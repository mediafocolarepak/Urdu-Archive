-- 65_drop_legacy_2006_fields.sql
-- Third and final step of the 2026-09 documents-table field audit (after 63 and 64).
-- Drops four columns inherited from the original 2006 Access schema:
--   book, book_page, short_name, file_page
--
-- WHY THIS IS SAFE
-- ----------------
-- All four are 100% confined to source='ALE' - the 471 records of the original Access
-- import (0 rows in STE/WEB/HAYAT). Their values have never been modified since that
-- import: the per-field counts in the live table match 02_seed_data.sql exactly
-- (book 407, book_page 338, short_name 121, file_page 113). That seed file is committed
-- to this repository, so every value dropped here stays recoverable from git, and the
-- original Access database remains available as a second copy.
--
-- PER-FIELD RATIONALE
-- -------------------
-- book / book_page  Already represented in document_collections: migration 16 backfilled
--                   them there. The only 8 distinct book titles in the data are all covered
--                   by that migration's mapping, so its lossy `else 'OTHR'` branch never
--                   fired - the copy is faithful. Guarded below.
-- short_name        No original content. 96 of 121 values are already substrings of title,
--                   original_title or legacy_file_name; 15 more are punctuation placeholders
--                   ('.' or ','); the rest are spelling variants of data we already hold.
--                   The three link-up records whose short_name carries a different date than
--                   the file name contradict it rather than add to it (#308: 'Linkup-28-10-95'
--                   vs file name '308-Linkup-28.9.95').
-- file_page         Page position inside the 2005 paper binder (75 single pages, 37 ranges,
--                   1 malformed value '17-17-19'). Superseded by the digital archive; the
--                   archivist confirmed it can be recovered from the Access database via
--                   original_title should it ever be needed.
--
-- DELIBERATELY NOT DROPPED
-- ------------------------
-- video   Kept on purpose. Those 20 values are not document ids but the code numbers of the
--         physical videocassettes (the same number recurs on several documents: 13 on
--         #20/#24/#25, 88 on #11/#32). The videos have since been digitised, and a later
--         phase will add them to this database under those same code numbers - so this
--         column is the join key to that future video catalogue, not dead weight.
--         Leave it alone.
--
-- physical_box is handled separately in migration 66: unlike these four it is a current field
-- (added in migration 03), editable in the app, so anything entered there is NOT in the Access
-- backup, and removing it needs the matching UI changes shipped with it.

-- Guard: refuse to drop book/book_page unless document_collections really does carry the
-- same information. If migration 16 was never run, or was only partially applied, this
-- aborts the whole migration and nothing is dropped.
do $$
declare
  v_missing  integer;
  v_mismatch integer;
begin
  select
    count(*) filter (where dc.document_id is null),
    count(*) filter (where dc.document_id is not null
                       and d.book_page is not null
                       and dc.page_number is distinct from d.book_page)
    into v_missing, v_mismatch
  from documents d
  left join document_collections dc on dc.document_id = d.document_id
  where d.book is not null and d.book <> '';

  if v_missing > 0 or v_mismatch > 0 then
    raise exception
      'Aborting: document_collections does not fully cover documents.book (% documents missing, % page_number mismatches). Re-run 16_backfill_document_collections.sql first, then this migration.',
      v_missing, v_mismatch;
  end if;

  raise notice 'Guard passed: all documents.book rows are represented in document_collections.';
end $$;

-- No view depends on these: v_documents_by_category / v_documents_by_topic expanded
-- documents.* into an explicit column list, but migration 21 dropped both views, which is
-- why 63 and 64 could drop columns without CASCADE. Same applies here.
-- Dropping book also drops idx_documents_book (01_schema.sql) along with it.
alter table public.documents
  drop column if exists book,
  drop column if exists book_page,
  drop column if exists short_name,
  drop column if exists file_page;
