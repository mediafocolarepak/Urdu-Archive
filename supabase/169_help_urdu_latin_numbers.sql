-- 169: the Urdu Help guides write numbers in Latin digits (Owner's decision, 2026-11-25), as 168 began to do.
-- Only the digits of the Urdu guides change (title, one-line summary and text); no word is touched, and whether a guide is
-- still a draft does not change. Safe to run again.

update public.help_pages
   set title = translate(title, '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩', '01234567890123456789'),
       summary = translate(summary, '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩', '01234567890123456789'),
       html_content = translate(html_content, '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩', '01234567890123456789'),
       updated_at = now(), updated_by_email = 'migration 169'
 where language = 'ur'
   and concat(title, summary, html_content) ~ '[۰-۹٠-٩]';

-- Every row should say true.
select 'no Urdu digit is left in the Urdu guides' as item,
       not exists (select 1 from public.help_pages where language = 'ur' and concat(title, summary, html_content) ~ '[۰-۹٠-٩]') as ok
union all
select 'English and Italian are untouched',
       not exists (select 1 from public.help_pages where language <> 'ur' and updated_by_email = 'migration 169')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
