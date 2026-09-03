-- _check_before_65.sql (diagnostic only - nothing is modified)
-- The two facts still missing before migrations 65 and 66 can be run safely.

-- ---------------------------------------------------------------------------
-- 1. Did migration 16's backfill actually land? Migration 65 drops book/book_page
--    on the assumption that document_collections carries the same information.
--    REQUIRED: missing_from_document_collections = 0 AND page_number_mismatch = 0.
--    (Migration 65 re-checks this itself and aborts if not - this is just the preview.)
-- ---------------------------------------------------------------------------
select
  count(*) as docs_with_book,
  count(*) filter (where dc.document_id is null) as missing_from_document_collections,
  count(*) filter (where dc.document_id is not null
                     and d.book_page is not null
                     and dc.page_number is distinct from d.book_page) as page_number_mismatch
from documents d
left join document_collections dc on dc.document_id = d.document_id
where d.book is not null and d.book <> '';

select collection_code, count(*) as rows
from document_collections
group by collection_code
order by rows desc;

-- ---------------------------------------------------------------------------
-- 2. physical_box is NOT a 2006 field: it was added by migration 03 and is editable
--    in the app (docdetail.js) plus shown in a Print Report (reports.js). Anything
--    entered there since then exists ONLY here - it is not in the Access backup nor
--    in 02_seed_data.sql. Check who filled it before migration 66 drops it.
-- ---------------------------------------------------------------------------
select
  source,
  count(*) as total,
  count(*) filter (where physical_box is not null and physical_box <> '') as physical_box_filled
from documents
group by source
order by total desc;

select document_id, source, physical_box, title
from documents
where physical_box is not null and physical_box <> ''
order by document_id
limit 50;
