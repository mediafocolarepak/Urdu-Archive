# Governance — roles, departments and decision policies

**Status: v1.2 (2026-09-18) — decisions taken by the Owner; all of phases 1 through 3 are built and
merged (migrations 80–93). Team comments welcome, changes go through a new version.**

**What changed in v1.2:** same day as v1.1, later session. Reward's last open piece (compensation
runs, the anomaly report) shipped (migration 91), closing phase 3 entirely — §6.4 moves from "to
build" to §5 alongside everything else. Formation paths were also restructured at the owner's
request: the "Years" level between a path and its modules is gone (migration 92 — Path → Module →
Chapter → Post, one level shallower), modules/chapters are now shown as a numbered outline instead
of a nested tree, and a thumbnail image can be set per path for the catalog (migration 93). A new
printable Personnel & Team Applications report (Print Reports, Admin/HR) was added, reusing
existing data sources — no new migration. No organisational decision changes here either; still a
"catch the docs up to the code" pass.

This document describes how the people who run the **Focolare Urdu Archive Manager** are
organised: who does what, who decides what, and how that maps onto the software. It exists
because the project has moved from a one-person effort to a team spread across several cities,
and decisions that used to live in one head now need to be written down.

It is written in two layers, kept deliberately separate:

- **Organisation** (§2–§4): roles, departments, decision rules. These are policies about people.
  They can be changed by the team without touching the code.
- **Software** (§5–§7): what the application already does, what must be built to support the
  organisation, and in what order. This is the part that becomes migrations and JS.

Companion documents: `COLLABORATION.md` (developer workflow), `HANDOFF.md` and the
`PROJECT_HANDOFF_vNN.md` series (technical state), `TEAM_UPDATE_vNN.md` series (what changed for
the team, session by session).

---

## 1. Principles

1. **Departments are roles, not offices.** A department is a set of responsibilities plus the
   permissions needed to carry them out. A person can belong to several. A department with one
   member is still a department. We create the structure now so it is ready when the people
   arrive, not the other way round.
2. **Separation of duties is rigid.** Nobody may, alone, (a) admit a person, (b) assign them
   work, and (c) decide what they are paid for it. HR, Coordination and Reward stay in
   different hands even while the team is small. Where the same person must temporarily wear two
   hats, the rule is *the one who proposes does not approve*.
3. **Admin is a technical role, not a governance role.** Admin means "can change configuration
   and data". It does not mean "decides". Decisions on people, work and money belong to the
   departments; Admin executes them and keeps the system running.
4. **Every decision that affects a person, a task's value or a payment is recorded** with who
   proposed it, who approved it, when, and why. This is already how credits and reputation work
   (`task_outcome_events`): the same append-only pattern is extended to people decisions.
5. **One lead per department.** The lead is accountable for the department's decisions and is
   the approver of last resort inside it. Leads are appointed by the project owner.

---

## 2. Departments

### 2.1 HR (Human Resources)

*Mission:* follow every active person in the programme — from operator to admin — from first
contact to exit.

Responsibilities:
- Screen and filter **Join the Team** applications; interview where needed; **propose**
  admission (see §4: HR proposes, a lead/Admin approves).
- Run **recruitment campaigns** when a project needs specific skills (translators from Italian,
  proofreaders, transcribers, content creators…).
- **Onboard** new operators: welcome, first tasks, assignment of qualifications (proposed by
  HR, set by Admin).
- **Monitor** operators, coordinators and admins: credits, reputation, recent outcomes, activity;
  maintain a watch list ("at risk", "monitor closely") with reasons.
- **Propose** suspension, exclusion or re-admission, with a written motivation.
- **Training** of operators — to be designed later (see §7); the Formation Paths tool can be
  used for onboarding courses today without new code.

Needs from the software: a consolidated **HR view** (§5.3, built) — one screen with every team
member, their role, qualifications, credits, reputation, last activity, outcome history, watch
status, and pending applications — plus a **printable Personnel & Team Applications report**
(§5.7, built) for bringing the same picture to a meeting.

### 2.2 Coordination

*Mission:* keep the flow of work orderly and consistent.

Responsibilities:
- Create tasks, set base credits from the rate table, assign or leave open, reassign when stuck.
- Review submitted work (verdict OK / OK-but / Fail), with the Revisors.
- Enforce deadlines; reclaim abandoned tasks (this carries a reputation penalty, so it is a
  decision that gets recorded).
