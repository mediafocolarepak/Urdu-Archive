// Reward's tools in My Department (GOVERNANCE.md §6.4): the credits, the compensation runs, the unusual credits, the tokens, the
// public thanks and the certificates. One screen for each since phase 4 (2026-11-25); people are shown by name.

import { authorNames, sb, State, esc, withStatus, isAdmin, popupShell, promptPopup, errorText, labelOf } from './core.js?v=20261127224837';
import { openPolicyProposalModal } from './policy.js?v=20261127224837';
import { plural, factHtml, tableHtml, namesByIds, nameOnly, decideButtons, itemHtml, wireItems, outcomeHtml, agoText, dayText, personSearch } from './deptui.js?v=20261127224837';

const isRfMember = () => State.myDepartments.some(d => d.department_code === 'RF');
const category = code => labelOf(State.optionListsByName.task_category || [], code) || code;
const personOf = r => (r.full_name || '').trim() || '(no name)';

// ---------- For "Today" ----------

export async function loadRewardItems(open) {
  const [runs, unusual] = await Promise.all([loadRuns('pending'), withStatus(sb.rpc('reward_operator_credit_anomalies'))]);
  const items = runs.items;
  const n = unusual.filter(o => o.flagged).length;
  if (n) items.push({ tone: 'amber', title: 'Unusual credits', text: esc(plural(n, 'person has', 'people have') + ' many credits approved and not published'), can: true, buttons: [{ label: 'Look', run: () => { open('unusual'); return false; } }] });
  return items;
}

// ---------- Credits ----------

export async function renderCredits(box) {
  const [overview, ledger] = await Promise.all([
    withStatus(sb.rpc('reward_credit_overview')),
    withStatus(sb.from('budget_ledger').select('*').order('created_at', { ascending: false })),
  ]);
  const o = overview[0] || { open_credits: 0, in_progress_credits: 0, to_redeem_credits: 0, redeemed_credits: 0, budget: 0 };
  const used = o.open_credits + o.in_progress_credits + o.to_redeem_credits + o.redeemed_credits;
  const name = await authorNames(ledger, 'created_by', 'created_by_email');
  box.innerHTML = `
    <div class="panel">
      <p class="hint">The credits of the tasks, as they are now.</p>
      <div class="dep-facts">
        ${factHtml('Budget', o.budget)}${factHtml('Still free', o.budget - used)}${factHtml('Tasks nobody has taken', o.open_credits)}
        ${factHtml('Tasks in progress', o.in_progress_credits)}${factHtml('Approved, not published', o.to_redeem_credits)}${factHtml('Published', o.redeemed_credits)}
      </div>
      <h3>Added to the budget</h3>
      <p class="hint">An Admin adds to the budget in Tasks, Budget.</p>
      ${tableHtml(['Date', 'Credits', 'Note', 'By'], ledger.map(r => [esc(dayText(r.created_at)), esc(r.amount), esc(r.note), esc(nameOnly(name(r)))]), 'Nothing yet.')}
    </div>`;
}

// ---------- Compensation runs (migration 91, decision matrix row 15) ----------
// Reward prepares, an Admin (for the Owner) decides, and never the person who prepared it: decide_compensation_run() checks it.

