-- 110_doors_and_archive_log.sql
-- Fase 1 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md (Owner's decisions of 2026-11-05):
--   1. Only Admin can make a document visible. + New document, Bulk Import and Hayat Extract become
--      Admin-only here in the database, not just in the interface.
--   2. The server gives out document numbers. The browser used to compute max + 1, which went wrong
--      for anyone who could not see hidden rows, and would reuse the number of a deleted document.
--   3. A log nobody can edit records every change to the archive, written by the database.
--   4. Deleting becomes reversible and leaves a trace. Nobody can hard-delete through the API.
--   5. During development Admin may approve their own proposals on people and policy (109 already
--      did this for tasks). Compensation runs keep the second person, since they concern money.
--
-- Run after 109. Safe to re-run. Nothing is hidden from readers and no status changes.

-- ============================================================================
-- 1. Document numbers
-- ============================================================================
create sequence if not exists public.document_id_seq;

-- Never moves backwards, so re-running this cannot hand out a number twice.
select setval(
  'public.document_id_seq',
  greatest(
    (select coalesce(max(document_id), 1) from public.documents),
    (select last_value from public.document_id_seq)
  )
);

alter table public.documents alter column document_id set default nextval('public.document_id_seq');

create or replace function public.next_document_id()
returns integer
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('operator') then
    raise exception 'Only team members can create documents.';
  end if;
  return nextval('public.document_id_seq')::integer;
end;
$$;

-- ============================================================================
-- 2. Deleted documents: columns and rules
-- ============================================================================
alter table public.documents add column if not exists deleted_at timestamptz;
alter table public.documents add column if not exists deleted_by uuid references auth.users(id) on delete set null;
alter table public.documents add column if not exists deleted_by_email text;
alter table public.documents add column if not exists deleted_reason text;

-- Same rule that is live today (62, 50), plus: a deleted document is hidden from everyone, Admin
-- included. Admin reaches them through get_deleted_documents().
drop policy if exists "read - documents" on public.documents;
create policy "read - documents" on public.documents for select to authenticated using (
  current_role_is('user') and deleted_at is null and (
    workflow_status is null
    or workflow_status = 'published'
    or workflow_status in ('ENTR', 'TYP', 'PROF', 'CORR', 'APPR', 'STOR')
    or (workflow_status = 'removed' and current_role_is('coordinator'))
    or (workflow_status in ('revision', 'pending_publish') and (
      current_role_is('coordinator')
      or exists (select 1 from public.tasks t where t.id = documents.source_task_id and t.claimed_by = auth.uid())
    ))
  )
);

drop policy if exists "update - documents" on public.documents;
create policy "update - documents" on public.documents for update to authenticated
  using (current_role_is('operator') and deleted_at is null)
  with check (current_role_is('operator'));

-- No delete policy at all: soft_delete_document() below is the only way.
drop policy if exists "delete - documents" on public.documents;

-- ============================================================================
-- 3. Only Admin changes what readers can see
-- ============================================================================
create or replace function public.document_status_is_visible(p_status text)
returns boolean
language sql
immutable
as $$
  select p_status is null or p_status in ('published', 'ENTR', 'TYP', 'PROF', 'CORR', 'APPR', 'STOR');
$$;

-- Everyone else may still create a hidden 'revision' draft (a task correction, a promoted board post)
-- and move a draft between hidden states (a Revisor's fail discards it). Moves between two visible
-- states stay open for the old process steps: they change nothing for readers. auth.uid() is null
-- only outside the app (SQL Editor, migrations), where the anonymous API has no write rule anyway.
create or replace function public.guard_document_visibility()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
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
    return new;
  end if;

  if public.document_status_is_visible(new.workflow_status) <> public.document_status_is_visible(old.workflow_status) then
    raise exception 'Only Admin can publish or withdraw a document.';
  end if;
  if new.deleted_at is distinct from old.deleted_at then
    raise exception 'Only Admin can delete or restore a document.';
  end if;
  return new;
end;
$$;

drop trigger if exists documents_guard_visibility on public.documents;
create trigger documents_guard_visibility
  before insert or update on public.documents
  for each row execute function public.guard_document_visibility();

-- ============================================================================
-- 4. The archive log
-- ============================================================================
create table if not exists public.archive_log (
  id          bigint generated always as identity primary key,
  at          timestamptz not null default now(),
  actor_id    uuid,          -- null: a migration or the SQL Editor, not a person in the app
  actor_email text,
  actor_role  text,          -- at that moment; 'admin' marks Admin's direct actions
  table_name  text not null,
  row_key     text not null,
  document_id integer,       -- no foreign key on purpose: the log outlives everything it describes
  action      text not null check (action in ('insert', 'update', 'delete')),
  changes     jsonb not null -- { "field": { "old": ..., "new": ... } }
);
create index if not exists idx_archive_log_document on public.archive_log (document_id, at desc);
create index if not exists idx_archive_log_actor on public.archive_log (actor_id, at desc);

-- No policies: rows are reached only through the functions below, and written only by the trigger.
alter table public.archive_log enable row level security;

create or replace function public.archive_log_is_append_only()
returns trigger
language plpgsql
as $$
begin
  raise exception 'The archive log cannot be changed.';
end;
$$;

drop trigger if exists archive_log_no_update on public.archive_log;
create trigger archive_log_no_update
  before update or delete on public.archive_log
  for each row execute function public.archive_log_is_append_only();

drop trigger if exists archive_log_no_truncate on public.archive_log;
create trigger archive_log_no_truncate
  before truncate on public.archive_log
  for each statement execute function public.archive_log_is_append_only();

-- Generic: the arguments are the columns that identify the row. Derived columns and running totals
-- are left out, so a credit paid does not look like someone editing a profile. On insert the body
-- of a text is left out too, because its first update records it as the old value.
create or replace function public.log_archive_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_old     jsonb := case when tg_op = 'INSERT' then '{}'::jsonb else to_jsonb(old) end;
  v_new     jsonb := case when tg_op = 'DELETE' then '{}'::jsonb else to_jsonb(new) end;
  v_row     jsonb := case when tg_op = 'DELETE' then v_old else v_new end;
  v_ignored text[] := array['body_norm', 'body_tsv', 'char_count', 'updated_at', 'updated_by_email', 'credits', 'reputation', 'created_at'];
  v_changes jsonb := '{}'::jsonb;
  v_key     text;
  v_row_key text := '';
  v_role    text;
  v_email   text;
  i         integer;
begin
  for v_key in select jsonb_object_keys(v_old || v_new) loop
    continue when v_key = any (v_ignored);
    continue when tg_op = 'INSERT' and v_key = 'body';
    -- An empty field counts as absent, so a new row lists only what was really filled in.
    if coalesce(v_old -> v_key, 'null'::jsonb) is distinct from coalesce(v_new -> v_key, 'null'::jsonb) then
      v_changes := v_changes || jsonb_build_object(v_key, jsonb_strip_nulls(jsonb_build_object('old', v_old -> v_key, 'new', v_new -> v_key)));
    end if;
  end loop;

  if tg_op = 'UPDATE' and v_changes = '{}'::jsonb then
    return new;
  end if;

  for i in 0 .. tg_nargs - 1 loop
    v_row_key := v_row_key || case when i > 0 then '/' else '' end || coalesce(v_row ->> tg_argv[i], '');
  end loop;

  select role, email into v_role, v_email from public.user_roles where user_id = auth.uid();

  insert into public.archive_log (actor_id, actor_email, actor_role, table_name, row_key, document_id, action, changes)
  values (auth.uid(), v_email, v_role, tg_table_name, v_row_key, (v_row ->> 'document_id')::integer, lower(tg_op), v_changes);

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

do $$
declare
  t record;
begin
  for t in
    select * from (values
      ('documents', 'document_id'),
      ('document_texts', 'document_id'),
      ('document_original_texts', 'document_id, language'),
      ('document_collections', 'document_id, collection_code'),
      ('process_history', 'id'),
      ('works', 'work_id'),
      ('tasks', 'id'),
      ('user_roles', 'user_id'),
      ('user_qualifications', 'user_id, qualification_code'),
      ('department_members', 'department_code, user_id')
    ) as v(table_name, key_columns)
  loop
    execute format('drop trigger if exists %I on public.%I', t.table_name || '_log_change', t.table_name);
    execute format(
      'create trigger %I after insert or update or delete on public.%I for each row execute function public.log_archive_change(%s)',
      t.table_name || '_log_change', t.table_name,
      (select string_agg(quote_literal(btrim(c)), ', ') from unnest(string_to_array(t.key_columns, ',')) c)
    );
  end loop;
end;
$$;

-- ============================================================================
-- 5. Delete and restore
-- ============================================================================
create or replace function public.soft_delete_document(p_document_id integer, p_reason text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
begin
  if not public.current_role_is('admin') then
    raise exception 'Only Admin can delete a document.';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'Please give a reason for deleting this document.';
  end if;
  select email into v_email from public.user_roles where user_id = auth.uid();

  update public.documents
  set deleted_at = now(), deleted_by = auth.uid(), deleted_by_email = v_email, deleted_reason = btrim(p_reason)
  where document_id = p_document_id and deleted_at is null;
  if not found then raise exception 'Document not found, or already deleted.'; end if;
end;
$$;

create or replace function public.restore_document(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then
    raise exception 'Only Admin can restore a document.';
  end if;
  update public.documents
  set deleted_at = null, deleted_by = null, deleted_by_email = null, deleted_reason = null
  where document_id = p_document_id and deleted_at is not null;
  if not found then raise exception 'This document is not deleted.'; end if;
end;
$$;

create or replace function public.get_deleted_documents()
returns table (document_id integer, title text, language text, deleted_at timestamptz, deleted_by_email text, deleted_reason text)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then
    raise exception 'Only Admin can see deleted documents.';
  end if;
  return query
    select d.document_id, d.title, d.language, d.deleted_at, d.deleted_by_email, d.deleted_reason
    from public.documents d
    where d.deleted_at is not null
    order by d.deleted_at desc;
end;
$$;

-- ============================================================================
-- 6. Reading the log
-- ============================================================================
-- Text bodies can be long: the log keeps them, these views only say they changed.
create or replace function public.archive_log_summary(p_changes jsonb)
returns jsonb
language sql
immutable
as $$
  select case when p_changes ? 'body'
    then (p_changes - 'body') || '{"body": {"new": "(text changed)"}}'::jsonb
    else p_changes end;
$$;

-- Coordinators and Admin.
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
  return query
    select l.at, coalesce(nullif(p.full_name, ''), l.actor_email, '(system)'), l.actor_role, l.table_name, l.action,
           public.archive_log_summary(l.changes)
    from public.archive_log l
    left join public.user_profiles p on p.user_id = l.actor_id
    where l.document_id = p_document_id
    order by l.at desc, l.id desc;
end;
$$;

-- The person themselves, Admin and the HR lead.
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
    order by l.at desc, l.id desc
    limit greatest(1, least(coalesce(p_limit, 200), 1000));
end;
$$;

-- ============================================================================
-- 7. Admin may approve their own proposals during development
-- ============================================================================
create or replace function public.decide_people_decision(p_id bigint, p_outcome text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d       public.people_decisions%rowtype;
  v_email text;
begin
  select * into d from public.people_decisions where id = p_id for update;
  if d is null then raise exception 'Decision not found.'; end if;
  if d.status <> 'pending' then raise exception 'This decision has already been closed (%).', d.status; end if;
  if p_outcome not in ('approved', 'rejected', 'withdrawn') then raise exception 'Invalid outcome.'; end if;

  if p_outcome = 'withdrawn' then
    if d.proposed_by <> auth.uid() then raise exception 'Only the proposer can withdraw a proposal.'; end if;
  else
    if d.proposed_by = auth.uid() and not public.current_role_is('admin') then
      raise exception 'The person who proposed a decision cannot approve or reject it.';
    end if;
    if not public.can_approve_people_decision(d.decision_type) then
      raise exception 'You are not allowed to decide a "%" decision.', d.decision_type;
    end if;
    if p_outcome = 'rejected' and (p_note is null or btrim(p_note) = '') then
      raise exception 'A note is required when rejecting.';
    end if;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  update public.people_decisions
  set status = p_outcome, decided_by = auth.uid(), decided_by_email = v_email,
      decided_at = now(), decision_note = p_note
  where id = p_id;

  if p_outcome = 'approved' then
    perform public.apply_people_decision(p_id);
  end if;
end;
$$;

create or replace function public.decide_policy_change(p_id bigint, p_outcome text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  p       public.policy_proposals%rowtype;
  v_email text;
begin
  select * into p from public.policy_proposals where id = p_id for update;
  if p is null then raise exception 'Proposal not found.'; end if;
  if p.status <> 'pending' then raise exception 'This proposal has already been closed (%).', p.status; end if;
  if p_outcome not in ('approved', 'rejected', 'withdrawn') then raise exception 'Invalid outcome.'; end if;

  if p_outcome = 'withdrawn' then
    if p.proposed_by <> auth.uid() then raise exception 'Only the proposer can withdraw a proposal.'; end if;
  else
    if p.proposed_by = auth.uid() and not public.current_role_is('admin') then
      raise exception 'The person who proposed a policy change cannot approve or reject it.';
    end if;
    if not public.can_approve_policy_change() then
      raise exception 'You are not allowed to decide a policy proposal.';
    end if;
    if p_outcome = 'rejected' and (p_note is null or btrim(p_note) = '') then
      raise exception 'A note is required when rejecting.';
    end if;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  update public.policy_proposals
  set status = p_outcome, decided_by = auth.uid(), decided_by_email = v_email,
      decided_at = now(), decision_note = p_note
  where id = p_id;

  if p_outcome = 'approved' then
    perform public.apply_policy_change(p_id);
  end if;
end;
$$;

-- ============================================================================
-- 8. Verification: every row must say true.
-- ============================================================================
select 'next number is above every existing document' as item,
  (select last_value from public.document_id_seq) >= (select max(document_id) from public.documents) as ok
union all select 'anonymous and direct delete rules are gone',
  not exists (select 1 from pg_policies where tablename = 'documents' and cmd = 'DELETE')
union all select 'read rule hides deleted documents',
  (select qual like '%deleted_at IS NULL%' from pg_policies where tablename = 'documents' and policyname = 'read - documents')
union all select 'visibility guard installed',
  exists (select 1 from pg_trigger where tgname = 'documents_guard_visibility')
union all select 'log triggers installed on all 10 tables',
  (select count(*) = 10 from pg_trigger where tgname like '%\_log\_change' and not tgisinternal)
union all select 'log cannot be changed',
  (select count(*) = 2 from pg_trigger where tgrelid = 'public.archive_log'::regclass and not tgisinternal)
union all select 'no document marked deleted by this migration',
  not exists (select 1 from public.documents where deleted_at is not null);
