import { sb, State, esc, today, optionsHtml, withStatus, computeFileName, createWorkFor } from './core.js?v=20260817134636';

export function slugifyTitle(s) {
  return (s || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 40) || 'untitled';
}

export function titleFromFilename(name) {
  const noExt = name.replace(/\.[a-z0-9]+$/i, '');
  const cleaned = noExt.replace(/[_\-]+/g, ' ').replace(/\s+/g, ' ').trim();
  return cleaned.charAt(0).toUpperCase() + cleaned.slice(1);
}

// Best-effort: a full day.month.year pattern becomes an exact ref_date; a bare 4-digit
// year becomes ref_period instead, since that's honestly all we know from the filename.
export function extractDateFromFilename(name) {
  let m = name.match(/(\d{1,2})[.\-\/](\d{1,2})[.\-\/](\d{4})(?!\d)/);
  if (m) {
    const [, d, mo, y] = m.map(Number);
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      const dt = new Date(y, mo - 1, d);
      if (!isNaN(dt)) return { ref_date: `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`, ref_period: null };
    }
  }
  m = name.match(/(\d{1,2})[.\-\/](\d{1,2})[.\-\/](\d{2})(?!\d)/);
  if (m) {
    const [, d, mo, y2] = m.map(Number);
    const y = y2 < 50 ? 2000 + y2 : 1900 + y2;
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      const dt = new Date(y, mo - 1, d);
      if (!isNaN(dt)) return { ref_date: `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`, ref_period: null };
    }
  }
  m = name.match(/(19|20)\d{2}/);
  if (m) return { ref_date: null, ref_period: m[0] };
  return { ref_date: null, ref_period: null };
}

export function normalizeForCompare(s) {
  return (s || '').toLowerCase().replace(/\.[a-z0-9]+$/, '').replace(/[^a-z0-9]+/g, ' ').trim();
}
export function titleOverlapScore(a, b) {
  const wa = new Set(normalizeForCompare(a).split(' ').filter(w => w.length > 2));
  const wb = new Set(normalizeForCompare(b).split(' ').filter(w => w.length > 2));
  if (wa.size === 0 || wb.size === 0) return 0;
  let inter = 0;
  for (const w of wa) if (wb.has(w)) inter++;
  return inter / Math.min(wa.size, wb.size);
}

let batchProvenance = '';
let batchOperator = '';
let batchMediaType = 'DOC';
let batchCollection = '';
let batchLang = '';

export async function renderBulkImportView(main) {
  const supported = 'showDirectoryPicker' in window;
  main.innerHTML = `
    <div class="panel">
      <h2>Bulk Import</h2>
      <p class="hint">Pick a local folder of files to catalogue in one go. Each file gets a new catalogue number, its own Document, and a record with status "Entry" - category/author/topic are left for you to fill in afterwards from the Dashboard, which will also complete the file name automatically at that point. Duplicates are expected (different sources/versions of the same content) - possible duplicates are only flagged for your awareness, not blocked.</p>
      ${supported ? '' : '<div class="empty-msg">This feature needs Chrome or Edge (it uses a browser API to read and rename local files that Firefox/Safari do not support).</div>'}
      ${supported ? `
      <div class="field-grid" style="max-width:600px;">
        <div class="field"><label>Source (applies to this whole batch)</label><select id="bi-provenance">${optionsHtml(State.provenances, batchProvenance, true)}</select></div>
        <div class="field"><label>Operator (applies to this whole batch)</label><select id="bi-operator">${optionsHtml(State.operators, batchOperator, true)}</select></div>
        <div class="field"><label>Language (applies to this whole batch)</label><select id="bi-lang">${optionsHtml(State.langs, batchLang, true)}</select></div>
        <div class="field"><label>Media type (applies to this whole batch)</label><select id="bi-media-type">${optionsHtml(State.mediaTypes, batchMediaType, false)}</select></div>
        <div class="field"><label>Collection (optional)</label><select id="bi-collection">${optionsHtml(State.collections, batchCollection, true)}</select></div>
      </div>
      <div class="btn-row"><button class="btn" id="bi-pick-folder">Select folderâ€¦</button></div>` : ''}
      <div id="bi-body"></div>
    </div>`;
  if (!supported) return;
  document.getElementById('bi-pick-folder').addEventListener('click', () => {
    batchProvenance = document.getElementById('bi-provenance').value;
    batchOperator = document.getElementById('bi-operator').value;
    batchLang = document.getElementById('bi-lang').value;
    batchMediaType = document.getElementById('bi-media-type').value;
    batchCollection = document.getElementById('bi-collection').value;
    scanBulkImportFolder();
  });
}

