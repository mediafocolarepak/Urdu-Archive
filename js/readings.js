// Read aloud: anyone signed in can record a text (114_readings.sql, Documentazione\PROTOCOLLO_Ingresso_
// archivio_v1.md §10). Consent, holding the text for 7 days, recording or uploading, then a listening
// review. A recording stays on the phone (IndexedDB) until the server has confirmed it, so a phone call
// or a closed page doesn't lose it. The database is the real gate: this module collects and shows.

import {
  sb, State, esc, withStatus, labelOf, isAdmin, isCoordinator, isDeptMember, AUDIO_BUCKET, AUDIO_FORMATS,
  audioFileProblem, audioDurationOf, mountAudioPlayer, eraseMyAudioFiles,
  helpLinkHtml,
} from './core.js?v=20261107190326';

// AAC in MP4 first, the likeliest to play on every phone; plain 'audio/mp4' can hold Opus, as in Chrome.
const RECORD_FORMATS = ['audio/mp4;codecs=mp4a.40.2', 'audio/mp4', 'audio/webm;codecs=opus', 'audio/webm', 'audio/ogg;codecs=opus'];
const MAX_RECORD_SECONDS = 45 * 60; // stays well under the bucket's 25 MB at 64 kbit/s
const TRIAL_SECONDS = 10;
const UPLOAD_ATTEMPTS = 3;
const STATUS_LABELS = { submitted: 'Waiting to be heard', to_correct: 'To record again', published: 'Published', rejected: 'Not accepted', draft: 'Not sent yet' };

let currentTab = 'mine';
let active = null; // the recording in progress, so leaving the screen can stop it safely

const scrollTop = () => { document.getElementById('main').scrollTop = 0; };
const mmss = s => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, '0')}`;
const dateOf = iso => (iso || '').slice(0, 10);
async function act(fn) {
  try { await fn(); return true; }
  catch (e) { alert(e.message); return false; }
}

// ---------- Keeping a recording on the phone until it has arrived ----------
// Every step is in try/catch: in a private window there may be no storage, and recording still works,
// only without the safety net.
const DB_NAME = 'dua-readings';
function openDb() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1);
    req.onupgradeneeded = () => req.result.createObjectStore('chunks', { autoIncrement: true }).createIndex('doc', 'doc');
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}
async function saveChunk(doc, blob, mime, seconds) {
  try {
    const db = await openDb();
    db.transaction('chunks', 'readwrite').objectStore('chunks').add({ doc, blob, mime, seconds });
    db.close();
  } catch { /* not essential */ }
}
async function loadChunks(doc) {
  try {
    const db = await openDb();
    const rows = await new Promise((resolve, reject) => {
      const req = db.transaction('chunks').objectStore('chunks').index('doc').getAll(doc);
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
    db.close();
    return rows;
  } catch { return []; }
}
async function clearChunks(doc) {
  try {
    const db = await openDb();
    const store = db.transaction('chunks', 'readwrite').objectStore('chunks');
    const req = store.index('doc').openKeyCursor(doc);
    await new Promise(resolve => {
      req.onsuccess = () => { if (req.result) { store.delete(req.result.primaryKey); req.result.continue(); } else resolve(); };
      req.onerror = () => resolve();
    });
    db.close();
  } catch { /* not essential */ }
}
async function recoveredTake(doc) {
  const rows = await loadChunks(doc);
  if (!rows.length) return null;
  const mime = rows[0].mime;
  return { blob: new Blob(rows.map(r => r.blob), { type: mime }), mime, seconds: Math.max(...rows.map(r => r.seconds || 0)) };
}

// ---------- The section ----------
export async function renderReadingsView(main) {
  stopActiveRecording();
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  if (State.readingTarget) {
    const target = State.readingTarget;
    State.readingTarget = null;
    await openReading(main, target);
    return;
  }
  const canListen = await withStatus(sb.rpc('can_review_readings'));
  const canSeeReaders = isAdmin() || isCoordinator() || isDeptMember('HR') || isDeptMember('COORD');
  const tabs = [['mine', 'My readings']];
  if (canListen) tabs.push(['listen', 'To listen']);
  if (canSeeReaders) tabs.push(['readers', 'Readers']);
  if (!tabs.some(([id]) => id === currentTab)) currentTab = 'mine';
  main.innerHTML = `
    <div class="panel">
      <h2>Read aloud ${helpLinkHtml('read-aloud')}</h2>
      <p class="hint">Your voice can bring a text to those who find reading difficult. Someone listens first; then your reading is in the archive with your name.</p>
      ${tabs.length > 1 ? `<div class="btn-row">${tabs.map(([id, label]) => `<button class="btn ${id === currentTab ? '' : 'secondary'}" data-rd-tab="${id}">${esc(label)}</button>`).join('')}</div>` : ''}
    </div>
    <div id="rd-body"></div>`;
  main.querySelectorAll('[data-rd-tab]').forEach(b => b.addEventListener('click', () => {
    currentTab = b.dataset.rdTab;
    renderReadingsView(main);
  }));
  const body = document.getElementById('rd-body');
  if (currentTab === 'listen') await renderQueue(main, body);
  else if (currentTab === 'readers') await renderReaders(main, body);
  else await renderMine(main, body);
  refreshReadingsBadge();
}

// The number of the text, beside its title: with it, the ID # box in the Library finds it again.
const docNumber = id => (id === null || id === undefined ? '' : `#${esc(id)} &middot; `);

