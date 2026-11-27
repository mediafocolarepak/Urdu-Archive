// "Home": the first tab of a User (Owner's request, 2026-11-18). It replaced "Start Here" (95_onboarding_and_share_
// with_us.sql, redesigned 2026-11-06), whose Word of Life and three sections of cards moved to the landing page shown
// before signing in (landing.js). Home is a short set of large tiles to the sections of the app: in each, the English
// in bold on the left and the Urdu in Nastaliq on the right (Owner's layout).
// Since 2026-11-23 (Owner's request) Home starts with the Word of Life of the month, as the landing page does, and with
// "Continue" tiles: the last document opened on this device, and the formation path being read.

import { sb, State, esc } from './core.js?v=20261127224837';
import { openReadingView } from './docdetail.js?v=20261127224837';
import { lastBookBookmark } from './books.js?v=20261127224837';

// The Urdu names are the ones of the Urdu guides (Documentazione/guide-help/ur1.mjs, ur2.mjs, migration 119): Boards,
// Formation Paths and Help have one there; the others are named in Latin letters there too, so they stand alone
// until the Owner gives a word. Never invented (memory: Urdu wording is the Owner's).
// Since 2026-11-25 Home is the same for Users and Operators, and silent; an Operator has one quiet tile more, My work, at the
// end. My Profile and Help are no longer tiles: one is in the bar, the other always at the top.
const HOME_TILES = [
  // The Library first (Owner's request, 2026-11-18). The Urdu guides call it "Library" in Latin letters too.
  ['dashboard', 'Library', ''],
  // Books (2026-11-24): the Link-ups and, later, other kinds of text read as a book. No Urdu name yet: the Owner's.
  ['books', 'Books', ''],
  ['formation', 'Formation Paths', 'تربیتی راستے'],
  ['boards', 'Boards', 'بورڈز'],
  ['myspace', 'My Space', ''],
  ['readings', 'Read aloud', ''],
  ['sharewithus', 'Share with us', ''],
  ['jointeam', 'Join the Team', ''],
];
// From the Urdu guides (help "find-read"): the Word of Life of this month.
const WORD_OF_MONTH_UR = 'اس مہینے کا کلامِ حیات';

const NAV_PATHS = {
  dashboard: 'M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM4 17a3 3 0 0 1 3-3h12',
  myspace: 'M6 3h12v18l-6-4-6 4z',
  readings: 'M12 15a3 3 0 0 0 3-3V6a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zM6 11a6 6 0 0 0 12 0M12 17v4',
  work: 'M4 8h16v11H4zM9 8V5h6v3M4 13h16',
  boards: 'M4 4h16v11H4zM8 20l4-5 4 5M8 8h8M8 11h5',
  formation: 'M12 6C10 4.5 7 4 4 4v15c3 0 6 .5 8 2 2-1.5 5-2 8-2V4c-3 0-6 .5-8 2zM12 6v15',
  sharewithus: 'M4 5h16v11H9l-5 4z',
  jointeam: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M19 8v6M16 11h6',
  profile: 'M4 5h16v14H4zM9 12a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM6 16a3 3 0 0 1 6 0M14 9h4M14 13h4',
  help: 'M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM9.5 9.5a2.5 2.5 0 1 1 3.4 2.3c-.6.3-.9.8-.9 1.4v.6M12 17h.01',
  word: 'M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
  about: 'M3 11l9-8 9 8M5 10v10h14V10',
  how_to_use: 'M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM15.5 8.5l-2 5-5 2 2-5z',
  how_to_collaborate: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M17 11a3 3 0 1 0 0-6M17 14a6 6 0 0 1 4 6',
  signin: 'M10 17l5-5-5-5M15 12H3M14 3h5a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-5',
  continue: 'M7 4l12 8-12 8z',
  books: 'M4 19V5a2 2 0 0 1 2-2h13v14H6a2 2 0 0 0-2 2zm0 0a2 2 0 0 0 2 2h13M9 7h6',
};
export const navIcon = name => `<span class="start-icon" aria-hidden="true"><svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="${NAV_PATHS[name]}"/></svg></span>`;
export const CHEVRON = '<span class="start-chevron" aria-hidden="true">&rsaquo;</span>';

// One tile: icon, English in bold on the left, Urdu in Nastaliq on the right (when there is one), arrow.
export function homeTileHtml(attrs, icon, english, urdu, extraClass = '') {
  return `
    <button type="button" class="home-tile${extraClass ? ' ' + extraClass : ''}" ${attrs}>
      ${navIcon(icon)}
      <span class="home-tile-en">${esc(english)}</span>
      ${urdu ? `<span class="home-tile-ur" dir="rtl" lang="ur">${esc(urdu)}</span>` : ''}
      ${CHEVRON}
    </button>`;
}

