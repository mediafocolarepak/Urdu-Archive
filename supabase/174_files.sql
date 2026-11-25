-- 174: which files can be uploaded, how large, and by whom (Owner's go-ahead, 2026-11-25).
--   * Pictures only where the app uses pictures, sound only where it uses sound, PDF, Word and InPage in the archive (50 MB).
--   * The pictures of the formation paths: from whoever prepares paths. They were open to everyone signed in.
--   * The lists of the public folders are for those signed in. The pictures themselves still open by their address.
--   * The corrected file of a task is .inp, .doc, .docx or .pdf.
-- Files already there are not touched. Run AFTER the code of the same pull request is live. Safe to run again.

update storage.buckets set allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/avif', 'image/heic', 'image/heif']
where id in ('board-media', 'department-media', 'formation-media', 'onboarding-media');
-- 'audio/*' and not a list: a phone adds the codec to the name of the kind ("audio/webm;codecs=opus").
update storage.buckets set allowed_mime_types = array['audio/*'] where id in ('report-audio', 'share-with-us-audio');
update storage.buckets set file_size_limit = 52428800, allowed_mime_types = array['application/pdf', 'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/octet-stream']
where id = 'archive-files';

create or replace function public.can_prepare_paths()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.current_role_is('coordinator') or public.is_any_formatore()
      or (public.person_may_work() and (exists (select 1 from public.formation_paths p where p.owner_id = auth.uid())
                                        or exists (select 1 from public.formation_path_editors e where e.user_id = auth.uid())));
$$;
revoke execute on function public.can_prepare_paths() from public, anon;
grant execute on function public.can_prepare_paths() to authenticated;

drop policy if exists "upload - formation-media" on storage.objects;
create policy "upload - formation-media" on storage.objects for insert to authenticated
  with check (bucket_id = 'formation-media' and public.can_prepare_paths());

drop policy if exists "read - board-media" on storage.objects;
create policy "read - board-media" on storage.objects for select to authenticated using (bucket_id = 'board-media' and public.current_role_is('user'));
drop policy if exists "read - formation-media" on storage.objects;
create policy "read - formation-media" on storage.objects for select to authenticated using (bucket_id = 'formation-media' and public.current_role_is('user'));
drop policy if exists "read - onboarding-media" on storage.objects;
create policy "read - onboarding-media" on storage.objects for select to authenticated using (bucket_id = 'onboarding-media' and public.current_role_is('user'));

-- The voice messages: from whoever has access (170).
drop policy if exists "upload - report-audio" on storage.objects;
create policy "upload - report-audio" on storage.objects for insert to authenticated
  with check (bucket_id = 'report-audio' and split_part(name, '/', 1) = auth.uid()::text and public.current_role_is('user'));
drop policy if exists "upload - share-with-us-audio" on storage.objects;
create policy "upload - share-with-us-audio" on storage.objects for insert to authenticated
  with check (bucket_id = 'share-with-us-audio' and split_part(name, '/', 1) = auth.uid()::text and public.current_role_is('user'));

create or replace function public.task_file_ok(p_name text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select p_name ~ '^draft-[0-9]{1,9}-[0-9]{1,15}-[0-9]{1,20}\.(inp|doc|docx|pdf)$'
     and exists (select 1 from public.tasks t
                  where t.id::text = split_part(p_name, '-', 3) and t.document_id::text = split_part(p_name, '-', 2)
                    and t.claimed_by = auth.uid() and t.status = 'claimed')
     and public.current_role_is('operator');
$$;

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- Row 8 false does not undo anything: it says that a file of another kind is already there, and it stays there.
-- ============================================================================
select 1 as n, 'Every folder has its kinds of file and its limit' as item,
       not exists (select 1 from storage.buckets where allowed_mime_types is null or file_size_limit is null) as ok
union all select 2, 'Pictures only, in four folders',
       (select count(*) = 4 from storage.buckets where id in ('board-media', 'department-media', 'formation-media', 'onboarding-media')
         and allowed_mime_types @> array['image/jpeg', 'image/png'] and not allowed_mime_types @> array['image/svg+xml'] and array_length(allowed_mime_types, 1) = 7)
union all select 3, 'Sound only, in two folders', (select count(*) = 2 from storage.buckets where id in ('report-audio', 'share-with-us-audio') and allowed_mime_types = array['audio/*'])
union all select 4, 'PDF, Word and InPage up to 50 MB in the archive',
       (select file_size_limit = 52428800 and array_length(allowed_mime_types, 1) = 4 and not public from storage.buckets where id = 'archive-files')
union all select 5, 'Pictures of the paths: from whoever prepares them',
       (select with_check ~ 'can_prepare_paths' from pg_policies where schemaname = 'storage' and policyname = 'upload - formation-media')
union all select 6, 'No list of files without signing in',
       not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and cmd in ('SELECT', 'ALL') and permissive = 'PERMISSIVE' and not (roles <@ array['authenticated'::name]))
union all select 7, 'Task files: InPage, Word, PDF',
       (select prosrc ~ 'inp\|doc\|docx\|pdf' from pg_proc where oid = 'public.task_file_ok(text)'::regprocedure)
union all select 8, 'The files already there are of these kinds',
       not exists (select 1 from storage.objects o join storage.buckets b on b.id = o.bucket_id
         where coalesce(o.metadata ->> 'mimetype', '') <> '' and not exists (select 1 from unnest(b.allowed_mime_types) k
           where split_part(o.metadata ->> 'mimetype', ';', 1) = k or (k like '%/*' and o.metadata ->> 'mimetype' like replace(k, '*', '%'))))
order by 1;
