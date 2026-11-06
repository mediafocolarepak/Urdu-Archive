-- 120: date of birth instead of age bracket (Owner's decision, 2026-11-06). A bracket goes out of date as people
-- age; a date gives the right group every day, and lets Formation choose its audience by age later on.
--
-- A date is more delicate than a bracket, so it does NOT go in user_profiles, which any Coordinator can read in
-- full. It has its own table, readable only by the person, the HR lead and Admins. Everyone with a working need
-- (Coordinators, HR and Formation members) gets only the bracket, computed on request and stored nowhere.
--
-- Old brackets can't become dates. They stay in user_profiles.age_bracket as a fallback until the person gives
-- the date, and are then cleared. Run this BEFORE merging the PR. Safe to run again.

begin;

create table if not exists public.user_birth_dates (
  user_id       uuid primary key references auth.users(id) on delete cascade,
  date_of_birth date not null check (date_of_birth >= date '1900-01-01'),
  updated_at    timestamptz not null default now(),
  updated_by    uuid
);

alter table public.user_birth_dates enable row level security;
revoke all on public.user_birth_dates from anon;

-- Reading only. There is no write policy on purpose: writes go through set_date_of_birth() and the sign-up trigger.
drop policy if exists user_birth_dates_select on public.user_birth_dates;
create policy user_birth_dates_select on public.user_birth_dates
  for select using (
    auth.uid() = user_id
    or public.current_role_is('admin')
    or public.is_dept_lead('HR')
  );

-- The one place that defines the brackets. The codes are those of option list age_bracket, which holds their labels.
create or replace function public.age_bracket_of(p_dob date, p_on date default current_date)
returns text
language sql
stable
as $$
  select case
    when p_dob is null then null
    when extract(year from age(p_on, p_dob)) < 12 then 'LT12'
    when extract(year from age(p_on, p_dob)) < 18 then '12_17'
    when extract(year from age(p_on, p_dob)) < 31 then '18_30'
    when extract(year from age(p_on, p_dob)) < 66 then '31_65'
    else 'GT65'
  end;
$$;

-- Everyone's bracket, never a date, for those with a working need. from_date false means an old bracket, as declared.
drop function if exists public.people_age_brackets();
create function public.people_age_brackets()
returns table (user_id uuid, age_bracket text, from_date boolean)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not (public.current_role_is('coordinator') or public.is_dept_member('HR') or public.is_dept_member('FORM')) then
    raise exception 'Not allowed';
  end if;
  return query
    select r.user_id,
           coalesce(public.age_bracket_of(b.date_of_birth), p.age_bracket),
           b.date_of_birth is not null
    from public.user_roles r
    left join public.user_birth_dates b on b.user_id = r.user_id
    left join public.user_profiles p on p.user_id = r.user_id;
end;
$$;

-- A person sets their own date, an Admin anyone's. An empty date removes it. The value isn't copied to any log.
create or replace function public.set_date_of_birth(p_date date, p_user_id uuid default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_me uuid := auth.uid();
  v_target uuid := coalesce(p_user_id, v_me);
begin
  if v_me is null then raise exception 'Not signed in'; end if;
  if v_target <> v_me and not public.current_role_is('admin') then raise exception 'Not allowed'; end if;
  if p_date is null then
    delete from public.user_birth_dates where user_id = v_target;
    return;
  end if;
  if p_date < date '1900-01-01' or p_date > current_date then raise exception 'This date of birth is not possible'; end if;
  insert into public.user_birth_dates (user_id, date_of_birth, updated_at, updated_by)
  values (v_target, p_date, now(), v_me)
  on conflict (user_id) do update
    set date_of_birth = excluded.date_of_birth, updated_at = excluded.updated_at, updated_by = excluded.updated_by;
  update public.user_profiles set age_bracket = null where user_id = v_target and age_bracket is not null;
end;
$$;

revoke all on function public.people_age_brackets() from public, anon;
revoke all on function public.set_date_of_birth(date, uuid) from public, anon;
grant execute on function public.people_age_brackets() to authenticated;
grant execute on function public.set_date_of_birth(date, uuid) to authenticated;

-- Sign-up: same trigger as 85_signup_demographics.sql, with the date. The form can only send it through the account's
-- metadata, so it is moved to the protected table and removed from there. A bad date must never block a sign-up.
-- age_bracket stays accepted, for a phone still running the old form.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_dob date;
begin
  insert into public.user_roles (user_id, email, role)
  select new.id, new.email, 'user'
  where not exists (select 1 from public.user_roles where user_id = new.id);

  insert into public.user_profiles (user_id, email, full_name, city, membership_type, phone, age_bracket, gender)
  values (
    new.id, new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.raw_user_meta_data ->> 'city',
    new.raw_user_meta_data ->> 'membership_type',
    new.raw_user_meta_data ->> 'phone',
    new.raw_user_meta_data ->> 'age_bracket',
    new.raw_user_meta_data ->> 'gender'
  )
  on conflict (user_id) do nothing;

  if new.raw_user_meta_data ? 'date_of_birth' then
    begin
      v_dob := nullif(new.raw_user_meta_data ->> 'date_of_birth', '')::date;
      if v_dob >= date '1900-01-01' and v_dob <= current_date then
        insert into public.user_birth_dates (user_id, date_of_birth, updated_by)
        values (new.id, v_dob, new.id)
        on conflict (user_id) do nothing;
      end if;
      update auth.users
      set raw_user_meta_data = raw_user_meta_data - 'date_of_birth'
      where id = new.id;
    exception when others then
      raise warning 'Date of birth not saved at sign-up: %', sqlerrm;
    end;
  end if;

  return new;
end;
$$;

-- The guide of the HR page describes the new column of People (all three languages; only this sentence changes).
update public.help_pages set html_content = replace(html_content,
    '<p>Everyone on the team: role, standing, credits, reputation, qualifications, departments.',
    '<p>Everyone on the team: role, standing, age group, credits, reputation, qualifications, departments. The HR lead also sees the date of birth; other members see only the age group.'),
  updated_at = now(), updated_by_email = 'migration 120'
where slug = 'dept-hr_en' and html_content not like '%age group, credits%';

update public.help_pages set html_content = replace(html_content,
    '<p>Tutto il team: ruolo, posizione, crediti, reputazione, qualifiche, reparti.',
    '<p>Tutto il team: ruolo, posizione, fascia d''età, crediti, reputazione, qualifiche, reparti. Il responsabile di HR vede anche la data di nascita; gli altri membri solo la fascia.'),
  updated_at = now(), updated_by_email = 'migration 120'
where slug = 'dept-hr_it' and html_content not like '%fascia d''età, crediti%';

update public.help_pages set html_content = replace(html_content,
    '<p>پوری ٹیم: کردار، حیثیت، کریڈٹ، ساکھ، اہلیتیں، شعبے۔',
    '<p>پوری ٹیم: کردار، حیثیت، عمر کا گروپ، کریڈٹ، ساکھ، اہلیتیں، شعبے۔ HR کا سربراہ تاریخِ پیدائش بھی دیکھتا ہے؛ دوسرے ارکان صرف عمر کا گروپ۔'),
  updated_at = now(), updated_by_email = 'migration 120'
where slug = 'dept-hr_ur' and html_content not like '%عمر کا گروپ، کریڈٹ%';

commit;

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 'table user_birth_dates has row-level security on' as item,
       (select relrowsecurity from pg_class where oid = 'public.user_birth_dates'::regclass) as ok
union all select 'only one rule, and it is for reading',
       (select count(*) = 1 and bool_and(cmd = 'SELECT') from pg_policies where tablename = 'user_birth_dates')
union all select 'date of birth not added to user_profiles',
       (select count(*) = 0 from information_schema.columns where table_name = 'user_profiles' and column_name = 'date_of_birth')
union all select 'brackets at their edges: 11, 12, 17, 18, 30, 31, 65, 66',
       (select array_agg(public.age_bracket_of(d, date '2026-11-06') order by d desc) =
               array['LT12','12_17','12_17','18_30','18_30','31_65','31_65','GT65']
        from unnest(array[date '2015-01-01', date '2014-11-06', date '2009-01-01', date '2008-11-06',
                          date '1996-01-01', date '1995-11-06', date '1961-01-01', date '1960-11-06']) d)
union all select 'bracket labels are all there (5)',
       (select count(*) = 5 from public.option_lists where list_name = 'age_bracket' and code in ('LT12','12_17','18_30','31_65','GT65'))
union all select 'sign-up trigger handles the date',
       (select prosrc like '%user_birth_dates%' from pg_proc where proname = 'handle_new_user')
union all select 'HR guide updated in all 3 languages',
       (select count(*) = 3 from public.help_pages where slug in ('dept-hr_en', 'dept-hr_it', 'dept-hr_ur')
          and (html_content like '%age group, credits%' or html_content like '%fascia d''età, crediti%' or html_content like '%عمر کا گروپ، کریڈٹ%'));
