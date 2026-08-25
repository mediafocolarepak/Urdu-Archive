import { State, canWrite, isAdmin, boot, wireAuthButtons } from './core.js?v=20260825114048';
import { renderDashboardView } from './dashboard.js?v=20260825114048';
import { renderReportsView } from './reports.js?v=20260825114048';
import { renderHayatView } from './hayatindex.js?v=20260825114048';
import { renderMatchReviewView } from './matchreview.js?v=20260825114048';
import { renderBulkImportView } from './bulkimport.js?v=20260825114048';
import { renderUsersView, renderOptionsView } from './admin.js?v=20260825114048';
import { renderAdminEditView } from './adminedit.js?v=20260825114048';
import { renderWorkConsolidationView } from './workconsolidation.js?v=20260825114048';
import { renderHayatEditorView } from './hayateditor.js?v=20260825114048';

// Libri and Processi are retired as separate tabs: "Collection" is now a Dashboard filter,
// and process steps live in the Process History section of the document detail panel.
function getTabs() {
  const tabs = [
    { id: 'dashboard', label: 'Dashboard' },
    { id: 'reports', label: 'Print Reports' },
    { id: 'hayat', label: 'Hayat Index' },
  ];
  if (canWrite()) {
    tabs.push({ id: 'matchreview', label: 'Match Review' });
    tabs.push({ id: 'workconsolidation', label: 'Work Consolidation' });
    tabs.push({ id: 'hayateditor', label: 'Hayat Editor' });
    tabs.push({ id: 'bulkimport', label: 'Bulk Import' });
  }
  if (isAdmin()) { tabs.push({ id: 'users', label: 'Users' }); tabs.push({ id: 'options', label: 'Options' }); tabs.push({ id: 'adminedit', label: 'Edit Records' }); }
  return tabs;
}

function initTopbar() {
  const bar = document.getElementById('tabs');
  const tabs = getTabs();
  bar.innerHTML = tabs.map(t => `<button class="tab-btn" data-tab="${t.id}">${t.label}</button>`).join('');
  bar.querySelectorAll('.tab-btn').forEach(b => b.addEventListener('click', () => renderTab(b.dataset.tab)));
}

function renderTab(id) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === id));
  const main = document.getElementById('main');
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  if (id === 'dashboard') renderDashboardView(main);
  else if (id === 'reports') renderReportsView(main);
  else if (id === 'hayat') renderHayatView(main);
  else if (id === 'users') renderUsersView(main);
  else if (id === 'options') renderOptionsView(main);
  else if (id === 'adminedit') renderAdminEditView(main);
  else if (id === 'matchreview') renderMatchReviewView(main);
  else if (id === 'workconsolidation') renderWorkConsolidationView(main);
  else if (id === 'hayateditor') renderHayatEditorView(main);
  else if (id === 'bulkimport') renderBulkImportView(main);
}

// Escape hatch so docdetail.js's Print Tracking Sheet "Back" button can navigate without
// importing this module (which would create a circular import - see docdetail.js).
window.__renderTab = renderTab;

wireAuthButtons();
boot(() => { initTopbar(); renderTab('dashboard'); });
