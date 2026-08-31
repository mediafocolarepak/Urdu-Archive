-- The "big" piece parked from earlier sessions: file handling for correction tasks. A task
-- linked to a document lets the Operator download the original, correct it, and upload the
-- result as a new document row (same work_id, sibling of the original) with
-- workflow_status = 'revision' - invisible to normal search/dashboard until reviewed. Reuses
-- documents.workflow_status (repurposed - the old paper-office pipeline codes are confirmed
-- dead, see PROJECT_HANDOFF_v6.md session notes 2026-08-31) instead of a new field.
--
-- Ties into the task review pipeline already built (38-43): a Revisor's fail, or Admin's
-- reject, marks the candidate 'removed' (discarded, admin-only visibility) and leaves the
-- original 'published' untouched; Admin's publish makes the candidate 'published' and marks
-- the OLD original 'removed' (superseded, not deleted) - a replace, not an extra sibling
-- version. Same blind-review principle as the task itself: a Revisor reaches the candidate
-- file only through get_review_document(), which never exposes who corrected it.
-- Do after 44_reputation_default_50.sql.

alter table public.documents add column if not exists source_task_id bigint references public.tasks(id) on delete set null;

-- One-time normalization: every existing/legacy workflow_status value becomes 'published' -
-- the vocabulary going forward is exactly published/revision/removed, nothing else.
update public.documents
set workflow_status = 'published'
where workflow_status is distinct from 'revision' and workflow_status is distinct from 'removed';

delete from public.option_lists where list_name = 'workflow_status';
insert into public.option_lists (list_name, code, label, sort_order) values
  ('workflow_status', 'published', 'Published', 1),
  ('workflow_status', 'revision', 'In revision', 2),
  ('workflow_status', 'removed', 'Removed', 3);

-- Real visibility gate (there wasn't one before - workflow_status was purely a UI filter).
-- published/no status: everyone. removed: Coordinator+ only (audit). revision: Coordinator+,
-- or the Operator who is the task's own claimant (so they can check their own upload) - a
-- Revisor is deliberately NOT included here, they only ever reach it via get_review_document().
drop policy if exists "read - documents" on public.documents;
create policy "read - documents" on public.documents for select to authenticated using (
  current_role_is('user') and (
    workflow_status is null
    or workflow_status = 'published'
    or (workflow_status = 'removed' and current_role_is('coordinator'))
    or (workflow_status = 'revision' and (
      current_role_is('coordinator')
      or exists (select 1 from public.tasks t where t.id = documents.source_task_id and t.claimed_by = auth.uid())
    ))
  )
);

-- Blind document fetch for review - same anonymization principle as get_review_queue(): a
-- Revisor gets the content needed to check the work, never operator/updated_by or any field
-- that would identify who did it.
create or replace function public.get_review_document(p_document_id integer)
returns table (
  document_id integer, title text, original_title text, ur_title text,
  storage_path text, file_name text, category text, language text, notes text
)
language sql
security definer
stable
as $$
  select d.document_id, d.title, d.original_title, d.ur_title, d.storage_path, d.file_name, d.category, d.language, d.notes
  from public.documents d
  where d.document_id = p_document_id
    and d.workflow_status = 'revision'
    and (
      current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
    );
$$;

-- get_review_queue() now also surfaces the candidate document's id (not identifying by itself)
-- so the review UI can offer "open the corrected file" via get_review_document() above. The
-- return shape changed (new column), so CREATE OR REPLACE alone is rejected by Postgres -
-- drop it first.
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
as $$
  select t.id, t.title, t.description, t.category, t.document_id, t.document_pages, t.credits, t.submitted_at,
    (select d.document_id from public.documents d where d.source_task_id = t.id limit 1) as candidate_document_id
  from public.tasks t
  where t.status = 'submitted'
    and t.claimed_by <> auth.uid()
    and (
      current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
    )
  order by t.submitted_at;
$$;

-- submit_task_review(): 'fail' also discards the candidate document (-> 'removed'), the
-- original stays untouched. ok/ok_but still don't touch credits/reputation nor the document -
-- that stays deferred to Admin's own decision, same as before.
create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
begin
  if not (
    current_role_is('coordinator')
    or exists (select 1 from public.user_qualifications where user_id = auth.uid() and qualification_code = 'REVISOR')
  ) then
    raise exception 'Only a Revisor (or Coordinator/Admin) can submit a review verdict.';
  end if;
  if p_verdict not in ('ok', 'ok_but', 'fail') then
    raise exception 'Invalid verdict.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'submitted' then raise exception 'Only a submitted task can be reviewed.'; end if;
  if v_task.claimed_by = auth.uid() then raise exception 'You cannot review your own task.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'fail' then
    update public.tasks
    set status = 'rejected', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;

    update public.documents set workflow_status = 'removed'
    where source_task_id = p_task_id and workflow_status = 'revision';

    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (p_task_id, v_task.claimed_by, 'review_fail', 0, -10, v_email, p_notes);

    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  else
    update public.tasks
    set status = 'approved', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;
  end if;
end;
$$;

-- admin_decide_task(): now also settles the linked document, if any. Publish -> candidate goes
-- live (workflow_status 'published', marked preferred) and the old original is superseded
-- ('removed', no longer preferred). Reject -> candidate discarded ('removed'), original
-- untouched. Same ledger/credit logic as before, unchanged.
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
      update public.documents set workflow_status = 'removed', is_preferred = false where document_id = v_task.document_id;
      update public.documents set workflow_status = 'published', is_preferred = true where document_id = v_candidate_doc_id;
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

select 'document revision workflow installato.' as result;
