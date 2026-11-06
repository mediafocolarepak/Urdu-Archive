-- 125_correct_italian_titles.sql
-- Corrects 26 Italian titles, as the Owner approved on 2026-11-06: 16 typing errors in old records, 10 Italian versions cut short or
-- mistyped, whose Urdu version has the whole title. It changes it_title and also original_title, because the Library shows both when
-- they differ. A title changes only if it is still the one that was read, so an edit made since then stays. Then it fills 2 empty it_title.
-- Run it in the SQL Editor. It can be run twice. The earlier values are kept in the backup table, and restored like this:
--   update public.documents d set it_title = b.it_title, original_title = b.original_title from public._backup_title_corrections_20261106 b where d.document_id = b.document_id;

create table if not exists public._backup_title_corrections_20261106 as
select document_id, it_title, original_title, now() as backed_up_at
from public.documents
where document_id in (4, 36, 99, 102, 133, 161, 201, 224, 275, 285, 286, 287, 288, 460, 486, 791,
                      1671, 1693, 1701, 1703, 1708, 1719, 1732, 1736, 1798, 1803, 787, 810);
alter table public._backup_title_corrections_20261106 enable row level security;

with fix (document_id, old_title, new_title) as (
  values
    (4, 'Risposte suDio Amore', 'Risposte su Dio Amore'),
    (36, 'Storia di Giosi - Esperinze dei primi tempi sul Rosso', 'Storia di Giosi - Esperienze dei primi tempi sul Rosso'),
    (99, 'Primo Mitero della Luce', 'Primo Mistero della Luce'),
    (102, 'Quarto Mistero dela Luce', 'Quarto Mistero della Luce'),
    (133, 'A tu per tu con Chiara (una Suora chiede come portare l''Ideale nella sua Comunità"', 'A tu per tu con Chiara (una Suora chiede come portare l''Ideale nella sua Comunità)'),
    (161, 'Eserienza gen 3 "La vita dei gen 3 in Libano"', 'Esperienza gen 3 "La vita dei gen 3 in Libano"'),
    (201, 'Esperienza di Faheel di lahore', 'Esperienza di Faheel di Lahore'),
    (224, 'Goccie di sapienza', 'Gocce di sapienza'),
    (275, 'Mesaggio del Papa sui Misteri della luce', 'Messaggio del Papa sui Misteri della luce'),
    (285, 'Rosarium Virginis Marie (prima parte)', 'Rosarium Virginis Mariae (prima parte)'),
    (286, 'Rosario Virginis Marie (seconda parte)', 'Rosarium Virginis Mariae (seconda parte)'),
    (287, 'Rosario Virginis Marie 1 (estratto)', 'Rosarium Virginis Mariae 1 (estratto)'),
    (288, 'L''Opera sichiama Carità', 'L''Opera si chiama Carità'),
    (460, 'Dammi tutti I soli', 'Dammi tutti i soli'),
    (486, 'La nostra responsabiltà è grande', 'La nostra responsabilità è grande'),
    (791, 'Sere il nostro ideale vivo', 'Essere il nostro ideale vivo'),
    (1671, 'Vivere la volontà di Dio', 'Vivere la volontà di Dio con totale impegno'),
    (1693, 'Sere fuoco', 'Essere fuoco'),
    (1701, 'Azioni "pulite", tutte ugualmente', 'Azioni "pulite", tutte egualmente importanti, sulla base dell''Amore'),
    (1703, 'Chiedersi ad ogni azione che compiamo:', 'Chiedersi ad ogni azione che compiamo: sto evangelizzando?'),
    (1708, 'Insegnamento di Renata', 'Un insegnamento di Renata'),
    (1719, 'Parola al primo posto', 'La Parola al primo posto'),
    (1732, 'Realizzare il nostro sogno:', 'Realizzare il nostro sogno: nessun bisognoso'),
    (1736, '"Comunione delle esperienze', 'Comunione delle esperienze della Parola di Vita'),
    (1798, 'Le 4 parole"', 'Le 4 parole'),
    (1803, 'Vivere la parola per amare Gesù Abbandonato', 'Vivere la Parola per amare Gesù Abbandonato nell''attimo presente della nostra vita')
)
update public.documents d
set it_title = f.new_title,
    original_title = case when regexp_replace(btrim(d.original_title), '\s+', ' ', 'g') = f.old_title then f.new_title else d.original_title end
from fix f
where f.document_id = d.document_id
  and d.it_title = f.old_title;

with empty_one (document_id, new_title) as (
  values
    (787, 'Azioni "pulite", tutte egualmente importanti, sulla base dell''Amore'),
    (810, 'Dare')
), done as (
  update public.documents d
  set it_title = e.new_title
  from empty_one e
  where e.document_id = d.document_id
    and nullif(btrim(d.it_title), '') is null
  returning d.document_id, d.it_title
)
insert into public._filled_it_title_20261106 (document_id, it_title, source)
select document_id, it_title, 'correction' from done
on conflict (document_id) do nothing;

-- Verification (the SQL Editor shows only the last result). 28 rows, all with ok = true. The two filled ones keep their original_title.
with want (document_id, new_title, two_fields) as (
  values
    (4, 'Risposte su Dio Amore', true),
    (36, 'Storia di Giosi - Esperienze dei primi tempi sul Rosso', true),
    (99, 'Primo Mistero della Luce', true),
    (102, 'Quarto Mistero della Luce', true),
    (133, 'A tu per tu con Chiara (una Suora chiede come portare l''Ideale nella sua Comunità)', true),
    (161, 'Esperienza gen 3 "La vita dei gen 3 in Libano"', true),
    (201, 'Esperienza di Faheel di Lahore', true),
    (224, 'Gocce di sapienza', true),
    (275, 'Messaggio del Papa sui Misteri della luce', true),
    (285, 'Rosarium Virginis Mariae (prima parte)', true),
    (286, 'Rosarium Virginis Mariae (seconda parte)', true),
    (287, 'Rosarium Virginis Mariae 1 (estratto)', true),
    (288, 'L''Opera si chiama Carità', true),
    (460, 'Dammi tutti i soli', true),
    (486, 'La nostra responsabilità è grande', true),
    (791, 'Essere il nostro ideale vivo', true),
    (1671, 'Vivere la volontà di Dio con totale impegno', true),
    (1693, 'Essere fuoco', true),
    (1701, 'Azioni "pulite", tutte egualmente importanti, sulla base dell''Amore', true),
    (1703, 'Chiedersi ad ogni azione che compiamo: sto evangelizzando?', true),
    (1708, 'Un insegnamento di Renata', true),
    (1719, 'La Parola al primo posto', true),
    (1732, 'Realizzare il nostro sogno: nessun bisognoso', true),
    (1736, 'Comunione delle esperienze della Parola di Vita', true),
    (1798, 'Le 4 parole', true),
    (1803, 'Vivere la Parola per amare Gesù Abbandonato nell''attimo presente della nostra vita', true),
    (787, 'Azioni "pulite", tutte egualmente importanti, sulla base dell''Amore', false),
    (810, 'Dare', false)
)
select w.document_id,
       d.it_title = w.new_title and (not w.two_fields or d.original_title = w.new_title) as ok,
       d.it_title,
       d.original_title
from want w
left join public.documents d on d.document_id = w.document_id
order by w.document_id;
