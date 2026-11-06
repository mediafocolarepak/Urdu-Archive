-- 121: the "To listen" queue also gives the number of the document that was read, so that it can be found again
-- (Owner's request, 2026-11-06). Same function as in 114_readings.sql, with one column more. Safe to run again.

begin;

drop function if exists public.get_reading_queue();
create function public.get_reading_queue()
returns table (id bigint, title text, source_document_id integer, language text, duration text, days_waiting integer, overdue boolean,
               claimed_by_me boolean, claimed_by_other boolean, reminder_count integer)
language sql
security definer
stable
set search_path = public
as $$
  select s.id, s.title, coalesce(s.source_document_id, d.document_id), d.language, d.duration,
         extract(day from now() - s.submitted_at)::integer,
         s.submitted_at <= now() - interval '7 days',
         s.claimed_by = auth.uid() and s.claimed_at > now() - interval '48 hours',
         s.claimed_by is not null and s.claimed_by <> auth.uid() and s.claimed_at > now() - interval '48 hours',
         s.reminder_count
  from public.archive_submissions s
  left join public.documents d on d.source_submission_id = s.id
  where s.kind = 'reading' and s.status = 'submitted' and public.can_review_submission(s.id)
  order by s.submitted_at;
$$;

commit;

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 'the queue gives the document number' as item,
       (select pg_get_function_result('public.get_reading_queue()'::regprocedure) like '%source_document_id integer%') as ok
union all select 'it still checks who may review',
       (select prosrc like '%can_review_submission%' from pg_proc where oid = 'public.get_reading_queue()'::regprocedure)
union all select 'it runs with the same rights as before',
       (select prosecdef from pg_proc where oid = 'public.get_reading_queue()'::regprocedure);
