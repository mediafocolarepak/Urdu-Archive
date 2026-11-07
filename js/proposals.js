// Proposals: the one door for new content (112_proposals.sql, Documentazione\PROTOCOLLO_Ingresso_
// archivio_v1.md §6-7). A team member fills in the form; a Revisor or Coordinator approves, and that
// alone publishes. Everything goes through server functions, in one transaction: this module only
// collects and shows, and the database is the real gate.

import {
  sb, State, esc, withStatus, optionsHtml, labelOf, isAdmin, isCoordinator, canManageReserved, canWrite, BUCKET, likeSafe,
  titleOverlapScore, ACCESS_LEVELS, readPdfPageCountFromBlob, getDriveAccessToken, uploadPdfToGDrive,
  AUDIO_BUCKET, AUDIO_FORMATS, audioFileProblem, audioDurationOf, HIDDEN_DOC_STATUSES, isMediaLinkOk, videoLinkHtml, mountAudioPlayer,
  helpLinkHtml,
} from './core.js?v=20261107205757';

const MAX_FILE_BYTES = 50 * 1024 * 1024; // the Supabase Free plan's limit per file
const FORMATS = [['DOC', 'Text or PDF'], ['AUD', 'Audio'], ['VID', 'Video']];
const STATUS_LABELS = {
  draft: 'Draft',
  submitted: 'Awaiting review',
  to_correct: 'To correct',
  published: 'Published',
  rejected: 'Rejected',
};
const EVENT_LABELS = {
  created: 'Created', submitted: 'Sent for review', resubmitted: 'Sent again after correcting',
  withdrawn: 'Taken back', discarded: 'Discarded', reminder: 'Reminder sent', claimed: 'A reviewer took it',
  released: 'A reviewer released it', sent_back: 'Sent back to correct', published: 'Published', rejected: 'Rejected',
};

// Reads the text out of a Word file. Loaded only when someone uses it: it is 630 KB, too much to
// make every phone download at sign-in. The version is pinned and its checksum verified.
const MAMMOTH_URL = 'https://cdn.jsdelivr.net/npm/mammoth@1.8.0/mammoth.browser.min.js';
const MAMMOTH_INTEGRITY = 'sha384-/cXAMbzovUIKbBERjPmR3SnPTh8siWr5lsvFYj1Uq4XP0yaJUZJmsh0YXyGv5P0y';
const MAX_WORD_BYTES = 20 * 1024 * 1024;

let currentTab = 'mine';

const dateOf = iso => (iso || '').slice(0, 10);
const scrollTop = () => { document.getElementById('main').scrollTop = 0; };

// sb.rpc through withStatus throws on any refusal; every action here shows the server's own message.
async function act(fn) {
  try { await fn(); return true; }
  catch (e) { alert(e.message); return false; }
}

let mammothLoading = null;
function loadMammoth() {
  if (window.mammoth) return Promise.resolve(window.mammoth);
  if (!mammothLoading) {
    mammothLoading = new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = MAMMOTH_URL;
      script.integrity = MAMMOTH_INTEGRITY;
      script.crossOrigin = 'anonymous';
      script.onload = () => resolve(window.mammoth);
      script.onerror = () => {
        mammothLoading = null;
        reject(new Error('Could not load the Word reader. Please check the connection and try again.'));
      };
      document.head.appendChild(script);
    });
  }
  return mammothLoading;
}

// The text only: layout and images stay out, and the file itself is not kept.
async function textFromWord(file) {
  if (file.size > MAX_WORD_BYTES) throw new Error(`"${file.name}" is larger than 20 MB.`);
  const reader = await loadMammoth();
  let result;
  try {
    result = await reader.extractRawText({ arrayBuffer: await file.arrayBuffer() });
  } catch {
    throw new Error('This file cannot be read. Only .docx files work: open an older .doc in Word and save it as .docx.');
  }
  const text = result.value.replace(/\r\n/g, '\n').replace(/\n{3,}/g, '\n\n').trim();
  if (!text) throw new Error('No text found in this file. It may contain only images: if so, paste the text by hand.');
  return text;
}

// ---------- The section ----------

export async function renderProposalsView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  // Coming from a board post, already filled in.
  if (State.proposalPrefill) {
    const prefill = State.proposalPrefill;
    State.proposalPrefill = null;
    currentTab = 'mine';
    await renderForm(main, null, prefill);
    return;
  }
  const canReview = await withStatus(sb.rpc('can_review_submissions'));
  const tabs = [['mine', 'My proposals'], ['month', 'Word of Life']];
  if (canReview) tabs.push(['queue', 'To review']);
  if (isAdmin()) tabs.push(['drive', 'Files for Drive']);
  if (!tabs.some(([id]) => id === currentTab)) currentTab = 'mine';
  main.innerHTML = `
    <div class="panel">
      <h2>Proposals ${helpLinkHtml('propose')}</h2>
      <p class="hint">New content reaches the archive through a shared review: nobody publishes alone. Boards are separate, and what is posted there is not in the archive.</p>
      ${tabs.length > 1 ? `<div class="btn-row">${tabs.map(([id, label]) => `<button class="btn ${id === currentTab ? '' : 'secondary'}" data-prop-tab="${id}">${esc(label)}</button>`).join('')}</div>` : ''}
    </div>
    <div id="prop-body"></div>`;
  main.querySelectorAll('[data-prop-tab]').forEach(b => b.addEventListener('click', () => {
    currentTab = b.dataset.propTab;
    renderProposalsView(main);
  }));
  const body = document.getElementById('prop-body');
  if (currentTab === 'queue') await renderQueue(main, body);
  else if (currentTab === 'month') await renderMonth(main, body);
  else if (currentTab === 'drive') await renderDriveList(body);
  else await renderMine(main, body);
  refreshProposalsBadge();
}

// ---------- My proposals ----------

function mineStateHtml(r) {
  if (r.status === 'submitted') {
    const wait = r.days_waiting === 0 ? 'since today' : `for ${r.days_waiting} day${r.days_waiting === 1 ? '' : 's'}`;
    return `Awaiting review ${wait}${r.in_review ? ' &middot; a reviewer is working on it' : ''}`;
  }
  return esc(STATUS_LABELS[r.status] || r.status);
}

