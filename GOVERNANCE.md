# Governance — roles, departments and decision policies

**Status: v1.0 (2026-09-16) — decisions taken by the Owner; in force as the basis for phase 1. Team comments welcome, changes go through a new version.**

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

Needs from the software: a consolidated **HR view** (§6.2) — one screen with every team member,
their role, qualifications, credits, reputation, last activity, outcome history, watch status,
and pending applications.

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
- Design formation paths: years → modules → chapters, with linked documents, quizzes, final
  certificate. A path has one **owner** and any number of **co-authors** (other formatori
  invited by the owner) who edit it together; the owner — or the Formation lead — publishes it.
  Working together on a course is the preferred way, not the exception.
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

**Policy before software.** The biggest risk today is not technical: it is that these rules are
not written. Once they are, the software needed is small (§6.4).

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
substitute for this in-app workflow, not a replacement for it. Once §6.6 is built, in-app
proposals become the record of truth; the repo document becomes a human-readable summary kept in
sync with it, not the primary record.

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
| 3 | Assign / remove a qualification | HR (or Coordination) | Admin applies | Person concerned | `user_qualifications` + people-decision log (§6.1) |
| 4 | Put a person on the watch list | HR | — (HR decides, must give reason) | Lead HR | people-decision log |
| 5 | Suspend a person (no new tasks) | HR | Lead HR or Admin (not the proposer) | Coordination, person | people-decision log; `user_roles.standing` |
| 6 | Exclude a person (remove access) | HR | Owner | All leads | people-decision log; role removal |
| 7 | Promote to Coordinator / Admin | Owner or Lead HR | Owner | All leads | people-decision log |
| 8 | Appoint / replace a department lead | Owner | Owner | Everyone | `department_members` |
| 9 | Create a task, set its credits | Coordinator | — (within rate table) | — | `tasks` |
| 10 | Grant extra credits beyond the rate | Coordinator (with note) | Lead Coordination if above the threshold in Options (§8.3) | Reward | `tasks.extra_credits`, note |
| 11 | Reclaim a task (reputation penalty) | Coordinator | — (must give reason) | Person | `task_outcome_events` |
| 12 | Final publish / reject of a reviewed task | Revisor/Coordinator (verdict) | Admin | Person | `task_outcome_events` |
| 13 | Change any policy table value (rates, tiers, thresholds — see §2.8 for who owns which) | Owning department's lead | Admin who is not the proposer, after team review (§2.8) | Owning department | `task_category_rates`, `task_reputation_tiers`, `policy_values` (with `updated_by_email`); per-department policy revision history (§2.8, §6.6) |
| 14 | Compensation policy (credit → money) | Reward | Owner | Everyone | Policy document (repo), trial phase — see §2.8 |
| 15 | Execute a compensation run | Reward | Lead Reward + Owner | Persons paid | Reward records (outside app for now) |
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

## 5. What the software already does (as-is, September 2026)

This section is here so the team designs on the real system, not an imagined one.

### 5.1 Roles and qualifications
- `user_roles`: one row per account — `role` (user/operator/coordinator/admin), `credits`,
  `reputation`, `email`, `created_at`. Only Admin can change `role`.
- `user_qualifications` (many-to-many, codes from `option_lists` list `operator_qualification`).
  Only Admin assigns. `user_qualifies_for_category()` gates task claiming by category.
- `user_profiles`: full name, city, phone, membership, plus the Join-the-Team profile fields
  (academic level, availability, experience, skills, motivation).

### 5.2 Applications ("Join the Team")
- `collaboration_applications` with status `pending → recommended → approved | rejected`.
- Coordinator+ can see applications and set **recommended** or **rejected**; only Admin can set
  **approved** (and simultaneously promotes the role). **This is already the "propose → approve"
  shape HR needs** — the department work is to route it to HR members rather than to all
  coordinators, and to record who proposed.

### 5.3 Formatori and boards
- `board_editors`: who may post on which board. **Being a formatore is currently defined as
  "has at least one `board_editors` row"** (`is_any_formatore()`). Formation paths (`formation_paths`,
  years, modules, chapters, posts, enrolments, chat, quizzes, certificates) are created by
  formatori and editable **only by the owner or any Coordinator** — there is no co-author
  concept yet.
