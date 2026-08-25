import { sb, State, esc, labelOf, optionsHtml, canWrite, isAdmin, withStatus, DASH_ROW_LIMIT, DASH_SORTABLE, likeSafe } from './core.js?v=20260825155642';
import { renderDocDetail, createNewDocument } from './docdetail.js?v=20260825155642';

export async function renderDashboardView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Dashboard <span class="count-badge" id="dash-count"></span></h2>
      <div class="searchbar">
        <input id="dash-search" placeholder="Search by title or tags..." value="${esc(State.dashFilters.search)}">
        ${canWrite() ? '<button class="btn" id="dash-new">+ New document</button>' : ''}
      </div>
      <div class="field-grid" style="margin-bottom:10px;">
        <div class="field"><label>ID #</label><input id="dash-search-id" placeholder="ID #" value="${esc(State.dashFilters.idSearch)}"></div>
        <div class="field"><label>Category</label><select id="f-category">${optionsHtml(State.categories, State.dashFilters.category, true)}</select></div>
        <div class="field"><label>Author</label><select id="f-author">${optionsHtml(State.authors, State.dashFilters.author, true)}</select></div>
        <div class="field"><label>Main topic</label><select id="f-main_topic">${optionsHtml(State.mainTopics, State.dashFilters.main_topic, true)}</select></div>
        <div class="field"><label>Workflow status</label><select id="f-status">${optionsHtml(State.statuses, State.dashFilters.workflow_status, true)}</select></div>
        <div class="field"><label>Recipient</label><select id="f-recipient">${optionsHtml(State.recipients, State.dashFilters.recipient, true)}</select></div>
        <div class="field"><label>Collection</label><select id="f-collection">${optionsHtml(State.collections, State.dashFilters.collection, true)}</select></div>
        <div class="field"><label>Language</label><select id="f-language">${optionsHtml(State.langs, State.dashFilters.language, true)}</select></div>
      </div>
      <div class="field" style="display:flex;flex-wrap:wrap;gap:6px 24px;">
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-legacy" ${State.dashFilters.legacyOnly ? 'checked' : ''}> Show only documents from the original Access import
        </label>
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-pending" ${State.dashFilters.pendingOnly ? 'checked' : ''}> Show only documents marked for deletion
        </label>
      </div>
      ${isAdmin() ? '<div class="btn-row"><button class="btn secondary" id="dash-export-csv">Export CSV</button></div>' : ''}
      <div class="split">
        <div>
          <div class="grid-wrap" style="max-height:70vh;"><table class="grid" id="dash-grid"></table></div>
        </div>
        <div class="panel" id="doc-detail" style="margin:0;"></div>
      </div>
    </div>`;

  document.getElementById('dash-search').addEventListener('input', e => { State.dashFilters.search = e.target.value; refreshDashGrid(); });
  document.getElementById('dash-search-id').addEventListener('input', e => { State.dashFilters.idSearch = e.target.value; refreshDashGrid(); });
  if (canWrite()) document.getElementById('dash-new').addEventListener('click', () => createNewDocument(refreshDashGrid));
  document.getElementById('f-category').addEventListener('change', e => { State.dashFilters.category = e.target.value; refreshDashGrid(); });
  document.getElementById('f-author').addEventListener('change', e => { State.dashFilters.author = e.target.value; refreshDashGrid(); });
  document.getElementById('f-main_topic').addEventListener('change', e => { State.dashFilters.main_topic = e.target.value; refreshDashGrid(); });
  document.getElementById('f-status').addEventListener('change', e => { State.dashFilters.workflow_status = e.target.value; refreshDashGrid(); });
  document.getElementById('f-legacy').addEventListener('change', e => { State.dashFilters.legacyOnly = e.target.checked; refreshDashGrid(); });
  document.getElementById('f-pending').addEventListener('change', e => { State.dashFilters.pendingOnly = e.target.checked; refreshDashGrid(); });
  document.getElementById('f-recipient').addEventListener('change', e => { State.dashFilters.recipient = e.target.value; refreshDashGrid(); });
  document.getElementById('f-collection').addEventListener('change', e => { State.dashFilters.collection = e.target.value; refreshDashGrid(); });
  document.getElementById('f-language').addEventListener('change', e => { State.dashFilters.language = e.target.value; refreshDashGrid(); });
  if (isAdmin()) document.getElementById('dash-export-csv').addEventListener('click', exportDashboardCsv);

  // Escape hatch so docdetail.js can trigger a grid refresh after save/delete without
  // importing this module (which would create a circular import - see docdetail.js).
  window.__refreshDashGrid = refreshDashGrid;

  await refreshDashGrid();
  await renderDocDetail(State.selectedDocId);
}

function buildDashQuery(selectAll) {
  let q = sb.from('documents').select(selectAll ? '*' : 'document_id,category,author,main_topic,recipient,title,original_title,place,pending_deletion,is_preferred');
  const f = State.dashFilters;
  if (f.search && f.search.trim()) {
    const like = likeSafe(f.search.trim());
    q = q.or(`title.ilike.${like},secondary_tags.ilike.${like}`);
  }
  if (f.idSearch && f.idSearch.trim()) {
    const idNum = parseInt(f.idSearch.trim(), 10);
    q = Number.isFinite(idNum) ? q.eq('document_id', idNum) : q.eq('document_id', -1);
  }
  if (f.category) q = q.eq('category', f.category);
  if (f.author) q = q.eq('author', f.author);
  if (f.main_topic) q = q.eq('main_topic', f.main_topic);
  if (f.workflow_status) q = q.eq('workflow_status', f.workflow_status);
  if (f.legacyOnly) q = q.eq('legacy_migrated', true);
  if (f.pendingOnly) q = q.eq('pending_deletion', true);
  if (f.recipient) q = q.overlaps('recipient', [f.recipient]);
  if (f.language) q = q.eq('language', f.language);
  return q;
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

export async function refreshDashGrid() {
  const grid = document.getElementById('dash-grid');
  if (!grid) return;
  let rows = await withStatus(buildDashQuery(false).order(State.dashSort.col, { ascending: State.dashSort.asc }).limit(DASH_ROW_LIMIT), 'Searching...');
  rows = await filterByCollection(rows);
  document.getElementById('dash-count').textContent = rows.length;
  const arrow = (col) => col !== State.dashSort.col ? '' : (State.dashSort.asc ? ' &uarr;' : ' &darr;');
  grid.innerHTML = `<thead><tr>${Object.entries(DASH_SORTABLE).map(([col, label]) =>
      `<th data-sort="${col}">${label}${arrow(col)}</th>`).join('')}</tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.document_id)}" class="${String(r.document_id) === String(State.selectedDocId) ? 'selected' : ''}">
      <td>${esc(r.document_id)}${r.pending_deletion ? ' <span class="count-badge" style="padding:1px 6px;background:var(--danger);color:#fff;">pending deletion</span>' : ''}</td>
      <td>${r.is_preferred ? '&#9733; ' : ''}${esc(r.title)}</td>
      <td>${esc(r.original_title)}</td>
      <td>${esc(labelOf(State.authors, r.author))}</td>
      <td>${esc(r.place)}</td>
      <td>${esc(labelOf(State.categories, r.category))}</td></tr>`).join('')}</tbody>`;
  grid.querySelectorAll('th[data-sort]').forEach(th => th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (State.dashSort.col === col) State.dashSort.asc = !State.dashSort.asc; else State.dashSort = { col, asc: true };
    refreshDashGrid();
  }));
  grid.querySelectorAll('tbody tr').forEach(tr => tr.addEventListener('click', async () => {
    State.selectedDocId = tr.dataset.id;
    await refreshDashGrid();
    await renderDocDetail(State.selectedDocId);
  }));
}

function csvEscape(v) {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

async function exportDashboardCsv() {
  let rows = await withStatus(buildDashQuery(true).order(State.dashSort.col, { ascending: State.dashSort.asc }).limit(DASH_ROW_LIMIT), 'Exporting...');
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
