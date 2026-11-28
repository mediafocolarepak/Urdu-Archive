// "Find work to do" (Owner's decisions, 2026-11-27): ready searches of what is missing in the archive, for Admin,
// Coordinator and the leads of a department, to print, to download for Excel, and to turn into tasks. The searches are
// read-only functions (186_find_work.sql) that use the rights of whoever asks: what a person cannot read is not listed.
// "There" in a language means a typed text or a PDF in the same Work.

import { sb, State, esc, labelOf, optionsHtml, withStatus, titleTrio, docDateLabel, yearOf, readPdfPageCount, popupShell,
  alertPopup, canReviewApplications, getDisplayNameByEmail, today } from './core.js?v=20261128134020';

const SEARCHES = [
  { group: 'Languages', key: 'it-ur', name: 'Italian, not yet in Urdu', note: 'Documents to translate', kind: 'lang', has: 'ITA', missing: 'URD' },
  { group: 'Languages', key: 'ur-en', name: 'Urdu, without English', note: 'Texts to bring into English', kind: 'lang', has: 'URD', missing: 'ENG' },
  { group: 'Languages', key: 'ur-it', name: 'Urdu, without the Italian original', note: 'Originals to look for', kind: 'lang', has: 'URD', missing: 'ITA' },
  { group: 'Languages', key: 'lang', name: 'Another combination', note: 'Choose the languages', kind: 'lang', choose: true },
  { group: 'Periods', key: 'wol', name: 'Word of Life: missing months', note: 'Months between two dates', kind: 'wol' },
  { group: 'Texts', key: 'type', name: 'PDF without typed text', note: 'Texts to type', kind: 'texts', p: 'no_text', task: 'TYPING', verb: 'Type' },
  { group: 'Texts', key: 'reread', name: 'Text not yet reread', note: 'Proof and finalize', kind: 'texts', p: 'not_reread', task: 'PROOFREAD', verb: 'Proofread' },
  { group: 'Texts', key: 'aloud', name: 'Ready to read aloud', note: 'No recording yet', kind: 'texts', p: 'read_aloud', noTasks: 'A reading is not a task: readers find these texts in Read aloud.' },
  { group: 'Catalogue', key: 'details', name: 'Missing details', note: 'Date, titles, author', kind: 'details', task: 'REVISION', verb: 'Complete the details' },
  { group: 'Catalogue', key: 'dups', name: 'Possible duplicates', note: 'Same Work, language and date', kind: 'dups', noTasks: 'Look at them and decide: they are not a task.' },
];
const DETAILS = [['date', 'Date'], ['en_title', 'English title'], ['ur_title', 'Urdu title'], ['it_title', 'Italian title'], ['author', 'Author'], ['category', 'Category']];
const SORTS = [['date', 'Date'], ['title', 'Title'], ['category', 'Category'], ['number', 'Number']];
const LANG_SHORT = { URD: 'U', ITA: 'I', ENG: 'E' };
const ACTIVE_TASK = ['open', 'claimed', 'submitted', 'approved'];
const TASK_STATE = { open: 'open', claimed: 'taken', submitted: 'sent', approved: 'approved' };
const MONTH = ym => { const [y, m] = ym.split('-').map(Number); return new Date(y, m - 1, 1).toLocaleDateString('en', { month: 'long', year: 'numeric' }); };
const thisMonth = () => today().slice(0, 7);

// Who may use it: the same rule as find_work_allowed() on the server.
export function canFindWork() { return canReviewApplications() || State.myDepartments.some(d => d.is_lead); }

const st = () => (State.findWork ||= { key: 'it-ur', category: '', from: '', to: '', has: 'ENG', missing: 'URD', language: 'URD', source: '',
  what: 'en_title', sort: 'date', wolFrom: '1980-01', wolTo: thisMonth(), wolMissing: 'URD', rows: null, ran: '' });
const searchOf = key => SEARCHES.find(s => s.key === key) || SEARCHES[0];
// Opens Find work on one search, with some of its choices (the Overview of My work, overview.js).
export function openFindWork(key, choices = {}) {
  Object.assign(st(), { category: '', from: '', to: '' }, choices, { key, rows: null, ran: '' });
  window.__renderTab('findwork', 'work');
}
const langName = code => labelOf(State.langs, code) || code;

