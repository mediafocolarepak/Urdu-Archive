# Reward — Compensation Policy

**Author:** Alessandro Maggi (Admin) for Naeem Sohail (Reward lead) · **Approved by:** Alessandro Maggi (Admin) · **Date:** 17 September 2026
**Status:** 🟢 approved as trial policy — values match the live DB as of 2026-09-17. Naeem Sohail
(Reward lead) reviews and revises once he has studied the system; from then on, changes follow
the policy revision process (GOVERNANCE.md §2.8).

> This document is the reference required by GOVERNANCE.md §2.4 ("Policy before software") and
> answers the open question in §8 point 6 (where Reward records that are not in the app live:
> here, in the repo). As long as it stays in draft status, Phase 3 (`compensation_runs`, rate/tier
> history, anomaly report — GOVERNANCE.md §6.4) is not started.

---

## 1. What a credit is

_To be written — Naeem._ Questions to answer:
- In the first phase (October to March) the platform will be on beta version, not final. It will work on voluntarily bases. For this reason in this phase credits are not monetized. in a second phase a credit will be given a currency value (e.g. 1 credit = X PKR/EUR), keeping in consideration the funds raised for the project.
- The value is the same for every operator, and vary only according to the task.
- Everyone has the possibility to keep working voluntarily by anonymously donate the earned credits to a common fund, which will be used transparently for the benefit of worthy operators.
## 2. Rates per category (`task_category_rates`)

Current values in the DB (read on 2026-09-17):

| Category    | Credits per page | Last updated by               |
| ----------- | ---------------- | ----------------------------- |
| IT_UR       | 20               | alessanpk@yahoo.it            |
| TEXT_REREAD | 0.5              | _(seed value, never changed)_ |
| EN_UR       | 20               |                               |
| TYPING      | 15               |                               |
More categories will come. these values are for trial phase. this table should be an editable policy, that can be revised and approved by the admins and Leads team. 
_To confirm or revise — Naeem._ Only two categories are configured: if real work covers other
task categories that are not yet priced, they need to be added here before Phase 3 builds
history on top of these tables.

## 3. Extra credits

Current values in `policy_values`:

| Key | Value | Meaning |
|---|---|---|
| `extra_credit_abs_threshold` | 10 | above this absolute extra-credit amount, approval is required |
| `extra_credit_pct_threshold` | 30 | above this percentage (relative to the base), approval is required |
Same my comments as with the previous table.
For row 10 of the decision matrix (GOVERNANCE.md §4): the Coordinator grants extra credits with a
note; above the thresholds here, the **Coordination lead** must approve.

_To be written — Naeem._ Are the current thresholds correct for the Reward policy, or should
they be revised? (They were set during development, not yet a formal Reward decision.)

## 4. Reputation tiers (`task_reputation_tiers`)

Current values in the DB:

| Tier | Min base credits | Max base credits | OK delta | OK-but delta | Fail delta |
|---|---|---|---|---|---|
| Small | 0 | 10 | +5 | −3 | −5 |
| Medium | 11 | 30 | +10 | −5 | −10 |
| Large | 31 | (no limit) | +15 | −8 | −15 |

Plus one specific event outside this table:

| Event | Reputation delta | Key in `policy_values` |
|---|---|---|
| Board misuse (`board_misuse`) | −10 | `board_misuse_reputation_delta` |
all these tables must be recalibrated by the team at any time. 
_To confirm — Naeem._ Are these tiers still the intended ones, or should they be recalibrated
based on experience so far?

## 5. Converting credits into compensation

_To be written — Naeem._ Points to cover:
- **Frequency**: monthly, per project, on request?
- **Minimum threshold** of credits to trigger a payment (if any).
- **Who prepares** the compensation run (`compensation_runs.prepared_by`) and **who approves**
  it (`compensation_runs.approved_by`) — per the "the one who proposes does not approve" rule
  (GOVERNANCE.md principle 2), they cannot be the same person. The Reward lead approves; another
  Reward member (or the Owner) prepares, or vice versa.
- **Currency** and exchange rate, if payment is not made directly in credits.

## 6. Documentation required for each payment

This is a very sensitive part of the whole project. proper accountability has to be maintained, to assure maximum transparency and tracing of every money transaction. all records and journal should be properly maintained, so that at any moment internal or external auditing can be conducted. a system of redundant backup must be implemented on multiple platforms, online as well as local.
_To be written — Naeem._ What needs to be kept for every payment made (receipts, bank
references, declarations) to comply with Pakistani law and the Movement's rules. This feeds the
`compensation_lines.reference` field (GOVERNANCE.md §6.4).

## 7. Anomalies and controls

Risk thresholds currently configured in `policy_values` (used elsewhere in the app, e.g. the
People tab "at risk" flag):

| Key | Value | Meaning |
|---|---|---|
| `risk_negative_events` | 2 | number of negative events in the window that triggers "at risk" |
| `risk_reputation_below` | 40 | reputation threshold below which a person is flagged |
| `risk_window_days` | 60 | time window (days) over which negative events are counted |
The risk policy should be agreed together with HR department. At the moment it is ok like this
_To confirm — Naeem._ For Reward specifically: what should trigger an anomaly flag in the
compensation report (e.g. extra credits repeatedly granted above threshold, an operator whose
credits grow without corresponding published tasks)? Phase 3's report (GOVERNANCE.md §6.4) will
read these criteria.

---

## Progress checklist

- [x] Current rates, reputation tiers and thresholds imported from the DB (2026-09-17)
- [x] Sections 1, 3 (threshold review), 4 (tier review), 5, 6, 7 (anomaly criteria) written by Naeem
- [x] Approved by the Owner
- [ ] Phase 3 (rate/tier history, `compensation_runs`, anomaly report) started
