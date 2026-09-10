// Formation paths (Fase A, migrazione 73): solo gerarchia contenuti e CRUD per il formatore
// proprietario - niente iscrizione/chatroom/quiz/attestato ancora (Fasi B/C/D). Un post qui e'
// solo titolo+testo libero (niente collegamento a un documento, a differenza di board_posts)
// per contenere lo scope di questa prima passata - vedi discussione in chat del 10/09/2026.

import { sb, State, esc, withStatus, canReviewApplications, optionsHtml, labelOf } from './core.js?v=20260910212728';

// Which chapters are expanded in the tree - in-memory only, resets when switching paths.
let expandedChapters = new Set();

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
        <div id="fp-mine">${mine.length ? mine.map(p => renderPathCard(p, audienceList, true)).join('') : '<div class="empty-msg">You haven’t created any path yet.</div>'}</div>
        <h3 style="margin-top:20px;">Catalog</h3>
      ` : ''}
      <div id="fp-catalog">${published.length ? published.map(p => renderPathCard(p, audienceList, false)).join('') : ''}</div>
      ${!published.length && !mine.length ? '<div class="empty-msg">No paths available yet.</div>' : ''}
    </div>`;

  document.querySelectorAll('[data-open-path]').forEach(el => el.addEventListener('click', () => {
    State.formationSelectedPathId = parseInt(el.dataset.openPath, 10);
    expandedChapters = new Set();
    renderFormationView(main);
  }));

  if (State.isFormatore) {
    document.getElementById('fp-new').addEventListener('click', () => openPathPopup({
      onSaved: () => renderFormationView(main),
    }));
  }
}

