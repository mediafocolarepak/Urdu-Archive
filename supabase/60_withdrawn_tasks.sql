-- 60_withdrawn_tasks.sql
-- Adds a 'withdrawn' task status so Admin can pull an obsolete/over-budget open task off
-- Tasks Store without deleting it, then re-enable it later from a new "Withdrawn Tasks" tab
-- (js/tasks.js). Only open <-> withdrawn transitions are allowed - a claimed/submitted/etc.
-- task can't be withdrawn directly (free it up first, same as any other status change).

alter table public.tasks drop constraint if exists tasks_status_check;
alter table public.tasks add constraint tasks_status_check
  check (status in ('open', 'claimed', 'submitted', 'approved', 'rejected', 'published', 'withdrawn'));

create or replace function public.validate_task_status_transition()
returns trigger
language plpgsql
as $$
begin
  if new.status = old.status then
    return new;
  end if;
  if (old.status, new.status) in (
    ('open', 'claimed'), ('claimed', 'open'), ('claimed', 'submitted'),
    ('submitted', 'approved'), ('submitted', 'rejected'), ('approved', 'published'),
    ('open', 'withdrawn'), ('withdrawn', 'open')
  ) then
    return new;
  end if;
  raise exception 'Illegal task status transition: % -> %', old.status, new.status;
end;
$$;
