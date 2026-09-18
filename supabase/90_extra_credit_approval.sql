-- 90_extra_credit_approval.sql
-- Closes GOVERNANCE.md decision-matrix row 10, the one concrete gap left open by the September
-- 2026 audit of migrations 80-89 ("Grant extra credits beyond the rate - Coordinator proposes
-- (with note) - Lead Coordination approves if above the threshold in Options - GOVERNANCE.md
-- §8.3: extra > 30% of base credits, or > 10 credits absolute, whichever is lower"). The
-- thresholds (extra_credit_pct_threshold, extra_credit_abs_threshold) have existed as editable
-- policy_values since migration 80, but nothing ever read them: a Coordinator could set any
-- extra_credits value on a task with no Coordination-lead sign-off at all.
--
-- Enforcement point: NOT task creation or claiming - an Operator should be free to start the
-- work in good faith while sign-off is pending, and gating creation would mean reworking
-- tasks_select_team/tasks_insert_reviewers RLS that half the app depends on, for no real safety
-- gain. Instead this gates the actual credit *grant*: submit_task_review()
-- (57_task_category_rates_and_extra_credits.sql) is the one place a task's credits turn into a
-- real task_outcome_events row (and, via its existing trigger, real user_roles.credits). A task
-- above threshold can be created, claimed, worked and submitted exactly as before; it just can't
-- be given an 'ok'/'ok_but' verdict - i.e. its credits can't be paid out - until a Coordination
-- lead who is not its own creator approves the extra amount.

-- 1. Track approval state on the task itself. Server-computed (see trigger below), never
-- trusted from the client.
alter table public.tasks
  add column if not exists extra_credits_status text not null default 'none'
    check (extra_credits_status in ('none', 'pending', 'approved')),
  add column if not exists extra_credits_approved_by uuid references auth.users(id),
  add column if not exists extra_credits_approved_by_email text,
  add column if not exists extra_credits_approved_at timestamptz;

-- A task can't carry extra credits without saying why - already required client-side
-- (js/tasks.js), made a real constraint so it can't be bypassed by calling the API directly.
-- NOT VALID: only enforced for new inserts/updates from here on, doesn't fail this migration
-- over any pre-existing row that predates the client-side check.
alter table public.tasks drop constraint if exists tasks_extra_credits_note_required;
alter table public.tasks
  add constraint tasks_extra_credits_note_required
  check (extra_credits = 0 or extra_credits_note is not null) not valid;

-- 2. Threshold check (GOVERNANCE.md §8.3): approval is needed once extra_credits exceeds the
-- LOWER of the two configured thresholds (30% of base, or 10 credits absolute, by default -
-- both editable in Options -> Policy values / My Department -> Policy, migration 80/86).
create or replace function public.extra_credit_needs_approval(p_base_credits integer, p_extra_credits integer)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(p_extra_credits, 0) > least(
    coalesce(p_base_credits, 0) * public.policy_value('extra_credit_pct_threshold', 30) / 100.0,
    public.policy_value('extra_credit_abs_threshold', 10)::numeric
  );
$$;

-- 3. extra_credits_status is recomputed server-side on every insert/update, overwriting
-- whatever the client sent - nobody can insert a task pre-marked 'approved', or keep a stale
-- 'approved' after quietly raising extra_credits afterwards. An unrelated update (claim, status
-- change...) that leaves extra_credits untouched must not reset an approval that already
-- happened, so that one case is carried over explicitly from OLD.
create or replace function public.set_extra_credit_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.extra_credit_needs_approval(new.base_credits, new.extra_credits) then
    new.extra_credits_status := 'none';
    new.extra_credits_approved_by := null;
    new.extra_credits_approved_by_email := null;
    new.extra_credits_approved_at := null;
  elsif tg_op = 'UPDATE' then
    if old.extra_credits = new.extra_credits and old.extra_credits_status = 'approved' then
      new.extra_credits_status := 'approved';
      new.extra_credits_approved_by := old.extra_credits_approved_by;
      new.extra_credits_approved_by_email := old.extra_credits_approved_by_email;
      new.extra_credits_approved_at := old.extra_credits_approved_at;
    else
      new.extra_credits_status := 'pending';
      new.extra_credits_approved_by := null;
      new.extra_credits_approved_by_email := null;
      new.extra_credits_approved_at := null;
    end if;
  else
    new.extra_credits_status := 'pending';
    new.extra_credits_approved_by := null;
    new.extra_credits_approved_by_email := null;
    new.extra_credits_approved_at := null;
  end if;
  return new;
end;
$$;

drop trigger if exists set_extra_credit_status_trigger on public.tasks;
create trigger set_extra_credit_status_trigger
  before insert or update on public.tasks
  for each row execute function public.set_extra_credit_status();

-- Backfill every task written before this migration existed - the trigger only fires on writes
-- from now on. A no-op UPDATE of extra_credits (not id - id is a GENERATED ALWAYS identity
-- column and rejects being "updated" even to its own value) is enough to make the trigger run
-- its own logic for every row; since extra_credits_status was just added as 'none' for all of
-- them, this lands exactly on 'pending' for anything already above threshold and 'none'
-- otherwise - the same place a fresh insert would.
update public.tasks set extra_credits = extra_credits;

-- 4. Entry point: a Coordination lead approves a pending extra-credit amount. Proposer never
-- equals approver (GOVERNANCE.md §1 principle 2) even when the same person happens to be both a
-- Coordinator and the Coordination lead (§8.1's temporary dual-hat allowance) - the check is
-- against the task's own creator, not the caller's general permissions.
create or replace function public.approve_task_extra_credits(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t public.tasks%rowtype;
  v_email text;
begin
  select * into t from public.tasks where id = p_task_id for update;
  if t is null then raise exception 'Task not found.'; end if;
  if t.extra_credits_status <> 'pending' then
    raise exception 'This task has no extra-credit approval pending.';
  end if;
  if not public.is_dept_lead('COORD') then
    raise exception 'Only the Coordination lead can approve extra credits.';
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();
  if t.created_by_email = v_email then
    raise exception 'The person who proposed the extra credits cannot approve them.';
  end if;

  update public.tasks
  set extra_credits_status = 'approved',
      extra_credits_approved_by = auth.uid(),
      extra_credits_approved_by_email = v_email,
      extra_credits_approved_at = now()
  where id = p_task_id;
end;
$$;

-- 5. Close the loop where credits are actually granted - block a passing verdict on a task
-- whose extra credits are still pending, same function otherwise (57_task_category_rates_and_
-- extra_credits.sql).
create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_new_status text;
  v_event_type text;
begin
  if not exists (select 1 from public.user_qualifications where user_id = auth.uid() and qualification_code = 'REVISOR') then
    raise exception 'Only a Revisor can submit a review verdict.';
  end if;
  if p_verdict not in ('ok', 'ok_but', 'fail') then
    raise exception 'Invalid verdict.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'submitted' then raise exception 'Only a submitted task can be reviewed.'; end if;

  if p_verdict in ('ok', 'ok_but') and v_task.extra_credits_status = 'pending' then
    raise exception 'This task''s extra credits (%) are still awaiting Coordination-lead approval - it cannot be given a passing verdict until then.', v_task.extra_credits;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'ok' then
    v_new_status := 'approved'; v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := 10; v_event_type := 'review_ok';
  elsif p_verdict = 'ok_but' then
    v_new_status := 'approved'; v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := -5; v_event_type := 'review_ok_but';
  else
    v_new_status := 'rejected'; v_credit_delta := 0; v_reputation_delta := -10; v_event_type := 'review_fail';
  end if;

  update public.tasks
  set status = v_new_status, review_verdict = p_verdict, review_notes = p_notes,
      reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
  where id = p_task_id;

  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_notes);

  if p_verdict = 'fail' then
    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      base_credits, extra_credits, extra_credits_note,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.base_credits, v_task.extra_credits, v_task.extra_credits_note,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  end if;
end;
$$;

-- 6. coordination_task_overview() (89) needs the extra-credit fields so My Department ->
-- Coordination can show a pending-approval queue - column list changed, so drop-and-recreate.
drop function if exists public.coordination_task_overview();
create or replace function public.coordination_task_overview()
returns table (
  id                       bigint,
  title                    text,
  category                 text,
  status                   text,
  claimed_by               uuid,
  due_date                 date,
  created_at               timestamptz,
  base_credits             integer,
  extra_credits            integer,
  extra_credits_note       text,
  extra_credits_status     text,
  created_by_email         text
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id, t.title, t.category, t.status, t.claimed_by, t.due_date, t.created_at,
         t.base_credits, t.extra_credits, t.extra_credits_note, t.extra_credits_status, t.created_by_email
  from public.tasks t
  where (t.status in ('open', 'claimed', 'submitted', 'approved') or t.extra_credits_status = 'pending')
    and (public.is_dept_member('COORD') or current_role_is('coordinator') or current_role_is('admin'));
$$;

notify pgrst, 'reload schema';

-- Self-test.
select 'tasks.extra_credits_status' as item, exists (select 1 from information_schema.columns where table_name = 'tasks' and column_name = 'extra_credits_status') as ok
union all select 'function extra_credit_needs_approval', (select count(*) = 1 from pg_proc where proname = 'extra_credit_needs_approval')
union all select 'function set_extra_credit_status', (select count(*) = 1 from pg_proc where proname = 'set_extra_credit_status')
union all select 'trigger set_extra_credit_status_trigger', (select count(*) = 1 from pg_trigger where tgname = 'set_extra_credit_status_trigger')
union all select 'function approve_task_extra_credits', (select count(*) = 1 from pg_proc where proname = 'approve_task_extra_credits')
union all select 'submit_task_review blocks pending extra credits', (select prosrc like '%extra_credits_status = ''pending''%' from pg_proc where proname = 'submit_task_review')
union all select 'constraint tasks_extra_credits_note_required', (select count(*) = 1 from pg_constraint where conname = 'tasks_extra_credits_note_required')
union all select 'coordination_task_overview returns extra_credits_status', (select count(*) = 1 from information_schema.columns where table_name = 'tasks' and column_name = 'extra_credits_status')
union all select 'no task left mismarked (pending vs. threshold)', (
  select count(*) = 0 from public.tasks t
  where t.extra_credits_status = 'none' and public.extra_credit_needs_approval(t.base_credits, t.extra_credits)
);
