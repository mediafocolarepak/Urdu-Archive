-- 97_share_with_us_operators.sql
-- "Share with us" (95_onboarding_and_share_with_us.sql) gains the tab in the Operator UI
-- (owner's request 2026-09-20): "so anche loro possono dare un loro feedback al team dei lead e
-- admins". 95's own insert policy comment already said "an Operator or Coordinator may just as
-- well want to share an experience, and there is no reason to gate that here" - but the actual
-- check() only ever allowed current_role_is('user'), so an Operator posting from the new tab
-- would have hit an RLS violation on every Send. This migration is that comment finally matching
-- the code, scoped to Operator only (Coordinator wasn't asked for and keeps its existing access
-- as a reader via is_any_dept_lead()/admin, not as a sharer).
--
-- Run after 96_share_with_us_audio.sql. Idempotent, self-test at the end.

drop policy if exists "share_with_us_messages_insert" on public.share_with_us_messages;
create policy "share_with_us_messages_insert" on public.share_with_us_messages
  for insert with check (
    user_id = auth.uid() and (current_role_is('user') or current_role_is('operator'))
  );

-- ============================================================================
-- Self-test (run separately). All rows must be true.
-- ============================================================================
select 'policies share_with_us_messages (2)' as item, (select count(*) = 2 from pg_policies where tablename = 'share_with_us_messages') as ok;
