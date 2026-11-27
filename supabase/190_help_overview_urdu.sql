-- 190: the Urdu side of 189 (Owner's request, 2026-11-27: "prepara anche quelle in urdu"). Run after 189.
-- Prepared with the Urdu style guide, in the words the Urdu guides already use. Before an Urdu reader has checked it:
--   - the new guide overview_ur is a draft (only Admins see it, as the other Urdu drafts);
--   - the sentences changed in the existing Urdu guides are seen by whoever reads those guides.
-- Changes only these sentences, and does nothing to a guide edited in the app in the same place. Safe to run again.

insert into public.help_pages (slug, guide_key, language, role, title, summary, section, audience, html_content, sort_order, draft, updated_at, updated_by_email)
values ('overview_ur', 'overview', 'ur', null, 'Overview', 'جو منتظر ہے، آخری تاریخیں، ہم کیسے ہیں، ہفتے', 'run', array['coordinator'], $help_guide$<p class="lead"><b>My work</b> پہلے <b>Overview</b> کھولتا ہے: جو آپ کا منتظر ہے، اور منصوبہ کیسا چل رہا ہے۔ ہر خانہ وہ جگہ کھولتا ہے جہاں یہ کام ہوتا ہے۔</p>
<h2>Waiting for you</h2>
<p>جائزے کے لیے ٹاسک، تجاویز، سننے کے لیے ریکارڈنگز، پیغامات، اور ہر شعبے کے فیصلے۔ سب سے پرانا پہلے۔ جب سب سے پرانا 7 دن سے زیادہ انتظار کرے تو خانہ سرخ ہو جاتا ہے۔</p>
<h2>Deadlines</h2>
<p>اگلے 30 دنوں میں جس کی آخری تاریخ ہے، یا جس میں دیر ہو گئی ہے: ٹاسک، شعبوں کی ترجیحات، تربیتی راستوں میں داخلے، اور مہینے کا کلامِ حیات جب اس کا اردو متن ابھی نہ ہو۔ بغیر آخری تاریخ کے لیا گیا ٹاسک 14 دن بعد یہاں آتا ہے۔</p>
<h2>How we are</h2>
<p>شعبے: <b>On track</b>، <b>Slowing down</b>، <b>Stalled</b>۔ ایڈمن یہ بھی دیکھتے ہیں: خطرے میں لوگ، فنڈز، ریکارڈنگز کی جگہ، اور <b>Protection</b>: وہ چار قدم جو اکاؤنٹس کی حفاظت کرتے ہیں۔</p>
<h2>The last 12 weeks</h2>
<p>ہر دن آنے والے لوگ، کھولی گئی دستاویزات، سنی گئی ریکارڈنگز، شائع شدہ ٹاسک، نئے اکاؤنٹس۔ ہر ہفتے کا ایک چھوٹا ستون: اس کا نمبر دیکھنے کے لیے ماؤس اس پر لے جائیں۔ تیر پچھلے 4 ہفتوں کا موازنہ ان سے پہلے کے 4 ہفتوں سے کرتا ہے۔</p>
<p><b>Readings by branch</b> دکھاتا ہے کہ فوکولاری تحریک کی ہر شاخ نے کتنی دستاویزات کھولیں اور کتنی ریکارڈنگز سنیں۔ ایپ صرف تعداد رکھتی ہے، دن کے حساب سے: کبھی یہ نہیں کہ کون، اور کبھی یہ نہیں کہ کون سی دستاویز۔</p>
<h2>The archive: how far we are</h2>
<p>اردو میں Link-ups، انگریزی کے ساتھ اردو متن، ٹائپ شدہ متن والی اردو PDF، دوبارہ پڑھے گئے متن، اور کلامِ حیات کے مہینے۔ ہر سطر <b>Find work</b> میں اپنی تلاش کھولتی ہے۔</p>
<h2>مختصر راستے</h2>
<ul>
<li><b>Since your last visit:</b> اوپر ایک سطر بتاتی ہے کہ جس دن آپ پچھلی بار آئے تھے اس کے بعد کیا بدلا ہے۔</li>
<li><b>Go to…</b> (یا <b>Ctrl+K</b>): کسی اوزار کا نام، دستاویز کے لیے <b>#1593</b>، <b>task 51</b>، یا عنوان کے کچھ الفاظ لکھیں۔ پھر Enter دبائیں۔</li>
<li><b>Favourites:</b> زیادہ سے زیادہ 3 اوزار، <b>My work</b> میں سب سے اوپر۔ یہ اسی آلے پر رہتے ہیں۔</li>
<li><b>Print the week:</b> کاغذ پر Overview، کسی ملاقات کے لیے۔</li>
</ul>
<p>ایڈمن 7 اور 14 کو <b>Options → Overview</b> میں بدلتا ہے۔</p>$help_guide$, 248, true, now(), 'migration 190')
on conflict (slug) do nothing;

do $m$
declare c record;
begin
  for c in
    select * from (values
      -- Being an Admin
      ('role-admin_ur', $g$<h2>صرف آپ کر سکتے ہیں</h2>$g$,
        $g$<h2>Home اور My work</h2>
<p>آپ سب کی طرح <b>Home</b> سے شروع کرتے ہیں: کلامِ حیات، Library، کتابیں، خاموشی میں۔ کام <b>My work</b> میں آپ کا انتظار کرتا ہے، بٹنوں کی پٹی میں؛ اس کا نمبر بتاتا ہے کہ کتنی چیزیں آپ کی منتظر ہیں۔</p>
<p><b>My work</b> پہلے <b>Overview</b> کھولتا ہے۔ کمپیوٹر پر بائیں طرف کی پٹی پھر اوزار گروہوں میں دکھاتی ہے: <b>To decide</b>، <b>Archive</b>، <b>Team</b> اور <b>Settings</b>۔ فون پر یہ Overview کے آخر میں ہیں۔ <b>‹ Home</b> آپ کو واپس لے جاتا ہے۔ دیکھیں <a href="#" data-help-guide="overview">Overview</a>۔</p>
<h2>صرف آپ کر سکتے ہیں</h2>$g$),
      ('role-admin_ur', $g$<li><b>Tasks → Publish Tasks:</b> جو ریوائزرز نے منظور کیا وہ صرف آپ کا منتظر ہے۔</li>$g$,
        $g$<li><b>My work → Overview:</b> جو آپ کا منتظر ہے، سب سے پرانا پہلے۔ ہر خانہ وہ جگہ کھولتا ہے جہاں یہ کام ہوتا ہے۔</li>
<li><b>Tasks → Publish Tasks:</b> جو ریوائزرز نے منظور کیا وہ صرف آپ کا منتظر ہے۔</li>$g$),
      ('role-admin_ur', $g$<li><b>Project overview:</b> ہر شعبے کی حالت اور نوٹ پڑھیں۔$g$,
        $g$<li><b>My work → Overview → How we are</b>، اور اس کے نیچے شعبے: ہر شعبے کی حالت اور نوٹ پڑھیں۔$g$),
      -- Being a Coordinator
      ('role-coordinator_ur', $g$<h2>آپ کا میدان</h2>$g$,
        $g$<h2>Home اور My work</h2>
<p>آپ سب کی طرح <b>Home</b> سے شروع کرتے ہیں: کلامِ حیات، Library، کتابیں، خاموشی میں۔ کام <b>My work</b> میں آپ کا انتظار کرتا ہے، بٹنوں کی پٹی میں؛ اس کا نمبر بتاتا ہے کہ کتنی چیزیں آپ کی منتظر ہیں۔</p>
<p><b>My work</b> پہلے <b>Overview</b> کھولتا ہے۔ کمپیوٹر پر بائیں طرف کی پٹی پھر اوزار گروہوں میں دکھاتی ہے: <b>To decide</b>، <b>Archive</b> اور <b>Team</b>۔ فون پر یہ Overview کے آخر میں ہیں۔ <b>‹ Home</b> آپ کو واپس لے جاتا ہے۔ دیکھیں <a href="#" data-help-guide="overview">Overview</a>۔</p>
<h2>آپ کا میدان</h2>$g$),
      ('role-coordinator_ur', $g$<li><b>Messages:</b> جواب دیں، یا <b>Create task</b> استعمال کریں۔</li>$g$,
        $g$<li><b>My work → Overview:</b> جو آپ کا منتظر ہے، سب سے پرانا پہلے۔ ہر خانہ وہ جگہ کھولتا ہے جہاں یہ کام ہوتا ہے۔</li>
<li><b>Messages:</b> جواب دیں، یا <b>Create task</b> استعمال کریں۔</li>$g$),
      -- Administer
      ('administer_ur', $g$<summary>لوگ: Users ٹیب</summary>$g$, $g$<summary>لوگ: Users</summary>$g$),
      ('administer_ur', $g$<p>سطر سے کردار بدلیں۔$g$, $g$<p><b>My work → Team → Users</b>۔ سطر سے کردار بدلیں۔$g$),
      ('administer_ur', $g$<li><b>Maintenance:</b> ایک بار کے اوزار۔</li>$g$,
        $g$<li><b>Overview:</b> کتنے دن بعد انتظار کرتی چیز سرخ ہو جائے (7)، اور بغیر آخری تاریخ کے لیا گیا ٹاسک کتنے دن بعد Deadlines میں جائے (14)۔</li>
<li><b>Maintenance:</b> ایک بار کے اوزار۔</li>$g$),
      ('administer_ur', $g$<li><b>Project overview:</b> سب شعبے اور Users کا حصہ۔ فیصلے کے مطابق یہ درج نہیں کرتا کہ کون سائن اِن ہوا۔</li>$g$,
        $g$<li><b>My work → Overview:</b> جو منتظر ہے، آخری تاریخیں، ہم کیسے ہیں، پچھلے 12 ہفتے اور آرکائیو؛ نیچے سب شعبے اور Users کا حصہ۔ ایپ گنتی ہے کہ ہر دن کتنے لوگ آتے ہیں، کردار کے لحاظ سے، اور فوکولاری تحریک کی ہر شاخ نے کتنی دستاویزات کھولیں اور کتنی ریکارڈنگز سنیں: صرف تعداد، کبھی یہ نہیں کہ کون۔</li>$g$),
      -- Leading a department
      ('role-lead_ur', $g$ایڈمن سب شعبے ایک ساتھ <b>Project overview</b> میں دیکھتے ہیں۔$g$, $g$ایڈمن سب شعبے ایک ساتھ <b>My work → Overview</b> میں دیکھتے ہیں۔$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 190'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means that sentence had been edited in the app: tell the developer.
select 1 as n, 'The Overview guide in Urdu, as a draft' as item,
       (select count(*) = 1 from public.help_pages where slug = 'overview_ur') as ok
union all select 2, 'Being an Admin, in Urdu',
       (select count(*) = 1 from public.help_pages where slug = 'role-admin_ur'
          and strpos(html_content, 'data-help-guide="overview"') > 0 and strpos(html_content, '<li><b>My work → Overview:</b>') > 0 and strpos(html_content, 'Project overview') = 0)
union all select 3, 'Being a Coordinator, in Urdu',
       (select count(*) = 1 from public.help_pages where slug = 'role-coordinator_ur'
          and strpos(html_content, 'data-help-guide="overview"') > 0 and strpos(html_content, '<li><b>My work → Overview:</b>') > 0)
union all select 4, 'Administer, in Urdu',
       (select count(*) = 1 from public.help_pages where slug = 'administer_ur'
          and strpos(html_content, 'My work → Team → Users') > 0 and strpos(html_content, '<li><b>Overview:</b>') > 0 and strpos(html_content, 'Project overview') = 0)
union all select 5, 'Leading a department, in Urdu',
       (select count(*) = 1 from public.help_pages where slug = 'role-lead_ur' and strpos(html_content, 'Project overview') = 0)
order by n;
