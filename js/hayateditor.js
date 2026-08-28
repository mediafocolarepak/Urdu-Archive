// Hayat Editor: fast inline-editing grid for one Hayat magazine edition (month-year) at a
// time, instead of correcting index rows one popup at a time. Tab/Shift+Tab move between
// cells for free (they're just DOM inputs in row order); Enter saves the current row. Autore/
// Categoria/Branca/Argomento are comboboxes (free text + suggestions) - new values are only
// written to option_lists once the row is actually extracted into a document (SessionCache in
// the meantime), per the project's "don't pollute a fixed vocabulary with unreviewed values"
// rule that also applies to Bulk Import and the rest of this session's schema changes.

import { sb, State, esc, today, canWrite, withStatus, withStatusCount, labelOf, extractHayatRowToDocument, SessionCache } from './core.js?v=20260828210000';
import { comboboxHtml, wireCombobox } from './combobox.js?v=20260828210000';

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
        <button class="btn secondary" id="he-paste-import">Paste CSV</button>
        <button class="btn secondary" id="he-prompt">Gemini Prompt</button>` : ''}
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
    document.getElementById('he-import').addEventListener('click', () => showCsvImportModal('file'));
    document.getElementById('he-paste-import').addEventListener('click', () => showCsvImportModal('paste'));
    document.getElementById('he-prompt').addEventListener('click', showPromptModal);
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
  sel.value = State.hayatEditorEdition; // some browsers don't re-sync the displayed value from `selected` alone after an innerHTML rebuild
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
    <td><input data-f="ur_title" value="${esc(r.ur_title)}" placeholder="Ur-Title" style="min-width:160px;" dir="auto"></td>
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
      <th></th><th>ID</th><th>Pagina</th><th>Autore</th><th>Titolo (Urdu)</th><th>Title (EN)</th><th>Ur-Title</th>
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

// Export produces the same 11-column layout used by the external extraction tool (PDF ->
// CSV) that this format was designed to round-trip with: mese_anno and the Italian
// "categoria" label are derived rather than stored verbatim (categoria from the category
// code via labelOf; mese_anno is the same for every row in a single-edition export).
const EXPORT_HEADERS = ['mese_anno', 'pagina', 'categoria', 'category', 'branca', 'autore', 'titolo', 'argomento', 'data_pdv', 'title', 'Ur-Title'];

function exportCsv() {
  if (!currentRows.length) { alert('Nothing to export for this edition.'); return; }
  const header = EXPORT_HEADERS.join(',');
  const body = currentRows.map(r => EXPORT_HEADERS.map(h => {
    if (h === 'mese_anno') return csvEscape(State.hayatEditorEdition);
    if (h === 'categoria') return csvEscape(labelOf(State.categories, r.category));
    if (h === 'Ur-Title') return csvEscape(r.ur_title);
    return csvEscape(r[h]);
  }).join(',')).join('\n');
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

// Import accepts the same 11-column layout: mese_anno and categoria are read from the file
// only to be ignored (the edition comes from the modal's own field - the user types it once
// there rather than trusting the file - and categoria is redundant with the category code);
// "Ur-Title" is the one header that doesn't match its DB column name (ur_title) verbatim.
const IMPORT_HEADER_ALIASES = { 'Ur-Title': 'ur_title' };
const IMPORT_COLUMNS = ['pagina', 'autore', 'titolo', 'title', 'ur_title', 'category', 'branca', 'argomento', 'data_pdv'];

function showCsvImportModal(mode) {
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel" style="max-width:600px;">
      <h2>${mode === 'paste' ? 'Paste CSV' : 'Import CSV'}</h2>
      <div class="field"><label>Edition (Month-Year)</label><input id="csv-import-edition" placeholder="YYYY-MM" value="${esc(State.hayatEditorEdition || '')}"></div>
      ${mode === 'paste'
        ? '<div class="field"><label>Paste CSV text</label><textarea id="csv-import-text" rows="14" style="font-family:monospace;font-size:12px;"></textarea></div>'
        : '<div class="field"><label>CSV file</label><input id="csv-import-file" type="file" accept=".csv"></div>'}
      <div id="csv-import-result" class="hint" style="min-height:1.4em;white-space:pre-wrap;"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="csv-import-cancel">Cancel</button>
        <button class="btn" id="csv-import-go">Import</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  const resultBox = document.getElementById('csv-import-result');
  const showResult = (kind, message) => {
    resultBox.textContent = message;
    resultBox.style.color = kind === 'error' ? 'var(--danger)' : 'var(--accent)';
  };
  document.getElementById('csv-import-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('csv-import-go').addEventListener('click', async () => {
    const goBtn = document.getElementById('csv-import-go');
    const edition = document.getElementById('csv-import-edition').value.trim();
    if (!/^\d{4}-\d{2}$/.test(edition)) { showResult('error', 'Please enter the edition as YYYY-MM (e.g. 2022-05).'); return; }
    let text;
    if (mode === 'paste') {
      text = document.getElementById('csv-import-text').value;
      if (!text.trim()) { showResult('error', 'Please paste CSV text first.'); return; }
    } else {
      const file = document.getElementById('csv-import-file').files[0];
      if (!file) { showResult('error', 'Please choose a CSV file first.'); return; }
      text = await file.text();
    }

    const validation = validateCsv(text);
    if (!validation.ok) { showResult('error', validation.message); return; }

    goBtn.disabled = true;
    showResult(null, 'Importing…');
    try {
      const added = await runCsvImport(validation.rows, edition);
      showResult('success', `✓ Imported ${added} row(s) into edition ${edition}.`);
      await populateEditionSelect();
      await refreshHayatEditorGrid();
    } catch (err) {
      showResult('error', `Import failed: ${err.message}`);
    } finally {
      goBtn.disabled = false;
    }
  });
}

// Consistency check before writing anything: every data row must parse into the same number
// of fields as the header (the classic sign of a broken CSV - an unescaped comma or quote),
// and the header must contain at least one column this importer actually recognizes -
// otherwise every row would silently import as all-blank. Returns parsed+aliased row objects
// so runCsvImport never has to re-parse (and can't disagree with what was validated).
function validateCsv(text) {
  const lines = text.split(/\r?\n/).filter(l => l.trim() !== '');
  if (lines.length < 2) return { ok: false, message: 'The CSV has no data rows (only a header, or it is empty).' };
  const rawHeader = parseCsvLine(lines[0]);
  const header = rawHeader.map(h => { const t = h.trim(); return IMPORT_HEADER_ALIASES[t] || t; });
  if (!header.some(h => IMPORT_COLUMNS.includes(h))) {
    return { ok: false, message: `None of the header columns are recognized.\nExpected at least one of: ${IMPORT_COLUMNS.join(', ')}\nFound: ${rawHeader.join(', ') || '(empty header)'}` };
  }
  const badLines = [];
  const rows = [];
  for (let i = 1; i < lines.length; i++) {
    const cells = parseCsvLine(lines[i]);
    if (cells.length !== header.length) {
      badLines.push(`Line ${i + 1}: expected ${header.length} fields, found ${cells.length}`);
      continue;
    }
    const obj = {};
    header.forEach((h, idx) => {
      if (!IMPORT_COLUMNS.includes(h)) return;
      const v = cells[idx];
      obj[h] = (!v || v.trim().toUpperCase() === 'NULL') ? null : v;
    });
    rows.push(obj);
  }
  if (badLines.length) {
    const shown = badLines.slice(0, 8).join('\n');
    const more = badLines.length > 8 ? `\n...and ${badLines.length - 8} more` : '';
    return { ok: false, message: `Found ${badLines.length} malformed row(s) - fix them and try again (probably an unescaped comma or quote):\n${shown}${more}` };
  }
  return { ok: true, rows };
}

// Inserts the already-validated rows, then re-counts the edition in the database to confirm
// they actually persisted - not just that no error was thrown. This is the "did the import
// really happen" check: it would have caught the earlier confirm()-related bug (rows silently
// never inserted) even if some future issue causes inserts to succeed without a query error.
async function runCsvImport(rows, edition) {
  const { count: beforeCount } = await withStatusCount(sb.from('hayat_indice').select('id', { count: 'exact', head: true }).eq('mese_anno', edition));
  let maxRows = await withStatus(sb.from('hayat_indice').select('id').order('id', { ascending: false }).limit(1));
  let nextId = (maxRows[0]?.id || 0) + 1;
  for (const r of rows) {
    await withStatus(sb.from('hayat_indice').insert({ ...r, id: nextId, mese_anno: edition }), 'Importing...');
    nextId++;
  }
  const { count: afterCount } = await withStatusCount(sb.from('hayat_indice').select('id', { count: 'exact', head: true }).eq('mese_anno', edition));
  const actuallyAdded = (afterCount || 0) - (beforeCount || 0);
  if (actuallyAdded !== rows.length) {
    throw new Error(`expected to add ${rows.length} row(s), but ${actuallyAdded} are now present for edition ${edition}. Check your permissions and try again.`);
  }
  State.hayatEditorEdition = edition;
  return actuallyAdded;
}

// ---------- Gemini Prompt (shared, editable text for the PDF -> CSV extraction workflow) ----------
// Stored in the generic app_settings key/value table rather than anywhere Hayat-specific,
// so the same table can hold any future single shared setting without a new migration.

const PROMPT_SETTING_KEY = 'hayat_csv_gemini_prompt';

async function showPromptModal() {
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel" style="max-width:700px;">
      <h2>Gemini Prompt <span class="hint">— shared with the team, used to extract a Hayat edition's CSV from its PDF</span></h2>
      <div class="field"><textarea id="prompt-text" rows="16" readonly style="font-family:monospace;font-size:12.5px;">Loading…</textarea></div>
      <div id="prompt-result" class="hint" style="min-height:1.4em;"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="prompt-copy">Copy to clipboard</button>
        <button class="btn secondary" id="prompt-edit">Edit</button>
        <button class="btn secondary" id="prompt-save" style="display:none;">Save</button>
        <button class="btn" id="prompt-close">Close</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  const textarea = document.getElementById('prompt-text');
  const resultBox = document.getElementById('prompt-result');
  const editBtn = document.getElementById('prompt-edit');
  const saveBtn = document.getElementById('prompt-save');

  function setEditing(on) {
    textarea.readOnly = !on;
    editBtn.style.display = on ? 'none' : '';
    saveBtn.style.display = on ? '' : 'none';
  }

  document.getElementById('prompt-close').addEventListener('click', () => backdrop.remove());
  editBtn.addEventListener('click', () => { setEditing(true); resultBox.textContent = ''; });

  document.getElementById('prompt-copy').addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(textarea.value);
    } catch {
      textarea.select();
      document.execCommand('copy');
    }
    resultBox.style.color = 'var(--accent)';
    resultBox.textContent = 'Copied to clipboard.';
  });

  // Read-only by default so nobody edits it by accident; "Edit" explicitly unlocks the
  // textarea and swaps in "Save". Both the initial load and the save itself are fully
  // wrapped in try/catch (a previous version called sb.auth.getUser() *outside* the save's
  // try/catch - if that ever failed, the save silently did nothing with no error shown,
  // which matches a real report of "Save looked like it worked but nothing persisted").
  try {
    const rows = await withStatus(sb.from('app_settings').select('value').eq('key', PROMPT_SETTING_KEY));
    textarea.value = (rows && rows[0] && rows[0].value) || '';
  } catch (err) {
    textarea.value = '';
    resultBox.style.color = 'var(--danger)';
    resultBox.textContent = `Could not load the saved prompt: ${err.message}`;
  }

  saveBtn.addEventListener('click', async () => {
    saveBtn.disabled = true;
    try {
      const value = textarea.value;
      const { data: { user } } = await sb.auth.getUser();
      if (!user) throw new Error('no active session - please sign in again');
      await withStatus(sb.from('app_settings').upsert({ key: PROMPT_SETTING_KEY, value, updated_at: new Date().toISOString(), updated_by_email: user.email }), 'Saving...');
      resultBox.style.color = 'var(--accent)';
      resultBox.textContent = '✓ Saved for everyone.';
      setEditing(false);
    } catch (err) {
      resultBox.style.color = 'var(--danger)';
      resultBox.textContent = `Save failed: ${err.message}`;
    } finally {
      saveBtn.disabled = false;
    }
  });
}
