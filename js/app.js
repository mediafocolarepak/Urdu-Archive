import { State, isAdmin, canReviewApplications, isAnyDeptLead, boot, wireAuthButtons, confirmPopup, showLoadFailed } from './core.js?v=20261125122603';
import { renderDashboardView } from './dashboard.js?v=20261125122603';
import { renderReportsView } from './reports.js?v=20261125122603';
import { renderHayatView } from './hayatindex.js?v=20261125122603';
import { renderMatchReviewView } from './matchreview.js?v=20261125122603';
import { renderBulkImportView } from './bulkimport.js?v=20261125122603';
import { renderUsersView, renderOptionsView, renderAnnouncementsView } from './admin.js?v=20261125122603';
import { renderAdminMessagesView, initChatNotifications } from './chat.js?v=20261125122603';
import { renderWorkView, loadWork } from './work.js?v=20261125122603';
import { renderWorkConsolidationView } from './workconsolidation.js?v=20261125122603';
import { renderHayatEditorView } from './hayateditor.js?v=20261125122603';
import { renderInPageConverterView } from './inpageconverter.js?v=20261125122603';
import { renderUserGuideView } from './userguide.js?v=20261125122603';
import { renderJoinTeamView } from './collaboration.js?v=20261125122603';
import { renderTasksView, initTaskNotifications } from './tasks.js?v=20261125122603';
import { renderMyProfileView } from './profile.js?v=20261125122603';
import { renderMySpaceView } from './myspace.js?v=20261125122603';
import { renderBoardsView } from './boards.js?v=20261125122603';
import { renderFormationView } from './formation.js?v=20261125122603';
import { renderBooksView } from './books.js?v=20261125122603';
import { renderMyDepartmentView, renderDepartmentsOverviewView, initDeptMessageNotifications } from './mydepartment.js?v=20261125122603';
import { renderOnboardingView } from './onboarding.js?v=20261125122603';
import { renderLanding } from './landing.js?v=20261125122603';
import { renderShareComposeView, renderShareInboxView, initShareNotifications } from './sharewithus.js?v=20261125122603';
import { renderProposalsView, initProposalNotifications } from './proposals.js?v=20261125122603';
import { renderReadingsView, initReadingNotifications } from './readings.js?v=20261125122603';
import { registerServiceWorker, initInstallBanner } from './pwa-register.js?v=20261125122603';