async function loadRuns(status) {
  let query = sb.from('compensation_runs').select('*').order('created_at', { ascending: false });
  if (status) query = query.eq('status', status);
  const runs = await withStatus(query);
  const lines = runs.length ? await withStatus(sb.from('compensation_lines').select('*').in('run_id', runs.map(r => r.id))) : [];
  const [name, { data: { user } }] = await Promise.all([namesByIds([...runs.flatMap(r => [r.prepared_by, r.decided_by]), ...lines.map(l => l.user_id)]), sb.auth.getUser()]);
  const items = runs.map(r => {
    const mine = r.prepared_by === user.id, can = r.status === 'pending' && isAdmin() && !mine, l = lines.filter(x => x.run_id === r.id);
    const sum = `${plural(l.length, 'person', 'people')}, ${plural(l.reduce((s, x) => s + x.credits_settled, 0), 'credit', 'credits')}`;
    return {
      run: r, lines: l, can, tone: 'violet', title: 'Compensation run', quote: r.note,
      text: `From ${esc(dayText(r.period_from))} to ${esc(dayText(r.period_to))}: <b>${esc(sum)}</b>${linesHtml(l, name)}`,
      by: `Prepared by ${mine ? 'you' : name(r.prepared_by)}, ${agoText(r.created_at)}${r.status !== 'pending' ? (r.decided_by && r.status !== 'withdrawn' ? `. Decided by ${name(r.decided_by)}, ${agoText(r.decided_at)}` : '') : can ? '' : '. An Admin decides.'}${r.decision_note ? `. Note: ${r.decision_note}` : ''}`,
      buttons: r.status !== 'pending' ? [] : decideButtons({
        mine, can, question: `Approve this run: ${sum}? It writes down that these credits have been paid.`,
        call: (outcome, note) => sb.rpc('decide_compensation_run', { p_run_id: r.id, p_outcome: outcome, ...(note ? { p_note: note } : {}) }),
      }),
    };
  });
  return { items, name };
}
const linesHtml = (lines, name) => `<details class="dep-more"><summary>Who</summary>${tableHtml(['Person', 'Credits', 'Amount', 'Reference'],
  lines.map(l => [esc(name(l.user_id)), esc(l.credits_settled), `${esc(l.amount)} ${esc(l.currency)}`, esc(l.reference)]), 'Nobody.')}</details>`;

export async function renderRuns(box) {
  const { items } = await loadRuns();
  for (const x of items) { const s = { pending: ['violet', '&#8987;', 'Waiting'], approved: ['green', '&#10003;', 'Approved'], rejected: ['red', '&#10005;', 'Not approved'], withdrawn: ['grey', '&#8617;', 'Taken back'] }[x.run.status]; if (s) [x.tone, x.sign, x.state] = s; }
  box.innerHTML = `
    <p class="hint">A run writes down that some credits became money. It does not move money.</p>
    ${isRfMember() ? '<div class="btn-row"><button type="button" class="btn" id="run-new">+ New run</button></div>' : ''}
    ${items.map(itemHtml).join('') || '<div class="panel empty-msg">No runs yet.</div>'}`;
  wireItems(box, items, () => renderRuns(box));
  box.querySelector('#run-new')?.addEventListener('click', () => openNewRun(() => renderRuns(box)));
}

