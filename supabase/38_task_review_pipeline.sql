-- Step 1 of the task review/reputation design (see PROJECT_HANDOFF_v6.md session notes,
-- 2026-08-31): the state-machine skeleton and the credits/reputation ledger. Does NOT yet
-- include the anonymized review queue or the verdict/retry-spawn RPC (that's step 2 - a
-- Revisor's verdict is what actually produces 'approved'/'rejected' events and, on fail,
-- spawns the retry task; until then a submitted task just sits in 'submitted' limbo, which is
-- expected) or the Admin publish UI (step 3) or the reputation bar (step 4).
--
-- New lifecycle: open -> claimed -> submitted -> approved -> published (success), or
-- open -> claimed -> submitted -> rejected (fail, terminal - step 2 will spawn a fresh open
-- task from here). Replaces the old open/claimed/done set - existing 'done' rows are migrated
-- to 'published' since that's what "done" meant before this pipeline existed.
-- Do after 37_task_qualifications_categories.sql.

update public.tasks set status = 'published' where status = 'done';

alter table public.tasks drop constraint if exists tasks_status_check;
alter table public.tasks add constraint tasks_status_check
  check (status in ('open', 'claimed', 'submitted', 'approved', 'rejected', 'published'));

alter table public.tasks add column if not exists submitted_at timestamptz;
alter table public.tasks add column if not exists review_verdict text check (review_verdict in ('ok', 'ok_but', 'fail'));
alter table public.tasks add column if not exists review_notes text;
alter table public.tasks add column if not exists reviewed_by uuid references auth.users(id) on delete set null;
alter table public.tasks add column if not exists reviewed_by_email text;
alter table public.tasks add column if not exists reviewed_at timestamptz;
alter table public.tasks add column if not exists published_at timestamptz;
-- Set by step 2's fail-verdict RPC when it spawns a retry task, so the retry links back to the
-- failed attempt (audit trail) and can't be claimed by the same operator who failed it.
alter table public.tasks add column if not exists retry_of_task_id bigint references public.tasks(id) on delete set null;
alter table public.tasks add column if not exists excluded_operator uuid references auth.users(id) on delete set null;

-- Enforces the lifecycle above at the DB layer regardless of which client code path writes to
-- the row - cheap insurance against a future bug silently corrupting task state. Same-status
-- updates (editing due_date, description, etc.) are always allowed.
create or replace function public.validate_task_status_transition()
returns trigger
language plpgsql
as $$
begin
  if new.status = old.status then
    return new;
  end if;
  if (old.status, new.status) in (
    ('open', 'claimed'), ('claimed', 'open'), ('claimed', 'submitted'),
    ('submitted', 'approved'), ('submitted', 'rejected'), ('approved', 'published')
  ) then
    return new;
  end if;
  raise exception 'Illegal task status transition: % -> %', old.status, new.status;
end;
$$;

drop trigger if exists tasks_validate_status_transition on public.tasks;
create trigger tasks_validate_status_transition
  before update on public.tasks
  for each row execute function public.validate_task_status_transition();

-- Credits (cumulative "currency", never decreases on its own) and reputation (bounded 0-100
-- trust score, starts neutral rather than at 0 so a brand-new Operator isn't "in the red" from
-- day one) - both derived from task_outcome_events below, kept denormalized here for cheap
-- reads. Only Operators are meant to accrue these in practice, but the columns aren't
-- role-restricted at the DB level (harmless if unused for other roles).
alter table public.user_roles add column if not exists credits integer not null default 0;
alter table public.user_roles add column if not exists reputation integer not null default 70;

-- The audit trail / source of truth behind credits and reputation - one row per task outcome
-- that affects an operator's standing. event_type is intentionally a plain text tag rather
-- than a hard enum: step 2 (review verdicts) and later conduct-related events will add more
-- values than the one this step already needs ('reclaimed').
create table if not exists public.task_outcome_events (
  id bigint generated always as identity primary key,
  task_id bigint references public.tasks(id) on delete set null,
  user_id uuid not null references auth.users(id) on delete cascade,
  event_type text not null,
  credit_delta integer not null default 0,
  reputation_delta integer not null default 0,
  created_at timestamptz not null default now(),
  created_by_email text,
  note text
);
alter table public.task_outcome_events enable row level security;

drop policy if exists "task_outcome_events_select" on public.task_outcome_events;
create policy "task_outcome_events_select" on public.task_outcome_events
  for select using (user_id = auth.uid() or current_role_is('coordinator'));
-- No insert/update/delete policy for authenticated on purpose: rows are only ever written by
-- security-definer functions (reclaim_task below, and step 2's verdict RPC), which bypass RLS
-- as the function owner - this table is never written to directly from client code.

create or replace function public.apply_task_outcome_deltas()
returns trigger
language plpgsql
security definer
as $$
begin
  update public.user_roles
  set credits = credits + new.credit_delta,
      reputation = greatest(0, least(100, reputation + new.reputation_delta))
  where user_id = new.user_id;
  return new;
end;
$$;

drop trigger if exists task_outcome_events_apply_deltas on public.task_outcome_events;
create trigger task_outcome_events_apply_deltas
  after insert on public.task_outcome_events
  for each row execute function public.apply_task_outcome_deltas();

-- An operator excluded from a specific (retry-spawned) task can't claim it, nor be assigned to
-- it directly by a Coordinator - checked on both the read side (so it doesn't even show as
-- claimable) and the write side (defense in depth, matches the qualification checks already
-- added in 37).
drop policy if exists "tasks_select_team" on public.tasks;
create policy "tasks_select_team" on public.tasks
  for select using (
    current_role_is('coordinator')
    or claimed_by = auth.uid()
    or (
      current_role_is('operator')
      and public.user_qualifies_for_category(auth.uid(), category)
      and (excluded_operator is null or excluded_operator <> auth.uid())
    )
  );

drop policy if exists "tasks_update_own_or_reviewers" on public.tasks;
create policy "tasks_update_own_or_reviewers" on public.tasks
  for update using (
    current_role_is('coordinator')
    or claimed_by = auth.uid()
    or (
      claimed_by is null
      and public.user_qualifies_for_category(auth.uid(), category)
      and (excluded_operator is null or excluded_operator <> auth.uid())
    )
  ) with check (
    (claimed_by = auth.uid() and (excluded_operator is null or excluded_operator <> auth.uid()))
    or (current_role_is('coordinator') and (claimed_by is null or public.user_qualifies_for_category(claimed_by, category)))
  );

-- Coordinator/Admin pulling back a claimed task (overdue with no response, or inappropriate
-- conduct) - applies the same negative reputation delta either way; the free-text note is
-- where the actual reason lives. Replaces the old plain "free up" update (tasks.js's
-- task-team-free button) so the penalty is never skippable by calling the update directly.
create or replace function public.reclaim_task(p_task_id bigint, p_note text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
begin
  if not current_role_is('coordinator') then
    raise exception 'Only Coordinator/Admin can reclaim a task.';
  end if;
  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'claimed' or v_task.claimed_by is null then
    raise exception 'Only a claimed task can be reclaimed.';
  end if;

  update public.tasks
  set status = 'open', claimed_by = null, claimed_by_email = null, claimed_at = null, due_date = null
  where id = p_task_id;

  select email into v_email from public.user_roles where user_id = auth.uid();
  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, 'reclaimed', 0, -10, v_email, p_note);
end;
$$;

select 'task review pipeline (step 1: states + ledger) installato.' as result;
