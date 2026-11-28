// My work of Admins and Coordinators (Owner's decision, 2026-11-27, Documentazione/ADMIN_Proposta_regia.html): the Overview
// opens first and says what waits for this person, oldest first; every box leads to where it is done. On a computer the tools
// are in the bar on the left, in groups (app.js workMenu); on a phone they are listed here, under what waits.
// Step B (migration 187): what falls due, how we are, how far the archive is. Without 187 those boxes are simply not there.
// Step C (migration 188): the last 12 weeks, readings by branch, "since your last visit", favourites, "Go to..." and
// "Print the week". Without 188 those are simply not there.

import { sb, State, esc, isAdmin, today, popupShell, labelOf } from './core.js?v=20261128134020';
import { departmentsWaiting, renderDepartmentsOverviewView } from './mydepartment.js?v=20261128134020';
import { deptLabel } from './deptui.js?v=20261128134020';
import { openFindWork } from './findwork.js?v=20261128134020';

const quietly = promise => Promise.resolve(promise).then(r => (r && !r.error ? r.data : null), () => null);
const daysSince = when => (when ? Math.max(0, Math.round((new Date(today() + 'T00:00') - new Date(String(when).slice(0, 10) + 'T00:00')) / 86400000)) : null);
const oldestOf = (rows, key) => (rows || []).map(r => r[key]).filter(Boolean).sort()[0] || null;

// What waits for this person: [{ key, count, what, oldest (days) or null, note, colour, open }], and how many in all.
export async function loadWaiting() {
  const admin = isAdmin();
  const [reviews, toPublish, subCounts, readCounts, messages, depts] = await Promise.all([
    quietly(sb.rpc('get_review_queue')),
    admin ? quietly(sb.from('tasks').select('id,reviewed_at').eq('status', 'approved')) : null,
    quietly(sb.rpc('get_submission_counts')),
    quietly(sb.rpc('get_reading_counts')),
    quietly(sb.from('chat_messages').select('id,created_at').eq('dismissed', false)),
    departmentsWaiting().catch(() => []),
  ]);
  const sc = (subCounts && subCounts[0]) || {}, rc = (readCounts && readCounts[0]) || {};
  const go = (tab, before, sub) => () => { if (before) before(); window.__renderTab(tab, 'work', sub); };
  const items = [
    { key: 'tasks', count: (reviews || []).length, what: 'Tasks to review', oldest: daysSince(oldestOf(reviews, 'submitted_at')), colour: 'work', open: go('tasks', () => { State.tasksView = 'review'; }) },
    ...(admin ? [{ key: 'publish', count: (toPublish || []).length, what: 'Tasks to close', note: 'Approved, waiting for you to close them', oldest: daysSince(oldestOf(toPublish, 'reviewed_at')), colour: 'work', open: go('tasks', () => { State.tasksView = 'publish'; }) }] : []),
    { key: 'proposals', count: sc.to_review || 0, what: 'Proposals', note: sc.overdue ? `${sc.overdue} for over 7 days` : '', late: !!sc.overdue, colour: 'work', open: go('proposals', () => { State.proposalsTab = 'queue'; }) },
    { key: 'readings', count: rc.to_listen || 0, what: 'Recordings to hear', colour: 'readings', open: go('readings', () => { State.readingsTab = 'listen'; }) },
    { key: 'chat', count: (messages || []).length, what: 'Messages', note: 'Waiting for a reply', oldest: daysSince(oldestOf(messages, 'created_at')), colour: 'report', open: go('chat') },
    ...(depts || []).filter(d => d.can).map(d => ({ key: 'dept-' + d.code, count: d.can, what: d.label, note: 'To decide in the department', colour: 'dept', open: go('mydepartment', null, `department/${d.code}`) })),
  ];
  const red = State.policyValues.waiting_red_days ?? 7;
  for (const x of items) x.late = x.late || (x.oldest !== null && x.oldest !== undefined && x.oldest > red);
  items.sort((a, b) => (!a.count - !b.count) || ((b.oldest ?? -1) - (a.oldest ?? -1)));
  return { items, total: items.reduce((n, x) => n + x.count, 0) };
}

