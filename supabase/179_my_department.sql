-- 179: My Department (phase 4, Owner's decisions, 2026-11-25): people are known by name.
--   1. The list of People is for HR and Admins; it no longer carries logins, telephone numbers and cities. The login of one
--      person is asked one at a time, by HR and Admins (person_contact).
--   2. The proposals on the rules are read by the team. The rules in force stay readable by all.
--   3. No login stays in the decisions, the rules, the compensation runs, the budget, the tokens, the reserved documents and
--      the deleted ones: who did what is said by the account, and the names come from people_names().
--   4. A person is chosen by name (find_people): the leads for their team, Reward for the tokens. Names only.
--   5. "Suspend (no new tasks)" says what it does: no work until reinstated.
-- Run AFTER the code of the same pull request is live (it works with and without this file). Safe to run again.

-- ============================================================================
-- 1. Choosing a person, and the login of one
-- ============================================================================
create or replace function public.find_people(p_query text)
returns table (user_id uuid, full_name text)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_like text := '%' || replace(replace(replace(btrim(coalesce(p_query, '')), '\', '\\'), '%', '\%'), '_', '\_') || '%';
begin
  if not (public.current_role_is('coordinator') or public.is_any_dept_lead() or public.can_manage_tokens()) then
    raise exception 'You cannot look for people here.';
  end if;
  if length(btrim(coalesce(p_query, ''))) < 3 then return; end if;
  return query
    select r.user_id, btrim(p.full_name)
    from public.user_roles r join public.user_profiles p on p.user_id = r.user_id
    where btrim(coalesce(p.full_name, '')) <> '' and p.full_name ilike v_like and r.standing <> 'excluded'
    order by 2
    limit 10;
end;
$$;
revoke execute on function public.find_people(text) from public, anon;
grant execute on function public.find_people(text) to authenticated;

create or replace function public.person_contact(p_user_id uuid)
returns text
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not (public.is_dept_member('HR') or public.current_role_is('admin')) then
    raise exception 'Only HR and Admins can see how to contact a person.';
  end if;
  return (select r.email from public.user_roles r where r.user_id = p_user_id);
end;
$$;
revoke execute on function public.person_contact(uuid) from public, anon;
grant execute on function public.person_contact(uuid) to authenticated;

create or replace function public.token_give_titles_to(p_user_id uuid, p_note text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_rate integer := public.token_rate('unit');
  v_id bigint;
begin
  if not public.can_manage_tokens() then raise exception 'Only Reward gives these tokens.'; end if;
  if nullif(btrim(p_note), '') is null then raise exception 'Please say which batch of answers.'; end if;
  if not exists (select 1 from public.user_roles where user_id = p_user_id) then raise exception 'This person has no account.'; end if;
  if p_user_id = auth.uid() then raise exception 'Someone else in Reward gives tokens for your own answers.'; end if;
  insert into public.token_events (user_id, kind, unit, units, tokens, valued_at, note, created_by)
  values (p_user_id, 'titles', 'unit', 1, v_rate, case when v_rate is not null then now() end, btrim(p_note), auth.uid())
  returning id into v_id;
  return v_id;
end;
$$;
revoke execute on function public.token_give_titles_to(uuid, text) from public, anon;
grant execute on function public.token_give_titles_to(uuid, text) to authenticated;
-- The old one, which took an email.
do $m$
begin
  if to_regprocedure('public.token_give_for_titles(text, text)') is not null then
    revoke execute on function public.token_give_for_titles(text, text) from public, anon, authenticated;
  end if;
end $m$;

-- ============================================================================
-- 2. Who reads the proposals on the rules
-- ============================================================================
create or replace function public.is_any_dept_member()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.department_members where public.person_may_work() and user_id = auth.uid());
$$;
revoke execute on function public.is_any_dept_member() from public, anon;
grant execute on function public.is_any_dept_member() to authenticated;

drop policy if exists "policy_proposals_select" on public.policy_proposals;
create policy "policy_proposals_select" on public.policy_proposals for select to authenticated
  using ((select public.current_role_is('operator')) or (select public.is_any_dept_member()));

-- ============================================================================
-- 3. Accounts instead of logins
-- ============================================================================
alter table public.budget_ledger         add column if not exists created_by uuid;
alter table public.reserved_access       add column if not exists granted_by uuid;
alter table public.reserved_access       add column if not exists revoked_by uuid;
alter table public.policy_values         add column if not exists updated_by uuid;
alter table public.task_reputation_tiers add column if not exists updated_by uuid;
alter table public.token_milestones      add column if not exists updated_by uuid;
alter table public.token_texts           add column if not exists updated_by uuid;
alter table public.compensation_runs     alter column prepared_by_email drop not null;
alter table public.compensation_lines    alter column user_email drop not null;

do $m$
declare
  x record;
  f record;
  v_def text;
  v_new text;
  v_name constant text := '(select nullif(btrim(up.full_name), '''') from public.user_profiles up where up.user_id = ';
begin
  -- The past: the account from the login, then the login goes.
  for x in select * from (values
      ('budget_ledger', 'created_by', 'created_by_email'), ('reserved_access', 'granted_by', 'granted_by_email'), ('reserved_access', 'revoked_by', 'revoked_by_email'),
      ('policy_values', 'updated_by', 'updated_by_email'), ('task_reputation_tiers', 'updated_by', 'updated_by_email'),
      ('token_milestones', 'updated_by', 'updated_by_email'), ('token_texts', 'updated_by', 'updated_by_email'),
      ('policy_proposals', 'decided_by', 'decided_by_email'), ('people_decisions', 'decided_by', 'decided_by_email'),
      ('compensation_runs', 'decided_by', 'decided_by_email'), ('token_events', 'created_by', 'created_by_email'),
      ('token_annulments', 'annulled_by', 'annulled_by_email'), ('documents', 'deleted_by', 'deleted_by_email')) as v(t, id_col, email_col)
    join information_schema.columns k on k.table_schema = 'public' and k.table_name = v.t and k.column_name = v.email_col
  loop
    execute format('alter table public.%I disable trigger user', x.t);
    execute format('update public.%I t set %I = r.user_id from public.user_roles r where t.%I is null and t.%I is not null and lower(r.email) = lower(t.%I)', x.t, x.id_col, x.id_col, x.email_col, x.email_col);
    execute format('alter table public.%I enable trigger user', x.t);
  end loop;

  for x in
    select v.t, v.col from (values
      ('policy_proposals', 'proposed_by_email'), ('policy_proposals', 'decided_by_email'),
      ('people_decisions', 'subject_email'), ('people_decisions', 'proposed_by_email'), ('people_decisions', 'decided_by_email'),
      ('compensation_runs', 'prepared_by_email'), ('compensation_runs', 'decided_by_email'), ('compensation_lines', 'user_email'),
      ('budget_ledger', 'created_by_email'), ('token_events', 'user_email'), ('token_events', 'created_by_email'), ('token_annulments', 'annulled_by_email'),
      ('reserved_access', 'granted_by_email'), ('reserved_access', 'revoked_by_email'),
      ('policy_values', 'updated_by_email'), ('task_reputation_tiers', 'updated_by_email'), ('token_milestones', 'updated_by_email'), ('token_texts', 'updated_by_email'),
      ('documents', 'deleted_by_email')) as v(t, col)
    join information_schema.columns k on k.table_schema = 'public' and k.table_name = v.t and k.column_name = v.col
  loop
    execute format('alter table public.%I disable trigger user', x.t);
    execute format('update public.%I set %I = null where %I is not null', x.t, x.col, x.col);
    execute format('alter table public.%I enable trigger user', x.t);
  end loop;

  -- From now on. "zz": after every other trigger of the table. On documents only when a document is deleted.
  for x in
    select v.t, string_agg(quote_literal(v.col), ', ') as cols from (values
      ('policy_proposals', 'proposed_by_email'), ('policy_proposals', 'decided_by_email'),
      ('people_decisions', 'subject_email'), ('people_decisions', 'proposed_by_email'), ('people_decisions', 'decided_by_email'),
      ('compensation_runs', 'prepared_by_email'), ('compensation_runs', 'decided_by_email'), ('compensation_lines', 'user_email'),
      ('budget_ledger', 'created_by_email'), ('token_events', 'user_email'), ('token_events', 'created_by_email'), ('token_annulments', 'annulled_by_email'),
      ('reserved_access', 'granted_by_email'), ('reserved_access', 'revoked_by_email'),
      ('policy_values', 'updated_by_email'), ('task_reputation_tiers', 'updated_by_email'), ('token_milestones', 'updated_by_email'), ('token_texts', 'updated_by_email'),
      ('documents', 'deleted_by_email')) as v(t, col)
    join information_schema.columns k on k.table_schema = 'public' and k.table_name = v.t and k.column_name = v.col
    group by v.t
  loop
    execute format('drop trigger if exists zz_keep_no_login on public.%I', x.t);
    execute format('create trigger zz_keep_no_login before insert or update on public.%I for each row %s execute function public.keep_no_login(%s)',
      x.t, case when x.t = 'documents' then 'when (new.deleted_by_email is not null)' else '' end, x.cols);
  end loop;

  for x in select * from (values
      ('budget_ledger', '''author:created_by'''), ('policy_values', '''always:updated_by'''), ('task_reputation_tiers', '''always:updated_by'''),
      ('token_milestones', '''always:updated_by'''), ('token_texts', '''always:updated_by''')) as v(t, args)
  loop
    execute format('drop trigger if exists zz_set_person on public.%I', x.t);
    execute format('create trigger zz_set_person before insert or update on public.%I for each row execute function public.set_person(%s)', x.t, x.args);
  end loop;

  -- 4. The functions, from their live text. What is not as expected stops everything, and nothing is changed.
  for f in select p.oid, p.proname, p.prosrc from pg_proc p join pg_namespace n on n.oid = p.pronamespace
            where n.nspname = 'public' and p.proname in ('hr_people_overview', 'set_reserved_access', 'list_reserved_access', 'get_deleted_documents',
              'reward_operator_credit_anomalies', 'reward_unsettled_credits', 'reward_token_entries', 'reward_token_people')
  loop
    v_def := replace(pg_get_functiondef(f.oid), chr(13), '');
    v_new := v_def;
    if f.proname = 'hr_people_overview' and v_def ~ 'is_any_dept_lead|r\.email|p\.phone' then
      v_new := regexp_replace(v_new, '\s+or\s+(public\.)?is_any_dept_lead\(\)', '', 'i');
      v_new := regexp_replace(v_new, 'r\.email,\s*coalesce\(p\.full_name, ''''\),\s*p\.city,\s*p\.membership_type,\s*p\.phone,', 'null::text, coalesce(p.full_name, ''''), null::text, p.membership_type, null::text,', 'i');
      v_new := regexp_replace(v_new, '(order by coalesce\(p\.full_name, ''''\)),\s*r\.email', '\1, r.user_id', 'i');
      if v_new ~ 'is_any_dept_lead|r\.email|p\.phone|p\.city' then raise exception '179: hr_people_overview is not as expected.'; end if;
    elsif f.proname = 'set_reserved_access' and v_def !~ 'granted_by,' then
      v_new := replace(v_new, 'insert into public.reserved_access (user_id, granted_by_email, granted_at, reason)', 'insert into public.reserved_access (user_id, granted_by, granted_at, reason)');
      v_new := replace(v_new, 'values (p_user_id, v_email, now(),', 'values (p_user_id, auth.uid(), now(),');
      v_new := replace(v_new, 'set granted_by_email = excluded.granted_by_email, granted_at', 'set granted_by = excluded.granted_by, granted_at');
      v_new := replace(v_new, 'revoked_by_email = null, revoked_at', 'revoked_by = null, revoked_at');
      v_new := replace(v_new, 'set revoked_by_email = v_email, revoked_at', 'set revoked_by = auth.uid(), revoked_at');
      if v_new ~ '_by_email' or v_new !~ 'granted_by = excluded' or v_new !~ 'revoked_by = auth' then raise exception '179: set_reserved_access is not as expected.'; end if;
    elsif f.proname = 'list_reserved_access' and v_def ~ 'a\.granted_by_email' then
      -- An exact login still finds its person; a piece of it does not.
      v_new := replace(v_new, 'a.granted_by_email, a.granted_at', v_name || 'a.granted_by) as granted_by_name, a.granted_at');
      v_new := replace(v_new, 'case when x.has_grant then x.granted_by_email end', 'case when x.has_grant then x.granted_by_name end');
      v_new := replace(v_new, 'select x.user_id, x.full_name, x.email, x.role,', 'select x.user_id, x.full_name, null::text, x.role,');
      v_new := replace(v_new, 'x.email ilike v_like', 'lower(x.email) = lower(btrim(p_query))');
      v_new := regexp_replace(v_new, '(order by x\.is_auto, x\.full_name), x\.email', '\1, x.user_id');
      if v_new ~ 'x\.email,|email ilike|x\.granted_by_email' then raise exception '179: list_reserved_access is not as expected.'; end if;
    elsif f.proname = 'get_deleted_documents' and v_def ~ 'd\.deleted_by_email' then
      v_new := replace(v_new, 'd.deleted_by_email', v_name || 'd.deleted_by)');
    elsif f.proname in ('reward_operator_credit_anomalies', 'reward_unsettled_credits') and v_def ~ 'ur\.email' then
      v_new := replace(v_new, 'ur.email', 'null::text');
    elsif f.proname = 'reward_token_entries' and v_def ~ 'e\.user_email' then
      v_new := replace(v_new, 'e.user_email', v_name || 'e.user_id)');
    elsif f.proname = 'reward_token_people' and v_def ~ 'max\(e\.user_email\)' then
      v_new := replace(v_new, 'max(e.user_email)', 'null::text');
    end if;
    if v_new is distinct from v_def then execute v_new; end if;
  end loop;

  -- The names of those a decision, a payment or a token is about.
  v_def := replace(pg_get_functiondef('public.people_names(uuid[], text[])'::regprocedure), chr(13), '');
  if v_def !~ 'people_decisions' then
    v_new := replace(v_def, 'or (me.lead and exists (select 1 from public.share_with_us_messages s where s.user_id = a.user_id))',
      'or (me.lead and exists (select 1 from public.share_with_us_messages s where s.user_id = a.user_id))
      -- whoever a decision, a payment or a token is about, for those who handle it
      or (me.hr and exists (select 1 from public.people_decisions d where a.user_id in (d.subject_user_id, d.proposed_by, d.decided_by)))
      or (public.is_dept_lead(''FORM'') and exists (select 1 from public.people_decisions d where a.user_id in (d.subject_user_id, d.proposed_by, d.decided_by)
            and d.decision_type in (''board_misuse'', ''board_block'', ''board_unblock'')))
      or (public.is_dept_member(''RF'') and (exists (select 1 from public.compensation_lines l where l.user_id = a.user_id)
            or exists (select 1 from public.token_events k where k.user_id = a.user_id)))');
    if v_new = v_def then raise exception '179: people_names is not as expected.'; end if;
    execute v_new;
  end if;
end $m$;

update public.option_lists set label = 'Suspend (no work until reinstated)'
 where list_name = 'people_decision_type' and code = 'suspend' and label = 'Suspend (no new tasks)';

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'The list of People: HR and Admins, no login, telephone or city' as item,
       (select prosrc !~ 'is_any_dept_lead|r\.email|p\.phone|p\.city' and prosrc ~ '''HR''' from pg_proc where oid = 'public.hr_people_overview()'::regprocedure) as ok
union all select 2, 'The login of one person: HR and Admins', (select prosrc ~ '''HR''' from pg_proc where oid = 'public.person_contact(uuid)'::regprocedure)
       and not has_function_privilege('anon', 'public.person_contact(uuid)', 'execute')
union all select 3, 'A person is found by name', has_function_privilege('authenticated', 'public.find_people(text)', 'execute') and not has_function_privilege('anon', 'public.find_people(text)', 'execute')
union all select 4, 'The proposals on the rules: the team', (select count(*) = 1 and bool_and(qual ~ 'operator' and qual ~ 'is_any_dept_member') from pg_policies where schemaname = 'public' and tablename = 'policy_proposals' and cmd in ('SELECT', 'ALL'))
union all select 5, 'The rules in force: everyone', exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'policy_values' and cmd = 'SELECT' and qual ~ '''user''')
union all select 6, 'No login in proposals and decisions', not exists (select 1 from public.policy_proposals where coalesce(proposed_by_email, decided_by_email) is not null)
       and not exists (select 1 from public.people_decisions where coalesce(subject_email, proposed_by_email, decided_by_email) is not null)
union all select 7, 'Nor in runs, budget and tokens', not exists (select 1 from public.compensation_runs where coalesce(prepared_by_email, decided_by_email) is not null)
       and not exists (select 1 from public.compensation_lines where user_email is not null) and not exists (select 1 from public.budget_ledger where created_by_email is not null)
       and not exists (select 1 from public.token_events where coalesce(user_email, created_by_email) is not null) and not exists (select 1 from public.token_annulments where annulled_by_email is not null)
union all select 8, 'Nor in reserved and deleted documents, and in the rules', not exists (select 1 from public.reserved_access where coalesce(granted_by_email, revoked_by_email) is not null)
       and not exists (select 1 from public.documents where deleted_by_email is not null)
       and not exists (select 1 from public.policy_values where updated_by_email is not null) and not exists (select 1 from public.task_reputation_tiers where updated_by_email is not null)
       and not exists (select 1 from public.token_milestones where updated_by_email is not null) and not exists (select 1 from public.token_texts where updated_by_email is not null)
union all select 9, 'Nor will it come back', (select count(*) = 13 from pg_trigger t join pg_class c on c.oid = t.tgrelid where t.tgname = 'zz_keep_no_login' and t.tgenabled = 'O' and c.relname in
       ('policy_proposals', 'people_decisions', 'compensation_runs', 'compensation_lines', 'budget_ledger', 'token_events', 'token_annulments', 'reserved_access', 'policy_values', 'task_reputation_tiers', 'token_milestones', 'token_texts', 'documents'))
union all select 10, 'The lists show names', (select count(*) = 6 and bool_and(prosrc !~ 'ur\.email|e\.user_email|d\.deleted_by_email|a\.granted_by_email') from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'
       and p.proname in ('list_reserved_access', 'get_deleted_documents', 'reward_operator_credit_anomalies', 'reward_unsettled_credits', 'reward_token_entries', 'reward_token_people'))
union all select 11, 'The names of those a decision is about', pg_get_functiondef('public.people_names(uuid[], text[])'::regprocedure) ~ 'people_decisions'
union all select 12, 'The label of Suspend', not exists (select 1 from public.option_lists where list_name = 'people_decision_type' and label = 'Suspend (no new tasks)')
union all select 13, 'No trigger was left off', not exists (select 1 from pg_trigger t join pg_class c on c.oid = t.tgrelid where not t.tgisinternal and t.tgenabled = 'D' and c.relname in
       ('policy_proposals', 'people_decisions', 'compensation_runs', 'compensation_lines', 'budget_ledger', 'token_events', 'token_annulments', 'reserved_access', 'policy_values', 'task_reputation_tiers', 'token_milestones', 'token_texts', 'documents'))
order by 1;
