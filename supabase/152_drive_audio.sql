-- 152: audio recordings kept on Google Drive (Owner's decision, 2026-11-22).
-- The audio of the Urdu videos (about 90 hours) does not fit the Free plan's 1 GB of storage, so its mp3 files
-- live in a Google Drive folder shared "anyone with the link", like the PDFs. A recording on Drive is an ordinary
-- AUD record with an audio_readings row whose path is 'gdrive:<file name>': the app plays it from the Drive folder
-- (core.js, audioFileUrl) instead of the reading-audio bucket. Every other path is still a file in the bucket.
--
-- What changes here: a Drive path is never put on the list of files to erase from the bucket, because it is not
-- in the bucket. When such a recording is erased or replaced, its file stays on Drive: Admin removes it there.
-- Run this BEFORE merging the PR. Safe to run again. It changes no existing record.

create or replace function public.skip_drive_audio_erase()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.path like 'gdrive:%' then return null; end if;
  return new;
end;
$$;

drop trigger if exists audio_files_to_erase_skip_drive on public.audio_files_to_erase;
create trigger audio_files_to_erase_skip_drive
  before insert on public.audio_files_to_erase
  for each row execute function public.skip_drive_audio_erase();

-- Checks: all should be true.
select 'Drive paths are not listed for erasing' as check_name,
  exists (select 1 from pg_trigger where tgname = 'audio_files_to_erase_skip_drive' and not tgisinternal) as ok
union all select 'no Drive path is on the list already',
  not exists (select 1 from public.audio_files_to_erase where path like 'gdrive:%');
