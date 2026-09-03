-- _check_legacy_fields_detail.sql (diagnostic only, not a migration - nothing is modified)
-- Second pass of the 2026-09 documents field audit, for the five columns deliberately kept
-- back in migrations 63/64: book, book_page, short_name, file_page, video.
-- Goal: decide, per field, between KEEP AS-IS / MIGRATE INTO A CURRENT FIELD / DROP,
-- on evidence rather than on guesswork. Run each query and report the output.

-- ============================================================================
-- 0. Guard: confirm every column these queries touch still exists under that name.
--    (Migrations 03/15/21 renamed several: note->notes, file_name->legacy_file_name,
--    provenance->source, original_lang->language.) Expect 16 rows.
-- ============================================================================
select column_name, data_type
from information_schema.columns
where table_schema = 'public'
  and table_name in ('documents', 'document_collections')
  and column_name in ('document_id','book','book_page','short_name','file_page','video',
                      'title','original_title','file_name','legacy_file_name','physical_box',
                      'media_type','notes','source','collection_code','page_number')
order by table_name, column_name;

-- ============================================================================
-- A. book / book_page - are they really redundant with document_collections?
-- ============================================================================

-- A1. Every distinct book title, how many documents carry it, and which collection_code
--     migration 16 mapped it to. Any row showing 'OTHR' is a title that survives ONLY in
--     documents.book: dropping the column would lose it permanently.
select
  d.book,
  count(*) as docs,
  case d.book
    when 'Face to face with Chiara' then 'FACF'
    when 'Themes of Spirituality'   then 'THEM'
    when 'Meditations'              then 'MEDIT'
    when 'Experiences'              then 'EXPE'
    when 'Messages'                 then 'MESS'
    when 'Protagonists'             then 'PROT'
    when 'linkup'                   then 'LINKU'
    when 'Link-up'                  then 'LINKU'
    when 'The Focolare and its realities' then 'FOCO'
    else 'OTHR  <-- TITLE LOST IF DROPPED'
  end as mapped_to
from documents d
where d.book is not null and d.book <> ''
group by d.book
order by docs desc;

-- A2. Did the migration-16 backfill actually land for every one of them?
--     want_missing = 0. Anything > 0 means those documents' book data is NOT in
--     document_collections and dropping the column would lose it.
select
  count(*) as docs_with_book,
  count(*) filter (where dc.document_id is null) as missing_from_document_collections,
  count(*) filter (where dc.document_id is not null
                     and d.book_page is not null
                     and dc.page_number is distinct from d.book_page) as page_number_mismatch,
  count(*) filter (where d.book_page is not null and dc.page_number is null) as page_lost_in_backfill
from documents d
left join document_collections dc
  on dc.document_id = d.document_id
where d.book is not null and d.book <> '';

-- A3. Sanity check the other direction: rows in document_collections that came from nowhere
--     (i.e. created by the app, not by the backfill) - tells us if the table is actually in use.
select collection_code, count(*) as rows
from document_collections
group by collection_code
order by rows desc;

-- ============================================================================
-- B. short_name - is it distinct information, or a stale copy of title/file_name?
-- ============================================================================

-- NB: short_name is contemporary with the ORIGINAL Access file names, which migration 03
-- renamed to legacy_file_name; the current file_name column holds the recomputed
-- "00518-STE-..." names and is the wrong thing to compare against. Check both.

-- B1. How often short_name is just a substring of something we already store.
select
  count(*) as short_name_filled,
  count(*) filter (where title            ilike '%' || short_name || '%') as contained_in_title,
  count(*) filter (where original_title   ilike '%' || short_name || '%') as contained_in_original_title,
  count(*) filter (where legacy_file_name ilike '%' || short_name || '%') as contained_in_legacy_file_name,
  count(*) filter (where file_name        ilike '%' || short_name || '%') as contained_in_current_file_name,
  count(*) filter (where coalesce(title, '')            not ilike '%' || short_name || '%'
                     and coalesce(original_title, '')   not ilike '%' || short_name || '%'
                     and coalesce(legacy_file_name, '') not ilike '%' || short_name || '%'
                     and coalesce(file_name, '')        not ilike '%' || short_name || '%')
    as genuinely_independent
from documents
where short_name is not null and short_name <> '';

-- B2. The independent ones, in full - this is the only content at risk.
select document_id, short_name, title, original_title, legacy_file_name
from documents
where short_name is not null and short_name <> ''
  and coalesce(title, '')            not ilike '%' || short_name || '%'
  and coalesce(original_title, '')   not ilike '%' || short_name || '%'
  and coalesce(legacy_file_name, '') not ilike '%' || short_name || '%'
  and coalesce(file_name, '')        not ilike '%' || short_name || '%'
order by document_id;

-- ============================================================================
-- C. file_page - page range in the physical binder. Overlap with physical_box?
-- ============================================================================

select
  count(*) as file_page_filled,
  count(*) filter (where physical_box is not null and physical_box <> '') as also_has_physical_box,
  count(*) filter (where file_page ~ '^[0-9]+$') as looks_like_single_page,
  count(*) filter (where file_page ~ '^[0-9]+\s*-\s*[0-9]+$') as looks_like_range,
  count(*) filter (where file_page !~ '^[0-9]+(\s*-\s*[0-9]+)?$') as other_shapes
from documents
where file_page is not null and file_page <> '';

select document_id, file_page, physical_box, title
from documents
where file_page is not null and file_page <> ''
order by document_id
limit 40;

-- ============================================================================
-- D. video - reference to a physical videocassette. Any link to real VID records?
-- ============================================================================

select
  count(*) as video_filled,
  count(*) filter (where media_type = 'VID') as of_which_are_vid_records,
  count(*) filter (where notes ilike '%video%') as notes_also_mention_video
from documents
where video is not null and video <> '';

select document_id, video, media_type, title, notes
from documents
where video is not null and video <> ''
order by document_id;

-- ============================================================================
-- E. Cross-check: is any of this concentrated in the live dataset, or purely historical?
-- ============================================================================
select
  source,
  count(*) as total,
  count(book)       as book_filled,
  count(book_page)  as book_page_filled,
  count(short_name) as short_name_filled,
  count(file_page)  as file_page_filled,
  count(video)      as video_filled
from documents
group by source
order by total desc;
