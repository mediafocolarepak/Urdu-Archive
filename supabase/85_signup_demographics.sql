-- 85_signup_demographics.sql
-- HR asked for age bracket and gender at signup, for statistics (session of 17/09/2026). Age is
-- a bracket, not a birthdate: easier to pick, and avoids storing an exact date of birth we have
-- no real use for. Existing accounts get both columns null - HR will backfill separately; the
-- signup trigger only fills them for accounts created from now on.

alter table public.user_profiles add column if not exists age_bracket text;
alter table public.user_profiles add column if not exists gender text check (gender in ('M', 'F'));

insert into public.option_lists (list_name, code, label, sort_order) values
  ('age_bracket', 'LT12',  'Less than 12 years', 1),
  ('age_bracket', '12_17', '12-17 years',        2),
  ('age_bracket', '18_30', '18-30 years',        3),
  ('age_bracket', '31_65', '31-65 years',        4),
  ('age_bracket', 'GT65',  'More than 65 years', 5)
on conflict (list_name, code) do nothing;

-- Same trigger as 16_signup_chat_splash.sql, extended with the two new fields (still travel in
-- signUp()'s options.data -> raw_user_meta_data, same mechanism as full_name/city/etc.).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
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

  return new;
end;
$$;

-- Self-test.
select 'user_profiles.age_bracket' as item, exists (select 1 from information_schema.columns where table_name = 'user_profiles' and column_name = 'age_bracket') as ok
union all select 'user_profiles.gender', exists (select 1 from information_schema.columns where table_name = 'user_profiles' and column_name = 'gender')
union all select 'option list age_bracket (5)', (select count(*) = 5 from option_lists where list_name = 'age_bracket');
