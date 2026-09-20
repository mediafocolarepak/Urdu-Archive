import { sb, State, esc, optionsHtml, isAdmin, withStatus, loadOptions, labelOf, getDisplayNameByEmail, likeSafe, OPTION_LIST_NAMES, OPTION_LIST_LABELS, readPdfPageCountDebug, getDriveAccessToken, canProposePolicyChange } from './core.js?v=20260920111144';
import { openPolicyProposalModal, ownersFor } from './policy.js?v=20260920111144';

// ---------- Users ----------

const STANDING_BADGE = { active: '', watch: '<span class="hint" style="color:var(--warning,#b8860b);">watch</span>', suspended: '<span class="hint" style="color:var(--danger);">suspended</span>' };

export async function renderUsersView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  const rows = await withStatus(sb.from('user_roles').select('*').order('email'));
  const profileRows = await withStatus(sb.from('user_profiles').select('*'));
  const profileByUid = {}; for (const p of profileRows) profileByUid[p.user_id] = p;
  const qualList = State.optionListsByName.operator_qualification || [];
  const qualRows = qualList.length ? await withStatus(sb.from('user_qualifications').select('*')) : [];
  const qualByUid = {};
  for (const q of qualRows) (qualByUid[q.user_id] ||= new Set()).add(q.qualification_code);
  const deptRows = await withStatus(sb.from('department_members').select('*'));
  const deptByUid = {};
  for (const d of deptRows) (deptByUid[d.user_id] ||= []).push(d);
  const adminCount = rows.filter(r => r.role === 'admin').length;

  // Sortable by name or by signup date only (the other columns have no obvious total order,
  // e.g. role/qualifications) - same click-a-th-header pattern as dashboard.js's DASH_SORTABLE.
  const sortCol = State.usersSort.col;
  const dir = State.usersSort.asc ? 1 : -1;
  rows.sort((a, b) => {
    const av = sortCol === 'full_name' ? (profileByUid[a.user_id]?.full_name || '').toLowerCase() : (a.created_at || '');
    const bv = sortCol === 'full_name' ? (profileByUid[b.user_id]?.full_name || '').toLowerCase() : (b.created_at || '');
    return av < bv ? -dir : av > bv ? dir : 0;
  });
  const arrow = col => col !== sortCol ? '' : (State.usersSort.asc ? ' &uarr;' : ' &darr;');

  main.innerHTML = `
    <div class="panel">
      <h2>Users <span class="count-badge">${rows.length}</span></h2>
      <p class="hint">User = read/search only. Operator = can create and edit, and mark documents for deletion. Coordinator = Operator powers, plus reviews "Join the Team" applications. Admin = can also delete permanently and manage roles.</p>
      <p class="hint">Qualifications are tags on top of the Operator role, not extra roles - a person can hold more than one (e.g. Translator + Revisor). They control which task categories someone can see and claim (Translation -> Translator, Revision -> Revisor); manage the list itself from Options -> Operator qualifications.</p>
      <p class="hint">An Admin's role can't be changed from this dropdown - remove their access and re-add them at the new role instead. There must always be at least one Admin, so the last one can't be removed either.</p>
      <div class="grid-wrap"><table class="grid" id="users-grid">
        <thead><tr><th data-sort="full_name">Full name${arrow('full_name')}</th><th>Age group</th><th>Email</th><th>Role</th><th>Departments</th><th>Standing</th><th>Qualifications</th><th>Credits</th><th>Reputation</th><th>City</th><th>Membership</th><th>Phone</th><th data-sort="created_at">Since${arrow('created_at')}</th><th></th></tr></thead>
        <tbody>${rows.map(r => { const p = profileByUid[r.user_id] || {}; const uidQuals = qualByUid[r.user_id] || new Set(); const lowRep = r.role === 'operator' && r.reputation != null && r.reputation < 20;
          const deptLabel = (deptByUid[r.user_id] || []).map(d => `${labelOf(State.optionListsByName.department || [], d.department_code)}${d.is_lead ? ' (lead)' : ''}`).join(', ');
          return `<tr data-uid="${esc(r.user_id)}">
          <td>${esc(p.full_name)}</td>
          <td><select class="age-group-select" data-uid="${esc(r.user_id)}" style="width:12ch;">${optionsHtml(State.optionListsByName.age_bracket || [], p.age_bracket, true)}</select></td>
          <td>${esc(r.email)}</td>
          <td><select class="role-select" data-uid="${esc(r.user_id)}" style="width:10ch;" ${r.role === 'admin' ? 'disabled title="Admin role can\'t be changed here - remove access and re-add at the new role instead."' : ''}>${optionsHtml([['user', 'User'], ['operator', 'Operator'], ['coordinator', 'Coordinator'], ['admin', 'Admin']], r.role, false)}</select></td>
          <td style="white-space:normal;">${esc(deptLabel) || '<span class="hint">—</span>'}</td>
          <td>${STANDING_BADGE[r.standing] ?? esc(r.standing)}</td>
          <td style="white-space:normal;min-width:220px;">${r.role !== 'operator' ? '<span class="hint">Operators only</span>' : (qualList.map(([code, label]) => `
            <label style="display:inline-flex;align-items:center;gap:4px;margin-right:10px;font-weight:normal;text-transform:none;font-size:12.5px;">
              <input type="checkbox" class="qual-check" data-uid="${esc(r.user_id)}" data-code="${esc(code)}" ${uidQuals.has(code) ? 'checked' : ''}> ${esc(label)}
            </label>`).join('') || '<span class="hint">None defined yet</span>')}</td>
          <td>${r.role === 'operator' ? esc(r.credits ?? 0) : '—'}</td>
          <td>${r.role === 'operator' ? `<span${lowRep ? ' style="color:var(--danger);font-weight:600;"' : ''}>${esc(r.reputation ?? 50)}${lowRep ? ' (low)' : ''}</span>` : '—'}</td>
          <td>${esc(p.city)}</td>
          <td>${esc(labelOf(State.optionListsByName.membership_type || [], p.membership_type))}</td>
          <td>${esc(p.phone)}</td>
          <td>${esc((r.created_at || '').slice(0, 10))}</td>
          <td>
            <button class="btn secondary edit-profile-btn" data-uid="${esc(r.user_id)}" data-email="${esc(r.email)}" style="padding:4px 10px;">Edit</button>
            <button class="btn danger propose-exclusion-btn" data-uid="${esc(r.user_id)}" data-email="${esc(r.email)}" style="padding:4px 10px;">Propose exclusion</button>
          </td></tr>`; }).join('')}</tbody>
      </table></div>
      <p class="hint" style="margin-top:8px;">"Propose exclusion" records a request to remove this person's role, keeping their account, credits and reputation (GOVERNANCE.md §8.7) - another Admin or the HR lead must approve it for it to take effect. To fully delete a login/auth account, use the Supabase Dashboard (Authentication → Users).</p>
    </div>`;
  main.querySelectorAll('#users-grid th[data-sort]').forEach(th => th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (State.usersSort.col === col) State.usersSort.asc = !State.usersSort.asc; else State.usersSort = { col, asc: true };
    renderUsersView(main);
  }));
  main.querySelectorAll('.role-select').forEach(sel => sel.addEventListener('change', async () => {
    await withStatus(sb.from('user_roles').update({ role: sel.value }).eq('user_id', sel.dataset.uid), 'Updating role...');
    await renderUsersView(main); // re-render so the qualifications column shows/hides for the new role
  }));
  main.querySelectorAll('.age-group-select').forEach(sel => sel.addEventListener('change', async () => {
    await withStatus(sb.from('user_profiles').upsert({ user_id: sel.dataset.uid, age_bracket: sel.value || null }), 'Saving...');
  }));
  main.querySelectorAll('.qual-check').forEach(cb => cb.addEventListener('change', async () => {
    const { uid, code } = cb.dataset;
    if (cb.checked) await withStatus(sb.from('user_qualifications').insert({ user_id: uid, qualification_code: code }), 'Saving...');
    else await withStatus(sb.from('user_qualifications').delete().eq('user_id', uid).eq('qualification_code', code), 'Saving...');
  }));
  main.querySelectorAll('.propose-exclusion-btn').forEach(btn => btn.addEventListener('click', async () => {
    const row = rows.find(r => r.user_id === btn.dataset.uid);
    if (row && row.role === 'admin' && adminCount <= 1) { alert('There must always be at least one Admin - promote someone else first before excluding this one.'); return; }
    const reason = prompt(`Reason for proposing exclusion of ${btn.dataset.email}?\n(their account, credits and reputation are kept - only the role is removed, once approved)`);
    if (reason == null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    const { error } = await sb.rpc('propose_people_decision', { p_subject: btn.dataset.uid, p_type: 'exclude', p_reason: reason.trim() });
    if (error) { alert(error.message); return; }
    alert('Exclusion proposed and recorded as pending. It needs another Admin (or the HR lead) to approve it via rpc(\'decide_people_decision\') before it takes effect - there is no approval screen yet (planned for the People tab).');
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
      <div class="field"><label>Age bracket <span class="hint">(statistics only)</span></label>
        <select id="edit-profile-age-bracket">${optionsHtml(State.optionListsByName.age_bracket || [], profile.age_bracket, true)}</select>
      </div>
      <div class="field"><label>Gender <span class="hint">(statistics only)</span></label>
        <select id="edit-profile-gender">${optionsHtml([['M', 'Male'], ['F', 'Female']], profile.gender, true)}</select>
      </div>
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
    const age_bracket = document.getElementById('edit-profile-age-bracket').value || null;
    const gender = document.getElementById('edit-profile-gender').value || null;
    await withStatus(sb.from('user_profiles').upsert({ user_id: uid, email, full_name, city, membership_type, phone, age_bracket, gender }), 'Saving...');
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
      <h2>Departments <span class="hint">— membership and leads, see GOVERNANCE.md §2 and §4</span></h2>
      <div id="dept-editor"></div>
    </div>
    <div class="panel">
      <h2>Policy <span class="hint">— task category rates, reputation tiers and thresholds</span></h2>
      <p class="hint">These moved to a propose/approve workflow (GOVERNANCE.md §2.8): no one, including Admin, edits them directly here any more. See <strong>People</strong> to view current values, propose a change (department leads), or approve/reject a pending proposal (Admin).</p>
    </div>
    <div class="panel">
      <h2>Maintenance <span class="hint">— one-off data cleanup tools</span></h2>
      <div>
        <p class="hint">Reads each document's PDF (Supabase Storage, or Google Drive as a fallback) with the same reader used elsewhere in the app, and saves its page count if it's still missing. Runs one document at a time in this tab - keep it open while it works. Safe to stop and resume later: it always skips documents that already have a page count.</p>
        <div class="btn-row">
          <button class="btn" id="backfill-start-btn">Backfill page counts</button>
          <button class="btn secondary" id="backfill-stop-btn" style="display:none;">Stop</button>
        </div>
        <p id="backfill-progress" class="hint"></p>
        <div id="backfill-log" style="max-height:200px;overflow:auto;font-size:12px;"></div>
      </div>
    </div>`;
  document.getElementById('opt-list-select').addEventListener('change', e => { State.optionsSelectedList = e.target.value; renderOptionsEditor(); });
  await renderOptionsEditor();
  await renderDepartmentsEditor();
  wireBackfillPageCounts();
}

// ---------- Maintenance: backfill documents.pages from the PDF for records missing it ----------

let backfillStopRequested = false;

function wireBackfillPageCounts() {
  document.getElementById('backfill-start-btn').addEventListener('click', runBackfillPageCounts);
  document.getElementById('backfill-stop-btn').addEventListener('click', () => { backfillStopRequested = true; });
}

async function runBackfillPageCounts() {
  backfillStopRequested = false;
  const startBtn = document.getElementById('backfill-start-btn');
  const stopBtn = document.getElementById('backfill-stop-btn');
  const progress = document.getElementById('backfill-progress');
  const log = document.getElementById('backfill-log');
  startBtn.style.display = 'none';
  stopBtn.style.display = 'inline-block';
  log.innerHTML = '';

  // The Drive half of this needs an OAuth token, not just the public API key - unauthenticated
  // byte downloads (alt=media) are blocked by CORS, see readPdfPageCountDebug. Fetched once
  // up front (may show Google's consent prompt, possibly in a popup window - check for one if
  // this seems stuck) and reused for the whole run rather than re-requested per document.
  // Guarded with a timeout: Google's token client silently never calls back at all (no
  // resolve, no reject) if its popup gets blocked, which otherwise hangs this indefinitely
  // with no feedback beyond the Stop button already showing.
  progress.textContent = 'Requesting Google Drive access - check for a popup window if this takes more than a few seconds...';
  let accessToken = null;
  try {
    accessToken = await Promise.race([
      getDriveAccessToken(),
      new Promise((_, reject) => setTimeout(() => reject(new Error('Timed out waiting for Google Drive access - a popup may have been blocked. Allow popups for this site and try again.')), 20000)),
    ]);
  } catch (e) {
    log.insertAdjacentHTML('beforeend', `<div>Could not get Google Drive access: ${esc(e.message)} - documents will only be readable from Supabase Storage this run.</div>`);
  }

  const rows = await withStatus(sb.from('documents').select('document_id,title,file_name,storage_path').is('pages', null).neq('media_type', 'VID').order('document_id'));
  let done = 0, ok = 0, failed = 0;
  progress.textContent = `0 / ${rows.length}`;
  for (const doc of rows) {
    if (backfillStopRequested) break;
    try {
      const { pages: n, detail } = await readPdfPageCountDebug(doc, accessToken);
      if (n != null) {
        const { error } = await sb.from('documents').update({ pages: n }).eq('document_id', doc.document_id);
        if (error) throw error;
        ok++;
      } else {
        failed++;
        log.insertAdjacentHTML('beforeend', `<div>#${esc(doc.document_id)} ${esc(doc.title)} — ${esc(detail)}</div>`);
      }
    } catch (err) {
      failed++;
      log.insertAdjacentHTML('beforeend', `<div>#${esc(doc.document_id)} ${esc(doc.title)} — ${esc(err.message)}</div>`);
    }
    done++;
    progress.textContent = `${done} / ${rows.length} (${ok} saved, ${failed} skipped)${backfillStopRequested ? ' — stopped, safe to resume.' : ''}`;
    // A small pause between Drive lookups - unthrottled, this loop can burn through the Drive
    // API's per-100-seconds quota in well under a minute on a set this size, which then makes
    // every later document look like "not found" too (see readPdfPageCountDebug's API-error
    // branch, added after exactly that got misread as a per-file problem).
    await new Promise(r => setTimeout(r, 200));
  }
  if (!backfillStopRequested) progress.textContent += ' — done.';
  startBtn.style.display = 'inline-block';
  stopBtn.style.display = 'none';
}

