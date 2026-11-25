-- 176: the task desk (Owner's decisions, 2026-11-25).
--   1. A person has at most three tasks in progress. Coordinators and Admins change the number (Tasks, Team overview). A task
--      given by a Coordinator is not stopped by it.
--   2. A review that says "OK, but..." or "Fail" carries a note for who did the work.
--   3. No login stays in the tasks and in their history: who created, took and judged a task is said by the account, and the
--      names come from people_names(). Two lists that showed a login show the name.
-- Run AFTER the code of the same pull request is live (it works with and without this file). Safe to run again.

-- ============================================================================
-- 1. How many at once
-- ============================================================================
insert into public.policy_values (key, value, label)
values ('task_max_in_progress', 3, 'How many tasks a person can have in progress at the same time')
on conflict (key) do nothing;

create or replace function public.set_task_limit(p_value integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('coordinator') then raise exception 'Only Coordinators and Admins can change this number.'; end if;
  if p_value is null or p_value < 1 or p_value > 20 then raise exception 'Please choose a number from 1 to 20.'; end if;
  update public.policy_values set value = p_value where key = 'task_max_in_progress';
end;
$$;
revoke execute on function public.set_task_limit(integer) from public, anon;
grant execute on function public.set_task_limit(integer) to authenticated;

-- A rule that changes leaves a trace.
drop trigger if exists policy_values_log_change on public.policy_values;
create trigger policy_values_log_change after insert or update or delete on public.policy_values
  for each row execute function public.log_archive_change('key');

do $m$
declare
  v_def text;
  f record;
begin
  -- Taking a task.
  v_def := pg_get_functiondef('public.claim_task(bigint, date)'::regprocedure);
  if v_def !~ 'task_max_in_progress' then
    if position('  if p_due_date is null then' in v_def) = 0 then raise exception '176: claim_task is not as expected.'; end if;
    execute replace(v_def, '  if p_due_date is null then', $r$  -- One at a time for the same person, so two quick taps do not take two.
  perform pg_advisory_xact_lock(hashtext('claim_task ' || v_me::text));
  if (select count(*) from public.tasks m where m.claimed_by = v_me and m.status = 'claimed') >= public.policy_value('task_max_in_progress', 3) then
    raise exception 'You already have % tasks in progress. Send one, or return one, and then you can take this.', public.policy_value('task_max_in_progress', 3);
  end if;
  if p_due_date is null then$r$);
  end if;

  -- 2. The note.
  for f in select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'submit_task_review' and p.prosrc !~ 'write a note' loop
    v_def := pg_get_functiondef(f.oid);
    if position('raise exception ''Invalid verdict.'';' in v_def) = 0 then raise exception '176: submit_task_review is not as expected.'; end if;
    execute regexp_replace(v_def, '(raise exception ''Invalid verdict\.'';\s*end if;)', $r$\1
  if p_verdict in ('ok_but', 'fail') and coalesce(btrim(p_notes), '') = '' then
    raise exception 'Please write a note for the person who did the work.';
  end if;$r$);
  end loop;
end $m$;

-- ============================================================================
-- 3. Accounts instead of logins
-- ============================================================================
alter table public.tasks add column if not exists created_by uuid;
alter table public.tasks alter column created_by_email drop not null;
alter table public.task_outcome_events add column if not exists created_by uuid;

create or replace function public.set_task_creator()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' then
    new.created_by := old.created_by;
  elsif auth.uid() is not null then
    -- A second try keeps the person who created the first.
    new.created_by := coalesce(case when new.retry_of_task_id is not null and current_user <> 'authenticated'
                                    then (select t.created_by from public.tasks t where t.id = new.retry_of_task_id) end, auth.uid());
  end if;
  return new;
end;
$$;

do $m$
declare
  v_def text;
  f record;
begin
  alter table public.tasks disable trigger user;
  update public.tasks t set created_by = r.user_id from public.user_roles r where t.created_by is null and lower(r.email) = lower(t.created_by_email);
  update public.tasks set claimed_by_email = null, created_by_email = null, reviewed_by_email = null, extra_credits_approved_by_email = null
   where coalesce(claimed_by_email, created_by_email, reviewed_by_email, extra_credits_approved_by_email) is not null;
  alter table public.tasks enable trigger user;
  alter table public.task_outcome_events disable trigger user;
  update public.task_outcome_events e set created_by = r.user_id from public.user_roles r where e.created_by is null and lower(r.email) = lower(e.created_by_email);
  update public.task_outcome_events set created_by_email = null where created_by_email is not null;
  alter table public.task_outcome_events enable trigger user;

  -- Who proposes extra credits cannot approve them: by account.
  for f in select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'approve_task_extra_credits' and p.prosrc ~ 'created_by_email' loop
    v_def := pg_get_functiondef(f.oid);
    if position('t.created_by_email = v_email' in v_def) = 0 then raise exception '176: approve_task_extra_credits is not as expected.'; end if;
    execute replace(v_def, 't.created_by_email = v_email', 't.created_by = auth.uid()');
  end loop;
  -- The lists of Coordination and Reward: the name, in the same column.
  for f in select p.oid from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname in ('coordination_task_overview', 'reward_extra_credit_tasks') and p.prosrc ~ 't\.created_by_email' loop
    v_def := replace(pg_get_functiondef(f.oid), 't.created_by_email', '(select btrim(up.full_name) from public.user_profiles up where up.user_id = t.created_by)');
    execute replace(v_def, 't.extra_credits_approved_by_email', '(select btrim(up.full_name) from public.user_profiles up where up.user_id = t.extra_credits_approved_by)');
  end loop;
end $m$;

drop trigger if exists zz_set_task_creator on public.tasks;
create trigger zz_set_task_creator before insert or update on public.tasks for each row execute function public.set_task_creator();
drop trigger if exists zz_keep_no_login on public.tasks;
create trigger zz_keep_no_login before insert or update on public.tasks
  for each row execute function public.keep_no_login('claimed_by_email', 'created_by_email', 'reviewed_by_email', 'extra_credits_approved_by_email');
drop trigger if exists zz_set_person on public.task_outcome_events;
create trigger zz_set_person before insert on public.task_outcome_events for each row execute function public.set_person('always:created_by');
drop trigger if exists zz_keep_no_login on public.task_outcome_events;
create trigger zz_keep_no_login before insert on public.task_outcome_events for each row execute function public.keep_no_login('created_by_email');

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'The limit is there, and a Coordinator can change it' as item,
       exists (select 1 from public.policy_values where key = 'task_max_in_progress' and value between 1 and 20)
       and has_function_privilege('authenticated', 'public.set_task_limit(integer)', 'execute') and not has_function_privilege('anon', 'public.set_task_limit(integer)', 'execute') as ok
union all select 2, 'Taking a task counts those in progress', (select prosrc ~ 'task_max_in_progress' from pg_proc where oid = 'public.claim_task(bigint, date)'::regprocedure)
union all select 3, 'OK, but... and Fail ask for a note', (select bool_and(prosrc ~ 'write a note') from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'submit_task_review')
union all select 4, 'No login is left in the tasks and their history',
       not exists (select 1 from public.tasks where coalesce(claimed_by_email, created_by_email, reviewed_by_email, extra_credits_approved_by_email) is not null)
       and not exists (select 1 from public.task_outcome_events where created_by_email is not null)
union all select 5, 'Nor will it come back', (select count(*) = 2 from pg_trigger where tgname = 'zz_keep_no_login' and tgenabled = 'O' and tgrelid in ('public.tasks'::regclass, 'public.task_outcome_events'::regclass))
union all select 6, 'Who created a task is an account', exists (select 1 from pg_trigger where tgname = 'zz_set_task_creator' and tgenabled = 'O')
       and (select count(*) = 0 or count(created_by) > 0 from public.tasks)
union all select 7, 'Extra credits: by account, not by login', (select bool_and(prosrc !~ 'created_by_email') from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'approve_task_extra_credits')
union all select 8, 'The two lists show names', (select count(*) = 2 and bool_and(prosrc !~ 't\.created_by_email' and prosrc ~ 'up\.full_name') from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname in ('coordination_task_overview', 'reward_extra_credit_tasks'))
union all select 9, 'No trigger was left off', not exists (select 1 from pg_trigger where tgrelid in ('public.tasks'::regclass, 'public.task_outcome_events'::regclass) and not tgisinternal and tgenabled = 'D')
order by 1;
