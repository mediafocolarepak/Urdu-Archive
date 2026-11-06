// "Help" tab, redesigned 2026-11-06 with the Owner: guides are organised by what a person wants to do,
// not by role, and each person sees only the guides for what they can do. Content lives in help_pages
// (one row per guide and language, 116_help_redesign.sql). The list loads titles only; a guide's text is
// fetched when it is opened. Users have no Help tab (Start Here stands in for it, GOVERNANCE 5.8): they
// reach this view from the Guides button of Start Here. Admin can edit a guide in place.
//
// audience tokens (help_pages.audience, any match shows the guide; Admin sees everything):
//   user | operator | coordinator   the role or anything above it
//   lead                            leads any department
//   dept:*  dept:<CODE>             member of any department, or of that one
//   qual:<CODE>                     holds that qualification
//   board_editor                    looks after at least one board

import { sb, State, esc, isAdmin, withStatus } from './core.js?v=20261106192514';

const SECTIONS = [
  ['use', { en: 'Use the archive', it: 'Usare l\'archivio', ur: 'آرکائیو کا استعمال' }],
  ['add', { en: 'Add to the archive', it: 'Aggiungere all\'archivio', ur: 'آرکائیو میں اضافہ' }],
  ['work', { en: 'Work with the team', it: 'Lavorare con il team', ur: 'ٹیم کے ساتھ کام' }],
  ['check', { en: 'Check others\' work', it: 'Controllare il lavoro altrui', ur: 'دوسروں کے کام کا جائزہ' }],
  ['role', { en: 'Your role', it: 'Il tuo ruolo', ur: 'آپ کا کردار' }],
  ['dept', { en: 'Department pages', it: 'Le pagine dei reparti', ur: 'شعبوں کے صفحات' }],
  ['run', { en: 'Run the project', it: 'Gestire il progetto', ur: 'منصوبے کا انتظام' }],
  ['ref', { en: 'Reference', it: 'Riferimento', ur: 'حوالہ' }],
];
const LANG_LABELS = { en: 'EN', it: 'IT', ur: 'اردو' };
const byLangOrder = (a, b) => Object.keys(LANG_LABELS).indexOf(a) - Object.keys(LANG_LABELS).indexOf(b);
const UI = {
  en: { help: 'Help', guides: 'Guides', edit: 'Edit', cancel: 'Cancel', save: 'Save', title: 'Title', summary: 'One line for the list', updated: 'Last updated', by: 'by', empty: 'No guides here yet.', failed: 'The guides could not be loaded. Check your connection and try again.', missing: 'This guide is not available.' },
  ur: { help: 'مدد', guides: 'رہنمائی', edit: 'Edit', cancel: 'Cancel', save: 'Save', title: 'Title', summary: 'One line for the list', updated: 'Last updated', by: 'by', empty: 'ابھی کوئی رہنمائی نہیں۔', failed: 'رہنمائی لوڈ نہیں ہو سکی۔ کنکشن دیکھ کر دوبارہ کوشش کریں۔', missing: 'یہ رہنمائی دستیاب نہیں۔' },
  it: { help: 'Help', guides: 'Guide', edit: 'Modifica', cancel: 'Annulla', save: 'Salva', title: 'Titolo', summary: 'Una riga per l\'elenco', updated: 'Ultimo aggiornamento', by: 'di', empty: 'Ancora nessuna guida.', failed: 'Non è stato possibile caricare le guide. Controlla la connessione e riprova.', missing: 'Questa guida non è disponibile.' },
};
const ui = () => UI[helpView.lang] || UI.en;

const LIST_FIELDS = 'slug,guide_key,language,title,summary,section,audience,sort_order,draft';
let listCache = null;
let myQualsCache = null;
const bodyCache = new Map();
const helpView = { key: null, editing: false, lang: readLang(), listScroll: 0, depth: 0, returnTab: null, fromStart: false };

// Remembered per browser; the page works the same if storage is unavailable.
function readLang() { try { return localStorage.getItem('helpLang'); } catch { return null; } }
function saveLang(lang) { try { localStorage.setItem('helpLang', lang); } catch { /* not needed to work */ } }

