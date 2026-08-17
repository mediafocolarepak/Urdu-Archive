import { sb, State, esc, today, likeSafe, canWrite, withStatus, computeFileName, uniqueFileName, createWorkFor } from './core.js?v=20260817133204';

export async function renderHayatView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Hayat Index</h2>
      <p class="hint">Rows not yet "extracted" can be turned into a new document with one click, already tagged with source "Hayat", language Urdu, and its own Document.</p>
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
    query = query.or(`titolo.ilike.${like},title.ilike.${like},autore.ilike.${like},argomento.ilike.${like}`);
  }
  const rows = await withStatus(query);
  rows.sort((a, b) => (a.idtranscription || 0) - (b.idtranscription || 0) || (a.autore || '').localeCompare(b.autore || '') || (a.mese_anno || '').localeCompare(b.mese_anno || ''));
  grid.innerHTML = `<thead><tr><th></th><th>Id</th><th>Month-Year</th><th>Page</th><th>Category</th><th>Branch</th><th>Author</th><th>Title</th><th>Topic</th><th>Extracted</th></tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.id)}">
      <td>${(!r.estratto && canWrite()) ? `<button class="btn" data-extract="${esc(r.id)}" style="padding:3px 8px;">Extract &rarr;</button>` : ''}</td>
      <td>${esc(r.id)}</td><td>${esc(r.mese_anno)}</td><td>${esc(r.pagina)}</td><td>${esc(r.document_categories?.document_category)}</td>
      <td>${esc(r.branca)}</td><td>${esc(r.autore)}</td><td>${esc(r.titolo)}</td><td>${esc(r.argomento)}</td><td>${esc(r.estratto)}</td></tr>`).join('')}</tbody>`;
  grid.querySelectorAll('[data-extract]').forEach(btn => btn.addEventListener('click', async e => {
    e.stopPropagation();
    await extractHayatRow(btn.dataset.extract);
    await refreshHayatGrid(filterText);
  }));
}

const HAYAT_CATEGORY_MAP = { Tlk: 'DISC', Mdt: 'MEDI', Lkp: 'LINK', Wol: 'WORD', Exp: 'EXPE' };
function mapHayatAuthor(name) {
  if (!name) return 'OFFI';
  if (name === 'Chiara') return 'CHIA';
  return 'OTHR';
}

async function extractHayatRow(hayatId) {
  const rows = await withStatus(sb.from('hayat_indice').select('*').eq('id', hayatId));
  const row = rows[0];
  if (!row || row.estratto) return;
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.document_id || 0) + 1;
  const category = HAYAT_CATEGORY_MAP[row.category] || 'MISC';
  const author = mapHayatAuthor(row.autore);
  const workId = await createWorkFor(row.titolo || row.title);
  const draft = {
    document_id: newId, title: row.title || row.titolo, legacy_category: row.category, legacy_author: row.autore,
    hayat_index_ref: row.id, to_whom: row.branca, original_title: row.titolo || row.title,
    hayat_issue: `${row.mese_anno}p.${row.pagina}`, legacy_topic: row.argomento,
    category, author, main_topic: 'GENR', secondary_tags: row.argomento,
    ref_period: row.mese_anno || null,
    original_lang: 'URD', workflow_status: 'ENTR', legacy_migrated: false,
    provenance: 'HAYAT', media_type: 'DOC', work_id: workId,
  };
  draft.file_name = await uniqueFileName(computeFileName(draft), null);
  await withStatus(sb.from('documents').insert(draft));
  await withStatus(sb.from('hayat_indice').update({ estratto: today() }).eq('id', hayatId));
  alert(`Created document #${newId} from Hayat entry #${hayatId}. You can complete it from the Dashboard.`);
}
