// "My work": the room of the work, the one thing an Operator has more than a User (Owner's concept, 2026-11-25). Home is the
// spiritual home, the same for everyone and silent; here are the things to do, what waits for others, the tools, the credits
// and the notices of the team. The sections that serve both places appear in both, each with its own dress (core.js quiet()).

import { sb, State, esc, today, isDeptLead, isAnyDeptLead, standingHtml, showGoodPracticesModal, openTranslatePopup } from './core.js?v=20261128134020';

const quietly = promise => Promise.resolve(promise).then(r => (r && !r.error ? r.data : null), () => null);

// Everything this person has to do, or waits for. Each part on its own: what cannot be read is simply not there.
// { todo: [{ tone, sign, state, title, note, action, open }], waiting: [...], counts: {...} }
export async function loadWork() {
  const { data: { user } } = await sb.auth.getUser();
  const [mine, openTasks, taskReviews, submissions, subCounts, readCounts, pending, messages, standing] = await Promise.all([
    quietly(sb.from('tasks').select('id,title,status,due_date,submitted_at').eq('claimed_by', user.id).in('status', ['claimed', 'submitted'])),
    quietly(sb.from('tasks').select('id').eq('status', 'open')),
    quietly(sb.rpc('get_review_queue')),
    quietly(sb.rpc('get_my_submissions')),
    quietly(sb.rpc('get_submission_counts')),
    quietly(sb.rpc('get_reading_counts')),
    State.myBoards.size ? quietly(sb.from('board_posts').select('id,board_code').eq('status', 'pending').in('board_code', [...State.myBoards])) : null,
    State.myDepartments.length ? quietly(sb.from('department_messages').select('department_code,created_at').neq('user_id', user.id).order('created_at', { ascending: false }).limit(60)) : null,
    quietly(sb.from('user_roles').select('credits,reputation').eq('user_id', user.id)),
  ]);
  const days = due => Math.round((new Date(due + 'T00:00') - new Date(today() + 'T00:00')) / 86400000);
  const n = (count, one, many) => `${count} ${count === 1 ? one : many}`;
  const todo = [], waiting = [];

  const goTasks = view => () => { State.tasksView = view; if (view === 'mine') State.mineTab = 'active'; window.__renderTab('tasks', 'work'); };
  for (const t of (mine || []).filter(x => x.status === 'claimed').sort((a, b) => ((a.due_date || '9') < (b.due_date || '9') ? -1 : 1))) {
    const d = t.due_date ? days(t.due_date) : null;
    const late = d !== null && d < 0, soon = d !== null && d >= 0 && d <= (State.policyValues.task_near_due_days ?? 3);
    todo.push({ rank: late ? 0 : soon ? 2 : 3, tone: late ? 'red' : soon ? 'amber' : 'blue', sign: late ? '&#9888;' : soon ? '&#9200;' : '&#9998;',
      state: late ? `Overdue by ${n(-d, 'day', 'days')}` : d === 0 ? 'Due today' : soon ? `Due in ${n(d, 'day', 'days')}` : d === null ? 'In progress' : `In progress, due in ${n(d, 'day', 'days')}`,
      title: t.title, note: 'Task', action: 'Continue', open: () => window.__renderTab('tasks', 'work', 'task/' + t.id) });
  }
  for (const s of (submissions || []).filter(x => x.status === 'to_correct')) {
    todo.push({ rank: 1, tone: 'red', sign: '&#8617;', state: 'To correct', title: s.title || 'Your proposal', note: s.decision_note || 'Your proposal', action: 'Correct',
      open: () => { State.proposalOpen = s.id; window.__renderTab('proposals', 'work'); } });
  }
  const rc = (readCounts && readCounts[0]) || {}, sc = (subCounts && subCounts[0]) || {};
  if (rc.to_rerecord) todo.push({ rank: 1, tone: 'red', sign: '&#8617;', state: 'To record again', title: n(rc.to_rerecord, 'reading of yours', 'readings of yours'), note: 'Read aloud', action: 'Open', open: () => { State.readingsTab = 'mine'; window.__renderTab('readings', 'home'); } });
  if ((taskReviews || []).length) todo.push({ rank: 4, tone: 'violet', sign: '&#128065;', state: 'For you to review', title: n(taskReviews.length, 'task', 'tasks'), note: '', action: 'Review', open: goTasks('review') });
  if (sc.to_review) todo.push({ rank: 4, tone: sc.overdue ? 'red' : 'violet', sign: '&#128065;', state: 'For you to review', title: n(sc.to_review, 'proposal', 'proposals'), note: sc.overdue ? `${sc.overdue} for over 7 days` : '', action: 'Review', open: () => { State.proposalsTab = 'queue'; window.__renderTab('proposals', 'work'); } });
  if (rc.to_listen) todo.push({ rank: 5, tone: 'violet', sign: '&#128266;', state: 'For you to listen to', title: n(rc.to_listen, 'reading', 'readings'), note: '', action: 'Listen', open: () => { State.readingsTab = 'listen'; window.__renderTab('readings', 'work'); } });
  if ((pending || []).length) todo.push({ rank: 5, tone: 'violet', sign: '&#128172;', state: 'Posts waiting', title: n(pending.length, 'post on your boards', 'posts on your boards'), note: '', action: 'Look', open: () => { State.boardsSelected = pending[0].board_code; window.__renderTab('boards', 'work'); } });
  todo.sort((a, b) => a.rank - b.rank);

  for (const t of (mine || []).filter(x => x.status === 'submitted')) waiting.push({ title: t.title, note: 'Task sent for review' });
  for (const s of (submissions || []).filter(x => x.status === 'submitted')) waiting.push({ title: s.title || 'Your proposal', note: `Proposal sent for review${s.days_waiting ? `, ${n(s.days_waiting, 'day', 'days')} ago` : ' today'}` });

  // The messages of the team not seen yet on this device (mydepartment.js keeps when each department's channel was opened).
  const unseen = {};
  for (const m of messages || []) {
    const seen = localStorage.getItem(`deptMsgSeenAt_${m.department_code}_${user.id}`) || '1970-01-01T00:00:00.000Z';
    if (m.created_at > seen) unseen[m.department_code] = (unseen[m.department_code] || 0) + 1;
  }
  return { todo, waiting, standing: (standing && standing[0]) || null, unseen,
    counts: { open: (openTasks || []).length, mine: (mine || []).filter(x => x.status === 'claimed').length, reviews: (taskReviews || []).length, proposals: sc, readings: rc, pending: (pending || []).length, messages: Object.values(unseen).reduce((a, b) => a + b, 0) } };
}

