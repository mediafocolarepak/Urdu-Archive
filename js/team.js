const SUPABASE_URL = 'https://tvabpsxfwofiqriwbolz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2YWJwc3hmd29maXFyaXdib2x6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0NTQ2OTksImV4cCI6MjEwMjAzMDY5OX0.ltxl-K6lHKp1NC3-t9xzMOML9JVyqrpcQjkHkauiGBY';
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const BUCKET = 'archive-files';

// Legacy PDF archive: files live in a shared, publicly-readable Google Drive folder
// and are looked up by exact file_name match (the API key is restricted to Drive API
// + this site's domain in Google Cloud Console, so it's safe to ship in client code).
const GDRIVE_API_KEY = 'AIzaSyD_AMo9JFxS3jf6Wv1Cg3TRyMvXkzVYFEQ';
const GDRIVE_FOLDER_ID = '1r9-UM5hJ6xQYm24RzpK4Zo74x1XKyCIq';

async function downloadFromGDrive(fileName) {
  if (!fileName) { alert('This document has no file name yet.'); return; }
  const q = `name='${fileName.replace(/'/g, "\\'")}' and '${GDRIVE_FOLDER_ID}' in parents and trashed=false`;
  const url = `https://www.googleapis.com/drive/v3/files?q=${encodeURIComponent(q)}&fields=files(id,name)&key=${GDRIVE_API_KEY}`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    if (data.error) { alert('Google Drive error: ' + data.error.message); return; }
    if (!data.files || data.files.length === 0) {
      alert(`"${fileName}" was not found yet in the Google Drive archive folder.`);
      return;
    }
    window.open(`https://drive.google.com/file/d/${data.files[0].id}/view`, '_blank');
  } catch (e) {
    alert('Could not reach Google Drive: ' + e.message);
  }
}

// ---------- Fixed vocabularies ----------
// Loaded from the admin-editable `option_lists` table at sign-in (see loadOptions()).
// These start empty and are populated before any tab renders.

let CATEGORIES = [];
let AUTHORS = [];
let MAIN_TOPICS = [];
let RECIPIENTS = [];
let LANGS = [];
let STATUSES = [];
const OPTION_LIST_NAMES = ['category', 'author', 'main_topic', 'recipient', 'original_lang', 'workflow_status'];
const OPTION_LIST_TARGETS = { category: 'CATEGORIES', author: 'AUTHORS', main_topic: 'MAIN_TOPICS', recipient: 'RECIPIENTS', original_lang: 'LANGS', workflow_status: 'STATUSES' };

async function loadOptions() {
  const rows = await withStatus(sb.from('option_lists').select('*').order('sort_order'));
  const byList = { category: [], author: [], main_topic: [], recipient: [], original_lang: [], workflow_status: [] };
  for (const r of rows) { if (byList[r.list_name]) byList[r.list_name].push([r.code, r.label]); }
  CATEGORIES = byList.category; AUTHORS = byList.author; MAIN_TOPICS = byList.main_topic;
  RECIPIENTS = byList.recipient; LANGS = byList.original_lang; STATUSES = byList.workflow_status;
}

const TRACKING_STEPS = [
  ['ENTR', 'Entry', 'Document identified and registered in DB. Original source acquired.'],
  ['TYP', 'Typing', 'Transcription/OCR completed. Initial Urdu draft prepared (unrevised).'],
  ['PROF', 'Proofing', 'First formal reading done. Spelling, punctuation, and diacritics checked against original.'],
  ['CORR', 'Correction', 'Errors found in Proofing have been corrected. Second draft ready.'],
  ['APPR', 'Approved', 'Final review by a senior terminologist. Text declared doctrinally and stylistically accurate.'],
  ['STOR', 'Stored', 'Master file stored in read-only repository. Physical copy filed in box.'],
];

function labelOf(list, code) { const f = list.find(x => x[0] === code); return f ? f[1] : (code || ''); }
function optionsHtml(list, value, allowEmpty) {
  return (allowEmpty ? '<option value=""></option>' : '') +
    list.map(([c, l]) => `<option value="${c}" ${c === value ? 'selected' : ''}>${l}</option>`).join('');
}

// ---------- State ----------

let SelectedDocId = null;
let SelectedBookName = null;
let SelectedCategoryId = null;
let DashFilters = { search: '', category: '', author: '', main_topic: '', workflow_status: '', recipient: [], legacyOnly: false, pendingOnly: false };
let DashPage = 0;
const DASH_PAGE_SIZE = 25;
let DashSort = { col: 'document_id', asc: false };
const DASH_SORTABLE = { document_id: 'ID', title: 'Title', category: 'Category', author: 'Author', ref_date: 'Ref. date', workflow_status: 'Status' };

let CurrentRole = 'user';
function canWrite() { return CurrentRole === 'operator' || CurrentRole === 'admin'; }
function canDelete() { return CurrentRole === 'admin'; }
function isAdmin() { return CurrentRole === 'admin'; }

// ---------- Helpers ----------

function today() {
  const d = new Date();
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}
function esc(v) {
  if (v === null || v === undefined) return '';
  return String(v).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}
function likeSafe(s) { return '%' + s.replace(/[%,()]/g, '') + '%'; }

function slugify(title) {
  if (!title) return 'untitled';
  let s = title.toLowerCase();
  s = s.replace(/['".,;:!?()]/g, '');
  s = s.replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  if (s.length > 30) {
    let cut = s.slice(0, 30);
    const lastDash = cut.lastIndexOf('-');
    if (lastDash > 10) cut = cut.slice(0, lastDash);
    s = cut;
  }
  return s || 'untitled';
}
function yearOf(refDate, refPeriod) {
  if (refDate) { const m = refDate.match(/^(\d{4})-/); if (m) return m[1]; }
  if (refPeriod) { const m = refPeriod.match(/(\d{4})/); if (m) return m[1]; }
  return 'XXXX';
}
function computeFileName(doc) {
  const id = String(doc.document_id).padStart(5, '0');
  const cat = doc.category || 'MISC';
  const auth = doc.author || 'OTHR';
  const topic = doc.main_topic || 'GENR';
  const slug = slugify(doc.title);
  const year = yearOf(doc.ref_date, doc.ref_period);
  return `${id}-${cat}-${auth}-${topic}-${slug}-${year}.pdf`;
}
async function uniqueFileName(base, excludeDocId) {
  let name = base;
  let suffix = 2;
  for (;;) {
    let q = sb.from('documents').select('document_id').eq('file_name', name);
    if (excludeDocId) q = q.neq('document_id', excludeDocId);
    const { data } = await q;
    if (!data || data.length === 0) return name;
    name = base.replace(/\.pdf$/, '') + '-' + suffix + '.pdf';
    suffix++;
  }
}

function setStatus(text, isError) {
  const label = document.getElementById('dirty-label');
  const dot = document.getElementById('dirty-dot');
  if (label) label.textContent = text;
  if (dot) dot.className = 'dot' + (isError ? ' dirty' : '');
}

async function withStatus(promise, busyText) {
  setStatus(busyText || 'Working...', false);
  const { data, error } = await promise;
  if (error) { setStatus('Error: ' + error.message, true); throw error; }
  setStatus('Connected', false);
  return data;
}
async function withStatusCount(promise, busyText) {
  setStatus(busyText || 'Working...', false);
  const { data, error, count } = await promise;
  if (error) { setStatus('Error: ' + error.message, true); throw error; }
  setStatus('Connected', false);
  return { data, count };
}

// ---------- AUTH ----------

let appShown = false;

async function boot() {
  const { data: { session } } = await sb.auth.getSession();
  if (session) { showApp(session); } else { showLogin(); }
  sb.auth.onAuthStateChange((event, session) => {
    if (session && !appShown) showApp(session);
    else if (session) document.getElementById('user-email').textContent = session.user.email;
    else { appShown = false; showLogin(); }
  });
}

function showLogin() {
  document.getElementById('login-screen').style.display = 'flex';
  document.getElementById('app').style.display = 'none';
}

async function showApp(session) {
  appShown = true;
  SelectedDocId = null; SelectedBookName = null; SelectedCategoryId = null;
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('app').style.display = 'flex';

  const { data: roleRows } = await sb.from('user_roles').select('role').eq('user_id', session.user.id);
  CurrentRole = roleRows && roleRows[0] ? roleRows[0].role : 'user';
  document.getElementById('user-email').textContent = `${session.user.email} (${CurrentRole})`;

  await loadOptions();
  initTopbar();
  renderTab('dashboard');
}

document.getElementById('login-btn').addEventListener('click', async () => {
  const email = document.getElementById('login-email').value.trim();
  const password = document.getElementById('login-password').value;
  const errBox = document.getElementById('login-error');
  errBox.textContent = '';
  const { error } = await sb.auth.signInWithPassword({ email, password });
  if (error) errBox.textContent = error.message;
});

document.getElementById('signup-btn').addEventListener('click', async () => {
  const email = document.getElementById('login-email').value.trim();
  const password = document.getElementById('login-password').value;
  const errBox = document.getElementById('login-error');
  errBox.textContent = '';
  if (!email || password.length < 6) { errBox.textContent = 'Email and password (min. 6 characters) are required.'; return; }
  const { error } = await sb.auth.signUp({ email, password });
  if (error) { errBox.textContent = error.message; return; }
  errBox.style.color = 'var(--accent)';
  errBox.textContent = 'Sign-up submitted. Check your email to confirm, then sign in.';
});

document.getElementById('logout-btn').addEventListener('click', () => sb.auth.signOut());

// ---------- TABS ----------

function getTabs() {
  const tabs = [
    { id: 'dashboard', label: 'Dashboard' },
    { id: 'reports', label: 'Print Reports' },
    { id: 'libri', label: 'Libri' },
    { id: 'processi', label: 'Processi' },
    { id: 'hayat', label: 'Hayat Index' },
  ];
  if (canWrite()) { tabs.push({ id: 'matchreview', label: 'Match Review' }); tabs.push({ id: 'bulkimport', label: 'Bulk Import' }); }
  if (isAdmin()) { tabs.push({ id: 'users', label: 'Users' }); tabs.push({ id: 'options', label: 'Options' }); }
  return tabs;
}

function initTopbar() {
  const bar = document.getElementById('tabs');
  const tabs = getTabs();
  bar.innerHTML = tabs.map(t => `<button class="tab-btn" data-tab="${t.id}">${t.label}</button>`).join('');
  bar.querySelectorAll('.tab-btn').forEach(b => b.addEventListener('click', () => renderTab(b.dataset.tab)));
}

function renderTab(id) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.dataset.tab === id));
  const main = document.getElementById('main');
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  if (id === 'dashboard') renderDashboardView(main);
  else if (id === 'reports') renderReportsView(main);
  else if (id === 'libri') renderLibriView(main);
  else if (id === 'processi') renderProcessiView(main);
  else if (id === 'hayat') renderHayatView(main);
  else if (id === 'users') renderUsersView(main);
  else if (id === 'options') renderOptionsView(main);
  else if (id === 'matchreview') renderMatchReviewView(main);
  else if (id === 'bulkimport') renderBulkImportView(main);
}