// The task a row of a language search makes: into Urdu from Italian or English, into English from Urdu, else Others.
function langTask(s, f) {
  const has = s.choose ? f.has : s.has, missing = s.choose ? f.missing : s.missing;
  const cat = { 'ITA>URD': 'IT_UR', 'ENG>URD': 'EN_UR', 'URD>ENG': 'UR_EN' }[`${has}>${missing}`] || 'OTHER';
  const verb = cat === 'OTHER' ? (missing === 'ITA' ? 'Find the Italian original' : `Add the ${langName(missing)} version`) : `Translate into ${langName(missing)}`;
  return { cat, verb };
}

async function fetchAll(fn, args) {
  const out = [];
  for (let from = 0; ; from += 1000) {
    const rows = await withStatus(sb.rpc(fn, args).range(from, from + 999), 'Searching...');
    out.push(...rows);
    if (rows.length < 1000) return out;
  }
}

// The rows of the chosen search, as { id, doc, cells, task, ... }: one per document, or one per month for the Word of Life.
async function runSearch(s, f) {
  const cat = f.category || null;
  if (s.kind === 'lang') {
    const has = s.choose ? f.has : s.has, missing = s.choose ? f.missing : s.missing;
    return fetchAll('find_missing_language', { p_has: has, p_missing: missing, p_category: cat });
  }
  if (s.kind === 'texts') return fetchAll('find_texts', { p_kind: s.p, p_language: s.p === 'read_aloud' ? 'URD' : (f.language || null), p_category: cat });
  if (s.kind === 'details') return fetchAll('find_missing_details', { p_what: f.what, p_category: cat, p_language: f.language || null });
  if (s.kind === 'dups') return fetchAll('find_duplicates', { p_category: cat });
  return fetchAll('find_wol_documents', {});
}

// The Word of Life as months: every month between the two dates without a text in the language looked for.
async function wolMonths(docs, f) {
  const byMonth = new Map();
  for (const d of docs) if (d.note) (byMonth.get(d.note) || byMonth.set(d.note, []).get(d.note)).push(d);
  const months = [];
  for (let [y, m] = f.wolFrom.split('-').map(Number); `${y}-${String(m).padStart(2, '0')}` <= f.wolTo; m === 12 ? (y++, m = 1) : m++) months.push(`${y}-${String(m).padStart(2, '0')}`);
  const rows = months.map(ym => {
    const there = byMonth.get(ym) || [];
    const langs = [...new Set(there.map(d => d.language).filter(Boolean))].sort();
    if (langs.includes(f.wolMissing)) return null;
    // The task is made on the text it is translated from: Italian first, then English, then any other.
    const source = ['ITA', 'ENG'].map(l => there.find(d => d.language === l)).find(Boolean) || there[0] || null;
    const cat = !source ? 'OTHER' : f.wolMissing === 'URD' ? ({ ITA: 'IT_UR', ENG: 'EN_UR' }[source.language] || 'OTHER') : f.wolMissing === 'ENG' && source.language === 'URD' ? 'UR_EN' : 'OTHER';
    const title = source ? `Word of Life, ${MONTH(ym)}: translate into ${langName(f.wolMissing)}` : `Word of Life, ${MONTH(ym)}: find it`;
    return { ym, langs, source, cat, title, task_id: source?.task_id || null, task_status: source?.task_status || null };
  }).filter(Boolean);
  // Every month of the period, with the languages there, for the calendar above the list.
  rows.calendar = months.map(ym => ({ ym, langs: [...new Set((byMonth.get(ym) || []).map(d => d.language).filter(Boolean))].sort() }));
  // A month without any text has no document to hang a task on: its task is found by its title.
  const loose = rows.filter(r => !r.source).map(r => r.title);
  if (loose.length) {
    const tasks = await withStatus(sb.from('tasks').select('id,title,status').in('title', loose).in('status', ACTIVE_TASK));
    for (const t of tasks) { const r = rows.find(x => !x.source && x.title === t.title); if (r && !r.task_id) { r.task_id = t.id; r.task_status = t.status; } }
  }
  return rows;
}

