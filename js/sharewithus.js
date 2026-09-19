// "Share with us" (95_onboarding_and_share_with_us.sql, PROJECT_HANDOFF for this session): not a
// bug/task report - that stays the existing chat_messages ("Report a Problem or Suggestion",
// chat.js) - but a place for anyone to share an experience, feeling or idea, read by every
// department lead and Admin, not just one department. The owner's own framing: "amore che va e
// che torna" (reciprocal love) - so every lead can thank a share and reply, and several leads can
// each do both on the same share (unlike chat_messages' single reply_text column). Two views,
// dispatched in app.js exactly like chat.js already splits admin/user - see renderTab('chat')
// there for the precedent this follows.

import { sb, esc, withStatus, nameMapForEmails, isAdmin, isAnyDeptLead } from './core.js?v=20260919110557';

function formatDateTime(iso) { return esc((iso || '').slice(0, 16).replace('T', ' ')); }

// ---------- Compose view (anyone without a lead/admin role) ----------

export async function renderShareComposeView(main) {
  const { data: { user } } = await sb.auth.getUser();
  markShareSeen('sharer_' + user.id);
  main.innerHTML = `
    <div class="panel">
      <h2>Share with us</h2>
      <p class="hint">Tell us about your experience with the archive, the paths, or the community - a feeling, an idea, a difficulty, anything you'd like us to hear. This isn't for reporting a technical problem (use "Report a Problem or Suggestion" for that) - every team lead reads this, and may thank you or write back.</p>
      <div class="field"><textarea id="swu-text" dir="auto" rows="4" placeholder="Share what's on your mind..."></textarea></div>
      <div class="btn-row"><button class="btn" id="swu-send">Send</button></div>
      <div class="chat-thread" id="swu-thread" style="margin-top:16px;"></div>
    </div>`;
  await refreshOwnThread();

  document.getElementById('swu-send').addEventListener('click', async () => {
    const body = document.getElementById('swu-text').value.trim();
    if (!body) { alert('Please write something first.'); return; }
    await withStatus(sb.from('share_with_us_messages').insert({ user_id: user.id, user_email: user.email, body }), 'Sending...');
    document.getElementById('swu-text').value = '';
    await refreshOwnThread();
  });
}

async function refreshOwnThread() {
  const box = document.getElementById('swu-thread');
  if (!box) return;
  // No explicit .eq('user_id', ...) - RLS already limits a non-lead/admin caller to their own
  // rows (same convention chat.js's renderChatView uses for chat_messages).
  const messages = await withStatus(sb.from('share_with_us_messages').select('*').order('created_at'));
  if (!messages.length) { box.innerHTML = '<div class="empty-msg">Nothing shared yet - write the first one above.</div>'; return; }
  const ids = messages.map(m => m.id);
  const [reactions, replies] = await Promise.all([
    withStatus(sb.from('share_with_us_reactions').select('*').in('message_id', ids)),
    withStatus(sb.from('share_with_us_replies').select('*').in('message_id', ids).order('created_at')),
  ]);
  const nameMap = await nameMapForEmails([...reactions.map(r => r.user_email), ...replies.map(r => r.user_email)]);

  box.innerHTML = messages.map(m => {
    const myReactions = reactions.filter(r => r.message_id === m.id);
    const myReplies = replies.filter(r => r.message_id === m.id);
    const thanks = myReactions.length ? `<div class="chat-meta" style="margin-top:4px;">&#128591; Thanked by ${myReactions.map(r => esc(nameMap[r.user_email] || r.user_email)).join(', ')}</div>` : '';
    const replyBubbles = myReplies.map(r => `
      <div class="chat-bubble from-other">
        <div class="chat-meta">${esc(nameMap[r.user_email] || r.user_email)} &middot; ${formatDateTime(r.created_at)}</div>
        ${esc(r.body)}
      </div>`).join('');
    return `
      <div class="chat-bubble from-me">
        <div class="chat-meta">${formatDateTime(m.created_at)}</div>
        <div dir="auto">${esc(m.body)}</div>
        ${thanks}
      </div>
      ${replyBubbles}`;
  }).join('');
  box.scrollTop = box.scrollHeight;
}

// ---------- Inbox view (every department lead + Admin) ----------

export async function renderShareInboxView(main) {
  const { data: { user } } = await sb.auth.getUser();
  markShareSeen('lead_' + user.id);
  main.innerHTML = `
    <div class="panel">
      <h2>Share with us</h2>
      <p class="hint">What people have shared - not technical reports, just experiences, feelings and ideas. Every lead and Admin sees every share; thank one, or write back, as many of you as want to.</p>
      <div id="swu-inbox"></div>
    </div>`;
  await refreshInbox(user);
}

