-- 91_reward_compensation_and_anomalies.sql
-- GOVERNANCE.md §6.4 (Reward, phase 3) - the two pieces still open after migration 88's
-- read-only credit-circulation dashboard: compensation runs (row 15, "credits earned" vs
-- "credits paid" reconciliation) and an anomaly report (extra-credit outliers, credit growth
-- without published work). Also closes a gap the 2026-09-18 audit flagged: RF members could see
-- aggregate credit numbers (88) but not read `task_outcome_events` itself.
--
-- Row 15 says "Reward proposes, Lead Reward + Owner approves". This schema has no separate
-- "Owner" identity from Admin (§3: Alessandro = Owner + Admin) and no existing pattern anywhere
-- for a two-signature approval, so - same simplification GOVERNANCE.md itself makes elsewhere
-- for Owner/Admin - the approver here is Admin, and proposer != approver is enforced exactly
-- like every other propose/approve pair in the app (people_decisions, policy_proposals).

-- 1. The record that credits were converted to money. No other table's writes changed on the
-- strength of this ledger existing - it doesn't try to "mark tasks as redeemed", it just answers
-- "how much of this person's credit balance has already been settled?" via unsettled_credits()
-- below, so the same credits are never counted into two runs by mistake.
create table if not exists public.compensation_runs (
  id                bigint generated always as identity primary key,
  period_from       date not null,
  period_to         date not null,
  status            text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'withdrawn')),
  note              text,
  prepared_by       uuid not null references auth.users(id),
  prepared_by_email text not null,
  decided_by        uuid references auth.users(id),
  decided_by_email  text,
  decided_at        timestamptz,
  decision_note     text,
  created_at        timestamptz not null default now(),
  check (period_to >= period_from)
);

create table if not exists public.compensation_lines (
  id              bigint generated always as identity primary key,
  run_id          bigint not null references public.compensation_runs(id) on delete cascade,
  user_id         uuid not null references auth.users(id),
  user_email      text not null,
  credits_settled integer not null check (credits_settled > 0),
  amount          numeric not null check (amount > 0),
  currency        text not null default 'PKR',
  reference       text
);

alter table public.compensation_runs enable row level security;
alter table public.compensation_lines enable row level security;

drop policy if exists "compensation_runs_select" on public.compensation_runs;
create policy "compensation_runs_select" on public.compensation_runs
  for select using (public.is_dept_member('RF') or current_role_is('admin'));

drop policy if exists "compensation_lines_select" on public.compensation_lines;
create policy "compensation_lines_select" on public.compensation_lines
  for select using (public.is_dept_member('RF') or current_role_is('admin'));

-- No insert/update/delete policy on either table for anyone - same shape as `people_decisions`
-- and `policy_proposals`: the only writers are the two security-definer functions below.

-- 2. How many of this person's credits have never been part of an *approved* run - the ceiling
-- a new run's line for them can't exceed. Rejected/withdrawn/pending runs don't count against it.
create or replace function public.unsettled_credits(p_user_id uuid)
returns integer
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((select credits from public.user_roles where user_id = p_user_id), 0)
       - coalesce((
           select sum(cl.credits_settled)
           from public.compensation_lines cl
           join public.compensation_runs cr on cr.id = cl.run_id
           where cl.user_id = p_user_id and cr.status = 'approved'
         ), 0);
$$;

-- Picker for the "New compensation run" UI: everyone with something left to settle.
create or replace function public.reward_unsettled_credits()
returns table (
  user_id     uuid,
  email       text,
  full_name   text,
  unsettled   integer
)
language sql
security definer
stable
set search_path = public
as $$
  select ur.user_id, ur.email, up.full_name, public.unsettled_credits(ur.user_id)
  from public.user_roles ur
  left join public.user_profiles up on up.user_id = ur.user_id
  where public.unsettled_credits(ur.user_id) > 0
    and (public.is_dept_member('RF') or current_role_is('admin'))
  order by public.unsettled_credits(ur.user_id) desc;
$$;

-- 3. Entry point 1: propose. p_lines is a JSON array of
-- {"user_id", "credits_settled", "amount", "currency"?, "reference"?}. Validates each line
-- against unsettled_credits() at proposal time so a run can't overcommit what a person is
-- actually still owed - the same check re-runs implicitly at decide time isn't needed since
-- nothing else can create a competing approved run in between under normal single-admin use, and
-- a stale line simply fails the decide step's re-check below if it ever would overcommit.
create or replace function public.propose_compensation_run(p_period_from date, p_period_to date, p_note text, p_lines jsonb)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_run_id     bigint;
  v_email      text;
  v_line       jsonb;
  v_user_id    uuid;
  v_user_email text;
  v_credits    integer;
  v_amount     numeric;
  v_currency   text;
  v_reference  text;