const titleOf = d => { const t = titleTrio(d); return t.en || t.it || t.ur || ''; };
const dateKey = d => d.ref_date || (/^\d{4}(-\d{2})?/.exec(d.ref_period || '') || [])[0] || '9999';
function sortRows(rows, how) {
  const by = {
    date: (a, b) => dateKey(a).localeCompare(dateKey(b)) || a.document_id - b.document_id,
    title: (a, b) => titleOf(a).localeCompare(titleOf(b), 'en', { sensitivity: 'base', numeric: true }) || a.document_id - b.document_id,
    category: (a, b) => labelOf(State.categories, a.category).localeCompare(labelOf(State.categories, b.category)) || dateKey(a).localeCompare(dateKey(b)) || a.document_id - b.document_id,
    number: (a, b) => a.document_id - b.document_id,
  }[how] || ((a, b) => a.document_id - b.document_id);
  return [...rows].sort(by);
}
const inYears = (d, f) => {
  if (!f.from && !f.to) return true;
  const y = yearOf(d.ref_date, d.ref_period);
  if (y === 'XXXX') return false;
  return (!f.from || y >= f.from) && (!f.to || y <= f.to);
};

const langsHtml = langs => `<span class="fw-langs">${(langs || []).map(l => `<i title="${esc(langName(l))}">${esc(LANG_SHORT[l] || l)}</i>`).join('') || '—'}</span>`;
const langsText = langs => (langs || []).map(langName).join(', ');
const taskHtml = r => (r.task_id ? `<span class="fw-task">Task #${esc(r.task_id)} ${esc(TASK_STATE[r.task_status] || r.task_status || '')}</span>` : '');

// The columns of each kind of search: [header, html(row), text(row) for Excel].
function columnsFor(s, f) {
  const title = ['Title', d => { const t = titleTrio(d); return `${t.en ? `<b dir="auto">${esc(t.en)}</b>` : ''}${t.ur ? `<span class="fw-ur" dir="rtl" lang="ur">${esc(t.ur)}</span>` : ''}${t.it ? `<span class="fw-it" dir="auto" lang="it">${esc(t.it)}</span>` : ''}${!t.en && !t.ur && !t.it ? '<span class="hint">(no title)</span>' : ''}`; },
    d => { const t = titleTrio(d); return [t.en, t.ur, t.it].filter(Boolean).join(' / '); }];
  const num = ['#', d => `#${esc(d.document_id)}`, d => d.document_id];
  const date = ['Date', d => esc(docDateLabel(d)), d => d.ref_date || d.ref_period || ''];
  const category = ['Category', d => esc(labelOf(State.categories, d.category)), d => labelOf(State.categories, d.category)];
  const langs = ['Languages', d => langsHtml(d.languages), d => langsText(d.languages)];
  const pages = ['Pages', d => esc(d.pages ?? ''), d => d.pages ?? ''];
  const task = ['Task', d => taskHtml(d), d => (d.task_id ? `#${d.task_id} ${TASK_STATE[d.task_status] || ''}` : '')];
  if (s.kind === 'wol') {
    return [['Month', r => esc(MONTH(r.ym)), r => r.ym], ['Languages there', r => langsHtml(r.langs), r => langsText(r.langs)],
      ['Text to start from', r => (r.source ? `#${esc(r.source.document_id)} ${esc(langName(r.source.language))}` : '<span class="hint">None: find it first</span>'), r => (r.source ? `#${r.source.document_id} ${langName(r.source.language)}` : 'None')],
      ['Task', r => taskHtml(r), r => (r.task_id ? `#${r.task_id} ${TASK_STATE[r.task_status] || ''}` : '')]];
  }
  if (s.kind === 'texts') {
    const length = ['Length', d => (d.char_count ? `${Math.max(1, Math.round(d.char_count / 1800))} p.` : esc(d.pages ?? '')), d => d.char_count || ''];
    const source = ['Source', d => esc(d.source || ''), d => d.source || ''];
    return s.p === 'read_aloud' ? [num, date, title, category, source, length] : [num, date, title, category, ['Language', d => esc(langName(d.language)), d => langName(d.language)], source, pages, task];
  }
  if (s.kind === 'details') return [num, date, title, category, ['Language', d => esc(langName(d.language)), d => langName(d.language)], task];
  if (s.kind === 'dups') return [num, date, title, category, ['Language', d => esc(langName(d.language)), d => langName(d.language)], ['Same as', d => esc(d.note || ''), d => d.note || '']];
  return [num, date, title, category, langs, pages, task];
}

