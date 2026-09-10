-- 71_boards.sql
-- Le bacheche formative, Fase 1 del progetto (PROJECT_HANDOFF_v15.md; ragionamento completo in
-- PROJECT_HANDOFF_v14b_bacheche.md). Una bacheca per gruppo, dove i "formatori" pubblicano
-- testi scelti - segnalazioni di documenti dell'archivio, oppure post liberi con un paragrafo
-- intero - e i membri li leggono. Decisioni prese il 10/09/2026:
--   * solo per branca, a livello nazionale (la comunita' locale non esiste nel modello dati);
--   * vocabolario proprio, option list 'board', amministrabile da Options - NON la lista
--     'recipient', che e' un dato d'archivio (a chi il testo fu scritto) e non una scelta
--     editoriale di oggi;
--   * un post puo' esistere senza documento (avvisi, inviti, un pensiero), con un corpo di testo
--     libero anche lungo;
--   * il "letto" arriva dopo, non qui;
--   * nominano i formatori Coordinator e Admin; tutti vedono tutte le bacheche.
--
-- LA SCELTA STRUTTURALE PIU' IMPORTANTE: il permesso di pubblicare e' PER BACHECA
-- (board_editors), non una qualifica globale ne' un nuovo livello di ruolo. Una qualifica
-- globale lascerebbe il formatore dei Gen 3 pubblicare sulla bacheca dei sacerdoti; un nuovo
-- livello nella gerarchia current_role_is() toccherebbe decine di policy per rispondere a una
-- domanda che non ha risposta ("un formatore conta piu' o meno di un operator?").
--
-- Do dopo 70_user_favorites.sql. Consegnare A BLOCCHI, un blocco per esecuzione, e verificare
-- con la query in coda in un'esecuzione separata (v14 §2.1).

-- 1. Le bacheche come option list. Aggiungere 'board' a OPTION_LIST_NAMES / OPTION_LIST_LABELS
-- in core.js (riga ~286) perche' compaia in Options e in State.optionListsByName.board.
-- Etichette in inglese come tutta l'interfaccia; modificabili da Options senza toccare codice.
insert into public.option_lists (list_name, code, label, sort_order) values
  ('board', 'GEN4', 'Children (Gen 4)',      1),
  ('board', 'GEN3', 'Teenagers (Gen 3)',     2),
  ('board', 'GEN2', 'Young people (Gen 2)',  3),
  ('board', 'ADUL', 'Adults',                4),
  ('board', 'FAMI', 'Families',              5),
  ('board', 'SACE', 'Priests',               6)
on conflict (list_name, code) do nothing;

-- 2. Chi puo' pubblicare su quale bacheca.
create table if not exists public.board_editors (
  board_code     text        not null,
  user_id        uuid        not null references auth.users(id) on delete cascade,
  added_by_email text,
  created_at     timestamptz not null default now(),
  primary key (board_code, user_id)
);

-- 3. I post.
create table if not exists public.board_posts (
  id              bigint generated always as identity primary key,
  board_code      text    not null,
  -- nullable: un post puo' essere un avviso senza documento. Se il documento viene cancellato
  -- il post resta, con il suo testo, senza piu' il collegamento.
  document_id     integer references public.documents(document_id) on delete set null,
  title           text    not null,
  -- il paragrafo del formatore, anche lungo, in urdu: nell'interfaccia va reso con dir="auto"
  -- e white-space: pre-wrap, come gia' fatto per ur_title (docdetail.js).
  body            text,
  -- previsti ORA per non precludere i "percorsi formativi": finche' restano null la bacheca e'
  -- una sequenza temporale; valorizzati, un percorso e' "una bacheca con un ordine" invece di
  -- una tabella nuova. Nessuna interfaccia li usa ancora.
  sequence_number integer,
  parent_path_id  bigint references public.board_posts(id) on delete cascade,
  pinned          boolean not null default false,
  -- default auth.uid(): il client non deve (e non puo', vedi policy) dichiarare un autore
  -- diverso da se stesso.
  posted_by       uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  posted_by_email text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  -- un post deve avere ALMENO una delle due cose: un documento o un testo.
  constraint board_posts_has_content check (document_id is not null or (body is not null and btrim(body) <> ''))
);
-- La bacheca, con i fissati in testa e poi dal piu' recente.
create index if not exists idx_board_posts_board_order
  on public.board_posts (board_code, pinned desc, created_at desc);

-- 4. Due funzioni d'appoggio per le policy.
-- security definer perche' devono leggere board_editors e documents a prescindere da cio' che
-- le policy del chiamante gli lascerebbero vedere; set search_path come handle_new_user (05).

-- "Il chiamante e' formatore di questa bacheca?"
create or replace function public.is_board_editor(code text)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.board_editors
                  where board_code = code and user_id = auth.uid());
$$;

-- "Questo documento si puo' mettere in bacheca?" Regola: versione urdu, e non in lavorazione.
-- Con la policy della migrazione 62 gli utenti vedono anche i documenti in ENTR/TYP/PROF/CORR
-- (battitura, bozze, correzione): senza questo filtro la bacheca diventerebbe il canale che
-- espone al pubblico il lavoro non finito. 'revision' / 'pending_publish' / 'removed' sono la
-- pipeline di revisione in corso (migrazioni 45 e 50) e restano fuori per lo stesso motivo.
-- null = documento senza stato (parte dello storico): visibile a tutti, quindi postabile.
create or replace function public.document_is_postable(doc integer)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.documents d
                  where d.document_id = doc
                    and d.language = 'URD'
                    and (d.workflow_status is null
                         or d.workflow_status in ('APPR', 'STOR', 'published')));
