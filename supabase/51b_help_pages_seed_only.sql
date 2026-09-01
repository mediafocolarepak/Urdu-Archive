-- Seed data: the 12 guides (6 Italian + 6 English), self-contained HTML incl. their own <style>.

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('roles_it', 'it', null, 'Il Libro dei Ruoli', $q_roles_it$
<!doctype html>
<html>
<body><div id="page-static"><title>Il Libro dei Ruoli</title>
<style>
  :root {
    --paper: #eef0e6;
    --paper-raised: #f8f9f2;
    --paper-card: #f3f4ea;
    --ink: #1e2a1f;
    --ink-soft: #55624e;
    --ink-faint: #838f79;
    --line: #d2d6c1;
    --line-strong: #b9bea3;
    --brass: #8f6a24;
    --brass-strong: #6e5219;
    --thread: #7c3430;
    --thread-soft: #f3e4de;
    --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30, 42, 31, 0.06), 0 6px 20px rgba(30, 42, 31, 0.05);
  }

  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810;
      --paper-raised: #1a2116;
      --paper-card: #1e261a;
      --ink: #e8e7d8;
      --ink-soft: #a8ae98;
      --ink-faint: #798270;
      --line: #303a29;
      --line-strong: #414d36;
      --brass: #d2a24e;
      --brass-strong: #e6b869;
      --thread: #cf7d78;
      --thread-soft: #2c1a18;
      --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0, 0, 0, 0.3), 0 8px 24px rgba(0, 0, 0, 0.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810;
    --paper-raised: #1a2116;
    --paper-card: #1e261a;
    --ink: #e8e7d8;
    --ink-soft: #a8ae98;
    --ink-faint: #798270;
    --line: #303a29;
    --line-strong: #414d36;
    --brass: #d2a24e;
    --brass-strong: #e6b869;
    --thread: #cf7d78;
    --thread-soft: #2c1a18;
    --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0, 0, 0, 0.3), 0 8px 24px rgba(0, 0, 0, 0.35);
  }

  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  body {
    margin: 0;
    background: var(--paper);
    color: var(--ink);
    font-family: "Archivo", "Segoe UI", -apple-system, sans-serif;
    font-size: 16px;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
  }
  @media (prefers-reduced-motion: reduce) {
    html { scroll-behavior: auto; }
    * { animation: none !important; transition: none !important; }
  }

  h1, h2, h3 {
    font-family: "Fraunces", Georgia, serif;
    color: var(--ink);
    text-wrap: balance;
    font-weight: 600;
    margin: 0;
  }

  .eyebrow {
    font-family: "IBM Plex Mono", ui-monospace, monospace;
    font-size: 11.5px;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--brass);
    font-weight: 600;
  }

  a { color: var(--brass-strong); }

  /* ---------- Layout shell ---------- */
  .shell {
    display: grid;
    grid-template-columns: 240px minmax(0, 1fr);
    max-width: 1180px;
    margin: 0 auto;
  }
  @media (max-width: 860px) {
    .shell { grid-template-columns: 1fr; }
  }

  nav.toc {
    position: sticky;
    top: 0;
    align-self: start;
    height: 100vh;
    overflow-y: auto;
    padding: 40px 20px 40px 28px;
    border-right: 1px solid var(--line);
  }
  @media (max-width: 860px) {
    nav.toc {
      position: static;
      height: auto;
      border-right: none;
      border-bottom: 1px solid var(--line);
      padding: 18px 20px;
      overflow-x: auto;
      white-space: nowrap;
    }
  }

  .toc-brand {
    font-family: "Fraunces", serif;
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 22px;
    display: flex;
    align-items: baseline;
    gap: 8px;
  }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono", monospace; }
  @media (max-width: 860px) { .toc-brand { display: inline-flex; margin: 0 24px 0 0; } }

  nav.toc ol {
    list-style: none;
    margin: 0;
    padding: 0;
    counter-reset: sec;
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  @media (max-width: 860px) {
    nav.toc ol { flex-direction: row; gap: 4px; }
  }
  nav.toc li { counter-increment: sec; }
  nav.toc a {
    display: flex;
    gap: 8px;
    padding: 6px 8px;
    margin: 0 -8px;
    border-radius: 3px;
    color: var(--ink-soft);
    text-decoration: none;
    font-size: 13.5px;
    line-height: 1.3;
  }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before {
    content: counter(sec, decimal-leading-zero);
    font-family: "IBM Plex Mono", monospace;
    font-size: 11px;
    color: var(--ink-faint);
    flex: none;
    padding-top: 1px;
  }
  @media (max-width: 860px) {
    nav.toc a { white-space: nowrap; margin: 0; }
  }

  main { padding: 56px 48px 120px; min-width: 0; }
  @media (max-width: 860px) { main { padding: 40px 20px 90px; } }

  .cover { max-width: 640px; margin-bottom: 90px; }
  .cover .eyebrow { display: block; margin-bottom: 16px; }
  .cover h1 {
    font-size: clamp(34px, 5.4vw, 52px);
    line-height: 1.08;
    letter-spacing: -0.01em;
  }
  .cover .lede {
    margin-top: 22px;
    font-size: 18px;
    line-height: 1.65;
    color: var(--ink-soft);
    max-width: 62ch;
  }
  .cover .meta {
    margin-top: 32px;
    display: flex;
    gap: 28px;
    flex-wrap: wrap;
    font-family: "IBM Plex Mono", monospace;
    font-size: 12px;
    color: var(--ink-faint);
  }
  .cover .meta b { color: var(--ink-soft); font-weight: 600; }

  section { max-width: 68ch; margin-bottom: 84px; scroll-margin-top: 32px; }
  section.wide { max-width: 900px; }
  section > .eyebrow { display: block; margin-bottom: 10px; }
  section h2 { font-size: clamp(24px, 3.4vw, 30px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 15.5px; margin: 10px 0 30px; max-width: 58ch; }

  p { margin: 0 0 16px; }
  p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }

  .rule {
    border: none;
    border-top: 1px solid var(--line);
    margin: 0 0 30px;
  }

  /* ---------- Role ladder ---------- */
  .ladder { display: flex; flex-direction: column; gap: 10px; margin: 8px 0 8px; }
  .rung {
    display: grid;
    grid-template-columns: 140px 1fr;
    gap: 20px;
    align-items: start;
    padding: 18px 20px;
    background: var(--paper-card);
    border: 1px solid var(--line);
    border-left: 3px solid var(--line-strong);
    border-radius: 4px;
  }
  .rung.top { border-left-color: var(--brass); }
  @media (max-width: 620px) { .rung { grid-template-columns: 1fr; gap: 8px; } }
  .rung .role-name {
    font-family: "Fraunces", serif;
    font-weight: 600;
    font-size: 17px;
  }
  .rung .role-code {
    display: block;
    font-family: "IBM Plex Mono", monospace;
    font-size: 10.5px;
    letter-spacing: 0.08em;
    color: var(--ink-faint);
    margin-top: 3px;
    text-transform: uppercase;
  }
  .rung ul { margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 5px; }
  .rung li { font-size: 14px; color: var(--ink-soft); padding-left: 15px; position: relative; }
  .rung li::before {
    content: "";
    position: absolute; left: 0; top: 8px;
    width: 5px; height: 5px; border-radius: 50%;
    background: var(--brass);
    opacity: 0.7;
  }
  .rung li b { color: var(--ink); font-weight: 600; }
  .cumulative-note {
    font-size: 13px;
    color: var(--ink-faint);
    margin-top: 14px;
    padding-left: 4px;
    border-left: 2px solid var(--line);
    padding-left: 14px;
  }

  /* ---------- Qualification chips ---------- */
  .qual-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
    margin: 8px 0 20px;
  }
  @media (max-width: 620px) { .qual-grid { grid-template-columns: 1fr; } }
  .qual-card {
    background: var(--paper-card);
    border: 1px solid var(--line);
    border-radius: 4px;
    padding: 16px 18px;
  }
  .qual-card .qname {
    font-family: "Fraunces", serif;
    font-weight: 600;
    font-size: 15.5px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .qual-card .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--brass); flex: none; }
  .qual-card p { font-size: 13.5px; color: var(--ink-soft); margin-top: 8px; }

  /* ---------- Diagram figure ---------- */
  figure { margin: 0 0 8px; }
  figure svg { display: block; width: 100%; height: auto; max-width: 100%; overflow: visible; }
  figcaption {
    font-size: 13px;
    color: var(--ink-faint);
    margin-top: 14px;
    padding-top: 12px;
    border-top: 1px solid var(--line);
  }
  .diagram-wrap {
    background: var(--paper-raised);
    border: 1px solid var(--line);
    border-radius: 6px;
    padding: 28px 24px 18px;
    box-shadow: var(--shadow);
    margin: 4px 0 30px;
    overflow-x: auto;
  }

  /* ---------- Callouts / exit paths ---------- */
  .exit-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin: 26px 0; }
  @media (max-width: 620px) { .exit-grid { grid-template-columns: 1fr; } }
  .exit-card {
    border-radius: 4px;
    padding: 16px 18px;
    border: 1px solid var(--line);
  }
  .exit-card.calm { background: var(--sage-soft); border-color: var(--line-strong); }
  .exit-card.warn { background: var(--thread-soft); border-color: color-mix(in srgb, var(--thread) 35%, var(--line)); }
  .exit-card .label {
    font-family: "IBM Plex Mono", monospace;
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    font-weight: 600;
  }
  .exit-card.calm .label { color: var(--brass-strong); }
  .exit-card.warn .label { color: var(--thread); }
  .exit-card h3 { font-size: 15.5px; margin-top: 6px; }
  .exit-card p { font-size: 13.5px; color: var(--ink-soft); margin-top: 8px; }

  /* ---------- Definition rows (credits/reputation) ---------- */
  .def-row {
    display: grid;
    grid-template-columns: 130px 1fr;
    gap: 20px;
    padding: 18px 0;
    border-top: 1px solid var(--line);
  }
  .def-row:last-child { border-bottom: 1px solid var(--line); }
  @media (max-width: 620px) { .def-row { grid-template-columns: 1fr; gap: 6px; } }
  .def-row dt {
    font-family: "Fraunces", serif;
    font-weight: 600;
    font-size: 16px;
  }
  .def-row dd { margin: 0; font-size: 14.5px; color: var(--ink-soft); }

  /* reputation meter sample */
  .meter { display: flex; align-items: center; gap: 12px; margin-top: 14px; }
  .meter .track {
    flex: 1;
    height: 8px;
    border-radius: 5px;
    background: var(--line);
    overflow: hidden;
  }
  .meter .fill {
    height: 100%;
    width: 50%;
    border-radius: 5px;
    background: linear-gradient(90deg, var(--thread), var(--brass));
  }
  .meter .val { font-family: "IBM Plex Mono", monospace; font-size: 13px; color: var(--ink-soft); flex: none; }

  /* ---------- Log strip ---------- */
  .log-strip { display: flex; flex-direction: column; border: 1px solid var(--line); border-radius: 4px; overflow: hidden; margin: 10px 0 24px; }
  .log-line {
    display: grid;
    grid-template-columns: 100px 110px 1fr;
    gap: 14px;
    padding: 11px 16px;
    font-size: 13px;
    border-top: 1px solid var(--line);
  }
  .log-line:first-child { border-top: none; background: var(--paper-card); }
  @media (max-width: 620px) { .log-line { grid-template-columns: 1fr; gap: 2px; } }
  .log-line .when { font-family: "IBM Plex Mono", monospace; color: var(--ink-faint); }
  .log-line .who { color: var(--brass-strong); font-weight: 600; }
  .log-line .what { color: var(--ink-soft); }

  /* ---------- Future banner ---------- */
  .future {
    border: 1px dashed var(--line-strong);
    border-radius: 6px;
    padding: 22px 24px;
    background: var(--paper-raised);
  }
  .future .eyebrow { color: var(--thread); }
  .future ul { margin: 14px 0 0; padding-left: 18px; }
  .future li { font-size: 14.5px; color: var(--ink-soft); margin-bottom: 8px; }

  /* ---------- closing ---------- */
  .closing {
    max-width: 58ch;
    padding-top: 20px;
  }
  .closing .eyebrow { display: block; margin-bottom: 10px; }
  footer.page-end {
    margin-top: 40px;
    padding-top: 20px;
    border-top: 1px solid var(--line);
    font-size: 12.5px;
    color: var(--ink-faint);
    font-family: "IBM Plex Mono", monospace;
  }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div>
