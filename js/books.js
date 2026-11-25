// Books (Owner's request, 2026-11-24): the texts of one kind read as a book - in date order, with a cover, an index by
// year, a large reader that turns pages, and a bookmark, like the formation paths. "Automatic" books: no list is kept
// by hand; a new Link-up in the archive appears in its book by itself. The Link-ups come first; another kind becomes a
// book by adding a line to BOOKS. The bookmark is in book_bookmarks (162_book_bookmarks.sql): until 162 is run there
// is simply no bookmark, the rest works.
//
// A page is one Work: the Urdu text when there is one, otherwise the Italian; when both exist the reader can switch.
// The recordings of the Work can be heard on the page. Reserved and hidden texts never appear: the database decides
// what each person can read (row level security), and proposals and removed texts are left out here.

import { sb, State, esc, withStatus, HIDDEN_DOC_STATUSES, mountAudioPlayer, URDU_SCRIPT } from './core.js?v=20261125223139';

// A book: code (for its bookmark), category, title, the cover's author line, what a page is called, a line under the
// title. Optional: order 'title' (A to Z, with letters, for texts that seldom have a date; otherwise by date, with
// years), include (only the Works with a title like this), clean (what to take off the front of a title), cover (colour).
export const BOOKS = [
  { code: 'linkups', category: 'Lkp', title: 'Link-ups', author: 'Chiara Lubich', unit: ['Link-up', 'Link-ups'],
    about: 'Chiara’s Link-ups, one after the other, in the order she gave them.' },
  // 2026-11-24: most meditations have no date, so they are in alphabetical order.
  { code: 'meditations', category: 'Mdt', title: 'Meditations', author: 'Chiara Lubich', unit: ['meditation', 'meditations'],
    about: 'Chiara’s meditations, from A to Z: a page for each, to read slowly.', order: 'title', clean: /^Med\.?\s+/i, cover: 'green' },
  // 2026-11-24: from the Experiences, those of the first times and the stories of the first focolarini and focolarine
  // (the Owner's request); the recent experiences of Gen, families and volunteers stay out. A new story whose title
  // names one of them, or says story, profile, first times, comes in by itself.
  { code: 'early-stories', category: 'Exp', title: 'Stories of the early days', author: 'Focolarini and focolarine', unit: ['story', 'stories'],
    about: 'The experiences of the first times, and the stories of the first focolarini and focolarine, told by them.',
    include: /(stor(y|ies)|first times|profile|heavenly mariapolis|little flowers|telegram|protagonists)|\b(Dori|Ginetta|Foco|Igino|Fons|Palmira|Silvana|Vale|Virgo|Aletta|Marisa|Giosi|Danilo|Vera|Eli)\b/i,
    cover: 'red' },
  // 2026-11-24: one Word of Life a month. monthly: the pages are months, listed by year; verse: the verse at the top of
  // each text, between quotation marks, is shown large before the commentary.
  { code: 'word-of-life', category: 'Wol', title: 'Word of Life', author: 'Month by month', unit: ['Word of Life', 'Words of Life'],
    about: 'A Word of the Gospel for every month, with its commentary, to put into practice in daily life.',
    monthly: true, verse: true, cover: 'amber' },
];

const view = { book: null, items: [], index: 0, bookmarkKey: null, userId: null, main: null, lang: {}, loading: false };
const textCache = new Map();

// ---------- Reading the book from the archive ----------

