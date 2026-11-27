-- 189: the guides of Admins and Coordinators after the new My work (Owner's request, 2026-11-27; migrations 187 and 188).
-- English and Italian. The Urdu guides stay as they are until the Owner asks for them.
--   1. A new guide, "The Overview" (overview_en, overview_it), for Coordinators and Admins.
--   2. "Being an Admin" and "Being a Coordinator": where things are now (Home and My work), and the Overview first every day.
--   3. "Administer": Users and the Overview in My work, the thresholds in Options, and what the app now counts.
--   4. "Leading a department": the departments of all are in My work -> Overview, no longer in Project overview.
-- Changes only these sentences, and does nothing to a guide edited in the app in the same place. Safe to run again.

-- ============================================================================
-- 1. The Overview
-- ============================================================================
insert into public.help_pages (slug, guide_key, language, role, title, summary, section, audience, html_content, sort_order, updated_at, updated_by_email)
values ('overview_en', 'overview', 'en', null, 'The Overview', 'What waits, deadlines, how we are, the weeks', 'run', array['coordinator'], $help_guide$<p class="lead">My work opens on the Overview: what waits for you, and how the project is going. Every box opens the place where it is done.</p>
<h2>Waiting for you</h2>
<p>Tasks to review, proposals, recordings to hear, messages, and what each department has to decide. The oldest first. A box turns red when the oldest has waited more than 7 days.</p>
<h2>Deadlines</h2>
<p>What falls due in the next 30 days, or is late: tasks, department priorities, formation enrolments, and the Word of Life of the month when it has no Urdu text yet. A task taken with no due date comes here after 14 days.</p>
<h2>How we are</h2>
<p>The departments: on track, slowing down, stalled. Admins also see people at risk, funds, space for recordings, and <b>Protection</b>: the four steps that protect the accounts.</p>
<h2>The last 12 weeks</h2>
<p>People who came in each day, documents opened, recordings heard, tasks published, new accounts. One small bar for each week: point at it to see its number. The arrow compares the last 4 weeks with the 4 before.</p>
<p><b>Readings by branch</b> shows how many documents were opened and how many recordings were heard by each branch of the Focolare. The app keeps only numbers, by day: never who, never which document.</p>
<h2>The archive: how far we are</h2>
<p>Link-ups in Urdu, Urdu texts with English, Urdu PDFs with typed text, texts reread, months of the Word of Life. Each line opens its search in Find work.</p>
<h2>Shortcuts</h2>
<ul>
<li><b>Since your last visit:</b> a line at the top says what changed since the day you came before.</li>
<li><b>Go to…</b> (or <b>Ctrl+K</b>): write the name of a tool, <b>#1593</b> for a document, <b>task 51</b>, or words of a title. Then press Enter.</li>
<li><b>Favourites:</b> up to 3 tools at the top of My work. They stay on that device.</li>
<li><b>Print the week:</b> the Overview on paper, for a meeting.</li>
</ul>
<p>An Admin changes the 7 and the 14 in <b>Options → Overview</b>.</p>$help_guide$, 248, now(), 'migration 189')
on conflict (slug) do nothing;

insert into public.help_pages (slug, guide_key, language, role, title, summary, section, audience, html_content, sort_order, updated_at, updated_by_email)
values ('overview_it', 'overview', 'it', null, 'L''Overview', 'Che cosa aspetta, scadenze, come stiamo, le settimane', 'run', array['coordinator'], $help_guide$<p class="lead">My work si apre sull'Overview: che cosa ti aspetta, e come va il progetto. Ogni riquadro apre il posto dove si fa.</p>
<h2>Waiting for you</h2>
<p>Task da rivedere, proposte, registrazioni da ascoltare, messaggi, e ciò che ogni reparto deve decidere. Dal più vecchio. Un riquadro diventa rosso quando il più vecchio aspetta da più di 7 giorni.</p>
<h2>Deadlines</h2>
<p>Ciò che scade nei prossimi 30 giorni, o è in ritardo: task, priorità dei reparti, iscrizioni ai percorsi di formazione, e la Parola di vita del mese quando non ha ancora il testo in urdu. Un task preso senza scadenza arriva qui dopo 14 giorni.</p>
<h2>How we are</h2>
<p>I reparti: in linea, rallentati, fermi. Gli Admin vedono anche le persone a rischio, i fondi, lo spazio per le registrazioni, e <b>Protection</b>: i quattro passi che proteggono gli account.</p>
<h2>The last 12 weeks</h2>
<p>Persone entrate ogni giorno, documenti aperti, registrazioni ascoltate, task pubblicati, nuovi account. Una piccola barra per ogni settimana: passaci sopra per vedere il suo numero. La freccia confronta le ultime 4 settimane con le 4 prima.</p>
<p><b>Readings by branch</b> mostra quanti documenti sono stati aperti e quante registrazioni ascoltate da ogni branca del Focolare. L'app tiene solo numeri, per giorno: mai chi, mai quale documento.</p>
<h2>The archive: how far we are</h2>
<p>Link-up in urdu, testi urdu con l'inglese, PDF urdu con il testo battuto, testi riletti, mesi della Parola di vita. Ogni riga apre la sua ricerca in Find work.</p>
<h2>Scorciatoie</h2>
<ul>
<li><b>Since your last visit:</b> una riga in alto dice che cosa è cambiato dal giorno in cui sei venuto prima.</li>
<li><b>Go to…</b> (o <b>Ctrl+K</b>): scrivi il nome di uno strumento, <b>#1593</b> per un documento, <b>task 51</b>, o parole di un titolo. Poi premi Invio.</li>
<li><b>Favourites:</b> fino a 3 strumenti in cima a My work. Restano su quel dispositivo.</li>
<li><b>Print the week:</b> l'Overview su carta, per un incontro.</li>
</ul>
<p>Un Admin cambia il 7 e il 14 in <b>Options → Overview</b>.</p>$help_guide$, 248, now(), 'migration 189')
on conflict (slug) do nothing;

-- ============================================================================
-- 2-4. Sentences of the other guides: [slug, what is there, what goes there]
-- ============================================================================
do $m$
declare c record;
begin
  for c in
    select * from (values
      -- Being an Admin
      ('role-admin_en', $g$<h2>Only you can</h2>$g$,
        $g$<h2>Home and My work</h2>
<p>You start in <b>Home</b>, like everyone: the Word of Life, the Library, the books, in quiet. The work waits in <b>My work</b>, in the bar; its number says how many things wait for you.</p>
<p>My work opens on the <b>Overview</b>. On a computer the bar on the left then shows the tools in groups: <b>To decide</b>, <b>Archive</b>, <b>Team</b> and <b>Settings</b>. On a phone they are at the bottom of the Overview. <b>‹ Home</b> takes you back. See <a href="#" data-help-guide="overview">The Overview</a>.</p>
<h2>Only you can</h2>$g$),
      ('role-admin_en', $g$<li><b>Tasks → Publish Tasks:</b> what Revisors have approved waits only on you.</li>$g$,
        $g$<li><b>My work → Overview:</b> what waits for you, the oldest first. Each box opens the place where it is done.</li>
<li><b>Tasks → Publish Tasks:</b> what Revisors have approved waits only on you.</li>$g$),
      ('role-admin_en', $g$<li><b>Project overview:</b> read every department's status and note.$g$,
        $g$<li><b>My work → Overview → How we are,</b> and the departments below it: read every department's status and note.$g$),
      ('role-admin_it', $g$<h2>Solo tu puoi</h2>$g$,
        $g$<h2>Home e My work</h2>
<p>Entri in <b>Home</b>, come tutti: la Parola di vita, la Library, i libri, in silenzio. Il lavoro aspetta in <b>My work</b>, nella barra; il suo numero dice quante cose ti aspettano.</p>
<p>My work si apre sull'<b>Overview</b>. Sul computer la barra a sinistra mostra allora gli strumenti in gruppi: <b>To decide</b>, <b>Archive</b>, <b>Team</b> e <b>Settings</b>. Sul telefono sono in fondo all'Overview. <b>‹ Home</b> ti riporta indietro. Vedi <a href="#" data-help-guide="overview">L'Overview</a>.</p>
<h2>Solo tu puoi</h2>$g$),
      ('role-admin_it', $g$<li><b>Tasks → Publish Tasks:</b> ciò che i Revisori hanno approvato aspetta solo te.</li>$g$,
        $g$<li><b>My work → Overview:</b> ciò che ti aspetta, dal più vecchio. Ogni riquadro apre il posto dove si fa.</li>
<li><b>Tasks → Publish Tasks:</b> ciò che i Revisori hanno approvato aspetta solo te.</li>$g$),
      ('role-admin_it', $g$<li><b>Project overview:</b> leggi stato e nota di ogni reparto.$g$,
        $g$<li><b>My work → Overview → How we are,</b> e i reparti più sotto: leggi stato e nota di ogni reparto.$g$),
      -- Being a Coordinator
      ('role-coordinator_en', $g$<h2>Your field</h2>$g$,
        $g$<h2>Home and My work</h2>
<p>You start in <b>Home</b>, like everyone: the Word of Life, the Library, the books, in quiet. The work waits in <b>My work</b>, in the bar; its number says how many things wait for you.</p>
<p>My work opens on the <b>Overview</b>. On a computer the bar on the left then shows the tools in groups: <b>To decide</b>, <b>Archive</b> and <b>Team</b>. On a phone they are at the bottom of the Overview. <b>‹ Home</b> takes you back. See <a href="#" data-help-guide="overview">The Overview</a>.</p>
<h2>Your field</h2>$g$),
      ('role-coordinator_en', $g$<li><b>Messages:</b> reply, or use <b>Create task</b>.</li>$g$,
        $g$<li><b>My work → Overview:</b> what waits for you, the oldest first. Each box opens the place where it is done.</li>
<li><b>Messages:</b> reply, or use <b>Create task</b>.</li>$g$),
      ('role-coordinator_it', $g$<h2>Il tuo campo</h2>$g$,
        $g$<h2>Home e My work</h2>
<p>Entri in <b>Home</b>, come tutti: la Parola di vita, la Library, i libri, in silenzio. Il lavoro aspetta in <b>My work</b>, nella barra; il suo numero dice quante cose ti aspettano.</p>
<p>My work si apre sull'<b>Overview</b>. Sul computer la barra a sinistra mostra allora gli strumenti in gruppi: <b>To decide</b>, <b>Archive</b> e <b>Team</b>. Sul telefono sono in fondo all'Overview. <b>‹ Home</b> ti riporta indietro. Vedi <a href="#" data-help-guide="overview">L'Overview</a>.</p>
<h2>Il tuo campo</h2>$g$),
      ('role-coordinator_it', $g$<li><b>Messages:</b> rispondi, o usa <b>Create task</b>.</li>$g$,
        $g$<li><b>My work → Overview:</b> ciò che ti aspetta, dal più vecchio. Ogni riquadro apre il posto dove si fa.</li>
<li><b>Messages:</b> rispondi, o usa <b>Create task</b>.</li>$g$),
      -- Administer
      ('administer_en', $g$<summary>People: Users tab</summary>$g$, $g$<summary>People: Users</summary>$g$),
      ('administer_en', $g$<p>Change a role from the row.$g$, $g$<p><b>My work → Team → Users.</b> Change a role from the row.$g$),
      ('administer_en', $g$<li><b>Maintenance:</b> one-off tools.</li>$g$,
        $g$<li><b>Overview:</b> after how many days something waiting turns red (7), and a task taken with no due date goes into Deadlines (14).</li>
<li><b>Maintenance:</b> one-off tools.</li>$g$),
      ('administer_en', $g$<li><b>Project overview:</b> all departments and the Users panel. It doesn't record who signs in, by decision.</li>$g$,
        $g$<li><b>My work → Overview:</b> what waits, deadlines, how we are, the last 12 weeks and the archive; below, all departments and the Users panel. The app counts how many people come in each day, by role, and the readings by branch of the Focolare: only numbers, never who.</li>$g$),
      ('administer_it', $g$<summary>Le persone: la scheda Users</summary>$g$, $g$<summary>Le persone: Users</summary>$g$),
      ('administer_it', $g$<p>Cambia un ruolo dalla riga.$g$, $g$<p><b>My work → Team → Users.</b> Cambia un ruolo dalla riga.$g$),
      ('administer_it', $g$<li><b>Maintenance:</b> strumenti una tantum.</li>$g$,
        $g$<li><b>Overview:</b> dopo quanti giorni un'attesa diventa rossa (7), e un task preso senza scadenza va in Deadlines (14).</li>
<li><b>Maintenance:</b> strumenti una tantum.</li>$g$),
      ('administer_it', $g$<li><b>Project overview:</b> tutti i reparti e il pannello Users. Non registra chi accede, per scelta.</li>$g$,
        $g$<li><b>My work → Overview:</b> ciò che aspetta, le scadenze, come stiamo, le ultime 12 settimane e l'archivio; più sotto, tutti i reparti e il pannello Users. L'app conta quante persone entrano ogni giorno, per ruolo, e le letture per branca del Focolare: solo numeri, mai chi.</li>$g$),
      -- Leading a department
      ('role-lead_en', $g$Admins see all departments together in <b>Project overview</b>.$g$, $g$Admins see all departments together in <b>My work → Overview</b>.$g$),
      ('role-lead_it', $g$Gli Admin vedono tutti i reparti insieme in <b>Project overview</b>.$g$, $g$Gli Admin vedono tutti i reparti insieme in <b>My work → Overview</b>.$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 189'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means that sentence had been edited in the app: tell the developer.
select 1 as n, 'The Overview guide, in English and Italian' as item,
       (select count(*) = 2 from public.help_pages where guide_key = 'overview' and language in ('en', 'it')) as ok
union all select 2, 'Being an Admin: Home and My work, the Overview every day',
       (select count(*) = 2 from public.help_pages where slug in ('role-admin_en', 'role-admin_it')
          and strpos(html_content, 'data-help-guide="overview"') > 0 and strpos(html_content, '<li><b>My work → Overview:</b>') > 0 and strpos(html_content, 'Project overview') = 0)
union all select 3, 'Being a Coordinator: Home and My work, the Overview every day',
       (select count(*) = 2 from public.help_pages where slug in ('role-coordinator_en', 'role-coordinator_it')
          and strpos(html_content, 'data-help-guide="overview"') > 0 and strpos(html_content, '<li><b>My work → Overview:</b>') > 0)
union all select 4, 'Administer: Users, the Overview, the thresholds',
       (select count(*) = 2 from public.help_pages where slug in ('administer_en', 'administer_it')
          and strpos(html_content, 'My work → Team → Users') > 0 and strpos(html_content, '<li><b>Overview:</b>') > 0 and strpos(html_content, 'Project overview') = 0)
union all select 5, 'Leading a department: the Overview',
       (select count(*) = 2 from public.help_pages where slug in ('role-lead_en', 'role-lead_it') and strpos(html_content, 'Project overview') = 0)
order by n;