// ---------- Departments (membership + one lead per department, GOVERNANCE.md §2/§4) ----------

async function renderDepartmentsEditor() {
  const box = document.getElementById('dept-editor');
  const depts = State.optionListsByName.department || [];
  if (!depts.length) { box.innerHTML = '<div class="hint">No departments defined yet - add one to the "department" list above.</div>'; return; }
  const selected = depts.some(([c]) => c === State.deptEditorSelected) ? State.deptEditorSelected : depts[0][0];
  State.deptEditorSelected = selected;
  box.innerHTML = `
    <div class="field" style="max-width:280px;"><label>Department</label><select id="dept-select"></select></div>
    <div id="dept-list"><div class="hint">Loading...</div></div>
    <div class="field" style="margin-top:8px;">
      <label>Add member <span class="hint">(search by name or email)</span></label>
      <input id="dept-search" placeholder="Type a name or email...">
      <div id="dept-search-results"></div>
    </div>`;
  const sel = document.getElementById('dept-select');
  sel.innerHTML = depts.map(([code, label]) => `<option value="${esc(code)}" ${code === selected ? 'selected' : ''}>${esc(label)}</option>`).join('');
  sel.addEventListener('change', () => { State.deptEditorSelected = sel.value; refreshDepartmentMembers(sel.value); });

  document.getElementById('dept-search').addEventListener('input', async e => {
    const q = e.target.value.trim();
    const resultsBox = document.getElementById('dept-search-results');
    if (!q) { resultsBox.innerHTML = ''; return; }
    const pattern = likeSafe(q);
    const rows = await withStatus(sb.from('user_profiles').select('user_id,email,full_name').or(`full_name.ilike.${pattern},email.ilike.${pattern}`).limit(10));
    resultsBox.innerHTML = rows.map(r => `<div class="hint" style="cursor:pointer;padding:2px 0;" data-add-uid="${esc(r.user_id)}">${esc(r.full_name) || esc(r.email)} &middot; ${esc(r.email)}</div>`).join('') || '<div class="hint">No match.</div>';
    resultsBox.querySelectorAll('[data-add-uid]').forEach(el => el.addEventListener('click', async () => {
      const { data: { user } } = await sb.auth.getUser();
      const { error } = await sb.from('department_members').insert({ department_code: sel.value, user_id: el.dataset.addUid, added_by_email: user.email });
      if (error && error.code !== '23505') { alert(error.message); return; } // 23505 = already a member, ignore
      document.getElementById('dept-search').value = '';
      resultsBox.innerHTML = '';
      refreshDepartmentMembers(sel.value);
    }));
  });

  refreshDepartmentMembers(selected);
}

