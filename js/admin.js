import { sb, State, esc, optionsHtml, isAdmin, withStatus, loadOptions, labelOf, getDisplayNameByEmail, OPTION_LIST_NAMES, OPTION_LIST_LABELS } from './core.js?v=20260901232817';

// ---------- Users ----------

export async function renderUsersView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  const rows = await withStatus(sb.from('user_roles').select('*').order('email'));
  const profileRows = await withStatus(sb.from('user_profiles').select('*'));
  const profileByUid = {}; for (const p of profileRows) profileByUid[p.user_id] = p;
  const qualList = State.optionListsByName.operator_qualification || [];
  const qualRows = qualList.length ? await withStatus(sb.from('user_qualifications').select('*')) : [];
  const qualByUid = {};
  for (const q of qualRows) (qualByUid[q.user_id] ||= new Set()).add(q.qualification_code);
  const adminCount = rows.filter(r => r.role === 'admin').length;

  main.innerHTML = `
    <div class="panel">
      <h2>Users <span class="count-badge">${rows.length}</span></h2>
      <p class="hint">User = read/search only. Operator = can create and edit, and mark documents for deletion. Coordinator = Operator powers, plus reviews "Join the Team" applications. Admin = can also delete permanently and manage roles.</p>
      <p class="hint">Qualifications are tags on top of the Operator role, not extra roles - a person can hold more than one (e.g. Translator + Revisor). They control which task categories someone can see and claim (Translation -> Translator, Revision -> Revisor); manage the list itself from Options -> Operator qualifications.</p>
      <p class="hint">An Admin's role can't be changed from this dropdown - remove their access and re-add them at the new role instead. There must always be at least one Admin, so the last one can't be removed either.</p>
      <div class="grid-wrap"><table class="grid" id="users-grid">
        <thead><tr><th>Email</th><th>Role</th><th>Qualifications</th><th>Credits</th><th>Reputation</th><th>Full name</th><th>City</th><th>Membership</th><th>Phone</th><th>Since</th><th></th></tr></thead>
        <tbody>${rows.map(r => { const p = profileByUid[r.user_id] || {}; const uidQuals = qualByUid[r.user_id] || new Set(); const lowRep = r.role === 'operator' && r.reputation != null && r.reputation < 20; return `<tr data-uid="${esc(r.user_id)}">
          <td>${esc(r.email)}</td>
          <td><select class="role-select" data-uid="${esc(r.user_id)}" ${r.role === 'admin' ? 'disabled title="Admin role can\'t be changed here - remove access and re-add at the new role instead."' : ''}>${optionsHtml([['user', 'User'], ['operator', 'Operator'], ['coordinator', 'Coordinator'], ['admin', 'Admin']], r.role, false)}</select></td>
          <td style="white-space:normal;min-width:220px;">${r.role !== 'operator' ? '<span class="hint">Operators only</span>' : (qualList.map(([code, label]) => `
            <label style="display:inline-flex;align-items:center;gap:4px;margin-right:10px;font-weight:normal;text-transform:none;font-size:12.5px;">
              <input type="checkbox" class="qual-check" data-uid="${esc(r.user_id)}" data-code="${esc(code)}" ${uidQuals.has(code) ? 'checked' : ''}> ${esc(label)}
            </label>`).join('') || '<span class="hint">None defined yet</span>')}</td>
          <td>${r.role === 'operator' ? esc(r.credits ?? 0) : '—'}</td>
          <td>${r.role === 'operator' ? `<span${lowRep ? ' style="color:var(--danger);font-weight:600;"' : ''}>${esc(r.reputation ?? 50)}${lowRep ? ' (low)' : ''}</span>` : '—'}</td>
          <td>${esc(p.full_name)}</td>
          <td>${esc(p.city)}</td>
          <td>${esc(labelOf(State.optionListsByName.membership_type || [], p.membership_type))}</td>
          <td>${esc(p.phone)}</td>
          <td>${esc((r.created_at || '').slice(0, 10))}</td>
          <td>
            <button class="btn secondary edit-profile-btn" data-uid="${esc(r.user_id)}" data-email="${esc(r.email)}" style="padding:4px 10px;">Edit</button>
            <button class="btn danger remove-user-btn" data-uid="${esc(r.user_id)}" data-email="${esc(r.email)}" style="padding:4px 10px;">Remove access</button>
          </td></tr>`; }).join('')}</tbody>
      </table></div>
      <p class="hint" style="margin-top:8px;">"Remove access" drops the person back to no role at all (they lose the app entirely until re-registered or re-added) - it does not delete their login/auth account. To fully delete an account, use the Supabase Dashboard (Authentication → Users).</p>
    </div>`;
  main.querySelectorAll('.role-select').forEach(sel => sel.addEventListener('change', async () => {
    await withStatus(sb.from('user_roles').update({ role: sel.value }).eq('user_id', sel.dataset.uid), 'Updating role...');
    await renderUsersView(main); // re-render so the qualifications column shows/hides for the new role
  }));
  main.querySelectorAll('.qual-check').forEach(cb => cb.addEventListener('change', async () => {
    const { uid, code } = cb.dataset;
    if (cb.checked) await withStatus(sb.from('user_qualifications').insert({ user_id: uid, qualification_code: code }), 'Saving...');
    else await withStatus(sb.from('user_qualifications').delete().eq('user_id', uid).eq('qualification_code', code), 'Saving...');
  }));
  main.querySelectorAll('.remove-user-btn').forEach(btn => btn.addEventListener('click', async () => {
    const row = rows.find(r => r.user_id === btn.dataset.uid);
    if (row && row.role === 'admin' && adminCount <= 1) { alert('There must always be at least one Admin - promote someone else first before removing this one.'); return; }
    if (!confirm(`Remove access for ${btn.dataset.email}? They will lose all access to the app until re-added (their login account itself is not deleted).`)) return;
    await withStatus(sb.from('user_roles').delete().eq('user_id', btn.dataset.uid), 'Removing...');
    await renderUsersView(main);
  }));
  main.querySelectorAll('.edit-profile-btn').forEach(btn => btn.addEventListener('click', () => {
    showEditProfileModal(btn.dataset.uid, btn.dataset.email, profileByUid[btn.dataset.uid] || {}, main);
  }));
}

