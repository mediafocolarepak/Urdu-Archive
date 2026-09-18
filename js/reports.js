import { sb, State, esc, labelOf, optionsHtml, withStatus, withStatusCount, isDeptMember, isAdmin, reportTable, nameMapForEmails } from './core.js?v=20260918180126';

const APPLICATION_STATUS_LABEL = {
  pending: 'Pending', recommended: 'Recommended to Admin', approved: 'Approved', rejected: 'Rejected',
};

export function renderReportsView(main) {
  // Personnel report (owner's request, session of 2026-09-18): a printable roster of everyone
  // employed as an operator or department member, plus Join-the-Team admission requests, for
  // Admin/HR to bring to a meeting. Deliberately narrower than the People tab's own gate
  // (isDeptMember('HR') || isAnyDeptLead() || isAdmin()): collaboration_applications' RLS
  // (81_team_applications_hr_only.sql) only lets HR members and Admin read it, not every
  // department lead - a Coordination/Reward/Formation lead would otherwise see this button and
  // get a half-empty report (roster fine, applications silently filtered to nothing by RLS).
  const canSeePersonnel = isDeptMember('HR') || isAdmin();

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
    ${canSeePersonnel ? `
    <div class="panel no-print">
      <h2>Personnel &amp; Team Applications <span class="hint">(Admin / HR)</span></h2>
      <p class="hint">Every operator, coordinator and department member, plus every Join-the-Team application - one printable snapshot for a meeting or a periodic review.</p>
      <div class="btn-row">
        <button class="btn" id="r-generate-personnel">Generate</button>
        <button class="btn secondary" id="r-print-personnel">Print / Export PDF</button>
      </div>
    </div>` : ''}
    <div id="report-area"></div>
    <div id="personnel-report-area"></div>
    <style>@media print { @page { size: A4 landscape; } }</style>
  `;
  document.getElementById('r-generate').addEventListener('click', generateFilteredReport);
  document.getElementById('r-print').addEventListener('click', () => window.print());
  if (canSeePersonnel) {
    document.getElementById('r-generate-personnel').addEventListener('click', generatePersonnelReport);
    document.getElementById('r-print-personnel').addEventListener('click', () => window.print());
  }
}

async function generatePersonnelReport() {
  const area = document.getElementById('personnel-report-area');
  area.innerHTML = '<div class="empty-msg">Loading...</div>';

  const [people, applications] = await Promise.all([
    withStatus(sb.rpc('hr_people_overview'), 'Generating report...'),
    withStatus(sb.from('collaboration_applications').select('*').order('created_at', { ascending: false })),
  ]);

  const nameMap = await nameMapForEmails(applications.map(a => a.user_email));

  const peopleCols = [
    { key: 'full_name', label: 'Name' }, { key: 'email', label: 'Email' },
    { key: 'roleLabel', label: 'Role' }, { key: 'departments', label: 'Departments' },
    { key: 'qualifications', label: 'Qualifications' }, { key: 'standingLabel', label: 'Standing' },
    { key: 'credits', label: 'Credits' }, { key: 'reputation', label: 'Reputation' },
    { key: 'sinceLabel', label: 'Since' }, { key: 'riskLabel', label: 'At risk' },
  ];
  const peopleRows = people.map(p => ({
    ...p,
    roleLabel: p.role ? p.role.charAt(0).toUpperCase() + p.role.slice(1) : '—',
    standingLabel: p.standing ? p.standing.charAt(0).toUpperCase() + p.standing.slice(1) : '—',
    sinceLabel: (p.since || '').slice(0, 10),
    riskLabel: p.at_risk ? 'At risk' : '',
  })).sort((a, b) => (a.full_name || a.email).localeCompare(b.full_name || b.email));

  const appCols = [
    { key: 'nameLabel', label: 'Applicant' }, { key: 'user_email', label: 'Email' },
    { key: 'statusLabel', label: 'Status' }, { key: 'submittedLabel', label: 'Submitted' },
    { key: 'recommended_by_email', label: 'Recommended by' },
    { key: 'reviewed_by_email', label: 'Decided by' }, { key: 'coordinator_note', label: 'Note' },
  ];
  // Open requests (pending/recommended) first - the ones a meeting actually needs to act on -
  // then the historical record, newest first within each group.
  const statusOrder = { pending: 0, recommended: 1, approved: 2, rejected: 3 };
  const appRows = applications.map(a => ({
    ...a,
    nameLabel: nameMap[a.user_email] || '—',
    statusLabel: APPLICATION_STATUS_LABEL[a.status] || a.status,
    submittedLabel: (a.created_at || '').slice(0, 10),
  })).sort((a, b) => (statusOrder[a.status] ?? 9) - (statusOrder[b.status] ?? 9) || (b.created_at || '').localeCompare(a.created_at || ''));

  area.innerHTML = reportTable('Personnel Roster', peopleRows, peopleCols)
    + reportTable('Team Applications', appRows, appCols);
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
  // Collections are many-to-many (document_collections) - documents has no collection column.
  // Resolving the ids first keeps this a server-side filter, so `count` stays truthful.
  if (collection) {
    const matches = await withStatus(sb.from('document_collections').select('document_id').eq('collection_code', collection));
    q = q.in('document_id', matches.map(m => m.document_id));
  }
  if (source) q = q.eq('source', source);
  if (recipient) q = q.overlaps('recipient', [recipient]);
  if (from) q = q.gte('ref_date', from);
  if (to) q = q.lte('ref_date', to);
  q = q.order('document_id');

  const { data: rows, count } = await withStatusCount(q, 'Generating report...');
  if (!rows.length) { area.innerHTML = '<div class="empty-msg">No documents match these filters.</div>'; return; }

  const body = rows.map(r => `<tr><td>${esc(r.document_id)}</td><td>${esc(r.title)}</td><td>${esc(labelOf(State.categories, r.category))}</td>
    <td>${esc(labelOf(State.authors, r.author))}</td><td>${(r.recipient || []).map(c => labelOf(State.recipients, c)).join(', ')}</td>
    <td>${esc(r.ref_date)}</td><td>${esc(labelOf(State.statuses, r.workflow_status))}</td></tr>`).join('');
  area.innerHTML = `<div class="report-view">
    <h2>Filtered Document Report</h2>
    <div class="hint" style="margin-bottom:8px;">Total documents: ${count}</div>
    <table><thead><tr><th>ID</th><th>Title (EN)</th><th>Category</th><th>Author</th><th>Recipient(s)</th><th>Ref. date</th><th>Workflow status</th></tr></thead>
    <tbody>${body}</tbody></table>
  </div>`;
}
