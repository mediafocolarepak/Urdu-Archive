import { sb, State, esc, labelOf, withStatus, mergeWorks } from './core.js?v=20260818230219';
import { renderDocDetail } from './docdetail.js?v=20260818230219';

const ITALIAN_MONTHS = { gennaio: 1, febbraio: 2, marzo: 3, aprile: 4, maggio: 5, giugno: 6, luglio: 7, agosto: 8, settembre: 9, ottobre: 10, novembre: 11, dicembre: 12 };
export function pdvApproxDate(r) {
  if (!r.mese || !r.anno) return null;
  const m = ITALIAN_MONTHS[r.mese.trim().split(' ')[0].toLowerCase()];
  const y = parseInt(r.anno, 10);
  if (!m || !y) return null;
  return new Date(y, m - 1, 15).getTime();
}
export function rankByDateProximity(refDate, refs, dateField) {
  // Ranks by closeness to refDate, but never drops a candidate just because it (or the
  // document) has no date - those are appended at the end instead, so the full list stays
  // browsable and a genuine match with a missing/blank date can still be found and assigned.
  if (!refDate) return refs;
  const target = new Date(refDate).getTime();
  const withDate = refs.filter(r => r[dateField]);
  const withoutDate = refs.filter(r => !r[dateField]);
  withDate.sort((a, b) => Math.abs(new Date(a[dateField]).getTime() - target) - Math.abs(new Date(b[dateField]).getTime() - target));
  return [...withDate, ...withoutDate];
}
export function rankByYearMonthProximity(refDate, refs) {
  if (!refDate) return refs;
  const target = new Date(refDate).getTime();
  const withDate = refs.map(r => ({ r, d: pdvApproxDate(r) })).filter(x => x.d !== null);
  const withoutDate = refs.filter(r => pdvApproxDate(r) === null);
  withDate.sort((a, b) => Math.abs(a.d - target) - Math.abs(b.d - target));
  return [...withDate.map(x => x.r), ...withoutDate];
}

const MATCH_LISTS = {
  collegamenti: {
    label: 'Collegamenti (Italian titles)',
    docFilter: d => d.category === 'Lkp' && !d.match_ref,
    refTable: 'ref_collegamenti',
    refLabel: r => `${r.data || '?'} â€” ${r.titolo}${r.luogo ? ' (' + r.luogo + ')' : ''}`,
    refValue: r => r.titolo,
    field: 'match_ref',
    rank: (doc, refs) => rankByDateProximity(doc.ref_date, refs, 'data'),
  },
  video: {
    label: 'Video index',
    docFilter: d => !d.video_ref,
    refTable: 'ref_video_index',
    refLabel: r => `${r.numero} â€” ${r.descrizione}${r.data ? ' (' + r.data + ')' : ''}`,
    refValue: r => r.numero,
    field: 'video_ref',
    rank: (doc, refs) => rankByDateProximity(doc.ref_date, refs, 'data'),
  },
  pdv: {
    label: 'Parola di Vita',
    docFilter: d => d.category === 'Wol' && !d.pdv_ref,
    refTable: 'ref_parola_di_vita',
    refLabel: r => `${r.mese} â€” ${r.versetto}`,
    refValue: r => r.link,
    field: 'pdv_ref',
    rank: (doc, refs) => rankByYearMonthProximity(doc.ref_date, refs),
  },
  worklink: {
    label: 'Other catalogued items (possible same document)',
    isWorkLink: true,
  },
};

