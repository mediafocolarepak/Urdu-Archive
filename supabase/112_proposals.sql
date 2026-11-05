-- 112_proposals.sql
-- Fase 3 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md (Owner's decisions of 2026-11-05).
-- One door for new content. A team member fills in a proposal with one or more versions (one per
-- language). Each version is an ordinary documents row in the new hidden status 'proposed'; the
-- proposal itself is a thin envelope, so the review makes one decision on the whole package.
--
--   draft -> submitted -> published, or rejected, or to_correct -> submitted ...
--
-- Rules:
--   - A Revisor or Coordinator approves, and that alone publishes. Nobody approves their own, except
--     Admin during development (GOVERNANCE.md §1 principle 3).
--   - Reserved content is reviewed only by Formation members and Admin.
--   - Whoever proposes always sees the state and can send a reminder. Reviewers always see the queue.
--     Times are computed from dates on each read, so no scheduled job is needed.
--   - No credits here: whoever wants a compensation agrees with the team first, and works a task.
--
-- Every change goes through the functions below, in one transaction, so a proposal is never half
-- saved. Run after 111. Safe to re-run. It adds new things and changes no existing document.

-- ============================================================================
-- 1. Tables
-- ============================================================================
create table if not exists public.archive_submissions (
  id               bigint generated always as identity primary key,
  proposer_id      uuid references auth.users(id) on delete set null,
  proposer_email   text,
  status           text not null default 'draft'
                   check (status in ('draft', 'submitted', 'to_correct', 'published', 'rejected', 'discarded')),
  title            text,
  common           jsonb not null default '{}'::jsonb, -- the shared fields of the form, as saved
  work_id          bigint,
  is_reserved      boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  submitted_at     timestamptz,
  claimed_by       uuid references auth.users(id) on delete set null,
  claimed_at       timestamptz,
  reminder_count   integer not null default 0,
  last_reminder_at timestamptz,
  decided_by_email text,
  decided_at       timestamptz,
  decision_note    text
);
create index if not exists idx_archive_submissions_status on public.archive_submissions (status, submitted_at);
create index if not exists idx_archive_submissions_proposer on public.archive_submissions (proposer_id, created_at desc);

create table if not exists public.submission_events (
  id            bigint generated always as identity primary key,
  submission_id bigint not null references public.archive_submissions(id) on delete cascade,
  at            timestamptz not null default now(),
  actor_email   text,
  event         text not null,
  note          text
);
create index if not exists idx_submission_events_submission on public.submission_events (submission_id, at);

-- No rules: both tables are reached only through the functions below.
alter table public.archive_submissions enable row level security;
alter table public.submission_events enable row level security;

drop trigger if exists archive_submissions_log_change on public.archive_submissions;
create trigger archive_submissions_log_change
  after insert or update or delete on public.archive_submissions
  for each row execute function public.log_archive_change('id');

alter table public.documents add column if not exists source_submission_id bigint references public.archive_submissions(id) on delete set null;
alter table public.documents add column if not exists on_drive_at timestamptz;
create index if not exists idx_documents_source_submission on public.documents (source_submission_id) where source_submission_id is not null;

insert into public.option_lists (list_name, code, label, sort_order) values
  ('workflow_status', 'proposed', 'Proposed (awaiting review)', 5)
on conflict (list_name, code) do nothing;

-- ============================================================================
-- 2. Who can do what
-- ============================================================================
create or replace function public.can_review_submissions()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
      or public.can_manage_reserved();
$$;

create or replace function public.can_review_submission(p_id bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('admin') or exists (
    select 1 from public.archive_submissions s
    where s.id = p_id
      and s.proposer_id is distinct from auth.uid()
      and case when s.is_reserved then public.can_manage_reserved()
               else public.current_role_is('coordinator')
                    or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
          end
  );
$$;

create or replace function public.can_read_proposal(p_id bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.can_review_submission(p_id)
      or exists (select 1 from public.archive_submissions s where s.id = p_id and s.proposer_id = auth.uid());
$$;

create or replace function public.document_is_proposed(p_document_id integer)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.documents d where d.document_id = p_document_id and d.workflow_status = 'proposed');
$$;

-- Same rule that is live today (110), plus the proposals.
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
    or (workflow_status = 'proposed' and public.can_read_proposal(source_submission_id))
  )
);

