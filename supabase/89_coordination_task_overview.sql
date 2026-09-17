-- 89_coordination_task_overview.sql
-- Coordination's My Department panel needs a live task-flow overview (open / claimed / overdue
-- / near due / awaiting review / awaiting publish) - nothing like it exists today: Tasks -> Team
-- overview (js/tasks.js) filters a list but has no counts, and explicitly excludes open tasks.
--
-- Department membership ('COORD') and the user_roles.role = 'coordinator' role are two
-- independent things in this schema (checked: no trigger syncs them) - a Coordination lead
-- appointed via department_members does NOT automatically gain the `coordinator` role that
-- tasks_select_team (38_task_review_pipeline.sql) checks for full read access. Same fix as
-- Reward (migration 88): a small RPC, gated on department membership OR the coordinator/admin
-- role (so it works either way), rather than widening tasks' RLS or assuming the two are synced.

create or replace function public.coordination_task_overview()
returns table (
  id             bigint,
  title          text,
  category       text,
  status         text,
  claimed_by     uuid,
  due_date       date,
  created_at     timestamptz
)
language sql
security definer
stable
set search_path = public
as $$
  select t.id, t.title, t.category, t.status, t.claimed_by, t.due_date, t.created_at
  from public.tasks t
  where t.status in ('open', 'claimed', 'submitted', 'approved')
    and (public.is_dept_member('COORD') or current_role_is('coordinator') or current_role_is('admin'));
$$;

-- New policy value: how many days ahead counts as "near due" for the Coordination overview.
-- Owned by Coordination (GOVERNANCE.md §2.8 pattern extended to this department for the first
-- time) - editable later through the policy revision framework (migration 86), not hard-coded.
insert into public.policy_values (key, value, label) values
  ('task_near_due_days', 3, 'A claimed task counts as "near due" this many days before its due date, in the Coordination overview')
on conflict (key) do nothing;

-- Self-test.
select 'function coordination_task_overview' as item, to_regproc('public.coordination_task_overview') is not null as ok
union all select 'policy_values.task_near_due_days', exists (select 1 from policy_values where key = 'task_near_due_days');
