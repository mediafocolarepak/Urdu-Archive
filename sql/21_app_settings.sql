-- Generic shared key/value settings table. First use: storing the Gemini prompt used to
-- extract a Hayat edition's CSV from its scanned PDF, editable from the Hayat Editor tab so
-- whoever runs that extraction always finds it ready to copy (rather than living only in one
-- person's own notes). Reusable for any future single-shared-value setting.
-- Run once in the Supabase Dashboard -> SQL Editor. Safe to re-run.

create table if not exists public.app_settings (
  key text primary key,
  value text,
  updated_at timestamptz not null default now(),
  updated_by_email text
);

alter table public.app_settings enable row level security;

-- Readable/writable by operators and admins only (the same roles that can use the Hayat
-- Editor's write actions) - plain "user" accounts have no reason to see or change this.
drop policy if exists "app_settings_select_write_roles" on public.app_settings;
create policy "app_settings_select_write_roles" on public.app_settings
  for select using (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role in ('operator', 'admin')
  ));

drop policy if exists "app_settings_insert_write_roles" on public.app_settings;
create policy "app_settings_insert_write_roles" on public.app_settings
  for insert with check (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role in ('operator', 'admin')
  ));

drop policy if exists "app_settings_update_write_roles" on public.app_settings;
create policy "app_settings_update_write_roles" on public.app_settings
  for update using (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role in ('operator', 'admin')
  ));
