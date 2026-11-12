-- 144_gen4_children_course.sql
-- The draft path "Formation Course for the Gen 4 and Children" (Owner, 2026-11-12): made for children, rich in pictures, stories
-- and tales from the Bible, the Gospel and of children. Bible stories with slides (creation, Noah, Abraham, Moses, the
-- Ten Commandments), Jesus (Christmas, the illustrated Gen 4 Word of Life, Jesus among us, Mary), Chiara as the first
-- Gen 4 (slides and short plays of her childhood, her friends' stories, her answers to the Gen 4), and the Gen 4 (the
-- art of loving, games from the Rawalpindi congresses, stories of children).
-- 13 modules in four parts (Stories of the Bible, Jesus our friend, Chiara the first Gen 4, We are Gen 4),
-- 13 chapters, 50 posts, each linking one Urdu document of the archive.
-- Texts chosen by Claude at the Owner's request from the agents' labels (135): texts made for the Gen 4 and young
-- children, slides and illustrated texts first, one copy of each text, no defective text, no text twice.
-- Status: draft. Nothing is published, nobody is enrolled. Titles are in English; the Urdu ones are the formatore's.
--
-- Owner of the path: the SQL Editor has no signed-in user. With one Admin account, the path is given to it.
-- With more than one, write the owner's email IN THE EDITOR (not in this file) in place of OWNER-EMAIL, in the
-- line that starts with v_email a few lines below (keep the quotes). The account must be an Admin.
-- Running it again does nothing if the path already exists. To remove it:
--   delete from public.formation_paths where title = 'Formation Course for the Gen 4 and Children' and status = 'draft';

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

  if exists (select 1 from public.formation_paths where title = 'Formation Course for the Gen 4 and Children') then
    raise notice 'The path already exists: nothing done.';
    return;
  end if;

  insert into public.formation_paths (title, description, status, owner_id)
    values ('Formation Course for the Gen 4 and Children',
            'A path for the Gen 4 and children, told in stories and pictures: the Bible from creation to Moses, Jesus our friend and Mary, Chiara the first Gen 4, the art of loving, games and stories of children.',
            'draft', v_owner)
    returning id into v_path;

  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'God creates the world', 'The story of creation told with slides, a short chapter and a script with music and questions.', 'Stories of the Bible', 0) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[960, 700, 1083]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Noah and Abraham', null, null, 1) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[963, 696, 697]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Moses and God''s people', 'Moses, the desert and the Ten Commandments, with slides.', null, 2) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[961, 698, 962, 957]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Jesus is born', 'Christmas: a message and songs for the Gen 4, one of them in Urdu.', 'Jesus, our friend', 3) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[643, 1482, 1050]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Jesus teaches us to love', 'The Gen 4 Word of Life: a short story of a child who lives it each month, some of them illustrated.', null, 4) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1534, 1556, 1557, 1535, 1536, 1053]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Jesus among us and Jesus Forsaken', null, null, 5) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1047, 1055, 504]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Mary, our mother', null, null, 6) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[26, 1003, 544, 1449]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara as a child', 'Chiara was the first Gen 4. Slides where she tells her own childhood, and four short plays the children can act.', 'Chiara, the first Gen 4', 7) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[958, 959, 620, 626, 625, 632]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara''s friends tell their story', null, null, 8) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1090, 983]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara talks with the Gen 4', null, null, 9) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[600, 688, 1037, 1245]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The art of loving', null, 'We are Gen 4', 10) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1115, 665, 1061, 1272]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Games and feasts', 'Games from the Gen 4 congresses in Rawalpindi, the Ideal game and the Gen 4 pact.', null, 11) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1265, 952, 1070, 1084]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Stories of children', null, null, 12) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1035, 1136, 1470, 1142]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
end $$;

notify pgrst, 'reload schema';

-- Checks: every row should say true.
with p as (select id, owner_id, status from public.formation_paths where title = 'Formation Course for the Gen 4 and Children'),
     m as (select fm.* from public.formation_modules fm join p on p.id = fm.path_id),
     c as (select fc.* from public.formation_chapters fc join m on m.id = fc.module_id),
     t as (select fp.* from public.formation_posts fp join c on c.id = fp.chapter_id)
select 1 as ord, 'one draft path' as what, (select count(*) = 1 from p where status = 'draft') as ok
union all select 2, 'owned by an Admin', (select bool_and(exists (select 1 from public.user_roles r where r.user_id = p.owner_id and r.role = 'admin')) from p)
union all select 3, 'modules (13)', (select count(*) = 13 from m)
union all select 4, 'parts start at modules 1, 4, 8, 11', (select string_agg((sequence_number + 1)::text, ',' order by sequence_number) = '1,4,8,11' from m where part_title is not null)
union all select 5, 'chapters (13)', (select count(*) = 13 from c)
union all select 6, 'posts (50)', (select count(*) = 50 from t)
union all select 7, 'no document posted twice', (select count(distinct document_id) = count(*) from t)
union all select 8, 'the Bible stories (modules 1 to 3) hold their 10 texts', (select count(*) = 10 from t fp join c on c.id = fp.chapter_id join m on m.id = c.module_id where m.sequence_number <= 2)
order by ord;
