-- 84_boards_moderation.sql
-- GOVERNANCE.md §2.6 / PROJECT_HANDOFF_v23.md §3.4 (Fase 2c): boards open up from "formatori
-- post, everyone reads" to "everyone posts, formatori moderate". Operators (and Coordinator/
-- Admin) still publish straight through, exactly as before; a plain User's post is held
-- 'pending' until a board editor (or Coordinator/Admin) publishes or rejects it. Note this
-- migration is numbered 84, not 83 as PROJECT_HANDOFF_v22's original roadmap sketch had it -
-- 82/83 were used by the formation co-authors work (session of 16-17/09/2026) first.
--
-- Run after 83_formation_ai_prompt_help.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. New columns on board_posts: a link and/or an image alongside (or instead of) body text,
--    and the moderation state. default 'published' so every EXISTING row (all formatore-posted,
--    trusted content) keeps behaving exactly as before this migration.
-- ============================================================================
alter table public.board_posts add column if not exists link_url text;
alter table public.board_posts add column if not exists image_path text;
alter table public.board_posts add column if not exists status text not null default 'published'
  check (status in ('pending', 'published', 'rejected'));
alter table public.board_posts add column if not exists moderated_by_email text;
alter table public.board_posts add column if not exists moderated_at timestamptz;
alter table public.board_posts add column if not exists moderation_note text;

-- A post now only needs ONE of document/body/link/image, not specifically document-or-body.
alter table public.board_posts drop constraint if exists board_posts_has_content;
alter table public.board_posts add constraint board_posts_has_content check (
  document_id is not null or link_url is not null or image_path is not null
  or (body is not null and btrim(body) <> '')
);

-- ============================================================================
-- 2. Who is blocked from posting - a column, not a `standing` value (GOVERNANCE.md §8.1
--    decision log: a User can be both `watch` and blocked, two independent axes).
-- ============================================================================
alter table public.user_roles add column if not exists board_posting_blocked boolean not null default false;

