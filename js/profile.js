// "My Profile" - every signed-in account (any role) can see their own name/email/role/
// qualifications (read-only, managed by Admin elsewhere) and edit the same
// experience/skills/motivation fields first collected by "Join the Team" (collaboration.js) -
// these live on user_profiles so they stay editable long after the original application was
// reviewed. Deliberately does not import from collaboration.js (project convention: modules
// only import from core.js), so the skill-chip rendering is duplicated here in small form.

import { sb, State, esc, withStatus, labelOf, optionsHtml, logEntriesHtml, dateOfBirthFieldsHtml, readDateOfBirth, displayLogin, PHONE_LOGIN_DOMAIN, TEXT_SIZES, COLOUR_CHOICES, displayPrefs, saveDisplayPrefs } from './core.js?v=20261124162602';

const ACADEMIC_LEVELS = [
  ['HIGH_SCHOOL', 'High school'],
  ['BACHELOR', "Bachelor's degree"],
  ['MASTER', "Master's degree"],
  ['DOCTORATE', 'Doctorate'],
  ['OTHER', 'Other / prefer to describe below'],
];

const GENDER_OPTIONS = [['M', 'Male'], ['F', 'Female']];

const ROLE_LABEL = { user: 'User', operator: 'Operator', coordinator: 'Coordinator', admin: 'Admin' };

let editing = false;

