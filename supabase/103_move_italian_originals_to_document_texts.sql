-- 103_move_italian_originals_to_document_texts.sql
-- Corregge il modello dati della migrazione 102. I 273 testi italiani importati da "Linkup Ita
-- PDF" NON sono testi-sidecar di un documento diverso: hanno gia' un proprio record in
-- `documents` (document_id 1558-1830, language='ITA'), ciascuno collegato via work_id al/ai
-- fratello/i urdu (chiarimento dell'owner, 2026-09-21: ogni documento, in qualunque lingua, va
-- su un record separato; i record dello stesso titolo si raggruppano con work_id, e la scheda di
-- dettaglio ne elenca i fratelli - vedi fetchWorkSiblings in docdetail.js). Verificato su tutti
-- i 273: language='ITA' e work_id non nullo per ognuno, zero anomalie.
--
-- Quindi il testo va in document_texts (il corpo del record italiano stesso), non in
-- document_original_texts (un sidecar per quando NON esiste un record separato in lingua
-- originale). Questa migrazione lo sposta e pulisce le righe mal posizionate.

-- 1. document_texts.source non aveva ancora posto per un testo originale importato da Drive - il
-- suo check ammetteva solo 'inpage'/'typed'/'ocr' (i valori sensati prima che in questa tabella
-- arrivasse testo in una lingua diversa dall'urdu). Stesso valore e stessa logica di
-- document_original_texts (migrazione 101).
alter table public.document_texts drop constraint if exists document_texts_source_check;
alter table public.document_texts add constraint document_texts_source_check
  check (source in ('inpage', 'typed', 'ocr', 'drive_import'));

-- 2. Copia: stesso document_id (sono gia' i documenti italiani, non il sidecar di un altro).
-- Il filtro su documents.language/work_id e' un cancello di sicurezza: sposta solo le righe che
-- corrispondono davvero a un documento italiano proprio gia' agganciato a un work - non tutto
-- cio' che document_original_texts potesse mai contenere in futuro (es. un vero sidecar senza
-- record separato resterebbe dov'e').
insert into public.document_texts (document_id, body, source, source_file, reviewed)
select dot.document_id, dot.body, 'drive_import', dot.source_file, false
from public.document_original_texts dot
join public.documents d on d.document_id = dot.document_id
where dot.language = 'ITA' and d.language = 'ITA' and d.work_id is not null
on conflict (document_id) do nothing;

-- 3. Rimuove le righe ora ridondanti dal sidecar - erano il modello sbagliato per documenti che
-- hanno gia' un proprio record catalogato.
delete from public.document_original_texts dot
using public.documents d
where d.document_id = dot.document_id
  and dot.language = 'ITA' and d.language = 'ITA' and d.work_id is not null;

-- ============================================================================
-- Verifica finale
-- ============================================================================
select 'document_texts per i documenti italiani (language=ITA, work_id impostato)' as item,
       count(*) as n
from public.document_texts dt
join public.documents d using (document_id)
where d.language = 'ITA' and d.work_id is not null
union all
select 'righe rimaste in document_original_texts (atteso: 0, salvo sidecar futuri non-ITA)', count(*)
from public.document_original_texts;
