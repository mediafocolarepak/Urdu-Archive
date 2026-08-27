# Handoff — Focolare Urdu Archive Manager

Ultimo aggiornamento: 2026-08-27, dopo il merge di PR #10 (main @ `2c8672d`).
Scritto per continuare lo sviluppo in una nuova finestra di contesto senza perdere le convenzioni stabilite.

## Cos'è il progetto

- Repo: `mediafocolarepak/Urdu-Archive` su GitHub (org, non account personale)
- Sito live: pubblicato via GitHub Pages, deploy automatico dal branch `main`
- Stack: **Supabase** (Postgres + Auth + Storage + Realtime) come backend, **JS vanilla a moduli ES** nel frontend — nessun framework, nessun build step, nessun bundler
- Database Supabase: project ref `tvabpsxfwofiqriwbolz` (URL/anon key sono hardcoded in `js/core.js`, sono pubblici per design — la sicurezza è demandata interamente a RLS/Row Level Security)
- Utente: non tecnico ma molto operativo — esegue lui stesso le query SQL nell'SQL Editor di Supabase, apre la Console del browser (F12) quando gli si chiede, testa sul telefono vero. Comunica in italiano. All'inizio di questa collaborazione ha chiesto lezioni introduttive su Git/GitHub/SQL/ecc. ogni volta che si presentava un concetto nuovo — mantenere questo stile se il contesto lo richiede ancora.

## Architettura del codice

- [index.html](index.html) — unico entry point, login/signup screen + shell dell'app
- [js/core.js](js/core.js) — client Supabase (`sb`, esposto anche su `window.__sb` per debug), `State` condiviso, helper generici (`esc`, `withStatus`, `withStatusCount`, `labelOf`, `optionsHtml`...), tutta la logica di autenticazione, splash-screen. **Pattern architetturale importante**: ogni modulo funzionale importa *solo* da `core.js` (mai da un altro modulo feature), per tenere il grafo delle import una semplice stella ed evitare dipendenze circolari. L'unica eccezione è `window.__renderTab` (escape hatch in `app.js` per navigare da moduli che non possono importare `app.js` senza creare un ciclo).
- [js/app.js](js/app.js) — dispatcher dei tab, wiring del boot
- [js/dashboard.js](js/dashboard.js) — elenco/ricerca documenti (tabella su desktop, card su mobile <700px — entrambi i markup sono sempre nel DOM, decide una media query CSS)
- [js/docdetail.js](js/docdetail.js) — dettaglio/modifica documento
- [js/hayatindex.js](js/hayatindex.js) — vista di sola consultazione dell'indice Hayat + pulsante "Extract"
- [js/hayateditor.js](js/hayateditor.js) — editor a griglia dell'indice Hayat: CRUD, Import/Paste/Export CSV, finestra "Gemini Prompt"
- [js/admin.js](js/admin.js) — gestione Users (+ modifica profilo), Options (liste a tendina), Announcements (editor splash-screen)
- [js/chat.js](js/chat.js) — messaggistica/ticketing utente↔admin, notifiche live
- [js/adminedit.js](js/adminedit.js), `matchreview.js`, `workconsolidation.js`, `bulkimport.js`, `reports.js`, `userguide.js`, `combobox.js`, `tests.js` — altri moduli funzionali
- [js/pwa-register.js](js/pwa-register.js) + [sw.js](sw.js) + [manifest.json](manifest.json) + `icons/` — supporto PWA
- [sql/](sql/) — script di migrazione numerati, **da eseguire manualmente** nell'SQL Editor di Supabase (nessun sistema di migrazione automatico)

## Convenzioni tecniche da rispettare (letto-il-codice-e-sbagliato-una-volta)

