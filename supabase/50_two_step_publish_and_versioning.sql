-- Closes the loop on the document revision workflow (45_document_revision_workflow.sql),
-- per 2026-08-31 session refinement:
--   1. Publishing a task and publishing a DOCUMENT are now two separate Admin actions, not one.
--      admin_decide_task('publish') closes the task and awards credits/reputation immediately,
--      but only moves the candidate document to a new 'pending_publish' state - not live yet.
--      A new finalize_document_publish() is the second, separate step Admin takes once the
--      final PDF + InPage file are ready.
--   2. Publishing a document no longer hides the old original ('removed') - both versions stay
--      'published' and visible, exactly like the existing Work-siblings mechanism already used
--      for language/media variants (see docdetail.js's "All Versions" bar) - is_preferred just
--      moves to the new version so it's the one shown by default.
--   3. The operator's raw uploaded correction now lives in a dedicated draft_inp_path column,
--      not storage_path/file_name - those stay reserved for the FINAL PDF, exactly like every
--      other document in the catalog. The final .inp Admin uploads after conversion goes to the
--      same Google Drive "INPAGE Original Document" folder as everything else today (via the
--      existing OAuth write path already used by the InPage Converter), named
--      "<new document_id>-<filename>", recorded in renamed_inp_file_name like any other doc.
-- Do after 49_renamed_inp_file_name.sql.

alter table public.documents add column if not exists draft_inp_path text;

insert into public.option_lists (list_name, code, label, sort_order) values
  ('workflow_status', 'pending_publish', 'Pending publish (task closed, document not final yet)', 4)
on conflict (list_name, code) do nothing;

-- revision/pending_publish share the same restricted visibility: the task's own claimant, or
-- Coordinator+. A Revisor still only ever reaches a 'revision' document via get_review_document
-- below - not through this policy.
drop policy if exists "read - documents" on public.documents;
create policy "read - documents" on public.documents for select to authenticated using (
  current_role_is('user') and (
    workflow_status is null
    or workflow_status = 'published'
    or (workflow_status = 'removed' and current_role_is('coordinator'))
    or (workflow_status in ('revision', 'pending_publish') and (
      current_role_is('coordinator')
      or exists (select 1 from public.tasks t where t.id = documents.source_task_id and t.claimed_by = auth.uid())
    ))
  )
);

-- Now returns draft_inp_path (where the operator's raw correction actually lives) instead of
-- storage_path/file_name, which are reserved for the final PDF and stay empty until Admin
-- finalizes. Return shape changed (columns differ from before) - drop first, same reason as
-- get_review_queue() in 45_document_revision_workflow.sql.
drop function if exists public.get_review_document(integer);
create function public.get_review_document(p_document_id integer)
returns table (
  document_id integer, title text, original_title text, ur_title text,
  draft_inp_path text, category text, language text, notes text
)
language sql
security definer
stable
as $$
  select d.document_id, d.title, d.original_title, d.ur_title, d.draft_inp_path, d.category, d.language, d.notes
  from public.documents d
  where d.document_id = p_document_id
    and d.workflow_status = 'revision'
    and (
      current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
    );
$$;

-- Publish branch now only moves the candidate to 'pending_publish' - the credit/reputation
-- ledger event still fires immediately (task is genuinely closed), but the document itself
-- isn't live until finalize_document_publish() runs as a distinct, later Admin action.
create or replace function public.admin_decide_task(p_task_id bigint, p_decision text, p_note text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_event_type text;
  v_candidate_doc_id integer;
begin
  if not current_role_is('admin') then
    raise exception 'Only Admin can make the final publish/reject decision.';
  end if;
  if p_decision not in ('publish', 'reject') then
    raise exception 'Invalid decision.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'approved' then raise exception 'Only an approved task can be published or rejected.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();
  select document_id into v_candidate_doc_id from public.documents where source_task_id = v_task.id limit 1;

  if p_decision = 'publish' then
    if v_task.review_verdict = 'ok_but' then
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := -5; v_event_type := 'review_ok_but';
    else
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := 10; v_event_type := 'review_ok';
    end if;
    update public.tasks set status = 'published', published_at = now() where id = p_task_id;

    if v_candidate_doc_id is not null then
      update public.documents set workflow_status = 'pending_publish' where document_id = v_candidate_doc_id;
    end if;
  else
    v_credit_delta := 0; v_reputation_delta := -10; v_event_type := 'admin_rejected';
    update public.tasks set status = 'rejected' where id = p_task_id;

    if v_candidate_doc_id is not null then
      update public.documents set workflow_status = 'removed' where document_id = v_candidate_doc_id;
    end if;
  end if;

  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_note);
end;
$$;

-- Second, separate Admin action: makes a 'pending_publish' document live. Demotes whichever
-- sibling in the same Work currently holds is_preferred (it stays 'published' and visible -
-- not hidden, just no longer the default shown version) and promotes this one instead.
create or replace function public.finalize_document_publish(p_document_id integer)
returns void
language plpgsql
security definer
as $$
declare
  v_work_id bigint;
begin
  if not current_role_is('admin') then
    raise exception 'Only Admin can publish a document.';
  end if;
  select work_id into v_work_id from public.documents where document_id = p_document_id;
  if v_work_id is null then raise exception 'Document not found or has no work_id.'; end if;

  update public.documents set is_preferred = false
  where work_id = v_work_id and document_id <> p_document_id and is_preferred = true;

  update public.documents set workflow_status = 'published', is_preferred = true
  where document_id = p_document_id;
end;
$$;

select 'two-step publish + versioning installato.' as result;
