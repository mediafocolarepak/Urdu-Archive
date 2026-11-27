// Admin<->user chat/ticketing. Users see only their own messages (RLS enforces this
// server-side, so no explicit .eq('user_id', ...) filter is needed for the user view);
// admins see every message and can reply + dismiss. Everything stays in chat_messages
// forever - "dismiss" is a soft flag hiding a row from the admin's default list, not a delete.

import { displayLogin, nameMapForIds, sb, State, esc, canReviewApplications, withStatus, labelOf, confirmPopup } from './core.js?v=20261127224837';

// Report types are admin-editable from Options ("Report type" list) - see OPTION_LIST_NAMES
// in core.js and 55_report_types.sql for the seed. Read fresh each time rather than cached in
// a module-level constant so an Options edit shows up without a page reload.
function reportTypes() { return State.optionListsByName.report_type || []; }

function formatDateTime(iso) {
  return esc((iso || '').slice(0, 16).replace('T', ' '));
}

const REPORT_AUDIO_BUCKET = 'report-audio';

// Users and Operators report from Share with us since 2026-11-25 (sharewithus.js); this is the inbox of Coordinators and Admins.

// The recordings of these reports, to listen to (private bucket: a short-lived link for each).
async function reportAudioUrls(rows) {
  const paths = rows.filter(r => r.audio_path).map(r => r.audio_path);
  if (!paths.length) return {};
  const { data } = await sb.storage.from(REPORT_AUDIO_BUCKET).createSignedUrls(paths, 3600);
  return Object.fromEntries((data || []).filter(d => d.signedUrl).map(d => [d.path, d.signedUrl]));
}
const reportAudioHtml = (r, urls) => (r.audio_path && urls[r.audio_path] ? `<div style="margin-top:6px;"><audio controls preload="none" src="${esc(urls[r.audio_path])}"></audio></div>` : '');

// ---------- Admin inbox ----------

export async function renderAdminMessagesView(main) {
  if (!canReviewApplications()) { main.innerHTML = '<div class="empty-msg">Coordinator or Admin access required.</div>'; return; }
  const { data: { user } } = await sb.auth.getUser();
  markChatSeen('reviewer_' + user.id);
  main.innerHTML = `
    <div class="panel">
      <h2>Messages</h2>
      <div class="field-grid">
        <div class="field"><label>User</label><input id="msg-filter-user" type="text" placeholder="Email contains..."></div>
        <div class="field"><label>Report type</label>
          <select id="msg-filter-type"><option value="">All</option>${reportTypes().map(([c, l]) => `<option value="${c}">${l}</option>`).join('')}</select>
        </div>
        <div class="field"><label>Document ID</label><input id="msg-filter-docid" type="number" min="1"></div>
        <div class="field"><label>&nbsp;</label><label style="text-transform:none;font-size:13px;"><input id="msg-filter-dismissed" type="checkbox" style="width:auto;"> Show dismissed</label></div>
      </div>
      <div class="grid-wrap"><table class="grid" id="msg-grid">
        <thead><tr><th>Date/time</th><th>User</th><th>Type</th><th>Doc ID</th><th>Message</th><th>Reply</th><th></th><th></th><th>Led to a correction</th></tr></thead>
        <tbody id="msg-grid-body"></tbody>
      </table></div>
    </div>`;
  const refresh = () => refreshAdminMessages();
  document.getElementById('msg-filter-user').addEventListener('input', refresh);
  document.getElementById('msg-filter-type').addEventListener('change', refresh);
  document.getElementById('msg-filter-docid').addEventListener('input', refresh);
  document.getElementById('msg-filter-dismissed').addEventListener('change', refresh);
  await refreshAdminMessages();
}

// Who reads Messages may also look for a person by login (Coordinators and Admins read the accounts).
async function loginsOf(ids) {
  const { data } = await sb.from('user_roles').select('user_id,email').in('user_id', [...new Set(ids.filter(Boolean))]);
  return Object.fromEntries((data || []).map(r => [r.user_id, displayLogin(r.email)]));
}