// ================= DASHBOARD =================

async function renderDashboardView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Dashboard <span class="count-badge" id="dash-count"></span></h2>
      <div class="searchbar">
        <input id="dash-search" placeholder="Search by title or tags..." value="${esc(DashFilters.search)}">
        ${canWrite() ? '<button class="btn" id="dash-new">+ New document</button>' : ''}
      </div>
      <div class="field-grid" style="margin-bottom:10px;">
        <div class="field"><label>Category</label><select id="f-category">${optionsHtml(CATEGORIES, DashFilters.category, true)}</select></div>
        <div class="field"><label>Author</label><select id="f-author">${optionsHtml(AUTHORS, DashFilters.author, true)}</select></div>
        <div class="field"><label>Main topic</label><select id="f-main_topic">${optionsHtml(MAIN_TOPICS, DashFilters.main_topic, true)}</select></div>
        <div class="field"><label>Workflow status</label><select id="f-status">${optionsHtml(STATUSES, DashFilters.workflow_status, true)}</select></div>
      </div>
      <div class="field">
        <label>Recipient(s)</label>
        <div class="btn-row" style="margin:0;">
          ${RECIPIENTS.map(([c, l]) => `<label style="display:flex;align-items:center;gap:4px;font-size:12.5px;font-weight:normal;text-transform:none;">
            <input type="checkbox" class="f-recipient" value="${c}" ${DashFilters.recipient.includes(c) ? 'checked' : ''}> ${l}</label>`).join('')}
        </div>
      </div>
      <div class="field" style="max-width:260px;">
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="f-legacy" ${DashFilters.legacyOnly ? 'checked' : ''}> Show legacy-migrated documents only
        </label>
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;margin-top:6px;">
          <input type="checkbox" id="f-pending" ${DashFilters.pendingOnly ? 'checked' : ''}> Show only documents marked for deletion
        </label>
      </div>
      <div class="split">
        <div>
          <div class="grid-wrap"><table class="grid" id="dash-grid"></table></div>
          <div class="btn-row" id="dash-pager"></div>
        </div>
        <div class="panel" id="doc-detail" style="margin:0;"></div>
      </div>
    </div>`;

  document.getElementById('dash-search').addEventListener('input', e => { DashFilters.search = e.target.value; DashPage = 0; refreshDashGrid(); });
  if (canWrite()) document.getElementById('dash-new').addEventListener('click', createNewDocument);
  document.getElementById('f-category').addEventListener('change', e => { DashFilters.category = e.target.value; DashPage = 0; refreshDashGrid(); });
  document.getElementById('f-author').addEventListener('change', e => { DashFilters.author = e.target.value; DashPage = 0; refreshDashGrid(); });
  document.getElementById('f-main_topic').addEventListener('change', e => { DashFilters.main_topic = e.target.value; DashPage = 0; refreshDashGrid(); });
  document.getElementById('f-status').addEventListener('change', e => { DashFilters.workflow_status = e.target.value; DashPage = 0; refreshDashGrid(); });
  document.getElementById('f-legacy').addEventListener('change', e => { DashFilters.legacyOnly = e.target.checked; DashPage = 0; refreshDashGrid(); });
  document.getElementById('f-pending').addEventListener('change', e => { DashFilters.pendingOnly = e.target.checked; DashPage = 0; refreshDashGrid(); });
  main.querySelectorAll('.f-recipient').forEach(cb => cb.addEventListener('change', () => {
    DashFilters.recipient = Array.from(main.querySelectorAll('.f-recipient:checked')).map(c => c.value);
    DashPage = 0; refreshDashGrid();
  }));

  await refreshDashGrid();
  await renderDocDetail(SelectedDocId);
}

function buildDashQuery(forCount) {
  let q = sb.from('documents').select(
    forCount ? 'document_id' : 'document_id,category,author,main_topic,recipient,title,ref_date,workflow_status,legacy_migrated,pending_deletion',
    forCount ? { count: 'exact', head: true } : undefined
  );
  if (DashFilters.search && DashFilters.search.trim()) {
    const like = likeSafe(DashFilters.search.trim());
    q = q.or(`title.ilike.${like},secondary_tags.ilike.${like}`);
  }
  if (DashFilters.category) q = q.eq('category', DashFilters.category);
  if (DashFilters.author) q = q.eq('author', DashFilters.author);
  if (DashFilters.main_topic) q = q.eq('main_topic', DashFilters.main_topic);
  if (DashFilters.workflow_status) q = q.eq('workflow_status', DashFilters.workflow_status);
  if (DashFilters.legacyOnly) q = q.eq('legacy_migrated', true);
  if (DashFilters.pendingOnly) q = q.eq('pending_deletion', true);
  if (DashFilters.recipient.length) q = q.overlaps('recipient', DashFilters.recipient);
  return q;
}

async function refreshDashGrid() {
  const grid = document.getElementById('dash-grid');
  const { count } = await withStatusCount(buildDashQuery(true), 'Searching...');
  const total = count || 0;
  const maxPage = Math.max(0, Math.ceil(total / DASH_PAGE_SIZE) - 1);
  if (DashPage > maxPage) DashPage = maxPage;
  const from = DashPage * DASH_PAGE_SIZE;
  const to = from + DASH_PAGE_SIZE - 1;
  const rows = await withStatus(buildDashQuery(false).order(DashSort.col, { ascending: DashSort.asc }).range(from, to));
  document.getElementById('dash-count').textContent = total;
  const arrow = (col) => col !== DashSort.col ? '' : (DashSort.asc ? ' &uarr;' : ' &darr;');
  grid.innerHTML = `<thead><tr>${Object.entries(DASH_SORTABLE).map(([col, label]) =>
      `<th data-sort="${col}">${label}${arrow(col)}</th>`).join('')}<th>Recipient(s)</th></tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.document_id)}" class="${String(r.document_id) === String(SelectedDocId) ? 'selected' : ''}">
      <td>${esc(r.document_id)}${r.legacy_migrated ? ' <span class="count-badge" style="padding:1px 6px;">legacy</span>' : ''}${r.pending_deletion ? ' <span class="count-badge" style="padding:1px 6px;background:var(--danger);color:#fff;">pending deletion</span>' : ''}</td>
      <td>${esc(r.title)}</td><td>${esc(labelOf(CATEGORIES, r.category))}</td><td>${esc(labelOf(AUTHORS, r.author))}</td>
      <td>${esc(r.ref_date)}</td><td>${esc(labelOf(STATUSES, r.workflow_status))}</td>
      <td>${(r.recipient || []).map(c => esc(labelOf(RECIPIENTS, c))).join(', ')}</td></tr>`).join('')}</tbody>`;
  grid.querySelectorAll('th[data-sort]').forEach(th => th.addEventListener('click', () => {
    const col = th.dataset.sort;
    if (DashSort.col === col) DashSort.asc = !DashSort.asc; else DashSort = { col, asc: true };
    refreshDashGrid();
  }));
  grid.querySelectorAll('tbody tr').forEach(tr => tr.addEventListener('click', async () => {
    SelectedDocId = tr.dataset.id;
    await refreshDashGrid();
    await renderDocDetail(SelectedDocId);
  }));
  document.getElementById('dash-pager').innerHTML = `
    <button class="btn secondary" id="pg-prev" ${DashPage === 0 ? 'disabled' : ''}>&larr; Previous</button>
    <span class="hint" style="align-self:center;">Page ${total ? DashPage + 1 : 0} of ${maxPage + 1} &middot; Total documents: ${total}</span>
    <button class="btn secondary" id="pg-next" ${DashPage >= maxPage ? 'disabled' : ''}>Next &rarr;</button>`;
  document.getElementById('pg-prev').addEventListener('click', () => { DashPage--; refreshDashGrid(); });
  document.getElementById('pg-next').addEventListener('click', () => { DashPage++; refreshDashGrid(); });
}