async function renderMine(main, body) {
  const rows = await withStatus(sb.rpc('get_my_submissions'));
  body.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="margin-top:0;"><button class="btn" id="prop-new">+ New proposal</button></div>
      ${rows.length ? rows.map(r => `
        <div class="subpanel" data-id="${esc(r.id)}" style="margin-top:12px;">
          <div style="font-weight:600;" dir="auto">${esc(r.title) || '<span class="hint">(no title yet)</span>'}</div>
          <div class="hint">${mineStateHtml(r)} &middot; ${esc(r.version_count)} version${r.version_count === 1 ? '' : 's'}</div>
          ${r.decision_note ? `<p style="white-space:pre-wrap;margin:6px 0;" dir="auto"><b>Reviewer's note:</b> ${esc(r.decision_note)}</p>` : ''}
          <div class="btn-row">
            ${['draft', 'to_correct'].includes(r.status) ? '<button class="btn prop-edit">Edit</button><button class="btn danger prop-discard">Discard</button>' : '<button class="btn secondary prop-open">Open</button>'}
            ${r.status === 'submitted' && !r.in_review ? '<button class="btn secondary prop-withdraw">Take back to edit</button>' : ''}
            ${r.status === 'submitted' ? `<button class="btn secondary prop-remind" ${r.reminder_allowed ? '' : 'disabled'}>Send a reminder</button>` : ''}
          </div>
          ${r.status === 'submitted' && !r.reminder_allowed ? `<div class="hint">A reminder can be sent from ${esc(dateOf(r.next_reminder_at))}.</div>` : ''}
        </div>`).join('') : '<div class="empty-msg" style="margin-top:12px;">No proposals yet.</div>'}
    </div>`;
  document.getElementById('prop-new').addEventListener('click', () => renderForm(main, null));
  body.querySelectorAll('[data-id]').forEach(card => {
    const id = parseInt(card.dataset.id, 10);
    card.querySelector('.prop-edit')?.addEventListener('click', () => renderForm(main, id));
    card.querySelector('.prop-open')?.addEventListener('click', () => renderDetail(main, id));
    card.querySelector('.prop-discard')?.addEventListener('click', async () => {
      if (!confirm('Discard this proposal?')) return;
      if (await act(() => withStatus(sb.rpc('discard_submission', { p_id: id }), 'Discarding...'))) renderProposalsView(main);
    });
    card.querySelector('.prop-withdraw')?.addEventListener('click', async () => {
      if (await act(() => withStatus(sb.rpc('withdraw_submission', { p_id: id }), 'Taking back...'))) renderProposalsView(main);
    });
    card.querySelector('.prop-remind')?.addEventListener('click', async () => {
      if (await act(() => withStatus(sb.rpc('send_submission_reminder', { p_id: id }), 'Sending...'))) {
        alert('Reminder sent: it now stands out for everyone who reviews proposals.');
        renderProposalsView(main);
      }
    });
  });
}

// ---------- The Word of Life of a month: one package ----------

const MONTH_SLOTS = [
  { key: 'ITA', label: 'Italian', language: 'ITA', media: 'DOC' },
  { key: 'ENG', label: 'English', language: 'ENG', media: 'DOC' },
  { key: 'URD', label: 'Urdu', language: 'URD', media: 'DOC' },
  { key: 'VID', label: 'Video', language: 'URD', media: 'VID' },
  { key: 'AUD', label: 'Audio', language: 'URD', media: 'AUD' },
];
const MONTH_STATES = { draft: 'Being prepared', submitted: 'Awaiting review', to_correct: 'To correct', rejected: 'Not accepted' };
const TASK_STATES = { open: 'open', claimed: 'being worked on', submitted: 'being reviewed', approved: 'approved' };
const TRANSLATION_TASKS = ['IT_UR', 'EN_UR'];
let monthPeriod = null;

const thisMonth = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
};
const monthName = period => {
  const [y, m] = period.split('-').map(Number);
  return new Date(y, m - 1, 1).toLocaleDateString('en', { month: 'long', year: 'numeric' });
};
const versionState = v => {
  if (v.submission_status && v.workflow_status === 'proposed') return MONTH_STATES[v.submission_status] || v.submission_status;
  if (['revision', 'pending_publish'].includes(v.workflow_status)) return 'Being worked on, through a task';
  return 'In the archive';
};

async function renderMonth(main, body) {
  monthPeriod = monthPeriod || thisMonth();
  const d = await withStatus(sb.rpc('get_word_of_life_month', { p_period: monthPeriod }));
  const inSlot = slot => d.versions.filter(v => v.media_type === slot.media && (slot.media !== 'DOC' || v.language === slot.language));
  const translationTasks = d.tasks.filter(t => TRANSLATION_TASKS.includes(t.category));
  const filled = slot => inSlot(slot).length > 0 || (slot.key === 'URD' && translationTasks.length > 0);
  const missing = MONTH_SLOTS.filter(slot => !filled(slot));
  const canLink = isCoordinator() || isAdmin();
  // A translation is worked on from its source text.
  const source = d.versions.find(v => v.language === 'ITA' && v.media_type === 'DOC') || d.versions.find(v => v.language === 'ENG' && v.media_type === 'DOC');

  body.innerHTML = `
    <div class="panel">
      <div class="field" style="max-width:220px;"><label>Month</label><input id="pm-month" type="month" value="${esc(monthPeriod)}"></div>
      <p class="hint" style="margin-top:0;">Everything for ${esc(monthName(monthPeriod))} in one place. The month is the Word of Life's own, not the magazine's. A piece that comes late is simply added later.</p>
      ${MONTH_SLOTS.map(slot => {
        const here = inSlot(slot);
        return `<div class="btn-row" data-slot="${slot.key}" style="justify-content:space-between;align-items:center;border-top:1px solid var(--line);padding:8px 0;margin:0;">
          <div style="min-width:0;flex:1 1 200px;">
            <b>${esc(slot.label)}</b>
            ${here.map(v => `<div class="hint"><a href="#" data-open-doc="${esc(v.document_id)}" dir="auto">${esc(v.title) || '#' + esc(v.document_id)}</a> &middot; ${esc(versionState(v))}${slot.media === 'DOC' ? '' : ` &middot; ${esc(labelOf(State.langs, v.language))}`}${v.in_series ? '' : ' &middot; not linked to this month yet'}</div>`).join('')}
            ${slot.key === 'URD' ? translationTasks.map(t => `<div class="hint">Task #${esc(t.id)}, translation: ${esc(TASK_STATES[t.status] || t.status)}</div>`).join('') : ''}
            ${filled(slot) ? '' : '<div class="hint">Missing</div>'}
          </div>
          <div class="btn-row" style="margin:0;">
            ${here.filter(v => !v.in_series && canLink).map(v => `<button class="btn secondary pm-link" data-doc="${esc(v.document_id)}" style="padding:3px 10px;white-space:nowrap;">Link to this month</button>`).join('')}
            ${filled(slot) ? '' : `<button class="btn secondary pm-add" style="padding:3px 10px;white-space:nowrap;">+ Add</button>`}
            ${slot.key === 'URD' && !filled(slot) && source && canLink ? `<button class="btn secondary pm-task" style="padding:3px 10px;white-space:nowrap;">Create a translation task</button>` : ''}
          </div>
        </div>`;
      }).join('')}
      ${missing.length > 1 ? '<div class="btn-row"><button class="btn" id="pm-add-all">Propose everything missing together</button></div>' : ''}
    </div>`;

  document.getElementById('pm-month').addEventListener('change', e => {
    if (!e.target.value) return;
    monthPeriod = e.target.value;
    renderMonth(main, body);
  });
  const open = async slots => {
    let workId;
    if (!await act(async () => { workId = await withStatus(sb.rpc('ensure_word_of_life_month', { p_period: monthPeriod }), 'Preparing the month...'); })) return;
    const known = d.versions.find(v => v.en_title) || {};
    const anyAuthor = d.versions.find(v => v.author);
    await renderForm(main, null, {
      workId,
      workLabel: `Word of Life, ${monthName(monthPeriod)}`,
      common: { en_title: known.en_title || `Word of Life, ${monthName(monthPeriod)}`, category: d.category || '', author: anyAuthor?.author || '', ref_period: monthPeriod },
      versions: slots.map(slot => ({ language: slot.language, media_type: slot.media })),
    });
  };
  body.querySelectorAll('[data-slot]').forEach(row => {
    const slot = MONTH_SLOTS.find(s => s.key === row.dataset.slot);
    row.querySelector('.pm-add')?.addEventListener('click', () => open([slot]));
    row.querySelector('.pm-task')?.addEventListener('click', () => {
      State.selectedDocId = source.document_id;
      State.dashOpenDetail = true;
      window.__renderTab('dashboard');
    });
  });
  document.getElementById('pm-add-all')?.addEventListener('click', () => open(missing));
  body.querySelectorAll('[data-open-doc]').forEach(a => a.addEventListener('click', e => {
    e.preventDefault();
    State.selectedDocId = a.dataset.openDoc;
    State.dashOpenDetail = true;
    window.__renderTab('dashboard');
  }));
  body.querySelectorAll('.pm-link').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm('Link this document, and any versions already linked to it, to this month?')) return;
    if (await act(() => withStatus(sb.rpc('link_document_to_month', { p_document_id: parseInt(btn.dataset.doc, 10), p_period: monthPeriod }), 'Linking...'))) renderMonth(main, body);
  }));
}

