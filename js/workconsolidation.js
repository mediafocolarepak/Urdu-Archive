// Work Consolidation: a batch tool for merging Documents that turned out to be the same
// work under different catalogue entries - complements Match Review's "Other catalogued
// items" (which reviews one document at a time against date-ranked candidates) with a
// wide-angle view: title-similarity suggestions across every still-unmerged (single-document)
// Work, plus a fully manual fallback for cases the similarity heuristic misses.
//
// Scope note: only documents whose Work is still single-item are considered here - a Work
// that already has several versions is presumed already reviewed, and its preferred-version
// management lives on the document detail page (Other Versions table) rather than duplicated
// here.

import { sb, esc, withStatus, labelOf, State, downloadFromGDrive, mergeWorks, titleOverlapScore } from './core.js?v=20260823234040';

const SIMILARITY_THRESHOLD = 0.6;
const MAX_FOR_SUGGESTIONS = 1500; // guard against an O(n^2) scan over a very large catalogue

export async function renderWorkConsolidationView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Work Consolidation</h2>
      <p class="hint">Documents whose Work has never been merged with another. Suggested groups below are guesses from title similarity - review before merging.</p>
      <div id="wc-suggestions"><div class="empty-msg">Scanning...</div></div>
    </div>
    <div class="panel">
      <h2>Single-document Works <span class="count-badge" id="wc-single-count"></span></h2>
      <p class="hint">Didn't get suggested above? Merge manually: type the catalogue ID of the document whose Work you want to join.</p>
      <div class="grid-wrap" style="max-height:60vh;overflow:auto;"><table class="grid" id="wc-single-grid"></table></div>
    </div>`;

  const docs = await withStatus(
    sb.from('documents').select('document_id,title,author,ref_date,language,source,work_id,file_name').order('document_id'),
    'Loading works...'
  );
  const countByWork = {};
  for (const d of docs) if (d.work_id) countByWork[d.work_id] = (countByWork[d.work_id] || 0) + 1;
  const singleDocs = docs.filter(d => d.work_id && countByWork[d.work_id] === 1);

  renderSingleDocGrid(singleDocs);
  renderSuggestions(singleDocs);
}

function docRowCells(d) {
  return `<td>${esc(d.document_id)}</td><td>${esc(d.title)}</td><td>${esc(labelOf(State.authors, d.author))}</td>
    <td>${esc(d.ref_date)}</td><td>${esc(labelOf(State.langs, d.language))}</td><td>${esc(labelOf(State.sources, d.source))}</td>`;
}

function renderSingleDocGrid(singleDocs) {
  document.getElementById('wc-single-count').textContent = singleDocs.length;
  const grid = document.getElementById('wc-single-grid');
  grid.innerHTML = `<thead><tr>
      <th>ID</th><th>Title</th><th>Author</th><th>Ref. date</th><th>Language</th><th>Source</th><th></th><th>Merge into doc #</th>
    </tr></thead>
    <tbody>${singleDocs.map(d => `<tr data-id="${esc(d.document_id)}">
      ${docRowCells(d)}
      <td><button class="btn secondary wc-open" style="padding:3px 8px;">Open</button></td>
      <td><input class="wc-target" placeholder="ID" style="width:70px;display:inline-block;">
          <button class="btn wc-merge" style="padding:3px 8px;">Merge</button></td>
    </tr>`).join('')}</tbody>`;

  grid.querySelectorAll('tbody tr').forEach(tr => {
    const doc = singleDocs.find(d => String(d.document_id) === tr.dataset.id);
    tr.querySelector('.wc-open').addEventListener('click', () => downloadFromGDrive(doc.file_name));
    tr.querySelector('.wc-merge').addEventListener('click', async () => {
      const targetId = tr.querySelector('.wc-target').value.trim();
      if (!targetId) { alert('Enter the target document ID first.'); return; }
      if (targetId === tr.dataset.id) { alert('That is the same document.'); return; }
      try {
        await mergeWorks(targetId, [doc.document_id]);
        alert(`Document #${doc.document_id} merged into the Work of #${targetId}.`);
        await renderWorkConsolidationView(document.getElementById('main'));
      } catch (e) {
        alert('Could not merge: ' + e.message);
      }
    });
  });
}

function computeSuggestedGroups(docs) {
  const groups = [];
  const used = new Set();
  for (let i = 0; i < docs.length; i++) {
    if (used.has(docs[i].document_id)) continue;
    const group = [docs[i]];
    for (let j = i + 1; j < docs.length; j++) {
      if (used.has(docs[j].document_id)) continue;
      if (titleOverlapScore(docs[i].title, docs[j].title) >= SIMILARITY_THRESHOLD) group.push(docs[j]);
    }
    if (group.length > 1) {
      group.forEach(d => used.add(d.document_id));
      groups.push(group);
    }
  }
  return groups;
}

function renderSuggestions(singleDocs) {
  const box = document.getElementById('wc-suggestions');
  if (singleDocs.length > MAX_FOR_SUGGESTIONS) {
    box.innerHTML = `<div class="empty-msg">Too many single-document Works (${singleDocs.length}) to scan for suggestions here - use the manual list below instead.</div>`;
    return;
  }
  const groups = computeSuggestedGroups(singleDocs.filter(d => d.title));
  if (!groups.length) { box.innerHTML = '<div class="empty-msg">No title-similarity suggestions right now.</div>'; return; }

  box.innerHTML = groups.map((g, gi) => `
    <div class="panel" style="margin-bottom:12px;">
      <div class="grid-wrap"><table class="grid">
        <thead><tr><th>ID</th><th>Title</th><th>Author</th><th>Ref. date</th><th>Language</th><th>Source</th><th></th></tr></thead>
        <tbody>${g.map(d => `<tr data-id="${esc(d.document_id)}">${docRowCells(d)}
          <td><button class="btn secondary wc-open" style="padding:3px 8px;">Open</button></td></tr>`).join('')}</tbody>
      </table></div>
      <div class="btn-row"><button class="btn wc-merge-group" data-gi="${gi}">Merge these ${g.length} into one Document</button></div>
    </div>`).join('');

  box.querySelectorAll('.wc-open').forEach(btn => {
    const tr = btn.closest('tr');
    const d = groups.flat().find(x => String(x.document_id) === tr.dataset.id);
    btn.addEventListener('click', () => downloadFromGDrive(d.file_name));
  });
  box.querySelectorAll('.wc-merge-group').forEach(btn => btn.addEventListener('click', async () => {
    const g = groups[btn.dataset.gi];
    if (!confirm(`Merge documents ${g.map(d => '#' + d.document_id).join(', ')} into one Document?`)) return;
    try {
      await mergeWorks(g[0].document_id, g.slice(1).map(d => d.document_id));
      await renderWorkConsolidationView(document.getElementById('main'));
    } catch (e) {
      alert('Could not merge: ' + e.message);
    }
  }));
}