begin
  if not public.is_dept_member('RF') then
    raise exception 'Only a Reward member can prepare a compensation run.';
  end if;
  if p_period_to < p_period_from then
    raise exception 'The period end cannot be before the period start.';
  end if;
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 then
    raise exception 'A compensation run needs at least one line.';
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  insert into public.compensation_runs (period_from, period_to, note, prepared_by, prepared_by_email)
  values (p_period_from, p_period_to, p_note, auth.uid(), v_email)
  returning id into v_run_id;

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_user_id   := (v_line->>'user_id')::uuid;
    v_credits   := (v_line->>'credits_settled')::integer;
    v_amount    := (v_line->>'amount')::numeric;
    v_currency  := coalesce(nullif(v_line->>'currency', ''), 'PKR');
    v_reference := v_line->>'reference';

    if v_user_id is null then raise exception 'Each line needs a person.'; end if;
    if v_credits is null or v_credits <= 0 then raise exception 'credits_settled must be a positive number.'; end if;
    if v_amount is null or v_amount <= 0 then raise exception 'amount must be a positive number.'; end if;
    if v_credits > public.unsettled_credits(v_user_id) then
      raise exception 'That amount of credits exceeds what is still unsettled for one of the selected people.';
    end if;

    select email into v_user_email from public.user_roles where user_id = v_user_id;

    insert into public.compensation_lines (run_id, user_id, user_email, credits_settled, amount, currency, reference)
    values (v_run_id, v_user_id, v_user_email, v_credits, v_amount, v_currency, v_reference);
  end loop;

  return v_run_id;
end;
$$;

