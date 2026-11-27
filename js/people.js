// People (GOVERNANCE.md §6.2): HR's view of every account, from hr_people_overview(), and the decisions about people
// (people_decisions: proposed by one person, decided by another). Since phase 4 (2026-11-25): a list and, beside it, the card of
// one person, instead of a table of 16 columns; whoever decides reads what exactly they decide; people are shown by name, and a
// login only inside a person's card, under Contact (Owner's decision). The database is the real gate.

import {
  sb, State, esc, withStatus, isAdmin, isDeptMember, isDeptLead, labelOf, optionsHtml, logEntriesHtml, popupShell, errorText, displayLogin
} from './core.js?v=20261127113639';
import { st, plural, factHtml, namesByIds, decideButtons, outcomeHtml, agoText, dayText } from './deptui.js?v=20261127113639';

const ROLE_OPTIONS = [['user', 'User'], ['operator', 'Operator'], ['coordinator', 'Coordinator'], ['admin', 'Admin']];
const BOARD_TYPES = ['board_misuse', 'board_block', 'board_unblock'];
const roleLabel = r => labelOf(ROLE_OPTIONS, r) || r || '';

// Mirrors can_propose_people_decision(), only to choose what to show: the function is the real gate.
function canPropose(type) {
  if (isAdmin()) return true;
  if (['qualification_add', 'qualification_remove', 'watch_on', 'watch_off', 'suspend', 'reinstate', 'exclude'].includes(type)) return isDeptMember('HR');
  if (type === 'role_change') return isDeptLead('HR');
  if (BOARD_TYPES.includes(type)) return State.currentRole === 'coordinator' || State.myBoards.size > 0;
  return false;
}
// Mirrors can_approve_people_decision(), same.
function canApprove(type) {
  if (isAdmin()) return true;
  if (type === 'suspend' || type === 'reinstate') return isDeptLead('HR');
  if (BOARD_TYPES.includes(type)) return isDeptLead('FORM') || isDeptLead('HR');
  return false;
}
const whoDecides = type => (['suspend', 'reinstate'].includes(type) ? 'the HR lead or an Admin' : BOARD_TYPES.includes(type) ? 'the Formation lead, the HR lead or an Admin' : 'an Admin');

let decisionTypes = null; // [[code, label]], once per visit
async function loadTypes() {
  if (!decisionTypes) {
    const rows = await withStatus(sb.from('option_lists').select('code,label').eq('list_name', 'people_decision_type').order('sort_order'));
    // Until 179 has been run: the label that no longer says what happens.
    decisionTypes = rows.map(r => [r.code, r.label === 'Suspend (no new tasks)' ? 'Suspend (no work until reinstated)' : r.label]);
  }
  return decisionTypes;
}

// What is proposed, in full: not only "Change technical role", but from which role to which.
function decisionHtml(d, types, role) {
  const b = v => `<b>${esc(v)}</b>`, p = d.payload || {};
  const quals = State.optionListsByName.operator_qualification || [];
  if (d.decision_type === 'role_change') return `Change the role: ${role && d.status === 'pending' ? `from ${b(roleLabel(role))} ` : ''}to ${b(roleLabel(p.role))}`;
  if (d.decision_type === 'qualification_add') return `Add a qualification: ${b(labelOf(quals, p.qualification_code) || p.qualification_code)}`;
  if (d.decision_type === 'qualification_remove') return `Remove a qualification: ${b(labelOf(quals, p.qualification_code) || p.qualification_code)}`;
  if (d.decision_type === 'board_misuse') return `${esc(labelOf(types, d.decision_type))}: ${b(Math.abs(p.reputation_delta ?? State.policyValues.board_misuse_reputation_delta ?? 10))} points of reputation less`;
  return b(labelOf(types, d.decision_type));
}
const toneOf = type => (['suspend', 'exclude', 'board_misuse', 'board_block', 'qualification_remove'].includes(type) ? 'red' : type === 'watch_on' ? 'amber' : 'violet');

