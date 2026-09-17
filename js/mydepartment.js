// "My Department" (migration 87, GOVERNANCE.md §2.7/§2.8): a single screen for a department
// lead (or Admin) to keep an eye on their own team and policy without hunting across tabs.
// Department list is fully data-driven from option_lists ('department') and department_members
// - departments can be added, renamed or retired from Options without touching this file.

import { sb, State, esc, withStatus, isAdmin, isDeptLead, likeSafe } from './core.js?v=20260917235357';
import { renderPolicySection } from './policy.js?v=20260917235357';
import { renderPeopleSection } from './people.js?v=20260917235357';

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
    ${selected === 'HR' ? '<div id="mydept-people-box"></div>' : ''}
    ${selected === 'RF' ? '<div id="mydept-credits-box"></div>' : ''}
    <div id="mydept-policy-box"></div>`;

  if (codes.length > 1) {
    document.getElementById('mydept-select').addEventListener('change', e => {
      State.myDeptSelected = e.target.value;
      renderMyDepartmentView(main);
    });
  }

  await renderRoster(selected);
  // HR's job is org-wide people oversight, not just its own small team (§Team above) - the full
  // People roster (GOVERNANCE.md §6.2) belongs here too, per the owner's request 2026-09-17, so
  // an HR lead doesn't have to bounce between My Department and the standalone People tab.
  if (selected === 'HR') await renderPeopleSection(document.getElementById('mydept-people-box'));
  // Reward needs to see credits in circulation to tune rates/tiers and, later, plan compensation
  // runs (GOVERNANCE.md §6.4, migration 88) - same numbers Admin already sees in Tasks -> Budget,
  // read-only here (topping up the budget stays an Owner/Admin action, decision matrix row 16).
  if (selected === 'RF') await renderRewardCredits(document.getElementById('mydept-credits-box'));
  await renderPolicySection(document.getElementById('mydept-policy-box'), { departmentFilter: selected });
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
