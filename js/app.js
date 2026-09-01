import { State, canWrite, isAdmin, canReviewApplications, boot, wireAuthButtons } from './core.js?v=20260901205125';
import { renderDashboardView } from './dashboard.js?v=20260901205125';
import { renderReportsView } from './reports.js?v=20260901205125';
import { renderHayatView } from './hayatindex.js?v=20260901205125';
import { renderMatchReviewView } from './matchreview.js?v=20260901205125';
import { renderBulkImportView } from './bulkimport.js?v=20260901205125';
import { renderUsersView, renderOptionsView, renderAnnouncementsView } from './admin.js?v=20260901205125';
import { renderChatView, renderAdminMessagesView, initChatNotifications } from './chat.js?v=20260901205125';
import { renderAdminEditView } from './adminedit.js?v=20260901205125';
import { renderWorkConsolidationView } from './workconsolidation.js?v=20260901205125';
import { renderHayatEditorView } from './hayateditor.js?v=20260901205125';
import { renderInPageConverterView } from './inpageconverter.js?v=20260901205125';
import { renderUserGuideView } from './userguide.js?v=20260901205125';
import { renderJoinTeamView, renderApplicationsView } from './collaboration.js?v=20260901205125';
import { renderTasksView, initTaskNotifications } from './tasks.js?v=20260901205125';
import { registerServiceWorker } from './pwa-register.js?v=20260901205125';

// Libri and Processi are retired as separate tabs: "Collection" is now a Dashboard filter,
// and process steps live in the Process History section of the document detail panel.
function getTabs() {
  // Plain Operators are meant to work the Tasks queue, not the cataloguing tools - so Hayat
  // Index/Match Review/Work Consolidation/Hayat Editor/Bulk Import stay hidden for them unless
  // they hold the "Data Assistant" qualification (Options -> Operator qualifications).
  // Coordinator/Admin always see them; InPage Converter is unaffected (not part of this list).
  const dataToolsHidden = State.currentRole === 'operator' && !State.myQualifications.has('DATA_ASSISTANT');
  const tabs = [
    { id: 'dashboard', label: 'Dashboard' },
    { id: 'reports', label: 'Print Reports' },
  ];
  if (!dataToolsHidden) tabs.push({ id: 'hayat', label: 'Hayat Index' });
  if (canWrite()) {
    if (!dataToolsHidden) {
      tabs.push({ id: 'matchreview', label: 'Match Review' });
      tabs.push({ id: 'workconsolidation', label: 'Work Consolidation' });
      tabs.push({ id: 'hayateditor', label: 'Hayat Editor' });
      tabs.push({ id: 'bulkimport', label: 'Bulk Import' });
    }
    tabs.push({ id: 'inpageconverter', label: 'InPage Converter' });
  }
  if (canReviewApplications()) { tabs.push({ id: 'applications', label: 'Team Applications' }); }
  if (canWrite()) { tabs.push({ id: 'tasks', label: 'Tasks' }); }
  if (isAdmin()) { tabs.push({ id: 'users', label: 'Users' }); tabs.push({ id: 'options', label: 'Options' }); tabs.push({ id: 'adminedit', label: 'Edit Records' }); tabs.push({ id: 'announcements', label: 'Announcements' }); }
  tabs.push({ id: 'chat', label: canReviewApplications() ? 'Messages' : 'Chat' });
  // Persistently visible invitation for read-only accounts - collaborators (Operator+)
  // already have other ways to reach out, see the "Join the Team" module for why.
  if (State.currentRole === 'user') { tabs.push({ id: 'jointeam', label: 'Join the Team' }); }
  tabs.push({ id: 'help', label: 'Help' });
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
  else if (id === 'inpageconverter') renderInPageConverterView(main);
  else if (id === 'announcements') renderAnnouncementsView(main);
  else if (id === 'chat') { canReviewApplications() ? renderAdminMessagesView(main) : renderChatView(main); }
  else if (id === 'applications') renderApplicationsView(main);
  else if (id === 'tasks') renderTasksView(main);
  else if (id === 'jointeam') renderJoinTeamView(main);
  else if (id === 'help') renderUserGuideView(main);
}

// Escape hatch so docdetail.js's Print Tracking Sheet "Back" button can navigate without
// importing this module (which would create a circular import - see docdetail.js).
window.__renderTab = renderTab;

wireAuthButtons();
boot(() => { initTopbar(); renderTab('dashboard'); initChatNotifications(() => renderTab('chat')); initTaskNotifications(() => renderTab('tasks')); });
registerServiceWorker();
