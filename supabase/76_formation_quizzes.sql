-- Percorsi formativi (Fase D: quiz e attestato). Decisioni chiuse in chat il 10-11/09/2026:
-- solo scelta multipla, tentativi illimitati (resta il migliore), attestato solo quando TUTTI
-- i quiz dei moduli + l'esame finale sono superati. Un quiz per modulo (gia' deciso per Fase D
-- all'inizio) + un esame finale per percorso, stessa tabella con kind='module'/'final'.
--
-- A differenza dei post (73: sempre pubblici una volta pubblicati, opzione C), i quiz sono
-- riservati - iscritti (attivi) + proprietario + Coordinator/Admin, stesso perimetro della
-- chatroom studenti (75). Le risposte corrette non passano mai dalla select diretta della
-- tabella: uno studente le vede solo tramite formation_quiz_for_taking() (senza correct_index),
-- e la correzione vera avviene server-side in submit_formation_quiz_attempt().

-- 1. Il quiz - di modulo o esame finale del percorso.
create table if not exists public.formation_quizzes (
  id                     bigint generated always as identity primary key,
  path_id                bigint  not null references public.formation_paths(id) on delete cascade,
  module_id              bigint  references public.formation_modules(id) on delete cascade,
  kind                   text    not null check (kind in ('module', 'final')),
  title                  text    not null,
  pass_threshold_percent integer not null default 70 check (pass_threshold_percent between 1 and 100),
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  constraint formation_quizzes_kind_shape check (
    (kind = 'module' and module_id is not null) or (kind = 'final' and module_id is null)
  )
);
-- Un solo quiz per modulo, un solo esame finale per percorso.
create unique index if not exists idx_formation_quizzes_one_per_module
  on public.formation_quizzes (module_id) where kind = 'module';
create unique index if not exists idx_formation_quizzes_one_final_per_path
  on public.formation_quizzes (path_id) where kind = 'final';

-- 2. Le domande - scelta multipla, correct_index e' l'indice (0-based) dentro options.
create table if not exists public.formation_quiz_questions (
  id              bigint generated always as identity primary key,
  quiz_id         bigint  not null references public.formation_quizzes(id) on delete cascade,
  question_text   text    not null,
  options         jsonb   not null,
  correct_index   integer not null,
  points          integer not null default 1 check (points > 0),
  sequence_number integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint formation_quiz_questions_options_shape check (
    jsonb_typeof(options) = 'array' and jsonb_array_length(options) >= 2
  ),
  constraint formation_quiz_questions_correct_index_range check (
    correct_index >= 0 and correct_index < jsonb_array_length(options)
  )
);
create index if not exists idx_formation_quiz_questions_quiz on public.formation_quiz_questions (quiz_id, sequence_number);

-- 3. Tentativi - un registro (come task_outcome_events, 38_task_review_pipeline.sql): non si
-- sovrascrive mai un tentativo precedente, "superato" = esiste un tentativo con passed = true.
create table if not exists public.formation_quiz_attempts (
  id            bigint generated always as identity primary key,
  quiz_id       bigint  not null references public.formation_quizzes(id) on delete cascade,
  user_id       uuid    not null references auth.users(id) on delete cascade,
  score_percent numeric not null,
  passed        boolean not null,
  answers       jsonb   not null,
  submitted_at  timestamptz not null default now()
);
create index if not exists idx_formation_quiz_attempts_quiz_user on public.formation_quiz_attempts (quiz_id, user_id);

-- 4. Attestato - una riga per (percorso, utente), emessa automaticamente al soddisfacimento
-- di tutti i criteri (vedi formation_check_and_issue_certificate sotto). certificate_code e'
-- solo un identificativo leggibile, nessuna pagina di verifica pubblica per ora.
create table if not exists public.formation_certificates (
  path_id          bigint  not null references public.formation_paths(id) on delete cascade,
  user_id          uuid    not null references auth.users(id) on delete cascade,
  issued_at        timestamptz not null default now(),
  certificate_code text    not null unique default substr(md5(random()::text || clock_timestamp()::text), 1, 10),
  primary key (path_id, user_id)
);

-- 5. Funzioni d'appoggio.

