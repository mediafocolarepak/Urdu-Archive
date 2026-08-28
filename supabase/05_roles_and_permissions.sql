-- Three-tier access control: User (read-only), Operator (write, no delete),
-- Admin (delete + manage roles). Run after 03_alter_schema_english.sql / 04_migrate_english_schema.sql.
-- No begin/commit wrapper (same reason as before).

-- 1. Role table, one row per signed-up team member.
create table if not exists user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'user' check (role in ('user', 'operator', 'admin')),
  created_at timestamptz not null default now()
);
alter table user_roles enable row level security;

drop policy if exists "read roles" on user_roles;
create policy "read roles" on user_roles for select to authenticated using (true);

drop policy if exists "admins update roles" on user_roles;
create policy "admins update roles" on user_roles for update to authenticated
  using (exists (select 1 from user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'))
  with check (exists (select 1 from user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'));

-- 2. Auto-provision a 'user' row for every new sign-up (SECURITY DEFINER bypasses RLS for the
-- insert, since a brand-new account has no role yet to satisfy any policy). This touches the
-- same auth.users insert path that failed earlier in the project ("Database error saving new
-- user") - test signing up a fresh test account after running this script. If it breaks again,
-- roll back with: drop trigger on_auth_user_created on auth.users; drop function public.handle_new_user();
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_roles (user_id, email, role) values (new.id, new.email, 'user')
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill a role row for any account that signed up before this script existed.
insert into user_roles (user_id, email, role)
  select id, email, 'user' from auth.users
  on conflict (user_id) do nothing;

-- 3. Role-check helper, used by every policy below.
create or replace function public.current_role_is(min_role text)
returns boolean
language sql
security definer
stable
as $$
  select case
    when min_role = 'user' then exists (select 1 from user_roles where user_id = auth.uid())
    when min_role = 'operator' then exists (select 1 from user_roles where user_id = auth.uid() and role in ('operator', 'admin'))
    when min_role = 'admin' then exists (select 1 from user_roles where user_id = auth.uid() and role = 'admin')
    else false
  end;
$$;

-- 4. Soft-delete flag: operators can mark a document for deletion instead of removing it.
alter table documents add column if not exists pending_deletion boolean not null default false;
alter table documents add column if not exists pending_deletion_note text;

-- 5. Replace the old blanket "any authenticated user" policy on documents with role tiers.
drop policy if exists "team read/write - documents" on documents;
create policy "read - documents" on documents for select to authenticated using (current_role_is('user'));
create policy "insert - documents" on documents for insert to authenticated with check (current_role_is('operator'));
create policy "update - documents" on documents for update to authenticated using (current_role_is('operator')) with check (current_role_is('operator'));
create policy "delete - documents" on documents for delete to authenticated using (current_role_is('admin'));

-- hayat_indice: everyone reads, operator+ can extract/update (marks "estratto"), no delete needed.
drop policy if exists "team read/write - hayat_indice" on hayat_indice;
create policy "read - hayat_indice" on hayat_indice for select to authenticated using (current_role_is('user'));
create policy "update - hayat_indice" on hayat_indice for update to authenticated using (current_role_is('operator')) with check (current_role_is('operator'));

-- 6. Storage: users read, operators upload/replace, admins delete.
drop policy if exists "team read - archive-files" on storage.objects;
drop policy if exists "team upload - archive-files" on storage.objects;
drop policy if exists "team update - archive-files" on storage.objects;
drop policy if exists "team delete - archive-files" on storage.objects;

create policy "read - archive-files" on storage.objects for select
  to authenticated using (bucket_id = 'archive-files' and current_role_is('user'));
create policy "upload - archive-files" on storage.objects for insert
  to authenticated with check (bucket_id = 'archive-files' and current_role_is('operator'));
create policy "update - archive-files" on storage.objects for update
  to authenticated using (bucket_id = 'archive-files' and current_role_is('operator'));
create policy "delete - archive-files" on storage.objects for delete
  to authenticated using (bucket_id = 'archive-files' and current_role_is('admin'));

select 'roles installed. Now run: update user_roles set role = ''admin'' where email = ''YOUR-EMAIL-HERE'';' as result;
