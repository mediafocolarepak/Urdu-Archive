// Fase 2 di "Join the Team": bacheca di task, organizzata come un processo di lavoro in
// sotto-schede interne (vedi 2026-09-02 session): Tasks Store (spazio pubblico degli open
// task, uguale per tutti i ruoli inclusi Coordinator/Admin) -> claim -> My Tasks (i miei task
// in corso/in revisione/chiusi, con un ledger crediti calcolato al volo dagli
// task_outcome_events, non una tabella a parte) mentre Team overview/Review/Publish restano
// strumenti di gestione separati (Team e Review: Coordinator+Admin; Publish: solo Admin, è
// un'operazione tecnica). RLS impedisce di toccare un task preso da qualcun altro (vedi
// 34_task_store.sql) - i pulsanti qui sotto rispecchiano solo quel vincolo, non lo sostituiscono.

import { helpLinkHtml, popupShell, showGoodPracticesModal, sb, State, esc, today, canWrite, canReviewApplications, isAdmin, withStatus, nameMapForEmails, optionsHtml, labelOf, BUCKET, downloadInpFromGDrive, getDriveAccessToken, uploadInpToGDrive, computeFileName, uniqueFileName, nextDocumentId, confirmPopup, promptPopup, nameMapForIds, authorNames, errorText, archiveFileEnding, asArchiveFile, ARCHIVE_FILE_MAX } from './core.js?v=20261127163927';
import { documentSources, fileSource, documentPane, openDocument, wireSplit } from './desk.js?v=20261127163927';

function isOverdue(t) { return t.status === 'claimed' && t.due_date && t.due_date < today(); }
function formatDate(d) { return d ? esc(d) : '—'; }
function taskIdBadge(t) { return `<span style="position:absolute;top:10px;right:14px;font-size:12px;color:var(--muted,#666);">Task ID N. <b>${esc(t.id)}</b></span>`; }
function relativeDate(iso) {
  if (!iso) return '—';
  const days = Math.floor((Date.now() - new Date(iso).getTime()) / 86400000);
  if (days <= 0) return 'today';
  return days === 1 ? '1 day ago' : `${days} days ago`;
}

// Categories that gate visibility/assignment to a specific qualification - mirrors the case
// expression in operator_qualifies_for_category()/user_qualifies_for_category() in
// 37_task_qualifications_categories.sql. Keep the two in sync if the category list changes.
const CATEGORY_REQUIRES_QUALIFICATION = { IT_UR: 'TRANSLATOR', EN_UR: 'TRANSLATOR', UR_EN: 'TRANSLATOR', REVISION: 'REVISOR' };

// Below this, Team overview flags the operator in red so Coordinator/Admin notice and can have
// a human conversation - deliberately not an automatic block on anything (see 2026-08-31
// session notes: the team is volunteers, a silent auto-ban would be the wrong tone here).
const LOW_REPUTATION_THRESHOLD = 20;

const NEAR_DUE_DAYS = 3;
function daysTo(due) { return Math.round((new Date(due + 'T00:00') - new Date(today() + 'T00:00')) / 86400000); }
function stateHtml(t) {
  const st = (cls, sign, text) => `<span class="st st-${cls}"><span aria-hidden="true">${sign}</span> ${esc(text)}</span>`;
  const days = n => `${n} day${n === 1 ? '' : 's'}`;
  if (t.status === 'claimed' && t.due_date) {
    const d = daysTo(t.due_date);
    if (d < 0) return st('red', '&#9888;', `Overdue by ${days(-d)}`);
    if (d === 0) return st('amber', '&#9200;', 'Due today');
    if (d <= (State.policyValues?.task_near_due_days ?? NEAR_DUE_DAYS)) return st('amber', '&#9200;', `Due in ${days(d)}`);
    return st('blue', '&#9998;', `In progress, due in ${days(d)}`);
  }
  if (t.status === 'claimed') return st('blue', '&#9998;', 'In progress');
  if (t.status === 'submitted') return st('violet', '&#8987;', 'Waiting for review');
  if (t.status === 'approved') return st('green', '&#10003;', 'Approved');
  if (t.status === 'published') return st('green', '&#10003;', t.review_verdict === 'ok_but' ? 'Approved, with a remark' : 'Approved and closed');
  if (t.status === 'rejected') return st('red', '&#10005;', 'Not accepted');
  return st('grey', '', STATUS_LABELS[t.status] || t.status);
}
const stateClass = t => ({ red: 'st-red', amber: 'st-amber', blue: 'st-blue', violet: 'st-violet', green: 'st-green', grey: 'st-grey' })[(stateHtml(t).match(/st-(\w+)/) || [])[1]] || '';

const STATUS_LABELS = { claimed: 'In progress', submitted: 'Waiting for review', approved: 'Approved', rejected: 'Rejected', published: 'Published' };

async function fetchOperators() {
  const rows = await withStatus(sb.from('user_roles').select('user_id,email,reputation').in('role', ['operator', 'coordinator']).order('email'));
  const nameMap = await nameMapForEmails(rows.map(r => r.email));
  const qualRows = await withStatus(sb.from('user_qualifications').select('*'));
  const qualByUid = {};
  for (const q of qualRows) (qualByUid[q.user_id] ||= new Set()).add(q.qualification_code);
  return rows.map(r => ({ ...r, displayName: nameMap[r.email], qualifications: qualByUid[r.user_id] || new Set() }));
}

function docLine(t) {
  const parts = [];
  if (t.category) parts.push(esc(labelOf(State.optionListsByName.task_category || [], t.category)));
  if (t.document_id) parts.push(`Document #${esc(t.document_id)}`);
  if (t.document_pages != null) parts.push(`${esc(t.document_pages)} pages`);
  if (t.credits != null) parts.push(`${esc(t.credits)} credits`);
  return parts.length ? `<p class="hint">${parts.join(' · ')}</p>` : '';
}

function taskFacts(t) {
  return [t.credits != null ? `<b>${esc(t.credits)} credits</b>` : '', t.document_pages != null ? `${esc(t.document_pages)} page${t.document_pages === 1 ? '' : 's'}` : '', t.document_id ? `Document #${esc(t.document_id)}` : ''].filter(Boolean).join(' &middot; ');
}

// ---------- Entry point + inner tab bar ----------

let currentView = 'store';

export async function renderTasksView(main) {
  if (!canWrite()) { main.innerHTML = '<div class="empty-msg">Operator access required.</div>'; return; }
  const { data: { user } } = await sb.auth.getUser();
  const manage = canReviewApplications(); // same tier as Team Applications review: Coordinator + Admin
  const myQuals = await withStatus(sb.from('user_qualifications').select('qualification_code').eq('user_id', user.id));
  // Coordinator/Admin can act as Revisor without the tag (oversight tier - e.g. stepping in if
  // the queue backs up), same anonymization as an Operator holding the REVISOR qualification.
  const isRevisor = manage || myQuals.some(q => q.qualification_code === 'REVISOR');
  const admin = isAdmin();

  // A "Create task" from Messages, or "redo" from Team overview, stashes a prefill and jumps
  // here (see chat.js's startTaskFromMessage) - always land on Store, where the New task
  // popup lives, so the prefill actually gets seen.
  if (State.tasksView) { currentView = State.tasksView; State.tasksView = null; }
  if (State.taskPrefill) currentView = 'store';

  // One task has its own page and address (#task/51); a review too (#review/51).
  const sub = /^(task|review)\/(\d+)$/.exec(State.sub || '');
  if (sub && sub[1] === 'task') return renderTaskPage(main, sub[2], user);
  if (sub && sub[1] === 'review' && isRevisor) return renderReviewPage(main, sub[2]);

  const tabs = [{ id: 'store', label: 'Tasks Store' }, { id: 'mine', label: 'My Tasks' }];
  if (manage) tabs.push({ id: 'team', label: 'Team overview' });
  if (isRevisor) tabs.push({ id: 'review', label: 'Review Tasks' });
  if (admin) tabs.push({ id: 'publish', label: 'Publish Tasks' });
  if (admin) tabs.push({ id: 'withdrawn', label: 'Withdrawn Tasks' });
  if (admin) tabs.push({ id: 'budget', label: 'Budget' });
  if (!tabs.some(t => t.id === currentView)) currentView = 'store';

  main.innerHTML = `
    <div class="panel">
      <h2>Tasks ${helpLinkHtml('tasks')}</h2>
      <div class="btn-row" style="margin-bottom:0;">
        ${tabs.map(t => `<button class="btn ${t.id === currentView ? '' : 'secondary'} tasks-nav-btn" data-view="${t.id}" aria-pressed="${t.id === currentView}">${t.label}</button>`).join('')}
        ${State.currentRole === 'operator' ? '<button class="btn secondary" id="tasks-good-practices">Good practices</button>' : ''}
      </div>
    </div>
    <div id="tasks-body"></div>`;
  document.getElementById('tasks-good-practices')?.addEventListener('click', showGoodPracticesModal);
  main.querySelectorAll('.tasks-nav-btn').forEach(b => b.addEventListener('click', () => {
    currentView = b.dataset.view;
    renderTasksView(main);
  }));

  const body = document.getElementById('tasks-body');
  if (currentView === 'store') await renderStoreView(body, manage, admin, user);
  else if (currentView === 'mine') await renderMineView(body, user);
  else if (currentView === 'team') await renderTeamView(body);
  else if (currentView === 'review') await renderReviewViewBody(body);
  else if (currentView === 'publish') await renderPublishViewBody(body);
  else if (currentView === 'withdrawn') await renderWithdrawnView(body);
  else if (currentView === 'budget') await renderBudgetView(body);
}