create or replace function public.is_formation_quiz_participant(pid bigint)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.is_formation_owner(pid) or public.current_role_is('coordinator') or public.formation_is_enrolled(pid);
$$;

alter table public.formation_quizzes         enable row level security;
alter table public.formation_quiz_questions  enable row level security;
alter table public.formation_quiz_attempts   enable row level security;
alter table public.formation_certificates    enable row level security;

-- formation_quizzes: titolo/soglia visibili a chi partecipa (non le risposte, che stanno in
-- un'altra tabella); scrittura solo al proprietario/Coordinator.
drop policy if exists "formation_quizzes_select" on public.formation_quizzes;
create policy "formation_quizzes_select" on public.formation_quizzes
  for select using (public.is_formation_quiz_participant(path_id));
drop policy if exists "formation_quizzes_write" on public.formation_quizzes;
create policy "formation_quizzes_write" on public.formation_quizzes
  for all using (public.is_formation_owner(path_id) or public.current_role_is('coordinator'))
  with check (public.is_formation_owner(path_id) or public.current_role_is('coordinator'));

-- formation_quiz_questions: select diretto SOLO al proprietario/Coordinator (per editarle) - uno
-- studente le legge senza correct_index tramite formation_quiz_for_taking() sotto, mai da qui.
drop policy if exists "formation_quiz_questions_select" on public.formation_quiz_questions;
create policy "formation_quiz_questions_select" on public.formation_quiz_questions
  for select using (
    exists (select 1 from public.formation_quizzes q
              where q.id = quiz_id and (public.is_formation_owner(q.path_id) or public.current_role_is('coordinator')))
  );
drop policy if exists "formation_quiz_questions_write" on public.formation_quiz_questions;
create policy "formation_quiz_questions_write" on public.formation_quiz_questions
  for all using (
    exists (select 1 from public.formation_quizzes q
              where q.id = quiz_id and (public.is_formation_owner(q.path_id) or public.current_role_is('coordinator')))
  )
  with check (
    exists (select 1 from public.formation_quizzes q
              where q.id = quiz_id and (public.is_formation_owner(q.path_id) or public.current_role_is('coordinator')))
  );

-- formation_quiz_attempts: ognuno vede i propri, piu' il proprietario/Coordinator (per vedere chi
-- ha superato cosa). Nessuna policy di insert: solo submit_formation_quiz_attempt() puo' scrivere.
drop policy if exists "formation_quiz_attempts_select" on public.formation_quiz_attempts;
create policy "formation_quiz_attempts_select" on public.formation_quiz_attempts
  for select using (
    user_id = auth.uid()
    or exists (select 1 from public.formation_quizzes q
                 where q.id = quiz_id and (public.is_formation_owner(q.path_id) or public.current_role_is('coordinator')))
  );

-- formation_certificates: ognuno vede i propri (per il proprio profilo), piu' il
-- proprietario/Coordinator. Nessuna policy di scrittura: solo la funzione sotto puo' emetterli.
drop policy if exists "formation_certificates_select" on public.formation_certificates;
create policy "formation_certificates_select" on public.formation_certificates
  for select using (
    user_id = auth.uid()
    or public.is_formation_owner(path_id)
    or public.current_role_is('coordinator')
  );

-- 6. Consegna del quiz allo studente - stesse domande, MAI correct_index. Si autoverifica il
-- permesso (stesso schema di board_post_readers/formation_enrollees): chi non ha accesso
-- riceve zero righe invece di un errore.
create or replace function public.formation_quiz_for_taking(qid bigint)
returns table (question_id bigint, question_text text, options jsonb, sequence_number integer)
language sql
security definer
stable
set search_path = public
as $$
  select qq.id, qq.question_text, qq.options, qq.sequence_number
  from public.formation_quiz_questions qq
  join public.formation_quizzes q on q.id = qq.quiz_id
  where qq.quiz_id = qid and public.is_formation_quiz_participant(q.path_id)
  order by qq.sequence_number;
$$;

