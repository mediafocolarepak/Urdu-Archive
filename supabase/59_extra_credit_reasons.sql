-- 59_extra_credit_reasons.sql
-- Turns the "Why the extra credits?" free-text field on task creation (js/docdetail.js,
-- js/tasks.js) into an admin-editable dropdown, same pattern as report_type (55) and
-- collaboration_skill (52).

insert into option_lists (list_name, code, label, sort_order) values
  ('extra_credit_reason', 'URGENT', 'Urgent basis', 1),
  ('extra_credit_reason', 'DIFFICULT_TEXT', 'More difficult text', 2),
  ('extra_credit_reason', 'MORE_LINES', 'More lines than usual', 3)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;