// ---------- The form ----------

let form = null;

function emptyVersion(language) {
  return {
    document_id: null, language: language || '', original_title: '', body: '', draft_path: null, pages: null, access_level: 'private', file: null,
    media_type: 'DOC', external_url: '', duration: '', audio_path: null, audio_mime: null, audio_size: null, reader_name: '', audioFile: null,
  };
}

const FORMAT_WORDS = { VID: 'video', AUD: 'audio' };
function versionsSummary(existing) {
  if (!existing || !existing.length) return '';
  const words = existing.map(v => labelOf(State.langs, v.language) + (FORMAT_WORDS[v.media_type] ? ` ${FORMAT_WORDS[v.media_type]}` : ''));
  return ` Already in the archive: ${esc([...new Set(words)].join(', '))}.`;
}

// prefill: what another screen already knows (a month's package, a board post, a related document). Nothing
// is saved until the person saves.
async function renderForm(main, id, prefill) {
  form = { id, work_id: null, newWork: false, workLabel: '', common: {}, versions: [emptyVersion('URD')], decisionNote: null, status: 'draft' };
  if (prefill) {
    form.work_id = prefill.workId || null;
    form.workLabel = prefill.workLabel || '';
    form.common = { ...prefill.common };
    form.versions = prefill.versions.map(v => ({ ...emptyVersion(v.language), ...v }));
    form.requestId = prefill.requestId || null;
    form.existing = prefill.existing || null;
  }
  if (id) {
    const d = await withStatus(sb.rpc('get_submission_detail', { p_id: id }));
    form.work_id = d.work_id;
    form.common = d.common || {};
    form.decisionNote = d.decision_note;
    form.status = d.status;
    form.versions = d.versions.length ? d.versions.map(v => ({ ...v, body: v.body || '', file: null, audioFile: null })) : [emptyVersion('URD')];
    if (d.work_documents.length) form.workLabel = d.work_documents.map(w => w.title).filter(Boolean)[0] || `Work #${d.work_id}`;
    form.existing = d.work_documents.map(w => ({ language: w.language, media_type: 'DOC' }));
  }
  scrollTop();
  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 8px;">
        <h2 style="margin:0;">${id ? 'Edit proposal' : 'New proposal'}</h2>
        <button class="btn secondary" id="pf-back">Back</button>
      </div>
      <p class="hint">Proposing earns no credits by itself. If you would like a compensation, agree with the team first: they will create a task for it.</p>
      ${prefill?.note ? `<p class="hint">${esc(prefill.note)}${(prefill.links || []).map(([label, url]) => ` <a href="${esc(url)}" target="_blank" rel="noopener noreferrer">${esc(label)}</a>.`).join('')}</p>` : ''}
      ${form.decisionNote ? `<p style="white-space:pre-wrap;" dir="auto"><b>Reviewer's note:</b> ${esc(form.decisionNote)}</p>` : ''}
      <div class="subpanel">
        ${form.common.related_to_document_id ? `
        <h3>1. A new version of a document in the archive</h3>
        <p style="margin-bottom:4px;">Related to <b dir="auto">${esc(form.workLabel)}</b> <span class="hint">#${esc(form.common.related_to_document_id)}</span></p>
        <p class="hint" style="margin-top:0;">What you add here stays linked to it, and each will show the other among its versions.${versionsSummary(form.existing)}</p>` : `
        <h3>1. Is it new, or does it already exist?</h3>
        <p class="hint">Look for it first. If the same text exists in another language or version, link this proposal to it. You decide: nothing is linked by itself.</p>
        <div class="searchbar"><input id="pf-search" dir="auto" placeholder="Search by title or by a phrase of the text..."></div>
        <div id="pf-search-results"></div>
        <div id="pf-work-choice" style="margin-top:8px;"></div>`}
      </div>
      <div class="subpanel" style="margin-top:14px;">
        <h3>2. What the versions share</h3>
        <div id="pf-common"></div>
      </div>
      <div class="subpanel" style="margin-top:14px;">
        <h3>3. Versions</h3>
        <p class="hint">One for each language and format. Adding the text, pasted or loaded from Word, is what makes it searchable: a PDF alone can be found only by its title and tags.</p>
        <div id="pf-versions"></div>
        <div class="btn-row"><button class="btn secondary" id="pf-add-version">+ Another language</button></div>
      </div>
      <div class="btn-row" style="margin-top:14px;">
        <button class="btn" id="pf-submit">Send for review</button>
        <button class="btn secondary" id="pf-save">Save draft</button>
        ${isAdmin() ? '<button class="btn secondary" id="pf-publish">Publish directly (Admin)</button>' : ''}
      </div>
      <div id="pf-status" class="hint"></div>
    </div>`;
  renderCommon();
  renderVersions();
  if (!form.common.related_to_document_id) {
    renderWorkChoice();
    wireSearch();
  }
  document.getElementById('pf-back').addEventListener('click', () => renderProposalsView(main));
  document.getElementById('pf-add-version').addEventListener('click', () => {
    collectForm();
    form.versions.push(emptyVersion(''));
    renderVersions();
  });
  document.getElementById('pf-save').addEventListener('click', async () => {
    if (await act(() => persist())) renderProposalsView(main);
  });
  document.getElementById('pf-submit').addEventListener('click', async () => {
    const ok = await act(async () => {
      await persist();
      await withStatus(sb.rpc('submit_submission', { p_id: form.id }), 'Sending...');
    });
    if (ok) { currentTab = 'mine'; renderProposalsView(main); }
  });
  document.getElementById('pf-publish')?.addEventListener('click', async () => {
    if (!confirm('Publish this directly, without review? It becomes visible at once, and your action is recorded.')) return;
    const ok = await act(async () => {
      await persist();
      await withStatus(sb.rpc('approve_submission', { p_id: form.id, p_read_document_ids: null, p_note: null }), 'Publishing...');
    });
    if (ok) { currentTab = 'mine'; renderProposalsView(main); }
  });
  loadTagSuggestions();
}

function renderCommon() {
  const c = form.common;
  document.getElementById('pf-common').innerHTML = `
    <div class="field-grid wide">
      <div class="field"><label>Title in English *</label><input id="pf-en_title" value="${esc(c.en_title)}"></div>
      <div class="field"><label>Category *</label><select id="pf-category">${optionsHtml(State.categories, c.category, true)}</select></div>
      <div class="field"><label>Author *</label><select id="pf-author">${optionsHtml(State.authors, c.author, true)}</select></div>
      <div class="field"><label>Date *</label><input id="pf-ref_date" type="date" value="${esc(c.ref_date)}"></div>
      <div class="field"><label>or period (a Word of Life: its own month, such as 2026-12) *</label><input id="pf-ref_period" placeholder="2026-12" value="${esc(c.ref_period)}"></div>
      <div class="field"><label>Recipient <span class="hint">(optional)</span></label><select id="pf-recipient">${optionsHtml(State.recipients, c.recipient, true)}</select></div>
      <div class="field"><label>Main topic <span class="hint">(optional)</span></label><select id="pf-main_topic">${optionsHtml(State.mainTopics, c.main_topic, true)}</select></div>
      <div class="field"><label>Topic tags <span class="hint">(optional, separated by commas)</span></label><input id="pf-secondary_tags" list="pf-tag-list" dir="auto" value="${esc(c.secondary_tags)}"><datalist id="pf-tag-list"></datalist></div>
      <div class="field"><label>Bible verse <span class="hint">(optional)</span></label><input id="pf-bible_verse" dir="auto" value="${esc(c.bible_verse)}"></div>
      <div class="field"><label>Contained in a magazine issue <span class="hint">(optional: the issue's number in the archive)</span></label><input id="pf-contained" type="number" min="1" value="${esc(c.contained_in_document_id)}"></div>
      <div class="field"><label>Page in that issue <span class="hint">(optional)</span></label><input id="pf-contained-page" type="number" min="1" value="${esc(c.contained_page)}"></div>
    </div>`;
}

function renderVersions() {
  const levels = ACCESS_LEVELS.filter(([code]) => code !== 'reserved' || canManageReserved());
  const box = document.getElementById('pf-versions');
  box.innerHTML = form.versions.map((v, i) => `
    <div class="panel" data-version="${i}" style="margin-bottom:10px;">
      <div class="field-grid wide">
        <div class="field"><label>Language *</label><select class="pv-language">${optionsHtml(State.langs, v.language, true)}</select></div>
        <div class="field"><label>Title in this language *</label><input class="pv-title" dir="auto" value="${esc(v.original_title)}"></div>
        <div class="field"><label>Access level</label><select class="pv-level">${optionsHtml(levels, v.access_level, false)}</select></div>
        <div class="field"><label>Format</label><select class="pv-format">${optionsHtml(FORMATS, v.media_type || 'DOC', false)}</select></div>
      </div>
      <div class="pv-vid" style="display:${v.media_type === 'VID' ? 'block' : 'none'};">
        <div class="field"><label>Video link *</label><input class="pv-link" type="url" dir="ltr" placeholder="https://youtu.be/..." value="${esc(v.external_url)}">
          <div class="hint">YouTube or Google Drive. The video isn't stored here, so keep the original file on Drive too.</div></div>
        <div class="field"><label>Duration <span class="hint">(optional, such as 4 min)</span></label><input class="pv-duration" value="${esc(v.duration)}"></div>
      </div>
      <div class="pv-aud" style="display:${v.media_type === 'AUD' ? 'block' : 'none'};">
        <div class="field"><label>Read by *</label><input class="pv-reader" dir="auto" value="${esc(v.reader_name)}"><div class="hint">This name is shown next to the recording.</div></div>
        <div class="field"><label>Recording * ${v.audio_path ? '<span class="hint">(already attached; choose another to replace it)</span>' : ''}</label><input class="pv-audio" type="file" accept=".mp3,.m4a,.mp4,.aac,.ogg,.opus,.webm,audio/*">
          <div class="hint">MP3 or M4A plays on every phone. Up to 25 MB, which is about 50 minutes of voice.</div></div>
      </div>
      <div class="pv-doc" style="display:${!v.media_type || v.media_type === 'DOC' ? 'block' : 'none'};">
      <div class="field"><label>Text</label><textarea class="pv-body" dir="auto" rows="6">${esc(v.body)}</textarea></div>
      <div class="field"><label>Or load the text from Word <span class="hint">(.docx; the file itself is not kept)</span></label><input class="pv-word" type="file" accept=".docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document"><div class="hint pv-word-status"></div></div>
      <div class="field"><label>PDF file ${v.draft_path ? '<span class="hint">(already attached; choose another to replace it)</span>' : ''}</label><input class="pv-file" type="file" accept=".pdf"></div>
      </div>
      ${form.versions.length > 1 ? '<div class="btn-row"><button class="btn danger pv-remove" style="padding:4px 10px;">Remove this version</button></div>' : ''}
    </div>`).join('');
  box.querySelectorAll('[data-version]').forEach(card => {
    const i = parseInt(card.dataset.version, 10);
    card.querySelector('.pv-remove')?.addEventListener('click', () => {
      collectForm();
      form.versions.splice(i, 1);
      renderVersions();
    });
    card.querySelector('.pv-file').addEventListener('change', e => { form.versions[i].file = e.target.files[0] || null; });
    card.querySelector('.pv-format').addEventListener('change', e => {
      card.querySelector('.pv-doc').style.display = e.target.value === 'DOC' ? 'block' : 'none';
      card.querySelector('.pv-aud').style.display = e.target.value === 'AUD' ? 'block' : 'none';
      card.querySelector('.pv-vid').style.display = e.target.value === 'VID' ? 'block' : 'none';
    });
    card.querySelector('.pv-audio').addEventListener('change', e => {
      const file = e.target.files[0] || null;
      const problem = file && audioFileProblem(file);
      if (problem) { alert(problem); e.target.value = ''; form.versions[i].audioFile = null; return; }
      form.versions[i].audioFile = file;
    });
    card.querySelector('.pv-word').addEventListener('change', async e => {
      const file = e.target.files[0];
      e.target.value = '';
      if (!file) return;
      const body = card.querySelector('.pv-body');
      if (body.value.trim() && !confirm('Replace the text already in this box with the text of the file?')) return;
      const status = card.querySelector('.pv-word-status');
      status.textContent = 'Reading the file...';
      const ok = await act(async () => {
        body.value = await textFromWord(file);
        status.textContent = `Text loaded from "${file.name}". Please check it: layout and images are not carried over.`;
      });
      if (!ok) status.textContent = '';
    });
  });
}

function collectForm() {
  const val = id => document.getElementById(id).value;
  form.common = {
    en_title: val('pf-en_title'), category: val('pf-category'), author: val('pf-author'),
    ref_date: val('pf-ref_date'), ref_period: val('pf-ref_period'), recipient: val('pf-recipient'),
    main_topic: val('pf-main_topic'), secondary_tags: val('pf-secondary_tags'), bible_verse: val('pf-bible_verse'),
    contained_in_document_id: val('pf-contained'), contained_page: val('pf-contained-page'),
    // Not fields of the form: they come with the document this one is related to, and must stay.
    related_to_document_id: form.common.related_to_document_id, place: form.common.place, original_author: form.common.original_author,
  };
  document.querySelectorAll('#pf-versions [data-version]').forEach(card => {
    const v = form.versions[parseInt(card.dataset.version, 10)];
    v.language = card.querySelector('.pv-language').value;
    v.original_title = card.querySelector('.pv-title').value;
    v.access_level = card.querySelector('.pv-level').value;
    v.body = card.querySelector('.pv-body').value;
    v.media_type = card.querySelector('.pv-format').value;
    v.external_url = card.querySelector('.pv-link').value.trim();
    v.reader_name = card.querySelector('.pv-reader').value;
    if (v.media_type === 'VID') v.duration = card.querySelector('.pv-duration').value;
  });
}

// Files first, under a random name: if saving then fails, nothing but an unused file is left behind.
async function persist() {
  collectForm();
  const status = document.getElementById('pf-status');
  // Before any file goes up, so a mistyped link doesn't leave an unused recording behind.
  for (const v of form.versions) {
    if (v.media_type === 'VID' && v.external_url && !isMediaLinkOk(v.external_url)) {
      throw new Error('A video link must be an https link to YouTube or Google Drive.');
    }
  }
  for (const v of form.versions) {
    if (v.media_type !== 'AUD' || !v.audioFile) continue;
    const [ending, mime] = AUDIO_FORMATS[(v.audioFile.name.split('.').pop() || '').toLowerCase()];
    status.textContent = `Uploading ${v.audioFile.name}...`;
    const path = `${crypto.randomUUID()}.${ending}`;
    await withStatus(sb.storage.from(AUDIO_BUCKET).upload(path, v.audioFile, { contentType: mime }), 'Uploading the recording...');
    v.duration = await audioDurationOf(v.audioFile);
    v.audio_path = path;
    v.audio_mime = mime;
    v.audio_size = v.audioFile.size;
    v.audioFile = null;
  }
  for (const v of form.versions) {
    if (v.media_type !== 'DOC' || !v.file) continue;
    if (v.file.size > MAX_FILE_BYTES) throw new Error(`"${v.file.name}" is larger than 50 MB.`);
    status.textContent = `Uploading ${v.file.name}...`;
    const path = `proposal-${crypto.randomUUID()}.pdf`;
    await withStatus(sb.storage.from(BUCKET).upload(path, v.file, { contentType: 'application/pdf' }), 'Uploading file...');
    v.pages = await readPdfPageCountFromBlob(v.file);
    v.draft_path = path;
    v.file = null;
  }
  status.textContent = '';
  const payload = {
    common: form.common,
    work_id: form.work_id,
    new_work: form.newWork,
    versions: form.versions.map(v => ({
      document_id: v.document_id, language: v.language, original_title: v.original_title, body: v.body,
      draft_path: v.draft_path, pages: v.pages, access_level: v.access_level,
      media_type: v.media_type, external_url: v.external_url, duration: v.duration,
      audio_path: v.audio_path, audio_mime: v.audio_mime, audio_size: v.audio_size, reader_name: v.reader_name,
      source_board_post_id: v.source_board_post_id,
    })),
  };
  form.id = await withStatus(sb.rpc('save_submission', { p_id: form.id, p_payload: payload }), 'Saving...');
  const saved = await withStatus(sb.rpc('get_submission_detail', { p_id: form.id }));
  form.versions = saved.versions.map(v => ({ ...v, body: v.body || '', file: null, audioFile: null }));
  form.work_id = saved.work_id;
  form.newWork = false;
  // A suggestion from a board is settled only once there is really a proposal to show for it.
  if (form.requestId) {
    await withStatus(sb.rpc('close_archive_request', { p_id: form.requestId, p_outcome: 'proposed' }), 'Saving...');
    form.requestId = null;
  }
}

function renderWorkChoice() {
  const box = document.getElementById('pf-work-choice');
  box.innerHTML = form.work_id && form.workLabel
    ? `<div class="hint"><b>Linked to:</b> <span dir="auto">${esc(form.workLabel)}</span> <button class="btn secondary" id="pf-work-clear" style="padding:2px 8px;">Remove the link</button></div>`
    : '<div class="hint">Not linked to anything: this will be a new work.</div>';
  document.getElementById('pf-work-clear')?.addEventListener('click', () => {
    form.work_id = null;
    form.workLabel = '';
    form.newWork = true;
    renderWorkChoice();
  });
}

function wireSearch() {
  const input = document.getElementById('pf-search');
  let timer = null;
  input.addEventListener('input', () => {
    clearTimeout(timer);
    timer = setTimeout(() => runSearch(input.value.trim()), 400);
  });
}

const SEARCH_FIELDS = 'document_id,title,en_title,original_title,ur_title,it_title,language,work_id,workflow_status,category,author,ref_date,ref_period,recipient,main_topic,secondary_tags';

async function runSearch(q) {
  const box = document.getElementById('pf-search-results');
  if (q.length < 3) { box.innerHTML = ''; return; }
  const like = likeSafe(q);
  const [byTitle, byText] = await Promise.all([
    withStatus(sb.from('documents').select(SEARCH_FIELDS).or(`title.ilike.${like},original_title.ilike.${like},ur_title.ilike.${like},en_title.ilike.${like},it_title.ilike.${like}`).limit(30)),
    withStatus(sb.rpc('search_document_texts', { q, lim: 10 })),
  ]);
  const seen = new Set(byTitle.map(d => d.document_id));
  const textIds = byText.map(t => t.document_id).filter(id => !seen.has(id));
  const fromText = textIds.length ? await withStatus(sb.from('documents').select(SEARCH_FIELDS).in('document_id', textIds)) : [];
  const score = d => Math.max(titleOverlapScore(q, d.en_title), titleOverlapScore(q, d.title), titleOverlapScore(q, d.original_title), titleOverlapScore(q, d.it_title));
  const rows = [...byTitle, ...fromText]
    .filter(d => d.work_id && !HIDDEN_DOC_STATUSES.includes(d.workflow_status))
    .sort((a, b) => score(b) - score(a))
    .slice(0, 10);
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing similar found.</div>'; return; }
  box.innerHTML = rows.map(d => `
    <div class="btn-row" data-doc="${esc(d.document_id)}" style="justify-content:space-between;align-items:center;border-top:1px solid var(--line);padding:6px 0;margin:0;">
      <div style="min-width:0;"><span dir="auto">${esc(d.en_title || d.title || d.original_title) || '<span class="hint">(no title)</span>'}</span>
        <span class="hint">#${esc(d.document_id)} &middot; ${esc(labelOf(State.langs, d.language))}${d.ref_period || d.ref_date ? ' &middot; ' + esc(d.ref_period || d.ref_date) : ''}</span></div>
      <button class="btn secondary" style="padding:3px 10px;white-space:nowrap;">Link to this</button>
    </div>`).join('');
  box.querySelectorAll('[data-doc]').forEach(row => row.querySelector('button').addEventListener('click', () => {
    const d = rows.find(r => String(r.document_id) === row.dataset.doc);
    collectForm();
    form.work_id = d.work_id;
    form.newWork = false;
    form.workLabel = d.en_title || d.title || d.original_title || `Work #${d.work_id}`;
    // Fill only what is still empty: the person's own entries stay.
    const c = form.common;
    c.en_title = c.en_title || d.en_title || '';
    c.category = c.category || d.category || '';
    c.author = c.author || d.author || '';
    c.ref_date = c.ref_date || d.ref_date || '';
    c.ref_period = c.ref_period || d.ref_period || '';
    c.recipient = c.recipient || (d.recipient && d.recipient[0]) || '';
    c.main_topic = c.main_topic || d.main_topic || '';
    c.secondary_tags = c.secondary_tags || d.secondary_tags || '';
    renderCommon();
    loadTagSuggestions();
    renderWorkChoice();
    box.innerHTML = '';
    document.getElementById('pf-search').value = '';
  }));
}