// ---------- Step B ----------
const daysTo = d => Math.round((new Date(String(d).slice(0, 10) + 'T00:00') - new Date(today() + 'T00:00')) / 86400000);
const days = n => `${n} ${n === 1 ? 'day' : 'days'}`;
const dueText = d => { const n = daysTo(d); return n < 0 ? `${days(-n)} late` : n === 0 ? 'today' : n <= 7 ? `in ${days(n)}` : new Date(d + 'T00:00').toLocaleDateString('en', { day: 'numeric', month: 'short' }); };
const nextMonthFirst = () => { const t = new Date(today() + 'T00:00'), n = new Date(t.getFullYear(), t.getMonth() + 1, 1); return `${n.getFullYear()}-${String(n.getMonth() + 1).padStart(2, '0')}-01`; };

// What falls due in the next 30 days, or is late; the Word of Life of this month (and, after the 15th, of the next) without Urdu.
function deadlineRows(board, arch) {
  const task = id => () => window.__renderTab('tasks', 'work', 'task/' + id);
  const rows = ((board && board.deadlines) || []).map(d => (
    d.kind === 'task' ? { date: d.date, text: `Task #${d.id}: ${d.title}`, open: task(d.id) }
    : d.kind === 'idle' ? { date: d.date, text: `Task #${d.id}, taken ${days(daysTo(d.since) * -1)} ago, with no due date: ${d.title}`, open: task(d.id) }
    : d.kind === 'priority' ? { date: d.date, text: `${deptLabel(d.department)}: ${d.title}`, open: () => window.__renderTab('mydepartment', 'work', 'department/' + d.department) }
    : d.kind === 'enrolment' ? { date: d.date, text: `Formation path, enrolment closes: ${d.title}`, open: () => { State.formationSelectedPathId = d.id; window.__renderTab('formation', 'work'); } }
    : null)).filter(Boolean);
  if (arch && !arch.wol_this) rows.push({ date: today().slice(0, 8) + '01', text: 'Word of Life of this month: no Urdu text yet', open: () => openFindWork('wol') });
  else if (arch && !arch.wol_next && +today().slice(8, 10) >= 15) rows.push({ date: nextMonthFirst(), text: 'Word of Life of next month: no Urdu text yet', open: () => openFindWork('wol') });
  return rows.sort((a, b) => (a.date < b.date ? -1 : a.date > b.date ? 1 : 0));
}

// The steps that protect the accounts (Owner's request, 2026-11-27: a reminder in the app). The first three are settings of
// Supabase that the app cannot see: an Admin ticks them (app_settings 'protection_steps'). The fourth the app sees by itself.
const PROTECTION = [
  ['phone', 'The sign-up function (Phone-Account) published again'],
  ['min8', 'Passwords of at least 8 characters, in Supabase'],
  ['signup', 'Sign-up by email turned off, in Supabase'],
];
async function protectionTicks() {
  const { data } = await sb.from('app_settings').select('value').eq('key', 'protection_steps');
  try { const v = data && data[0] && data[0].value; const list = typeof v === 'string' ? JSON.parse(v) : v; return Array.isArray(list) ? list : []; } catch { return []; }
}
function protectionPopup(a, ticks, redraw) {
  const { panel, close } = popupShell('ov-protection', { width: 500, label: 'Protection' });
  panel.innerHTML = `<h2 style="margin-top:0;">Protection</h2>
    <p>Four steps that protect the accounts. The first three are done in Supabase: tick each one when it is done.</p>
    ${PROTECTION.map(([k, t]) => `<label class="ov-check"><input type="checkbox" data-k="${k}" ${ticks.includes(k) ? 'checked' : ''}> ${esc(t)}</label>`).join('')}
    <p class="ov-check"><span aria-hidden="true">${a.admins_second_step ? '&#10003;' : '&#10007;'}</span> Second step at sign-in: on for ${a.admins_second_step} of ${a.admins} Admins <span class="hint">(My Profile)</span></p>
    <div class="btn-row" style="justify-content:flex-end;"><button type="button" class="btn secondary" id="ov-prot-close">Close</button><button type="button" class="btn" id="ov-prot-save">Save</button></div>`;
  panel.querySelector('#ov-prot-close').addEventListener('click', close);
  panel.querySelector('#ov-prot-save').addEventListener('click', async () => {
    const list = [...panel.querySelectorAll('[data-k]')].filter(x => x.checked).map(x => x.dataset.k);
    const { data: { user } } = await sb.auth.getUser();
    const { error } = await sb.from('app_settings').upsert({ key: 'protection_steps', value: JSON.stringify(list), updated_at: new Date().toISOString(), updated_by_email: user.email }, { onConflict: 'key' });
    if (error) { panel.querySelector('.btn-row').insertAdjacentHTML('beforebegin', '<p class="hint" style="color:var(--st-red);">It was not saved. Please try again.</p>'); return; }
    close(); redraw();
  });
  panel.focus();
}

