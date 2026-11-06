-- 122_italian_title.sql
-- Every text is to have its title in Urdu, English and Italian (Owner's decision, 2026-11-06). Urdu and English
-- already have a field; Italian doesn't. This adds the field, and an Italian version gets its own title in it when it
-- is created, by whichever path. No existing title is touched: filling the gaps comes in a later migration.

alter table public.documents add column if not exists it_title text;

create or replace function public.documents_fill_it_title() returns trigger
language plpgsql as $$
begin
  if new.language = 'ITA' and nullif(btrim(new.it_title), '') is null and nullif(btrim(new.original_title), '') is not null then
    new.it_title := new.original_title;
  end if;
  return new;
end $$;

drop trigger if exists documents_fill_it_title on public.documents;
create trigger documents_fill_it_title before insert on public.documents
  for each row execute function public.documents_fill_it_title();

-- Verification (the SQL Editor shows only the last result): three rows, all true.
select 'documents.it_title exists' as check_name,
       exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'documents' and column_name = 'it_title') as ok
union all select 'trigger exists',
       exists (select 1 from pg_trigger where tgname = 'documents_fill_it_title')
union all select 'no existing title was changed',
       not exists (select 1 from public.documents where it_title is not null);