let tagSuggestions = null;
async function loadTagSuggestions() {
  if (!tagSuggestions) {
    const { data } = await sb.from('documents').select('secondary_tags').not('secondary_tags', 'is', null);
    const tags = new Set();
    (data || []).forEach(r => (r.secondary_tags || '').split(/[,;]/).map(t => t.trim()).filter(Boolean).forEach(t => tags.add(t)));
    tagSuggestions = [...tags].sort();
  }
  const list = document.getElementById('pf-tag-list');
  if (list) list.innerHTML = tagSuggestions.map(t => `<option value="${esc(t)}"></option>`).join('');
}

// ---------- The queue ----------

async function renderQueue(main, body) {
  const rows = await withStatus(sb.rpc('get_submission_queue'));
  body.innerHTML = `
    <div class="panel">
      <p class="hint" style="margin-top:0;">Oldest first. Who proposed each one isn't shown. Taking a proposal holds it for you for 48 hours; after that it comes back here by itself.</p>
      ${rows.length ? rows.map(r => `
        <div class="subpanel" data-id="${esc(r.id)}" style="margin-top:12px;">
          <div style="font-weight:600;" dir="auto">${esc(r.title)}</div>
          <div class="hint">${esc(r.languages)} &middot; waiting ${r.days_waiting === 0 ? 'since today' : `${esc(r.days_waiting)} day${r.days_waiting === 1 ? '' : 's'}`}</div>
          <div>
            ${r.overdue ? '<span class="count-badge" style="padding:1px 6px;background:var(--danger);color:#fff;">Over 7 days</span>' : ''}
            ${r.reminder_count ? '<span class="count-badge" style="padding:1px 6px;">Reminder sent</span>' : ''}
            ${r.is_reserved ? '<span class="count-badge" style="padding:1px 6px;">Reserved</span>' : ''}
            ${r.mine ? '<span class="count-badge" style="padding:1px 6px;">Yours</span>' : ''}
            ${r.claimed_by_me ? '<span class="count-badge" style="padding:1px 6px;">You have taken it</span>' : ''}
            ${r.claimed_by_other ? '<span class="count-badge" style="padding:1px 6px;">Another reviewer has it</span>' : ''}
          </div>
          <div class="btn-row"><button class="btn prop-review">Open</button></div>
        </div>`).join('') : '<div class="empty-msg">Nothing waiting for review.</div>'}
    </div>`;
  body.querySelectorAll('[data-id]').forEach(card => {
    card.querySelector('.prop-review').addEventListener('click', () => renderDetail(main, parseInt(card.dataset.id, 10)));
  });
}

