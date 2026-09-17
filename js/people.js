// People (Phase 2a, PROJECT_HANDOFF_v23.md §3.2): HR's consolidated view of every team member
// (GOVERNANCE.md §6.2), backed by the single hr_people_overview() RPC (80_departments_and_
// people_decisions.sql), plus the propose/decide workflow for the decisions in that migration's
// people_decisions table. Visible to HR members, any department lead, or Admin - see app.js's
// tab gate; hr_people_overview() itself returns no rows to anyone else, so this is belt and
// braces, not the real gate.

import {
  sb, State, esc, withStatus, isAdmin, isDeptMember, isDeptLead, labelOf, optionsHtml,
} from './core.js?v=20260918000637';
import { renderPolicySection } from './policy.js?v=20260918000637';

const STANDING_BADGE = {
  active: '',
  watch: '<span class="hint" style="color:#b8860b;">watch</span>',
  suspended: '<span class="hint" style="color:var(--danger);">suspended</span>',
};

const ROLE_OPTIONS = [['user', 'User'], ['operator', 'Operator'], ['coordinator', 'Coordinator'], ['admin', 'Admin']];

// Mirrors can_propose_people_decision() server-side, only to decide what to show in the
// "Propose..." menu - the RPC itself is the real gate and will reject anything this gets wrong.
function canProposeTypeClientSide(type) {
  if (isAdmin()) return true;
  if (type === 'qualification_add' || type === 'qualification_remove') return isDeptMember('HR');
  if (['watch_on', 'watch_off', 'suspend', 'reinstate', 'exclude'].includes(type)) return isDeptMember('HR');
  if (type === 'role_change') return isDeptLead('HR');
  if (['board_misuse', 'board_block', 'board_unblock'].includes(type)) return State.currentRole === 'coordinator' || State.myBoards.size > 0;
  return false;
}

// Mirrors can_approve_people_decision() server-side, same caveat as above.
function canApproveTypeClientSide(type) {
  if (isAdmin()) return true;
  if (type === 'suspend' || type === 'reinstate') return isDeptLead('HR');
  if (['board_misuse', 'board_block', 'board_unblock'].includes(type)) return isDeptLead('FORM') || isDeptLead('HR');
  return false;
}

// Tracks whichever container last rendered the roster (People tab or My Department's embedded
// section), so a successful propose can refresh that same section in place instead of assuming
// it's always the standalone People tab.
let currentRosterContainer = null;

let decisionTypes = null; // [[code,label]] from option_lists, loaded once per People tab visit
async function loadDecisionTypes() {
  if (decisionTypes) return decisionTypes;
  const rows = await withStatus(sb.from('option_lists').select('code,label').eq('list_name', 'people_decision_type').order('sort_order'));
  decisionTypes = rows.map(r => [r.code, r.label]);
  return decisionTypes;
}

export async function renderPeopleView(main) {
  main.innerHTML = '<div class="panel"><h2>People</h2><div class="empty-msg">Loading...</div></div>';
  await loadDecisionTypes();

  main.innerHTML = `
    <div id="people-section-box"></div>
    <div class="panel">
      <h2>Pending decisions</h2>
      <div id="people-pending-box"><div class="hint">Loading...</div></div>
    </div>
    <div id="policy-section-box"></div>`;

  await renderPeopleSection(document.getElementById('people-section-box'));
  renderPendingDecisions(main);
  renderPolicySection(document.getElementById('policy-section-box'));
}

