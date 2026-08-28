-- Step 1: give every existing document its own Work (1 document = 1 work by default).
-- Uses a loop rather than a set-based insert so each new work_id is unambiguously
-- matched back to the document that created it (small table, ~500 rows, performance is a non-issue).
do $$
declare
  doc record;
  new_work_id bigint;
begin
  for doc in select document_id, title from documents where work_id is null order by document_id loop
    insert into works (canonical_title) values (doc.title) returning work_id into new_work_id;
    update documents set work_id = new_work_id where document_id = doc.document_id;
  end loop;
end $$;

-- ---------------------------------------------------------------------------------
-- DRY RUN: run just this SELECT first if you want to see what the merge below will do
-- before it happens. Shows every date where 2+ still-single-item-work documents share
-- an exact date with no two of them sharing the same provenance+language (the
-- unambiguous case - anything messier is left for human review in Match Review instead).
-- ---------------------------------------------------------------------------------
select d.ref_date, count(*) as documents_to_merge,
       string_agg(coalesce(d.provenance,'?') || '/' || coalesce(d.original_lang,'?') || ' #' || d.document_id, ', ') as detail
from documents d
where d.ref_date is not null
  and d.work_id in (select work_id from documents group by work_id having count(*) = 1)
group by d.ref_date
having count(*) > 1
   and count(*) = count(distinct coalesce(d.provenance,'') || '|' || coalesce(d.original_lang,''))
order by d.ref_date;

-- ---------------------------------------------------------------------------------
-- Step 2: the actual merge. Comment this whole DO block out if you only want the
-- dry-run numbers above for now and want to merge later.
-- ---------------------------------------------------------------------------------
do $$
declare
  grp record;
  canonical_work_id bigint;
begin
  for grp in (
    select d.ref_date
    from documents d
    where d.ref_date is not null
      and d.work_id in (select work_id from documents group by work_id having count(*) = 1)
    group by d.ref_date
    having count(*) > 1
       and count(*) = count(distinct coalesce(d.provenance,'') || '|' || coalesce(d.original_lang,''))
  ) loop
    select min(work_id) into canonical_work_id from documents where ref_date = grp.ref_date;
    update documents set work_id = canonical_work_id where ref_date = grp.ref_date and work_id <> canonical_work_id;
  end loop;

  delete from works w where not exists (select 1 from documents d where d.work_id = w.work_id);
end $$;

select 'documents with a work_id: ' || (select count(*) from documents where work_id is not null)
  || ' / total works: ' || (select count(*) from works)
  || ' / works with 2+ items: ' || (select count(*) from (select work_id from documents group by work_id having count(*) > 1) x) as result;
