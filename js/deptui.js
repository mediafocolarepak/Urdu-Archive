// The small pieces My Department's screens share (phase 4, 2026-11-25): what state a thing is in, who did it, a table that
// becomes cards on a phone, the choice of a person by name. People are shown by name, never by login.

import { sb, State, esc, nameMapForIds, confirmPopup, promptPopup, errorText } from './core.js?v=20261127223631';

export const plural = (n, one, many) => `${n} ${Number(n) === 1 ? one : many}`;
export const dash = '&mdash;';
// Until 179 has been run some columns still bring a login: it is not shown.
export const nameOnly = v => (v && !String(v).includes('@') ? String(v) : '');

export function deptLabel(code) {
  const hit = (State.optionListsByName.department || []).find(([c]) => c === code);
  return hit ? hit[1] : code;
}

const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
export function dayText(iso) {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso || '');
  return m ? `${Number(m[3])} ${MONTHS[Number(m[2]) - 1]} ${m[1]}` : '';
}
export function agoText(iso) {
  if (!iso) return '';
  const day = d => new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const n = Math.round((day(new Date()) - day(new Date(iso))) / 86400000);
  return n <= 0 ? 'today' : n === 1 ? 'yesterday' : n < 30 ? `${n} days ago` : `on ${dayText(iso)}`;
}

// A sign and a word, never only a colour.
export const st = (tone, sign, text) => `<span class="st st-${tone}"><span aria-hidden="true">${sign}</span> ${esc(text)}</span>`;
export const OUTCOME = {
  pending: ['violet', '&#8987;', 'Waiting'], approved: ['green', '&#10003;', 'Approved'],
  rejected: ['red', '&#10005;', 'Not approved'], withdrawn: ['grey', '&#8617;', 'Taken back'],
};
export const outcomeHtml = status => st(...(OUTCOME[status] || ['grey', '&#8226;', status || '']));

// Names by account. Whoever has no name is "(no name)": a login never takes its place.
export async function namesByIds(ids) {
  const map = await nameMapForIds(ids, { logins: false });
  return id => (id ? map[id] || '(no name)' : '');
}

// Something to decide, or to look at: { tone, sign, state, title, text (html), quote, by, buttons: [{ label, kind, run }] }.
// run() says true when the list must be read again.
export function itemHtml(x, i) {
  return `<div class="work-item dep-item st-${x.tone || 'violet'}" data-item="${i}">
    <div class="work-item-text">
      ${x.sign ? st(x.tone || 'violet', x.sign, x.state) : ''}
      <div class="work-item-title" dir="auto">${esc(x.title)}</div>
      ${x.text ? `<div class="dep-what">${x.text}</div>` : ''}
      ${x.quote ? `<div class="dep-quote" dir="auto">&ldquo;${esc(x.quote)}&rdquo;</div>` : ''}
      ${x.by ? `<div class="hint dep-by">${esc(x.by)}</div>` : ''}
    </div>
    ${(x.buttons || []).length ? `<div class="btn-row dep-item-btns">${x.buttons.map((b, n) => `<button type="button" class="btn ${b.kind || ''}" data-btn="${n}">${esc(b.label)}</button>`).join('')}</div>` : ''}
  </div>`;
}
export function wireItems(box, items, again) {
  box.querySelectorAll('[data-item]').forEach(el => el.querySelectorAll('[data-btn]').forEach(b => b.addEventListener('click', async () => {
    const todo = items[+el.dataset.item].buttons[+b.dataset.btn];
    b.disabled = true;
    try { if (await todo.run()) await again(); } finally { b.disabled = false; }
  })));
}

// The buttons of something proposed: approve and reject (with a note), or take it back. call(outcome, note) answers { error }.
export function decideButtons({ mine, can, call, question, approved }) {
  const go = async (outcome, note) => {
    const { error } = await call(outcome, note);
    if (error) { alert(errorText(error)); return false; }
    if (outcome === 'approved' && approved) await approved();
    return true;
  };
  if (can) return [
    { label: 'Approve', run: async () => (await confirmPopup(question, { confirmLabel: 'Approve' })) && go('approved') },
    { label: 'Reject', kind: 'secondary', run: async () => {
      const note = await promptPopup('Why not? The person who proposed it will read this.', '', { okLabel: 'Reject' });
      if (note == null) return false;
      if (!note.trim()) { alert('Please write why.'); return false; }
      return go('rejected', note.trim());
    } },
  ];
  if (mine) return [{ label: 'Take it back', kind: 'secondary', run: async () => (await confirmPopup('Take back this proposal?')) && go('withdrawn') }];
  return [];
}

// A table on a computer; on a phone each row is a card, with the name of each column. The cells are html.
export function tableHtml(heads, rows, empty) {
  if (!rows.length) return `<div class="empty-msg">${esc(empty)}</div>`;
  return `<div class="dep-table-wrap"><table class="grid dep-table">
    <thead><tr>${heads.map(h => `<th scope="col">${esc(h)}</th>`).join('')}</tr></thead>
    <tbody>${rows.map(r => `<tr>${r.map((c, i) => `<td ${heads[i] ? `data-l="${esc(heads[i])}"` : 'class="dep-td-btns"'}>${c === '' || c == null ? dash : c}</td>`).join('')}</tr>`).join('')}</tbody>
  </table></div>`;
}

export const factHtml = (label, value) => `<div class="dep-fact"><span>${esc(label)}</span><b>${esc(value)}</b></div>`;

// Choosing a person by name (find_people, migration 179: names only). onPick({ user_id, full_name }).
export function personSearch(box, { label, onPick }) {
  box.innerHTML = `<div class="field dep-find"><label>${esc(label)}<input type="search" autocomplete="off" placeholder="Write at least 3 letters of the name"></label></div><div class="dep-found" aria-live="polite"></div>`;
  const input = box.querySelector('input'), out = box.querySelector('.dep-found');
  let timer = null, turn = 0;
  input.addEventListener('input', () => {
    clearTimeout(timer);
    const q = input.value.trim(), mine = ++turn;
    if (q.length < 3) { out.innerHTML = ''; return; }
    timer = setTimeout(async () => {
      const { data, error } = await sb.rpc('find_people', { p_query: q });
      if (mine !== turn) return;
      if (error) { out.innerHTML = `<div class="hint">${error.code === 'PGRST202' ? 'This is not ready yet. Please try again later.' : esc(errorText(error))}</div>`; return; }
      const rows = data || [];
      out.innerHTML = rows.map((r, i) => `<button type="button" class="btn secondary" data-n="${i}">${esc(r.full_name)}</button>`).join('') || '<div class="hint">Nobody found.</div>';
      out.querySelectorAll('[data-n]').forEach(b => b.addEventListener('click', () => { input.value = ''; out.innerHTML = ''; onPick(rows[+b.dataset.n]); }));
    }, 250);
  });
}
