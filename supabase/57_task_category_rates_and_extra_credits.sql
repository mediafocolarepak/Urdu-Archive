-- 57_task_category_rates_and_extra_credits.sql
-- Step 1 of the credits redesign: an admin-editable credits-per-page rate per task category,
-- plus splitting tasks.credits into an auto-computed base_credits (rate x pages) and a
-- separately-declared extra_credits (difficulty/urgency bonus, requires a note - see
-- js/tasks.js). tasks.credits itself is unchanged in shape (still the number everything else
-- in the app reads) - the client computes credits = base_credits + extra_credits at creation.

create table if not exists task_category_rates (
  category text primary key,
  credits_per_page numeric not null default 0,
  updated_at timestamptz not null default now(),
  updated_by_email text
);

alter table task_category_rates enable row level security;

drop policy if exists task_category_rates_select on task_category_rates;
create policy task_category_rates_select on task_category_rates
  for select using (current_role_is('user'));

drop policy if exists task_category_rates_admin_insert on task_category_rates;
create policy task_category_rates_admin_insert on task_category_rates
  for insert with check (current_role_is('admin'));

drop policy if exists task_category_rates_admin_update on task_category_rates;
create policy task_category_rates_admin_update on task_category_rates
  for update using (current_role_is('admin')) with check (current_role_is('admin'));

drop policy if exists task_category_rates_admin_delete on task_category_rates;
create policy task_category_rates_admin_delete on task_category_rates
  for delete using (current_role_is('admin'));

alter table tasks
  add column if not exists base_credits integer,
  add column if not exists extra_credits integer not null default 0,
  add column if not exists extra_credits_note text;

-- Redefined only to carry base_credits/extra_credits/extra_credits_note onto the retry task a
-- 'fail' verdict spawns, alongside the existing credits/category/pages copy - same behavior
-- otherwise, see 40_task_review_verdict.sql for the original.
create or replace function public.submit_task_review(p_task_id bigint, p_verdict text, p_notes text)
returns void
language plpgsql
security definer
as $$
declare
  v_task public.tasks%rowtype;
  v_email text;
  v_credit_delta integer;
  v_reputation_delta integer;
  v_new_status text;
  v_event_type text;
begin
  if not exists (select 1 from public.user_qualifications where user_id = auth.uid() and qualification_code = 'REVISOR') then
    raise exception 'Only a Revisor can submit a review verdict.';
  end if;
  if p_verdict not in ('ok', 'ok_but', 'fail') then
    raise exception 'Invalid verdict.';
  end if;

  select * into v_task from public.tasks where id = p_task_id for update;
  if v_task is null then raise exception 'Task not found.'; end if;
  if v_task.status <> 'submitted' then raise exception 'Only a submitted task can be reviewed.'; end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  if p_verdict = 'ok' then
    v_new_status := 'approved'; v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := 10; v_event_type := 'review_ok';
  elsif p_verdict = 'ok_but' then
    v_new_status := 'approved'; v_credit_delta := coalesce(v_task.credits, 0); v_reputation_delta := -5; v_event_type := 'review_ok_but';
  else
    v_new_status := 'rejected'; v_credit_delta := 0; v_reputation_delta := -10; v_event_type := 'review_fail';
  end if;

  update public.tasks
  set status = v_new_status, review_verdict = p_verdict, review_notes = p_notes,
      reviewed_by = auth.uid(), reviewed_by_email = v_email, reviewed_at = now()
  where id = p_task_id;

  insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
  values (p_task_id, v_task.claimed_by, v_event_type, v_credit_delta, v_reputation_delta, v_email, p_notes);

  if p_verdict = 'fail' then
    insert into public.tasks (
      title, description, category, document_id, document_pages, credits,
      base_credits, extra_credits, extra_credits_note,
      created_by_email, status, retry_of_task_id, excluded_operator
    ) values (
      v_task.title || ' (retry)', v_task.description, v_task.category, v_task.document_id, v_task.document_pages, v_task.credits,
      v_task.base_credits, v_task.extra_credits, v_task.extra_credits_note,
      v_task.created_by_email, 'open', v_task.id, v_task.claimed_by
    );
  end if;
end;
$$;
