-- 82_formation_co_authors.sql
-- GOVERNANCE.md §2.3 / PROJECT_HANDOFF_v23.md §3.3: "Working together on a course is the
-- preferred way, not the exception." Until now a formation path had exactly one owner who could
-- edit it; this adds co-authors (formation_path_editors) who work the path exactly like the
-- owner, while publishing (draft -> published) stays reserved to the owner or the Formation lead
-- (or Coordinator/Admin, who already had oversight before this migration).
--
-- Run after 81_team_applications_hr_only.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. Co-authors table. Read is open (same openness as department_members/board_editors - who
--    works on what is not secret); write is owner of the path, the Formation lead, or
--    Coordinator/Admin (mirrors "invited by the owner", GOVERNANCE.md §2.3, with the same
--    oversight escape hatches the rest of formation_* already has).
-- ============================================================================
create table if not exists public.formation_path_editors (
  path_id        bigint      not null references public.formation_paths(id) on delete cascade,
  user_id        uuid        not null references auth.users(id) on delete cascade,
  added_by_email text,
  created_at     timestamptz not null default now(),
  primary key (path_id, user_id)
);

alter table public.formation_path_editors enable row level security;

drop policy if exists "formation_path_editors_select" on public.formation_path_editors;
create policy "formation_path_editors_select" on public.formation_path_editors
  for select using (current_role_is('user'));

drop policy if exists "formation_path_editors_write" on public.formation_path_editors;
create policy "formation_path_editors_write" on public.formation_path_editors
  for all using (
    exists (select 1 from public.formation_paths p where p.id = path_id and p.owner_id = auth.uid())
    or public.is_dept_lead('FORM')
    or current_role_is('coordinator')
  )
  with check (
    exists (select 1 from public.formation_paths p where p.id = path_id and p.owner_id = auth.uid())
    or public.is_dept_lead('FORM')
    or current_role_is('coordinator')
  );