// For "Today" of HR and of Formation (the boards only): the decisions that wait. can: this person decides them.
export async function loadPeopleItems(code) {
  let rows = await withStatus(sb.from('people_decisions').select('*').eq('status', 'pending').order('proposed_at', { ascending: true }));
  if (code === 'FORM') rows = rows.filter(d => BOARD_TYPES.includes(d.decision_type));
  if (!rows.length) return [];
  const [types, people, name, { data: { user } }] = await Promise.all([
    loadTypes(),
    code === 'HR' ? loadPeople().then(p => p.byId, () => ({})) : {},
    namesByIds(rows.flatMap(d => [d.subject_user_id, d.proposed_by])),
    sb.auth.getUser(),
  ]);
  const nameOf = id => people[id]?.full_name || name(id);
  return rows.map(d => {
    const mine = d.proposed_by === user.id, can = canApprove(d.decision_type) && (!mine || isAdmin());
    const what = decisionHtml(d, types, people[d.subject_user_id]?.role);
    return {
      tone: toneOf(d.decision_type), title: nameOf(d.subject_user_id), text: what, quote: d.reason, can,
      by: `Proposed by ${mine ? 'you' : nameOf(d.proposed_by)}, ${agoText(d.proposed_at)}${can ? '' : `. Waiting for ${whoDecides(d.decision_type)}.`}`,
      buttons: decideButtons({
        mine, can, question: `${nameOf(d.subject_user_id)}: ${what.replace(/<[^>]*>/g, '').replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&#39;/g, "'")}. Approve?`,
        call: (outcome, note) => sb.rpc('decide_people_decision', { p_id: d.id, p_outcome: outcome, ...(note ? { p_note: note } : {}) }),
        approved: () => { peopleCache = null; },
      }),
    };
  });
}

// ---------- The list ----------

let peopleCache = null; // { at, rows, byId, ages }
async function loadPeople(fresh = false) {
  if (!fresh && peopleCache && Date.now() - peopleCache.at < 60000) return peopleCache;
  const [rows, brackets, births] = await Promise.all([
    withStatus(sb.rpc('hr_people_overview')),
    withStatus(sb.rpc('people_age_brackets')),
    withStatus(sb.from('user_birth_dates').select('user_id,date_of_birth')), // HR lead and Admins only (120)
  ]);
  const ages = {};
  for (const b of brackets) ages[b.user_id] = { bracket: b.age_bracket };
  for (const b of births) ages[b.user_id] = { ...ages[b.user_id], date: b.date_of_birth };
  peopleCache = { at: Date.now(), rows, ages, byId: Object.fromEntries(rows.map(r => [r.user_id, r])) };
  return peopleCache;
}

// department_code/qualification_code in a "CODE (lead)?, CODE" string: matched exactly, not as a piece of text.
const codesIn = joined => (joined || '').split(',').map(x => x.trim()).filter(Boolean);
const hasCode = (joined, code) => codesIn(joined).some(x => x.replace(/\s*\(lead\)$/, '') === code);

