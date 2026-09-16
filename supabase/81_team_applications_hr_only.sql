-- 81_team_applications_hr_only.sql
-- GOVERNANCE.md phase 2a, second half of PROJECT_HANDOFF_v23.md §3.2: Team Applications moves
-- from Coordinator to HR. Migration 80 (§8) deliberately kept Coordinator's RLS access so the
-- app kept working while only the client-side gate (canReviewTeamApplications() in core.js) was
-- HR-based - this migration drops the Coordinator clause from the two policies to match.
--
-- DO NOT RUN THIS until the JS from PROJECT_HANDOFF_v23.md §3.2 (People tab, canReviewTeamApplications
-- in core.js, the "People" tab gate in app.js, collaboration.js's renderApplicationsView) is
-- deployed and confirmed working - a Coordinator with no HR/lead/Admin role would otherwise lose
-- Team Applications access with no replacement UI yet visible to them.

drop policy if exists "collaboration_applications_select_reviewers" on public.collaboration_applications;
create policy "collaboration_applications_select_reviewers" on public.collaboration_applications
  for select using (public.is_dept_member('HR') or current_role_is('admin'));

drop policy if exists "collaboration_applications_update_reviewers" on public.collaboration_applications;
create policy "collaboration_applications_update_reviewers" on public.collaboration_applications
  for update using (public.is_dept_member('HR') or current_role_is('admin'))
  with check (
    current_role_is('admin')
    or (public.is_dept_member('HR') and status in ('recommended', 'rejected'))
  );

-- Self-test: both policies should reference is_dept_member, neither should mention 'coordinator'.
select 'policy select has no coordinator clause' as item,
  not exists (select 1 from pg_policies where tablename = 'collaboration_applications'
              and policyname = 'collaboration_applications_select_reviewers' and qual ilike '%coordinator%') as ok
union all
select 'policy update has no coordinator clause',
  not exists (select 1 from pg_policies where tablename = 'collaboration_applications'
              and policyname = 'collaboration_applications_update_reviewers' and (qual ilike '%coordinator%' or with_check ilike '%coordinator%'));
