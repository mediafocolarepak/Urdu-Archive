select d.document_id, d.title, d.language, d.work_id
from public.document_original_texts dot
join public.documents d using (document_id)
where dot.language = 'ITA' and (d.language is distinct from 'ITA' or d.work_id is null)
order by d.document_id;
