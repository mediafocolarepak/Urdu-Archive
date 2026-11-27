// "My Department" (migration 87, GOVERNANCE.md §2.7/§2.8). Since phase 4 (Owner's decisions, 2026-11-25) four tabs instead of one
// long page: Today (what waits for a decision, the state of the department, what matters now), Team and chat, Tools (one screen
// for each tool) and Rules. Each has its address: #department/HR/people. People are shown by name, never by login.
// The list of departments is driven by option_lists ('department') and department_members: departments can be added, renamed
// or retired from Options without touching this file.

import { authorNames,
  sb, State, esc, today, withStatus, isAdmin, isDeptLead, labelOf,
  nameMapForIds, DEPARTMENT_MEDIA_BUCKET, ONBOARDING_MEDIA_BUCKET, fetchActiveTranslationPrompt, canManageReserved, canReviewApplications, canReviewTeamApplications,
  helpLinkHtml, confirmPopup, promptPopup, popupShell, showLoadFailed, errorText
} from './core.js?v=20261127113639';
import { renderRules, loadRuleItems } from './policy.js?v=20261127113639';
import { renderPeopleTool, renderDecisionsTool, loadPeopleItems } from './people.js?v=20261127113639';
import { renderCredits, renderRuns, renderUnusual, renderTokens, renderThanks, renderCertificates, loadRewardItems } from './reward.js?v=20261127113639';
import { renderApplicationsView, loadApplicationItems } from './collaboration.js?v=20261127113639';
import { deptLabel, plural, st, itemHtml, wireItems, tableHtml, namesByIds, nameOnly, personSearch, agoText, dayText } from './deptui.js?v=20261127113639';

// Each department's page opens its own guide from the "?" beside the title.
const DEPT_GUIDES = { HR: 'dept-hr', COORD: 'dept-coordination', FORM: 'dept-formation', RF: 'dept-reward', COMM: 'dept-communication', ARCHIVE: 'dept-archive' };

function myDepartmentCodes() {
  if (isAdmin()) return (State.optionListsByName.department || []).map(([c]) => c);
  return State.myDepartments.map(d => d.department_code);
}

// The address of a page of a department: go('HR'), go('HR', 'people'), go('HR', 'people', id).
const go = (code, ...rest) => window.__renderTab('mydepartment', undefined, ['department', code, ...rest.filter(Boolean)].join('/'));

const TABS = [['today', 'Today', ''], ['team', 'Team', ' and chat'], ['tools', 'Tools', ''], ['rules', 'Rules', '']];

// The tools of a department: { key, name, note, draw(box, ctx) } opens its screen; { open } leaves for another section.
function toolsOf(code) {
  const section = (id, name, note) => ({ key: id, name, note, open: () => window.__renderTab(id) });
  switch (code) {
    case 'HR': return [
      { key: 'people', name: 'People', note: 'Who is on the team, and how it goes', draw: (box, c) => renderPeopleTool(box, { id: c.id, open: id => go(code, 'people', id), show: c.address }) },
      { key: 'applications', name: 'Applications', note: 'New people who want to join', draw: box => renderApplicationsView(box) },
      { key: 'decisions', name: 'Decisions taken', note: 'What was decided, by whom and why', draw: box => renderDecisionsTool(box) },
    ];
    case 'COORD': return [
      { key: 'flow', name: 'Task flow', note: 'Open, in progress, in review, late', draw: box => renderTaskFlow(box) },
      ...(canReviewApplications() ? [{ key: 'overview', name: 'Team overview', note: 'In Tasks: give a task to someone else, take it back', open: () => { State.tasksView = 'team'; window.__renderTab('tasks'); } }] : []),
    ];
    case 'RF': return [
      { key: 'credits', name: 'Credits', note: 'The budget, and the credits of the tasks', draw: renderCredits },
      { key: 'runs', name: 'Compensation runs', note: 'When credits become money', draw: renderRuns },
      { key: 'unusual', name: 'Unusual credits', note: 'What to look at with care', draw: renderUnusual },
      { key: 'tokens', name: 'Tokens', note: 'What people gave outside the tasks', draw: renderTokens },
      { key: 'thanks', name: 'Public thanks', note: 'The list for a month', draw: renderThanks },
      { key: 'certificates', name: 'Certificates', note: 'Milestones, texts, and checking a code', draw: renderCertificates },
    ];
    case 'FORM': return [
      { key: 'paths', name: 'Paths in preparation', note: 'Every path: being written, published, archived', draw: renderPaths },
      ...(canManageReserved() ? [{ key: 'reserved', name: 'Reserved documents', note: 'Who can read them', draw: renderReservedAccess }] : []),
    ];
    case 'COMM': return [{ key: 'cards', name: 'Start Here cards', note: 'What Users see in Start Here', draw: renderOnboardingCardsManager }];
    // "Archive & Data" (owner's request 2026-09-20): the cataloguing tools stay their own sections.
    case 'ARCHIVE': return [
      section('hayat', 'Hayat Index', 'Browse the original Hayat register'),
      section('matchreview', 'Match Review', 'Check and confirm the automatic matches'),
      section('workconsolidation', 'Work Consolidation', 'Bring together entries of the same document'),
      section('hayateditor', 'Hayat Editor', 'Correct an entry of the Hayat register'),
      ...(isAdmin() ? [
        section('bulkimport', 'Bulk Import', 'Add many documents from a spreadsheet'),
        { key: 'deleted', name: 'Deleted documents', note: 'See them, and restore them', draw: renderDeletedDocuments },
        { key: 'prompt', name: 'Translation prompt', note: 'What the Translate button copies', draw: renderTranslationPromptEditor },
      ] : []),
    ];
    default: return [];
  }
}

// What waits in a department: { can: to decide here, others: waiting for someone else }.
async function loadWaiting(code) {
  const open = (...rest) => go(code, ...rest);
  const parts = [loadRuleItems(code)];
  if (code === 'HR') { parts.push(loadPeopleItems('HR')); if (canReviewTeamApplications()) parts.push(loadApplicationItems(() => open('applications'))); }
  if (code === 'FORM' && (isAdmin() || isDeptLead('FORM'))) parts.push(loadPeopleItems('FORM'));
  if (code === 'COORD') parts.push(loadFlowItems(open));
  if (code === 'RF') parts.push(loadRewardItems(open));
  const done = await Promise.allSettled(parts);
  done.filter(r => r.status === 'rejected').forEach(r => console.warn('My Department, waiting:', r.reason));
  // The rules come last: they are the same for everyone, what is about a person comes first.
  const items = done.flatMap((r, i) => (i && r.status === 'fulfilled' ? r.value : [])).concat(done[0].status === 'fulfilled' ? done[0].value : []);
  return { can: items.filter(x => x.can), others: items.filter(x => !x.can), failed: done.some(r => r.status === 'rejected') };
}

let focusTab = false; // after a tab is chosen with the keyboard, it stays in focus