// ---------- Tasks Store: public, same for every role - free tasks to claim ----------

async function renderStoreView(body, manage, admin, user) {
  const [rows, inProgress] = await Promise.all([
    withStatus(sb.from('tasks').select('*').eq('status', 'open').order('created_at', { ascending: false })), myTasksNow(user),
  ]);
  let sortDesc = true, chosen = null;

  body.innerHTML = `
    <div class="store-filters">
      <div class="field"><label for="store-category">Kind of work</label><select id="store-category">${optionsHtml(State.optionListsByName.task_category || [], '', true, 'All')}</select></div>
      ${manage ? '<div class="field"><label>&nbsp;</label><button class="btn" id="store-new-task-btn">+ New task</button></div>' : ''}
    </div>
    <details class="store-more"><summary>More options</summary><div class="store-filters">
      <div class="field"><label for="store-mincredits">Credits, at least</label><input id="store-mincredits" type="number" min="0"></div>
      <div class="field"><label for="store-sort-btn">Order</label><button class="btn secondary" id="store-sort-btn">Newest first</button></div></div></details>
    <div class="task-two"><div class="task-list task-cards" id="store-rows"></div><div class="task-side" id="store-side"></div></div>`;

  const side = document.getElementById('store-side');
  function choose(t) {
    chosen = t;
    document.querySelectorAll('#store-rows .task-card').forEach(c => c.classList.toggle('task-chosen', !!t && c.dataset.id === String(t.id)));
    if (t) { side.scrollTop = 0; mountTake(side, t, user, inProgress); } else side.innerHTML = '';
  }
  function applyAndRender() {
    const cat = document.getElementById('store-category').value;
    const minCredits = parseInt(document.getElementById('store-mincredits').value, 10) || 0;
    const filtered = rows
      .filter(t => (!cat || t.category === cat) && (t.credits || 0) >= minCredits)
      .sort((a, b) => sortDesc ? new Date(b.created_at) - new Date(a.created_at) : new Date(a.created_at) - new Date(b.created_at));
    const list = document.getElementById('store-rows');
    if (!filtered.length) { list.innerHTML = `<div class="empty-msg">${rows.length ? 'No task of this kind now.' : 'There are no tasks to take now.'}</div>`; choose(null); return; }
    list.innerHTML = filtered.map(t => `
      <div class="task-card" data-id="${t.id}">
        <div class="task-card-top"><span class="task-kind">${esc(taskKind(t)) || 'Task'}</span><span>#${esc(t.id)} &middot; ${relativeDate(t.created_at)}</span></div>
        <div class="task-card-title" dir="auto">${esc(t.title)}</div>
        <div class="task-card-facts">${taskFacts(t)}</div>
        <div class="btn-row"><button class="btn store-open-btn">Look at it</button>${admin ? '<button class="btn danger store-withdraw-btn">Withdraw</button>' : ''}</div>
      </div>`).join('');
    list.querySelectorAll('.task-card').forEach(card => {
      const t = filtered.find(x => String(x.id) === card.dataset.id);
      const open = () => (wide() ? choose(t) : openTask(t.id));
      card.querySelector('.store-open-btn').addEventListener('click', open);
      card.addEventListener('click', e => { if (!e.target.closest('button')) open(); });
      card.querySelector('.store-withdraw-btn')?.addEventListener('click', async () => {
        if (!await confirmPopup(`Withdraw "${t.title}" from the Store? It moves to Withdrawn Tasks, where it can be put back later.`)) return;
        await withStatus(sb.from('tasks').update({ status: 'withdrawn' }).eq('id', t.id), 'Withdrawing...');
        await renderTasksView(document.getElementById('main'));
      });
    });
    if (wide()) choose(filtered.find(t => chosen && t.id === chosen.id) || filtered[0]);
  }

  document.getElementById('store-category').addEventListener('change', applyAndRender);
  document.getElementById('store-mincredits').addEventListener('input', applyAndRender);
  document.getElementById('store-sort-btn').addEventListener('click', () => {
    sortDesc = !sortDesc;
    document.getElementById('store-sort-btn').textContent = sortDesc ? 'Newest first' : 'Oldest first';
    applyAndRender();
  });
  applyAndRender();

  if (manage) {
    const operators = await fetchOperators();
    document.getElementById('store-new-task-btn').addEventListener('click', () => openNewTaskPopup(operators));
    if (State.taskPrefill) openNewTaskPopup(operators);
  }
}

// Taking and sending a task go through claim_task() and submit_task() (165_task_doors.sql), which check everything and
// say what is wrong. Until 165 has been run they are not there: the old direct change. True if it was done.
async function taskStep(fn, args, oldWay, busyText) {
  try {
    await withStatus(sb.rpc(fn, args), busyText);
    return true;
  } catch (e) {
    if (e.code !== 'PGRST202') { alert(e.message); return false; }
  }
  await withStatus(oldWay(), busyText);
  return true;
}

// ---------- The desk (Owner's decision, 2026-11-25; desk.js): a task is one place, with the document beside the work ----------

