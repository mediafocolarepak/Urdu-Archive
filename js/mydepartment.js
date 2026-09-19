// "My Department" (migration 87, GOVERNANCE.md §2.7/§2.8): a single screen for a department
// lead (or Admin) to keep an eye on their own team and policy without hunting across tabs.
// Department list is fully data-driven from option_lists ('department') and department_members
// - departments can be added, renamed or retired from Options without touching this file.

import {
  sb, State, esc, today, withStatus, isAdmin, isDeptLead, likeSafe,
  nameMapForEmails, DEPARTMENT_MEDIA_BUCKET, ONBOARDING_MEDIA_BUCKET,
} from './core.js?v=20260919172343';
import { renderPolicySection } from './policy.js?v=20260919172343';
import { renderPeopleSection } from './people.js?v=20260919172343';
import { renderApplicationsView } from './collaboration.js?v=20260919172343';

function myDepartmentCodes() {
  if (isAdmin()) return (State.optionListsByName.department || []).map(([c]) => c);
  return State.myDepartments.map(d => d.department_code);
}

function deptLabel(code) {
  const depts = State.optionListsByName.department || [];
  const hit = depts.find(([c]) => c === code);
  return hit ? hit[1] : code;
}

export async function renderMyDepartmentView(main) {
  const codes = myDepartmentCodes();
  if (!codes.length) {
    main.innerHTML = '<div class="panel"><h2>My Department</h2><div class="empty-msg">You are not a member of any department yet - see Options &rarr; Departments (Admin) to be added.</div></div>';
    return;
  }
  const selected = codes.includes(State.myDeptSelected) ? State.myDeptSelected : codes[0];
  State.myDeptSelected = selected;

  main.innerHTML = `
    <div class="panel">
      <h2>My Department</h2>
      ${codes.length > 1
        ? `<div class="field" style="max-width:280px;"><label>Department</label><select id="mydept-select">${codes.map(c => `<option value="${esc(c)}" ${c === selected ? 'selected' : ''}>${esc(deptLabel(c))}</option>`).join('')}</select></div>`
        : `<p class="hint">${esc(deptLabel(selected))}</p>`}
    </div>
    <div id="mydept-roster-box"></div>
    <div id="mydept-channel-box"></div>
    ${selected === 'HR' ? '<div id="mydept-applications-box"></div>' : ''}
    ${selected === 'HR' ? '<div id="mydept-people-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-credits-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-compensation-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-anomalies-box"></div>' : ''}
    ${selected === 'COORD' ? '<div id="mydept-tasks-box"></div>' : ''}
    ${selected === 'FORM' ? '<div id="mydept-formation-box"></div>' : ''}
    ${selected === 'COMM' ? '<div id="mydept-onboarding-box"></div>' : ''}
    <div id="mydept-policy-box"></div>`;

  if (codes.length > 1) {
    document.getElementById('mydept-select').addEventListener('change', e => {
      State.myDeptSelected = e.target.value;
      renderMyDepartmentView(main);
    });
  }

  await renderRoster(selected);
  await renderDeptChannel(document.getElementById('mydept-channel-box'), selected);
  // HR's work starts with Team Applications (screening candidates before they're even Operators)
  // and continues with the People roster (GOVERNANCE.md §6.2) once they're on the team - both
  // belong here, per the owner's request 2026-09-17/18, so an HR lead doesn't have to bounce
  // between My Department and two separate standalone tabs. Reused as-is (same component the
  // standalone Team Applications tab uses), not duplicated.
  if (selected === 'HR') await renderApplicationsView(document.getElementById('mydept-applications-box'));
  if (selected === 'HR') await renderPeopleSection(document.getElementById('mydept-people-box'));
  // Reward needs to see credits in circulation to tune rates/tiers and, later, plan compensation
  // runs (GOVERNANCE.md §6.4, migration 88) - same numbers Admin already sees in Tasks -> Budget,
  // read-only here (topping up the budget stays an Owner/Admin action, decision matrix row 16).
  if (selected === 'RF') await renderRewardCredits(document.getElementById('mydept-credits-box'));
  // GOVERNANCE.md §6.4 (migration 91): "credits earned" vs "credits paid" reconciliation and an
  // anomaly report - the two pieces migration 88 left open.
  if (selected === 'RF') await renderCompensationRuns(document.getElementById('mydept-compensation-box'));
  if (selected === 'RF') await renderRewardAnomalies(document.getElementById('mydept-anomalies-box'));
  // Coordination needs a live flow overview - counts plus who to follow up with - since
  // Tasks -> Team overview (js/tasks.js) only ever shows a filtered list, no counts, and
  // excludes open (unclaimed) tasks entirely. Read-only here: reassigning/reclaiming a task
  // stays in Team overview, which already does it correctly against the real RLS.
  if (selected === 'COORD') await renderCoordinationOverview(document.getElementById('mydept-tasks-box'));
  // Formation needs the pipeline (what's being written, what's published) and a way into each
  // path to actually coordinate/help - a FORM lead already has full read access to every path
  // (including drafts) and the formatori-only chat channel via existing RLS (is_any_formatore()
  // == FORM membership since migration 80), so no new migration is needed here, only the view.
  if (selected === 'FORM') await renderFormationPipeline(document.getElementById('mydept-formation-box'));
  // Communication authors the "Start Here" cards (95_onboarding_and_share_with_us.sql) from here -
  // onboarding.js only ever reads onboarding_cards, this is the one place that writes it.
  if (selected === 'COMM') await renderOnboardingCardsManager(document.getElementById('mydept-onboarding-box'));
  await renderPolicySection(document.getElementById('mydept-policy-box'), { departmentFilter: selected });
}

