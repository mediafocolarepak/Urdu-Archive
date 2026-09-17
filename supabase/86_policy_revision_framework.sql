-- 86_policy_revision_framework.sql
-- GOVERNANCE.md §2.8 / §6.6: policy tables (task_category_rates, task_reputation_tiers,
-- policy_values) stop being directly editable by Admin. A change is a team decision an Admin
-- only APPLIES - never a single Admin's unilateral edit. Same shape as people_decisions
-- (80_departments_and_people_decisions.sql §6): an append-only proposal log, written only
-- through two security-definer entry points, nothing deleted, ever.
--
--   target_table          proposed by (owning dept lead, §2.8)     approved by
--   --------------------  ---------------------------------------  --------------------------
--   task_category_rates   Reward                                   Admin (not the proposer)
--   task_reputation_tiers Reward                                   Admin (not the proposer)
--   policy_values         owning department per §2.8 (see key ->   Admin (not the proposer)
--                         department mapping the UI shows; the
--                         DB only checks "is a lead of p_department")
--
-- Renames (a tier_name or category code changing) are expressed as an upsert whose
-- field_changes carries the NEW identity value; apply_policy_change() deletes the row at
-- target_key first when that happens, same behavior the old direct-edit UI had.

create table if not exists public.policy_proposals (
  id                bigint generated always as identity primary key,
  department_code   text        not null,
  target_table      text        not null,
  target_key        text        not null,   -- category / tier_name / policy_values.key (current identity)
  action            text        not null default 'upsert' check (action in ('upsert', 'delete')),
  field_changes     jsonb       not null,    -- column:value pairs to write (ignored when action = 'delete')
  reason            text        not null,
  proposed_by       uuid        not null,
  proposed_by_email text,
  proposed_at       timestamptz not null default now(),
  status            text        not null default 'pending'
                    check (status in ('pending', 'approved', 'rejected', 'withdrawn')),
  decided_by        uuid,
  decided_by_email  text,
  decided_at        timestamptz,
  decision_note     text,
  constraint policy_proposals_reason_not_blank check (btrim(reason) <> ''),
  constraint policy_proposals_target check (target_table in (
    'task_category_rates', 'task_reputation_tiers', 'policy_values'))
);
create index if not exists idx_policy_proposals_dept on public.policy_proposals (department_code, proposed_at desc);
create index if not exists idx_policy_proposals_pending on public.policy_proposals (status) where status = 'pending';

alter table public.policy_proposals enable row level security;

-- Who may read: anyone signed in (§2.8 point 5 - current policy and its history stay
-- consultable by everyone), matching the existing select policies on the three policy tables.
drop policy if exists "policy_proposals_select" on public.policy_proposals;
create policy "policy_proposals_select" on public.policy_proposals
  for select using (current_role_is('user'));
-- No insert/update/delete policies: writes go through the two functions below.