export async function renderMyDepartmentView(main) {
  const codes = myDepartmentCodes();
  if (!codes.length) {
    main.innerHTML = '<div class="panel"><h2>My Department</h2><div class="empty-msg">You are not in a department yet. An Admin can add you.</div></div>';
    return;
  }
  const [, askedCode, askedPage, id] = (State.sub || '').split('/');
  const known = codes.includes(askedCode);
  const code = known ? askedCode : codes.includes(State.myDeptSelected) ? State.myDeptSelected : codes[0];
  State.myDeptSelected = code;
  const tools = toolsOf(code);
  const tool = known ? tools.find(t => t.key === askedPage && t.draw) : null;
  const tab = tool ? 'tools' : known && TABS.some(([k]) => k === askedPage) ? askedPage : 'today';

  main.innerHTML = `
    <div class="panel dep-head ${tool ? 'dep-in-tool' : ''}">
      <h2>My Department ${helpLinkHtml(DEPT_GUIDES[code] || 'my-department')}</h2>
      ${codes.length > 1
        ? `<label class="sr-only" for="mydept-select">Department</label><select id="mydept-select">${codes.map(c => `<option value="${esc(c)}" ${c === code ? 'selected' : ''}>${esc(deptLabel(c))}</option>`).join('')}</select>`
        : `<span class="dep-name">${esc(deptLabel(code))}</span>`}
      <div class="dep-tabs" role="tablist" aria-label="${esc(deptLabel(code))}">
      ${TABS.map(([k, label, rest]) => `<button type="button" class="dep-tab" role="tab" id="dep-tab-${k}" data-tab-key="${k}" aria-selected="${k === tab}" tabindex="${k === tab ? 0 : -1}">${label}${rest ? `<span class="dep-long">${rest}</span>` : ''} <span class="dep-n" data-n="${k}" hidden></span></button>`).join('')}
      </div>
    </div>
    <div class="dep-body" role="tabpanel" aria-labelledby="dep-tab-${tab}">
      ${tool ? `<div class="dep-tool-head"><button type="button" class="btn secondary" id="dep-back">&lsaquo; ${tool.key === 'people' && id ? '<span class="dep-narrow">People</span><span class="dep-wide">Tools</span>' : 'Tools'}</button><h3 ${tool.key === 'people' && id ? 'class="dep-wide"' : ''}>${esc(tool.name)}</h3></div>` : ''}
      <div id="dep-main"></div>
    </div>`;

  main.querySelector('#mydept-select')?.addEventListener('change', e => go(e.target.value, tool ? 'tools' : tab === 'today' ? '' : tab));
  const tabs = [...main.querySelectorAll('.dep-tab')];
  tabs.forEach((b, i) => {
    b.addEventListener('click', () => { focusTab = document.activeElement === b; go(code, b.dataset.tabKey === 'today' ? '' : b.dataset.tabKey); });
    b.addEventListener('keydown', e => {
      const step = { ArrowRight: 1, ArrowLeft: -1 }[e.key];
      if (!step) return;
      e.preventDefault();
      focusTab = true;
      go(code, ...[TABS[(i + step + TABS.length) % TABS.length][0]].filter(k => k !== 'today'));
    });
  });
  if (focusTab) { focusTab = false; main.querySelector('.dep-tab[aria-selected="true"]').focus({ preventScroll: true }); }
  main.querySelector('#dep-back')?.addEventListener('click', () => (tool.key === 'people' && id && !matchMedia('(min-width: 1000px)').matches ? go(code, 'people') : go(code, 'tools')));

  const box = main.querySelector('#dep-main');
  const draw = async () => {
    try {
      box.innerHTML = '<div class="hint">Loading...</div>';
      if (tool) await tool.draw(box, { id, address: uid => setAddress(`department/${code}/${tool.key}/${uid}`) });
      else if (tab === 'today') await renderToday(box, code);
      else if (tab === 'team') await renderTeam(box, code);
      else if (tab === 'tools') renderTools(box, code, tools);
      else await renderRules(box, code);
    } catch (e) { if (box.isConnected) showLoadFailed(box, e, draw); }
  };
  await draw();
  await showCounts(main, code, tab);
}

// On a computer a person is chosen without leaving the list: the address follows, so reloading opens the same person.
function setAddress(sub) {
  State.sub = sub;
  history.replaceState({ ...history.state, sub }, '', '#' + sub);
}

function setCount(main, key, n, word) {
  const el = main.querySelector(`[data-n="${key}"]`);
  if (!el) return;
  el.hidden = !n;
  el.textContent = n;
  el.setAttribute('aria-label', `, ${n} ${word}`);
}
let counts = null; // { code, at, n }: not asked again at each tab
async function showCounts(main, code, tab) {
  try {
    if (tab !== 'today' && !(counts && counts.code === code && Date.now() - counts.at < 60000)) counts = { code, at: Date.now(), n: (await loadWaiting(code)).can.length };
    if (counts && counts.code === code) setCount(main, 'today', counts.n, 'to decide');
    if (tab !== 'team') setCount(main, 'team', await unseenMessages(code), 'new');
  } catch (e) { console.warn('My Department, counts:', e); }
}
async function unseenMessages(code) {
  const { data: { user } } = await sb.auth.getUser();
  const { data } = await sb.from('department_messages').select('id').eq('department_code', code).neq('user_id', user.id).gt('created_at', getDeptSeenAt(code, user.id));
  return (data || []).length;
}

// ---------- Tools ----------

function renderTools(box, code, tools) {
  box.innerHTML = tools.length ? `<div class="dep-tiles">${tools.map(t => `<button type="button" class="dep-tile" data-tool="${esc(t.key)}"><b>${esc(t.name)}</b><span class="hint">${esc(t.note)}</span></button>`).join('')}</div>`
    : '<div class="panel empty-msg">This department has no tools of its own.</div>';
  box.querySelectorAll('[data-tool]').forEach(b => b.addEventListener('click', () => { const t = tools.find(x => x.key === b.dataset.tool); if (t.open) t.open(); else go(code, t.key); }));
}

// ---------- Today ----------

async function renderToday(box, code) {
  box.innerHTML = `<div class="dep-two"><section id="dep-decide"><div class="hint">Loading...</div></section><section id="dep-status"></section></div>`;
  const decide = box.querySelector('#dep-decide'), status = box.querySelector('#dep-status');
  const drawDecide = async () => {
    const w = await loadWaiting(code);
    if (!decide.isConnected) return;
    counts = { code, at: Date.now(), n: w.can.length };
    const main = box.closest('main, #main') || document.getElementById('main');
    setCount(main, 'today', w.can.length, 'to decide');
    decide.innerHTML = `
      <h3 class="dep-h">To decide ${w.can.length ? `<span class="dep-n">${w.can.length}</span>` : ''}</h3>
      ${w.failed ? '<div class="panel load-failed"><p style="margin:0 0 10px;">A part could not be read.</p><button type="button" class="btn secondary" id="dep-again">Try again</button></div>' : ''}
      <div id="dep-can">${w.can.map(itemHtml).join('') || (w.failed ? '' : '<div class="panel work-clear"><span aria-hidden="true">&#10003;</span> Nothing waits for your decision.</div>')}</div>
      ${w.others.length ? `<details class="subpanel work-waiting" ${w.can.length ? '' : 'open'}><summary>Waiting for others <span class="count-badge">${w.others.length}</span></summary><div id="dep-others">${w.others.map(itemHtml).join('')}</div></details>` : ''}`;
    wireItems(decide.querySelector('#dep-can'), w.can, drawDecide);
    if (w.others.length) wireItems(decide.querySelector('#dep-others'), w.others, drawDecide);
    decide.querySelector('#dep-again')?.addEventListener('click', drawDecide);
  };
  const drawStatus = async () => { try { await renderDepartmentStatus(status, code); } catch (e) { if (status.isConnected) showLoadFailed(status, e, drawStatus); } };
  await Promise.all([drawDecide(), drawStatus()]);
}

// ---------- "Department Pulse" (migration 98, owner's request 2026-09-20) ----------
// A lead-managed status (on_track/slowing/stalled) and a short list of priorities, set by the lead (or Admin) and read by the
// members - deliberately by hand, not computed. The hint of migration 99 is never applied by itself (GOVERNANCE.md §5.9).

const STATUS_META = {
  on_track: { label: 'On track', tone: 'green', sign: '&#9679;', color: 'var(--st-green)' },
  slowing:  { label: 'Slowing down', tone: 'amber', sign: '&#9680;', color: 'var(--st-amber)' },
  stalled:  { label: 'Stalled', tone: 'red', sign: '&#9632;', color: 'var(--st-red)' },
};

