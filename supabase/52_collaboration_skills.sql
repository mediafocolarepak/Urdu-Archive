-- 52_collaboration_skills.sql
-- Seeds the "collaboration_skill" option_lists list used by the "Join the Team" form's Skills
-- checkboxes (js/collaboration.js). Admin-editable afterwards from the Options tab like any
-- other list (option_lists RLS already allows this - see 06_option_lists.sql).

insert into option_lists (list_name, code, label, sort_order) values
  ('collaboration_skill', 'URDU_RW', 'Urdu read/write', 1),
  ('collaboration_skill', 'URDU_INPAGE', 'Urdu typing in INPAGE', 2),
  ('collaboration_skill', 'URDU_WORD', 'Urdu typing in Word', 3),
  ('collaboration_skill', 'GRAPHICS_PRESENTATIONS', 'Computer graphic/Presentations', 4),
  ('collaboration_skill', 'VIDEO_AUDIO', 'Video/Audio editing', 5),
  ('collaboration_skill', 'MS_WINDOWS_FILES', 'MS Windows/Files managements', 6),
  ('collaboration_skill', 'COMMS_MEDIA', 'Communication & Media expert', 7),
  ('collaboration_skill', 'WRITER_CONTENT', 'Writer/Content creator', 8)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;
