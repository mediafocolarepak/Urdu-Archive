-- _check_dead_fields_audit.sql (diagnostic only, not a migration - nothing to apply)
-- Checks whether the candidate "dead" columns found in the 2026-09-03 documents-table field
-- audit are actually empty among source='STE' records (the current, real dataset per that
-- session's discussion) vs. across the whole table (which still carries the pre-2006-schema
-- historical import). Run both queries and compare.

-- 1) Among source='STE' records only - the "present" dataset.
select
  count(*) as ste_total,
  count(short_name) as short_name_filled,
  count(entered) as entered_filled,
  count(printed) as printed_filled,
  count(file_page) as file_page_filled,
  count(book_page) as book_page_filled,
  count(updated_by) as updated_by_filled,
  count(match_ref) as match_ref_filled,
  count(video_ref) as video_ref_filled,
  count(pdv_ref) as pdv_ref_filled,
  count(*) filter (where has_video is true) as has_video_true,
  count("position") as position_filled,
  count(process) as process_filled,
  count(video) as video_filled,
  count(book) as book_filled,
  count(collection) as collection_filled
from documents
where source = 'STE';

-- 2) Across the WHOLE table, for comparison - how much historical data actually lives in
--    these columns, in case any of it is worth migrating into a current field before dropping.
select
  count(*) as total_documents,
  count(short_name) as short_name_filled,
  count(entered) as entered_filled,
  count(printed) as printed_filled,
  count(file_page) as file_page_filled,
  count(book_page) as book_page_filled,
  count(updated_by) as updated_by_filled,
  count(match_ref) as match_ref_filled,
  count(video_ref) as video_ref_filled,
  count(pdv_ref) as pdv_ref_filled,
  count(*) filter (where has_video is true) as has_video_true,
  count("position") as position_filled,
  count(process) as process_filled,
  count(video) as video_filled,
  count(book) as book_filled,
  count(collection) as collection_filled
from documents;
