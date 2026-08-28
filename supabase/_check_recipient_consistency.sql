-- Read-only: any recipient code actually used on a document that has NO matching row in
-- option_lists (list_name='recipient') would show up here as unlabelled/unselectable in a
-- dropdown. Empty result = safe to switch the Recipient filter to a dropdown.
select distinct unnest(recipient) as orphan_recipient_code
from documents
where recipient is not null
except
select code from option_lists where list_name = 'recipient';
