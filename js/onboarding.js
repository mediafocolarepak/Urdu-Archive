// "Start Here" (95_onboarding_and_share_with_us.sql, PROJECT_HANDOFF for this session): replaces
// the technical Help tab for Users only - a first-run orientation hub, not a reference manual.
// Three sections (what this is / how to use it / how to collaborate), filled with bilingual cards
// (Urdu title/body + an optional English gloss) authored by the Communication department through
// its own editor in My Department -> Communication (see renderOnboardingCardsManager in
// mydepartment.js) - this module only ever reads onboarding_cards, never writes it.

import { sb, esc, withStatus, ONBOARDING_MEDIA_BUCKET } from './core.js?v=20260920114618';

const thumbnailUrl = path => path ? sb.storage.from(ONBOARDING_MEDIA_BUCKET).getPublicUrl(path).data.publicUrl : null;

const SECTIONS = [
  ['about', 'What is this?'],
  ['how_to_use', 'How to use it'],
  ['how_to_collaborate', 'How to collaborate'],
];

function cardCoverHtml(c) {
  const url = thumbnailUrl(c.thumbnail_path);
  if (url) return `<div style="width:100%;aspect-ratio:16/9;border-radius:8px 8px 0 0;overflow:hidden;background:#eee;"><img src="${esc(url)}" alt="" style="width:100%;height:100%;object-fit:cover;display:block;"></div>`;
  return '';
}

// media_url is either a normal external link (video/further reading, opened in a new tab) or, for
// a card whose whole job is to point somewhere else in the app (like the Share with us tutorial
// card), an internal reference "tab:<id>" navigated via the same window.__renderTab escape hatch
// docdetail.js/chat.js already use to jump tabs without a circular import between modules.
function renderCard(c) {
  const internalTab = c.media_url && c.media_url.startsWith('tab:') ? c.media_url.slice(4) : null;
  return `
    <div class="panel" style="padding:0;overflow:hidden;display:flex;flex-direction:column;${internalTab ? 'cursor:pointer;' : ''}" ${internalTab ? `data-open-tab="${esc(internalTab)}"` : ''}>
      ${cardCoverHtml(c)}
      <div style="padding:12px;flex:1;display:flex;flex-direction:column;gap:2px;">
        <div style="font-weight:600;" dir="auto">${esc(c.title_ur)}</div>
        ${c.title_en ? `<div class="hint">${esc(c.title_en)}</div>` : ''}
        ${c.body_ur ? `<div style="margin-top:6px;" dir="auto">${esc(c.body_ur)}</div>` : ''}
        ${c.body_en ? `<div class="hint" style="margin-top:2px;">${esc(c.body_en)}</div>` : ''}
        ${c.media_type === 'video' && c.media_url && !internalTab ? `<div style="margin-top:8px;"><a href="${esc(c.media_url)}" target="_blank" rel="noopener">&#9654; Watch video</a></div>` : ''}
      </div>
    </div>`;
}

export async function renderOnboardingView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  const cards = await withStatus(sb.from('onboarding_cards').select('*').eq('published', true).order('sort_order').order('created_at'));

  main.innerHTML = SECTIONS.map(([code, heading]) => {
    const inSection = cards.filter(c => c.section === code);
    if (!inSection.length) return '';
    return `
      <div class="panel">
        <h2>${esc(heading)}</h2>
        <div class="field-grid wide">${inSection.map(renderCard).join('')}</div>
      </div>`;
  }).join('') || '<div class="empty-msg">Nothing here yet - check back soon.</div>';

  main.querySelectorAll('[data-open-tab]').forEach(el => el.addEventListener('click', () => window.__renderTab(el.dataset.openTab)));
}