// ---------- My readings ----------
async function renderMine(main, body) {
  await eraseMyAudioFiles();
  const d = await withStatus(sb.rpc('get_my_readings'));
  body.innerHTML = `
    ${d.readings.length ? `<div class="panel"><h3 style="margin-top:0;">My readings</h3>
      ${d.readings.map(r => `
        <div class="subpanel" data-id="${esc(r.id)}" style="margin-top:12px;">
          <div style="font-weight:600;" dir="auto">${esc(r.title) || '<span class="hint">(no title)</span>'}</div>
          <div class="hint">${docNumber(r.source_document_id ?? r.document_id)}${esc(STATUS_LABELS[r.status] || r.status)}${r.status === 'submitted' ? ` ${r.days_waiting === 0 ? 'since today' : `for ${esc(r.days_waiting)} day${r.days_waiting === 1 ? '' : 's'}`}${r.in_review ? ' &middot; someone is listening to it' : ''}` : ''}${r.duration ? ` &middot; ${esc(r.duration)}` : ''}</div>
          ${r.decision_note ? `<p style="white-space:pre-wrap;margin:6px 0;" dir="auto"><b>From who listened:</b> ${esc(r.decision_note)}</p>` : ''}
          <div class="rd-player"></div>
          <div class="btn-row">
            ${r.path ? '<button class="btn secondary rd-play">&#128266; Listen</button>' : ''}
            ${r.status === 'to_correct' ? '<button class="btn rd-again">Record again</button>' : ''}
            ${r.status === 'submitted' ? `<button class="btn secondary rd-remind" ${r.reminder_allowed ? '' : 'disabled'}>Send a reminder</button>` : ''}
          </div>
          ${r.status === 'submitted' && !r.reminder_allowed ? `<div class="hint">A reminder can be sent from ${esc(dateOf(r.next_reminder_at))}.</div>` : ''}
        </div>`).join('')}
    </div>` : ''}
    ${d.held.length ? `<div class="panel"><h3 style="margin-top:0;">Texts you are holding</h3>
      ${d.held.map(h => `
        <div class="subpanel" data-held="${esc(h.document_id)}" style="margin-top:12px;">
          <div style="font-weight:600;" dir="auto">${esc(h.title)}</div>
          <div class="hint">${docNumber(h.document_id)}${esc(labelOf(State.langs, h.language))} &middot; yours until ${esc(dateOf(h.expires_at))}</div>
          <div class="btn-row"><button class="btn rd-record">Record</button><button class="btn secondary rd-release">Let it go</button></div>
        </div>`).join('')}
    </div>` : ''}
    <div class="panel">
      <h3 style="margin-top:0;">Texts waiting for a voice</h3>
      <p class="hint" style="margin-top:0;">${d.limit <= 4000 ? 'Your first reading is a short one, so you can get used to it. ' : ''}You can also start from any text in the Library, with its Read aloud button.</p>
      ${d.waiting.length ? d.waiting.map(w => `
        <div class="btn-row" data-wait="${esc(w.document_id)}" style="justify-content:space-between;align-items:center;border-top:1px solid var(--line);padding:6px 0;margin:0;">
          <div style="min-width:0;"><div dir="auto">${esc(w.title) || '<span class="hint">(no title)</span>'}</div>
            <div class="hint">${docNumber(w.document_id)}${esc(labelOf(State.langs, w.language))} &middot; about ${esc(Math.max(1, Math.round(w.chars / 900)))} min</div></div>
          <button class="btn secondary rd-take" style="padding:3px 10px;white-space:nowrap;">Read this</button>
        </div>`).join('') : '<div class="empty-msg">No texts are waiting right now.</div>'}
    </div>
    ${d.consented ? `<div class="panel"><h3 style="margin-top:0;">Your consent</h3>
      <p class="hint" style="margin-top:0;">You can change your mind at any time. Your readings are removed at once and their files erased.</p>
      <div class="btn-row"><button class="btn danger" id="rd-withdraw">Withdraw my consent</button></div>
    </div>` : ''}`;

  body.querySelectorAll('[data-id]').forEach(card => {
    const r = d.readings.find(x => String(x.id) === card.dataset.id);
    card.querySelector('.rd-play')?.addEventListener('click', () => mountAudioPlayer(card.querySelector('.rd-player'), { path: r.path }, true));
    card.querySelector('.rd-again')?.addEventListener('click', () => openReading(main, r.source_document_id));
    card.querySelector('.rd-remind')?.addEventListener('click', async () => {
      if (await act(() => withStatus(sb.rpc('send_submission_reminder', { p_id: r.id }), 'Sending...'))) {
        alert('Reminder sent: it now stands out for everyone who listens.');
        renderReadingsView(main);
      }
    });
  });
  body.querySelectorAll('[data-held]').forEach(card => {
    const id = parseInt(card.dataset.held, 10);
    card.querySelector('.rd-record').addEventListener('click', () => openReading(main, id));
    card.querySelector('.rd-release').addEventListener('click', async () => {
      if (!confirm('Let this text go, so that someone else can read it?')) return;
      await clearChunks(id);
      if (await act(() => withStatus(sb.rpc('release_reading', { p_document_id: id }), 'Saving...'))) renderReadingsView(main);
    });
  });
  body.querySelectorAll('[data-wait]').forEach(row => {
    row.querySelector('.rd-take').addEventListener('click', () => openReading(main, parseInt(row.dataset.wait, 10)));
  });
  document.getElementById('rd-withdraw')?.addEventListener('click', async () => {
    if (!confirm('Withdraw your consent? All your readings are removed at once and their files erased. This cannot be undone.')) return;
    const ok = await act(async () => {
      await withStatus(sb.rpc('withdraw_reading_consent', { p_user_id: null }), 'Removing your readings...');
      await eraseMyAudioFiles();
      try { indexedDB.deleteDatabase(DB_NAME); } catch { /* nothing kept here */ }
    });
    if (ok) { alert('Done: your readings have been removed.'); renderReadingsView(main); }
  });
}

