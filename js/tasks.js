// Fase 2 di "Join the Team": bacheca di task. Coordinator/Admin creano i task (testo libero,
// con un document_id opzionale per legarli a un record dell'archivio) e possono assegnarli
// direttamente a un Operator o lasciarli liberi; qualunque Operator+ può "prendere" (claim) un
// task libero fissando lui stesso la data di consegna. RLS impedisce di toccare un task preso
// da qualcun altro (vedi 34_task_store.sql) - i pulsanti qui sotto rispecchiano solo quel
// vincolo, non lo sostituiscono.

import { sb, esc, today, canWrite, canReviewApplications, withStatus, getDisplayNameByEmail } from './core.js?v=20260829001156';

function isOverdue(t) { return t.status === 'claimed' && t.due_date && t.due_date < today(); }
function formatDate(d) { return d ? esc(d) : '—'; }

// Resolves a set of emails to display names in one batch, for the "Team overview"/"Completed"
// lists (Coordinator/Admin only - getDisplayNameByEmail needs 35_task_names.sql's RLS to read
// another user's profile). Falls back to the email itself wherever no full_name is on file.
async function nameMapForEmails(emails) {
  const unique = [...new Set(emails.filter(Boolean))];
  const names = await Promise.all(unique.map(e => getDisplayNameByEmail(e)));
  const map = {};
  unique.forEach((e, i) => { map[e] = names[i]; });
  return map;
}

async function fetchOperators() {
  const rows = await withStatus(sb.from('user_roles').select('user_id,email').in('role', ['operator', 'coordinator']).order('email'));
  const names = await Promise.all(rows.map(r => getDisplayNameByEmail(r.email)));
  return rows.map((r, i) => ({ ...r, displayName: names[i] }));
}

