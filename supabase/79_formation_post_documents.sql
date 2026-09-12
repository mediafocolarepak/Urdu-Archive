-- 79_formation_post_documents.sql
-- Fase A di formation_posts (73_formation_paths.sql) gia' prevedeva document_id e il check
-- "documento o testo", ma nessuna interfaccia lo usava - un formatore poteva solo scrivere un
-- post libero dentro un capitolo, mai agganciare un documento dell'archivio come si fa da tempo
-- nelle bacheche (board_posts, 71_boards.sql). Con l'aggiunta di "+ Path" da Dashboard/My Space,
-- il gap di sicurezza gemello di quello risolto in 71 per le bacheche va chiuso anche qui:
-- la RLS di formation_posts_write non controllava che il documento fosse "postabile"
-- (document_is_postable() - versione urdu, non in lavorazione), a differenza di board_posts_insert/
-- update. Nessuna nuova colonna: solo la policy.

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
    (
      current_role_is('coordinator')
      or exists (select 1 from public.formation_chapters c
                   join public.formation_modules m on m.id = c.module_id
                   join public.formation_years y on y.id = m.year_id
                 where c.id = chapter_id and public.is_formation_owner(y.path_id))
    )
    and (document_id is null or public.document_is_postable(document_id))
  );

-- Verifica.
select 'policy formation_posts (2)', (select count(*) = 2 from pg_policies where tablename = 'formation_posts');