- `board_posts`: title + body and/or a linked document; **only board editors and Coordinators
  can post**, everyone with an account can read. No link/image fields, no moderation status:
  a post is published the moment it is inserted.
- Quiz questions are rows in `formation_quiz_questions` (`question_text`, `options` JSON array,
  `correct_index`, `points`, `sequence_number`) — a flat shape that maps cleanly to a Markdown
  import format (§6.3).

### 5.4 Credits, reputation, money
- `task_outcome_events` is the **append-only ledger**: every event (`review_ok`, `review_ok_but`,
  `review_fail`, `admin_rejected`, `given_up`, `withdrawn`, reclaim…) carries `credit_delta`,
  `reputation_delta`, `created_by_email`, `note`. A trigger applies the deltas to `user_roles`;
  those columns are never written by hand. Reputation is clamped 0–100, starts at 50.
- `task_category_rates` (credits per page by category) and `task_reputation_tiers` (deltas by
  task size) are Admin-editable tables with `updated_by_email` — but no history of previous
  values.
- `budget_ledger`: append-only top-ups, Admin only. Available budget is computed live.
- There is **no notion of "standing"** (active / watch / suspended) on a person, no "at risk"
  flag, and no log of decisions about people other than the application status.
- There is no record of compensation actually paid: credits accumulate, conversion to money
  happens outside the app.

### 5.5 Who sees what today
- Users tab (roles, qualifications, credits, reputation, city, membership, phone, since): Admin only.
- Team Applications, Proofreading queue, everyone's outcome history: Coordinator+.
- Budget, Options (rates, tiers, lists), Announcements: Admin only.

Consequence: today an HR person who is not Admin **cannot see the list of people they are
supposed to follow**, and a Reward person cannot see the ledgers. That is the first
gap to close.

---

## 6. What must be built (to-be)

Ordered by dependency. Each item names the phase in §7.

### 6.1 Department model (phase 1 — architecture) — **migration 80, written 2026-09-16**
- `option_lists` list `department` (codes `HR`, `COORD`, `FORM`, `RF`, `COMM`): departments
  are created/retired from the Options tab, not from code.
- `department_members (department_code, user_id, is_lead, added_by_email, created_at)`, at most
  one lead per department (partial unique index). Written by Admin only (executing row 8).
  Helpers `is_dept_member(code)`, `is_dept_lead(code)`, `is_any_dept_lead()`.
- `is_any_formatore()` is redefined as "member of `FORM`"; every existing board editor is
  backfilled into `FORM` so nobody loses path-creation rights on migration day.
- `user_roles.standing` (`active` / `watch` / `suspended`), changed only by the decision
  functions below. A trigger on `tasks` blocks a suspended person from claiming or being
  assigned a task, without touching the existing task policies.
- `policy_values (key, value, label, updated_by_email)`: the numbers of §8.3 and §8.4 plus the
  board-misuse penalty, Admin-editable from Options, read by everyone.
- `people_decisions`: append-only log with subject, type, payload, reason, proposer, status
  (`pending` / `approved` / `rejected` / `withdrawn`), decider, note. **Clients cannot
  insert or update it**: the only entry points are `propose_people_decision()` and
  `decide_people_decision()`, which enforce who may propose, who may approve, and that the
  two are different people. Types: `qualification_add/remove`, `watch_on/off` (applied at
  once, no approval — row 4), `suspend`, `reinstate`, `exclude` (role → user, standing →
  suspended, department/board/qualification rows dropped; account and ledgers kept — §8.7),
  `role_change`, `board_misuse` (writes a `task_outcome_events` row with a negative
  reputation delta, so the existing trigger applies it).
- Join the Team: `recommended_by` is recorded when an application is set to `recommended`;
  a trigger refuses approval by the same person. HR members get access alongside
  Coordinators; Coordinators are removed from these policies in phase 2a together with the
  client change (`canReviewApplications()`).
- `hr_people_overview()`: one function returning the whole People tab (role, standing, credits,
  reputation, qualifications, departments, last event, negative events in the window, open
  tasks, pending decisions, computed `at_risk`). Readable by HR members, leads and Admin.
