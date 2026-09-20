-- 94_department_messages.sql
-- Internal team communications (GOVERNANCE.md §2.7/§2.8, raised v26, scoped and built v33): one
-- message thread per department, visible only to that department's members and Admin - distinct
-- from Boards (71/84: public, moderated, open to every signed-in user) and from the admin<->user
-- chat (chat_messages: 1:1 ticketing). Any department member can post and reply; the department
-- lead (or Admin) can pin a message; the author can edit/delete their own message within 15
-- minutes of posting. Lives in "My Department" (mydepartment.js), not a new top-level tab.
--
-- Run after 93_formation_path_thumbnails.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. The messages. Same "pinned desc, created_at desc" ordering as board_posts (71_boards.sql),
--    same "needs text or an image" content rule.
-- ============================================================================
create table if not exists public.department_messages (
  id               bigint generated always as identity primary key,
  department_code  text        not null,
  body             text,
  image_path       text,
  user_id          uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  user_email       text,
  pinned           boolean     not null default false,
  pinned_by_email  text,
  pinned_at        timestamptz,
  created_at       timestamptz not null default now(),
  edited_at        timestamptz,
  constraint department_messages_has_content check (
    (body is not null and btrim(body) <> '') or image_path is not null
  )
);
create index if not exists idx_department_messages_order
  on public.department_messages (department_code, pinned desc, created_at desc);

alter table public.department_messages enable row level security;

-- Read/post: any member of the department, or Admin (consistent with Admin seeing every
-- department in My Department already - myDepartmentCodes() in mydepartment.js).
drop policy if exists "department_messages_select" on public.department_messages;
create policy "department_messages_select" on public.department_messages
  for select using (
    public.is_dept_member(department_code) or current_role_is('admin')
  );

drop policy if exists "department_messages_insert" on public.department_messages;
create policy "department_messages_insert" on public.department_messages
  for insert with check (
    user_id = auth.uid()
    and (public.is_dept_member(department_code) or current_role_is('admin'))
  );

-- Two different update paths share this table: the author editing their own recent message, and
-- the department lead pinning any message. RLS admits both; the trigger below (department_
-- message_update_guard) makes sure each path only ever touches its own columns, so an author
-- editing text can't sneak in a pin, and a lead pinning can't rewrite someone else's text.
drop policy if exists "department_messages_update" on public.department_messages;
create policy "department_messages_update" on public.department_messages
  for update using (
    (user_id = auth.uid() and now() - created_at < interval '15 minutes')
    or public.is_dept_lead(department_code)
    or current_role_is('admin')
  )
  with check (
    (user_id = auth.uid() and now() - created_at < interval '15 minutes')
    or public.is_dept_lead(department_code)
    or current_role_is('admin')
  );

-- Delete: author only, same 15-minute window as editing. No lead/admin override - if a message
-- needs removing after that window, that's a data-fix task for Admin directly, not a client
-- feature (keeps this append-only-by-default, same spirit as people_decisions/board posts).
drop policy if exists "department_messages_delete" on public.department_messages;
create policy "department_messages_delete" on public.department_messages
  for delete using (
    user_id = auth.uid() and now() - created_at < interval '15 minutes'
  );

-- ============================================================================
-- 2. The field-separation guard. See the update policy comment above for why this exists.
-- ============================================================================
create or replace function public.department_message_update_guard()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email        text;
  v_body_changed boolean;
  v_pin_changed  boolean;
begin
  if new.department_code is distinct from old.department_code
     or new.user_id is distinct from old.user_id
     or new.user_email is distinct from old.user_email
     or new.created_at is distinct from old.created_at then
    raise exception 'department_code, user_id, user_email and created_at cannot be changed.';
  end if;

  v_body_changed := (new.body is distinct from old.body) or (new.image_path is distinct from old.image_path);
  v_pin_changed  := (new.pinned is distinct from old.pinned);

  if v_body_changed and v_pin_changed then
    raise exception 'Edit the message and pin/unpin it in two separate actions.';
  end if;

  if v_body_changed then
    if old.user_id <> auth.uid() then
      raise exception 'Only the author can edit this message.';
    end if;
    if now() - old.created_at >= interval '15 minutes' then
      raise exception 'This message can no longer be edited (the 15-minute window has passed).';
    end if;
    new.edited_at       := now();
    new.pinned_by_email := old.pinned_by_email;
    new.pinned_at        := old.pinned_at;

  elsif v_pin_changed then
    if not (public.is_dept_lead(old.department_code) or current_role_is('admin')) then
      raise exception 'Only the department lead can pin a message.';
    end if;
    select email into v_email from public.user_roles where user_id = auth.uid();
    new.pinned_by_email := case when new.pinned then v_email else null end;
    new.pinned_at        := case when new.pinned then now() else null end;
    new.edited_at         := old.edited_at;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_department_message_update_guard on public.department_messages;
create trigger trg_department_message_update_guard
  before update on public.department_messages
  for each row execute function public.department_message_update_guard();

-- ============================================================================
-- 3. Storage bucket for message images - NOT public (see DEPARTMENT_MEDIA_BUCKET in core.js).
--    Objects are keyed "<department_code>/<filename>" so the department code can be read straight
--    off the storage path, the same trick used for per-tenant paths elsewhere.
-- ============================================================================
insert into storage.buckets (id, name, public, file_size_limit)
values ('department-media', 'department-media', false, 5242880)
on conflict (id) do nothing;

drop policy if exists "read - department-media" on storage.objects;
drop policy if exists "upload - department-media" on storage.objects;
drop policy if exists "delete - department-media" on storage.objects;

create policy "read - department-media" on storage.objects for select
  to authenticated using (
    bucket_id = 'department-media'
    and (public.is_dept_member(split_part(name, '/', 1)) or current_role_is('admin'))
  );
create policy "upload - department-media" on storage.objects for insert
  to authenticated with check (
    bucket_id = 'department-media'
    and (public.is_dept_member(split_part(name, '/', 1)) or current_role_is('admin'))
  );
create policy "delete - department-media" on storage.objects for delete
  to authenticated using (
    bucket_id = 'department-media'
    and (public.is_dept_lead(split_part(name, '/', 1)) or current_role_is('admin'))
  );

-- ============================================================================
-- 4. Self-test (run separately). All rows must be true.
-- ============================================================================
select 'table department_messages' as item, (to_regclass('public.department_messages') is not null) as ok
union all select 'index idx_department_messages_order', exists (select 1 from pg_indexes where indexname = 'idx_department_messages_order')
union all select 'policies department_messages (4)', (select count(*) = 4 from pg_policies where tablename = 'department_messages')
union all select 'trigger department_message_update_guard', exists (select 1 from pg_trigger where tgname = 'trg_department_message_update_guard')
union all select 'fn department_message_update_guard', to_regproc('public.department_message_update_guard') is not null
union all select 'storage bucket department-media (private)', exists (select 1 from storage.buckets where id = 'department-media' and public = false)
union all select 'storage policies department-media (3)', (select count(*) = 3 from pg_policies where tablename = 'objects' and policyname like '%department-media%');