// How we are: [{ tone, text, open }].
function healthRows(board, ticks, redraw) {
  const rows = [], dep = board && board.departments, a = board && board.admin;
  if (dep) rows.push({ tone: dep.stalled ? 'red' : dep.slowing ? 'amber' : 'green',
    text: `Departments: ${dep.on_track} on track${dep.slowing ? `, ${dep.slowing} slowing down` : ''}${dep.stalled ? `, ${dep.stalled} stalled` : ''}`,
    open: () => (isAdmin() ? document.getElementById('ov-depts')?.scrollIntoView({ behavior: 'smooth' }) : window.__renderTab('mydepartment', 'work')) });
  if (a) {
    if (a.at_risk !== null && a.at_risk !== undefined) rows.push({ tone: a.at_risk ? 'amber' : 'green', text: a.at_risk ? `People at risk: ${a.at_risk}` : 'Nobody at risk', open: () => window.__renderTab('mydepartment', 'work', 'department/HR/people') });
    const perMonth = (a.spent_90 || 0) / 3, months = perMonth > 0 ? Math.floor(a.available / perMonth) : null;
    rows.push({ tone: a.available <= 0 || (months !== null && months < 2) ? 'red' : months !== null && months < 4 ? 'amber' : 'green',
      text: months !== null ? `Funds: enough for about ${months} ${months === 1 ? 'month' : 'months'} (${a.available} credits)` : `Funds: ${a.available} credits available`,
      open: () => { State.tasksView = 'budget'; window.__renderTab('tasks', 'work'); } });
    if (a.space && a.space.limit) {
      const pct = Math.round((100 * a.space.used) / a.space.limit);
      rows.push({ tone: pct > 90 ? 'red' : pct > 70 ? 'amber' : 'green', text: `Space for recordings: ${pct}% used`, open: () => { State.readingsTab = 'listen'; window.__renderTab('readings', 'work'); } });
    }
    const done = PROTECTION.filter(([k]) => ticks.includes(k)).length + (a.admins_second_step ? 1 : 0);
    rows.push({ tone: done === 4 ? 'green' : 'red', text: `Protection: ${done} of 4 steps done`, open: () => protectionPopup(a, ticks, redraw) });
  }
  const v = (new URL(import.meta.url).searchParams.get('v') || '').match(/^(\d{4})(\d{2})(\d{2})/);
  if (v) rows.push({ tone: 'green', text: `App updated: ${new Date(`${v[1]}-${v[2]}-${v[3]}T00:00`).toLocaleDateString('en', { day: 'numeric', month: 'short', year: 'numeric' })}` });
  return rows;
}

// How far the archive is: each bar opens its search in Find work.
function archiveBars(x) {
  if (!x) return [];
  return [
    ['Link-ups in Urdu', x.lkp_ita_urd, x.lkp_ita, 'library', () => openFindWork('it-ur', { category: 'Lkp' })],
    ['Urdu texts with English', x.urd_with_eng, x.urd_works, 'books', () => openFindWork('ur-en')],
    ['Urdu PDFs with typed text', x.urd_pdf_typed, x.urd_pdf, 'formation', () => openFindWork('type', { language: 'URD' })],
    ['Typed Urdu texts reread', x.urd_reread, x.urd_typed, 'readings', () => openFindWork('reread', { language: 'URD' })],
    ['Word of Life months since 1980', x.wol_months, x.wol_total, 'start', () => openFindWork('wol')],
  ].map(([what, has, of, colour, open]) => ({ what, has: has || 0, of: of || 0, colour, open }));
}

