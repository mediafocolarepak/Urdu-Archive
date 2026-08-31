-- Follow-up to the review pipeline, from 2026-08-31 testing feedback: Admin gets the actual
-- final say before anything goes live, not just a "Publish" rubber stamp. A Revisor's ok/ok_but
-- verdict alone no longer touches credits/reputation - it only does on 'fail' (still Revisor-
-- terminal, unchanged). For ok/ok_but, the ledger event is deferred until Admin's own decision:
-- Publish applies the credit/reputation the Revisor's verdict would have given; Reject applies
-- the same penalty as a fail (0 credits, -10 reputation) instead, as if the review had failed
-- outright. Either way the Revisor's own judgement stays invisible to the operator until Admin
-- has acted - see PROJECT_HANDOFF_v6.md session notes, 2026-08-31.
-- Do after 42_coordinator_admin_can_review.sql.

-- Same as before except ok/ok_but no longer insert a task_outcome_events row - only set status
-- to 'approved' and record the verdict for Admin to see. 'fail' is untouched (still immediate).
create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
begin
  if not (
    current_role_is('coordinator')
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
  if v_task.claimed_by = auth.uid() then raise exception 'You cannot review your own task.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'fail' then
    update public.tasks
    set status = 'rejected', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;

    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (p_task_id, v_task.claimed_by, 'review_fail', 0, -10, v_email, p_notes);

    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  else
    -- ok / ok_but: just record the verdict and hand off to Admin - no ledger event yet.
    update public.tasks
    set status = 'approved', review_verdict = p_verdict, review_notes = p_notes,
        reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
    where id = p_task_id;
  end if;
end;
$$;

-- Admin's final decision on an approved task: 'publish' applies the credit/reputation the
-- Revisor's verdict implied (deferred until now) and makes the task's outcome final; 'reject'
-- overrides the Revisor and applies the same penalty as a fail would have, instead. Either way
-- this is the moment the operator's standing actually changes for this task - not before.
-- Admin-only (not Coordinator) - this is deliberately a stricter tier than the review itself.
create or replace function public.admin_decide_task(p_task_id bigint, p_decision text, p_note text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_event_type text;
begin
  if not current_role_is('admin') then
    raise exception 'Only Admin can make the final publish/reject decision.';
  end if;
  if p_decision not in ('publish', 'reject') then
    raise exception 'Invalid decision.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'approved' then raise exception 'Only an approved task can be published or rejected.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_decision = 'publish' then
    if v_task.review_verdict = 'ok_but' then
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := -5; v_event_type := 'review_ok_but';
    else
      v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := 10; v_event_type := 'review_ok';
    end if;
    update public.tasks set status = 'published', published_at = now() where id = p_task_id;
  else
    v_credit_delta := 0; v_reputation_delta := -10; v_event_type := 'admin_rejected';
    update public.tasks set status = 'rejected' where id = p_task_id;
  end if;

  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_note);
end;
$$;

select 'admin final decision installato.' as result;
