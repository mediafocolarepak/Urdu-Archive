-- 172: two tools get back the rules they were missing (found 2026-11-25). Run after 170.
--   - document_collections had its protection on and no rule that opens it: nobody, Admin included, could read or save the
--     collections from the app, so the Collection filter found nothing. Readers read them (reserved documents stay hidden by
--     the guard that is already there); whoever uses the archive tools writes them.
--   - hayat_indice had no rule to add or delete a row, so "+ Add row", Duplicate, Import CSV and Delete could not work.
--     Adding is for whoever uses the archive tools; deleting is for Coordinators and Admins, and from now on the archive log
--     records every change to the register.
-- Safe to run again.

drop policy if exists "read - document_collections" on public.document_collections;
create policy "read - document_collections" on public.document_collections for select to authenticated
  using ((select public.current_role_is('user')));
drop policy if exists "insert - document_collections" on public.document_collections;
create policy "insert - document_collections" on public.document_collections for insert to authenticated
  with check ((select public.can_catalogue()));
drop policy if exists "update - document_collections" on public.document_collections;
create policy "update - document_collections" on public.document_collections for update to authenticated
  using ((select public.can_catalogue())) with check ((select public.can_catalogue()));
drop policy if exists "delete - document_collections" on public.document_collections;
create policy "delete - document_collections" on public.document_collections for delete to authenticated
  using ((select public.can_catalogue()));

drop policy if exists "insert - hayat_indice" on public.hayat_indice;
create policy "insert - hayat_indice" on public.hayat_indice for insert to authenticated
  with check ((select public.can_catalogue()));
drop policy if exists "delete - hayat_indice" on public.hayat_indice;
create policy "delete - hayat_indice" on public.hayat_indice for delete to authenticated
  using ((select public.current_role_is('coordinator')));
drop trigger if exists hayat_indice_log_change on public.hayat_indice;
create trigger hayat_indice_log_change after insert or update or delete on public.hayat_indice
  for each row execute function public.log_archive_change('id');

-- Every row should say true.
select 'Collections: four rules, readers read, the tools write' as item,
       (select count(*) = 4 and count(*) filter (where (coalesce(qual, '') || coalesce(with_check, '')) ~ 'can_catalogue') = 3
          from pg_policies where schemaname = 'public' and tablename = 'document_collections' and permissive = 'PERMISSIVE') as ok
union all
select 'Reserved documents still guarded in the collections',
       exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'document_collections' and policyname = 'visible_document_guard' and permissive = 'RESTRICTIVE')
union all
select 'Hayat register: read, add, change, delete',
       (select count(distinct cmd) = 4 from pg_policies where schemaname = 'public' and tablename = 'hayat_indice' and permissive = 'PERMISSIVE')
union all
select 'The archive log records the register',
       exists (select 1 from pg_trigger where tgrelid = 'public.hayat_indice'::regclass and tgname = 'hayat_indice_log_change');