const personName = r => (r.full_name || '').trim() || '(no name)';
function whyAtRisk(r) {
  const under = State.policyValues.risk_reputation_below ?? 40, events = State.policyValues.risk_negative_events ?? 2, days = State.policyValues.risk_window_days ?? 60;
  return [r.reputation < under ? `reputation ${r.reputation}, under ${under}` : '', r.negative_events >= events ? `${plural(r.negative_events, 'negative event', 'negative events')} in ${days} days` : ''].filter(Boolean).join('; ');
}
function stateOf(r) {
  if (r.standing === 'suspended') return ['red', '&#9208;', 'Suspended'];
  if (r.standing === 'excluded') return ['red', '&#10005;', 'Excluded'];
  if (r.at_risk) return ['red', '&#9888;', 'At risk'];
  if (r.standing === 'watch') return ['amber', '&#9673;', 'On the watch list'];
  return ['green', '&#9679;', 'In good standing'];
}
const WHO = [['', 'Everyone'], ['team', 'The team'], ['risk', 'At risk'], ['active', 'In good standing'], ['watch', 'On the watch list'], ['suspended', 'Suspended'], ['excluded', 'Excluded']];
const ORDERS = [['name', 'Name'], ['rep_low', 'Reputation, lowest first'], ['rep_high', 'Reputation, highest first'], ['cred_high', 'Credits, highest first'], ['cred_low', 'Credits, lowest first'], ['new', 'Newest first'], ['old', 'Oldest first']];
const SORT = {
  // Whoever has no name comes last.
  name: (a, b) => (!(a.full_name || '').trim() - !(b.full_name || '').trim()) || personName(a).toLowerCase().localeCompare(personName(b).toLowerCase()),
  rep_low: (a, b) => (a.reputation ?? 0) - (b.reputation ?? 0), rep_high: (a, b) => (b.reputation ?? 0) - (a.reputation ?? 0),
  cred_low: (a, b) => (a.credits ?? 0) - (b.credits ?? 0), cred_high: (a, b) => (b.credits ?? 0) - (a.credits ?? 0),
  new: (a, b) => ((a.since || '') < (b.since || '') ? 1 : -1), old: (a, b) => ((a.since || '') < (b.since || '') ? -1 : 1),
};
const wide = () => matchMedia('(min-width: 1000px)').matches;

// open(id): the address of one person; show(id): on a computer, the same without leaving the list.
export async function renderPeopleTool(box, { id, open, show }) {
  const { rows } = await loadPeople(!id);
  await loadTypes();
  const f = State.peopleFilter;
  let chosen = id || (wide() ? State.personChosen : '') || '';
  if (chosen && !peopleCache.byId[chosen]) chosen = '';
  const depts = State.optionListsByName.department || [], quals = State.optionListsByName.operator_qualification || [];
  const more = f.department || f.role || f.qualification || f.order !== 'name';

  box.innerHTML = `
    <div class="dep-people ${id ? 'dep-one' : ''}">
      <div class="dep-people-list">
        <div class="dep-filters">
          <label class="sr-only" for="people-search">Search a name</label>
          <input id="people-search" type="search" placeholder="Search a name" value="${esc(f.search)}">
          <label class="sr-only" for="people-who">Who</label>
          <select id="people-who">${optionsHtml(WHO, f.who, false)}</select>
        </div>
        <details class="dep-more" ${more ? 'open' : ''}><summary>More options</summary>
          <div class="field"><label>Department<select id="people-department">${optionsHtml(depts, f.department, true, 'All')}</select></label></div>
          <div class="field"><label>Role<select id="people-role">${optionsHtml(ROLE_OPTIONS, f.role, true, 'All')}</select></label></div>
          <div class="field"><label>Qualification<select id="people-qualification">${optionsHtml(quals, f.qualification, true, 'All')}</select></label></div>
          <div class="field"><label>Order<select id="people-order">${optionsHtml(ORDERS, f.order, false)}</select></label></div>
        </details>
        <div class="hint" id="people-count" aria-live="polite"></div>
        <div id="people-rows"></div>
      </div>
      <div class="dep-people-card" id="people-card"></div>
    </div>`;
  const $ = x => box.querySelector('#' + x);

  const drawList = () => {
    const q = f.search.trim().toLowerCase();
    const list = rows.filter(r =>
      (!q || personName(r).toLowerCase().includes(q)) &&
      (!f.who || (f.who === 'team' ? r.role !== 'user' || !!r.departments : f.who === 'risk' ? r.at_risk : r.standing === f.who)) &&
      (!f.department || hasCode(r.departments, f.department)) && (!f.role || r.role === f.role) && (!f.qualification || hasCode(r.qualifications, f.qualification)))
      .sort(SORT[f.order] || SORT.name);
    $('people-count').textContent = plural(list.length, 'person', 'people');
    $('people-rows').innerHTML = list.map(r => `<button type="button" class="dep-person st-${stateOf(r)[0]}" data-uid="${esc(r.user_id)}" ${r.user_id === chosen ? 'aria-current="true"' : ''}>
      <span class="dep-person-name" dir="auto">${esc(personName(r))}</span><span class="hint">${esc(roleLabel(r.role))}${Number(r.pending_decisions) ? ` &middot; ${plural(r.pending_decisions, 'decision waits', 'decisions wait')}` : ''}</span>${st(...stateOf(r))}</button>`).join('') || '<div class="empty-msg">Nobody found.</div>';
    $('people-rows').querySelectorAll('[data-uid]').forEach(b => b.addEventListener('click', () => {
      if (!wide()) { open(b.dataset.uid); return; }
      chosen = State.personChosen = b.dataset.uid;
      show(chosen);
      $('people-rows').querySelectorAll('[data-uid]').forEach(x => x.toggleAttribute('aria-current', x === b));
      drawCard();
    }));
  };
  const drawCard = () => {
    const r = peopleCache.byId[chosen];
    if (!r) { $('people-card').innerHTML = '<div class="panel empty-msg">Choose a person in the list.</div>'; return; }
    renderPerson($('people-card'), r, () => renderPeopleTool(box, { id, open, show }));
  };
  for (const [el, key] of [['people-search', 'search'], ['people-who', 'who'], ['people-department', 'department'], ['people-role', 'role'], ['people-qualification', 'qualification'], ['people-order', 'order']])
    $(el).addEventListener(el === 'people-search' ? 'input' : 'change', e => { f[key] = e.target.value; drawList(); });
  drawList();
  drawCard();
}

