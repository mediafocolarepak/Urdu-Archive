-- 128_token_milestones.sql
-- Tokens of appreciation, second part (docs/TOKEN_POLICY.md §5-§7, decided by the Owner on 2026-11-07).
--   - Milestones and three texts in Reward's page: the certificate's sentence, who signs it (a Focolare responsible), and
--     the word of encouragement for those under 18. Changed like every policy value: proposed by Reward, approved by an
--     Admin who is not the proposer. The policy proposals learn these two tables.
--   - A certificate of appreciation is issued by itself when a person's tokens reach a milestone, with a code anyone signed
--     in can verify. It keeps the sentence and the signer it was issued with. It waits until Reward has written both.
--   - "My tokens" for each person: their total, what they gave, how many times their readings were listened to (already
--     counted, anonymously, since migration 114), their certificates, and for those under 18 the word of encouragement.
-- Run it in the SQL Editor BEFORE merging: My Space and Reward's page ask for the new functions. It can be run twice.

-- ============================================================================
-- 1. Milestones and texts
-- ============================================================================
create table if not exists public.token_milestones (
  tokens           integer primary key check (tokens > 0),
  label            text,
  updated_at       timestamptz not null default now(),
  updated_by_email text
);
create table if not exists public.token_texts (
  key              text primary key check (key in ('certificate_sentence', 'certificate_signer', 'under18_encouragement')),
  label            text not null,
  text             text not null default '',
  updated_at       timestamptz not null default now(),
  updated_by_email text
);
insert into public.token_texts (key, label) values
  ('certificate_sentence', 'The sentence on the certificate of appreciation, in English'),
  ('certificate_signer', 'Who signs the certificate: a Focolare responsible (name and role)'),
  ('under18_encouragement', 'The word of encouragement shown in My Space to those under 18, who are never thanked in public')
on conflict (key) do nothing;

alter table public.token_milestones enable row level security;
alter table public.token_texts enable row level security;
drop policy if exists "token_milestones_select" on public.token_milestones;
create policy "token_milestones_select" on public.token_milestones for select using (public.current_role_is('user'));
drop policy if exists "token_texts_select" on public.token_texts;
create policy "token_texts_select" on public.token_texts for select using (public.current_role_is('user'));
-- No write rule: only apply_policy_change() writes them.

-- ============================================================================
-- 2. Certificates
-- ============================================================================
create table if not exists public.token_certificates (
  id               bigint generated always as identity primary key,
  user_id          uuid not null,
  milestone        integer not null,
  tokens_at_issue  integer not null,
  sentence         text not null,
  signer           text not null,
  certificate_code text not null unique default substr(md5(random()::text || clock_timestamp()::text), 1, 10),
  issued_at        timestamptz not null default now(),
  unique (user_id, milestone)
);
alter table public.token_certificates enable row level security;
drop policy if exists "token_certificates_select" on public.token_certificates;
create policy "token_certificates_select" on public.token_certificates for select
  using (user_id = auth.uid() or public.is_dept_member('RF') or public.current_role_is('admin'));

create or replace function public.token_certificates_guard()
returns trigger
language plpgsql
as $$
begin
  raise exception 'A certificate cannot be changed or removed.';
end;
$$;
drop trigger if exists token_certificates_guard on public.token_certificates;
create trigger token_certificates_guard before update or delete on public.token_certificates
  for each row execute function public.token_certificates_guard();