function renderDocDetailConsultation(box, doc) {
  const row = (label, value) => `<div class="field"><label>${esc(label)}</label><input value="${esc(value)}" disabled></div>`;
  box.innerHTML = `
    <h3>Document #${esc(doc.document_id)}</h3>
    <div class="field-grid wide">
      ${row('Title (EN)', doc.title)}
      ${row('Category', labelOf(CATEGORIES, doc.category))}
      ${row('Author', labelOf(AUTHORS, doc.author))}
      ${row('Main topic', labelOf(MAIN_TOPICS, doc.main_topic))}
      ${row('Secondary tags', doc.secondary_tags)}
      ${row('Original language', labelOf(LANGS, doc.original_lang))}
      ${row('Reference date', doc.ref_date)}
      ${row('File name', doc.file_name)}
      ${row('Video', doc.has_video ? 'Yes' : 'No')}
      ${row('Title (ITA)', doc.italian_title)}
      ${row('Video ref', doc.video_ref)}
      ${row('Parola di Vita ref', doc.pdv_ref)}
    </div>
    <div class="field">
      <label>Recipient(s)</label>
      <div style="font-size:13px;padding:4px 0;">${(doc.recipient || []).map(c => esc(labelOf(RECIPIENTS, c))).join(', ') || '—'}</div>
    </div>
    <div class="btn-row">
      <button class="btn" id="doc-download-gdrive">Download Document</button>
    </div>
    ${doc.storage_path ? `<div class="field"><label>File</label><a href="#" id="doc-download">Download</a></div>` : ''}
  `;
  document.getElementById('doc-download-gdrive').addEventListener('click', () => downloadFromGDrive(doc.file_name));
  if (doc.storage_path) {
    document.getElementById('doc-download').addEventListener('click', async e => {
      e.preventDefault();
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
  }
}

async function renderDocDetail(id) {
  const box = document.getElementById('doc-detail');
  if (!box) return;
  if (!id) { box.innerHTML = '<div class="empty-msg">Select a document from the list, or create a new one.</div>'; return; }
  const rows = await withStatus(sb.from('documents').select('*').eq('document_id', id));
  if (!rows.length) { box.innerHTML = '<div class="empty-msg">Document not found.</div>'; return; }
  const doc = rows[0];

  if (CurrentRole === 'user') { renderDocDetailConsultation(box, doc); return; }

  const readOnly = !canWrite();

  function textField(label, name, value, type) {
    if (readOnly) return `<div class="field"><label>${esc(label)}</label><input value="${esc(value)}" disabled></div>`;
    return `<div class="field"><label>${esc(label)}</label><input data-f="${name}" type="${type || 'text'}" value="${esc(value)}"></div>`;
  }
  function selectField(label, name, value, list) {
    if (readOnly) return `<div class="field"><label>${esc(label)}</label><input value="${esc(labelOf(list, value))}" disabled></div>`;
    return `<div class="field"><label>${esc(label)}</label><select data-f="${name}">${optionsHtml(list, value, false)}</select></div>`;
  }

  const previewName = computeFileName({ ...doc });

  box.innerHTML = `
    <h3>Document #${esc(doc.document_id)}${doc.legacy_migrated ? ' <span class="count-badge">legacy-migrated</span>' : ''}${doc.pending_deletion ? ' <span class="count-badge" style="background:var(--danger);color:#fff;">pending deletion</span>' : ''}</h3>
    <div class="field-grid wide">
      ${textField('Title (EN)', 'title', doc.title)}
      ${textField('Reference date', 'ref_date', doc.ref_date, 'date')}
      ${textField('Title (ITA)', 'italian_title', doc.italian_title)}
      ${selectField('Category', 'category', doc.category, CATEGORIES)}
      ${selectField('Author', 'author', doc.author, AUTHORS)}
      ${selectField('Main topic', 'main_topic', doc.main_topic, MAIN_TOPICS)}
      ${textField('Secondary tags', 'secondary_tags', doc.secondary_tags)}
      ${selectField('Original language', 'original_lang', doc.original_lang, LANGS)}
      ${textField('Reference period', 'ref_period', doc.ref_period)}
      ${selectField('Workflow status', 'workflow_status', doc.workflow_status, STATUSES)}
      ${textField('Physical box', 'physical_box', doc.physical_box)}
      ${textField('Video ref', 'video_ref', doc.video_ref)}
      ${textField('Parola di Vita ref', 'pdv_ref', doc.pdv_ref)}
      <div class="field"><label>File name</label><input value="${esc(doc.file_name)}" disabled></div>
      ${readOnly ? `<div class="field"><label>Video</label><input value="${doc.has_video ? 'Yes' : 'No'}" disabled></div>`
        : `<div class="field"><label>Video</label><select data-f="has_video">
             <option value="false" ${!doc.has_video ? 'selected' : ''}>No</option>
             <option value="true" ${doc.has_video ? 'selected' : ''}>Yes</option>
           </select></div>`}
    </div>
    <div class="field">
      <label>Recipient(s)</label>
      <div class="btn-row" style="margin:0;">
        ${RECIPIENTS.map(([c, l]) => `<label style="display:flex;align-items:center;gap:4px;font-size:12.5px;font-weight:normal;text-transform:none;">
          <input type="checkbox" class="f-doc-recipient" value="${c}" ${(doc.recipient || []).includes(c) ? 'checked' : ''} ${readOnly ? 'disabled' : ''}> ${l}</label>`).join('')}
      </div>
    </div>
    ${readOnly ? `<div class="field"><label>Notes</label><textarea disabled>${esc(doc.notes)}</textarea></div>`
      : `<div class="field"><label>Notes</label><textarea data-f="notes">${esc(doc.notes)}</textarea></div>`}
    <div class="field">
      <label>File</label>
      ${readOnly ? '' : `<div class="hint">File will be saved as: <b id="filename-preview">${esc(previewName)}</b></div>`}
      ${doc.storage_path ? `<div class="hint">Currently on file: ${esc(doc.file_name)} — <a href="#" id="doc-download">Download</a></div>` : '<div class="hint">No file uploaded yet.</div>'}
      ${readOnly ? '' : '<input type="file" id="doc-file-input" accept=".pdf,.doc,.docx" style="margin-top:6px;">'}
      <button class="btn secondary" id="doc-download-gdrive" style="margin-top:8px;">Download Document (legacy archive)</button>
    </div>
    ${canWrite() ? `<div class="field">
      <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
        <input type="checkbox" id="f-pending-deletion" ${doc.pending_deletion ? 'checked' : ''}> Mark this document for deletion
      </label>
      <input data-f="pending_deletion_note" placeholder="Reason (optional)" value="${esc(doc.pending_deletion_note)}" style="margin-top:6px;">
    </div>` : ''}
    <div class="btn-row">
      ${canWrite() ? '<button class="btn" id="doc-save">Save changes</button>' : ''}
      <button class="btn secondary" id="doc-tracking-sheet">Print Tracking Sheet</button>
      ${canDelete() ? '<button class="btn danger" id="doc-delete">Delete permanently</button>' : ''}
    </div>
    <details open style="margin-top:14px;">
      <summary class="hint" style="cursor:pointer;">Legacy data (read-only, kept for reference)</summary>
      <div class="field-grid wide" style="margin-top:8px;">
        <div class="field"><label>Legacy category</label><input value="${esc(doc.legacy_category)}" disabled></div>
        <div class="field"><label>Legacy author</label><input value="${esc(doc.legacy_author)}" disabled></div>
        <div class="field"><label>Legacy topic</label><input value="${esc(doc.legacy_topic)}" disabled></div>
        <div class="field"><label>Legacy status</label><input value="${esc(doc.legacy_status)}" disabled></div>
        <div class="field"><label>Legacy file name</label><input value="${esc(doc.legacy_file_name)}" disabled></div>
      </div>
    </details>
  `;

  document.getElementById('doc-tracking-sheet').addEventListener('click', () => renderTrackingSheet(id));
  document.getElementById('doc-download-gdrive').addEventListener('click', () => downloadFromGDrive(doc.file_name));
  if (doc.storage_path) {
    document.getElementById('doc-download').addEventListener('click', async e => {
      e.preventDefault();
      const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
      if (data?.signedUrl) window.open(data.signedUrl, '_blank');
    });
  }
  if (!canWrite()) return;

  function collectFields() {
    const out = {};
    box.querySelectorAll('[data-f]').forEach(el => out[el.dataset.f] = el.value === '' ? null : el.value);
    out.has_video = out.has_video === 'true';
    out.recipient = Array.from(box.querySelectorAll('.f-doc-recipient:checked')).map(c => c.value);
    if (out.recipient.length === 0) out.recipient = null;
    out.pending_deletion = document.getElementById('f-pending-deletion').checked;
    return out;
  }
  function updatePreview() {
    const vals = collectFields();
    document.getElementById('filename-preview').textContent = computeFileName({ document_id: doc.document_id, ...vals });
  }
  box.querySelectorAll('[data-f="title"],[data-f="category"],[data-f="author"],[data-f="main_topic"],[data-f="ref_date"],[data-f="ref_period"]')
    .forEach(el => el.addEventListener('input', updatePreview));

  document.getElementById('doc-save').addEventListener('click', async () => {
    const vals = collectFields();
    const baseName = computeFileName({ document_id: doc.document_id, ...vals });
    const finalName = await uniqueFileName(baseName, doc.document_id);
    vals.file_name = finalName;

    const fileInput = document.getElementById('doc-file-input');
    let storagePath = doc.storage_path;
    if (fileInput.files && fileInput.files[0]) {
      if (storagePath && storagePath !== finalName) {
        await sb.storage.from(BUCKET).remove([storagePath]);
      }
      await withStatus(sb.storage.from(BUCKET).upload(finalName, fileInput.files[0], { upsert: true }), 'Uploading file...');
      storagePath = finalName;
    } else if (storagePath && storagePath !== finalName) {
      await sb.storage.from(BUCKET).move(storagePath, finalName);
      storagePath = finalName;
    }
    vals.storage_path = storagePath;

    await withStatus(sb.from('documents').update(vals).eq('document_id', id), 'Saving...');
    if (document.getElementById('dash-grid')) await refreshDashGrid();
    await renderDocDetail(id);
  });

  if (!canDelete()) return;
  document.getElementById('doc-delete').addEventListener('click', async () => {
    if (!confirm(`Permanently delete document #${id}? This cannot be undone.`)) return;
    if (doc.storage_path) await sb.storage.from(BUCKET).remove([doc.storage_path]);
    await withStatus(sb.from('documents').delete().eq('document_id', id));
    SelectedDocId = null;
    if (document.getElementById('dash-grid')) await refreshDashGrid();
    await renderDocDetail(null);
  });
}

async function createNewDocument() {
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.document_id || 0) + 1;
  await withStatus(sb.from('documents').insert({ document_id: newId, workflow_status: 'ENTR', legacy_migrated: false }));
  SelectedDocId = String(newId);
  await refreshDashGrid();
  await renderDocDetail(SelectedDocId);
}

// ================= PRINT TRACKING SHEET =================

async function renderTrackingSheet(id) {
  const main = document.getElementById('main');
  const rows = await withStatus(sb.from('documents').select('*').eq('document_id', id));
  const doc = rows[0];
  if (!doc) return;
  main.innerHTML = `
    <div class="btn-row no-print">
      <button class="btn secondary" id="back-to-dash">&larr; Back</button>
      <button class="btn" id="print-tracking">Print / Export PDF</button>
    </div>
    <div class="report-view" style="max-width:800px;margin:0 auto;">
      <h2>Focolare Urdu Archive - Document Tracking Sheet</h2>
      <table style="margin-bottom:16px;">
        <tr><th style="width:30%;">Document ID</th><td>${esc(doc.document_id)}</td></tr>
        <tr><th>Title</th><td>${esc(doc.title)}</td></tr>
        <tr><th>Category</th><td>${esc(labelOf(CATEGORIES, doc.category))}</td></tr>
        <tr><th>Author</th><td>${esc(labelOf(AUTHORS, doc.author))}</td></tr>
        <tr><th>Main topic</th><td>${esc(labelOf(MAIN_TOPICS, doc.main_topic))}</td></tr>
        <tr><th>Recipient(s)</th><td>${(doc.recipient || []).map(c => esc(labelOf(RECIPIENTS, c))).join(', ')}</td></tr>
        <tr><th>Original language</th><td>${esc(labelOf(LANGS, doc.original_lang))}</td></tr>
        <tr><th>Reference date / period</th><td>${esc(doc.ref_date)} ${esc(doc.ref_period)}</td></tr>
        <tr><th>File name</th><td>${esc(doc.file_name)}</td></tr>
        <tr><th>Physical box</th><td>${esc(doc.physical_box)}</td></tr>
      </table>
      <h3 style="margin-bottom:6px;">Process Registry</h3>
      <table>
        <thead><tr><th>#</th><th>Step</th><th>Description (what must be done)</th><th>Date</th><th>Signature</th></tr></thead>
        <tbody>${TRACKING_STEPS.map((s, i) => `<tr><td>${i + 1}</td><td>${esc(s[1])}</td><td>${esc(s[2])}</td><td style="min-width:90px;">&nbsp;</td><td style="min-width:120px;">&nbsp;</td></tr>`).join('')}</tbody>
      </table>
      <h3 style="margin:16px 0 6px;">Additional Notes</h3>
      <div style="border-top:1px solid #999;height:20px;"></div>
      <div style="border-top:1px solid #999;height:20px;margin-top:20px;"></div>
      <div style="border-top:1px solid #999;height:20px;margin-top:20px;"></div>
    </div>
    <style>@media print { @page { size: A4; } }</style>
  `;
  document.getElementById('back-to-dash').addEventListener('click', () => renderTab('dashboard'));
  document.getElementById('print-tracking').addEventListener('click', () => window.print());
}

// ================= PRINT REPORTS =================

let ReportFilters = { category: '', main_topic: '', author: '', recipient: '', workflow_status: '', from: '', to: '' };

function renderReportsView(main) {
  main.innerHTML = `
    <div class="panel no-print">
      <h2>Print Reports</h2>
      <div class="field-grid">
        <div class="field"><label>Category</label><select id="r-category">${optionsHtml(CATEGORIES, '', true)}</select></div>
        <div class="field"><label>Main topic</label><select id="r-main_topic">${optionsHtml(MAIN_TOPICS, '', true)}</select></div>
        <div class="field"><label>Author</label><select id="r-author">${optionsHtml(AUTHORS, '', true)}</select></div>
        <div class="field"><label>Recipient</label><select id="r-recipient">${optionsHtml(RECIPIENTS, '', true)}</select></div>
        <div class="field"><label>Workflow status</label><select id="r-status">${optionsHtml(STATUSES, '', true)}</select></div>
        <div class="field"><label>Date from</label><input id="r-from" type="date"></div>
        <div class="field"><label>Date to</label><input id="r-to" type="date"></div>
      </div>
      <div class="btn-row">
        <button class="btn" id="r-generate">Generate</button>
        <button class="btn secondary" id="r-print">Print / Export PDF</button>
      </div>
    </div>
    <div id="report-area"></div>
    <style>@media print { @page { size: A4 landscape; } }</style>
  `;
  document.getElementById('r-generate').addEventListener('click', generateFilteredReport);
  document.getElementById('r-print').addEventListener('click', () => window.print());
}

async function generateFilteredReport() {
  const area = document.getElementById('report-area');
  area.innerHTML = '<div class="empty-msg">Loading...</div>';
  const category = document.getElementById('r-category').value;
  const mainTopic = document.getElementById('r-main_topic').value;
  const author = document.getElementById('r-author').value;
  const recipient = document.getElementById('r-recipient').value;
  const status = document.getElementById('r-status').value;
  const from = document.getElementById('r-from').value;
  const to = document.getElementById('r-to').value;

  let q = sb.from('documents').select('*', { count: 'exact' });
  if (category) q = q.eq('category', category);
  if (mainTopic) q = q.eq('main_topic', mainTopic);
  if (author) q = q.eq('author', author);
  if (status) q = q.eq('workflow_status', status);
  if (recipient) q = q.overlaps('recipient', [recipient]);
  if (from) q = q.gte('ref_date', from);
  if (to) q = q.lte('ref_date', to);
  q = q.order('document_id');

  const { data: rows, count } = await withStatusCount(q, 'Generating report...');
  if (!rows.length) { area.innerHTML = '<div class="empty-msg">No documents match these filters.</div>'; return; }

  const body = rows.map(r => `<tr><td>${esc(r.document_id)}</td><td>${esc(r.title)}</td><td>${esc(labelOf(CATEGORIES, r.category))}</td>
    <td>${esc(labelOf(AUTHORS, r.author))}</td><td>${(r.recipient || []).map(c => labelOf(RECIPIENTS, c)).join(', ')}</td>
    <td>${esc(r.ref_date)}</td><td>${esc(labelOf(STATUSES, r.workflow_status))}</td><td>${esc(r.physical_box)}</td></tr>`).join('');
  area.innerHTML = `<div class="report-view">
    <h2>Filtered Document Report</h2>
    <div class="hint" style="margin-bottom:8px;">Total documents: ${count}</div>
    <table><thead><tr><th>ID</th><th>Title (EN)</th><th>Category</th><th>Author</th><th>Recipient(s)</th><th>Ref. date</th><th>Workflow status</th><th>Physical box</th></tr></thead>
    <tbody>${body}</tbody></table>
  </div>`;
}

// ================= LIBRI (preserved, legacy fields) =================

async function renderLibriView(main) {
  const books = await withStatus(sb.from('documents').select('book').not('book', 'is', null));
  const distinctBooks = Array.from(new Set(books.map(b => b.book))).filter(Boolean).sort();
  main.innerHTML = `
    <div class="panel">
      <h2>Libri</h2>
      <div class="field" style="max-width:320px;">
        <label>Select book</label>
        <select id="book-select">
          <option value="">-- choose a book --</option>
          ${distinctBooks.map(b => `<option value="${esc(b)}" ${b === SelectedBookName ? 'selected' : ''}>${esc(b)}</option>`).join('')}
        </select>
      </div>
      <div class="btn-row">
        <button class="btn" id="book-report">Book report</button>
        <button class="btn" id="book-report-ita">Book Italian report</button>
        <button class="btn secondary no-print" id="print-btn2">Print / Export PDF</button>
      </div>
      <div id="book-list"></div>
      <div id="citation-box" class="field" style="margin-top:10px;">
        <label>Citation (click a row to generate it)</label>
        <textarea id="citation-text" readonly></textarea>
        <button class="btn secondary" id="copy-citation" style="margin-top:6px;">Copy to clipboard</button>
      </div>
      <div id="report-area"></div>
    </div>`;
  document.getElementById('print-btn2').addEventListener('click', () => window.print());
  document.getElementById('book-select').addEventListener('change', e => { SelectedBookName = e.target.value; refreshBookList(); });
  document.getElementById('book-report').addEventListener('click', () => showBookReport('Book'));
  document.getElementById('book-report-ita').addEventListener('click', () => showBookReport('Book Italian'));
  document.getElementById('copy-citation').addEventListener('click', () => {
    const t = document.getElementById('citation-text'); t.select(); document.execCommand('copy');
  });
  await refreshBookList();
}

async function refreshBookList() {
  const listEl = document.getElementById('book-list');
  if (!SelectedBookName) { listEl.innerHTML = '<div class="empty-msg">Select a book to see its linked documents.</div>'; return; }
  const rows = await withStatus(sb.from('documents').select('*, topics(class)').eq('book', SelectedBookName));
  rows.sort((a, b) => (a.ref_date || '').localeCompare(b.ref_date || '') || (a.legacy_topic || '').localeCompare(b.legacy_topic || '') || (a.to_whom || '').localeCompare(b.to_whom || ''));
  listEl.innerHTML = `<div class="grid-wrap"><table class="grid">
    <thead><tr><th>ID</th><th>Title</th><th>Original</th><th>Author</th><th>To whom</th><th>Place</th><th>Date</th><th>Hayat #</th></tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.document_id)}">
      <td>${esc(r.document_id)}</td><td>${esc(r.title)}</td><td>${esc(r.original_title)}</td><td>${esc(r.legacy_author)}</td>
      <td>${esc(r.to_whom)}</td><td>${esc(r.place)}</td><td>${esc(r.ref_date)}</td><td>${esc(r.hayat_issue)}</td></tr>`).join('')}</tbody>
  </table></div>`;
  listEl.querySelectorAll('tbody tr').forEach(tr => tr.addEventListener('click', () => {
    const row = rows.find(r => String(r.document_id) === tr.dataset.id);
    document.getElementById('citation-text').value = buildCitation(row);
  }));
}

function buildCitation(doc) {
  const fileorgtitle = doc.original_title ? `(${doc.original_title})` : '';
  const fileauthor = doc.legacy_author ? ` - ${doc.legacy_author}` : '';
  const filetowhom = doc.to_whom ? ` - ${doc.to_whom}` : '';
  const fileplace = doc.place ? ` - ${doc.place}` : '';
  const filedate = doc.ref_date ? ` - ${doc.ref_date}` : '';
  const filehayat = doc.hayat_issue ? ` - Hayat ${doc.hayat_issue}` : '';
  return `${doc.document_id} - ${doc.title || ''}${fileorgtitle}${fileauthor}${filetowhom}${fileplace}${filedate}${filehayat}`;
}

async function showBookReport(caption) {
  const area = document.getElementById('report-area');
  if (!SelectedBookName) { area.innerHTML = '<div class="empty-msg">Select a book first.</div>'; return; }
  const rows = await withStatus(sb.from('documents').select('*, topics!inner(topic_eng,class,topic_order,class_order), document_categories!inner(document_category)').eq('book', SelectedBookName));
  rows.sort((a, b) => (a.topics.class_order - b.topics.class_order) || (a.topics.topic_order - b.topics.topic_order));
  const flat = rows.map(r => ({ ...r, Class: r.topics.class }));
  area.innerHTML = reportTable(`${caption}: ${SelectedBookName}`, flat,
    [{ key: 'Class', label: 'Class' }, { key: 'legacy_topic', label: 'Topic' }, { key: 'title', label: 'Title' },
     { key: 'legacy_author', label: 'Author' }, { key: 'ref_date', label: 'Date' }, { key: 'book_page', label: 'Book page' }], 'Class');
}

function reportTable(title, rows, cols, groupBy) {
  if (rows.length === 0) return `<div class="report-view"><h2>${esc(title)}</h2><div class="empty-msg">No results.</div></div>`;
  let body = '';
  let lastGroup;
  for (const r of rows) {
    if (groupBy && r[groupBy] !== lastGroup) {
      lastGroup = r[groupBy];
      body += `<tr><td colspan="${cols.length}" class="group-header">${esc(lastGroup || '(none)')}</td></tr>`;
    }
    body += '<tr>' + cols.map(c => `<td>${esc(r[c.key])}</td>`).join('') + '</tr>';
  }
  return `<div class="report-view"><h2>${esc(title)}</h2><div class="hint" style="margin-bottom:8px;">${rows.length} rows</div>
    <table><thead><tr>${cols.map(c => `<th>${esc(c.label)}</th>`).join('')}</tr></thead><tbody>${body}</tbody></table></div>`;
}

// ================= PROCESSI (preserved) =================

async function renderProcessiView(main) {
  const cats = await withStatus(sb.from('process_categories').select('*').order('process_category'));
  main.innerHTML = `
    <div class="panel">
      <h2>Process definitions</h2>
      <div class="split">
        <div>
          <h3>Process categories</h3>
          <div class="grid-wrap"><table class="grid" id="proc-cat-grid">
            <thead><tr><th>Category</th><th>Description</th></tr></thead>
            <tbody>${cats.map(c => `<tr data-id="${esc(c.category_id)}" class="${String(c.category_id) === String(SelectedCategoryId) ? 'selected' : ''}">
              <td>${esc(c.process_category)}</td><td>${esc(c.description)}</td></tr>`).join('')}</tbody>
          </table></div>
        </div>
        <div id="proc-steps"></div>
      </div>
    </div>`;
  main.querySelectorAll('#proc-cat-grid tbody tr').forEach(tr => tr.addEventListener('click', async () => {
    SelectedCategoryId = tr.dataset.id;
    main.querySelectorAll('#proc-cat-grid tbody tr').forEach(r => r.classList.toggle('selected', r === tr));
    await renderProcessSteps();
  }));
  if (SelectedCategoryId) await renderProcessSteps();
  else document.getElementById('proc-steps').innerHTML = '<div class="empty-msg">Select a process category.</div>';
}

async function renderProcessSteps() {
  const box = document.getElementById('proc-steps');
  const rows = await withStatus(sb.from('process').select('*').eq('category', SelectedCategoryId).order('step'));
  box.innerHTML = `<h3>Process steps</h3>
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Step</th><th>Description</th><th>Date</th></tr></thead>
      <tbody>${rows.map(r => `<tr><td>${esc(r.step)}</td><td>${esc(r.description)}</td><td>${esc(r.dateline)}</td></tr>`).join('')}</tbody>
    </table></div>`;
}

// ================= HAYAT INDEX (preserved, extraction writes new fields) =================

async function renderHayatView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Hayat Index</h2>
      <p class="hint">Rows not yet "extracted" can be turned into a new document with one click, already using the new English fields.</p>
      <div class="searchbar"><input id="hayat-search" placeholder="Search by title, author, topic..."></div>
      <div class="grid-wrap"><table class="grid" id="hayat-grid"></table></div>
    </div>`;
  document.getElementById('hayat-search').addEventListener('input', e => refreshHayatGrid(e.target.value));
  await refreshHayatGrid('');
}

