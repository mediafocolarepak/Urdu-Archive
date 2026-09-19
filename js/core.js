// Supabase client, shared mutable state, generic helpers, auth, and the tab dispatcher.
// Every other module imports from this one only (never from each other) to keep the
// import graph a simple star and avoid circular-import bugs.

export const SUPABASE_URL = 'https://tvabpsxfwofiqriwbolz.supabase.co';
export const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2YWJwc3hmd29maXFyaXdib2x6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0NTQ2OTksImV4cCI6MjEwMjAzMDY5OX0.ltxl-K6lHKp1NC3-t9xzMOML9JVyqrpcQjkHkauiGBY';
export const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
export const BUCKET = 'archive-files';

// Debug escape hatch: lets a DevTools console diagnose issues against the real, already-
// authenticated session without creating a second Supabase client (which collides with this
// one over the same localStorage session key and can produce confusing, unrelated errors).
window.__sb = sb;

// Legacy PDF archive: files live in a shared, publicly-readable Google Drive folder
// and are looked up by exact file_name match (the API key is restricted to Drive API
// + this site's domain in Google Cloud Console, so it's safe to ship in client code).
const GDRIVE_API_KEY = 'AIzaSyD_AMo9JFxS3jf6Wv1Cg3TRyMvXkzVYFEQ';
const GDRIVE_FOLDER_ID = '1r9-UM5hJ6xQYm24RzpK4Zo74x1XKyCIq';

// "INPAGE Original Document" folder (My Drive/Urdu text archive/INPAGE Original Document) -
// holds the original .inp files, renamed with the document ID prefix, referenced by
// documents.original_inp_file_name. Same lookup mechanism as the PDF folder above, so it also
// needs "anyone with the link can view" sharing - the API key alone can't read a private
// folder. If downloads start failing with a permission-flavored error, check that setting.
const GDRIVE_INP_FOLDER_ID = '1LnZ2qo9bAQfyTnvU8V-0D9qLcXQX82DY';

async function findAndOpenInGDrive(folderId, fileName, notFoundHint) {
  if (!fileName) { alert('This document has no file name yet.'); return; }
  const q = `name='${fileName.replace(/'/g, "\\'")}' and '${folderId}' in parents and trashed=false`;
  const url = `https://www.googleapis.com/drive/v3/files?q=${encodeURIComponent(q)}&fields=files(id,name)&key=${GDRIVE_API_KEY}`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    if (data.error) { alert('Google Drive error: ' + data.error.message); return; }
    if (!data.files || data.files.length === 0) {
      alert(`"${fileName}" was not found yet in ${notFoundHint}.`);
      return;
    }
    window.open(`https://drive.google.com/file/d/${data.files[0].id}/view`, '_blank');
  } catch (e) {
    alert('Could not reach Google Drive: ' + e.message);
  }
}

export async function downloadFromGDrive(fileName) {
  await findAndOpenInGDrive(GDRIVE_FOLDER_ID, fileName, 'the Google Drive archive folder');
}

// Fetches a Drive file's raw bytes (not just opening the viewer, see findAndOpenInGDrive
// above) via the same public "anyone with the link" folder + API key, using ?alt=media.
// Returns null (never throws) so callers can fall back to a manual entry.
async function fetchGDriveFileBlob(folderId, fileName) {
  if (!fileName) return null;
  const q = `name='${fileName.replace(/'/g, "\\'")}' and '${folderId}' in parents and trashed=false`;
  const listUrl = `https://www.googleapis.com/drive/v3/files?q=${encodeURIComponent(q)}&fields=files(id,name)&key=${GDRIVE_API_KEY}`;
  try {
    const listRes = await fetch(listUrl);
    const listData = await listRes.json();
    const fileId = listData.files?.[0]?.id;
    if (!fileId) return null;
    const mediaRes = await fetch(`https://www.googleapis.com/drive/v3/files/${fileId}?alt=media&key=${GDRIVE_API_KEY}`);
    if (!mediaRes.ok) return null;
    return await mediaRes.blob();
  } catch {
    return null;
  }
}

// Counts the pages of a PDF Blob/File with pdf.js. Returns null (never throws) on any failure
// - callers should fall back to letting the person type the page count in by hand. Shared by
// readPdfPageCount below (fetches the blob from Storage/Drive first) and by anything that
// already holds the raw file locally (e.g. Bulk Import, reading straight off disk before the
// file is ever uploaded anywhere).
export async function readPdfPageCountFromBlob(blob) {
  if (!window.pdfjsLib || !blob) return null;
  try {
    const buf = await blob.arrayBuffer();
    const pdf = await pdfjsLib.getDocument({ data: buf }).promise;
    return pdf.numPages;
  } catch {
    return null;
  }
}

// Reads a document's PDF (Supabase Storage first, then the Google Drive archive folder as
// fallback - same precedence as downloadVersion in docdetail.js) and counts its pages with
// pdf.js. Returns null (never throws) on any failure - callers should fall back to letting
// the person type the page count in by hand.
export async function readPdfPageCount(doc) {
  if (!window.pdfjsLib) return null;
  let blob = null;
  if (doc.storage_path) {
    const { data } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
    if (data?.signedUrl) {
      try { const res = await fetch(data.signedUrl); if (res.ok) blob = await res.blob(); } catch {}
    }
  }
  if (!blob) blob = await fetchGDriveFileBlob(GDRIVE_FOLDER_ID, doc.file_name);
  if (!blob) return null;
  return readPdfPageCountFromBlob(blob);
}