// The roster grid (search/standing/at-risk/department/role/qualification filters, sortable
// Name/Credits/Reputation/Since, Propose.../History per row) as a self-contained section -
// reusable wherever it's useful, not just the People tab: mydepartment.js embeds it in HR's
// "My Department" page too (2026-09-17, owner's request), instead of duplicating the grid.
export async function renderPeopleSection(container) {
  currentRosterContainer = container; // see openProposePopup's refresh-after-save below
  container.innerHTML = '<div class="panel"><h2>People</h2><div class="empty-msg">Loading...</div></div>';
  await loadDecisionTypes();
  const rows = await withStatus(sb.rpc('hr_people_overview'));
  const deptOptions = State.optionListsByName.department || [];
  const qualOptions = State.optionListsByName.operator_qualification || [];

  container.innerHTML = `
    <div class="panel">
      <h2>People <span class="count-badge">${rows.length}</span> <span class="hint">— GOVERNANCE.md §6.2</span></h2>
      <div class="field-grid">
        <div class="field"><label>Search</label><input id="people-search" placeholder="Name or email..." value="${esc(State.peopleFilter.search)}"></div>
        <div class="field"><label>Standing</label>
          <select id="people-standing-filter">
            <option value="">All</option>
            <option value="active" ${State.peopleFilter.standing === 'active' ? 'selected' : ''}>Active</option>
            <option value="watch" ${State.peopleFilter.standing === 'watch' ? 'selected' : ''}>Watch</option>
            <option value="suspended" ${State.peopleFilter.standing === 'suspended' ? 'selected' : ''}>Suspended</option>
          </select>
        </div>
        <div class="field"><label>Department</label>
          <select id="people-department-filter"><option value="">All</option>${deptOptions.map(([c, l]) => `<option value="${esc(c)}" ${State.peopleFilter.department === c ? 'selected' : ''}>${esc(l)}</option>`).join('')}</select>
        </div>
        <div class="field"><label>Role</label>
          <select id="people-role-filter"><option value="">All</option>${ROLE_OPTIONS.map(([c, l]) => `<option value="${esc(c)}" ${State.peopleFilter.role === c ? 'selected' : ''}>${esc(l)}</option>`).join('')}</select>
        </div>
        <div class="field"><label>Qualification</label>
          <select id="people-qualification-filter"><option value="">All</option>${qualOptions.map(([c, l]) => `<option value="${esc(c)}" ${State.peopleFilter.qualification === c ? 'selected' : ''}>${esc(l)}</option>`).join('')}</select>
        </div>
        <div class="field"><label>&nbsp;</label>
          <label style="display:flex;align-items:center;gap:6px;font-weight:normal;text-transform:none;">
            <input type="checkbox" id="people-atrisk-filter" ${State.peopleFilter.atRiskOnly ? 'checked' : ''}> At risk only
          </label>
        </div>
      </div>
      <div id="people-grid-box"></div>
    </div>`;

  document.getElementById('people-search').addEventListener('input', e => { State.peopleFilter.search = e.target.value; renderPeopleGrid(rows); });
  document.getElementById('people-standing-filter').addEventListener('change', e => { State.peopleFilter.standing = e.target.value; renderPeopleGrid(rows); });
  document.getElementById('people-department-filter').addEventListener('change', e => { State.peopleFilter.department = e.target.value; renderPeopleGrid(rows); });
  document.getElementById('people-role-filter').addEventListener('change', e => { State.peopleFilter.role = e.target.value; renderPeopleGrid(rows); });
  document.getElementById('people-qualification-filter').addEventListener('change', e => { State.peopleFilter.qualification = e.target.value; renderPeopleGrid(rows); });
  document.getElementById('people-atrisk-filter').addEventListener('change', e => { State.peopleFilter.atRiskOnly = e.target.checked; renderPeopleGrid(rows); });

  renderPeopleGrid(rows);
}

// department_code/qualification_code tokens in a comma-joined "CODE (lead)?, CODE, ..." string
// (see hr_people_overview()'s string_agg columns) - split and match exactly, not a substring
// search, so e.g. filtering "HR" never matches a hypothetical "HRX" department.
function hasToken(joined, code) {
  return (joined || '').split(',').some(seg => seg.trim().replace(/\s*\(lead\)$/, '') === code);
}

