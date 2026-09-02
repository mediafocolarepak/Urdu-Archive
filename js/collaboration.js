// "Join the Team": explains the project to a User-role account and collects a structured
// application (collaboration_applications table) instead of a free-text chat message, so
// Coordinator/Admin get comparable fields to actually evaluate a candidate on. Coordinator
// can only move a request to 'recommended'/'rejected' (enforced by RLS, not just hidden in
// the UI) - only Admin can set 'approved', paired with the actual role promotion in
// user_roles (already an admin-only action, see 05_roles_and_permissions.sql).

import { sb, State, esc, canReviewApplications, isAdmin, withStatus, nameMapForEmails } from './core.js?v=20260902151023';

const ACADEMIC_LEVELS = [
  ['HIGH_SCHOOL', 'High school'],
  ['BACHELOR', "Bachelor's degree"],
  ['MASTER', "Master's degree"],
  ['DOCTORATE', 'Doctorate'],
  ['OTHER', 'Other / prefer to describe below'],
];

const STATUS_LABEL = {
  pending: 'Pending review',
  recommended: 'Recommended to Admin',
  approved: 'Approved',
  rejected: 'Not accepted',
};

function formatDate(iso) {
  return esc((iso || '').slice(0, 10));
}

// ---------- "Join the Team" info page + form (User role) ----------

