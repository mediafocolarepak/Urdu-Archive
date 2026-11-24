// The landing page, shown before signing in (Owner's request, 2026-11-18, migration 149): what Start Here was - the
// Word of Life of the month, the three sections of cards ("This is your home", "How to use it", "How to collaborate")
// - and Sign in. Whoever has not signed in reads them through public_word_of_life() and public_start_cards() only.
// The Word of Life tile opens the large-print reading view of its Urdu text. Cards are written by the Communication
// department (My Department -> Communication); a card that points into the app ("tab:<id>") is shown without a link
// here, since the app needs signing in.

import { sb, esc, ONBOARDING_MEDIA_BUCKET, showSignIn } from './core.js?v=20261124162602';
import { openReadingView } from './docdetail.js?v=20261124162602';
import { homeTileHtml, wordTileHtml } from './onboarding.js?v=20261124162602';

const SECTIONS = [
  ['about', 'یہ آپ کا گھر ہے', 'This is your home'],
  ['how_to_use', 'اسے کیسے استعمال کریں؟', 'How to use it'],
  ['how_to_collaborate', 'تعاون کیسے کریں؟', 'How to collaborate'],
];

const view = { box: null, word: null, cards: [], page: null, scroll: 0 };
const thumbnailUrl = path => path ? sb.storage.from(ONBOARDING_MEDIA_BUCKET).getPublicUrl(path).data.publicUrl : null;


function cardHtml(c) {
  const url = thumbnailUrl(c.thumbnail_path);
  const outside = c.media_type === 'video' && c.media_url && !c.media_url.startsWith('tab:');
  return `
    <div class="panel" style="padding:0;overflow:hidden;display:flex;flex-direction:column;">
      ${url ? `<div style="width:100%;aspect-ratio:16/9;overflow:hidden;background:#eee;"><img src="${esc(url)}" alt="" style="width:100%;height:100%;object-fit:cover;display:block;"></div>` : ''}
      <div style="padding:12px;flex:1;display:flex;flex-direction:column;gap:2px;">
        <div style="font-weight:600;" dir="auto">${esc(c.title_ur)}</div>
        ${c.body_ur ? `<div style="margin-top:6px;white-space:pre-wrap;" dir="auto">${esc(c.body_ur)}</div>` : ''}
        ${c.title_en ? `<div class="hint" style="font-weight:600;margin-top:10px;">${esc(c.title_en)}</div>` : ''}
        ${c.body_en ? `<div class="hint" style="margin-top:2px;white-space:pre-wrap;">${esc(c.body_en)}</div>` : ''}
        ${outside ? `<div style="margin-top:8px;"><a href="${esc(c.media_url)}" target="_blank" rel="noopener">&#9654; Watch video</a></div>` : ''}
      </div>
    </div>`;
}

function renderHome() {
  const box = view.box;
  const sections = SECTIONS.filter(([code]) => view.cards.some(c => c.section === code));
  box.innerHTML = `
    <div class="start-home landing-home">
      <h1 class="landing-title">Digital Urdu Archive</h1>
      <div id="landing-word">${view.word ? wordTileHtml(view.word, 'data-landing-word') : ''}</div>
      <div class="start-tiles">
        ${sections.map(([code, ur, en]) => homeTileHtml(`data-landing-page="${code}"`, code, en, ur)).join('')}
        ${homeTileHtml('data-landing-signin', 'signin', 'Sign in', '', 'home-signin')}
      </div>
    </div>`;
  wireHome();
  window.scrollTo(0, view.scroll);
}

function wireHome() {
  const box = view.box;
  box.querySelector('[data-landing-word]')?.addEventListener('click', openWord);
  box.querySelectorAll('[data-landing-page]').forEach(b => b.addEventListener('click', () => openPage(b.dataset.landingPage)));
  box.querySelector('[data-landing-signin]').addEventListener('click', () => showSignIn());
}

function openPage(code) {
  view.scroll = window.scrollY;
  view.page = code;
  history.pushState({ landingPage: code }, '');
  renderPage();
}

function renderPage() {
  const section = SECTIONS.find(([code]) => code === view.page);
  if (!section) { view.page = null; renderHome(); return; }
  const [code, ur, en] = section;
  view.box.innerHTML = `
    <div class="start-home landing-home">
      <div class="btn-row start-back-row"><button type="button" class="btn secondary back-btn" id="landing-back">&lsaquo; Back</button></div>
      <div class="panel">
        <h2 class="start-page-ur" dir="auto">${esc(ur)}</h2>
        <h2 class="start-page-en">${esc(en)}</h2>
        <div class="field-grid wide">${view.cards.filter(c => c.section === code).map(cardHtml).join('')}</div>
      </div>
    </div>`;
  document.getElementById('landing-back').addEventListener('click', () => {
    if (history.state && history.state.landingPage) history.back(); else { view.page = null; renderHome(); }
  });
  window.scrollTo(0, 0);
}

// The large-print reading view of the Urdu text. The phone's Back closes it, as ✕ does.
function openWord() {
  const w = view.word;
  if (!w) return;
  openReadingView({ en_title: w.en_title || '', ur_title: w.ur_title || w.original_title || '', language: w.language }, { body: w.body });
  history.pushState({ landingRead: true }, '');
  document.getElementById('rv-close')?.addEventListener('click', () => {
    if (history.state && history.state.landingRead) history.back();
  });
}

window.addEventListener('popstate', e => {
  if (!view.box || view.box.style.display === 'none') return;
  document.getElementById('reading-view')?.remove();
  const page = e.state && e.state.landingPage;
  if (page) { view.page = page; renderPage(); } else if (view.page) { view.page = null; renderHome(); }
});

export async function renderLanding(box) {
  view.box = box;
  view.page = null;
  view.scroll = 0;
  if (!view.cards.length && !view.word) box.innerHTML = '<div class="empty-msg">Loading...</div>';
  // Each part on its own: the page works with what it can load, and Sign in is always there.
  const [cards, word] = await Promise.all([
    sb.rpc('public_start_cards').then(r => r.data || [], () => []),
    sb.rpc('public_word_of_life').then(r => (r.data && r.data[0]) || null, () => null),
  ]);
  view.cards = cards;
  view.word = word && word.body ? word : null;
  renderHome();
}
