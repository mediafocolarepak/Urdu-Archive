-- 114_readings.sql
-- Fase 5 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md (Owner's decisions of 2026-11-05).
-- Anyone signed in can read a text aloud and record it. The recording goes to a listening review and,
-- if approved, becomes a record of the archive with a Listen button and the reader's name.
--
--   consent -> reserve the text for 7 days -> record or upload -> queue -> OK, OK with a note,
--   record again (no consequences), or rejected (the text is free again).
--
-- A reading is an archive_submissions row of kind 'reading', so it shares the proposals' claims, reminders,
-- states and log. It is reviewed by those with the AUDIO_REVIEWER qualification, Coordinators and Admin.
-- Audio files have one way out: audio_files_to_erase. Whatever stops being used is listed there and
-- then removed from the bucket, by the reader's own browser or by Admin. A file cannot be removed from
-- inside the database, so the list is what guarantees none is forgotten.
--
-- Run after 113. Safe to re-run. It changes no existing document.

-- ============================================================================
-- 1. Tables
-- ============================================================================
insert into public.option_lists (list_name, code, label, sort_order) values
  ('operator_qualification', 'AUDIO_REVIEWER', 'Audio reviewer', 6)
on conflict (list_name, code) do nothing;

alter table public.archive_submissions add column if not exists kind text not null default 'content';
alter table public.archive_submissions drop constraint if exists archive_submissions_kind_ok;
alter table public.archive_submissions add constraint archive_submissions_kind_ok check (kind in ('content', 'reading'));
alter table public.archive_submissions add column if not exists source_document_id integer references public.documents(document_id) on delete set null;
create index if not exists idx_archive_submissions_kind on public.archive_submissions (kind, status, submitted_at);
create index if not exists idx_archive_submissions_source on public.archive_submissions (source_document_id) where source_document_id is not null;

alter table public.audio_readings add column if not exists source_document_id integer references public.documents(document_id) on delete set null;
alter table public.audio_readings add column if not exists reader_user_id uuid references auth.users(id) on delete set null;
alter table public.audio_readings add column if not exists consent_version text;
alter table public.audio_readings add column if not exists origin text not null default 'form';
alter table public.audio_readings drop constraint if exists audio_readings_origin_ok;
alter table public.audio_readings add constraint audio_readings_origin_ok check (origin in ('form', 'app', 'file'));
-- When the text was last changed at the moment of recording: a later correction shows up as a difference.
alter table public.audio_readings add column if not exists source_text_at timestamptz;
create index if not exists idx_audio_readings_reader on public.audio_readings (reader_user_id) where reader_user_id is not null;
create index if not exists idx_audio_readings_source on public.audio_readings (source_document_id) where source_document_id is not null;

-- The wording someone accepted must stay readable afterwards, so a change is a new version.
create table if not exists public.reading_consent_texts (
  version  text primary key,
  body_en  text not null,
  body_ur  text,             -- the Owner's wording; until it is here, the English text is shown
  active   boolean not null default false,
  created_at timestamptz not null default now()
);
create unique index if not exists idx_reading_consent_one_active on public.reading_consent_texts (active) where active;

insert into public.reading_consent_texts (version, body_en, active) values ('v1',
'Before you record

Your voice is yours, so please read this first.

- Why: your reading helps those who find reading difficult, or cannot read, to receive the text.
- Who listens: someone on the team listens to it first. If it is approved, it is in the archive for the registered users who can see this text.
- Your name is shown next to the recording.
- It stays in the archive for as long as you wish. It will never be used to create a synthetic voice, and it will never be given to anyone outside the archive.
- You can change your mind at any time, here in Read aloud. Your readings are removed at once and their files erased. A copy that someone has already saved on their own device cannot be called back.
- A reading earns no credits by itself. If you would like a compensation, agree with the team first.',
true)
on conflict (version) do nothing;

create table if not exists public.reading_consents (
  user_id      uuid not null references auth.users(id) on delete cascade,
  version      text not null references public.reading_consent_texts(version),
  accepted_at  timestamptz not null default now(),
  withdrawn_at timestamptz,
  primary key (user_id, version)
);

create table if not exists public.reading_reservations (
  source_document_id integer primary key references public.documents(document_id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  reserved_at timestamptz not null default now(),
  expires_at  timestamptz not null
);
create index if not exists idx_reading_reservations_user on public.reading_reservations (user_id);

create table if not exists public.audio_files_to_erase (
  path           text primary key,
  reason         text,
  reader_user_id uuid,
  requested_by   uuid,
  requested_at   timestamptz not null default now(),
  erase_after    timestamptz not null default now(),
  erased_at      timestamptz
);

-- Listens are only counted, per reading and per day. Who listened is not recorded: access history is
-- its own decision (GOVERNANCE.md §5.9), not a side effect of a statistic.
create table if not exists public.audio_play_counts (
  document_id integer not null references public.documents(document_id) on delete cascade,
  day         date not null default current_date,
  plays       integer not null default 0,
  primary key (document_id, day)
);

-- All closed: only the functions below reach them, except the consent's wording, which anyone may read.
alter table public.reading_consent_texts enable row level security;
alter table public.reading_consents enable row level security;
alter table public.reading_reservations enable row level security;
alter table public.audio_files_to_erase enable row level security;
alter table public.audio_play_counts enable row level security;
drop policy if exists "read - reading_consent_texts" on public.reading_consent_texts;
create policy "read - reading_consent_texts" on public.reading_consent_texts for select to authenticated using (true);

drop trigger if exists reading_consents_log_change on public.reading_consents;
create trigger reading_consents_log_change
  after insert or update or delete on public.reading_consents
  for each row execute function public.log_archive_change('user_id', 'version');
drop trigger if exists audio_files_to_erase_log_change on public.audio_files_to_erase;
create trigger audio_files_to_erase_log_change
  after insert or update or delete on public.audio_files_to_erase
  for each row execute function public.log_archive_change('path');

-- ============================================================================
-- 2. Who reviews what
-- ============================================================================
create or replace function public.can_review_readings()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'AUDIO_REVIEWER');
$$;

-- Same as 112, with the readings going to those who review by listening.
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
      and case when s.kind = 'reading' then public.can_review_readings()
               when s.is_reserved then public.can_manage_reserved()
               else public.current_role_is('coordinator')
                    or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
          end
  );
