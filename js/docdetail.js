// The document detail panel - shared between Dashboard and Match Review (both give it a
// <div id="doc-detail"> to render into). Only this module and core.js know about the
// `documents` table's full field set.

import {
  sb, State, esc, today, labelOf, optionsHtml, canWrite, canDelete, isCoordinator, isAdmin,
  computeFileName, uniqueFileName, withStatus, BUCKET, downloadFromGDrive,
  createWorkFor, TRACKING_STEPS, getCollectionsForDocument, saveDocumentCollections, setPreferredVersion,
  readPdfPageCount, getDisplayNameByEmail,
} from './core.js?v=20260902165344';

// Categories that gate visibility/assignment to a specific qualification - duplicated from the
// same constant in tasks.js (project convention: modules only import from core.js, never each
// other) - mirrors 37_task_qualifications_categories.sql. Keep all three in sync.
const CATEGORY_REQUIRES_QUALIFICATION = { IT_UR: 'TRANSLATOR', EN_UR: 'TRANSLATOR', REVISION: 'REVISOR' };
const TASK_STATUS_LABEL = { open: 'Open', claimed: 'Claimed', submitted: 'Submitted', approved: 'Approved', rejected: 'Rejected', published: 'Published' };

// Builds the "riassunto" text block that replaces the old grid of disabled input fields -
// one line per group of related info, empty groups dropped entirely so the block stays short.
function renderDocSummary(doc) {
  const line = (...parts) => parts.filter(Boolean).join(' · ');
  const lines = [
    line(esc(labelOf(State.categories, doc.category)), esc(labelOf(State.authors, doc.author)), esc(labelOf(State.mainTopics, doc.main_topic))),
    line(doc.place ? 'Place: ' + esc(doc.place) : '', doc.ref_date ? 'Reference date: ' + esc(doc.ref_date) : ''),
    doc.secondary_tags ? 'Tags: ' + esc(doc.secondary_tags) : '',
    line('Language: ' + esc(labelOf(State.langs, doc.language)), esc(labelOf(State.mediaTypes, doc.media_type)),
      doc.media_type === 'VID' && doc.duration ? 'Duration: ' + esc(doc.duration) : '',
      doc.media_type === 'VID' && doc.quality ? 'Quality: ' + esc(labelOf(State.qualities, doc.quality)) : ''),
  ].filter(Boolean);
  return lines.map(l => `<div>${l}</div>`).join('');
}

