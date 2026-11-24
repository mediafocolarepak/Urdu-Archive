import { sb, State, esc, labelOf, optionsHtml, isAdmin, canWrite, ACCESS_LEVELS, canManageReserved, withStatus, DASH_ROW_LIMIT, DASH_SORTABLE, likeSafe, HIDDEN_DOC_STATUSES, docTitlesHtml, docCardHtml } from './core.js?v=20261123163143';
import { renderDocDetail, createNewDocument } from './docdetail.js?v=20261123163143';

// The "From the boards" section (84_boards_moderation.sql) was removed on the Owner's request, 2026-11-18: the
// Library shows only the archive; board posts are in the Boards tab.

// Which Works have a reading or a video, for the marks on the list. Those records are few.
let mediaWorks = { aud: new Set(), vid: new Set() };
async function loadMediaWorks() {
  const rows = await withStatus(sb.from('documents').select('work_id,media_type,workflow_status,external_url').in('media_type', ['AUD', 'VID']));
  const visible = rows.filter(r => r.work_id && !HIDDEN_DOC_STATUSES.includes(r.workflow_status));
  mediaWorks = {
    aud: new Set(visible.filter(r => r.media_type === 'AUD').map(r => r.work_id)),
    vid: new Set(visible.filter(r => r.media_type === 'VID' && r.external_url).map(r => r.work_id)),
  };
}
const AUDIO_ICON = '<span title="Audio" aria-label="Audio">&#128266;</span> ';
const VIDEO_ICON = '<span title="Video" aria-label="Video">&#9654;</span> ';
const mediaIcons = r => (mediaWorks.aud.has(r.work_id) ? AUDIO_ICON : '') + (mediaWorks.vid.has(r.work_id) ? VIDEO_ICON : '');

