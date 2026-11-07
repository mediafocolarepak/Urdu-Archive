-- 129_token_reports_thanks.sql
-- Tokens of appreciation, third part (docs/TOKEN_POLICY.md §2, §5, §7).
--   - A useful problem report: whoever handles reports (Coordinator, Admin) marks "this report led to a correction" in
--     Messages, and the person who reported receives one unit, once per report, never for their own.
--   - Openings of a text are counted anonymously, by day, like the listens of a recording (migration 114): only the document
--     and the day, never who opened it. My Space shows them beside the person's own texts.
--   - Public thanks: a consent each adult gives or withdraws in My Space (never asked of those under 18). Reward's page lists,
--     for a month, those who consented and what they gave, ready for Communication to publish in the app and in Hayat.
-- Run it in the SQL Editor BEFORE merging: Messages, My Space and Reward's page ask for the new functions. It can be run twice.

-- ============================================================================
-- 1. Useful reports
-- ============================================================================
alter table public.token_events add column if not exists chat_message_id bigint;
create unique index if not exists token_events_one_per_report on public.token_events (chat_message_id) where chat_message_id is not null;

create or replace function public.token_give_for_report(p_message_id bigint)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  m public.chat_messages%rowtype;
  v_me text;
  v_rate integer := public.token_rate('unit');
  v_id bigint;
begin
  if not public.current_role_is('coordinator') then raise exception 'Only those who handle reports can mark one.'; end if;
  select * into m from public.chat_messages where id = p_message_id;
  if m.id is null then raise exception 'Report not found.'; end if;
  if m.user_id = auth.uid() then raise exception 'Someone else marks your own report.'; end if;
  if exists (select 1 from public.token_events where chat_message_id = p_message_id) then
    raise exception 'This report has already been marked.';
  end if;
  select email into v_me from public.user_roles where user_id = auth.uid();
  insert into public.token_events (user_id, user_email, kind, unit, units, tokens, valued_at, note, chat_message_id, created_by, created_by_email)
  values (m.user_id, m.user_email, 'report', 'unit', 1, v_rate, case when v_rate is not null then now() end,
          'Report #' || m.id || case when m.document_id is not null then ' about document #' || m.document_id else '' end,
          m.id, auth.uid(), v_me)
  returning id into v_id;
  return v_id;
end;
$$;

-- Which reports have been marked, for the Messages page.
create or replace function public.token_marked_reports()
returns table (chat_message_id bigint)
language sql
stable
security definer
set search_path = public
as $$
  select e.chat_message_id from public.token_events e
  where e.chat_message_id is not null and public.current_role_is('coordinator');
$$;

-- ============================================================================
-- 2. Openings of a text, counted anonymously
-- ============================================================================
create table if not exists public.document_open_counts (
  document_id integer not null references public.documents(document_id) on delete cascade,
  day         date not null default current_date,
  opens       integer not null default 0,
  primary key (document_id, day)
);
alter table public.document_open_counts enable row level security;
-- No rule at all: only the functions below reach it.

create or replace function public.count_document_open(p_document_id integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.current_role_is('user') or not public.document_reserved_ok(p_document_id) or not exists (
    select 1 from public.documents d where d.document_id = p_document_id
      and coalesce(d.media_type, 'DOC') = 'DOC' and d.deleted_at is null and public.document_status_is_visible(d.workflow_status)
  ) then
    return;
  end if;
  insert into public.document_open_counts (document_id, opens) values (p_document_id, 1)
  on conflict (document_id, day) do update set opens = public.document_open_counts.opens + 1;
end;
$$;

-- ============================================================================
-- 3. Consent to public thanks
-- ============================================================================
create table if not exists public.token_thanks_consents (
  user_id   uuid primary key,
  given_at  timestamptz not null default now()
);
alter table public.token_thanks_consents enable row level security;
drop policy if exists "token_thanks_consents_select" on public.token_thanks_consents;
create policy "token_thanks_consents_select" on public.token_thanks_consents for select
  using (user_id = auth.uid() or public.is_dept_member('RF') or public.current_role_is('admin'));
-- No write rule: set_token_thanks_consent() writes it.

create or replace function public.token_is_minor(p_user uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select b.date_of_birth > (current_date - interval '18 years') from public.user_birth_dates b where b.user_id = p_user), false);
$$;