function boardHtml(deadlines, health, bars, extra = '') {
  const n = x => Number(x).toLocaleString('en');
  return `<div class="ov-board">
    ${deadlines ? `<section class="ov-box"><h3 class="ov-h">Deadlines <span class="hint">the next 30 days</span></h3>
      ${deadlines.length ? deadlines.map((d, i) => { const k = daysTo(d.date); return `<button type="button" class="ov-row" data-due="${i}"><span class="ov-when ${k < 0 ? 'late' : k <= 7 ? 'soon' : ''}">${esc(dueText(d.date))}</span><span class="ov-text" dir="auto">${esc(d.text)}</span></button>`; }).join('')
        : '<p class="hint">Nothing falls due in the next 30 days.</p>'}</section>` : ''}
    ${health.length ? `<section class="ov-box"><h3 class="ov-h">How we are</h3>
      ${health.map((h, i) => `<${h.open ? 'button type="button"' : 'div'} class="ov-row" data-health="${i}"><span class="ov-dot ov-${h.tone}" aria-hidden="true"></span><span class="ov-text">${esc(h.text)}</span></${h.open ? 'button' : 'div'}>`).join('')}</section>` : ''}
    ${extra}
    ${bars.length ? `<section class="ov-box ov-box-wide"><h3 class="ov-h">The archive: how far we are <span class="hint">each line opens Find work</span></h3>
      ${bars.map((b, i) => `<button type="button" class="ov-bar" data-bar="${i}" style="--sec:var(--c-${b.colour})"><span class="ov-bar-t"><span>${esc(b.what)}</span><b>${n(b.has)} of ${n(b.of)}</b></span>
        <span class="ov-track" aria-hidden="true"><span style="width:${b.of ? Math.round((100 * b.has) / b.of) : 0}%"></span></span></button>`).join('')}</section>` : ''}
  </div>`;
}

