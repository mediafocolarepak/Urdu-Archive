// "Home": the first tab of a User (Owner's request, 2026-11-18). It replaced "Start Here" (95_onboarding_and_share_
// with_us.sql, redesigned 2026-11-06), whose Word of Life and three sections of cards moved to the landing page shown
// before signing in (landing.js). Home is a short set of large tiles to the sections of the app: in each, the English
// in bold on the left and the Urdu in Nastaliq on the right (Owner's layout).

import { esc } from './core.js?v=20261123145620';

// The Urdu names are the ones of the Urdu guides (Documentazione/guide-help/ur1.mjs, ur2.mjs, migration 119): Boards,
// Formation Paths and Help have one there; the others are named in Latin letters there too, so they stand alone
// until the Owner gives a word. Never invented (memory: Urdu wording is the Owner's).
const HOME_TILES = [
  // The Library first (Owner's request, 2026-11-18). The Urdu guides call it "Library" in Latin letters too.
  ['dashboard', 'Library', ''],
  ['myspace', 'My Space', ''],
  ['boards', 'Boards', 'بورڈز'],
  ['formation', 'Formation Paths', 'تربیتی راستے'],
  ['sharewithus', 'Share with us', ''],
  ['jointeam', 'Join the Team', ''],
  ['profile', 'My Profile', ''],
];
const HELP_UR = 'مدد';

const NAV_PATHS = {
  dashboard: 'M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM4 17a3 3 0 0 1 3-3h12',
  myspace: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21a8 8 0 0 1 16 0',
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

export function renderOnboardingView(main) {
  main.innerHTML = `
    <div class="start-home">
      <div class="start-tiles">
        ${HOME_TILES.map(([tab, en, ur]) => homeTileHtml(`data-start-tab="${tab}"`, tab, en, ur)).join('')}
        ${homeTileHtml('data-help-home', 'help', 'Help', HELP_UR)}
      </div>
    </div>`;
  main.querySelectorAll('[data-start-tab]').forEach(b => b.addEventListener('click', () => window.__renderTab(b.dataset.startTab)));
}
