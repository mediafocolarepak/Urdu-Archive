-- 163: internal functions can no longer be called from outside.
--
-- In PostgreSQL a new function can be called by everybody unless that is taken away. The functions below are
-- steps of other functions, which check who is asking; they do not check it themselves. From now on only those
-- other functions (security definer, same owner) can call them. The app calls none of them directly.
--
-- Nothing else changes: no table, no data, no function body. Safe to run again.
--
-- To undo one, for example:  grant execute on function public.unsettled_credits(uuid) to authenticated;
--
-- Run in the Supabase Dashboard -> SQL Editor. Every row of the final table must say true.

-- 1. Nobody calls these from outside. By name, so a different list of parameters is covered too.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as fn
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prokind = 'f'
      and p.proname in (
        'apply_people_decision',                  -- step of propose_/decide_people_decision
        'apply_policy_change',                    -- step of decide_policy_change
        'formation_check_and_issue_certificate',  -- step of submit_formation_quiz_attempt
        'unsettled_credits',                      -- step of the compensation runs
        'take_reading_out',                       -- step of erase_reading, withdraw_reading_consent
        'submission_event',                       -- step of every action on a proposal
        'submission_problem',                     -- step of submit_/approve_submission
        'submission_for_decision',                -- step of approve_/send_back_/reject_submission
        'token_is_minor')                         -- step of the tokens functions
  loop
    execute format('revoke all on function %s from public, anon, authenticated', r.fn);
  end loop;
end;
$$;

-- 2. These five run with their owner's rights but did not say where to look for tables.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as fn
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
      and p.proname in ('current_role_is', 'user_qualifies_for_category', 'apply_task_outcome_deltas',
                        'reclaim_task', 'give_up_task')
  loop
    execute format('alter function %s set search_path = public', r.fn);
  end loop;
end;
$$;

-- 3. Verification: every row must say true.
with closed(name) as (
  values ('apply_people_decision'), ('apply_policy_change'), ('formation_check_and_issue_certificate'),
         ('unsettled_credits'), ('take_reading_out'), ('submission_event'), ('submission_problem'),
         ('submission_for_decision'), ('token_is_minor')
),
callers(caller, callee) as (
  values ('propose_people_decision', 'apply_people_decision'), ('decide_people_decision', 'apply_people_decision'),
         ('decide_policy_change', 'apply_policy_change'),
         ('submit_formation_quiz_attempt', 'formation_check_and_issue_certificate'),
         ('reward_unsettled_credits', 'unsettled_credits'), ('propose_compensation_run', 'unsettled_credits'),
         ('decide_compensation_run', 'unsettled_credits'),
         ('erase_reading', 'take_reading_out'), ('withdraw_reading_consent', 'take_reading_out'),
         ('save_submission', 'submission_event'), ('submit_submission', 'submission_event'),
         ('submit_submission', 'submission_problem'), ('approve_submission', 'submission_problem'),
         ('approve_submission', 'submission_for_decision'), ('reject_submission', 'submission_for_decision'),
         ('send_back_submission', 'submission_for_decision'),
         ('my_tokens', 'token_is_minor'), ('set_token_thanks_consent', 'token_is_minor'),
         ('reward_public_thanks', 'token_is_minor')
),
f as (
  select p.* from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.prokind = 'f'
)
select 'exists and is closed: ' || c.name as item,
       exists (select 1 from f where f.proname = c.name)
       and not exists (select 1 from f where f.proname = c.name
                       and (has_function_privilege('anon', f.oid, 'execute')
                            or has_function_privilege('authenticated', f.oid, 'execute'))) as ok
from closed c
union all
select 'still works: ' || k.caller || ' -> ' || k.callee,
       exists (select 1 from f where f.proname = k.caller)
       and not exists (
         select 1 from f a, f b
         where a.proname = k.caller and b.proname = k.callee
           and (not a.prosecdef or not has_function_privilege(a.proowner, b.oid, 'execute')
                or not has_function_privilege('authenticated', a.oid, 'execute')))
from callers k
union all
select 'search_path set on the five functions',
       (select count(distinct f.proname) = 5 and bool_and(coalesce(f.proconfig, '{}') @> array['search_path=public'])
        from f where f.proname in ('current_role_is', 'user_qualifies_for_category', 'apply_task_outcome_deltas',
                                   'reclaim_task', 'give_up_task'))
union all
select 'current_role_is still open to signed-in people and visitors (the rules need it)',
       (select bool_and(has_function_privilege('authenticated', f.oid, 'execute') and has_function_privilege('anon', f.oid, 'execute'))
        from f where f.proname = 'current_role_is')
order by 2, 1;
