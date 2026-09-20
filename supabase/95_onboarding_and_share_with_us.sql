-- 95_onboarding_and_share_with_us.sql
-- Two additions, scoped together in one long conversation with the owner (sociological/
-- psychological/marketing framing, see PROJECT_HANDOFF for this session): a new onboarding hub
-- for Users ("Start Here", replacing the technical Help tab for that role only) and a new
-- relational feedback channel, "Share with us".
--
-- 1. onboarding_cards: bilingual (Urdu + English gloss) cards authored by the Communication
--    department, grouped into three sections - what this is, how to use it, how to collaborate.
--    Phase 1a: text/image/external-video-link cards only.
-- 2. formation_paths gains title_en/description_en (nullable): the same bilingual treatment,
--    since path content is already written in Urdu.
-- 3. share_with_us_messages / _reactions / _replies: a User (or anyone) can share an experience,
--    feeling or idea - not a bug/task report (that stays chat_messages, unchanged). Every
--    department lead and Admin can read every share, thank it, and reply; multiple leads can each
--    thank and reply to the same share, unlike chat_messages' single-reply-column shape. The
--    owner's own framing: "amore che va e che torna" - reciprocal, not a ticket queue.
--    Voice messages are explicitly deferred to phase 1b - not in this migration.
--
-- Run after 94_department_messages.sql. Idempotent, self-test at the end.

