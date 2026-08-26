-- Enables Supabase Realtime on chat_messages so admins get a live "New Messages" toast
-- while online (INSERT events), and users get a live "New reply" toast (UPDATE events).
-- Run once in the Supabase Dashboard -> SQL Editor. Safe to re-run.

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'chat_messages'
  ) then
    alter publication supabase_realtime add table public.chat_messages;
  end if;
end $$;

-- Ships full old-row values on UPDATE/DELETE realtime events (default only ships the
-- primary key), so the client can tell exactly which columns changed.
alter table public.chat_messages replica identity full;

-- Lets admins edit a user's profile fields (full name/city/membership/phone) from the
-- Users tab. No such policy existed before (only select-own/select-admin/insert-own).
-- Both insert and update are needed: accounts created before this feature existed have
-- no user_profiles row yet, so the Edit modal's upsert() does an INSERT for those.
drop policy if exists "user_profiles_update_admin" on public.user_profiles;
create policy "user_profiles_update_admin" on public.user_profiles
  for update using (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'
  ));

drop policy if exists "user_profiles_insert_admin" on public.user_profiles;
create policy "user_profiles_insert_admin" on public.user_profiles
  for insert with check (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'
  ));
