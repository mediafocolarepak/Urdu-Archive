-- 127_tokens.sql
-- Tokens of appreciation, first part (docs/TOKEN_POLICY.md, decided by the Owner on 2026-11-07).
--   - Three values in Reward's page, changed like every policy value (proposed by one person, approved by an Admin who is
--     not the proposer): tokens per page, per minute, per unit. They start at 0, which means "not set yet".
--   - A ledger that is only added to: who received tokens, for what, how many. No write rule for anyone; only the functions
--     below write, and nothing is ever deleted. A token is annulled by a separate entry.
--   - Tokens are given by themselves when a proposal or a reading is published, one entry per published version: by its
--     pages for a text or PDF, by its minutes for audio and video. Where the size isn't recorded, one unit.
--   - Contributions published before today are counted now, marked as past.
--   - While a value is 0, its entries wait with no tokens. When Reward's value is approved, the waiting entries are valued
--     at once. A value changed later applies only from then on.
--   - Reward annuls an entry with a note, and gives a unit for each batch of Urdu title answers.
-- Not here yet: tokens for a problem report that led to a correction, milestones, the certificate, My Space, the count of
-- listens, public thanks.
-- Run it in the SQL Editor BEFORE merging: Reward's page asks for the new functions. It can be run twice.

-- ============================================================================
-- 1. Reward's values
-- ============================================================================
insert into public.policy_values (key, value, label) values
  ('token_per_page', 0, 'Tokens of appreciation for each page of a text or PDF proposal (0 = not set yet: the tokens wait)'),
  ('token_per_minute', 0, 'Tokens of appreciation for each minute of a reading, audio or video (0 = not set yet: the tokens wait)'),
  ('token_per_unit', 0, 'Tokens of appreciation for each useful problem report and each batch of Urdu title answers (0 = not set yet)')
on conflict (key) do nothing;

-- ============================================================================
-- 2. The ledger
-- ============================================================================
create table if not exists public.token_events (
  id               bigint generated always as identity primary key,
  user_id          uuid not null,
  user_email       text,
  kind             text not null check (kind in ('proposal', 'reading', 'report', 'titles')),
  submission_id    bigint,
  document_id      integer,
  unit             text not null check (unit in ('page', 'minute', 'unit')),
  units            integer not null check (units > 0),
  size_recorded    boolean not null default true,  -- false when the size was missing and one unit was counted
  tokens           integer,                         -- null while Reward's value for this unit is not set
  valued_at        timestamptz,
  past             boolean not null default false,  -- given for a contribution made before tokens existed
  note             text,
  created_by       uuid,
  created_by_email text,
  created_at       timestamptz not null default now()
);
-- A published version gives its tokens once.
create unique index if not exists token_events_one_per_document on public.token_events (document_id) where document_id is not null;
create index if not exists token_events_user on public.token_events (user_id, created_at desc);

create table if not exists public.token_annulments (
  event_id         bigint primary key references public.token_events(id),
  note             text not null check (btrim(note) <> ''),
  annulled_by      uuid,
  annulled_by_email text,
  annulled_at      timestamptz not null default now()
);

alter table public.token_events enable row level security;
alter table public.token_annulments enable row level security;

-- Each person reads their own; Reward and Admin read everything. No write rule: only the functions below write.
drop policy if exists "token_events_select" on public.token_events;
create policy "token_events_select" on public.token_events for select
  using (user_id = auth.uid() or public.is_dept_member('RF') or public.current_role_is('admin'));
drop policy if exists "token_annulments_select" on public.token_annulments;
create policy "token_annulments_select" on public.token_annulments for select
  using (public.is_dept_member('RF') or public.current_role_is('admin')
         or exists (select 1 from public.token_events e where e.id = event_id and e.user_id = auth.uid()));

