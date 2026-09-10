-- Percorsi formativi (Fase B: iscrizione). Modello C confermato in chat il 10/09/2026: il
-- contenuto di un percorso pubblicato resta sempre leggibile da chiunque (vedi 73); iscriversi
-- entro formation_paths.enrollment_deadline serve solo a sbloccare, nelle fasi successive,
-- chatroom (Fase C) e quiz/attestato (Fase D) - non ancora costruiti qui.
--
-- Tutte le scritture passano da due funzioni security definer (stesso schema delle RPC di
-- give_up_task/reclaim_task in 34_task_store.sql) invece che da insert/update diretti sulla
-- tabella: la scadenza va controllata in un solo punto, non duplicata tra client e RLS.
-- Il client non ha NESSUN permesso di scrittura diretto sulla tabella.

create table if not exists public.formation_enrollments (
  path_id      bigint  not null references public.formation_paths(id) on delete cascade,
  user_id      uuid    not null references auth.users(id) on delete cascade,
  enrolled_at  timestamptz not null default now(),
  -- null = iscritto attualmente; valorizzato = si e' ritirato (la riga resta, per lo storico -
  -- ri-iscriversi entro la scadenza aggiorna la stessa riga invece di crearne una seconda).
  withdrawn_at timestamptz,
  primary key (path_id, user_id)
);
create index if not exists idx_formation_enrollments_path on public.formation_enrollments (path_id) where withdrawn_at is null;

alter table public.formation_enrollments enable row level security;

-- Solo lettura della propria riga (serve al client per sapere "mi sono iscritto?") - stesso
-- schema di board_post_reads in 72_board_post_reads.sql. Nessuna policy di insert/update/delete:
-- ogni scrittura passa dalle funzioni sotto.
drop policy if exists "formation_enrollments_select_own" on public.formation_enrollments;
create policy "formation_enrollments_select_own" on public.formation_enrollments
  for select using (user_id = auth.uid());

-- "Quanti iscritti attivi ha ciascuno di questi percorsi?" - a tutti, nessun dato personale.
create or replace function public.formation_enrollment_counts(path_ids bigint[])
returns table (path_id bigint, enrolled_count bigint)
language sql
security definer
stable
set search_path = public
as $$
  select fe.path_id, count(*) as enrolled_count
  from public.formation_enrollments fe
  where fe.path_id = any(path_ids) and fe.withdrawn_at is null
  group by fe.path_id;
$$;

-- "Chi e' iscritto a questo percorso?" - solo al proprietario o a Coordinator/Admin, verificato
-- dalla funzione stessa (stesso schema di board_post_readers in 72): se il chiamante non ha il
-- permesso, restituisce zero righe invece di un errore.
create or replace function public.formation_enrollees(pid bigint)
returns table (user_id uuid, full_name text, email text, enrolled_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select up.user_id, up.full_name, up.email, fe.enrolled_at
  from public.formation_enrollments fe
  join public.user_profiles up on up.user_id = fe.user_id
  where fe.path_id = pid
    and fe.withdrawn_at is null
    and (public.is_formation_owner(pid) or public.current_role_is('coordinator'))
  order by fe.enrolled_at;
$$;

-- Iscrizione (o ri-iscrizione dopo un ritiro): unico punto che controlla la scadenza, cosi' non
-- serve duplicarla lato client. Rifiuta se il percorso non e' pubblicato o la scadenza e' passata.
create or replace function public.enroll_in_formation_path(pid bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  p record;
begin
  select status, enrollment_deadline into p from public.formation_paths where id = pid;
  if not found then
    raise exception 'Formation path not found.';
  end if;
  if p.status <> 'published' then
    raise exception 'This path is not open for enrollment.';
  end if;
  if p.enrollment_deadline is not null and current_date > p.enrollment_deadline then
    raise exception 'The enrollment deadline for this path has passed.';
  end if;
  insert into public.formation_enrollments (path_id, user_id, enrolled_at, withdrawn_at)
  values (pid, auth.uid(), now(), null)
  on conflict (path_id, user_id) do update set enrolled_at = now(), withdrawn_at = null;
end;
$$;

-- Ritiro: sempre permesso, nessun controllo sulla scadenza (ritirarsi non e' mai bloccato).
create or replace function public.withdraw_from_formation_path(pid bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.formation_enrollments
  set withdrawn_at = now()
  where path_id = pid and user_id = auth.uid() and withdrawn_at is null;
end;
$$;

select 'tabella formation_enrollments', to_regclass('public.formation_enrollments') is not null as ok
union all select 'funzione formation_enrollment_counts', to_regproc('public.formation_enrollment_counts') is not null
union all select 'funzione formation_enrollees', to_regproc('public.formation_enrollees') is not null
union all select 'funzione enroll_in_formation_path', to_regproc('public.enroll_in_formation_path') is not null
union all select 'funzione withdraw_from_formation_path', to_regproc('public.withdraw_from_formation_path') is not null
union all select 'policy formation_enrollments (1)', (select count(*) = 1 from pg_policies where tablename = 'formation_enrollments');
