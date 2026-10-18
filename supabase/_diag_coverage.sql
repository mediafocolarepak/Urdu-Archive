-- _diag_coverage.sql
-- Diagnostica: perche' il join italiano/urdu su document_id 1558-1830 non restituisce righe.
-- Sola lettura.

select 'document_original_texts (ITA importati)' as insieme, count(*) as n,
       min(document_id) as min_id, max(document_id) as max_id
from public.document_original_texts where language = 'ITA'
union all
select 'document_texts (urdu, tutti)', count(*), min(document_id), max(document_id)
from public.document_texts
union all
select 'document_texts (urdu) nel range 1558-1830', count(*), min(document_id), max(document_id)
from public.document_texts where document_id between 1558 and 1830
union all
select 'intersezione: document_id con ENTRAMBI i testi', count(*), min(dot.document_id), max(dot.document_id)
from public.document_original_texts dot
join public.document_texts dt using (document_id)
where dot.language = 'ITA';
