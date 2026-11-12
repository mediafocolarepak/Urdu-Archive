-- 141_new_families_course.sql
-- The draft path "Formation Course for New Families" (Owner, 2026-11-12): the same lines as the Gen 2 path (140), for families.
-- Texts chosen by Claude at the Owner's request: modules 1-3 and 5 reuse the texts chosen for the Pre-Volunteers path
-- (137, texts for adults); module 4 and the family modules come from the agents' labels (migration 135), one copy of
-- each text, no defective text, no text in two places.
-- 12 modules in four parts (The Story, The Spirituality, The Families, The Rule), 24 chapters (module 3 has one
-- per point of the spirituality, module 4 two), 109 posts, each linking one Urdu document of the archive.
-- The Rule is the General Statutes only (Owner, 2026-11-12). The archive holds only 33 texts on the family: modules 7,
-- 9 and 11 say in their description what is missing.
-- Status: draft. Nothing is published, nobody is enrolled. Titles are in English; the Urdu ones are the formatore's.
--
-- Owner of the path: the SQL Editor has no signed-in user. With one Admin account, the path is given to it.
-- With more than one, write the owner's email IN THE EDITOR (not in this file) in place of OWNER-EMAIL, in the
-- line that starts with v_email a few lines below (keep the quotes). The account must be an Admin.
-- Running it again does nothing if the path already exists. To remove it:
--   delete from public.formation_paths where title = 'Formation Course for New Families' and status = 'draft';

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

  if exists (select 1 from public.formation_paths where title = 'Formation Course for New Families') then
    raise notice 'The path already exists: nothing done.';
    return;
  end if;

  insert into public.formation_paths (title, description, status, owner_id)
    values ('Formation Course for New Families',
            'A path for families: the story of Chiara and of the Movement, the spirituality of unity, the art of loving and its tools, the seven colours, New Families, the family in God''s plan, the Ideal lived in marriage and in suffering, Chiara''s words to the families, experiences of families, and the General Statutes.',
            'draft', v_owner)
    returning id into v_path;

  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara Lubich', null, 'The Story', 0) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[515, 521, 1025, 1424, 1086, 336]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Ideal and the story of the Movement', null, null, 1) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[565, 590, 546, 42, 288]) with ordinality as x(id, ord)
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
    from unnest(array[382, 383, 333, 370, 8]) with ordinality as x(id, ord)
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
    from unnest(array[701, 767, 768, 845]) with ordinality as x(id, ord)
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
    from unnest(array[294, 526, 337, 356, 445]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Art of Loving and the tools', null, null, 3) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The Art of Loving', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1444, 411, 550, 39]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'The tools of unity', 1) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[313, 303, 437, 431]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The Seven Colours', null, null, 4) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[43, 44, 292, 298, 323]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'How New Families were born', null, 'The Families', 5) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[716, 636, 1518, 652]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The family in God''s plan', 'Draft note: Chiara''s two talks on the family and the education of children (#20, #532) break off after a few lines and are left out. Material from the families or an introduction by the formatore is needed on education.', null, 6) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[525, 1150, 1447, 1260]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Living the Ideal in marriage', null, null, 7) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[653, 1075, 1156, 1158, 1460]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Suffering in the family and Jesus Forsaken', 'Draft note: the archive holds only a few Urdu texts on this. The families'' own experiences or an introduction by the formatore are needed.', null, 8) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[549, 539, 1375]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Chiara to the families and the Family Fest', null, null, 9) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[704, 1082, 1445, 751]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'Experiences of families', 'Draft note: three experiences of families in Pakistan. More can be added by the formatore.', null, 10) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1007, 1553, 622]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
  insert into public.formation_modules (path_id, title, description, part_title, sequence_number)
    values (v_path, 'The General Statutes', 'For the families the General Statutes of the Work of Mary are the Rule (Owner, 2026-11-12).', 'The Rule', 11) returning id into v_module;
  insert into public.formation_chapters (module_id, title, sequence_number)
    values (v_module, 'Readings', 0) returning id into v_chapter;
  insert into public.formation_posts (chapter_id, document_id, title, sequence_number, posted_by)
    select v_chapter, d.document_id, coalesce(nullif(btrim(d.en_title), ''), nullif(btrim(d.title), ''), 'Document ' || d.document_id), x.ord - 1, v_owner
    from unnest(array[1487, 996, 934]) with ordinality as x(id, ord)
    join public.documents d on d.document_id = x.id
    where public.document_is_postable(d.document_id)
    order by x.ord;
end $$;

notify pgrst, 'reload schema';

-- Checks: every row should say true.
with p as (select id, owner_id, status from public.formation_paths where title = 'Formation Course for New Families'),
     m as (select fm.* from public.formation_modules fm join p on p.id = fm.path_id),
     c as (select fc.* from public.formation_chapters fc join m on m.id = fc.module_id),
     t as (select fp.* from public.formation_posts fp join c on c.id = fp.chapter_id)
select 1 as ord, 'one draft path' as what, (select count(*) = 1 from p where status = 'draft') as ok
union all select 2, 'owned by an Admin', (select bool_and(exists (select 1 from public.user_roles r where r.user_id = p.owner_id and r.role = 'admin')) from p)
union all select 3, 'modules (12)', (select count(*) = 12 from m)
union all select 4, 'parts start at modules 1, 3, 6, 12', (select string_agg((sequence_number + 1)::text, ',' order by sequence_number) = '1,3,6,12' from m where part_title is not null)
union all select 5, 'chapters (24)', (select count(*) = 24 from c)
union all select 6, 'posts (109)', (select count(*) = 109 from t)
union all select 7, 'no document posted twice', (select count(distinct document_id) = count(*) from t)
union all select 8, 'the family modules (6 to 11) hold their 23 texts', (select count(*) = 23 from t fp join c on c.id = fp.chapter_id join m on m.id = c.module_id where m.sequence_number between 5 and 10)
order by ord;
