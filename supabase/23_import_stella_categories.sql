-- Imports the category/topic/year/author corrections from "Stella Files and Categories.csv"
-- (converted to UTF-8, typo codes normalized: 'Ge 3'->'Ge3', 'Coll'->'Col') onto matching
-- documents (documents.title = csv FileName).
--
-- Matching rule for titles that appear with more than one Category in the CSV (confirmed with
-- the user 2026-08-24): if documents has exactly that many rows sharing the same title, assign
-- them the categories in the same order (lowest document_id <-> first category encountered in
-- the file); if there's only one matching document, it gets the first category encountered.

-- ============================================================
-- STEP 0 - one-time manual step (not SQL): import the CSV as a new table.
-- In Supabase Studio: Table Editor -> Insert -> "Import data from CSV/text",
-- upload H:\Project Urdu Claude\stella_files_categories_utf8.csv (tab-delimited),
-- name the new table "stella_import". It will auto-create text columns
-- FileName, Topic, Year, Category, Autore.
-- ============================================================

-- ============================================================
-- STEP 1 - add the 17 new category codes (nothing else in option_lists is touched)
-- ============================================================
insert into option_lists (list_name, code, label, sort_order) values
  ('category', 'Ge2', 'Gen 2', 100),
  ('category', 'Ge3', 'Gen 3', 101),
  ('category', 'Ge4', 'Gen 4', 102),
  ('category', 'NFa', 'New Families', 103),
  ('category', 'Chi', 'Chiara', 104),
  ('category', 'Dlg', 'Dialogue', 105),
  ('category', 'Col', 'Collections', 106),
  ('category', 'Lett', 'Lettere', 107),
  ('category', 'Chr', 'Church - Pope', 108),
  ('category', 'Sto', 'Storia', 109),
  ('category', 'Vol', 'Volontari', 110),
  ('category', 'Son', 'Songs', 111),
  ('category', 'Mrp', 'Mariapolis', 112),
  ('category', 'Rlg', 'Religious', 113),
  ('category', 'Pra', 'Prayer', 114),
  ('category', 'Ctd', 'Citadels', 115),
  ('category', 'Reg', 'Regulations', 116)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

-- ============================================================
-- STEP 2 - build the matching, one distinct (filename, category) pair per row, in the order
-- each category first appears for that filename (ctid = physical insert order, reliable right
-- after a fresh CSV import with no prior updates/deletes on the table).
-- ============================================================
-- documents.title has no file extension (confirmed 2026-08-24: "Cap 1 La Creazione", not
-- "Cap 1 La Creazione.pdf") - strip it from the CSV filename before matching.
create temp table csv_distinct as
select distinct on (regexp_replace("FileName", '\.[^.]+$', ''), "Category")
  regexp_replace("FileName", '\.[^.]+$', '') as filename, "Category" as category, "Topic" as topic, "Year" as year, "Autore" as autore, ctid as row_pos
from stella_import
order by regexp_replace("FileName", '\.[^.]+$', ''), "Category", ctid;

create temp table csv_ranked as
select filename, category, topic, year, autore,
  row_number() over (partition by filename order by row_pos) as category_rank,
  count(*) over (partition by filename) as category_count
from csv_distinct;

-- Case-insensitive, whitespace-collapsed match key - catches "articolo..." vs "Articolo...",
-- double spaces, etc. without introducing false positives (still a full-title comparison).
create temp table csv_ranked2 as
select *, lower(trim(regexp_replace(filename, '\s+', ' ', 'g'))) as match_key
from csv_ranked;

create temp table doc_ranked as
select document_id, title,
  lower(trim(regexp_replace(title, '\s+', ' ', 'g'))) as match_key,
  row_number() over (partition by lower(trim(regexp_replace(title, '\s+', ' ', 'g'))) order by document_id) as doc_rank
from documents
where lower(trim(regexp_replace(title, '\s+', ' ', 'g'))) in (select distinct match_key from csv_ranked2);

create temp table final_match as
select dr.document_id, cr.category, cr.topic, cr.year, cr.autore
from doc_ranked dr
join csv_ranked2 cr on cr.match_key = dr.match_key and cr.category_rank = least(dr.doc_rank, cr.category_count);

-- ============================================================
-- STEP 3 - PREVIEW (read-only). Run this and check the numbers before STEP 4.
-- ============================================================
select 'csv rows' as label, count(*) as n from stella_import
union all
select 'distinct filenames in csv', count(distinct filename) from csv_ranked2
union all
select 'csv filenames with a matching document', count(distinct match_key) from csv_ranked2 where match_key in (select match_key from doc_ranked)
union all
select 'csv filenames with NO matching document (check titles)', count(distinct match_key) from csv_ranked2 where match_key not in (select match_key from doc_ranked)
union all
select 'documents that will be updated', count(*) from final_match;

-- ============================================================
-- STEP 4 - apply. category is overwritten (that's the point of this import); secondary_tags /
-- ref_period / original_author only fill in where currently blank, so nothing already on file
-- gets clobbered; author is only set to CHIA when Autore is exactly 'Chiara Lubich'.
-- ============================================================
update documents d
set category = fm.category,
    secondary_tags = coalesce(nullif(d.secondary_tags, ''), nullif(fm.topic, '')),
    ref_period = coalesce(nullif(d.ref_period, ''), nullif(fm.year, '')),
    original_author = coalesce(nullif(d.original_author, ''), nullif(fm.autore, '')),
    author = case when fm.autore = 'Chiara Lubich' then 'CHIA' else d.author end
from final_match fm
where fm.document_id = d.document_id;

select 'updated' as label, count(*) from final_match;

drop table if exists csv_distinct, csv_ranked, csv_ranked2, doc_ranked, final_match;
-- stella_import is left in place in case you want to double-check something - drop it yourself
-- once you're happy with the result: drop table if exists stella_import;
