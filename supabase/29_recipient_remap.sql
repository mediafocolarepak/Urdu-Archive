-- Fixes the "Recipient" (capital R) typo on the Seminarians row - as-is it's invisible to the
-- app, which always queries list_name = 'recipient' (lowercase, exact match).
update option_lists set list_name = 'recipient' where list_name = 'Recipient';

-- Remaps every document's to_whom (old, messy free text) to the new cleaned-up recipient code,
-- and writes that same code into recipient (the field the app actually uses for the dropdown/
-- filter) - confirmed mapping, 2026-08-25.
update documents d
set to_whom = v.new_value,
    recipient = array[v.new_value]
from (values
  ('Assemblea Generale', 'General Assembly'),
  ('Capizona', 'Capizona'),
  ('Comune di Bologna', 'Internals'),
  ('Famiglie', 'Families'),
  ('Festa di Santa Chiara', 'Internals'),
  ('Focolarini', 'Focolarini/Focolarine'),
  ('Focolarini Esterni', 'Focolarini Formation'),
  ('gen 2', 'Gen 2'),
  ('Gen 2', 'Gen 2'),
  ('gen 2f', 'Gen 2'),
  ('Gen 3', 'Gen 3'),
  ('Gen 4', 'Gen 4'),
  ('GenFest', 'Youth'),
  ('Genfest 95', 'Youth'),
  ('Giovani', 'Youth'),
  ('Interni', 'Internals'),
  ('Mov. Dioc.', 'Mov. Dioc.'),
  ('Prevolontarie', 'PreVolunteers'),
  ('Religiosi', 'Religious'),
  ('Vescovi', 'Bishops'),
  ('Volontari', 'Volunteers'),
  ('volontarie', 'Volunteers')
) as v(old_value, new_value)
where d.to_whom = v.old_value;

select 'documents updated' as label, count(*) as n
from documents
where to_whom in (
  'General Assembly','Capizona','Internals','Families','Focolarini/Focolarine',
  'Focolarini Formation','Gen 2','Gen 3','Gen 4','Youth','Mov. Dioc.','PreVolunteers',
  'Religious','Bishops','Volunteers'
);