function filtersHtml(s, f) {
  const sel = (id, label, list, value, empty) => `<div class="field"><label for="${id}">${label}</label><select id="${id}">${optionsHtml(list, value, !!empty, empty || '')}</select></div>`;
  const year = (id, label, value) => `<div class="field fw-year"><label for="${id}">${label}</label><input id="${id}" inputmode="numeric" maxlength="4" placeholder="—" value="${esc(value)}"></div>`;
  const categories = sel('fw-category', 'Category', State.categories, f.category, 'All');
  const sort = sel('fw-sort', 'Sort by', SORTS, f.sort);
  if (s.kind === 'wol') {
    return `<div class="field"><label for="fw-wol-from">From</label><input id="fw-wol-from" type="month" value="${esc(f.wolFrom)}"></div>
      <div class="field"><label for="fw-wol-to">To</label><input id="fw-wol-to" type="month" value="${esc(f.wolTo)}"></div>
      ${sel('fw-wol-missing', 'Missing in', State.langs, f.wolMissing)}`;
  }
  if (s.kind === 'lang') return `${s.choose ? sel('fw-has', 'Has', State.langs, f.has) + sel('fw-missing', 'Is missing', State.langs, f.missing) : ''}${categories}${year('fw-from', 'From year', f.from)}${year('fw-to', 'To year', f.to)}${sort}`;
  if (s.kind === 'texts') return `${s.p === 'read_aloud' ? '' : sel('fw-language', 'Language', State.langs, f.language, 'All')}${categories}${s.p === 'not_reread' ? sel('fw-source', 'Source', State.sources, f.source, 'All') : ''}${sort}`;
  if (s.kind === 'details') return `${sel('fw-what', 'Missing', DETAILS, f.what)}${categories}${sel('fw-language', 'Language', State.langs, f.language, 'All')}${sort}`;
  return `${categories}${sort}`;
}

function readFilters(main, f) {
  const v = id => main.querySelector('#' + id)?.value;
  for (const [id, key] of [['fw-category', 'category'], ['fw-sort', 'sort'], ['fw-has', 'has'], ['fw-missing', 'missing'], ['fw-language', 'language'],
    ['fw-source', 'source'], ['fw-what', 'what'], ['fw-wol-from', 'wolFrom'], ['fw-wol-to', 'wolTo'], ['fw-wol-missing', 'wolMissing']]) if (v(id) !== undefined) f[key] = v(id);
  for (const [id, key] of [['fw-from', 'from'], ['fw-to', 'to']]) if (v(id) !== undefined) f[key] = (v(id) || '').replace(/\D/g, '').slice(0, 4);
}

// What the filters say, in words, for the printed sheet and the file.
function filtersText(s, f) {
  const parts = [];
  if (s.kind === 'wol') return `From ${MONTH(f.wolFrom)} to ${MONTH(f.wolTo)} · Missing in ${langName(f.wolMissing)}`;
  if (s.choose) parts.push(`Has ${langName(f.has)}, missing ${langName(f.missing)}`);
  if (s.kind === 'details') parts.push(`Missing: ${labelOf(DETAILS, f.what)}`);
  if (s.kind === 'texts' && s.p !== 'read_aloud') parts.push(`Language: ${f.language ? langName(f.language) : 'All'}`);
  if (s.kind === 'details' && f.language) parts.push(`Language: ${langName(f.language)}`);
  parts.push(`Category: ${f.category ? labelOf(State.categories, f.category) : 'All'}`);
  if (s.p === 'not_reread' && f.source) parts.push(`Source: ${f.source}`);
  if (s.kind === 'lang' && (f.from || f.to)) parts.push(`Years: ${f.from || '…'}–${f.to || '…'}`);
  if (s.kind !== 'wol') parts.push(`Sorted by ${labelOf(SORTS, f.sort).toLowerCase()}`);
  return parts.join(' · ');
}

