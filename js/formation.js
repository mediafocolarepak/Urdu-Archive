// Formation paths (Fase A: gerarchia contenuti, migrazione 73 - Fase B: iscrizione, migrazione
// 74). Chatroom/quiz/attestato ancora non costruiti (Fasi C/D). Un post qui e' solo titolo+testo
// libero (niente collegamento a un documento, a differenza di board_posts) per contenere lo
// scope della prima passata - vedi discussione in chat del 10/09/2026.
//
// Iscrizione (Fase B): "Enroll" e' visibile solo su un percorso pubblicato, e solo prima della
// scadenza (se impostata) - il vero controllo e' server-side in enroll_in_formation_path()
// (74_formation_enrollments.sql), questo e' solo per non mostrare un bottone che fallirebbe.
// Il ritiro non ha invece nessuna scadenza. Il conteggio e' pubblico; l'elenco nominativo
// (formation_enrollees) e' visibile solo al proprietario o a Coordinator/Admin, stesso schema
// del "Who?" delle bacheche (72_board_post_reads.sql).

import { sb, State, esc, withStatus, canReviewApplications, isDeptLead, isAdmin, optionsHtml, labelOf, today, nameMapForEmails, confirmPopup } from './core.js?v=20260920190820';

// Thumbnails (migration 93, owner's request to make the catalog "look like Coursera") - a public
// bucket, same shape as board post images (BOARD_MEDIA_BUCKET in core.js), but not shared outside
// this file so it isn't exported from core.js.
const FORMATION_MEDIA_BUCKET = 'formation-media';
const thumbnailUrl = path => path ? sb.storage.from(FORMATION_MEDIA_BUCKET).getPublicUrl(path).data.publicUrl : null;

// Standard prompt for drafting a quiz with an AI tool (GOVERNANCE.md §2.3), shared by the
// "Copy prompt" button below and the matching Help entry (see supabase/83_formation_ai_prompt_help.sql)
// so both always say the same thing - only the Markdown format actually matters (parseQuizMarkdown below).
const QUIZ_AI_PROMPT = `You are helping build a quiz for an online course module. Based on the module content below, write 8-10 multiple-choice questions in this exact Markdown format (nothing else):

## <question text>
- [ ] <wrong option>
- [ ] <wrong option>
- [x] <correct option>
- [ ] <wrong option>
points: 1

Rules:
- Each question needs at least 2 options and exactly one marked [x] as correct.
- "points: N" is optional (defaults to 1) and, if present, must be its own line right after the last option.
- Do not add numbering, explanations, or any text outside this format.

Module content:
<paste the module's text here>`;