async function refreshAdminMessages() {
  const emailFilter = document.getElementById('msg-filter-user').value.trim().toLowerCase();
  const typeFilter = document.getElementById('msg-filter-type').value;
  const docIdFilter = document.getElementById('msg-filter-docid').value.trim();
  const showDismissed = document.getElementById('msg-filter-dismissed').checked;

  let query = sb.from('chat_messages').select('*').order('created_at', { ascending: false });
  if (!showDismissed) query = query.eq('dismissed', false);
  if (typeFilter) query = query.eq('report_type', typeFilter);
  if (docIdFilter) query = query.eq('document_id', parseInt(docIdFilter, 10));
  const rows = await withStatus(query);
  const nameMap = await nameMapForIds(rows.map(r => r.user_id));
  const logins = emailFilter ? await loginsOf(rows.map(r => r.user_id)) : {};
  const filtered = emailFilter ? rows.filter(r => `${nameMap[r.user_id] || ''} ${logins[r.user_id] || ''}`.toLowerCase().includes(emailFilter)) : rows;
  const audioUrls = await reportAudioUrls(filtered);
  // A report that led to a correction gives its author a token of appreciation (docs/TOKEN_POLICY.md, migration 129).
  const { data: markedRows } = await sb.rpc('token_marked_reports');
  const marked = new Set((markedRows || []).map(m => String(m.chat_message_id)));
  const { data: { user: me } } = await sb.auth.getUser();

  const body = document.getElementById('msg-grid-body');
  body.innerHTML = filtered.map(r => `
    <tr data-id="${r.id}" class="${r.dismissed ? 'dismissed-row' : ''}">
      <td>${formatDateTime(r.created_at)}</td>
      <td>${esc(nameMap[r.user_id] || '')}</td>
      <td>${esc(labelOf(reportTypes(), r.report_type) || r.report_type)}</td>
      <td>${r.document_id ? esc(r.document_id) : '—'}</td>
      <td style="white-space:normal;max-width:260px;">${esc(r.message_text || '')}${reportAudioHtml(r, audioUrls)}</td>
      <td><textarea class="msg-reply-input" rows="2" style="min-width:180px;">${esc(r.reply_text)}</textarea></td>
      <td>
        <button class="btn secondary msg-reply-btn" style="padding:4px 10px;">Send</button>
        <button class="btn danger msg-dismiss-btn" style="padding:4px 10px;">Dismiss</button>
      </td>
      <td><button class="btn msg-create-task-btn" style="padding:4px 10px;">Create task</button></td>
      <td>${marked.has(String(r.id)) ? '<span class="hint">Yes, thanked</span>'
        : (r.user_id === me.id ? '<span class="hint">Your own</span>'
          : '<button class="btn secondary msg-corrected-btn" style="padding:4px 10px;">It led to a correction</button>')}</td>
    </tr>`).join('') || '<tr><td colspan="9">No messages match the current filters.</td></tr>';

  body.querySelectorAll('tr[data-id]').forEach(tr => {
    const id = tr.dataset.id;
    tr.querySelector('.msg-reply-btn').addEventListener('click', async () => {
      const reply_text = tr.querySelector('.msg-reply-input').value.trim();
      if (!reply_text) { alert('Please enter a reply.'); return; }
      await withStatus(sb.from('chat_messages').update({
        reply_text, replied_at: new Date().toISOString(),
      }).eq('id', id), 'Sending reply...');
      await refreshAdminMessages();
    });
    tr.querySelector('.msg-dismiss-btn').addEventListener('click', async () => {
      await withStatus(sb.from('chat_messages').update({ dismissed: true }).eq('id', id), 'Dismissing...');
      await refreshAdminMessages();
    });
    tr.querySelector('.msg-corrected-btn')?.addEventListener('click', async () => {
      if (!await confirmPopup('Did this report lead to a correction? Its author receives a token of appreciation.')) return;
      const { error } = await sb.rpc('token_give_for_report', { p_message_id: Number(id) });
      if (error) { alert(error.message); return; }
      await refreshAdminMessages();
    });
    tr.querySelector('.msg-create-task-btn').addEventListener('click', async () => {
      const r = filtered.find(x => String(x.id) === id);
      await startTaskFromMessage(r);
    });
  });
}

