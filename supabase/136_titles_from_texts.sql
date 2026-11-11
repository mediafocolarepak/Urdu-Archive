-- 136_titles_from_texts.sql
-- Italian titles read in the Urdu texts (agents' reading of the archive, 2026-11), applied with the Owner's choice of
-- 2026-11-11: missing titles added, the archive kept where it is fuller, the differing ones decided one by one (list:
-- Documentazione/formazione-volontari/titoli_decisioni.md, generated with this file by genera_136.mjs).
-- 35 Italian titles set, 5 English titles changed (only where the Italian is added),
-- 14 "(translated)" marks cleared where the text confirms a title translated by 126.
-- A setting of the Italian title clears its "(translated)" mark through the trigger of 126.
-- Each change applies only if the title is still the one exported on 2026-11-09; otherwise the row is left alone.
-- It can be run again: the second time nothing changes.
-- Restore:
--   update public.documents d set it_title = b.it_title, en_title = b.en_title, it_title_translated = b.it_title_translated from public._backup_titles_20261111 b where d.document_id = b.document_id;

create table if not exists public._backup_titles_20261111 as
  select document_id, it_title, en_title, it_title_translated from public.documents where false;
alter table public._backup_titles_20261111 enable row level security;
insert into public._backup_titles_20261111
  select d.document_id, d.it_title, d.en_title, d.it_title_translated from public.documents d
  where d.document_id in (57, 339, 511, 512, 514, 516, 541, 547, 553, 564, 565, 573, 580, 581, 582, 599, 605, 606, 659, 671, 703, 851, 909, 918, 927, 952, 955, 972, 1001, 1014, 1028, 1062, 1070, 1115, 1122, 1123, 1145, 1172, 1241, 1254, 1416, 1417, 1427, 1440, 1470, 1528, 1536, 1539, 1556)
    and not exists (select 1 from public._backup_titles_20261111 b where b.document_id = d.document_id);

with c (document_id, old_it, new_it) as (
  values
    (57, null, 'Voglio'),
    (339, null, 'Una grande virtù cristiana'),
    (512, 'Chiara ai focolarini europei, Rocca di Papa, 27 dicembre 1970', 'L''Opera si chiama Carità (Chiara ai focolarini europei, Rocca di Papa, 27 dicembre 1970)'),
    (516, 'Chiara ai gen 2, Rocca di Papa, 9 luglio 1974', 'Dio è Amore (Chiara ai gen 2, Rocca di Papa, 9 luglio 1974)'),
    (541, 'Secondo tema (5 novembre 1995)', 'Spiritualità collettiva, secondo tema (5 novembre 1995)'),
    (547, 'V tema sulla spiritualità collettiva', 'L''amore eleva (V tema sulla spiritualità collettiva)'),
    (553, 'Chiara 27-11-1999 Risposte agli interni ad Amman', 'Chiara incontra gli interni/e della zona del Medio Oriente, Amman (Giordania), 27 novembre 1999'),
    (564, 'Chiara 01-04-2001 Focolarini esterni', 'Incontro esterni, 13 aprile 2001'),
    (565, 'Chiara 10-06-2001 Storia dell''Ideale, Trento', 'Chi beve l''acqua pensa alla sorgente (Storia dell''Ideale, Trento, 10 giugno 2001)'),
    (573, 'Congresso internazionale del Movimento Parrocchiale e del Movimento Diocesano', 'Gesù Abbandonato, via maestra per una comunità in dialogo (Congresso internazionale del Movimento Parrocchiale e del Movimento Diocesano)'),
    (580, 'Chiara all''assemblea generale, Castelgandolfo, 21 settembre 2002', 'L''amore che unisce (Chiara all''assemblea generale, Castelgandolfo, 21 settembre 2002)'),
    (581, 'Incontro di amici musulmani, 1 novembre 2002', 'L''amore al prossimo (Incontro di amici musulmani, 1 novembre 2002)'),
    (582, 'Chiara 03-11-2002 Risposte alle domande dei musulmani', 'Risposte a 13 domande (ai musulmani, 3 novembre 2002)'),
    (599, 'Chiara 16-07-2004 Paradiso: nuova comprensione', 'Nuova comprensione del Paradiso (16 luglio 2004)'),
    (659, 'Tema del professor Amer al-Hafi (Giordania), novembre 2002', 'L''amore al prossimo nell''Islam (Tema del professor Amer al-Hafi, Giordania, novembre 2002)'),
    (851, null, 'Una grande virtù cristiana'),
    (909, null, 'Perfetti come il Padre'),
    (918, null, 'Per Gesù crocifisso e abbandonato'),
    (927, null, 'La festa'),
    (952, 'Decalogo del gioco, 2004', 'Decalogo del gioco ideale (congresso gen 3 f, Castelgandolfo, 22-25 febbraio 2004)'),
    (955, 'Decalogo del gioco, 2004', 'Decalogo del gioco ideale (congresso gen 3 f, Castelgandolfo, 22-25 febbraio 2004)'),
    (1014, 'Esperienza per il congresso mariano', 'Maria nella mia vita (esperienza di Sana da Lahore per il congresso mariano)'),
    (1062, 'Gioco dell''indaco', 'Quiz: colore indaco'),
    (1070, 'Grande gioco, congresso 2004', 'Grande gioco: Arcobaleno di gioia (congresso 2004)'),
    (1115, 'Introduzione, congresso 2004', 'Presentazione del congresso gen 4, 2004'),
    (1122, 'Istruzioni: gioco di gruppo, congresso 2004', 'Istruzioni: gioco nei gruppi, congresso 2004'),
    (1145, 'Libano: aggiornamento DVD', 'Video Libano: aggiornamento ottobre 2006'),
    (1172, 'Libro: Chiara ai gen 3, Vizi e virtù', 'I vizi e le virtù (libro: Chiara ai gen 3)'),
    (1241, 'Messaggio dei gen del Pakistan a Chiara, Settimana Mondo Unito, 13-10-2002', 'Messaggio dal Pakistan (dei gen del Pakistan a Chiara, Settimana Mondo Unito, 13 ottobre 2002)'),
    (1416, 'Presentazione della branca dei religiosi', 'Presentazione della branca dei Religiosi del Movimento dei Focolari'),
    (1417, 'Presentazione, congresso gen 4', 'Presentazione congresso gen 4'),
    (1427, 'Programma, congresso gen 4, 2004', 'Programma: congresso gen 4, giugno 2004'),
    (1440, 'Risposte ai gen 3, congresso 2002, su Gesù Abbandonato', 'Risposta su Gesù Abbandonato (ai gen 3, congresso 2002)'),
    (1528, 'Emmaus 23-02-2004 Statuti ai gen 3', 'Cosa sono gli statuti? (ai gen 3, Emmaus, 23 febbraio 2004)'),
    (1539, 'Veni Creator, in urdu', 'Veni Creator Spiritus (in urdu)')
)
update public.documents d set it_title = c.new_it
from c where d.document_id = c.document_id and d.deleted_at is null and d.it_title is not distinct from c.old_it;

with c (document_id, old_en, new_en) as (
  values
    (339, null, 'A Great Christian Virtue'),
    (851, 'Linkup - P 28-09-2000', 'Linkup - P 28-09-2000 A Great Christian Virtue'),
    (909, 'Linkup - P 05-04-2005', 'Linkup - P 05-04-2005 Perfect as the Father'),
    (918, 'Linkup - P 11-08-2006', 'Linkup - P 11-08-2006 For Jesus Crucified and Forsaken'),
    (927, 'Linkup - P 14-02-2009', 'Linkup - P 14-02-2009 The Feast')
)
update public.documents d set en_title = c.new_en
from c where d.document_id = c.document_id and d.deleted_at is null and d.en_title is not distinct from c.old_en;

with c (document_id, it) as (
  values
    (511, 'Chiara 23-02-1971 Gesù Maestro'),
    (514, 'Chiara 01-07-1972 Uomo-mondo, al congresso gen'),
    (605, 'Parola di vita illustrata, ottobre 2003'),
    (606, '01-07-1972 Uomo-mondo, al congresso gen'),
    (671, 'Chiara sul Volontarifest'),
    (703, 'Chiara 05-04-2005 Lettera di Chiara ai giovani'),
    (972, 'Domande, congresso gen 2, Islamabad 2002'),
    (1001, 'Rosarium Virginis Mariae'),
    (1028, 'Faccia a faccia, III parte'),
    (1123, 'Gesù Abbandonato, 3 giugno 1972'),
    (1254, 'Pace, dal libro "Il Natale ritorna"'),
    (1470, 'Parola di vita, dicembre 2003'),
    (1536, 'Parola di vita gen 4, settembre 2004'),
    (1556, 'Parola di vita illustrata, ottobre 2003')
)
update public.documents d set it_title_translated = false
from c where d.document_id = c.document_id and d.deleted_at is null and d.it_title = c.it and d.it_title_translated;

-- Checks: every row should say true.
with s (document_id, it) as (values (57, 'Voglio'), (339, 'Una grande virtù cristiana'), (512, 'L''Opera si chiama Carità (Chiara ai focolarini europei, Rocca di Papa, 27 dicembre 1970)'), (516, 'Dio è Amore (Chiara ai gen 2, Rocca di Papa, 9 luglio 1974)'), (541, 'Spiritualità collettiva, secondo tema (5 novembre 1995)'), (547, 'L''amore eleva (V tema sulla spiritualità collettiva)'), (553, 'Chiara incontra gli interni/e della zona del Medio Oriente, Amman (Giordania), 27 novembre 1999'), (564, 'Incontro esterni, 13 aprile 2001'), (565, 'Chi beve l''acqua pensa alla sorgente (Storia dell''Ideale, Trento, 10 giugno 2001)'), (573, 'Gesù Abbandonato, via maestra per una comunità in dialogo (Congresso internazionale del Movimento Parrocchiale e del Movimento Diocesano)'), (580, 'L''amore che unisce (Chiara all''assemblea generale, Castelgandolfo, 21 settembre 2002)'), (581, 'L''amore al prossimo (Incontro di amici musulmani, 1 novembre 2002)'), (582, 'Risposte a 13 domande (ai musulmani, 3 novembre 2002)'), (599, 'Nuova comprensione del Paradiso (16 luglio 2004)'), (659, 'L''amore al prossimo nell''Islam (Tema del professor Amer al-Hafi, Giordania, novembre 2002)'), (851, 'Una grande virtù cristiana'), (909, 'Perfetti come il Padre'), (918, 'Per Gesù crocifisso e abbandonato'), (927, 'La festa'), (952, 'Decalogo del gioco ideale (congresso gen 3 f, Castelgandolfo, 22-25 febbraio 2004)'), (955, 'Decalogo del gioco ideale (congresso gen 3 f, Castelgandolfo, 22-25 febbraio 2004)'), (1014, 'Maria nella mia vita (esperienza di Sana da Lahore per il congresso mariano)'), (1062, 'Quiz: colore indaco'), (1070, 'Grande gioco: Arcobaleno di gioia (congresso 2004)'), (1115, 'Presentazione del congresso gen 4, 2004'), (1122, 'Istruzioni: gioco nei gruppi, congresso 2004'), (1145, 'Video Libano: aggiornamento ottobre 2006'), (1172, 'I vizi e le virtù (libro: Chiara ai gen 3)'), (1241, 'Messaggio dal Pakistan (dei gen del Pakistan a Chiara, Settimana Mondo Unito, 13 ottobre 2002)'), (1416, 'Presentazione della branca dei Religiosi del Movimento dei Focolari'), (1417, 'Presentazione congresso gen 4'), (1427, 'Programma: congresso gen 4, giugno 2004'), (1440, 'Risposta su Gesù Abbandonato (ai gen 3, congresso 2002)'), (1528, 'Cosa sono gli statuti? (ai gen 3, Emmaus, 23 febbraio 2004)'), (1539, 'Veni Creator Spiritus (in urdu)')),
     e (document_id, en) as (values (339, 'A Great Christian Virtue'), (851, 'Linkup - P 28-09-2000 A Great Christian Virtue'), (909, 'Linkup - P 05-04-2005 Perfect as the Father'), (918, 'Linkup - P 11-08-2006 For Jesus Crucified and Forsaken'), (927, 'Linkup - P 14-02-2009 The Feast')),
     u (document_id) as (values (511), (514), (605), (606), (671), (703), (972), (1001), (1028), (1123), (1254), (1470), (1536), (1556))
select 1 as ord, 'Italian titles set (35)' as what, count(*) = 35 as ok from s join public.documents d using (document_id) where d.it_title = s.it
union all select 2, 'set titles carry no translated mark', count(*) = 0 from s join public.documents d using (document_id) where d.it_title_translated
union all select 3, 'English titles changed (5)', count(*) = 5 from e join public.documents d using (document_id) where d.en_title = e.en
union all select 4, 'marks cleared (14)', count(*) = 0 from u join public.documents d using (document_id) where d.it_title_translated
union all select 5, 'backup rows (49)', count(*) = 49 from public._backup_titles_20261111
order by ord;
