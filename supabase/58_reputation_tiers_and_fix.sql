-- 58_reputation_tiers_and_fix.sql
-- Two things in one migration:
-- 1. Fixes a regression in 57_task_category_rates_and_extra_credits.sql: that migration
--    redefined submit_task_review() from the OLD body in 40_task_review_verdict.sql, not
--    realizing 43_admin_final_decision.sql had already replaced it with the current, correct
--    one (Coordinator can review, self-review blocked, ok/ok_but deferred to Admin's decision).
--    This migration redefines both submit_task_review() and admin_decide_task() from the
--    correct 43_admin_final_decision.sql bodies, so running this after 57 (in either order,
--    as long as 58 runs last) leaves the app in the right state.
-- 2. Adds task_reputation_tiers: an admin-editable table of reputation deltas (OK / OK-but /
--    Fail-or-Reject) scaled by a task's base_credits, replacing the flat +10/-5/-10 that was
--    hardcoded before. A tier match is looked up by both submit_task_review() (fail path only)
--    and admin_decide_task() (publish/reject path) via the task_reputation_deltas() helper.

create table if not exists task_reputation_tiers (
  tier_name text primary key,
  min_base_credits integer not null,
  max_base_credits integer,
  ok_delta integer not null,
  ok_but_delta integer not null,
  fail_delta integer not null,
  sort_order integer not null default 0,
  updated_at timestamptz not null default now(),
  updated_by_email text
);

alter table task_reputation_tiers enable row level security;

drop policy if exists task_reputation_tiers_select on task_reputation_tiers;
create policy task_reputation_tiers_select on task_reputation_tiers
  for select using (current_role_is('user'));

drop policy if exists task_reputation_tiers_admin_insert on task_reputation_tiers;
create policy task_reputation_tiers_admin_insert on task_reputation_tiers
  for insert with check (current_role_is('admin'));

drop policy if exists task_reputation_tiers_admin_update on task_reputation_tiers;
create policy task_reputation_tiers_admin_update on task_reputation_tiers
  for update using (current_role_is('admin')) with check (current_role_is('admin'));

drop policy if exists task_reputation_tiers_admin_delete on task_reputation_tiers;
create policy task_reputation_tiers_admin_delete on task_reputation_tiers
  for delete using (current_role_is('admin'));

insert into task_reputation_tiers (tier_name, min_base_credits, max_base_credits, ok_delta, ok_but_delta, fail_delta, sort_order) values
  ('Small', 0, 10, 5, -3, -5, 1),
  ('Medium', 11, 30, 10, -5, -10, 2),
  ('Large', 31, null, 15, -8, -15, 3)
on conflict (tier_name) do update set
  min_base_credits = excluded.min_base_credits, max_base_credits = excluded.max_base_credits,
  ok_delta = excluded.ok_delta, ok_but_delta = excluded.ok_but_delta, fail_delta = excluded.fail_delta,
  sort_order = excluded.sort_order;

-- Looks up the tier matching a task's base_credits. Returns zero rows if no tier matches
-- (e.g. the table is empty) - callers must coalesce to a safe fallback, which they do.
create or replace function public.task_reputation_deltas(p_base_credits integer)
returns table(ok_delta integer, ok_but_delta integer, fail_delta integer)
language sql
stable
as $$
  select t.ok_delta, t.ok_but_delta, t.fail_delta
  from public.task_reputation_tiers t
  where coalesce(p_base_credits, 0) >= t.min_base_credits
    and (t.max_base_credits is null or coalesce(p_base_credits, 0) <= t.max_base_credits)
  order by t.sort_order
  limit 1;
$$;

create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_fail_delta integer;
begin
  if not (
    current_role_is('coordinator')
    or exists (select 1 from public.user_qualifications where user_id = auth.uid() and qualification_code = 'REVISOR')
  ) then
    raise exception 'Only a Revisor (or Coordinator/Admin) can submit a review verdict.';
  end if;
  if p_verdict not in ('ok', 'ok_but', 'fail') then
    raise exception 'Invalid verdict.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'submitted' then raise exception 'Only a submitted task can be reviewed.'; end if;
  if v_task.claimed_by = auth.uid() then raise exception 'You cannot review your own task.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'fail' then
    select fail_delta into v_fail_delta from public.task_reputation_deltas(v_task.base_credits);
    v_fail_delta := coalesce(v_fail_delta, -10);

    update public.tasks
    set status = 'rejected', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;

    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (p_task_id, v_task.claimed_by, 'review_fail', 0, v_fail_delta, v_email, p_notes);

    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      base_credits, extra_credits, extra_credits_note,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.base_credits, v_task.extra_credits, v_task.extra_credits_note,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  else
    -- ok / ok_but: just record the verdict and hand off to Admin - no ledger event yet.
    update public.tasks
    set status = 'approved', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;
  end if;
end;
$$;

create or replace function public.admin_decide_task(p_task_id bigint, p_decision text, p_note text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_event_type text;
  v_ok_delta integer;
  v_ok_but_delta integer;
  v_fail_delta integer;
begin
  if not current_role_is('admin') then
    raise exception 'Only Admin can make the final publish/reject decision.';
  end if;
  if p_decision not in ('publish', 'reject') then
    raise exception 'Invalid decision.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'approved' then raise exception 'Only an approved task can be published or rejected.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();
  select ok_delta, ok_but_delta, fail_delta into v_ok_delta, v_ok_but_delta, v_fail_delta
    from public.task_reputation_deltas(v_task.base_credits);
  v_ok_delta := coalesce(v_ok_delta, 10);
  v_ok_but_delta := coalesce(v_ok_but_delta, -5);
  v_fail_delta := coalesce(v_fail_delta, -10);

  if p_decision = 'publish' then
    if v_task.review_verdict = 'ok_but' then
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := v_ok_but_delta; v_event_type := 'review_ok_but';
    else
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := v_ok_delta; v_event_type := 'review_ok';
    end if;
    update public.tasks set status = 'published', published_at = now() where id = p_task_id;
  else
    v_credit_delta := 0; v_reputation_delta := v_fail_delta; v_event_type := 'admin_rejected';
    update public.tasks set status = 'rejected' where id = p_task_id;
  end if;

  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_note);
end;
$$;
