-- 62_fix_legacy_status_visibility.sql
-- Fixes a regression from 50_two_step_publish_and_versioning.sql: that migration rewrote the
-- "read - documents" SELECT policy to only cover the NEW two-step-publish vocabulary (null,
-- 'published', 'removed', 'revision', 'pending_publish'), forgetting the OLD legacy pipeline
-- statuses ('ENTR', 'TYP', 'PROF', 'CORR', 'APPR', 'STOR' - Entry/Typing/Proofing/Correction/
-- Approved/Stored, from 06_option_lists.sql) that most of the historical archive - and every
-- document Bulk Import or "New Document" creates today - still uses. Since that migration,
-- every document sitting at one of those statuses has been invisible to EVERY role, Admin
-- included (discovered 2026-09-03: Bulk Import silently reassigned a document_id already used
-- by an invisible 'ENTR' document, since its own max(document_id) lookup couldn't see it
-- either, and the insert failed on the primary key).
--
-- This restores the same visibility those legacy statuses had before 50 - same tier as
-- 'published' - without touching any data. A full review of legacy workflow_status values
-- (vs. the current two-step-publish pipeline) is tracked as separate follow-up work, not
-- attempted here on purpose (see PROJECT_HANDOFF_v10.md's session notes for 2026-09-03).

drop policy if exists "read - documents" on public.documents;
create policy "read - documents" on public.documents for select to authenticated using (
  current_role_is('user') and (
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
