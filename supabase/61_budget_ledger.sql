-- 61_budget_ledger.sql
-- Admin-only "Budget" tab in js/tasks.js: an append-only ledger of top-ups (never a single
-- overwritable number - same reasoning as the future PKR exchange rate idea, see
-- PROJECT_HANDOFF_v9.md §4.4). Budget = sum(amount) over this table. Everything else (used
-- credits by status, available balance) is computed live from public.tasks - not stored here,
-- so Withdraw/Reject naturally free up availability without any reversal bookkeeping.

create table if not exists public.budget_ledger (
  id bigint generated always as identity primary key,
  amount integer not null check (amount > 0),
  note text,
  created_at timestamptz not null default now(),
  created_by_email text
);

alter table public.budget_ledger enable row level security;

drop policy if exists "budget_ledger_admin_select" on public.budget_ledger;
create policy "budget_ledger_admin_select" on public.budget_ledger
  for select using (current_role_is('admin'));

drop policy if exists "budget_ledger_admin_insert" on public.budget_ledger;
create policy "budget_ledger_admin_insert" on public.budget_ledger
  for insert with check (current_role_is('admin'));