export async function renderJoinTeamView(main) {
  const { data: { user } } = await sb.auth.getUser();

  const existing = await withStatus(sb.from('collaboration_applications')
    .select('*').eq('user_id', user.id).order('created_at', { ascending: false }).limit(1));
  const active = existing.find(r => r.status === 'pending' || r.status === 'recommended');

  main.innerHTML = `
    <div class="panel">
      <h2>Join the Team</h2>
      <p>The Focolare Urdu Archive is entirely kept up by volunteers - correcting texts, translating,
      cross-checking sources, and putting together collections for future generations. If you'd like
      to help, here's what it involves and how to apply.</p>

      <h3>What collaborators do</h3>
      <ul>
        <li>Correct and proofread transcribed texts against the original documents</li>
        <li>Translate material between Italian, English and Urdu</li>
        <li>Cross-check texts and dates against other sources</li>
        <li>Prepare thematic collections from the archive</li>
      </ul>

      <h3>What to expect</h3>
      <p class="hint">Collaborating means becoming an Operator: you'll be able to create and edit
      catalogue entries and upload files. There's no fixed schedule or minimum commitment - you pick
      up tasks that fit your time and interests. Applications are reviewed by a coordinator and
      approved by an administrator before your account is upgraded.</p>

      <div id="jointeam-body"></div>
    </div>`;

  const body = document.getElementById('jointeam-body');

  if (active) {
    body.innerHTML = `
      <div class="empty-msg">
        You already have a request <b>${esc(STATUS_LABEL[active.status] || active.status)}</b>
        (sent ${formatDate(active.created_at)}). We'll get back to you - no need to send another one.
      </div>`;
    return;
  }
  if (existing.length && existing[0].status === 'rejected') {
    body.innerHTML = `<p class="hint">Your previous request wasn't accepted${existing[0].coordinator_note ? ': ' + esc(existing[0].coordinator_note) : '.'} You're welcome to apply again below.</p>`;
  }

  body.innerHTML += `
    <div class="subpanel">
      <h3>Tell us about you</h3>
      <p class="hint" style="margin-top:-4px;">Please share with us your experience and capabilities by filling this form.</p>
      <div class="field-grid wide">
        <div class="field"><label>Academic level</label>
          <select id="jt-academic">${ACADEMIC_LEVELS.map(([c, l]) => `<option value="${c}">${l}</option>`).join('')}</select>
        </div>
        <div class="field"><label>Availability <span class="hint">(optional)</span></label>
          <input id="jt-availability" type="text" placeholder="e.g. a few hours a week, weekends only..."></div>
        <div class="field" style="grid-column:1/-1;"><label>Relevant experience</label>
          <textarea id="jt-experience" rows="2" placeholder="Translation, editing, archival work, languages you speak..."></textarea>
        </div>
        <div class="field" style="grid-column:1/-1;"><label>Skills</label>
          <div class="skill-chips">${(State.optionListsByName.collaboration_skill || []).map(([code, label]) => `
            <label class="skill-chip"><input type="checkbox" class="jt-skill-check" value="${esc(label)}"> ${esc(label)}</label>`).join('') || '<span class="hint">No skills defined yet - ask an Admin to add some from Options.</span>'}
            <label class="skill-chip skill-chip-other">
              <input type="checkbox" id="jt-skill-other-check">Other
              <input type="text" id="jt-skill-other-text" placeholder="please specify" disabled>
            </label>
          </div>
        </div>
        <div class="field" style="grid-column:1/-1;"><label>Why do you like to be part of our team?</label>
          <textarea id="jt-motivation" rows="3"></textarea>
        </div>
      </div>
    </div>
    <div class="btn-row"><button class="btn" id="jt-submit-btn">Submit Request</button></div>`;

  body.querySelectorAll('.jt-skill-check').forEach(cb => cb.addEventListener('change', () => {
    cb.closest('.skill-chip').classList.toggle('checked', cb.checked);
  }));
  const otherCheck = document.getElementById('jt-skill-other-check');
  const otherText = document.getElementById('jt-skill-other-text');
  otherCheck.addEventListener('change', () => {
    otherCheck.closest('.skill-chip').classList.toggle('checked', otherCheck.checked);
    otherText.disabled = !otherCheck.checked;
    if (!otherCheck.checked) otherText.value = '';
  });

  document.getElementById('jt-submit-btn').addEventListener('click', async () => {
    const motivation = document.getElementById('jt-motivation').value.trim();
    if (!motivation) { alert('Please tell us why you\'d like to join - it\'s the field reviewers read first.'); return; }
    const skillLabels = Array.from(document.querySelectorAll('.jt-skill-check:checked')).map(cb => cb.value);
    if (otherCheck.checked && otherText.value.trim()) skillLabels.push(otherText.value.trim());
    const academic_level = document.getElementById('jt-academic').value;
    const experience = document.getElementById('jt-experience').value.trim() || null;
    const skills = skillLabels.join(', ') || null;
    const availability = document.getElementById('jt-availability').value.trim() || null;
    await withStatus(sb.from('collaboration_applications').insert({
      user_id: user.id, user_email: user.email,
      academic_level, experience, skills, motivation, availability,
    }), 'Sending your request...');
    // Mirrors the same answers onto user_profiles so they stay editable afterwards from
    // "My Profile" (profile.js), independent of how the application itself gets reviewed.
    await withStatus(sb.from('user_profiles').update({
      academic_level, experience, skills, motivation, availability,
      profile_updated_at: new Date().toISOString(),
    }).eq('user_id', user.id), 'Saving...');
    await renderJoinTeamView(main);
  });
}

// ---------- Review queue (Coordinator + Admin) ----------

export async function renderApplicationsView(main) {
  if (!canReviewApplications()) { main.innerHTML = '<div class="empty-msg">Coordinator or Admin access required.</div>'; return; }
  main.innerHTML = `
    <div class="panel">
      <h2>Team Applications</h2>
      <p class="hint">${isAdmin()
        ? 'Coordinators recommend candidates here; approving promotes them to Operator directly.'
        : 'Review requests and recommend candidates to an Admin - only an Admin can give final approval.'}</p>
      <div class="field-grid">
        <div class="field"><label>Status</label>
          <select id="apps-filter-status">
            <option value="">All open (pending + recommended)</option>
            <option value="pending">Pending review</option>
            <option value="recommended">Recommended to Admin</option>
            <option value="approved">Approved</option>
            <option value="rejected">Not accepted</option>
          </select>
        </div>
      </div>
      <div id="apps-list"></div>
    </div>`;
  document.getElementById('apps-filter-status').addEventListener('change', refreshApplications);
  await refreshApplications();
}

