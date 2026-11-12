-- 145: pictures in formation paths (Owner, 2026-11-13: "add pictures to the posts of the paths, beautiful and different
-- for each path"). A module and a post can now have a picture (image_path), as a path already has its cover
-- (thumbnail_path). The reader shows the post's picture, or else its module's; the path page shows each module's
-- picture at the top of the module. A formatore can upload another one, for a module or for a single post, in the app.
-- The six draft paths get illustrations drawn for them (Documentazione/immagini-percorsi/disegna.mjs, one palette per
-- path and one subject per module) and a cover each. They are files of the app (img/paths/...), written here as
-- "app:img/paths/..."; an uploaded picture is a path in the formation-media bucket, as covers already are.
-- Only empty fields are filled: a cover or a picture already chosen is kept. Run this BEFORE merging the PR.
-- Safe to run again. To remove the drawn pictures only:
--   update public.formation_modules set image_path = null where image_path like 'app:%';
--   update public.formation_paths set thumbnail_path = null where thumbnail_path like 'app:%';

alter table public.formation_modules add column if not exists image_path text;
alter table public.formation_posts add column if not exists image_path text;

-- Formation Course for Pre-Volunteers of God: cover and 9 module pictures.
update public.formation_paths set thumbnail_path = 'app:img/paths/pre-volunteers/cover.svg'
  where title = 'Formation Course for Pre-Volunteers of God' and thumbnail_path is null;
update public.formation_modules m set image_path = 'app:img/paths/pre-volunteers/m' || lpad((m.sequence_number + 1)::text, 2, '0') || '.svg'
  from public.formation_paths p
  where p.id = m.path_id and p.title = 'Formation Course for Pre-Volunteers of God' and m.image_path is null and m.sequence_number between 0 and 8;

-- Formation Course for the Gen 2: cover and 11 module pictures.
update public.formation_paths set thumbnail_path = 'app:img/paths/gen2/cover.svg'
  where title = 'Formation Course for the Gen 2' and thumbnail_path is null;
update public.formation_modules m set image_path = 'app:img/paths/gen2/m' || lpad((m.sequence_number + 1)::text, 2, '0') || '.svg'
  from public.formation_paths p
  where p.id = m.path_id and p.title = 'Formation Course for the Gen 2' and m.image_path is null and m.sequence_number between 0 and 10;

-- Formation Course for New Families: cover and 12 module pictures.
update public.formation_paths set thumbnail_path = 'app:img/paths/families/cover.svg'
  where title = 'Formation Course for New Families' and thumbnail_path is null;
update public.formation_modules m set image_path = 'app:img/paths/families/m' || lpad((m.sequence_number + 1)::text, 2, '0') || '.svg'
  from public.formation_paths p
  where p.id = m.path_id and p.title = 'Formation Course for New Families' and m.image_path is null and m.sequence_number between 0 and 11;

-- Formation Course for Local Community Animators: cover and 8 module pictures.
update public.formation_paths set thumbnail_path = 'app:img/paths/communities/cover.svg'
  where title = 'Formation Course for Local Community Animators' and thumbnail_path is null;
update public.formation_modules m set image_path = 'app:img/paths/communities/m' || lpad((m.sequence_number + 1)::text, 2, '0') || '.svg'
  from public.formation_paths p
  where p.id = m.path_id and p.title = 'Formation Course for Local Community Animators' and m.image_path is null and m.sequence_number between 0 and 7;

-- Formation Course for the Gen 3 and Teens: cover and 12 module pictures.
update public.formation_paths set thumbnail_path = 'app:img/paths/gen3/cover.svg'
  where title = 'Formation Course for the Gen 3 and Teens' and thumbnail_path is null;
update public.formation_modules m set image_path = 'app:img/paths/gen3/m' || lpad((m.sequence_number + 1)::text, 2, '0') || '.svg'
  from public.formation_paths p
  where p.id = m.path_id and p.title = 'Formation Course for the Gen 3 and Teens' and m.image_path is null and m.sequence_number between 0 and 11;

-- Formation Course for the Gen 4 and Children: cover and 13 module pictures.
update public.formation_paths set thumbnail_path = 'app:img/paths/gen4/cover.svg'
  where title = 'Formation Course for the Gen 4 and Children' and thumbnail_path is null;
update public.formation_modules m set image_path = 'app:img/paths/gen4/m' || lpad((m.sequence_number + 1)::text, 2, '0') || '.svg'
  from public.formation_paths p
  where p.id = m.path_id and p.title = 'Formation Course for the Gen 4 and Children' and m.image_path is null and m.sequence_number between 0 and 12;

notify pgrst, 'reload schema';

-- Checks: every row should say true. A path that is missing (renamed or deleted) says false: its pictures are not set.
select 1 as ord, 'picture column on modules' as what, exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'formation_modules' and column_name = 'image_path') as ok
union all select 2, 'picture column on posts', exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'formation_posts' and column_name = 'image_path')
union all select 3, 'Formation Course for Pre-Volunteers of God: 9 module pictures and a cover', (select count(*) = 9 from public.formation_modules m join public.formation_paths p on p.id = m.path_id where p.title = 'Formation Course for Pre-Volunteers of God' and m.image_path like 'app:img/paths/pre-volunteers/%') and exists (select 1 from public.formation_paths where title = 'Formation Course for Pre-Volunteers of God' and thumbnail_path is not null)
union all select 4, 'Formation Course for the Gen 2: 11 module pictures and a cover', (select count(*) = 11 from public.formation_modules m join public.formation_paths p on p.id = m.path_id where p.title = 'Formation Course for the Gen 2' and m.image_path like 'app:img/paths/gen2/%') and exists (select 1 from public.formation_paths where title = 'Formation Course for the Gen 2' and thumbnail_path is not null)
union all select 5, 'Formation Course for New Families: 12 module pictures and a cover', (select count(*) = 12 from public.formation_modules m join public.formation_paths p on p.id = m.path_id where p.title = 'Formation Course for New Families' and m.image_path like 'app:img/paths/families/%') and exists (select 1 from public.formation_paths where title = 'Formation Course for New Families' and thumbnail_path is not null)
union all select 6, 'Formation Course for Local Community Animators: 8 module pictures and a cover', (select count(*) = 8 from public.formation_modules m join public.formation_paths p on p.id = m.path_id where p.title = 'Formation Course for Local Community Animators' and m.image_path like 'app:img/paths/communities/%') and exists (select 1 from public.formation_paths where title = 'Formation Course for Local Community Animators' and thumbnail_path is not null)
union all select 7, 'Formation Course for the Gen 3 and Teens: 12 module pictures and a cover', (select count(*) = 12 from public.formation_modules m join public.formation_paths p on p.id = m.path_id where p.title = 'Formation Course for the Gen 3 and Teens' and m.image_path like 'app:img/paths/gen3/%') and exists (select 1 from public.formation_paths where title = 'Formation Course for the Gen 3 and Teens' and thumbnail_path is not null)
union all select 8, 'Formation Course for the Gen 4 and Children: 13 module pictures and a cover', (select count(*) = 13 from public.formation_modules m join public.formation_paths p on p.id = m.path_id where p.title = 'Formation Course for the Gen 4 and Children' and m.image_path like 'app:img/paths/gen4/%') and exists (select 1 from public.formation_paths where title = 'Formation Course for the Gen 4 and Children' and thumbnail_path is not null)
order by ord;