$$;

-- A reading changes only through submit_reading, not through the proposal form.
create or replace function public.guard_reading_submission()
returns trigger
language plpgsql
as $$
begin
  if old.kind = 'reading' and new.common is distinct from old.common
     and coalesce(current_setting('dua.reading_op', true), '') <> 'on' then
    raise exception 'A reading changes only through the recorder.';
  end if;
  return new;
end;
$$;
drop trigger if exists archive_submissions_guard_reading on public.archive_submissions;
create trigger archive_submissions_guard_reading
  before update on public.archive_submissions
  for each row execute function public.guard_reading_submission();

-- ============================================================================
-- 3. Files: who may open, upload and remove them
-- ============================================================================
create or replace function public.audio_file_listed(p_name text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.audio_files_to_erase e where e.path = p_name and e.erase_after <= now());
$$;

-- As in 113 it runs as the person asking, so every rule on documents applies. A file listed for erasing
-- is closed at once, even if removing it from the bucket has to wait.
create or replace function public.audio_file_ok(p_name text)
returns boolean
language sql
stable
set search_path = public
as $$
  select not public.audio_file_listed(p_name) and exists (
    select 1 from public.audio_readings a
    join public.documents d on d.document_id = a.document_id
    where a.path = p_name
  );
$$;

-- Admin may remove any file. Anyone else, only one of theirs already listed for erasing.
create or replace function public.audio_file_erasable(p_name text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('admin') or exists (
    select 1 from public.audio_files_to_erase e
    where e.path = p_name and e.erased_at is null and e.erase_after <= now()
      and auth.uid() in (e.reader_user_id, e.requested_by)
  );
$$;

create or replace function public.can_upload_reading()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('operator')
      or exists (select 1 from public.reading_reservations r where r.user_id = auth.uid() and r.expires_at > now())
      or exists (select 1 from public.archive_submissions s where s.proposer_id = auth.uid() and s.kind = 'reading' and s.status = 'to_correct');
$$;

drop policy if exists "read - reading-audio" on storage.objects;
create policy "read - reading-audio" on storage.objects for select to authenticated
  using (bucket_id = 'reading-audio' and (public.audio_file_ok(name) or public.audio_file_erasable(name)));

drop policy if exists "upload - reading-audio" on storage.objects;
create policy "upload - reading-audio" on storage.objects for insert to authenticated
  with check (bucket_id = 'reading-audio' and public.can_upload_reading());

drop policy if exists "delete - reading-audio" on storage.objects;
create policy "delete - reading-audio" on storage.objects for delete to authenticated
  using (bucket_id = 'reading-audio' and public.audio_file_erasable(name));

-- Whatever a record stops pointing at goes on the list, by whichever path it happened: the proposal
-- form, a discarded draft, a new take replacing an old one.
create or replace function public.list_replaced_audio_file()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.path is not null and (tg_op = 'DELETE' or new.path is distinct from old.path) then
    insert into public.audio_files_to_erase (path, reason, reader_user_id, requested_by)
    values (old.path, 'no longer used by its record', old.reader_user_id, auth.uid())
    on conflict (path) do nothing;
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;
drop trigger if exists audio_readings_list_file on public.audio_readings;
create trigger audio_readings_list_file
  after update or delete on public.audio_readings
  for each row execute function public.list_replaced_audio_file();

-- What this person can remove now. The browser removes each one, then confirms.
create or replace function public.get_my_files_to_erase()
returns setof text
language sql
security definer
stable
set search_path = public
as $$
  select e.path from public.audio_files_to_erase e
  where e.erased_at is null and e.erase_after <= now()
    and (public.current_role_is('admin') or auth.uid() in (e.reader_user_id, e.requested_by));
$$;

-- Marks it erased only once it is really gone from the bucket. The row stays, without the content.
create or replace function public.confirm_audio_file_erased(p_path text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from public.audio_files_to_erase e where e.path = p_path
                  and (public.current_role_is('admin') or auth.uid() in (e.reader_user_id, e.requested_by))) then
    raise exception 'That file is not on your list.';
  end if;
  if exists (select 1 from storage.objects o where o.bucket_id = 'reading-audio' and o.name = p_path) then
    raise exception 'That file is still there.';
  end if;
  update public.audio_files_to_erase set erased_at = now() where path = p_path and erased_at is null;
  update public.audio_readings set path = null where path = p_path;
end;
$$;

-- ============================================================================
-- 4. Consent
-- ============================================================================
create or replace function public.reading_consent_version()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select version from public.reading_consent_texts where active limit 1;
$$;

create or replace function public.has_reading_consent()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.reading_consents c
                 where c.user_id = auth.uid() and c.version = public.reading_consent_version() and c.withdrawn_at is null);
