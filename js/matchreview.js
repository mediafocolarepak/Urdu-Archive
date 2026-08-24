import { sb, State, esc, labelOf, optionsHtml, withStatus, mergeWorks, likeSafe, DASH_ROW_LIMIT } from './core.js?v=20260824214857';
import { renderDocDetail } from './docdetail.js?v=20260824214857';

export function rankByDateProximity(refDate, refs, dateField) {
  // Ranks by closeness to refDate, but never drops a candidate just because it (or
  // the document) has no date - those are appended at the end instead, so the full list stays
  // browsable and a genuine match with a missing/blank date can still be found and merged.
  if (!refDate) return refs;
  const target = new Date(refDate).getTime();
  const withDate = refs.filter(r => r[dateField]);
  const withoutDate = refs.filter(r => !r[dateField]);
  withDate.sort((a, b) => Math.abs(new Date(a[dateField]).getTime() - target) - Math.abs(new Date(b[dateField]).getTime() - target));
  return [...withDate, ...withoutDate];
}

const MATCH_SORTABLE = { document_id: 'ID', category: 'Category', title: 'Title (EN)', original_title: 'Original title', ref_date: 'Ref. date' };

export async function renderMatchReviewView(main) {
  const f = State.matchFilters;
  main.innerHTML = `
    <div class="panel">
      <h2>Match Review</h2>
      <p class="hint">Search and pick a document below, then merge it with a matching item on the right - a translation, a duplicate scan, another language version...</p>
      <div class="searchbar">
        <input id="mr-search" placeholder="Search by title or tags..." value="${esc(f.search)}">
      </div>
      <div class="field-grid" style="margin-bottom:10px;">
        <div class="field"><label>ID #</label><input id="mr-search-id" placeholder="ID #" value="${esc(f.idSearch)}"></div>
        <div class="field"><label>Category</label><select id="mr-f-category">${optionsHtml(State.categories, f.category, true)}</select></div>
        <div class="field"><label>Author</label><select id="mr-f-author">${optionsHtml(State.authors, f.author, true)}</select></div>
        <div class="field"><label>Workflow status</label><select id="mr-f-status">${optionsHtml(State.statuses, f.workflow_status, true)}</select></div>
        <div class="field"><label>Recipient</label><select id="mr-f-recipient">${optionsHtml(State.recipients, f.recipient, true)}</select></div>
        <div class="field"><label>Collection</label><select id="mr-f-collection">${optionsHtml(State.collections, f.collection, true)}</select></div>
      </div>
      <div class="grid-wrap" style="max-height:34vh;"><table class="grid" id="mr-grid"></table></div>
      <div id="match-body" style="margin-top:14px;"></div>
    </div>`;

  document.getElementById('mr-search').addEventListener('input', e => { f.search = e.target.value; refreshMatchGrid(); });
  document.getElementById('mr-search-id').addEventListener('input', e => { f.idSearch = e.target.value; refreshMatchGrid(); });
  document.getElementById('mr-f-category').addEventListener('change', e => { f.category = e.target.value; refreshMatchGrid(); });
  document.getElementById('mr-f-author').addEventListener('change', e => { f.author = e.target.value; refreshMatchGrid(); });
  document.getElementById('mr-f-status').addEventListener('change', e => { f.workflow_status = e.target.value; refreshMatchGrid(); });
  document.getElementById('mr-f-recipient').addEventListener('change', e => { f.recipient = e.target.value; refreshMatchGrid(); });
  document.getElementById('mr-f-collection').addEventListener('change', e => { f.collection = e.target.value; refreshMatchGrid(); });

  await refreshMatchGrid();
  await renderMatchBody();
}

function buildMatchQuery() {
  let q = sb.from('documents').select('document_id,category,title,original_title,ref_date,pending_deletion');
  const f = State.matchFilters;
  if (f.search && f.search.trim()) {
    const like = likeSafe(f.search.trim());
    q = q.or(`title.ilike.${like},secondary_tags.ilike.${like}`);
  }
  if (f.idSearch && f.idSearch.trim()) {
    const idNum = parseInt(f.idSearch.trim(), 10);
    q = Number.isFinite(idNum) ? q.eq('document_id', idNum) : q.eq('document_id', -1);
  }
  if (f.category) q = q.eq('category', f.category);
  if (f.author) q = q.eq('author', f.author);
  if (f.workflow_status) q = q.eq('workflow_status', f.workflow_status);
  if (f.recipient) q = q.overlaps('recipient', [f.recipient]);
  return q;
}

// Collections are many-to-many (document_collections), so filtering by them is a post-fetch
// join rather than a single .eq() on the documents query - same approach as the Dashboard.
async function filterByCollection(rows) {
  const f = State.matchFilters;
  if (!f.collection) return rows;
  const matches = await withStatus(sb.from('document_collections').select('document_id').eq('collection_code', f.collection));
  const idSet = new Set(matches.map(m => m.document_id));
  return rows.filter(r => idSet.has(r.document_id));
}

