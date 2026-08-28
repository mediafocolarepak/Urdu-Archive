-- STEP 1 - PREVIEW (read-only). Shows which recipient codes in option_lists are no longer
-- referenced by any document (across the whole recipient array, not just the first element,
-- as a safety net for any leftover multi-value legacy data).
select code, label from option_lists
where list_name = 'recipient'
  and code not in (select distinct unnest(recipient) from documents where recipient is not null)
order by code;

-- STEP 2 - delete those codes, except the 4 just-added-but-not-yet-used ones (kept for future
-- use: Priests, Seminarians, Others, New Umanity).
delete from option_lists
where list_name = 'recipient'
  and code not in (select distinct unnest(recipient) from documents where recipient is not null)
  and code not in ('Priests', 'Seminarians', 'Others', 'New Umanity');

select 'recipient options remaining' as label, count(*) as n from option_lists where list_name = 'recipient';
