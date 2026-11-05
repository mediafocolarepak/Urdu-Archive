-- 109_fix_task_review_functions.sql
-- Fase 0 of Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md. Rebuilds the task review chain as
-- one consistent whole. Each later migration had redefined these functions from an older body:
--   - 90 rebuilt submit_task_review() from 57: Revisor only, no self-review block, credits paid at
--     review, candidate document no longer discarded on a fail.
--   - 58 rebuilt admin_decide_task() from 43: credits paid again at publish, and the document no
--     longer moves to pending_publish (added by 50) or is discarded on reject.
--   - validate_task_status_transition() (38, 60) never allowed approved -> rejected, so Admin's
--     Reject button always failed.
--   - set_extra_credit_status() (90) turned every approval back to 'pending', so a task above the
--     extra-credit threshold could never receive a passing verdict.
--
-- The result, in one place:
--   - Review: a Revisor, Coordinator or Admin gives the verdict. Nobody reviews their own task,
--     EXCEPT Admin: the Owner's decision of 2026-11-05 for the development and testing phase. A
--     self-reviewed task stays recognisable afterwards (tasks.reviewed_by = tasks.claimed_by), so
--     Reward reports can leave test credits out.
--   - Credits and reputation are written once, at Admin's publish/reject decision. Reputation
--     follows the tiers (58). A fail writes its reputation penalty at review, as before.
--   - Tasks already paid at review by the old function are not paid again; rejecting one takes
--     that payment back through a new ledger event (the ledger stays append-only).
--
-- Safe to re-run. Credits paid twice in the past are NOT corrected here: that is a decision for the
-- Owner, on the numbers from _audit_phase0_task_review.sql.

-- 1. Admin's reject needs this transition.
create or replace function public.validate_task_status_transition()
returns trigger
language plpgsql
as $$
begin
  if new.status = old.status then
    return new;
  end if;
  if (old.status, new.status) in (
    ('open', 'claimed'), ('claimed', 'open'), ('claimed', 'submitted'),
    ('submitted', 'approved'), ('submitted', 'rejected'), ('approved', 'published'),
    ('approved', 'rejected'),
    ('open', 'withdrawn'), ('withdrawn', 'open')
  ) then
    return new;
  end if;
  raise exception 'Illegal task status transition: % -> %', old.status, new.status;
end;
$$;

-- 2. Extra credits: an approval must survive the trigger. Only approve_task_extra_credits() below
-- sets this transaction-local flag; the app's API cannot call set_config(), so a client still cannot
-- mark a task approved by writing the column directly.
create or replace function public.set_extra_credit_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.extra_credit_needs_approval(new.base_credits, new.extra_credits) then
    new.extra_credits_status := 'none';
    new.extra_credits_approved_by := null;
    new.extra_credits_approved_by_email := null;
    new.extra_credits_approved_at := null;
  elsif tg_op = 'UPDATE' and old.extra_credits = new.extra_credits and old.extra_credits_status = 'approved' then
    new.extra_credits_status := 'approved';
    new.extra_credits_approved_by := old.extra_credits_approved_by;
    new.extra_credits_approved_by_email := old.extra_credits_approved_by_email;
    new.extra_credits_approved_at := old.extra_credits_approved_at;
  elsif tg_op = 'UPDATE' and old.extra_credits = new.extra_credits
        and current_setting('dua.extra_credits_approving', true) = 'on' then
    new.extra_credits_status := 'approved';
  else
    new.extra_credits_status := 'pending';
    new.extra_credits_approved_by := null;
    new.extra_credits_approved_by_email := null;
    new.extra_credits_approved_at := null;
  end if;
  return new;
end;
$$;

