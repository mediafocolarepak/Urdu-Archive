-- 188: the Overview of Admins and Coordinators, step C (Owner's decision, 2026-11-27, ADMIN_Proposta_regia.html).
-- Safe to run again.
--   1. Two thresholds of the Overview, which an Admin changes in Options: after how many days something waiting turns red
--      (7), after how many days a task taken with no due date goes into Deadlines (14).
--   2. People who came in: each day, how many different people opened the app, by role. Only the number, never who.
--      The app keeps, for each person, only the moment of the last visit, so that it can say "since your last visit"
--      to that person alone and count a person once a day.
--   3. Readings by branch of the Focolare (Owner's request, 2026-11-27): each day, for each branch (membership_type of the
--      profile), how many documents were opened and how many recordings were heard. Without names and without the document.
--      Counted from the counters that already exist (migrations 114 and 129), so nothing changes in what is counted.
--   4. overview_trends(): the last 12 weeks, the branches, and what changed since the last visit. Admin and Coordinator only.
-- The new numbers start from the day this runs.

-- ============================================================================
-- 1. The thresholds
-- ============================================================================
insert into public.policy_values (key, value, label) values
  ('waiting_red_days', 7, 'Days after which something waiting in the Overview turns red'),
  ('task_idle_days', 14, 'Days after which a task taken with no due date goes into Deadlines')
on conflict (key) do nothing;

create or replace function public.set_overview_thresholds(p_red integer, p_idle integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('admin') then raise exception 'Only an Admin can change this.'; end if;
  if p_red is null or p_red < 1 or p_red > 90 or p_idle is null or p_idle < 1 or p_idle > 90 then
    raise exception 'Please choose numbers from 1 to 90.';
  end if;
  update public.policy_values set value = p_red, updated_at = now(), updated_by_email = (select email from auth.users where id = auth.uid()) where key = 'waiting_red_days';
  update public.policy_values set value = p_idle, updated_at = now(), updated_by_email = (select email from auth.users where id = auth.uid()) where key = 'task_idle_days';
end;
$$;
revoke execute on function public.set_overview_thresholds(integer, integer) from public, anon;
grant execute on function public.set_overview_thresholds(integer, integer) to authenticated;

-- ============================================================================
-- 2. People who came in
-- ============================================================================
create table if not exists public.visit_counts (
  day    date not null default current_date,
  role   text not null,
  people integer not null default 0,
  primary key (day, role)
);
create table if not exists public.visit_last (
  user_id   uuid primary key references auth.users(id) on delete cascade,
  seen_at   timestamptz not null default now(),
  before_at timestamptz
);
alter table public.visit_counts enable row level security;
alter table public.visit_last enable row level security;
-- No rule at all: only the functions below reach them.

-- Called once when the app opens. Counts this person once a day, and gives back when this person came in before today.
create or replace function public.note_visit()
returns timestamptz
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.visit_last;
  v_new boolean := false;
  v_role text;
begin
  if v_uid is null or not public.current_role_is('user') then return null; end if;
  select * into v_row from public.visit_last where user_id = v_uid for update;
  if not found then
    insert into public.visit_last (user_id) values (v_uid) on conflict (user_id) do nothing;
    v_new := found;
  elsif v_row.seen_at::date < current_date then
    update public.visit_last set before_at = v_row.seen_at, seen_at = now() where user_id = v_uid;
    v_new := true;
    v_row.before_at := v_row.seen_at;
  else
    update public.visit_last set seen_at = now() where user_id = v_uid;
  end if;
  if v_new then
    v_role := case when public.current_role_is('admin') then 'admin' when public.current_role_is('coordinator') then 'coordinator'
                   when public.current_role_is('operator') then 'operator' else 'user' end;
    insert into public.visit_counts (role, people) values (v_role, 1)
    on conflict (day, role) do update set people = public.visit_counts.people + 1;
  end if;
  return v_row.before_at;
end;
$$;
revoke execute on function public.note_visit() from public, anon;
grant execute on function public.note_visit() to authenticated;

-- ============================================================================
-- 3. Readings by branch
-- ============================================================================
create table if not exists public.branch_read_counts (
  day    date not null default current_date,
  branch text not null,
  opens  integer not null default 0,
  plays  integer not null default 0,
  primary key (day, branch)
);
alter table public.branch_read_counts enable row level security;
-- No rule at all: only overview_trends() reads it.

-- Each time a counter of 114 or 129 goes up, the same number goes to the branch of whoever opened or listened.
create or replace function public.count_by_branch()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_branch text := coalesce(nullif((select p.membership_type from public.user_profiles p where p.user_id = auth.uid()), ''), 'none');
  v_opens integer := 0;
  v_plays integer := 0;
begin
  if tg_table_name = 'document_open_counts' then v_opens := new.opens - coalesce(case when tg_op = 'UPDATE' then old.opens end, 0);
  else v_plays := new.plays - coalesce(case when tg_op = 'UPDATE' then old.plays end, 0);
  end if;
  if v_opens > 0 or v_plays > 0 then
    insert into public.branch_read_counts (day, branch, opens, plays) values (new.day, v_branch, greatest(v_opens, 0), greatest(v_plays, 0))
    on conflict (day, branch) do update set opens = public.branch_read_counts.opens + excluded.opens, plays = public.branch_read_counts.plays + excluded.plays;
  end if;
  return new;
end;
$$;
revoke execute on function public.count_by_branch() from public, anon, authenticated;

drop trigger if exists document_open_counts_by_branch on public.document_open_counts;
create trigger document_open_counts_by_branch after insert or update on public.document_open_counts
  for each row execute function public.count_by_branch();
drop trigger if exists audio_play_counts_by_branch on public.audio_play_counts;
create trigger audio_play_counts_by_branch after insert or update on public.audio_play_counts
  for each row execute function public.count_by_branch();

-- ============================================================================
-- 4. The weeks, the branches, since the last visit
-- ============================================================================
create or replace function public.overview_trends(p_since timestamptz default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_first date := date_trunc('week', current_date)::date - 77;   -- the Monday 11 weeks before this week's
  v_weeks jsonb;
  v_branches jsonb;
  v_roles jsonb;
  v_since jsonb;
begin
  if not public.current_role_is('coordinator') then return null; end if;

  select jsonb_agg(jsonb_build_object(
           'week', w.d,
           'days', least(7, current_date - w.d + 1),
           'visits',    (select coalesce(sum(people), 0) from public.visit_counts where day >= w.d and day < w.d + 7),
           'opens',     (select coalesce(sum(opens), 0) from public.document_open_counts where day >= w.d and day < w.d + 7),
           'plays',     (select coalesce(sum(plays), 0) from public.audio_play_counts where day >= w.d and day < w.d + 7),
           'published', (select count(*) from public.tasks where status = 'published' and published_at >= w.d and published_at < w.d + 7),
           'accounts',  (select count(*) from public.user_profiles where created_at >= w.d and created_at < w.d + 7))
         order by w.d)
    into v_weeks
    from (select (v_first + 7 * i) as d from generate_series(0, 11) i) w;

  select coalesce(jsonb_agg(jsonb_build_object('branch', b.branch, 'opens', b.opens, 'plays', b.plays) order by b.opens + b.plays desc, b.branch), '[]'::jsonb)
    into v_branches
    from (select branch, sum(opens) as opens, sum(plays) as plays from public.branch_read_counts where day >= v_first group by branch) b;

  select coalesce(jsonb_object_agg(r.role, r.visits), '{}'::jsonb) into v_roles
    from (select role, sum(people) as visits from public.visit_counts where day >= v_first group by role) r;

  if p_since is not null then
    v_since := jsonb_build_object(
      'accounts',  (select count(*) from public.user_profiles where created_at > p_since),
      'opens',     (select coalesce(sum(opens), 0) from public.document_open_counts where day > p_since::date),
      'plays',     (select coalesce(sum(plays), 0) from public.audio_play_counts where day > p_since::date),
      'submitted', (select count(*) from public.tasks where submitted_at > p_since),
      'published', (select count(*) from public.tasks where status = 'published' and published_at > p_since),
      'messages',  (select count(*) from public.chat_messages where created_at > p_since));
  end if;

  return jsonb_build_object(
    'weeks', v_weeks,
    'counting_since', (select min(day) from public.visit_counts),
    'branches_since', (select min(day) from public.branch_read_counts),
    'branches', v_branches,
    'roles', v_roles,
    'since', v_since);
end;
$$;
revoke execute on function public.overview_trends(timestamptz) from public, anon;
grant execute on function public.overview_trends(timestamptz) to authenticated;

notify pgrst, 'reload schema';

-- Check: every row true.
select 1 as n, 'The two thresholds are there' as item,
       (select count(*) = 2 from public.policy_values where key in ('waiting_red_days', 'task_idle_days')) as ok
union all select 2, 'Only an Admin changes them, with a function',
       has_function_privilege('authenticated', 'public.set_overview_thresholds(integer, integer)', 'execute')
       and not has_function_privilege('anon', 'public.set_overview_thresholds(integer, integer)', 'execute')
union all select 3, 'The new counts are closed to everyone',
       (select bool_and(c.relrowsecurity) and not exists (select 1 from pg_policies p where p.schemaname = 'public' and p.tablename in ('visit_counts', 'visit_last', 'branch_read_counts'))
          from pg_class c where c.oid in ('public.visit_counts'::regclass, 'public.visit_last'::regclass, 'public.branch_read_counts'::regclass))
union all select 4, 'A visit is counted only by the app, for the person signed in',
       has_function_privilege('authenticated', 'public.note_visit()', 'execute') and not has_function_privilege('anon', 'public.note_visit()', 'execute')
union all select 5, 'Openings and recordings also go to the branch',
       (select count(*) = 2 from pg_trigger where tgname in ('document_open_counts_by_branch', 'audio_play_counts_by_branch') and not tgisinternal)
union all select 6, 'The weeks are for the team only, and only read',
       has_function_privilege('authenticated', 'public.overview_trends(timestamptz)', 'execute') and not has_function_privilege('anon', 'public.overview_trends(timestamptz)', 'execute')
       and (select prosecdef and provolatile = 's' from pg_proc where oid = 'public.overview_trends(timestamptz)'::regprocedure)
union all select 7, 'Without a role in the team: nothing',
       public.overview_trends(null) is null and public.note_visit() is null
order by n;
