// My work of Admins and Coordinators (Owner's decision, 2026-11-27, Documentazione/ADMIN_Proposta_regia.html): the Overview
// opens first and says what waits for this person, oldest first; every box leads to where it is done. On a computer the tools
// are in the bar on the left, in groups (app.js workMenu); on a phone they are listed here, under what waits.
// Step A of three: B adds deadlines, how we are and the archive; C the weeks, "since your last visit" and "Go to...".

import { sb, State, esc, isAdmin, today } from './core.js?v=20261127205542';
import { departmentsWaiting, renderDepartmentsOverviewView } from './mydepartment.js?v=20261127205542';

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

const ageText = x => (x.note && !x.oldest ? x.note : x.oldest === null || x.oldest === undefined ? (x.note || '') : x.oldest === 0 ? 'the oldest: today' : `the oldest: ${x.oldest} ${x.oldest === 1 ? 'day' : 'days'}`);

// The tools of My work, the same groups as the bar (app.js passes them in): on a phone they are here.
export async function renderOverviewView(main, menu) {
  main.innerHTML = '<div class="panel ov-head"><h2>Overview</h2></div><div class="empty-msg">Loading...</div>';
  const w = await loadWaiting();
  if (main.dataset.section !== 'work') return w;
  const waiting = w.items.filter(x => x.count), clear = w.items.filter(x => !x.count);
  main.innerHTML = `
    <div class="panel ov-head"><h2>Overview</h2>
      <p class="hint">${w.total ? `${w.total} ${w.total === 1 ? 'thing is' : 'things are'} waiting for you. The oldest first.` : 'Nothing is waiting for you. Thank you!'}</p></div>
    <section class="ov-section">
      <h3 class="ov-h">Waiting for you</h3>
      <div class="ov-wait-grid">
        ${waiting.map((x, i) => `<button type="button" class="ov-wait${x.late ? ' ov-late' : ''}" data-i="${i}" style="--sec:var(--c-${x.colour})">
          <span class="ov-num">${x.count}</span><span class="ov-what">${esc(x.what)}</span><span class="ov-age">${esc(ageText(x))}</span></button>`).join('')}
      </div>
      ${clear.length ? `<p class="hint ov-clear">Nothing waiting: ${clear.map(x => esc(x.what)).join(' · ')}</p>` : ''}
    </section>
    <section class="ov-section ov-tools">
      <h3 class="ov-h">Tools</h3>
      ${menu.filter(([group]) => group).map(([group, items]) => `<h4 class="ov-group">${esc(group)}</h4><div class="ov-tool-list">${items.map(([id, label]) => `<button type="button" class="ov-tool" data-tool="${id}">${esc(label)}<span class="start-chevron" aria-hidden="true">&rsaquo;</span></button>`).join('')}</div>`).join('')}
    </section>
    ${isAdmin() ? '<section class="ov-section" id="ov-depts"></section>' : ''}`;
  main.querySelectorAll('.ov-wait').forEach(b => b.addEventListener('click', () => waiting[+b.dataset.i].open()));
  main.querySelectorAll('[data-tool]').forEach(b => b.addEventListener('click', () => window.__workTool(b.dataset.tool)));
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

