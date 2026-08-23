// The document detail panel - shared between Dashboard and Match Review (both give it a
// <div id="doc-detail"> to render into). Only this module and core.js know about the
// `documents` table's full field set.

import {
  sb, State, esc, today, labelOf, optionsHtml, canWrite, canDelete,
  computeFileName, uniqueFileName, withStatus, BUCKET, downloadFromGDrive,
  createWorkFor, TRACKING_STEPS, getCollectionsForDocument, saveDocumentCollections, setPreferredVersion,
} from './core.js?v=20260823234040';

export function renderDocDetailConsultation(box, doc, workSiblings, docCollections) {
  const row = (label, value) => `<div class="field"><label>${esc(label)}</label><input value="${esc(value)}" disabled></div>`;
  box.innerHTML = `
    <h3>Document #${esc(doc.document_id)}</h3>
    ${renderAllVersionsBar(doc, workSiblings)}
    <div class="field-grid wide">
      ${row('Title (EN)', doc.title)}
      ${row('Original title', doc.original_title)}
      ${row('Place', doc.place)}
      ${row('Category', labelOf(State.categories, doc.category))}
      ${row('Author', labelOf(State.authors, doc.author))}
      ${row('Main topic', labelOf(State.mainTopics, doc.main_topic))}
      ${row('Secondary tags', doc.secondary_tags)}
      ${row('Language', labelOf(State.langs, doc.language))}
      ${row('Reference date', doc.ref_date)}
      ${row('File name', doc.file_name)}
      ${row('Media type', labelOf(State.mediaTypes, doc.media_type))}
      ${row('Source', labelOf(State.sources, doc.source))}
      ${row('Operator', labelOf(State.operators, doc.operator))}
      ${doc.media_type === 'VID' ? row('Duration', doc.duration) : ''}
      ${doc.media_type === 'VID' ? row('Quality', labelOf(State.qualities, doc.quality)) : ''}
      ${row('Current step', labelOf(State.statuses, doc.workflow_status))}
    </div>
    <div class="field">
      <label>Recipient(s)</label>
      <div style="font-size:13px;padding:4px 0;">${(doc.recipient || []).map(c => esc(labelOf(State.recipients, c))).join(', ') || '—'}</div>
    </div>
    <div class="field">
      <label>Collections</label>
      <div style="font-size:13px;padding:4px 0;">${renderCollectionsSummary(docCollections)}</div>
    </div>
    ${renderWorkSiblingsHtml(workSiblings, doc.document_id, false)}
    <div class="btn-row">
      <button class="btn" id="doc-download-gdrive">Download Document</button>
    </div>
    ${doc.storage_path ? `<div class="field"><label>File</label><a href="#" id="doc-download">Download</a></div>` : ''}
  `;
  document.getElementById('doc-download-gdrive').addEventListener('click', () => downloadFromGDrive(doc.file_name));
  if (doc.storage_path) {
    document.getElementById('doc-download').addEventListener('click', async e => {
      e.preventDefault();
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
  }
  wireWorkSiblingsClicks(box);
  wireAllVersionsBar(box, doc, workSiblings);
}

function renderCollectionsSummary(docCollections) {
  if (!docCollections || !docCollections.length) return '—';
  return docCollections.map(dc => esc(labelOf(State.collections, dc.collection_code)) + (dc.page_number ? ` (p.${esc(dc.page_number)})` : '')).join(', ');
}

// A "Document" groups together several "Versions" (translations, other-language
// re-tellings, or a video/audio counterpart) that share a work_id. Text versions get their
// own full detail page (consult + download); for video/audio, the file name shown here is
// enough to locate the file, so no extra download plumbing is built for them. Only one
// version per Document may be "preferred" - the star is set from here or from Work
// Consolidation, never automatically.
function renderWorkSiblingsHtml(siblings, currentId, canEdit) {
  if (!siblings || siblings.length === 0) return '';
  const others = siblings.filter(s => String(s.document_id) !== String(currentId));
  if (!others.length) return '';
  return `
    <div class="field">
      <label>Other versions of this document</label>
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>ID</th><th>Title</th><th>Language</th><th>Source</th><th>Type</th><th>File</th><th>Preferred</th><th></th></tr></thead>
        <tbody>${others.map(s => `<tr data-sibling-id="${esc(s.document_id)}">
          <td>${esc(s.document_id)}</td><td>${esc(s.title)}</td><td>${esc(labelOf(State.langs, s.language))}</td>
          <td>${esc(labelOf(State.sources, s.source))}</td><td>${esc(labelOf(State.mediaTypes, s.media_type))}</td>
          <td>${esc(s.file_name)}</td>
          <td>${s.is_preferred ? '<span class="count-badge">&#9733; Preferred</span>'
              : (canEdit ? `<button class="btn secondary sibling-set-preferred" style="padding:2px 8px;">Set preferred</button>` : '')}</td>
          <td><button class="btn secondary sibling-open" style="padding:2px 8px;">Open</button></td>
        </tr>`).join('')}</tbody>
      </table></div>
    </div>`;
}

function wireWorkSiblingsClicks(box, workId) {
  box.querySelectorAll('tr[data-sibling-id]').forEach(tr => {
    tr.addEventListener('click', async () => {
      const targetId = tr.dataset.siblingId;
      State.selectedDocId = targetId;
      await onAfterDocChange();
      await renderDocDetail(targetId);
    });
    const openBtn = tr.querySelector('.sibling-open');
    if (openBtn) openBtn.addEventListener('click', async e => {
      e.stopPropagation();
      const rows = await withStatus(sb.from('documents').select('file_name').eq('document_id', tr.dataset.siblingId));
      downloadFromGDrive(rows[0]?.file_name);
    });
    const prefBtn = tr.querySelector('.sibling-set-preferred');
    if (prefBtn) prefBtn.addEventListener('click', async e => {
      e.stopPropagation();
      await setPreferredVersion(tr.dataset.siblingId, workId);
      await onAfterDocChange();
      await renderDocDetail(State.selectedDocId);
    });
  });
}

async function fetchWorkSiblings(workId) {
  if (!workId) return [];
  return await withStatus(sb.from('documents').select('document_id,title,language,source,media_type,file_name,is_preferred,storage_path').eq('work_id', workId));
}

// Downloads a specific version, preferring the app-managed Storage copy (signed URL) over the
// Google Drive lookup-by-name fallback - same precedence the single-document download already uses.
async function downloadVersion(v) {
  if (v.storage_path) {
    const { data } = await sb.storage.from(BUCKET).createSignedUrl(v.storage_path, 60);
    if (data?.signedUrl) { window.open(data.signedUrl, '_blank'); return; }
  }
  downloadFromGDrive(v.file_name);
}

// A prominent, always-at-the-top row of one download button per version of this Document
// (the one currently open, plus every linked sibling) - added so a plain User doesn't have to
// scroll down to the "Other versions" table just to grab a translation or duplicate.
function renderAllVersionsBar(doc, siblings) {
  const all = [doc, ...(siblings || []).filter(s => String(s.document_id) !== String(doc.document_id))];
  if (all.length <= 1) return '';
  return `
    <div class="btn-row all-versions-bar" style="margin-top:0;">
      ${all.map(v => {
        const isCurrent = String(v.document_id) === String(doc.document_id);
        const lang = labelOf(State.langs, v.language) || '?';
        const src = labelOf(State.sources, v.source);
        const kind = v.media_type === 'VID' ? ' video' : '';
        return `<button class="btn${isCurrent ? '' : ' secondary'} version-download" data-id="${esc(v.document_id)}">
          Download ${esc(lang)}${kind}${src ? ' — ' + esc(src) : ''}${isCurrent ? ' (this one)' : ''}
        </button>`;
      }).join('')}
    </div>`;
}

function wireAllVersionsBar(box, doc, siblings) {
  const all = [doc, ...(siblings || []).filter(s => String(s.document_id) !== String(doc.document_id))];
  box.querySelectorAll('.version-download').forEach(btn => {
    btn.addEventListener('click', () => {
      const v = all.find(x => String(x.document_id) === btn.dataset.id);
      if (v) downloadVersion(v);
    });
  });
}

export async function renderDocDetail(id) {
  const box = document.getElementById('doc-detail');
  if (!box) return;
  if (!id) { box.innerHTML = '<div class="empty-msg">Select a document from the list, or create a new one.</div>'; return; }
  const rows = await withStatus(sb.from('documents').select('*').eq('document_id', id));
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Document not found.</div>'; return; }
  const doc = rows[0];
  const siblings = await fetchWorkSiblings(doc.work_id);
  const docCollections = await getCollectionsForDocument(doc.document_id);

  if (State.currentRole === 'user') { renderDocDetailConsultation(box, doc, siblings, docCollections); return; }

  const readOnly = !canWrite();

  function textField(label, name, value, type) {
    if (readOnly) return `<div class="field"><label>${esc(label)}</label><input value="${esc(value)}" disabled></div>`;
    return `<div class="field"><label>${esc(label)}</label><input data-f="${name}" type="${type || 'text'}" value="${esc(value)}"></div>`;
  }
  function selectField(label, name, value, list, allowEmpty) {
    if (readOnly) return `<div class="field"><label>${esc(label)}</label><input value="${esc(labelOf(list, value))}" disabled></div>`;
    return `<div class="field"><label>${esc(label)}</label><select data-f="${name}">${optionsHtml(list, value, !!allowEmpty)}</select></div>`;
  }

  const previewName = computeFileName({ ...doc });
  const isVideo = doc.media_type === 'VID';

  box.innerHTML = `
    <h3>Document #${esc(doc.document_id)}${doc.pending_deletion ? ' <span class="count-badge" style="background:var(--danger);color:#fff;">pending deletion</span>' : ''}</h3>
    ${renderAllVersionsBar(doc, siblings)}
    <div class="field-grid wide">
      ${textField('Title (EN)', 'title', doc.title)}
      ${textField('Original title', 'original_title', doc.original_title)}
      ${textField('Place', 'place', doc.place)}
      ${textField('Reference date', 'ref_date', doc.ref_date, 'date')}
      ${selectField('Category', 'category', doc.category, State.categories)}
      ${selectField('Author', 'author', doc.author, State.authors)}
      ${textField('Author (free text)', 'original_author', doc.original_author)}
      ${selectField('Main topic', 'main_topic', doc.main_topic, State.mainTopics)}
      ${textField('Secondary tags', 'secondary_tags', doc.secondary_tags)}
      ${selectField('Language', 'language', doc.language, State.langs)}
      ${textField('Reference period', 'ref_period', doc.ref_period)}
      ${selectField('Media type', 'media_type', doc.media_type, State.mediaTypes)}
      ${selectField('Source', 'source', doc.source, State.sources)}
      ${selectField('Operator', 'operator', doc.operator, State.operators)}
      ${textField('Physical box', 'physical_box', doc.physical_box)}
      ${textField('Episode number', 'episode_number', doc.episode_number)}
      ${textField('Bible verse', 'bible_verse', doc.bible_verse)}
      <div class="field"><label>File name</label><input value="${esc(doc.file_name)}" disabled></div>
      ${textField('Duration (video only)', 'duration', doc.duration)}
      ${selectField('Quality (video only)', 'quality', doc.quality, State.qualities)}
      <div class="field"><label>Status (free text)</label><input value="${esc(doc.original_status)}" disabled></div>
      <div class="field"><label>Legacy file name</label><input value="${esc(doc.legacy_file_name)}" disabled></div>
    </div>
    <div class="field">
      <label>Recipient(s)</label>
      <div class="btn-row" style="margin:0;">
        ${State.recipients.map(([c, l]) => `<label style="display:flex;align-items:center;gap:4px;font-size:12.5px;font-weight:normal;text-transform:none;">
          <input type="checkbox" class="f-doc-recipient" value="${c}" ${(doc.recipient || []).includes(c) ? 'checked' : ''} ${readOnly ? 'disabled' : ''}> ${l}</label>`).join('')}
      </div>
    </div>
    <div class="field">
      <label>Collections</label>
      <div class="btn-row" style="margin:0;flex-direction:column;align-items:flex-start;gap:4px;">
        ${State.collections.map(([c, l]) => {
          const existing = docCollections.find(dc => dc.collection_code === c);
          return `<label style="display:flex;align-items:center;gap:6px;font-size:12.5px;font-weight:normal;text-transform:none;">
            <input type="checkbox" class="f-doc-collection" value="${c}" ${existing ? 'checked' : ''} ${readOnly ? 'disabled' : ''}>
            <span style="min-width:180px;">${esc(l)}</span>
            <input class="f-doc-collection-page" data-code="${c}" type="number" placeholder="page" value="${esc(existing?.page_number)}" style="width:80px;" ${readOnly ? 'disabled' : ''}>
          </label>`;
        }).join('')}
      </div>
    </div>
    ${renderWorkSiblingsHtml(siblings, doc.document_id, canWrite())}
    ${readOnly ? `<div class="field"><label>Notes</label><textarea disabled>${esc(doc.notes)}</textarea></div>`
      : `<div class="field"><label>Notes</label><textarea data-f="notes">${esc(doc.notes)}</textarea></div>`}
    <div class="field">
      <label>File</label>
      ${doc.file_name
        ? `<div class="hint">Saved file name (kept as-is unless you upload a replacement below): <b>${esc(doc.file_name)}</b></div>`
        : (readOnly ? '' : `<div class="hint">No file linked yet - will be named <b id="filename-preview">${esc(previewName)}</b> once you upload one.</div>`)}
      ${doc.storage_path ? `<div class="hint">Currently on file: ${esc(doc.file_name)} — <a href="#" id="doc-download">Download</a></div>` : '<div class="hint">No file uploaded yet.</div>'}
      ${readOnly ? '' : '<input type="file" id="doc-file-input" accept=".pdf,.doc,.docx" style="margin-top:6px;">'}
      <button class="btn secondary" id="doc-download-gdrive" style="margin-top:8px;">Download Document (legacy archive)</button>
    </div>
    ${canWrite() ? `<div class="field">
      <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
        <input type="checkbox" id="f-pending-deletion" ${doc.pending_deletion ? 'checked' : ''}> Mark this document for deletion
      </label>
      <input data-f="pending_deletion_note" placeholder="Reason (optional)" value="${esc(doc.pending_deletion_note)}" style="margin-top:6px;">
    </div>` : ''}
    <div class="btn-row">
      ${canWrite() ? '<button class="btn" id="doc-save">Save changes</button>' : ''}
      <button class="btn secondary" id="doc-tracking-sheet">Print Tracking Sheet</button>
      ${canDelete() ? '<button class="btn danger" id="doc-delete">Delete permanently</button>' : ''}
    </div>
    ${renderProcessHistorySection(doc)}
  `;

  document.getElementById('doc-tracking-sheet').addEventListener('click', () => renderTrackingSheet(id));
  document.getElementById('doc-download-gdrive').addEventListener('click', () => downloadFromGDrive(doc.file_name));
  wireWorkSiblingsClicks(box, doc.work_id);
  wireAllVersionsBar(box, doc, siblings);
  if (doc.storage_path) {
    document.getElementById('doc-download').addEventListener('click', async e => {
      e.preventDefault();
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
  }
  await wireProcessHistorySection(id, doc);
  if (!canWrite()) return;

  function collectFields() {
    const out = {};
    box.querySelectorAll('[data-f]').forEach(el => out[el.dataset.f] = el.value === '' ? null : el.value);
    out.recipient = Array.from(box.querySelectorAll('.f-doc-recipient:checked')).map(c => c.value);
    if (out.recipient.length === 0) out.recipient = null;
    out.pending_deletion = document.getElementById('f-pending-deletion').checked;
    return out;
  }
  function collectCollections() {
    return Array.from(box.querySelectorAll('.f-doc-collection:checked')).map(cb => {
      const pageInput = box.querySelector(`.f-doc-collection-page[data-code="${cb.value}"]`);
      const page = pageInput.value.trim();
      return { collection_code: cb.value, page_number: page === '' ? null : parseInt(page, 10) };
    });
  }
  function updatePreview() {
    const preview = document.getElementById('filename-preview');
    if (!preview) return; // not shown once the document already has a file_name - see below
    const vals = collectFields();
    preview.textContent = computeFileName({ document_id: doc.document_id, ...vals });
  }
  box.querySelectorAll('[data-f="title"]').forEach(el => el.addEventListener('input', updatePreview));

  document.getElementById('doc-save').addEventListener('click', async () => {
    const vals = collectFields();
    const fileInput = document.getElementById('doc-file-input');
    const uploadingNewFile = fileInput.files && fileInput.files[0];
    let storagePath = doc.storage_path;

    if (uploadingNewFile) {
      // A real new file is being attached - safe (and useful) to give it a fresh computed name.
      const baseName = computeFileName({ document_id: doc.document_id, ...vals });
      const finalName = await uniqueFileName(baseName, doc.document_id);
      if (storagePath && storagePath !== finalName) {
        await sb.storage.from(BUCKET).remove([storagePath]);
      }
      await withStatus(sb.storage.from(BUCKET).upload(finalName, fileInput.files[0], { upsert: true }), 'Uploading file...');
      storagePath = finalName;
      vals.file_name = finalName;
    } else if (!doc.file_name) {
      // Nothing linked yet at all - a placeholder name is harmless since there's no real file to disconnect from.
      const baseName = computeFileName({ document_id: doc.document_id, ...vals });
      vals.file_name = await uniqueFileName(baseName, doc.document_id);
    }
    // Else: this document already has a real file (on Drive or in Storage) - file_name is left
    // out of `vals` entirely, so editing title/metadata can never silently disconnect it from
    // that file. Renaming an existing linked file is only ever done by uploading a replacement.
    vals.storage_path = storagePath;

    await withStatus(sb.from('documents').update(vals).eq('document_id', id), 'Saving...');
    await saveDocumentCollections(id, collectCollections());
    await onAfterDocChange();
    await renderDocDetail(id);
  });

  if (!canDelete()) return;
  document.getElementById('doc-delete').addEventListener('click', async () => {
    if (!confirm(`Permanently delete document #${id}? This cannot be undone.`)) return;
    if (doc.storage_path) await sb.storage.from(BUCKET).remove([doc.storage_path]);
    await withStatus(sb.from('documents').delete().eq('document_id', id));
    State.selectedDocId = null;
    await onAfterDocChange();
    await renderDocDetail(null);
  });
}

// Dashboard is the only view with a live grid that needs refreshing after a save/delete;
// Match Review doesn't have a #dash-grid on screen, so this is a no-op there.
async function onAfterDocChange() {
  if (window.__refreshDashGrid && document.getElementById('dash-grid')) await window.__refreshDashGrid();
}

// ---------- Process History ----------

function renderProcessHistorySection(doc) {
  return `
    <div class="panel" style="margin-top:14px;">
      <h3>Process history <span class="hint">— current step: ${esc(labelOf(State.statuses, doc.workflow_status)) || '—'}</span></h3>
      <div id="process-history-log"><div class="empty-msg">Loading...</div></div>
      ${canWrite() ? `
      <div class="field-grid" style="margin-top:10px;">
        <div class="field"><label>Step</label><select id="ph-step">${optionsHtml(State.statuses, doc.workflow_status, false)}</select></div>
        <div class="field"><label>Date</label><input id="ph-date" type="date" value="${esc(today())}"></div>
      </div>
      <div class="field"><label>Note</label><input id="ph-note" placeholder="Optional note"></div>
      <div class="btn-row"><button class="btn secondary" id="ph-add">Add step</button></div>` : ''}
    </div>`;
}

async function wireProcessHistorySection(documentId, doc) {
  await refreshProcessHistoryLog(documentId);
  const addBtn = document.getElementById('ph-add');
  if (!addBtn) return;
  addBtn.addEventListener('click', async () => {
    const step = document.getElementById('ph-step').value;
    const step_date = document.getElementById('ph-date').value || today();
    const note = document.getElementById('ph-note').value || null;
    await withStatus(sb.from('process_history').insert({ document_id: documentId, step, step_date, note }), 'Adding step...');
    await withStatus(sb.from('documents').update({ workflow_status: step }).eq('document_id', documentId), 'Updating status...');
    await onAfterDocChange();
    await renderDocDetail(documentId);
  });
}

async function refreshProcessHistoryLog(documentId) {
  const box = document.getElementById('process-history-log');
  if (!box) return;
  const rows = await withStatus(sb.from('process_history').select('*').eq('document_id', documentId).order('step_date', { ascending: false }).order('created_at', { ascending: false }));
  box.innerHTML = rows.length === 0 ? '<div class="empty-msg">No steps logged yet.</div>' : `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Step</th><th>Date</th><th>Note</th><th></th></tr></thead>
      <tbody>${rows.map(r => `<tr data-ph-id="${esc(r.id)}"><td>${esc(labelOf(State.statuses, r.step))}</td><td>${esc(r.step_date)}</td><td>${esc(r.note)}</td>
        <td>${canWrite() ? '<button class="btn danger ph-delete" style="padding:2px 8px;">Delete</button>' : ''}</td></tr>`).join('')}</tbody>
    </table></div>`;
  box.querySelectorAll('.ph-delete').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Delete this process step? The document\'s current step will be recalculated from what remains.')) return;
    const stepRowId = btn.closest('tr').dataset.phId;
    await withStatus(sb.from('process_history').delete().eq('id', stepRowId), 'Deleting step...');
    const remaining = await withStatus(sb.from('process_history').select('step').eq('document_id', documentId).order('step_date', { ascending: false }).order('created_at', { ascending: false }).limit(1));
    const newStatus = remaining[0]?.step || 'ENTR';
    await withStatus(sb.from('documents').update({ workflow_status: newStatus }).eq('document_id', documentId), 'Updating status...');
    await onAfterDocChange();
    await renderDocDetail(documentId);
  }));
}

