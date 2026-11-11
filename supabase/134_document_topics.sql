-- 134: topic labels on archive documents (Owner's request, 2026-11-09). Agents read every Urdu text a formation path
-- can link and gave each the topics it really treats, with the passage that shows it (copied word for word and checked
-- against the text), who it is written for, and a one-sentence English summary. They feed "Find texts" when a formatore
-- builds a path, and the Pre-Volunteers path. The labels themselves are an option list ('doc_topic'), editable in
-- Options like the others. Structure only: the data comes in 135_document_topics_data_*.sql.
-- Run this BEFORE merging the PR. Safe to run again.

-- 1. A document's topics. relevance: 3 = main subject, 2 = a substantial part, 1 = present but brief.
create table if not exists public.document_topics (
  document_id integer     not null references public.documents(document_id) on delete cascade,
  topic       text        not null,
  relevance   smallint    not null check (relevance between 1 and 3),
  passage     text,
  source      text        not null default 'ai' check (source in ('ai', 'person')),
  reviewed    boolean     not null default false,
  created_at  timestamptz not null default now(),
  primary key (document_id, topic)
);
create index if not exists idx_document_topics_topic on public.document_topics (topic, relevance desc);

-- 2. Who the text is for and what it is about, one row per document.
create table if not exists public.document_profiles (
  document_id integer     primary key references public.documents(document_id) on delete cascade,
  audience    text        check (audience in ('ADULTS', 'YOUTH', 'CHILDREN', 'ALL')),
  summary_en  text,
  source      text        not null default 'ai' check (source in ('ai', 'person')),
  created_at  timestamptz not null default now()
);

-- 3. Read by whoever can read the document itself (the documents table's own rules decide, reserved included);
-- written by Admins only.
alter table public.document_topics   enable row level security;
alter table public.document_profiles enable row level security;

drop policy if exists "document_topics_select" on public.document_topics;
create policy "document_topics_select" on public.document_topics
  for select using (exists (select 1 from public.documents d where d.document_id = document_topics.document_id));
drop policy if exists "document_topics_write" on public.document_topics;
create policy "document_topics_write" on public.document_topics
  for all using (public.current_role_is('admin')) with check (public.current_role_is('admin'));

drop policy if exists "document_profiles_select" on public.document_profiles;
create policy "document_profiles_select" on public.document_profiles
  for select using (exists (select 1 from public.documents d where d.document_id = document_profiles.document_id));
drop policy if exists "document_profiles_write" on public.document_profiles;
create policy "document_profiles_write" on public.document_profiles
  for all using (public.current_role_is('admin')) with check (public.current_role_is('admin'));

-- 4. The labels, as an option list.
insert into public.option_lists (list_name, code, label, sort_order) values
  ('doc_topic', 'CHIARA', 'Chiara Lubich: her life and person', 1),
  ('doc_topic', 'HISTORY', 'History of the Movement (Trent, the beginnings, its spread)', 2),
  ('doc_topic', 'IDEAL', 'The Ideal: the spirituality of unity as a whole', 3),
  ('doc_topic', 'P01_GOD_LOVE', 'God Love', 4),
  ('doc_topic', 'P02_WILL', 'The Will of God', 5),
  ('doc_topic', 'P03_WORD', 'The Word of God', 6),
  ('doc_topic', 'P04_NEIGHBOUR', 'The neighbour', 7),
  ('doc_topic', 'P05_MUTUAL', 'Mutual love (the new commandment)', 8),
  ('doc_topic', 'P06_EUCHARIST', 'The Eucharist', 9),
  ('doc_topic', 'P07_UNITY', 'Unity', 10),
  ('doc_topic', 'P08_FORSAKEN', 'Jesus Forsaken', 11),
  ('doc_topic', 'P09_MARY', 'Mary', 12),
  ('doc_topic', 'P10_CHURCH', 'The Church', 13),
  ('doc_topic', 'P11_SPIRIT', 'The Holy Spirit', 14),
  ('doc_topic', 'P12_MIDST', 'Jesus in the midst', 15),
  ('doc_topic', 'COLOURS', 'The seven colours: origin and the whole', 16),
  ('doc_topic', 'C_RED', 'Red: communion of goods, economy, work', 17),
  ('doc_topic', 'C_ORANGE', 'Orange: witness and spreading', 18),
  ('doc_topic', 'C_YELLOW', 'Yellow: spiritual life, prayer, formation', 19),
  ('doc_topic', 'C_GREEN', 'Green: physical life, nature, health', 20),
  ('doc_topic', 'C_BLUE', 'Blue: harmony, environment, beauty', 21),
  ('doc_topic', 'C_INDIGO', 'Indigo: wisdom, study', 22),
  ('doc_topic', 'C_VIOLET', 'Violet: unity, communications', 23),
  ('doc_topic', 'VOLUNTEERS', 'Volunteers: vocation and life', 24),
  ('doc_topic', 'VOL_HISTORY', 'Volunteers: how the branch was born', 25),
  ('doc_topic', 'NUCLEUS', 'The nucleus', 26),
  ('doc_topic', 'STATUTES', 'Statutes and rules of a branch', 27),
  ('doc_topic', 'GEN', 'Gen and young people', 28),
  ('doc_topic', 'FAMILIES', 'Families (New Families)', 29),
  ('doc_topic', 'FOCOLARINI', 'Focolarini and the focolare', 30),
  ('doc_topic', 'CLERGY', 'Priests, religious and bishops', 31),
  ('doc_topic', 'ART_OF_LOVING', 'The art of loving', 32),
  ('doc_topic', 'COMMUNION', 'Communion: of soul, of experiences, the hour of truth', 33),
  ('doc_topic', 'SUFFERING', 'Suffering, illness, death', 34),
  ('doc_topic', 'PRAYER', 'Prayer', 35),
  ('doc_topic', 'DIALOGUE', 'Dialogue: ecumenical, with other religions, with all', 36),
  ('doc_topic', 'SOCIETY', 'Living the Ideal in society and at work', 37),
  ('doc_topic', 'WORK_OF_MARY', 'The Work of Mary (Opera di Maria): the Movement as a whole, its centre, zones and structure', 38),
  ('doc_topic', 'MARIAPOLI', 'Mariapolis', 39),
  ('doc_topic', 'CITTADELLA', 'The little towns of witness (Cittadelle)', 40),
  ('doc_topic', 'HOLINESS', 'Holiness: the call to become saints, together', 41),
  ('doc_topic', 'PRESENT_MOMENT', 'Living the present moment', 42),
  ('doc_topic', 'HOLY_JOURNEY', 'The Holy Journey', 43),
  ('doc_topic', 'DEATH_HEAVEN', 'Death, eternal life and heaven', 44),
  ('doc_topic', 'JOY_PEACE', 'Joy and peace', 45),
  ('doc_topic', 'FAITH_HOPE', 'Faith and hope', 46),
  ('doc_topic', 'POPE', 'The Pope and his words', 47),
  ('doc_topic', 'T_PACT', 'Pact of mutual love', 48),
  ('doc_topic', 'T_SOUL', 'Communion of soul', 49),
  ('doc_topic', 'T_WORD_EXP', 'Communion of experiences of the Word', 50),
  ('doc_topic', 'T_COLLOQUIO', 'The personal talk (colloquio)', 51),
  ('doc_topic', 'T_TRUTH', 'The hour of truth', 52),
  ('doc_topic', 'AL_FIRST', 'Art of loving: love first', 53),
  ('doc_topic', 'AL_AS_SELF', 'Art of loving: love as yourself', 54),
  ('doc_topic', 'AL_MAKE_ONE', 'Art of loving: make yourself one', 55),
  ('doc_topic', 'AL_EVERYONE', 'Art of loving: love everyone', 56),
  ('doc_topic', 'AL_JESUS_IN', 'Art of loving: see and love Jesus in the neighbour', 57),
  ('doc_topic', 'AL_ENEMY', 'Art of loving: love the enemy', 58),
  ('doc_topic', 'GENS', 'Gens'' (seminarians)', 59),
  ('doc_topic', 'NEW_HUMANITY', 'New Humanity', 60),
  ('doc_topic', 'YOUTH_UNITED', 'Youth for a United World', 61),
  ('doc_topic', 'YOUNG_UNITY', 'Young people / Teens for Unity (Ragazzi per l''unità)', 62),
  ('doc_topic', 'PARISH_DIOC', 'Parish and Diocesan Movements', 63),
  ('doc_topic', 'POLITICS', 'Political Movement for Unity', 64),
  ('doc_topic', 'ECONOMY', 'Economy of Communion', 65),
  ('doc_topic', 'ABBA_SCHOOL', 'The Abbà School and the Movement''s culture', 66)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

notify pgrst, 'reload schema';

-- Every row should say true.
select 'table document_topics' as item, to_regclass('public.document_topics') is not null as ok
union all select 'table document_profiles', to_regclass('public.document_profiles') is not null
union all select 'policies (4)', (select count(*) = 4 from pg_policies where tablename in ('document_topics', 'document_profiles'))
union all select 'topic labels (66)', (select count(*) = 66 from public.option_lists where list_name = 'doc_topic');