// ---------- From a text to its recorder: state, consent, holding ----------
const STATE_MESSAGES = {
  not_text: 'This is not a text that can be read aloud.',
  reserved_level: 'Reserved texts are recorded by the team, not from here.',
  no_text: 'This document has no text to read yet.',
  not_reviewed: 'This text has not been checked yet, so it cannot be recorded for now.',
  has_reading: 'This text already has a reading.',
  taken: 'Someone is reading this text at the moment.',
  in_review: 'Your reading of this text is waiting to be heard.',
};

async function openReading(main, documentId) {
  scrollTop();
  const s = await withStatus(sb.rpc('reading_state', { p_document_id: documentId }));
  if (s.state === 'too_long') {
    showNotice(main, s.limit <= 4000 ? 'This text is long for a first reading. Please begin with a shorter one: you will find some in Texts waiting for a voice.' : 'This text is too long to record in one go. Reading in parts will come later.');
    return;
  }
  if (!['available', 'mine', 'rerecord'].includes(s.state)) { showNotice(main, STATE_MESSAGES[s.state] || 'This text cannot be read right now.'); return; }
  if (!s.consented) { await renderConsent(main, documentId); return; }
  if (s.state === 'available') {
    if (!await act(() => withStatus(sb.rpc('reserve_reading', { p_document_id: documentId }), 'Holding the text for you...'))) return;
  }
  await renderRecorder(main, documentId, s);
}

function showNotice(main, message) {
  main.innerHTML = `<div class="panel"><p>${esc(message)}</p><div class="btn-row"><button class="btn secondary" id="rd-back">Back</button></div></div>`;
  document.getElementById('rd-back').addEventListener('click', () => renderReadingsView(main));
}

async function renderConsent(main, documentId) {
  const rows = await withStatus(sb.from('reading_consent_texts').select('version,body_en,body_ur').eq('active', true));
  const consent = rows[0];
  const { data: { user } } = await sb.auth.getUser();
  const profile = await withStatus(sb.from('user_profiles').select('full_name').eq('user_id', user.id));
  const name = profile[0]?.full_name;
  main.innerHTML = `
    <div class="panel">
      ${consent.body_ur ? `<div dir="auto" style="white-space:pre-wrap;font-size:17px;line-height:2;margin-bottom:14px;">${esc(consent.body_ur)}</div>` : ''}
      <div style="white-space:pre-wrap;line-height:1.6;">${esc(consent.body_en)}</div>
      <p style="margin-top:12px;">${name ? `Your name will appear as: <b dir="auto">${esc(name)}</b>. You can change it in My Profile.` : '<b>Please add your name in My Profile first: it is shown next to your readings.</b>'}</p>
      <div class="btn-row">
        <button class="btn" id="rd-accept" ${name ? '' : 'disabled'}>I agree, continue</button>
        <button class="btn secondary" id="rd-decline">Not now</button>
      </div>
    </div>`;
  document.getElementById('rd-decline').addEventListener('click', () => renderReadingsView(main));
  document.getElementById('rd-accept').addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('accept_reading_consent'), 'Saving...'))) openReading(main, documentId);
  });
}