// Same as readPdfPageCount, but reports WHERE it looked and why it gave up - used only by the
// Options -> Maintenance backfill tool, where "no PDF found" alone isn't enough to tell a
// missing storage_path from a Drive filename mismatch from a corrupt PDF pdf.js can't parse.
export async function readPdfPageCountDebug(doc, accessToken) {
  if (!window.pdfjsLib) return { pages: null, detail: 'pdf.js did not load' };
  if (doc.storage_path) {
    const { data, error } = await sb.storage.from(BUCKET).createSignedUrl(doc.storage_path, 60);
    if (error || !data?.signedUrl) return { pages: null, detail: `storage_path "${doc.storage_path}" - could not sign a URL` };
    let res;
    try { res = await fetch(data.signedUrl); } catch (e) { return { pages: null, detail: `storage_path "${doc.storage_path}" - network error: ${e.message}` }; }
    if (!res.ok) return { pages: null, detail: `storage_path "${doc.storage_path}" - fetch failed (${res.status})` };
    const pages = await readPdfPageCountFromBlob(await res.blob());
    return pages != null ? { pages, detail: null } : { pages: null, detail: `storage_path "${doc.storage_path}" - pdf.js could not parse the file` };
  }
  if (!doc.file_name) return { pages: null, detail: 'no storage_path and no file_name on record' };
  if (!accessToken) return { pages: null, detail: 'no Google Drive access token - Admin needs to grant Drive access first' };
  // OAuth Bearer, not the bare API key: `alt=media` (the actual byte download, as opposed to
  // the file-metadata search) is blocked by CORS when called unauthenticated - confirmed
  // 2026-09-02 from the browser's own CORS error, which the unauthenticated path had been
  // silently swallowing as a plain "not found" until this debug path exposed it.
  let blob;
  try {
    blob = await fetchGDriveFileBlobAuthed(GDRIVE_FOLDER_ID, doc.file_name, accessToken);
  } catch (e) {
    return { pages: null, detail: `Drive lookup for "${doc.file_name}" - ${e.message}` };
  }
  if (!blob) return { pages: null, detail: `not found on Drive by file_name "${doc.file_name}"` };
  const pages = await readPdfPageCountFromBlob(blob);
  return pages != null ? { pages, detail: null } : { pages: null, detail: `found "${doc.file_name}" on Drive, but pdf.js could not parse it` };
}

export async function downloadInpFromGDrive(fileName) {
  await findAndOpenInGDrive(GDRIVE_INP_FOLDER_ID, fileName, 'the Google Drive "INPAGE Original Document" folder');
}

// Uploads the finalized .inp for a newly-published document into the same "INPAGE Original
// Document" Drive folder as every other original - so a future correction task on this
// document can download it the same way (see downloadInpFromGDrive above). Returns the Drive
// file id; the caller is responsible for recording `fileName` in documents.renamed_inp_file_name.
export async function uploadInpToGDrive(fileName, blob, accessToken) {
  return await driveUploadOrReplace(GDRIVE_INP_FOLDER_ID, fileName, blob, accessToken);
}

// ---------- Google Drive write access (OAuth) ----------
// The legacy read lookup above only ever needs a public-folder API key. Writing/overwriting
// files needs a real user consent token instead - obtained via Google Identity Services (GIS),
// scoped to the InPage Converter tab only (that's the only feature that ever writes to Drive).
// OAuth 2.0 Client ID created in the same Google Cloud project as GDRIVE_API_KEY above,
// authorized for the https://mediafocolarepak.github.io origin.
const GOOGLE_OAUTH_CLIENT_ID = '67936040816-n0rq4f5eul93bk3cc7bauei7b3108g0j.apps.googleusercontent.com';
const GOOGLE_DRIVE_WRITE_SCOPE = 'https://www.googleapis.com/auth/drive';

let gisTokenClient = null;
let gisLoadPromise = null;
function loadGis() {
  if (window.google?.accounts?.oauth2) return Promise.resolve();
  if (!gisLoadPromise) {
    gisLoadPromise = new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = 'https://accounts.google.com/gsi/client';
      s.onload = resolve;
      s.onerror = () => reject(new Error('Could not load Google Sign-In.'));
      document.head.appendChild(s);
    });
  }
  return gisLoadPromise;
}

// Resolves to a short-lived OAuth access token with Drive write scope. Shows Google's
// account/consent prompt the first time in a page session; the app is in "Testing" mode in
// Google Cloud, so only the emails added as test users there can grant this.
export async function getDriveAccessToken() {
  await loadGis();
  if (!gisTokenClient) {
    gisTokenClient = window.google.accounts.oauth2.initTokenClient({
      client_id: GOOGLE_OAUTH_CLIENT_ID,
      scope: GOOGLE_DRIVE_WRITE_SCOPE,
      callback: () => {}, // overridden per-call below
    });
  }
  return new Promise((resolve, reject) => {
    gisTokenClient.callback = (resp) => {
      if (resp.error) reject(new Error(resp.error)); else resolve(resp.access_token);
    };
    gisTokenClient.requestAccessToken({ prompt: '' });
  });
}

