// The document detail panel - shared between Dashboard and Match Review (both give it a
// <div id="doc-detail"> to render into). Only this module and core.js know about the
// `documents` table's full field set.

import {
  sb, State, esc, today, labelOf, optionsHtml, canWrite, canDelete, isCoordinator, isAdmin,
  computeFileName, uniqueFileName, withStatus, BUCKET, downloadFromGDrive,
  createWorkFor, TRACKING_STEPS, getCollectionsForDocument, saveDocumentCollections, setPreferredVersion,
  readPdfPageCount, readPdfPageCountFromBlob, getDisplayNameByEmail, openBoardPostPopup, isDocPostable,
  openFormationPostPopup, canReviewApplications, openTranslatePopup, nextDocumentId, logEntriesHtml,
  ACCESS_LEVELS, canManageReserved, HIDDEN_DOC_STATUSES, isMediaLinkOk, audioFileUrl, videoLinkHtml, mountAudioPlayer, eraseMyAudioFiles,
} from './core.js?v=20261106165033';

function favLabel(docId) { return State.myFavorites.has(docId) ? '★ Saved' : '☆ Save'; }

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
    doc.access_level === 'reserved' ? '<span class="count-badge">Reserved</span>' : '',
    line(esc(labelOf(State.categories, doc.category)), esc(labelOf(State.authors, doc.author)), esc(labelOf(State.mainTopics, doc.main_topic))),
    line(doc.place ? 'Place: ' + esc(doc.place) : '', doc.ref_date ? 'Reference date: ' + esc(doc.ref_date) : ''),
    doc.secondary_tags ? 'Tags: ' + esc(doc.secondary_tags) : '',
    line('Language: ' + esc(labelOf(State.langs, doc.language)), esc(labelOf(State.mediaTypes, doc.media_type)),
      ['VID', 'AUD'].includes(doc.media_type) && doc.duration ? 'Duration: ' + esc(doc.duration) : '',
      doc.media_type === 'VID' && doc.quality ? 'Quality: ' + esc(labelOf(State.qualities, doc.quality)) : ''),
  ].filter(Boolean);
  return lines.map(l => `<div>${l}</div>`).join('');
}

// The urdu body text (document_texts, migration 68) - not part of `documents`, so it needs its
// own query, always run alongside the summary fetch in renderDocDetail below. A text not yet
// reviewed is labelled as an unverified automatic transcription, per the warning already
// written into 68_document_texts.sql when the table was created: presenting machine-converted
// text as authoritative before a human has read it would be worse than not showing it at all.
function renderDocTextBox(text) {
  if (!text) return '';
  const chars = text.char_count || (text.body || '').length;
  return `
    <div class="field">
      <div class="btn-row" style="justify-content:space-between;align-items:center;">
        <label style="margin:0;">Text <span class="hint">(${chars.toLocaleString()} characters)</span></label>
        <span style="cursor:pointer;text-decoration:underline;font-size:12.5px;" id="doc-text-toggle">Show</span>
      </div>
      <div id="doc-text-body" dir="auto" style="display:none;white-space:pre-wrap;font-size:14px;line-height:1.8;margin-top:6px;max-height:60vh;overflow-y:auto;">${esc(text.body)}</div>
    </div>`;
}

// "Open editable text" (PROJECT_HANDOFF_v31.md §2 point 1) - a plain, selectable/copyable form of
// the same document_texts row the box above shows styled. Needed because the styled preview above
// is a plain <div>, not an <input>/<textarea>, so mobile browsers and some desktop ones don't offer
// a normal copy affordance on it. Read-only textarea + Copy/Report a problem/Close, same popup
// shell as confirmPopup/openBoardPostPopup in core.js (overlay-backdrop + panel overlay-panel),
// but kept here rather than core.js since only this module needs it.
//
// "Report a problem" hands off to chat.js prefilled with whatever passage the reader was just
// looking at: the textarea's current selection if one is still live, or (a mobile reader may have
// used the OS's own copy gesture, which can clear the JS-visible selection) whatever is on the
// clipboard as a fallback - best-effort, silently empty if neither is available or the browser
// denies clipboard reads. Copy respects a live selection the same way, so "select a paragraph,
// copy it, report it" is one continuous motion rather than three unrelated actions.
async function selectedOrClipboardText(textarea) {
  const selected = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd).trim();
  if (selected) return selected;
  try { return (await navigator.clipboard.readText()).trim(); } catch { return ''; }
}

