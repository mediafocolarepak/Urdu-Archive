// "My Space" - a user's own saved documents (Fase 0 of the boards project, see
// PROJECT_HANDOFF_v15.md). Personal and private: each user only ever sees their own favorites,
// enforced by RLS on user_favorites, not by anything in this module.

import { sb, State, esc, labelOf, withStatus, isDocPostable, openBoardPostPopup, openFormationPostPopup, canReviewApplications, canWrite, openTranslatePopup, docCardHtml } from './core.js?v=20261123161409';

// Since 2026-11-23 (Owner's request) the saved documents are the same large cards as the Library: a tap opens the
// document's card. Remove is small, under each one. The tokens of appreciation have a page of their own.
export async function renderMySpaceView(main) {
  const [rows, tokens] = await Promise.all([
    withStatus(sb.from('user_favorites')
      .select('document_id,created_at,documents(document_id,title,en_title,ur_title,it_title,original_title,author,category,ref_date,ref_period,place,language,workflow_status,recipient)')
      .order('created_at', { ascending: false })),
    sb.rpc('my_tokens').then(r => (r.error ? null : r.data), () => null),
  ]);
  const hasTokens = tokens && ((tokens.entries || []).length || (tokens.certificates || []).length);

  main.innerHTML = `
    <div class="panel">
      <h2>My Space <span class="count-badge">${rows.length}</span></h2>
      <p class="hint" style="margin:-4px 0 12px;">The documents you saved with &#9734; Save.</p>
      ${canWrite() ? '<div class="btn-row" style="margin:0 0 8px;"><button class="btn secondary" id="myspace-translate">Translate a text</button></div>' : ''}
      <div id="myspace-cards"></div>
      ${hasTokens ? `<button type="button" class="home-tile myspace-tokens-tile" id="myspace-tokens-open">
        <span class="home-tile-en">Tokens of appreciation</span><span class="count-badge">${esc(tokens.total ?? 0)}</span>
        <span class="start-chevron" aria-hidden="true">&rsaquo;</span></button>` : ''}
    </div>`;
  document.getElementById('myspace-translate')?.addEventListener('click', () => openTranslatePopup());
  document.getElementById('myspace-tokens-open')?.addEventListener('click', () => renderTokensPage(main));

  const cardsBox = document.getElementById('myspace-cards');
  const docsById = {};
  cardsBox.innerHTML = rows.map(r => {
    const doc = r.documents;
    if (!doc) return '';
    docsById[doc.document_id] = doc;
    const canAddToBoard = State.myBoards.size > 0 && isDocPostable(doc);
    const canAddToPath = (State.isFormatore || canReviewApplications()) && isDocPostable(doc);
    return docCardHtml(doc, { extra: `
      <div class="btn-row doc-card-tools">
        <button class="btn secondary" data-remove="${esc(doc.document_id)}">Remove</button>
        ${canAddToBoard ? `<button class="btn secondary" data-addboard="${esc(doc.document_id)}">+ Board</button>` : ''}
        ${canAddToPath ? `<button class="btn secondary" data-addpath="${esc(doc.document_id)}">+ Path</button>` : ''}
      </div>` });
  }).join('') || `<div class="empty-msg">Nothing saved yet. Open a document in the ${State.currentRole === 'user' ? 'Library' : 'Dashboard'} and press &#9734; Save.</div>`;

  // A tap on the card opens the document itself, not the list (on a phone its card comes straight up).
  cardsBox.querySelectorAll('.doc-card-open').forEach(btn => {
    btn.addEventListener('click', () => {
      State.selectedDocId = btn.closest('.doc-card').dataset.id;
      State.dashOpenDetail = true;
      window.__renderTab('dashboard');
    });
  });
  cardsBox.querySelectorAll('[data-remove]').forEach(btn => {
    btn.addEventListener('click', async e => {
      e.stopPropagation();
      const docId = parseInt(btn.dataset.remove, 10);
      const { data: { user } } = await sb.auth.getUser();
      await withStatus(sb.from('user_favorites').delete().eq('user_id', user.id).eq('document_id', docId));
      State.myFavorites.delete(docId);
      renderMySpaceView(main);
    });
  });
  cardsBox.querySelectorAll('[data-addboard]').forEach(btn => {
    btn.addEventListener('click', e => {
      e.stopPropagation();
      const doc = docsById[btn.dataset.addboard];
      openBoardPostPopup({ doc, onSaved: () => {} });
    });
  });
  cardsBox.querySelectorAll('[data-addpath]').forEach(btn => {
    btn.addEventListener('click', e => {
      e.stopPropagation();
      const doc = docsById[btn.dataset.addpath];
      openFormationPostPopup({ doc, onSaved: () => {} });
    });
  });
}

// The tokens of appreciation on a page of their own, with Back to My Space.
async function renderTokensPage(main) {
  main.innerHTML = `
    <div class="btn-row start-back-row"><button class="btn secondary back-btn" id="tokens-back">&lsaquo; Back</button></div>
    <div id="myspace-tokens"></div>`;
  document.getElementById('tokens-back').addEventListener('click', () => renderMySpaceView(main));
  await renderMyTokens(document.getElementById('myspace-tokens'));
}

// ---------- Tokens of appreciation (docs/TOKEN_POLICY.md, migrations 127-128) ----------
// What this person gave outside tasks, what it has done, and their certificates. Never money.
const TOKEN_KINDS = { proposal: 'Proposal', reading: 'Reading aloud', report: 'Useful report', titles: 'Urdu titles reviewed' };
const TOKEN_UNITS = { page: ['page', 'pages'], minute: ['minute', 'minutes'], unit: ['unit', 'units'] };

