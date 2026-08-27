-- Adds a dedicated "Ur-Title" field to documents and hayat_indice, distinct from the
-- existing original_title/titolo columns (per the user's explicit choice: a new, separate
-- field rather than relabeling the existing ones).
-- Run once in the Supabase Dashboard -> SQL Editor. Safe to re-run.

alter table public.documents add column if not exists ur_title text;
alter table public.hayat_indice add column if not exists ur_title text;
