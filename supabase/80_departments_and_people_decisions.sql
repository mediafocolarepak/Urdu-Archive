-- 80_departments_and_people_decisions.sql
-- Phase 1 of GOVERNANCE.md (v1.0, 2026-09-16): the department model, the "standing" of a
-- person, the append-only log of decisions about people, and the policy values that used to be
-- hard-coded. Written in English from here on: the team is no longer Italian-only.
--
-- What this migration does NOT do (phase 2, see GOVERNANCE.md §6.1b/§6.1c/§6.2): no UI, no
-- co-authors on formation paths, no board moderation. It only lays the schema and the functions
-- the UI will call, so that the client work can be done without touching the database again.
--
-- Run after 79_formation_post_documents.sql. Idempotent (if not exists / or replace / drop
-- policy if exists everywhere), so it can be re-run safely. Check with the self-test at the end.

-- ============================================================================
-- 1. Departments are an option list, so they are created/retired from the Options tab.
-- ============================================================================
insert into public.option_lists (list_name, code, label, sort_order) values
  ('department', 'HR',    'Human Resources',      1),
  ('department', 'COORD', 'Coordination',         2),
  ('department', 'FORM',  'Formation',            3),
  ('department', 'RF',    'Reward & Finances',    4),
  ('department', 'COMM',  'Communication',        5)
on conflict (list_name, code) do nothing;

-- ============================================================================
-- 2. Who belongs to which department, and who leads it. A person may be in any number of
--    departments; a department has at most one lead (partial unique index). Written by Admin
--    only - executing the Owner's decision (GOVERNANCE.md §4 row 8).
-- ============================================================================
create table if not exists public.department_members (
  department_code text        not null,
  user_id         uuid        not null references auth.users(id) on delete cascade,
  is_lead         boolean     not null default false,
  added_by_email  text,
  created_at      timestamptz not null default now(),
  primary key (department_code, user_id)
);
create unique index if not exists idx_department_members_one_lead
  on public.department_members (department_code) where is_lead;

alter table public.department_members enable row level security;

-- Everyone signed in can see who is in which department (same openness as user_roles): the
-- UI needs it to show "propose to the HR lead", and there is nothing secret in it.
drop policy if exists "department_members_select" on public.department_members;
create policy "department_members_select" on public.department_members
  for select using (current_role_is('user'));

drop policy if exists "department_members_admin_insert" on public.department_members;
create policy "department_members_admin_insert" on public.department_members
  for insert with check (current_role_is('admin'));

drop policy if exists "department_members_admin_update" on public.department_members;
create policy "department_members_admin_update" on public.department_members
  for update using (current_role_is('admin')) with check (current_role_is('admin'));

drop policy if exists "department_members_admin_delete" on public.department_members;
create policy "department_members_admin_delete" on public.department_members
  for delete using (current_role_is('admin'));

-- Helpers, same shape as is_board_editor() (71): security definer so policies can call them
-- regardless of what the caller's own RLS would let them read.
create or replace function public.is_dept_member(code text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.department_members
                  where department_code = code and user_id = auth.uid());
$$;

create or replace function public.is_dept_lead(code text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.department_members
                  where department_code = code and user_id = auth.uid() and is_lead);
$$;

create or replace function public.is_any_dept_lead()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.department_members where user_id = auth.uid() and is_lead);
$$;

-- ============================================================================
-- 3. "Formatore" is now = member of the Formation department (GOVERNANCE.md §8.2). Every policy
--    written since 73 calls is_any_formatore(), so redefining it is enough. board_editors keeps
--    its own meaning (who curates a given board). Backfill: everyone who is a board editor today
--    becomes a FORM member, so nobody loses the ability to create paths on the day this runs.
-- ============================================================================
insert into public.department_members (department_code, user_id, added_by_email)
  select distinct 'FORM', user_id, 'migration 80 (backfill from board_editors)'
  from public.board_editors
on conflict (department_code, user_id) do nothing;

create or replace function public.is_any_formatore()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.is_dept_member('FORM');
$$;

