-- _export_work_pairs.sql
-- Esportazione delle coppie italiano/urdu per il mining della skill di traduzione, questa volta
-- unendo tramite work_id (il modello corretto: ogni versione linguistica e' un record separato,
-- raggruppato via work_id) invece che per document_id. Sola lettura.
--
-- Una riga per ogni (documento italiano, fratello urdu con testo) - un work con piu' fratelli
-- urdu genera piu' righe con lo stesso testo italiano, che e' quello che vogliamo: ogni fratello
-- e' un candidato di traduzione a se'.
--
-- Eseguire nell'SQL editor di Supabase, scaricare come CSV e caricare qui in chat.

select
  ita.work_id,
  ita.document_id as ita_document_id,
  ita.title       as ita_title,
  dot.body        as testo_ita,
  urd.document_id as urdu_document_id,
  urd.title       as urdu_title,
  urd.is_preferred,
  dt.body         as testo_urdu
from public.documents ita
join public.document_texts dot on dot.document_id = ita.document_id
join public.documents urd on urd.work_id = ita.work_id and urd.document_id <> ita.document_id
join public.document_texts dt on dt.document_id = urd.document_id
where ita.language = 'ITA' and ita.work_id is not null
order by ita.work_id, ita.document_id, urd.document_id;