// "Original text" (migration 101, owner's request 2026-09-20): the Italian source text a
// Collegamento was translated from, matched to this archive by the same 5-digit document_id used
// in the Google Drive export it came from. Same read-only popup shell as openDocTextPopup above,
// kept separate (not folded into that function) since the two texts have independent existence -
// a document can have one, both, or neither, and mixing the two popups' state would be fragile.
// navigator.clipboard is refused on some hosts/browsers; selecting the whole text and using the
// legacy execCommand keeps Copy working there, and otherwise leaves the text selected for Ctrl+C.
function copySelectionFallback(textarea) {
  textarea.focus();
  if (!textarea.selectionEnd || textarea.selectionStart === textarea.selectionEnd) textarea.select();
  let ok = false;
  try { ok = document.execCommand('copy'); } catch { ok = false; }
  alert(ok ? 'Text copied.' : 'Could not copy automatically - the text is selected, press Ctrl+C (or use the Copy option of your phone).');
}

function openOriginalTextPopup(doc, originalText) {
  document.getElementById('doc-original-text-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'doc-original-text-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Original text (Italian)</h2>
      ${!originalText.reviewed ? '<div class="hint" style="color:var(--danger, #b3261e);">Imported text, not yet checked against the source.</div>' : ''}
      <textarea id="doc-original-text-popup-body" readonly style="width:100%;min-height:50vh;font-size:14px;line-height:1.8;">${esc(originalText.body)}</textarea>
      <div class="btn-row" style="justify-content:flex-end;margin-top:8px;">
        <button class="btn secondary" id="doc-original-text-popup-copy">Copy</button>
        <button class="btn" id="doc-original-text-popup-close">Close</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  const textarea = document.getElementById('doc-original-text-popup-body');
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('doc-original-text-popup-close').addEventListener('click', () => backdrop.remove());
  document.getElementById('doc-original-text-popup-copy').addEventListener('click', async () => {
    const selected = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
    try { await navigator.clipboard.writeText(selected || originalText.body); alert(selected ? 'Selected text copied.' : 'Text copied.'); }
    catch { copySelectionFallback(textarea); }
  });
}

// "Read (large print)" (owner's request 2026-10-27: many members, especially older ones, struggle
// to read the text at normal size). A full-screen reading view of the same document_texts body, with
// big type, generous line spacing and a three-way contrast choice, none of which needs the user to
// pinch-zoom. The size and contrast are remembered per device (localStorage, in try/catch: the view
// works without it). Read-only - editing and copying stay in "Open editable text".
const READING_SIZES = [18, 22, 26, 32, 40, 48];
const READING_MODES = ['normal', 'dark', 'light'];
const READING_MODE_LABELS = { normal: 'Colours: app', dark: 'Colours: white on black', light: 'Colours: black on white' };
function loadReadingPrefs() {
  try { const p = JSON.parse(localStorage.getItem('readingPrefs') || '{}'); return { size: READING_SIZES.includes(p.size) ? p.size : 26, mode: READING_MODES.includes(p.mode) ? p.mode : 'normal' }; }
  catch { return { size: 26, mode: 'normal' }; }
}
function saveReadingPrefs(prefs) { try { localStorage.setItem('readingPrefs', JSON.stringify(prefs)); } catch { /* private mode: not remembered */ } }

function openReadingView(doc, text) {
  document.getElementById('reading-view')?.remove();
  const prefs = loadReadingPrefs();
  const view = document.createElement('div');
  view.id = 'reading-view';
  view.className = 'reading-view';
  view.setAttribute('role', 'dialog');
  view.setAttribute('aria-label', 'Reading view');
  view.innerHTML = `
    <div class="reading-toolbar">
      <button class="btn secondary" id="rv-smaller" aria-label="Smaller text">A&minus;</button>
      <button class="btn secondary" id="rv-bigger" aria-label="Bigger text">A+</button>
      <button class="btn secondary" id="rv-mode"></button>
      <button class="btn" id="rv-close">Close</button>
    </div>
    <div class="reading-body" id="rv-scroll">
      <div class="reading-title">${esc(doc.en_title)}</div>
      ${doc.ur_title ? `<div class="reading-title" dir="auto">${esc(doc.ur_title)}</div>` : ''}
      <div id="rv-text" class="reading-text" dir="auto">${esc(text.body)}</div>
    </div>`;
  document.body.appendChild(view);
  const textEl = document.getElementById('rv-text');
  const apply = () => {
    view.dataset.mode = prefs.mode;
    textEl.style.fontSize = prefs.size + 'px';
    document.getElementById('rv-mode').textContent = READING_MODE_LABELS[prefs.mode];
    document.getElementById('rv-smaller').disabled = prefs.size === READING_SIZES[0];
    document.getElementById('rv-bigger').disabled = prefs.size === READING_SIZES[READING_SIZES.length - 1];
    saveReadingPrefs(prefs);
  };
  const close = () => { view.remove(); document.removeEventListener('keydown', onKey); };
  const onKey = e => { if (e.key === 'Escape') close(); };
  document.addEventListener('keydown', onKey);
  document.getElementById('rv-close').addEventListener('click', close);
  document.getElementById('rv-smaller').addEventListener('click', () => { prefs.size = READING_SIZES[Math.max(0, READING_SIZES.indexOf(prefs.size) - 1)]; apply(); });
  document.getElementById('rv-bigger').addEventListener('click', () => { prefs.size = READING_SIZES[Math.min(READING_SIZES.length - 1, READING_SIZES.indexOf(prefs.size) + 1)]; apply(); });
  document.getElementById('rv-mode').addEventListener('click', () => { prefs.mode = READING_MODES[(READING_MODES.indexOf(prefs.mode) + 1) % READING_MODES.length]; apply(); });
  apply();
}

function openDocTextPopup(doc, text) {
  document.getElementById('doc-text-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'doc-text-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Text</h2>
      <textarea id="doc-text-popup-body" readonly dir="auto" style="width:100%;min-height:50vh;font-size:14px;line-height:1.8;">${esc(text.body)}</textarea>
      <div class="btn-row" style="justify-content:flex-end;margin-top:8px;">
        <button class="btn secondary" id="doc-text-popup-copy">Copy</button>
        <button class="btn secondary" id="doc-text-popup-report">Report a problem</button>
        <button class="btn" id="doc-text-popup-close">Close</button>
      </div>
      <p class="hint" style="margin-top:8px;">If you find a mistake in a paragraph of the text, please select and copy the paragraph and paste it in the message of your report.</p>
    </div>`;
  document.body.appendChild(backdrop);
  const textarea = document.getElementById('doc-text-popup-body');
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('doc-text-popup-close').addEventListener('click', () => backdrop.remove());
  document.getElementById('doc-text-popup-copy').addEventListener('click', async () => {
    const selected = textarea.value.slice(textarea.selectionStart, textarea.selectionEnd);
    try { await navigator.clipboard.writeText(selected || text.body); alert(selected ? 'Selected text copied.' : 'Text copied.'); }
    catch { copySelectionFallback(textarea); }
  });
  document.getElementById('doc-text-popup-report').addEventListener('click', async () => {
    State.selectedDocId = doc.document_id;
    State.chatMessagePrefill = await selectedOrClipboardText(textarea);
    backdrop.remove();
    window.__renderTab('chat');
  });
}

// Opens the proposal form already filled in from this document, and tied to its Work for good: this is
// what makes the two versions of one another (GOVERNANCE.md §5.14). A document with no Work gets one first.
async function addRelatedVersion(doc, siblings) {
  const title = doc.en_title || doc.title || doc.original_title || '';
  let workId = doc.work_id;
  if (!workId) {
    workId = await createWorkFor(title);
    await withStatus(sb.from('documents').update({ work_id: workId }).eq('document_id', doc.document_id), 'Saving...');
  }
  const others = [doc, ...(siblings || []).filter(s => String(s.document_id) !== String(doc.document_id))]
    .filter(v => !HIDDEN_DOC_STATUSES.includes(v.workflow_status));
  const hasUrdu = others.some(v => v.language === 'URD' && (v.media_type || 'DOC') === 'DOC');
  State.proposalPrefill = {
    workId,
    workLabel: title,
    common: {
      related_to_document_id: doc.document_id,
      en_title: doc.en_title || doc.title || '', category: doc.category || '', author: doc.author || '',
      original_author: doc.original_author || '', ref_date: doc.ref_date || '', ref_period: doc.ref_period || '',
      recipient: (doc.recipient || [])[0] || '', main_topic: doc.main_topic || '', secondary_tags: doc.secondary_tags || '',
      bible_verse: doc.bible_verse || '', place: doc.place || '',
    },
    versions: [{ language: hasUrdu ? '' : 'URD', access_level: doc.access_level === 'reserved' ? 'reserved' : (doc.access_level || 'private') }],
    existing: others.map(v => ({ language: v.language, media_type: v.media_type || 'DOC' })),
  };
  window.__renderTab('proposals');
}

export function renderDocDetailConsultation(box, doc, workSiblings, docCollections, canEdit, text, originalText, media = []) {
  // A video with its link, or a reading, has no PDF to open.
  const noPdf = doc.media_type === 'AUD' || (doc.media_type === 'VID' && doc.external_url);
  const langOf = m => esc(labelOf(State.langs, m.language) || '?');
  const ownReading = media.find(m => m.media_type === 'AUD' && String(m.document_id) === String(doc.document_id));
  // A version of a reserved document would have to be reserved too, and only Admin and Formation can add those.
  const canAddRelated = canWrite() && !HIDDEN_DOC_STATUSES.includes(doc.workflow_status) && (doc.access_level !== 'reserved' || canManageReserved());
  box.innerHTML = `
    <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 8px;">
      <h3 style="margin:0;">Document #${esc(doc.document_id)}</h3>
      <div class="btn-row" style="margin:0;">
        ${canEdit ? '<button class="btn secondary" id="doc-open-editor">Edit</button>' : ''}
        <button class="btn secondary" id="doc-fav">${favLabel(doc.document_id)}</button>
        ${State.myBoards.size > 0 && isDocPostable(doc) ? '<button class="btn secondary" id="doc-add-board">+ Board</button>' : ''}
        ${(State.isFormatore || canReviewApplications()) && isDocPostable(doc) ? '<button class="btn secondary" id="doc-add-path">+ Path</button>' : ''}
        ${noPdf ? '' : '<button class="btn" id="doc-download-gdrive" style="white-space:nowrap;">Open PDF</button>'}
      </div>
    </div>
    <div class="btn-row" style="margin:0 0 8px;">
      ${media.map((m, i) => m === ownReading ? '' : m.media_type === 'VID'
        ? videoLinkHtml(m.external_url, `Watch video (${labelOf(State.langs, m.language) || '?'})`)
        : `<button class="btn doc-listen" data-i="${i}" style="flex:0 0 auto;white-space:nowrap;">&#128266; Listen (${langOf(m)})</button>`).join('')}
      ${text ? '<button class="btn" id="doc-text-read" style="flex:0 0 auto;white-space:nowrap;">Read (large print)</button>' : ''}
      ${text ? '<button class="btn secondary" id="doc-text-open" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">Open editable text</button>' : ''}
      ${originalText ? '<button class="btn secondary" id="doc-original-text-open" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">Original text (Italian)</button>' : ''}
      <span id="doc-read-aloud" style="display:contents;"></span>
      ${canAddRelated ? '<button class="btn secondary" id="doc-add-related" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">+ Add a related version</button>' : ''}
      ${canWrite() ? '<button class="btn secondary" id="doc-translate" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">Translate</button>' : ''}
      ${isAdmin() && ownReading ? '<button class="btn secondary" id="doc-reader-name" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">Correct the name</button><button class="btn danger" id="doc-erase-reading" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">Erase the recording</button>' : ''}
      <button class="btn secondary" id="doc-report-problem" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">Report a problem</button>
    </div>
    <div id="doc-media-player"></div>
    ${media.some(m => m.media_type === 'AUD' && String(m.source_document_id) === String(doc.document_id) && m.source_text_at && text?.updated_at > m.source_text_at) ? '<div class="hint">The text has been corrected since it was read aloud, so the two may differ.</div>' : ''}
    <div class="field" style="font-size:13px;line-height:1.7;">
      <div style="font-weight:600;font-size:14px;margin-bottom:2px;">${esc(doc.en_title) || '<span class="hint">(no title)</span>'}</div>
      ${doc.ur_title ? `<div dir="auto" style="font-size:14px;margin-bottom:6px;">${esc(doc.ur_title)}</div>` : ''}
      ${renderDocSummary(doc)}
      ${doc.contained_in_document_id ? `<div>In the magazine issue <a href="#" id="doc-contained-in">#${esc(doc.contained_in_document_id)}</a>${doc.contained_page ? `, page ${esc(doc.contained_page)}` : ''}</div>` : ''}
      <div id="doc-contains"></div>
    </div>
    <div class="field">
      <label>Recipient(s)</label>
      <div style="font-size:13px;padding:4px 0;">${(doc.recipient || []).map(c => esc(labelOf(State.recipients, c))).join(', ') || '—'}</div>
    </div>
    <div class="field">
      <label>Collections</label>
      <div style="font-size:13px;padding:4px 0;">${renderCollectionsSummary(docCollections)}</div>
    </div>
    ${renderDocTextBox(text)}
    ${renderWorkSiblingsHtml(workSiblings, doc.document_id, false)}
    ${doc.storage_path ? `<div class="field"><label>File</label><a href="#" id="doc-download">Download</a></div>` : ''}
    ${canEdit ? renderDocTasksBox(doc) : ''}
  `;
  document.getElementById('doc-download-gdrive')?.addEventListener('click', () => downloadFromGDrive(doc.file_name));
  document.getElementById('doc-contained-in')?.addEventListener('click', async e => {
    e.preventDefault();
    State.selectedDocId = doc.contained_in_document_id;
    await renderDocDetail(doc.contained_in_document_id);
  });
  // What a magazine issue holds. Asked only for an issue: other documents contain nothing.
  if (labelOf(State.categories, doc.category) === 'Magazine issue') {
    sb.from('documents').select('document_id,title,en_title,contained_page').eq('contained_in_document_id', doc.document_id).order('contained_page').then(({ data }) => {
      const slot = document.getElementById('doc-contains');
      if (!slot || !data || !data.length) return;
      slot.innerHTML = `<div style="margin-top:4px;"><b>In this issue:</b></div>${data.map(d => `<div><a href="#" data-contained="${esc(d.document_id)}" dir="auto">${esc(d.en_title || d.title)}</a>${d.contained_page ? ` <span class="hint">p. ${esc(d.contained_page)}</span>` : ''}</div>`).join('')}`;
      slot.querySelectorAll('[data-contained]').forEach(a => a.addEventListener('click', async e => {
        e.preventDefault();
        State.selectedDocId = a.dataset.contained;
        await renderDocDetail(a.dataset.contained);
      }));
    }, () => {});
  }
  const mediaPlayer = document.getElementById('doc-media-player');
  box.querySelectorAll('.doc-listen').forEach(btn => btn.addEventListener('click', () => mountAudioPlayer(mediaPlayer, media[parseInt(btn.dataset.i, 10)], true)));
  if (ownReading) mountAudioPlayer(mediaPlayer, ownReading, false);
  // Offered only where it can really start: the database decides, and most texts simply don't show it.
  if (text && (!doc.media_type || doc.media_type === 'DOC')) {
    sb.rpc('reading_state', { p_document_id: doc.document_id }).then(({ data }) => {
      const slot = document.getElementById('doc-read-aloud');
      if (!slot || !data || !['available', 'mine', 'rerecord'].includes(data.state)) return;
      slot.innerHTML = `<button class="btn secondary" id="doc-read-aloud-btn" style="flex:0 0 auto;white-space:nowrap;font-size:12.5px;padding:5px 10px;">&#127908; ${data.state === 'rerecord' ? 'Record again' : 'Read aloud'}</button>`;
      document.getElementById('doc-read-aloud-btn').addEventListener('click', () => {
        State.readingTarget = doc.document_id;
        window.__renderTab('readings');
      });
    }, () => {});
  }
  document.getElementById('doc-add-related')?.addEventListener('click', () => addRelatedVersion(doc, workSiblings).catch(e => alert(e.message)));
  document.getElementById('doc-reader-name')?.addEventListener('click', async () => {
    const name = prompt('The name to show next to this recording:', ownReading.reader_name || '');
    if (name === null) return;
    await withStatus(sb.rpc('set_reading_reader', { p_document_id: doc.document_id, p_name: name }), 'Saving...');
    await renderDocDetail(doc.document_id);
  });
  document.getElementById('doc-erase-reading')?.addEventListener('click', async () => {
    const reason = prompt('Why is this recording being erased? It disappears at once and the file cannot be recovered.');
    if (reason === null) return;
    await withStatus(sb.rpc('erase_reading', { p_document_id: doc.document_id, p_reason: reason }), 'Erasing...');
    await eraseMyAudioFiles();
    State.selectedDocId = null;
    await onAfterDocChange();
    await renderDocDetail(null);
  });
  const textToggle = document.getElementById('doc-text-toggle');
  if (textToggle) textToggle.addEventListener('click', () => {
    const body = document.getElementById('doc-text-body');
    const isOpen = body.style.display !== 'none';
    body.style.display = isOpen ? 'none' : 'block';
    textToggle.textContent = isOpen ? 'Show' : 'Hide';
  });
  const textRead = document.getElementById('doc-text-read');
  if (textRead) textRead.addEventListener('click', () => openReadingView(doc, text));
  const textOpen = document.getElementById('doc-text-open');
  if (textOpen) textOpen.addEventListener('click', () => openDocTextPopup(doc, text));
  const originalTextOpen = document.getElementById('doc-original-text-open');
  if (originalTextOpen) originalTextOpen.addEventListener('click', () => openOriginalTextPopup(doc, originalText));
  // Prefill only with Italian source text: on an Urdu record `text` is the Urdu body, and
  // prefilling it would ask for a translation of a translation. Since migration 103 the Italian
  // originals are records of their own (language 'ITA', body in document_texts), so on one of
  // those `text` IS the source; the document_original_texts sidecar (migration 101) still covers a
  // true original with no record of its own. Otherwise an empty field, the user pastes.
  const translateBtn = document.getElementById('doc-translate');
  if (translateBtn) {
    const source = doc.language === 'ITA' && text ? text.body : (originalText ? originalText.body : '');
    translateBtn.addEventListener('click', () => openTranslatePopup({ text: source, title: doc.en_title || '' }));
  }
  document.getElementById('doc-report-problem').addEventListener('click', () => {
    State.selectedDocId = doc.document_id;
    State.chatMessagePrefill = null;
    window.__renderTab('chat');
  });
  document.getElementById('doc-fav').addEventListener('click', async () => {
    const btn = document.getElementById('doc-fav');
    const { data: { user } } = await sb.auth.getUser();
    if (State.myFavorites.has(doc.document_id)) {
      await withStatus(sb.from('user_favorites').delete().eq('user_id', user.id).eq('document_id', doc.document_id));
      State.myFavorites.delete(doc.document_id);
    } else {
      await withStatus(sb.from('user_favorites').insert({ user_id: user.id, document_id: doc.document_id }));
      State.myFavorites.add(doc.document_id);
    }
    btn.textContent = favLabel(doc.document_id);
  });
  if (State.myBoards.size > 0 && isDocPostable(doc)) {
    document.getElementById('doc-add-board').addEventListener('click', () => openBoardPostPopup({ doc, onSaved: () => {} }));
  }
  if ((State.isFormatore || canReviewApplications()) && isDocPostable(doc)) {
    document.getElementById('doc-add-path').addEventListener('click', () => openFormationPostPopup({ doc, onSaved: () => {} }));
  }
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
      const rows = await withStatus(sb.from('documents').select('file_name,media_type,external_url').eq('document_id', tr.dataset.siblingId));
      const sibling = rows[0];
      if (sibling?.media_type === 'AUD') { await navigate(tr.dataset.siblingId); return; }
      if (sibling?.media_type === 'VID' && sibling.external_url) { window.open(sibling.external_url, '_blank', 'noopener'); return; }
      downloadFromGDrive(sibling?.file_name);
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
  return await withStatus(sb.from('documents').select('document_id,title,category,author,language,source,media_type,file_name,is_preferred,storage_path,external_url,workflow_status').eq('work_id', workId));
}