// ---------- The recorder ----------
function stopActiveRecording() {
  if (active) active.abandon();
  active = null;
}

function recordingFormat() {
  if (!window.MediaRecorder || !navigator.mediaDevices?.getUserMedia) return null;
  return RECORD_FORMATS.find(f => MediaRecorder.isTypeSupported(f)) || null;
}

// mime as the browser gives it, without codecs -> how the bucket keeps it
function storedFormat(mime) {
  const base = (mime || '').split(';')[0];
  if (base === 'audio/mp4') return ['m4a', 'audio/mp4'];
  if (base === 'audio/ogg') return ['ogg', 'audio/ogg'];
  if (base === 'audio/aac') return ['aac', 'audio/aac'];
  if (base === 'audio/mpeg') return ['mp3', 'audio/mpeg'];
  return ['webm', 'audio/webm'];
}

async function renderRecorder(main, documentId, state) {
  const [docs, texts] = await Promise.all([
    withStatus(sb.from('documents').select('document_id,title,en_title,ur_title,original_title,language').eq('document_id', documentId)),
    withStatus(sb.from('document_texts').select('body').eq('document_id', documentId)),
  ]);
  const doc = docs[0];
  const format = recordingFormat();
  scrollTop();
  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 8px;">
        <h2 style="margin:0;" dir="auto">${esc(doc.ur_title || doc.original_title || doc.en_title || doc.title)}</h2>
        <button class="btn secondary" id="rc-back">Back</button>
      </div>
      <div class="hint">Document #${esc(documentId)}</div>
      ${state.note ? `<p style="white-space:pre-wrap;" dir="auto"><b>From who listened:</b> ${esc(state.note)}</p>` : ''}
      <div id="rc-recovered"></div>
      <div id="rc-trial" class="subpanel" ${format ? '' : 'hidden'}>
        <b>First, try ${TRIAL_SECONDS} seconds</b>
        <div class="hint">Read a line at your normal distance from the phone, then listen: is the voice clear? Is it a quiet room?</div>
        <div class="btn-row"><button class="btn secondary" id="rc-trial-start">Try now</button></div>
        <div id="rc-trial-result"></div>
      </div>
      ${format ? '' : '<p class="hint">This browser cannot record here. You can still record with your phone\'s own recorder, and upload the file below.</p>'}
      <div class="subpanel" style="margin-top:12px;">
        <b>Or upload a recording made with your phone</b>
        <div class="hint">MP3 or M4A plays on every phone. Up to 25 MB.</div>
        <input id="rc-file" type="file" accept=".mp3,.m4a,.mp4,.aac,.ogg,.opus,.webm,audio/*" style="margin-top:6px;">
      </div>
    </div>
    <div class="panel"><div dir="auto" class="reading-text" style="font-size:24px;" id="rc-text">${esc(texts[0]?.body)}</div></div>
    <div class="panel" id="rc-controls" style="position:sticky;bottom:0;z-index:5;margin-bottom:0;"></div>`;

  document.getElementById('rc-back').addEventListener('click', () => renderReadingsView(main));
  const controls = document.getElementById('rc-controls');

  const showIdle = () => {
    controls.innerHTML = format
      ? '<div class="btn-row" style="margin:0;"><button class="btn" id="rc-start">&#127908; Start recording</button></div><div class="hint">You can pause between paragraphs. Please keep this screen on.</div>'
      : '';
    document.getElementById('rc-start')?.addEventListener('click', startTake);
  };

  const showTake = take => {
    const url = URL.createObjectURL(take.blob);
    controls.innerHTML = `
      <audio controls src="${esc(url)}" style="width:100%;"></audio>
      <div class="hint">${esc(mmss(take.seconds))} &middot; ${esc((take.blob.size / 1024 / 1024).toFixed(1))} MB. Please listen before sending. It stays on this phone until it has arrived.</div>
      <div class="btn-row" style="margin-bottom:0;">
        <button class="btn" id="rc-send">Send to be heard</button>
        ${format ? '<button class="btn secondary" id="rc-redo">Record again</button>' : ''}
      </div>
      <div id="rc-status" class="hint" role="status"></div>`;
    document.getElementById('rc-redo')?.addEventListener('click', async () => {
      if (!confirm('Delete this recording and start again?')) return;
      await clearChunks(documentId);
      URL.revokeObjectURL(url);
      showIdle();
    });
    document.getElementById('rc-send').addEventListener('click', async () => {
      const btn = document.getElementById('rc-send');
      btn.disabled = true;
      const ok = await sendTake(documentId, take, 'app', document.getElementById('rc-status'));
      if (ok) { await clearChunks(documentId); currentTab = 'mine'; renderReadingsView(main); }
      else btn.disabled = false;
    });
  };

  const startTake = async () => {
    await clearChunks(documentId);
    const session = await startRecording({
      format,
      onChunk: (blob, mime, seconds) => saveChunk(documentId, blob, mime, seconds),
      onTick: seconds => {
        // Another tab was opened: stop, and what was recorded is offered again on coming back.
        if (!controls.isConnected) { stopActiveRecording(); return; }
        const t = document.getElementById('rc-timer');
        if (t) t.textContent = mmss(seconds);
      },
      maxSeconds: MAX_RECORD_SECONDS,
      onFinish: take => { active = null; if (controls.isConnected) showTake(take); },
      onProblem: message => { const s = document.getElementById('rc-rec-note'); if (s) s.textContent = message; },
    });
    if (!session) { showIdle(); return; }
    active = session;
    controls.innerHTML = `
      <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
        <span id="rc-timer" style="font-size:24px;font-weight:600;font-variant-numeric:tabular-nums;">0:00</span>
        <button class="btn secondary" id="rc-pause">Pause</button>
        <button class="btn" id="rc-stop">Finish</button>
      </div>
      <div id="rc-rec-note" class="hint" role="status">Recording.</div>`;
    document.getElementById('rc-pause').addEventListener('click', e => {
      const paused = session.togglePause();
      e.currentTarget.textContent = paused ? 'Continue' : 'Pause';
      document.getElementById('rc-rec-note').textContent = paused ? 'Paused.' : 'Recording.';
    });
    document.getElementById('rc-stop').addEventListener('click', () => session.stop());
  };

  document.getElementById('rc-trial-start')?.addEventListener('click', async e => {
    const btn = e.currentTarget;
    const result = document.getElementById('rc-trial-result');
    btn.disabled = true;
    result.innerHTML = '<div class="hint" role="status">Recording the trial...</div>';
    const session = await startRecording({
      format,
      maxSeconds: TRIAL_SECONDS,
      onTick: () => { if (!controls.isConnected) stopActiveRecording(); },
      onFinish: take => {
        active = null;
        btn.disabled = false;
        if (!result.isConnected) return;
        result.innerHTML = `<audio controls src="${esc(URL.createObjectURL(take.blob))}" style="width:100%;"></audio><div class="hint">This trial is not kept. If the voice is clear, go ahead.</div>`;
      },
      onProblem: () => {},
    });
    if (session) active = session;
    else { btn.disabled = false; result.innerHTML = ''; }
  });

  document.getElementById('rc-file').addEventListener('change', async e => {
    const file = e.target.files[0];
    if (!file) return;
    const problem = audioFileProblem(file);
    if (problem) { alert(problem); e.target.value = ''; return; }
    controls.innerHTML = `<div>${esc(file.name)}</div>
      <div class="btn-row" style="margin-bottom:0;"><button class="btn" id="rc-send-file">Send to be heard</button></div>
      <div id="rc-status" class="hint" role="status"></div>`;
    document.getElementById('rc-send-file').addEventListener('click', async ev => {
      ev.currentTarget.disabled = true;
      const ending = (file.name.split('.').pop() || '').toLowerCase();
      const ok = await sendTake(documentId, { blob: file, mime: AUDIO_FORMATS[ending][1], duration: await audioDurationOf(file), ending: AUDIO_FORMATS[ending][0] }, 'file', document.getElementById('rc-status'));
      if (ok) { await clearChunks(documentId); currentTab = 'mine'; renderReadingsView(main); }
      else document.getElementById('rc-send-file').disabled = false;
    });
  });

  const recovered = await recoveredTake(documentId);
  if (recovered && recovered.blob.size) {
    showTake(recovered);
    document.getElementById('rc-recovered').innerHTML = '<p class="hint"><b>A recording of this text was found on this phone.</b> You can listen to it and send it, or record again.</p>';
  } else {
    showIdle();
  }
}

// Returns a session, or null if the microphone did not start (already explained to the person).
async function startRecording({ format, onChunk, onTick, onFinish, onProblem, maxSeconds }) {
  let stream;
  try {
    stream = await navigator.mediaDevices.getUserMedia({ audio: { echoCancellation: true, noiseSuppression: true, autoGainControl: true } });
  } catch (e) {
    alert(`The microphone did not start (${e.name}). Please check the permission for this browser in the phone's settings, or upload a recording instead.`);
    return null;
  }
  const recorder = new MediaRecorder(stream, { mimeType: format, audioBitsPerSecond: 64000 });
  const mime = recorder.mimeType || format;
  const chunks = [];
  let seconds = 0;
  let lastTick = Date.now();
  let wakeLock = null;
  let abandoned = false;

  const keepScreenOn = async () => {
    try { if ('wakeLock' in navigator) wakeLock = await navigator.wakeLock.request('screen'); } catch { /* not essential */ }
  };
  const onVisible = () => { if (document.visibilityState === 'visible' && recorder.state !== 'inactive') keepScreenOn(); };
  document.addEventListener('visibilitychange', onVisible);
  keepScreenOn();

  const ticker = setInterval(() => {
    const now = Date.now();
    if (recorder.state === 'recording') seconds += (now - lastTick) / 1000;
    lastTick = now;
    onTick(seconds);
    if (seconds >= maxSeconds && recorder.state !== 'inactive') recorder.stop();
  }, 250);

  const cleanUp = () => {
    clearInterval(ticker);
    document.removeEventListener('visibilitychange', onVisible);
    stream.getTracks().forEach(t => t.stop());
    if (wakeLock) { wakeLock.release().catch(() => {}); wakeLock = null; }
  };

  recorder.ondataavailable = e => {
    if (!e.data || !e.data.size) return;
    chunks.push(e.data);
    if (onChunk) onChunk(e.data, mime, seconds);
  };
  recorder.onerror = e => onProblem(`The recording stopped: ${e.error?.name || 'unknown problem'}. What was recorded so far is kept.`);
  recorder.onstop = () => {
    cleanUp();
    if (!abandoned) onFinish({ blob: new Blob(chunks, { type: mime }), mime, seconds });
  };
  // A phone call or the system can take the microphone away without anyone pressing stop.
  stream.getAudioTracks().forEach(t => { t.onended = () => { if (recorder.state !== 'inactive') recorder.stop(); }; });

  recorder.start(5000); // a piece every 5 seconds, saved on the phone as it comes

  return {
    togglePause() {
      if (recorder.state === 'recording') { recorder.pause(); return true; }
      if (recorder.state === 'paused') { recorder.resume(); lastTick = Date.now(); return false; }
      return false;
    },
    stop() { if (recorder.state !== 'inactive') recorder.stop(); },
    // Leaving the screen: what was recorded stays on the phone and is offered on coming back.
    abandon() { abandoned = true; if (recorder.state !== 'inactive') recorder.stop(); else cleanUp(); },
  };
}