function showEditProfileModal(uid, email, profile, main) {
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2>Edit profile <span class="hint">— ${esc(email)}</span></h2>
      <div class="field"><label>Full name</label><input id="edit-profile-fullname" value="${esc(profile.full_name)}"></div>
      <div class="field"><label>City</label><input id="edit-profile-city" value="${esc(profile.city)}"></div>
      <div class="field"><label>Focolare membership type</label>
        <select id="edit-profile-membership">${optionsHtml(State.optionListsByName.membership_type || [], profile.membership_type, true)}</select>
      </div>
      <div class="field"><label>Mobile phone</label><input id="edit-profile-phone" value="${esc(profile.phone)}"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="edit-profile-cancel">Cancel</button>
        <button class="btn" id="edit-profile-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('edit-profile-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('edit-profile-save').addEventListener('click', async () => {
    const full_name = document.getElementById('edit-profile-fullname').value.trim();
    const city = document.getElementById('edit-profile-city').value.trim();
    const membership_type = document.getElementById('edit-profile-membership').value;
    const phone = document.getElementById('edit-profile-phone').value.trim();
    await withStatus(sb.from('user_profiles').upsert({ user_id: uid, email, full_name, city, membership_type, phone }), 'Saving...');
    backdrop.remove();
    await renderUsersView(main);
  });
}

// ---------- Options (admin-editable dropdown lists) ----------

export async function renderOptionsView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  main.innerHTML = `
    <div class="panel">
      <h2>Options <span class="hint">— edit the dropdown lists used across the app</span></h2>
      <div class="field" style="max-width:280px;">
        <label>List</label>
        <select id="opt-list-select">${OPTION_LIST_NAMES.map(n => `<option value="${n}" ${n === State.optionsSelectedList ? 'selected' : ''}>${OPTION_LIST_LABELS[n]}</option>`).join('')}</select>
      </div>
      <div id="opt-editor"></div>
    </div>
    <div class="panel">
      <h2>Task reputation tiers <span class="hint">— reputation deltas by task size (base credits)</span></h2>
      <div id="reptiers-editor"></div>
    </div>`;
  document.getElementById('opt-list-select').addEventListener('change', e => { State.optionsSelectedList = e.target.value; renderOptionsEditor(); });
  await renderOptionsEditor();
  await renderReputationTiersEditor();
}