create or replace function public.set_token_thanks_consent(p_consent boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'Please sign in.'; end if;
  if p_consent then
    if public.token_is_minor(auth.uid()) then raise exception 'Those under 18 are thanked privately, never in public.'; end if;
    insert into public.token_thanks_consents (user_id) values (auth.uid()) on conflict (user_id) do nothing;
  else
    delete from public.token_thanks_consents where user_id = auth.uid();
  end if;
end;
$$;

-- Reward's list for a month: adults who consented and have a name, with what they gave that month (not annulled, not past).
create or replace function public.reward_public_thanks(p_month date)
returns table (full_name text, proposals bigint, readings bigint, reports bigint, titles bigint, tokens bigint)
language sql
stable
security definer
set search_path = public
as $$
  select btrim(p.full_name),
         count(*) filter (where e.kind = 'proposal'),
         count(*) filter (where e.kind = 'reading'),
         count(*) filter (where e.kind = 'report'),
         count(*) filter (where e.kind = 'titles'),
         coalesce(sum(e.tokens), 0)
  from public.token_events e
  join public.token_thanks_consents c on c.user_id = e.user_id
  join public.user_profiles p on p.user_id = e.user_id and nullif(btrim(p.full_name), '') is not null
  where public.can_manage_tokens()
    and not e.past
    and e.created_at >= date_trunc('month', p_month) and e.created_at < date_trunc('month', p_month) + interval '1 month'
    and not exists (select 1 from public.token_annulments a where a.event_id = e.id)
    and not public.token_is_minor(e.user_id)
  group by e.user_id, p.full_name
  order by btrim(p.full_name);
$$;

-- ============================================================================
-- 4. My Space: same as 128, with the openings of each text, the reports, and the consent
-- ============================================================================
create or replace function public.my_tokens()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_me uuid := auth.uid();
  v_total integer;
  v_minor boolean;
begin
  if v_me is null then return null; end if;
  v_total := public.token_total(v_me);
  v_minor := public.token_is_minor(v_me);
  return jsonb_build_object(
    'total', v_total,
    'waiting', (select count(*) from public.token_events e where e.user_id = v_me and e.tokens is null
                  and not exists (select 1 from public.token_annulments a where a.event_id = e.id)),
    'next_milestone', (select min(m.tokens) from public.token_milestones m where m.tokens > v_total),
    'name', (select nullif(btrim(full_name), '') from public.user_profiles where user_id = v_me),
    'minor', v_minor,
    'consent', exists (select 1 from public.token_thanks_consents c where c.user_id = v_me),
    'encouragement', case when v_minor
                       then (select nullif(btrim(text), '') from public.token_texts where key = 'under18_encouragement') end,
    'entries', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', e.id, 'kind', e.kind, 'document_id', e.document_id,
        'title', case when e.document_id is null then null
                      when public.document_reserved_ok(e.document_id) then coalesce(d.en_title, d.title, d.original_title)
                      else '(reserved)' end,
        'unit', e.unit, 'units', e.units, 'size_recorded', e.size_recorded, 'tokens', e.tokens, 'past', e.past,
        'note', e.note, 'created_at', e.created_at,
        'annulled', a.event_id is not null, 'annul_note', a.note,
        'listens', case when d.media_type = 'AUD' then (select coalesce(sum(c.plays), 0) from public.audio_play_counts c where c.document_id = e.document_id) end,
        'opens', case when e.document_id is not null and coalesce(d.media_type, 'DOC') = 'DOC'
                      then (select coalesce(sum(o.opens), 0) from public.document_open_counts o where o.document_id = e.document_id) end
      ) order by e.created_at desc, e.id desc)
      from public.token_events e
      left join public.token_annulments a on a.event_id = e.id
      left join public.documents d on d.document_id = e.document_id
      where e.user_id = v_me), '[]'::jsonb),
    'certificates', coalesce((
      select jsonb_agg(jsonb_build_object('milestone', c.milestone, 'tokens_at_issue', c.tokens_at_issue, 'sentence', c.sentence,
                                          'signer', c.signer, 'code', c.certificate_code, 'issued_at', c.issued_at) order by c.milestone)
      from public.token_certificates c where c.user_id = v_me), '[]'::jsonb)
  );
end;
$$;

grant execute on function public.token_give_for_report(bigint) to authenticated;
grant execute on function public.token_marked_reports() to authenticated;
grant execute on function public.count_document_open(integer) to authenticated;
grant execute on function public.set_token_thanks_consent(boolean) to authenticated;
grant execute on function public.reward_public_thanks(date) to authenticated;
grant execute on function public.my_tokens() to authenticated;

notify pgrst, 'reload schema';

-- ============================================================================
-- Verification (the SQL Editor shows only the last result). Every row must say true.
-- ============================================================================
select 'a report gives its unit once' as item,
       exists (select 1 from pg_indexes where indexname = 'token_events_one_per_report') as ok
union all select 'openings counted with no person in them',
       not exists (select 1 from information_schema.columns where table_name = 'document_open_counts' and column_name like '%user%')
union all select 'nobody reads or writes the openings directly',
       not exists (select 1 from pg_policies where tablename = 'document_open_counts')
union all select 'consent written only through its function',
       not exists (select 1 from pg_policies where tablename = 'token_thanks_consents' and cmd <> 'SELECT')
union all select 'the new functions are there',
       (select count(*) = 5 from pg_proc where proname in ('token_give_for_report', 'token_marked_reports', 'count_document_open',
                                                          'set_token_thanks_consent', 'reward_public_thanks'));
