-- 105_skill_corpus_analysis_log.sql
-- Log of the mining cycles run on the parallel Italian<->Urdu corpus to maintain the translation
-- style guide (Focolare_Urdu_Translation_Style_Guide). Tracked from
-- log_skill_mining_run_2026-10-19.sql, with two deliberate changes:
--
--   1. Admin-only. The original policies let anyone read the table (`using (true)` applies to
--      signed-out visitors too) and let ANY signed-in user insert, a plain User included. The log
--      is maintenance bookkeeping, not something the app's readers need, so both policies are now
--      `current_role_is('admin')`, as for the project's other maintenance tables. There is no
--      update or delete policy: the log is append-only.
--   2. Safe to re-run. The original inserted the second cycle's row unconditionally, so running
--      it twice duplicated it; each row is now inserted only if it is not already there.
--
-- It is not known whether the 2026-09-21 script (create_and_log_skill_corpus_analysis.sql) was
-- ever executed, so this creates the table if missing and replaces ANY existing policy on it -
-- if the permissive ones are already in the database, this removes them.
--
-- Run after 104_fix_linkup_ref_date_shift.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. The log
-- ============================================================================
create table if not exists public.skill_corpus_analysis_log (
  id                    bigint generated always as identity primary key,
  analyzed_up_to        timestamptz not null default now(),
  pairs_analyzed_count  integer not null,
  skill_version_before  text,
  skill_version_after   text,
  findings_summary      text,
  run_by_email          text,
  created_at            timestamptz not null default now()
);

alter table public.skill_corpus_analysis_log enable row level security;

-- Drop every existing policy first (not only the two names below): an earlier run may have left
-- permissive ones under other names.
do $$
declare p record;
begin
  for p in select policyname from pg_policies
           where schemaname = 'public' and tablename = 'skill_corpus_analysis_log' loop
    execute format('drop policy %I on public.skill_corpus_analysis_log', p.policyname);
  end loop;
end $$;

create policy "skill_corpus_analysis_log_select" on public.skill_corpus_analysis_log
  for select using (current_role_is('admin'));

create policy "skill_corpus_analysis_log_insert" on public.skill_corpus_analysis_log
  for insert with check (current_role_is('admin'));

-- ============================================================================
-- 2. The two cycles run so far
-- ============================================================================
-- First cycle (2026-09-21), only if nobody logged anything yet.
insert into public.skill_corpus_analysis_log
  (analyzed_up_to, pairs_analyzed_count, skill_version_before, skill_version_after, findings_summary, run_by_email)
select timestamptz '2026-09-21 15:20+05', 286, '3.0', '3.1',
  'Primo ciclo di mining su corpus parallelo (286 righe esportate via _export_work_pairs.sql). '
  || 'fokulari promosso a canonico; conferme a livello di documento su Chiesa, Spirito Santo, Unita, Colloquio, '
  || 'Gesu abbandonato, amore reciproco, Patto; aperta la divergenza Mariapoli; segnalato khuda senza diacritico; '
  || 'registrato il limite dei trigger italiani generici. Numeri rivisti dal secondo ciclo (vedi riga successiva).',
  'alessanpk@gmail.com'
where not exists (select 1 from public.skill_corpus_analysis_log);

-- Second cycle (2026-10-19), only if not already logged.
insert into public.skill_corpus_analysis_log
  (pairs_analyzed_count, skill_version_before, skill_version_after, findings_summary, run_by_email)
select
  278, '3.2', '3.4',
  'Secondo ciclo sullo stesso corpus del 2026-09-21, metodo corretto (manuale 13.8). '
  || '286 righe esportate, 278 usabili: 8 coppie scartate perche il fratello e un altro record italiano, non una traduzione '
  || '(documenti 1716, 1717, 1721, 1722, 1739, 1740, 1747, 1749 - difetto di dati segnalato all archivio). '
  || 'Il corpus reale e 122 documenti italiani distinti su 118 work_id, non 286 documenti. '
  || 'Metodo: finestra allineata per posizione di paragrafo (piu o meno 1, oppure 2 se il testo urdu e poco segmentato) '
  || 'accanto alla co-occorrenza a documento intero, cosi la sovrastima del primo metodo e misurabile: '
  || 'minima sui termini frequenti (Dio 96 contro 93 per cento), ampia su quelli medi (Chiesa 74 contro 48, Patto 71 contro 35). '
  || 'DIVERGENZA NUOVA E FORTE: Ideale si scrive aaidil con hamza (68 conferme su 68); la forma del glossario non compare mai. '
  || 'Corregge la conclusione del paragrafo 13.7 della v3.1, che la dava a zero per limite di metodo. Non promossa: decide l utente. '
  || 'Il saluto canonico e nel corpus la grafia minoritaria: 103 contro 6. '
  || 'Mariapolis confermata dal corpus (25 contro 2) il giorno dopo la decisione della v3.2. '
  || 'Tre voci di glossario non attestate: Cittadella resa lunga (0 su 15), vivere il presente (0 su 21), ora della verita (0 su 6). '
  || 'Cinque voci non verificabili perche assenti dall italiano: arte di amare, Volontari di Dio, Famiglie Nuove, Gen 2/3/4, le due invocazioni. '
  || 'Risultato negativo di metodo: la scoperta automatica di rese alternative non funziona ne per frequenza ne per sovrarappresentazione; '
  || 'serve un allineamento per frase. Tre errori di confronto trovati, tutti silenziosi (boundary sulle lettere accentate, '
  || 'varianti grafiche con ordine di lettere diverso, backslash persi): i numeri precedenti vanno letti come limiti inferiori. '
  || 'Nessuna promozione automatica attestato->canonico: entrambe le divergenze sono state decise dall utente lo stesso giorno '
  || '(aaidil con hamza per Ideale, saluto scritto unito), recepite nel manuale v3.4 come terminologia canonica.',
  'alessanpk@gmail.com'
where not exists (
  select 1 from public.skill_corpus_analysis_log
  where skill_version_before = '3.2' and skill_version_after = '3.4'
);

-- ============================================================================
-- 3. Self-test (run separately). All rows must be true.
-- ============================================================================
select 'table skill_corpus_analysis_log' as item, (to_regclass('public.skill_corpus_analysis_log') is not null) as ok
union all select 'RLS enabled', (select relrowsecurity from pg_class where oid = 'public.skill_corpus_analysis_log'::regclass)
union all select 'exactly 2 policies (select, insert)', (select count(*) = 2 from pg_policies where tablename = 'skill_corpus_analysis_log')
union all select 'every policy is admin-only', (select bool_and((coalesce(qual, '') || coalesce(with_check, '')) like '%admin%') from pg_policies where tablename = 'skill_corpus_analysis_log')
union all select 'both cycles logged', (select count(*) >= 2 from public.skill_corpus_analysis_log where skill_version_after in ('3.1', '3.4'));