export async function renderDashboardView(main) {
  // Operator shares the simplified read/search-only Dashboard layout with User - their write
  // access still works everywhere else (Tasks, and the doc-detail panel for their own claimed
  // work), just not via this quick "+ New document" shortcut or the full editor here.
  const isUser = State.currentRole === 'user' || State.currentRole === 'operator';
  // Plain Users see this tab as "Library" (owner's request 2026-09-21) - Operator and everyone
  // else keeps "Dashboard", same layout either way (see isUser above).
  const heading = State.currentRole === 'user' ? 'Library' : 'Dashboard';

  // Plain Users (and Operators, see above) land on the archive filtered to Urdu by default
  // (the vast majority of what they consult); applied once per session so a manual change to
  // the filter later isn't silently reset on every dashboard revisit.
  if (isUser && !State.dashUserDefaultsApplied) {
    State.dashFilters.language = 'URD';
    State.dashUserDefaultsApplied = true;
  }

  // Search for readers (Owner's request, 2026-11-23): a large box with a Search button, two large choices (everything,
  // or what can be heard or watched), and the other options closed under "More search options". Urdu stays the
  // language chosen at first; it is not counted as a search the reader made.
  const media = State.dashFilters.withMedia;
  // Main topic and Source are not offered to readers (Owner's request, 2026-11-23); staff keep them.
  const isReader = State.currentRole === 'user';
  if (isReader) Object.assign(State.dashFilters, { main_topic: '', source: '' });
  main.innerHTML = `
    <div class="panel${isUser ? ' dash-user' : ''}">
      <h2>${heading} <span class="count-badge" id="dash-count"></span></h2>
      ${isUser ? '<button type="button" class="book-strip" id="dash-book"><span class="book-strip-icon" aria-hidden="true">&#128218;</span><span class="book-strip-text"><b>Read the Link-ups as a book</b><span>From the first to the last, in date order</span></span><span class="start-chevron" aria-hidden="true">&rsaquo;</span></button>' : ''}
      <div class="searchbar">
        <input id="dash-search" type="search" enterkeyhint="search" placeholder="A title or a word" value="${esc(State.dashFilters.search)}">
        <button class="btn" id="dash-search-go">&#128269; Search</button>
        ${isAdmin() ? '<button class="btn" id="dash-new">+ New document</button>' : ''}
        ${canWrite() ? '<button class="btn secondary" id="dash-propose">+ Propose content</button>' : ''}
      </div>
      <div class="btn-row dash-media-choice" role="group" aria-label="What to show">
        <button class="btn ${media ? 'secondary' : ''}" data-media="all" aria-pressed="${!media}">Everything</button>
        <button class="btn ${media ? '' : 'secondary'}" data-media="media" aria-pressed="${media}">&#128266; To listen or watch</button>
      </div>
      <div class="btn-row dash-search-tools">
        <button type="button" class="btn secondary dash-filters-toggle" id="dash-filters-toggle" aria-expanded="false" aria-controls="dash-filters"><span id="dash-filters-label">More search options</span> <span id="dash-filters-arrow" aria-hidden="true">&#9662;</span></button>
        <button type="button" class="btn secondary" id="dash-clear-filters">Clear the search</button>
      </div>
      <div class="dash-filters" id="dash-filters">
      <div class="field-grid" style="margin-bottom:10px;">
        <div class="field"><label>ID #</label><input id="dash-search-id" placeholder="ID #" value="${esc(State.dashFilters.idSearch)}"></div>
        <div class="field"><label>Category</label><select id="f-category">${optionsHtml(State.categories, State.dashFilters.category, true, 'All')}</select></div>
        <div class="field"><label>Author</label><select id="f-author">${optionsHtml(State.authors, State.dashFilters.author, true, 'All')}</select></div>
        ${isReader ? '' : `<div class="field"><label>Main topic</label><select id="f-main_topic">${optionsHtml(State.mainTopics, State.dashFilters.main_topic, true, 'All')}</select></div>`}
        ${isUser ? '' : `<div class="field"><label>Workflow status</label><select id="f-status">${optionsHtml(State.statuses, State.dashFilters.workflow_status, true, 'All')}</select></div>`}
        ${isUser && !canManageReserved() ? '' : `<div class="field"><label>Access level</label><select id="f-access">${optionsHtml(ACCESS_LEVELS, State.dashFilters.access_level, true, 'All')}</select></div>`}
        <div class="field"><label>Recipient</label><select id="f-recipient">${optionsHtml(State.recipients, State.dashFilters.recipient, true, 'All')}</select></div>
        ${isReader ? '' : `<div class="field"><label>Source</label><select id="f-source">${optionsHtml(State.sources, State.dashFilters.source, true, 'All')}</select></div>`}
        <div class="field"><label>Collection</label><select id="f-collection">${optionsHtml(State.collections, State.dashFilters.collection, true, 'All')}</select></div>
        <div class="field"><label>Language</label><select id="f-language">${optionsHtml(State.langs, State.dashFilters.language, true, 'All')}</select></div>
      </div>
      ${isUser ? '' : `<div class="field" style="display:flex;flex-wrap:wrap;gap:6px 24px;">
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-legacy" ${State.dashFilters.legacyOnly ? 'checked' : ''}> Show only documents from the original Access import
        </label>
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-pending" ${State.dashFilters.pendingOnly ? 'checked' : ''}> Show only documents marked for deletion
        </label>
      </div>`}
      </div>
      ${isAdmin() ? '<div class="btn-row"><button class="btn secondary" id="dash-export-csv">Export CSV</button></div>' : ''}
      <div class="split split-wide-left">
        <div>
          <div class="grid-wrap dash-grid-wrap" style="max-height:70vh;"><table class="grid" id="dash-grid"></table></div>
          <p class="hint dash-scroll-hint" style="margin:4px 0 0;">&larr; Scroll sideways to see more columns &rarr;</p>
          <div class="dash-sort"><label for="dash-sort">Order</label><select id="dash-sort">${DASH_SORT_OPTIONS.map(([value, label]) => `<option value="${value}">${label}</option>`).join('')}</select></div>
          <div class="dash-cards" id="dash-cards"></div>
        </div>
        <div class="dash-detail-col">
          <div class="dash-back"><button class="btn secondary back-btn" id="dash-back">&lsaquo; Back to list</button></div>
          <div class="panel" id="doc-detail" style="margin:0;"></div>
        </div>
      </div>
    </div>`;

  // On a phone the filters are a list that the Search button opens (the nine dropdowns pushed the
  // list of documents a full screen down); a choice closes it again, so the results show at once
  // (Owner's request, 2026-11-09). On a wide screen they stay open and the button is hidden by CSS.
  const filtersBox = document.getElementById('dash-filters');
  const filtersToggle = document.getElementById('dash-filters-toggle');
  const setFiltersOpen = open => {
    filtersBox.classList.toggle('open', open);
    filtersToggle.setAttribute('aria-expanded', String(open));
    document.getElementById('dash-filters-arrow').innerHTML = open ? '&#9652;' : '&#9662;';
  };
  const closeFiltersOnPhone = () => { if (window.matchMedia('(max-width: 900px)').matches) setFiltersOpen(false); };
  filtersToggle.addEventListener('click', () => setFiltersOpen(!filtersBox.classList.contains('open')));
  filtersBox.addEventListener('change', e => { if (e.target.tagName === 'SELECT' || e.target.type === 'checkbox') closeFiltersOnPhone(); });
  document.getElementById('dash-search-id').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); e.target.blur(); closeFiltersOnPhone(); }
  });
  document.getElementById('dash-clear-filters').addEventListener('click', () => clearDashSearch(main, isUser));
  document.getElementById('dash-back').addEventListener('click', () => { if (history.state && history.state.dashDetail) history.back(); else closeDocDetailScreen(); });
  window.removeEventListener('popstate', closeDocDetailScreen);
  window.addEventListener('popstate', closeDocDetailScreen);
  // The list follows the typing after a short pause, so a slow phone doesn't search for every letter; Search or Enter at once.
  const searchBox = document.getElementById('dash-search');
  let searchTimer = null;
  const searchNow = () => { clearTimeout(searchTimer); State.dashFilters.search = searchBox.value; refreshDashGrid(); };
  searchBox.addEventListener('input', () => { clearTimeout(searchTimer); searchTimer = setTimeout(searchNow, 600); });
  searchBox.addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); searchBox.blur(); searchNow(); } });
  document.getElementById('dash-search-go').addEventListener('click', () => { searchBox.blur(); searchNow(); });
  document.getElementById('dash-search-id').addEventListener('input', e => { State.dashFilters.idSearch = e.target.value; refreshDashGrid(); });
  document.getElementById('dash-propose')?.addEventListener('click', () => window.__renderTab('proposals'));
  document.getElementById('dash-book')?.addEventListener('click', () => { State.bookOpen = { code: 'linkups' }; window.__renderTab('books'); });
  const sortSelect = document.getElementById('dash-sort');
  sortSelect.value = dashSortValue();
  sortSelect.addEventListener('change', () => {
    const [col, dir] = sortSelect.value.split(':');
    State.dashSort = { col, asc: dir === 'asc' };
    refreshDashGrid();
  });
  main.querySelectorAll('[data-media]').forEach(b => b.addEventListener('click', () => {
    State.dashFilters.withMedia = b.dataset.media === 'media';
    main.querySelectorAll('[data-media]').forEach(x => {
      const on = (x.dataset.media === 'media') === State.dashFilters.withMedia;
      x.className = `btn ${on ? '' : 'secondary'}`;
      x.setAttribute('aria-pressed', String(on));
    });
    refreshDashGrid();
  }));
  if (isAdmin()) document.getElementById('dash-new').addEventListener('click', () => createNewDocument(refreshDashGrid));
  document.getElementById('f-category').addEventListener('change', e => { State.dashFilters.category = e.target.value; refreshDashGrid(); });
  document.getElementById('f-author').addEventListener('change', e => { State.dashFilters.author = e.target.value; refreshDashGrid(); });
  document.getElementById('f-main_topic')?.addEventListener('change', e => { State.dashFilters.main_topic = e.target.value; refreshDashGrid(); });
  document.getElementById('f-access')?.addEventListener('change', e => { State.dashFilters.access_level = e.target.value; refreshDashGrid(); });
  if (!isUser) {
    document.getElementById('f-status').addEventListener('change', e => { State.dashFilters.workflow_status = e.target.value; refreshDashGrid(); });
    document.getElementById('f-legacy').addEventListener('change', e => { State.dashFilters.legacyOnly = e.target.checked; refreshDashGrid(); });
    document.getElementById('f-pending').addEventListener('change', e => { State.dashFilters.pendingOnly = e.target.checked; refreshDashGrid(); });
  }
  document.getElementById('f-recipient').addEventListener('change', e => { State.dashFilters.recipient = e.target.value; refreshDashGrid(); });
  document.getElementById('f-source')?.addEventListener('change', e => { State.dashFilters.source = e.target.value; refreshDashGrid(); });
  document.getElementById('f-collection').addEventListener('change', e => { State.dashFilters.collection = e.target.value; refreshDashGrid(); });
  document.getElementById('f-language').addEventListener('change', e => { State.dashFilters.language = e.target.value; refreshDashGrid(); });
  if (isAdmin()) document.getElementById('dash-export-csv').addEventListener('click', exportDashboardCsv);

  // Escape hatch so docdetail.js can trigger a grid refresh after save/delete without
  // importing this module (which would create a circular import - see docdetail.js).
  window.__refreshDashGrid = refreshDashGrid;

  await loadMediaWorks();
  await refreshDashGrid();
  await renderDocDetail(State.selectedDocId);
  // Coming from a card that opens one document: on a phone, show it at once rather than the list.
  if (State.dashOpenDetail) {
    State.dashOpenDetail = false;
    if (window.matchMedia('(max-width: 900px)').matches) openDocDetailScreen();
  }
}

