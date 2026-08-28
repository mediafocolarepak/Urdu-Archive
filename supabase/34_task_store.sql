-- Fase 2 di "Join the Team": bacheca di task che un Operator può sottoscrivere (claim) fissando
-- una data di consegna lui stesso; Coordinator/Admin creano i task, vedono chi è libero/in
-- ritardo, e possono riassegnare o liberare un task. Da eseguire dopo 22_collaboration_applications.sql
-- (usa current_role_is, già esteso lì a includere 'coordinator').

create table if not exists public.tasks (
  id bigint generated always as identity primary key,
  title text not null,
  description text,
  document_id integer references public.documents(document_id) on delete set null,
  created_by_email text not null,
  created_at timestamptz not null default now(),
  status text not null default 'open' check (status in ('open', 'claimed', 'done')),
  claimed_by uuid references auth.users(id) on delete set null,
  claimed_by_email text,
  claimed_at timestamptz,
  due_date date,
  completed_at timestamptz
);

alter table public.tasks enable row level security;

-- Chiunque sia almeno Operator vede l'intera bacheca (deve poter vedere cosa è libero da
-- prendere, non solo i propri task).
drop policy if exists "tasks_select_team" on public.tasks;
create policy "tasks_select_team" on public.tasks
  for select using (current_role_is('operator'));

-- Solo Coordinator/Admin creano task (decisione esplicita: la bacheca è gestita dal team di
-- coordinamento, non aperta a proposte spontanee degli Operator - a differenza delle
-- candidature "Join the Team" stesse, che restano un flusso separato).
drop policy if exists "tasks_insert_reviewers" on public.tasks;
create policy "tasks_insert_reviewers" on public.tasks
  for insert with check (current_role_is('coordinator'));

-- Un Operator può "prendere" (claim) un task libero, o aggiornare/completare un task che ha
-- già preso (claimed_by = lui). Non può toccare un task preso da qualcun altro. Coordinator/
-- Admin possono sempre aggiornare qualunque task (riassegnare, liberare, forzare completato).
drop policy if exists "tasks_update_own_or_reviewers" on public.tasks;
create policy "tasks_update_own_or_reviewers" on public.tasks
  for update using (
    current_role_is('coordinator') or claimed_by is null or claimed_by = auth.uid()
  ) with check (
    current_role_is('coordinator') or claimed_by = auth.uid()
  );

drop policy if exists "tasks_delete_reviewers" on public.tasks;
create policy "tasks_delete_reviewers" on public.tasks
  for delete using (current_role_is('coordinator'));

select 'tasks installato.' as result;