<div class="shell" id="edit-root">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Il Libro dei Ruoli</div>
    <ol>
      <li><a href="#filosofia">La filosofia</a></li>
      <li><a href="#ruoli">Ruoli e gerarchia</a></li>
      <li><a href="#qualifiche">Le qualifiche</a></li>
      <li><a href="#ciclo">Il ciclo di vita di un task</a></li>
      <li><a href="#uscite">Le due uscite oneste</a></li>
      <li><a href="#crediti">Crediti e reputazione</a></li>
      <li><a href="#anonimo">La revisione alla cieca</a></li>
      <li><a href="#log">Tutto resta scritto</a></li>
      <li><a href="#documenti">I documenti: il prossimo passo</a></li>
      <li><a href="#seguito">Cosa viene dopo</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Archivio Urdu — Focolare</span>
      <h1>Come lavora chi lavora nell'Archivio</h1>
      <p class="lede">Una guida a ruoli, qualifiche e flusso di lavoro dietro l'Urdu Archive Manager — scritta per chi userà il sistema, non per chi l'ha costruito. Nessun termine tecnico che non venga prima spiegato.</p>
      <div class="meta">
        <span><b>Parte</b> 1 di 2 — filosofia e funzionamento</span>
        <span><b>Seguirà</b> una guida operativa per ruolo</span>
      </div>
    </div>

    <section id="filosofia">
      <span class="eyebrow">01 — Il perché</span>
      <h2>Un ufficio che non ha più pareti</h2>
      <p class="dek">Il sistema di ruoli e "task" non è un capriccio tecnico: è la traduzione digitale di un modo di lavorare che il team ha già praticato per anni, prima che diventasse impossibile farlo fisicamente.</p>
      <p>Dieci anni fa il lavoro sull'archivio si svolgeva in una stanza sola: un documento passava, fisicamente, da un vassoio all'altro — dattiloscritto, controllato, corretto, timbrato, archiviato. Ogni passaggio era visibile perché tutti erano nella stessa stanza.</p>
      <p>Oggi il team è sparso su più città, e quella stanza non esiste più. Quello che è rimasto — e che questo sistema ricostruisce apposta — è la stessa cosa che rendeva quel modo di lavorare affidabile: <strong>ogni passaggio ha un responsabile, un momento preciso, e lascia una traccia.</strong> I "task" (letteralmente, "compiti") sono i vassoi virtuali; i ruoli sono chi ha il permesso di spostare cosa da un vassoio all'altro.</p>
    </section>

    <section id="ruoli" class="wide">
      <span class="eyebrow">02 — Le persone</span>
      <h2>Ruoli e gerarchia</h2>
      <p class="dek">Quattro livelli, ciascuno costruito sopra il precedente: chi sta più in alto può fare tutto quello che può fare chi sta sotto, più qualcosa in più.</p>

      <div class="ladder">
        <div class="rung">
          <div><span class="role-name">User</span><span class="role-code">consultazione</span></div>
          <ul>
            <li>Consulta e cerca nell'archivio pubblicato</li>
            <li>Segnala un problema o propone una correzione in chat</li>
            <li>Può fare richiesta di "Join the Team"</li>
            <li>Non può modificare né creare nulla</li>
          </ul>
        </div>
        <div class="rung">
          <div><span class="role-name">Operator</span><span class="role-code">esecuzione</span></div>
          <ul>
            <li>Prende in carico i <b>task</b> aperti, secondo le proprie qualifiche</li>
            <li>Crea e corregge documenti nel catalogo</li>
            <li>Può contrassegnare un documento per l'eliminazione (non eliminarlo)</li>
          </ul>
        </div>
        <div class="rung">
          <div><span class="role-name">Coordinator</span><span class="role-code">supervisione</span></div>
          <ul>
            <li>Crea nuovi task e li assegna, o li lascia liberi</li>
            <li>Vede chi è impegnato, chi è in ritardo, e può <b>riprendere</b> un task fermo (con penalità per chi lo teneva)</li>
            <li>Valuta le candidature di chi vuole entrare nel team ("Join the Team")</li>
            <li>Può anche fare da revisore, se serve</li>
          </ul>
        </div>
        <div class="rung top">
          <div><span class="role-name">Admin</span><span class="role-code">autorità finale</span></div>
          <ul>
            <li>Gestisce utenti, ruoli e qualifiche di tutti</li>
            <li>Ha l'<b>ultima parola</b> prima che un lavoro corretto diventi pubblico — può pubblicare o respingere, anche contro il parere del revisore</li>
            <li>Può eliminare in modo definitivo</li>
          </ul>
        </div>
      </div>
      <p class="cumulative-note">Ogni livello include i poteri di quello sotto: un Admin può fare tutto ciò che fa un Operator, ma non il contrario.</p>
    </section>

    <section id="qualifiche">
      <span class="eyebrow">03 — Le competenze</span>
      <h2>Le qualifiche: un asse a parte</h2>
      <p class="dek">Il ruolo dice <em>quanta autorità</em> hai. La qualifica dice <em>in cosa sei bravo</em>. Sono due cose diverse, e si combinano: un Operator può avere una, più di una, o nessuna qualifica.</p>
      <p>Le qualifiche determinano quali task un Operator può anche solo <strong>vedere</strong>: un task di traduzione compare solo a chi è qualificato come Traduttore, un task di revisione solo a chi è qualificato come Revisore. Il resto dei task — proofreading, creazione di contenuti, varie — resta visibile a qualunque Operator.</p>
      <div class="qual-grid">
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Traduttore</div>
          <p>Vede e può prendere i task di traduzione (italiano→urdu, inglese→urdu).</p>
        </div>
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Revisore</div>
          <p>Vede e può prendere i task di revisione; è anche chi giudica il lavoro altrui, in forma anonima (vedi più avanti).</p>
        </div>
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Proof Reader</div>
          <p>Può solo accettare tasks di proofreading, scaricare il file segnalato nel task e ricaricarlo corrretto per la revisione — i task di correzione bozze restano comunque aperti a ogni Operator.</p>
        </div>
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Content Creator</div>
          <p>Competenza registrata per riferimento — i task di creazione contenuti restano comunque aperti a ogni Operator.</p>
        </div>
      </div>
      <p>Coordinator e Admin possono sempre fare da Revisore, anche senza la qualifica esplicita: è previsto per intervenire se la coda di lavori da revisionare si allunga troppo.</p>
    </section>

    <section id="ciclo" class="wide">
      <span class="eyebrow">04 — Il lavoro</span>
      <h2>Il ciclo di vita di un task</h2>
      <p class="dek">Ogni task attraversa una sequenza fissa di stati. Nessuno può saltarne uno: il sistema stesso rifiuta un passaggio che non segue l'ordine previsto.</p>

      <div class="diagram-wrap">
        <figure>
          <svg viewBox="0 0 860 300" role="img" aria-label="Diagramma di flusso: un task passa da Open a Claimed a Submitted; il revisore lo giudica Fail (torna Open come nuovo task, per un altro operatore) oppure Ok/Ok con riserva (Approved); da Approved l'Admin decide Reject (chiude come respinto) o Publish (Published, stato finale).">
            <defs>
              <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                <path d="M0,0 L10,5 L0,10 z" fill="currentColor"></path>
              </marker>
            </defs>
            <g font-family="IBM Plex Mono, monospace" font-size="12" fill="currentColor">
              <!-- main spine nodes -->
              <g>
                <rect x="10" y="40" width="104" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="62" y="65" text-anchor="middle">Open</text>
              </g>
              <g>
                <rect x="184" y="40" width="104" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="236" y="65" text-anchor="middle">Claimed</text>
              </g>
              <g>
                <rect x="358" y="40" width="120" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="418" y="65" text-anchor="middle">Submitted</text>
              </g>
              <g>
                <rect x="548" y="40" width="120" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="608" y="65" text-anchor="middle">Approved</text>
              </g>
              <g>
                <rect x="738" y="40" width="112" height="42" rx="4" stroke="var(--brass)" stroke-width="2" fill="none">
                  <animate attributeName="opacity" values="1" dur="1s" begin="0s" fill="freeze"></animate>
                </rect>
                <text x="794" y="65" text-anchor="middle" fill="var(--brass)" font-weight="700">Published</text>
              </g>

              <!-- spine arrows -->
              <line x1="114" y1="61" x2="180" y2="61" stroke="currentColor" marker-end="url(#arrow)"></line>
              <text x="147" y="52" text-anchor="middle" font-size="10.5">claim</text>

              <line x1="288" y1="61" x2="354" y2="61" stroke="currentColor" marker-end="url(#arrow)"></line>
              <text x="321" y="52" text-anchor="middle" font-size="10.5">submit</text>

              <line x1="478" y1="61" x2="544" y2="61" stroke="currentColor" marker-end="url(#arrow)"></line>
              <text x="511" y="52" text-anchor="middle" font-size="10.5">ok / ok, ma...</text>

              <line x1="668" y1="61" x2="734" y2="61" stroke="var(--brass)" stroke-width="2" marker-end="url(#arrow)"></line>
              <text x="701" y="52" text-anchor="middle" font-size="10.5" fill="var(--brass)" font-weight="600">admin: publish</text>

              <!-- reviewer label above submitted->approved -->
              <text x="418" y="30" text-anchor="middle" font-size="10.5" fill="currentColor" opacity="0.75">giudizio del Revisore</text>
              <text x="608" y="30" text-anchor="middle" font-size="10.5" fill="currentColor" opacity="0.75">decisione dell'Admin</text>

              <!-- fail branch: submitted -> down -> new open task -->
              <path d="M 418 82 C 418 150, 62 150, 62 178" fill="none" stroke="var(--thread)" stroke-width="1.6" marker-end="url(#arrow)"></path>
              <text x="240" y="146" text-anchor="middle" font-size="10.5" fill="var(--thread)">fail — nuovo task, altro operatore</text>
              <rect x="10" y="180" width="104" height="42" rx="4" fill="none" stroke="var(--thread)" stroke-dasharray="3 3"></rect>
              <text x="62" y="205" text-anchor="middle" fill="var(--thread)">Rejected</text>

              <!-- admin reject branch: approved -> down -> rejected (separate box) -->
              <path d="M 608 82 C 608 150, 700 150, 700 178" fill="none" stroke="var(--thread)" stroke-width="1.6" marker-end="url(#arrow)"></path>
              <text x="654" y="146" text-anchor="middle" font-size="10.5" fill="var(--thread)">admin: reject</text>
              <rect x="648" y="180" width="112" height="42" rx="4" fill="none" stroke="var(--thread)" stroke-dasharray="3 3"></rect>
              <text x="704" y="205" text-anchor="middle" fill="var(--thread)">Rejected</text>

              <text x="62" y="240" text-anchor="middle" font-size="10" opacity="0.7">stato finale</text>
              <text x="704" y="240" text-anchor="middle" font-size="10" opacity="0.7">stato finale — pulsante "ricrea task" a scelta dell'Admin</text>
            </g>
          </svg>
          <figcaption>Il percorso di un task dalla creazione alla pubblicazione. Il ramo rosso tratteggiato è dove il lavoro si ferma: un fail del Revisore genera <em>subito e da solo</em> un nuovo task aperto ad altri; un reject dell'Admin no — lascia a lui la scelta se e quando far ripartire il lavoro.</figcaption>
        </figure>
      </div>

      <p>Due dettagli non ovvi, ma decisivi:</p>
      <p><strong>Il giudizio del Revisore resta sospeso.</strong> Quando il Revisore dice "ok" o "ok, ma con riserva", il task passa in coda per l'Admin — ma i crediti e il punteggio dell'operatore non cambiano ancora. È l'Admin, con la sua decisione finale (pubblica o respinge), a rendere effettivo quel giudizio. In questo modo l'Admin ha davvero l'ultima parola su tutto ciò che diventa pubblico.</p>
      <p><strong>Un fail del Revisore e un reject dell'Admin non sono uguali.</strong> Se il Revisore giudica il lavoro insufficiente (Fail) e il task deve essere quindi rifatto, il sistema crea <em>da solo</em> un nuovo task aperto — a chiunque tranne chi aveva fatto quel tentativo. Se invece è l'Admin a fermare un lavoro che il Revisore aveva approvato, non succede nulla in automatico: è una decisione più rara, e sta a lui scegliere se e quando far ripartire il lavoro su quel documento.</p>
    </section>

    <section id="uscite">
      <span class="eyebrow">05 — Onestà</span>
      <h2>Le due uscite di un task claimed</h2>
      <p class="dek">Un task preso in carico può tornare libero in due modi molto diversi — e il sistema li tratta in modo diverso apposta.</p>
      <div class="exit-grid">
        <div class="exit-card calm">
          <span class="label">Give up — rinuncia</span>
          <h3>L'operatore ammette di non farcela</h3>
          <p>Un atto onesto, non una colpa. Chi rinuncia scrive una riga sul perché; il task torna libero; <strong>nessuna penalità</strong>. Restare bloccati su un lavoro che non si riesce a fare bene sarebbe peggio.</p>
        </div>
        <div class="exit-card warn">
          <span class="label">Reclaim — ripresa forzata</span>
          <h3>Il Coordinator interviene</h3>
          <p>Per un ritardo senza risposta, o un comportamento scorretto. Il Coordinator scrive il motivo; il task torna libero; <strong>l'operatore riceve una penalità</strong> sul punteggio di reputazione.</p>
        </div>
      </div>
    </section>

    <section id="crediti">
      <span class="eyebrow">06 — Il valore del lavoro</span>
      <h2>Crediti e reputazione</h2>
      <p class="dek">Due numeri diversi, per due domande diverse: <em>quanto hai lavorato</em>, e <em>quanto ci si può fidare di te</em>.</p>
      <dl>
        <div class="def-row">
          <dt>Crediti</dt>
          <dd>Si accumulano — non scendono mai da soli. Ogni task ha un valore in crediti stabilito alla creazione; l'operatore li riceve solo quando il lavoro viene pubblicato con successo. Serviranno come base per una futura forma di riconoscimento del lavoro svolto.</dd>
        </div>
        <div class="def-row">
          <dt>Reputazione</dt>
          <dd>
            Un punteggio da 0 a 100 che sale con il lavoro fatto bene e scende per lavoro impreciso, ritardi, o un task ripreso forzatamente. Parte da un valore neutro (50), non da zero — nessuno comincia "in debito".
            <div class="meter" aria-hidden="true">
              <span class="val">0</span>
              <span class="track"><span class="fill"></span></span>
              <span class="val">100</span>
            </div>
          </dd>
        </div>
      </dl>
      <p>Un giudizio "ok, ma con riserva" da parte del Revisore è un caso particolare: il lavoro viene comunque accettato e pagato in crediti, ma la reputazione scende leggermente lo stesso — per tenere alta l'attenzione sulla qualità, anche quando il risultato finale va bene.</p>
      <div class="exit-card warn" style="margin-top:22px;">
        <span class="label">Se la reputazione scende molto</span>
        <h3>Un avviso per il team, non un blocco automatico</h3>
        <p>Chi lavora nell'archivio lo fa da volontario: un blocco automatico e impersonale sarebbe la risposta sbagliata. Sotto una soglia bassa, il sistema si limita a segnalare la persona in rosso a Coordinator e Admin — nella panoramica del team — così possano accorgersene ed intervenire con una conversazione, prima che la situazione peggiori. Qualunque decisione più concreta resta sempre una scelta umana.</p>
      </div>
    </section>

    <section id="anonimo">
      <span class="eyebrow">07 — Imparzialità</span>
      <h2>La revisione alla cieca</h2>
      <p class="dek">Chi giudica un lavoro non sa chi l'ha fatto — nemmeno se lo volesse scoprire dai dati che riceve.</p>
      <p>Quando un Revisore apre la coda dei lavori da valutare, vede il contenuto del task — cosa andava fatto, su quale documento, quante pagine — ma <strong>non il nome di chi l'ha svolto</strong>. Non è un'informazione nascosta nell'interfaccia: semplicemente non viene mai inviata al suo browser. Un Revisore non può nemmeno valutare un proprio lavoro, se per caso lo avesse svolto lui stesso.</p>
      <p>Lo scopo è giudicare <em>il lavoro</em>, non la persona: nessun favore a un amico, nessun pregiudizio verso qualcun altro.</p>
    </section>

    <section id="log">
      <span class="eyebrow">08 — Memoria</span>
      <h2>Tutto resta scritto</h2>
      <p class="dek">Ogni passaggio che cambia i crediti o la reputazione di qualcuno lascia una riga permanente: chi, quando, perché.</p>
      <div class="log-strip">
        <div class="log-line"><span class="when">31 ago</span><span class="who">Revisore</span><span class="what">giudizio "ok" registrato, in attesa della decisione dell'Admin</span></div>
        <div class="log-line"><span class="when">31 ago</span><span class="who">Admin</span><span class="what">pubblicato — crediti e reputazione assegnati</span></div>
        <div class="log-line"><span class="when">30 ago</span><span class="who">Coordinator</span><span class="what">task ripreso per ritardo — penalità applicata, motivo registrato</span></div>
        <div class="log-line"><span class="when">29 ago</span><span class="who">Operatore</span><span class="what">rinuncia al task — nessuna penalità, motivo registrato</span></div>
      </div>
      <p>Questa non è una funzione in più: è la stessa logica del vecchio cartellino firmato ad ogni passaggio, semplicemente digitale — e per questo impossibile da perdere o falsificare.</p>
    </section>

    <section id="documenti" class="wide">
      <span class="eyebrow">09 — Il file, non solo il lavoro</span>
      <h2>Come si corregge davvero un documento</h2>
      <p class="dek">Il sistema di task e revisione governa <em>il lavoro</em>. Questa sezione racconta come la stessa logica si applica <em>al file stesso</em> di un documento da correggere — attivo e in uso.</p>
      <p>Quando un task è collegato a un documento, l'operatore scarica l'originale direttamente dalla scheda del task — il file InPage vero e proprio quando disponibile, altrimenti il PDF già in archivio — lo corregge, e lo ricarica. Il file corretto entra in archivio come una nuova versione "sorella" di quella originale, ma resta <strong>invisibile a tutti tranne all'operatore stesso e a Coordinator/Admin</strong>, finché non viene approvato — esattamente lo stesso principio di riservatezza già visto per i task.</p>
      <p>L'approvazione avviene in <strong>due passaggi separati</strong>, non uno solo. Primo: quando l'Admin chiude il task (dopo l'ok del Revisore), i crediti e la reputazione vengono assegnati subito — non c'è bisogno di aspettare che il file sia del tutto pronto. Secondo, con calma: l'Admin prepara il PDF finale e il file InPage definitivo, li carica, e solo a quel punto rende il documento davvero pubblico.</p>
      <div class="exit-card calm">
        <span class="label">Una sorella, non una sostituta</span>
        <h3>La versione vecchia non sparisce</h3>
        <p>Quando la nuova versione diventa pubblica, quella precedente <strong>resta visibile anche lei</strong> — non viene nascosta né cancellata. Sono due versioni "sorelle" dello stesso documento originale, esattamente come già succede per una traduzione in un'altra lingua o un formato diverso: cambia solo quale delle due viene mostrata per prima nelle ricerche.</p>
      </div>
    </section>

    <section id="seguito" class="closing">
      <span class="eyebrow">10 — Cosa leggere adesso</span>
      <h2>Una guida per ogni ruolo</h2>
      <p>Questo documento spiega la logica generale. Per il funzionamento pratico, giorno per giorno, c'è una guida operativa dedicata a ciascun ruolo — User, Operator, Coordinator, Admin — più un riferimento tecnico per chi sviluppa e mantiene l'applicazione.</p>
      <footer class="page-end">Movimento dei Focolari — Archivio Urdu · Documento 1 di 6</footer>
    </section>
  </main>
</div>

</body>
</html>
$q_roles_it$, 0, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('user_it', 'it', 'user', 'Guida Operativa — User', $q_user_it$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Guida per Consultare l'Archivio</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  main { max-width: 680px; margin: 0 auto; padding: 56px 24px 100px; }
  .cover { margin-bottom: 60px; }
  .cover .eyebrow { display: block; margin-bottom: 16px; }
  .cover h1 { font-size: clamp(30px,6vw,42px); line-height: 1.1; }
  .cover .lede { margin-top: 18px; font-size: 17px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 20px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { margin-bottom: 50px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(21px,3.4vw,25px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14.5px; margin: 8px 0 20px; }
  p { margin: 0 0 14px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 10px 0 10px 38px; border-top: 1px solid var(--line); font-size: 14.5px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 10px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 16px 18px; margin: 14px 0; }
  .card h3 { font-size: 15px; margin-bottom: 6px; }
  .card p { font-size: 13.5px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 14px 16px; margin: 14px 0; font-size: 13.5px; }
  .no-card b { color: var(--thread); }
  footer.page-end { margin-top: 50px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&amp;family=Archivo:wght@400;500;600;700&amp;family=IBM+Plex+Mono:wght@500;600&amp;display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div><main id="edit-root" contenteditable="false" spellcheck="false">
  <div class="cover">
    <span class="eyebrow">Archivio Urdu — Guida Operativa</span>
    <h1>Guida per chi consulta l'archivio</h1>
    <p class="lede">Tutto quello che puoi fare come User: cercare, leggere, scaricare — e come contribuire senza dover scrivere una riga di codice.</p>
    <div class="role-badge"><span class="dot"></span>Ruolo: User</div>
  </div>

  <section>
    <span class="eyebrow">01</span>
    <h2>Cosa puoi fare</h2>
    <p>Il tuo accesso è di sola consultazione: puoi cercare, leggere e scaricare qualunque documento già pubblicato nell'archivio, ma non puoi crearne o modificarne. Non è una limitazione tecnica arbitraria — è pensata così perché il catalogo resti affidabile: solo chi è autorizzato (Operator e superiori) può modificarlo direttamente.</p>
    <ul class="step-list">
      <li><b>Dashboard</b> — cerca per titolo, autore, categoria, data; apri qualunque scheda documento per leggerne i dettagli.</li>
      <li><b>Print Reports / Hayat Index</b> — le stesse informazioni, organizzate per la stampa o per la rivista Hayat.</li>
      <li><b>Download</b> — ogni documento pubblicato ha un file scaricabile direttamente dalla sua scheda.</li>
    </ul>
  </section>

  <section>
    <span class="eyebrow">02</span>
    <h2>Segnalare un problema</h2>
    <p class="dek">Hai trovato un errore nel testo di un documento, un errore nella pagina web, un file che non si scarica? Dillo nella tab <b>Chat</b>.</p>
    <ul class="step-list">
      <li>Vai sulla tab <b>Chat</b>, scegli il tipo di segnalazione (Revisione, Errore di download, Bug, Suggerimento), scrivi il messaggio — se riguarda un documento specifico, indicane il numero.</li>
      <li>Il tuo messaggio arriva a Coordinator e Admin, che possono risponderti direttamente nella stessa conversazione.</li>
      <li>Se la segnalazione richiede un intervento vero e proprio, chi la riceve può trasformarla in un <b>task</b> per la squadra degli Operators e seguirà il processo di correzione..</li>
    </ul>
    <div class="card">
      <h3>Riceverai una notifica</h3>
      <p>Quando arriva una risposta al tuo messaggio, un avviso comparirà la prossima volta che accedi — non serve controllare a mano la chat ogni giorno.</p>
    </div>
  </section>

  <section>
    <span class="eyebrow">03</span>
    <h2>Candidarsi per entrare nel team</h2>
    <p class="dek">Vuoi passare da consultare l'archivio a collaborare con il nostro Team? Si comincia da "Join the Team".</p>
    <ul class="step-list">
      <li>Vai sulla tab <b>Join the Team</b> (visibile solo a chi ha ancora il ruolo User) e compila il modulo di candidatura.</li>
      <li>La tua richiesta verrà esaminata e il Team si metterà in contatto con te.</li>
      <li>Se la tua richiesta verrà approvata, sarai ammesso al ruolo <b>Operator,</b>&nbsp; e da quel momento vedrai comparire nuove tab (Tasks, Edit Records, e altre) e questa guida non ti riguarderà più: la prossima è quella per Operator.</li>
    </ul>
    <div class="no-card"><b>Nota</b> —Per l'approvazione di una candidatura servono diverse approvazioni. Non è una svista, è una scelta esplicita per prendere le decisioni insieme.</div>
  </section>

  <footer class="page-end">Movimento dei Focolari — Archivio Urdu · Guida Operativa · User</footer>
</body>
</html>
$q_user_it$, 10, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('operator_it', 'it', 'operator', 'Guida Operativa — Operator', $q_operator_it$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Guida Operator</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  .shell { display: grid; grid-template-columns: 220px minmax(0,1fr); max-width: 1080px; margin: 0 auto; }
  @media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
  nav.toc { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; padding: 40px 18px 40px 24px; border-right: 1px solid var(--line); }
  @media (max-width: 820px) { nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line); padding: 16px 20px; overflow-x: auto; white-space: nowrap; } }
  .toc-brand { font-family: "Fraunces",serif; font-size: 14px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono",monospace; }
  @media (max-width: 820px) { .toc-brand { display: inline-flex; margin: 0 20px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 820px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a { display: flex; gap: 7px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px; color: var(--ink-soft); text-decoration: none; font-size: 12.5px; }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before { content: counter(sec,decimal-leading-zero); font-family: "IBM Plex Mono",monospace; font-size: 10px; color: var(--ink-faint); }
  @media (max-width: 820px) { nav.toc a { white-space: nowrap; margin: 0; } }
  main { padding: 52px 40px 100px; min-width: 0; }
  @media (max-width: 820px) { main { padding: 36px 18px 90px; } }
  .cover { max-width: 620px; margin-bottom: 56px; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(28px,5vw,40px); line-height: 1.1; }
  .cover .lede { margin-top: 16px; font-size: 16.5px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 18px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { max-width: 640px; margin-bottom: 48px; scroll-margin-top: 24px; }
  section.wide { max-width: 780px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(20px,3.2vw,24px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14px; margin: 8px 0 18px; }
  p { margin: 0 0 13px; font-size: 15px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 9px 0 9px 34px; border-top: 1px solid var(--line); font-size: 14px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 9px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 15px 17px; margin: 12px 0; }
  .card h3 { font-size: 14.5px; margin-bottom: 5px; }
  .card p { font-size: 13px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 13px 15px; margin: 12px 0; font-size: 13px; }
  .no-card b { color: var(--thread); }
  .qual-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 10px 0 4px; }
  @media (max-width: 560px) { .qual-grid { grid-template-columns: 1fr; } }
  .qual-card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 4px; padding: 14px 16px; }
  .qual-card .qname { font-family: "Fraunces",serif; font-weight: 600; font-size: 14.5px; display: flex; align-items: center; gap: 7px; }
  .qual-card .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); flex: none; }
  .qual-card p { font-size: 12.5px; color: var(--ink-soft); margin-top: 6px; }
  .meter { display: flex; align-items: center; gap: 10px; margin: 10px 0; }
  .meter .track { flex: 1; max-width: 200px; height: 7px; border-radius: 4px; background: var(--line); overflow: hidden; }
  .meter .fill { height: 100%; width: 50%; border-radius: 4px; background: linear-gradient(90deg, var(--thread), var(--brass)); }
  .meter .val { font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  footer.page-end { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&amp;family=Archivo:wght@400;500;600;700&amp;family=IBM+Plex+Mono:wght@500;600&amp;display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div><div class="shell" id="edit-root" contenteditable="false" spellcheck="false">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Guida Operator</div>
    <ol>
      <li><a href="#panoramica">Cosa puoi fare</a></li>
      <li><a href="#claim">Prendere un task</a></li>
      <li><a href="#correzione">Correggere un documento</a></li>
      <li><a href="#uscite">Rinuncia o rinvio</a></li>
      <li><a href="#qualifiche">Le tue qualifiche</a></li>
      <li><a href="#revisore">Se sei Revisore</a></li>
      <li><a href="#punteggio">Il tuo punteggio</a></li>
      <li><a href="#catalogo">Modificare il catalogo</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Archivio Urdu — Guida Operativa</span>
      <h1>Guida per chi lavora sui task</h1>
      <p class="lede">Come prendere un task, correggere un documento passo per passo, e acquisire crediti.</p>
      <div class="role-badge"><span class="dot"></span>Ruolo: Operator</div>
    </div>

    <section id="panoramica">
      <span class="eyebrow">01</span>
      <h2>Cosa puoi fare in più rispetto a un User</h2>
      <p>Puoi creare e modificare documenti nel catalogo direttamente, e soprattutto puoi prendere in carico i <b>task</b> della bacheca, il modo normale in cui il lavoro viene distribuito nel team. Nella tab <b>Tasks</b> trovi tutto: i task liberi da prendere, i tuoi task in corso, e lo storico di quelli completati.</p>
    </section>

    <section id="claim">
      <span class="eyebrow">02</span>
      <h2>Prendere un task</h2>
      <ul class="step-list">
        <li>In "Open tasks" vedi solo i task che puoi effettivamente prendere — quelli di traduzione o revisione compaiono solo se hai la qualifica giusta (vedi più sotto).</li>
        <li>Scegli una <b>data di consegna realistica (deadline)</b>&nbsp;— una volta preso il task, quella data resta fissa: non potrai più modificarla in seguito.</li>
        <li>Premi "Claim this task". Da quel momento il task compare in "My tasks".</li>
      </ul>
      <div class="no-card"><b>Prendine solo quanti riesci a portare a termine</b> — un task lasciato scadere senza risposta può essere ripreso forzatamente da un Coordinator, con una penalità sulle tue buone pratiche.</div>
    </section>

    <section id="correzione" class="wide">
      <span class="eyebrow">03</span>
      <h2>Correggere un documento</h2>
      <p class="dek">Se il task è collegato a un documento specifico, il lavoro segue questi passaggi, tutti dalla stessa scheda del task.</p>
      <ul class="step-list">
        <li><b>Download original file</b> — scarica il file da correggere: il vero file InPage quando è disponibile, altrimenti il PDF già in archivio.</li>
        <li>Correggi il file <b>fuori dall'app</b>, con i tuoi strumenti abituali (InPage, Word...).</li>
        <li><b>Upload corrected file</b> — ricarica il file corretto. Finché non lo fai, il pulsante "Submit for review" resta disattivato: non puoi inviare in revisione un lavoro senza aver caricato nulla.</li>
        <li>Puoi ricaricare più volte prima di inviare — ogni caricamento sostituisce il precedente, non si accumulano copie.</li>
        <li><b>Submit for review</b> — una volta inviato, il task passa al Revisore e non potrai più modificarlo.</li>
      </ul>
      <div class="card">
        <h3>Cosa vede chi ti revisiona</h3>
        <p>Il file che hai caricato resta invisibile a tutti tranne a te e a chi è incaricato di revisionarlo e approvarlo. Anche chi lo revisiona <b>non sa che sei stato tu</b> a&nbsp; eseguire quel task (vedi "Il Libro dei Ruoli" per il perché).</p>
      </div>
    </section>

    <section id="uscite">
      <span class="eyebrow">04</span>
      <h2>Se non riesci a portarlo a termine</h2>
      <p class="dek">C'è un modo onesto per uscire da un task preso. Usalo prima che diventi un problema, non dopo.</p>
      <ul class="step-list">
        <li><b>Give up this task</b> — disponibile su ogni task che hai in corso. Scrivi una riga sul motivo, e il task torna libero per qualcun altro.</li>
        <li>Questo <b>non ha alcuna penalità</b>: ammettere di non riuscire a farcela è un atto onesto, non un errore.</li>
        <li>È molto diverso dal farsi riprendere un task per non aver rispettato i tempi — quello sì comporta una penalità, perché la differenza sta nell'aver comunicato per tempo.</li>
      </ul>
    </section>

    <section id="qualifiche" class="wide">
      <span class="eyebrow">05</span>
      <h2>Le tue qualifiche</h2>
      <p class="dek">Un Admin te le assegna in base alle tue competenze — determinano quali task puoi vedere.</p>
      <div class="qual-grid">
        <div class="qual-card"><div class="qname"><span class="dot"></span>Traduttore</div><p>Vedi e puoi prendere i task di traduzione (italiano→urdu, inglese→urdu).</p></div>
        <div class="qual-card"><div class="qname"><span class="dot"></span>Revisore</div><p>Vedi e puoi prendere i task di revisione, e accedi alla coda di revisione anonima (vedi sotto).</p></div>
        <div class="qual-card"><div class="qname"><span class="dot"></span>Proof Reader</div><p>Competenza registrata per riferimento — i task di correzione bozze restano comunque aperti a tutti.</p></div>
        <div class="qual-card"><div class="qname"><span class="dot"></span>Content Creator</div><p>Competenza registrata per riferimento — i task di creazione contenuti restano comunque aperti a tutti.</p></div>
      </div>
      <p>Puoi averne più di una contemporaneamente. Se non ne hai nessuna, vedi comunque tutti i task che non richiedono una qualifica specifica.</p>
    </section>

    <section id="revisore" class="wide">
      <span class="eyebrow">06</span>
      <h2>Se sei Revisore</h2>
      <p class="dek">Nella tab Tasks compare in più un pannello "Review queue" — visibile solo a chi ha questa qualifica.</p>
      <ul class="step-list">
        <li>Vedi i task inviati per revisione: cosa andava fatto, su quale documento, quante pagine — <b>mai chi l'ha svolto</b>, nemmeno tu potrai mai vedere un tuo stesso task lì (il sistema lo esclude in automatico).</li>
        <li>Se il task è collegato a un documento, un pulsante "Open corrected file" ti fa aprire il file corretto per controllarlo.</li>
        <li>Dai il tuo giudizio: <b>OK</b> (lavoro fatto bene), <b>OK, but...</b> (accettabile ma impreciso — scrivi perché), oppure <b>Fail</b> (da rifare — il sistema crea da solo un nuovo task per qualcun altro).</li>
        <li>Le note che scrivi arrivano all'operatore — sii specifico e costruttivo, le leggerà per capire cosa migliorare.</li>
      </ul>
      <div class="no-card"><b>Il tuo giudizio non chiude subito il task</b> — passa all'Admin, che decide se pubblicare o respingere. Il punteggio dell'operatore cambia solo a quel punto, non quando dai il tuo verdetto.</div>
    </section>

    <section id="punteggio">
      <span class="eyebrow">07</span>
      <h2>Il tuo punteggio</h2>
      <p class="dek">In alto, accanto alla tua email, trovi due numeri.</p>
      <p><b>Crediti</b> — si accumulano ogni volta che un tuo task viene pubblicato con successo. Non scendono mai da soli.</p>
      <p><b>Buone Pratiche</b> — un punteggio da 0 a 100 che parte da 50 (un premio alla buona volontà, anche prima di aver fatto qualunque lavoro) e si muove in base a come lavori.</p>
      <div class="meter" aria-hidden="true"><span class="val">0</span><span class="track"><span class="fill"></span></span><span class="val">100</span></div>
      <p>Premi il pulsante <b>"Good practices"</b> in alto in qualunque momento per rivedere i consigli su come lavorare bene e i comportamenti da evitare.</p>
    </section>

    <section id="catalogo">
      <span class="eyebrow">08</span>
      <h2>Modificare il catalogo direttamente</h2>
      <p>Oltre ai task, puoi anche creare o modificare documenti direttamente dalla Dashboard o da "Edit Records" — utile per correzioni rapide di metadati (titolo, categoria, autore...) che non richiedono l'intero flusso di revisione. Per una correzione sostanziale del testo di un documento, però, il percorso corretto resta sempre quello del task: garantisce che qualcun altro controlli il lavoro prima che diventi pubblico.</p>
    </section>

    <footer class="page-end">Movimento dei Focolari — Archivio Urdu · Guida Operativa · Operator</footer>
  </main>
</body>
</html>
$q_operator_it$, 20, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('coordinator_it', 'it', 'coordinator', 'Guida Operativa — Coordinator', $q_coordinator_it$
<!doctype html>
<html>
<body><div id="page-static"><title>Guida Coordinator</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  .shell { display: grid; grid-template-columns: 220px minmax(0,1fr); max-width: 1080px; margin: 0 auto; }
  @media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
  nav.toc { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; padding: 40px 18px 40px 24px; border-right: 1px solid var(--line); }
  @media (max-width: 820px) { nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line); padding: 16px 20px; overflow-x: auto; white-space: nowrap; } }
  .toc-brand { font-family: "Fraunces",serif; font-size: 14px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono",monospace; }
  @media (max-width: 820px) { .toc-brand { display: inline-flex; margin: 0 20px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 820px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a { display: flex; gap: 7px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px; color: var(--ink-soft); text-decoration: none; font-size: 12.5px; }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before { content: counter(sec,decimal-leading-zero); font-family: "IBM Plex Mono",monospace; font-size: 10px; color: var(--ink-faint); }
  @media (max-width: 820px) { nav.toc a { white-space: nowrap; margin: 0; } }
  main { padding: 52px 40px 100px; min-width: 0; }
  @media (max-width: 820px) { main { padding: 36px 18px 90px; } }
  .cover { max-width: 620px; margin-bottom: 56px; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(28px,5vw,40px); line-height: 1.1; }
  .cover .lede { margin-top: 16px; font-size: 16.5px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 18px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { max-width: 640px; margin-bottom: 48px; scroll-margin-top: 24px; }
  section.wide { max-width: 780px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(20px,3.2vw,24px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14px; margin: 8px 0 18px; }
  p { margin: 0 0 13px; font-size: 15px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 9px 0 9px 34px; border-top: 1px solid var(--line); font-size: 14px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 9px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 15px 17px; margin: 12px 0; }
  .card h3 { font-size: 14.5px; margin-bottom: 5px; }
  .card p { font-size: 13px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 13px 15px; margin: 12px 0; font-size: 13px; }
  .no-card b { color: var(--thread); }
  footer.page-end { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div>
<div class="shell" id="edit-root">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Guida Coordinator</div>
    <ol>
      <li><a href="#panoramica">Cosa puoi fare in più</a></li>
      <li><a href="#creare">Creare un task</a></li>
      <li><a href="#squadra">Gestire la squadra</a></li>
      <li><a href="#messaggi">I messaggi degli utenti</a></li>
      <li><a href="#candidature">Le candidature</a></li>
      <li><a href="#revisore">Fare anche da Revisore</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Archivio Urdu — Guida Operativa</span>
      <h1>Guida per chi coordina la squadra</h1>
      <p class="lede">Come creare e assegnare i task, tenere d'occhio chi è impegnato, e gestire le richieste che arrivano dal team.</p>
      <div class="role-badge"><span class="dot"></span>Ruolo: Coordinator</div>
    </div>

    <section id="panoramica">
      <span class="eyebrow">01</span>
      <h2>Cosa puoi fare in più rispetto a un Operator</h2>
      <p>Un Coordinator eredita tutti i poteri di un Operator (task, correzioni, catalogo) e aggiunge la responsabilità di <strong>organizzare il lavoro della squadra</strong>: decidere quali task creare, chi li fa, intervenire se qualcosa si blocca, e fare da primo filtro sulle candidature di chi vuole entrare nel team.</p>
    </section>

    <section id="creare" class="wide">
      <span class="eyebrow">02</span>
      <h2>Creare un task</h2>
      <p class="dek">Dalla tab Tasks, in alto trovi il modulo "New task" — visibile solo a Coordinator e Admin.</p>
      <ul class="step-list">
        <li>Scrivi un <b>titolo</b> e, se serve, una <b>descrizione</b> più dettagliata di cosa va fatto.</li>
        <li>Scegli una <b>categoria</b> (Traduzione, Revisione, Proof Reading, Creazione contenuti, Altro) — le categorie di Traduzione e Revisione mostrano il task solo a chi ha la qualifica giusta; le altre restano aperte a chiunque.</li>
        <li>Se il task riguarda un documento specifico, indicane l'<b>ID</b> — il numero di pagine si compila da solo se il documento ce l'ha già registrato.</li>
        <li>Imposta i <b>crediti</b> — quanto varrà questo task una volta completato con successo (per ora un numero deciso da te, non calcolato automaticamente).</li>
        <li>Puoi <b>assegnarlo direttamente</b> a qualcuno (il menu mostra solo chi ha la qualifica compatibile con la categoria scelta), oppure lasciarlo libero perché chiunque lo prenda.</li>
      </ul>
      <div class="card"><h3>Da una segnalazione in chat</h3><p>Se un utente ha segnalato un problema, apri Messages e premi "Create task" sulla sua riga: titolo, descrizione e documento si compilano da soli a partire dalla segnalazione.</p></div>
    </section>

    <section id="squadra" class="wide">
      <span class="eyebrow">03</span>
      <h2>Gestire la squadra</h2>
      <p class="dek">Il pannello "Team overview" mostra i task presi da tutti, non solo i tuoi.</p>
      <ul class="step-list">
        <li>Vedi chi ha preso cosa, con che scadenza, e se è <b>in ritardo</b> (etichetta rossa).</li>
        <li>Un operatore con <b>reputazione bassa</b> viene segnalato in rosso — è un avviso per te, non un blocco automatico: significa "vale la pena parlarne", non "vietato".</li>
        <li><b>Reassign</b> — sposta un task da un operatore a un altro (solo tra chi ha la qualifica giusta).</li>
        <li><b>Reclaim (torna a open)</b> — riprendi forzatamente un task fermo da troppo tempo o gestito male. Ti verrà chiesto il motivo: viene registrato, e comporta una penalità sulla reputazione di chi lo teneva.</li>
      </ul>
      <div class="no-card"><b>Diverso da una rinuncia</b> — se è l'operatore stesso a rinunciare onestamente (pulsante "Give up" dal suo lato), non c'è alcuna penalità. Il reclaim forzato da parte tua è per i casi in cui non c'è stata comunicazione.</div>
    </section>

    <section id="messaggi">
      <span class="eyebrow">04</span>
      <h2>I messaggi degli utenti</h2>
      <p>La tab Messages raccoglie le segnalazioni di tutti gli utenti (visibile a Coordinator e Admin, non solo Admin). Puoi rispondere direttamente, archiviare ("Dismiss") quelle risolte, o trasformarne una in task con un clic, come visto sopra.</p>
    </section>

    <section id="candidature">
      <span class="eyebrow">05</span>
      <h2>Le candidature "Join the Team"</h2>
      <p>Quando un User si candida per entrare nel team, la sua richiesta arriva prima a te. Puoi <b>consigliarla</b> o <b>respingerla</b> — ma non puoi approvarla definitivamente da solo: serve sempre la conferma di un Admin, apposta perché nessuno possa promuovere un amico senza un secondo controllo.</p>
    </section>

    <section id="revisore">
      <span class="eyebrow">06</span>
      <h2>Puoi fare anche da Revisore</h2>
      <p>Anche senza la qualifica specifica, un Coordinator può aprire la "Review queue" e dare un giudizio sui task in attesa — utile se la coda si allunga troppo. Vale la stessa regola di anonimato di sempre: nemmeno tu vedi chi ha svolto il lavoro che stai valutando, e non puoi giudicare un tuo stesso task.</p>
    </section>

    <footer class="page-end">Movimento dei Focolari — Archivio Urdu · Guida Operativa · Coordinator</footer>
  </main>
</div>

</body>
</html>
$q_coordinator_it$, 30, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('admin_it', 'it', 'admin', 'Guida Operativa — Admin', $q_admin_it$
<!doctype html>
<html>
<body><div id="page-static"><title>Guida Admin</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  .shell { display: grid; grid-template-columns: 220px minmax(0,1fr); max-width: 1080px; margin: 0 auto; }
  @media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
  nav.toc { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; padding: 40px 18px 40px 24px; border-right: 1px solid var(--line); }
  @media (max-width: 820px) { nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line); padding: 16px 20px; overflow-x: auto; white-space: nowrap; } }
  .toc-brand { font-family: "Fraunces",serif; font-size: 14px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono",monospace; }
  @media (max-width: 820px) { .toc-brand { display: inline-flex; margin: 0 20px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 820px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a { display: flex; gap: 7px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px; color: var(--ink-soft); text-decoration: none; font-size: 12.5px; }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before { content: counter(sec,decimal-leading-zero); font-family: "IBM Plex Mono",monospace; font-size: 10px; color: var(--ink-faint); }
  @media (max-width: 820px) { nav.toc a { white-space: nowrap; margin: 0; } }
  main { padding: 52px 40px 100px; min-width: 0; }
  @media (max-width: 820px) { main { padding: 36px 18px 90px; } }
  .cover { max-width: 620px; margin-bottom: 56px; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(28px,5vw,40px); line-height: 1.1; }
  .cover .lede { margin-top: 16px; font-size: 16.5px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 18px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { max-width: 640px; margin-bottom: 48px; scroll-margin-top: 24px; }
  section.wide { max-width: 780px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(20px,3.2vw,24px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14px; margin: 8px 0 18px; }
  p { margin: 0 0 13px; font-size: 15px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 9px 0 9px 34px; border-top: 1px solid var(--line); font-size: 14px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 9px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 15px 17px; margin: 12px 0; }
  .card h3 { font-size: 14.5px; margin-bottom: 5px; }
  .card p { font-size: 13px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 13px 15px; margin: 12px 0; font-size: 13px; }
  .no-card b { color: var(--thread); }
  footer.page-end { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div>
<div class="shell" id="edit-root">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Guida Admin</div>
    <ol>
      <li><a href="#panoramica">Cosa puoi fare in più</a></li>
      <li><a href="#utenti">Utenti, ruoli, qualifiche</a></li>
      <li><a href="#opzioni">Le liste dell'app</a></li>
      <li><a href="#decisione">La decisione finale sui task</a></li>
      <li><a href="#finalizzare">Pubblicare un documento</a></li>
      <li><a href="#candidature">Approvazione candidature</a></li>
      <li><a href="#annunci">Annunci ed eliminazioni</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Archivio Urdu — Guida Operativa</span>
      <h1>Guida per chi amministra il sistema</h1>
      <p class="lede">L'ultima parola su tutto ciò che diventa pubblico — utenti, task e documenti.</p>
      <div class="role-badge"><span class="dot"></span>Ruolo: Admin</div>
    </div>

    <section id="panoramica">
      <span class="eyebrow">01</span>
      <h2>Cosa puoi fare in più rispetto a un Coordinator</h2>
      <p>Un Admin eredita tutti i poteri di Coordinator e Operator, e aggiunge quello che nessun altro ruolo ha: la <strong>decisione finale</strong> prima che un lavoro o una nuova versione di un documento diventi davvero pubblica, oltre alla gestione di utenti, ruoli, qualifiche, liste dell'app, ed eliminazioni definitive.</p>
    </section>

    <section id="utenti" class="wide">
      <span class="eyebrow">02</span>
      <h2>Utenti, ruoli, qualifiche</h2>
      <p class="dek">Nella tab Users trovi tutto il team in un'unica tabella.</p>
      <ul class="step-list">
        <li>Cambia il <b>ruolo</b> di chiunque dal menu a tendina sulla sua riga (User / Operator / Coordinator / Admin).</li>
        <li>Solo per gli Operator, assegna le <b>qualifiche</b> (Traduttore, Revisore, Proof Reader, Content Creator) con le caselle — una persona può averne più di una.</li>
        <li>Vedi i <b>crediti</b> e la <b>reputazione</b> accumulati da ciascun Operator — un numero in rosso significa reputazione sotto soglia, un segnale per intervenire, non un blocco.</li>
        <li><b>Remove access</b> toglie il ruolo (la persona perde l'accesso all'app, ma il suo account di accesso non viene cancellato).</li>
      </ul>
    </section>

    <section id="opzioni">
      <span class="eyebrow">03</span>
      <h2>Le liste dell'app</h2>
      <p>La tab Options gestisce ogni lista a tendina dell'app — categorie, autori, lingue, qualifiche disponibili, categorie dei task, e altro. Aggiungi, rinomina o elimina una voce da lì.</p>
      <div class="no-card"><b>Attenzione ai codici Translator/Revisor</b> — queste due qualifiche non sono etichette qualunque: il sistema le usa internamente per decidere chi vede quali task. Rinominarle o cancellarle da qui interrompe silenziosamente quel controllo — se serve cambiarle, chiedi prima conferma a chi sviluppa l'app.</div>
    </section>

    <section id="decisione" class="wide">
      <span class="eyebrow">04</span>
      <h2>La decisione finale sui task</h2>
      <p class="dek">Nella tab Tasks, il pannello "Publish queue" mostra i task che un Revisore ha già approvato — aspettano solo te.</p>
      <ul class="step-list">
        <li>Puoi aprire il file corretto ("Open corrected file") per controllarlo di persona prima di decidere.</li>
        <li><b>Publish</b> — chiude il task e assegna subito crediti e reputazione all'operatore, secondo il giudizio del Revisore. Il documento collegato, però, non diventa ancora pubblico: passa in attesa di finalizzazione (vedi sotto).</li>
        <li><b>Reject</b> — scavalca il giudizio del Revisore. Ti verrà chiesto il motivo. L'operatore riceve la stessa penalità che avrebbe avuto un fail, e il file corretto viene scartato.</li>
      </ul>
      <div class="card"><h3>Perché sono due cose separate</h3><p>Chiudere il task (pagare l'operatore) non deve aspettare che tu abbia già pronto il PDF finale — puoi farlo subito, e occuparti con calma della pubblicazione vera e propria in un secondo momento.</p></div>
    </section>

    <section id="finalizzare" class="wide">
      <span class="eyebrow">05</span>
      <h2>Pubblicare un documento</h2>
      <p class="dek">Sempre nella tab Tasks, il pannello "Documents ready to publish" elenca i documenti il cui task è già stato chiuso, ma che non sono ancora online.</p>
      <ul class="step-list">
        <li><b>Download draft file</b> — scarica la bozza corretta dall'operatore, per prepararne la versione definitiva (conversione in PDF, eventuale rilettura finale).</li>
        <li>Carica il <b>PDF finale</b> — va nello stesso spazio di archiviazione di tutti gli altri documenti pubblicati.</li>
        <li>Carica il <b>file InPage finale</b> — va su Google Drive, nella stessa cartella di tutti gli originali; la prima volta ti verrà chiesto di accedere con un account Google autorizzato.</li>
        <li>Premi <b>Publish</b>: il documento diventa visibile a tutti. La versione precedente <strong>non sparisce</strong> — resta anche lei pubblica, semplicemente non è più quella mostrata per prima nelle ricerche.</li>
      </ul>
    </section>

    <section id="candidature">
      <span class="eyebrow">06</span>
      <h2>Approvazione candidature</h2>
      <p>Quando un Coordinator ha già consigliato una candidatura "Join the Team", tocca a te approvarla definitivamente — solo allora la persona diventa Operator. Questo doppio controllo è voluto: nessuno può promuovere qualcuno da solo, nemmeno un Coordinator.</p>
    </section>

    <section id="annunci">
      <span class="eyebrow">07</span>
      <h2>Annunci ed eliminazioni</h2>
      <p>La tab Announcements pubblica un messaggio che tutti vedranno al prossimo accesso — utile per comunicazioni generali al team. Sei anche l'unico ruolo che può <b>eliminare definitivamente</b> un documento o un task, invece di limitarsi a nasconderlo: un'azione che non si può annullare, da usare con attenzione.</p>
    </section>

    <footer class="page-end">Movimento dei Focolari — Archivio Urdu · Guida Operativa · Admin</footer>
  </main>
</div>

</body>
</html>
$q_admin_it$, 40, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('schema_it', 'it', null, 'Schema e Meccanismi del Database', $q_schema_it$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Schema e Meccanismi del Database</title>
<style>
  :root {
    --paper: #eef1f3;
    --paper-raised: #f7f9fa;
    --paper-card: #e4e9ec;
    --ink: #182027;
    --ink-soft: #4e5a63;
    --ink-faint: #7c8892;
    --line: #d3d9dd;
    --line-strong: #b7c0c6;
    --accent: #0e7c86;
    --accent-strong: #0a5c64;
    --danger: #9c3d35;
    --danger-soft: #f3e3e1;
    --ok: #2f7a4f;
    --ok-soft: #e1efe4;
    --shadow: 0 1px 2px rgba(24, 32, 39, 0.06), 0 6px 20px rgba(24, 32, 39, 0.06);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #11161a;
      --paper-raised: #171d22;
      --paper-card: #1c2329;
      --ink: #e7ecef;
      --ink-soft: #a7b1b8;
      --ink-faint: #74808a;
      --line: #2b333a;
      --line-strong: #3a444c;
      --accent: #3fb8c2;
      --accent-strong: #63cbd3;
      --danger: #d98079;
      --danger-soft: #2c1a19;
      --ok: #7fc99a;
      --ok-soft: #16261c;
      --shadow: 0 1px 2px rgba(0,0,0,.35), 0 8px 24px rgba(0,0,0,.4);
    }
  }
  :root[data-theme="dark"] {
    --paper: #11161a; --paper-raised: #171d22; --paper-card: #1c2329;
    --ink: #e7ecef; --ink-soft: #a7b1b8; --ink-faint: #74808a;
    --line: #2b333a; --line-strong: #3a444c;
    --accent: #3fb8c2; --accent-strong: #63cbd3;
    --danger: #d98079; --danger-soft: #2c1a19; --ok: #7fc99a; --ok-soft: #16261c;
    --shadow: 0 1px 2px rgba(0,0,0,.35), 0 8px 24px rgba(0,0,0,.4);
  }

  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body {
    margin: 0; background: var(--paper); color: var(--ink);
    font-family: "IBM Plex Sans", "Segoe UI", -apple-system, sans-serif;
    font-size: 15.5px; line-height: 1.6; -webkit-font-smoothing: antialiased;
  }
  code, .mono { font-family: "IBM Plex Mono", ui-monospace, "Consolas", monospace; }
  h1, h2, h3 { font-family: "IBM Plex Sans", sans-serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  a { color: var(--accent-strong); }

  .shell { display: grid; grid-template-columns: 250px minmax(0,1fr); max-width: 1200px; margin: 0 auto; }
  @media (max-width: 880px) { .shell { grid-template-columns: 1fr; } }

  nav.toc {
    position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto;
    padding: 36px 18px 36px 26px; border-right: 1px solid var(--line);
  }
  @media (max-width: 880px) {
    nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line);
      padding: 16px 20px; overflow-x: auto; white-space: nowrap; }
  }
  .toc-brand { font-weight: 700; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--accent); font-family: "IBM Plex Mono", monospace; }
  @media (max-width: 880px) { .toc-brand { display: inline-flex; margin: 0 22px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 880px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a {
    display: flex; gap: 8px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px;
    color: var(--ink-soft); text-decoration: none; font-size: 13px; line-height: 1.3;
  }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before {
    content: counter(sec, decimal-leading-zero); font-family: "IBM Plex Mono", monospace;
    font-size: 10.5px; color: var(--ink-faint); flex: none; padding-top: 1px;
  }
  @media (max-width: 880px) { nav.toc a { white-space: nowrap; margin: 0; } }

  main { padding: 52px 44px 120px; min-width: 0; }
  @media (max-width: 880px) { main { padding: 36px 18px 90px; } }

  .cover { max-width: 680px; margin-bottom: 84px; }
  .eyebrow { font-family: "IBM Plex Mono", monospace; font-size: 11px; letter-spacing: .1em; text-transform: uppercase; color: var(--accent); font-weight: 600; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(30px, 4.6vw, 44px); line-height: 1.1; letter-spacing: -.01em; }
  .cover .lede { margin-top: 18px; font-size: 17px; line-height: 1.6; color: var(--ink-soft); max-width: 62ch; }
  .cover .meta { margin-top: 26px; display: flex; gap: 24px; flex-wrap: wrap; font-family: "IBM Plex Mono", monospace; font-size: 11.5px; color: var(--ink-faint); }
  .cover .meta b { color: var(--ink-soft); font-weight: 600; }

  section { max-width: 74ch; margin-bottom: 76px; scroll-margin-top: 28px; }
  section.wide { max-width: 940px; }
  section > .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(22px, 3vw, 27px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14.5px; margin: 8px 0 26px; max-width: 62ch; }
  h3 { font-size: 16px; margin: 30px 0 10px; }
  p { margin: 0 0 14px; }
  p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }

  /* schema table */
  .schema-table { width: 100%; border-collapse: collapse; font-size: 13px; margin: 6px 0 22px; }
  .schema-table caption { text-align: left; font-family: "IBM Plex Mono", monospace; font-size: 12.5px; font-weight: 600; color: var(--accent-strong); margin-bottom: 8px; caption-side: top; }
  .schema-table th, .schema-table td { border-top: 1px solid var(--line); padding: 7px 10px; text-align: left; vertical-align: top; }
  .schema-table th { font-family: "IBM Plex Mono", monospace; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; color: var(--ink-faint); font-weight: 600; }
  .schema-table td.col { font-family: "IBM Plex Mono", monospace; color: var(--accent-strong); white-space: nowrap; }
  .schema-table td.desc { color: var(--ink-soft); }
  .table-wrap { overflow-x: auto; border: 1px solid var(--line); border-radius: 6px; padding: 4px 14px; background: var(--paper-raised); margin: 8px 0 24px; }

  /* code block */
  pre.code { background: var(--paper-card); border: 1px solid var(--line); border-radius: 6px; padding: 14px 16px; overflow-x: auto; font-size: 12.5px; line-height: 1.55; margin: 4px 0 20px; }
  pre.code code { font-family: "IBM Plex Mono", monospace; color: var(--ink); }
  .tok-kw { color: var(--accent-strong); font-weight: 600; }
  .tok-com { color: var(--ink-faint); font-style: italic; }
  .tok-str { color: var(--ok); }

  /* rpc catalog card */
  .rpc-card { border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 5px; padding: 14px 18px; margin: 0 0 14px; background: var(--paper-card); }
  .rpc-card .sig { font-family: "IBM Plex Mono", monospace; font-size: 13px; font-weight: 600; color: var(--accent-strong); }
  .rpc-card .who { font-family: "IBM Plex Mono", monospace; font-size: 10.5px; text-transform: uppercase; letter-spacing: .06em; color: var(--ink-faint); margin-top: 4px; }
  .rpc-card p { font-size: 13.5px; color: var(--ink-soft); margin-top: 8px; }

  /* diagram */
  .diagram-wrap { background: var(--paper-raised); border: 1px solid var(--line); border-radius: 6px; padding: 26px 22px 16px; box-shadow: var(--shadow); margin: 6px 0 26px; overflow-x: auto; }
  figure { margin: 0; }
  figure svg { display: block; width: 100%; height: auto; overflow: visible; }
  figcaption { font-size: 12.5px; color: var(--ink-faint); margin-top: 12px; padding-top: 10px; border-top: 1px solid var(--line); }

  /* callouts */
  .callout { border-radius: 5px; padding: 14px 16px; margin: 6px 0 20px; border: 1px solid var(--line); font-size: 13.5px; }
  .callout.security { background: var(--danger-soft); border-color: color-mix(in srgb, var(--danger) 35%, var(--line)); }
  .callout.security .label { color: var(--danger); }
  .callout.note { background: var(--ok-soft); border-color: color-mix(in srgb, var(--ok) 35%, var(--line)); }
  .callout.note .label { color: var(--ok); }
  .callout .label { font-family: "IBM Plex Mono", monospace; font-size: 10.5px; letter-spacing: .08em; text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 6px; }

  ul.plain { margin: 4px 0 16px; padding-left: 20px; }
  ul.plain li { margin-bottom: 6px; font-size: 14px; color: var(--ink-soft); }
  ul.plain li b { color: var(--ink); }

  .migration-index { width: 100%; border-collapse: collapse; font-size: 12.5px; }
  .migration-index th, .migration-index td { border-top: 1px solid var(--line); padding: 6px 10px; text-align: left; }
  .migration-index th { font-family: "IBM Plex Mono", monospace; font-size: 10.5px; text-transform: uppercase; color: var(--ink-faint); }
  .migration-index td.file { font-family: "IBM Plex Mono", monospace; color: var(--accent-strong); white-space: nowrap; }

  footer.page-end { margin-top: 30px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono", monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&amp;family=IBM+Plex+Mono:wght@400;500;600&amp;display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "IBM Plex Sans",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--accent); border-color: var(--accent); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--accent); outline-offset: 6px; border-radius: 6px; }
</style>
</div><div class="shell" id="edit-root" contenteditable="false" spellcheck="false">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">#</span> Schema del Database</div>
    <ol>
      <li><a href="#overview">Architettura</a></li>
      <li><a href="#ruoli">Ruoli e permessi (RLS)</a></li>
      <li><a href="#schema">Tabelle principali</a></li>
      <li><a href="#task-fsm">Macchina a stati: Task</a></li>
      <li><a href="#task-rpc">Funzioni RPC: Task</a></li>
      <li><a href="#doc-fsm">Macchina a stati: Documento</a></li>
      <li><a href="#doc-rpc">Funzioni RPC: Documento</a></li>
      <li><a href="#ledger">Crediti e reputazione</a></li>
      <li><a href="#storage">Storage e Google Drive</a></li>
      <li><a href="#migrazioni">Indice delle migrazioni</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Urdu Archive Manager — riferimento tecnico</span>
      <h1>Schema e meccanismi del database</h1>
      <p class="lede">Riferimento tecnico per chi sviluppa o mantiene l'applicazione: tabelle, policy di sicurezza (RLS), funzioni del database (RPC), e le due macchine a stati — task e documento — che governano il flusso di lavoro.</p>
      <div class="meta">
        <span><b>Backend</b> Supabase (Postgres + Auth + Storage)</span>
        <span><b>Repo</b> mediafocolarepak/Urdu-Archive</span>
        <span><b>Ultima migrazione</b> 50_two_step_publish_and_versioning.sql</span>
      </div>
    </div>

    <section id="overview">
      <span class="eyebrow">01</span>
      <h2>Architettura</h2>
      <p class="dek">Nessun server applicativo: la logica vive nel database.</p>
      <p>L'app è HTML/JavaScript statico (nessun framework, nessun bundler), pubblicato su GitHub Pages. Non esiste un server applicativo intermedio: il browser parla direttamente con Supabase (Postgres + Auth + Storage) tramite il client `supabase-js`. Questo ha una conseguenza precisa: <strong>la sicurezza non può dipendere dal codice JavaScript</strong>, perché chiunque può leggerlo o modificarlo negli strumenti di sviluppo del browser. Ogni regola che conta davvero — chi può vedere una riga, chi può modificarla, chi può eseguire un'azione — è imposta dal database stesso tramite <strong>Row Level Security (RLS)</strong> e funzioni <code>SECURITY DEFINER</code>. L'interfaccia si limita a rispecchiare quelle regole per comodità dell'utente, non le sostituisce.</p>
      <p>Due integrazioni esterne, entrambe verso Google Drive: una in sola lettura con una API key pubblica (per i PDF storici e i file InPage originali, entrambi in cartelle condivise "chiunque abbia il link"), una in scrittura con consenso OAuth dell'utente (usata dall'InPage Converter e dal caricamento del file InPage finale a fine correzione).</p>
    </section>

    <section id="ruoli" class="wide">
      <span class="eyebrow">02</span>
      <h2>Ruoli e permessi (RLS)</h2>
      <p class="dek">Un'unica funzione SQL decide chi può fare cosa; ogni policy la richiama.</p>
      <p>I ruoli (<code>user_roles.role</code>) formano una scala crescente: <code>user</code> &lt; <code>operator</code> &lt; <code>coordinator</code> &lt; <code>admin</code>. Quasi ogni policy RLS nel database richiama la stessa funzione:</p>
      <pre class="code"><code><span class="tok-kw">create or replace function</span> public.current_role_is(min_role <span class="tok-kw">text</span>)
<span class="tok-kw">returns boolean language sql security definer stable as</span> $$
  <span class="tok-kw">select case</span>
    <span class="tok-kw">when</span> min_role = <span class="tok-str">'operator'</span> <span class="tok-kw">then exists</span> (... <span class="tok-kw">role in</span> (<span class="tok-str">'operator','coordinator','admin'</span>))
    <span class="tok-kw">when</span> min_role = <span class="tok-str">'coordinator'</span> <span class="tok-kw">then exists</span> (... <span class="tok-kw">role in</span> (<span class="tok-str">'coordinator','admin'</span>))
    <span class="tok-kw">when</span> min_role = <span class="tok-str">'admin'</span> <span class="tok-kw">then exists</span> (... <span class="tok-kw">role</span> = <span class="tok-str">'admin'</span>)
  <span class="tok-kw">end</span>;
$$;</code></pre>
      <p>Una policy tipo <code>using (current_role_is('coordinator'))</code> significa quindi "Coordinator o superiore". Le <strong>qualifiche</strong> (Translator, Revisor, Proof Reader, Content Creator) sono un asse indipendente — non un livello nella scala, ma etichette in <code>user_qualifications</code> (many-to-many, un Operator può averne più di una), verificate da una seconda funzione, <code>user_qualifies_for_category(uid, cat)</code>, usata per decidere se un Operator può vedere/prendere un task di una certa categoria.</p>
      <div class="callout security">
        <span class="label">Punto critico</span>
        Le stringhe <code>'TRANSLATOR'</code> e <code>'REVISOR'</code> sono scritte letteralmente dentro le funzioni SQL. La lista delle qualifiche è modificabile da Admin via Options (tabella <code>option_lists</code>), ma rinominare o cancellare quei due codici da lì <strong>rompe silenziosamente</strong> il controllo — nessun errore, semplicemente i task di quella categoria smettono di essere filtrati correttamente.
      </div>
    </section>

    <section id="schema" class="wide">
      <span class="eyebrow">03</span>
      <h2>Tabelle principali</h2>
      <p class="dek">Solo le colonne rilevanti per capire il funzionamento — non un dump completo dello schema.</p>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>documents — il catalogo dell'archivio</caption>
        <thead><tr><th>Colonna</th><th>Significato</th></tr></thead>
        <tbody>
          <tr><td class="col">document_id</td><td class="desc">Chiave primaria, intero assegnato manualmente dall'app (non una sequence — vedi §Task RPC per come viene calcolato un nuovo id)</td></tr>
          <tr><td class="col">work_id</td><td class="desc">Raggruppa le versioni "sorelle" di uno stesso Work (lingue diverse, o — dal 2026-08-31 — versioni corrette nel tempo). Vedi §Documento: macchina a stati</td></tr>
          <tr><td class="col">is_preferred</td><td class="desc">Quale sorella è quella mostrata di default nelle liste</td></tr>
          <tr><td class="col">workflow_status</td><td class="desc"><code>published</code> / <code>revision</code> / <code>pending_publish</code> / <code>removed</code> — governa la visibilità reale (RLS), non solo un filtro UI</td></tr>
          <tr><td class="col">storage_path / file_name</td><td class="desc">Riservati al <strong>PDF finale</strong> pubblicato (Supabase Storage, bucket <code>archive-files</code>)</td></tr>
          <tr><td class="col">draft_inp_path</td><td class="desc">File InPage grezzo caricato da un Operator durante un task di correzione (Storage) — mai lo stesso campo del PDF</td></tr>
          <tr><td class="col">original_inp_file_name</td><td class="desc">Nome storico non prefissato, solo per riferimento — <em>non</em> usato per cercare il file</td></tr>
          <tr><td class="col">renamed_inp_file_name</td><td class="desc">Nome reale su Google Drive (<code>&lt;document_id&gt;-...</code>), quello effettivamente usato per il download</td></tr>
          <tr><td class="col">source_task_id</td><td class="desc">Se il record è una candidata di correzione: il task che l'ha generata</td></tr>
          <tr><td class="col">category, author, main_topic, source, language, ...</td><td class="desc">Campi di catalogazione, vocabolario in <code>option_lists</code></td></tr>
        </tbody>
      </table>
      </div>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>tasks — la bacheca dei lavori</caption>
        <thead><tr><th>Colonna</th><th>Significato</th></tr></thead>
        <tbody>
          <tr><td class="col">status</td><td class="desc"><code>open / claimed / submitted / approved / rejected / published</code> — vedi §Task: macchina a stati</td></tr>
          <tr><td class="col">category</td><td class="desc">Fissa dalla creazione, mai riscritta — governa la visibilità per qualifica (§Ruoli)</td></tr>
          <tr><td class="col">document_id, document_pages, credits</td><td class="desc">Collegamento al documento e "prezzo" del task (valore fisso deciso alla creazione, non calcolato da una formula)</td></tr>
          <tr><td class="col">claimed_by / claimed_by_email</td><td class="desc"><strong>Mai esposto a un Revisore</strong> — vedi <code>get_review_queue()</code></td></tr>
          <tr><td class="col">excluded_operator</td><td class="desc">Su un task nato da un fail: l'operatore che ha fallito, escluso dal riprenderlo</td></tr>
          <tr><td class="col">retry_of_task_id</td><td class="desc">Collega un task rigenerato al tentativo fallito originale (solo su fail del Revisore, non su reject dell'Admin)</td></tr>
          <tr><td class="col">review_verdict, review_notes, reviewed_by*</td><td class="desc">Il giudizio del Revisore — non tocca ancora crediti/reputazione da solo</td></tr>
        </tbody>
      </table>
      </div>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>task_outcome_events — il ledger (fonte di verità)</caption>
        <thead><tr><th>Colonna</th><th>Significato</th></tr></thead>
        <tbody>
          <tr><td class="col">task_id, user_id</td><td class="desc">Quale task, quale operatore viene premiato/penalizzato</td></tr>
          <tr><td class="col">event_type</td><td class="desc">Testo libero: <code>review_ok</code>, <code>review_ok_but</code>, <code>review_fail</code>, <code>admin_rejected</code>, <code>reclaimed</code>, <code>given_up</code></td></tr>
          <tr><td class="col">credit_delta, reputation_delta</td><td class="desc">Applicati a <code>user_roles.credits</code>/<code>reputation</code> da un trigger, mai scritti a mano</td></tr>
          <tr><td class="col">created_by_email, note</td><td class="desc">Chi ha generato l'evento e perché — l'audit trail leggibile da un umano</td></tr>
        </tbody>
      </table>
      </div>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>Tabelle di supporto</caption>
        <thead><tr><th>Tabella</th><th>Ruolo</th></tr></thead>
        <tbody>
          <tr><td class="col">user_roles</td><td class="desc">Un ruolo per utente, più <code>credits</code>/<code>reputation</code> (aggiunti in step 1 della pipeline task)</td></tr>
          <tr><td class="col">user_qualifications</td><td class="desc">Many-to-many utente↔qualifica</td></tr>
          <tr><td class="col">option_lists</td><td class="desc">Vocabolario generico riusato per <em>ogni</em> lista a tendina dell'app (categoria, autore, qualifiche, categoria task, workflow_status...) — <code>(list_name, code)</code> chiave primaria</td></tr>
          <tr><td class="col">works</td><td class="desc">Un Work = un'opera; <code>documents.work_id</code> vi fa riferimento per raggruppare le versioni</td></tr>
          <tr><td class="col">chat_messages</td><td class="desc">Ticketing utente↔team, con pulsante "Create task" collegato a <code>State.taskPrefill</code> lato client (non un vero collegamento DB)</td></tr>
          <tr><td class="col">collaboration_applications</td><td class="desc">Candidature "Join the Team" (User → Operator)</td></tr>
        </tbody>
      </table>
      </div>
    </section>

    <section id="task-fsm" class="wide">
      <span class="eyebrow">04</span>
      <h2>Macchina a stati: Task</h2>
      <p class="dek">Applicata a livello di database, non solo in JavaScript.</p>
      <div class="diagram-wrap">
        <figure>
          <svg viewBox="0 0 900 260" role="img" aria-label="Il campo tasks.status passa da open a claimed a submitted; il Revisore decide fail (torna open come nuovo task per un altro operatore) oppure ok/ok_but (approved); da approved l'Admin decide reject (chiude come rejected, nessun credito) oppure publish (chiude il task, published, crediti assegnati). Un trigger sul database rifiuta qualunque altra transizione.">
            <defs>
              <marker id="arrow2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                <path d="M0,0 L10,5 L0,10 z" fill="currentColor"></path>
              </marker>
            </defs>
            <g font-family="IBM Plex Mono, monospace" font-size="12" fill="currentColor">
              <rect x="10" y="40" width="100" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="60" y="64" text-anchor="middle">open</text>
              <rect x="178" y="40" width="100" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="228" y="64" text-anchor="middle">claimed</text>
              <rect x="346" y="40" width="116" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="404" y="64" text-anchor="middle">submitted</text>
              <rect x="530" y="40" width="116" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="588" y="64" text-anchor="middle">approved</text>
              <rect x="746" y="40" width="110" height="40" rx="4" stroke="var(--accent)" stroke-width="2" fill="none"></rect>
              <text x="801" y="64" text-anchor="middle" fill="var(--accent)" font-weight="700">published</text>

              <line x1="110" y1="60" x2="174" y2="60" stroke="currentColor" marker-end="url(#arrow2)"></line>
              <text x="142" y="51" text-anchor="middle" font-size="10">claim</text>
              <line x1="278" y1="60" x2="342" y2="60" stroke="currentColor" marker-end="url(#arrow2)"></line>
              <text x="310" y="51" text-anchor="middle" font-size="10">submit</text>
              <line x1="462" y1="60" x2="526" y2="60" stroke="currentColor" marker-end="url(#arrow2)"></line>
              <text x="494" y="51" text-anchor="middle" font-size="10">ok / ok_but</text>
              <line x1="646" y1="60" x2="742" y2="60" stroke="var(--accent)" stroke-width="2" marker-end="url(#arrow2)"></line>
              <text x="694" y="51" text-anchor="middle" font-size="10" fill="var(--accent)">admin: publish</text>

              <text x="404" y="30" text-anchor="middle" font-size="10.5" opacity=".75">giudizio del Revisore</text>
              <text x="588" y="30" text-anchor="middle" font-size="10.5" opacity=".75">decisione dell'Admin</text>

              <path d="M 404 82 C 404 150, 60 150, 60 178" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow2)"></path>
              <text x="230" y="146" text-anchor="middle" font-size="10" fill="var(--danger)">fail — nuovo task open, altro operatore</text>
              <rect x="10" y="180" width="100" height="40" rx="4" fill="none" stroke="var(--danger)" stroke-dasharray="3 3"></rect>
              <text x="60" y="204" text-anchor="middle" fill="var(--danger)">rejected</text>

              <path d="M 588 82 C 588 150, 700 150, 700 178" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow2)"></path>
              <text x="644" y="146" text-anchor="middle" font-size="10" fill="var(--danger)">admin: reject</text>
              <rect x="650" y="180" width="100" height="40" rx="4" fill="none" stroke="var(--danger)" stroke-dasharray="3 3"></rect>
              <text x="700" y="204" text-anchor="middle" fill="var(--danger)">rejected</text>

              <path d="M 228 82 C 228 110, 110 110, 110 60" fill="none" stroke="currentColor" stroke-width="1.2" marker-end="url(#arrow2)" opacity=".6"></path>
              <text x="169" y="112" text-anchor="middle" font-size="9.5" opacity=".6">give_up / reclaim</text>
            </g>
          </svg>
          <figcaption>Percorso di <code>tasks.status</code>. Ogni transizione è verificata da un trigger (<code>validate_task_status_transition</code>) — qualunque altra combinazione viene rifiutata dal database, indipendentemente da cosa prova a fare il client.</figcaption>
        </figure>
      </div>
      <p>Due dettagli non ovvi dal solo diagramma: <strong>il giudizio del Revisore non tocca crediti/reputazione</strong> — solo la decisione dell'Admin lo fa (vedi <code>admin_decide_task</code> sotto). E <strong>un fail del Revisore e un reject dell'Admin non sono equivalenti</strong>: il primo genera <em>automaticamente</em> un nuovo task; il secondo no (l'Admin sceglie se e quando ricrearlo, dalla lista "Completed").</p>
    </section>

    <section id="task-rpc" class="wide">
      <span class="eyebrow">05</span>
      <h2>Funzioni RPC: Task</h2>
      <p class="dek">Ogni transizione che tocca crediti o reputazione passa da una funzione <code>SECURITY DEFINER</code>, mai da un update diretto dal client.</p>

      <div class="rpc-card">
        <div class="sig">give_up_task(p_task_id, p_note)</div>
        <div class="who">chiamabile da: l'operatore che ha preso il task</div>
        <p><code>claimed → open</code>. Rinuncia onesta e volontaria — <strong>nessuna penalità</strong> (delta 0/0), ma comunque loggata nel ledger per lo storico.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">reclaim_task(p_task_id, p_note)</div>
        <div class="who">chiamabile da: Coordinator+</div>
        <p><code>claimed → open</code>, forzato. Per ritardo senza risposta o comportamento scorretto — <strong>-10 reputazione</strong>, obbligatorio (non scavalcabile chiamando un update diretto, perché non esiste una policy che lo permetta).</p>
      </div>
      <div class="rpc-card">
        <div class="sig">get_review_queue()</div>
        <div class="who">chiamabile da: Revisore qualificato, o Coordinator+</div>
        <p>Restituisce i task <code>submitted</code> — <strong>mai <code>claimed_by</code>/<code>claimed_by_email</code></strong>. Non è un filtro lato client: quelle colonne non vengono proprio incluse nella query SQL interna. Esclude anche i task che il chiamante ha svolto lui stesso.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">submit_task_review(p_task_id, p_verdict, p_notes)</div>
        <div class="who">chiamabile da: Revisore qualificato, o Coordinator+ — mai il claimant</div>
        <p><code>verdict = 'fail'</code> → <code>submitted → rejected</code>, -10 reputazione applicati <strong>subito</strong>, più creazione automatica di un nuovo task open (stesso documento/categoria, <code>excluded_operator</code> = chi ha fallito).<br><code>verdict ∈ {'ok','ok_but'}</code> → <code>submitted → approved</code>, ma <strong>nessun delta ancora</strong> — resta in sospeso fino alla decisione dell'Admin.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">admin_decide_task(p_task_id, p_decision, p_note)</div>
        <div class="who">chiamabile da: Admin soltanto (non Coordinator)</div>
        <p><code>p_decision = 'publish'</code> → <code>approved → published</code>, applica il delta che il verdetto del Revisore implicava (+10, o -5 se era "ok, ma..."), e sposta il documento candidato collegato a <code>pending_publish</code> (non ancora visibile).<br><code>p_decision = 'reject'</code> → <code>approved → rejected</code>, stessa penalità di un fail (-10, 0 crediti), scavalca il Revisore; il documento candidato passa a <code>removed</code>.</p>
      </div>
    </section>

    <section id="doc-fsm" class="wide">
      <span class="eyebrow">06</span>
      <h2>Macchina a stati: Documento</h2>
      <p class="dek"><code>documents.workflow_status</code> — un asse indipendente dal task che l'ha generato.</p>
      <div class="diagram-wrap">
        <figure>
          <svg viewBox="0 0 900 220" role="img" aria-label="Un nuovo record documento nasce con stato revision, visibile solo al suo operatore e a Coordinator/Admin. Se il task collegato viene chiuso con esito ok dall'admin, passa a pending_publish. Se il Revisore fallisce il task o l'Admin rifiuta, passa a removed, visibile solo ad Admin. Da pending_publish, quando l'Admin carica PDF e file InPage finali e conferma, il documento passa a published e diventa visibile a tutti, senza nascondere la versione precedente dello stesso Work.">
            <defs>
              <marker id="arrow3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                <path d="M0,0 L10,5 L0,10 z" fill="currentColor"></path>
              </marker>
            </defs>
            <g font-family="IBM Plex Mono, monospace" font-size="12" fill="currentColor">
              <rect x="10" y="30" width="120" height="42" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="70" y="55" text-anchor="middle">revision</text>
              <text x="70" y="88" text-anchor="middle" font-size="9.5" opacity=".7">operatore + Coord/Admin</text>

              <rect x="330" y="30" width="150" height="42" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="405" y="55" text-anchor="middle">pending_publish</text>
              <text x="405" y="88" text-anchor="middle" font-size="9.5" opacity=".7">task chiuso, doc non ancora vivo</text>

              <rect x="700" y="30" width="140" height="42" rx="4" stroke="var(--accent)" stroke-width="2" fill="none"></rect>
              <text x="770" y="55" text-anchor="middle" fill="var(--accent)" font-weight="700">published</text>
              <text x="770" y="88" text-anchor="middle" font-size="9.5" opacity=".7">is_preferred = true</text>

              <rect x="330" y="150" width="120" height="42" rx="4" fill="none" stroke="var(--danger)" stroke-dasharray="3 3"></rect>
              <text x="390" y="175" text-anchor="middle" fill="var(--danger)">removed</text>
              <text x="390" y="205" text-anchor="middle" font-size="9.5" opacity=".7">solo Admin</text>

              <line x1="130" y1="51" x2="326" y2="51" stroke="currentColor" marker-end="url(#arrow3)"></line>
              <text x="228" y="42" text-anchor="middle" font-size="10">admin_decide_task('publish')</text>

              <path d="M 130 60 C 220 110, 260 110, 326 165" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow3)"></path>
              <text x="220" y="128" text-anchor="middle" font-size="9.5" fill="var(--danger)">Revisore: fail</text>

              <path d="M 405 72 C 405 105, 400 120, 395 146" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow3)"></path>
              <text x="440" y="112" text-anchor="middle" font-size="9.5" fill="var(--danger)">admin: reject</text>

              <line x1="480" y1="51" x2="696" y2="51" stroke="var(--accent)" stroke-width="2" marker-end="url(#arrow3)"></line>
              <text x="588" y="42" text-anchor="middle" font-size="10" fill="var(--accent)">finalize_document_publish()</text>
            </g>
          </svg>
          <figcaption>Percorso di <code>documents.workflow_status</code> per un record "candidato" a correzione. Il documento originale, nel frattempo, resta sempre <code>published</code> — anche dopo che la nuova versione diventa a sua volta <code>published</code> (vedi sotto: si sostituisce solo <code>is_preferred</code>, mai la visibilità).</figcaption>
        </figure>
      </div>
      <div class="callout note">
        <span class="label">Non un rimpiazzo, un fratello</span>
        Quando <code>finalize_document_publish()</code> rende pubblica la nuova versione, l'originale <strong>non</strong> passa a <code>removed</code>. Entrambi restano <code>published</code> e visibili — sono versioni sorelle dello stesso <code>work_id</code>, lo stesso meccanismo già usato per varianti di lingua/formato. Solo <code>is_preferred</code> si sposta sulla versione nuova, così è quella mostrata di default.
      </div>
    </section>

    <section id="doc-rpc" class="wide">
      <span class="eyebrow">07</span>
      <h2>Funzioni RPC: Documento</h2>
      <div class="rpc-card">
        <div class="sig">get_review_document(p_document_id)</div>
        <div class="who">chiamabile da: Revisore qualificato, o Coordinator+</div>
        <p>Restituisce i campi di un documento <code>revision</code> necessari per controllarlo (titolo, categoria, <code>draft_inp_path</code>) — <strong>mai <code>operator</code>/<code>updated_by</code></strong>, stesso principio di anonimato del task.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">finalize_document_publish(p_document_id)</div>
        <div class="who">chiamabile da: Admin soltanto</div>
        <p>Secondo passo, separato dalla chiusura del task: promuove il documento a <code>published</code> + <code>is_preferred = true</code>, e retrocede (non nasconde) qualunque altro fratello dello stesso <code>work_id</code> che avesse <code>is_preferred = true</code> prima.</p>
      </div>
      <div class="callout security">
        <span class="label">Perché due passi separati</span>
        La chiusura del task (crediti/reputazione) e la pubblicazione del documento (file finali pronti) sono state deliberatamente scollegate: l'Admin non deve aspettare di avere il PDF pronto per chiudere il task e pagare l'operatore. Il pannello "Documents ready to publish" (tab Tasks) elenca i documenti fermi a <code>pending_publish</code>.
      </div>
    </section>

    <section id="ledger">
      <span class="eyebrow">08</span>
      <h2>Crediti e reputazione</h2>
      <p class="dek">Un solo trigger, una sola fonte di verità.</p>
      <p><code>user_roles.credits</code> (parte da 0, sale soltanto) e <code>user_roles.reputation</code> (0–100, parte da 50) non vengono mai scritti direttamente. Ogni riga inserita in <code>task_outcome_events</code> fa scattare:</p>
      <pre class="code"><code><span class="tok-com">-- after insert on task_outcome_events, per riga</span>
<span class="tok-kw">update</span> user_roles
<span class="tok-kw">set</span> credits = credits + new.credit_delta,
    reputation = <span class="tok-kw">greatest</span>(<span class="tok-kw">0</span>, <span class="tok-kw">least</span>(<span class="tok-kw">100</span>, reputation + new.reputation_delta))
<span class="tok-kw">where</span> user_id = new.user_id;</code></pre>
      <p>Questo rende il ledger l'unico posto dove serve guardare per capire "perché il punteggio di qualcuno è cambiato" — i due campi su <code>user_roles</code> sono solo una cache per letture rapide (mostrate nel widget in alto, solo per il ruolo Operator).</p>
    </section>

    <section id="storage">
      <span class="eyebrow">09</span>
      <h2>Storage e Google Drive</h2>
      <p class="dek">Tre destinazioni diverse per tre tipi di file — non intercambiabili.</p>
      <ul class="plain">
        <li><b>Supabase Storage</b> (bucket <code>archive-files</code>) — PDF finali pubblicati (<code>storage_path</code>/<code>file_name</code>) e bozze di correzione in corso (<code>draft_inp_path</code>). Upload via <code>supabase.storage.from(BUCKET).upload()</code>, download via URL firmato temporaneo.</li>
        <li><b>Google Drive, cartella PDF storici</b> — lettura pubblica via API key, lookup per nome file esatto (<code>documents.file_name</code>). Nessuna scrittura da qui.</li>
        <li><b>Google Drive, cartella "INPAGE Original Document"</b> (<code>1LnZ2qo9bAQfyTnvU8V-0D9qLcXQX82DY</code>) — stesso meccanismo di lettura pubblica per gli originali InPage (<code>documents.renamed_inp_file_name</code>); <strong>scrittura</strong> tramite OAuth (consenso Google richiesto al primo utilizzo per sessione) quando l'Admin carica il file InPage finale di una correzione.</li>
      </ul>
      <div class="callout security">
        <span class="label">Dipendenza silenziosa</span>
        Il meccanismo di lettura pubblica funziona solo finché le due cartelle Drive restano condivise "chiunque abbia il link". Se qualcuno stringe i permessi, il sintomo è un generico "file non trovato" — non un errore di permesso esplicito, perché la API key non basta a distinguere i due casi.
      </div>
    </section>

    <footer class="page-end">Focolare Urdu Archive Manager — riferimento tecnico, generato 2026-08-31</footer>
  </main>
</body>
</html>
$q_schema_it$, 50, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('roles_en', 'en', null, 'Book of Roles', $q_roles_en$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Book of Roles</title>
<style>
  :root {
    --paper: #eef0e6;
    --paper-raised: #f8f9f2;
    --paper-card: #f3f4ea;
    --ink: #1e2a1f;
    --ink-soft: #55624e;
    --ink-faint: #838f79;
    --line: #d2d6c1;
    --line-strong: #b9bea3;
    --brass: #8f6a24;
    --brass-strong: #6e5219;
    --thread: #7c3430;
    --thread-soft: #f3e4de;
    --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30, 42, 31, 0.06), 0 6px 20px rgba(30, 42, 31, 0.05);
  }

  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810;
      --paper-raised: #1a2116;
      --paper-card: #1e261a;
      --ink: #e8e7d8;
      --ink-soft: #a8ae98;
      --ink-faint: #798270;
      --line: #303a29;
      --line-strong: #414d36;
      --brass: #d2a24e;
      --brass-strong: #e6b869;
      --thread: #cf7d78;
      --thread-soft: #2c1a18;
      --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0, 0, 0, 0.3), 0 8px 24px rgba(0, 0, 0, 0.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810;
    --paper-raised: #1a2116;
    --paper-card: #1e261a;
    --ink: #e8e7d8;
    --ink-soft: #a8ae98;
    --ink-faint: #798270;
    --line: #303a29;
    --line-strong: #414d36;
    --brass: #d2a24e;
    --brass-strong: #e6b869;
    --thread: #cf7d78;
    --thread-soft: #2c1a18;
    --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0, 0, 0, 0.3), 0 8px 24px rgba(0, 0, 0, 0.35);
  }

  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  body {
    margin: 0;
    background: var(--paper);
    color: var(--ink);
    font-family: "Archivo", "Segoe UI", -apple-system, sans-serif;
    font-size: 16px;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
  }
  @media (prefers-reduced-motion: reduce) {
    html { scroll-behavior: auto; }
    * { animation: none !important; transition: none !important; }
  }

  h1, h2, h3 {
    font-family: "Fraunces", Georgia, serif;
    color: var(--ink);
    text-wrap: balance;
    font-weight: 600;
    margin: 0;
  }

  .eyebrow {
    font-family: "IBM Plex Mono", ui-monospace, monospace;
    font-size: 11.5px;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--brass);
    font-weight: 600;
  }

  a { color: var(--brass-strong); }

  /* ---------- Layout shell ---------- */
  .shell {
    display: grid;
    grid-template-columns: 240px minmax(0, 1fr);
    max-width: 1180px;
    margin: 0 auto;
  }
  @media (max-width: 860px) {
    .shell { grid-template-columns: 1fr; }
  }

  nav.toc {
    position: sticky;
    top: 0;
    align-self: start;
    height: 100vh;
    overflow-y: auto;
    padding: 40px 20px 40px 28px;
    border-right: 1px solid var(--line);
  }
  @media (max-width: 860px) {
    nav.toc {
      position: static;
      height: auto;
      border-right: none;
      border-bottom: 1px solid var(--line);
      padding: 18px 20px;
      overflow-x: auto;
      white-space: nowrap;
    }
  }

  .toc-brand {
    font-family: "Fraunces", serif;
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 22px;
    display: flex;
    align-items: baseline;
    gap: 8px;
  }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono", monospace; }
  @media (max-width: 860px) { .toc-brand { display: inline-flex; margin: 0 24px 0 0; } }

  nav.toc ol {
    list-style: none;
    margin: 0;
    padding: 0;
    counter-reset: sec;
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  @media (max-width: 860px) {
    nav.toc ol { flex-direction: row; gap: 4px; }
  }
  nav.toc li { counter-increment: sec; }
  nav.toc a {
    display: flex;
    gap: 8px;
    padding: 6px 8px;
    margin: 0 -8px;
    border-radius: 3px;
    color: var(--ink-soft);
    text-decoration: none;
    font-size: 13.5px;
    line-height: 1.3;
  }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before {
    content: counter(sec, decimal-leading-zero);
    font-family: "IBM Plex Mono", monospace;
    font-size: 11px;
    color: var(--ink-faint);
    flex: none;
    padding-top: 1px;
  }
  @media (max-width: 860px) {
    nav.toc a { white-space: nowrap; margin: 0; }
  }

  main { padding: 56px 48px 120px; min-width: 0; }
  @media (max-width: 860px) { main { padding: 40px 20px 90px; } }

  .cover { max-width: 640px; margin-bottom: 90px; }
  .cover .eyebrow { display: block; margin-bottom: 16px; }
  .cover h1 {
    font-size: clamp(34px, 5.4vw, 52px);
    line-height: 1.08;
    letter-spacing: -0.01em;
  }
  .cover .lede {
    margin-top: 22px;
    font-size: 18px;
    line-height: 1.65;
    color: var(--ink-soft);
    max-width: 62ch;
  }
  .cover .meta {
    margin-top: 32px;
    display: flex;
    gap: 28px;
    flex-wrap: wrap;
    font-family: "IBM Plex Mono", monospace;
    font-size: 12px;
    color: var(--ink-faint);
  }
  .cover .meta b { color: var(--ink-soft); font-weight: 600; }

  section { max-width: 68ch; margin-bottom: 84px; scroll-margin-top: 32px; }
  section.wide { max-width: 900px; }
  section > .eyebrow { display: block; margin-bottom: 10px; }
  section h2 { font-size: clamp(24px, 3.4vw, 30px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 15.5px; margin: 10px 0 30px; max-width: 58ch; }

  p { margin: 0 0 16px; }
  p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }

  .rule {
    border: none;
    border-top: 1px solid var(--line);
    margin: 0 0 30px;
  }

  /* ---------- Role ladder ---------- */
  .ladder { display: flex; flex-direction: column; gap: 10px; margin: 8px 0 8px; }
  .rung {
    display: grid;
    grid-template-columns: 140px 1fr;
    gap: 20px;
    align-items: start;
    padding: 18px 20px;
    background: var(--paper-card);
    border: 1px solid var(--line);
    border-left: 3px solid var(--line-strong);
    border-radius: 4px;
  }
  .rung.top { border-left-color: var(--brass); }
  @media (max-width: 620px) { .rung { grid-template-columns: 1fr; gap: 8px; } }
  .rung .role-name {
    font-family: "Fraunces", serif;
    font-weight: 600;
    font-size: 17px;
  }
  .rung .role-code {
    display: block;
    font-family: "IBM Plex Mono", monospace;
    font-size: 10.5px;
    letter-spacing: 0.08em;
    color: var(--ink-faint);
    margin-top: 3px;
    text-transform: uppercase;
  }
  .rung ul { margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 5px; }
  .rung li { font-size: 14px; color: var(--ink-soft); padding-left: 15px; position: relative; }
  .rung li::before {
    content: "";
    position: absolute; left: 0; top: 8px;
    width: 5px; height: 5px; border-radius: 50%;
    background: var(--brass);
    opacity: 0.7;
  }
  .rung li b { color: var(--ink); font-weight: 600; }
  .cumulative-note {
    font-size: 13px;
    color: var(--ink-faint);
    margin-top: 14px;
    padding-left: 4px;
    border-left: 2px solid var(--line);
    padding-left: 14px;
  }

  /* ---------- Qualification chips ---------- */
  .qual-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
    margin: 8px 0 20px;
  }
  @media (max-width: 620px) { .qual-grid { grid-template-columns: 1fr; } }
  .qual-card {
    background: var(--paper-card);
    border: 1px solid var(--line);
    border-radius: 4px;
    padding: 16px 18px;
  }
  .qual-card .qname {
    font-family: "Fraunces", serif;
    font-weight: 600;
    font-size: 15.5px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .qual-card .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--brass); flex: none; }
  .qual-card p { font-size: 13.5px; color: var(--ink-soft); margin-top: 8px; }

  /* ---------- Diagram figure ---------- */
  figure { margin: 0 0 8px; }
  figure svg { display: block; width: 100%; height: auto; max-width: 100%; overflow: visible; }
  figcaption {
    font-size: 13px;
    color: var(--ink-faint);
    margin-top: 14px;
    padding-top: 12px;
    border-top: 1px solid var(--line);
  }
  .diagram-wrap {
    background: var(--paper-raised);
    border: 1px solid var(--line);
    border-radius: 6px;
    padding: 28px 24px 18px;
    box-shadow: var(--shadow);
    margin: 4px 0 30px;
    overflow-x: auto;
  }

  /* ---------- Callouts / exit paths ---------- */
  .exit-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin: 26px 0; }
  @media (max-width: 620px) { .exit-grid { grid-template-columns: 1fr; } }
  .exit-card {
    border-radius: 4px;
    padding: 16px 18px;
    border: 1px solid var(--line);
  }
  .exit-card.calm { background: var(--sage-soft); border-color: var(--line-strong); }
  .exit-card.warn { background: var(--thread-soft); border-color: color-mix(in srgb, var(--thread) 35%, var(--line)); }
  .exit-card .label {
    font-family: "IBM Plex Mono", monospace;
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    font-weight: 600;
  }
  .exit-card.calm .label { color: var(--brass-strong); }
  .exit-card.warn .label { color: var(--thread); }
  .exit-card h3 { font-size: 15.5px; margin-top: 6px; }
  .exit-card p { font-size: 13.5px; color: var(--ink-soft); margin-top: 8px; }

  /* ---------- Definition rows (credits/reputation) ---------- */
  .def-row {
    display: grid;
    grid-template-columns: 130px 1fr;
    gap: 20px;
    padding: 18px 0;
    border-top: 1px solid var(--line);
  }
  .def-row:last-child { border-bottom: 1px solid var(--line); }
  @media (max-width: 620px) { .def-row { grid-template-columns: 1fr; gap: 6px; } }
  .def-row dt {
    font-family: "Fraunces", serif;
    font-weight: 600;
    font-size: 16px;
  }
  .def-row dd { margin: 0; font-size: 14.5px; color: var(--ink-soft); }

  /* reputation meter sample */
  .meter { display: flex; align-items: center; gap: 12px; margin-top: 14px; }
  .meter .track {
    flex: 1;
    height: 8px;
    border-radius: 5px;
    background: var(--line);
    overflow: hidden;
  }
  .meter .fill {
    height: 100%;
    width: 50%;
    border-radius: 5px;
    background: linear-gradient(90deg, var(--thread), var(--brass));
  }
  .meter .val { font-family: "IBM Plex Mono", monospace; font-size: 13px; color: var(--ink-soft); flex: none; }

  /* ---------- Log strip ---------- */
  .log-strip { display: flex; flex-direction: column; border: 1px solid var(--line); border-radius: 4px; overflow: hidden; margin: 10px 0 24px; }
  .log-line {
    display: grid;
    grid-template-columns: 100px 110px 1fr;
    gap: 14px;
    padding: 11px 16px;
    font-size: 13px;
    border-top: 1px solid var(--line);
  }
  .log-line:first-child { border-top: none; background: var(--paper-card); }
  @media (max-width: 620px) { .log-line { grid-template-columns: 1fr; gap: 2px; } }
  .log-line .when { font-family: "IBM Plex Mono", monospace; color: var(--ink-faint); }
  .log-line .who { color: var(--brass-strong); font-weight: 600; }
  .log-line .what { color: var(--ink-soft); }

  /* ---------- Future banner ---------- */
  .future {
    border: 1px dashed var(--line-strong);
    border-radius: 6px;
    padding: 22px 24px;
    background: var(--paper-raised);
  }
  .future .eyebrow { color: var(--thread); }
  .future ul { margin: 14px 0 0; padding-left: 18px; }
  .future li { font-size: 14.5px; color: var(--ink-soft); margin-bottom: 8px; }

  /* ---------- closing ---------- */
  .closing {
    max-width: 58ch;
    padding-top: 20px;
  }
  .closing .eyebrow { display: block; margin-bottom: 10px; }
  footer.page-end {
    margin-top: 40px;
    padding-top: 20px;
    border-top: 1px solid var(--line);
    font-size: 12.5px;
    color: var(--ink-faint);
    font-family: "IBM Plex Mono", monospace;
  }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div>
<div class="shell" id="edit-root">
  <nav class="toc" aria-label="Index">
    <div class="toc-brand"><span class="mark">§</span> The Book of Roles</div>
    <ol>
      <li><a href="#filosofia">The philosophy</a></li>
      <li><a href="#ruoli">Roles and hierarchy</a></li>
      <li><a href="#qualifiche">Qualifications</a></li>
      <li><a href="#ciclo">The lifecycle of a task</a></li>
      <li><a href="#uscite">The two honest exits</a></li>
      <li><a href="#crediti">Credits and reputation</a></li>
      <li><a href="#anonimo">Blind review</a></li>
      <li><a href="#log">Everything stays on record</a></li>
      <li><a href="#documenti">The documents: the next step</a></li>
      <li><a href="#seguito">What comes next</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Urdu Archive — Focolare</span>
      <h1>The Book of Roles</h1>
      <p class="lede">A guide to roles, qualifications, and workflow behind the Urdu Archive Manager — written for those who will use the system, not for those who built it. No technical term is used without first being explained.</p>
      <div class="meta">
        <span><b>Part</b> 1 of 2 — philosophy and how it works</span>
        <span><b>To follow</b> an operational guide by role</span>
      </div>
    </div>

    <section id="filosofia">
      <span class="eyebrow">01 — The why</span>
      <h2>An office with no walls left</h2>
      <p class="dek">The system of roles and "tasks" is not a technical whim: it is the digital translation of a way of working the team had already practiced for years, before it became impossible to do it in person.</p>
      <p>Ten years ago, work on the archive took place in a single room: a document passed, physically, from one tray to another — typed, checked, corrected, stamped, filed. Every step was visible because everyone was in the same room.</p>
      <p>Today the team is spread across several cities, and that room no longer exists. What has remained — and what this system deliberately rebuilds — is the very thing that made that way of working reliable: <strong>every step has someone responsible for it, a precise moment, and leaves a trace.</strong> "Tasks" (literally, "jobs") are the virtual trays; roles determine who has permission to move what from one tray to another.</p>
    </section>

    <section id="ruoli" class="wide">
      <span class="eyebrow">02 — The people</span>
      <h2>Roles and hierarchy</h2>
      <p class="dek">Four levels, each built on top of the previous one: whoever stands higher can do everything that whoever stands below can do, plus something more.</p>

      <div class="ladder">
        <div class="rung">
          <div><span class="role-name">User</span><span class="role-code">browsing</span></div>
          <ul>
            <li>Browses and searches the published archive</li>
            <li>Reports an issue or proposes a correction in chat</li>
            <li>Can submit a "Join the Team" request</li>
            <li>Cannot modify or create anything</li>
          </ul>
        </div>
        <div class="rung">
          <div><span class="role-name">Operator</span><span class="role-code">execution</span></div>
          <ul>
            <li>Takes on open <b>tasks</b>, according to their own qualifications</li>
            <li>Creates and corrects documents in the catalog</li>
            <li>Can flag a document for deletion (not delete it)</li>
          </ul>
        </div>
        <div class="rung">
          <div><span class="role-name">Coordinator</span><span class="role-code">supervision</span></div>
          <ul>
            <li>Creates new tasks and assigns them, or leaves them open</li>
            <li>Sees who is busy, who is behind schedule, and can <b>reclaim</b> a stalled task (with a penalty for whoever was holding it)</li>
            <li>Reviews applications from those who want to join the team ("Join the Team")</li>
            <li>Can also act as reviewer, if needed</li>
          </ul>
        </div>
        <div class="rung top">
          <div><span class="role-name">Admin</span><span class="role-code">final authority</span></div>
          <ul>
            <li>Manages users, roles, and qualifications for everyone</li>
            <li>Has the <b>final word</b> before a corrected piece of work goes public — can publish or reject, even against the reviewer's opinion</li>
            <li>Can delete permanently</li>
          </ul>
        </div>
      </div>
      <p class="cumulative-note">Each level includes the powers of the one below it: an Admin can do everything an Operator can do, but not the other way around.</p>
    </section>

    <section id="qualifiche">
      <span class="eyebrow">03 — Skills</span>
      <h2>Qualifications: a separate axis</h2>
      <p class="dek">The role tells you <em>how much authority</em> you have. The qualification tells you <em>what you're good at</em>. They are two different things, and they combine: an Operator can have one, more than one, or no qualification at all.</p>
      <p>Qualifications determine which tasks an Operator can even <strong>see</strong>: a translation task appears only to someone qualified as Translator, a review task only to someone qualified as Revisor. The rest of the tasks — proofreading, content creation, miscellaneous — remain visible to any Operator.</p>
      <div class="qual-grid">
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Translator</div>
          <p>Sees and can take translation tasks (Italian→Urdu, English→Urdu).</p>
        </div>
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Revisor</div>
          <p>Sees and can take review tasks; is also the one who judges other people's work, anonymously (see further below).</p>
        </div>
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Proof Reader</div>
          <p>Can only accept proofreading tasks, download the file flagged in the task, and re-upload it corrected for review — proofreading tasks nonetheless remain open to every Operator.</p>
        </div>
        <div class="qual-card">
          <div class="qname"><span class="dot"></span>Content Creator</div>
          <p>Skill recorded for reference — content-creation tasks nonetheless remain open to every Operator.</p>
        </div>
      </div>
      <p>Coordinator and Admin can always act as Revisor, even without the explicit qualification: this is meant to allow stepping in if the review queue grows too long.</p>
    </section>

    <section id="ciclo" class="wide">
      <span class="eyebrow">04 — The work</span>
      <h2>The lifecycle of a task</h2>
      <p class="dek">Every task passes through a fixed sequence of states. No one can skip a step: the system itself rejects a transition that doesn't follow the expected order.</p>

      <div class="diagram-wrap">
        <figure>
          <svg viewBox="0 0 860 300" role="img" aria-label="Flow diagram: a task moves from Open to Claimed to Submitted; the reviewer judges it Fail (it returns to Open as a new task, for another operator) or Ok/Ok with reservations (Approved); from Approved the Admin decides Reject (closes it as rejected) or Publish (Published, final state).">
            <defs>
              <marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                <path d="M0,0 L10,5 L0,10 z" fill="currentColor"></path>
              </marker>
            </defs>
            <g font-family="IBM Plex Mono, monospace" font-size="12" fill="currentColor">
              <!-- main spine nodes -->
              <g>
                <rect x="10" y="40" width="104" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="62" y="65" text-anchor="middle">Open</text>
              </g>
              <g>
                <rect x="184" y="40" width="104" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="236" y="65" text-anchor="middle">Claimed</text>
              </g>
              <g>
                <rect x="358" y="40" width="120" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="418" y="65" text-anchor="middle">Submitted</text>
              </g>
              <g>
                <rect x="548" y="40" width="120" height="42" rx="4" fill="none" stroke="currentColor"></rect>
                <text x="608" y="65" text-anchor="middle">Approved</text>
              </g>
              <g>
                <rect x="738" y="40" width="112" height="42" rx="4" stroke="var(--brass)" stroke-width="2" fill="none">
                  <animate attributeName="opacity" values="1" dur="1s" begin="0s" fill="freeze"></animate>
                </rect>
                <text x="794" y="65" text-anchor="middle" fill="var(--brass)" font-weight="700">Published</text>
              </g>

              <!-- spine arrows -->
              <line x1="114" y1="61" x2="180" y2="61" stroke="currentColor" marker-end="url(#arrow)"></line>
              <text x="147" y="52" text-anchor="middle" font-size="10.5">claim</text>

              <line x1="288" y1="61" x2="354" y2="61" stroke="currentColor" marker-end="url(#arrow)"></line>
              <text x="321" y="52" text-anchor="middle" font-size="10.5">submit</text>

              <line x1="478" y1="61" x2="544" y2="61" stroke="currentColor" marker-end="url(#arrow)"></line>
              <text x="511" y="52" text-anchor="middle" font-size="10.5">ok / ok, but...</text>

              <line x1="668" y1="61" x2="734" y2="61" stroke="var(--brass)" stroke-width="2" marker-end="url(#arrow)"></line>
              <text x="701" y="52" text-anchor="middle" font-size="10.5" fill="var(--brass)" font-weight="600">admin: publish</text>

              <!-- reviewer label above submitted->approved -->
              <text x="418" y="30" text-anchor="middle" font-size="10.5" fill="currentColor" opacity="0.75">Revisor's judgment</text>
              <text x="608" y="30" text-anchor="middle" font-size="10.5" fill="currentColor" opacity="0.75">Admin's decision</text>

              <!-- fail branch: submitted -> down -> new open task -->
              <path d="M 418 82 C 418 150, 62 150, 62 178" fill="none" stroke="var(--thread)" stroke-width="1.6" marker-end="url(#arrow)"></path>
              <text x="240" y="146" text-anchor="middle" font-size="10.5" fill="var(--thread)">fail — new task, another operator</text>
              <rect x="10" y="180" width="104" height="42" rx="4" fill="none" stroke="var(--thread)" stroke-dasharray="3 3"></rect>
              <text x="62" y="205" text-anchor="middle" fill="var(--thread)">Rejected</text>

              <!-- admin reject branch: approved -> down -> rejected (separate box) -->
              <path d="M 608 82 C 608 150, 700 150, 700 178" fill="none" stroke="var(--thread)" stroke-width="1.6" marker-end="url(#arrow)"></path>
              <text x="654" y="146" text-anchor="middle" font-size="10.5" fill="var(--thread)">admin: reject</text>
              <rect x="648" y="180" width="112" height="42" rx="4" fill="none" stroke="var(--thread)" stroke-dasharray="3 3"></rect>
              <text x="704" y="205" text-anchor="middle" fill="var(--thread)">Rejected</text>

              <text x="62" y="240" text-anchor="middle" font-size="10" opacity="0.7">final state</text>
              <text x="704" y="240" text-anchor="middle" font-size="10" opacity="0.7">final state — "recreate task" button, at the Admin's discretion</text>
            </g>
          </svg>
          <figcaption>The path of a task from creation to publication. The dashed red branch is where the work stops: a Fail from the Revisor <em>immediately and on its own</em> generates a new task open to others; a reject from the Admin does not — it leaves the choice of if and when to restart the work up to them.</figcaption>
        </figure>
      </div>

      <p>Two details that aren't obvious, but are decisive:</p>
      <p><strong>The Revisor's judgment stays pending.</strong> When the Revisor says "ok" or "ok, but with reservations," the task moves into the Admin's queue — but the operator's credits and score do not change yet. It is the Admin, with their final decision (publish or reject), who makes that judgment effective. This way, the Admin genuinely has the final word over everything that becomes public.</p>
      <p><strong>A Fail from the Revisor and a reject from the Admin are not the same thing.</strong> If the Revisor judges the work insufficient (Fail) and the task therefore needs to be redone, the system <em>on its own</em> creates a new open task — available to anyone except whoever made that attempt. If instead it's the Admin who stops a piece of work the Revisor had approved, nothing happens automatically: it's a rarer decision, and it's up to them to choose if and when to restart work on that document.</p>
    </section>

    <section id="uscite">
      <span class="eyebrow">05 — Honesty</span>
      <h2>The two exits from a claimed task</h2>
      <p class="dek">A task that has been claimed can become free again in two very different ways — and the system deliberately treats them differently.</p>
      <div class="exit-grid">
        <div class="exit-card calm">
          <span class="label">Give up — stepping back</span>
          <h3>The operator admits they can't get it done</h3>
          <p>An honest act, not a fault. Whoever gives up writes a line on why; the task becomes free again; <strong>no penalty</strong>. Staying stuck on a job you can't do well would be worse.</p>
        </div>
        <div class="exit-card warn">
          <span class="label">Reclaim — forced recovery</span>
          <h3>The Coordinator steps in</h3>
          <p>For an unanswered delay, or improper conduct. The Coordinator writes the reason; the task becomes free again; <strong>the operator receives a penalty</strong> on their reputation score.</p>
        </div>
      </div>
    </section>

    <section id="crediti">
      <span class="eyebrow">06 — The value of the work</span>
      <h2>Credits and reputation</h2>
      <p class="dek">Two different numbers, for two different questions: <em>how much have you worked</em>, and <em>how much can you be trusted</em>.</p>
      <dl>
        <div class="def-row">
          <dt>Credits</dt>
          <dd>They accumulate — they never go down on their own. Every task has a credit value set when it's created; the operator receives it only once the work is successfully published. It will serve as the basis for a future form of recognition for the work done.</dd>
        </div>
        <div class="def-row">
          <dt>Reputation</dt>
          <dd>
            A score from 0 to 100 that rises with work done well and falls for imprecise work, delays, or a task that had to be forcibly reclaimed. It starts from a neutral value (50), not from zero — no one begins "in debt."
            <div class="meter" aria-hidden="true">
              <span class="val">0</span>
              <span class="track"><span class="fill"></span></span>
              <span class="val">100</span>
            </div>
          </dd>
        </div>
      </dl>
      <p>An "ok, but with reservations" judgment from the Revisor is a special case: the work is still accepted and paid in credits, but the reputation drops slightly anyway — to keep attention on quality high, even when the final result is fine.</p>
      <div class="exit-card warn" style="margin-top:22px;">
        <span class="label">If reputation drops a lot</span>
        <h3>A warning for the team, not an automatic block</h3>
        <p>People who work on the archive do so as volunteers: an automatic, impersonal block would be the wrong response. Below a low threshold, the system simply flags the person in red to Coordinator and Admin — in the team overview — so they can notice and step in with a conversation, before the situation gets worse. Any more concrete decision always remains a human choice.</p>
      </div>
    </section>

    <section id="anonimo">
      <span class="eyebrow">07 — Impartiality</span>
      <h2>Blind review</h2>
      <p class="dek">Whoever judges a piece of work doesn't know who did it — not even if they wanted to find out from the data they receive.</p>
      <p>When a Revisor opens the queue of work to evaluate, they see the content of the task — what needed to be done, on which document, how many pages — but <strong>not the name of who carried it out</strong>. This isn't information hidden in the interface: it simply is never sent to their browser at all. A Revisor cannot even evaluate their own work, if they happened to have carried it out themselves.</p>
      <p>The purpose is to judge <em>the work</em>, not the person: no favoritism toward a friend, no prejudice against anyone else.</p>
    </section>

    <section id="log">
      <span class="eyebrow">08 — Memory</span>
      <h2>Everything stays on record</h2>
      <p class="dek">Every step that changes someone's credits or reputation leaves a permanent line: who, when, why.</p>
      <div class="log-strip">
        <div class="log-line"><span class="when">Aug 31</span><span class="who">Revisor</span><span class="what">"ok" judgment recorded, awaiting the Admin's decision</span></div>
        <div class="log-line"><span class="when">Aug 31</span><span class="who">Admin</span><span class="what">published — credits and reputation awarded</span></div>
        <div class="log-line"><span class="when">Aug 30</span><span class="who">Coordinator</span><span class="what">task reclaimed for delay — penalty applied, reason recorded</span></div>
        <div class="log-line"><span class="when">Aug 29</span><span class="who">Operator</span><span class="what">gave up the task — no penalty, reason recorded</span></div>
      </div>
      <p>This isn't an extra feature: it's the same logic as the old card signed at every step, simply digital — and for that reason impossible to lose or falsify.</p>
    </section>

    <section id="documenti" class="wide">
      <span class="eyebrow">09 — The file, not just the work</span>
      <h2>How a document is actually corrected</h2>
      <p class="dek">The task and review system governs <em>the work</em>. This section explains how the same logic applies <em>to the file itself</em> of a document being corrected — active and in use.</p>
      <p>When a task is linked to a document, the operator downloads the original directly from the task's page — the actual InPage file when available, otherwise the PDF already in the archive — corrects it, and re-uploads it. The corrected file enters the archive as a new "sibling" version of the original one, but remains <strong>invisible to everyone except the operator themselves and Coordinator/Admin</strong>, until it is approved — exactly the same confidentiality principle already seen for tasks.</p>
      <p>Approval happens in <strong>two separate steps</strong>, not one. First: when the Admin closes the task (after the Revisor's ok), credits and reputation are awarded right away — there's no need to wait for the file to be fully ready. Second, taking their time: the Admin prepares the final PDF and the definitive InPage file, uploads them, and only then makes the document truly public.</p>
      <div class="exit-card calm">
        <span class="label">A sibling, not a replacement</span>
        <h3>The old version doesn't disappear</h3>
        <p>When the new version goes public, the previous one <strong>remains visible too</strong> — it isn't hidden or deleted. They are two "sibling" versions of the same original document, exactly as already happens for a translation into another language or a different format: only which of the two is shown first in searches changes.</p>
      </div>
    </section>

    <section id="seguito" class="closing">
      <span class="eyebrow">10 — What to read now</span>
      <h2>A guide for every role</h2>
      <p>This document explains the general logic. For day-to-day practical operation, there is a dedicated operational guide for each role — User, Operator, Coordinator, Admin — plus a technical reference for those who develop and maintain the application.</p>
      <footer class="page-end">Focolare Movement — Urdu Archive · Document 1 of 6</footer>
    </section>
  </main>
</div>

</body>
</html>
$q_roles_en$, 0, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('user_en', 'en', 'user', 'User Guide', $q_user_en$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Guide to Browsing the Archive</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  main { max-width: 680px; margin: 0 auto; padding: 56px 24px 100px; }
  .cover { margin-bottom: 60px; }
  .cover .eyebrow { display: block; margin-bottom: 16px; }
  .cover h1 { font-size: clamp(30px,6vw,42px); line-height: 1.1; }
  .cover .lede { margin-top: 18px; font-size: 17px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 20px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { margin-bottom: 50px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(21px,3.4vw,25px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14.5px; margin: 8px 0 20px; }
  p { margin: 0 0 14px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 10px 0 10px 38px; border-top: 1px solid var(--line); font-size: 14.5px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 10px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 16px 18px; margin: 14px 0; }
  .card h3 { font-size: 15px; margin-bottom: 6px; }
  .card p { font-size: 13.5px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 14px 16px; margin: 14px 0; font-size: 13.5px; }
  .no-card b { color: var(--thread); }
  footer.page-end { margin-top: 50px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&amp;family=Archivo:wght@400;500;600;700&amp;family=IBM+Plex+Mono:wght@500;600&amp;display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div><main id="edit-root" contenteditable="false" spellcheck="false">
  <div class="cover">
    <span class="eyebrow">Urdu Archive — Operating Guide</span>
    <h1>Guide for archive users</h1>
    <p class="lede">Everything you can do as a User: search, read, download — and how to contribute without having to write a single line of code.</p>
    <div class="role-badge"><span class="dot"></span>Role: User</div>
  </div>

  <section>
    <span class="eyebrow">01</span>
    <h2>What you can do</h2>
    <p>Your access is read-only: you can search, read, and download any document already published in the archive, but you cannot create or modify one. This isn't an arbitrary technical limitation — it's designed this way so the catalog stays reliable: only authorized users (Operator and above) can edit it directly.</p>
    <ul class="step-list">
      <li><b>Dashboard</b> — search by title, author, category, date; open any document record to read its details.</li>
      <li><b>Print Reports / Hayat Index</b> — the same information, organized for printing or for the Hayat magazine.</li>
      <li><b>Download</b> — every published document has a file you can download directly from its record.</li>
    </ul>
  </section>

  <section>
    <span class="eyebrow">02</span>
    <h2>Reporting a problem</h2>
    <p class="dek">Found an error in a document's text, an error on the web page, a file that won't download? Say so in the <b>Chat</b> tab.</p>
    <ul class="step-list">
      <li>Go to the <b>Chat</b> tab, choose the type of report (Review, Download error, Bug, Suggestion), write your message — if it concerns a specific document, include its number.</li>
      <li>Your message reaches the Coordinator and Admin, who can reply to you directly in the same conversation.</li>
      <li>If the report requires actual intervention, whoever receives it can turn it into a <b>task</b> for the team of Operators, who will follow the correction process..</li>
    </ul>
    <div class="card">
      <h3>You'll receive a notification</h3>
      <p>When a reply arrives to your message, an alert will appear the next time you log in — no need to check the chat by hand every day.</p>
    </div>
  </section>

  <section>
    <span class="eyebrow">03</span>
    <h2>Applying to join the team</h2>
    <p class="dek">Want to move from browsing the archive to collaborating with our Team? It starts with "Join the Team".</p>
    <ul class="step-list">
      <li>Go to the <b>Join the Team</b> tab (visible only to those who still hold the User role) and fill out the application form.</li>
      <li>Your request will be reviewed and the Team will get in touch with you.</li>
      <li>If your request is approved, you'll be admitted to the <b>Operator</b> role, and from that point on you'll see new tabs appear (Tasks, Edit Records, and others), and this guide will no longer apply to you: the next one is the one for Operator.</li>
    </ul>
    <div class="no-card"><b>Note</b> —Approving an application requires several approvals. This isn't an oversight, it's a deliberate choice to make decisions together.</div>
  </section>

  <footer class="page-end">Focolare Movement — Urdu Archive · Operating Guide · User</footer>
</body>
</html>
$q_user_en$, 10, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('operator_en', 'en', 'operator', 'Operator Guide', $q_operator_en$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Operator Guide</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  .shell { display: grid; grid-template-columns: 220px minmax(0,1fr); max-width: 1080px; margin: 0 auto; }
  @media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
  nav.toc { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; padding: 40px 18px 40px 24px; border-right: 1px solid var(--line); }
  @media (max-width: 820px) { nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line); padding: 16px 20px; overflow-x: auto; white-space: nowrap; } }
  .toc-brand { font-family: "Fraunces",serif; font-size: 14px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono",monospace; }
  @media (max-width: 820px) { .toc-brand { display: inline-flex; margin: 0 20px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 820px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a { display: flex; gap: 7px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px; color: var(--ink-soft); text-decoration: none; font-size: 12.5px; }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before { content: counter(sec,decimal-leading-zero); font-family: "IBM Plex Mono",monospace; font-size: 10px; color: var(--ink-faint); }
  @media (max-width: 820px) { nav.toc a { white-space: nowrap; margin: 0; } }
  main { padding: 52px 40px 100px; min-width: 0; }
  @media (max-width: 820px) { main { padding: 36px 18px 90px; } }
  .cover { max-width: 620px; margin-bottom: 56px; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(28px,5vw,40px); line-height: 1.1; }
  .cover .lede { margin-top: 16px; font-size: 16.5px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 18px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { max-width: 640px; margin-bottom: 48px; scroll-margin-top: 24px; }
  section.wide { max-width: 780px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(20px,3.2vw,24px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14px; margin: 8px 0 18px; }
  p { margin: 0 0 13px; font-size: 15px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 9px 0 9px 34px; border-top: 1px solid var(--line); font-size: 14px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 9px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 15px 17px; margin: 12px 0; }
  .card h3 { font-size: 14.5px; margin-bottom: 5px; }
  .card p { font-size: 13px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 13px 15px; margin: 12px 0; font-size: 13px; }
  .no-card b { color: var(--thread); }
  .qual-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 10px 0 4px; }
  @media (max-width: 560px) { .qual-grid { grid-template-columns: 1fr; } }
  .qual-card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 4px; padding: 14px 16px; }
  .qual-card .qname { font-family: "Fraunces",serif; font-weight: 600; font-size: 14.5px; display: flex; align-items: center; gap: 7px; }
  .qual-card .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); flex: none; }
  .qual-card p { font-size: 12.5px; color: var(--ink-soft); margin-top: 6px; }
  .meter { display: flex; align-items: center; gap: 10px; margin: 10px 0; }
  .meter .track { flex: 1; max-width: 200px; height: 7px; border-radius: 4px; background: var(--line); overflow: hidden; }
  .meter .fill { height: 100%; width: 50%; border-radius: 4px; background: linear-gradient(90deg, var(--thread), var(--brass)); }
  .meter .val { font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  footer.page-end { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&amp;family=Archivo:wght@400;500;600;700&amp;family=IBM+Plex+Mono:wght@500;600&amp;display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div><div class="shell" id="edit-root" contenteditable="false" spellcheck="false">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Operator Guide</div>
    <ol>
      <li><a href="#panoramica">What you can do</a></li>
      <li><a href="#claim">Claiming a task</a></li>
      <li><a href="#correzione">Correcting a document</a></li>
      <li><a href="#uscite">Giving up or deferring</a></li>
      <li><a href="#qualifiche">Your qualifications</a></li>
      <li><a href="#revisore">If you are a Revisor</a></li>
      <li><a href="#punteggio">Your score</a></li>
      <li><a href="#catalogo">Editing the catalog</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Urdu Archive — Operator Guide</span>
      <h1>Guide for those working on tasks</h1>
      <p class="lede">How to claim a task, correct a document step by step, and earn credits.</p>
      <div class="role-badge"><span class="dot"></span>Role: Operator</div>
    </div>

    <section id="panoramica">
      <span class="eyebrow">01</span>
      <h2>What you can do beyond a User</h2>
      <p>You can create and edit documents in the catalog directly, and above all you can take on <b>tasks</b> from the board, the normal way work is distributed across the team. In the <b>Tasks</b> tab you find everything: open tasks available to claim, your tasks in progress, and the history of completed ones.</p>
    </section>

    <section id="claim">
      <span class="eyebrow">02</span>
      <h2>Claiming a task</h2>
      <ul class="step-list">
        <li>In "Open tasks" you only see the tasks you can actually claim — translation or review tasks appear only if you have the right qualification (see below).</li>
        <li>Choose a <b>realistic delivery date (deadline)</b> — once you have claimed the task, that date is fixed: you will no longer be able to change it afterwards.</li>
        <li>Press "Claim this task". From that moment the task appears in "My tasks".</li>
      </ul>
      <div class="no-card"><b>Only take on as many as you can complete</b> — a task left to expire without a response can be forcibly reclaimed by a Coordinator, with a penalty to your good practices.</div>
    </section>

    <section id="correzione" class="wide">
      <span class="eyebrow">03</span>
      <h2>Correcting a document</h2>
      <p class="dek">If the task is linked to a specific document, the work follows these steps, all from the same task card.</p>
      <ul class="step-list">
        <li><b>Download original file</b> — download the file to correct: the real InPage file when available, otherwise the PDF already in the archive.</li>
        <li>Correct the file <b>outside the app</b>, with your usual tools (InPage, Word...).</li>
        <li><b>Upload corrected file</b> — upload the corrected file. Until you do so, the "Submit for review" button remains disabled: you cannot submit work for review without having uploaded anything.</li>
        <li>You can re-upload multiple times before submitting — each upload replaces the previous one, copies do not accumulate.</li>
        <li><b>Submit for review</b> — once submitted, the task moves to the Revisor and you will no longer be able to edit it.</li>
      </ul>
      <div class="card">
        <h3>What the person reviewing you sees</h3>
        <p>The file you uploaded remains invisible to everyone except you and whoever is assigned to review and approve it. Even the reviewer <b>does not know it was you</b> who carried out that task (see "The Book of Roles" for why).</p>
      </div>
    </section>

    <section id="uscite">
      <span class="eyebrow">04</span>
      <h2>If you can't complete it</h2>
      <p class="dek">There is an honest way to step back from a claimed task. Use it before it becomes a problem, not after.</p>
      <ul class="step-list">
        <li><b>Give up this task</b> — available on every task you have in progress. Write a line about the reason, and the task becomes free again for someone else.</li>
        <li>This <b>carries no penalty</b>: admitting you can't manage it is an honest act, not a mistake.</li>
        <li>It is very different from having a task reclaimed for missing the deadline — that does carry a penalty, because the difference lies in having communicated in time.</li>
      </ul>
    </section>

    <section id="qualifiche" class="wide">
      <span class="eyebrow">05</span>
      <h2>Your qualifications</h2>
      <p class="dek">An Admin assigns them to you based on your skills — they determine which tasks you can see.</p>
      <div class="qual-grid">
        <div class="qual-card"><div class="qname"><span class="dot"></span>Translator</div><p>You see and can claim translation tasks (Italian→Urdu, English→Urdu).</p></div>
        <div class="qual-card"><div class="qname"><span class="dot"></span>Revisor</div><p>You see and can claim review tasks, and access the anonymous review queue (see below).</p></div>
        <div class="qual-card"><div class="qname"><span class="dot"></span>Proof Reader</div><p>Skill recorded for reference — proofreading tasks remain open to everyone regardless.</p></div>
        <div class="qual-card"><div class="qname"><span class="dot"></span>Content Creator</div><p>Skill recorded for reference — content creation tasks remain open to everyone regardless.</p></div>
      </div>
      <p>You can hold more than one at the same time. If you have none, you still see all tasks that do not require a specific qualification.</p>
    </section>

    <section id="revisore" class="wide">
      <span class="eyebrow">06</span>
      <h2>If you are a Revisor</h2>
      <p class="dek">In the Tasks tab an additional "Review queue" panel appears — visible only to those with this qualification.</p>
      <ul class="step-list">
        <li>You see tasks submitted for review: what needed to be done, on which document, how many pages — <b>never who did it</b>, and you will never even be able to see your own task there (the system automatically excludes it).</li>
        <li>If the task is linked to a document, an "Open corrected file" button lets you open the corrected file to check it.</li>
        <li>Give your verdict: <b>OK</b> (work done well), <b>OK, but...</b> (acceptable but imprecise — write why), or <b>Fail</b> (needs redoing — the system automatically creates a new task for someone else).</li>
        <li>The notes you write reach the operator — be specific and constructive, they will read them to understand what to improve.</li>
      </ul>
      <div class="no-card"><b>Your verdict does not immediately close the task</b> — it passes to the Admin, who decides whether to publish or reject it. The operator's score changes only at that point, not when you give your verdict.</div>
    </section>

    <section id="punteggio">
      <span class="eyebrow">07</span>
      <h2>Your score</h2>
      <p class="dek">At the top, next to your email, you find two numbers.</p>
      <p><b>Credits</b> — accumulate every time one of your tasks is successfully published. They never go down on their own.</p>
      <p><b>Good Practices</b> — a score from 0 to 100 that starts at 50 (a reward for good will, even before doing any work) and moves based on how you work.</p>
      <div class="meter" aria-hidden="true"><span class="val">0</span><span class="track"><span class="fill"></span></span><span class="val">100</span></div>
      <p>Press the <b>"Good practices"</b> button at the top at any time to review tips on how to work well and behaviors to avoid.</p>
    </section>

    <section id="catalogo">
      <span class="eyebrow">08</span>
      <h2>Editing the catalog directly</h2>
      <p>Besides tasks, you can also create or edit documents directly from the Dashboard or from "Edit Records" — useful for quick metadata corrections (title, category, author...) that do not require the full review workflow. For a substantial correction to a document's text, however, the correct path always remains the task workflow: it ensures someone else checks the work before it goes public.</p>
    </section>

    <footer class="page-end">Focolare Movement — Urdu Archive · Operator Guide · Operator</footer>
  </main>
</body>
</html>
$q_operator_en$, 20, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('coordinator_en', 'en', 'coordinator', 'Coordinator Guide', $q_coordinator_en$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Coordinator Guide</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  .shell { display: grid; grid-template-columns: 220px minmax(0,1fr); max-width: 1080px; margin: 0 auto; }
  @media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
  nav.toc { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; padding: 40px 18px 40px 24px; border-right: 1px solid var(--line); }
  @media (max-width: 820px) { nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line); padding: 16px 20px; overflow-x: auto; white-space: nowrap; } }
  .toc-brand { font-family: "Fraunces",serif; font-size: 14px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono",monospace; }
  @media (max-width: 820px) { .toc-brand { display: inline-flex; margin: 0 20px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 820px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a { display: flex; gap: 7px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px; color: var(--ink-soft); text-decoration: none; font-size: 12.5px; }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before { content: counter(sec,decimal-leading-zero); font-family: "IBM Plex Mono",monospace; font-size: 10px; color: var(--ink-faint); }
  @media (max-width: 820px) { nav.toc a { white-space: nowrap; margin: 0; } }
  main { padding: 52px 40px 100px; min-width: 0; }
  @media (max-width: 820px) { main { padding: 36px 18px 90px; } }
  .cover { max-width: 620px; margin-bottom: 56px; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(28px,5vw,40px); line-height: 1.1; }
  .cover .lede { margin-top: 16px; font-size: 16.5px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 18px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { max-width: 640px; margin-bottom: 48px; scroll-margin-top: 24px; }
  section.wide { max-width: 780px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(20px,3.2vw,24px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14px; margin: 8px 0 18px; }
  p { margin: 0 0 13px; font-size: 15px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 9px 0 9px 34px; border-top: 1px solid var(--line); font-size: 14px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 9px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 15px 17px; margin: 12px 0; }
  .card h3 { font-size: 14.5px; margin-bottom: 5px; }
  .card p { font-size: 13px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 13px 15px; margin: 12px 0; font-size: 13px; }
  .no-card b { color: var(--thread); }
  footer.page-end { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div>
<div class="shell" id="edit-root">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Coordinator Guide</div>
    <ol>
      <li><a href="#panoramica">What you can do beyond an Operator</a></li>
      <li><a href="#creare">Creating a task</a></li>
      <li><a href="#squadra">Managing the team</a></li>
      <li><a href="#messaggi">User messages</a></li>
      <li><a href="#candidature">Applications</a></li>
      <li><a href="#revisore">Acting as a Revisor too</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Urdu Archive — Operating Guide</span>
      <h1>Guide for those coordinating the team</h1>
      <p class="lede">How to create and assign tasks, keep an eye on who's busy, and handle requests coming in from the team.</p>
      <div class="role-badge"><span class="dot"></span>Role: Coordinator</div>
    </div>

    <section id="panoramica">
      <span class="eyebrow">01</span>
      <h2>What you can do beyond an Operator</h2>
      <p>A Coordinator inherits all the powers of an Operator (tasks, corrections, catalog) and adds the responsibility of <strong>organizing the team's work</strong>: deciding which tasks to create, who does them, stepping in if something gets stuck, and acting as the first filter on applications from people who want to join the team.</p>
    </section>

    <section id="creare" class="wide">
      <span class="eyebrow">02</span>
      <h2>Creating a task</h2>
      <p class="dek">From the Tasks tab, at the top you'll find the "New task" form — visible only to Coordinator and Admin.</p>
      <ul class="step-list">
        <li>Write a <b>title</b> and, if needed, a more detailed <b>description</b> of what needs to be done.</li>
        <li>Choose a <b>category</b> (Translation, Revision, Proof Reading, Content Creation, Other) — the Translation and Revision categories only show the task to people with the right qualification; the others remain open to anyone.</li>
        <li>If the task concerns a specific document, provide its <b>ID</b> — the page count fills in automatically if the document already has it recorded.</li>
        <li>Set the <b>credits</b> — how much this task will be worth once successfully completed (for now a number you decide, not calculated automatically).</li>
        <li>You can <b>assign it directly</b> to someone (the menu only shows people with a qualification compatible with the chosen category), or leave it open for anyone to pick up.</li>
      </ul>
      <div class="card"><h3>From a chat report</h3><p>If a user has flagged an issue, open Messages and press "Create task" on their row: title, description, and document fill in automatically from the report.</p></div>
    </section>

    <section id="squadra" class="wide">
      <span class="eyebrow">03</span>
      <h2>Managing the team</h2>
      <p class="dek">The "Team overview" panel shows tasks taken by everyone, not just your own.</p>
      <ul class="step-list">
        <li>See who has taken what, with what deadline, and whether it's <b>overdue</b> (red label).</li>
        <li>An operator with <b>low reputation</b> is flagged in red — this is a warning for you, not an automatic block: it means "worth talking about," not "forbidden."</li>
        <li><b>Reassign</b> — move a task from one operator to another (only among those with the right qualification).</li>
        <li><b>Reclaim (back to open)</b> — forcibly take back a task that has been stalled too long or handled poorly. You'll be asked for a reason: it gets recorded, and it comes with a reputation penalty for whoever was holding it.</li>
      </ul>
      <div class="no-card"><b>Different from giving up</b> — if the operator themselves honestly gives up (the "Give up" button on their side), there's no penalty. A forced reclaim on your part is for cases where there was no communication.</div>
    </section>

    <section id="messaggi">
      <span class="eyebrow">04</span>
      <h2>User messages</h2>
      <p>The Messages tab collects reports from all users (visible to Coordinator and Admin, not just Admin). You can reply directly, archive ("Dismiss") resolved ones, or turn one into a task with a click, as seen above.</p>
    </section>

    <section id="candidature">
      <span class="eyebrow">05</span>
      <h2>"Join the Team" applications</h2>
      <p>When a User applies to join the team, their request comes to you first. You can <b>recommend</b> or <b>reject</b> it — but you can't approve it outright on your own: it always needs confirmation from an Admin, deliberately so that no one can promote a friend without a second check.</p>
    </section>

    <section id="revisore">
      <span class="eyebrow">06</span>
      <h2>You can act as a Revisor too</h2>
      <p>Even without the specific qualification, a Coordinator can open the "Review queue" and give a verdict on pending tasks — useful if the queue grows too long. The same anonymity rule always applies: even you can't see who did the work you're reviewing, and you can't review your own task.</p>
    </section>

    <footer class="page-end">Focolare Movement — Urdu Archive · Operating Guide · Coordinator</footer>
  </main>
</div>

</body>
</html>
$q_coordinator_en$, 30, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('admin_en', 'en', 'admin', 'Admin Guide', $q_admin_en$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Admin Guide</title>
<style>
  :root {
    --paper: #eef0e6; --paper-raised: #f8f9f2; --paper-card: #f3f4ea;
    --ink: #1e2a1f; --ink-soft: #55624e; --ink-faint: #838f79;
    --line: #d2d6c1; --line-strong: #b9bea3;
    --brass: #8f6a24; --brass-strong: #6e5219;
    --thread: #7c3430; --thread-soft: #f3e4de; --sage-soft: #e2e7d4;
    --shadow: 0 1px 2px rgba(30,42,31,.06), 0 6px 20px rgba(30,42,31,.05);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
      --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
      --line: #303a29; --line-strong: #414d36;
      --brass: #d2a24e; --brass-strong: #e6b869;
      --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
    }
  }
  :root[data-theme="dark"] {
    --paper: #131810; --paper-raised: #1a2116; --paper-card: #1e261a;
    --ink: #e8e7d8; --ink-soft: #a8ae98; --ink-faint: #798270;
    --line: #303a29; --line-strong: #414d36;
    --brass: #d2a24e; --brass-strong: #e6b869;
    --thread: #cf7d78; --thread-soft: #2c1a18; --sage-soft: #232c1c;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px rgba(0,0,0,.35);
  }
  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body { margin: 0; background: var(--paper); color: var(--ink); font-family: "Archivo","Segoe UI",-apple-system,sans-serif; font-size: 16px; line-height: 1.6; }
  h1,h2,h3 { font-family: "Fraunces",Georgia,serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  .eyebrow { font-family: "IBM Plex Mono",monospace; font-size: 11.5px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass); font-weight: 600; }
  .shell { display: grid; grid-template-columns: 220px minmax(0,1fr); max-width: 1080px; margin: 0 auto; }
  @media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
  nav.toc { position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto; padding: 40px 18px 40px 24px; border-right: 1px solid var(--line); }
  @media (max-width: 820px) { nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line); padding: 16px 20px; overflow-x: auto; white-space: nowrap; } }
  .toc-brand { font-family: "Fraunces",serif; font-size: 14px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--brass); font-family: "IBM Plex Mono",monospace; }
  @media (max-width: 820px) { .toc-brand { display: inline-flex; margin: 0 20px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 820px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a { display: flex; gap: 7px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px; color: var(--ink-soft); text-decoration: none; font-size: 12.5px; }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before { content: counter(sec,decimal-leading-zero); font-family: "IBM Plex Mono",monospace; font-size: 10px; color: var(--ink-faint); }
  @media (max-width: 820px) { nav.toc a { white-space: nowrap; margin: 0; } }
  main { padding: 52px 40px 100px; min-width: 0; }
  @media (max-width: 820px) { main { padding: 36px 18px 90px; } }
  .cover { max-width: 620px; margin-bottom: 56px; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(28px,5vw,40px); line-height: 1.1; }
  .cover .lede { margin-top: 16px; font-size: 16.5px; color: var(--ink-soft); line-height: 1.6; }
  .role-badge { display: inline-flex; align-items: center; gap: 8px; margin-top: 18px; padding: 6px 14px; background: var(--paper-card); border: 1px solid var(--line); border-radius: 20px; font-family: "IBM Plex Mono",monospace; font-size: 12px; color: var(--ink-soft); }
  .role-badge .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brass); }
  section { max-width: 640px; margin-bottom: 48px; scroll-margin-top: 24px; }
  section.wide { max-width: 780px; }
  section .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(20px,3.2vw,24px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14px; margin: 8px 0 18px; }
  p { margin: 0 0 13px; font-size: 15px; } p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }
  .step-list { list-style: none; margin: 6px 0 0; padding: 0; counter-reset: step; }
  .step-list li { counter-increment: step; position: relative; padding: 9px 0 9px 34px; border-top: 1px solid var(--line); font-size: 14px; color: var(--ink-soft); }
  .step-list li:first-child { border-top: none; }
  .step-list li::before { content: counter(step); position: absolute; left: 0; top: 9px; font-family: "IBM Plex Mono",monospace; font-weight: 600; color: var(--brass); }
  .step-list li b { color: var(--ink); }
  .card { background: var(--paper-card); border: 1px solid var(--line); border-radius: 5px; padding: 15px 17px; margin: 12px 0; }
  .card h3 { font-size: 14.5px; margin-bottom: 5px; }
  .card p { font-size: 13px; color: var(--ink-soft); }
  .no-card { border-left: 3px solid var(--thread); background: var(--thread-soft); border-radius: 5px; padding: 13px 15px; margin: 12px 0; font-size: 13px; }
  .no-card b { color: var(--thread); }
  footer.page-end { margin-top: 40px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono",monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Archivo:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500;600&display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "Archivo",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--brass); border-color: var(--brass); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--brass); outline-offset: 6px; border-radius: 6px; }
</style>
</div>
<div class="shell" id="edit-root">
  <nav class="toc" aria-label="Indice">
    <div class="toc-brand"><span class="mark">§</span> Admin Guide</div>
    <ol>
      <li><a href="#panoramica">What you can do beyond that</a></li>
      <li><a href="#utenti">Users, roles, qualifications</a></li>
      <li><a href="#opzioni">The app's lists</a></li>
      <li><a href="#decisione">The final decision on tasks</a></li>
      <li><a href="#finalizzare">Publishing a document</a></li>
      <li><a href="#candidature">Approving applications</a></li>
      <li><a href="#annunci">Announcements and deletions</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Urdu Archive — Operating Guide</span>
      <h1>Guide for those who administer the system</h1>
      <p class="lede">The final word on everything that goes public — users, tasks, and documents.</p>
      <div class="role-badge"><span class="dot"></span>Role: Admin</div>
    </div>

    <section id="panoramica">
      <span class="eyebrow">01</span>
      <h2>What you can do beyond a Coordinator</h2>
      <p>An Admin inherits all the powers of Coordinator and Operator, and adds what no other role has: the <strong>final decision</strong> before a piece of work or a new version of a document actually goes public, along with managing users, roles, qualifications, the app's lists, and permanent deletions.</p>
    </section>

    <section id="utenti" class="wide">
      <span class="eyebrow">02</span>
      <h2>Users, roles, qualifications</h2>
      <p class="dek">In the Users tab you'll find the whole team in a single table.</p>
      <ul class="step-list">
        <li>Change anyone's <b>role</b> from the dropdown menu on their row (User / Operator / Coordinator / Admin).</li>
        <li>For Operators only, assign <b>qualifications</b> (Translator, Revisor, Proof Reader, Content Creator) with the checkboxes — a person can have more than one.</li>
        <li>See the <b>credits</b> and <b>reputation</b> each Operator has accumulated — a number in red means reputation below threshold, a signal to step in, not a block.</li>
        <li><b>Remove access</b> removes the role (the person loses access to the app, but their login account is not deleted).</li>
      </ul>
    </section>

    <section id="opzioni">
      <span class="eyebrow">03</span>
      <h2>The app's lists</h2>
      <p>The Options tab manages every dropdown list in the app — categories, authors, languages, available qualifications, task categories, and more. Add, rename, or delete an entry from there.</p>
      <div class="no-card"><b>Be careful with the Translator/Revisor codes</b> — these two qualifications are not just any labels: the system uses them internally to decide who sees which tasks. Renaming or deleting them from here silently breaks that control — if they need to change, check with the app's developer first.</div>
    </section>

    <section id="decisione" class="wide">
      <span class="eyebrow">04</span>
      <h2>The final decision on tasks</h2>
      <p class="dek">In the Tasks tab, the "Publish queue" panel shows the tasks a Revisor has already approved — they're just waiting on you.</p>
      <ul class="step-list">
        <li>You can open the corrected file ("Open corrected file") to check it yourself before deciding.</li>
        <li><b>Publish</b> — closes the task and immediately awards credits and reputation to the operator, according to the Revisor's judgment. The linked document, however, does not yet go public: it moves into a waiting state for finalization (see below).</li>
        <li><b>Reject</b> — overrides the Revisor's judgment. You'll be asked for a reason. The operator receives the same penalty they would have gotten from a fail, and the corrected file is discarded.</li>
      </ul>
      <div class="card"><h3>Why these are two separate things</h3><p>Closing the task (paying the operator) doesn't have to wait until you already have the final PDF ready — you can do it right away, and take care of the actual publishing at a later, calmer moment.</p></div>
    </section>

    <section id="finalizzare" class="wide">
      <span class="eyebrow">05</span>
      <h2>Publishing a document</h2>
      <p class="dek">Still in the Tasks tab, the "Documents ready to publish" panel lists documents whose task has already been closed, but which are not yet online.</p>
      <ul class="step-list">
        <li><b>Download draft file</b> — downloads the corrected draft from the operator, to prepare its final version (conversion to PDF, any final proofreading).</li>
        <li>Upload the <b>final PDF</b> — it goes into the same storage space as all the other published documents.</li>
        <li>Upload the <b>final InPage file</b> — it goes to Google Drive, into the same folder as all the originals; the first time, you'll be asked to sign in with an authorized Google account.</li>
        <li>Press <b>Publish</b>: the document becomes visible to everyone. The previous version <strong>does not disappear</strong> — it also stays public, it's simply no longer the one shown first in searches.</li>
      </ul>
    </section>

    <section id="candidature">
      <span class="eyebrow">06</span>
      <h2>Approving applications</h2>
      <p>When a Coordinator has already recommended a "Join the Team" application, it's up to you to give the final approval — only then does the person become an Operator. This double check is intentional: no one can promote someone on their own, not even a Coordinator.</p>
    </section>

    <section id="annunci">
      <span class="eyebrow">07</span>
      <h2>Announcements and deletions</h2>
      <p>The Announcements tab publishes a message that everyone will see the next time they log in — useful for general communications to the team. You are also the only role that can <b>permanently delete</b> a document or a task, rather than simply hiding it: an action that cannot be undone, to be used with care.</p>
    </section>

    <footer class="page-end">Focolare Movement — Urdu Archive · Operating Guide · Admin</footer>
  </main>
</div>

</body>
</html>
$q_admin_en$, 40, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('schema_en', 'en', null, 'Database Schema and Mechanisms', $q_schema_en$
<!doctype html>
<html>
<body><body><div id="page-static"><title>Database Schema and Mechanisms</title>
<style>
  :root {
    --paper: #eef1f3;
    --paper-raised: #f7f9fa;
    --paper-card: #e4e9ec;
    --ink: #182027;
    --ink-soft: #4e5a63;
    --ink-faint: #7c8892;
    --line: #d3d9dd;
    --line-strong: #b7c0c6;
    --accent: #0e7c86;
    --accent-strong: #0a5c64;
    --danger: #9c3d35;
    --danger-soft: #f3e3e1;
    --ok: #2f7a4f;
    --ok-soft: #e1efe4;
    --shadow: 0 1px 2px rgba(24, 32, 39, 0.06), 0 6px 20px rgba(24, 32, 39, 0.06);
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --paper: #11161a;
      --paper-raised: #171d22;
      --paper-card: #1c2329;
      --ink: #e7ecef;
      --ink-soft: #a7b1b8;
      --ink-faint: #74808a;
      --line: #2b333a;
      --line-strong: #3a444c;
      --accent: #3fb8c2;
      --accent-strong: #63cbd3;
      --danger: #d98079;
      --danger-soft: #2c1a19;
      --ok: #7fc99a;
      --ok-soft: #16261c;
      --shadow: 0 1px 2px rgba(0,0,0,.35), 0 8px 24px rgba(0,0,0,.4);
    }
  }
  :root[data-theme="dark"] {
    --paper: #11161a; --paper-raised: #171d22; --paper-card: #1c2329;
    --ink: #e7ecef; --ink-soft: #a7b1b8; --ink-faint: #74808a;
    --line: #2b333a; --line-strong: #3a444c;
    --accent: #3fb8c2; --accent-strong: #63cbd3;
    --danger: #d98079; --danger-soft: #2c1a19; --ok: #7fc99a; --ok-soft: #16261c;
    --shadow: 0 1px 2px rgba(0,0,0,.35), 0 8px 24px rgba(0,0,0,.4);
  }

  * { box-sizing: border-box; }
  html { scroll-behavior: smooth; }
  @media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } * { animation: none !important; transition: none !important; } }
  body {
    margin: 0; background: var(--paper); color: var(--ink);
    font-family: "IBM Plex Sans", "Segoe UI", -apple-system, sans-serif;
    font-size: 15.5px; line-height: 1.6; -webkit-font-smoothing: antialiased;
  }
  code, .mono { font-family: "IBM Plex Mono", ui-monospace, "Consolas", monospace; }
  h1, h2, h3 { font-family: "IBM Plex Sans", sans-serif; font-weight: 600; text-wrap: balance; margin: 0; color: var(--ink); }
  a { color: var(--accent-strong); }

  .shell { display: grid; grid-template-columns: 250px minmax(0,1fr); max-width: 1200px; margin: 0 auto; }
  @media (max-width: 880px) { .shell { grid-template-columns: 1fr; } }

  nav.toc {
    position: sticky; top: 0; align-self: start; height: 100vh; overflow-y: auto;
    padding: 36px 18px 36px 26px; border-right: 1px solid var(--line);
  }
  @media (max-width: 880px) {
    nav.toc { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--line);
      padding: 16px 20px; overflow-x: auto; white-space: nowrap; }
  }
  .toc-brand { font-weight: 700; font-size: 14px; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
  .toc-brand .mark { color: var(--accent); font-family: "IBM Plex Mono", monospace; }
  @media (max-width: 880px) { .toc-brand { display: inline-flex; margin: 0 22px 0 0; } }
  nav.toc ol { list-style: none; margin: 0; padding: 0; counter-reset: sec; display: flex; flex-direction: column; gap: 2px; }
  @media (max-width: 880px) { nav.toc ol { flex-direction: row; gap: 4px; } }
  nav.toc li { counter-increment: sec; }
  nav.toc a {
    display: flex; gap: 8px; padding: 5px 8px; margin: 0 -8px; border-radius: 3px;
    color: var(--ink-soft); text-decoration: none; font-size: 13px; line-height: 1.3;
  }
  nav.toc a:hover { background: var(--paper-card); color: var(--ink); }
  nav.toc a::before {
    content: counter(sec, decimal-leading-zero); font-family: "IBM Plex Mono", monospace;
    font-size: 10.5px; color: var(--ink-faint); flex: none; padding-top: 1px;
  }
  @media (max-width: 880px) { nav.toc a { white-space: nowrap; margin: 0; } }

  main { padding: 52px 44px 120px; min-width: 0; }
  @media (max-width: 880px) { main { padding: 36px 18px 90px; } }

  .cover { max-width: 680px; margin-bottom: 84px; }
  .eyebrow { font-family: "IBM Plex Mono", monospace; font-size: 11px; letter-spacing: .1em; text-transform: uppercase; color: var(--accent); font-weight: 600; }
  .cover .eyebrow { display: block; margin-bottom: 14px; }
  .cover h1 { font-size: clamp(30px, 4.6vw, 44px); line-height: 1.1; letter-spacing: -.01em; }
  .cover .lede { margin-top: 18px; font-size: 17px; line-height: 1.6; color: var(--ink-soft); max-width: 62ch; }
  .cover .meta { margin-top: 26px; display: flex; gap: 24px; flex-wrap: wrap; font-family: "IBM Plex Mono", monospace; font-size: 11.5px; color: var(--ink-faint); }
  .cover .meta b { color: var(--ink-soft); font-weight: 600; }

  section { max-width: 74ch; margin-bottom: 76px; scroll-margin-top: 28px; }
  section.wide { max-width: 940px; }
  section > .eyebrow { display: block; margin-bottom: 8px; }
  section h2 { font-size: clamp(22px, 3vw, 27px); margin-bottom: 6px; }
  section .dek { color: var(--ink-soft); font-size: 14.5px; margin: 8px 0 26px; max-width: 62ch; }
  h3 { font-size: 16px; margin: 30px 0 10px; }
  p { margin: 0 0 14px; }
  p:last-child { margin-bottom: 0; }
  strong { color: var(--ink); font-weight: 700; }

  /* schema table */
  .schema-table { width: 100%; border-collapse: collapse; font-size: 13px; margin: 6px 0 22px; }
  .schema-table caption { text-align: left; font-family: "IBM Plex Mono", monospace; font-size: 12.5px; font-weight: 600; color: var(--accent-strong); margin-bottom: 8px; caption-side: top; }
  .schema-table th, .schema-table td { border-top: 1px solid var(--line); padding: 7px 10px; text-align: left; vertical-align: top; }
  .schema-table th { font-family: "IBM Plex Mono", monospace; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; color: var(--ink-faint); font-weight: 600; }
  .schema-table td.col { font-family: "IBM Plex Mono", monospace; color: var(--accent-strong); white-space: nowrap; }
  .schema-table td.desc { color: var(--ink-soft); }
  .table-wrap { overflow-x: auto; border: 1px solid var(--line); border-radius: 6px; padding: 4px 14px; background: var(--paper-raised); margin: 8px 0 24px; }

  /* code block */
  pre.code { background: var(--paper-card); border: 1px solid var(--line); border-radius: 6px; padding: 14px 16px; overflow-x: auto; font-size: 12.5px; line-height: 1.55; margin: 4px 0 20px; }
  pre.code code { font-family: "IBM Plex Mono", monospace; color: var(--ink); }
  .tok-kw { color: var(--accent-strong); font-weight: 600; }
  .tok-com { color: var(--ink-faint); font-style: italic; }
  .tok-str { color: var(--ok); }

  /* rpc catalog card */
  .rpc-card { border: 1px solid var(--line); border-left: 3px solid var(--accent); border-radius: 5px; padding: 14px 18px; margin: 0 0 14px; background: var(--paper-card); }
  .rpc-card .sig { font-family: "IBM Plex Mono", monospace; font-size: 13px; font-weight: 600; color: var(--accent-strong); }
  .rpc-card .who { font-family: "IBM Plex Mono", monospace; font-size: 10.5px; text-transform: uppercase; letter-spacing: .06em; color: var(--ink-faint); margin-top: 4px; }
  .rpc-card p { font-size: 13.5px; color: var(--ink-soft); margin-top: 8px; }

  /* diagram */
  .diagram-wrap { background: var(--paper-raised); border: 1px solid var(--line); border-radius: 6px; padding: 26px 22px 16px; box-shadow: var(--shadow); margin: 6px 0 26px; overflow-x: auto; }
  figure { margin: 0; }
  figure svg { display: block; width: 100%; height: auto; overflow: visible; }
  figcaption { font-size: 12.5px; color: var(--ink-faint); margin-top: 12px; padding-top: 10px; border-top: 1px solid var(--line); }

  /* callouts */
  .callout { border-radius: 5px; padding: 14px 16px; margin: 6px 0 20px; border: 1px solid var(--line); font-size: 13.5px; }
  .callout.security { background: var(--danger-soft); border-color: color-mix(in srgb, var(--danger) 35%, var(--line)); }
  .callout.security .label { color: var(--danger); }
  .callout.note { background: var(--ok-soft); border-color: color-mix(in srgb, var(--ok) 35%, var(--line)); }
  .callout.note .label { color: var(--ok); }
  .callout .label { font-family: "IBM Plex Mono", monospace; font-size: 10.5px; letter-spacing: .08em; text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 6px; }

  ul.plain { margin: 4px 0 16px; padding-left: 20px; }
  ul.plain li { margin-bottom: 6px; font-size: 14px; color: var(--ink-soft); }
  ul.plain li b { color: var(--ink); }

  .migration-index { width: 100%; border-collapse: collapse; font-size: 12.5px; }
  .migration-index th, .migration-index td { border-top: 1px solid var(--line); padding: 6px 10px; text-align: left; }
  .migration-index th { font-family: "IBM Plex Mono", monospace; font-size: 10.5px; text-transform: uppercase; color: var(--ink-faint); }
  .migration-index td.file { font-family: "IBM Plex Mono", monospace; color: var(--accent-strong); white-space: nowrap; }

  footer.page-end { margin-top: 30px; padding-top: 18px; border-top: 1px solid var(--line); font-size: 12px; color: var(--ink-faint); font-family: "IBM Plex Mono", monospace; }
</style>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&amp;family=IBM+Plex+Mono:wght@400;500;600&amp;display=swap">

<style>
  #edit-bar { position: fixed; bottom: 18px; right: 18px; z-index: 1000; display: flex; align-items: center; gap: 8px; background: var(--paper-raised); border: 1px solid var(--line-strong); border-radius: 8px; padding: 8px 10px; box-shadow: var(--shadow); font-family: "IBM Plex Sans",sans-serif; }
  #edit-bar button { font-family: inherit; font-size: 12.5px; font-weight: 600; border: 1px solid var(--line-strong); background: var(--paper-card); color: var(--ink); border-radius: 5px; padding: 6px 12px; cursor: pointer; }
  #edit-bar button.primary { background: var(--accent); border-color: var(--accent); color: #fff; }
  #edit-bar #edit-status { font-family: "IBM Plex Mono",monospace; font-size: 11px; color: var(--ink-faint); max-width: 220px; }
  #edit-root[contenteditable="true"] { outline: 2px dashed var(--accent); outline-offset: 6px; border-radius: 6px; }
</style>
</div><div class="shell" id="edit-root" contenteditable="false" spellcheck="false">
  <nav class="toc" aria-label="Index">
    <div class="toc-brand"><span class="mark">#</span> Database Schema</div>
    <ol>
      <li><a href="#overview">Architecture</a></li>
      <li><a href="#ruoli">Roles and permissions (RLS)</a></li>
      <li><a href="#schema">Main tables</a></li>
      <li><a href="#task-fsm">State machine: Task</a></li>
      <li><a href="#task-rpc">RPC functions: Task</a></li>
      <li><a href="#doc-fsm">State machine: Document</a></li>
      <li><a href="#doc-rpc">RPC functions: Document</a></li>
      <li><a href="#ledger">Credits and reputation</a></li>
      <li><a href="#storage">Storage and Google Drive</a></li>
      <li><a href="#migrazioni">Migration index</a></li>
    </ol>
  </nav>

  <main>
    <div class="cover">
      <span class="eyebrow">Urdu Archive Manager — technical reference</span>
      <h1>Database Schema and Mechanisms</h1>
      <p class="lede">Technical reference for anyone developing or maintaining the application: tables, security policies (RLS), database functions (RPC), and the two state machines — task and document — that govern the workflow.</p>
      <div class="meta">
        <span><b>Backend</b> Supabase (Postgres + Auth + Storage)</span>
        <span><b>Repo</b> mediafocolarepak/Urdu-Archive</span>
        <span><b>Latest migration</b> 50_two_step_publish_and_versioning.sql</span>
      </div>
    </div>

    <section id="overview">
      <span class="eyebrow">01</span>
      <h2>Architecture</h2>
      <p class="dek">No application server: the logic lives in the database.</p>
      <p>The app is static HTML/JavaScript (no framework, no bundler), published on GitHub Pages. There is no intermediate application server: the browser talks directly to Supabase (Postgres + Auth + Storage) via the `supabase-js` client. This has a precise consequence: <strong>security cannot depend on the JavaScript code</strong>, because anyone can read or modify it in the browser's developer tools. Every rule that truly matters — who can see a row, who can modify it, who can perform an action — is enforced by the database itself through <strong>Row Level Security (RLS)</strong> and <code>SECURITY DEFINER</code> functions. The interface merely mirrors those rules for the user's convenience; it does not replace them.</p>
      <p>Two external integrations, both toward Google Drive: one read-only with a public API key (for historical PDFs and the original InPage files, both in folders shared "anyone with the link"), one write-enabled with the user's OAuth consent (used by the InPage Converter and by the upload of the final InPage file at the end of correction).</p>
    </section>

    <section id="ruoli" class="wide">
      <span class="eyebrow">02</span>
      <h2>Roles and permissions (RLS)</h2>
      <p class="dek">A single SQL function decides who can do what; every policy calls it.</p>
      <p>The roles (<code>user_roles.role</code>) form an increasing scale: <code>user</code> &lt; <code>operator</code> &lt; <code>coordinator</code> &lt; <code>admin</code>. Almost every RLS policy in the database calls the same function:</p>
      <pre class="code"><code><span class="tok-kw">create or replace function</span> public.current_role_is(min_role <span class="tok-kw">text</span>)
<span class="tok-kw">returns boolean language sql security definer stable as</span> $$
  <span class="tok-kw">select case</span>
    <span class="tok-kw">when</span> min_role = <span class="tok-str">'operator'</span> <span class="tok-kw">then exists</span> (... <span class="tok-kw">role in</span> (<span class="tok-str">'operator','coordinator','admin'</span>))
    <span class="tok-kw">when</span> min_role = <span class="tok-str">'coordinator'</span> <span class="tok-kw">then exists</span> (... <span class="tok-kw">role in</span> (<span class="tok-str">'coordinator','admin'</span>))
    <span class="tok-kw">when</span> min_role = <span class="tok-str">'admin'</span> <span class="tok-kw">then exists</span> (... <span class="tok-kw">role</span> = <span class="tok-str">'admin'</span>)
  <span class="tok-kw">end</span>;
$$;</code></pre>
      <p>A policy such as <code>using (current_role_is('coordinator'))</code> therefore means "Coordinator or higher". <strong>Qualifications</strong> (Translator, Revisor, Proof Reader, Content Creator) are an independent axis — not a level on the scale, but labels in <code>user_qualifications</code> (many-to-many, an Operator can have more than one), checked by a second function, <code>user_qualifies_for_category(uid, cat)</code>, used to decide whether an Operator can see/claim a task in a given category.</p>
      <div class="callout security">
        <span class="label">Critical point</span>
        The strings <code>'TRANSLATOR'</code> and <code>'REVISOR'</code> are written literally inside the SQL functions. The list of qualifications can be edited by Admin via Options (table <code>option_lists</code>), but renaming or deleting those two codes from there <strong>silently breaks</strong> the check — no error, the tasks in that category simply stop being filtered correctly.
      </div>
    </section>

    <section id="schema" class="wide">
      <span class="eyebrow">03</span>
      <h2>Main tables</h2>
      <p class="dek">Only the columns relevant to understanding how it works — not a complete schema dump.</p>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>documents — the archive catalog</caption>
        <thead><tr><th>Column</th><th>Meaning</th></tr></thead>
        <tbody>
          <tr><td class="col">document_id</td><td class="desc">Primary key, an integer assigned manually by the app (not a sequence — see §Task RPC for how a new id is computed)</td></tr>
          <tr><td class="col">work_id</td><td class="desc">Groups the "sibling" versions of the same Work (different languages, or — since 2026-08-31 — versions corrected over time). See §Document: state machine</td></tr>
          <tr><td class="col">is_preferred</td><td class="desc">Which sibling is the one shown by default in lists</td></tr>
          <tr><td class="col">workflow_status</td><td class="desc"><code>published</code> / <code>revision</code> / <code>pending_publish</code> / <code>removed</code> — governs actual visibility (RLS), not just a UI filter</td></tr>
          <tr><td class="col">storage_path / file_name</td><td class="desc">Reserved for the <strong>final published PDF</strong> (Supabase Storage, bucket <code>archive-files</code>)</td></tr>
          <tr><td class="col">draft_inp_path</td><td class="desc">Raw InPage file uploaded by an Operator during a correction task (Storage) — never the same field as the PDF</td></tr>
          <tr><td class="col">original_inp_file_name</td><td class="desc">Historical unprefixed name, for reference only — <em>not</em> used to look up the file</td></tr>
          <tr><td class="col">renamed_inp_file_name</td><td class="desc">Actual name on Google Drive (<code>&lt;document_id&gt;-...</code>), the one actually used for downloading</td></tr>
          <tr><td class="col">source_task_id</td><td class="desc">If the record is a correction candidate: the task that generated it</td></tr>
          <tr><td class="col">category, author, main_topic, source, language, ...</td><td class="desc">Cataloging fields, vocabulary in <code>option_lists</code></td></tr>
        </tbody>
      </table>
      </div>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>tasks — the job board</caption>
        <thead><tr><th>Column</th><th>Meaning</th></tr></thead>
        <tbody>
          <tr><td class="col">status</td><td class="desc"><code>open / claimed / submitted / approved / rejected / published</code> — see §Task: state machine</td></tr>
          <tr><td class="col">category</td><td class="desc">Fixed at creation, never rewritten — governs visibility by qualification (§Roles)</td></tr>
          <tr><td class="col">document_id, document_pages, credits</td><td class="desc">Link to the document and the task's "price" (a fixed value decided at creation, not computed by a formula)</td></tr>
          <tr><td class="col">claimed_by / claimed_by_email</td><td class="desc"><strong>Never exposed to a Reviewer</strong> — see <code>get_review_queue()</code></td></tr>
          <tr><td class="col">excluded_operator</td><td class="desc">On a task born from a fail: the operator who failed, excluded from taking it up again</td></tr>
          <tr><td class="col">retry_of_task_id</td><td class="desc">Links a regenerated task to the original failed attempt (only on a Reviewer fail, not on an Admin reject)</td></tr>
          <tr><td class="col">review_verdict, review_notes, reviewed_by*</td><td class="desc">The Reviewer's verdict — does not yet touch credits/reputation on its own</td></tr>
        </tbody>
      </table>
      </div>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>task_outcome_events — the ledger (source of truth)</caption>
        <thead><tr><th>Column</th><th>Meaning</th></tr></thead>
        <tbody>
          <tr><td class="col">task_id, user_id</td><td class="desc">Which task, which operator is rewarded/penalized</td></tr>
          <tr><td class="col">event_type</td><td class="desc">Free text: <code>review_ok</code>, <code>review_ok_but</code>, <code>review_fail</code>, <code>admin_rejected</code>, <code>reclaimed</code>, <code>given_up</code></td></tr>
          <tr><td class="col">credit_delta, reputation_delta</td><td class="desc">Applied to <code>user_roles.credits</code>/<code>reputation</code> by a trigger, never written by hand</td></tr>
          <tr><td class="col">created_by_email, note</td><td class="desc">Who generated the event and why — the human-readable audit trail</td></tr>
        </tbody>
      </table>
      </div>

      <div class="table-wrap">
      <table class="schema-table">
        <caption>Supporting tables</caption>
        <thead><tr><th>Table</th><th>Role</th></tr></thead>
        <tbody>
          <tr><td class="col">user_roles</td><td class="desc">One role per user, plus <code>credits</code>/<code>reputation</code> (added in step 1 of the task pipeline)</td></tr>
          <tr><td class="col">user_qualifications</td><td class="desc">Many-to-many user↔qualification</td></tr>
          <tr><td class="col">option_lists</td><td class="desc">Generic vocabulary reused for <em>every</em> dropdown list in the app (category, author, qualifications, task category, workflow_status...) — <code>(list_name, code)</code> primary key</td></tr>
          <tr><td class="col">works</td><td class="desc">A Work = a piece; <code>documents.work_id</code> references it to group versions</td></tr>
          <tr><td class="col">chat_messages</td><td class="desc">User↔team ticketing, with a "Create task" button linked to <code>State.taskPrefill</code> on the client side (not an actual DB link)</td></tr>
          <tr><td class="col">collaboration_applications</td><td class="desc">"Join the Team" applications (User → Operator)</td></tr>
        </tbody>
      </table>
      </div>
    </section>

    <section id="task-fsm" class="wide">
      <span class="eyebrow">04</span>
      <h2>State machine: Task</h2>
      <p class="dek">Enforced at the database level, not just in JavaScript.</p>
      <div class="diagram-wrap">
        <figure>
          <svg viewBox="0 0 900 260" role="img" aria-label="The tasks.status field moves from open to claimed to submitted; the Reviewer decides fail (returns to open as a new task for another operator) or ok/ok_but (approved); from approved the Admin decides reject (closes as rejected, no credit) or publish (closes the task, published, credits assigned). A database trigger rejects any other transition.">
            <defs>
              <marker id="arrow2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                <path d="M0,0 L10,5 L0,10 z" fill="currentColor"></path>
              </marker>
            </defs>
            <g font-family="IBM Plex Mono, monospace" font-size="12" fill="currentColor">
              <rect x="10" y="40" width="100" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="60" y="64" text-anchor="middle">open</text>
              <rect x="178" y="40" width="100" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="228" y="64" text-anchor="middle">claimed</text>
              <rect x="346" y="40" width="116" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="404" y="64" text-anchor="middle">submitted</text>
              <rect x="530" y="40" width="116" height="40" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="588" y="64" text-anchor="middle">approved</text>
              <rect x="746" y="40" width="110" height="40" rx="4" stroke="var(--accent)" stroke-width="2" fill="none"></rect>
              <text x="801" y="64" text-anchor="middle" fill="var(--accent)" font-weight="700">published</text>

              <line x1="110" y1="60" x2="174" y2="60" stroke="currentColor" marker-end="url(#arrow2)"></line>
              <text x="142" y="51" text-anchor="middle" font-size="10">claim</text>
              <line x1="278" y1="60" x2="342" y2="60" stroke="currentColor" marker-end="url(#arrow2)"></line>
              <text x="310" y="51" text-anchor="middle" font-size="10">submit</text>
              <line x1="462" y1="60" x2="526" y2="60" stroke="currentColor" marker-end="url(#arrow2)"></line>
              <text x="494" y="51" text-anchor="middle" font-size="10">ok / ok_but</text>
              <line x1="646" y1="60" x2="742" y2="60" stroke="var(--accent)" stroke-width="2" marker-end="url(#arrow2)"></line>
              <text x="694" y="51" text-anchor="middle" font-size="10" fill="var(--accent)">admin: publish</text>

              <text x="404" y="30" text-anchor="middle" font-size="10.5" opacity=".75">Reviewer's verdict</text>
              <text x="588" y="30" text-anchor="middle" font-size="10.5" opacity=".75">Admin's decision</text>

              <path d="M 404 82 C 404 150, 60 150, 60 178" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow2)"></path>
              <text x="230" y="146" text-anchor="middle" font-size="10" fill="var(--danger)">fail — new open task, another operator</text>
              <rect x="10" y="180" width="100" height="40" rx="4" fill="none" stroke="var(--danger)" stroke-dasharray="3 3"></rect>
              <text x="60" y="204" text-anchor="middle" fill="var(--danger)">rejected</text>

              <path d="M 588 82 C 588 150, 700 150, 700 178" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow2)"></path>
              <text x="644" y="146" text-anchor="middle" font-size="10" fill="var(--danger)">admin: reject</text>
              <rect x="650" y="180" width="100" height="40" rx="4" fill="none" stroke="var(--danger)" stroke-dasharray="3 3"></rect>
              <text x="700" y="204" text-anchor="middle" fill="var(--danger)">rejected</text>

              <path d="M 228 82 C 228 110, 110 110, 110 60" fill="none" stroke="currentColor" stroke-width="1.2" marker-end="url(#arrow2)" opacity=".6"></path>
              <text x="169" y="112" text-anchor="middle" font-size="9.5" opacity=".6">give_up / reclaim</text>
            </g>
          </svg>
          <figcaption>Path of <code>tasks.status</code>. Every transition is checked by a trigger (<code>validate_task_status_transition</code>) — any other combination is rejected by the database, regardless of what the client tries to do.</figcaption>
        </figure>
      </div>
      <p>Two details not obvious from the diagram alone: <strong>the Reviewer's verdict does not touch credits/reputation</strong> — only the Admin's decision does (see <code>admin_decide_task</code> below). And <strong>a Reviewer fail and an Admin reject are not equivalent</strong>: the former <em>automatically</em> generates a new task; the latter does not (the Admin chooses whether and when to recreate it, from the "Completed" list).</p>
    </section>

    <section id="task-rpc" class="wide">
      <span class="eyebrow">05</span>
      <h2>RPC functions: Task</h2>
      <p class="dek">Every transition that touches credits or reputation goes through a <code>SECURITY DEFINER</code> function, never a direct update from the client.</p>

      <div class="rpc-card">
        <div class="sig">give_up_task(p_task_id, p_note)</div>
        <div class="who">callable by: the operator who claimed the task</div>
        <p><code>claimed → open</code>. Honest, voluntary withdrawal — <strong>no penalty</strong> (delta 0/0), but still logged in the ledger for the record.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">reclaim_task(p_task_id, p_note)</div>
        <div class="who">callable by: Coordinator+</div>
        <p><code>claimed → open</code>, forced. For unresponsive delay or improper conduct — <strong>-10 reputation</strong>, mandatory (cannot be bypassed by calling a direct update, because no policy allows it).</p>
      </div>
      <div class="rpc-card">
        <div class="sig">get_review_queue()</div>
        <div class="who">callable by: a qualified Reviewer, or Coordinator+</div>
        <p>Returns <code>submitted</code> tasks — <strong>never <code>claimed_by</code>/<code>claimed_by_email</code></strong>. It is not a client-side filter: those columns simply are not included in the internal SQL query. It also excludes tasks the caller performed themselves.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">submit_task_review(p_task_id, p_verdict, p_notes)</div>
        <div class="who">callable by: a qualified Reviewer, or Coordinator+ — never the claimant</div>
        <p><code>verdict = 'fail'</code> → <code>submitted → rejected</code>, -10 reputation applied <strong>immediately</strong>, plus automatic creation of a new open task (same document/category, <code>excluded_operator</code> = whoever failed).<br><code>verdict ∈ {'ok','ok_but'}</code> → <code>submitted → approved</code>, but <strong>no delta yet</strong> — it stays pending until the Admin's decision.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">admin_decide_task(p_task_id, p_decision, p_note)</div>
        <div class="who">callable by: Admin only (not Coordinator)</div>
        <p><code>p_decision = 'publish'</code> → <code>approved → published</code>, applies the delta implied by the Reviewer's verdict (+10, or -5 if it was "ok, but..."), and moves the linked candidate document to <code>pending_publish</code> (not yet visible).<br><code>p_decision = 'reject'</code> → <code>approved → rejected</code>, same penalty as a fail (-10, 0 credits), overrides the Reviewer; the candidate document moves to <code>removed</code>.</p>
      </div>
    </section>

    <section id="doc-fsm" class="wide">
      <span class="eyebrow">06</span>
      <h2>State machine: Document</h2>
      <p class="dek"><code>documents.workflow_status</code> — an axis independent from the task that generated it.</p>
      <div class="diagram-wrap">
        <figure>
          <svg viewBox="0 0 900 220" role="img" aria-label="A new document record is born with status revision, visible only to its operator and to Coordinator/Admin. If the linked task is closed with an ok outcome by the admin, it moves to pending_publish. If the Reviewer fails the task or the Admin rejects it, it moves to removed, visible only to Admin. From pending_publish, when the Admin uploads the final PDF and InPage files and confirms, the document moves to published and becomes visible to everyone, without hiding the previous version of the same Work.">
            <defs>
              <marker id="arrow3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
                <path d="M0,0 L10,5 L0,10 z" fill="currentColor"></path>
              </marker>
            </defs>
            <g font-family="IBM Plex Mono, monospace" font-size="12" fill="currentColor">
              <rect x="10" y="30" width="120" height="42" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="70" y="55" text-anchor="middle">revision</text>
              <text x="70" y="88" text-anchor="middle" font-size="9.5" opacity=".7">operator + Coord/Admin</text>

              <rect x="330" y="30" width="150" height="42" rx="4" fill="none" stroke="currentColor"></rect>
              <text x="405" y="55" text-anchor="middle">pending_publish</text>
              <text x="405" y="88" text-anchor="middle" font-size="9.5" opacity=".7">task closed, doc not yet live</text>

              <rect x="700" y="30" width="140" height="42" rx="4" stroke="var(--accent)" stroke-width="2" fill="none"></rect>
              <text x="770" y="55" text-anchor="middle" fill="var(--accent)" font-weight="700">published</text>
              <text x="770" y="88" text-anchor="middle" font-size="9.5" opacity=".7">is_preferred = true</text>

              <rect x="330" y="150" width="120" height="42" rx="4" fill="none" stroke="var(--danger)" stroke-dasharray="3 3"></rect>
              <text x="390" y="175" text-anchor="middle" fill="var(--danger)">removed</text>
              <text x="390" y="205" text-anchor="middle" font-size="9.5" opacity=".7">Admin only</text>

              <line x1="130" y1="51" x2="326" y2="51" stroke="currentColor" marker-end="url(#arrow3)"></line>
              <text x="228" y="42" text-anchor="middle" font-size="10">admin_decide_task('publish')</text>

              <path d="M 130 60 C 220 110, 260 110, 326 165" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow3)"></path>
              <text x="220" y="128" text-anchor="middle" font-size="9.5" fill="var(--danger)">Reviewer: fail</text>

              <path d="M 405 72 C 405 105, 400 120, 395 146" fill="none" stroke="var(--danger)" stroke-width="1.6" marker-end="url(#arrow3)"></path>
              <text x="440" y="112" text-anchor="middle" font-size="9.5" fill="var(--danger)">admin: reject</text>

              <line x1="480" y1="51" x2="696" y2="51" stroke="var(--accent)" stroke-width="2" marker-end="url(#arrow3)"></line>
              <text x="588" y="42" text-anchor="middle" font-size="10" fill="var(--accent)">finalize_document_publish()</text>
            </g>
          </svg>
          <figcaption>Path of <code>documents.workflow_status</code> for a record "candidate" for correction. The original document, meanwhile, always remains <code>published</code> — even after the new version itself becomes <code>published</code> (see below: only <code>is_preferred</code> switches over, never the visibility).</figcaption>
        </figure>
      </div>
      <div class="callout note">
        <span class="label">Not a replacement, a sibling</span>
        When <code>finalize_document_publish()</code> makes the new version public, the original does <strong>not</strong> move to <code>removed</code>. Both remain <code>published</code> and visible — they are sibling versions of the same <code>work_id</code>, the same mechanism already used for language/format variants. Only <code>is_preferred</code> shifts to the new version, so that is the one shown by default.
      </div>
    </section>

    <section id="doc-rpc" class="wide">
      <span class="eyebrow">07</span>
      <h2>RPC functions: Document</h2>
      <div class="rpc-card">
        <div class="sig">get_review_document(p_document_id)</div>
        <div class="who">callable by: a qualified Reviewer, or Coordinator+</div>
        <p>Returns the fields of a <code>revision</code> document needed to check it (title, category, <code>draft_inp_path</code>) — <strong>never <code>operator</code>/<code>updated_by</code></strong>, the same anonymity principle as the task.</p>
      </div>
      <div class="rpc-card">
        <div class="sig">finalize_document_publish(p_document_id)</div>
        <div class="who">callable by: Admin only</div>
        <p>Second step, separate from closing the task: promotes the document to <code>published</code> + <code>is_preferred = true</code>, and demotes (does not hide) any other sibling of the same <code>work_id</code> that previously had <code>is_preferred = true</code>.</p>
      </div>
      <div class="callout security">
        <span class="label">Why two separate steps</span>
        Closing the task (credits/reputation) and publishing the document (final files ready) were deliberately decoupled: the Admin does not have to wait for the PDF to be ready in order to close the task and pay the operator. The "Documents ready to publish" panel (Tasks tab) lists the documents sitting at <code>pending_publish</code>.
      </div>
    </section>

    <section id="ledger">
      <span class="eyebrow">08</span>
      <h2>Credits and reputation</h2>
      <p class="dek">A single trigger, a single source of truth.</p>
      <p><code>user_roles.credits</code> (starts at 0, only goes up) and <code>user_roles.reputation</code> (0–100, starts at 50) are never written directly. Every row inserted into <code>task_outcome_events</code> triggers:</p>
      <pre class="code"><code><span class="tok-com">-- after insert on task_outcome_events, per row</span>
<span class="tok-kw">update</span> user_roles
<span class="tok-kw">set</span> credits = credits + new.credit_delta,
    reputation = <span class="tok-kw">greatest</span>(<span class="tok-kw">0</span>, <span class="tok-kw">least</span>(<span class="tok-kw">100</span>, reputation + new.reputation_delta))
<span class="tok-kw">where</span> user_id = new.user_id;</code></pre>
      <p>This makes the ledger the only place you need to look at to understand "why someone's score changed" — the two fields on <code>user_roles</code> are just a cache for quick reads (shown in the widget at the top, only for the Operator role).</p>
    </section>

    <section id="storage">
      <span class="eyebrow">09</span>
      <h2>Storage and Google Drive</h2>
      <p class="dek">Three different destinations for three types of files — not interchangeable.</p>
      <ul class="plain">
        <li><b>Supabase Storage</b> (bucket <code>archive-files</code>) — final published PDFs (<code>storage_path</code>/<code>file_name</code>) and in-progress correction drafts (<code>draft_inp_path</code>). Upload via <code>supabase.storage.from(BUCKET).upload()</code>, download via a temporary signed URL.</li>
        <li><b>Google Drive, historical PDFs folder</b> — public read via API key, lookup by exact file name (<code>documents.file_name</code>). No writing from here.</li>
        <li><b>Google Drive, "INPAGE Original Document" folder</b> (<code>1LnZ2qo9bAQfyTnvU8V-0D9qLcXQX82DY</code>) — same public read mechanism for InPage originals (<code>documents.renamed_inp_file_name</code>); <strong>writing</strong> via OAuth (Google consent required on first use per session) when the Admin uploads the final InPage file of a correction.</li>
      </ul>
      <div class="callout security">
        <span class="label">Silent dependency</span>
        The public read mechanism only works as long as the two Drive folders remain shared "anyone with the link". If someone tightens the permissions, the symptom is a generic "file not found" — not an explicit permission error, because the API key alone cannot distinguish the two cases.
      </div>
    </section>

    <footer class="page-end">Focolare Urdu Archive Manager — technical reference, generated 2026-08-31</footer>
  </main>
</body>
</html>
$q_schema_en$, 50, now(), 'system')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();