// Prefills the Tasks tab's "New task" form from a chat report: pulls the linked document's
// page count (if any) so the Coordinator/Admin doesn't have to look it up separately, then
// hands off via State + the same window.__renderTab escape hatch docdetail.js uses (chat.js
// and tasks.js never import each other directly - see core.js's star-import convention).
async function startTaskFromMessage(r) {
  let document_pages = null;
  if (r.document_id) {
    const { data } = await sb.from('documents').select('pages').eq('document_id', r.document_id).maybeSingle();
    document_pages = data?.pages ?? null;
  }
  State.taskPrefill = {
    title: `Proofreading: ${labelOf(reportTypes(), r.report_type) || r.report_type}${r.document_id ? ` - Doc #${r.document_id}` : ''}`,
    description: r.message_text,
    document_id: r.document_id || null,
    document_pages,
  };
  window.__renderTab('tasks');
}

// ---------- Live "new message" notifications ----------
// "Seen" is tracked per role+user in localStorage (not sessionStorage, since it must survive
// across logins - the whole point is to still notify someone who was offline when a message
// arrived). A Supabase Realtime subscription covers the "online right now" case; the one-off
// backlog check covers "offline, catches up at next login". Both paths funnel into the same
// toast so there's only one notification UI to maintain.

function seenKey(who) { return `chatSeenAt_${who}`; }
function getSeenAt(who) { return localStorage.getItem(seenKey(who)) || '1970-01-01T00:00:00.000Z'; }
function markChatSeen(who) { localStorage.setItem(seenKey(who), new Date().toISOString()); }

function showChatToast(title, message, onView) {
  document.querySelectorAll('.toast-notification').forEach(t => t.remove());
  const toast = document.createElement('div');
  toast.className = 'toast-notification';
  toast.innerHTML = `
    <div class="toast-title">${esc(title)}</div>
    <div class="toast-body">${esc(message)}</div>
    <div class="btn-row" style="margin:8px 0 0;">
      <button class="btn" id="toast-view-btn" style="padding:4px 10px;">View</button>
      <button class="btn secondary" id="toast-close-btn" style="padding:4px 10px;">Dismiss</button>
    </div>`;
  document.body.appendChild(toast);
  document.getElementById('toast-close-btn').addEventListener('click', () => toast.remove());
  document.getElementById('toast-view-btn').addEventListener('click', () => { toast.remove(); onView(); });
}

let notifyChannel = null;

// Called once per login (from app.js, after the dashboard is first shown). navigateToChat
// should switch to the Chat/Messages tab - passed in rather than imported to avoid a circular
// import with app.js (core.js's star-import convention: feature modules never import each other).
export async function initChatNotifications(navigateToChat) {
  if (notifyChannel) { sb.removeChannel(notifyChannel); notifyChannel = null; }
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return;

  if (canReviewApplications()) {
    const who = 'reviewer_' + user.id;
    const { data } = await sb.from('chat_messages').select('id').eq('dismissed', false).gt('created_at', getSeenAt(who));
    if (data && data.length) showChatToast('New Messages', `${data.length} report${data.length > 1 ? 's' : ''} waiting for a reply.`, navigateToChat);

    notifyChannel = sb.channel('chat-admin-notify')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'chat_messages' }, () => {
        showChatToast('New Messages', 'A user just sent a new report.', navigateToChat);
      })
      .subscribe();
  } else {
    const who = 'user_' + user.id;
    const { data } = await sb.from('chat_messages').select('id').eq('user_id', user.id).not('reply_text', 'is', null).gt('replied_at', getSeenAt(who));
    if (data && data.length) showChatToast('New reply from Admin', 'Admin replied to one of your messages.', navigateToChat);

    notifyChannel = sb.channel('chat-user-notify-' + user.id)
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'chat_messages', filter: `user_id=eq.${user.id}` }, payload => {
        if (payload.new.reply_text) showChatToast('New reply from Admin', 'Admin replied to your message.', navigateToChat);
      })
      .subscribe();
  }
}