-- ============================================================================
-- 1. Onboarding cards (Communication department content)
-- ============================================================================
create table if not exists public.onboarding_cards (
  id               bigint generated always as identity primary key,
  section          text        not null check (section in ('about', 'how_to_use', 'how_to_collaborate')),
  title_ur         text        not null,
  title_en         text,
  body_ur          text,
  body_en          text,
  media_type       text        not null default 'text' check (media_type in ('text', 'image', 'video')),
  -- external link (YouTube/Facebook/Instagram, wherever Communication already publishes) for a
  -- 'video' card - no video upload/hosting/player in this app, decided with the owner.
  media_url        text,
  thumbnail_path   text,       -- storage path in the onboarding-media bucket, the card's cover image
  sort_order       integer     not null default 0,
  published        boolean     not null default true,
  created_by_email text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index if not exists idx_onboarding_cards_order
  on public.onboarding_cards (section, sort_order, created_at);

alter table public.onboarding_cards enable row level security;

drop policy if exists "onboarding_cards_select" on public.onboarding_cards;
create policy "onboarding_cards_select" on public.onboarding_cards
  for select using (current_role_is('user'));

drop policy if exists "onboarding_cards_write" on public.onboarding_cards;
create policy "onboarding_cards_write" on public.onboarding_cards
  for all
  using (public.is_dept_member('COMM') or current_role_is('admin'))
  with check (public.is_dept_member('COMM') or current_role_is('admin'));

-- Storage bucket for card cover images - public read (this is outreach content, nothing
-- sensitive), same shape as board-media (84_boards_moderation.sql). 5 MB cap per file.
insert into storage.buckets (id, name, public, file_size_limit)
values ('onboarding-media', 'onboarding-media', true, 5242880)
on conflict (id) do nothing;

drop policy if exists "read - onboarding-media" on storage.objects;
drop policy if exists "upload - onboarding-media" on storage.objects;
drop policy if exists "delete - onboarding-media" on storage.objects;

create policy "read - onboarding-media" on storage.objects for select
  using (bucket_id = 'onboarding-media');
create policy "upload - onboarding-media" on storage.objects for insert
  to authenticated with check (
    bucket_id = 'onboarding-media' and (public.is_dept_member('COMM') or current_role_is('admin'))
  );
create policy "delete - onboarding-media" on storage.objects for delete
  to authenticated using (
    bucket_id = 'onboarding-media' and (public.is_dept_member('COMM') or current_role_is('admin'))
  );

-- ============================================================================
-- 2. Formation paths: optional English gloss alongside the (already Urdu) title/description.
-- ============================================================================
alter table public.formation_paths add column if not exists title_en text;
alter table public.formation_paths add column if not exists description_en text;

-- ============================================================================
-- 3. Share with us
-- ============================================================================
create table if not exists public.share_with_us_messages (
  id         bigint generated always as identity primary key,
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  user_email text,
  body       text        not null check (btrim(body) <> ''),
  created_at timestamptz not null default now()
);
create index if not exists idx_share_with_us_messages_recent on public.share_with_us_messages (created_at desc);

alter table public.share_with_us_messages enable row level security;

drop policy if exists "share_with_us_messages_select" on public.share_with_us_messages;
create policy "share_with_us_messages_select" on public.share_with_us_messages
  for select using (
    user_id = auth.uid() or public.is_any_dept_lead() or current_role_is('admin')
  );

-- Open to any signed-in team member, not narrowed to the User role - an Operator or Coordinator
-- may just as well want to share an experience, and there is no reason to gate that here.
drop policy if exists "share_with_us_messages_insert" on public.share_with_us_messages;
create policy "share_with_us_messages_insert" on public.share_with_us_messages
  for insert with check (user_id = auth.uid() and current_role_is('user'));
-- No update/delete policy: append-only, same philosophy as people_decisions and board posts -
-- a shared feeling doesn't get silently edited or erased once someone may have responded to it.

create table if not exists public.share_with_us_reactions (
  message_id bigint      not null references public.share_with_us_messages(id) on delete cascade,
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  user_email text,
  created_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

alter table public.share_with_us_reactions enable row level security;

drop policy if exists "share_with_us_reactions_select" on public.share_with_us_reactions;
create policy "share_with_us_reactions_select" on public.share_with_us_reactions
  for select using (
    public.is_any_dept_lead() or current_role_is('admin')
    or exists (
      select 1 from public.share_with_us_messages m
      where m.id = share_with_us_reactions.message_id and m.user_id = auth.uid()
    )
  );

drop policy if exists "share_with_us_reactions_insert" on public.share_with_us_reactions;
create policy "share_with_us_reactions_insert" on public.share_with_us_reactions
  for insert with check (
    user_id = auth.uid() and (public.is_any_dept_lead() or current_role_is('admin'))
  );

-- A lead can withdraw their own "thank you" - same toggle UX as user_favorites (star/unstar).
drop policy if exists "share_with_us_reactions_delete" on public.share_with_us_reactions;
create policy "share_with_us_reactions_delete" on public.share_with_us_reactions
  for delete using (user_id = auth.uid());

create table if not exists public.share_with_us_replies (
  id         bigint generated always as identity primary key,
  message_id bigint      not null references public.share_with_us_messages(id) on delete cascade,
  user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  user_email text,
  body       text        not null check (btrim(body) <> ''),
  created_at timestamptz not null default now()
);
create index if not exists idx_share_with_us_replies_by_message on public.share_with_us_replies (message_id, created_at);

alter table public.share_with_us_replies enable row level security;

drop policy if exists "share_with_us_replies_select" on public.share_with_us_replies;
create policy "share_with_us_replies_select" on public.share_with_us_replies
  for select using (
    public.is_any_dept_lead() or current_role_is('admin')
    or exists (
      select 1 from public.share_with_us_messages m
      where m.id = share_with_us_replies.message_id and m.user_id = auth.uid()
    )
  );

-- Every lead's reply stays its own row (unlike chat_messages' single reply_text column) - several
-- leads can each respond to the same share, so nobody's "thank you for sharing this" overwrites
-- another's.
drop policy if exists "share_with_us_replies_insert" on public.share_with_us_replies;
create policy "share_with_us_replies_insert" on public.share_with_us_replies
  for insert with check (
    user_id = auth.uid() and (public.is_any_dept_lead() or current_role_is('admin'))
  );

-- ============================================================================
-- 4. Self-test (run separately). All rows must be true.
-- ============================================================================
select 'table onboarding_cards' as item, (to_regclass('public.onboarding_cards') is not null) as ok
union all select 'policies onboarding_cards (2)', (select count(*) = 2 from pg_policies where tablename = 'onboarding_cards')
union all select 'storage bucket onboarding-media (public)', exists (select 1 from storage.buckets where id = 'onboarding-media' and public = true)
union all select 'storage policies onboarding-media (3)', (select count(*) = 3 from pg_policies where tablename = 'objects' and policyname like '%onboarding-media%')
union all select 'formation_paths.title_en', exists (select 1 from information_schema.columns where table_name = 'formation_paths' and column_name = 'title_en')
union all select 'formation_paths.description_en', exists (select 1 from information_schema.columns where table_name = 'formation_paths' and column_name = 'description_en')
union all select 'table share_with_us_messages', (to_regclass('public.share_with_us_messages') is not null)
union all select 'table share_with_us_reactions', (to_regclass('public.share_with_us_reactions') is not null)
union all select 'table share_with_us_replies', (to_regclass('public.share_with_us_replies') is not null)
union all select 'policies share_with_us_messages (2)', (select count(*) = 2 from pg_policies where tablename = 'share_with_us_messages')
union all select 'policies share_with_us_reactions (3)', (select count(*) = 3 from pg_policies where tablename = 'share_with_us_reactions')
union all select 'policies share_with_us_replies (2)', (select count(*) = 2 from pg_policies where tablename = 'share_with_us_replies');