async function renderFormationPipeline(box) {
  const [paths, editorRows, chatRows] = await Promise.all([
    withStatus(sb.from('formation_paths').select('id,title,target_audience,status,owner_id,course_starts_at,course_ends_at').order('created_at', { ascending: false })),
    withStatus(sb.from('formation_path_editors').select('path_id,user_id')),
    withStatus(sb.from('formation_chat_messages').select('path_id,created_at').eq('channel', 'formatori').order('created_at', { ascending: false })),
  ]);
  const ownerIds = [...new Set(paths.map(p => p.owner_id))];
  const profileRows = ownerIds.length
    ? await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', ownerIds))
    : [];
  const profileByUid = {};
  for (const p of profileRows) profileByUid[p.user_id] = p;
  const coAuthorCount = {};
  for (const e of editorRows) coAuthorCount[e.path_id] = (coAuthorCount[e.path_id] || 0) + 1;
  const activityCount = {};
  const lastActivity = {};
  for (const m of chatRows) { // rows are newest-first, so the first hit per path is the last activity
    activityCount[m.path_id] = (activityCount[m.path_id] || 0) + 1;
    if (!lastActivity[m.path_id]) lastActivity[m.path_id] = m.created_at;
  }
  const ownerName = uid => { const p = profileByUid[uid] || {}; return p.full_name || p.email || uid || '—'; };

  const row = p => `<tr>
    <td>${esc(p.title)}</td>
    <td>${esc(p.target_audience) || '<span class="hint">—</span>'}</td>
    <td>${esc(ownerName(p.owner_id))}</td>
    <td>${coAuthorCount[p.id] || 0}</td>
    <td>${p.course_starts_at || p.course_ends_at ? `${esc(p.course_starts_at) || '?'} &rarr; ${esc(p.course_ends_at) || '?'}` : '<span class="hint">not scheduled yet</span>'}</td>
    <td>${activityCount[p.id] ? `${activityCount[p.id]} msgs &middot; last ${esc((lastActivity[p.id] || '').slice(0, 10))}` : '<span class="hint">none yet</span>'}</td>
    <td><button class="btn secondary mydept-open-path-btn" data-id="${p.id}" style="padding:4px 10px;">Open</button></td>
  </tr>`;
  const section = (title, hint, rows) => `
    <h3 style="margin-top:16px;">${esc(title)} <span class="count-badge">${rows.length}</span> ${hint ? `<span class="hint">${esc(hint)}</span>` : ''}</h3>
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Title</th><th>Audience</th><th>Owner</th><th>Co-authors</th><th>Course dates</th><th>Formatori chat</th><th></th></tr></thead>
      <tbody>${rows.length ? rows.map(row).join('') : '<tr><td colspan="7" class="hint">None.</td></tr>'}</tbody>
    </table></div>`;

  box.innerHTML = `
    <div class="panel">
      <h2>Formation pipeline <span class="hint">— every path, open one to coordinate or help tune it</span></h2>
      ${section('In progress', '— being written, not yet published (drafts)', paths.filter(p => p.status === 'draft'))}
      ${section('Published', '', paths.filter(p => p.status === 'published'))}
      ${(() => { const arch = paths.filter(p => p.status === 'archived'); return arch.length ? section('Archived', '', arch) : ''; })()}
    </div>`;

  box.querySelectorAll('.mydept-open-path-btn').forEach(btn => btn.addEventListener('click', () => {
    State.formationSelectedPathId = parseInt(btn.dataset.id, 10);
    document.querySelector('.tab-btn[data-tab="formation"]')?.click();
  }));
}

async function renderCoordinationOverview(box) {
  const rows = await withStatus(sb.rpc('coordination_task_overview'));
  const pendingExtraCredits = rows.filter(r => r.extra_credits_status === 'pending');
  const claimedIds = [...new Set(rows.filter(r => r.claimed_by).map(r => r.claimed_by))];
  const profileRows = claimedIds.length
    ? await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', claimedIds))
    : [];
  const profileByUid = {};
  for (const p of profileRows) profileByUid[p.user_id] = p;

  const nearDueDays = State.policyValues.task_near_due_days ?? 3;
  const todayStr = today();
  const nearDueLimit = new Date(); nearDueLimit.setDate(nearDueLimit.getDate() + nearDueDays);

  const isOverdue = r => r.status === 'claimed' && r.due_date && r.due_date < todayStr;
  const isNearDue = r => r.status === 'claimed' && r.due_date && !isOverdue(r) && new Date(r.due_date) <= nearDueLimit;

  const open = rows.filter(r => r.status === 'open');
  const claimed = rows.filter(r => r.status === 'claimed');
  const submitted = rows.filter(r => r.status === 'submitted');
  const approved = rows.filter(r => r.status === 'approved');
  const overdue = claimed.filter(isOverdue);
  const nearDue = claimed.filter(isNearDue);

  const whoName = uid => { const p = profileByUid[uid] || {}; return p.full_name || p.email || uid || '—'; };
  const daysDiff = due => Math.round((new Date(due) - new Date(todayStr)) / 86400000);
  const dueCell = r => {
    if (!r.due_date) return '<span class="hint">—</span>';
    if (r.status !== 'claimed') return esc(r.due_date);
    const d = daysDiff(r.due_date);
    return d < 0 ? `${esc(r.due_date)} <span style="color:var(--danger);font-weight:600;">(${-d}d overdue)</span>`
      : `${esc(r.due_date)} <span class="hint">(in ${d}d)</span>`;
  };

  const TABS = [
    { id: 'open', label: 'Open', rows: open, showAssignee: false, showDue: false },
    { id: 'claimed', label: 'Claimed', rows: claimed, showAssignee: true, showDue: true },
    { id: 'submitted', label: 'Awaiting review', rows: submitted, showAssignee: true, showDue: true },
    { id: 'approved', label: 'Awaiting publish', rows: approved, showAssignee: true, showDue: true },
    { id: 'overdue', label: 'Overdue', rows: overdue, showAssignee: true, showDue: true },
    { id: 'neardue', label: `Near due (≤${nearDueDays}d)`, rows: nearDue, showAssignee: true, showDue: true },
  ];
  const activeTab = TABS.find(t => t.id === State.myDeptCoordTab) || TABS[0];

  const rowHtml = (r, t) => `<tr>
    <td>${esc(r.title)}</td>
    <td>${esc(r.category)}</td>
    ${t.showAssignee ? `<td>${esc(whoName(r.claimed_by))}</td>` : ''}
    ${t.showDue ? `<td>${dueCell(r)}</td>` : ''}
  </tr>`;

  // Decision matrix row 10 (GOVERNANCE.md §4/§8.3, migration 90): extra credits above the
  // policy threshold can't be paid out until the Coordination lead approves them. Shown here,
  // not folded into a TABS entry, because it cuts across every status bucket above (a task can
  // be 'claimed' or 'submitted' and still be pending on its extra credits at the same time) and
  // it's the one place in this panel with a real write action, not just a read-only overview.
  const canApproveExtraCredits = isDeptLead('COORD');
  const extraCreditsRowHtml = r => `<tr>
    <td>${esc(r.title)}</td>
    <td>${esc(r.category)}</td>
    <td>${esc(r.base_credits ?? 0)}</td>
    <td>${esc(r.extra_credits)}</td>
    <td>${esc(r.extra_credits_note) || '—'}</td>
    <td>${esc(r.created_by_email) || '—'}</td>
    <td>${canApproveExtraCredits ? `<button class="btn mydept-approve-extra-btn" data-id="${esc(r.id)}" style="padding:2px 8px;">Approve</button>` : '<span class="hint">Coordination lead only</span>'}</td>
  </tr>`;

  box.innerHTML = `
    ${pendingExtraCredits.length ? `<div class="panel">
      <h2>Extra credits awaiting approval <span class="count-badge">${pendingExtraCredits.length}</span></h2>
      <p class="hint">Above the policy threshold (My Department &rarr; Policy, GOVERNANCE.md §8.3) - can't be given a passing review verdict until approved here. The proposer can't approve their own task.</p>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Task</th><th>Category</th><th>Base</th><th>Extra</th><th>Reason</th><th>Proposed by</th><th></th></tr></thead>
        <tbody>${pendingExtraCredits.map(extraCreditsRowHtml).join('')}</tbody>
      </table></div>
    </div>` : ''}
    <div class="panel">
      <h2>Task flow <span class="hint">— live overview of the open pipeline, same buckets as Tasks</span></h2>
      <div class="btn-row" style="margin-bottom:12px;flex-wrap:wrap;">
        ${TABS.map(t => `<button class="btn ${t.id === activeTab.id ? '' : 'secondary'} mydept-coord-tab-btn" data-tab="${t.id}">${t.label} <span class="count-badge">${t.rows.length}</span></button>`).join('')}
      </div>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Task</th><th>Category</th>${activeTab.showAssignee ? '<th>Assignee</th>' : ''}${activeTab.showDue ? '<th>Due</th>' : ''}</tr></thead>
        <tbody>${activeTab.rows.length ? activeTab.rows.map(r => rowHtml(r, activeTab)).join('') : `<tr><td colspan="${2 + (activeTab.showAssignee ? 1 : 0) + (activeTab.showDue ? 1 : 0)}" class="empty-msg">Nothing here.</td></tr>`}</tbody>
      </table></div>
      <p class="hint" style="margin-top:8px;">Read-only - reassign, reclaim, review or publish a task from the Tasks tab, where those actions already work against the real permissions.</p>
    </div>`;

  box.querySelectorAll('.mydept-coord-tab-btn').forEach(btn => btn.addEventListener('click', () => {
    State.myDeptCoordTab = btn.dataset.tab;
    renderCoordinationOverview(box);
  }));

  box.querySelectorAll('.mydept-approve-extra-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Approve these extra credits? This lets the task be given a passing review verdict.')) return;
    const { error } = await sb.rpc('approve_task_extra_credits', { p_task_id: parseInt(btn.dataset.id, 10) });
    if (error) { alert(error.message); return; }
    renderCoordinationOverview(box);
  }));
}

