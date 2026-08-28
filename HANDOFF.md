# Handoff — Focolare Urdu Archive Manager

Ultimo aggiornamento: 2026-08-28, dopo il merge di PR #12 e #13 (main @ `76e6faf`).
Scritto per continuare lo sviluppo in una nuova finestra di contesto senza perdere le convenzioni stabilite.

## Cos'è il progetto

- Repo: `mediafocolarepak/Urdu-Archive` su GitHub (org, non account personale)
- Sito live: pubblicato via GitHub Pages, deploy automatico dal branch `main`, su `https://mediafocolarepak.github.io/Urdu-Archive/`
- Stack: **Supabase** (Postgres + Auth + Storage + Realtime) come backend, **JS vanilla a moduli ES** nel frontend — nessun framework, nessun build step, nessun bundler. Eccezione: da questa sessione esiste anche un **tool Node CLI separato** (`tools/tag-extraction/`, vedi sotto) che invece richiede `npm install`.
- Database Supabase: project ref `tvabpsxfwofiqriwbolz` (URL/anon key sono hardcoded in `js/core.js`, sono pubblici per design — la sicurezza è demandata interamente a RLS/Row Level Security)
- Utente: non tecnico ma molto operativo — esegue lui stesso le query SQL nell'SQL Editor di Supabase, apre la Console del browser (F12) quando gli si chiede, testa sul telefono vero. Comunica in italiano. Ha in programma una presentazione a un gruppo numeroso entro la settimana dall'8/2026 (vedi sezione SMTP sotto).

## Architettura del codice

