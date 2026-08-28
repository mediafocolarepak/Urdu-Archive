// Admin-only "Edit Records" tab: a dense, horizontally-scrolling grid with every editable
// document field inline (as opposed to the Dashboard, which shows a handful of columns and
// opens one record at a time in the side panel). Meant for fast bulk corrections. It does
// not recompute/rename the stored file on save - use the normal document detail Save for that.
// Collections are shown as a plain multiselect here (no per-collection page number, unlike the
// document detail page) - editing page numbers still needs the full document detail page.

import { sb, State, esc, isAdmin, withStatus, optionsHtml, BUCKET, DASH_ROW_LIMIT, likeSafe, saveDocumentCollections } from './core.js?v=20260828235923';

const EDIT_COLUMNS = [
  ['title', 'Title (EN)', 'text'],
  ['original_title', 'Original title', 'text'],
  ['ur_title', 'Ur-Title', 'text'],
  ['author', 'Author', 'select', () => State.authors],
  ['original_author', 'Author (free text)', 'text'],
  ['ref_date', 'Ref. date', 'date'],
  ['place', 'Place', 'text'],
  ['recipient', 'Recipient', 'select', () => State.recipients],
  ['category', 'Category', 'select', () => State.categories],
  ['main_topic', 'Main topic', 'select', () => State.mainTopics],
  ['secondary_tags', 'Secondary tags', 'text'],
  ['language', 'Language', 'select', () => State.langs],
  ['ref_period', 'Ref. period', 'text'],
  ['media_type', 'Media type', 'select', () => State.mediaTypes],
  ['source', 'Source', 'select', () => State.sources],
  ['operator', 'Operator', 'select', () => State.operators],
  ['physical_box', 'Physical box', 'text'],
  ['episode_number', 'Episode number', 'text'],
  ['bible_verse', 'Bible verse', 'text'],
  ['duration', 'Duration', 'text'],
  ['quality', 'Quality', 'select', () => State.qualities],
  ['workflow_status', 'Status', 'select', () => State.statuses],
  ['notes', 'Notes', 'text'],
  ['pending_deletion', 'Pending deletion', 'checkbox'],
  ['pending_deletion_note', 'Deletion note', 'text'],
  ['original_inp_file_name', 'Original .INP file', 'text'],
  ['original_doc_file_name', 'Original .DOCX file', 'text'],
  ['is_preferred', 'Preferred', 'checkbox'],
];