async function renderRewardCredits(box) {
  const [overviewRows, ledgerRows] = await Promise.all([
    withStatus(sb.rpc('reward_credit_overview')),
    withStatus(sb.from('budget_ledger').select('*').order('created_at', { ascending: false })),
  ]);
  const o = overviewRows[0] || { open_credits: 0, in_progress_credits: 0, to_redeem_credits: 0, redeemed_credits: 0, budget: 0 };
  const used = o.open_credits + o.in_progress_credits + o.to_redeem_credits + o.redeemed_credits;
  const available = o.budget - used;
  const tile = (label, value) => `<div class="field"><label>${esc(label)}</label><div style="font-size:20px;font-weight:600;">${esc(value)}</div></div>`;

  box.innerHTML = `
    <div class="panel">
      <h2>Credits in circulation <span class="hint">— live, GOVERNANCE.md §6.4</span></h2>
      <p class="hint">Every credit currently posted, claimed, awaiting review, or already published - useful for tuning rates and reputation tiers (Policy, below), and later for planning compensation runs.</p>
      <div class="field-grid">
        ${tile('Budget', o.budget)}
        ${tile('Available', available)}
        ${tile('Posted, not claimed', o.open_credits)}
        ${tile('Claimed, in progress', o.in_progress_credits)}
        ${tile('Approved, to redeem', o.to_redeem_credits)}
        ${tile('Redeemed (published)', o.redeemed_credits)}
      </div>
      <p class="hint" style="margin-top:8px;">Topping up the budget stays an Owner/Admin action (Tasks &rarr; Budget).</p>
      <h3>Top-up history</h3>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Date</th><th>Amount</th><th>Note</th><th>Added by</th></tr></thead>
        <tbody>${ledgerRows.length ? ledgerRows.map(r => `
          <tr><td>${esc((r.created_at || '').slice(0, 10))}</td><td>${esc(r.amount)}</td><td>${esc(r.note) || '—'}</td><td>${esc(r.created_by_email) || '—'}</td></tr>
        `).join('') : '<tr><td colspan="4" class="empty-msg">No top-ups recorded yet.</td></tr>'}</tbody>
      </table></div>
    </div>`;
}

// ---------- Compensation runs (migration 91, GOVERNANCE.md §6.4 / decision matrix row 15) ----------
// "Reward proposes, Lead Reward + Owner approves" - here, Admin stands in for Owner (the schema
// has no separate Owner identity), and proposer never equals approver, enforced in
// decide_compensation_run() itself, not just by hiding the button.

