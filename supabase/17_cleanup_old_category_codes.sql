-- Removes the superseded DISC/LINK/WORD/... category codes from option_lists, now that
-- 15_versions_editors_schema.sql switched the Category dropdown over to the original Access
-- codes (Tlk/Mdt/Lkp/...). Safe: a code is only deleted if no document currently uses it -
-- anything still in use keeps its label instead of turning into a blank/unlabelled value.

-- Informational: which old codes (if any) are still actually assigned to a document.
select category, count(*) as documents_using_it
from documents
where category in ('DISC','LINK','WORD','EXPE','DIAR','MEDI','PAR4','REGU','LETT','MISC')
group by category
order by category;

delete from option_lists
where list_name = 'category'
  and code in ('DISC','LINK','WORD','EXPE','DIAR','MEDI','PAR4','REGU','LETT','MISC')
  and not exists (select 1 from documents d where d.category = option_lists.code);

select 'category options remaining: ' || (select count(*) from option_lists where list_name = 'category') as result;