- Escalate to HR when a person's behaviour, not just a single task, is the problem.
- Keep the document workflow (revision → proofreading → approval → publication) moving.

This is what the **Coordinator** role already does today; the department formalises it and
gives it a lead.

### 2.3 Formation (Formatori)

*Mission:* build and run formation paths (courses) on the archive's material.

Responsibilities:
- Design formation paths: modules → chapters, with linked documents, quizzes, final certificate
  (simplified from an earlier modules-inside-years shape — §5.4). A path has one **owner** and
  any number of **co-authors** (other formatori invited by the owner) who edit it together; the
  owner — or the Formation lead — publishes it. Working together on a course is the preferred
  way, not the exception.
- Bring new material into the archive **through the normal document workflow** — a formatore
  uploading a text is an operator uploading a text: it goes through revision and approval like
  any other. Formation never becomes a side door into the archive.
- Maintain the quiz bank; use AI tools with a standard prompt to draft module summaries and
  quizzes, then import them.
- Run enrolments, answer learners in the path chat, issue certificates.
- **Curate the boards** (§2.6): the editors of each board are formatori; they moderate what
  members submit and enforce the board usage policy.

Today "formatore" = anyone with at least one row in `board_editors` (§5.3). The department
replaces that implicit definition with an explicit one: **Formation membership decides who may
create paths; `board_editors` decides who curates each board.** The two are related but
distinct.

### 2.4 Reward

*Mission:* the credit and compensation system is fair, transparent, lawful and fraud-proof.

Responsibilities:
- Own the **policies**: what a credit is worth, per-category rates, extra-credit rules,
  reputation tiers, when and how credits are converted to compensation, what documentation is
  required.
- Approve changes to the rate table and reputation tiers (Admin applies them).
- Review the budget ledger and the outcome ledger; reconcile; flag anomalies (a task published
  with unusual extra credits, an operator whose credits grow faster than their published work).
- Sign off periodic compensation runs.
- Keep whatever records local law and the Movement's rules require.

**Policy before software.** The biggest risk was never technical: it was that these rules were
not written. They now are (`docs/REWARD_POLICY.md`, trial phase — §2.8, §8 item 6); the software
Reward needs — credit circulation, compensation runs, the anomaly report — is now built (§5.5).

### 2.5 Communication

*Mission:* people know the platform exists, know what is new, and know how to use it.

Responsibilities:
- Video tutorials and short guides; keep the in-app Help aligned with them.
- Announce releases and new features (in-app Announcements tab + social channels).
- Promote recruitment campaigns on HR's behalf.

Needs from the software: almost nothing — possibly a "What's new" section. This department is
people work, not code work.

### 2.6 Boards — a shared space, distinct from the archive

Boards are where formatori and members meet: ideas, proposals, texts for meditation, links to
a video, an image. They are **not part of the archive** and never become archive records: the
archive is the official corpus with its catalogue fields, revision workflow and credits; a
board post has none of those and must not pollute searches, reports, tasks or statistics.
If a board text deserves the archive, a formatore or coordinator **promotes** it — a document
is created in the normal revision workflow, with the usual review and approval.

Who may post:
- **Board editors** (formatori assigned to that board) and **Coordinators**: publish directly;
  they also moderate.
- **Operators**: publish directly, without prior approval — they have been screened by HR and
  have a reputation at stake.
- **Users** (anyone with an account): may **submit** a post; it stays pending until an editor of
  that board publishes or rejects it (with a short note).

**Board usage policy** (to be shown in the app before the first post, and in Help):
- A board is for content that serves the formation and spiritual life of that group: reflections,
  proposals, texts, links, images related to it.
- Not for: general announcements, personal messages, advertising, chain content, anything
  misleading, off-topic, or contrary to the spirit of the Movement.
- Editors may remove any post that breaks the policy, stating the reason. The author is
  notified.
- **Repeated or serious misuse is penalised**: a reputation penalty for operators (recorded in the
  outcome ledger, like any other conduct event), loss of posting rights for users; both
  proposed by the board editor and approved by the Formation lead or HR (decision rows 21–22 in
  §4). Misuse of a board is a people matter, so it follows the same propose/approve rule as
  every other decision about a person.

### 2.7 Membership rules

- A person may belong to any number of departments.
- Each department has exactly **one lead**, appointed by the project owner. During the current
  experimental phase one person may lead two departments (§8.1); the goal is one lead each.