export async function renderFindWorkView(main) {
  if (!canFindWork()) { main.innerHTML = '<div class="empty-msg">This page is for Admins, Coordinators and the leads of a department.</div>'; return; }
  const f = st();
  const s = searchOf(f.key);
  const canTask = canReviewApplications();
  const groups = [...new Set(SEARCHES.map(x => x.group))];
  main.innerHTML = `
    <div class="fw-page">
      <nav class="fw-side no-print" aria-label="Searches">${groups.map(g => `<h3>${esc(g)}</h3>${SEARCHES.filter(x => x.group === g).map(x => `
        <button type="button" class="fw-search${x.key === s.key ? ' on' : ''}" data-key="${x.key}" ${x.key === s.key ? 'aria-current="true"' : ''}><b>${esc(x.name)}</b><span>${esc(x.note)}</span></button>`).join('')}`).join('')}</nav>
      <div class="fw-main">
        <div class="panel no-print">
          <h2 style="margin-top:0;">${esc(s.name)}</h2>
          <p class="hint" style="margin-top:-6px;">${esc(s.note)}.${s.kind === 'lang' || s.kind === 'wol' ? ' A language is there when a version has a typed text or a PDF.' : ''}</p>
          <div class="field-grid fw-filters">${filtersHtml(s, f)}</div>
          <div class="btn-row"><button class="btn" id="fw-show">Show</button></div>
        </div>
        <div id="fw-result"></div>
      </div>
    </div>
    <style>@media print { @page { size: A4 landscape; margin: 12mm; @bottom-right { content: "Page " counter(page) " of " counter(pages); font: 10px sans-serif; } } }</style>`;
  main.querySelectorAll('[data-key]').forEach(b => b.addEventListener('click', () => {
    if (b.dataset.key === f.key) return;
    f.key = b.dataset.key; f.rows = null; f.ran = '';
    renderFindWorkView(main);
  }));
  main.querySelector('#fw-show').addEventListener('click', async () => { readFilters(main, f); await show(main, s, f, canTask, true); });
  // Coming back from a document's card shows the same list again, without asking the server.
  if (f.rows && f.ran === s.key) await show(main, s, f, canTask, false);
}