async function refreshHayatGrid(filterText) {
  const grid = document.getElementById('hayat-grid');
  let query = sb.from('hayat_indice').select('*, document_categories(document_category)');
  if (filterText && filterText.trim()) {
    const like = likeSafe(filterText.trim());
    query = query.or(`titolo.ilike.${like},title.ilike.${like},autore.ilike.${like},argomento.ilike.${like}`);
  }
  const rows = await withStatus(query);
  rows.sort((a, b) => (a.idtranscription || 0) - (b.idtranscription || 0) || (a.autore || '').localeCompare(b.autore || '') || (a.mese_anno || '').localeCompare(b.mese_anno || ''));
  grid.innerHTML = `<thead><tr><th></th><th>Id</th><th>Month-Year</th><th>Page</th><th>Category</th><th>Branch</th><th>Author</th><th>Title</th><th>Topic</th><th>Extracted</th></tr></thead>
    <tbody>${rows.map(r => `<tr data-id="${esc(r.id)}">
      <td>${(!r.estratto && canWrite()) ? `<button class="btn" data-extract="${esc(r.id)}" style="padding:3px 8px;">Extract &rarr;</button>` : ''}</td>
      <td>${esc(r.id)}</td><td>${esc(r.mese_anno)}</td><td>${esc(r.pagina)}</td><td>${esc(r.document_categories?.document_category)}</td>
      <td>${esc(r.branca)}</td><td>${esc(r.autore)}</td><td>${esc(r.titolo)}</td><td>${esc(r.argomento)}</td><td>${esc(r.estratto)}</td></tr>`).join('')}</tbody>`;
  grid.querySelectorAll('[data-extract]').forEach(btn => btn.addEventListener('click', async e => {
    e.stopPropagation();
    await extractHayatRow(btn.dataset.extract);
    await refreshHayatGrid(filterText);
  }));
}