- The three "control" departments — HR, Coordination, Reward — should have
  **different leads**; this is the target, waived during the experimental phase (§8.1). What is
  never waived is the rule on each single decision: the person who proposes does not approve.
- Admin (technical) may be a member of any department but should not lead HR or Reward while also being the only Admin — otherwise the separation in principle 2 is empty.

### 2.8 Policy revision process

The platform is in an experimental, trial phase (started 2026-09-17): none of the operational
policy tables (`task_category_rates`, `task_reputation_tiers`, `policy_values`, and any future
editable policy table) are meant to be final. They must stay changeable for as long as the
project runs — but a change must never be a single Admin's unilateral decision. It is a team
decision that an Admin only **applies**.

**Who owns which policy table** (who may propose a change to it):
- `task_category_rates`, `task_reputation_tiers`, extra-credit thresholds — Reward (§2.4)
- risk thresholds (`risk_negative_events`, `risk_reputation_below`, `risk_window_days`) — HR and
  Reward jointly (§2.1, §2.4)
- board-related policy values (`board_misuse_reputation_delta`) — Formation and HR jointly (§2.6)
- any future policy value — the department whose mission it serves; ambiguous cases go to the
  Owner.

**Process:**
1. **Propose.** Any department lead may draft a policy change: which table/key, the current
   value, the proposed value, and the reason. The proposal is recorded — never applied directly.
2. **Review.** The team (Admins and department leads) reviews the proposal — in a meeting, on a
   call, or however the group works at the time; the process does not require a specific review
   medium, only that the outcome is recorded.
3. **Approve or reject.** An Admin who is not the proposer applies the decision. Approving a
   change writes the new value to the live table (with `updated_by_email` and a link back to the
   proposal); rejecting closes the proposal with a reason. An Admin may never change a policy
   table's value except by applying an already-decided proposal — never on their own initiative
   alone (principle 2, §1).
4. **Record.** Every department keeps its own policy revision history: every proposal, who
   proposed it, the decision, who decided, and when — visible to that department's members and to
   Admin, forever (nothing is deleted, same as `task_outcome_events` and the people-decision log).
5. **Consult.** The current value of every policy table stays visible to everyone for read-only
   consultation; editing happens only through this process, never through a direct table edit
   outside it.

This mirrors principle 2 (§1) — the one who proposes does not approve — applied to policy
instead of people. It generalizes row 13 of the decision matrix (§4) beyond Reward's two tables,
and formalizes what row 14 ("Compensation policy... recorded in Policy document (repo)") always
implied: a policy document in the repo (e.g. `docs/REWARD_POLICY.md`) is the trial-phase
substitute for this in-app workflow, not a replacement for it. Now that §5.6 is built, in-app
proposals are the record of truth; `docs/REWARD_POLICY.md` is a human-readable summary to be kept
in sync with it, not the primary record.

---

## 3. Technical roles (unchanged)

The application's four-tier role hierarchy stays as it is. Departments sit *on top of* it, they
do not replace it.

| Role | What it grants (DB level) |
|---|---|
| **User** | Read the archive; report problems; apply to join the team. |
| **Operator** | Everything above + write documents, claim and submit tasks. Qualifications (Translator, Revisor, Proof Reader, Content Creator…) gate which task categories they can take. |
| **Coordinator** | Everything above + create/assign/review tasks, see applications and everyone's qualifications and outcome history, recommend applicants. |
| **Admin** | Everything above + change roles and qualifications, publish/reject reviewed tasks, edit option lists, rates, tiers, budget ledger, announcements; delete. |

Department membership will add *specific* permissions to whoever holds it (e.g. HR members can
see the HR view whatever their technical role). It never removes a permission the technical role
grants.

---

## 4. Decision matrix

For each recurring decision: who **proposes**, who **approves**, who is **informed**, and where
it is **recorded**. "Lead" means the lead of the department named. "Owner" is the project
owner. Where Approver is "Lead / Admin", either is sufficient — but never the same person who
proposed.