async function myQualifications() {
  if (myQualsCache) return myQualsCache;
  const { data: { user } } = await sb.auth.getUser();
  const { data } = await sb.from('user_qualifications').select('qualification_code').eq('user_id', user.id);
  myQualsCache = new Set((data || []).map(q => q.qualification_code));
  return myQualsCache;
}

function matchesAudience(audience, quals) {
  if (isAdmin()) return true;
  const rank = { user: 1, operator: 2, coordinator: 3, admin: 4 }[State.currentRole] || 1;
  return (audience || []).some(t => {
    if (t === 'user') return true;
    if (t === 'operator') return rank >= 2;
    if (t === 'coordinator') return rank >= 3;
    if (t === 'lead') return State.myDepartments.some(d => d.is_lead);
    if (t === 'board_editor') return State.myBoards.size > 0;
    if (t === 'dept:*') return State.myDepartments.length > 0;
    if (t.startsWith('dept:')) return State.myDepartments.some(d => d.department_code === t.slice(5));
    if (t.startsWith('qual:')) return quals.has(t.slice(5));
    return false;
  });
}

async function loadGuides() {
  if (listCache) return listCache;
  const { data, error } = await sb.from('help_pages').select(LIST_FIELDS).not('guide_key', 'is', null).order('sort_order');
  if (error) throw error;
  // A draft (the Urdu, until reviewed) is seen only by Admins; everyone else gets the guide in another language.
  listCache = (data || []).filter(r => !r.draft || isAdmin());
  return listCache;
}

// One row per guide, in the reader's language if it exists, otherwise in another one.
function rowFor(rows, key, lang) {
  const ofGuide = rows.filter(r => r.guide_key === key);
  return ofGuide.find(r => r.language === lang) || ofGuide.find(r => r.language === 'en') || ofGuide[0] || null;
}

function langSwitchHtml(languages) {
  if (languages.length < 2) return '';
  return `<div class="help-lang" role="group" aria-label="Language">${[...languages].sort(byLangOrder).map(l =>
    `<button type="button" class="btn ${l === helpView.lang ? '' : 'secondary'}" data-help-lang="${esc(l)}" aria-pressed="${l === helpView.lang}">${esc(LANG_LABELS[l] || l)}</button>`).join('')}</div>`;
}

function wireLangSwitch(main) {
  main.querySelectorAll('[data-help-lang]').forEach(b => b.addEventListener('click', () => {
    helpView.lang = b.dataset.helpLang;
    saveLang(helpView.lang);
    renderUserGuideView(main);
  }));
}

export async function renderUserGuideView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  let rows, quals;
  try {
    [rows, quals] = await Promise.all([loadGuides(), myQualifications()]);
  } catch (err) {
    console.error('Help:', err);
    main.innerHTML = `<div class="panel"><h2>${esc(ui().help)}</h2><div class="empty-msg">${esc(ui().failed)}</div></div>`;
    return;
  }
  if (!helpView.lang) helpView.lang = State.currentRole === 'user' && rows.some(r => r.language === 'ur') ? 'ur' : 'en';
  if (helpView.key) await renderGuide(main, rows);
  else renderList(main, rows, quals);
}

