-- 67_collection_into_document_collections.sql
-- Retires documents.collection, the last of the three parallel tracks for the same concept
-- (documents.book went in migration 65; document_collections is the one that stays).
--
-- WHAT WAS ACTUALLY BROKEN
-- ------------------------
-- Collections have been a many-to-many join in document_collections since migration 15, and
-- that is what the document editor (core.js getCollectionsForDocument / saveDocumentCollections),
-- the Dashboard filter and Match Review all read. But documents.collection survived alongside
-- it, and two places kept using it exclusively:
--   * Bulk Import WROTE only documents.collection - so every document catalogued in bulk with a
--     collection was invisible to the editor's checkboxes, the Dashboard filter and Match Review.
--   * The Filtered Document Report FILTERED only on documents.collection - so any document whose
--     collections were set from the editor was missing from that report.
-- Neither failure raised anything: both simply returned fewer rows than they should have.
-- Both call sites are corrected in the same commit as this migration (bulkimport.js, reports.js).
--
-- Both columns use the same vocabulary (the option_lists 'collection' codes: FACF, THEM, MEDIT,
-- EXPE, MESS, PROT, LINKU, FOCO, OTHR, HAYAT), so the backfill is a straight copy. Rows already
-- present in document_collections win - the editor is the authoritative source, and it carries
-- page_number, which documents.collection never had.

do $$
declare
  v_to_migrate integer;
  v_already    integer;
  v_inserted   integer;
begin
  select
    count(*) filter (where dc.document_id is null),
    count(*) filter (where dc.document_id is not null)
    into v_to_migrate, v_already
  from documents d
  left join document_collections dc
    on dc.document_id = d.document_id and dc.collection_code = d.collection
  where d.collection is not null and d.collection <> '';

  raise notice 'documents.collection: % row(s) to migrate, % already in document_collections.',
    v_to_migrate, v_already;

  insert into document_collections (document_id, collection_code, page_number)
  select d.document_id, d.collection, null
  from documents d
  where d.collection is not null and d.collection <> ''
  on conflict (document_id, collection_code) do nothing;

  get diagnostics v_inserted = row_count;
  raise notice 'Inserted % row(s) into document_collections.', v_inserted;

  if v_inserted <> v_to_migrate then
    raise exception
      'Aborting: expected to insert % row(s) but inserted %. Nothing has been dropped; investigate before re-running.',
      v_to_migrate, v_inserted;
  end if;
end $$;

alter table public.documents drop column if exists collection;

select 'documents columns now: ' || count(*)::text as result
from information_schema.columns
where table_schema = 'public' and table_name = 'documents';
