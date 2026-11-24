-- 162_book_bookmarks.sql
-- Books (Owner's request, 2026-11-24): the texts of one kind - the Link-ups first - read as a book, in date order, with an
-- index and a bookmark, like the formation paths (139_formation_bookmarks.sql). One bookmark per person and book.
-- book_code is the book's name in the app (js/books.js, for example 'linkups'); item_key is the page: 'w<work_id>', or
-- 'd<document_id>' for a text with no Work.
--
-- Run in the SQL Editor. Safe to run again. Self-test at the end: every row must say true.

create table if not exists public.book_bookmarks (
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  book_code  text        not null check (book_code ~ '^[a-z0-9_-]{1,40}$'),
  item_key   text        not null check (item_key ~ '^[wd][0-9]+$'),
  updated_at timestamptz not null default now(),
  primary key (user_id, book_code)
);

alter table public.book_bookmarks enable row level security;

-- Each person sees and changes only their own bookmarks.
drop policy if exists "book_bookmarks_own" on public.book_bookmarks;
create policy "book_bookmarks_own" on public.book_bookmarks
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select, insert, update, delete on public.book_bookmarks to authenticated;

-- Self-test: every row must say true.
select 'table book_bookmarks' as check_name, exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'book_bookmarks') as ok
union all select 'row level security on', (select relrowsecurity from pg_class where oid = 'public.book_bookmarks'::regclass)
union all select 'policy book_bookmarks_own', exists (select 1 from pg_policies where tablename = 'book_bookmarks' and policyname = 'book_bookmarks_own');
