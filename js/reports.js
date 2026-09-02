import { sb, State, esc, labelOf, optionsHtml, withStatusCount } from './core.js?v=20260902153222';

export function renderReportsView(main) {
  main.innerHTML = `
    <div class="panel no-print">
      <h2>Print Reports</h2>
      <div class="field-grid">
        <div class="field"><label>Category</label><select id="r-category">${optionsHtml(State.categories, '', true)}</select></div>
        <div class="field"><label>Main topic</label><select id="r-main_topic">${optionsHtml(State.mainTopics, '', true)}</select></div>
        <div class="field"><label>Author</label><select id="r-author">${optionsHtml(State.authors, '', true)}</select></div>
        <div class="field"><label>Recipient</label><select id="r-recipient">${optionsHtml(State.recipients, '', true)}</select></div>
        <div class="field"><label>Workflow status</label><select id="r-status">${optionsHtml(State.statuses, '', true)}</select></div>
        <div class="field"><label>Collection</label><select id="r-collection">${optionsHtml(State.collections, '', true)}</select></div>
        <div class="field"><label>Source</label><select id="r-source">${optionsHtml(State.sources, '', true)}</select></div>
        <div class="field"><label>Date from</label><input id="r-from" type="date"></div>
        <div class="field"><label>Date to</label><input id="r-to" type="date"></div>
      </div>
      <div class="btn-row">
        <button class="btn" id="r-generate">Generate</button>
        <button class="btn secondary" id="r-print">Print / Export PDF</button>
      </div>
    </div>
    <div id="report-area"></div>
    <style>@media print { @page { size: A4 landscape; } }</style>
  `;
  document.getElementById('r-generate').addEventListener('click', generateFilteredReport);
  document.getElementById('r-print').addEventListener('click', () => window.print());
}

async function generateFilteredReport() {
  const area = document.getElementById('report-area');
  area.innerHTML = '<div class="empty-msg">Loading...</div>';
  const category = document.getElementById('r-category').value;
  const mainTopic = document.getElementById('r-main_topic').value;
  const author = document.getElementById('r-author').value;
  const recipient = document.getElementById('r-recipient').value;
  const status = document.getElementById('r-status').value;
  const collection = document.getElementById('r-collection').value;
  const source = document.getElementById('r-source').value;
  const from = document.getElementById('r-from').value;
  const to = document.getElementById('r-to').value;

  let q = sb.from('documents').select('*', { count: 'exact' });
  if (category) q = q.eq('category', category);
  if (mainTopic) q = q.eq('main_topic', mainTopic);
  if (author) q = q.eq('author', author);
  if (status) q = q.eq('workflow_status', status);
  if (collection) q = q.eq('collection', collection);
  if (source) q = q.eq('source', source);
  if (recipient) q = q.overlaps('recipient', [recipient]);
  if (from) q = q.gte('ref_date', from);
  if (to) q = q.lte('ref_date', to);
  q = q.order('document_id');

  const { data: rows, count } = await withStatusCount(q, 'Generating report...');
  if (!rows.length) { area.innerHTML = '<div class="empty-msg">No documents match these filters.</div>'; return; }

  const body = rows.map(r => `<tr><td>${esc(r.document_id)}</td><td>${esc(r.title)}</td><td>${esc(labelOf(State.categories, r.category))}</td>
    <td>${esc(labelOf(State.authors, r.author))}</td><td>${(r.recipient || []).map(c => labelOf(State.recipients, c)).join(', ')}</td>
    <td>${esc(r.ref_date)}</td><td>${esc(labelOf(State.statuses, r.workflow_status))}</td><td>${esc(r.physical_box)}</td></tr>`).join('');
  area.innerHTML = `<div class="report-view">
    <h2>Filtered Document Report</h2>
    <div class="hint" style="margin-bottom:8px;">Total documents: ${count}</div>
    <table><thead><tr><th>ID</th><th>Title (EN)</th><th>Category</th><th>Author</th><th>Recipient(s)</th><th>Ref. date</th><th>Workflow status</th><th>Physical box</th></tr></thead>
    <tbody>${body}</tbody></table>
  </div>`;
}
