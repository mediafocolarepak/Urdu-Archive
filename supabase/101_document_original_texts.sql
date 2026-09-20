-- 101_document_original_texts.sql
-- The Italian (or other source-language) original text of a document, alongside its Urdu
-- translation (document_texts, migration 68) - owner's request 2026-09-20, after confirming that
-- a Google Drive folder of ~150 Italian Collegamenti PDFs carries the exact same 5-digit ID as
-- this archive's document_id (spot-checked on 5 documents, all matched). Kept as its own table,
-- same reasoning as 68_document_texts.sql: documents is the hot table the Dashboard queries on
-- every keystroke, a multi-KB text column doesn't belong on it, and the join is 1:1 (well, 1:N by
-- language) so the cost is only paid when the text is actually opened.
--
-- Unlike Urdu, Italian has a real Postgres full-text search configuration (to_tsvector('italian',
-- ...)) - no custom normalization function needed the way urdu_norm() was for document_texts.
--
-- This migration creates the structure only. Loading the ~150 texts is a separate step (the
-- owner is exporting them from Google Drive for bulk import).

-- 1. The table. `language` even though today only 'ITA' is populated: documents.original_lang
-- (03_alter_schema_english.sql) already allows ENG/FRA/SPA too, so a future original in another
-- language has somewhere to go without a schema change. Composite primary key (not document_id
-- alone) for the same reason - nothing today needs two originals for one document, but nothing
-- should have to change if it ever happens.
create table if not exists public.document_original_texts (
  document_id        integer     not null references public.documents(document_id) on delete cascade,
  language            text        not null default 'ITA' check (language in ('ITA', 'ENG', 'FRA', 'SPA')),
  body                text        not null,
  body_tsv            tsvector    generated always as (to_tsvector('italian', body)) stored,
  char_count          integer     generated always as (length(body)) stored,
  -- where this text came from: typed/pasted in by hand, OCR, or imported from a Google Drive
  -- export (the expected path for the initial ~150 Collegamenti).
  source              text        not null default 'drive_import' check (source in ('typed', 'ocr', 'drive_import')),
  source_file         text,
  -- false until a human has read it against the source - same "unverified until reviewed"
  -- philosophy as document_texts, even though a Drive-exported text layer is normally reliable.
  reviewed            boolean     not null default false,
  reviewed_by_email   text,
  reviewed_at         timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  updated_by_email    text,
  primary key (document_id, language)
);

-- 2. Indexes: full-text on the Italian body, and a plain index for "does this document have an
-- original text at all" lookups (docdetail.js will need this to decide whether to show the
-- button at all).
create index if not exists idx_document_original_texts_tsv
  on public.document_original_texts using gin (body_tsv);
create index if not exists idx_document_original_texts_document_id
  on public.document_original_texts (document_id);

-- 3. updated_at trigger, same shape as document_texts'.
create or replace function public.touch_document_original_texts()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
drop trigger if exists trg_touch_document_original_texts on public.document_original_texts;
create trigger trg_touch_document_original_texts before update on public.document_original_texts
  for each row execute function public.touch_document_original_texts();

-- 4. RLS - same tiers as document_texts: everyone reads, Operator+ writes, only Admin deletes.
alter table public.document_original_texts enable row level security;

drop policy if exists "document_original_texts_select" on public.document_original_texts;
create policy "document_original_texts_select" on public.document_original_texts
  for select using (current_role_is('user'));

drop policy if exists "document_original_texts_insert" on public.document_original_texts;
create policy "document_original_texts_insert" on public.document_original_texts
  for insert with check (current_role_is('operator'));

drop policy if exists "document_original_texts_update" on public.document_original_texts;
create policy "document_original_texts_update" on public.document_original_texts
  for update using (current_role_is('operator')) with check (current_role_is('operator'));

drop policy if exists "document_original_texts_delete" on public.document_original_texts;
create policy "document_original_texts_delete" on public.document_original_texts
  for delete using (current_role_is('admin'));

-- 5. Search, mirroring search_document_texts()'s shape (68_document_texts.sql) so the two can
-- eventually sit side by side in the Dashboard's search if the owner wants that later -
-- websearch_to_tsquery so a plain phrase typed by a person works without needing tsquery syntax.
create or replace function public.search_document_original_texts(q text, lim integer default 100)
returns table (document_id integer, language text, snippet text, reviewed boolean)
language sql
stable
as $$
  select dot.document_id, dot.language,
         ts_headline('italian', dot.body, websearch_to_tsquery('italian', q),
                     'MaxFragments=1, MaxWords=30, MinWords=15'),
         dot.reviewed
  from public.document_original_texts dot
  where q <> '' and dot.body_tsv @@ websearch_to_tsquery('italian', q)
  limit lim;
$$;

-- ============================================================================
-- Self-test (run separately). All rows must be true.
-- ============================================================================
select 'table document_original_texts' as item, (to_regclass('public.document_original_texts') is not null) as ok
union all select 'policies document_original_texts (4)', (select count(*) = 4 from pg_policies where tablename = 'document_original_texts')
union all select 'function search_document_original_texts', exists (select 1 from pg_proc where proname = 'search_document_original_texts');
