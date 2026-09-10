-- 70_user_favorites.sql
-- "My Space", Fase 0 del progetto bacheche (PROJECT_HANDOFF_v15.md): i preferiti personali.
-- Un utente segna un documento con una stella e lo ritrova in una lista sua. Nient'altro.
--
-- E' la funzione piu' semplice del progetto e probabilmente quella che i plain user useranno di
-- piu' - e libera il nome "My Space" per il verso giusto: uno spazio PERSONALE, non una bacheca
-- di gruppo curata da altri (quella e' la Fase 1, migrazione 71).
--
-- I preferiti sono privati: nessuno, nemmeno l'Admin, vede quelli di un altro attraverso le
-- policy. Non c'e' un motivo di servizio per cui dovrebbe, e la lista di cosa una persona salva
-- per la propria formazione e' affar suo.
--
-- Do dopo 69_protect_reviewed_texts.sql. Consegnare A BLOCCHI (vedi v14 §2.1) e verificare con
-- la query in coda in un'esecuzione separata.

-- 1. La tabella.
create table if not exists public.user_favorites (
  user_id     uuid        not null references auth.users(id) on delete cascade,
  document_id integer     not null references public.documents(document_id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, document_id)
);
-- La lista di un utente, dal piu' recente.
create index if not exists idx_user_favorites_user_recent
  on public.user_favorites (user_id, created_at desc);

-- 2. RLS: ognuno vede e gestisce solo i propri. current_role_is('user') sull'insert e' la stessa
-- soglia minima delle altre tabelle - esclude un account autenticato senza riga in user_roles.
alter table public.user_favorites enable row level security;

drop policy if exists "user_favorites_select" on public.user_favorites;
create policy "user_favorites_select" on public.user_favorites
  for select using (user_id = auth.uid());

drop policy if exists "user_favorites_insert" on public.user_favorites;
create policy "user_favorites_insert" on public.user_favorites
  for insert with check (user_id = auth.uid() and current_role_is('user'));

drop policy if exists "user_favorites_delete" on public.user_favorites;
create policy "user_favorites_delete" on public.user_favorites
  for delete using (user_id = auth.uid());

-- 3. Verifica (esecuzione separata).
select 'user_favorites' as oggetto, to_regclass('public.user_favorites') is not null as esiste
union all
select 'policy (attese 3)', (select count(*) = 3 from pg_policies where tablename = 'user_favorites');