// Fase 2 (PROJECT_HANDOFF_v16.md): the search box now also reaches into the Urdu body text
// (document_texts, migration 68), not just titles and tags. search_document_texts() does its
// own normalization (yeh/kaf/heh forms, diacritics - see 68_document_texts.sql) so it finds
// matches a plain ilike on the raw text would silently miss; it can't be folded into the same
// .or() as the title/tag ilike below because it reads a different table, so it runs first as a
// separate query and its document_ids are added as one more branch of that same .or().
async function buildDashQuery(selectAll) {
  let q = sb.from('documents').select(selectAll ? '*' : 'document_id,category,author,main_topic,recipient,title,original_title,en_title,ur_title,it_title,it_title_translated,place,ref_date,ref_period,pending_deletion,is_preferred,access_level,work_id,media_type');
  const f = State.dashFilters;
  if (f.search && f.search.trim()) {
    const term = f.search.trim();
    const like = likeSafe(term);
    const textMatches = await withStatus(sb.rpc('search_document_texts', { q: term, lim: 2000 }), 'Searching text...');
    const textIds = [...new Set(textMatches.map(m => m.document_id))];
    const idsClause = textIds.length ? `,document_id.in.(${textIds.join(',')})` : '';
    q = q.or(`title.ilike.${like},original_title.ilike.${like},ur_title.ilike.${like},en_title.ilike.${like},it_title.ilike.${like},secondary_tags.ilike.${like}${idsClause}`);
  }
  if (f.idSearch && f.idSearch.trim()) {
    const idNum = parseInt(f.idSearch.trim(), 10);
    q = Number.isFinite(idNum) ? q.eq('document_id', idNum) : q.eq('document_id', -1);
  }
  // A reading is reached from its text or through this button; among the texts it would only double
  // the list (PROTOCOLLO §10.3). Looking for its number finds it anyway.
  if (f.withMedia) q = q.in('media_type', ['AUD', 'VID']);
  else if (!(f.idSearch && f.idSearch.trim())) q = q.or('media_type.is.null,media_type.neq.AUD');
  if (f.category) q = q.eq('category', f.category);
  if (f.author) q = q.eq('author', f.author);
  if (f.main_topic) q = q.eq('main_topic', f.main_topic);
  if (f.workflow_status) q = q.eq('workflow_status', f.workflow_status);
  if (f.access_level) q = q.eq('access_level', f.access_level);
  if (f.legacyOnly) q = q.eq('legacy_migrated', true);
  if (f.pendingOnly) q = q.eq('pending_deletion', true);
  if (f.recipient) q = q.overlaps('recipient', [f.recipient]);
  if (f.source) q = q.eq('source', f.source);
  if (f.language) q = q.eq('language', f.language);
  // Wrapped in an object rather than returned bare: a PostgREST query builder is itself
  // thenable, so an `async function` returning it directly gets unwrapped by the promise
  // resolution algorithm - callers awaiting buildDashQuery() would get the already-executed
  // {data, error} result instead of the chainable builder, breaking .order()/.limit() below.
  return { q };
}

