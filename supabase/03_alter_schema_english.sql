-- Focolare Urdu Archive Manager - English schema upgrade.
-- Run in the Supabase SQL Editor AFTER 01_schema.sql / 02_seed_data.sql have already run.
-- No begin/commit wrapper: the pooled SQL Editor connection does not reliably commit
-- explicit multi-statement transactions (see prior troubleshooting in this project).

-- 1. Preserve old free-text fields under legacy_ names (kept for the Libri/Processi/Hayat/Stampe tabs).
alter table documents rename column category to legacy_category;
alter table documents rename column author to legacy_author;
alter table documents rename column topic to legacy_topic;
alter table documents rename column status to legacy_status;
alter table documents rename column file_name to legacy_file_name;
alter table documents rename column date to ref_date;
alter table documents rename column note to notes;

-- 2. New fixed-vocabulary fields for the English schema.
alter table documents add column if not exists category text;
alter table documents add column if not exists author text;
alter table documents add column if not exists main_topic text;
alter table documents add column if not exists secondary_tags text;
alter table documents add column if not exists recipient text[];
alter table documents add column if not exists original_lang text default 'ITA';
alter table documents add column if not exists ref_period text;
alter table documents add column if not exists workflow_status text default 'ENTR';
alter table documents add column if not exists physical_box text;
alter table documents add column if not exists file_name text;
alter table documents add column if not exists storage_path text;
alter table documents add column if not exists legacy_migrated boolean not null default false;
alter table documents add column if not exists created_at timestamptz not null default now();

alter table documents add constraint documents_file_name_unique unique (file_name);

alter table documents add constraint documents_category_check
  check (category is null or category in ('DISC','LINK','WORD','EXPE','DIAR','MEDI','PAR4','REGU','LETT','MISC'));
alter table documents add constraint documents_author_check
  check (author is null or author in ('CHIA','IGIN','KLAU','PAPA','OFFI','OTHR'));
alter table documents add constraint documents_main_topic_check
  check (main_topic is null or main_topic in ('12PO','7COL','5TOO','ARTL','PRAY','HIST','GENR'));
alter table documents add constraint documents_workflow_status_check
  check (workflow_status in ('ENTR','TYP','PROF','CORR','APPR','STOR'));
alter table documents add constraint documents_original_lang_check
  check (original_lang is null or original_lang in ('ITA','ENG','FRA','SPA','URD'));

create index if not exists idx_documents_category_new on documents(category);
create index if not exists idx_documents_main_topic on documents(main_topic);
create index if not exists idx_documents_workflow_status on documents(workflow_status);
create index if not exists idx_documents_legacy_migrated on documents(legacy_migrated);
create index if not exists idx_documents_recipient on documents using gin(recipient);

-- 3. Storage bucket for uploaded PDF/Word files, private, team-only.
insert into storage.buckets (id, name, public)
  values ('archive-files', 'archive-files', false)
  on conflict (id) do nothing;

create policy "team read - archive-files" on storage.objects for select
  to authenticated using (bucket_id = 'archive-files');
create policy "team upload - archive-files" on storage.objects for insert
  to authenticated with check (bucket_id = 'archive-files');
create policy "team update - archive-files" on storage.objects for update
  to authenticated using (bucket_id = 'archive-files');
create policy "team delete - archive-files" on storage.objects for delete
  to authenticated using (bucket_id = 'archive-files');

select 'schema upgrade complete' as result;
