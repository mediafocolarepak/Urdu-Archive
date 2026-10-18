-- _diag_id_match.sql
-- Verifica se il document_id dei PDF italiani corrisponde davvero al documento giusto in
-- `documents`, o se la corrispondenza per numero e' sbagliata (ipotesi dell'utente: il testo
-- urdu di questi Collegamenti esiste ma sotto un document_id diverso). Sola lettura.

-- 1. Titoli/date dei 10 documenti con id piu' basso tra i 273 importati: controllare a occhio
-- se sembrano davvero i Collegamenti giusti (confrontare con i nomi dei file PDF, es.
-- 01558 = "il-santo-viaggio", 01827 = "essere-sempre-famiglia").
select d.document_id, d.title, d.original_title, d.ref_date, d.category
from public.documents d
join public.document_original_texts dot using (document_id)
where dot.language = 'ITA'
order by d.document_id
limit 15;

-- 2. Gli stessi Collegamenti potrebbero essere catalogati ANCHE sotto un altro document_id
-- (doppione), quello che ha gia' il testo urdu. Cerca titoli duplicati o molto simili tra
-- i documenti con urdu (id 2-1557) e quelli con italiano (id 1558-1830).
select d1.document_id as id_ita, d1.title as titolo_ita, d1.ref_date as data_ita,
       d2.document_id as id_urdu_candidato, d2.title as titolo_urdu_candidato, d2.ref_date as data_urdu
from public.documents d1
join public.document_original_texts dot on dot.document_id = d1.document_id and dot.language = 'ITA'
join public.documents d2 on d2.ref_date = d1.ref_date and d2.document_id <> d1.document_id
join public.document_texts dt on dt.document_id = d2.document_id
order by d1.document_id
limit 30;

-- 3. Quanti dei 273 hanno una data (ref_date) valida che potrebbe fare da chiave di
-- abbinamento alternativa al document_id.
select count(*) as con_ref_date, count(*) filter (where d.ref_date is null) as senza_ref_date
from public.documents d
join public.document_original_texts dot using (document_id)
where dot.language = 'ITA';