// Libri and Processi are retired as separate tabs: "Collection" is now a Dashboard filter,
// and process steps live in the Process History section of the document detail panel.
function getTabs() {
  const isOperator = State.currentRole === 'operator';
  const isUser = State.currentRole === 'user';

  // Users and Operators have the same bar (Owner's concept, 2026-11-25): an Operator is first of all a User, and has one
  // place more, My work. Everything else opens from Home or from My work; Help is always at the top.
  if (isUser || isOperator) {
    return [
      { id: 'onboarding', label: 'Home' },
      { id: 'dashboard', label: 'Library' },
      ...(isOperator ? [{ id: 'work', label: 'My work' }] : []),
      { id: 'sharewithus', label: 'Share with us' },
      { id: 'profile', label: 'My Profile' },
    ];
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

// The two places. Sections only of the work; sections that serve both, dressed differently in each (core.js quiet()); the
// others belong to Home. A section opened from inside another keeps the place the person is in.
const WORK_ONLY = new Set(['work', 'tasks', 'proposals', 'mydepartment', 'inpageconverter', 'hayat', 'hayateditor', 'matchreview', 'workconsolidation', 'bulkimport', 'deptoverview']);
const BOTH = new Set(['dashboard', 'boards', 'formation', 'readings', 'sharewithus', 'help']);
function placeFor(id, asked) {
  if (State.currentRole !== 'operator') return 'home';
  if (WORK_ONLY.has(id)) return 'work';
  if (BOTH.has(id)) return asked || State.place;
  return 'home';
}
// Which voice of the bar a section belongs to.
function voiceOf(id) {
  if (State.place === 'work') return 'work';
  if (['dashboard', 'sharewithus', 'profile'].includes(id)) return id;
  if (id === 'chat') return 'sharewithus';
  return id === 'help' ? '' : 'onboarding';
}
// Each section's guide, for the Help button at the top (userguide.js).
const GUIDE_OF = { dashboard: 'find-read', boards: 'boards', formation: 'formation-paths', readings: 'read-aloud', sharewithus: 'talk-team', tasks: 'tasks', proposals: 'propose', mydepartment: 'my-department', work: 'teamwork' };

const NAV_ICONS = {
  onboarding: 'M3 11l9-8 9 8M5 10v10h14V10',
  dashboard: 'M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM4 17a3 3 0 0 1 3-3h12',
  myspace: 'M6 3h12v18l-6-4-6 4z',
  work: 'M4 8h16v11H4zM9 8V5h6v3M4 13h16',
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
const navIcon = id => `<svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="${id === 'more' ? 3 : 2}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="${NAV_ICONS[id] || NAV_ICONS.more}"/></svg>`;
// The bar of Users and Operators: at the bottom on a phone, on the left on a computer (style.css). Coordinators and Admins
// keep the row of sections at the top.
function initBottomNav(tabs) {
  const nav = document.getElementById('bottom-nav');
  const on = ['user', 'operator'].includes(State.currentRole);
  document.body.classList.toggle('has-bottom-nav', on);
  document.body.classList.toggle('reader-topbar', on);
  document.body.classList.toggle('is-operator', State.currentRole === 'operator');
  document.getElementById('help-top').hidden = !on;
  if (!on) { nav.innerHTML = ''; return; }
  nav.innerHTML = tabs.map(t => `<button class="bn-btn" data-tab="${t.id}">${navIcon(t.id)}<span class="bn-label">${t.label}</span>${t.id === 'work' ? '<span class="bn-count" id="work-count" hidden></span>' : ''}</button>`).join('')
    + '<button class="bn-narrow" id="bn-narrow" type="button"></button>';
  nav.querySelectorAll('.bn-btn').forEach(b => b.addEventListener('click', () => renderTab(b.dataset.tab, b.dataset.tab === 'work' ? 'work' : 'home')));
  // On a computer the bar can be only its signs; the choice stays on this device.
  const narrow = document.getElementById('bn-narrow');
  const show = () => {
    const is = document.body.classList.contains('nav-narrow');
    narrow.innerHTML = is ? '&raquo;' : '&laquo; <span class="bn-label">Less</span>';
    narrow.setAttribute('aria-label', is ? 'Show the names' : 'Show only the signs');
    nav.querySelectorAll('.bn-btn').forEach(b => { b.title = is ? b.querySelector('.bn-label').textContent : ''; });
  };
  try { document.body.classList.toggle('nav-narrow', localStorage.getItem('navNarrow') === '1'); } catch { /* not needed to work */ }
  narrow.addEventListener('click', () => {
    const is = document.body.classList.toggle('nav-narrow');
    try { localStorage.setItem('navNarrow', is ? '1' : ''); } catch { /* not needed to work */ }
    show();
  });
  show();
}

// How many things wait in My work, beside its name and on its tile in Home: a small number, nothing more.
let workCountAt = 0;
function showWorkCount(count) {
  State.workCount = count;
  const el = document.getElementById('work-count');
  if (el) { el.hidden = !count; el.textContent = count > 99 ? '99+' : count; el.setAttribute('aria-label', `${count} waiting`); }
  const tile = document.getElementById('home-work-note');
  if (tile) tile.textContent = count ? `${count} thing${count === 1 ? ' is' : 's are'} waiting` : 'Nothing is waiting';
}
async function refreshWorkCount(now) {
  if (State.currentRole !== 'operator' || (!now && Date.now() - workCountAt < 60000)) return;
  workCountAt = Date.now();
  try { showWorkCount((await loadWork()).todo.length); } catch (e) { console.warn('My work:', e); }
}

// How tall the page's scrolling area is, for what must stay in sight inside it (style.css, --main-h).
new ResizeObserver(([entry]) => document.documentElement.style.setProperty('--main-h', Math.round(entry.contentRect.height) + 'px')).observe(document.getElementById('main'));

// A form with something not saved says so in State.unsaved (a sentence); leaving it asks first.
window.addEventListener('beforeunload', e => { if (State.unsaved) { e.preventDefault(); e.returnValue = ''; } });

// The browser's Back goes to the section before, and each section has its own address (#tasks). What a section opens inside
// itself (a document on a phone, a book, a guide) keeps its own step, as before: those steps carry no "tab".
let popping = false;
window.addEventListener('popstate', () => { popping = true; setTimeout(() => { popping = false; }, 0); }, true);
window.addEventListener('popstate', e => {
  const s = e.state;
  if (!s || !s.tab || !State.appShown) return;
  if (document.getElementById('main').dataset.section !== s.tab || State.place !== s.place) { popping = true; renderTab(s.tab, s.place); popping = false; }
});
function canOpen(id) {
  if (getTabs().some(t => t.id === id)) return true;
  if (State.currentRole === 'user') return ['books', 'myspace', 'boards', 'formation', 'readings', 'jointeam', 'help', 'chat'].includes(id);
  if (State.currentRole === 'operator') return ['books', 'myspace', 'boards', 'formation', 'readings', 'tasks', 'proposals', 'inpageconverter', 'help', 'chat'].includes(id) || (id === 'mydepartment' && State.myDepartments.length > 0);
  return false;
}

function renderTab(id, place) {
  // Reporting something is one of the things to share (Owner's decision, 2026-11-25): one door for Users and Operators.
  if (id === 'chat' && !canReviewApplications()) { State.shareDoor = true; id = 'sharewithus'; place = 'home'; }
  if (State.unsaved) {
    confirmPopup(State.unsaved, { confirmLabel: 'Leave without saving', cancelLabel: 'Stay here', danger: true }).then(leave => {
      if (!leave) return;
      State.unsaved = '';
      renderTab(id, place);
    });
    return;
  }
  State.place = placeFor(id, place);
  document.body.classList.toggle('place-work', State.place === 'work');
  document.body.classList.toggle('place-home', State.place !== 'work');
  document.body.classList.toggle('at-work', id === 'work');
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === id));
  const voice = voiceOf(id);
  document.querySelectorAll('.bn-btn').forEach(b => { b.classList.toggle('active', b.dataset.tab === voice); b.toggleAttribute('aria-current', b.dataset.tab === voice); });
  // The band that says "you are in the room of the work", and leads back to it.
  const bar = document.getElementById('place-bar');
  bar.hidden = State.place !== 'work';
  if (State.place === 'work') {
    bar.innerHTML = id === 'work' ? `<span class="place-name">${navIcon('work')} My work</span>` : `<button type="button" class="place-name place-back">&lsaquo; ${navIcon('work')} My work</button>`;
    bar.querySelector('button')?.addEventListener('click', () => renderTab('work', 'work'));
  }
  const help = document.getElementById('help-top');
  const guide = GUIDE_OF[id];
  if (guide) { help.dataset.helpGuide = guide; delete help.dataset.helpHome; } else { delete help.dataset.helpGuide; help.dataset.helpHome = ''; }
  const main = document.getElementById('main');
  main.dataset.section = id;
  main.scrollTop = 0;
  if (!popping && id !== 'help' && !(history.state && history.state.tab === id && history.state.place === State.place)) history.pushState({ tab: id, place: State.place }, '', '#' + id);
  refreshWorkCount(id === 'onboarding' && State.place === 'home' && workCountAt === 0);
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  // A section that cannot be read says so, with Try again, instead of staying on "Loading...".
  Promise.resolve().then(() => drawSection(id, main)).catch(e => {
    if (main.dataset.section !== id) return;
    const box = document.createElement('div');
    if (main.children.length <= 1 && /^\s*Loading/.test(main.textContent)) main.innerHTML = '';
    main.prepend(box);
    showLoadFailed(box, e, () => renderTab(id, place));
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
  else if (id === 'chat') return renderAdminMessagesView(main);
  else if (id === 'work') return renderWorkView(main).then(w => { if (w) { workCountAt = Date.now(); showWorkCount(w.todo.length); } });
  else if (id === 'mydepartment') return renderMyDepartmentView(main);
  else if (id === 'deptoverview') return renderDepartmentsOverviewView(main);
  else if (id === 'tasks') return renderTasksView(main);
  else if (id === 'jointeam') return renderJoinTeamView(main);
  else if (id === 'profile') return renderMyProfileView(main);
  else if (id === 'help') return renderUserGuideView(main);
  else if (id === 'onboarding') return renderOnboardingView(main);
  // The leads' inbox is work: an Operator who leads a department finds it in My work, and shares from Home like everyone.
  else if (id === 'sharewithus') return (isAdmin() || (isAnyDeptLead() && (State.currentRole !== 'operator' || State.place === 'work'))) ? renderShareInboxView(main) : renderShareComposeView(main);
}

// Escape hatch so docdetail.js's Print Tracking Sheet "Back" button can navigate without
// importing this module (which would create a circular import - see docdetail.js).
window.__renderTab = renderTab;
// The landing page before signing in (landing.js), shown by core.js's showLogin.
window.__renderLanding = renderLanding;

wireAuthButtons();
boot(() => {
  // Users and Operators land on Home (Operators since 2026-11-25); everyone else on the Dashboard. An address with a section
  // (#tasks) opens it, if this person has it.
  initTopbar();
  const asked = (location.hash.match(/^#([a-z]+)$/) || [])[1];
  const first = ['user', 'operator'].includes(State.currentRole) ? 'onboarding' : 'dashboard';
  const start = asked && canOpen(asked) ? asked : first;
  history.replaceState({ tab: start, place: placeFor(start, 'home') }, '', '#' + start);
  State.place = 'home';
  renderTab(start, 'home');
  initChatNotifications(() => renderTab('chat'));
  initTaskNotifications(() => renderTab('tasks', 'work'));
  initDeptMessageNotifications(code => { State.myDeptSelected = code; renderTab('mydepartment'); });
  initShareNotifications(() => renderTab('sharewithus', isAnyDeptLead() ? 'work' : 'home'));
  initProposalNotifications(() => renderTab('proposals'));
  initReadingNotifications(() => renderTab('readings'));
});
registerServiceWorker();
initInstallBanner();
