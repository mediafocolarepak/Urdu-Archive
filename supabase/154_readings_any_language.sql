-- 154: reading aloud a text in any language (Owner's request, 2026-11-22: "I can read an Italian text and add its audio").
-- Reading aloud never looked at the language: a reading becomes an AUD record in the language of the text it reads,
-- in the same Work. What kept the 274 Italian texts out (each on its own ITA record since migration 103):
--   1. none was marked as checked, and a reading needs a checked text. Owner's decision (2026-11-22): the Italian
--      texts imported from the Link-up PDFs are correct and can be read, as Stella's (STE) texts already are.
--   2. the list "Texts waiting for a voice" showed Urdu titles first and had no way to pick a language.
-- Also: Coordinators and Admin can now mark any text as checked from its document (mark_text_checked), which until
-- now could only be done in SQL.
-- Run this BEFORE merging the PR. Safe to run again.

-- ============================================================================
-- 1. The Italian texts from the Link-up PDFs count as checked (Owner's decision).
-- ============================================================================
update public.document_texts t
   set reviewed = true, reviewed_at = coalesce(t.reviewed_at, now())
  from public.documents d
 where d.document_id = t.document_id and d.language = 'ITA' and t.source = 'drive_import' and not t.reviewed;

-- ============================================================================
-- 2. A title in the text's own language, for the reading screens.
-- ============================================================================
create or replace function public.title_in_own_language(p_language text, p_ur text, p_it text, p_en text, p_title text, p_original text)
returns text
language sql
immutable
as $$
  select case p_language
    when 'URD' then coalesce(p_ur, p_original, p_en, p_title)
    when 'ITA' then coalesce(p_it, p_original, p_title, p_en)
    when 'ENG' then coalesce(p_en, p_original, p_title)
    else coalesce(p_original, p_title, p_en, p_ur)
  end;
$$;

-- The conditions of 114's waiting list, in one place for the list and its counts.
create or replace function public.text_waits_for_reading(d public.documents, t public.document_texts, p_limit integer)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(d.media_type, 'DOC') = 'DOC' and d.deleted_at is null and public.document_status_is_visible(d.workflow_status)
    and coalesce(d.access_level, 'private') <> 'reserved' and (t.reviewed or d.source = 'STE') and length(t.body) <= p_limit
    and not exists (select 1 from public.documents x where x.work_id = d.work_id and x.language is not distinct from d.language
                     and x.media_type = 'AUD' and x.deleted_at is null and public.document_status_is_visible(x.workflow_status))
    and not exists (select 1 from public.reading_reservations r where r.source_document_id = d.document_id and r.expires_at > now())
    and not exists (select 1 from public.archive_submissions s where s.kind = 'reading' and s.source_document_id = d.document_id and s.status = 'submitted');
$$;

-- ============================================================================
-- 3. My readings: titles in the text's language, and the waiting texts of one language or all.
--    Same as 114 except: p_language, the titles, and 'languages' (how many texts wait in each language).
-- ============================================================================
drop function if exists public.get_my_readings();
create or replace function public.get_my_readings(p_language text default null)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_limit integer := public.reading_chars_limit();
begin
  if not public.current_role_is('user') then raise exception 'Please sign in first.'; end if;
  return jsonb_build_object(
    'consented', public.has_reading_consent(),
    'limit', v_limit,
    'held', coalesce((
      select jsonb_agg(jsonb_build_object('document_id', r.source_document_id,
                                          'title', public.title_in_own_language(d.language, d.ur_title, d.it_title, d.en_title, d.title, d.original_title),
                                          'language', d.language, 'expires_at', r.expires_at) order by r.expires_at)
      from public.reading_reservations r join public.documents d on d.document_id = r.source_document_id
      where r.user_id = auth.uid() and r.expires_at > now()
        and not exists (select 1 from public.archive_submissions s where s.proposer_id = auth.uid() and s.kind = 'reading'
                         and s.source_document_id = r.source_document_id and s.status = 'to_correct')), '[]'::jsonb),
    'readings', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id, 'title', s.title, 'status', s.status, 'source_document_id', s.source_document_id, 'decision_note', s.decision_note,
        'days_waiting', case when s.status = 'submitted' then extract(day from now() - s.submitted_at)::integer end,
        'in_review', s.claimed_by is not null and s.claimed_at > now() - interval '48 hours',
        'reminder_allowed', s.status = 'submitted' and s.submitted_at <= now() - interval '3 days'
          and (s.last_reminder_at is null or s.last_reminder_at <= now() - interval '3 days'),
        'next_reminder_at', case when s.status = 'submitted' then greatest(s.submitted_at, coalesce(s.last_reminder_at, s.submitted_at)) + interval '3 days' end,
        'document_id', a.document_id, 'path', a.path, 'duration', x.duration, 'language', x.language
      ) order by coalesce(s.submitted_at, s.created_at) desc)
      from public.archive_submissions s
      left join public.documents x on x.source_submission_id = s.id
      left join public.audio_readings a on a.document_id = x.document_id
      where s.proposer_id = auth.uid() and s.kind = 'reading' and s.status <> 'discarded'), '[]'::jsonb),
    'languages', coalesce((
      select jsonb_object_agg(w.language, w.n)
      from (select d.language, count(*) as n from public.documents d join public.document_texts t on t.document_id = d.document_id
            where d.language is not null and public.text_waits_for_reading(d, t, v_limit) group by d.language) w), '{}'::jsonb),
    'waiting', coalesce((
      select jsonb_agg(q.w order by q.first desc, q.chars)
      from (
        select jsonb_build_object('document_id', d.document_id,
                                  'title', public.title_in_own_language(d.language, d.ur_title, d.it_title, d.en_title, d.title, d.original_title),
                                  'en_title', d.en_title, 'language', d.language, 'chars', length(t.body)) as w,
               exists (select 1 from public.option_lists o where o.list_name = 'category' and o.code = d.category and o.label ilike 'word of life') as first,
               length(t.body) as chars
        from public.documents d join public.document_texts t on t.document_id = d.document_id
        where public.text_waits_for_reading(d, t, v_limit) and (p_language is null or d.language = p_language)
        order by first desc, chars
        limit 20
      ) q(w, first, chars)), '[]'::jsonb)
  );
end;
$$;

-- ============================================================================
-- 4. Mark a text as checked, from its document (Coordinator and Admin).
-- ============================================================================
create or replace function public.mark_text_checked(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('coordinator') then raise exception 'Only a Coordinator or Admin can mark a text as checked.'; end if;
  update public.document_texts
     set reviewed = true, reviewed_at = now(), reviewed_by_email = auth.email()
   where document_id = p_document_id and not reviewed;
  if not found and not exists (select 1 from public.document_texts where document_id = p_document_id) then
    raise exception 'This document has no text.';
  end if;
end;
$$;

-- Checks: all should be true.
select 'Italian texts from the PDFs are checked' as check_name,
  not exists (select 1 from public.document_texts t join public.documents d on d.document_id = t.document_id
              where d.language = 'ITA' and t.source = 'drive_import' and not t.reviewed) as ok
union all select 'the reading list takes a language',
  exists (select 1 from pg_proc where proname = 'get_my_readings' and pronargs = 1)
  and not exists (select 1 from pg_proc where proname = 'get_my_readings' and pronargs = 0)
union all select 'texts can be marked as checked from the app',
  exists (select 1 from pg_proc where proname = 'mark_text_checked');