-- Nothing is deleted, and an entry changes only once: from waiting to valued.
create or replace function public.token_events_guard()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then raise exception 'Tokens are never deleted: Reward annuls them with a note.'; end if;
  if old.tokens is not null
     or new.tokens is null
     or (to_jsonb(new) - 'tokens' - 'valued_at') is distinct from (to_jsonb(old) - 'tokens' - 'valued_at') then
    raise exception 'A token entry cannot be changed.';
  end if;
  return new;
end;
$$;
drop trigger if exists token_events_guard on public.token_events;
create trigger token_events_guard before update or delete on public.token_events
  for each row execute function public.token_events_guard();

create or replace function public.token_annulments_guard()
returns trigger
language plpgsql
as $$
begin
  raise exception 'An annulment cannot be changed or removed.';
end;
$$;
drop trigger if exists token_annulments_guard on public.token_annulments;
create trigger token_annulments_guard before update or delete on public.token_annulments
  for each row execute function public.token_annulments_guard();

-- ============================================================================
-- 3. Sizes and values
-- ============================================================================
-- Minutes from what the app records: "4:05" from a recording, or what a person typed for a video ("4 min", "1 h 20").
-- Rounded up; null when there is nothing to read.
create or replace function public.token_minutes(p text)
returns integer
language plpgsql
immutable
as $$
declare
  t text := lower(btrim(coalesce(p, '')));
  m text[];
  secs numeric;
begin
  if t = '' then return null; end if;
  m := regexp_match(t, '^(\d+):(\d{1,2}):(\d{1,2})$');
  if m is not null then secs := m[1]::numeric * 3600 + m[2]::numeric * 60 + m[3]::numeric; return greatest(1, ceil(secs / 60))::integer; end if;
  m := regexp_match(t, '^(\d+):(\d{1,2})$');
  if m is not null then secs := m[1]::numeric * 60 + m[2]::numeric; return greatest(1, ceil(secs / 60))::integer; end if;
  m := regexp_match(t, '(\d+(?:[.,]\d+)?)\s*(?:h|hr|hrs|hour|hours|ora|ore)\M\s*(\d+)?');
  if m is not null then
    return greatest(1, ceil(replace(m[1], ',', '.')::numeric * 60 + coalesce(m[2], '0')::numeric))::integer;
  end if;
  m := regexp_match(t, '(\d+(?:[.,]\d+)?)');
  if m is not null and replace(m[1], ',', '.')::numeric > 0 then return greatest(1, ceil(replace(m[1], ',', '.')::numeric))::integer; end if;
  return null;
end;
$$;

create or replace function public.token_rate(p_unit text)
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select nullif(value, 0) from public.policy_values
  where key = case p_unit when 'page' then 'token_per_page' when 'minute' then 'token_per_minute' else 'token_per_unit' end;
$$;

-- Values every waiting entry whose unit now has a value. Called when Reward's value changes.
create or replace function public.token_value_waiting()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
begin
  update public.token_events e
  set tokens = e.units * public.token_rate(e.unit), valued_at = now()
  where e.tokens is null and public.token_rate(e.unit) is not null;
  get diagnostics n = row_count;
  return n;
end;
$$;

create or replace function public.after_token_value()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.key like 'token\_per\_%' and new.value is distinct from old.value then perform public.token_value_waiting(); end if;
  return new;
end;
$$;
drop trigger if exists policy_values_token_value on public.policy_values;
create trigger policy_values_token_value after update on public.policy_values
  for each row execute function public.after_token_value();

-- ============================================================================
-- 4. Tokens given by themselves
-- ============================================================================
-- One entry per published version of a proposal or a reading, to whoever proposed or read it.
create or replace function public.token_give_for_submission(p_id bigint, p_past boolean default false)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  s public.archive_submissions%rowtype;
  d record;
  v_unit text;
  v_size integer;
  v_rate integer;
  n integer := 0;