- **Decided (2026-09-16):** `FORM` department membership replaces `is_any_formatore()` as the
  gate for creating formation paths; `board_editors` keeps its own meaning (who curates and
  moderates a given board).

### 6.1b Formation paths with co-authors (phase 2 — small)
- New table `formation_path_editors (path_id, user_id, added_by_email, created_at)`, primary
  key (path_id, user_id); the owner adds/removes rows (row 23 in §4).
- Helper `can_edit_path(pid)` = owner **or** co-author **or** Coordinator. All update/delete
  policies of the path subtree (paths, years, modules, chapters, formation posts, quizzes,
  questions — migrations 73–76) are redefined in one migration to use it instead of
  `owner_id = auth.uid()`. Publishing (`status → published`) stays with the owner or the
  Formation lead.
- UI: a "Co-authors" section in the path editor (search by name/email among `FORM` members).
  The existing path chat serves as the co-authors' workspace before publication.

### 6.1c Boards open to members, with light moderation (phase 2 — medium)
- `board_posts` gains `link_url text`, `image_path text` (Storage bucket `board-media`, size
  limit, upload allowed to any authenticated account, read to everyone), `status text default
  'published'` (`pending` / `published` / `rejected`), `moderated_by_email`, `moderated_at`,
  `moderation_note`.
- Insert policy opens to every account. A trigger sets `status = 'pending'` unless the author is
  an editor of that board, a Coordinator, or an Operator (who publish directly — §2.6).
  Select policy: `published` to everyone; `pending`/`rejected` to the author and the board's
  editors/Coordinators.
- Moderation UI in `boards.js`: a "Pending" counter and queue for editors of that board;
  publish / reject with note; remove a published post with reason (row 21). Board usage policy
  shown once before the first post (acknowledgement stored per user) and permanently in Help.
- `board_misuse` becomes an event type in `task_outcome_events` (`task_id` null, negative
  `reputation_delta` from a configurable value in Options); for Users a `standing = 'no_post'`
  value blocks further submissions. Both written only through the people-decision approval
  flow (row 22), never directly by the editor.
- Search: a search box inside Boards; in Dashboard search a separate "From the boards" section,
  never mixed with archive rows.
- "Promote to archive" button for editors/Coordinators: creates a document in `revision` with
  title/body pre-filled and a back-reference to the post (row 24).

### 6.2 HR view (phase 2 — mostly presentation)
- A new tab **People**, visible to HR members and Admin, that joins `user_roles`,
  `user_profiles`, `user_qualifications`, `department_members`, aggregate of
  `task_outcome_events` (last event, count of fails in the last N days, last activity), and
  `standing`. Sortable and filterable; "at risk" is a **computed** badge (e.g. reputation < 40,
  or ≥ 2 fail/reclaim events in 60 days — thresholds live in an option list so HR can tune
  them), not a stored flag. The stored thing is the HR decision (`watch`), not the heuristic.
- Application review moves from "Coordinator+" to "HR members + Admin"; the recommend step
  records the proposer so the approver check in row 1 can be enforced.
- Proposal/approval UI for rows 3–7 of §4, writing `people_decisions`.

### 6.3 Formation tools (phase 2 — small, independent)
- **Quiz import from Markdown**: define a format (one `##` per question, `- [x]`/`- [ ]` options,
  optional `points:`), a parser in `formation.js`, and an "Import quiz (.md)" button that inserts
  `formation_quiz_questions`. Validate against the same constraints the DB enforces (≥ 2 options,
  exactly one correct).
- **Standard AI prompt** for drafting a module summary and quiz in that format: a text block in
  the Help tab and a "Copy prompt" button in the module editor. No backend.
- Material import into the archive: **no new path** — document the rule (§2.3) in Help; if a
  shortcut is wanted later, it is "create a document in draft from the formation module", which
  still lands in the normal workflow.

### 6.4 Reward (phase 3 — after the policy is written)
- Read access to `budget_ledger`, `task_outcome_events`, rates and tiers for `RF` members.
- History tables (or an audit trigger) for `task_category_rates` and `task_reputation_tiers`, so
  a rate change is an event with before/after, not an overwrite.
- `compensation_runs (id, period_from, period_to, prepared_by, approved_by, approved_at, note)`
  and `compensation_lines (run_id, user_id, credits_settled, amount, currency, reference)`: the
  record that credits were converted to money, so "credits earned" and "credits paid" can be
  reconciled. Optional until the policy exists.
