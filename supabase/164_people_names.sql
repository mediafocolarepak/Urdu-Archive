-- 164: people are known by name, not by login.
--
-- Until now every signed-in person could read the whole list of accounts: login (for phone accounts, the mobile
-- number), role, credits, reputation and standing; and the whole profile of the Admins. From now on:
--   * each person reads their own role; Coordinators and Admins read everyone's, as their screens need;
--   * a profile is read by its owner, by Coordinators and by Admins;
--   * the screens ask people_names() for names. It gives a NAME only, and only of people the caller meets in the app.
--
-- Run it AFTER the app version that uses people_names() is live (that version also works without it).
-- Nothing is deleted. Safe to run again. Run in the Supabase Dashboard -> SQL Editor: every row must say true.
--
-- To undo:
--   drop policy "read roles" on public.user_roles;
--   create policy "read roles" on public.user_roles for select to authenticated using (true);
--   (and run sql/18_public_admin_profile_names.sql again)

-- 1. Names, and only names. The login comes back only for a login the caller already had.
--    By user_roles.email, which people cannot change, and not by user_profiles.email, which they can.
create or replace function public.people_names(p_ids uuid[] default null, p_emails text[] default null)
returns table (user_id uuid, email text, full_name text)
language sql
stable
security definer
set search_path = public
as $$
  with me as (
    select auth.uid() as uid,
           public.current_role_is('user') as signed_in,
           public.current_role_is('operator') as team,
           public.current_role_is('coordinator') as sees_all,
           public.is_dept_member('HR') as hr,
           public.is_any_dept_lead() as lead
  ),
  asked as (
    select r.user_id, r.role, case when r.email = any (p_emails) then r.email end as email
    from public.user_roles r
    where (r.user_id = any (p_ids) or r.email = any (p_emails))
      and coalesce(cardinality(p_ids), 0) + coalesce(cardinality(p_emails), 0) <= 1000
  )
  select a.user_id, a.email, btrim(p.full_name)
  from asked a
  cross join me
  join public.user_profiles p on p.user_id = a.user_id
  where me.signed_in
    and btrim(coalesce(p.full_name, '')) <> ''
    and (
      me.sees_all
      or a.user_id = me.uid
      -- those who answer for the archive
      or a.role in ('coordinator', 'admin')
      or exists (select 1 from public.department_members l where l.user_id = a.user_id and l.is_lead)
      -- the team among themselves, and members of the same department
      or (me.team and a.role <> 'user')
      or exists (select 1 from public.department_members x
                 join public.department_members y on y.department_code = x.department_code
                 where x.user_id = me.uid and y.user_id = a.user_id)
      -- who signs something the caller reads: a published post, a path, a message in a path's chat
      or exists (select 1 from public.board_posts b where b.posted_by = a.user_id
                 and (b.status = 'published' or public.is_board_editor(b.board_code)))
      or exists (select 1 from public.formation_paths f where f.owner_id = a.user_id)
      or exists (select 1 from public.formation_path_editors e where e.user_id = a.user_id)
      or exists (select 1 from public.formation_chat_messages c where c.user_id = a.user_id and c.channel = 'students'
                 and (public.formation_is_enrolled(c.path_id) or public.can_edit_path(c.path_id)))
      -- whoever wrote to the people who read it: applications for HR, shares for the leads
      or (me.hr and exists (select 1 from public.collaboration_applications k where k.user_id = a.user_id))
      or (me.lead and exists (select 1 from public.share_with_us_messages s where s.user_id = a.user_id))
    );
$$;
revoke all on function public.people_names(uuid[], text[]) from public, anon;
grant execute on function public.people_names(uuid[], text[]) to authenticated;

-- 2. Roles: one's own; everyone's for Coordinators and Admins.
drop policy if exists "read roles" on public.user_roles;
create policy "read roles" on public.user_roles for select to authenticated
  using (user_id = (select auth.uid()) or (select public.current_role_is('coordinator')));

-- Changing a role stays with the Admins. The old rule looked into this same table, which a rule may not do once reading
-- it is restricted (Postgres: infinite recursion); current_role_is() asks the same thing without that.
drop policy if exists "admins update roles" on public.user_roles;
create policy "admins update roles" on public.user_roles for update to authenticated
  using ((select public.current_role_is('admin')))
  with check ((select public.current_role_is('admin')));

-- 3. The Admins' whole profile (phone, city, gender) is no longer open to everyone: people_names() gives their name.
drop policy if exists "user_profiles_select_admins_public" on public.user_profiles;

-- 4. Verification: every row must say true.
select 'people_names: for signed-in people only' as item,
       has_function_privilege('authenticated', 'public.people_names(uuid[], text[])', 'execute')
       and not has_function_privilege('anon', 'public.people_names(uuid[], text[])', 'execute') as ok
union all
select 'people_names: owner''s rights, fixed search_path',
       (select prosecdef and coalesce(proconfig, '{}') @> array['search_path=public']
        from pg_proc where oid = to_regprocedure('public.people_names(uuid[], text[])'))
union all
select 'roles: one rule for reading, and not for everybody',
       (select count(*) = 1 and bool_and(qual like '%auth.uid()%' and qual like '%coordinator%')
        from pg_policies where schemaname = 'public' and tablename = 'user_roles' and cmd in ('SELECT', 'ALL'))
union all
select 'roles: only Admins change them, with no rule reading its own table',
       (select count(*) = 1 and bool_and(qual like '%current_role_is%admin%' and with_check like '%current_role_is%admin%' and qual not like '%user_roles%')
        from pg_policies where schemaname = 'public' and tablename = 'user_roles' and cmd in ('UPDATE', 'ALL'))
union all
select 'roles: no rule is always true',
       not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'user_roles' and qual = 'true')
union all
select 'profiles: the Admins'' profiles are no longer public',
       not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'user_profiles'
                   and policyname = 'user_profiles_select_admins_public')
union all
select 'profiles: the owner and the Coordinators still read them',
       (select count(*) = 2 from pg_policies where schemaname = 'public' and tablename = 'user_profiles'
        and cmd = 'SELECT' and policyname in ('user_profiles_select_own', 'user_profiles_select_reviewers'))
union all
select 'both tables are protected',
       (select bool_and(relrowsecurity) from pg_class where oid in ('public.user_roles'::regclass, 'public.user_profiles'::regclass));