// The file first, under a random name, with a few tries on a weak connection. If anything fails the
// recording is still on the phone and can be sent again.
async function sendTake(documentId, take, origin, status) {
  const [fallbackEnding, mime] = storedFormat(take.mime);
  const ending = take.ending || fallbackEnding;
  // A second try after the server refused must not leave a second copy of the file behind.
  const path = take.uploadedPath || `${crypto.randomUUID()}.${ending}`;
  const say = text => { if (status) status.textContent = text; };
  for (let attempt = 1; attempt <= UPLOAD_ATTEMPTS && !take.uploadedPath; attempt++) {
    say(attempt === 1 ? 'Sending...' : `Weak connection, trying again (${attempt} of ${UPLOAD_ATTEMPTS})...`);
    const { error } = await sb.storage.from(AUDIO_BUCKET).upload(path, take.blob, { contentType: mime });
    if (!error || /exists|duplicate/i.test(error.message || '')) { take.uploadedPath = path; break; }
    if (attempt === UPLOAD_ATTEMPTS) {
      say('');
      alert(`The recording could not be sent: ${error.message}. It is still on this phone: please try again when the connection is better.`);
      return false;
    }
    await new Promise(r => setTimeout(r, attempt * 2000));
  }
  const ok = await act(async () => {
    await withStatus(sb.rpc('submit_reading', {
      p_document_id: documentId, p_path: path, p_mime: mime, p_size: take.blob.size,
      p_duration: take.duration || (take.seconds ? mmss(take.seconds) : null), p_origin: origin,
    }), 'Saving...');
    await eraseMyAudioFiles();
  });
  say('');
  return ok;
}

