import { sb, State, esc, labelOf, optionsHtml, canWrite, withStatus, DASH_ROW_LIMIT, DASH_SORTABLE, likeSafe } from './core.js?v=20260817133204';
import { renderDocDetail, createNewDocument } from './docdetail.js?v=20260817133204';

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
        <div class="field"><label>Collection</label><select id="f-collection">${optionsHtml(State.collections, State.dashFilters.collection, true)}</select></div>
      </div>
      <div class="field">
        <label>Recipient(s)</label>
        <div class="btn-row" style="margin:0;">
          ${State.recipients.map(([c, l]) => `<label style="display:flex;align-items:center;gap:4px;font-size:12.5px;font-weight:normal;text-transform:none;">
            <input type="checkbox" class="f-recipient" value="${c}" ${State.dashFilters.recipient.includes(c) ? 'checked' : ''}> ${l}</label>`).join('')}
        </div>
      </div>
      <div class="field" style="display:flex;flex-wrap:wrap;gap:6px 24px;">
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-legacy" ${State.dashFilters.legacyOnly ? 'checked' : ''}> Show legacy-migrated documents only
        </label>
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-pending" ${State.dashFilters.pendingOnly ? 'checked' : ''}> Show only documents marked for deletion
        </label>
      </div>
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
  document.getElementById('f-collection').addEventListener('change', e => { State.dashFilters.collection = e.target.value; refreshDashGrid(); });
  document.getElementById('f-legacy').addEventListener('change', e => { State.dashFilters.legacyOnly = e.target.checked; refreshDashGrid(); });
  document.getElementById('f-pending').addEventListener('change', e => { State.dashFilters.pendingOnly = e.target.checked; refreshDashGrid(); });
  main.querySelectorAll('.f-recipient').forEach(cb => cb.addEventListener('change', () => {
    State.dashFilters.recipient = Array.from(main.querySelectorAll('.f-recipient:checked')).map(c => c.value);
    refreshDashGrid();
  }));

  // Escape hatch so docdetail.js can trigger a grid refresh after save/delete without
  // importing this module (which would create a circular import - see docdetail.js).
  window.__refreshDashGrid = refreshDashGrid;

  await refreshDashGrid();
  await renderDocDetail(State.selectedDocId);
}

function buildDashQuery() {
  let q = sb.from('documents').select('document_id,category,author,main_topic,recipient,title,ref_date,workflow_status,legacy_migrated,pending_deletion');
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
  if (f.collection) q = q.eq('collection', f.collection);
  if (f.legacyOnly) q = q.eq('legacy_migrated', true);
  if (f.pendingOnly) q = q.eq('pending_deletion', true);
  if (f.recipient.length) q = q.overlaps('recipient', f.recipient);
  return q;
}

export async function refreshDashGrid() {
  const grid = document.getElementById('dash-grid');
  if (!grid) return;
  const rows = await withStatus(buildDashQuery().order(State.dashSort.col, { ascending: State.dashSort.asc }).limit(DASH_ROW_LIMIT), 'Searching...');
  document.getElementById('dash-count').textContent = rows.length;
  const arrow = (col) => col !== State.dashSort.col ? '' : (State.dashSort.asc ? ' &uarr;' : ' &darr;');
  grid.innerHTML = `<thead><tr>${Object.entries(DASH_SORTABLE).map(([col, label]) =>
      `<th data-sort="${col}">${label}${arrow(col)}</th>`).join('')}<th>Recipient(s)</th></tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.document_id)}" class="${String(r.document_id) === String(State.selectedDocId) ? 'selected' : ''}">
      <td>${esc(r.document_id)}${r.legacy_migrated ? ' <span class="count-badge" style="padding:1px 6px;">legacy</span>' : ''}${r.pending_deletion ? ' <span class="count-badge" style="padding:1px 6px;background:var(--danger);color:#fff;">pending deletion</span>' : ''}</td>
      <td>${esc(r.title)}</td><td>${esc(labelOf(State.categories, r.category))}</td><td>${esc(labelOf(State.authors, r.author))}</td>
      <td>${esc(r.ref_date)}</td><td>${esc(labelOf(State.statuses, r.workflow_status))}</td>
      <td>${(r.recipient || []).map(c => esc(labelOf(State.recipients, c))).join(', ')}</td></tr>`).join('')}</tbody>`;
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