// ---------- One proposal, to read or to review ----------

async function openFile(path) {
  const { data, error } = await sb.storage.from(BUCKET).createSignedUrl(path, 300);
  if (error) { alert(error.message); return; }
  window.open(data.signedUrl, '_blank');
}

async function renderDetail(main, id) {
  const d = await withStatus(sb.rpc('get_submission_detail', { p_id: id }));
  const c = d.common || {};
  const line = (label, value) => value ? `<div><b>${esc(label)}:</b> <span dir="auto">${esc(value)}</span></div>` : '';
  const canDecide = d.can_review && d.status === 'submitted' && (!d.claimed_by_other || isAdmin());
  scrollTop();
  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 8px;">
        <h2 style="margin:0;" dir="auto">${esc(d.title) || '(no title)'}</h2>
        <button class="btn secondary" id="pd-back">Back</button>
      </div>
      <div class="hint">${esc(STATUS_LABELS[d.status] || d.status)}${d.is_reserved ? ' &middot; Reserved' : ''}${d.proposer_email ? ' &middot; proposed by ' + esc(d.proposer_email) : ''}</div>
      ${d.decision_note ? `<p style="white-space:pre-wrap;" dir="auto"><b>Reviewer's note:</b> ${esc(d.decision_note)}</p>` : ''}
      <div class="field" style="font-size:13px;line-height:1.7;margin-top:10px;">
        ${line('Category', labelOf(State.categories, c.category))}
        ${line('Author', labelOf(State.authors, c.author))}
        ${line('Date', c.ref_date)}
        ${line('Period', c.ref_period)}
        ${line('Recipient', labelOf(State.recipients, c.recipient))}
        ${line('Main topic', labelOf(State.mainTopics, c.main_topic))}
        ${line('Topic tags', c.secondary_tags)}
        ${line('Bible verse', c.bible_verse)}
      </div>
      ${d.work_documents.length ? `<div class="field"><label>Other versions of this work, already in the archive</label>${d.work_documents.map(w => `<div class="hint"><span dir="auto">${esc(w.title)}</span> &middot; ${esc(labelOf(State.langs, w.language))} &middot; #${esc(w.document_id)}</div>`).join('')}</div>` : '<div class="hint">Proposed as a new work, not linked to anything in the archive.</div>'}
      ${d.versions.map(v => `
        <div class="subpanel" style="margin-top:12px;" data-doc="${esc(v.document_id)}">
          <h3 style="margin-top:0;">${esc(labelOf(State.langs, v.language))}${v.media_type === 'DOC' ? '' : ` <span class="count-badge" style="padding:1px 6px;">${esc(labelOf(FORMATS, v.media_type))}</span>`}${v.access_level === 'reserved' ? ' <span class="count-badge" style="padding:1px 6px;">Reserved</span>' : ''}</h3>
          <div dir="auto" style="font-weight:600;">${esc(v.original_title)}</div>
          ${v.duration ? `<div class="hint">Duration: ${esc(v.duration)}</div>` : ''}
          ${v.media_type === 'VID' ? `<div class="btn-row">${v.external_url ? videoLinkHtml(v.external_url, 'Watch the video', true) : '<span class="hint">No link yet.</span>'}</div>` : ''}
          ${v.media_type === 'AUD' ? `<div class="pd-audio">${v.audio_path ? '' : '<span class="hint">No recording yet.</span>'}</div>` : ''}
          ${v.media_type !== 'DOC' ? '' : v.body ? `<div dir="auto" style="white-space:pre-wrap;max-height:320px;overflow:auto;border:1px solid var(--line);padding:8px;margin:6px 0;">${esc(v.body)}</div>` : '<div class="hint">No text: only searchable by title and tags.</div>'}
          ${v.draft_path ? '<div class="btn-row"><button class="btn secondary pd-file">Open the PDF</button></div>' : ''}
          ${canDecide && v.body ? `<label style="display:flex;align-items:center;gap:8px;margin-top:6px;text-transform:none;letter-spacing:normal;font-size:13.5px;"><input type="checkbox" class="pd-read" style="width:auto;flex:none;" value="${esc(v.document_id)}"> I have read this text against its source</label>` : ''}
        </div>`).join('')}
      ${canDecide ? `
        <div class="btn-row" style="margin-top:14px;">
          ${d.claimed_by_me ? '<button class="btn secondary" id="pd-release">Release it</button>' : '<button class="btn secondary" id="pd-claim">Take it</button>'}
          <button class="btn" id="pd-approve">Approve and publish</button>
          <button class="btn secondary" id="pd-back-correct">Send back to correct</button>
          <button class="btn danger" id="pd-reject">Reject</button>
        </div>` : ''}
      ${d.can_review && d.status === 'submitted' && !canDecide ? '<p class="hint">Another reviewer has taken this. It comes back to the queue after 48 hours if they don\'t decide.</p>' : ''}
      <details class="subpanel" style="margin-top:14px;" ${d.can_review ? '' : 'open'}>
        <summary style="cursor:pointer;font-weight:600;">History</summary>
        ${d.events.map(e => `<div class="hint" style="padding:2px 0;">${esc((e.at || '').slice(0, 16).replace('T', ' '))} &middot; ${esc(EVENT_LABELS[e.event] || e.event)}${e.actor ? ' &middot; ' + esc(e.actor) : ''}${e.note ? `: <span dir="auto">${esc(e.note)}</span>` : ''}</div>`).join('')}
      </details>
    </div>`;
  document.getElementById('pd-back').addEventListener('click', () => renderProposalsView(main));
  main.querySelectorAll('[data-doc]').forEach(card => {
    const v = d.versions.find(x => String(x.document_id) === card.dataset.doc);
    card.querySelector('.pd-file')?.addEventListener('click', () => openFile(v.draft_path));
    if (v.media_type === 'AUD' && v.audio_path) mountAudioPlayer(card.querySelector('.pd-audio'), { path: v.audio_path, reader_name: v.reader_name }, false);
  });
  const reload = () => renderDetail(main, id);
  const closeToQueue = () => { currentTab = 'queue'; renderProposalsView(main); };
  document.getElementById('pd-claim')?.addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('claim_submission', { p_id: id }), 'Saving...'))) reload();
  });
  document.getElementById('pd-release')?.addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('release_submission', { p_id: id }), 'Saving...'))) reload();
  });
  document.getElementById('pd-approve')?.addEventListener('click', async () => {
    if (!confirm('Approve and publish? Every version becomes visible at once, according to its access level.')) return;
    const read = [...main.querySelectorAll('.pd-read:checked')].map(cb => parseInt(cb.value, 10));
    if (await act(() => withStatus(sb.rpc('approve_submission', { p_id: id, p_read_document_ids: read, p_note: null }), 'Publishing...'))) closeToQueue();
  });
  document.getElementById('pd-back-correct')?.addEventListener('click', async () => {
    const note = prompt('What needs correcting? The person who proposed it will read this.');
    if (note === null) return;
    if (await act(() => withStatus(sb.rpc('send_back_submission', { p_id: id, p_note: note }), 'Sending back...'))) closeToQueue();
  });
  document.getElementById('pd-reject')?.addEventListener('click', async () => {
    const note = prompt('Why are you rejecting this? The person who proposed it will read this.');
    if (note === null) return;
    if (await act(() => withStatus(sb.rpc('reject_submission', { p_id: id, p_note: note }), 'Rejecting...'))) closeToQueue();
  });
}

// ---------- PDFs to copy to Drive: the app opens PDFs from there ----------

async function renderDriveList(body) {
  const rows = await withStatus(sb.rpc('get_documents_for_drive'));
  body.innerHTML = `
    <div class="panel">
      <p class="hint" style="margin-top:0;">Approved PDFs, until now only in Supabase. "Open PDF" looks for them on Drive, so copy each one there. The copy in Supabase is then removed, to keep within the free plan's space.</p>
      ${rows.length ? `<div class="grid-wrap"><table class="grid">
        <thead><tr><th>Document</th><th>Title</th><th>File name</th><th></th></tr></thead>
        <tbody>${rows.map(r => `<tr data-doc="${esc(r.document_id)}">
          <td>#${esc(r.document_id)}${r.access_level === 'reserved' ? ' <span class="count-badge" style="padding:1px 6px;">Reserved</span>' : ''}</td>
          <td dir="auto">${esc(r.title)}</td><td>${esc(r.file_name)}</td>
          <td><button class="btn secondary pdr-send" style="padding:2px 8px;">Copy to Drive</button></td>
        </tr>`).join('')}</tbody>
      </table></div>` : '<div class="empty-msg">Nothing to copy.</div>'}
    </div>`;
  body.querySelectorAll('[data-doc]').forEach(row => row.querySelector('.pdr-send').addEventListener('click', async () => {
    const r = rows.find(x => String(x.document_id) === row.dataset.doc);
    if (r.access_level === 'reserved' && !confirm('This document is reserved, and anyone with the link can open a file on Drive. Copy it anyway?')) return;
    const ok = await act(async () => {
      const token = await getDriveAccessToken();
      const { data, error } = await sb.storage.from(BUCKET).download(r.storage_path);
      if (error) throw error;
      await uploadPdfToGDrive(r.file_name, data, token);
      await withStatus(sb.rpc('mark_document_on_drive', { p_document_id: r.document_id }), 'Saving...');
      await sb.storage.from(BUCKET).remove([r.storage_path]);
    });
    if (ok) renderDriveList(body);
  }));
}

// ---------- The count on the tab, and the note at sign-in ----------

export async function refreshProposalsBadge() {
  const { data } = await sb.rpc('get_submission_counts');
  const c = data && data[0];
  const btn = document.querySelector('.tab-btn[data-tab="proposals"]');
  if (!btn) return c;
  const total = c ? c.to_review + c.to_correct : 0;
  btn.textContent = total ? `Proposals (${total})` : 'Proposals';
  return c;
}

export async function initProposalNotifications(navigate) {
  if (!canWrite()) return;
  const c = await refreshProposalsBadge();
  if (!c || (!c.to_review && !c.to_correct)) return;
  const parts = [];
  if (c.to_review) parts.push(`${c.to_review} waiting for review${c.reminded ? `, ${c.reminded} with a reminder` : ''}${c.overdue ? `, ${c.overdue} for over 7 days` : ''}`);
  if (c.to_correct) parts.push(`${c.to_correct} of yours to correct`);
  document.querySelectorAll('.toast-notification').forEach(t => t.remove());
  const toast = document.createElement('div');
  toast.className = 'toast-notification';
  toast.innerHTML = `
    <div class="toast-title">Proposals</div>
    <div class="toast-body">${esc(parts.join('; '))}.</div>
    <div class="btn-row" style="margin:8px 0 0;">
      <button class="btn" id="toast-prop-view" style="padding:4px 10px;">View</button>
      <button class="btn secondary" id="toast-prop-close" style="padding:4px 10px;">Dismiss</button>
    </div>`;
  document.body.appendChild(toast);
  document.getElementById('toast-prop-close').addEventListener('click', () => toast.remove());
  document.getElementById('toast-prop-view').addEventListener('click', () => {
    toast.remove();
    if (c.to_review) currentTab = 'queue';
    navigate();
  });
}