export async function renderAdminEditView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  const f = State.adminEditFilters;
  main.innerHTML = `
    <div class="panel">
      <h2>Edit Records <span class="count-badge" id="ae-count"></span></h2>
      <p class="hint">Every field is editable directly in the grid (except ID). Changes are only saved when you press "Save" on that row. Collections here are membership only - edit page numbers from the document's own page.</p>
      <div class="searchbar">
        <input id="ae-search" placeholder="Search by title or tags..." value="${esc(f.search)}">
      </div>
      <div class="field-grid" style="margin-bottom:10px;">
        <div class="field"><label>ID #</label><input id="ae-search-id" placeholder="ID #" value="${esc(f.idSearch)}"></div>
        <div class="field"><label>Category</label><select id="ae-f-category">${optionsHtml(State.categories, f.category, true)}</select></div>
        <div class="field"><label>Author</label><select id="ae-f-author">${optionsHtml(State.authors, f.author, true)}</select></div>
        <div class="field"><label>Main topic</label><select id="ae-f-main_topic">${optionsHtml(State.mainTopics, f.main_topic, true)}</select></div>
        <div class="field"><label>Workflow status</label><select id="ae-f-status">${optionsHtml(State.statuses, f.workflow_status, true)}</select></div>
        <div class="field"><label>Collection</label><select id="ae-f-collection">${optionsHtml(State.collections, f.collection, true)}</select></div>
        <div class="field"><label>Language</label><select id="ae-f-language">${optionsHtml(State.langs, f.language, true)}</select></div>
        <div class="field"><label>Recipient</label><select id="ae-f-recipient">${optionsHtml(State.recipients, f.recipient, true)}</select></div>
        <div class="field"><label>Source</label><select id="ae-f-source">${optionsHtml(State.sources, f.source, true)}</select></div>
      </div>
      <div class="field" style="display:flex;flex-wrap:wrap;gap:6px 24px;">
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="ae-f-legacy" ${f.legacyOnly ? 'checked' : ''}> Show only documents from the original Access import
        </label>
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="ae-f-pending" ${f.pendingOnly ? 'checked' : ''}> Show only documents marked for deletion
        </label>
      </div>
      <div class="grid-wrap" style="max-height:70vh;overflow:auto;"><table class="grid" id="ae-grid"></table></div>
    </div>`;

  document.getElementById('ae-search').addEventListener('input', e => { f.search = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-search-id').addEventListener('input', e => { f.idSearch = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-category').addEventListener('change', e => { f.category = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-author').addEventListener('change', e => { f.author = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-main_topic').addEventListener('change', e => { f.main_topic = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-status').addEventListener('change', e => { f.workflow_status = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-collection').addEventListener('change', e => { f.collection = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-language').addEventListener('change', e => { f.language = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-recipient').addEventListener('change', e => { f.recipient = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-source').addEventListener('change', e => { f.source = e.target.value; refreshAdminEditGrid(); });
  document.getElementById('ae-f-legacy').addEventListener('change', e => { f.legacyOnly = e.target.checked; refreshAdminEditGrid(); });
  document.getElementById('ae-f-pending').addEventListener('change', e => { f.pendingOnly = e.target.checked; refreshAdminEditGrid(); });

  await refreshAdminEditGrid();
}

function buildAdminEditQuery() {
  let q = sb.from('documents').select('*');
  const f = State.adminEditFilters;
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
  if (f.language) q = q.eq('language', f.language);
  if (f.recipient) q = q.overlaps('recipient', [f.recipient]);
  if (f.source) q = q.eq('source', f.source);
  if (f.legacyOnly) q = q.eq('legacy_migrated', true);
  if (f.pendingOnly) q = q.eq('pending_deletion', true);
  return q;
}

// Per-field width bumps requested 2026-08-25: Category +3ch, Title/Original title +10ch
// over the grid's normal minimums (text inputs default to 120px ~= 17ch; select had no
// explicit width before, so its baseline is estimated from its longest label).
const WIDTH_OVERRIDES = {
  title: '30ch', original_title: '30ch', category: '19ch',
  recipient: '26ch', source: '21ch', operator: '21ch',
};

function cellHtml(doc, col) {
  const [name, , type, listFn] = col;
  const value = name === 'recipient' ? (doc[name] || [])[0] : doc[name];
  const widthStyle = WIDTH_OVERRIDES[name] ? `min-width:${WIDTH_OVERRIDES[name]};` : '';
  if (type === 'select') {
    return `<select data-f="${name}" style="${widthStyle}">${optionsHtml(listFn(), value, true)}</select>`;
  }
  if (type === 'checkbox') {
    return `<input type="checkbox" data-f="${name}" ${value ? 'checked' : ''}>`;
  }
  return `<input data-f="${name}" type="${type}" value="${esc(value)}" style="min-width:120px;${widthStyle}">`;
}

function collectionsCellHtml(docId, collectionsByDoc) {
  const selected = new Set((collectionsByDoc[docId] || []).map(c => c.collection_code));
  return `<select data-collections multiple size="2" style="min-width:120px;">
    ${State.collections.map(([c, l]) => `<option value="${c}" ${selected.has(c) ? 'selected' : ''}>${l}</option>`).join('')}
  </select>`;
}

function collectRowValues(tr) {
  const out = {};
  for (const col of EDIT_COLUMNS) {
    const [name, , type] = col;
    const el = tr.querySelector(`[data-f="${name}"]`);
    if (type === 'checkbox') { out[name] = el.checked; }
    else if (name === 'recipient') { out[name] = el.value ? [el.value] : null; }
    else { out[name] = el.value === '' ? null : el.value; }
  }
  return out;
}

export async function refreshAdminEditGrid() {
  const grid = document.getElementById('ae-grid');
  if (!grid) return;
  let rows = await withStatus(buildAdminEditQuery().order('document_id', { ascending: false }).limit(DASH_ROW_LIMIT), 'Searching...');
  if (State.adminEditFilters.collection) {
    const withCollection = await withStatus(sb.from('document_collections').select('document_id').eq('collection_code', State.adminEditFilters.collection));
    const idSet = new Set(withCollection.map(r => r.document_id));
    rows = rows.filter(r => idSet.has(r.document_id));
  }
  document.getElementById('ae-count').textContent = rows.length;

  const ids = rows.map(r => r.document_id);
  const collectionRows = ids.length ? await withStatus(sb.from('document_collections').select('*').in('document_id', ids)) : [];
  const collectionsByDoc = {};
  for (const c of collectionRows) (collectionsByDoc[c.document_id] ||= []).push(c);

  grid.innerHTML = `<thead><tr>
      <th>ID</th>${EDIT_COLUMNS.map(([, label]) => `<th>${esc(label)}</th>`).join('')}<th>Collections</th><th>File name</th><th></th><th></th>
    </tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.document_id)}">
      <td>${esc(r.document_id)}</td>
      ${EDIT_COLUMNS.map(col => `<td>${cellHtml(r, col)}</td>`).join('')}
      <td>${collectionsCellHtml(r.document_id, collectionsByDoc)}</td>
      <td>${esc(r.file_name)}</td>
      <td><button class="btn secondary ae-save" style="padding:4px 10px;">Save</button></td>
      <td><button class="btn danger ae-delete" style="padding:4px 10px;">Delete</button></td>
    </tr>`).join('')}</tbody>`;

  grid.querySelectorAll('tbody tr').forEach(tr => {
    const id = tr.dataset.id;
    const saveRow = async () => {
      const vals = collectRowValues(tr);
      await withStatus(sb.from('documents').update(vals).eq('document_id', id), 'Saving...');
      const selectedCodes = Array.from(tr.querySelector('[data-collections]').selectedOptions).map(o => o.value);
      const existing = collectionsByDoc[id] || [];
      const payload = selectedCodes.map(code => {
        const prior = existing.find(c => c.collection_code === code);
        return { collection_code: code, page_number: prior ? prior.page_number : null };
      });
      await saveDocumentCollections(id, payload);
    };
    tr.querySelector('.ae-save').addEventListener('click', saveRow);
    // Enter saves the row without needing to reach for the Save button.
    tr.addEventListener('keydown', e => {
      if (e.key === 'Enter') { e.preventDefault(); saveRow(); }
    });
    // Clicking anywhere in the row also saves it - lets you edit a field then just click
    // elsewhere in the same row instead of hunting for the Save button. Skip Save (would just
    // double-fire) and Delete (a click there means delete, not save).
    tr.addEventListener('click', e => {
      if (e.target.closest('.ae-save, .ae-delete')) return;
      saveRow();
    });
    tr.querySelector('.ae-delete').addEventListener('click', async () => {
      if (!confirm(`Permanently delete document #${id}? This cannot be undone.`)) return;
      const rowData = rows.find(r => String(r.document_id) === String(id));
      if (rowData?.storage_path) await sb.storage.from(BUCKET).remove([rowData.storage_path]);
      await withStatus(sb.from('documents').delete().eq('document_id', id));
      await refreshAdminEditGrid();
    });
  });
}
