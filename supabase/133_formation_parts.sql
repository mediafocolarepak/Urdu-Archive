-- 133: parts in a formation path, like the parts of a book (Owner's request, 2026-11-09). A module can start a part:
-- its part_title is the part's name, and the modules after it belong to that part until another module starts a new
-- one. No new level and no new table: modules keep their numbering 1, 2, 3... across parts, so "Chapter 3.4" stays
-- the same. Existing paths have no parts and look as before. The same rules as the module itself decide who reads
-- and who writes it. Run this BEFORE merging the PR. Safe to run again.

alter table public.formation_modules
  add column if not exists part_title text;

notify pgrst, 'reload schema';

-- Should say true.
select 'Part column on modules' as item,
       exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'formation_modules' and column_name = 'part_title') as ok;