-- ============================================================================
-- 4. Standing of a person: active / watch / suspended. Never written by hand - only by
--    decide_people_decision() below. 'suspended' blocks taking tasks (trigger in §7).
-- ============================================================================
alter table public.user_roles add column if not exists standing text not null default 'active';
alter table public.user_roles drop constraint if exists user_roles_standing_check;
alter table public.user_roles add constraint user_roles_standing_check
  check (standing in ('active', 'watch', 'suspended'));

-- ============================================================================
-- 5. Policy values: numbers that are policy, not code (GOVERNANCE.md §8.3, §8.4). Admin edits
--    them from Options; everyone signed in can read them (the client needs them for badges).
-- ============================================================================
create table if not exists public.policy_values (
  key              text primary key,
  value            integer not null,
  label            text not null,
  updated_at       timestamptz not null default now(),
  updated_by_email text
);
alter table public.policy_values enable row level security;

drop policy if exists "policy_values_select" on public.policy_values;
create policy "policy_values_select" on public.policy_values
  for select using (current_role_is('user'));

drop policy if exists "policy_values_admin_write" on public.policy_values;
create policy "policy_values_admin_write" on public.policy_values
  for all using (current_role_is('admin')) with check (current_role_is('admin'));

insert into public.policy_values (key, value, label) values
  ('extra_credit_pct_threshold',     30, 'Extra credits above this % of base credits need the Coordination lead''s approval'),
  ('extra_credit_abs_threshold',     10, 'Extra credits above this absolute value need the Coordination lead''s approval'),
  ('risk_reputation_below',          40, 'A person is "at risk" when reputation is below this'),
  ('risk_negative_events',            2, 'A person is "at risk" after this many negative events in the window'),
  ('risk_window_days',               60, 'Window (days) for counting negative events'),
  ('board_misuse_reputation_delta', -10, 'Reputation penalty applied for board misuse (negative number)')
on conflict (key) do nothing;

create or replace function public.policy_value(p_key text, p_default integer)
returns integer
language sql
security definer
stable
set search_path = public
as $$
  select coalesce((select value from public.policy_values where key = p_key), p_default);
$$;

-- ============================================================================
-- 6. Decisions about people: the append-only log (GOVERNANCE.md §1.4, §4). Same idea as
--    task_outcome_events: nothing is ever updated except the decision fields, nothing deleted.
--    Rows are written ONLY through propose_people_decision() / decide_people_decision(): there
--    is no insert/update policy for clients on purpose.
--
--    decision_type            proposed by                  approved by                  effect on approval
--    ---------------------    -------------------------    -------------------------    ----------------------------------
--    qualification_add        HR member / Coordinator      Admin                        insert user_qualifications
--    qualification_remove     HR member / Coordinator      Admin                        delete user_qualifications
--    watch_on / watch_off     HR member                    (none - applied at once)     standing active <-> watch
--    suspend                  HR member                    HR lead or Admin             standing -> suspended
--    reinstate                HR member                    HR lead or Admin             standing -> active
--    exclude                  HR member                    Admin (executing the Owner)  role -> user, standing -> suspended,
--                                                                                       drop dept/board/qualification rows
--    role_change              HR lead / Admin              Admin                        user_roles.role := payload.role
--    board_misuse             board editor / Coordinator   FORM lead, HR lead or Admin  task_outcome_events (reputation penalty)
--
--    In every case the approver must be a different person from the proposer.
-- ============================================================================
create table if not exists public.people_decisions (
  id                bigint generated always as identity primary key,
  subject_user_id   uuid        not null references auth.users(id) on delete cascade,
  subject_email     text,
  decision_type     text        not null,
  payload           jsonb,      -- qualification_code / role / reputation_delta, depending on type
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
  constraint people_decisions_reason_not_blank check (btrim(reason) <> ''),
  constraint people_decisions_type check (decision_type in (
    'qualification_add', 'qualification_remove', 'watch_on', 'watch_off',
    'suspend', 'reinstate', 'exclude', 'role_change', 'board_misuse'))
);
create index if not exists idx_people_decisions_subject on public.people_decisions (subject_user_id, proposed_at desc);
create index if not exists idx_people_decisions_pending on public.people_decisions (status) where status = 'pending';

