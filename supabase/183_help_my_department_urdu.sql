-- 183: three Urdu sentences of the guides, approved by the Owner on 2026-11-25: where a person's email or number is (HR), who adds
-- members to a department, and the name instead of the email for a batch of Urdu titles (Reward). Run after 182.
-- Changes only these sentences. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('dept-hr_ur', $g$آپ تلاش اور فلٹر کر سکتے ہیں۔$g$,
        $g$آپ نام سے تلاش کر سکتے ہیں، پھر کسی شخص کو چنیں تو اس کا کارڈ کھلتا ہے۔ اس کی ای میل یا موبائل نمبر صرف وہیں، <b>Contact</b> میں ہے، اور اسے صرف HR کے ارکان اور ایڈمن دیکھتے ہیں۔$g$),
      ('my-department_ur', $g$سربراہ یا ایڈمن رکن کو ہٹا سکتا ہے۔ ارکان شامل کرنا اور سربراہ مقرر کرنا ایڈمن کا ہے، Options میں$g$,
        $g$سربراہ یا ایڈمن نام سے رکن شامل کر سکتا ہے، اور رکن کو ہٹا سکتا ہے۔ سربراہ مقرر کرنا ایڈمن کا ہے، Options میں$g$),
      ('dept-reward_ur', $g$تو اس کی ای میل اور کھیپ لکھیں، پھر$g$,
        $g$تو اس کا نام تلاش کریں اور کھیپ لکھیں، پھر$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 183'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means the sentence had been edited in the app, or 182 was not run: tell the developer.
select 'where a person''s email or number is' as item,
       (select count(*) = 1 from public.help_pages where slug = 'dept-hr_ur' and strpos(html_content, $g$<b>Contact</b> میں ہے، اور اسے صرف HR کے ارکان اور ایڈمن دیکھتے ہیں۔$g$) > 0) as ok
union all
select 'who adds members',
       (select count(*) = 1 from public.help_pages where slug = 'my-department_ur' and strpos(html_content, $g$سربراہ یا ایڈمن نام سے رکن شامل کر سکتا ہے، اور رکن کو ہٹا سکتا ہے۔$g$) > 0)
union all
select 'the name for the Urdu titles',
       (select count(*) = 1 from public.help_pages where slug = 'dept-reward_ur' and strpos(html_content, $g$تو اس کا نام تلاش کریں اور کھیپ لکھیں، پھر$g$) > 0)
union all
select 'the old sentences are gone',
       not exists (select 1 from public.help_pages where (slug = 'dept-hr_ur' and strpos(html_content, $g$آپ تلاش اور فلٹر کر سکتے ہیں۔$g$) > 0)
         or (slug = 'my-department_ur' and strpos(html_content, $g$ارکان شامل کرنا اور سربراہ مقرر کرنا$g$) > 0)
         or (slug = 'dept-reward_ur' and strpos(html_content, $g$اس کی ای میل اور کھیپ$g$) > 0))
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