| # | Decision | Proposes | Approves | Informed | Recorded in |
|---|---|---|---|---|---|
| 1 | Admit an applicant as Operator | HR | Lead HR or Admin (not the proposer) | Coordination | `collaboration_applications` (recommended → approved) |
| 2 | Reject an applicant | HR | — (HR decides; applicant may reapply) | — | `collaboration_applications` |
| 3 | Assign / remove a qualification | HR (or Coordination) | Admin applies | Person concerned | `user_qualifications` + people-decision log (§5.3) |
| 4 | Put a person on the watch list | HR | — (HR decides, must give reason) | Lead HR | people-decision log |
| 5 | Suspend a person (no new tasks) | HR | Lead HR or Admin (not the proposer) | Coordination, person | people-decision log; `user_roles.standing` |
| 6 | Exclude a person (remove access) | HR | Owner | All leads | people-decision log; role removal |
| 7 | Promote to Coordinator / Admin | Owner or Lead HR | Owner | All leads | people-decision log |
| 8 | Appoint / replace a department lead | Owner | Owner | Everyone | `department_members` |
| 9 | Create a task, set its credits | Coordinator | — (within rate table) | — | `tasks` |
| 10 | Grant extra credits beyond the rate | Coordinator (with note) | Lead Coordination if above the threshold in Options (§8.3) | Reward | `tasks.extra_credits`, note; enforced server-side since migration 90 (`tasks.extra_credits_status`, `approve_task_extra_credits()`) |
| 11 | Reclaim a task (reputation penalty) | Coordinator | — (must give reason) | Person | `task_outcome_events` |
| 12 | Final publish / reject of a reviewed task | Revisor/Coordinator (verdict) | Admin | Person | `task_outcome_events` |
| 13 | Change any policy table value (rates, tiers, thresholds — see §2.8 for who owns which) | Owning department's lead | Admin who is not the proposer, after team review (§2.8) | Owning department | `task_category_rates`, `task_reputation_tiers`, `policy_values` (with `updated_by_email`); per-department policy revision history (§2.8, §5.6) |
| 14 | Compensation policy (credit → money) | Reward | Owner | Everyone | Policy document (repo), trial phase — see §2.8 |
| 15 | Execute a compensation run | Reward | Lead Reward + Owner | Persons paid | `compensation_runs`/`compensation_lines`, since migration 91 — Admin stands in for "Owner" (§5.5) |
| 16 | Budget top-up | Owner | Owner | Reward | `budget_ledger` |
| 17 | Publish a formation path | Formatore | Lead Formation | — | `formation_paths` |
| 18 | Import formation material into the archive | Formatore | Normal document workflow (Coordination) | — | `documents` |
| 19 | Release / announce a feature | Engineering | Owner | Everyone | Announcements + `TEAM_UPDATE` |
| 20 | Create / retire a department | Owner | Owner | Everyone | `option_lists` (`department`) |
| 21 | Publish / reject a User's board submission; remove a post that breaks the usage policy | Board editor of that board (or Coordinator) | — (editor decides, must give reason) | Author | `board_posts.status`, moderation note |
| 22 | Penalise board misuse (reputation penalty for an Operator, loss of posting rights for a User) | Board editor | Lead Formation or Lead HR (not the proposer) | Person, HR | people-decision log; `task_outcome_events` (`board_misuse`) |
| 23 | Add / remove a co-author on a formation path | Path owner | — | Co-author | `formation_path_editors` |
| 24 | Promote a board post into the archive | Board editor / Coordinator | Normal document workflow | Author | `documents` (new record in `revision`) |

Rules that apply to the whole table:
- Proposer and approver are never the same person.
- Every row marked "people-decision log" needs a written reason; a decision without one is
  invalid.
- Silence is not approval. A proposal with no decision after 7 days is escalated to the Owner.

---

## 5. What the software already does (as of 2026-09-18, migrations 1–93)

This section is here so the team designs on the real system, not an imagined one. Everything in
§6.1, 6.1b, 6.1c, 6.2, 6.3, 6.4 and 6.6 of v1.0 is now folded in here as shipped; §6 (below) keeps
only what's genuinely still open — which as of v1.2 is just Communication (no code needed) and two
low-priority known gaps.

### 5.1 Roles and qualifications
- `user_roles`: one row per account — `role` (user/operator/coordinator/admin), `credits`,
  `reputation`, `standing` (`active`/`watch`/`suspended`, migration 80), `email`, `created_at`.
  Only Admin changes `role` directly; `standing` changes only through `people_decisions` (§5.6).
  A trigger blocks a suspended person from claiming or being assigned a task.
- `user_qualifications` (many-to-many, codes from `option_lists` list `operator_qualification`).
  Assigned by Admin, or proposed by HR/Coordination and applied via `people_decisions`.
  `user_qualifies_for_category()` gates task claiming by category.
- `user_profiles`: full name, city, phone, membership, age bracket and gender (migration 85,
  new accounts only — existing accounts have both null, HR backfills separately), plus the
  Join-the-Team profile fields (academic level, availability, experience, skills, motivation).