async function driveFindFileId(folderId, fileName, accessToken) {
  const q = `name='${fileName.replace(/'/g, "\\'")}' and '${folderId}' in parents and trashed=false`;
  const res = await fetch(`https://www.googleapis.com/drive/v3/files?q=${encodeURIComponent(q)}&fields=files(id,name)`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const data = await res.json();
  if (data.error) throw new Error(data.error.message);
  return data.files && data.files[0] ? data.files[0].id : null;
}

// Downloads a Drive file's raw bytes with an OAuth Bearer token instead of the bare API key.
// The API-key-only equivalent (fetchGDriveFileBlob below) hits a CORS wall on `alt=media` -
// Google's servers don't send Access-Control-Allow-Origin for that endpoint when called
// unauthenticated, confirmed 2026-09-02 (readPdfPageCountDebug's diagnostics surfaced the
// browser's CORS error, which the unauthenticated path had been silently swallowing as a
// plain "not found"). An OAuth Bearer request doesn't have that problem - same as the
// existing upload path (driveUploadOrReplace) already relies on. Only wired into the
// Maintenance backfill tool (Admin-only) for now, not into the general readPdfPageCount below
// - that one runs for any Operator/Coordinator opening "Create Task" or the editor, and this
// app's Drive OAuth client is in Google Cloud "Testing" mode, so only whitelisted test-user
// Google accounts can grant it. Wiring OAuth into that broader path would surface a Google
// consent prompt (or a silent rejection) to people who have no reason to see one.
export async function fetchGDriveFileBlobAuthed(folderId, fileName, accessToken) {
  const fileId = await driveFindFileId(folderId, fileName, accessToken);
  if (!fileId) return null;
  const res = await fetch(`https://www.googleapis.com/drive/v3/files/${fileId}?alt=media`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) return null;
  return res.blob();
}

// Uploads `blob` as `fileName` into Drive folder `folderId`, overwriting an existing file of
// the same name in that folder if one exists, or creating it otherwise. Returns the file ID.
export async function driveUploadOrReplace(folderId, fileName, blob, accessToken) {
  const existingId = await driveFindFileId(folderId, fileName, accessToken);
  if (existingId) {
    const res = await fetch(`https://www.googleapis.com/upload/drive/v3/files/${existingId}?uploadType=media`, {
      method: 'PATCH',
      headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': blob.type || 'application/octet-stream' },
      body: blob,
    });
    if (!res.ok) throw new Error('Drive update failed: ' + (await res.text()));
    return existingId;
  }
  const metadata = { name: fileName, parents: [folderId] };
  const form = new FormData();
  form.append('metadata', new Blob([JSON.stringify(metadata)], { type: 'application/json' }));
  form.append('file', blob);
  const res = await fetch('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart', {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}` },
    body: form,
  });
  const data = await res.json();
  if (data.error) throw new Error(data.error.message);
  return data.id;
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
  myQualifications: new Set(),  // qualification_code set for the signed-in Operator (empty for other roles)
  myFavorites: new Set(),  // document_id set of the signed-in user's own "My Space" saves
  myBoards: new Set(),  // board_code set the signed-in user can post to (all of them for coordinator/admin)
  myMembershipType: null,  // user_profiles.membership_type, for the default board to open first
  boardsSelected: null,  // board_code of the currently open board on the Boards tab, remembered across re-renders
  appShown: false,
  selectedDocId: null,
  selectedCategoryId: null,
  dashFilters: { search: '', idSearch: '', category: '', author: '', main_topic: '', workflow_status: '', collection: '', recipient: '', source: '', language: '', legacyOnly: false, pendingOnly: false },
  dashUserDefaultsApplied: false,
  dashSort: { col: 'document_id', asc: false },
  reportFilters: { category: '', main_topic: '', author: '', recipient: '', workflow_status: '', from: '', to: '' },
  matchFilters: { search: '', idSearch: '', category: '', author: '', workflow_status: '', recipient: '', collection: '', language: '', source: '', orphansOnly: false },
  matchSort: { col: 'document_id', asc: false },
  matchSelectedId: null,
  usersSort: { col: 'full_name', asc: true },
  peopleSort: { col: 'full_name', asc: true },
  peopleFilter: { search: '', standing: '', atRiskOnly: false, department: '', role: '', qualification: '' },
  optionsSelectedList: 'category',
  deptEditorSelected: null,  // department_code currently shown in Options -> Departments
  myDeptSelected: null,  // department_code currently shown in My Department (mydepartment.js)
  myDeptCoordTab: 'open',  // sub-tab shown in My Department's Coordination task-flow panel
  mineTab: 'active',  // sub-tab shown in Tasks -> My Tasks (active/submitted/closed)
  docCollections: [],  // { document_id, collection_code, page_number } for the open document
  optionListsByName: {},  // option_lists rows grouped by list_name, as [code,label] pairs - generic lookup used by SessionCache/combobox
  hayatEditorEdition: '',
  taskPrefill: null,  // { title, description, document_id, document_pages } - set by chat.js's "Create task" button, consumed once by tasks.js's new-task form
  isFormatore: false,  // true if I'm a FORM department member - see boot(); mirrors is_any_formatore() server-side, used to gate "+ New formation path" and "My paths"
  formationSelectedPathId: null,
  myDepartments: [],  // [{department_code, is_lead}] for the signed-in user - see GOVERNANCE.md
  policyValues: {},  // policy_values key -> integer value, cached at boot (see 80_departments_and_people_decisions.sql)
  standing: 'active',  // user_roles.standing: active/watch/suspended
  boardPostingBlocked: false,  // user_roles.board_posting_blocked (84_boards_moderation.sql)
  boardPolicyAcked: false,  // whether user_profiles.board_policy_ack_at is set
  boardsSearch: '',  // free-text filter over the open board (84_boards_moderation.sql)
};

// Storage bucket for board post images (84_boards_moderation.sql) - separate from BUCKET
// (archive-files) because it's public-read and has a much smaller per-file size cap.
export const BOARD_MEDIA_BUCKET = 'board-media';

// Storage bucket for department-channel message images (94_department_messages.sql) - unlike
// BOARD_MEDIA_BUCKET this one is NOT public-read: the whole point of the department channel is
// that it's private to that department's members, so images in it must be too. Objects are keyed
// "<department_code>/<filename>"; the storage policies check the department_code prefix against
// is_dept_member()/is_dept_lead(), so reading one back needs a signed URL, not a public URL.
export const DEPARTMENT_MEDIA_BUCKET = 'department-media';

// Storage bucket for "Start Here" onboarding card thumbnails (95_onboarding_and_share_with_us.sql)
// - public-read like BOARD_MEDIA_BUCKET (outreach content, nothing sensitive), write-gated to
// Communication/Admin. Exported (not module-local like FORMATION_MEDIA_BUCKET) because both
// onboarding.js (reads cards) and mydepartment.js (Communication's card editor) need it.
export const ONBOARDING_MEDIA_BUCKET = 'onboarding-media';

// Records that the signed-in user has seen and accepted the board usage policy (js/boards.js
// shows it once before their first post). Never re-shown once set.
export async function ackBoardPolicy() {
  const { data: { user } } = await sb.auth.getUser();
  await withStatus(sb.from('user_profiles').update({ board_policy_ack_at: new Date().toISOString() }).eq('user_id', user.id));
  State.boardPolicyAcked = true;
}

export const DASH_ROW_LIMIT = 5000;
export const DASH_SORTABLE = { document_id: 'ID', title: 'Title (EN)', original_title: 'Original title', author: 'Author', place: 'Place', category: 'Category' };

// hayat_author / hayat_argomento are deliberately separate from author / main_topic: those
// two keep their fixed, CHECK-constrained vocabularies (see 15_versions_editors_schema.sql),
// while the Hayat Editor's Autore/Argomento comboboxes are free-typing - a new value there
// must never risk violating the documents table's constraints on author/main_topic.
export const OPTION_LIST_NAMES = ['category', 'author', 'main_topic', 'recipient', 'language', 'workflow_status', 'media_type', 'source', 'collection', 'quality', 'operator', 'hayat_author', 'hayat_argomento', 'membership_type', 'task_category', 'operator_qualification', 'collaboration_skill', 'report_type', 'extra_credit_reason', 'board', 'formation_audience', 'department', 'age_bracket'];
export const OPTION_LIST_LABELS = {
  category: 'Category', author: 'Author', main_topic: 'Main topic', recipient: 'Recipient',
  language: 'Language', workflow_status: 'Workflow status', media_type: 'Media type',
  source: 'Source', collection: 'Collection', quality: 'Quality', operator: 'Operator',
  hayat_author: 'Hayat: Autore', hayat_argomento: 'Hayat: Argomento',
  membership_type: 'Focolare membership type', task_category: 'Task category',
  operator_qualification: 'Operator qualifications',
  collaboration_skill: 'Join the Team: skills',
  report_type: 'Report a Problem: report type',
  extra_credit_reason: 'Task: extra credits reason',
  board: 'Formation boards',
  formation_audience: 'Formation paths: target audience',
  department: 'Departments',
  age_bracket: 'Age bracket (signup statistics)',
};

// Pre-selection of the board from a document's recipient (suggestion, not a constraint).
export const BOARD_FOR_RECIPIENT = { GEN4: 'GEN4', GEN3: 'GEN3', GEN2: 'GEN2', GMUW: 'GEN2', FAMI: 'FAMI',
  SACE: 'SACE', VESC: 'SACE', SUOR: 'SACE', VOLU: 'ADUL', FOCL: 'ADUL', UMAN: 'ADUL' };
// Board opened first, from the membership_type declared at signup. GEN doesn't distinguish
// age: opens on young people. null = first non-empty board.
export const DEFAULT_BOARD_FOR_MEMBERSHIP = { GEN: 'GEN2', FOCO: 'ADUL', MARR: 'FAMI', VOLU: 'ADUL', FRND: 'ADUL', SYMP: 'ADUL', OTHR: null };

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

export function canWrite() { return State.currentRole === 'operator' || State.currentRole === 'coordinator' || State.currentRole === 'admin'; }
export function canDelete() { return State.currentRole === 'admin'; }
export function isAdmin() { return State.currentRole === 'admin'; }
export function isCoordinator() { return State.currentRole === 'coordinator'; }
// Can review "Join the Team" applications - Coordinator (own queue) or Admin (everything).
// Kept broad on purpose (used by openFormationPostPopup etc. for "sees everything" access) -
// canReviewTeamApplications() below is the narrower, HR-based gate for the Team Applications
// tab specifically (GOVERNANCE.md phase 2a).
export function canReviewApplications() { return State.currentRole === 'coordinator' || State.currentRole === 'admin'; }

// Department membership - mirrors is_dept_member()/is_dept_lead() server-side (see
// 80_departments_and_people_decisions.sql). Client-side echoes only gate UI; RLS is the real gate.
export function isDeptMember(code) { return State.myDepartments.some(d => d.department_code === code); }
export function isDeptLead(code) { return State.myDepartments.some(d => d.department_code === code && d.is_lead); }
export function isAnyDeptLead() { return State.myDepartments.some(d => d.is_lead); }

// Team Applications tab visibility, moved from Coordinator to HR (GOVERNANCE.md phase 2a) -
// Coordinators still keep RLS access for now (migration 80 §8) until migration 81 removes it,
// so this is purely a client-side narrowing of who sees the tab, not the real gate.
export function canReviewTeamApplications() { return isDeptMember('HR') || isAdmin(); }

// Policy revision framework (GOVERNANCE.md §2.8/§6.6, migration 86) - mirrors
// can_propose_policy_change()/can_approve_policy_change() server-side; RLS is the real gate.
export function canProposePolicyChange(departmentCode) { return isAdmin() || isDeptLead(departmentCode); }
export function canApprovePolicyChange() { return isAdmin(); }

// ---------- Standing widget (credits + reputation, shown in the topbar for Operator+) ----------

const GOOD_PRACTICES = [
  'Claim a task only if you realistically expect to finish it by the due date you set.',
  'Can\'t make it after all? Use "Give up this task" early and honestly - it\'s not penalized, unlike letting it sit overdue.',
  'Only submit a task for review when you\'re confident it\'s actually ready.',
  'As a Revisor, judge the work in front of you, not who you think might have done it.',
  'Keep review notes specific and constructive - the operator will read them.',
];
const AVOID_LIST = [
  'Claiming several tasks "just in case" and letting most of them go overdue.',
  'Submitting incomplete or rushed work just to hit a deadline.',
  'Trying to guess or ask around about who did a task you\'re reviewing.',
  'Disrespectful or inappropriate behavior toward teammates - the System can reclaim a task for this, with a reputation penalty.',
];

function repClass(rep) { return rep >= 70 ? 'rep-good' : rep >= 40 ? 'rep-ok' : 'rep-low'; }

function renderStandingWidget(credits, reputation) {
  const box = document.getElementById('standing-widget');
  if (!box) return;
  box.style.display = 'flex';
  box.innerHTML = `
    <span class="credits-badge">${esc(credits ?? 0)} credits</span>
    <span class="rep-label hint">Good practice</span>
    <span class="rep-track"><span class="rep-fill ${repClass(reputation ?? 70)}" style="width:${Math.max(0, Math.min(100, reputation ?? 70))}%;"></span></span>
    <span class="rep-val">${esc(reputation ?? 70)}</span>
    <button class="btn secondary" id="good-practices-btn">Good practices</button>`;
  document.getElementById('good-practices-btn').addEventListener('click', showGoodPracticesModal);
}

function showGoodPracticesModal() {
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2>Good practices</h2>
      <ul class="good-practices-list">${GOOD_PRACTICES.map(p => `<li>${esc(p)}</li>`).join('')}</ul>
      <h2>Behaviors to avoid</h2>
      <ul class="avoid-list">${AVOID_LIST.map(p => `<li>${esc(p)}</li>`).join('')}</ul>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn" id="good-practices-close">Close</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('good-practices-close').addEventListener('click', () => backdrop.remove());
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
}

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
    ur_title: row.ur_title || null,
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
    if (event === 'PASSWORD_RECOVERY') { showRecoveryScreen(); return; }
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

  const { data: roleRows } = await sb.from('user_roles').select('role,credits,reputation,standing,board_posting_blocked').eq('user_id', session.user.id);
  const roleRow = roleRows && roleRows[0];
  State.currentRole = roleRow ? roleRow.role : 'user';
  State.standing = roleRow ? roleRow.standing : 'active';
  State.boardPostingBlocked = roleRow ? !!roleRow.board_posting_blocked : false;
  document.getElementById('user-email').textContent = `${session.user.email} (${State.currentRole})`;
  if (State.currentRole === 'operator' && roleRow) renderStandingWidget(roleRow.credits, roleRow.reputation);

  const { data: deptRows } = await sb.from('department_members').select('department_code,is_lead').eq('user_id', session.user.id);
  State.myDepartments = deptRows || [];
  const { data: policyRows } = await sb.from('policy_values').select('key,value');
  State.policyValues = {};
  for (const p of (policyRows || [])) State.policyValues[p.key] = p.value;

  State.myQualifications = new Set();
  if (State.currentRole === 'operator') {
    const { data: myQuals } = await sb.from('user_qualifications').select('qualification_code').eq('user_id', session.user.id);
    for (const q of (myQuals || [])) State.myQualifications.add(q.qualification_code);
  }

  const { data: favs } = await sb.from('user_favorites').select('document_id');
  State.myFavorites = new Set((favs || []).map(f => f.document_id));

  await loadOptions();

  State.myBoards = new Set();
  if (canReviewApplications()) {
    State.myBoards = new Set((State.optionListsByName.board || []).map(([code]) => code));
  } else {
    const { data: editorRows } = await sb.from('board_editors').select('board_code');
    State.myBoards = new Set((editorRows || []).map(r => r.board_code));
  }
  // The client-side mirror of the server's is_any_formatore() (80_departments_and_people_
  // decisions.sql), used to gate formation-path creation and the "My paths" section - "formatore"
  // has meant "member of the FORM department" since migration 80, not "has a board_editors row"
  // (that's now a separate, narrower thing: who curates a specific board, GOVERNANCE.md §2.3).
  // This used to still check board_editors directly, which drifted out of sync the moment 80
  // shipped: a FORM member added without ever being a board editor lost the "+ Path" button
  // client-side even though the server would have allowed them (found 2026-09-18, testing the
  // formation path redesign).
  State.isFormatore = State.myDepartments.some(d => d.department_code === 'FORM');
  const { data: profileRows } = await sb.from('user_profiles').select('membership_type,board_policy_ack_at').eq('user_id', session.user.id);
  State.myMembershipType = (profileRows && profileRows[0] && profileRows[0].membership_type) || null;
  State.boardPolicyAcked = !!(profileRows && profileRows[0] && profileRows[0].board_policy_ack_at);

  renderDashboardTab();
  await maybeShowSplash();
}

// ---------- Splash-screen announcements ----------
// Shown once per browser session (not on every tab switch), and again after a fresh
// login - the sessionStorage flag is set here and cleared by the sign-out handler below.

async function maybeShowSplash() {
  if (sessionStorage.getItem('splashShown')) return;
  const { data, error } = await sb.from('splash_messages').select('*').order('created_at', { ascending: false }).limit(1);
  if (error || !data || !data.length) { sessionStorage.setItem('splashShown', '1'); return; }
  const msg = data[0];
  const authorName = await getDisplayNameByEmail(msg.created_by_email);
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2>Announcements</h2>
      <div class="overlay-message">${esc(msg.message_text)}</div>
      <p class="hint">Posted by ${esc(authorName)} on ${esc((msg.created_at || '').slice(0, 10))}</p>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="splash-history-btn">Previous Announcements</button>
        <button class="btn" id="splash-dismiss-btn">Got it</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('splash-dismiss-btn').addEventListener('click', () => {
    backdrop.remove();
    sessionStorage.setItem('splashShown', '1');
  });
  document.getElementById('splash-history-btn').addEventListener('click', showSplashHistory);
}

// Read-only scrollable list of every past announcement, opened from the splash screen's
// "Previous Announcements" button. Stacks on top of the splash overlay (which stays open
// underneath) rather than replacing it, so "Got it" still works normally after closing this.
async function showSplashHistory() {
  const { data } = await sb.from('splash_messages').select('*').order('created_at', { ascending: false });
  const rows = data || [];
  const names = await Promise.all(rows.map(r => getDisplayNameByEmail(r.created_by_email)));
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2>Previous Announcements</h2>
      <div class="chat-thread" style="max-height:60vh;">
        ${rows.map((r, i) => `<div class="field" style="margin-bottom:8px;">
            <div class="hint">${esc((r.created_at || '').slice(0, 10))} &middot; ${esc(names[i])}</div>
            <div class="overlay-message">${esc(r.message_text)}</div>
          </div>`).join('') || '<div class="empty-msg">No previous announcements.</div>'}
      </div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn" id="splash-history-close-btn">Close</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('splash-history-close-btn').addEventListener('click', () => backdrop.remove());
}

// Resolves an email to its user_profiles.full_name, falling back to the email itself if no
// profile/name is on file (or if RLS blocks the read - anyone can read their own profile;
// reading another user's needs Coordinator/Admin, see 35_task_names.sql).
export async function getDisplayNameByEmail(email) {
  if (!email) return '';
  const { data } = await sb.from('user_profiles').select('full_name').eq('email', email).limit(1);
  return (data && data[0] && data[0].full_name) || email;
}

// Batch version for a list view showing several different people at once (Team Applications,
// admin Messages inbox, Tasks board) - one round trip per distinct email instead of resolving
// each row's name in isolation.
export async function nameMapForEmails(emails) {
  const unique = [...new Set(emails.filter(Boolean))];
  const names = await Promise.all(unique.map(e => getDisplayNameByEmail(e)));
  const map = {};
  unique.forEach((e, i) => { map[e] = names[i]; });
  return map;
}

// Same postability rule as document_is_postable() in 71_boards.sql - a client-side echo so a
// "+ Board" button doesn't appear only to have the insert rejected by RLS; that policy remains
// the real gate. Keep the two in sync. Lives here (not in docdetail.js) because myspace.js needs
// it too, and modules only import from core.js, never from each other.
export function isDocPostable(doc) {
  return doc.language === 'URD' && (doc.workflow_status == null || ['APPR', 'STOR', 'published'].includes(doc.workflow_status));
}

// Styled stand-in for the native confirm() dialog - resolves to true/false like confirm() does,
// so a call site just becomes `if (!(await confirmPopup('...'))) return;`. Two things confirm()
// can't do that this fixes: it never picks up the app's own styling (looks like a jarring OS
// dialog to someone who otherwise never sees one), and it silently blocks automated browser
// testing (PROJECT_HANDOFF_v18.md §3, v30.md §0.2 - the "residual, needs a human" item).
// Started in Formation Paths (owner's request, session of 2026-09-18) since that's the area
// meant to feel the least like "expert software"; other modules can adopt it the same way.
export function confirmPopup(message, { title = 'Are you sure?', danger = false, confirmLabel = 'Confirm' } = {}) {
  return new Promise(resolve => {
    document.getElementById('confirm-popup')?.remove();
    const backdrop = document.createElement('div');
    backdrop.id = 'confirm-popup';
    backdrop.className = 'overlay-backdrop';
    backdrop.innerHTML = `
      <div class="panel overlay-panel" style="max-width:420px;">
        <h2 style="margin-top:0;">${esc(title)}</h2>
        <p style="white-space:pre-wrap;">${esc(message)}</p>
        <div class="btn-row" style="justify-content:flex-end;">
          <button class="btn secondary" id="confirm-cancel">Cancel</button>
          <button class="btn ${danger ? 'danger' : ''}" id="confirm-ok">${esc(confirmLabel)}</button>
        </div>
      </div>`;
    document.body.appendChild(backdrop);
    const finish = ok => { backdrop.remove(); resolve(ok); };
    backdrop.addEventListener('click', e => { if (e.target === backdrop) finish(false); });
    document.getElementById('confirm-cancel').addEventListener('click', () => finish(false));
    document.getElementById('confirm-ok').addEventListener('click', () => finish(true));
  });
}

// Shared popup for a board post - used by docdetail.js's "+ Board" (post with a document) and
// boards.js's "+ New post" (free post). Lives here, not in either of them, because those two
// modules can't import each other (project convention: modules import only from core.js).
// { doc } prefills from a document; { boardCode } prefills the board directly; { post } switches
// this to an edit (update instead of insert).
// Posting is open to any signed-in, non-blocked user (84_boards_moderation.sql) - the board list
// here is every board, not just State.myBoards (which now means "boards I moderate"). A User's
// post lands 'pending' server-side (trg_force_board_post_pending); this popup never claims
// otherwise.
export function openBoardPostPopup({ doc = null, boardCode = null, post = null, onSaved } = {}) {
  document.getElementById('board-post-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'board-post-popup';
  backdrop.className = 'overlay-backdrop';
  const allBoards = State.optionListsByName.board || [];
  const suggested = post ? post.board_code : (boardCode || (doc && BOARD_FOR_RECIPIENT[(doc.recipient || [])[0]]));
  const preselect = allBoards.some(([code]) => code === suggested) ? suggested : (allBoards[0] && allBoards[0][0]) || '';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${post ? 'Edit post' : 'New post'}</h2>
      <p class="hint" id="bp-pending-hint" style="display:${!post && !State.myBoards.has(preselect) ? 'block' : 'none'};">Your post will be held for review by that board's editors before it appears to others.</p>
      <div class="field"><label>Board</label><select id="bp-board">${optionsHtml(allBoards, preselect, false)}</select></div>
      ${doc ? `<div class="field"><label>Document</label><div style="font-size:13px;padding:4px 0;">#${esc(doc.document_id)} &mdash; ${esc(doc.en_title) || '<span class="hint">(no title)</span>'}</div></div>` : ''}
      <div class="field"><label>Title</label><input id="bp-title" value="${esc(post ? post.title : (doc ? doc.en_title || '' : ''))}"></div>
      <div class="field"><label>Text</label><textarea id="bp-body" dir="auto" rows="8">${esc(post ? post.body : '')}</textarea></div>
      <div class="field"><label>Link <span class="hint">(optional)</span></label><input id="bp-link" placeholder="https://..." value="${esc(post ? post.link_url : '')}"></div>
      <div class="field"><label>Image <span class="hint">(optional${post && post.image_path ? ' - choose a file to replace the current one' : ''})</span></label><input id="bp-image" type="file" accept="image/*"></div>
      <div class="hint" id="bp-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="bp-cancel">Cancel</button>
        <button class="btn" id="bp-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('bp-cancel').addEventListener('click', () => backdrop.remove());
  if (!post) document.getElementById('bp-board').addEventListener('change', e => {
    document.getElementById('bp-pending-hint').style.display = State.myBoards.has(e.target.value) ? 'none' : 'block';
  });
  document.getElementById('bp-save').addEventListener('click', async () => {
    const board_code = document.getElementById('bp-board').value;
    const title = document.getElementById('bp-title').value.trim();
    const body = document.getElementById('bp-body').value.trim();
    const link_url = document.getElementById('bp-link').value.trim();
    const errBox = document.getElementById('bp-error');
    errBox.textContent = '';
    const document_id = doc ? doc.document_id : (post ? post.document_id : null);
    if (!title) { errBox.textContent = 'Title is required.'; return; }
    if (link_url && !/^https?:\/\//.test(link_url)) { errBox.textContent = 'Link must start with http:// or https://'; return; }
    let image_path = post ? post.image_path : null;
    const file = document.getElementById('bp-image').files[0];
    if (file) {
      const path = `${Date.now()}-${file.name}`.replace(/[^a-zA-Z0-9._-]/g, '_');
      const { error } = await sb.storage.from(BOARD_MEDIA_BUCKET).upload(path, file, { upsert: true });
      if (error) { errBox.textContent = 'Could not upload the image: ' + error.message; return; }
      image_path = path;
    }
    if (!document_id && !body && !link_url && !image_path) { errBox.textContent = 'A document, some text, a link, or an image is required.'; return; }
    const { data: { user } } = await sb.auth.getUser();
    const row = { board_code, document_id, title, body: body || null, link_url: link_url || null, image_path, posted_by_email: user.email };
    if (post) await withStatus(sb.from('board_posts').update(row).eq('id', post.id), 'Saving...');
    else await withStatus(sb.from('board_posts').insert(row), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// Shared popup for attaching a document to a formation path chapter - the formation-paths
// equivalent of openBoardPostPopup above, used by docdetail.js's "+ Path" (Dashboard) and
// myspace.js's "+ Path" (My Space). A path has a module/chapter hierarchy (migration 92 dropped
// the "Years" level that used to sit above modules - Path -> Module -> Chapter -> Post now) the
// formatore doesn't necessarily have open in front of them, so the popup asks for both levels
// with cascading dropdowns - each one also offering "+ Create new..." inline, so building the
// course structure never requires leaving the document you're looking at (owner's request,
// session of 2026-09-18: "si parte dai testi", the course is assembled around them, not the
// other way round). Lives here, not in formation.js, for the same reason as openBoardPostPopup:
// docdetail.js and myspace.js can't import from formation.js (project convention: modules import
// only from core.js). Only lets you pick a path you can actually write to (owner, co-author, or
// Coordinator/Admin) - the real gate is still formation_posts_write's RLS (92_formation_flatten_
// modules.sql).
export function openFormationPostPopup({ doc = null, onSaved } = {}) {
  document.getElementById('fp-add-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fp-add-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Add to formation path</h2>
      ${doc ? `<div class="field"><label>Document</label><div style="font-size:13px;padding:4px 0;">#${esc(doc.document_id)} &mdash; ${esc(doc.en_title) || '<span class="hint">(no title)</span>'}</div></div>` : ''}
      <div class="field"><label>Path</label><select id="fap-path"><option value="">Loading...</option></select></div>

      <div class="field"><label>Module</label><select id="fap-module" disabled><option value="">Select a path first</option></select></div>
      <div id="fap-new-module-fields" style="display:none;margin-left:12px;">
        <div class="field"><label>New module title</label><input id="fap-new-module-title" dir="auto"></div>
        <div class="field"><label>New module description <span class="hint">(optional)</span></label><textarea id="fap-new-module-desc" dir="auto" rows="2"></textarea></div>
      </div>

      <div class="field" id="fap-chapter-field" style="display:none;"><label>Chapter</label><select id="fap-chapter" disabled><option value="">Select a module first</option></select></div>
      <div id="fap-new-chapter-fields" style="display:none;margin-left:12px;">
        <div class="field"><label>New chapter title</label><input id="fap-new-chapter-title" dir="auto"></div>
      </div>

      <div class="field"><label>Title</label><input id="fap-title" value="${esc(doc ? doc.en_title || '' : '')}"></div>
      <div class="field"><label>Text</label><textarea id="fap-body" dir="auto" rows="6"></textarea></div>
      <div class="hint" id="fap-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fap-cancel">Cancel</button>
        <button class="btn" id="fap-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fap-cancel').addEventListener('click', () => backdrop.remove());

  const pathSel = document.getElementById('fap-path');
  const moduleSel = document.getElementById('fap-module');
  const chapterField = document.getElementById('fap-chapter-field');
  const chapterSel = document.getElementById('fap-chapter');
  const newModuleFields = document.getElementById('fap-new-module-fields');
  const newChapterFields = document.getElementById('fap-new-chapter-fields');

  function resetSelect(sel, placeholder) {
    sel.innerHTML = `<option value="">${placeholder}</option>`;
    sel.disabled = true;
  }

  sb.auth.getUser().then(async ({ data: { user } }) => {
    const paths = await withStatus(sb.from('formation_paths').select('id,title,owner_id'));
    const myPaths = paths.filter(p => p.owner_id === user.id || canReviewApplications());
    if (!myPaths.length) {
      pathSel.innerHTML = '<option value="">No paths available</option>';
      document.getElementById('fap-error').textContent = 'You have no formation path to add to yet - create one first in Formation Paths.';
      return;
    }
    pathSel.innerHTML = '<option value="">Select a path...</option>' + myPaths.map(p => `<option value="${p.id}">${esc(p.title)}</option>`).join('');
  });

  pathSel.addEventListener('change', async () => {
    resetSelect(moduleSel, 'Select a path first');
    chapterField.style.display = 'none';
    resetSelect(chapterSel, 'Select a module first');
    newModuleFields.style.display = 'none';
    newChapterFields.style.display = 'none';
    if (!pathSel.value) return;
    const modules = await withStatus(sb.from('formation_modules').select('id,title').eq('path_id', pathSel.value).order('sequence_number'));
    moduleSel.innerHTML = (modules.length ? '<option value="">Select a module...</option>' : '')
      + modules.map(m => `<option value="${m.id}">${esc(m.title)}</option>`).join('')
      + '<option value="__new__">+ Create new module...</option>';
    moduleSel.disabled = false;
    if (!modules.length) { moduleSel.value = '__new__'; moduleSel.dispatchEvent(new Event('change')); }
  });

  moduleSel.addEventListener('change', async () => {
    chapterField.style.display = 'none';
    resetSelect(chapterSel, 'Select a module first');
    if (moduleSel.value === '__new__') {
      // A brand-new module can't have existing chapters yet - go straight to "new chapter"
      // instead of showing an empty dropdown with nothing to pick.
      newModuleFields.style.display = 'block';
      newChapterFields.style.display = 'block';
      return;
    }
    newModuleFields.style.display = 'none';
    newChapterFields.style.display = 'none';
    if (!moduleSel.value) return;
    chapterField.style.display = 'block';
    const chapters = await withStatus(sb.from('formation_chapters').select('id,title').eq('module_id', moduleSel.value).order('sequence_number'));
    chapterSel.innerHTML = (chapters.length ? '<option value="">Select a chapter...</option>' : '')
      + chapters.map(c => `<option value="${c.id}">${esc(c.title)}</option>`).join('')
      + '<option value="__new__">+ Create new chapter...</option>';
    chapterSel.disabled = false;
    if (!chapters.length) { chapterSel.value = '__new__'; chapterSel.dispatchEvent(new Event('change')); }
  });

  chapterSel.addEventListener('change', () => {
    newChapterFields.style.display = chapterSel.value === '__new__' ? 'block' : 'none';
  });

  document.getElementById('fap-save').addEventListener('click', async () => {
    const errBox = document.getElementById('fap-error');
    errBox.textContent = '';
    if (!pathSel.value) { errBox.textContent = 'Please select a path.'; return; }
    if (!moduleSel.value) { errBox.textContent = 'Please select or create a module.'; return; }

    let moduleId = moduleSel.value;
    if (moduleId === '__new__') {
      const title = document.getElementById('fap-new-module-title').value.trim();
      if (!title) { errBox.textContent = 'Please enter a title for the new module.'; return; }
      const description = document.getElementById('fap-new-module-desc').value.trim() || null;
      const siblingModules = await withStatus(sb.from('formation_modules').select('id').eq('path_id', pathSel.value));
      const { data: newModule, error: moduleErr } = await sb.from('formation_modules')
        .insert({ path_id: parseInt(pathSel.value, 10), title, description, sequence_number: siblingModules.length })
        .select('id').single();
      if (moduleErr) { errBox.textContent = moduleErr.message; return; }
      moduleId = newModule.id;
    }

    let chapterId = chapterField.style.display === 'none' ? '__new__' : chapterSel.value;
    if (!chapterId) { errBox.textContent = 'Please select or create a chapter.'; return; }
    if (chapterId === '__new__') {
      const title = document.getElementById('fap-new-chapter-title').value.trim();
      if (!title) { errBox.textContent = 'Please enter a title for the new chapter.'; return; }
      const siblingCount = await withStatus(sb.from('formation_chapters').select('id').eq('module_id', moduleId));
      const { data: newChapter, error: chapterErr } = await sb.from('formation_chapters')
        .insert({ module_id: parseInt(moduleId, 10), title, sequence_number: siblingCount.length })
        .select('id').single();
      if (chapterErr) { errBox.textContent = chapterErr.message; return; }
      chapterId = newChapter.id;
    }

    const title = document.getElementById('fap-title').value.trim();
    const body = document.getElementById('fap-body').value.trim();
    const document_id = doc ? doc.document_id : null;
    if (!title) { errBox.textContent = 'Title is required.'; return; }
    if (!document_id && !body) { errBox.textContent = 'Either a document or some text is required.'; return; }
    const siblingPosts = await withStatus(sb.from('formation_posts').select('id').eq('chapter_id', chapterId));
    const row = { chapter_id: parseInt(chapterId, 10), document_id, title, body: body || null, sequence_number: siblingPosts.length };
    const { error: postErr } = await sb.from('formation_posts').insert(row);
    if (postErr) { errBox.textContent = postErr.message; return; }
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// Populates a signup-form dropdown before login (anon-readable option_lists rows - see
// option_lists_select_anon in 16_signup_chat_splash.sql). Used for both membership type and
// age bracket.
export async function loadOptionsForSignup(listName) {
  const { data, error } = await sb.from('option_lists').select('code,label').eq('list_name', listName).order('sort_order');
  return error ? [] : data.map(r => [r.code, r.label]);
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

  const signupFields = document.getElementById('signup-fields');
  const switchLink = document.getElementById('auth-switch-link');
  const switchHint = document.getElementById('auth-switch-hint');
  let signupMode = false;

  function setSignupMode(on) {
    signupMode = on;
    signupFields.style.display = on ? 'block' : 'none';
    document.getElementById('login-btn').style.display = on ? 'none' : 'flex';
    document.getElementById('signup-btn').style.display = on ? 'flex' : 'none';
    switchHint.textContent = on ? 'Already have an account?' : 'New here?';
    switchLink.textContent = on ? 'Sign in' : 'Sign up';
    document.getElementById('login-password-label').textContent = on ? 'Create a new password' : 'Password';
    document.getElementById('forgot-password-row').style.display = on ? 'none' : 'block';
    document.getElementById('login-error').textContent = '';
  }
  switchLink.addEventListener('click', () => setSignupMode(!signupMode));
  setSignupMode(false);

  loadOptionsForSignup('membership_type').then(rows => {
    document.getElementById('signup-membership').innerHTML =
      '<option value=""></option>' + rows.map(([c, l]) => `<option value="${c}">${esc(l)}</option>`).join('');
  });
  loadOptionsForSignup('age_bracket').then(rows => {
    document.getElementById('signup-age-bracket').innerHTML =
      '<option value=""></option>' + rows.map(([c, l]) => `<option value="${c}">${esc(l)}</option>`).join('');
  });

  document.getElementById('signup-btn').addEventListener('click', async () => {
    const email = document.getElementById('login-email').value.trim();
    const password = document.getElementById('login-password').value;
    const full_name = document.getElementById('signup-fullname').value.trim();
    const city = document.getElementById('signup-city').value.trim();
    const membership_type = document.getElementById('signup-membership').value;
    const phone = document.getElementById('signup-phone').value.trim();
    const age_bracket = document.getElementById('signup-age-bracket').value;
    const gender = document.getElementById('signup-gender').value;
    const errBox = document.getElementById('login-error');
    errBox.textContent = '';
    if (!email || password.length < 6) { errBox.textContent = 'Email and password (min. 6 characters) are required.'; return; }
    if (!full_name || !city || !membership_type || !phone || !age_bracket || !gender) { errBox.textContent = 'Full name, city, membership type, phone, age bracket and gender are required.'; return; }
    const { error } = await sb.auth.signUp({ email, password, options: { data: { full_name, city, membership_type, phone, age_bracket, gender }, emailRedirectTo: 'https://mediafocolarepak.github.io/Urdu-Archive/' } });
    if (error) { errBox.textContent = error.message; return; }
    errBox.style.color = 'var(--accent)';
    errBox.textContent = 'Sign-up submitted. Check your email to confirm, then sign in.';
  });

  document.getElementById('logout-btn').addEventListener('click', () => {
    sessionStorage.removeItem('splashShown');
    sb.auth.signOut();
  });

  document.getElementById('forgot-password-link').addEventListener('click', async () => {
    const errBox = document.getElementById('login-error');
    const email = document.getElementById('login-email').value.trim();
    if (!email) { errBox.style.color = 'var(--danger)'; errBox.textContent = 'Type your email above first, then click "Forgot your password?" again.'; return; }
    errBox.textContent = '';
    const { error } = await sb.auth.resetPasswordForEmail(email, { redirectTo: 'https://mediafocolarepak.github.io/Urdu-Archive/' });
    if (error) { errBox.style.color = 'var(--danger)'; errBox.textContent = error.message; return; }
    errBox.style.color = 'var(--accent)';
    errBox.textContent = 'Check your email for a link to reset your password.';
  });
}

// Fired via the onAuthStateChange 'PASSWORD_RECOVERY' event (see boot() below) once someone
// follows the reset-password link from their email - shows a dedicated "set new password"
// screen instead of the normal login/app, since the session at this point is a short-lived
// recovery session, not a real sign-in.
function showRecoveryScreen() {
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('app').style.display = 'none';
  document.getElementById('recovery-screen').style.display = 'flex';
  const errBox = document.getElementById('recovery-error');
  const saveBtn = document.getElementById('recovery-save-btn');
  saveBtn.onclick = async () => {
    const pw = document.getElementById('recovery-password').value;
    const pw2 = document.getElementById('recovery-password-confirm').value;
    errBox.style.color = 'var(--danger)'; errBox.textContent = '';
    if (pw.length < 6) { errBox.textContent = 'Password must be at least 6 characters.'; return; }
    if (pw !== pw2) { errBox.textContent = 'Passwords do not match.'; return; }
    const { error } = await sb.auth.updateUser({ password: pw });
    if (error) { errBox.textContent = error.message; return; }
    document.getElementById('recovery-screen').style.display = 'none';
    location.reload();
  };
}