async function show(main, s, f, canTask, fresh) {
  const area = main.querySelector('#fw-result');
  if (s.kind === 'wol' && (!/^\d{4}-\d{2}$/.test(f.wolFrom) || !/^\d{4}-\d{2}$/.test(f.wolTo) || f.wolFrom > f.wolTo)) {
    area.innerHTML = '<div class="empty-msg">Choose two months, the first before the second.</div>'; return;
  }
  if (fresh || !f.rows) {
    area.innerHTML = '<div class="empty-msg">Searching...</div>';
    try { f.rows = await runSearch(s, f); f.ran = s.key; } catch { area.innerHTML = '<div class="empty-msg">The search did not work. Please try again.</div>'; return; }
  }
  let rows = s.kind === 'wol' ? await wolMonths(f.rows, f) : sortRows(f.rows.filter(d => (s.kind !== 'lang' || inYears(d, f)) && (s.p !== 'not_reread' || !f.source || d.source === f.source)), f.sort);
  if (main.querySelector('#fw-result') !== area) return;
  const cols = columnsFor(s, f);
  const tasksHere = canTask && !s.noTasks;
  const free = r => !r.task_id;
  const keyOf = r => (s.kind === 'wol' ? r.ym : String(r.document_id));
  const chosen = new Set(tasksHere ? rows.filter(free).map(keyOf) : []);
  const who = await getDisplayNameByEmail((await sb.auth.getUser()).data.user?.email).catch(() => '');
  const shownCount = rows.length;
  area.innerHTML = `
    <div class="panel fw-sheet">
      <div class="fw-print-head"><div><h2>${esc(s.name)}</h2><div>${esc(filtersText(s, f))} · ${shownCount} found</div></div>
        <div class="fw-print-who">DUA · Find work to do<br>Printed ${esc(new Date().toLocaleDateString('en', { day: 'numeric', month: 'short', year: 'numeric' }))}${who ? ` by ${esc(who)}` : ''}</div></div>
      ${s.kind === 'wol' ? calendarHtml(rows.calendar, f.wolMissing) : ''}
      <div class="fw-count no-print"><b>${shownCount}</b> ${s.kind === 'wol' ? (shownCount === 1 ? 'month' : 'months') : 'found'}${s.kind === 'wol' ? ` without ${esc(langName(f.wolMissing))}` : ''}</div>
      ${shownCount ? `<div class="fw-table-wrap"><table class="fw-table">
        <thead><tr>${tasksHere ? '<th class="fw-ck no-print"><input type="checkbox" id="fw-all" aria-label="Choose all"></th>' : ''}${cols.map(c => `<th>${esc(c[0])}</th>`).join('')}</tr></thead>
        <tbody>${rows.map((r, i) => `<tr class="${r.task_id ? 'fw-has-task' : ''}${s.kind === 'wol' && !r.source ? '' : ' fw-open'}" data-i="${i}">
          ${tasksHere ? `<td class="fw-ck no-print">${free(r) ? `<input type="checkbox" data-ck="${esc(keyOf(r))}" checked aria-label="Choose">` : ''}</td>` : ''}
          ${cols.map(c => `<td${c[0] === 'Title' ? ' class="fw-title"' : ` data-h="${esc(c[0])}"`}>${c[1](r)}</td>`).join('')}</tr>`).join('')}</tbody></table></div>
        <p class="hint no-print">${tasksHere ? 'A row with a task already is not chosen. ' : ''}${s.kind === 'wol' ? 'A month opens the text to start from.' : 'A row opens the card of its document.'}${s.noTasks && canTask ? ' ' + esc(s.noTasks) : ''}</p>`
      : '<div class="empty-msg">Nothing is missing here. Thank you!</div>'}
      <div class="pf-bottom no-print"><span class="hint" id="fw-chosen"></span>
        <button class="btn secondary" id="fw-print" ${shownCount ? '' : 'disabled'}>Print</button>
        <button class="btn secondary" id="fw-excel" ${shownCount ? '' : 'disabled'}>Download for Excel</button>
        ${tasksHere ? '<button class="btn" id="fw-tasks">Create tasks</button>' : ''}</div>
    </div>`;
  const chosenNote = () => {
    const el = area.querySelector('#fw-chosen');
    if (el) el.textContent = tasksHere ? `${chosen.size} chosen` : '';
    const btn = area.querySelector('#fw-tasks');
    if (btn) btn.disabled = !chosen.size;
    const all = area.querySelector('#fw-all'), free = rows.filter(r => !r.task_id).length;
    if (all) { all.checked = free > 0 && chosen.size === free; all.indeterminate = chosen.size > 0 && chosen.size < free; }
  };
  chosenNote();
  area.querySelectorAll('[data-ck]').forEach(c => c.addEventListener('change', () => { c.checked ? chosen.add(c.dataset.ck) : chosen.delete(c.dataset.ck); chosenNote(); }));
  area.querySelector('#fw-all')?.addEventListener('change', e => {
    area.querySelectorAll('[data-ck]').forEach(c => { c.checked = e.target.checked; e.target.checked ? chosen.add(c.dataset.ck) : chosen.delete(c.dataset.ck); });
    chosenNote();
  });
  area.querySelectorAll('tr.fw-open').forEach(tr => tr.addEventListener('click', e => {
    if (e.target.closest('.fw-ck')) return;
    const r = rows[+tr.dataset.i], id = s.kind === 'wol' ? r.source?.document_id : r.document_id;
    if (id) window.__renderTab('dashboard', State.place, 'doc/' + id);
  }));
  area.querySelector('#fw-print').addEventListener('click', () => window.print());
  area.querySelector('#fw-excel').addEventListener('click', () => downloadForExcel(s, f, cols, rows));
  area.querySelector('#fw-tasks')?.addEventListener('click', () => createTasks(main, s, f, rows.filter(r => chosen.has(keyOf(r)))));
}

