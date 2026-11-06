// "Start Here" (95_onboarding_and_share_with_us.sql, PROJECT_HANDOFF for this session): replaces
// the technical Help tab for Users only - a first-run orientation hub, not a reference manual.
// Three sections (what this is / how to use it / how to collaborate), filled with bilingual cards
// (Urdu title/body + an optional English gloss) authored by the Communication department through
// its own editor in My Department -> Communication (see renderOnboardingCardsManager in
// mydepartment.js) - this module only ever reads onboarding_cards, never writes it.

import { sb, State, esc, withStatus, ONBOARDING_MEDIA_BUCKET, HIDDEN_DOC_STATUSES, videoLinkHtml, mountAudioPlayer } from './core.js?v=20261106165033';

const thumbnailUrl = path => path ? sb.storage.from(ONBOARDING_MEDIA_BUCKET).getPublicUrl(path).data.publicUrl : null;

const SECTIONS = [
  ['about', 'یہ آپ کا گھر ہے', 'This is your home'],
  ['how_to_use', 'اسے کیسے استعمال کریں؟', 'How to use it'],
  ['how_to_collaborate', 'تعاون کیسے کریں؟', 'How to collaborate'],
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
        ${c.body_ur ? `<div style="margin-top:6px;white-space:pre-wrap;" dir="auto">${esc(c.body_ur)}</div>` : ''}
        ${c.title_en ? `<div class="hint" style="font-weight:600;margin-top:10px;">${esc(c.title_en)}</div>` : ''}
        ${c.body_en ? `<div class="hint" style="margin-top:2px;white-space:pre-wrap;">${esc(c.body_en)}</div>` : ''}
        ${c.media_type === 'video' && c.media_url && !internalTab ? `<div style="margin-top:8px;"><a href="${esc(c.media_url)}" target="_blank" rel="noopener">&#9654; Watch video</a></div>` : ''}
      </div>
    </div>`;
}

// ---------- The Word of Life of the month ----------
// One tap, for those who cannot look for it by typing (PROTOCOLLO §9). It is found by category and by
// its own month; with no Word of Life for this month yet, the latest one is shown, with its month.
// The Urdu heading is the Owner's wording: until it is here, the English one stands alone.
const WORD_OF_MONTH_HEADING_UR = '';
const WOM_FIELDS = 'document_id,work_id,title,en_title,ur_title,original_title,language,media_type,ref_period,external_url,workflow_status,is_preferred';

async function findWordOfMonth() {
  const codes = State.categories.filter(([, label]) => /word of life/i.test(label)).map(([code]) => code);
  if (!codes.length) return null;
  const now = new Date();
  const next = new Date(now.getFullYear(), now.getMonth() + 1, 1);
  const before = `${next.getFullYear()}-${String(next.getMonth() + 1).padStart(2, '0')}`;
  const rows = (await withStatus(sb.from('documents').select(WOM_FIELDS).in('category', codes)
    .gte('ref_period', '1900').lt('ref_period', before).order('ref_period', { ascending: false }).limit(40)))
    .filter(d => /^\d{4}-\d{2}/.test(d.ref_period) && !HIDDEN_DOC_STATUSES.includes(d.workflow_status));
  if (!rows.length) return null;
  const month = rows[0].ref_period.slice(0, 7);
  const sameMonth = rows.filter(d => d.ref_period.startsWith(month));
  const urduFirst = (a, b) => (b.language === 'URD') - (a.language === 'URD') || !!b.is_preferred - !!a.is_preferred;
  const written = sameMonth.filter(d => !['AUD', 'VID'].includes(d.media_type)).sort(urduFirst);
  const doc = written[0] || sameMonth[0];
  const fromWork = doc.work_id ? await withStatus(sb.from('documents').select(WOM_FIELDS).eq('work_id', doc.work_id).in('media_type', ['AUD', 'VID'])) : [];
  const media = [...new Map([...sameMonth, ...fromWork].map(d => [d.document_id, d])).values()]
    .filter(d => !HIDDEN_DOC_STATUSES.includes(d.workflow_status)).sort(urduFirst);
  const video = media.find(d => d.media_type === 'VID' && d.external_url);
  const audioDoc = media.find(d => d.media_type === 'AUD');
  const reading = audioDoc ? (await withStatus(sb.from('audio_readings').select('document_id,path,reader_name').eq('document_id', audioDoc.document_id)))[0] : null;
  return { doc, month, isCurrent: month === `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`, video, reading: reading && reading.path ? reading : null };
}

function wordOfMonthHtml(w) {
  const [year, mon] = w.month.split('-').map(Number);
  const monthName = new Date(year, mon - 1, 1).toLocaleDateString('en', { month: 'long', year: 'numeric' });
  const title = w.doc.ur_title || w.doc.original_title || w.doc.en_title || w.doc.title;
  return `
    <div class="panel" id="wom-card">
      ${WORD_OF_MONTH_HEADING_UR ? `<h2 style="margin:0 0 4px;font-size:24px;line-height:1.3;text-align:left;" dir="auto">${esc(WORD_OF_MONTH_HEADING_UR)}</h2>` : ''}
      <h2 style="margin:0 0 8px;font-size:24px;line-height:1.3;">${w.isCurrent ? 'Word of Life of this month' : 'Latest Word of Life'}</h2>
      <div style="font-weight:600;font-size:18px;line-height:1.7;" dir="auto">${esc(title)}</div>
      <div class="hint">${w.doc.en_title && w.doc.en_title !== title ? `${esc(w.doc.en_title)} &middot; ` : ''}${esc(monthName)}</div>
      <div class="btn-row">
        <button class="btn" id="wom-read">Read</button>
        ${w.reading ? '<button class="btn" id="wom-listen">&#128266; Listen</button>' : ''}
        ${w.video ? videoLinkHtml(w.video.external_url, 'Watch video') : ''}
      </div>
      <div id="wom-player"></div>
    </div>`;
}

// Start Here stays usable if this cannot be found: it simply has no such card.
async function renderWordOfMonth(box) {
  let w = null;
  try { w = await findWordOfMonth(); } catch (e) { console.error('Word of the month:', e); }
  if (!w || !box.isConnected) return;
  box.innerHTML = wordOfMonthHtml(w);
  document.getElementById('wom-read').addEventListener('click', () => {
    State.selectedDocId = w.doc.document_id;
    State.dashOpenDetail = true;
    window.__renderTab('dashboard');
  });
  document.getElementById('wom-listen')?.addEventListener('click', () => mountAudioPlayer(document.getElementById('wom-player'), w.reading, true));
}

export async function renderOnboardingView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  const cards = await withStatus(sb.from('onboarding_cards').select('*').eq('published', true).order('sort_order').order('created_at'));

  main.innerHTML = '<div id="wom-box"></div>' + SECTIONS.map(([code, headingUr, headingEn]) => {
    const inSection = cards.filter(c => c.section === code);
    if (!inSection.length) return '';
    return `
      <div class="panel">
        <h2 style="margin:0 0 4px;font-size:24px;line-height:1.3;text-align:left;" dir="auto">${esc(headingUr)}</h2>
        <h2 style="margin:0 0 12px;font-size:24px;line-height:1.3;">${esc(headingEn)}</h2>
        <div class="field-grid wide">${inSection.map(renderCard).join('')}</div>
      </div>`;
  }).join('') || '<div class="empty-msg">Nothing here yet - check back soon.</div>';

  // Users have no Help tab: this is their way to the guides meant for them (userguide.js). English until the Owner gives the Urdu.
  main.insertAdjacentHTML('beforeend', '<div class="btn-row" style="justify-content:center;"><button type="button" class="btn secondary" data-help-home>Guides</button></div>');
  main.querySelectorAll('[data-open-tab]').forEach(el => el.addEventListener('click', () => window.__renderTab(el.dataset.openTab)));
  renderWordOfMonth(document.getElementById('wom-box'));
}