-- A person's tokens: valued and not annulled.
create or replace function public.token_total(p_user uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(sum(e.tokens), 0)::integer
  from public.token_events e
  where e.user_id = p_user and e.tokens is not null
    and not exists (select 1 from public.token_annulments a where a.event_id = e.id);
$$;

-- Issues the certificates a person has reached and doesn't have yet. Waits while the sentence or the signer is empty.
create or replace function public.token_issue_certificates(p_user uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sentence text;
  v_signer text;
  v_total integer;
  n integer := 0;
begin
  select nullif(btrim(text), '') into v_sentence from public.token_texts where key = 'certificate_sentence';
  select nullif(btrim(text), '') into v_signer from public.token_texts where key = 'certificate_signer';
  if v_sentence is null or v_signer is null or p_user is null then return 0; end if;
  v_total := public.token_total(p_user);
  insert into public.token_certificates (user_id, milestone, tokens_at_issue, sentence, signer)
  select p_user, m.tokens, v_total, v_sentence, v_signer
  from public.token_milestones m
  where m.tokens <= v_total
  on conflict (user_id, milestone) do nothing;
  get diagnostics n = row_count;
  return n;
end;
$$;

create or replace function public.token_issue_all_certificates()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  u uuid;
  n integer := 0;
begin
  for u in select distinct user_id from public.token_events loop
    n := n + public.token_issue_certificates(u);
  end loop;
  return n;
end;
$$;

create or replace function public.after_token_event()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.tokens is not null then perform public.token_issue_certificates(new.user_id); end if;
  return new;
end;
$$;
drop trigger if exists token_events_certificates on public.token_events;
create trigger token_events_certificates after insert or update on public.token_events
  for each row execute function public.after_token_event();

revoke execute on function public.token_issue_certificates(uuid) from public, anon, authenticated;
revoke execute on function public.token_issue_all_certificates() from public, anon, authenticated;
revoke execute on function public.token_total(uuid) from public, anon, authenticated;

-- ============================================================================
-- 3. Policy proposals learn the two new tables (same as 86, with the two branches added)
-- ============================================================================
alter table public.policy_proposals drop constraint if exists policy_proposals_target;
alter table public.policy_proposals add constraint policy_proposals_target check (target_table in (
  'task_category_rates', 'task_reputation_tiers', 'policy_values', 'token_milestones', 'token_texts'));

create or replace function public.apply_policy_change(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  p public.policy_proposals%rowtype;
  v_new_category text;
  v_new_tier text;
  v_new_milestone integer;
begin
  select * into p from public.policy_proposals where id = p_id;
  if p is null then raise exception 'Proposal not found.'; end if;

  if p.target_table = 'task_category_rates' then
    if p.action = 'delete' then
      delete from public.task_category_rates where category = p.target_key;
    else
      v_new_category := coalesce(p.field_changes->>'category', p.target_key);
      if v_new_category <> p.target_key then
        delete from public.task_category_rates where category = p.target_key;
      end if;
      insert into public.task_category_rates (category, credits_per_page, updated_at, updated_by_email)
      values (v_new_category, (p.field_changes->>'credits_per_page')::numeric, now(), p.decided_by_email)
      on conflict (category) do update set
        credits_per_page = excluded.credits_per_page,
        updated_at = excluded.updated_at,
        updated_by_email = excluded.updated_by_email;
    end if;

  elsif p.target_table = 'task_reputation_tiers' then
    if p.action = 'delete' then
      delete from public.task_reputation_tiers where tier_name = p.target_key;
    else
      v_new_tier := coalesce(p.field_changes->>'tier_name', p.target_key);
      if v_new_tier <> p.target_key then
        delete from public.task_reputation_tiers where tier_name = p.target_key;
      end if;
      insert into public.task_reputation_tiers (
        tier_name, min_base_credits, max_base_credits, ok_delta, ok_but_delta, fail_delta,
        sort_order, updated_at, updated_by_email)
      values (
        v_new_tier,
        (p.field_changes->>'min_base_credits')::integer,
        nullif(p.field_changes->>'max_base_credits', '')::integer,
        (p.field_changes->>'ok_delta')::integer,
        (p.field_changes->>'ok_but_delta')::integer,
        (p.field_changes->>'fail_delta')::integer,
        coalesce((p.field_changes->>'sort_order')::integer, 0),
        now(), p.decided_by_email)
      on conflict (tier_name) do update set
        min_base_credits = excluded.min_base_credits,
        max_base_credits = excluded.max_base_credits,
        ok_delta = excluded.ok_delta,
        ok_but_delta = excluded.ok_but_delta,
        fail_delta = excluded.fail_delta,
        sort_order = excluded.sort_order,
        updated_at = excluded.updated_at,
        updated_by_email = excluded.updated_by_email;
    end if;

  elsif p.target_table = 'policy_values' then
    if p.action = 'delete' then
      raise exception 'policy_values entries cannot be deleted, only changed.';
    end if;
    update public.policy_values
    set value = (p.field_changes->>'value')::integer,
        updated_at = now(), updated_by_email = p.decided_by_email
    where key = p.target_key;
    if not found then raise exception 'Unknown policy_values key: %', p.target_key; end if;

  elsif p.target_table = 'token_milestones' then
    -- target_key is the milestone's number of tokens; a changed number moves the milestone.
    if p.action = 'delete' then
      delete from public.token_milestones where tokens = p.target_key::integer;
    else
      v_new_milestone := coalesce((p.field_changes->>'tokens')::integer, p.target_key::integer);
      if v_new_milestone is null or v_new_milestone <= 0 then raise exception 'A milestone needs a number of tokens above 0.'; end if;
      if v_new_milestone <> p.target_key::integer then
        delete from public.token_milestones where tokens = p.target_key::integer;
      end if;
      insert into public.token_milestones (tokens, label, updated_at, updated_by_email)
      values (v_new_milestone, nullif(btrim(p.field_changes->>'label'), ''), now(), p.decided_by_email)
      on conflict (tokens) do update set label = excluded.label, updated_at = excluded.updated_at, updated_by_email = excluded.updated_by_email;
    end if;
    perform public.token_issue_all_certificates();

  elsif p.target_table = 'token_texts' then
    if p.action = 'delete' then raise exception 'These texts cannot be deleted, only changed.'; end if;
    update public.token_texts
    set text = coalesce(btrim(p.field_changes->>'text'), ''), updated_at = now(), updated_by_email = p.decided_by_email
    where key = p.target_key;
    if not found then raise exception 'Unknown text: %', p.target_key; end if;
    perform public.token_issue_all_certificates();
  end if;
end;
$$;

create or replace function public.propose_policy_change(
  p_department text, p_target_table text, p_target_key text, p_action text,
  p_field_changes jsonb, p_reason text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id    bigint;
  v_email text;
begin
  if p_target_table not in ('task_category_rates', 'task_reputation_tiers', 'policy_values', 'token_milestones', 'token_texts') then
    raise exception 'Invalid target table.';
  end if;
  if p_action not in ('upsert', 'delete') then
    raise exception 'Invalid action.';
  end if;
  if p_target_table = 'token_milestones' and coalesce(p_target_key, '') !~ '^[1-9][0-9]*$' then
    raise exception 'A milestone is a number of tokens above 0.';
  end if;
  if not public.can_propose_policy_change(p_department) then
    raise exception 'You are not allowed to propose a policy change for department "%".', p_department;
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'A reason is required.';
  end if;
  if p_action = 'upsert' and (p_field_changes is null or p_field_changes = '{}'::jsonb) then
    raise exception 'field_changes is required for an upsert.';
  end if;
  if exists (select 1 from public.policy_proposals
              where target_table = p_target_table and target_key = p_target_key and status = 'pending') then
    raise exception 'There is already a pending proposal for this policy row.';
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  insert into public.policy_proposals (
    department_code, target_table, target_key, action, field_changes, reason,
    proposed_by, proposed_by_email)
  values (
    p_department, p_target_table, p_target_key, p_action, coalesce(p_field_changes, '{}'::jsonb),
    p_reason, auth.uid(), v_email)
  returning id into v_id;

  return v_id;
end;
$$;

-- ============================================================================
-- 4. What each person sees (My Space) and the verification of a certificate
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
  select b.date_of_birth > (current_date - interval '18 years') into v_minor from public.user_birth_dates b where b.user_id = v_me;
  return jsonb_build_object(
    'total', v_total,
    'waiting', (select count(*) from public.token_events e where e.user_id = v_me and e.tokens is null
                  and not exists (select 1 from public.token_annulments a where a.event_id = e.id)),
    'next_milestone', (select min(m.tokens) from public.token_milestones m where m.tokens > v_total),
    'name', (select nullif(btrim(full_name), '') from public.user_profiles where user_id = v_me),
    'minor', coalesce(v_minor, false),
    'encouragement', case when coalesce(v_minor, false)
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
        'listens', case when d.media_type = 'AUD' then (select coalesce(sum(c.plays), 0) from public.audio_play_counts c where c.document_id = e.document_id) end
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

-- Anyone signed in can check a certificate's code: whose it is, which milestone, when.
create or replace function public.verify_token_certificate(p_code text)
returns table (full_name text, milestone integer, issued_at timestamptz, signer text)
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(nullif(btrim(p.full_name), ''), 'A member of the archive'), c.milestone, c.issued_at, c.signer
  from public.token_certificates c
  left join public.user_profiles p on p.user_id = c.user_id
  where public.current_role_is('user') and c.certificate_code = lower(btrim(p_code));
$$;

grant execute on function public.my_tokens() to authenticated;
grant execute on function public.verify_token_certificate(text) to authenticated;

notify pgrst, 'reload schema';

-- ============================================================================
-- Verification (the SQL Editor shows only the last result). Every row must say true.
-- ============================================================================
select 'three texts ready for Reward to write' as item,
       (select count(*) = 3 from public.token_texts) as ok
union all select 'policy proposals accept milestones and texts',
       (select pg_get_constraintdef(oid) like '%token_milestones%' and pg_get_constraintdef(oid) like '%token_texts%'
          from pg_constraint where conname = 'policy_proposals_target')
union all select 'certificates issued by themselves, never changed',
       exists (select 1 from pg_trigger where tgname = 'token_events_certificates')
       and exists (select 1 from pg_trigger where tgname = 'token_certificates_guard')
union all select 'nobody writes milestones, texts or certificates directly',
       not exists (select 1 from pg_policies where tablename in ('token_milestones', 'token_texts', 'token_certificates') and cmd <> 'SELECT');
