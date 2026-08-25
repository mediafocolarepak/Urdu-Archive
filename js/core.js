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
  mediaTypes: [], sources: [], collections: [], qualities: [], operators: [],
  currentRole: 'user',
  appShown: false,
  selectedDocId: null,
  selectedCategoryId: null,
  dashFilters: { search: '', idSearch: '', category: '', author: '', main_topic: '', workflow_status: '', collection: '', recipient: '', language: '', legacyOnly: false, pendingOnly: false },
  dashUserDefaultsApplied: false,
  dashSort: { col: 'document_id', asc: false },
  adminEditFilters: { search: '', idSearch: '', category: '', author: '', main_topic: '', workflow_status: '', collection: '', recipient: '', source: '', language: '', legacyOnly: false, pendingOnly: false },
  reportFilters: { category: '', main_topic: '', author: '', recipient: '', workflow_status: '', from: '', to: '' },
  matchFilters: { search: '', idSearch: '', category: '', author: '', workflow_status: '', recipient: '', collection: '', language: '' },
  matchSort: { col: 'document_id', asc: false },
  matchSelectedId: null,
  optionsSelectedList: 'category',
  docCollections: [],  // { document_id, collection_code, page_number } for the open document
  optionListsByName: {},  // option_lists rows grouped by list_name, as [code,label] pairs - generic lookup used by SessionCache/combobox
  hayatEditorEdition: '',
};

export const DASH_ROW_LIMIT = 5000;
export const DASH_SORTABLE = { document_id: 'ID', title: 'Title (EN)', original_title: 'Original title', author: 'Author', place: 'Place', category: 'Category' };

// hayat_author / hayat_argomento are deliberately separate from author / main_topic: those
// two keep their fixed, CHECK-constrained vocabularies (see 15_versions_editors_schema.sql),
// while the Hayat Editor's Autore/Argomento comboboxes are free-typing - a new value there
// must never risk violating the documents table's constraints on author/main_topic.
export const OPTION_LIST_NAMES = ['category', 'author', 'main_topic', 'recipient', 'language', 'workflow_status', 'media_type', 'source', 'collection', 'quality', 'operator', 'hayat_author', 'hayat_argomento'];
export const OPTION_LIST_LABELS = {
  category: 'Category', author: 'Author', main_topic: 'Main topic', recipient: 'Recipient',
  language: 'Language', workflow_status: 'Workflow status', media_type: 'Media type',
  source: 'Source', collection: 'Collection', quality: 'Quality', operator: 'Operator',
  hayat_author: 'Hayat: Autore', hayat_argomento: 'Hayat: Argomento',
};

export async function loadOptions() {
  const rows = await withStatus(sb.from('option_lists').select('*').order('sort_order'));
  const byList = {}; for (const n of OPTION_LIST_NAMES) byList[n] = [];
  for (const r of rows) { if (byList[r.list_name]) byList[r.list_name].push([r.code, r.label]); }
  State.categories = byList.category; State.authors = byList.author; State.mainTopics = byList.main_topic;
  State.recipients = byList.recipient; State.langs = byList.language; State.statuses = byList.workflow_status;
  State.mediaTypes = byList.media_type; State.sources = byList.source;
  State.collections = byList.collection; State.qualities = byList.quality; State.operators = byList.operator;
  State.optionListsByName = byList;
}

// Adds a code/label to an option_lists list if it isn't already there, then reloads State.
// Used for both a direct admin "add option" action and for SessionCache.persistUsed below.
export async function addOptionToList(listName, code, label) {
  if (!code) return;
  const rows = await withStatus(sb.from('option_lists').select('code').eq('list_name', listName));
  if (rows.some(r => r.code === code)) return;
  const sortOrder = rows.length + 1;
  await withStatus(sb.from('option_lists').insert({ list_name: listName, code, label: label || code, sort_order: sortOrder }));
  await loadOptions();
}

export async function getCollectionsForDocument(docId) {
  if (!docId) return [];
  return await withStatus(sb.from('document_collections').select('*').eq('document_id', docId).order('collection_code'));
}

// Replaces the full set of collection associations for a document in one go (delete + insert)
// rather than diffing - the set is always small, and this keeps the call site simple.
export async function saveDocumentCollections(docId, collectionRows) {
  await withStatus(sb.from('document_collections').delete().eq('document_id', docId));
  const toInsert = (collectionRows || []).filter(c => c.collection_code)
    .map(c => ({ document_id: docId, collection_code: c.collection_code, page_number: c.page_number || null }));
  if (toInsert.length) await withStatus(sb.from('document_collections').insert(toInsert));
}

// Session-only cache for option values typed in a combobox before they're actually saved to
// option_lists. Lets a value used in one row (e.g. a new Hayat "Argomento") show up as a
// suggestion in the next row immediately, without writing to the DB until the record is saved.
export const SessionCache = {
  values: {},  // { list_name: [{ code, label }] }
  add(listName, code, label) {
    if (!code) return;
    if (!this.values[listName]) this.values[listName] = [];
    if (!this.values[listName].some(v => v.code === code)) this.values[listName].push({ code, label: label || code });
  },
  getAll(listName) {
    const fromDb = State.optionListsByName[listName] || [];
    const fromCache = this.values[listName] || [];
    const merged = [...fromDb];
    for (const item of fromCache) {
      if (!merged.some(v => v[0] === item.code)) merged.push([item.code, item.label]);
    }
    return merged;
  },
  // Persists only the values actually used (passed in explicitly), each as [code,label];
  // usedValues = { list_name: [code,label][] }. Clears the cache once done.
  async persistUsed(usedValues) {
    for (const [listName, items] of Object.entries(usedValues || {})) {
      for (const [code, label] of items) await addOptionToList(listName, code, label);
    }
    this.values = {};
  },
  clear() { this.values = {}; },
};

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
  const slug = slugify(doc.title);
  return `${id}-${slug}.pdf`;
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