// The Word of Life as a calendar: a line for each year, a box for each month with the languages there; a box without the
// language looked for is pink.
function calendarHtml(months, missing) {
  const years = new Map();
  for (const m of months) (years.get(m.ym.slice(0, 4)) || years.set(m.ym.slice(0, 4), {}).get(m.ym.slice(0, 4)))[+m.ym.slice(5)] = m.langs;
  const head = ['', ...'JFMAMJJASOND'].map(x => `<span class="fw-cal-h">${x}</span>`).join('');
  return `<div class="fw-cal" role="img" aria-label="Calendar of the Word of Life: a pink box is a month without ${esc(langName(missing))}">${head}${[...years].map(([y, ms]) => `<b>${y}</b>${
    Array.from({ length: 12 }, (_, i) => { const l = ms[i + 1]; if (!l) return '<span class="fw-cal-out"></span>';
      return `<span class="fw-cal-m${l.includes(missing) ? '' : ' gap'}" title="${esc(MONTH(`${y}-${String(i + 1).padStart(2, '0')}`))}">${l.map(x => `<i>${esc(LANG_SHORT[x] || x)}</i>`).join('')}</span>`; }).join('')}`).join('')}</div>`;
}

// Tab-separated text in UTF-16: Excel opens it in columns with any language setting, Urdu included.
function downloadForExcel(s, f, cols, rows) {
  const cell = v => String(v ?? '').replace(/[\t\r\n]+/g, ' ');
  const lines = [[s.name], [filtersText(s, f)], [], cols.map(c => c[0]), ...rows.map(r => cols.map(c => c[2](r)))].map(l => l.map(cell).join('\t'));
  const text = '﻿' + lines.join('\r\n');
  const buf = new Uint8Array(text.length * 2);
  for (let i = 0; i < text.length; i++) { const c = text.charCodeAt(i); buf[i * 2] = c & 255; buf[i * 2 + 1] = c >> 8; }
  const a = document.createElement('a');
  a.href = URL.createObjectURL(new Blob([buf], { type: 'text/csv;charset=utf-16le' }));
  a.download = `find-work-${s.key}-${today()}.csv`;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 2000);
}