export function renderDocDetailConsultation(box, doc, workSiblings, docCollections, canEdit) {
  box.innerHTML = `
    <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 8px;">
      <h3 style="margin:0;">Document #${esc(doc.document_id)}</h3>
      <div class="btn-row" style="margin:0;">
        ${canEdit ? '<button class="btn secondary" id="doc-open-editor">Edit</button>' : ''}
        <button class="btn" id="doc-download-gdrive">Open</button>
      </div>
    </div>
    <div class="field" style="font-size:13px;line-height:1.7;">
      <div style="font-weight:600;font-size:14px;margin-bottom:2px;">${esc(doc.en_title) || '<span class="hint">(no title)</span>'}</div>
      ${doc.ur_title ? `<div dir="auto" style="font-size:14px;margin-bottom:6px;">${esc(doc.ur_title)}</div>` : ''}
      ${renderDocSummary(doc)}
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
    ${doc.storage_path ? `<div class="field"><label>File</label><a href="#" id="doc-download">Download</a></div>` : ''}
    ${canEdit ? renderDocTasksBox(doc) : ''}
  `;
  document.getElementById('doc-download-gdrive').addEventListener('click', () => downloadFromGDrive(doc.file_name));
  if (canEdit) {
    document.getElementById('doc-open-editor').addEventListener('click', () => openFullScreenEditor(doc.document_id));
    document.getElementById('doc-create-task').addEventListener('click', () => openCreateTaskPopup(doc, () => refreshDocTasksList(doc)));
    refreshDocTasksList(doc);
  }
  if (doc.storage_path) {
    document.getElementById('doc-download').addEventListener('click', async e => {
      e.preventDefault();
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
  }
  wireWorkSiblingsClicks(box);
}

// ---------- Tasks for this document (Coordinator/Admin only, see canEdit above) ----------

function renderDocTasksBox(doc) {
  return `
    <div class="field">
      <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 4px;">
        <label style="margin:0;">Tasks for this document</label>
        <button class="btn secondary" id="doc-create-task" style="padding:4px 10px;">Create Task</button>
      </div>
      <div id="doc-tasks-list"><div class="hint">Loading...</div></div>
    </div>`;
}

async function refreshDocTasksList(doc) {
  const box = document.getElementById('doc-tasks-list');
  if (!box) return;
  const rows = await withStatus(sb.from('tasks').select('*').eq('document_id', doc.document_id).order('created_at', { ascending: false }));
  if (!rows.length) { box.innerHTML = '<div class="hint">No tasks yet for this document.</div>'; return; }
  const names = await Promise.all(rows.map(t => t.claimed_by_email ? getDisplayNameByEmail(t.claimed_by_email) : Promise.resolve(null)));
  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>ID</th><th>Status</th><th>Claimed by</th><th>Due date</th><th>Credits</th></tr></thead>
      <tbody>${rows.map((t, i) => `<tr>
        <td>#${esc(t.id)}</td>
        <td>${esc(TASK_STATUS_LABEL[t.status] || t.status)}</td>
        <td>${esc(names[i]) || '<span class="hint">— open —</span>'}</td>
        <td>${esc(t.due_date) || '—'}</td>
        <td>${t.credits != null ? esc(t.credits) : '—'}</td>
      </tr>`).join('')}</tbody>
    </table></div>`;
}

async function openCreateTaskPopup(doc, onCreated) {
  document.getElementById('doc-create-task-popup')?.remove();
  const overlay = document.createElement('div');
  overlay.id = 'doc-create-task-popup';
  overlay.style.cssText = 'position:fixed;inset:0;z-index:2100;background:rgba(20,16,10,.55);display:flex;align-items:center;justify-content:center;overflow:auto;padding:24px 16px;';
  overlay.innerHTML = '<div class="panel" style="max-width:560px;width:100%;margin:0;"></div>';
  document.body.appendChild(overlay);
  const panel = overlay.querySelector('.panel');
  const close = () => overlay.remove();
  overlay.addEventListener('click', e => { if (e.target === overlay) close(); });

  const rateRows = await withStatus(sb.from('task_category_rates').select('*'));
  const categoryRates = Object.fromEntries(rateRows.map(r => [r.category, r.credits_per_page]));
  const opRows = await withStatus(sb.from('user_roles').select('user_id,email').in('role', ['operator', 'coordinator']).order('email'));
  const opNames = await Promise.all(opRows.map(r => getDisplayNameByEmail(r.email)));
  const qualRows = await withStatus(sb.from('user_qualifications').select('*'));
  const qualByUid = {};
  for (const q of qualRows) (qualByUid[q.user_id] ||= new Set()).add(q.qualification_code);
  const operators = opRows.map((r, i) => ({ ...r, displayName: opNames[i], qualifications: qualByUid[r.user_id] || new Set() }));

  panel.innerHTML = `
    <h2 style="margin-top:0;">Create Task <span class="hint">— Document #${esc(doc.document_id)}</span></h2>
    <div class="field-grid">
      <div class="field" style="grid-column:1/-1;"><label>Title</label><input id="ct-title" value="${esc(doc.title || doc.original_title || '')}"></div>
      <div class="field" style="grid-column:1/-1;"><label>Description</label><textarea id="ct-desc" rows="2"></textarea></div>
      <div class="field"><label>Category</label><select id="ct-category">${optionsHtml(State.optionListsByName.task_category || [], '', true)}</select></div>
      <div class="field"><label>Document pages</label><input id="ct-pages" type="number" min="0" value="${esc(doc.pages ?? '')}">
        <div class="hint" id="ct-pages-status">${doc.pages == null ? 'Reading from file...' : ''}</div>
      </div>
      <div class="field"><label>Base credits <span class="hint">(rate &times; pages)</span></label><input id="ct-base-credits" value="0" disabled></div>
      <div class="field"><label>Extra credits <span class="hint">(optional)</span></label><input id="ct-extra-credits" type="number" value="0"></div>
      <div class="field" id="ct-extra-note-field" style="display:none;grid-column:1/-1;"><label>Why the extra credits?</label><select id="ct-extra-note">${optionsHtml(State.optionListsByName.extra_credit_reason || [], '', true)}</select></div>
      <div class="field" style="grid-column:1/-1;"><label>Total credits</label><div id="ct-total-credits" style="font-size:14px;font-weight:600;">0</div></div>
      <div class="field"><label>Assign directly to <span class="hint">(optional)</span></label><select id="ct-assignee"></select></div>
      <div class="field" id="ct-due-field" style="display:none;"><label>Due date</label><input id="ct-due" type="date"></div>
    </div>
    <div class="btn-row"><button class="btn" id="ct-submit">Create task</button><button class="btn secondary" id="ct-cancel">Cancel</button></div>`;

  function recompute() {
    const category = document.getElementById('ct-category').value;
    const rate = categoryRates[category] || 0;
    const pages = parseFloat(document.getElementById('ct-pages').value) || 0;
    const base = Math.round(rate * pages);
    document.getElementById('ct-base-credits').value = base;
    const extra = parseInt(document.getElementById('ct-extra-credits').value, 10) || 0;
    document.getElementById('ct-total-credits').textContent = base + extra;
    document.getElementById('ct-extra-note-field').style.display = extra !== 0 ? 'block' : 'none';
  }
  function refreshAssignees() {
    const category = document.getElementById('ct-category').value;
    const requiredQual = CATEGORY_REQUIRES_QUALIFICATION[category];
    const eligible = requiredQual ? operators.filter(o => o.qualifications.has(requiredQual)) : operators;
    const sel = document.getElementById('ct-assignee');
    sel.innerHTML = '<option value="">— leave open —</option>' + eligible.map(o => `<option value="${o.user_id}" data-email="${esc(o.email)}">${esc(o.displayName)}</option>`).join('');
    document.getElementById('ct-due-field').style.display = 'none';
  }
  document.getElementById('ct-category').addEventListener('change', () => { recompute(); refreshAssignees(); });
  document.getElementById('ct-pages').addEventListener('input', recompute);
  document.getElementById('ct-extra-credits').addEventListener('input', recompute);
  document.getElementById('ct-assignee').addEventListener('change', e => {
    document.getElementById('ct-due-field').style.display = e.target.value ? 'block' : 'none';
  });
  recompute();
  refreshAssignees();

  // Auto-read the page count from the actual PDF when the document doesn't have one saved yet
  // (same pdf.js mechanism as the "Read from file" button in the full editor) - only when the
  // popup is still open by the time it resolves, since this document could get closed quickly.
  if (doc.pages == null) {
    readPdfPageCount(doc).then(n => {
      if (!document.body.contains(overlay)) return;
      const status = document.getElementById('ct-pages-status');
      if (n == null) { status.textContent = 'Could not read the file automatically - enter the page count by hand.'; return; }
      document.getElementById('ct-pages').value = n;
      status.textContent = `Read ${n} page${n === 1 ? '' : 's'} from the file.`;
      recompute();
    });
  }

  document.getElementById('ct-cancel').addEventListener('click', close);
  document.getElementById('ct-submit').addEventListener('click', async () => {
    const title = document.getElementById('ct-title').value.trim();
    if (!title) { alert('Please enter a title.'); return; }
    const baseCredits = parseInt(document.getElementById('ct-base-credits').value, 10) || 0;
    const extraCredits = parseInt(document.getElementById('ct-extra-credits').value, 10) || 0;
    const extraNote = document.getElementById('ct-extra-note').value.trim();
    if (extraCredits !== 0 && !extraNote) { alert('Please explain why you are adding extra credits.'); return; }
    const assigneeSel = document.getElementById('ct-assignee');
    const assigneeId = assigneeSel.value || null;
    const assigneeEmail = assigneeId ? assigneeSel.selectedOptions[0].dataset.email : null;
    const dueDate = document.getElementById('ct-due').value || null;
    if (assigneeId && !dueDate) { alert('Please set a due date for the person you are assigning this to.'); return; }
    const taskPages = parseInt(document.getElementById('ct-pages').value, 10) || null;
    // If the document itself never had its page count recorded, save what was typed here back
    // onto the document too, so the next task on it (or the doc detail view) doesn't start blank.
    if (taskPages != null && doc.pages == null) {
      await withStatus(sb.from('documents').update({ pages: taskPages }).eq('document_id', doc.document_id), 'Saving page count...');
      doc.pages = taskPages;
    }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('tasks').insert({
      title, description: document.getElementById('ct-desc').value.trim() || null,
      category: document.getElementById('ct-category').value || null,
      document_id: doc.document_id, document_pages: taskPages,
      base_credits: baseCredits, extra_credits: extraCredits, extra_credits_note: extraNote || null,
      credits: baseCredits + extraCredits,
      created_by_email: user.email,
      status: assigneeId ? 'claimed' : 'open',
      claimed_by: assigneeId, claimed_by_email: assigneeEmail,
      claimed_at: assigneeId ? new Date().toISOString() : null,
      due_date: dueDate,
    }), 'Creating task...');
    close();
    await onCreated();
  });
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
  // Consultation (canEdit false - plain User/Operator reading a document) shows only the
  // fields someone browsing needs to pick a version; the editing context (canEdit true) keeps
  // the fuller set needed to actually manage versions (source/type/file, set-preferred).
  const headCells = canEdit
    ? '<th>ID</th><th>Title</th><th>Language</th><th>Source</th><th>Type</th><th>File</th><th>Preferred</th><th></th>'
    : '<th>ID</th><th>Title</th><th>Category</th><th>Author</th><th>Language</th><th></th>';
  return `
    <div class="field">
      <label>Other versions of this document</label>
      <div class="grid-wrap"><table class="grid">
        <thead><tr>${headCells}</tr></thead>
        <tbody>${others.map(s => {
          const cells = canEdit
            ? `<td>${esc(s.document_id)}</td><td>${esc(s.title)}</td><td>${esc(labelOf(State.langs, s.language))}</td>
               <td>${esc(labelOf(State.sources, s.source))}</td><td>${esc(labelOf(State.mediaTypes, s.media_type))}</td>
               <td>${esc(s.file_name)}</td>
               <td>${s.is_preferred ? '<span class="count-badge">&#9733; Preferred</span>'
                   : `<button class="btn secondary sibling-set-preferred" style="padding:2px 8px;">Set preferred</button>`}</td>`
            : `<td>${esc(s.document_id)}</td><td>${esc(s.title)}</td><td>${esc(labelOf(State.categories, s.category))}</td>
               <td>${esc(labelOf(State.authors, s.author))}</td><td>${esc(labelOf(State.langs, s.language))}</td>`;
          return `<tr data-sibling-id="${esc(s.document_id)}">
          ${cells}
          <td><button class="btn secondary sibling-open" style="padding:2px 8px;">Open</button></td>
        </tr>`;
        }).join('')}</tbody>
      </table></div>
    </div>`;
}

// `navigate` lets the two contexts that reuse this (plain consultation vs. the full editor,
// either inline for Match Review or in the full-screen overlay) each decide what "open this
// sibling" means for them - default is a normal Dashboard-style navigation.
function wireWorkSiblingsClicks(box, workId, navigate) {
  navigate = navigate || (async targetId => { State.selectedDocId = targetId; await onAfterDocChange(); await renderDocDetail(targetId); });
  box.querySelectorAll('tr[data-sibling-id]').forEach(tr => {
    tr.addEventListener('click', () => navigate(tr.dataset.siblingId));
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
      await navigate(State.selectedDocId);
    });
  });
}

async function fetchWorkSiblings(workId) {
  if (!workId) return [];
  return await withStatus(sb.from('documents').select('document_id,title,category,author,language,source,media_type,file_name,is_preferred,storage_path').eq('work_id', workId));
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

// The Dashboard now always shows the simplified, read-only consultation panel for every role
// (User/Operator/Coordinator/Admin alike) - Coordinator/Admin additionally get an "Edit" button
// there that opens the full field editor in a full-screen overlay (openFullScreenEditor below),
// replacing the old "Edit Records" tab entirely. `opts.legacyFullEdit` preserves the previous
// inline-in-the-side-panel behavior for Match Review, which still needs it (see matchreview.js).
export async function renderDocDetail(id, opts = {}) {
  const box = document.getElementById('doc-detail');
  if (!box) return;
  if (!id) { box.innerHTML = '<div class="empty-msg">Select a document from the list, or create a new one.</div>'; return; }
  const rows = await withStatus(sb.from('documents').select('*').eq('document_id', id));
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Document not found.</div>'; return; }
  const doc = rows[0];
  const siblings = await fetchWorkSiblings(doc.work_id);
  const docCollections = await getCollectionsForDocument(doc.document_id);

  if (opts.legacyFullEdit && canWrite()) {
    renderFullEditForm(box, id, doc, siblings, docCollections, {
      mode: 'legacy',
      onDone: () => renderDocDetail(id, { legacyFullEdit: true }),
      refreshSelf: () => renderDocDetail(id, { legacyFullEdit: true }),
      onDelete: () => renderDocDetail(null, { legacyFullEdit: true }),
      navigateSibling: targetId => renderDocDetail(targetId, { legacyFullEdit: true }),
    });
    return;
  }

  const canEdit = isCoordinator() || isAdmin();
  renderDocDetailConsultation(box, doc, siblings, docCollections, canEdit);
}

// Opens the full field editor for a document in a full-screen overlay (Coordinator/Admin only,
// triggered by the "Edit" button in the consultation panel). Re-fetches its own data rather
// than reusing what the consultation panel already has, so it's always safe to call standalone.
export async function openFullScreenEditor(id) {
  const rows = await withStatus(sb.from('documents').select('*').eq('document_id', id));
  if (!rows.length) { alert('Document not found.'); return; }
  const doc = rows[0];
  const siblings = await fetchWorkSiblings(doc.work_id);
  const docCollections = await getCollectionsForDocument(doc.document_id);

  document.getElementById('doc-fullscreen-editor')?.remove();
  const overlay = document.createElement('div');
  overlay.id = 'doc-fullscreen-editor';
  overlay.style.cssText = 'position:fixed;inset:0;z-index:2000;background:rgba(20,16,10,.55);display:flex;justify-content:center;overflow:auto;padding:24px 16px;';
  overlay.innerHTML = '<div class="panel" id="doc-fullscreen-editor-panel" style="max-width:900px;width:100%;height:fit-content;margin:0;"></div>';
  document.body.appendChild(overlay);
  const panel = overlay.querySelector('#doc-fullscreen-editor-panel');

  function close() { overlay.remove(); }
  async function closeAndReturn() { close(); await onAfterDocChange(); await renderDocDetail(id); }

  renderFullEditForm(panel, id, doc, siblings, docCollections, {
    mode: 'overlay',
    onDone: closeAndReturn,
    refreshSelf: () => openFullScreenEditor(id),
    onDelete: async () => { close(); State.selectedDocId = null; await onAfterDocChange(); await renderDocDetail(null); },
    onClose: close,
    navigateSibling: targetId => openFullScreenEditor(targetId),
  });
}

// Builds the full field-editor form into `box` (either the Dashboard's side panel for legacy
// Match Review use, or the full-screen overlay panel) - ctx tells it what to do once an action
// (save/delete/process-history change/close) completes, since that differs by context.
async function renderFullEditForm(box, id, doc, siblings, docCollections, ctx) {
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
      ${textField('Ur-Title', 'ur_title', doc.ur_title)}
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
      <div class="field"><label>Pages</label>
        <div class="btn-row" style="margin:0;gap:6px;">
          <input data-f="pages" type="number" value="${esc(doc.pages)}">
          <button type="button" class="btn secondary" id="doc-read-pages" style="padding:6px 10px;white-space:nowrap;">Read from file</button>
        </div>
        <div class="hint" id="doc-read-pages-status"></div>
      </div>
      <div class="field"><label>File name</label><input value="${esc(doc.file_name)}" disabled></div>
      ${textField('Duration (video only)', 'duration', doc.duration)}
      ${selectField('Quality (video only)', 'quality', doc.quality, State.qualities)}
      <div class="field"><label>Legacy file name</label><input value="${esc(doc.legacy_file_name)}" disabled></div>
    </div>
    <div class="field">
      <label>Recipient</label>
      <select id="f-doc-recipient" ${readOnly ? 'disabled' : ''}>${optionsHtml(State.recipients, (doc.recipient || [])[0], true)}</select>
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
      ${ctx.mode === 'overlay' ? '<button class="btn secondary" id="doc-editor-close">Close</button>' : ''}
      <button class="btn secondary" id="doc-tracking-sheet">Print Tracking Sheet</button>
      ${canDelete() ? '<button class="btn danger" id="doc-delete">Delete permanently</button>' : ''}
    </div>
    ${renderProcessHistorySection(doc)}
  `;

  document.getElementById('doc-tracking-sheet').addEventListener('click', () => renderTrackingSheet(id));
  document.getElementById('doc-download-gdrive').addEventListener('click', () => downloadFromGDrive(doc.file_name));
  if (ctx.mode === 'overlay') document.getElementById('doc-editor-close').addEventListener('click', () => ctx.onClose());
  document.getElementById('doc-read-pages').addEventListener('click', async () => {
    const status = document.getElementById('doc-read-pages-status');
    status.textContent = 'Reading file...';
    const n = await readPdfPageCount(doc);
    if (n == null) { status.textContent = 'Could not read the file automatically - enter the page count by hand.'; return; }
    box.querySelector('[data-f="pages"]').value = n;
    status.textContent = `Read ${n} page${n === 1 ? '' : 's'} from the file.`;
  });
  wireWorkSiblingsClicks(box, doc.work_id, ctx.navigateSibling);
  wireAllVersionsBar(box, doc, siblings);
  if (doc.storage_path) {
    document.getElementById('doc-download').addEventListener('click', async e => {
      e.preventDefault();
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
  }
  await wireProcessHistorySection(id, doc, ctx.refreshSelf);
  if (!canWrite()) return;

  function collectFields() {
    const out = {};
    box.querySelectorAll('[data-f]').forEach(el => out[el.dataset.f] = el.value === '' ? null : el.value);
    if ('pages' in out) out.pages = out.pages === null ? null : parseInt(out.pages, 10);
    const recipientVal = document.getElementById('f-doc-recipient').value;
    out.recipient = recipientVal ? [recipientVal] : null;
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
    await ctx.onDone();
  });

  if (!canDelete()) return;
  document.getElementById('doc-delete').addEventListener('click', async () => {
    if (!confirm(`Permanently delete document #${id}? This cannot be undone.`)) return;
    if (doc.storage_path) await sb.storage.from(BUCKET).remove([doc.storage_path]);
    await withStatus(sb.from('documents').delete().eq('document_id', id));
    await ctx.onDelete();
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

async function wireProcessHistorySection(documentId, doc, refreshSelf) {
  await refreshProcessHistoryLog(documentId, refreshSelf);
  const addBtn = document.getElementById('ph-add');
  if (!addBtn) return;
  addBtn.addEventListener('click', async () => {
    const step = document.getElementById('ph-step').value;
    const step_date = document.getElementById('ph-date').value || today();
    const note = document.getElementById('ph-note').value || null;
    await withStatus(sb.from('process_history').insert({ document_id: documentId, step, step_date, note }), 'Adding step...');
    await withStatus(sb.from('documents').update({ workflow_status: step }).eq('document_id', documentId), 'Updating status...');
    await onAfterDocChange();
    await refreshSelf();
  });
}

async function refreshProcessHistoryLog(documentId, refreshSelf) {
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
    await refreshSelf();
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
