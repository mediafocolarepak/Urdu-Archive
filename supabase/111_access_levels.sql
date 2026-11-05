-- 111_access_levels.sql
-- Fase 2 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md (Owner's decisions of 2026-11-05).
-- Every document version has one of three levels:
--   public    may also exist outside the archive (a YouTube link, for example)
--   private   any registered user: the default, and the level of every existing document
--   reserved  only Admin, Formation members and users they have enabled
-- For anyone else a reserved document does not exist: not in lists, search, tasks, boards or history.
-- Only Admin and Formation members can give or take away the reserved level, or enable a person.
--
-- The limit, by the Owner's decision (GOVERNANCE.md §5.13): PDFs and .inp files stay in the current
-- Drive folder, open to anyone with the link. Levels govern what the app shows; they do not make a
-- file on Drive secret. Records, texts and files in Supabase Storage ARE protected.
--
-- The rules here are RESTRICTIVE policies: they add to every rule already on a table and cannot be
-- widened by one. Also closes a gap left by 110: the text of a draft or of a deleted document can no
-- longer be read through the API.
--
-- Run after 110. Safe to re-run. No document changes level, and nobody loses access to anything that
-- is visible today, except texts of hidden drafts and of deleted documents.

-- ============================================================================
-- 1. The level, and who is enabled
-- ============================================================================
alter table public.documents add column if not exists access_level text not null default 'private';
alter table public.documents drop constraint if exists documents_access_level_check;
alter table public.documents add constraint documents_access_level_check
  check (access_level in ('public', 'private', 'reserved'));
create index if not exists idx_documents_reserved on public.documents (document_id) where access_level = 'reserved';

-- Not in user_roles: that table is readable by everyone (05), and who is enabled is nobody's business.
create table if not exists public.reserved_access (
  user_id          uuid primary key references auth.users(id) on delete cascade,
  granted_by_email text,
  granted_at       timestamptz not null default now(),
  revoked_by_email text,
  revoked_at       timestamptz,
  reason           text
);
alter table public.reserved_access enable row level security;
drop policy if exists "reserved_access_own" on public.reserved_access;
create policy "reserved_access_own" on public.reserved_access for select to authenticated
  using (user_id = auth.uid());
-- No write rules: set_reserved_access() below is the only way in.

drop trigger if exists reserved_access_log_change on public.reserved_access;
create trigger reserved_access_log_change
  after insert or update or delete on public.reserved_access
  for each row execute function public.log_archive_change('user_id');

-- ============================================================================
-- 2. The checks every rule uses
-- ============================================================================
create or replace function public.can_manage_reserved()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('admin') or public.is_dept_member('FORM');
$$;

create or replace function public.has_reserved_access()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.can_manage_reserved()
      or exists (select 1 from public.reserved_access a where a.user_id = auth.uid() and a.revoked_at is null);
$$;

-- These bypass row-level security on purpose: the rule on tasks cannot query documents directly,
-- because the rule on documents already queries tasks, and Postgres would refuse the loop.
create or replace function public.document_reserved_ok(p_document_id integer)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select p_document_id is null
      or public.has_reserved_access()
      or not exists (select 1 from public.documents d where d.document_id = p_document_id and d.access_level = 'reserved');
$$;

-- A Work is hidden only when every document in it is reserved: its title may be the document's.
-- A Work with no documents yet stays visible, so creating a document can read back its new Work.
create or replace function public.work_reserved_ok(p_work_id bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.has_reserved_access()
      or not exists (select 1 from public.documents d where d.work_id = p_work_id)
      or exists (select 1 from public.documents d where d.work_id = p_work_id and d.access_level <> 'reserved');
$$;

create or replace function public.storage_file_ok(p_name text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.has_reserved_access()
      or not exists (select 1 from public.documents d
                      where d.access_level = 'reserved'
                        and (d.storage_path = p_name or d.draft_inp_path = p_name));
$$;

-- ============================================================================
-- 3. The rules
-- ============================================================================
drop policy if exists "reserved_guard" on public.documents;
create policy "reserved_guard" on public.documents as restrictive for all to authenticated
  using (access_level <> 'reserved' or public.has_reserved_access())
  with check (access_level <> 'reserved' or public.has_reserved_access());

-- Reading these follows the document: not visible to you, not readable. This uses the rules on
-- documents themselves, so it also covers hidden drafts and deleted documents. Writing stays as it
-- was, except on reserved documents: whoever promotes a board post must still be able to save the
-- text of a draft they cannot see.
do $$
declare
  t text;
begin
  foreach t in array array['document_texts', 'document_original_texts', 'process_history', 'document_collections'] loop
    execute format('drop policy if exists "visible_document_guard" on public.%I', t);
    execute format(
      'create policy "visible_document_guard" on public.%I as restrictive for select to authenticated using (exists (select 1 from public.documents d where d.document_id = %I.document_id))',
      t, t);
    execute format('drop policy if exists "reserved_guard_insert" on public.%I', t);
    execute format(
      'create policy "reserved_guard_insert" on public.%I as restrictive for insert to authenticated with check (public.document_reserved_ok(document_id))', t);
    execute format('drop policy if exists "reserved_guard_update" on public.%I', t);
    execute format(
      'create policy "reserved_guard_update" on public.%I as restrictive for update to authenticated using (public.document_reserved_ok(document_id)) with check (public.document_reserved_ok(document_id))', t);
    execute format('drop policy if exists "reserved_guard_delete" on public.%I', t);
    execute format(
      'create policy "reserved_guard_delete" on public.%I as restrictive for delete to authenticated using (public.document_reserved_ok(document_id))', t);
  end loop;

  -- A task, a favourite or a post about a reserved document goes with it.
  foreach t in array array['tasks', 'user_favorites', 'board_posts', 'formation_posts'] loop
    execute format('drop policy if exists "reserved_guard" on public.%I', t);
    execute format(
      'create policy "reserved_guard" on public.%I as restrictive for all to authenticated using (public.document_reserved_ok(document_id)) with check (public.document_reserved_ok(document_id))', t);
  end loop;
end;
$$;

drop policy if exists "reserved_guard" on public.works;
create policy "reserved_guard" on public.works as restrictive for all to authenticated
  using (public.work_reserved_ok(work_id))
  with check (public.work_reserved_ok(work_id));

-- Files in Supabase Storage: final PDFs and task drafts of reserved documents.
drop policy if exists "reserved_guard_archive_files" on storage.objects;
create policy "reserved_guard_archive_files" on storage.objects as restrictive for select to authenticated
  using (bucket_id <> 'archive-files' or public.storage_file_ok(name));

-- ============================================================================
-- 4. Who can give or take away the level
-- ============================================================================
-- Builds on 110's guard. A correction made through a task inherits the level of the document it
-- corrects, whatever the browser sends: an enabled Operator working on a reserved document needs no
-- special right, and a draft of a reserved document can never come out less protected.
create or replace function public.guard_document_visibility()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task_level text;
begin
  if tg_op = 'INSERT' and new.source_task_id is not null then
    select d.access_level into v_task_level
    from public.tasks t join public.documents d on d.document_id = t.document_id
    where t.id = new.source_task_id;
    if v_task_level is not null then
      new.access_level := v_task_level;
    end if;
  end if;

  if auth.uid() is null or public.current_role_is('admin') then
    return new;
  end if;

  if tg_op = 'INSERT' then
    if new.workflow_status is distinct from 'revision' then
      raise exception 'Only Admin can add a visible document. Everyone else adds a draft for review.';
    end if;
    if new.deleted_at is not null then
      raise exception 'Only Admin can delete a document.';
    end if;
    if new.access_level = 'reserved' and v_task_level is distinct from 'reserved' and not public.can_manage_reserved() then
      raise exception 'Only Admin and Formation can add a reserved document.';
    end if;
    return new;
  end if;

  if public.document_status_is_visible(new.workflow_status) <> public.document_status_is_visible(old.workflow_status) then
    raise exception 'Only Admin can publish or withdraw a document.';
  end if;
  if new.deleted_at is distinct from old.deleted_at then
    raise exception 'Only Admin can delete or restore a document.';
  end if;
  if new.access_level is distinct from old.access_level
     and 'reserved' in (new.access_level, old.access_level)
     and not public.can_manage_reserved() then
    raise exception 'Only Admin and Formation can change whether a document is reserved.';
  end if;
  return new;
end;
$$;

-- p_enabled true: enable, false: take away. Everything is kept in the archive log.
create or replace function public.set_reserved_access(p_user_id uuid, p_enabled boolean, p_reason text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
begin
  if not public.can_manage_reserved() then
    raise exception 'Only Admin and Formation can enable access to reserved documents.';
  end if;
  if not exists (select 1 from public.user_roles where user_id = p_user_id) then
    raise exception 'User not found.';
  end if;
  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_enabled then
    insert into public.reserved_access (user_id, granted_by_email, granted_at, reason)
    values (p_user_id, v_email, now(), nullif(btrim(p_reason), ''))
    on conflict (user_id) do update
      set granted_by_email = excluded.granted_by_email, granted_at = excluded.granted_at,
          revoked_by_email = null, revoked_at = null, reason = excluded.reason;
  else
    update public.reserved_access
    set revoked_by_email = v_email, revoked_at = now(), reason = nullif(btrim(p_reason), '')
    where user_id = p_user_id and revoked_at is null;
  end if;
end;
$$;

-- No search text: everyone currently enabled. With search text: anyone matching, to enable them.
create or replace function public.list_reserved_access(p_query text default null)
returns table (user_id uuid, full_name text, email text, role text, enabled boolean, automatic boolean,
               granted_by_email text, granted_at timestamptz)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_like text := '%' || replace(replace(replace(btrim(coalesce(p_query, '')), '\', '\\'), '%', '\%'), '_', '\_') || '%';
  v_all  boolean := btrim(coalesce(p_query, '')) = '';
begin
  if not public.can_manage_reserved() then
    raise exception 'Only Admin and Formation can see who is enabled.';
  end if;
  return query
    with people as (
      select r.user_id, p.full_name, r.email, r.role,
             a.revoked_at is null and a.user_id is not null as has_grant,
             (r.role = 'admin' or exists (select 1 from public.department_members m where m.department_code = 'FORM' and m.user_id = r.user_id)) as is_auto,
             a.granted_by_email, a.granted_at
      from public.user_roles r
      left join public.user_profiles p on p.user_id = r.user_id
      left join public.reserved_access a on a.user_id = r.user_id
    )
    select x.user_id, x.full_name, x.email, x.role, (x.has_grant or x.is_auto), x.is_auto,
           case when x.has_grant then x.granted_by_email end, case when x.has_grant then x.granted_at end
    from people x
    where (v_all and (x.has_grant or x.is_auto))
       or (not v_all and (x.email ilike v_like or x.full_name ilike v_like))
    order by x.is_auto, x.full_name, x.email
    limit 100;
end;
$$;

-- ============================================================================
-- 5. Functions that bypass the rules must apply them too
-- ============================================================================
drop function if exists public.get_review_document(integer);
create function public.get_review_document(p_document_id integer)
returns table (
  document_id integer, title text, original_title text, ur_title text,
  draft_inp_path text, category text, language text, notes text
)
language sql
security definer
stable
set search_path = public
as $$
  select d.document_id, d.title, d.original_title, d.ur_title, d.draft_inp_path, d.category, d.language, d.notes
  from public.documents d
  where d.document_id = p_document_id
    and d.workflow_status = 'revision'
    and public.document_reserved_ok(d.document_id)
    and (
      public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
    );
$$;

drop function if exists public.get_review_queue();
create function public.get_review_queue()
returns table (
  id bigint, title text, description text, category text,
  document_id integer, document_pages integer, credits integer, submitted_at timestamptz,
  candidate_document_id integer
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id, t.title, t.description, t.category, t.document_id, t.document_pages, t.credits, t.submitted_at,
    (select d.document_id from public.documents d where d.source_task_id = t.id limit 1) as candidate_document_id
  from public.tasks t
  where t.status = 'submitted'
    and public.document_reserved_ok(t.document_id)
    and (t.claimed_by <> auth.uid() or public.current_role_is('admin'))
    and (
      public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
    )
  order by t.submitted_at;
$$;

create or replace function public.get_next_reread_document()
returns table (
  document_id integer, title text, en_title text, category text,
  pages integer, body text
)
language sql
security definer
stable
set search_path = public
as $$
  select d.document_id, d.title, d.en_title, d.category, d.pages, dt.body
  from public.document_texts dt
  join public.documents d on d.document_id = dt.document_id
  where dt.reviewed = false
    and d.deleted_at is null
    and public.document_reserved_ok(d.document_id)
    and (
      public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq
                  where uq.user_id = auth.uid() and uq.qualification_code = 'PROOF_READER')
    )
  order by dt.document_id
  limit 1;
$$;

-- A reserved document cannot be posted to a board or a formation path.
create or replace function public.document_is_postable(doc integer)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.documents d
                  where d.document_id = doc
                    and d.language = 'URD'
                    and d.access_level <> 'reserved'
                    and d.deleted_at is null
                    and (d.workflow_status is null
                         or d.workflow_status in ('APPR', 'STOR', 'published')));
$$;

-- Task lists for Coordination and Reward: same columns as 90 and 91, without titles of reserved work.
drop function if exists public.coordination_task_overview();
create function public.coordination_task_overview()
returns table (
  id                       bigint,
  title                    text,
  category                 text,
  status                   text,
  claimed_by               uuid,
  due_date                 date,
  created_at               timestamptz,
  base_credits             integer,
  extra_credits            integer,
  extra_credits_note       text,
  extra_credits_status     text,
  created_by_email         text
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id,
         case when public.document_reserved_ok(t.document_id) then t.title else '(reserved)' end,
         t.category, t.status, t.claimed_by, t.due_date, t.created_at,
         t.base_credits, t.extra_credits,
         case when public.document_reserved_ok(t.document_id) then t.extra_credits_note end,
         t.extra_credits_status, t.created_by_email
  from public.tasks t
  where (t.status in ('open', 'claimed', 'submitted', 'approved') or t.extra_credits_status = 'pending')
    and (public.is_dept_member('COORD') or public.current_role_is('coordinator') or public.current_role_is('admin'));
$$;

drop function if exists public.reward_extra_credit_tasks();
create function public.reward_extra_credit_tasks()
returns table (
  id                               bigint,
  title                            text,
  category                         text,
  status                           text,
  base_credits                     integer,
  extra_credits                    integer,
  extra_credits_note               text,
  extra_credits_status             text,
  created_by_email                 text,
  extra_credits_approved_by_email  text
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id,
         case when public.document_reserved_ok(t.document_id) then t.title else '(reserved)' end,
         t.category, t.status, t.base_credits, t.extra_credits,
         case when public.document_reserved_ok(t.document_id) then t.extra_credits_note end,
         t.extra_credits_status, t.created_by_email, t.extra_credits_approved_by_email
  from public.tasks t
  where t.extra_credits <> 0
    and (public.is_dept_member('RF') or public.current_role_is('admin'))
  order by t.extra_credits desc;
$$;

-- The log.
create or replace function public.get_document_history(p_document_id integer)
returns table (at timestamptz, actor text, actor_role text, table_name text, action text, changes jsonb)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not public.current_role_is('coordinator') then
    raise exception 'Only Coordinators and Admin can see a document''s history.';
  end if;
  if not public.document_reserved_ok(p_document_id) then
    return;
  end if;
  return query
    select l.at, coalesce(nullif(p.full_name, ''), l.actor_email, '(system)'), l.actor_role, l.table_name, l.action,
           public.archive_log_summary(l.changes)
    from public.archive_log l
    left join public.user_profiles p on p.user_id = l.actor_id
    where l.document_id = p_document_id
    order by l.at desc, l.id desc;
end;
$$;

create or replace function public.get_person_activity(p_user_id uuid, p_limit integer default 200)
returns table (at timestamptz, table_name text, row_key text, document_id integer, action text, changes jsonb)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not (p_user_id = auth.uid() or public.current_role_is('admin') or public.is_dept_lead('HR')) then
    raise exception 'A person''s activity is visible only to them, to Admin and to the HR lead.';
  end if;
  return query
    select l.at, l.table_name, l.row_key, l.document_id, l.action, public.archive_log_summary(l.changes)
    from public.archive_log l
    where l.actor_id = p_user_id
      and (p_user_id = auth.uid() or public.document_reserved_ok(l.document_id))
    order by l.at desc, l.id desc
    limit greatest(1, least(coalesce(p_limit, 200), 1000));
end;
$$;

-- ============================================================================
-- 6. Verification: every row must say true.
-- ============================================================================
select 'every document has a level, and none is reserved yet' as item,
  not exists (select 1 from public.documents where access_level is distinct from 'private') as ok
union all select 'nobody is enabled yet',
  not exists (select 1 from public.reserved_access)
union all select 'rules on documents, works and task-related tables',
  (select count(*) = 6 from pg_policies where policyname = 'reserved_guard' and schemaname = 'public')
union all select 'texts, originals, process steps and collections follow the document',
  (select count(*) = 4 from pg_policies where policyname = 'visible_document_guard' and schemaname = 'public')
union all select 'files in Storage are covered',
  exists (select 1 from pg_policies where policyname = 'reserved_guard_archive_files' and schemaname = 'storage')
union all select 'the level is protected by the guard',
  (select prosrc like '%can_manage_reserved%' from pg_proc where proname = 'guard_document_visibility')
union all select 'enabling a person is logged',
  exists (select 1 from pg_trigger where tgname = 'reserved_access_log_change');