function renderList(main, rows, quals) {
  const visible = rows.filter(r => matchesAudience(r.audience, quals));
  const languages = [...new Set(rows.map(r => r.language))];
  const keys = [...new Set(visible.map(r => r.guide_key))];
  const shown = keys.map(k => rowFor(visible, k, helpView.lang));
  const groups = SECTIONS.map(([code, names]) => {
    const inSection = shown.filter(r => r.section === code).sort((a, b) => a.sort_order - b.sort_order);
    if (!inSection.length) return '';
    return `
      <h3 class="help-section">${esc(names[helpView.lang] || names.en)}</h3>
      <div class="help-list">${inSection.map(r => `
        <button type="button" class="help-row" data-help-open="${esc(r.guide_key)}" ${r.language === 'ur' ? 'dir="rtl"' : ''}>
          <span class="help-row-title">${esc(r.title)}${r.draft ? ' <span class="count-badge">draft</span>' : ''}</span>
          ${r.summary ? `<span class="help-row-summary">${esc(r.summary)}</span>` : ''}
        </button>`).join('')}</div>`;
  }).join('');
  main.innerHTML = `
    <div class="panel help-panel">
      ${State.currentRole === 'user' ? '<div class="btn-row start-back-row"><button type="button" class="btn secondary" id="help-to-start">&larr; Start Here</button></div>' : ''}
      <div class="help-head"><h2>${esc(ui().help)}</h2>${langSwitchHtml(languages)}</div>
      ${groups || `<div class="empty-msg">${esc(ui().empty)}</div>`}
    </div>`;
  wireLangSwitch(main);
  document.getElementById('help-to-start')?.addEventListener('click', () => {
    if (history.state && history.state.helpHome) { history.back(); return; }
    window.__renderTab('onboarding');
  });
  main.querySelectorAll('[data-help-open]').forEach(b => b.addEventListener('click', () => openGuide(b.dataset.helpOpen)));
  document.getElementById('main').scrollTop = helpView.listScroll;
}

// Guides are written by Admin but shown inside the app itself rather than in a frame, so that the page
// has one scroll and the app's own light, dark and font settings. Anything that could run code goes.
function cleanGuideHtml(raw) {
  const doc = new DOMParser().parseFromString(raw || '', 'text/html');
  doc.querySelectorAll('script,style,iframe,object,embed,link,meta,base,form').forEach(n => n.remove());
  doc.querySelectorAll('*').forEach(n => {
    for (const a of [...n.attributes]) {
      if (/^on/i.test(a.name) || (/^(href|src)$/i.test(a.name) && /^\s*(javascript|data):/i.test(a.value))) n.removeAttribute(a.name);
    }
    if (n.tagName === 'A' && /^https?:/i.test(n.getAttribute('href') || '')) { n.setAttribute('target', '_blank'); n.setAttribute('rel', 'noopener'); }
  });
  return doc.body.innerHTML;
}

