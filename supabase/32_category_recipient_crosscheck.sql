-- Documents whose category is really describing a recipient/target-audience (Gen 2/3/4,
-- Volunteers, Religious) - copies that value into recipient. category itself is left untouched
-- (only recipient is being asked for here); only fills recipient where currently null, so it
-- never overwrites something already set.
update documents d
set recipient = array[ocat.label]
from option_lists ocat
where ocat.list_name = 'category' and ocat.code = d.category
  and (ocat.label in (select code from option_lists where list_name = 'recipient')
       or ocat.label in (select label from option_lists where list_name = 'recipient'))
  and d.recipient is null;

select 'recipient filled from category' as label, count(*) as n
from documents d
join option_lists ocat on ocat.list_name = 'category' and ocat.code = d.category
where ocat.label in (select code from option_lists where list_name = 'recipient')
   or ocat.label in (select label from option_lists where list_name = 'recipient');