// ---------- Step C (migration 188) ----------
const DAY = 86400000;
const dateOf = s => new Date(String(s).slice(0, 10) + 'T00:00');
const shortDate = s => dateOf(s).toLocaleDateString('en', { day: 'numeric', month: 'short' });
const n0 = x => Number(x || 0).toLocaleString('en');
// The days of a week (from its Monday) that were counted: from `since` (the first day of a new count), up to today.
function daysIn(week, since) {
  const from = Math.max(+dateOf(week), since ? +dateOf(since) : 0), to = Math.min(+dateOf(week) + 6 * DAY, +dateOf(today()));
  return to < from ? 0 : Math.round((to - from) / DAY) + 1;
}
// The last 4 weeks (this one as far as it went) against the 4 before, day for day.
function periodOf(weeks, key, since) {
  const part = (a, b) => weeks.slice(a, b).reduce((s, w) => ({ sum: s.sum + (w[key] || 0), days: s.days + daysIn(w.week, since) }), { sum: 0, days: 0 });
  const now = part(8, 12), before = part(4, 8);
  const change = before.days >= 14 && now.days && before.sum ? Math.round(100 * ((now.sum / now.days) / (before.sum / before.days) - 1)) : null;
  return { now, change };
}
// Twelve small bars, one a week; this week's is lighter, as it is not over. The number of each is in its tooltip.
function sparkHtml(weeks, key, since, label) {
  const vals = weeks.map(w => w[key] || 0), max = Math.max(1, ...vals), H = 30, BW = 9, GAP = 3;
  return `<svg class="ov-spark" viewBox="0 0 ${12 * (BW + GAP) - GAP} ${H}" width="${12 * (BW + GAP) - GAP}" height="${H}" role="img" aria-label="${esc(label)}, week by week">
    ${weeks.map((w, i) => { const v = vals[i], h = v ? Math.max(3, Math.round((H - 1) * v / max)) : 1, counted = !since || +dateOf(w.week) + 6 * DAY >= +dateOf(since);
      return `<rect x="${i * (BW + GAP)}" y="${H - h}" width="${BW}" height="${h}" rx="2" class="${i === 11 ? 'now' : ''}${v ? '' : ' zero'}"><title>${esc(`Week of ${shortDate(w.week)}${i === 11 ? ' (so far)' : ''}: ${counted ? n0(v) : 'not counted yet'}`)}</title></rect>`; }).join('')}
  </svg>`;
}
function trendsHtml(t) {
  if (!t || !t.weeks || t.weeks.length !== 12) return '';
  const W = t.weeks, since = t.counting_since;
  const ROWS = [
    ['visits', 'People who came in', 'a day, on average', since],
    ['opens', 'Documents opened', 'in 4 weeks'],
    ['plays', 'Recordings heard', 'in 4 weeks'],
    ['published', 'Tasks published', 'in 4 weeks'],
    ['accounts', 'New accounts', 'in 4 weeks'],
  ];
  const ROLE = { user: 'Users', operator: 'Operators', coordinator: 'Coordinators', admin: 'Admins' };
  const roles = Object.entries(ROLE).filter(([k]) => t.roles && t.roles[k]).map(([k, l]) => `${l} ${n0(t.roles[k])}`).join(' · ');
  const rows = ROWS.map(([key, what, unit, from]) => {
    if (key === 'visits' && !since) return `<div class="ov-trend"><span class="ov-trend-t"><b>${what}</b><span class="hint">Counted from today: only how many, never who.</span></span></div>`;
    const p = periodOf(W, key, from);
    const value = key === 'visits' ? (p.now.days ? (p.now.sum / p.now.days).toFixed(p.now.sum / p.now.days < 10 ? 1 : 0) : '0') : n0(p.now.sum);
    const ch = p.change === null ? '' : `<span class="ov-change">${p.change > 0 ? '&#9650;' : p.change < 0 ? '&#9660;' : '='} ${Math.abs(p.change)}%</span>`;
    const note = key === 'visits' ? `${since > W[0].week ? `Counted since ${shortDate(since)}. ` : ''}${roles ? `In 12 weeks: ${roles}` : ''}` : '';
    return `<div class="ov-trend"><span class="ov-trend-t"><b>${what}</b><span class="ov-trend-v">${value} <span class="hint">${unit}</span> ${ch}</span>${note ? `<span class="hint">${esc(note)}</span>` : ''}</span>${sparkHtml(W, key, from, what)}</div>`;
  }).join('');
  return `<section class="ov-box ov-box-wide"><h3 class="ov-h">The last 12 weeks <span class="hint">the arrows compare the last 4 weeks with the 4 before</span></h3><div class="ov-trends">${rows}</div></section>`;
}
// Readings by branch of the Focolare (Owner's request, 2026-11-27): how many, never who nor what.
function branchesHtml(t) {
  if (!t || !t.branches) return '';
  const list = State.optionListsByName.membership_type || [];
  const name = b => (b === 'none' ? 'Not said in the profile' : labelOf(list, b));
  const max = Math.max(1, ...t.branches.map(b => b.opens + b.plays));
  const from = t.branches_since && t.branches_since > t.weeks[0].week ? `Since ${shortDate(t.branches_since)}` : 'In 12 weeks';
  return `<section class="ov-box ov-box-wide"><h3 class="ov-h">Readings by branch <span class="hint">${esc(from)}, how many and never who</span></h3>
    ${t.branches.length ? t.branches.map(b => `<div class="ov-bar ov-bar-static" style="--sec:var(--c-readings)"><span class="ov-bar-t"><span>${esc(name(b.branch))}</span><b>${n0(b.opens)} opened · ${n0(b.plays)} heard</b></span>
      <span class="ov-track" aria-hidden="true"><span style="width:${Math.round((100 * (b.opens + b.plays)) / max)}%"></span></span></div>`).join('')
      : '<p class="hint">Counted from today. Nothing yet.</p>'}</section>`;
}
// "Since your last visit": only what changed.
function sinceHtml(t, at) {
  const s = t && t.since;
  if (!s || !at) return '';
  const parts = [[s.accounts, 'new account', 'new accounts'], [s.opens, 'document opened', 'documents opened'], [s.plays, 'recording heard', 'recordings heard'],
    [s.submitted, 'task sent for review', 'tasks sent for review'], [s.published, 'task published', 'tasks published'], [s.messages, 'message', 'messages']]
    .filter(([v]) => v).map(([v, one, many]) => `${n0(v)} ${v === 1 ? one : many}`);
  return `<p class="ov-since"><b>Since your last visit</b> <span class="hint">(${esc(shortDate(at))})</span>: ${parts.length ? esc(parts.join(' · ')) : 'nothing new.'}</p>`;
}