-- ============================================================================
-- 2. can_edit_path(): owner OR co-author OR Coordinator (Admin already passes every policy via
--    current_role_is checks elsewhere, and RLS is bypassed for the service role regardless).
--    is_formation_owner() (73) is kept as-is - it now means specifically "the single owner",
--    used where that distinction still matters (the publish guard below).
-- ============================================================================
create or replace function public.can_edit_path(pid bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.is_formation_owner(pid)
      or exists (select 1 from public.formation_path_editors where path_id = pid and user_id = auth.uid())
      or current_role_is('coordinator');
$$;

-- ============================================================================
-- 3. Publishing stays owner/Formation-lead/Coordinator/Admin even though can_edit_path() above
--    now lets co-authors update the row for everything else - a trigger, because formation_paths
--    is normally updated with a plain .update(), not a dedicated RPC (see formation.js).
-- ============================================================================
create or replace function public.check_formation_path_publish()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status is distinct from old.status then
    if not (auth.uid() = new.owner_id or public.is_dept_lead('FORM')
            or current_role_is('coordinator') or current_role_is('admin')) then
      raise exception 'Only the path owner, the Formation lead, or Coordinator/Admin can change a path''s publication status.';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_formation_path_publish_guard on public.formation_paths;
create trigger trg_formation_path_publish_guard
  before update of status on public.formation_paths
  for each row execute function public.check_formation_path_publish();

-- ============================================================================
-- 4. Redefine every write (and quiz-question select, which exists specifically to hide
--    correct_index from students - the same "who manages this path" audience as write) policy
--    that used to check is_formation_owner()/owner_id directly, to use can_edit_path() instead.
-- ============================================================================
drop policy if exists "formation_paths_update" on public.formation_paths;
create policy "formation_paths_update" on public.formation_paths
  for update using (public.can_edit_path(id)) with check (public.can_edit_path(id));
drop policy if exists "formation_paths_delete" on public.formation_paths;
create policy "formation_paths_delete" on public.formation_paths
  for delete using (public.can_edit_path(id));

drop policy if exists "formation_years_write" on public.formation_years;
create policy "formation_years_write" on public.formation_years
  for all using (public.can_edit_path(path_id)) with check (public.can_edit_path(path_id));

drop policy if exists "formation_modules_write" on public.formation_modules;
create policy "formation_modules_write" on public.formation_modules
  for all using (exists (select 1 from public.formation_years y where y.id = year_id and public.can_edit_path(y.path_id)))
  with check (exists (select 1 from public.formation_years y where y.id = year_id and public.can_edit_path(y.path_id)));

drop policy if exists "formation_chapters_write" on public.formation_chapters;
create policy "formation_chapters_write" on public.formation_chapters
  for all using (
    exists (select 1 from public.formation_modules m join public.formation_years y on y.id = m.year_id
              where m.id = module_id and public.can_edit_path(y.path_id))
  )
  with check (
    exists (select 1 from public.formation_modules m join public.formation_years y on y.id = m.year_id
              where m.id = module_id and public.can_edit_path(y.path_id))
  );

-- formation_posts_write: last redefined in 79 (adds the document_is_postable check) - keep that
-- check, only swap the ownership clause.
drop policy if exists "formation_posts_write" on public.formation_posts;
create policy "formation_posts_write" on public.formation_posts
  for all using (
    exists (select 1 from public.formation_chapters c
              join public.formation_modules m on m.id = c.module_id
              join public.formation_years y on y.id = m.year_id
            where c.id = chapter_id and public.can_edit_path(y.path_id))
  )
  with check (
    exists (select 1 from public.formation_chapters c
              join public.formation_modules m on m.id = c.module_id
              join public.formation_years y on y.id = m.year_id
            where c.id = chapter_id and public.can_edit_path(y.path_id))
    and (document_id is null or public.document_is_postable(document_id))
  );

drop policy if exists "formation_quizzes_write" on public.formation_quizzes;
create policy "formation_quizzes_write" on public.formation_quizzes
  for all using (public.can_edit_path(path_id)) with check (public.can_edit_path(path_id));

drop policy if exists "formation_quiz_questions_select" on public.formation_quiz_questions;
create policy "formation_quiz_questions_select" on public.formation_quiz_questions
  for select using (
    exists (select 1 from public.formation_quizzes q where q.id = quiz_id and public.can_edit_path(q.path_id))
  );
drop policy if exists "formation_quiz_questions_write" on public.formation_quiz_questions;
create policy "formation_quiz_questions_write" on public.formation_quiz_questions
  for all using (
    exists (select 1 from public.formation_quizzes q where q.id = quiz_id and public.can_edit_path(q.path_id))
  )
  with check (
    exists (select 1 from public.formation_quizzes q where q.id = quiz_id and public.can_edit_path(q.path_id))
  );

-- ============================================================================
-- 5. Downstream functions/policies that also gated on "is this the owner (or Coordinator)?" as
--    a proxy for "manages this path" - extended the same way so a co-author does not hit a wall
--    the UI otherwise implies they can walk through (quiz participation, enrollee list, the
--    students' chat channel).
-- ============================================================================
create or replace function public.is_formation_quiz_participant(pid bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.can_edit_path(pid) or public.formation_is_enrolled(pid);
$$;

drop policy if exists "formation_quiz_attempts_select" on public.formation_quiz_attempts;
create policy "formation_quiz_attempts_select" on public.formation_quiz_attempts
  for select using (
    user_id = auth.uid()
    or exists (select 1 from public.formation_quizzes q where q.id = quiz_id and public.can_edit_path(q.path_id))
  );

drop policy if exists "formation_certificates_select" on public.formation_certificates;
create policy "formation_certificates_select" on public.formation_certificates
  for select using (user_id = auth.uid() or public.can_edit_path(path_id));

create or replace function public.formation_enrollees(pid bigint)
returns table (user_id uuid, full_name text, email text, enrolled_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select up.user_id, up.full_name, up.email, fe.enrolled_at
  from public.formation_enrollments fe
  join public.user_profiles up on up.user_id = fe.user_id
  where fe.path_id = pid
    and fe.withdrawn_at is null
    and public.can_edit_path(pid)
  order by fe.enrolled_at;
$$;

drop policy if exists "formation_chat_select" on public.formation_chat_messages;
create policy "formation_chat_select" on public.formation_chat_messages
  for select using (
    (channel = 'students' and (public.formation_is_enrolled(path_id) or public.can_edit_path(path_id)))
    or
    (channel = 'formatori' and (public.is_any_formatore() or public.current_role_is('coordinator')))
  );
drop policy if exists "formation_chat_insert" on public.formation_chat_messages;
create policy "formation_chat_insert" on public.formation_chat_messages
  for insert with check (
    user_id = auth.uid()
    and (
      (channel = 'students' and (public.formation_is_enrolled(path_id) or public.can_edit_path(path_id)))
      or
      (channel = 'formatori' and (public.is_any_formatore() or public.current_role_is('coordinator')))
    )
  );

-- ============================================================================
-- 6. Self-test. All rows must be true.
-- ============================================================================
select 'table formation_path_editors' as item, to_regclass('public.formation_path_editors') is not null as ok
union all select 'fn can_edit_path', to_regproc('public.can_edit_path') is not null
union all select 'fn check_formation_path_publish', to_regproc('public.check_formation_path_publish') is not null
union all select 'trigger publish guard', exists (select 1 from pg_trigger where tgname = 'trg_formation_path_publish_guard')
union all select 'policies formation_path_editors (2)', (select count(*) = 2 from pg_policies where tablename = 'formation_path_editors')
union all select 'formation_paths_update uses can_edit_path', exists (select 1 from pg_policies where tablename = 'formation_paths' and policyname = 'formation_paths_update' and qual ilike '%can_edit_path%')
union all select 'formation_quiz_questions_select uses can_edit_path', exists (select 1 from pg_policies where tablename = 'formation_quiz_questions' and policyname = 'formation_quiz_questions_select' and qual ilike '%can_edit_path%')
union all select 'formation_posts_write keeps document_is_postable check', exists (select 1 from pg_policies where tablename = 'formation_posts' and policyname = 'formation_posts_write' and with_check ilike '%document_is_postable%');
