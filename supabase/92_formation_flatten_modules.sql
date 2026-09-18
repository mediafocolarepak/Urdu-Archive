-- 92_formation_flatten_modules.sql
-- Simplifies formation path structure per the owner's request (session of 2026-09-18): "Anni"
-- add a hierarchy level nobody actually needs (a formation path is a sequence of modules, not
-- a multi-year programme in the vast majority of real cases) and make module/chapter creation
-- feel like filling out an administrative form instead of building a course outline. This
-- migration removes `formation_years` and moves `formation_modules` directly under
-- `formation_paths`: Path -> Module (numbered) -> Chapter (numbered) -> Post, one level
-- shallower. No data is lost - every module keeps its path via its old year's path_id.

-- 1. Add the direct path_id, backfill it from each module's year, then require it.
alter table public.formation_modules add column if not exists path_id bigint references public.formation_paths(id) on delete cascade;

update public.formation_modules m
set path_id = y.path_id
from public.formation_years y
where m.year_id = y.id and m.path_id is null;

alter table public.formation_modules alter column path_id set not null;

-- 2. Redefine every RLS policy that walked through formation_years to reach formation_paths -
-- BEFORE dropping year_id below, since these old policies still reference it (Postgres refuses
-- to drop a column any policy depends on). One join level shorter now than the 82_formation_co_
-- authors.sql versions being replaced; current_role_is('coordinator') / can_edit_path() branches
-- are carried over unchanged, only the year hop is removed.

drop policy if exists "formation_modules_select" on public.formation_modules;
create policy "formation_modules_select" on public.formation_modules
  for select using (
    exists (select 1 from public.formation_paths p where p.id = path_id
      and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
drop policy if exists "formation_modules_write" on public.formation_modules;
create policy "formation_modules_write" on public.formation_modules
  for all using (public.can_edit_path(path_id)) with check (public.can_edit_path(path_id));

drop policy if exists "formation_chapters_select" on public.formation_chapters;
create policy "formation_chapters_select" on public.formation_chapters
  for select using (
    exists (select 1 from public.formation_modules m
              join public.formation_paths p on p.id = m.path_id
            where m.id = module_id
            and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
drop policy if exists "formation_chapters_write" on public.formation_chapters;
create policy "formation_chapters_write" on public.formation_chapters
  for all using (
    exists (select 1 from public.formation_modules m where m.id = module_id and public.can_edit_path(m.path_id))
  )
  with check (
    exists (select 1 from public.formation_modules m where m.id = module_id and public.can_edit_path(m.path_id))
  );

drop policy if exists "formation_posts_select" on public.formation_posts;
create policy "formation_posts_select" on public.formation_posts
  for select using (
    exists (select 1 from public.formation_chapters c
              join public.formation_modules m on m.id = c.module_id
              join public.formation_paths p on p.id = m.path_id
            where c.id = chapter_id
            and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
-- formation_posts_write keeps the document_is_postable check from 79_formation_post_documents.sql,
-- only the ownership clause loses its year hop.
drop policy if exists "formation_posts_write" on public.formation_posts;
create policy "formation_posts_write" on public.formation_posts
  for all using (
    exists (select 1 from public.formation_chapters c
              join public.formation_modules m on m.id = c.module_id
            where c.id = chapter_id and public.can_edit_path(m.path_id))
  )
  with check (
    exists (select 1 from public.formation_chapters c
              join public.formation_modules m on m.id = c.module_id
            where c.id = chapter_id and public.can_edit_path(m.path_id))
    and (document_id is null or public.document_is_postable(document_id))
  );

-- 3. Now that nothing depends on year_id any more, drop the old column/index, add the new index,
-- then drop formation_years entirely - nothing else references it.
drop index if exists public.idx_formation_modules_year;
alter table public.formation_modules drop column if exists year_id;
create index if not exists idx_formation_modules_path on public.formation_modules (path_id, sequence_number);

drop trigger if exists trg_touch_formation_years on public.formation_years;
drop table if exists public.formation_years;

notify pgrst, 'reload schema';

-- Self-test.
select 'table formation_years dropped' as item, to_regclass('public.formation_years') is null as ok
union all select 'formation_modules.path_id exists and not null', (select count(*) = 0 from information_schema.columns where table_name = 'formation_modules' and column_name = 'path_id' and is_nullable = 'YES')
union all select 'formation_modules.year_id dropped', not exists (select 1 from information_schema.columns where table_name = 'formation_modules' and column_name = 'year_id')
union all select 'every module has a path_id', (select count(*) = 0 from public.formation_modules where path_id is null)
union all select 'policy formation_modules_write uses can_edit_path directly', exists (select 1 from pg_policies where tablename = 'formation_modules' and policyname = 'formation_modules_write' and qual ilike '%can_edit_path(path_id)%')
union all select 'policy formation_chapters_write has no year join', (select count(*) = 0 from pg_policies where tablename = 'formation_chapters' and policyname = 'formation_chapters_write' and (qual ilike '%formation_years%' or with_check ilike '%formation_years%'))
union all select 'policy formation_posts_write keeps document_is_postable check', exists (select 1 from pg_policies where tablename = 'formation_posts' and policyname = 'formation_posts_write' and with_check ilike '%document_is_postable%');
