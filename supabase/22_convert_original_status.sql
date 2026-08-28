-- Converts documents.original_status (ex legacy_status, free text from the old Access "process"
-- table) into the real workflow_status, using the mapping confirmed against the process table:
--   'Preparation' -> 'ENTR' (Entered)
--   'Stored'      -> 'STOR' (Stored)
-- There is no legacy equivalent for 'APPR' (Approved) - that step was added after the Access
-- system, so it's simply never produced by this conversion.

-- ============================================================
-- STEP 0 - PREVIEW (read-only). Run first.
-- Shows, for each original_status value, how many documents already have a process_history
-- entry (meaning someone has worked on them in the app since go-live) or a workflow_status
-- other than the 'ENTR' default - those are left untouched by STEP 1 on purpose, so a
-- document nobody has touched since import can't be silently pushed backward.
-- ============================================================
select
  d.original_status as label,
  count(*) as total,
  count(*) filter (where ph.document_id is not null) as already_has_process_history,
  count(*) filter (where d.workflow_status != 'ENTR') as workflow_status_not_default
from documents d
left join process_history ph on ph.document_id = d.document_id
where d.original_status is not null
group by d.original_status;

-- ============================================================
-- STEP 1 - Convert (only touches documents still untouched since import)
-- ============================================================
update documents d
set workflow_status = case d.original_status when 'Preparation' then 'ENTR' when 'Stored' then 'STOR' end
where d.original_status in ('Preparation', 'Stored')
  and d.workflow_status = 'ENTR'
  and not exists (select 1 from process_history ph where ph.document_id = d.document_id);

select 'converted' as label, count(*) from documents
where original_status in ('Preparation', 'Stored') and workflow_status in ('ENTR', 'STOR');

-- ============================================================
-- STEP 2 - Drop original_status (OPTIONAL - only run once you're happy with STEP 1's result;
-- this permanently discards the raw legacy text, so review the STEP 1 counts first).
-- ============================================================
-- alter table documents drop column if exists original_status;
