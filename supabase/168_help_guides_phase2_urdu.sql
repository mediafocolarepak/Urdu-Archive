-- 168: the Urdu Help guides follow the new layout, as 167 does in English and Italian (Owner's request, 2026-11-25).
-- Wording proposed with the Focolare Urdu style guide and approved by the Owner. Numbers and the names of buttons and screens
-- stay in Latin letters. Replaces only these sentences; whether a guide is still a draft does not change. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('find-read_ur', $g$یوزر کے لیے اس کا نام <b>Library</b> ہے اور ٹیم کے لیے <b>Dashboard</b>۔$g$, $g$یہ Home میں <b>Library</b> ہے۔ آپریٹرز کو یہ <b>My work</b> میں بھی <b>Library, to work on</b> کے نام سے ملتا ہے؛ کوآرڈینیٹرز اور ایڈمن کے لیے اس کا نام <b>Dashboard</b> ہے۔$g$),
      ('find-read_ur', $g$<li><b>Report a problem</b>: ٹیم کو بتاتا ہے، دستاویز کا نمبر پہلے سے لکھا ہوتا ہے۔</li>$g$, $g$<li><b dir="ltr">Something to say about this text?</b> (جو اس پر کام کر رہے ہوں ان کے لیے <b>Report a problem</b>): <b>Share with us</b> کھولتا ہے، جہاں دستاویز کا نمبر پہلے سے لکھا ہوتا ہے۔</li>$g$),
      ('find-read_ur', $g$<b>Start Here</b> میں پہلا بٹن$g$, $g$<b>Home</b> میں پہلا بٹن$g$),
      ('propose_ur', $g$<td><b>Proposals → + New proposal</b>، یا Dashboard پر <b>+ Propose content</b></td>$g$, $g$<td><b dir="ltr">Proposals → + New proposal</b>، یا <b>Library, to work on</b> میں <b dir="ltr">+ Propose content</b> (کوآرڈینیٹرز اور ایڈمن کے لیے Dashboard میں)</td>$g$),
      ('tasks_ur', $g$کریڈٹ <b>My credits</b> میں اور اوپر کی پٹی میں نظر آتے ہیں۔$g$, $g$کریڈٹ <b>My credits</b> میں اور <b>My work</b> کے صفحے پر سب سے اوپر نظر آتے ہیں۔$g$),
      ('tasks_ur', $g$۰ سے ۱۰۰ تک کا نمبر جو ۵۰ سے شروع ہوتا ہے اور بتاتا ہے کہ آپ کا کام کتنا قابلِ اعتماد ہے۔ یہ اوپر کی پٹی میں نظر آتا ہے۔$g$, $g$0 سے 100 تک کا نمبر جو 50 سے شروع ہوتا ہے اور بتاتا ہے کہ آپ کا کام کتنا قابلِ اعتماد ہے۔ یہ <b>My work</b> کے صفحے پر سب سے اوپر نظر آتا ہے۔$g$),
      ('teamwork_ur', $g$<b>Report a Problem or Suggestion</b>، یا اگر آپ کوآرڈینیٹر ہیں تو <b>Messages</b>$g$, $g$<b>Share with us</b>، یا اگر آپ کوآرڈینیٹر ہیں تو <b>Messages</b>$g$),
      ('talk-team_ur', $g$<p class="lead">مختلف باتوں کے لیے مختلف جگہیں ہیں، تاکہ کچھ ضائع نہ ہو۔</p>$g$, $g$<p class="lead">ٹیم سے بات کرنے کا ایک ہی دروازہ ہے: <b>Share with us</b>، جو بٹنوں کی پٹی میں ہمیشہ موجود ہے۔ کوئی تجربہ، کوئی خیال، کوئی غلطی یا کوئی چیز جو کام نہ کرے: ہر بات صحیح لوگوں تک پہنچتی ہے۔</p>$g$),
      ('talk-team_ur', $g$<tr><td>غلطی، نہ کھلنے والی فائل یا تجویز کی اطلاع دینا</td><td><b>Report a Problem or Suggestion</b></td></tr>
<tr><td>کوئی تجربہ، مشکل یا خیال بانٹنا</td><td><b>Share with us</b></td></tr>$g$, $g$<tr><td>کوئی تجربہ یا خیال بانٹنا، کسی غلطی یا کام نہ کرنے والی چیز کی اطلاع دینا</td><td><b>Share with us</b></td></tr>$g$),
      ('talk-team_ur', $g$<h2>مسئلے کی اطلاع دیں</h2>
<ol>
<li><b>Report type</b> چنیں اور پیغام لکھیں۔ اگر بات کسی دستاویز کی ہو تو اس کا نمبر لکھیں، یا خود دستاویز پر <b>Report a problem</b> دبائیں۔</li>
<li><b>Send</b> دبائیں۔ کوآرڈینیٹرز اور ایڈمن اسے پڑھتے ہیں اور اسی صفحے پر جواب دیتے ہیں۔ جواب آنے پر آپ کو اطلاع ملتی ہے۔</li>
</ol>
<h2>Share with us</h2>
<p>یہ تکنیکی مسائل کے لیے نہیں۔ یہ اس کے لیے ہے جو آپ جیتے اور سوچتے ہیں، اور ہر شعبے کا سربراہ اسے پڑھتا ہے۔ لکھیں، یا اگر فون اجازت دے تو <b>Record a voice message</b> دبائیں۔ شکریہ اور جواب اسی صفحے پر نظر آتے ہیں۔</p>$g$, $g$<h2>Share with us</h2>
<ol>
<li><b>چنیں کہ بات کس بارے میں ہے۔</b> بٹنوں کے نیچے لکھا ہوتا ہے کہ یہ کن لوگوں تک پہنچے گی۔</li>
<li><b>بول کر بتائیں یا لکھیں،</b> جس زبان میں آپ چاہیں۔ اگر فون اجازت دے تو <b>Record a voice message</b> نظر آتا ہے۔ اگر بات کسی دستاویز کی ہو تو اس کا نمبر لکھیں، یا خود دستاویز سے شروع کریں: وہاں نمبر پہلے سے لکھا ہوتا ہے۔</li>
<li><b>Send</b> دبائیں۔ شکریہ اور جواب اسی صفحے پر نظر آتے ہیں، اور جواب آنے پر آپ کو اطلاع ملتی ہے۔</li>
</ol>
<table><tr><th>چنیں</th><th>کون پڑھتا یا سنتا ہے</th></tr>
<tr><td><b>My experience with the App</b></td><td>شعبوں کے سربراہ اور ایڈمن</td></tr>
<tr><td><b>How to improve the app, an idea</b></td><td>کوآرڈینیٹرز، شعبوں کے سربراہ اور ایڈمن</td></tr>
<tr><td><b>A mistake in a text</b></td><td>کوآرڈینیٹرز اور ایڈمن</td></tr>
<tr><td><b>Something doesn't work</b></td><td>کوآرڈینیٹرز اور ایڈمن</td></tr></table>$g$),
      ('talk-team_ur', $g$اگر آپ قبول ہو جائیں تو آپریٹر بن جاتے ہیں اور نئے ٹیب نظر آتے ہیں۔$g$, $g$اگر آپ قبول ہو جائیں تو آپریٹر بن جاتے ہیں، اور بٹنوں کی پٹی میں <b>My work</b> نظر آتا ہے۔ آپ کا Home ویسا ہی رہتا ہے۔$g$),
      ('talk-team_ur', $g$<li><b>Change my password</b> اور <b>Sign out</b>۔</li>
<li><b>My Certificates</b>، تربیتی راستوں سے۔</li>$g$, $g$<li><b>Personal details</b>، سب سے اوپر۔</li>
<li><b>Tokens of appreciation and certificates</b>۔</li>
<li><b>Text and colours on this device</b>۔</li>
<li><b>Change my password</b>۔</li>$g$),
      ('talk-team_ur', $g$اسے صرف آپ، ایڈمن اور HR کا سربراہ دیکھ سکتے ہیں۔</li>
</ul>$g$, $g$اسے صرف آپ، ایڈمن اور HR کا سربراہ دیکھ سکتے ہیں۔</li>
<li><b>Sign out</b>، صفحے کے آخر میں۔</li>
</ul>$g$),
      ('role-lead_ur', $g$<li><b>Share with us:</b> ہر سربراہ پڑھتا ہے$g$, $g$<li><b>What people shared</b>، <b>My work</b> میں (کوآرڈینیٹرز اور ایڈمن کے لیے <b>Share with us</b>): ہر سربراہ پڑھتا ہے$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(replace(h.html_content, E'\r\n', E'\n'), replace(c.was, E'\r\n', E'\n'), replace(c.now_is, E'\r\n', E'\n')),
           updated_at = now(), updated_by_email = 'migration 168'
     where h.slug = c.slug
       and strpos(replace(h.html_content, E'\r\n', E'\n'), replace(c.was, E'\r\n', E'\n')) > 0
       and strpos(replace(h.html_content, E'\r\n', E'\n'), replace(c.now_is, E'\r\n', E'\n')) = 0;
  end loop;
  update public.help_pages set summary = 'شراکت، شمولیت، آپ کی پروفائل' where slug = 'talk-team_ur' and summary = 'اطلاع، شراکت، شمولیت، آپ کی پروفائل';
end $m$;

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- A false row means the sentence had been edited in the app: change that guide by hand.
-- ============================================================================
select 'find-read_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'find-read_ur'
  and strpos(html_content, $g$یہ Home میں <b>Library</b> ہے۔ آپریٹرز کو یہ <b>My work</b> میں بھی <b>Library, to work on</b> کے نام سے ملتا ہے؛ کوآرڈینیٹرز اور ایڈمن کے لیے اس کا نام <b>Dashboard</b> ہے۔$g$) > 0
  and strpos(html_content, $g$<li><b dir="ltr">Something to say about this text?</b> (جو اس پر کام کر رہے ہوں ان کے لیے <b>Report a problem</b>): <b>Share with us</b> کھولتا ہے، جہاں دستاویز کا نمبر پہلے سے لکھا ہوتا ہے۔</li>$g$) > 0
  and strpos(html_content, $g$<b>Home</b> میں پہلا بٹن$g$) > 0) as ok
union all select 'propose_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'propose_ur'
  and strpos(html_content, $g$<td><b dir="ltr">Proposals → + New proposal</b>، یا <b>Library, to work on</b> میں <b dir="ltr">+ Propose content</b> (کوآرڈینیٹرز اور ایڈمن کے لیے Dashboard میں)</td>$g$) > 0) as ok
union all select 'tasks_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'tasks_ur'
  and strpos(html_content, $g$کریڈٹ <b>My credits</b> میں اور <b>My work</b> کے صفحے پر سب سے اوپر نظر آتے ہیں۔$g$) > 0
  and strpos(html_content, $g$0 سے 100 تک کا نمبر جو 50 سے شروع ہوتا ہے اور بتاتا ہے کہ آپ کا کام کتنا قابلِ اعتماد ہے۔ یہ <b>My work</b> کے صفحے پر سب سے اوپر نظر آتا ہے۔$g$) > 0) as ok