const ICONS = {
  tasks: 'M4 6h3M4 12h3M4 18h3M10 6h10M10 12h10M10 18h10', proposals: 'M12 4v16M4 12h16', review: 'M2 12c3-6 17-6 20 0-3 6-17 6-20 0zM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
  mydepartment: 'M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM3 20a6 6 0 0 1 12 0M17 11a3 3 0 1 0 0-6M17 14a6 6 0 0 1 4 6', dashboard: 'M4 4h12a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3zM4 17a3 3 0 0 1 3-3h12',
  formation: 'M12 4l9 5-9 5-9-5zM7 11v5c3 2 7 2 10 0v-5', boards: 'M4 4h16v11H4zM8 20l4-5 4 5M8 8h8M8 11h5', readings: 'M12 15a3 3 0 0 0 3-3V6a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zM6 11a6 6 0 0 0 12 0M12 17v4',
  inpageconverter: 'M4 7h13l-3-3M20 17H7l3 3', findwork: 'M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM21 21l-5-5', sharewithus: 'M4 5h16v11H9l-5 4z', translate: 'M4 5h9M8 3v2M11 5c-1 4-4 7-7 8M6 9c1 2 3 4 5 5M12 20l4-9 4 9M13.5 17h5',
  received: 'M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.600-7 10-7 10z', practices: 'M12 3l2.7 5.6 6.1.8-4.5 4.2 1.1 6.1L12 16.8l-5.4 2.900 1.100-6.100L3.200 9.400l6.100-.8z',
};
const icon = k => `<span class="start-icon" aria-hidden="true"><svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="${ICONS[k]}"/></svg></span>`;

