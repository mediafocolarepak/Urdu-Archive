-- 115_monthly_package.sql
-- Fase 6 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md (Owner's decisions of 2026-11-05).
--   - The Word of Life of a month is one Work, found by its month rather than by guessing a title: Italian,
--     English, Urdu, video and audio, added together or one at a time.
--   - A magazine issue is a record of its own; what it contains points to it, with the page.
--   - Boards: a post goes to the archive through the proposal form, and anyone can suggest one.
--   - The star on task publications is per Work, language and format, as for proposals.
--   - Word of Life periods that also hold a page ('2001-04p.7') are cleaned. This is the one part that changes
--     existing documents: only that field, and every change is in archive_log with the old value.
--
-- Run after 114. Safe to re-run.

-- ============================================================================
-- 1. Columns
-- ============================================================================
alter table public.documents add column if not exists contained_in_document_id integer references public.documents(document_id) on delete set null;
alter table public.documents add column if not exists contained_page integer;
create index if not exists idx_documents_contained_in on public.documents (contained_in_document_id) where contained_in_document_id is not null;

alter table public.works add column if not exists series text;
alter table public.works add column if not exists series_period text;
create unique index if not exists idx_works_series_period on public.works (series, series_period) where series is not null;

insert into public.option_lists (list_name, code, label, sort_order) values
  ('category', 'MAG', 'Magazine issue', 12)
on conflict (list_name, code) do nothing;

-- ============================================================================
-- 2. Cleaning the periods
-- ============================================================================
-- The page must not be lost: where the issue field is empty, the old value goes there first.
update public.documents set hayat_issue = ref_period
where ref_period ~ '^[0-9]{4}-[0-9]{2}p\.[0-9]*$' and nullif(btrim(hayat_issue), '') is null;

update public.documents set ref_period = left(ref_period, 7)
where ref_period ~ '^[0-9]{4}-[0-9]{2}p\.[0-9]*$';

-- A Word of Life with no month at all, when the Hayat index knows it and no exact date says otherwise.
update public.documents d set ref_period = left(h.data_pdv, 7)
from public.hayat_indice h
where h.id::text = d.hayat_index_ref::text
  and nullif(btrim(d.ref_period), '') is null and d.ref_date is null
  and coalesce(h.data_pdv, '') ~ '^[0-9]{4}-[0-9]{2}';

-- ============================================================================
-- 3. The star, for what a task publishes
-- ============================================================================
-- As in 50, but a new Urdu version must not take the star from the Italian one (PROTOCOLLO §6.4).
create or replace function public.finalize_document_publish(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d public.documents%rowtype;
begin
  if not public.current_role_is('admin') then
    raise exception 'Only Admin can publish a document.';
  end if;
  select * into d from public.documents where document_id = p_document_id;
  if d.work_id is null then raise exception 'Document not found or has no work_id.'; end if;

  update public.documents set is_preferred = false
  where work_id = d.work_id and document_id <> p_document_id and is_preferred = true
    and language is not distinct from d.language
    and coalesce(media_type, 'DOC') = coalesce(d.media_type, 'DOC');

  update public.documents set workflow_status = 'published', is_preferred = true
  where document_id = p_document_id;
end;
$$;

-- ============================================================================
-- 4. The proposal form: contained in, and from which board post
-- ============================================================================
-- Same as 113, plus common.contained_in_document_id, common.contained_page, and each version's
-- source_board_post_id.
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
  v_media   text;
  v_link    text;
  v_audio   text;
  v_in      integer := nullif(c ->> 'contained_in_document_id', '')::integer;
  v_in_page integer := nullif(c ->> 'contained_page', '')::integer;
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

  if v_in is not null and not exists (
    select 1 from public.documents x where x.document_id = v_in and x.deleted_at is null
      and public.document_status_is_visible(x.workflow_status) and public.document_reserved_ok(x.document_id)
  ) then
    raise exception 'That magazine issue was not found.';
  end if;

  for v in select * from jsonb_array_elements(coalesce(p_payload -> 'versions', '[]'::jsonb)) loop
    v_doc := nullif(v ->> 'document_id', '')::integer;
    v_level := coalesce(nullif(v ->> 'access_level', ''), 'private');
    v_lang := nullif(v ->> 'language', '');
    v_orig := nullif(btrim(v ->> 'original_title'), '');
    v_media := coalesce(nullif(v ->> 'media_type', ''), 'DOC');
    if v_media not in ('DOC', 'VID', 'AUD') then
      raise exception 'Unknown format.';
    end if;
    -- Text and PDF belong to a written version; a reading or a video has neither.
    v_body := case when v_media = 'DOC' then nullif(btrim(v ->> 'body'), '') end;
    v_link := case when v_media = 'VID' then nullif(btrim(v ->> 'external_url'), '') end;
    if v_link is not null and not public.media_link_ok(v_link) then
      raise exception 'A video link must be an https link to YouTube or Google Drive.';
    end if;
    v_audio := case when v_media = 'AUD' then nullif(v ->> 'audio_path', '') end;
    if v_audio is not null and v_audio !~ '^[0-9a-f-]{36}\.(mp3|m4a|aac|ogg|webm)$' then
      raise exception 'That is not a valid recording.';
    end if;

    if v_doc is not null then
      if not exists (select 1 from public.documents d where d.document_id = v_doc and d.source_submission_id = v_id) then
        raise exception 'That version does not belong to this proposal.';
      end if;
    else
      v_doc := nextval('public.document_id_seq')::integer;
      insert into public.documents (document_id, workflow_status, source_submission_id, legacy_migrated, is_preferred, media_type, access_level)
      values (v_doc, 'proposed', v_id, false, false, v_media, v_level);
    end if;

    if v_audio is not null and exists (select 1 from public.audio_readings a where a.path = v_audio and a.document_id <> v_doc) then
      raise exception 'That recording belongs to another document.';
    end if;

    update public.documents set
      title = coalesce(v_title, v_orig),
      en_title = v_title,
      original_title = v_orig,
      ur_title = case when v_lang = 'URD' then v_orig end,
      language = v_lang,
      work_id = v_work,
      access_level = v_level,
      media_type = v_media,
      external_url = v_link,
      duration = case when v_media = 'DOC' then null else nullif(btrim(v ->> 'duration'), '') end,
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
      contained_in_document_id = v_in,
      contained_page = v_in_page,
      source_board_post_id = coalesce(nullif(v ->> 'source_board_post_id', '')::bigint, source_board_post_id),
      draft_inp_path = case when v_media = 'DOC' then coalesce(nullif(v ->> 'draft_path', ''), draft_inp_path) end,
      pages = case when v_media = 'DOC' then coalesce(nullif(v ->> 'pages', '')::integer, pages) end,
      catalog_date = current_date
    where document_id = v_doc;

    if v_body is not null then
      insert into public.document_texts (document_id, body, source, updated_by_email)
      values (v_doc, v_body, 'typed', v_email)
      on conflict (document_id) do update set body = excluded.body, updated_by_email = excluded.updated_by_email;
    else
      delete from public.document_texts where document_id = v_doc;
    end if;

    if v_media = 'AUD' then
      insert into public.audio_readings (document_id, path, mime_type, size_bytes, reader_name)
      values (v_doc, v_audio, nullif(v ->> 'audio_mime', ''), nullif(v ->> 'audio_size', '')::bigint, nullif(btrim(v ->> 'reader_name'), ''))
      on conflict (document_id) do update set
        path = coalesce(excluded.path, audio_readings.path),
        mime_type = coalesce(excluded.mime_type, audio_readings.mime_type),
        size_bytes = coalesce(excluded.size_bytes, audio_readings.size_bytes),
        reader_name = excluded.reader_name;
    else
      delete from public.audio_readings where document_id = v_doc;
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

-- ============================================================================
-- 5. The Word of Life of a month
-- ============================================================================
create or replace function public.word_of_life_codes()
returns text[]
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(array_agg(code), array[]::text[]) from public.option_lists where list_name = 'category' and label ilike 'word of life';
$$;

-- Finds the month's Work, or makes it. If the month's documents already share one Work, that one is used.
-- If they are in several, nothing is merged by itself (GOVERNANCE §1.7): a person links them from the list.
create or replace function public.ensure_word_of_life_month(p_period text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_work bigint;
  v_found bigint[];
begin
  if not public.current_role_is('operator') then raise exception 'Only team members can do this.'; end if;
  if coalesce(p_period, '') !~ '^[0-9]{4}-(0[1-9]|1[0-2])$' then raise exception 'Please choose a month.'; end if;
  select work_id into v_work from public.works where series = 'WOL' and series_period = p_period;
  if v_work is not null then return v_work; end if;

  select array_agg(distinct d.work_id) into v_found
  from public.documents d
  where d.category = any (public.word_of_life_codes()) and left(d.ref_period, 7) = p_period
    and d.deleted_at is null and d.work_id is not null;

  if array_length(v_found, 1) = 1 and not exists (select 1 from public.works w where w.work_id = v_found[1] and w.series is not null) then
    update public.works set series = 'WOL', series_period = p_period where work_id = v_found[1];
    return v_found[1];
  end if;

  insert into public.works (canonical_title, series, series_period) values ('Word of Life, ' || p_period, 'WOL', p_period)
  on conflict (series, series_period) where series is not null do update set series = excluded.series
  returning work_id into v_work;
  return v_work;
end;
$$;

-- What the month has and what it is missing, for the whole team. Nothing here creates anything.
create or replace function public.get_word_of_life_month(p_period text)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_work bigint;
  v_codes text[] := public.word_of_life_codes();
begin
  if not public.current_role_is('operator') then raise exception 'Only team members can see this.'; end if;
  select work_id into v_work from public.works where series = 'WOL' and series_period = p_period;
  return jsonb_build_object(
    'period', p_period,
    'work_id', v_work,
    'category', (select d.category from public.documents d where d.category = any (v_codes) group by d.category order by count(*) desc limit 1),
    'versions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'document_id', d.document_id, 'title', coalesce(d.ur_title, d.original_title, d.en_title, d.title), 'en_title', d.en_title,
        'author', d.author, 'language', d.language, 'media_type', coalesce(d.media_type, 'DOC'), 'workflow_status', d.workflow_status,
        'submission_status', s.status, 'in_series', d.work_id is not distinct from v_work
      ) order by d.document_id)
      from public.documents d
      left join public.archive_submissions s on s.id = d.source_submission_id
      where d.deleted_at is null and d.workflow_status is distinct from 'removed' and public.document_reserved_ok(d.document_id)
        and ((v_work is not null and d.work_id = v_work)
             or (d.category = any (v_codes) and left(d.ref_period, 7) = p_period))), '[]'::jsonb),
    'tasks', coalesce((
      select jsonb_agg(jsonb_build_object('id', t.id, 'title', t.title, 'category', t.category, 'status', t.status, 'document_id', t.document_id) order by t.id)
      from public.tasks t
      where t.status not in ('rejected', 'published')
        and t.document_id in (
          select d.document_id from public.documents d
          where (v_work is not null and d.work_id = v_work) or (d.category = any (v_codes) and left(d.ref_period, 7) = p_period)
        ) and public.document_reserved_ok(t.document_id)), '[]'::jsonb)
  );