$$;

create or replace function public.accept_reading_consent()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('user') then raise exception 'Please sign in first.'; end if;
  if nullif(btrim((select full_name from public.user_profiles where user_id = auth.uid())), '') is null then
    raise exception 'Your name is shown next to your readings: please add it in My Profile first.';
  end if;
  insert into public.reading_consents (user_id, version) values (auth.uid(), public.reading_consent_version())
  on conflict (user_id, version) do update set accepted_at = now(), withdrawn_at = null;
end;
$$;

-- Internal: takes one reading out at once. The file closes now and is removed by whoever can.
create or replace function public.take_reading_out(p_document_id integer, p_reason text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  a public.audio_readings%rowtype;
begin
  perform set_config('dua.submission_op', 'on', true);
  select * into a from public.audio_readings where document_id = p_document_id;
  update public.documents set workflow_status = 'removed', is_preferred = false where document_id = p_document_id;
  if a.path is not null then
    insert into public.audio_files_to_erase (path, reason, reader_user_id, requested_by)
    values (a.path, p_reason, a.reader_user_id, auth.uid())
    on conflict (path) do update set erase_after = now(), reason = excluded.reason;
  end if;
end;
$$;

-- The reader's own decision, or Admin's on their behalf. Everything goes at once (Owner's decision).
create or replace function public.withdraw_reading_consent(p_user_id uuid default null)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := coalesce(p_user_id, auth.uid());
  d record;
  n integer := 0;
begin
  if v_user is distinct from auth.uid() and not public.current_role_is('admin') then
    raise exception 'Only Admin can do this for someone else.';
  end if;
  perform set_config('dua.submission_op', 'on', true);
  perform set_config('dua.reading_op', 'on', true);
  update public.reading_consents set withdrawn_at = now() where user_id = v_user and withdrawn_at is null;
  for d in select a.document_id from public.audio_readings a where a.reader_user_id = v_user loop
    perform public.take_reading_out(d.document_id, 'consent withdrawn');
    n := n + 1;
  end loop;
  update public.archive_submissions set status = 'discarded', claimed_by = null, claimed_at = null, updated_at = now()
  where proposer_id = v_user and kind = 'reading' and status in ('draft', 'submitted', 'to_correct');
  delete from public.reading_reservations where user_id = v_user;
  return n;
end;
$$;

-- For a reading uploaded by the team, whose reader has no account here.
create or replace function public.erase_reading(p_document_id integer, p_reason text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then raise exception 'Only Admin can do this.'; end if;
  if nullif(btrim(p_reason), '') is null then raise exception 'Please give a reason.'; end if;
  if not exists (select 1 from public.audio_readings a where a.document_id = p_document_id) then
    raise exception 'That is not a reading.';
  end if;
  perform public.take_reading_out(p_document_id, btrim(p_reason));
end;
$$;

create or replace function public.set_reading_reader(p_document_id integer, p_name text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then raise exception 'Only Admin can do this.'; end if;
  if nullif(btrim(p_name), '') is null then raise exception 'Please give a name.'; end if;
  update public.audio_readings set reader_name = btrim(p_name) where document_id = p_document_id;
  if not found then raise exception 'That is not a reading.'; end if;
end;
$$;

-- ============================================================================
-- 5. Which text can be read, and holding it
-- ============================================================================
-- A first reading stays short, so nobody risks long work being rejected; longer ones wait for parts.
-- The bucket stops taking new reservations well before the Free plan's 1 GB, shared with the PDFs.
create or replace function public.reading_chars_limit()
returns integer
language sql
security definer
stable
set search_path = public
as $$
  select case when exists (
    select 1 from public.audio_readings a join public.documents d on d.document_id = a.document_id
    where a.reader_user_id = auth.uid() and d.workflow_status = 'published'
  ) then 20000 else 4000 end;
$$;

create or replace function public.reading_space_used()
returns bigint
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(sum((o.metadata ->> 'size')::bigint), 0)::bigint from storage.objects o where o.bucket_id = 'reading-audio';
$$;

create or replace function public.reading_space_limit()
returns bigint
language sql
immutable
as $$
  select 500::bigint * 1024 * 1024;
$$;

-- states: not_text, reserved_level, no_text, not_reviewed, has_reading, taken, mine, in_review, rerecord,
-- too_long, available. Reveals nothing about a document this person cannot see.
create or replace function public.reading_state(p_document_id integer)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  d public.documents%rowtype;
  t record;
  r public.reading_reservations%rowtype;
  v_mine public.archive_submissions%rowtype;
  v_limit integer := public.reading_chars_limit();
  v_base jsonb;
begin
  select * into d from public.documents where document_id = p_document_id;
  if d.document_id is null or d.deleted_at is not null or not public.document_status_is_visible(d.workflow_status)
     or coalesce(d.media_type, 'DOC') <> 'DOC' or not public.current_role_is('user') then
    return jsonb_build_object('state', 'not_text');
  end if;
  if d.access_level = 'reserved' then return jsonb_build_object('state', 'reserved_level'); end if;
  v_base := jsonb_build_object('consented', public.has_reading_consent(), 'limit', v_limit);

  select x.reviewed, length(x.body) as chars into t from public.document_texts x where x.document_id = p_document_id;
  if t is null or t.chars is null then return v_base || jsonb_build_object('state', 'no_text'); end if;
  v_base := v_base || jsonb_build_object('chars', t.chars);
  -- Stella's texts count as correct even if not marked as reread (Owner's decision).
  if not (t.reviewed or d.source = 'STE') then return v_base || jsonb_build_object('state', 'not_reviewed'); end if;

  select * into v_mine from public.archive_submissions s
  where s.kind = 'reading' and s.source_document_id = p_document_id and s.proposer_id = auth.uid()
    and s.status in ('draft', 'submitted', 'to_correct')
  order by s.id desc limit 1;
  if v_mine.id is not null then
    if v_mine.status = 'submitted' then return v_base || jsonb_build_object('state', 'in_review', 'submission_id', v_mine.id); end if;
    return v_base || jsonb_build_object('state', 'rerecord', 'submission_id', v_mine.id, 'note', v_mine.decision_note);
  end if;

  -- One published reading for each text; a Coordinator or Admin may have a new one replace it.
  if not public.current_role_is('coordinator') and exists (
    select 1 from public.documents x
    where x.work_id = d.work_id and x.language is not distinct from d.language and x.media_type = 'AUD'
      and x.deleted_at is null and public.document_status_is_visible(x.workflow_status)
  ) then
    return v_base || jsonb_build_object('state', 'has_reading');
  end if;

  select * into r from public.reading_reservations x where x.source_document_id = p_document_id and x.expires_at > now();
  if r.user_id = auth.uid() then return v_base || jsonb_build_object('state', 'mine', 'expires_at', r.expires_at); end if;
  if r.user_id is not null or exists (
    select 1 from public.archive_submissions s
    where s.kind = 'reading' and s.source_document_id = p_document_id and s.status = 'submitted'
  ) then
    return v_base || jsonb_build_object('state', 'taken');
  end if;
  if t.chars > v_limit then return v_base || jsonb_build_object('state', 'too_long'); end if;
  return v_base || jsonb_build_object('state', 'available');
end;
$$;

create or replace function public.reserve_reading(p_document_id integer)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_state jsonb := public.reading_state(p_document_id);
  v_until timestamptz := now() + interval '7 days';
  v_held integer;
begin
  if not public.has_reading_consent() then raise exception 'Please read and accept the consent first.'; end if;
  if v_state ->> 'state' = 'mine' then return (v_state ->> 'expires_at')::timestamptz; end if;
  if v_state ->> 'state' <> 'available' then raise exception 'This text cannot be read right now.'; end if;
  if public.reading_space_used() >= public.reading_space_limit() then
    raise exception 'There is no space for new recordings at the moment. Please try again later.';
  end if;
  select count(*) into v_held from public.reading_reservations where user_id = auth.uid() and expires_at > now();
  if v_held >= (case when public.reading_chars_limit() > 4000 then 3 else 1 end) then
    raise exception 'You are already holding as many texts as you can: please finish or release one first.';
  end if;
  insert into public.reading_reservations (source_document_id, user_id, expires_at)
  values (p_document_id, auth.uid(), v_until)
  on conflict (source_document_id) do update
    set user_id = excluded.user_id, reserved_at = now(), expires_at = excluded.expires_at
    where public.reading_reservations.expires_at <= now();
  if not found then raise exception 'Someone else has just taken this text.'; end if;
  return v_until;
end;
$$;

create or replace function public.release_reading(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.reading_reservations where source_document_id = p_document_id and user_id = auth.uid();
end;
$$;

-- ============================================================================
-- 6. Sending a reading
-- ============================================================================
create or replace function public.submit_reading(p_document_id integer, p_path text, p_mime text, p_size bigint, p_duration text, p_origin text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_state jsonb := public.reading_state(p_document_id);
  v_st text := v_state ->> 'state';
  d public.documents%rowtype;
  s public.archive_submissions%rowtype;
  v_email text;
  v_name text;
  v_doc integer;
  v_work bigint;
  v_text_at timestamptz;
  v_title text;
  v_orig text;
begin
  if not public.has_reading_consent() then raise exception 'Please read and accept the consent first.'; end if;
  if v_st not in ('mine', 'rerecord') then raise exception 'Please hold this text before recording it.'; end if;
  if exists (select 1 from public.reading_reservations r where r.source_document_id = p_document_id and r.user_id <> auth.uid() and r.expires_at > now()) then
    raise exception 'Someone else has taken this text in the meantime.';
  end if;
  if coalesce(p_path, '') !~ '^[0-9a-f-]{36}\.(mp3|m4a|aac|ogg|webm)$' then raise exception 'That is not a valid recording.'; end if;
  if exists (select 1 from public.audio_readings a where a.path = p_path) then raise exception 'That recording belongs to another document.'; end if;
  if p_origin not in ('app', 'file') then raise exception 'Unknown origin.'; end if;

  select nullif(btrim(full_name), '') into v_name from public.user_profiles where user_id = auth.uid();
  if v_name is null then raise exception 'Your name is shown next to your readings: please add it in My Profile first.'; end if;
  select email into v_email from public.user_roles where user_id = auth.uid();
  select * into d from public.documents where document_id = p_document_id;
  select updated_at into v_text_at from public.document_texts where document_id = p_document_id;

  perform set_config('dua.submission_op', 'on', true);
  perform set_config('dua.reading_op', 'on', true);

  v_work := d.work_id;
  if v_work is null then
    insert into public.works (canonical_title) values (coalesce(d.en_title, d.title, d.original_title)) returning work_id into v_work;
    update public.documents set work_id = v_work where document_id = p_document_id;
  end if;

  v_title := coalesce(d.en_title, d.title, d.original_title, d.ur_title);
  v_orig := coalesce(d.ur_title, d.original_title, d.en_title, d.title);

  if v_st = 'rerecord' then
    select * into s from public.archive_submissions where id = (v_state ->> 'submission_id')::bigint for update;
    select x.document_id into v_doc from public.documents x where x.source_submission_id = s.id order by x.document_id limit 1;
  else
    insert into public.archive_submissions (proposer_id, proposer_email, kind, source_document_id, title, work_id, common)
    values (auth.uid(), v_email, 'reading', p_document_id, v_title, v_work,
            jsonb_build_object('en_title', v_title, 'category', d.category, 'author', d.author,
                               'ref_date', d.ref_date, 'ref_period', d.ref_period))
    returning * into s;
    perform public.submission_event(s.id, 'created');
  end if;

  if v_doc is null then
    v_doc := nextval('public.document_id_seq')::integer;
    insert into public.documents (document_id, workflow_status, source_submission_id, legacy_migrated, is_preferred, media_type, access_level)
    values (v_doc, 'proposed', s.id, false, false, 'AUD', coalesce(d.access_level, 'private'));
  end if;

  update public.documents set
    title = v_title, en_title = d.en_title, original_title = v_orig, ur_title = d.ur_title,
    language = d.language, work_id = v_work, access_level = coalesce(d.access_level, 'private'), media_type = 'AUD',
    duration = nullif(btrim(p_duration), ''), category = d.category, author = d.author, original_author = d.original_author,
    ref_date = d.ref_date, ref_period = d.ref_period, recipient = d.recipient, main_topic = d.main_topic,
    secondary_tags = d.secondary_tags, bible_verse = d.bible_verse, place = d.place, catalog_date = current_date
  where document_id = v_doc;

  insert into public.audio_readings (document_id, path, mime_type, size_bytes, reader_name, source_document_id, reader_user_id, consent_version, origin, source_text_at)
  values (v_doc, p_path, nullif(p_mime, ''), p_size, v_name, p_document_id, auth.uid(), public.reading_consent_version(), p_origin, v_text_at)
  on conflict (document_id) do update set
    path = excluded.path, mime_type = excluded.mime_type, size_bytes = excluded.size_bytes, reader_name = excluded.reader_name,
    source_document_id = excluded.source_document_id, reader_user_id = excluded.reader_user_id,
    consent_version = excluded.consent_version, origin = excluded.origin, source_text_at = excluded.source_text_at;

  update public.archive_submissions
  set status = 'submitted', submitted_at = now(), claimed_by = null, claimed_at = null,
      reminder_count = 0, last_reminder_at = null, decision_note = null, updated_at = now()
  where id = s.id;
  perform public.submission_event(s.id, case when v_st = 'rerecord' then 'resubmitted' else 'submitted' end);
  delete from public.reading_reservations where source_document_id = p_document_id;
  return s.id;
end;
$$;

-- A reading needs its recording and its reader: the rest comes from the text, whatever it holds.
-- Same as 113 for everything else.
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
  if s.kind = 'content' then
    if nullif(btrim(s.common ->> 'en_title'), '') is null then return 'Please give an English title.'; end if;
    if nullif(s.common ->> 'category', '') is null then return 'Please choose a category.'; end if;
    if nullif(s.common ->> 'author', '') is null then return 'Please choose an author.'; end if;
    if nullif(s.common ->> 'ref_date', '') is null and nullif(btrim(s.common ->> 'ref_period'), '') is null then
      return 'Please give a date or a period.';
    end if;
  end if;
  if not exists (select 1 from public.documents d where d.source_submission_id = p_id) then
    return 'Please add at least one version.';
  end if;
  if s.kind = 'content' and exists (select 1 from public.documents d where d.source_submission_id = p_id and (d.language is null or d.original_title is null)) then
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

-- What each decision does to the holding and to the file, by whichever function took it.
-- A rejected recording's file is erased after 30 days; its row stays in the log.
create or replace function public.after_submission_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status is not distinct from old.status then return new; end if;
  if new.kind = 'reading' and new.status = 'to_correct' and new.source_document_id is not null then
    insert into public.reading_reservations (source_document_id, user_id, expires_at)
    values (new.source_document_id, new.proposer_id, now() + interval '7 days')
    on conflict (source_document_id) do update
      set user_id = excluded.user_id, reserved_at = now(), expires_at = excluded.expires_at;
  end if;
  if new.status = 'rejected' then
    insert into public.audio_files_to_erase (path, reason, reader_user_id, requested_by, erase_after)
    select a.path, 'rejected', a.reader_user_id, auth.uid(), now() + interval '30 days'
    from public.audio_readings a join public.documents d on d.document_id = a.document_id
    where d.source_submission_id = new.id and a.path is not null
    on conflict (path) do nothing;
  end if;
  return new;
end;
$$;
drop trigger if exists archive_submissions_after_status on public.archive_submissions;
create trigger archive_submissions_after_status
  after update on public.archive_submissions
  for each row execute function public.after_submission_status();

-- ============================================================================
-- 7. The proposals' lists stay about content; the readings have their own
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
  where s.proposer_id = auth.uid() and s.status <> 'discarded' and s.kind = 'content'
  order by coalesce(s.submitted_at, s.created_at) desc;
$$;

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
  where s.status = 'submitted' and s.kind = 'content' and public.can_review_submission(s.id)
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
    (select count(*)::integer from public.archive_submissions s where s.status = 'submitted' and s.kind = 'content' and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.status = 'submitted' and s.kind = 'content' and s.reminder_count > 0 and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.status = 'submitted' and s.kind = 'content' and s.submitted_at <= now() - interval '7 days' and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.status = 'to_correct' and s.kind = 'content' and s.proposer_id = auth.uid());
$$;

-- Everything the reader's own screen needs. The texts waiting for a voice are limited to what this
-- person can take now: shortest first, the Word of Life before the rest.
create or replace function public.get_my_readings()
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_limit integer := public.reading_chars_limit();
begin
  if not public.current_role_is('user') then raise exception 'Please sign in first.'; end if;
  return jsonb_build_object(
    'consented', public.has_reading_consent(),
    'limit', v_limit,
    'held', coalesce((
      select jsonb_agg(jsonb_build_object('document_id', r.source_document_id, 'title', coalesce(d.ur_title, d.en_title, d.title, d.original_title),
                                          'language', d.language, 'expires_at', r.expires_at) order by r.expires_at)
      from public.reading_reservations r join public.documents d on d.document_id = r.source_document_id
      where r.user_id = auth.uid() and r.expires_at > now()
        and not exists (select 1 from public.archive_submissions s where s.proposer_id = auth.uid() and s.kind = 'reading'
                         and s.source_document_id = r.source_document_id and s.status = 'to_correct')), '[]'::jsonb),
    'readings', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id, 'title', s.title, 'status', s.status, 'source_document_id', s.source_document_id, 'decision_note', s.decision_note,
        'days_waiting', case when s.status = 'submitted' then extract(day from now() - s.submitted_at)::integer end,
        'in_review', s.claimed_by is not null and s.claimed_at > now() - interval '48 hours',
        'reminder_allowed', s.status = 'submitted' and s.submitted_at <= now() - interval '3 days'
          and (s.last_reminder_at is null or s.last_reminder_at <= now() - interval '3 days'),
        'next_reminder_at', case when s.status = 'submitted' then greatest(s.submitted_at, coalesce(s.last_reminder_at, s.submitted_at)) + interval '3 days' end,
        'document_id', a.document_id, 'path', a.path, 'duration', x.duration, 'language', x.language
      ) order by coalesce(s.submitted_at, s.created_at) desc)
      from public.archive_submissions s
      left join public.documents x on x.source_submission_id = s.id
      left join public.audio_readings a on a.document_id = x.document_id
      where s.proposer_id = auth.uid() and s.kind = 'reading' and s.status <> 'discarded'), '[]'::jsonb),
    'waiting', coalesce((
      select jsonb_agg(q.w order by q.first desc, q.chars)
      from (
        select jsonb_build_object('document_id', d.document_id, 'title', coalesce(d.ur_title, d.en_title, d.title, d.original_title),
                                  'en_title', d.en_title, 'language', d.language, 'chars', length(t.body)) as w,
               exists (select 1 from public.option_lists o where o.list_name = 'category' and o.code = d.category and o.label ilike 'word of life') as first,
               length(t.body) as chars
        from public.documents d join public.document_texts t on t.document_id = d.document_id
        where coalesce(d.media_type, 'DOC') = 'DOC' and d.deleted_at is null and public.document_status_is_visible(d.workflow_status)
          and coalesce(d.access_level, 'private') <> 'reserved' and (t.reviewed or d.source = 'STE') and length(t.body) <= v_limit
          and not exists (select 1 from public.documents x where x.work_id = d.work_id and x.language is not distinct from d.language
                           and x.media_type = 'AUD' and x.deleted_at is null and public.document_status_is_visible(x.workflow_status))
          and not exists (select 1 from public.reading_reservations r where r.source_document_id = d.document_id and r.expires_at > now())
          and not exists (select 1 from public.archive_submissions s where s.kind = 'reading' and s.source_document_id = d.document_id and s.status = 'submitted')
        order by first desc, chars
        limit 20
      ) q(w, first, chars)), '[]'::jsonb)
  );
end;
$$;

-- Oldest first. The reader's name stays off this screen and the next one: a voice can be recognised, but
-- the review should be about the voice.
create or replace function public.get_reading_queue()
returns table (id bigint, title text, language text, duration text, days_waiting integer, overdue boolean,
               claimed_by_me boolean, claimed_by_other boolean, reminder_count integer)
language sql
security definer
stable
set search_path = public
as $$
  select s.id, s.title, d.language, d.duration, extract(day from now() - s.submitted_at)::integer,
         s.submitted_at <= now() - interval '7 days',
         s.claimed_by = auth.uid() and s.claimed_at > now() - interval '48 hours',
         s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours',
         s.reminder_count
  from public.archive_submissions s
  left join public.documents d on d.source_submission_id = s.id
  where s.kind = 'reading' and s.status = 'submitted' and public.can_review_submission(s.id)
  order by s.submitted_at;
$$;

create or replace function public.get_reading_counts()
returns table (to_listen integer, to_rerecord integer)
language sql
security definer
stable
set search_path = public
as $$
  select
    (select count(*)::integer from public.archive_submissions s where s.kind = 'reading' and s.status = 'submitted' and public.can_review_submission(s.id)),
    (select count(*)::integer from public.archive_submissions s where s.kind = 'reading' and s.status = 'to_correct' and s.proposer_id = auth.uid());
$$;

create or replace function public.get_reading_detail(p_id bigint)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
  v_admin boolean := public.current_role_is('admin');
  v_mine boolean;
begin
  select * into s from public.archive_submissions where id = p_id and kind = 'reading';
  if s.id is null or not public.can_read_proposal(p_id) then raise exception 'Reading not found.'; end if;
  v_mine := s.proposer_id = auth.uid();
  return (
    select jsonb_build_object(
      'id', s.id, 'status', s.status, 'title', s.title, 'decision_note', s.decision_note, 'mine', v_mine,
      'can_review', public.can_review_submission(p_id),
      'claimed_by_me', s.claimed_by = auth.uid() and s.claimed_at > now() - interval '48 hours',
      'claimed_by_other', s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours',
      'document_id', d.document_id, 'language', d.language, 'duration', d.duration, 'path', a.path,
      'reader_name', case when v_admin or v_mine then a.reader_name end,
      'source_document_id', a.source_document_id,
      'source_body', (select t.body from public.document_texts t where t.document_id = a.source_document_id),
      'text_changed', (select t.updated_at > a.source_text_at from public.document_texts t where t.document_id = a.source_document_id),
      'events', coalesce((
        select jsonb_agg(jsonb_build_object('at', e.at, 'event', e.event, 'note', e.note,
                                            'actor', case when v_admin then e.actor_email end) order by e.at, e.id)
        from public.submission_events e where e.submission_id = p_id), '[]'::jsonb))
    from public.documents d
    left join public.audio_readings a on a.document_id = d.document_id
    where d.source_submission_id = p_id
    order by d.document_id limit 1
  );
end;
$$;

-- ============================================================================
-- 8. For those who look after the readers, and the space
-- ============================================================================
create or replace function public.count_audio_play(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('user') or not public.document_reserved_ok(p_document_id) or not exists (
    select 1 from public.documents d where d.document_id = p_document_id and d.media_type = 'AUD'
      and d.deleted_at is null and public.document_status_is_visible(d.workflow_status)
  ) then
    return;
  end if;
  insert into public.audio_play_counts (document_id, plays) values (p_document_id, 1)
  on conflict (document_id, day) do update set plays = public.audio_play_counts.plays + 1;
end;
$$;

-- Coordination and HR see how each reader is doing, to give the best ones the most important work.
create or replace function public.get_reader_stats()
returns table (user_id uuid, reader_name text, approved integer, waiting integer, to_rerecord integer, times_sent_back integer, rejected integer, listens bigint)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not (public.current_role_is('coordinator') or public.is_dept_member('HR') or public.is_dept_member('COORD')) then
    raise exception 'Only Coordination, HR and Admin can see this.';
  end if;
  return query
    select s.proposer_id, max(coalesce(nullif(p.full_name, ''), s.proposer_email))::text,
           (count(*) filter (where s.status = 'published'))::integer,
           (count(*) filter (where s.status = 'submitted'))::integer,
           (count(*) filter (where s.status = 'to_correct'))::integer,
           (select count(*)::integer from public.submission_events e join public.archive_submissions s2 on s2.id = e.submission_id
             where s2.proposer_id = s.proposer_id and s2.kind = 'reading' and e.event = 'sent_back'),
           (count(*) filter (where s.status = 'rejected'))::integer,
           (select coalesce(sum(c.plays), 0)::bigint from public.audio_play_counts c
             join public.audio_readings a on a.document_id = c.document_id where a.reader_user_id = s.proposer_id)
    from public.archive_submissions s
    left join public.user_profiles p on p.user_id = s.proposer_id
    where s.kind = 'reading' and s.proposer_id is not null and s.status <> 'discarded'
    group by s.proposer_id
    order by 3 desc, 2;
end;
$$;

-- Space used, files due to be removed, and files nothing points at (an upload whose sending failed).
create or replace function public.get_audio_housekeeping()
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then raise exception 'Only Admin can see this.'; end if;
  return jsonb_build_object(
    'used', public.reading_space_used(),
    'limit', public.reading_space_limit(),
    'due', coalesce((select jsonb_agg(jsonb_build_object('path', e.path, 'reason', e.reason, 'requested_at', e.requested_at) order by e.requested_at)
                     from public.audio_files_to_erase e where e.erased_at is null and e.erase_after <= now()), '[]'::jsonb),
    'later', (select count(*) from public.audio_files_to_erase e where e.erased_at is null and e.erase_after > now()),
    'orphans', coalesce((select jsonb_agg(o.name order by o.name)
                         from storage.objects o
                         where o.bucket_id = 'reading-audio' and o.created_at < now() - interval '1 day'
                           and not exists (select 1 from public.audio_readings a where a.path = o.name)
                           and not exists (select 1 from public.audio_files_to_erase e where e.path = o.name)), '[]'::jsonb)
  );
end;
$$;

-- ============================================================================
-- 9. Verification: every row must say true.
-- ============================================================================
select 'no existing document was touched' as item,
  not exists (select 1 from public.archive_submissions where kind = 'reading')
  and not exists (select 1 from public.audio_readings where reader_user_id is not null) as ok
union all select 'a consent text is active',
  (select count(*) = 1 from public.reading_consent_texts where active)
union all select 'new tables closed to direct access',
  (select count(*) = 4 from pg_class where relname in ('reading_consents', 'reading_reservations', 'audio_files_to_erase', 'audio_play_counts') and relrowsecurity)
  and not exists (select 1 from pg_policies where schemaname = 'public' and tablename in ('reading_consents', 'reading_reservations', 'audio_files_to_erase', 'audio_play_counts'))
union all select 'audio reviewer qualification added',
  exists (select 1 from public.option_lists where list_name = 'operator_qualification' and code = 'AUDIO_REVIEWER')
union all select 'bucket rules in place',
  (select count(*) = 3 from pg_policies where schemaname = 'storage' and policyname like '%reading-audio%')
union all select 'only readings go to listeners',
  (select prosrc like '%can_review_readings%' from pg_proc where proname = 'can_review_submission')
union all select 'proposal lists leave readings out',
  (select prosrc like '%s.kind = ''content''%' from pg_proc where proname = 'get_submission_queue')
union all select 'files on their way out are listed',
  exists (select 1 from pg_trigger where tgname = 'audio_readings_list_file')
union all select 'consent is logged',
  exists (select 1 from pg_trigger where tgname = 'reading_consents_log_change');