1. **`withStatus(promise)` restituisce l'array dei dati DIRETTAMENTE** (lancia un'eccezione in caso di errore). MAI scrivere `const { data } = await withStatus(...)` — è sbagliato, `data` sarà sempre `undefined` (bug reale trovato e corretto in PR #10). Usa `const rows = await withStatus(...)` e poi `rows[0]`, ecc.
   `withStatusCount(promise)` invece restituisce `{ data, count }` — quello sì va destrutturato.
2. **Cache-busting**: ogni file `.js`/`.html` porta una query string `?v=YYYYMMDDHHMMSS` che va aggiornata ad ogni deploy (in tutti i file contemporaneamente, incluso `sw.js` che ha una costante `CACHE_VERSION` separata da tenere allineata). Versione attuale: `20260827220000`. Comando tipo:
   ```bash
   grep -rl "VECCHIA_VERSIONE" --include="*.html" --include="*.js" . | xargs sed -i 's/VECCHIA_VERSIONE/NUOVA_VERSIONE/g'
   sed -i "s/CACHE_VERSION = 'VECCHIA_VERSIONE'/CACHE_VERSION = 'NUOVA_VERSIONE'/" sw.js
   ```
3. **Test locale**: nessun build step, si serve con un piccolo server statico Node (nessun tool come `http-server` disponibile in questo ambiente per problemi di npm/PATH — ne è stato scritto uno ad hoc, vedi cronologia sessione se serve rigenerarlo). Il **service worker non è testabile nel browser sandbox di Claude** (blocca *qualunque* registrazione SW, anche banale — limite dell'ambiente, non bug dell'app): va verificato sul sito vero.
4. **RLS**: ogni nuova tabella ha policy basate sul ruolo in `user_roles` (`user`/`operator`/`admin`), seguendo lo stesso pattern delle tabelle esistenti. Ricordarsi sia SELECT che INSERT che UPDATE se serve — un errore fatto due volte in questa sessione: dimenticare la policy INSERT quando serviva anche upsert su righe non ancora esistenti.
5. **Workflow Git** (fondamentale, sbagliato due volte in questa sessione): **creare SEMPRE un branch prima di modificare file**, mai lavorare direttamente su `main`:
   ```bash
   git checkout main && git pull && git checkout -b feature/nome-descrittivo
   ```
   Poi: commit → push → `gh pr create` (con corpo dettagliato + test plan) → **aspettare conferma dell'utente** (soprattutto se serve eseguire SQL) → `gh pr merge <N> --merge --delete-branch` → `git fetch --prune`.
   Se ci si accorge di aver modificato file stando già su `main` senza commit: si può ancora rimediare con `git checkout -b nuovo-branch` (porta con sé le modifiche non committate), poi `git checkout main && git reset --hard origin/main` per pulire `main`.
6. **gh CLI**: già autenticato in questo ambiente come `mediafocolarepak` (via `gh auth login` + `gh auth setup-git` per risolvere un conflitto di credenziali Windows Credential Manager). Se in una nuova sessione desktop `git push`/`gh pr` desse errori di permessi/autenticazione, rifare `gh auth login` (device flow) + `gh auth setup-git`.

## Funzionalità aggiunte in questa sessione (in ordine, ognuna in una PR separata, tutte mergiate)

| PR | Cosa | Migrazione SQL |
|---|---|---|
| #1 | Signup esteso (nome, città, appartenenza Focolare, cellulare) → `user_profiles`, trigger su `auth.users` | `16_signup_chat_splash.sql` |
| #1 | Splash-screen avvisi (`splash_messages`), una volta a sessione | incluso in `16` |
| #1 | Chat/ticketing utente↔admin (`chat_messages`), tag segnalazione, reply, dismiss | incluso in `16` |
| #2 | Document ID opzionale + precompilato da documento selezionato; notifiche live (Realtime + controllo al login); modifica profilo utente da parte admin | `17_realtime_chat.sql` |
| #3 | PWA (manifest, service worker, icona) + vista a schede mobile per l'elenco documenti | — |
| #4 | Nome completo (non email) per chi pubblica un avviso; pulsante "Previous Announcements" con storico | `18_public_admin_profile_names.sql` |
| #5 | Campo "Ur-Title" dedicato su `documents` e `hayat_indice` | `19_ur_title.sql` |
| #6 | Rework Import/Export CSV Hayat per il formato dello strumento esterno (Gemini); nuovo pulsante "Paste CSV" | `20_hayat_data_pdv.sql` |
| #7 | Fix bug PWA sospetto su `confirm()`; validazione consistenza CSV; verifica reale dell'avvenuto import; pulsante "Gemini Prompt" (testo condiviso, tabella generica `app_settings`) | `21_app_settings.sql` |
| #8 | "Gemini Prompt" in sola lettura di default + pulsante Edit; primo tentativo di fix del bug di salvataggio (parziale) | — |
| #9 | Esposto `window.__sb` per diagnosi via Console del browser | — |
| #10 | **Trovato e corretto il vero bug**: `const { data } = await withStatus(...)` — vedi punto 1 sopra | — |

Tutte le migrazioni SQL (16-21) sono già state eseguite sul database di produzione.

## Cose aperte / da tenere a mente

- C'è una riga di prova `diagnostic_test` nella tabella `app_settings`, lasciata da una sessione di debug — innocua, l'utente non ha ancora confermato se vuole che la elimini
- Account di test `alessanpk+uatest1@gmail.com`: esiste ma **non ha più un ruolo** in `user_roles` (l'utente lo ha rimosso durante i test) — se serve di nuovo per testare funzionalità che richiedono `operator`/`admin`, va ripromosso dalla scheda Users
- Account admin reali in uso: `alessanpk@gmail.com` e `alessanpk@yahoo.it`
- Segnalato ma non affrontato: altri `confirm()`/`alert()` nativi rimasti in `hayateditor.js` (Delete selected, Extract selected) e altrove nell'app — si ipotizzava fossero a rischio sulla PWA installata, ma il bug reale trovato in PR #10 era tutt'altro (un errore di destrutturazione). Il rischio teorico resta, ma **non è confermato** — da rivalutare solo se viene segnalato un problema concreto, non "silenziare" tutto preventivamente
- Nessun bug noto aperto al momento della scrittura di questo file

## Come ripartire

1. `cd` nella cartella del repo (nota: probabilmente `E:\Ale Projects\Urdu-Archive`, **non** `E:\Ale Projects\Urdu Archive` — nomi di cartelle diversi, il secondo è la working directory di sessione ma il repo vero è nel primo)
2. `git status` e `git pull` per assicurarsi di essere allineati con `origin/main`
3. Per qualunque nuova modifica, seguire il workflow del punto 5 sopra (branch → PR → conferma utente → merge)