// Collections are many-to-many now (document_collections), so filtering by them is a
// post-fetch join rather than a single .eq() on the documents query.
async function filterByCollection(rows) {
  const f = State.dashFilters;
  if (!f.collection) return rows;
  const matches = await withStatus(sb.from('document_collections').select('document_id').eq('collection_code', f.collection));
  const idSet = new Set(matches.map(m => m.document_id));
  return rows.filter(r => idSet.has(r.document_id));
}

// The document grid (left window) is now the same for every role (owner's request 2026-09-20) -
// One Title column with the three titles one under the other (DASH_SORTABLE, docTitlesHtml, core.js), no Recipient(s)/Ref. date.

// Column widths (% of table width, sums to 100) - #dash-grid uses table-layout:fixed (style.css)
// so these are enforced, not just hints; overflow/ellipsis (also style.css) truncates whatever
// doesn't fit, and the horizontal scrollbar on .grid-wrap (style.css) takes over once Title's
// 300px minimum (also style.css) no longer fits.
const DASH_COL_WIDTHS = { document_id: 6, en_title: 46, author: 10, place: 16, category: 22 };

let listScrollY = 0;
// The page itself never scrolls (#app is a fixed-height column); #main is the scroller.
const scrollMainTo = y => { const m = document.getElementById('main'); if (m) m.scrollTop = y; };
// On a phone the list is made of cards, with no column headers to tap: this list chooses the order instead.
// Same State.dashSort as the headers of the table on a wide screen.
const DASH_SORT_OPTIONS = [
  ['document_id:desc', 'Number: highest first'],
  ['document_id:asc', 'Number: lowest first'],
  ['en_title:asc', 'English title: A to Z'],
  ['en_title:desc', 'English title: Z to A'],
];
function dashSortValue() { return `${State.dashSort.col}:${State.dashSort.asc ? 'asc' : 'desc'}`; }