union all select 'teamwork_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'teamwork_ur'
  and strpos(html_content, $g$<b>Share with us</b>، یا اگر آپ کوآرڈینیٹر ہیں تو <b>Messages</b>$g$) > 0) as ok
union all select 'talk-team_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'talk-team_ur'
  and strpos(html_content, $g$<p class="lead">ٹیم سے بات کرنے کا ایک ہی دروازہ ہے: <b>Share with us</b>، جو بٹنوں کی پٹی میں ہمیشہ موجود ہے۔ کوئی تجربہ، کوئی خیال، کوئی غلطی یا کوئی چیز جو کام نہ کرے: ہر بات صحیح لوگوں تک پہنچتی ہے۔</p>$g$) > 0
  and strpos(html_content, $g$<tr><td>کوئی تجربہ یا خیال بانٹنا، کسی غلطی یا کام نہ کرنے والی چیز کی اطلاع دینا</td><td><b>Share with us</b></td></tr>$g$) > 0
  and strpos(html_content, $g$<li><b>چنیں کہ بات کس بارے میں ہے۔</b> بٹنوں کے نیچے لکھا ہوتا ہے کہ یہ کن لوگوں تک پہنچے گی۔</li>$g$) > 0
  and strpos(html_content, $g$اگر آپ قبول ہو جائیں تو آپریٹر بن جاتے ہیں، اور بٹنوں کی پٹی میں <b>My work</b> نظر آتا ہے۔ آپ کا Home ویسا ہی رہتا ہے۔$g$) > 0
  and strpos(html_content, $g$<li><b>Tokens of appreciation and certificates</b>۔</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Sign out</b>، صفحے کے آخر میں۔</li>$g$) > 0) as ok
union all select 'role-lead_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'role-lead_ur'
  and strpos(html_content, $g$<li><b>What people shared</b>، <b>My work</b> میں (کوآرڈینیٹرز اور ایڈمن کے لیے <b>Share with us</b>): ہر سربراہ پڑھتا ہے$g$) > 0) as ok
union all select 'no old place is named in Urdu', not exists (select 1 from public.help_pages where language = 'ur' and (html_content like '%Report a Problem or Suggestion%' or html_content like '%Report type%' or html_content like '%اوپر کی پٹی%' or html_content like '%<b>Start Here</b>%'))
union all select 'English and Italian are untouched', not exists (select 1 from public.help_pages where language <> 'ur' and updated_by_email = 'migration 168')
union all select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
