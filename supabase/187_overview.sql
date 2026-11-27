-- 187: the Overview of Admins and Coordinators, step B (Owner's decision, 2026-11-27, ADMIN_Proposta_regia.html).
-- Two functions that only read; no table changes. Safe to run again.
--   overview_board()   deadlines (tasks, department priorities, formation enrolments) and how we are (departments; for
--                      Admins also people at risk, funds, space for recordings, the second step of the Admins).
--                      Admin and Coordinator only; what is the Admin's stays empty for a Coordinator.
--   overview_archive() how far the archive is: Link-ups in Urdu, Urdu with English, Urdu PDFs typed, texts reread, the
--                      months of the Word of Life. With the rights of whoever calls it (as the searches of 186): a document
--                      that person cannot read is not counted.

create or replace function public.overview_board()
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_admin boolean := public.current_role_is('admin');
  v_idle integer := coalesce((select value from public.policy_values where key = 'task_idle_days'), 14);
  v_deadlines jsonb;
  v_depts jsonb;
  v_at_risk integer;
  v_budget bigint; v_used bigint; v_spent90 bigint;
  v_space jsonb;
  v_admins integer; v_admins_second integer;
begin
  if not public.current_role_is('coordinator') then return null; end if;

  -- What falls due in the next 30 days, or is already late.
  select coalesce(jsonb_agg(x order by x->>'date', x->>'title'), '[]'::jsonb) into v_deadlines from (
    select jsonb_build_object('kind', 'task', 'id', t.id, 'title', t.title, 'date', t.due_date) as x
      from public.tasks t where t.status = 'claimed' and t.due_date is not null and t.due_date <= current_date + 30
    union all
    select jsonb_build_object('kind', 'idle', 'id', t.id, 'title', t.title, 'date', (t.claimed_at::date + v_idle), 'since', t.claimed_at::date)
      from public.tasks t where t.status = 'claimed' and t.due_date is null and t.claimed_at < now() - make_interval(days => v_idle)
    union all
    select jsonb_build_object('kind', 'priority', 'id', p.id, 'title', p.title, 'date', p.due_date, 'department', p.department_code)
      from public.department_priorities p where not p.done and p.due_date is not null and p.due_date <= current_date + 30
    union all
    select jsonb_build_object('kind', 'enrolment', 'id', f.id, 'title', f.title, 'date', f.enrollment_deadline)
      from public.formation_paths f where f.status = 'published' and f.enrollment_deadline between current_date and current_date + 30
  ) s;

  -- The departments: how many on track, slowing, stalled (a department with no status set is on track).
  select jsonb_build_object(
           'on_track', count(*) filter (where coalesce(s.status, 'on_track') = 'on_track'),
           'slowing',  count(*) filter (where s.status = 'slowing'),
           'stalled',  count(*) filter (where s.status = 'stalled'))
    into v_depts
    from public.option_lists o left join public.department_status s on s.department_code = o.code
   where o.list_name = 'department';

  if v_admin then
    begin
      select count(*) into v_at_risk from public.hr_people_overview() h where h.at_risk;
    exception when others then v_at_risk := null;
    end;
    -- Funds as in Tasks -> Budget: what was added, less the credits of every task posted; and what the last 90 days used.
    select coalesce(sum(amount), 0) into v_budget from public.budget_ledger;
    select coalesce(sum(credits), 0) into v_used from public.tasks where status in ('open', 'claimed', 'submitted', 'approved', 'published');
    select coalesce(sum(credits), 0) into v_spent90 from public.tasks where status = 'published' and published_at > now() - interval '90 days';
    begin
      v_space := jsonb_build_object('used', public.reading_space_used(), 'limit', public.reading_space_limit());
    exception when others then v_space := null;
    end;
    select count(*), count(*) filter (where exists (select 1 from auth.mfa_factors f where f.user_id = r.user_id and f.status = 'verified'))
      into v_admins, v_admins_second
      from public.user_roles r where r.role = 'admin';
  end if;

  return jsonb_build_object(
    'deadlines', v_deadlines,
    'departments', v_depts,
    'admin', case when v_admin then jsonb_build_object(
      'at_risk', v_at_risk,
      'budget', v_budget, 'available', v_budget - v_used, 'spent_90', v_spent90,
      'space', v_space,
      'admins', v_admins, 'admins_second_step', v_admins_second) end);
end;
$$;
revoke execute on function public.overview_board() from public, anon;
grant execute on function public.overview_board() to authenticated;

create or replace function public.overview_archive()
returns jsonb
language sql stable security invoker set search_path = public as $$
  with d as (select * from public.find_work_docs() where has_text or has_pdf),
  works as (
    select w, bool_or(language = 'ITA') ita, bool_or(language = 'URD') urd, bool_or(language = 'ENG') eng, bool_or(category = 'Lkp') lkp
    from d group by w),
  wol as (select distinct note as ym from public.find_wol_documents() where language = 'URD' and note >= '1980-01' and note <= to_char(current_date, 'YYYY-MM'))
  select case when public.find_work_allowed() then jsonb_build_object(
    'lkp_ita',      (select count(*) from works where lkp and ita),
    'lkp_ita_urd',  (select count(*) from works where lkp and ita and urd),
    'urd_works',    (select count(*) from works where urd),
    'urd_with_eng', (select count(*) from works where urd and eng),
    'urd_pdf',      (select count(*) from d where language = 'URD' and has_pdf),
    'urd_pdf_typed',(select count(*) from d where language = 'URD' and has_pdf and has_text),
    'urd_typed',    (select count(*) from d where language = 'URD' and has_text),
    'urd_reread',   (select count(*) from d where language = 'URD' and has_text and reviewed),
    'wol_months',   (select count(*) from wol),
    'wol_total',    ((extract(year from current_date)::int - 1980) * 12 + extract(month from current_date)::int),
    'wol_this',     exists (select 1 from wol where ym = to_char(current_date, 'YYYY-MM')),
    'wol_next',     exists (select 1 from public.find_wol_documents() where language = 'URD' and note = to_char(current_date + interval '1 month', 'YYYY-MM'))
  ) end;
$$;
revoke execute on function public.overview_archive() from public, anon;
grant execute on function public.overview_archive() to authenticated;

notify pgrst, 'reload schema';

-- Check: every row true.
select 1 as n, 'The board is there, for the team only' as item,
       has_function_privilege('authenticated', 'public.overview_board()', 'execute') and not has_function_privilege('anon', 'public.overview_board()', 'execute') as ok
union all select 2, 'The board only reads and runs as its owner',
       (select prosecdef and provolatile = 's' from pg_proc where oid = 'public.overview_board()'::regprocedure)
union all select 3, 'The archive is there, for the team only',
       has_function_privilege('authenticated', 'public.overview_archive()', 'execute') and not has_function_privilege('anon', 'public.overview_archive()', 'execute')
union all select 4, 'The archive counts with the rights of whoever asks',
       (select not prosecdef and provolatile = 's' from pg_proc where oid = 'public.overview_archive()'::regprocedure)
union all select 5, 'Without a role in the team: nothing',
       public.overview_board() is null and public.overview_archive() is null
order by n;