const HAYAT_CATEGORY_MAP = { Tlk: 'DISC', Mdt: 'MEDI', Lkp: 'LINK', Wol: 'WORD', Exp: 'EXPE' };
function mapHayatAuthor(name) {
  if (!name) return 'OFFI';
  if (name === 'Chiara') return 'CHIA';
  return 'OTHR';
}

async function extractHayatRow(hayatId) {
  const rows = await withStatus(sb.from('hayat_indice').select('*').eq('id', hayatId));
  const row = rows[0];
  if (!row || row.estratto) return;
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.document_id || 0) + 1;
  const category = HAYAT_CATEGORY_MAP[row.category] || 'MISC';
  const author = mapHayatAuthor(row.autore);
  const draft = {
    document_id: newId, title: row.title, legacy_category: row.category, legacy_author: row.autore,
    hayat_index_ref: row.id, to_whom: row.branca, original_title: row.titolo,
    hayat_issue: `${row.mese_anno}p.${row.pagina}`, legacy_topic: row.argomento,
    category, author, main_topic: 'GENR', secondary_tags: row.argomento,
    original_lang: 'ITA', workflow_status: 'ENTR', legacy_migrated: false,
  };
  draft.file_name = await uniqueFileName(computeFileName(draft), null);
  await withStatus(sb.from('documents').insert(draft));
  await withStatus(sb.from('hayat_indice').update({ estratto: today() }).eq('id', hayatId));
  alert(`Created document #${newId} from Hayat entry #${hayatId}. You can complete it from the Dashboard.`);
}

