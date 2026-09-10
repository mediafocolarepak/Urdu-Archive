-- 72_board_post_reads.sql
-- "Letto" sui post delle bacheche (decisioni prese con Alessandro il 10/09/2026):
--   * marcatura AUTOMATICA alla visualizzazione del post (non un pulsante da cliccare);
--   * tutti vedono un conteggio; solo il formatore di quella bacheca, o Coordinator/Admin,
--     vede l'elenco nominativo di chi ha letto.
--
-- Do dopo 71_boards.sql.

-- 1. La tabella. Una riga per (post, utente), la prima volta che lo vede - non si aggiorna piu'
-- dopo, quindi read_at e' la prima lettura, non l'ultima.
create table if not exists public.board_post_reads (
  post_id bigint      not null references public.board_posts(id) on delete cascade,
  user_id uuid        not null references auth.users(id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index if not exists idx_board_post_reads_post on public.board_post_reads (post_id);

-- 2. RLS: ognuno vede e scrive solo la propria riga - serve solo al client per sapere "l'ho gia'
-- segnato?" senza rifare l'insert. Il conteggio e l'elenco nominativo NON passano da qui: vedono
-- oltre quello che questa policy lascerebbe vedere, tramite le funzioni security definer sotto -
-- stesso schema di is_board_editor()/document_is_postable() in 71_boards.sql.
alter table public.board_post_reads enable row level security;

drop policy if exists "board_post_reads_select" on public.board_post_reads;
create policy "board_post_reads_select" on public.board_post_reads
  for select using (user_id = auth.uid());

drop policy if exists "board_post_reads_insert" on public.board_post_reads;
create policy "board_post_reads_insert" on public.board_post_reads
  for insert with check (user_id = auth.uid());

-- 3. Conteggio - a tutti, nessun dato personale esposto. Prende piu' post in un colpo solo (una
-- bacheca ne mostra parecchi, evita N+1 query per il conteggio).
create or replace function public.board_post_read_counts(post_ids bigint[])
returns table (post_id bigint, read_count integer)
language sql
security definer
stable
set search_path = public
as $$
  select r.post_id, count(*)::integer
  from public.board_post_reads r
  where r.post_id = any(post_ids)
  group by r.post_id;
$$;

-- 4. Elenco nominativo - solo formatore della bacheca del post, o Coordinator/Admin. Se il
-- chiamante non ha il permesso non restituisce un errore ma zero righe: il client semplicemente
-- non offre il pulsante a chi non dovrebbe vederlo, questa e' solo la rete di sicurezza.
create or replace function public.board_post_readers(pid bigint)
returns table (user_id uuid, email text, full_name text, read_at timestamptz)
language sql
security definer
stable
set search_path = public
as $$
  select r.user_id, up.email, up.full_name, r.read_at
  from public.board_post_reads r
  join public.board_posts bp on bp.id = r.post_id
  left join public.user_profiles up on up.user_id = r.user_id
  where r.post_id = pid
    and (public.current_role_is('coordinator') or public.is_board_editor(bp.board_code))
  order by r.read_at desc;
$$;

-- 5. Verifica (esecuzione separata).
select 'tabella board_post_reads' as oggetto, to_regclass('public.board_post_reads') is not null as ok
union all select 'policy (attese 2)', (select count(*) = 2 from pg_policies where tablename = 'board_post_reads')
union all select 'funzione board_post_read_counts', to_regproc('public.board_post_read_counts') is not null
union all select 'funzione board_post_readers', to_regproc('public.board_post_readers') is not null;
