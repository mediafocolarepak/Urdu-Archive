// The formation boards (Fase 1, PROJECT_HANDOFF_v15.md): one board per group, where "editors"
// (named by Coordinator/Admin, per-board via board_editors - see 71_boards.sql) post curated
// documents or free-standing text, and everyone reads. No comments.
//
// "Letto" (72_board_post_reads.sql): marked automatically the moment a post is rendered here -
// no button to click. Everyone sees a count; only that board's editors and Coordinator/Admin
// see who, via a security definer function (board_post_readers) that checks the permission
// itself, the same pattern as is_board_editor()/document_is_postable() in 71_boards.sql.

import {
  sb, State, esc, withStatus, canReviewApplications, getDisplayNameByEmail,
  openBoardPostPopup, likeSafe, DEFAULT_BOARD_FOR_MEMBERSHIP, BOARD_MEDIA_BUCKET, ackBoardPolicy,
  createWorkFor, uniqueFileName, computeFileName,
} from './core.js?v=20260917234604';

// Shown once, before a person's first post (84_boards_moderation.sql) - keep this in sync with
// the Help entries board_usage_policy_en/it, which say the same thing at more length.
const BOARD_POLICY_TEXT = `Keep it relevant to the group and in the spirit of the programme. No commercial promotion, no political campaigning, no content that wouldn't be appropriate to read aloud to the group.

A post from a User is held for review by that board's editors before anyone else sees it; an Operator's post is published immediately. An editor can reject or remove a post, with a reason. Repeated misuse can lead to a reduced reputation (Operators) or to being blocked from posting (Users) - always proposed by an editor and approved by a Formation or HR lead, never by one person alone.`;

