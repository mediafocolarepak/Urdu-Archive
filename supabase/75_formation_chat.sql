-- Percorsi formativi (Fase C: chatroom). Due canali per percorso, decisi in chat il 10/09/2026:
-- - 'students': chi e' iscritto (formation_enrollments, withdrawn_at is null) + il proprietario
--   + Coordinator/Admin - per domande/contributi durante il percorso.
-- - 'formatori': un qualunque formatore (is_any_formatore, 73_formation_paths.sql), anche di
--   un altro gruppo, + Coordinator/Admin - per suggerire cambiamenti/miglioramenti al
--   proprietario, visibile SOLO ai formatori (mai agli iscritti). Funziona anche su un percorso
--   ancora in bozza, cosi' il confronto puo' avvenire prima della pubblicazione.
-- Una sola tabella con una colonna 'channel', non due tabelle: stessa forma, regole diverse.

create table if not exists public.formation_chat_messages (
  id           bigint generated always as identity primary key,
  path_id      bigint  not null references public.formation_paths(id) on delete cascade,
  channel      text    not null check (channel in ('students', 'formatori')),
  user_id      uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  user_email   text,
  message_text text    not null check (btrim(message_text) <> ''),
  created_at   timestamptz not null default now()
);
create index if not exists idx_formation_chat_path_channel on public.formation_chat_messages (path_id, channel, created_at);

alter table public.formation_chat_messages enable row level security;

-- "Il chiamante e' iscritto (attivo) a questo percorso?" - stesso schema di is_board_editor()/
-- is_formation_owner() in 71/73.
create or replace function public.formation_is_enrolled(pid bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.formation_enrollments
                  where path_id = pid and user_id = auth.uid() and withdrawn_at is null);
$$;

drop policy if exists "formation_chat_select" on public.formation_chat_messages;
create policy "formation_chat_select" on public.formation_chat_messages
  for select using (
    (channel = 'students' and (public.formation_is_enrolled(path_id) or public.is_formation_owner(path_id) or public.current_role_is('coordinator')))
    or
    (channel = 'formatori' and (public.is_any_formatore() or public.current_role_is('coordinator')))
  );

drop policy if exists "formation_chat_insert" on public.formation_chat_messages;
create policy "formation_chat_insert" on public.formation_chat_messages
  for insert with check (
    user_id = auth.uid()
    and (
      (channel = 'students' and (public.formation_is_enrolled(path_id) or public.is_formation_owner(path_id) or public.current_role_is('coordinator')))
      or
      (channel = 'formatori' and (public.is_any_formatore() or public.current_role_is('coordinator')))
    )
  );

-- Cancellazione: il proprio messaggio, o Coordinator/Admin per moderazione - stesso schema
-- della delete su board_posts (71_boards.sql).
drop policy if exists "formation_chat_delete" on public.formation_chat_messages;
create policy "formation_chat_delete" on public.formation_chat_messages
  for delete using (user_id = auth.uid() or public.current_role_is('coordinator'));

select 'tabella formation_chat_messages', to_regclass('public.formation_chat_messages') is not null as ok
union all select 'funzione formation_is_enrolled', to_regproc('public.formation_is_enrolled') is not null
union all select 'policy formation_chat_messages (3)', (select count(*) = 3 from pg_policies where tablename = 'formation_chat_messages');