// Favourites: up to 3 tools at the top of My work (Owner's decision, 2026-11-27). They stay on this device.
const FAV_KEY = 'workFavourites';
export function workFavourites() { try { const v = JSON.parse(localStorage.getItem(FAV_KEY) || '[]'); return Array.isArray(v) ? v.slice(0, 3) : []; } catch { return []; } }
function openFavourites(menu) {
  const tools = menu.flatMap(([group, items]) => (group && group !== 'Favourites' ? items : [])), now = workFavourites();
  const { panel, close } = popupShell('ov-favourites', { width: 460, label: 'Favourites' });
  panel.innerHTML = `<h2 style="margin-top:0;">Favourites</h2><p>Choose up to 3 tools. They go to the top of My work, on this device.</p>
    <div class="ov-fav-list">${tools.map(([id, label]) => `<label class="ov-check"><input type="checkbox" data-id="${esc(id)}" ${now.includes(id) ? 'checked' : ''}> ${esc(label)}</label>`).join('')}</div>
    <div class="btn-row" style="justify-content:flex-end;"><button type="button" class="btn secondary" id="ov-fav-close">Cancel</button><button type="button" class="btn" id="ov-fav-save">Save</button></div>`;
  const boxes = [...panel.querySelectorAll('[data-id]')];
  const limit = () => { const n = boxes.filter(b => b.checked).length; boxes.forEach(b => { b.disabled = !b.checked && n >= 3; }); };
  boxes.forEach(b => b.addEventListener('change', limit)); limit();
  panel.querySelector('#ov-fav-close').addEventListener('click', close);
  panel.querySelector('#ov-fav-save').addEventListener('click', () => {
    try { localStorage.setItem(FAV_KEY, JSON.stringify(boxes.filter(b => b.checked).map(b => b.dataset.id))); } catch { /* not needed to work */ }
    close();
    window.__rebuildWork();
  });
}

// "Go to...": one box to reach a tool, a document (#1593 or words of its title), a task or a proposal. Ctrl+K (app.js).
export function openGoTo(tools) {
  const { panel, close } = popupShell('ov-goto', { width: 560, label: 'Go to' });
  panel.innerHTML = `<h2 style="margin-top:0;">Go to&hellip;</h2>
    <input type="search" id="ov-goto-q" class="ov-goto-q" placeholder="A tool, #1593, task 51, or words of a title" autocomplete="off" aria-label="Where to go" aria-controls="ov-goto-list">
    <div id="ov-goto-list" class="ov-goto-list" role="listbox" aria-label="Places"></div>
    <p class="hint">&uarr; &darr; to choose, Enter to go, Esc to close.</p>`;
  const input = panel.querySelector('#ov-goto-q'), list = panel.querySelector('#ov-goto-list');
  let found = [], at = 0, asked = 0;
  const draw = () => {
    list.innerHTML = found.length ? found.map((x, i) => `<button type="button" class="ov-goto-item${i === at ? ' on' : ''}" role="option" aria-selected="${i === at}" data-i="${i}"><span dir="auto">${esc(x.label)}</span><span class="hint">${esc(x.where)}</span></button>`).join('')
      : `<p class="hint">${input.value.trim() ? 'Nothing found.' : ''}</p>`;
    list.querySelectorAll('[data-i]').forEach(b => b.addEventListener('click', () => go(+b.dataset.i)));
  };
  const go = i => { const x = found[i]; if (!x) return; close(); x.open(); };
  const search = async () => {
    const q = input.value.trim(), low = q.toLowerCase(), mine = ++asked;
    found = tools.filter(t => !q || t.label.toLowerCase().includes(low)).slice(0, q ? 8 : 30).map(t => ({ label: t.label, where: t.group, open: t.open }));
    const num = (q.match(/^#?\s*(\d{1,7})$/) || [])[1], task = (low.match(/^task\s*#?\s*(\d+)$/) || [])[1], prop = (low.match(/^proposal\s*#?\s*(\d+)$/) || [])[1];
    if (task) found.unshift({ label: `Task #${task}`, where: 'Tasks', open: () => window.__renderTab('tasks', 'work', 'task/' + task) });
    if (prop) found.unshift({ label: `Proposal #${prop}`, where: 'Proposals', open: () => window.__renderTab('proposals', 'work', 'proposal/' + prop) });
    if (num) found.unshift({ label: `Document #${num}`, where: 'Library', open: () => window.__renderTab('dashboard', 'work', 'doc/' + num) });
    at = 0; draw();
    const words = q.replace(/[,()*%\\]/g, ' ').trim();
    if (words.length < 3 || num || task || prop) return;
    const like = `%${words}%`;
    const docs = await quietly(sb.from('documents').select('document_id,title,en_title,ur_title').is('deleted_at', null)
      .or(`title.ilike.${like},en_title.ilike.${like},ur_title.ilike.${like},it_title.ilike.${like}`).limit(6));
    if (mine !== asked || !docs) return;
    found.push(...docs.map(d => ({ label: `#${d.document_id} ${d.en_title || d.title || d.ur_title || ''}`, where: 'Document', open: () => window.__renderTab('dashboard', 'work', 'doc/' + d.document_id) })));
    draw();
  };
  let timer = 0;
  input.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(search, 200); });
  input.addEventListener('keydown', e => {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') { e.preventDefault(); if (found.length) { at = (at + (e.key === 'ArrowDown' ? 1 : found.length - 1)) % found.length; draw(); list.querySelector('.on')?.scrollIntoView({ block: 'nearest' }); } }
    else if (e.key === 'Enter') { e.preventDefault(); go(at); }
  });
  search();
  input.focus();
}