// ---------- One person ----------

function renderPerson(box, r, again) {
  const age = peopleCache.ages[r.user_id] || {};
  const ageText = [age.bracket ? labelOf(State.optionListsByName.age_bracket || [], age.bracket) || age.bracket : '', age.date ? dayText(age.date) : ''].filter(Boolean).join(', ');
  const depts = State.optionListsByName.department || [], quals = State.optionListsByName.operator_qualification || [];
  const chip = t => `<span class="dep-chip">${esc(t)}</span>`;
  const why = r.at_risk ? whyAtRisk(r) : '';
  const state = stateOf(r);
  box.innerHTML = `
    <div class="panel dep-card st-${state[0]}">
      <h3 class="dep-card-name" dir="auto">${esc(personName(r))}</h3>
      <div>${r.at_risk && state[2] !== 'At risk' ? st(...state) + ' ' : ''}${r.at_risk ? st('red', '&#9888;', `At risk${why ? ': ' + why : ''}`) : st(...state)}</div>
      <div class="dep-chips">${chip(roleLabel(r.role))}${codesIn(r.departments).map(c => chip(`${labelOf(depts, c.replace(/\s*\(lead\)$/, ''))}${/\(lead\)$/.test(c) ? ', lead' : ''}`)).join('')}${codesIn(r.qualifications).map(c => chip(labelOf(quals, c))).join('')}</div>
      <div class="dep-facts">
        ${factHtml('Credits', r.credits ?? 0)}${factHtml('Reputation', r.reputation ?? '—')}${factHtml('Tasks in progress', r.open_tasks ?? 0)}${factHtml('Negative events', r.negative_events ?? 0)}
        ${factHtml('Account since', dayText(r.since) || '—')}${factHtml('Last event', r.last_event_type ? `${eventLabel(r.last_event_type)}${r.last_event_at ? ', ' + agoText(r.last_event_at) : ''}` : '—')}${factHtml('Age', ageText || '—')}${factHtml('Decisions waiting', r.pending_decisions ?? 0)}
      </div>
      ${isDeptMember('HR') || isAdmin() ? '<details class="dep-more" id="person-contact"><summary>Contact</summary><div id="person-login" class="hint">Loading...</div></details>' : ''}
      <div class="btn-row"><button type="button" class="btn" id="person-propose">Propose a decision</button></div>
      <details class="dep-more" id="person-history"><summary>History</summary><div class="hint">Loading...</div></details>
    </div>`;
  box.querySelector('#person-propose').addEventListener('click', () => openProposePopup(r, async () => { peopleCache = null; await again(); }));
  once(box.querySelector('#person-contact'), async out => {
    const { data, error } = await sb.rpc('person_contact', { p_user_id: r.user_id });
    const login = error ? (error.code === 'PGRST202' ? r.email : '') : data; // until 179 has been run the list brings it
    out.textContent = login ? `Login: ${displayLogin(login)}` : error ? errorText(error) : 'No login found.';
  });
  once(box.querySelector('#person-history'), out => renderHistory(out, r.user_id));
}
const once = (details, load) => details?.addEventListener('toggle', function open() {
  if (!details.open) return;
  details.removeEventListener('toggle', open);
  const out = details.lastElementChild;
  Promise.resolve(load(out)).catch(e => { out.textContent = errorText(e); });
});
const EVENTS = { review_ok: 'OK', review_ok_but: 'OK, but...', review_fail: 'Fail', admin_rejected: 'Not approved', given_up: 'Task returned', reclaimed: 'Task taken back', board_misuse: 'Misuse of a board' };
const eventLabel = t => EVENTS[t] || String(t).replace(/_/g, ' ').replace(/^./, c => c.toUpperCase());