// Parses the Markdown format above into rows ready for formation_quiz_questions. Returns every
// well-formed question plus a human-readable error per malformed one, rather than failing the
// whole import over a single typo - the caller decides whether to import the valid ones anyway.
function parseQuizMarkdown(text) {
  const lines = (text || '').split(/\r?\n/);
  const questions = [];
  const errors = [];
  let current = null;
  let qNum = 0;
  function finalizeCurrent() {
    if (!current) return;
    const opts = current.options;
    const correctCount = opts.filter(o => o.correct).length;
    const label = `Question ${current.num} ("${current.text.slice(0, 40)}")`;
    if (opts.length < 2) { errors.push(`${label}: needs at least 2 options.`); return; }
    if (correctCount !== 1) { errors.push(`${label}: exactly one option must be marked correct (found ${correctCount}).`); return; }
    questions.push({ question_text: current.text, options: opts.map(o => o.text), correct_index: opts.findIndex(o => o.correct), points: current.points });
  }
  for (const raw of lines) {
    const line = raw.trim();
    if (!line) continue;
    const hMatch = line.match(/^##\s+(.+)/);
    if (hMatch) { finalizeCurrent(); qNum++; current = { num: qNum, text: hMatch[1].trim(), options: [], points: 1 }; continue; }
    if (!current) continue;
    const optMatch = line.match(/^-\s*\[([ xX])\]\s*(.+)/);
    if (optMatch) { current.options.push({ correct: optMatch[1].toLowerCase() === 'x', text: optMatch[2].trim() }); continue; }
    const ptsMatch = line.match(/^points:\s*(\d+)/i);
    if (ptsMatch) { current.points = parseInt(ptsMatch[1], 10) || 1; continue; }
  }
  finalizeCurrent();
  if (!qNum) errors.unshift('No questions found - each question must start with a line like "## Question text".');
  return { questions, errors };
}

// A readable preview of a linked document's Urdu text - same idea as boards.js's textPreview()
// (duplicated rather than shared: project convention is modules import only from core.js).
function textPreview(body, maxChars = 280) {
  const trimmed = (body || '').trim();
  return trimmed.length > maxChars ? trimmed.slice(0, maxChars).trim() + '…' : trimmed;
}

// Which chapters are expanded in the tree - in-memory only, resets when switching paths.
let expandedChapters = new Set();
// Whether the "Who's enrolled?" list is expanded - in-memory only, resets when switching paths.
let enrolleesOpen = false;
// Which of the two chat channels are expanded - in-memory only, resets when switching paths.
let chatOpen = { students: false, formatori: false };
// Which quizzes have their manage/take panel expanded (by quiz id) - resets when switching paths.
let quizManageOpen = new Set();
let quizTakeOpen = new Set();

export async function renderFormationView(main) {
  if (State.formationSelectedPathId) await renderPathDetail(main, State.formationSelectedPathId);
  else await renderCatalog(main);
}

// ---------- Catalog ----------

async function renderCatalog(main) {
  const { data: { user } } = await sb.auth.getUser();
  const paths = await withStatus(sb.from('formation_paths').select('*').order('created_at', { ascending: false }));
  const mine = State.isFormatore ? paths.filter(p => p.owner_id === user.id) : [];
  const published = paths.filter(p => p.status === 'published' && !mine.some(m => m.id === p.id));
  const audienceList = State.optionListsByName.formation_audience || [];

  main.innerHTML = `
    <div class="panel">
      <h2>Formation Paths</h2>
      ${State.isFormatore ? `
        <h3>My Paths</h3>
        <div class="btn-row" style="margin-bottom:10px;"><button class="btn" id="fp-new">+ New path</button></div>
        <div id="fp-mine" class="field-grid wide">${mine.length ? mine.map(p => renderPathCard(p, audienceList, true)).join('') : '<div class="empty-msg">You haven’t created any path yet.</div>'}</div>
        <h3 style="margin-top:20px;">Catalog</h3>
      ` : ''}
      <div id="fp-catalog" class="field-grid wide">${published.length ? published.map(p => renderPathCard(p, audienceList, false)).join('') : ''}</div>
      ${!published.length && !mine.length ? '<div class="empty-msg">No paths available yet.</div>' : ''}
    </div>`;

  document.querySelectorAll('[data-open-path]').forEach(el => el.addEventListener('click', () => {
    State.formationSelectedPathId = parseInt(el.dataset.openPath, 10);
    expandedChapters = new Set();
    chatOpen = { students: false, formatori: false };
    quizManageOpen = new Set();
    quizTakeOpen = new Set();
    renderFormationView(main);
  }));

  if (State.isFormatore) {
    document.getElementById('fp-new').addEventListener('click', () => openPathPopup({
      onSaved: () => renderFormationView(main),
    }));
  }
}

// A handful of pleasant, fixed gradients (not random per render, so a path's card doesn't
// flicker to a different color on every refresh) - picked by the path's own id, so it stays
// stable for that path forever. Used as a placeholder cover whenever no thumbnail is uploaded,
// so the catalog reads like a grid of course cards (Coursera-style, the owner's reference) even
// before anyone gets around to adding real images.
const CARD_GRADIENTS = [
  'linear-gradient(135deg,#6b4f3b,#a9784f)', 'linear-gradient(135deg,#3b5a4f,#6f9c86)',
  'linear-gradient(135deg,#4f4a6b,#8577ad)', 'linear-gradient(135deg,#6b3b4a,#ad7789)',
  'linear-gradient(135deg,#3b526b,#5f8bad)', 'linear-gradient(135deg,#6b5f3b,#ad9a5f)',
];
function cardCoverHtml(p) {
  const url = thumbnailUrl(p.thumbnail_path);
  if (url) return `<div style="width:100%;aspect-ratio:16/9;border-radius:8px 8px 0 0;overflow:hidden;background:#eee;"><img src="${esc(url)}" alt="" style="width:100%;height:100%;object-fit:cover;display:block;"></div>`;
  const gradient = CARD_GRADIENTS[p.id % CARD_GRADIENTS.length];
  const initial = (p.title || '?').trim().charAt(0).toUpperCase();
  return `<div style="width:100%;aspect-ratio:16/9;border-radius:8px 8px 0 0;background:${gradient};display:flex;align-items:center;justify-content:center;">
    <span style="font-size:38px;font-weight:700;color:rgba(255,255,255,.85);">${esc(initial)}</span>
  </div>`;
}

function renderPathCard(p, audienceList, isMine) {
  const badge = p.status === 'draft' ? 'Draft' : (p.status === 'archived' ? 'Archived' : 'Published');
  return `
    <div class="panel" data-open-path="${p.id}" style="cursor:pointer;padding:0;overflow:hidden;display:flex;flex-direction:column;">
      ${cardCoverHtml(p)}
      <div style="padding:12px;flex:1;display:flex;flex-direction:column;">
        <div class="btn-row" style="justify-content:space-between;align-items:flex-start;">
          <div dir="auto">
            <div style="font-weight:600;">${esc(p.title)}</div>
            ${p.title_en ? `<div class="hint">${esc(p.title_en)}</div>` : ''}
          </div>
          ${isMine ? `<span class="hint" style="white-space:nowrap;">${badge}</span>` : ''}
        </div>
        ${p.description ? `<div class="hint" style="margin-top:4px;" dir="auto">${esc(textPreview(p.description, 140))}</div>` : ''}
        ${p.description_en ? `<div class="hint" style="margin-top:2px;">${esc(textPreview(p.description_en, 140))}</div>` : ''}
        <div class="hint" style="margin-top:auto;padding-top:8px;">
          ${esc(labelOf(audienceList, p.target_audience))}
          ${p.session_type === 'summer' ? ' &middot; Summer session' : ' &middot; Regular path'}
          ${p.enrollment_deadline ? ` &middot; Enroll by ${esc(p.enrollment_deadline)}` : ''}
        </div>
      </div>
    </div>`;
}

// ---------- Popup: create/edit a path ----------

function openPathPopup({ path = null, onSaved } = {}) {
  document.getElementById('fp-path-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fp-path-popup';
  backdrop.className = 'overlay-backdrop';
  const audienceList = State.optionListsByName.formation_audience || [];
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${path ? 'Edit path' : 'New path'}</h2>
      <div class="field"><label>Title</label><input id="fpp-title" dir="auto" value="${esc(path ? path.title : '')}"></div>
      <div class="field"><label>Description</label><textarea id="fpp-description" dir="auto" rows="3">${esc(path ? path.description : '')}</textarea></div>
      <div class="field"><label>English title <span class="hint">(optional gloss, shown alongside the title above)</span></label><input id="fpp-title-en" value="${esc(path ? path.title_en : '')}"></div>
      <div class="field"><label>English description <span class="hint">(optional)</span></label><textarea id="fpp-description-en" rows="2">${esc(path ? path.description_en : '')}</textarea></div>
      <div class="field"><label>Target audience</label><select id="fpp-audience">${optionsHtml(audienceList, path ? path.target_audience : '', true)}</select></div>
      <div class="field">
        <label>Thumbnail <span class="hint">(shown on the catalog card - optional, a plain color is used if you skip this)</span></label>
        ${path && path.thumbnail_path ? `<div style="margin-bottom:6px;"><img src="${esc(thumbnailUrl(path.thumbnail_path))}" alt="" style="max-width:220px;border-radius:6px;display:block;"></div>` : ''}
        <div class="btn-row" style="margin-bottom:6px;"><button type="button" class="btn secondary" id="fpp-gen-prompt">Generate image prompt</button></div>
        <div id="fpp-prompt-box" style="display:none;margin-bottom:8px;">
          <textarea id="fpp-prompt-text" dir="auto" rows="5" readonly style="font-size:12px;"></textarea>
          <div class="btn-row" style="margin-top:4px;"><button type="button" class="btn secondary" id="fpp-copy-prompt" style="padding:4px 10px;">Copy</button>
            <span class="hint">Paste this into an AI image tool (Midjourney, ChatGPT/DALL-E, Copilot...), then upload the image it gives you below.</span></div>
        </div>
        <input id="fpp-thumbnail" type="file" accept="image/*">
      </div>
      <div class="field"><label>Session type</label><select id="fpp-session">
        <option value="regular" ${!path || path.session_type === 'regular' ? 'selected' : ''}>Regular (October-May)</option>
        <option value="summer" ${path && path.session_type === 'summer' ? 'selected' : ''}>Summer (June-September)</option>
      </select></div>
      <div class="field-grid">
        <div class="field"><label>Course starts</label><input type="date" id="fpp-starts" value="${esc(path ? path.course_starts_at : '')}"></div>
        <div class="field"><label>Course ends</label><input type="date" id="fpp-ends" value="${esc(path ? path.course_ends_at : '')}"></div>
        <div class="field"><label>Enrollment deadline</label><input type="date" id="fpp-deadline" value="${esc(path ? path.enrollment_deadline : '')}"></div>
      </div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fpp-cancel">Cancel</button>
        <button class="btn" id="fpp-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fpp-cancel').addEventListener('click', () => backdrop.remove());

  // Image prompt (owner's request, session of 2026-09-18): not automatic generation - that needs
  // a paid API and a secret key this vanilla-JS/no-backend app has nowhere safe to keep (see
  // QUIZ_AI_PROMPT above for the same reasoning applied to quizzes) - just a well-formed prompt
  // built from the path's own title/description/audience, for the formatore to paste into
  // whatever AI image tool they already use, then upload the result via the file input below.
  document.getElementById('fpp-gen-prompt').addEventListener('click', () => {
    const title = document.getElementById('fpp-title').value.trim();
    if (!title) { alert('Please enter a title first.'); return; }
    const description = document.getElementById('fpp-description').value.trim();
    const audienceSel = document.getElementById('fpp-audience');
    const audienceLabel = audienceSel.selectedOptions[0] && audienceSel.selectedOptions[0].value ? audienceSel.selectedOptions[0].textContent.trim() : '';
    const promptText = [
      'Create a vibrant, modern cover illustration for an online course catalog card (16:9, landscape).',
      `Course title: "${title}"`,
      description ? `Course theme: ${description}` : null,
      audienceLabel ? `Audience: ${audienceLabel}` : null,
      'Style: colourful, contemporary, flat/illustrative design, welcoming and energetic mood, suitable for a Catholic formation/spirituality learning platform.',
      'No text, letters, numbers or logos anywhere in the image.',
    ].filter(Boolean).join('\n');
    document.getElementById('fpp-prompt-text').value = promptText;
    document.getElementById('fpp-prompt-box').style.display = 'block';
  });
  document.getElementById('fpp-copy-prompt').addEventListener('click', async () => {
    const text = document.getElementById('fpp-prompt-text').value;
    try { await navigator.clipboard.writeText(text); alert('Prompt copied - paste it into your AI image tool of choice.'); }
    catch { alert('Could not copy automatically - select the text above and copy it manually.'); }
  });

  document.getElementById('fpp-save').addEventListener('click', async () => {
    const title = document.getElementById('fpp-title').value.trim();
    if (!title) { alert('Title is required.'); return; }
    let thumbnail_path = path ? path.thumbnail_path : null;
    const file = document.getElementById('fpp-thumbnail').files[0];
    if (file) {
      const objectPath = `${Date.now()}-${file.name}`.replace(/[^a-zA-Z0-9._-]/g, '_');
      const { error } = await sb.storage.from(FORMATION_MEDIA_BUCKET).upload(objectPath, file, { upsert: true });
      if (error) { alert('Could not upload the thumbnail: ' + error.message); return; }
      thumbnail_path = objectPath;
    }
    const row = {
      title,
      description: document.getElementById('fpp-description').value.trim() || null,
      title_en: document.getElementById('fpp-title-en').value.trim() || null,
      description_en: document.getElementById('fpp-description-en').value.trim() || null,
      thumbnail_path,
      target_audience: document.getElementById('fpp-audience').value || null,
      session_type: document.getElementById('fpp-session').value,
      course_starts_at: document.getElementById('fpp-starts').value || null,
      course_ends_at: document.getElementById('fpp-ends').value || null,
      enrollment_deadline: document.getElementById('fpp-deadline').value || null,
    };
    if (path) await withStatus(sb.from('formation_paths').update(row).eq('id', path.id), 'Saving...');
    else await withStatus(sb.from('formation_paths').insert(row), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// ---------- Popup: create/edit a post ----------

function openPostPopup({ chapterId, post = null, sequence = 0, onSaved }) {
  document.getElementById('fp-post-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fp-post-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${post ? 'Edit post' : 'New post'}</h2>
      <div class="field"><label>Title</label><input id="fppost-title" value="${esc(post ? post.title : '')}"></div>
      <div class="field"><label>Text</label><textarea id="fppost-body" dir="auto" rows="8">${esc(post ? post.body : '')}</textarea></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fppost-cancel">Cancel</button>
        <button class="btn" id="fppost-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fppost-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('fppost-save').addEventListener('click', async () => {
    const title = document.getElementById('fppost-title').value.trim();
    const body = document.getElementById('fppost-body').value.trim();
    if (!title) { alert('Title is required.'); return; }
    if (!body) { alert('Text is required.'); return; }
    if (post) await withStatus(sb.from('formation_posts').update({ title, body }).eq('id', post.id), 'Saving...');
    else await withStatus(sb.from('formation_posts').insert({ chapter_id: chapterId, title, body, sequence_number: sequence }), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// ---------- Path detail ----------

async function renderPathDetail(main, pathId) {
  const { data: { user } } = await sb.auth.getUser();
  const path = await withStatus(sb.from('formation_paths').select('*').eq('id', pathId).maybeSingle());
  if (!path) { State.formationSelectedPathId = null; return renderFormationView(main); }

  // Flattened structure (migration 92): Path -> Module -> Chapter -> Post, one level shallower
  // than the original Path -> Year -> Module -> Chapter -> Post - "Anni" added a hierarchy level
  // almost nobody used (see PROJECT_HANDOFF_v29+ / GOVERNANCE.md session notes 2026-09-18).
  const modules = await withStatus(sb.from('formation_modules').select('*').eq('path_id', pathId).order('sequence_number').order('id'));
  const moduleIds = modules.map(m => m.id);
  const chapters = moduleIds.length ? await withStatus(sb.from('formation_chapters').select('*').in('module_id', moduleIds).order('sequence_number').order('id')) : [];
  const chapterIds = chapters.map(c => c.id);
  const posts = chapterIds.length ? await withStatus(sb.from('formation_posts').select('*').in('chapter_id', chapterIds).order('sequence_number').order('id')) : [];

  // Posts can optionally link an archive document (added via "+ Path" from Dashboard/My Space) -
  // same doc/text lookup pattern as renderBoardsView in boards.js.
  const docIds = [...new Set(posts.filter(p => p.document_id != null).map(p => p.document_id))];
  const docById = {}, textById = {};
  if (docIds.length) {
    const docs = await withStatus(sb.from('documents').select('document_id,en_title,ur_title').in('document_id', docIds));
    for (const d of docs) docById[d.document_id] = d;
    const texts = await withStatus(sb.from('document_texts').select('document_id,body,reviewed').in('document_id', docIds));
    for (const t of texts) textById[t.document_id] = t;
  }

  // Co-authors (migration 82): any editor works the path exactly like the owner (can_edit_path()
  // server-side); only the owner or the Formation lead may add/remove co-authors themselves.
  const editorRows = await withStatus(sb.from('formation_path_editors').select('user_id,added_by_email,created_at').eq('path_id', pathId));
  const isCoAuthor = editorRows.some(e => e.user_id === user.id);
  const canManageCoAuthors = path.owner_id === user.id || isDeptLead('FORM') || isAdmin();
  const editorProfiles = editorRows.length ? await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', editorRows.map(e => e.user_id))) : [];
  const editorProfileByUid = {}; for (const p of editorProfiles) editorProfileByUid[p.user_id] = p;
  let formMemberOptions = [];
  if (canManageCoAuthors) {
    const formMembers = await withStatus(sb.from('department_members').select('user_id').eq('department_code', 'FORM'));
    const candidateIds = formMembers.map(m => m.user_id).filter(uid => uid !== path.owner_id && !editorRows.some(e => e.user_id === uid));
    if (candidateIds.length) {
      const candidateProfiles = await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', candidateIds));
      formMemberOptions = candidateProfiles.map(p => [p.user_id, p.full_name || p.email]);
    }
  }

  const audienceList = State.optionListsByName.formation_audience || [];
  const canEdit = path.owner_id === user.id || isCoAuthor || canReviewApplications();
  const canSeeEnrollees = canEdit;  // owner or Coordinator/Admin - formation_enrollees() checks this itself too

  const chaptersOf = moduleId => chapters.filter(c => c.module_id === moduleId);
  const postsOf = chapterId => posts.filter(p => p.chapter_id === chapterId);

  const badge = path.status === 'draft' ? 'Draft' : (path.status === 'archived' ? 'Archived' : 'Published');

  let myEnrollment = null, enrolledCount = 0;
  if (path.status === 'published') {
    const [myRow, countRows] = await Promise.all([
      withStatus(sb.from('formation_enrollments').select('withdrawn_at').eq('path_id', pathId).eq('user_id', user.id).maybeSingle()),
      withStatus(sb.rpc('formation_enrollment_counts', { path_ids: [pathId] })),
    ]);
    myEnrollment = myRow;
    enrolledCount = (countRows[0] && countRows[0].enrolled_count) || 0;
  }
  const isEnrolled = myEnrollment && !myEnrollment.withdrawn_at;
  const deadlinePassed = path.enrollment_deadline && path.enrollment_deadline < today();
  // Discussion (students channel): only makes sense once the path is actually published (that's
  // when enrollment - and so a cohort to talk to - exists); the owner can still see it in draft
  // via canEdit, matching formation_chat_messages' RLS (owner always qualifies for their channel).
  const canSeeStudentsChat = path.status === 'published' && (isEnrolled || canEdit);
  // Formatori notes: works even in draft, deliberately - see 75_formation_chat.sql.
  const canSeeFormatoriChat = State.isFormatore || canReviewApplications();

  // Quiz/attestato (Fase D): riservati, non "sempre pubblici" come i post - vedi
  // 76_formation_quizzes.sql. canTakeQuiz ricalca canSeeStudentsChat (iscritto o proprietario),
  // ma senza il vincolo "solo se pubblicato": il proprietario deve poter provare il proprio
  // quiz anche mentre il percorso e' ancora in bozza.
  const canManageQuiz = canEdit;
  const canTakeQuiz = isEnrolled || canEdit;
  let quizzes = [], passedQuizIds = new Set(), latestAttemptByQuiz = {}, myCertificate = null;
  if (canManageQuiz || canTakeQuiz) {
    quizzes = await withStatus(sb.from('formation_quizzes').select('*').eq('path_id', pathId));
    const quizIds = quizzes.map(q => q.id);
    const myAttempts = quizIds.length
      ? await withStatus(sb.from('formation_quiz_attempts').select('quiz_id,passed,score_percent').eq('user_id', user.id).in('quiz_id', quizIds).order('submitted_at', { ascending: false }))
      : [];
    for (const a of myAttempts) {
      if (a.passed) passedQuizIds.add(a.quiz_id);
      if (!latestAttemptByQuiz[a.quiz_id]) latestAttemptByQuiz[a.quiz_id] = a;  // rows already newest-first
    }
    myCertificate = await withStatus(sb.from('formation_certificates').select('*').eq('path_id', pathId).eq('user_id', user.id).maybeSingle());
  }
  const finalQuiz = quizzes.find(q => q.kind === 'final') || null;
  const quizByModule = {}; for (const q of quizzes.filter(q => q.kind === 'module')) quizByModule[q.module_id] = q;
  const quizCtx = { canManage: canManageQuiz, canTake: canTakeQuiz, passedQuizIds, latestAttemptByQuiz, quizByModule };

  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;">
        <button class="btn secondary" id="fp-back">&larr; Formation Paths</button>
        <span class="hint">${badge}</span>
      </div>
      ${thumbnailUrl(path.thumbnail_path) ? `<img src="${esc(thumbnailUrl(path.thumbnail_path))}" alt="" style="width:100%;max-height:220px;object-fit:cover;border-radius:8px;margin:8px 0;">` : ''}
      <h2 dir="auto">${esc(path.title)}</h2>
      ${path.title_en ? `<div class="hint" style="margin-top:-6px;margin-bottom:6px;">${esc(path.title_en)}</div>` : ''}
      ${path.description ? `<div dir="auto" style="margin-bottom:4px;">${esc(path.description)}</div>` : ''}
      ${path.description_en ? `<div class="hint" style="margin-bottom:8px;">${esc(path.description_en)}</div>` : ''}
      <div class="hint">
        ${esc(labelOf(audienceList, path.target_audience))}
        ${path.session_type === 'summer' ? ' &middot; Summer session' : ' &middot; Regular path'}
        ${path.course_starts_at ? ` &middot; ${esc(path.course_starts_at)} &rarr; ${esc(path.course_ends_at)}` : ''}
        ${path.enrollment_deadline ? ` &middot; Enroll by ${esc(path.enrollment_deadline)}` : ''}
      </div>
      ${path.status === 'published' ? `
      <div class="hint" style="margin-top:10px;">
        ${enrolledCount} enrolled${canSeeEnrollees ? ` &middot; <span style="cursor:pointer;text-decoration:underline;" id="fp-toggle-enrollees">Who?</span>` : ''}
      </div>
      <div id="fp-enrollees-list" class="hint" style="display:${enrolleesOpen ? 'block' : 'none'};margin-top:4px;"></div>
      <div class="btn-row" style="margin-top:6px;">
        ${isEnrolled
          ? '<span class="hint">You are enrolled ✓</span><button class="btn secondary" id="fp-withdraw">Withdraw</button>'
          : (deadlinePassed
            ? '<span class="hint">Enrollment is closed for this path.</span>'
            : '<button class="btn" id="fp-enroll">Enroll</button>')}
      </div>` : ''}
      ${canEdit ? `<div class="btn-row" style="margin-top:10px;">
        <button class="btn secondary" id="fp-edit-details">Edit details</button>
        ${path.status !== 'published' ? '<button class="btn secondary" id="fp-publish">Publish</button>' : '<button class="btn secondary" id="fp-archive">Archive</button>'}
        <button class="btn danger" id="fp-delete-path">Delete path</button>
      </div>` : ''}
      ${(canEdit && (editorRows.length || canManageCoAuthors)) ? renderCoAuthorsSectionHtml(editorRows, editorProfileByUid, canManageCoAuthors, formMemberOptions) : ''}
      ${chatSectionHtml('students', 'Discussion', canSeeStudentsChat)}
      ${chatSectionHtml('formatori', 'Formatori notes (visible only to formatori)', canSeeFormatoriChat)}
      ${myCertificate ? `<div class="hint" style="margin-top:10px;">&#127891; Certificate earned on ${esc((myCertificate.issued_at || '').slice(0, 10))} &middot; code ${esc(myCertificate.certificate_code)}</div>` : ''}
      ${(canManageQuiz || canTakeQuiz) ? `<div style="margin-top:10px;">
        <div class="hint" style="margin-bottom:4px;">Final exam</div>
        ${quizBlockHtml('final', null, finalQuiz, quizCtx)}
      </div>` : ''}
      <hr style="margin:16px 0;">
      <div id="fp-tree">
        ${canEdit ? '<div class="btn-row" style="margin-bottom:10px;"><button class="btn" id="fp-add-module">+ Add module</button></div>' : ''}
        ${modules.length ? modules.map((m, i) => renderModuleBlock(m, i + 1, chaptersOf(m.id), postsOf, canEdit, quizCtx, docById, textById)).join('') : '<div class="empty-msg">No modules yet.</div>'}
      </div>
    </div>`;

  document.getElementById('fp-back').addEventListener('click', () => {
    State.formationSelectedPathId = null;
    renderFormationView(main);
  });

  const enrollBtn = document.getElementById('fp-enroll');
  if (enrollBtn) enrollBtn.addEventListener('click', async () => {
    await withStatus(sb.rpc('enroll_in_formation_path', { pid: pathId }), 'Enrolling...');
    renderPathDetail(main, pathId);
  });
  const withdrawBtn = document.getElementById('fp-withdraw');
  if (withdrawBtn) withdrawBtn.addEventListener('click', async () => {
    if (!(await confirmPopup('You will lose access to its chatroom, quizzes and certificate once those are built - the path content itself stays visible.', { title: 'Withdraw from this path?', confirmLabel: 'Withdraw' }))) return;
    await withStatus(sb.rpc('withdraw_from_formation_path', { pid: pathId }), 'Withdrawing...');
    renderPathDetail(main, pathId);
  });
  const toggleEnrolleesEl = document.getElementById('fp-toggle-enrollees');
  if (toggleEnrolleesEl) toggleEnrolleesEl.addEventListener('click', async () => {
    enrolleesOpen = !enrolleesOpen;
    const box = document.getElementById('fp-enrollees-list');
    box.style.display = enrolleesOpen ? 'block' : 'none';
    if (!enrolleesOpen) return;
    box.innerHTML = 'Loading...';
    const rows = await withStatus(sb.rpc('formation_enrollees', { pid: pathId }));
    box.innerHTML = rows.length
      ? rows.map(r => `${esc(r.full_name) || esc(r.email)} &middot; ${esc((r.enrolled_at || '').slice(0, 10))}`).join('<br>')
      : 'Nobody yet.';
  });

  if (canEdit) {
    document.getElementById('fp-edit-details').addEventListener('click', () => openPathPopup({ path, onSaved: () => renderPathDetail(main, pathId) }));
    document.getElementById('fp-delete-path').addEventListener('click', async () => {
      if (!(await confirmPopup('All its modules, chapters and posts will be deleted with it. This cannot be undone.', { title: 'Delete this whole path?', danger: true, confirmLabel: 'Delete path' }))) return;
      await withStatus(sb.from('formation_paths').delete().eq('id', pathId), 'Deleting...');
      State.formationSelectedPathId = null;
      renderFormationView(main);
    });
    const publishBtn = document.getElementById('fp-publish');
    if (publishBtn) publishBtn.addEventListener('click', async () => {
      await withStatus(sb.from('formation_paths').update({ status: 'published' }).eq('id', pathId), 'Saving...');
      renderPathDetail(main, pathId);
    });
    const archiveBtn = document.getElementById('fp-archive');
    if (archiveBtn) archiveBtn.addEventListener('click', async () => {
      await withStatus(sb.from('formation_paths').update({ status: 'archived' }).eq('id', pathId), 'Saving...');
      renderPathDetail(main, pathId);
    });
    document.getElementById('fp-add-module').addEventListener('click', () => {
      openModulePopup({ pathId, sequence: modules.length, onSaved: () => renderPathDetail(main, pathId) });
    });
  }

  wireChatSection(main, pathId, 'students', canSeeStudentsChat);
  wireChatSection(main, pathId, 'formatori', canSeeFormatoriChat);
  wireCoAuthorsActions(main, pathId, canManageCoAuthors);
  wireQuizActions(main, pathId, quizzes);

  wireTreeActions(main, pathId, modules, chapters, posts, canEdit);
}

// ---------- Co-authors (migration 82) ----------

function renderCoAuthorsSectionHtml(editorRows, profileByUid, canManage, formMemberOptions) {
  const nameOf = uid => esc(profileByUid[uid]?.full_name || profileByUid[uid]?.email || uid);
  if (!canManage) {
    return editorRows.length ? `<div class="hint" style="margin-top:10px;">Co-authors: ${editorRows.map(e => nameOf(e.user_id)).join(', ')}</div>` : '';
  }
  return `
    <div style="margin-top:10px;">
      <div class="hint" style="font-weight:600;">Co-authors <span class="hint" style="font-weight:normal;">— work this path exactly like the owner</span></div>
      ${editorRows.length ? editorRows.map(e => `
        <div class="btn-row" style="justify-content:space-between;max-width:320px;margin:2px 0;">
          <span>${nameOf(e.user_id)}</span>
          <button class="btn secondary" data-remove-coauthor="${esc(e.user_id)}" style="padding:2px 8px;">Remove</button>
        </div>`).join('') : '<div class="hint">No co-authors yet.</div>'}
      ${formMemberOptions.length ? `
        <div class="field" style="max-width:320px;margin-top:6px;">
          <label>Add co-author <span class="hint">(Formation department members)</span></label>
          <div class="btn-row">
            <select id="fp-coauthor-add">${optionsHtml(formMemberOptions, '', true)}</select>
            <button class="btn secondary" id="fp-coauthor-add-btn" style="padding:4px 10px;">Add</button>
          </div>
        </div>` : '<div class="hint" style="margin-top:6px;">No other Formation department members available to add.</div>'}
    </div>`;
}

function wireCoAuthorsActions(main, pathId, canManageCoAuthors) {
  if (!canManageCoAuthors) return;
  const addBtn = document.getElementById('fp-coauthor-add-btn');
  if (addBtn) addBtn.addEventListener('click', async () => {
    const sel = document.getElementById('fp-coauthor-add');
    if (!sel.value) return;
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('formation_path_editors').insert({ path_id: pathId, user_id: sel.value, added_by_email: user.email }), 'Adding...');
    renderPathDetail(main, pathId);
  });
  document.querySelectorAll('[data-remove-coauthor]').forEach(btn => btn.addEventListener('click', async () => {
    if (!(await confirmPopup('They will lose edit access to this path.', { title: 'Remove this co-author?', danger: true, confirmLabel: 'Remove' }))) return;
    await withStatus(sb.from('formation_path_editors').delete().eq('path_id', pathId).eq('user_id', btn.dataset.removeCoauthor), 'Removing...');
    renderPathDetail(main, pathId);
  }));
}

// ---------- Chat (Fase C) ----------

function chatSectionHtml(channel, label, canAccess) {
  if (!canAccess) return '';
  const isOpen = chatOpen[channel];
  return `
    <div style="margin-top:10px;">
      <span style="cursor:pointer;text-decoration:underline;font-weight:600;" data-toggle-chat="${channel}">${isOpen ? '&#9662;' : '&#9656;'} ${esc(label)}</span>
      ${isOpen ? `<div style="margin-top:8px;">
        <div class="chat-thread" id="fp-chat-thread-${channel}"></div>
        <div class="field"><textarea id="fp-chat-input-${channel}" rows="2" dir="auto" placeholder="Write a message..."></textarea></div>
        <div class="btn-row" style="justify-content:flex-end;"><button class="btn" id="fp-chat-send-${channel}">Send</button></div>
      </div>` : ''}
    </div>`;
}

function wireChatSection(main, pathId, channel, canAccess) {
  if (!canAccess) return;
  const toggle = document.querySelector(`[data-toggle-chat="${channel}"]`);
  if (toggle) toggle.addEventListener('click', () => {
    chatOpen[channel] = !chatOpen[channel];
    renderPathDetail(main, pathId);
  });
  if (chatOpen[channel]) refreshChatThread(main, pathId, channel);
}

async function refreshChatThread(main, pathId, channel) {
  const { data: { user } } = await sb.auth.getUser();
  const rows = await withStatus(sb.from('formation_chat_messages').select('*').eq('path_id', pathId).eq('channel', channel).order('created_at'));
  const nameMap = await nameMapForEmails(rows.map(r => r.user_email));
  const box = document.getElementById(`fp-chat-thread-${channel}`);
  if (!box) return;
  box.innerHTML = rows.length
    ? rows.map(r => `
      <div class="chat-bubble ${r.user_id === user.id ? 'from-user' : 'from-admin'}">
        <div class="chat-meta">${esc(nameMap[r.user_email] || r.user_email)} &middot; ${esc((r.created_at || '').slice(0, 16).replace('T', ' '))}</div>
        <div dir="auto">${esc(r.message_text)}</div>
      </div>`).join('')
    : '<div class="empty-msg">No messages yet.</div>';
  box.scrollTop = box.scrollHeight;

  document.getElementById(`fp-chat-send-${channel}`).addEventListener('click', async () => {
    const input = document.getElementById(`fp-chat-input-${channel}`);
    const text = input.value.trim();
    if (!text) return;
    await withStatus(sb.from('formation_chat_messages').insert({ path_id: pathId, channel, message_text: text, user_email: user.email }), 'Sending...');
    renderPathDetail(main, pathId);
  });
}

// Numbered like a table of contents someone would write by hand ("Module 1", "Chapter 1.2") -
// the whole point of flattening away "Years" (migration 92) was to make this outline read like
// a course index, not a database tree, for formatori who are far more at home with paper/Word/
// Excel than with nested admin screens.
function renderModuleBlock(m, moduleNumber, chapters, postsOf, canEdit, quizCtx, docById, textById) {
  return `
  <div class="panel" style="margin-bottom:10px;" data-module-block="${m.id}">
    <div class="btn-row" style="justify-content:space-between;">
      <div style="font-weight:600;" dir="auto">Module ${moduleNumber} &mdash; ${esc(m.title)}</div>
      ${canEdit ? `<div class="btn-row">
        <button class="btn secondary" data-move-module-up="${m.id}" style="padding:2px 6px;">&#9650;</button>
        <button class="btn secondary" data-move-module-down="${m.id}" style="padding:2px 6px;">&#9660;</button>
        <button class="btn secondary" data-edit-module="${m.id}" style="padding:2px 6px;">Edit</button>
        <button class="btn secondary" data-add-chapter="${m.id}" style="padding:2px 6px;">+ Chapter</button>
        <button class="btn danger" data-delete-module="${m.id}" style="padding:2px 6px;">Delete</button>
      </div>` : ''}
    </div>
    ${m.description ? `<div class="hint" dir="auto">${esc(m.description)}</div>` : ''}
    ${(quizCtx.canManage || quizCtx.canTake) ? quizBlockHtml('module', m.id, quizCtx.quizByModule[m.id], quizCtx) : ''}
    ${chapters.length ? chapters.map((c, i) => renderChapterBlock(c, `${moduleNumber}.${i + 1}`, postsOf(c.id), canEdit, docById, textById)).join('') : '<div class="hint">No chapters yet.</div>'}
  </div>`;
}

// Title + description, used both to create a new module (pathId given, module null) and to
// edit an existing one (module given) - same shape as openPathPopup/openPostPopup elsewhere in
// this file.
function openModulePopup({ pathId, module = null, sequence = 0, onSaved }) {
  document.getElementById('fm-module-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fm-module-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${module ? 'Edit module' : 'New module'}</h2>
      <div class="field"><label>Title</label><input id="fm-module-title" dir="auto" value="${esc(module ? module.title : '')}"></div>
      <div class="field"><label>Description <span class="hint">(optional)</span></label><textarea id="fm-module-desc" dir="auto" rows="3">${esc(module ? module.description || '' : '')}</textarea></div>
      <div class="hint" id="fm-module-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fm-module-cancel">Cancel</button>
        <button class="btn" id="fm-module-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fm-module-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('fm-module-save').addEventListener('click', async () => {
    const title = document.getElementById('fm-module-title').value.trim();
    const description = document.getElementById('fm-module-desc').value.trim() || null;
    if (!title) { document.getElementById('fm-module-error').textContent = 'Title is required.'; return; }
    if (module) await withStatus(sb.from('formation_modules').update({ title, description }).eq('id', module.id), 'Saving...');
    else await withStatus(sb.from('formation_modules').insert({ path_id: pathId, title, description, sequence_number: sequence }), 'Saving...');
    backdrop.remove();
    onSaved();
  });
}

// Title-only counterpart to openModulePopup above, for creating/renaming a chapter - replaces
// the plain prompt() this used to be (session of 2026-09-18, same pass that replaced confirm()
// with confirmPopup() throughout this file).
function openChapterPopup({ moduleId, chapter = null, sequence = 0, onSaved }) {
  document.getElementById('fm-chapter-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fm-chapter-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${chapter ? 'Rename chapter' : 'New chapter'}</h2>
      <div class="field"><label>Title</label><input id="fm-chapter-title" dir="auto" value="${esc(chapter ? chapter.title : '')}"></div>
      <div class="hint" id="fm-chapter-error"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fm-chapter-cancel">Cancel</button>
        <button class="btn" id="fm-chapter-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fm-chapter-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('fm-chapter-save').addEventListener('click', async () => {
    const title = document.getElementById('fm-chapter-title').value.trim();
    if (!title) { document.getElementById('fm-chapter-error').textContent = 'Title is required.'; return; }
    if (chapter) await withStatus(sb.from('formation_chapters').update({ title }).eq('id', chapter.id), 'Saving...');
    else await withStatus(sb.from('formation_chapters').insert({ module_id: moduleId, title, sequence_number: sequence }), 'Saving...');
    backdrop.remove();
    onSaved();
  });
}

// ---------- Quiz & certificate (Fase D) ----------

function quizBlockHtml(kind, moduleId, quiz, quizCtx) {
  const { canManage, canTake, passedQuizIds, latestAttemptByQuiz } = quizCtx;
  const noun = kind === 'final' ? 'final exam' : 'quiz';
  if (!quiz) {
    return canManage
      ? `<div class="hint" style="margin:4px 0;"><span style="cursor:pointer;text-decoration:underline;" data-create-quiz="1" data-kind="${kind}" data-module-id="${moduleId || ''}">+ Add ${noun}</span></div>`
      : `<div class="hint" style="margin:4px 0;">No ${noun} yet.</div>`;
  }
  const passed = passedQuizIds.has(quiz.id);
  const latest = latestAttemptByQuiz[quiz.id];
  const manageOpen = quizManageOpen.has(quiz.id);
  const takeOpen = quizTakeOpen.has(quiz.id);
  return `
    <div style="margin:6px 0;padding:8px;border:1px dashed var(--accent-soft);border-radius:6px;">
      <div class="btn-row" style="justify-content:space-between;flex-wrap:wrap;">
        <div dir="auto"><strong>${esc(quiz.title)}</strong> <span class="hint">(pass ${quiz.pass_threshold_percent}%)</span>
          ${passed ? ' <span class="hint">&check; Passed</span>' : (latest ? ` <span class="hint">Last score: ${latest.score_percent}%</span>` : '')}
        </div>
        <div class="btn-row">
          ${canManage ? `<button class="btn secondary" data-manage-quiz="${quiz.id}" style="padding:2px 8px;">${manageOpen ? 'Close' : 'Manage'}</button>` : ''}
          ${canTake ? `<button class="btn secondary" data-take-quiz="${quiz.id}" style="padding:2px 8px;">${takeOpen ? 'Close' : (passed ? 'Retake' : 'Take quiz')}</button>` : ''}
        </div>
      </div>
      ${manageOpen ? `<div id="fp-quiz-manage-${quiz.id}" style="margin-top:8px;">Loading...</div>` : ''}
      ${takeOpen ? `<div id="fp-quiz-take-${quiz.id}" style="margin-top:8px;">Loading...</div>` : ''}
    </div>`;
}

function openQuizMetaPopup({ title, quiz = null, onSaved }) {
  document.getElementById('fp-quizmeta-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fp-quizmeta-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel" style="max-width:400px;">
      <h2 style="margin-top:0;">${esc(title)}</h2>
      <div class="field"><label>Title</label><input id="fqm-title" value="${esc(quiz ? quiz.title : '')}"></div>
      <div class="field"><label>Pass threshold (%)</label><input id="fqm-threshold" type="number" min="1" max="100" value="${quiz ? quiz.pass_threshold_percent : 70}"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fqm-cancel">Cancel</button>
        <button class="btn" id="fqm-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fqm-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('fqm-save').addEventListener('click', () => {
    const t = document.getElementById('fqm-title').value.trim();
    const pct = parseInt(document.getElementById('fqm-threshold').value, 10);
    if (!t) { alert('Title is required.'); return; }
    if (!Number.isFinite(pct) || pct < 1 || pct > 100) { alert('Pass threshold must be a number between 1 and 100.'); return; }
    backdrop.remove();
    onSaved({ title: t, pass_threshold_percent: pct });
  });
}

function openQuestionPopup({ quizId, question = null, sequence = 0, onSaved }) {
  document.getElementById('fp-question-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fp-question-popup';
  backdrop.className = 'overlay-backdrop';
  const optionsText = question ? question.options.join('\n') : '';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">${question ? 'Edit question' : 'New question'}</h2>
      <div class="field"><label>Question</label><textarea id="fq-text" dir="auto" rows="2">${esc(question ? question.question_text : '')}</textarea></div>
      <div class="field"><label>Options <span class="hint">(one per line, at least 2)</span></label><textarea id="fq-options" dir="auto" rows="5">${esc(optionsText)}</textarea></div>
      <div class="field"><label>Correct option number <span class="hint">(1, 2, 3...)</span></label><input id="fq-correct" type="number" min="1" value="${question ? question.correct_index + 1 : 1}"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fq-cancel">Cancel</button>
        <button class="btn" id="fq-save">Save</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fq-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('fq-save').addEventListener('click', async () => {
    const question_text = document.getElementById('fq-text').value.trim();
    const options = document.getElementById('fq-options').value.split('\n').map(s => s.trim()).filter(Boolean);
    const correctNum = parseInt(document.getElementById('fq-correct').value, 10);
    if (!question_text) { alert('Question text is required.'); return; }
    if (options.length < 2) { alert('At least 2 options are required.'); return; }
    if (!Number.isFinite(correctNum) || correctNum < 1 || correctNum > options.length) { alert('Correct option number must be within the option list.'); return; }
    const row = { question_text, options, correct_index: correctNum - 1 };
    if (question) await withStatus(sb.from('formation_quiz_questions').update(row).eq('id', question.id), 'Saving...');
    else await withStatus(sb.from('formation_quiz_questions').insert({ quiz_id: quizId, sequence_number: sequence, ...row }), 'Saving...');
    backdrop.remove();
    if (onSaved) onSaved();
  });
}

// Pastes the QUIZ_AI_PROMPT format, parses it client-side (parseQuizMarkdown), and inserts every
// well-formed question in one batch - matching questions are skipped with a reason shown inline
// rather than blocking the whole import over one malformed line.
function openImportQuizPopup({ quizId, startingSequence, onSaved }) {
  document.getElementById('fp-import-quiz-popup')?.remove();
  const backdrop = document.createElement('div');
  backdrop.id = 'fp-import-quiz-popup';
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Import quiz from Markdown</h2>
      <p class="hint">Paste questions in the standard format (see "Copy AI prompt", or Help). Valid questions are imported even if others have errors.</p>
      <div class="field"><textarea id="fiq-text" rows="12" placeholder="## Question text&#10;- [ ] wrong option&#10;- [x] correct option&#10;points: 1"></textarea></div>
      <div id="fiq-errors" class="hint" style="color:var(--danger);white-space:pre-wrap;"></div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="fiq-cancel">Cancel</button>
        <button class="btn" id="fiq-import">Import</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('fiq-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('fiq-import').addEventListener('click', async () => {
    const { questions, errors } = parseQuizMarkdown(document.getElementById('fiq-text').value);
    const errBox = document.getElementById('fiq-errors');
    errBox.textContent = errors.join('\n');
    if (!questions.length) { if (!errors.length) errBox.textContent = 'Nothing to import.'; return; }
    const rows = questions.map((q, i) => ({ quiz_id: quizId, sequence_number: startingSequence + i, ...q }));
    await withStatus(sb.from('formation_quiz_questions').insert(rows), 'Importing...');
    backdrop.remove();
    if (errors.length) alert(`Imported ${questions.length} question(s); ${errors.length} were skipped:\n\n${errors.join('\n')}`);
    if (onSaved) onSaved();
  });
}

async function renderQuizManagePanel(main, pathId, quiz) {
  const box = document.getElementById(`fp-quiz-manage-${quiz.id}`);
  if (!box) return;
  const questions = await withStatus(sb.from('formation_quiz_questions').select('*').eq('quiz_id', quiz.id).order('sequence_number').order('id'));
  box.innerHTML = `
    <div class="btn-row" style="justify-content:flex-end;margin-bottom:6px;">
      <button class="btn secondary" data-edit-quiz-meta="1" style="padding:2px 8px;">Edit title/threshold</button>
      <button class="btn danger" data-delete-quiz="1" style="padding:2px 8px;">Delete quiz</button>
    </div>
    ${questions.length ? questions.map((q, i) => `
      <div style="padding:6px 0;border-top:1px solid var(--accent-soft);">
        <div dir="auto"><strong>${i + 1}.</strong> ${esc(q.question_text)}</div>
        <div class="hint">${q.options.map((o, idx) => `${idx === q.correct_index ? '&check; ' : ''}${esc(o)}`).join(' &middot; ')}</div>
        <div class="btn-row" style="margin-top:2px;">
          <button class="btn secondary" data-edit-question="${q.id}" style="padding:2px 6px;">Edit</button>
          <button class="btn danger" data-delete-question="${q.id}" style="padding:2px 6px;">Delete</button>
        </div>
      </div>`).join('') : '<div class="hint">No questions yet.</div>'}
    <div class="btn-row" style="margin-top:8px;">
      <button class="btn secondary" data-add-question="1">+ Add question</button>
      <button class="btn secondary" data-import-quiz-md="1">Import quiz (.md)</button>
      <button class="btn secondary" data-copy-ai-prompt="1">Copy AI prompt</button>
    </div>`;

  box.querySelector('[data-edit-quiz-meta]').addEventListener('click', () => {
    openQuizMetaPopup({ title: 'Edit quiz', quiz, onSaved: async fields => {
      await withStatus(sb.from('formation_quizzes').update(fields).eq('id', quiz.id), 'Saving...');
      renderPathDetail(main, pathId);
    } });
  });
  box.querySelector('[data-delete-quiz]').addEventListener('click', async () => {
    if (!(await confirmPopup('All its questions and every attempt at it will be deleted too. This cannot be undone.', { title: 'Delete this quiz?', danger: true, confirmLabel: 'Delete quiz' }))) return;
    await withStatus(sb.from('formation_quizzes').delete().eq('id', quiz.id), 'Deleting...');
    renderPathDetail(main, pathId);
  });
  box.querySelector('[data-add-question]').addEventListener('click', () => {
    openQuestionPopup({ quizId: quiz.id, sequence: questions.length, onSaved: () => renderPathDetail(main, pathId) });
  });
  box.querySelector('[data-import-quiz-md]').addEventListener('click', () => {
    openImportQuizPopup({ quizId: quiz.id, startingSequence: questions.length, onSaved: () => renderPathDetail(main, pathId) });
  });
  box.querySelector('[data-copy-ai-prompt]').addEventListener('click', async () => {
    try { await navigator.clipboard.writeText(QUIZ_AI_PROMPT); alert('Prompt copied - paste it into your AI tool of choice, then paste the module content where it says so.'); }
    catch { alert('Could not copy automatically - the prompt is also in Help ("Formation: drafting a quiz with AI").'); }
  });
  box.querySelectorAll('[data-edit-question]').forEach(el => el.addEventListener('click', () => {
    const q = questions.find(x => x.id === parseInt(el.dataset.editQuestion, 10));
    openQuestionPopup({ quizId: quiz.id, question: q, onSaved: () => renderPathDetail(main, pathId) });
  }));
  box.querySelectorAll('[data-delete-question]').forEach(el => el.addEventListener('click', async () => {
    if (!(await confirmPopup('This cannot be undone.', { title: 'Delete this question?', danger: true, confirmLabel: 'Delete' }))) return;
    await withStatus(sb.from('formation_quiz_questions').delete().eq('id', el.dataset.deleteQuestion), 'Deleting...');
    renderPathDetail(main, pathId);
  }));
}

async function renderQuizTakePanel(main, pathId, quiz) {
  const box = document.getElementById(`fp-quiz-take-${quiz.id}`);
  if (!box) return;
  const questions = await withStatus(sb.rpc('formation_quiz_for_taking', { qid: quiz.id }));
  if (!questions.length) { box.innerHTML = '<div class="hint">This quiz has no questions yet.</div>'; return; }
  box.innerHTML = questions.map((q, i) => `
    <div style="margin-bottom:10px;">
      <div dir="auto"><strong>${i + 1}.</strong> ${esc(q.question_text)}</div>
      ${q.options.map((o, idx) => `
        <label style="display:block;text-transform:none;font-size:13px;padding:2px 0;">
          <input type="radio" name="fq-answer-${q.question_id}" value="${idx}" style="width:auto;"> ${esc(o)}
        </label>`).join('')}
    </div>`).join('')
    + `<div class="btn-row"><button class="btn" id="fp-quiz-submit-${quiz.id}">Submit</button></div>
       <div id="fp-quiz-result-${quiz.id}" class="hint" style="margin-top:6px;"></div>`;

  document.getElementById(`fp-quiz-submit-${quiz.id}`).addEventListener('click', async () => {
    const answers = {};
    questions.forEach(q => {
      const checked = box.querySelector(`input[name="fq-answer-${q.question_id}"]:checked`);
      if (checked) answers[q.question_id] = parseInt(checked.value, 10);
    });
    const [result] = await withStatus(sb.rpc('submit_formation_quiz_attempt', { qid: quiz.id, answers }), 'Submitting...');
    const resultBox = document.getElementById(`fp-quiz-result-${quiz.id}`);
    resultBox.textContent = `Score: ${result.score_percent}% - ${result.passed ? 'Passed ✓' : 'Not passed yet - you can try again.'}`;
    setTimeout(() => renderPathDetail(main, pathId), 1400);
  });
}

function wireQuizActions(main, pathId, quizzes) {
  document.querySelectorAll('[data-create-quiz]').forEach(el => el.addEventListener('click', () => {
    const kind = el.dataset.kind;
    const moduleId = el.dataset.moduleId ? parseInt(el.dataset.moduleId, 10) : null;
    openQuizMetaPopup({
      title: kind === 'final' ? 'New final exam' : 'New quiz',
      onSaved: async fields => {
        await withStatus(sb.from('formation_quizzes').insert({ path_id: pathId, module_id: moduleId, kind, ...fields }), 'Saving...');
        renderPathDetail(main, pathId);
      },
    });
  }));
  document.querySelectorAll('[data-manage-quiz]').forEach(el => el.addEventListener('click', () => {
    const qid = parseInt(el.dataset.manageQuiz, 10);
    if (quizManageOpen.has(qid)) quizManageOpen.delete(qid); else quizManageOpen.add(qid);
    renderPathDetail(main, pathId);
  }));
  document.querySelectorAll('[data-take-quiz]').forEach(el => el.addEventListener('click', () => {
    const qid = parseInt(el.dataset.takeQuiz, 10);
    if (quizTakeOpen.has(qid)) quizTakeOpen.delete(qid); else quizTakeOpen.add(qid);
    renderPathDetail(main, pathId);
  }));
  quizzes.forEach(q => {
    if (quizManageOpen.has(q.id)) renderQuizManagePanel(main, pathId, q);
    if (quizTakeOpen.has(q.id)) renderQuizTakePanel(main, pathId, q);
  });
}

function renderChapterBlock(c, chapterLabel, posts, canEdit, docById, textById) {
  const isOpen = expandedChapters.has(c.id);
  return `
  <div style="margin:8px 0 8px 16px;padding:8px;border:1px solid var(--accent-soft);border-radius:6px;" data-chapter-block="${c.id}">
    <div class="btn-row" style="justify-content:space-between;">
      <span style="font-weight:600;cursor:pointer;" data-toggle-chapter="${c.id}" dir="auto">${isOpen ? '&#9662;' : '&#9656;'} Chapter ${esc(chapterLabel)} &mdash; ${esc(c.title)} <span class="hint">(${posts.length})</span></span>
      ${canEdit ? `<div class="btn-row">
        <button class="btn secondary" data-move-chapter-up="${c.id}" style="padding:2px 6px;">&#9650;</button>
        <button class="btn secondary" data-move-chapter-down="${c.id}" style="padding:2px 6px;">&#9660;</button>
        <button class="btn secondary" data-rename-chapter="${c.id}" style="padding:2px 6px;">Rename</button>
        <button class="btn secondary" data-add-post="${c.id}" style="padding:2px 6px;">+ Post</button>
        <button class="btn danger" data-delete-chapter="${c.id}" style="padding:2px 6px;">Delete</button>
      </div>` : ''}
    </div>
    ${isOpen ? `<div style="margin-top:6px;">${posts.length ? posts.map(p => renderPostRow(p, canEdit, docById[p.document_id], textById[p.document_id])).join('') : '<div class="hint">No posts yet.</div>'}</div>` : ''}
  </div>`;
}

function renderPostRow(p, canEdit, doc, text) {
  return `
  <div style="padding:6px 0;border-top:1px solid var(--accent-soft);" data-post-row="${p.id}">
    <div class="btn-row" style="justify-content:space-between;align-items:flex-start;">
      <div style="font-weight:600;" dir="auto">${esc(p.title)}</div>
      ${canEdit ? `<div class="btn-row">
        <button class="btn secondary" data-move-post-up="${p.id}" style="padding:2px 6px;">&#9650;</button>
        <button class="btn secondary" data-move-post-down="${p.id}" style="padding:2px 6px;">&#9660;</button>
        <button class="btn secondary" data-edit-post="${p.id}" style="padding:2px 6px;">Edit</button>
        <button class="btn danger" data-delete-post="${p.id}" style="padding:2px 6px;">Delete</button>
      </div>` : ''}
    </div>
    ${p.body ? `<div dir="auto" style="white-space:pre-wrap;">${esc(p.body)}</div>` : ''}
    ${doc ? `<div class="field" style="margin-top:6px;">
      <label>Document</label>
      <div style="font-size:13px;">#${esc(doc.document_id)} &middot; ${esc(doc.en_title) || '<span class="hint">(no title)</span>'}${doc.ur_title ? ` / <span dir="auto">${esc(doc.ur_title)}</span>` : ''}</div>
      ${text ? `<div class="board-doc-preview" dir="auto">${esc(textPreview(text.body))}</div>` : ''}
      <button class="btn secondary" data-open-doc="${esc(doc.document_id)}" style="margin-top:4px;">Open</button>
    </div>` : ''}
  </div>`;
}

// Swaps sequence_number between an item and its neighbor in the given direction, within the
// sibling list passed in (already ordered like the query - sequence_number then id).
async function reorderSibling(table, siblings, id, dir, onDone) {
  const idx = siblings.findIndex(x => x.id === id);
  const j = idx + dir;
  if (idx < 0 || j < 0 || j >= siblings.length) return;
  const a = siblings[idx], b = siblings[j];
  await withStatus(sb.from(table).update({ sequence_number: b.sequence_number }).eq('id', a.id), 'Saving...');
  await withStatus(sb.from(table).update({ sequence_number: a.sequence_number }).eq('id', b.id), 'Saving...');
  onDone();
}

function wireTreeActions(main, pathId, modules, chapters, posts, canEdit) {
  const refresh = () => renderPathDetail(main, pathId);

  document.querySelectorAll('[data-toggle-chapter]').forEach(el => el.addEventListener('click', () => {
    const id = parseInt(el.dataset.toggleChapter, 10);
    if (expandedChapters.has(id)) expandedChapters.delete(id); else expandedChapters.add(id);
    refresh();
  }));

  document.querySelectorAll('[data-open-doc]').forEach(btn => btn.addEventListener('click', () => {
    State.selectedDocId = btn.dataset.openDoc;
    window.__renderTab('dashboard');
  }));

  if (!canEdit) return;

  document.querySelectorAll('[data-move-module-up]').forEach(el => el.addEventListener('click', () => {
    const m = modules.find(x => x.id === parseInt(el.dataset.moveModuleUp, 10));
    reorderSibling('formation_modules', modules, m.id, -1, refresh);
  }));
  document.querySelectorAll('[data-move-module-down]').forEach(el => el.addEventListener('click', () => {
    const m = modules.find(x => x.id === parseInt(el.dataset.moveModuleDown, 10));
    reorderSibling('formation_modules', modules, m.id, 1, refresh);
  }));
  document.querySelectorAll('[data-edit-module]').forEach(el => el.addEventListener('click', () => {
    const m = modules.find(x => x.id === parseInt(el.dataset.editModule, 10));
    openModulePopup({ pathId, module: m, onSaved: refresh });
  }));
  document.querySelectorAll('[data-delete-module]').forEach(el => el.addEventListener('click', async () => {
    if (!(await confirmPopup('All its chapters and posts will be deleted with it.', { title: 'Delete this module?', danger: true, confirmLabel: 'Delete module' }))) return;
    await withStatus(sb.from('formation_modules').delete().eq('id', el.dataset.deleteModule), 'Deleting...');
    refresh();
  }));
  document.querySelectorAll('[data-add-chapter]').forEach(el => el.addEventListener('click', () => {
    const moduleId = parseInt(el.dataset.addChapter, 10);
    const siblingCount = chapters.filter(c => c.module_id === moduleId).length;
    openChapterPopup({ moduleId, sequence: siblingCount, onSaved: refresh });
  }));

  document.querySelectorAll('[data-move-chapter-up]').forEach(el => el.addEventListener('click', () => {
    const c = chapters.find(x => x.id === parseInt(el.dataset.moveChapterUp, 10));
    reorderSibling('formation_chapters', chapters.filter(x => x.module_id === c.module_id), c.id, -1, refresh);
  }));
  document.querySelectorAll('[data-move-chapter-down]').forEach(el => el.addEventListener('click', () => {
    const c = chapters.find(x => x.id === parseInt(el.dataset.moveChapterDown, 10));
    reorderSibling('formation_chapters', chapters.filter(x => x.module_id === c.module_id), c.id, 1, refresh);
  }));
  document.querySelectorAll('[data-rename-chapter]').forEach(el => el.addEventListener('click', () => {
    const c = chapters.find(x => x.id === parseInt(el.dataset.renameChapter, 10));
    openChapterPopup({ moduleId: c.module_id, chapter: c, onSaved: refresh });
  }));
  document.querySelectorAll('[data-delete-chapter]').forEach(el => el.addEventListener('click', async () => {
    if (!(await confirmPopup('All its posts will be deleted with it.', { title: 'Delete this chapter?', danger: true, confirmLabel: 'Delete chapter' }))) return;
    await withStatus(sb.from('formation_chapters').delete().eq('id', el.dataset.deleteChapter), 'Deleting...');
    refresh();
  }));
  document.querySelectorAll('[data-add-post]').forEach(el => el.addEventListener('click', () => {
    const chapterId = parseInt(el.dataset.addPost, 10);
    const siblingCount = posts.filter(p => p.chapter_id === chapterId).length;
    expandedChapters.add(chapterId);
    openPostPopup({ chapterId, sequence: siblingCount, onSaved: refresh });
  }));

  document.querySelectorAll('[data-move-post-up]').forEach(el => el.addEventListener('click', () => {
    const p = posts.find(x => x.id === parseInt(el.dataset.movePostUp, 10));
    reorderSibling('formation_posts', posts.filter(x => x.chapter_id === p.chapter_id), p.id, -1, refresh);
  }));
  document.querySelectorAll('[data-move-post-down]').forEach(el => el.addEventListener('click', () => {
    const p = posts.find(x => x.id === parseInt(el.dataset.movePostDown, 10));
    reorderSibling('formation_posts', posts.filter(x => x.chapter_id === p.chapter_id), p.id, 1, refresh);
  }));
  document.querySelectorAll('[data-edit-post]').forEach(el => el.addEventListener('click', () => {
    const p = posts.find(x => x.id === parseInt(el.dataset.editPost, 10));
    openPostPopup({ chapterId: p.chapter_id, post: p, onSaved: refresh });
  }));
  document.querySelectorAll('[data-delete-post]').forEach(el => el.addEventListener('click', async () => {
    if (!(await confirmPopup('This cannot be undone.', { title: 'Delete this post?', danger: true, confirmLabel: 'Delete' }))) return;
    await withStatus(sb.from('formation_posts').delete().eq('id', el.dataset.deletePost), 'Deleting...');
    refresh();
  }));
}
