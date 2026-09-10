// Proofreading queue (v14 §6.4 punto 5 / v17 §4 punto 3, migrazione 77): distribuisce la
// rilettura dei document_texts.reviewed = false senza passare dal sistema Task (creare 1.124
// task manuali non e' praticabile). Un solo passaggio - chi rilegge corregge il testo e lo
// marca riletto nello stesso momento, nessun secondo Revisor - il credito e' calcolato
// server-side in submit_document_reread() ed entra nel registro esistente
// (task_outcome_events, con task_id = null) cosi' credits/reputation si aggiornano da soli.

import { sb, State, esc, withStatus, isAdmin, canReviewApplications } from './core.js?v=20260911004650';

export async function renderRereadView(main) {
  const canUse = canReviewApplications() || State.myQualifications.has('PROOF_READER');
  if (!canUse) {
    main.innerHTML = '<div class="empty-msg">Proof Reader qualification (or Coordinator/Admin) required to use the proofreading queue.</div>';
    return;
  }

  main.innerHTML = `
    <div class="panel">
      <h2>Proofreading Queue</h2>
      <div class="hint">Reads out the archive's unreviewed automatic transcriptions one at a time. Correct anything wrong, then mark it reviewed.</div>
      ${isAdmin() ? '<div id="reread-rate" style="margin-top:10px;"></div>' : ''}
      <hr style="margin:16px 0;">
      <div id="reread-body">Loading...</div>
    </div>`;

  if (isAdmin()) await renderRateEditor(main);
  await loadNextDocument(main);
}

async function renderRateEditor(main) {
  const box = document.getElementById('reread-rate');
  const rows = await withStatus(sb.from('task_category_rates').select('credits_per_page').eq('category', 'TEXT_REREAD'));
  const rate = (rows[0] && rows[0].credits_per_page) ?? 0.5;
  box.innerHTML = `
    <div class="field" style="max-width:220px;">
      <label>Credits per page</label>
      <div class="btn-row">
        <input id="reread-rate-input" type="number" min="0" step="0.1" value="${esc(rate)}">
        <button class="btn secondary" id="reread-rate-save">Save</button>
      </div>
    </div>`;
  document.getElementById('reread-rate-save').addEventListener('click', async () => {
    const value = parseFloat(document.getElementById('reread-rate-input').value);
    if (!Number.isFinite(value) || value < 0) { alert('Enter a valid non-negative number.'); return; }
    await withStatus(sb.from('task_category_rates').upsert({ category: 'TEXT_REREAD', credits_per_page: value }), 'Saving...');
  });
}

async function loadNextDocument(main) {
  const box = document.getElementById('reread-body');
  box.innerHTML = 'Loading...';
  const rows = await withStatus(sb.rpc('get_next_reread_document'));
  const doc = rows[0];
  if (!doc) {
    box.innerHTML = '<div class="empty-msg">Nothing left to reread - every text has been reviewed. &#127881;</div>';
    return;
  }
  box.innerHTML = `
    <div class="hint">#${esc(doc.document_id)} &middot; ${esc(doc.category)} &middot; ${doc.pages ? `${esc(doc.pages)} page(s)` : 'page count unknown'}</div>
    <div style="font-weight:600;margin:4px 0;" dir="auto">${esc(doc.en_title) || esc(doc.title) || '(no title)'}</div>
    <textarea id="reread-textarea" dir="auto" rows="16" style="white-space:pre-wrap;">${esc(doc.body)}</textarea>
    <div class="btn-row" style="margin-top:8px;justify-content:flex-end;">
      <button class="btn" id="reread-submit">Mark as reviewed</button>
    </div>
    <div id="reread-feedback" class="hint" style="margin-top:6px;"></div>`;

  document.getElementById('reread-submit').addEventListener('click', async () => {
    const corrected = document.getElementById('reread-textarea').value;
    if (!corrected.trim()) { alert('The text cannot be empty.'); return; }
    const [result] = await withStatus(sb.rpc('submit_document_reread', { doc_id: doc.document_id, corrected_body: corrected }), 'Saving...');
    const feedback = document.getElementById('reread-feedback');
    feedback.textContent = result.credited > 0 ? `Saved - +${result.credited} credits.` : 'Saved.';
    setTimeout(() => loadNextDocument(main), 900);
  });
}