export async function renderTasksView(main) {
  if (!canWrite()) { main.innerHTML = '<div class="empty-msg">Operator access required.</div>'; return; }
  const { data: { user } } = await sb.auth.getUser();
  const manage = canReviewApplications(); // same tier as Team Applications review: Coordinator + Admin

  main.innerHTML = `
    <div class="panel" id="tasks-new-panel" style="display:none;"></div>
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

  await refreshTasks(user, manage, operators);
}

function renderNewTaskForm(operators) {
  const panel = document.getElementById('tasks-new-panel');
  panel.innerHTML = `
    <h2>New task</h2>
    <div class="field-grid" style="max-width:640px;">
      <div class="field"><label>Title</label><input id="task-new-title"></div>
      <div class="field"><label>Description</label><textarea id="task-new-desc" rows="2"></textarea></div>
      <div class="field"><label>Document ID <span class="hint">(optional)</span></label><input id="task-new-docid" type="number" min="1"></div>
      <div class="field"><label>Assign directly to <span class="hint">(optional — otherwise left open to claim)</span></label>
        <select id="task-new-assignee"><option value="">— leave open —</option>${operators.map(o => `<option value="${o.user_id}" data-email="${esc(o.email)}">${esc(o.displayName)}</option>`).join('')}</select>
      </div>
      <div class="field" id="task-new-due-field" style="display:none;"><label>Due date</label><input id="task-new-due" type="date"></div>
    </div>
    <div class="btn-row"><button class="btn" id="task-new-submit">Create task</button></div>`;
  document.getElementById('task-new-assignee').addEventListener('change', e => {
    document.getElementById('task-new-due-field').style.display = e.target.value ? 'block' : 'none';
  });
  document.getElementById('task-new-submit').addEventListener('click', async () => {
    const title = document.getElementById('task-new-title').value.trim();
    if (!title) { alert('Please enter a title.'); return; }
    const docId = document.getElementById('task-new-docid').value.trim();
    const assigneeSel = document.getElementById('task-new-assignee');
    const assigneeId = assigneeSel.value || null;
    const assigneeEmail = assigneeId ? assigneeSel.selectedOptions[0].dataset.email : null;
    const dueDate = document.getElementById('task-new-due').value || null;
    if (assigneeId && !dueDate) { alert('Please set a due date for the person you are assigning this to.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('tasks').insert({
      title, description: document.getElementById('task-new-desc').value.trim() || null,
      document_id: docId ? parseInt(docId, 10) : null,
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

async function refreshTasks(user, manage, operators) {
  const rows = await withStatus(sb.from('tasks').select('*').order('created_at', { ascending: false }));
  const nameMap = manage ? await nameMapForEmails(rows.flatMap(t => [t.claimed_by_email, t.created_by_email])) : {};

  renderOpenList(rows.filter(t => t.status === 'open'));
  renderMineList(rows.filter(t => t.status === 'claimed' && t.claimed_by === user.id));
  if (manage) renderTeamList(rows.filter(t => t.status === 'claimed' && t.claimed_by !== user.id), operators, nameMap);
  renderDoneList(rows.filter(t => t.status === 'done'), manage, nameMap);
}

function docLine(t) { return t.document_id ? `<p class="hint">Document #${esc(t.document_id)}</p>` : ''; }

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

function renderMineList(rows) {
  const box = document.getElementById('tasks-mine-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">You have no claimed tasks. Check "Open tasks" above.</div>'; return; }
  box.innerHTML = rows.map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;${isOverdue(t) ? 'border-color:var(--danger);' : ''}">
      <b>${esc(t.title)}</b> ${isOverdue(t) ? '<span class="chat-tag" style="color:var(--danger);">Overdue</span>' : ''}
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      <div class="field-grid" style="max-width:320px;">
        <div class="field"><label>Due date</label><input class="task-mine-due" type="date" value="${esc(t.due_date || '')}"></div>
      </div>
      <div class="btn-row">
        <button class="btn secondary task-mine-save">Update due date</button>
        <button class="btn task-mine-done">Mark done</button>
      </div>
    </div>`).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = card.dataset.id;
    card.querySelector('.task-mine-save').addEventListener('click', async () => {
      const due = card.querySelector('.task-mine-due').value;
      if (!due) { alert('Please choose a due date.'); return; }
      await withStatus(sb.from('tasks').update({ due_date: due }).eq('id', id), 'Updating...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-mine-done').addEventListener('click', async () => {
      await withStatus(sb.from('tasks').update({ status: 'done', completed_at: new Date().toISOString() }).eq('id', id), 'Marking done...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

function renderTeamList(rows, operators, nameMap) {
  const box = document.getElementById('tasks-team-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">No one else has a claimed task right now.</div>'; return; }
  box.innerHTML = rows.map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;${isOverdue(t) ? 'border-color:var(--danger);' : ''}">
      <div class="chat-meta"><b>${esc(t.title)}</b> · ${esc(nameMap[t.claimed_by_email] || t.claimed_by_email)} · due ${formatDate(t.due_date)} ${isOverdue(t) ? '<span class="chat-tag" style="color:var(--danger);">Overdue</span>' : ''}</div>
      ${docLine(t)}
      ${t.description ? `<p>${esc(t.description)}</p>` : ''}
      <div class="field-grid" style="max-width:320px;">
        <div class="field"><label>Reassign to</label>
          <select class="task-team-reassign"><option value="">— choose —</option>${operators.filter(o => o.user_id !== t.claimed_by).map(o => `<option value="${o.user_id}" data-email="${esc(o.email)}">${esc(o.displayName)}</option>`).join('')}</select>
        </div>
      </div>
      <div class="btn-row">
        <button class="btn secondary task-team-reassign-btn">Reassign</button>
        <button class="btn secondary task-team-free">Free up (back to open)</button>
        <button class="btn danger task-team-delete">Delete</button>
      </div>
    </div>`).join('');
  box.querySelectorAll('[data-id]').forEach(card => {
    const id = card.dataset.id;
    card.querySelector('.task-team-reassign-btn').addEventListener('click', async () => {
      const sel = card.querySelector('.task-team-reassign');
      if (!sel.value) { alert('Choose someone to reassign this task to.'); return; }
      await withStatus(sb.from('tasks').update({
        claimed_by: sel.value, claimed_by_email: sel.selectedOptions[0].dataset.email, claimed_at: new Date().toISOString(),
      }).eq('id', id), 'Reassigning...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-team-free').addEventListener('click', async () => {
      if (!confirm('Free up this task and put it back in the open pool?')) return;
      await withStatus(sb.from('tasks').update({
        status: 'open', claimed_by: null, claimed_by_email: null, claimed_at: null, due_date: null,
      }).eq('id', id), 'Freeing up...');
      await renderTasksView(document.getElementById('main'));
    });
    card.querySelector('.task-team-delete').addEventListener('click', async () => {
      if (!confirm('Delete this task permanently?')) return;
      await withStatus(sb.from('tasks').delete().eq('id', id), 'Deleting...');
      await renderTasksView(document.getElementById('main'));
    });
  });
}

function renderDoneList(rows, manage, nameMap) {
  const box = document.getElementById('tasks-done-list');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Nothing completed yet.</div>'; return; }
  box.innerHTML = rows.slice(0, 30).map(t => `
    <div class="panel" data-id="${t.id}" style="margin-bottom:12px;">
      <div class="chat-meta">${esc(t.title)} · ${esc(nameMap[t.claimed_by_email] || t.claimed_by_email)} · completed ${formatDate((t.completed_at || '').slice(0, 10))}</div>
      ${manage ? '<div class="btn-row"><button class="btn danger task-done-delete">Delete</button></div>' : ''}
    </div>`).join('');
  if (manage) {
    box.querySelectorAll('[data-id]').forEach(card => {
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