### 5.2 Applications ("Join the Team")
- `collaboration_applications` with status `pending → recommended → approved | rejected`,
  `recommended_by` recorded on the recommend step.
- **HR members** (department `HR`) and Admin review applications and set **recommended** or
  **rejected**; a trigger refuses approval by the same person who recommended (migration 80/81).
  Coordinators no longer see this queue on their own — HR does (§2.1, §5.6). Only Admin sets
  **approved** (and simultaneously promotes the role).

### 5.3 Departments, people decisions and the HR view (migration 80, §2.8, §6.2 of v1.0)
- `option_lists` list `department` (`HR`, `COORD`, `FORM`, `RF`, `COMM`) and
  `department_members (department_code, user_id, is_lead, added_by_email)`, at most one lead per
  department. Helpers `is_dept_member(code)`, `is_dept_lead(code)`, `is_any_dept_lead()`.
  Appointing/replacing a lead (row 8) stays a direct Admin write to this table — not a
  `people_decisions` proposal — since proposer and approver are both the Owner by construction.
- `people_decisions`: append-only log (subject, type, payload, reason, proposer, status, decider,
  note). Clients cannot insert or update it directly — the only entry points are
  `propose_people_decision()` and `decide_people_decision()`, which enforce who may propose, who
  may approve, and that the two are never the same person (checked in SQL, not just the UI).
  Types: `qualification_add/remove`, `watch_on/off` (applied immediately, no approval — row 4),
  `suspend`, `reinstate`, `exclude` (role → `user`, standing → `suspended`, department/board/
  qualification rows dropped; account and every ledger kept — §8.7), `role_change`,
  `board_misuse` / `board_block` / `board_unblock` (§5.4).
- **People tab** (`hr_people_overview()`), visible to HR members, department leads and Admin:
  role, standing, credits, reputation, qualifications, departments, last event, negative events
  in the window, open tasks, pending decisions, and a **computed** `at_risk` badge (reputation <
  40, or ≥ 2 negative events in 60 days — all three numbers live in `policy_values`, §5.6). The
  stored thing is the HR decision (`watch`), never the heuristic itself.
- **My Department**: one screen per department (HR, Coordination, Formation, Reward), each
  showing that department's own working view (roster, applications/People for HR, task-flow
  overview for Coordination, course pipeline for Formation, credit circulation for Reward) plus
  the shared Policy section (§5.6). Team Applications no longer exists as a separate top-level
  tab — it lives inside My Department → HR.

### 5.4 Formation, boards and quiz import
- `FORM` department membership (not `board_editors`) gates who may create formation paths;
  `board_editors` keeps its own, distinct meaning — who curates/moderates a given board.
- **Structure (migration 92, restructured 2026-09-18):** `formation_paths` → `formation_modules`
  → `formation_chapters` → `formation_posts`, one level shallower than the original design — the
  "Years" level (`formation_years`) was dropped at the owner's request: a path is a sequence of
  numbered modules, not a multi-year programme, in the vast majority of real cases. Modules and
  chapters render as a numbered outline ("Module 1 — Title", "Chapter 1.2 — Title") instead of a
  nested tree, closer to a table of contents a formatore would write by hand than to a database
  schema. The "+ Path" popup used from a document's own page (Dashboard/My Space) can create a
  new module and chapter inline, without a separate trip to the Formation Paths screen — the
  course is built around the texts being filed into it, not the other way round.
- `formation_paths.thumbnail_path` (migration 93): an optional cover image per path, shown on its
  catalog card and detail page; a path with none gets a stable per-path colour placeholder with
  its initial letter instead, so the catalog still reads as a finished grid of cards.
- `formation_path_editors (path_id, user_id, added_by_email)`: a path has an owner plus any
  number of co-authors, added/removed by the owner (row 23). `can_edit_path()` = owner, co-author
  or Coordinator; publishing stays with the owner, the Formation lead, a Coordinator or Admin.
  A "Co-authors" section in the path editor searches by name/email among `FORM` members.
- **Quiz import from Markdown**: a real parser in `formation.js` (one `##` per question,
  `- [x]`/`- [ ]` options, optional `points:`), validated against the same constraints the DB
  enforces (≥ 2 options, exactly one correct); valid questions import even if some in the file
  fail. A standard AI prompt for drafting a module summary + quiz lives in Help and behind a
  "Copy prompt" button in the module editor.