// A full date ("3 September 1981"), a month ("April 2001") or a year ("1997"): many texts only have the year or month.
const dayLabel = when => {
  if (!when) return '';
  const [y, m, d] = when.split('-').map(Number);
  if (d) return new Date(y, m - 1, d).toLocaleDateString('en', { day: 'numeric', month: 'long', year: 'numeric' });
  if (m) return new Date(y, m - 1, 1).toLocaleDateString('en', { month: 'long', year: 'numeric' });
  return String(y);
};
// The date of a text for the book: its ref_date, else the year or month in ref_period ("1997", "2001-04", "Summer 2003").
// Many have only the year where the Italian title gives the month too ("Parola di vita, marzo 2006"): then the month.
const IT_MONTHS = ['gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'];
const monthFromItalian = d => {
  const m = /(gennaio|febbraio|marzo|aprile|maggio|giugno|luglio|agosto|settembre|ottobre|novembre|dicembre)\s+(\d{4})/i.exec(d.it_title || '');
  return m ? `${m[2]}-${String(IT_MONTHS.indexOf(m[1].toLowerCase()) + 1).padStart(2, '0')}` : null;
};
const whenOf = d => d.ref_date || (/^\d{4}-\d{2}/.exec(d.ref_period || '') || [])[0] || monthFromItalian(d)
  || (/^\d{4}/.exec(d.ref_period || '') || [])[0] || (/\b(19|20)\d{2}\b/.exec(d.ref_period || '') || [])[0] || null;
// The titles without what stands in front: "Linkup-1990-10-25-" / "CH-1990-10-25-" (161_linkup_titles.sql), and on the
// few Link-ups without a date the older "Linkup - P ..." and "Link-up: " / "Collegamento: ". A code alone is no title.
const bare = s => (s || '').replace(/^(?:Linkup|CH)-\d{4}-\d{2}-\d{2}-?/, '').replace(/^\d{2}-\d{2}-\d{4}\s+(?=Linkup)/, '')
  .replace(/^Linkup\s*-\s*[A-Z]\s*(?:\d{2}-\d{2}-\d{4}[A-Za-z]?|\d+)?\s*/, '')
  .replace(/^(?:Link-?up|Collegamento)\s*:\s*/i, '').trim();

