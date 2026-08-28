-- Adds a simple Yes/No flag for "a video also exists for this document".
alter table documents add column if not exists has_video boolean not null default false;

select 'has_video column ready' as result;
