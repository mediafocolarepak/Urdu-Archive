-- Adds a separate "Operator" field (the person who provided/handled a batch of material),
-- kept distinct from "Source" (documents.provenance, now labelled "Source" in the UI - the
-- column name itself is unchanged to avoid touching every query in the app).

alter table documents add column if not exists operator text;
create index if not exists idx_documents_operator on documents(operator);

insert into option_lists (list_name, code, label, sort_order) values
  ('operator', 'UNKN', 'Unknown', 1)
on conflict (list_name, code) do update set label = excluded.label, sort_order = excluded.sort_order;

select 'operator field ready: documents.operator column=' ||
  (select count(*) from information_schema.columns where table_name = 'documents' and column_name = 'operator')
  || ', operator options=' || (select count(*) from option_lists where list_name = 'operator') as result;
