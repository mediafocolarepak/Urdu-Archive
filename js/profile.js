// "My Profile" - every signed-in account (any role) can see their own name/email/role/
// qualifications (read-only, managed by Admin elsewhere) and edit the same
// experience/skills/motivation fields first collected by "Join the Team" (collaboration.js) -
// these live on user_profiles so they stay editable long after the original application was
// reviewed. Deliberately does not import from collaboration.js (project convention: modules
// only import from core.js), so the skill-chip rendering is duplicated here in small form.

import { sb, State, esc, withStatus, labelOf } from './core.js?v=20260902165344';

const ACADEMIC_LEVELS = [
  ['HIGH_SCHOOL', 'High school'],
  ['BACHELOR', "Bachelor's degree"],
  ['MASTER', "Master's degree"],
  ['DOCTORATE', 'Doctorate'],
  ['OTHER', 'Other / prefer to describe below'],
];

const ROLE_LABEL = { user: 'User', operator: 'Operator', coordinator: 'Coordinator', admin: 'Admin' };

let editing = false;

export async function renderMyProfileView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  const { data: { user } } = await sb.auth.getUser();
  const [roleRows, profileRows, qualRows] = await Promise.all([
    withStatus(sb.from('user_roles').select('role').eq('user_id', user.id)),
    withStatus(sb.from('user_profiles').select('*').eq('user_id', user.id)),
    withStatus(sb.from('user_qualifications').select('qualification_code').eq('user_id', user.id)),
  ]);
  const role = roleRows[0]?.role || 'user';
  const profile = profileRows[0] || {};
  const qualList = State.optionListsByName.operator_qualification || [];
  const myQualLabels = qualRows.map(q => labelOf(qualList, q.qualification_code)).filter(Boolean);
  const skillList = State.optionListsByName.collaboration_skill || [];
  const storedSkills = (profile.skills || '').split(',').map(s => s.trim()).filter(Boolean);
  const knownLabels = new Set(skillList.map(([, label]) => label));
  const otherSkills = storedSkills.filter(s => !knownLabels.has(s));

  main.innerHTML = `
    <div class="panel" style="max-width:780px;margin:0 auto;">
      <h2>My Profile</h2>
      <div class="field-grid wide" style="margin-bottom:16px;">
        <div class="field"><label>Full name</label><div style="font-size:13.5px;padding:4px 0;">${esc(profile.full_name) || '—'}</div></div>
        <div class="field"><label>Email</label><div style="font-size:13.5px;padding:4px 0;">${esc(user.email)}</div></div>
        <div class="field"><label>Role</label><div style="font-size:13.5px;padding:4px 0;">${esc(ROLE_LABEL[role] || role)}</div></div>
        <div class="field"><label>Qualifications</label><div style="font-size:13.5px;padding:4px 0;">${myQualLabels.map(esc).join(', ') || '—'}</div></div>
      </div>
      ${role === 'operator' ? '<div class="subpanel" id="profile-editable"></div>' : ''}
      <div class="subpanel" style="margin-top:16px;">
        <h3>Change my password</h3>
        <div class="field-grid wide">
          <div class="field"><label>New password</label><input id="pw-new" type="password" autocomplete="new-password"></div>
          <div class="field"><label>Confirm new password</label><input id="pw-confirm" type="password" autocomplete="new-password"></div>
        </div>
        <div class="btn-row"><button class="btn" id="pw-save-btn">Update Password</button></div>
        <div id="pw-status" class="hint"></div>
      </div>
    </div>`;

  if (role === 'operator') {
    renderEditable(document.getElementById('profile-editable'), profile, skillList, storedSkills, otherSkills, user.id, main);
  }
  wireChangePassword();
}

function wireChangePassword() {
  document.getElementById('pw-save-btn').addEventListener('click', async () => {
    const status = document.getElementById('pw-status');
    const pw = document.getElementById('pw-new').value;
    const pw2 = document.getElementById('pw-confirm').value;
    status.style.color = 'var(--danger)'; status.textContent = '';
    if (pw.length < 6) { status.textContent = 'Password must be at least 6 characters.'; return; }
    if (pw !== pw2) { status.textContent = 'Passwords do not match.'; return; }
    const { error } = await sb.auth.updateUser({ password: pw });
    if (error) { status.textContent = error.message; return; }
    status.style.color = 'var(--accent)';
    status.textContent = 'Password updated.';
    document.getElementById('pw-new').value = '';
    document.getElementById('pw-confirm').value = '';
  });
}

