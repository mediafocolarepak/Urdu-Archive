-- 98_department_status.sql
-- "Department Pulse" Phase 1 (owner's request 2026-09-20): a lead-managed status banner + a
-- short priorities/deadlines list per department, so every member can see at a glance how their
-- department is doing and what matters right now - a human touch, not an automated metric.
-- Deliberately manual in this phase: the lead picks the color and writes the note themselves,
-- rather than the app computing it - see PROJECT_HANDOFF for the reasoning (a wrong automatic
-- signal is worse than an honestly subjective one). An automatic suggestion, and an Admin-only
-- roll-up across every department, may follow later (Phase 2) once this phase shows real use -
-- the roll-up needs nothing new here since Admin already reads every row via the policies below.
--
-- Run after 97_share_with_us_operators.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. department_status: one row per department, upserted by its lead.
-- ============================================================================
create table if not exists public.department_status (
  department_code text primary key,
  status          text        not null default 'on_track' check (status in ('on_track', 'slowing', 'stalled')),
  note            text,
  updated_by_email text,
  updated_at      timestamptz not null default now()
);

alter table public.department_status enable row level security;

drop policy if exists "department_status_select" on public.department_status;
create policy "department_status_select" on public.department_status
  for select using (public.is_dept_member(department_code) or current_role_is('admin'));

drop policy if exists "department_status_write" on public.department_status;
create policy "department_status_write" on public.department_status
  for all
  using (public.is_dept_lead(department_code) or current_role_is('admin'))
  with check (public.is_dept_lead(department_code) or current_role_is('admin'));

-- ============================================================================
-- 2. department_priorities: a short, ordered list of what the department is focused on right
--    now - not a second task system, just titles with an optional due date, managed by the lead.
-- ============================================================================
create table if not exists public.department_priorities (
  id               bigint generated always as identity primary key,
  department_code  text        not null,
  title            text        not null check (btrim(title) <> ''),
  due_date         date,
  sort_order       integer     not null default 0,
  done             boolean     not null default false,
  done_at          timestamptz,
  created_by_email text,
  created_at       timestamptz not null default now()
);
create index if not exists idx_department_priorities_dept
  on public.department_priorities (department_code, done, sort_order, created_at);

alter table public.department_priorities enable row level security;

drop policy if exists "department_priorities_select" on public.department_priorities;
create policy "department_priorities_select" on public.department_priorities
  for select using (public.is_dept_member(department_code) or current_role_is('admin'));

drop policy if exists "department_priorities_write" on public.department_priorities;
create policy "department_priorities_write" on public.department_priorities
  for all
  using (public.is_dept_lead(department_code) or current_role_is('admin'))
  with check (public.is_dept_lead(department_code) or current_role_is('admin'));

-- ============================================================================
-- 3. Self-test (run separately). All rows must be true.
-- ============================================================================
select 'table department_status' as item, (to_regclass('public.department_status') is not null) as ok
union all select 'policies department_status (2)', (select count(*) = 2 from pg_policies where tablename = 'department_status')
union all select 'table department_priorities', (to_regclass('public.department_priorities') is not null)
union all select 'policies department_priorities (2)', (select count(*) = 2 from pg_policies where tablename = 'department_priorities');