end;
$$;

-- A person decides that a document of that month belongs to it. Its whole Work comes along, so versions
-- already linked stay together; a star already held for the same language and format stays where it is.
create or replace function public.link_document_to_month(p_document_id integer, p_period text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_old bigint;
  v_new bigint;
begin
  if not public.current_role_is('coordinator') then raise exception 'Only Coordinators and Admin can do this.'; end if;
  if not public.document_reserved_ok(p_document_id) then raise exception 'Document not found.'; end if;
  perform set_config('dua.submission_op', 'on', true);
  select work_id into v_old from public.documents where document_id = p_document_id;
  v_new := public.ensure_word_of_life_month(p_period);
  if v_old is not distinct from v_new then return; end if;
  update public.documents d set is_preferred = false
  where (d.document_id = p_document_id or (v_old is not null and d.work_id = v_old)) and d.is_preferred
    and exists (select 1 from public.documents x where x.work_id = v_new and x.is_preferred
                 and x.language is not distinct from d.language
                 and coalesce(x.media_type, 'DOC') = coalesce(d.media_type, 'DOC'));
  update public.documents d set work_id = v_new
  where d.document_id = p_document_id or (v_old is not null and d.work_id = v_old);
  if v_old is not null then
    update public.archive_submissions set work_id = v_new where work_id = v_old;
    delete from public.works w where w.work_id = v_old and not exists (select 1 from public.documents d where d.work_id = v_old);
  end if;
end;
$$;

-- ============================================================================
-- 6. Boards: anyone can suggest a post for the archive
-- ============================================================================
create table if not exists public.board_archive_requests (
  id                 bigint generated always as identity primary key,
  post_id            bigint not null references public.board_posts(id) on delete cascade,
  requested_by       uuid references auth.users(id) on delete set null,
  requested_by_email text,
  requested_at       timestamptz not null default now(),
  closed_at          timestamptz,
  closed_by_email    text,
  outcome            text check (outcome in ('proposed', 'declined'))
);
create unique index if not exists idx_board_archive_requests_open on public.board_archive_requests (post_id) where closed_at is null;

-- No rules: reached only through the functions below.
alter table public.board_archive_requests enable row level security;

drop trigger if exists board_archive_requests_log_change on public.board_archive_requests;
create trigger board_archive_requests_log_change
  after insert or update or delete on public.board_archive_requests
  for each row execute function public.log_archive_change('id');

create or replace function public.can_handle_archive_request(p_board text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('coordinator') or public.is_dept_member('ARCHIVE') or public.is_board_editor(p_board);
$$;

create or replace function public.request_post_for_archive(p_post_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('user') then raise exception 'Please sign in first.'; end if;
  if not exists (select 1 from public.board_posts p where p.id = p_post_id and p.status = 'published') then
    raise exception 'Post not found.';
  end if;
  insert into public.board_archive_requests (post_id, requested_by, requested_by_email)
  values (p_post_id, auth.uid(), (select email from public.user_roles where user_id = auth.uid()))
  on conflict (post_id) where closed_at is null do nothing;
end;
$$;

-- Which posts already have a suggestion waiting, so the button can say so.
create or replace function public.get_requested_posts()
returns setof bigint
language sql
security definer
stable
set search_path = public
as $$
  select r.post_id from public.board_archive_requests r where r.closed_at is null and public.current_role_is('user');
$$;

create or replace function public.get_archive_requests()
returns table (id bigint, post_id bigint, board_code text, title text, body text, link_url text, image_path text, requested_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select r.id, p.id, p.board_code, p.title, p.body, p.link_url, p.image_path, r.requested_at
  from public.board_archive_requests r
  join public.board_posts p on p.id = r.post_id
  where r.closed_at is null and public.can_handle_archive_request(p.board_code)
  order by r.requested_at;
$$;

create or replace function public.close_archive_request(p_id bigint, p_outcome text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_board text;
begin
  select p.board_code into v_board from public.board_archive_requests r join public.board_posts p on p.id = r.post_id where r.id = p_id;
  if v_board is null then raise exception 'Request not found.'; end if;
  if not public.can_handle_archive_request(v_board) then raise exception 'You cannot decide on this request.'; end if;
  if p_outcome not in ('proposed', 'declined') then raise exception 'Unknown outcome.'; end if;
  update public.board_archive_requests
  set closed_at = now(), closed_by_email = (select email from public.user_roles where user_id = auth.uid()), outcome = p_outcome
  where id = p_id and closed_at is null;
end;
$$;

-- ============================================================================
-- 7. Verification: every row must say true.
-- ============================================================================
select 'no period still holds a page' as item,
  not exists (select 1 from public.documents where ref_period ~ '^[0-9]{4}-[0-9]{2}p\.') as ok
union all select 'no page lost: cleaned records keep their issue',
  not exists (select 1 from public.archive_log l join public.documents d on d.document_id = l.document_id
              where l.table_name = 'documents' and l.changes -> 'ref_period' ->> 'old' ~ '^[0-9]{4}-[0-9]{2}p\.[0-9]+$'
                and nullif(btrim(d.hayat_issue), '') is null)
union all select 'periods cleaned, each one in the log: ' || (select count(*) from public.archive_log where table_name = 'documents' and action = 'update' and changes -> 'ref_period' ->> 'old' ~ '^[0-9]{4}-[0-9]{2}p\.'),
  true
union all select 'one Work per month at most',
  exists (select 1 from pg_indexes where indexname = 'idx_works_series_period')
union all select 'magazine issue category added',
  exists (select 1 from public.option_lists where list_name = 'category' and code = 'MAG')
union all select 'the form knows what contains what',
  (select prosrc like '%contained_in_document_id%' from pg_proc where proname = 'save_submission')
  and (select prosrc like '%external_url%' from pg_proc where proname = 'save_submission')
union all select 'the star on task publications is per language',
  (select prosrc like '%language is not distinct%' from pg_proc where proname = 'finalize_document_publish')
union all select 'suggestions closed to direct access',
  (select relrowsecurity from pg_class where oid = 'public.board_archive_requests'::regclass)
  and not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'board_archive_requests');