export async function renderMatchReviewView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Match Review</h2>
      <p class="hint">Step through documents one at a time and assign the best-matching cross-reference. Candidates are pre-ranked by date; use search to find others.</p>
      <div class="field" style="max-width:360px;">
        <label>List</label>
        <select id="match-list-select">${Object.entries(MATCH_LISTS).map(([k, v]) => `<option value="${k}" ${k === State.matchListKey ? 'selected' : ''}>${v.label}</option>`).join('')}</select>
      </div>
      <div id="match-body"></div>
    </div>`;
  document.getElementById('match-list-select').addEventListener('change', async e => {
    State.matchListKey = e.target.value;
    State.matchIndex = 0;
    await loadMatchQueue();
    renderMatchBody();
  });
  await loadMatchQueue();
  renderMatchBody();
}

async function loadMatchQueue() {
  const cfg = MATCH_LISTS[State.matchListKey];
  if (cfg.isWorkLink) {
    const docs = await withStatus(sb.from('documents').select('document_id,title,ref_date,work_id,provenance,language,pending_deletion').order('document_id'));
    const countByWork = {};
    for (const d of docs) if (d.work_id) countByWork[d.work_id] = (countByWork[d.work_id] || 0) + 1;
    const singleItem = docs.filter(d => !d.pending_deletion && d.work_id && countByWork[d.work_id] === 1);
    State.matchQueue = singleItem;
    State.matchRefRows = singleItem;
    return;
  }
  const docs = await withStatus(sb.from('documents').select('document_id,title,category,author,ref_date,match_ref,video_ref,pdv_ref,pending_deletion').order('document_id'));
  State.matchQueue = docs.filter(d => !d.pending_deletion && cfg.docFilter(d));
  State.matchRefRows = await withStatus(sb.from(cfg.refTable).select('*'));
}

function renderMatchBody() {
  const box = document.getElementById('match-body');
  const cfg = MATCH_LISTS[State.matchListKey];
  if (State.matchQueue.length === 0) {
    box.innerHTML = `<div class="empty-msg">Nothing to review for this list right now â€” either all matched, or no documents currently qualify.</div>`;
    return;
  }
  if (State.matchIndex >= State.matchQueue.length) {
    box.innerHTML = `<div class="empty-msg">All done for this list for now! Switch lists, or check back after new documents are added.</div>`;
    return;
  }
  const doc = State.matchQueue[State.matchIndex];
  const ranked = cfg.isWorkLink
    ? rankByDateProximity(doc.ref_date, State.matchRefRows.filter(r => r.document_id !== doc.document_id), 'ref_date')
    : cfg.rank(doc, State.matchRefRows);
  box.innerHTML = `
    <div class="hint" style="margin:10px 0;">${State.matchIndex + 1} of ${State.matchQueue.length} remaining in this list</div>
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
  renderCandidates(ranked, cfg, doc);
  renderDocDetail(doc.document_id);
  document.getElementById('match-skip').addEventListener('click', () => { State.matchIndex++; renderMatchBody(); });
  document.getElementById('match-search').addEventListener('input', e => {
    const term = e.target.value.toLowerCase();
    if (!term) { renderCandidates(ranked, cfg, doc); return; }
    const pool = cfg.isWorkLink ? State.matchRefRows.filter(r => r.document_id !== doc.document_id) : State.matchRefRows;
    const filtered = pool.filter(r => candidateLabel(r, cfg).toLowerCase().includes(term));
    renderCandidates(filtered, cfg, doc);
  });
}

function candidateLabel(r, cfg) {
  if (cfg.isWorkLink) return `#${r.document_id} â€” ${r.title || '(untitled)'} â€” ${r.ref_date || 'no date'} â€” ${r.provenance || '?'}/${r.language || '?'}`;
  return cfg.refLabel(r);
}

function renderCandidates(list, cfg, doc) {
  const box = document.getElementById('match-candidates');
  document.getElementById('match-candidates-count').textContent = `(${list.length} total, most likely first)`;
  if (list.length === 0) { box.innerHTML = '<div class="empty-msg">No candidates found.</div>'; return; }
  box.innerHTML = list.map((r, i) => {
    const sameVariant = cfg.isWorkLink && r.provenance === doc.provenance && r.language === doc.language;
    return `<div class="panel" style="margin-bottom:8px;padding:10px;">
      <div style="font-size:13px;">${esc(candidateLabel(r, cfg))}${sameVariant ? ' <span class="hint">(same source/language - more likely a duplicate than a translation)</span>' : ''}</div>
      <button class="btn" data-i="${i}" style="margin-top:6px;padding:4px 10px;">${cfg.isWorkLink ? 'Same document â€” merge' : 'Assign'}</button>
    </div>`;
  }).join('');
  box.querySelectorAll('[data-i]').forEach(btn => btn.addEventListener('click', async () => {
    const r = list[btn.dataset.i];
    if (cfg.isWorkLink) {
      await mergeWorks(r.document_id, [doc.document_id]);
    } else {
      await withStatus(sb.from('documents').update({ [cfg.field]: cfg.refValue(r) }).eq('document_id', doc.document_id), 'Saving...');
    }
    State.matchIndex++;
    renderMatchBody();
  }));
}
