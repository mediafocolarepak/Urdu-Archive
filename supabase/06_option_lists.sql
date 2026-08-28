-- Makes every dropdown list admin-editable instead of hardcoded in the app.
-- Run after 05_roles_and_permissions.sql.

create table if not exists option_lists (
  list_name text not null,
  code text not null,
  label text not null,
  sort_order integer not null default 0,
  primary key (list_name, code)
);
alter table option_lists enable row level security;

drop policy if exists "read - option_lists" on option_lists;
create policy "read - option_lists" on option_lists for select to authenticated using (current_role_is('user'));
drop policy if exists "admin write - option_lists" on option_lists;
create policy "admin write - option_lists" on option_lists for all to authenticated
  using (current_role_is('admin')) with check (current_role_is('admin'));

-- The fixed vocabulary now lives here instead of in a rigid CHECK constraint, so it can grow.
-- Enforcement moves to the app layer (dropdowns only ever offer these values); the DB no longer
-- rejects an unrecognized code, matching how the "recipient" array field already worked.
alter table documents drop constraint if exists documents_category_check;
alter table documents drop constraint if exists documents_author_check;
alter table documents drop constraint if exists documents_main_topic_check;
alter table documents drop constraint if exists documents_workflow_status_check;
alter table documents drop constraint if exists documents_original_lang_check;

insert into option_lists (list_name, code, label, sort_order) values
  ('category', 'DISC', 'Discourse', 1),
  ('category', 'LINK', 'Linkage (Collegamento)', 2),
  ('category', 'WORD', 'Word of Life', 3),
  ('category', 'EXPE', 'Experience', 4),
  ('category', 'DIAR', 'Diary', 5),
  ('category', 'MEDI', 'Meditation', 6),
  ('category', 'PAR4', 'Paradise ''49', 7),
  ('category', 'REGU', 'Regulation', 8),
  ('category', 'LETT', 'Letter', 9),
  ('category', 'MISC', 'Miscellaneous / Other', 10),

  ('author', 'CHIA', 'Chiara Lubich', 1),
  ('author', 'IGIN', 'Igino Giordani (Foco)', 2),
  ('author', 'KLAU', 'Klaus Hemmerle', 3),
  ('author', 'PAPA', 'Papal / Church Document', 4),
  ('author', 'OFFI', 'Official Movement Document', 5),
  ('author', 'OTHR', 'Other', 6),

  ('main_topic', '12PO', '12 Points of Spirituality', 1),
  ('main_topic', '7COL', '7 Colors (Concrete Life Aspects)', 2),
  ('main_topic', '5TOO', '5 Tools of Communion', 3),
  ('main_topic', 'ARTL', 'Art of Loving', 4),
  ('main_topic', 'PRAY', 'Prayer / Liturgy', 5),
  ('main_topic', 'HIST', 'History / Movement Facts', 6),
  ('main_topic', 'GENR', 'General / Mixed', 7),

  ('original_lang', 'ITA', 'Italian', 1),
  ('original_lang', 'ENG', 'English', 2),
  ('original_lang', 'FRA', 'French', 3),
  ('original_lang', 'SPA', 'Spanish', 4),
  ('original_lang', 'URD', 'Urdu (Originally written)', 5),

  ('workflow_status', 'ENTR', 'Entry', 1),
  ('workflow_status', 'TYP', 'Typing', 2),
  ('workflow_status', 'PROF', 'Proofing', 3),
  ('workflow_status', 'CORR', 'Correction', 4),
  ('workflow_status', 'APPR', 'Approved', 5),
  ('workflow_status', 'STOR', 'Stored', 6),

  ('recipient', 'GEN2', 'Gen2', 1),
  ('recipient', 'GEN3', 'Gen3', 2),
  ('recipient', 'GEN4', 'Gen4', 3),
  ('recipient', 'VOLU', 'Volunteers', 4),
  ('recipient', 'FAMI', 'Families', 5),
  ('recipient', 'FOCL', 'Focolarini', 6),
  ('recipient', 'SUOR', 'Religious Sisters', 7),
  ('recipient', 'SACE', 'Priests', 8),
  ('recipient', 'VESC', 'Bishops', 9),
  ('recipient', 'UMAN', 'New Humanity', 10),
  ('recipient', 'GMUW', 'Youth for a United World', 11),
  ('recipient', 'ALTR', 'Other', 12)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

-- Remap the 471 already-migrated documents' recipient codes to the new list above.
update documents set recipient = array_replace(recipient, 'BISH', 'VESC') where 'BISH' = any(recipient);
update documents set recipient = array_replace(recipient, 'PRIE', 'SACE') where 'PRIE' = any(recipient);
update documents set recipient = array_replace(recipient, 'VOLM', 'VOLU') where 'VOLM' = any(recipient);
update documents set recipient = array_replace(recipient, 'VOLF', 'VOLU') where 'VOLF' = any(recipient);
update documents set recipient = array_replace(recipient, 'NEWF', 'FAMI') where 'NEWF' = any(recipient);
update documents set recipient = array_replace(recipient, 'FOCM', 'FOCL') where 'FOCM' = any(recipient);
update documents set recipient = array_replace(recipient, 'FOCF', 'FOCL') where 'FOCF' = any(recipient);
update documents set recipient = array_remove(recipient, 'ALL') where 'ALL' = any(recipient);

select 'option_lists installed, rows=' || count(*) as result from option_lists;