- `board_posts` now carries `link_url`, `image_path` (Storage bucket `board-media`), and a real
  moderation lifecycle: `status` (`pending`/`published`/`rejected`), `moderated_by_email`,
  `moderated_at`, `moderation_note`. Any account can submit; a trigger auto-publishes for board
  editors, Coordinators and Operators (§2.6) and marks everyone else `pending`. Editors get a
  "Pending" queue in `boards.js` to publish/reject with a note, or remove a published post with a
  reason (row 21). The board usage policy is shown once before a person's first post
  (acknowledgement stored per user) and permanently in Help.
- `board_misuse`/`board_block`/`board_unblock` are `people_decisions` types (never a direct write
  by the editor) — a reputation penalty for an Operator, or loss of posting rights for a User
  (row 22). "Promote to archive" (editors/Coordinators) creates a document in `revision` with a
  back-reference to the originating post (row 24).

### 5.5 Credits, reputation, money
- `task_outcome_events` is the **append-only ledger**: every event (`review_ok`, `review_ok_but`,
  `review_fail`, `admin_rejected`, `given_up`, `withdrawn`, reclaim, `board_misuse`…) carries
  `credit_delta`, `reputation_delta`, `created_by_email`, `note`. A trigger applies the deltas to
  `user_roles`; those columns are never written by hand. Reputation is clamped 0–100, starts at
  50.
- `task_category_rates` and `task_reputation_tiers` can **no longer be written directly, even by
  Admin** (migration 86 dropped that RLS) — the only path to a new value is
  `propose_policy_change()` → `decide_policy_change()` (§5.6). `policy_values` is the same.
- Extra credits above the policy threshold (30% of base, or 10 absolute, whichever is lower —
  §8.3) cannot be paid out until the Coordination lead approves them: `tasks.extra_credits_status`
  is recomputed server-side on every write, and `submit_task_review()` refuses a passing verdict
  while it's `pending` (migration 90, closes row 10 — this was the one governance rule left
  unenforced when v1.0 was written). The task itself can still be created, claimed and worked
  while approval is pending; only the credit grant is gated.
- `budget_ledger`: append-only top-ups, Admin only. Available budget is computed live.
  `reward_credit_overview()` (migration 88) gives Reward members a read-only breakdown (posted /
  claimed / awaiting review / redeemed) without needing Admin's Budget tab; RF members can also
  read `task_outcome_events` directly (migration 91), not just this aggregate.
- **Compensation runs (migration 91, closes decision matrix row 15):** `compensation_runs` /
  `compensation_lines` record that credits were converted to money — append-only, no direct write
  policy for anyone, written only through `propose_compensation_run()` (RF members) and
  `decide_compensation_run()` (Admin, standing in for "Owner" since the schema has no separate
  Owner identity — proposer never equals approver, enforced in SQL). `unsettled_credits()` stops
  the same credits being counted into two runs. This is the "credits earned vs. credits paid"
  reconciliation v1.0 asked for; `docs/REWARD_POLICY.md` still governs the conversion rate itself
  (§2.8, §8 item 6), the schema only records that a conversion happened.
- **Anomaly report (migration 91, §2.4):** `reward_extra_credit_tasks()` lists every task that
  ever carried extra credits, whatever its approval status; `reward_operator_credit_anomalies()`
  flags an operator once their approved-but-unpublished credits exceed both their published
  credits and a policy floor (`reward_anomaly_backlog_credits`, default 100). Both are read-only
  views in My Department → Reward, not stored flags.
- Still true from v1.0: no separate history table for `task_category_rates`/
  `task_reputation_tiers` changes — superseded in spirit by `policy_proposals`' own history
  (§5.6), which was judged sufficient rather than building a second mechanism.

### 5.6 Policy revision framework (migration 86, was §6.6 in v1.0)
- `policy_proposals` (department, target table/key, old/new value, rationale, proposer, status,
  decider, decision note) is append-only and holds its own full history — nothing is ever
  deleted, and it doubles as the audit trail v1.0's §6.4 asked for as a separate mechanism.
- `propose_policy_change()`: any lead of the table's owning department (§2.8) may call it;
  changes nothing until decided. `decide_policy_change(id, outcome, note)` — one function
  covering both approve and reject, not the two separately-named functions v1.0 sketched — is
  Admin-only and explicitly refuses the proposer as decider, checked in SQL.