const wide = () => window.matchMedia('(min-width: 1000px)').matches;
const openTask = (id, kind = 'task') => window.__renderTab('tasks', State.currentRole === 'operator' ? 'work' : undefined, `${kind}/${id}`);
const backToTasks = view => { if (view) { currentView = view; } window.__renderTab('tasks', State.currentRole === 'operator' ? 'work' : undefined); };
const taskKind = t => labelOf(State.optionListsByName.task_category || [], t.category) || '';
const plusDays = n => { const d = new Date(); d.setDate(d.getDate() + n); return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0'); };
const limitNow = () => State.policyValues?.task_max_in_progress ?? 3;
// What step 2 is called: the work itself, in plain words.
const WORK_WORDS = { IT_UR: ['Translate it', 'From Italian to Urdu, in Word or InPage, on your computer.'], EN_UR: ['Translate it', 'From English to Urdu, in Word or InPage, on your computer.'], UR_EN: ['Translate it', 'From Urdu to English, in Word, on your computer.'],
  TYPING: ['Type it', 'In Word or InPage, on your computer.'], PROOFREAD: ['Read and correct it', 'In Word or InPage, on your computer.'], REVISION: ['Read and correct it', 'In Word or InPage, on your computer.'] };
const workWords = t => WORK_WORDS[t.category] || ['Do the work', 'On your computer.'];

function factsHtml(t) {
  return `<div class="desk-facts">${[taskKind(t) && esc(taskKind(t)), t.document_pages != null && `${esc(t.document_pages)} page${t.document_pages === 1 ? '' : 's'}`, t.credits != null && `<b>${esc(t.credits)} credits</b>`, t.document_id && `Document #${esc(t.document_id)}`].filter(Boolean).map(x => `<span>${x}</span>`).join('')}</div>`;
}
function openFor(t) { const d = Math.floor((Date.now() - new Date(t.created_at).getTime()) / 86400000); return d > 0 ? `Open for ${d} day${d === 1 ? '' : 's'}` : 'New today'; }
function infoCard(t, state = stateHtml(t)) {
  return `<div class="panel desk-info">${state}<div class="desk-title" dir="auto">${esc(t.title)}</div>${t.description ? `<p style="white-space:pre-wrap;margin:6px 0 0;" dir="auto">${esc(t.description)}</p>` : ''}${factsHtml(t)}</div>`;
}
function headHtml(back, note) {
  return `<div class="desk-head"><button type="button" class="btn secondary" id="desk-back">&lsaquo; ${esc(back)}</button><span class="desk-head-title">${esc(note)}</span></div>`;
}
// The two halves. With no document there is only the work.
function deskHtml(head, hasDoc, work) {
  return `${head}<div class="desk${hasDoc ? '' : ' desk-alone'}">${hasDoc ? '<div class="desk-doc" id="desk-doc"></div><div class="desk-split" role="separator" aria-orientation="vertical" aria-label="Make one side wider" tabindex="0"><span aria-hidden="true">&#8942;</span></div>' : ''}<div class="desk-work" id="desk-work">${work}</div></div>`;
}
// Beside the work on a computer; behind one button on a phone.
function mountDocument(main, sources, first) {
  const box = main.querySelector('#desk-doc');
  let pane = null;
  if (box && sources.length) {
    const open = () => { if (!pane && wide()) { pane = documentPane(box, sources); pane.show(first && pane.keys.includes(first) ? first : pane.keys[0]); } };
    open();
    window.addEventListener('resize', function onResize() { if (!box.isConnected) window.removeEventListener('resize', onResize); else open(); });
    wireSplit(main.querySelector('.desk'));
  } else main.querySelector('.desk')?.classList.add('desk-alone');
  main.querySelectorAll('.desk-open-doc').forEach(b => { if (!sources.length) b.remove(); else b.addEventListener('click', () => openDocument(sources, b.dataset.key || sources[0].key)); });
  return { refresh: key => pane?.refresh(key), show: key => (pane && wide() ? pane.show(key) : openDocument(sources, key)) };
}
const draftOf = async taskId => (await withStatus(sb.from('documents').select('document_id,draft_inp_path,workflow_status').eq('source_task_id', taskId)))[0] || null;

async function renderTaskPage(main, id, user) {
  const t = (await withStatus(sb.from('tasks').select('*').eq('id', id)))[0];
  if (!t) {
    main.innerHTML = `<div class="panel"><p>This task is not here any more, or it is not for you.</p><div class="btn-row"><button class="btn" id="desk-back">Tasks</button></div></div>`;
    main.querySelector('#desk-back').addEventListener('click', () => backToTasks());
    return;
  }
  if (t.status === 'open') return renderOpenTask(main, t, user);
  if (t.claimed_by === user.id && t.status === 'claimed') return renderMyDesk(main, t, user);
  return renderTaskState(main, t, user);
}

// ---------- A task to take ----------

async function myTasksNow(user) {
  return (await withStatus(sb.from('tasks').select('id').eq('claimed_by', user.id).eq('status', 'claimed'))).length;
}
// The part that takes a task: used beside the list on a computer, and on the page of the task.
function mountTake(box, t, user, inProgress) {
  const full = inProgress >= limitNow();
  box.innerHTML = `
    ${infoCard(t, `<span class="st st-grey">${openFor(t)}</span>`)}
    ${t.document_id ? '<div class="btn-row"><button class="btn secondary" data-look>Look at the document</button></div>' : ''}
    <div class="panel">
      ${full ? `<p style="margin:0;"><b>You have ${inProgress} task${inProgress === 1 ? '' : 's'} in progress.</b> Send one, or return one, and then you can take this.</p><div class="btn-row"><button class="btn secondary" data-mine>My Tasks</button></div>` : `
      <div class="field"><label for="take-due">When can you finish it?</label>
        <div class="quick-dates" role="group" aria-label="When can you finish it?">${[[7, '1 week'], [14, '2 weeks'], [30, '1 month']].map(([n, l]) => `<button type="button" class="btn secondary" data-days="${n}" aria-pressed="false">${l}</button>`).join('')}</div>
        <input id="take-due" type="date" min="${today()}" style="max-width:240px;">
        <div class="hint">The date does not change. If you cannot finish, return the task: it costs nothing.</div></div>
      <div class="btn-row"><button class="btn big-btn" data-take>Take this task</button></div>`}
    </div>`;
  box.querySelector('[data-mine]')?.addEventListener('click', () => backToTasks('mine'));
  box.querySelector('[data-look]')?.addEventListener('click', async () => {
    const sources = await documentSources(t.document_id);
    if (!sources.length) { alert('There is nothing to look at for this document yet.'); return; }
    openDocument(sources);
  });
  if (full) return;
  const due = box.querySelector('#take-due');
  const marks = () => box.querySelectorAll('[data-days]').forEach(b => b.setAttribute('aria-pressed', String(due.value === plusDays(+b.dataset.days))));
  box.querySelectorAll('[data-days]').forEach(b => b.addEventListener('click', () => { due.value = plusDays(+b.dataset.days); marks(); }));
  due.addEventListener('input', marks);
  box.querySelector('[data-take]').addEventListener('click', async e => {
    if (!due.value) { alert('Please choose the date.'); return; }
    if (due.value < today()) { alert('Please choose a date from today on.'); return; }
    e.target.disabled = true;
    const done = await taskStep('claim_task', { p_task_id: t.id, p_due_date: due.value }, () => sb.from('tasks').update({
      status: 'claimed', claimed_by: user.id, claimed_by_email: user.email, claimed_at: new Date().toISOString(), due_date: due.value,
    }).eq('id', t.id), 'Taking the task...');
    e.target.disabled = false;
    if (done) { currentView = 'mine'; State.mineTab = 'active'; openTask(t.id); } else if (!State.sub) renderTasksView(document.getElementById('main'));
  });
}
async function renderOpenTask(main, t, user) {
  const inProgress = await myTasksNow(user);
  main.innerHTML = `${headHtml('Tasks Store', 'Task ' + t.id)}<div class="desk-one" id="take-box"></div>`;
  main.querySelector('#desk-back').addEventListener('click', () => backToTasks('store'));
  mountTake(main.querySelector('#take-box'), t, user, inProgress);
}

// ---------- A task of mine, in progress ----------

const gotKey = t => `taskGot_${t.id}`;
async function renderMyDesk(main, t, user) {
  const sources = await documentSources(t.document_id);
  if (t.document_id) sources.push(fileSource('mine', 'My file', async () => (await draftOf(t.id))?.draft_inp_path || null));
  main.innerHTML = deskHtml(headHtml('My Tasks', 'Task ' + t.id), sources.length > 0, '<div class="hint">Loading...</div>');
  main.querySelector('#desk-back').addEventListener('click', () => backToTasks('mine'));
  const work = main.querySelector('#desk-work');
  let pane = null;

  const draw = async () => {
    const draft = t.document_id ? await draftOf(t.id) : null;
    const got = !!draft || !!localStorage.getItem(gotKey(t));
    const [name, how] = workWords(t);
    const step = (n, state, title, body) => `<div class="desk-step desk-${state}"><span class="desk-num" aria-hidden="true">${state === 'done' ? '&#10003;' : n}</span><div><b>${title}${state === 'done' ? ' <span class="sr-only">(done)</span>' : ''}</b>${body}</div></div>`;
    const fileName = draft ? `${esc((draft.draft_inp_path || '').split('.').pop().toUpperCase())} file` : '';
    const kinds = '.inp, .doc, .docx, .pdf &middot; up to 50 MB';
    const steps = t.document_id ? [
      step(1, got ? 'done' : 'now', 'Get the file', `<div class="btn-row"><button class="btn ${got ? 'secondary' : ''}" data-get>${got ? 'Get it again' : 'Get the file'}</button></div>`),
      step(2, draft ? 'done' : got ? 'now' : 'later', name, `<div class="hint">${how}</div>`),
      step(3, draft ? 'done' : got ? 'now' : 'later', 'Upload your file', draft
        ? `<div class="desk-file"><span aria-hidden="true">&#128196;</span><div><b>Your ${fileName} is here</b></div></div><div class="btn-row"><button class="btn secondary" data-see>Look at it</button><label class="btn secondary" style="cursor:pointer;">Replace it<input type="file" data-file accept=".inp,.doc,.docx,.pdf" hidden></label></div>`
        : `<div class="desk-drop" data-drop><div class="desk-drop-drag">Drag your file here, or</div><label class="btn ${got ? '' : 'secondary'}" style="cursor:pointer;">Choose the file<input type="file" data-file accept=".inp,.doc,.docx,.pdf" hidden></label><div class="hint">${kinds}</div></div>`),
      step(4, draft ? 'now' : 'later', 'Send for review', `<div class="hint">After this you cannot change it.</div><div class="btn-row"><button class="btn big-btn" data-send ${draft ? '' : 'disabled'}>Send for review</button></div>`),
    ] : [
      step(1, 'now', name, `<div class="hint">${how}</div>`),
      step(2, 'now', 'Send for review', '<div class="hint">After this you cannot change it.</div><div class="btn-row"><button class="btn big-btn" data-send>Send for review</button></div>'),
    ];
    work.innerHTML = `${infoCard(t)}
      ${sources.length ? '<div class="btn-row desk-phone"><button class="btn secondary desk-open-doc">Look at the document</button></div>' : ''}
      <div class="panel desk-steps">${steps.join('')}</div>
      <p class="hint">You cannot finish? <button type="button" class="desk-return" data-return>Return this task</button> It costs nothing.</p>
      <div class="desk-bottom"><button type="button" class="btn big-btn" data-bottom>${t.document_id && !draft ? (got ? 'Choose the file' : 'Get the file') : 'Send for review'}</button></div>`;
    if (pane === null) pane = mountDocument(main, sources);
    else work.querySelectorAll('.desk-open-doc').forEach(b => b.addEventListener('click', () => openDocument(sources, sources[0].key)));

    // On a phone the button of this moment stays at the bottom of the screen.
    work.querySelector('[data-bottom]').addEventListener('click', () => work.querySelector(t.document_id && !draft ? (got ? '[data-file]' : '[data-get]') : '[data-send]').click());
    work.querySelector('[data-get]')?.addEventListener('click', async () => { await downloadOriginalForTask(t.document_id); try { localStorage.setItem(gotKey(t), '1'); } catch { /* only the tick is lost */ } draw(); });
    work.querySelector('[data-see]')?.addEventListener('click', () => pane.show('mine'));
    const take = async file => {
      if (!file) return;
      try { await uploadCorrectedFile(t, file); } catch (err) { alert(errorText(err)); }
      pane.refresh('mine');
      await draw();
    };
    work.querySelectorAll('[data-file]').forEach(i => i.addEventListener('change', e => take(e.target.files[0])));
    const drop = work.querySelector('[data-drop]');
    if (drop) {
      drop.addEventListener('dragover', e => { e.preventDefault(); drop.classList.add('desk-over'); });
      drop.addEventListener('dragleave', () => drop.classList.remove('desk-over'));
      drop.addEventListener('drop', e => { e.preventDefault(); drop.classList.remove('desk-over'); take(e.dataTransfer.files[0]); });
    }
    work.querySelector('[data-send]')?.addEventListener('click', async () => {
      if (!await confirmPopup('Send this task for review? After this you cannot change it.', { confirmLabel: 'Send for review', cancelLabel: 'Not yet' })) return;
      const done = await taskStep('submit_task', { p_task_id: t.id }, () => sb.from('tasks').update({ status: 'submitted', submitted_at: new Date().toISOString() }).eq('id', t.id), 'Sending...');
      if (!done) return;
      try { localStorage.removeItem(gotKey(t)); } catch { /* nothing to clean */ }
      State.mineTab = 'submitted';
      backToTasks('mine');
      alert('Sent. Thank you! A Revisor will look at it.');
    });
    work.querySelector('[data-return]').addEventListener('click', async () => {
      const note = await promptPopup('Why do you return this task? One line is enough. It does not change your reputation.');
      if (note === null) return;
      if (!note.trim()) { alert('Please write one line.'); return; }
      await withStatus(sb.rpc('give_up_task', { p_task_id: t.id, p_note: note.trim() }), 'Returning the task...');
      backToTasks('mine');
    });
  };
  // A file dropped beside the box must not open in place of the app.
  main.querySelector('.desk').addEventListener('dragover', e => e.preventDefault());
  main.querySelector('.desk').addEventListener('drop', e => e.preventDefault());
  await draw();
}

// ---------- A task sent, closed, or of someone else (Coordinators and Admins) ----------

async function renderTaskState(main, t, user) {
  const mine = t.claimed_by === user.id;
  const [sources, draft] = await Promise.all([documentSources(t.document_id), t.document_id ? draftOf(t.id) : null]);
  if (draft?.draft_inp_path) sources.unshift(fileSource('mine', mine ? 'My file' : 'The file', draft.draft_inp_path));
  const who = mine || !t.claimed_by ? '' : (await nameMapForIds([t.claimed_by]))[t.claimed_by];
  const work = `${infoCard(t)}
    ${who ? `<p class="hint">Taken by ${esc(who)}${t.due_date ? `, until ${formatDate(t.due_date)}` : ''}</p>` : ''}
    ${t.status === 'submitted' ? `<div class="panel"><p style="margin:0;">Sent ${relativeDate(t.submitted_at)}. A Revisor will look at it. There is nothing you need to do.</p></div>` : ''}
    ${t.status === 'approved' ? '<div class="panel"><p style="margin:0;">The Revisor has approved it. An Admin closes it, and then the credits arrive.</p></div>' : ''}
    ${t.status === 'published' && t.credits != null ? `<div class="panel st-green desk-result"><b>+${esc(t.credits)} credits</b></div>` : ''}
    ${t.review_notes ? `<div class="panel"><b>The Revisor's note</b><p style="white-space:pre-wrap;margin:6px 0 0;" dir="auto">${esc(t.review_notes)}</p></div>` : ''}
    ${sources.length ? '<div class="btn-row desk-phone"><button class="btn secondary desk-open-doc">Look at the document</button></div>' : ''}`;
  const back = mine ? 'My Tasks' : 'Tasks';
  main.innerHTML = deskHtml(headHtml(back, 'Task ' + t.id), sources.length > 0, work);
  main.querySelector('#desk-back').addEventListener('click', () => backToTasks(mine ? 'mine' : undefined));
  mountDocument(main, sources);
}

function openNewTaskPopup(operators) {
  document.getElementById('new-task-popup')?.remove();
  // Consumed once: a "Create task" click from the Messages inbox (chat.js) or a "redo" from
  // Team overview stashes a prefill here via State, then hands off to this popup.
  const prefill = State.taskPrefill;
  State.taskPrefill = null;

  const { panel, close } = popupShell('new-task-popup', { width: 680, label: 'New task', section: 'tasks' });

  panel.innerHTML = `
    <h2 style="margin-top:0;">New task</h2>
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
      <div class="field" id="task-new-extra-note-field" style="display:none;grid-column:1/-1;"><label>Why the extra credits? <span class="hint">(required if not zero)</span></label><select id="task-new-extra-note">${optionsHtml(State.optionListsByName.extra_credit_reason || [], '', true)}</select></div>
      <div class="field" id="task-new-extra-approval-hint" style="display:none;grid-column:1/-1;"><span class="hint">This amount is above the Coordination-lead approval threshold - the task can be created, claimed and worked as usual, but can't be given a passing review verdict (its credits can't be paid out) until the Coordination lead approves it.</span></div>
      <div class="field" style="grid-column:1/-1;"><label>Total credits</label><div id="task-new-total-credits" style="font-size:14px;font-weight:600;padding:4px 0;">0</div></div>
      <div class="field"><label>Assign directly to <span class="hint">(optional — otherwise left open to claim; list narrows to who's qualified once a category is picked)</span></label>
        <select id="task-new-assignee"></select>
      </div>
      <div class="field" id="task-new-due-field" style="display:none;"><label>Due date</label><input id="task-new-due" type="date"></div>
    </div>
    <div class="btn-row"><button class="btn" id="task-new-submit">Create task</button><button class="btn secondary" id="task-new-cancel">Cancel</button></div>`;

  panel.querySelector('#task-new-cancel').addEventListener('click', close);

  let categoryRates = {};
  sb.from('task_category_rates').select('*').then(({ data }) => {
    categoryRates = Object.fromEntries((data || []).map(r => [r.category, r.credits_per_page]));
    recomputeCredits();
  });

  function recomputeCredits() {
    const category = panel.querySelector('#task-new-category').value;
    const pages = parseFloat(panel.querySelector('#task-new-pages').value) || 0;
    const rate = categoryRates[category] || 0;
    const base = Math.round(rate * pages);
    panel.querySelector('#task-new-base-credits').value = base;
    const extra = parseInt(panel.querySelector('#task-new-extra-credits').value, 10) || 0;
    panel.querySelector('#task-new-total-credits').textContent = base + extra;
    panel.querySelector('#task-new-extra-note-field').style.display = extra !== 0 ? 'block' : 'none';
    // Client-side preview only - extra_credit_needs_approval() in the DB is what's actually
    // enforced (migration 90), this just avoids surprising the Coordinator after the fact.
    const pctThreshold = State.policyValues.extra_credit_pct_threshold ?? 30;
    const absThreshold = State.policyValues.extra_credit_abs_threshold ?? 10;
    const needsApproval = extra > Math.min(base * pctThreshold / 100, absThreshold);
    panel.querySelector('#task-new-extra-approval-hint').style.display = needsApproval ? 'block' : 'none';
  }
  panel.querySelector('#task-new-pages').addEventListener('input', recomputeCredits);
  panel.querySelector('#task-new-extra-credits').addEventListener('input', recomputeCredits);
  panel.querySelector('#task-new-category').addEventListener('change', recomputeCredits);
  function refreshAssigneeOptions() {
    const category = panel.querySelector('#task-new-category').value;
    const requiredQual = CATEGORY_REQUIRES_QUALIFICATION[category];
    const eligible = requiredQual ? operators.filter(o => o.qualifications.has(requiredQual)) : operators;
    const sel = panel.querySelector('#task-new-assignee');
    const prior = sel.value;
    sel.innerHTML = '<option value="">— leave open —</option>' + eligible.map(o => `<option value="${o.user_id}" data-email="${esc(o.email)}">${esc(o.displayName)}</option>`).join('');
    sel.value = eligible.some(o => o.user_id === prior) ? prior : '';
    panel.querySelector('#task-new-due-field').style.display = sel.value ? 'block' : 'none';
  }
  refreshAssigneeOptions();
  panel.querySelector('#task-new-category').addEventListener('change', refreshAssigneeOptions);
  panel.querySelector('#task-new-assignee').addEventListener('change', e => {
    panel.querySelector('#task-new-due-field').style.display = e.target.value ? 'block' : 'none';
  });
  // Manually typing/changing a document ID also looks up its page count, same as the
  // "Create task" button from Messages does - only when the pages field is still empty, so it
  // never clobbers a value the coordinator already typed or that came in via prefill.
  panel.querySelector('#task-new-docid').addEventListener('change', async e => {
    const pagesField = panel.querySelector('#task-new-pages');
    const docId = e.target.value.trim();
    if (!docId || pagesField.value !== '') return;
    const { data } = await sb.from('documents').select('pages').eq('document_id', parseInt(docId, 10)).maybeSingle();
    if (data?.pages != null) pagesField.value = data.pages;
    recomputeCredits();
  });
  panel.querySelector('#task-new-submit').addEventListener('click', async () => {
    const title = panel.querySelector('#task-new-title').value.trim();
    if (!title) { alert('Please enter a title.'); return; }
    const docId = panel.querySelector('#task-new-docid').value.trim();
    const pages = panel.querySelector('#task-new-pages').value.trim();
    const baseCredits = parseInt(panel.querySelector('#task-new-base-credits').value, 10) || 0;
    const extraCredits = parseInt(panel.querySelector('#task-new-extra-credits').value, 10) || 0;
    const extraNote = panel.querySelector('#task-new-extra-note').value.trim();
    if (extraCredits !== 0 && !extraNote) { alert('Please explain why you are adding extra credits.'); return; }
    const assigneeSel = panel.querySelector('#task-new-assignee');
    const assigneeId = assigneeSel.value || null;
    const dueDate = panel.querySelector('#task-new-due').value || null;
    if (assigneeId && !dueDate) { alert('Please set a due date for the person you are assigning this to.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('tasks').insert({
      title, description: panel.querySelector('#task-new-desc').value.trim() || null,
      category: panel.querySelector('#task-new-category').value || null,
      document_id: docId ? parseInt(docId, 10) : null,
      document_pages: pages ? parseInt(pages, 10) : null,
      base_credits: baseCredits, extra_credits: extraCredits, extra_credits_note: extraNote || null,
      credits: baseCredits + extraCredits,
      created_by_email: user.email,
      status: assigneeId ? 'claimed' : 'open',
      claimed_by: assigneeId,
      claimed_at: assigneeId ? new Date().toISOString() : null,
      due_date: dueDate,
    }), 'Creating task...');
    close();
    await renderTasksView(document.getElementById('main'));
  });
}

// ---------- My Tasks: personal queue (any role) + a computed credits ledger ----------

async function renderMineView(body, user) {
  const rows = await withStatus(sb.from('tasks').select('*').eq('claimed_by', user.id).order('created_at', { ascending: false }));
  const active = rows.filter(t => t.status === 'claimed');
  const submitted = rows.filter(t => t.status === 'submitted');
  const closed = rows.filter(t => ['approved', 'rejected', 'published'].includes(t.status));
  const MINE_TABS = [['active', 'In progress', active.length], ['submitted', 'Waiting for review', submitted.length], ['closed', 'Closed', closed.length]];
  if (!MINE_TABS.some(([id]) => id === State.mineTab)) State.mineTab = 'active';

  body.innerHTML = `
    <div class="btn-row"><button class="btn secondary" id="mine-credits-btn">My credits</button></div>
    <div id="mine-ledger" style="display:none;margin-top:12px;"></div>
    <div class="btn-row" style="margin:16px 0 0;flex-wrap:wrap;">
      ${MINE_TABS.map(([id, label, count]) => `<button class="btn ${id === State.mineTab ? '' : 'secondary'} mine-tab-btn" data-tab="${id}">${label} <span class="count-badge">${count}</span></button>`).join('')}
    </div>
    <div id="mine-active-section" style="${State.mineTab === 'active' ? '' : 'display:none;'}"><div id="mine-active-list"></div></div>
    <div id="mine-submitted-section" style="${State.mineTab === 'submitted' ? '' : 'display:none;'}"><div id="mine-submitted-list"></div></div>
    <div id="mine-closed-section" style="${State.mineTab === 'closed' ? '' : 'display:none;'}"><div id="mine-closed-list"></div></div>`;

  renderMineActiveList(active);
  renderMineSubmittedList(submitted);
  renderMineClosedList(closed);

  document.getElementById('mine-credits-btn').addEventListener('click', () => toggleLedger(user));
  // Tab switch just toggles which already-rendered section is visible - all three are cheap and
  // already fetched together above, so there's no need to re-query on every click.
  body.querySelectorAll('.mine-tab-btn').forEach(btn => btn.addEventListener('click', () => {
    State.mineTab = btn.dataset.tab;
    document.getElementById('mine-active-section').style.display = State.mineTab === 'active' ? '' : 'none';
    document.getElementById('mine-submitted-section').style.display = State.mineTab === 'submitted' ? '' : 'none';
    document.getElementById('mine-closed-section').style.display = State.mineTab === 'closed' ? '' : 'none';
    body.querySelectorAll('.mine-tab-btn').forEach(b => b.classList.toggle('secondary', b.dataset.tab !== State.mineTab));
  }));
}

async function toggleLedger(user) {
  const box = document.getElementById('mine-ledger');
  if (box.style.display === 'block') { box.style.display = 'none'; return; }
  box.style.display = 'block';
  box.innerHTML = '<div class="hint">Loading...</div>';
  const [events, pending, redeemed] = await Promise.all([
    withStatus(sb.from('task_outcome_events').select('credit_delta').eq('user_id', user.id)),
    withStatus(sb.from('tasks').select('credits').eq('claimed_by', user.id).in('status', ['claimed', 'submitted', 'approved'])),
    withStatus(sb.from('tasks').select('credits').eq('claimed_by', user.id).eq('status', 'published')),
  ]);
  const earned = events.reduce((sum, e) => sum + (e.credit_delta || 0), 0);
  const inProgress = pending.reduce((sum, t) => sum + (t.credits || 0), 0);
  const redeemedTotal = redeemed.reduce((sum, t) => sum + (t.credits || 0), 0);
  box.innerHTML = `
    <div class="panel">
      <div class="field-grid">
        <div class="field"><label>Earned</label><div style="font-size:20px;font-weight:600;">${esc(earned)}</div></div>
        <div class="field"><label>In progress <span class="hint">(if approved)</span></label><div style="font-size:20px;font-weight:600;">${esc(inProgress)}</div></div>
        <div class="field"><label>Of tasks closed <span class="hint">(not a payment)</span></label><div style="font-size:20px;font-weight:600;">${esc(redeemedTotal)}</div></div>
      </div>
    </div>`;
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
  const ext = archiveFileEnding(file);
  if (!ext) { alert('Please choose an InPage, Word or PDF file (.inp, .doc, .docx, .pdf).'); return; }
  if (file.size > ARCHIVE_FILE_MAX) { alert('This file is larger than 50 MB.'); return; }
  const draftPath = `draft-${task.document_id}-${task.id}-${Date.now()}.${ext}`;
  await withStatus(sb.storage.from(BUCKET).upload(draftPath, asArchiveFile(file)), 'Uploading corrected file...');

  // save_task_draft (170) makes the draft, or gives it the new file, and checks that the task is one's own. Until 170 has
  // been run it is not there: the old direct change.
  try {
    await withStatus(sb.rpc('save_task_draft', { p_task_id: task.id, p_path: draftPath }), 'Saving...');
    return;
  } catch (e) {
    if (e.code !== 'PGRST202') throw e;
  }
  const existing = await withStatus(sb.from('documents').select('document_id,draft_inp_path').eq('source_task_id', task.id));
  if (existing.length) {
    const old = existing[0];
    if (old.draft_inp_path && old.draft_inp_path !== draftPath) await sb.storage.from(BUCKET).remove([old.draft_inp_path]);
    await withStatus(sb.from('documents').update({ draft_inp_path: draftPath }).eq('document_id', old.document_id), 'Replacing corrected file...');
  } else {
    const newId = await nextDocumentId();
    const isTranslation = ['IT_UR', 'EN_UR', 'UR_EN'].includes(task.category);
    await withStatus(sb.from('documents').insert({
      document_id: newId, work_id: orig.work_id, title: orig.title, en_title: orig.en_title, it_title: orig.it_title, it_title_translated: orig.it_title_translated,
      original_title: isTranslation ? null : orig.original_title, ur_title: isTranslation ? null : orig.ur_title,
      category: orig.category, author: orig.author, language: task.category === 'UR_EN' ? 'ENG' : isTranslation ? 'URD' : orig.language,
      ref_date: orig.ref_date, ref_period: orig.ref_period, recipient: orig.recipient, main_topic: orig.main_topic,
      secondary_tags: orig.secondary_tags, bible_verse: orig.bible_verse, media_type: orig.media_type || 'DOC',
      workflow_status: 'revision', source_task_id: task.id, draft_inp_path: draftPath,
      is_preferred: false, legacy_migrated: false,
    }), 'Creating revision record...');
  }
}

// Overdue tasks first (oldest due date on top), then current tasks (soonest due date on top) -
// both groups sorted the same way, ascending by due date, just split by isOverdue().
function sortMineActive(rows) {
  return [...rows].sort((a, b) => {
    const overdueDiff = (isOverdue(b) ? 1 : 0) - (isOverdue(a) ? 1 : 0);
    if (overdueDiff !== 0) return overdueDiff;
    return (a.due_date || '') < (b.due_date || '') ? -1 : (a.due_date || '') > (b.due_date || '') ? 1 : 0;
  });
}

// The lists of My Tasks: what it is, where it stands, and one button that opens it on the desk.
function mineCard(t, button, extra = '') {
  return `<div class="panel task-item ${stateClass(t)}" data-id="${t.id}" style="margin-bottom:12px;">
      <div class="task-card-top">${stateHtml(t)}<span>#${esc(t.id)}</span></div>
      <div class="task-card-title" dir="auto">${esc(t.title)}</div>
      ${docLine(t)}${extra}
      <div class="btn-row"><button class="btn ${button === 'Continue' ? '' : 'secondary'} mine-open">${button}</button></div>
    </div>`;
}
const wireMine = box => box.querySelectorAll('.mine-open').forEach(b => b.addEventListener('click', () => openTask(b.closest('[data-id]').dataset.id)));
function renderMineActiveList(rows) {
  const box = document.getElementById('mine-active-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing in progress. You can take a task in Tasks Store.</div>'; return; }
  box.innerHTML = sortMineActive(rows).map(t => mineCard(t, 'Continue')).join('');
  wireMine(box);
}

function renderMineSubmittedList(rows) {
  const box = document.getElementById('mine-submitted-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing is waiting for review.</div>'; return; }
  box.innerHTML = rows.map(t => mineCard(t, 'Look at it', t.submitted_at ? `<p class="hint">Sent ${relativeDate(t.submitted_at)}. A Revisor will look at it.</p>` : '')).join('');
  wireMine(box);
}

function renderMineClosedList(rows) {
  const box = document.getElementById('mine-closed-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing closed yet.</div>'; return; }
  const PAGE = 30;
  let shown = PAGE;
  const draw = () => {
    box.innerHTML = rows.slice(0, shown).map(t => mineCard(t, 'Look at it', `${t.status === 'published' && t.credits != null ? `<p class="st st-green" style="margin:6px 0 0;">+${esc(t.credits)} credits</p>` : ''}${t.review_notes ? `<p style="white-space:pre-wrap;margin:6px 0 0;" dir="auto"><b>The Revisor's note:</b> ${esc(t.review_notes)}</p>` : ''}`)).join('') + (rows.length > shown ? `<div class="btn-row"><button class="btn secondary" id="mine-closed-more">Show more (${rows.length - shown})</button></div>` : '');
    wireMine(box);
    document.getElementById('mine-closed-more')?.addEventListener('click', () => { shown += PAGE; draw(); });
  };
  draw();
}

// ---------- Team overview: Coordinator/Admin, everyone else's tasks (active + history) ----------

async function renderTeamView(body) {
  const { data: { user } } = await sb.auth.getUser();
  const [rows, operators] = await Promise.all([
    withStatus(sb.from('tasks').select('*').neq('status', 'open').neq('claimed_by', user.id).order('created_at', { ascending: false })),
    fetchOperators(),
  ]);
  const nameMap = await nameMapForIds(rows.map(t => t.claimed_by));

  body.innerHTML = `
    <div class="field-grid">
      <div class="field"><label><input type="checkbox" id="team-overdue"> Overdue only</label></div>
      <div class="field"><label>Category</label><select id="team-category">${optionsHtml(State.optionListsByName.task_category || [], '', true)}</select></div>
      <div class="field"><label>Operator</label><select id="team-operator"><option value="">All operators</option>${operators.map(o => `<option value="${o.user_id}">${esc(o.displayName)}</option>`).join('')}</select></div>
      <div class="field"><label>Status</label><select id="team-status"><option value="">All statuses</option>${Object.entries(STATUS_LABELS).map(([v, l]) => `<option value="${v}">${l}</option>`).join('')}</select></div>
    </div>
    <div class="panel team-limit"><label for="team-limit">Tasks in progress for each person, at most</label>
      <div class="btn-row" style="margin:6px 0 0;"><input id="team-limit" type="number" min="1" max="20" value="${esc(limitNow())}" style="width:90px;"><button class="btn secondary" id="team-limit-save">Save</button><span class="hint" id="team-limit-status" role="status"></span></div>
      <div class="hint">You can still give a task to someone who has reached it.</div></div>
    <div id="team-list" style="margin-top:12px;"></div>`;
  document.getElementById('team-limit-save').addEventListener('click', async () => {
    const value = parseInt(document.getElementById('team-limit').value, 10), status = document.getElementById('team-limit-status');
    status.textContent = '';
    if (!(value >= 1 && value <= 20)) { alert('Please choose a number from 1 to 20.'); return; }
    try { await withStatus(sb.rpc('set_task_limit', { p_value: value }), 'Saving...'); } catch (e) { alert(e.code === 'PGRST202' ? 'This is not ready yet. An Admin has one step to do.' : errorText(e)); return; }
    State.policyValues.task_max_in_progress = value;
    status.textContent = 'Saved \u2713';
  });

  const apply = () => {
    const overdueOnly = document.getElementById('team-overdue').checked;
    const cat = document.getElementById('team-category').value;
    const op = document.getElementById('team-operator').value;
    const status = document.getElementById('team-status').value;
    const filtered = rows.filter(t =>
      (!overdueOnly || isOverdue(t)) &&
      (!cat || t.category === cat) &&
      (!op || t.claimed_by === op) &&
      (!status || t.status === status));
    renderTeamList(filtered, operators, nameMap);
  };
  ['team-overdue', 'team-category', 'team-operator', 'team-status'].forEach(id => document.getElementById(id).addEventListener('change', apply));
  apply();
}

function renderTeamList(rows, operators, nameMap) {
  const box = document.getElementById('team-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">No tasks match this filter.</div>'; return; }
  const repByUid = {};
  for (const o of operators) repByUid[o.user_id] = o.reputation;
  // A straight Revisor "fail" already auto-spawns a retry task - only an Admin override
  // (rejected despite an ok/ok_but verdict) needs this manual follow-up, since that path is a
  // deliberate one-off decision rather than an automatic respawn.
  const needsRedo = t => t.status === 'rejected' && t.review_verdict !== 'fail';
  box.innerHTML = rows.map(t => {
    const rep = repByUid[t.claimed_by];
    const lowRep = rep != null && rep < LOW_REPUTATION_THRESHOLD;
    return `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;position:relative;${isOverdue(t) || lowRep ? 'border-color:var(--danger);' : ''}">
      ${taskIdBadge(t)}
      <div class="chat-meta"><b>${esc(t.title)}</b> · ${esc(nameMap[t.claimed_by] || '')} · ${esc(STATUS_LABELS[t.status] || t.status)}${t.status === 'claimed' ? ` · due ${formatDate(t.due_date)}` : ''} ${isOverdue(t) ? '<span class="chat-tag" style="color:var(--danger);">Overdue</span>' : ''} ${lowRep ? `<span class="chat-tag" style="color:var(--danger);">Low reputation (${esc(rep)})</span>` : ''}</div>
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      ${t.review_notes ? `<p class="hint">${esc(t.review_notes)}</p>` : ''}
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
        </div>` : ''}
      ${['approved', 'rejected', 'published'].includes(t.status) ? `<div class="btn-row">
        ${needsRedo(t) ? '<button class="btn secondary task-done-redo">Create task to redo this</button>' : ''}
        <button class="btn danger task-done-delete">Delete</button>
      </div>` : ''}
    </div>`;
  }).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = card.dataset.id;
    const t = rows.find(r => String(r.id) === id);
    card.querySelector('.task-team-reassign-btn')?.addEventListener('click', async () => {
      const sel = card.querySelector('.task-team-reassign');
      if (!sel.value) { alert('Choose someone to reassign this task to.'); return; }
      await withStatus(sb.from('tasks').update({
        claimed_by: sel.value, claimed_at: new Date().toISOString(),
      }).eq('id', id), 'Reassigning...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-team-free')?.addEventListener('click', async () => {
      const note = await promptPopup('Why are you freeing up this task? (overdue with no response, inappropriate conduct, ...) This lowers the operator\'s reputation score.');
      if (note === null) return;
      await withStatus(sb.rpc('reclaim_task', { p_task_id: parseInt(id, 10), p_note: note || null }), 'Freeing up...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-team-delete')?.addEventListener('click', async () => {
      if (!await confirmPopup('Delete this task permanently?')) return;
      await withStatus(sb.from('tasks').delete().eq('id', id), 'Deleting...');
      await renderTasksView(document.getElementById('main'));
    });
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
      if (!await confirmPopup('Delete this completed task permanently?')) return;
      await withStatus(sb.from('tasks').delete().eq('id', id), 'Deleting...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

// ---------- Review Tasks: Coordinator/Admin, or an Operator with the Revisor qualification ----------

async function renderReviewViewBody(body) {
  body.innerHTML = `<p class="hint">We review only the task, so who did the work isn't shown here.</p><div id="tasks-review-list"><div class="hint">Loading...</div></div>`;
  await refreshReviewQueue();
}

async function refreshReviewQueue() {
  const rows = await withStatus(sb.rpc('get_review_queue'));
  const box = document.getElementById('tasks-review-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing is waiting for review.</div>'; return; }
  box.innerHTML = `<div class="task-cards">${rows.map(t => `
    <div class="task-card" data-id="${t.id}">
      <div class="task-card-top"><span class="task-kind">${esc(taskKind(t)) || 'Task'}</span><span>#${esc(t.id)} &middot; sent ${relativeDate(t.submitted_at)}</span></div>
      <div class="task-card-title" dir="auto">${esc(t.title)}</div>
      <div class="task-card-facts">${taskFacts(t)}</div>
      <div class="btn-row"><button class="btn">Review</button></div>
    </div>`).join('')}</div>`;
  box.querySelectorAll('[data-id] .btn').forEach(b => b.addEventListener('click', () => openTask(b.closest('[data-id]').dataset.id, 'review')));
}

// One review on the desk: the file and the document on one side, the decision on the other. It is sent with "Send", not at
// the first touch. Who did the work is not shown, and the queue of the database does not say it.
const VERDICTS = [['ok', 'OK', 'Good work. It goes to the Admin.', 'green'], ['ok_but', 'OK, but...', 'Good, but write what to look at. It goes to the Admin.', 'violet'], ['fail', 'Fail', 'Not good enough. Write why. Someone else will do it again.', 'red']];
async function renderReviewPage(main, id) {
  const queue = await withStatus(sb.rpc('get_review_queue'));
  const t = queue.find(x => String(x.id) === String(id));
  if (!t) {
    main.innerHTML = '<div class="panel"><p>This task is not waiting for your review any more.</p><div class="btn-row"><button class="btn" id="desk-back">Review Tasks</button></div></div>';
    main.querySelector('#desk-back').addEventListener('click', () => backToTasks('review'));
    return;
  }
  const sources = await documentSources(t.document_id);
  if (t.candidate_document_id) sources.unshift(fileSource('mine', 'The file', async () => (await withStatus(sb.rpc('get_review_document', { p_document_id: t.candidate_document_id })))[0]?.draft_inp_path || null));
  const work = `${infoCard(t, `<span class="st st-violet"><span aria-hidden="true">&#128065;</span> Sent ${esc(relativeDate(t.submitted_at))}</span>`)}
    <div class="btn-row">${sources.length ? '<button class="btn secondary desk-open-doc desk-phone">Look at the file</button>' : ''}${t.candidate_document_id ? '<button class="btn secondary" id="review-download">Download the file</button>' : ''}</div>
    <div class="panel">
      <fieldset class="desk-choices"><legend>Your decision</legend>${VERDICTS.map(([v, l, text, tone]) => `<label class="desk-choice st-${tone}"><input type="radio" name="verdict" value="${v}"><span><b>${l}</b><span class="hint">${text}</span></span></label>`).join('')}</fieldset>
      <div class="field"><label for="review-note">Note <span class="hint" id="review-note-hint">(if you want)</span></label><textarea id="review-note" rows="4" dir="auto" placeholder="Write as you would speak to them"></textarea></div>
      <div class="btn-row"><button class="btn big-btn" id="review-send" disabled>Send</button></div>
    </div>`;
  main.innerHTML = deskHtml(headHtml('Review Tasks', `Task ${t.id}, ${queue.indexOf(t) + 1} of ${queue.length}`), sources.length > 0, work);
  mountDocument(main, sources, 'mine');
  const note = main.querySelector('#review-note'), send = main.querySelector('#review-send');
  const verdict = () => main.querySelector('[name="verdict"]:checked')?.value || '';
  const mark = () => {
    const v = verdict(), needed = v === 'ok_but' || v === 'fail';
    main.querySelector('#review-note-hint').textContent = needed ? '(needed)' : '(if you want)';
    main.querySelectorAll('.desk-choice').forEach(l => l.classList.toggle('desk-chosen', l.querySelector('input').checked));
    send.disabled = !v || (needed && !note.value.trim());
    State.unsaved = v || note.value.trim() ? 'Your review has not been sent yet.' : '';
  };
  main.querySelectorAll('[name="verdict"]').forEach(r => r.addEventListener('change', mark));
  note.addEventListener('input', mark);
  main.querySelector('#desk-back').addEventListener('click', () => backToTasks('review'));
  main.querySelector('#review-download')?.addEventListener('click', async () => {
    const path = (await withStatus(sb.rpc('get_review_document', { p_document_id: t.candidate_document_id })))[0]?.draft_inp_path;
    if (!path) { alert('There is no file for this task.'); return; }
    const { data } = await sb.storage.from(BUCKET).createSignedUrl(path, 60);
    if (data?.signedUrl) window.open(data.signedUrl, '_blank');
  });
  send.addEventListener('click', async () => {
    const v = verdict();
    if (v === 'fail' && !await confirmPopup('Send "Fail"? The task closes, and a new one opens for someone else.', { confirmLabel: 'Send', cancelLabel: 'Not yet', danger: true })) return;
    send.disabled = true;
    try {
      await withStatus(sb.rpc('submit_task_review', { p_task_id: t.id, p_verdict: v, p_notes: note.value.trim() || null }), 'Sending...');
    } catch (e) { send.disabled = false; alert(errorText(e)); return; }
    State.unsaved = '';
    backToTasks('review');
    alert('Sent. Thank you!');
  });
}

// ---------- Publish Tasks: Admin only - a technical step, kept out of Coordinator's reach ----------

async function renderPublishViewBody(body) {
  body.innerHTML = `
    <div class="panel"><h2 style="margin-top:0;">Publish queue <span class="hint">— approved by a Revisor, ready to go live</span></h2><div id="tasks-publish-list"></div></div>
    <div class="panel"><h2 style="margin-top:0;">Documents ready to publish <span class="hint">— task already closed; upload the final PDF and InPage file, then publish</span></h2><div id="tasks-finalize-list"></div></div>`;
  await refreshPublishQueue();
  await refreshFinalizeQueue();
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
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;position:relative;">
      ${taskIdBadge(t)}
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
      if (!await confirmPopup('Close this task? The operator gets the credits/reputation the Revisor\'s verdict implied. The document itself isn\'t live yet - you\'ll prepare the final PDF and publish it separately, from "Documents ready to publish" below.')) return;
      await withStatus(sb.rpc('admin_decide_task', { p_task_id: id, p_decision: 'publish', p_note: null }), 'Closing task...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-reject-btn').addEventListener('click', async () => {
      const note = await promptPopup('Why are you rejecting this, despite the Revisor\'s verdict? This closes the task with the same penalty as a fail - you can create a fresh task on the same document afterward from Team overview.');
      if (note === null) return;
      if (!note.trim()) { alert('Please enter a reason.'); return; }
      await withStatus(sb.rpc('admin_decide_task', { p_task_id: id, p_decision: 'reject', p_note: note.trim() }), 'Rejecting...');
      await renderTasksView(document.getElementById('main'));
    });
  });
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
      await withStatus(sb.storage.from(BUCKET).upload(finalName, asArchiveFile(file), { upsert: true }), 'Uploading PDF...');
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
      if (!d.storage_path) { if (!await confirmPopup('No final PDF uploaded yet - publish anyway?')) return; }
      await withStatus(sb.rpc('finalize_document_publish', { p_document_id: id }), 'Publishing document...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

// ---------- Withdrawn Tasks: Admin only - open tasks pulled off the Store, re-enable-able ----------

async function renderWithdrawnView(body) {
  const rows = await withStatus(sb.from('tasks').select('*').eq('status', 'withdrawn').order('created_at', { ascending: false }));
  if (!rows.length) { body.innerHTML = '<div class="empty-msg">Nothing withdrawn right now.</div>'; return; }
  body.innerHTML = rows.map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;position:relative;">
      ${taskIdBadge(t)}
      <b>${esc(t.title)}</b>
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      <div class="btn-row"><button class="btn secondary withdrawn-reenable-btn">Re-enable in Store</button></div>
    </div>`).join('');
  body.querySelectorAll('[data-id]').forEach(card => {
    card.querySelector('.withdrawn-reenable-btn').addEventListener('click', async () => {
      await withStatus(sb.from('tasks').update({ status: 'open' }).eq('id', card.dataset.id), 'Re-enabling...');
      currentView = 'store';
      await renderTasksView(document.getElementById('main'));
    });
  });
}

// ---------- Budget: Admin only - a top-up ledger, plus a live breakdown of committed credits ----------
// Budget = sum(budget_ledger.amount) - an append-only log of top-ups, never a single
// overwritable number. Used/available is computed live from tasks.credits by status, so
// Withdraw/Reject free up availability automatically (they're simply excluded here) with no
// reversal entries needed.

const BUDGET_COMMITTED_STATUSES = ['open', 'claimed', 'submitted', 'approved', 'published'];

async function renderBudgetView(body) {
  const [ledgerRows, taskRows] = await Promise.all([
    withStatus(sb.from('budget_ledger').select('*').order('created_at', { ascending: false })),
    withStatus(sb.from('tasks').select('credits,status').in('status', BUDGET_COMMITTED_STATUSES)),
  ]);
  const addedBy = await authorNames(ledgerRows, 'created_by', 'created_by_email');
  const budget = ledgerRows.reduce((sum, r) => sum + r.amount, 0);
  const sumFor = statuses => taskRows.filter(t => statuses.includes(t.status)).reduce((sum, t) => sum + (t.credits || 0), 0);
  const openCredits = sumFor(['open']);
  const inProgressCredits = sumFor(['claimed', 'submitted']);
  const toRedeemCredits = sumFor(['approved']);
  const redeemedCredits = sumFor(['published']);
  const used = openCredits + inProgressCredits + toRedeemCredits + redeemedCredits;
  const available = budget - used;

  const tile = (label, value) => `<div class="field"><label>${label}</label><div style="font-size:20px;font-weight:600;">${esc(value)}</div></div>`;
  body.innerHTML = `
    <div class="panel">
      <div class="field-grid">
        ${tile('Budget', budget)}
        ${tile('Available', available)}
        ${tile('Posted, not claimed', openCredits)}
        ${tile('In progress', inProgressCredits)}
        ${tile('Approved, to redeem', toRedeemCredits)}
        ${tile('Redeemed', redeemedCredits)}
      </div>
    </div>
    <div class="btn-row"><button class="btn" id="budget-add-funds-btn">Add funds</button></div>
    <h3>Top-up history</h3>
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Date</th><th>Amount</th><th>Note</th><th>Added by</th></tr></thead>
      <tbody>${ledgerRows.length ? ledgerRows.map(r => `
        <tr><td>${esc((r.created_at || '').slice(0, 10))}</td><td>${esc(r.amount)}</td><td>${esc(r.note) || '—'}</td><td>${esc(addedBy(r)) || '—'}</td></tr>
      `).join('') : '<tr><td colspan="4" class="empty-msg">No top-ups recorded yet.</td></tr>'}</tbody>
    </table></div>`;

  document.getElementById('budget-add-funds-btn').addEventListener('click', openAddFundsPopup);
}

function openAddFundsPopup() {
  document.getElementById('add-funds-popup')?.remove();
  const overlay = document.createElement('div');
  overlay.id = 'add-funds-popup';
  overlay.style.cssText = 'position:fixed;inset:0;z-index:2100;background:rgba(20,16,10,.55);display:flex;align-items:center;justify-content:center;overflow:auto;padding:24px 16px;';
  overlay.innerHTML = '<div class="panel" style="max-width:420px;width:100%;margin:0;"></div>';
  document.body.appendChild(overlay);
  const panel = overlay.querySelector('.panel');
  const close = () => overlay.remove();
  overlay.addEventListener('click', e => { if (e.target === overlay) close(); });
  panel.innerHTML = `
    <h2 style="margin-top:0;">Add funds</h2>
    <div class="field"><label>Amount <span class="hint">(credits)</span></label><input id="funds-amount" type="number" min="1"></div>
    <div class="field"><label>Note <span class="hint">(optional)</span></label><input id="funds-note"></div>
    <div class="btn-row"><button class="btn" id="funds-confirm">Add</button><button class="btn secondary" id="funds-cancel">Cancel</button></div>`;
  panel.querySelector('#funds-cancel').addEventListener('click', close);
  panel.querySelector('#funds-confirm').addEventListener('click', async () => {
    const amount = parseInt(panel.querySelector('#funds-amount').value, 10);
    if (!amount || amount <= 0) { alert('Please enter a positive amount.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('budget_ledger').insert({
      amount, note: panel.querySelector('#funds-note').value.trim() || null, created_by_email: user.email,
    }), 'Adding funds...');
    close();
    await renderTasksView(document.getElementById('main'));
  });
}

// ---------- Overdue / reassignment notifications ----------
// In-app only for now (Fase 2 scope) - shown once per login session, like the splash screen.
// Email reminders are a deliberately separate follow-up (needs an Edge Function + email
// provider, not just UI - see PROJECT_HANDOFF_v4.md §Fase 2).

function showTaskToast(title, message, onView) {
  document.querySelectorAll('.toast-notification').forEach(t => t.remove());
  const toast = document.createElement('div');
  toast.className = 'toast-notification work-toast';
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