async function renderCompensationRuns(box) {
  const runs = await withStatus(sb.from('compensation_runs').select('*').order('created_at', { ascending: false }));
  const lineRows = runs.length
    ? await withStatus(sb.from('compensation_lines').select('*').in('run_id', runs.map(r => r.id)))
    : [];
  const linesByRun = {};
  for (const l of lineRows) (linesByRun[l.run_id] = linesByRun[l.run_id] || []).push(l);
  const { data: { user } } = await sb.auth.getUser();

  const runRowHtml = r => {
    const lines = linesByRun[r.id] || [];
    const totalCredits = lines.reduce((s, l) => s + l.credits_settled, 0);
    const canDecide = r.status === 'pending' && isAdmin() && r.prepared_by_email !== user.email;
    const canWithdraw = r.status === 'pending' && r.prepared_by_email === user.email;
    return `<tr>
      <td>${esc(r.period_from)} &rarr; ${esc(r.period_to)}</td>
      <td>${lines.length} ${lines.length === 1 ? 'person' : 'people'}, ${esc(totalCredits)} credits</td>
      <td>${esc(r.status)}</td>
      <td>${esc(r.prepared_by_email)}</td>
      <td>
        <button class="btn secondary mydept-comp-details-btn" data-id="${esc(r.id)}" style="padding:2px 8px;">Details</button>
        ${canDecide ? `<button class="btn mydept-comp-approve-btn" data-id="${esc(r.id)}" style="padding:2px 8px;">Approve</button>
          <button class="btn danger mydept-comp-reject-btn" data-id="${esc(r.id)}" style="padding:2px 8px;">Reject</button>` : ''}
        ${canWithdraw ? `<button class="btn secondary mydept-comp-withdraw-btn" data-id="${esc(r.id)}" style="padding:2px 8px;">Withdraw</button>` : ''}
      </td>
    </tr>
    <tr class="mydept-comp-details-row" data-for="${esc(r.id)}" style="display:none;">
      <td colspan="5">
        ${r.note ? `<p class="hint">${esc(r.note)}</p>` : ''}
        <table class="grid"><thead><tr><th>Person</th><th>Credits settled</th><th>Amount</th><th>Reference</th></tr></thead>
        <tbody>${lines.map(l => `<tr><td>${esc(l.user_email)}</td><td>${esc(l.credits_settled)}</td><td>${esc(l.amount)} ${esc(l.currency)}</td><td>${esc(l.reference) || '—'}</td></tr>`).join('')}</tbody></table>
        ${r.decided_by_email ? `<p class="hint" style="margin-top:6px;">${esc(r.status)} by ${esc(r.decided_by_email)} on ${esc((r.decided_at || '').slice(0, 10))}${r.decision_note ? ' — ' + esc(r.decision_note) : ''}</p>` : ''}
      </td>
    </tr>`;
  };

  box.innerHTML = `
    <div class="panel">
      <h2>Compensation runs <span class="hint">— GOVERNANCE.md §6.4, decision matrix row 15</span></h2>
      <p class="hint">Records that credits were converted to money - it never moves money itself, only the record that a payment happened. ${isRfMember() ? '<button class="btn" id="mydept-new-comp-run-btn" style="margin-left:8px;">New compensation run</button>' : ''}</p>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Period</th><th>Lines</th><th>Status</th><th>Prepared by</th><th></th></tr></thead>
        <tbody>${runs.length ? runs.map(runRowHtml).join('') : '<tr><td colspan="5" class="empty-msg">No compensation runs yet.</td></tr>'}</tbody>
      </table></div>
    </div>`;

  box.querySelectorAll('.mydept-comp-details-btn').forEach(btn => btn.addEventListener('click', () => {
    const row = box.querySelector(`.mydept-comp-details-row[data-for="${btn.dataset.id}"]`);
    row.style.display = row.style.display === 'none' ? '' : 'none';
  }));
  box.querySelectorAll('.mydept-comp-approve-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Approve this compensation run? This records that these credits have been paid.')) return;
    const { error } = await sb.rpc('decide_compensation_run', { p_run_id: parseInt(btn.dataset.id, 10), p_outcome: 'approved' });
    if (error) { alert(error.message); return; }
    renderCompensationRuns(box);
  }));
  box.querySelectorAll('.mydept-comp-reject-btn').forEach(btn => btn.addEventListener('click', async () => {
    const note = prompt('Reason for rejecting this compensation run?');
    if (!note || !note.trim()) return;
    const { error } = await sb.rpc('decide_compensation_run', { p_run_id: parseInt(btn.dataset.id, 10), p_outcome: 'rejected', p_note: note.trim() });
    if (error) { alert(error.message); return; }
    renderCompensationRuns(box);
  }));
  box.querySelectorAll('.mydept-comp-withdraw-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Withdraw this compensation run?')) return;
    const { error } = await sb.rpc('decide_compensation_run', { p_run_id: parseInt(btn.dataset.id, 10), p_outcome: 'withdrawn' });
    if (error) { alert(error.message); return; }
    renderCompensationRuns(box);
  }));
  const newBtn = document.getElementById('mydept-new-comp-run-btn');
  if (newBtn) newBtn.addEventListener('click', () => openNewCompensationRunPopup(box));
}

// propose_compensation_run() (migration 91) requires real RF membership - matches the decision
// matrix's "Reward proposes" exactly, unlike deciding it (Admin, standing in for Owner). Admin
// alone, without an RF row, still sees this whole view (My Department shows every department to
// Admin) but can't propose from it - only decide.
function isRfMember() {
  return State.myDepartments.some(d => d.department_code === 'RF');
}

async function openNewCompensationRunPopup(box) {
  const unsettled = await withStatus(sb.rpc('reward_unsettled_credits'));

  const overlay = document.createElement('div');
  overlay.id = 'new-comp-run-popup';
  overlay.style.cssText = 'position:fixed;inset:0;z-index:2100;background:rgba(20,16,10,.55);display:flex;align-items:center;justify-content:center;overflow:auto;padding:24px 16px;';
  overlay.innerHTML = '<div class="panel" style="max-width:640px;width:100%;margin:0;"></div>';
  document.body.appendChild(overlay);
  const panel = overlay.querySelector('.panel');
  const close = () => overlay.remove();
  overlay.addEventListener('click', e => { if (e.target === overlay) close(); });

  panel.innerHTML = `
    <h2 style="margin-top:0;">New compensation run</h2>
    <div class="field-grid">
      <div class="field"><label>Period from</label><input id="comp-from" type="date"></div>
      <div class="field"><label>Period to</label><input id="comp-to" type="date"></div>
      <div class="field" style="grid-column:1/-1;"><label>Note <span class="hint">(optional)</span></label><input id="comp-note"></div>
    </div>
    <h3>Lines</h3>
    <p class="hint">Only people with unsettled credits are listed. Check who is included in this run, and set the amount actually paid.</p>
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th></th><th>Person</th><th>Unsettled</th><th>Credits to settle</th><th>Amount</th><th>Currency</th><th>Reference</th></tr></thead>
      <tbody>${unsettled.length ? unsettled.map(u => `<tr>
        <td><input type="checkbox" class="comp-line-check" data-uid="${esc(u.user_id)}"></td>
        <td>${esc(u.full_name) || esc(u.email)}</td>
        <td>${esc(u.unsettled)}</td>
        <td><input type="number" class="comp-line-credits" data-uid="${esc(u.user_id)}" min="1" max="${esc(u.unsettled)}" value="${esc(u.unsettled)}" style="width:80px;"></td>
        <td><input type="number" class="comp-line-amount" data-uid="${esc(u.user_id)}" min="0" step="0.01" style="width:100px;"></td>
        <td><input type="text" class="comp-line-currency" data-uid="${esc(u.user_id)}" value="PKR" style="width:70px;"></td>
        <td><input type="text" class="comp-line-reference" data-uid="${esc(u.user_id)}" style="width:120px;"></td>
      </tr>`).join('') : '<tr><td colspan="7" class="empty-msg">Nobody has unsettled credits right now.</td></tr>'}</tbody>
    </table></div>
    <div class="btn-row" style="margin-top:12px;"><button class="btn" id="comp-submit">Create run</button><button class="btn secondary" id="comp-cancel">Cancel</button></div>`;

  panel.querySelector('#comp-cancel').addEventListener('click', close);
  panel.querySelector('#comp-submit').addEventListener('click', async () => {
    const from = panel.querySelector('#comp-from').value;
    const to = panel.querySelector('#comp-to').value;
    if (!from || !to) { alert('Please set both dates for the period.'); return; }
    const checked = [...panel.querySelectorAll('.comp-line-check:checked')];
    if (!checked.length) { alert('Select at least one person.'); return; }
    const lines = [];
    for (const chk of checked) {
      const uid = chk.dataset.uid;
      const credits = parseInt(panel.querySelector(`.comp-line-credits[data-uid="${uid}"]`).value, 10);
      const amount = parseFloat(panel.querySelector(`.comp-line-amount[data-uid="${uid}"]`).value);
      const currency = panel.querySelector(`.comp-line-currency[data-uid="${uid}"]`).value.trim() || 'PKR';
      const reference = panel.querySelector(`.comp-line-reference[data-uid="${uid}"]`).value.trim() || null;
      if (!credits || credits <= 0) { alert('Credits to settle must be a positive number for every selected person.'); return; }
      if (!amount || amount <= 0) { alert('Amount must be a positive number for every selected person.'); return; }
      lines.push({ user_id: uid, credits_settled: credits, amount, currency, reference });
    }
    const { error } = await sb.rpc('propose_compensation_run', {
      p_period_from: from, p_period_to: to, p_note: panel.querySelector('#comp-note').value.trim() || null, p_lines: lines,
    });
    if (error) { alert(error.message); return; }
    close();
    renderCompensationRuns(box);
  });
}

