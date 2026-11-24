// "My Space" - a user's own saved documents (Fase 0 of the boards project, see
// PROJECT_HANDOFF_v15.md). Personal and private: each user only ever sees their own favorites,
// enforced by RLS on user_favorites, not by anything in this module.

import { sb, State, esc, labelOf, withStatus, isDocPostable, openBoardPostPopup, openFormationPostPopup, canReviewApplications, canWrite, openTranslatePopup, docCardHtml } from './core.js?v=20261124162602';

// Since 2026-11-23 (Owner's request) the saved documents are the same large cards as the Library: a tap opens the
// document's card. Remove is small, under each one. The tokens of appreciation are in My Profile.
export async function renderMySpaceView(main) {
  const rows = await withStatus(sb.from('user_favorites')
    .select('document_id,created_at,documents(document_id,title,en_title,ur_title,it_title,original_title,author,category,ref_date,ref_period,place,language,workflow_status,recipient)')
    .order('created_at', { ascending: false }));

  main.innerHTML = `
    <div class="panel">
      <h2>My Space <span class="count-badge">${rows.length}</span></h2>
      <p class="hint" style="margin:-4px 0 12px;">The documents you saved with &#9734; Save.</p>
      ${canWrite() ? '<div class="btn-row" style="margin:0 0 8px;"><button class="btn secondary" id="myspace-translate">Translate a text</button></div>' : ''}
      <div id="myspace-cards"></div>
    </div>`;
  document.getElementById('myspace-translate')?.addEventListener('click', () => openTranslatePopup());

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
