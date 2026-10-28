-- 107: names in a department's Team panel for members who cannot read other people's profiles.
--
-- Found 2026-10-28 (owner's screenshots): in My Department -> Team, an Operator saw "(no name)" for
-- the members and the lead's raw user id, while the Admin saw the real names. Cause: user_profiles
-- can be read only by the person themselves and by Coordinator+Admin (16_signup_chat_splash.sql,
-- 35_task_names.sql), and that table also holds private fields (email, demographics), so the policy
-- should not be widened. Instead this function returns ONLY the names of one department's members,
-- and only to someone who belongs to that department (or is Coordinator/Admin). Nothing else from
-- the profile (no email, no demographics) leaves the table.

create or replace function public.department_roster(p_dept text)
returns table (user_id uuid, full_name text, is_lead boolean)
language sql
stable
security definer
set search_path = public
as $$
  select dm.user_id, up.full_name, dm.is_lead
  from public.department_members dm
  left join public.user_profiles up on up.user_id = dm.user_id
  where dm.department_code = p_dept
    and (
      public.current_role_is('coordinator')
      or exists (
        select 1 from public.department_members me
        where me.department_code = p_dept and me.user_id = auth.uid()
      )
    )
  order by dm.is_lead desc, up.full_name;
$$;

revoke all on function public.department_roster(text) from public;
revoke all on function public.department_roster(text) from anon;
grant execute on function public.department_roster(text) to authenticated;

-- ============================================================================
-- Self-test (run separately). All rows must be true.
-- ============================================================================
select 'function department_roster exists' as item,
       (to_regprocedure('public.department_roster(text)') is not null) as ok
union all select 'is security definer',
       (select prosecdef from pg_proc where oid = to_regprocedure('public.department_roster(text)'))
union all select 'anon cannot execute',
       not has_function_privilege('anon', 'public.department_roster(text)', 'execute')
union all select 'authenticated can execute',
       has_function_privilege('authenticated', 'public.department_roster(text)', 'execute')
union all select 'user_profiles policies unchanged (own + coordinator-level select)',
       (select count(*) >= 2 from pg_policies where tablename = 'user_profiles' and cmd = 'SELECT');