// ---------- To listen ----------
async function renderQueue(main, body) {
  const rows = await withStatus(sb.rpc('get_reading_queue'));
  body.innerHTML = `
    <div class="panel">
      <p class="hint" style="margin-top:0;">Oldest first. Who read each one isn't shown. Taking a reading holds it for you for 48 hours; after that it comes back here by itself.</p>
      ${rows.length ? rows.map(r => `
        <div class="subpanel" data-id="${esc(r.id)}" style="margin-top:12px;">
          <div style="font-weight:600;" dir="auto">${esc(r.title)}</div>
          <div class="hint">${docNumber(r.source_document_id)}${esc(labelOf(State.langs, r.language))}${r.duration ? ` &middot; ${esc(r.duration)}` : ''} &middot; waiting ${r.days_waiting === 0 ? 'since today' : `${esc(r.days_waiting)} day${r.days_waiting === 1 ? '' : 's'}`}</div>
          <div>
            ${r.overdue ? '<span class="count-badge" style="padding:1px 6px;background:var(--danger);color:#fff;">Over 7 days</span>' : ''}
            ${r.reminder_count ? '<span class="count-badge" style="padding:1px 6px;">Reminder sent</span>' : ''}
            ${r.claimed_by_me ? '<span class="count-badge" style="padding:1px 6px;">You have taken it</span>' : ''}
            ${r.claimed_by_other ? '<span class="count-badge" style="padding:1px 6px;">Someone else has it</span>' : ''}
          </div>
          <div class="btn-row"><button class="btn rd-open">Listen</button></div>
        </div>`).join('') : '<div class="empty-msg">Nothing waiting to be heard.</div>'}
    </div>`;
  body.querySelectorAll('[data-id]').forEach(card => {
    card.querySelector('.rd-open').addEventListener('click', () => renderListen(main, parseInt(card.dataset.id, 10)));
  });
}