- Anomaly report (task with extra credits above threshold; operator with credits growing without
  published tasks): a query, exposed as a report.

### 6.5 Communication (no phase)
- Nothing required. A "What's new" block on the Dashboard fed by Announcements is a nice-to-have.

### 6.6 Policy revision framework (phase 3, cross-department — see §2.8)
Not started. Technical design pending; sketch below to guide it, not a spec to build from as-is.
- A `policy_proposals` table (or similarly named): department_code, target table, target
  key/row, proposed field changes (old/new), rationale, proposed_by, status
  (pending/approved/rejected/withdrawn), decided_by, decided_at, decision note. Append-only, like
  `task_outcome_events` and the people-decision log — nothing is ever deleted.
- `propose_policy_change(...)`: any lead of the owning department (§2.8) may call it; inserts a
  pending proposal, changes nothing yet.
- `approve_policy_change(id)` / `reject_policy_change(id, note)`: Admin only, and not the same
  user who proposed. Approving writes the new value into the real table
  (`task_category_rates` / `task_reputation_tiers` / `policy_values`) inside the same
  transaction, with `updated_by_email` pointing at the approving Admin and a reference back to
  the proposal.
- RLS: remove the current direct `admin_update` policy on `task_category_rates`,
  `task_reputation_tiers` and `policy_values` (today any Admin can write them unilaterally —
  exactly what §2.8 says must stop). All writes to these tables go through
  `approve_policy_change()`, `security definer`, which is the only path that can move a value
  from proposed to live.
- UI: a read-only "Current policy" view for everyone (replaces direct editing in the existing
  Departments/Policy values admin panels); a "Propose change" action for department leads; a
  "Pending proposals" queue for Admin (approve/reject with note); a per-department "Policy
  history" view (mirrors the People tab's per-person decision history, §6.2).
- Until this is built, policy changes are made the trial-phase way: an Admin edits the table
  directly, but only after a decision recorded in a document like `docs/REWARD_POLICY.md` — the
  same discipline the schema will later enforce, applied by hand.

---

## 7. Implementation phases and who works on them

| Phase | Content | Model / people | Exit criterion |
|---|---|---|---|
| **0** | This document agreed; policy skeleton for Reward written by the Reward lead / Owner | Team | §8 questions answered |
| **1** | Department model: migration 80 (written; to be run and verified), then a minimal Admin UI to assign members/leads and edit policy values | Migration: Claude **Opus** (done) → UI: **Sonnet**; Sheril reviews the PR | HR and Admin can be assigned to departments; suspending a user blocks task claiming |
| **2a** | People tab (HR view) + proposal/approval flows | **Sonnet** + Sheril (front end) | An HR member who is not Admin can do everything in §2.1 from the app |
| **2b** | Quiz `.md` import + AI prompt; path co-authors (§6.1b) | **Sonnet** / Sheril | A formatore imports a 10-question quiz from a file; two formatori edit the same path |
| **2c** | Boards open to members with moderation, usage policy, promote-to-archive (§6.1c) | **Sonnet** / Sheril | A User submits a post, a board editor publishes it; an Operator posts directly |
| **3** | Reward: audit history, compensation runs, anomaly report | Sonnet, after the policy | A compensation run can be recorded and reconciled |
| later | Operator training programme; "What's new" | — | — |

The switch from Opus to Sonnet happens **after the migration 80 schema and the decision matrix
are frozen** — from that point the remaining work is views, forms and parsers, which Sonnet does
well and cheaper.

Developer workflow (branch + PR, one publisher at a time, handoff docs) is in `COLLABORATION.md`
and applies unchanged. Every session that touches this area ends with a new
`PROJECT_HANDOFF_vNN.md` (technical) and a new `TEAM_UPDATE_vNN.md` (for the team).

---

## 8. Decisions log

Answered by the Owner on 2026-09-16 unless noted. One item still open (8.6).

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
   edit. Process in §2.8; the in-app framework to enforce it technically is planned (§6.6,
   phase 3) but not yet built — until then the discipline is applied by hand, through a policy
   document like `docs/REWARD_POLICY.md`.
