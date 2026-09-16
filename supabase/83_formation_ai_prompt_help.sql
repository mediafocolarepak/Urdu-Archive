-- 83_formation_ai_prompt_help.sql
-- PROJECT_HANDOFF_v23.md §3.3 (Fase 2b): the standard AI prompt for drafting a quiz, made
-- discoverable in Help too - not just behind the "Copy AI prompt" button in the quiz manager
-- (js/formation.js's QUIZ_AI_PROMPT, which must say exactly the same thing as this page). Same
-- mechanism as 51_help_pages.sql / 78_help_boards_formation_paths.sql (help_pages table,
-- admin-editable in-app). role = null: relevant to any formatore, not one specific role.

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('formation_ai_prompt_en', 'en', null, 'Formation: drafting a quiz with AI', $q_fap_en$
<title>Formation: drafting a quiz with AI</title>
<style>
  body { font-family: -apple-system, 'Public Sans', sans-serif; line-height: 1.5; padding: 16px; color: #26211d; }
  h2 { margin-top: 0; }
  pre { background: #f3efe7; border: 1px solid #e6ded2; border-radius: 8px; padding: 12px; white-space: pre-wrap; font-family: 'IBM Plex Mono', monospace; font-size: 12.5px; }
  code { font-family: 'IBM Plex Mono', monospace; }
</style>
<h2>Drafting a quiz with an AI tool</h2>
<p>Formatori are expected to draft module quizzes with an AI tool (ChatGPT, Claude, Gemini...) rather
than typing every question by hand. Paste the module's content into the AI tool together with the
prompt below, then paste the AI's reply into <strong>Formation Paths &rarr; your path &rarr; a
module's quiz &rarr; Import quiz (.md)</strong>.</p>
<p>The same prompt is one click away from a "Copy AI prompt" button next to "Import quiz (.md)" in
the quiz manager, so you never need to retype it.</p>
<h3>The prompt</h3>
<pre>You are helping build a quiz for an online course module. Based on the module content below, write 8-10 multiple-choice questions in this exact Markdown format (nothing else):

## &lt;question text&gt;
- [ ] &lt;wrong option&gt;
- [ ] &lt;wrong option&gt;
- [x] &lt;correct option&gt;
- [ ] &lt;wrong option&gt;
points: 1

Rules:
- Each question needs at least 2 options and exactly one marked [x] as correct.
- "points: N" is optional (defaults to 1) and, if present, must be its own line right after the last option.
- Do not add numbering, explanations, or any text outside this format.

Module content:
&lt;paste the module's text here&gt;</pre>
<p>The importer accepts questions even if some others in the same paste are malformed (missing a
correct answer, only one option, etc.) - it imports what it can and lists the rest so you can fix
and re-paste just those.</p>
$q_fap_en$, 6, now(), null)
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

insert into help_pages (slug, language, role, title, html_content, sort_order, updated_at, updated_by_email)
values ('formation_ai_prompt_it', 'it', null, 'Percorsi Formativi: creare un quiz con l’AI', $q_fap_it$
<title>Percorsi Formativi: creare un quiz con l'AI</title>
<style>
  body { font-family: -apple-system, 'Public Sans', sans-serif; line-height: 1.5; padding: 16px; color: #26211d; }
  h2 { margin-top: 0; }
  pre { background: #f3efe7; border: 1px solid #e6ded2; border-radius: 8px; padding: 12px; white-space: pre-wrap; font-family: 'IBM Plex Mono', monospace; font-size: 12.5px; }
  code { font-family: 'IBM Plex Mono', monospace; }
</style>
<h2>Creare un quiz con uno strumento AI</h2>
<p>I formatori sono invitati a preparare i quiz dei moduli con uno strumento AI (ChatGPT, Claude,
Gemini...) invece di scrivere ogni domanda a mano. Incolla il contenuto del modulo nello strumento
AI insieme al prompt qui sotto, poi incolla la risposta dell'AI in <strong>Percorsi Formativi
&rarr; il tuo percorso &rarr; il quiz di un modulo &rarr; Import quiz (.md)</strong>.</p>
<p>Lo stesso prompt e' disponibile con un click dal bottone "Copy AI prompt" accanto a "Import quiz
(.md)" nella gestione del quiz, cosi' non serve mai riscriverlo.</p>
<h3>Il prompt (in inglese, cosi' funziona con qualunque assistente)</h3>
<pre>You are helping build a quiz for an online course module. Based on the module content below, write 8-10 multiple-choice questions in this exact Markdown format (nothing else):

## &lt;question text&gt;
- [ ] &lt;wrong option&gt;
- [ ] &lt;wrong option&gt;
- [x] &lt;correct option&gt;
- [ ] &lt;wrong option&gt;
points: 1

Rules:
- Each question needs at least 2 options and exactly one marked [x] as correct.
- "points: N" is optional (defaults to 1) and, if present, must be its own line right after the last option.
- Do not add numbering, explanations, or any text outside this format.

Module content:
&lt;paste the module's text here&gt;</pre>
<p>L'importazione accetta le domande valide anche se altre nello stesso incollato sono malformate
(manca la risposta corretta, una sola opzione, ecc.) - importa quello che puo' ed elenca il resto,
cosi' puoi correggerle e reincollare solo quelle.</p>
$q_fap_it$, 6, now(), null)
on conflict (slug) do update set language=excluded.language, role=excluded.role, title=excluded.title, html_content=excluded.html_content, sort_order=excluded.sort_order, updated_at=now();

-- Self-test.
select 'help_pages formation_ai_prompt_en' as item, exists (select 1 from help_pages where slug = 'formation_ai_prompt_en') as ok
union all select 'help_pages formation_ai_prompt_it', exists (select 1 from help_pages where slug = 'formation_ai_prompt_it');
