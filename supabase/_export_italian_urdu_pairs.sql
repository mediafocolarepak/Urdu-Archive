-- _export_italian_urdu_pairs.sql
-- Esportazione delle coppie italiano/urdu per il mining della skill di traduzione
-- (HANDOFF_Skill_Autoapprendimento_2026-09-20.md SS4). Solo lettura, nessuna modifica.
--
-- Eseguire nell'SQL editor di Supabase, poi usare "Download as CSV" (o copiare i risultati
-- come JSON se l'editor lo offre) e caricare il file qui in chat.

select
  dot.document_id,
  d.title,
  d.ref_date,
  dot.body as testo_ita,
  dt.body  as testo_urdu
from public.document_original_texts dot
join public.document_texts dt using (document_id)
join public.documents d using (document_id)
where dot.language = 'ITA'
order by dot.document_id;
