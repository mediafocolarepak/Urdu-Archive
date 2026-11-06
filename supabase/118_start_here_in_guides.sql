-- 118: Start Here is now a screen of large buttons (js/onboarding.js), so two guides that describe it change.
-- Replaces only these sentences, so any other edit made to the guides in the app stays. Safe to run again.

update public.help_pages set html_content = replace(html_content,
  'In <b>Start Here</b>, a card opens this month''s Word of Life with one tap, with <b>Listen</b> and <b>Watch video</b> when they exist.',
  'In <b>Start Here</b>, the first button opens this month''s Word of Life, with <b>Read</b>, and <b>Listen</b> and <b>Watch video</b> when they exist.'),
  updated_at = now(), updated_by_email = 'migration 118'
where slug = 'find-read_en';

update public.help_pages set html_content = replace(html_content,
  'In <b>Start Here</b>, una scheda apre con un tocco la Parola di Vita del mese, con <b>Listen</b> e <b>Watch video</b> quando esistono.',
  'In <b>Start Here</b>, il primo pulsante apre la Parola di Vita del mese, con <b>Read</b>, e <b>Listen</b> e <b>Watch video</b> quando esistono.'),
  updated_at = now(), updated_by_email = 'migration 118'
where slug = 'find-read_it';

update public.help_pages set html_content = replace(html_content,
  '<p>What Users see first. Think of the person',
  '<p>What Users see first. Each section is a large button on Start Here that opens a page with its cards. A section with no published card has no button. Think of the person'),
  updated_at = now(), updated_by_email = 'migration 118'
where slug = 'dept-communication_en' and html_content not like '%Each section is a large button%';

update public.help_pages set html_content = replace(html_content,
  '<p>Ciò che gli User vedono per primo. Pensa a chi',
  '<p>Ciò che gli User vedono per primo. Ogni sezione è un pulsante grande su Start Here che apre una pagina con le sue schede. Una sezione senza schede pubblicate non ha pulsante. Pensa a chi'),
  updated_at = now(), updated_by_email = 'migration 118'
where slug = 'dept-communication_it' and html_content not like '%Ogni sezione è un pulsante grande%';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- A false row means the sentence had been edited in the app: change that guide by hand.
-- ============================================================================
select 'find-read, English' as item, (select count(*) = 1 from public.help_pages where slug = 'find-read_en' and html_content like '%the first button opens%') as ok
union all select 'find-read, Italian', (select count(*) = 1 from public.help_pages where slug = 'find-read_it' and html_content like '%il primo pulsante apre%')
union all select 'dept-communication, English', (select count(*) = 1 from public.help_pages where slug = 'dept-communication_en' and html_content like '%Each section is a large button%')
union all select 'dept-communication, Italian', (select count(*) = 1 from public.help_pages where slug = 'dept-communication_it' and html_content like '%Ogni sezione è un pulsante grande%')
union all select 'still 27 guides in each language', (select count(*) = 54 from public.help_pages);
