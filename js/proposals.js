// Proposals: the one door for new content (112_proposals.sql, Documentazione\PROTOCOLLO_Ingresso_
// archivio_v1.md §6-7). A team member fills in the form; a Revisor or Coordinator approves, and that
// alone publishes. Everything goes through server functions, in one transaction: this module only
// collects and shows, and the database is the real gate.

import {
  sb, State, esc, withStatus, optionsHtml, labelOf, isAdmin, isCoordinator, canManageReserved, canWrite, BUCKET, likeSafe,
  titleOverlapScore, ACCESS_LEVELS, readPdfPageCountFromBlob, getDriveAccessToken, uploadPdfToGDrive,
  AUDIO_BUCKET, AUDIO_FORMATS, audioFileProblem, audioDurationOf, HIDDEN_DOC_STATUSES, isMediaLinkOk, videoLinkHtml, mountAudioPlayer,
  helpLinkHtml, textDir, confirmPopup, promptPopup, loadLibrary
} from './core.js?v=20261127223631';
import { fileSource, documentPane, openDocument, wireSplit } from './desk.js?v=20261127223631';

const MAX_FILE_BYTES = 50 * 1024 * 1024; // the Supabase Free plan's limit per file
const FORMATS = [['DOC', 'Text or PDF'], ['AUD', 'Audio'], ['VID', 'Video']];
const STATUS_LABELS = {
  draft: 'Draft',
  submitted: 'Awaiting review',
  to_correct: 'To correct',
  published: 'Published',
  rejected: 'Rejected',
};
// The same colours of state as in Tasks, with a sign and a word.
const STATUS_CLASS = { draft: 'st-grey', submitted: 'st-violet', to_correct: 'st-red', published: 'st-green', rejected: 'st-grey' };
const STATUS_SIGN = { draft: '&#9998;', submitted: '&#8987;', to_correct: '&#8617;', published: '&#10003;', rejected: '&#10005;' };
const EVENT_LABELS = {
  created: 'Created', submitted: 'Sent for review', resubmitted: 'Sent again after correcting',
  withdrawn: 'Taken back', discarded: 'Discarded', reminder: 'Reminder sent', claimed: 'A reviewer took it',
  released: 'A reviewer released it', sent_back: 'Sent back to correct', published: 'Published', rejected: 'Rejected',
};

const MAX_WORD_BYTES = 20 * 1024 * 1024;

let currentTab = 'mine';

const dateOf = iso => (iso || '').slice(0, 10);
const scrollTop = () => { document.getElementById('main').scrollTop = 0; };

// sb.rpc through withStatus throws on any refusal; every action here shows the server's own message.
async function act(fn) {
  try { await fn(); return true; }
  catch (e) { alert(e.message); return false; }
}

// The text only: layout and images stay out, and the file itself is not kept.
async function textFromWord(file) {
  if (file.size > MAX_WORD_BYTES) throw new Error(`"${file.name}" is larger than 20 MB.`);
  const reader = await loadLibrary('mammoth', 'Could not load the Word reader. Please check the connection and try again.');
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

const openProposal = id => window.__renderTab('proposals', undefined, 'proposal/' + id);
const toList = () => window.__renderTab('proposals', undefined, '');

export async function renderProposalsView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  // An address: one proposal, as a form while it is the person's to write, otherwise to read or to review.
  const asked = /^proposal\/(\d+)$/.exec(State.sub || '');
  if (asked) {
    const askedId = parseInt(asked[1], 10);
    let d = null;
    try { d = await withStatus(sb.rpc('get_submission_detail', { p_id: askedId })); } catch { /* said by renderDetail */ }
    if (d && d.mine && ['draft', 'to_correct'].includes(d.status)) await renderForm(main, askedId);
    else await renderDetail(main, askedId);
    return;
  }
  // Coming from a board post, already filled in.
  if (State.proposalPrefill) {
    const prefill = State.proposalPrefill;
    State.proposalPrefill = null;
    currentTab = 'mine';
    await renderForm(main, null, prefill);
    return;
  }
  // Coming from My work: one proposal to correct, or one of the lists.
  if (State.proposalOpen) {
    const id = State.proposalOpen;
    State.proposalOpen = null;
    currentTab = 'mine';
    openProposal(id);
    return;
  }
  if (State.proposalsTab) { currentTab = State.proposalsTab; State.proposalsTab = null; }
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
    return `<span class="st st-violet">&#8987; Awaiting review</span> ${wait}${r.in_review ? ' &middot; a reviewer is working on it' : ''}`;
  }
  return `<span class="st ${STATUS_CLASS[r.status] || 'st-grey'}">${STATUS_SIGN[r.status] || ''} ${esc(STATUS_LABELS[r.status] || r.status)}</span>`;
}