// "Print the week": the Overview on paper, for the meeting of the coordinators.
function printWeek() {
  document.body.classList.add('print-week');
  const done = () => { document.body.classList.remove('print-week'); window.removeEventListener('afterprint', done); };
  window.addEventListener('afterprint', done);
  window.print();
}

const ageText = x => (x.note && !x.oldest ? x.note : x.oldest === null || x.oldest === undefined ? (x.note || '') : x.oldest === 0 ? 'the oldest: today' : `the oldest: ${x.oldest} ${x.oldest === 1 ? 'day' : 'days'}`);

// The tools of My work, the same groups as the bar (app.js passes them in): on a phone they are here.
export async function renderOverviewView(main, menu) {
  main.innerHTML = '<div class="panel ov-head"><h2>Overview</h2></div><div class="empty-msg">Loading...</div>';
  const lastVisit = await Promise.resolve(State.visitAsked).catch(() => null);
  const [w, board, arch, ticks, trends] = await Promise.all([
    loadWaiting(),
    quietly(sb.rpc('overview_board')),
    quietly(sb.rpc('overview_archive')),
    isAdmin() ? protectionTicks().catch(() => []) : [],
    quietly(sb.rpc('overview_trends', { p_since: lastVisit || null })),
  ]);
  if (main.dataset.section !== 'work') return w;
  const deadlines = board || arch ? deadlineRows(board, arch) : null;
  const health = healthRows(board, ticks, () => renderOverviewView(main, menu));
  const bars = archiveBars(arch);
  const waiting = w.items.filter(x => x.count), clear = w.items.filter(x => !x.count);
  const extra = trendsHtml(trends) + branchesHtml(trends);
  main.innerHTML = `
    <div class="panel ov-head"><div class="ov-head-top"><h2>Overview <span class="ov-print-date">${esc(new Date(today() + 'T00:00').toLocaleDateString('en', { day: 'numeric', month: 'long', year: 'numeric' }))}</span></h2>
      <div class="btn-row ov-head-btns"><button type="button" class="btn secondary" id="ov-goto">&#8981; Go to&hellip;</button><button type="button" class="btn secondary" id="ov-fav">&#9734; Favourites</button><button type="button" class="btn secondary" id="ov-print">Print the week</button></div></div>
      <p class="hint">${w.total ? `${w.total} ${w.total === 1 ? 'thing is' : 'things are'} waiting for you. The oldest first.` : 'Nothing is waiting for you. Thank you!'}</p>
      ${sinceHtml(trends, lastVisit)}</div>
    <section class="ov-section">
      <h3 class="ov-h">Waiting for you</h3>
      <div class="ov-wait-grid">
        ${waiting.map((x, i) => `<button type="button" class="ov-wait${x.late ? ' ov-late' : ''}" data-i="${i}" style="--sec:var(--c-${x.colour})">
          <span class="ov-num">${x.count}</span><span class="ov-what">${esc(x.what)}</span><span class="ov-age">${esc(ageText(x))}</span></button>`).join('')}
      </div>
      ${clear.length ? `<p class="hint ov-clear">Nothing waiting: ${clear.map(x => esc(x.what)).join(' · ')}</p>` : ''}
    </section>
    ${board || arch || extra ? `<div class="ov-section">${boardHtml(deadlines, health, bars, extra)}</div>` : ''}
    <section class="ov-section ov-tools">
      <h3 class="ov-h">Tools</h3>
      ${menu.filter(([group]) => group).map(([group, items]) => `<h4 class="ov-group">${esc(group)}</h4><div class="ov-tool-list">${items.map(([id, label]) => `<button type="button" class="ov-tool" data-tool="${id}">${esc(label)}<span class="start-chevron" aria-hidden="true">&rsaquo;</span></button>`).join('')}</div>`).join('')}
    </section>
    ${isAdmin() ? '<section class="ov-section" id="ov-depts"></section>' : ''}`;
  main.querySelector('#ov-goto').addEventListener('click', () => window.__goTo());
  main.querySelector('#ov-fav').addEventListener('click', () => openFavourites(menu));
  main.querySelector('#ov-print').addEventListener('click', printWeek);
  main.querySelectorAll('.ov-wait').forEach(b => b.addEventListener('click', () => waiting[+b.dataset.i].open()));
  main.querySelectorAll('[data-tool]').forEach(b => b.addEventListener('click', () => window.__workTool(b.dataset.tool)));
  main.querySelectorAll('[data-due]').forEach(b => b.addEventListener('click', () => deadlines[+b.dataset.due].open()));
  main.querySelectorAll('button[data-health]').forEach(b => b.addEventListener('click', () => health[+b.dataset.health].open()));
  main.querySelectorAll('[data-bar]').forEach(b => b.addEventListener('click', () => bars[+b.dataset.bar].open()));
  // The departments at a glance (what was Project overview), for Admins.
  const box = main.querySelector('#ov-depts');
  if (box) await renderDepartmentsOverviewView(box).catch(e => { console.warn('Overview, departments:', e); box.remove(); });
  return w;
}

