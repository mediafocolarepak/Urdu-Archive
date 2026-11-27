// "Share with us" (95_onboarding_and_share_with_us.sql, PROJECT_HANDOFF for this session): not a
// bug/task report - that stays the existing chat_messages ("Report a Problem or Suggestion",
// chat.js) - but a place for anyone to share an experience, feeling or idea, read by every
// department lead and Admin, not just one department. The owner's own framing: "amore che va e
// che torna" (reciprocal love) - so every lead can thank a share and reply, and several leads can
// each do both on the same share (unlike chat_messages' single reply_text column). Two views,
// dispatched in app.js exactly like chat.js already splits admin/user - see renderTab('chat')
// there for the precedent this follows.

import { nameMapForIds, sb, State, esc, labelOf, withStatus, isAdmin, isAnyDeptLead, canRecordAudio, mountVoiceRecorder, uploadVoice } from './core.js?v=20261127123527';

function formatDateTime(iso) { return esc((iso || '').slice(0, 16).replace('T', ' ')); }

// ---------- Voice messages (96_share_with_us_audio.sql, phase 1b) ----------
// For someone who struggles typing a second script on a phone - the whole reason this feature exists. The recorder is
// core.js mountVoiceRecorder (shared with Report a problem since 2026-11-23); not offered where the browser can't record.
const SHARE_AUDIO_BUCKET = 'share-with-us-audio';

// ---------- The one door, for Users and Operators (Owner's decision, 2026-11-25) ----------
// "Share with us" rather than "Report a problem", because one can also speak. Inside, what it is about: an experience goes to
// the leads of the departments and the Admins (share_with_us_messages, as before); the others are the reports of before
// (chat_messages), read by Coordinators and Admins, and the ideas by the leads too (166_ideas_for_leads.sql). Speaking comes
// first, writing second; after sending, a large "Thank you". The answers of both kinds are in one list.
const SHARE_KINDS = [
  ['EXPERIENCE', '&#128155;', 'My experience with the App'],
  ['SUGGESTION', '&#128161;', 'How to improve the app, an idea'],
  ['REVISION', '&#128214;', 'A mistake in a text'],
  ['BUG', '&#9888;&#65039;', "Something doesn't work"],
];
const kindLabel = code => (SHARE_KINDS.find(k => k[0] === code) || [])[2] || labelOf(State.optionListsByName.report_type || [], code) || code;
const kindSign = code => (SHARE_KINDS.find(k => k[0] === code) || [])[1] || '&#128172;';
const REPORT_AUDIO_BUCKET = 'report-audio';

export async function renderShareComposeView(main) {
  const { data: { user } } = await sb.auth.getUser();
  markShareSeen('sharer_' + user.id);
  localStorage.setItem('chatSeenAt_user_' + user.id, new Date().toISOString());
  const voice = canRecordAudio();
  // Coming from a document: its number, and the passage copied from its text if there is one.
  const about = State.shareDocument || '', passage = State.chatMessagePrefill || '';
  State.shareDocument = null;
  State.chatMessagePrefill = null;
  State.shareDoor = false;
  let kind = passage ? 'REVISION' : '';
  main.innerHTML = `
    <div class="panel share-door">
      <h2>Share with us</h2>
      <label id="swu-kind-label">What would you like to share?</label>
      <div class="report-kinds share-kinds" role="group" aria-labelledby="swu-kind-label">
        ${SHARE_KINDS.map(([code, icon, label]) => `<button type="button" class="report-kind" data-kind="${code}" aria-pressed="${code === kind}"><span class="report-kind-icon" aria-hidden="true">${icon}</span>${esc(label)}</button>`).join('')}
      </div>
      <p class="hint" id="swu-who"></p>
      <div class="field" id="swu-doc-field"><label for="swu-doc">Document number <span class="hint">(if it is about a document)</span></label><input id="swu-doc" type="number" min="1" inputmode="numeric" value="${esc(about)}" style="max-width:200px;"></div>
      ${voice ? '<label>Say it</label><div id="swu-voice" class="field"></div>' : ''}
      <div class="field"><label for="swu-text">${voice ? 'Or write it' : 'Write it'}</label><textarea id="swu-text" dir="auto" rows="4" placeholder="In the language you prefer">${esc(passage)}</textarea></div>
      <div class="btn-row"><button class="btn big-btn" id="swu-send">Send</button></div>
      <h3 style="margin-top:20px;">What you shared, and our answers</h3>
      <div class="chat-thread" id="swu-thread"></div>
    </div>`;
  const recorder = voice ? mountVoiceRecorder(document.getElementById('swu-voice')) : null;
  const showKind = () => {
    main.querySelectorAll('.report-kind').forEach(x => x.setAttribute('aria-pressed', String(x.dataset.kind === kind)));
    document.getElementById('swu-doc-field').hidden = kind === 'EXPERIENCE' || (!kind && !about);
    document.getElementById('swu-who').textContent = !kind ? '' : kind === 'EXPERIENCE' ? 'The leads of the departments and the Admins will read or hear it.'
      : kind === 'SUGGESTION' ? 'The Coordinators, the leads of the departments and the Admins will read or hear it.' : 'The Coordinators and the Admins will read or hear it.';
  };
  main.querySelectorAll('.report-kind').forEach(b => b.addEventListener('click', () => { kind = b.dataset.kind; showKind(); }));
  showKind();
  refreshOwnThread(user).catch(e => console.warn('Share with us:', e));

  document.getElementById('swu-send').addEventListener('click', async () => {
    const body = document.getElementById('swu-text').value.trim();
    const audio = recorder && recorder.audio;
    if (!kind) { alert('Please choose first what you would like to share.'); return; }
    if (!body && !audio) { alert(voice ? 'Please record or write something first.' : 'Please write something first.'); return; }
    let audio_path = null, audio_mime_type = null;
    if (audio) {
      try { ({ path: audio_path, mimeType: audio_mime_type } = await uploadVoice(kind === 'EXPERIENCE' ? SHARE_AUDIO_BUCKET : REPORT_AUDIO_BUCKET, user.id, audio)); }
      catch (err) { alert('The voice message could not be sent. Please write your message instead. (' + err.message + ')'); return; }
    }
    if (kind === 'EXPERIENCE') {
      await withStatus(sb.from('share_with_us_messages').insert({ user_id: user.id, body: body || null, audio_path, audio_mime_type }), 'Sending...');
    } else {
      const doc = parseInt(document.getElementById('swu-doc').value, 10);
      await withStatus(sb.from('chat_messages').insert({
        user_id: user.id, user_email: user.email, report_type: kind, document_id: Number.isFinite(doc) ? doc : null, message_text: body || null,
        ...(audio_path ? { audio_path, audio_mime_type } : {}),
      }), 'Sending...');
    }
    main.innerHTML = `
      <div class="panel thank-you">
        <div class="thank-you-mark" aria-hidden="true">&#10004;</div>
        <h2>Thank you</h2>
        <p>What you shared has reached the team. Our answer, if there is one, will appear under "What you shared, and our answers".</p>
        <div class="btn-row" style="justify-content:center;">
          <button class="btn big-btn" id="ty-home">Back to Home</button>
          <button class="btn secondary" id="ty-again">See what I shared</button>
        </div>
      </div>`;
    document.getElementById('ty-home').addEventListener('click', () => window.__renderTab('onboarding', 'home'));
    document.getElementById('ty-again').addEventListener('click', () => renderShareComposeView(main));
  });
}

