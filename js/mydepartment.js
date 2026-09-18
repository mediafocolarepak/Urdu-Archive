// "My Department" (migration 87, GOVERNANCE.md §2.7/§2.8): a single screen for a department
// lead (or Admin) to keep an eye on their own team and policy without hunting across tabs.
// Department list is fully data-driven from option_lists ('department') and department_members
// - departments can be added, renamed or retired from Options without touching this file.

import { sb, State, esc, today, withStatus, isAdmin, isDeptLead, likeSafe } from './core.js?v=20260918154150';
import { renderPolicySection } from './policy.js?v=20260918154150';
import { renderPeopleSection } from './people.js?v=20260918154150';
import { renderApplicationsView } from './collaboration.js?v=20260918154150';

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
    ${selected === 'HR' ? '<div id="mydept-applications-box"></div>' : ''}
    ${selected === 'HR' ? '<div id="mydept-people-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-credits-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-compensation-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-anomalies-box"></div>' : ''}
    ${selected === 'COORD' ? '<div id="mydept-tasks-box"></div>' : ''}
    ${selected === 'FORM' ? '<div id="mydept-formation-box"></div>' : ''}
    <div id="mydept-policy-box"></div>`;

  if (codes.length > 1) {
    document.getElementById('mydept-select').addEventListener('change', e => {
      State.myDeptSelected = e.target.value;
      renderMyDepartmentView(main);
    });
  }

  await renderRoster(selected);
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
