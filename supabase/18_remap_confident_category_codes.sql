-- Remaps the old-taxonomy category codes that have an unambiguous new-taxonomy equivalent
-- (confirmed by the app's own former Hayat category mapping, plus the two exact-name matches
-- WORD/MISC). DIAR/PAR4/REGU/LETT are deliberately left untouched - no reliable equivalent,
-- review those by hand in Edit Records instead.

update documents set category = 'Wol' where category = 'WORD';
update documents set category = 'Lkp' where category = 'LINK';
update documents set category = 'Tlk' where category = 'DISC';
update documents set category = 'Mdt' where category = 'MEDI';
update documents set category = 'Exp' where category = 'EXPE';
update documents set category = 'Misc' where category = 'MISC';

-- Now that those are remapped, drop the ones among them no longer used by any document
-- (same safe pattern as 17_cleanup_old_category_codes.sql - only removes what's truly unused).
delete from option_lists
where list_name = 'category'
  and code in ('WORD','LINK','DISC','MEDI','EXPE','MISC')
  and not exists (select 1 from documents d where d.category = option_lists.code);

select 'category options remaining: ' || (select count(*) from option_lists where list_name = 'category')
  || ' - still needing manual review: ' || (select count(*) from documents where category in ('DIAR','PAR4','REGU','LETT')) as result;