alter table public.people_decisions enable row level security;

-- Who may read: HR members, any department lead, Admin - and the person the decision is about
-- (they should be able to see what was decided about them and why).
drop policy if exists "people_decisions_select" on public.people_decisions;
create policy "people_decisions_select" on public.people_decisions
  for select using (
    subject_user_id = auth.uid()
    or public.is_dept_member('HR')
    or public.is_any_dept_lead()
    or current_role_is('admin')
  );
-- No insert/update/delete policies: writes go through the two functions below.

insert into public.option_lists (list_name, code, label, sort_order) values
  ('people_decision_type', 'qualification_add',    'Add a qualification',            1),
  ('people_decision_type', 'qualification_remove', 'Remove a qualification',         2),
  ('people_decision_type', 'watch_on',             'Put on the watch list',          3),
  ('people_decision_type', 'watch_off',            'Remove from the watch list',     4),
  ('people_decision_type', 'suspend',              'Suspend (no new tasks)',         5),
  ('people_decision_type', 'reinstate',            'Reinstate',                      6),
  ('people_decision_type', 'exclude',              'Exclude (remove role, keep account)', 7),
  ('people_decision_type', 'role_change',          'Change technical role',          8),
  ('people_decision_type', 'board_misuse',         'Penalise board misuse',          9)
on conflict (list_name, code) do nothing;

