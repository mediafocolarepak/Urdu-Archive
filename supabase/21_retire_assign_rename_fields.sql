-- Retires the Assign mechanism (match_ref/video_ref/pdv_ref) in favor of Work-to-Work merge
-- as the only linking method, folds the ref_* metadata into the document's own fields so it
-- isn't lost, and renames/consolidates a few fields per the 2026-08-23 conversation:
--   - provenance -> source (pure rename, no data change)
--   - legacy_category dropped (already fully duplicated into category since 15_versions_editors_schema.sql)
--   - legacy_topic folded into secondary_tags, then dropped
--   - legacy_author -> original_author (kept separate, NOT merged into the constrained `author` field)
--   - legacy_status -> original_status (kept separate for now - pending a manual code mapping
--     to workflow_status, to be applied in a follow-up script once that mapping is provided)
--   - legacy_file_name and legacy_migrated: untouched, on purpose
--   - match_ref / video_ref / pdv_ref columns and the ref_* tables themselves: left in place as
--     inert historical data (not dropped) - only the app UI stops using them for linking.

-- ============================================================
-- STEP 0 - PREVIEW (read-only). Run this first and eyeball the counts before continuing.
-- Combined into one UNION ALL query so the Supabase SQL editor shows every row at once
-- (it only displays the last statement's result when you run several separate selects).
-- ============================================================
select 'legacy_category vs category mismatches (should be near 0)' as label, count(*)
from documents where legacy_category is distinct from category and legacy_category is not null
union all
select 'legacy_topic rows that would be copied into secondary_tags', count(*)
from documents where legacy_topic is not null and legacy_topic != '' and (secondary_tags is null or secondary_tags = '')
union all
select 'legacy_topic rows that would be DROPPED (secondary_tags already has something else)', count(*)
from documents where legacy_topic is not null and legacy_topic != '' and secondary_tags is not null and secondary_tags != '' and secondary_tags != legacy_topic
union all
select 'documents with match_ref to backfill from ref_collegamenti', count(*)
from documents d join ref_collegamenti r on d.match_ref = r.titolo
union all
select 'documents with video_ref to backfill from ref_video_index', count(*)
from documents d join ref_video_index r on d.video_ref = r.numero
union all
select 'documents with pdv_ref to backfill from ref_parola_di_vita', count(*)
from documents d join ref_parola_di_vita r on d.pdv_ref = r.link;

-- ============================================================
-- STEP 1 - Structural changes
-- ============================================================
alter table documents rename column provenance to source;
update option_lists set list_name = 'source' where list_name = 'provenance';
alter index if exists idx_documents_provenance rename to idx_documents_source;

alter table documents add column if not exists episode_number text;
alter table documents add column if not exists bible_verse text;

alter table documents rename column legacy_author to original_author;
alter table documents rename column legacy_status to original_status;

-- ============================================================
-- STEP 2 - Backfill ref_* metadata onto the document itself (never overwrites existing data)
-- ============================================================

-- Collegamenti: place/date/period
update documents d set
  place = coalesce(d.place, r.luogo),
  ref_date = coalesce(d.ref_date, r.data),
  ref_period = coalesce(d.ref_period, r.anno)
from ref_collegamenti r
where d.match_ref = r.titolo;

-- Video index: duration/date, everything else folded into notes
update documents d set
  duration = coalesce(d.duration, r.durata),
  ref_date = coalesce(d.ref_date, r.data),
  episode_number = coalesce(d.episode_number, r.numero),
  notes = trim(both E'\n' from coalesce(d.notes || E'\n', '') ||
    '[Video index] n. ' || coalesce(r.numero, '?') ||
    coalesce(' - ' || r.descrizione, '') ||
    coalesce(' - autore: ' || r.autore, '') ||
    coalesce(' - note: ' || r.note, ''))
from ref_video_index r
where d.video_ref = r.numero;

-- Parola di Vita: period/verse, riferimento folded into notes
update documents d set
  ref_period = coalesce(d.ref_period, trim(both '-' from coalesce(r.anno, '') || '-' || coalesce(r.mese, ''))),
  bible_verse = coalesce(d.bible_verse, r.versetto),
  notes = case when r.riferimento is not null and r.riferimento != '' then
    trim(both E'\n' from coalesce(d.notes || E'\n', '') || '[Parola di Vita index] riferimento: ' || r.riferimento)
    else d.notes end
from ref_parola_di_vita r
where d.pdv_ref = r.link;

-- ============================================================
-- STEP 3 - Consolidate legacy_category / legacy_topic, then drop them
-- ============================================================
update documents set category = coalesce(category, legacy_category) where category is null and legacy_category is not null;
update documents set secondary_tags = legacy_topic where (secondary_tags is null or secondary_tags = '') and legacy_topic is not null and legacy_topic != '';

-- v_documents_by_category / v_documents_by_topic (from 01_schema.sql) still depend on
-- legacy_category/legacy_topic (auto-renamed from the original category/topic by script 03's
-- rename) and join against the vestigial document_categories/topics tables. Nothing in the app
-- queries these views (checked js/*.js) - safe to drop them so the column drops below succeed.
drop view if exists v_documents_by_category;
drop view if exists v_documents_by_topic;

alter table documents drop column if exists legacy_category;
alter table documents drop column if exists legacy_topic;

select 'v3.1 schema ready: source options=' || (select count(*) from option_lists where list_name = 'source')
  || ', documents with episode_number=' || (select count(*) from documents where episode_number is not null)
  || ', documents with bible_verse=' || (select count(*) from documents where bible_verse is not null) as result;