// ---------- Anomaly report (migration 91, GOVERNANCE.md §2.4/§6.4) ----------

async function renderRewardAnomalies(box) {
  const [extraCreditTasks, operatorAnomalies] = await Promise.all([
    withStatus(sb.rpc('reward_extra_credit_tasks')),
    withStatus(sb.rpc('reward_operator_credit_anomalies')),
  ]);
  const flagged = operatorAnomalies.filter(o => o.flagged);

  box.innerHTML = `
    <div class="panel">
      <h2>Anomaly report <span class="hint">— GOVERNANCE.md §2.4/§6.4</span></h2>

      <h3>Tasks with extra credits <span class="count-badge">${extraCreditTasks.length}</span></h3>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Task</th><th>Category</th><th>Status</th><th>Base</th><th>Extra</th><th>Reason</th><th>Extra-credit approval</th><th>Proposed by</th></tr></thead>
        <tbody>${extraCreditTasks.length ? extraCreditTasks.map(t => `<tr>
          <td>${esc(t.title)}</td><td>${esc(t.category)}</td><td>${esc(t.status)}</td>
          <td>${esc(t.base_credits ?? 0)}</td><td>${esc(t.extra_credits)}</td><td>${esc(t.extra_credits_note) || '—'}</td>
          <td>${esc(t.extra_credits_status)}${t.extra_credits_approved_by_email ? ' — ' + esc(t.extra_credits_approved_by_email) : ''}</td>
          <td>${esc(t.created_by_email) || '—'}</td>
        </tr>`).join('') : '<tr><td colspan="8" class="empty-msg">No task has ever carried extra credits.</td></tr>'}</tbody>
      </table></div>

      <h3 style="margin-top:16px;">Operators with credits ahead of published work <span class="count-badge">${flagged.length}</span></h3>
      <p class="hint">Flagged once approved-but-unpublished credits exceed both their published credits and the policy floor (My Department &rarr; Policy, "reward_anomaly_backlog_credits").</p>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Person</th><th>Credits</th><th>Reputation</th><th>Approved, unpublished</th><th>Published</th><th>Published tasks</th></tr></thead>
        <tbody>${flagged.length ? flagged.map(o => `<tr>
          <td>${esc(o.full_name) || esc(o.email)}</td><td>${esc(o.credits)}</td><td>${esc(o.reputation)}</td>
          <td>${esc(o.approved_not_published_credits)}</td><td>${esc(o.published_credits)}</td><td>${esc(o.published_task_count)}</td>
        </tr>`).join('') : '<tr><td colspan="6" class="empty-msg">Nobody is flagged right now.</td></tr>'}</tbody>
      </table></div>
    </div>`;
}

async function renderRoster(code) {
  const box = document.getElementById('mydept-roster-box');
  const canManage = isAdmin() || isDeptLead(code);
  const memberRows = await withStatus(sb.from('department_members').select('user_id,is_lead').eq('department_code', code));
  const profileRows = memberRows.length
    ? await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', memberRows.map(r => r.user_id)))
    : [];
  const profileByUid = {};
  for (const p of profileRows) profileByUid[p.user_id] = p;
  const lead = memberRows.find(r => r.is_lead);
  const leadName = lead ? (profileByUid[lead.user_id]?.full_name || profileByUid[lead.user_id]?.email || lead.user_id) : '(none yet)';

  box.innerHTML = `
    <div class="panel">
      <h2>Team <span class="count-badge">${memberRows.length}</span></h2>
      <p class="hint">Lead: <strong>${esc(leadName)}</strong>${canManage ? ' <span class="hint">— appointing or replacing the lead is done from Options &rarr; Departments (Admin), see GOVERNANCE.md §2.8/§4 row 8</span>' : ''}</p>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Name</th><th>Email</th><th></th></tr></thead>
        <tbody>${memberRows.map(r => {
          const p = profileByUid[r.user_id] || {};
          return `<tr>
            <td>${esc(p.full_name) || '(no name)'}${r.is_lead ? ' <strong>(lead)</strong>' : ''}</td>
            <td>${esc(p.email)}</td>
            <td>${canManage && !r.is_lead ? `<button class="btn danger mydept-remove-btn" data-uid="${esc(r.user_id)}" style="padding:2px 8px;">Remove</button>` : ''}</td>
          </tr>`;
        }).join('') || '<tr><td colspan="3" class="hint">No members yet.</td></tr>'}</tbody>
      </table></div>
      ${canManage ? `<div class="field" style="margin-top:8px;">
        <label>Add member <span class="hint">(search by name or email)</span></label>
        <input id="mydept-search" placeholder="Type a name or email...">
        <div id="mydept-search-results"></div>
      </div>` : ''}
    </div>`;

  if (!canManage) return;

  document.getElementById('mydept-search').addEventListener('input', async e => {
    const q = e.target.value.trim();
    const resultsBox = document.getElementById('mydept-search-results');
    if (!q) { resultsBox.innerHTML = ''; return; }
    const pattern = likeSafe(q);
    const rows = await withStatus(sb.from('user_profiles').select('user_id,email,full_name').or(`full_name.ilike.${pattern},email.ilike.${pattern}`).limit(10));
    resultsBox.innerHTML = rows.map(r => `<div class="hint" style="cursor:pointer;padding:2px 0;" data-add-uid="${esc(r.user_id)}">${esc(r.full_name) || esc(r.email)} &middot; ${esc(r.email)}</div>`).join('') || '<div class="hint">No match.</div>';
    resultsBox.querySelectorAll('[data-add-uid]').forEach(el => el.addEventListener('click', async () => {
      const { data: { user } } = await sb.auth.getUser();
      const { error } = await sb.from('department_members').insert({ department_code: code, user_id: el.dataset.addUid, added_by_email: user.email });
      if (error && error.code !== '23505') { alert(error.message); return; } // 23505 = already a member, ignore
      document.getElementById('mydept-search').value = '';
      resultsBox.innerHTML = '';
      renderRoster(code);
    }));
  });

  box.querySelectorAll('.mydept-remove-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Remove this member from the department?')) return;
    const { error } = await sb.from('department_members').delete().eq('department_code', code).eq('user_id', btn.dataset.uid);
    if (error) { alert(error.message); return; }
    renderRoster(code);
  }));
}

