-- 180: the guides follow the four tabs of My Department (Today, Team and chat, Tools, Rules), and say where a person's login is.
-- Run after the new screens are live and after 179. In Urdu only the names of the tabs and of the buttons change.
-- Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('administer_en', $g$<li><b>Policy:</b> decide proposals. You can't decide your own, and no value changes any other way.</li>$g$,
        $g$<li><b>Rules:</b> decide proposals. You can't decide your own, and no value changes any other way.</li>$g$),
      ('administer_en', $g$<p><b>My Department → Formation → Access to reserved documents</b> enables a person. A reserved document is protected in the app, not on Drive.</p>$g$,
        $g$<p><b>My Department → Formation → Reserved documents</b> enables a person. A reserved document is protected in the app, not on Drive.</p>$g$),
      ('administer_it', $g$<li><b>Policy:</b> decidere le proposte. Non puoi decidere le tue, e nessun valore cambia in altro modo.</li>$g$,
        $g$<li><b>Rules:</b> decidere le proposte. Non puoi decidere le tue, e nessun valore cambia in altro modo.</li>$g$),
      ('administer_it', $g$<p><b>My Department → Formation → Access to reserved documents</b> abilita una persona. Un documento riservato è protetto nell'app, non su Drive.</p>$g$,
        $g$<p><b>My Department → Formation → Reserved documents</b> abilita una persona. Un documento riservato è protetto nell'app, non su Drive.</p>$g$),
      ('administer_ur', $g$<li><b>Policy:</b> تجاویز کا فیصلہ۔ آپ اپنی تجویز کا فیصلہ نہیں کر سکتے، اور کوئی قدر کسی اور طرح نہیں بدلتی۔</li>$g$,
        $g$<li><b>Rules:</b> تجاویز کا فیصلہ۔ آپ اپنی تجویز کا فیصلہ نہیں کر سکتے، اور کوئی قدر کسی اور طرح نہیں بدلتی۔</li>$g$),
      ('administer_ur', $g$<p><b>My Department → Formation → Access to reserved documents</b> کسی شخص کو اجازت دیتا ہے۔ مخصوص دستاویز ایپ میں محفوظ ہے، Drive پر نہیں۔</p>$g$,
        $g$<p><b>My Department → Formation → Reserved documents</b> کسی شخص کو اجازت دیتا ہے۔ مخصوص دستاویز ایپ میں محفوظ ہے، Drive پر نہیں۔</p>$g$),
      ('dept-archive_en', $g$<h3>Archive tools</h3>$g$,
        $g$<h3>Tools</h3>$g$),
      ('dept-archive_en', $g$<li><b>Every week:</b> work through some of Match Review and Work Consolidation, and agree in the Team channel who does what, so two people don't do the same.</li>$g$,
        $g$<li><b>Every week:</b> work through some of Match Review and Work Consolidation, and agree in <b>Team and chat</b> who does what, so two people don't do the same.</li>$g$),
      ('dept-archive_it', $g$<h3>Archive tools</h3>$g$,
        $g$<h3>Tools</h3>$g$),
      ('dept-archive_it', $g$<li><b>Ogni settimana:</b> lavora su una parte di Match Review e Work Consolidation, e accordatevi nel Team channel su chi fa che cosa, perché due persone non facciano lo stesso lavoro.</li>$g$,
        $g$<li><b>Ogni settimana:</b> lavora su una parte di Match Review e Work Consolidation, e accordatevi in <b>Team and chat</b> su chi fa che cosa, perché due persone non facciano lo stesso lavoro.</li>$g$),
      ('dept-archive_ur', $g$<h3>Archive tools</h3>$g$,
        $g$<h3>Tools</h3>$g$),
      ('dept-archive_ur', $g$<li><b>ہر ہفتے:</b> Match Review اور Work Consolidation کا کچھ حصہ مکمل کریں، اور Team channel میں طے کریں کہ کون کیا کرے، تاکہ دو لوگ ایک ہی کام نہ کریں۔</li>$g$,
        $g$<li><b>ہر ہفتے:</b> Match Review اور Work Consolidation کا کچھ حصہ مکمل کریں، اور <b>Team and chat</b> میں طے کریں کہ کون کیا کرے، تاکہ دو لوگ ایک ہی کام نہ کریں۔</li>$g$),
      ('dept-communication_en', $g$<h3>Start Here cards</h3>$g$,
        $g$<h3>Tools → Start Here cards</h3>$g$),
      ('dept-communication_it', $g$<h3>Start Here cards</h3>$g$,
        $g$<h3>Tools → Start Here cards</h3>$g$),
      ('dept-communication_ur', $g$<h3>Start Here cards</h3>$g$,
        $g$<h3>Tools → Start Here cards</h3>$g$),
      ('dept-coordination_en', $g$<h3>Extra credits awaiting approval</h3>$g$,
        $g$<h3>Today → Extra credits</h3>$g$),
      ('dept-coordination_en', $g$<h3>Task flow</h3>$g$,
        $g$<h3>Tools → Task flow</h3>$g$),
      ('dept-coordination_en', $g$<p>A live count of the open work: <b>Open</b>, <b>In progress</b>, <b>Awaiting review</b>, <b>Awaiting publish</b>, <b>Overdue</b>. It shows where things pile up and whom to contact. It is read-only: to act, go to <b>Tasks → Team overview</b>.</p>$g$,
        $g$<p>A live count of the open work: <b>Open</b>, <b>In progress</b>, <b>In review</b>, <b>To publish</b>, <b>Late</b>. It shows where things pile up and whom to contact. It is read-only: to act, go to <b>Tasks → Team overview</b>.</p>$g$),
      ('dept-coordination_it', $g$<h3>Extra credits awaiting approval</h3>$g$,
        $g$<h3>Today → Extra credits</h3>$g$),
      ('dept-coordination_it', $g$<h3>Task flow</h3>$g$,
        $g$<h3>Tools → Task flow</h3>$g$),
      ('dept-coordination_it', $g$<p>Un conteggio aggiornato del lavoro aperto: <b>Open</b>, <b>In progress</b>, <b>Awaiting review</b>, <b>Awaiting publish</b>, <b>Overdue</b>. Mostra dove le cose si accumulano e chi contattare. È di sola lettura: per agire, vai in <b>Tasks → Team overview</b>.</p>$g$,
        $g$<p>Un conteggio aggiornato del lavoro aperto: <b>Open</b>, <b>In progress</b>, <b>In review</b>, <b>To publish</b>, <b>Late</b>. Mostra dove le cose si accumulano e chi contattare. È di sola lettura: per agire, vai in <b>Tasks → Team overview</b>.</p>$g$),
      ('dept-coordination_ur', $g$<h3>Extra credits awaiting approval</h3>$g$,
        $g$<h3>Today → Extra credits</h3>$g$),
      ('dept-coordination_ur', $g$<h3>Task flow</h3>$g$,
        $g$<h3>Tools → Task flow</h3>$g$),
      ('dept-coordination_ur', $g$<p>کھلے کام کی تازہ گنتی: <b>Open</b>, <b>In progress</b>, <b>Awaiting review</b>, <b>Awaiting publish</b>, <b>Overdue</b>۔ یہ دکھاتا ہے کہ چیزیں کہاں جمع ہیں اور کس سے رابطہ کریں۔ یہ صرف پڑھنے کے لیے ہے: عمل کے لیے <b>Tasks → Team overview</b> میں جائیں۔</p>$g$,
        $g$<p>کھلے کام کی تازہ گنتی: <b>Open</b>, <b>In progress</b>, <b>In review</b>, <b>To publish</b>, <b>Late</b>۔ یہ دکھاتا ہے کہ چیزیں کہاں جمع ہیں اور کس سے رابطہ کریں۔ یہ صرف پڑھنے کے لیے ہے: عمل کے لیے <b>Tasks → Team overview</b> میں جائیں۔</p>$g$),
      ('dept-formation_en', $g$<h3>Formation pipeline</h3>$g$,
        $g$<h3>Tools → Paths in preparation</h3>$g$),
      ('dept-formation_en', $g$<p>Every path, split into <b>In progress</b> (drafts) and <b>Published</b>. Open one to help or coordinate. This is where the lead sees what the team is writing.</p>$g$,
        $g$<p>Every path, split into <b>Being written</b> (drafts) and <b>Published</b>. Open one to help or coordinate. This is where the lead sees what the team is writing.</p>$g$),
      ('dept-formation_en', $g$<h3>Access to reserved documents</h3>$g$,
        $g$<h3>Tools → Reserved documents</h3>$g$),
      ('dept-formation_en', $g$<li><b>Board misuse:</b> the Formation lead or the HR lead approves what an editor proposes.</li>$g$,
        $g$<li><b>Board misuse:</b> the Formation lead or the HR lead approves what an editor proposes. The Formation lead finds it in <b>Today</b>.</li>$g$),
      ('dept-formation_en', $g$<li><b>Every week:</b> the lead reads the pipeline and asks how each draft is going. Use the Team channel, and <b>Formatori notes</b> for advice on a path.</li>$g$,
        $g$<li><b>Every week:</b> the lead reads the paths and asks how each draft is going. Use <b>Team and chat</b>, and <b>Formatori notes</b> for advice on a path.</li>$g$),
      ('dept-formation_it', $g$<h3>Formation pipeline</h3>$g$,
        $g$<h3>Tools → Paths in preparation</h3>$g$),
      ('dept-formation_it', $g$<p>Tutti i percorsi, divisi in <b>In progress</b> (bozze) e <b>Published</b>. Aprine uno per aiutare o coordinare. Qui il responsabile vede che cosa sta scrivendo il team.</p>$g$,
        $g$<p>Tutti i percorsi, divisi in <b>Being written</b> (bozze) e <b>Published</b>. Aprine uno per aiutare o coordinare. Qui il responsabile vede che cosa sta scrivendo il team.</p>$g$),
      ('dept-formation_it', $g$<h3>Access to reserved documents</h3>$g$,
        $g$<h3>Tools → Reserved documents</h3>$g$),
      ('dept-formation_it', $g$<li><b>Abuso di bacheca:</b> il responsabile di Formazione o di HR approva ciò che propone chi cura la bacheca.</li>$g$,
        $g$<li><b>Abuso di bacheca:</b> il responsabile di Formazione o di HR approva ciò che propone chi cura la bacheca. Il responsabile di Formazione lo trova in <b>Today</b>.</li>$g$),
      ('dept-formation_it', $g$<li><b>Ogni settimana:</b> il responsabile legge la pipeline e chiede come va ogni bozza. Usate il Team channel, e <b>Formatori notes</b> per i consigli su un percorso.</li>$g$,
        $g$<li><b>Ogni settimana:</b> il responsabile legge i percorsi e chiede come va ogni bozza. Usate <b>Team and chat</b>, e <b>Formatori notes</b> per i consigli su un percorso.</li>$g$),
      ('dept-formation_ur', $g$<h3>Formation pipeline</h3>$g$,
        $g$<h3>Tools → Paths in preparation</h3>$g$),
      ('dept-formation_ur', $g$<p>سب راستے، <b>In progress</b> (مسودے) اور <b>Published</b> میں بٹے ہوئے۔ مدد یا رابطہ کاری کے لیے کوئی کھولیں۔ یہاں سربراہ دیکھتا ہے کہ ٹیم کیا لکھ رہی ہے۔</p>$g$,
        $g$<p>سب راستے، <b>Being written</b> (مسودے) اور <b>Published</b> میں بٹے ہوئے۔ مدد یا رابطہ کاری کے لیے کوئی کھولیں۔ یہاں سربراہ دیکھتا ہے کہ ٹیم کیا لکھ رہی ہے۔</p>$g$),
      ('dept-formation_ur', $g$<h3>Access to reserved documents</h3>$g$,
        $g$<h3>Tools → Reserved documents</h3>$g$),
      ('dept-formation_ur', $g$<li><b>ہر ہفتے:</b> سربراہ پائپ لائن پڑھتا اور پوچھتا ہے کہ ہر مسودہ کیسا چل رہا ہے۔ Team channel استعمال کریں، اور راستے پر مشورے کے لیے <b>Formatori notes</b>۔</li>$g$,
        $g$<li><b>ہر ہفتے:</b> سربراہ <b>Paths in preparation</b> پڑھتا اور پوچھتا ہے کہ ہر مسودہ کیسا چل رہا ہے۔ <b>Team and chat</b> استعمال کریں، اور راستے پر مشورے کے لیے <b>Formatori notes</b>۔</li>$g$),
      ('dept-hr_en', $g$<h3>Team Applications</h3>$g$,
        $g$<h3>Tools → Applications</h3>$g$),
      ('dept-hr_en', $g$<h3>People</h3>$g$,
        $g$<h3>Tools → People</h3>$g$),
      ('dept-hr_en', $g$<p>Everyone on the team: role, standing, age group, credits, reputation, qualifications, departments. The HR lead also sees the date of birth; other members see only the age group. You can search and filter. An at-risk mark is a computed hint to look closer: what counts is your decision, never the mark.</p>$g$,
        $g$<p>Everyone on the team: role, standing, age group, credits, reputation, qualifications, departments. The HR lead also sees the date of birth; other members see only the age group. Search a name, then choose a person to see their card. Their login is only there, under <b>Contact</b>, for HR members and Admins. An at-risk mark says why, and is a computed hint to look closer: what counts is your decision, never the mark.</p>$g$),
      ('dept-hr_en', $g$<li><b>Propose…</b> starts a decision about the person, always with a written reason.</li>$g$,
        $g$<li><b>Propose a decision</b> starts a decision about the person, always with a written reason.</li>$g$),
      ('dept-hr_en', $g$<li><b>History</b> shows past decisions, and <b>Activity</b> what the person has changed in the archive. The HR lead and Admins can see Activity.</li>$g$,
        $g$<li><b>History</b> shows past decisions and, for the HR lead and Admins, what the person has changed in the archive. All past decisions are in <b>Tools → Decisions taken</b>.</li>$g$),
      ('dept-hr_en', $g$<h3>Pending decisions</h3>$g$,
        $g$<h3>Today</h3>$g$),
      ('dept-hr_en', $g$<p>What has been proposed and is waiting. Those entitled see <b>Approve</b> and <b>Reject</b>; whoever proposed can <b>Withdraw</b>.</p>$g$,
        $g$<p>What has been proposed and is waiting, in full: from which role to which, which qualification. Those entitled see <b>Approve</b> and <b>Reject</b>; whoever proposed can <b>Take it back</b>.</p>$g$),
      ('dept-hr_en', $g$<li><b>A few times a week:</b> new applications, and Pending decisions. Nobody should wait in silence.</li>$g$,
        $g$<li><b>A few times a week:</b> new applications, and <b>Today</b>. Nobody should wait in silence.</li>$g$),
      ('dept-hr_it', $g$<h3>Team Applications</h3>$g$,
        $g$<h3>Tools → Applications</h3>$g$),
      ('dept-hr_it', $g$<h3>People</h3>$g$,
        $g$<h3>Tools → People</h3>$g$),
      ('dept-hr_it', $g$<p>Tutto il team: ruolo, posizione, fascia d'età, crediti, reputazione, qualifiche, reparti. Il responsabile di HR vede anche la data di nascita; gli altri membri solo la fascia. Puoi cercare e filtrare. Il segno di rischio è un'indicazione calcolata per guardare meglio: conta la tua decisione, mai il segno.</p>$g$,
        $g$<p>Tutto il team: ruolo, posizione, fascia d'età, crediti, reputazione, qualifiche, reparti. Il responsabile di HR vede anche la data di nascita; gli altri membri solo la fascia. Cerca un nome, poi scegli una persona per vedere la sua scheda. Il suo login è solo lì, sotto <b>Contact</b>, per i membri di HR e gli Admin. Il segno di rischio dice il perché, ed è un'indicazione calcolata per guardare meglio: conta la tua decisione, mai il segno.</p>$g$),
      ('dept-hr_it', $g$<li><b>Propose…</b> avvia una decisione sulla persona, sempre con un motivo scritto.</li>$g$,
        $g$<li><b>Propose a decision</b> avvia una decisione sulla persona, sempre con un motivo scritto.</li>$g$),
      ('dept-hr_it', $g$<li><b>History</b> mostra le decisioni passate, e <b>Activity</b> ciò che la persona ha modificato in archivio. Activity la vedono il responsabile di HR e gli Admin.</li>$g$,
        $g$<li><b>History</b> mostra le decisioni passate e, al responsabile di HR e agli Admin, ciò che la persona ha modificato in archivio. Tutte le decisioni passate sono in <b>Tools → Decisions taken</b>.</li>$g$),
      ('dept-hr_it', $g$<h3>Pending decisions</h3>$g$,
        $g$<h3>Today</h3>$g$),
      ('dept-hr_it', $g$<p>Ciò che è stato proposto e aspetta. Chi ne ha titolo vede <b>Approve</b> e <b>Reject</b>; chi ha proposto può fare <b>Withdraw</b>.</p>$g$,
        $g$<p>Ciò che è stato proposto e aspetta, per intero: da quale ruolo a quale, quale qualifica. Chi ne ha titolo vede <b>Approve</b> e <b>Reject</b>; chi ha proposto può fare <b>Take it back</b>.</p>$g$),
      ('dept-hr_it', $g$<li><b>Alcune volte a settimana:</b> nuove candidature e Pending decisions. Nessuno deve aspettare nel silenzio.</li>$g$,
        $g$<li><b>Alcune volte a settimana:</b> nuove candidature e <b>Today</b>. Nessuno deve aspettare nel silenzio.</li>$g$),
      ('dept-hr_ur', $g$<h3>Team Applications</h3>$g$,
        $g$<h3>Tools → Applications</h3>$g$),
      ('dept-hr_ur', $g$<h3>People</h3>$g$,
        $g$<h3>Tools → People</h3>$g$),
      ('dept-hr_ur', $g$<li><b>Propose…</b> اس شخص کے بارے میں فیصلہ شروع کرتا ہے، ہمیشہ تحریری وجہ کے ساتھ۔</li>$g$,
        $g$<li><b>Propose a decision</b> اس شخص کے بارے میں فیصلہ شروع کرتا ہے، ہمیشہ تحریری وجہ کے ساتھ۔</li>$g$),
      ('dept-hr_ur', $g$<li><b>History</b> پچھلے فیصلے دکھاتا ہے، اور <b>Activity</b> وہ جو اس شخص نے آرکائیو میں بدلا۔ Activity کو HR کا سربراہ اور ایڈمن دیکھ سکتے ہیں۔</li>$g$,
        $g$<li><b>History</b> پچھلے فیصلے دکھاتا ہے، اور <b>What this person did in the archive</b> وہ جو اس شخص نے آرکائیو میں بدلا۔ <b>What this person did in the archive</b> کو HR کا سربراہ اور ایڈمن دیکھ سکتے ہیں۔</li>$g$),
      ('dept-hr_ur', $g$<h3>Pending decisions</h3>$g$,
        $g$<h3>Today</h3>$g$),
      ('dept-hr_ur', $g$<p>جو تجویز ہوا اور انتظار میں ہے۔ جن کا حق ہے وہ <b>Approve</b> اور <b>Reject</b> دیکھتے ہیں؛ تجویز کرنے والا <b>Withdraw</b> کر سکتا ہے۔</p>$g$,
        $g$<p>جو تجویز ہوا اور انتظار میں ہے۔ جن کا حق ہے وہ <b>Approve</b> اور <b>Reject</b> دیکھتے ہیں؛ تجویز کرنے والا <b>Take it back</b> کر سکتا ہے۔</p>$g$),
      ('dept-hr_ur', $g$<li><b>ہفتے میں چند بار:</b> نئی درخواستیں اور Pending decisions۔ کوئی خاموشی میں انتظار نہ کرے۔</li>$g$,
        $g$<li><b>ہفتے میں چند بار:</b> نئی درخواستیں اور <b>Today</b>۔ کوئی خاموشی میں انتظار نہ کرے۔</li>$g$),
      ('dept-reward_en', $g$<h3>Credits in circulation</h3>$g$,
        $g$<h3>Tools → Credits</h3>$g$),
      ('dept-reward_en', $g$<h3>Compensation runs</h3>$g$,
        $g$<h3>Tools → Compensation runs</h3>$g$),
      ('dept-reward_en', $g$<p>The record that credits were turned into money. A Reward member prepares a run with <b>New compensation run</b>, listing the people and amounts. An Admin who didn't prepare it decides. The same credits can't enter two runs, and nothing is ever deleted.</p>$g$,
        $g$<p>The record that credits were turned into money. A Reward member prepares a run with <b>+ New run</b>, listing the people and amounts. An Admin who didn't prepare it decides. The same credits can't enter two runs, and nothing is ever deleted.</p>$g$),
      ('dept-reward_en', $g$<h3>Anomaly report</h3>$g$,
        $g$<h3>Tools → Unusual credits</h3>$g$),
      ('dept-reward_en', $g$<h3>Policy</h3>$g$,
        $g$<h3>Rules</h3>$g$),
      ('dept-reward_en', $g$<p>The lead proposes changes to rates, reputation tiers and thresholds with <b>Propose change</b>, with the reason. The team reviews it, and an Admin who isn't the proposer decides. Nobody can change a value directly, Admins included.</p>$g$,
        $g$<p>The lead proposes changes to rates, reputation tiers and thresholds with <b>Change</b>, with the reason. The team reviews it, and an Admin who isn't the proposer decides. Nobody can change a value directly, Admins included.</p>$g$),
      ('dept-reward_en', $g$<li><b>Every week:</b> look at the anomaly report. If something is odd, ask Coordination before concluding anything.</li>$g$,
        $g$<li><b>Every week:</b> look at <b>Unusual credits</b>. If something is odd, ask Coordination before concluding anything.</li>$g$),
      ('dept-reward_it', $g$<h3>Credits in circulation</h3>$g$,
        $g$<h3>Tools → Credits</h3>$g$),
      ('dept-reward_it', $g$<h3>Compensation runs</h3>$g$,
        $g$<h3>Tools → Compensation runs</h3>$g$),
      ('dept-reward_it', $g$<p>La traccia che dei crediti sono diventati denaro. Un membro di Reward prepara un'esecuzione con <b>New compensation run</b>, elencando persone e importi. Decide un Admin che non l'ha preparata. Gli stessi crediti non possono entrare in due esecuzioni, e nulla si cancella mai.</p>$g$,
        $g$<p>La traccia che dei crediti sono diventati denaro. Un membro di Reward prepara un'esecuzione con <b>+ New run</b>, elencando persone e importi. Decide un Admin che non l'ha preparata. Gli stessi crediti non possono entrare in due esecuzioni, e nulla si cancella mai.</p>$g$),
      ('dept-reward_it', $g$<h3>Anomaly report</h3>$g$,
        $g$<h3>Tools → Unusual credits</h3>$g$),
      ('dept-reward_it', $g$<h3>Policy</h3>$g$,
        $g$<h3>Rules</h3>$g$),
      ('dept-reward_it', $g$<p>Il responsabile propone modifiche a tariffe, livelli di reputazione e soglie con <b>Propose change</b>, con il motivo. Il team la esamina, e decide un Admin diverso da chi propone. Nessuno può cambiare un valore direttamente, Admin compresi.</p>$g$,
        $g$<p>Il responsabile propone modifiche a tariffe, livelli di reputazione e soglie con <b>Change</b>, con il motivo. Il team la esamina, e decide un Admin diverso da chi propone. Nessuno può cambiare un valore direttamente, Admin compresi.</p>$g$),
      ('dept-reward_it', $g$<li><b>Ogni settimana:</b> guarda il report delle anomalie. Se qualcosa è strano, chiedi a Coordinamento prima di concludere.</li>$g$,
        $g$<li><b>Ogni settimana:</b> guarda <b>Unusual credits</b>. Se qualcosa è strano, chiedi a Coordinamento prima di concludere.</li>$g$),
      ('dept-reward_ur', $g$<h3>Credits in circulation</h3>$g$,
        $g$<h3>Tools → Credits</h3>$g$),
      ('dept-reward_ur', $g$<h3>Compensation runs</h3>$g$,
        $g$<h3>Tools → Compensation runs</h3>$g$),
      ('dept-reward_ur', $g$<p>اس بات کا ریکارڈ کہ کریڈٹ پیسوں میں بدلے گئے۔ Reward کا رکن <b>New compensation run</b> سے لوگوں اور رقموں کی فہرست بناتا ہے۔ وہ ایڈمن فیصلہ کرتا ہے جس نے تیار نہ کی ہو۔ ایک ہی کریڈٹ دو بار شامل نہیں ہو سکتے، اور کچھ کبھی مٹتا نہیں۔</p>$g$,
        $g$<p>اس بات کا ریکارڈ کہ کریڈٹ پیسوں میں بدلے گئے۔ Reward کا رکن <b>+ New run</b> سے لوگوں اور رقموں کی فہرست بناتا ہے۔ وہ ایڈمن فیصلہ کرتا ہے جس نے تیار نہ کی ہو۔ ایک ہی کریڈٹ دو بار شامل نہیں ہو سکتے، اور کچھ کبھی مٹتا نہیں۔</p>$g$),
      ('dept-reward_ur', $g$<h3>Anomaly report</h3>$g$,
        $g$<h3>Tools → Unusual credits</h3>$g$),
      ('dept-reward_ur', $g$<h3>Policy</h3>$g$,
        $g$<h3>Rules</h3>$g$),
      ('dept-reward_ur', $g$<p>سربراہ شرحوں، ساکھ کے درجوں اور حدوں میں تبدیلی <b>Propose change</b> سے، وجہ کے ساتھ، تجویز کرتا ہے۔ ٹیم غور کرتی ہے اور وہ ایڈمن فیصلہ کرتا ہے جس نے تجویز نہ کی ہو۔ کوئی قدر براہِ راست نہیں بدل سکتا، ایڈمن بھی نہیں۔</p>$g$,
        $g$<p>سربراہ شرحوں، ساکھ کے درجوں اور حدوں میں تبدیلی <b>Change</b> سے، وجہ کے ساتھ، تجویز کرتا ہے۔ ٹیم غور کرتی ہے اور وہ ایڈمن فیصلہ کرتا ہے جس نے تجویز نہ کی ہو۔ کوئی قدر براہِ راست نہیں بدل سکتا، ایڈمن بھی نہیں۔</p>$g$),
      ('dept-reward_ur', $g$<li><b>ہر ہفتے:</b> بے قاعدگیوں کی رپورٹ دیکھیں۔ کچھ عجیب لگے تو نتیجہ نکالنے سے پہلے Coordination سے پوچھیں۔</li>$g$,
        $g$<li><b>ہر ہفتے:</b> <b>Unusual credits</b> دیکھیں۔ کچھ عجیب لگے تو نتیجہ نکالنے سے پہلے Coordination سے پوچھیں۔</li>$g$),
      ('my-department_en', $g$<h2>In order, from the top</h2>$g$,
        $g$<h2>The four tabs</h2>$g$),
      ('my-department_en', $g$<tr><td><b>Status</b></td><td>On track, Slowing down or Stalled, with the lead's note. The app may add a hint under "Data suggests", which is never applied by itself</td><td>The lead or Admin</td></tr>$g$,
        $g$<tr><td><b>Today</b>: to decide</td><td>What waits for your decision, and what waits for others</td><td>Whoever may decide it</td></tr>
<tr><td><b>Today</b>: state</td><td>On track, Slowing down or Stalled, with the lead's note. The app may add a hint under "The numbers say", which is never applied by itself</td><td>The lead or Admin</td></tr>$g$),
      ('my-department_en', $g$<tr><td><b>Priorities</b></td><td>A short list of what the team is focused on, with dates if useful. It isn't a second task system: no assignee and no credits</td><td>The lead or Admin</td></tr>$g$,
        $g$<tr><td><b>Today</b>: What matters now</td><td>A short list of what the team is focused on, with dates if useful. It isn't a second task system: no assignee and no credits</td><td>The lead or Admin</td></tr>$g$),
      ('my-department_en', $g$<tr><td><b>Team</b></td><td>The members and the lead</td><td>The lead or Admin can remove a member. Admin adds members and appoints leads, in Options</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Team</td><td>The members and the lead</td><td>The lead or Admin adds and removes members, by name. Admin appoints leads, in Options</td></tr>$g$),
      ('my-department_en', $g$<tr><td><b>Team channel</b></td><td>A private conversation for the department, with images. Nobody outside it sees it, except Admins</td><td>Any member writes. Your own message can be changed for 15 minutes. The lead or Admin pins</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Chat</td><td>A private conversation for the department, with images. Nobody outside it sees it, except Admins</td><td>Any member writes. Your own message can be changed for 15 minutes. The lead or Admin pins</td></tr>$g$),
      ('my-department_en', $g$<tr><td>The department's own tools</td><td>See its guide</td><td>Depends on the tool</td></tr>$g$,
        $g$<tr><td><b>Tools</b></td><td>The department's own tools, one screen for each. See its guide</td><td>Depends on the tool</td></tr>$g$),
      ('my-department_en', $g$<tr><td><b>Policy</b></td><td>The rules and values in force, and the history of every proposal</td><td>The owning department's lead proposes, and an Admin who isn't the proposer decides</td></tr></table>$g$,
        $g$<tr><td><b>Rules</b></td><td>The rules in force, in plain sentences, and the history of every proposal</td><td>The owning department's lead proposes, and an Admin who isn't the proposer decides</td></tr></table>$g$),
      ('my-department_en', $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: Team Applications, People, Pending decisions</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: People, Applications, Decisions taken</li>$g$),
      ('my-department_en', $g$<li><a href="#" data-help-guide="dept-coordination">Coordination</a>: Extra credits, Task flow</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-coordination">Coordination</a>: Task flow</li>$g$),
      ('my-department_en', $g$<li><a href="#" data-help-guide="dept-formation">Formation</a>: Formation pipeline, Access to reserved documents</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-formation">Formation</a>: Paths in preparation, Reserved documents</li>$g$),
      ('my-department_en', $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits in circulation, Compensation runs, Anomaly report</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits, Compensation runs, Unusual credits, Tokens, Public thanks, Certificates</li>$g$),
      ('my-department_en', $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Archive tools, Deleted documents, Translation prompt</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Hayat Index, Match Review, Work Consolidation, Hayat Editor, Deleted documents, Translation prompt</li>$g$),
      ('my-department_it', $g$<h2>In ordine, dall'alto</h2>$g$,
        $g$<h2>Le quattro schede</h2>$g$),
      ('my-department_it', $g$<tr><td><b>Stato</b></td><td>On track, Slowing down o Stalled, con la nota del responsabile. L'app può aggiungere un'indicazione sotto "Data suggests", che non si applica mai da sola</td><td>Il responsabile o un Admin</td></tr>$g$,
        $g$<tr><td><b>Today</b>: da decidere</td><td>Ciò che aspetta una tua decisione, e ciò che aspetta altri</td><td>Chi può deciderlo</td></tr>
<tr><td><b>Today</b>: stato</td><td>On track, Slowing down o Stalled, con la nota del responsabile. L'app può aggiungere un'indicazione sotto "The numbers say", che non si applica mai da sola</td><td>Il responsabile o un Admin</td></tr>$g$),
      ('my-department_it', $g$<tr><td><b>Priorities</b></td><td>Una lista corta di ciò su cui il team è concentrato, con date se utili. Non è un secondo sistema di task: niente assegnatario e niente crediti</td><td>Il responsabile o un Admin</td></tr>$g$,
        $g$<tr><td><b>Today</b>: What matters now</td><td>Una lista corta di ciò su cui il team è concentrato, con date se utili. Non è un secondo sistema di task: niente assegnatario e niente crediti</td><td>Il responsabile o un Admin</td></tr>$g$),
      ('my-department_it', $g$<tr><td><b>Team</b></td><td>I membri e il responsabile</td><td>Il responsabile o un Admin può togliere un membro. Un Admin aggiunge i membri e nomina i responsabili, in Options</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Team</td><td>I membri e il responsabile</td><td>Il responsabile o un Admin aggiunge e toglie i membri, per nome. Un Admin nomina i responsabili, in Options</td></tr>$g$),
      ('my-department_it', $g$<tr><td><b>Team channel</b></td><td>Una conversazione privata del reparto, con immagini. Da fuori non la vede nessuno, tranne gli Admin</td><td>Ogni membro scrive. Il tuo messaggio si può cambiare per 15 minuti. Il responsabile o un Admin fissa</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Chat</td><td>Una conversazione privata del reparto, con immagini. Da fuori non la vede nessuno, tranne gli Admin</td><td>Ogni membro scrive. Il tuo messaggio si può cambiare per 15 minuti. Il responsabile o un Admin fissa</td></tr>$g$),
      ('my-department_it', $g$<tr><td>Gli strumenti del reparto</td><td>Vedi la sua guida</td><td>Dipende dallo strumento</td></tr>$g$,
        $g$<tr><td><b>Tools</b></td><td>Gli strumenti del reparto, una schermata per ciascuno. Vedi la sua guida</td><td>Dipende dallo strumento</td></tr>$g$),
      ('my-department_it', $g$<tr><td><b>Policy</b></td><td>Le regole e i valori in vigore, e la storia di ogni proposta</td><td>Propone il responsabile del reparto competente, decide un Admin diverso da chi propone</td></tr></table>$g$,
        $g$<tr><td><b>Rules</b></td><td>Le regole in vigore, in frasi semplici, e la storia di ogni proposta</td><td>Propone il responsabile del reparto competente, decide un Admin diverso da chi propone</td></tr></table>$g$),
      ('my-department_it', $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: Team Applications, People, Pending decisions</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: People, Applications, Decisions taken</li>$g$),
      ('my-department_it', $g$<li><a href="#" data-help-guide="dept-coordination">Coordinamento</a>: Extra credits, Task flow</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-coordination">Coordinamento</a>: Task flow</li>$g$),
      ('my-department_it', $g$<li><a href="#" data-help-guide="dept-formation">Formazione</a>: Formation pipeline, Access to reserved documents</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-formation">Formazione</a>: Paths in preparation, Reserved documents</li>$g$),
      ('my-department_it', $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits in circulation, Compensation runs, Anomaly report</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits, Compensation runs, Unusual credits, Tokens, Public thanks, Certificates</li>$g$),
      ('my-department_it', $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Archive tools, Deleted documents, Translation prompt</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Hayat Index, Match Review, Work Consolidation, Hayat Editor, Deleted documents, Translation prompt</li>$g$),
      ('my-department_ur', $g$<h2>ترتیب سے، اوپر سے</h2>$g$,
        $g$<h2>اس صفحے کے حصے</h2>$g$),
      ('my-department_ur', $g$<tr><td><b>حالت</b></td><td>On track, Slowing down یا Stalled، سربراہ کے نوٹ کے ساتھ۔ ایپ "Data suggests" کے نیچے اشارہ دے سکتی ہے، جو کبھی خود لاگو نہیں ہوتا</td><td>سربراہ یا ایڈمن</td></tr>$g$,
        $g$<tr><td><b>Today</b>: حالت</td><td>On track, Slowing down یا Stalled، سربراہ کے نوٹ کے ساتھ۔ ایپ "The numbers say" کے نیچے اشارہ دے سکتی ہے، جو کبھی خود لاگو نہیں ہوتا</td><td>سربراہ یا ایڈمن</td></tr>$g$),
      ('my-department_ur', $g$<tr><td><b>Priorities</b></td><td>مختصر فہرست کہ ٹیم کس چیز پر توجہ دے رہی ہے، ضرورت ہو تو تاریخوں کے ساتھ۔ یہ دوسرا ٹاسک نظام نہیں: نہ ذمہ دار، نہ کریڈٹ</td><td>سربراہ یا ایڈمن</td></tr>$g$,
        $g$<tr><td><b>Today</b>: What matters now</td><td>مختصر فہرست کہ ٹیم کس چیز پر توجہ دے رہی ہے، ضرورت ہو تو تاریخوں کے ساتھ۔ یہ دوسرا ٹاسک نظام نہیں: نہ ذمہ دار، نہ کریڈٹ</td><td>سربراہ یا ایڈمن</td></tr>$g$),
      ('my-department_ur', $g$<tr><td><b>Team</b></td><td>ارکان اور سربراہ</td><td>سربراہ یا ایڈمن رکن کو ہٹا سکتا ہے۔ ارکان شامل کرنا اور سربراہ مقرر کرنا ایڈمن کا ہے، Options میں</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Team</td><td>ارکان اور سربراہ</td><td>سربراہ یا ایڈمن رکن کو ہٹا سکتا ہے۔ ارکان شامل کرنا اور سربراہ مقرر کرنا ایڈمن کا ہے، Options میں</td></tr>$g$),
      ('my-department_ur', $g$<tr><td><b>Team channel</b></td><td>شعبے کی نجی گفتگو، تصویروں کے ساتھ۔ باہر سے کوئی نہیں دیکھتا، سوائے ایڈمن کے</td><td>ہر رکن لکھتا ہے۔ اپنا پیغام 15 منٹ تک بدلا جا سکتا ہے۔ سربراہ یا ایڈمن اوپر رکھتا ہے</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Chat</td><td>شعبے کی نجی گفتگو، تصویروں کے ساتھ۔ باہر سے کوئی نہیں دیکھتا، سوائے ایڈمن کے</td><td>ہر رکن لکھتا ہے۔ اپنا پیغام 15 منٹ تک بدلا جا سکتا ہے۔ سربراہ یا ایڈمن اوپر رکھتا ہے</td></tr>$g$),
      ('my-department_ur', $g$<tr><td>شعبے کے اپنے اوزار</td><td>اس کی رہنمائی دیکھیں</td><td>اوزار پر منحصر</td></tr>$g$,
        $g$<tr><td><b>Tools</b>: شعبے کے اپنے اوزار</td><td>اس کی رہنمائی دیکھیں</td><td>اوزار پر منحصر</td></tr>$g$),
      ('my-department_ur', $g$<tr><td><b>Policy</b></td><td>نافذ قواعد اور قدریں، اور ہر تجویز کی تاریخ</td><td>متعلقہ شعبے کا سربراہ تجویز کرتا ہے، اور وہ ایڈمن فیصلہ کرتا ہے جس نے تجویز نہ کی ہو</td></tr></table>$g$,
        $g$<tr><td><b>Rules</b></td><td>نافذ قواعد اور قدریں، اور ہر تجویز کی تاریخ</td><td>متعلقہ شعبے کا سربراہ تجویز کرتا ہے، اور وہ ایڈمن فیصلہ کرتا ہے جس نے تجویز نہ کی ہو</td></tr></table>$g$),
      ('my-department_ur', $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: Team Applications, People, Pending decisions</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: People, Applications, Decisions taken</li>$g$),
      ('my-department_ur', $g$<li><a href="#" data-help-guide="dept-coordination">Coordination</a>: Extra credits, Task flow</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-coordination">Coordination</a>: Task flow</li>$g$),
      ('my-department_ur', $g$<li><a href="#" data-help-guide="dept-formation">Formation</a>: Formation pipeline, Access to reserved documents</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-formation">Formation</a>: Paths in preparation, Reserved documents</li>$g$),
      ('my-department_ur', $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits in circulation, Compensation runs, Anomaly report</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits, Compensation runs, Unusual credits, Tokens, Public thanks, Certificates</li>$g$),
      ('my-department_ur', $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Archive tools, Deleted documents, Translation prompt</li>$g$,
        $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Hayat Index, Match Review, Work Consolidation, Hayat Editor, Deleted documents, Translation prompt</li>$g$),
      ('role-admin_en', $g$<li><b>My Department → HR → Pending decisions,</b> and <b>Options → Policy</b>: nothing should wait beyond 7 days.</li>$g$,
        $g$<li><b>My Department → Today</b>, for each department: nothing should wait beyond 7 days.</li>$g$),
      ('role-admin_it', $g$<li><b>My Department → HR → Pending decisions,</b> e <b>Options → Policy</b>: nulla deve aspettare oltre 7 giorni.</li>$g$,
        $g$<li><b>My Department → Today</b>, per ogni reparto: nulla deve aspettare oltre 7 giorni.</li>$g$),
      ('role-admin_ur', $g$<li><b>My Department → HR → Pending decisions،</b> اور <b>Options → Policy</b>: کچھ 7 دن سے زیادہ انتظار نہ کرے۔</li>$g$,
        $g$<li><b>My Department → Today</b>: کچھ 7 دن سے زیادہ انتظار نہ کرے۔</li>$g$),
      ('role-formator_en', $g$<li>Read the department's <b>Team channel</b>.</li>$g$,
        $g$<li>Read the department's <b>Team and chat</b>.</li>$g$),
      ('role-formator_en', $g$<li>With your lead, look at the <b>Formation pipeline</b>: what is in draft, what is published.</li>$g$,
        $g$<li>With your lead, look at <b>Paths in preparation</b>: what is in draft, what is published.</li>$g$),
      ('role-formator_it', $g$<li>Leggi il <b>Team channel</b> del reparto.</li>$g$,
        $g$<li>Leggi <b>Team and chat</b> del reparto.</li>$g$),
      ('role-formator_it', $g$<li>Con il responsabile, guarda la <b>Formation pipeline</b>: che cosa è in bozza, che cosa è pubblicato.</li>$g$,
        $g$<li>Con il responsabile, guarda <b>Paths in preparation</b>: che cosa è in bozza, che cosa è pubblicato.</li>$g$),
      ('role-formator_ur', $g$<li>شعبے کا <b>Team channel</b> پڑھیں۔</li>$g$,
        $g$<li>شعبے کا <b>Team and chat</b> پڑھیں۔</li>$g$),
      ('role-formator_ur', $g$<li>سربراہ کے ساتھ <b>Formation pipeline</b> دیکھیں: کیا مسودے میں ہے، کیا شائع ہوا۔</li>$g$,
        $g$<li>سربراہ کے ساتھ <b>Paths in preparation</b> دیکھیں: کیا مسودے میں ہے، کیا شائع ہوا۔</li>$g$),
      ('role-lead_en', $g$<li><b>The Team channel:</b> you can pin what matters.</li>$g$,
        $g$<li><b>Team and chat:</b> you can pin what matters.</li>$g$),
      ('role-lead_en', $g$<li><b>Your department's rules:</b> you can propose a change with <b>Propose change</b> in Policy, if the department owns that rule. An Admin who isn't the proposer applies it, after the team has reviewed it.</li>$g$,
        $g$<li><b>Your department's rules:</b> you can propose a change with <b>Change</b> in <b>Rules</b>, if the department owns that rule. An Admin who isn't the proposer applies it, after the team has reviewed it.</li>$g$),
      ('role-lead_en', $g$<li>Read the <b>Team channel</b> and answer what waits on you.</li>$g$,
        $g$<li>Read <b>Team and chat</b> and answer what waits on you.</li>$g$),
      ('role-lead_en', $g$<li><b>Update status</b> honestly, with a short note. The app may suggest a status: you decide, and it is only a hint.</li>$g$,
        $g$<li><b>Today → Change:</b> say honestly how the department is doing, with a short note. The app may suggest a status: you decide, and it is only a hint.</li>$g$),
      ('role-lead_en', $g$<li>Tick off done <b>Priorities</b> and add the next ones. Keep the list short.</li>$g$,
        $g$<li>Tick off done <b>What matters now</b> and add the next ones. Keep the list short.</li>$g$),
      ('role-lead_it', $g$<li><b>Il Team channel:</b> puoi fissare ciò che conta.</li>$g$,
        $g$<li><b>Team and chat:</b> puoi fissare ciò che conta.</li>$g$),
      ('role-lead_it', $g$<li><b>Le regole del tuo reparto:</b> puoi proporre una modifica con <b>Propose change</b> in Policy, se la regola è del reparto. La applica un Admin diverso da chi propone, dopo che il team l'ha esaminata.</li>$g$,
        $g$<li><b>Le regole del tuo reparto:</b> puoi proporre una modifica con <b>Change</b> in <b>Rules</b>, se la regola è del reparto. La applica un Admin diverso da chi propone, dopo che il team l'ha esaminata.</li>$g$),
      ('role-lead_it', $g$<li>Leggi il <b>Team channel</b> e rispondi a ciò che aspetta te.</li>$g$,
        $g$<li>Leggi <b>Team and chat</b> e rispondi a ciò che aspetta te.</li>$g$),
      ('role-lead_it', $g$<li><b>Update status</b> con onestà, con una breve nota. L'app può suggerire uno stato: decidi tu, è solo un'indicazione.</li>$g$,
        $g$<li><b>Today → Change:</b> di' con onestà come va il reparto, con una breve nota. L'app può suggerire uno stato: decidi tu, è solo un'indicazione.</li>$g$),
      ('role-lead_it', $g$<li>Spunta le <b>Priorities</b> fatte e aggiungi le prossime. Tieni la lista corta.</li>$g$,
        $g$<li>Spunta le <b>What matters now</b> fatte e aggiungi le prossime. Tieni la lista corta.</li>$g$),
      ('role-lead_ur', $g$<li><b>Team channel:</b> آپ اہم پیغام کو اوپر رکھ سکتے ہیں۔</li>$g$,
        $g$<li><b>Team and chat:</b> آپ اہم پیغام کو اوپر رکھ سکتے ہیں۔</li>$g$),
      ('role-lead_ur', $g$<li><b>آپ کے شعبے کے قواعد:</b> اگر قاعدہ شعبے کا ہو تو Policy میں <b>Propose change</b> سے تبدیلی تجویز کر سکتے ہیں۔ ٹیم کے غور کے بعد اسے وہ ایڈمن لاگو کرتا ہے جس نے تجویز نہ کی ہو۔</li>$g$,
        $g$<li><b>آپ کے شعبے کے قواعد:</b> اگر قاعدہ شعبے کا ہو تو <b>Rules</b> میں <b>Change</b> سے تبدیلی تجویز کر سکتے ہیں۔ ٹیم کے غور کے بعد اسے وہ ایڈمن لاگو کرتا ہے جس نے تجویز نہ کی ہو۔</li>$g$),
      ('role-lead_ur', $g$<li><b>Team channel</b> پڑھیں اور جو آپ کا منتظر ہے اس کا جواب دیں۔</li>$g$,
        $g$<li><b>Team and chat</b> پڑھیں اور جو آپ کا منتظر ہے اس کا جواب دیں۔</li>$g$),
      ('role-lead_ur', $g$<li><b>Update status</b> دیانت داری سے، مختصر نوٹ کے ساتھ۔ ایپ کوئی حالت تجویز کر سکتی ہے: فیصلہ آپ کا ہے، یہ صرف اشارہ ہے۔</li>$g$,
        $g$<li><b>Today → Change</b> دیانت داری سے، مختصر نوٹ کے ساتھ۔ ایپ کوئی حالت تجویز کر سکتی ہے: فیصلہ آپ کا ہے، یہ صرف اشارہ ہے۔</li>$g$),
      ('role-lead_ur', $g$<li>مکمل <b>Priorities</b> پر نشان لگائیں اور اگلی شامل کریں۔ فہرست مختصر رکھیں۔</li>$g$,
        $g$<li>مکمل <b>What matters now</b> پر نشان لگائیں اور اگلی شامل کریں۔ فہرست مختصر رکھیں۔</li>$g$),
      ('teamwork_en', $g$<tr><td>Your department's daily work</td><td><b>My Department → Team channel</b>, private to the department</td></tr>$g$,
        $g$<tr><td>Your department's daily work</td><td><b>My Department → Team and chat</b>, private to the department</td></tr>$g$),
      ('teamwork_en', $g$<tr><td>What the department is focused on</td><td>The status and <b>Priorities</b> at the top of its page</td></tr>$g$,
        $g$<tr><td>What the department is focused on</td><td>The state and <b>What matters now</b>, in its <b>Today</b></td></tr>$g$),
      ('teamwork_it', $g$<tr><td>Il lavoro quotidiano del reparto</td><td><b>My Department → Team channel</b>, privato per il reparto</td></tr>$g$,
        $g$<tr><td>Il lavoro quotidiano del reparto</td><td><b>My Department → Team and chat</b>, privato per il reparto</td></tr>$g$),
      ('teamwork_it', $g$<tr><td>Su che cosa è concentrato il reparto</td><td>Lo stato e le <b>Priorities</b> in cima alla sua pagina</td></tr>$g$,
        $g$<tr><td>Su che cosa è concentrato il reparto</td><td>Lo stato e <b>What matters now</b>, nel suo <b>Today</b></td></tr>$g$),
      ('teamwork_ur', $g$<tr><td>شعبے کا روزمرہ کام</td><td><b>My Department → Team channel</b>، صرف شعبے کے لیے</td></tr>$g$,
        $g$<tr><td>شعبے کا روزمرہ کام</td><td><b>My Department → Team and chat</b>، صرف شعبے کے لیے</td></tr>$g$),
      ('teamwork_ur', $g$<tr><td>شعبہ کس چیز پر توجہ دے رہا ہے</td><td>اس کے صفحے کے اوپر حالت اور <b>Priorities</b></td></tr>$g$,
        $g$<tr><td>شعبہ کس چیز پر توجہ دے رہا ہے</td><td><b>Today</b> میں حالت اور <b>What matters now</b></td></tr>$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 180'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means the sentence had been edited in the app: change that guide by hand.
select 'administer_en' as item, (select count(*) = 1 from public.help_pages where slug = 'administer_en'
  and strpos(html_content, $g$<li><b>Rules:</b> decide proposals. You can't decide your own, and no value changes any other way.</li>$g$) > 0
  and strpos(html_content, $g$<p><b>My Department → Formation → Reserved documents</b> enables a person. A reserved document is protected in the app, not on Drive.</p>$g$) > 0) as ok
union all
select 'administer_it' as item, (select count(*) = 1 from public.help_pages where slug = 'administer_it'
  and strpos(html_content, $g$<li><b>Rules:</b> decidere le proposte. Non puoi decidere le tue, e nessun valore cambia in altro modo.</li>$g$) > 0
  and strpos(html_content, $g$<p><b>My Department → Formation → Reserved documents</b> abilita una persona. Un documento riservato è protetto nell'app, non su Drive.</p>$g$) > 0) as ok
union all
select 'administer_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'administer_ur'
  and strpos(html_content, $g$<li><b>Rules:</b> تجاویز کا فیصلہ۔ آپ اپنی تجویز کا فیصلہ نہیں کر سکتے، اور کوئی قدر کسی اور طرح نہیں بدلتی۔</li>$g$) > 0
  and strpos(html_content, $g$<p><b>My Department → Formation → Reserved documents</b> کسی شخص کو اجازت دیتا ہے۔ مخصوص دستاویز ایپ میں محفوظ ہے، Drive پر نہیں۔</p>$g$) > 0) as ok
union all
select 'dept-archive_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-archive_en'
  and strpos(html_content, $g$<h3>Tools</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>Every week:</b> work through some of Match Review and Work Consolidation, and agree in <b>Team and chat</b> who does what, so two people don't do the same.</li>$g$) > 0) as ok
union all
select 'dept-archive_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-archive_it'
  and strpos(html_content, $g$<h3>Tools</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>Ogni settimana:</b> lavora su una parte di Match Review e Work Consolidation, e accordatevi in <b>Team and chat</b> su chi fa che cosa, perché due persone non facciano lo stesso lavoro.</li>$g$) > 0) as ok
union all
select 'dept-archive_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-archive_ur'
  and strpos(html_content, $g$<h3>Tools</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>ہر ہفتے:</b> Match Review اور Work Consolidation کا کچھ حصہ مکمل کریں، اور <b>Team and chat</b> میں طے کریں کہ کون کیا کرے، تاکہ دو لوگ ایک ہی کام نہ کریں۔</li>$g$) > 0) as ok
union all
select 'dept-communication_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-communication_en'
  and strpos(html_content, $g$<h3>Tools → Start Here cards</h3>$g$) > 0) as ok
union all
select 'dept-communication_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-communication_it'
  and strpos(html_content, $g$<h3>Tools → Start Here cards</h3>$g$) > 0) as ok
union all
select 'dept-communication_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-communication_ur'
  and strpos(html_content, $g$<h3>Tools → Start Here cards</h3>$g$) > 0) as ok
union all
select 'dept-coordination_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-coordination_en'
  and strpos(html_content, $g$<h3>Today → Extra credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Task flow</h3>$g$) > 0
  and strpos(html_content, $g$<p>A live count of the open work: <b>Open</b>, <b>In progress</b>, <b>In review</b>, <b>To publish</b>, <b>Late</b>. It shows where things pile up and whom to contact. It is read-only: to act, go to <b>Tasks → Team overview</b>.</p>$g$) > 0) as ok
union all
select 'dept-coordination_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-coordination_it'
  and strpos(html_content, $g$<h3>Today → Extra credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Task flow</h3>$g$) > 0
  and strpos(html_content, $g$<p>Un conteggio aggiornato del lavoro aperto: <b>Open</b>, <b>In progress</b>, <b>In review</b>, <b>To publish</b>, <b>Late</b>. Mostra dove le cose si accumulano e chi contattare. È di sola lettura: per agire, vai in <b>Tasks → Team overview</b>.</p>$g$) > 0) as ok
union all
select 'dept-coordination_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-coordination_ur'
  and strpos(html_content, $g$<h3>Today → Extra credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Task flow</h3>$g$) > 0
  and strpos(html_content, $g$<p>کھلے کام کی تازہ گنتی: <b>Open</b>, <b>In progress</b>, <b>In review</b>, <b>To publish</b>, <b>Late</b>۔ یہ دکھاتا ہے کہ چیزیں کہاں جمع ہیں اور کس سے رابطہ کریں۔ یہ صرف پڑھنے کے لیے ہے: عمل کے لیے <b>Tasks → Team overview</b> میں جائیں۔</p>$g$) > 0) as ok
union all
select 'dept-formation_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-formation_en'
  and strpos(html_content, $g$<h3>Tools → Paths in preparation</h3>$g$) > 0
  and strpos(html_content, $g$<p>Every path, split into <b>Being written</b> (drafts) and <b>Published</b>. Open one to help or coordinate. This is where the lead sees what the team is writing.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Reserved documents</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>Board misuse:</b> the Formation lead or the HR lead approves what an editor proposes. The Formation lead finds it in <b>Today</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Every week:</b> the lead reads the paths and asks how each draft is going. Use <b>Team and chat</b>, and <b>Formatori notes</b> for advice on a path.</li>$g$) > 0) as ok
union all
select 'dept-formation_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-formation_it'
  and strpos(html_content, $g$<h3>Tools → Paths in preparation</h3>$g$) > 0
  and strpos(html_content, $g$<p>Tutti i percorsi, divisi in <b>Being written</b> (bozze) e <b>Published</b>. Aprine uno per aiutare o coordinare. Qui il responsabile vede che cosa sta scrivendo il team.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Reserved documents</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>Abuso di bacheca:</b> il responsabile di Formazione o di HR approva ciò che propone chi cura la bacheca. Il responsabile di Formazione lo trova in <b>Today</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Ogni settimana:</b> il responsabile legge i percorsi e chiede come va ogni bozza. Usate <b>Team and chat</b>, e <b>Formatori notes</b> per i consigli su un percorso.</li>$g$) > 0) as ok
union all
select 'dept-formation_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-formation_ur'
  and strpos(html_content, $g$<h3>Tools → Paths in preparation</h3>$g$) > 0
  and strpos(html_content, $g$<p>سب راستے، <b>Being written</b> (مسودے) اور <b>Published</b> میں بٹے ہوئے۔ مدد یا رابطہ کاری کے لیے کوئی کھولیں۔ یہاں سربراہ دیکھتا ہے کہ ٹیم کیا لکھ رہی ہے۔</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Reserved documents</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>ہر ہفتے:</b> سربراہ <b>Paths in preparation</b> پڑھتا اور پوچھتا ہے کہ ہر مسودہ کیسا چل رہا ہے۔ <b>Team and chat</b> استعمال کریں، اور راستے پر مشورے کے لیے <b>Formatori notes</b>۔</li>$g$) > 0) as ok
union all
select 'dept-hr_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-hr_en'
  and strpos(html_content, $g$<h3>Tools → Applications</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → People</h3>$g$) > 0
  and strpos(html_content, $g$<p>Everyone on the team: role, standing, age group, credits, reputation, qualifications, departments. The HR lead also sees the date of birth; other members see only the age group. Search a name, then choose a person to see their card. Their login is only there, under <b>Contact</b>, for HR members and Admins. An at-risk mark says why, and is a computed hint to look closer: what counts is your decision, never the mark.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Propose a decision</b> starts a decision about the person, always with a written reason.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>History</b> shows past decisions and, for the HR lead and Admins, what the person has changed in the archive. All past decisions are in <b>Tools → Decisions taken</b>.</li>$g$) > 0
  and strpos(html_content, $g$<h3>Today</h3>$g$) > 0
  and strpos(html_content, $g$<p>What has been proposed and is waiting, in full: from which role to which, which qualification. Those entitled see <b>Approve</b> and <b>Reject</b>; whoever proposed can <b>Take it back</b>.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>A few times a week:</b> new applications, and <b>Today</b>. Nobody should wait in silence.</li>$g$) > 0) as ok
union all
select 'dept-hr_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-hr_it'
  and strpos(html_content, $g$<h3>Tools → Applications</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → People</h3>$g$) > 0
  and strpos(html_content, $g$<p>Tutto il team: ruolo, posizione, fascia d'età, crediti, reputazione, qualifiche, reparti. Il responsabile di HR vede anche la data di nascita; gli altri membri solo la fascia. Cerca un nome, poi scegli una persona per vedere la sua scheda. Il suo login è solo lì, sotto <b>Contact</b>, per i membri di HR e gli Admin. Il segno di rischio dice il perché, ed è un'indicazione calcolata per guardare meglio: conta la tua decisione, mai il segno.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Propose a decision</b> avvia una decisione sulla persona, sempre con un motivo scritto.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>History</b> mostra le decisioni passate e, al responsabile di HR e agli Admin, ciò che la persona ha modificato in archivio. Tutte le decisioni passate sono in <b>Tools → Decisions taken</b>.</li>$g$) > 0
  and strpos(html_content, $g$<h3>Today</h3>$g$) > 0
  and strpos(html_content, $g$<p>Ciò che è stato proposto e aspetta, per intero: da quale ruolo a quale, quale qualifica. Chi ne ha titolo vede <b>Approve</b> e <b>Reject</b>; chi ha proposto può fare <b>Take it back</b>.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Alcune volte a settimana:</b> nuove candidature e <b>Today</b>. Nessuno deve aspettare nel silenzio.</li>$g$) > 0) as ok
union all
select 'dept-hr_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-hr_ur'
  and strpos(html_content, $g$<h3>Tools → Applications</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → People</h3>$g$) > 0
  and strpos(html_content, $g$<li><b>Propose a decision</b> اس شخص کے بارے میں فیصلہ شروع کرتا ہے، ہمیشہ تحریری وجہ کے ساتھ۔</li>$g$) > 0
  and strpos(html_content, $g$<li><b>History</b> پچھلے فیصلے دکھاتا ہے، اور <b>What this person did in the archive</b> وہ جو اس شخص نے آرکائیو میں بدلا۔ <b>What this person did in the archive</b> کو HR کا سربراہ اور ایڈمن دیکھ سکتے ہیں۔</li>$g$) > 0
  and strpos(html_content, $g$<h3>Today</h3>$g$) > 0
  and strpos(html_content, $g$<p>جو تجویز ہوا اور انتظار میں ہے۔ جن کا حق ہے وہ <b>Approve</b> اور <b>Reject</b> دیکھتے ہیں؛ تجویز کرنے والا <b>Take it back</b> کر سکتا ہے۔</p>$g$) > 0
  and strpos(html_content, $g$<li><b>ہفتے میں چند بار:</b> نئی درخواستیں اور <b>Today</b>۔ کوئی خاموشی میں انتظار نہ کرے۔</li>$g$) > 0) as ok
union all
select 'dept-reward_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_en'
  and strpos(html_content, $g$<h3>Tools → Credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Compensation runs</h3>$g$) > 0
  and strpos(html_content, $g$<p>The record that credits were turned into money. A Reward member prepares a run with <b>+ New run</b>, listing the people and amounts. An Admin who didn't prepare it decides. The same credits can't enter two runs, and nothing is ever deleted.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Unusual credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Rules</h3>$g$) > 0
  and strpos(html_content, $g$<p>The lead proposes changes to rates, reputation tiers and thresholds with <b>Change</b>, with the reason. The team reviews it, and an Admin who isn't the proposer decides. Nobody can change a value directly, Admins included.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Every week:</b> look at <b>Unusual credits</b>. If something is odd, ask Coordination before concluding anything.</li>$g$) > 0) as ok
union all
select 'dept-reward_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_it'
  and strpos(html_content, $g$<h3>Tools → Credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Compensation runs</h3>$g$) > 0
  and strpos(html_content, $g$<p>La traccia che dei crediti sono diventati denaro. Un membro di Reward prepara un'esecuzione con <b>+ New run</b>, elencando persone e importi. Decide un Admin che non l'ha preparata. Gli stessi crediti non possono entrare in due esecuzioni, e nulla si cancella mai.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Unusual credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Rules</h3>$g$) > 0
  and strpos(html_content, $g$<p>Il responsabile propone modifiche a tariffe, livelli di reputazione e soglie con <b>Change</b>, con il motivo. Il team la esamina, e decide un Admin diverso da chi propone. Nessuno può cambiare un valore direttamente, Admin compresi.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Ogni settimana:</b> guarda <b>Unusual credits</b>. Se qualcosa è strano, chiedi a Coordinamento prima di concludere.</li>$g$) > 0) as ok
union all
select 'dept-reward_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_ur'
  and strpos(html_content, $g$<h3>Tools → Credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Compensation runs</h3>$g$) > 0
  and strpos(html_content, $g$<p>اس بات کا ریکارڈ کہ کریڈٹ پیسوں میں بدلے گئے۔ Reward کا رکن <b>+ New run</b> سے لوگوں اور رقموں کی فہرست بناتا ہے۔ وہ ایڈمن فیصلہ کرتا ہے جس نے تیار نہ کی ہو۔ ایک ہی کریڈٹ دو بار شامل نہیں ہو سکتے، اور کچھ کبھی مٹتا نہیں۔</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Unusual credits</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Rules</h3>$g$) > 0
  and strpos(html_content, $g$<p>سربراہ شرحوں، ساکھ کے درجوں اور حدوں میں تبدیلی <b>Change</b> سے، وجہ کے ساتھ، تجویز کرتا ہے۔ ٹیم غور کرتی ہے اور وہ ایڈمن فیصلہ کرتا ہے جس نے تجویز نہ کی ہو۔ کوئی قدر براہِ راست نہیں بدل سکتا، ایڈمن بھی نہیں۔</p>$g$) > 0
  and strpos(html_content, $g$<li><b>ہر ہفتے:</b> <b>Unusual credits</b> دیکھیں۔ کچھ عجیب لگے تو نتیجہ نکالنے سے پہلے Coordination سے پوچھیں۔</li>$g$) > 0) as ok
union all
select 'my-department_en' as item, (select count(*) = 1 from public.help_pages where slug = 'my-department_en'
  and strpos(html_content, $g$<h2>The four tabs</h2>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Today</b>: to decide</td><td>What waits for your decision, and what waits for others</td><td>Whoever may decide it</td></tr>
<tr><td><b>Today</b>: state</td><td>On track, Slowing down or Stalled, with the lead's note. The app may add a hint under "The numbers say", which is never applied by itself</td><td>The lead or Admin</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Today</b>: What matters now</td><td>A short list of what the team is focused on, with dates if useful. It isn't a second task system: no assignee and no credits</td><td>The lead or Admin</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Team</td><td>The members and the lead</td><td>The lead or Admin adds and removes members, by name. Admin appoints leads, in Options</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Chat</td><td>A private conversation for the department, with images. Nobody outside it sees it, except Admins</td><td>Any member writes. Your own message can be changed for 15 minutes. The lead or Admin pins</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Tools</b></td><td>The department's own tools, one screen for each. See its guide</td><td>Depends on the tool</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Rules</b></td><td>The rules in force, in plain sentences, and the history of every proposal</td><td>The owning department's lead proposes, and an Admin who isn't the proposer decides</td></tr></table>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: People, Applications, Decisions taken</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-coordination">Coordination</a>: Task flow</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-formation">Formation</a>: Paths in preparation, Reserved documents</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits, Compensation runs, Unusual credits, Tokens, Public thanks, Certificates</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Hayat Index, Match Review, Work Consolidation, Hayat Editor, Deleted documents, Translation prompt</li>$g$) > 0) as ok
union all
select 'my-department_it' as item, (select count(*) = 1 from public.help_pages where slug = 'my-department_it'
  and strpos(html_content, $g$<h2>Le quattro schede</h2>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Today</b>: da decidere</td><td>Ciò che aspetta una tua decisione, e ciò che aspetta altri</td><td>Chi può deciderlo</td></tr>
<tr><td><b>Today</b>: stato</td><td>On track, Slowing down o Stalled, con la nota del responsabile. L'app può aggiungere un'indicazione sotto "The numbers say", che non si applica mai da sola</td><td>Il responsabile o un Admin</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Today</b>: What matters now</td><td>Una lista corta di ciò su cui il team è concentrato, con date se utili. Non è un secondo sistema di task: niente assegnatario e niente crediti</td><td>Il responsabile o un Admin</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Team</td><td>I membri e il responsabile</td><td>Il responsabile o un Admin aggiunge e toglie i membri, per nome. Un Admin nomina i responsabili, in Options</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Chat</td><td>Una conversazione privata del reparto, con immagini. Da fuori non la vede nessuno, tranne gli Admin</td><td>Ogni membro scrive. Il tuo messaggio si può cambiare per 15 minuti. Il responsabile o un Admin fissa</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Tools</b></td><td>Gli strumenti del reparto, una schermata per ciascuno. Vedi la sua guida</td><td>Dipende dallo strumento</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Rules</b></td><td>Le regole in vigore, in frasi semplici, e la storia di ogni proposta</td><td>Propone il responsabile del reparto competente, decide un Admin diverso da chi propone</td></tr></table>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: People, Applications, Decisions taken</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-coordination">Coordinamento</a>: Task flow</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-formation">Formazione</a>: Paths in preparation, Reserved documents</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits, Compensation runs, Unusual credits, Tokens, Public thanks, Certificates</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Hayat Index, Match Review, Work Consolidation, Hayat Editor, Deleted documents, Translation prompt</li>$g$) > 0) as ok
union all
select 'my-department_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'my-department_ur'
  and strpos(html_content, $g$<h2>اس صفحے کے حصے</h2>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Today</b>: حالت</td><td>On track, Slowing down یا Stalled، سربراہ کے نوٹ کے ساتھ۔ ایپ "The numbers say" کے نیچے اشارہ دے سکتی ہے، جو کبھی خود لاگو نہیں ہوتا</td><td>سربراہ یا ایڈمن</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Today</b>: What matters now</td><td>مختصر فہرست کہ ٹیم کس چیز پر توجہ دے رہی ہے، ضرورت ہو تو تاریخوں کے ساتھ۔ یہ دوسرا ٹاسک نظام نہیں: نہ ذمہ دار، نہ کریڈٹ</td><td>سربراہ یا ایڈمن</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Team</td><td>ارکان اور سربراہ</td><td>سربراہ یا ایڈمن رکن کو ہٹا سکتا ہے۔ ارکان شامل کرنا اور سربراہ مقرر کرنا ایڈمن کا ہے، Options میں</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Chat</td><td>شعبے کی نجی گفتگو، تصویروں کے ساتھ۔ باہر سے کوئی نہیں دیکھتا، سوائے ایڈمن کے</td><td>ہر رکن لکھتا ہے۔ اپنا پیغام 15 منٹ تک بدلا جا سکتا ہے۔ سربراہ یا ایڈمن اوپر رکھتا ہے</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Tools</b>: شعبے کے اپنے اوزار</td><td>اس کی رہنمائی دیکھیں</td><td>اوزار پر منحصر</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td><b>Rules</b></td><td>نافذ قواعد اور قدریں، اور ہر تجویز کی تاریخ</td><td>متعلقہ شعبے کا سربراہ تجویز کرتا ہے، اور وہ ایڈمن فیصلہ کرتا ہے جس نے تجویز نہ کی ہو</td></tr></table>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-hr">HR</a>: People, Applications, Decisions taken</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-coordination">Coordination</a>: Task flow</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-formation">Formation</a>: Paths in preparation, Reserved documents</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-reward">Reward</a>: Credits, Compensation runs, Unusual credits, Tokens, Public thanks, Certificates</li>$g$) > 0
  and strpos(html_content, $g$<li><a href="#" data-help-guide="dept-archive">Archive &amp; Data</a>: Hayat Index, Match Review, Work Consolidation, Hayat Editor, Deleted documents, Translation prompt</li>$g$) > 0) as ok
union all
select 'role-admin_en' as item, (select count(*) = 1 from public.help_pages where slug = 'role-admin_en'
  and strpos(html_content, $g$<li><b>My Department → Today</b>, for each department: nothing should wait beyond 7 days.</li>$g$) > 0) as ok
union all
select 'role-admin_it' as item, (select count(*) = 1 from public.help_pages where slug = 'role-admin_it'
  and strpos(html_content, $g$<li><b>My Department → Today</b>, per ogni reparto: nulla deve aspettare oltre 7 giorni.</li>$g$) > 0) as ok
union all
select 'role-admin_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'role-admin_ur'
  and strpos(html_content, $g$<li><b>My Department → Today</b>: کچھ 7 دن سے زیادہ انتظار نہ کرے۔</li>$g$) > 0) as ok
union all
select 'role-formator_en' as item, (select count(*) = 1 from public.help_pages where slug = 'role-formator_en'
  and strpos(html_content, $g$<li>Read the department's <b>Team and chat</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li>With your lead, look at <b>Paths in preparation</b>: what is in draft, what is published.</li>$g$) > 0) as ok
union all
select 'role-formator_it' as item, (select count(*) = 1 from public.help_pages where slug = 'role-formator_it'
  and strpos(html_content, $g$<li>Leggi <b>Team and chat</b> del reparto.</li>$g$) > 0
  and strpos(html_content, $g$<li>Con il responsabile, guarda <b>Paths in preparation</b>: che cosa è in bozza, che cosa è pubblicato.</li>$g$) > 0) as ok
union all
select 'role-formator_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'role-formator_ur'
  and strpos(html_content, $g$<li>شعبے کا <b>Team and chat</b> پڑھیں۔</li>$g$) > 0
  and strpos(html_content, $g$<li>سربراہ کے ساتھ <b>Paths in preparation</b> دیکھیں: کیا مسودے میں ہے، کیا شائع ہوا۔</li>$g$) > 0) as ok
union all
select 'role-lead_en' as item, (select count(*) = 1 from public.help_pages where slug = 'role-lead_en'
  and strpos(html_content, $g$<li><b>Team and chat:</b> you can pin what matters.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Your department's rules:</b> you can propose a change with <b>Change</b> in <b>Rules</b>, if the department owns that rule. An Admin who isn't the proposer applies it, after the team has reviewed it.</li>$g$) > 0
  and strpos(html_content, $g$<li>Read <b>Team and chat</b> and answer what waits on you.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Today → Change:</b> say honestly how the department is doing, with a short note. The app may suggest a status: you decide, and it is only a hint.</li>$g$) > 0
  and strpos(html_content, $g$<li>Tick off done <b>What matters now</b> and add the next ones. Keep the list short.</li>$g$) > 0) as ok
union all
select 'role-lead_it' as item, (select count(*) = 1 from public.help_pages where slug = 'role-lead_it'
  and strpos(html_content, $g$<li><b>Team and chat:</b> puoi fissare ciò che conta.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Le regole del tuo reparto:</b> puoi proporre una modifica con <b>Change</b> in <b>Rules</b>, se la regola è del reparto. La applica un Admin diverso da chi propone, dopo che il team l'ha esaminata.</li>$g$) > 0
  and strpos(html_content, $g$<li>Leggi <b>Team and chat</b> e rispondi a ciò che aspetta te.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Today → Change:</b> di' con onestà come va il reparto, con una breve nota. L'app può suggerire uno stato: decidi tu, è solo un'indicazione.</li>$g$) > 0
  and strpos(html_content, $g$<li>Spunta le <b>What matters now</b> fatte e aggiungi le prossime. Tieni la lista corta.</li>$g$) > 0) as ok
union all
select 'role-lead_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'role-lead_ur'
  and strpos(html_content, $g$<li><b>Team and chat:</b> آپ اہم پیغام کو اوپر رکھ سکتے ہیں۔</li>$g$) > 0
  and strpos(html_content, $g$<li><b>آپ کے شعبے کے قواعد:</b> اگر قاعدہ شعبے کا ہو تو <b>Rules</b> میں <b>Change</b> سے تبدیلی تجویز کر سکتے ہیں۔ ٹیم کے غور کے بعد اسے وہ ایڈمن لاگو کرتا ہے جس نے تجویز نہ کی ہو۔</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Team and chat</b> پڑھیں اور جو آپ کا منتظر ہے اس کا جواب دیں۔</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Today → Change</b> دیانت داری سے، مختصر نوٹ کے ساتھ۔ ایپ کوئی حالت تجویز کر سکتی ہے: فیصلہ آپ کا ہے، یہ صرف اشارہ ہے۔</li>$g$) > 0
  and strpos(html_content, $g$<li>مکمل <b>What matters now</b> پر نشان لگائیں اور اگلی شامل کریں۔ فہرست مختصر رکھیں۔</li>$g$) > 0) as ok
union all
select 'teamwork_en' as item, (select count(*) = 1 from public.help_pages where slug = 'teamwork_en'
  and strpos(html_content, $g$<tr><td>Your department's daily work</td><td><b>My Department → Team and chat</b>, private to the department</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td>What the department is focused on</td><td>The state and <b>What matters now</b>, in its <b>Today</b></td></tr>$g$) > 0) as ok
union all
select 'teamwork_it' as item, (select count(*) = 1 from public.help_pages where slug = 'teamwork_it'
  and strpos(html_content, $g$<tr><td>Il lavoro quotidiano del reparto</td><td><b>My Department → Team and chat</b>, privato per il reparto</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td>Su che cosa è concentrato il reparto</td><td>Lo stato e <b>What matters now</b>, nel suo <b>Today</b></td></tr>$g$) > 0) as ok
union all
select 'teamwork_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'teamwork_ur'
  and strpos(html_content, $g$<tr><td>شعبے کا روزمرہ کام</td><td><b>My Department → Team and chat</b>، صرف شعبے کے لیے</td></tr>$g$) > 0
  and strpos(html_content, $g$<tr><td>شعبہ کس چیز پر توجہ دے رہا ہے</td><td><b>Today</b> میں حالت اور <b>What matters now</b></td></tr>$g$) > 0) as ok
union all
select 'no old name is left', not exists (select 1 from public.help_pages where html_content ~ '(Team channel|Formation pipeline|Anomaly report|Pending decisions|<b>Propose change</b>|<b>Update status</b>|New compensation run|<b>Policy</b>)')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
