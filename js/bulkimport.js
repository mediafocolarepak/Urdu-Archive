// Bulk Import: catalogue every supported file in a folder in one pass. No per-file review
// step any more - the only checkpoint is a single "Import N files?" confirmation before
// anything is written, since renaming files on disk is not easily undone. Possible duplicates
// (by title similarity against what's already catalogued) are still detected, but only
// reported afterwards in the summary, not used to block or pre-exclude anything.

import { sb, State, esc, today, optionsHtml, withStatus, computeFileName, createWorkFor, titleOverlapScore } from './core.js?v=20260902141721';

export function titleFromFilename(name) {
  const noExt = name.replace(/\.[a-z0-9]+$/i, '');
  const cleaned = noExt.replace(/[_\-]+/g, ' ').replace(/\s+/g, ' ').trim();
  return cleaned.charAt(0).toUpperCase() + cleaned.slice(1);
}

// Best-effort, checked most-specific pattern first: a full day.month.year becomes an exact
// ref_date; a year-month (no day) or a bare year becomes ref_period instead, since that's
// honestly all we know from the filename.
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
  m = name.match(/(19|20)\d{2}-(0[1-9]|1[0-2])(?!\d)/);
  if (m) return { ref_date: null, ref_period: m[0] };
  m = name.match(/(19|20)\d{2}/);
  if (m) return { ref_date: null, ref_period: m[0] };
  return { ref_date: null, ref_period: null };
}

let batchSource = '';
let batchOperator = '';
let batchMediaType = 'DOC';
let batchCollection = '';
let batchLang = '';

export async function renderBulkImportView(main) {
  const supported = 'showDirectoryPicker' in window;
  main.innerHTML = `
    <div class="panel">
      <h2>Bulk Import</h2>
      <p class="hint">Pick a local folder of files to catalogue in one go. Each file gets a new catalogue number and its own Document. Category/author/topic are left for you to fill in afterwards from the Dashboard. There is one confirmation before anything is written or renamed - after that, every file in the folder is imported.</p>
      ${supported ? '' : '<div class="empty-msg">This feature needs Chrome or Edge (it uses a browser API to read and rename local files that Firefox/Safari do not support).</div>'}
      ${supported ? `
      <div class="field-grid" style="max-width:600px;">
        <div class="field"><label>Source (applies to this whole batch)</label><select id="bi-source">${optionsHtml(State.sources, batchSource, true)}</select></div>
        <div class="field"><label>Operator (applies to this whole batch)</label><select id="bi-operator">${optionsHtml(State.operators, batchOperator, true)}</select></div>
        <div class="field"><label>Language (applies to this whole batch)</label><select id="bi-lang">${optionsHtml(State.langs, batchLang, true)}</select></div>
        <div class="field"><label>Media type (applies to this whole batch)</label><select id="bi-media-type">${optionsHtml(State.mediaTypes, batchMediaType, false)}</select></div>
        <div class="field"><label>Collection (optional)</label><select id="bi-collection">${optionsHtml(State.collections, batchCollection, true)}</select></div>
      </div>
      <div class="btn-row"><button class="btn" id="bi-pick-folder">Select folder…</button></div>` : ''}
      <div id="bi-body"></div>
    </div>`;
  if (!supported) return;
  document.getElementById('bi-pick-folder').addEventListener('click', () => {
    batchSource = document.getElementById('bi-source').value;
    batchOperator = document.getElementById('bi-operator').value;
    batchLang = document.getElementById('bi-lang').value;
    batchMediaType = document.getElementById('bi-media-type').value;
    batchCollection = document.getElementById('bi-collection').value;
    scanAndImport();
  });
}

function baseNameOf(name) {
  const dot = name.lastIndexOf('.');
  return dot > 0 ? name.slice(0, dot) : name;
}

async function scanAndImport() {
  const body = document.getElementById('bi-body');
  let dirHandle;
  try {
    dirHandle = await window.showDirectoryPicker({ mode: 'readwrite' });
  } catch (e) {
    return; // user cancelled the picker
  }
  body.innerHTML = '<div class="empty-msg">Scanning folder…</div>';

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

  const plan = files.map(entry => {
    const title = titleFromFilename(entry.name);
    const { ref_date, ref_period } = extractDateFromFilename(entry.name);
    let bestMatch = null, bestScore = 0;
    for (const doc of existing) {
      const score = Math.max(titleOverlapScore(title, doc.title), titleOverlapScore(entry.name, doc.file_name), titleOverlapScore(entry.name, doc.legacy_file_name));
      if (score > bestScore) { bestScore = score; bestMatch = doc; }
    }
    const document_id = nextId++;
    const ext = entry.name.slice(entry.name.lastIndexOf('.'));
    const base = baseNameOf(entry.name);
    const newFileName = computeFileName({ document_id, title }).replace(/\.pdf$/, ext);
    return {
      entry, originalName: entry.name, document_id, title, ref_date, ref_period, newFileName,
      original_inp_file_name: `${base}.inp`, original_doc_file_name: `${base}.docx`,
      isDuplicateSuspect: bestScore >= 0.5, duplicateOf: bestMatch,
    };
  });

  if (!confirm(`Import ${plan.length} file(s) and rename them on disk? This cannot be easily undone.`)) {
    body.innerHTML = '';
    return;
  }

  body.innerHTML = '<div class="empty-msg">Importing…</div>';
  let imported = 0, failed = 0;
  const errors = [];
  for (const r of plan) {
    try {
      const workId = await createWorkFor(r.title);
      await withStatus(sb.from('documents').insert({
        document_id: r.document_id, title: r.title, workflow_status: 'ENTR',
        catalog_date: today(), ref_date: r.ref_date, ref_period: r.ref_period,
        file_name: r.newFileName, legacy_migrated: false, work_id: workId,
        source: batchSource || null, operator: batchOperator || null, language: batchLang || null,
        media_type: batchMediaType, collection: batchCollection || null,
        original_inp_file_name: r.original_inp_file_name, original_doc_file_name: r.original_doc_file_name,
      }));
      const file = await r.entry.getFile();
      const newHandle = await dirHandle.getFileHandle(r.newFileName, { create: true });
      const writable = await newHandle.createWritable();
      await writable.write(await file.arrayBuffer());
      await writable.close();
      await dirHandle.removeEntry(r.originalName);
      imported++;
    } catch (e) {
      failed++;
      errors.push({ name: r.originalName, message: e.message });
    }
  }

  const duplicates = plan.filter(r => r.isDuplicateSuspect);
  body.innerHTML = `
    <div class="panel">
      <b>Done.</b> Catalogued ${imported} document(s), each with its own new Document.${failed ? ` ${failed} failed.` : ''}
      ${duplicates.length ? `<div class="hint" style="margin-top:8px;">${duplicates.length} file(s) looked similar to something already catalogued - worth a check:</div>
        <ul>${duplicates.map(d => `<li>${esc(d.originalName)} - similar to #${esc(d.duplicateOf.document_id)} "${esc(d.duplicateOf.title)}"</li>`).join('')}</ul>` : ''}
      ${errors.length ? `<div class="hint" style="margin-top:8px;">Failed:</div><ul>${errors.map(e => `<li>${esc(e.name)}: ${esc(e.message)}</li>`).join('')}</ul>` : ''}
    </div>`;
}
