-- 54_profile_fields_and_web_designer_skill.sql
-- Adds the "Join the Team" answer fields to user_profiles (so they stay editable afterwards
-- from the new "My Profile" tab, js/profile.js), a self-update RLS policy for them, and the
-- "Web Designer" collaboration skill option.

alter table public.user_profiles
  add column if not exists academic_level text,
  add column if not exists availability text,
  add column if not exists experience text,
  add column if not exists skills text,
  add column if not exists motivation text,
  add column if not exists profile_updated_at timestamptz;

drop policy if exists "user_profiles_update_own" on public.user_profiles;
create policy "user_profiles_update_own" on public.user_profiles
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into option_lists (list_name, code, label, sort_order) values
  ('collaboration_skill', 'WEB_DESIGNER', 'Web Designer', 9)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;
