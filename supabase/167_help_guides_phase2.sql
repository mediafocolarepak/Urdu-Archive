-- 167: the Help guides follow the new layout for Users and Operators (Owner's decisions, 2026-11-25): Home, Library, My work,
-- Share with us as the one door, My Profile. English and Italian only: the Urdu guides wait for the Owner's words.
-- Replaces only these sentences, so any other edit made to the guides in the app stays. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('find-read_en', $g$It is called <b>Library</b> for Users and <b>Dashboard</b> for everyone on the team.$g$, $g$It is the <b>Library</b>, in Home. Operators also find it in <b>My work</b>, as <b>Library, to work on</b>; for Coordinators and Admins it is called <b>Dashboard</b>.$g$),
      ('find-read_it', $g$Si chiama <b>Library</b> per gli User e <b>Dashboard</b> per chi fa parte del team.$g$, $g$È la <b>Library</b>, nella Home. Gli Operatori la trovano anche in <b>My work</b>, come <b>Library, to work on</b>; per Coordinatori e Admin si chiama <b>Dashboard</b>.$g$),
      ('find-read_en', $g$<li><b>Report a problem</b>: tells the team, with the document number already filled in.</li>$g$, $g$<li><b>Something to say about this text?</b> (for those at work on it, <b>Report a problem</b>): opens <b>Share with us</b>, with the document number already filled in.</li>$g$),
      ('find-read_it', $g$<li><b>Report a problem</b>: avvisa il team, con il numero del documento già compilato.</li>$g$, $g$<li><b>Something to say about this text?</b> (per chi ci sta lavorando, <b>Report a problem</b>): apre <b>Share with us</b>, con il numero del documento già compilato.</li>$g$),
      ('find-read_en', $g$In <b>Start Here</b>, the first button opens$g$, $g$In <b>Home</b>, the first button opens$g$),
      ('find-read_it', $g$In <b>Start Here</b>, il primo pulsante apre$g$, $g$In <b>Home</b>, il primo pulsante apre$g$),
      ('propose_en', $g$or <b>+ Propose content</b> on the Dashboard$g$, $g$or <b>+ Propose content</b> in <b>Library, to work on</b> (Dashboard for Coordinators and Admins)$g$),
      ('propose_it', $g$oppure <b>+ Propose content</b> sulla Dashboard$g$, $g$oppure <b>+ Propose content</b> in <b>Library, to work on</b> (Dashboard per Coordinatori e Admin)$g$),
      ('tasks_en', $g$Credits appear under <b>My credits</b> and in the top bar.$g$, $g$Credits appear under <b>My credits</b> and at the top of <b>My work</b>.$g$),
      ('tasks_it', $g$I crediti compaiono sotto <b>My credits</b> e nella barra in alto.$g$, $g$I crediti compaiono sotto <b>My credits</b> e in cima a <b>My work</b>.$g$),
      ('tasks_en', $g$You see it in the top bar.$g$, $g$You see it at the top of <b>My work</b>.$g$),
      ('tasks_it', $g$Lo vedi nella barra in alto.$g$, $g$Lo vedi in cima a <b>My work</b>.$g$),
      ('teamwork_en', $g$<tr><td>A problem with a document or the app</td><td><b>Report a Problem or Suggestion</b>, or <b>Messages</b> if you are a Coordinator</td></tr>$g$, $g$<tr><td>A problem with a document or the app</td><td><b>Share with us</b>, or <b>Messages</b> if you are a Coordinator</td></tr>$g$),
      ('teamwork_it', $g$<tr><td>Un problema con un documento o con l'app</td><td><b>Report a Problem or Suggestion</b>, o <b>Messages</b> se sei Coordinatore</td></tr>$g$, $g$<tr><td>Un problema con un documento o con l'app</td><td><b>Share with us</b>, o <b>Messages</b> se sei Coordinatore</td></tr>$g$),
      ('talk-team_en', $g$<p class="lead">There are different places for different things, so that nothing gets lost.</p>$g$, $g$<p class="lead">There is one door to speak to the team: <b>Share with us</b>, always in the bar. An experience, an idea, a mistake or something that doesn't work: each reaches the right people.</p>$g$),
      ('talk-team_it', $g$<p class="lead">Ci sono posti diversi per cose diverse, così nulla va perso.</p>$g$, $g$<p class="lead">Per parlare con il team c'è una porta sola: <b>Share with us</b>, sempre nella barra. Un'esperienza, un'idea, un errore o qualcosa che non funziona: ogni cosa arriva alle persone giuste.</p>$g$),
      ('talk-team_en', $g$<tr><td>Report a mistake, a file that won't open, a suggestion</td><td><b>Report a Problem or Suggestion</b></td></tr>
<tr><td>Share an experience, a difficulty, an idea</td><td><b>Share with us</b></td></tr>$g$, $g$<tr><td>Share an experience or an idea, report a mistake or something that doesn't work</td><td><b>Share with us</b></td></tr>$g$),
      ('talk-team_it', $g$<tr><td>Segnalare un errore, un file che non si apre, un suggerimento</td><td><b>Report a Problem or Suggestion</b></td></tr>
<tr><td>Condividere un'esperienza, una difficoltà, un'idea</td><td><b>Share with us</b></td></tr>$g$, $g$<tr><td>Condividere un'esperienza o un'idea, segnalare un errore o qualcosa che non funziona</td><td><b>Share with us</b></td></tr>$g$),
      ('talk-team_en', $g$<h2>Report a problem</h2>
<ol>
<li>Choose the <b>Report type</b> and write your message. If it concerns a document, add its number, or press <b>Report a problem</b> on the document itself.</li>
<li>Press <b>Send</b>. The Coordinators and Admins read it and reply on the same page. You see a notice when a reply arrives.</li>
</ol>
<h2>Share with us</h2>
<p>This isn't for technical problems. It is for what you live and think, and every department lead reads it. Write, or press <b>Record a voice message</b> if your phone allows it. You see any thanks and replies on the same page.</p>$g$, $g$<h2>Share with us</h2>
<ol>
<li><b>Choose what it is about.</b> Under the choices you read who will receive it.</li>
<li><b>Say it or write it</b>, in the language you prefer. <b>Record a voice message</b> appears if your phone allows it. If it concerns a document, add its number, or start from the document itself: the number is already there.</li>
<li><b>Press Send.</b> Thanks and replies appear on the same page, and you see a notice when one arrives.</li>
</ol>
<table><tr><th>Choose</th><th>Who reads or hears it</th></tr>
<tr><td><b>My experience with the App</b></td><td>The leads of the departments and the Admins</td></tr>
<tr><td><b>How to improve the app, an idea</b></td><td>The Coordinators, the leads of the departments and the Admins</td></tr>
<tr><td><b>A mistake in a text</b></td><td>The Coordinators and the Admins</td></tr>
<tr><td><b>Something doesn't work</b></td><td>The Coordinators and the Admins</td></tr></table>$g$),
      ('talk-team_it', $g$<h2>Segnalare un problema</h2>
<ol>
<li>Scegli il <b>Report type</b> e scrivi il messaggio. Se riguarda un documento, aggiungi il numero, oppure premi <b>Report a problem</b> sul documento stesso.</li>
<li>Premi <b>Send</b>. Coordinatori e Admin lo leggono e rispondono nella stessa pagina. Vedi un avviso quando arriva una risposta.</li>
</ol>
<h2>Share with us</h2>
<p>Non è per i problemi tecnici. È per ciò che vivi e pensi, e lo leggono tutti i responsabili di reparto. Scrivi, oppure premi <b>Record a voice message</b> se il telefono lo consente. Ringraziamenti e risposte li vedi nella stessa pagina.</p>$g$, $g$<h2>Share with us</h2>
<ol>
<li><b>Scegli di che cosa si tratta.</b> Sotto le scelte leggi chi lo riceverà.</li>
<li><b>Dillo o scrivilo</b>, nella lingua che preferisci. <b>Record a voice message</b> compare se il telefono lo consente. Se riguarda un documento, aggiungi il numero, oppure parti dal documento stesso: il numero c'è già.</li>
<li><b>Premi Send.</b> Ringraziamenti e risposte compaiono nella stessa pagina, e vedi un avviso quando ne arriva uno.</li>
</ol>
<table><tr><th>Scegli</th><th>Chi lo legge o lo ascolta</th></tr>
<tr><td><b>My experience with the App</b></td><td>I responsabili dei reparti e gli Admin</td></tr>
<tr><td><b>How to improve the app, an idea</b></td><td>I Coordinatori, i responsabili dei reparti e gli Admin</td></tr>
<tr><td><b>A mistake in a text</b></td><td>I Coordinatori e gli Admin</td></tr>
<tr><td><b>Something doesn't work</b></td><td>I Coordinatori e gli Admin</td></tr></table>$g$),
      ('talk-team_en', $g$If you are accepted you become an Operator and new tabs appear.$g$, $g$If you are accepted you become an Operator, and <b>My work</b> appears in the bar. Your Home stays the same.$g$),
      ('talk-team_it', $g$Se vieni accettato diventi Operatore e compaiono nuove schede.$g$, $g$Se vieni accettato diventi Operatore, e nella barra compare <b>My work</b>. La tua Home resta la stessa.$g$),
      ('talk-team_en', $g$<li><b>Change my password</b> and <b>Sign out</b>.</li>
<li><b>My Certificates</b>, from the formation paths.</li>$g$, $g$<li><b>Personal details</b>, at the top.</li>
<li><b>Tokens of appreciation and certificates</b>.</li>
<li><b>Text and colours on this device</b>.</li>
<li><b>Change my password</b>.</li>$g$),
      ('talk-team_it', $g$<li><b>Change my password</b> e <b>Sign out</b>.</li>
<li><b>My Certificates</b>, dai percorsi formativi.</li>$g$, $g$<li><b>Personal details</b>, in cima.</li>
<li><b>Tokens of appreciation and certificates</b>.</li>
<li><b>Text and colours on this device</b>.</li>
<li><b>Change my password</b>.</li>$g$),
      ('talk-team_en', $g$Only you, Admin and the HR lead can see it.</li>
</ul>$g$, $g$Only you, Admin and the HR lead can see it.</li>
<li><b>Sign out</b>, at the end of the page.</li>
</ul>$g$),
      ('talk-team_it', $g$Lo vedono solo tu, gli Admin e il responsabile di HR.</li>
</ul>$g$, $g$Lo vedono solo tu, gli Admin e il responsabile di HR.</li>
<li><b>Sign out</b>, in fondo alla pagina.</li>
</ul>$g$),
      ('role-lead_en', $g$<li><b>Share with us:</b> every lead reads$g$, $g$<li><b>What people shared</b>, in My work (<b>Share with us</b> for Coordinators and Admins): every lead reads$g$),
      ('role-lead_it', $g$<li><b>Share with us:</b> ogni responsabile legge$g$, $g$<li><b>What people shared</b>, in My work (<b>Share with us</b> per Coordinatori e Admin): ogni responsabile legge$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(replace(h.html_content, E'\r\n', E'\n'), replace(c.was, E'\r\n', E'\n'), replace(c.now_is, E'\r\n', E'\n')),
           updated_at = now(), updated_by_email = 'migration 167'
     where h.slug = c.slug
       and strpos(replace(h.html_content, E'\r\n', E'\n'), replace(c.was, E'\r\n', E'\n')) > 0
       and strpos(replace(h.html_content, E'\r\n', E'\n'), replace(c.now_is, E'\r\n', E'\n')) = 0;
  end loop;
  update public.help_pages set summary = 'Share with us, join, your profile' where slug = 'talk-team_en' and summary = 'Report, share, join, your profile';
  update public.help_pages set summary = 'Share with us, unirsi, il tuo profilo' where slug = 'talk-team_it' and summary = 'Segnalare, condividere, unirsi, il tuo profilo';
end $m$;

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- A false row means the sentence had been edited in the app: change that guide by hand.
-- ============================================================================
select 'find-read_en' as item, (select count(*) = 1 from public.help_pages where slug = 'find-read_en'
  and strpos(html_content, $g$It is the <b>Library</b>, in Home. Operators also find it in <b>My work</b>, as <b>Library$g$) > 0
  and strpos(html_content, $g$<li><b>Something to say about this text?</b> (for those at work on it, <b>Report a problem$g$) > 0
  and strpos(html_content, $g$In <b>Home</b>, the first button opens$g$) > 0) as ok
union all select 'find-read_it' as item, (select count(*) = 1 from public.help_pages where slug = 'find-read_it'
  and strpos(html_content, $g$È la <b>Library</b>, nella Home. Gli Operatori la trovano anche in <b>My work</b>, come <b$g$) > 0
  and strpos(html_content, $g$<li><b>Something to say about this text?</b> (per chi ci sta lavorando, <b>Report a proble$g$) > 0
  and strpos(html_content, $g$In <b>Home</b>, il primo pulsante apre$g$) > 0) as ok
union all select 'propose_en' as item, (select count(*) = 1 from public.help_pages where slug = 'propose_en'
  and strpos(html_content, $g$or <b>+ Propose content</b> in <b>Library, to work on</b> (Dashboard for Coordinators and $g$) > 0) as ok
union all select 'propose_it' as item, (select count(*) = 1 from public.help_pages where slug = 'propose_it'
  and strpos(html_content, $g$oppure <b>+ Propose content</b> in <b>Library, to work on</b> (Dashboard per Coordinatori $g$) > 0) as ok
union all select 'tasks_en' as item, (select count(*) = 1 from public.help_pages where slug = 'tasks_en'
  and strpos(html_content, $g$Credits appear under <b>My credits</b> and at the top of <b>My work</b>.$g$) > 0
  and strpos(html_content, $g$You see it at the top of <b>My work</b>.$g$) > 0) as ok
union all select 'tasks_it' as item, (select count(*) = 1 from public.help_pages where slug = 'tasks_it'
  and strpos(html_content, $g$I crediti compaiono sotto <b>My credits</b> e in cima a <b>My work</b>.$g$) > 0
  and strpos(html_content, $g$Lo vedi in cima a <b>My work</b>.$g$) > 0) as ok
union all select 'teamwork_en' as item, (select count(*) = 1 from public.help_pages where slug = 'teamwork_en'
  and strpos(html_content, $g$<tr><td>A problem with a document or the app</td><td><b>Share with us</b>, or <b>Messages<$g$) > 0) as ok
union all select 'teamwork_it' as item, (select count(*) = 1 from public.help_pages where slug = 'teamwork_it'
  and strpos(html_content, $g$<tr><td>Un problema con un documento o con l'app</td><td><b>Share with us</b>, o <b>Messag$g$) > 0) as ok
union all select 'talk-team_en' as item, (select count(*) = 1 from public.help_pages where slug = 'talk-team_en'
  and strpos(html_content, $g$<p class="lead">There is one door to speak to the team: <b>Share with us</b>, always in th$g$) > 0
  and strpos(html_content, $g$<tr><td>Share an experience or an idea, report a mistake or something that doesn't work</t$g$) > 0
  and strpos(html_content, $g$<li><b>Choose what it is about.</b> Under the choices you read who will receive it.</li>$g$) > 0
  and strpos(html_content, $g$If you are accepted you become an Operator, and <b>My work</b> appears in the bar. Your Ho$g$) > 0
  and strpos(html_content, $g$<li><b>Tokens of appreciation and certificates</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Sign out</b>, at the end of the page.</li>$g$) > 0) as ok
union all select 'talk-team_it' as item, (select count(*) = 1 from public.help_pages where slug = 'talk-team_it'
  and strpos(html_content, $g$<p class="lead">Per parlare con il team c'è una porta sola: <b>Share with us</b>, sempre n$g$) > 0
  and strpos(html_content, $g$<tr><td>Condividere un'esperienza o un'idea, segnalare un errore o qualcosa che non funzio$g$) > 0
  and strpos(html_content, $g$<li><b>Scegli di che cosa si tratta.</b> Sotto le scelte leggi chi lo riceverà.</li>$g$) > 0
  and strpos(html_content, $g$Se vieni accettato diventi Operatore, e nella barra compare <b>My work</b>. La tua Home re$g$) > 0
  and strpos(html_content, $g$<li><b>Tokens of appreciation and certificates</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Sign out</b>, in fondo alla pagina.</li>$g$) > 0) as ok
union all select 'role-lead_en' as item, (select count(*) = 1 from public.help_pages where slug = 'role-lead_en'
  and strpos(html_content, $g$<li><b>What people shared</b>, in My work (<b>Share with us</b> for Coordinators and Admin$g$) > 0) as ok
union all select 'role-lead_it' as item, (select count(*) = 1 from public.help_pages where slug = 'role-lead_it'
  and strpos(html_content, $g$<li><b>What people shared</b>, in My work (<b>Share with us</b> per Coordinatori e Admin):$g$) > 0) as ok
union all select 'no old place is named in English and Italian', not exists (select 1 from public.help_pages where language in ('en', 'it') and (html_content like '%Report a Problem or Suggestion%' or html_content like '%Report type%' or html_content like '%in the top bar%' or html_content like '%barra in alto%' or html_content like '%In <b>Start Here</b>%'))
union all select 'the Urdu guides are untouched', not exists (select 1 from public.help_pages where language = 'ur' and updated_by_email = 'migration 167')
union all select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
