-- _diag_works_usage.sql
-- Quanto e' gia' usato il raggruppamento "work" (documents.work_id) per versioni in lingue
-- diverse dello stesso titolo? Sola lettura.

select count(*) as works_totali from public.works;

select count(*) as documenti_con_work_id,
       count(*) filter (where language is not null) as di_cui_con_language_impostata
from public.documents where work_id is not null;

select language, count(*) as n
from public.documents where work_id is not null
group by language order by n desc;

-- work con piu' di un documento collegato (i casi reali di "stesso titolo, piu' lingue/versioni")
select work_id, count(*) as n_documenti, array_agg(document_id order by document_id) as document_ids,
       array_agg(language order by document_id) as languages,
       array_agg(is_preferred order by document_id) as preferred_flags
from public.documents
where work_id is not null
group by work_id
having count(*) > 1
order by n_documenti desc
limit 20;