async function renderHistory(out, uid) {
  const [decisions, types] = await Promise.all([withStatus(sb.from('people_decisions').select('*').eq('subject_user_id', uid).order('proposed_at', { ascending: false })), loadTypes()]);
  const name = await namesByIds(decisions.flatMap(d => [d.proposed_by, d.decided_by]));
  out.classList.remove('hint');
  out.innerHTML = decisions.map(d => decisionRow(d, types, name, '')).join('') || '<div class="hint">Nothing has been decided about this person.</div>';
  if (isAdmin() || isDeptLead('HR')) {
    const activity = await withStatus(sb.rpc('get_person_activity', { p_user_id: uid }));
    out.insertAdjacentHTML('beforeend', `<h4>What this person did in the archive</h4>${logEntriesHtml(activity, false)}`);
  }
}
const decisionRow = (d, types, name, who) => `<div class="dep-past-row">
  <div>${outcomeHtml(d.status)} <span class="hint">${esc(dayText(d.decided_at || d.proposed_at))}</span></div>
  <div>${who ? `<b dir="auto">${esc(who)}</b>: ` : ''}${decisionHtml(d, types, '')}</div>
  <div class="hint" dir="auto">&ldquo;${esc(d.reason)}&rdquo;</div>
  <div class="hint">Proposed by ${esc(name(d.proposed_by))}${d.decided_by && d.status !== 'withdrawn' && d.decided_by !== d.proposed_by ? `, decided by ${esc(name(d.decided_by))}` : ''}</div>
  ${d.decision_note && d.decision_note !== 'No approval required for this type.' ? `<div class="hint" dir="auto">Note: ${esc(d.decision_note)}</div>` : ''}</div>`;

// ---------- Decisions taken ----------

export async function renderDecisionsTool(box, { limit = 30 } = {}) {
  const [rows, types, people] = await Promise.all([
    withStatus(sb.from('people_decisions').select('*').neq('status', 'pending').order('decided_at', { ascending: false }).limit(limit + 1)),
    loadTypes(), loadPeople().then(p => p.byId, () => ({})),
  ]);
  const list = rows.slice(0, limit);
  const name = await namesByIds(list.flatMap(d => [d.subject_user_id, d.proposed_by, d.decided_by]));
  const nameOf = id => people[id]?.full_name || name(id);
  box.innerHTML = `<div class="panel">${list.map(d => decisionRow(d, types, nameOf, nameOf(d.subject_user_id))).join('') || '<div class="empty-msg">Nothing has been decided yet.</div>'}
    ${rows.length > limit ? '<div class="btn-row"><button type="button" class="btn secondary" id="decisions-more">Show more</button></div>' : ''}</div>`;
  box.querySelector('#decisions-more')?.addEventListener('click', () => renderDecisionsTool(box, { limit: limit + 60 }));
}

