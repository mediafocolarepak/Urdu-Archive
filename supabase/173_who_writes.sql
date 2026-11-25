-- 173: who writes is said by the database, and no login stays inside posts, messages and pages (Owner's go-ahead, 2026-11-25).
--   1. The author of a post or message, and who moderated, answered or changed something, is the account that did it. What the
--      browser says about itself is not used any more.
--   2. The login (an email, or for a phone account the mobile number) is no longer kept with posts, messages, announcements,
--      guides, texts and memberships, where others read it. The names come from people_names(), by account.
--   3. The login written in a profile is always the account's own.
-- Run AFTER the code of the same pull request is live (it works with and without this file). Safe to run again.
-- Who did what stays: in the account columns, and in the archive log for the tables it covers.

-- ============================================================================
-- 1. The three small tools
-- ============================================================================
-- Columns that must not keep a login. Outside the app (SQL Editor, migrations) nothing changes.
create or replace function public.keep_no_login()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is not null then
    new := jsonb_populate_record(new, (select jsonb_object_agg(k, null) from unnest(tg_argv) k));
  end if;
  return new;
end;
$$;

-- 'author:<column>': who adds the row, for good. 'actor:<column>': who changes it last. 'actor:<column>:<watched>': who
-- changes the watched column. Only for a direct write from the app: the functions of the database say it themselves.
-- 'always:<column>': who changes it last, also through a function.
create or replace function public.set_person()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  a text;
  v_kind text;
  v_col text;
  v_watch text;
  v_old jsonb := case when tg_op = 'UPDATE' then to_jsonb(old) end;
begin
  if auth.uid() is null then return new; end if;
  foreach a in array tg_argv loop
    v_kind := split_part(a, ':', 1); v_col := split_part(a, ':', 2); v_watch := split_part(a, ':', 3);
    if v_kind = 'always' then
      new := jsonb_populate_record(new, jsonb_build_object(v_col, auth.uid()));
    elsif current_user <> 'authenticated' then
      continue;
    elsif v_kind = 'author' then
      new := jsonb_populate_record(new, jsonb_build_object(v_col, case when tg_op = 'INSERT' then to_jsonb(auth.uid()) else v_old -> v_col end));
    elsif v_watch = '' or (tg_op = 'UPDATE' and (to_jsonb(new) -> v_watch) is distinct from (v_old -> v_watch)) then
      new := jsonb_populate_record(new, jsonb_build_object(v_col, auth.uid()));
    elsif tg_op = 'UPDATE' then
      new := jsonb_populate_record(new, jsonb_build_object(v_col, v_old -> v_col));
    else
      new := jsonb_populate_record(new, jsonb_build_object(v_col, null));
    end if;
  end loop;
  return new;
end;
$$;

-- Where the login is needed by those who read it (HR for an application): the caller's own, and it does not change.
create or replace function public.own_login()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.uid() is null or current_user <> 'authenticated' then return new; end if;
  if tg_op = 'INSERT' then
    new := jsonb_populate_record(new, jsonb_build_object(tg_argv[0], (select r.email from public.user_roles r where r.user_id = auth.uid())));
  else
    new := jsonb_populate_record(new, jsonb_build_object(tg_argv[0], to_jsonb(old) -> tg_argv[0]));
  end if;
  return new;
end;
$$;

-- ============================================================================
-- 2. Accounts beside the logins that had none
-- ============================================================================
alter table public.splash_messages   add column if not exists created_by   uuid default auth.uid();
alter table public.board_posts       add column if not exists moderated_by uuid;
alter table public.chat_messages     add column if not exists replied_by   uuid;
alter table public.help_pages        add column if not exists updated_by   uuid;
alter table public.department_status add column if not exists updated_by   uuid;
alter table public.task_category_rates        add column if not exists updated_by  uuid;
alter table public.translation_prompts        add column if not exists created_by  uuid default auth.uid();
alter table public.collaboration_applications add column if not exists reviewed_by uuid;
alter table public.chat_messages   alter column user_email drop not null;
alter table public.splash_messages alter column created_by_email drop not null;

-- ============================================================================
-- 3. The past: accounts from the logins, then the logins go
-- ============================================================================
do $m$
declare
  x record;
begin
  for x in select * from (values
      ('splash_messages', 'created_by', 'created_by_email'), ('board_posts', 'moderated_by', 'moderated_by_email'), ('chat_messages', 'replied_by', 'replied_by_email'),
      ('help_pages', 'updated_by', 'updated_by_email'), ('department_status', 'updated_by', 'updated_by_email'),
      ('task_category_rates', 'updated_by', 'updated_by_email'), ('translation_prompts', 'created_by', 'created_by_email'), ('collaboration_applications', 'reviewed_by', 'reviewed_by_email'),
      ('collaboration_applications', 'recommended_by', 'recommended_by_email')) as v(t, id_col, email_col)
  loop
    execute format('alter table public.%I disable trigger user', x.t);
    execute format('update public.%I t set %I = r.user_id from public.user_roles r where t.%I is null and lower(r.email) = lower(t.%I)', x.t, x.id_col, x.id_col, x.email_col);
    execute format('alter table public.%I enable trigger user', x.t);
  end loop;

  for x in
    select v.t, v.col from (values
      ('board_posts', 'posted_by_email'), ('board_posts', 'moderated_by_email'), ('board_editors', 'added_by_email'),
      ('formation_chat_messages', 'user_email'), ('formation_path_editors', 'added_by_email'),
      ('department_messages', 'user_email'), ('department_messages', 'pinned_by_email'), ('department_members', 'added_by_email'),
      ('department_status', 'updated_by_email'), ('department_priorities', 'created_by_email'),
      ('share_with_us_messages', 'user_email'), ('share_with_us_reactions', 'user_email'), ('share_with_us_replies', 'user_email'),
      ('chat_messages', 'user_email'), ('chat_messages', 'replied_by_email'), ('splash_messages', 'created_by_email'),
      ('help_pages', 'updated_by_email'), ('onboarding_cards', 'created_by_email'), ('app_settings', 'updated_by_email'),
      ('document_texts', 'updated_by_email'), ('document_texts', 'reviewed_by_email'),
      ('document_original_texts', 'updated_by_email'), ('document_original_texts', 'reviewed_by_email'),
      ('task_category_rates', 'updated_by_email'), ('translation_prompts', 'created_by_email'),
      ('collaboration_applications', 'reviewed_by_email'), ('collaboration_applications', 'recommended_by_email')) as v(t, col)
    join information_schema.columns k on k.table_schema = 'public' and k.table_name = v.t and k.column_name = v.col
  loop
    execute format('alter table public.%I disable trigger user', x.t);
    execute format('update public.%I set %I = null where %I is not null and %I !~ ''^migration ''', x.t, x.col, x.col, x.col);
    execute format('alter table public.%I enable trigger user', x.t);
  end loop;

  -- 4. From now on. "zz": after every other trigger of the table.
  for x in
    select v.t, string_agg(quote_literal(v.col), ', ') as cols from (values
      ('board_posts', 'posted_by_email'), ('board_posts', 'moderated_by_email'), ('board_editors', 'added_by_email'),
      ('formation_chat_messages', 'user_email'), ('formation_path_editors', 'added_by_email'),
      ('department_messages', 'user_email'), ('department_messages', 'pinned_by_email'), ('department_members', 'added_by_email'),
      ('department_status', 'updated_by_email'), ('department_priorities', 'created_by_email'),
      ('share_with_us_messages', 'user_email'), ('share_with_us_reactions', 'user_email'), ('share_with_us_replies', 'user_email'),
      ('chat_messages', 'user_email'), ('chat_messages', 'replied_by_email'), ('splash_messages', 'created_by_email'),
      ('help_pages', 'updated_by_email'), ('onboarding_cards', 'created_by_email'), ('app_settings', 'updated_by_email'),
      ('document_texts', 'updated_by_email'), ('document_texts', 'reviewed_by_email'),
      ('document_original_texts', 'updated_by_email'), ('document_original_texts', 'reviewed_by_email'),
      ('task_category_rates', 'updated_by_email'), ('translation_prompts', 'created_by_email'),
      ('collaboration_applications', 'reviewed_by_email'), ('collaboration_applications', 'recommended_by_email')) as v(t, col)
    join information_schema.columns k on k.table_schema = 'public' and k.table_name = v.t and k.column_name = v.col
    group by v.t
  loop
    execute format('drop trigger if exists zz_keep_no_login on public.%I', x.t);
    execute format('create trigger zz_keep_no_login before insert or update on public.%I for each row execute function public.keep_no_login(%s)', x.t, x.cols);
  end loop;

  for x in select * from (values
      ('board_posts', '''author:posted_by'', ''actor:moderated_by:status'''), ('formation_chat_messages', '''author:user_id'''),
      ('department_messages', '''author:user_id'''), ('share_with_us_messages', '''author:user_id'''), ('share_with_us_reactions', '''author:user_id'''),
      ('share_with_us_replies', '''author:user_id'''), ('chat_messages', '''author:user_id'', ''actor:replied_by:reply_text'''),
      ('splash_messages', '''author:created_by'''), ('help_pages', '''actor:updated_by'''), ('department_status', '''actor:updated_by'''),
      ('collaboration_applications', '''author:user_id'', ''actor:reviewed_by:status'''),
      ('task_category_rates', '''always:updated_by'''), ('translation_prompts', '''author:created_by''')) as v(t, args)
  loop
    execute format('drop trigger if exists zz_set_person on public.%I', x.t);
    execute format('create trigger zz_set_person before insert or update on public.%I for each row execute function public.set_person(%s)', x.t, x.args);
  end loop;
end $m$;

drop trigger if exists zz_own_login on public.collaboration_applications;
create trigger zz_own_login before insert or update on public.collaboration_applications
  for each row execute function public.own_login('user_email');

-- ============================================================================
-- 5. The profile: the login is the account's, and a profile stays its account's
-- ============================================================================
create or replace function public.guard_profile_login()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' then new.user_id := old.user_id; end if;
  new.email := coalesce((select r.email from public.user_roles r where r.user_id = new.user_id), new.email);
  return new;
end;
$$;
drop trigger if exists zz_guard_profile_login on public.user_profiles;
create trigger zz_guard_profile_login before insert or update on public.user_profiles
  for each row execute function public.guard_profile_login();
update public.user_profiles p set email = r.email from public.user_roles r where r.user_id = p.user_id and p.email is distinct from r.email;

-- ============================================================================
-- 6. Names: the leads meet whoever sends an idea (166)
-- ============================================================================
do $m$
declare v_def text;
begin
  v_def := pg_get_functiondef('public.people_names(uuid[], text[])'::regprocedure);
  if v_def !~ 'SUGGESTION' then
    execute replace(v_def, 'or (me.lead and exists (select 1 from public.share_with_us_messages s where s.user_id = a.user_id))',
      'or (me.lead and exists (select 1 from public.share_with_us_messages s where s.user_id = a.user_id))
      or (me.lead and exists (select 1 from public.chat_messages i where i.user_id = a.user_id and i.report_type = ''SUGGESTION''))');
  end if;
end $m$;

notify pgrst, 'reload schema';

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 1 as n, 'No login is left in posts and messages' as item,
       not exists (select 1 from public.board_posts where posted_by_email is not null or moderated_by_email is not null)
       and not exists (select 1 from public.formation_chat_messages where user_email is not null)
       and not exists (select 1 from public.department_messages where user_email is not null or pinned_by_email is not null)
       and not exists (select 1 from public.share_with_us_messages where user_email is not null)
       and not exists (select 1 from public.share_with_us_replies where user_email is not null)
       and not exists (select 1 from public.share_with_us_reactions where user_email is not null)
       and not exists (select 1 from public.chat_messages where user_email is not null or replied_by_email is not null) as ok
union all select 2, 'Nor in announcements, guides, texts and settings',
       not exists (select 1 from public.splash_messages where created_by_email is not null)
       and not exists (select 1 from public.help_pages where updated_by_email like '%@%')
       and not exists (select 1 from public.document_texts where updated_by_email like '%@%' or reviewed_by_email like '%@%')
       and not exists (select 1 from public.document_original_texts where updated_by_email like '%@%' or reviewed_by_email like '%@%')
       and not exists (select 1 from public.app_settings where updated_by_email like '%@%')
       and not exists (select 1 from public.onboarding_cards where created_by_email like '%@%')
union all select 3, 'Nor in memberships, applications, rates and prompts',
       not exists (select 1 from public.collaboration_applications where reviewed_by_email is not null or recommended_by_email is not null)
       and not exists (select 1 from public.task_category_rates where updated_by_email like '%@%') and not exists (select 1 from public.translation_prompts where created_by_email like '%@%') and
       not exists (select 1 from public.department_members where added_by_email like '%@%') and not exists (select 1 from public.board_editors where added_by_email like '%@%')
       and not exists (select 1 from public.formation_path_editors where added_by_email like '%@%')
union all select 4, 'The announcements have an author''s account',
       (select count(*) = 0 or count(created_by) > 0 from public.splash_messages)
union all select 5, 'Twenty-one tables keep no login', (select count(*) = 21 from pg_trigger where tgname = 'zz_keep_no_login' and tgenabled = 'O')
union all select 6, 'Thirteen tables say who writes', (select count(*) = 13 from pg_trigger where tgname = 'zz_set_person' and tgenabled = 'O')
union all select 7, 'An application carries the account''s own login', exists (select 1 from pg_trigger where tgname = 'zz_own_login' and tgenabled = 'O')
union all select 8, 'So does a profile', exists (select 1 from pg_trigger where tgname = 'zz_guard_profile_login' and tgenabled = 'O')
       and not exists (select 1 from public.user_profiles p join public.user_roles r using (user_id) where p.email is distinct from r.email)
union all select 9, 'The leads see who sends an idea', pg_get_functiondef('public.people_names(uuid[], text[])'::regprocedure) ~ 'SUGGESTION'
union all select 10, 'No trigger was left off', not exists (select 1 from pg_trigger t join pg_class c on c.oid = t.tgrelid join pg_namespace n on n.oid = c.relnamespace
         where n.nspname = 'public' and not t.tgisinternal and t.tgenabled = 'D'
           and exists (select 1 from pg_trigger z where z.tgrelid = c.oid and z.tgname in ('zz_keep_no_login', 'zz_set_person')))
order by 1;