-- 7. Verifica e, se soddisfatti tutti i criteri, emette l'attestato: ogni modulo che HA un quiz
-- deve avere un tentativo superato dell'utente, e se esiste un esame finale anche quello deve
-- essere superato. on conflict do nothing - non si tocca issued_at di un attestato gia' emesso.
create or replace function public.formation_check_and_issue_certificate(pid bigint, uid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  missing_module_quizzes integer;
  final_quiz_id bigint;
  final_passed boolean;
begin
  select count(*) into missing_module_quizzes
  from public.formation_quizzes q
  where q.path_id = pid and q.kind = 'module'
    and not exists (
      select 1 from public.formation_quiz_attempts a
      where a.quiz_id = q.id and a.user_id = uid and a.passed
    );
  if missing_module_quizzes > 0 then
    return;
  end if;

  select id into final_quiz_id from public.formation_quizzes where path_id = pid and kind = 'final';
  if final_quiz_id is not null then
    select exists (select 1 from public.formation_quiz_attempts a
                    where a.quiz_id = final_quiz_id and a.user_id = uid and a.passed) into final_passed;
    if not final_passed then
      return;
    end if;
  end if;

  insert into public.formation_certificates (path_id, user_id)
  values (pid, uid)
  on conflict (path_id, user_id) do nothing;
end;
$$;

-- 8. Invio di un tentativo - unico punto che calcola il punteggio, cosi' un client non puo' mai
-- dichiarare da se' di aver superato un quiz. answers e' un oggetto {"<question_id>": indice}.
create or replace function public.submit_formation_quiz_attempt(qid bigint, answers jsonb)
returns table (score_percent numeric, passed boolean)
language plpgsql
security definer
set search_path = public
as $$
declare
  quiz record;
  total_points integer := 0;
  earned_points integer := 0;
  q record;
  chosen integer;
  computed_score numeric;
  did_pass boolean;
begin
  select * into quiz from public.formation_quizzes where id = qid;
  if not found then
    raise exception 'Quiz not found.';
  end if;
  if not public.is_formation_quiz_participant(quiz.path_id) then
    raise exception 'You do not have access to this quiz.';
  end if;

  for q in select * from public.formation_quiz_questions where quiz_id = qid loop
    total_points := total_points + q.points;
    chosen := (answers ->> q.id::text)::integer;
    if chosen is not null and chosen = q.correct_index then
      earned_points := earned_points + q.points;
    end if;
  end loop;

  if total_points = 0 then
    raise exception 'This quiz has no questions yet.';
  end if;

  computed_score := round(100.0 * earned_points / total_points, 1);
  did_pass := computed_score >= quiz.pass_threshold_percent;

  insert into public.formation_quiz_attempts (quiz_id, user_id, score_percent, passed, answers)
  values (qid, auth.uid(), computed_score, did_pass, answers);

  if did_pass then
    perform public.formation_check_and_issue_certificate(quiz.path_id, auth.uid());
  end if;

  return query select computed_score, did_pass;
end;
$$;

select 'tabella formation_quizzes',        to_regclass('public.formation_quizzes')        is not null as ok
union all select 'tabella formation_quiz_questions', to_regclass('public.formation_quiz_questions') is not null
union all select 'tabella formation_quiz_attempts',  to_regclass('public.formation_quiz_attempts')  is not null
union all select 'tabella formation_certificates',   to_regclass('public.formation_certificates')   is not null
union all select 'funzione formation_quiz_for_taking',   to_regproc('public.formation_quiz_for_taking')   is not null
union all select 'funzione submit_formation_quiz_attempt', to_regproc('public.submit_formation_quiz_attempt') is not null
union all select 'funzione formation_check_and_issue_certificate', to_regproc('public.formation_check_and_issue_certificate') is not null
union all select 'policy formation_quizzes (2)', (select count(*) = 2 from pg_policies where tablename = 'formation_quizzes')
union all select 'policy formation_quiz_questions (2)', (select count(*) = 2 from pg_policies where tablename = 'formation_quiz_questions')
union all select 'policy formation_quiz_attempts (1)', (select count(*) = 1 from pg_policies where tablename = 'formation_quiz_attempts')
union all select 'policy formation_certificates (1)', (select count(*) = 1 from pg_policies where tablename = 'formation_certificates');