// ---------- Team channel (94_department_messages.sql, PROJECT_HANDOFF_v33.md) ----------
// One flat, chronological message thread per department, visible only to that department's
// members and Admin - distinct from Boards (public, moderated) and the admin<->user chat
// (chat_messages: 1:1 ticketing). Any member can post; the department lead (or Admin) can pin;
// the author can edit/delete their own message within a short window after posting. The
// server-side window (the migration's trigger/RLS) is the real gate - this constant only decides
// when the client stops offering the Edit/Delete links, so don't rely on it for anything else.
const DEPT_MESSAGE_EDIT_WINDOW_MS = 15 * 60 * 1000;

function deptChatDateTime(iso) { return esc((iso || '').slice(0, 16).replace('T', ' ')); }

async function renderDeptChannel(box, code) {
  markDeptSeen(code);
  const canPin = isDeptLead(code) || isAdmin();
  const { data: { user } } = await sb.auth.getUser();

  const rows = await withStatus(sb.from('department_messages').select('*').eq('department_code', code).order('created_at'));
  const nameMap = await nameMapForEmails(rows.map(r => r.user_email));

  const imagePaths = rows.filter(r => r.image_path).map(r => r.image_path);
  let signedUrlByPath = {};
  if (imagePaths.length) {
    const { data } = await sb.storage.from(DEPARTMENT_MEDIA_BUCKET).createSignedUrls(imagePaths, 3600);
    (data || []).forEach(d => { if (d && d.signedUrl) signedUrlByPath[d.path] = d.signedUrl; });
  }

  // Each message renders exactly once as an interactive bubble (in the chronological thread) -
  // a pinned message additionally gets a plain, non-interactive reminder in the pinned section
  // above. Two interactive copies of the same message would mean two elements sharing the same
  // data-edit-id/data-delete-id/data-pin-id, and querySelector (singular) in the click handlers
  // below would always act on the first one regardless of which copy was actually clicked.
  const bubble = r => {
    const mine = r.user_id === user.id;
    const withinEditWindow = (Date.now() - new Date(r.created_at).getTime()) < DEPT_MESSAGE_EDIT_WINDOW_MS;
    const img = r.image_path && signedUrlByPath[r.image_path]
      ? `<div style="margin-top:6px;"><img src="${esc(signedUrlByPath[r.image_path])}" style="max-width:100%;max-height:240px;border-radius:8px;"></div>` : '';
    return `
      <div class="chat-bubble ${mine ? 'from-me' : 'from-other'} ${r.pinned ? 'pinned' : ''}" data-msg-id="${r.id}">
        <div class="chat-meta">${esc(nameMap[r.user_email] || r.user_email)} &middot; ${deptChatDateTime(r.created_at)}${r.edited_at ? ' &middot; edited' : ''}${r.pinned ? ' &middot; 📌 pinned' : ''}</div>
        <div class="dept-msg-body" dir="auto" style="white-space:pre-wrap;">${esc(r.body)}</div>
        ${img}
        <div class="btn-row" style="margin-top:6px;">
          ${mine && withinEditWindow ? `<span class="hint" style="cursor:pointer;text-decoration:underline;" data-edit-id="${r.id}">Edit</span>` : ''}
          ${mine && withinEditWindow ? `<span class="hint" style="cursor:pointer;text-decoration:underline;" data-delete-id="${r.id}">Delete</span>` : ''}
          ${canPin ? `<span class="hint" style="cursor:pointer;text-decoration:underline;" data-pin-id="${r.id}" data-pin-next="${!r.pinned}">${r.pinned ? 'Unpin' : 'Pin'}</span>` : ''}
        </div>
      </div>`;
  };
  const pinnedReminder = r => `
    <div class="chat-bubble pinned from-other">
      <div class="chat-meta">📌 ${esc(nameMap[r.user_email] || r.user_email)} &middot; ${deptChatDateTime(r.created_at)}</div>
      <div dir="auto" style="white-space:pre-wrap;">${esc(r.body)}</div>
    </div>`;

  const pinned = rows.filter(r => r.pinned);

  box.innerHTML = `
    <div class="panel">
      <h2>Team channel <span class="hint">— private to ${esc(deptLabel(code))}, not visible outside the department</span></h2>
      ${pinned.length ? `<div style="display:flex;flex-direction:column;gap:10px;margin-bottom:10px;">${pinned.map(pinnedReminder).join('')}</div>` : ''}
      <div class="chat-thread" id="dept-chat-thread">${rows.length ? rows.map(bubble).join('') : '<div class="empty-msg">No messages yet - start the conversation below.</div>'}</div>
      <div class="field"><textarea id="dept-msg-text" dir="auto" rows="2" placeholder="Message the ${esc(deptLabel(code))} team..."></textarea></div>
      <div class="field"><label>Image <span class="hint">(optional)</span></label><input id="dept-msg-image" type="file" accept="image/*"></div>
      <div class="hint" id="dept-msg-error"></div>
      <div class="btn-row"><button class="btn" id="dept-msg-send">Send</button></div>
    </div>`;

  const thread = document.getElementById('dept-chat-thread');
  thread.scrollTop = thread.scrollHeight;

  document.getElementById('dept-msg-send').addEventListener('click', async () => {
    const errBox = document.getElementById('dept-msg-error');
    errBox.textContent = '';
    const body = document.getElementById('dept-msg-text').value.trim();
    const file = document.getElementById('dept-msg-image').files[0];
    if (!body && !file) { errBox.textContent = 'Write a message or attach an image.'; return; }
    let image_path = null;
    if (file) {
      const path = `${code}/${Date.now()}-${file.name}`.replace(/[^a-zA-Z0-9._/-]/g, '_');
      const { error } = await sb.storage.from(DEPARTMENT_MEDIA_BUCKET).upload(path, file, { upsert: true });
      if (error) { errBox.textContent = 'Could not upload the image: ' + error.message; return; }
      image_path = path;
    }
    await withStatus(sb.from('department_messages').insert({
      department_code: code, user_id: user.id, user_email: user.email, body: body || null, image_path,
    }), 'Sending...');
    await renderDeptChannel(box, code);
  });

  box.querySelectorAll('[data-edit-id]').forEach(el => el.addEventListener('click', () => {
    const id = el.dataset.editId;
    const r = rows.find(x => String(x.id) === id);
    const bubbleEl = box.querySelector(`[data-msg-id="${id}"]`);
    bubbleEl.querySelector('.dept-msg-body').outerHTML = `
      <textarea class="dept-msg-edit-input" dir="auto" rows="2" style="width:100%;">${esc(r.body || '')}</textarea>
      <div class="btn-row" style="margin-top:4px;">
        <button class="btn secondary" id="dept-edit-cancel" style="padding:3px 8px;">Cancel</button>
        <button class="btn" id="dept-edit-save" style="padding:3px 8px;">Save</button>
      </div>`;
    bubbleEl.querySelector('#dept-edit-cancel').addEventListener('click', () => renderDeptChannel(box, code));
    bubbleEl.querySelector('#dept-edit-save').addEventListener('click', async () => {
      const next = bubbleEl.querySelector('.dept-msg-edit-input').value.trim();
      if (!next && !r.image_path) { alert('A message cannot be empty.'); return; }
      await withStatus(sb.from('department_messages').update({ body: next || null }).eq('id', id), 'Saving...');
      await renderDeptChannel(box, code);
    });
  }));

  box.querySelectorAll('[data-delete-id]').forEach(el => el.addEventListener('click', async () => {
    if (!confirm('Delete this message? This cannot be undone.')) return;
    await withStatus(sb.from('department_messages').delete().eq('id', el.dataset.deleteId), 'Deleting...');
    await renderDeptChannel(box, code);
  }));

  box.querySelectorAll('[data-pin-id]').forEach(el => el.addEventListener('click', async () => {
    const pinned_next = el.dataset.pinNext === 'true';
    await withStatus(sb.from('department_messages').update({ pinned: pinned_next }).eq('id', el.dataset.pinId), 'Saving...');
    await renderDeptChannel(box, code);
  }));
}

