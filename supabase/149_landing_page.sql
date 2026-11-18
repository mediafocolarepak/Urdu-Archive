-- 149: what the landing page shows before signing in (Owner's request, 2026-11-18).
-- The landing page is what Start Here was: the Word of Life of the month, the cards "This is your home", "How to use
-- it", "How to collaborate", and Sign in. Whoever has not signed in reads them through two functions only; the tables
-- stay closed to them (documents, document_texts and onboarding_cards keep their rules).
--   public_word_of_life(): the Word of Life in Urdu of the latest month up to now that has a text: its titles and its
--     text. Published, not deleted, not reserved (the Owner: the Word of Life is public). Nothing else of the archive.
--   public_start_cards(): the published cards of the three sections, as Start Here showed them.
-- Run this BEFORE merging the PR. Safe to run again.

create or replace function public.public_word_of_life()
returns table (document_id integer, month text, ur_title text, en_title text, original_title text, title text,
               language text, body text)
language sql
stable
security definer
set search_path = public
as $$
  with wol as (
    select d.*, substr(d.ref_period, 1, 7) as m
    from public.documents d
    where d.category = 'Wol'
      and d.language = 'URD'
      and d.deleted_at is null
      and d.access_level <> 'reserved'
      and (d.workflow_status is null or d.workflow_status not in ('proposed', 'revision', 'pending_publish', 'removed'))
      and d.ref_period ~ '^\d{4}-\d{2}'
      and substr(d.ref_period, 1, 7) <= to_char(now(), 'YYYY-MM')
      and exists (select 1 from public.document_texts t where t.document_id = d.document_id)
  )
  select w.document_id, w.m,
         w.ur_title,
         coalesce(nullif(btrim(w.en_title), ''),
                  (select s.en_title from public.documents s
                    where s.work_id = w.work_id and s.document_id <> w.document_id and s.deleted_at is null
                      and nullif(btrim(s.en_title), '') is not null and s.en_title !~ '[؀-ۿ]'
                    order by (s.language = 'ENG') desc, s.document_id limit 1)),
         w.original_title, w.title, w.language, t.body
  from wol w join public.document_texts t on t.document_id = w.document_id
  order by w.m desc, w.is_preferred desc nulls last, w.document_id
  limit 1;
$$;

create or replace function public.public_start_cards()
returns table (id bigint, section text, title_ur text, title_en text, body_ur text, body_en text, media_type text,
               media_url text, thumbnail_path text, sort_order integer)
language sql
stable
security definer
set search_path = public
as $$
  select c.id, c.section, c.title_ur, c.title_en, c.body_ur, c.body_en, c.media_type, c.media_url, c.thumbnail_path,
         c.sort_order
  from public.onboarding_cards c
  where c.published
  order by c.sort_order, c.created_at;
$$;

revoke all on function public.public_word_of_life() from public;
revoke all on function public.public_start_cards() from public;
grant execute on function public.public_word_of_life() to anon, authenticated;
grant execute on function public.public_start_cards() to anon, authenticated;

notify pgrst, 'reload schema';

-- Should all say true.
select 1 as ord, 'Word of Life function present' as item,
       exists (select 1 from pg_proc where proname = 'public_word_of_life' and pronamespace = 'public'::regnamespace) as ok
union all select 2, 'Cards function present',
       exists (select 1 from pg_proc where proname = 'public_start_cards' and pronamespace = 'public'::regnamespace)
union all select 3, 'A Word of Life with its text is found',
       (select count(*) = 1 and bool_and(length(body) > 0) from public.public_word_of_life())
union all select 4, 'Visitors may call both',
       has_function_privilege('anon', 'public.public_word_of_life()', 'execute')
       and has_function_privilege('anon', 'public.public_start_cards()', 'execute')
order by ord;
