-- Adds page-count tracking to documents (needed to size proof-reading work) and matching
-- document_pages/credits snapshot fields to tasks, so a task keeps the figures it was created
-- with even if the document's page count is edited later. Credits formula is not defined yet
-- (to be agreed with the user) - for now the field is filled in manually when a task is created.

alter table public.documents add column if not exists pages integer;

alter table public.tasks add column if not exists document_pages integer;
alter table public.tasks add column if not exists credits integer;

-- The "report a document issue in chat -> create a proof-reading task" flow needs Coordinator
-- to see the message inbox and reply/dismiss like Admin already can (not just Admin, since
-- Coordinator is the tier that runs day-to-day task triage - same tier as tasks_insert_reviewers
-- in 34_task_store.sql and the Team Applications review policies in 22_collaboration_applications.sql).
drop policy if exists "chat_messages_select_admin" on public.chat_messages;
create policy "chat_messages_select_reviewers" on public.chat_messages
  for select using (current_role_is('coordinator'));

drop policy if exists "chat_messages_update_admin" on public.chat_messages;
create policy "chat_messages_update_reviewers" on public.chat_messages
  for update using (current_role_is('coordinator'));

select 'document pages + task credits fields installati.' as result;