async function openNewRun(onSaved) {
  const people = await withStatus(sb.rpc('reward_unsettled_credits'));
  const { panel, close } = popupShell('new-run', { width: 680, label: 'New run', section: 'mydepartment' });
  panel.innerHTML = `
    <h2 style="margin-top:0;">New run</h2>
    <div class="field-grid">
      <div class="field"><label>From<input id="run-from" type="date"></label></div>
      <div class="field"><label>To<input id="run-to" type="date"></label></div>
      <div class="field" style="grid-column:1/-1;"><label>Note <span class="hint">(if needed)</span><input id="run-note" dir="auto"></label></div>
    </div>
    <h3>Who</h3>
    <p class="hint">Tick each person of this run, and write the amount paid.</p>
    ${people.map((u, i) => `<div class="run-line" data-i="${i}">
      <label class="run-who"><input type="checkbox" data-f="on"> <span dir="auto">${esc(personOf(u))}</span> <span class="hint">${esc(plural(u.unsettled, 'credit', 'credits'))} not paid yet</span></label>
      <div class="field-grid run-fields" hidden>
        <div class="field"><label>Credits<input type="number" data-f="credits" min="1" max="${esc(u.unsettled)}" value="${esc(u.unsettled)}"></label></div>
        <div class="field"><label>Amount<input type="number" data-f="amount" min="0" step="0.01"></label></div>
        <div class="field"><label>Currency<input data-f="currency" value="PKR"></label></div>
        <div class="field"><label>Reference<input data-f="reference"></label></div>
      </div></div>`).join('') || '<div class="empty-msg">Nobody has credits to be paid.</div>'}
    <div class="hint dep-error" id="run-error" role="alert"></div>
    <div class="btn-row" style="justify-content:flex-end;"><button type="button" class="btn secondary" id="run-cancel">Cancel</button>${people.length ? '<button type="button" class="btn" id="run-save">Create the run</button>' : ''}</div>`;
  const $ = id => panel.querySelector('#' + id);
  $('run-cancel').addEventListener('click', close);
  panel.querySelectorAll('.run-line').forEach(l => l.querySelector('[data-f=on]').addEventListener('change', e => { l.querySelector('.run-fields').hidden = !e.target.checked; }));
  $('run-save')?.addEventListener('click', async () => {
    const err = $('run-error'), from = $('run-from').value, to = $('run-to').value;
    err.textContent = '';
    if (!from || !to) { err.textContent = 'Please choose both dates.'; return; }
    const lines = [];
    for (const l of panel.querySelectorAll('.run-line')) {
      const v = f => l.querySelector(`[data-f=${f}]`), u = people[+l.dataset.i];
      if (!v('on').checked) continue;
      const credits_settled = parseInt(v('credits').value, 10), amount = parseFloat(v('amount').value);
      if (!(credits_settled > 0)) { err.textContent = `${personOf(u)}: please write the credits.`; return; }
      if (!(amount > 0)) { err.textContent = `${personOf(u)}: please write the amount.`; return; }
      lines.push({ user_id: u.user_id, credits_settled, amount, currency: v('currency').value.trim() || 'PKR', reference: v('reference').value.trim() || null });
    }
    if (!lines.length) { err.textContent = 'Please tick at least one person.'; return; }
    $('run-save').disabled = true;
    const { error } = await sb.rpc('propose_compensation_run', { p_period_from: from, p_period_to: to, p_note: $('run-note').value.trim() || null, p_lines: lines });
    $('run-save').disabled = false;
    if (error) { err.textContent = errorText(error); return; }
    close();
    onSaved();
  });
}

// ---------- Unusual credits (until 2026-11-25 "Anomaly report"; §2.4/§6.4) ----------

export async function renderUnusual(box) {
  const [tasks, people] = await Promise.all([withStatus(sb.rpc('reward_extra_credit_tasks')), withStatus(sb.rpc('reward_operator_credit_anomalies'))]);
  const flagged = people.filter(o => o.flagged), over = State.policyValues.reward_anomaly_backlog_credits ?? 100;
  const extra = { none: 'Not needed', pending: 'Waiting', approved: 'Approved' };
  const status = { open: 'Open', claimed: 'In progress', submitted: 'In review', approved: 'Approved', published: 'Published', rejected: 'Not approved', withdrawn: 'Withdrawn' };
  box.innerHTML = `
    <div class="panel">
      <h3>People with credits approved and not published <span class="count-badge">${flagged.length}</span></h3>
      <p class="hint">More than ${esc(over)}, and more than their published credits.</p>
      ${tableHtml(['Person', 'Approved, not published', 'Published', 'Tasks published', 'Credits', 'Reputation'],
        flagged.map(o => [esc(personOf(o)), esc(o.approved_not_published_credits), esc(o.published_credits), esc(o.published_task_count), esc(o.credits), esc(o.reputation)]), 'Nobody.')}
    </div>
    <div class="panel">
      <h3>Tasks with extra credits <span class="count-badge">${tasks.length}</span></h3>
      ${tableHtml(['Task', 'Kind of work', 'State', 'Base', 'Extra', 'Why', 'Extra credits', 'Proposed by'],
        tasks.map(t => [`<span dir="auto">${esc(t.title)}</span>`, esc(category(t.category)), esc(status[t.status] || t.status), esc(t.base_credits ?? 0), esc(t.extra_credits), `<span dir="auto">${esc(t.extra_credits_note)}</span>`,
          esc((extra[t.extra_credits_status] || t.extra_credits_status) + (nameOnly(t.extra_credits_approved_by_email) ? ` by ${t.extra_credits_approved_by_email}` : '')), esc(nameOnly(t.created_by_email))]), 'No task has extra credits.')}
    </div>`;
}

