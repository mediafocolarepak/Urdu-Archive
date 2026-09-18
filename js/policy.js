// Policy revision framework (GOVERNANCE.md §2.8/§6.6, migration 86): task_category_rates,
// task_reputation_tiers and policy_values are read-only everywhere in the app except through
// this module's propose/decide flow - propose_policy_change()/decide_policy_change() are the
// real gate (RLS on the three tables no longer allows direct writes at all), this module is
// only the UI for reaching them. Used from people.js (the "Policy" section, same audience as
// People: any department lead or Admin) and from admin.js (per-row "Propose..." buttons that
// replace the old direct-edit inputs on the reputation-tiers/policy-values/task-category panels).

import { sb, State, esc, withStatus, canProposePolicyChange, canApprovePolicyChange } from './core.js?v=20260918193251';

// Who may propose a change to each policy_values key (GOVERNANCE.md §2.8 "who owns which
// policy table"). task_category_rates and task_reputation_tiers are Reward's alone.
const POLICY_VALUE_OWNERS = {
  extra_credit_pct_threshold: ['RF'],
  extra_credit_abs_threshold: ['RF'],
  risk_reputation_below: ['HR', 'RF'],
  risk_negative_events: ['HR', 'RF'],
  risk_window_days: ['HR', 'RF'],
  board_misuse_reputation_delta: ['FORM', 'HR'],
  task_near_due_days: ['COORD'],
};

export function ownersFor(targetTable, targetKey) {
  if (targetTable === 'policy_values') return POLICY_VALUE_OWNERS[targetKey] || ['RF'];
  return ['RF'];
}

function deptLabel(code) {
  const depts = State.optionListsByName.department || [];
  const hit = depts.find(([c]) => c === code);
  return hit ? hit[1] : code;
}

// Generic "propose a policy change" modal. `fields` is either an array of
// {name, label, type: 'text'|'number', value, placeholder?} rendered as inputs whose values
// become field_changes (for action = 'upsert'), or null (action = 'delete' - only the reason is
// asked). `owners` is the list of department codes allowed to propose this change; if more than
// one, a select lets the proposer pick which department they propose as.
export function openPolicyProposalModal({ title, targetTable, targetKey, action, owners, fields, onSaved }) {
  const proposable = owners.filter(d => canProposePolicyChange(d));
  if (!proposable.length) { alert('You are not a lead of the department that owns this policy.'); return; }

  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2>${esc(title)}</h2>
      <p class="hint">This becomes operative only after an Admin who is not you approves it (GOVERNANCE.md §2.8). It stays visible in the pending queue and, either way, in this department's policy history.</p>
      ${proposable.length > 1 ? `<div class="field"><label>Propose as</label>
        <select id="polprop-department">${proposable.map(d => `<option value="${esc(d)}">${esc(deptLabel(d))}</option>`).join('')}</select>
      </div>` : `<input type="hidden" id="polprop-department" value="${esc(proposable[0])}">`}
      ${action === 'delete'
        ? '<p class="hint">This proposes removing this row entirely.</p>'
        : (fields || []).map(f => `<div class="field"><label>${esc(f.label)}</label>
            <input id="polprop-field-${esc(f.name)}" type="${f.type === 'number' ? 'number' : 'text'}" value="${f.value == null ? '' : esc(f.value)}" placeholder="${esc(f.placeholder || '')}"></div>`).join('')}
      <div class="field"><label>Reason <span class="hint">(required)</span></label>
        <textarea id="polprop-reason" rows="3" placeholder="Why this change?"></textarea></div>
      <div id="polprop-error" class="hint" style="color:var(--danger);"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="polprop-cancel">Cancel</button>
        <button class="btn" id="polprop-save">Submit proposal</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('polprop-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('polprop-save').addEventListener('click', async () => {
    const department = document.getElementById('polprop-department').value;
    const reason = document.getElementById('polprop-reason').value.trim();
    const errBox = document.getElementById('polprop-error');
    errBox.textContent = '';
    if (!reason) { errBox.textContent = 'A reason is required.'; return; }
    const field_changes = {};
    if (action !== 'delete') {
      for (const f of (fields || [])) {
        const raw = document.getElementById(`polprop-field-${f.name}`).value.trim();
        if (f.type === 'number') {
          field_changes[f.name] = raw === '' ? null : Number(raw);
        } else {
          field_changes[f.name] = raw === '' ? null : raw;
        }
      }
    }
    const { error } = await sb.rpc('propose_policy_change', {
      p_department: department, p_target_table: targetTable, p_target_key: targetKey,
      p_action: action, p_field_changes: field_changes, p_reason: reason,
    });
    if (error) { errBox.textContent = error.message; return; }
    backdrop.remove();
    if (onSaved) await onSaved();
  });
}

