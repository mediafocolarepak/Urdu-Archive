-- 170: what an Operator may write, and what Suspended and Excluded mean (Owner's decisions, 2026-11-25).
--   1. A suspended person stops working: in the archive they count as a User (they read, and use Share with us) until
--      they are reinstated. An excluded person no longer reads anything but the public pages. Never applied to an Admin.
--   2. Operators write only through the doors made for their work: the draft of their own task, a proposal, the Work of
--      a document that has none. The archive tools belong to the members of Archive & Data, Coordinators and Admins.
-- Run AFTER the code of the same pull request is live (it works with and without this file). Safe to run again.
-- What the functions do is otherwise unchanged: only the checks named here are added to the live definitions.

-- ============================================================================
-- 1. Standing: active, watch, suspended, excluded
-- ============================================================================
do $m$
declare c record;
begin
  for c in select conname from pg_constraint
            where conrelid = 'public.user_roles'::regclass and contype = 'c' and pg_get_constraintdef(oid) like '%standing%' loop
    execute format('alter table public.user_roles drop constraint %I', c.conname);
  end loop;
end $m$;
alter table public.user_roles add constraint user_roles_standing_check
  check (standing in ('active', 'watch', 'suspended', 'excluded'));

-- Those already excluded: their last decision about standing is an approved exclusion.
update public.user_roles r set standing = 'excluded'
where r.standing = 'suspended' and r.role = 'user'
  and (select d.decision_type from public.people_decisions d
        where d.subject_user_id = r.user_id and d.status = 'approved' and d.decision_type in ('suspend', 'reinstate', 'exclude')
        order by d.decided_at desc nulls last, d.id desc limit 1) = 'exclude';

-- The role a person has right now. Every rule and function that asks for a role goes through here.
create or replace function public.current_role_is(min_role text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((
    select case
      when r.role <> 'admin' and r.standing = 'excluded' then false
      when min_role = 'user' then true
      when r.role <> 'admin' and r.standing = 'suspended' then false
      when min_role = 'operator' then r.role in ('operator', 'coordinator', 'admin')
      when min_role = 'coordinator' then r.role in ('coordinator', 'admin')
      when min_role = 'admin' then r.role = 'admin'
      else false
    end
    from public.user_roles r where r.user_id = auth.uid()), false);
$$;

-- Neither suspended nor excluded: for what a person does as member of a department, editor, Revisor, author of a path.
create or replace function public.person_may_work()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((select r.role = 'admin' or r.standing not in ('suspended', 'excluded')
                     from public.user_roles r where r.user_id = auth.uid()), false);
$$;
revoke execute on function public.person_may_work() from public, anon;
grant execute on function public.person_may_work() to authenticated;

-- The checks that look at a membership, an editor's place or a qualification, not at the role.
do $m$
declare
  f record;
  v_def text;
  v_new text;
  -- "from <membership> [alias] where ... auth.uid()": only when the row asked for is the caller's own.
  v_rights constant text := '(from\s+(?:public\.)?(?:user_qualifications|department_members|board_editors|reserved_access|formation_path_editors|formation_paths)\s+(?:(?!where\M)\w+\s+)?where\s+)(?=[^;()]*auth\.uid\(\))';
begin
  for f in
    select p.oid, p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prokind = 'f' and p.prosrc ~* v_rights and p.prosrc !~ 'person_may_work'
  loop
    v_def := pg_get_functiondef(f.oid);
    v_new := regexp_replace(v_def, v_rights, '\1public.person_may_work() and ', 'gi');
    if v_new is distinct from v_def then execute v_new; end if;
  end loop;

  -- A suspended person cannot send a task; they can still give it up, so that someone else takes it.
  for f in
    select p.oid, p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'submit_task' and p.prosrc !~ 'person_may_work'
  loop
    execute regexp_replace(pg_get_functiondef(f.oid), '\nbegin\s*\n',
      E'\nbegin\n  if not public.person_may_work() then raise exception ''Your work in DUA is paused at the moment.''; end if;\n', 'i');
  end loop;

  -- Functions that ask only who is calling: closed to an excluded person.
  for f in
    select p.oid, p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosrc !~ 'current_role_is'
      and p.proname in ('reserve_reading', 'submit_reading', 'submit_formation_quiz_attempt', 'enroll_in_formation_path', 'send_submission_reminder')
  loop
    execute regexp_replace(pg_get_functiondef(f.oid), '\nbegin\s*\n',
      E'\nbegin\n  if not public.current_role_is(''user'') then raise exception ''Your access to DUA is closed.''; end if;\n', 'i');
  end loop;

  -- No task for a suspended or excluded person.
  for f in
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'block_suspended_task_claim' and p.prosrc !~ 'excluded'
  loop
    execute regexp_replace(pg_get_functiondef(f.oid), $r$standing = 'suspended'$r$, $r$standing in ('suspended', 'excluded')$r$);
  end loop;

  -- The decisions: an exclusion says so, a suspension cannot soften it, only Admin takes an excluded person back.
  for f in
    select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'apply_people_decision' and p.prosrc !~ 'excluded'
  loop
    v_def := pg_get_functiondef(f.oid);
    v_def := replace(v_def, $r$set role = 'user', standing = 'suspended' where user_id = d.subject_user_id;$r$,
      $r$set role = 'user', standing = 'excluded' where user_id = d.subject_user_id;
    update public.reserved_access set revoked_at = now() where user_id = d.subject_user_id and revoked_at is null;$r$);
    v_def := replace(v_def, $r$set standing = 'suspended' where user_id = d.subject_user_id;$r$,
      $r$set standing = 'suspended' where user_id = d.subject_user_id and standing <> 'excluded';$r$);
    v_def := replace(v_def, $r$update public.user_roles set standing = 'active' where user_id = d.subject_user_id;$r$,
      $r$if exists (select 1 from public.user_roles where user_id = d.subject_user_id and standing = 'excluded') and not public.current_role_is('admin') then
      raise exception 'Only an Admin can take back a person who was excluded.';
    end if;
    update public.user_roles set standing = 'active' where user_id = d.subject_user_id;$r$);
    execute v_def;
  end loop;
end $m$;

-- The rules that ask only who is writing: from whoever has access, and a path's co-authors only from who may work.
drop policy if exists "open_access_guard" on public.chat_messages;
create policy "open_access_guard" on public.chat_messages as restrictive for insert to authenticated
  with check ((select public.current_role_is('user')));
drop policy if exists "open_access_guard" on public.formation_chat_messages;
create policy "open_access_guard" on public.formation_chat_messages as restrictive for insert to authenticated
  with check ((select public.current_role_is('user')));
drop policy if exists "open_access_guard" on public.board_posts;
create policy "open_access_guard" on public.board_posts as restrictive for update to authenticated
  using ((select public.current_role_is('user')));
drop policy if exists "open_access_guard" on public.collaboration_applications;
create policy "open_access_guard" on public.collaboration_applications as restrictive for insert to authenticated
  with check ((select public.current_role_is('user')));
drop policy if exists "may_work_guard" on public.formation_path_editors;
create policy "may_work_guard" on public.formation_path_editors as restrictive for insert to authenticated
  with check ((select public.person_may_work()));
drop policy if exists "may_work_guard_delete" on public.formation_path_editors;
create policy "may_work_guard_delete" on public.formation_path_editors as restrictive for delete to authenticated
  using ((select public.person_may_work()));

-- ============================================================================
-- 2. Who uses the archive tools
-- ============================================================================
create or replace function public.can_catalogue()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('coordinator') or (public.current_role_is('operator') and public.is_dept_member('ARCHIVE'));
$$;
revoke execute on function public.can_catalogue() from public, anon;
grant execute on function public.can_catalogue() to authenticated;

-- ============================================================================
-- 3. The doors of an Operator's work
-- ============================================================================
-- The corrected file of one's own task: the first time it makes the draft, then it replaces the file of that draft.
create or replace function public.save_task_draft(p_task_id bigint, p_path text)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  t public.tasks%rowtype;
  o public.documents%rowtype;
  v_id integer;
  v_translation boolean;
begin
  if not public.current_role_is('operator') then raise exception 'Only team members can do this.'; end if;
  select * into t from public.tasks where id = p_task_id for update;
  if not found or t.claimed_by is distinct from auth.uid() then raise exception 'You can only add a file to a task you have taken.'; end if;
  if t.status <> 'claimed' then raise exception 'This task has already been sent, or is no longer yours.'; end if;
  if t.document_id is null then raise exception 'This task has no document.'; end if;
  if not public.task_file_ok(p_path) or split_part(p_path, '-', 3) <> p_task_id::text then raise exception 'This file does not belong to this task.'; end if;
  if not exists (select 1 from storage.objects s where s.bucket_id = 'archive-files' and s.name = p_path) then
    raise exception 'The file did not arrive. Please try again.';
  end if;

  select * into o from public.documents where document_id = t.document_id and deleted_at is null;
  if not found or not public.document_reserved_ok(t.document_id) then raise exception 'Original document not found.'; end if;

  select d.document_id into v_id from public.documents d where d.source_task_id = p_task_id and d.deleted_at is null order by d.document_id limit 1;
  if found then
    update public.documents set draft_inp_path = p_path where document_id = v_id and workflow_status = 'revision';
    if not found then raise exception 'This draft can no longer be changed.'; end if;
    return v_id;
  end if;

  v_id := nextval('public.document_id_seq')::integer;
  v_translation := coalesce(t.category, '') in ('IT_UR', 'EN_UR');
  insert into public.documents (document_id, work_id, title, en_title, it_title, it_title_translated, original_title, ur_title,
      category, author, language, ref_date, ref_period, recipient, main_topic, secondary_tags, bible_verse, media_type,
      workflow_status, source_task_id, draft_inp_path, is_preferred, legacy_migrated)
  values (v_id, o.work_id, o.title, o.en_title, o.it_title, o.it_title_translated,
      case when v_translation then null else o.original_title end, case when v_translation then null else o.ur_title end,
      o.category, o.author, case when v_translation then 'URD' else o.language end, o.ref_date, o.ref_period, o.recipient,
      o.main_topic, o.secondary_tags, o.bible_verse, coalesce(o.media_type, 'DOC'),
      'revision', p_task_id, p_path, false, false);
  return v_id;
end;
$$;

-- A file in archive-files named after a task the caller holds: draft-<document>-<task>-<when>.<kind>
create or replace function public.task_file_ok(p_name text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select p_name ~ '^draft-[0-9]{1,9}-[0-9]{1,15}-[0-9]{1,20}\.[a-z0-9]{1,8}$'
     and exists (select 1 from public.tasks t
                  where t.id::text = split_part(p_name, '-', 3) and t.document_id::text = split_part(p_name, '-', 2)
                    and t.claimed_by = auth.uid() and t.status = 'claimed')
     and public.current_role_is('operator');
$$;

-- "+ Add a related version" on a document that has no Work yet.
create or replace function public.ensure_work_for_document(p_document_id integer)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  d public.documents%rowtype;
  v_work bigint;
begin
  if not public.current_role_is('operator') then raise exception 'Only team members can do this.'; end if;
  select * into d from public.documents where document_id = p_document_id and deleted_at is null for update;
  if not found or not public.document_reserved_ok(p_document_id) or not public.document_status_is_visible(d.workflow_status) then
    raise exception 'Document not found.';
  end if;
  if d.work_id is not null then return d.work_id; end if;
  insert into public.works (canonical_title) values (coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), d.original_title))
  returning work_id into v_work;
  update public.documents set work_id = v_work where document_id = p_document_id;
  return v_work;
end;
$$;

revoke execute on function public.save_task_draft(bigint, text), public.task_file_ok(text), public.ensure_work_for_document(integer) from public, anon;
grant execute on function public.save_task_draft(bigint, text), public.task_file_ok(text), public.ensure_work_for_document(integer) to authenticated;

-- ============================================================================
-- 4. The rules: what was open to every Operator
-- ============================================================================
do $m$
declare
  p record;
  v_instead text;
  f record;
begin
  for p in
    select tablename, policyname, qual, with_check from pg_policies
    where schemaname = 'public' and permissive = 'PERMISSIVE' and cmd <> 'SELECT'
      and tablename in ('documents', 'works', 'process_history', 'document_collections', 'hayat_indice',
                        'document_texts', 'document_original_texts', 'ref_collegamenti', 'ref_video_index', 'ref_parola_di_vita')
      and (coalesce(qual, '') || coalesce(with_check, '')) ~ 'current_role_is\(''operator'''
  loop
    -- Texts and the reference tables: no screen of an Operator writes them, not even in the archive tools.
    v_instead := case when p.tablename in ('document_texts', 'document_original_texts', 'ref_collegamenti', 'ref_video_index', 'ref_parola_di_vita')
                      then '(select public.current_role_is(''coordinator''))' else '(select public.can_catalogue())' end;
    execute format('alter policy %I on public.%I', p.policyname, p.tablename)
      || case when p.qual is not null then ' using (' || regexp_replace(p.qual, '(public\.)?current_role_is\(''operator''(::text)?\)', v_instead, 'g') || ')' else '' end
      || case when p.with_check is not null then ' with check (' || regexp_replace(p.with_check, '(public\.)?current_role_is\(''operator''(::text)?\)', v_instead, 'g') || ')' else '' end;
  end loop;

  -- New documents outside the doors: only Admin makes them in the app; Coordinators keep the hidden drafts.
  for p in select policyname from pg_policies where schemaname = 'public' and tablename = 'documents' and cmd = 'INSERT' and permissive = 'PERMISSIVE' loop
    execute format('alter policy %I on public.documents with check ((select public.current_role_is(''coordinator'')))', p.policyname);
  end loop;
  for f in
    select pr.oid from pg_proc pr join pg_namespace n on n.oid = pr.pronamespace
    where n.nspname = 'public' and pr.proname = 'next_document_id' and pr.prosrc ~ 'current_role_is\(''operator''\)'
  loop
    execute replace(pg_get_functiondef(f.oid), $r$current_role_is('operator')$r$, $r$current_role_is('coordinator')$r$);
  end loop;

  -- The retired Proofreading tab (77, 111): nothing calls them any more.
  for f in
    select pr.oid::regprocedure as sig from pg_proc pr join pg_namespace n on n.oid = pr.pronamespace
    where n.nspname = 'public' and pr.proname in ('get_next_reread_document', 'submit_document_reread')
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', f.sig);
  end loop;
end $m$;

-- Five tables of the very first version (01), which nothing in the app reads: anyone signed in could still write them.
do $m$
declare t text;
begin
  foreach t in array array['document_categories', 'topics', 'process_categories', 'process', 'months'] loop
    if to_regclass('public.' || t) is null then continue; end if;
    execute format('drop policy if exists %I on public.%I', 'team read/write - ' || t, t);
    execute format('drop policy if exists %I on public.%I', 'read - ' || t, t);
    execute format('create policy %I on public.%I for select to authenticated using ((select public.current_role_is(''user'')))', 'read - ' || t, t);
  end loop;
end $m$;

-- Settings other than the pop-up switch: the Hayat Editor's prompt.
drop policy if exists "app_settings_select_write_roles" on public.app_settings;
create policy "app_settings_select_write_roles" on public.app_settings for select to authenticated using ((select public.can_catalogue()));
drop policy if exists "app_settings_insert_write_roles" on public.app_settings;
create policy "app_settings_insert_write_roles" on public.app_settings for insert to authenticated
  with check (key <> 'announcements_popup' and (select public.can_catalogue()));
drop policy if exists "app_settings_update_write_roles" on public.app_settings;
create policy "app_settings_update_write_roles" on public.app_settings for update to authenticated
  using (key <> 'announcements_popup' and (select public.can_catalogue())) with check (key <> 'announcements_popup');

-- Files: an Operator adds the file of their own task or of a proposal, and replaces nothing.
drop policy if exists "upload - archive-files" on storage.objects;
create policy "upload - archive-files" on storage.objects for insert to authenticated with check (
  bucket_id = 'archive-files' and (
    public.can_catalogue()
    or public.task_file_ok(name)
    or (public.current_role_is('operator') and name ~ '^proposal-[0-9a-f-]{36}\.pdf$')));
drop policy if exists "update - archive-files" on storage.objects;
create policy "update - archive-files" on storage.objects for update to authenticated
  using (bucket_id = 'archive-files' and public.can_catalogue())
  with check (bucket_id = 'archive-files' and public.can_catalogue());

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'Standing can be excluded' as item,
       exists (select 1 from pg_constraint where conrelid = 'public.user_roles'::regclass and pg_get_constraintdef(oid) like '%excluded%') as ok
union all select 2, 'The role looks at the standing',
       (select prosrc ~ 'excluded' and prosrc ~ 'suspended' from pg_proc where oid = 'public.current_role_is(text)'::regprocedure)
union all select 3, 'So do departments, editors and qualifications',
       (select count(distinct p.proname) >= 13 and bool_and(p.prosrc ~ 'person_may_work') from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname in (
           'is_dept_member', 'is_dept_lead', 'is_any_dept_lead', 'is_board_editor', 'is_formation_owner', 'can_edit_path',
           'can_propose_people_decision', 'has_reserved_access', 'department_roster', 'submit_task_review', 'can_review_submissions',
           'can_review_submission', 'can_review_readings'))
union all select 4, 'A suspended person sends no task, none is given to them',
       (select bool_and(p.prosrc ~ 'person_may_work' or p.prosrc ~ 'excluded') and count(*) = 2 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname in ('submit_task', 'block_suspended_task_claim'))
union all select 5, 'An exclusion says excluded, and only Admin undoes it',
       (select bool_and(p.prosrc ~ 'standing = ''excluded'' where' and p.prosrc ~ 'Only an Admin can take back' and p.prosrc ~ 'standing <> ''excluded''')
          from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'apply_people_decision')
union all select 6, 'An excluded person calls none of the five functions',
       (select bool_and(p.prosrc ~ 'current_role_is') from pg_proc p join pg_namespace n on n.oid = p.pronamespace
         where n.nspname = 'public' and p.proname in ('reserve_reading', 'submit_reading', 'submit_formation_quiz_attempt', 'enroll_in_formation_path', 'send_submission_reminder'))
union all select 7, 'No archive table is open to every Operator',
       not exists (select 1 from pg_policies where schemaname = 'public' and permissive = 'PERMISSIVE' and cmd <> 'SELECT'
         and tablename in ('documents', 'works', 'process_history', 'document_collections', 'hayat_indice', 'document_texts',
                           'document_original_texts', 'ref_collegamenti', 'ref_video_index', 'ref_parola_di_vita', 'app_settings')
         and (coalesce(qual, '') || coalesce(with_check, '')) ~ '''operator''')
union all select 8, 'Two rules on the files of the archive, both on the tools',
       (select count(*) = 2 and bool_and((coalesce(qual, '') || coalesce(with_check, '')) ~ 'can_catalogue') from pg_policies
         where schemaname = 'storage' and tablename = 'objects' and policyname in ('upload - archive-files', 'update - archive-files'))
union all select 9, 'The doors are there, for signed-in people only',
       has_function_privilege('authenticated', 'public.save_task_draft(bigint, text)', 'execute')
       and has_function_privilege('authenticated', 'public.ensure_work_for_document(integer)', 'execute')
       and not has_function_privilege('anon', 'public.save_task_draft(bigint, text)', 'execute')
       and not has_function_privilege('anon', 'public.ensure_work_for_document(integer)', 'execute')
union all select 10, 'Six guards on the rules that ask only who is writing',
       (select count(*) = 6 from pg_policies where schemaname = 'public' and permissive = 'RESTRICTIVE'
         and policyname in ('open_access_guard', 'may_work_guard', 'may_work_guard_delete'))
union all select 11, 'No rule is open to whoever is signed in',
       not exists (select 1 from pg_policies where schemaname = 'public' and permissive = 'PERMISSIVE' and cmd <> 'SELECT'
         and (coalesce(qual, '') || coalesce(with_check, '')) ~ 'auth\.role\(\)')
union all select 12, 'No view passes over the rules',
       not exists (select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
         where n.nspname = 'public' and c.relkind in ('v', 'm') and not coalesce(c.reloptions::text ~ 'security_invoker=(true|on)', false)
           and (has_table_privilege('anon', c.oid, 'select') or has_table_privilege('authenticated', c.oid, 'select')))
union all select 13, 'Every Admin still works',
       (select count(*) > 0 and bool_and(standing is not null) from public.user_roles where role = 'admin')
order by 1;