async function refreshApplications() {
  const statusFilter = document.getElementById('apps-filter-status').value;
  let query = sb.from('collaboration_applications').select('*').order('created_at', { ascending: false });
  query = statusFilter ? query.eq('status', statusFilter) : query.in('status', ['pending', 'recommended']);
  const rows = await withStatus(query);

  const list = document.getElementById('apps-list');
  if (!rows.length) { list.innerHTML = '<div class="empty-msg">No applications match this filter.</div>'; return; }
  const nameMap = await nameMapForEmails(rows.map(r => r.user_email));

  list.innerHTML = rows.map(r => `
    <div class="panel" data-id="${r.id}" style="margin-bottom:12px;">
      <div class="chat-meta"><b>${esc(nameMap[r.user_email] || r.user_email)}</b> · ${formatDate(r.created_at)} · <span class="chat-tag">${esc(STATUS_LABEL[r.status] || r.status)}</span></div>
      <p><b>Academic level:</b> ${esc(ACADEMIC_LEVELS.find(([c]) => c === r.academic_level)?.[1] || r.academic_level || '—')}</p>
      ${r.experience ? `<p><b>Experience:</b> ${esc(r.experience)}</p>` : ''}
      ${r.skills ? `<p><b>Skills:</b> ${esc(r.skills)}</p>` : ''}
      <p><b>Motivation:</b> ${esc(r.motivation)}</p>
      ${r.availability ? `<p><b>Availability:</b> ${esc(r.availability)}</p>` : ''}
      ${r.coordinator_note ? `<p class="hint"><b>Note:</b> ${esc(r.coordinator_note)}</p>` : ''}
      ${(r.status === 'pending' || r.status === 'recommended') ? `
        <div class="field"><label>Note <span class="hint">(optional, shown to the applicant if not accepted)</span></label>
          <textarea class="apps-note-input" rows="2">${esc(r.coordinator_note)}</textarea></div>
        <div class="btn-row">
          ${r.status === 'pending' ? '<button class="btn apps-recommend-btn" style="padding:4px 10px;">Recommend to Admin</button>' : ''}
          ${isAdmin() ? '<button class="btn apps-approve-btn" style="padding:4px 10px;">Approve &amp; Promote to Operator</button>' : ''}
          <button class="btn danger apps-reject-btn" style="padding:4px 10px;">Not accepted</button>
        </div>` : ''}
    </div>`).join('');

  list.querySelectorAll('[data-id]').forEach(card => {
    const id = card.dataset.id;
    const note = () => card.querySelector('.apps-note-input')?.value.trim() || null;
    card.querySelector('.apps-recommend-btn')?.addEventListener('click', async () => {
      await withStatus(sb.from('collaboration_applications').update({
        status: 'recommended', coordinator_note: note(),
      }).eq('id', id), 'Recommending...');
      await refreshApplications();
    });
    card.querySelector('.apps-reject-btn')?.addEventListener('click', async () => {
      if (!confirm('Mark this application as not accepted?')) return;
      await withStatus(sb.from('collaboration_applications').update({
        status: 'rejected', coordinator_note: note(),
      }).eq('id', id), 'Updating...');
      await refreshApplications();
    });
    card.querySelector('.apps-approve-btn')?.addEventListener('click', async () => {
      const row = { id };
      const emailMatch = card.querySelector('.chat-meta b')?.textContent;
      if (!confirm(`Approve and promote ${emailMatch} to Operator?`)) return;
      const { data: { user } } = await sb.auth.getUser();
      const [app] = await withStatus(sb.from('collaboration_applications').select('user_id').eq('id', id));
      await withStatus(sb.from('user_roles').update({ role: 'operator' }).eq('user_id', app.user_id), 'Promoting...');
      await withStatus(sb.from('collaboration_applications').update({
        status: 'approved', reviewed_by_email: user.email, reviewed_at: new Date().toISOString(), coordinator_note: note(),
      }).eq('id', id), 'Approving...');
      await refreshApplications();
    });
  });
}
