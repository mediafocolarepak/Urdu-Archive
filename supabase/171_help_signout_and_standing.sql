-- 171: two guides follow the Owner's decisions of 2026-11-25: Sign out beside the name in My Profile, and what Suspended and
-- Excluded mean (170). Run after 170. Replaces only these sentences, in three languages. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('talk-team_en', $g$<li><b>Sign out</b>, at the end of the page.</li>$g$, $g$<li><b>Sign out</b>, at the top, beside your name.</li>$g$),
      ('talk-team_it', $g$<li><b>Sign out</b>, in fondo alla pagina.</li>$g$, $g$<li><b>Sign out</b>, in alto, accanto al tuo nome.</li>$g$),
      ('talk-team_ur', $g$<li><b>Sign out</b>، صفحے کے آخر میں۔</li>$g$, $g$<li><b>Sign out</b>، سب سے اوپر، آپ کے نام کے ساتھ۔</li>$g$),
      ('dept-hr_en', $g$A suspended person can't claim or be given tasks. Excluding keeps the account and all its history.$g$,
        $g$A suspended person does no work until reinstated: they can read, and write in Share with us. An excluded person reads nothing, and only an Admin can take them back. Excluding keeps the account and all its history.$g$),
      ('dept-hr_it', $g$Una persona sospesa non può prendere né ricevere task. Escludere conserva l'account e tutta la sua storia.$g$,
        $g$Una persona sospesa non lavora finché non è riammessa: può leggere, e scrivere in Share with us. Una persona esclusa non legge nulla, e solo un Admin può riammetterla. Escludere conserva l'account e tutta la sua storia.$g$),
      ('dept-hr_ur', $g$معطل شخص نہ ٹاسک لے سکتا ہے نہ اسے دیا جا سکتا ہے۔$g$,
        $g$معطل شخص بحالی تک کوئی کام نہیں کر سکتا: وہ پڑھ سکتا ہے اور Share with us میں لکھ سکتا ہے۔ خارج کیا گیا شخص کچھ نہیں پڑھ سکتا، اور صرف ایڈمن اسے بحال کر سکتا ہے۔$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 171'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means the sentence had been edited in the app: change that guide by hand.
select 'Sign out beside the name, in 3 languages' as item,
       (select count(*) = 3 from public.help_pages where guide_key = 'talk-team'
         and (html_content like '%beside your name%' or html_content like '%accanto al tuo nome%' or html_content like '%آپ کے نام کے ساتھ%')) as ok
union all
select 'Suspended and excluded, in 3 languages',
       (select count(*) = 3 from public.help_pages where guide_key = 'dept-hr'
         and (html_content like '%does no work until reinstated%' or html_content like '%non lavora finché non è riammessa%' or html_content like '%معطل شخص بحالی تک%'))
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
