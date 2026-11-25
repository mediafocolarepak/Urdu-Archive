import { State, isAdmin, canReviewApplications, isAnyDeptLead, boot, wireAuthButtons, confirmPopup, showLoadFailed } from './core.js?v=20261125104645';
import { renderDashboardView } from './dashboard.js?v=20261125104645';
import { renderReportsView } from './reports.js?v=20261125104645';
import { renderHayatView } from './hayatindex.js?v=20261125104645';
import { renderMatchReviewView } from './matchreview.js?v=20261125104645';
import { renderBulkImportView } from './bulkimport.js?v=20261125104645';
import { renderUsersView, renderOptionsView, renderAnnouncementsView } from './admin.js?v=20261125104645';
import { renderChatView, renderAdminMessagesView, initChatNotifications } from './chat.js?v=20261125104645';
import { renderWorkConsolidationView } from './workconsolidation.js?v=20261125104645';
import { renderHayatEditorView } from './hayateditor.js?v=20261125104645';
import { renderInPageConverterView } from './inpageconverter.js?v=20261125104645';
import { renderUserGuideView } from './userguide.js?v=20261125104645';
import { renderJoinTeamView } from './collaboration.js?v=20261125104645';
import { renderTasksView, initTaskNotifications } from './tasks.js?v=20261125104645';
import { renderMyProfileView } from './profile.js?v=20261125104645';
import { renderMySpaceView } from './myspace.js?v=20261125104645';
import { renderBoardsView } from './boards.js?v=20261125104645';
import { renderFormationView } from './formation.js?v=20261125104645';
import { renderBooksView } from './books.js?v=20261125104645';
import { renderMyDepartmentView, renderDepartmentsOverviewView, initDeptMessageNotifications } from './mydepartment.js?v=20261125104645';
import { renderOnboardingView } from './onboarding.js?v=20261125104645';
import { renderLanding } from './landing.js?v=20261125104645';
import { renderShareComposeView, renderShareInboxView, initShareNotifications } from './sharewithus.js?v=20261125104645';
import { renderProposalsView, initProposalNotifications } from './proposals.js?v=20261125104645';
import { renderReadingsView, initReadingNotifications } from './readings.js?v=20261125104645';
import { registerServiceWorker, initInstallBanner } from './pwa-register.js?v=20261125104645';

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
      { id: 'onboarding', label: 'Home' },
      { id: 'dashboard', label: 'Library' },
      { id: 'books', label: 'Books' },
      { id: 'myspace', label: 'My Space' },
      { id: 'boards', label: 'Boards' },
      { id: 'formation', label: 'Formation Paths' },
      { id: 'sharewithus', label: 'Share with us' },
      { id: 'readings', label: 'Read aloud' },
      { id: 'chat', label: 'Report a problem' },
      { id: 'jointeam', label: 'Join the Team' },
      { id: 'profile', label: 'My Profile' },
    ];
  }

  // Plain Operators: a fixed, explicit order (owner's request 2026-09-20) - Tasks leads since
  // that's their main queue; People was never shown to them (an HR-lead/Coordinator/Admin tool).
  // Proofreading is gone entirely (owner's request 2026-09-20, see below). The cataloguing tools
  // (Hayat Index/Match Review/Work Consolidation/Hayat Editor/Bulk Import) are no longer flat
  // tabs gated by the "Data Assistant" qualification - they're grouped under My Department ->
  // "Archive & Data" department instead (owner's request 2026-09-20, see renderArchiveTools in
  // mydepartment.js), reachable by whoever is a member of that department.
  if (isOperator) {
    const tabs = [{ id: 'dashboard', label: 'Dashboard' }, { id: 'books', label: 'Books' }];
    // My Department in second position, right after Dashboard (owner's request 2026-09-20).
    if (State.myDepartments.length > 0) { tabs.push({ id: 'mydepartment', label: 'My Department' }); }
    tabs.push({ id: 'myspace', label: 'My Space' });
    tabs.push({ id: 'boards', label: 'Boards' });
    tabs.push({ id: 'formation', label: 'Formation Paths' });
    tabs.push({ id: 'tasks', label: 'Tasks' });
    tabs.push({ id: 'proposals', label: 'Proposals' });
    tabs.push({ id: 'readings', label: 'Read aloud' });
    tabs.push({ id: 'inpageconverter', label: 'InPage Converter' });
    tabs.push({ id: 'chat', label: 'Report a problem' });
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
  // there to select - see mydepartment.js's renderArchiveTools). The standalone People tab is
  // gone too (owner's request 2026-09-20, redundant with My Department): the roster and pending
  // decisions live under My Department -> HR, and Task reputation tiers/Policy under HR and
  // Reward - Admin reaches all of it the same way, via My Department (every department listed).
  // Proofreading is gone as well (owner's request 2026-09-20): now that every PDF has been
  // replaced, the bulk unreviewed-transcription queue (reread.js, removed) no longer has a
  // backlog to work through - an error found in a text is reported and fixed through the
  // ordinary "Report a Problem or Suggestion" -> task flow instead.
  if (isAdmin()) {
    return [
      { id: 'dashboard', label: 'Dashboard' },
      { id: 'books', label: 'Books' },
      { id: 'mydepartment', label: 'My Department' },
      // Admin-only roll-up of every department's status/priorities (migration 98, owner's
      // request 2026-09-20) - "Department Pulse", see mydepartment.js.
      { id: 'deptoverview', label: 'Project overview' },
      { id: 'myspace', label: 'My Space' },
      { id: 'boards', label: 'Boards' },
      { id: 'formation', label: 'Formation Paths' },
      { id: 'tasks', label: 'Tasks' },
      { id: 'proposals', label: 'Proposals' },
      { id: 'readings', label: 'Read aloud' },
      { id: 'announcements', label: 'Announcements' },
      { id: 'chat', label: 'Messages' },
      { id: 'sharewithus', label: 'Share with us' },
      { id: 'reports', label: 'Print Reports' },
      { id: 'users', label: 'Users' },
      { id: 'options', label: 'Options' },
      { id: 'profile', label: 'My Profile' },
      { id: 'help', label: 'Help' },
    ];
  }

  // Coordinator: general-purpose layout - cataloguing tools except Bulk Import (Admin only since
  // 2026-11-05, reached from My Department -> Archive & Data), Tasks, and My
  // Department for whichever departments they belong to (People, if they're HR lead, is reached
  // from there now). Proofreading is gone (owner's request 2026-09-20, see above).
  const tabs = [
    { id: 'dashboard', label: 'Dashboard' },
    { id: 'books', label: 'Books' },
    { id: 'myspace', label: 'My Space' },
    { id: 'boards', label: 'Boards' },
    { id: 'formation', label: 'Formation Paths' },
    { id: 'reports', label: 'Print Reports' },
    { id: 'hayat', label: 'Hayat Index' },
    { id: 'matchreview', label: 'Match Review' },
    { id: 'workconsolidation', label: 'Work Consolidation' },
    { id: 'hayateditor', label: 'Hayat Editor' },
    { id: 'inpageconverter', label: 'InPage Converter' },
  ];
  if (State.myDepartments.length > 0) { tabs.push({ id: 'mydepartment', label: 'My Department' }); }
  tabs.push({ id: 'tasks', label: 'Tasks' });
  tabs.push({ id: 'proposals', label: 'Proposals' });
  tabs.push({ id: 'readings', label: 'Read aloud' });
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
  initBottomNav(tabs);
}

