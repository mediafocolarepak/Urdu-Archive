-- Addendum to 15_versions_editors_schema.sql: backfills document_collections from the
-- original Access "book"/"book_page" fields on documents (never renamed, still holding the
-- original data) - this was in the original request draft but got dropped by mistake when
-- 15_... was corrected. Safe to re-run (ON CONFLICT DO NOTHING on the document_id+code pair).

insert into document_collections (document_id, collection_code, page_number)
select document_id,
  case book
    when 'Face to face with Chiara' then 'FACF'
    when 'Themes of Spirituality' then 'THEM'
    when 'Meditations' then 'MEDIT'
    when 'Experiences' then 'EXPE'
    when 'Messages' then 'MESS'
    when 'Protagonists' then 'PROT'
    when 'linkup' then 'LINKU'
    when 'Link-up' then 'LINKU'
    when 'The Focolare and its realities' then 'FOCO'
    else 'OTHR'
  end,
  book_page
from documents
where book is not null and book <> ''
on conflict (document_id, collection_code) do nothing;

select 'document_collections backfilled: ' || (select count(*) from document_collections) as result;