async function renderReputationTiersEditor() {
  const box = document.getElementById('reptiers-editor');
  const rows = await withStatus(sb.from('task_reputation_tiers').select('*').order('sort_order'));
  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Tier</th><th>Min base credits</th><th>Max base credits</th><th>OK</th><th>OK, but...</th><th>Fail / Reject</th><th>Sort order</th><th></th></tr></thead>
      <tbody>${rows.map(r => `<tr data-tier="${esc(r.tier_name)}">
        <td><input class="rt-name" value="${esc(r.tier_name)}" style="width:90px;"></td>
        <td><input class="rt-min" type="number" value="${esc(r.min_base_credits)}" style="width:70px;"></td>
        <td><input class="rt-max" type="number" value="${r.max_base_credits ?? ''}" placeholder="none" style="width:70px;"></td>
        <td><input class="rt-ok" type="number" value="${esc(r.ok_delta)}" style="width:60px;"></td>
        <td><input class="rt-okbut" type="number" value="${esc(r.ok_but_delta)}" style="width:60px;"></td>
        <td><input class="rt-fail" type="number" value="${esc(r.fail_delta)}" style="width:60px;"></td>
        <td><input class="rt-order" type="number" value="${esc(r.sort_order)}" style="width:60px;"></td>
        <td><button class="btn secondary rt-save" style="padding:4px 10px;">Save</button>
            <button class="btn danger rt-delete" style="padding:4px 10px;">Delete</button></td>
      </tr>`).join('')}
      <tr data-tier="">
        <td><input class="rt-name" placeholder="Tier name" style="width:90px;"></td>
        <td><input class="rt-min" type="number" value="0" style="width:70px;"></td>
        <td><input class="rt-max" type="number" placeholder="none" style="width:70px;"></td>
        <td><input class="rt-ok" type="number" value="0" style="width:60px;"></td>
        <td><input class="rt-okbut" type="number" value="0" style="width:60px;"></td>
        <td><input class="rt-fail" type="number" value="0" style="width:60px;"></td>
        <td><input class="rt-order" type="number" value="${rows.length + 1}" style="width:60px;"></td>
        <td><button class="btn rt-add" style="padding:4px 10px;">Add</button></td>
      </tr>
      </tbody>
    </table></div>
    <p class="hint" style="margin-top:8px;">Leave "Max base credits" empty for an open-ended top tier. A task's tier is matched by its base credits (rate &times; pages), not by the total including any extra credits.</p>
  `;
  function readRow(tr) {
    const tier_name = tr.querySelector('.rt-name').value.trim();
    const min_base_credits = parseInt(tr.querySelector('.rt-min').value, 10) || 0;
    const maxRaw = tr.querySelector('.rt-max').value.trim();
    const max_base_credits = maxRaw === '' ? null : parseInt(maxRaw, 10);
    const ok_delta = parseInt(tr.querySelector('.rt-ok').value, 10) || 0;
    const ok_but_delta = parseInt(tr.querySelector('.rt-okbut').value, 10) || 0;
    const fail_delta = parseInt(tr.querySelector('.rt-fail').value, 10) || 0;
    const sort_order = parseInt(tr.querySelector('.rt-order').value, 10) || 0;
    return { tier_name, min_base_credits, max_base_credits, ok_delta, ok_but_delta, fail_delta, sort_order };
  }
  box.querySelectorAll('tr[data-tier]:not([data-tier=""])').forEach(tr => {
    const originalName = tr.dataset.tier;
    tr.querySelector('.rt-save').addEventListener('click', async () => {
      const row = readRow(tr);
      if (!row.tier_name) { alert('Tier name is required.'); return; }
      const { data: { user } } = await sb.auth.getUser();
      if (row.tier_name !== originalName) {
        await withStatus(sb.from('task_reputation_tiers').delete().eq('tier_name', originalName));
      }
      await withStatus(sb.from('task_reputation_tiers').upsert({ ...row, updated_at: new Date().toISOString(), updated_by_email: user.email }), 'Saving...');
      await renderReputationTiersEditor();
    });
    tr.querySelector('.rt-delete').addEventListener('click', async () => {
      if (!confirm(`Remove tier "${originalName}"?`)) return;
      await withStatus(sb.from('task_reputation_tiers').delete().eq('tier_name', originalName));
      await renderReputationTiersEditor();
    });
  });
  const addRow = box.querySelector('tr[data-tier=""]');
  addRow.querySelector('.rt-add').addEventListener('click', async () => {
    const row = readRow(addRow);
    if (!row.tier_name) { alert('Tier name is required.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('task_reputation_tiers').insert({ ...row, updated_at: new Date().toISOString(), updated_by_email: user.email }), 'Adding...');
    await renderReputationTiersEditor();
  });
}

async function renderOptionsEditor() {
  const box = document.getElementById('opt-editor');
  const isTaskCategory = State.optionsSelectedList === 'task_category';
  const rows = await withStatus(sb.from('option_lists').select('*').eq('list_name', State.optionsSelectedList).order('sort_order'));
  const rateByCode = {};
  if (isTaskCategory) {
    const rateRows = await withStatus(sb.from('task_category_rates').select('*'));
    for (const r of rateRows) rateByCode[r.category] = r.credits_per_page;
  }
  const rateHeadCell = isTaskCategory ? '<th>Credits/page</th>' : '';
  const rateCell = code => isTaskCategory ? `<td><input class="opt-rate" type="number" min="0" step="0.5" value="${esc(rateByCode[code] ?? 0)}" style="width:70px;"></td>` : '';
  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Code</th><th>Label</th><th>Sort order</th>${rateHeadCell}<th></th></tr></thead>
      <tbody>${rows.map(r => `<tr data-code="${esc(r.code)}">
        <td><input class="opt-code" value="${esc(r.code)}" style="width:90px;"></td>
        <td><input class="opt-label" value="${esc(r.label)}"></td>
        <td><input class="opt-order" type="number" value="${esc(r.sort_order)}" style="width:70px;"></td>
        ${rateCell(r.code)}
        <td><button class="btn secondary opt-save" style="padding:4px 10px;">Save</button>
            <button class="btn danger opt-delete" style="padding:4px 10px;">Delete</button></td>
      </tr>`).join('')}
      <tr data-code="">
        <td><input class="opt-code" placeholder="NEWCODE" style="width:90px;"></td>
        <td><input class="opt-label" placeholder="New option label"></td>
        <td><input class="opt-order" type="number" value="${rows.length + 1}" style="width:70px;"></td>
        ${isTaskCategory ? '<td><input class="opt-rate" type="number" min="0" step="0.5" value="0" style="width:70px;"></td>' : ''}
        <td><button class="btn opt-add" style="padding:4px 10px;">Add</button></td>
      </tr>
      </tbody>
    </table></div>
    <p class="hint" style="margin-top:8px;">Changing or removing a code here does not update documents that already use the old code — edit those separately if needed.</p>
    ${isTaskCategory ? '<p class="hint">Credits/page is the base rate used to suggest a task\'s credits (rate &times; document pages) when creating a task in that category - see the Tasks tab.</p>' : ''}
  `;
  box.querySelectorAll('tr[data-code]:not([data-code=""])').forEach(tr => {
    const originalCode = tr.dataset.code;
    tr.querySelector('.opt-save').addEventListener('click', async () => {
      const code = tr.querySelector('.opt-code').value.trim();
      const label = tr.querySelector('.opt-label').value.trim();
      const sortOrder = parseInt(tr.querySelector('.opt-order').value, 10) || 0;
      if (!code || !label) { alert('Code and label are required.'); return; }
      if (code !== originalCode) {
        await withStatus(sb.from('option_lists').delete().eq('list_name', State.optionsSelectedList).eq('code', originalCode));
        if (isTaskCategory) await withStatus(sb.from('task_category_rates').delete().eq('category', originalCode));
      }
      await withStatus(sb.from('option_lists').upsert({ list_name: State.optionsSelectedList, code, label, sort_order: sortOrder }), 'Saving...');
      if (isTaskCategory) {
        const { data: { user } } = await sb.auth.getUser();
        const rate = parseFloat(tr.querySelector('.opt-rate').value) || 0;
        await withStatus(sb.from('task_category_rates').upsert({ category: code, credits_per_page: rate, updated_at: new Date().toISOString(), updated_by_email: user.email }), 'Saving...');
      }
      await loadOptions();
      await renderOptionsEditor();
    });
    tr.querySelector('.opt-delete').addEventListener('click', async () => {
      if (!confirm(`Remove option "${originalCode}" from this list?`)) return;
      await withStatus(sb.from('option_lists').delete().eq('list_name', State.optionsSelectedList).eq('code', originalCode));
      if (isTaskCategory) await withStatus(sb.from('task_category_rates').delete().eq('category', originalCode));
      await loadOptions();
      await renderOptionsEditor();
    });
  });
  const addRow = box.querySelector('tr[data-code=""]');
  addRow.querySelector('.opt-add').addEventListener('click', async () => {
    const code = addRow.querySelector('.opt-code').value.trim();
    const label = addRow.querySelector('.opt-label').value.trim();
    const sortOrder = parseInt(addRow.querySelector('.opt-order').value, 10) || 0;
    if (!code || !label) { alert('Code and label are required.'); return; }
    await withStatus(sb.from('option_lists').insert({ list_name: State.optionsSelectedList, code, label, sort_order: sortOrder }), 'Adding...');
    if (isTaskCategory) {
      const { data: { user } } = await sb.auth.getUser();
      const rate = parseFloat(addRow.querySelector('.opt-rate').value) || 0;
      await withStatus(sb.from('task_category_rates').upsert({ category: code, credits_per_page: rate, updated_at: new Date().toISOString(), updated_by_email: user.email }), 'Saving...');
    }
    await loadOptions();
    await renderOptionsEditor();
  });
}

