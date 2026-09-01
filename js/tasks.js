// Fase 2 di "Join the Team": bacheca di task. Coordinator/Admin creano i task (testo libero,
// con un document_id opzionale per legarli a un record dell'archivio) e possono assegnarli
// direttamente a un Operator o lasciarli liberi; qualunque Operator+ può "prendere" (claim) un
// task libero fissando lui stesso la data di consegna. RLS impedisce di toccare un task preso
// da qualcun altro (vedi 34_task_store.sql) - i pulsanti qui sotto rispecchiano solo quel
// vincolo, non lo sostituiscono.

import { sb, State, esc, today, canWrite, canReviewApplications, isAdmin, withStatus, getDisplayNameByEmail, nameMapForEmails, optionsHtml, labelOf, BUCKET, downloadInpFromGDrive, getDriveAccessToken, uploadInpToGDrive, computeFileName, uniqueFileName } from './core.js?v=20260902002107';

function isOverdue(t) { return t.status === 'claimed' && t.due_date && t.due_date < today(); }
function formatDate(d) { return d ? esc(d) : '—'; }

// Categories that gate visibility/assignment to a specific qualification - mirrors the case
// expression in operator_qualifies_for_category()/user_qualifies_for_category() in
// 37_task_qualifications_categories.sql. Keep the two in sync if the category list changes.
const CATEGORY_REQUIRES_QUALIFICATION = { IT_UR: 'TRANSLATOR', EN_UR: 'TRANSLATOR', REVISION: 'REVISOR' };

// Below this, Team overview flags the operator in red so Coordinator/Admin notice and can have
// a human conversation - deliberately not an automatic block on anything (see 2026-08-31
// session notes: the team is volunteers, a silent auto-ban would be the wrong tone here).
const LOW_REPUTATION_THRESHOLD = 20;

async function fetchOperators() {
  const rows = await withStatus(sb.from('user_roles').select('user_id,email,reputation').in('role', ['operator', 'coordinator']).order('email'));
  const names = await Promise.all(rows.map(r => getDisplayNameByEmail(r.email)));
  const qualRows = await withStatus(sb.from('user_qualifications').select('*'));
  const qualByUid = {};
  for (const q of qualRows) (qualByUid[q.user_id] ||= new Set()).add(q.qualification_code);
  return rows.map((r, i) => ({ ...r, displayName: names[i], qualifications: qualByUid[r.user_id] || new Set() }));
}

export async function renderTasksView(main) {
  if (!canWrite()) { main.innerHTML = '<div class="empty-msg">Operator access required.</div>'; return; }
  const { data: { user } } = await sb.auth.getUser();
  const manage = canReviewApplications(); // same tier as Team Applications review: Coordinator + Admin
  const myQuals = await withStatus(sb.from('user_qualifications').select('qualification_code').eq('user_id', user.id));
  // Coordinator/Admin can act as Revisor without the tag (oversight tier - e.g. stepping in if
  // the queue backs up), same anonymization as an Operator holding the REVISOR qualification.
  const isRevisor = manage || myQuals.some(q => q.qualification_code === 'REVISOR');

  main.innerHTML = `
    <div class="panel" id="tasks-new-panel" style="display:none;"></div>
    <div class="panel" id="tasks-review-panel" style="display:none;"><h2>Review queue <span class="hint">— we review only the task, so who did the work isn't shown here</span></h2><div id="tasks-review-list"></div></div>
    <div class="panel" id="tasks-publish-panel" style="display:none;"><h2>Publish queue <span class="hint">— approved by a Revisor, ready to go live</span></h2><div id="tasks-publish-list"></div></div>
    <div class="panel" id="tasks-finalize-panel" style="display:none;"><h2>Documents ready to publish <span class="hint">— task already closed; upload the final PDF and InPage file, then publish</span></h2><div id="tasks-finalize-list"></div></div>
    <div class="panel"><h2>Open tasks <span class="hint">— free to claim</span></h2><div id="tasks-open-list"></div></div>
    <div class="panel"><h2>My tasks</h2><div id="tasks-mine-list"></div></div>
    <div class="panel" id="tasks-team-panel" style="display:none;"><h2>Team overview <span class="hint">— everyone's claimed tasks</span></h2><div id="tasks-team-list"></div></div>
    <div class="panel"><h2>Completed</h2><div id="tasks-done-list"></div></div>`;

  let operators = [];
  if (manage) {
    operators = await fetchOperators();
    document.getElementById('tasks-new-panel').style.display = 'block';
    renderNewTaskForm(operators);
    document.getElementById('tasks-team-panel').style.display = 'block';
  }
  if (isRevisor) {
    document.getElementById('tasks-review-panel').style.display = 'block';
    await refreshReviewQueue();
  }
  if (isAdmin()) {
    document.getElementById('tasks-publish-panel').style.display = 'block';
    await refreshPublishQueue();
    document.getElementById('tasks-finalize-panel').style.display = 'block';
    await refreshFinalizeQueue();
  }

  await refreshTasks(user, manage, operators);
}

