-- Reputation starts at 50, not 70 - a mildly positive baseline for someone who hasn't done any
-- work yet ("un premio alla buona volontà di collaborare"), rather than a value that already
-- assumes some track record. Only resets rows still sitting untouched at the old default (no
-- ledger history at all) - anyone whose reputation already moved via real task_outcome_events
-- keeps their actual earned value, even if it happens to also read 70.
-- Do after 43_admin_final_decision.sql.

alter table public.user_roles alter column reputation set default 50;

update public.user_roles
set reputation = 50
where reputation = 70
  and not exists (select 1 from public.task_outcome_events e where e.user_id = user_roles.user_id);

select 'reputation default now 50.' as result;
