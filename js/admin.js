import { sb, State, esc, optionsHtml, isAdmin, withStatus, loadOptions, labelOf, getDisplayNameByEmail, OPTION_LIST_NAMES, OPTION_LIST_LABELS } from './core.js?v=20260827160000';

// ---------- Users ----------

export async function renderUsersView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  const rows = await withStatus(sb.from('user_roles').select('*').order('email'));
  const profileRows = await withStatus(sb.from('user_profiles').select('*'));
  const profileByUid = {}; for (const p of profileRows) profileByUid[p.user_id] = p;
  main.innerHTML = `
    <div class="panel">
      <h2>Users <span class="count-badge">${rows.length}</span></h2>
      <p class="hint">User = read/search only. Operator = can create and edit, and mark documents for deletion. Admin = can also delete permanently and manage roles.</p>
      <div class="grid-wrap"><table class="grid" id="users-grid">
        <thead><tr><th>Email</th><th>Role</th><th>Full name</th><th>City</th><th>Membership</th><th>Phone</th><th>Since</th><th></th></tr></thead>
        <tbody>${rows.map(r => { const p = profileByUid[r.user_id] || {}; return `<tr data-uid="${esc(r.user_id)}">
          <td>${esc(r.email)}</td>
          <td><select class="role-select" data-uid="${esc(r.user_id)}">${optionsHtml([['user', 'User'], ['operator', 'Operator'], ['admin', 'Admin']], r.role, false)}</select></td>
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
  }));
  main.querySelectorAll('.remove-user-btn').forEach(btn => btn.addEventListener('click', async () => {
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
    </div>`;
  document.getElementById('opt-list-select').addEventListener('change', e => { State.optionsSelectedList = e.target.value; renderOptionsEditor(); });
  await renderOptionsEditor();
}

async function renderOptionsEditor() {
  const box = document.getElementById('opt-editor');
  const rows = await withStatus(sb.from('option_lists').select('*').eq('list_name', State.optionsSelectedList).order('sort_order'));
  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Code</th><th>Label</th><th>Sort order</th><th></th></tr></thead>
      <tbody>${rows.map(r => `<tr data-code="${esc(r.code)}">
        <td><input class="opt-code" value="${esc(r.code)}" style="width:90px;"></td>
        <td><input class="opt-label" value="${esc(r.label)}"></td>
        <td><input class="opt-order" type="number" value="${esc(r.sort_order)}" style="width:70px;"></td>
        <td><button class="btn secondary opt-save" style="padding:4px 10px;">Save</button>
            <button class="btn danger opt-delete" style="padding:4px 10px;">Delete</button></td>
      </tr>`).join('')}
      <tr data-code="">
        <td><input class="opt-code" placeholder="NEWCODE" style="width:90px;"></td>
        <td><input class="opt-label" placeholder="New option label"></td>
        <td><input class="opt-order" type="number" value="${rows.length + 1}" style="width:70px;"></td>
        <td><button class="btn opt-add" style="padding:4px 10px;">Add</button></td>
      </tr>
      </tbody>
    </table></div>
    <p class="hint" style="margin-top:8px;">Changing or removing a code here does not update documents that already use the old code — edit those separately if needed.</p>
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
      }
      await withStatus(sb.from('option_lists').upsert({ list_name: State.optionsSelectedList, code, label, sort_order: sortOrder }), 'Saving...');
      await loadOptions();
      await renderOptionsEditor();
    });
    tr.querySelector('.opt-delete').addEventListener('click', async () => {
      if (!confirm(`Remove option "${originalCode}" from this list?`)) return;
      await withStatus(sb.from('option_lists').delete().eq('list_name', State.optionsSelectedList).eq('code', originalCode));
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