// The tools of this person: [key, title, note, colour, what it does].
function toolsFor(w) {
  const c = w.counts, go = (tab, before) => () => { if (before) before(); window.__renderTab(tab, 'work'); };
  const some = (count, text) => (count ? `${count} ${text}` : '');
  const tools = [
    ['tasks', 'Tasks', [some(c.open, 'to take'), some(c.mine, 'in progress')].filter(Boolean).join(', ') || 'Nothing open right now', 'work', go('tasks', () => { State.tasksView = c.mine ? 'mine' : 'store'; })],
    ['proposals', 'Proposals', 'Add a text, or correct one of yours', 'work', go('proposals', () => { State.proposalsTab = 'mine'; })],
  ];
  if (c.reviews || c.proposals.to_review || State.myQualifications.has('REVISOR')) tools.push(['review', 'Review', some((c.reviews || 0) + (c.proposals.to_review || 0), 'waiting for you') || 'Nothing is waiting', 'work',
    go(c.reviews || !c.proposals.to_review ? 'tasks' : 'proposals', () => { State.tasksView = 'review'; State.proposalsTab = 'queue'; })]);
  if (State.myDepartments.length) tools.push(['mydepartment', 'My Department', some(c.messages, c.messages === 1 ? 'new message' : 'new messages') || 'The team, its work and its tools', 'dept',
    go('mydepartment', () => { const code = Object.keys(w.unseen)[0]; if (code) State.myDeptSelected = code; })]);
  tools.push(['dashboard', 'Library, to work on', 'Translate, add a version, propose', 'library', go('dashboard')]);
  tools.push(['translate', 'Translate a text', 'Prepare a translation', 'library', () => openTranslatePopup()]);
  if (State.isFormatore) tools.push(['formation', 'Formation Paths, to prepare', 'Write and look after the paths', 'formation', go('formation', () => { State.formationSelectedPathId = null; })]);
  if (State.myBoards.size) tools.push(['boards', 'Boards, to look after', some(c.pending, c.pending === 1 ? 'post waiting' : 'posts waiting') || 'Nothing is waiting', 'boards', go('boards')]);
  if (c.readings.to_listen) tools.push(['readings', 'Readings to listen to', some(c.readings.to_listen, 'waiting'), 'readings', go('readings', () => { State.readingsTab = 'listen'; })]);
  if (isAnyDeptLead()) tools.push(['findwork', 'Find work to do', 'What is missing in the archive', 'work', go('findwork')]);
  tools.push(['inpageconverter', 'InPage Converter', 'From InPage to Word and PDF', 'dept', go('inpageconverter')]);
  if (isAnyDeptLead()) tools.push(['received', 'What people shared', 'Read, thank, write back', 'share', go('sharewithus')]);
  tools.push(['sharewithus', 'Share with us', 'Tell the team, by voice or in writing', 'share', () => window.__renderTab('sharewithus', 'home')]);
  tools.push(['practices', 'Good practices', 'How we work together', 'profile', () => showGoodPracticesModal()]);
  return tools;
}

export async function renderWorkView(main) {
  const w = await loadWork();
  if (main.dataset.section !== 'work') return;
  const tools = toolsFor(w);
  const lead = State.myDepartments.filter(d => isDeptLead(d.department_code)).length;
  main.innerHTML = `
    <div class="work-page">
      <div class="work-standing">${w.standing ? standingHtml(w.standing.credits, w.standing.reputation) : ''}</div>
      <section>
        <h2 class="work-h">To do now</h2>
        ${w.todo.length ? w.todo.map((x, i) => `
          <div class="work-item st-${x.tone}">
            <div class="work-item-text"><span class="st st-${x.tone}"><span aria-hidden="true">${x.sign}</span> ${esc(x.state)}</span>
              <div class="work-item-title" dir="auto">${esc(x.title)}</div>${x.note ? `<div class="hint" dir="auto">${esc(x.note)}</div>` : ''}</div>
            <button class="btn" data-todo="${i}">${esc(x.action)}</button>
          </div>`).join('') : '<div class="panel work-clear"><span aria-hidden="true">&#10003;</span> Nothing is waiting for you. Thank you!</div>'}
      </section>
      ${w.waiting.length ? `<details class="subpanel work-waiting" ${w.todo.length ? '' : 'open'}><summary>Waiting for others <span class="count-badge">${w.waiting.length}</span></summary>
        ${w.waiting.map(x => `<div class="work-waiting-row"><span class="st st-violet"><span aria-hidden="true">&#8987;</span> ${esc(x.note)}</span><div dir="auto">${esc(x.title)}</div></div>`).join('')}</details>` : ''}
      <section>
        <h2 class="work-h">Tools${lead ? ` <span class="hint">you lead ${lead === 1 ? 'a department' : `${lead} departments`}</span>` : ''}</h2>
        <div class="work-tools">${tools.map(([key, title, note, colour], i) => `
          <button type="button" class="home-tile work-tile" data-tool="${i}" style="--sec:var(--c-${colour})">${icon(key)}
            <span class="work-tile-text"><span class="home-tile-en">${esc(title)}</span><span class="hint">${esc(note)}</span></span><span class="start-chevron" aria-hidden="true">&rsaquo;</span></button>`).join('')}</div>
      </section>
    </div>`;
  main.querySelectorAll('[data-todo]').forEach(b => b.addEventListener('click', () => w.todo[+b.dataset.todo].open()));
  main.querySelectorAll('[data-tool]').forEach(b => b.addEventListener('click', () => tools[+b.dataset.tool][4]()));
  main.querySelector('#good-practices-btn')?.addEventListener('click', showGoodPracticesModal);
  return w;
}
