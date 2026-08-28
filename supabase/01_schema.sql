-- Urdu Transcriptions catalog - Supabase (Postgres) schema
-- Paste this into the Supabase SQL Editor and run it once, before running 02_seed_data.sql.

create table if not exists document_categories (
  cat_id text primary key,
  document_category text,
  "order" integer,
  book text,
  computer_file text
);

create table if not exists topics (
  topic text primary key,
  topic_eng text,
  class text,
  topic_order integer,
  class_order integer
);

create table if not exists process_categories (
  category_id text primary key,
  process_category text,
  description text
);

create table if not exists process (
  process_id text primary key,
  category text references process_categories(category_id),
  step integer,
  description text,
  dateline date,
  note text
);

create table if not exists months (
  id text primary key,
  month text,
  month_long text,
  year_long text
);

create table if not exists documents (
  document_id integer primary key,
  category text references document_categories(cat_id),
  title text,
  original_title text,
  author text,
  place text,
  date date,
  to_whom text,
  "position" text,
  topic text references topics(topic),
  file_name text,
  short_name text,
  status text,
  process integer,
  video text,
  hayat_issue text,
  hayat_index_ref integer,
  entered date,
  printed date,
  file_page text,
  book text,
  book_page integer,
  note text,
  updated_at timestamptz not null default now(),
  updated_by text
);

create table if not exists hayat_indice (
  id integer primary key,
  mese_anno text,
  pagina integer,
  categoria text,
  category text references document_categories(cat_id),
  branca text,
  autore text,
  titolo text,
  argomento text,
  data_pdv text,
  title text,
  estratto date,
  idtranscription integer,
  book_page integer,
  updated_at timestamptz not null default now()
);

create index if not exists idx_documents_category on documents(category);
create index if not exists idx_documents_topic on documents(topic);
create index if not exists idx_documents_book on documents(book);
create index if not exists idx_documents_status on documents(status);
create index if not exists idx_hayat_indice_category on hayat_indice(category);

-- Convenience views - computed live instead of the stale "precomputed query" tables Access used
create or replace view v_documents_by_category as
  select d.*, dc.document_category, t.topic_eng
  from documents d
  left join document_categories dc on d.category = dc.cat_id
  join topics t on d.topic = t.topic
  order by dc.document_category, d.title;

create or replace view v_documents_by_topic as
  select d.*, dc.document_category, t.topic_eng, t.class, t.topic_order, t.class_order
  from documents d
  left join document_categories dc on d.category = dc.cat_id
  join topics t on d.topic = t.topic
  order by t.class_order, t.topic_order;

-- Row Level Security: any signed-in team member can read/write.
-- Refine later with per-user roles if you need finer-grained permissions.
alter table document_categories enable row level security;
alter table topics enable row level security;
alter table process_categories enable row level security;
alter table process enable row level security;
alter table months enable row level security;
alter table documents enable row level security;
alter table hayat_indice enable row level security;

create policy "team read/write - document_categories" on document_categories for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "team read/write - topics" on topics for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "team read/write - process_categories" on process_categories for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "team read/write - process" on process for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "team read/write - months" on months for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "team read/write - documents" on documents for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "team read/write - hayat_indice" on hayat_indice for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