// ---------- Tokens of appreciation (docs/TOKEN_POLICY.md, migration 127): never money ----------

const TOKEN_KINDS = { proposal: 'Proposal', reading: 'Reading aloud', report: 'Useful report', titles: 'Urdu titles' };
const TOKEN_UNITS = { page: ['page', 'pages'], minute: ['minute', 'minutes'], unit: ['unit', 'units'] };

export async function renderTokens(box) {
  const [people, entries] = await Promise.all([withStatus(sb.rpc('reward_token_people')), withStatus(sb.rpc('reward_token_entries', { p_limit: 100 }))]);
  const waiting = people.reduce((n, p) => n + Number(p.waiting || 0), 0);
  // Until 179 has been run an entry brings a login instead of a name.
  const who = e => nameOnly(e.user_email) || '(no name)';
  box.innerHTML = `
    <div class="panel">
      <p class="hint">Tokens come by themselves when a proposal or a reading is published. They are never money. How many a page or a minute gives is in Rules. While a number is 0, the tokens wait${waiting ? ` (${waiting} now)` : ''}.</p>
      <h3>Who gave <span class="count-badge">${people.length}</span></h3>
      ${tableHtml(['Person', 'Tokens', 'Contributions', 'Waiting', 'Taken away', 'Last'], people.map(p => [esc(personOf(p)), esc(p.tokens), esc(p.entries), esc(p.waiting), esc(p.annulled), esc(dayText(p.last_at))]), 'Nobody yet.')}
    </div>
    <div class="panel">
      <h3>The last ones</h3>
      ${tableHtml(['Date', 'Person', 'For', 'What', 'Size', 'Tokens', ''], entries.map(e => [
        `${esc(dayText(e.created_at))}${e.past ? '<div class="hint">before tokens began</div>' : ''}`, esc(who(e)), esc(TOKEN_KINDS[e.kind] || e.kind),
        e.document_id ? `#${esc(e.document_id)} <span dir="auto">${esc(e.title)}</span>` : `<span dir="auto">${esc(e.note)}</span>`,
        `${esc(plural(e.units, ...TOKEN_UNITS[e.unit]))}${e.size_recorded ? '' : '<div class="hint">size not known</div>'}`,
        e.annulled ? `<s>${esc(e.tokens ?? '')}</s><div class="hint" dir="auto">Taken away: ${esc(e.annul_note)}</div>` : e.tokens == null ? '<span class="hint">waiting</span>' : esc(e.tokens),
        e.annulled ? ' ' : `<button type="button" class="btn secondary" data-annul="${esc(e.id)}">Take away</button>`,
      ]), 'Nothing yet.')}
    </div>
    <div class="panel">
      <h3>Tokens for a batch of Urdu titles</h3>
      <p class="hint">One for each batch a person sends. Someone else in Reward gives it for your own.</p>
      <div id="tok-person"></div>
      <div class="field"><label>Which batch<input id="tok-note" dir="auto" placeholder="For example: the file of 12 November"></label></div>
      <div class="btn-row"><button type="button" class="btn" id="tok-give" disabled>Give the tokens</button><span id="tok-status" class="hint" role="status"></span></div>
    </div>`;

  box.querySelectorAll('[data-annul]').forEach(b => b.addEventListener('click', async () => {
    const note = await promptPopup('Why are these tokens taken away? (For example: a copy of a text already in the archive.)', '', { okLabel: 'Take away' });
    if (note == null) return;
    if (!note.trim()) { alert('Please write why.'); return; }
    const { error } = await sb.rpc('token_annul', { p_event_id: Number(b.dataset.annul), p_note: note.trim() });
    if (error) { alert(errorText(error)); return; }
    await renderTokens(box);
  }));
  let person = null;
  const give = box.querySelector('#tok-give'), status = box.querySelector('#tok-status'), slot = box.querySelector('#tok-person');
  const ask = () => personSearch(slot, { label: 'Who sent it', onPick: p => {
    person = p; give.disabled = false;
    slot.innerHTML = `<div class="field"><span class="dep-label">Who sent it</span><div><span class="dep-chip" dir="auto">${esc(p.full_name)}</span> <button type="button" class="btn secondary">Change</button></div></div>`;
    slot.querySelector('button').addEventListener('click', () => { person = null; give.disabled = true; ask(); });
  } });
  ask();
  give.addEventListener('click', async () => {
    const note = box.querySelector('#tok-note').value.trim();
    if (!person) return;
    if (!note) { status.textContent = 'Please write which batch.'; return; }
    give.disabled = true;
    const { error } = await sb.rpc('token_give_titles_to', { p_user_id: person.user_id, p_note: note });
    give.disabled = false;
    if (error) { status.textContent = error.code === 'PGRST202' ? 'This is not ready yet. Please try again later.' : errorText(error); return; }
    await renderTokens(box);
  });
}

// ---------- Public thanks ----------

export async function renderThanks(box) {
  const now = new Date();
  box.innerHTML = `
    <div class="panel">
      <p class="hint">Only adults who said yes in My Space, with what they gave that month. No ranking. Copy it for Communication, who publishes it in the app and in Hayat.</p>
      <div class="field" style="max-width:280px;"><label>Month<input id="thanks-month" type="month" value="${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}"></label></div>
      <div class="btn-row"><button type="button" class="btn" id="thanks-show">Show the list</button><button type="button" class="btn secondary" id="thanks-copy" disabled>Copy</button></div>
      <div id="thanks-box"></div>
    </div>`;
  let text = '';
  const month = box.querySelector('#thanks-month'), copy = box.querySelector('#thanks-copy');
  box.querySelector('#thanks-show').addEventListener('click', async () => {
    if (!month.value) return;
    const rows = await withStatus(sb.rpc('reward_public_thanks', { p_month: month.value + '-01' }));
    const what = r => [[r.proposals, 'proposal', 'proposals'], [r.readings, 'reading aloud', 'readings aloud'], [r.reports, 'useful report', 'useful reports'], [r.titles, 'batch of Urdu titles', 'batches of Urdu titles']]
      .filter(([n]) => Number(n) > 0).map(([n, one, many]) => plural(n, one, many)).join(', ');
    const lines = rows.map(r => `${r.full_name}: ${what(r)}`);
    const monthName = new Date(month.value + '-01T12:00:00').toLocaleString('en', { month: 'long', year: 'numeric' });
    text = lines.length ? `Thank you, ${monthName}\n${lines.join('\n')}` : '';
    box.querySelector('#thanks-box').innerHTML = lines.length ? `<pre class="dep-pre" dir="auto">${esc(text)}</pre>` : '<div class="empty-msg">Nobody to thank in public for this month.</div>';
    copy.disabled = !lines.length;
  });
  copy.addEventListener('click', async () => {
    try { await navigator.clipboard.writeText(text); alert('Copied.'); } catch { alert('Copying is not allowed here: select the text and copy it.'); }
  });
}

// ---------- Certificates ----------

export async function renderCertificates(box) {
  const [milestones, texts] = await Promise.all([withStatus(sb.from('token_milestones').select('*').order('tokens')), withStatus(sb.from('token_texts').select('*').order('key'))]);
  box.innerHTML = `
    <div class="panel">
      <h3>Milestones</h3>
      <p class="hint">A certificate of appreciation comes by itself when a person reaches a milestone. It waits until the sentence and the signer below are written. Each change is a proposal: an Admin decides, and it waits in Rules.</p>
      ${tableHtml(['Tokens', 'Name', ''], milestones.map(m => [esc(m.tokens), `<span dir="auto">${esc(m.label)}</span>`,
        `<button type="button" class="btn secondary" data-change="${esc(m.tokens)}">Change</button> <button type="button" class="btn secondary" data-remove="${esc(m.tokens)}">Remove</button>`]), 'No milestone yet.')}
      <div class="btn-row"><button type="button" class="btn" id="ms-add">+ Propose a milestone</button></div>
    </div>
    <div class="panel">
      <h3>The texts of the certificate</h3>
      ${texts.map(t => `<div class="rule"><div class="rule-text"><span class="hint">${esc(t.label)}</span><div dir="auto">${t.text ? esc(t.text) : '<span class="hint">not written yet</span>'}</div></div><div class="rule-side"><button type="button" class="btn secondary" data-text="${esc(t.key)}">Change</button></div></div>`).join('')}
    </div>
    <div class="panel">
      <h3>Check a certificate</h3>
      <div class="field" style="max-width:320px;"><label>Its code<input id="cert-code" autocomplete="off" placeholder="10 letters and numbers"></label></div>
      <div class="btn-row"><button type="button" class="btn secondary" id="cert-check">Check</button><span id="cert-result" class="hint" role="status"></span></div>
    </div>`;
  const again = () => renderCertificates(box);
  const propose = (key, tokens, label) => openPolicyProposalModal({
    title: key ? `Change the milestone of ${key} tokens` : 'A new milestone',
    targetTable: 'token_milestones', targetKey: key || '', action: 'upsert', owners: ['RF'],
    fields: [{ name: 'tokens', label: 'Tokens needed', type: 'number', value: tokens }, { name: 'label', label: 'Its name (if needed)', type: 'text', value: label }], onSaved: again,
  });
  box.querySelector('#ms-add').addEventListener('click', async () => {
    const n = await promptPopup('How many tokens for the new milestone?');
    if (n == null) return;
    if (!/^[1-9][0-9]*$/.test(n.trim())) { alert('Please write a whole number above 0.'); return; }
    propose(n.trim(), n.trim(), '');
  });
  box.querySelectorAll('[data-change]').forEach(b => b.addEventListener('click', () => propose(b.dataset.change, b.dataset.change, milestones.find(m => String(m.tokens) === b.dataset.change)?.label || '')));
  box.querySelectorAll('[data-remove]').forEach(b => b.addEventListener('click', () => openPolicyProposalModal({
    title: `Remove the milestone of ${b.dataset.remove} tokens`, targetTable: 'token_milestones', targetKey: b.dataset.remove, action: 'delete', owners: ['RF'], fields: null, onSaved: again,
  })));
  box.querySelectorAll('[data-text]').forEach(b => b.addEventListener('click', () => {
    const t = texts.find(x => x.key === b.dataset.text);
    openPolicyProposalModal({ title: t.label, targetTable: 'token_texts', targetKey: t.key, action: 'upsert', owners: ['RF'], fields: [{ name: 'text', label: 'Text', type: 'text', value: t.text }], onSaved: again });
  }));
  box.querySelector('#cert-check').addEventListener('click', async () => {
    const out = box.querySelector('#cert-result'), code = box.querySelector('#cert-code').value.trim();
    if (!code) return;
    const { data, error } = await sb.rpc('verify_token_certificate', { p_code: code });
    if (error) { out.textContent = errorText(error); return; }
    const c = (data || [])[0];
    out.textContent = c ? `Genuine: ${c.full_name}, ${c.milestone} tokens, ${dayText(c.issued_at)}, signed by ${c.signer}.` : 'No certificate has this code.';
  });
}
