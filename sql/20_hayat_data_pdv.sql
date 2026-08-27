-- New CSV exports of the Hayat index (extracted from scanned PDFs) carry a "data_pdv" field:
-- the actual month/year a Parola di Vita (Word of Life) entry refers to, which can differ from
-- the physical edition's own mese_anno (e.g. the May issue prints June's Word of Life). No
-- existing column captures this, so it needs its own.
-- Run once in the Supabase Dashboard -> SQL Editor. Safe to re-run.

alter table public.hayat_indice add column if not exists data_pdv text;