function renderPathCard(p, audienceList, isMine) {
  const badge = p.status === 'draft' ? 'Draft' : (p.status === 'archived' ? 'Archived' : 'Published');
  return `
    <div class="panel" data-open-path="${p.id}" style="cursor:pointer;margin-bottom:8px;">
      <div class="btn-row" style="justify-content:space-between;">
        <div style="font-weight:600;" dir="auto">${esc(p.title)}</div>
        ${isMine ? `<span class="hint">${badge}</span>` : ''}
      </div>
      ${p.description ? `<div class="hint" style="margin-top:4px;" dir="auto">${esc(p.description)}</div>` : ''}
      <div class="hint" style="margin-top:4px;">
        ${esc(labelOf(audienceList, p.target_audience))}
        ${p.session_type === 'summer' ? ' &middot; Summer session' : ' &middot; Regular path'}
        ${p.enrollment_deadline ? ` &middot; Enroll by ${esc(p.enrollment_deadline)}` : ''}
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
      <div class="field"><label>Title</label><input id="fpp-title" value="${esc(path ? path.title : '')}"></div>
      <div class="field"><label>Description</label><textarea id="fpp-description" dir="auto" rows="3">${esc(path ? path.description : '')}</textarea></div>
      <div class="field"><label>Target audience</label><select id="fpp-audience">${optionsHtml(audienceList, path ? path.target_audience : '', true)}</select></div>
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
  document.getElementById('fpp-save').addEventListener('click', async () => {
    const title = document.getElementById('fpp-title').value.trim();
    if (!title) { alert('Title is required.'); return; }
    const row = {
      title,
      description: document.getElementById('fpp-description').value.trim() || null,
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

  const years = await withStatus(sb.from('formation_years').select('*').eq('path_id', pathId).order('sequence_number').order('id'));
  const yearIds = years.map(y => y.id);
  const modules = yearIds.length ? await withStatus(sb.from('formation_modules').select('*').in('year_id', yearIds).order('sequence_number').order('id')) : [];
  const moduleIds = modules.map(m => m.id);
  const chapters = moduleIds.length ? await withStatus(sb.from('formation_chapters').select('*').in('module_id', moduleIds).order('sequence_number').order('id')) : [];
  const chapterIds = chapters.map(c => c.id);
  const posts = chapterIds.length ? await withStatus(sb.from('formation_posts').select('*').in('chapter_id', chapterIds).order('sequence_number').order('id')) : [];

  const audienceList = State.optionListsByName.formation_audience || [];
  const canEdit = path.owner_id === user.id || canReviewApplications();

  const modulesOf = yearId => modules.filter(m => m.year_id === yearId);
  const chaptersOf = moduleId => chapters.filter(c => c.module_id === moduleId);
  const postsOf = chapterId => posts.filter(p => p.chapter_id === chapterId);

  const badge = path.status === 'draft' ? 'Draft' : (path.status === 'archived' ? 'Archived' : 'Published');

  main.innerHTML = `
    <div class="panel">
      <div class="btn-row" style="justify-content:space-between;">
        <button class="btn secondary" id="fp-back">&larr; Formation Paths</button>
        <span class="hint">${badge}</span>
      </div>
      <h2 dir="auto">${esc(path.title)}</h2>
      ${path.description ? `<div dir="auto" style="margin-bottom:8px;">${esc(path.description)}</div>` : ''}
      <div class="hint">
        ${esc(labelOf(audienceList, path.target_audience))}
        ${path.session_type === 'summer' ? ' &middot; Summer session' : ' &middot; Regular path'}
        ${path.course_starts_at ? ` &middot; ${esc(path.course_starts_at)} &rarr; ${esc(path.course_ends_at)}` : ''}
        ${path.enrollment_deadline ? ` &middot; Enroll by ${esc(path.enrollment_deadline)}` : ''}
      </div>
      ${canEdit ? `<div class="btn-row" style="margin-top:10px;">
        <button class="btn secondary" id="fp-edit-details">Edit details</button>
        ${path.status !== 'published' ? '<button class="btn secondary" id="fp-publish">Publish</button>' : '<button class="btn secondary" id="fp-archive">Archive</button>'}
        <button class="btn danger" id="fp-delete-path">Delete path</button>
      </div>` : ''}
      <hr style="margin:16px 0;">
      <div id="fp-tree">
        ${canEdit ? '<div class="btn-row" style="margin-bottom:10px;"><button class="btn" id="fp-add-year">+ Add year</button></div>' : ''}
        ${years.length ? years.map(y => renderYearBlock(y, modulesOf(y.id), chaptersOf, postsOf, canEdit)).join('') : '<div class="empty-msg">No years yet.</div>'}
      </div>
    </div>`;

  document.getElementById('fp-back').addEventListener('click', () => {
    State.formationSelectedPathId = null;
    renderFormationView(main);
  });

  if (canEdit) {
    document.getElementById('fp-edit-details').addEventListener('click', () => openPathPopup({ path, onSaved: () => renderPathDetail(main, pathId) }));
    document.getElementById('fp-delete-path').addEventListener('click', async () => {
      if (!confirm('Delete this whole path, with all its years/modules/chapters/posts? This cannot be undone.')) return;
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
    document.getElementById('fp-add-year').addEventListener('click', async () => {
      const n = prompt('Year number (1, 2, 3...):', String(years.length + 1));
      if (n === null) return;
      const year_number = parseInt(n, 10);
      if (!Number.isFinite(year_number)) { alert('Not a valid number.'); return; }
      await withStatus(sb.from('formation_years').insert({ path_id: pathId, year_number, sequence_number: years.length }), 'Saving...');
      renderPathDetail(main, pathId);
    });
  }

  wireTreeActions(main, pathId, years, modules, chapters, posts, canEdit);
}

function renderYearBlock(y, modules, chaptersOf, postsOf, canEdit) {
  return `
  <div class="panel" style="margin-bottom:10px;" data-year-block="${y.id}">
    <div class="btn-row" style="justify-content:space-between;">
      <h3 style="margin:0;">Year ${esc(y.year_number)}</h3>
      ${canEdit ? `<div class="btn-row">
        <button class="btn secondary" data-move-year-up="${y.id}" style="padding:2px 8px;">&#9650;</button>
        <button class="btn secondary" data-move-year-down="${y.id}" style="padding:2px 8px;">&#9660;</button>
        <button class="btn secondary" data-add-module="${y.id}" style="padding:2px 8px;">+ Module</button>
        <button class="btn danger" data-delete-year="${y.id}" style="padding:2px 8px;">Delete</button>
      </div>` : ''}
    </div>
    ${modules.length ? modules.map(m => renderModuleBlock(m, chaptersOf(m.id), postsOf, canEdit)).join('') : '<div class="hint">No modules yet.</div>'}
  </div>`;
}

function renderModuleBlock(m, chapters, postsOf, canEdit) {
  return `
  <div style="margin:10px 0 10px 12px;" data-module-block="${m.id}">
    <div class="btn-row" style="justify-content:space-between;">
      <div style="font-weight:600;" dir="auto">${esc(m.title)}</div>
      ${canEdit ? `<div class="btn-row">
        <button class="btn secondary" data-move-module-up="${m.id}" style="padding:2px 6px;">&#9650;</button>
        <button class="btn secondary" data-move-module-down="${m.id}" style="padding:2px 6px;">&#9660;</button>
        <button class="btn secondary" data-rename-module="${m.id}" style="padding:2px 6px;">Rename</button>
        <button class="btn secondary" data-add-chapter="${m.id}" style="padding:2px 6px;">+ Chapter</button>
        <button class="btn danger" data-delete-module="${m.id}" style="padding:2px 6px;">Delete</button>
      </div>` : ''}
    </div>
    ${m.description ? `<div class="hint" dir="auto">${esc(m.description)}</div>` : ''}
    ${chapters.length ? chapters.map(c => renderChapterBlock(c, postsOf(c.id), canEdit)).join('') : '<div class="hint">No chapters yet.</div>'}
  </div>`;
}

function renderChapterBlock(c, posts, canEdit) {
  const isOpen = expandedChapters.has(c.id);
  return `
  <div style="margin:8px 0 8px 16px;padding:8px;border:1px solid var(--accent-soft);border-radius:6px;" data-chapter-block="${c.id}">
    <div class="btn-row" style="justify-content:space-between;">
      <span style="font-weight:600;cursor:pointer;" data-toggle-chapter="${c.id}" dir="auto">${isOpen ? '&#9662;' : '&#9656;'} ${esc(c.title)} <span class="hint">(${posts.length})</span></span>
      ${canEdit ? `<div class="btn-row">
        <button class="btn secondary" data-move-chapter-up="${c.id}" style="padding:2px 6px;">&#9650;</button>
        <button class="btn secondary" data-move-chapter-down="${c.id}" style="padding:2px 6px;">&#9660;</button>
        <button class="btn secondary" data-rename-chapter="${c.id}" style="padding:2px 6px;">Rename</button>
        <button class="btn secondary" data-add-post="${c.id}" style="padding:2px 6px;">+ Post</button>
        <button class="btn danger" data-delete-chapter="${c.id}" style="padding:2px 6px;">Delete</button>
      </div>` : ''}
    </div>
    ${isOpen ? `<div style="margin-top:6px;">${posts.length ? posts.map(p => renderPostRow(p, canEdit)).join('') : '<div class="hint">No posts yet.</div>'}</div>` : ''}
  </div>`;
}

function renderPostRow(p, canEdit) {
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

function wireTreeActions(main, pathId, years, modules, chapters, posts, canEdit) {
  const refresh = () => renderPathDetail(main, pathId);

  document.querySelectorAll('[data-toggle-chapter]').forEach(el => el.addEventListener('click', () => {
    const id = parseInt(el.dataset.toggleChapter, 10);
    if (expandedChapters.has(id)) expandedChapters.delete(id); else expandedChapters.add(id);
    refresh();
  }));

  if (!canEdit) return;

  document.querySelectorAll('[data-move-year-up]').forEach(el => el.addEventListener('click', () =>
    reorderSibling('formation_years', years, parseInt(el.dataset.moveYearUp, 10), -1, refresh)));
  document.querySelectorAll('[data-move-year-down]').forEach(el => el.addEventListener('click', () =>
    reorderSibling('formation_years', years, parseInt(el.dataset.moveYearDown, 10), 1, refresh)));
  document.querySelectorAll('[data-delete-year]').forEach(el => el.addEventListener('click', async () => {
    if (!confirm('Delete this year with all its modules/chapters/posts?')) return;
    await withStatus(sb.from('formation_years').delete().eq('id', el.dataset.deleteYear), 'Deleting...');
    refresh();
  }));
  document.querySelectorAll('[data-add-module]').forEach(el => el.addEventListener('click', async () => {
    const yearId = parseInt(el.dataset.addModule, 10);
    const title = prompt('Module title:');
    if (!title || !title.trim()) return;
    const siblingCount = modules.filter(m => m.year_id === yearId).length;
    await withStatus(sb.from('formation_modules').insert({ year_id: yearId, title: title.trim(), sequence_number: siblingCount }), 'Saving...');
    refresh();
  }));

  document.querySelectorAll('[data-move-module-up]').forEach(el => el.addEventListener('click', () => {
    const m = modules.find(x => x.id === parseInt(el.dataset.moveModuleUp, 10));
    reorderSibling('formation_modules', modules.filter(x => x.year_id === m.year_id), m.id, -1, refresh);
  }));
  document.querySelectorAll('[data-move-module-down]').forEach(el => el.addEventListener('click', () => {
    const m = modules.find(x => x.id === parseInt(el.dataset.moveModuleDown, 10));
    reorderSibling('formation_modules', modules.filter(x => x.year_id === m.year_id), m.id, 1, refresh);
  }));
  document.querySelectorAll('[data-rename-module]').forEach(el => el.addEventListener('click', async () => {
    const m = modules.find(x => x.id === parseInt(el.dataset.renameModule, 10));
    const title = prompt('New module title:', m.title);
    if (!title || !title.trim()) return;
    await withStatus(sb.from('formation_modules').update({ title: title.trim() }).eq('id', m.id), 'Saving...');
    refresh();
  }));
  document.querySelectorAll('[data-delete-module]').forEach(el => el.addEventListener('click', async () => {
    if (!confirm('Delete this module with all its chapters/posts?')) return;
    await withStatus(sb.from('formation_modules').delete().eq('id', el.dataset.deleteModule), 'Deleting...');
    refresh();
  }));
  document.querySelectorAll('[data-add-chapter]').forEach(el => el.addEventListener('click', async () => {
    const moduleId = parseInt(el.dataset.addChapter, 10);
    const title = prompt('Chapter title:');
    if (!title || !title.trim()) return;
    const siblingCount = chapters.filter(c => c.module_id === moduleId).length;
    await withStatus(sb.from('formation_chapters').insert({ module_id: moduleId, title: title.trim(), sequence_number: siblingCount }), 'Saving...');
    refresh();
  }));

  document.querySelectorAll('[data-move-chapter-up]').forEach(el => el.addEventListener('click', () => {
    const c = chapters.find(x => x.id === parseInt(el.dataset.moveChapterUp, 10));
    reorderSibling('formation_chapters', chapters.filter(x => x.module_id === c.module_id), c.id, -1, refresh);
  }));
  document.querySelectorAll('[data-move-chapter-down]').forEach(el => el.addEventListener('click', () => {
    const c = chapters.find(x => x.id === parseInt(el.dataset.moveChapterDown, 10));
    reorderSibling('formation_chapters', chapters.filter(x => x.module_id === c.module_id), c.id, 1, refresh);
  }));
  document.querySelectorAll('[data-rename-chapter]').forEach(el => el.addEventListener('click', async () => {
    const c = chapters.find(x => x.id === parseInt(el.dataset.renameChapter, 10));
    const title = prompt('New chapter title:', c.title);
    if (!title || !title.trim()) return;
    await withStatus(sb.from('formation_chapters').update({ title: title.trim() }).eq('id', c.id), 'Saving...');
    refresh();
  }));
  document.querySelectorAll('[data-delete-chapter]').forEach(el => el.addEventListener('click', async () => {
    if (!confirm('Delete this chapter with all its posts?')) return;
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
    if (!confirm('Delete this post?')) return;
    await withStatus(sb.from('formation_posts').delete().eq('id', el.dataset.deletePost), 'Deleting...');
    refresh();
  }));
}
