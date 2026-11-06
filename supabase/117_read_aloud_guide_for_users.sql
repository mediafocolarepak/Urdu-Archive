-- 117: the Read aloud guide is for plain Users too, since they can read aloud (Owner's decision, 2026-11-06).
-- This shows a guide to those who already have the Read aloud tab. It is not the announcement of Read aloud.
-- Touches only the audience of this guide, so edits made in the app stay. Safe to run again.

update public.help_pages
set audience = array_append(audience, 'user')
where guide_key = 'read-aloud'
  and not ('user' = any(audience));

-- ============================================================================
-- Self-test: the SQL Editor shows only this last result. All rows must be true.
-- ============================================================================
select 'Read aloud guide shown to plain Users, in both languages' as item,
       (select count(*) = 2 from public.help_pages where guide_key = 'read-aloud' and 'user' = any(audience)) as ok
union all select 'still shown to Operators and up',
       (select count(*) = 2 from public.help_pages where guide_key = 'read-aloud' and 'operator' = any(audience))
union all select 'audience added once only',
       (select count(*) = 0 from public.help_pages where guide_key = 'read-aloud' and array_length(array_positions(audience, 'user'), 1) > 1)
union all select 'other guides for Operators not changed',
       (select count(*) = 0 from public.help_pages where guide_key = 'propose' and 'user' = any(audience));
