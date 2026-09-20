import { State, isAdmin, canReviewApplications, isDeptLead, isAnyDeptLead, boot, wireAuthButtons } from './core.js?v=20260920102321';
import { renderDashboardView } from './dashboard.js?v=20260920102321';
import { renderReportsView } from './reports.js?v=20260920102321';
import { renderHayatView } from './hayatindex.js?v=20260920102321';
import { renderMatchReviewView } from './matchreview.js?v=20260920102321';
import { renderBulkImportView } from './bulkimport.js?v=20260920102321';
import { renderUsersView, renderOptionsView, renderAnnouncementsView } from './admin.js?v=20260920102321';
import { renderChatView, renderAdminMessagesView, initChatNotifications } from './chat.js?v=20260920102321';
import { renderWorkConsolidationView } from './workconsolidation.js?v=20260920102321';
import { renderHayatEditorView } from './hayateditor.js?v=20260920102321';
import { renderInPageConverterView } from './inpageconverter.js?v=20260920102321';
import { renderUserGuideView } from './userguide.js?v=20260920102321';
import { renderJoinTeamView } from './collaboration.js?v=20260920102321';
import { renderTasksView, initTaskNotifications } from './tasks.js?v=20260920102321';
import { renderMyProfileView } from './profile.js?v=20260920102321';
import { renderMySpaceView } from './myspace.js?v=20260920102321';
import { renderBoardsView } from './boards.js?v=20260920102321';
import { renderFormationView } from './formation.js?v=20260920102321';
import { renderPeopleView } from './people.js?v=20260920102321';
import { renderMyDepartmentView, initDeptMessageNotifications } from './mydepartment.js?v=20260920102321';
import { renderRereadView } from './reread.js?v=20260920102321';
import { renderOnboardingView } from './onboarding.js?v=20260920102321';
import { renderShareComposeView, renderShareInboxView, initShareNotifications } from './sharewithus.js?v=20260920102321';
import { registerServiceWorker } from './pwa-register.js?v=20260920102321';

