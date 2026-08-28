-- Controlled-vocabulary tagging layer for the tag-extraction tool (tools/tag-extraction).
-- ADDITIVE ONLY: does not touch the existing columns on documents (category, main_topic,
-- secondary_tags, recipient) - those stay exactly as they are for the rest of the app.
-- Run once in the Supabase Dashboard -> SQL Editor. Safe to re-run.

-- Controlled vocabulary --------------------------------------------------
create table if not exists public.tag (
  tag_id        text primary key,
  faccetta      text not null,
  etichetta_it  text,
  etichetta_en  text,
  etichetta_ur  text,
  broader       text references public.tag(tag_id),
  creato_il     timestamptz default now()
);

comment on table  public.tag is 'Controlled facet vocabulary. tag_id never changes: it is the key.';
comment on column public.tag.broader is 'Parent tag: enables broadened search to children.';

create index if not exists idx_tag_faccetta on public.tag (faccetta);

-- Document <-> tag assignments -------------------------------------------
create table if not exists public.documento_tag (
  document_id  bigint not null,
  tag_id       text   not null references public.tag(tag_id),
  punteggio    numeric(6,2) default 0,
  confidenza   text default 'media' check (confidenza in ('alta','media','da_rivedere')),
  origine      text default 'auto'  check (origine in ('auto','metadato','cartella','umano')),
  creato_il    timestamptz default now(),
  primary key (document_id, tag_id)
);

comment on column public.documento_tag.origine is
  'auto = extracted from text; metadato = inferred from fields; cartella = from InPage folder structure; umano = entered/corrected by hand. Lets a re-run of the extraction delete ONLY the auto rows, preserving human corrections.';

create index if not exists idx_doctag_tag on public.documento_tag (tag_id);
create index if not exists idx_doctag_doc on public.documento_tag (document_id);

-- Extracted text (optional but recommended) -------------------------------
-- Keeping the text avoids re-decoding files on every re-run and enables full-text search.
create table if not exists public.documento_testo (
  document_id  bigint primary key,
  fonte        text check (fonte in ('inp','docx','pdf','txt')),
  testo        text,
  testo_norm   text,      -- normalized form: full-text search runs against this
  caratteri    integer,
  estratto_il  timestamptz default now()
);

create index if not exists idx_testo_fts
  on public.documento_testo using gin (to_tsvector('simple', coalesce(testo_norm,'')));

-- Convenience view for the UI ----------------------------------------------
create or replace view public.v_documento_tag as
select dt.document_id, dt.tag_id, t.faccetta,
       t.etichetta_it, t.etichetta_en, t.etichetta_ur,
       dt.punteggio, dt.confidenza, dt.origine
from public.documento_tag dt
join public.tag t using (tag_id);

-- Broadened search: every document tagged with p_tag or any of its descendants
create or replace function public.documenti_per_tag(p_tag text)
returns table (document_id bigint) language sql stable as $$
  with recursive albero as (
    select tag_id from public.tag where tag_id = p_tag
    union all
    select t.tag_id from public.tag t join albero a on t.broader = a.tag_id
  )
  select distinct dt.document_id
  from public.documento_tag dt
  join albero a on a.tag_id = dt.tag_id;
$$;

-- RLS: readable by any signed-in app user (same bar as documents/option_lists), writable
-- only via the CLI's service role key (tools/tag-extraction), which bypasses RLS entirely -
-- no insert/update policy is needed for the client.
alter table public.tag enable row level security;
drop policy if exists "tag_select_authenticated" on public.tag;
create policy "tag_select_authenticated" on public.tag
  for select using (exists (select 1 from public.user_roles ur where ur.user_id = auth.uid()));

alter table public.documento_tag enable row level security;
drop policy if exists "documento_tag_select_authenticated" on public.documento_tag;
create policy "documento_tag_select_authenticated" on public.documento_tag
  for select using (exists (select 1 from public.user_roles ur where ur.user_id = auth.uid()));

alter table public.documento_testo enable row level security;
drop policy if exists "documento_testo_select_authenticated" on public.documento_testo;
create policy "documento_testo_select_authenticated" on public.documento_testo
  for select using (exists (select 1 from public.user_roles ur where ur.user_id = auth.uid()));