// ================= USERS (admin only) =================

async function renderUsersView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  const rows = await withStatus(sb.from('user_roles').select('*').order('email'));
  main.innerHTML = `
    <div class="panel">
      <h2>Users <span class="count-badge">${rows.length}</span></h2>
      <p class="hint">User = read/search only. Operator = can create and edit, and mark documents for deletion. Admin = can also delete permanently and manage roles.</p>
      <div class="grid-wrap"><table class="grid" id="users-grid">
        <thead><tr><th>Email</th><th>Role</th><th>Since</th><th></th></tr></thead>
        <tbody>${rows.map(r => `<tr data-uid="${esc(r.user_id)}">
          <td>${esc(r.email)}</td>
          <td><select class="role-select" data-uid="${esc(r.user_id)}">${optionsHtml([['user', 'User'], ['operator', 'Operator'], ['admin', 'Admin']], r.role, false)}</select></td>
          <td>${esc((r.created_at || '').slice(0, 10))}</td>
          <td><button class="btn danger remove-user-btn" data-uid="${esc(r.user_id)}" data-email="${esc(r.email)}" style="padding:4px 10px;">Remove access</button></td></tr>`).join('')}</tbody>
      </table></div>
      <p class="hint" style="margin-top:8px;">"Remove access" drops the person back to no role at all (they lose the app entirely until re-registered or re-added) - it does not delete their login/auth account. To fully delete an account, use the Supabase Dashboard (Authentication → Users).</p>
    </div>`;
  main.querySelectorAll('.role-select').forEach(sel => sel.addEventListener('change', async () => {
    await withStatus(sb.from('user_roles').update({ role: sel.value }).eq('user_id', sel.dataset.uid), 'Updating role...');
  }));
  main.querySelectorAll('.remove-user-btn').forEach(btn => btn.addEventListener('click', async () => {
    if (!confirm(`Remove access for ${btn.dataset.email}? They will lose all access to the app until re-added (their login account itself is not deleted).`)) return;
    await withStatus(sb.from('user_roles').delete().eq('user_id', btn.dataset.uid), 'Removing...');
    await renderUsersView(main);
  }));
}

// ================= OPTIONS (admin only - edit dropdown lists) =================

const OPTION_LIST_LABELS = {
  category: 'Category', author: 'Author', main_topic: 'Main topic',
  recipient: 'Recipient', original_lang: 'Original language', workflow_status: 'Workflow status',
};
let OptionsSelectedList = 'category';

async function renderOptionsView(main) {
  if (!isAdmin()) { main.innerHTML = '<div class="empty-msg">Admin access required.</div>'; return; }
  main.innerHTML = `
    <div class="panel">
      <h2>Options <span class="hint">— edit the dropdown lists used across the app</span></h2>
      <div class="field" style="max-width:280px;">
        <label>List</label>
        <select id="opt-list-select">${OPTION_LIST_NAMES.map(n => `<option value="${n}" ${n === OptionsSelectedList ? 'selected' : ''}>${OPTION_LIST_LABELS[n]}</option>`).join('')}</select>
      </div>
      <div id="opt-editor"></div>
    </div>`;
  document.getElementById('opt-list-select').addEventListener('change', e => { OptionsSelectedList = e.target.value; renderOptionsEditor(); });
  await renderOptionsEditor();
}

