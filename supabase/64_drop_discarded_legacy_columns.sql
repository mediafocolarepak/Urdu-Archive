-- 64_drop_discarded_legacy_columns.sql
-- Second batch of the documents schema cleanup (2026-09-03 session). These columns carried
-- some historical data (per _check_dead_fields_audit.sql: entered 361/1807, printed 100,
-- process 220, position 4, video_ref 2, match_ref 1) but were confirmed by the user as safe to
-- discard - unlike book/book_page/short_name/file_page/video, which are kept for a later
-- decision on whether to migrate them into a current field.

alter table public.documents
  drop column if exists entered,
  drop column if exists printed,
  drop column if exists process,
  drop column if exists "position",
  drop column if exists video_ref,
  drop column if exists match_ref;