async function renderDepartmentStatus(box, code) {
  const canManage = isAdmin() || isDeptLead(code);
  const [statusRows, priorities, suggestionRows] = await Promise.all([
    withStatus(sb.from('department_status').select('*').eq('department_code', code)),
    withStatus(sb.from('department_priorities').select('*').eq('department_code', code).order('done').order('sort_order').order('created_at')),
    sb.rpc('department_pulse_suggested_status', { p_code: code }).then(r => r.data || [], () => []),
  ]);
  const status = statusRows[0] || { status: 'on_track', note: null, updated_at: null };
  const meta = STATUS_META[status.status] || STATUS_META.on_track;
  const suggestion = suggestionRows[0] || null;
  const name = await namesByIds([status.updated_by]);
  const again = () => renderDepartmentStatus(box, code);

  box.innerHTML = `
    <div class="panel dep-state st-${meta.tone}">
      <div class="dep-state-top">${st(meta.tone, meta.sign, meta.label)}${canManage ? '<button type="button" class="btn secondary" id="dep-status-edit">Change</button>' : ''}</div>
      ${status.note ? `<p dir="auto">${esc(status.note)}</p>` : ''}
      ${status.updated_at ? `<p class="hint">${[name(status.updated_by), agoText(status.updated_at)].filter(Boolean).map(esc).join(', ')}</p>` : ''}
      ${suggestion && suggestion.suggested !== status.status ? `<p class="hint">The numbers say: <b>${esc(STATUS_META[suggestion.suggested]?.label || suggestion.suggested)}</b> (${esc(suggestion.reason)}).</p>` : ''}
    </div>
    <div class="panel">
      <h3 style="margin-top:0;">What matters now</h3>
      ${priorities.map(p => `<div class="dep-prio ${p.done ? 'dep-done' : ''}">
        <label><input type="checkbox" data-done="${p.id}" ${p.done ? 'checked' : ''} ${canManage ? '' : 'disabled'}><span dir="auto">${esc(p.title)}${p.due_date ? ` <span class="hint">until ${esc(dayText(p.due_date))}</span>` : ''}</span></label>
        ${canManage ? `<button type="button" class="btn secondary" data-delete="${p.id}" aria-label="Remove: ${esc(p.title)}">Remove</button>` : ''}
      </div>`).join('') || '<p class="hint">Nothing yet.</p>'}
      ${canManage ? `<details class="dep-more"><summary>+ Add</summary>
        <div class="field"><label>What<input id="dep-prio-title" dir="auto"></label></div>
        <div class="field"><label>Until <span class="hint">(if needed)</span><input id="dep-prio-due" type="date"></label></div>
        <div class="btn-row"><button type="button" class="btn" id="dep-prio-add">Add</button></div></details>` : ''}
    </div>`;

  if (!canManage) return;
  box.querySelector('#dep-status-edit').addEventListener('click', () => openDepartmentStatusPopup(code, status, again));
  box.querySelector('#dep-prio-add').addEventListener('click', async () => {
    const title = box.querySelector('#dep-prio-title').value.trim();
    if (!title) return;
    await withStatus(sb.from('department_priorities').insert({ department_code: code, title, due_date: box.querySelector('#dep-prio-due').value || null, sort_order: priorities.length }), 'Saving...');
    again();
  });
  box.querySelectorAll('[data-done]').forEach(cb => cb.addEventListener('change', async () => {
    await withStatus(sb.from('department_priorities').update({ done: cb.checked, done_at: cb.checked ? new Date().toISOString() : null }).eq('id', cb.dataset.done), 'Saving...');
    again();
  }));
  box.querySelectorAll('[data-delete]').forEach(btn => btn.addEventListener('click', async () => {
    if (!await confirmPopup('Remove this line?')) return;
    await withStatus(sb.from('department_priorities').delete().eq('id', btn.dataset.delete), 'Removing...');
    again();
  }));
}

function openDepartmentStatusPopup(code, current, onSaved) {
  const { panel, close } = popupShell('dept-status-popup', { label: 'How is the department doing?', section: 'mydepartment' });
  panel.innerHTML = `
    <h2 style="margin-top:0;">How is the department doing?</h2>
    <fieldset class="desk-choices"><legend class="sr-only">State</legend>
      ${Object.entries(STATUS_META).map(([k, m]) => `<label class="desk-choice st-${m.tone}"><input type="radio" name="dsp" value="${k}" ${k === current.status ? 'checked' : ''}><span><b>${esc(m.label)}</b></span></label>`).join('')}
    </fieldset>
    <div class="field"><label>Note for the team<textarea id="dsp-note" rows="3" dir="auto">${esc(current.note || '')}</textarea></label></div>
    <div class="btn-row" style="justify-content:flex-end;">
      <button type="button" class="btn secondary" id="dsp-cancel">Cancel</button>
      <button type="button" class="btn" id="dsp-save">Save</button>
    </div>`;
  panel.querySelector('#dsp-cancel').addEventListener('click', close);
  panel.querySelector('#dsp-save').addEventListener('click', async () => {
    await withStatus(sb.from('department_status').upsert({
      department_code: code, status: panel.querySelector('[name=dsp]:checked').value, note: panel.querySelector('#dsp-note').value.trim() || null, updated_at: new Date().toISOString(),
    }), 'Saving...');
    close();
    onSaved();
  });
}

// ---------- Team and chat ----------

async function renderTeam(box, code) {
  box.innerHTML = '<div class="dep-two dep-two-chat"><section id="dep-chat"></section><section id="dep-roster"></section></div>';
  const part = (el, draw) => { const run = async () => { try { await draw(el, code); } catch (e) { if (el.isConnected) showLoadFailed(el, e, run); } }; return run(); };
  await Promise.all([part(box.querySelector('#dep-chat'), renderDeptChannel), part(box.querySelector('#dep-roster'), renderRoster)]);
}

async function renderRoster(box, code) {
  const canManage = isAdmin() || isDeptLead(code);
  const members = await withStatus(sb.from('department_members').select('user_id,is_lead').eq('department_code', code));
  // Names of every member, for any member of the department (107).
  const roster = members.length ? await withStatus(sb.rpc('department_roster', { p_dept: code })).catch(() => []) : [];
  const nameOf = id => (roster.find(r => r.user_id === id)?.full_name || '').trim() || '(no name)';
  members.sort((a, b) => (b.is_lead - a.is_lead) || nameOf(a.user_id).localeCompare(nameOf(b.user_id)));
  const again = () => renderRoster(box, code);

  box.innerHTML = `
    <div class="panel">
      <h3 style="margin-top:0;">Team <span class="count-badge">${members.length}</span></h3>
      ${members.map(m => `<div class="dep-member"><span><span dir="auto">${esc(nameOf(m.user_id))}</span>${m.is_lead ? ' <span class="dep-chip">Lead</span>' : ''}</span>
        ${canManage && !m.is_lead ? `<button type="button" class="btn secondary" data-remove="${esc(m.user_id)}" aria-label="Remove ${esc(nameOf(m.user_id))}">Remove</button>` : ''}</div>`).join('') || '<p class="hint">Nobody yet.</p>'}
      ${canManage ? `<details class="dep-more"><summary>+ Add a person</summary><div id="dep-add"></div></details><p class="hint">An Admin chooses the lead, in Options.</p>` : ''}
    </div>`;
  if (!canManage) return;
  personSearch(box.querySelector('#dep-add'), { label: 'Name', onPick: async p => {
    if (!await confirmPopup(`Add ${p.full_name} to ${deptLabel(code)}?`)) return;
    const { error } = await sb.from('department_members').insert({ department_code: code, user_id: p.user_id });
    if (error && error.code !== '23505') { alert(errorText(error)); return; } // 23505: already a member
    again();
  } });
  box.querySelectorAll('[data-remove]').forEach(btn => btn.addEventListener('click', async () => {
    if (!await confirmPopup(`Remove ${nameOf(btn.dataset.remove)} from the department?`)) return;
    const { error } = await sb.from('department_members').delete().eq('department_code', code).eq('user_id', btn.dataset.remove);
    if (error) { alert(errorText(error)); return; }
    again();
  }));
}

// The team's chat (94_department_messages.sql): one thread for each department, read by its members and Admins. Any member
// writes; the lead (or Admin) pins; the author corrects or deletes within 15 minutes - the server's rule is the real gate.
const DEPT_MESSAGE_EDIT_WINDOW_MS = 15 * 60 * 1000;

function deptChatDateTime(iso) { return esc((iso || '').slice(0, 16).replace('T', ' ')); }

