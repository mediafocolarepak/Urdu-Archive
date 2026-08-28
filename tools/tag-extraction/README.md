# Istruzioni — funzione di estrazione tag

Documento di specifica per Claude Code. Descrive una funzione da integrare nel
progetto: data una cartella o un singolo documento (`.inp`, `.docx`, `.txt`), ne
estrae al massimo sei tag da un vocabolario controllato e produce una tabella
con nome del file e tag in italiano, inglese e urdu, scrivendola sia in un file
di revisione sia su Supabase.

**Il codice di riferimento allegato è funzionante e collaudato.** Non va
riscritto da zero: va copiato nel progetto e adattato ai suoi percorsi e alle
sue convenzioni. Le sezioni «Trappole» e «Collaudo» contengono conoscenza
ricavata sul corpus reale: ignorarle produce un sistema che sembra funzionare e
perde silenziosamente metà dei risultati.

---

## 1. Che cosa deve fare

```bash
node bin/estrai-tag.js <file-o-cartella> [--max 6] [--out tag.csv] [--supabase]
```

- `<file-o-cartella>`: un singolo documento oppure una cartella, percorsa
  ricorsivamente. Formati: `.inp` (InPage), `.docx`, `.txt`.
- Per ogni documento: estrae il testo, cerca i termini del vocabolario, calcola
  un punteggio, seleziona al massimo `--max` tag (default 6).
- Scrive una tabella CSV con: `file`, `nome`, `caratteri`, `n_tag`, `tag_id`,
  **`tag_it`**, **`tag_en`**, **`tag_ur`**, `faccette`, `punteggi`.
- Con `--supabase` scrive anche nelle tabelle `tag` e `documento_tag`.
- Con `--dry-run` non scrive nulla e stampa la tabella a schermo.

Il file CSV **viene sempre prodotto**, anche quando si scrive su database: è la
revisione umana, e va guardata prima di considerare buono l'import.

---

## 2. Moduli da copiare nel progetto

| File | Responsabilità |
|---|---|
| `lib/normalizza.js` | forma canonica di confronto — **unica fonte di verità** |
| `lib/inpage.js` | decodifica dei documenti InPage legacy in Unicode |
| `lib/docx.js` | testo da `.docx` (zip + `word/document.xml`) |
| `lib/tassonomia.js` | carica il vocabolario YAML e costruisce i matcher |
| `lib/estrai.js` | assegnazione dei tag, punteggio, selezione dei migliori N |
| `lib/supabase.js` | scrittura su Supabase |
| `bin/estrai-tag.js` | interfaccia a riga di comando |
| `sql/schema.sql` | tabelle, indici, vista e funzione di ricerca |
| `tassonomia_focolare.yaml` | il vocabolario: 220 tag in 13 faccette |
| `test/collaudo.js` | collaudo minimo (`npm test`) |

Dipendenze: `cfb`, `js-yaml`, `adm-zip`, `@supabase/supabase-js`. Nessuna di
queste è pesante e nessuna richiede compilazione nativa.

---

## 3. Contratti delle funzioni

```js
// lib/normalizza.js
normalizza(testo: string): string

// lib/inpage.js
leggiInp(percorso: string): string          // .inp -> urdu Unicode
leggiTxtLegacy(percorso: string): string    // export .TXT di InPage
converti(dati: Buffer, {segnalaIgnoti?}): string

// lib/docx.js
leggiDocx(percorso: string): string

// lib/tassonomia.js
caricaTassonomia(percorsoYaml: string): { doc, tags: Map<id,Tag>, pattern: Pattern[] }

// lib/estrai.js
trovaTag(testo: string, tassonomia): Tag[]           // tutti, ordinati per punteggio
selezionaMigliori(tag: Tag[], max = 6, quote?): Tag[]

// lib/supabase.js
sincronizzaTassonomia(tassonomia): Promise<number>
scriviSuSupabase(voci, tassonomia): Promise<{scritte, orfani}>
```

Un tag estratto ha questa forma:

```js
{ tagId: 'SPI.gesu-abbandonato', faccetta: 'SPI', punteggio: 9,
  confidenza: 'alta', termini: ['یسوع متروک'],
  it: 'Gesu Abbandonato', en: 'Jesus Forsaken', ur: 'یسوع متروک' }
```

---

## 4. Come si scelgono i sei tag

Non si prendono semplicemente i sei col punteggio più alto: si rischia di
ottenere sei sfumature dello stesso argomento e nessuna indicazione di genere o
destinatario. La selezione applica **quote per faccetta**:

1. almeno **3 tag tematici** — faccette `SPI` (i dodici punti), `TEM` (temi),
   `COL` (i sette colori), `ADA` (arte di amare), `STR` (strumenti);
2. almeno **1 tag di contesto** — `GEN` (genere), `DES` (destinatario),
   `BRA` (branca);
3. i posti restanti vanno ai punteggi più alti, di qualunque faccetta.

Se il documento non offre abbastanza tag di una categoria, i posti liberi vanno
alle altre. **Non si inventa nulla per riempire le sei posizioni**: un documento
con due soli tag ne restituisce due.

Punteggio: `3 × match forti + match deboli`. Un tag con soli match deboli non
viene mai assegnato.

---

## 5. Database