// Empty list: say so plainly, and offer to start again (Owner's request, 2026-11-23).
function emptyListHtml() {
  return `<div class="empty-msg"><p style="margin:0 0 12px;">Nothing found. Try another word.</p><button class="btn" id="dash-empty-clear">Clear the search</button></div>`;
}
// Back to the list as it is at first: everything, and for readers in Urdu, the language chosen for them.
function clearDashSearch(main, isUser) {
  Object.assign(State.dashFilters, { search: '', idSearch: '', category: '', author: '', main_topic: '', workflow_status: '', access_level: '', collection: '', recipient: '', source: '', language: isUser ? 'URD' : '', legacyOnly: false, pendingOnly: false, withMedia: false });
  renderDashboardView(main);
}

function openDocDetailScreen() {
  const split = document.querySelector('.split.split-wide-left');
  if (!split || split.classList.contains('detail-open')) { scrollMainTo(0); return; }
  listScrollY = document.getElementById('main').scrollTop;
  split.classList.add('detail-open');
  // The search tools above the list make room for the card: only Back to list stays (Owner's request, 2026-11-23).
  split.parentElement.classList.add('dash-reading');
  history.pushState({ dashDetail: true }, '');
  scrollMainTo(0);
}
function closeDocDetailScreen() {
  const split = document.querySelector('.split.split-wide-left');
  if (!split || !split.classList.contains('detail-open')) return;
  // On a phone the card is only hidden, not removed: a recording would go on playing behind the list.
  split.querySelectorAll('.dash-detail-col audio').forEach(a => a.pause());
  split.classList.remove('detail-open');
  split.parentElement.classList.remove('dash-reading');
  scrollMainTo(listScrollY);
}