-- ============================================================================
-- 3. When someone other than a User has already acknowledged the board usage policy - shown
--    once before their first post (js/boards.js). A column on user_profiles, not a new table
--    (GOVERNANCE.md phase-1 default: only add a table when a column can't say it).
-- ============================================================================
alter table public.user_profiles add column if not exists board_policy_ack_at timestamptz;

-- ============================================================================
-- 4. Storage bucket for post images. 5 MB cap per file; public read (board posts are, once
--    published, visible to the whole team anyway - same openness as the archive's own files).
-- ============================================================================
insert into storage.buckets (id, name, public, file_size_limit)
values ('board-media', 'board-media', true, 5242880)
on conflict (id) do nothing;

drop policy if exists "read - board-media" on storage.objects;
drop policy if exists "upload - board-media" on storage.objects;
drop policy if exists "delete - board-media" on storage.objects;
create policy "read - board-media" on storage.objects for select
  using (bucket_id = 'board-media');
create policy "upload - board-media" on storage.objects for insert
  to authenticated with check (bucket_id = 'board-media' and current_role_is('user'));
create policy "delete - board-media" on storage.objects for delete
  to authenticated using (bucket_id = 'board-media' and current_role_is('coordinator'));

-- ============================================================================
-- 5. A new post from anyone other than a board editor or Operator+ is forced to 'pending',
--    regardless of what the client sent - the client never gets to declare its own post
--    pre-approved. current_role_is('operator') already covers coordinator/admin too (05/22).
-- ============================================================================
create or replace function public.force_board_post_pending()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not (public.is_board_editor(new.board_code) or current_role_is('operator')) then
    new.status := 'pending';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_force_board_post_pending on public.board_posts;
create trigger trg_force_board_post_pending
  before insert on public.board_posts
  for each row execute function public.force_board_post_pending();

-- 6. Only a board editor (or Coordinator/Admin) may change the moderation fields - checked in a
--    trigger rather than just the update policy below, because the same policy also has to let
--    an author edit their own pending post's text without touching status. moderated_at is
--    stamped here too, so the client never has to (and can't fake it).
create or replace function public.check_board_post_moderation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (new.status is distinct from old.status
      or new.moderated_by_email is distinct from old.moderated_by_email
      or new.moderation_note is distinct from old.moderation_note)
     and not (public.is_board_editor(new.board_code) or current_role_is('coordinator')) then
    raise exception 'Only an editor of this board, or Coordinator/Admin, can moderate a post.';
  end if;
  if new.status is distinct from old.status then
    new.moderated_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_check_board_post_moderation on public.board_posts;
create trigger trg_check_board_post_moderation
  before update on public.board_posts
  for each row execute function public.check_board_post_moderation();

-- ============================================================================
-- 7. RLS. Insert is now open to any signed-in, non-blocked User (was: board editor/Coordinator
--    only) - the trigger above decides whether that lands published or pending. Select adds
--    "see your own pending/rejected post" and "editors/Coordinator see everything on their
--    board" on top of the existing "published is public" rule. Update keeps letting an author
--    fix their own post's text (trigger #6 still blocks them from self-moderating).
-- ============================================================================
drop policy if exists "board_posts_select" on public.board_posts;
create policy "board_posts_select" on public.board_posts
  for select using (
    current_role_is('user') and (
      status = 'published'
      or posted_by = auth.uid()
      or public.is_board_editor(board_code)
      or current_role_is('coordinator')
    )
  );

drop policy if exists "board_posts_insert" on public.board_posts;
create policy "board_posts_insert" on public.board_posts
  for insert with check (
    posted_by = auth.uid()
    and current_role_is('user')
    and not coalesce((select r.board_posting_blocked from public.user_roles r where r.user_id = auth.uid()), false)
    and (document_id is null or public.document_is_postable(document_id))
    and (link_url is null or link_url ~ '^https?://')
  );

drop policy if exists "board_posts_update" on public.board_posts;
create policy "board_posts_update" on public.board_posts
  for update
  using (current_role_is('coordinator') or public.is_board_editor(board_code) or posted_by = auth.uid())
  with check (
    (current_role_is('coordinator') or public.is_board_editor(board_code) or posted_by = auth.uid())
    and (document_id is null or public.document_is_postable(document_id))
    and (link_url is null or link_url ~ '^https?://')
  );

-- board_posts_delete (71) is unchanged: Coordinator/Admin, or the author if also that board's
-- editor - a plain User who submitted a pending post cannot delete it themselves (they can only
-- wait for an editor's Publish/Reject); this matches "removal with a reason" being a moderation
-- action, not a self-service one.

-- ============================================================================
-- 8. "Promote to archive" (js/boards.js) creates a documents row from a post's text - traceable
--    back to its origin, same idea as documents.source_task_id (45_document_revision_workflow.sql).
-- ============================================================================
alter table public.documents add column if not exists source_board_post_id bigint references public.board_posts(id) on delete set null;

-- ============================================================================
-- 9. board_block / board_unblock: same proposer/approver pair as board_misuse (GOVERNANCE.md
--    §1.1: "abuse penalised - reputation for an Operator, a posting stop for a User - proposed
--    by the editor, approved by the Formation lead or the HR lead"). Extends 80's three
--    functions and the people_decisions_type check + option list.
-- ============================================================================
alter table public.people_decisions drop constraint if exists people_decisions_type;
alter table public.people_decisions add constraint people_decisions_type check (decision_type in (
  'qualification_add', 'qualification_remove', 'watch_on', 'watch_off',
  'suspend', 'reinstate', 'exclude', 'role_change', 'board_misuse', 'board_block', 'board_unblock'));

insert into public.option_lists (list_name, code, label, sort_order) values
  ('people_decision_type', 'board_block',   'Block from posting on boards',   10),
  ('people_decision_type', 'board_unblock', 'Unblock from posting on boards', 11)
on conflict (list_name, code) do nothing;

create or replace function public.can_propose_people_decision(p_type text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select case
    when current_role_is('admin') then true
    when p_type in ('qualification_add', 'qualification_remove') then
      public.is_dept_member('HR') or current_role_is('coordinator')
    when p_type in ('watch_on', 'watch_off', 'suspend', 'reinstate', 'exclude') then
      public.is_dept_member('HR')
    when p_type = 'role_change' then
      public.is_dept_lead('HR')
    when p_type in ('board_misuse', 'board_block', 'board_unblock') then
      current_role_is('coordinator')
      or exists (select 1 from public.board_editors where user_id = auth.uid())
    else false
  end;
$$;

create or replace function public.can_approve_people_decision(p_type text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select case
    when current_role_is('admin') then true
    when p_type in ('suspend', 'reinstate') then public.is_dept_lead('HR')
    when p_type in ('board_misuse', 'board_block', 'board_unblock') then public.is_dept_lead('FORM') or public.is_dept_lead('HR')
    else false   -- qualification_*, exclude, role_change: Admin only
  end;
$$;

create or replace function public.apply_people_decision(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d      public.people_decisions%rowtype;
  v_role text;
  v_delta integer;
begin
  select * into d from public.people_decisions where id = p_id;
  if d is null then raise exception 'Decision not found.'; end if;

  if d.decision_type = 'qualification_add' then
    insert into public.user_qualifications (user_id, qualification_code)
    values (d.subject_user_id, d.payload->>'qualification_code')
    on conflict do nothing;

  elsif d.decision_type = 'qualification_remove' then
    delete from public.user_qualifications
    where user_id = d.subject_user_id and qualification_code = d.payload->>'qualification_code';

  elsif d.decision_type = 'watch_on' then
    update public.user_roles set standing = 'watch'
    where user_id = d.subject_user_id and standing = 'active';

  elsif d.decision_type = 'watch_off' then
    update public.user_roles set standing = 'active'
    where user_id = d.subject_user_id and standing = 'watch';

  elsif d.decision_type = 'suspend' then
    update public.user_roles set standing = 'suspended' where user_id = d.subject_user_id;

  elsif d.decision_type = 'reinstate' then
    update public.user_roles set standing = 'active' where user_id = d.subject_user_id;

  elsif d.decision_type = 'exclude' then
    update public.user_roles set role = 'user', standing = 'suspended' where user_id = d.subject_user_id;
    delete from public.department_members  where user_id = d.subject_user_id;
    delete from public.board_editors       where user_id = d.subject_user_id;
    delete from public.user_qualifications where user_id = d.subject_user_id;

  elsif d.decision_type = 'role_change' then
    v_role := d.payload->>'role';
    if v_role not in ('user', 'operator', 'coordinator', 'admin') then
      raise exception 'Invalid role in payload.';
    end if;
    update public.user_roles set role = v_role where user_id = d.subject_user_id;

  elsif d.decision_type = 'board_misuse' then
    v_delta := coalesce((d.payload->>'reputation_delta')::integer,
                        public.policy_value('board_misuse_reputation_delta', -10));
    if v_delta > 0 then raise exception 'A board misuse penalty cannot be positive.'; end if;
    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (null, d.subject_user_id, 'board_misuse', 0, v_delta, d.decided_by_email,
            'People decision #' || d.id || ': ' || d.reason);

  elsif d.decision_type = 'board_block' then
    update public.user_roles set board_posting_blocked = true where user_id = d.subject_user_id;

  elsif d.decision_type = 'board_unblock' then
    update public.user_roles set board_posting_blocked = false where user_id = d.subject_user_id;
  end if;
end;
$$;

-- ============================================================================
-- 10. Help: the board usage policy (js/boards.js shows the same wording in the first-post
--     consent modal - keep the two in sync). role = null: relevant to anyone who can post.
-- ============================================================================
insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('board_usage_policy_en', 'en', null, 'Boards: usage policy', $q_bup_en$
<title>Boards: usage policy</title>
<style>
  body { font-family: -apple-system, 'Public Sans', sans-serif; line-height: 1.5; padding: 16px; color: #26211d; }
  h2 { margin-top: 0; }
  ul { padding-left: 20px; }
</style>
<h2>Posting on a board</h2>
<p>Boards are a shared space for the group they belong to - not part of the archive, and not a
general chatroom. Before you post:</p>
<ul>
  <li>Keep it relevant to the group and in the spirit of the programme.</li>
  <li>No commercial promotion, no political campaigning, no content that wouldn't be appropriate to read aloud to the group.</li>
  <li>A post from a User is held for review by that board's editors before anyone else sees it; an Operator's post is published immediately.</li>
  <li>An editor can reject or remove a post, with a reason. Repeated misuse can lead to your reputation being reduced (if you are an Operator) or to being blocked from posting on boards (if you are a User) - both are decisions an editor proposes and a Formation or HR lead approves, never a single person acting alone.</li>
</ul>
$q_bup_en$, 7, now(), null)
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('board_usage_policy_it', 'it', null, 'Bacheche: policy d’uso', $q_bup_it$
<title>Bacheche: policy d'uso</title>
<style>
  body { font-family: -apple-system, 'Public Sans', sans-serif; line-height: 1.5; padding: 16px; color: #26211d; }
  h2 { margin-top: 0; }
  ul { padding-left: 20px; }
</style>
<h2>Pubblicare su una bacheca</h2>
<p>Le bacheche sono uno spazio condiviso per il gruppo a cui appartengono - non fanno parte
dell'archivio e non sono una chat generica. Prima di pubblicare:</p>
<ul>
  <li>Resta pertinente al gruppo e allo spirito del programma.</li>
  <li>Niente promozione commerciale, niente propaganda politica, niente contenuti che non si leggerebbero volentieri ad alta voce al gruppo.</li>
  <li>Un post di uno User resta in attesa di revisione degli editor di quella bacheca prima che chiunque altro lo veda; un post di un Operator viene pubblicato subito.</li>
  <li>Un editor puo' rifiutare o rimuovere un post, con un motivo. L'abuso ripetuto puo' portare a una riduzione della reputazione (per un Operator) o al blocco dalla pubblicazione sulle bacheche (per uno User) - entrambe decisioni che un editor propone e un lead Formation o HR approva, mai una persona sola.</li>
</ul>
$q_bup_it$, 7, now(), null)
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

-- ============================================================================
-- 11. Self-test. All rows must be true.
-- ============================================================================
select 'board_posts.status column' as item, exists (select 1 from information_schema.columns where table_name = 'board_posts' and column_name = 'status') as ok
union all select 'board_posts.link_url column', exists (select 1 from information_schema.columns where table_name = 'board_posts' and column_name = 'link_url')
union all select 'user_roles.board_posting_blocked', exists (select 1 from information_schema.columns where table_name = 'user_roles' and column_name = 'board_posting_blocked')
union all select 'user_profiles.board_policy_ack_at', exists (select 1 from information_schema.columns where table_name = 'user_profiles' and column_name = 'board_policy_ack_at')
union all select 'documents.source_board_post_id', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'source_board_post_id')
union all select 'storage bucket board-media', exists (select 1 from storage.buckets where id = 'board-media')
union all select 'trigger force pending', exists (select 1 from pg_trigger where tgname = 'trg_force_board_post_pending')
union all select 'trigger moderation guard', exists (select 1 from pg_trigger where tgname = 'trg_check_board_post_moderation')
union all select 'policies board_posts (4)', (select count(*) = 4 from pg_policies where tablename = 'board_posts')
union all select 'option list people_decision_type (11)', (select count(*) = 11 from option_lists where list_name = 'people_decision_type')
union all select 'help_pages board_usage_policy_en', exists (select 1 from help_pages where slug = 'board_usage_policy_en')
union all select 'help_pages board_usage_policy_it', exists (select 1 from help_pages where slug = 'board_usage_policy_it');