// One task for each chosen row, open in the Tasks store. Credits as everywhere: the rate of the category × the pages,
// read from the PDF when the document does not say. A row whose pages cannot be read is left out, and said.
async function createTasks(main, s, f, picked) {
  if (!picked.length) return;
  const isWol = s.kind === 'wol';
  const base = isWol ? null : s.kind === 'lang' ? langTask(s, f) : { cat: s.task || 'OTHER', verb: s.verb || 'Work on it' };
  const firstCat = isWol ? picked[0].cat : base.cat;
  const { panel, close } = popupShell('fw-task-popup', { width: 560, label: 'Create tasks', section: 'findwork' });
  const titleFor = r => (isWol ? r.title : `${base.verb}: ${titleOf(r) || '#' + r.document_id}`);
  panel.innerHTML = `
    <h2 style="margin-top:0;">Create ${picked.length} task${picked.length === 1 ? '' : 's'}</h2>
    <p class="hint">One for each row you chose. They go to the Tasks store, open, for anyone who can do them.</p>
    <div class="field-grid">
      <div class="field" style="grid-column:1/-1;"><label for="fw-t-cat">Category</label><select id="fw-t-cat">${optionsHtml(State.optionListsByName.task_category || [], firstCat, false)}</select>
        ${isWol ? '<div class="hint">For the Word of Life each month keeps its own: from Italian or English into Urdu, or Others to find it.</div>' : ''}</div>
      <div class="field" style="grid-column:1/-1;"><label>Title, for example</label><div>${esc(titleFor(picked[0]))}</div></div>
    </div>
    <p class="hint">Credits: the rate of the category × the pages, as for every task. The app reads the pages from each PDF that does not say.</p>
    <div id="fw-t-msg" class="hint" role="status"></div>
    <div class="btn-row"><button class="btn secondary" id="fw-t-cancel">Cancel</button><button class="btn" id="fw-t-go">Create ${picked.length} task${picked.length === 1 ? '' : 's'}</button></div>`;
  if (isWol) panel.querySelector('#fw-t-cat').disabled = true;
  panel.querySelector('#fw-t-cancel').addEventListener('click', close);
  panel.querySelector('#fw-t-go').addEventListener('click', async () => {
    const go = panel.querySelector('#fw-t-go'), msg = panel.querySelector('#fw-t-msg');
    go.disabled = true; panel.querySelector('#fw-t-cancel').disabled = true;
    const chosenCat = panel.querySelector('#fw-t-cat').value;
    try {
      const rates = Object.fromEntries(((await withStatus(sb.from('task_category_rates').select('category,credits_per_page'))) || []).map(r => [r.category, Number(r.credits_per_page) || 0]));
      const docIds = picked.map(r => (isWol ? r.source?.document_id : r.document_id)).filter(Boolean);
      const docs = docIds.length ? await withStatus(sb.from('documents').select('document_id,pages,file_name,storage_path').in('document_id', docIds)) : [];
      const docOf = Object.fromEntries(docs.map(d => [d.document_id, d]));
      // Again, just before creating: a task made meanwhile by someone else is not made twice.
      const already = docIds.length ? new Set((await withStatus(sb.from('tasks').select('document_id').in('document_id', docIds).in('status', ACTIVE_TASK))).map(t => t.document_id)) : new Set();
      const { data: { user } } = await sb.auth.getUser();
      const out = [], skippedTask = [], skippedPages = [];
      for (const [i, r] of picked.entries()) {
        const docId = isWol ? r.source?.document_id || null : r.document_id;
        if (docId && already.has(docId)) { skippedTask.push(docId); continue; }
        const cat = isWol ? r.cat : chosenCat;
        let pages = docId ? (isWol ? r.source?.pages : r.pages) ?? docOf[docId]?.pages ?? null : null;
        if (docId && pages == null && docOf[docId] && (docOf[docId].file_name || docOf[docId].storage_path)) {
          msg.textContent = `Reading the pages: ${i + 1} of ${picked.length}...`;
          pages = await readPdfPageCount(docOf[docId]).catch(() => null);
          if (pages != null) await sb.from('documents').update({ pages }).eq('document_id', docId).then(() => {}, () => {});
        }
        if (docId && pages == null) { skippedPages.push(docId); continue; }
        const baseCredits = Math.round((rates[cat] || 0) * (pages || 0));
        out.push({ title: titleFor(r), description: `From Find work to do: ${s.name}.`, category: cat, document_id: docId, document_pages: pages,
          base_credits: baseCredits, extra_credits: 0, extra_credits_note: null, credits: baseCredits, created_by_email: user.email, status: 'open' });
      }
      msg.textContent = 'Creating the tasks...';
      if (out.length) await withStatus(sb.from('tasks').insert(out), 'Creating tasks...');
      close();
      const lines = [`${out.length} task${out.length === 1 ? '' : 's'} created. ${out.length ? 'They are in the Tasks store.' : ''}`];
      if (skippedTask.length) lines.push(`${skippedTask.length} already had a task: left out.`);
      if (skippedPages.length) lines.push(`${skippedPages.length} PDF${skippedPages.length === 1 ? '' : 's'} could not be read, so no task: ${skippedPages.map(x => '#' + x).join(', ')}. Open the card to set the pages.`);
      await alertPopup(lines.join('\n'));
      if (main.dataset.section === 'findwork') { st().rows = null; await show(main, s, f, true, true); }
    } catch (e) {
      msg.textContent = 'The tasks could not be created: ' + (e.message || e);
      go.disabled = false; panel.querySelector('#fw-t-cancel').disabled = false;
    }
  });
}
