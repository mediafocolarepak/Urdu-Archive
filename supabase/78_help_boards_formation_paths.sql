-- 78_help_boards_formation_paths.sql
-- Guida operativa "Bacheche e Percorsi Formativi" (IT+EN), aggiunta alla scheda Help su
-- richiesta di Alessandro - stesso meccanismo di 51_help_pages.sql (tabella help_pages,
-- ammin-editabile in-app). Contenuto identico ai due Claude Artifact pubblicati l'11/09/2026,
-- incollato qui cosi' resta anche dentro l'app, non solo su un link esterno che puo' scadere.
-- role = null: guida trasversale ai ruoli (formatori/Coordinator/Admin), non specifica di uno
-- solo, quindi non va sotto la sezione "il tuo ruolo" come le guide 10/20/30/40 - sort_order 5,
-- subito dopo "Il Libro dei Ruoli" (0) e prima delle guide per ruolo (10+).

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('boards_paths_it', 'it', null, 'Bacheche e Percorsi Formativi', $q_bp_it$
<title>Bacheche e Percorsi Formativi</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Public+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500&display=swap');

  :root{
    --bg:#faf8f4;
    --surface:#ffffff;
    --surface-2:#f3efe7;
    --ink:#26211d;
    --ink-soft:#6e655b;
    --ink-faint:#a89e90;
    --line:#e6ded2;
    --line-strong:#d8cdba;
    --accent:#6b2b3a;
    --accent-ink:#ffffff;
    --accent-soft:#f3e7e6;
    --accent-soft-line:#e4c9c9;
    --gold:#8a6a1f;
    --gold-soft:#f2ecd9;
    --gold-soft-line:#e0d3a4;
    --good:#3f6b3f;
    --good-soft:#e7efe2;
    --shadow: 0 1px 2px rgba(38,33,29,.06), 0 8px 24px -12px rgba(38,33,29,.18);
    --radius: 10px;
  }
  @media (prefers-color-scheme: dark){
    :root:not([data-theme="light"]){
      --bg:#1c1815;
      --surface:#242019;
      --surface-2:#2c2620;
      --ink:#f1ece3;
      --ink-soft:#c6bbab;
      --ink-faint:#8a8072;
      --line:#3a332a;
      --line-strong:#493f32;
      --accent:#e08a9a;
      --accent-ink:#2a1216;
      --accent-soft:#3a2226;
      --accent-soft-line:#5a3138;
      --gold:#d9bd6a;
      --gold-soft:#332c1b;
      --gold-soft-line:#54481f;
      --good:#8fbf8a;
      --good-soft:#233225;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px -12px rgba(0,0,0,.5);
    }
  }
  :root[data-theme="dark"]{
    --bg:#1c1815;
    --surface:#242019;
    --surface-2:#2c2620;
    --ink:#f1ece3;
    --ink-soft:#c6bbab;
    --ink-faint:#8a8072;
    --line:#3a332a;
    --line-strong:#493f32;
    --accent:#e08a9a;
    --accent-ink:#2a1216;
    --accent-soft:#3a2226;
    --accent-soft-line:#5a3138;
    --gold:#d9bd6a;
    --gold-soft:#332c1b;
    --gold-soft-line:#54481f;
    --good:#8fbf8a;
    --good-soft:#233225;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px -12px rgba(0,0,0,.5);
  }

  *{box-sizing:border-box;}
  body{
    background:var(--bg);
    color:var(--ink);
    font-family:'Public Sans', -apple-system, 'Segoe UI', sans-serif;
    font-size:15.5px;
    line-height:1.65;
  }
  h1,h2,h3{
    font-family:'Fraunces', Georgia, serif;
    text-wrap:balance;
    color:var(--ink);
    font-weight:600;
    letter-spacing:-.01em;
  }
  a{color:var(--accent);}
  code, .kbd, .chip{ font-family:'IBM Plex Mono', ui-monospace, monospace; }

  /* ---------- Shell layout: sticky TOC + column ---------- */
  .shell{
    display:grid;
    grid-template-columns: 240px minmax(0,760px);
    justify-content:center;
    gap:56px;
    max-width:1180px;
    margin:0 auto;
    padding:48px 24px 120px;
  }
  @media (max-width: 880px){
    .shell{ grid-template-columns: 1fr; padding:28px 18px 80px; gap:28px; }
    .toc{ position:static; order:2; }
  }

  .toc{
    position:sticky; top:32px; align-self:start;
    font-size:13px;
  }
  .toc .toc-title{
    font-family:'IBM Plex Mono';
    text-transform:uppercase;
    letter-spacing:.08em;
    color:var(--ink-faint);
    font-size:11px;
    margin-bottom:10px;
  }
  .toc nav{ display:flex; flex-direction:column; gap:2px; }
  .toc a{
    color:var(--ink-soft);
    text-decoration:none;
    padding:5px 10px;
    border-radius:7px;
    border-left:2px solid transparent;
  }
  .toc a:hover{ background:var(--surface-2); color:var(--ink); }
  .toc a.part{ font-weight:600; color:var(--ink); margin-top:12px; }
  .toc a.part:first-child{ margin-top:0; }
  .toc a.sub{ padding-left:20px; font-size:12.5px; }

  main{ min-width:0; }

  /* ---------- Header / intro ---------- */
  .doc-eyebrow{
    font-family:'IBM Plex Mono'; font-size:11.5px; letter-spacing:.1em; text-transform:uppercase;
    color:var(--accent); margin-bottom:14px; display:flex; align-items:center; gap:8px;
  }
  .doc-eyebrow::before{ content:''; width:22px; height:1.5px; background:var(--accent); display:inline-block; }
  h1.doc-title{ font-size:38px; line-height:1.12; margin:0 0 14px; }
  .doc-sub{ color:var(--ink-soft); font-size:16.5px; max-width:58ch; margin-bottom:28px; }
  .doc-meta{
    display:flex; gap:18px; flex-wrap:wrap; font-size:12.5px; color:var(--ink-faint);
    padding-top:16px; border-top:1px solid var(--line); margin-bottom:44px;
  }
  .doc-meta b{ color:var(--ink-soft); font-weight:600; }

  /* ---------- Part headers ---------- */
  .part-header{
    display:flex; align-items:baseline; gap:14px;
    margin:76px 0 6px;
    padding-bottom:14px;
    border-bottom:2px solid var(--ink);
  }
  .part-header:first-of-type{ margin-top:0; }
  .part-num{
    font-family:'IBM Plex Mono'; font-size:13px; color:var(--accent); font-weight:500;
  }
  .part-header h1{ font-size:26px; margin:0; }
  .part-intro{ color:var(--ink-soft); max-width:64ch; margin:16px 0 8px; }

  section.step{ margin-top:40px; scroll-margin-top:24px; }
  section.step h2{
    font-size:19px; display:flex; align-items:center; gap:10px; margin-bottom:4px;
  }
  section.step h2 .step-no{
    font-family:'IBM Plex Mono'; font-size:13px; color:var(--ink-faint); font-weight:500;
  }
  section.step > p.lede{ color:var(--ink-soft); margin:8px 0 18px; max-width:64ch; }

  p{ margin:0 0 14px; max-width:66ch; }
  ol.steps{ margin:0 0 18px; padding-left:0; list-style:none; counter-reset:s; }
  ol.steps > li{
    counter-increment:s;
    display:grid; grid-template-columns:26px 1fr; gap:12px;
    margin-bottom:14px; max-width:64ch;
  }
  ol.steps > li::before{
    content: counter(s);
    font-family:'IBM Plex Mono'; font-size:12px; font-weight:500;
    color:var(--accent); background:var(--accent-soft);
    width:24px; height:24px; border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    margin-top:.15em;
  }
  ul.plain{ margin:0 0 16px; padding-left:20px; max-width:64ch; }
  ul.plain li{ margin-bottom:6px; }

  /* ---------- UI chips (button/field labels as they appear on screen) ---------- */
  .chip{
    display:inline-flex; align-items:center; gap:4px;
    background:var(--surface-2); border:1px solid var(--line-strong);
    border-radius:6px; padding:1.5px 7px; font-size:12.5px; font-weight:500;
    color:var(--ink); white-space:nowrap;
  }

  /* ---------- Callout boxes ---------- */
  .box{
    border-radius:var(--radius);
    padding:16px 18px;
    margin:18px 0;
    max-width:64ch;
    border:1px solid var(--line);
    background:var(--surface);
  }
  .box .box-label{
    font-family:'IBM Plex Mono'; font-size:11px; text-transform:uppercase; letter-spacing:.08em;
    display:flex; align-items:center; gap:6px; margin-bottom:6px; font-weight:500;
  }
  .box p:last-child{ margin-bottom:0; }
  .box.who{ background:var(--surface-2); }
  .box.who .box-label{ color:var(--ink-soft); }
  .box.rule{ background:var(--accent-soft); border-color:var(--accent-soft-line); }
  .box.rule .box-label{ color:var(--accent); }
  .box.tip{ background:var(--gold-soft); border-color:var(--gold-soft-line); }
  .box.tip .box-label{ color:var(--gold); }

  /* ---------- Permission matrix ---------- */
  .matrix-wrap{ overflow-x:auto; margin:20px 0 8px; border:1px solid var(--line); border-radius:var(--radius); }
  table.matrix{ border-collapse:collapse; width:100%; font-size:13px; min-width:620px; }
  table.matrix caption{ display:none; }
  table.matrix th, table.matrix td{ padding:10px 14px; text-align:left; border-bottom:1px solid var(--line); }
  table.matrix thead th{
    font-family:'IBM Plex Mono'; font-weight:500; font-size:11px; text-transform:uppercase; letter-spacing:.05em;
    color:var(--ink-faint); background:var(--surface-2); white-space:nowrap;
  }
  table.matrix tbody th{ font-weight:600; color:var(--ink); white-space:nowrap; }
  table.matrix tbody tr:last-child td, table.matrix tbody tr:last-child th{ border-bottom:none; }
  table.matrix td{ text-align:center; color:var(--ink-soft); }
  .yes{ color:var(--good); font-weight:700; }
  .no{ color:var(--ink-faint); }

  /* ---------- Flow / hierarchy diagram ---------- */
  .flow{
    display:flex; align-items:center; gap:0; flex-wrap:wrap;
    margin:18px 0 22px; font-family:'IBM Plex Mono'; font-size:12.5px;
  }
  .flow .node{
    background:var(--surface); border:1px solid var(--line-strong); border-radius:7px;
    padding:7px 12px; color:var(--ink);
  }
  .flow .arrow{ color:var(--ink-faint); padding:0 8px; }

  .indent-tree{ margin:16px 0 20px; font-size:13.5px; }
  .indent-tree .lvl1{ font-weight:600; }
  .indent-tree .lvl2{ margin-left:22px; margin-top:6px; color:var(--ink-soft); }
  .indent-tree .lvl3{ margin-left:44px; margin-top:6px; color:var(--ink-soft); }
  .indent-tree .lvl4{ margin-left:66px; margin-top:6px; color:var(--ink-faint); }
  .indent-tree > div{ padding:3px 0; border-left:2px solid var(--line); padding-left:10px; }
  .indent-tree .lvl1{ border-left-color:var(--accent); }

  hr.sep{ border:none; border-top:1px solid var(--line); margin:48px 0; }

  .end-note{
    margin-top:64px; padding-top:20px; border-top:1px solid var(--line);
    color:var(--ink-faint); font-size:12.5px;
  }
</style>

<div class="shell">
  <aside class="toc">
    <div class="toc-title">In questa guida</div>
    <nav>
      <a class="part" href="#bacheche">I. Bacheche</a>
      <a class="sub" href="#b-cosa">Cos'è una bacheca</a>
      <a class="sub" href="#b-formatore">Diventare formatore</a>
      <a class="sub" href="#b-post">Pubblicare un post</a>
      <a class="sub" href="#b-gestire">Modificare, fissare, eliminare</a>
      <a class="sub" href="#b-letto">Il segno "✓ Letto"</a>
      <a class="sub" href="#b-editori">Gestire i formatori</a>

      <a class="part" href="#percorsi">II. Percorsi formativi</a>
      <a class="sub" href="#p-cosa">Cos'è un percorso</a>
      <a class="sub" href="#p-creare">Creare un percorso</a>
      <a class="sub" href="#p-struttura">Costruire la struttura</a>
      <a class="sub" href="#p-pubblicare">Pubblicare e archiviare</a>
      <a class="sub" href="#p-iscrizione">Iscrizione</a>
      <a class="sub" href="#p-chat">Le due chat</a>
      <a class="sub" href="#p-quiz">Quiz</a>
      <a class="sub" href="#p-attestato">L'attestato</a>

      <a class="part" href="#riepilogo">III. Riepilogo permessi</a>
    </nav>
  </aside>

  <main>
    <div class="doc-eyebrow">Guida operativa</div>
    <h1 class="doc-title">Bacheche e Percorsi Formativi</h1>
    <p class="doc-sub">Come usare le due funzioni di formazione dell'Archivio Urdu Focolare: le bacheche per avvisi e materiali curati, e i percorsi formativi per corsi strutturati con iscrizione, verifiche e attestato.</p>
    <div class="doc-meta">
      <span><b>Per chi:</b> formatori, Coordinator, Admin</span>
      <span><b>Dove:</b> tab "Boards" e "Formation Paths"</span>
    </div>

    <!-- ============================================================ PART I ============================================================ -->
    <div class="part-header" id="bacheche">
      <span class="part-num">I</span>
      <h1>Bacheche</h1>
    </div>
    <p class="part-intro">Una bacheca è un canale per gruppo (Bambini, Ragazzi, Giovani, Adulti, Famiglie, Sacerdoti...) dove i formatori pubblicano avvisi e documenti curati, e tutti gli altri leggono. Niente commenti: è un flusso a senso unico, pensato per la comunicazione formativa, non per la discussione.</p>

    <section class="step" id="b-cosa">
      <h2><span class="step-no">§1</span> Cos'è una bacheca</h2>
      <p class="lede">Ogni bacheca corrisponde a un gruppo dell'archivio. Un post può contenere un testo libero, oppure un documento dell'archivio collegato (con un'anteprima del testo urdu), oppure entrambi.</p>
      <div class="box who">
        <div class="box-label">Chi vede cosa</div>
        <p>Tutti gli utenti registrati leggono tutte le bacheche. Solo chi è stato nominato <b>formatore</b> di una bacheca specifica può scriverci — o Coordinator/Admin, che possono scrivere ovunque.</p>
      </div>
    </section>

    <section class="step" id="b-formatore">
      <h2><span class="step-no">§2</span> Diventare formatore di una bacheca</h2>
      <p class="lede">Non ci si nomina da soli: è Coordinator o Admin ad assegnare i formatori, bacheca per bacheca (vedi <a href="#b-editori">§6</a>). Se non vedi il bottone <span class="chip">+ New post</span> su una bacheca, non sei ancora stato nominato per quel gruppo.</p>
    </section>

    <section class="step" id="b-post">
      <h2><span class="step-no">§3</span> Pubblicare un post</h2>
      <ol class="steps">
        <li>Apri la bacheca del gruppo giusto dalle schede in alto, poi <span class="chip">+ New post</span>.</li>
        <li>Scrivi un titolo. Il testo è facoltativo se colleghi un documento, obbligatorio se il post è solo testo.</li>
        <li>Per collegare un documento dell'archivio, apri quel documento dalla Dashboard e usa il suo bottone "+ Board" — precompila il post con titolo e testo urdu in anteprima.</li>
        <li>Salva: il post appare subito in cima alla bacheca.</li>
      </ol>
    </section>

    <section class="step" id="b-gestire">
      <h2><span class="step-no">§4</span> Modificare, fissare, eliminare</h2>
      <p class="lede">Sotto ogni tuo post trovi <span class="chip">Edit</span> e <span class="chip">Delete</span>. Coordinator e Admin li vedono su ogni post, di qualunque bacheca.</p>
      <p>Il bottone <span class="chip">Pin</span> (solo Coordinator/Admin) fissa un post in cima alla bacheca, davanti a tutti gli altri — utile per un avviso urgente che non deve scorrere via.</p>
    </section>

    <section class="step" id="b-letto">
      <h2><span class="step-no">§5</span> Il segno "✓ Letto"</h2>
      <p class="lede">Ogni post tiene il conto di chi lo ha aperto — ma senza bisogno di cliccare nulla.</p>
      <div class="box rule">
        <div class="box-label">Come funziona davvero</div>
        <p>La lettura si registra <b>da sola</b> nell'istante in cui apri la bacheca — non è un bottone. Sotto il post vedi "<span class="chip">N read</span>" e, se lo hai già visto, "<span class="chip">you read this ✓</span>".</p>
      </div>
      <p>Il numero è visibile a tutti; <b>l'elenco con i nomi</b> — dietro il link <span class="chip">Who?</span> — è visibile solo al formatore di quella bacheca e a Coordinator/Admin. Un utente qualsiasi vede quante persone hanno letto, mai chi.</p>
    </section>

    <section class="step" id="b-editori">
      <h2><span class="step-no">§6</span> Gestire i formatori di una bacheca</h2>
      <p class="lede">Riservato a Coordinator e Admin, in fondo alla pagina Boards.</p>
      <ol class="steps">
        <li>Scegli la bacheca dal menu a tendina "Board".</li>
        <li>Cerca la persona per nome o email nel campo di ricerca, e clicca sul risultato per aggiungerla.</li>
        <li>Per toglierla, clicca <span class="chip">Remove</span> accanto al suo nome.</li>
      </ol>
    </section>

    <!-- ============================================================ PART II ============================================================ -->
    <div class="part-header" id="percorsi">
      <span class="part-num">II</span>
      <h1>Percorsi formativi</h1>
    </div>
    <p class="part-intro">Un percorso formativo è un vero corso strutturato: anni, moduli, capitoli, verifiche e — se lo si completa — un attestato. Diverso dalle bacheche, che restano avvisi sparsi: qui il contenuto ha un ordine da seguire.</p>

    <section class="step" id="p-cosa">
      <h2><span class="step-no">§1</span> Cos'è un percorso, e chi lo vede</h2>
      <div class="box rule">
        <div class="box-label">La regola che governa tutto</div>
        <p>Il <b>contenuto</b> di un percorso pubblicato è sempre leggibile da chiunque, iscritto o no — per farsi un'idea prima di impegnarsi, o per rivederlo anche dopo aver finito. <b>Iscriversi</b> serve solo a sbloccare tre cose: la chat con gli altri iscritti, le verifiche a quiz, e l'attestato finale.</p>
      </div>
      <p>Finché un percorso è in <span class="chip">Bozza</span>, lo vede solo chi lo sta costruendo: il proprietario, Coordinator/Admin, e — per poter dare consigli — qualunque altro formatore. Una volta su <span class="chip">Pubblicato</span>, si apre a tutti.</p>
    </section>

    <section class="step" id="p-creare">
      <h2><span class="step-no">§2</span> Creare un percorso</h2>
      <div class="box who">
        <div class="box-label">Chi può crearne uno</div>
        <p>Solo chi è già formatore di almeno una bacheca. Il percorso che crei sei tu l'unico proprietario — nessun altro può modificarlo, tranne Coordinator/Admin.</p>
      </div>
      <ol class="steps">
        <li>Vai alla tab <span class="chip">Formation Paths</span> → <span class="chip">+ New path</span>.</li>
        <li>Compila titolo, descrizione, utenza a cui è rivolto, e se è un percorso regolare (ottobre-maggio) o estivo (giugno-settembre).</li>
        <li>Se prevedi un'iscrizione a termine, imposta anche inizio/fine corso e la scadenza per iscriversi.</li>
        <li>Salva: nasce in <span class="chip">Bozza</span>, visibile solo a te (e agli altri formatori).</li>
      </ol>
    </section>

    <section class="step" id="p-struttura">
      <h2><span class="step-no">§3</span> Costruire la struttura</h2>
      <p class="lede">Un percorso è una gerarchia a quattro livelli:</p>
      <div class="indent-tree">
        <div class="lvl1">Anno 1, Anno 2...</div>
        <div class="lvl2">Modulo — es. "Fondamenti dell'unità"</div>
        <div class="lvl3">Capitolo — es. "L'amore come primo comandamento"</div>
        <div class="lvl4">Post — un testo, dentro il capitolo</div>
      </div>
      <p>Ad ogni livello trovi gli stessi controlli: le frecce <span class="chip">▲ ▼</span> per riordinare, <span class="chip">+</span> per aggiungere il livello sotto, e <span class="chip">Delete</span> — che cancella anche tutto quello che contiene, senza conferma successiva possibile.</p>
      <div class="box tip">
        <div class="box-label">Un post oggi è solo testo</div>
        <p>A differenza dei post delle bacheche, un post di percorso non si collega ancora a un documento dell'archivio — solo titolo e testo libero.</p>
      </div>
    </section>

    <section class="step" id="p-pubblicare">
      <h2><span class="step-no">§4</span> Pubblicare, archiviare, eliminare</h2>
      <ul class="plain">
        <li><span class="chip">Publish</span> — apre il percorso a tutti. Fallo quando la struttura è pronta, anche se incompleta: si può sempre continuare ad aggiungere dopo.</li>
        <li><span class="chip">Archive</span> — lo ritira dal catalogo pubblico senza cancellarlo: resta visibile a te, agli iscritti già dentro, e a Coordinator/Admin.</li>
        <li><span class="chip">Delete path</span> — cancellazione definitiva, con tutto quello che contiene (iscrizioni, chat, quiz, attestati compresi).</li>
      </ul>
    </section>

    <section class="step" id="p-iscrizione">
      <h2><span class="step-no">§5</span> Iscrizione</h2>
      <p class="lede">Sul percorso pubblicato compare un contatore ("N enrolled") e, per chi non è ancora dentro, il bottone <span class="chip">Enroll</span> — finché non passa la scadenza impostata alla creazione. Dopo, il bottone sparisce e resta solo "Enrollment is closed for this path": la scadenza è applicata anche lato server, non solo nascosta a schermo.</p>
      <p>Ci si può ritirare in ogni momento con <span class="chip">Withdraw</span>, senza limiti di tempo. L'elenco nominativo degli iscritti (<span class="chip">Who?</span>) resta visibile solo al proprietario del percorso e a Coordinator/Admin.</p>
    </section>

    <section class="step" id="p-chat">
      <h2><span class="step-no">§6</span> Le due chat</h2>
      <p class="lede">Ogni percorso ha due spazi di conversazione separati, sotto le voci a comparsa <span class="chip">▸ Discussion</span> e <span class="chip">▸ Formatori notes</span>.</p>
      <div class="matrix-wrap">
        <table class="matrix">
          <thead><tr><th></th><th>Discussion</th><th>Formatori notes</th></tr></thead>
          <tbody>
            <tr><th>Chi la vede e scrive</th><td>Iscritti + proprietario + Coordinator/Admin</td><td>Qualunque formatore + Coordinator/Admin</td></tr>
            <tr><th>A cosa serve</th><td>Domande e scambio tra chi segue il corso</td><td>Consigli e miglioramenti tra formatori</td></tr>
            <tr><th>Funziona anche in bozza?</th><td class="no">No — serve un percorso pubblicato</td><td class="yes">Sì, apposta</td></tr>
          </tbody>
        </table>
      </div>
      <p>"Formatori notes" resta invisibile agli iscritti in ogni caso: è lo spazio per il confronto dietro le quinte, anche prima che il percorso sia pronto per il pubblico.</p>
    </section>

    <section class="step" id="p-quiz">
      <h2><span class="step-no">§7</span> Quiz</h2>
      <p class="lede">Ogni modulo può avere un quiz, e il percorso un esame finale — entrambi a scelta multipla, con una soglia di superamento decisa dal formatore.</p>
      <ol class="steps">
        <li>Nel modulo (o in cima al percorso, per l'esame finale) clicca <span class="chip">+ Add quiz</span> / <span class="chip">+ Add final exam</span>, dai un titolo e una soglia percentuale.</li>
        <li>Apri <span class="chip">Manage</span> → <span class="chip">+ Add question</span>: scrivi la domanda, un'opzione per riga, e il numero dell'opzione corretta.</li>
        <li>Chi è iscritto vede <span class="chip">Take quiz</span>: risponde e ottiene subito punteggio ed esito.</li>
      </ol>
      <div class="box tip">
        <div class="box-label">Nessuna penalità</div>
        <p>I tentativi sono illimitati — si può riprovare finché non si passa, resta solo il miglior risultato. Niente blocchi dopo un tentativo sbagliato.</p>
      </div>
    </section>

    <section class="step" id="p-attestato">
      <h2><span class="step-no">§8</span> L'attestato</h2>
      <p class="lede">Si ottiene in automatico, non va assegnato a mano: appena un iscritto supera <b>tutti</b> i quiz dei moduli e l'esame finale (se il percorso ne prevede uno), l'attestato compare da solo.</p>
      <p>Resta visibile in due punti: in cima al percorso stesso, e nella pagina <span class="chip">My Profile</span> di chi lo ha ottenuto, sotto "My Certificates" — con data e codice, per sempre, anche se il percorso viene poi archiviato.</p>
    </section>

    <!-- ============================================================ PART III ============================================================ -->
    <div class="part-header" id="riepilogo">
      <span class="part-num">III</span>
      <h1>Riepilogo permessi</h1>
    </div>
    <p class="part-intro">Chi può fare cosa, a colpo d'occhio.</p>

    <div class="matrix-wrap">
      <table class="matrix">
        <thead><tr><th>Azione</th><th>Utente</th><th>Formatore</th><th>Coordinator / Admin</th></tr></thead>
        <tbody>
          <tr><th>Leggere bacheche e percorsi pubblicati</th><td class="yes">Sì</td><td class="yes">Sì</td><td class="yes">Sì</td></tr>
          <tr><th>Pubblicare in una bacheca</th><td class="no">—</td><td>solo le proprie</td><td class="yes">Ovunque</td></tr>
          <tr><th>Vedere chi ha letto un post</th><td class="no">—</td><td>solo le proprie</td><td class="yes">Ovunque</td></tr>
          <tr><th>Creare un percorso formativo</th><td class="no">—</td><td class="yes">Sì</td><td class="yes">Sì</td></tr>
          <tr><th>Modificare il percorso di un altro</th><td class="no">—</td><td>no (solo "Formatori notes")</td><td class="yes">Sì</td></tr>
          <tr><th>Iscriversi a un percorso</th><td class="yes">Sì</td><td class="yes">Sì</td><td class="yes">Sì</td></tr>
          <tr><th>Vedere l'elenco iscritti</th><td class="no">—</td><td>solo i propri percorsi</td><td class="yes">Ovunque</td></tr>
          <tr><th>Scrivere in "Formatori notes"</th><td class="no">—</td><td class="yes">Su ogni percorso</td><td class="yes">Su ogni percorso</td></tr>
        </tbody>
      </table>
    </div>

    <p class="end-note">Guida aggiornata all'11/09/2026 — funzioni costruite nelle Fasi A–D di "Percorsi formativi" e nella funzione "✓ Letto" delle bacheche.</p>
  </main>
</div>
$q_bp_it$, 5, now(), 'alessanpk@gmail.com')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('boards_paths_en', 'en', null, 'Boards and Formation Paths', $q_bp_en$
<title>Boards and Formation Paths</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=Public+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@500&display=swap');

  :root{
    --bg:#faf8f4;
    --surface:#ffffff;
    --surface-2:#f3efe7;
    --ink:#26211d;
    --ink-soft:#6e655b;
    --ink-faint:#a89e90;
    --line:#e6ded2;
    --line-strong:#d8cdba;
    --accent:#6b2b3a;
    --accent-ink:#ffffff;
    --accent-soft:#f3e7e6;
    --accent-soft-line:#e4c9c9;
    --gold:#8a6a1f;
    --gold-soft:#f2ecd9;
    --gold-soft-line:#e0d3a4;
    --good:#3f6b3f;
    --good-soft:#e7efe2;
    --shadow: 0 1px 2px rgba(38,33,29,.06), 0 8px 24px -12px rgba(38,33,29,.18);
    --radius: 10px;
  }
  @media (prefers-color-scheme: dark){
    :root:not([data-theme="light"]){
      --bg:#1c1815;
      --surface:#242019;
      --surface-2:#2c2620;
      --ink:#f1ece3;
      --ink-soft:#c6bbab;
      --ink-faint:#8a8072;
      --line:#3a332a;
      --line-strong:#493f32;
      --accent:#e08a9a;
      --accent-ink:#2a1216;
      --accent-soft:#3a2226;
      --accent-soft-line:#5a3138;
      --gold:#d9bd6a;
      --gold-soft:#332c1b;
      --gold-soft-line:#54481f;
      --good:#8fbf8a;
      --good-soft:#233225;
      --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px -12px rgba(0,0,0,.5);
    }
  }
  :root[data-theme="dark"]{
    --bg:#1c1815;
    --surface:#242019;
    --surface-2:#2c2620;
    --ink:#f1ece3;
    --ink-soft:#c6bbab;
    --ink-faint:#8a8072;
    --line:#3a332a;
    --line-strong:#493f32;
    --accent:#e08a9a;
    --accent-ink:#2a1216;
    --accent-soft:#3a2226;
    --accent-soft-line:#5a3138;
    --gold:#d9bd6a;
    --gold-soft:#332c1b;
    --gold-soft-line:#54481f;
    --good:#8fbf8a;
    --good-soft:#233225;
    --shadow: 0 1px 2px rgba(0,0,0,.3), 0 8px 24px -12px rgba(0,0,0,.5);
  }

  *{box-sizing:border-box;}
  body{
    background:var(--bg);
    color:var(--ink);
    font-family:'Public Sans', -apple-system, 'Segoe UI', sans-serif;
    font-size:15.5px;
    line-height:1.65;
  }
  h1,h2,h3{
    font-family:'Fraunces', Georgia, serif;
    text-wrap:balance;
    color:var(--ink);
    font-weight:600;
    letter-spacing:-.01em;
  }
  a{color:var(--accent);}
  code, .kbd, .chip{ font-family:'IBM Plex Mono', ui-monospace, monospace; }

  .shell{
    display:grid;
    grid-template-columns: 240px minmax(0,760px);
    justify-content:center;
    gap:56px;
    max-width:1180px;
    margin:0 auto;
    padding:48px 24px 120px;
  }
  @media (max-width: 880px){
    .shell{ grid-template-columns: 1fr; padding:28px 18px 80px; gap:28px; }
    .toc{ position:static; order:2; }
  }

  .toc{
    position:sticky; top:32px; align-self:start;
    font-size:13px;
  }
  .toc .toc-title{
    font-family:'IBM Plex Mono';
    text-transform:uppercase;
    letter-spacing:.08em;
    color:var(--ink-faint);
    font-size:11px;
    margin-bottom:10px;
  }
  .toc nav{ display:flex; flex-direction:column; gap:2px; }
  .toc a{
    color:var(--ink-soft);
    text-decoration:none;
    padding:5px 10px;
    border-radius:7px;
    border-left:2px solid transparent;
  }
  .toc a:hover{ background:var(--surface-2); color:var(--ink); }
  .toc a.part{ font-weight:600; color:var(--ink); margin-top:12px; }
  .toc a.part:first-child{ margin-top:0; }
  .toc a.sub{ padding-left:20px; font-size:12.5px; }

  main{ min-width:0; }

  .doc-eyebrow{
    font-family:'IBM Plex Mono'; font-size:11.5px; letter-spacing:.1em; text-transform:uppercase;
    color:var(--accent); margin-bottom:14px; display:flex; align-items:center; gap:8px;
  }
  .doc-eyebrow::before{ content:''; width:22px; height:1.5px; background:var(--accent); display:inline-block; }
  h1.doc-title{ font-size:38px; line-height:1.12; margin:0 0 14px; }
  .doc-sub{ color:var(--ink-soft); font-size:16.5px; max-width:58ch; margin-bottom:28px; }
  .doc-meta{
    display:flex; gap:18px; flex-wrap:wrap; font-size:12.5px; color:var(--ink-faint);
    padding-top:16px; border-top:1px solid var(--line); margin-bottom:44px;
  }
  .doc-meta b{ color:var(--ink-soft); font-weight:600; }

  .part-header{
    display:flex; align-items:baseline; gap:14px;
    margin:76px 0 6px;
    padding-bottom:14px;
    border-bottom:2px solid var(--ink);
  }
  .part-header:first-of-type{ margin-top:0; }
  .part-num{
    font-family:'IBM Plex Mono'; font-size:13px; color:var(--accent); font-weight:500;
  }
  .part-header h1{ font-size:26px; margin:0; }
  .part-intro{ color:var(--ink-soft); max-width:64ch; margin:16px 0 8px; }

  section.step{ margin-top:40px; scroll-margin-top:24px; }
  section.step h2{
    font-size:19px; display:flex; align-items:center; gap:10px; margin-bottom:4px;
  }
  section.step h2 .step-no{
    font-family:'IBM Plex Mono'; font-size:13px; color:var(--ink-faint); font-weight:500;
  }
  section.step > p.lede{ color:var(--ink-soft); margin:8px 0 18px; max-width:64ch; }

  p{ margin:0 0 14px; max-width:66ch; }
  ol.steps{ margin:0 0 18px; padding-left:0; list-style:none; counter-reset:s; }
  ol.steps > li{
    counter-increment:s;
    display:grid; grid-template-columns:26px 1fr; gap:12px;
    margin-bottom:14px; max-width:64ch;
  }
  ol.steps > li::before{
    content: counter(s);
    font-family:'IBM Plex Mono'; font-size:12px; font-weight:500;
    color:var(--accent); background:var(--accent-soft);
    width:24px; height:24px; border-radius:50%;
    display:flex; align-items:center; justify-content:center;
    margin-top:.15em;
  }
  ul.plain{ margin:0 0 16px; padding-left:20px; max-width:64ch; }
  ul.plain li{ margin-bottom:6px; }

  .chip{
    display:inline-flex; align-items:center; gap:4px;
    background:var(--surface-2); border:1px solid var(--line-strong);
    border-radius:6px; padding:1.5px 7px; font-size:12.5px; font-weight:500;
    color:var(--ink); white-space:nowrap;
  }

  .box{
    border-radius:var(--radius);
    padding:16px 18px;
    margin:18px 0;
    max-width:64ch;
    border:1px solid var(--line);
    background:var(--surface);
  }
  .box .box-label{
    font-family:'IBM Plex Mono'; font-size:11px; text-transform:uppercase; letter-spacing:.08em;
    display:flex; align-items:center; gap:6px; margin-bottom:6px; font-weight:500;
  }
  .box p:last-child{ margin-bottom:0; }
  .box.who{ background:var(--surface-2); }
  .box.who .box-label{ color:var(--ink-soft); }
  .box.rule{ background:var(--accent-soft); border-color:var(--accent-soft-line); }
  .box.rule .box-label{ color:var(--accent); }
  .box.tip{ background:var(--gold-soft); border-color:var(--gold-soft-line); }
  .box.tip .box-label{ color:var(--gold); }

  .matrix-wrap{ overflow-x:auto; margin:20px 0 8px; border:1px solid var(--line); border-radius:var(--radius); }
  table.matrix{ border-collapse:collapse; width:100%; font-size:13px; min-width:620px; }
  table.matrix th, table.matrix td{ padding:10px 14px; text-align:left; border-bottom:1px solid var(--line); }
  table.matrix thead th{
    font-family:'IBM Plex Mono'; font-weight:500; font-size:11px; text-transform:uppercase; letter-spacing:.05em;
    color:var(--ink-faint); background:var(--surface-2); white-space:nowrap;
  }
  table.matrix tbody th{ font-weight:600; color:var(--ink); white-space:nowrap; }
  table.matrix tbody tr:last-child td, table.matrix tbody tr:last-child th{ border-bottom:none; }
  table.matrix td{ text-align:center; color:var(--ink-soft); }
  .yes{ color:var(--good); font-weight:700; }
  .no{ color:var(--ink-faint); }

  .indent-tree{ margin:16px 0 20px; font-size:13.5px; }
  .indent-tree .lvl1{ font-weight:600; }
  .indent-tree .lvl2{ margin-left:22px; margin-top:6px; color:var(--ink-soft); }
  .indent-tree .lvl3{ margin-left:44px; margin-top:6px; color:var(--ink-soft); }
  .indent-tree .lvl4{ margin-left:66px; margin-top:6px; color:var(--ink-faint); }
  .indent-tree > div{ padding:3px 0; border-left:2px solid var(--line); padding-left:10px; }
  .indent-tree .lvl1{ border-left-color:var(--accent); }

  .end-note{
    margin-top:64px; padding-top:20px; border-top:1px solid var(--line);
    color:var(--ink-faint); font-size:12.5px;
  }
</style>

<div class="shell">
  <aside class="toc">
    <div class="toc-title">In this guide</div>
    <nav>
      <a class="part" href="#boards">I. Boards</a>
      <a class="sub" href="#b-what">What a board is</a>
      <a class="sub" href="#b-editor">Becoming a board editor</a>
      <a class="sub" href="#b-post">Publishing a post</a>
      <a class="sub" href="#b-manage">Edit, pin, delete</a>
      <a class="sub" href="#b-read">The "✓ Read" mark</a>
      <a class="sub" href="#b-editors">Managing board editors</a>

      <a class="part" href="#paths">II. Formation Paths</a>
      <a class="sub" href="#p-what">What a path is</a>
      <a class="sub" href="#p-create">Creating a path</a>
      <a class="sub" href="#p-structure">Building the structure</a>
      <a class="sub" href="#p-publish">Publish and archive</a>
      <a class="sub" href="#p-enroll">Enrollment</a>
      <a class="sub" href="#p-chat">The two chats</a>
      <a class="sub" href="#p-quiz">Quizzes</a>
      <a class="sub" href="#p-cert">The certificate</a>

      <a class="part" href="#summary">III. Permissions at a glance</a>
    </nav>
  </aside>

  <main>
    <div class="doc-eyebrow">Operating guide</div>
    <h1 class="doc-title">Boards and Formation Paths</h1>
    <p class="doc-sub">How to use the two formation features of the Urdu Focolare Archive: boards for announcements and curated material, and formation paths for structured courses with enrollment, quizzes and a certificate.</p>
    <div class="doc-meta">
      <span><b>For:</b> formatori, Coordinator, Admin</span>
      <span><b>Where:</b> the "Boards" and "Formation Paths" tabs</span>
    </div>

    <!-- ============================================================ PART I ============================================================ -->
    <div class="part-header" id="boards">
      <span class="part-num">I</span>
      <h1>Boards</h1>
    </div>
    <p class="part-intro">A board is a channel per group (Children, Teenagers, Young people, Adults, Families, Priests...) where formatori publish announcements and curated documents, and everyone else reads. No comments: it's a one-way stream, built for formation communication, not discussion.</p>

    <section class="step" id="b-what">
      <h2><span class="step-no">§1</span> What a board is</h2>
      <p class="lede">Each board matches one archive group. A post can hold free text, a linked archive document (with an Urdu text preview), or both.</p>
      <div class="box who">
        <div class="box-label">Who sees what</div>
        <p>Every registered user reads every board. Only someone named <b>editor</b> of a specific board can post there — or Coordinator/Admin, who can post anywhere.</p>
      </div>
    </section>

    <section class="step" id="b-editor">
      <h2><span class="step-no">§2</span> Becoming a board editor</h2>
      <p class="lede">You can't name yourself: only Coordinator or Admin assign editors, board by board (see <a href="#b-editors">§6</a>). If you don't see the <span class="chip">+ New post</span> button on a board, you haven't been named for that group yet.</p>
    </section>

    <section class="step" id="b-post">
      <h2><span class="step-no">§3</span> Publishing a post</h2>
      <ol class="steps">
        <li>Open the right group's board from the tabs at the top, then <span class="chip">+ New post</span>.</li>
        <li>Write a title. Text is optional if you attach a document, required for a text-only post.</li>
        <li>To attach an archive document, open it from the Dashboard and use its "+ Board" button — it pre-fills the post with the title and an Urdu text preview.</li>
        <li>Save: the post appears immediately at the top of the board.</li>
      </ol>
    </section>

    <section class="step" id="b-manage">
      <h2><span class="step-no">§4</span> Edit, pin, delete</h2>
      <p class="lede">Under each of your own posts you'll find <span class="chip">Edit</span> and <span class="chip">Delete</span>. Coordinator and Admin see them on every post, on any board.</p>
      <p>The <span class="chip">Pin</span> button (Coordinator/Admin only) fixes a post at the top of the board, ahead of everything else — useful for an urgent notice that shouldn't scroll away.</p>
    </section>

    <section class="step" id="b-read">
      <h2><span class="step-no">§5</span> The "✓ Read" mark</h2>
      <p class="lede">Every post keeps count of who has opened it — with nothing to click.</p>
      <div class="box rule">
        <div class="box-label">How it actually works</div>
        <p>Read tracking is recorded <b>on its own</b> the moment you open the board — it's not a button. Under the post you'll see "<span class="chip">N read</span>" and, once you've seen it, "<span class="chip">you read this ✓</span>".</p>
      </div>
      <p>The count is visible to everyone; the <b>named list</b> — behind the <span class="chip">Who?</span> link — is visible only to that board's editor and to Coordinator/Admin. A regular user sees how many people read it, never who.</p>
    </section>

    <section class="step" id="b-editors">
      <h2><span class="step-no">§6</span> Managing a board's editors</h2>
      <p class="lede">Coordinator and Admin only, at the bottom of the Boards page.</p>
      <ol class="steps">
        <li>Pick the board from the "Board" dropdown.</li>
        <li>Search for the person by name or email in the search box, and click the result to add them.</li>
        <li>To remove someone, click <span class="chip">Remove</span> next to their name.</li>
      </ol>
    </section>

    <!-- ============================================================ PART II ============================================================ -->
    <div class="part-header" id="paths">
      <span class="part-num">II</span>
      <h1>Formation Paths</h1>
    </div>
    <p class="part-intro">A formation path is a real structured course: years, modules, chapters, quizzes, and — once completed — a certificate. Unlike boards, which stay a scattered stream of notices, a path's content has an order to follow.</p>

    <section class="step" id="p-what">
      <h2><span class="step-no">§1</span> What a path is, and who sees it</h2>
      <div class="box rule">
        <div class="box-label">The rule that governs everything</div>
        <p>The <b>content</b> of a published path is always readable by anyone, enrolled or not — to get a sense of it before committing, or to revisit it even after finishing. <b>Enrolling</b> only unlocks three things: the chat with fellow enrollees, the quizzes, and the final certificate.</p>
      </div>
      <p>While a path is a <span class="chip">Draft</span>, only the people building it can see it: the owner, Coordinator/Admin, and — so they can offer advice — any other formatore. Once it's <span class="chip">Published</span>, it opens to everyone.</p>
    </section>

    <section class="step" id="p-create">
      <h2><span class="step-no">§2</span> Creating a path</h2>
      <div class="box who">
        <div class="box-label">Who can create one</div>
        <p>Only someone who is already an editor of at least one board. Whatever path you create, you're its sole owner — no one else can edit it, except Coordinator/Admin.</p>
      </div>
      <ol class="steps">
        <li>Go to the <span class="chip">Formation Paths</span> tab → <span class="chip">+ New path</span>.</li>
        <li>Fill in title, description, target audience, and whether it's a regular path (October–May) or a summer one (June–September).</li>
        <li>If you plan a time-limited enrollment, also set the course start/end dates and the enrollment deadline.</li>
        <li>Save: it's born as a <span class="chip">Draft</span>, visible only to you (and other formatori).</li>
      </ol>
    </section>

    <section class="step" id="p-structure">
      <h2><span class="step-no">§3</span> Building the structure</h2>
      <p class="lede">A path is a four-level hierarchy:</p>
      <div class="indent-tree">
        <div class="lvl1">Year 1, Year 2...</div>
        <div class="lvl2">Module — e.g. "Foundations of Unity"</div>
        <div class="lvl3">Chapter — e.g. "Love as the First Commandment"</div>
        <div class="lvl4">Post — a piece of text, inside the chapter</div>
      </div>
      <p>Every level has the same controls: the <span class="chip">▲ ▼</span> arrows to reorder, <span class="chip">+</span> to add the level below, and <span class="chip">Delete</span> — which also deletes everything it contains, with no way back.</p>
      <div class="box tip">
        <div class="box-label">A post is text-only for now</div>
        <p>Unlike board posts, a path post can't yet be linked to an archive document — just a title and free text.</p>
      </div>
    </section>

    <section class="step" id="p-publish">
      <h2><span class="step-no">§4</span> Publish, archive, delete</h2>
      <ul class="plain">
        <li><span class="chip">Publish</span> — opens the path to everyone. Do it once the structure is ready, even if incomplete: you can always keep adding afterward.</li>
        <li><span class="chip">Archive</span> — pulls it from the public catalog without deleting it: it stays visible to you, to enrollees already inside, and to Coordinator/Admin.</li>
        <li><span class="chip">Delete path</span> — permanent deletion, along with everything it contains (enrollments, chat, quizzes, certificates included).</li>
      </ul>
    </section>

    <section class="step" id="p-enroll">
      <h2><span class="step-no">§5</span> Enrollment</h2>
      <p class="lede">A published path shows an enrollee count ("N enrolled") and, for anyone not yet in, an <span class="chip">Enroll</span> button — until the deadline set at creation passes. After that, the button disappears and only "Enrollment is closed for this path" remains: the deadline is enforced on the server too, not just hidden on screen.</p>
      <p>Anyone can leave at any time with <span class="chip">Withdraw</span>, with no time limit. The named list of enrollees (<span class="chip">Who?</span>) stays visible only to the path's owner and to Coordinator/Admin.</p>
    </section>

    <section class="step" id="p-chat">
      <h2><span class="step-no">§6</span> The two chats</h2>
      <p class="lede">Every path has two separate conversation spaces, behind the collapsible <span class="chip">▸ Discussion</span> and <span class="chip">▸ Formatori notes</span> entries.</p>
      <div class="matrix-wrap">
        <table class="matrix">
          <thead><tr><th></th><th>Discussion</th><th>Formatori notes</th></tr></thead>
          <tbody>
            <tr><th>Who sees and writes</th><td>Enrollees + owner + Coordinator/Admin</td><td>Any formatore + Coordinator/Admin</td></tr>
            <tr><th>What it's for</th><td>Questions and exchange among people taking the course</td><td>Advice and improvements among formatori</td></tr>
            <tr><th>Works while still a draft?</th><td class="no">No — needs a published path</td><td class="yes">Yes, on purpose</td></tr>
          </tbody>
        </table>
      </div>
      <p>"Formatori notes" stays invisible to enrollees no matter what: it's the behind-the-scenes space for formatori to compare notes, even before a path is ready for the public.</p>
    </section>

    <section class="step" id="p-quiz">
      <h2><span class="step-no">§7</span> Quizzes</h2>
      <p class="lede">Every module can have a quiz, and the path a final exam — both multiple choice, with a pass threshold the formatore decides.</p>
      <ol class="steps">
        <li>In the module (or at the top of the path, for the final exam) click <span class="chip">+ Add quiz</span> / <span class="chip">+ Add final exam</span>, give it a title and a pass percentage.</li>
        <li>Open <span class="chip">Manage</span> → <span class="chip">+ Add question</span>: write the question, one option per line, and the number of the correct option.</li>
        <li>Enrollees see <span class="chip">Take quiz</span>: they answer and get their score and outcome immediately.</li>
      </ol>
      <div class="box tip">
        <div class="box-label">No penalty for trying</div>
        <p>Attempts are unlimited — you can retry until you pass, only the best result counts. No lockouts after a wrong attempt.</p>
      </div>
    </section>

    <section class="step" id="p-cert">
      <h2><span class="step-no">§8</span> The certificate</h2>
      <p class="lede">It's awarded automatically, never by hand: the moment an enrollee passes <b>every</b> module quiz and the final exam (if the path has one), the certificate appears on its own.</p>
      <p>It stays visible in two places: at the top of the path itself, and on the <span class="chip">My Profile</span> page of whoever earned it, under "My Certificates" — with a date and code, permanently, even if the path is later archived.</p>
    </section>

    <!-- ============================================================ PART III ============================================================ -->
    <div class="part-header" id="summary">
      <span class="part-num">III</span>
      <h1>Permissions at a glance</h1>
    </div>
    <p class="part-intro">Who can do what, at a glance.</p>

    <div class="matrix-wrap">
      <table class="matrix">
        <thead><tr><th>Action</th><th>User</th><th>Formatore</th><th>Coordinator / Admin</th></tr></thead>
        <tbody>
          <tr><th>Read published boards and paths</th><td class="yes">Yes</td><td class="yes">Yes</td><td class="yes">Yes</td></tr>
          <tr><th>Post to a board</th><td class="no">—</td><td>their own boards only</td><td class="yes">Anywhere</td></tr>
          <tr><th>See who read a post</th><td class="no">—</td><td>their own boards only</td><td class="yes">Anywhere</td></tr>
          <tr><th>Create a formation path</th><td class="no">—</td><td class="yes">Yes</td><td class="yes">Yes</td></tr>
          <tr><th>Edit someone else's path</th><td class="no">—</td><td>no ("Formatori notes" only)</td><td class="yes">Yes</td></tr>
          <tr><th>Enroll in a path</th><td class="yes">Yes</td><td class="yes">Yes</td><td class="yes">Yes</td></tr>
          <tr><th>See the enrollee list</th><td class="no">—</td><td>their own paths only</td><td class="yes">Anywhere</td></tr>
          <tr><th>Write in "Formatori notes"</th><td class="no">—</td><td class="yes">On any path</td><td class="yes">On any path</td></tr>
        </tbody>
      </table>
    </div>

    <p class="end-note">Guide current as of 09/11/2026 — features built in Phases A–D of "Formation Paths" and the boards' "✓ Read" function.</p>
  </main>
</div>
$q_bp_en$, 5, now(), 'alessanpk@gmail.com')
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

select 'help_pages boards_paths_it/en', (select count(*) = 2 from help_pages where slug in ('boards_paths_it','boards_paths_en')) as ok;
