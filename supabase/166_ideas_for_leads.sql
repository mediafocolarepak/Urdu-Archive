-- 166: the leads of the departments read the ideas to improve the app (Owner's decision, 2026-11-25).
--
-- "Share with us" is the one door for Users and Operators. An experience already reaches the leads and the Admins; an idea
-- (chat_messages, report_type SUGGESTION) reached only Coordinators and Admins. From now on the leads read it too, and hear
-- it when it was spoken. They only read: answering stays with Coordinators and Admins. Mistakes and things that don't work
-- are unchanged.
--
-- The app works with and without it. No data changes. Safe to run again.
-- Run in the Supabase Dashboard -> SQL Editor: every row must say true.
--
-- To undo:
--   drop policy "chat_messages_select_ideas_leads" on public.chat_messages;
--   drop policy "read ideas - report-audio" on storage.objects;

drop policy if exists "chat_messages_select_ideas_leads" on public.chat_messages;
create policy "chat_messages_select_ideas_leads" on public.chat_messages for select to authenticated
  using (report_type = 'SUGGESTION' and (select public.is_any_dept_lead()));

-- The recording of an idea, and only of an idea. Asked of the table as the caller: what one cannot read, one cannot hear.
drop policy if exists "read ideas - report-audio" on storage.objects;
create policy "read ideas - report-audio" on storage.objects for select to authenticated
  using (
    bucket_id = 'report-audio'
    and (select public.is_any_dept_lead())
    and exists (select 1 from public.chat_messages c where c.audio_path = storage.objects.name and c.report_type = 'SUGGESTION')
  );

-- Verification: every row must say true.
select 'leads read the ideas, and only the ideas' as item,
       (select count(*) = 1 and bool_and(cmd = 'SELECT' and permissive = 'PERMISSIVE' and qual like '%SUGGESTION%' and qual like '%is_any_dept_lead%')
        from pg_policies where schemaname = 'public' and tablename = 'chat_messages' and policyname = 'chat_messages_select_ideas_leads') as ok
union all
select 'leads hear only the ideas',
       (select count(*) = 1 and bool_and(cmd = 'SELECT' and qual like '%report-audio%' and qual like '%SUGGESTION%' and qual like '%is_any_dept_lead%')
        from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname = 'read ideas - report-audio')
union all
select 'leads cannot answer or change them',
       not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'chat_messages'
                   and cmd in ('UPDATE', 'DELETE', 'ALL') and (coalesce(qual, '') like '%dept_lead%' or coalesce(with_check, '') like '%dept_lead%'))
union all
select 'each person still reads their own',
       exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'chat_messages' and cmd = 'SELECT' and qual like '%auth.uid()%user_id%')
union all
select 'Coordinators and Admins still read all of them',
       exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'chat_messages' and cmd = 'SELECT' and qual like '%coordinator%');