async function renderMyTokens(box) {
  if (!box) return;
  const { data: t, error } = await sb.rpc('my_tokens');
  if (error || !t) { box.innerHTML = ''; return; }
  const entries = t.entries || [];
  const certificates = t.certificates || [];
  if (!entries.length && !certificates.length) {
    box.innerHTML = `<div class="panel"><h2>Tokens of appreciation</h2>
      <p class="hint">A thank-you for what you give the archive outside tasks: a text you propose, a reading of yours. They are a sign of gratitude, never money.</p>
      <div class="empty-msg">Nothing yet.</div></div>`;
    return;
  }
  const size = e => `${e.units} ${TOKEN_UNITS[e.unit][e.units === 1 ? 0 : 1]}`;
  box.innerHTML = `
    <div class="panel">
      <h2>Tokens of appreciation <span class="count-badge">${esc(t.total)}</span></h2>
      <p class="hint">A thank-you for what you give the archive outside tasks. They are a sign of gratitude, never money.${t.waiting ? ` ${t.waiting === 1 ? 'One of your gifts is' : esc(t.waiting) + ' of your gifts are'} waiting to be counted.` : ''}${t.next_milestone ? ` ${esc(t.next_milestone - t.total)} more to your next certificate.` : ''}</p>
      ${t.encouragement ? `<div class="note" dir="auto" style="margin:8px 0;">${esc(t.encouragement)}</div>` : ''}
      ${t.minor ? '' : `<label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:13px;margin:8px 0;">
        <input type="checkbox" id="tok-consent" ${t.consent ? 'checked' : ''} style="width:auto;"> Thank me by name in the monthly thanks, in the app and in Hayat</label>`}
      ${certificates.length ? `<h3>Your certificates</h3>${certificates.map((c, i) => `
        <div class="dash-card"><div class="dash-card-title">Certificate of appreciation — ${esc(c.milestone)} tokens</div>
          <div class="dash-card-meta">${esc((c.issued_at || '').slice(0, 10))} &middot; code ${esc(c.code)}</div>
          <div class="btn-row" style="margin:6px 0 0;"><button class="btn secondary tok-print" data-i="${i}">Print</button></div></div>`).join('')}` : ''}
      <h3>What you gave</h3>
      <div class="help-list">${entries.map(e => `
        <div class="dash-card">
          <div class="dash-card-title" dir="auto">${e.document_id ? `#${esc(e.document_id)} ${esc(e.title) || ''}` : esc(TOKEN_KINDS[e.kind] || e.kind)}</div>
          <div class="dash-card-meta">${esc(TOKEN_KINDS[e.kind] || e.kind)} &middot; ${esc(size(e))} &middot; ${e.annulled ? 'annulled' : (e.tokens == null ? 'waiting' : `${esc(e.tokens)} tokens`)}${e.listens != null ? ` &middot; listened ${esc(e.listens)} ${Number(e.listens) === 1 ? 'time' : 'times'}` : ''}${e.opens != null ? ` &middot; opened ${esc(e.opens)} ${Number(e.opens) === 1 ? 'time' : 'times'}` : ''}${e.past ? ' &middot; before tokens existed' : ''}</div>
          ${e.annulled && e.annul_note ? `<div class="hint">${esc(e.annul_note)}</div>` : ''}
          ${e.note && !e.document_id ? `<div class="hint">${esc(e.note)}</div>` : ''}
        </div>`).join('')}</div>
    </div>`;
  box.querySelectorAll('.tok-print').forEach(b => b.addEventListener('click', () => printCertificate(certificates[Number(b.dataset.i)], t.name)));
  document.getElementById('tok-consent')?.addEventListener('change', async e => {
    const { error } = await sb.rpc('set_token_thanks_consent', { p_consent: e.target.checked });
    if (error) { alert(error.message); e.target.checked = !e.target.checked; }
  });
}

// The certificate on its own page, ready to print or to save as PDF from the print dialog.
function printCertificate(c, name) {
  const w = window.open('', '_blank');
  if (!w) { alert('Please allow this page to open a new window, then press Print again.'); return; }
  w.document.write(`<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Certificate of appreciation</title>
    <style>body{font-family:Georgia,serif;margin:0;padding:40px;color:#222;text-align:center}
    .c{border:3px double #8a5a1f;padding:48px 32px;max-width:640px;margin:0 auto}
    h1{font-size:30px;margin:0 0 24px;color:#8a5a1f}.n{font-size:26px;margin:16px 0}.s{font-size:18px;line-height:1.6;margin:24px 0}
    .f{margin-top:40px;font-size:15px}.k{margin-top:24px;font-size:12px;color:#666}@media print{button{display:none}}</style></head>
    <body><div class="c"><h1>Certificate of appreciation</h1><div>Digital Urdu Archive</div>
    <div class="n" dir="auto">${esc(name || '')}</div>
    <div class="s" dir="auto">${esc(c.sentence)}</div>
    <div>${esc(c.milestone)} tokens of appreciation</div>
    <div class="f">${esc(c.signer)}<br>${esc((c.issued_at || '').slice(0, 10))}</div>
    <div class="k">Code ${esc(c.code)}</div></div>
    <p><button onclick="print()">Print</button></p></body></html>`);
  w.document.close();
}
