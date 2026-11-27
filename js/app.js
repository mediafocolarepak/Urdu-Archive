import { State, isAdmin, isLeader, canReviewApplications, isAnyDeptLead, openTranslatePopup, boot, wireAuthButtons, confirmPopup, showLoadFailed, showOperatorIntro } from './core.js?v=20261127211058';
import { renderDashboardView } from './dashboard.js?v=20261127211058';
import { renderReportsView } from './reports.js?v=20261127211058';
import { renderFindWorkView, canFindWork } from './findwork.js?v=20261127211058';
import { renderHayatView } from './hayatindex.js?v=20261127211058';
import { renderMatchReviewView } from './matchreview.js?v=20261127211058';
import { renderBulkImportView } from './bulkimport.js?v=20261127211058';
import { renderUsersView, renderOptionsView, renderAnnouncementsView } from './admin.js?v=20261127211058';
import { renderAdminMessagesView, initChatNotifications } from './chat.js?v=20261127211058';
import { renderWorkView, loadWork } from './work.js?v=20261127211058';
import { renderWorkConsolidationView } from './workconsolidation.js?v=20261127211058';
import { renderHayatEditorView } from './hayateditor.js?v=20261127211058';
import { renderInPageConverterView } from './inpageconverter.js?v=20261127211058';
import { renderUserGuideView } from './userguide.js?v=20261127211058';
import { renderJoinTeamView } from './collaboration.js?v=20261127211058';
import { renderTasksView, initTaskNotifications } from './tasks.js?v=20261127211058';
import { renderMyProfileView } from './profile.js?v=20261127211058';
import { renderMySpaceView } from './myspace.js?v=20261127211058';
import { renderBoardsView } from './boards.js?v=20261127211058';
import { renderFormationView } from './formation.js?v=20261127211058';
import { renderBooksView } from './books.js?v=20261127211058';
import { renderMyDepartmentView, renderDepartmentsOverviewView, initDeptMessageNotifications } from './mydepartment.js?v=20261127211058';
import { renderOnboardingView } from './onboarding.js?v=20261127211058';
import { renderLanding } from './landing.js?v=20261127211058';
import { renderShareComposeView, renderShareInboxView, initShareNotifications } from './sharewithus.js?v=20261127211058';
import { renderProposalsView, initProposalNotifications } from './proposals.js?v=20261127211058';
import { renderReadingsView, initReadingNotifications } from './readings.js?v=20261127211058';
import { renderOverviewView, renderArchiveToolsView, loadWaiting } from './overview.js?v=20261127211058';
import { registerServiceWorker, initInstallBanner } from './pwa-register.js?v=20261127211058';