// Second, separate Admin step (after admin_decide_task('publish') already closed the task and
// awarded credits): documents sitting at 'pending_publish' still need the final PDF - and
// ideally the final InPage file, uploaded to Drive - before finalize_document_publish() makes
// them live. Deliberately decoupled from the Publish queue above (2026-08-31 session decision):
// closing the task shouldn't be blocked on the PDF being ready yet.
async function refreshFinalizeQueue() {
  const rows = await withStatus(sb.from('documents').select('*').eq('workflow_status', 'pending_publish').order('document_id'));
  const box = document.getElementById('tasks-finalize-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing waiting to be finalized right now.</div>'; return; }
  box.innerHTML = rows.map(d => `
    <div class="panel" data-id="${d.document_id}" style="margin-bottom:12px;">
      <b>${esc(d.title)}</b> <span class="hint">Document #${esc(d.document_id)}</span>
      <div class="btn-row"><button class="btn secondary finalize-download-draft">Download draft file</button></div>
      <div class="field-grid" style="max-width:520px;">
        <div class="field"><label>Final PDF ${d.storage_path ? '(uploaded)' : ''}</label><input type="file" class="finalize-pdf-input" accept=".pdf"></div>
        <div class="field"><label>Final .INP for Drive ${d.renamed_inp_file_name ? '(uploaded)' : ''}</label><input type="file" class="finalize-inp-input" accept=".inp,.doc,.docx"></div>
      </div>
      <div class="btn-row"><button class="btn finalize-publish-btn">Publish</button></div>
    </div>`).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = parseInt(card.dataset.id, 10);
    const d = rows.find(r => r.document_id === id);
    card.querySelector('.finalize-download-draft').addEventListener('click', () => downloadDraftFile(id));
    card.querySelector('.finalize-pdf-input').addEventListener('change', async e => {
      const file = e.target.files[0];
      if (!file) return;
      const baseName = computeFileName({ document_id: id, title: d.title });
      const finalName = await uniqueFileName(baseName, id);
      await withStatus(sb.storage.from(BUCKET).upload(finalName, file, { upsert: true }), 'Uploading PDF...');
      await withStatus(sb.from('documents').update({ storage_path: finalName, file_name: finalName }).eq('document_id', id), 'Saving...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.finalize-inp-input').addEventListener('change', async e => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const token = await getDriveAccessToken();
        const driveFileName = `${id}-${file.name}`;
        await uploadInpToGDrive(driveFileName, file, token);
        await withStatus(sb.from('documents').update({ renamed_inp_file_name: driveFileName }).eq('document_id', id), 'Saving...');
        await renderTasksView(document.getElementById('main'));
      } catch (err) {
        alert('Could not upload to Google Drive: ' + err.message);
      }
    });
    card.querySelector('.finalize-publish-btn').addEventListener('click', async () => {
      if (!d.storage_path) { if (!confirm('No final PDF uploaded yet - publish anyway?')) return; }
      await withStatus(sb.rpc('finalize_document_publish', { p_document_id: id }), 'Publishing document...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

async function refreshPublishQueue() {
  const rows = await withStatus(sb.from('tasks').select('*').eq('status', 'approved').order('reviewed_at'));
  const box = document.getElementById('tasks-publish-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing waiting to be published right now.</div>'; return; }
  const docTaskIds = rows.filter(t => t.document_id).map(t => t.id);
  const candidateByTaskId = {};
  if (docTaskIds.length) {
    const candidates = await withStatus(sb.from('documents').select('document_id,source_task_id').in('source_task_id', docTaskIds));
    for (const c of candidates) candidateByTaskId[c.source_task_id] = c.document_id;
  }
  box.innerHTML = rows.map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;">
      <b>${esc(t.title)}</b> ${t.review_verdict === 'ok_but' ? '<span class="chat-tag">OK, but...</span>' : ''}
      ${docLine(t)}
      ${t.review_notes ? `<p class="hint">Revisor's note: ${esc(t.review_notes)}</p>` : ''}
      ${candidateByTaskId[t.id] ? '<div class="btn-row"><button class="btn secondary task-publish-open-file">Open corrected file</button></div>' : ''}
      <div class="btn-row">
        <button class="btn task-publish-btn">Publish</button>
        <button class="btn danger task-reject-btn">Reject</button>
      </div>
    </div>`).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = parseInt(card.dataset.id, 10);
    card.querySelector('.task-publish-open-file')?.addEventListener('click', () => downloadDraftFile(candidateByTaskId[id]));
    card.querySelector('.task-publish-btn').addEventListener('click', async () => {
      if (!confirm('Close this task? The operator gets the credits/reputation the Revisor\'s verdict implied. The document itself isn\'t live yet - you\'ll prepare the final PDF and publish it separately, from "Documents ready to publish" below.')) return;
      await withStatus(sb.rpc('admin_decide_task', { p_task_id: id, p_decision: 'publish', p_note: null }), 'Closing task...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-reject-btn').addEventListener('click', async () => {
      const note = prompt('Why are you rejecting this, despite the Revisor\'s verdict? This closes the task with the same penalty as a fail - you can create a fresh task on the same document afterward from the Completed list.');
      if (note === null) return;
      if (!note.trim()) { alert('Please enter a reason.'); return; }
      await withStatus(sb.rpc('admin_decide_task', { p_task_id: id, p_decision: 'reject', p_note: note.trim() }), 'Rejecting...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

async function refreshReviewQueue() {
  const rows = await withStatus(sb.rpc('get_review_queue'));
  const box = document.getElementById('tasks-review-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing waiting for review right now.</div>'; return; }
  box.innerHTML = rows.map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;">
      <b>${esc(t.title)}</b>
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      ${t.candidate_document_id ? `<div class="btn-row"><button class="btn secondary review-open-file">Open corrected file</button></div>` : ''}
      <div class="field"><label>Notes for the operator <span class="hint">(optional)</span></label><textarea class="review-notes" rows="2"></textarea></div>
      <div class="btn-row">
        <button class="btn review-ok">OK</button>
        <button class="btn secondary review-okbut">OK, but...</button>
        <button class="btn danger review-fail">Fail</button>
      </div>
    </div>`).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = parseInt(card.dataset.id, 10);
    const t = rows.find(r => r.id === id);
    const notes = () => card.querySelector('.review-notes').value.trim() || null;
    card.querySelector('.review-open-file')?.addEventListener('click', async () => {
      const docRows = await withStatus(sb.rpc('get_review_document', { p_document_id: t.candidate_document_id }));
      const draftPath = docRows[0]?.draft_inp_path;
      if (!draftPath) { alert('No file found for this revision.'); return; }
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(draftPath, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
    const submitVerdict = async (verdict, confirmMsg) => {
      if (confirmMsg && !confirm(confirmMsg)) return;
      await withStatus(sb.rpc('submit_task_review', { p_task_id: id, p_verdict: verdict, p_notes: notes() }), 'Submitting review...');
      await renderTasksView(document.getElementById('main'));
    };
    card.querySelector('.review-ok').addEventListener('click', () => submitVerdict('ok'));
    card.querySelector('.review-okbut').addEventListener('click', () => submitVerdict('ok_but'));
    card.querySelector('.review-fail').addEventListener('click', () => submitVerdict('fail', 'Mark this as failed? The task will close and a new open task will be created for someone else to redo (not the same operator).'));
  });
}

function renderNewTaskForm(operators) {
  // Consumed once: a "Create task" click from the Messages inbox (chat.js) stashes a prefill
  // here via State, then hands off to this tab - see chat.js's startTaskFromMessage.
  const prefill = State.taskPrefill;
  State.taskPrefill = null;

  const panel = document.getElementById('tasks-new-panel');
  panel.innerHTML = `
    <h2>New task</h2>
    <div class="field-grid" style="max-width:640px;">
      <div class="field"><label>Title</label><input id="task-new-title" value="${esc(prefill?.title || '')}"></div>
      <div class="field"><label>Description</label><textarea id="task-new-desc" rows="2">${esc(prefill?.description || '')}</textarea></div>
      <div class="field"><label>Category <span class="hint">(optional — gates who can see/claim it)</span></label>
        <select id="task-new-category">${optionsHtml(State.optionListsByName.task_category || [], '', true)}</select>
      </div>
      <div class="field"><label>Document ID <span class="hint">(optional)</span></label><input id="task-new-docid" type="number" min="1" value="${esc(prefill?.document_id || '')}"></div>
      <div class="field"><label>Document pages <span class="hint">(looked up from the document)</span></label><input id="task-new-pages" type="number" min="0" value="${esc(prefill?.document_pages ?? '')}"></div>
      <div class="field"><label>Base credits <span class="hint">(category rate &times; pages)</span></label><input id="task-new-base-credits" type="number" min="0" readonly style="background:var(--paper-card, #f3f4ea);"></div>
      <div class="field"><label>Extra credits <span class="hint">(difficulty/urgency bonus, optional)</span></label><input id="task-new-extra-credits" type="number" value="0"></div>
      <div class="field" id="task-new-extra-note-field" style="display:none;grid-column:1/-1;"><label>Why the extra credits? <span class="hint">(required if not zero)</span></label><textarea id="task-new-extra-note" rows="2"></textarea></div>
      <div class="field" style="grid-column:1/-1;"><label>Total credits</label><div id="task-new-total-credits" style="font-size:14px;font-weight:600;padding:4px 0;">0</div></div>
      <div class="field"><label>Assign directly to <span class="hint">(optional — otherwise left open to claim; list narrows to who's qualified once a category is picked)</span></label>
        <select id="task-new-assignee"></select>
      </div>
      <div class="field" id="task-new-due-field" style="display:none;"><label>Due date</label><input id="task-new-due" type="date"></div>
    </div>
    <div class="btn-row"><button class="btn" id="task-new-submit">Create task</button></div>`;

  let categoryRates = {};
  sb.from('task_category_rates').select('*').then(({ data }) => {
    categoryRates = Object.fromEntries((data || []).map(r => [r.category, r.credits_per_page]));
    recomputeCredits();
  });

  function recomputeCredits() {
    const category = document.getElementById('task-new-category').value;
    const pages = parseFloat(document.getElementById('task-new-pages').value) || 0;
    const rate = categoryRates[category] || 0;
    const base = Math.round(rate * pages);
    document.getElementById('task-new-base-credits').value = base;
    const extra = parseInt(document.getElementById('task-new-extra-credits').value, 10) || 0;
    document.getElementById('task-new-total-credits').textContent = base + extra;
    document.getElementById('task-new-extra-note-field').style.display = extra !== 0 ? 'block' : 'none';
  }
  document.getElementById('task-new-pages').addEventListener('input', recomputeCredits);
  document.getElementById('task-new-extra-credits').addEventListener('input', recomputeCredits);
  document.getElementById('task-new-category').addEventListener('change', recomputeCredits);
  function refreshAssigneeOptions() {
    const category = document.getElementById('task-new-category').value;
    const requiredQual = CATEGORY_REQUIRES_QUALIFICATION[category];
    const eligible = requiredQual ? operators.filter(o => o.qualifications.has(requiredQual)) : operators;
    const sel = document.getElementById('task-new-assignee');
    const prior = sel.value;
    sel.innerHTML = '<option value="">— leave open —</option>' + eligible.map(o => `<option value="${o.user_id}" data-email="${esc(o.email)}">${esc(o.displayName)}</option>`).join('');
    sel.value = eligible.some(o => o.user_id === prior) ? prior : '';
    document.getElementById('task-new-due-field').style.display = sel.value ? 'block' : 'none';
  }
  refreshAssigneeOptions();
  document.getElementById('task-new-category').addEventListener('change', refreshAssigneeOptions);
  document.getElementById('task-new-assignee').addEventListener('change', e => {
    document.getElementById('task-new-due-field').style.display = e.target.value ? 'block' : 'none';
  });
  // Manually typing/changing a document ID also looks up its page count, same as the
  // "Create task" button from Messages does - only when the pages field is still empty, so it
  // never clobbers a value the coordinator already typed or that came in via prefill.
  document.getElementById('task-new-docid').addEventListener('change', async e => {
    const pagesField = document.getElementById('task-new-pages');
    const docId = e.target.value.trim();
    if (!docId || pagesField.value !== '') return;
    const { data } = await sb.from('documents').select('pages').eq('document_id', parseInt(docId, 10)).maybeSingle();
    if (data?.pages != null) pagesField.value = data.pages;
    recomputeCredits();
  });
  document.getElementById('task-new-submit').addEventListener('click', async () => {
    const title = document.getElementById('task-new-title').value.trim();
    if (!title) { alert('Please enter a title.'); return; }
    const docId = document.getElementById('task-new-docid').value.trim();
    const pages = document.getElementById('task-new-pages').value.trim();
    const baseCredits = parseInt(document.getElementById('task-new-base-credits').value, 10) || 0;
    const extraCredits = parseInt(document.getElementById('task-new-extra-credits').value, 10) || 0;
    const extraNote = document.getElementById('task-new-extra-note').value.trim();
    if (extraCredits !== 0 && !extraNote) { alert('Please explain why you are adding extra credits.'); return; }
    const assigneeSel = document.getElementById('task-new-assignee');
    const assigneeId = assigneeSel.value || null;
    const assigneeEmail = assigneeId ? assigneeSel.selectedOptions[0].dataset.email : null;
    const dueDate = document.getElementById('task-new-due').value || null;
    if (assigneeId && !dueDate) { alert('Please set a due date for the person you are assigning this to.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('tasks').insert({
      title, description: document.getElementById('task-new-desc').value.trim() || null,
      category: document.getElementById('task-new-category').value || null,
      document_id: docId ? parseInt(docId, 10) : null,
      document_pages: pages ? parseInt(pages, 10) : null,
      base_credits: baseCredits, extra_credits: extraCredits, extra_credits_note: extraNote || null,
      credits: baseCredits + extraCredits,
      created_by_email: user.email,
      status: assigneeId ? 'claimed' : 'open',
      claimed_by: assigneeId, claimed_by_email: assigneeEmail,
      claimed_at: assigneeId ? new Date().toISOString() : null,
      due_date: dueDate,
    }), 'Creating task...');
    const main = document.getElementById('main');
    await renderTasksView(main);
  });
}

const ACTIVE_STATUSES = ['claimed', 'submitted'];
const HISTORY_STATUSES = ['approved', 'rejected', 'published'];
const STATUS_LABELS = { submitted: 'Waiting for review', approved: 'Approved', rejected: 'Rejected', published: 'Published' };

async function refreshTasks(user, manage, operators) {
  const rows = await withStatus(sb.from('tasks').select('*').order('created_at', { ascending: false }));
  const nameMap = manage ? await nameMapForEmails(rows.flatMap(t => [t.claimed_by_email, t.created_by_email])) : {};

  const myClaimedDocTaskIds = rows.filter(t => t.status === 'claimed' && t.claimed_by === user.id && t.document_id).map(t => t.id);
  const candidateByTaskId = {};
  if (myClaimedDocTaskIds.length) {
    const candidates = await withStatus(sb.from('documents').select('document_id,source_task_id').in('source_task_id', myClaimedDocTaskIds));
    for (const c of candidates) candidateByTaskId[c.source_task_id] = c.document_id;
  }

  renderOpenList(rows.filter(t => t.status === 'open'));
  renderMineList(rows.filter(t => ACTIVE_STATUSES.includes(t.status) && t.claimed_by === user.id), candidateByTaskId);
  if (manage) renderTeamList(rows.filter(t => ACTIVE_STATUSES.includes(t.status) && t.claimed_by !== user.id), operators, nameMap);
  renderDoneList(rows.filter(t => HISTORY_STATUSES.includes(t.status)), manage, nameMap);
}

function docLine(t) {
  const parts = [];
  if (t.category) parts.push(esc(labelOf(State.optionListsByName.task_category || [], t.category)));
  if (t.document_id) parts.push(`Document #${esc(t.document_id)}`);
  if (t.document_pages != null) parts.push(`${esc(t.document_pages)} pages`);
  if (t.credits != null) parts.push(`${esc(t.credits)} credits`);
  return parts.length ? `<p class="hint">${parts.join(' · ')}</p>` : '';
}

function renderOpenList(rows) {
  const box = document.getElementById('tasks-open-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">No open tasks right now.</div>'; return; }
  box.innerHTML = rows.map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;">
      <b>${esc(t.title)}</b>
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      <div class="field-grid" style="max-width:320px;">
        <div class="field"><label>Your target due date</label><input class="task-claim-due" type="date"></div>
      </div>
      <div class="btn-row"><button class="btn task-claim-btn">Claim this task</button></div>
    </div>`).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    card.querySelector('.task-claim-btn').addEventListener('click', async () => {
      const due = card.querySelector('.task-claim-due').value;
      if (!due) { alert('Please set a target due date before claiming.'); return; }
      const { data: { user } } = await sb.auth.getUser();
      await withStatus(sb.from('tasks').update({
        status: 'claimed', claimed_by: user.id, claimed_by_email: user.email,
        claimed_at: new Date().toISOString(), due_date: due,
      }).eq('id', card.dataset.id), 'Claiming...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

// Opens the DRAFT correction (an operator's raw upload, still in Supabase Storage) for the
// given document_id - used for an operator double-checking their own upload, and for
// Admin/Revisor opening it while it's still a 'revision'/'pending_publish' candidate.
// storage_path/file_name are reserved for the FINAL PDF once published (see
// 50_two_step_publish_and_versioning.sql) - this never reads those.
async function downloadDraftFile(documentId) {
  const rows = await withStatus(sb.from('documents').select('draft_inp_path').eq('document_id', documentId));
  const draftPath = rows[0]?.draft_inp_path;
  if (!draftPath) { alert('No draft file on record for this document yet.'); return; }
  const { data } = await sb.storage.from(BUCKET).createSignedUrl(draftPath, 60);
  if (data?.signedUrl) window.open(data.signedUrl, '_blank');
}

// Downloading the ORIGINAL to correct is different: the real source material is the .inp
// file, living in the "INPAGE Original Document" Google Drive folder under its RENAMED name
// (renamed_inp_file_name, e.g. "12-ALE-..."), not the catalog's on-file PDF.
// original_inp_file_name keeps the historical un-prefixed name for reference only - it's not
// what's actually on Drive, so it's not used for the lookup itself. Falls back to whatever PDF
// we have in Storage when no renamed file is on record yet (better than nothing while the .inp
// archive is still being uploaded/renamed).
async function downloadOriginalForTask(documentId) {
  const rows = await withStatus(sb.from('documents').select('storage_path,renamed_inp_file_name').eq('document_id', documentId));
  const doc = rows[0];
  if (doc?.renamed_inp_file_name) { await downloadInpFromGDrive(doc.renamed_inp_file_name); return; }
  if (!doc?.storage_path) { alert('No .inp file on record yet for this document, and no PDF on file either.'); return; }
  const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
  if (data?.signedUrl) window.open(data.signedUrl, '_blank');
}

// Uploads a corrected file for a document-linked task: creates (or replaces) a sibling
// documents row - same work_id as the original, workflow_status 'revision' so it's invisible
// everywhere except to its own claimant and Coordinator/Admin (see 45_document_revision_
// workflow.sql) until a Revisor and then Admin approve it. Linked back via source_task_id,
// which is also how the Review queue finds it to offer "open the corrected file".
async function uploadCorrectedFile(task, file) {
  const origRows = await withStatus(sb.from('documents').select('*').eq('document_id', task.document_id));
  const orig = origRows[0];
  if (!orig) { alert('Original document not found.'); return; }
  const ext = (file.name.split('.').pop() || 'bin').toLowerCase();
  const draftPath = `draft-${task.document_id}-${task.id}-${Date.now()}.${ext}`;
  await withStatus(sb.storage.from(BUCKET).upload(draftPath, file, { upsert: true }), 'Uploading corrected file...');

  const existing = await withStatus(sb.from('documents').select('document_id,draft_inp_path').eq('source_task_id', task.id));
  if (existing.length) {
    const old = existing[0];
    if (old.draft_inp_path && old.draft_inp_path !== draftPath) await sb.storage.from(BUCKET).remove([old.draft_inp_path]);
    await withStatus(sb.from('documents').update({ draft_inp_path: draftPath }).eq('document_id', old.document_id), 'Replacing corrected file...');
  } else {
    const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
    const newId = (maxRows[0]?.document_id || 0) + 1;
    await withStatus(sb.from('documents').insert({
      document_id: newId, work_id: orig.work_id, title: orig.title, original_title: orig.original_title,
      ur_title: orig.ur_title, category: orig.category, author: orig.author, language: orig.language,
      workflow_status: 'revision', source_task_id: task.id, draft_inp_path: draftPath,
      is_preferred: false, legacy_migrated: false,
    }), 'Creating revision record...');
  }
}

function renderMineList(rows, candidateByTaskId) {
  const box = document.getElementById('tasks-mine-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">You have no claimed tasks. Check "Open tasks" above.</div>'; return; }
  box.innerHTML = rows.map(t => {
    const hasCandidate = !!candidateByTaskId[t.id];
    const needsFile = t.status === 'claimed' && t.document_id;
    return `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;${isOverdue(t) ? 'border-color:var(--danger);' : ''}">
      <b>${esc(t.title)}</b> ${isOverdue(t) ? '<span class="chat-tag" style="color:var(--danger);">Overdue</span>' : ''}
      ${t.status === 'submitted' ? '<span class="chat-tag">Waiting for review</span>' : ''}
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      ${t.status === 'claimed' ? `
        <p class="hint">Due ${formatDate(t.due_date)} <span class="hint">(fixed when you claimed it)</span></p>
        ${needsFile ? `
          <div class="btn-row">
            <button class="btn secondary task-mine-download">Download original file</button>
            <label class="btn secondary" style="cursor:pointer;">Upload corrected file<input type="file" class="task-mine-upload-input" accept=".inp,.doc,.docx,.pdf" style="display:none;"></label>
            ${hasCandidate ? '<button class="btn secondary task-mine-download-mine">Download my corrected file</button>' : ''}
          </div>
          <p class="hint">${hasCandidate ? 'Corrected file uploaded - you can still replace it above before submitting.' : 'Upload the corrected file before you can submit this for review.'}</p>` : ''}
        <div class="btn-row">
          <button class="btn task-mine-submit" ${needsFile && !hasCandidate ? 'disabled' : ''}>Submit for review</button>
          <button class="btn secondary task-mine-giveup">Give up this task</button>
        </div>` : '<p class="hint">A Revisor will look at this next - no action needed from you for now.</p>'}
    </div>`;
  }).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = card.dataset.id;
    const t = rows.find(r => String(r.id) === id);
    card.querySelector('.task-mine-download')?.addEventListener('click', () => downloadOriginalForTask(t.document_id));
    card.querySelector('.task-mine-download-mine')?.addEventListener('click', () => downloadDraftFile(candidateByTaskId[t.id]));
    card.querySelector('.task-mine-upload-input')?.addEventListener('change', async e => {
      const file = e.target.files[0];
      if (!file) return;
      await uploadCorrectedFile(t, file);
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-mine-submit')?.addEventListener('click', async () => {
      if (!confirm('Submit this task for review? You will not be able to make further changes.')) return;
      await withStatus(sb.from('tasks').update({ status: 'submitted', submitted_at: new Date().toISOString() }).eq('id', id), 'Submitting...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-mine-giveup')?.addEventListener('click', async () => {
      const note = prompt('Why are you giving up this task? A short line is fine - this is logged, but does not affect your standing.');
      if (note === null) return;
      if (!note.trim()) { alert('Please enter a reason.'); return; }
      await withStatus(sb.rpc('give_up_task', { p_task_id: parseInt(id, 10), p_note: note.trim() }), 'Giving up task...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

function renderTeamList(rows, operators, nameMap) {
  const box = document.getElementById('tasks-team-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">No one else has a claimed task right now.</div>'; return; }
  const repByUid = {};
  for (const o of operators) repByUid[o.user_id] = o.reputation;
  box.innerHTML = rows.map(t => {
    const rep = repByUid[t.claimed_by];
    const lowRep = rep != null && rep < LOW_REPUTATION_THRESHOLD;
    return `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;${isOverdue(t) || lowRep ? 'border-color:var(--danger);' : ''}">
      <div class="chat-meta"><b>${esc(t.title)}</b> · ${esc(nameMap[t.claimed_by_email] || t.claimed_by_email)} · due ${formatDate(t.due_date)} ${isOverdue(t) ? '<span class="chat-tag" style="color:var(--danger);">Overdue</span>' : ''} ${t.status === 'submitted' ? '<span class="chat-tag">Waiting for review</span>' : ''} ${lowRep ? `<span class="chat-tag" style="color:var(--danger);">Low reputation (${esc(rep)})</span>` : ''}</div>
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      ${t.status === 'claimed' ? `
        <div class="field-grid" style="max-width:320px;">
          <div class="field"><label>Reassign to</label>
            <select class="task-team-reassign"><option value="">— choose —</option>${operators.filter(o => o.user_id !== t.claimed_by && (!CATEGORY_REQUIRES_QUALIFICATION[t.category] || o.qualifications.has(CATEGORY_REQUIRES_QUALIFICATION[t.category]))).map(o => `<option value="${o.user_id}" data-email="${esc(o.email)}">${esc(o.displayName)}</option>`).join('')}</select>
          </div>
        </div>
        <div class="btn-row">
          <button class="btn secondary task-team-reassign-btn">Reassign</button>
          <button class="btn secondary task-team-free">Free up (back to open)</button>
          <button class="btn danger task-team-delete">Delete</button>
        </div>` : '<p class="hint">Submitted - waiting for a Revisor.</p>'}
    </div>`;
  }).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = card.dataset.id;
    card.querySelector('.task-team-reassign-btn')?.addEventListener('click', async () => {
      const sel = card.querySelector('.task-team-reassign');
      if (!sel.value) { alert('Choose someone to reassign this task to.'); return; }
      await withStatus(sb.from('tasks').update({
        claimed_by: sel.value, claimed_by_email: sel.selectedOptions[0].dataset.email, claimed_at: new Date().toISOString(),
      }).eq('id', id), 'Reassigning...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-team-free')?.addEventListener('click', async () => {
      const note = prompt('Why are you freeing up this task? (overdue with no response, inappropriate conduct, ...) This lowers the operator\'s reputation score.');
      if (note === null) return;
      await withStatus(sb.rpc('reclaim_task', { p_task_id: parseInt(id, 10), p_note: note || null }), 'Freeing up...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-team-delete')?.addEventListener('click', async () => {
      if (!confirm('Delete this task permanently?')) return;
      await withStatus(sb.from('tasks').delete().eq('id', id), 'Deleting...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

function renderDoneList(rows, manage, nameMap) {
  const box = document.getElementById('tasks-done-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing completed yet.</div>'; return; }
  // A straight Revisor "fail" already auto-spawns a retry task - only an Admin override
  // (rejected despite an ok/ok_but verdict) needs this manual follow-up, since that path is a
  // deliberate one-off decision rather than an automatic respawn.
  const needsRedo = t => manage && t.status === 'rejected' && t.review_verdict !== 'fail';
  box.innerHTML = rows.slice(0, 30).map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;">
      <div class="chat-meta">${esc(t.title)} · ${esc(nameMap[t.claimed_by_email] || t.claimed_by_email)} · ${esc(STATUS_LABELS[t.status] || t.status)}${t.review_verdict ? ` (${esc(t.review_verdict)})` : ''}</div>
      ${t.review_notes ? `<p class="hint">${esc(t.review_notes)}</p>` : ''}
      ${manage ? `<div class="btn-row">
        ${needsRedo(t) ? '<button class="btn secondary task-done-redo">Create task to redo this</button>' : ''}
        <button class="btn danger task-done-delete">Delete</button>
      </div>` : ''}
    </div>`).join('');
  if (manage) {
    box.querySelectorAll('[data-id]').forEach(card => {
      const t = rows.find(r => String(r.id) === card.dataset.id);
      card.querySelector('.task-done-redo')?.addEventListener('click', async () => {
        State.taskPrefill = {
          title: `${t.title} (redo - admin rejected)`,
          description: t.review_notes ? `Admin rejected the previous attempt. Note: ${t.review_notes}` : 'Admin rejected the previous attempt.',
          document_id: t.document_id,
          document_pages: t.document_pages,
        };
        await renderTasksView(document.getElementById('main'));
      });
      card.querySelector('.task-done-delete')?.addEventListener('click', async () => {
        if (!confirm('Delete this completed task permanently?')) return;
        await withStatus(sb.from('tasks').delete().eq('id', card.dataset.id), 'Deleting...');
        await renderTasksView(document.getElementById('main'));
      });
    });
  }
}

// ---------- Overdue / reassignment notifications ----------
// In-app only for now (Fase 2 scope) - shown once per login session, like the splash screen.
// Email reminders are a deliberately separate follow-up (needs an Edge Function + email
// provider, not just UI - see PROJECT_HANDOFF_v4.md §Fase 2).

function showTaskToast(title, message, onView) {
  document.querySelectorAll('.toast-notification').forEach(t => t.remove());
  const toast = document.createElement('div');
  toast.className = 'toast-notification';
  toast.innerHTML = `
    <div class="toast-title">${esc(title)}</div>
    <div class="toast-body">${esc(message)}</div>
    <div class="btn-row" style="margin:8px 0 0;">
      <button class="btn" id="task-toast-view-btn" style="padding:4px 10px;">View</button>
      <button class="btn secondary" id="task-toast-close-btn" style="padding:4px 10px;">Dismiss</button>
    </div>`;
  document.body.appendChild(toast);
  document.getElementById('task-toast-close-btn').addEventListener('click', () => toast.remove());
  document.getElementById('task-toast-view-btn').addEventListener('click', () => { toast.remove(); onView(); });
}

let taskNotifyChannel = null;

export async function initTaskNotifications(navigateToTasks) {
  if (taskNotifyChannel) { sb.removeChannel(taskNotifyChannel); taskNotifyChannel = null; }
  if (!canWrite()) return;
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return;

  if (!sessionStorage.getItem('tasksOverdueShown')) {
    sessionStorage.setItem('tasksOverdueShown', '1');
    const { data } = await sb.from('tasks').select('id').eq('claimed_by', user.id).eq('status', 'claimed').lt('due_date', today());
    if (data && data.length) showTaskToast('Overdue tasks', `You have ${data.length} overdue task${data.length > 1 ? 's' : ''}.`, navigateToTasks);
  }

  taskNotifyChannel = sb.channel('tasks-notify-' + user.id)
    .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'tasks', filter: `claimed_by=eq.${user.id}` }, payload => {
      if (payload.old.claimed_by !== user.id) showTaskToast('New task assigned', `"${payload.new.title}" was assigned to you.`, navigateToTasks);
    })
    .subscribe();
}
