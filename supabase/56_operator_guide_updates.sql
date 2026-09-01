-- 56_operator_guide_updates.sql
-- Operator guide content update: removed point 8 (catalog editing, tab was removed)
-- and added a new section introducing the Tasks tab's panels, right after section 01.

update help_pages set html_content = $op_it$
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
      <li><a href="#tabtasks">La scheda Tasks</a></li>
      <li><a href="#claim">Prendere un task</a></li>
      <li><a href="#correzione">Correggere un documento</a></li>
      <li><a href="#uscite">Rinuncia o rinvio</a></li>
      <li><a href="#qualifiche">Le tue qualifiche</a></li>
      <li><a href="#revisore">Se sei Revisore</a></li>
      <li><a href="#punteggio">Il tuo punteggio</a></li>
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

    <section id="tabtasks" class="wide">
      <span class="eyebrow">02</span>
      <h2>La scheda Tasks</h2>
      <p class="dek">Qui trovi tutto il lavoro disponibile e il tuo storico, organizzato in pannelli.</p>
      <ul class="step-list">
        <li><b>Open tasks</b> — i task liberi che puoi prendere in carico. Se un task richiede una qualifica specifica (Traduttore, Revisore), lo vedi qui solo se ce l'hai.</li>
        <li><b>My tasks</b> — i task che hai preso in carico: da qui li correggi, li invii in revisione, o rinunci se non riesci a portarli a termine.</li>
        <li><b>Completed</b> — lo storico dei tuoi task chiusi, con l'esito e le eventuali note di chi ti ha revisionato.</li>
        <li><b>Review queue</b> — compare in più solo se hai la qualifica Revisore (vedi più sotto).</li>
      </ul>
      <p>Da qui in avanti vediamo come prendere un task, e poi come si correggono i documenti passo per passo.</p>
    </section>

    <section id="claim">
      <span class="eyebrow">03</span>
      <h2>Prendere un task</h2>
      <ul class="step-list">
        <li>In "Open tasks" vedi solo i task che puoi effettivamente prendere — quelli di traduzione o revisione compaiono solo se hai la qualifica giusta (vedi più sotto).</li>
        <li>Scegli una <b>data di consegna realistica (deadline)</b>&nbsp;— una volta preso il task, quella data resta fissa: non potrai più modificarla in seguito.</li>
        <li>Premi "Claim this task". Da quel momento il task compare in "My tasks".</li>
      </ul>
      <div class="no-card"><b>Prendine solo quanti riesci a portare a termine</b> — un task lasciato scadere senza risposta può essere ripreso forzatamente da un Coordinator, con una penalità sulle tue buone pratiche.</div>
    </section>

    <section id="correzione" class="wide">
      <span class="eyebrow">04</span>
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
      <span class="eyebrow">05</span>
      <h2>Se non riesci a portarlo a termine</h2>
      <p class="dek">C'è un modo onesto per uscire da un task preso. Usalo prima che diventi un problema, non dopo.</p>
      <ul class="step-list">
        <li><b>Give up this task</b> — disponibile su ogni task che hai in corso. Scrivi una riga sul motivo, e il task torna libero per qualcun altro.</li>
        <li>Questo <b>non ha alcuna penalità</b>: ammettere di non riuscire a farcela è un atto onesto, non un errore.</li>
        <li>È molto diverso dal farsi riprendere un task per non aver rispettato i tempi — quello sì comporta una penalità, perché la differenza sta nell'aver comunicato per tempo.</li>
      </ul>
    </section>

    <section id="qualifiche" class="wide">
      <span class="eyebrow">06</span>
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
      <span class="eyebrow">07</span>
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
      <span class="eyebrow">08</span>
      <h2>Il tuo punteggio</h2>
      <p class="dek">In alto, accanto alla tua email, trovi due numeri.</p>
      <p><b>Crediti</b> — si accumulano ogni volta che un tuo task viene pubblicato con successo. Non scendono mai da soli.</p>
      <p><b>Buone Pratiche</b> — un punteggio da 0 a 100 che parte da 50 (un premio alla buona volontà, anche prima di aver fatto qualunque lavoro) e si muove in base a come lavori.</p>
      <div class="meter" aria-hidden="true"><span class="val">0</span><span class="track"><span class="fill"></span></span><span class="val">100</span></div>
      <p>Premi il pulsante <b>"Good practices"</b> in alto in qualunque momento per rivedere i consigli su come lavorare bene e i comportamenti da evitare.</p>
    </section>

    <footer class="page-end">Movimento dei Focolari — Archivio Urdu · Guida Operativa · Operator</footer>
  </main>
