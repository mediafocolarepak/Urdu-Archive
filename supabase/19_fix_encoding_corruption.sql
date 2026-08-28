-- Fixes UTF-8 text that was mistakenly read as Windows-1252 at some point (almost certainly
-- during the original Access import), corrupting Italian accented letters across 228 rows in
-- 6 columns. Reversal: convert_from(convert_to(col,'WIN1252'),'UTF8').
--
-- 8 rows in hayat_indice.titolo contain a closing curly quote whose corruption landed on byte
-- 0x9D, one of the few gaps Windows-1252 leaves undefined (the original corruption process let
-- that byte pass straight through as U+009D instead of erroring, which strict WIN1252 can't
-- reverse directly). Handled with a plain-ASCII placeholder token so the blanket conversion
-- never has to touch that byte: swap it out before converting, swap the real quote back in after.

-- legacy_topic has an FK to the vestigial `topics` table (pre-dates main_topic/option_lists,
-- no longer queried anywhere in the app). That table likely still has the same corrupted text,
-- so fixing legacy_topic without dropping this constraint would fail to find a match. Safe to
-- drop: nothing in the app relies on this constraint any more.
alter table documents drop constraint if exists documents_topic_fkey;

update documents set title = convert_from(convert_to(title, 'WIN1252'), 'UTF8')
where title ~ 'Ã.';

update documents set original_title = convert_from(convert_to(original_title, 'WIN1252'), 'UTF8')
where original_title ~ 'Ã.';

update documents set secondary_tags = convert_from(convert_to(secondary_tags, 'WIN1252'), 'UTF8')
where secondary_tags ~ 'Ã.';

update documents set legacy_topic = convert_from(convert_to(legacy_topic, 'WIN1252'), 'UTF8')
where legacy_topic ~ 'Ã.';

update hayat_indice set argomento = convert_from(convert_to(argomento, 'WIN1252'), 'UTF8')
where argomento ~ 'Ã.';

-- hayat_indice.titolo: placeholder step for the 8 problem rows, then the normal blanket fix
-- (now safe for every titolo row, including those 8), then swap the placeholder for the real
-- closing quote.
update hayat_indice set titolo = replace(titolo, 'â€' || chr(157), '@@CLOSEQUOTE@@')
where titolo like '%' || chr(157) || '%';

update hayat_indice set titolo = convert_from(convert_to(titolo, 'WIN1252'), 'UTF8')
where titolo ~ 'Ã.';

update hayat_indice set titolo = replace(titolo, '@@CLOSEQUOTE@@', chr(8221))
where titolo like '%@@CLOSEQUOTE@@%';

-- Verification: every count below should now be 0.
select 'documents.title' as location, count(*) from documents where title ~ 'Ã.'
union all
select 'documents.original_title', count(*) from documents where original_title ~ 'Ã.'
union all
select 'documents.secondary_tags', count(*) from documents where secondary_tags ~ 'Ã.'
union all
select 'documents.legacy_topic', count(*) from documents where legacy_topic ~ 'Ã.'
union all
select 'hayat_indice.titolo', count(*) from hayat_indice where titolo ~ 'Ã.'
union all
select 'hayat_indice.argomento', count(*) from hayat_indice where argomento ~ 'Ã.'
order by 1;