async function scanBulkImportFolder() {
  const body = document.getElementById('bi-body');
  let dirHandle;
  try {
    dirHandle = await window.showDirectoryPicker({ mode: 'readwrite' });
  } catch (e) {
    return; // user cancelled the picker
  }
  State.bulkImportDirHandle = dirHandle;
  body.innerHTML = '<div class="empty-msg">Scanning folderâ€¦</div>';

  const extensions = batchMediaType === 'VID' ? ['.mp4', '.mov', '.avi', '.mkv'] : ['.pdf'];
  const files = [];
  for await (const entry of dirHandle.values()) {
    if (entry.kind === 'file' && extensions.some(ext => entry.name.toLowerCase().endsWith(ext))) files.push(entry);
  }
  if (files.length === 0) {
    body.innerHTML = `<div class="empty-msg">No ${batchMediaType === 'VID' ? 'video' : 'PDF'} files found in that folder.</div>`;
    return;
  }

  const existing = await withStatus(sb.from('documents').select('document_id,title,file_name,legacy_file_name').order('document_id'), 'Checking for similar items already catalogued...');
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  let nextId = (maxRows[0]?.document_id || 0) + 1;

  State.bulkImportRows = files.map(entry => {
    const title = titleFromFilename(entry.name);
    const { ref_date, ref_period } = extractDateFromFilename(entry.name);
    let bestMatch = null, bestScore = 0;
    for (const doc of existing) {
      const score = Math.max(titleOverlapScore(title, doc.title), titleOverlapScore(entry.name, doc.file_name), titleOverlapScore(entry.name, doc.legacy_file_name));
      if (score > bestScore) { bestScore = score; bestMatch = doc; }
    }
    const isDuplicateSuspect = bestScore >= 0.5;
    const document_id = nextId++;
    const ext = entry.name.slice(entry.name.lastIndexOf('.'));
    const newFileName = computeFileName({ document_id, title, provenance: batchProvenance, original_lang: batchLang, ref_date, ref_period }).replace(/\.pdf$/, ext);
    return {
      entry, originalName: entry.name, document_id, title, ref_date, ref_period, newFileName,
      isDuplicateSuspect, duplicateOf: bestMatch, included: true,
    };
  });

  renderBulkImportTable();
}

function renderBulkImportTable() {
  const body = document.getElementById('bi-body');
  body.innerHTML = `
    <div class="hint" style="margin:10px 0;">${State.bulkImportRows.length} file(s) found, source "${esc(batchProvenance || 'â€”')}". Possible duplicates are flagged below for awareness only â€” keep them checked unless you're sure it's a true duplicate, since different versions/translations are expected and welcome.</div>
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th></th><th>Catalogue #</th><th>Original name</th><th>Title (from filename)</th><th>Date/period detected</th><th>New file name</th><th>Similar to</th></tr></thead>
      <tbody>${State.bulkImportRows.map((r, i) => `<tr>
        <td><input type="checkbox" class="bi-include" data-i="${i}" ${r.included ? 'checked' : ''}></td>
        <td>${String(r.document_id).padStart(5, '0')}</td>
        <td>${esc(r.originalName)}</td>
        <td>${esc(r.title)}</td>
        <td>${esc(r.ref_date || r.ref_period || 'â€”')}</td>
        <td>${esc(r.newFileName)}</td>
        <td>${r.isDuplicateSuspect ? `<span class="count-badge">#${esc(r.duplicateOf.document_id)} "${esc(r.duplicateOf.title)}"</span>` : ''}</td>
      </tr>`).join('')}</tbody>
    </table></div>
    <div class="btn-row">
      <button class="btn" id="bi-apply">OK â€” catalogue the checked files</button>
    </div>
    <div id="bi-progress"></div>
  `;
  body.querySelectorAll('.bi-include').forEach(cb => cb.addEventListener('change', () => {
    State.bulkImportRows[cb.dataset.i].included = cb.checked;
  }));
  document.getElementById('bi-apply').addEventListener('click', applyBulkImport);
}

async function applyBulkImport() {
  const toImport = State.bulkImportRows.filter(r => r.included);
  if (toImport.length === 0) { alert('Nothing checked to import.'); return; }
  if (!confirm(`Catalogue ${toImport.length} file(s) and rename them on disk? This cannot be easily undone.`)) return;

  const progress = document.getElementById('bi-progress');
  let done = 0, failed = 0;
  for (const r of toImport) {
    progress.innerHTML = `<div class="hint">Processing ${done + failed + 1} of ${toImport.length}: ${esc(r.originalName)}â€¦</div>`;
    try {
      const workId = await createWorkFor(r.title);
      await withStatus(sb.from('documents').insert({
        document_id: r.document_id, title: r.title, workflow_status: 'ENTR',
        catalog_date: today(), ref_date: r.ref_date, ref_period: r.ref_period,
        file_name: r.newFileName, legacy_migrated: false, work_id: workId,
        provenance: batchProvenance || null, operator: batchOperator || null, original_lang: batchLang || null,
        media_type: batchMediaType, collection: batchCollection || null,
      }));
      const file = await r.entry.getFile();
      const newHandle = await State.bulkImportDirHandle.getFileHandle(r.newFileName, { create: true });
      const writable = await newHandle.createWritable();
      await writable.write(await file.arrayBuffer());
      await writable.close();
      await State.bulkImportDirHandle.removeEntry(r.originalName);
      done++;
    } catch (e) {
      failed++;
      r.error = e.message;
    }
  }
  progress.innerHTML = `<div class="panel"><b>Done.</b> Catalogued ${done} document(s).${failed ? ` ${failed} failed - see below.` : ''}</div>
    ${failed ? `<ul>${toImport.filter(r => r.error).map(r => `<li>${esc(r.originalName)}: ${esc(r.error)}</li>`).join('')}</ul>` : ''}`;
  State.bulkImportRows = State.bulkImportRows.filter(r => !r.included || r.error);
  if (State.bulkImportRows.length) renderBulkImportTable();
}
