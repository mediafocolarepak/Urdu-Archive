-- 140_gen2_course.sql
-- The draft path "Formation Course for the Gen 2" (Owner, 2026-11-12): the same lines as the Pre-Volunteers path (137) for the Gen 2.
-- Module 1 opens with "Jesus Life", Chiara's talk to young people in Spain in August 1989, where she tells the story of
-- the Ideal. Texts chosen by Claude at the Owner's request from the agents' labels (migration 135): texts for young
-- people and Chiara's talks to the Gen first, one copy of each text, no defective text, no text in two places.
-- 11 modules in four parts (The Story, The Spirituality, The Gen, The Rule), 23 chapters (module 3 has one per
-- point of the spirituality, module 4 two), 100 posts, each linking one Urdu document of the archive.
-- "The Art of Loving and the tools" and "The Gen unit" are modules of their own (Owner, 2026-11-12). The Gen have no
-- Regulations: the General Statutes hold for them too (Owner). Module 8 has few texts in Urdu: its description says so.
-- Status: draft. Nothing is published, nobody is enrolled. Titles are in English; the Urdu ones are the formatore's.
--
-- Owner of the path: the SQL Editor has no signed-in user. With one Admin account, the path is given to it.
-- With more than one, write the owner's email IN THE EDITOR (not in this file) in place of OWNER-EMAIL, in the
-- line that starts with v_email a few lines below (keep the quotes). The account must be an Admin.
-- Running it again does nothing if the path already exists. To remove it:
--   delete from public.formation_paths where title = 'Formation Course for the Gen 2' and status = 'draft';

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

  if exists (select 1 from public.formation_paths where title = 'Formation Course for the Gen 2') then
    raise notice 'The path already exists: nothing done.';
    return;
  end if;

  insert into public.formation_paths (title, description, status, owner_id)
    values ('Formation Course for the Gen 2',
            'A path for the Gen 2: the story of Chiara and of the Movement, the spirituality of unity, the art of loving and its tools, the seven colours, the Gen and their unit, Chiara''s words to the Gen and the Genfests, a united world, and the General Statutes.',
            'draft', v_owner)
    returning id into v_path;

  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara Lubich', null, 'The Story', 0) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[536, 548, 529, 1474, 515]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Ideal and the story of the Movement', null, null, 1) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[565, 597, 1089, 1428, 441]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Twelve Points', null, 'The Spirituality', 2) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'God Love', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[516, 3, 7, 1538, 822]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Will of God', 1) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[60, 393, 410, 438, 456]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Word of God', 2) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[518, 509, 677, 454, 810]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Neighbour', 3) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[389, 418, 439, 812]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Mutual Love', 4) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1148, 435, 784]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Eucharist', 5) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[647, 358, 912, 407]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Unity', 6) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[557, 11, 400, 408]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Jesus Forsaken', 7) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[708, 1056, 1093, 336]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Mary', 8) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[693, 1013, 394, 395, 420]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Church', 9) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[649, 416, 419, 845]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Holy Spirit', 10) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[427, 381, 591, 45, 1356]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Jesus in the Midst', 11) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[954, 294, 701]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Art of Loving and the tools', null, null, 3) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Art of Loving', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[39, 1125, 411, 550, 1143]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The tools of unity', 1) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[313, 303, 437, 431, 1008]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Seven Colours', null, null, 4) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[942, 717, 572, 43, 292, 298]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'How the Gen were born', null, 'The Gen', 5) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1493, 511, 530, 713]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Who is a Gen: vocation and life', null, null, 6) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[501, 554, 555, 1015]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Gen unit', 'Draft note: the archive holds only a few Urdu texts on the Gen unit (جین یونٹ). The Gen''s own documents or an introduction by the formatore are needed.', null, 7) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[999, 1010]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara to the Gen and the Genfests', null, null, 8) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[606, 1522, 795, 849]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Towards a united world', null, null, 9) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[568, 595, 705, 715, 1544, 1241]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The General Statutes', 'The Gen have no Regulations of their own: the General Statutes of the Work of Mary hold for them too.', 'The Rule', 10) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1487, 598, 996]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
end $$;

notify pgrst, 'reload schema';

-- Checks: every row should say true.
with p as (select id, owner_id, status from public.formation_paths where title = 'Formation Course for the Gen 2'),
     m as (select fm.* from public.formation_modules fm join p on p.id = fm.path_id),
     c as (select fc.* from public.formation_chapters fc join m on m.id = fc.module_id),
     t as (select fp.* from public.formation_posts fp join c on c.id = fp.chapter_id)
select 1 as ord, 'one draft path' as what, (select count(*) = 1 from p where status = 'draft') as ok
union all select 2, 'owned by an Admin', (select bool_and(exists (select 1 from public.user_roles r where r.user_id = p.owner_id and r.role = 'admin')) from p)
union all select 3, 'modules (11)', (select count(*) = 11 from m)
union all select 4, 'parts start at modules 1, 3, 6, 11', (select string_agg((sequence_number + 1)::text, ',' order by sequence_number) = '1,3,6,11' from m where part_title is not null)
union all select 5, 'chapters (23)', (select count(*) = 23 from c)
union all select 6, 'posts (100)', (select count(*) = 100 from t)
union all select 7, 'no document posted twice', (select count(distinct document_id) = count(*) from t)
union all select 8, 'module 1 opens with Jesus Life (#536)', (select fp.document_id = 536 from t fp join c on c.id = fp.chapter_id join m on m.id = c.module_id where m.sequence_number = 0 and c.sequence_number = 0 and fp.sequence_number = 0)
order by ord;
