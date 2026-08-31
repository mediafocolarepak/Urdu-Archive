-- Correction to 46_populate_original_inp_file_name.sql: for source = 'STE', the right field to
-- copy from is title, not original_title. Re-populates over the previous (wrong) values.
-- Do after 46_populate_original_inp_file_name.sql.

update public.documents
set original_inp_file_name = title
where source = 'STE' and title is not null;

select 'STE' as source, count(*) from public.documents where source = 'STE' and original_inp_file_name is not null;
