-- 88_reward_credit_overview.sql
-- GOVERNANCE.md §6.4: "Read access to budget_ledger, task_outcome_events, rates and tiers for
-- RF members" - the first, smallest piece of Reward Phase 3. Reward needs to see how many
-- credits are open/claimed/awaiting review/published at any moment (to tune category rates and
-- reputation tiers via the policy revision framework, migration 86, and later to plan
-- compensation runs) - but today RF members can't even read the `tasks` table: its RLS
-- (tasks_select_team, 38_task_review_pipeline.sql) requires Operator+/Coordinator/being the
-- task's own claimant. Widening that broadly would let Reward browse task details it has no
-- reason to see; instead, same pattern as hr_people_overview() (80_departments_and_people_
-- decisions.sql), a small RPC returns only the aggregate a Reward lead actually needs.

create or replace function public.reward_credit_overview()
returns table (
  open_credits         integer,  -- posted, not yet claimed
  in_progress_credits  integer,  -- claimed or submitted, not yet decided
  to_redeem_credits    integer,  -- approved, awaiting publish
  redeemed_credits     integer,  -- published
  budget                integer  -- sum of all budget_ledger top-ups ever
)
language sql
security definer
stable
set search_path = public
as $$
  select
    coalesce(sum(t.credits) filter (where t.status = 'open'), 0)::integer,
    coalesce(sum(t.credits) filter (where t.status in ('claimed', 'submitted')), 0)::integer,
    coalesce(sum(t.credits) filter (where t.status = 'approved'), 0)::integer,
    coalesce(sum(t.credits) filter (where t.status = 'published'), 0)::integer,
    coalesce((select sum(amount) from public.budget_ledger), 0)::integer
  from public.tasks t
  where t.status in ('open', 'claimed', 'submitted', 'approved', 'published')
  having (public.is_dept_member('RF') or current_role_is('admin'));
  -- HAVING (not WHERE) so the whole row - including the budget subquery - is dropped for an
  -- unauthorized caller: returns zero rows, not zero values, same "no rows to anyone else"
  -- shape as hr_people_overview(). WHERE would still leak the real budget total, since that
  -- subquery isn't otherwise tied to the tasks.status filter.
$$;

-- budget_ledger: RF members may now read the top-up ledger too (decision matrix row 16, "Reward
-- informed" on every top-up) - Admin remains the only one who can insert (Owner tops up, per the
-- same row). Additive to the existing admin-only select policy (Postgres OR's them together).
drop policy if exists "budget_ledger_rf_select" on public.budget_ledger;
create policy "budget_ledger_rf_select" on public.budget_ledger
  for select using (public.is_dept_member('RF'));

-- Self-test.
select 'function reward_credit_overview' as item, to_regproc('public.reward_credit_overview') is not null as ok
union all select 'policy budget_ledger_rf_select', exists (select 1 from pg_policies where tablename = 'budget_ledger' and policyname = 'budget_ledger_rf_select')
union all select 'budget_ledger admin select untouched', exists (select 1 from pg_policies where tablename = 'budget_ledger' and policyname = 'budget_ledger_admin_select')
union all select 'budget_ledger admin insert untouched', exists (select 1 from pg_policies where tablename = 'budget_ledger' and policyname = 'budget_ledger_admin_insert');
