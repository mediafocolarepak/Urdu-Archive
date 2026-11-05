-- _audit_phase0_task_review.sql
-- Read-only (Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md, fase 0): nothing here writes.
-- One statement on purpose, because the Supabase SQL Editor only shows the last result.
-- Run it, then export or copy the whole result. Run it BEFORE 109_fix_task_review_functions.sql
-- (it shows which functions are really live and what data the old ones left behind) and AGAIN after.
-- If it stops on a missing column or table, that is itself a finding: send the error.

with fn as (
  select p.proname, p.prosrc
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
),
paid as (
  select task_id, count(*) as n, sum(credit_delta) as total, max(credit_delta) as once
  from public.task_outcome_events
  where task_id is not null and event_type in ('review_ok', 'review_ok_but')
  group by task_id
)
-- 1. Which version of each function is live?
select '1.1 submit_task_review: blocks reviewing your own task' as item,
  (select (prosrc like '%cannot review your own task%')::text from fn where proname = 'submit_task_review') as value
union all select '1.2 submit_task_review: Coordinator/Admin may review',
  (select (prosrc like '%current_role_is(''coordinator'')%')::text from fn where proname = 'submit_task_review')
union all select '1.3 submit_task_review: pays credits at review (should be false)',
  (select (prosrc like '%v_credit_delta := coalesce(v_task.credits, 0)%')::text from fn where proname = 'submit_task_review')
union all select '1.4 submit_task_review: discards the candidate on fail',
  (select (prosrc like '%workflow_status = ''removed''%')::text from fn where proname = 'submit_task_review')
union all select '1.5 submit_task_review: refuses pending extra credits',
  (select (prosrc like '%extra_credits_status = ''pending''%')::text from fn where proname = 'submit_task_review')
union all select '1.6 admin_decide_task: moves the document to pending_publish',
  (select (prosrc like '%pending_publish%')::text from fn where proname = 'admin_decide_task')
union all select '1.7 admin_decide_task: uses reputation tiers',
  (select (prosrc like '%task_reputation_deltas%')::text from fn where proname = 'admin_decide_task')
union all select '1.8 status check allows approved -> rejected (Admin reject)',
  (select (prosrc like '%''approved'', ''rejected''%')::text from fn where proname = 'validate_task_status_transition')
union all select '1.9 extra-credit approval can stick (trigger honours the approver)',
  (select (prosrc like '%dua.extra_credits_approving%')::text from fn where proname = 'set_extra_credit_status')

-- 2. What did the old functions leave behind?
union all select '2.1 tasks by status',
  (select string_agg(status || '=' || n, ', ' order by status) from (select status, count(*) n from public.tasks group by status) s)
union all select '2.2 tasks paid more than once: how many',
  (select count(*)::text from paid where n > 1)
union all select '2.3 tasks paid more than once: excess credits in total',
  (select coalesce(sum(total - once), 0)::text from paid where n > 1)
union all select '2.4 tasks paid more than once: task ids',
  (select string_agg(task_id::text, ', ' order by task_id) from paid where n > 1)
union all select '2.5 approved tasks already paid at review (waiting for Admin)',
  (select string_agg(t.id::text, ', ' order by t.id) from public.tasks t join paid p on p.task_id = t.id where t.status = 'approved')
union all select '2.6 published tasks whose document is still in revision: document ids',
  (select string_agg(d.document_id::text, ', ' order by d.document_id) from public.documents d join public.tasks t on t.id = d.source_task_id where d.workflow_status = 'revision' and t.status = 'published')
union all select '2.7 rejected tasks whose document is still in revision: document ids',
  (select string_agg(d.document_id::text, ', ' order by d.document_id) from public.documents d join public.tasks t on t.id = d.source_task_id where d.workflow_status = 'revision' and t.status = 'rejected')
union all select '2.8 documents waiting for the final publish step',
  (select count(*)::text from public.documents where workflow_status = 'pending_publish')
union all select '2.9 tasks reviewed by the person who did them',
  (select count(*)::text from public.tasks where reviewed_by is not null and reviewed_by = claimed_by)
union all select '2.10 tasks with extra credits by approval state',
  (select string_agg(extra_credits_status || '=' || n, ', ' order by extra_credits_status) from (select extra_credits_status, count(*) n from public.tasks group by extra_credits_status) s)

-- 3. People
union all select '3.1 qualifications assigned',
  (select string_agg(qualification_code || '=' || n, ', ' order by qualification_code) from (select qualification_code, count(*) n from public.user_qualifications group by qualification_code) s)
union all select '3.2 department members',
  (select string_agg(department_code || '=' || n, ', ' order by department_code) from (select department_code, count(*) n from public.department_members group by department_code) s)
union all select '3.3 people by role',
  (select string_agg(role || '=' || n, ', ' order by role) from (select role, count(*) n from public.user_roles group by role) s)

-- 4. Archive
union all select '4.1 documents by status',
  (select string_agg(coalesce(workflow_status, '(none)') || '=' || n, ', ' order by n desc) from (select workflow_status, count(*) n from public.documents group by workflow_status) s)
union all select '4.2 documents by media type',
  (select string_agg(coalesce(media_type, '(none)') || '=' || n, ', ' order by n desc) from (select media_type, count(*) n from public.documents group by media_type) s)
union all select '4.3 texts by document source and reviewed flag',
  (select string_agg(src || '/' || reviewed || '=' || n, ', ' order by src, reviewed) from (select coalesce(d.source, '(none)') as src, dt.reviewed, count(*) n from public.document_texts dt join public.documents d on d.document_id = dt.document_id group by 1, 2) s)
union all select '4.4 tag vocabulary tables present',
  (select concat_ws(', ', 'tag=' || (to_regclass('public.tag') is not null), 'documento_tag=' || (to_regclass('public.documento_tag') is not null), 'documento_testo=' || (to_regclass('public.documento_testo') is not null)))
-- Compares year and month only: ref_period can also carry the page ('2001-04p.7').
union all select '4.5 Hayat records whose month differs from the Word of Life month: how many',
  (select count(*)::text from public.documents d join public.hayat_indice h on h.id::text = d.hayat_index_ref::text where coalesce(h.data_pdv, '') <> '' and left(d.ref_period, 7) is distinct from left(h.data_pdv, 7))
union all select '4.6 same: first 15 (document id: ref_period / data_pdv)',
  (select string_agg(x, '; ') from (select d.document_id || ': ' || coalesce(d.ref_period, '(none)') || ' / ' || h.data_pdv as x from public.documents d join public.hayat_indice h on h.id::text = d.hayat_index_ref::text where coalesce(h.data_pdv, '') <> '' and left(d.ref_period, 7) is distinct from left(h.data_pdv, 7) order by d.document_id limit 15) s)
union all select '4.7 documents whose ref_period also carries a page number',
  (select count(*)::text from public.documents where ref_period like '%p.%')

-- 5. Storage and rules really in force
union all select '5.1 storage buckets (id, public, size limit)',
  (select string_agg(id || ' public=' || public || ' limit=' || coalesce(file_size_limit::text, 'none'), '; ' order by id) from storage.buckets)
union all select '5.2 rules in force on ' || tablename,
  string_agg(policyname || ' [' || cmd || ']: ' || coalesce(qual, '') || coalesce(' CHECK ' || with_check, ''), E'\n' order by policyname)
from pg_policies
where schemaname = 'public'
  and tablename in ('documents', 'document_texts', 'document_original_texts', 'works', 'tasks', 'process_history', 'user_roles')
group by tablename
order by item;