$$;

-- 5. updated_at sui post, stesso schema della migrazione 68.
create or replace function public.touch_board_posts()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
drop trigger if exists trg_touch_board_posts on public.board_posts;
create trigger trg_touch_board_posts before update on public.board_posts
  for each row execute function public.touch_board_posts();

-- 6. RLS - board_editors. Ognuno vede le proprie nomine (per sapere su quali bacheche puo'
-- scrivere); Coordinator+ vede e gestisce tutte.
alter table public.board_editors enable row level security;

drop policy if exists "board_editors_select" on public.board_editors;
create policy "board_editors_select" on public.board_editors
  for select using (user_id = auth.uid() or current_role_is('coordinator'));

drop policy if exists "board_editors_insert" on public.board_editors;
create policy "board_editors_insert" on public.board_editors
  for insert with check (current_role_is('coordinator'));

drop policy if exists "board_editors_delete" on public.board_editors;
create policy "board_editors_delete" on public.board_editors
  for delete using (current_role_is('coordinator'));

-- 7. RLS - board_posts. Tutti leggono (e' il servizio per i plain user). Scrive chi e'
-- formatore DI QUELLA bacheca, o Coordinator+. Un formatore modifica e cancella solo i propri
-- post; Coordinator+ anche quelli altrui. Il documento, se c'e', deve essere postabile.
alter table public.board_posts enable row level security;

drop policy if exists "board_posts_select" on public.board_posts;
create policy "board_posts_select" on public.board_posts
  for select using (current_role_is('user'));

drop policy if exists "board_posts_insert" on public.board_posts;
create policy "board_posts_insert" on public.board_posts
  for insert with check (
    posted_by = auth.uid()
    and (current_role_is('coordinator') or public.is_board_editor(board_code))
    and (document_id is null or public.document_is_postable(document_id))
  );

drop policy if exists "board_posts_update" on public.board_posts;
create policy "board_posts_update" on public.board_posts
  for update
  using (current_role_is('coordinator') or (posted_by = auth.uid() and public.is_board_editor(board_code)))
  with check (
    (current_role_is('coordinator') or (posted_by = auth.uid() and public.is_board_editor(board_code)))
    and (document_id is null or public.document_is_postable(document_id))
  );

drop policy if exists "board_posts_delete" on public.board_posts;
create policy "board_posts_delete" on public.board_posts
  for delete using (current_role_is('coordinator') or (posted_by = auth.uid() and public.is_board_editor(board_code)));

-- 8. Verifica (esecuzione separata). Otto righe, tutte true.
select 'option list board (6 voci)' as oggetto, (select count(*) = 6 from public.option_lists where list_name = 'board') as ok
union all select 'tabella board_editors',        to_regclass('public.board_editors') is not null
union all select 'tabella board_posts',          to_regclass('public.board_posts') is not null
union all select 'funzione is_board_editor',     to_regproc('public.is_board_editor') is not null
union all select 'funzione document_is_postable', to_regproc('public.document_is_postable') is not null
union all select 'trigger updated_at',           exists (select 1 from pg_trigger where tgname = 'trg_touch_board_posts')
union all select 'policy board_editors (3)',     (select count(*) = 3 from pg_policies where tablename = 'board_editors')
union all select 'policy board_posts (4)',       (select count(*) = 4 from pg_policies where tablename = 'board_posts');