async function renderListen(main, id) {
  const d = await withStatus(sb.rpc('get_reading_detail', { p_id: id }));
  const canDecide = d.can_review && d.status === 'submitted' && (!d.claimed_by_other || isAdmin());
  scrollTop();
  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;align-items:center;margin:0 0 8px;">
        <h2 style="margin:0;" dir="auto">${esc(d.title)}</h2>
        <button class="btn secondary" id="rl-back">Back</button>
      </div>
      <div class="hint">${docNumber(d.source_document_id ?? d.document_id)}${esc(labelOf(State.langs, d.language))}${d.duration ? ` &middot; ${esc(d.duration)}` : ''}${d.reader_name ? ` &middot; read by <span dir="auto">${esc(d.reader_name)}</span>` : ''}</div>
      ${d.text_changed ? '<p class="hint"><b>The text has been corrected since this was recorded.</b></p>' : ''}
      <div id="rl-player"></div>
      ${canDecide ? `
        <div class="btn-row" style="margin-top:14px;">
          ${d.claimed_by_me ? '<button class="btn secondary" id="rl-release">Release it</button>' : '<button class="btn secondary" id="rl-claim">Take it</button>'}
          <button class="btn" id="rl-ok">OK, publish</button>
          <button class="btn secondary" id="rl-ok-note">OK, with a note</button>
          <button class="btn secondary" id="rl-again">Ask to record again</button>
          <button class="btn danger" id="rl-reject">Not accepted</button>
        </div>` : ''}
      ${d.can_review && d.status === 'submitted' && !canDecide ? '<p class="hint">Someone else has taken this. It comes back to the queue after 48 hours if they don\'t decide.</p>' : ''}
    </div>
    <div class="panel"><div dir="auto" class="reading-text" style="font-size:22px;">${esc(d.source_body)}</div></div>`;
  if (d.path) mountAudioPlayer(document.getElementById('rl-player'), { path: d.path }, false);
  document.getElementById('rl-back').addEventListener('click', () => renderReadingsView(main));
  const reload = () => renderListen(main, id);
  const toQueue = () => { currentTab = 'listen'; renderReadingsView(main); };
  document.getElementById('rl-claim')?.addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('claim_submission', { p_id: id }), 'Saving...'))) reload();
  });
  document.getElementById('rl-release')?.addEventListener('click', async () => {
    if (await act(() => withStatus(sb.rpc('release_submission', { p_id: id }), 'Saving...'))) reload();
  });
  document.getElementById('rl-ok')?.addEventListener('click', async () => {
    if (!confirm('Publish this reading? It becomes available to everyone who can see the text, with the reader\'s name.')) return;
    if (await act(() => withStatus(sb.rpc('approve_submission', { p_id: id, p_read_document_ids: null, p_note: null }), 'Publishing...'))) toQueue();
  });
  document.getElementById('rl-ok-note')?.addEventListener('click', async () => {
    const note = prompt('Your note for the person who read: a thank you, or something to keep in mind next time.');
    if (note === null) return;
    if (await act(() => withStatus(sb.rpc('approve_submission', { p_id: id, p_read_document_ids: null, p_note: note }), 'Publishing...'))) toQueue();
  });
  document.getElementById('rl-again')?.addEventListener('click', async () => {
    const note = prompt('What would help? This has no consequences for the person who read, so please say it kindly.');
    if (note === null) return;
    if (await act(() => withStatus(sb.rpc('send_back_submission', { p_id: id, p_note: note }), 'Sending...'))) toQueue();
  });
  document.getElementById('rl-reject')?.addEventListener('click', async () => {
    const note = prompt('Why can\'t this be accepted? The person who read will see this, and the text becomes available again.');
    if (note === null) return;
    if (await act(() => withStatus(sb.rpc('reject_submission', { p_id: id, p_note: note }), 'Saving...'))) toQueue();
  });
}

// ---------- Readers, and for Admin the space ----------
async function renderReaders(main, body) {
  const rows = await withStatus(sb.rpc('get_reader_stats'));
  const hk = isAdmin() ? await withStatus(sb.rpc('get_audio_housekeeping')) : null;
  const mb = n => (Number(n) / 1024 / 1024).toFixed(0);
  const toErase = hk ? [...hk.due.map(d => ({ path: d.path, reason: d.reason })), ...hk.orphans.map(path => ({ path, reason: 'not used by any record' }))] : [];
  body.innerHTML = `
    <div class="panel">
      <h3 style="margin-top:0;">Readers</h3>
      ${rows.length ? `<div class="grid-wrap"><table class="grid">
        <thead><tr><th>Reader</th><th>Published</th><th>Waiting</th><th>To record again</th><th>Times asked again</th><th>Not accepted</th><th>Listens</th>${isAdmin() ? '<th></th>' : ''}</tr></thead>
        <tbody>${rows.map(r => `<tr data-user="${esc(r.user_id)}">
          <td dir="auto">${esc(r.reader_name)}</td><td>${esc(r.approved)}</td><td>${esc(r.waiting)}</td><td>${esc(r.to_rerecord)}</td><td>${esc(r.times_sent_back)}</td><td>${esc(r.rejected)}</td><td>${esc(r.listens)}</td>
          ${isAdmin() ? '<td><button class="btn secondary rd-admin-withdraw" style="padding:2px 8px;white-space:nowrap;">Withdraw consent</button></td>' : ''}
        </tr>`).join('')}</tbody>
      </table></div>` : '<div class="empty-msg">No readers yet.</div>'}
    </div>
    ${hk ? `<div class="panel">
      <h3 style="margin-top:0;">Space</h3>
      <p class="hint" style="margin-top:0;">${esc(mb(hk.used))} MB of ${esc(mb(hk.limit))} MB used by recordings. New texts can't be held once the limit is reached.${Number(hk.later) ? ` ${esc(hk.later)} more file${Number(hk.later) === 1 ? '' : 's'} will be due for erasing later.` : ''}</p>
      ${toErase.length ? `<div class="btn-row"><button class="btn" id="rd-erase-all">Erase ${esc(toErase.length)} file${toErase.length === 1 ? '' : 's'}</button></div>
        ${toErase.map(f => `<div class="hint">${esc(f.path)} &middot; ${esc(f.reason)}</div>`).join('')}` : '<div class="hint">No files to erase.</div>'}
    </div>` : ''}`;
  body.querySelectorAll('.rd-admin-withdraw').forEach(btn => btn.addEventListener('click', async () => {
    const tr = btn.closest('tr');
    if (!confirm('Withdraw this person\'s consent, as they asked? All their readings are removed at once and their files erased. This cannot be undone.')) return;
    const ok = await act(async () => {
      await withStatus(sb.rpc('withdraw_reading_consent', { p_user_id: tr.dataset.user }), 'Removing...');
      await eraseMyAudioFiles();
    });
    if (ok) renderReadingsView(main);
  }));
  document.getElementById('rd-erase-all')?.addEventListener('click', async () => {
    if (!confirm('Erase these files for good? This cannot be undone.')) return;
    const ok = await act(async () => {
      await eraseMyAudioFiles();
      if (hk.orphans.length) {
        const { error } = await sb.storage.from(AUDIO_BUCKET).remove(hk.orphans);
        if (error) throw error;
      }
    });
    if (ok) renderReadingsView(main);
  });
}

// ---------- The count on the tab, and the note at sign-in ----------
export async function refreshReadingsBadge() {
  const { data } = await sb.rpc('get_reading_counts');
  const c = data && data[0];
  const btn = document.querySelector('.tab-btn[data-tab="readings"]');
  if (!btn) return c;
  const total = c ? c.to_listen + c.to_rerecord : 0;
  btn.textContent = total ? `Read aloud (${total})` : 'Read aloud';
  return c;
}

export async function initReadingNotifications(navigate) {
  const c = await refreshReadingsBadge();
  if (!c || (!c.to_listen && !c.to_rerecord)) return;
  const parts = [];
  if (c.to_listen) parts.push(`${c.to_listen} waiting to be heard`);
  if (c.to_rerecord) parts.push(`${c.to_rerecord} of yours to record again`);
  const toast = document.createElement('div');
  toast.className = 'toast-notification';
  toast.style.bottom = '150px';
  toast.innerHTML = `
    <div class="toast-title">Read aloud</div>
    <div class="toast-body">${esc(parts.join('; '))}.</div>
    <div class="btn-row" style="margin:8px 0 0;">
      <button class="btn" id="toast-rd-view" style="padding:4px 10px;">View</button>
      <button class="btn secondary" id="toast-rd-close" style="padding:4px 10px;">Dismiss</button>
    </div>`;
  document.body.appendChild(toast);
  document.getElementById('toast-rd-close').addEventListener('click', () => toast.remove());
  document.getElementById('toast-rd-view').addEventListener('click', () => {
    toast.remove();
    if (c.to_listen) currentTab = 'listen';
    navigate();
  });
}
