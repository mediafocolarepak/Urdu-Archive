-- 102_import_italian_originals_verify.sql
-- Da eseguire dopo tutti i part0N.sql di questo import.
select 'righe nei file sql (tutti i part)' as item, 273 as n
union all select 'righe inserite in document_original_texts (source=drive_import)', (select count(*) from public.document_original_texts where source = 'drive_import')
union all select 'document_id nei file ma assenti da documents (scartati)', 273 - (select count(*) from public.document_original_texts dot join public.documents d using (document_id) where dot.source = 'drive_import');
