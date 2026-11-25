-- 165: a task is taken and sent through two functions, and nobody writes its credits or its verdict by hand.
--
--   * claim_task(task, date): checks the role, the qualification, that the task is still free, and the date. Two people
--     can no longer take the same task: the second one is told.
--   * submit_task(task): only whoever took it, and only with the corrected file when there is a document.
--   * Operators no longer write on tasks directly. Coordinators and Admins still create, assign, withdraw, put back and
--     delete; credits, verdicts and reviews change only through the review functions (submit_task_review, admin_decide_task).
--
-- Run it AFTER the app version that uses these functions is live (that version also works without them).
-- No data changes. Safe to run again. Run in the Supabase Dashboard -> SQL Editor: every row must say true.
--
-- To undo:
--   drop trigger if exists tasks_guard_direct_write on public.tasks;
--   and create again "tasks_update_own_or_reviewers" from 38_task_review_pipeline.sql.

-- 1. Taking a task.
create or replace function public.claim_task(p_task_id bigint, p_due_date date)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t public.tasks%rowtype;
  v_me uuid := auth.uid();
  v_coordinator boolean := public.current_role_is('coordinator');
begin
  if not public.current_role_is('operator') then raise exception 'Only team members can take tasks.'; end if;

  select * into t from public.tasks where id = p_task_id for update;
  if not found or not public.document_reserved_ok(t.document_id) then raise exception 'Task not found.'; end if;
  if t.status <> 'open' or t.claimed_by is not null then
    raise exception 'Someone else has just taken this task, or it is no longer open.';
  end if;
  if t.excluded_operator = v_me then
    raise exception 'This is a second try of a task of yours: it is for someone else.';
  end if;
  if not v_coordinator and not public.user_qualifies_for_category(v_me, t.category) then
    raise exception 'This task needs a qualification you do not have yet.';
  end if;
  if p_due_date is null then raise exception 'Please choose the date by which you will finish.'; end if;
  -- The server counts days in UTC, behind Pakistan: yesterday here may still be today there, never the other way round.
  if p_due_date < current_date then raise exception 'Please choose a date from today on.'; end if;
  if p_due_date > current_date + 366 then raise exception 'Please choose a date within a year.'; end if;

  update public.tasks
  set status = 'claimed', claimed_by = v_me,
      claimed_by_email = (select r.email from public.user_roles r where r.user_id = v_me),
      claimed_at = now(), due_date = p_due_date
  where id = p_task_id;
end;
$$;
revoke all on function public.claim_task(bigint, date) from public, anon;
grant execute on function public.claim_task(bigint, date) to authenticated;