// Libri and Processi are retired as separate tabs: "Collection" is now a Dashboard filter,
// and process steps live in the Process History section of the document detail panel.
function getTabs() {
  const isOperator = State.currentRole === 'operator';
  const isUser = State.currentRole === 'user';

  // Plain Users: a fixed, explicit order (owner's request 2026-09-20) - a minimal read-only
  // set plus the outreach/collaboration tabs, no cataloguing tools, no Help (Start Here
  // replaces it, see onboarding.js).
  if (isUser) {
    return [
      { id: 'onboarding', label: 'Start Here' },
      { id: 'dashboard', label: 'Dashboard' },
      { id: 'myspace', label: 'My Space' },
      { id: 'boards', label: 'Boards' },
      { id: 'formation', label: 'Formation Paths' },
      { id: 'sharewithus', label: 'Share with us' },
      { id: 'chat', label: 'Report a Problem or Suggestion' },
      { id: 'jointeam', label: 'Join the Team' },
      { id: 'profile', label: 'My Profile' },
    ];
  }

  // Plain Operators: a fixed, explicit order (owner's request 2026-09-20) - Tasks leads since
  // that's their main queue; People and Proofreading are never shown to them regardless of any
  // department they hold (those stay HR-lead/Coordinator/Admin tools). The cataloguing tools
  // (Hayat Index/Match Review/Work Consolidation/Hayat Editor/Bulk Import) are no longer flat
  // tabs gated by the "Data Assistant" qualification - they're grouped under My Department ->
  // "Archive & Data" department instead (owner's request 2026-09-20, see renderArchiveTools in
  // mydepartment.js), reachable by whoever is a member of that department.
  if (isOperator) {
    const tabs = [
      { id: 'dashboard', label: 'Dashboard' },
      { id: 'myspace', label: 'My Space' },
      { id: 'boards', label: 'Boards' },
      { id: 'formation', label: 'Formation Paths' },
      { id: 'tasks', label: 'Tasks' },
    ];
    if (State.myDepartments.length > 0) { tabs.push({ id: 'mydepartment', label: 'My Department' }); }
    tabs.push({ id: 'inpageconverter', label: 'InPage Converter' });
    tabs.push({ id: 'chat', label: 'Report a Problem or Suggestion' });
    // Share with us: Operators can now give their own feedback to the team leads/Admin the same
    // way Users do, from the compose view (owner's request 2026-09-20) - see sharewithus.js.
    tabs.push({ id: 'sharewithus', label: 'Share with us' });
    tabs.push({ id: 'profile', label: 'My Profile' });
    tabs.push({ id: 'help', label: 'Help' });
    return tabs;
  }

  // Admin: a fixed, explicit order (owner's request 2026-09-20) - the cataloguing tools (Hayat
  // Index/Match Review/Work Consolidation/Hayat Editor/Bulk Import) are no longer flat tabs here
  // either, same reasoning as Operators: reachable via My Department -> Archive & Data instead
  // (myDepartmentCodes() already lists every department for Admin, so that department is always
  // there to select - see mydepartment.js's renderArchiveTools).
  if (isAdmin()) {
    return [
      { id: 'dashboard', label: 'Dashboard' },
      { id: 'myspace', label: 'My Space' },
      { id: 'boards', label: 'Boards' },
      { id: 'formation', label: 'Formation Paths' },
      { id: 'tasks', label: 'Tasks' },
      { id: 'mydepartment', label: 'My Department' },
      { id: 'announcements', label: 'Announcements' },
      { id: 'chat', label: 'Messages' },
      { id: 'sharewithus', label: 'Share with us' },
      { id: 'reports', label: 'Print Reports' },
      { id: 'people', label: 'People' },
      { id: 'users', label: 'Users' },
      { id: 'reread', label: 'Proofreading' },
      { id: 'options', label: 'Options' },
      { id: 'profile', label: 'My Profile' },
      { id: 'help', label: 'Help' },
    ];
  }

  // Coordinator: unchanged general-purpose layout - full cataloguing toolset, Tasks,
  // Proofreading, and (if HR lead) People, plus My Department for whichever departments they
  // belong to.
  const tabs = [
    { id: 'dashboard', label: 'Dashboard' },
    { id: 'myspace', label: 'My Space' },
    { id: 'boards', label: 'Boards' },
    { id: 'formation', label: 'Formation Paths' },
    { id: 'reports', label: 'Print Reports' },
    { id: 'hayat', label: 'Hayat Index' },
    { id: 'matchreview', label: 'Match Review' },
    { id: 'workconsolidation', label: 'Work Consolidation' },
    { id: 'hayateditor', label: 'Hayat Editor' },
    { id: 'bulkimport', label: 'Bulk Import' },
    { id: 'inpageconverter', label: 'InPage Converter' },
  ];
  if (isDeptLead('HR')) { tabs.push({ id: 'people', label: 'People' }); }
  if (State.myDepartments.length > 0) { tabs.push({ id: 'mydepartment', label: 'My Department' }); }
  tabs.push({ id: 'tasks', label: 'Tasks' });
  tabs.push({ id: 'reread', label: 'Proofreading' });
  tabs.push({ id: 'profile', label: 'My Profile' });
  tabs.push({ id: 'chat', label: 'Messages' });
  tabs.push({ id: 'help', label: 'Help' });
  if (isAnyDeptLead()) { tabs.push({ id: 'sharewithus', label: 'Share with us' }); }
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
  else if (id === 'myspace') renderMySpaceView(main);
  else if (id === 'boards') renderBoardsView(main);
  else if (id === 'formation') renderFormationView(main);
  else if (id === 'reports') renderReportsView(main);
  else if (id === 'hayat') renderHayatView(main);
  else if (id === 'users') renderUsersView(main);
  else if (id === 'options') renderOptionsView(main);
  else if (id === 'matchreview') renderMatchReviewView(main);
  else if (id === 'workconsolidation') renderWorkConsolidationView(main);
  else if (id === 'hayateditor') renderHayatEditorView(main);
  else if (id === 'bulkimport') renderBulkImportView(main);
  else if (id === 'inpageconverter') renderInPageConverterView(main);
  else if (id === 'announcements') renderAnnouncementsView(main);
  else if (id === 'chat') { canReviewApplications() ? renderAdminMessagesView(main) : renderChatView(main); }
  else if (id === 'people') renderPeopleView(main);
  else if (id === 'mydepartment') renderMyDepartmentView(main);
  else if (id === 'tasks') renderTasksView(main);
  else if (id === 'reread') renderRereadView(main);
  else if (id === 'jointeam') renderJoinTeamView(main);
  else if (id === 'profile') renderMyProfileView(main);
  else if (id === 'help') renderUserGuideView(main);
  else if (id === 'onboarding') renderOnboardingView(main);
  else if (id === 'sharewithus') { (isAnyDeptLead() || isAdmin()) ? renderShareInboxView(main) : renderShareComposeView(main); }
}

// Escape hatch so docdetail.js's Print Tracking Sheet "Back" button can navigate without
// importing this module (which would create a circular import - see docdetail.js).
window.__renderTab = renderTab;

wireAuthButtons();
boot(() => {
  initTopbar(); renderTab('dashboard');
  initChatNotifications(() => renderTab('chat'));
  initTaskNotifications(() => renderTab('tasks'));
  initDeptMessageNotifications(code => { State.myDeptSelected = code; renderTab('mydepartment'); });
  initShareNotifications(() => renderTab('sharewithus'));
});
registerServiceWorker();
