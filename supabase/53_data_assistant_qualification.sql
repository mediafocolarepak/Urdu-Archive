-- 53_data_assistant_qualification.sql
-- New "Data Assistant" Operator qualification: an Operator holding it keeps seeing the
-- cataloguing tools (Hayat Index, Match Review, Work Consolidation, Hayat Editor, Bulk Import)
-- that are otherwise hidden from the Operator role (see js/app.js getTabs()). This is a
-- client-side UI gate only, mirroring the pattern used for Translator/Revisor - it does not by
-- itself change RLS/table permissions.

insert into option_lists (list_name, code, label, sort_order) values
  ('operator_qualification', 'DATA_ASSISTANT', 'Data Assistant', 5)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;