async function refreshDepartmentMembers(deptCode) {
  const box = document.getElementById('dept-list');
  if (!box) return;
  const memberRows = await withStatus(sb.from('department_members').select('user_id,is_lead').eq('department_code', deptCode));
  if (!memberRows.length) { box.innerHTML = '<div class="hint">No members in this department yet.</div>'; return; }
  const profileRows = await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', memberRows.map(r => r.user_id)));
  const profileByUid = {}; for (const p of profileRows) profileByUid[p.user_id] = p;
  box.innerHTML = memberRows.map(r => {
    const p = profileByUid[r.user_id] || {};
    return `<div class="btn-row" style="justify-content:space-between;margin:4px 0;">
      <span>${esc(p.full_name) || esc(p.email) || r.user_id}${r.is_lead ? ' <strong>(lead)</strong>' : ''}</span>
      <span>
        ${r.is_lead
          ? `<button class="btn secondary" data-unset-lead="${esc(r.user_id)}" style="padding:2px 8px;">Remove lead</button>`
          : `<button class="btn secondary" data-make-lead="${esc(r.user_id)}" style="padding:2px 8px;">Make lead</button>`}
        <button class="btn danger" data-remove-member="${esc(r.user_id)}" style="padding:2px 8px;">Remove</button>
      </span>
    </div>`;
  }).join('');
  box.querySelectorAll('[data-make-lead]').forEach(btn => btn.addEventListener('click', async () => {
    const { error } = await sb.from('department_members').update({ is_lead: true }).eq('department_code', deptCode).eq('user_id', btn.dataset.makeLead);
    if (error) { alert(error.code === '23505' ? 'This department already has a lead - remove the current lead first, then make this person lead.' : error.message); return; }
    refreshDepartmentMembers(deptCode);
  }));
  box.querySelectorAll('[data-unset-lead]').forEach(btn => btn.addEventListener('click', async () => {
    await withStatus(sb.from('department_members').update({ is_lead: false }).eq('department_code', deptCode).eq('user_id', btn.dataset.unsetLead), 'Saving...');
    refreshDepartmentMembers(deptCode);
  }));
  box.querySelectorAll('[data-remove-member]').forEach(btn => btn.addEventListener('click', async () => {
    await withStatus(sb.from('department_members').delete().eq('department_code', deptCode).eq('user_id', btn.dataset.removeMember), 'Removing...');
    refreshDepartmentMembers(deptCode);
  }));
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
  const canProposeRate = isTaskCategory && canProposePolicyChange('RF');
  const rateCell = code => {
    if (!isTaskCategory) return '';
    const rate = rateByCode[code];
    const proposeBtn = canProposeRate ? `<button class="btn secondary opt-propose-rate" data-category="${esc(code)}" data-rate="${esc(rate ?? 0)}" style="padding:2px 8px;margin-left:6px;">Propose</button>` : '';
    return `<td>${rate == null ? '<span class="hint">not set</span>' : esc(rate)}${proposeBtn}</td>`;
  };
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
        ${isTaskCategory ? '<td><span class="hint">set after creating, below</span></td>' : ''}
        <td><button class="btn opt-add" style="padding:4px 10px;">Add</button></td>
      </tr>
      </tbody>
    </table></div>
    <p class="hint" style="margin-top:8px;">Changing or removing a code here does not update documents that already use the old code — edit those separately if needed.</p>
    ${isTaskCategory ? '<p class="hint">Credits/page (GOVERNANCE.md §2.8) is no longer edited here - it moved to a propose/approve workflow, see People &rarr; Policy. A brand-new category has no rate until a Reward lead proposes one there.</p>' : ''}
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
  if (isTaskCategory) {
    box.querySelectorAll('.opt-propose-rate').forEach(btn => btn.addEventListener('click', () => {
      openPolicyProposalModal({
        title: `Propose a rate change — ${btn.dataset.category}`,
        targetTable: 'task_category_rates', targetKey: btn.dataset.category, action: 'upsert',
        owners: ownersFor('task_category_rates'),
        fields: [{ name: 'credits_per_page', label: 'Credits per page', type: 'number', value: btn.dataset.rate }],
        onSaved: renderOptionsEditor,
      });
    }));
  }
  const addRow = box.querySelector('tr[data-code=""]');
  addRow.querySelector('.opt-add').addEventListener('click', async () => {
    const code = addRow.querySelector('.opt-code').value.trim();
    const label = addRow.querySelector('.opt-label').value.trim();
    const sortOrder = parseInt(addRow.querySelector('.opt-order').value, 10) || 0;
    if (!code || !label) { alert('Code and label are required.'); return; }
    await withStatus(sb.from('option_lists').insert({ list_name: State.optionsSelectedList, code, label, sort_order: sortOrder }), 'Adding...');
    await loadOptions();
    await renderOptionsEditor();
    if (isTaskCategory && canProposePolicyChange('RF')) {
      openPolicyProposalModal({
        title: `Propose the initial rate — ${code}`,
        targetTable: 'task_category_rates', targetKey: code, action: 'upsert',
        owners: ownersFor('task_category_rates'),
        fields: [{ name: 'credits_per_page', label: 'Credits per page', type: 'number', value: 0 }],
        onSaved: renderOptionsEditor,
      });
    }
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