export async function renderMyProfileView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  const { data: { user } } = await sb.auth.getUser();
  const [roleRows, profileRows, qualRows, certRows, reservedAccess, birthRows] = await Promise.all([
    withStatus(sb.from('user_roles').select('role').eq('user_id', user.id)),
    withStatus(sb.from('user_profiles').select('*').eq('user_id', user.id)),
    withStatus(sb.from('user_qualifications').select('qualification_code').eq('user_id', user.id)),
    withStatus(sb.from('formation_certificates').select('*, formation_paths(title)').eq('user_id', user.id).order('issued_at', { ascending: false })),
    withStatus(sb.rpc('has_reserved_access')),
    withStatus(sb.from('user_birth_dates').select('date_of_birth').eq('user_id', user.id)),
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
      <div class="profile-who">
        <div class="profile-name" dir="auto">${esc(profile.full_name) || '—'}</div>
        <div class="profile-login">${esc(displayLogin(user.email))}</div>
        <button class="btn big-btn" id="profile-signout">Sign out</button>
      </div>
      ${role === 'user' ? '' : `<div class="field-grid wide" style="margin-bottom:16px;">
        <div class="field"><label>Role</label><div style="font-size:16px;padding:4px 0;">${esc(ROLE_LABEL[role] || role)}</div></div>
        <div class="field"><label>Qualifications</label><div style="font-size:16px;padding:4px 0;">${myQualLabels.map(esc).join(', ') || '—'}</div></div>
        ${reservedAccess ? '<div class="field"><label>Reserved documents</label><div style="font-size:16px;padding:4px 0;">You can read them</div></div>' : ''}
      </div>`}
      <div class="subpanel" id="profile-display"></div>
      <div id="profile-thanks"></div>
      <details class="subpanel profile-section"><summary>Personal details</summary><div id="profile-demographics"></div></details>
      ${role === 'operator' ? '<details class="subpanel profile-section"><summary>Experience and availability</summary><div id="profile-editable"></div></details>' : ''}
      <details class="subpanel profile-section"><summary>Change my password</summary>
        <div class="field-grid wide">
          <div class="field"><label>New password</label><input id="pw-new" type="password" autocomplete="new-password"></div>
          <div class="field"><label>Confirm new password</label><input id="pw-confirm" type="password" autocomplete="new-password"></div>
        </div>
        <div class="btn-row"><button class="btn" id="pw-save-btn">Update Password</button></div>
        <div id="pw-status" class="hint"></div>
      </details>
      <details class="subpanel profile-section" id="profile-activity">
        <summary>My activity in the archive</summary>
        <div id="profile-activity-body" style="margin-top:8px;"><div class="hint">Loading...</div></div>
      </details>
    </div>`;

  // Sign out is also in the top bar, which on a phone is easy to miss (owner's report 2026-10-27);
  // this clicks that same button so there is one sign-out routine (core.js), not two.
  document.getElementById('profile-signout').addEventListener('click', () => document.getElementById('logout-btn').click());
  renderDisplayChoices(document.getElementById('profile-display'));
  renderThanksBox(document.getElementById('profile-thanks'), certRows);
  renderDemographics(document.getElementById('profile-demographics'), profile, birthRows[0]?.date_of_birth || '', main);
  if (role === 'operator') {
    renderEditable(document.getElementById('profile-editable'), profile, skillList, storedSkills, otherSkills, user.id, main);
  }
  wireChangePassword();
  const activityBox = document.getElementById('profile-activity');
  activityBox.addEventListener('toggle', async () => {
    if (!activityBox.open) return;
    const rows = await withStatus(sb.rpc('get_person_activity', { p_user_id: user.id }));
    document.getElementById('profile-activity-body').innerHTML = logEntriesHtml(rows, false);
  });
}

// Date of birth (120_date_of_birth.sql, its own protected table) + gender: collected at signup, but older accounts
// don't have them - self-editable here (any role, unlike the operator-only section below) so people can fill them
// in themselves instead of HR having to chase everyone individually.
async function renderDemographics(box, profile, dateOfBirth, main) {
  const ageBracketList = State.optionListsByName.age_bracket || [];
  const code = dateOfBirth ? await withStatus(sb.rpc('age_bracket_of', { p_dob: dateOfBirth })) : profile.age_bracket;
  const groupLabel = code ? labelOf(ageBracketList, code) || code : '';
  box.innerHTML = `
    <h3>Personal details</h3>
    <p class="hint">Only you, the HR lead and Admins can see your date of birth. A few people on the team see only your age group, for statistics and to prepare formation.</p>
    <div class="field-grid wide">
      <div class="field"><label>Date of birth</label>${dateOfBirthFieldsHtml('pf-dob', dateOfBirth)}${groupLabel ? `<div class="hint">Your age group: ${esc(groupLabel)}${dateOfBirth ? '' : ' (as you declared it)'}</div>` : ''}<div id="pf-dob-error" class="dob-error"></div></div>
      <div class="field"><label>Gender</label><select id="pf-gender">${optionsHtml(GENDER_OPTIONS, profile.gender, true)}</select></div>
    </div>
    <div class="btn-row"><button class="btn secondary" id="pf-demographics-save">Save</button></div>`;
  document.getElementById('pf-demographics-save').addEventListener('click', async () => {
    const dob = readDateOfBirth('pf-dob');
    document.getElementById('pf-dob-error').textContent = dob.error || '';
    if (dob.error) return;
    if ((dob.value || '') !== dateOfBirth) await withStatus(sb.rpc('set_date_of_birth', { p_date: dob.value }), 'Saving...');
    await withStatus(sb.from('user_profiles').update({
      gender: document.getElementById('pf-gender').value || null,
      profile_updated_at: new Date().toISOString(),
    }).eq('user_id', profile.user_id), 'Saving...');
    await renderMyProfileView(main);
  });
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
        <div class="field"><label>Academic level</label><div style="font-size:16px;padding:4px 0;">${esc(labelOf(ACADEMIC_LEVELS, profile.academic_level)) || '—'}</div></div>
        <div class="field"><label>Availability</label><div style="font-size:16px;padding:4px 0;">${esc(profile.availability) || '—'}</div></div>
        <div class="field" style="grid-column:1/-1;"><label>Relevant experience</label><div style="font-size:16px;padding:4px 0;white-space:pre-wrap;">${esc(profile.experience) || '—'}</div></div>
        <div class="field" style="grid-column:1/-1;"><label>Skills</label><div style="font-size:16px;padding:4px 0;">${storedSkills.map(esc).join(', ') || '—'}</div></div>
        <div class="field" style="grid-column:1/-1;"><label>Why do you like to be part of our team?</label><div style="font-size:16px;padding:4px 0;white-space:pre-wrap;">${esc(profile.motivation) || '—'}</div></div>
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

// Text size and colours on this device (core.js displayPrefs): the change shows at once, and stays on this phone.
function renderDisplayChoices(box) {
  const p = displayPrefs();
  const choice = (group, [key, label]) => `<button type="button" class="btn ${p[group] === key ? '' : 'secondary'} display-choice" data-group="${group}" data-key="${key}" aria-pressed="${p[group] === key}">${esc(label)}</button>`;
  box.innerHTML = `
    <h3>Text and colours on this device</h3>
    <label>Text size</label>
    <div class="btn-row display-choices">${TEXT_SIZES.map(s => choice('size', s)).join('')}</div>
    <label>Colours</label>
    <div class="btn-row display-choices">${COLOUR_CHOICES.map(c => choice('colours', c)).join('')}</div>`;
  box.querySelectorAll('.display-choice').forEach(b => b.addEventListener('click', () => {
    saveDisplayPrefs({ [b.dataset.group]: b.dataset.key });
    renderDisplayChoices(box);
  }));
}

// ---------- Tokens of appreciation (docs/TOKEN_POLICY.md, migrations 127-128) ----------
// What this person gave outside tasks, what it has done, and their certificates. Never money.
const TOKEN_KINDS = { proposal: 'Proposal', reading: 'Reading aloud', report: 'Useful report', titles: 'Urdu titles reviewed' };
const TOKEN_UNITS = { page: ['page', 'pages'], minute: ['minute', 'minutes'], unit: ['unit', 'units'] };

// Since 2026-11-23 (Owner's request) in My Profile: one box with the tokens and every certificate, those of the tokens
// and those of the formation paths. Shown only to someone who has one of them.
async function renderThanksBox(box, pathCertificates) {
  if (!box) return;
  const { data: t, error } = await sb.rpc('my_tokens');
  const entries = (!error && t && t.entries) || [];
  const certificates = (!error && t && t.certificates) || [];
  if (!entries.length && !certificates.length && !pathCertificates.length) { box.innerHTML = ''; return; }
  if (!entries.length && !certificates.length) {
    box.innerHTML = `<div class="subpanel thanks-box"><h3>Certificates</h3>${pathCertificatesHtml(pathCertificates)}</div>`;
    return;
  }
  const size = e => `${e.units} ${TOKEN_UNITS[e.unit][e.units === 1 ? 0 : 1]}`;
  box.innerHTML = `
    <div class="subpanel thanks-box">
      <h3>Tokens of appreciation and certificates <span class="count-badge">${esc(t.total)} tokens</span></h3>
      <p class="hint">A thank-you for what you give the archive outside tasks. They are a sign of gratitude, never money.${t.waiting ? ` ${t.waiting === 1 ? 'One of your gifts is' : esc(t.waiting) + ' of your gifts are'} waiting to be counted.` : ''}${t.next_milestone ? ` ${esc(t.next_milestone - t.total)} more to your next certificate.` : ''}</p>
      ${t.encouragement ? `<div class="note" dir="auto" style="margin:8px 0;">${esc(t.encouragement)}</div>` : ''}
      ${t.minor ? '' : `<label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:13px;margin:8px 0;">
        <input type="checkbox" id="tok-consent" ${t.consent ? 'checked' : ''} style="width:auto;"> Thank me by name in the monthly thanks, in the app and in Hayat</label>`}
      ${pathCertificatesHtml(pathCertificates)}
      ${certificates.length ? `<h3>Your certificates</h3>${certificates.map((c, i) => `
        <div class="dash-card"><div class="dash-card-title">Certificate of appreciation — ${esc(c.milestone)} tokens</div>
          <div class="dash-card-meta">${esc((c.issued_at || '').slice(0, 10))} &middot; code ${esc(c.code)}</div>
          <div class="btn-row" style="margin:6px 0 0;"><button class="btn secondary tok-print" data-i="${i}">Print</button></div></div>`).join('')}` : ''}
      <details class="profile-section thanks-gave"><summary>What you gave</summary>
      <div class="help-list">${entries.map(e => `
        <div class="dash-card">
          <div class="dash-card-title" dir="auto">${e.document_id ? `#${esc(e.document_id)} ${esc(e.title) || ''}` : esc(TOKEN_KINDS[e.kind] || e.kind)}</div>
          <div class="dash-card-meta">${esc(TOKEN_KINDS[e.kind] || e.kind)} &middot; ${esc(size(e))} &middot; ${e.annulled ? 'annulled' : (e.tokens == null ? 'waiting' : `${esc(e.tokens)} tokens`)}${e.listens != null ? ` &middot; listened ${esc(e.listens)} ${Number(e.listens) === 1 ? 'time' : 'times'}` : ''}${e.opens != null ? ` &middot; opened ${esc(e.opens)} ${Number(e.opens) === 1 ? 'time' : 'times'}` : ''}${e.past ? ' &middot; before tokens existed' : ''}</div>
          ${e.annulled && e.annul_note ? `<div class="hint">${esc(e.annul_note)}</div>` : ''}
          ${e.note && !e.document_id ? `<div class="hint">${esc(e.note)}</div>` : ''}
        </div>`).join('')}</div>
      </details>
    </div>`;
  box.querySelectorAll('.tok-print').forEach(b => b.addEventListener('click', () => printCertificate(certificates[Number(b.dataset.i)], t.name)));
  document.getElementById('tok-consent')?.addEventListener('change', async e => {
    const { error } = await sb.rpc('set_token_thanks_consent', { p_consent: e.target.checked });
    if (error) { alert(error.message); e.target.checked = !e.target.checked; }
  });
}

// The certificate on its own page, ready to print or to save as PDF from the print dialog.
function printCertificate(c, name) {
  const w = window.open('', '_blank');
  if (!w) { alert('Please allow this page to open a new window, then press Print again.'); return; }
  w.document.write(`<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Certificate of appreciation</title>
    <style>body{font-family:Georgia,serif;margin:0;padding:40px;color:#222;text-align:center}
    .c{border:3px double #8a5a1f;padding:48px 32px;max-width:640px;margin:0 auto}
    h1{font-size:30px;margin:0 0 24px;color:#8a5a1f}.n{font-size:26px;margin:16px 0}.s{font-size:18px;line-height:1.6;margin:24px 0}
    .f{margin-top:40px;font-size:15px}.k{margin-top:24px;font-size:12px;color:#666}@media print{button{display:none}}</style></head>
    <body><div class="c"><h1>Certificate of appreciation</h1><div>Digital Urdu Archive</div>
    <div class="n" dir="auto">${esc(name || '')}</div>
    <div class="s" dir="auto">${esc(c.sentence)}</div>
    <div>${esc(c.milestone)} tokens of appreciation</div>
    <div class="f">${esc(c.signer)}<br>${esc((c.issued_at || '').slice(0, 10))}</div>
    <div class="k">Code ${esc(c.code)}</div></div>
    <p><button onclick="print()">Print</button></p></body></html>`);
  w.document.close();
}

// The certificates of the formation paths (formation_certificates), one line each.
function pathCertificatesHtml(rows) {
  if (!rows.length) return '';
  return `<div class="thanks-path-certs">${rows.map(c => `<div class="thanks-cert">&#127891; <span dir="auto">${esc(c.formation_paths?.title) || 'Formation path'}</span> <span class="hint">&middot; ${esc((c.issued_at || '').slice(0, 10))} &middot; code ${esc(c.certificate_code)}</span></div>`).join('')}</div>`;
}
