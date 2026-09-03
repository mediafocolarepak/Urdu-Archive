-- 66_physical_box_to_original_title.sql
-- Retires documents.physical_box, moving its content into original_title first.
--
-- WHY THIS IS NOT A PLAIN DROP
-- ----------------------------
-- physical_box is not a 2006 legacy column: it was added by migration 03 and is typed by
-- hand in the document editor (docdetail.js). So unlike book/book_page/short_name/file_page
-- retired in migration 65, its content exists ONLY here - it is in neither the original
-- Access database nor 02_seed_data.sql.
--
-- Despite the name, nobody ever used it for a storage box. All 10 filled rows are
-- source='STE' (the current dataset) and hold the full Italian name of a book whose
-- `title` is only a working abbreviation - confirmed by the archivist. That is exactly
-- what original_title means in this schema (Italian original vs English title), so the
-- content is moved there rather than discarded.
--
-- The 10 values as found on 2026-09-03, recorded here so they survive in git regardless
-- of what happens to the table:
--    654  'Book 3'                                  -> '10 Comandamenti'
--   1002  'Era bellissima libro Gen 4'              -> 'Era Bellissima'
--   1134  'Let Primi Tempi A'                       -> 'Lettere dei primi tempi  A'
--   1148  'Libro detti gen.inp'                     -> 'Detti Gen'
--   1149  'Libro fiammella per proof'               -> 'La fiammella'
--   1150  'Libro La famiglia rinnovata per l''amore'-> 'La famiglia rinnovata dall''amore'
--   1151  'Let Primi Tempi B'                       -> 'Lettere dei primi tempi  B'
--   1152  'Libro Meditazioni B'                     -> 'Libro Meditazioni B'
--   1153  'Let Primi Tempi C'                       -> 'Lettere dei primi tempi C'
--   1154  'Libro Scritti Spirituali'                -> 'Scritti Spirituali'
--
-- Ships together with the UI changes that remove the field from the document editor, the
-- read-only detail table (docdetail.js) and the Filtered Document Report (reports.js).

-- Guard: never overwrite an original_title that already says something different. If any
-- row would lose data, abort the whole migration and name the offenders instead.
do $$
declare
  v_conflicts integer;
  v_list      text;
begin
  select count(*), string_agg(document_id::text, ', ' order by document_id)
    into v_conflicts, v_list
  from documents
  where physical_box is not null and physical_box <> ''
    and original_title is not null and original_title <> ''
    and original_title is distinct from physical_box;

  if v_conflicts > 0 then
    raise exception
      'Aborting: % document(s) already have a different original_title, moving physical_box there would overwrite it (document_id: %). Reconcile these by hand, then re-run.',
      v_conflicts, v_list;
  end if;
end $$;

update documents
   set original_title = physical_box
 where physical_box is not null and physical_box <> ''
   and (original_title is null or original_title = '');

alter table public.documents drop column if exists physical_box;

select 'documents columns now: ' || count(*)::text as result
from information_schema.columns
where table_schema = 'public' and table_name = 'documents';
