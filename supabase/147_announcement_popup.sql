-- 147: announcements open by themselves only when they are new (Owner's request, 2026-11-18).
-- Until now the latest announcement opened at every session. Now:
--   1. app_settings: settings of the whole app. 'announcements_popup' (true/false) is the switch on the Admin's
--      Announcements page: when false, no announcement opens by itself. Everyone signed in can read the settings;
--      only Admins can change them.
--   2. splash_seen: the last announcement each person closed with "Got it". An announcement the person has closed does
--      not open again, on any device. Only the person reads or writes their own row.
-- The app works before this runs too: with no switch it treats it as on, and it remembers closed announcements on the
-- device only. Run this BEFORE merging the PR. Safe to run again.

create table if not exists public.app_settings (
  key        text        primary key,
  value      jsonb       not null,
  updated_at timestamptz not null default now(),
  updated_by uuid        default auth.uid() references auth.users(id) on delete set null
);
alter table public.app_settings enable row level security;

drop policy if exists "app_settings_read" on public.app_settings;
create policy "app_settings_read" on public.app_settings
  for select to authenticated using (true);

drop policy if exists "app_settings_admin_write" on public.app_settings;
create policy "app_settings_admin_write" on public.app_settings
  for all to authenticated
  using (exists (select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'))
  with check (exists (select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'));

grant select, insert, update on public.app_settings to authenticated;
revoke all on public.app_settings from anon;

insert into public.app_settings (key, value) values ('announcements_popup', 'true'::jsonb)
  on conflict (key) do nothing;

create table if not exists public.splash_seen (
  user_id   uuid        primary key default auth.uid() references auth.users(id) on delete cascade,
  splash_id bigint      not null,
  seen_at   timestamptz not null default now()
);
alter table public.splash_seen enable row level security;

drop policy if exists "splash_seen_own" on public.splash_seen;
create policy "splash_seen_own" on public.splash_seen
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select, insert, update on public.splash_seen to authenticated;
revoke all on public.splash_seen from anon;

notify pgrst, 'reload schema';

-- Should all say true.
select 1 as ord, 'Settings table, row security on' as item,
       coalesce((select relrowsecurity from pg_class where oid = to_regclass('public.app_settings')), false) as ok
union all select 2, 'Pop-up switch present',
       exists (select 1 from public.app_settings where key = 'announcements_popup')
union all select 3, 'Settings: everyone reads, Admins write',
       (select count(*) = 2 from pg_policies where schemaname = 'public' and tablename = 'app_settings')
union all select 4, 'Closed announcements table, row security on',
       coalesce((select relrowsecurity from pg_class where oid = to_regclass('public.splash_seen')), false)
union all select 5, 'Closed announcements: own row only',
       (select count(*) = 1 from pg_policies where schemaname = 'public' and tablename = 'splash_seen')
order by ord;