async function refreshInbox(user) {
  const box = document.getElementById('swu-inbox');
  if (!box) return;
  const messages = await withStatus(sb.from('share_with_us_messages').select('*').order('created_at', { ascending: false }));
  if (!messages.length) { box.innerHTML = '<div class="empty-msg">Nothing shared yet.</div>'; return; }
  const ids = messages.map(m => m.id);
  const [reactions, replies] = await Promise.all([
    withStatus(sb.from('share_with_us_reactions').select('*').in('message_id', ids)),
    withStatus(sb.from('share_with_us_replies').select('*').in('message_id', ids).order('created_at')),
  ]);
  const nameMap = await nameMapForEmails([
    ...messages.map(m => m.user_email), ...reactions.map(r => r.user_email), ...replies.map(r => r.user_email),
  ]);

  box.innerHTML = messages.map(m => {
    const msgReactions = reactions.filter(r => r.message_id === m.id);
    const msgReplies = replies.filter(r => r.message_id === m.id);
    const iThanked = msgReactions.some(r => r.user_id === user.id);
    return `
      <div class="panel" style="margin-bottom:12px;" data-msg-id="${m.id}">
        <div class="chat-meta">${esc(nameMap[m.user_email] || m.user_email)} &middot; ${formatDateTime(m.created_at)}</div>
        <div dir="auto" style="margin:6px 0;">${esc(m.body)}</div>
        <div class="btn-row" style="align-items:center;">
          <button class="btn ${iThanked ? '' : 'secondary'} swu-thank-btn" style="padding:4px 10px;" data-id="${m.id}" data-next="${!iThanked}">&#128591; ${iThanked ? 'Thanked' : 'Thank you'}</button>
          ${msgReactions.length ? `<span class="hint">${msgReactions.map(r => esc(nameMap[r.user_email] || r.user_email)).join(', ')}</span>` : ''}
        </div>
        <div style="margin-top:8px;display:flex;flex-direction:column;gap:6px;">
          ${msgReplies.map(r => `
            <div class="chat-bubble from-other" style="align-self:flex-start;">
              <div class="chat-meta">${esc(nameMap[r.user_email] || r.user_email)} &middot; ${formatDateTime(r.created_at)}</div>
              ${esc(r.body)}
            </div>`).join('')}
        </div>
        <div class="field" style="margin-top:8px;">
          <textarea class="swu-reply-input" rows="2" placeholder="Write back..."></textarea>
        </div>
        <div class="btn-row"><button class="btn secondary swu-reply-btn" data-id="${m.id}" style="padding:4px 10px;">Reply</button></div>
      </div>`;
  }).join('');

  box.querySelectorAll('.swu-thank-btn').forEach(btn => btn.addEventListener('click', async () => {
    const id = btn.dataset.id;
    if (btn.dataset.next === 'true') {
      await withStatus(sb.from('share_with_us_reactions').insert({ message_id: id, user_id: user.id, user_email: user.email }), 'Saving...');
    } else {
      await withStatus(sb.from('share_with_us_reactions').delete().eq('message_id', id).eq('user_id', user.id), 'Saving...');
    }
    await refreshInbox(user);
  }));

  box.querySelectorAll('.swu-reply-btn').forEach(btn => btn.addEventListener('click', async () => {
    const id = btn.dataset.id;
    const panel = box.querySelector(`[data-msg-id="${id}"]`);
    const body = panel.querySelector('.swu-reply-input').value.trim();
    if (!body) { alert('Please write a reply first.'); return; }
    await withStatus(sb.from('share_with_us_replies').insert({ message_id: id, user_id: user.id, user_email: user.email, body }), 'Sending...');
    await refreshInbox(user);
  }));
}

// ---------- Live "new share" notifications - same pattern as chat.js's initChatNotifications and
// mydepartment.js's initDeptMessageNotifications (localStorage seen-key + Realtime + toast). ----------

function seenKey(who) { return `swuSeenAt_${who}`; }
function getSeenAt(who) { return localStorage.getItem(seenKey(who)) || '1970-01-01T00:00:00.000Z'; }
function markShareSeen(who) { localStorage.setItem(seenKey(who), new Date().toISOString()); }

function showShareToast(title, message, onView) {
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

let shareNotifyChannel = null;

// Called once per login (from app.js, after the dashboard is first shown), same convention as
// initChatNotifications/initTaskNotifications/initDeptMessageNotifications.
export async function initShareNotifications(navigateToShare) {
  if (shareNotifyChannel) { sb.removeChannel(shareNotifyChannel); shareNotifyChannel = null; }
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return;
  const iAmLead = isAnyDeptLead() || isAdmin();

  if (iAmLead) {
    const who = 'lead_' + user.id;
    const { data } = await sb.from('share_with_us_messages').select('id').gt('created_at', getSeenAt(who));
    if (data && data.length) showShareToast('Share with us', `${data.length} new share${data.length > 1 ? 's' : ''} waiting.`, navigateToShare);

    shareNotifyChannel = sb.channel('share-with-us-notify-lead')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'share_with_us_messages' }, () => {
        showShareToast('Share with us', 'Someone just shared something new.', navigateToShare);
      })
      .subscribe();
  } else {
    const who = 'sharer_' + user.id;
    const seenAt = getSeenAt(who);
    const [{ data: myMessages }, { data: newReplies }] = await Promise.all([
      sb.from('share_with_us_messages').select('id'),
      sb.from('share_with_us_replies').select('message_id').gt('created_at', seenAt),
    ]);
    const myIds = new Set((myMessages || []).map(m => m.id));
    if ((newReplies || []).some(r => myIds.has(r.message_id))) {
      showShareToast('Share with us', 'Someone wrote back on what you shared.', navigateToShare);
    }

    shareNotifyChannel = sb.channel('share-with-us-notify-' + user.id)
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'share_with_us_replies' }, async payload => {
        const { data } = await sb.from('share_with_us_messages').select('id').eq('id', payload.new.message_id).eq('user_id', user.id).maybeSingle();
        if (data) showShareToast('Share with us', 'Someone wrote back on what you shared.', navigateToShare);
      })
      .subscribe();
  }
}
