-- Cross-reference lists (Collegamenti italiani, Video index, Parola di Vita) + matching fields
-- on documents. Designed to grow: adding a new future list is just a new table like these three.

create table if not exists ref_collegamenti (
  id serial primary key,
  anno text,
  data date,
  luogo text,
  titolo text
);

create table if not exists ref_video_index (
  id serial primary key,
  numero text,
  autore text,
  descrizione text,
  data date,
  durata text,
  note text
);

create table if not exists ref_parola_di_vita (
  id serial primary key,
  anno text,
  mese text,
  versetto text,
  riferimento text,
  link text
);

alter table documents add column if not exists italian_title text;
alter table documents add column if not exists video_ref text;
alter table documents add column if not exists pdv_ref text;

alter table ref_collegamenti enable row level security;
alter table ref_video_index enable row level security;
alter table ref_parola_di_vita enable row level security;

drop policy if exists "read - ref_collegamenti" on ref_collegamenti;
create policy "read - ref_collegamenti" on ref_collegamenti for select to authenticated using (current_role_is('user'));
drop policy if exists "write - ref_collegamenti" on ref_collegamenti;
create policy "write - ref_collegamenti" on ref_collegamenti for all to authenticated
  using (current_role_is('operator')) with check (current_role_is('operator'));

drop policy if exists "read - ref_video_index" on ref_video_index;
create policy "read - ref_video_index" on ref_video_index for select to authenticated using (current_role_is('user'));
drop policy if exists "write - ref_video_index" on ref_video_index;
create policy "write - ref_video_index" on ref_video_index for all to authenticated
  using (current_role_is('operator')) with check (current_role_is('operator'));

drop policy if exists "read - ref_parola_di_vita" on ref_parola_di_vita;
create policy "read - ref_parola_di_vita" on ref_parola_di_vita for select to authenticated using (current_role_is('user'));
drop policy if exists "write - ref_parola_di_vita" on ref_parola_di_vita;
create policy "write - ref_parola_di_vita" on ref_parola_di_vita for all to authenticated
  using (current_role_is('operator')) with check (current_role_is('operator'));

select 'cross-reference schema ready' as result;
