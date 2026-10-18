-- 104_fix_linkup_ref_date_shift.sql
-- Fixes documents.ref_date for the Linkup (Collegamenti) series: ~244 documents carried the date
-- of the FOLLOWING Linkup instead of their own - a one-position shift along the series, with the
-- typical -14 day gap being exactly the fortnightly cadence of the Collegamenti. Two rows (1714
-- and 1772) had their values swapped with each other by the same operation (+/- 2700 days).
--
-- How it surfaced (2026-10-17/18): loading the 273 Italian original texts (migration 101) matched
-- each PDF to a document by the 5-digit id in its Drive file name; a year-level cross-check then
-- flagged 24 documents. Reading them showed the archive title's own date always agreed with the
-- Drive file name and disagreed with ref_date, so the check was widened to full dates over the
-- whole archive, which found ~244.
--
-- Why the title wins: two sources that have never seen each other agree. The catalogue title
-- ("Linkup YYYY MM DD <name>") and the Google Drive PDF file name
-- ("NNNNN-WEB-YYYY-MM-DD-<slug>-ITA.pdf") match on 269 of 269 comparable documents, zero
-- exceptions (the remaining 4 are 2005 files carrying only year-month). The owner confirmed the
-- intended meaning on 2026-10-18: ref_date is the date of the Collegamento, so it must equal the
-- date in the title.
--
-- Probable cause: this is what migration 27 (27_backfill_ref_date_from_title.sql and the four
-- 27_refdate_update_batch*.sql) was supposed to do - those files hold the correct dates
-- (1577 -> 1982-08-05, matching its title), but the live database did not. Most likely migration
-- 27 never ran in full on this project and ref_date kept the shifted legacy values. Same class of
-- incident as migration 54 (see PROJECT_HANDOFF_v22 §1.3): a file in supabase/ is not proof it
-- ran. The fix below is written to be independent of that history: it derives the date from the
-- title at run time rather than from a hardcoded list, so re-running it is harmless.
--
-- Run after 103_move_italian_originals_to_document_texts.sql. Already executed on the live database 2026-10-18,
-- verification at the end returned 0 discordant rows.

-- 1. Backup first - plain table, kept for a few weeks then dropped (see the handoff's "what not
-- to do" list). Rollback is the single update at the bottom of this file.
create table if not exists public._backup_documents_refdate_20261018 as
select document_id, ref_date, ref_period,
       coalesce(en_title, title, original_title) as titolo, now() as backed_up_at
from public.documents
where regexp_match(coalesce(en_title, title, original_title),
                   'Linkup\s+(\d{4})\s+(\d{2})\s+(\d{2})') is not null;

-- 2. Sanity check before writing: no impossible date in any title (must return zero rows).
with t as (
  select document_id, regexp_match(coalesce(en_title, title, original_title),
                                   'Linkup\s+(\d{4})\s+(\d{2})\s+(\d{2})') as m
  from public.documents
)
select document_id, m as impossible_date_in_title
from t
where m is not null and not (m[2]::int between 1 and 12 and m[3]::int between 1 and 31);

-- 3. The correction. ref_period is realigned to the new year only where it already holds a plain
-- 4-digit year or is empty - a period label set by hand ("1980s", a campaign name) is left alone.
update public.documents d
set ref_date   = make_date(t.m[1]::int, t.m[2]::int, t.m[3]::int),
    ref_period = case when d.ref_period is null then t.m[1]
                      when d.ref_period ~ '^\d{4}$' then t.m[1]
                      else d.ref_period end
from (
  select document_id,
         regexp_match(coalesce(en_title, title, original_title),
                      'Linkup\s+(\d{4})\s+(\d{2})\s+(\d{2})') as m
  from public.documents
) t
where t.document_id = d.document_id
  and t.m is not null
  and t.m[2]::int between 1 and 12 and t.m[3]::int between 1 and 31
  and (d.ref_date is null or d.ref_date <> make_date(t.m[1]::int, t.m[2]::int, t.m[3]::int));

-- 4. Verification (run separately). discordanti must be 0.
with t as (
  select document_id, ref_date,
         regexp_match(coalesce(en_title, title, original_title),
                      'Linkup\s+(\d{4})\s+(\d{2})\s+(\d{2})') as m
  from public.documents
)
select count(*) filter (where m is not null
                          and ref_date::text <> m[1]||'-'||m[2]||'-'||m[3]) as discordanti
from t;

-- Spot check, including the two rows whose values had been swapped with each other:
-- 1577 -> 1982-08-05, 1714 -> 1990-05-24, 1772 -> 1997-10-23, 1823 -> 2004-09-23.
select document_id, ref_date, ref_period, coalesce(en_title, title) as titolo
from public.documents where document_id in (1577, 1714, 1772, 1823) order by document_id;

-- ============================================================================
-- Rollback, if ever needed (do not run as part of the migration):
--   update public.documents d set ref_date = b.ref_date, ref_period = b.ref_period
--   from public._backup_documents_refdate_20261018 b where b.document_id = d.document_id;
-- ============================================================================