// The documents.author list is a small set of coarse buckets (CHIA/IGIN/KLAU/PAPA/OFFI/OTHR),
// unlike the free-text names in hayat_indice.autore - only "Chiara" is confidently mappable,
// everything else falls back to OTHR rather than guessing.
function mapHayatAuthor(name) {
  if (!name) return 'OFFI';
  if (name.trim().toLowerCase() === 'chiara') return 'CHIA';
  return 'OTHR';
}

// Shared by hayatindex.js (viewer) and hayateditor.js (grid editor) so the two "Extract"
// buttons behave identically. `row` is a hayat_indice record (or the current in-grid edit of
// one). category codes now match documents.category 1:1 (both are the original Access cat_id
// codes), so no translation table is needed here any more. Returns the new document_id.
export async function extractHayatRowToDocument(row) {
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.document_id || 0) + 1;
  const workId = await createWorkFor(row.titolo || row.title);
  const draft = {
    document_id: newId, title: row.title || row.titolo, original_title: row.titolo || row.title,
    original_author: row.autore,
    hayat_index_ref: row.id, to_whom: row.branca,
    hayat_issue: `${row.mese_anno || ''}p.${row.pagina || ''}`,
    category: row.category || null, author: mapHayatAuthor(row.autore), main_topic: 'GENR', secondary_tags: row.argomento,
    ref_period: row.mese_anno || null,
    language: 'URD', workflow_status: 'ENTR', legacy_migrated: false,
    source: 'HAYAT', media_type: 'DOC', work_id: workId,
  };
  draft.file_name = await uniqueFileName(computeFileName(draft), null);
  await withStatus(sb.from('documents').insert(draft));
  await withStatus(sb.from('document_collections').insert({ document_id: newId, collection_code: 'HAYAT', page_number: row.pagina || null }));
  await withStatus(sb.from('hayat_indice').update({ estratto: today(), idtranscription: newId }).eq('id', row.id));
  return newId;
}

// ---------- Work merge / preferred-version helpers (Work Consolidation + document detail) ----------

// Merges the Works of sourceDocIds into the Work of targetDocId: every document currently
// sharing a Work with a sourceDocId is reassigned to the target's work_id, and the
// now-empty source Works are deleted. Matches what matchreview.js's "Same document - merge"
// already does for a single pair, generalized to many-at-once for Work Consolidation.
export async function mergeWorks(targetDocId, sourceDocIds) {
  const ids = [targetDocId, ...sourceDocIds];
  const docs = await withStatus(sb.from('documents').select('document_id,work_id').in('document_id', ids));
  const targetWorkId = docs.find(d => String(d.document_id) === String(targetDocId))?.work_id;
  if (!targetWorkId) throw new Error(`Document #${targetDocId} not found or has no Work.`);
  const sourceWorkIds = [...new Set(docs.filter(d => String(d.document_id) !== String(targetDocId)).map(d => d.work_id))]
    .filter(w => w && w !== targetWorkId);
  if (!sourceWorkIds.length) return targetWorkId;
  await withStatus(sb.from('documents').update({ work_id: targetWorkId }).in('work_id', sourceWorkIds));
  await withStatus(sb.from('works').delete().in('work_id', sourceWorkIds));
  return targetWorkId;
}

// Pulls a document out of its current Work into a brand new single-item Work of its own -
// undoes a bad merge without touching the other documents that stay behind.
export async function separateDocument(docId, newTitle) {
  const workId = await createWorkFor(newTitle);
  await withStatus(sb.from('documents').update({ work_id: workId, is_preferred: false }).eq('document_id', docId));
  return workId;
}

// Only one document per Work may be the preferred version - clear the others first.
export async function setPreferredVersion(docId, workId) {
  await withStatus(sb.from('documents').update({ is_preferred: false }).eq('work_id', workId));
  await withStatus(sb.from('documents').update({ is_preferred: true }).eq('document_id', docId));
}

// ---------- Title similarity (Bulk Import duplicate flagging + Work Consolidation suggestions) ----------

export function normalizeForCompare(s) {
  return (s || '').toLowerCase().replace(/\.[a-z0-9]+$/, '').replace(/[^a-z0-9]+/g, ' ').trim();
}
export function titleOverlapScore(a, b) {
  const wa = new Set(normalizeForCompare(a).split(' ').filter(w => w.length > 2));
  const wb = new Set(normalizeForCompare(b).split(' ').filter(w => w.length > 2));
  if (wa.size === 0 || wb.size === 0) return 0;
  let inter = 0;
  for (const w of wa) if (wb.has(w)) inter++;
  return inter / Math.min(wa.size, wb.size);
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