async function renderGuide(main, rows) {
  const row = rowFor(rows, helpView.key, helpView.lang);
  if (!row) {
    main.innerHTML = `<div class="panel help-panel"><button class="btn secondary" id="help-back" type="button">&larr; ${esc(ui().guides)}</button><div class="empty-msg">${esc(ui().missing)}</div></div>`;
    document.getElementById('help-back').addEventListener('click', goBackToList);
    return;
  }
  const languages = rows.filter(r => r.guide_key === helpView.key).map(r => r.language);
  let body = bodyCache.get(row.slug);
  if (!body) {
    const found = await withStatus(sb.from('help_pages').select('html_content,updated_at,updated_by_email').eq('slug', row.slug));
    body = found[0] || { html_content: '' };
    bodyCache.set(row.slug, body);
  }
  const updated = body.updated_at ? new Date(body.updated_at).toLocaleDateString() : '';
  const rtl = row.language === 'ur' ? 'dir="rtl"' : '';
  main.innerHTML = `
    <div class="panel help-panel">
      <div class="help-head">
        <button class="btn secondary" id="help-back" type="button">&larr; ${esc(ui().guides)}</button>
        ${langSwitchHtml(languages)}
      </div>
      ${helpView.editing ? `
        <div class="field"><label>${esc(ui().title)}</label><input id="help-edit-title" value="${esc(row.title)}"></div>
        <div class="field"><label>${esc(ui().summary)}</label><input id="help-edit-summary" value="${esc(row.summary || '')}"></div>
        <textarea id="help-editor" spellcheck="false" class="help-editor">${esc(body.html_content)}</textarea>
      ` : `
        <article class="help-guide" ${rtl}>
          ${row.draft ? '<p class="note" dir="ltr">Draft: only Admins see this until it is reviewed.</p>' : ''}
          <h1>${esc(row.title)}</h1>
          ${cleanGuideHtml(body.html_content)}
        </article>
      `}
      ${isAdmin() ? `
        <div class="btn-row" style="margin-top:16px;">
          <button class="btn secondary" id="help-edit-toggle" type="button">${esc(helpView.editing ? ui().cancel : ui().edit)}</button>
          ${helpView.editing ? `<button class="btn" id="help-save" type="button">${esc(ui().save)}</button>` : ''}
        </div>
        ${updated ? `<p class="hint">${esc(ui().updated)}: ${esc(updated)}${body.updated_by_email ? ` ${esc(ui().by)} ${esc(body.updated_by_email)}` : ''}</p>` : ''}` : ''}
    </div>`;
  wireLangSwitch(main);
  document.getElementById('help-back').addEventListener('click', goBackToList);
  document.getElementById('main').scrollTop = 0;
  if (!isAdmin()) return;
  document.getElementById('help-edit-toggle').addEventListener('click', () => { helpView.editing = !helpView.editing; renderUserGuideView(main); });
  document.getElementById('help-save')?.addEventListener('click', async () => {
    const html_content = document.getElementById('help-editor').value;
    const title = document.getElementById('help-edit-title').value.trim();
    const summary = document.getElementById('help-edit-summary').value.trim() || null;
    if (!title) { alert('A title is required.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    const updated_at = new Date().toISOString();
    try {
      await withStatus(sb.from('help_pages').update({ html_content, title, summary, updated_at, updated_by_email: user.email }).eq('slug', row.slug), 'Saving...');
    } catch (err) { alert('Save failed: ' + err.message); return; }
    Object.assign(row, { title, summary });
    bodyCache.set(row.slug, { html_content, updated_at, updated_by_email: user.email });
    helpView.editing = false;
    renderUserGuideView(main);
  });
}

// The phone's Back goes to the previous guide, then to where the person came from (the list, or the screen
// whose "?" opened the guide), as it closes a document in the Library. The "Guides" button always goes to the list.
function openGuide(key) {
  const main = document.getElementById('main');
  if (!helpView.key) {
    helpView.depth = 0;
    helpView.returnTab = main.dataset.section === 'help' ? null : main.dataset.section;
    if (!helpView.returnTab) helpView.listScroll = main.scrollTop;
  }
  helpView.key = key;
  helpView.editing = false;
  helpView.depth += 1;
  history.pushState({ helpGuide: key }, '');
  window.__renderTab('help');
}
function goBackToList() {
  const steps = helpView.depth;
  helpView.returnTab = null;
  helpView.depth = 0;
  if (steps > 0) { history.go(-steps); return; }
  closeGuide();
}
function closeGuide() {
  const back = helpView.returnTab;
  helpView.key = null;
  helpView.editing = false;
  helpView.returnTab = null;
  helpView.depth = 0;
  const main = document.getElementById('main');
  if (main.dataset.section !== 'help') return;
  if (back) window.__renderTab(back);
  else renderUserGuideView(main);
}
window.addEventListener('popstate', e => {
  if (!helpView.key) {
    // Back from the list of guides returns to Start Here, for those who came from there.
    if (helpView.fromStart && !(e.state && e.state.helpHome)) {
      helpView.fromStart = false;
      if (document.getElementById('main').dataset.section === 'help') window.__renderTab('onboarding');
    }
    return;
  }
  const previous = e.state && e.state.helpGuide;
  if (!previous) { closeGuide(); return; }
  helpView.key = previous;
  helpView.editing = false;
  helpView.depth = Math.max(0, helpView.depth - 1);
  const main = document.getElementById('main');
  if (main.dataset.section === 'help') renderUserGuideView(main);
});

// Links work from anywhere: inside a guide (data-tab, data-help-guide), from the "?" beside a screen's
// title (helpLinkHtml in core.js), and from the Guides button of Start Here (data-help-home).
document.addEventListener('click', e => {
  const guide = e.target.closest('[data-help-guide]');
  if (guide) { e.preventDefault(); openGuide(guide.dataset.helpGuide); return; }
  const home = e.target.closest('[data-help-home]');
  if (home) {
    e.preventDefault();
    helpView.key = null;
    helpView.listScroll = 0;
    helpView.fromStart = true;
    history.pushState({ helpHome: true }, '');
    window.__renderTab('help');
    return;
  }
  const tab = e.target.closest('.help-guide [data-tab]');
  if (tab) { e.preventDefault(); helpView.key = null; window.__renderTab(tab.dataset.tab); }
});
