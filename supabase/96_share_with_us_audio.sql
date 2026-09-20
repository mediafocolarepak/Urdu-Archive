-- 96_share_with_us_audio.sql
-- Phase 1b of "Share with us" (95_onboarding_and_share_with_us.sql): voice messages, for someone
-- who struggles typing a second script on a phone (the "casalinga" persona this whole feature was
-- scoped around). Deliberately its own migration/phase, kept separate from 95's text-only launch
-- so this - the newest technical territory in the app, no audio recording existed anywhere before
-- this - didn't block everything else.
--
-- Run after 95_onboarding_and_share_with_us.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. share_with_us_messages: a voice note alongside (or instead of) the typed body.
--    audio_mime_type is stored because the recorded format varies by browser (Chrome/Android
--    typically produce audio/webm;codecs=opus, Safari/iOS audio/mp4) - the <audio> player needs
--    the real type to play it back reliably.
-- ============================================================================
alter table public.share_with_us_messages add column if not exists audio_path text;
alter table public.share_with_us_messages add column if not exists audio_mime_type text;

-- body was "not null check (btrim(body) <> '')" in 95 - both need relaxing so an audio-only
-- share (no typed caption) is a valid row.
alter table public.share_with_us_messages alter column body drop not null;
alter table public.share_with_us_messages drop constraint if exists share_with_us_messages_body_check;
alter table public.share_with_us_messages add constraint share_with_us_messages_has_content
  check ((body is not null and btrim(body) <> '') or audio_path is not null);

-- ============================================================================
-- 2. Storage bucket for the recordings - NOT public (unlike onboarding-media): a voice note is
--    personal, not outreach content. Objects keyed "<user_id>/<filename>", same path-prefix trick
--    department-media (migration 94) uses for department_code, checked against auth.uid() here.
-- ============================================================================
insert into storage.buckets (id, name, public, file_size_limit)
values ('share-with-us-audio', 'share-with-us-audio', false, 8388608)
on conflict (id) do nothing;

drop policy if exists "read - share-with-us-audio" on storage.objects;
drop policy if exists "upload - share-with-us-audio" on storage.objects;

create policy "read - share-with-us-audio" on storage.objects for select
  to authenticated using (
    bucket_id = 'share-with-us-audio'
    and (split_part(name, '/', 1) = auth.uid()::text or public.is_any_dept_lead() or current_role_is('admin'))
  );
-- Only into your own folder - nobody uploads on someone else's behalf.
create policy "upload - share-with-us-audio" on storage.objects for insert
  to authenticated with check (
    bucket_id = 'share-with-us-audio' and split_part(name, '/', 1) = auth.uid()::text
  );
-- No delete policy: share_with_us_messages is already append-only (95), so the audio that goes
-- with a message stays too.

-- ============================================================================
-- 3. Self-test (run separately). All rows must be true.
-- ============================================================================
select 'share_with_us_messages.audio_path' as item, exists (select 1 from information_schema.columns where table_name = 'share_with_us_messages' and column_name = 'audio_path') as ok
union all select 'share_with_us_messages.audio_mime_type', exists (select 1 from information_schema.columns where table_name = 'share_with_us_messages' and column_name = 'audio_mime_type')
union all select 'constraint share_with_us_messages_has_content', exists (select 1 from pg_constraint where conname = 'share_with_us_messages_has_content')
union all select 'share_with_us_messages.body is nullable', (select is_nullable = 'YES' from information_schema.columns where table_name = 'share_with_us_messages' and column_name = 'body')
union all select 'storage bucket share-with-us-audio (private)', exists (select 1 from storage.buckets where id = 'share-with-us-audio' and public = false)
union all select 'storage policies share-with-us-audio (2)', (select count(*) = 2 from pg_policies where tablename = 'objects' and policyname like '%share-with-us-audio%');
