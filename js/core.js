// Supabase client, shared mutable state, generic helpers, auth, and the tab dispatcher.
// Every other module imports from this one only (never from each other) to keep the
// import graph a simple star and avoid circular-import bugs.

export const SUPABASE_URL = 'https://tvabpsxfwofiqriwbolz.supabase.co';
export const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2YWJwc3hmd29maXFyaXdib2x6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0NTQ2OTksImV4cCI6MjEwMjAzMDY5OX0.ltxl-K6lHKp1NC3-t9xzMOML9JVyqrpcQjkHkauiGBY';
export const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
export const BUCKET = 'archive-files';
export const AUDIO_BUCKET = 'reading-audio';
// The files of the archive (174_files.sql allows only these, up to 50 MB). The kind is said by the ending, because a computer
// may not know InPage or Word files; supabase-js sends the kind of the file itself, so the file gets it.
const ARCHIVE_FILE_KINDS = { inp: 'application/octet-stream', pdf: 'application/pdf', doc: 'application/msword', docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' };
export const ARCHIVE_FILE_MAX = 50 * 1024 * 1024;
export function archiveFileEnding(file) { const e = (file.name.split('.').pop() || '').toLowerCase(); return ARCHIVE_FILE_KINDS[e] ? e : null; }
export function asArchiveFile(file) { const e = archiveFileEnding(file); return e ? file.slice(0, file.size, ARCHIVE_FILE_KINDS[e]) : file; }

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
    const data = await busyWhile(fetch(url).then(res => res.json()), 'Opening the file...');
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

// The libraries from outside, each with its exact version and fingerprint (the browser refuses a file that is not that one),
// loaded the first time someone needs them. To change a version: the new address and fingerprint here, and the address in
// the Content-Security-Policy of index.html. The fingerprint: curl -sL <address> | openssl dgst -sha384 -binary | openssl base64 -A
const LIBRARIES = {
  pdf: ['pdfjsLib', 'https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/legacy/build/pdf.min.js', 'sha384-OemFRmhjDZwhIKuUld0HJozkF2YErsgDaCL41trxGQZt4/WgnopJQqQl2DvDZ07Z'],
  docx: ['docx', 'https://cdn.jsdelivr.net/npm/docx@9.7.1/dist/index.iife.js', 'sha384-9OH56uLhIvkZkwF0jWNlfpcK3gPuSy5DfEMNqKe156wCpkND+MDdtaRyd05kwpG0'],
  mammoth: ['mammoth', 'https://cdn.jsdelivr.net/npm/mammoth@1.8.0/mammoth.browser.min.js', 'sha384-/cXAMbzovUIKbBERjPmR3SnPTh8siWr5lsvFYj1Uq4XP0yaJUZJmsh0YXyGv5P0y'],
};
const PDF_WORKER = ['https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/legacy/build/pdf.worker.min.js', 'sha384-sS8B4COeBqzQV9DaPpp5cbpF+xz2jPcFbN3L8FL3/dx0RMC6WLUwTUOFm0iFb1lw'];
const libraryLoading = {};
export function loadLibrary(name, failed = 'Could not load a part of the app. Please check the connection and try again.') {
  const [global, src, integrity] = LIBRARIES[name];
  if (window[global]) return Promise.resolve(window[global]);
  libraryLoading[name] ||= new Promise((resolve, reject) => {
    const script = document.createElement('script');
    Object.assign(script, { src, integrity, crossOrigin: 'anonymous' });
    script.onload = () => resolve(window[global]);
    script.onerror = () => { delete libraryLoading[name]; script.remove(); reject(new Error(failed)); };
    document.head.appendChild(script);
  });
  return libraryLoading[name];
}
// pdf.js does its work in a second file, which a page cannot check by itself: it is read with its fingerprint first.
export async function loadPdfJs() {
  const pdfjs = await loadLibrary('pdf');
  if (!pdfjs.GlobalWorkerOptions.workerSrc) {
    const worker = await fetch(PDF_WORKER[0], { integrity: PDF_WORKER[1], mode: 'cors', credentials: 'omit' });
    if (!worker.ok) throw new Error('pdf.worker ' + worker.status);
    pdfjs.GlobalWorkerOptions.workerSrc = URL.createObjectURL(new Blob([await worker.arrayBuffer()], { type: 'text/javascript' }));
  }
  return pdfjs;
}

// A page opened for printing: the print dialog once it is ready. Said from here, because a page may not carry a script of its own.
export function printWhenReady(w) {
  const go = () => w.setTimeout(() => w.print(), 150);
  if (w.document.readyState === 'complete') go(); else w.addEventListener('load', go, { once: true });
}

// The bytes of a PDF of the archive on Drive, for the document beside the work (desk.js). Null if it is not there.
export function fetchDriveFile(fileName) { return fetchGDriveFileBlob(GDRIVE_FOLDER_ID, fileName); }

// Counts the pages of a PDF Blob/File with pdf.js. Returns null (never throws) on any failure
// - callers should fall back to letting the person type the page count in by hand. Shared by
// readPdfPageCount below (fetches the blob from Storage/Drive first) and by anything that
// already holds the raw file locally (e.g. Bulk Import, reading straight off disk before the
// file is ever uploaded anywhere).
export async function readPdfPageCountFromBlob(blob) {
  if (!blob) return null;
  try {
    const pdfjs = await loadPdfJs();
    const buf = await blob.arrayBuffer();
    const pdf = await pdfjs.getDocument({ data: buf }).promise;
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
  try { await loadPdfJs(); } catch { return { pages: null, detail: 'pdf.js did not load' }; }
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
export async function uploadPdfToGDrive(fileName, blob, accessToken) {
  return await driveUploadOrReplace(GDRIVE_FOLDER_ID, fileName, blob, accessToken);
}

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
  place: 'home',  // 'home' or 'work': which of the two places an Operator is in (app.js renderTab)
  myQualifications: new Set(),  // qualification_code set for the signed-in Operator (empty for other roles)
  myFavorites: new Set(),  // document_id set of the signed-in user's own "My Space" saves
  myBoards: new Set(),  // board_code set the signed-in user can post to (all of them for coordinator/admin)
  myMembershipType: null,  // user_profiles.membership_type, for the default board to open first
  boardsSelected: null,  // board_code of the currently open board on the Boards tab, remembered across re-renders
  appShown: false,
  selectedDocId: null,
  selectedCategoryId: null,
  dashFilters: { search: '', idSearch: '', category: '', author: '', main_topic: '', workflow_status: '', access_level: '', collection: '', recipient: '', source: '', language: '', legacyOnly: false, pendingOnly: false, withMedia: false },
  dashUserDefaultsApplied: false,
  dashSort: { col: 'document_id', asc: false },
  reportFilters: { category: '', main_topic: '', author: '', recipient: '', workflow_status: '', from: '', to: '' },
  matchFilters: { search: '', idSearch: '', category: '', author: '', workflow_status: '', recipient: '', collection: '', language: '', source: '', orphansOnly: false },
  matchSort: { col: 'document_id', asc: false },
  matchSelectedId: null,
  usersSort: { col: 'full_name', asc: true },
  peopleFilter: { search: '', who: '', department: '', role: '', qualification: '', order: 'name' },
  optionsSelectedList: 'category',
  deptEditorSelected: null,  // department_code currently shown in Options -> Departments
  myDeptSelected: null,  // department_code currently shown in My Department (mydepartment.js)
  myDeptCoordTab: 'open',  // sub-tab shown in My Department's Coordination task-flow panel
  sub: '',             // a page inside a section: 'task/51', 'review/51' (app.js renderTab)
  mineTab: 'active',  // sub-tab shown in Tasks -> My Tasks (active/submitted/closed)
  docCollections: [],  // { document_id, collection_code, page_number } for the open document
  optionListsByName: {},  // option_lists rows grouped by list_name, as [code,label] pairs - generic lookup used by SessionCache/combobox
  hayatEditorEdition: '',
  taskPrefill: null,  // { title, description, document_id, document_pages } - set by chat.js's "Create task" button, consumed once by tasks.js's new-task form
  chatMessagePrefill: null,  // string - set by docdetail.js's "Report a problem" buttons (optionally with a copied/selected text passage), consumed once by chat.js's compose textarea
  isFormatore: false,  // true if I'm a FORM department member - see boot(); mirrors is_any_formatore() server-side, used to gate "+ New formation path" and "My paths"
  formationSelectedPathId: null,
  myDepartments: [],  // [{department_code, is_lead}] for the signed-in user - see GOVERNANCE.md
  policyValues: {},  // policy_values key -> integer value, cached at boot (see 80_departments_and_people_decisions.sql)
  standing: 'active',  // user_roles.standing: active/watch/suspended/excluded
  paused: false,       // suspended: in the app they are a User until they are reinstated (Owner, 2026-11-25; 170)
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
export const DASH_SORTABLE = { document_id: 'ID', en_title: 'Title', author: 'Author', place: 'Place', category: 'Category' };

// The titles of a document in the order they are shown: Urdu at the top (Owner's choice, 2026-11-06), English, Italian.
// original_title holds different things in different records (the Italian in the old ones, the title in the version's
// own language in the new ones), so it is shown only when it adds something.
export const URDU_SCRIPT = /[\u0600-\u06FF]/;
export function docTitles(d) {
  const t = s => (s ?? '').trim();
  const orig = t(d.original_title);
  const out = [];
  const add = (text, translated = false) => {
    if (text && !out.some(x => x.text.toLowerCase() === text.toLowerCase())) out.push({ text, isUrdu: URDU_SCRIPT.test(text), translated });
  };
  add(t(d.ur_title) || (URDU_SCRIPT.test(orig) ? orig : ''));
  add(t(d.en_title) || t(d.title));
  add(t(d.it_title), !!d.it_title_translated);
  add(orig);
  return out;
}
// The date of a document for its card and the Library: "June 28, 2004", or the month, or the period as written.
export function docDateLabel(doc) {
  if (doc.ref_date) {
    const d = new Date(doc.ref_date + 'T00:00:00');
    return isNaN(d) ? doc.ref_date : d.toLocaleDateString('en', { day: 'numeric', month: 'long', year: 'numeric' });
  }
  const m = /^(\d{4})-(\d{2})$/.exec(doc.ref_period || '');
  return m ? new Date(Number(m[1]), Number(m[2]) - 1, 1).toLocaleDateString('en', { month: 'long', year: 'numeric' }) : (doc.ref_period || '');
}
// The three titles of a document (Owner's request, 2026-11-27: always, in the Library, the paths, the boards and the books):
// English, Urdu, Italian, each only once, and a missing one taken from another version of the same Work.
export function titleTrio(d, others = []) {
  const t = s => (s ?? '').trim(), all = [d, ...others].filter(Boolean);
  const urOf = x => t(x.ur_title) || (URDU_SCRIPT.test(x.original_title || '') ? t(x.original_title) : '');
  const ur = all.map(urOf).find(Boolean) || '';
  let en = all.map(x => t(x.en_title) || t(x.title)).find(Boolean) || '';
  const itDoc = all.find(x => t(x.it_title));
  let it = itDoc ? t(itDoc.it_title) : '';
  if (!en && !ur && !it) en = t(d.original_title);
  if (it && en && it.toLowerCase() === en.toLowerCase()) it = '';
  return { en, ur, it, itTranslated: !!(it && itDoc.it_title_translated) };
}
// The three titles and, small, the number. cls: the class of the block (doc-trio, or doc-trio doc-trio-sm inside a post).
export function titleTrioHtml(d, { others = [], num = true, small = false } = {}) {
  const x = titleTrio(d, others);
  return `<div class="doc-trio${small ? ' doc-trio-sm' : ''}">
    ${num ? `<span class="doc-card-num">#${esc(d.document_id)}</span>` : ''}
    ${x.en ? `<span class="doc-trio-en" dir="auto">${esc(x.en)}</span>` : ''}
    ${x.ur ? `<span class="doc-trio-ur" dir="rtl" lang="ur">${esc(x.ur)}</span>` : ''}
    ${x.it ? `<span class="doc-trio-it" dir="auto" lang="it">${esc(x.it)}${x.itTranslated ? ' <span class="doc-title-mark">(translated)</span>' : ''}</span>` : ''}
    ${!x.en && !x.ur && !x.it ? '<span class="doc-trio-en hint">(no title)</span>' : ''}
  </div>`;
}
// A document as a large card (Owner's request, 2026-11-23): the number, the English title, the Urdu title in Nastaliq,
// then the author and the date. The whole card is one button. Used by the Library and My Space.
export function docCardHtml(d, { selected = false, extra = '' } = {}) {
  const { en: english, ur: urdu, it: italian, itTranslated } = titleTrio(d);
  const facts = [labelOf(State.authors, d.author), docDateLabel(d)].filter(Boolean).map(esc).join(' &middot; ');
  return `
    <div class="doc-card${selected ? ' selected' : ''}" data-id="${esc(d.document_id)}">
      <button type="button" class="doc-card-open">
        <span class="doc-card-num">#${esc(d.document_id)}</span>
        ${english ? `<span class="doc-card-en" dir="auto">${esc(english)}</span>` : ''}
        ${urdu ? `<span class="doc-card-ur" dir="rtl" lang="ur">${esc(urdu)}</span>` : ''}
        ${italian ? `<span class="doc-card-it" dir="auto" lang="it">${esc(italian)}${itTranslated ? ' <span class="doc-title-mark">(translated)</span>' : ''}</span>` : ''}
        ${!english && !urdu && !italian ? '<span class="doc-card-en hint">(no title)</span>' : ''}
        ${facts ? `<span class="doc-card-facts">${facts}</span>` : ''}
        <span class="doc-card-chevron" aria-hidden="true">&rsaquo;</span>
      </button>
      ${extra}
    </div>`;
}
// marks: what goes before the first title, such as the star.
export function docTitlesHtml(d, marks = '') {
  const titles = docTitles(d);
  if (!titles.length) return `<div class="doc-title">${marks}<span class="hint">(no title)</span></div>`;
  return titles.map((x, i) => `<div class="doc-title${i ? ' doc-title-more' : ''}${x.isUrdu ? ' doc-title-ur' : ''}" ${x.isUrdu ? 'dir="rtl" lang="ur"' : 'dir="auto"'}>${i ? '' : marks}${esc(x.text)}${x.translated ? ' <span class="doc-title-mark">(translated)</span>' : ''}</div>`).join('');
}

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
  age_bracket: 'Age bracket (labels of the computed groups: keep the codes)',
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
export function optionsHtml(list, value, allowEmpty, emptyLabel = '') {
  return (allowEmpty ? `<option value="">${emptyLabel}</option>` : '') +
    list.map(([c, l]) => `<option value="${c}" ${c === value ? 'selected' : ''}>${l}</option>`).join('');
}

export function canWrite() { return State.currentRole === 'operator' || State.currentRole === 'coordinator' || State.currentRole === 'admin'; }
// Home is the spiritual home, the same for everyone and silent; My work is the one room an Operator has more (Owner's concept,
// 2026-11-25). In Home an Operator sees what a User sees, without the buttons of the work. Always false for the other roles.
export function quiet() { return ['operator', 'coordinator', 'admin'].includes(State.currentRole) && State.place !== 'work'; }
// Admins and Coordinators: the same Home as everyone, and My work with the tools in groups (Owner's decision, 2026-11-27).
export function isLeader() { return State.currentRole === 'admin' || State.currentRole === 'coordinator'; }
// The archive tools (Match Review, Work Consolidation, Hayat Editor): the members of Archive & Data, Coordinators and Admins.
// The database says the same (can_catalogue, 170).
export function canCatalogue() { return isCoordinator() || isAdmin() || (State.currentRole === 'operator' && isDeptMember('ARCHIVE')); }
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

// Access levels (111_access_levels.sql). This only decides what the screens offer; the database
// is the real gate, and a reserved document simply does not reach anyone who isn't enabled.
export const ACCESS_LEVELS = [['public', 'Public'], ['private', 'Private (registered users)'], ['reserved', 'Reserved']];
export function canManageReserved() { return isAdmin() || isDeptMember('FORM'); }

// Video links and recordings (113_media.sql). The database is the real gate on links; this check only
// gives a clear message first. Statuses a reviewer may be able to read, but which aren't published:
export const HIDDEN_DOC_STATUSES = ['proposed', 'revision', 'pending_publish', 'removed'];
// What a reader can do with a Work, one row per language (Owner's request, 2026-11-23): the person picks a
// document, sees every version together and chooses to read it, listen to it or watch it. doc: the record open
// now; siblings: the other records of its Work; textIds: the ids with a text; media: from fetchDocMedia.
// One text per language: the record open now, else one with a text, else the starred one, else the lowest number.
// Rows: the language of the record open now first, then Urdu, Italian, English, then the others.
export function readerChoices(doc, siblings, textIds, media) {
  const isCurrent = d => String(d.document_id) === String(doc.document_id);
  const hasText = d => textIds.has(String(d.document_id));
  const hasPdf = d => !!(d.file_name || d.storage_path);
  const texts = [doc, ...(siblings || []).filter(s => !isCurrent(s))]
    .filter(d => (!d.media_type || d.media_type === 'DOC') && (isCurrent(d) || !HIDDEN_DOC_STATUSES.includes(d.workflow_status)))
    .filter(d => hasText(d) || hasPdf(d))
    .sort((a, b) => (isCurrent(b) - isCurrent(a)) || (hasText(b) - hasText(a)) || (!!b.is_preferred - !!a.is_preferred) || (a.document_id - b.document_id));
  const rows = new Map();
  const rowOf = lang => {
    const key = lang || '';
    if (!rows.has(key)) rows.set(key, { language: lang || null, text: null, pdf: null, audios: [], videos: [] });
    return rows.get(key);
  };
  for (const d of texts) {
    const row = rowOf(d.language);
    if (!row.text && hasText(d)) row.text = d;
  }
  // The PDF of the text shown, or else of another record of that language.
  for (const row of rows.values()) {
    row.pdf = row.text && hasPdf(row.text) ? row.text
      : texts.find(d => (d.language || null) === row.language && hasPdf(d)) || null;
  }
  for (const m of media || []) {
    if (m.media_type === 'AUD') rowOf(m.language).audios.push(m);
    else if (m.media_type === 'VID' && m.external_url) rowOf(m.language).videos.push(m);
  }
  const order = [doc.language, 'URD', 'ITA', 'ENG'];
  const rank = lang => { const i = order.indexOf(lang || null); return i < 0 ? order.length : i; };
  return [...rows.values()].sort((a, b) => (rank(a.language) - rank(b.language)) || String(a.language || '~').localeCompare(String(b.language || '~')));
}
export function isMediaLinkOk(url) { return /^https:\/\/((www\.|m\.)?youtube\.com|youtu\.be|drive\.google\.com)\/\S+$/.test(url || ''); }
// The audio of the Urdu videos (152_drive_audio.sql) is too large for the bucket: its mp3 files are in this Drive
// folder, shared "anyone with the link" like the PDF folder above, and its readings have the path 'gdrive:<file name>'.
const GDRIVE_AUDIO_FOLDER_ID = '1eRcdg9Ckka9u3rkgcM-nHW9q9ch7R9X2';
export const DRIVE_AUDIO_PREFIX = 'gdrive:';
export async function audioFileUrl(path) {
  if (path.startsWith(DRIVE_AUDIO_PREFIX)) {
    const name = path.slice(DRIVE_AUDIO_PREFIX.length);
    const q = `name='${name.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}' and '${GDRIVE_AUDIO_FOLDER_ID}' in parents and trashed=false`;
    const res = await fetch(`https://www.googleapis.com/drive/v3/files?q=${encodeURIComponent(q)}&fields=files(id)&key=${GDRIVE_API_KEY}`);
    const data = await res.json();
    if (data.error) throw new Error('Google Drive: ' + data.error.message);
    const id = data.files?.[0]?.id;
    if (!id) throw new Error(`"${name}" is not in the Google Drive audio folder.`);
    return `https://www.googleapis.com/drive/v3/files/${id}?alt=media&key=${GDRIVE_API_KEY}`;
  }
  const { data, error } = await sb.storage.from(AUDIO_BUCKET).createSignedUrl(path, 3600);
  if (error) throw error;
  return data.signedUrl;
}
// The small "?" beside a screen's title: opens that screen's guide in Help (userguide.js listens for it).
export function helpLinkHtml(guideKey) {
  return `<button type="button" class="help-q" data-help-guide="${esc(guideKey)}" title="How this works" aria-label="How this works">?</button>`;
}

// Date of birth (120_date_of_birth.sql): three lists rather than a calendar, which is hard to take back to 1950 on a
// phone. Used by the sign-up form, My Profile, Users and the pop-up that asks for it.
const DOB_MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
export function dateOfBirthFieldsHtml(prefix, value) {
  const [y, m, d] = (value || '').split('-').map(Number);
  const thisYear = new Date().getFullYear();
  const years = [];
  for (let i = thisYear; i >= 1920; i--) years.push(i);
  if (y && !years.includes(y)) years.push(y);
  const list = (part, label, options) => `<select id="${prefix}-${part}" aria-label="${label}"><option value="">${label}</option>${options.join('')}</select>`;
  return `<div class="dob-fields">
    ${list('day', 'Day', Array.from({ length: 31 }, (_, i) => `<option value="${i + 1}" ${d === i + 1 ? 'selected' : ''}>${i + 1}</option>`))}
    ${list('month', 'Month', DOB_MONTHS.map((name, i) => `<option value="${i + 1}" ${m === i + 1 ? 'selected' : ''}>${name}</option>`))}
    ${list('year', 'Year', years.map(year => `<option value="${year}" ${y === year ? 'selected' : ''}>${year}</option>`))}
  </div>`;
}

// { value: 'YYYY-MM-DD' or null when all three are empty, error: a message for the person, or null }
export function readDateOfBirth(prefix) {
  const part = name => parseInt(document.getElementById(`${prefix}-${name}`).value, 10);
  const [d, m, y] = [part('day'), part('month'), part('year')];
  if (!d && !m && !y) return { value: null, error: null };
  if (!d || !m || !y) return { value: null, error: 'Please choose the day, the month and the year.' };
  const date = new Date(y, m - 1, d);
  if (date.getMonth() !== m - 1) return { value: null, error: 'This date does not exist. Please check the day and the month.' };
  if (date > new Date()) return { value: null, error: 'A date of birth cannot be in the future.' };
  return { value: `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`, error: null };
}

// Whole years old today, for showing an age instead of a date in lists.
export function ageFromDate(iso) {
  const [y, m, d] = iso.split('-').map(Number);
  const now = new Date();
  return now.getFullYear() - y - ((now.getMonth() + 1 < m || (now.getMonth() + 1 === m && now.getDate() < d)) ? 1 : 0);
}

export function videoLinkHtml(url, label, secondary) {
  return `<a class="btn${secondary ? ' secondary' : ''}" href="${esc(url)}" target="_blank" rel="noopener noreferrer" style="flex:0 0 auto;white-space:nowrap;text-decoration:none;">&#9654; ${esc(label)}</a>`;
}
// File name ending -> the name kept in the bucket and the type it is served as.
export const AUDIO_FORMATS = {
  mp3: ['mp3', 'audio/mpeg'], m4a: ['m4a', 'audio/mp4'], mp4: ['m4a', 'audio/mp4'], aac: ['aac', 'audio/aac'],
  ogg: ['ogg', 'audio/ogg'], opus: ['ogg', 'audio/ogg'], webm: ['webm', 'audio/webm'],
};
const MAX_AUDIO_BYTES = 25 * 1024 * 1024; // the reading-audio bucket's limit (113_media.sql)
// Null when the file can be used, otherwise why not.
export function audioFileProblem(file) {
  const ending = (file.name.split('.').pop() || '').toLowerCase();
  if (ending === 'wav') return 'A WAV file is too large. Please convert it to MP3 or M4A first.';
  if (!AUDIO_FORMATS[ending]) return `"${file.name}" is not a recording this app can keep: please use MP3, M4A, OGG or WEBM.`;
  if (file.size > MAX_AUDIO_BYTES) return `"${file.name}" is larger than 25 MB. Please convert it to a smaller MP3 or M4A.`;
  return null;
}
// How long it lasts, if the file says so. Some recordings don't, and nothing depends on it.
export function audioDurationOf(file) {
  return new Promise(resolve => {
    const url = URL.createObjectURL(file);
    const audio = new Audio();
    const done = value => { clearTimeout(timer); URL.revokeObjectURL(url); resolve(value); };
    const timer = setTimeout(() => done(null), 5000);
    audio.preload = 'metadata';
    audio.onerror = () => done(null);
    audio.onloadedmetadata = () => {
      if (!Number.isFinite(audio.duration)) { done(null); return; }
      const total = Math.round(audio.duration);
      done(`${Math.floor(total / 60)}:${String(total % 60).padStart(2, '0')}`);
    };
    audio.src = url;
  });
}
// Removes from the bucket whatever this person can remove and no record uses any more (114_readings.sql).
// Whatever fails stays on the list, already closed to listeners, for the next try or for Admin.
export async function eraseMyAudioFiles() {
  const { data: paths } = await sb.rpc('get_my_files_to_erase');
  if (!paths || !paths.length) return;
  const { error } = await sb.storage.from(AUDIO_BUCKET).remove(paths);
  if (error) return;
  for (const path of paths) await sb.rpc('confirm_audio_file_erased', { p_path: path });
}
// One player for the document panel, the Start Here card and the review screen.
// reading: { path, reader_name, document_id }. With a document_id, a listen is counted (never who).
export async function mountAudioPlayer(box, reading, autoplay) {
  box.innerHTML = '<div class="hint">Loading the recording...</div>';
  let url;
  try { url = await busyWhile(audioFileUrl(reading.path), 'Opening the recording...'); }
  catch (e) { box.innerHTML = `<div class="hint">Could not open the recording: ${esc(e.message)}</div>`; return; }
  box.innerHTML = `
    <audio controls preload="metadata" style="width:100%;margin-top:6px;" src="${esc(url)}"></audio>
    ${reading.reader_name ? `<div class="hint" dir="auto">Read by ${esc(reading.reader_name)}</div>` : ''}`;
  const audio = box.querySelector('audio');
  if (reading.document_id) audio.addEventListener('play', () => { sb.rpc('count_audio_play', { p_document_id: reading.document_id }).then(() => {}, () => {}); }, { once: true });
  audio.addEventListener('error', () => {
    box.insertAdjacentHTML('beforeend', '<div class="hint">This device could not play the recording. Please tell us in "Share with us", and say which phone you use.</div>');
  });
  if (autoplay) audio.play().catch(() => { /* the browser wants a second tap on the player */ });
}

// Team Applications tab visibility, moved from Coordinator to HR (GOVERNANCE.md phase 2a) -
// Coordinators still keep RLS access for now (migration 80 §8) until migration 81 removes it,
// so this is purely a client-side narrowing of who sees the tab, not the real gate.
export function canReviewTeamApplications() { return isDeptMember('HR') || isAdmin(); }

// Policy revision framework (GOVERNANCE.md §2.8/§6.6, migration 86) - mirrors
// can_propose_policy_change()/can_approve_policy_change() server-side; RLS is the real gate.
export function canProposePolicyChange(departmentCode) { return isAdmin() || isDeptLead(departmentCode); }
export function canApprovePolicyChange() { return isAdmin(); }

// ---------- Archive log (110_doors_and_archive_log.sql) ----------

const LOG_TABLE_LABELS = {
  documents: 'Document', document_texts: 'Text', document_original_texts: 'Original text',
  document_collections: 'Collection', hayat_indice: 'Hayat index', policy_values: 'Rule', process_history: 'Process step', works: 'Work', tasks: 'Task',
  user_roles: 'Role', user_qualifications: 'Qualification', department_members: 'Department',
};
const LOG_ACTION_LABELS = { insert: 'added', update: 'changed', delete: 'removed' };

function logValue(v) {
  if (v === undefined || v === null) return '\u2014';
  const s = typeof v === 'string' ? v : JSON.stringify(v);
  return s.length > 80 ? s.slice(0, 80) + '\u2026' : s;
}

function logWhat(r) {
  const deleted = r.table_name === 'documents' && r.changes?.deleted_at;
  if (deleted) return deleted.new ? 'Document deleted' : 'Document restored';
  return `${LOG_TABLE_LABELS[r.table_name] || r.table_name} ${LOG_ACTION_LABELS[r.action] || r.action}`;
}

// Shared by a document's history and a person's activity. showActor: who did it (a document's
// history); otherwise which document it was about (a person's activity).
export function logEntriesHtml(rows, showActor) {
  if (!rows.length) return '<div class="hint">Nothing recorded yet.</div>';
  return `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>When</th><th>${showActor ? 'Who' : 'Document'}</th><th>What</th><th>Details</th></tr></thead>
      <tbody>${rows.map(r => `<tr>
        <td>${esc((r.at || '').slice(0, 16).replace('T', ' '))}</td>
        <td>${showActor ? `${esc(r.actor)}${r.actor_role === 'admin' ? ' <span class="hint">(Admin)</span>' : ''}` : (r.document_id ? '#' + esc(r.document_id) : '')}</td>
        <td>${esc(logWhat(r))}</td>
        <td style="white-space:normal;" dir="auto">${Object.entries(r.changes || {}).map(([field, c]) => `${esc(field)}: ${esc(logValue(c.old))} &rarr; ${esc(logValue(c.new))}`).join('<br>')}</td>
      </tr>`).join('')}</tbody>
    </table></div>`;
}

// ---------- Standing widget (credits + reputation, shown in the topbar for Operator+) ----------

const GOOD_PRACTICES = [
  'Take a task only if you think you can finish it by the date you choose.',
  'You cannot finish it? Use "Return this task" early. It costs nothing. Leaving it late does.',
  'Send a task for review only when it is ready.',
  'As a Revisor, look at the work, not at who may have done it.',
  'Write review notes that help. The person will read them.',
];
const AVOID_LIST = [
  'Taking tasks "just in case" and leaving them late.',
  'Sending work that is not finished, only to be on time.',
  'Asking who did a task you are reviewing.',
  'Being rude to others. A Coordinator can take a task back for this, and your reputation goes down.',
];

function repClass(rep) { return rep >= 70 ? 'rep-good' : rep >= 40 ? 'rep-ok' : 'rep-low'; }

// The credits and how the good practice is going, at the top of My work (work.js). A tap opens the good practices. Not in the
// top bar since 2026-11-25: Home is silent, and what measures the work stays in the room of the work.
export function standingHtml(credits, reputation) {
  const rep = Math.max(0, Math.min(100, reputation ?? 70));
  return `
    <button type="button" class="standing-btn" id="good-practices-btn" title="Good practices" aria-label="${esc(credits ?? 0)} credits. Good practice: ${rep} out of 100. Open the good practices">
      <span class="credits-badge">${esc(credits ?? 0)} credits</span>
      <span class="rep-label">Good practice</span>
      <span class="rep-track"><span class="rep-fill ${repClass(rep)}" style="width:${rep}%;"></span></span>
      <span class="rep-val">${rep}</span>
    </button>`;
}

export function showGoodPracticesModal() {
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

// Document numbers come from the server (110_doors_and_archive_log.sql). Computing max + 1 here went
// wrong for anyone who could not see hidden rows, and would reuse the number of a deleted document.
export async function nextDocumentId() {
  return await withStatus(sb.rpc('next_document_id'));
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
  const newId = await nextDocumentId();
  const workId = await createWorkFor(row.titolo || row.title);
  const draft = {
    document_id: newId, title: row.title || row.titolo, original_title: row.titolo || row.title, it_title: row.titolo || null,
    ur_title: row.ur_title || null,
    original_author: row.autore,
    hayat_index_ref: row.id, to_whom: row.branca,
    hayat_issue: `${row.mese_anno || ''}p.${row.pagina || ''}`,
    category: row.category || null, author: mapHayatAuthor(row.autore), main_topic: 'GENR', secondary_tags: row.argomento,
    // A Word of Life is dated by its own month, not the issue's (Owner's decision 2026-11-05):
    // the December issue can carry January's Word of Life. The issue stays in hayat_issue above.
    ref_period: row.data_pdv || row.mese_anno || null,
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
// One star per Work, language and format: choosing the Urdu version must not take it from the Italian.
export async function setPreferredVersion(docId, workId) {
  const rows = await withStatus(sb.from('documents').select('language,media_type').eq('document_id', docId));
  const { language, media_type: media } = rows[0] || {};
  let q = sb.from('documents').update({ is_preferred: false }).eq('work_id', workId);
  q = language ? q.eq('language', language) : q.is('language', null);
  q = !media || media === 'DOC' ? q.or('media_type.is.null,media_type.eq.DOC') : q.eq('media_type', media);
  await withStatus(q);
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

// A turning wheel with "Loading..." in the middle of the screen while the app waits (Owner's request, 2026-11-23:
// readers not at ease with phones should see that something is happening). It appears only after 0.4 s, so quick
// answers don't make it flicker, and it never blocks a tap. Every request through withStatus shows it.
let busyCount = 0;
let busyTimer = null;
let busyLabel = 'Loading...';
function showBusy() {
  let el = document.getElementById('app-busy');
  if (!el) {
    el = document.createElement('div');
    el.id = 'app-busy';
    el.setAttribute('role', 'status');
    el.innerHTML = '<div class="app-busy-wheel" aria-hidden="true"></div><div class="app-busy-text"></div>';
    document.body.appendChild(el);
  }
  el.querySelector('.app-busy-text').textContent = busyLabel;
}
// Requests one after another keep the wheel up: it goes away 0.2 s after the last one ends.
let busyHideTimer = null;
export function busyStart(label) {
  busyLabel = label || 'Loading...';
  clearTimeout(busyHideTimer);
  if (document.getElementById('app-busy')) showBusy();
  else if (busyCount === 0) busyTimer = setTimeout(showBusy, 400);
  busyCount++;
}
export function busyEnd() {
  busyCount = Math.max(0, busyCount - 1);
  if (busyCount) return;
  clearTimeout(busyTimer);
  busyHideTimer = setTimeout(() => document.getElementById('app-busy')?.remove(), 200);
}
export async function busyWhile(promise, label) {
  busyStart(label);
  try { return await promise; } finally { busyEnd(); }
}

// The wheel says "Loading...", or what the caller is doing ("Saving...", "Searching...").
export async function withStatus(promise, busyText) {
  setStatus(busyText || 'Working...', false);
  const { data, error } = await busyWhile(promise, busyText);
  if (error) { setStatus('Error: ' + error.message, true); throw error; }
  setStatus('Connected', false);
  return data;
}
export async function withStatusCount(promise, busyText) {
  setStatus(busyText || 'Working...', false);
  const { data, error, count } = await busyWhile(promise, busyText);
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

// A new password: eight characters, and not one of the first that anyone would try. Passwords already in use stay as they are.
// The same in the Edge Function phone-account.
export const MIN_PASSWORD = 8;
const EASY_PASSWORD = /^(.)\1*$|^(0?123456789?0?|9?87654321?0?|password\d*|qwerty\w*|abcd(efgh)?\d*|pakistan\d*|focolare\d*)$/i;
export function passwordProblem(pw, login = '') {
  if (pw.length < MIN_PASSWORD) return `The password needs at least ${MIN_PASSWORD} characters.`;
  const digits = String(login).replace(/\D/g, '');
  if (EASY_PASSWORD.test(pw) || (digits.length > 6 && pw.replace(/\D/g, '').endsWith(digits.slice(-9)))) return 'This password is too easy to guess. Please choose another one.';
  return '';
}

// Whoever can change the archive is signed out after a time without using the app: a phone or a computer left somewhere stays
// closed. Never the Users. In milliseconds, by role.
const HOUR = 3600000;
const IDLE_LIMIT = { operator: 7 * 24 * HOUR, coordinator: 12 * HOUR, admin: 12 * HOUR };
const IDLE_WARNING = 5 * 60000;
const lastActive = () => { try { return Number(localStorage.getItem('lastActive')) || 0; } catch { return 0; } };
let activeNoted = 0;
function noteActive() {
  const now = Date.now();
  if (now - activeNoted < 30000) return;
  activeNoted = now;
  try { localStorage.setItem('lastActive', String(now)); } catch { /* private window: no limit */ }
}
export function idleLeft(role, last, now = Date.now()) { return IDLE_LIMIT[role] && last ? last + IDLE_LIMIT[role] - now : Infinity; }
async function signOutIdle() {
  try { sessionStorage.setItem('signedOutIdle', '1'); localStorage.removeItem('lastActive'); } catch { /* only the message is lost */ }
  await sb.auth.signOut({ scope: 'local' }).catch(() => {});
  history.replaceState(null, '', location.pathname);
  location.reload();
}
let idleTimer = null, idleWarned = false;
function watchIdle() {
  clearInterval(idleTimer);
  if (!IDLE_LIMIT[State.currentRole]) return;
  activeNoted = 0; noteActive();
  if (!watchIdle.wired) { watchIdle.wired = true; for (const e of ['pointerdown', 'keydown', 'scroll', 'touchstart']) window.addEventListener(e, () => { if (idleLeft(State.currentRole, lastActive()) > 0) noteActive(); }, { passive: true, capture: true }); }
  const check = () => {
    const left = idleLeft(State.currentRole, lastActive());
    if (left <= 0) { clearInterval(idleTimer); signOutIdle(); return; }
    if (left > IDLE_WARNING) { idleWarned = false; return; }
    if (!idleWarned && !document.hidden) { idleWarned = true; alertPopup('You will be signed out in a few minutes, because DUA has not been used for a long time. Press OK to stay.'); }
  };
  idleTimer = setInterval(check, 60000);
  if (!watchIdle.seen) { watchIdle.seen = true; document.addEventListener('visibilitychange', () => { if (!document.hidden && State.appShown && idleTimer) check(); }); }
}

// The second step of the sign-in (My Profile): the code of an authenticator app, after the password. The database asks for it
// too (second_step_done, 175_sign_in.sql). True while the code is still to be given.
async function secondStepMissing() {
  if (!sb.auth.mfa) return false;
  const { data } = await sb.auth.mfa.getAuthenticatorAssuranceLevel();
  return !!data && data.nextLevel === 'aal2' && data.currentLevel !== 'aal2';
}
function showSecondStep(renderDashboardTab) {
  document.getElementById('app').style.display = 'none';
  document.getElementById('closed-screen')?.remove();
  document.body.insertAdjacentHTML('beforeend', `
    <div id="closed-screen" class="closed-screen"><div class="panel">
      <h2>Second step</h2>
      <p>Open your authenticator app and write the 6 digits it shows for DUA.</p>
      <div class="field"><label for="second-code">Code</label><input id="second-code" type="text" inputmode="numeric" autocomplete="one-time-code" maxlength="7" style="font-size:24px;letter-spacing:4px;"></div>
      <div id="second-error" class="dob-error" role="alert"></div>
      <div class="btn-row"><button type="button" class="btn big-btn" id="second-go">Continue</button><button type="button" class="btn secondary" id="second-out">Sign out</button></div>
      <p class="hint">If you no longer have that phone, ask the other Admin of DUA.</p>
    </div></div>`);
  const input = document.getElementById('second-code'), error = document.getElementById('second-error'), go = document.getElementById('second-go');
  input.focus();
  document.getElementById('second-out').addEventListener('click', () => document.getElementById('logout-btn').click());
  const send = async () => {
    const code = input.value.replace(/\D/g, '');
    if (code.length !== 6) { error.textContent = 'The code has 6 digits.'; return; }
    go.disabled = true; error.textContent = '';
    try {
      const { data: factors, error: e1 } = await sb.auth.mfa.listFactors();
      const factor = factors && factors.totp[0];
      const { error: e2 } = e1 || !factor ? { error: e1 || new Error('No second step found.') } : await sb.auth.mfa.challengeAndVerify({ factorId: factor.id, code });
      if (e2) { error.textContent = /invalid|expired/i.test(e2.message) ? 'This code is not right, or it has expired. Try the one shown now.' : errorText(e2); input.select(); return; }
      document.getElementById('closed-screen').remove();
      const { data: { session } } = await sb.auth.getSession();
      await showApp(session, renderDashboardTab);
    } finally { go.disabled = false; }
  };
  go.addEventListener('click', send);
  input.addEventListener('keydown', e => { if (e.key === 'Enter') send(); });
}

export async function boot(renderDashboardTab) {
  try { if (sessionStorage.getItem('signedOutIdle')) { sessionStorage.removeItem('signedOutIdle'); setTimeout(() => alertPopup('You were signed out because DUA was not used for a long time on this device. Please sign in again.'), 600); } } catch { /* no message */ }
  const { data: { session } } = await sb.auth.getSession();
  if (session) { await showApp(session, renderDashboardTab); } else { showLogin(); }
  sb.auth.onAuthStateChange(async (event, session) => {
    if (event === 'PASSWORD_RECOVERY') { showRecoveryScreen(); return; }
    if (session && !State.appShown) await showApp(session, renderDashboardTab);
    else if (session) document.getElementById('user-email').textContent = displayLogin(session.user.email);
    else { State.appShown = false; showLogin(); }
  });
}

// An excluded person: nothing opens but this page (the database gives them nothing either, 170).
function showClosed() {
  document.getElementById('app').style.display = 'none';
  document.getElementById('closed-screen')?.remove();
  document.body.insertAdjacentHTML('beforeend', `
    <div id="closed-screen" class="closed-screen"><div class="panel">
      <h2>Digital Urdu Archive</h2>
      <p>Your access to DUA is closed.</p>
      <p>If you think this is a mistake, please speak with the person who invited you.</p>
      <button type="button" class="btn big-btn" id="closed-signout">Sign out</button>
    </div></div>`);
  document.getElementById('closed-signout').addEventListener('click', () => document.getElementById('logout-btn').click());
}

// Before signing in, the landing page comes first (landing.js, set by app.js as window.__renderLanding); its Sign in
// tile opens the sign-in card, whose "Back" returns to it. Without it, the sign-in card as before.
function showLogin() {
  document.getElementById('app').style.display = 'none';
  document.getElementById('closed-screen')?.remove();
  const landing = document.getElementById('landing-screen');
  if (landing && window.__renderLanding) {
    document.getElementById('login-screen').style.display = 'none';
    landing.style.display = 'block';
    window.__renderLanding(landing);
  } else {
    document.getElementById('login-screen').style.display = 'flex';
  }
}

export function showSignIn() {
  const landing = document.getElementById('landing-screen');
  if (landing) landing.style.display = 'none';
  document.getElementById('login-screen').style.display = 'flex';
  window.scrollTo(0, 0);
}

async function showApp(session, renderDashboardTab) {
  State.appShown = true;
  State.selectedDocId = null; State.selectedCategoryId = null;
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('landing-screen')?.style.setProperty('display', 'none');
  document.getElementById('reading-view')?.remove();
  if (await secondStepMissing()) { showSecondStep(renderDashboardTab); return; }
  document.getElementById('app').style.display = 'flex';

  const { data: roleRows } = await sb.from('user_roles').select('role,credits,reputation,standing,board_posting_blocked').eq('user_id', session.user.id);
  const roleRow = roleRows && roleRows[0];
  State.currentRole = roleRow ? roleRow.role : 'user';
  State.standing = roleRow ? roleRow.standing : 'active';
  // The same the database does (current_role_is, 170): never for an Admin.
  if (State.currentRole !== 'admin' && State.standing === 'excluded') { showClosed(); return; }
  if (idleLeft(State.currentRole, lastActive()) <= 0) { await signOutIdle(); return; }
  watchIdle();
  State.paused = State.currentRole !== 'admin' && State.currentRole !== 'user' && State.standing === 'suspended';
  if (State.paused) State.currentRole = 'user';
  State.boardPostingBlocked = roleRow ? !!roleRow.board_posting_blocked : false;
  document.getElementById('user-email').textContent = `${displayLogin(session.user.email)} (${State.currentRole})`;

  const { data: deptRows } = await sb.from('department_members').select('department_code,is_lead').eq('user_id', session.user.id);
  State.myDepartments = State.paused ? [] : deptRows || [];
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
    State.myBoards = new Set(State.paused ? [] : (editorRows || []).map(r => r.board_code));
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
  await maybeShowSplash(session.user.id);
  // The announcement comes first, if there is one: its "Got it" then asks for the date.
  if (!document.querySelector('.overlay-backdrop')) maybeAskDateOfBirth();
}

// ---------- Asking for the date of birth ----------
// Only those who haven't given it, once per session. It never blocks the app: "Later" asks again after 7 days.
// The Urdu is the reviewers' to approve (Documentazione/Popup_data_nascita_urdu_da_rivedere.md): until then, English only.
const DOB_PROMPT_UR = { title: '', body: '' };
const DOB_LATER_DAYS = 7;
export async function maybeAskDateOfBirth() {
  if (sessionStorage.getItem('dobAsked')) return;
  sessionStorage.setItem('dobAsked', '1');
  const { data: { user } } = await sb.auth.getUser();
  if (!user) return;
  const laterKey = `dobLater_${user.id}`;
  try { if (Number(localStorage.getItem(laterKey)) > Date.now()) return; } catch { /* then simply ask */ }
  const { data, error } = await sb.from('user_birth_dates').select('user_id').eq('user_id', user.id);
  if (error || !data || data.length) return;
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.id = 'dob-popup';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      ${DOB_PROMPT_UR.title ? `<h2 class="start-page-ur" dir="auto">${esc(DOB_PROMPT_UR.title)}</h2>` : ''}
      <h2 style="margin-top:0;">Please add your date of birth</h2>
      ${DOB_PROMPT_UR.body ? `<p class="dob-ur" dir="auto">${esc(DOB_PROMPT_UR.body)}</p>` : ''}
      <p>It keeps our programme statistics right, and helps us offer formation suited to your age.</p>
      <p class="hint">Only you, the HR lead and Admins can see the date. A few people on the team see only your age group. If you don't know the exact date, choose the nearest.</p>
      ${dateOfBirthFieldsHtml('dob-popup')}
      <div id="dob-popup-error" class="dob-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="dob-popup-later">Later</button>
        <button class="btn" id="dob-popup-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('dob-popup-later').addEventListener('click', () => {
    try { localStorage.setItem(laterKey, String(Date.now() + DOB_LATER_DAYS * 86400000)); } catch { /* asked again next session */ }
    backdrop.remove();
  });
  document.getElementById('dob-popup-save').addEventListener('click', async () => {
    const errBox = document.getElementById('dob-popup-error');
    const { value, error: problem } = readDateOfBirth('dob-popup');
    errBox.textContent = problem || (value ? '' : 'Please choose the day, the month and the year.');
    if (!value) return;
    try {
      await withStatus(sb.rpc('set_date_of_birth', { p_date: value }), 'Saving...');
      backdrop.remove();
    } catch (err) { errBox.textContent = err.message; }
  });
}

// ---------- Direction of a text ----------
// dir="auto" looks only at the first letter, so an Urdu text that opens with a Latin word (a heading, "DUA", a
// reference) was shown left to right as a whole. The document's language decides first; otherwise most letters do.
const RTL_LANGUAGES = new Set(['URD']);
export function textDir(text, language) {
  if (language && RTL_LANGUAGES.has(language)) return 'rtl';
  const s = String(text || '').slice(0, 5000);
  const rtl = (s.match(/[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]/g) || []).length;
  const ltr = (s.match(/[A-Za-z\u00C0-\u024F]/g) || []).length;
  if (!rtl && !ltr) return 'auto';
  return rtl > ltr ? 'rtl' : 'ltr';
}

// ---------- Splash-screen announcements ----------
// Owner's request, 2026-11-18 (migration 147): an announcement opens by itself only while the Admin's switch is on
// (app_settings 'announcements_popup'), and only until the person closes it with "Got it": a closed one never opens
// again, on any device (splash_seen). Checked once per browser session; the sessionStorage flag is cleared by the
// sign-out handler below. Before 147 runs: no switch means on, and closed announcements are remembered on the device.

export async function announcementsPopupOn() {
  const { data, error } = await sb.from('app_settings').select('value').eq('key', 'announcements_popup');
  if (error || !data || !data.length) return true;
  // app_settings.value is text (sql/21_app_settings.sql): the switch is 'true' or 'false'.
  return String(data[0].value).replace(/"/g, '').trim() !== 'false';
}

async function lastSeenSplashId(userId) {
  let seen = 0;
  try { seen = Number(localStorage.getItem(`splashSeen_${userId}`)) || 0; } catch { /* the database decides */ }
  const { data, error } = await sb.from('splash_seen').select('splash_id').eq('user_id', userId);
  if (!error && data && data.length) seen = Math.max(seen, Number(data[0].splash_id) || 0);
  return seen;
}

async function markSplashSeen(userId, splashId) {
  try { localStorage.setItem(`splashSeen_${userId}`, String(splashId)); } catch { /* the database keeps it */ }
  const { error } = await sb.from('splash_seen').upsert({ user_id: userId, splash_id: splashId, seen_at: new Date().toISOString() }, { onConflict: 'user_id' });
  if (error) console.warn('Closed announcement not saved in the database:', error.message);
}

// An announcement in the reader's language (migration 131): English always, Italian and Urdu when written. The
// language starts as the one chosen in Help (helpLang), and a choice made here is kept there too, from the next
// opening of Help. Whoever chooses a language with no text reads the English.
const SPLASH_LANGS = { en: 'EN', it: 'IT', ur: 'اردو' };
const splashLangs = m => Object.keys(SPLASH_LANGS).filter(l => l === 'en' || (l === 'it' ? m.message_it : m.message_ur));
const splashText = (m, lang) => (lang === 'it' && m.message_it) || (lang === 'ur' && m.message_ur) || m.message_text;
function splashStartLang(m) {
  const langs = splashLangs(m);
  let saved = null;
  try { saved = localStorage.getItem('helpLang'); } catch { /* then the default below */ }
  if (saved && langs.includes(saved)) return saved;
  return State.currentRole === 'user' && langs.includes('ur') ? 'ur' : 'en';
}
function splashMessageHtml(m, lang) {
  const urdu = lang === 'ur' && m.message_ur;
  return `<div class="overlay-message${urdu ? ' splash-ur' : ''}" ${urdu ? 'dir="rtl"' : 'dir="auto"'}>${esc(splashText(m, lang))}</div>`;
}

async function maybeShowSplash(userId) {
  if (sessionStorage.getItem('splashShown')) return;
  sessionStorage.setItem('splashShown', '1');
  if (!userId || !(await announcementsPopupOn())) return;
  const { data, error } = await sb.from('splash_messages').select('*').order('created_at', { ascending: false }).limit(1);
  if (error || !data || !data.length) return;
  const msg = data[0];
  if (Number(msg.id) <= await lastSeenSplashId(userId)) return;
  const authorName = (await authorNames([msg], 'created_by', 'created_by_email'))(msg);
  const langs = splashLangs(msg);
  let lang = splashStartLang(msg);
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <div class="splash-head">
        <h2>Announcements</h2>
        ${langs.length > 1 ? '<div class="help-lang" role="group" aria-label="Language" id="splash-langs"></div>' : ''}
      </div>
      <div id="splash-text"></div>
      <p class="hint">Posted by ${esc(authorName)} on ${esc((msg.created_at || '').slice(0, 10))}</p>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="splash-history-btn">Previous Announcements</button>
        <button class="btn" id="splash-dismiss-btn">Got it</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  const show = () => {
    document.getElementById('splash-text').innerHTML = splashMessageHtml(msg, lang);
    const box = document.getElementById('splash-langs');
    if (!box) return;
    box.innerHTML = langs.map(l => `<button type="button" class="btn ${l === lang ? '' : 'secondary'}" data-splash-lang="${l}" aria-pressed="${l === lang}">${esc(SPLASH_LANGS[l])}</button>`).join('');
    box.querySelectorAll('[data-splash-lang]').forEach(b => b.addEventListener('click', () => {
      lang = b.dataset.splashLang;
      try { localStorage.setItem('helpLang', lang); } catch { /* not needed to work */ }
      show();
    }));
  };
  show();
  document.getElementById('splash-dismiss-btn').addEventListener('click', () => {
    backdrop.remove();
    markSplashSeen(userId, msg.id);
    maybeAskDateOfBirth();
  });
  document.getElementById('splash-history-btn').addEventListener('click', () => showSplashHistory(lang));
}

// Read-only scrollable list of every past announcement, opened from the splash screen's
// "Previous Announcements" button. Stacks on top of the splash overlay (which stays open
// underneath) rather than replacing it, so "Got it" still works normally after closing this.
async function showSplashHistory(lang = 'en') {
  const { data } = await sb.from('splash_messages').select('*').order('created_at', { ascending: false });
  const rows = data || [];
  const names = rows.map(await authorNames(rows, 'created_by', 'created_by_email'));
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2>Previous Announcements</h2>
      <div class="chat-thread" style="max-height:60vh;">
        ${rows.map((r, i) => `<div class="field" style="margin-bottom:8px;">
            <div class="hint">${esc((r.created_at || '').slice(0, 10))} &middot; ${esc(names[i])}</div>
            ${splashMessageHtml(r, lang)}
          </div>`).join('') || '<div class="empty-msg">No previous announcements.</div>'}
      </div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn" id="splash-history-close-btn">Close</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('splash-history-close-btn').addEventListener('click', () => backdrop.remove());
}

// People are shown by name, never by login: for a phone account the login is the mobile number. Names come from
// people_names() (164_people_names.sql), which gives a name only, and only of people the caller meets in the app.
// Where a name is not given, Coordinators and Admins see the login, as they need it; everyone else "A member of DUA".
const NAMELESS = 'A member of DUA';
const PEOPLE_BATCH = 300;
async function fetchPeopleNames({ ids = [], emails = [] }) {
  const { data, error } = await sb.rpc('people_names', { p_ids: ids, p_emails: emails });
  if (!error) return data || [];
  // Until 164 has been run the function is not there: the old way, which gives whatever the rules let the caller read.
  const list = ids.length ? ['user_id', ids] : ['email', emails];
  const old = await sb.from('user_profiles').select('user_id,email,full_name').in(list[0], list[1]);
  return old.data || [];
}
async function namesFor(key, values) {
  const unique = [...new Set((values || []).filter(Boolean))];
  const found = new Map();
  for (let i = 0; i < unique.length; i += PEOPLE_BATCH) {
    const rows = await fetchPeopleNames({ [key]: unique.slice(i, i + PEOPLE_BATCH) });
    for (const r of rows) if (r.full_name) found.set(key === 'ids' ? r.user_id : r.email, r.full_name);
  }
  return { unique, found };
}

// One person's name from the login kept with a message, a post or a task.
export async function getDisplayNameByEmail(email) {
  if (!email) return '';
  return (await nameMapForEmails([email]))[email];
}

// The same for a list, with one request for all of them. Every login asked for has an answer in the map.
export async function nameMapForEmails(emails) {
  const { unique, found } = await namesFor('emails', emails);
  return Object.fromEntries(unique.map(e => [e, found.get(e) || (canReviewApplications() ? displayLogin(e) : NAMELESS)]));
}

// Names by account id, for path owners, co-authors and assignees. Every id asked for has an answer in the map.
// logins: false leaves out a person without a name, for everyone (My Department: names only).
export async function nameMapForIds(ids, { logins = true } = {}) {
  const { unique, found } = await namesFor('ids', ids);
  const missing = unique.filter(id => !found.has(id));
  // An old account may have no name yet: Coordinators and Admins, who may read the profile, see its login.
  if (missing.length && logins && canReviewApplications()) {
    const { data } = await sb.from('user_profiles').select('user_id,email').in('user_id', missing);
    for (const r of data || []) if (r.email) found.set(r.user_id, displayLogin(r.email));
  }
  return Object.fromEntries(unique.map(id => [id, found.get(id) || (logins ? NAMELESS : '')]));
}

// The names of those who wrote some rows, by account, as a function of the row. Until 173_who_writes.sql has been run some rows
// have a login and no account: for those, by login. Nobody is shown where there is neither.
export async function authorNames(rows, idKey, emailKey) {
  const noId = rows.filter(r => !r[idKey] && r[emailKey] && String(r[emailKey]).includes('@'));
  const [byId, byEmail] = await Promise.all([nameMapForIds(rows.map(r => r[idKey])), noId.length ? nameMapForEmails(noId.map(r => r[emailKey])) : {}]);
  return r => byId[r[idKey]] || byEmail[r[emailKey]] || '';
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
// Since 2026-11-23 (Owner's request) the whole app uses these three instead of the browser's confirm(), prompt() and
// alert(): large text, large buttons, the app's colours, and no web address at the top that could worry a reader.
// They wait for each other, so two messages never cover one another.
let dialogChain = Promise.resolve();
function queueDialog(build) {
  const shown = dialogChain.then(() => new Promise(build));
  dialogChain = shown.then(() => {}, () => {});
  return shown;
}
function dialogShell(id, title, message, extraHtml, buttonsHtml) {
  document.getElementById(id)?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = id;
  backdrop.className = 'overlay-backdrop app-dialog';
  backdrop.innerHTML = `
    <div class="panel overlay-panel" role="dialog" aria-modal="true" style="max-width:460px;">
      ${title ? `<h2 style="margin-top:0;">${esc(title)}</h2>` : ''}
      <p class="app-dialog-text" dir="auto">${esc(message)}</p>
      ${extraHtml}
      <div class="btn-row app-dialog-buttons">${buttonsHtml}</div>
    </div>`;
  document.body.appendChild(backdrop);
  // Esc answers like the first button: No, Cancel, or OK where there is nothing else. The keyboard then goes back to where it was.
  const before = document.activeElement;
  backdrop.addEventListener('keydown', e => { if (e.key === 'Escape') { e.stopPropagation(); backdrop.querySelector('.app-dialog-buttons .btn')?.click(); } });
  new MutationObserver((_, o) => { if (!backdrop.isConnected) { o.disconnect(); if (before && before.isConnected) before.focus(); } }).observe(document.body, { childList: true });
  return backdrop;
}
// A window of the app's own: Esc or a tap outside closes it, the keyboard stays inside it and then goes back where it was.
export function popupShell(id, { width = 520, label = '', section = '' } = {}) {
  document.getElementById(id)?.remove();
  const before = document.activeElement;
  const back = document.createElement('div');
  back.id = id;
  back.className = 'popup-back';
  if (section) back.dataset.section = section;
  back.innerHTML = `<div class="panel" role="dialog" aria-modal="true" aria-label="${esc(label)}" tabindex="-1" style="max-width:${width}px;"></div>`;
  document.body.appendChild(back);
  const panel = back.firstElementChild;
  const close = () => { back.remove(); if (before && before.isConnected) before.focus(); };
  back.addEventListener('mousedown', e => { if (e.target === back) close(); });
  back.addEventListener('keydown', e => {
    if (e.key === 'Escape') { e.stopPropagation(); close(); return; }
    if (e.key !== 'Tab') return;
    const all = [...panel.querySelectorAll('button, input, select, textarea, a[href]')].filter(x => !x.disabled && x.offsetParent !== null);
    if (!all.length) return;
    if (e.shiftKey && (document.activeElement === all[0] || document.activeElement === panel)) { e.preventDefault(); all[all.length - 1].focus(); }
    else if (!e.shiftKey && document.activeElement === all[all.length - 1]) { e.preventDefault(); all[0].focus(); }
  });
  panel.focus();
  return { panel, close };
}
export function confirmPopup(message, { title = '', danger = false, confirmLabel = 'Yes', cancelLabel } = {}) {
  const noLabel = cancelLabel || (confirmLabel === 'Yes' ? 'No' : 'Cancel');
  return queueDialog(resolve => {
    const backdrop = dialogShell('confirm-popup', title, message, '',
      `<button class="btn secondary" id="confirm-cancel">${esc(noLabel)}</button>
       <button class="btn ${danger ? 'danger' : ''}" id="confirm-ok">${esc(confirmLabel)}</button>`);
    const finish = ok => { backdrop.remove(); resolve(ok); };
    backdrop.addEventListener('click', e => { if (e.target === backdrop) finish(false); });
    document.getElementById('confirm-cancel').addEventListener('click', () => finish(false));
    document.getElementById('confirm-ok').addEventListener('click', () => finish(true));
    document.getElementById('confirm-ok').focus();
  });
}
// Like prompt(): the text typed, or null when the person cancels.
export function promptPopup(message, defaultValue = '', { title = '', okLabel = 'OK' } = {}) {
  return queueDialog(resolve => {
    const backdrop = dialogShell('prompt-popup', title, message,
      `<textarea id="prompt-input" rows="3" dir="auto" style="width:100%;">${esc(defaultValue ?? '')}</textarea>`,
      `<button class="btn secondary" id="prompt-cancel">Cancel</button>
       <button class="btn" id="prompt-ok">${esc(okLabel)}</button>`);
    const input = document.getElementById('prompt-input');
    const finish = value => { backdrop.remove(); resolve(value); };
    backdrop.addEventListener('click', e => { if (e.target === backdrop) finish(null); });
    document.getElementById('prompt-cancel').addEventListener('click', () => finish(null));
    document.getElementById('prompt-ok').addEventListener('click', () => finish(input.value));
    input.focus();
  });
}
// Like alert(), but it doesn't stop the page: the code goes on, the message stays until OK.
export function alertPopup(message, { title = '' } = {}) {
  return queueDialog(resolve => {
    const backdrop = dialogShell('alert-popup', title, String(message ?? ''), '', '<button class="btn" id="alert-ok">OK</button>');
    const finish = () => { backdrop.remove(); resolve(); };
    document.getElementById('alert-ok').addEventListener('click', finish);
    document.getElementById('alert-ok').focus();
  });
}
window.alert = message => { alertPopup(message); };

// When something does not work, say so (until 2026-11-25 only a small line in the top bar did, and many buttons seemed to
// do nothing). In plain words: what happened and what to do. What a function of the database answers is shown as it is.
export function errorText(e) {
  const message = String((e && e.message) || e || '');
  if (/failed to fetch|networkerror|load failed|network request failed/i.test(message)) return 'The connection did not work. Please check it and try again.';
  if (e && e.code === 'P0001') return message;
  if (e && (e.code === '42501' || /row-level security|permission denied/i.test(message))) return 'You do not have permission for this. If you think you should, please tell a Coordinator or an Admin.';
  if (/jwt|session|refresh token/i.test(message)) return 'Your sign-in has expired. Please sign out from My Profile and sign in again.';
  return 'That did not work. Please try again. If it happens again, tell us in "Share with us".' + (message ? `\n\n(${message})` : '');
}
// Every request that nobody handles ends here; one message at a time.
let errorShown = false;
window.addEventListener('unhandledrejection', event => {
  const e = event.reason;
  const fromServer = e && typeof e === 'object' && ('hint' in e || 'details' in e || 'statusCode' in e || e.name === 'StorageApiError' || e.name === 'AuthApiError');
  if (!fromServer && !/failed to fetch|networkerror|load failed/i.test(String((e && e.message) || ''))) return;
  event.preventDefault();
  console.error(e);
  if (errorShown) return;
  errorShown = true;
  alertPopup(errorText(e)).then(() => { errorShown = false; });
});
// Instead of a part of the screen that could not be read: what happened, and Try again.
export function showLoadFailed(box, e, again) {
  console.error(e);
  if (!box) return;
  box.innerHTML = `<div class="panel load-failed"><p style="margin:0 0 10px;white-space:pre-wrap;">${esc(errorText(e))}</p><button class="btn secondary">Try again</button></div>`;
  box.querySelector('button').addEventListener('click', again);
}

// The first steps of an Operator (Owner's decision, 2026-11-27): four short screens, once for each account (migration 184; until
// it is run, once for each device). Help shows them again.
const INTRO = [
  ['&#129520;', 'Your room: My work', 'Home stays the same. My work is the place of what you do for the archive.'],
  ['&#9995;', 'Take a task', 'In Tasks, choose one and say when you can finish it. Up to 3 at a time.'],
  ['&#128228;', 'Send it', 'The document is beside the steps. When it is ready, Send for review.'],
  ['&#128172;', 'Ask', 'Help is always at the top. You can also write in Share with us.'],
];
export async function showOperatorIntro(again = false) {
  if (!again) {
    if (State.currentRole !== 'operator') return;
    const { data, error } = await sb.rpc('operator_intro', { p_mark: false });
    const local = (() => { try { return localStorage.getItem('operatorIntroSeen'); } catch { return '1'; } })();
    if (error ? local : data) return;
  }
  const { panel, close } = popupShell('operator-intro', { width: 440, label: 'Welcome to the team' });
  let i = 0;
  const done = () => {
    close();
    try { localStorage.setItem('operatorIntroSeen', '1'); } catch { /* the account keeps it */ }
    if (!again) sb.rpc('operator_intro', { p_mark: true }).then(() => {}, () => {});
  };
  const draw = () => {
    const [sign, title, text] = INTRO[i];
    panel.innerHTML = `<div class="intro-step"><div class="intro-sign" aria-hidden="true">${sign}</div><div class="hint">${i + 1} of ${INTRO.length}</div>
      <h2>${title}</h2><p>${text}</p></div>
      <div class="btn-row intro-btns">${i < INTRO.length - 1 ? '<button type="button" class="btn secondary" data-skip>Skip</button><button type="button" class="btn" data-next>Next &rsaquo;</button>' : '<button type="button" class="btn" data-next>Start</button>'}</div>`;
    panel.querySelector('[data-skip]')?.addEventListener('click', done);
    panel.querySelector('[data-next]').addEventListener('click', () => { if (i < INTRO.length - 1) { i++; draw(); panel.querySelector('[data-next]').focus(); } else done(); });
    panel.querySelector('[data-next]').focus();
  };
  draw();
}

// Text size and colours for this device (Owner's request, 2026-11-23), chosen in My Profile and kept in this browser
// only. The size scales the content of the screen (style.css, --text-zoom); the colours follow the phone unless
// light or dark is chosen. Applied as soon as the app loads, the landing page included.
export const TEXT_SIZES = [['normal', 'Normal', 1], ['large', 'Large', 1.15], ['xlarge', 'Very large', 1.3]];
export const COLOUR_CHOICES = [['auto', 'Automatic'], ['light', 'Light'], ['dark', 'Dark']];
export function displayPrefs() {
  let p = {};
  try { p = JSON.parse(localStorage.getItem('displayPrefs') || '{}') || {}; } catch { /* private mode: the defaults */ }
  return {
    size: TEXT_SIZES.some(([k]) => k === p.size) ? p.size : 'normal',
    colours: COLOUR_CHOICES.some(([k]) => k === p.colours) ? p.colours : 'auto',
  };
}
export function applyDisplayPrefs(p = displayPrefs()) {
  const root = document.documentElement;
  root.style.setProperty('--text-zoom', String((TEXT_SIZES.find(([k]) => k === p.size) || TEXT_SIZES[0])[2]));
  if (p.colours === 'auto') delete root.dataset.theme; else root.dataset.theme = p.colours;
}
export function saveDisplayPrefs(changes) {
  const p = { ...displayPrefs(), ...changes };
  try { localStorage.setItem('displayPrefs', JSON.stringify(p)); } catch { /* not remembered, applied for now */ }
  applyDisplayPrefs(p);
  return p;
}
applyDisplayPrefs();

// ---------- Voice messages (Share with us, Report a problem) ----------
// One recorder for both (Owner's request, 2026-11-23: speaking is easier than typing): a large red "Record" button, a
// clock while recording, then the recording to listen to, with "Record again". Plain MediaRecorder, no library; not
// offered where the browser can't record. Moved here from sharewithus.js (96_share_with_us_audio.sql).
const VOICE_MIME_CANDIDATES = ['audio/webm;codecs=opus', 'audio/webm', 'audio/mp4', 'audio/ogg'];
export function canRecordAudio() { return !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia && window.MediaRecorder); }
export function voiceFileEnding(mime) {
  if (!mime) return 'webm';
  if (mime.includes('mp4')) return 'm4a';
  if (mime.includes('ogg')) return 'ogg';
  return 'webm';
}
// box: where the recorder goes. Returns { audio (null, or { blob, mimeType }), reset() }.
export function mountVoiceRecorder(box, { label = 'Record a voice message', maxMs = 3 * 60 * 1000 } = {}) {
  const state = { audio: null, url: null, recorder: null, stream: null, timer: null };
  const stopStream = () => {
    if (state.stream) { state.stream.getTracks().forEach(t => t.stop()); state.stream = null; }
    clearInterval(state.timer); state.timer = null;
  };
  const showStart = () => {
    box.innerHTML = `<button type="button" class="btn voice-btn" data-voice="start">&#127908; ${esc(label)}</button>`;
    box.querySelector('[data-voice="start"]').addEventListener('click', start);
  };
  const showDone = () => {
    box.innerHTML = `
      <div class="voice-done">
        <div class="voice-done-title">&#10004; Your voice message</div>
        <audio controls src="${state.url}"></audio>
        <button type="button" class="btn secondary" data-voice="again">Delete it and record again</button>
      </div>`;
    box.querySelector('[data-voice="again"]').addEventListener('click', () => { reset(); });
  };
  const reset = () => {
    if (state.recorder && state.recorder.state === 'recording') { state.recorder.onstop = null; state.recorder.stop(); }
    stopStream();
    if (state.url) URL.revokeObjectURL(state.url);
    state.audio = null; state.url = null; state.recorder = null;
    showStart();
  };
  async function start() {
    let stream;
    try { stream = await navigator.mediaDevices.getUserMedia({ audio: true }); }
    catch { alert('The microphone could not be used. Please allow it for this site, or write your message instead.'); return; }
    state.stream = stream;
    const chunks = [];
    const mimeType = VOICE_MIME_CANDIDATES.find(t => MediaRecorder.isTypeSupported(t)) || '';
    const recorder = mimeType ? new MediaRecorder(stream, { mimeType }) : new MediaRecorder(stream);
    state.recorder = recorder;
    recorder.addEventListener('dataavailable', e => { if (e.data.size > 0) chunks.push(e.data); });
    recorder.onstop = () => {
      stopStream();
      const blob = new Blob(chunks, { type: mimeType || (chunks[0] && chunks[0].type) || 'audio/webm' });
      state.audio = { blob, mimeType: blob.type };
      state.url = URL.createObjectURL(blob);
      if (document.body.contains(box)) showDone();
    };
    const startedAt = Date.now();
    recorder.start();
    box.innerHTML = `
      <div class="voice-recording">
        <div class="voice-clock" role="status"><span class="voice-dot" aria-hidden="true"></span> Recording&hellip; <span data-voice="clock">0:00</span></div>
        <button type="button" class="btn voice-btn" data-voice="stop">&#9209; Stop</button>
      </div>`;
    box.querySelector('[data-voice="stop"]').addEventListener('click', () => recorder.stop());
    state.timer = setInterval(() => {
      // Left the page while recording: the microphone is let go.
      if (!document.body.contains(box)) { recorder.onstop = null; if (recorder.state === 'recording') recorder.stop(); stopStream(); return; }
      const s = Math.floor((Date.now() - startedAt) / 1000);
      const clock = box.querySelector('[data-voice="clock"]');
      if (clock) clock.textContent = `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
      if (Date.now() - startedAt >= maxMs && recorder.state === 'recording') recorder.stop();
    }, 500);
  }
  showStart();
  return { get audio() { return state.audio; }, reset };
}
// Sends a recording into the person's own folder of a private bucket; returns { path, mimeType }.
export async function uploadVoice(bucket, userId, audio) {
  const path = `${userId}/${Date.now()}.${voiceFileEnding(audio.mimeType)}`;
  const { error } = await busyWhile(sb.storage.from(bucket).upload(path, audio.blob, { contentType: audio.mimeType || undefined }), 'Sending...');
  if (error) throw error;
  return { path, mimeType: audio.mimeType || null };
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
      ${doc ? `<div class="field"><label>Document</label><div style="font-size:16px;padding:4px 0;">#${esc(doc.document_id)} &mdash; ${esc(doc.en_title) || '<span class="hint">(no title)</span>'}</div></div>` : ''}
      <div class="field"><label>Title</label><input id="bp-title" value="${esc(post ? post.title : (doc ? doc.en_title || '' : ''))}"></div>
      <div class="field"><label>Text</label><textarea id="bp-body" dir="auto" rows="8">${esc(post ? post.body : '')}</textarea></div>
      <div class="field"><label>Link <span class="hint">(optional)</span></label><input id="bp-link" placeholder="https://..." value="${esc(post ? post.link_url : '')}"></div>
      <div class="field"><label>Image <span class="hint">(optional${post && post.image_path ? ' - choose a file to replace the current one' : ''})</span></label><input id="bp-image" type="file" accept="image/jpeg,image/png,image/webp,image/gif"></div>
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
    const row = { board_code, document_id, title, body: body || null, link_url: link_url || null, image_path };
    if (post) await withStatus(sb.from('board_posts').update(row).eq('id', post.id), 'Saving...');
    else await withStatus(sb.from('board_posts').insert(row), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// The translation prompt lives in translation_prompts (106_translation_prompts.sql), append-only:
// the newest row is the one in force. Exported because both the Translate popup below and the Admin
// editor in mydepartment.js read it, and modules only import from core.js. Resolves to null if the
// table is unreadable or empty (migration not run yet, no connection) - callers say so, no fallback
// copy of the prompt is kept in the code, so there is exactly one source.
export async function fetchActiveTranslationPrompt() {
  const { data, error } = await sb.from('translation_prompts').select('id,version,body,created_at').order('id', { ascending: false }).limit(1);
  return error || !data || !data.length ? null : data[0];
}

// Phase 0 of the in-app translation helper: assembles the style-guide prompt + the source text
// for the user to paste into Claude. Deliberately makes no network call to Claude - the Anthropic
// key can't live in the browser (a real call would sit behind an Edge Function). Lives here, not in
// docdetail.js, so a standalone entry point (My Space, Dashboard) can open it without importing
// a sibling module.
export function openTranslatePopup({ text = '', title = '' } = {}) {
  document.getElementById('translate-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'translate-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Translate</h2>
      <p class="hint">This prepares a prompt to paste into Claude. The translation you get back is a draft: it must be reviewed before it is used anywhere.</p>
      ${title ? `<div style="font-size:13px;margin-bottom:6px;"><b>Title:</b> ${esc(title)}</div>` : ''}
      <textarea id="tr-text" dir="auto" placeholder="Paste the Italian or English text here" style="width:100%;min-height:40vh;font-size:14px;line-height:1.7;">${esc(text)}</textarea>
      <div class="hint" id="tr-msg" style="margin-top:6px;"></div>
      <textarea id="tr-fallback" readonly dir="auto" style="display:none;width:100%;min-height:25vh;font-size:12.5px;margin-top:6px;"></textarea>
      <div class="btn-row" style="justify-content:flex-end;margin-top:8px;">
        <button class="btn" id="tr-copy-all">Copy prompt + text</button>
        <button class="btn secondary" id="tr-copy-prompt">Copy prompt only</button>
        <button class="btn secondary" id="tr-close">Close</button>
      </div>
      <p class="hint" id="tr-version" style="margin-top:8px;">Loading the prompt...</p>
    </div>`;
  document.body.appendChild(backdrop);
  const msg = document.getElementById('tr-msg');
  const fallback = document.getElementById('tr-fallback');
  let prompt = null;
  fetchActiveTranslationPrompt().then(p => {
    prompt = p;
    const label = document.getElementById('tr-version');
    if (!label) return; // popup closed meanwhile
    if (p) label.textContent = p.version;
    else {
      label.textContent = 'No prompt found.';
      msg.textContent = 'The translation prompt could not be loaded - check your connection, or ask an Admin whether it has been set up (migration 106).';
      msg.style.color = 'var(--danger, #b3261e)';
    }
  });
  const noPrompt = () => {
    fallback.style.display = 'none';
    msg.textContent = 'The prompt is not loaded (yet) - wait a moment and try again.';
    msg.style.color = 'var(--danger, #b3261e)';
  };
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('tr-close').addEventListener('click', () => backdrop.remove());
  // On a clipboard refusal the assembled prompt is shown in a selectable textarea instead of
  // dead-ending - several operators work on phones, where a denied clipboard is common.
  // navigator.clipboard needs a secure context and can be refused by the browser; the older
  // execCommand('copy') on a selected textarea still works there (plain-http hosts, some mobile
  // and embedded browsers). Only if both fail is the user asked to copy by hand - and then the
  // message is made loud, because a silent failure leaves the *previous* clipboard content in
  // place and the user pastes the wrong thing without noticing.
  const copy = async (payload, doneMsg) => {
    let ok = false;
    try { await navigator.clipboard.writeText(payload); ok = true; } catch { /* try the fallback */ }
    if (ok) { fallback.style.display = 'none'; msg.textContent = doneMsg; msg.style.color = ''; return; }
    fallback.value = payload;
    fallback.style.display = 'block';
    fallback.focus();
    fallback.select();
    try { ok = document.execCommand('copy'); } catch { ok = false; }
    if (ok) { msg.textContent = doneMsg; msg.style.color = ''; return; }
    msg.textContent = 'NOT COPIED - your clipboard still holds the old content. Select all the text in the box below and copy it manually.';
    msg.style.color = 'var(--danger, #b3261e)';
    fallback.scrollIntoView({ block: 'nearest' });
  };
  document.getElementById('tr-copy-prompt').addEventListener('click', () => { if (!prompt) return noPrompt(); copy(prompt.body, 'Prompt copied.'); });
  document.getElementById('tr-copy-all').addEventListener('click', () => {
    if (!prompt) return noPrompt();
    const src = document.getElementById('tr-text').value.trim();
    if (!src) { fallback.style.display = 'none'; msg.textContent = 'The text field is empty - nothing copied.'; return; }
    const parts = [prompt.body, '---', title ? `Title: ${title}` : null, src].filter(p => p !== null);
    copy(parts.join('\n\n'), 'Prompt and text copied - paste them into Claude.');
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
      ${doc ? `<div class="field"><label>Document</label><div style="font-size:16px;padding:4px 0;">#${esc(doc.document_id)} &mdash; ${esc(doc.en_title) || '<span class="hint">(no title)</span>'}</div></div>` : ''}
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
// option_lists_select_anon in 16_signup_chat_splash.sql). Used for membership type.
export async function loadOptionsForSignup(listName) {
  const { data, error } = await sb.from('option_lists').select('code,label').eq('list_name', listName).order('sort_order');
  return error ? [] : data.map(r => [r.code, r.label]);
}

// ---------- Signing in with a mobile number (Owner's request, 2026-11-18) ----------
// Many members, the elderly above all, have no email or cannot confirm one. Signing up with a number goes through the
// Edge Function "phone-account" (supabase/functions/phone-account), which creates the account already confirmed with
// an internal address <digits>@phone.dua.invalid (".invalid": no mail is ever delivered there). Signing in with the
// number uses that address. Accounts made with an email keep signing in with their email.
export const PHONE_LOGIN_DOMAIN = 'phone.dua.invalid';
// The Edge Function's slug as deployed by the Owner (2026-11-18): "Phone-Account", capitals included (slugs can't be renamed).
export const PHONE_ACCOUNT_FUNCTION = 'Phone-Account';
// Digits only, Pakistan by default: 0300 1234567 -> 923001234567. Same rule as the Edge Function.
export function normalizePhone(raw) {
  let d = String(raw || '').replace(/\D/g, '');
  if (d.startsWith('00')) d = d.slice(2);
  else if (d.startsWith('0')) d = '92' + d.slice(1);
  if (d.startsWith('92') && d.length !== 12) return null;
  return d.length >= 10 && d.length <= 15 ? d : null;
}
// What to show for an account: the number for a phone account, the email otherwise.
export function displayLogin(email) {
  const s = String(email || '');
  const suffix = '@' + PHONE_LOGIN_DOMAIN;
  return s.endsWith(suffix) && /^\d+$/.test(s.slice(0, -suffix.length)) ? '+' + s.slice(0, -suffix.length) : s;
}
const PHONE_SIGNUP_ERRORS = {
  phone_invalid: 'This mobile number does not look right. Write it like 0300 1234567.',
  password_short: 'The password needs at least 8 characters.',
  password_easy: 'This password is too easy to guess. Please choose another one.',
  too_many: 'Many people are signing up at this moment. Please try again in an hour, or ask an Admin of DUA.',
  fields_missing: 'Please fill in every field.',
  phone_in_use: 'This number already has an account. Sign in with it, or ask an Admin of DUA for help.',
};

// Called explicitly from app.js, not run automatically on import - tests.html imports
// core.js too (for the pure helper functions) but has none of these DOM elements.
export function wireAuthButtons() {
  const errBox = document.getElementById('login-error');
  const showError = msg => { errBox.style.color = 'var(--danger)'; errBox.textContent = msg; };
  const showDone = msg => { errBox.style.color = 'var(--accent)'; errBox.textContent = msg; };

  document.getElementById('login-btn').addEventListener('click', async () => {
    const id = document.getElementById('login-email').value.trim();
    const password = document.getElementById('login-password').value;
    errBox.textContent = '';
    let email = id;
    if (!id.includes('@')) {
      const digits = normalizePhone(id);
      if (!digits) { showError('Write your mobile number like 0300 1234567, or your email.'); return; }
      email = digits + '@' + PHONE_LOGIN_DOMAIN;
    }
    const { error } = await sb.auth.signInWithPassword({ email, password });
    if (!error) { try { localStorage.setItem('lastActive', String(Date.now())); } catch { /* no limit */ } }
    if (error) showError(/invalid login credentials/i.test(error.message) ? 'The number (or email) or the password is not right.' : error.message);
  });

  const signupFields = document.getElementById('signup-fields');
  const switchLink = document.getElementById('auth-switch-link');
  const switchHint = document.getElementById('auth-switch-hint');
  const idInput = document.getElementById('login-email');
  let signupMode = false;
  let gender = '';

  function setSignupMode(on) {
    signupMode = on;
    signupFields.style.display = on ? 'block' : 'none';
    document.getElementById('login-btn').style.display = on ? 'none' : 'flex';
    document.getElementById('signup-btn').style.display = on ? 'flex' : 'none';
    switchHint.textContent = on ? 'Already have an account?' : 'New here?';
    switchLink.textContent = on ? 'Sign in' : 'Sign up';
    document.getElementById('login-id-label').textContent = on ? 'Mobile phone' : 'Mobile phone or email';
    document.getElementById('login-id-hint').style.display = on ? 'block' : 'none';
    idInput.type = on ? 'tel' : 'text';
    idInput.autocomplete = on ? 'tel' : 'username';
    document.getElementById('login-password-label').textContent = on ? 'Create a new password' : 'Password';
    document.getElementById('login-password').autocomplete = on ? 'new-password' : 'current-password';
    document.getElementById('forgot-password-row').style.display = on ? 'none' : 'block';
    errBox.textContent = '';
  }
  switchLink.addEventListener('click', () => setSignupMode(!signupMode));
  setSignupMode(false);
  const backToLanding = document.getElementById('back-to-landing');
  if (backToLanding) {
    backToLanding.parentElement.style.display = window.__renderLanding ? '' : 'none';
    backToLanding.addEventListener('click', () => showLogin());
  }

  document.querySelectorAll('.gender-btn').forEach(b => b.addEventListener('click', () => {
    gender = b.dataset.gender;
    document.querySelectorAll('.gender-btn').forEach(x => {
      const on = x.dataset.gender === gender;
      x.classList.toggle('secondary', !on);
      x.setAttribute('aria-checked', String(on));
    });
  }));

  loadOptionsForSignup('membership_type').then(rows => {
    document.getElementById('signup-membership').innerHTML =
      '<option value=""></option>' + rows.map(([c, l]) => `<option value="${c}">${esc(l)}</option>`).join('');
  });
  document.getElementById('signup-dob').innerHTML = dateOfBirthFieldsHtml('signup-dob');

  document.getElementById('signup-btn').addEventListener('click', async () => {
    const digits = normalizePhone(idInput.value);
    const password = document.getElementById('login-password').value;
    const full_name = document.getElementById('signup-fullname').value.trim();
    const city = document.getElementById('signup-city').value.trim();
    const membership_type = document.getElementById('signup-membership').value;
    const dob = readDateOfBirth('signup-dob');
    errBox.textContent = '';
    if (!digits) { showError(PHONE_SIGNUP_ERRORS.phone_invalid); return; }
    const weak = passwordProblem(password, digits);
    if (weak) { showError(weak); return; }
    if (!full_name || !city || !membership_type || !gender) { showError('Please fill in your full name, city, membership type, and choose Male or Female.'); return; }
    if (dob.error || !dob.value) { showError(dob.error || 'Please choose your date of birth.'); return; }
    const btn = document.getElementById('signup-btn');
    btn.disabled = true;
    showDone('Creating your account...');
    try {
      const { data, error } = await sb.functions.invoke(PHONE_ACCOUNT_FUNCTION, {
        body: { action: 'signup', phone: digits, password, full_name, city, membership_type, gender, date_of_birth: dob.value },
      });
      if (error) {
        let code = null;
        try { code = (await error.context.json()).error; } catch { /* no readable answer */ }
        console.warn('Sign-up:', error.message, code);
        showError(PHONE_SIGNUP_ERRORS[code] || 'Sign-up did not work. Check your connection and try again.');
        return;
      }
      const { error: signInError } = await sb.auth.signInWithPassword({ email: data.login, password });
      if (signInError) { setSignupMode(false); showError('Your account is ready: sign in with your number and password.'); }
    } finally {
      btn.disabled = false;
    }
  });

  document.getElementById('logout-btn').addEventListener('click', () => {
    sessionStorage.removeItem('splashShown');
    sessionStorage.removeItem('dobAsked');
    // A fresh page after signing out, so that nothing the screens kept in memory (the Help guides, qualifications)
    // carries over to the next person who signs in on the same phone.
    // This device only: the others stay signed in ("Sign out from all devices" is in My Profile).
    sb.auth.signOut({ scope: 'local' }).finally(() => { history.replaceState(null, '', location.pathname); location.reload(); });
  });

  // An email account gets a reset link; a phone account has no email, so an Admin gives a temporary password (Users).
  document.getElementById('forgot-password-link').addEventListener('click', async () => {
    const id = idInput.value.trim();
    if (!id.includes('@')) {
      showDone('If you signed up with your mobile number, ask an Admin of DUA: they will give you a new password, which you can then change in My Profile. If you signed up with an email, type your email above and tap "Forgot your password?" again.');
      return;
    }
    errBox.textContent = '';
    const { error } = await sb.auth.resetPasswordForEmail(id, { redirectTo: 'https://mediafocolarepak.github.io/Urdu-Archive/' });
    if (error) { showError(error.message); return; }
    showDone('Check your email for a link to reset your password.');
  });
}

// Fired via the onAuthStateChange 'PASSWORD_RECOVERY' event (see boot() below) once someone
// follows the reset-password link from their email - shows a dedicated "set new password"
// screen instead of the normal login/app, since the session at this point is a short-lived
// recovery session, not a real sign-in.
function showRecoveryScreen() {
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('landing-screen')?.style.setProperty('display', 'none');
  document.getElementById('app').style.display = 'none';
  document.getElementById('recovery-screen').style.display = 'flex';
  const errBox = document.getElementById('recovery-error');
  const saveBtn = document.getElementById('recovery-save-btn');
  saveBtn.onclick = async () => {
    const pw = document.getElementById('recovery-password').value;
    const pw2 = document.getElementById('recovery-password-confirm').value;
    errBox.style.color = 'var(--danger)'; errBox.textContent = '';
    const weak = passwordProblem(pw);
    if (weak) { errBox.textContent = weak; return; }
    if (pw !== pw2) { errBox.textContent = 'Passwords do not match.'; return; }
    const { error } = await sb.auth.updateUser({ password: pw });
    if (error) { errBox.textContent = error.message; return; }
    document.getElementById('recovery-screen').style.display = 'none';
    location.reload();
  };
}
