-- 131: an announcement in three languages (Owner's request, 2026-11-07). message_text stays the English text and is
-- still required; Italian and Urdu are optional. The announcement window shows EN, IT and اردو for the languages
-- written, and whoever chooses a language with no text reads the English. Old announcements are unchanged.
-- Nothing else changes: the same rules decide who reads (everyone signed in) and who publishes (Admins).
-- Run this BEFORE merging the PR. Safe to run again.

alter table public.splash_messages
  add column if not exists message_it text,
  add column if not exists message_ur text;

-- Both rows should say true.
select 'Italian text column' as item,
       exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'splash_messages' and column_name = 'message_it') as ok
union all
select 'Urdu text column',
       exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'splash_messages' and column_name = 'message_ur');
