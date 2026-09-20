-- 99_department_pulse_signals.sql
-- "Department Pulse" Phase 2 (owner's request 2026-09-20, GOVERNANCE.md §5.9/§8 item 11):
-- a computed suggestion for the status color, shown as a hint next to the lead's own manual
-- pick - never auto-applied, never overwrites department_status on its own. Only the two
-- departments with an existing, objective signal in the data get one for now (Coordination:
-- overdue tasks; Reward: flagged credit anomalies) - HR (pending decision age), Formation and
-- Communication (days since last real activity) round out all five "core" departments per the
-- owner's request; Archive & Data has no bespoke signal yet (its work already shows up in
-- Coordination's task data) and returns no suggestion.
--
-- Run after 98_department_status.sql. Idempotent, self-test at the end.

create or replace function public.department_pulse_suggested_status(p_code text)
returns table(suggested text, reason text)
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_overdue integer;
  v_flagged integer;
  v_oldest_pending_days integer;
  v_form_days integer;
  v_comm_days integer;
begin
  if not (public.is_dept_member(p_code) or current_role_is('admin')) then
    return;
  end if;

  if p_code = 'COORD' then
    select count(*) into v_overdue from public.tasks
      where status = 'claimed' and due_date is not null and due_date < current_date;
    if v_overdue = 0 then return query select 'on_track', 'No overdue tasks.';
    elsif v_overdue <= 2 then return query select 'slowing', v_overdue || ' task(s) overdue.';
    else return query select 'stalled', v_overdue || ' task(s) overdue.';
    end if;

  elsif p_code = 'RF' then
    select count(*) into v_flagged from public.reward_operator_credit_anomalies() where flagged;
    if v_flagged = 0 then return query select 'on_track', 'No flagged credit anomalies.';
    elsif v_flagged <= 2 then return query select 'slowing', v_flagged || ' operator(s) flagged in the anomaly report.';
    else return query select 'stalled', v_flagged || ' operator(s) flagged in the anomaly report.';
    end if;

  elsif p_code = 'HR' then
    select coalesce(extract(day from now() - min(proposed_at))::integer, 0) into v_oldest_pending_days
      from public.people_decisions where status = 'pending';
    if v_oldest_pending_days = 0 then return query select 'on_track', 'No pending decisions.';
    elsif v_oldest_pending_days <= 7 then return query select 'on_track', 'Oldest pending decision is ' || v_oldest_pending_days || ' day(s) old.';
    elsif v_oldest_pending_days <= 14 then return query select 'slowing', 'Oldest pending decision is ' || v_oldest_pending_days || ' day(s) old.';
    else return query select 'stalled', 'Oldest pending decision is ' || v_oldest_pending_days || ' day(s) old.';
    end if;

  elsif p_code = 'FORM' then
    select coalesce(extract(day from now() - greatest(
      (select max(created_at) from public.formation_chat_messages where channel = 'formatori'),
      (select max(updated_at) from public.formation_paths)
    ))::integer, 999) into v_form_days;
    if v_form_days <= 7 then return query select 'on_track', 'Last activity ' || v_form_days || ' day(s) ago.';
    elsif v_form_days <= 21 then return query select 'slowing', 'Last activity ' || v_form_days || ' day(s) ago.';
    else return query select 'stalled', case when v_form_days >= 999 then 'No activity recorded yet.' else 'Last activity ' || v_form_days || ' day(s) ago.' end;
    end if;

  elsif p_code = 'COMM' then
    select coalesce(extract(day from now() - max(updated_at))::integer, 999) into v_comm_days
      from public.onboarding_cards;
    if v_comm_days <= 7 then return query select 'on_track', 'Last card update ' || v_comm_days || ' day(s) ago.';
    elsif v_comm_days <= 21 then return query select 'slowing', 'Last card update ' || v_comm_days || ' day(s) ago.';
    else return query select 'stalled', case when v_comm_days >= 999 then 'No cards yet.' else 'Last card update ' || v_comm_days || ' day(s) ago.' end;
    end if;

  else
    return; -- Archive & Data, or any future department: no bespoke signal yet.
  end if;
end;
$$;

-- ============================================================================
-- Self-test (run separately). All rows must be true.
-- ============================================================================
select 'function department_pulse_suggested_status' as item,
  exists (select 1 from pg_proc where proname = 'department_pulse_suggested_status') as ok;
