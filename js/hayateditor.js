// Hayat Editor: fast inline-editing grid for one Hayat magazine edition (month-year) at a
// time, instead of correcting index rows one popup at a time. Tab/Shift+Tab move between
// cells for free (they're just DOM inputs in row order); Enter saves the current row. Autore/
// Categoria/Branca/Argomento are comboboxes (free text + suggestions) - new values are only
// written to option_lists once the row is actually extracted into a document (SessionCache in
// the meantime), per the project's "don't pollute a fixed vocabulary with unreviewed values"
// rule that also applies to Bulk Import and the rest of this session's schema changes.

import { sb, State, esc, today, canWrite, withStatus, extractHayatRowToDocument, SessionCache } from './core.js?v=20260825114048';
import { comboboxHtml, wireCombobox } from './combobox.js?v=20260825114048';

let currentRows = [];

export async function renderHayatEditorView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Hayat Editor</h2>
      <p class="hint">Edit one Hayat edition at a time. Tab/Shift+Tab to move between fields, Enter to save the current row. Autore/Categoria/Branca/Argomento accept new values - they're only added to the shared lists when that row is extracted.</p>
      <div class="field" style="max-width:280px;">
        <label>Edition (Month-Year)</label>
        <select id="he-edition"><option value="">Loading…</option></select>
      </div>
      <div class="hint" id="he-progress" style="margin-bottom:10px;"></div>
      <div class="btn-row">
        ${canWrite() ? `
        <button class="btn" id="he-add-row">+ Add row</button>
        <button class="btn" id="he-extract">Extract selected</button>
        <button class="btn danger" id="he-delete">Delete selected</button>
        <button class="btn secondary" id="he-duplicate">Duplicate selected</button>
        <button class="btn secondary" id="he-import">Import CSV</button>
        <input type="file" id="he-import-file" accept=".csv" style="display:none;">` : ''}
        <button class="btn secondary" id="he-export">Export CSV</button>
      </div>
      <div class="grid-wrap" style="max-height:65vh;overflow:auto;"><table class="grid" id="he-grid"></table></div>
    </div>`;

  await populateEditionSelect();
  document.getElementById('he-edition').addEventListener('change', e => {
    State.hayatEditorEdition = e.target.value;
    refreshHayatEditorGrid();
  });
  if (canWrite()) {
    document.getElementById('he-add-row').addEventListener('click', addRow);
    document.getElementById('he-extract').addEventListener('click', extractSelected);
    document.getElementById('he-delete').addEventListener('click', deleteSelected);
    document.getElementById('he-duplicate').addEventListener('click', duplicateSelected);
    document.getElementById('he-import').addEventListener('click', () => document.getElementById('he-import-file').click());
    document.getElementById('he-import-file').addEventListener('change', importCsv);
  }
  document.getElementById('he-export').addEventListener('click', exportCsv);

  await refreshHayatEditorGrid();
}

async function populateEditionSelect() {
  const sel = document.getElementById('he-edition');
  const rows = await withStatus(sb.from('hayat_indice').select('mese_anno'));
  const editions = [...new Set(rows.map(r => r.mese_anno).filter(Boolean))].sort();
  if (!State.hayatEditorEdition || !editions.includes(State.hayatEditorEdition)) {
    State.hayatEditorEdition = editions[editions.length - 1] || '';
  }
  sel.innerHTML = editions.map(e => `<option value="${esc(e)}" ${e === State.hayatEditorEdition ? 'selected' : ''}>${esc(e)}</option>`).join('')
    || '<option value="">No editions yet</option>';
}

const HE_COMBO_FIELDS = [
  ['autore', 'hayat_author', 'Autore'],
  ['category', 'category', 'Categoria'],
  ['branca', 'recipient', 'Branca'],
  ['argomento', 'hayat_argomento', 'Argomento'],
];

function rowHtml(r) {
  const combo = (f, list, ph) => comboboxHtml({ id: `he-${f}-${r.id}`, listName: list, value: r[f], placeholder: ph });
  return `<tr data-id="${esc(r.id)}">
    <td><input type="checkbox" class="he-sel" data-id="${esc(r.id)}"></td>
    <td>${esc(r.id)}</td>
    <td><input data-f="pagina" type="number" value="${esc(r.pagina)}" style="width:70px;"></td>
    <td>${combo('autore', 'hayat_author', 'Autore')}</td>
    <td><input data-f="titolo" value="${esc(r.titolo)}" placeholder="Titolo (Urdu)" style="min-width:160px;" dir="auto"></td>
    <td><input data-f="title" value="${esc(r.title)}" placeholder="Title (EN)" style="min-width:160px;"></td>
    <td>${combo('category', 'category', 'Categoria')}</td>
    <td>${combo('branca', 'recipient', 'Branca')}</td>
    <td>${combo('argomento', 'hayat_argomento', 'Argomento')}</td>
    <td>${r.estratto ? `<span class="count-badge">${esc(r.estratto)}${r.idtranscription ? ` &rarr; #${esc(r.idtranscription)}` : ''}</span>` : '<span class="hint">not extracted</span>'}</td>
  </tr>`;
}

export async function refreshHayatEditorGrid() {
  const grid = document.getElementById('he-grid');
  if (!grid || !State.hayatEditorEdition) {
    if (grid) grid.innerHTML = '';
    document.getElementById('he-progress').textContent = '';
    return;
  }
  currentRows = await withStatus(sb.from('hayat_indice').select('*').eq('mese_anno', State.hayatEditorEdition).order('pagina'), 'Loading edition...');
  const extractedCount = currentRows.filter(r => r.estratto).length;
  document.getElementById('he-progress').textContent = `${extractedCount} of ${currentRows.length} articles extracted in this edition`;

  const readOnly = !canWrite();
  grid.innerHTML = `<thead><tr>
      <th></th><th>ID</th><th>Pagina</th><th>Autore</th><th>Titolo (Urdu)</th><th>Title (EN)</th>
      <th>Categoria</th><th>Branca</th><th>Argomento</th><th>Estratto</th>
    </tr></thead>
    <tbody>${currentRows.map(rowHtml).join('')}</tbody>`;

  for (const r of currentRows) {
    for (const [field, listName] of HE_COMBO_FIELDS) wireCombobox({ id: `he-${field}-${r.id}`, listName });
  }
  if (readOnly) {
    grid.querySelectorAll('input,select').forEach(el => el.disabled = true);
    return;
  }
  grid.querySelectorAll('tbody tr').forEach(tr => {
    tr.querySelectorAll('input[data-f], input[id^="he-"]').forEach(el => {
      el.addEventListener('keydown', e => {
        if (e.key === 'Enter') { e.preventDefault(); saveRow(tr); }
      });
    });
  });
}

function collectRow(tr) {
  const id = tr.dataset.id;
  const out = { id };
  tr.querySelectorAll('[data-f]').forEach(el => out[el.dataset.f] = el.value === '' ? null : el.value);
  for (const [field] of HE_COMBO_FIELDS) {
    const el = document.getElementById(`he-${field}-${id}`);
    out[field] = el.value.trim() === '' ? null : el.value.trim();
  }
  return out;
}

async function saveRow(tr) {
  const vals = collectRow(tr);
  const { id, ...fields } = vals;
  await withStatus(sb.from('hayat_indice').update(fields).eq('id', id), 'Saving row...');
  const local = currentRows.find(r => String(r.id) === String(id));
  if (local) Object.assign(local, fields);
}

function selectedIds() {
  return Array.from(document.querySelectorAll('.he-sel:checked')).map(cb => cb.dataset.id);
}

async function addRow() {
  const maxRows = await withStatus(sb.from('hayat_indice').select('id').order('id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.id || 0) + 1;
  await withStatus(sb.from('hayat_indice').insert({ id: newId, mese_anno: State.hayatEditorEdition }), 'Adding row...');
  await refreshHayatEditorGrid();
}

async function deleteSelected() {
  const ids = selectedIds();
  if (!ids.length) { alert('Select at least one row first.'); return; }
  if (!confirm(`Permanently delete ${ids.length} Hayat index row(s)? This cannot be undone.`)) return;
  await withStatus(sb.from('hayat_indice').delete().in('id', ids), 'Deleting...');
  await refreshHayatEditorGrid();
}

async function duplicateSelected() {
  const ids = selectedIds();
  if (!ids.length) { alert('Select at least one row first.'); return; }
  let maxRows = await withStatus(sb.from('hayat_indice').select('id').order('id', { ascending: false }).limit(1));
  let nextId = (maxRows[0]?.id || 0) + 1;
  for (const id of ids) {
    const src = currentRows.find(r => String(r.id) === String(id));
    if (!src) continue;
    const { id: _old, estratto, idtranscription, updated_at, ...rest } = src;
    await withStatus(sb.from('hayat_indice').insert({ ...rest, id: nextId }), 'Duplicating...');
    nextId++;
  }
  await refreshHayatEditorGrid();
}

async function extractSelected() {
  const ids = selectedIds();
  if (!ids.length) { alert('Select at least one row first.'); return; }
  const toExtract = currentRows.filter(r => ids.includes(String(r.id)) && !r.estratto);
  if (!toExtract.length) { alert('All selected rows are already extracted.'); return; }
  if (!confirm(`Extract ${toExtract.length} row(s) into new documents?`)) return;
  let done = 0;
  for (const row of toExtract) {
    const tr = document.querySelector(`tr[data-id="${row.id}"]`);
    const fresh = collectRow(tr);
    await saveRow(tr);
    await extractHayatRowToDocument({ ...row, ...fresh });
    await SessionCache.persistUsed({
      hayat_author: fresh.autore ? [[fresh.autore, fresh.autore]] : [],
      category: fresh.category ? [[fresh.category, fresh.category]] : [],
      recipient: fresh.branca ? [[fresh.branca, fresh.branca]] : [],
      hayat_argomento: fresh.argomento ? [[fresh.argomento, fresh.argomento]] : [],
    });
    done++;
  }
  alert(`Extracted ${done} document(s).`);
  await refreshHayatEditorGrid();
}

function csvEscape(v) {
  const s = v === null || v === undefined ? '' : String(v);
  return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}
const CSV_COLUMNS = ['pagina', 'autore', 'titolo', 'title', 'category', 'branca', 'argomento'];

function exportCsv() {
  if (!currentRows.length) { alert('Nothing to export for this edition.'); return; }
  const header = CSV_COLUMNS.join(',');
  const body = currentRows.map(r => CSV_COLUMNS.map(c => csvEscape(r[c])).join(',')).join('\n');
  const blob = new Blob([header + '\n' + body], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = `hayat-${State.hayatEditorEdition || 'export'}.csv`;
  document.body.appendChild(a); a.click(); a.remove();
  URL.revokeObjectURL(url);
}

function parseCsvLine(line) {
  const out = []; let cur = ''; let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (inQuotes) {
      if (c === '"' && line[i + 1] === '"') { cur += '"'; i++; }
      else if (c === '"') inQuotes = false;
      else cur += c;
    } else if (c === '"') inQuotes = true;
    else if (c === ',') { out.push(cur); cur = ''; }
    else cur += c;
  }
  out.push(cur);
  return out;
}

async function importCsv(e) {
  const file = e.target.files[0];
  e.target.value = '';
  if (!file) return;
  if (!State.hayatEditorEdition) { alert('Select an edition first.'); return; }
  const text = await file.text();
  const lines = text.split(/\r?\n/).filter(l => l.trim() !== '');
  if (lines.length < 2) { alert('CSV has no data rows.'); return; }
  const header = parseCsvLine(lines[0]).map(h => h.trim());
  const rows = lines.slice(1).map(l => {
    const cells = parseCsvLine(l);
    const obj = {}; header.forEach((h, i) => { if (CSV_COLUMNS.includes(h)) obj[h] = cells[i] || null; });
    return obj;
  });
  if (!confirm(`Import ${rows.length} row(s) as new entries in edition "${State.hayatEditorEdition}"? This appends new rows - it does not update existing ones.`)) return;
  let maxRows = await withStatus(sb.from('hayat_indice').select('id').order('id', { ascending: false }).limit(1));
  let nextId = (maxRows[0]?.id || 0) + 1;
  for (const r of rows) {
    await withStatus(sb.from('hayat_indice').insert({ ...r, id: nextId, mese_anno: State.hayatEditorEdition }), 'Importing...');
    nextId++;
  }
  alert(`Imported ${rows.length} row(s).`);
  await refreshHayatEditorGrid();
}