async function renderMine(main, body) {
  // What must be corrected comes first.
  const rows = (await withStatus(sb.rpc('get_my_submissions'))).slice().sort((a, b) => (b.status === 'to_correct') - (a.status === 'to_correct'));
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
    card.querySelector('.prop-edit')?.addEventListener('click', () => openProposal(id));
    card.querySelector('.prop-open')?.addEventListener('click', () => openProposal(id));
    card.querySelector('.prop-discard')?.addEventListener('click', async () => {
      if (!await confirmPopup('Discard this proposal?')) return;
      if (await act(() => withStatus(sb.rpc('discard_submission', { p_id: id }), 'Discarding...'))) {
        // Its copy on this device goes too.
        const { data: { user } } = await sb.auth.getUser();
        forgetOnDevice(`proposalDraft_${user?.id || ''}_${id}`);
        renderProposalsView(main);
      }
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
    if (!await confirmPopup('Link this document, and any versions already linked to it, to this month?')) return;
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

// The four steps of a proposal (Owner's decision, 2026-11-27). All four are in the page at once, one shown, so nothing is lost
// moving between them. Save draft and Next (in the last step Send for review) stay in sight at the bottom.
const STEPS = [['Is it already here?', 'Look for it first'], ['About the text', 'Title, author, date'], ['The text or the file', 'One for each language'], ['Check and send', 'What is missing']];
let step = 0;
const wide = () => window.matchMedia('(min-width: 1000px)').matches;

// While writing, the proposal is kept on this device (not the files chosen): if the page closes, it is offered again.
// Only Save draft puts it in My proposals.
let draftKey = '', keepTimer = null;
const keptCopy = () => ({ id: form.id, work_id: form.work_id, newWork: form.newWork, workLabel: form.workLabel, common: form.common, requestId: form.requestId || null, existing: form.existing || null,
  versions: form.versions.map(v => ({ ...v, file: null, audioFile: null, fileName: v.file?.name || v.fileName || '', audioName: v.audioFile?.name || v.audioName || '' })) });
function keepOnDevice() {
  clearTimeout(keepTimer);
  keepTimer = setTimeout(() => {
    if (!document.getElementById('pf-versions')) return;
    collectForm();
    try {
      localStorage.setItem(draftKey, JSON.stringify({ at: new Date().toISOString(), step, form: keptCopy() }));
      const kept = document.getElementById('pf-kept');
      if (kept) kept.textContent = 'Kept on this device ✓';
    } catch { /* a full or closed storage: only Save draft keeps it */ }
  }, 700);
}
function forgetOnDevice(...keys) { clearTimeout(keepTimer); for (const k of keys) { try { localStorage.removeItem(k); } catch { /* nothing kept */ } } }

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
  const { data: { user } } = await sb.auth.getUser();
  draftKey = `proposalDraft_${user?.id || ''}_${id || (prefill ? 'prefill' : 'new')}`;
  step = id && form.decisionNote ? 3 : 0;
  let restored = null;
  if (!prefill) { try { restored = JSON.parse(localStorage.getItem(draftKey) || 'null'); } catch { restored = null; } }
  if (restored?.form && await confirmPopup(`You have a draft of this proposal on this device, from ${new Date(restored.at).toLocaleString('en', { day: 'numeric', month: 'long', hour: '2-digit', minute: '2-digit' })}. Continue it?`, { confirmLabel: 'Continue it', cancelLabel: 'Start again' })) {
    Object.assign(form, restored.form, { decisionNote: form.decisionNote, status: form.status });
    step = restored.step || 0;
  } else if (restored) forgetOnDevice(draftKey);
  const filesAgain = (restored?.form?.versions || []).flatMap(v => [v.fileName, v.audioName]).filter(Boolean);
  scrollTop();
  main.innerHTML = `
    <div class="panel pf-panel">
      <div class="btn-row start-back-row"><button class="btn secondary back-btn" id="pf-back">&lsaquo; Back</button></div>
      <h2 style="margin:0 0 6px;">${id ? 'Edit proposal' : 'New proposal'}</h2>
      <p class="hint" style="margin-top:0;">Proposing earns no credits by itself. If you would like a compensation, agree with the team first: they will create a task for it.</p>
      ${prefill?.note ? `<p class="hint">${esc(prefill.note)}${(prefill.links || []).map(([label, url]) => ` <a href="${esc(url)}" target="_blank" rel="noopener noreferrer">${esc(label)}</a>.`).join('')}</p>` : ''}
      ${form.decisionNote ? `<p class="pf-note" dir="auto"><b>Reviewer's note:</b> ${esc(form.decisionNote)}</p>` : ''}
      ${filesAgain.length && Object.keys(restored?.form || {}).length && form.versions.some(v => v.fileName || v.audioName) ? `<p class="pf-note">The files you had chosen are not kept on the device: please choose them again (${filesAgain.map(esc).join(', ')}).</p>` : ''}
      <div class="pf-wrap">
        <nav class="pf-steps" aria-label="Steps">${STEPS.map(([name, note], i) => `<button type="button" class="pf-step" data-step="${i}"><span class="desk-num">${i + 1}</span><span class="pf-step-text"><b>${name}</b><span class="hint">${note}</span></span></button>`).join('')}</nav>
        <div class="pf-stage">
          <section class="pf-sec" data-sec="0">
          ${form.common.related_to_document_id ? `
            <h3>A new version of a document in the archive</h3>
            <p style="margin-bottom:4px;">Related to <b dir="auto">${esc(form.workLabel)}</b> <span class="hint">#${esc(form.common.related_to_document_id)}</span></p>
            <p class="hint" style="margin-top:0;">What you add here stays linked to it, and each will show the other among its versions.${versionsSummary(form.existing)}</p>` : `
            <h3>Is it already here?</h3>
            <p class="hint">Look for it first. If the same text is here in another language or version, link your proposal to it. You decide: nothing is linked by itself.</p>
            <div class="searchbar"><input id="pf-search" dir="auto" placeholder="Search a title or a sentence of the text"></div>
            <div id="pf-search-results"></div>
            <div id="pf-work-choice" style="margin-top:8px;"></div>`}
          </section>
          <section class="pf-sec" data-sec="1" hidden><h3>About the text</h3><div id="pf-common"></div></section>
          <section class="pf-sec" data-sec="2" hidden>
            <h3>The text or the file</h3>
            <p class="hint">One for each language and format. The text, pasted or loaded from Word, is what makes it searchable: a PDF alone can be found only by its title and tags.</p>
            <div id="pf-versions"></div>
            <div class="btn-row"><button type="button" class="btn secondary" id="pf-add-version">+ Another language</button></div>
          </section>
          <section class="pf-sec" data-sec="3" hidden><h3>Check and send</h3><div id="pf-check"></div></section>
        </div>
      </div>
      <div class="pf-bottom">
        <span class="hint" id="pf-kept" aria-live="polite"></span>
        <button type="button" class="btn secondary" id="pf-save">Save draft</button>
        ${isAdmin() ? '<button type="button" class="btn secondary" id="pf-publish" hidden>Publish directly (Admin)</button>' : ''}
        <button type="button" class="btn" id="pf-next">Next &rsaquo;</button>
        <button type="button" class="btn" id="pf-submit" hidden>Send for review</button>
      </div>
      <div id="pf-status" class="hint" role="status"></div>
    </div>`;
  renderCommon();
  renderVersions();
  if (!form.common.related_to_document_id) {
    renderWorkChoice();
    wireSearch();
  }
  goStep(step);
  // Whatever is written is not lost by leaving: the app asks first (State.unsaved, app.js), and the device keeps a copy.
  State.unsaved = '';
  const changed = () => { State.unsaved = 'This proposal has changes that are not saved. Leave it?'; keepOnDevice(); };
  const formPanel = main.querySelector('.panel');
  formPanel.addEventListener('input', e => { if (e.target.id !== 'pf-search') changed(); });
  formPanel.addEventListener('change', e => { if (e.target.id !== 'pf-search') changed(); });
  if (restored?.form && Object.keys(restored.form).length && form === form) State.unsaved = 'This proposal has changes that are not saved. Leave it?';
  main.querySelectorAll('[data-step]').forEach(b => b.addEventListener('click', () => goStep(+b.dataset.step)));
  document.getElementById('pf-next').addEventListener('click', () => goStep(step + 1));
  document.getElementById('pf-back').addEventListener('click', async () => {
    if (State.unsaved && !await confirmPopup(State.unsaved, { confirmLabel: 'Leave without saving', cancelLabel: 'Stay here', danger: true })) return;
    State.unsaved = '';
    forgetOnDevice(draftKey);
    toList();
  });
  document.getElementById('pf-add-version').addEventListener('click', () => {
    collectForm();
    form.versions.push(emptyVersion(''));
    renderVersions();
    keepOnDevice();
  });
  const saved = () => forgetOnDevice(draftKey, `proposalDraft_${user?.id || ''}_${form.id}`);
  document.getElementById('pf-save').addEventListener('click', async () => {
    if (await act(() => persist())) { saved(); toList(); }
  });
  document.getElementById('pf-submit').addEventListener('click', async () => {
    const ok = await act(async () => {
      await persist();
      await withStatus(sb.rpc('submit_submission', { p_id: form.id }), 'Sending...');
    });
    if (ok) { saved(); currentTab = 'mine'; toList(); alert('Sent for review. Thank you!'); }
  });
  document.getElementById('pf-publish')?.addEventListener('click', async () => {
    if (!await confirmPopup('Publish this directly, without review? It becomes visible at once, and your action is recorded.')) return;
    const ok = await act(async () => {
      await persist();
      await withStatus(sb.rpc('approve_submission', { p_id: form.id, p_read_document_ids: null, p_note: null }), 'Publishing...');
    });
    if (ok) { saved(); currentTab = 'mine'; toList(); }
  });
  loadTagSuggestions();
}

function goStep(i) {
  if (!document.getElementById('pf-versions')) return;
  collectForm();
  step = Math.max(0, Math.min(STEPS.length - 1, i));
  document.querySelectorAll('.pf-sec').forEach(s => { s.hidden = +s.dataset.sec !== step; });
  const missing = whatIsMissing();
  document.querySelectorAll('.pf-step').forEach(b => {
    const n = +b.dataset.step;
    b.classList.toggle('pf-now', n === step);
    // A step already passed: done when nothing is missing in it, otherwise marked to come back to.
    const passed = n < step, lacks = missing.some(m => m.step === n);
    b.classList.toggle('pf-done', passed && !lacks);
    b.classList.toggle('pf-lacks', passed && lacks);
    b.querySelector('.desk-num').innerHTML = passed ? (lacks ? '!' : '&#10003;') : String(n + 1);
    b.setAttribute('aria-label', `${STEPS[n][0]}${passed ? (lacks ? ', something is missing' : ', done') : ''}`);
    b.toggleAttribute('aria-current', n === step);
  });
  const last = step === STEPS.length - 1;
  document.getElementById('pf-next').hidden = last;
  document.getElementById('pf-submit').hidden = !last;
  document.getElementById('pf-submit').disabled = missing.length > 0;
  const pub = document.getElementById('pf-publish');
  if (pub) { pub.hidden = !last; pub.disabled = missing.length > 0; }
  if (last) renderCheck(missing);
  document.getElementById('main').scrollTop = 0;
}

// What submission_problem() would refuse, said before sending, each with the way to it.
function whatIsMissing() {
  const c = form.common, out = [];
  const add = (text, stepNo, find) => out.push({ text, step: stepNo, find });
  if (!(c.en_title || '').trim()) add('The title in English', 1, '#pf-en_title');
  if (!c.category) add('The category', 1, '#pf-category');
  if (!c.author) add('The author', 1, '#pf-author');
  if (!c.ref_date && !(c.ref_period || '').trim()) add('The date, or its month', 1, '#pf-ref_date');
  if (!form.versions.length) add('At least one version', 2, '#pf-add-version');
  form.versions.forEach((v, i) => {
    const who = labelOf(State.langs, v.language) || `Version ${i + 1}`, at = sel => `[data-version="${i}"] ${sel}`;
    if (!v.language) add(`${who}: its language`, 2, at('.pv-language'));
    if (!(v.original_title || '').trim()) add(`${who}: its title`, 2, at('.pv-title'));
    if (v.media_type === 'AUD') {
      if (!v.audio_path && !v.audioFile) add(`${who}: the recording`, 2, at('.pv-audio'));
      if (!(v.reader_name || '').trim()) add(`${who}: who reads it`, 2, at('.pv-reader'));
    } else if (v.media_type === 'VID') {
      if (!(v.external_url || '').trim()) add(`${who}: the video link`, 2, at('.pv-link'));
    } else if (!(v.body || '').trim() && !v.file && !v.draft_path) add(`${who}: its text or a PDF`, 2, at('.pv-body'));
  });
  return out;
}

function renderCheck(missing) {
  const c = form.common, box = document.getElementById('pf-check');
  const facts = [labelOf(State.categories, c.category), labelOf(State.authors, c.author), c.ref_period || c.ref_date].filter(Boolean);
  const state = v => (v.media_type === 'AUD' ? (v.audio_path || v.audioFile ? 'recording' : '') : v.media_type === 'VID' ? (v.external_url ? 'video link' : '')
    : [(v.body || '').trim() ? 'text' : '', v.file || v.draft_path ? 'PDF' : ''].filter(Boolean).join(' and '));
  box.innerHTML = `
    ${missing.length ? `<div class="panel pf-missing"><b>Still missing</b>${missing.map((m, i) => `<div class="pf-miss"><span><span aria-hidden="true">&#10007;</span> ${esc(m.text)}</span><button type="button" class="btn secondary" data-go="${i}">Go there</button></div>`).join('')}</div>`
      : '<div class="panel work-clear"><span aria-hidden="true">&#10003;</span> Nothing is missing.</div>'}
    <div class="panel">
      <div class="desk-title" dir="auto">${esc(c.en_title) || '<span class="hint">(no title yet)</span>'}</div>
      ${facts.length ? `<div class="desk-facts">${facts.map(f => `<span>${esc(f)}</span>`).join('')}</div>` : ''}
      ${form.workLabel ? `<p class="hint">Linked to: <span dir="auto">${esc(form.workLabel)}</span></p>` : ''}
      ${form.versions.map(v => `<div class="pf-ver"><b>${esc(labelOf(State.langs, v.language) || 'A version')}</b> <span dir="auto">${esc(v.original_title)}</span> ${state(v) ? `<span class="st st-green"><span aria-hidden="true">&#10003;</span> ${esc(state(v))}</span>` : ''}</div>`).join('')}
    </div>
    <p class="hint">${missing.length ? 'Send for review opens when nothing is missing.' : 'A Revisor or a Coordinator decides; nobody publishes alone.'} You can also keep it as a draft.</p>`;
  box.querySelectorAll('[data-go]').forEach(b => b.addEventListener('click', () => {
    const m = missing[+b.dataset.go];
    goStep(m.step);
    const el = document.querySelector(m.find);
    if (m.find.includes('pf-ref_date') || m.find.includes('pf-category') || m.find.includes('pf-author') || m.find.includes('pf-en_title')) document.getElementById('pf-more')?.removeAttribute('open');
    el?.scrollIntoView({ block: 'center' });
    el?.focus();
  }));
}

function renderCommon() {
  const c = form.common;
  const more = c.recipient || c.main_topic || c.secondary_tags || c.bible_verse || c.contained_in_document_id;
  document.getElementById('pf-common').innerHTML = `
    <div class="field-grid wide">
      <div class="field"><label for="pf-en_title">Title in English</label><input id="pf-en_title" value="${esc(c.en_title)}"></div>
      <div class="field"><label for="pf-category">Category</label><select id="pf-category">${optionsHtml(State.categories, c.category, true)}</select></div>
      <div class="field"><label for="pf-author">Author</label><select id="pf-author">${optionsHtml(State.authors, c.author, true)}</select></div>
      <div class="field"><label for="pf-ref_date">Date</label><input id="pf-ref_date" type="date" value="${esc(c.ref_date)}"></div>
      <div class="field"><label for="pf-ref_period">or its month <span class="hint">(a Word of Life: such as 2026-12)</span></label><input id="pf-ref_period" placeholder="2026-12" value="${esc(c.ref_period)}"></div>
    </div>
    <details class="dep-more" id="pf-more" ${more ? 'open' : ''}><summary>More details <span class="hint">recipient, topic, tags, Bible verse, magazine issue</span></summary>
    <div class="field-grid wide">
      <div class="field"><label for="pf-recipient">Recipient</label><select id="pf-recipient">${optionsHtml(State.recipients, c.recipient, true)}</select></div>
      <div class="field"><label for="pf-main_topic">Main topic</label><select id="pf-main_topic">${optionsHtml(State.mainTopics, c.main_topic, true)}</select></div>
      <div class="field"><label for="pf-secondary_tags">Topic tags <span class="hint">(separated by commas)</span></label><input id="pf-secondary_tags" list="pf-tag-list" dir="auto" value="${esc(c.secondary_tags)}"><datalist id="pf-tag-list"></datalist></div>
      <div class="field"><label for="pf-bible_verse">Bible verse</label><input id="pf-bible_verse" dir="auto" value="${esc(c.bible_verse)}"></div>
      <div class="field"><label for="pf-contained">Contained in a magazine issue <span class="hint">(the issue's number in the archive)</span></label><input id="pf-contained" type="number" min="1" value="${esc(c.contained_in_document_id)}"></div>
      <div class="field"><label for="pf-contained-page">Page in that issue</label><input id="pf-contained-page" type="number" min="1" value="${esc(c.contained_page)}"></div>
    </div></details>`;
}

// The PDF chosen, beside the text on a computer: what is typed can be compared with it. On a phone, behind a button.
function pdfSourceOf(v) {
  if (v.file) return { key: 'pdf', label: 'The PDF you chose', load: async () => ({ pdf: v.file }) };
  if (v.draft_path) return fileSource('pdf', 'The PDF', v.draft_path);
  return null;
}
function showPdf(card, v) {
  const box = card.querySelector('.pv-pdf'), phone = card.querySelector('.pv-look');
  const source = pdfSourceOf(v);
  card.querySelector('.pv-pair').classList.toggle('pv-has-pdf', !!source);
  phone.hidden = !source;
  if (!source) { box.innerHTML = ''; return; }
  if (wide()) documentPane(box, [source]).show('pdf');
  else box.innerHTML = '';
  phone.onclick = () => openDocument([source], 'pdf');
}

function renderVersions() {
  const levels = ACCESS_LEVELS.filter(([code]) => code !== 'reserved' || canManageReserved());
  const box = document.getElementById('pf-versions');
  box.innerHTML = form.versions.map((v, i) => `
    <div class="panel pv-card" data-version="${i}">
      <div class="field-grid wide">
        <div class="field"><label>Language<select class="pv-language">${optionsHtml(State.langs, v.language, true)}</select></label></div>
        <div class="field"><label>Title in this language<input class="pv-title" dir="auto" value="${esc(v.original_title)}"></label></div>
        <div class="field"><label>Who can read it<select class="pv-level">${optionsHtml(levels, v.access_level, false)}</select></label></div>
        <div class="field"><label>Format<select class="pv-format">${optionsHtml(FORMATS, v.media_type || 'DOC', false)}</select></label></div>
      </div>
      <div class="pv-vid" ${v.media_type === 'VID' ? '' : 'hidden'}>
        <div class="field"><label>Video link<input class="pv-link" type="url" dir="ltr" placeholder="https://youtu.be/..." value="${esc(v.external_url)}"></label>
          <div class="hint">YouTube or Google Drive. The video isn't stored here, so keep the original file on Drive too.</div></div>
        <div class="field"><label>Duration <span class="hint">(if you know it, such as 4 min)</span><input class="pv-duration" value="${esc(v.duration)}"></label></div>
      </div>
      <div class="pv-aud" ${v.media_type === 'AUD' ? '' : 'hidden'}>
        <div class="field"><label>Read by<input class="pv-reader" dir="auto" value="${esc(v.reader_name)}"></label><div class="hint">This name is shown next to the recording.</div></div>
        <div class="field"><label>Recording ${v.audio_path ? '<span class="hint">(already attached; choose another to replace it)</span>' : ''}<input class="pv-audio" type="file" accept=".mp3,.m4a,.mp4,.aac,.ogg,.opus,.webm,audio/*"></label>
          <div class="hint">MP3 or M4A plays on every phone. Up to 25 MB, which is about 50 minutes of voice.</div></div>
      </div>
      <div class="pv-doc" ${!v.media_type || v.media_type === 'DOC' ? '' : 'hidden'}>
        <div class="pv-pair">
          <div class="field pv-text"><label>Text<textarea class="pv-body" dir="${textDir(v.body, v.language)}" rows="14">${esc(v.body)}</textarea></label></div>
          <div class="pv-pdf" aria-label="The PDF"></div>
        </div>
        <div class="pv-drop">
          <span class="desk-drop-drag">Drop a PDF or a Word file here, or</span>
          <label class="btn secondary">Choose a PDF<input class="pv-file sr-only" type="file" accept=".pdf"></label>
          <label class="btn secondary">Load the text from Word<input class="pv-word sr-only" type="file" accept=".docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document"></label>
          <button type="button" class="btn secondary pv-look" hidden>Look at the PDF</button>
        </div>
        <div class="hint pv-file-status">${v.file ? `PDF chosen: ${esc(v.file.name)}` : v.draft_path ? 'A PDF is attached. Choose another to replace it.' : ''}</div>
        <div class="hint pv-word-status"></div>
      </div>
      ${form.versions.length > 1 ? '<div class="btn-row"><button type="button" class="btn danger pv-remove">Remove this version</button></div>' : ''}
    </div>`).join('');
  box.querySelectorAll('[data-version]').forEach(card => {
    const i = parseInt(card.dataset.version, 10), v = form.versions[i];
    card.querySelector('.pv-remove')?.addEventListener('click', async () => {
      if (!await confirmPopup('Remove this version from the proposal?', { confirmLabel: 'Remove' })) return;
      collectForm();
      form.versions.splice(i, 1);
      renderVersions();
      keepOnDevice();
    });
    const takePdf = file => {
      if (!file) return;
      if (!/\.pdf$/i.test(file.name)) { alert('Please choose a PDF file.'); return; }
      if (file.size > MAX_FILE_BYTES) { alert(`"${file.name}" is larger than 50 MB.`); return; }
      v.file = file;
      card.querySelector('.pv-file-status').textContent = `PDF chosen: ${file.name}`;
      showPdf(card, v);
      State.unsaved = 'This proposal has changes that are not saved. Leave it?';
      keepOnDevice();
    };
    card.querySelector('.pv-file').addEventListener('change', e => { takePdf(e.target.files[0]); e.target.value = ''; });
    card.querySelector('.pv-format').addEventListener('change', e => {
      card.querySelector('.pv-doc').hidden = e.target.value !== 'DOC';
      card.querySelector('.pv-aud').hidden = e.target.value !== 'AUD';
      card.querySelector('.pv-vid').hidden = e.target.value !== 'VID';
    });
    card.querySelector('.pv-audio').addEventListener('change', e => {
      const file = e.target.files[0] || null;
      const problem = file && audioFileProblem(file);
      if (problem) { alert(problem); e.target.value = ''; v.audioFile = null; return; }
      v.audioFile = file;
    });
    // The text box follows the language chosen, or its letters while the language is not chosen.
    const bodyBox = card.querySelector('.pv-body');
    const setBodyDir = () => { bodyBox.dir = textDir(bodyBox.value, card.querySelector('.pv-language').value); };
    bodyBox.addEventListener('input', setBodyDir);
    card.querySelector('.pv-language').addEventListener('change', setBodyDir);
    const takeWord = async file => {
      if (!file) return;
      if (bodyBox.value.trim() && !await confirmPopup('Replace the text already in this box with the text of the file?')) return;
      const status = card.querySelector('.pv-word-status');
      status.textContent = 'Reading the file...';
      const ok = await act(async () => {
        bodyBox.value = await textFromWord(file);
        setBodyDir();
        status.textContent = `Text loaded from "${file.name}". Please check it: layout and images are not carried over.`;
        State.unsaved = 'This proposal has changes that are not saved. Leave it?';
        keepOnDevice();
      });
      if (!ok) status.textContent = '';
    };
    card.querySelector('.pv-word').addEventListener('change', e => { const f = e.target.files[0]; e.target.value = ''; takeWord(f); });
    // A file dropped on the box: a PDF is attached, a Word file gives its text.
    const drop = card.querySelector('.pv-doc');
    drop.addEventListener('dragover', e => { if ([...(e.dataTransfer?.types || [])].includes('Files')) { e.preventDefault(); drop.classList.add('desk-over'); } });
    drop.addEventListener('dragleave', e => { if (!drop.contains(e.relatedTarget)) drop.classList.remove('desk-over'); });
    drop.addEventListener('drop', e => {
      e.preventDefault();
      drop.classList.remove('desk-over');
      const file = e.dataTransfer.files[0];
      if (!file) return;
      if (/\.docx$/i.test(file.name)) takeWord(file); else takePdf(file);
    });
    showPdf(card, v);
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
  State.unsaved = '';
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
    card.querySelector('.prop-review').addEventListener('click', () => openProposal(card.dataset.id));
  });
}

// ---------- One proposal, to read or to review ----------

// The review (Owner's decision, 2026-11-27): the proposed document beside the decision, as for the tasks. Approve and publish
// opens when every version has been looked at: its PDF or its text opened, its recording played, its video opened.
async function renderDetail(main, id) {
  let d;
  try { d = await withStatus(sb.rpc('get_submission_detail', { p_id: id })); }
  catch {
    main.innerHTML = '<div class="panel"><p>This proposal cannot be opened.</p><div class="btn-row"><button class="btn" id="pd-back">Proposals</button></div></div>';
    main.querySelector('#pd-back').addEventListener('click', toList);
    return;
  }
  const c = d.common || {};
  const canDecide = d.can_review && d.status === 'submitted' && (!d.claimed_by_other || isAdmin());
  const langOf = v => labelOf(State.langs, v.language) || 'A version';
  // What there is to look at in each version, and whether it has been looked at.
  const looked = new Set();
  const sources = [];
  d.versions.forEach((v, i) => {
    const mark = src => ({ ...src, load: async () => { const r = await src.load(); looked.add(i); update(); return r; } });
    if (v.draft_path) sources.push(mark(fileSource(`pdf${i}`, `${langOf(v)}: PDF`, v.draft_path)));
    if (v.body) sources.push(mark({ key: `text${i}`, label: `${langOf(v)}: text`, load: async () => ({ text: v.body, language: v.language }) }));
    const nothing = !v.draft_path && !v.body && !(v.media_type === 'AUD' && v.audio_path) && !(v.media_type === 'VID' && v.external_url);
    if (nothing) looked.add(i);
  });
  const toLook = () => d.versions.map((v, i) => (looked.has(i) ? '' : langOf(v) + (v.media_type === 'AUD' ? ': the recording' : v.media_type === 'VID' ? ': the video' : ''))).filter(Boolean);
  const facts = [labelOf(State.categories, c.category), labelOf(State.authors, c.author), c.ref_period || c.ref_date, labelOf(State.recipients, c.recipient), labelOf(State.mainTopics, c.main_topic)].filter(Boolean);
  const proposer = d.proposer_email && !String(d.proposer_email).includes('@') ? d.proposer_email : '';
  const CHOICES = [['approve', 'Approve and publish', 'It becomes visible at once, according to who can read it.', 'green'], ['back', 'Send back to correct', 'Write what to correct.', 'amber'], ['reject', 'Reject', 'Write why.', 'red']];
  scrollTop();
  const work = `
    <div class="panel desk-info" style="--st:var(--st-violet)">
      ${STATUS_LABELS[d.status] ? mineStateHtml({ ...d, days_waiting: d.submitted_at ? Math.floor((Date.now() - new Date(d.submitted_at)) / 86400000) : 0 }) : ''}
      <div class="desk-title" dir="auto">${esc(d.title) || '(no title)'}</div>
      ${facts.length ? `<div class="desk-facts">${facts.map(f => `<span>${esc(f)}</span>`).join('')}${d.is_reserved ? '<span>Reserved</span>' : ''}</div>` : ''}
      ${c.secondary_tags || c.bible_verse ? `<p class="hint" dir="auto">${esc([c.secondary_tags, c.bible_verse].filter(Boolean).join(' · '))}</p>` : ''}
      ${proposer ? `<p class="hint">Proposed by ${esc(proposer)}</p>` : ''}
      ${d.decision_note ? `<p class="pf-note" dir="auto"><b>Reviewer's note:</b> ${esc(d.decision_note)}</p>` : ''}
    </div>
    ${sources.length ? '<div class="btn-row desk-phone"><button type="button" class="btn secondary desk-open-doc">Look at the document</button></div>' : ''}
    <div class="panel">
      <h3 style="margin-top:0;">${canDecide ? '1. Look at each version' : 'The versions'}</h3>
      ${d.versions.map((v, i) => `
        <div class="pd-ver" data-i="${i}">
          <div><b>${esc(langOf(v))}</b>${v.media_type === 'DOC' ? '' : ` <span class="count-badge">${esc(labelOf(FORMATS, v.media_type))}</span>`}${v.access_level === 'reserved' ? ' <span class="count-badge">Reserved</span>' : ''}
            <span class="pd-looked" hidden>${'<span class="st st-green"><span aria-hidden="true">&#10003;</span> looked at</span>'}</span></div>
          <div dir="auto">${esc(v.original_title)}</div>
          ${v.duration ? `<div class="hint">Duration: ${esc(v.duration)}</div>` : ''}
          <div class="btn-row" style="margin:6px 0 0;">
            ${v.draft_path ? `<button type="button" class="btn secondary" data-show="pdf${i}">Open the PDF</button>` : ''}
            ${v.body ? `<button type="button" class="btn secondary" data-show="text${i}">Read the text</button>` : ''}
            ${v.media_type === 'VID' ? (v.external_url ? videoLinkHtml(v.external_url, 'Watch the video', true) : '<span class="hint">No link yet.</span>') : ''}
            ${v.media_type === 'DOC' && !v.body && !v.draft_path ? '<span class="hint">No text and no PDF.</span>' : ''}
          </div>
          ${v.media_type === 'AUD' ? `<div class="pd-audio">${v.audio_path ? '' : '<span class="hint">No recording yet.</span>'}</div>` : ''}
          ${v.media_type === 'DOC' && !v.body ? '<div class="hint">No text: it can be found only by its title and tags.</div>' : ''}
          ${canDecide && v.body ? `<label class="pd-read-row"><input type="checkbox" class="pd-read" value="${esc(v.document_id)}"> I have read this text against its source</label>` : ''}
        </div>`).join('')}
    </div>
    ${d.work_documents.length ? `<div class="panel"><b>Already in the archive, in the same work</b>${d.work_documents.map(w => `<div class="hint"><span dir="auto">${esc(w.title)}</span> &middot; ${esc(labelOf(State.langs, w.language))} &middot; #${esc(w.document_id)}</div>`).join('')}</div>`
      : '<p class="hint">A new work: nothing else in the archive is linked to it.</p>'}
    ${canDecide ? `
      <div class="panel">
        <div class="btn-row" style="margin-top:0;">${d.claimed_by_me ? '<button type="button" class="btn secondary" id="pd-release">Release it</button><span class="hint">You have taken it for 48 hours.</span>' : '<button type="button" class="btn secondary" id="pd-claim">Take it</button><span class="hint">So that nobody else reviews it at the same time.</span>'}</div>
        <fieldset class="desk-choices"><legend>2. Your decision</legend>${CHOICES.map(([v, l, text, tone]) => `<label class="desk-choice st-${tone}"><input type="radio" name="pd-choice" value="${v}"><span><b>${l}</b><span class="hint">${text}</span></span></label>`).join('')}</fieldset>
        <p class="hint" id="pd-tolook"></p>
        <div class="field"><label for="pd-note">Note for the person who proposed it <span class="hint" id="pd-note-hint"></span></label><textarea id="pd-note" rows="4" dir="auto"></textarea></div>
        <div class="btn-row"><button type="button" class="btn big-btn" id="pd-send" disabled>Send</button></div>
      </div>` : ''}
    ${d.can_review && d.status === 'submitted' && !canDecide ? '<p class="hint">Another reviewer has taken this. It comes back to the queue after 48 hours if they don\'t decide.</p>' : ''}
    <details class="subpanel" ${d.can_review ? '' : 'open'}>
      <summary style="cursor:pointer;font-weight:600;">History</summary>
      ${d.events.map(e => `<div class="hint" style="padding:2px 0;">${esc((e.at || '').slice(0, 16).replace('T', ' '))} &middot; ${esc(EVENT_LABELS[e.event] || e.event)}${e.actor && !String(e.actor).includes('@') ? ' &middot; ' + esc(e.actor) : ''}${e.note ? `: <span dir="auto">${esc(e.note)}</span>` : ''}</div>`).join('')}
    </details>`;
  main.innerHTML = `<div class="desk-head"><button type="button" class="btn secondary" id="pd-back">&lsaquo; ${d.can_review && d.status === 'submitted' ? 'To review' : 'Proposals'}</button><span class="desk-head-title">Proposal ${esc(d.id)}</span></div>
    <div class="desk${sources.length ? '' : ' desk-alone'}">${sources.length ? '<div class="desk-doc" id="desk-doc"></div><div class="desk-split" role="separator" aria-orientation="vertical" aria-label="Make one side wider" tabindex="0"><span aria-hidden="true">&#8942;</span></div>' : ''}<div class="desk-work" id="desk-work">${work}</div></div>`;
  let pane = null;
  const box = main.querySelector('#desk-doc');
  if (box) {
    const open = () => { if (!pane && wide()) { pane = documentPane(box, sources); pane.show(sources[0].key); } };
    open();
    window.addEventListener('resize', function onResize() { if (!box.isConnected) window.removeEventListener('resize', onResize); else open(); });
    wireSplit(main.querySelector('.desk'));
  }
  const show = key => (pane && wide() ? pane.show(key) : openDocument(sources, key));
  main.querySelectorAll('.desk-open-doc').forEach(b => b.addEventListener('click', () => openDocument(sources, sources[0].key)));
  main.querySelectorAll('[data-show]').forEach(b => b.addEventListener('click', () => show(b.dataset.show)));
  main.querySelectorAll('.pd-ver').forEach(card => {
    const i = +card.dataset.i, v = d.versions[i];
    if (v.media_type === 'AUD' && v.audio_path) {
      mountAudioPlayer(card.querySelector('.pd-audio'), { path: v.audio_path, reader_name: v.reader_name }, false);
      card.addEventListener('play', () => { looked.add(i); update(); }, true);
    }
    card.querySelectorAll('a[href]').forEach(a => a.addEventListener('click', () => { looked.add(i); update(); }));
  });
  main.querySelector('#pd-back').addEventListener('click', async () => {
    if (State.unsaved && !await confirmPopup(State.unsaved, { confirmLabel: 'Leave', cancelLabel: 'Stay here', danger: true })) return;
    State.unsaved = '';
    if (d.can_review && d.status === 'submitted') currentTab = 'queue';
    toList();
  });
  const note = main.querySelector('#pd-note'), send = main.querySelector('#pd-send');
  const choice = () => main.querySelector('[name="pd-choice"]:checked')?.value || '';
  function update() {
    main.querySelectorAll('.pd-ver').forEach(card => { card.querySelector('.pd-looked').hidden = !looked.has(+card.dataset.i); });
    if (!send) return;
    const left = toLook(), c2 = choice(), needNote = c2 === 'back' || c2 === 'reject';
    const approve = main.querySelector('[name="pd-choice"][value="approve"]');
    approve.disabled = left.length > 0;
    approve.closest('.desk-choice').classList.toggle('desk-choice-off', left.length > 0);
    if (approve.disabled && approve.checked) approve.checked = false;
    main.querySelector('#pd-tolook').textContent = left.length ? `Approve and publish opens when you have looked at: ${left.join(', ')}.` : '';
    main.querySelector('#pd-note-hint').textContent = needNote ? '(needed)' : '(if you want)';
    main.querySelectorAll('.desk-choice').forEach(l => l.classList.toggle('desk-chosen', l.querySelector('input').checked));
    send.disabled = !choice() || (needNote && !note.value.trim());
    State.unsaved = choice() || note.value.trim() ? 'Your decision has not been sent yet.' : '';
  }
  update();
  main.querySelectorAll('[name="pd-choice"]').forEach(r => r.addEventListener('change', update));
  note?.addEventListener('input', update);
  const reload = () => renderDetail(main, id);
  const closeToQueue = () => { State.unsaved = ''; currentTab = 'queue'; toList(); };
  document.getElementById('pd-claim')?.addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('claim_submission', { p_id: id }), 'Saving...'))) reload();
  });
  document.getElementById('pd-release')?.addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('release_submission', { p_id: id }), 'Saving...'))) reload();
  });
  send?.addEventListener('click', async () => {
    const c2 = choice(), text = note.value.trim();
    if (c2 === 'approve') {
      if (!await confirmPopup('Approve and publish? Every version becomes visible at once, according to who can read it.', { confirmLabel: 'Approve and publish' })) return;
      const read = [...main.querySelectorAll('.pd-read:checked')].map(cb => parseInt(cb.value, 10));
      if (await act(() => withStatus(sb.rpc('approve_submission', { p_id: id, p_read_document_ids: read, p_note: text || null }), 'Publishing...'))) closeToQueue();
    } else if (c2 === 'back') {
      if (await act(() => withStatus(sb.rpc('send_back_submission', { p_id: id, p_note: text }), 'Sending back...'))) closeToQueue();
    } else if (c2 === 'reject') {
      if (!await confirmPopup('Reject this proposal? The person who proposed it will read your note.', { confirmLabel: 'Reject', danger: true })) return;
      if (await act(() => withStatus(sb.rpc('reject_submission', { p_id: id, p_note: text }), 'Rejecting...'))) closeToQueue();
    }
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
    if (r.access_level === 'reserved' && !await confirmPopup('This document is reserved, and anyone with the link can open a file on Drive. Copy it anyway?')) return;
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
  toast.className = 'toast-notification work-toast';
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