// "Archive tools": the cataloguing tools in one page (they are also in My Department -> Archive & Data, as before).
const ARCHIVE_TOOLS = [
  ['hayat', 'Hayat Index', 'Browse the original Hayat register'],
  ['matchreview', 'Match Review', 'Check and confirm the automatic matches'],
  ['workconsolidation', 'Work Consolidation', 'Bring together entries of the same document'],
  ['hayateditor', 'Hayat Editor', 'Correct an entry of the Hayat register'],
  ['bulkimport', 'Bulk Import', 'Add many documents from a spreadsheet', 'admin'],
  ['inpageconverter', 'InPage Converter', 'From InPage to Word and PDF'],
];
export function renderArchiveToolsView(main) {
  const tools = ARCHIVE_TOOLS.filter(t => !t[3] || isAdmin());
  main.innerHTML = `
    <div class="panel"><h2>Archive tools</h2><p class="hint">The tools to catalogue the archive. They are also in My Department, Archive &amp; Data.</p></div>
    <div class="ov-tool-list ov-tool-big">${tools.map(([id, name, note]) => `<button type="button" class="ov-tool" data-tool="${id}"><span><b>${esc(name)}</b><span class="hint">${esc(note)}</span></span><span class="start-chevron" aria-hidden="true">&rsaquo;</span></button>`).join('')}</div>`;
  main.querySelectorAll('[data-tool]').forEach(b => b.addEventListener('click', () => window.__renderTab(b.dataset.tool, 'work')));
}

