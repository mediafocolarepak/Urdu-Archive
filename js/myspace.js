// "My Space" - a user's own saved documents (Fase 0 of the boards project, see
// PROJECT_HANDOFF_v15.md). Personal and private: each user only ever sees their own favorites,
// enforced by RLS on user_favorites, not by anything in this module.

import { sb, State, esc, labelOf, withStatus } from './core.js?v=20260910140007';

export async function renderMySpaceView(main) {
  const rows = await withStatus(sb.from('user_favorites')
    .select('document_id,created_at,documents(document_id,en_title,ur_title,author,category,ref_date,place)')
    .order('created_at', { ascending: false }));

  main.innerHTML = `
    <div class="panel">
      <h2>My Space <span class="hint">— documents you saved</span> <span class="count-badge">${rows.length}</span></h2>
      <div id="myspace-cards"></div>
    </div>`;

  const cardsBox = document.getElementById('myspace-cards');
  cardsBox.innerHTML = rows.map(r => {
    const doc = r.documents;
    if (!doc) return '';
    const title = esc(doc.en_title) || '<span class="hint">(no title)</span>';
    return `<div class="dash-card" data-id="${esc(doc.document_id)}">
      <div class="dash-card-title">${title}</div>
      ${doc.ur_title ? `<div dir="auto">${esc(doc.ur_title)}</div>` : ''}
      <div class="dash-card-meta">#${esc(doc.document_id)} &middot; ${esc(labelOf(State.authors, doc.author))} &middot; ${esc(doc.place)} &middot; ${esc(labelOf(State.categories, doc.category))}</div>
      <div class="btn-row" style="margin:6px 0 0;"><button class="btn secondary" data-remove="${esc(doc.document_id)}">Remove</button></div>
    </div>`;
  }).join('') || '<div class="empty-msg">Nothing saved yet — use ☆ Save on any document in the Dashboard.</div>';

  cardsBox.querySelectorAll('.dash-card').forEach(card => {
    card.addEventListener('click', e => {
      if (e.target.dataset.remove) return;
      State.selectedDocId = card.dataset.id;
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
}