begin
  select * into s from public.archive_submissions where id = p_id;
  if s.id is null or s.status <> 'published' or s.proposer_id is null then return 0; end if;
  for d in
    select x.document_id, coalesce(x.media_type, 'DOC') as media_type, x.pages, x.duration
    from public.documents x
    where x.source_submission_id = p_id and x.deleted_at is null and x.workflow_status = 'published'
  loop
    v_unit := case when d.media_type = 'DOC' then 'page' else 'minute' end;
    v_size := case when v_unit = 'page' then nullif(d.pages, 0) else public.token_minutes(d.duration) end;
    v_rate := public.token_rate(v_unit);
    insert into public.token_events (user_id, user_email, kind, submission_id, document_id, unit, units, size_recorded,
                                     tokens, valued_at, past)
    values (s.proposer_id, s.proposer_email, case when s.kind = 'reading' then 'reading' else 'proposal' end, p_id, d.document_id,
            v_unit, coalesce(v_size, 1), v_size is not null,
            coalesce(v_size, 1) * v_rate, case when v_rate is not null then now() end, p_past)
    on conflict (document_id) where document_id is not null do nothing;
    if found then n := n + 1; end if;
  end loop;
  return n;
end;
$$;

create or replace function public.after_submission_tokens()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'published' and old.status is distinct from 'published' then
    perform public.token_give_for_submission(new.id);
  end if;
  return new;
end;
$$;
drop trigger if exists archive_submissions_tokens on public.archive_submissions;
create trigger archive_submissions_tokens after update on public.archive_submissions
  for each row execute function public.after_submission_tokens();

-- ============================================================================
-- 5. What Reward does
-- ============================================================================
create or replace function public.can_manage_tokens()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_dept_member('RF') or public.current_role_is('admin');
$$;

