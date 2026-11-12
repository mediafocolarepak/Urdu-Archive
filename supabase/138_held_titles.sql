-- 138_held_titles.sql
-- The 7 titles held by 136, with the Owner's answers of 2026-11-12 (list and findings:
-- Documentazione/formazione-volontari/titoli_in_sospeso.md, local).
--   5     same text as 537 (the 1990 feast of Saint Clare talk): Italian title as the Owner wrote it, date 08-11-1990
--         corrected to 11-08-1990 (day and month were swapped; 537 has the right one).
--   733   holds a copy of 734's text: a duplicate the Owner removes in the app. Nothing written here.
--   984   Italian title "Dori: lettera a una volontaria" (text and original file name say "volontaria").
--   1017  Italian title from the original file name; "esperienza di Patras" is only one story in the collection.
--   1018  left without an Italian title. Nothing written here.
--   1147  archive title kept, "(translated)" mark cleared: the text confirms it.
--   1273  September 2004 kept; Italian title added.
-- English titles stay as they are. Setting the Italian title clears its "(translated)" mark (trigger of 126).
-- Each change applies only if the value is still the one exported on 2026-11-09; otherwise the row is left alone.
-- It can be run again: the second time nothing changes.
-- Restore:
--   update public.documents d set it_title = b.it_title, it_title_translated = b.it_title_translated, ref_date = b.ref_date from public._backup_titles_20261112 b where d.document_id = b.document_id;

create table if not exists public._backup_titles_20261112 as
  select document_id, it_title, it_title_translated, ref_date from public.documents where false;
alter table public._backup_titles_20261112 enable row level security;
insert into public._backup_titles_20261112
  select d.document_id, d.it_title, d.it_title_translated, d.ref_date from public.documents d
  where d.document_id in (5, 984, 1017, 1147, 1273)
    and not exists (select 1 from public._backup_titles_20261112 b where b.document_id = d.document_id);

with c (document_id, old_it, new_it) as (
  values
    (5, 'Il popo un nuovo tipo di cristiano', 'Il popo un nuovo tipo di cristiano (Bambino Evangelico)'),
    (984, 'Dori: Lettera a un volontario', 'Dori: lettera a una volontaria'),
    (1017, null, 'Esperienze dei volontari, Lahore, giornata 06'),
    (1273, null, 'Parola di vita Gen 4, settembre 2004')
)
update public.documents d set it_title = c.new_it
from c where d.document_id = c.document_id and d.deleted_at is null and d.it_title is not distinct from c.old_it;

update public.documents set ref_date = date '1990-08-11'
where document_id = 5 and deleted_at is null and ref_date = date '1990-11-08';

update public.documents set it_title_translated = false
where document_id = 1147 and deleted_at is null and it_title_translated
  and it_title = 'Judy 24-04-2005 La presenza di Dio nella comunità, al primo Simposio islamo-cristiano';

-- Checks: every row should say true.
with s (document_id, it) as (values
       (5, 'Il popo un nuovo tipo di cristiano (Bambino Evangelico)'), (984, 'Dori: lettera a una volontaria'),
       (1017, 'Esperienze dei volontari, Lahore, giornata 06'), (1273, 'Parola di vita Gen 4, settembre 2004'))
select 1 as ord, 'Italian titles set (4)' as what, count(*) = 4 as ok from s join public.documents d using (document_id) where d.it_title = s.it
union all select 2, 'no translated mark on 5, 984, 1017, 1147, 1273', count(*) = 0 from public.documents where document_id in (5, 984, 1017, 1147, 1273) and it_title_translated
union all select 3, '5 dated 11-08-1990 like 537', (select ref_date = date '1990-08-11' from public.documents where document_id = 5)
union all select 4, '733 and 1018 untouched', count(*) = 0 from public._backup_titles_20261112 where document_id in (733, 1018)
union all select 5, 'backup rows (5)', count(*) = 5 from public._backup_titles_20261112
order by ord;
