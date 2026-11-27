-- 184: phase 5 (Owner's decisions, 2026-11-27).
--   1. The first steps of an Operator are shown once for each account: the profile remembers when they were seen.
--   2. Names instead of logins where a person has no name: a document's history (Coordinators and Admins), who reads aloud
--      (HR and Coordination), and who proposed and acted on a proposal (Admins).
-- Run AFTER the code of the same pull request is live (it works with and without this file). Safe to run again.

alter table public.user_profiles add column if not exists operator_intro_seen_at timestamptz;

-- Has this account seen the first steps? With p_mark, they are now seen. Only the account's own row.
create or replace function public.operator_intro(p_mark boolean default false)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then return true; end if;
  if p_mark then
    update public.user_profiles set operator_intro_seen_at = coalesce(operator_intro_seen_at, now()) where user_id = auth.uid();
  end if;
  return coalesce((select operator_intro_seen_at is not null from public.user_profiles where user_id = auth.uid()), false);
end;
$$;
revoke execute on function public.operator_intro(boolean) from public, anon;
grant execute on function public.operator_intro(boolean) to authenticated;

-- The profile's own column is not written by hand: only by the function above.
do $m$
declare
  f record;
  v_def text;
  v_new text;
  v_name constant text := '(select coalesce(nullif(btrim(pp.full_name), ''''), ''(no name)'') from public.user_roles rr left join public.user_profiles pp on pp.user_id = rr.user_id where lower(rr.email) = lower(e.actor_email))';
begin
  for f in select p.oid, p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
            where n.nspname = 'public' and p.proname in ('get_document_history', 'get_reader_stats', 'get_submission_detail', 'get_reading_detail')
  loop
    v_def := replace(pg_get_functiondef(f.oid), chr(13), '');
    v_new := v_def;
    if f.proname = 'get_document_history' then
      v_new := replace(v_new, 'coalesce(nullif(p.full_name, ''''), l.actor_email, ''(system)'')',
        'coalesce(nullif(btrim(p.full_name), ''''), case when l.actor_id is null then ''(system)'' else ''(no name)'' end)');
    elsif f.proname = 'get_reader_stats' then
      v_new := replace(v_new, 'max(coalesce(nullif(p.full_name, ''''), s.proposer_email))::text', 'max(coalesce(nullif(btrim(p.full_name), ''''), ''(no name)''))::text');
    else
      v_new := replace(v_new, '''proposer_email'', case when v_admin then s.proposer_email end',
        '''proposer_email'', case when v_admin then (select coalesce(nullif(btrim(pp.full_name), ''''), ''(no name)'') from public.user_profiles pp where pp.user_id = s.proposer_id) end');
      v_new := replace(v_new, '''actor'', case when v_admin then e.actor_email end', '''actor'', case when v_admin and e.actor_email is not null then ' || v_name || ' end');
    end if;
    if v_new ~ 'actor_email, ''\(system\)''|s\.proposer_email\)\)|then s\.proposer_email end|then e\.actor_email end' then
      raise exception '184: % is not as expected.', f.proname;
    end if;
    if v_new is distinct from v_def then execute v_new; end if;
  end loop;
end $m$;

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'The profile remembers the first steps' as item,
       exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'user_profiles' and column_name = 'operator_intro_seen_at') as ok
union all select 2, 'Only for the account itself, and only when signed in',
       has_function_privilege('authenticated', 'public.operator_intro(boolean)', 'execute') and not has_function_privilege('anon', 'public.operator_intro(boolean)', 'execute')
union all select 3, 'A document''s history shows names', (select prosrc !~ 'l\.actor_email' from pg_proc where oid = 'public.get_document_history(integer)'::regprocedure)
union all select 4, 'Who reads aloud shows names', (select bool_and(prosrc !~ 's\.proposer_email\)') from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'get_reader_stats')
union all select 5, 'A proposal shows names to the Admins', (select bool_and(prosrc !~ 'then s\.proposer_email end' and prosrc !~ 'then e\.actor_email end') from pg_proc p join pg_namespace n on n.oid = p.pronamespace
       where n.nspname = 'public' and p.proname in ('get_submission_detail', 'get_reading_detail'))
order by 1;