function renderPeopleGrid(allRows) {
  const box = document.getElementById('people-grid-box');
  if (!box) return;
  const f = State.peopleFilter;
  const q = f.search.trim().toLowerCase();
  let rows = allRows.filter(r =>
    (!q || (r.full_name || '').toLowerCase().includes(q) || (r.email || '').toLowerCase().includes(q)) &&
    (!f.standing || r.standing === f.standing) &&
    (!f.department || hasToken(r.departments, f.department)) &&
    (!f.role || r.role === f.role) &&
    (!f.qualification || hasToken(r.qualifications, f.qualification)) &&
    (!f.atRiskOnly || r.at_risk));

  const sortCol = State.peopleSort.col;
  const dir = State.peopleSort.asc ? 1 : -1;
  rows = [...rows].sort((a, b) => {
    const av = sortCol === 'full_name' ? (a.full_name || '').toLowerCase() : (a[sortCol] ?? '');
    const bv = sortCol === 'full_name' ? (b.full_name || '').toLowerCase() : (b[sortCol] ?? '');
    return av < bv ? -dir : av > bv ? dir : 0;
  });
  const arrow = col => col !== sortCol ? '' : (State.peopleSort.asc ? ' &uarr;' : ' &darr;');
  const sortHeader = (col, label) => `<th data-sort="${col}" style="cursor:pointer;">${label}${arrow(col)}</th>`;

  box.innerHTML = `
    <div class="grid-wrap"><table class="grid" id="people-grid">
      <thead><tr>
        ${sortHeader('full_name', 'Name')}<th>Email</th><th>Role</th><th>Departments</th><th>Standing</th>
        ${sortHeader('credits', 'Credits')}${sortHeader('reputation', 'Reputation')}<th>Qualifications</th>
        ${sortHeader('since', 'Since')}<th>Last event</th><th>Negative events</th><th>Open tasks</th><th>Pending</th><th>At risk</th><th></th>
      </tr></thead>
      <tbody>${rows.map(r => `<tr data-uid="${esc(r.user_id)}">
        <td>${esc(r.full_name) || '<span class="hint">—</span>'}</td>
        <td>${esc(r.email)}</td>
        <td>${esc(r.role)}</td>
        <td style="white-space:normal;">${esc(r.departments) || '<span class="hint">—</span>'}</td>
        <td>${STANDING_BADGE[r.standing] ?? esc(r.standing)}</td>
        <td>${esc(r.credits ?? '—')}</td>
        <td>${esc(r.reputation ?? '—')}</td>
        <td style="white-space:normal;">${esc(r.qualifications) || '<span class="hint">—</span>'}</td>
        <td>${esc((r.since || '').slice(0, 10))}</td>
        <td>${esc(r.last_event_type) || '<span class="hint">—</span>'}</td>
        <td>${esc(r.negative_events)}</td>
        <td>${esc(r.open_tasks)}</td>
        <td>${esc(r.pending_decisions)}</td>
        <td>${r.at_risk ? '<span style="color:var(--danger);font-weight:600;">at risk</span>' : ''}</td>
        <td>
          <button class="btn secondary people-propose-btn" style="padding:4px 10px;">Propose…</button>
          <button class="btn secondary people-history-btn" style="padding:4px 10px;">History</button>
        </td>
      </tr>
      <tr class="people-history-row" data-history-for="${esc(r.user_id)}" style="display:none;"><td colspan="15"></td></tr>`).join('') || ''}</tbody>
    </table></div>
    ${!rows.length ? '<div class="empty-msg">No one matches this filter.</div>' : ''}`;

  box.querySelectorAll('#people-grid th[data-sort]').forEach(th => th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (State.peopleSort.col === col) State.peopleSort.asc = !State.peopleSort.asc; else State.peopleSort = { col, asc: true };
    renderPeopleGrid(allRows);
  }));
  box.querySelectorAll('.people-propose-btn').forEach(btn => btn.addEventListener('click', () => {
    const uid = btn.closest('tr').dataset.uid;
    const row = allRows.find(r => r.user_id === uid);
    openProposePopup(row, allRows);
  }));
  box.querySelectorAll('.people-history-btn').forEach(btn => btn.addEventListener('click', () => {
    const uid = btn.closest('tr').dataset.uid;
    toggleHistoryRow(uid);
  }));
}

