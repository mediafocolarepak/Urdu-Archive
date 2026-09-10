-- Percorsi formativi (Fase A - solo gerarchia contenuti, CRUD formatore, lettura pubblica a
-- percorso pubblicato). Vedi discussione in chat del 10/09/2026 per le decisioni di design:
-- un solo formatore proprietario per percorso, ma ogni "formatore" (chi e' editor di almeno
-- una bacheca, is_any_formatore() sotto) puo' leggere anche i percorsi ancora in bozza per
-- poter dare suggerimenti (Fase C, chatroom formatori-only, non ancora costruita).
-- Iscrizione (Fase B), chatroom (Fase C) e quiz/attestato (Fase D) sono migrazioni successive.

-- 1. La testata del percorso.
create table if not exists public.formation_paths (
  id                  bigint generated always as identity primary key,
  title               text    not null,
  -- il "blurb" pubblico nel catalogo - vedi opzione C della discussione: il contenuto e'
  -- sempre leggibile una volta pubblicato, iscriversi serve solo a sbloccare chatroom/quiz/
  -- attestato, non a leggere.
  description         text,
  -- lista option_lists 'formation_audience' (stesso meccanismo generico di recipient/board,
  -- vedi 06_option_lists.sql), non FK - enforcement lato app come le altre liste.
  target_audience     text,
  status              text    not null default 'draft'
                        check (status in ('draft', 'published', 'archived')),
  owner_id            uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  -- entro questa data ci si puo' iscrivere per accedere a chatroom/quiz/attestato del percorso
  -- regolare (ottobre-maggio) o della sessione estiva (giugno-settembre).
  enrollment_deadline date,
  course_starts_at    date,
  course_ends_at      date,
  session_type        text    not null default 'regular' check (session_type in ('regular', 'summer')),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- 2. Anni (un percorso puo' durare piu' anni).
create table if not exists public.formation_years (
  id              bigint generated always as identity primary key,
  path_id         bigint  not null references public.formation_paths(id) on delete cascade,
  year_number     integer not null,
  sequence_number integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists idx_formation_years_path on public.formation_years (path_id, sequence_number);

-- 3. Moduli dentro un anno.
create table if not exists public.formation_modules (
  id              bigint generated always as identity primary key,
  year_id         bigint  not null references public.formation_years(id) on delete cascade,
  title           text    not null,
  description     text,
  sequence_number integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists idx_formation_modules_year on public.formation_modules (year_id, sequence_number);

-- 4. Capitoli dentro un modulo.
create table if not exists public.formation_chapters (
  id              bigint generated always as identity primary key,
  module_id       bigint  not null references public.formation_modules(id) on delete cascade,
  title           text    not null,
  sequence_number integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists idx_formation_chapters_module on public.formation_chapters (module_id, sequence_number);

-- 5. I post dentro un capitolo - stessa forma di board_posts (71), ma agganciati al capitolo
-- invece che a una bacheca fissa.
create table if not exists public.formation_posts (
  id              bigint generated always as identity primary key,
  chapter_id      bigint  not null references public.formation_chapters(id) on delete cascade,
  document_id     integer references public.documents(document_id) on delete set null,
  title           text    not null,
  body            text,
  sequence_number integer not null default 0,
  posted_by       uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint formation_posts_has_content check (document_id is not null or (body is not null and btrim(body) <> ''))
);
create index if not exists idx_formation_posts_chapter on public.formation_posts (chapter_id, sequence_number);

-- 6. Funzioni d'appoggio per le policy - stesso schema di is_board_editor()/document_is_postable()
-- in 71_boards.sql: security definer perche' devono leggere tabelle a prescindere da cosa le
-- policy del chiamante gli lascerebbero vedere.

-- "Il chiamante e' formatore di ALMENO una bacheca?" - definizione di "formatore" gia' in uso
-- nell'app (chi ha un ruolo di editor su una board), qui estesa: chiunque sia formatore da
-- qualche parte puo' leggere (non modificare) anche i percorsi altrui ancora in bozza, per
-- poterne discutere nella chatroom formatori-only (Fase C).
create or replace function public.is_any_formatore()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.board_editors where user_id = auth.uid());
$$;

-- "Il chiamante e' il proprietario di questo percorso?"
create or replace function public.is_formation_owner(pid bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.formation_paths
                  where id = pid and owner_id = auth.uid());
$$;

-- 7. updated_at sulle 5 tabelle - una sola funzione condivisa, a differenza di board_posts/
-- document_texts (una tabella a testa) perche' qui nascono tutte insieme nella stessa migrazione.
create or replace function public.touch_formation_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_touch_formation_paths on public.formation_paths;
create trigger trg_touch_formation_paths before update on public.formation_paths
  for each row execute function public.touch_formation_updated_at();
drop trigger if exists trg_touch_formation_years on public.formation_years;
create trigger trg_touch_formation_years before update on public.formation_years
  for each row execute function public.touch_formation_updated_at();
drop trigger if exists trg_touch_formation_modules on public.formation_modules;
create trigger trg_touch_formation_modules before update on public.formation_modules
  for each row execute function public.touch_formation_updated_at();
drop trigger if exists trg_touch_formation_chapters on public.formation_chapters;
create trigger trg_touch_formation_chapters before update on public.formation_chapters
  for each row execute function public.touch_formation_updated_at();
drop trigger if exists trg_touch_formation_posts on public.formation_posts;
create trigger trg_touch_formation_posts before update on public.formation_posts
  for each row execute function public.touch_formation_updated_at();

-- 8. RLS. Regola di lettura uniforme sulle 5 tabelle: un percorso pubblicato e' leggibile da
-- chiunque (opzione C - il contenuto e' sempre pubblico una volta pubblicato); una bozza e'
-- leggibile solo dal proprietario, da Coordinator/Admin, o da un qualunque altro formatore
-- (per dare suggerimenti). Scrittura: solo il proprietario o Coordinator/Admin (oversight),
-- stesso schema di board_posts.

alter table public.formation_paths   enable row level security;
alter table public.formation_years   enable row level security;
alter table public.formation_modules enable row level security;
alter table public.formation_chapters enable row level security;
alter table public.formation_posts   enable row level security;

drop policy if exists "formation_paths_select" on public.formation_paths;
create policy "formation_paths_select" on public.formation_paths
  for select using (
    current_role_is('user') and (
      status = 'published'
      or owner_id = auth.uid()
      or current_role_is('coordinator')
      or public.is_any_formatore()
    )
  );
drop policy if exists "formation_paths_insert" on public.formation_paths;
create policy "formation_paths_insert" on public.formation_paths
  for insert with check (owner_id = auth.uid() and public.is_any_formatore());
drop policy if exists "formation_paths_update" on public.formation_paths;
create policy "formation_paths_update" on public.formation_paths
  for update using (owner_id = auth.uid() or current_role_is('coordinator'))
  with check (owner_id = auth.uid() or current_role_is('coordinator'));
drop policy if exists "formation_paths_delete" on public.formation_paths;
create policy "formation_paths_delete" on public.formation_paths
  for delete using (owner_id = auth.uid() or current_role_is('coordinator'));

drop policy if exists "formation_years_select" on public.formation_years;
create policy "formation_years_select" on public.formation_years
  for select using (
    exists (select 1 from public.formation_paths p where p.id = path_id
      and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
drop policy if exists "formation_years_write" on public.formation_years;
create policy "formation_years_write" on public.formation_years
  for all using (public.is_formation_owner(path_id) or current_role_is('coordinator'))
  with check (public.is_formation_owner(path_id) or current_role_is('coordinator'));

drop policy if exists "formation_modules_select" on public.formation_modules;
create policy "formation_modules_select" on public.formation_modules
  for select using (
    exists (select 1 from public.formation_years y join public.formation_paths p on p.id = y.path_id
      where y.id = year_id
      and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
drop policy if exists "formation_modules_write" on public.formation_modules;
create policy "formation_modules_write" on public.formation_modules
  for all using (
    current_role_is('coordinator')
    or exists (select 1 from public.formation_years y where y.id = year_id and public.is_formation_owner(y.path_id))
  )
  with check (
    current_role_is('coordinator')
    or exists (select 1 from public.formation_years y where y.id = year_id and public.is_formation_owner(y.path_id))
  );

drop policy if exists "formation_chapters_select" on public.formation_chapters;
create policy "formation_chapters_select" on public.formation_chapters
  for select using (
    exists (select 1 from public.formation_modules m
              join public.formation_years y on y.id = m.year_id
              join public.formation_paths p on p.id = y.path_id
            where m.id = module_id
            and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
drop policy if exists "formation_chapters_write" on public.formation_chapters;
create policy "formation_chapters_write" on public.formation_chapters
  for all using (
    current_role_is('coordinator')
    or exists (select 1 from public.formation_modules m join public.formation_years y on y.id = m.year_id
                where m.id = module_id and public.is_formation_owner(y.path_id))
  )
  with check (
    current_role_is('coordinator')
    or exists (select 1 from public.formation_modules m join public.formation_years y on y.id = m.year_id
                where m.id = module_id and public.is_formation_owner(y.path_id))
  );

drop policy if exists "formation_posts_select" on public.formation_posts;
create policy "formation_posts_select" on public.formation_posts
  for select using (
    exists (select 1 from public.formation_chapters c
              join public.formation_modules m on m.id = c.module_id
              join public.formation_years y on y.id = m.year_id
              join public.formation_paths p on p.id = y.path_id
            where c.id = chapter_id
            and (p.status = 'published' or p.owner_id = auth.uid() or current_role_is('coordinator') or public.is_any_formatore()))
  );
drop policy if exists "formation_posts_write" on public.formation_posts;
create policy "formation_posts_write" on public.formation_posts
  for all using (
    current_role_is('coordinator')
    or exists (select 1 from public.formation_chapters c
                 join public.formation_modules m on m.id = c.module_id
                 join public.formation_years y on y.id = m.year_id
               where c.id = chapter_id and public.is_formation_owner(y.path_id))
  )
  with check (
    current_role_is('coordinator')
    or exists (select 1 from public.formation_chapters c
                 join public.formation_modules m on m.id = c.module_id
                 join public.formation_years y on y.id = m.year_id
               where c.id = chapter_id and public.is_formation_owner(y.path_id))
  );

-- 9. Lista opzioni per l'utenza del percorso - stesso meccanismo generico di 06_option_lists.sql.
-- Valori di partenza, editabili da Options come tutte le altre liste.
insert into option_lists (list_name, code, label, sort_order) values
  ('formation_audience', 'GA', 'Young leaders', 1),
  ('formation_audience', 'GEN2', 'Gen2', 2),
  ('formation_audience', 'GEN3', 'Gen3', 3),
  ('formation_audience', 'FOCL', 'Focolarini in training', 4),
  ('formation_audience', 'ALTR', 'Other', 5)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

-- 10. Verifica.
select 'tabella formation_paths',    to_regclass('public.formation_paths')    is not null as ok
union all select 'tabella formation_years',    to_regclass('public.formation_years')    is not null
union all select 'tabella formation_modules',  to_regclass('public.formation_modules')  is not null
union all select 'tabella formation_chapters', to_regclass('public.formation_chapters') is not null
union all select 'tabella formation_posts',    to_regclass('public.formation_posts')    is not null
union all select 'funzione is_any_formatore',  to_regproc('public.is_any_formatore')    is not null
union all select 'funzione is_formation_owner',to_regproc('public.is_formation_owner')  is not null
union all select 'policy formation_paths (4)', (select count(*) = 4 from pg_policies where tablename = 'formation_paths')
union all select 'option_lists formation_audience seed', (select count(*) = 5 from option_lists where list_name = 'formation_audience');