// Bottom navigation bar for phones (owner's request 2026-10-23): Users and Operators get their four
// most-used sections pinned at the bottom plus "More" for the rest; Coordinators and Admins work
// mostly from a computer and keep the top bar only. Shown by CSS under 900px; the top tab strip is
// hidden there for these roles. The tab lists above stay the single source of what each role may open.
const BOTTOM_NAV = {
  user: ['onboarding', 'dashboard', 'myspace', 'sharewithus'],
  operator: ['dashboard', 'mydepartment', 'tasks', 'myspace'],
};
const NAV_ICONS = {
  onboarding: 'M3 11l9-8 9 8M5 10v10h14V10',
  dashboard: 'M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM4 17a3 3 0 0 1 3-3h12',
  myspace: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21a8 8 0 0 1 16 0',
  sharewithus: 'M4 5h16v11H9l-5 4z',
  mydepartment: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M17 11a3 3 0 1 0 0-6M17 14a6 6 0 0 1 4 6',
  tasks: 'M4 6h3M4 12h3M4 18h3M10 6h10M10 12h10M10 18h10',
  books: 'M12 6c-2-2-5-2-8-1v14c3-1 6-1 8 1 2-2 5-2 8-1V5c-3-1-6-1-8 1zM12 6v14',
  boards: 'M4 4h16v11H4zM8 20l4-5 4 5M8 8h8M8 11h5',
  formation: 'M12 4l9 5-9 5-9-5zM7 11v5c3 2 7 2 10 0v-5',
  proposals: 'M12 4v16M4 12h16',
  readings: 'M12 15a3 3 0 0 0 3-3V6a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zM6 11a6 6 0 0 0 12 0M12 17v4',
  inpageconverter: 'M4 7h13l-3-3M20 17H7l3 3',
  chat: 'M12 4l9 16H3zM12 10v4M12 17h.01',
  jointeam: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M19 8v6M16 11h6',
  profile: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21a8 8 0 0 1 16 0',
  help: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 1-1 1.7M12 17h.01',
  more: 'M5 12h.01M12 12h.01M19 12h.01',
};
// Each section's colour, for the list under "More" (style.css has them for the tabs and the pages).
const NAV_COLOUR = { onboarding: 'start', dashboard: 'library', books: 'books', myspace: 'myspace', boards: 'boards', formation: 'formation', sharewithus: 'share', readings: 'readings',
  chat: 'report', jointeam: 'share', profile: 'profile', help: 'start', tasks: 'work', proposals: 'work', mydepartment: 'dept', inpageconverter: 'dept' };