// ---------- The "Policy" section: read-only current values, pending queue, history ----------

export async function renderPolicySection(container, { departmentFilter } = {}) {
  container.innerHTML = '<div class="hint">Loading...</div>';
  const [rates, tiers, values, proposalsRaw] = await Promise.all([
    withStatus(sb.from('task_category_rates').select('*').order('category')),
    withStatus(sb.from('task_reputation_tiers').select('*').order('sort_order')),
    withStatus(sb.from('policy_values').select('*').order('key')),
    withStatus(sb.from('policy_proposals').select('*').order('proposed_at', { ascending: false })),
  ]);
  const proposals = departmentFilter ? proposalsRaw.filter(p => p.department_code === departmentFilter) : proposalsRaw;
  const pending = proposals.filter(p => p.status === 'pending');
  const history = proposals.filter(p => p.status !== 'pending');
  const { data: { user } } = await sb.auth.getUser();
  const myEmail = user.email;
  const depts = State.optionListsByName.department || [];
  const canProposeAny = owners => owners.some(d => canProposePolicyChange(d));
  // In a department-scoped view (My Department), a table/row is shown only if this department
  // is one of its owners - otherwise it isn't this department's business, keep the view short.
  const owns = owners => !departmentFilter || owners.includes(departmentFilter);

  const ratesPanel = owns(ownersFor('task_category_rates')) ? `
    <div class="panel">
      <h2>Task category rates <span class="hint">— credits per page, owned by Reward (GOVERNANCE.md §2.4)</span></h2>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Category</th><th>Credits/page</th><th>Last updated by</th><th></th></tr></thead>
        <tbody>${rates.map(r => `<tr>
          <td>${esc(r.category)}</td><td>${esc(r.credits_per_page)}</td><td>${esc(r.updated_by_email || '')}</td>
          <td>${canProposeAny(ownersFor('task_category_rates'))
            ? `<button class="btn secondary pp-propose-rate" style="padding:4px 10px;" data-category="${esc(r.category)}" data-rate="${esc(r.credits_per_page)}">Propose change</button>`
            : `<span class="hint">Owned by ${ownersFor('task_category_rates').map(deptLabel).join(' / ')}</span>`}</td>
        </tr>`).join('')}</tbody>
      </table></div>
    </div>` : '';
  const tiersPanel = owns(ownersFor('task_reputation_tiers')) ? `
    <div class="panel">
      <h2>Task reputation tiers <span class="hint">— owned by Reward</span></h2>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Tier</th><th>Min</th><th>Max</th><th>OK</th><th>OK, but...</th><th>Fail</th><th>Sort</th><th></th></tr></thead>
        <tbody>${tiers.map(t => `<tr>
          <td>${esc(t.tier_name)}</td><td>${esc(t.min_base_credits)}</td><td>${t.max_base_credits ?? '(none)'}</td>
          <td>${esc(t.ok_delta)}</td><td>${esc(t.ok_but_delta)}</td><td>${esc(t.fail_delta)}</td><td>${esc(t.sort_order)}</td>
          <td>${canProposeAny(ownersFor('task_reputation_tiers'))
            ? `<button class="btn secondary pp-propose-tier" style="padding:4px 10px;" data-tier='${esc(JSON.stringify(t))}'>Propose change</button>`
            : `<span class="hint">Owned by ${ownersFor('task_reputation_tiers').map(deptLabel).join(' / ')}</span>`}</td>
        </tr>`).join('')}</tbody>
      </table></div>
    </div>` : '';
  const valueRows = values.filter(v => owns(ownersFor('policy_values', v.key)));
  const valuesPanel = valueRows.length ? `
    <div class="panel">
      <h2>Policy values <span class="hint">— thresholds, ownership varies by key (GOVERNANCE.md §2.8)</span></h2>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Key</th><th>Meaning</th><th>Value</th><th></th></tr></thead>
        <tbody>${valueRows.map(v => `<tr>
          <td><code>${esc(v.key)}</code></td><td style="white-space:normal;">${esc(v.label)}</td><td>${esc(v.value)}</td>
          <td>${canProposeAny(ownersFor('policy_values', v.key))
            ? `<button class="btn secondary pp-propose-value" style="padding:4px 10px;" data-key="${esc(v.key)}" data-value="${esc(v.value)}">Propose change</button>`
            : `<span class="hint">Owned by ${ownersFor('policy_values', v.key).map(deptLabel).join(' / ')}</span>`}</td>
        </tr>`).join('')}</tbody>
      </table></div>` : '';
  const historyPanel = departmentFilter ? `
    <div class="panel">
      <h2>Policy history <span class="hint">— every proposal for this department, kept forever</span></h2>
      <div id="policy-history-box"></div>
    </div>` : `
    <div class="panel">
      <h2>Policy history <span class="hint">— every proposal, per department, kept forever</span></h2>
      <div class="field" style="max-width:280px;"><label>Department</label>
        <select id="policy-history-dept"><option value="">All</option>${depts.map(([c, l]) => `<option value="${esc(c)}">${esc(l)}</option>`).join('')}</select>
      </div>
      <div id="policy-history-box"></div>
    </div>`;

  container.innerHTML = `
    ${ratesPanel}${tiersPanel}${valuesPanel}
    ${!ratesPanel && !tiersPanel && !valuesPanel ? '<div class="panel"><p class="empty-msg">This department does not own any policy table yet.</p></div>' : ''}
    <div class="panel">
      <h2>Pending policy proposals</h2>
      <div id="policy-pending-box"></div>
    </div>
    ${historyPanel}`;

  container.querySelectorAll('.pp-propose-rate').forEach(btn => btn.addEventListener('click', () => {
    openPolicyProposalModal({
      title: `Propose a rate change — ${btn.dataset.category}`,
      targetTable: 'task_category_rates', targetKey: btn.dataset.category, action: 'upsert',
      owners: ownersFor('task_category_rates'),
      fields: [{ name: 'credits_per_page', label: 'Credits per page', type: 'number', value: btn.dataset.rate }],
      onSaved: () => renderPolicySection(container, { departmentFilter }),
    });
  }));
  container.querySelectorAll('.pp-propose-tier').forEach(btn => btn.addEventListener('click', () => {
    const t = JSON.parse(btn.dataset.tier);
    openPolicyProposalModal({
      title: `Propose a reputation tier change — ${t.tier_name}`,
      targetTable: 'task_reputation_tiers', targetKey: t.tier_name, action: 'upsert',
      owners: ownersFor('task_reputation_tiers'),
      fields: [
        { name: 'tier_name', label: 'Tier name', type: 'text', value: t.tier_name },
        { name: 'min_base_credits', label: 'Min base credits', type: 'number', value: t.min_base_credits },
        { name: 'max_base_credits', label: 'Max base credits (empty = none)', type: 'number', value: t.max_base_credits },
        { name: 'ok_delta', label: 'OK delta', type: 'number', value: t.ok_delta },
        { name: 'ok_but_delta', label: 'OK, but... delta', type: 'number', value: t.ok_but_delta },
        { name: 'fail_delta', label: 'Fail delta', type: 'number', value: t.fail_delta },
        { name: 'sort_order', label: 'Sort order', type: 'number', value: t.sort_order },
      ],
      onSaved: () => renderPolicySection(container, { departmentFilter }),
    });
  }));
  container.querySelectorAll('.pp-propose-value').forEach(btn => btn.addEventListener('click', () => {
    openPolicyProposalModal({
      title: `Propose a value change — ${btn.dataset.key}`,
      targetTable: 'policy_values', targetKey: btn.dataset.key, action: 'upsert',
      owners: ownersFor('policy_values', btn.dataset.key),
      fields: [{ name: 'value', label: 'Value', type: 'number', value: btn.dataset.value }],
      onSaved: () => renderPolicySection(container, { departmentFilter }),
    });
  }));

  renderPendingQueue(pending, myEmail, container, departmentFilter);
  wireHistory(history, container, departmentFilter);
}

