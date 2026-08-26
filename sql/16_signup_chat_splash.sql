-- Extended signup profile, splash-screen announcements, and admin<->user chat/ticketing.
-- Run this once in the Supabase Dashboard -> SQL Editor (see README.md "Applying a schema
-- migration" for the walkthrough). Safe to re-run: every statement is idempotent.

-- ============================================================================
-- 1. user_profiles - extra signup fields, one row per auth user
-- ============================================================================

create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text not null default '',
  city text,
  membership_type text,
  phone text,
  created_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;

drop policy if exists "user_profiles_select_own" on public.user_profiles;
create policy "user_profiles_select_own" on public.user_profiles
  for select using (auth.uid() = user_id);

drop policy if exists "user_profiles_select_admin" on public.user_profiles;
create policy "user_profiles_select_admin" on public.user_profiles
  for select using (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'
  ));

drop policy if exists "user_profiles_insert_own" on public.user_profiles;
create policy "user_profiles_insert_own" on public.user_profiles
  for insert with check (auth.uid() = user_id);

-- ============================================================================
-- 2. Auto-provisioning trigger: new auth.users row -> user_roles + user_profiles.
--    Needed because email-confirmation signup has no authenticated session yet,
--    so a client-side insert under RLS is not possible at signup time. The extra
--    profile fields travel in signUp()'s options.data (-> raw_user_meta_data).
-- ============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_roles (user_id, email, role)
  select new.id, new.email, 'user'
  where not exists (select 1 from public.user_roles where user_id = new.id);

  insert into public.user_profiles (user_id, email, full_name, city, membership_type, phone)
  values (
    new.id, new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.raw_user_meta_data ->> 'city',
    new.raw_user_meta_data ->> 'membership_type',
    new.raw_user_meta_data ->> 'phone'
  )
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- 3. option_lists: allow anonymous (pre-login) read, needed so the signup form
--    can populate the "Focolare membership type" dropdown before authentication.
-- ============================================================================

drop policy if exists "option_lists_select_anon" on public.option_lists;
create policy "option_lists_select_anon" on public.option_lists
  for select to anon using (true);

insert into public.option_lists (list_name, code, label, sort_order)
select v.list_name, v.code, v.label, v.sort_order
from (values
  ('membership_type', 'FOCO', 'Focolarino/a', 1),
  ('membership_type', 'MARR', 'Married Focolare member', 2),
  ('membership_type', 'VOLU', 'Volunteer', 3),
  ('membership_type', 'GEN', 'Gen', 4),
  ('membership_type', 'FRND', 'Friend of the Focolare', 5),
  ('membership_type', 'SYMP', 'Sympathizer', 6),
  ('membership_type', 'OTHR', 'Other', 7)
) as v(list_name, code, label, sort_order)
where not exists (
  select 1 from public.option_lists ol where ol.list_name = 'membership_type' and ol.code = v.code
);

-- ============================================================================
-- 4. splash_messages - admin-published announcements, append-only history
-- ============================================================================

create table if not exists public.splash_messages (
  id bigint generated always as identity primary key,
  message_text text not null,
  created_by_email text not null,
  created_at timestamptz not null default now()
);

alter table public.splash_messages enable row level security;

drop policy if exists "splash_messages_select_authenticated" on public.splash_messages;
create policy "splash_messages_select_authenticated" on public.splash_messages
  for select to authenticated using (true);

drop policy if exists "splash_messages_insert_admin" on public.splash_messages;
create policy "splash_messages_insert_admin" on public.splash_messages
  for insert with check (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'
  ));

-- ============================================================================
-- 5. chat_messages - user-to-admin tickets/reports, with reply + soft dismiss
-- ============================================================================

create table if not exists public.chat_messages (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  user_email text not null,
  created_at timestamptz not null default now(),
  report_type text not null check (report_type in ('REVISION', 'DOWNLOAD_ERROR', 'BUG', 'SUGGESTION')),
  document_id integer references public.documents(document_id),
  message_text text not null,
  reply_text text,
  replied_at timestamptz,
  replied_by_email text,
  dismissed boolean not null default false
);

alter table public.chat_messages enable row level security;

drop policy if exists "chat_messages_select_own" on public.chat_messages;
create policy "chat_messages_select_own" on public.chat_messages
  for select using (auth.uid() = user_id);

drop policy if exists "chat_messages_select_admin" on public.chat_messages;
create policy "chat_messages_select_admin" on public.chat_messages
  for select using (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'
  ));

drop policy if exists "chat_messages_insert_own" on public.chat_messages;
create policy "chat_messages_insert_own" on public.chat_messages
  for insert with check (auth.uid() = user_id);

drop policy if exists "chat_messages_update_admin" on public.chat_messages;
create policy "chat_messages_update_admin" on public.chat_messages
  for update using (exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'
  ));
