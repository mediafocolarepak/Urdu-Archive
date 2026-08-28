-- "Join the Team": candidature di collaborazione (User -> Operator) + nuovo ruolo Coordinator.
-- Da eseguire dopo 05_roles_and_permissions.sql / 16_signup_chat_splash.sql.

-- 1. Nuovo ruolo 'coordinator', tra operator e admin.
alter table user_roles drop constraint if exists user_roles_role_check;
alter table user_roles add constraint user_roles_role_check
  check (role in ('user', 'operator', 'coordinator', 'admin'));

-- current_role_is('operator') ora include anche coordinator (il Coordinator eredita i poteri
-- di scrittura dell'Operator); nuovo caso esplicito per 'coordinator' (coordinator + admin),
-- usato dalle policy sulle candidature sotto.
create or replace function public.current_role_is(min_role text)
returns boolean
language sql
security definer
stable
as $$
  select case
    when min_role = 'user' then exists (select 1 from user_roles where user_id = auth.uid())
    when min_role = 'operator' then exists (select 1 from user_roles where user_id = auth.uid() and role in ('operator', 'coordinator', 'admin'))
    when min_role = 'coordinator' then exists (select 1 from user_roles where user_id = auth.uid() and role in ('coordinator', 'admin'))
    when min_role = 'admin' then exists (select 1 from user_roles where user_id = auth.uid() and role = 'admin')
    else false
  end;
$$;

-- 2. Tabella delle candidature.
create table if not exists public.collaboration_applications (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  user_email text not null,
  created_at timestamptz not null default now(),
  academic_level text,
  experience text,
  skills text,
  motivation text,
  availability text,
  status text not null default 'pending' check (status in ('pending', 'recommended', 'approved', 'rejected')),
  coordinator_note text,
  reviewed_by_email text,
  reviewed_at timestamptz
);

-- Una sola candidatura "attiva" (non ancora rifiutata/approvata) per persona alla volta -
-- evita invii ripetuti mentre una richiesta è già in valutazione.
create unique index if not exists collaboration_applications_one_active_per_user
  on public.collaboration_applications (user_id)
  where status in ('pending', 'recommended');

alter table public.collaboration_applications enable row level security;

drop policy if exists "collaboration_applications_select_own" on public.collaboration_applications;
create policy "collaboration_applications_select_own" on public.collaboration_applications
  for select using (auth.uid() = user_id);

drop policy if exists "collaboration_applications_select_reviewers" on public.collaboration_applications;
create policy "collaboration_applications_select_reviewers" on public.collaboration_applications
  for select using (current_role_is('coordinator'));

drop policy if exists "collaboration_applications_insert_own" on public.collaboration_applications;
create policy "collaboration_applications_insert_own" on public.collaboration_applications
  for insert with check (auth.uid() = user_id);

-- Sia Coordinator che Admin possono aggiornare stato/nota - il Coordinator segna solo
-- "recommended"/"rejected" (mai "approved": la promozione a Operator resta un'azione Admin,
-- fatta insieme all'update di user_roles.role che solo Admin può già fare - vedi
-- 05_roles_and_permissions.sql, "admins update roles").
drop policy if exists "collaboration_applications_update_reviewers" on public.collaboration_applications;
create policy "collaboration_applications_update_reviewers" on public.collaboration_applications
  for update using (current_role_is('coordinator'))
  with check (
    current_role_is('admin')
    or (current_role_is('coordinator') and status in ('recommended', 'rejected'))
  );

select 'collaboration_applications installato. Ricorda di promuovere manualmente i coordinatori: update user_roles set role = ''coordinator'' where email = ''...'';' as result;