- `task_category_rates`, `task_reputation_tiers` and `policy_values` have **no direct
  insert/update/delete policy left for anyone, Admin included** — the only writer is
  `apply_policy_change()`, `security definer`, reachable only from `decide_policy_change()`. This
  is the one governance rule (§8 item 8) verified end-to-end at the database level, not just by
  team discipline.
- UI (My Department → Policy): read-only current values for everyone signed in, a "Propose
  change" action for department leads, a pending-proposals queue for Admin, and a per-department
  history view.

### 5.7 Who sees what today
- **People tab** (My Department → HR): HR members, department leads, Admin.
- **Personnel & Team Applications report** (Print Reports, migration-free, reuses `hr_people_
  overview()` and `collaboration_applications`): HR members and Admin only — deliberately
  narrower than the People tab's own gate, since `collaboration_applications`' RLS only lets HR
  and Admin read it, not every department lead. A printable roster of every operator/department
  member plus every admission request, for a meeting or a periodic review.
- **Policy** (current values + propose/approve): read by everyone; propose by department leads;
  decide by Admin (not the proposer).
- Team Applications: HR members + Admin (My Department → HR), no longer a separate tab.
- Proofreading queue, everyone's outcome history: Coordinator+.
- Budget (top-up), Options (option lists, departments): Admin only. Reward members get a
  read-only view of credit circulation, the outcome ledger, compensation runs and the anomaly
  report (§5.5) without Admin access.

The gap v1.0 flagged here — "an HR person who is not Admin cannot see the list of people they are
supposed to follow, and a Reward person cannot see the ledgers" — is now closed for both HR (§5.3)
and Reward (§5.5).

---

## 6. What's left to build

Subsections 6.1–6.4 and 6.6 of v1.0 shipped as designed (with the naming differences noted
inline in §5) and their content now lives in §5, where it describes the running system rather
than a plan. The subsection numbers below are kept only so existing cross-references (§2, §4, §7)
keep pointing at something; §6.1, 6.1b, 6.1c, 6.2, 6.3, 6.4 and 6.6 are retired as "to-build"
entries. As of v1.2, all of §6 that remains is Communication (§6.5, no code needed) and two
low-priority known gaps (§6.7, §6.8) — nothing is actively "to build".

### 6.1, 6.1b, 6.1c, 6.2, 6.3, 6.4, 6.6 — shipped, see §5
- Department model, `people_decisions`, `standing`, `policy_values` → **§5.1, §5.3** (migration 80)
- Formation path co-authors → **§5.4** (migration 82)
- Boards open to members with moderation → **§5.4** (migration 84)
- HR / People tab → **§5.3** (migration 80, UI in `people.js`)
- Quiz Markdown import + AI prompt → **§5.4** (migration 83, parser in `formation.js`)
- Policy revision framework → **§5.6** (migration 86)
- Extra-credit approval (row 10 — not originally its own §6 subsection in v1.0, just a policy
  value with nothing reading it) → **§5.5** (migration 90)
- Reward: credit circulation, `task_outcome_events` read access, compensation runs, anomaly
  report → **§5.5** (migrations 88, 91) — closed 2026-09-18, same session as the formation
  restructure below.

### 6.5 Communication (no phase)
- Nothing required. A "What's new" block on the Dashboard fed by Announcements is a nice-to-have.

### 6.7 Known gap: formation path publish doesn't fully match §4 row 17
Row 17 implies a Formatore proposes and the Formation lead approves publishing, as a distinct
proposer/approver pair. In practice `can_edit_path()`'s publish check (§5.4) allows the owner
(who is usually the same formatore who wrote it), the Formation lead, any Coordinator, or Admin —
so an owner who is also a formatore can publish their own path without a second person's sign-off.
Pre-dates migrations 80–93; not a regression, but not matched to the letter of the matrix either.
Low priority: formation paths go through the same document revision/approval workflow before
their content reaches the archive (row 18), so this doesn't bypass the archive's own review.

### 6.8 Known gap: two technical-role enforcement items from earlier handoffs
Carried over, not touched by migrations 80–93:
- "Only the Owner appoints department leads" (row 8) is a written rule, not an RLS-enforced one —
  any Admin can currently write `department_members`. Harmless today (Owner is the sole Admin);
  revisit if/when a second Admin is added.
- Internal team communications (a private lead-to-team channel, distinct from the public,
  moderated Boards) — explicitly deferred by the Owner, no design started.

---

## 7. Implementation phases and who works on them