// What this person shared, of both kinds, the newest first, each with its answers. Asked for by person: a lead may read more.
async function refreshOwnThread(user) {
  const [messages, reports] = await Promise.all([
    withStatus(sb.from('share_with_us_messages').select('*').eq('user_id', user.id).order('created_at', { ascending: false })),
    withStatus(sb.from('chat_messages').select('*').eq('user_id', user.id).order('created_at', { ascending: false })),
  ]);
  const ids = messages.map(m => m.id);
  const [reactions, replies] = ids.length ? await Promise.all([
    withStatus(sb.from('share_with_us_reactions').select('*').in('message_id', ids)),
    withStatus(sb.from('share_with_us_replies').select('*').in('message_id', ids).order('created_at')),
  ]) : [[], []];
  const [nameMap, shareAudio, reportAudio] = await Promise.all([
    nameMapForIds([...reactions.map(r => r.user_id), ...replies.map(r => r.user_id)]), signedAudioUrls(messages), signedAudioUrls(reports, REPORT_AUDIO_BUCKET),
  ]);
  const box = document.getElementById('swu-thread');
  if (!box) return;
  const all = [...messages.map(m => ({ kind: 'EXPERIENCE', at: m.created_at, m })), ...reports.map(m => ({ kind: m.report_type, at: m.created_at, m }))].sort((a, b) => (a.at < b.at ? 1 : -1));
  if (!all.length) { box.innerHTML = '<div class="empty-msg">Nothing shared yet.</div>'; return; }
  box.innerHTML = all.map(({ kind, m }) => {
    const mine = kind === 'EXPERIENCE';
    const thanks = mine ? reactions.filter(r => r.message_id === m.id) : [];
    const answers = mine ? replies.filter(r => r.message_id === m.id).map(r => [nameMap[r.user_id], r.created_at, r.body]) : m.reply_text ? [['The team', m.replied_at, m.reply_text]] : [];
    return `
      <div class="chat-bubble from-me">
        <div class="chat-meta"><span aria-hidden="true">${kindSign(kind)}</span> ${esc(kindLabel(kind))}${m.document_id ? ` &middot; #${esc(m.document_id)}` : ''} &middot; ${formatDateTime(m.created_at)}</div>
        ${m.body || m.message_text ? `<div dir="auto" style="white-space:pre-wrap;">${esc(m.body || m.message_text)}</div>` : ''}
        ${audioPlayerHtml(m, mine ? shareAudio : reportAudio)}
        ${thanks.length ? `<div class="chat-meta" style="margin-top:4px;">&#128591; Thanked by ${thanks.map(r => esc(nameMap[r.user_id])).join(', ')}</div>` : ''}
      </div>
      ${answers.map(([who, at, text]) => `<div class="chat-bubble from-other"><div class="chat-meta">${esc(who)} &middot; ${formatDateTime(at)}</div><div dir="auto" style="white-space:pre-wrap;">${esc(text)}</div></div>`).join('')}`;
  }).join('');
}

// Shared by both views: batch-fetch signed URLs (the bucket is private) for every message that
// has a voice recording - same createSignedUrls pattern mydepartment.js's Team channel already
// uses for its own (also private) images.
async function signedAudioUrls(messages, bucket = SHARE_AUDIO_BUCKET) {
  const paths = messages.filter(m => m.audio_path).map(m => m.audio_path);
  if (!paths.length) return {};
  const { data } = await sb.storage.from(bucket).createSignedUrls(paths, 3600);
  const map = {};
  (data || []).forEach(d => { if (d && d.signedUrl) map[d.path] = d.signedUrl; });
  return map;
}

function audioPlayerHtml(m, audioUrlByPath) {
  if (!m.audio_path || !audioUrlByPath[m.audio_path]) return '';
  return `<div style="margin-top:6px;"><audio controls src="${esc(audioUrlByPath[m.audio_path])}" type="${esc(m.audio_mime_type || '')}"></audio></div>`;
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
    </div>
    <div id="swu-ideas"></div>`;
  await refreshInbox(user);
  refreshIdeas(document.getElementById('swu-ideas')).catch(e => console.warn('Ideas:', e));
}

// The ideas to improve the app, which the leads read too (166_ideas_for_leads.sql). Coordinators and Admins answer from Messages.
async function refreshIdeas(box) {
  const { data: { user } } = await sb.auth.getUser();
  const rows = (await withStatus(sb.from('chat_messages').select('*').eq('report_type', 'SUGGESTION').eq('dismissed', false).order('created_at', { ascending: false }).limit(100))).filter(r => r.user_id !== user.id || isAdmin());
  if (!rows.length || !box || !box.isConnected) return;
  const [names, audio] = await Promise.all([nameMapForIds(rows.map(r => r.user_id)), signedAudioUrls(rows, REPORT_AUDIO_BUCKET)]);
  box.innerHTML = `<div class="panel"><h2>Ideas to improve the app <span class="count-badge">${rows.length}</span></h2>
    <p class="hint">The Coordinators and the Admins answer them.</p>
    ${rows.map(r => `<div class="panel" style="margin-bottom:12px;">
      <div class="chat-meta">${esc(names[r.user_id] || '')} &middot; ${formatDateTime(r.created_at)}${r.document_id ? ` &middot; #${esc(r.document_id)}` : ''}</div>
      ${r.message_text ? `<div dir="auto" style="margin:6px 0;white-space:pre-wrap;">${esc(r.message_text)}</div>` : ''}${audioPlayerHtml(r, audio)}
      ${r.reply_text ? `<div class="chat-bubble from-other"><div class="chat-meta">Answered &middot; ${formatDateTime(r.replied_at)}</div><div dir="auto">${esc(r.reply_text)}</div></div>` : ''}
    </div>`).join('')}</div>`;
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
  const nameMap = await nameMapForIds([...messages, ...reactions, ...replies].map(r => r.user_id));
  const audioUrlByPath = await signedAudioUrls(messages);

  box.innerHTML = messages.map(m => {
    const msgReactions = reactions.filter(r => r.message_id === m.id);
    const msgReplies = replies.filter(r => r.message_id === m.id);
    const iThanked = msgReactions.some(r => r.user_id === user.id);
    return `
      <div class="panel" style="margin-bottom:12px;" data-msg-id="${m.id}">
        <div class="chat-meta">${esc(nameMap[m.user_id] || '')} &middot; ${formatDateTime(m.created_at)}</div>
        ${m.body ? `<div dir="auto" style="margin:6px 0;">${esc(m.body)}</div>` : ''}
        ${audioPlayerHtml(m, audioUrlByPath)}
        <div class="btn-row" style="align-items:center;">
          <button class="btn ${iThanked ? '' : 'secondary'} swu-thank-btn" style="padding:4px 10px;" data-id="${m.id}" data-next="${!iThanked}">&#128591; ${iThanked ? 'Thanked' : 'Thank you'}</button>
          ${msgReactions.length ? `<span class="hint">${msgReactions.map(r => esc(nameMap[r.user_id] || '')).join(', ')}</span>` : ''}
        </div>
        <div style="margin-top:8px;display:flex;flex-direction:column;gap:6px;">
          ${msgReplies.map(r => `
            <div class="chat-bubble from-other" style="align-self:flex-start;">
              <div class="chat-meta">${esc(nameMap[r.user_id] || '')} &middot; ${formatDateTime(r.created_at)}</div>
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
      await withStatus(sb.from('share_with_us_reactions').insert({ message_id: id, user_id: user.id }), 'Saving...');
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
    await withStatus(sb.from('share_with_us_replies').insert({ message_id: id, user_id: user.id, body }), 'Sending...');
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
  toast.className = 'toast-notification' + (isAnyDeptLead() || isAdmin() ? ' work-toast' : '');
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
      sb.from('share_with_us_messages').select('id').eq('user_id', user.id),
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
