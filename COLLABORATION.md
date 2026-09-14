# Collaborare su questo progetto

Documento per chi si aggiunge allo sviluppo di **Focolare Urdu Archive Manager** insieme ad
Alessandro (proprietario del repo). Copre solo il flusso di lavoro condiviso — per l'ambiente di
sviluppo locale (clonare il repo, script PowerShell, server locale) vedi `NUOVO_COMPUTER_SETUP.md`,
che Alessandro ti passa direttamente (non è nel repo, per lo stesso motivo per cui non lo sono gli
script `_localserver.ps1`/`_sync_from_deploy.ps1`/`publish.ps1`: sono configurazione locale alla
singola macchina, non parte dell'app).

---

## 1. Accesso

- **GitHub**: Alessandro ti invita come collaboratrice del repo `mediafocolarepak/Urdu-Archive`
  con permesso di scrittura (Write). Ricevi un invito via email da accettare.
- **Supabase** (solo se devi eseguire migrazioni SQL o consultare il database direttamente):
  invito separato, indipendente da GitHub — chiedilo ad Alessandro se ti serve.
- Nessuna chiave da configurare: le credenziali Supabase e Google Drive sono incorporate nel
  codice (`js/core.js`), pubbliche per design — la sicurezza è nelle policy RLS del database, non
  nella segretezza di queste chiavi.

## 2. Flusso Git: branch + Pull Request

Non si lavora mai direttamente su `main`. Per ogni modifica:

```bash
git checkout main
git pull
git checkout -b nome-descrittivo-della-modifica
# ... modifiche, commit ...
git push -u origin nome-descrittivo-della-modifica
```

Poi apri una Pull Request su GitHub verso `main`. `main` è collegato a GitHub Pages: ogni push
lì pubblica automaticamente il sito, quindi il momento del merge è anche il momento della
pubblicazione — non è un ambiente di staging separato.

## 3. Attenzione a `publish.ps1`: un solo publisher alla volta

`publish.ps1` riscrive il token di versione (`?v=...`) in **tutti** i file JS ad ogni
pubblicazione, non solo in quelli modificati — è così che il progetto invalida la cache del
browser ad ogni release. Questo significa che se due persone pubblicano indipendentemente in
rapida successione, ottenete conflitti di merge su righe che non c'entrano nulla col lavoro
vero di nessuno dei due.

**Regola pratica**: prima di lanciare `publish.ps1`, avvisa l'altra persona (messaggio, chat) e
aspetta conferma che non stia per pubblicare anche lei nello stesso momento. Se lavorate spesso
in parallelo, valutate di designare una sola persona come "publisher" che fonde i branch altrui e
pubblica lei, invece che ognuno pubblica il proprio.

## 4. Tenere allineato il contesto tra due persone (`PROJECT_HANDOFF_vNN.md`)

Il progetto tiene lo stato reale (decisioni prese, cosa NON fare, prossimi passi) in un
documento `PROJECT_HANDOFF_vNN.md`, aggiornato a fine di ogni sessione di lavoro e incollato come
primo messaggio della sessione successiva (con Claude Code o assistente equivalente). Finora
viveva solo nella cartella Downloads di Alessandro, portato a mano da un computer all'altro — con
due persone questo non basta più.

**Regola pratica**:
- Chi finisce una sessione di lavoro **aggiorna `PROJECT_HANDOFF_vNN.md`** (nuova versione, non
  sovrascrivere la precedente) e lo condivide con l'altra persona — via una cartella Drive
  condivisa dedicata a questi file (da creare, non esiste ancora) o via email/chat.
- Prima di iniziare una nuova sessione, verifica di avere l'ultima versione e non una vecchia:
  guarda il numero più alto e la data in cima al file.
- Se avete lavorato entrambi nello stesso periodo su parti diverse, il documento più recente deve
  riassumere il lavoro di entrambi, non solo il proprio — altrimenti chi riparte perde pezzi.

## 5. Convenzioni di codice (invariate, si applicano a chiunque tocchi il codice)

- Vanilla JS, nessuno step di build, nessun `npm install`.
- Ogni modulo (`js/*.js`) importa solo da `core.js`, mai da un altro modulo — evita import
  circolari. Se due moduli devono condividere una funzione, questa vive in `core.js`.
- Nessun commento che spiega COSA fa il codice (i nomi già lo dicono) — solo commenti che
  spiegano un PERCHÉ non ovvio (un vincolo nascosto, un workaround, una decisione controintuitiva).