const navIcon = id => `<svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="${id === 'more' ? 3 : 2}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="${NAV_ICONS[id] || NAV_ICONS.more}"/></svg>`;
let navMoreIds = [];
function initBottomNav(tabs) {
  const nav = document.getElementById('bottom-nav');
  const wanted = BOTTOM_NAV[State.currentRole];
  document.body.classList.toggle('has-bottom-nav', !!wanted);
  // A reader's top bar shows only the app's name (Owner's request, 2026-11-23): the email and Sign out are in My Profile,
  // and the turning wheel says when the app is working.
  // Operators too since 2026-11-25; beside the name they keep their credits. Admins and Coordinators keep the whole bar.
  document.body.classList.toggle('reader-topbar', !!wanted);
  document.body.classList.toggle('team-topbar', State.currentRole === 'operator');
  if (!wanted) { nav.innerHTML = ''; return; }
  const pinned = wanted.map(id => tabs.find(t => t.id === id)).filter(Boolean);
  const more = tabs.filter(t => !pinned.some(p => p.id === t.id));
  navMoreIds = more.map(t => t.id);
  const icon = navIcon;
  nav.innerHTML = pinned.map(t => `<button class="bn-btn" data-tab="${t.id}">${icon(t.id)}<span>${t.label}</span></button>`).join('') +
    (more.length ? `<button class="bn-btn" id="bn-more" data-tab="more">${icon('more')}<span>More</span></button>` : '');
  nav.querySelectorAll('.bn-btn[data-tab]:not(#bn-more)').forEach(b => b.addEventListener('click', () => renderTab(b.dataset.tab)));
  document.getElementById('bn-more')?.addEventListener('click', () => openMoreSheet(more));
}
function openMoreSheet(more) {
  document.getElementById('bn-more-sheet')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'bn-more-sheet';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `<div class="panel overlay-panel bn-sheet"><h2 style="margin-top:0;">More</h2>${more.map(t => `<button class="btn secondary bn-sheet-item" data-tab="${t.id}" style="--sec:var(--c-${NAV_COLOUR[t.id] || 'profile'})">${navIcon(t.id)}<span>${t.label}</span></button>`).join('')}</div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  backdrop.querySelectorAll('.bn-sheet-item').forEach(b => b.addEventListener('click', () => { backdrop.remove(); renderTab(b.dataset.tab); }));
}

// How tall the page's scrolling area is, for what must stay in sight inside it (style.css, --main-h).
new ResizeObserver(([entry]) => document.documentElement.style.setProperty('--main-h', Math.round(entry.contentRect.height) + 'px')).observe(document.getElementById('main'));

// A form with something not saved says so in State.unsaved (a sentence); leaving it asks first.
window.addEventListener('beforeunload', e => { if (State.unsaved) { e.preventDefault(); e.returnValue = ''; } });

function renderTab(id) {
  if (State.unsaved) {
    confirmPopup(State.unsaved, { confirmLabel: 'Leave without saving', cancelLabel: 'Stay here', danger: true }).then(leave => {
      if (!leave) return;
      State.unsaved = '';
      renderTab(id);
    });
    return;
  }
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === id));
  document.querySelectorAll('.bn-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === id || (b.dataset.tab === 'more' && navMoreIds.includes(id))));
  const main = document.getElementById('main');
  main.dataset.section = id;
  main.scrollTop = 0;
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  // A section that cannot be read says so, with Try again, instead of staying on "Loading...".
  Promise.resolve().then(() => drawSection(id, main)).catch(e => {
    if (main.dataset.section !== id) return;
    const box = document.createElement('div');
    if (main.children.length <= 1 && /^\s*Loading/.test(main.textContent)) main.innerHTML = '';
    main.prepend(box);
    showLoadFailed(box, e, () => renderTab(id));
  });
}
function drawSection(id, main) {
  if (id === 'dashboard') return renderDashboardView(main);
  else if (id === 'books') return renderBooksView(main);
  else if (id === 'myspace') return renderMySpaceView(main);
  else if (id === 'boards') return renderBoardsView(main);
  else if (id === 'formation') return renderFormationView(main);
  else if (id === 'reports') return renderReportsView(main);
  else if (id === 'hayat') return renderHayatView(main);
  else if (id === 'users') return renderUsersView(main);
  else if (id === 'options') return renderOptionsView(main);
  else if (id === 'matchreview') return renderMatchReviewView(main);
  else if (id === 'workconsolidation') return renderWorkConsolidationView(main);
  else if (id === 'hayateditor') return renderHayatEditorView(main);
  else if (id === 'bulkimport' && isAdmin()) return renderBulkImportView(main);
  else if (id === 'proposals') return renderProposalsView(main);
  else if (id === 'readings') return renderReadingsView(main);
  else if (id === 'inpageconverter') return renderInPageConverterView(main);
  else if (id === 'announcements') return renderAnnouncementsView(main);
  else if (id === 'chat') return canReviewApplications() ? renderAdminMessagesView(main) : renderChatView(main);
  else if (id === 'mydepartment') return renderMyDepartmentView(main);
  else if (id === 'deptoverview') return renderDepartmentsOverviewView(main);
  else if (id === 'tasks') return renderTasksView(main);
  else if (id === 'jointeam') return renderJoinTeamView(main);
  else if (id === 'profile') return renderMyProfileView(main);
  else if (id === 'help') return renderUserGuideView(main);
  else if (id === 'onboarding') return renderOnboardingView(main);
  else if (id === 'sharewithus') return (isAnyDeptLead() || isAdmin()) ? renderShareInboxView(main) : renderShareComposeView(main);
}

// Escape hatch so docdetail.js's Print Tracking Sheet "Back" button can navigate without
// importing this module (which would create a circular import - see docdetail.js).
window.__renderTab = renderTab;
// The landing page before signing in (landing.js), shown by core.js's showLogin.
window.__renderLanding = renderLanding;

wireAuthButtons();
boot(() => {
  // Plain Users land on "Home" (Start Here until 2026-11-18) instead of Dashboard (owner's request 2026-09-21): it's
  // their landing page now, not just a tab they can find - everyone else still opens Dashboard.
  initTopbar(); renderTab(State.currentRole === 'user' ? 'onboarding' : 'dashboard');
  initChatNotifications(() => renderTab('chat'));
  initTaskNotifications(() => renderTab('tasks'));
  initDeptMessageNotifications(code => { State.myDeptSelected = code; renderTab('mydepartment'); });
  initShareNotifications(() => renderTab('sharewithus'));
  initProposalNotifications(() => renderTab('proposals'));
  initReadingNotifications(() => renderTab('readings'));
});
registerServiceWorker();
initInstallBanner();