-- 4. Entry point 2: decide. Admin stands in for "Owner" (see header note); proposer never equals
-- approver, checked in SQL. The proposer alone may withdraw a still-pending run.
create or replace function public.decide_compensation_run(p_run_id bigint, p_outcome text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  r       public.compensation_runs%rowtype;
  v_email text;
  v_line  record;
begin
  select * into r from public.compensation_runs where id = p_run_id for update;
  if r is null then raise exception 'Compensation run not found.'; end if;
  if r.status <> 'pending' then raise exception 'This run has already been decided (%).', r.status; end if;
  if p_outcome not in ('approved', 'rejected', 'withdrawn') then raise exception 'Invalid outcome.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_outcome = 'withdrawn' then
    if r.prepared_by <> auth.uid() then raise exception 'Only the person who prepared this run can withdraw it.'; end if;
  else
    if r.prepared_by = auth.uid() then
      raise exception 'The person who prepared a compensation run cannot approve or reject it.';
    end if;
    if not current_role_is('admin') then
      raise exception 'Only Admin (acting for the Owner, GOVERNANCE.md row 15) can decide a compensation run.';
    end if;
    if p_outcome = 'rejected' and (p_note is null or btrim(p_note) = '') then
      raise exception 'A note is required when rejecting.';
    end if;
    if p_outcome = 'approved' then
      -- Re-check at decision time: another run could have been approved for the same person in
      -- between proposing and deciding this one. unsettled_credits() only counts *approved*
      -- lines, so this run's own still-pending line isn't already subtracted from it - a direct
      -- comparison is correct here, not a re-derivation.
      for v_line in select * from public.compensation_lines where run_id = p_run_id loop
        if v_line.credits_settled > public.unsettled_credits(v_line.user_id) then
          raise exception 'This run would overcommit credits already settled elsewhere for one of its lines - reject it and prepare a fresh one.';
        end if;
      end loop;
    end if;
  end if;

  update public.compensation_runs
  set status = p_outcome, decided_by = auth.uid(), decided_by_email = v_email, decided_at = now(), decision_note = p_note
  where id = p_run_id;
end;
$$;

-- 5. RF members can now read the outcome ledger itself, not just aggregates (88 gave them
-- budget_ledger and reward_credit_overview() only) - needed for the anomaly report below and for
-- reconciling what compensation runs settle against what was actually earned. Additive to the
-- existing policy (Postgres OR's them together).
drop policy if exists "task_outcome_events_rf_select" on public.task_outcome_events;
create policy "task_outcome_events_rf_select" on public.task_outcome_events
  for select using (public.is_dept_member('RF'));

-- 6. Anomaly report, part A: every task that ever carried extra credits, whatever its current
-- extra_credits_status (migration 90) - "a task published with unusual extra credits" (§2.4).
create or replace function public.reward_extra_credit_tasks()
returns table (
  id                               bigint,
  title                            text,
  category                         text,
  status                           text,
  base_credits                     integer,
  extra_credits                    integer,
  extra_credits_note               text,
  extra_credits_status             text,
  created_by_email                 text,
  extra_credits_approved_by_email  text
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id, t.title, t.category, t.status, t.base_credits, t.extra_credits, t.extra_credits_note,
         t.extra_credits_status, t.created_by_email, t.extra_credits_approved_by_email
  from public.tasks t
  where t.extra_credits <> 0
    and (public.is_dept_member('RF') or current_role_is('admin'))
  order by t.extra_credits desc;
$$;

-- 7. Anomaly report, part B: "an operator whose credits grow faster than their published work"
-- (§2.4) - flags whoever has more credit sitting in 'approved' (reviewed, earned, not yet
-- published) than they have ever had published, above a configurable floor so a normal small
-- backlog doesn't light up for everyone.
insert into public.policy_values (key, value, label) values
  ('reward_anomaly_backlog_credits', 100, 'Flag an operator in the Reward anomaly report once their approved-but-unpublished credits exceed this, and exceed their published credits too')
on conflict (key) do nothing;

create or replace function public.reward_operator_credit_anomalies()
returns table (
  user_id                        uuid,
  email                          text,
  full_name                      text,
  credits                        integer,
  reputation                     integer,
  approved_not_published_credits integer,
  published_credits              integer,
  published_task_count           integer,
  flagged                        boolean
)
language sql
security definer
stable
set search_path = public
as $$
  select
    ur.user_id, ur.email, up.full_name, ur.credits, ur.reputation,
    coalesce(a.approved_credits, 0)::integer,
    coalesce(p.published_credits, 0)::integer,
    coalesce(p.published_count, 0)::integer,
    coalesce(a.approved_credits, 0) > greatest(coalesce(p.published_credits, 0), public.policy_value('reward_anomaly_backlog_credits', 100))
  from public.user_roles ur
  left join public.user_profiles up on up.user_id = ur.user_id
  left join (
    select claimed_by, sum(credits) as approved_credits
    from public.tasks where status = 'approved' and claimed_by is not null group by claimed_by
  ) a on a.claimed_by = ur.user_id
  left join (
    select claimed_by, sum(credits) as published_credits, count(*) as published_count
    from public.tasks where status = 'published' and claimed_by is not null group by claimed_by
  ) p on p.claimed_by = ur.user_id
  where (coalesce(a.approved_credits, 0) > 0 or coalesce(p.published_credits, 0) > 0)
    and (public.is_dept_member('RF') or current_role_is('admin'))
  order by coalesce(a.approved_credits, 0) desc;
$$;

notify pgrst, 'reload schema';

-- Self-test.
select 'table compensation_runs' as item, to_regclass('public.compensation_runs') is not null as ok
union all select 'table compensation_lines', to_regclass('public.compensation_lines') is not null
union all select 'compensation_runs has no write policy (select only)', (select count(*) = 1 from pg_policies where tablename = 'compensation_runs')
union all select 'compensation_lines has no write policy (select only)', (select count(*) = 1 from pg_policies where tablename = 'compensation_lines')
union all select 'function unsettled_credits', (select count(*) = 1 from pg_proc where proname = 'unsettled_credits')
union all select 'function reward_unsettled_credits', (select count(*) = 1 from pg_proc where proname = 'reward_unsettled_credits')
union all select 'function propose_compensation_run', (select count(*) = 1 from pg_proc where proname = 'propose_compensation_run')
union all select 'function decide_compensation_run', (select count(*) = 1 from pg_proc where proname = 'decide_compensation_run')
union all select 'policy task_outcome_events_rf_select', exists (select 1 from pg_policies where tablename = 'task_outcome_events' and policyname = 'task_outcome_events_rf_select')
union all select 'function reward_extra_credit_tasks', (select count(*) = 1 from pg_proc where proname = 'reward_extra_credit_tasks')
union all select 'function reward_operator_credit_anomalies', (select count(*) = 1 from pg_proc where proname = 'reward_operator_credit_anomalies')
union all select 'policy_values.reward_anomaly_backlog_credits', exists (select 1 from public.policy_values where key = 'reward_anomaly_backlog_credits');
