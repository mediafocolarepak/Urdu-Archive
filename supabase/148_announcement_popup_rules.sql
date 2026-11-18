-- 148: corrects 147. The table app_settings already existed (sql/21_app_settings.sql: the Hayat Editor's Gemini
-- prompt), with "value" as text and rules letting Operators and Admins read and change every row. So 147 did not
-- create it: it added its two rules on top of the three old ones (its check 3 said false), and the switch is stored
-- as the text 'true' / 'false'. Its rule "everyone signed in reads" also opened the Hayat prompt to every User, and
-- the old rules let Operators change the switch. Now:
--   - everyone signed in reads only the switch; Operators and Admins read every row, as before;
--   - only Admins change the switch; Operators and Admins change the other rows, as before.
-- splash_seen (147) was right and is not touched. Run after 147, BEFORE merging the PR. Safe to run again.

drop policy if exists "app_settings_read" on public.app_settings;
create policy "app_settings_read" on public.app_settings
  for select to authenticated using (key = 'announcements_popup');

drop policy if exists "app_settings_admin_write" on public.app_settings;
drop policy if exists "app_settings_popup_admin" on public.app_settings;
create policy "app_settings_popup_admin" on public.app_settings
  for all to authenticated
  using (key = 'announcements_popup'
         and exists (select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'))
  with check (key = 'announcements_popup'
         and exists (select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role = 'admin'));

-- The two old writing rules of 21, the same but no longer on the switch.
drop policy if exists "app_settings_insert_write_roles" on public.app_settings;
create policy "app_settings_insert_write_roles" on public.app_settings
  for insert with check (key <> 'announcements_popup' and exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role in ('operator', 'admin')
  ));

drop policy if exists "app_settings_update_write_roles" on public.app_settings;
create policy "app_settings_update_write_roles" on public.app_settings
  for update using (key <> 'announcements_popup' and exists (
    select 1 from public.user_roles ur where ur.user_id = auth.uid() and ur.role in ('operator', 'admin')
  )) with check (key <> 'announcements_popup');

-- The switch as plain text, on unless it says false.
update public.app_settings set value = case when btrim(value, ' "') = 'false' then 'false' else 'true' end
where key = 'announcements_popup' and value is distinct from 'true' and value is distinct from 'false';

notify pgrst, 'reload schema';

-- Should all say true.
select 1 as ord, 'Switch present, true or false' as item,
       exists (select 1 from public.app_settings where key = 'announcements_popup' and value in ('true', 'false')) as ok
union all select 2, 'Five rules on app_settings',
       (select count(*) = 5 from pg_policies where schemaname = 'public' and tablename = 'app_settings')
union all select 3, 'Everyone reads only the switch',
       exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'app_settings'
                 and policyname = 'app_settings_read' and qual like '%announcements_popup%')
union all select 4, 'Old writing rules leave the switch alone',
       (select count(*) = 2 from pg_policies where schemaname = 'public' and tablename = 'app_settings'
          and policyname in ('app_settings_insert_write_roles', 'app_settings_update_write_roles')
          and coalesce(qual, '') || coalesce(with_check, '') like '%announcements_popup%')
union all select 5, 'Closed announcements: own row only (147)',
       (select count(*) = 1 from pg_policies where schemaname = 'public' and tablename = 'splash_seen')
order by ord;
