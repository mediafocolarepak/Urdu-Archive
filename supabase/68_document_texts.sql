-- 68_document_texts.sql
-- Il testo urdu dei documenti, finora non presente da nessuna parte: documents ha ur_title e
-- en_title ma non il corpo. Senza di esso la lettura in-app e' impossibile (il PDF sta su Google
-- Drive dietro un muro CORS, vedi PROJECT_HANDOFF_v13.md §1) e la ricerca del Dashboard puo'
-- guardare solo dentro titoli e tag (dashboard.js buildDashQuery).
--
-- PERCHE' UNA TABELLA SEPARATA E NON UNA COLONNA SU documents
-- ------------------------------------------------------------
-- documents e' appena passata da 60 a 45 colonne (migrazioni 63-67) ed e' la tabella calda:
-- il Dashboard la interroga a ogni tasto premuto e l'Export CSV fa select *. Una colonna di
-- testo da ~7.400 caratteri medi (fino a 157.591) verrebbe trascinata in ogni singola query.
-- Qui il join e' 1:1 e si paga solo quando il testo serve davvero.
--
-- PROVENIENZA DEL TESTO
-- ---------------------
-- La prima infornata viene dai 1.365 file .inp locali, convertiti in Unicode dalla stessa
-- funzione che gia' gira nel browser (inPageBytesToUnicode in js/inpageconverter.js, corretta
-- nel commit f22b305). Misurazione del 09/09/2026 sull'intero corpus: 1.364 file convertiti su
-- 1.365, il 96,6% con testo pieno e in media il 95% di caratteri urdu, 1.011 contenuti unici,
-- ~19 MB in tutto. Il collegamento file -> document_id e' ricostruito da renamed_inp_file_name
-- (migrazione 49) e da legacy_file_name (seed 02), con un secondo passaggio sul numero di
-- catalogo confermato dalla data: 983 collegamenti solidi su 1.011, verificati a campione su
-- 20 documenti letti a mano.
--
-- IMPORTANTE - il flag reviewed. Il testo convertito in blocco non e' stato riletto da nessuno.
-- Nasce quindi con reviewed = false e l'interfaccia DEVE etichettarlo come trascrizione
-- automatica non verificata: e' materiale di formazione, e presentarlo come autorevole prima
-- che un essere umano l'abbia letto sarebbe peggio che non averlo. La rilettura e' lavoro da
-- distribuire con il sistema Tasks (molto piu' rapido della trascrizione, e va pagato meno).
--
-- Questa migrazione crea SOLO la struttura. Il caricamento dei testi e' un passo separato
-- (~19 MB: non si incolla nel SQL Editor).

-- 1. pg_trgm: la ricerca urdu non puo' usare il full-text di Postgres, che non ha una
-- configurazione per questa lingua (to_tsvector('simple', ...) non farebbe alcuno stemming e
-- spezzerebbe male). La strada praticabile e' l'indice trigram su LIKE. Installata nello schema
-- extensions come da convenzione Supabase, e l'operator class piu' sotto e' qualificata
-- esplicitamente per non dipendere dal search_path della sessione.
create extension if not exists pg_trgm with schema extensions;

-- 2. Normalizzazione per la ricerca.
-- LA TRAPPOLA: in urdu due testi che sullo schermo sono identici possono essere byte diversi.
-- La yeh araba e quella urdu, la kaf araba e quella urdu, le forme della hamza, i diacritici
-- opzionali (zabar/zer/pesh), la kashida decorativa e i giunti a larghezza zero cambiano i byte
-- senza cambiare la parola. Senza normalizzazione la ricerca fallisce IN SILENZIO su parte
-- delle occorrenze: il caso peggiore, perche' sembra funzionare.
--
-- I segni da CANCELLARE sono scritti con \uXXXX e non con il carattere vero: sono invisibili
-- (diacritici, kashida, ZWNJ, marcatori di direzione, BOM) e in forma letterale renderebbero
-- questa funzione impossibile da rivedere e facilissima da corrompere con un copia-incolla -
-- basta un editor che normalizza gli spazi. Le lettere da PIEGARE restano invece scritte per
-- esteso, perche' sono visibili e cosi' si legge a colpo d'occhio cosa diventa cosa.
-- (In una stringa E'...' le sequenze \uXXXX vengono espanse dal parser prima che l'espressione
-- regolare le veda: il risultato e' identico, ma quella riga del sorgente resta ASCII.)
--
-- Le pieghe sono volutamente generose - alzano il richiamo, abbassano di poco la precisione:
-- tutte le varianti di yeh, compresa la bari yeh, confluiscono in yeh urdu; heh araba e teh
-- marbuta in heh urdu; le hamza portate su alef in alef semplice. La do-chashmi ھ (U+06BE) NON
-- viene piegata: distingue le consonanti aspirate ed e' una lettera a se'.
--
-- immutable perche' serve a una colonna generata (vedi sotto); nessuna dipendenza da locale
-- o da search_path.
create or replace function public.urdu_norm(t text)
returns text
language sql
immutable
parallel safe
as $$
  select btrim(regexp_replace(
    translate(
      lower(
        regexp_replace(
          regexp_replace(
            regexp_replace(
              regexp_replace(
                regexp_replace(
                  regexp_replace(
                    -- diacritici (U+064B-065F), alef soprascritta (U+0670), segni coranici
                    -- (U+06D6-06ED), kashida (U+0640), caratteri a larghezza zero e marcatori
                    -- di direzione (U+200B-200F), BOM (U+FEFF): invisibili o decorativi, via.
                    t,
                    E'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640\u200B-\u200F\uFEFF]', '', 'g'),
                  -- yeh araba, alef maksura, bari yeh, bari yeh con hamza, yeh con hamza -> yeh urdu
                  E'[يىےۓئ]', E'ی', 'g'),
                -- kaf araba, swash kaf -> kaf urdu
                E'[كڪ]', E'ک', 'g'),
              -- heh araba, teh marbuta, heh con yeh sopra -> heh urdu
              E'[هةۀ]', E'ہ', 'g'),
            -- alef con madda / hamza sopra / hamza sotto / wasla -> alef semplice
            E'[آأإٱ]', E'ا', 'g'),
          -- waw con hamza -> waw
          E'[ؤ]', E'و', 'g')
      ),
      -- cifre indo-arabe (serie araba U+0660-0669 e serie estesa urdu/persiana U+06F0-06F9)
      -- nelle cifre occidentali: 20 caratteri in ingresso, 20 in uscita.
      E'٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹',
      '01234567890123456789'),
    -- spazi, tabulazioni e a capo compattati in un singolo spazio
    '\s+', ' ', 'g'))
$$;

-- 3. La tabella.
create table if not exists public.document_texts (
  document_id       integer primary key references public.documents(document_id) on delete cascade,
  body              text not null,
  -- colonna generata: non puo' andare fuori sincrono con body, a differenza di un trigger
  -- dimenticato. ATTENZIONE: se un giorno urdu_norm viene migliorata, i valori gia' salvati
  -- NON si ricalcolano da soli - serve un "update public.document_texts set body = body;".
  body_norm         text generated always as (public.urdu_norm(body)) stored,
  char_count        integer generated always as (length(body)) stored,
  -- da dove viene questo testo: conversione automatica, battitura umana, OCR.
  source            text not null default 'inpage' check (source in ('inpage', 'typed', 'ocr')),
  -- il file .inp (o altro) da cui e' stato generato, per poter rifare la conversione domani
  -- senza ricostruire il collegamento da capo.
  source_file       text,
  -- false finche' un essere umano non l'ha riletto. Vedi la nota in testa al file.
  reviewed          boolean not null default false,
  reviewed_by_email text,
  reviewed_at       timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  updated_by_email  text
);

-- 4. Indici.
-- L'indice trigram e' quello che rende sostenibile LIKE '%...%' su 10 milioni di caratteri.
create index if not exists idx_document_texts_body_norm_trgm
  on public.document_texts using gin (body_norm extensions.gin_trgm_ops);
-- Per la coda di rilettura ("mostrami cosa non ha ancora guardato nessuno").
create index if not exists idx_document_texts_reviewed
  on public.document_texts (reviewed) where reviewed = false;

-- 5. updated_at.
create or replace function public.touch_document_texts()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
drop trigger if exists trg_touch_document_texts on public.document_texts;
create trigger trg_touch_document_texts before update on public.document_texts
  for each row execute function public.touch_document_texts();

-- 6. RLS - stessi scaglioni di documents (05_roles_and_permissions.sql): tutti leggono,
-- Operator+ scrive, solo Admin cancella.
-- Il testo non ancora riletto resta LEGGIBILE da tutti di proposito: nasconderlo renderebbe la
-- ricerca cieca su quasi tutto l'archivio per il tempo, lungo, della rilettura. La garanzia e'
-- l'etichetta nell'interfaccia, non la policy - vedi la nota in testa al file.
alter table public.document_texts enable row level security;

drop policy if exists "document_texts_select" on public.document_texts;
create policy "document_texts_select" on public.document_texts
  for select using (current_role_is('user'));

drop policy if exists "document_texts_insert" on public.document_texts;
create policy "document_texts_insert" on public.document_texts
  for insert with check (current_role_is('operator'));

drop policy if exists "document_texts_update" on public.document_texts;
create policy "document_texts_update" on public.document_texts
  for update using (current_role_is('operator')) with check (current_role_is('operator'));

drop policy if exists "document_texts_delete" on public.document_texts;
create policy "document_texts_delete" on public.document_texts
  for delete using (current_role_is('admin'));

-- 7. La ricerca.
-- Passa da qui e non da un LIKE costruito nel client PER UN MOTIVO PRECISO: la chiave di
-- ricerca va normalizzata esattamente come il testo indicizzato. Se la normalizzazione venisse
-- riscritta anche in JavaScript, le due copie divergerebbero - e la ricerca comincerebbe a non
-- trovare cose che ci sono, senza che nessun errore lo segnali. Una sola implementazione.
--
-- Lo spezzone restituito e' ritagliato da body_norm e NON da body: la normalizzazione toglie
-- caratteri, quindi la posizione trovata in body_norm non corrisponde alla stessa posizione in
-- body e il ritaglio cadrebbe spostato. Il testo normalizzato ha perso solo diacritici e forme
-- alternative, resta perfettamente leggibile per un'anteprima; il testo integrale si prende
-- dalla riga vera quando si apre il documento.
create or replace function public.search_document_texts(q text, lim integer default 100)
returns table (document_id integer, snippet text, reviewed boolean)
language sql
stable
as $$
  with needle as (select public.urdu_norm(q) as n)
  select dt.document_id,
         substring(dt.body_norm
                   from greatest(1, position(needle.n in dt.body_norm) - 60)
                   for 160),
         dt.reviewed
  from public.document_texts dt, needle
  where needle.n <> ''
    and dt.body_norm like '%' || needle.n || '%'
  limit lim;
$$;

-- 8. Verifica. La parola urdu "kya" scritta male apposta: kaf ARABA (U+0643) invece di quella
-- urdu, shadda e fatha addosso, una kashida in mezzo, yeh ARABA (U+064A) invece di quella urdu.
-- Deve tornare kaf urdu + yeh urdu + alef, cioe' esattamente la stessa parola scritta bene.
select 'document_texts creata. Righe: ' || (select count(*) from public.document_texts)::text as result,
       public.urdu_norm(E'كَّيـا') as normalizzata,
       (public.urdu_norm(E'كَّيـا') = E'کیا') as prova_superata;
