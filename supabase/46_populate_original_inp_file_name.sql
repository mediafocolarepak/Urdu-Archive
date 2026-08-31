-- Populates documents.original_inp_file_name (now wired to the "Download original file"
-- button on a correction task, see 45_document_revision_workflow.sql) from whichever field
-- already holds the right value depending on where the document came from:
--   - source = 'ALE': copy from legacy_file_name, then fix the WIN1252/UTF8 mojibake on
--     accented letters - same reversal already used in 19_fix_encoding_corruption.sql
--     (convert_from(convert_to(col, 'WIN1252'), 'UTF8'), only applied where the 'Ã.' tell
--     is actually present).
--   - source = 'STE': copy from original_title as-is (no encoding issue reported for this one).
-- Do after 45_document_revision_workflow.sql.

update public.documents
set original_inp_file_name = legacy_file_name
where source = 'ALE' and legacy_file_name is not null;

update public.documents
set original_inp_file_name = convert_from(convert_to(original_inp_file_name, 'WIN1252'), 'UTF8')
where source = 'ALE' and original_inp_file_name ~ 'Ã.';

update public.documents
set original_inp_file_name = original_title
where source = 'STE' and original_title is not null;

select 'ALE' as source, count(*) from public.documents where source = 'ALE' and original_inp_file_name is not null
union all
select 'STE', count(*) from public.documents where source = 'STE' and original_inp_file_name is not null;
