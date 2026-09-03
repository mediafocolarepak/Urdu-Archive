-- 63_drop_empty_legacy_columns.sql
-- First step of the documents schema cleanup (2026-09-03 session): drops only the columns
-- confirmed completely empty across the whole table (0 of 1807 rows filled, per
-- _check_dead_fields_audit.sql), so there is zero historical data to lose. A second batch of
-- legacy columns that DO carry historical data not yet represented in any current field
-- (book, book_page, short_name, file_page, video, entered, printed, process, position,
-- video_ref, match_ref) is deliberately NOT touched here - decided keep-or-migrate on a
-- field-by-field basis in a follow-up session, not a blanket drop.

alter table public.documents
  drop column if exists updated_by,
  drop column if exists pdv_ref,
  drop column if exists has_video;