// ---------- Live "new message" notifications, same pattern as chat.js's initChatNotifications
// (localStorage "seen" timestamp per department+user + a Supabase Realtime subscription + one
// shared toast). Kept here rather than in chat.js since only this module's data is involved, and
// modules never import each other (core.js star-import convention). ----------

function deptSeenKey(code, uid) { return `deptMsgSeenAt_${code}_${uid}`; }
function getDeptSeenAt(code, uid) { return localStorage.getItem(deptSeenKey(code, uid)) || '1970-01-01T00:00:00.000Z'; }
async function markDeptSeen(code) {
  const { data: { user } } = await sb.auth.getUser();
  if (user) localStorage.setItem(deptSeenKey(code, user.id), new Date().toISOString());
}

function showDeptMessageToast(deptCode, onView) {
  document.querySelectorAll('.toast-notification').forEach(t => t.remove());
  const toast = document.createElement('div');
  toast.className = 'toast-notification';
  toast.innerHTML = `
    <div class="toast-title">New team message</div>
    <div class="toast-body">A new message in the ${esc(deptLabel(deptCode))} channel.</div>
    <div class="btn-row" style="margin:8px 0 0;">
      <button class="btn" id="toast-view-btn" style="padding:4px 10px;">View</button>
      <button class="btn secondary" id="toast-close-btn" style="padding:4px 10px;">Dismiss</button>
    </div>`;
  document.body.appendChild(toast);
  document.getElementById('toast-close-btn').addEventListener('click', () => toast.remove());
  document.getElementById('toast-view-btn').addEventListener('click', () => { toast.remove(); onView(deptCode); });
}

let deptNotifyChannel = null;

// Called once per login (from app.js, after the dashboard is first shown), same convention as
// initChatNotifications/initTaskNotifications. navigateToMyDepartment(code) should switch to My
// Department with that department selected - passed in to avoid a circular import with app.js.
export async function initDeptMessageNotifications(navigateToMyDepartment) {
  if (deptNotifyChannel) { sb.removeChannel(deptNotifyChannel); deptNotifyChannel = null; }
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return;
  const codes = myDepartmentCodes();
  if (!codes.length) return;

  for (const code of codes) {
    const { data } = await sb.from('department_messages').select('id')
      .eq('department_code', code).neq('user_id', user.id).gt('created_at', getDeptSeenAt(code, user.id));
    if (data && data.length) { showDeptMessageToast(code, navigateToMyDepartment); break; } // one toast is enough at login
  }

  deptNotifyChannel = sb.channel('dept-messages-notify')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'department_messages' }, payload => {
      const row = payload.new;
      if (row.user_id === user.id || !codes.includes(row.department_code)) return;
      showDeptMessageToast(row.department_code, navigateToMyDepartment);
    })
    .subscribe();
}

// ---------- "Start Here" card editor (95_onboarding_and_share_with_us.sql) ----------
// Communication's own tool for the onboarding_cards Users see in "Start Here" (onboarding.js,
// read-only there). Built once real content needed to exist and writing rows by hand in Supabase
// wasn't a realistic ask for a non-technical content team - same bootstrapping gap help_pages had
// before the rest of Help existed, closed here the same way boards/formation editors already are:
// a plain popup form, not a generic admin grid.
const ONBOARDING_SECTIONS = [
  ['about', 'What is this?'],
  ['how_to_use', 'How to use it'],
  ['how_to_collaborate', 'How to collaborate'],
];
function onboardingSectionLabel(code) { const hit = ONBOARDING_SECTIONS.find(([c]) => c === code); return hit ? hit[1] : code; }
const onboardingThumbnailUrl = path => path ? sb.storage.from(ONBOARDING_MEDIA_BUCKET).getPublicUrl(path).data.publicUrl : null;