-- Can the caller PROPOSE a change owned by this department?
create or replace function public.can_propose_policy_change(p_department text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select current_role_is('admin') or public.is_dept_lead(p_department);
$$;

-- Can the caller APPROVE a policy proposal? (Proposer <> approver is checked separately.)
-- Admin-only by design (§2.8: "an Admin who is not the proposer applies the decision") - unlike
-- people_decisions, no department lead can self-approve their own department's policy changes,
-- since Reward/HR/etc. leads are usually the proposers here.
create or replace function public.can_approve_policy_change()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select current_role_is('admin');
$$;

-- Applies the effect of an approved proposal. Internal: called by decide_policy_change() only.
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
    -- Keys are fixed (seeded in 80); only 'upsert' (i.e. changing the value) makes sense.
    if p.action = 'delete' then
      raise exception 'policy_values entries cannot be deleted, only changed.';
    end if;
    update public.policy_values
    set value = (p.field_changes->>'value')::integer,
        updated_at = now(), updated_by_email = p.decided_by_email
    where key = p.target_key;
    if not found then raise exception 'Unknown policy_values key: %', p.target_key; end if;
  end if;
end;
$$;

-- Entry point 1: propose. Returns the proposal id.
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
  if p_target_table not in ('task_category_rates', 'task_reputation_tiers', 'policy_values') then
    raise exception 'Invalid target table.';
  end if;
  if p_action not in ('upsert', 'delete') then
    raise exception 'Invalid action.';
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

-- Entry point 2: decide. p_outcome = 'approved' | 'rejected' by an Admin, or 'withdrawn' by the
-- proposer. The approver must not be the proposer (GOVERNANCE.md §1 principle 2, §2.8 point 3).
create or replace function public.decide_policy_change(p_id bigint, p_outcome text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  p       public.policy_proposals%rowtype;
  v_email text;
begin
  select * into p from public.policy_proposals where id = p_id for update;
  if p is null then raise exception 'Proposal not found.'; end if;
  if p.status <> 'pending' then raise exception 'This proposal has already been closed (%).', p.status; end if;
  if p_outcome not in ('approved', 'rejected', 'withdrawn') then raise exception 'Invalid outcome.'; end if;

  if p_outcome = 'withdrawn' then
    if p.proposed_by <> auth.uid() then raise exception 'Only the proposer can withdraw a proposal.'; end if;
  else
    if p.proposed_by = auth.uid() then
      raise exception 'The person who proposed a policy change cannot approve or reject it.';
    end if;
    if not public.can_approve_policy_change() then
      raise exception 'You are not allowed to decide a policy proposal.';
    end if;
    if p_outcome = 'rejected' and (p_note is null or btrim(p_note) = '') then
      raise exception 'A note is required when rejecting.';
    end if;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  update public.policy_proposals
  set status = p_outcome, decided_by = auth.uid(), decided_by_email = v_email,
      decided_at = now(), decision_note = p_note
  where id = p_id;

  if p_outcome = 'approved' then
    perform public.apply_policy_change(p_id);
  end if;
end;
$$;

-- Close the direct-write door: from here on, only apply_policy_change() (security definer,
-- reached only through decide_policy_change()) can write to these three tables. select stays
-- open to everyone signed in (§2.8 point 5 - current policy is always visible for consultation).
drop policy if exists "task_category_rates_admin_insert" on public.task_category_rates;
drop policy if exists "task_category_rates_admin_update" on public.task_category_rates;
drop policy if exists "task_category_rates_admin_delete" on public.task_category_rates;

drop policy if exists "task_reputation_tiers_admin_insert" on public.task_reputation_tiers;
drop policy if exists "task_reputation_tiers_admin_update" on public.task_reputation_tiers;
drop policy if exists "task_reputation_tiers_admin_delete" on public.task_reputation_tiers;

drop policy if exists "policy_values_admin_write" on public.policy_values;

notify pgrst, 'reload schema';

-- Self-test.
select 'table policy_proposals' as item, to_regclass('public.policy_proposals') is not null as ok
union all select 'policies policy_proposals (1, select only)', (select count(*) = 1 from pg_policies where tablename = 'policy_proposals')
union all select 'function can_propose_policy_change', (select count(*) = 1 from pg_proc where proname = 'can_propose_policy_change')
union all select 'function can_approve_policy_change', (select count(*) = 1 from pg_proc where proname = 'can_approve_policy_change')
union all select 'function apply_policy_change', (select count(*) = 1 from pg_proc where proname = 'apply_policy_change')
union all select 'function propose_policy_change', (select count(*) = 1 from pg_proc where proname = 'propose_policy_change')
union all select 'function decide_policy_change', (select count(*) = 1 from pg_proc where proname = 'decide_policy_change')
union all select 'task_category_rates has no admin write policy left', (select count(*) = 0 from pg_policies where tablename = 'task_category_rates' and cmd in ('INSERT','UPDATE','DELETE'))
union all select 'task_reputation_tiers has no admin write policy left', (select count(*) = 0 from pg_policies where tablename = 'task_reputation_tiers' and cmd in ('INSERT','UPDATE','DELETE'))
union all select 'policy_values has no admin write policy left', (select count(*) = 0 from pg_policies where tablename = 'policy_values' and cmd in ('INSERT','UPDATE','DELETE','ALL'))
union all select 'task_category_rates still select-able', (select count(*) = 1 from pg_policies where tablename = 'task_category_rates' and cmd = 'SELECT')
union all select 'task_reputation_tiers still select-able', (select count(*) = 1 from pg_policies where tablename = 'task_reputation_tiers' and cmd = 'SELECT')
union all select 'policy_values still select-able', (select count(*) = 1 from pg_policies where tablename = 'policy_values' and cmd = 'SELECT');
