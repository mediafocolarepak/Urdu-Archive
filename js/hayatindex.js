// Read-mostly viewer over the full Hayat index (all editions at once), for browsing/searching.
// For actual editing use the Hayat Editor tab; this view's only action is one-click Extract,
// sharing core.js's extractHayatRowToDocument so both tabs create documents identically.

import { sb, esc, likeSafe, canWrite, withStatus, extractHayatRowToDocument } from './core.js?v=20260902165344';

export async function renderHayatView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Hayat Index</h2>
      <p class="hint">Rows not yet "extracted" can be turned into a new document with one click, already tagged with source "Hayat", language Urdu, and its own Document. To edit the index itself (fix a title, add rows), use the Hayat Editor tab.</p>
      <div class="searchbar"><input id="hayat-search" placeholder="Search by title, author, topic..."></div>
      <div class="grid-wrap"><table class="grid" id="hayat-grid"></table></div>
    </div>`;
  document.getElementById('hayat-search').addEventListener('input', e => refreshHayatGrid(e.target.value));
  await refreshHayatGrid('');
}

async function refreshHayatGrid(filterText) {
  const grid = document.getElementById('hayat-grid');
  let query = sb.from('hayat_indice').select('*, document_categories(document_category)');
  if (filterText && filterText.trim()) {
    const like = likeSafe(filterText.trim());
    query = query.or(`titolo.ilike.${like},title.ilike.${like},ur_title.ilike.${like},autore.ilike.${like},argomento.ilike.${like}`);
  }
  const rows = await withStatus(query);
  rows.sort((a, b) => (a.idtranscription || 0) - (b.idtranscription || 0) || (a.autore || '').localeCompare(b.autore || '') || (a.mese_anno || '').localeCompare(b.mese_anno || ''));
  grid.innerHTML = `<thead><tr><th></th><th>Id</th><th>Month-Year</th><th>Page</th><th>Category</th><th>Branch</th><th>Author</th><th>Title</th><th>Ur-Title</th><th>Topic</th><th>Extracted</th></tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.id)}">
      <td>${(!r.estratto && canWrite()) ? `<button class="btn" data-extract="${esc(r.id)}" style="padding:3px 8px;">Extract &rarr;</button>` : ''}</td>
      <td>${esc(r.id)}</td><td>${esc(r.mese_anno)}</td><td>${esc(r.pagina)}</td><td>${esc(r.document_categories?.document_category)}</td>
      <td>${esc(r.branca)}</td><td>${esc(r.autore)}</td><td>${esc(r.titolo)}</td><td dir="auto">${esc(r.ur_title)}</td><td>${esc(r.argomento)}</td><td>${esc(r.estratto)}</td></tr>`).join('')}</tbody>`;
  grid.querySelectorAll('[data-extract]').forEach(btn => btn.addEventListener('click', async e => {
    e.stopPropagation();
    await extractHayatRow(btn.dataset.extract);
    await refreshHayatGrid(filterText);
  }));
}

async function extractHayatRow(hayatId) {
  const rows = await withStatus(sb.from('hayat_indice').select('*').eq('id', hayatId));
  const row = rows[0];
  if (!row || row.estratto) return;
  const newId = await extractHayatRowToDocument(row);
  alert(`Created document #${newId} from Hayat entry #${hayatId}. You can complete it from the Dashboard.`);
}