-- 2. Sending it for review.
create or replace function public.submit_task(p_task_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t public.tasks%rowtype;
begin
  select * into t from public.tasks where id = p_task_id for update;
  if not found or t.claimed_by is distinct from auth.uid() then raise exception 'You can only send a task you have taken.'; end if;
  if t.status <> 'claimed' then raise exception 'This task has already been sent, or is no longer yours.'; end if;
  if t.document_id is not null and not exists (select 1 from public.documents d where d.source_task_id = p_task_id) then
    raise exception 'Please upload the corrected file first.';
  end if;
  update public.tasks set status = 'submitted', submitted_at = now() where id = p_task_id;
end;
$$;
revoke all on function public.submit_task(bigint) from public, anon;
grant execute on function public.submit_task(bigint) to authenticated;

-- 3. What can still be written directly, and by whom. Not security definer on purpose: inside the functions above and the
--    review functions current_user is their owner, so this lets them through; from the app it is 'authenticated'.
create or replace function public.guard_task_direct_write()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if current_user not in ('authenticated', 'anon') then
    return new;
  end if;

  if tg_op = 'INSERT' then
    if new.status not in ('open', 'claimed') or (new.status = 'claimed') <> (new.claimed_by is not null) then
      raise exception 'A new task is either open, or assigned to someone.';
    end if;
    if new.review_verdict is not null or new.review_notes is not null or new.reviewed_by is not null
       or new.reviewed_by_email is not null or new.reviewed_at is not null or new.submitted_at is not null
       or new.published_at is not null or new.retry_of_task_id is not null or new.excluded_operator is not null then
      raise exception 'A new task cannot carry a review.';
    end if;
    if coalesce(new.credits, 0) <> coalesce(new.base_credits, 0) + coalesce(new.extra_credits, 0) then
      raise exception 'The credits of a task are its base credits and its extra credits.';
    end if;
    -- Who proposes extra credits cannot approve them: so who creates a task is not the browser's to say.
    new.created_by_email := (select r.email from public.user_roles r where r.user_id = auth.uid());
    new.created_at := now();
    return new;
  end if;

  if new.status is distinct from old.status and (old.status, new.status) not in (('open', 'withdrawn'), ('withdrawn', 'open')) then
    raise exception 'This change to a task is made through its own button.';
  end if;
  if new.claimed_by is distinct from old.claimed_by
     and not (old.status = 'claimed' and new.status = 'claimed' and new.claimed_by is not null) then
    raise exception 'A task is taken, returned or freed through its own button.';
  end if;
  if row(new.id, new.credits, new.base_credits, new.extra_credits, new.extra_credits_note, new.category, new.document_id, new.document_pages)
       is distinct from row(old.id, old.credits, old.base_credits, old.extra_credits, old.extra_credits_note, old.category, old.document_id, old.document_pages)
     or row(new.review_verdict, new.review_notes, new.reviewed_by, new.reviewed_by_email, new.reviewed_at, new.submitted_at, new.published_at)
       is distinct from row(old.review_verdict, old.review_notes, old.reviewed_by, old.reviewed_by_email, old.reviewed_at, old.submitted_at, old.published_at)
     or row(new.retry_of_task_id, new.excluded_operator, new.created_by_email, new.created_at)
       is distinct from row(old.retry_of_task_id, old.excluded_operator, old.created_by_email, old.created_at) then
    raise exception 'The credits, the review and the document of a task cannot be changed.';
  end if;
  return new;
end;
$$;
drop trigger if exists tasks_guard_direct_write on public.tasks;
create trigger tasks_guard_direct_write
  before insert or update on public.tasks
  for each row execute function public.guard_task_direct_write();

-- 4. Direct changes are for Coordinators and Admins only.
drop policy if exists "tasks_update_own_or_reviewers" on public.tasks;
drop policy if exists "tasks_update_reviewers" on public.tasks;
create policy "tasks_update_reviewers" on public.tasks for update
  using ((select public.current_role_is('coordinator')))
  with check ((select public.current_role_is('coordinator'))
              and (claimed_by is null or public.user_qualifies_for_category(claimed_by, category)
                   or claimed_by = (select auth.uid())));

-- 5. Verification: every row must say true.
select 'claim_task: signed-in people only' as item,
       has_function_privilege('authenticated', 'public.claim_task(bigint, date)', 'execute')
       and not has_function_privilege('anon', 'public.claim_task(bigint, date)', 'execute') as ok
union all
select 'submit_task: signed-in people only',
       has_function_privilege('authenticated', 'public.submit_task(bigint)', 'execute')
       and not has_function_privilege('anon', 'public.submit_task(bigint)', 'execute')
union all
select 'both run with their owner''s rights and a fixed search_path',
       (select count(*) = 2 and bool_and(prosecdef and coalesce(proconfig, '{}') @> array['search_path=public'])
        from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and proname in ('claim_task', 'submit_task'))
union all
select 'the guard is on, and runs with the caller''s rights',
       exists (select 1 from pg_trigger where tgrelid = 'public.tasks'::regclass and tgname = 'tasks_guard_direct_write' and tgenabled = 'O')
       and (select not prosecdef from pg_proc where oid = to_regprocedure('public.guard_task_direct_write()'))
union all
select 'one rule for direct changes, for Coordinators and Admins',
       (select count(*) = 1 and bool_and(policyname = 'tasks_update_reviewers' and qual like '%coordinator%')
        from pg_policies where schemaname = 'public' and tablename = 'tasks' and permissive = 'PERMISSIVE' and cmd in ('UPDATE', 'ALL'))
union all
select 'the review functions are still there, with their owner''s rights',
       (select count(*) = 5 and bool_and(prosecdef) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and proname in ('submit_task_review', 'admin_decide_task', 'give_up_task', 'reclaim_task', 'approve_task_extra_credits'))
union all
select 'the status steps are still checked',
       exists (select 1 from pg_trigger where tgrelid = 'public.tasks'::regclass and tgname = 'tasks_validate_status_transition' and tgenabled = 'O');