function monthName(month) {
  const [year, mon] = month.split('-').map(Number);
  return new Date(year, mon - 1, 1).toLocaleDateString('en', { month: 'long', year: 'numeric' });
}
const thisMonth = () => { const d = new Date(); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`; };

// The Word of Life tile, on Home and on the landing page. attrs: what the page uses to find it.
export function wordTileHtml(w, attrs) {
  const current = w.month === thisMonth();
  const urTitle = w.ur_title || w.original_title || w.title;
  const enTitle = w.en_title && w.en_title !== urTitle ? w.en_title : '';
  return `
    <button type="button" class="home-tile home-word" ${attrs}>
      ${navIcon('word')}
      <span class="home-word-text">
        <span class="home-word-row">
          <span class="home-tile-en">${current ? 'Word of Life of this month' : 'Latest Word of Life'}</span>
          ${current ? `<span class="home-tile-ur" dir="rtl" lang="ur">${esc(WORD_OF_MONTH_UR)}</span>` : ''}
        </span>
        <span class="home-word-ur" dir="rtl" lang="ur">${esc(urTitle)}</span>
        ${enTitle ? `<span class="home-word-en" dir="auto">${esc(enTitle)}</span>` : ''}
        <span class="hint">${esc(monthName(w.month))}</span>
      </span>
      ${CHEVRON}
    </button>`;
}

// The last document opened on this device, kept by docdetail.js (rememberLastDocument).
function lastDocument() {
  try { const d = JSON.parse(localStorage.getItem('lastDocument') || 'null'); return d && d.id ? d : null; } catch { return null; }
}

// A "Continue" tile: what to continue in bold, then its title.
function continueTileHtml(attrs, what, title) {
  return `
    <button type="button" class="home-tile home-continue" ${attrs}>
      ${navIcon('continue')}
      <span class="home-word-text">
        <span class="home-tile-en">${esc(what)}</span>
        <span class="home-continue-title" dir="auto">${esc(title)}</span>
      </span>
      ${CHEVRON}
    </button>`;
}

export function renderOnboardingView(main) {
  main.innerHTML = `
    <div class="start-home">
      ${State.paused ? '<p class="panel home-paused">Your work in DUA is paused at the moment. You can read as before, and write to us in Share with us.</p>' : ''}
      <div id="home-top" class="start-tiles" style="margin-bottom:10px;"></div>
      <div class="start-tiles">
        ${HOME_TILES.filter(([tab]) => tab !== 'jointeam' || (State.currentRole === 'user' && !State.paused)).map(([tab, en, ur]) => homeTileHtml(`data-start-tab="${tab}"`, tab, en, ur)).join('')}
        ${State.currentRole !== 'user' ? `<button type="button" class="home-tile home-work" data-start-tab="work">${navIcon('work')}<span class="home-word-text"><span class="home-tile-en">My work</span><span class="hint" id="home-work-note"></span></span>${CHEVRON}</button>` : ''}
      </div>
    </div>`;
  main.querySelectorAll('[data-start-tab]').forEach(b => b.addEventListener('click', () => window.__renderTab(b.dataset.startTab, b.dataset.startTab === 'work' ? 'work' : 'home')));
  const note = main.querySelector('#home-work-note');
  if (note && State.workCount !== undefined) note.textContent = State.workCount ? `${State.workCount} thing${State.workCount === 1 ? ' is' : 's are'} waiting` : 'Nothing is waiting';
  fillHomeTop(main);
}

// The top of Home: the Word of Life, then what this person can continue. Each part on its own: Home works without them.
async function fillHomeTop(main) {
  const top = main.querySelector('#home-top');
  const [word, bookmark, bookMark] = await Promise.all([
    sb.rpc('public_word_of_life').then(r => (r.data && r.data[0]) || null, () => null),
    sb.from('formation_bookmarks').select('path_id,updated_at,formation_paths(title)').order('updated_at', { ascending: false }).limit(1)
      .then(r => (r.data && r.data[0]) || null, () => null),
    lastBookBookmark().catch(() => null),
  ]);
  if (!top || !document.body.contains(top)) return;
  const last = lastDocument();
  top.innerHTML = [
    word && word.body ? wordTileHtml(word, 'data-home-word') : '',
    last ? continueTileHtml('data-home-last-doc', 'Continue reading', last.title || `Document #${last.id}`) : '',
    bookmark && bookmark.formation_paths ? continueTileHtml('data-home-path', 'Continue your formation path', bookmark.formation_paths.title || '') : '',
    bookMark ? continueTileHtml('data-home-book', 'Continue the book', bookMark.book.title) : '',
  ].join('');
  if (!top.innerHTML.trim()) { top.remove(); return; }
  top.querySelector('[data-home-word]')?.addEventListener('click', () =>
    openReadingView({ en_title: word.en_title || '', ur_title: word.ur_title || word.original_title || '', language: word.language }, { body: word.body }));
  top.querySelector('[data-home-last-doc]')?.addEventListener('click', () => {
    State.selectedDocId = last.id;
    State.dashOpenDetail = true;
    window.__renderTab('dashboard');
  });
  top.querySelector('[data-home-book]')?.addEventListener('click', () => {
    State.bookOpen = { code: bookMark.book.code, key: bookMark.key };
    window.__renderTab('books');
  });
  top.querySelector('[data-home-path]')?.addEventListener('click', () => {
    State.formationSelectedPathId = bookmark.path_id;
    window.__renderTab('formation');
  });
}