function showBoardPolicyModal(onAgree) {
  const backdrop = document.createElement('div');
  backdrop.className = 'overlay-backdrop';
  backdrop.innerHTML = `
    <div class="panel overlay-panel">
      <h2 style="margin-top:0;">Before you post</h2>
      <div style="white-space:pre-wrap;">${esc(BOARD_POLICY_TEXT)}</div>
      <div class="btn-row" style="justify-content:flex-end;">
        <button class="btn secondary" id="bpol-cancel">Cancel</button>
        <button class="btn" id="bpol-agree">I understand, continue</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  backdrop.addEventListener('click', e => { if (e.target === backdrop) backdrop.remove(); });
  document.getElementById('bpol-cancel').addEventListener('click', () => backdrop.remove());
  document.getElementById('bpol-agree').addEventListener('click', async () => {
    await ackBoardPolicy();
    backdrop.remove();
    onAgree();
  });
}

// Gate every "post" entry point through the policy modal the first time - used here and could
// be reused by docdetail.js/myspace.js's "+ Board" if they ever need the same gate (they don't
// yet: attaching a document to a board is still an Operator+ action, already trusted).
function openBoardPostPopupGated(opts) {
  if (State.boardPolicyAcked) { openBoardPostPopup(opts); return; }
  showBoardPolicyModal(() => openBoardPostPopup(opts));
}

// Fase 2 (PROJECT_HANDOFF_v16.md): a readable preview of the document's Urdu text, from
// document_texts, right in the post - instead of a bare link out of the app. Plain substring,
// same idea as search_document_texts()'s snippet, just longer and not search-anchored.
function textPreview(body, maxChars = 280) {
  const trimmed = (body || '').trim();
  return trimmed.length > maxChars ? trimmed.slice(0, maxChars).trim() + '…' : trimmed;
}

export async function renderBoardsView(main) {
  const { data: { user } } = await sb.auth.getUser();
  const myEmail = user.email;

  const posts = await withStatus(sb.from('board_posts').select('*').order('pinned', { ascending: false }).order('created_at', { ascending: false }));
  const docIds = [...new Set(posts.filter(p => p.document_id != null).map(p => p.document_id))];
  const docs = docIds.length ? await withStatus(sb.from('documents').select('document_id,en_title,ur_title').in('document_id', docIds)) : [];
  const docById = {}; for (const d of docs) docById[d.document_id] = d;
  const texts = docIds.length ? await withStatus(sb.from('document_texts').select('document_id,body,reviewed').in('document_id', docIds)) : [];
  const textById = {}; for (const t of texts) textById[t.document_id] = t;

  const allBoards = State.optionListsByName.board || [];
  // Posting is now open to everyone (84_boards_moderation.sql), so every board is worth showing
  // even if empty - unlike before this migration, when only a board's own formatori/Coordinator
  // could ever post there.
  const shownBoards = allBoards;

  if (!shownBoards.length) {
    main.innerHTML = '<div class="panel"><h2>Boards</h2><div class="empty-msg">No boards yet.</div></div>';
    return;
  }

  const defaultBoard = DEFAULT_BOARD_FOR_MEMBERSHIP[State.myMembershipType];
  let active = State.boardsSelected;
  if (!active || !shownBoards.some(([code]) => code === active)) {
    active = (defaultBoard && shownBoards.some(([code]) => code === defaultBoard)) ? defaultBoard : shownBoards[0][0];
  }
  State.boardsSelected = active;

  main.innerHTML = `
    <div class="panel">
      <h2>Boards</h2>
      <div class="btn-row" id="board-pills" style="margin-bottom:10px;">
        ${shownBoards.map(([code, label]) => `<button class="board-pill${code === active ? ' active' : ''}" data-board="${esc(code)}">${esc(label)}</button>`).join('')}
      </div>
      <div class="field" style="max-width:320px;"><input id="board-search" placeholder="Search this board..." value="${esc(State.boardsSearch)}"></div>
      ${State.myBoards.has(active) ? '<div id="board-pending-queue" style="margin:10px 0;"></div>' : ''}
      <div id="board-posts"></div>
      ${canReviewApplications() ? '<div id="board-editors-panel" style="margin-top:24px;"></div>' : ''}
    </div>`;

  document.querySelectorAll('#board-pills .board-pill').forEach(btn => btn.addEventListener('click', () => {
    State.boardsSelected = btn.dataset.board;
    State.boardsSearch = '';
    renderBoardsView(main);
  }));
  document.getElementById('board-search').addEventListener('input', e => {
    State.boardsSearch = e.target.value;
    renderPostsForBoard(active, postsForActiveBoard(), docById, textById, myEmail, main);
  });

  function postsForActiveBoard() {
    const q = State.boardsSearch.trim().toLowerCase();
    return posts.filter(p => p.board_code === active
      && (!q || p.title.toLowerCase().includes(q) || (p.body || '').toLowerCase().includes(q)));
  }

  if (State.myBoards.has(active)) {
    renderPendingQueue(document.getElementById('board-pending-queue'), active, posts.filter(p => p.board_code === active && p.status === 'pending'), main);
  }
  renderPostsForBoard(active, postsForActiveBoard(), docById, textById, myEmail, main);

  if (canReviewApplications()) {
    renderEditorsPanel(document.getElementById('board-editors-panel'), allBoards, active);
  }
}

// ---------- Pending queue (that board's editors, or Coordinator/Admin) ----------

function renderPendingQueue(box, boardCode, pendingPosts, main) {
  if (!box) return;
  if (!pendingPosts.length) { box.innerHTML = ''; return; }
  box.innerHTML = `
    <div class="panel" style="background:var(--accent-soft);">
      <h3 style="margin-top:0;">Pending review <span class="count-badge">${pendingPosts.length}</span></h3>
      ${pendingPosts.map(p => `
        <div style="padding:8px 0;border-top:1px solid var(--accent-soft-line);" data-pending-id="${p.id}">
          <div style="font-weight:600;" dir="auto">${esc(p.title)}</div>
          ${p.body ? `<div dir="auto" style="white-space:pre-wrap;">${esc(p.body)}</div>` : ''}
          ${p.link_url ? `<div><a href="${esc(p.link_url)}" target="_blank" rel="noopener">${esc(p.link_url)}</a></div>` : ''}
          <div class="field" style="margin-top:4px;"><label>Note <span class="hint">(required to reject)</span></label><textarea class="pq-note" rows="2"></textarea></div>
          <div class="btn-row">
            <button class="btn" data-publish="${p.id}" style="padding:4px 10px;">Publish</button>
            <button class="btn danger" data-reject="${p.id}" style="padding:4px 10px;">Reject</button>
          </div>
        </div>`).join('')}
    </div>`;
  box.querySelectorAll('[data-publish]').forEach(btn => btn.addEventListener('click', async () => {
    const { data: { user } } = await sb.auth.getUser();
    const note = btn.closest('[data-pending-id]').querySelector('.pq-note').value.trim();
    await withStatus(sb.from('board_posts').update({ status: 'published', moderated_by_email: user.email, moderation_note: note || null }).eq('id', btn.dataset.publish), 'Publishing...');
    renderBoardsView(main);
  }));
  box.querySelectorAll('[data-reject]').forEach(btn => btn.addEventListener('click', async () => {
    const note = btn.closest('[data-pending-id]').querySelector('.pq-note').value.trim();
    if (!note) { alert('A note is required when rejecting - the author will see it.'); return; }
    const { data: { user } } = await sb.auth.getUser();
    await withStatus(sb.from('board_posts').update({ status: 'rejected', moderated_by_email: user.email, moderation_note: note }).eq('id', btn.dataset.reject), 'Rejecting...');
    renderBoardsView(main);
  }));
}

async function renderPostsForBoard(boardCode, posts, docById, textById, myEmail, main) {
  const box = document.getElementById('board-posts');
  // Posting is open to any signed-in user now (84_boards_moderation.sql) - only an explicit
  // block (proposed by an editor, approved by a Formation/HR lead via the People tab) removes it.
  const canPost = !State.boardPostingBlocked;
  const postIds = posts.map(p => p.id);

  const { data: { user } } = await sb.auth.getUser();
  const [myReadRows, countRows] = await Promise.all([
    postIds.length ? withStatus(sb.from('board_post_reads').select('post_id').eq('user_id', user.id).in('post_id', postIds)) : [],
    postIds.length ? withStatus(sb.rpc('board_post_read_counts', { post_ids: postIds })) : [],
  ]);
  const myReadSet = new Set(myReadRows.map(r => r.post_id));
  const countByPost = {}; for (const c of countRows) countByPost[c.post_id] = c.read_count;

  // Which of these posts already has an archive document promoted from it - so "Promote to
  // archive" doesn't offer to create a second one for the same post.
  const promotedRows = postIds.length ? await withStatus(sb.from('documents').select('source_board_post_id').in('source_board_post_id', postIds)) : [];
  const promotedPostIds = new Set(promotedRows.map(r => r.source_board_post_id));

  // "Letto" is automatic on viewing: anything not yet in myReadSet is counted right now, so the
  // checkmark/count are right on this very render, and persisted in the background below rather
  // than making the view wait on a round trip for something this small.
  const newlyRead = postIds.filter(id => !myReadSet.has(id));
  for (const id of newlyRead) { myReadSet.add(id); countByPost[id] = (countByPost[id] || 0) + 1; }

  box.innerHTML = `
    ${canPost
      ? '<div class="btn-row" style="margin-bottom:10px;"><button class="btn" id="board-new-post">+ New post</button></div>'
      : '<p class="hint">You have been blocked from posting on boards.</p>'}
    <div id="board-posts-list">${posts.map(p => renderPostCard(p, docById[p.document_id], textById[p.document_id], myEmail, myReadSet.has(p.id), countByPost[p.id] || 0, promotedPostIds.has(p.id))).join('') || '<div class="empty-msg">No posts match here yet.</div>'}</div>`;

  if (canPost) {
    document.getElementById('board-new-post').addEventListener('click', () => openBoardPostPopupGated({
      boardCode, onSaved: () => renderBoardsView(main),
    }));
  }

  if (newlyRead.length) {
    sb.from('board_post_reads').upsert(newlyRead.map(post_id => ({ post_id, user_id: user.id })), { onConflict: 'post_id,user_id', ignoreDuplicates: true })
      .then(({ error }) => { if (error) console.error('Could not record "read" for board posts:', error); });
  }

  // Resolve author display names after the initial render (avoids one query per post up front).
  Promise.all(posts.map(p => getDisplayNameByEmail(p.posted_by_email))).then(resolvedNames => {
    posts.forEach((p, i) => {
      const el = document.querySelector(`.board-post[data-id="${p.id}"] .board-post-author`);
      if (el) el.textContent = resolvedNames[i];
    });
  });

  wirePostActions(posts, docById, myEmail, main);
}

const STATUS_BADGE = {
  pending: '<span class="hint" style="color:#b8860b;">Pending review</span>',
  rejected: '<span class="hint" style="color:var(--danger);">Rejected</span>',
};

function renderPostCard(p, doc, text, myEmail, iRead, readCount, alreadyPromoted) {
  const isModerator = State.myBoards.has(p.board_code);
  const isMine = p.posted_by_email === myEmail;
  // Edit: the author (any role, own text) or a moderator. Delete stays narrower - unchanged
  // from before this migration - because a plain User's own post isn't theirs to remove once
  // submitted; only a moderator (or Coordinator/Admin) can, "with a reason" (the confirm below).
  const canEditThis = canReviewApplications() || isModerator || isMine;
  const canDeleteThis = canReviewApplications() || (isMine && isModerator);
  const canSeeReaders = canReviewApplications() || isModerator;
  // Promoting writes a document_texts row, which needs Operator+ (68_document_texts.sql) -
  // a board editor who happens to still be a plain User couldn't actually complete this.
  const canPromote = (canReviewApplications() || isModerator) && State.currentRole !== 'user' && p.body && p.body.trim() && !alreadyPromoted;
  const imageUrl = p.image_path ? sb.storage.from(BOARD_MEDIA_BUCKET).getPublicUrl(p.image_path).data.publicUrl : null;
  return `
    <div class="panel board-post" data-id="${p.id}">
      <div class="btn-row" style="justify-content:space-between;align-items:flex-start;margin:0 0 4px;">
        <div style="font-weight:600;" dir="auto">${p.pinned ? '📌 ' : ''}${esc(p.title)}</div>
        ${STATUS_BADGE[p.status] || ''}
      </div>
      <div class="hint">posted by <span class="board-post-author">…</span> &middot; ${esc((p.created_at || '').slice(0, 10))}</div>
      ${p.status === 'rejected' && p.moderation_note ? `<div class="hint" style="color:var(--danger);">Reason: ${esc(p.moderation_note)}</div>` : ''}
      ${p.body ? `<div class="board-post-body" dir="auto">${esc(p.body)}</div>` : ''}
      ${p.link_url ? `<div style="margin-top:4px;"><a href="${esc(p.link_url)}" target="_blank" rel="noopener">${esc(p.link_url)}</a></div>` : ''}
      ${imageUrl ? `<img src="${esc(imageUrl)}" alt="" style="max-width:100%;max-height:320px;margin-top:6px;border-radius:6px;">` : ''}
      ${doc ? `<div class="field" style="margin-top:8px;">
        <label>Document</label>
        <div style="font-size:13px;">#${esc(doc.document_id)} &middot; ${esc(doc.en_title) || '<span class="hint">(no title)</span>'}${doc.ur_title ? ` / <span dir="auto">${esc(doc.ur_title)}</span>` : ''}</div>
        ${text ? `<div class="board-doc-preview" dir="auto">${esc(textPreview(text.body))}</div>${!text.reviewed ? '<div class="hint">Unverified automatic transcription</div>' : ''}` : ''}
        <button class="btn secondary" data-open-doc="${esc(doc.document_id)}" style="margin-top:4px;">Open</button>
      </div>` : ''}
      <div class="hint" style="margin-top:6px;">
        ${readCount} read${iRead ? ' &middot; you read this ✓' : ''}${canSeeReaders ? ` &middot; <span style="cursor:pointer;text-decoration:underline;" data-show-readers="${p.id}">Who?</span>` : ''}
      </div>
      <div id="board-readers-${p.id}" class="hint" style="display:none;margin-top:4px;"></div>
      <div class="btn-row" style="margin-top:8px;">
        ${canEditThis ? `<button class="btn secondary" data-edit="${p.id}">Edit</button>` : ''}
        ${canDeleteThis ? `<button class="btn danger" data-delete="${p.id}">Delete</button>` : ''}
        ${canReviewApplications() ? `<button class="btn secondary" data-pin="${p.id}">${p.pinned ? 'Unpin' : 'Pin'}</button>` : ''}
        ${canPromote ? `<button class="btn secondary" data-promote="${p.id}">Promote to archive</button>` : ''}
      </div>
    </div>`;
}

function wirePostActions(posts, docById, myEmail, main) {
  document.querySelectorAll('[data-show-readers]').forEach(el => el.addEventListener('click', async () => {
    const id = el.dataset.showReaders;
    const box = document.getElementById(`board-readers-${id}`);
    if (box.style.display === 'block') { box.style.display = 'none'; return; }
    box.style.display = 'block';
    box.innerHTML = 'Loading...';
    const rows = await withStatus(sb.rpc('board_post_readers', { pid: parseInt(id, 10) }));
    box.innerHTML = rows.length
      ? rows.map(r => `${esc(r.full_name) || esc(r.email)} &middot; ${esc((r.read_at || '').slice(0, 10))}`).join('<br>')
      : 'Nobody yet.';
  }));
  document.querySelectorAll('[data-open-doc]').forEach(btn => btn.addEventListener('click', () => {
    State.selectedDocId = btn.dataset.openDoc;
    window.__renderTab('dashboard');
  }));
  document.querySelectorAll('[data-edit]').forEach(btn => btn.addEventListener('click', () => {
    const post = posts.find(p => String(p.id) === btn.dataset.edit);
    openBoardPostPopup({ post, onSaved: () => renderBoardsView(main) });
  }));
  document.querySelectorAll('[data-delete]').forEach(btn => btn.addEventListener('click', async () => {
    const reason = prompt('Delete this post - what is the reason?');
    if (reason == null) return;
    if (!reason.trim()) { alert('A reason is required.'); return; }
    await withStatus(sb.from('board_posts').delete().eq('id', btn.dataset.delete), 'Deleting...');
    renderBoardsView(main);
  }));
  document.querySelectorAll('[data-pin]').forEach(btn => btn.addEventListener('click', async () => {
    const post = posts.find(p => String(p.id) === btn.dataset.pin);
    await withStatus(sb.from('board_posts').update({ pinned: !post.pinned }).eq('id', post.id), 'Saving...');
    renderBoardsView(main);
  }));
  document.querySelectorAll('[data-promote]').forEach(btn => btn.addEventListener('click', async () => {
    const post = posts.find(p => String(p.id) === btn.dataset.promote);
    if (!confirm(`Create an archive document from "${post.title}"? It will start in revision, same as any other draft.`)) return;
    await promotePostToArchive(post);
    renderBoardsView(main);
  }));
}

// Creates a new archive document (workflow_status 'revision', same stage as any other draft
// awaiting review - see tasks.js's uploadCorrectedFile for the same status used elsewhere) from
// a board post's title/text, with its own Work and a document_texts row so the text is actually
// readable/searchable like any other document, not just cross-linked.
async function promotePostToArchive(post) {
  const { data: { user } } = await sb.auth.getUser();
  const maxRows = await withStatus(sb.from('documents').select('document_id').order('document_id', { ascending: false }).limit(1));
  const newId = (maxRows[0]?.document_id || 0) + 1;
  const workId = await createWorkFor(post.title);
  const draft = {
    document_id: newId, title: post.title, work_id: workId, language: 'URD',
    workflow_status: 'revision', source_board_post_id: post.id, legacy_migrated: false, is_preferred: false,
  };
  draft.file_name = await uniqueFileName(computeFileName(draft), null);
  await withStatus(sb.from('documents').insert(draft), 'Creating archive draft...');
  await withStatus(sb.from('document_texts').insert({ document_id: newId, body: post.body, source: 'typed', reviewed: false, updated_by_email: user.email }), 'Saving text...');
}

// ---------- Board editors panel (Coordinator/Admin only) ----------

async function renderEditorsPanel(box, allBoards, selectedBoard) {
  if (!box) return;
  box.innerHTML = `
    <h3>Board editors</h3>
    <div class="field"><label>Board</label><select id="be-board"></select></div>
    <div id="be-list"><div class="hint">Loading...</div></div>
    <div class="field" style="margin-top:8px;">
      <label>Add editor <span class="hint">(search by name or email)</span></label>
      <input id="be-search" placeholder="Type a name or email...">
      <div id="be-search-results"></div>
    </div>`;
  const boardSel = document.getElementById('be-board');
  boardSel.innerHTML = allBoards.map(([code, label]) => `<option value="${esc(code)}" ${code === selectedBoard ? 'selected' : ''}>${esc(label)}</option>`).join('');
  boardSel.addEventListener('change', () => refreshEditorsList(boardSel.value));

  document.getElementById('be-search').addEventListener('input', async e => {
    const q = e.target.value.trim();
    const resultsBox = document.getElementById('be-search-results');
    if (!q) { resultsBox.innerHTML = ''; return; }
    const pattern = likeSafe(q);
    const rows = await withStatus(sb.from('user_profiles').select('user_id,email,full_name').or(`full_name.ilike.${pattern},email.ilike.${pattern}`).limit(10));
    resultsBox.innerHTML = rows.map(r => `<div class="hint" style="cursor:pointer;padding:2px 0;" data-add-uid="${esc(r.user_id)}" data-add-email="${esc(r.email)}">${esc(r.full_name) || esc(r.email)} &middot; ${esc(r.email)}</div>`).join('') || '<div class="hint">No match.</div>';
    resultsBox.querySelectorAll('[data-add-uid]').forEach(el => el.addEventListener('click', async () => {
      await withStatus(sb.from('board_editors').insert({
        board_code: boardSel.value, user_id: el.dataset.addUid, added_by_email: (await sb.auth.getUser()).data.user.email,
      }), 'Adding...');
      document.getElementById('be-search').value = '';
      resultsBox.innerHTML = '';
      refreshEditorsList(boardSel.value);
    }));
  });

  refreshEditorsList(selectedBoard);
}

async function refreshEditorsList(boardCode) {
  const box = document.getElementById('be-list');
  if (!box) return;
  const editorRows = await withStatus(sb.from('board_editors').select('user_id').eq('board_code', boardCode));
  if (!editorRows.length) { box.innerHTML = '<div class="hint">No editors named on this board yet.</div>'; return; }
  const profileRows = await withStatus(sb.from('user_profiles').select('user_id,email,full_name').in('user_id', editorRows.map(r => r.user_id)));
  const profileByUid = {}; for (const p of profileRows) profileByUid[p.user_id] = p;
  box.innerHTML = editorRows.map(r => {
    const p = profileByUid[r.user_id] || {};
    return `<div class="btn-row" style="justify-content:space-between;margin:4px 0;">
      <span>${esc(p.full_name) || esc(p.email) || r.user_id}</span>
      <button class="btn secondary" data-remove-editor="${esc(r.user_id)}" style="padding:2px 8px;">Remove</button>
    </div>`;
  }).join('');
  box.querySelectorAll('[data-remove-editor]').forEach(btn => btn.addEventListener('click', async () => {
    await withStatus(sb.from('board_editors').delete().eq('board_code', boardCode).eq('user_id', btn.dataset.removeEditor), 'Removing...');
    refreshEditorsList(boardCode);
  }));
}
