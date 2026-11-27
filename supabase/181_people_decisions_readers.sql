-- 181: who reads the decisions about people (Owner's decision, 2026-11-25). Until now the lead of any department read all of them.
--   HR members and Admins: all. The person a decision is about, and whoever proposed it: theirs. The Formation lead, who may
--   decide on the boards: only the decisions about the boards.
-- Only a reading rule changes: who proposes and who decides is as before. Run in any order with 179 and 180. Safe to run again.

drop policy if exists "people_decisions_select" on public.people_decisions;
create policy "people_decisions_select" on public.people_decisions for select to authenticated
  using (
    subject_user_id = (select auth.uid())
    or proposed_by = (select auth.uid())
    or (select public.is_dept_member('HR'))
    or (select public.current_role_is('admin'))
    or (decision_type in ('board_misuse', 'board_block', 'board_unblock') and (select public.is_dept_lead('FORM')))
  );

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'One reading rule' as item,
       (select count(*) = 1 from pg_policies where schemaname = 'public' and tablename = 'people_decisions' and cmd in ('SELECT', 'ALL')) as ok
union all select 2, 'HR, Admins, the person, the proposer', (select qual ~ '''HR''' and qual ~ '''admin''' and qual ~ 'subject_user_id' and qual ~ 'proposed_by' from pg_policies where schemaname = 'public' and tablename = 'people_decisions' and cmd = 'SELECT')
union all select 3, 'Formation: the boards only', (select qual ~ '''FORM''' and qual ~ 'board_misuse' from pg_policies where schemaname = 'public' and tablename = 'people_decisions' and cmd = 'SELECT')
union all select 4, 'No longer the lead of any department', (select qual !~ 'is_any_dept_lead' from pg_policies where schemaname = 'public' and tablename = 'people_decisions' and cmd = 'SELECT')
union all select 5, 'The protection is on, and nobody writes directly',
       (select relrowsecurity from pg_class where oid = 'public.people_decisions'::regclass)
       and not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'people_decisions' and cmd <> 'SELECT')
order by 1;