-- Proposer never equals approver, except Admin (Owner's decision, see above).
create or replace function public.approve_task_extra_credits(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t public.tasks%rowtype;
  v_email text;
  v_is_admin boolean := public.current_role_is('admin');
begin
  select * into t from public.tasks where id = p_task_id for update;
  if t is null then raise exception 'Task not found.'; end if;
  if t.extra_credits_status <> 'pending' then
    raise exception 'This task has no extra-credit approval pending.';
  end if;
  if not (v_is_admin or public.is_dept_lead('COORD')) then
    raise exception 'Only the Coordination lead can approve extra credits.';
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();
  if t.created_by_email = v_email and not v_is_admin then
    raise exception 'The person who proposed the extra credits cannot approve them.';
  end if;

  perform set_config('dua.extra_credits_approving', 'on', true);
  update public.tasks
  set extra_credits_status = 'approved',
      extra_credits_approved_by = auth.uid(),
      extra_credits_approved_by_email = v_email,
      extra_credits_approved_at = now()
  where id = p_task_id;
  perform set_config('dua.extra_credits_approving', 'off', true);
end;
$$;

-- 3. The queue: same columns as 45, plus Admin sees their own tasks. Dropped first, as 45 did, so
-- this also works if the live function still has an older shape.
drop function if exists public.get_review_queue();
create function public.get_review_queue()
returns table (
  id bigint, title text, description text, category text,
  document_id integer, document_pages integer, credits integer, submitted_at timestamptz,
  candidate_document_id integer
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id, t.title, t.description, t.category, t.document_id, t.document_pages, t.credits, t.submitted_at,
    (select d.document_id from public.documents d where d.source_task_id = t.id limit 1) as candidate_document_id
  from public.tasks t
  where t.status = 'submitted'
    and (t.claimed_by <> auth.uid() or public.current_role_is('admin'))
    and (
      public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR')
    )
  order by t.submitted_at;
$$;

-- 4. The verdict. OK / OK-but only record it and hand over to Admin; no ledger event yet.
create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_fail_delta integer;
  v_is_admin boolean := public.current_role_is('admin');
begin
  if not (
    public.current_role_is('coordinator')
    or exists (select 1 from public.user_qualifications where user_id = auth.uid() and qualification_code = 'REVISOR')
  ) then
    raise exception 'Only a Revisor (or Coordinator/Admin) can submit a review verdict.';
  end if;
  if p_verdict not in ('ok', 'ok_but', 'fail') then
    raise exception 'Invalid verdict.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'submitted' then raise exception 'Only a submitted task can be reviewed.'; end if;
  if v_task.claimed_by = auth.uid() and not v_is_admin then
    raise exception 'You cannot review your own task.';
  end if;
  if p_verdict in ('ok', 'ok_but') and v_task.extra_credits_status = 'pending' and not v_is_admin then
    raise exception 'This task''s extra credits (%) are still awaiting Coordination-lead approval - it cannot be given a passing verdict until then.', v_task.extra_credits;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'fail' then
    select fail_delta into v_fail_delta from public.task_reputation_deltas(v_task.base_credits);
    v_fail_delta := coalesce(v_fail_delta, -10);

    update public.tasks
    set status = 'rejected', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;

    update public.documents set workflow_status = 'removed'
    where source_task_id = p_task_id and workflow_status = 'revision';

    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (p_task_id, v_task.claimed_by, 'review_fail', 0, v_fail_delta, v_email, p_notes);

    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      base_credits, extra_credits, extra_credits_note,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.base_credits, v_task.extra_credits, v_task.extra_credits_note,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  else
    update public.tasks
    set status = 'approved', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;
  end if;
end;
$$;

-- 5. Admin's decision: closes the task, pays once, and moves the document one step
-- (pending_publish, then finalize_document_publish() from 50 makes it live).
create or replace function public.admin_decide_task(p_task_id bigint, p_decision text, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_event_type text;
  v_candidate_doc_id integer;
  v_ok_delta integer;
  v_ok_but_delta integer;
  v_fail_delta integer;
  v_prior_events integer;
  v_prior_credits integer;
  v_prior_reputation integer;
begin
  if not public.current_role_is('admin') then
    raise exception 'Only Admin can make the final publish/reject decision.';
  end if;
  if p_decision not in ('publish', 'reject') then
    raise exception 'Invalid decision.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'approved' then raise exception 'Only an approved task can be published or rejected.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();
  select d.document_id into v_candidate_doc_id from public.documents d where d.source_task_id = v_task.id limit 1;

  select ok_delta, ok_but_delta, fail_delta into v_ok_delta, v_ok_but_delta, v_fail_delta
    from public.task_reputation_deltas(v_task.base_credits);
  v_ok_delta := coalesce(v_ok_delta, 10);
  v_ok_but_delta := coalesce(v_ok_but_delta, -5);
  v_fail_delta := coalesce(v_fail_delta, -10);

  -- Anything the old submit_task_review() (90) already paid for this task.
  select count(*), coalesce(sum(credit_delta), 0), coalesce(sum(reputation_delta), 0)
    into v_prior_events, v_prior_credits, v_prior_reputation
    from public.task_outcome_events
    where task_id = p_task_id and event_type in ('review_ok', 'review_ok_but');

  if p_decision = 'publish' then
    if v_task.review_verdict = 'ok_but' then
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := v_ok_but_delta; v_event_type := 'review_ok_but';
    else
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := v_ok_delta; v_event_type := 'review_ok';
    end if;
    update public.tasks set status = 'published', published_at = now() where id = p_task_id;

    if v_candidate_doc_id is not null then
      update public.documents set workflow_status = 'pending_publish' where document_id = v_candidate_doc_id;
    end if;
  else
    v_credit_delta := -v_prior_credits;
    v_reputation_delta := v_fail_delta - v_prior_reputation;
    v_event_type := 'admin_rejected';
    update public.tasks set status = 'rejected' where id = p_task_id;

    if v_candidate_doc_id is not null then
      update public.documents set workflow_status = 'removed' where document_id = v_candidate_doc_id;
    end if;
  end if;

  if not (p_decision = 'publish' and v_prior_events > 0) then
    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_note);
  end if;
end;
$$;

-- 6. Documents the old functions left stranded in 'revision', hidden from readers and from every
-- queue. Both targets stay hidden from readers: published tasks reach Admin's "Documents ready to
-- publish" list, rejected ones are discarded as intended.
update public.documents d set workflow_status = 'pending_publish'
from public.tasks t
where t.id = d.source_task_id and d.workflow_status = 'revision' and t.status = 'published';

update public.documents d set workflow_status = 'removed'
from public.tasks t
where t.id = d.source_task_id and d.workflow_status = 'revision' and t.status = 'rejected';

-- 7. Verification: every row must say true.
select 'submit_task_review: self-review blocked, except Admin' as item,
  (select prosrc like '%cannot review your own task%' and prosrc like '%not v_is_admin%' from pg_proc where proname = 'submit_task_review') as ok
union all select 'submit_task_review: pays nothing on a passing verdict',
  (select prosrc not like '%coalesce(v_task.credits, 0)%' from pg_proc where proname = 'submit_task_review')
union all select 'admin_decide_task: moves the document to pending_publish',
  (select prosrc like '%pending_publish%' from pg_proc where proname = 'admin_decide_task')
union all select 'admin_decide_task: does not pay twice',
  (select prosrc like '%v_prior_events%' from pg_proc where proname = 'admin_decide_task')
union all select 'status check allows Admin reject',
  (select prosrc like '%''approved'', ''rejected''%' from pg_proc where proname = 'validate_task_status_transition')
union all select 'extra-credit approval survives the trigger',
  (select prosrc like '%dua.extra_credits_approving%' from pg_proc where proname = 'set_extra_credit_status')
union all select 'no document left in revision under a closed task',
  not exists (select 1 from public.documents d join public.tasks t on t.id = d.source_task_id where d.workflow_status = 'revision' and t.status in ('published', 'rejected'));
