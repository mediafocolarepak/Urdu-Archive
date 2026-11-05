-- 113_media.sql
-- Fase 4 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md (Owner's decisions of 2026-11-05).
-- A version of a work can now be a video (a link, never a file: the project is on the Free plan) or an
-- audio reading (a file in a new private bucket, with the reader's name, which is shown). Both enter
-- through the same proposal form and review as any other version.
--
-- Recording inside the app, the consent and the listening queue are Fase 5: here the team uploads a
-- recording made elsewhere, as an ordinary proposal.
--
-- Run after 112. Safe to re-run. It adds new things and changes no existing document.

-- ============================================================================
-- 1. Video: a link on the document
-- ============================================================================
alter table public.documents add column if not exists external_url text;

create or replace function public.media_link_ok(p_url text)
returns boolean
language sql
immutable
as $$
  select p_url ~ '^https://((www\.|m\.)?youtube\.com|youtu\.be|drive\.google\.com)/[^[:space:]]+$';
$$;

alter table public.documents drop constraint if exists documents_external_url_ok;
alter table public.documents add constraint documents_external_url_ok
  check (external_url is null or public.media_link_ok(external_url));

insert into public.option_lists (list_name, code, label, sort_order) values
  ('media_type', 'AUD', 'Audio', 3)
on conflict (list_name, code) do nothing;

-- ============================================================================
-- 2. Audio: the file's details, one row per audio record in documents
-- ============================================================================
create table if not exists public.audio_readings (
  document_id  integer primary key references public.documents(document_id) on delete cascade,
  path         text unique,          -- empty only while a proposal is still a draft
  mime_type    text,
  size_bytes   bigint,
  reader_name  text,                 -- shown next to the player (Owner's decision)
  created_at   timestamptz not null default now()
);

-- Whoever can see the document can see this row. No write rule: only the functions below write here.
alter table public.audio_readings enable row level security;
drop policy if exists "read - audio_readings" on public.audio_readings;
create policy "read - audio_readings" on public.audio_readings for select to authenticated
  using (exists (select 1 from public.documents d where d.document_id = audio_readings.document_id));

drop trigger if exists audio_readings_log_change on public.audio_readings;
create trigger audio_readings_log_change
  after insert or update or delete on public.audio_readings
  for each row execute function public.log_archive_change('document_id');

-- ============================================================================
-- 3. The bucket: private, read through signed links
-- ============================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('reading-audio', 'reading-audio', false, 26214400,
        array['audio/mpeg', 'audio/mp4', 'audio/aac', 'audio/ogg', 'audio/webm'])
on conflict (id) do update set public = false, file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Runs as the person asking, so every rule on documents applies: hidden, deleted and reserved
-- documents keep their file closed too.
create or replace function public.audio_file_ok(p_name text)
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1 from public.audio_readings a
    join public.documents d on d.document_id = a.document_id
    where a.path = p_name
  );
$$;

drop policy if exists "read - reading-audio" on storage.objects;
create policy "read - reading-audio" on storage.objects for select to authenticated
  using (bucket_id = 'reading-audio' and public.audio_file_ok(name));

drop policy if exists "upload - reading-audio" on storage.objects;
create policy "upload - reading-audio" on storage.objects for insert to authenticated
  with check (bucket_id = 'reading-audio' and public.current_role_is('operator'));

-- ============================================================================
-- 4. The proposal form learns the three formats
-- ============================================================================
-- Same as 112, plus each version's media_type, external_url, duration, and for audio audio_path,
-- audio_mime, audio_size, reader_name.
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
              and coalesce(d.media_type, 'DOC') = 'DOC'
              and d.draft_inp_path is null
              and not exists (select 1 from public.document_texts t where t.document_id = d.document_id)) then
    return 'Each written version needs its text or a file.';
  end if;
  if exists (select 1 from public.documents d where d.source_submission_id = p_id and d.media_type = 'VID' and d.external_url is null) then
    return 'Each video needs its link.';
  end if;
  if exists (select 1 from public.documents d
             left join public.audio_readings a on a.document_id = d.document_id
             where d.source_submission_id = p_id and d.media_type = 'AUD' and a.path is null) then
    return 'Each audio version needs its recording.';
  end if;
  if exists (select 1 from public.documents d
             left join public.audio_readings a on a.document_id = d.document_id
             where d.source_submission_id = p_id and d.media_type = 'AUD' and a.reader_name is null) then
    return 'Each audio version needs the name of who is reading.';
  end if;
  return null;
end;
$$;

-- Same as 112, with each version's format and its link or recording.
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
        'media_type', coalesce(d.media_type, 'DOC'), 'external_url', d.external_url, 'duration', d.duration,
        'audio_path', a.path, 'audio_mime', a.mime_type, 'audio_size', a.size_bytes, 'reader_name', a.reader_name,
        'body', (select t.body from public.document_texts t where t.document_id = d.document_id)
      ) order by d.document_id)
      from public.documents d
      left join public.audio_readings a on a.document_id = d.document_id
      where d.source_submission_id = p_id), '[]'::jsonb),
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
-- 5. Verification: every row must say true.
-- ============================================================================
select 'video links: only https, only YouTube and Drive' as item,
  public.media_link_ok('https://youtu.be/abc') and public.media_link_ok('https://www.youtube.com/watch?v=abc')
  and public.media_link_ok('https://drive.google.com/file/d/abc/view')
  and not public.media_link_ok('http://youtu.be/abc') and not public.media_link_ok('https://example.org/abc')
  and not public.media_link_ok('https://youtube.com.example.org/abc') as ok
union all select 'no existing document was touched',
  not exists (select 1 from public.documents where external_url is not null or media_type = 'AUD')
union all select 'audio option added',
  exists (select 1 from public.option_lists where list_name = 'media_type' and code = 'AUD')
union all select 'audio table closed to direct writes',
  (select relrowsecurity from pg_class where oid = 'public.audio_readings'::regclass)
  and (select count(*) = 1 from pg_policies where schemaname = 'public' and tablename = 'audio_readings')
union all select 'bucket is private',
  exists (select 1 from storage.buckets where id = 'reading-audio' and public = false)
union all select 'bucket rules in place',
  (select count(*) = 2 from pg_policies where schemaname = 'storage' and policyname like '%reading-audio%')
union all select 'the form knows the formats',
  (select prosrc like '%audio_readings%' from pg_proc where proname = 'save_submission')
  and (select prosrc like '%Each video needs%' from pg_proc where proname = 'submission_problem')
union all select 'audio changes are logged',
  exists (select 1 from pg_trigger where tgname = 'audio_readings_log_change');
