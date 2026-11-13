-- 146_pre_volunteers_tools.sql
-- In the draft path "Formation Course for Pre-Volunteers of God" (137), a new module "The tools of collective spirituality" in the part
-- "The Spirituality", right after "The Seven Colours" (Owner, 2026-11-13), as in the Gen 2 path. One chapter for each
-- tool, in the Owner's order: the pact of mutual love, the personal talk (colloquio), the communion of experiences, the
-- communion of soul, the hour of truth. 12 posts, each linking one Urdu document of the archive, none already in the path.
-- The archive holds no Urdu text on the personal talk: its chapter is left empty and the module's description says
-- so. The modules after it move down by one (The Volunteers part now starts at module 6, The Rule is module 10); their
-- pictures stay theirs. The new module gets its own picture (img/paths/pre-volunteers/tools.svg).
-- The posts are signed by the path's owner, so no email is needed. Run this BEFORE merging the PR. Running it again
-- does nothing if the module already exists. To remove it (the modules after it move back up):
--   see the removal block at the end of this file.

do $$
declare
  v_path bigint;
  v_owner uuid;
  v_colours int;
  v_module bigint;
  v_chapter bigint;
begin
  select id, owner_id into v_path, v_owner from public.formation_paths where title = 'Formation Course for Pre-Volunteers of God';
  if v_path is null then
    raise exception 'The path "Formation Course for Pre-Volunteers of God" was not found (renamed?): nothing done.';
  end if;
  if exists (select 1 from public.formation_modules where path_id = v_path and title = 'The tools of collective spirituality') then
    raise notice 'The module already exists: nothing done.';
    return;
  end if;
  select sequence_number into v_colours from public.formation_modules where path_id = v_path and title = 'The Seven Colours';
  if v_colours is null then
    raise exception 'The module "The Seven Colours" was not found in the path (renamed?): nothing done.';
  end if;

  update public.formation_modules set sequence_number = sequence_number + 1
    where path_id = v_path and sequence_number > v_colours;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number, image_path)
    values (v_path, 'The tools of collective spirituality', 'The five tools of the collective spirituality: the pact of mutual love, the personal talk (colloquio), the communion of experiences, the communion of soul and the hour of truth. Chiara gave a Link-up on each tool in 1994-95: those on the pact (25 August 1994) and on the communion of experiences (27 October 1994) open their chapters. Draft note: her Link-ups on the personal talk, the communion of soul and the hour of truth are not yet in the archive in Urdu; they should be added, and meanwhile the formatore introduces these tools. The archive holds no other Urdu text on the personal talk.', null, v_colours + 1, 'app:img/paths/pre-volunteers/tools.svg')
    returning id into v_module;

  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The pact of mutual love', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[313, 1264, 1359]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The personal talk (colloquio)', 1) returning id into v_chapter;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The communion of experiences', 2) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[303, 431, 579, 1017]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The communion of soul', 3) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[721, 818]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The hour of truth', 4) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[437, 1027, 1008]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
end $$;

notify pgrst, 'reload schema';

-- Checks: every row should say true.
with p as (select id from public.formation_paths where title = 'Formation Course for Pre-Volunteers of God'),
     m as (select fm.* from public.formation_modules fm join p on p.id = fm.path_id),
     t as (select m.title as module_title, fp.* from public.formation_posts fp join public.formation_chapters c on c.id = fp.chapter_id join m on m.id = c.module_id)
select 1 as ord, 'the new module comes right after The Seven Colours' as what,
       (select n.sequence_number = s.sequence_number + 1 from m n, m s where n.title = 'The tools of collective spirituality' and s.title = 'The Seven Colours') as ok
union all select 2, 'it has 5 chapters', (select count(*) = 5 from public.formation_chapters c join m on m.id = c.module_id where m.title = 'The tools of collective spirituality')
union all select 3, 'it has 12 posts', (select count(*) = 12 from t where module_title = 'The tools of collective spirituality')
union all select 4, 'no document twice in the path', (select count(distinct document_id) = count(*) from t)
union all select 5, 'modules are numbered without gaps or repeats', (select count(distinct sequence_number) = count(*) and max(sequence_number) = count(*) - 1 from m)
union all select 6, 'The Volunteers part starts right after the new module', (select v.sequence_number = n.sequence_number + 1 from m v, m n where v.part_title = 'The Volunteers' and n.title = 'The tools of collective spirituality')
order by ord;

-- Removal (run only to undo; the modules after it move back up):
--   do $r$ declare v_path bigint; v_seq int; begin
--     select id into v_path from public.formation_paths where title = 'Formation Course for Pre-Volunteers of God';
--     select sequence_number into v_seq from public.formation_modules where path_id = v_path and title = 'The tools of collective spirituality';
--     delete from public.formation_modules where path_id = v_path and title = 'The tools of collective spirituality';
--     update public.formation_modules set sequence_number = sequence_number - 1 where path_id = v_path and sequence_number > v_seq;
--   end $r$;
