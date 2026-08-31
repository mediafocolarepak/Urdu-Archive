-- Step 2 of the task review/reputation design: the anonymized review queue and the verdict
-- RPC. A Revisor never sees who claimed a submitted task - get_review_queue() strips
-- claimed_by/claimed_by_email entirely (not just hides them in the UI), and the verdict itself
-- is submitted through submit_task_review(), never a direct update to the tasks table, so
-- there is no client code path that could leak the claimant to a Revisor.
-- On 'fail', submit_task_review() atomically closes the task as 'rejected' AND spawns a fresh
-- open retry task (same document/category/pages/credits) excluding the operator who failed it.
-- Do after 39_task_give_up.sql.

create or replace function public.get_review_queue()
returns table (
  id bigint, title text, description text, category text,
  document_id integer, document_pages integer, credits integer, submitted_at timestamptz
)
language sql
security definer
stable
as $$
  select t.id, t.title, t.description, t.category, t.document_id, t.document_pages, t.credits, t.submitted_at
  from public.tasks t
  where t.status = 'submitted'
    and exists (
      select 1 from public.user_qualifications uq
      where uq.user_id = auth.uid() and uq.qualification_code = 'REVISOR'
    )
  order by t.submitted_at;
$$;

create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_new_status text;
  v_event_type text;
begin
  if not exists (select 1 from public.user_qualifications where user_id = auth.uid() and qualification_code = 'REVISOR') then
    raise exception 'Only a Revisor can submit a review verdict.';
  end if;
  if p_verdict not in ('ok', 'ok_but', 'fail') then
    raise exception 'Invalid verdict.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'submitted' then raise exception 'Only a submitted task can be reviewed.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'ok' then
    v_new_status := 'approved'; v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := 10; v_event_type := 'review_ok';
  elsif p_verdict = 'ok_but' then
    v_new_status := 'approved'; v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := -5; v_event_type := 'review_ok_but';
  else
    v_new_status := 'rejected'; v_credit_delta := 0; v_reputation_delta := -10; v_event_type := 'review_fail';
  end if;

  update public.tasks
  set status = v_new_status, review_verdict = p_verdict, review_notes = p_notes,
      reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
  where id = p_task_id;

  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_notes);

  if p_verdict = 'fail' then
    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  end if;
end;
$$;

select 'task review verdict (step 2: anonymous queue + retry spawn) installato.' as result;
