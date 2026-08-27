-- Lets any authenticated user resolve an admin's display name (for "Posted by <name>" on
-- the splash screen and the Announcements history table), without exposing regular users'
-- profiles to each other. Scoped only to rows belonging to an admin.
-- Run once in the Supabase Dashboard -> SQL Editor. Safe to re-run.

drop policy if exists "user_profiles_select_admins_public" on public.user_profiles;
create policy "user_profiles_select_admins_public" on public.user_profiles
  for select using (exists (
    select 1 from public.user_roles ur where ur.user_id = user_profiles.user_id and ur.role = 'admin'
  ));
