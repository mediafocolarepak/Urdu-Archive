-- 177: the guides follow the task desk (176): the new button names, the limit of tasks in progress, and the note of a review.
-- Run after the new screens are live and after 176. In Urdu only the names of the buttons change. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('tasks_en', $g$with its category, credits and title. You can filter by <b>Category</b> and <b>Min credits</b>.</li>$g$,
        $g$with its category, credits and title. You can choose the <b>Kind of work</b>; under <b>More options</b>, also <b>Credits, at least</b>.</li>$g$),
      ('tasks_en', $g$<li><b>Take it.</b> Press <b>Claim</b>, choose <b>Your target due date</b> and confirm. The date is a commitment: it can't be changed afterwards, so choose a realistic one.</li>$g$,
        $g$<li><b>Take it.</b> Choose <b>When can you finish it?</b> and press <b>Take this task</b>. The date can't be changed afterwards, so choose a realistic one. You can have up to 3 tasks in progress; the Coordinators can change this number.</li>$g$),
      ('tasks_en', $g$<li><b>Download the original.</b> In <b>My Tasks → In progress</b>, press <b>Download original file</b>. If it's missing, tell whoever created the task.</li>$g$,
        $g$<li><b>Open it.</b> In <b>My Tasks → In progress</b>, open the task. On a computer the document is beside the steps; on a phone press <b>Look at the document</b>. Press <b>Get the file</b> to download it. If it's missing, tell whoever created the task.</li>$g$),
      ('tasks_en', $g$Press <b>Upload corrected file</b>:$g$,
        $g$Press <b>Choose the file</b>:$g$),
      ('tasks_en', $g$Until you submit, you can replace it.$g$,
        $g$Until you send it, you can replace it.$g$),
      ('tasks_en', $g$<li><b>Submit.</b> Press <b>Submit for review</b> and confirm.$g$,
        $g$<li><b>Send it.</b> Press <b>Send for review</b> and confirm.$g$),
      ('tasks_en', $g$<b>Give up this task</b>, or a Coordinator$g$,
        $g$<b>Return this task</b>, or a Coordinator$g$),
      ('tasks_en', $g$press <b>Give up this task</b> and write the reason.$g$,
        $g$press <b>Return this task</b> and write the reason.$g$),
      ('tasks_it', $g$con categoria, crediti e titolo. Puoi filtrare per <b>Category</b> e <b>Min credits</b>.</li>$g$,
        $g$con categoria, crediti e titolo. Puoi scegliere <b>Kind of work</b>; sotto <b>More options</b>, anche <b>Credits, at least</b>.</li>$g$),
      ('tasks_it', $g$<li><b>Prendilo.</b> Premi <b>Claim</b>, scegli <b>Your target due date</b> e conferma. La data è un impegno: non si può cambiare dopo, quindi scegline una realistica.</li>$g$,
        $g$<li><b>Prendilo.</b> Scegli <b>When can you finish it?</b> e premi <b>Take this task</b>. La data non si può cambiare dopo, quindi scegline una realistica. Puoi avere fino a 3 task in corso; i Coordinatori possono cambiare questo numero.</li>$g$),
      ('tasks_it', $g$<li><b>Scarica l'originale.</b> In <b>My Tasks → In progress</b>, premi <b>Download original file</b>. Se manca, avvisa chi ha creato il task.</li>$g$,
        $g$<li><b>Aprilo.</b> In <b>My Tasks → In progress</b>, apri il task. Sul computer il documento è accanto ai passi; sul telefono premi <b>Look at the document</b>. Premi <b>Get the file</b> per scaricarlo. Se manca, avvisa chi ha creato il task.</li>$g$),
      ('tasks_it', $g$Premi <b>Upload corrected file</b>:$g$,
        $g$Premi <b>Choose the file</b>:$g$),
      ('tasks_it', $g$Premi <b>Submit for review</b> e conferma.$g$,
        $g$Premi <b>Send for review</b> e conferma.$g$),
      ('tasks_it', $g$<b>Give up this task</b>, o un Coordinatore$g$,
        $g$<b>Return this task</b>, o un Coordinatore$g$),
      ('tasks_it', $g$premi <b>Give up this task</b> e scrivi il motivo.$g$,
        $g$premi <b>Return this task</b> e scrivi il motivo.$g$),
      ('tasks_ur', $g$<b>Category</b> اور <b>Min credits</b>$g$,
        $g$<b>Kind of work</b> اور <b>Credits, at least</b>$g$),
      ('tasks_ur', $g$<b>Claim</b> دبائیں، <b>Your target due date</b> چنیں اور تصدیق کریں۔$g$,
        $g$<b>When can you finish it?</b> چنیں اور <b>Take this task</b> دبائیں۔$g$),
      ('tasks_ur', $g$<b>Download original file</b>$g$,
        $g$<b>Get the file</b>$g$),
      ('tasks_ur', $g$<b>Upload corrected file</b>$g$,
        $g$<b>Choose the file</b>$g$),
      ('tasks_ur', $g$<b>Submit for review</b>$g$,
        $g$<b>Send for review</b>$g$),
      ('tasks_ur', $g$<b>Give up this task</b>$g$,
        $g$<b>Return this task</b>$g$),
      ('review-tasks_en', $g$<li><b>Open the corrected file</b> with <b>Open corrected file</b>, if the task concerns a document, and compare it with what was asked.</li>$g$,
        $g$<li><b>Open a task with Review.</b> On a computer the file and the document are beside your decision; on a phone press <b>Look at the file</b>. Compare them with what was asked.</li>$g$),
      ('review-tasks_en', $g$<li><b>Give your verdict,</b> with a note that helps the person do better next time.</li>$g$,
        $g$<li><b>Choose your verdict</b> and press <b>Send</b>. With <b>OK, but...</b> and <b>Fail</b> a note is needed: it helps the person do better next time.</li>$g$),
      ('review-tasks_it', $g$<li><b>Apri il file corretto</b> con <b>Open corrected file</b>, se il task riguarda un documento, e confrontalo con ciò che era richiesto.</li>$g$,
        $g$<li><b>Apri un task con Review.</b> Sul computer il file e il documento sono accanto alla tua decisione; sul telefono premi <b>Look at the file</b>. Confrontali con ciò che era richiesto.</li>$g$),
      ('review-tasks_it', $g$<li><b>Dai il verdetto,</b> con una nota che aiuti la persona a far meglio la prossima volta.</li>$g$,
        $g$<li><b>Scegli il verdetto</b> e premi <b>Send</b>. Con <b>OK, but...</b> e <b>Fail</b> serve una nota: aiuta la persona a fare meglio la prossima volta.</li>$g$),
      ('review-tasks_ur', $g$<b>Open corrected file</b>$g$,
        $g$<b>The file</b>$g$),
      ('coordinate-team_en', $g$<li><b>Reassign</b> moves a task to someone else, with no penalty.</li>$g$,
        $g$<li><b>Tasks in progress for each person, at most</b>: 3, unless you change it. You can still give a task to someone who has reached it.</li>
<li><b>Reassign</b> moves a task to someone else, with no penalty.</li>$g$),
      ('coordinate-team_it', $g$<li><b>Reassign</b> passa un task a un altro, senza penalità.</li>$g$,
        $g$<li><b>Tasks in progress for each person, at most</b>: 3, se non lo cambi. Puoi comunque dare un task a chi ci è arrivato.</li>
<li><b>Reassign</b> passa un task a un altro, senza penalità.</li>$g$),
      ('dept-coordination_en', $g$<b>Open</b>, <b>Claimed</b>,$g$,
        $g$<b>Open</b>, <b>In progress</b>,$g$),
      ('dept-coordination_it', $g$<b>Open</b>, <b>Claimed</b>,$g$,
        $g$<b>Open</b>, <b>In progress</b>,$g$),
      ('dept-coordination_ur', $g$<b>Open</b>, <b>Claimed</b>,$g$,
        $g$<b>Open</b>, <b>In progress</b>,$g$),
      ('dept-reward_en', $g$posted, claimed, awaiting review$g$,
        $g$posted, in progress, awaiting review$g$),
      ('who-does-what_en', $g$claim and submit tasks$g$,
        $g$take and send tasks$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 177'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

update public.help_pages set summary = case slug when 'tasks_en' then 'Take, send, credits, reputation' else summary end
 where slug = 'tasks_en' and summary = 'Claim, submit, credits, reputation';

-- Every row should say true. A false row means the sentence had been edited in the app: change that guide by hand.
select 'tasks_en' as item, (select count(*) = 1 from public.help_pages where slug = 'tasks_en'
  and strpos(html_content, $g$with its category, credits and title. You can choose the <b>Kind of work</b>; under <b>More options</b>, also <b>Credits, at least</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Take it.</b> Choose <b>When can you finish it?</b> and press <b>Take this task</b>. The date can't be changed afterwards, so choose a realistic one. You can have up to 3 tasks in progress; the Coordinators can change this number.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Open it.</b> In <b>My Tasks → In progress</b>, open the task. On a computer the document is beside the steps; on a phone press <b>Look at the document</b>. Press <b>Get the file</b> to download it. If it's missing, tell whoever created the task.</li>$g$) > 0
  and strpos(html_content, $g$Press <b>Choose the file</b>:$g$) > 0
  and strpos(html_content, $g$Until you send it, you can replace it.$g$) > 0
  and strpos(html_content, $g$<li><b>Send it.</b> Press <b>Send for review</b> and confirm.$g$) > 0
  and strpos(html_content, $g$<b>Return this task</b>, or a Coordinator$g$) > 0
  and strpos(html_content, $g$press <b>Return this task</b> and write the reason.$g$) > 0) as ok
union all
select 'tasks_it' as item, (select count(*) = 1 from public.help_pages where slug = 'tasks_it'
  and strpos(html_content, $g$con categoria, crediti e titolo. Puoi scegliere <b>Kind of work</b>; sotto <b>More options</b>, anche <b>Credits, at least</b>.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Prendilo.</b> Scegli <b>When can you finish it?</b> e premi <b>Take this task</b>. La data non si può cambiare dopo, quindi scegline una realistica. Puoi avere fino a 3 task in corso; i Coordinatori possono cambiare questo numero.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Aprilo.</b> In <b>My Tasks → In progress</b>, apri il task. Sul computer il documento è accanto ai passi; sul telefono premi <b>Look at the document</b>. Premi <b>Get the file</b> per scaricarlo. Se manca, avvisa chi ha creato il task.</li>$g$) > 0
  and strpos(html_content, $g$Premi <b>Choose the file</b>:$g$) > 0
  and strpos(html_content, $g$Premi <b>Send for review</b> e conferma.$g$) > 0
  and strpos(html_content, $g$<b>Return this task</b>, o un Coordinatore$g$) > 0
  and strpos(html_content, $g$premi <b>Return this task</b> e scrivi il motivo.$g$) > 0) as ok
union all
select 'tasks_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'tasks_ur'
  and strpos(html_content, $g$<b>Kind of work</b> اور <b>Credits, at least</b>$g$) > 0
  and strpos(html_content, $g$<b>When can you finish it?</b> چنیں اور <b>Take this task</b> دبائیں۔$g$) > 0
  and strpos(html_content, $g$<b>Get the file</b>$g$) > 0
  and strpos(html_content, $g$<b>Choose the file</b>$g$) > 0
  and strpos(html_content, $g$<b>Send for review</b>$g$) > 0
  and strpos(html_content, $g$<b>Return this task</b>$g$) > 0) as ok
union all
select 'review-tasks_en' as item, (select count(*) = 1 from public.help_pages where slug = 'review-tasks_en'
  and strpos(html_content, $g$<li><b>Open a task with Review.</b> On a computer the file and the document are beside your decision; on a phone press <b>Look at the file</b>. Compare them with what was asked.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Choose your verdict</b> and press <b>Send</b>. With <b>OK, but...</b> and <b>Fail</b> a note is needed: it helps the person do better next time.</li>$g$) > 0) as ok
union all
select 'review-tasks_it' as item, (select count(*) = 1 from public.help_pages where slug = 'review-tasks_it'
  and strpos(html_content, $g$<li><b>Apri un task con Review.</b> Sul computer il file e il documento sono accanto alla tua decisione; sul telefono premi <b>Look at the file</b>. Confrontali con ciò che era richiesto.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Scegli il verdetto</b> e premi <b>Send</b>. Con <b>OK, but...</b> e <b>Fail</b> serve una nota: aiuta la persona a fare meglio la prossima volta.</li>$g$) > 0) as ok
union all
select 'review-tasks_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'review-tasks_ur'
  and strpos(html_content, $g$<b>The file</b>$g$) > 0) as ok
union all
select 'coordinate-team_en' as item, (select count(*) = 1 from public.help_pages where slug = 'coordinate-team_en'
  and strpos(html_content, $g$<li><b>Tasks in progress for each person, at most</b>: 3, unless you change it. You can still give a task to someone who has reached it.</li>
<li><b>Reassign</b> moves a task to someone else, with no penalty.</li>$g$) > 0) as ok
union all
select 'coordinate-team_it' as item, (select count(*) = 1 from public.help_pages where slug = 'coordinate-team_it'
  and strpos(html_content, $g$<li><b>Tasks in progress for each person, at most</b>: 3, se non lo cambi. Puoi comunque dare un task a chi ci è arrivato.</li>
<li><b>Reassign</b> passa un task a un altro, senza penalità.</li>$g$) > 0) as ok
union all
select 'dept-coordination_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-coordination_en'
  and strpos(html_content, $g$<b>Open</b>, <b>In progress</b>,$g$) > 0) as ok
union all
select 'dept-coordination_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-coordination_it'
  and strpos(html_content, $g$<b>Open</b>, <b>In progress</b>,$g$) > 0) as ok
union all
select 'dept-coordination_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-coordination_ur'
  and strpos(html_content, $g$<b>Open</b>, <b>In progress</b>,$g$) > 0) as ok
union all
select 'dept-reward_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_en'
  and strpos(html_content, $g$posted, in progress, awaiting review$g$) > 0) as ok
union all
select 'who-does-what_en' as item, (select count(*) = 1 from public.help_pages where slug = 'who-does-what_en'
  and strpos(html_content, $g$take and send tasks$g$) > 0) as ok
union all
select 'no old button is named', not exists (select 1 from public.help_pages where html_content ~ '<b>(Claim|Submit for review|Give up this task|Download original file|Upload corrected file|Min credits)</b>')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
