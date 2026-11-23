-- 160_report_voice.sql
-- "Report a problem" with a voice message (Owner's request, 2026-11-23): speaking is easier than typing for many
-- readers, as "Share with us" already allows (96_share_with_us_audio.sql, same pattern).
-- A report can now be a voice message, a written one, or both. The recordings are private: the person who sent one
-- and Coordinators/Admins (who read the reports, 36_document_pages_task_credits.sql) can hear it.
--
-- Run in the SQL Editor. Safe to run again. Self-test at the end: every row must say true.

alter table public.chat_messages add column if not exists audio_path text;
alter table public.chat_messages add column if not exists audio_mime_type text;

-- message_text was "not null": a voice-only report is a valid row too.
alter table public.chat_messages alter column message_text drop not null;
alter table public.chat_messages drop constraint if exists chat_messages_has_content;
alter table public.chat_messages add constraint chat_messages_has_content
  check ((message_text is not null and btrim(message_text) <> '') or audio_path is not null);

-- The recordings: a private bucket, one folder per person ("<user_id>/<file>"), 8 MB at most (about 3 minutes).
insert into storage.buckets (id, name, public, file_size_limit)
values ('report-audio', 'report-audio', false, 8388608)
on conflict (id) do nothing;

drop policy if exists "read - report-audio" on storage.objects;
drop policy if exists "upload - report-audio" on storage.objects;

create policy "read - report-audio" on storage.objects for select
  to authenticated using (
    bucket_id = 'report-audio'
    and (split_part(name, '/', 1) = auth.uid()::text or public.current_role_is('coordinator'))
  );
-- Only into your own folder. No delete: reports stay, like their text.
create policy "upload - report-audio" on storage.objects for insert
  to authenticated with check (
    bucket_id = 'report-audio' and split_part(name, '/', 1) = auth.uid()::text
  );

-- Self-test: every row must say true.
select 'chat_messages.audio_path' as check_name, exists (select 1 from information_schema.columns where table_name = 'chat_messages' and column_name = 'audio_path') as ok
union all select 'chat_messages.audio_mime_type', exists (select 1 from information_schema.columns where table_name = 'chat_messages' and column_name = 'audio_mime_type')
union all select 'chat_messages.message_text can be empty', (select is_nullable = 'YES' from information_schema.columns where table_name = 'chat_messages' and column_name = 'message_text')
union all select 'constraint chat_messages_has_content', exists (select 1 from pg_constraint where conname = 'chat_messages_has_content')
union all select 'bucket report-audio is private', exists (select 1 from storage.buckets where id = 'report-audio' and public = false)
union all select 'two storage policies for report-audio', (select count(*) = 2 from pg_policies where tablename = 'objects' and policyname like '%report-audio%');
