-- 182: what 180 did not find in the guides. The Urdu guides still had Urdu digits (the Owner's decision of 2026-11-25: Latin digits),
-- and the part on the tokens in Reward's guide still had the old names. In Urdu only digits and names change. Run after 180.
-- Safe to run again.

update public.help_pages
   set title = translate(title, d.urdu, '01234567890123456789'), summary = translate(summary, d.urdu, '01234567890123456789'),
       html_content = translate(html_content, d.urdu, '01234567890123456789'), updated_at = now(), updated_by_email = 'migration 182'
  from (select chr(1776) || chr(1777) || chr(1778) || chr(1779) || chr(1780) || chr(1781) || chr(1782) || chr(1783) || chr(1784) || chr(1785) || chr(1632) || chr(1633) || chr(1634) || chr(1635) || chr(1636) || chr(1637) || chr(1638) || chr(1639) || chr(1640) || chr(1641) as urdu) d
 where language = 'ur' and concat(title, summary, html_content) is distinct from translate(concat(title, summary, html_content), d.urdu, '01234567890123456789');

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('dept-reward_en', $g$<h3>Who gave, Latest entries</h3>$g$,
        $g$<h3>Tools → Tokens</h3>$g$),
      ('dept-reward_en', $g$<p>Tokens are given by themselves, by pages or minutes, when a contribution is accepted. Nobody writes them by hand. Entries marked <b>before tokens</b> come from contributions made before tokens existed. <b>Annul</b>, with a note, cancels an entry, for example a proposal that turned out to be a copy. The annulment is a new entry: nothing is deleted. Only Reward annuls.</p>$g$,
        $g$<p>Tokens are given by themselves, by pages or minutes, when a contribution is accepted. Nobody writes them by hand. Entries marked <b>before tokens began</b> come from contributions made before tokens existed. <b>Take away</b>, with a note, cancels an entry, for example a proposal that turned out to be a copy. The annulment is a new entry: nothing is deleted. Only Reward annuls.</p>$g$),
      ('dept-reward_en', $g$<p>The value of a page, a minute and a unit is in <b>Policy values</b>, and changes with <b>Propose change</b>, like the rates. While a value is 0, the tokens wait, and they are counted as soon as the value is approved.</p>$g$,
        $g$<p>The value of a page, a minute and a unit is in <b>Rules</b>, and changes with <b>Change</b>, like the rates. While a value is 0, the tokens wait, and they are counted as soon as the value is approved.</p>$g$),
      ('dept-reward_en', $g$<h3>Milestones and the certificate</h3>$g$,
        $g$<h3>Tools → Certificates</h3>$g$),
      ('dept-reward_en', $g$<p><b>+ Propose a milestone</b>, <b>Propose change</b> and <b>Propose removal</b> set the milestones. When someone's tokens reach one, a certificate of appreciation is issued by itself, once the table below holds the certificate's sentence and the signer, a Focolare responsible. The same table holds the word of encouragement for those under 18. Every change is a proposal that an Admin who is not you approves. <b>Check</b> tells whether a certificate's code is genuine.</p>$g$,
        $g$<p><b>+ Propose a milestone</b>, <b>Change</b> and <b>Remove</b> set the milestones. When someone's tokens reach one, a certificate of appreciation is issued by itself, once the texts below give the certificate's sentence and the signer, a Focolare responsible. One of them is the word of encouragement for those under 18. Every change is a proposal that an Admin who is not you approves. <b>Check</b> tells whether a certificate's code is genuine.</p>$g$),
      ('dept-reward_en', $g$<h3>Public thanks for a month</h3>$g$,
        $g$<h3>Tools → Public thanks</h3>$g$),
      ('dept-reward_en', $g$<h3>A batch of Urdu title answers received</h3>$g$,
        $g$<h3>Tools → Tokens: Urdu titles</h3>$g$),
      ('dept-reward_en', $g$<p>When a reviewer sends a batch of answers on the Urdu titles, write their email and which batch, then press <b>Give the tokens</b>. For your own answers, someone else in Reward does it.</p>$g$,
        $g$<p>When a reviewer sends a batch of answers on the Urdu titles, search their name, write which batch, then press <b>Give the tokens</b>. For your own answers, someone else in Reward does it.</p>$g$),
      ('dept-reward_it', $g$<h3>Who gave, Latest entries</h3>$g$,
        $g$<h3>Tools → Tokens</h3>$g$),
      ('dept-reward_it', $g$<p>I token arrivano da soli, per pagine o minuti, quando un contributo viene accettato. Nessuno li scrive a mano. Le voci segnate <b>before tokens</b> vengono da contributi fatti prima che i token esistessero. <b>Annul</b>, con una nota, annulla una voce, per esempio una proposta che si è rivelata una copia. L'annullamento è una voce nuova: nulla si cancella. Solo Reward annulla.</p>$g$,
        $g$<p>I token arrivano da soli, per pagine o minuti, quando un contributo viene accettato. Nessuno li scrive a mano. Le voci segnate <b>before tokens began</b> vengono da contributi fatti prima che i token esistessero. <b>Take away</b>, con una nota, annulla una voce, per esempio una proposta che si è rivelata una copia. L'annullamento è una voce nuova: nulla si cancella. Solo Reward annulla.</p>$g$),
      ('dept-reward_it', $g$<p>Il valore di una pagina, di un minuto e di un'unità è in <b>Policy values</b>, e si cambia con <b>Propose change</b>, come le tariffe. Finché un valore è 0, i token aspettano, e vengono contati appena il valore è approvato.</p>$g$,
        $g$<p>Il valore di una pagina, di un minuto e di un'unità è in <b>Rules</b>, e si cambia con <b>Change</b>, come le tariffe. Finché un valore è 0, i token aspettano, e vengono contati appena il valore è approvato.</p>$g$),
      ('dept-reward_it', $g$<h3>Milestones and the certificate</h3>$g$,
        $g$<h3>Tools → Certificates</h3>$g$),
      ('dept-reward_it', $g$<p><b>+ Propose a milestone</b>, <b>Propose change</b> e <b>Propose removal</b> fissano i traguardi. Quando i token di una persona ne raggiungono uno, l'attestato di riconoscimento viene emesso da solo, appena la tabella qui sotto contiene la frase dell'attestato e chi lo firma, un responsabile del Focolare. La stessa tabella contiene l'incoraggiamento per chi ha meno di 18 anni. Ogni modifica è una proposta che approva un Admin diverso da te. <b>Check</b> dice se il codice di un attestato è autentico.</p>$g$,
        $g$<p><b>+ Propose a milestone</b>, <b>Change</b> e <b>Remove</b> fissano i traguardi. Quando i token di una persona ne raggiungono uno, l'attestato di riconoscimento viene emesso da solo, appena i testi qui sotto dicono la frase dell'attestato e chi lo firma, un responsabile del Focolare. Uno di essi è l'incoraggiamento per chi ha meno di 18 anni. Ogni modifica è una proposta che approva un Admin diverso da te. <b>Check</b> dice se il codice di un attestato è autentico.</p>$g$),
      ('dept-reward_it', $g$<h3>Public thanks for a month</h3>$g$,
        $g$<h3>Tools → Public thanks</h3>$g$),
      ('dept-reward_it', $g$<h3>A batch of Urdu title answers received</h3>$g$,
        $g$<h3>Tools → Tokens: Urdu titles</h3>$g$),
      ('dept-reward_it', $g$<p>Quando un revisore manda un blocco di risposte sui titoli urdu, scrivi la sua email e quale blocco, poi premi <b>Give the tokens</b>. Per le tue risposte lo fa un altro membro di Reward.</p>$g$,
        $g$<p>Quando un revisore manda un blocco di risposte sui titoli urdu, cerca il suo nome, scrivi quale blocco, poi premi <b>Give the tokens</b>. Per le tue risposte lo fa un altro membro di Reward.</p>$g$),
      ('dept-reward_ur', $g$<h3>Who gave, Latest entries</h3>$g$,
        $g$<h3>Tools → Tokens</h3>$g$),
      ('dept-reward_ur', $g$<p>جب کوئی حصہ قبول ہوتا ہے تو ٹوکن خود بخود، صفحات یا منٹوں کے حساب سے، ملتے ہیں۔ کوئی انہیں ہاتھ سے نہیں لکھتا۔ <b>before tokens</b> والے اندراج ان حصوں سے ہیں جو ٹوکن شروع ہونے سے پہلے دیے گئے۔ <b>Annul</b>، ایک نوٹ کے ساتھ، کسی اندراج کو منسوخ کرتا ہے، مثلاً ایسی تجویز جو نقل نکلی۔ منسوخی ایک نیا اندراج ہے: کچھ مٹتا نہیں۔ صرف Reward منسوخ کرتا ہے۔</p>$g$,
        $g$<p>جب کوئی حصہ قبول ہوتا ہے تو ٹوکن خود بخود، صفحات یا منٹوں کے حساب سے، ملتے ہیں۔ کوئی انہیں ہاتھ سے نہیں لکھتا۔ <b>before tokens began</b> والے اندراج ان حصوں سے ہیں جو ٹوکن شروع ہونے سے پہلے دیے گئے۔ <b>Take away</b>، ایک نوٹ کے ساتھ، کسی اندراج کو منسوخ کرتا ہے، مثلاً ایسی تجویز جو نقل نکلی۔ منسوخی ایک نیا اندراج ہے: کچھ مٹتا نہیں۔ صرف Reward منسوخ کرتا ہے۔</p>$g$),
      ('dept-reward_ur', $g$<p>ایک صفحے، ایک منٹ اور ایک اکائی کی قدر <b>Policy values</b> میں ہے، اور شرحوں کی طرح <b>Propose change</b> سے بدلتی ہے۔ جب تک کوئی قدر 0 ہو، ٹوکن انتظار کرتے ہیں، اور قدر منظور ہوتے ہی گن لیے جاتے ہیں۔</p>$g$,
        $g$<p>ایک صفحے، ایک منٹ اور ایک اکائی کی قدر <b>Rules</b> میں ہے، اور شرحوں کی طرح <b>Change</b> سے بدلتی ہے۔ جب تک کوئی قدر 0 ہو، ٹوکن انتظار کرتے ہیں، اور قدر منظور ہوتے ہی گن لیے جاتے ہیں۔</p>$g$),
      ('dept-reward_ur', $g$<h3>Milestones and the certificate</h3>$g$,
        $g$<h3>Tools → Certificates</h3>$g$),
      ('dept-reward_ur', $g$<p><b>+ Propose a milestone</b>، <b>Propose change</b> اور <b>Propose removal</b> سے سنگِ میل طے ہوتے ہیں۔ جب کسی کے ٹوکن کسی سنگِ میل تک پہنچتے ہیں تو تعریفی سند خود بخود جاری ہوتی ہے، بشرطیکہ نیچے کی جدول میں سند کا جملہ اور دستخط کرنے والے کا نام لکھا ہو، جو فوکولاری تحریک کا کوئی ذمہ دار ہو۔ اسی جدول میں 18 سال سے کم عمر والوں کے لیے حوصلہ افزائی کے الفاظ بھی ہیں۔ ہر تبدیلی ایک تجویز ہے جسے آپ کے علاوہ کوئی ایڈمن منظور کرتا ہے۔ <b>Check</b> بتاتا ہے کہ کسی سند کا کوڈ اصلی ہے یا نہیں۔</p>$g$,
        $g$<p><b>+ Propose a milestone</b>، <b>Change</b> اور <b>Remove</b> سے سنگِ میل طے ہوتے ہیں۔ جب کسی کے ٹوکن کسی سنگِ میل تک پہنچتے ہیں تو تعریفی سند خود بخود جاری ہوتی ہے، بشرطیکہ نیچے کی جدول میں سند کا جملہ اور دستخط کرنے والے کا نام لکھا ہو، جو فوکولاری تحریک کا کوئی ذمہ دار ہو۔ اسی جدول میں 18 سال سے کم عمر والوں کے لیے حوصلہ افزائی کے الفاظ بھی ہیں۔ ہر تبدیلی ایک تجویز ہے جسے آپ کے علاوہ کوئی ایڈمن منظور کرتا ہے۔ <b>Check</b> بتاتا ہے کہ کسی سند کا کوڈ اصلی ہے یا نہیں۔</p>$g$),
      ('dept-reward_ur', $g$<h3>Public thanks for a month</h3>$g$,
        $g$<h3>Tools → Public thanks</h3>$g$),
      ('dept-reward_ur', $g$<h3>A batch of Urdu title answers received</h3>$g$,
        $g$<h3>Tools → Tokens: Urdu titles</h3>$g$),
      ('my-department_ur', $g$<tr><td><b>Team channel</b></td><td>شعبے کی نجی گفتگو، تصویروں کے ساتھ۔ باہر سے کوئی نہیں دیکھتا، سوائے ایڈمن کے</td><td>ہر رکن لکھتا ہے۔ اپنا پیغام 15 منٹ تک بدلا جا سکتا ہے۔ سربراہ یا ایڈمن اوپر رکھتا ہے</td></tr>$g$,
        $g$<tr><td><b>Team and chat</b>: Chat</td><td>شعبے کی نجی گفتگو، تصویروں کے ساتھ۔ باہر سے کوئی نہیں دیکھتا، سوائے ایڈمن کے</td><td>ہر رکن لکھتا ہے۔ اپنا پیغام 15 منٹ تک بدلا جا سکتا ہے۔ سربراہ یا ایڈمن اوپر رکھتا ہے</td></tr>$g$),
      ('role-admin_ur', $g$<li><b>My Department → HR → Pending decisions،</b> اور <b>Options → Policy</b>: کچھ 7 دن سے زیادہ انتظار نہ کرے۔</li>$g$,
        $g$<li><b>My Department → Today</b>: کچھ 7 دن سے زیادہ انتظار نہ کرے۔</li>$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 182'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true.
select 'dept-reward_en' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_en'
  and strpos(html_content, $g$<h3>Tools → Tokens</h3>$g$) > 0
  and strpos(html_content, $g$<p>Tokens are given by themselves, by pages or minutes, when a contribution is accepted. Nobody writes them by hand. Entries marked <b>before tokens began</b> come from contributions made before tokens existed. <b>Take away</b>, with a note, cancels an entry, for example a proposal that turned out to be a copy. The annulment is a new entry: nothing is deleted. Only Reward annuls.</p>$g$) > 0
  and strpos(html_content, $g$<p>The value of a page, a minute and a unit is in <b>Rules</b>, and changes with <b>Change</b>, like the rates. While a value is 0, the tokens wait, and they are counted as soon as the value is approved.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Certificates</h3>$g$) > 0
  and strpos(html_content, $g$<p><b>+ Propose a milestone</b>, <b>Change</b> and <b>Remove</b> set the milestones. When someone's tokens reach one, a certificate of appreciation is issued by itself, once the texts below give the certificate's sentence and the signer, a Focolare responsible. One of them is the word of encouragement for those under 18. Every change is a proposal that an Admin who is not you approves. <b>Check</b> tells whether a certificate's code is genuine.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Public thanks</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Tokens: Urdu titles</h3>$g$) > 0
  and strpos(html_content, $g$<p>When a reviewer sends a batch of answers on the Urdu titles, search their name, write which batch, then press <b>Give the tokens</b>. For your own answers, someone else in Reward does it.</p>$g$) > 0) as ok
union all
select 'dept-reward_it' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_it'
  and strpos(html_content, $g$<h3>Tools → Tokens</h3>$g$) > 0
  and strpos(html_content, $g$<p>I token arrivano da soli, per pagine o minuti, quando un contributo viene accettato. Nessuno li scrive a mano. Le voci segnate <b>before tokens began</b> vengono da contributi fatti prima che i token esistessero. <b>Take away</b>, con una nota, annulla una voce, per esempio una proposta che si è rivelata una copia. L'annullamento è una voce nuova: nulla si cancella. Solo Reward annulla.</p>$g$) > 0
  and strpos(html_content, $g$<p>Il valore di una pagina, di un minuto e di un'unità è in <b>Rules</b>, e si cambia con <b>Change</b>, come le tariffe. Finché un valore è 0, i token aspettano, e vengono contati appena il valore è approvato.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Certificates</h3>$g$) > 0
  and strpos(html_content, $g$<p><b>+ Propose a milestone</b>, <b>Change</b> e <b>Remove</b> fissano i traguardi. Quando i token di una persona ne raggiungono uno, l'attestato di riconoscimento viene emesso da solo, appena i testi qui sotto dicono la frase dell'attestato e chi lo firma, un responsabile del Focolare. Uno di essi è l'incoraggiamento per chi ha meno di 18 anni. Ogni modifica è una proposta che approva un Admin diverso da te. <b>Check</b> dice se il codice di un attestato è autentico.</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Public thanks</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Tokens: Urdu titles</h3>$g$) > 0
  and strpos(html_content, $g$<p>Quando un revisore manda un blocco di risposte sui titoli urdu, cerca il suo nome, scrivi quale blocco, poi premi <b>Give the tokens</b>. Per le tue risposte lo fa un altro membro di Reward.</p>$g$) > 0) as ok
union all
select 'dept-reward_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'dept-reward_ur'
  and strpos(html_content, $g$<h3>Tools → Tokens</h3>$g$) > 0
  and strpos(html_content, $g$<p>جب کوئی حصہ قبول ہوتا ہے تو ٹوکن خود بخود، صفحات یا منٹوں کے حساب سے، ملتے ہیں۔ کوئی انہیں ہاتھ سے نہیں لکھتا۔ <b>before tokens began</b> والے اندراج ان حصوں سے ہیں جو ٹوکن شروع ہونے سے پہلے دیے گئے۔ <b>Take away</b>، ایک نوٹ کے ساتھ، کسی اندراج کو منسوخ کرتا ہے، مثلاً ایسی تجویز جو نقل نکلی۔ منسوخی ایک نیا اندراج ہے: کچھ مٹتا نہیں۔ صرف Reward منسوخ کرتا ہے۔</p>$g$) > 0
  and strpos(html_content, $g$<p>ایک صفحے، ایک منٹ اور ایک اکائی کی قدر <b>Rules</b> میں ہے، اور شرحوں کی طرح <b>Change</b> سے بدلتی ہے۔ جب تک کوئی قدر 0 ہو، ٹوکن انتظار کرتے ہیں، اور قدر منظور ہوتے ہی گن لیے جاتے ہیں۔</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Certificates</h3>$g$) > 0
  and strpos(html_content, $g$<p><b>+ Propose a milestone</b>، <b>Change</b> اور <b>Remove</b> سے سنگِ میل طے ہوتے ہیں۔ جب کسی کے ٹوکن کسی سنگِ میل تک پہنچتے ہیں تو تعریفی سند خود بخود جاری ہوتی ہے، بشرطیکہ نیچے کی جدول میں سند کا جملہ اور دستخط کرنے والے کا نام لکھا ہو، جو فوکولاری تحریک کا کوئی ذمہ دار ہو۔ اسی جدول میں 18 سال سے کم عمر والوں کے لیے حوصلہ افزائی کے الفاظ بھی ہیں۔ ہر تبدیلی ایک تجویز ہے جسے آپ کے علاوہ کوئی ایڈمن منظور کرتا ہے۔ <b>Check</b> بتاتا ہے کہ کسی سند کا کوڈ اصلی ہے یا نہیں۔</p>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Public thanks</h3>$g$) > 0
  and strpos(html_content, $g$<h3>Tools → Tokens: Urdu titles</h3>$g$) > 0) as ok
union all
select 'my-department_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'my-department_ur'
  and strpos(html_content, $g$<tr><td><b>Team and chat</b>: Chat</td><td>شعبے کی نجی گفتگو، تصویروں کے ساتھ۔ باہر سے کوئی نہیں دیکھتا، سوائے ایڈمن کے</td><td>ہر رکن لکھتا ہے۔ اپنا پیغام 15 منٹ تک بدلا جا سکتا ہے۔ سربراہ یا ایڈمن اوپر رکھتا ہے</td></tr>$g$) > 0) as ok
union all
select 'role-admin_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'role-admin_ur'
  and strpos(html_content, $g$<li><b>My Department → Today</b>: کچھ 7 دن سے زیادہ انتظار نہ کرے۔</li>$g$) > 0) as ok
union all
select 'no Urdu digit is left in the Urdu guides', not exists (select 1 from public.help_pages where language = 'ur'
  and concat(title, summary, html_content) is distinct from translate(concat(title, summary, html_content), chr(1776) || chr(1777) || chr(1778) || chr(1779) || chr(1780) || chr(1781) || chr(1782) || chr(1783) || chr(1784) || chr(1785) || chr(1632) || chr(1633) || chr(1634) || chr(1635) || chr(1636) || chr(1637) || chr(1638) || chr(1639) || chr(1640) || chr(1641), '01234567890123456789'))
union all
select 'no old name is left', not exists (select 1 from public.help_pages where html_content ~ '(Team channel|Formation pipeline|Anomaly report|Pending decisions|<b>Propose change</b>|<b>Propose removal</b>|<b>Policy values</b>|<b>Annul</b>|<b>Update status</b>|New compensation run|<b>Policy</b>)')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
