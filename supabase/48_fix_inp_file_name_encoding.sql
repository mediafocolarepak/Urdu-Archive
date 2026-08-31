-- Standalone fix for the mojibake still visible in documents.original_inp_file_name after
-- 46_populate_original_inp_file_name.sql (the encoding-fix step there apparently didn't take
-- effect - re-applying it here, unconditionally on the current value, for every source).
-- Same reversal as 19_fix_encoding_corruption.sql: UTF-8 text that got read as WIN1252 at some
-- point, only touched where the 'Ã.' tell is actually present.

update public.documents
set original_inp_file_name = convert_from(convert_to(original_inp_file_name, 'WIN1252'), 'UTF8')
where original_inp_file_name ~ 'Ã.';

select count(*) as still_corrupted from public.documents where original_inp_file_name ~ 'Ã.';