async function renderDeptChannel(box, code) {
  markDeptSeen(code);
  const canPin = isDeptLead(code) || isAdmin();
  const { data: { user } } = await sb.auth.getUser();
  const rows = await withStatus(sb.from('department_messages').select('*').eq('department_code', code).order('created_at'));
  const name = await namesByIds(rows.map(r => r.user_id));

  const imagePaths = rows.filter(r => r.image_path).map(r => r.image_path);
  const signedUrlByPath = {};
  if (imagePaths.length) {
    const { data } = await sb.storage.from(DEPARTMENT_MEDIA_BUCKET).createSignedUrls(imagePaths, 3600);
    (data || []).forEach(d => { if (d && d.signedUrl) signedUrlByPath[d.path] = d.signedUrl; });
  }

  // Each message is there once with its buttons; a pinned one has also a reminder above, without buttons.
  const bubble = r => {
    const mine = r.user_id === user.id, early = mine && (Date.now() - new Date(r.created_at).getTime()) < DEPT_MESSAGE_EDIT_WINDOW_MS;
    const img = r.image_path && signedUrlByPath[r.image_path] ? `<img class="dep-img" src="${esc(signedUrlByPath[r.image_path])}" alt="Picture">` : '';
    const btns = [early ? ['edit', 'Correct'] : 0, early ? ['delete', 'Delete'] : 0, canPin ? ['pin', r.pinned ? 'Unpin' : 'Pin'] : 0].filter(Boolean);
    return `
      <div class="chat-bubble ${mine ? 'from-me' : 'from-other'} ${r.pinned ? 'pinned' : ''}" data-msg-id="${r.id}">
        <div class="chat-meta">${mine ? 'You' : esc(name(r.user_id))} &middot; ${deptChatDateTime(r.created_at)}${r.edited_at ? ' &middot; corrected' : ''}${r.pinned ? ' &middot; &#128204; pinned' : ''}</div>
        <div class="dept-msg-body" dir="auto" style="white-space:pre-wrap;">${esc(r.body)}</div>
        ${img}
        ${btns.length ? `<div class="dep-msg-btns">${btns.map(([k, l]) => `<button type="button" data-act="${k}">${l}</button>`).join('')}</div>` : ''}
      </div>`;
  };
  const pinned = rows.filter(r => r.pinned);

  box.innerHTML = `
    <div class="panel dep-chat">
      <h3 style="margin-top:0;">Chat <span class="hint">only for ${esc(deptLabel(code))}</span></h3>
      ${pinned.map(r => `<div class="dep-pinned"><span aria-hidden="true">&#128204;</span> <span dir="auto">${esc(r.body)}</span> <span class="hint">${esc(name(r.user_id))}</span></div>`).join('')}
      <div class="chat-thread" id="dept-chat-thread" tabindex="0" aria-label="Messages">${rows.map(bubble).join('') || '<div class="empty-msg">No messages yet.</div>'}</div>
      <label class="sr-only" for="dept-msg-text">Write a message</label>
      <textarea id="dept-msg-text" dir="auto" rows="2" placeholder="Write a message"></textarea>
      <div class="dep-send">
        <label class="btn secondary" tabindex="-1">&#128247; Picture<input id="dept-msg-image" class="sr-only" type="file" accept="image/jpeg,image/png,image/webp,image/gif"></label>
        <span class="hint" id="dept-msg-file"></span>
        <button type="button" class="btn" id="dept-msg-send">Send</button>
      </div>
      <div class="hint dep-error" id="dept-msg-error" role="alert"></div>
    </div>`;
  const $ = id => box.querySelector('#' + id);
  const thread = $('dept-chat-thread');
  thread.scrollTop = thread.scrollHeight;
  const again = () => renderDeptChannel(box, code);

  $('dept-msg-image').addEventListener('change', e => { $('dept-msg-file').textContent = e.target.files[0]?.name || ''; });
  $('dept-msg-send').addEventListener('click', async () => {
    const errBox = $('dept-msg-error'), body = $('dept-msg-text').value.trim(), file = $('dept-msg-image').files[0];
    errBox.textContent = '';
    if (!body && !file) { errBox.textContent = 'Please write a message, or choose a picture.'; return; }
    $('dept-msg-send').disabled = true;
    try {
      let image_path = null;
      if (file) {
        const path = `${code}/${Date.now()}-${file.name}`.replace(/[^a-zA-Z0-9._/-]/g, '_');
        const { error } = await sb.storage.from(DEPARTMENT_MEDIA_BUCKET).upload(path, file, { upsert: true });
        if (error) { errBox.textContent = 'The picture could not be sent. ' + error.message; return; }
        image_path = path;
      }
      await withStatus(sb.from('department_messages').insert({ department_code: code, user_id: user.id, body: body || null, image_path }), 'Sending...');
      await again();
    } finally { if ($('dept-msg-send')) $('dept-msg-send').disabled = false; }
  });

  box.querySelectorAll('[data-msg-id]').forEach(el => {
    const r = rows.find(x => String(x.id) === el.dataset.msgId);
    el.querySelector('[data-act=edit]')?.addEventListener('click', () => {
      el.querySelector('.dept-msg-body').outerHTML = `
        <textarea class="dept-msg-edit-input" dir="auto" rows="2" style="width:100%;">${esc(r.body || '')}</textarea>
        <div class="btn-row"><button type="button" class="btn secondary" data-cancel>Cancel</button><button type="button" class="btn" data-save>Save</button></div>`;
      el.querySelector('[data-cancel]').addEventListener('click', again);
      el.querySelector('[data-save]').addEventListener('click', async () => {
        const next = el.querySelector('.dept-msg-edit-input').value.trim();
        if (!next && !r.image_path) { alert('A message cannot be empty.'); return; }
        await withStatus(sb.from('department_messages').update({ body: next || null }).eq('id', r.id), 'Saving...');
        await again();
      });
    });
    el.querySelector('[data-act=delete]')?.addEventListener('click', async () => {
      if (!await confirmPopup('Delete this message? This cannot be undone.', { danger: true, confirmLabel: 'Delete' })) return;
      await withStatus(sb.from('department_messages').delete().eq('id', r.id), 'Deleting...');
      await again();
    });
    el.querySelector('[data-act=pin]')?.addEventListener('click', async () => {
      await withStatus(sb.from('department_messages').update({ pinned: !r.pinned }).eq('id', r.id), 'Saving...');
      await again();
    });
  });
}

// ---------- Coordination: the task flow ----------

const isLate = r => r.status === 'claimed' && r.due_date && r.due_date < today();
async function loadFlowItems(open) {
  const rows = await withStatus(sb.rpc('coordination_task_overview'));
  const can = isDeptLead('COORD') || isAdmin();
  const items = rows.filter(r => r.extra_credits_status === 'pending').map(r => ({
    tone: 'violet', title: r.title, text: `Extra credits: <b>${esc(r.extra_credits)}</b>, on a base of ${esc(r.base_credits ?? 0)}`, quote: r.extra_credits_note, can,
    by: `${nameOnly(r.created_by_email) ? `Proposed by ${r.created_by_email}` : ''}${can ? '' : ' Waiting for the Coordination lead or an Admin.'}`.trim(),
    buttons: can ? [{ label: 'Approve', run: async () => {
      if (!await confirmPopup('Approve these extra credits?', { confirmLabel: 'Approve' })) return false;
      const { error } = await sb.rpc('approve_task_extra_credits', { p_task_id: r.id });
      if (error) { alert(errorText(error)); return false; }
      return true;
    } }] : [],
  }));
  const late = rows.filter(isLate).length;
  if (late) items.push({ tone: 'red', title: plural(late, 'task is late', 'tasks are late'), can: true, buttons: [{ label: 'Look', run: () => { State.myDeptCoordTab = 'overdue'; open('flow'); return false; } }] });
  return items;
}

async function renderTaskFlow(box) {
  const rows = await withStatus(sb.rpc('coordination_task_overview'));
  const name = await namesByIds(rows.map(r => r.claimed_by));
  const nearDays = State.policyValues.task_near_due_days ?? 3;
  const days = due => Math.round((new Date(due) - new Date(today())) / 86400000);
  const soon = r => r.status === 'claimed' && r.due_date && !isLate(r) && days(r.due_date) <= nearDays;
  const kinds = State.optionListsByName.task_category || [];
  const LISTS = [
    ['open', 'Open', rows.filter(r => r.status === 'open')], ['claimed', 'In progress', rows.filter(r => r.status === 'claimed')],
    ['submitted', 'In review', rows.filter(r => r.status === 'submitted')], ['approved', 'To publish', rows.filter(r => r.status === 'approved')],
    ['overdue', 'Late', rows.filter(isLate)], ['neardue', 'Due soon', rows.filter(soon)],
  ];
  const [key, , list] = LISTS.find(([k]) => k === State.myDeptCoordTab) || LISTS[0];
  const due = r => (!r.due_date ? '' : r.status !== 'claimed' ? esc(dayText(r.due_date)) : isLate(r) ? `${esc(dayText(r.due_date))} ${st('red', '&#9888;', `${plural(-days(r.due_date), 'day', 'days')} late`)}`
    : `${esc(dayText(r.due_date))} ${soon(r) ? st('amber', '&#9200;', days(r.due_date) ? `in ${plural(days(r.due_date), 'day', 'days')}` : 'today') : ''}`);
  const title = r => `<span dir="auto">${esc(r.title)}</span>`, kind = r => esc(labelOf(kinds, r.category) || r.category);
  box.innerHTML = `
    <div class="panel">
      <div class="dep-lists" role="group" aria-label="Which tasks">${LISTS.map(([k, label, l]) => `<button type="button" class="btn ${k === key ? '' : 'secondary'}" data-list="${k}" aria-pressed="${k === key}">${label} <span class="count-badge">${l.length}</span></button>`).join('')}</div>
      ${key === 'open' ? tableHtml(['Task', 'Kind of work'], list.map(r => [title(r), kind(r)]), 'Nothing here.')
        : tableHtml(['Task', 'Kind of work', 'Who', 'Date'], list.map(r => [title(r), kind(r), esc(name(r.claimed_by)), due(r)]), 'Nothing here.')}
      ${canReviewApplications() ? '<p class="hint">To give a task to someone else, or take it back: Tools, Team overview.</p>' : ''}
    </div>`;
  box.querySelectorAll('[data-list]').forEach(b => b.addEventListener('click', () => { State.myDeptCoordTab = b.dataset.list; renderTaskFlow(box); }));
}

// ---------- Formation ----------

// A lead of Formation reads every path, drafts included, and the formatori chat (is_any_formatore(), migration 80).
async function renderPaths(box) {
  const [paths, editorRows, chatRows] = await Promise.all([
    withStatus(sb.from('formation_paths').select('id,title,target_audience,status,owner_id,course_starts_at,course_ends_at').order('created_at', { ascending: false })),
    withStatus(sb.from('formation_path_editors').select('path_id,user_id')),
    withStatus(sb.from('formation_chat_messages').select('path_id,created_at').eq('channel', 'formatori').order('created_at', { ascending: false })),
  ]);
  const name = await namesByIds(paths.map(p => p.owner_id));
  const count = {}, writers = {}, last = {};
  for (const e of editorRows) writers[e.path_id] = (writers[e.path_id] || 0) + 1;
  for (const m of chatRows) { count[m.path_id] = (count[m.path_id] || 0) + 1; last[m.path_id] ||= m.created_at; } // newest first
  const part = (title, list) => `<h3>${title} <span class="count-badge">${list.length}</span></h3>
    ${tableHtml(['Path', 'For', 'Who leads it', 'Other writers', 'Dates', 'Formatori chat', ''], list.map(p => [
      `<span dir="auto">${esc(p.title)}</span>`, esc(p.target_audience), esc(name(p.owner_id)), esc(writers[p.id] || 0),
      p.course_starts_at || p.course_ends_at ? `${esc(dayText(p.course_starts_at) || '?')} &rarr; ${esc(dayText(p.course_ends_at) || '?')}` : '',
      count[p.id] ? `${esc(plural(count[p.id], 'message', 'messages'))}<div class="hint">last ${esc(agoText(last[p.id]))}</div>` : '',
      `<button type="button" class="btn secondary" data-path="${p.id}">Open</button>`]), 'None.')}`;
  const archived = paths.filter(p => p.status === 'archived');
  box.innerHTML = `<div class="panel">${part('Being written', paths.filter(p => p.status === 'draft'))}${part('Published', paths.filter(p => p.status === 'published'))}${archived.length ? part('Archived', archived) : ''}</div>`;
  box.querySelectorAll('[data-path]').forEach(btn => btn.addEventListener('click', () => {
    State.formationSelectedPathId = parseInt(btn.dataset.path, 10);
    window.__renderTab('formation', State.currentRole === 'operator' ? 'work' : undefined);
  }));
}

// Who can read reserved documents (111_access_levels.sql). Admins and Formation always can; the others are enabled here, one by one.
async function renderReservedAccess(box) {
  box.innerHTML = `
    <div class="panel">
      <p class="hint">Here are the people who can read reserved documents. Search for a person to enable them. For anyone else a reserved document does not appear in the app. Its PDF stays on Drive, where anyone with the link can open it: if a document is very delicate, keep only its text.</p>
      <div class="field"><label>Search a name<input id="reserved-search" type="search" autocomplete="off"></label></div>
      <div id="reserved-list" aria-live="polite"><div class="hint">Loading...</div></div>
    </div>`;
  const search = box.querySelector('#reserved-search'), out = box.querySelector('#reserved-list');
  let timer = null, turn = 0;
  const refresh = async () => {
    const mine = ++turn;
    const rows = await withStatus(sb.rpc('list_reserved_access', { p_query: search.value.trim() || null }));
    if (mine !== turn) return;
    const who = r => (r.full_name || '').trim() || '(no name)';
    out.innerHTML = tableHtml(['Person', 'Access', 'Enabled', ''], rows.map((r, i) => [
      `<span dir="auto">${esc(who(r))}</span>`, r.automatic ? st('green', '&#10003;', 'Always (Admin or Formation)') : r.enabled ? st('green', '&#10003;', 'Enabled') : st('grey', '&#8226;', 'Not enabled'),
      r.enabled && !r.automatic ? esc([nameOnly(r.granted_by_email) ? `by ${r.granted_by_email}` : '', dayText(r.granted_at)].filter(Boolean).join(', ')) : ' ',
      r.automatic ? ' ' : `<button type="button" class="btn secondary" data-i="${i}">${r.enabled ? 'Take away' : 'Enable'}</button>`]), 'Nobody found.');
    out.querySelectorAll('[data-i]').forEach(btn => btn.addEventListener('click', async () => {
      const r = rows[+btn.dataset.i];
      const reason = await promptPopup(r.enabled ? `Take away the access of ${who(r)}? A short reason, if you want:` : `Let ${who(r)} read reserved documents? A short reason, if you want:`, '', { okLabel: r.enabled ? 'Take away' : 'Enable' });
      if (reason === null) return;
      await withStatus(sb.rpc('set_reserved_access', { p_user_id: r.user_id, p_enabled: !r.enabled, p_reason: reason }), 'Saving...');
      await refresh();
    }));
  };
  search.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(refresh, 300); });
  await refresh();
}

// ---------- Archive & Data ----------

// Deleting leaves the record in place, hidden from everyone (110_doors_and_archive_log.sql).
async function renderDeletedDocuments(box) {
  const rows = await withStatus(sb.rpc('get_deleted_documents'));
  box.innerHTML = `<div class="panel">${tableHtml(['Document', 'Title', 'Deleted', 'By', 'Why', ''], rows.map(r => [
    '#' + esc(r.document_id), `<span dir="auto">${esc(r.title)}</span>`, esc(dayText(r.deleted_at)), esc(nameOnly(r.deleted_by_email)), `<span dir="auto">${esc(r.deleted_reason)}</span>`,
    `<button type="button" class="btn secondary" data-restore="${esc(r.document_id)}">Restore</button>`]), 'No deleted documents.')}</div>`;
  box.querySelectorAll('[data-restore]').forEach(btn => btn.addEventListener('click', async () => {
    await withStatus(sb.rpc('restore_document', { p_document_id: parseInt(btn.dataset.restore, 10) }), 'Restoring...');
    await renderDeletedDocuments(box);
  }));
}

// ---------- Translation prompt editor (106_translation_prompts.sql) ----------
// The text the Translate button copies (openTranslatePopup in core.js). Admin-only to change, as
// the table's RLS enforces. Saving never overwrites: it adds a version and the newest is the one in
// force, so a past version is restored by loading it and saving it again - nothing is ever lost.
async function renderTranslationPromptEditor(box) {
  if (!box) return;
  const [active, versions] = await Promise.all([
    fetchActiveTranslationPrompt(),
    withStatus(sb.from('translation_prompts').select('*').order('id', { ascending: false }).limit(20)),
  ]);

  const savedBy = await authorNames(versions, 'created_by', 'created_by_email');
  box.innerHTML = `
    <div class="panel">
      <p class="hint">Saving adds a new version; older ones are kept and the newest is the one in force. Keep it in step with the style guide: when the manual changes a canonical term, change it here and say in one line what changed.</p>
      ${active ? '' : '<p class="hint" style="color:var(--danger, #b3261e);">No prompt in the database yet: paste one below and save it as the first version.</p>'}
      <div class="field"><label>Version</label><input id="tp-version" value="${esc(active ? active.version : '')}" placeholder="e.g. prompt-core v3 (2026-11-02, manual v3.5)"></div>
      <div class="field"><label>Prompt</label><textarea id="tp-body" rows="18" style="width:100%;font-size:12.5px;">${esc(active ? active.body : '')}</textarea></div>
      <div class="field"><label>What changed <span class="hint">(one line)</span></label><input id="tp-note"></div>
      <div class="hint" id="tp-error"></div>
      <div class="btn-row"><button class="btn" id="tp-save">Save as a new version</button></div>
      <h3 style="margin-top:16px;">Versions <span class="hint">(newest first, last 20)</span></h3>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Version</th><th>Saved</th><th>By</th><th>What changed</th><th></th></tr></thead>
        <tbody>${versions.length ? versions.map(v => `<tr>
          <td title="${esc(v.version)}">${esc(v.version)}</td>
          <td>${esc(String(v.created_at).slice(0, 10))}</td>
          <td>${esc(savedBy(v))}</td>
          <td title="${esc(v.change_note)}">${esc(v.change_note)}</td>
          <td><button class="btn secondary tp-load-btn" data-id="${v.id}" style="padding:2px 8px;">Load</button></td>
        </tr>`).join('') : '<tr><td colspan="5" class="hint">No versions yet.</td></tr>'}</tbody>
      </table></div>
    </div>`;

  box.querySelectorAll('.tp-load-btn').forEach(btn => btn.addEventListener('click', async () => {
    const rows = await withStatus(sb.from('translation_prompts').select('version,body').eq('id', btn.dataset.id).limit(1));
    if (!rows.length) return;
    document.getElementById('tp-version').value = rows[0].version;
    document.getElementById('tp-body').value = rows[0].body;
    document.getElementById('tp-note').value = '';
    document.getElementById('tp-error').textContent = 'Loaded into the editor - change the version label, then save to make it the one in force.';
  }));

  document.getElementById('tp-save').addEventListener('click', async () => {
    const errBox = document.getElementById('tp-error');
    errBox.textContent = '';
    const version = document.getElementById('tp-version').value.trim();
    const body = document.getElementById('tp-body').value.trim();
    const change_note = document.getElementById('tp-note').value.trim() || null;
    if (!version) { errBox.textContent = 'The version label is required.'; return; }
    if (!body) { errBox.textContent = 'The prompt cannot be empty.'; return; }
    if (active && body === active.body.trim() && version === active.version) { errBox.textContent = 'Nothing changed.'; return; }
    if (active && version === active.version) { errBox.textContent = 'The prompt changed but the version label did not - change the label too, so two different prompts never share one.'; return; }
    await withStatus(sb.from('translation_prompts').insert({ version, body, change_note }), 'Saving...');
    renderTranslationPromptEditor(box);
  });
}

// ---------- Live "new message" notifications, same pattern as chat.js's initChatNotifications
// (localStorage "seen" timestamp per department+user + a Supabase Realtime subscription + one
// shared toast). Kept here rather than in chat.js since only this module's data is involved, and
// modules never import each other (core.js star-import convention). ----------

function deptSeenKey(code, uid) { return `deptMsgSeenAt_${code}_${uid}`; }
function getDeptSeenAt(code, uid) { return localStorage.getItem(deptSeenKey(code, uid)) || '1970-01-01T00:00:00.000Z'; }
async function markDeptSeen(code) {
  const { data: { user } } = await sb.auth.getUser();
  if (user) localStorage.setItem(deptSeenKey(code, user.id), new Date().toISOString());
}

function showDeptMessageToast(deptCode, onView) {
  document.querySelectorAll('.toast-notification').forEach(t => t.remove());
  const toast = document.createElement('div');
  toast.className = 'toast-notification work-toast';
  toast.innerHTML = `
    <div class="toast-title">New team message</div>
    <div class="toast-body">A new message in the ${esc(deptLabel(deptCode))} channel.</div>
    <div class="btn-row" style="margin:8px 0 0;">
      <button class="btn" id="toast-view-btn" style="padding:4px 10px;">View</button>
      <button class="btn secondary" id="toast-close-btn" style="padding:4px 10px;">Dismiss</button>
    </div>`;
  document.body.appendChild(toast);
  document.getElementById('toast-close-btn').addEventListener('click', () => toast.remove());
  document.getElementById('toast-view-btn').addEventListener('click', () => { toast.remove(); onView(deptCode); });
}

let deptNotifyChannel = null;

// Called once per login (from app.js, after the dashboard is first shown), same convention as
// initChatNotifications/initTaskNotifications. navigateToMyDepartment(code) should switch to My
// Department with that department selected - passed in to avoid a circular import with app.js.
export async function initDeptMessageNotifications(navigateToMyDepartment) {
  if (deptNotifyChannel) { sb.removeChannel(deptNotifyChannel); deptNotifyChannel = null; }
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return;
  const codes = myDepartmentCodes();
  if (!codes.length) return;

  for (const code of codes) {
    const { data } = await sb.from('department_messages').select('id')
      .eq('department_code', code).neq('user_id', user.id).gt('created_at', getDeptSeenAt(code, user.id));
    if (data && data.length) { showDeptMessageToast(code, navigateToMyDepartment); break; } // one toast is enough at login
  }

  deptNotifyChannel = sb.channel('dept-messages-notify')
    .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'department_messages' }, payload => {
      const row = payload.new;
      if (row.user_id === user.id || !codes.includes(row.department_code)) return;
      showDeptMessageToast(row.department_code, navigateToMyDepartment);
    })
    .subscribe();
}

// ---------- "Start Here" card editor (95_onboarding_and_share_with_us.sql) ----------
// Communication's own tool for the onboarding_cards Users see in "Start Here" (onboarding.js,
// read-only there). Built once real content needed to exist and writing rows by hand in Supabase
// wasn't a realistic ask for a non-technical content team - same bootstrapping gap help_pages had
// before the rest of Help existed, closed here the same way boards/formation editors already are:
// a plain popup form, not a generic admin grid.
const ONBOARDING_SECTIONS = [
  ['about', 'What is this?'],
  ['how_to_use', 'How to use it'],
  ['how_to_collaborate', 'How to collaborate'],
];
function onboardingSectionLabel(code) { const hit = ONBOARDING_SECTIONS.find(([c]) => c === code); return hit ? hit[1] : code; }
const onboardingThumbnailUrl = path => path ? sb.storage.from(ONBOARDING_MEDIA_BUCKET).getPublicUrl(path).data.publicUrl : null;

async function renderOnboardingCardsManager(box) {
  if (!box) return;
  const cards = await withStatus(sb.from('onboarding_cards').select('*').order('section').order('sort_order').order('created_at'));

  const row = c => `
    <tr class="${c.published ? '' : 'dismissed-row'}">
      <td>${esc(onboardingSectionLabel(c.section))}</td>
      <td>
        <div dir="auto" style="font-weight:600;">${esc(c.title_ur)}</div>
        ${c.title_en ? `<div class="hint">${esc(c.title_en)}</div>` : ''}
      </td>
      <td>${esc(c.media_type)}${c.media_type === 'video' && c.media_url ? ` &middot; ${esc(c.media_url)}` : ''}</td>
      <td>${c.sort_order}</td>
      <td>${c.published ? 'Yes' : '<span class="hint">no (draft)</span>'}</td>
      <td>
        <button class="btn secondary mydept-card-edit-btn" data-id="${c.id}" style="padding:4px 10px;">Edit</button>
        <button class="btn danger mydept-card-delete-btn" data-id="${c.id}" style="padding:4px 10px;">Delete</button>
      </td>
    </tr>`;

  box.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;">
        <span class="hint">What Users see in Start Here.</span>
        <button class="btn" id="mydept-card-new">+ New card</button>
      </div>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>Section</th><th>Title</th><th>Media</th><th>Order</th><th>Published</th><th></th></tr></thead>
        <tbody>${cards.length ? cards.map(row).join('') : '<tr><td colspan="6" class="hint">No cards yet - click "+ New card" to write the first one.</td></tr>'}</tbody>
      </table></div>
    </div>`;

  document.getElementById('mydept-card-new').addEventListener('click', () => openOnboardingCardPopup({ onSaved: () => renderOnboardingCardsManager(box) }));
  box.querySelectorAll('.mydept-card-edit-btn').forEach(btn => btn.addEventListener('click', () => {
    const card = cards.find(c => String(c.id) === btn.dataset.id);
    openOnboardingCardPopup({ card, onSaved: () => renderOnboardingCardsManager(box) });
  }));
  box.querySelectorAll('.mydept-card-delete-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!await confirmPopup('Delete this card? This cannot be undone.')) return;
    await withStatus(sb.from('onboarding_cards').delete().eq('id', btn.dataset.id), 'Deleting...');
    renderOnboardingCardsManager(box);
  }));
}