create or replace function public.token_annul(p_event_id bigint, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  e public.token_events%rowtype;
  v_email text;
begin
  if not public.can_manage_tokens() then raise exception 'Only Reward annuls tokens.'; end if;
  if nullif(btrim(p_note), '') is null then raise exception 'Please say why.'; end if;
  select * into e from public.token_events where id = p_event_id;
  if e.id is null then raise exception 'Token entry not found.'; end if;
  if e.user_id = auth.uid() then raise exception 'Someone else in Reward annuls your own tokens.'; end if;
  if exists (select 1 from public.token_annulments where event_id = p_event_id) then raise exception 'Already annulled.'; end if;
  select email into v_email from public.user_roles where user_id = auth.uid();
  insert into public.token_annulments (event_id, note, annulled_by, annulled_by_email) values (p_event_id, btrim(p_note), auth.uid(), v_email);
end;
$$;

-- One unit for a batch of Urdu title answers received (docs/TOKEN_POLICY.md §2).
create or replace function public.token_give_for_titles(p_email text, p_note text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid;
  v_email text;
  v_me text;
  v_rate integer := public.token_rate('unit');
  v_id bigint;
begin
  if not public.can_manage_tokens() then raise exception 'Only Reward gives these tokens.'; end if;
  if nullif(btrim(p_note), '') is null then raise exception 'Please say which batch of answers.'; end if;
  select user_id, email into v_user, v_email from public.user_roles where lower(email) = lower(btrim(p_email));
  if v_user is null then raise exception 'Nobody with that email has signed up.'; end if;
  if v_user = auth.uid() then raise exception 'Someone else in Reward gives tokens for your own answers.'; end if;
  select email into v_me from public.user_roles where user_id = auth.uid();
  insert into public.token_events (user_id, user_email, kind, unit, units, tokens, valued_at, note, created_by, created_by_email)
  values (v_user, v_email, 'titles', 'unit', 1, v_rate, case when v_rate is not null then now() end, btrim(p_note), auth.uid(), v_me)
  returning id into v_id;
  return v_id;
end;
$$;

-- Reward's page: one row per person.
create or replace function public.reward_token_people()
returns table (user_id uuid, email text, full_name text, tokens bigint, entries bigint, waiting bigint, annulled bigint, last_at timestamptz)
language sql
stable
security definer
set search_path = public
as $$
  select e.user_id, max(e.user_email), max(p.full_name),
         coalesce(sum(e.tokens) filter (where a.event_id is null), 0),
         count(*) filter (where a.event_id is null),
         count(*) filter (where a.event_id is null and e.tokens is null),
         count(a.event_id),
         max(e.created_at)
  from public.token_events e
  left join public.token_annulments a on a.event_id = e.id
  left join public.user_profiles p on p.user_id = e.user_id
  where public.can_manage_tokens()
  group by e.user_id
  order by max(e.created_at) desc;
$$;

-- Reward's page: the latest entries, with what they were given for. A reserved text shows only its number.
create or replace function public.reward_token_entries(p_limit integer default 100)
returns table (id bigint, user_email text, kind text, document_id integer, title text, unit text, units integer, size_recorded boolean,
               tokens integer, past boolean, note text, created_at timestamptz, annulled boolean, annul_note text)
language sql
stable
security definer
set search_path = public
as $$
  select e.id, e.user_email, e.kind, e.document_id,
         case when e.document_id is null then null
              when public.document_reserved_ok(e.document_id) then coalesce(d.en_title, d.title, d.original_title)
              else '(reserved)' end,
         e.unit, e.units, e.size_recorded, e.tokens, e.past, e.note, e.created_at,
         a.event_id is not null, a.note
  from public.token_events e
  left join public.token_annulments a on a.event_id = e.id
  left join public.documents d on d.document_id = e.document_id
  where public.can_manage_tokens()
  order by e.created_at desc, e.id desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

grant execute on function public.token_annul(bigint, text) to authenticated;
grant execute on function public.token_give_for_titles(text, text) to authenticated;
grant execute on function public.reward_token_people() to authenticated;
grant execute on function public.reward_token_entries(integer) to authenticated;
grant execute on function public.can_manage_tokens() to authenticated;
revoke execute on function public.token_give_for_submission(bigint, boolean) from public, anon, authenticated;
revoke execute on function public.token_value_waiting() from public, anon, authenticated;

-- ============================================================================
-- 6. Contributions made before tokens existed (docs/TOKEN_POLICY.md §8)
-- ============================================================================
select public.token_give_for_submission(s.id, true)
from public.archive_submissions s
where s.status = 'published'
order by s.id;

notify pgrst, 'reload schema';

-- ============================================================================
-- Verification (the SQL Editor shows only the last result). All rows must say true; the counts are for the Owner.
-- ============================================================================
select 'three values in Reward''s page' as item,
       (select count(*) = 3 from public.policy_values where key in ('token_per_page', 'token_per_minute', 'token_per_unit'))::text as result
union all select 'ledger and guards in place',
       (exists (select 1 from pg_trigger where tgname = 'token_events_guard')
        and exists (select 1 from pg_trigger where tgname = 'archive_submissions_tokens')
        and exists (select 1 from pg_trigger where tgname = 'policy_values_token_value'))::text
union all select 'nobody can write the ledger directly',
       (not exists (select 1 from pg_policies where tablename in ('token_events', 'token_annulments') and cmd <> 'SELECT'))::text
union all select 'every published version counted once',
       (select count(*) = 0 from public.documents d join public.archive_submissions s on s.id = d.source_submission_id
         where s.status = 'published' and s.proposer_id is not null and d.workflow_status = 'published' and d.deleted_at is null
           and not exists (select 1 from public.token_events e where e.document_id = d.document_id))::text
union all select 'past contributions counted (entries)', (select count(*) from public.token_events where past)::text
union all select 'people who gave', (select count(distinct user_id) from public.token_events)::text
union all select 'entries without a recorded size (one unit each)', (select count(*) from public.token_events where not size_recorded)::text
union all select 'entries waiting for Reward''s values', (select count(*) from public.token_events where tokens is null)::text;
