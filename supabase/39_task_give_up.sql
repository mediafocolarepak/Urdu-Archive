-- Follow-up to 38_task_review_pipeline.sql, from testing feedback: the due date fixed at claim
-- time must stay fixed (editing it after the fact defeats its purpose as a commitment) - the
-- "Update due date" action is removed from the app, no DB change needed for that part.
-- What does need a DB change: instead of editing the due date, an Operator who honestly can't
-- do a task they claimed should be able to voluntarily give it up, with a short note on why.
-- This is NOT the same as a Coordinator reclaiming an overdue/misbehaving Operator's task
-- (reclaim_task, -10 reputation) - a voluntary, honest give-up is explicitly not penalized
-- (0/0 delta), but is still logged for the record via the same task_outcome_events ledger.
-- Do after 38_task_review_pipeline.sql.

create or replace function public.give_up_task(p_task_id bigint, p_note text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
begin
  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.claimed_by is distinct from auth.uid() then
    raise exception 'You can only give up a task you have claimed yourself.';
  end if;
  if v_task.status <> 'claimed' then
    raise exception 'Only a claimed task (not yet submitted) can be given up.';
  end if;

  update public.tasks
  set status = 'open', claimed_by = null, claimed_by_email = null, claimed_at = null, due_date = null
  where id = p_task_id;

  select email into v_email from public.user_roles where user_id = auth.uid();
  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, auth.uid(), 'given_up', 0, 0, v_email, p_note);
end;
$$;

select 'give_up_task installato.' as result;
