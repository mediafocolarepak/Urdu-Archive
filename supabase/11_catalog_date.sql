alter table documents add column if not exists catalog_date date;
select 'catalog_date column ready' as result;
