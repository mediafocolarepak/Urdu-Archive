-- 178: three Urdu sentences of the guides, approved by the Owner on 2026-11-25: the limit of tasks in progress, the document
-- beside the work, and the note of a review. Run after 177. Adds only these sentences. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('tasks_ur', $g$تاریخ ایک وعدہ ہے: بعد میں بدلی نہیں جا سکتی، اس لیے حقیقت پسندانہ چنیں۔</li>$g$,
        $g$تاریخ ایک وعدہ ہے: بعد میں بدلی نہیں جا سکتی، اس لیے حقیقت پسندانہ چنیں۔ آپ کے پاس ایک وقت میں زیادہ سے زیادہ 3 جاری ٹاسک ہو سکتے ہیں؛ کوآرڈینیٹر یہ تعداد بدل سکتے ہیں۔</li>$g$),
      ('tasks_ur', $g$<b>Get the file</b> دبائیں۔ اگر نہ ہو تو ٹاسک بنانے والے کو بتائیں۔</li>$g$,
        $g$<b>Get the file</b> دبائیں۔ اگر نہ ہو تو ٹاسک بنانے والے کو بتائیں۔ کمپیوٹر پر دستاویز مراحل کے ساتھ نظر آتی ہے؛ فون پر <b>Look at the document</b> دبائیں۔</li>$g$),
      ('review-tasks_ur', $g$<b>فیصلہ دیں،</b> ایسے نوٹ کے ساتھ جو اگلی بار بہتر کرنے میں مدد دے۔$g$,
        $g$<b>فیصلہ دیں،</b> ایسے نوٹ کے ساتھ جو اگلی بار بہتر کرنے میں مدد دے۔ <b>OK, but...</b> اور <b>Fail</b> کے ساتھ نوٹ لکھنا ضروری ہے۔$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 178'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means the sentence had been edited in the app, or 177 was not run: tell the developer.
select 'the limit of tasks in progress' as item,
       (select count(*) = 1 from public.help_pages where slug = 'tasks_ur' and strpos(html_content, $g$زیادہ سے زیادہ 3 جاری ٹاسک ہو سکتے ہیں$g$) > 0) as ok
union all
select 'the document beside the work',
       (select count(*) = 1 from public.help_pages where slug = 'tasks_ur' and strpos(html_content, $g$فون پر <b>Look at the document</b> دبائیں۔$g$) > 0)
union all
select 'the note of a review',
       (select count(*) = 1 from public.help_pages where slug = 'review-tasks_ur' and strpos(html_content, $g$کے ساتھ نوٹ لکھنا ضروری ہے۔$g$) > 0)
union all
select 'no sentence is there twice',
       not exists (select 1 from public.help_pages where slug in ('tasks_ur', 'review-tasks_ur')
         and html_content ~ '(زیادہ سے زیادہ 3 جاری.*زیادہ سے زیادہ 3 جاری|Look at the document.*Look at the document|نوٹ لکھنا ضروری.*نوٹ لکھنا ضروری)')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
