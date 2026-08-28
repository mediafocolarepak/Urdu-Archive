-- Export dei documenti senza file collegato (documents.file_name IS NULL), per il
-- convertitore InPage standalone: usato per (1) dare priorità solo ai .inp locali che
-- servono davvero a colmare un buco nel DB, (2) generare le UPDATE che collegano il file
-- convertito al document_id giusto senza creare un documento duplicato.
--
-- Se il risultato supera le ~250 righe visualizzabili in chat, ripetere cambiando OFFSET
-- (0, 250, 500, ...) come fatto oggi per l'export dei Collegamenti.

SELECT
  document_id,
  title,
  original_title,
  ref_date,
  ref_period,
  place,
  category,
  original_inp_file_name,
  original_doc_file_name
FROM documents
WHERE file_name IS NULL
ORDER BY category, ref_date NULLS LAST, document_id
LIMIT 250 OFFSET 0;
-- Ripetere cambiando OFFSET: 0, 250, 500, ... finché il risultato non è vuoto.