- [index.html](index.html) — unico entry point, login/signup screen + shell dell'app
- [js/core.js](js/core.js) — client Supabase (`sb`, esposto anche su `window.__sb` per debug), `State` condiviso, helper generici (`esc`, `withStatus`, `withStatusCount`, `labelOf`, `optionsHtml`...), tutta la logica di autenticazione, splash-screen, **e ora anche l'accesso Google Drive** (lettura via API key pubblica + scrittura via OAuth, vedi sotto). **Pattern architetturale importante**: ogni modulo funzionale importa *solo* da `core.js` (mai da un altro modulo feature), per tenere il grafo delle import una semplice stella ed evitare dipendenze circolari. L'unica eccezione è `window.__renderTab` (escape hatch in `app.js` per navigare da moduli che non possono importare `app.js` senza creare un ciclo — usato ora anche da `workconsolidation.js` per saltare su Match Review).
- [js/app.js](js/app.js) — dispatcher dei tab, wiring del boot
- [js/dashboard.js](js/dashboard.js) — elenco/ricerca documenti (tabella su desktop, card su mobile <700px)
- [js/docdetail.js](js/docdetail.js) — dettaglio/modifica documento
- [js/hayatindex.js](js/hayatindex.js) — vista di sola consultazione dell'indice Hayat + pulsante "Extract"
- [js/hayateditor.js](js/hayateditor.js) — editor a griglia dell'indice Hayat: CRUD, Import/Paste/Export CSV, finestra "Gemini Prompt"
- [js/inpageconverter.js](js/inpageconverter.js) — **nuovo** (PR #12): scheda "InPage Converter", vedi sezione dedicata sotto
- [js/admin.js](js/admin.js) — gestione Users (+ modifica profilo), Options (liste a tendina), Announcements (editor splash-screen)
- [js/chat.js](js/chat.js) — messaggistica/ticketing utente↔admin, notifiche live
- [js/matchreview.js](js/matchreview.js) — ora con filtri Source e "Show only orphans" (PR #12)
- [js/workconsolidation.js](js/workconsolidation.js) — ora con pulsante "Match Review" per riga orfana (PR #12)
- [js/adminedit.js](js/adminedit.js), `bulkimport.js`, `reports.js`, `userguide.js`, `combobox.js`, `tests.js` — altri moduli funzionali, invariati
- [js/pwa-register.js](js/pwa-register.js) + [sw.js](sw.js) + [manifest.json](manifest.json) + `icons/` — supporto PWA
- [sql/](sql/) — script di migrazione numerati, **da eseguire manualmente** nell'SQL Editor di Supabase (nessun sistema di migrazione automatico)
- [tools/tag-extraction/](tools/tag-extraction/) — **nuovo** (PR #13): tool CLI Node, indipendente dall'app browser, vedi sezione dedicata sotto

## Convenzioni tecniche da rispettare

1. **`withStatus(promise)` restituisce l'array dei dati DIRETTAMENTE** (lancia un'eccezione in caso di errore). MAI scrivere `const { data } = await withStatus(...)`. `withStatusCount(promise)` invece restituisce `{ data, count }` — quello sì va destrutturato.
2. **Cache-busting**: ogni file `.js`/`.html` porta una query string `?v=YYYYMMDDHHMMSS` da aggiornare ad ogni deploy (tutti i file insieme, incluso `sw.js` con la sua `CACHE_VERSION`). Versione attuale: `20260828120000`.
   ```bash
   grep -rl "VECCHIA_VERSIONE" --include="*.html" --include="*.js" . | xargs sed -i 's/VECCHIA_VERSIONE/NUOVA_VERSIONE/g'
   sed -i "s/CACHE_VERSION = 'VECCHIA_VERSIONE'/CACHE_VERSION = 'NUOVA_VERSIONE'/" sw.js
   ```
3. **Test locale**: nessun build step per l'app browser; si serve con un piccolo server statico Node ad hoc (script minimale con `http.createServer`, da riscrivere al volo se serve — vedi cronologia sessione). Il **service worker non è testabile nel browser sandbox di Claude** (blocca qualunque registrazione SW): va verificato sul sito vero.
4. **Librerie caricate da CDN in `<script>` tag** (fuori dal grafo dei moduli ES): occhio al **Content-Type**. jsDelivr serve `.cjs` con MIME `application/node`, che i browser rifiutano di eseguire come `<script>` (strict MIME checking) — scoperto solo testando nel browser vero, non con Node. Preferire build `.iife.js` o `.min.js`, mai `.cjs`/`.umd.cjs`, per qualunque libreria caricata così in futuro.
5. **RLS**: ogni nuova tabella ha policy basate sul ruolo in `user_roles` (`user`/`operator`/`admin`), stesso pattern delle tabelle esistenti. Ricordarsi SELECT, INSERT e UPDATE se servono entrambi.
6. **Workflow Git**: **creare SEMPRE un branch prima di modificare file**, mai lavorare direttamente su `main`:
   ```bash
   git checkout main && git pull && git checkout -b feature/nome-descrittivo
   ```
   Poi: commit → push → `gh pr create` (corpo dettagliato + test plan) → **aspettare conferma dell'utente** (soprattutto se serve eseguire SQL) → `gh pr merge <N> --merge --delete-branch` → `git fetch --prune`.
7. **gh CLI**: già autenticato come `mediafocolarepak`. Se in una nuova sessione desktop `git push`/`gh pr` dà errori di permessi, rifare `gh auth login` (device flow) + `gh auth setup-git`.
8. **Prima di dare per buona una libreria/API di terze parti, verificarla contro il sorgente reale** (property names esatti, MIME type, comportamento in un vero browser) invece di fidarsi solo della documentazione o di un test in Node — il bug del punto 4 e il bug della divisione in paragrafi (sotto) sono stati trovati solo così.

## Novità di questa sessione

### PR #12 — Scheda "InPage Converter" + filtri Match Review

Nuova scheda (operator/admin), pensata come **convertitore generico InPage → Word/PDF**, non legata a un documento specifico dell'archivio:

1. L'utente sceglie un file `.inp` locale (già modificato in InPage)
2. "Convert" decodifica il binario InPage in Unicode direttamente nel browser (nessun passaggio per InPage/clipboard) — algoritmo portato da [ltrc/inPageToUnicode](https://github.com/ltrc/inPageToUnicode) (GPLv2), **verificato byte-per-byte identico** alla libreria originale su un file reale di produzione
3. Il testo convertito appare in un'anteprima editabile
4. "Download Word (.docx)" genera un file Word con intestazione (Document ID + riferimento inglese) e corpo urdu RTL in font Jameel Noori Nastaleeq (libreria `docx` via CDN, caricata lazy solo quando serve)
5. "Generate PDF (print)" apre un'anteprima di stampa nel browser — niente generazione PDF lato client: si sfrutta il motore di rendering del browser stesso (unico modo affidabile di riprodurre la legatura Nastaliq senza una libreria di shaping dedicata), l'utente salva con "Salva come PDF" dal dialogo di stampa nativo
6. Campo "Google Drive folder (link o ID)" opzionale + pulsante "Update files on Drive": carica/sovrascrive `.inp` e `.docx` in quella cartella via OAuth (il PDF resta un passaggio manuale, spiegato nell'hint della UI)

**Due bug reali trovati e corretti solo testando nel vero browser** (Node da solo non li avrebbe mai rivelati):
- La libreria `docx` veniva caricata da un URL jsDelivr con estensione `.umd.cjs`, servito con MIME type non eseguibile dal browser → cambiato in `.iife.js`
- La divisione in paragrafi cercava una riga vuota doppia (`\n{2,}`), ma il testo convertito da InPage separa i paragrafi con un solo `\r\n` → l'intero documento Word sarebbe finito in un unico blocco senza interruzioni. Corretto: ogni riga sorgente diventa un paragrafo Word

**OAuth Google Drive** (scrittura): nuovo Client ID OAuth 2.0 creato nello stesso progetto Google Cloud della API key esistente (usata altrove solo in lettura), scope `drive` completo, autorizzato per `https://mediafocolarepak.github.io`. L'app è in stato **"Testing"** su Google Cloud (non verificata) — solo gli utenti aggiunti come **test user** possono autorizzare l'accesso: al momento `alessanpk@gmail.com`, `media.focolarepak@gmail.com`, `stellajohn2013@gmail.com`. Altri operator/admin che dovranno usare "Update files on Drive" vanno aggiunti lì (Google Cloud Console → il progetto → Google Auth Platform → Audience → Test users).

**Match Review**: aggiunti filtro **Source** e checkbox **"Show only orphans"** (documenti il cui Work non è mai stato unito).
**Work Consolidation**: le righe della lista manuale orfani hanno ora un pulsante **"Match Review"** che porta direttamente su Match Review con quel documento selezionato e i filtri pre-impostati (stessa source, solo orfani) — evita di dover cercare/digitare un ID a memoria.

**Non ancora testato da un umano**: il vero upload OAuth su Drive (richiede il consenso interattivo di Google, non simulabile in automazione) e l'apertura del `.docx` generato in Word vero (verificato finora solo ispezionando l'XML interno del file).

### PR #13 — Tool CLI di estrazione tag (`tools/tag-extraction/`)

Tool Node **separato** dall'app browser (richiede `npm install`), fornito dall'utente come implementazione di riferimento già collaudata (vedi `tools/tag-extraction/README.md` per le istruzioni complete, comprese le "Trappole" — errori già commessi e da non ripetere). Dato un file o una cartella di documenti `.inp`/`.docx`/`.txt`, estrae fino a 6 tag da un vocabolario controllato di 220 tag/13 faccette (etichette it/en/ur), scrive un CSV di revisione e, con `--supabase`, scrive anche su due nuove tabelle Supabase.

Adattamenti fatti rispetto al codice fornito (per allinearlo allo schema reale, come richiesto dalle istruzioni stesse):
- `lib/supabase.js` cercava una tabella `documento` con colonna `legacy_file_name`, inesistenti — corretto per usare la vera tabella `documents`
- Il percorso di default della tassonomia ora è relativo alla cartella dello script (`__dirname`), non alla cwd di chi lo lancia

`sql/22_tag_taxonomy.sql`: nuove tabelle `tag`, `documento_tag`, `documento_testo` (+ vista, funzione di ricerca ricorsiva, RLS in lettura per qualunque utente autenticato). **Additivo**: non tocca `documents.category`/`main_topic`/`secondary_tags`/`recipient`.

**Verificato**: `npm install` + `npm test` (17 casi) passano; `--dry-run` su un file reale ha prodotto 6 tag sensati.
**Non ancora fatto**: la migrazione SQL non è stata eseguita sul database di produzione; `--supabase` non è mai stato lanciato per davvero (solo `--dry-run`). Consigliato provarlo prima su una cartella piccola.

### Incidente Supabase (risolto da solo, non un bug nostro)

Durante la sessione, i tentativi di signup fallivano con `HTTP 504` e i log mostravano `ShareLock` in attesa per diversi secondi in modo ricorrente. Causa: un **incidente noto lato piattaforma Supabase** ("Increased response times for requests", vedi status.supabase.com), non una configurazione sbagliata nostra. Si è risolto da solo con il tempo — se ricapita un pattern simile, controllare prima lo status di Supabase prima di indagare lato nostro.

### Email SMTP configurata (per l'evento della prossima settimana)

Il servizio email integrato di Supabase (usato quando non c'è SMTP personalizzato) ha un limite di sole **2 email/ora** — troppo poco per un evento con molte persone che si iscrivono. Configurato **SMTP personalizzato con Gmail** (account `media.focolarepak@gmail.com`, App Password generata appositamente) in Supabase Dashboard → Authentication → Emails, e alzato il **rate limit per l'invio email** (Authentication → Rate Limits) da 2 a 30/ora. Non ancora ritestato con un signup reale dopo la risoluzione dell'incidente Supabase — da verificare alla prossima occasione, prima dell'evento.

## Cose aperte / da tenere a mente

- **Account di test** `alessanpk+uatest1@gmail.com`: esiste, confermato, ruolo admin ripristinato — ma **la password non è nota** (il reset via email non mostra mai un form per impostarne una nuova, perché l'app non gestisce la UI di recovery: un utente che clicca un link di reset viene loggato direttamente). Se serve di nuovo un login per questo account, o si usa l'API Admin di Supabase per impostare una password nota (richiede la Service Role Key, **mai condividerla in chat** — vedi punto sotto), oppure si costruisce prima una vera schermata "imposta nuova password" nell'app.
- **Attenzione Service Role Key**: durante questa sessione l'utente l'ha incollata per errore in chiaro in chat mentre debuggava un comando PowerShell. È stata segnalata subito e l'utente ha detto di volerla rigenerare — **verificare alla prossima sessione che sia stata effettivamente rigenerata** (Supabase Dashboard → Project Settings → API).
- Riga di prova `diagnostic_test` in `app_settings`: **eliminata** in questa sessione.
- Non ancora testato da un umano: upload OAuth Drive (PR #12) e migrazione/uso reale del tool tag-extraction (PR #13) — vedi le due sezioni sopra.
- Segnalato ma non affrontato (da sessioni precedenti, resta valido): `confirm()`/`alert()` nativi in `hayateditor.js` — rischio teorico su PWA installata, mai confermato da un problema concreto. Non intervenire preventivamente.
- Account admin reali in uso: `alessanpk@gmail.com` e `alessanpk@yahoo.it`.

## Come ripartire

1. `cd` nella cartella del repo (`E:\Ale Projects\Urdu-Archive` — non confondere con `E:\Ale Projects\Urdu Archive`, la working directory di sessione)
2. `git status` e `git pull` per allinearsi con `origin/main`
3. Per qualunque nuova modifica, seguire il workflow Git del punto 6 sopra
4. Se emergono errori 504/lentezza anomala e persistente, controllare prima [status.supabase.com](https://status.supabase.com) prima di indagare lato codice
