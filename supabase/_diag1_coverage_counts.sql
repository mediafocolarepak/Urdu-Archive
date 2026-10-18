select
  count(*) as totale_273,
  count(*) filter (where d.language = 'ITA') as con_language_ita,
  count(*) filter (where d.work_id is not null) as con_work_id,
  count(*) filter (where d.language = 'ITA' and d.work_id is not null) as con_entrambi,
  count(*) filter (where d.language is distinct from 'ITA') as con_language_diversa_o_null,
  count(*) filter (where d.work_id is null) as senza_work_id
from public.document_original_texts dot
join public.documents d using (document_id)
where dot.language = 'ITA';
