-- _audit_pre54_migrations.sql
-- Read-only audit (PROJECT_HANDOFF_v22 §3 punto 4 / v24 §3 punto 2): verifica se le migrazioni
-- 01-53 sono state davvero eseguite sul database live, dopo che la 54 risultò mai eseguita
-- nonostante fosse nel repo da tempo (v22 §1.3). Nessuna scrittura: solo select. Un controllo
-- per ogni migrazione che introduce schema (tabelle/colonne/funzioni/liste) - le migrazioni
-- puramente di dati (fuzzy match, backfill di ref_date, correzioni di encoding) non hanno un
-- modo affidabile di essere verificate da uno script generico e non sono incluse qui.
-- Tutte le righe devono dare `true`. Se qualcuna dà `false`, quella migrazione va rieseguita
-- (sono tutte idempotenti, `create if not exists` / `add column if not exists`).

select '01: document_categories table' as item, to_regclass('public.document_categories') is not null as ok
union all select '03: documents.category column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'category')
union all select '05: user_roles table', to_regclass('public.user_roles') is not null
union all select '05: fn current_role_is', to_regproc('public.current_role_is') is not null
union all select '06: option_lists table', to_regclass('public.option_lists') is not null
union all select '07: documents.has_video column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'has_video')
union all select '08: ref_collegamenti table', to_regclass('public.ref_collegamenti') is not null
union all select '12: works table', to_regclass('public.works') is not null
union all select '12: documents.media_type column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'media_type')
union all select '14: documents.operator column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'operator')
union all select '15: documents.original_inp_file_name column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'original_inp_file_name')
union all select '16: user_profiles table', to_regclass('public.user_profiles') is not null
union all select '16: splash_messages table', to_regclass('public.splash_messages') is not null
union all select '21: documents.episode_number column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'episode_number')
union all select '22: collaboration_applications table', to_regclass('public.collaboration_applications') is not null
union all select '34: tasks table', to_regclass('public.tasks') is not null
union all select '36: documents.pages column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'pages')
union all select '36: tasks.credits column', exists (select 1 from information_schema.columns where table_name = 'tasks' and column_name = 'credits')
union all select '37: user_qualifications table', to_regclass('public.user_qualifications') is not null
union all select '37: tasks.category column', exists (select 1 from information_schema.columns where table_name = 'tasks' and column_name = 'category')
union all select '38: tasks.review_verdict column', exists (select 1 from information_schema.columns where table_name = 'tasks' and column_name = 'review_verdict')
union all select '39: fn give_up_task', to_regproc('public.give_up_task') is not null
union all select '43/50: fn admin_decide_task', to_regproc('public.admin_decide_task') is not null
union all select '45: documents.source_task_id column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'source_task_id')
union all select '49: documents.renamed_inp_file_name column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'renamed_inp_file_name')
union all select '50: documents.draft_inp_path column', exists (select 1 from information_schema.columns where table_name = 'documents' and column_name = 'draft_inp_path')
union all select '50: fn finalize_document_publish', to_regproc('public.finalize_document_publish') is not null
union all select '51: help_pages table', to_regclass('public.help_pages') is not null
union all select '52: option_lists collaboration_skill seed', exists (select 1 from option_lists where list_name = 'collaboration_skill' and code = 'URDU_RW')
union all select '53: option_lists DATA_ASSISTANT qualification', exists (select 1 from option_lists where list_name = 'operator_qualification' and code = 'DATA_ASSISTANT')
order by 1;