function fieldChangesSummary(p) {
  if (p.action === 'delete') return '(remove row)';
  return Object.entries(p.field_changes || {}).map(([k, v]) => `${k}: ${v}`).join(', ');
}

function renderPendingQueue(pending, myEmail, container, departmentFilter) {
  const box = document.getElementById('policy-pending-box');
  if (!box) return;
  if (!pending.length) { box.innerHTML = '<div class="empty-msg">Nothing pending.</div>'; return; }
  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Department</th><th>Table</th><th>Key</th><th>Change</th><th>Reason</th><th>Proposed by</th><th>Date</th><th></th></tr></thead>
      <tbody>${pending.map(p => `<tr data-id="${p.id}">
        <td>${esc(deptLabel(p.department_code))}</td>
        <td>${esc(p.target_table)}</td>
        <td>${esc(p.target_key)}</td>
        <td style="white-space:normal;">${esc(fieldChangesSummary(p))}</td>
        <td style="white-space:normal;">${esc(p.reason)}</td>
        <td>${esc(p.proposed_by_email)}</td>
        <td>${esc((p.proposed_at || '').slice(0, 10))}</td>
        <td>
          ${p.proposed_by_email === myEmail
            ? '<button class="btn secondary pp-withdraw-btn" style="padding:4px 10px;">Withdraw</button>'
            : (canApprovePolicyChange()
              ? '<button class="btn pp-approve-btn" style="padding:4px 10px;">Approve</button><button class="btn danger pp-reject-btn" style="padding:4px 10px;">Reject</button>'
              : '<span class="hint">Awaiting Admin</span>')}
        </td>
      </tr>`).join('')}</tbody>
    </table></div>`;

  box.querySelectorAll('.pp-withdraw-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Withdraw this proposal?')) return;
    const { error } = await sb.rpc('decide_policy_change', { p_id: parseInt(btn.closest('tr').dataset.id, 10), p_outcome: 'withdrawn' });
    if (error) { alert(error.message); return; }
    renderPolicySection(container, { departmentFilter });
  }));
  box.querySelectorAll('.pp-approve-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Approve this policy change? It becomes live immediately.')) return;
    const { error } = await sb.rpc('decide_policy_change', { p_id: parseInt(btn.closest('tr').dataset.id, 10), p_outcome: 'approved' });
    if (error) { alert(error.message); return; }
    // Refresh the cached policy_values (read at boot, see core.js showApp()) so badges/thresholds
    // used elsewhere in the app reflect an approved change without a full page reload.
    const { data: policyRows } = await sb.from('policy_values').select('key,value');
    State.policyValues = {};
    for (const p of (policyRows || [])) State.policyValues[p.key] = p.value;
    renderPolicySection(container, { departmentFilter });
  }));
  box.querySelectorAll('.pp-reject-btn').forEach(btn => btn.addEventListener('click', async () => {
    const note = prompt('A note is required when rejecting - it will be visible to the proposer:');
    if (note == null) return;
    if (!note.trim()) { alert('A note is required when rejecting.'); return; }
    const { error } = await sb.rpc('decide_policy_change', { p_id: parseInt(btn.closest('tr').dataset.id, 10), p_outcome: 'rejected', p_note: note.trim() });
    if (error) { alert(error.message); return; }
    renderPolicySection(container, { departmentFilter });
  }));
}

function wireHistory(history, container, departmentFilter) {
  const sel = document.getElementById('policy-history-dept'); // absent when departmentFilter is set - see historyPanel above
  const box = document.getElementById('policy-history-box');
  function render() {
    const filtered = sel && sel.value ? history.filter(p => p.department_code === sel.value) : history;
    if (!filtered.length) { box.innerHTML = '<div class="empty-msg">No decided proposals yet.</div>'; return; }
    box.innerHTML = `
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Department</th><th>Table</th><th>Key</th><th>Change</th><th>Reason</th><th>Status</th><th>Decided by</th><th>Note</th><th>Date</th></tr></thead>
        <tbody>${filtered.map(p => `<tr>
          <td>${esc(deptLabel(p.department_code))}</td>
          <td>${esc(p.target_table)}</td>
          <td>${esc(p.target_key)}</td>
          <td style="white-space:normal;">${esc(fieldChangesSummary(p))}</td>
          <td style="white-space:normal;">${esc(p.reason)}</td>
          <td>${esc(p.status)}</td>
          <td>${esc(p.decided_by_email || '')}</td>
          <td style="white-space:normal;">${esc(p.decision_note || '')}</td>
          <td>${esc((p.decided_at || '').slice(0, 10))}</td>
        </tr>`).join('')}</tbody>
      </table></div>`;
  }
  if (sel) sel.addEventListener('change', render);
  render();
}