// The video links and readings to offer on this document: from its whole Work, one for each language
// and format. The record open now comes first, then the starred one, so a newer reading takes over
// from an older one without deleting it, and an older one can still be opened and heard.
async function fetchDocMedia(doc, siblings) {
  const isCurrent = d => String(d.document_id) === String(doc.document_id);
  const candidates = [doc, ...(siblings || []).filter(s => !isCurrent(s))]
    .filter(d => (d.media_type === 'AUD' || (d.media_type === 'VID' && d.external_url))
      && (isCurrent(d) || !HIDDEN_DOC_STATUSES.includes(d.workflow_status)))
    .sort((a, b) => (isCurrent(b) - isCurrent(a)) || (!!b.is_preferred - !!a.is_preferred));
  const picked = new Map();
  candidates.forEach(d => { const key = `${d.language}|${d.media_type}`; if (!picked.has(key)) picked.set(key, d); });
  const list = [...picked.values()];
  const audioIds = list.filter(d => d.media_type === 'AUD').map(d => d.document_id);
  if (!audioIds.length) return list;
  const readings = await withStatus(sb.from('audio_readings').select('document_id,path,reader_name,source_document_id,source_text_at').in('document_id', audioIds));
  const byDoc = new Map(readings.map(r => [String(r.document_id), r]));
  return list
    .map(d => (d.media_type === 'AUD' ? { ...d, ...byDoc.get(String(d.document_id)) } : d))
    .filter(d => d.media_type !== 'AUD' || d.path);
}