function renderEditable(box, profile, skillList, storedSkills, otherSkills, userId, main) {
  if (!editing) {
    box.innerHTML = `
      <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 10px;">
        <h3 style="margin:0;">Your experience &amp; availability</h3>
        <button class="btn secondary" id="profile-edit-btn">Edit</button>
      </div>
      <div class="field-grid wide">
        <div class="field"><label>Academic level</label><div style="font-size:13.5px;padding:4px 0;">${esc(labelOf(ACADEMIC_LEVELS, profile.academic_level)) || '—'}</div></div>
        <div class="field"><label>Availability</label><div style="font-size:13.5px;padding:4px 0;">${esc(profile.availability) || '—'}</div></div>
        <div class="field" style="grid-column:1/-1;"><label>Relevant experience</label><div style="font-size:13.5px;padding:4px 0;white-space:pre-wrap;">${esc(profile.experience) || '—'}</div></div>
        <div class="field" style="grid-column:1/-1;"><label>Skills</label><div style="font-size:13.5px;padding:4px 0;">${storedSkills.map(esc).join(', ') || '—'}</div></div>
        <div class="field" style="grid-column:1/-1;"><label>Why do you like to be part of our team?</label><div style="font-size:13.5px;padding:4px 0;white-space:pre-wrap;">${esc(profile.motivation) || '—'}</div></div>
      </div>`;
    document.getElementById('profile-edit-btn').addEventListener('click', () => { editing = true; renderEditable(box, profile, skillList, storedSkills, otherSkills, userId, main); });
    return;
  }

  box.innerHTML = `
    <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 10px;">
      <h3 style="margin:0;">Your experience &amp; availability</h3>
      <div><button class="btn secondary" id="profile-cancel-btn">Cancel</button> <button class="btn" id="profile-save-btn">Save</button></div>
    </div>
    <div class="field-grid wide">
      <div class="field"><label>Academic level</label>
        <select id="pf-academic">${ACADEMIC_LEVELS.map(([c, l]) => `<option value="${c}" ${c === profile.academic_level ? 'selected' : ''}>${l}</option>`).join('')}</select>
      </div>
      <div class="field"><label>Availability <span class="hint">(optional)</span></label>
        <input id="pf-availability" type="text" value="${esc(profile.availability)}" placeholder="e.g. a few hours a week, weekends only..."></div>
      <div class="field" style="grid-column:1/-1;"><label>Relevant experience</label>
        <textarea id="pf-experience" rows="2" placeholder="Translation, editing, archival work, languages you speak...">${esc(profile.experience)}</textarea>
      </div>
      <div class="field" style="grid-column:1/-1;"><label>Skills</label>
        <div class="skill-chips">${skillList.map(([code, label]) => `
          <label class="skill-chip${storedSkills.includes(label) ? ' checked' : ''}"><input type="checkbox" class="pf-skill-check" value="${esc(label)}" ${storedSkills.includes(label) ? 'checked' : ''}> ${esc(label)}</label>`).join('')}
          <label class="skill-chip skill-chip-other${otherSkills.length ? ' checked' : ''}">
            <input type="checkbox" id="pf-skill-other-check" ${otherSkills.length ? 'checked' : ''}>Other
            <input type="text" id="pf-skill-other-text" placeholder="please specify" value="${esc(otherSkills.join(', '))}" ${otherSkills.length ? '' : 'disabled'}>
          </label>
        </div>
      </div>
      <div class="field" style="grid-column:1/-1;"><label>Why do you like to be part of our team?</label>
        <textarea id="pf-motivation" rows="3">${esc(profile.motivation)}</textarea>
      </div>
    </div>`;

  box.querySelectorAll('.pf-skill-check').forEach(cb => cb.addEventListener('change', () => {
    cb.closest('.skill-chip').classList.toggle('checked', cb.checked);
  }));
  const otherCheck = document.getElementById('pf-skill-other-check');
  const otherText = document.getElementById('pf-skill-other-text');
  otherCheck.addEventListener('change', () => {
    otherCheck.closest('.skill-chip').classList.toggle('checked', otherCheck.checked);
    otherText.disabled = !otherCheck.checked;
    if (!otherCheck.checked) otherText.value = '';
  });

  document.getElementById('profile-cancel-btn').addEventListener('click', () => { editing = false; renderMyProfileView(main); });
  document.getElementById('profile-save-btn').addEventListener('click', async () => {
    const skillLabels = Array.from(box.querySelectorAll('.pf-skill-check:checked')).map(cb => cb.value);
    if (otherCheck.checked && otherText.value.trim()) skillLabels.push(otherText.value.trim());
    await withStatus(sb.from('user_profiles').update({
      academic_level: document.getElementById('pf-academic').value,
      availability: document.getElementById('pf-availability').value.trim() || null,
      experience: document.getElementById('pf-experience').value.trim() || null,
      skills: skillLabels.join(', ') || null,
      motivation: document.getElementById('pf-motivation').value.trim() || null,
      profile_updated_at: new Date().toISOString(),
    }).eq('user_id', userId), 'Saving...');
    editing = false;
    await renderMyProfileView(main);
  });
}
