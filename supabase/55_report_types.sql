-- 55_report_types.sql
-- Moves the "Report a Problem" form's Report type dropdown (js/chat.js) from a hardcoded
-- list into option_lists, admin-editable from Options like every other list.

insert into option_lists (list_name, code, label, sort_order) values
  ('report_type', 'REVISION', 'Revision', 1),
  ('report_type', 'DOWNLOAD_ERROR', 'Download error', 2),
  ('report_type', 'BUG', 'Software bug', 3),
  ('report_type', 'SUGGESTION', 'Suggestion', 4)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;
