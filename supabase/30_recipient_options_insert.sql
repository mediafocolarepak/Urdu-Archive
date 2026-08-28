insert into option_lists (list_name, code, label, sort_order) values
  ('recipient', 'Others', 'Others', 20),
  ('recipient', 'General Assembly', 'General Assembly', 19),
  ('recipient', 'Capizona', 'Capizona', 2),
  ('recipient', 'Internals', 'Internals', 0),
  ('recipient', 'Families', 'Families', 15),
  ('recipient', 'Focolarini/Focolarine', 'Focolarini/Focolarine', 1),
  ('recipient', 'Focolarini Formation', 'Focolarini Formation', 2),
  ('recipient', 'Gen 2', 'gen 2', 3),
  ('recipient', 'Gen 3', 'Gen 3', 4),
  ('recipient', 'Gen 4', 'Gen 4', 5),
  ('recipient', 'Youth', 'Youth', 16),
  ('recipient', 'Mov. Dioc.', 'Mov. Dioc./Parr.', 17),
  ('recipient', 'PreVolunteers', 'PreVolunteers', 8),
  ('recipient', 'Religious', 'Religious', 10),
  ('recipient', 'Priests', 'Priests', 13),
  ('recipient', 'New Umanity', 'New Humanity', 18),
  ('recipient', 'Bishops', 'Bishops', 14),
  ('recipient', 'Volunteers', 'Volunteers', 11),
  ('recipient', 'Seminarians', 'Seminarians', 12)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

select 'recipient options' as label, count(*) as n from option_lists where list_name = 'recipient';
