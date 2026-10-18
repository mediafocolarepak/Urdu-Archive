-- _diag_ita_docs_coverage.sql
-- Quanti dei 273 document_id importati in document_original_texts hanno gia' un record
-- proprio in `documents` con language='ITA' e work_id impostato (il modello descritto
-- dall'utente: ogni documento e' un record separato, raggruppato via work_id)? Sola lettura.

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

-- Se ce ne sono, i casi anomali (language diversa da ITA, o work_id assente) da guardare a mano.
select d.document_id, d.title, d.language, d.work_id
from public.document_original_texts dot
join public.documents d using (document_id)
where dot.language = 'ITA' and (d.language is distinct from 'ITA' or d.work_id is null)
order by d.document_id;

-- Per gli work_id trovati: quanti hanno ALMENO un fratello urdu con testo gia' in document_texts
-- (le vere coppie disponibili per il mining bilingue).
select count(distinct d.document_id) as ita_con_fratello_urdu_testuale
from public.documents d
join public.document_original_texts dot on dot.document_id = d.document_id and dot.language = 'ITA'
where d.work_id is not null
  and exists (
    select 1 from public.documents sib
    join public.document_texts dt on dt.document_id = sib.document_id
    where sib.work_id = d.work_id and sib.document_id <> d.document_id
  );
