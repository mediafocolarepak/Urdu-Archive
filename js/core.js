// Supabase client, shared mutable state, generic helpers, auth, and the tab dispatcher.
// Every other module imports from this one only (never from each other) to keep the
// import graph a simple star and avoid circular-import bugs.

export const SUPABASE_URL = 'https://tvabpsxfwofiqriwbolz.supabase.co';
export const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2YWJwc3hmd29maXFyaXdib2x6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0NTQ2OTksImV4cCI6MjEwMjAzMDY5OX0.ltxl-K6lHKp1NC3-t9xzMOML9JVyqrpcQjkHkauiGBY';
export const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
export const BUCKET = 'archive-files';

// Legacy PDF archive: files live in a shared, publicly-readable Google Drive folder
// and are looked up by exact file_name match (the API key is restricted to Drive API
// + this site's domain in Google Cloud Console, so it's safe to ship in client code).
const GDRIVE_API_KEY = 'AIzaSyD_AMo9JFxS3jf6Wv1Cg3TRyMvXkzVYFEQ';
const GDRIVE_FOLDER_ID = '1r9-UM5hJ6xQYm24RzpK4Zo74x1XKyCIq';

export async function downloadFromGDrive(fileName) {
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

// ---------- Shared mutable state ----------
// ES module `let` bindings can be read live from other modules but not reassigned from
// outside the module that declared them. Everything mutable lives as properties on this
// one exported object instead, so every module can read AND write it directly (State.x = y).

export const State = {
  // fixed vocabularies, loaded from option_lists at sign-in
  categories: [], authors: [], mainTopics: [], recipients: [], langs: [], statuses: [],
  mediaTypes: [], provenances: [], collections: [], qualities: [],
  currentRole: 'user',
  appShown: false,
  selectedDocId: null,
  selectedCategoryId: null,
  dashFilters: { search: '', idSearch: '', category: '', author: '', main_topic: '', workflow_status: '', collection: '', recipient: [], legacyOnly: false, pendingOnly: false },
  dashPage: 0,
  dashSort: { col: 'document_id', asc: false },
  reportFilters: { category: '', main_topic: '', author: '', recipient: '', workflow_status: '', from: '', to: '' },
  matchListKey: 'collegamenti',
  matchQueue: [],
  matchIndex: 0,
  matchRefRows: [],
  bulkImportRows: [],
  bulkImportDirHandle: null,
  optionsSelectedList: 'category',
};

export const DASH_PAGE_SIZE = 25;
export const DASH_SORTABLE = { document_id: 'ID', title: 'Title', category: 'Category', author: 'Author', ref_date: 'Ref. date', workflow_status: 'Status' };

export const OPTION_LIST_NAMES = ['category', 'author', 'main_topic', 'recipient', 'original_lang', 'workflow_status', 'media_type', 'provenance', 'collection', 'quality'];
export const OPTION_LIST_LABELS = {
  category: 'Category', author: 'Author', main_topic: 'Main topic', recipient: 'Recipient',
  original_lang: 'Language', workflow_status: 'Workflow status', media_type: 'Media type',
  provenance: 'Provenance', collection: 'Collection', quality: 'Quality',
};

export async function loadOptions() {
  const rows = await withStatus(sb.from('option_lists').select('*').order('sort_order'));
  const byList = {}; for (const n of OPTION_LIST_NAMES) byList[n] = [];
  for (const r of rows) { if (byList[r.list_name]) byList[r.list_name].push([r.code, r.label]); }
  State.categories = byList.category; State.authors = byList.author; State.mainTopics = byList.main_topic;
  State.recipients = byList.recipient; State.langs = byList.original_lang; State.statuses = byList.workflow_status;
  State.mediaTypes = byList.media_type; State.provenances = byList.provenance;
  State.collections = byList.collection; State.qualities = byList.quality;
}

export function labelOf(list, code) { const f = list.find(x => x[0] === code); return f ? f[1] : (code || ''); }
export function optionsHtml(list, value, allowEmpty) {
  return (allowEmpty ? '<option value=""></option>' : '') +
    list.map(([c, l]) => `<option value="${c}" ${c === value ? 'selected' : ''}>${l}</option>`).join('');
}

export function canWrite() { return State.currentRole === 'operator' || State.currentRole === 'admin'; }
export function canDelete() { return State.currentRole === 'admin'; }
export function isAdmin() { return State.currentRole === 'admin'; }

// ---------- Generic helpers ----------

export function today() {
  const d = new Date();
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}
export function esc(v) {
  if (v === null || v === undefined) return '';
  return String(v).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}
export function likeSafe(s) { return '%' + s.replace(/[%,()]/g, '') + '%'; }

export function slugify(title) {
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
export function yearOf(refDate, refPeriod) {
  if (refDate) { const m = refDate.match(/^(\d{4})-/); if (m) return m[1]; }
  if (refPeriod) { const m = refPeriod.match(/(\d{4})/); if (m) return m[1]; }
  return 'XXXX';
}
export function computeFileName(doc) {
  const id = String(doc.document_id).padStart(5, '0');
  const cat = doc.category || 'MISC';
  const auth = doc.author || 'OTHR';
  const topic = doc.main_topic || 'GENR';
  const prov = doc.provenance ? `-${doc.provenance}` : '';
  const slug = slugify(doc.title);
  const year = yearOf(doc.ref_date, doc.ref_period);
  return `${id}-${cat}-${auth}-${topic}${prov}-${slug}-${year}.pdf`;
}
export async function uniqueFileName(base, excludeDocId) {
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

// Creates a fresh single-item Work for a new document and returns its work_id.
export async function createWorkFor(title) {
  const rows = await withStatus(sb.from('works').insert({ canonical_title: title }).select('work_id'));
  return rows[0].work_id;
}

export function setStatus(text, isError) {
  const label = document.getElementById('dirty-label');
  const dot = document.getElementById('dirty-dot');
  if (label) label.textContent = text;
  if (dot) dot.className = 'dot' + (isError ? ' dirty' : '');
}

export async function withStatus(promise, busyText) {
  setStatus(busyText || 'Working...', false);
  const { data, error } = await promise;
  if (error) { setStatus('Error: ' + error.message, true); throw error; }
  setStatus('Connected', false);
  return data;
}
export async function withStatusCount(promise, busyText) {
  setStatus(busyText || 'Working...', false);
  const { data, error, count } = await promise;
  if (error) { setStatus('Error: ' + error.message, true); throw error; }
  setStatus('Connected', false);
  return { data, count };
}

export function reportTable(title, rows, cols, groupBy) {
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

export const TRACKING_STEPS = [
  ['ENTR', 'Entry', 'Document identified and registered in DB. Original source acquired.'],
  ['TYP', 'Typing', 'Transcription/OCR completed. Initial Urdu draft prepared (unrevised).'],
  ['PROF', 'Proofing', 'First formal reading done. Spelling, punctuation, and diacritics checked against original.'],
  ['CORR', 'Correction', 'Errors found in Proofing have been corrected. Second draft ready.'],
  ['APPR', 'Approved', 'Final review by a senior terminologist. Text declared doctrinally and stylistically accurate.'],
  ['STOR', 'Stored', 'Master file stored in read-only repository. Physical copy filed in box.'],
];

// ---------- AUTH ----------

export async function boot(renderDashboardTab) {
  const { data: { session } } = await sb.auth.getSession();
  if (session) { await showApp(session, renderDashboardTab); } else { showLogin(); }
  sb.auth.onAuthStateChange(async (event, session) => {
    if (session && !State.appShown) await showApp(session, renderDashboardTab);
    else if (session) document.getElementById('user-email').textContent = session.user.email;
    else { State.appShown = false; showLogin(); }
  });
}

function showLogin() {
  document.getElementById('login-screen').style.display = 'flex';
  document.getElementById('app').style.display = 'none';
}

async function showApp(session, renderDashboardTab) {
  State.appShown = true;
  State.selectedDocId = null; State.selectedCategoryId = null;
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('app').style.display = 'flex';

  const { data: roleRows } = await sb.from('user_roles').select('role').eq('user_id', session.user.id);
  State.currentRole = roleRows && roleRows[0] ? roleRows[0].role : 'user';
  document.getElementById('user-email').textContent = `${session.user.email} (${State.currentRole})`;

  await loadOptions();
  renderDashboardTab();
}

// Called explicitly from app.js, not run automatically on import - tests.html imports
// core.js too (for the pure helper functions) but has none of these DOM elements.
export function wireAuthButtons() {
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
}