| Phase | Content | Model / people | Exit criterion | Status |
|---|---|---|---|---|
| **0** | This document agreed; policy skeleton for Reward written by the Reward lead / Owner | Team | §8 questions answered | ✅ Done |
| **1** | Department model (migration 80), then a minimal Admin UI to assign members/leads and edit policy values | Migration: Claude **Opus** → UI: **Sonnet** | HR and Admin can be assigned to departments; suspending a user blocks task claiming | ✅ Done |
| **2a** | People tab (HR view) + proposal/approval flows | **Sonnet** | An HR member who is not Admin can do everything in §2.1 from the app | ✅ Done |
| **2b** | Quiz `.md` import + AI prompt; path co-authors (§5.4) | **Sonnet** | A formatore imports a 10-question quiz from a file; two formatori edit the same path | ✅ Done |
| **2c** | Boards open to members with moderation, usage policy, promote-to-archive (§5.4) | **Sonnet** | A User submits a post, a board editor publishes it; an Operator posts directly | ✅ Done |
| **3** | Policy revision framework (§5.6); Reward audit history, compensation runs, anomaly report (§5.5); extra-credit approval (§5.5, migration 90) | **Sonnet** | A compensation run can be recorded and reconciled | ✅ Done |
| later | Operator training programme; "What's new" | — | — | Not started |

The switch from Opus to Sonnet happens **after the migration 80 schema and the decision matrix
are frozen** — from that point the remaining work is views, forms and parsers, which Sonnet does
well and cheaper.

Developer workflow (branch + PR, one publisher at a time, handoff docs) is in `COLLABORATION.md`
and applies unchanged. Every session that touches this area ends with a new
`PROJECT_HANDOFF_vNN.md` (technical) and a new `TEAM_UPDATE_vNN.md` (for the team).

---

## 8. Decisions log

Answered by the Owner on 2026-09-16 unless noted. Item 6 was still open when v1.0 was written;
it was answered 2026-09-17 (see its own entry below) and nothing here remains open as of v1.1.

1. **May one person lead two departments?** Yes, **temporarily**, whichever departments they
   are: this is an experimental phase, the system has to be tested while suitable people are
   found. The separation-of-duties rule in §1.2 (proposer ≠ approver) still applies to every
   single decision even when one person holds two leads. To be revisited once the team has
   grown.
2. **Does `FORM` membership replace `board_editors` as the gate for creating formation paths?**
   Yes. Boards stay a distinct space with light moderation (§2.6); Operators publish directly,
   Users submit for approval; misuse is penalised (§4 rows 21–22).
3. **Extra-credit threshold needing the Coordination lead's approval (row 10):** extra > 30 %
   of base credits, or > 10 credits absolute — whichever is lower. **This is a policy value,
   editable in Options, not a constant in the code.**
4. **"At risk" heuristic for the People tab:** reputation < 40, or ≥ 2 negative events in the
   last 60 days. All three numbers editable in Options.
5. **First department leads:**

   | Department | Lead |
   |---|---|
   | HR | Mehwish |
   | Coordination | Sikander Innocent |
   | Formation | Gina Yaqoob (2026-09-16: replaces Aster Saleem) |
   | Reward | Naeem Sohail (2026-09-17: appointed, now registered) |
   | Communication | Larissa |

   Alessandro = Owner + Admin (technical). Sheril = engineering: not a department in this
   scheme but a standing role with its own workflow (`COLLABORATION.md`).
6. **Where do Reward records that are not in the app live** (compensation policy, payment
   references) — **repo, `docs/`** (answered 2026-09-17: `docs/REWARD_POLICY.md`, approved by
   Alessandro Maggi as Admin as a trial policy pending Naeem Sohail's review — see §2.8).
7. **Exclusion (row 6):** remove the role, **keep the account and the ledger** — history must
   survive the person leaving. Nothing is ever deleted from `task_outcome_events` or
   `people_decisions`.
8. **Policy tables must stay revisable for the whole life of the project, never frozen as
   "final"** (decided 2026-09-17, prompted by writing the first Reward policy in the trial
   phase): every change is a team decision an Admin applies, never a single Admin's unilateral
   edit. Process in §2.8; the in-app framework that enforces it technically is now built and live
   (§5.6, migration 86 — direct admin writes to the policy tables are gone at the RLS level, not
   just discouraged). `docs/REWARD_POLICY.md` remains the human-readable summary of Reward's own
   trial-phase values, kept in sync with the in-app history rather than being the primary record.
