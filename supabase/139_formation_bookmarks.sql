-- 139: a bookmark in a formation path, like a bookmark in a book (Owner's request, 2026-11-12). One per person and
-- per path: the post where the person stopped reading. Saved in the database, so it follows the person to any
-- device. Only the person can see, set or remove their own bookmark; nobody else, Admins included, reads it
-- through the API. The post must belong to the path and be one the person can see (the posts' own rules decide).
-- Deleting the path or the post deletes the bookmark. Run this BEFORE merging the PR. Safe to run again.

create table if not exists public.formation_bookmarks (
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  path_id    bigint      not null references public.formation_paths(id) on delete cascade,
  post_id    bigint      not null references public.formation_posts(id) on delete cascade,
  updated_at timestamptz not null default now(),
  primary key (user_id, path_id)
);

alter table public.formation_bookmarks enable row level security;

drop policy if exists "formation_bookmarks_own" on public.formation_bookmarks;
create policy "formation_bookmarks_own" on public.formation_bookmarks
  for all
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.formation_posts fp
                  join public.formation_chapters c on c.id = fp.chapter_id
                  join public.formation_modules m on m.id = c.module_id
                where fp.id = post_id and m.path_id = formation_bookmarks.path_id)
  );

grant select, insert, update, delete on public.formation_bookmarks to authenticated;
revoke all on public.formation_bookmarks from anon;

notify pgrst, 'reload schema';

-- Should all say true.
select 'Bookmark table' as item,
       exists (select 1 from information_schema.tables
                where table_schema = 'public' and table_name = 'formation_bookmarks') as ok
union all
select 'Row security on',
       (select relrowsecurity from pg_class where oid = 'public.formation_bookmarks'::regclass)
union all
select 'One rule, own rows only',
       (select count(*) = 1 from pg_policies where schemaname = 'public' and tablename = 'formation_bookmarks');