async function toggleHistoryRow(uid) {
  const row = document.querySelector(`tr.people-history-row[data-history-for="${uid}"]`);
  if (!row) return;
  const cell = row.querySelector('td');
  if (row.style.display !== 'none') { row.style.display = 'none'; return; }
  row.style.display = '';
  cell.innerHTML = '<div class="hint">Loading...</div>';
  const decisions = await withStatus(sb.from('people_decisions').select('*').eq('subject_user_id', uid).order('proposed_at', { ascending: false }));
  const types = await loadDecisionTypes();
  cell.innerHTML = decisions.length ? `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Type</th><th>Reason</th><th>Proposed by</th><th>Status</th><th>Decided by</th><th>Note</th></tr></thead>
      <tbody>${decisions.map(d => `<tr>
        <td>${esc(labelOf(types, d.decision_type))}</td>
        <td style="white-space:normal;">${esc(d.reason)}</td>
        <td>${esc(d.proposed_by_email)} &middot; ${esc((d.proposed_at || '').slice(0, 10))}</td>
        <td>${esc(d.status)}</td>
        <td>${esc(d.decided_by_email) || '<span class="hint">—</span>'}</td>
        <td style="white-space:normal;">${esc(d.decision_note) || ''}</td>
      </tr>`).join('')}</tbody>
    </table></div>` : '<div class="hint">No decisions recorded about this person yet.</div>';
}

// ---------- Propose a decision ----------

function openProposePopup(row, allRows) {
  const myQualCodes = new Set((row.qualifications || '').split(',').map(s => s.trim()).filter(Boolean));
  const allQuals = State.optionListsByName.operator_qualification || [];
  const types = decisionTypes.filter(([code]) => canProposeTypeClientSide(code));

  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Propose a decision <span class="hint">— ${esc(row.full_name) || esc(row.email)}</span></h2>
      ${types.length ? `
        <div class="field"><label>Decision type</label><select id="pp-type">${optionsHtml(types, types[0]?.[0], false)}</select></div>
        <div id="pp-payload"></div>
        <div class="field"><label>Reason</label><textarea id="pp-reason" rows="3"></textarea></div>
        <div class="hint" id="pp-error"></div>
        <div class="btn-row" style="justify-content:flex-end;">
          <button class="btn secondary" id="pp-cancel">Cancel</button>
          <button class="btn" id="pp-save">Propose</button>
        </div>` : '<div class="empty-msg">You are not able to propose any decision type for this person.</div><div class="btn-row" style="justify-content:flex-end;"><button class="btn secondary" id="pp-cancel">Close</button></div>'}
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('pp-cancel').addEventListener('click', () => backdrop.remove());
  if (!types.length) return;

  const typeSel = document.getElementById('pp-type');
  const payloadBox = document.getElementById('pp-payload');
  function renderPayloadField() {
    const type = typeSel.value;
    if (type === 'qualification_add') {
      const options = allQuals.filter(([code]) => !myQualCodes.has(code));
      payloadBox.innerHTML = options.length
        ? `<div class="field"><label>Qualification</label><select id="pp-qual">${optionsHtml(options, options[0][0], false)}</select></div>`
        : '<div class="hint">This person already has every defined qualification.</div>';
    } else if (type === 'qualification_remove') {
      const options = allQuals.filter(([code]) => myQualCodes.has(code));
      payloadBox.innerHTML = options.length
        ? `<div class="field"><label>Qualification</label><select id="pp-qual">${optionsHtml(options, options[0][0], false)}</select></div>`
        : '<div class="hint">This person has no qualifications to remove.</div>';
    } else if (type === 'role_change') {
      payloadBox.innerHTML = `<div class="field"><label>New role</label><select id="pp-role">${optionsHtml(ROLE_OPTIONS, row.role, false)}</select></div>`;
    } else {
      payloadBox.innerHTML = '';
    }
  }
  typeSel.addEventListener('change', renderPayloadField);
  renderPayloadField();

  document.getElementById('pp-save').addEventListener('click', async () => {
    const type = typeSel.value;
    const reason = document.getElementById('pp-reason').value.trim();
    const errBox = document.getElementById('pp-error');
    errBox.textContent = '';
    if (!reason) { errBox.textContent = 'A reason is required.'; return; }
    let payload = null;
    if (type === 'qualification_add' || type === 'qualification_remove') {
      const qualSel = document.getElementById('pp-qual');
      if (!qualSel) { errBox.textContent = 'No qualification available for this action.'; return; }
      payload = { qualification_code: qualSel.value };
    } else if (type === 'role_change') {
      payload = { role: document.getElementById('pp-role').value };
    }
    const { error } = await sb.rpc('propose_people_decision', { p_subject: row.user_id, p_type: type, p_reason: reason, p_payload: payload });
    if (error) { errBox.textContent = error.message; return; }
    backdrop.remove();
    if (currentRosterContainer) await renderPeopleSection(currentRosterContainer);
  });
}

