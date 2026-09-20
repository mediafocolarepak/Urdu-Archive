-- 100_admin_project_stats.sql
-- Project overview (owner's request 2026-09-20): adds a "Users" panel alongside the department
-- cards, with headcount/demographics and Formation Paths enrollment numbers. Headcount and
-- demographics (user_roles, user_profiles) need no new function - Admin already reads those
-- tables directly client-side (same as admin.js's Users view). Enrollments are the one gap:
-- formation_enrollments' only select policy is "your own row" (74_formation_enrollments.sql), no
-- admin bypass, so an aggregate needs a security-definer function like this one.
--
-- Login/access tracking was asked about but isn't built here: Supabase's own sign-in timestamps
-- (auth.users.last_sign_in_at) aren't exposed to the client anywhere in this app today, and
-- deciding whether/how to surface that is a separate, privacy-sensitive product decision, not a
-- one-line add-on to this migration - see PROJECT_HANDOFF for the reasoning.
--
-- Run after 99_department_pulse_signals.sql. Idempotent, self-test at the end.

create or replace function public.admin_project_stats()
returns table(
  total_active_enrollments  bigint,
  distinct_enrolled_users   bigint,
  enrollments_by_path       json
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not current_role_is('admin') then
    return;
  end if;

  return query
  select
    coalesce((select count(*) from public.formation_enrollments where withdrawn_at is null), 0),
    coalesce((select count(distinct user_id) from public.formation_enrollments where withdrawn_at is null), 0),
    coalesce((
      select json_agg(json_build_object('path_id', fp.id, 'title', fp.title, 'enrolled', cnt.c) order by cnt.c desc)
      from public.formation_paths fp
      join (
        select path_id, count(*) as c from public.formation_enrollments where withdrawn_at is null group by path_id
      ) cnt on cnt.path_id = fp.id
    ), '[]'::json);
end;
$$;

-- ============================================================================
-- Self-test (run separately). All rows must be true.
-- ============================================================================
select 'function admin_project_stats' as item,
  exists (select 1 from pg_proc where proname = 'admin_project_stats') as ok;