// ---------- Propose a decision ----------

function openProposePopup(row, onSaved) {
  const mine = new Set(codesIn(row.qualifications)), all = State.optionListsByName.operator_qualification || [];
  const types = decisionTypes.filter(([code]) => canPropose(code));
  const { panel, close } = popupShell('propose-decision', { label: 'Propose a decision', section: 'mydepartment' });
  panel.innerHTML = `
    <h2 style="margin-top:0;">Propose a decision</h2>
    <p><b dir="auto">${esc(personName(row))}</b></p>
    ${types.length ? `
      <div class="field"><label>What<select id="pp-type">${optionsHtml(types, types[0][0], false)}</select></label></div>
      <div id="pp-payload"></div>
      <div class="field"><label>Why? <span class="hint">(needed)</span><textarea id="pp-reason" rows="3" dir="auto"></textarea></label></div>
      <p class="hint" id="pp-who"></p>
      <div class="hint dep-error" id="pp-error" role="alert"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button type="button" class="btn secondary" id="pp-cancel">Cancel</button>
        <button type="button" class="btn" id="pp-save">Propose</button>
      </div>` : '<div class="empty-msg">You cannot propose a decision about this person.</div><div class="btn-row" style="justify-content:flex-end;"><button type="button" class="btn secondary" id="pp-cancel">Close</button></div>'}`;
  const $ = id => panel.querySelector('#' + id);
  $('pp-cancel').addEventListener('click', close);
  if (!types.length) return;

  const draw = () => {
    const type = $('pp-type').value;
    const choice = (label, id, options, empty) => (options.length ? `<div class="field"><label>${label}<select id="${id}">${optionsHtml(options, options[0][0], false)}</select></label></div>` : `<div class="hint">${empty}</div>`);
    $('pp-payload').innerHTML = type === 'qualification_add' ? choice('Qualification', 'pp-qual', all.filter(([c]) => !mine.has(c)), 'This person has all the qualifications.')
      : type === 'qualification_remove' ? choice('Qualification', 'pp-qual', all.filter(([c]) => mine.has(c)), 'This person has no qualifications.')
      : type === 'role_change' ? `<p class="hint">Now: ${esc(roleLabel(row.role))}</p>` + choice('New role', 'pp-role', ROLE_OPTIONS.filter(([c]) => c !== row.role), '') : '';
    $('pp-who').textContent = ['watch_on', 'watch_off'].includes(type) ? 'This counts at once.' : `It waits for ${whoDecides(type)}.`;
  };
  $('pp-type').addEventListener('change', draw);
  draw();
  $('pp-save').addEventListener('click', async () => {
    const type = $('pp-type').value, reason = $('pp-reason').value.trim(), err = $('pp-error');
    err.textContent = '';
    let payload = null;
    if (type.startsWith('qualification_')) {
      if (!$('pp-qual')) { err.textContent = 'There is no qualification to choose.'; return; }
      payload = { qualification_code: $('pp-qual').value };
    } else if (type === 'role_change') payload = { role: $('pp-role').value };
    if (!reason) { err.textContent = 'Please write why.'; return; }
    $('pp-save').disabled = true;
    const { error } = await sb.rpc('propose_people_decision', { p_subject: row.user_id, p_type: type, p_reason: reason, p_payload: payload });
    $('pp-save').disabled = false;
    if (error) { err.textContent = errorText(error); return; }
    close();
    await onSaved();
  });
}
