-- Addendum to 19_fix_encoding_corruption.sql: catches rows that only had curly-quote/em-dash/
-- ellipsis style corruption (â€œ, â€™, â€“, â€¦...) with no simple accented letter alongside,
-- so the earlier 'Ã.' filter missed them.
--
-- Two of these rows (hayat_indice.titolo 81 and 92) already had their closing quote fixed by
-- 19_fix_encoding_corruption.sql's placeholder step - re-running a blanket conversion on them
-- now would re-corrupt that already-correct "”" character, so they get the same
-- placeholder-protect treatment before converting the rest of the string.

-- Rows with no already-fixed character mixed in - safe to convert directly.
update documents set title = convert_from(convert_to(title, 'WIN1252'), 'UTF8')
where title ~ 'â€' and title !~ 'Ã.';

update documents set original_title = convert_from(convert_to(original_title, 'WIN1252'), 'UTF8')
where original_title ~ 'â€' and original_title !~ 'Ã.';

update hayat_indice set titolo = convert_from(convert_to(titolo, 'WIN1252'), 'UTF8')
where titolo ~ 'â€' and titolo !~ 'Ã.' and titolo not like '%' || chr(8221) || '%';

-- The two rows with an already-correct closing quote: protect it, convert, restore it.
update hayat_indice set titolo = replace(titolo, chr(8221)::text, '@@ALREADYFIXED@@')
where titolo like '%' || chr(8221) || '%' and titolo ~ 'â€';

update hayat_indice set titolo = convert_from(convert_to(titolo, 'WIN1252'), 'UTF8')
where titolo ~ 'â€' and titolo like '%@@ALREADYFIXED@@%';

update hayat_indice set titolo = replace(titolo, '@@ALREADYFIXED@@', chr(8221))
where titolo like '%@@ALREADYFIXED@@%';

-- Verification: every count below should now be 0.
select 'documents.title' as location, count(*) from documents where title ~ 'â€'
union all
select 'documents.original_title', count(*) from documents where original_title ~ 'â€'
union all
select 'documents.secondary_tags', count(*) from documents where secondary_tags ~ 'â€'
union all
select 'documents.legacy_topic', count(*) from documents where legacy_topic ~ 'â€'
union all
select 'hayat_indice.titolo', count(*) from hayat_indice where titolo ~ 'â€'
union all
select 'hayat_indice.argomento', count(*) from hayat_indice where argomento ~ 'â€'
order by 1;