export async function refreshDashGrid() {
  const grid = document.getElementById('dash-grid');
  if (!grid) return;
  const cols = DASH_SORTABLE;
  const colWidths = DASH_COL_WIDTHS;
  let rows = await withStatus((await buildDashQuery(false)).q.order(State.dashSort.col, { ascending: State.dashSort.asc, nullsFirst: false }).limit(DASH_ROW_LIMIT), 'Searching...');
  rows = await filterByCollection(rows);
  document.getElementById('dash-count').textContent = rows.length;
  const f = State.dashFilters;
  const isUser = State.currentRole === 'user' || State.currentRole === 'operator';
  const languageChanged = f.language !== (isUser ? 'URD' : '');
  const activeFilters = [f.idSearch, f.category, f.author, f.main_topic, f.workflow_status, f.access_level, f.recipient, f.source, f.collection, languageChanged, f.legacyOnly, f.pendingOnly].filter(Boolean).length;
  const sum = document.getElementById('dash-filters-label');
  if (sum) sum.textContent = activeFilters ? `More search options (${activeFilters} chosen)` : 'More search options';
  // "Clear the search" only when there is something to clear.
  const clearBtn = document.getElementById('dash-clear-filters');
  if (clearBtn) clearBtn.hidden = !(activeFilters || f.search || f.withMedia);
  const arrow = (col) => col !== State.dashSort.col ? '' : (State.dashSort.asc ? ' &uarr;' : ' &darr;');
  grid.innerHTML = `<colgroup>${Object.keys(cols).map(col => `<col style="width:${colWidths[col]}%">`).join('')}</colgroup>
    <thead><tr>${Object.entries(cols).map(([col, label]) =>
      `<th data-sort="${col}">${label}${arrow(col)}</th>`).join('')}</tr></thead>
    <tbody>${rows.map(r => {
      const star = r.is_preferred ? '&#9733; ' : '';
      return `<tr data-id="${esc(r.document_id)}" class="${String(r.document_id) === String(State.selectedDocId) ? 'selected' : ''}">
      <td>${esc(r.document_id)}${r.pending_deletion ? ' <span class="count-badge" style="padding:1px 6px;background:var(--danger);color:#fff;">pending deletion</span>' : ''}${r.access_level === 'reserved' ? ' <span class="count-badge" style="padding:1px 6px;">Reserved</span>' : ''}</td>
      <td>${docTitlesHtml(r, star + mediaIcons(r))}</td>
      <td>${esc(labelOf(State.authors, r.author))}</td>
      <td>${esc(r.place)}</td>
      <td>${esc(labelOf(State.categories, r.category))}</td>
      </tr>`;
    }).join('') || `<tr><td colspan="${Object.keys(cols).length}" style="cursor:default;">${emptyListHtml()}</td></tr>`}</tbody>`;
  grid.querySelector('#dash-empty-clear')?.addEventListener('click', () => clearDashSearch(document.getElementById('main'), isUser));
  grid.querySelectorAll('th[data-sort]').forEach(th => th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (State.dashSort.col === col) State.dashSort.asc = !State.dashSort.asc; else State.dashSort = { col, asc: true };
    refreshDashGrid();
  }));

  // Selecting only moves the highlight and loads the detail - it no longer re-queries and
  // re-renders the whole list, which threw the reader back to a different scroll position. On a
  // phone the detail replaces the list as its own screen (Back button, and the phone's own back
  // gesture, return to the list at the same place).
  const selectDoc = async id => {
    State.selectedDocId = id;
    document.querySelectorAll('#dash-grid tbody tr, #dash-cards .doc-card').forEach(el => el.classList.toggle('selected', el.dataset.id === String(id)));
    await renderDocDetail(State.selectedDocId);
    if (window.matchMedia('(max-width: 900px)').matches) openDocDetailScreen();
  };
  grid.querySelectorAll('tbody tr[data-id]').forEach(tr => tr.addEventListener('click', () => selectDoc(tr.dataset.id)));

  // Card list is the mobile-friendly alternative to the wide, horizontally-scrolling table
  // above - same rows, same click behaviour, just stacked instead of columnar. Both are
  // always in the DOM; a CSS media query (css/style.css) picks one per screen width.
  const cardsBox = document.getElementById('dash-cards');
  if (cardsBox) {
    // One large card per document: the number, the titles, the author and the date (Owner's request, 2026-11-23).
    cardsBox.innerHTML = rows.map(r => docCardHtml(r, {
      selected: String(r.document_id) === String(State.selectedDocId),
      extra: `${r.pending_deletion ? '<span class="count-badge" style="background:var(--danger);color:#fff;">pending deletion</span>' : ''}${r.access_level === 'reserved' ? '<span class="count-badge">Reserved</span>' : ''}`,
    })).join('') || emptyListHtml();
    cardsBox.querySelectorAll('.doc-card-open').forEach(el => el.addEventListener('click', () => selectDoc(el.closest('.doc-card').dataset.id)));
    cardsBox.querySelector('#dash-empty-clear')?.addEventListener('click', () => clearDashSearch(document.getElementById('main'), isUser));
  }
}

function csvEscape(v) {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

async function exportDashboardCsv() {
  let rows = await withStatus((await buildDashQuery(true)).q.order(State.dashSort.col, { ascending: State.dashSort.asc, nullsFirst: false }).limit(DASH_ROW_LIMIT), 'Exporting...');
  rows = await filterByCollection(rows);
  if (!rows.length) { alert('No documents match the current filters.'); return; }
  const columns = Object.keys(rows[0]);
  const header = columns.join(',');
  const body = rows.map(r => columns.map(c => csvEscape(Array.isArray(r[c]) ? r[c].join(';') : r[c])).join(',')).join('\n');
  const blob = new Blob([header + '\n' + body], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = 'documents-export.csv';
  document.body.appendChild(a); a.click(); a.remove();
  URL.revokeObjectURL(url);
}
