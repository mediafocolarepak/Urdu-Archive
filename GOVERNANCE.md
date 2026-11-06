# Governance — roles, departments and decision policies

**Status: v1.19 (2026-11-06) — decisions taken by the Owner; all of phases 1 through 3 are built and
merged (migrations 80–115). Team comments welcome, changes go through a new version.**

**What changed in v1.19:** date of birth instead of age bracket (§5.19, migration 120, Owner's decision): the date is readable only by
the person, the HR lead and Admins; the age group is computed from it, for those who need it.

**What changed in v1.18:** the guides in Urdu, as drafts (§5.18, Owner's request): the team sees them, plain Users don't until they are reviewed.

**What changed in v1.17:** Start Here is now a first screen of large buttons, so that nobody has to scroll past
everything (§5.8, Owner's request): the Word of Life, the three sections of cards and the guides, each opening its own page.

**What changed in v1.16:** Help redesigned with the Owner (§5.18, migration 116): guides by activity, and each
person sees only those for what they can do. New guides present each role and department page. Users still have
Start Here instead of a Help tab, with a button to the guides meant for them.

**What changed in v1.15:** the Word of Life of a month is one package, and a magazine issue is a record of
its own (§5.17, migration 115). A board post reaches the archive only through the proposal form, and anyone
can suggest one (§2.6).

**What changed in v1.14:** anyone signed in can read a text aloud (§5.16, migration 114). They consent,
hold the text for 7 days and record it or upload a file. Someone listens, and an approved reading gets a
Listen button and the reader's name. Whoever withdraws consent has their readings removed at once.

**What changed in v1.13:** video links and audio readings (§5.15, migration 113). A proposal can now
hold a video or a recording alongside the text, a document shows Listen and Watch video buttons, and Start
Here has a one-tap Word of Life of the month.

**What changed in v1.12:** the one door for new content (§5.14, migration 112). Anyone on the team
fills in a proposal; a Revisor or Coordinator approves, and that alone publishes it. Whoever proposed
it always sees where it stands and can send a reminder, and reviewers always see the queue.

**What changed in v1.11:** access levels (§5.13, migration 111). Every document version is public,
private or reserved. A reserved document exists only for Admin, Formation members and people they
enable. **The limit is written down on purpose:** PDFs stay on Drive with a public link, so a level
decides what the app shows and does not make a file on Drive secret.

**What changed in v1.10:** the first part of the archive intake protocol
(`Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md`), migrations 109–110:
- **Only Admin can make a document visible**, and this is enforced in the database (§5.12). + New
  document, Bulk Import and Hayat Extract are Admin-only; everyone else can add only hidden drafts.
- **During development Admin may do everything, reviewing and approving their own work included**
  (§1 principle 3, §4), with every action recorded. Compensation runs keep the second person.
- **A log nobody can edit records every change to the archive** (§5.12), and **deleting is now
  reversible**: nobody can erase a document through the app.
- **The task review chain was repaired** (§5.12): credits had been paid at review and again at
  publish, and Admin's Reject always failed.

**What changed in v1.9:** a catch-up and one principle, no new migration. v1.8 stopped at migration
98; the software then moved through migrations 99–106 and several user-facing changes that this
document never recorded, so §5 no longer described the running system. Now written down:
- **A sixth department, Archive & Data** (§2.9), created by the Owner from Options (data only). It
  owns the cataloguing tools and, since migration 106, the Translate prompt.
- **Department Pulse phase 2 and the Project overview Users panel** (§5.9, migrations 99–100);
  **Operators can use Share with us** (§5.8, migration 97); Users now land on **Start Here** after
  login and see the Dashboard as **Library** (§5.8).
- **How the archive models languages and dates** (new §5.10, migrations 101–104): every document in
  every language is its own record, grouped by `work_id`; the 273 Italian Collegamenti were imported
  that way; and a one-position shift in `ref_date` across about 244 Collegamenti was found and
  corrected.
- **Translation tooling** (new §5.11, migrations 105–106): the Translate helper, the translation
  prompt kept in the database as numbered versions, and the log of corpus-mining cycles.
- **§1 principle 7**: a tool may report how the community writes a term; only the Owner decides it.
  Three terminology decisions had already followed that rule without it being written here.
- A new row in the decision matrix (§4 row 25) and decision-log items 12–14 (§8).

**What changed in v1.8:** same phase, next session, one new migration, no new principle - this is
a mechanism, not a policy shift. **Department Pulse** (§5.9, migration 98): each department's lead
sets a simple status (on track / slowing down / stalled) and a short list of current priorities,
visible to every member of that department; Admin gets a one-screen roll-up across every
department ("Project overview", a new tab). Deliberately manual, not computed from task data - the
Owner's own reasoning (§8 item 11): a wrong automatic signal is worse than an honestly subjective
one, and the human note is the actual point, not the color. Also this session: the standalone
People tab and Proofreading queue were retired (folded into My Department -> HR, and no longer
needed now that every PDF has been replaced) - UI cleanup, not a governance change, not detailed
further here.

**What changed in v1.7:** same day as v1.6, later pass, no new migration. §1 gains a sixth
principle — the reasoning behind "Start Here"/"Share with us" (v1.6) had only been written down as
software (§5.8) and as a decision-log entry (§8 item 10), not as a standing principle for how the
organisation treats the people it serves. Written down now because it should outlive this one
feature: design for whoever finds it hardest, ship a staged-but-honest version rather than wait
for a complete one, and keep a technical report and a shared feeling going to structurally
different places. §5.8 now opens with a one-line pointer back to it.

**What changed in v1.6:** next session, two new migrations. A new first-run experience for Users,
scoped in a long conversation with the Owner (sociological/psychological/marketing framing) about
a real gap: a new User with little English and basic Urdu literacy had no orientation — the old
Help tab was a technical English walkthrough built for operators.
- **"Start Here"** replaces Help for Users only (§5.8, migration 95): three sections (what this
  is / how to use it / how to collaborate), filled with bilingual (Urdu + English gloss) cards —
  text, image or linked-video — **authored by Communication**, the department's first real
  software responsibility (§2.5 updated accordingly).
- **Formation Paths** get the same bilingual title/description treatment on their catalog cards.
- **"Share with us"** (§5.8, migrations 95–96): a new, deliberately separate channel from the
  existing technical "Report a Problem or Suggestion" chat — for sharing an experience, feeling or
  idea, not a bug. Read by **every department lead and Admin**, each of whom can thank a share
  and/or reply independently. Phase 1a shipped text-only; phase 1b (this session) added voice
  messages, for someone who finds typing a second script on a phone hard.
- Deliberately **not** done in this pass: translating the app's existing UI chrome into Urdu — a
  separate, larger project, waiting on Asci/Sheril's availability, using the current CSS/layout
  (no RTL mirroring) once it starts.

**What changed in v1.5:** same day as v1.1–v1.4, later session, one new migration. Two additions,
requested together when the Owner asked for a plain-language map of how the whole system fits
together (see the two-poles framing opening §2 below, and PROJECT_HANDOFF_v34.md):
- **Internal team communications**, deferred since v26/§6.8 of earlier versions, is built: a
  private "Team channel" per department (§5.3, migration 94), closing that long-open gap.
- §2 now opens with the **two-poles framing** — Material (Formation, Coordination) vs. People
  (HR, Reward), with Communication working across both — the same structure already implicit in
  the department list, now written down explicitly because it turned out to be the clearest way
  to explain the whole system to someone seeing it for the first time.

**What changed in v1.4:** same day as v1.1–v1.3, later session, no new migration. The formation
path editor gained a "Generate image prompt" button (§5.4): composes a ready-to-paste AI-image
prompt from the path's own title/description/target audience, for the formatore to run through
whatever image tool they use and then upload via the existing thumbnail field (v1.2/migration 93).
Deliberately not automatic image generation - no paid API, no secret key to keep, same reasoning
already applied to the quiz-drafting AI prompt.

**What changed in v1.3:** same day as v1.1/v1.2, later session, no new migration. The Personnel
report (added in v1.2) now separates the actual team (operators and up) from plain Users, who can
be very numerous and aren't who a HR/Admin printout is meant to be about, and adds two grouped
views — by department and by qualification (§5.7). Separately, every native `prompt()`/`confirm()`
dialog in Formation Paths was replaced with a styled in-app popup (`confirmPopup()` in `core.js`,
reusable elsewhere) — closer to the rest of the app's look, and it also removes the one thing that
was blocking automated browser testing of that area (§5.4).

**What changed in v1.2:** Reward's last open piece (compensation runs, the anomaly report) shipped
(migration 91), closing phase 3 entirely — §6.4 moves from "to build" to §5 alongside everything
else. Formation paths were also restructured at the owner's request: the "Years" level between a
path and its modules is gone (migration 92 — Path → Module → Chapter → Post, one level shallower),
modules/chapters are now shown as a numbered outline instead of a nested tree, and a thumbnail
image can be set per path for the catalog (migration 93). A new printable Personnel & Team
Applications report (Print Reports, Admin/HR) was added, reusing existing data sources — no new
migration. No organisational decision changes in v1.2 or v1.3 either; both are "catch the docs up
to the code" passes.

This document describes how the people who run the **Digital Urdu Archive (DUA)** are
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
   departments; Admin executes them and keeps the system running. **During development and testing
   the Admin may do everything, with no approval from anyone, including reviewing their own tasks and
   approving their own proposals (Owner's decision, 2026-11-05):** the Owner is at once developer,
   Admin and head of the focolare, there is no other way to test each role alone, and the Admins
   already work in unity outside the platform. Every such action is recorded (§5.12). Compensation
   runs (row 15) keep a second person, because they concern money. To be reviewed when Revisors start
   working in the app.
4. **Every decision that affects a person, a task's value or a payment is recorded** with who
   proposed it, who approved it, when, and why. This is already how credits and reputation work
   (`task_outcome_events`): the same append-only pattern is extended to people decisions.
5. **One lead per department.** The lead is accountable for the department's decisions and is
   the approver of last resort inside it. Leads are appointed by the project owner.
6. **A User's first encounter, and a User's voice, deserve the same deliberate design as any
   internal process does.** Design for the person who will find it hardest — someone with little
   English and basic Urdu literacy, on a phone, who has never used the platform — not for the
   average case; what serves them serves everyone. A full solution (translating everything,
   building everything) is not required before a smaller, honest one (bilingual content, a warmer
   first tab) ships — staged is not lesser, as long as what's deferred is written down, not
   forgotten (§5.8). And what a User shares is heard by leadership directly, not filtered through
   a support queue: a technical report and a shared feeling are structurally different things and
   go to different places, because treating them the same would flatten both.
7. **A tool may report how the community writes a term; only the Owner decides it.** The real
   Italian↔Urdu document pairs are mined to see which forms the community actually uses (§5.11),
   and the result is shown as *attested* usage, never applied. Where usage diverges from the
   glossary the Owner decides, and only then does the style guide — and the Translate prompt that
   distils it — change. The same rule holds inside the prompt: the model is asked to flag a term it
   is unsure of rather than invent one, and every version of the prompt is kept, so nothing is
   rewritten silently.

---

## 2. Departments

Five core departments, but two objects (a sixth, Archive & Data, §2.9, looks after the archive's own
records). Two departments own **the material** — the Urdu texts that
enter the archive and leave it again as published documents and formation paths: **Formation**
(§2.3, builds the paths, brings material into the pipeline) and **Coordination** (§2.2, runs the
translation → typing → proofreading → revision → publication pipeline that the Operators execute).
Two more own **the people** who do that work, not the material itself: **HR** (§2.1, admits and
monitors Operators) and **Reward** (§2.4, distributes credits — and, later, compensation — for the
work done). **Communication** (§2.5) belongs to neither object: it promotes what Formation and
Coordination produce, and it recruits toward HR, working in close contact with both sides without
owning either.

This split is why the separation-of-duties rule in §1.2 draws its lines where it does: the
department that decides *what work gets done* (Coordination) is never the same one that decides
*who is fit to do it* (HR) or *what that work is worth* (Reward).

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

*Mission:* people know the platform exists, know what is new, and know how to use it — and, for a
first-time User, feel welcomed into it before anything else.

Responsibilities:
- **Author and keep fresh the "Start Here" cards** (§5.8) a new User sees in place of a technical
  Help tab: bilingual (Urdu + English gloss), warm rather than instructional, in whatever mix of
  text, image and short linked video best explains what the archive is, how to use it, and how to
  get more involved. This is the friendly face of the platform for someone who has never used it —
  not a manual, a welcome.
- **Keep "Share with us" alive** (§5.8): read what Users and the team share — an experience, a
  difficulty, an idea — thank it, and write back. This is reciprocal, not a support queue: every
  department lead and Admin sees the same shares Communication does, but Communication is the
  department whose whole mission is to make sure nobody who shares something goes unheard.
- Video tutorials and short guides; keep the in-app Help aligned with them (Operators and up).
- Announce releases and new features (in-app Announcements tab + social channels).
- Promote recruitment campaigns on HR's behalf — including toward Users who see what's shared and
  might join the team themselves.

Needs from the software: writable access to the "Start Here" cards and read/reply access to
"Share with us" (both §5.8, migration 95) — Communication's first real software responsibility,
where before this department needed almost none.

### 2.6 Boards — a shared space, distinct from the archive

Boards are where formatori and members meet: ideas, proposals, texts for meditation, links to
a video, an image. They are **not part of the archive** and never become archive records: the
archive is the official corpus with its catalogue fields, revision workflow and credits; a
board post has none of those and must not pollute searches, reports, tasks or statistics.
If a post deserves the archive, whoever looks after the board or a Coordinator **proposes** it: the proposal
form (§5.14) opens already filled in, and it goes through the usual review. This works for posts with only an
image or a link too. Anyone else can **suggest** a post; the suggestion reaches that board's editors, Archive &
Data and Coordinators, who propose it or decline it (migration 115).

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

### 2.9 Archive & Data

*Mission:* keep the archive's own records correct — the catalogue, the texts as stored, the way
documents of different languages are linked — and own the tools that do it.

Created by the Owner from Options (a department is data, no migration), with the Owner as its lead
(§1.5) and a small group of members, so that the department's own Team channel (§5.3) gives
cataloguing work a place to coordinate. Responsibilities:
- Run the **cataloguing tools**: Hayat Index, Match Review, Work Consolidation and Hayat Editor. They
  used to be separate Operator tabs gated by a "Data Assistant" qualification; they are now launched
  from My Department → Archive & Data. **Bulk Import and Hayat Extract are Admin-only since
  2026-11-05** (§5.12): they add visible documents, so they are not routine cataloguing work.
- Keep **dates, links and texts** right: a document's `ref_date` is the date of the Collegamento and
  must equal the date in its title; every language version is its own record, linked by `work_id`
  (§5.10).
- Keep the **translation prompt** (§5.11): Admin saves each new version from the editor on this
  department's page, after the Owner has decided a terminology question (§1.7).

It does not decide what work gets done (Coordination), who does it (HR) or what it is worth
(Reward): it corrects the records the others produce. Its work already shows up in Coordination's
task data, which is why Department Pulse (§5.9) gives it no computed signal.

---

## 3. Technical roles (unchanged)

The application's four-tier role hierarchy stays as it is. Departments sit *on top of* it, they
do not replace it.

| Role | What it grants (DB level) |
|---|---|
| **User** | Read the archive; report problems; apply to join the team. |
| **Operator** | Everything above + edit existing documents, add new ones only as hidden drafts (§5.12), claim and submit tasks. Qualifications (Translator, Revisor, Proof Reader, Content Creator…) gate which task categories they can take. |
| **Coordinator** | Everything above + create/assign/review tasks, see applications and everyone's qualifications and outcome history, recommend applicants. |
| **Admin** | Everything above + change roles and qualifications, publish/reject reviewed tasks, edit option lists, rates, tiers, budget ledger, announcements; add visible documents, publish or withdraw any document, delete and restore (§5.12). |

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
| 18 | Import formation material into the archive | Formatore | The proposal review (§5.14) | — | `archive_submissions` |
| 19 | Release / announce a feature | Engineering | Owner | Everyone | Announcements + `TEAM_UPDATE` |
| 20 | Create / retire a department | Owner | Owner | Everyone | `option_lists` (`department`) |
| 21 | Publish / reject a User's board submission; remove a post that breaks the usage policy | Board editor of that board (or Coordinator) | — (editor decides, must give reason) | Author | `board_posts.status`, moderation note |
| 22 | Penalise board misuse (reputation penalty for an Operator, loss of posting rights for a User) | Board editor | Lead Formation or Lead HR (not the proposer) | Person, HR | people-decision log; `task_outcome_events` (`board_misuse`) |
| 23 | Add / remove a co-author on a formation path | Path owner | — | Co-author | `formation_path_editors` |
| 24 | Promote a board post into the archive | Board editor / Coordinator | Normal document workflow | Author | `documents` (new record in `revision`) |
| 26 | Publish new content | Any team member (the proposal form) | A Revisor or Coordinator, not the proposer; for reserved content, another Formation member or Admin. Admin may also publish directly | Proposer | `archive_submissions`, `submission_events`, `archive_log` |
| 25 | Change a canonical translation term, or save a new version of the Translate prompt | Anyone (a translator's flagged uncertain term, or a mining cycle) | Owner (Admin saves the version) | Translators | The style guide's version, a new row in `translation_prompts`, and a row in `skill_corpus_analysis_log` when it follows a mining cycle (§5.11) |

Rules that apply to the whole table:
- Proposer and approver are never the same person, except an Admin during development (§1 principle 3).
- Every row marked "people-decision log" needs a written reason; a decision without one is
  invalid.
- Silence is not approval. A proposal with no decision after 7 days is escalated to the Owner.

---

## 5. What the software already does (as of 2026-10-21, migrations 1–106)

This section is here so the team designs on the real system, not an imagined one. Everything in
§6.1, 6.1b, 6.1c, 6.2, 6.3, 6.4 and 6.6 of v1.0 is now folded in here as shipped, and as of v1.6
so is Communication's own software (§5.8/§6.5); §6 (below) keeps only what's genuinely still
open — two low-priority known gaps.

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
  overview for Coordination, course pipeline for Formation, credit circulation for Reward), a
  shared **Team channel** (below) and the shared Policy section (§5.6). Team Applications no
  longer exists as a separate top-level tab — it lives inside My Department → HR.
- **Team channel** (migration 94, `department_messages`): the internal team communications
  deferred since v26/§6.8 of earlier versions — a private message thread per department, visible
  only to that department's members and Admin, distinct from Boards (§2.6, public and moderated)
  and from the admin↔user chat (`chat_messages`, 1:1 ticketing). Any department member can post
  and reply; the department lead (or Admin) can pin a message; the author can edit or delete their
  own message within 15 minutes of posting, enforced server-side by a field-separation trigger so
  an edit can't sneak in a pin and vice versa. Images attach through a **private** storage bucket
  (`department-media`) — unlike `board-media`, not public, since the whole point of this channel
  is that it stays internal to the department.

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
  its initial letter instead, so the catalog still reads as a finished grid of cards. The path
  editor's "Generate image prompt" button (v1.4) composes a prompt from the path's own title/
  description/target audience for an external AI image tool - no image generation happens inside
  the app itself, the formatore pastes the prompt elsewhere and uploads the result through the
  same thumbnail field.
- **No more native `prompt()`/`confirm()` dialogs (v1.3):** every create/rename/delete action in
  Formation Paths uses a styled in-app popup instead (`confirmPopup()`, new in `core.js` and
  reusable by other modules; `openChapterPopup()`/`openModulePopup()` for the two text inputs).
  Closer to the rest of the app's look for the "not a computer expert" audience this redesign
  targets, and it also closed the one long-standing gap in browser-testing this area (native
  dialogs silently block automation - PROJECT_HANDOFF_v18.md §3 first raised this).
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
  and Admin read it, not every department lead. Three views of the same data (v1.3): a **Team
  Roster** (operator and up only) kept separate from a compact **Users** table (plain Users, the
  general readership, can run to hundreds/thousands of rows and have no team-specific columns to
  show); **by department** and **by qualification**, each exploding `hr_people_overview()`'s
  comma-joined summary columns back into one row per membership and grouping with the resolved
  option-list label, not the raw code. Team Applications is included in every view. All printable
  for a meeting or a periodic review.
- **Policy** (current values + propose/approve): read by everyone; propose by department leads;
  decide by Admin (not the proposer).
- Team Applications: HR members + Admin (My Department → HR), no longer a separate tab.
- Budget (top-up), Options (option lists, departments): Admin only. Reward members get a
  read-only view of credit circulation, the outcome ledger, compensation runs and the anomaly
  report (§5.5) without Admin access.
- Department status and priorities (§5.9): read by that department's members + Admin; set only by
  that department's lead + Admin. Admin's "Project overview" roll-up: Admin only.
- **Project overview's Users panel** (§5.9): Admin only. Enrollment totals come from a
  security-definer function, `admin_project_stats()` (migration 100), because
  `formation_enrollments` only lets a person read their own row.
- **Translation prompt and mining log** (§5.11): the prompt is read by Operator and up (the audience
  of the Translate button) and changed by Admin only; `skill_corpus_analysis_log` is read and written
  by Admin only.

The gap v1.0 flagged here — "an HR person who is not Admin cannot see the list of people they are
supposed to follow, and a Reward person cannot see the ledgers" — is now closed for both HR (§5.3)
and Reward (§5.5).

### 5.8 Onboarding hub and Share with us (migrations 95–96)

The software below exists to carry out §1.6 — read that first for the reasoning; what follows is
only the mechanism.

**"Start Here"** replaces the technical Help tab for Users only — Operators/Coordinators/Admin
keep Help (redesigned in §5.18). Content lives in `onboarding_cards` (bilingual: `title_ur`/`body_ur`
required, `title_en`/`body_en` optional gloss), grouped into three sections — `about`,
`how_to_use`, `how_to_collaborate` — writable by Communication (`is_dept_member('COMM')`) or
Admin, readable by every signed-in user. A card can carry an image (`onboarding-media`, a public
bucket like `board-media` — this is outreach content, nothing sensitive) or link to a video
already published elsewhere (YouTube/Facebook/Instagram — no video hosting was built). One
"how to collaborate" card is the tutorial for Share with us, linking into that tab via
`media_url = 'tab:sharewithus'` rather than an external URL.

Formation Paths (§5.4) got the same bilingual treatment: `title_en`/`description_en`, nullable,
shown alongside the (already-Urdu) title/description on the catalog card and path detail page.

**The first screen (2026-11-06, Owner's request):** no longer the sections one after another. It is a set of large buttons,
Urdu above English, each opening its own page: the Word of Life, the three sections (a section with no published card has no
button) and the guides. The Word of Life is reached by its button, then Read or Listen: two taps rather than the one of protocol §9,
by this choice. Read aloud has no button here, since it isn't announced yet.

**"Share with us"** is not the technical "Report a Problem or Suggestion" chat (`chat_messages`,
unchanged) — it's for an experience, a feeling, an idea, framed by the Owner as reciprocal
("amore che va e che torna"), not a ticket queue. `share_with_us_messages`: Users may post and, since
migration 97, Operators too (the original policy only ever allowed Users, despite its own comment;
a Coordinator keeps read access through the lead/Admin path, not as a sharer);
`share_with_us_reactions` (a "thank you", one per lead per message, toggleable) and
`share_with_us_replies` (several leads can each reply independently, unlike `chat_messages`'
single `reply_text` column) are both readable by the original sharer and by **every** department
lead and Admin — not gated to one department, unlike the Team channel (§5.3). Phase 1b (migration
96) added voice messages: `audio_path`/`audio_mime_type` on the message row, a **private** storage
bucket `share-with-us-audio` keyed `<user_id>/<filename>` (only the author uploads into their own
folder; the author or any lead/Admin can read it back via a signed URL) — recorded client-side
with plain `MediaRecorder`/`getUserMedia`, no library, and simply not offered on a browser that
doesn't support it.

**What Users see first** (no migration): after login a User lands on **Start Here**, not the
Dashboard, and for plain Users the Dashboard tab is called **Library**. The app's title is now
"Focolare Urdu Archive" (the word "Manager" dropped from the page title, login screen, top bar and
PWA name — shorter and warmer for a User-facing name). Start Here's section headings are bilingual
(Urdu above English) and a card's text keeps its line breaks, so numbered steps read one per line.

### 5.9 Department Pulse (migration 98)

A lead-managed status and a short priorities list per department, so members stay aligned and
motivated without a meeting - the Owner's framing: a human touch on online work, not a metric
(§8 item 11 has the full reasoning).

- `department_status`: one row per department (`department_code` primary key) - `status`
  (`on_track` / `slowing` / `stalled`), a free-text `note`, `updated_by_email`/`updated_at`.
  Read by department members and Admin; written only by that department's lead or Admin (`for
  all`, same RLS shape as `task_reputation_tiers`' owner check, not the propose/decide framework
  of §5.6 - this is an operational status, not a policy value, so there is no separate approval
  step).
- `department_priorities`: an ordered, short list of what the department is focused on right now -
  `title`, an optional `due_date`, `done`/`done_at`, `sort_order`. Same read/write split as above.
  Deliberately not a second task system: no assignee, no credits, no category - just what the lead
  wants the team looking at.
- **UI**: a colored banner (green/amber/red) at the top of each department's My Department page,
  with the lead's note and an "Update status" action for the lead/Admin; the priorities list
  underneath, checkable off by the lead/Admin. A new tab, **"Project overview"**, Admin only,
  right after My Department: one card per department showing its current status/note/open-
  priority count, reading the same two tables with no per-department filter (Admin already sees
  every row via the RLS above) - clicking a card opens that department's My Department page.
- Explicitly **not** built in this phase: any computed suggestion for the status color. The Owner
  and Claude agreed a wrong automatic signal (a stale "green" from an idle status, or a "red" from
  a metric that doesn't fit a given department) would do more harm than an honestly subjective
  human note - see §8 item 11. A computed hint, and possibly surfacing it to Coordinator too, may
  follow once this phase shows real use.

**Phase 2 (migration 99)**: a **computed hint** now appears next to the lead's own pick — never
applied by itself, never written to `department_status`. Coordination: overdue claimed tasks;
Reward: flagged credit anomalies (the existing anomaly report); HR: age of the oldest pending people
decision; Formation: days since the last formatori-chat message or path update; Communication: days
since the last Start Here card update; Archive & Data: none. The Owner chose to build these before
phase 1 had real usage, so the thresholds are first guesses to revisit after a few weeks of real
lead use. Admin also has a confirm-gated "Reset all statuses" on Project overview.

**Users panel (migration 100)**: Project overview also shows headcount, age and gender breakdowns of
the userbase and Formation Paths enrollment (§5.7). Login/access history is deliberately **not**
built: it is privacy-sensitive and is its own decision, not a side effect of a statistics screen.

### 5.10 Languages, dates and the archive's data model (migrations 101–104)

- **Every document, in every language, has its own record** in `documents`; records of the same work
  are grouped by `work_id`, and a document's detail panel lists its siblings (§8 item 12). The 273
  Italian Collegamenti (document_id 1558–1830, `language = 'ITA'`) were imported on that model:
  their text is the body of the Italian record itself, in `document_texts` with
  `source = 'drive_import'` and `reviewed = false` (extracted automatically from PDFs, not yet read
  against the original page).
- `document_original_texts` (migration 101) was first built as a sidecar holding the Italian text of
  a *different* record; migration 103 corrected the model and emptied it. It now means only "an
  original text with no catalogued record of its own", and the "Original text (Italian)" button
  reads it, so the button is dormant. Whether to keep it for genuine sidecars or remove it is open.
- To pair an Italian text with its Urdu translation, **join through `work_id`**, never by
  `document_id`.
- **Dates (migration 104).** `ref_date` is the date of the Collegamento and must equal the date in
  the document's own title. About 244 Collegamenti were found carrying the date of the *following*
  one — a one-position shift along the series — and two had swapped values. The title and the Drive
  file name, two sources that had never seen each other, agreed on 269 of 269 comparable documents,
  which is why the title is authoritative. The correction derives the date from the title when it
  runs, keeps a backup table (`_backup_documents_refdate_20261018`, to be dropped after a few
  weeks), and most likely does what migration 27 was meant to do but never fully did on this
  database. It was the second migration found to have not fully run, both by accident (the first was
  migration 54); a systematic audit of what actually ran has still not been done.

### 5.11 Translation tooling (migrations 105–106)

- **Translate** — a button for anyone with write access (Operator and up), in the document panel
  and as "Translate a text" in My Space. It assembles the translation prompt and the source text to
  paste into Claude. **The app makes no call to Claude**: an API key cannot live in a browser, and
  a real call would sit behind a server function. What comes back is a **draft** for a human
  reviewer. It is prefilled only with Italian source text — on an Italian record, its own text —
  never with the Urdu body.
- **The prompt** (`translation_prompts`, migration 106) is the working form of the translation
  style guide, kept as numbered, append-only versions; the newest is in force. Operator and up read
  it; only Admin adds a version, from My Department → Archive & Data, with a one-line note of what
  changed. Nothing is deleted, so a bad edit is undone by saving the old text again. It lives in
  the database, not in code, because the guide changed its canonical terms three times in two days.
- **The mining log** (`skill_corpus_analysis_log`, migration 105, Admin only) holds one row per
  cycle. *Mining* means reading the real Italian↔Urdu pairs — 122 Italian documents over 118 works —
  to see which Urdu form the community writes for a glossary term. Two cycles so far (2026-09-21,
  guide 3.0 → 3.1; 2026-10-19, 3.2 → 3.4). It never promotes anything (§1.7): فوکولاری, ماریاپولس,
  آئیڈیل and the greeting ڈئیراسٹ became canonical only by the Owner's decision (§8 item 13).
- **Not built**: a real call to Claude from the app, and saving the "uncertain terms" list the
  prompt asks the model to return, which would let everyday use feed the next mining cycle.


### 5.12 Archive doors, task review and the log (migrations 109–110)

- **Who can make a document visible:** only Admin. A trigger on `documents`
  (`guard_document_visibility`) enforces it whatever the app does: anyone else can insert only a
  hidden `revision` draft and cannot move a document between hidden and visible. Moves between two
  visible states stay open (the old process steps), and so does editing the metadata of a published
  document: narrowing that is a later decision, because Archive & Data needs it.
- **Document numbers** come from the server (`next_document_id()`, a sequence), never from the
  browser, and a number is never reused.
- **The log:** `archive_log` records who, when, what, with the value before and after, for documents,
  texts, collections, process steps, Works, tasks, roles, qualifications and department members. It
  is written by database triggers, and nobody can change or empty it. It starts on the day migration
  110 ran: what happened before cannot be reconstructed. It records who changes things, never who
  reads them. **Change history** on a document: Coordinators and Admin. **Activity** of a person: that
  person, Admin and the HR lead.
- **Deleting:** `soft_delete_document()` needs a reason and hides the document from everyone. The
  record and its files stay, and Admin restores it from My Department → Archive & Data. Nobody can
  erase a document through the app.
- **Task review (migration 109):** a Revisor, Coordinator or Admin gives the verdict; nobody reviews
  their own task, except Admin. Credits and reputation are written once, at Admin's decision, and the
  document then moves to `pending_publish`. A task reviewed by the person who did it stays
  recognisable (`reviewed_by = claimed_by`), so Reward reports can leave test credits out.
- **A Word of Life** extracted from the Hayat index takes its own month (`data_pdv`), not the issue's.


### 5.13 Access levels (migration 111)

| Level | Who sees it in the app | Where the file can be |
|---|---|---|
| **Public** | Registered users; it may also exist outside the archive | A link to YouTube or elsewhere, or Drive |
| **Private** (the default, and every document that existed on 2026-11-05) | Registered users | Drive |
| **Reserved** | Admin, Formation members, people they have enabled | Drive; text and records protected in the database |

- **For anyone not enabled, a reserved document does not exist:** not in lists, search, tasks, boards,
  formation paths, favourites or history. A Work whose documents are all reserved hides its title too.
  Task lists for Coordination and Reward show "(reserved)" in place of its title and note.
- **Who decides:** only Admin and Formation members can give or take away the reserved level, or
  enable a person, from My Department → Formation. Who is enabled is visible only to them, and every
  change is in the log (§5.12). A correction made through a task inherits the level of the document
  it corrects, and nobody without the right can lower it.
- **What this does not protect, by the Owner's decision:** PDFs and `.inp` files stay in the current
  Drive folder, open to anyone with the link. The folder's identifier is in the published JavaScript,
  and a file's name contains the document's title. Records, texts and files in Supabase Storage are
  protected. For a very delicate document, keep only the text here and do not upload the PDF. A link
  to a video also works outside the app.
- **Also protected now:** nobody but those who can see a document can read its text, so the text of a
  hidden draft or a deleted document is no longer readable through the API.
- **Adding a reserved document:** through the proposal form (§5.14), with a second Formation member or
  Admin approving.


### 5.14 Proposals: the one door for new content (migration 112)

- **Form:** three steps. Is it new or does it already exist (a search suggests, a person decides, nothing
  is linked by itself); what the versions share (English title, category, author, date or period, and
  optionally recipient, topic, tags, Bible verse); then one version per language, with its title and
  its text or a PDF. The text can be pasted or loaded from a Word `.docx`, of which only the text is
  kept; Urdu in InPage goes through the InPage Converter first. Numbers, file names, status and the
  preferred mark are set by the system. Adding the text is what makes a document searchable.
- **Adding to a document already in the archive:** its panel has **+ Add a related version**. The form opens
  filled in from that document and tied to its Work: the link can't be removed, even when the draft is reopened,
  and the level follows the document. On a reserved document, only Admin and Formation get the button.
- **States:** draft, awaiting review, to correct (with a note), published, rejected. Each version is a
  normal record in the hidden status `proposed`, visible only to the proposer and to those who can
  review it. Every version of a proposal is published at once.
- **Who decides:** a Revisor or Coordinator, never on their own proposal. Reserved content is reviewed
  only by another Formation member or Admin. Admin may review their own, and may publish directly.
  A proposal's text cannot be changed by direct writes, only through the form.
- **A text counts as reread only if the reviewer says so,** version by version. The rest stays unverified.
- **Nothing gets stuck:** the proposer sees how long it has waited and can send a reminder after 3 days,
  then once every 3 days. It reaches the queue, not a person. Taking a proposal holds it for 48 hours,
  then it returns by itself. After 7 days it is marked as overdue (§4). All of this is computed from
  dates. It works inside the app only: a tab count and a note at sign-in, no email.
- **PDFs:** they stay in Supabase during review. After approval, Admin copies them to Drive from
  Proposals → Files for Drive, and the Supabase copy is removed, because the project is on the Free plan.
  Until then the document offers a download link, and its Open PDF button doesn't find the file.
- **Credits:** none for proposing. Whoever wants a compensation agrees with the team first, which creates
  a task (Owner's decision).
- **Not yet part of this door:** a task correction keeps its own path, with Admin's final decision (row 12),
  since credits depend on it. Promoting a board post still creates a hidden draft outside the queue,
  until the Boards change (done in §2.6: promoting no longer exists).

### 5.15 Video and audio (migration 113)

- **Video is a link, never a file:** https, YouTube or Google Drive only, enforced by the database. The
  original stays on Drive, so the archive doesn't depend on YouTube. Like any link, it also works outside
  the app (§5.13).
- **A reading is a record of its own** (`media_type` `AUD`), in the same Work and language as its text, with
  its own access level. The file is in the private bucket `reading-audio` (up to 25 MB, MP3, M4A, AAC, OGG
  or WEBM), opened through a link valid for one hour. Whoever can't see the document can't open the file:
  hidden, reserved and deleted documents keep it closed. The details are in `audio_readings`, which is written
  only by the proposal functions and is in the log.
- **The reader's name is shown** next to the player (Owner's decision), and the form requires it.
- **Both enter through the one door** (§5.14): the form asks for the format of each version.
- **A newer reading takes the star** for its Work and language, and the older one stays, reachable from
  "Other versions". The star is per Work, language and format, so a reading never takes it from a text.
- **Finding them:** Listen and Watch video buttons on every version of the Work; marks on the Library list; an
  "Audio and video only" button; and a Word of Life of the month card in Start Here, for those who can't
  look for it by typing. Readings stay out of the normal list and of reports, so they don't double them.
- Readings can also be uploaded by the team as ordinary proposals. Readings by anyone signed in follow §5.16.
- `recordtest.html` tests what a phone can record and play. It sends nothing and saves nothing.

### 5.16 Reading aloud (migration 114)

- **Who:** anyone signed in, User included, with no audition (Owner's decision). No credits by itself; a
  compensation is agreed with the team first, through a task.
- **Which texts:** those already reread, or whose source is `STE` (Owner's decision on Stella's texts). So the
  `ALE` transcriptions wait until they are reread. Not reserved texts: those are recorded by the team through
  the proposal form. One published reading per text; a Coordinator or Admin may have a new one replace it.
- **Consent:** accepted once, per version of the wording, and logged. The name shown comes from the person's
  profile. The first wording is English only until the Owner gives the Urdu.
- **Holding a text:** 7 days, so two people don't read the same one. A first reading is limited to 4,000
  characters and one text at a time; after the first approved reading, 20,000 characters and three texts.
- **Recording:** in the browser, with a 10-second trial, pause and the text on screen, or by uploading a file.
  Pieces are saved on the phone every 5 seconds until the server has confirmed the recording.
- **Review:** by the `AUDIO_REVIEWER` qualification, Coordinators and Admin, never one's own (Admin excepted,
  §1 principle 3). Revisors of written texts don't review readings, since judging a voice is a different
  skill. OK, OK with a note, record again (no consequences) or not accepted (the text is free again). Claims,
  reminders, overdue marks and the log are those of proposals (§5.14), in their own queue.
- **The reader's name stays off the review screens,** though a voice can be recognised, and a technical person
  could read it through the API. It is meant to keep the review on the voice, not as a guarantee.
- **Withdrawing consent:** from the same section, or by Admin on request. Every reading of that person leaves
  at once, and any in review is discarded. Copies already saved on someone's device can't be called back.
- **Files:** a file nothing uses goes on a list and closes at once. It is then removed by the person's browser
  or by Admin, since a database can't remove a stored file. A not-accepted recording stays 30 days. Admin also
  sees files nothing points at. The row stays in the log, without the content.
- **Space:** no new texts can be held once recordings reach 500 MB, on the Free plan's 1 GB shared with PDFs.
- **Listens are only counted,** per reading and per day. Who listened is not recorded (§5.9).
- **Readers:** Coordination, HR and Admin see each reader's published, waiting, sent-back and not-accepted
  readings and their listens, to give the best readers the most important work. That work would go through a
  task; the `READER` qualification and a reading task category aren't built yet.

### 5.17 The month's Word of Life and the magazine (migration 115)

- **One Work per month,** found by its month (`works.series`, `series_period`) rather than by guessing a title.
- **Proposals → Word of Life:** for a chosen month, shows Italian, English, Urdu, video and audio, each with its
  state or marked as missing. Pieces can be proposed together, as one package published at once, or added later.
- **Existing documents:** if a month's documents already share one Work, that Work becomes the month's. If they
  are in several, nothing merges by itself (§1): they are listed as not linked, and a Coordinator or Admin links
  them. A star already held for a language and format stays where it is.
- **Tasks:** translation and video remain Coordination's tasks. The month shows open translation tasks and leads
  a Coordinator to the source text to create one. A translation made through a task now becomes a version in
  Urdu, and keeps the source's date, recipients and topic.
- **The star:** per Work, language and format in every path now, tasks and "Set preferred" included.
- **The magazine:** an issue is its own record (category Magazine issue), with its own month and PDF. What it
  contains points to it (`contained_in_document_id`, `contained_page`), and each side links to the other. A Word of
  Life keeps its own month. Issue records don't exist yet: they are added as proposals as their PDFs are ready.
- **Data cleaned:** periods holding a page (`2001-04p.7`) now hold only the month. The page stays in the issue
  field, and the old values are in the log.

### 5.18 Help: guides by activity (migration 116)

- **One entry per guide, not per role:** eight groups (use the archive, add to it, work with the team, check others'
  work, your role, department pages, run the project, reference). A person sees only what applies to their role,
  qualifications, departments and boards (`help_pages.audience`). This is for clarity, not protection: any signed-in
  person can read any guide through the API, so guides must hold nothing confidential.
- **Languages:** English, Italian and Urdu, one selector. **The Urdu was drafted with the translation skill at the Owner's request
  (2026-11-06, migration 119), and stays a draft, seen by the team (Operators and up) but not by plain Users, until those who know Urdu well have reviewed it** (§1
  principle 7). It is opened guide by guide with `help_pages.draft`. Plain Users then read Urdu first, unless they choose otherwise.
- **Role guides** set out a person's field, what isn't theirs, and a suggested daily and weekly rhythm. **The rhythm is
  a suggestion, not a rule of this document.** Where a guide and this document differ, this document holds.
- **A "?" beside a screen's title** opens its guide. **The Read aloud guide is visible to plain Users too** (Owner's
  decision, 2026-11-06, migration 117), since they can read aloud. Showing the guide isn't announcing the feature.
- The old pages are kept in `_backup_help_pages_20261106`. Admins edit guides in place in the app.

### 5.19 Date of birth (migration 120)

- **Why:** a bracket goes out of date as people age. A date gives the right group every day, and will let Formation choose its
  audience by age.
- **Who sees what:**

| Who | Sees |
|---|---|
| The person | Their own date |
| HR lead, Admin | The date |
| HR and Formation members, Coordinators | Only the age group |
| Everyone else | Neither, for anyone but themselves |

- **Permissions, not encoding (Owner's decision):** the date has its own table, `user_birth_dates`, with one rule for reading, enforced by
  the database whatever the app does. It isn't in `user_profiles`, which Coordinators can read in full. Nobody writes it directly: a
  person sets their own and an Admin anyone's through `set_date_of_birth()`. The value isn't copied to `archive_log`.
- **The age group is computed, never stored,** by `age_bracket_of()`, the only place that defines the brackets. Others get it from
  `people_age_brackets()`, which gives no date. The codes are those of the option list `age_bracket`, which holds the labels: keep them.
- **Old brackets** can't become dates. They stand in, marked as declared, until the person gives the date, and are then cleared.
- **At sign-up** the date is required. It can only travel through the account's metadata, so a trigger moves it to the table and removes it
  from there. A bad date never blocks a sign-up.
- **Asking those already registered:** a pop-up after sign-in, once per session, only for those with no date. It never blocks the app:
  Later asks again after 7 days. English until the Urdu has been reviewed.
- **Not built:** choosing a formation audience by age. Formation is to say first which brackets it needs: 18-30 and 31-65 may be too wide.

---

## 6. What's left to build

Subsections 6.1–6.4 and 6.6 of v1.0 shipped as designed (with the naming differences noted
inline in §5) and their content now lives in §5, where it describes the running system rather
than a plan. The subsection numbers below are kept only so existing cross-references (§2, §4, §7)
keep pointing at something; §6.1, 6.1b, 6.1c, 6.2, 6.3, 6.4 and 6.6 are retired as "to-build"
entries; as of v1.6, §6.5 (Communication) joins them, shipped — see §5.8. All that remains open in
§6 is two low-priority known gaps (§6.7, §6.8) — nothing is actively "to build".

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

### 6.5 Communication — shipped, see §5.8
What used to read "nothing required" turned out to need real software after all: authoring
"Start Here" and reading/replying to "Share with us" (migration 95, §5.8, §2.5). A "What's new"
block on the Dashboard fed by Announcements remains a nice-to-have, still not built.

### 6.7 Known gap: formation path publish doesn't fully match §4 row 17
Row 17 implies a Formatore proposes and the Formation lead approves publishing, as a distinct
proposer/approver pair. In practice `can_edit_path()`'s publish check (§5.4) allows the owner
(who is usually the same formatore who wrote it), the Formation lead, any Coordinator, or Admin —
so an owner who is also a formatore can publish their own path without a second person's sign-off.
Pre-dates migrations 80–93; not a regression, but not matched to the letter of the matrix either.
Low priority: formation paths go through the same document revision/approval workflow before
their content reaches the archive (row 18), so this doesn't bypass the archive's own review.

### 6.8 Known gap: department-lead appointment isn't RLS-enforced
Carried over, not touched by migrations 80–106:
- "Only the Owner appoints department leads" (row 8) is a written rule, not an RLS-enforced one —
  any Admin can currently write `department_members`. Harmless today (Owner is the sole Admin);
  revisit if/when a second Admin is added.

(Internal team communications, the other item that used to be listed here, shipped this session —
see §5.3.)

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
| later | The app's own interface in Urdu (not just bilingual content) | — | — | Not started; waiting on the two people who write the wording |

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
9. **Internal team communications (§5.3, migration 94), scoped 2026-09-18:** any department
   member may post and reply, not lead-only broadcast — restricting posting to leads would make it
   announcement-only, and members would have no in-app way to respond. Admin sees and can post in
   every department's channel, consistent with Admin's visibility everywhere else in My Department.
   The department lead (or Admin) may pin a message; the author may edit or delete their own
   message for 15 minutes after posting, a fixed UX allowance rather than a `policy_values` entry —
   it isn't a governance decision the propose/approve framework needs to own.
10. **"Start Here" and "Share with us" (§5.8, migrations 95–96), scoped 2026-09-18/19:** bilingual
    cards over a full Urdu UI for now — a separate, larger project (translating all existing UI
    chrome) waits on Asci/Sheril, not blocking this. Video cards link to content Communication
    already publishes elsewhere; no video hosting was built. Share with us is open to anyone
    signed in, not just Users, and every department lead/Admin reads every share (not gated to one
    department, unlike the Team channel) — the Owner's framing: reciprocal, not a ticket queue.
    Voice messages (phase 1b) were deliberately sequenced after the text-only launch, to keep the
    newest technical territory (browser audio recording) from blocking the rest.
11. **Department Pulse (§5.9, migration 98), scoped 2026-09-20:** a department's status indicator
    is set by hand by its lead, not computed from task/credit data. Raised and settled in the same
    conversation - a wrong automatic signal (a stale green, or a metric that fits one department's
    work but not another's) would undermine trust in the indicator faster than a manual one that's
    honestly subjective. The human note next to the color is the actual point: motivation and
    alignment, not a KPI. Admin's "Project overview" roll-up needed no separate decision - it
    follows directly from Admin already reading every department's row (§2, throughout).
12. **Languages and dates in the archive (§5.10), clarified 2026-09-21 and 2026-10-18:** the Owner's
    rule is that every document in every language has its own record, grouped by `work_id`, and its
    text is the body of that record, not a sidecar of another; and that `ref_date` is the date of
    the Collegamento, so it equals the date in its title, the title being authoritative because two
    independent sources agree with it on every comparable document. Both are statements about what
    the archive's fields *mean*, decided by the Owner, not inferred from the data.
13. **Terminology comes from the community and is decided by the Owner (§1.7, §5.11), 2026-09-20 and
    2026-10-19:** a mining cycle reports attested forms and where they diverge from the glossary;
    nothing is promoted automatically. The Owner promoted فوکولاری (2026-09-20), then ماریاپولس,
    آئیڈیل (with the hamza) and the greeting ڈئیراسٹ (written joined) on 2026-10-19 — each time the
    form the corpus already used. The Translate prompt is kept in the database as numbered versions,
    changed by Admin only, because the terminology moved three times in two days. Translate stays
    copy-and-paste — no key in the browser, and a draft always meets a human reviewer.
14. **A sixth department, Archive & Data (§2.9), created 2026-09-20:** the Owner made it himself
    from Options, as its lead, to give the cataloguing tools a home and the people who use them a
    Team channel of their own to coordinate in. A department is data (§1.1), so no migration was
    needed.
15. **The program is renamed "Digital Urdu Archive" (DUA), 2026-11-05:** the Owner changed the name
    from "Focolare Urdu Archive" because its initials, FUA, can be read badly in English; "DUA"
    (دعا in Urdu, "prayer") is easier to say and to remember. The code, manifest and app icons use
    the new name; the repository and the live address keep the old "Urdu-Archive" name, because
    renaming them would change the web address that installed copies and shared links point to.
    Sheril confirmed the name sounds right in Urdu. **Rule: the program is always written "DUA" in
    Latin letters, never in Urdu script, even inside Urdu texts that mention it** — it is an acronym,
    not a word to translate or transliterate (this applies to the Start Here cards, the guides and the
    Translate prompt's output alike).
    Earlier sections and decision entries keep the name that was in use when they were written.
16. **Who brings content into the archive, 2026-11-05:** the Owner decided that nobody adds content
    alone and everything passes through a shared review, with Admin above it all during development.
    Decided in full in `Documentazione\PROTOCOLLO_Ingresso_archivio_v1.md` §3 (one door for new
    content, public / private / reserved documents, reminders, volunteer audio readings, Word of Life
    dated by its own month). Built: §5.12 to §5.17.