// Downloads a specific version, preferring the app-managed Storage copy (signed URL) over the
// Google Drive lookup-by-name fallback - same precedence the single-document download already uses.
async function downloadVersion(v) {
  if (v.media_type === 'VID' && v.external_url) { window.open(v.external_url, '_blank', 'noopener'); return; }
  if (v.media_type === 'AUD') {
    const rows = await withStatus(sb.from('audio_readings').select('path').eq('document_id', v.document_id));
    if (rows[0]?.path) window.open(await audioFileUrl(rows[0].path), '_blank', 'noopener');
    return;
  }
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
        const kind = v.media_type === 'VID' ? ' video' : v.media_type === 'AUD' ? ' audio' : '';
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
  const media = await fetchDocMedia(doc, siblings);
  const docCollections = await getCollectionsForDocument(doc.document_id);
  const textRows = await withStatus(sb.from('document_texts').select('body,char_count,reviewed,updated_at').eq('document_id', doc.document_id));
  const text = textRows[0] || null;
  // Original-language text (migration 101) - Italian for now, see docdetail.js's
  // openOriginalTextPopup. Absent for the vast majority of documents until the owner's Google
  // Drive import runs; the button in renderDocDetailConsultation only appears when present.
  const originalTextRows = await withStatus(sb.from('document_original_texts').select('language,body,reviewed').eq('document_id', doc.document_id));
  const originalText = originalTextRows[0] || null;

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
  renderDocDetailConsultation(box, doc, siblings, docCollections, canEdit, text, originalText, media);
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
      ${selectField('Access level', 'access_level', doc.access_level, ACCESS_LEVELS.filter(([code]) => code !== 'reserved' || canManageReserved() || doc.access_level === 'reserved'))}
      ${textField('Reference period', 'ref_period', doc.ref_period)}
      ${selectField('Media type', 'media_type', doc.media_type, State.mediaTypes.filter(([code]) => code !== 'AUD' || doc.media_type === 'AUD'))}
      ${selectField('Source', 'source', doc.source, State.sources)}
      ${selectField('Operator', 'operator', doc.operator, State.operators)}
      ${textField('Episode number', 'episode_number', doc.episode_number)}
      ${textField('Bible verse', 'bible_verse', doc.bible_verse)}
      ${textField('Contained in magazine issue (its number)', 'contained_in_document_id', doc.contained_in_document_id, 'number')}
      ${textField('Page in that issue', 'contained_page', doc.contained_page, 'number')}
      <div class="field"><label>Pages</label>
        <div class="btn-row" style="margin:0;gap:6px;">
          <input data-f="pages" type="number" value="${esc(doc.pages)}">
          <button type="button" class="btn secondary" id="doc-read-pages" style="padding:6px 10px;white-space:nowrap;">Read from file</button>
        </div>
        <div class="hint" id="doc-read-pages-status"></div>
      </div>
      <div class="field"><label>File name</label><input value="${esc(doc.file_name)}" disabled></div>
      ${textField('Duration (video or audio)', 'duration', doc.duration)}
      ${textField('Video link (YouTube or Google Drive)', 'external_url', doc.external_url)}
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
      ${canDelete() ? '<button class="btn danger" id="doc-delete">Delete</button>' : ''}
    </div>
    ${renderProcessHistorySection(doc)}
    ${renderChangeHistorySection()}
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
  wireChangeHistorySection(id);
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
    if (vals.media_type !== 'VID') vals.external_url = null;
    if (vals.external_url && !isMediaLinkOk(vals.external_url)) { alert('A video link must be an https link to YouTube or Google Drive.'); return; }
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
      // Auto-read the page count straight off the picked file - same technique as Bulk Import,
      // and avoids the Google Drive alt=media CORS wall entirely (see 2026-09-02 session notes)
      // since it never needs to fetch the file back from anywhere. Only overwrites what's in
      // the form if the read actually succeeds, so a manual entry the person already typed
      // (or a "Read from file" result on the OLD file) isn't clobbered by a read failure.
      const readPagesStatus = document.getElementById('doc-read-pages-status');
      const readPages = await readPdfPageCountFromBlob(fileInput.files[0]);
      if (readPages != null) {
        vals.pages = readPages;
        box.querySelector('[data-f="pages"]').value = readPages;
        readPagesStatus.textContent = `Read ${readPages} page${readPages === 1 ? '' : 's'} from the uploaded file.`;
      } else {
        readPagesStatus.textContent = 'Could not read the page count from the uploaded file automatically - enter it by hand if needed.';
      }
      await withStatus(sb.storage.from(BUCKET).upload(finalName, fileInput.files[0], { upsert: true }), 'Uploading file...');
      storagePath = finalName;
      vals.file_name = finalName;
    } else if (!doc.file_name && !['VID', 'AUD'].includes(vals.media_type)) {
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
    const reason = prompt(`Why are you deleting document #${id}? It leaves the archive, but nothing is erased: Admin can restore it from My Department -> Archive & Data.`);
    if (reason === null) return;
    if (!reason.trim()) { alert('Please enter a reason.'); return; }
    await withStatus(sb.rpc('soft_delete_document', { p_document_id: parseInt(id, 10), p_reason: reason.trim() }), 'Deleting...');
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

// ---------- Change history: written by the database, nobody can edit it ----------

function renderChangeHistorySection() {
  if (!isCoordinator() && !isAdmin()) return '';
  return `
    <details class="panel" id="doc-change-history" style="margin-top:14px;">
      <summary style="cursor:pointer;font-weight:600;">Change history</summary>
      <div id="doc-change-history-body" style="margin-top:8px;"><div class="hint">Loading...</div></div>
    </details>`;
}

function wireChangeHistorySection(documentId) {
  const box = document.getElementById('doc-change-history');
  if (!box) return;
  box.addEventListener('toggle', async () => {
    if (!box.open) return;
    const rows = await withStatus(sb.rpc('get_document_history', { p_document_id: parseInt(documentId, 10) }));
    document.getElementById('doc-change-history-body').innerHTML = logEntriesHtml(rows, true);
  });
}

// ---------- New document ----------

export async function createNewDocument(afterCreate) {
  const newId = await nextDocumentId();
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
      <h2>Digital Urdu Archive - Document Tracking Sheet</h2>
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