// ---------- Announcements (splash-screen editor, admin-only) ----------

export async function renderAnnouncementsView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  main.innerHTML = `
    <div class="panel">
      <h2>Announcements <span class="hint">— shown to every user in a splash screen on their next login</span></h2>
      <div class="field"><label>New announcement text</label><textarea id="splash-new-text" rows="4"></textarea></div>
      <div class="btn-row"><button class="btn" id="splash-publish-btn">Publish</button></div>
    </div>
    <div class="panel">
      <h2>History</h2>
      <div class="grid-wrap"><table class="grid" id="splash-history-grid">
        <thead><tr><th>Date</th><th>Published by</th><th>Message</th></tr></thead>
        <tbody id="splash-history-body"></tbody>
      </table></div>
    </div>`;
  await refreshAnnouncementsHistory();
  document.getElementById('splash-publish-btn').addEventListener('click', async () => {
    const text = document.getElementById('splash-new-text').value.trim();
    if (!text) { alert('Announcement text is required.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('splash_messages').insert({ message_text: text, created_by_email: user.email }), 'Publishing...');
    document.getElementById('splash-new-text').value = '';
    await refreshAnnouncementsHistory();
  });
}

async function refreshAnnouncementsHistory() {
  const rows = await withStatus(sb.from('splash_messages').select('*').order('created_at', { ascending: false }));
  const names = await Promise.all(rows.map(r => getDisplayNameByEmail(r.created_by_email)));
  document.getElementById('splash-history-body').innerHTML = rows.map((r, i) => `<tr>
    <td>${esc((r.created_at || '').slice(0, 16).replace('T', ' '))}</td>
    <td>${esc(names[i])}</td>
    <td style="white-space:normal;">${esc(r.message_text)}</td>
  </tr>`).join('') || '<tr><td colspan="3">No announcements yet.</td></tr>';
}
