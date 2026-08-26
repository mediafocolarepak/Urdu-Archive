// Admin<->user chat/ticketing. Users see only their own messages (RLS enforces this
// server-side, so no explicit .eq('user_id', ...) filter is needed for the user view);
// admins see every message and can reply + dismiss. Everything stays in chat_messages
// forever - "dismiss" is a soft flag hiding a row from the admin's default list, not a delete.

import { sb, esc, isAdmin, withStatus } from './core.js?v=20260826120000';

const REPORT_TYPES = [
  ['REVISION', 'Revision'],
  ['DOWNLOAD_ERROR', 'Download error'],
  ['BUG', 'Software bug'],
  ['SUGGESTION', 'Suggestion'],
];
const REPORT_TYPE_LABEL = Object.fromEntries(REPORT_TYPES);
const DOC_ID_REQUIRED_TYPES = ['REVISION', 'DOWNLOAD_ERROR'];

function formatDateTime(iso) {
  return esc((iso || '').slice(0, 16).replace('T', ' '));
}

// ---------- User-facing chat ----------

export async function renderChatView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Chat with Admin</h2>
      <div class="chat-thread" id="chat-thread"></div>
      <div class="field-grid">
        <div class="field"><label>Report type</label>
          <select id="chat-report-type">${REPORT_TYPES.map(([c, l]) => `<option value="${c}">${l}</option>`).join('')}</select>
        </div>
        <div class="field" id="chat-docid-field"><label>Document ID</label><input id="chat-document-id" type="number" min="1"></div>
      </div>
      <div class="field"><label>Message</label><textarea id="chat-message-text" rows="3"></textarea></div>
      <div class="btn-row"><button class="btn" id="chat-send-btn">Send</button></div>
    </div>`;
  await refreshChatThread();
  const typeSelect = document.getElementById('chat-report-type');
  const docIdField = document.getElementById('chat-docid-field');
  const syncDocIdVisibility = () => { docIdField.style.display = DOC_ID_REQUIRED_TYPES.includes(typeSelect.value) ? 'block' : 'none'; };
  typeSelect.addEventListener('change', syncDocIdVisibility);
  syncDocIdVisibility();

  document.getElementById('chat-send-btn').addEventListener('click', async () => {
    const report_type = typeSelect.value;
    const document_id = document.getElementById('chat-document-id').value.trim();
    const message_text = document.getElementById('chat-message-text').value.trim();
    if (!message_text) { alert('Please enter a message.'); return; }
    if (DOC_ID_REQUIRED_TYPES.includes(report_type) && !document_id) { alert('Document ID is required for Revision and Download error reports.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('chat_messages').insert({
      user_id: user.id, user_email: user.email, report_type,
      document_id: document_id ? parseInt(document_id, 10) : null,
      message_text,
    }), 'Sending...');
    document.getElementById('chat-message-text').value = '';
    document.getElementById('chat-document-id').value = '';
    await refreshChatThread();
  });
}

async function refreshChatThread() {
  const rows = await withStatus(sb.from('chat_messages').select('*').order('created_at'));
  const box = document.getElementById('chat-thread');
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">No messages yet - send one below.</div>'; return; }
  box.innerHTML = rows.map(r => {
    const userBubble = `
      <div class="chat-bubble from-user">
        <div class="chat-meta"><span class="chat-tag">${esc(REPORT_TYPE_LABEL[r.report_type] || r.report_type)}</span>${r.document_id ? `Doc #${esc(r.document_id)} · ` : ''}${formatDateTime(r.created_at)}</div>
        ${esc(r.message_text)}
      </div>`;
    const replyBubble = r.reply_text ? `
      <div class="chat-bubble from-admin">
        <div class="chat-meta">Admin · ${formatDateTime(r.replied_at)}</div>
        ${esc(r.reply_text)}
      </div>` : '';
    return userBubble + replyBubble;
  }).join('');
  box.scrollTop = box.scrollHeight;
}

// ---------- Admin inbox ----------

export async function renderAdminMessagesView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  main.innerHTML = `
    <div class="panel">
      <h2>Messages</h2>
      <div class="field-grid">
        <div class="field"><label>User</label><input id="msg-filter-user" type="text" placeholder="Email contains..."></div>
        <div class="field"><label>Report type</label>
          <select id="msg-filter-type"><option value="">All</option>${REPORT_TYPES.map(([c, l]) => `<option value="${c}">${l}</option>`).join('')}</select>
        </div>
        <div class="field"><label>Document ID</label><input id="msg-filter-docid" type="number" min="1"></div>
        <div class="field"><label>&nbsp;</label><label style="text-transform:none;font-size:13px;"><input id="msg-filter-dismissed" type="checkbox" style="width:auto;"> Show dismissed</label></div>
      </div>
      <div class="grid-wrap"><table class="grid" id="msg-grid">
        <thead><tr><th>Date/time</th><th>User</th><th>Type</th><th>Doc ID</th><th>Message</th><th>Reply</th><th></th></tr></thead>
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
  const filtered = emailFilter ? rows.filter(r => (r.user_email || '').toLowerCase().includes(emailFilter)) : rows;

  const body = document.getElementById('msg-grid-body');
  body.innerHTML = filtered.map(r => `
    <tr data-id="${r.id}" class="${r.dismissed ? 'dismissed-row' : ''}">
      <td>${formatDateTime(r.created_at)}</td>
      <td>${esc(r.user_email)}</td>
      <td>${esc(REPORT_TYPE_LABEL[r.report_type] || r.report_type)}</td>
      <td>${r.document_id ? esc(r.document_id) : '—'}</td>
      <td style="white-space:normal;max-width:260px;">${esc(r.message_text)}</td>
      <td><textarea class="msg-reply-input" rows="2" style="min-width:180px;">${esc(r.reply_text)}</textarea></td>
      <td>
        <button class="btn secondary msg-reply-btn" style="padding:4px 10px;">Send</button>
        <button class="btn danger msg-dismiss-btn" style="padding:4px 10px;">Dismiss</button>
      </td>
    </tr>`).join('') || '<tr><td colspan="7">No messages match the current filters.</td></tr>';

  body.querySelectorAll('tr[data-id]').forEach(tr => {
    const id = tr.dataset.id;
    tr.querySelector('.msg-reply-btn').addEventListener('click', async () => {
      const reply_text = tr.querySelector('.msg-reply-input').value.trim();
      if (!reply_text) { alert('Please enter a reply.'); return; }
      const { data: { user } } = await sb.auth.getUser();
      await withStatus(sb.from('chat_messages').update({
        reply_text, replied_at: new Date().toISOString(), replied_by_email: user.email,
      }).eq('id', id), 'Sending reply...');
      await refreshAdminMessages();
    });
    tr.querySelector('.msg-dismiss-btn').addEventListener('click', async () => {
      await withStatus(sb.from('chat_messages').update({ dismissed: true }).eq('id', id), 'Dismissing...');
      await refreshAdminMessages();
    });
  });
}