async function loadBook(book) {
  const rows = [];
  for (let from = 0; ; from += 1000) {
    const page = await withStatus(sb.from('documents')
      .select('document_id,work_id,language,media_type,ref_date,ref_period,en_title,it_title,ur_title,original_title,is_preferred,workflow_status,external_url,duration')
      .eq('category', book.category).is('deleted_at', null).order('document_id').range(from, from + 999), 'Opening the book...');
    rows.push(...page);
    if (page.length < 1000) break;
  }
  const docs = rows.filter(d => !HIDDEN_DOC_STATUSES.includes(d.workflow_status));
  // Which texts have a body, and which recordings have a file: asked in groups, without the texts themselves.
  const textIds = new Set();
  const textDocs = docs.filter(d => (d.media_type || 'DOC') === 'DOC');
  for (let i = 0; i < textDocs.length; i += 150) {
    const ids = textDocs.slice(i, i + 150).map(d => d.document_id);
    const got = await withStatus(sb.from('document_texts').select('document_id,char_count').in('document_id', ids), 'Opening the book...');
    got.filter(t => t.char_count > 0).forEach(t => textIds.add(t.document_id));
  }
  const audioIds = docs.filter(d => d.media_type === 'AUD').map(d => d.document_id);
  const readings = new Map();
  for (let i = 0; i < audioIds.length; i += 150) {
    const got = await withStatus(sb.from('audio_readings').select('document_id,path,reader_name').in('document_id', audioIds.slice(i, i + 150)));
    got.forEach(r => readings.set(r.document_id, r));
  }
  // One page per Work.
  const groups = new Map();
  for (const d of docs) {
    const key = d.work_id != null ? `w${d.work_id}` : `d${d.document_id}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(d);
  }
  const pick = (list, lang) => list.filter(d => d.language === lang && (d.media_type || 'DOC') === 'DOC' && textIds.has(d.document_id))
    .sort((a, b) => (!!b.is_preferred - !!a.is_preferred) || (a.document_id - b.document_id))[0] || null;
  const items = [];
  const clean = s => (book.clean ? bare(s).replace(book.clean, '').trim() : bare(s));
  for (const [key, list] of groups) {
    if (book.include && !list.some(d => book.include.test([d.en_title, d.it_title, d.original_title].filter(Boolean).join(' ')))) continue;
    const urdu = pick(list, 'URD');
    const italian = pick(list, 'ITA');
    const audios = list.filter(d => d.media_type === 'AUD' && readings.has(d.document_id)).map(d => ({ ...d, ...readings.get(d.document_id) }));
    const video = list.find(d => d.media_type === 'VID' && d.external_url);
    if (!urdu && !italian && !audios.length) continue;
    const dated = list.map(whenOf).filter(Boolean).map(w => (book.monthly ? w.slice(0, 7) : w)).sort();
    const titled = [italian, urdu, ...list].filter(Boolean);
    const en = titled.map(d => clean(d.en_title)).find(t => t && !/^link-?up$/i.test(t)) || '';
    const it = titled.map(d => clean(d.it_title)).find(Boolean) || '';
    const ur = titled.map(d => bare(d.ur_title) || (URDU_SCRIPT.test(d.original_title || '') ? d.original_title : '')).find(Boolean) || '';
    items.push({ key, date: dated[0] || null, en, it, ur, urdu, italian, audios, video });
  }
  // The same text kept twice in the archive (same date, same Italian title): one page, with every recording.
  const seen = new Map();
  for (let i = items.length - 1; i >= 0; i--) {
    const it = items[i];
    if (!it.date || !it.it) continue;
    const k = `${it.date}|${it.it.toLowerCase()}`;
    const other = seen.get(k);
    if (!other) { seen.set(k, it); continue; }
    const keep = (other.audios.length >= it.audios.length) ? other : it;
    const drop = keep === other ? it : other;
    keep.audios = [...keep.audios, ...drop.audios.filter(a => !keep.audios.some(x => x.document_id === a.document_id))];
    keep.urdu = keep.urdu || drop.urdu;
    keep.italian = keep.italian || drop.italian;
    items.splice(items.indexOf(drop), 1);
    seen.set(k, keep);
  }
  if (book.order === 'title') items.sort((a, b) => titleOf(a, book).localeCompare(titleOf(b, book), 'en', { sensitivity: 'base' }) || a.key.localeCompare(b.key));
  else items.sort((a, b) => (a.date === null) - (b.date === null) || (a.date || '').localeCompare(b.date || '') || a.key.localeCompare(b.key));
  return items;
}

async function loadBookmark(book) {
  const { data: { user } } = await sb.auth.getUser();
  view.userId = user?.id || null;
  const { data } = await sb.from('book_bookmarks').select('item_key').eq('book_code', book.code).maybeSingle();
  return data?.item_key || null;
}

// The heading a page is listed under: its year, or for a book in A to Z order the first letter of its title.
const yearOf = it => {
  if (view.book && view.book.order === 'title') {
    const c = titleOf(it, view.book).charAt(0).toUpperCase();
    return /[A-Z]/.test(c) ? c : '#';
  }
  return it.date ? it.date.slice(0, 4) : 'Without a date';
};
const capital = s => s.charAt(0).toUpperCase() + s.slice(1);
function titleOf(it, book) {
  if (book.monthly && it.date) return dayLabel(it.date);
  return it.en || it.it || it.ur || (it.date ? `${capital(book.unit[0])} of ${dayLabel(it.date)}` : `${capital(book.unit[0])} without a title`);
}
const itemTitle = it => titleOf(it, view.book);

// ---------- The shelf ----------

function coverHtml(book, items, attrs = '', big = false) {
  const years = items.filter(i => i.date).map(i => i.date.slice(0, 4)).sort();
  const span = years.length ? (years[0] === years[years.length - 1] ? years[0] : `${years[0]} – ${years[years.length - 1]}`) : '';
  return `
    <button type="button" class="book-cover${big ? ' book-cover-big' : ''}${book.cover ? ` book-cover-${book.cover}` : ''}" ${attrs}>
      <span class="book-cover-frame">
        <span class="book-cover-author">${esc(book.author)}</span>
        <span class="book-cover-title book-cover-title-${book.title.length <= 8 ? 's' : book.title.length <= 12 ? 'm' : 'l'}">${esc(book.title).replace(/-/g, '\u2011')}</span>
        <span class="book-cover-rule" aria-hidden="true"></span>
        ${span ? `<span class="book-cover-years">${esc(span)}</span>` : ''}
        ${items.length ? `<span class="book-cover-count">${items.length} ${esc(book.unit[items.length === 1 ? 0 : 1])}</span>` : ''}
      </span>
    </button>`;
}

export async function renderBooksView(main) {
  view.main = main;
  // Opened from Home's "Continue" tile, or from the Library: straight to that book.
  if (State.bookOpen) {
    const { code, key } = State.bookOpen;
    State.bookOpen = null;
    const book = BOOKS.find(b => b.code === code);
    if (book) { await renderBookPage(main, book, key); return; }
  }
  main.innerHTML = `
    <div class="panel">
      <h2>Books</h2>
      <p class="hint" style="margin:-4px 0 16px;">The texts of the archive read like a book, from the first page to the last.</p>
      <div class="book-shelf">${BOOKS.map(b => coverHtml(b, [], `data-book="${esc(b.code)}"`)).join('')}</div>
    </div>`;
  main.querySelectorAll('[data-book]').forEach(b => b.addEventListener('click', () => renderBookPage(main, BOOKS.find(x => x.code === b.dataset.book))));
}

// ---------- A book: cover, Start / Continue, index by year ----------

// cached: coming back from the reader, the book already in memory is drawn again without asking the archive.
async function renderBookPage(main, book, openKey, cached = false) {
  view.main = main;
  if (!(cached && view.book === book && view.items.length)) {
    const [loaded, bookmarkKey] = await Promise.all([loadBook(book), loadBookmark(book).catch(() => null)]);
    view.items = loaded;
    view.bookmarkKey = bookmarkKey && loaded.some(i => i.key === bookmarkKey) ? bookmarkKey : null;
  }
  view.book = book;
  const items = view.items;
  const marked = items.find(i => i.key === view.bookmarkKey);
  const years = [...new Set(items.map(yearOf))];
  main.innerHTML = `
    <div class="panel book-page">
      <div class="btn-row start-back-row"><button class="btn secondary back-btn" id="book-back">&lsaquo; Back</button></div>
      <div class="book-head">
        ${coverHtml(book, items, 'tabindex="-1" aria-hidden="true"', true)}
        <div class="book-head-text">
          <h2 class="book-title">${esc(book.title)}</h2>
          <p class="book-about">${esc(book.about)}</p>
          ${items.length ? `<button class="btn big-btn" id="book-start">&#128214; ${marked ? 'Continue reading' : 'Start reading'}</button>
          ${marked ? `<div class="fp-bookmark-note" dir="auto">&#128278; Your bookmark: ${esc(itemTitle(marked))}${marked.date ? ` &middot; ${esc(dayLabel(marked.date))}` : ''}</div>` : ''}` : '<p class="empty-msg">There is nothing to read here yet.</p>'}
        </div>
      </div>
      ${items.length ? `
      <h3 class="book-index-title">Contents</h3>
      <div class="book-years" role="navigation" aria-label="${book.order === 'title' ? 'Letters' : 'Years'}">${years.map(y => `<button type="button" class="book-year-chip" data-year="${esc(y)}">${esc(y)}</button>`).join('')}</div>
      <div class="book-index">${indexHtml(items)}</div>` : ''}
    </div>`;
  document.getElementById('book-back').addEventListener('click', () => renderBooksView(main));
  document.getElementById('book-start')?.addEventListener('click', () => openReader(Math.max(0, items.indexOf(marked))));
  main.querySelectorAll('[data-year]').forEach(b => b.addEventListener('click', () =>
    main.querySelector(`[data-year-head="${b.dataset.year}"]`)?.scrollIntoView({ behavior: 'smooth', block: 'start' })));
  main.querySelectorAll('[data-go]').forEach(b => b.addEventListener('click', () => openReader(parseInt(b.dataset.go, 10))));
  if (openKey) {
    const i = items.findIndex(x => x.key === openKey);
    if (i >= 0) openReader(i);
  }
}

// The date beside a title in the index: day and month under a year's heading; in an A to Z book, the year.
function indexDate(it) {
  if (!it.date || view.book.monthly) return '';
  if (view.book.order === 'title') return it.date.slice(0, 4);
  const [y, m, d] = it.date.split('-').map(Number);
  if (d) return new Date(y, m - 1, d).toLocaleDateString('en', { day: 'numeric', month: 'short' });
  if (m) return new Date(y, m - 1, 1).toLocaleDateString('en', { month: 'short' });
  return '';
}

function indexHtml(items, current = -1) {
  let html = '', lastYear = null;
  items.forEach((it, i) => {
    const y = yearOf(it);
    if (y !== lastYear) { lastYear = y; html += `<div class="book-index-year" data-year-head="${esc(y)}">${esc(y)}</div>`; }
    const mark = it.key === view.bookmarkKey ? '<span class="fp-toc-bookmark">&#128278; your bookmark</span>' : '';
    const kinds = `${it.urdu || it.italian ? '&#128214;' : ''}${it.audios.length ? ' &#128266;' : ''}`;
    html += `
      <button type="button" class="book-index-item${i === current ? ' current' : ''}" data-go="${i}">
        <span class="book-index-date">${esc(indexDate(it))}</span>
        <span class="book-index-text">
          <span class="book-index-name" dir="auto">${esc(itemTitle(it))}</span>
          ${it.ur ? `<span class="book-index-ur" dir="rtl" lang="ur">${esc(it.ur)}</span>` : ''}
          ${it.it && it.en && !view.book.monthly ? `<span class="book-index-it" dir="auto">${esc(it.it)}</span>` : ''}
        </span>
        <span class="book-index-kinds" aria-hidden="true">${kinds}</span>${mark}
      </button>`;
  });
  return html;
}

// ---------- The reader ----------

function openReader(index) {
  if (!view.items.length) return;
  if (!document.getElementById('book-reader')) {
    view.main.insertAdjacentHTML('beforeend', `
      <div class="fp-reader book-reader" id="book-reader" role="dialog" aria-label="${esc(view.book.title)}">
        <div class="fp-reader-bar">
          <button type="button" class="btn secondary back-btn" id="br-close">&lsaquo; Back</button>
          <div class="fp-reader-where">
            <div class="fp-reader-path">${esc(view.book.title)}</div>
            <div class="fp-reader-pos" id="br-pos"></div>
          </div>
          <button type="button" class="btn fp-bookmark-btn" id="br-bookmark"></button>
          <button type="button" class="btn secondary" id="br-toc-btn" aria-label="Contents">&#9776;<span class="fp-btn-label"> Contents</span></button>
        </div>
        <div class="fp-reader-toc" id="br-toc" hidden></div>
        <div class="fp-bookmark-ribbon" id="br-ribbon" hidden>&#128278; Your bookmark is on this page</div>
        <div class="fp-reader-body" id="br-body"></div>
        <div class="fp-reader-nav">
          <button type="button" class="btn secondary" id="br-prev">&lsaquo; Previous</button>
          <span class="hint" id="br-count"></span>
          <button type="button" class="btn" id="br-next">Next &rsaquo;</button>
        </div>
      </div>`);
    history.pushState({ bookReader: true }, '');
    wireReader();
  }
  showPage(index);
}

// quiet: fetching the next page in the background, without the "Loading" wheel.
async function bodyOf(doc, quiet = false) {
  if (textCache.has(doc.document_id)) return textCache.get(doc.document_id);
  const query = sb.from('document_texts').select('body').eq('document_id', doc.document_id);
  const rows = quiet ? ((await query).data || []) : await withStatus(query, 'Turning the page...');
  const body = rows[0]?.body || '';
  textCache.set(doc.document_id, body);
  return body;
}

async function showPage(index) {
  if (index < 0 || index >= view.items.length || view.loading) return;
  view.loading = true;
  view.index = index;
  const it = view.items[index];
  document.getElementById('br-pos').textContent = view.book.order === 'title'
    ? `page ${index + 1} of ${view.items.length}` : `${yearOf(it)} · page ${index + 1} of ${view.items.length}`;
  document.getElementById('br-count').textContent = `${index + 1} / ${view.items.length}`;
  document.getElementById('br-prev').disabled = index === 0;
  document.getElementById('br-next').disabled = index === view.items.length - 1;
  document.getElementById('br-toc').hidden = true;
  updateBookmark();
  // Urdu first; the reader's choice of language is kept for this page while the book is open.
  const lang = view.lang[it.key] || (it.urdu ? 'URD' : 'ITA');
  const doc = lang === 'URD' ? it.urdu : it.italian;
  const body = document.getElementById('br-body');
  try {
    const text = doc ? await bodyOf(doc) : '';
    body.innerHTML = `
      <article class="book-leaf">
        <div class="book-leaf-date">${esc(dayLabel(it.date))}</div>
        <h2 class="book-leaf-title" dir="auto">${esc(view.book.monthly && it.date ? view.book.unit[0] : itemTitle(it))}</h2>
        ${it.ur ? `<div class="book-leaf-ur" dir="rtl" lang="ur">${esc(it.ur)}</div>` : ''}
        <div class="book-leaf-tools">
          ${it.urdu && it.italian ? `<div class="book-lang" role="group" aria-label="Language">
            <button type="button" class="btn ${lang === 'URD' ? '' : 'secondary'}" data-lang="URD" aria-pressed="${lang === 'URD'}">Urdu</button>
            <button type="button" class="btn ${lang === 'ITA' ? '' : 'secondary'}" data-lang="ITA" aria-pressed="${lang === 'ITA'}">Italian</button>
          </div>` : (doc ? `<span class="book-lang-only">${lang === 'URD' ? 'In Urdu' : 'In Italian: the Urdu text is not in the archive yet'}</span>` : '')}
          ${it.audios.length ? `<button type="button" class="btn book-listen" id="br-listen">&#128266; Listen${it.audios[0].duration ? ` <span class="reader-btn-note">${esc(it.audios[0].duration)}</span>` : ''}</button>` : ''}
          ${it.video ? `<a class="btn secondary" href="${esc(it.video.external_url)}" target="_blank" rel="noopener noreferrer">&#9654; Watch</a>` : ''}
        </div>
        <div id="br-player"></div>
        ${view.book.verse && doc ? verseHtml(text, lang) : ''}
        ${doc ? `<div class="book-leaf-text ${lang === 'URD' ? 'reading-text' : 'reading-text reading-text-latin'}" dir="${lang === 'URD' ? 'rtl' : 'ltr'}" lang="${lang === 'URD' ? 'ur' : 'it'}">${esc(text)}</div>`
          : '<p class="hint">There is no written text of this one yet: you can listen to it.</p>'}
        <div class="book-leaf-end" aria-hidden="true">&#10086;</div>
        ${doc ? `<button type="button" class="btn secondary book-report" id="br-report">Found a mistake? Tell us</button>` : ''}
      </article>`;
  } finally {
    view.loading = false;
  }
  body.scrollTop = 0;
  body.querySelectorAll('[data-lang]').forEach(b => b.addEventListener('click', () => { view.lang[it.key] = b.dataset.lang; showPage(view.index); }));
  document.getElementById('br-listen')?.addEventListener('click', () => {
    document.getElementById('br-listen').classList.add('playing');
    mountAudioPlayer(document.getElementById('br-player'), it.audios[0], true);
  });
  document.getElementById('br-report')?.addEventListener('click', () => {
    State.selectedDocId = doc.document_id;
    State.chatMessagePrefill = null;
    closeReader(false);
    window.__renderTab('chat');
  });
  // The next page is fetched while this one is read, so turning the page is quick.
  const next = view.items[index + 1];
  const nextDoc = next && (next.urdu || next.italian);
  if (nextDoc) bodyOf(nextDoc, true).catch(() => {});
}

// The verse at the top of a Word of Life: the first line between quotation marks near the start (it may run on to the
// next lines until the quotation closes), with the reference in brackets that follows it. Nothing when none is found.
function verseHtml(text, lang) {
  const lines = (text || '').split('\n').map(s => s.trim()).filter(Boolean).slice(0, 10);
  const opens = /[‘“"«']/;
  const ref = /\([^()]*\d+\s*[:：]\s*\d+[^()]*\)/;
  const words = l => l.replace(/[^\p{L}]/gu, '').length > 8;
  // First a line that carries its Bible reference "(Luke 6:38)", or whose next line is only that reference; else the
  // first line between quotation marks.
  let i = lines.findIndex((l, k) => words(l) && k < 6 && (ref.test(l) || (lines[k + 1] && /^\(.{2,40}\)$/.test(lines[k + 1]) && ref.test(lines[k + 1]))));
  if (i > 0 && !ref.test(lines[i]) && !opens.test(lines[i])) {
    // The reference may close a verse that began on an earlier line with the quotation mark.
    const start = lines.slice(0, i).map((l, k) => (opens.test(l) && words(l) ? k : -1)).filter(k => k >= 0).pop();
    if (start != null && i - start <= 3) i = start;
  }
  // A line that only contains quotation marks somewhere (a note in brackets, say) is no verse: it must begin with one.
  if (i < 0) i = lines.findIndex(l => /^[‘“"«']/.test(l) && words(l));
  if (i < 0) return '';
  let verse = lines[i];
  let j = i;
  const closes = /[’”»]/;
  while (!closes.test(verse) && j < i + 3 && lines[j + 1]) verse += ' ' + lines[++j];
  // The verse ends with its closing quotation mark, and the reference in brackets right after it, when there is one:
  // the commentary that may follow on the same line is not part of it.
  const end = /[’”»]+(?:\s*[۔.]?\s*\([^()]{2,40}\))?/.exec(verse);
  const sameLineRef = end && /\(/.test(end[0]);
  if (end) verse = verse.slice(0, end.index + end[0].length).trim();
  const cite = !sameLineRef && lines[j + 1] && /^\(.{2,40}\)$/.test(lines[j + 1]) ? lines[j + 1] : '';
  return `<blockquote class="book-verse" dir="${lang === 'URD' ? 'rtl' : 'ltr'}" lang="${lang === 'URD' ? 'ur' : 'it'}">${esc(verse)}${cite ? `<cite>${esc(cite)}</cite>` : ''}</blockquote>`;
}

function updateBookmark() {
  const btn = document.getElementById('br-bookmark');
  if (!btn) return;
  const here = view.bookmarkKey === view.items[view.index].key;
  btn.innerHTML = here ? '&#128278; Bookmarked &#10004;' : '&#9734; Bookmark';
  btn.setAttribute('aria-pressed', String(here));
  btn.classList.toggle('fp-bookmark-on', here);
  btn.title = here ? 'Remove the bookmark' : 'Keep my place here';
  document.getElementById('br-ribbon').hidden = !here;
}

async function toggleBookmark() {
  const key = view.items[view.index].key;
  try {
    if (view.bookmarkKey === key) {
      await withStatus(sb.from('book_bookmarks').delete().eq('book_code', view.book.code).eq('user_id', view.userId), 'Saving...');
      view.bookmarkKey = null;
    } else {
      await withStatus(sb.from('book_bookmarks').upsert({ user_id: view.userId, book_code: view.book.code, item_key: key, updated_at: new Date().toISOString() }, { onConflict: 'user_id,book_code' }), 'Saving...');
      view.bookmarkKey = key;
    }
  } catch {
    alert('The bookmark could not be saved just now. Please try again later.');
    return;
  }
  updateBookmark();
}

function wireReader() {
  const go = d => showPage(view.index + d);
  document.getElementById('br-prev').addEventListener('click', () => go(-1));
  document.getElementById('br-next').addEventListener('click', () => go(1));
  document.getElementById('br-close').addEventListener('click', () => {
    if (history.state && history.state.bookReader) history.back(); else closeReader(true);
  });
  document.getElementById('br-bookmark').addEventListener('click', toggleBookmark);
  const toc = document.getElementById('br-toc');
  document.getElementById('br-toc-btn').addEventListener('click', () => {
    toc.hidden = !toc.hidden;
    if (toc.hidden) return;
    toc.innerHTML = `<div class="book-index">${indexHtml(view.items, view.index)}</div>`;
    toc.querySelector('.current')?.scrollIntoView({ block: 'center' });
  });
  toc.addEventListener('click', e => {
    const b = e.target.closest('[data-go]');
    if (b) showPage(parseInt(b.dataset.go, 10));
  });
  // A swipe turns the page.
  const body = document.getElementById('br-body');
  let start = null;
  body.addEventListener('touchstart', e => { start = e.touches.length === 1 ? { x: e.touches[0].clientX, y: e.touches[0].clientY } : null; }, { passive: true });
  body.addEventListener('touchend', e => {
    if (!start) return;
    const dx = e.changedTouches[0].clientX - start.x, dy = e.changedTouches[0].clientY - start.y;
    start = null;
    if (Math.abs(dx) > 70 && Math.abs(dy) < 50) go(dx < 0 ? 1 : -1);
  }, { passive: true });
  document.addEventListener('keydown', readerKeys);
}

function readerKeys(e) {
  if (!document.getElementById('book-reader') || document.querySelector('.overlay-backdrop, .reading-view')) return;
  if (e.target.closest && e.target.closest('input, textarea, select')) return;
  if (e.key === 'ArrowRight') showPage(view.index + 1);
  else if (e.key === 'ArrowLeft') showPage(view.index - 1);
  else if (e.key === 'Escape') document.getElementById('br-close').click();
}

// Back to the book's page, its index showing where the reader was.
function closeReader(refresh) {
  const el = document.getElementById('book-reader');
  if (!el) return;
  el.querySelectorAll('audio').forEach(a => a.pause());
  el.remove();
  document.removeEventListener('keydown', readerKeys);
  if (refresh && view.main && document.body.contains(view.main)) {
    const at = view.items[view.index];
    renderBookPage(view.main, view.book, null, true).then(() => {
      view.main.querySelector(`[data-go="${view.items.findIndex(i => i.key === at?.key)}"]`)?.scrollIntoView({ block: 'center' });
    });
  }
}
window.addEventListener('popstate', () => { if (document.getElementById('book-reader')) closeReader(true); });

// For Home: the book this person was reading, from their latest bookmark.
export async function lastBookBookmark() {
  const { data } = await sb.from('book_bookmarks').select('book_code,item_key,updated_at').order('updated_at', { ascending: false }).limit(1);
  const row = data && data[0];
  const book = row && BOOKS.find(b => b.code === row.book_code);
  return book ? { book, key: row.item_key } : null;
}