// ---------- Pending decisions ----------

async function renderPendingDecisions(main) {
  const box = document.getElementById('people-pending-box');
  if (!box) return;
  const rows = await withStatus(sb.from('people_decisions').select('*').eq('status', 'pending').order('proposed_at', { ascending: true }));
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing pending.</div>'; return; }
  const types = await loadDecisionTypes();
  const { data: { user } } = await sb.auth.getUser();
  const myEmail = user.email;

  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Subject</th><th>Type</th><th>Reason</th><th>Proposed by</th><th>Date</th><th></th></tr></thead>
      <tbody>${rows.map(r => `<tr data-id="${r.id}">
        <td>${esc(r.subject_email)}</td>
        <td>${esc(labelOf(types, r.decision_type))}</td>
        <td style="white-space:normal;">${esc(r.reason)}</td>
        <td>${esc(r.proposed_by_email)}</td>
        <td>${esc((r.proposed_at || '').slice(0, 10))}</td>
        <td>
          ${r.proposed_by_email === myEmail
            ? '<button class="btn secondary pd-withdraw-btn" style="padding:4px 10px;">Withdraw</button>'
            : (canApproveTypeClientSide(r.decision_type)
              ? '<button class="btn pd-approve-btn" style="padding:4px 10px;">Approve</button><button class="btn danger pd-reject-btn" style="padding:4px 10px;">Reject</button>'
              : '<span class="hint">Awaiting an approver</span>')}
        </td>
      </tr>`).join('')}</tbody>
    </table></div>`;

  box.querySelectorAll('.pd-withdraw-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Withdraw this proposal?')) return;
    const { error } = await sb.rpc('decide_people_decision', { p_id: parseInt(btn.closest('tr').dataset.id, 10), p_outcome: 'withdrawn' });
    if (error) { alert(error.message); return; }
    await renderPendingDecisions(main);
  }));
  box.querySelectorAll('.pd-approve-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Approve this decision?')) return;
    const { error } = await sb.rpc('decide_people_decision', { p_id: parseInt(btn.closest('tr').dataset.id, 10), p_outcome: 'approved' });
    if (error) { alert(error.message); return; }
    await renderPendingDecisions(main);
  }));
  box.querySelectorAll('.pd-reject-btn').forEach(btn => btn.addEventListener('click', async () => {
    const note = prompt('A note is required when rejecting - it will be visible to the proposer:');
    if (note == null) return;
    if (!note.trim()) { alert('A note is required when rejecting.'); return; }
    const { error } = await sb.rpc('decide_people_decision', { p_id: parseInt(btn.closest('tr').dataset.id, 10), p_outcome: 'rejected', p_note: note.trim() });
    if (error) { alert(error.message); return; }
    await renderPendingDecisions(main);
  }));
}