async function refreshMatchGrid() {
  const grid = document.getElementById('mr-grid');
  if (!grid) return;
  let rows = await withStatus(buildMatchQuery().order(State.matchSort.col, { ascending: State.matchSort.asc }).limit(DASH_ROW_LIMIT), 'Searching...');
  rows = rows.filter(r => !r.pending_deletion);
  rows = await filterByCollection(rows);
  const arrow = (col) => col !== State.matchSort.col ? '' : (State.matchSort.asc ? ' &uarr;' : ' &darr;');
  grid.innerHTML = `<thead><tr>${Object.entries(MATCH_SORTABLE).map(([col, label]) =>
      `<th data-sort="${col}">${label}${arrow(col)}</th>`).join('')}</tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.document_id)}" class="${String(r.document_id) === String(State.matchSelectedId) ? 'selected' : ''}">
      <td>${esc(r.document_id)}</td><td>${esc(labelOf(State.categories, r.category))}</td>
      <td>${esc(r.title)}</td><td>${esc(r.original_title)}</td><td>${esc(r.ref_date)}</td></tr>`).join('')}</tbody>`;
  grid.querySelectorAll('th[data-sort]').forEach(th => th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (State.matchSort.col === col) State.matchSort.asc = !State.matchSort.asc; else State.matchSort = { col, asc: true };
    refreshMatchGrid();
  }));
  grid.querySelectorAll('tbody tr').forEach(tr => tr.addEventListener('click', async () => {
    State.matchSelectedId = tr.dataset.id;
    await refreshMatchGrid();
    await renderMatchBody();
  }));
}

async function renderMatchBody() {
  const box = document.getElementById('match-body');
  if (!State.matchSelectedId) {
    box.innerHTML = `<div class="empty-msg">Select a document from the list above to start matching.</div>`;
    return;
  }
  const rows = await withStatus(sb.from('documents').select('document_id,title,ref_date,source,language,pending_deletion').eq('document_id', State.matchSelectedId));
  const doc = rows[0];
  if (!doc) { box.innerHTML = '<div class="empty-msg">Document not found.</div>'; return; }

  const candidateRows = await withStatus(sb.from('documents').select('document_id,title,ref_date,source,language,pending_deletion').neq('document_id', doc.document_id));
  const candidates = candidateRows.filter(r => !r.pending_deletion);
  const ranked = rankByDateProximity(doc.ref_date, candidates, 'ref_date');

  box.innerHTML = `
    <div class="split">
      <div class="panel" style="margin:0;">
        <p class="hint">Full document record - fix or fill in anything you notice while matching.</p>
        <div id="doc-detail" style="max-height:60vh;overflow-y:auto;"></div>
      </div>
      <div>
        <h3>Candidates <span class="hint" id="match-candidates-count"></span></h3>
        <input id="match-search" placeholder="Search candidates...">
        <div id="match-candidates" style="max-height:55vh;overflow-y:auto;margin-top:8px;"></div>
      </div>
    </div>
  `;
  renderCandidates(ranked, doc);
  renderDocDetail(doc.document_id);
  document.getElementById('match-search').addEventListener('input', e => {
    const term = e.target.value.toLowerCase();
    if (!term) { renderCandidates(ranked, doc); return; }
    const filtered = candidates.filter(r => candidateLabel(r).toLowerCase().includes(term));
    renderCandidates(filtered, doc);
  });
}

function candidateLabel(r) {
  return `#${r.document_id} — ${r.title || '(untitled)'} — ${r.ref_date || 'no date'} — ${r.source || '?'}/${r.language || '?'}`;
}

function renderCandidates(list, doc) {
  const box = document.getElementById('match-candidates');
  document.getElementById('match-candidates-count').textContent = `(${list.length} total, most likely first)`;
  if (list.length === 0) { box.innerHTML = '<div class="empty-msg">No candidates found.</div>'; return; }
  box.innerHTML = list.map((r, i) => {
    const sameVariant = r.source === doc.source && r.language === doc.language;
    return `<div class="panel" style="margin-bottom:8px;padding:10px;">
      <div style="font-size:13px;">${esc(candidateLabel(r))}${sameVariant ? ' <span class="hint">(same source/language - more likely a duplicate than a translation)</span>' : ''}</div>
      <button class="btn" data-i="${i}" style="margin-top:6px;padding:4px 10px;">Same document — merge</button>
    </div>`;
  }).join('');
  box.querySelectorAll('[data-i]').forEach(btn => btn.addEventListener('click', async () => {
    const r = list[btn.dataset.i];
    await mergeWorks(r.document_id, [doc.document_id]);
    await refreshMatchGrid();
    await renderMatchBody();
  }));
}
