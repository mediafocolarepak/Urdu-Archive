-- 142_community_animators_course.sql
-- The draft path "Formation Course for Local Community Animators" (Owner, 2026-11-12). The first community, the archetype, is Trent
-- when the focolare was born: module 1 opens with "Jesus Life" (#536, Spain 1989) and Chiara at Bologna (1997), then the
-- first companions' experiences, the twelve points, the art of loving (without the tools), what a local community is,
-- Jesus in the midst, the animator who serves, and leading a group meeting.
-- 8 modules in four parts (The first community: Trent, The Spirituality, The local community, Leading a community group),
-- 19 chapters (module 3 has one per point of the spirituality), 87 posts, each linking one Urdu document of the archive.
-- Texts chosen by Claude at the Owner's request: module 3 reuses the Pre-Volunteers texts (137) with two swaps; the
-- others come from the agents' labels (135) and a search for "local community" in the Urdu texts. One copy of each text,
-- no defective text, no text in two places. Modules 5, 7 and 8 have few texts: their description says what is missing.
-- Status: draft. Nothing is published, nobody is enrolled. Titles are in English; the Urdu ones are the formatore's.
--
-- Owner of the path: the SQL Editor has no signed-in user. With one Admin account, the path is given to it.
-- With more than one, write the owner's email IN THE EDITOR (not in this file) in place of OWNER-EMAIL, in the
-- line that starts with v_email a few lines below (keep the quotes). The account must be an Admin.
-- Running it again does nothing if the path already exists. To remove it:
--   delete from public.formation_paths where title = 'Formation Course for Local Community Animators' and status = 'draft';

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

  if exists (select 1 from public.formation_paths where title = 'Formation Course for Local Community Animators') then
    raise notice 'The path already exists: nothing done.';
    return;
  end if;

  insert into public.formation_paths (title, description, status, owner_id)
    values ('Formation Course for Local Community Animators',
            'A path for those who animate a local community: Trent, the first community, and the experiences of the first times; the twelve points and the art of loving; what a local community is and Jesus in the midst, its soul; the animator who serves and how to lead a group meeting.',
            'draft', v_owner)
    returning id into v_path;

  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara and the birth of the focolare', 'Trent, where the focolare was born, is the first community, the archetype of every local community. Chiara tells its story to young people in Spain (1989) and at Bologna city hall (1997).', 'The first community: Trent', 0) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[536, 546, 565, 302]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Experiences of the first times', 'Some of these experiences were told to the Gen 3 and Gen 4: short and simple, but in the first companions'' own words.', null, 1) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1474, 1089, 1428, 29, 30]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Twelve Points', null, 'The Spirituality', 2) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'God Love', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[41, 330, 331, 348, 355]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Will of God', 1) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[38, 57, 58, 342, 368]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Word of God', 2) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[9, 624, 627, 531, 341]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Neighbour', 3) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[389, 418, 581, 553, 299]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Mutual Love', 4) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[382, 383, 333, 370, 849]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Eucharist', 5) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[358, 552, 633, 861, 912]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Unity', 6) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[40, 293, 335, 365, 527]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Jesus Forsaken', 7) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[24, 300, 305, 317, 325]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Mary', 8) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[533, 387, 386, 435, 438]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Church', 9) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[649, 767, 768, 845]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Holy Spirit', 10) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[381, 591, 427, 45, 53]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Jesus in the Midst', 11) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[294, 337, 356, 445]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Art of Loving', null, null, 3) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[535, 411, 550, 1125]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'What is a local community', 'Draft note: the archive holds only a few Urdu texts on the local community. The General Statutes define it; Emmaus calls it a diamond with many facets. An introduction by the formatore is needed.', 'The local community', 4) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1487, 1000, 801, 1355, 454, 1256]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Jesus in the midst, the soul of the community', null, null, 5) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[701, 999, 437]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The animator who serves', 'Draft note: the archive holds only a few Urdu texts on animating a community. An introduction by the formatore is needed.', 'Leading a community group', 6) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[52, 526, 652, 486]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Leading a group meeting', 'Draft note: how to lead a group meeting (Gospel experiences rather than ideas, the Word of Life, Jesus in the midst at the start, groups of 10 to 15) is outlined in the Group leader''s supplement of "Called to be Community" (Living City, 2014). It is copyrighted: the formatore writes this text in their own words, or permission to translate it is asked first.', null, 7) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[509, 303, 431]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
end $$;

notify pgrst, 'reload schema';

-- Checks: every row should say true.
with p as (select id, owner_id, status from public.formation_paths where title = 'Formation Course for Local Community Animators'),
     m as (select fm.* from public.formation_modules fm join p on p.id = fm.path_id),
     c as (select fc.* from public.formation_chapters fc join m on m.id = fc.module_id),
     t as (select fp.* from public.formation_posts fp join c on c.id = fp.chapter_id)
select 1 as ord, 'one draft path' as what, (select count(*) = 1 from p where status = 'draft') as ok
union all select 2, 'owned by an Admin', (select bool_and(exists (select 1 from public.user_roles r where r.user_id = p.owner_id and r.role = 'admin')) from p)
union all select 3, 'modules (8)', (select count(*) = 8 from m)
union all select 4, 'parts start at modules 1, 3, 5, 7', (select string_agg((sequence_number + 1)::text, ',' order by sequence_number) = '1,3,5,7' from m where part_title is not null)
union all select 5, 'chapters (19)', (select count(*) = 19 from c)
union all select 6, 'posts (87)', (select count(*) = 87 from t)
union all select 7, 'no document posted twice', (select count(distinct document_id) = count(*) from t)
union all select 8, 'module 1 opens with Jesus Life (#536), the community and leading modules hold their 16 texts', (select (select fp.document_id = 536 from t fp join c on c.id = fp.chapter_id join m on m.id = c.module_id where m.sequence_number = 0 and fp.sequence_number = 0) and (select count(*) = 16 from t fp join c on c.id = fp.chapter_id join m on m.id = c.module_id where m.sequence_number >= 4))
order by ord;