-- Can the caller PROPOSE this kind of decision?
create or replace function public.can_propose_people_decision(p_type text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select case
    when current_role_is('admin') then true
    when p_type in ('qualification_add', 'qualification_remove') then
      public.is_dept_member('HR') or current_role_is('coordinator')
    when p_type in ('watch_on', 'watch_off', 'suspend', 'reinstate', 'exclude') then
      public.is_dept_member('HR')
    when p_type = 'role_change' then
      public.is_dept_lead('HR')
    when p_type = 'board_misuse' then
      current_role_is('coordinator')
      or exists (select 1 from public.board_editors where user_id = auth.uid())
    else false
  end;
$$;

-- Can the caller APPROVE this kind of decision? (Proposer <> approver is checked separately.)
create or replace function public.can_approve_people_decision(p_type text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select case
    when current_role_is('admin') then true
    when p_type in ('suspend', 'reinstate') then public.is_dept_lead('HR')
    when p_type = 'board_misuse' then public.is_dept_lead('FORM') or public.is_dept_lead('HR')
    else false   -- qualification_*, exclude, role_change: Admin only
  end;
$$;

-- Applies the effect of an approved decision. Internal: called by the two entry points below.
create or replace function public.apply_people_decision(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d      public.people_decisions%rowtype;
  v_role text;
  v_delta integer;
begin
  select * into d from public.people_decisions where id = p_id;
  if d is null then raise exception 'Decision not found.'; end if;

  if d.decision_type = 'qualification_add' then
    insert into public.user_qualifications (user_id, qualification_code)
    values (d.subject_user_id, d.payload->>'qualification_code')
    on conflict do nothing;

  elsif d.decision_type = 'qualification_remove' then
    delete from public.user_qualifications
    where user_id = d.subject_user_id and qualification_code = d.payload->>'qualification_code';

  elsif d.decision_type = 'watch_on' then
    update public.user_roles set standing = 'watch'
    where user_id = d.subject_user_id and standing = 'active';

  elsif d.decision_type = 'watch_off' then
    update public.user_roles set standing = 'active'
    where user_id = d.subject_user_id and standing = 'watch';

  elsif d.decision_type = 'suspend' then
    update public.user_roles set standing = 'suspended' where user_id = d.subject_user_id;

  elsif d.decision_type = 'reinstate' then
    update public.user_roles set standing = 'active' where user_id = d.subject_user_id;

  elsif d.decision_type = 'exclude' then
    -- GOVERNANCE.md §8.7: remove the role, keep the account and every ledger row.
    update public.user_roles set role = 'user', standing = 'suspended' where user_id = d.subject_user_id;
    delete from public.department_members  where user_id = d.subject_user_id;
    delete from public.board_editors       where user_id = d.subject_user_id;
    delete from public.user_qualifications where user_id = d.subject_user_id;

  elsif d.decision_type = 'role_change' then
    v_role := d.payload->>'role';
    if v_role not in ('user', 'operator', 'coordinator', 'admin') then
      raise exception 'Invalid role in payload.';
    end if;
    update public.user_roles set role = v_role where user_id = d.subject_user_id;

  elsif d.decision_type = 'board_misuse' then
    v_delta := coalesce((d.payload->>'reputation_delta')::integer,
                        public.policy_value('board_misuse_reputation_delta', -10));
    if v_delta > 0 then raise exception 'A board misuse penalty cannot be positive.'; end if;
    -- The trigger on task_outcome_events (38) applies the delta to user_roles.reputation.
    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (null, d.subject_user_id, 'board_misuse', 0, v_delta, d.decided_by_email,
            'People decision #' || d.id || ': ' || d.reason);
  end if;
end;
$$;

-- Entry point 1: propose. Returns the decision id. Types that need no approval (watch_on /
-- watch_off, GOVERNANCE.md §4 row 4) are applied immediately and recorded as approved by the
-- proposer with a note saying so.
create or replace function public.propose_people_decision(
  p_subject uuid, p_type text, p_reason text, p_payload jsonb default null)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id    bigint;
  v_email text;
  v_subject_email text;
begin
  if not public.can_propose_people_decision(p_type) then
    raise exception 'You are not allowed to propose a "%" decision.', p_type;
  end if;
  if p_subject = auth.uid() then
    raise exception 'You cannot propose a decision about yourself.';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception 'A reason is required.';
  end if;
  if p_type in ('qualification_add', 'qualification_remove') and coalesce(p_payload->>'qualification_code', '') = '' then
    raise exception 'payload.qualification_code is required.';
  end if;
  if p_type = 'role_change' and coalesce(p_payload->>'role', '') = '' then
    raise exception 'payload.role is required.';
  end if;
  if exists (select 1 from public.people_decisions
              where subject_user_id = p_subject and decision_type = p_type and status = 'pending') then
    raise exception 'There is already a pending "%" decision about this person.', p_type;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();
  select email into v_subject_email from public.user_roles where user_id = p_subject;

  insert into public.people_decisions (subject_user_id, subject_email, decision_type, payload, reason, proposed_by, proposed_by_email)
  values (p_subject, v_subject_email, p_type, p_payload, p_reason, auth.uid(), v_email)
  returning id into v_id;

  if p_type in ('watch_on', 'watch_off') then
    update public.people_decisions
    set status = 'approved', decided_by = auth.uid(), decided_by_email = v_email,
        decided_at = now(), decision_note = 'No approval required for this type.'
    where id = v_id;
    perform public.apply_people_decision(v_id);
  end if;

  return v_id;
end;
$$;

-- Entry point 2: decide. p_outcome = 'approved' | 'rejected' by an approver, or 'withdrawn' by
-- the proposer. The approver must not be the proposer - this is the separation-of-duties rule
-- of GOVERNANCE.md §1.2, enforced here and not only in the UI.
create or replace function public.decide_people_decision(p_id bigint, p_outcome text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  d       public.people_decisions%rowtype;
  v_email text;
begin
  select * into d from public.people_decisions where id = p_id for update;
  if d is null then raise exception 'Decision not found.'; end if;
  if d.status <> 'pending' then raise exception 'This decision has already been closed (%).', d.status; end if;
  if p_outcome not in ('approved', 'rejected', 'withdrawn') then raise exception 'Invalid outcome.'; end if;

  if p_outcome = 'withdrawn' then
    if d.proposed_by <> auth.uid() then raise exception 'Only the proposer can withdraw a proposal.'; end if;
  else
    if d.proposed_by = auth.uid() then
      raise exception 'The person who proposed a decision cannot approve or reject it.';
    end if;
    if not public.can_approve_people_decision(d.decision_type) then
      raise exception 'You are not allowed to decide a "%" decision.', d.decision_type;
    end if;
    if p_outcome = 'rejected' and (p_note is null or btrim(p_note) = '') then
      raise exception 'A note is required when rejecting.';
    end if;
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  update public.people_decisions
  set status = p_outcome, decided_by = auth.uid(), decided_by_email = v_email,
      decided_at = now(), decision_note = p_note
  where id = p_id;

  if p_outcome = 'approved' then
    perform public.apply_people_decision(p_id);
  end if;
end;
$$;

-- ============================================================================
-- 7. A suspended person cannot take tasks - neither by claiming an open one nor by being
--    assigned one by a Coordinator. A trigger rather than a policy change, so the (already
--    layered) task policies of 34/37/38 stay untouched.
-- ============================================================================
create or replace function public.block_suspended_task_claim()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.claimed_by is not null
     and (tg_op = 'INSERT' or new.claimed_by is distinct from old.claimed_by)
     and exists (select 1 from public.user_roles where user_id = new.claimed_by and standing = 'suspended') then
    raise exception 'This operator is suspended and cannot take tasks.';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_block_suspended_task_claim on public.tasks;
create trigger trg_block_suspended_task_claim
  before insert or update of claimed_by on public.tasks
  for each row execute function public.block_suspended_task_claim();

-- ============================================================================
-- 8. Join the Team: route to HR and record who recommended, so the approver can be checked
--    against the proposer (GOVERNANCE.md §4 row 1). Coordinators KEEP their access in this
--    migration - the client still shows the tab to them (canReviewApplications() in core.js);
--    phase 2a moves the tab to HR members and then drops 'coordinator' from these two policies.
-- ============================================================================
alter table public.collaboration_applications add column if not exists recommended_by uuid references auth.users(id) on delete set null;
alter table public.collaboration_applications add column if not exists recommended_by_email text;

create or replace function public.collaboration_application_guard()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare v_email text;
begin
  if new.status = 'recommended' and old.status is distinct from 'recommended' then
    select email into v_email from public.user_roles where user_id = auth.uid();
    new.recommended_by := auth.uid();
    new.recommended_by_email := v_email;
  end if;
  if new.status = 'approved' and old.status is distinct from 'approved'
     and new.recommended_by is not null and new.recommended_by = auth.uid() then
    raise exception 'The person who recommended an application cannot be the one who approves it.';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_collaboration_application_guard on public.collaboration_applications;
create trigger trg_collaboration_application_guard
  before update on public.collaboration_applications
  for each row execute function public.collaboration_application_guard();

drop policy if exists "collaboration_applications_select_reviewers" on public.collaboration_applications;
create policy "collaboration_applications_select_reviewers" on public.collaboration_applications
  for select using (current_role_is('coordinator') or public.is_dept_member('HR'));

drop policy if exists "collaboration_applications_update_reviewers" on public.collaboration_applications;
create policy "collaboration_applications_update_reviewers" on public.collaboration_applications
  for update using (current_role_is('coordinator') or public.is_dept_member('HR'))
  with check (
    current_role_is('admin')
    or ((current_role_is('coordinator') or public.is_dept_member('HR')) and status in ('recommended', 'rejected'))
  );

-- ============================================================================
-- 9. The HR view (GOVERNANCE.md §6.2), as one function so the People tab is a single call.
--    Readable by HR members, department leads and Admin. "at_risk" is computed here from
--    policy_values, never stored - what is stored is the HR decision (standing = 'watch').
-- ============================================================================
create or replace function public.hr_people_overview()
returns table (
  user_id            uuid,
  email              text,
  full_name          text,
  city               text,
  membership_type    text,
  phone              text,
  role               text,
  standing           text,
  credits            integer,
  reputation         integer,
  qualifications     text,
  departments        text,      -- e.g. "HR (lead), FORM"
  since              timestamptz,
  last_event_at      timestamptz,
  last_event_type    text,
  negative_events    bigint,    -- in the risk window
  open_tasks         bigint,    -- claimed / submitted / approved, not yet closed
  pending_decisions  bigint,
  at_risk            boolean
)
language sql
security definer
stable
set search_path = public
as $$
  with me as (
    select public.is_dept_member('HR') or public.is_any_dept_lead() or current_role_is('admin') as ok
  ),
  thr as (
    select public.policy_value('risk_reputation_below', 40)  as rep_below,
           public.policy_value('risk_negative_events', 2)    as neg_events,
           public.policy_value('risk_window_days', 60)       as window_days
  ),
  ev as (
    select e.user_id,
           max(e.created_at) as last_event_at,
           (array_agg(e.event_type order by e.created_at desc))[1] as last_event_type,
           count(*) filter (where e.reputation_delta < 0
                              and e.created_at >= now() - make_interval(days => (select window_days from thr))) as negative_events
    from public.task_outcome_events e
    group by e.user_id
  )
  select r.user_id, r.email, coalesce(p.full_name, ''), p.city, p.membership_type, p.phone,
         r.role, r.standing, r.credits, r.reputation,
         (select string_agg(q.qualification_code, ', ' order by q.qualification_code)
            from public.user_qualifications q where q.user_id = r.user_id),
         (select string_agg(d.department_code || case when d.is_lead then ' (lead)' else '' end, ', ' order by d.department_code)
            from public.department_members d where d.user_id = r.user_id),
         r.created_at,
         ev.last_event_at, ev.last_event_type, coalesce(ev.negative_events, 0),
         (select count(*) from public.tasks t where t.claimed_by = r.user_id and t.status in ('claimed', 'submitted', 'approved')),
         (select count(*) from public.people_decisions pd where pd.subject_user_id = r.user_id and pd.status = 'pending'),
         (r.reputation < (select rep_below from thr)) or (coalesce(ev.negative_events, 0) >= (select neg_events from thr))
  from public.user_roles r
  left join public.user_profiles p on p.user_id = r.user_id
  left join ev on ev.user_id = r.user_id
  where (select ok from me)
  order by coalesce(p.full_name, ''), r.email;
$$;

-- ============================================================================
-- 10. Self-test (run separately). All rows must be true.
-- ============================================================================
select 'option list department (5)' as item, (select count(*) = 5 from public.option_lists where list_name = 'department') as ok
union all select 'option list people_decision_type (9)', (select count(*) = 9 from public.option_lists where list_name = 'people_decision_type')
union all select 'table department_members',        to_regclass('public.department_members') is not null
union all select 'table people_decisions',          to_regclass('public.people_decisions') is not null
union all select 'table policy_values (6 rows)',    (select count(*) = 6 from public.policy_values)
union all select 'user_roles.standing',             exists (select 1 from information_schema.columns where table_name = 'user_roles' and column_name = 'standing')
union all select 'applications.recommended_by',     exists (select 1 from information_schema.columns where table_name = 'collaboration_applications' and column_name = 'recommended_by')
union all select 'fn is_dept_member',               to_regproc('public.is_dept_member') is not null
union all select 'fn is_dept_lead',                 to_regproc('public.is_dept_lead') is not null
union all select 'fn propose_people_decision',      to_regproc('public.propose_people_decision') is not null
union all select 'fn decide_people_decision',       to_regproc('public.decide_people_decision') is not null
union all select 'fn hr_people_overview',           to_regproc('public.hr_people_overview') is not null
union all select 'trigger suspended claim',         exists (select 1 from pg_trigger where tgname = 'trg_block_suspended_task_claim')
union all select 'trigger application guard',       exists (select 1 from pg_trigger where tgname = 'trg_collaboration_application_guard')
union all select 'policies department_members (4)', (select count(*) = 4 from pg_policies where tablename = 'department_members')
union all select 'policies people_decisions (1)',   (select count(*) = 1 from pg_policies where tablename = 'people_decisions')
union all select 'FORM backfilled from board_editors', (select count(*) from public.department_members where department_code = 'FORM')
                                                     >= (select count(distinct user_id) from public.board_editors);