</body>
</html>
$op_it$, updated_at = now(), updated_by_email = 'admin' where slug = 'operator_it';

update help_pages set html_content = $op_en$
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
      <li><a href="#tabtasks">The Tasks tab</a></li>
      <li><a href="#claim">Claiming a task</a></li>
      <li><a href="#correzione">Correcting a document</a></li>
      <li><a href="#uscite">Giving up or deferring</a></li>
      <li><a href="#qualifiche">Your qualifications</a></li>
      <li><a href="#revisore">If you are a Revisor</a></li>
      <li><a href="#punteggio">Your score</a></li>
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

    <section id="tabtasks" class="wide">
      <span class="eyebrow">02</span>
      <h2>The Tasks tab</h2>
      <p class="dek">Everything you can work on and your history live here, organized into panels.</p>
      <ul class="step-list">
        <li><b>Open tasks</b> — the free tasks you can claim. If a task requires a specific qualification (Translator, Revisor), you only see it here if you have it.</li>
        <li><b>My tasks</b> — the tasks you've claimed: from here you correct them, submit them for review, or give up if you can't complete them.</li>
        <li><b>Completed</b> — the history of your closed tasks, with the outcome and any notes from whoever reviewed you.</li>
        <li><b>Review queue</b> — appears only if you hold the Revisor qualification (see below).</li>
      </ul>
      <p>From here we'll look at how to claim a task, and then how to correct documents step by step.</p>
    </section>

    <section id="claim">
      <span class="eyebrow">03</span>
      <h2>Claiming a task</h2>
      <ul class="step-list">
        <li>In "Open tasks" you only see the tasks you can actually claim — translation or review tasks appear only if you have the right qualification (see below).</li>
        <li>Choose a <b>realistic delivery date (deadline)</b> — once you have claimed the task, that date is fixed: you will no longer be able to change it afterwards.</li>
        <li>Press "Claim this task". From that moment the task appears in "My tasks".</li>
      </ul>
      <div class="no-card"><b>Only take on as many as you can complete</b> — a task left to expire without a response can be forcibly reclaimed by a Coordinator, with a penalty to your good practices.</div>
    </section>

    <section id="correzione" class="wide">
      <span class="eyebrow">04</span>
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
      <span class="eyebrow">05</span>
      <h2>If you can't complete it</h2>
      <p class="dek">There is an honest way to step back from a claimed task. Use it before it becomes a problem, not after.</p>
      <ul class="step-list">
        <li><b>Give up this task</b> — available on every task you have in progress. Write a line about the reason, and the task becomes free again for someone else.</li>
        <li>This <b>carries no penalty</b>: admitting you can't manage it is an honest act, not a mistake.</li>
        <li>It is very different from having a task reclaimed for missing the deadline — that does carry a penalty, because the difference lies in having communicated in time.</li>
      </ul>
    </section>

    <section id="qualifiche" class="wide">
      <span class="eyebrow">06</span>
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
      <span class="eyebrow">07</span>
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
      <span class="eyebrow">08</span>
      <h2>Your score</h2>
      <p class="dek">At the top, next to your email, you find two numbers.</p>
      <p><b>Credits</b> — accumulate every time one of your tasks is successfully published. They never go down on their own.</p>
      <p><b>Good Practices</b> — a score from 0 to 100 that starts at 50 (a reward for good will, even before doing any work) and moves based on how you work.</p>
      <div class="meter" aria-hidden="true"><span class="val">0</span><span class="track"><span class="fill"></span></span><span class="val">100</span></div>
      <p>Press the <b>"Good practices"</b> button at the top at any time to review tips on how to work well and behaviors to avoid.</p>
    </section>

    <footer class="page-end">Focolare Movement — Urdu Archive · Operator Guide · Operator</footer>
  </main>
</body>
</html>
$op_en$, updated_at = now(), updated_by_email = 'admin' where slug = 'operator_en';