// ---------- New document ----------

export async function createNewDocument(afterCreate) {
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.document_id || 0) + 1;
  const workId = await createWorkFor(null);
  await withStatus(sb.from('documents').insert({ document_id: newId, workflow_status: 'ENTR', legacy_migrated: false, work_id: workId }));
  State.selectedDocId = String(newId);
  if (afterCreate) await afterCreate();
  await renderDocDetail(State.selectedDocId);
}

// ---------- Print Tracking Sheet (now driven by the process_history log) ----------

export async function renderTrackingSheet(id) {
  const main = document.getElementById('main');
  const rows = await withStatus(sb.from('documents').select('*').eq('document_id', id));
  const doc = rows[0];
  if (!doc) return;
  const historyRows = await withStatus(sb.from('process_history').select('*').eq('document_id', id).order('step_date'));
  const doneSteps = new Set(historyRows.map(r => r.step));
  main.innerHTML = `
    <div class="btn-row no-print">
      <button class="btn secondary" id="back-to-dash">&larr; Back</button>
      <button class="btn" id="print-tracking">Print / Export PDF</button>
    </div>
    <div class="report-view" style="max-width:800px;margin:0 auto;">
      <h2>Focolare Urdu Archive - Document Tracking Sheet</h2>
      <table style="margin-bottom:16px;">
        <tr><th style="width:30%;">Document ID</th><td>${esc(doc.document_id)}</td></tr>
        <tr><th>Title</th><td>${esc(doc.title)}</td></tr>
        <tr><th>Category</th><td>${esc(labelOf(State.categories, doc.category))}</td></tr>
        <tr><th>Author</th><td>${esc(labelOf(State.authors, doc.author))}</td></tr>
        <tr><th>Main topic</th><td>${esc(labelOf(State.mainTopics, doc.main_topic))}</td></tr>
        <tr><th>Recipient(s)</th><td>${(doc.recipient || []).map(c => esc(labelOf(State.recipients, c))).join(', ')}</td></tr>
        <tr><th>Language</th><td>${esc(labelOf(State.langs, doc.language))}</td></tr>
        <tr><th>Source</th><td>${esc(labelOf(State.sources, doc.source))}</td></tr>
        <tr><th>Operator</th><td>${esc(labelOf(State.operators, doc.operator))}</td></tr>
        <tr><th>Reference date / period</th><td>${esc(doc.ref_date)} ${esc(doc.ref_period)}</td></tr>
        <tr><th>File name</th><td>${esc(doc.file_name)}</td></tr>
        <tr><th>Physical box</th><td>${esc(doc.physical_box)}</td></tr>
      </table>
      <h3 style="margin-bottom:6px;">Process Registry</h3>
      <table>
        <thead><tr><th>#</th><th>Step</th><th>Description</th><th>Date</th><th>Signature</th></tr></thead>
        <tbody>${TRACKING_STEPS.map((s, i) => {
          const done = historyRows.find(r => r.step === s[0]);
          return `<tr><td>${i + 1}</td><td>${esc(s[1])}</td><td>${esc(s[2])}</td><td style="min-width:90px;">${esc(done?.step_date) || '&nbsp;'}</td><td style="min-width:120px;">&nbsp;</td></tr>`;
        }).join('')}</tbody>
      </table>
      <h3 style="margin:16px 0 6px;">Additional Notes</h3>
      <div style="border-top:1px solid #999;height:20px;">${esc(doc.notes) || ''}</div>
    </div>
    <style>@media print { @page { size: A4; } }</style>
  `;
  document.getElementById('back-to-dash').addEventListener('click', () => window.__renderTab('dashboard'));
  document.getElementById('print-tracking').addEventListener('click', () => window.print());
}