-- A proposal's text and collections change only through its functions, not by direct writes.
do $$
declare
  t text;
begin
  foreach t in array array['document_texts', 'document_original_texts', 'process_history', 'document_collections'] loop
    execute format('drop policy if exists "proposed_guard_insert" on public.%I', t);
    execute format('create policy "proposed_guard_insert" on public.%I as restrictive for insert to authenticated with check (not public.document_is_proposed(document_id))', t);
    execute format('drop policy if exists "proposed_guard_update" on public.%I', t);
    execute format('create policy "proposed_guard_update" on public.%I as restrictive for update to authenticated using (not public.document_is_proposed(document_id)) with check (not public.document_is_proposed(document_id))', t);
    execute format('drop policy if exists "proposed_guard_delete" on public.%I', t);
    execute format('create policy "proposed_guard_delete" on public.%I as restrictive for delete to authenticated using (not public.document_is_proposed(document_id))', t);
  end loop;
end;
$$;

-- A file attached to a proposal is readable only by those who can read the proposal.
create or replace function public.storage_file_ok(p_name text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select (public.has_reserved_access()
          or not exists (select 1 from public.documents d
                          where d.access_level = 'reserved'
                            and (d.storage_path = p_name or d.draft_inp_path = p_name)))
     and not exists (select 1 from public.documents d
                      where d.workflow_status = 'proposed'
                        and d.draft_inp_path = p_name
                        and not public.can_read_proposal(d.source_submission_id));
$$;

-- Builds on 110 and 111. The functions below set a flag only they can set: the app's API cannot call
-- set_config(), and each call to them is one transaction.
create or replace function public.guard_document_visibility()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task_level text;
  v_op boolean := coalesce(current_setting('dua.submission_op', true), '') = 'on';
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
    if new.workflow_status = 'proposed' and not v_op then
      raise exception 'A proposal is added through the proposal form.';
    end if;
    if new.workflow_status is distinct from 'revision' and new.workflow_status is distinct from 'proposed' then
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

  if old.workflow_status = 'proposed' and not v_op then
    raise exception 'A proposal changes only through the proposal form and its review.';
  end if;
  if public.document_status_is_visible(new.workflow_status) <> public.document_status_is_visible(old.workflow_status) and not v_op then
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

-- ============================================================================
-- 3. Filling in a proposal
-- ============================================================================
create or replace function public.submission_event(p_id bigint, p_event text, p_note text default null)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.submission_events (submission_id, actor_email, event, note)
  values (p_id, (select email from public.user_roles where user_id = auth.uid()), p_event, nullif(btrim(p_note), ''));
$$;

-- p_payload: { common: {...}, work_id: number|null, versions: [{ document_id, language, original_title,
-- body, draft_path, pages, access_level }] }. Only these fields are read: nothing else can be set.
create or replace function public.save_submission(p_id bigint, p_payload jsonb)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id      bigint := p_id;
  s         public.archive_submissions%rowtype;
  c         jsonb := coalesce(p_payload -> 'common', '{}'::jsonb);
  v         jsonb;
  v_email   text;
  v_title   text := nullif(btrim(c ->> 'en_title'), '');
  v_work    bigint := nullif(p_payload ->> 'work_id', '')::bigint;
  v_doc     integer;
  v_keep    integer[] := array[]::integer[];
  v_level   text;
  v_lang    text;
  v_orig    text;
  v_body    text;
  v_rec     text[];
begin
  if not public.current_role_is('operator') then
    raise exception 'Only team members can propose content.';
  end if;
  perform set_config('dua.submission_op', 'on', true);
  select email into v_email from public.user_roles where user_id = auth.uid();

  if v_id is null then
    insert into public.archive_submissions (proposer_id, proposer_email) values (auth.uid(), v_email)
    returning id into v_id;
    perform public.submission_event(v_id, 'created');
  end if;

  select * into s from public.archive_submissions where id = v_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if s.proposer_id is distinct from auth.uid() and not public.current_role_is('admin') then
    raise exception 'This proposal belongs to someone else.';
  end if;
  if s.status not in ('draft', 'to_correct') then
    raise exception 'This proposal can no longer be changed.';
  end if;

  if v_work is not null then
    if not exists (select 1 from public.works w where w.work_id = v_work) or not public.work_reserved_ok(v_work) then
      raise exception 'That Work was not found.';
    end if;
  else
    -- new_work: the person removed a link they had chosen, so this is a new work after all.
    v_work := case when coalesce((p_payload ->> 'new_work')::boolean, false) then null else s.work_id end;
    if v_work is null then
      insert into public.works (canonical_title) values (v_title) returning work_id into v_work;
    end if;
  end if;

  v_rec := case when nullif(c ->> 'recipient', '') is null then null else array[c ->> 'recipient'] end;

  for v in select * from jsonb_array_elements(coalesce(p_payload -> 'versions', '[]'::jsonb)) loop
    v_doc := nullif(v ->> 'document_id', '')::integer;
    v_level := coalesce(nullif(v ->> 'access_level', ''), 'private');
    v_lang := nullif(v ->> 'language', '');
    v_orig := nullif(btrim(v ->> 'original_title'), '');
    v_body := nullif(btrim(v ->> 'body'), '');

    if v_doc is not null then
      if not exists (select 1 from public.documents d where d.document_id = v_doc and d.source_submission_id = v_id) then
        raise exception 'That version does not belong to this proposal.';
      end if;
    else
      v_doc := nextval('public.document_id_seq')::integer;
      insert into public.documents (document_id, workflow_status, source_submission_id, legacy_migrated, is_preferred, media_type, access_level)
      values (v_doc, 'proposed', v_id, false, false, 'DOC', v_level);
    end if;

    update public.documents set
      title = coalesce(v_title, v_orig),
      en_title = v_title,
      original_title = v_orig,
      ur_title = case when v_lang = 'URD' then v_orig end,
      language = v_lang,
      work_id = v_work,
      access_level = v_level,
      category = nullif(c ->> 'category', ''),
      author = nullif(c ->> 'author', ''),
      original_author = nullif(btrim(c ->> 'original_author'), ''),
      ref_date = nullif(c ->> 'ref_date', '')::date,
      ref_period = nullif(btrim(c ->> 'ref_period'), ''),
      recipient = v_rec,
      main_topic = nullif(c ->> 'main_topic', ''),
      secondary_tags = nullif(btrim(c ->> 'secondary_tags'), ''),
      bible_verse = nullif(btrim(c ->> 'bible_verse'), ''),
      place = nullif(btrim(c ->> 'place'), ''),
      draft_inp_path = coalesce(nullif(v ->> 'draft_path', ''), draft_inp_path),
      pages = coalesce(nullif(v ->> 'pages', '')::integer, pages),
      catalog_date = current_date
    where document_id = v_doc;

    if v_body is not null then
      insert into public.document_texts (document_id, body, source, updated_by_email)
      values (v_doc, v_body, 'typed', v_email)
      on conflict (document_id) do update set body = excluded.body, updated_by_email = excluded.updated_by_email;
    else
      delete from public.document_texts where document_id = v_doc;
    end if;

    v_keep := v_keep || v_doc;
  end loop;

  -- A version taken out of the form was only ever a hidden draft: the log keeps what it held.
  delete from public.documents d where d.source_submission_id = v_id and not (d.document_id = any (v_keep));

  update public.archive_submissions set
    title = coalesce(v_title, title),
    common = c,
    work_id = v_work,
    is_reserved = exists (select 1 from public.documents d where d.source_submission_id = v_id and d.access_level = 'reserved'),
    updated_at = now()
  where id = v_id;

  return v_id;
end;
$$;

-- Null when the proposal is complete, otherwise what is missing.
create or replace function public.submission_problem(p_id bigint)
returns text
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  select * into s from public.archive_submissions where id = p_id;
  if nullif(btrim(s.common ->> 'en_title'), '') is null then return 'Please give an English title.'; end if;
  if nullif(s.common ->> 'category', '') is null then return 'Please choose a category.'; end if;
  if nullif(s.common ->> 'author', '') is null then return 'Please choose an author.'; end if;
  if nullif(s.common ->> 'ref_date', '') is null and nullif(btrim(s.common ->> 'ref_period'), '') is null then
    return 'Please give a date or a period.';
  end if;
  if not exists (select 1 from public.documents d where d.source_submission_id = p_id) then
    return 'Please add at least one version.';
  end if;
  if exists (select 1 from public.documents d where d.source_submission_id = p_id and (d.language is null or d.original_title is null)) then
    return 'Each version needs a language and its title in that language.';
  end if;
  if exists (select 1 from public.documents d where d.source_submission_id = p_id
              and d.draft_inp_path is null
              and not exists (select 1 from public.document_texts t where t.document_id = d.document_id)) then
    return 'Each version needs its text or a file.';
  end if;
  return null;
end;
$$;

create or replace function public.submit_submission(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
  v_problem text;
begin
  select * into s from public.archive_submissions where id = p_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if s.proposer_id is distinct from auth.uid() and not public.current_role_is('admin') then
    raise exception 'This proposal belongs to someone else.';
  end if;
  if s.status not in ('draft', 'to_correct') then raise exception 'This proposal has already been sent.'; end if;
  v_problem := public.submission_problem(p_id);
  if v_problem is not null then raise exception '%', v_problem; end if;

  update public.archive_submissions
  set status = 'submitted', submitted_at = now(), claimed_by = null, claimed_at = null,
      reminder_count = 0, last_reminder_at = null, decision_note = null, updated_at = now()
  where id = p_id;
  perform public.submission_event(p_id, case when s.status = 'to_correct' then 'resubmitted' else 'submitted' end);
end;
$$;

-- Back to draft, as long as no reviewer has it.
create or replace function public.withdraw_submission(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  select * into s from public.archive_submissions where id = p_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if s.proposer_id is distinct from auth.uid() and not public.current_role_is('admin') then
    raise exception 'This proposal belongs to someone else.';
  end if;
  if s.status <> 'submitted' then raise exception 'This proposal is not awaiting review.'; end if;
  if s.claimed_by is not null and s.claimed_at > now() - interval '48 hours' then
    raise exception 'A reviewer is working on this proposal.';
  end if;
  update public.archive_submissions set status = 'draft', claimed_by = null, claimed_at = null, updated_at = now() where id = p_id;
  perform public.submission_event(p_id, 'withdrawn');
end;
$$;

create or replace function public.discard_submission(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  perform set_config('dua.submission_op', 'on', true);
  select * into s from public.archive_submissions where id = p_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if s.proposer_id is distinct from auth.uid() and not public.current_role_is('admin') then
    raise exception 'This proposal belongs to someone else.';
  end if;
  if s.status not in ('draft', 'to_correct') then raise exception 'This proposal cannot be discarded now.'; end if;
  delete from public.documents d where d.source_submission_id = p_id and d.workflow_status = 'proposed';
  update public.archive_submissions set status = 'discarded', updated_at = now() where id = p_id;
  perform public.submission_event(p_id, 'discarded');
end;
$$;

-- At most one every 3 days, and only after 3 days of waiting. It reaches the whole queue, not a person.
create or replace function public.send_submission_reminder(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  select * into s from public.archive_submissions where id = p_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if s.proposer_id is distinct from auth.uid() then raise exception 'Only the person who proposed it can send a reminder.'; end if;
  if s.status <> 'submitted' then raise exception 'This proposal is not awaiting review.'; end if;
  if s.submitted_at > now() - interval '3 days' or s.last_reminder_at > now() - interval '3 days' then
    raise exception 'A reminder can be sent after 3 days of waiting, and once every 3 days.';
  end if;
  update public.archive_submissions set reminder_count = reminder_count + 1, last_reminder_at = now() where id = p_id;
  perform public.submission_event(p_id, 'reminder');
end;
$$;

-- ============================================================================
-- 4. Reviewing
-- ============================================================================
-- Taking a proposal holds it for 48 hours; then it goes back to the queue by itself.
create or replace function public.claim_submission(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  select * into s from public.archive_submissions where id = p_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if not public.can_review_submission(p_id) then raise exception 'You cannot review this proposal.'; end if;
  if s.status <> 'submitted' then raise exception 'This proposal is not awaiting review.'; end if;
  if s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours'
     and not public.current_role_is('admin') then
    raise exception 'Another reviewer is working on this proposal.';
  end if;
  update public.archive_submissions set claimed_by = auth.uid(), claimed_at = now() where id = p_id;
  perform public.submission_event(p_id, 'claimed');
end;
$$;

create or replace function public.release_submission(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.archive_submissions set claimed_by = null, claimed_at = null
  where id = p_id and status = 'submitted' and (claimed_by = auth.uid() or public.current_role_is('admin'));
  if not found then raise exception 'You are not working on this proposal.'; end if;
  perform public.submission_event(p_id, 'released');
end;
$$;

-- Internal: everything a decision has in common.
create or replace function public.submission_for_decision(p_id bigint)
returns public.archive_submissions
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  select * into s from public.archive_submissions where id = p_id for update;
  if s is null then raise exception 'Proposal not found.'; end if;
  if not public.can_review_submission(p_id) then raise exception 'You cannot review this proposal.'; end if;
  if s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours'
     and not public.current_role_is('admin') then
    raise exception 'Another reviewer is working on this proposal.';
  end if;
  return s;
end;
$$;

-- Publishes every version at once. Admin may also publish directly, from a draft.
-- p_read_document_ids: the versions whose text the reviewer has read against the source. Only those
-- are marked reviewed; the others stay unverified.
create or replace function public.approve_submission(p_id bigint, p_read_document_ids integer[] default null, p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
  v_problem text;
  v_email text;
  d record;
  v_slug text;
begin
  perform set_config('dua.submission_op', 'on', true);
  s := public.submission_for_decision(p_id);
  if s.status <> 'submitted' and not (public.current_role_is('admin') and s.status in ('draft', 'to_correct')) then
    raise exception 'This proposal is not awaiting review.';
  end if;
  v_problem := public.submission_problem(p_id);
  if v_problem is not null then raise exception '%', v_problem; end if;
  select email into v_email from public.user_roles where user_id = auth.uid();

  for d in select * from public.documents x where x.source_submission_id = p_id and x.workflow_status = 'proposed' order by x.document_id loop
    -- The star is one per Work, language and format: a new Urdu version must not take it from Italian.
    update public.documents set is_preferred = false
    where work_id = d.work_id and document_id <> d.document_id and is_preferred
      and language is not distinct from d.language and media_type is not distinct from d.media_type;

    v_slug := lower(coalesce(d.en_title, d.title, 'untitled'));
    v_slug := regexp_replace(v_slug, '[''".,;:!?()]', '', 'g');
    v_slug := btrim(regexp_replace(v_slug, '[^a-z0-9]+', '-', 'g'), '-');
    v_slug := coalesce(nullif(left(v_slug, 30), ''), 'untitled');

    update public.documents set
      workflow_status = 'published',
      is_preferred = true,
      storage_path = case when draft_inp_path is not null then draft_inp_path else storage_path end,
      file_name = case when draft_inp_path is not null then lpad(document_id::text, 5, '0') || '-' || v_slug || '.pdf' else file_name end
    where document_id = d.document_id;
  end loop;

  update public.document_texts t
  set reviewed = true, reviewed_at = now(), reviewed_by_email = v_email
  where t.document_id = any (coalesce(p_read_document_ids, array[]::integer[]))
    and exists (select 1 from public.documents x where x.document_id = t.document_id and x.source_submission_id = p_id);

  update public.archive_submissions
  set status = 'published', decided_by_email = v_email, decided_at = now(),
      decision_note = nullif(btrim(p_note), ''), claimed_by = null, claimed_at = null, updated_at = now()
  where id = p_id;
  perform public.submission_event(p_id, 'published', p_note);
end;
$$;

create or replace function public.send_back_submission(p_id bigint, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
begin
  s := public.submission_for_decision(p_id);
  if s.status <> 'submitted' then raise exception 'This proposal is not awaiting review.'; end if;
  if nullif(btrim(p_note), '') is null then raise exception 'Please say what needs correcting.'; end if;
  update public.archive_submissions
  set status = 'to_correct', decision_note = btrim(p_note), decided_at = now(),
      claimed_by = null, claimed_at = null, updated_at = now()
  where id = p_id;
  perform public.submission_event(p_id, 'sent_back', p_note);
end;
$$;

create or replace function public.reject_submission(p_id bigint, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
  v_email text;
begin
  perform set_config('dua.submission_op', 'on', true);
  s := public.submission_for_decision(p_id);
  if s.status <> 'submitted' then raise exception 'This proposal is not awaiting review.'; end if;
  if nullif(btrim(p_note), '') is null then raise exception 'Please give a reason.'; end if;
  select email into v_email from public.user_roles where user_id = auth.uid();
  update public.documents set workflow_status = 'removed' where source_submission_id = p_id and workflow_status = 'proposed';
  update public.archive_submissions
  set status = 'rejected', decision_note = btrim(p_note), decided_by_email = v_email, decided_at = now(),
      claimed_by = null, claimed_at = null, updated_at = now()
  where id = p_id;
  perform public.submission_event(p_id, 'rejected', p_note);
end;
$$;

-- ============================================================================
-- 5. Lists
-- ============================================================================
create or replace function public.get_my_submissions()
returns table (id bigint, title text, status text, created_at timestamptz, submitted_at timestamptz, days_waiting integer,
               decision_note text, version_count integer, reminder_allowed boolean, next_reminder_at timestamptz,
               reminder_count integer, in_review boolean)
language sql
security definer
stable
set search_path = public
as $$
  select s.id, s.title, s.status, s.created_at, s.submitted_at,
         case when s.status = 'submitted' then extract(day from now() - s.submitted_at)::integer end,
         s.decision_note,
         (select count(*)::integer from public.documents d where d.source_submission_id = s.id),
         s.status = 'submitted' and s.submitted_at <= now() - interval '3 days'
           and (s.last_reminder_at is null or s.last_reminder_at <= now() - interval '3 days'),
         case when s.status = 'submitted' then greatest(s.submitted_at, coalesce(s.last_reminder_at, s.submitted_at)) + interval '3 days' end,
         s.reminder_count,
         s.claimed_by is not null and s.claimed_at > now() - interval '48 hours'
  from public.archive_submissions s
  where s.proposer_id = auth.uid() and s.status <> 'discarded'
  order by coalesce(s.submitted_at, s.created_at) desc;
$$;

-- Oldest first. Who proposed it is not returned, as for task reviews.
create or replace function public.get_submission_queue()
returns table (id bigint, title text, is_reserved boolean, submitted_at timestamptz, days_waiting integer, overdue boolean,
               version_count integer, languages text, mine boolean, claimed_by_me boolean, claimed_by_other boolean,
               reminder_count integer, last_reminder_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select s.id, s.title, s.is_reserved, s.submitted_at,
         extract(day from now() - s.submitted_at)::integer,
         s.submitted_at <= now() - interval '7 days',
         (select count(*)::integer from public.documents d where d.source_submission_id = s.id),
         (select string_agg(d.language, ', ' order by d.language) from public.documents d where d.source_submission_id = s.id),
         s.proposer_id = auth.uid(),
         s.claimed_by = auth.uid() and s.claimed_at > now() - interval '48 hours',
         s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours',
         s.reminder_count, s.last_reminder_at
  from public.archive_submissions s
  where s.status = 'submitted' and public.can_review_submission(s.id)
  order by s.submitted_at;
$$;

create or replace function public.get_submission_counts()
returns table (to_review integer, reminded integer, overdue integer, to_correct integer)
language sql
security definer
stable
set search_path = public
as $$
  select
    (select count(*)::integer from public.archive_submissions s where s.status = 'submitted' and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.status = 'submitted' and s.reminder_count > 0 and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.status = 'submitted' and s.submitted_at <= now() - interval '7 days' and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.status = 'to_correct' and s.proposer_id = auth.uid());
$$;

-- Everything the form or the review screen needs. Reviewers do not get the proposer's name;
-- only Admin sees names in the history.
create or replace function public.get_submission_detail(p_id bigint)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
  v_admin boolean := public.current_role_is('admin');
begin
  select * into s from public.archive_submissions where id = p_id;
  if s is null or not public.can_read_proposal(p_id) then raise exception 'Proposal not found.'; end if;
  return jsonb_build_object(
    'id', s.id, 'status', s.status, 'title', s.title, 'common', s.common, 'work_id', s.work_id,
    'is_reserved', s.is_reserved, 'submitted_at', s.submitted_at, 'decision_note', s.decision_note,
    'mine', s.proposer_id = auth.uid(),
    'proposer_email', case when v_admin then s.proposer_email end,
    'can_review', public.can_review_submission(p_id),
    'claimed_by_me', s.claimed_by = auth.uid() and s.claimed_at > now() - interval '48 hours',
    'claimed_by_other', s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours',
    'problem', public.submission_problem(p_id),
    'versions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'document_id', d.document_id, 'language', d.language, 'original_title', d.original_title,
        'access_level', d.access_level, 'draft_path', d.draft_inp_path, 'pages', d.pages,
        'body', (select t.body from public.document_texts t where t.document_id = d.document_id)
      ) order by d.document_id)
      from public.documents d where d.source_submission_id = p_id), '[]'::jsonb),
    'work_documents', coalesce((
      select jsonb_agg(jsonb_build_object('document_id', d.document_id, 'title', coalesce(d.en_title, d.title), 'language', d.language) order by d.document_id)
      from public.documents d
      where d.work_id = s.work_id and d.source_submission_id is distinct from p_id and d.deleted_at is null
        and public.document_status_is_visible(d.workflow_status) and public.document_reserved_ok(d.document_id)), '[]'::jsonb),
    'events', coalesce((
      select jsonb_agg(jsonb_build_object('at', e.at, 'event', e.event, 'note', e.note,
                                          'actor', case when v_admin then e.actor_email end) order by e.at, e.id)
      from public.submission_events e where e.submission_id = p_id), '[]'::jsonb)
  );
end;
$$;

-- ============================================================================
-- 6. PDFs still to be copied to Drive (the app opens PDFs from there)
-- ============================================================================
create or replace function public.get_documents_for_drive()
returns table (document_id integer, title text, language text, file_name text, storage_path text, access_level text)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then raise exception 'Only Admin can see this list.'; end if;
  return query
    select d.document_id, coalesce(d.en_title, d.title), d.language, d.file_name, d.storage_path, d.access_level
    from public.documents d
    where d.source_submission_id is not null and d.storage_path is not null and d.file_name is not null
      and d.on_drive_at is null and d.deleted_at is null and d.workflow_status = 'published'
    order by d.document_id;
end;
$$;

create or replace function public.mark_document_on_drive(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then raise exception 'Only Admin can do this.'; end if;
  -- The Supabase copy goes next, to keep within the free plan's space, so nothing may point at it.
  update public.documents set on_drive_at = now(), storage_path = null, draft_inp_path = null
  where document_id = p_document_id and on_drive_at is null;
end;
$$;

-- ============================================================================
-- 7. Verification: every row must say true.
-- ============================================================================
select 'tables in place, closed to direct access' as item,
  (select count(*) = 2 from pg_class where relname in ('archive_submissions', 'submission_events') and relrowsecurity) as ok
union all select 'no existing document was touched',
  not exists (select 1 from public.documents where workflow_status = 'proposed' or source_submission_id is not null)
union all select 'read rule includes proposals',
  (select qual like '%can_read_proposal%' from pg_policies where tablename = 'documents' and policyname = 'read - documents')
union all select 'still hides deleted documents',
  (select qual like '%deleted_at IS NULL%' from pg_policies where tablename = 'documents' and policyname = 'read - documents')
union all select 'guard knows proposals',
  (select prosrc like '%dua.submission_op%' from pg_proc where proname = 'guard_document_visibility')
union all select 'proposal text cannot be changed directly',
  (select count(*) = 12 from pg_policies where policyname like 'proposed\_guard\_%' and schemaname = 'public')
union all select 'proposals are logged',
  exists (select 1 from pg_trigger where tgname = 'archive_submissions_log_change');