Eseguire `sql/schema.sql`. Crea **solo tabelle nuove**: `tag`, `documento_tag`,
`documento_testo`, più una vista e una funzione di ricerca ricorsiva. Le colonne
esistenti dell'archivio (`category`, `main_topic`, `secondary_tags`,
`recipient`) non vengono toccate e continuano a servire l'applicazione attuale.

La colonna che conta davvero è **`documento_tag.origine`**, con valori
`auto` / `metadato` / `cartella` / `umano`. Serve a una cosa sola, ma decisiva:
permette di rilanciare l'estrazione su tutto il corpus **cancellando solo le
righe `auto`** e lasciando intatte le correzioni fatte a mano.

```sql
delete from documento_tag where origine = 'auto';   -- prima di ogni ripassata
```

Senza questa distinzione, la seconda esecuzione distrugge il lavoro di revisione
e il sistema si blocca dopo pochi giri.

Variabili d'ambiente: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`. La service
role key bypassa le policy RLS: **non deve mai finire nel bundle del client**.

---

## 6. Trappole

Sono tutte cose già costate tempo. Nessuna fa fallire il programma: fanno
soltanto sparire risultati.

**L'accento dattilografico.** I testi italiani scrivono `UNITA'`,
`GESU'ABBANDONATO`, `SPIRITUALITA'`, `CITTA'NUOVA`, `E'`, `PERCHE'` — vocale più
apostrofo al posto della vocale accentata. In italiano l'apostrofo preceduto da
vocale non è mai elisione (`l'`, `un'`, `dell'` finiscono in consonante), quindi
si converte in spazio. La regola vale in **tre luoghi**: indicizzazione, colonna
normalizzata nel database, e stringa digitata dall'utente nella ricerca.
Applicarla in uno solo è peggio che non applicarla, perché chi cerca «unità» non
trova `UNITA'` e nessun errore lo segnala.

**La ye automatica di InPage.** Il codice `0xA5` è reso *choti ye* in posizione
iniziale o mediana e *bari ye* in posizione finale. Senza questa regola `میں`
diventa `مےں` e `لیے` diventa `لےے`, e ogni ricerca su quelle parole fallisce.
È già implementata in `lib/inpage.js`: non semplificarla.

**I `.inp` non richiedono InPage.** Sono contenitori OLE con il testo nel flusso
`InPage100`, nella stessa codifica dell'export e **in ordine logico**. Non serve
né il programma né l'OCR.

**Sovrapposizioni fra alias.** Vince il match più lungo: `Word of Life` non deve
far scattare anche il tag generico `the Word`. Match con lo stesso identico span
convivono, perché un termine può servire due tag legati da gerarchia.

**Alias deboli.** `Chiara`, `Gen`, `Centro`, `zona` sono ambigui. Nel vocabolario
stanno sotto `weak` e da soli non assegnano mai un tag. Non promuoverli.

**I PDF non sono in questo flusso.** I PDF urdu dell'archivio hanno il testo in
ordine visivo e richiedono una ricostruzione geometrica: c'è uno script Python
separato (`estrai_urdu.py`). Non tentare di leggerli con una libreria PDF
generica: restituisce caratteri corretti in ordine sbagliato, che è il modo
peggiore di sbagliare perché sembra funzionare.

---

## 7. Collaudo

`npm test` esegue `test/collaudo.js`: tredici casi di normalizzazione, la regola
della ye, l'ordine dell'alfabeto InPage e la tolleranza dei pattern. **Va
eseguito dopo ogni modifica** a `lib/normalizza.js` o alla tabella in
`lib/inpage.js`.

Verifica funzionale minima su un campione reale:

```bash
node bin/estrai-tag.js ./campione --max 6 --out /tmp/prova.csv
```

Attese, misurate su 47 documenti InPage reali: tutti i file con almeno 40
caratteri di testo producono una riga; i documenti con testo di lunghezza
normale ricevono una mediana di 6 tag, di cui 3-4 tematici; nessuna riga ha i
campi `tag_ur` vuoti quando `tag_it` è pieno (se accade, manca l'etichetta urdu
nel vocabolario, non è un errore del codice).

Prima di considerare il sistema in esercizio, indicizzare a mano cinquanta
documenti e confrontare con l'output: la soglia ragionevole è **precisione ≥
0,90 e richiamo ≥ 0,75**. La precisione conta più del richiamo — un tag sbagliato
inquina le ricerche per sempre, un tag mancante si rimedia con la ricerca a
testo libero.

---

## 8. Manutenzione: il punto debole attuale

Il vocabolario ha in media cinque o sei alias italiani per tag e **uno o due
urdu**. Sui testi urdu questo abbassa il richiamo: documenti brevi che parlano
chiaramente di un argomento restano senza tag perché il vocabolario non conosce
il modo in cui quel testo lo dice.

Il rimedio non è cambiare l'algoritmo ma arricchire gli alias, e va fatto sul
corpus: eseguire l'estrazione, raccogliere i termini urdu frequenti che nessun
tag intercetta, e promuovere a mano quelli che meritano. Due o tre giri di questo
ciclo valgono più di qualunque modifica al codice.

Regole redazionali del vocabolario, da rispettare quando lo si amplia: un tag =
un concetto; nessun tag senza almeno cinque documenti che lo giustificano; il
`tag_id` non si rinomina e non si ricicla mai (si deprecano, puntando al
sostituto); nel dubbio un alias nasce `weak`.
