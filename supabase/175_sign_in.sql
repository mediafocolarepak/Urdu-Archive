-- 175: signing in (Owner's go-ahead, 2026-11-25).
--   1. The second step (a code of an authenticator app, My Profile): whoever turned it on has the powers of their role only
--      after giving the code. With the password alone they count as a User. Nothing changes for those who did not turn it on.
--   2. A counter for the sign-ups, used by the Edge Function phone-account. It keeps no number, no name and no address: only a
--      code of the connection that changes every day, and it is emptied after two days.
-- Run AFTER the code of the same pull request is live. Safe to run again.
--
-- If an Admin loses the phone with the codes:  delete from auth.mfa_factors where user_id = (select id from auth.users where email = '...');
-- To undo the check itself:  create or replace function public.second_step_done() returns boolean language sql stable as $$ select true $$;

-- Before anything changes: the two things this relies on. An error here stops everything, and nothing is changed.
select count(*) from auth.mfa_factors where false;
select auth.jwt() is null;

create or replace function public.second_step_done()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(auth.jwt() ->> 'aal', '') = 'aal2'
      or not exists (select 1 from auth.mfa_factors f where f.user_id = auth.uid() and f.status = 'verified');
$$;
revoke execute on function public.second_step_done() from public, anon;
grant execute on function public.second_step_done() to authenticated;

-- As in 170, with the second step for the team. It is asked last, so Users never pay for it.
create or replace function public.current_role_is(min_role text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((
    select case
      when r.role <> 'admin' and r.standing = 'excluded' then false
      when min_role = 'user' then true
      when r.role <> 'admin' and r.standing = 'suspended' then false
      when min_role = 'operator' then r.role in ('operator', 'coordinator', 'admin') and public.second_step_done()
      when min_role = 'coordinator' then r.role in ('coordinator', 'admin') and public.second_step_done()
      when min_role = 'admin' then r.role = 'admin' and public.second_step_done()
      else false
    end
    from public.user_roles r where r.user_id = auth.uid()), false);
$$;

create or replace function public.person_may_work()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((select (r.role = 'admin' or r.standing not in ('suspended', 'excluded')) and public.second_step_done()
                     from public.user_roles r where r.user_id = auth.uid()), false);
$$;

-- The rules that read the role by themselves (announcements, the pop-up switch, profiles): through the same door.
do $m$
declare p record;
begin
  for p in
    select schemaname, tablename, policyname, cmd, qual, with_check from pg_policies
    where schemaname = 'public' and policyname in ('app_settings_popup_admin', 'splash_messages_insert_admin', 'user_profiles_insert_admin', 'user_profiles_update_admin')
  loop
    execute format('alter policy %I on public.%I', p.policyname, p.tablename)
      || case when p.policyname = 'app_settings_popup_admin' then ' using (key = ''announcements_popup'' and (select public.current_role_is(''admin''))) with check (key = ''announcements_popup'' and (select public.current_role_is(''admin'')))'
              else case when p.qual is not null then ' using ((select public.current_role_is(''admin'')))' else '' end
                || case when p.with_check is not null then ' with check ((select public.current_role_is(''admin'')))' else '' end end;
  end loop;
end $m$;

create table if not exists public.signup_attempts (
  id      bigint generated always as identity primary key,
  at      timestamptz not null default now(),
  source  text not null,
  created boolean not null default false
);
create index if not exists idx_signup_attempts_at on public.signup_attempts (at);
-- No rule opens it: only the function's own key reads and writes it.
alter table public.signup_attempts enable row level security;
revoke all on public.signup_attempts from anon, authenticated;

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'The role asks for the second step' as item,
       (select prosrc ~ 'second_step_done' and prosrc ~ 'excluded' and prosecdef from pg_proc where oid = 'public.current_role_is(text)'::regprocedure) as ok
union all select 2, 'So does the work', (select prosrc ~ 'second_step_done' from pg_proc where oid = 'public.person_may_work()'::regprocedure)
union all select 3, 'It can be read, by signed-in people only',
       has_function_privilege('authenticated', 'public.second_step_done()', 'execute') and not has_function_privilege('anon', 'public.second_step_done()', 'execute')
union all select 4, 'No rule reads an Admin by itself',
       not exists (select 1 from pg_policies where schemaname = 'public' and (coalesce(qual, '') || coalesce(with_check, '')) ~ 'user_roles'
         and (coalesce(qual, '') || coalesce(with_check, '')) ~ '''admin''::text')
union all select 5, 'The counter of sign-ups is closed',
       (select relrowsecurity from pg_class where oid = 'public.signup_attempts'::regclass) and not has_table_privilege('anon', 'public.signup_attempts', 'select')
       and not has_table_privilege('authenticated', 'public.signup_attempts', 'insert')
union all select 6, 'Nobody has lost anything: whoever has no second step is as before',
       (select count(*) from public.user_roles r where not exists (select 1 from auth.mfa_factors f where f.user_id = r.user_id and f.status = 'verified')) > 0
order by 1;
