import { sb, State, esc, withStatus, mergeWorks } from './core.js?v=20260824122248';
import { renderDocDetail } from './docdetail.js?v=20260824122248';

export function rankByDateProximity(refDate, refs, dateField) {
  // Ranks by closeness to refDate, but never drops a candidate just because it (or the
  // document) has no date - those are appended at the end instead, so the full list stays
  // browsable and a genuine match with a missing/blank date can still be found and merged.
  if (!refDate) return refs;
  const target = new Date(refDate).getTime();
  const withDate = refs.filter(r => r[dateField]);
  const withoutDate = refs.filter(r => !r[dateField]);
  withDate.sort((a, b) => Math.abs(new Date(a[dateField]).getTime() - target) - Math.abs(new Date(b[dateField]).getTime() - target));
  return [...withDate, ...withoutDate];
}

export async function renderMatchReviewView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Match Review</h2>
      <p class="hint">Step through documents that are still alone in their Document group, and merge in any other catalogued item that's really the same document (a translation, a duplicate scan, another language version...). Candidates are pre-ranked by date; use search to find others.</p>
      <div id="match-body"></div>
    </div>`;
  await loadMatchQueue();
  renderMatchBody();
}

async function loadMatchQueue() {
  const docs = await withStatus(sb.from('documents').select('document_id,title,ref_date,work_id,source,language,pending_deletion').order('document_id'));
  const countByWork = {};
  for (const d of docs) if (d.work_id) countByWork[d.work_id] = (countByWork[d.work_id] || 0) + 1;
  const singleItem = docs.filter(d => !d.pending_deletion && d.work_id && countByWork[d.work_id] === 1);
  State.matchQueue = singleItem;
  State.matchRefRows = singleItem;
}

function renderMatchBody() {
  const box = document.getElementById('match-body');
  if (State.matchQueue.length === 0) {
    box.innerHTML = `<div class="empty-msg">Nothing to review right now — either everything is already merged, or no documents currently qualify.</div>`;
    return;
  }
  if (State.matchIndex >= State.matchQueue.length) {
    box.innerHTML = `<div class="empty-msg">All done for now! Check back after new documents are added.</div>`;
    return;
  }
  const doc = State.matchQueue[State.matchIndex];
  const ranked = rankByDateProximity(doc.ref_date, State.matchRefRows.filter(r => r.document_id !== doc.document_id), 'ref_date');
  box.innerHTML = `
    <div class="hint" style="margin:10px 0;">${State.matchIndex + 1} of ${State.matchQueue.length} remaining</div>
    <div class="split">
      <div class="panel" style="margin:0;">
        <div class="btn-row" style="margin-top:0;"><button class="btn secondary" id="match-skip">Skip &rarr;</button></div>
        <p class="hint">Full document record - fix or fill in anything you notice while matching.</p>
        <div id="doc-detail" style="max-height:70vh;overflow-y:auto;"></div>
      </div>
      <div>
        <h3>Candidates <span class="hint" id="match-candidates-count"></span></h3>
        <input id="match-search" placeholder="Search candidates...">
        <div id="match-candidates" style="max-height:60vh;overflow-y:auto;margin-top:8px;"></div>
      </div>
    </div>
  `;
  renderCandidates(ranked, doc);
  renderDocDetail(doc.document_id);
  document.getElementById('match-skip').addEventListener('click', () => { State.matchIndex++; renderMatchBody(); });
  document.getElementById('match-search').addEventListener('input', e => {
    const term = e.target.value.toLowerCase();
    if (!term) { renderCandidates(ranked, doc); return; }
    const pool = State.matchRefRows.filter(r => r.document_id !== doc.document_id);
    const filtered = pool.filter(r => candidateLabel(r).toLowerCase().includes(term));
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
    State.matchIndex++;
    renderMatchBody();
  }));
}
