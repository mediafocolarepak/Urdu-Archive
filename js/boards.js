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
  openBoardPostPopup, likeSafe, DEFAULT_BOARD_FOR_MEMBERSHIP,
} from './core.js?v=20260911001316';

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
  const postCountByBoard = {};
  for (const p of posts) postCountByBoard[p.board_code] = (postCountByBoard[p.board_code] || 0) + 1;
  // Never show an empty board to someone who can't post to it - a formatore still needs to see
  // their own board (even empty) to be able to publish there.
  const shownBoards = allBoards.filter(([code]) => postCountByBoard[code] > 0 || State.myBoards.has(code));

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
      <div id="board-posts"></div>
      ${canReviewApplications() ? '<div id="board-editors-panel" style="margin-top:24px;"></div>' : ''}
    </div>`;

  document.querySelectorAll('#board-pills .board-pill').forEach(btn => btn.addEventListener('click', () => {
    State.boardsSelected = btn.dataset.board;
    renderBoardsView(main);
  }));

  renderPostsForBoard(active, posts.filter(p => p.board_code === active), docById, textById, myEmail, main);

  if (canReviewApplications()) {
    renderEditorsPanel(document.getElementById('board-editors-panel'), allBoards, active);
  }
}

async function renderPostsForBoard(boardCode, posts, docById, textById, myEmail, main) {
  const box = document.getElementById('board-posts');
  const canPost = State.myBoards.has(boardCode);
  const postIds = posts.map(p => p.id);

  const { data: { user } } = await sb.auth.getUser();
  const [myReadRows, countRows] = await Promise.all([
    postIds.length ? withStatus(sb.from('board_post_reads').select('post_id').eq('user_id', user.id).in('post_id', postIds)) : [],
    postIds.length ? withStatus(sb.rpc('board_post_read_counts', { post_ids: postIds })) : [],
  ]);
  const myReadSet = new Set(myReadRows.map(r => r.post_id));
  const countByPost = {}; for (const c of countRows) countByPost[c.post_id] = c.read_count;

  // "Letto" is automatic on viewing: anything not yet in myReadSet is counted right now, so the
  // checkmark/count are right on this very render, and persisted in the background below rather
  // than making the view wait on a round trip for something this small.
  const newlyRead = postIds.filter(id => !myReadSet.has(id));
  for (const id of newlyRead) { myReadSet.add(id); countByPost[id] = (countByPost[id] || 0) + 1; }

  box.innerHTML = `
    ${canPost ? '<div class="btn-row" style="margin-bottom:10px;"><button class="btn" id="board-new-post">+ New post</button></div>' : ''}
    <div id="board-posts-list">${posts.map(p => renderPostCard(p, docById[p.document_id], textById[p.document_id], myEmail, myReadSet.has(p.id), countByPost[p.id] || 0)).join('') || '<div class="empty-msg">No posts on this board yet.</div>'}</div>`;

  if (canPost) {
    document.getElementById('board-new-post').addEventListener('click', () => openBoardPostPopup({
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

function renderPostCard(p, doc, text, myEmail, iRead, readCount) {
  const canEditThis = canReviewApplications() || (p.posted_by_email === myEmail && State.myBoards.has(p.board_code));
  const canSeeReaders = canReviewApplications() || State.myBoards.has(p.board_code);
  return `
    <div class="panel board-post" data-id="${p.id}">
      <div class="btn-row" style="justify-content:space-between;align-items:flex-start;margin:0 0 4px;">
        <div style="font-weight:600;" dir="auto">${p.pinned ? '📌 ' : ''}${esc(p.title)}</div>
      </div>
      <div class="hint">posted by <span class="board-post-author">…</span> &middot; ${esc((p.created_at || '').slice(0, 10))}</div>
      ${p.body ? `<div class="board-post-body" dir="auto">${esc(p.body)}</div>` : ''}
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
        ${canEditThis ? `<button class="btn secondary" data-edit="${p.id}">Edit</button><button class="btn danger" data-delete="${p.id}">Delete</button>` : ''}
        ${canReviewApplications() ? `<button class="btn secondary" data-pin="${p.id}">${p.pinned ? 'Unpin' : 'Pin'}</button>` : ''}
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
    if (!confirm('Delete this post?')) return;
    await withStatus(sb.from('board_posts').delete().eq('id', btn.dataset.delete), 'Deleting...');
    renderBoardsView(main);
  }));
  document.querySelectorAll('[data-pin]').forEach(btn => btn.addEventListener('click', async () => {
    const post = posts.find(p => String(p.id) === btn.dataset.pin);
    await withStatus(sb.from('board_posts').update({ pinned: !post.pinned }).eq('id', post.id), 'Saving...');
    renderBoardsView(main);
  }));
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
