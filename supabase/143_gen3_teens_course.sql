-- 143_gen3_teens_course.sql
-- The draft path "Formation Course for the Gen 3 and Teens" (Owner, 2026-11-12): simple, exciting, full of stories and pictures.
-- Chiara's childhood (illustrated slides), the first companions telling the Gen 3 their adventure in Trent, the Ideal
-- in short talks and stories (God Love, the Word, Jesus Forsaken, Mary, the art of loving), the Gen 3, Chiara's answers
-- to them, and Teens for Unity with Run4Unity in Rawalpindi and Dalwal.
-- 10 modules in three parts (Chiara's story, The Ideal in our life, The Gen 3 and Teens for Unity), 10 chapters,
-- 41 posts, each linking one Urdu document of the archive.
-- Texts chosen by Claude at the Owner's request from the agents' labels (135): texts told to the Gen 3 (a few to the
-- Gen 4), stories and experiences first, long books left out, one copy of each text, no defective text, no text twice.
-- Status: draft. Nothing is published, nobody is enrolled. Titles are in English; the Urdu ones are the formatore's.
--
-- Owner of the path: the SQL Editor has no signed-in user. With one Admin account, the path is given to it.
-- With more than one, write the owner's email IN THE EDITOR (not in this file) in place of OWNER-EMAIL, in the
-- line that starts with v_email a few lines below (keep the quotes). The account must be an Admin.
-- Running it again does nothing if the path already exists. To remove it:
--   delete from public.formation_paths where title = 'Formation Course for the Gen 3 and Teens' and status = 'draft';

do $$
declare
  v_email text := 'OWNER-EMAIL';
  v_owner uuid;
  v_path bigint;
  v_module bigint;
  v_chapter bigint;
  v_admins int;
begin
  if v_email <> 'OWNER-EMAIL' then
    select r.user_id into v_owner from public.user_roles r join auth.users u on u.id = r.user_id
      where r.role = 'admin' and lower(u.email) = lower(btrim(v_email));
    if v_owner is null then
      raise exception 'No Admin account has the email written in v_email: check it and run again.';
    end if;
  else
    select count(*) into v_admins from public.user_roles where role = 'admin';
    if v_admins <> 1 then
      raise exception 'There are % Admin accounts: write the owner''s email in place of OWNER-EMAIL (line v_email, near the top) and run again.', v_admins;
    end if;
    select user_id into v_owner from public.user_roles where role = 'admin';
  end if;

  if exists (select 1 from public.formation_paths where title = 'Formation Course for the Gen 3 and Teens') then
    raise notice 'The path already exists: nothing done.';
    return;
  end if;

  insert into public.formation_paths (title, description, status, owner_id)
    values ('Formation Course for the Gen 3 and Teens',
            'A path for the Gen 3 and teenagers, told in stories: Chiara as a child and the adventure of Trent, God who loves us, the Word lived, Jesus Forsaken our secret, Mary, the art of loving, who the Gen 3 are, Chiara''s answers to them, and Teens for Unity.',
            'draft', v_owner)
    returning id into v_path;

  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara as a child', 'Chiara tells the children the story of her own childhood. The first two texts were written for slides with pictures.', 'Chiara''s story', 0) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[958, 959, 1471]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The adventure begins in Trent', 'The first companions tell the Gen 3 their own adventure in wartime Trent.', null, 1) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1494, 981, 1474, 1090, 950]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'God loves me immensely', null, 'The Ideal in our life', 2) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1468, 1467, 1465]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Living the Word', null, null, 3) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[605, 1022, 988, 1266]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Jesus Forsaken, our secret', null, null, 4) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[507, 949, 1440, 1501]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Mary, our mother', null, null, 5) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1003, 1165, 1002]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The art of loving', null, null, 6) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[678, 503, 1037, 1042, 1442]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Who are the Gen 3', null, 'The Gen 3 and Teens for Unity', 7) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[990, 989, 1528, 1141, 955]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara answers the Gen 3', null, null, 8) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1455, 502, 522]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Teens for Unity: towards a united world', 'Teens for Unity, the Golden Rule and Run4Unity, also in Rawalpindi and Dalwal.', null, 9) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[674, 1233, 1458, 1434, 1031, 1244]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
end $$;

notify pgrst, 'reload schema';

-- Checks: every row should say true.
with p as (select id, owner_id, status from public.formation_paths where title = 'Formation Course for the Gen 3 and Teens'),
     m as (select fm.* from public.formation_modules fm join p on p.id = fm.path_id),
     c as (select fc.* from public.formation_chapters fc join m on m.id = fc.module_id),
     t as (select fp.* from public.formation_posts fp join c on c.id = fp.chapter_id)
select 1 as ord, 'one draft path' as what, (select count(*) = 1 from p where status = 'draft') as ok
union all select 2, 'owned by an Admin', (select bool_and(exists (select 1 from public.user_roles r where r.user_id = p.owner_id and r.role = 'admin')) from p)
union all select 3, 'modules (10)', (select count(*) = 10 from m)
union all select 4, 'parts start at modules 1, 3, 8', (select string_agg((sequence_number + 1)::text, ',' order by sequence_number) = '1,3,8' from m where part_title is not null)
union all select 5, 'chapters (10)', (select count(*) = 10 from c)
union all select 6, 'posts (41)', (select count(*) = 41 from t)
union all select 7, 'no document posted twice', (select count(distinct document_id) = count(*) from t)
union all select 8, 'Teens for Unity module holds its 6 texts', (select count(*) = 6 from t fp join c on c.id = fp.chapter_id join m on m.id = c.module_id where m.sequence_number = 9)
order by ord;