async function renderOptionsEditor() {
  const box = document.getElementById('opt-editor');
  const rows = await withStatus(sb.from('option_lists').select('*').eq('list_name', OptionsSelectedList).order('sort_order'));
  box.innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Code</th><th>Label</th><th>Sort order</th><th></th></tr></thead>
      <tbody>${rows.map(r => `<tr data-code="${esc(r.code)}">
        <td><input class="opt-code" value="${esc(r.code)}" style="width:90px;"></td>
        <td><input class="opt-label" value="${esc(r.label)}"></td>
        <td><input class="opt-order" type="number" value="${esc(r.sort_order)}" style="width:70px;"></td>
        <td><button class="btn secondary opt-save" style="padding:4px 10px;">Save</button>
            <button class="btn danger opt-delete" style="padding:4px 10px;">Delete</button></td>
      </tr>`).join('')}
      <tr data-code="">
        <td><input class="opt-code" placeholder="NEWCODE" style="width:90px;"></td>
        <td><input class="opt-label" placeholder="New option label"></td>
        <td><input class="opt-order" type="number" value="${rows.length + 1}" style="width:70px;"></td>
        <td><button class="btn opt-add" style="padding:4px 10px;">Add</button></td>
      </tr>
      </tbody>
    </table></div>
    <p class="hint" style="margin-top:8px;">Changing or removing a code here does not update documents that already use the old code — edit those separately if needed.</p>
  `;
  box.querySelectorAll('tr[data-code]:not([data-code=""])').forEach(tr => {
    const originalCode = tr.dataset.code;
    tr.querySelector('.opt-save').addEventListener('click', async () => {
      const code = tr.querySelector('.opt-code').value.trim();
      const label = tr.querySelector('.opt-label').value.trim();
      const sortOrder = parseInt(tr.querySelector('.opt-order').value, 10) || 0;
      if (!code || !label) { alert('Code and label are required.'); return; }
      if (code !== originalCode) {
        await withStatus(sb.from('option_lists').delete().eq('list_name', OptionsSelectedList).eq('code', originalCode));
      }
      await withStatus(sb.from('option_lists').upsert({ list_name: OptionsSelectedList, code, label, sort_order: sortOrder }), 'Saving...');
      await loadOptions();
      await renderOptionsEditor();
    });
    tr.querySelector('.opt-delete').addEventListener('click', async () => {
      if (!confirm(`Remove option "${originalCode}" from this list?`)) return;
      await withStatus(sb.from('option_lists').delete().eq('list_name', OptionsSelectedList).eq('code', originalCode));
      await loadOptions();
      await renderOptionsEditor();
    });
  });
  const addRow = box.querySelector('tr[data-code=""]');
  addRow.querySelector('.opt-add').addEventListener('click', async () => {
    const code = addRow.querySelector('.opt-code').value.trim();
    const label = addRow.querySelector('.opt-label').value.trim();
    const sortOrder = parseInt(addRow.querySelector('.opt-order').value, 10) || 0;
    if (!code || !label) { alert('Code and label are required.'); return; }
    await withStatus(sb.from('option_lists').insert({ list_name: OptionsSelectedList, code, label, sort_order: sortOrder }), 'Adding...');
    await loadOptions();
    await renderOptionsEditor();
  });
}

// ================= MATCH REVIEW =================

const ITALIAN_MONTHS = { gennaio:1, febbraio:2, marzo:3, aprile:4, maggio:5, giugno:6, luglio:7, agosto:8, settembre:9, ottobre:10, novembre:11, dicembre:12 };
function pdvApproxDate(r) {
  if (!r.mese || !r.anno) return null;
  const m = ITALIAN_MONTHS[r.mese.trim().split(' ')[0].toLowerCase()];
  const y = parseInt(r.anno, 10);
  if (!m || !y) return null;
  return new Date(y, m - 1, 15).getTime();
}
function rankByDateProximity(refDate, refs, dateField) {
  // Ranks by closeness to refDate, but never drops a candidate just because it (or the
  // document) has no date - those are appended at the end instead, so the full list stays
  // browsable and a genuine match with a missing/blank date can still be found and assigned.
  if (!refDate) return refs;
  const target = new Date(refDate).getTime();
  const withDate = refs.filter(r => r[dateField]);
  const withoutDate = refs.filter(r => !r[dateField]);
  withDate.sort((a, b) => Math.abs(new Date(a[dateField]).getTime() - target) - Math.abs(new Date(b[dateField]).getTime() - target));
  return [...withDate, ...withoutDate];
}
function rankByYearMonthProximity(refDate, refs) {
  if (!refDate) return refs;
  const target = new Date(refDate).getTime();
  const withDate = refs.map(r => ({ r, d: pdvApproxDate(r) })).filter(x => x.d !== null);
  const withoutDate = refs.filter(r => pdvApproxDate(r) === null);
  withDate.sort((a, b) => Math.abs(a.d - target) - Math.abs(b.d - target));
  return [...withDate.map(x => x.r), ...withoutDate];
}

const MATCH_LISTS = {
  collegamenti: {
    label: 'Collegamenti (Italian titles)',
    docFilter: d => d.category === 'LINK' && !d.italian_title,
    refTable: 'ref_collegamenti',
    refLabel: r => `${r.data || '?'} — ${r.titolo}${r.luogo ? ' (' + r.luogo + ')' : ''}`,
    refValue: r => r.titolo,
    rank: (doc, refs) => rankByDateProximity(doc.ref_date, refs, 'data'),
  },
  video: {
    label: 'Video index',
    docFilter: d => !d.video_ref,
    refTable: 'ref_video_index',
    refLabel: r => `${r.numero} — ${r.descrizione}${r.data ? ' (' + r.data + ')' : ''}`,
    refValue: r => r.numero,
    rank: (doc, refs) => rankByDateProximity(doc.ref_date, refs, 'data'),
  },
  pdv: {
    label: 'Parola di Vita',
    docFilter: d => d.category === 'WORD' && !d.pdv_ref,
    refTable: 'ref_parola_di_vita',
    refLabel: r => `${r.mese} — ${r.versetto}`,
    refValue: r => r.link,
    rank: (doc, refs) => rankByYearMonthProximity(doc.ref_date, refs),
  },
};

let MatchListKey = 'collegamenti';
let MatchQueue = [];
let MatchIndex = 0;
let MatchRefRows = [];

async function renderMatchReviewView(main) {
  main.innerHTML = `
    <div class="panel">
      <h2>Match Review</h2>
      <p class="hint">Step through documents one at a time and assign the best-matching cross-reference. Candidates are pre-ranked by date; use search to find others.</p>
      <div class="field" style="max-width:320px;">
        <label>List</label>
        <select id="match-list-select">${Object.entries(MATCH_LISTS).map(([k, v]) => `<option value="${k}" ${k === MatchListKey ? 'selected' : ''}>${v.label}</option>`).join('')}</select>
      </div>
      <div id="match-body"></div>
    </div>`;
  document.getElementById('match-list-select').addEventListener('change', async e => {
    MatchListKey = e.target.value;
    MatchIndex = 0;
    await loadMatchQueue();
    renderMatchBody();
  });
  await loadMatchQueue();
  renderMatchBody();
}

async function loadMatchQueue() {
  const cfg = MATCH_LISTS[MatchListKey];
  const docs = await withStatus(sb.from('documents').select('document_id,title,category,author,ref_date,italian_title,video_ref,pdv_ref,pending_deletion').order('document_id'));
  MatchQueue = docs.filter(d => !d.pending_deletion && cfg.docFilter(d));
  MatchRefRows = await withStatus(sb.from(cfg.refTable).select('*'));
}

function renderMatchBody() {
  const box = document.getElementById('match-body');
  const cfg = MATCH_LISTS[MatchListKey];
  if (MatchQueue.length === 0) {
    box.innerHTML = `<div class="empty-msg">Nothing to review for this list right now — either all matched, or no documents currently qualify.</div>`;
    return;
  }
  if (MatchIndex >= MatchQueue.length) {
    box.innerHTML = `<div class="empty-msg">All done for this list for now! Switch lists, or check back after new documents are added.</div>`;
    return;
  }
  const doc = MatchQueue[MatchIndex];
  const ranked = cfg.rank(doc, MatchRefRows);
  box.innerHTML = `
    <div class="hint" style="margin:10px 0;">${MatchIndex + 1} of ${MatchQueue.length} remaining in this list</div>
    <div class="split">
      <div class="panel" style="margin:0;">
        <div class="btn-row" style="margin-top:0;"><button class="btn secondary" id="match-skip">Skip →</button></div>
        <p class="hint">Full document record - fix or fill in anything you notice while matching.</p>
        <div id="doc-detail" style="max-height:70vh;overflow-y:auto;"></div>
      </div>
      <div>
        <h3>Candidates <span class="hint" id="match-candidates-count"></span></h3>
        <input id="match-search" placeholder="Search candidates...">
        <div id="match-candidates" style="max-height:60vh;overflow-y:auto;margin-top:8px;"></div>
      </div>
    </div>
  `;
  renderCandidates(ranked, cfg, doc);
  renderDocDetail(doc.document_id);
  document.getElementById('match-skip').addEventListener('click', () => { MatchIndex++; renderMatchBody(); });
  document.getElementById('match-search').addEventListener('input', e => {
    const term = e.target.value.toLowerCase();
    const filtered = term
      ? MatchRefRows.filter(r => cfg.refLabel(r).toLowerCase().includes(term))
      : ranked;
    renderCandidates(filtered, cfg, doc);
  });
}

function renderCandidates(list, cfg, doc) {
  const box = document.getElementById('match-candidates');
  document.getElementById('match-candidates-count').textContent = `(${list.length} total, most likely first)`;
  if (list.length === 0) { box.innerHTML = '<div class="empty-msg">No candidates found.</div>'; return; }
  box.innerHTML = list.map((r, i) => `<div class="panel" style="margin-bottom:8px;padding:10px;">
    <div style="font-size:13px;">${esc(cfg.refLabel(r))}</div>
    <button class="btn" data-i="${i}" style="margin-top:6px;padding:4px 10px;">Assign</button>
  </div>`).join('');
  box.querySelectorAll('[data-i]').forEach(btn => btn.addEventListener('click', async () => {
    const r = list[btn.dataset.i];
    const field = MatchListKey === 'collegamenti' ? 'italian_title' : MatchListKey === 'video' ? 'video_ref' : 'pdv_ref';
    await withStatus(sb.from('documents').update({ [field]: cfg.refValue(r) }).eq('document_id', doc.document_id), 'Saving...');
    MatchIndex++;
    renderMatchBody();
  }));
}

// ================= BULK IMPORT =================

function slugifyTitle(s) {
  return (s || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 40) || 'untitled';
}

function titleFromFilename(name) {
  const noExt = name.replace(/\.[a-z0-9]+$/i, '');
  const cleaned = noExt.replace(/[_\-]+/g, ' ').replace(/\s+/g, ' ').trim();
  return cleaned.charAt(0).toUpperCase() + cleaned.slice(1);
}

// Best-effort: a full day.month.year pattern becomes an exact ref_date; a bare 4-digit
// year becomes ref_period instead, since that's honestly all we know from the filename.
function extractDateFromFilename(name) {
  let m = name.match(/(\d{1,2})[.\-\/](\d{1,2})[.\-\/](\d{4})(?!\d)/);
  if (m) {
    const [, d, mo, y] = m.map(Number);
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      const dt = new Date(y, mo - 1, d);
      if (!isNaN(dt)) return { ref_date: `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`, ref_period: null };
    }
  }
  m = name.match(/(\d{1,2})[.\-\/](\d{1,2})[.\-\/](\d{2})(?!\d)/);
  if (m) {
    const [, d, mo, y2] = m.map(Number);
    const y = y2 < 50 ? 2000 + y2 : 1900 + y2;
    if (mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
      const dt = new Date(y, mo - 1, d);
      if (!isNaN(dt)) return { ref_date: `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`, ref_period: null };
    }
  }
  m = name.match(/(19|20)\d{2}/);
  if (m) return { ref_date: null, ref_period: m[0] };
  return { ref_date: null, ref_period: null };
}

function normalizeForCompare(s) {
  return (s || '').toLowerCase().replace(/\.[a-z0-9]+$/, '').replace(/[^a-z0-9]+/g, ' ').trim();
}
function titleOverlapScore(a, b) {
  const wa = new Set(normalizeForCompare(a).split(' ').filter(w => w.length > 2));
  const wb = new Set(normalizeForCompare(b).split(' ').filter(w => w.length > 2));
  if (wa.size === 0 || wb.size === 0) return 0;
  let inter = 0;
  for (const w of wa) if (wb.has(w)) inter++;
  return inter / Math.min(wa.size, wb.size);
}

let BulkImportRows = [];
let BulkImportDirHandle = null;

async function renderBulkImportView(main) {
  const supported = 'showDirectoryPicker' in window;
  main.innerHTML = `
    <div class="panel">
      <h2>Bulk Import</h2>
      <p class="hint">Pick a local folder of PDF files to catalogue in one go. Each file gets a new catalogue number and a record with status "Entry" - category/author/topic are left for you to fill in afterwards from the Dashboard, which will also complete the file name automatically at that point.</p>
      ${supported ? '' : '<div class="empty-msg">This feature needs Chrome or Edge (it uses a browser API to read and rename local files that Firefox/Safari do not support).</div>'}
      ${supported ? '<div class="btn-row"><button class="btn" id="bi-pick-folder">Select folder…</button></div>' : ''}
      <div id="bi-body"></div>
    </div>`;
  if (!supported) return;
  document.getElementById('bi-pick-folder').addEventListener('click', scanBulkImportFolder);
}

async function scanBulkImportFolder() {
  const body = document.getElementById('bi-body');
  let dirHandle;
  try {
    dirHandle = await window.showDirectoryPicker({ mode: 'readwrite' });
  } catch (e) {
    return; // user cancelled the picker
  }
  BulkImportDirHandle = dirHandle;
  body.innerHTML = '<div class="empty-msg">Scanning folder…</div>';

  const files = [];
  for await (const entry of dirHandle.values()) {
    if (entry.kind === 'file' && entry.name.toLowerCase().endsWith('.pdf')) files.push(entry);
  }
  if (files.length === 0) {
    body.innerHTML = '<div class="empty-msg">No PDF files found in that folder.</div>';
    return;
  }

  const existing = await withStatus(sb.from('documents').select('document_id,title,file_name,legacy_file_name').order('document_id'), 'Checking for duplicates...');
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  let nextId = (maxRows[0]?.document_id || 0) + 1;

  BulkImportRows = files.map(entry => {
    const title = titleFromFilename(entry.name);
    const { ref_date, ref_period } = extractDateFromFilename(entry.name);
    let bestMatch = null, bestScore = 0;
    for (const doc of existing) {
      const score = Math.max(titleOverlapScore(title, doc.title), titleOverlapScore(entry.name, doc.file_name), titleOverlapScore(entry.name, doc.legacy_file_name));
      if (score > bestScore) { bestScore = score; bestMatch = doc; }
    }
    const isDuplicateSuspect = bestScore >= 0.5;
    const document_id = nextId++;
    const newFileName = `${String(document_id).padStart(5, '0')}-${slugifyTitle(title)}.pdf`;
    return {
      entry, originalName: entry.name, document_id, title, ref_date, ref_period, newFileName,
      isDuplicateSuspect, duplicateOf: bestMatch, included: !isDuplicateSuspect,
    };
  });

  renderBulkImportTable();
}

function renderBulkImportTable() {
  const body = document.getElementById('bi-body');
  body.innerHTML = `
    <div class="hint" style="margin:10px 0;">${BulkImportRows.length} PDF files found. Uncheck any you don't want to import (possible duplicates are pre-unchecked - review them).</div>
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th></th><th>Catalogue #</th><th>Original name</th><th>Title (from filename)</th><th>Date/period detected</th><th>New file name</th><th>Duplicate?</th></tr></thead>
      <tbody>${BulkImportRows.map((r, i) => `<tr>
        <td><input type="checkbox" class="bi-include" data-i="${i}" ${r.included ? 'checked' : ''}></td>
        <td>${String(r.document_id).padStart(5, '0')}</td>
        <td>${esc(r.originalName)}</td>
        <td>${esc(r.title)}</td>
        <td>${esc(r.ref_date || r.ref_period || '—')}</td>
        <td>${esc(r.newFileName)}</td>
        <td>${r.isDuplicateSuspect ? `<span class="count-badge" style="background:var(--danger);color:#fff;">possible dup of #${esc(r.duplicateOf.document_id)} "${esc(r.duplicateOf.title)}"</span>` : ''}</td>
      </tr>`).join('')}</tbody>
    </table></div>
    <div class="btn-row">
      <button class="btn" id="bi-apply">OK — catalogue the checked files</button>
    </div>
    <div id="bi-progress"></div>
  `;
  body.querySelectorAll('.bi-include').forEach(cb => cb.addEventListener('change', () => {
    BulkImportRows[cb.dataset.i].included = cb.checked;
  }));
  document.getElementById('bi-apply').addEventListener('click', applyBulkImport);
}

async function applyBulkImport() {
  const toImport = BulkImportRows.filter(r => r.included);
  if (toImport.length === 0) { alert('Nothing checked to import.'); return; }
  if (!confirm(`Catalogue ${toImport.length} document(s) and rename the files on disk? This cannot be easily undone.`)) return;

  const progress = document.getElementById('bi-progress');
  const today = new Date().toISOString().slice(0, 10);
  let done = 0, failed = 0;
  for (const r of toImport) {
    progress.innerHTML = `<div class="hint">Processing ${done + failed + 1} of ${toImport.length}: ${esc(r.originalName)}…</div>`;
    try {
      await withStatus(sb.from('documents').insert({
        document_id: r.document_id, title: r.title, workflow_status: 'ENTR',
        catalog_date: today, ref_date: r.ref_date, ref_period: r.ref_period,
        file_name: r.newFileName, legacy_migrated: false,
      }));
      const file = await r.entry.getFile();
      const newHandle = await BulkImportDirHandle.getFileHandle(r.newFileName, { create: true });
      const writable = await newHandle.createWritable();
      await writable.write(await file.arrayBuffer());
      await writable.close();
      await BulkImportDirHandle.removeEntry(r.originalName);
      done++;
    } catch (e) {
      failed++;
      r.error = e.message;
    }
  }
  progress.innerHTML = `<div class="panel"><b>Done.</b> Catalogued ${done} document(s).${failed ? ` ${failed} failed - see below.` : ''}</div>
    ${failed ? `<ul>${toImport.filter(r => r.error).map(r => `<li>${esc(r.originalName)}: ${esc(r.error)}</li>`).join('')}</ul>` : ''}`;
  BulkImportRows = BulkImportRows.filter(r => !r.included || r.error);
  if (BulkImportRows.length) renderBulkImportTable();
}

boot();
