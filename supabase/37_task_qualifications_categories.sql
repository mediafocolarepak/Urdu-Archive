-- Operator "qualifications" (Translator/Revisor/Proof Reader/Content Creator, ...) - tags on
-- top of the Operator role, not a new tier in the role hierarchy: a Revisor is an experienced
-- Operator who also judges whether translated/corrected text is good, not a rank that outranks
-- Coordinator. Admin-editable via the Options tab (list_name 'operator_qualification', reusing
-- the generic option_lists mechanism already used for document category/author/etc.) and
-- many-to-many via user_qualifications, since one person can hold more than one qualification
-- (e.g. Translator + Revisor). Paired with a closed task_category list, same mechanism.
-- Do after 36_document_pages_task_credits.sql.

insert into public.option_lists (list_name, code, label, sort_order) values
  ('operator_qualification', 'TRANSLATOR', 'Translator', 1),
  ('operator_qualification', 'REVISOR', 'Revisor', 2),
  ('operator_qualification', 'PROOF_READER', 'Proof Reader', 3),
  ('operator_qualification', 'CONTENT_CREATOR', 'Content Creator', 4)
on conflict (list_name, code) do nothing;

insert into public.option_lists (list_name, code, label, sort_order) values
  ('task_category', 'IT_UR', 'Italian to Urdu Translation', 1),
  ('task_category', 'EN_UR', 'English to Urdu Translation', 2),
  ('task_category', 'PROOFREAD', 'Proof Reading', 3),
  ('task_category', 'REVISION', 'Revision', 4),
  ('task_category', 'CONTENT', 'Content Creation', 5),
  ('task_category', 'OTHER', 'Others', 6)
on conflict (list_name, code) do nothing;

alter table public.tasks add column if not exists category text;

create table if not exists public.user_qualifications (
  user_id uuid not null references auth.users(id) on delete cascade,
  qualification_code text not null,
  primary key (user_id, qualification_code)
);
alter table public.user_qualifications enable row level security;

-- Coordinator+ need to read everyone's qualifications (to manage/assign); a user can read
-- their own. Only Admin assigns qualifications (same tier as who manages roles in Users).
drop policy if exists "user_qualifications_select" on public.user_qualifications;
create policy "user_qualifications_select" on public.user_qualifications
  for select using (user_id = auth.uid() or current_role_is('coordinator'));

drop policy if exists "user_qualifications_insert_admin" on public.user_qualifications;
create policy "user_qualifications_insert_admin" on public.user_qualifications
  for insert with check (current_role_is('admin'));

drop policy if exists "user_qualifications_delete_admin" on public.user_qualifications;
create policy "user_qualifications_delete_admin" on public.user_qualifications
  for delete using (current_role_is('admin'));

-- Whether a given user is allowed to work on a task of the given category - translation
-- categories need the TRANSLATOR qualification, REVISION needs REVISOR, everything else
-- (including no category, for tasks created before this migration) stays open to any operator.
-- Takes an explicit uid (not just auth.uid()) so it also covers a Coordinator assigning a task
-- directly to someone else at creation time, not just an Operator claiming an open one.
-- security definer so it can read user_qualifications regardless of the caller's own RLS grant.
create or replace function public.user_qualifies_for_category(uid uuid, cat text)
returns boolean
language sql
security definer
stable
as $$
  select case
    when cat in ('IT_UR', 'EN_UR') then exists (
      select 1 from public.user_qualifications uq where uq.user_id = uid and uq.qualification_code = 'TRANSLATOR')
    when cat = 'REVISION' then exists (
      select 1 from public.user_qualifications uq where uq.user_id = uid and uq.qualification_code = 'REVISOR')
    else true
  end;
$$;

drop policy if exists "tasks_insert_reviewers" on public.tasks;
create policy "tasks_insert_reviewers" on public.tasks
  for insert with check (
    current_role_is('coordinator')
    and (claimed_by is null or public.user_qualifies_for_category(claimed_by, category))
  );

drop policy if exists "tasks_select_team" on public.tasks;
create policy "tasks_select_team" on public.tasks
  for select using (
    current_role_is('coordinator')
    or claimed_by = auth.uid()
    or (current_role_is('operator') and public.user_qualifies_for_category(auth.uid(), category))
  );

-- with check also re-validates reassignment (Coordinator moving an already-claimed task to a
-- different Operator, not just the insert-time direct assignment above) against the target's
-- qualification - claimed_by = auth.uid() covers an Operator's own claim/update/mark-done.
drop policy if exists "tasks_update_own_or_reviewers" on public.tasks;
create policy "tasks_update_own_or_reviewers" on public.tasks
  for update using (
    current_role_is('coordinator')
    or claimed_by = auth.uid()
    or (claimed_by is null and public.user_qualifies_for_category(auth.uid(), category))
  ) with check (
    claimed_by = auth.uid()
    or (current_role_is('coordinator') and (claimed_by is null or public.user_qualifies_for_category(claimed_by, category)))
  );

select 'task qualifications + categories installati.' as result;
