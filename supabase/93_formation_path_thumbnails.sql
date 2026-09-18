-- 93_formation_path_thumbnails.sql
-- Owner's request (session of 2026-09-18): make the Formation Paths catalog "look like Coursera"
-- - a thumbnail image per path, shown on its catalog card and detail page. Same storage pattern
-- as board post images (84_boards_moderation.sql): a public-read bucket, upload open to any
-- signed-in user (the real gate is still formation_paths_write's RLS on the row that references
-- the file - an orphaned upload nobody links to is harmless), delete restricted to Coordinator+
-- so a stray image can be cleaned up centrally if needed.

alter table public.formation_paths add column if not exists thumbnail_path text;

insert into storage.buckets (id, name, public, file_size_limit)
values ('formation-media', 'formation-media', true, 3145728)  -- 3 MB - a card thumbnail, not a document
on conflict (id) do nothing;

drop policy if exists "read - formation-media" on storage.objects;
drop policy if exists "upload - formation-media" on storage.objects;
drop policy if exists "delete - formation-media" on storage.objects;
create policy "read - formation-media" on storage.objects for select
  using (bucket_id = 'formation-media');
create policy "upload - formation-media" on storage.objects for insert
  to authenticated with check (bucket_id = 'formation-media' and current_role_is('user'));
create policy "delete - formation-media" on storage.objects for delete
  to authenticated using (bucket_id = 'formation-media' and current_role_is('coordinator'));

notify pgrst, 'reload schema';

-- Self-test.
select 'formation_paths.thumbnail_path' as item, exists (select 1 from information_schema.columns where table_name = 'formation_paths' and column_name = 'thumbnail_path') as ok
union all select 'storage bucket formation-media', exists (select 1 from storage.buckets where id = 'formation-media')
union all select 'storage policies (3)', (select count(*) = 3 from pg_policies where tablename = 'objects' and policyname in ('read - formation-media', 'upload - formation-media', 'delete - formation-media'));