function openOnboardingCardPopup({ card = null, onSaved } = {}) {
  document.getElementById('oc-card-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'oc-card-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${card ? 'Edit card' : 'New card'}</h2>
      <div class="field"><label>Section</label><select id="oc-section">${ONBOARDING_SECTIONS.map(([c, l]) => `<option value="${c}" ${card && card.section === c ? 'selected' : ''}>${l}</option>`).join('')}</select></div>
      <div class="field"><label>Title (Urdu)</label><input id="oc-title-ur" dir="auto" value="${esc(card ? card.title_ur : '')}"></div>
      <div class="field"><label>Title (English) <span class="hint">(optional)</span></label><input id="oc-title-en" value="${esc(card ? card.title_en : '')}"></div>
      <div class="field"><label>Text (Urdu) <span class="hint">(optional)</span></label><textarea id="oc-body-ur" dir="auto" rows="3">${esc(card ? card.body_ur : '')}</textarea></div>
      <div class="field"><label>Text (English) <span class="hint">(optional)</span></label><textarea id="oc-body-en" rows="3">${esc(card ? card.body_en : '')}</textarea></div>
      <div class="field"><label>Media type</label><select id="oc-media-type">
        <option value="text" ${!card || card.media_type === 'text' ? 'selected' : ''}>Text only</option>
        <option value="image" ${card && card.media_type === 'image' ? 'selected' : ''}>Image (upload below)</option>
        <option value="video" ${card && card.media_type === 'video' ? 'selected' : ''}>Video (link)</option>
      </select></div>
      <div class="field"><label>Link <span class="hint">(for "Video": a YouTube/Facebook/Instagram URL you already published. Leave empty otherwise - unless you were told to enter a special "tab:..." reference, e.g. for the Share with us tutorial card)</span></label><input id="oc-media-url" value="${esc(card ? card.media_url : '')}"></div>
      <div class="field">
        <label>Thumbnail <span class="hint">(optional cover image, shown on the card)</span></label>
        ${card && card.thumbnail_path ? `<div style="margin-bottom:6px;"><img src="${esc(onboardingThumbnailUrl(card.thumbnail_path))}" alt="" style="max-width:220px;border-radius:6px;display:block;"></div>` : ''}
        <input id="oc-thumbnail" type="file" accept="image/jpeg,image/png,image/webp,image/gif">
      </div>
      <div class="field-grid">
        <div class="field"><label>Order <span class="hint">(lower shows first)</span></label><input id="oc-sort" type="number" value="${card ? card.sort_order : 0}"></div>
        <div class="field"><label style="text-transform:none;font-size:13px;"><input id="oc-published" type="checkbox" style="width:auto;" ${!card || card.published ? 'checked' : ''}> Published (visible to Users)</label></div>
      </div>
      <div class="hint" id="oc-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="oc-cancel">Cancel</button>
        <button class="btn" id="oc-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('oc-cancel').addEventListener('click', () => backdrop.remove());

  document.getElementById('oc-save').addEventListener('click', async () => {
    const errBox = document.getElementById('oc-error');
    errBox.textContent = '';
    const title_ur = document.getElementById('oc-title-ur').value.trim();
    if (!title_ur) { errBox.textContent = 'Title (Urdu) is required.'; return; }
    const media_type = document.getElementById('oc-media-type').value;
    const media_url = document.getElementById('oc-media-url').value.trim();
    if (media_type === 'video' && !media_url) { errBox.textContent = 'A video card needs a link.'; return; }

    let thumbnail_path = card ? card.thumbnail_path : null;
    const file = document.getElementById('oc-thumbnail').files[0];
    if (file) {
      const objectPath = `${Date.now()}-${file.name}`.replace(/[^a-zA-Z0-9._-]/g, '_');
      const { error } = await sb.storage.from(ONBOARDING_MEDIA_BUCKET).upload(objectPath, file, { upsert: true });
      if (error) { errBox.textContent = 'Could not upload the thumbnail: ' + error.message; return; }
      thumbnail_path = objectPath;
    }

    const { data: { user } } = await sb.auth.getUser();
    const row = {
      section: document.getElementById('oc-section').value,
      title_ur,
      title_en: document.getElementById('oc-title-en').value.trim() || null,
      body_ur: document.getElementById('oc-body-ur').value.trim() || null,
      body_en: document.getElementById('oc-body-en').value.trim() || null,
      media_type,
      media_url: media_url || null,
      thumbnail_path,
      sort_order: parseInt(document.getElementById('oc-sort').value, 10) || 0,
      published: document.getElementById('oc-published').checked,
      created_by_email: user.email,
      updated_at: new Date().toISOString(),
    };
    if (card) await withStatus(sb.from('onboarding_cards').update(row).eq('id', card.id), 'Saving...');
    else await withStatus(sb.from('onboarding_cards').insert(row), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// ---------- Admin-only roll-up across every department (its own tab, see app.js) ----------

export async function renderDepartmentsOverviewView(main) {
  main.innerHTML = '<div class="panel"><h2>Project overview</h2><div class="empty-msg">Loading...</div></div>';
  const depts = State.optionListsByName.department || [];
  const [statusRows, priorityRows, suggestionResults] = await Promise.all([
    withStatus(sb.from('department_status').select('*')),
    withStatus(sb.from('department_priorities').select('department_code,title,due_date,done').eq('done', false).order('sort_order')),
    // Phase 2 (migration 99): one RPC call per department, in parallel - no set-returning
    // "every department at once" function exists, and this list is short (a handful of rows).
    Promise.all(depts.map(([code]) => withStatus(sb.rpc('department_pulse_suggested_status', { p_code: code })).then(rows => [code, rows[0] || null]))),
  ]);
  const statusByCode = {};
  for (const s of statusRows) statusByCode[s.department_code] = s;
  const openPriorityCount = {};
  for (const p of priorityRows) openPriorityCount[p.department_code] = (openPriorityCount[p.department_code] || 0) + 1;
  const suggestionByCode = Object.fromEntries(suggestionResults);

  const card = ([code, label]) => {
    const status = statusByCode[code] || { status: 'on_track', note: null, updated_at: null };
    const meta = STATUS_META[status.status] || STATUS_META.on_track;
    const suggestion = suggestionByCode[code];
    return `
      <div class="panel" style="border-left:4px solid ${meta.color};cursor:pointer;" data-open-dept="${esc(code)}">
        <div class="btn-row" style="justify-content:space-between;align-items:center;">
          <h3 style="margin:0;"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${meta.color};margin-right:6px;"></span>${esc(label)}</h3>
          <span class="hint">${esc(meta.label)}</span>
        </div>
        ${status.note ? `<p style="margin:6px 0 0;font-size:13px;">${esc(status.note)}</p>` : '<p class="hint" style="margin:6px 0 0;">No status set yet.</p>'}
        <p class="hint" style="margin:6px 0 0;">${openPriorityCount[code] || 0} open ${openPriorityCount[code] === 1 ? 'priority' : 'priorities'}${status.updated_at ? ` &middot; updated ${esc((status.updated_at || '').slice(0, 10))}` : ''}</p>
        ${suggestion ? `<p class="hint" style="margin:4px 0 0;">Data suggests: ${esc(STATUS_META[suggestion.suggested]?.label || suggestion.suggested)}</p>` : ''}
      </div>`;
  };

  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;">
        <h2 style="margin:0;">Project overview <span class="hint">— every department at a glance, click one to open it</span></h2>
        <button class="btn danger" id="dept-overview-reset">Reset all statuses</button>
      </div>
    </div>
    <div class="field-grid wide">${depts.map(card).join('') || '<p class="hint">No departments configured yet.</p>'}</div>
    <div id="dept-overview-users-box"></div>`;

  main.querySelectorAll('[data-open-dept]').forEach(el => el.addEventListener('click', () => {
    go(el.dataset.openDept);
  }));

  // Admin-only escape hatch (owner's request 2026-09-20): bulk-clear every department's manual
  // status/note back to the table default (on_track, no note) - e.g. after a trial run of Phase
  // 2, or to stop a stale color misleading members. Does not touch priorities, only status.
  document.getElementById('dept-overview-reset').addEventListener('click', async () => {
    if (!await confirmPopup('Reset every department\'s status to "On track" with no note? This cannot be undone.')) return;
    const rows = depts.map(([code]) => ({
      department_code: code, status: 'on_track', note: null, updated_at: new Date().toISOString(),
    }));
    await withStatus(sb.from('department_status').upsert(rows), 'Resetting...');
    renderDepartmentsOverviewView(main);
  });

  await renderUsersStatsPanel(document.getElementById('dept-overview-users-box'));
}

// ---------- Users & activity panel (migration 100, owner's request 2026-09-20) ----------
// Headcount/demographics come straight from user_roles/user_profiles - Admin already reads both
// tables directly client-side (same access admin.js's Users view relies on), no RPC needed.
// Formation Paths enrollment counts are the one gap: formation_enrollments' only select policy is
// "your own row" (74_formation_enrollments.sql), so those come from admin_project_stats().
// Login/access tracking was asked about but isn't included - Supabase's own sign-in timestamps
// aren't exposed anywhere in this app today, and whether/how to surface them is a separate,
// privacy-sensitive decision, not folded silently into this panel.
async function renderUsersStatsPanel(box) {
  if (!box) return;
  box.innerHTML = '<div class="panel"><h2>Users</h2><div class="empty-msg">Loading...</div></div>';
  const [roleRows, profileRows, statsRows, bracketRows] = await Promise.all([
    withStatus(sb.from('user_roles').select('role,standing,created_at')),
    withStatus(sb.from('user_profiles').select('gender')),
    withStatus(sb.rpc('admin_project_stats')),
    withStatus(sb.rpc('people_age_brackets')),
  ]);
  const fromDate = bracketRows.filter(r => r.from_date).length;
  const stats = statsRows[0] || { total_active_enrollments: 0, distinct_enrolled_users: 0, enrollments_by_path: [] };

  const countBy = (rows, key) => {
    const m = {};
    for (const r of rows) { const v = r[key] || 'not_set'; m[v] = (m[v] || 0) + 1; }
    return m;
  };
  const byRole = countBy(roleRows, 'role');
  const byStanding = countBy(roleRows, 'standing');
  const byGender = countBy(profileRows, 'gender');
  const byAgeBracket = countBy(bracketRows, 'age_bracket');
  const thirtyDaysAgo = new Date(Date.now() - 30 * 86400000).toISOString();
  const newLast30 = roleRows.filter(r => (r.created_at || '') >= thirtyDaysAgo).length;

  const tile = (label, value) => `<div class="field"><label>${esc(label)}</label><div style="font-size:20px;font-weight:600;">${esc(value)}</div></div>`;
  const ROLE_LABELS = { user: 'Users', operator: 'Operators', coordinator: 'Coordinators', admin: 'Admins' };
  const GENDER_LABELS = { M: 'Male', F: 'Female', not_set: 'Not set' };
  const ageBracketOptions = State.optionListsByName.age_bracket || [];
  const ageBracketLabel = code => code === 'not_set' ? 'Not set' : (labelOf(ageBracketOptions, code) || code);
  // Fixed-width count column (not justify-content:space-between, which stretched the number
  // to the far edge of the whole .field-grid cell instead of sitting next to its own label -
  // found from the owner's screenshot 2026-09-20).
  const breakdownList = (m, labelFn) => Object.entries(m).sort((a, b) => b[1] - a[1])
    .map(([k, v]) => `<div style="display:flex;gap:8px;padding:2px 0;"><span class="hint" style="min-width:24px;text-align:right;">${esc(v)}</span><span>${esc(labelFn(k))}</span></div>`).join('');

  box.innerHTML = `
    <div class="panel">
      <h2>Users <span class="hint">— headcount, demographics, Formation Paths enrollment</span></h2>
      <div class="field-grid">
        ${tile('Total accounts', roleRows.length)}
        ${Object.entries(ROLE_LABELS).map(([code, label]) => tile(label, byRole[code] || 0)).join('')}
        ${tile('New in last 30 days', newLast30)}
      </div>
      <div class="field-grid" style="margin-top:10px;">
        <div class="field"><label>Standing</label>${breakdownList(byStanding, k => k === 'not_set' ? 'Not set' : k)}</div>
        <div class="field"><label>Gender</label>${breakdownList(byGender, k => GENDER_LABELS[k] || k)}</div>
        <div class="field" style="grid-column:span 2;"><label>Age bracket</label>${breakdownList(byAgeBracket, ageBracketLabel)}<div class="hint">${fromDate} of ${bracketRows.length} from a date of birth; the others as declared, or not set.</div></div>
      </div>
      <h3 style="margin:16px 0 4px;">Formation Paths enrollment</h3>
      <div class="field-grid">
        ${tile('Active enrollments', stats.total_active_enrollments)}
        ${tile('Distinct enrolled users', stats.distinct_enrolled_users)}
      </div>
      ${(stats.enrollments_by_path || []).length ? `
        <div class="grid-wrap" style="margin-top:8px;"><table class="grid">
          <thead><tr><th>Path</th><th>Enrolled</th></tr></thead>
          <tbody>${stats.enrollments_by_path.map(p => `<tr><td>${esc(p.title)}</td><td>${esc(p.enrolled)}</td></tr>`).join('')}</tbody>
        </table></div>` : '<p class="hint" style="margin-top:8px;">No active enrollments yet.</p>'}
      <p class="hint" style="margin-top:10px;">Login/access history isn't tracked yet - ask if this would be useful and it can be added as its own piece (it touches privacy considerations worth a separate decision).</p>
    </div>`;
}
