-- v3 data model: language rename, real Document/Version fields (original_title, place,
-- original file names, match_ref, is_preferred), multi-collection support, new category
-- taxonomy (restoring the original Access cat_id codes), and a safe one-time Work
-- regrouping by normalized original_title that never touches a Work already merged by hand.
--
-- Corrected against the live schema vs. the original request draft:
--   - original_title / place already existed (from the 2009 Access import) - not re-added.
--   - hayat_indice.data_pdv / book_page already existed - nothing to do there.
--   - author / main_topic / workflow_status keep their existing fixed vocabularies and CHECK
--     constraints untouched (only category's constraint is replaced - see below).
--   - the Work regroup only touches documents whose current Work is still single-item, so
--     any merge already done by hand via Match Review survives this script.
-- No begin/commit wrapper - same reason as 03_alter_schema_english.sql (pooled SQL Editor
-- connection does not reliably commit explicit multi-statement transactions).

-- 1. Rename original_lang -> language (column + option_lists rows). Guarded so this whole
--    script can be safely re-run from the top even if an earlier attempt got partway through
--    (the column rename, once done, must not be attempted again or it errors).
do $$
begin
  if exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'original_lang') then
    alter table documents rename column original_lang to language;
  end if;
end $$;
update option_lists set list_name = 'language' where list_name = 'original_lang';

-- 2. Drop italian_title (superseded by match_ref - confirmed: its values are a partial,
--    already-redundant subset of original_title, so nothing worth preserving).
alter table documents drop column if exists italian_title;

-- 3. New Document/Version fields.
alter table documents add column if not exists original_inp_file_name text;
alter table documents add column if not exists original_doc_file_name text;
alter table documents add column if not exists match_ref text;
alter table documents add column if not exists is_preferred boolean not null default false;

-- 4. document_collections: a document can now belong to more than one printed Collection
--    (e.g. a talk that appears both in "Themes of Spirituality" and later reprinted
--    elsewhere), each with its own page number in that particular book.
create table if not exists document_collections (
  id serial primary key,
  document_id integer references documents(document_id) on delete cascade,
  collection_code text not null,
  page_number integer,
  unique(document_id, collection_code)
);
create index if not exists idx_document_collections_document on document_collections(document_id);
create index if not exists idx_document_collections_collection on document_collections(collection_code);

-- 5. New category taxonomy: restores the original Access cat_id codes (already sitting
--    untouched in legacy_category) instead of the coarser DISC/LINK/WORD/... set. The old
--    constraint is dropped rather than replaced, matching how collection/provenance/media_type
--    already work (no DB-level enum - option_lists + the dropdown are the source of truth).
alter table documents drop constraint if exists documents_category_check;

insert into option_lists (list_name, code, label, sort_order) values
  ('category', 'Tlk', 'Talks', 1),
  ('category', 'Mdt', 'Meditations', 2),
  ('category', 'Lkp', 'Link-up', 3),
  ('category', 'Ans', 'Answers', 4),
  ('category', 'Art', 'Articles', 5),
  ('category', 'Exp', 'Experiences', 6),
  ('category', 'Var', 'Various', 7),
  ('category', 'Ctc', 'Catechism', 8),
  ('category', 'Dow', 'Drops of Wisdom', 9),
  ('category', 'Msg', 'Messages', 10),
  ('category', 'Wol', 'Word of Life', 11),
  ('category', 'Misc', 'Miscellaneous', 98),
  ('category', 'Othr', 'Other', 99)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

-- 6. Collections list (HAYAT included, so Hayat-extracted articles can be tagged the same
--    way as any other printed collection).
insert into option_lists (list_name, code, label, sort_order) values
  ('collection', 'FACF', 'Face to face with Chiara', 1),
  ('collection', 'THEM', 'Themes of Spirituality', 2),
  ('collection', 'MEDIT', 'Meditations', 3),
  ('collection', 'EXPE', 'Experiences', 4),
  ('collection', 'MESS', 'Messages', 5),
  ('collection', 'PROT', 'Protagonists', 6),
  ('collection', 'LINKU', 'Link-up', 7),
  ('collection', 'FOCO', 'The Focolare and its realities', 8),
  ('collection', 'HAYAT', 'Hayat / Naya Shaher', 10),
  ('collection', 'OTHR', 'Other', 99)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

-- 7. Recipient list, backfilled from the free-text legacy to_whom field (unconstrained,
--    unlike author/main_topic/workflow_status, so this is safe to populate as-is).
insert into option_lists (list_name, code, label, sort_order)
select 'recipient', to_whom, to_whom, row_number() over (order by to_whom)
from (select distinct to_whom from documents where to_whom is not null and to_whom <> '') t
on conflict (list_name, code) do nothing;

-- 8. Provenance code for the bulk of already-migrated documents.
insert into option_lists (list_name, code, label, sort_order) values
  ('provenance', 'ALE', 'Alessandro', 3)
on conflict (list_name, code) do update set label = excluded.label;

-- 9. Data backfill for legacy-migrated documents.
--    - category is reset to the original Access code (legacy_category already holds it).
--    - author / main_topic / workflow_status are NOT touched: they were already correctly
--      mapped into their fixed vocabularies back in 04_migrate_english_schema.sql: copying
--      the raw legacy_* text over them now would violate their CHECK constraints (or corrupt
--      already-correct data) since that raw text doesn't belong to those fixed vocabularies.
update documents
set provenance = 'ALE',
    language = 'URD',
    category = legacy_category,
    recipient = string_to_array(to_whom, ';')
where legacy_migrated = true;

-- 10. One-time Work regroup by normalized original_title - SAFE version: only considers
--     documents whose current Work is still single-item (i.e. never merged by hand since
--     go-live). Groups are merged into the lowest work_id in the group; the other, now-empty
--     Work rows are deleted - exactly what the app's own Match Review "merge" does.
do $$
declare
  g record;
  target_work bigint;
begin
  for g in
    select trim(regexp_replace(d.original_title, '[^a-zA-Z0-9 ]', '', 'g')) as norm_title,
           array_agg(distinct d.work_id) as work_ids
    from documents d
    where d.legacy_migrated = true
      and d.original_title is not null and d.original_title <> ''
      and d.work_id in (select work_id from documents group by work_id having count(*) = 1)
    group by norm_title
    having count(distinct d.work_id) > 1
  loop
    select min(w) into target_work from unnest(g.work_ids) as w;
    update documents set work_id = target_work
      where work_id = any(g.work_ids) and work_id <> target_work;
    delete from works where work_id = any(g.work_ids) and work_id <> target_work;
  end loop;
end $$;

select 'v3 schema ready: document_collections=' || (select count(*) from document_collections)
  || ', category options=' || (select count(*) from option_lists where list_name = 'category')
  || ', language options=' || (select count(*) from option_lists where list_name = 'language')
  || ', legacy docs regrouped into works=' || (select count(distinct work_id) from documents where legacy_migrated = true) as result;
