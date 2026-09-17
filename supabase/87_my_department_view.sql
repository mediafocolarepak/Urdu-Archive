-- 87_my_department_view.sql
-- "My Department" view: a department lead should be able to see and run their own team without
-- going through Admin for everyday membership changes - but appointing/removing the LEAD itself
-- stays an Owner/Admin decision (GOVERNANCE.md §4 row 8, discussed explicitly with the owner
-- 2026-09-17: department leads are appointed by the Owner, not delegated to a generic Admin
-- action a lead could trigger on themselves or a peer).
--
-- So this migration extends department_members' RLS with two new, narrowly-scoped policies for
-- department leads, additive to the existing admin-only ones (Postgres OR's multiple permissive
-- policies for the same command together):
--   - a lead may INSERT a new member into their own department, but never with is_lead = true
--     (no self-appointing a co-lead or handing the lead badge to someone else)
--   - a lead may DELETE an ordinary member of their own department, but never the lead row itself
-- Admin keeps full control (including setting/unsetting is_lead) via the existing admin_insert/
-- admin_update/admin_delete policies, untouched by this migration.

drop policy if exists "department_members_lead_insert" on public.department_members;
create policy "department_members_lead_insert" on public.department_members
  for insert
  with check (public.is_dept_lead(department_code) and is_lead = false);

drop policy if exists "department_members_lead_delete" on public.department_members;
create policy "department_members_lead_delete" on public.department_members
  for delete
  using (public.is_dept_lead(department_code) and is_lead = false);

-- Self-test.
select 'policy department_members_lead_insert' as item, exists (select 1 from pg_policies where tablename = 'department_members' and policyname = 'department_members_lead_insert') as ok
union all select 'policy department_members_lead_delete', exists (select 1 from pg_policies where tablename = 'department_members' and policyname = 'department_members_lead_delete')
union all select 'admin policies on department_members untouched (3)', (select count(*) = 3 from pg_policies where tablename = 'department_members' and policyname like 'department_members_admin_%');
