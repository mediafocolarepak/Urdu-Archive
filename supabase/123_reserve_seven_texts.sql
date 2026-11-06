-- 123_reserve_seven_texts.sql
-- Six Urdu texts say in their first lines that they are reserved, or meant for the more mature internal members, but were not
-- reserved in the archive. The seventh, 569, is a copy of 297 (same date, same talk, same opening) without those words.
-- The Owner's decision (2026-11-06): all seven become reserved. Only Admin, Formation members and those they have enabled
-- will see them, with their tasks, favourites and posts. No other document changes.
-- Run it in the SQL Editor. It can be run twice. The earlier level is kept in the backup table, and restored like this:
--   update public.documents d set access_level = b.access_level from public._backup_documents_access_20261106 b where d.document_id = b.document_id;

create table if not exists public._backup_documents_access_20261106 as
select document_id, access_level, now() as backed_up_at
from public.documents
where document_id in (297, 561, 562, 563, 569, 571, 578);
alter table public._backup_documents_access_20261106 enable row level security;

update public.documents
set access_level = 'reserved'
where document_id in (297, 561, 562, 563, 569, 571, 578)
  and access_level is distinct from 'reserved';

-- Verification (the SQL Editor shows only the last result). Seven rows: all must say reserved = true.
-- other_visible: other documents of the same Work still not reserved, such as the Italian version. readings: recordings of the text.
select d.document_id,
       d.access_level = 'reserved' as reserved,
       (select b.access_level from public._backup_documents_access_20261106 b where b.document_id = d.document_id) as level_before,
       (select count(*) from public.documents o
         where o.work_id = d.work_id and o.document_id <> d.document_id and o.access_level is distinct from 'reserved') as other_visible,
       (select count(*) from public.audio_readings r where r.document_id = d.document_id) as readings,
       coalesce(d.en_title, d.title) as title
from public.documents d
where d.document_id in (297, 561, 562, 563, 569, 571, 578)
order by d.document_id;