async function renderOnboardingCardsManager(box) {
  if (!box) return;
  const cards = await withStatus(sb.from('onboarding_cards').select('*').order('section').order('sort_order').order('created_at'));

  const row = c => `
    <tr class="${c.published ? '' : 'dismissed-row'}">
      <td>${esc(onboardingSectionLabel(c.section))}</td>
      <td>
        <div dir="auto" style="font-weight:600;">${esc(c.title_ur)}</div>
        ${c.title_en ? `<div class="hint">${esc(c.title_en)}</div>` : ''}
      </td>
      <td>${esc(c.media_type)}${c.media_type === 'video' && c.media_url ? ` &middot; ${esc(c.media_url)}` : ''}</td>
      <td>${c.sort_order}</td>
      <td>${c.published ? 'Yes' : '<span class="hint">no (draft)</span>'}</td>
      <td>
        <button class="btn secondary mydept-card-edit-btn" data-id="${c.id}" style="padding:4px 10px;">Edit</button>
        <button class="btn danger mydept-card-delete-btn" data-id="${c.id}" style="padding:4px 10px;">Delete</button>
      </td>
    </tr>`;

  box.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;">
        <h2>Start Here cards <span class="hint">&mdash; what Users see instead of Help</span></h2>
        <button class="btn" id="mydept-card-new">+ New card</button>
      </div>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Section</th><th>Title</th><th>Media</th><th>Order</th><th>Published</th><th></th></tr></thead>
        <tbody>${cards.length ? cards.map(row).join('') : '<tr><td colspan="6" class="hint">No cards yet - click "+ New card" to write the first one.</td></tr>'}</tbody>
      </table></div>
    </div>`;

  document.getElementById('mydept-card-new').addEventListener('click', () => openOnboardingCardPopup({ onSaved: () => renderOnboardingCardsManager(box) }));
  box.querySelectorAll('.mydept-card-edit-btn').forEach(btn => btn.addEventListener('click', () => {
    const card = cards.find(c => String(c.id) === btn.dataset.id);
    openOnboardingCardPopup({ card, onSaved: () => renderOnboardingCardsManager(box) });
  }));
  box.querySelectorAll('.mydept-card-delete-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Delete this card? This cannot be undone.')) return;
    await withStatus(sb.from('onboarding_cards').delete().eq('id', btn.dataset.id), 'Deleting...');
    renderOnboardingCardsManager(box);
  }));
}

function openOnboardingCardPopup({ card = null, onSaved } = {}) {
  document.getElementById('oc-card-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'oc-card-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${card ? 'Edit card' : 'New card'}</h2>
      <div class="field"><label>Section</label><select id="oc-section">${ONBOARDING_SECTIONS.map(([c, l]) => `<option value="${c}" ${card && card.section === c ? 'selected' : ''}>${l}</option>`).join('')}</select></div>
      <div class="field"><label>Title (Urdu)</label><input id="oc-title-ur" dir="auto" value="${esc(card ? card.title_ur : '')}"></div>
      <div class="field"><label>Title (English) <span class="hint">(optional)</span></label><input id="oc-title-en" value="${esc(card ? card.title_en : '')}"></div>
      <div class="field"><label>Text (Urdu) <span class="hint">(optional)</span></label><textarea id="oc-body-ur" dir="auto" rows="3">${esc(card ? card.body_ur : '')}</textarea></div>
      <div class="field"><label>Text (English) <span class="hint">(optional)</span></label><textarea id="oc-body-en" rows="3">${esc(card ? card.body_en : '')}</textarea></div>
      <div class="field"><label>Media type</label><select id="oc-media-type">
        <option value="text" ${!card || card.media_type === 'text' ? 'selected' : ''}>Text only</option>
        <option value="image" ${card && card.media_type === 'image' ? 'selected' : ''}>Image (upload below)</option>
        <option value="video" ${card && card.media_type === 'video' ? 'selected' : ''}>Video (link)</option>
      </select></div>
      <div class="field"><label>Link <span class="hint">(for "Video": a YouTube/Facebook/Instagram URL you already published. Leave empty otherwise - unless you were told to enter a special "tab:..." reference, e.g. for the Share with us tutorial card)</span></label><input id="oc-media-url" value="${esc(card ? card.media_url : '')}"></div>
      <div class="field">
        <label>Thumbnail <span class="hint">(optional cover image, shown on the card)</span></label>
        ${card && card.thumbnail_path ? `<div style="margin-bottom:6px;"><img src="${esc(onboardingThumbnailUrl(card.thumbnail_path))}" alt="" style="max-width:220px;border-radius:6px;display:block;"></div>` : ''}
        <input id="oc-thumbnail" type="file" accept="image/*">
      </div>
      <div class="field-grid">
        <div class="field"><label>Order <span class="hint">(lower shows first)</span></label><input id="oc-sort" type="number" value="${card ? card.sort_order : 0}"></div>
        <div class="field"><label style="text-transform:none;font-size:13px;"><input id="oc-published" type="checkbox" style="width:auto;" ${!card || card.published ? 'checked' : ''}> Published (visible to Users)</label></div>
      </div>
      <div class="hint" id="oc-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="oc-cancel">Cancel</button>
        <button class="btn" id="oc-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('oc-cancel').addEventListener('click', () => backdrop.remove());

  document.getElementById('oc-save').addEventListener('click', async () => {
    const errBox = document.getElementById('oc-error');
    errBox.textContent = '';
    const title_ur = document.getElementById('oc-title-ur').value.trim();
    if (!title_ur) { errBox.textContent = 'Title (Urdu) is required.'; return; }
    const media_type = document.getElementById('oc-media-type').value;
    const media_url = document.getElementById('oc-media-url').value.trim();
    if (media_type === 'video' && !media_url) { errBox.textContent = 'A video card needs a link.'; return; }

    let thumbnail_path = card ? card.thumbnail_path : null;
    const file = document.getElementById('oc-thumbnail').files[0];
    if (file) {
      const objectPath = `${Date.now()}-${file.name}`.replace(/[^a-zA-Z0-9._-]/g, '_');
      const { error } = await sb.storage.from(ONBOARDING_MEDIA_BUCKET).upload(objectPath, file, { upsert: true });
      if (error) { errBox.textContent = 'Could not upload the thumbnail: ' + error.message; return; }
      thumbnail_path = objectPath;
    }

    const { data: { user } } = await sb.auth.getUser();
    const row = {
      section: document.getElementById('oc-section').value,
      title_ur,
      title_en: document.getElementById('oc-title-en').value.trim() || null,
      body_ur: document.getElementById('oc-body-ur').value.trim() || null,
      body_en: document.getElementById('oc-body-en').value.trim() || null,
      media_type,
      media_url: media_url || null,
      thumbnail_path,
      sort_order: parseInt(document.getElementById('oc-sort').value, 10) || 0,
      published: document.getElementById('oc-published').checked,
      created_by_email: user.email,
      updated_at: new Date().toISOString(),
    };
    if (card) await withStatus(sb.from('onboarding_cards').update(row).eq('id', card.id), 'Saving...');
    else await withStatus(sb.from('onboarding_cards').insert(row), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}
