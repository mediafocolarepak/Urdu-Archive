-- Lets an admin remove a user_roles row from the Users tab ("Remove access").
-- This does NOT delete the person's login/auth account - it only drops their role
-- record, so the app falls back to treating them as base "User" on next load.
-- Full account deletion still requires the Supabase Dashboard (Authentication > Users).
drop policy if exists "admins delete roles" on user_roles;
create policy "admins delete roles" on user_roles for delete to authenticated
  using (current_role_is('admin'));

select 'role removal policy ready' as result;