// Libri and Processi are retired as separate tabs: "Collection" is now a Dashboard filter,
// and process steps live in the Process History section of the document detail panel.
function getTabs() {
  const isOperator = State.currentRole === 'operator';
  const isUser = State.currentRole === 'user';

  // Users and Operators have the same bar (Owner's concept, 2026-11-25): an Operator is first of all a User, and has one
  // place more, My work. Everything else opens from Home or from My work; Help is always at the top.
  // Admins and Coordinators too, since 2026-11-27 (Owner's decision): Home first, and the tools in My work (workMenu below).
  if (isUser || isOperator || isLeader()) {
    return [
      { id: 'onboarding', label: 'Home' },
      { id: 'dashboard', label: 'Library' },
      ...(isUser ? [] : [{ id: 'work', label: 'My work' }]),
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
      { id: 'findwork', label: 'Find work' },
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
    { id: 'findwork', label: 'Find work' },
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

// My work of Admins and Coordinators: the tools in groups, in the bar on the left on a computer and in the Overview on a phone
// (overview.js). Every section of the old row of tabs is here, or in Home. [group, [[id, label, 'action'?]]]
function workMenu() {
  if (!isLeader()) return [];
  const admin = isAdmin();
  return [
    ['', [['work', 'Overview']]],
    ['To decide', [['tasks', 'Tasks'], ['proposals', 'Proposals'], ['readings', 'Recordings'], ['chat', 'Messages'], ...(admin || isAnyDeptLead() ? [['sharewithus', 'Shared with us']] : [])]],
    ['Archive', [['dashboard', 'Library'], ['translate', 'Translate a text', 'action'], ['findwork', 'Find work'], ['reports', 'Print Reports'], ['archivetools', 'Archive tools']]],
    ['Team', [...(State.myDepartments.length || admin ? [['mydepartment', admin ? 'Departments' : 'My Department']] : []), ['boards', 'Boards'], ['formation', 'Formation Paths'], ...(admin ? [['users', 'Users'], ['announcements', 'Announcements']] : [])]],
    ...(admin ? [['Settings', [['options', 'Options']]]] : []),
  ];
}
// A tool of My work, from the bar or from the Overview.
function workTool(id) {
  const item = workMenu().flatMap(([, items]) => items).find(([x]) => x === id);
  if (item && item[2] === 'action') { if (id === 'translate') openTranslatePopup(); return; }
  renderTab(id, 'work');
}
window.__workTool = workTool;
// Where a section opened from inside another lights the bar (the archive tools, the old Project overview).
const WORK_VOICE = { hayat: 'archivetools', matchreview: 'archivetools', workconsolidation: 'archivetools', hayateditor: 'archivetools', bulkimport: 'archivetools', inpageconverter: 'archivetools', deptoverview: 'work' };

function initTopbar() {
  const bar = document.getElementById('tabs');
  const tabs = getTabs();
  bar.innerHTML = tabs.map(t => `<button class="tab-btn" data-tab="${t.id}">${t.label}</button>`).join('');
  bar.querySelectorAll('.tab-btn').forEach(b => b.addEventListener('click', () => renderTab(b.dataset.tab)));
  initBottomNav(tabs);
}

// The two places. Sections only of the work; sections that serve both, dressed differently in each (core.js quiet()); the
// others belong to Home. A section opened from inside another keeps the place the person is in.
const WORK_ONLY = new Set(['work', 'tasks', 'proposals', 'mydepartment', 'findwork', 'inpageconverter', 'hayat', 'hayateditor', 'matchreview', 'workconsolidation', 'bulkimport', 'deptoverview', 'archivetools', 'chat', 'reports', 'users', 'options', 'announcements']);
const BOTH = new Set(['dashboard', 'boards', 'formation', 'readings', 'sharewithus', 'help']);
function placeFor(id, asked) {
  if (!['operator', 'coordinator', 'admin'].includes(State.currentRole)) return 'home';
  if (WORK_ONLY.has(id)) return 'work';
  if (BOTH.has(id)) return asked || State.place;
  return 'home';
}
// Which voice of the bar a section belongs to.
function voiceOf(id) {
  if (State.place === 'work') return isLeader() ? WORK_VOICE[id] || id : 'work';
  if (['dashboard', 'sharewithus', 'profile', 'jointeam', ...BAR_MORE.map(([x]) => x)].includes(id)) return id;
  if (id === 'chat') return 'sharewithus';
  return id === 'help' ? '' : 'onboarding';
}
// Each section's guide, for the Help button at the top (userguide.js).
const GUIDE_OF = { dashboard: 'find-read', boards: 'boards', formation: 'formation-paths', readings: 'read-aloud', sharewithus: 'talk-team', tasks: 'tasks', proposals: 'propose', mydepartment: 'my-department', work: 'teamwork', findwork: 'find-work' };

const NAV_ICONS = {
  onboarding: 'M3 11l9-8 9 8M5 10v10h14V10',
  dashboard: 'M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM4 17a3 3 0 0 1 3-3h12',
  myspace: 'M6 3h12v18l-6-4-6 4z',
  work: 'M4 8h16v11H4zM9 8V5h6v3M4 13h16',
  sharewithus: 'M4 5h16v11H9l-5 4z',
  mydepartment: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M17 11a3 3 0 1 0 0-6M17 14a6 6 0 0 1 4 6',
  tasks: 'M4 6h3M4 12h3M4 18h3M10 6h10M10 12h10M10 18h10',
  books: 'M4 19V5a2 2 0 0 1 2-2h13v14H6a2 2 0 0 0-2 2zm0 0a2 2 0 0 0 2 2h13M9 7h6',
  boards: 'M4 4h16v11H4zM8 20l4-5 4 5M8 8h8M8 11h5',
  formation: 'M12 6C10 4.5 7 4 4 4v15c3 0 6 .5 8 2 2-1.5 5-2 8-2V4c-3 0-6 .5-8 2zM12 6v15',
  proposals: 'M12 4v16M4 12h16',
  readings: 'M12 15a3 3 0 0 0 3-3V6a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zM6 11a6 6 0 0 0 12 0M12 17v4',
  inpageconverter: 'M4 7h13l-3-3M20 17H7l3 3',
  chat: 'M3 6h18v12H3zM3 7l9 6 9-6',
  jointeam: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M19 8v6M16 11h6',
  profile: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21a8 8 0 0 1 16 0',
  help: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 1-1 1.7M12 17h.01',
  findwork: 'M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM21 21l-5-5',
  reports: 'M6 9V3h12v6M6 18H4v-7h16v7h-2M8 14h8v7H8z',
  archivetools: 'M3 4h18v4H3zM5 8v12h14V8M10 12h4',
  users: 'M8 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM2 16a6 6 0 0 1 12 0M15 6h7M15 11h7M15 16h5',
  announcements: 'M3 10v4h4l6 4V6l-6 4zM17 9a4 4 0 0 1 0 6',
  options: 'M4 6h9M17 6h3M4 12h3M11 12h9M4 18h11M19 18h1M15 4v4M9 10v4M17 16v4',
  translate: 'M4 5h9M8 3v2M11 5c-1 4-4 7-7 8M6 9c1 2 3 4 5 5M12 20l4-9 4 9M13.5 17h5',
  more: 'M5 12h.01M12 12h.01M19 12h.01',
};
const navIcon = id => `<svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="${id === 'more' ? 3 : 2}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="${NAV_ICONS[id] || NAV_ICONS.more}"/></svg>`;
// On a computer the bar on the left also lists what Home offers, in the order of its tiles (Owner's request, 2026-11-27): there
// is room, and it helps to go from one to another. On a phone these stay hidden (style.css .bn-more) and Home stays lit.
const BAR_MORE = [['books', 'Books'], ['formation', 'Formation Paths'], ['boards', 'Boards'], ['myspace', 'My Space'], ['readings', 'Read aloud']];
function barItems(tabs) {
  const out = [];
  for (const t of tabs) {
    out.push(t);
    if (t.id === 'dashboard') out.push(...BAR_MORE.map(([id, label]) => ({ id, label, more: true })));
    if (t.id === 'sharewithus' && State.currentRole === 'user' && !State.paused) out.push({ id: 'jointeam', label: 'Join the Team', more: true });
  }
  return out;
}
// The bar of Users and Operators: at the bottom on a phone, on the left on a computer (style.css). Coordinators and Admins
// keep the row of sections at the top.
function initBottomNav(tabs) {
  const nav = document.getElementById('bottom-nav');
  const on = ['user', 'operator', 'coordinator', 'admin'].includes(State.currentRole);
  document.body.classList.toggle('has-bottom-nav', on);
  document.body.classList.toggle('reader-topbar', on);
  document.body.classList.toggle('is-operator', State.currentRole === 'operator');
  document.body.classList.toggle('is-leader', isLeader());
  document.getElementById('help-top').hidden = !on;
  if (!on) { nav.innerHTML = ''; return; }
  nav.innerHTML = barItems(tabs).map(t => `<button class="bn-btn${t.more ? ' bn-more' : ''}" data-tab="${t.id}">${navIcon(t.id)}<span class="bn-label">${t.label}</span>${t.id === 'work' ? '<span class="bn-count" id="work-count" hidden></span>' : ''}</button>`).join('')
    // In My work, on a computer, the bar of an Admin or a Coordinator shows the tools instead (style.css .bn-wm).
    + (isLeader() ? '<button class="bn-btn bn-wm bn-wm-back" data-tab="onboarding" type="button"><span aria-hidden="true">&lsaquo;</span><span class="bn-label">Home</span></button>'
      + workMenu().map(([group, items]) => (group ? `<span class="bn-group bn-wm">${group}</span>` : '')
        + items.map(([id, label]) => `<button class="bn-btn bn-wm" data-tab="${id}" data-tool="${id}" type="button">${navIcon(id)}<span class="bn-label">${label}</span>${id === 'work' ? '<span class="bn-count" id="wm-count" hidden></span>' : ''}</button>`).join('')).join('') : '')
    + '<button class="bn-narrow" id="bn-narrow" type="button"></button>';
  nav.querySelectorAll('.bn-btn:not(.bn-wm)').forEach(b => b.addEventListener('click', () => renderTab(b.dataset.tab, b.dataset.tab === 'work' ? 'work' : 'home')));
  nav.querySelector('.bn-wm-back')?.addEventListener('click', () => renderTab('onboarding', 'home'));
  nav.querySelectorAll('.bn-wm[data-tool]').forEach(b => b.addEventListener('click', () => workTool(b.dataset.tool)));
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
  for (const el of [document.getElementById('work-count'), document.getElementById('wm-count')]) {
    if (el) { el.hidden = !count; el.textContent = count > 99 ? '99+' : count; el.setAttribute('aria-label', `${count} waiting`); }
  }
  const tile = document.getElementById('home-work-note');
  if (tile) tile.textContent = count ? `${count} thing${count === 1 ? ' is' : 's are'} waiting` : 'Nothing is waiting';
}
async function refreshWorkCount(now) {
  if (!['operator', 'coordinator', 'admin'].includes(State.currentRole) || (!now && Date.now() - workCountAt < 60000)) return;
  workCountAt = Date.now();
  try { showWorkCount(isLeader() ? (await loadWaiting()).total : (await loadWork()).todo.length); } catch (e) { console.warn('My work:', e); }
}

// How tall the page's scrolling area is, for what must stay in sight inside it (style.css, --main-h).
new ResizeObserver(([entry]) => requestAnimationFrame(() => document.documentElement.style.setProperty('--main-h', Math.round(entry.contentRect.height) + 'px'))).observe(document.getElementById('main'));

// A form with something not saved says so in State.unsaved (a sentence); leaving it asks first.
window.addEventListener('beforeunload', e => { if (State.unsaved) { e.preventDefault(); e.returnValue = ''; } });

// The browser's Back goes to the section before, and each section has its own address (#tasks). What a section opens inside
// itself (a document on a phone, a book, a guide) keeps its own step, as before: those steps carry no "tab".
let popping = false;
window.addEventListener('popstate', () => { popping = true; setTimeout(() => { popping = false; }, 0); }, true);
window.addEventListener('popstate', e => {
  const s = e.state;
  if (!s || !s.tab || !State.appShown) return;
  if (document.getElementById('main').dataset.section !== s.tab || State.place !== s.place || (State.sub || '') !== (s.sub || '')) { popping = true; renderTab(s.tab, s.place, s.sub || ''); popping = false; }
});
function canOpen(id) {
  if (getTabs().some(t => t.id === id)) return true;
  if (State.currentRole === 'user') return ['books', 'myspace', 'boards', 'formation', 'readings', 'jointeam', 'help', 'chat'].includes(id) && !(id === 'jointeam' && State.paused);
  if (isLeader()) return workMenu().some(([, items]) => items.some(([x, , kind]) => x === id && kind !== 'action'))
    || ['books', 'myspace', 'boards', 'formation', 'readings', 'help', 'deptoverview', 'hayat', 'matchreview', 'workconsolidation', 'hayateditor', 'inpageconverter'].includes(id) || (id === 'bulkimport' && isAdmin());
  if (State.currentRole === 'operator') return ['books', 'myspace', 'boards', 'formation', 'readings', 'tasks', 'proposals', 'inpageconverter', 'help', 'chat'].includes(id) || (id === 'mydepartment' && State.myDepartments.length > 0) || (id === 'findwork' && canFindWork());
  return false;
}

// sub: a page inside a section, with its own address (#task/51, #review/51, #department/HR/people).
const SUBS = { tasks: /^(task|review)\/\d+$/, proposals: /^proposal\/\d+$/, dashboard: /^doc\/\d+$/, mydepartment: /^department\/[\w-]+(\/[a-z]+(\/[\w-]+)?)?$/ };
function renderTab(id, place, sub = '') {
  // Reporting something is one of the things to share (Owner's decision, 2026-11-25): one door for Users and Operators.
  if (id === 'chat' && !canReviewApplications()) { State.shareDoor = true; id = 'sharewithus'; place = 'home'; }
  if (State.unsaved) {
    confirmPopup(State.unsaved, { confirmLabel: 'Leave without saving', cancelLabel: 'Stay here', danger: true }).then(leave => {
      if (!leave) return;
      State.unsaved = '';
      renderTab(id, place, sub);
    });
    return;
  }
  State.place = placeFor(id, place);
  State.sub = SUBS[id] && SUBS[id].test(sub) ? sub : '';
  document.body.classList.toggle('place-work', State.place === 'work');
  document.body.classList.toggle('place-home', State.place !== 'work');
  document.body.classList.toggle('at-work', id === 'work');
  document.body.classList.toggle('at-desk', id === 'tasks' && !!State.sub);
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === id));
  const voice = voiceOf(id);
  const inMenu = isLeader() && State.place === 'work';
  document.querySelectorAll('.bn-btn').forEach(b => { const on = b.dataset.tab === voice && b.classList.contains('bn-wm') === inMenu && !b.classList.contains('bn-wm-back'); b.classList.toggle('active', on); b.toggleAttribute('aria-current', on); });
  // On a phone the sections of Home have no voice of their own in the bar: Home stays lit. In My work of an Admin or a
  // Coordinator, My work does.
  document.querySelector('.bn-btn[data-tab="onboarding"]:not(.bn-wm)')?.classList.toggle('phone-on', !inMenu && (BAR_MORE.some(([x]) => x === voice) || voice === 'jointeam'));
  document.querySelector('.bn-btn[data-tab="work"]:not(.bn-wm)')?.classList.toggle('phone-on', inMenu);
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
  if (!popping && id !== 'help' && !(history.state && history.state.tab === id && history.state.place === State.place && (history.state.sub || '') === State.sub)) history.pushState({ tab: id, place: State.place, sub: State.sub }, '', '#' + (State.sub || id));
  refreshWorkCount(id === 'onboarding' && State.place === 'home' && workCountAt === 0);
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  // A section that cannot be read says so, with Try again, instead of staying on "Loading...".
  Promise.resolve().then(() => drawSection(id, main)).then(() => computerNote(id, main)).catch(e => {
    if (main.dataset.section !== id) return;
    const box = document.createElement('div');
    if (main.children.length <= 1 && /^\s*Loading/.test(main.textContent)) main.innerHTML = '';
    main.prepend(box);
    showLoadFailed(box, e, () => renderTab(id, place, sub));
  });
}
function drawSection(id, main) {
  if (id === 'dashboard') return renderDashboardView(main);
  else if (id === 'books') return renderBooksView(main);
  else if (id === 'myspace') return renderMySpaceView(main);
  else if (id === 'boards') return renderBoardsView(main);
  else if (id === 'formation') return renderFormationView(main);
  else if (id === 'reports') return renderReportsView(main);
  else if (id === 'findwork') return renderFindWorkView(main);
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
  else if (id === 'work' && isLeader()) return renderOverviewView(main, workMenu()).then(w => { if (w) { workCountAt = Date.now(); showWorkCount(w.total); } });
  else if (id === 'archivetools') return renderArchiveToolsView(main);
  else if (id === 'work') return renderWorkView(main).then(w => { if (w) { workCountAt = Date.now(); showWorkCount(w.todo.length); } });
  else if (id === 'mydepartment') return renderMyDepartmentView(main);
  else if (id === 'deptoverview') return renderDepartmentsOverviewView(main);
  else if (id === 'tasks') return renderTasksView(main);
  else if (id === 'jointeam') return renderJoinTeamView(main);
  else if (id === 'profile') return renderMyProfileView(main);
  else if (id === 'help') return renderUserGuideView(main);
  else if (id === 'onboarding') return renderOnboardingView(main);
  // The leads' inbox is work: an Operator who leads a department finds it in My work, and shares from Home like everyone.
  else if (id === 'sharewithus') return (isAdmin() || isAnyDeptLead()) && State.place === 'work' ? renderShareInboxView(main) : renderShareComposeView(main);
}

// The tools made for a computer say so on a phone, kindly; they stay usable (Owner's decision, 2026-11-27).
const COMPUTER_TOOLS = new Set(['findwork', 'inpageconverter', 'hayateditor', 'matchreview', 'workconsolidation', 'bulkimport', 'hayat']);
function computerNote(id, main) {
  if (!COMPUTER_TOOLS.has(id) || main.dataset.section !== id || !window.matchMedia('(max-width: 900px)').matches || main.querySelector('.computer-note')) return;
  main.insertAdjacentHTML('afterbegin', '<p class="computer-note"><span aria-hidden="true">&#128187;</span> This tool works best on a computer.</p>');
}

// Escape hatch so docdetail.js's Print Tracking Sheet "Back" button can navigate without
// importing this module (which would create a circular import - see docdetail.js).
window.__renderTab = renderTab;
// The landing page before signing in (landing.js), shown by core.js's showLogin.
window.__renderLanding = renderLanding;

wireAuthButtons();
boot(() => {
  // Everyone lands on Home (Operators since 2026-11-25, Admins and Coordinators since 2026-11-27). An address with a section
  // (#tasks) opens it, if this person has it.
  initTopbar();
  const hash = location.hash.slice(1), subOf = Object.keys(SUBS).find(k => SUBS[k].test(hash));
  const asked = subOf || (hash.match(/^([a-z]+)$/) || [])[1];
  const first = 'onboarding';
  const start = asked && canOpen(asked) ? asked : first;
  const startSub = start === subOf ? hash : '';
  history.replaceState({ tab: start, place: placeFor(start, 'home'), sub: startSub }, '', '#' + (startSub || start));
  State.place = 'home';
  renderTab(start, 'home', startSub);
  showOperatorIntro();
  initChatNotifications(() => renderTab('chat'));
  initTaskNotifications(() => renderTab('tasks', 'work'));
  initDeptMessageNotifications(code => renderTab('mydepartment', undefined, `department/${code}/team`));
  initShareNotifications(() => renderTab('sharewithus', isAnyDeptLead() || isAdmin() ? 'work' : 'home'));
  initProposalNotifications(() => renderTab('proposals'));
  initReadingNotifications(() => renderTab('readings', isLeader() ? 'work' : undefined));
});
registerServiceWorker();
initInstallBanner();
