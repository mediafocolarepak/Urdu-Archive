-- v2 data model: Works (grouping translations/versions of the same title), provenance,
-- media type, collection, video quality/duration, and a real process-step history log.

create table if not exists works (
  work_id bigserial primary key,
  canonical_title text,
  notes text,
  created_at timestamptz not null default now()
);
alter table works enable row level security;
drop policy if exists "read - works" on works;
create policy "read - works" on works for select to authenticated using (current_role_is('user'));
drop policy if exists "write - works" on works;
create policy "write - works" on works for all to authenticated
  using (current_role_is('operator')) with check (current_role_is('operator'));

create table if not exists process_history (
  id bigserial primary key,
  document_id integer references documents(document_id) on delete cascade,
  step text,
  step_date date,
  note text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
alter table process_history enable row level security;
drop policy if exists "read - process_history" on process_history;
create policy "read - process_history" on process_history for select to authenticated using (current_role_is('user'));
drop policy if exists "write - process_history" on process_history;
create policy "write - process_history" on process_history for all to authenticated
  using (current_role_is('operator')) with check (current_role_is('operator'));
create index if not exists idx_process_history_document on process_history(document_id);

alter table documents add column if not exists media_type text;
alter table documents add column if not exists provenance text;
alter table documents add column if not exists collection text;
alter table documents add column if not exists work_id bigint references works(work_id);
alter table documents add column if not exists duration text;
alter table documents add column if not exists quality text;
create index if not exists idx_documents_work_id on documents(work_id);
create index if not exists idx_documents_provenance on documents(provenance);

insert into option_lists (list_name, code, label, sort_order) values
  ('media_type', 'DOC', 'Document', 1),
  ('media_type', 'VID', 'Video', 2),
  ('provenance', 'LEGACY', 'Legacy', 1),
  ('provenance', 'HAYAT', 'Hayat magazine', 2),
  ('quality', 'GOOD', 'Good', 1),
  ('quality', 'POOR', 'Poor', 2),
  ('quality', 'BAD', 'Bad', 3)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

-- Seed the "collection" option list from whatever distinct values already exist in the
-- legacy `book` field, so nothing already in use is missing from the new dropdown.
insert into option_lists (list_name, code, label, sort_order)
select 'collection',
       upper(regexp_replace(book, '[^a-zA-Z0-9]+', '_', 'g')),
       book,
       row_number() over (order by book)
from (select distinct book from documents where book is not null and book <> '') b
on conflict (list_name, code) do nothing;

select 'v2 schema ready: works=' || (select count(*) from works)
  || ', process_history=' || (select count(*) from process_history)
  || ', collection options=' || (select count(*) from option_lists where list_name = 'collection') as result;
