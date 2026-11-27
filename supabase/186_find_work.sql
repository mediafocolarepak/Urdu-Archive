-- 186: Find work to do (Owner's decisions, 2026-11-27). Searches of what is missing in the archive, for Admin, Coordinator
-- and the leads of a department: a language missing in a Work, the months of the Word of Life, texts to type, to reread or
-- to read aloud, missing details, possible duplicates. Every function only reads, with the rights of whoever calls it:
-- a document that person cannot read is not in the list either. Plus two task categories, "Urdu to English Translation"
-- and "Typing" (an Urdu to English draft becomes an English version), and the guide "Find work to do" in English and
-- Italian. No table changes. Safe to run again.

-- Who may search: Admin, Coordinator, and the lead of any department.
create or replace function public.find_work_allowed()
returns boolean language sql stable security invoker set search_path = public as $$
  select public.current_role_is('coordinator')
      or exists (select 1 from public.department_members m where m.user_id = auth.uid() and m.is_lead);
$$;

-- The documents the searches look at: text documents (not audio, not video), not deleted, not hidden (a proposal, a
-- revision, a removed one). A document without a Work is a Work by itself. "There" in a language: a text or a PDF.
create or replace function public.find_work_docs()
returns table (document_id integer, w bigint, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, access_level text, is_preferred boolean, has_text boolean, has_pdf boolean, reviewed boolean,
               char_count integer)
language sql stable security invoker set search_path = public as $$
  select d.document_id, coalesce(d.work_id, -d.document_id)::bigint, d.work_id::bigint, d.language, d.category, d.ref_date, d.ref_period,
         d.en_title, d.ur_title, d.it_title, d.original_title, d.title, d.author, d.source, d.pages, d.access_level,
         coalesce(d.is_preferred, false), t.document_id is not null, (d.file_name is not null or d.storage_path is not null),
         coalesce(t.reviewed, false), t.char_count
  from public.documents d left join public.document_texts t on t.document_id = d.document_id
  where public.find_work_allowed()
    and d.deleted_at is null
    and coalesce(d.media_type, 'DOC') = 'DOC'
    and coalesce(d.workflow_status, '') not in ('proposed', 'revision', 'pending_publish', 'removed');
$$;

-- What every search gives back: the document, its titles and date, the languages its Work has, a note, and the task already
-- on it (open, taken, sent or approved), if there is one.
drop function if exists public.find_missing_language(text, text, text);
drop function if exists public.find_wol_documents();
drop function if exists public.find_texts(text, text, text);
drop function if exists public.find_missing_details(text, text, text);
drop function if exists public.find_duplicates(text);
drop function if exists public.find_work_rows(integer[], text[]);

create or replace function public.find_work_rows(p_ids integer[], p_notes text[])
returns table (document_id integer, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, char_count integer, languages text[], note text, task_id bigint, task_status text)
language sql stable security invoker set search_path = public as $$
  with d as (select * from public.find_work_docs()),
  there as (select x.w, array_agg(distinct x.language order by x.language) as langs
            from d x where (x.has_text or x.has_pdf) and x.language is not null group by x.w),
  picked as (select u.id, u.note from unnest(p_ids, p_notes) as u(id, note))
  select d.document_id, d.work_id, d.language, d.category, d.ref_date, d.ref_period, d.en_title, d.ur_title, d.it_title,
         d.original_title, d.title, d.author, d.source, d.pages, d.char_count, coalesce(th.langs, '{}'), p.note,
         tk.id, tk.status
  from picked p join d on d.document_id = p.id
  left join there th on th.w = d.w
  left join lateral (select t.id, t.status from public.tasks t
                     where t.document_id = d.document_id and t.status in ('open', 'claimed', 'submitted', 'approved')
                     order by t.id desc limit 1) tk on true
  order by d.document_id;
$$;

-- A Work that has p_has and not p_missing: one row per Work, its p_has document (with a text first, then the starred
-- one, then the lowest number).
create or replace function public.find_missing_language(p_has text, p_missing text, p_category text default null)
returns table (document_id integer, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, char_count integer, languages text[], note text, task_id bigint, task_status text)
language sql stable security invoker set search_path = public as $$
  with d as (select * from public.find_work_docs()),
  there as (select distinct x.w, x.language from d x where x.has_text or x.has_pdf),
  pick as (
    select distinct on (x.w) x.document_id
    from d x
    where x.language = p_has and (x.has_text or x.has_pdf)
      and (p_category is null or x.category = p_category)
      and not exists (select 1 from there t where t.w = x.w and t.language = p_missing)
    order by x.w, x.has_text desc, x.is_preferred desc, x.document_id)
  select * from public.find_work_rows(array(select document_id from pick), array(select null::text from pick));
$$;

-- The Word of Life documents, each with its month (the note, "YYYY-MM"), read as the book reads it: the date, else a
-- period "YYYY-MM", else the month in the Italian title ("Parola di vita, marzo 2006"). The calendar is made in the app.
create or replace function public.find_wol_documents()
returns table (document_id integer, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, char_count integer, languages text[], note text, task_id bigint, task_status text)
language sql stable security invoker set search_path = public as $$
  with d as (
    select x.document_id,
           coalesce(to_char(x.ref_date, 'YYYY-MM'), substring(x.ref_period from '^\d{4}-\d{2}'),
             (select m[2] || '-' || lpad((array_position(array['gennaio','febbraio','marzo','aprile','maggio','giugno','luglio',
                      'agosto','settembre','ottobre','novembre','dicembre'], lower(m[1])))::text, 2, '0')
              from regexp_match(coalesce(x.it_title, ''), '(gennaio|febbraio|marzo|aprile|maggio|giugno|luglio|agosto|settembre|ottobre|novembre|dicembre)\s+(\d{4})', 'i') m)) as ym
    from public.find_work_docs() x
    where x.category = 'Wol' and (x.has_text or x.has_pdf))
  select * from public.find_work_rows(array(select document_id from d), array(select ym from d));
$$;

-- Texts: 'no_text' a PDF without its typed text; 'not_reread' a text not yet reread; 'read_aloud' an Urdu text that may be
-- read aloud (reread, or by STE; not reserved) and whose Work has no Urdu reading yet. The note: the length of the text.
create or replace function public.find_texts(p_kind text, p_language text default null, p_category text default null)
returns table (document_id integer, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, char_count integer, languages text[], note text, task_id bigint, task_status text)
language sql stable security invoker set search_path = public as $$
  with d as (
    select x.* from public.find_work_docs() x
    where (p_language is null or x.language = p_language)
      and (p_category is null or x.category = p_category)
      and case p_kind
        when 'no_text' then x.has_pdf and not x.has_text
        when 'not_reread' then x.has_text and not x.reviewed
        when 'read_aloud' then x.language = 'URD' and x.has_text and (x.reviewed or x.source = 'STE')
          and coalesce(x.access_level, 'private') <> 'reserved'
          and not exists (select 1 from public.documents a where a.media_type = 'AUD' and a.language = 'URD'
                          and a.deleted_at is null and coalesce(a.work_id, -a.document_id) = x.w)
        else false end)
  select * from public.find_work_rows(array(select document_id from d), array(select null::text from d));
$$;

-- Missing details: p_what is 'date', 'en_title', 'ur_title', 'it_title', 'author' or 'category'.
create or replace function public.find_missing_details(p_what text, p_category text default null, p_language text default null)
returns table (document_id integer, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, char_count integer, languages text[], note text, task_id bigint, task_status text)
language sql stable security invoker set search_path = public as $$
  with d as (
    select x.* from public.find_work_docs() x
    where (p_language is null or x.language = p_language)
      and (p_category is null or x.category = p_category)
      and case p_what
        when 'date' then x.ref_date is null and btrim(coalesce(x.ref_period, '')) = ''
        -- A Link-up title "Linkup-2005-08-11" (161) is only its date: no title yet.
        when 'en_title' then btrim(coalesce(x.en_title, '')) = '' or x.en_title ~ '^Linkup-\d{4}-\d{2}-\d{2}-?$'
        when 'ur_title' then btrim(coalesce(x.ur_title, '')) = '' or x.ur_title ~ '^Linkup-\d{4}-\d{2}-\d{2}-?$'
        when 'it_title' then btrim(coalesce(x.it_title, '')) = '' or x.it_title ~ '^CH-\d{4}-\d{2}-\d{2}-?$'
        when 'author' then btrim(coalesce(x.author, '')) = ''
        when 'category' then btrim(coalesce(x.category, '')) = ''
        else false end)
  select * from public.find_work_rows(array(select document_id from d), array(select null::text from d));
$$;

-- Possible duplicates: more than one document of the same Work, language and date. The note names the others.
create or replace function public.find_duplicates(p_category text default null)
returns table (document_id integer, work_id bigint, language text, category text, ref_date date, ref_period text,
               en_title text, ur_title text, it_title text, original_title text, title text, author text, source text,
               pages integer, char_count integer, languages text[], note text, task_id bigint, task_status text)
language sql stable security invoker set search_path = public as $$
  with d as (select x.* from public.find_work_docs() x where x.ref_date is not null and (p_category is null or x.category = p_category)),
  g as (select x.w, x.language, x.ref_date, array_agg(x.document_id order by x.document_id) ids
        from d x group by x.w, x.language, x.ref_date having count(*) > 1),
  r as (select i as id, 'Same as ' || array_to_string(array(select '#' || j from unnest(g.ids) j where j <> i order by j), ', ') as note
        from g, unnest(g.ids) i)
  select * from public.find_work_rows(array(select id from r), array(select note from r));
$$;

-- Only for people signed in; each function checks who is asking (find_work_allowed) and reads with their rights.
do $g$
declare f text;
begin
  foreach f in array array['find_work_allowed()', 'find_work_docs()', 'find_work_rows(integer[], text[])',
    'find_missing_language(text, text, text)', 'find_wol_documents()', 'find_texts(text, text, text)',
    'find_missing_details(text, text, text)', 'find_duplicates(text)'] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $g$;

-- Two task categories (the Owner: added now, even if not used yet). "Others" stays last.
insert into public.option_lists (list_name, code, label, sort_order) values
  ('task_category', 'UR_EN', 'Urdu to English Translation', 7),
  ('task_category', 'TYPING', 'Typing', 8)
on conflict (list_name, code) do nothing;
update public.option_lists set sort_order = 99 where list_name = 'task_category' and code = 'OTHER' and sort_order < 99;

-- A translation into English needs a Translator, like the others.
create or replace function public.user_qualifies_for_category(uid uuid, cat text)
returns boolean
language sql
security definer
stable
as $$
  select case
    when cat in ('IT_UR', 'EN_UR', 'UR_EN') then exists (
      select 1 from public.user_qualifications uq where uq.user_id = uid and uq.qualification_code = 'TRANSLATOR')
    when cat = 'REVISION' then exists (
      select 1 from public.user_qualifications uq where uq.user_id = uid and uq.qualification_code = 'REVISOR')
    else true
  end;
$$;

-- The draft of an Urdu to English translation is an English version (save_task_draft, 170): the same small change as the
-- other translations, only the language differs.
do $p$
declare v_def text; v_new text;
begin
  v_def := pg_get_functiondef('public.save_task_draft(bigint, text)'::regprocedure);
  v_new := replace(v_def, $x$in ('IT_UR', 'EN_UR')$x$, $x$in ('IT_UR', 'EN_UR', 'UR_EN')$x$);
  v_new := replace(v_new, $x$case when v_translation then 'URD' else o.language end$x$,
    $x$case when t.category = 'UR_EN' then 'ENG' when v_translation then 'URD' else o.language end$x$);
  if position($x$in ('IT_UR', 'EN_UR', 'UR_EN')$x$ in v_new) = 0 or position($x$when t.category = 'UR_EN' then 'ENG'$x$ in v_new) = 0 then
    raise exception '186: save_task_draft is not as expected.';
  end if;
  if v_new is distinct from v_def then execute v_new; end if;
end $p$;

-- The guide, in English and Italian (the Owner: for the team's tools Urdu is not needed).
insert into public.help_pages (slug, guide_key, language, role, title, summary, section, audience, html_content, sort_order, draft, updated_at, updated_by_email)
values ('find-work_en', 'find-work', 'en', null, 'Find work to do', 'What is missing in the archive, to print or to make tasks', 'run', array['coordinator', 'lead'], $help_guide$<p class="lead">Ready searches of what is missing in the archive: texts to translate, months of the Word of Life, texts to type or to reread, missing details. Each list can be printed, downloaded for Excel, and turned into tasks.</p>
<h2>Where it is</h2>
<p>Admins and Coordinators: <b>Find work</b> in the top bar, or <b>Find work to do</b> at the top of <b>Print Reports</b>. Department leads: <b>My work → Find work to do</b>.</p>
<h2>Search</h2>
<ol>
<li><b>Choose a search</b> on the left. There are four groups: <b>Languages</b>, <b>Periods</b>, <b>Texts</b>, <b>Catalogue</b>.</li>
<li><b>Set the filters</b>: the category, and for the languages the years. <b>Sort by</b> orders the list by date, title, category or number.</li>
<li>Press <b>Show</b>. The number at the top says how many were found. A row opens the card of its document; <b>Back</b> brings you to the same list.</li>
</ol>
<p>A language is <b>there</b> when a version of the same text has a typed text or a PDF. A version with only its title counts as missing.</p>
<table><tr><th>Search</th><th>What it finds</th></tr>
<tr><td>Italian, not yet in Urdu</td><td>Documents to translate</td></tr>
<tr><td>Urdu, without English</td><td>Texts to bring into English</td></tr>
<tr><td>Urdu, without the Italian original</td><td>Originals to look for</td></tr>
<tr><td>Another combination</td><td>The same, with the languages you choose</td></tr>
<tr><td>Word of Life: missing months</td><td>The months between two dates without a Word of Life in a language. It starts from January 1980. A calendar shows the months: a pink box is a month to do</td></tr>
<tr><td>PDF without typed text</td><td>Texts to type</td></tr>
<tr><td>Text not yet reread</td><td>Texts to proof and finalize</td></tr>
<tr><td>Ready to read aloud</td><td>Urdu texts that can be read aloud and have no recording yet</td></tr>
<tr><td>Missing details</td><td>No date, no title in a language, no author or no category</td></tr>
<tr><td>Possible duplicates</td><td>Two documents of the same text, language and date</td></tr></table>
<p>You see only the documents you may read.</p>
<h2>Print and Excel</h2>
<p><b>Print</b> gives a clean sheet: the search, the filters, who printed it and when, and the page numbers. <b>Download for Excel</b> saves the same list as a file that Excel opens in columns, Urdu included.</p>
<h2>Make tasks (Admins and Coordinators)</h2>
<ol>
<li>Every row without a task is already chosen. Untick what you do not want.</li>
<li>Press <b>Create tasks</b>, check the category, and confirm. One task for each document, open in the Tasks store.</li>
<li>Credits are the rate of the category × the pages. The app reads the pages from the PDF when the document does not say. A document whose pages cannot be read gets no task: the app tells you which, and you set its pages on its card.</li>
</ol>
<p>A document that already has a task (open, taken, sent or approved) is left out. Department leads see the lists and ask a Coordinator for the tasks.</p>
<p><a class="btn" href="#" data-tab="findwork">Open Find work</a></p>$help_guide$, 255, false, now(), 'migration 186'),
('find-work_it', 'find-work', 'it', null, 'Trovare il lavoro da fare', 'Che cosa manca nell''archivio, da stampare o da farne task', 'run', array['coordinator', 'lead'], $help_guide$<p class="lead">Ricerche pronte di ciò che manca nell'archivio: testi da tradurre, mesi della Parola di Vita, testi da battere o da rileggere, dati mancanti. Ogni elenco si stampa, si scarica per Excel e diventa task.</p>
<h2>Dove si trova</h2>
<p>Admin e Coordinator: <b>Find work</b> nella barra in alto, oppure <b>Find work to do</b> in cima a <b>Print Reports</b>. Responsabili di un dipartimento: <b>My work → Find work to do</b>.</p>
<h2>Cercare</h2>
<ol>
<li><b>Scegli una ricerca</b> a sinistra. Ci sono quattro gruppi: <b>Languages</b>, <b>Periods</b>, <b>Texts</b>, <b>Catalogue</b>.</li>
<li><b>Imposta i filtri</b>: la categoria e, per le lingue, gli anni. <b>Sort by</b> ordina per data, titolo, categoria o numero.</li>
<li>Premi <b>Show</b>. Il numero in alto dice quanti sono. Una riga apre la scheda del suo documento; <b>Indietro</b> ti riporta allo stesso elenco.</li>
</ol>
<p>Una lingua <b>c'è</b> quando una versione dello stesso testo ha un testo battuto o un PDF. Una versione con il solo titolo conta come mancante.</p>
<table><tr><th>Ricerca</th><th>Che cosa trova</th></tr>
<tr><td>Italian, not yet in Urdu</td><td>Documenti da tradurre</td></tr>
<tr><td>Urdu, without English</td><td>Testi da portare in inglese</td></tr>
<tr><td>Urdu, without the Italian original</td><td>Originali da cercare</td></tr>
<tr><td>Another combination</td><td>Le stesse, con le lingue che scegli</td></tr>
<tr><td>Word of Life: missing months</td><td>I mesi tra due date senza Parola di Vita in una lingua. Parte da gennaio 1980. Un calendario mostra i mesi: un riquadro rosa è un mese da fare</td></tr>
<tr><td>PDF without typed text</td><td>Testi da battere</td></tr>
<tr><td>Text not yet reread</td><td>Testi da rileggere e completare</td></tr>
<tr><td>Ready to read aloud</td><td>Testi urdu che si possono leggere ad alta voce e non hanno ancora una lettura</td></tr>
<tr><td>Missing details</td><td>Senza data, senza titolo in una lingua, senza autore o senza categoria</td></tr>
<tr><td>Possible duplicates</td><td>Due documenti dello stesso testo, lingua e data</td></tr></table>
<p>Vedi solo i documenti che puoi leggere.</p>
<h2>Stampa ed Excel</h2>
<p><b>Print</b> dà un foglio pulito: la ricerca, i filtri, chi l'ha stampato e quando, e i numeri di pagina. <b>Download for Excel</b> salva lo stesso elenco in un file che Excel apre in colonne, urdu compreso.</p>
<h2>Creare i task (Admin e Coordinator)</h2>
<ol>
<li>Ogni riga senza task è già scelta. Togli la spunta a ciò che non vuoi.</li>
<li>Premi <b>Create tasks</b>, controlla la categoria e conferma. Un task per documento, aperto nel negozio dei Task.</li>
<li>I crediti sono la tariffa della categoria × le pagine. L'app legge le pagine dal PDF quando il documento non le dice. Un documento di cui non si leggono le pagine non riceve il task: l'app ti dice quali sono, e metti le pagine nella sua scheda.</li>
</ol>
<p>Un documento che ha già un task (aperto, preso, inviato o approvato) resta fuori. I responsabili vedono gli elenchi e chiedono i task a un Coordinator.</p>
<p><a class="btn" href="#" data-tab="findwork">Open Find work</a></p>$help_guide$, 255, false, now(), 'migration 186')
on conflict (slug) do nothing;

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'The searches are there' as item,
       (select count(*) from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public'
          and p.proname in ('find_work_allowed', 'find_work_docs', 'find_work_rows', 'find_missing_language', 'find_wol_documents',
                            'find_texts', 'find_missing_details', 'find_duplicates')) = 8 as ok
union all select 2, 'They only read, with the rights of whoever asks',
       not exists (select 1 from pg_proc p join pg_namespace s on s.oid = p.pronamespace where s.nspname = 'public'
          and p.proname like 'find\_%' and (p.prosecdef or p.provolatile <> 's'))
union all select 3, 'Only for people signed in',
       has_function_privilege('authenticated', 'public.find_missing_language(text, text, text)', 'execute')
       and not has_function_privilege('anon', 'public.find_missing_language(text, text, text)', 'execute')
       and not has_function_privilege('anon', 'public.find_work_docs()', 'execute')
union all select 4, 'Two new task categories',
       (select count(*) from public.option_lists where list_name = 'task_category' and code in ('UR_EN', 'TYPING')) = 2
union all select 5, 'Urdu to English needs a Translator',
       (select prosrc ~ 'UR_EN' from pg_proc where oid = 'public.user_qualifies_for_category(uuid, text)'::regprocedure)
union all select 6, 'An Urdu to English draft is an English version',
       (select prosrc ~ 'UR_EN'' then ''ENG''' from pg_proc where oid = 'public.save_task_draft(bigint, text)'::regprocedure)
union all select 7, 'The guide, in English and Italian',
       (select count(*) from public.help_pages where guide_key = 'find-work' and language in ('en', 'it')) = 2
order by 1;
