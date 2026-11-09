-- 132: the guides use the new button names in Library and Dashboard (Owner's request, 2026-11-09). The filters now
-- open from a button called "Search", and "Clear all filters and search" is now "Clear all search", beside it.
-- Only these two Latin button names change, in English, Italian and Urdu; no other word of any guide is touched.
-- Run this BEFORE merging the PR. Safe to run again.

update public.help_pages
   set html_content = replace(html_content, '<b>Clear all filters and search</b>', '<b>Clear all search</b>'),
       updated_at = now()
 where html_content like '%<b>Clear all filters and search</b>%';

update public.help_pages
   set html_content = replace(html_content, '<b>Filters</b>', '<b>Search</b>'),
       updated_at = now()
 where guide_key = 'find-read' and html_content like '%<b>Filters</b>%';

-- Every row should say true.
select 'no guide names the old Clear button' as item,
       not exists (select 1 from public.help_pages where html_content like '%Clear all filters and search%') as ok
union all
select 'Find and read names Clear all search, in 3 languages',
       (select count(*) = 3 from public.help_pages where guide_key = 'find-read' and html_content like '%<b>Clear all search</b>%')
union all
select 'Find and read names the Search button, in 3 languages',
       (select count(*) = 3 from public.help_pages where guide_key = 'find-read' and html_content not like '%<b>Filters</b>%' and html_content like '%<b>Search</b>%')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
