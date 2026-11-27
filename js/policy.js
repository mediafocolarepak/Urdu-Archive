// The rules with a number (GOVERNANCE.md §2.8/§6.6, migration 86): task_category_rates, task_reputation_tiers and policy_values
// change only through a proposal that an Admin decides - propose_policy_change()/decide_policy_change() are the real gate, this
// module is only their screen. Since phase 4 (2026-11-25) each rule is a plain sentence, and people are shown by name. Used by
// My Department (tab Rules, and "To decide" in Today), by Reward's certificates and by Options (admin.js).

import { sb, State, esc, withStatus, canProposePolicyChange, canApprovePolicyChange, popupShell, errorText, labelOf } from './core.js?v=20261127224837';
import { deptLabel, namesByIds, itemHtml, wireItems, decideButtons, agoText, dayText, outcomeHtml } from './deptui.js?v=20261127224837';

// Who may propose a change to each policy_values key (GOVERNANCE.md §2.8). task_category_rates and task_reputation_tiers are
// Reward's alone.
const POLICY_VALUE_OWNERS = {
  extra_credit_pct_threshold: ['RF'],
  extra_credit_abs_threshold: ['RF'],
  risk_reputation_below: ['HR', 'RF'],
  risk_negative_events: ['HR', 'RF'],
  risk_window_days: ['HR', 'RF'],
  board_misuse_reputation_delta: ['FORM', 'HR'],
  task_near_due_days: ['COORD'],
  task_max_in_progress: ['COORD'],
  token_per_page: ['RF'],
  token_per_minute: ['RF'],
  token_per_unit: ['RF'],
};

export function ownersFor(targetTable, targetKey) {
  if (targetTable === 'policy_values') return POLICY_VALUE_OWNERS[targetKey] || ['RF'];
  return ['RF'];
}

// HR reads Reward's reputation tiers, to judge who is "at risk" (owner's request 2026-09-20), without proposing changes.
const SEES_TIERS = ['RF', 'HR'];

// The sentences (Owner's decision, 2026-11-25). Each number changes on its own: one button for each.
const num = v => `<b class="rule-n">${esc(v)}</b>`;
const RULES = [
  { keys: ['task_max_in_progress'], say: v => `A person can have ${num(v[0])} ${v[0] === 1 ? 'task' : 'tasks'} in progress.`, short: ['Tasks in progress for each person'] },
  { keys: ['task_near_due_days'], say: v => `A task is &ldquo;due soon&rdquo; ${num(v[0])} ${v[0] === 1 ? 'day' : 'days'} before its date.`, short: ['Days before the date when a task is "due soon"'] },
  { keys: ['extra_credit_pct_threshold', 'extra_credit_abs_threshold'], say: v => `The Coordination lead must approve extra credits over ${num(v[0] + '%')} of the base, or over ${num(v[1])}.`,
    short: ['Extra credits to approve: over this % of the base', 'Extra credits to approve: over this number'], buttons: v => [`Change ${v[0]}%`, `Change ${v[1]}`] },
  { keys: ['risk_reputation_below'], say: v => `A person is &ldquo;at risk&rdquo; with reputation under ${num(v[0])}.`, short: ['A person is "at risk" with reputation under this number'] },
  { keys: ['risk_negative_events', 'risk_window_days'], say: v => `A person is &ldquo;at risk&rdquo; with ${num(v[0])} negative ${v[0] === 1 ? 'event' : 'events'} in ${num(v[1])} days.`,
    short: ['A person is "at risk" with this number of negative events', 'Days in which the negative events are counted'], buttons: v => [`Change ${v[0]}`, `Change ${v[1]} days`] },
  { keys: ['board_misuse_reputation_delta'], say: v => `Misuse of a board takes away ${num(v[0])} points of reputation.`, short: ['Points of reputation that misuse of a board takes away'], minus: true },
  { keys: ['reward_anomaly_backlog_credits'], say: v => `Reward looks at a person with more than ${num(v[0])} credits approved and not published.`, short: ['Credits approved and not published that Reward looks at'] },
  { keys: ['token_per_page', 'token_per_minute', 'token_per_unit'], say: v => `A page gives ${num(v[0])} ${v[0] === 1 ? 'token' : 'tokens'}, a minute ${num(v[1])}, a report or a batch of titles ${num(v[2])}. (0 = not decided yet)`,
    short: ['Tokens for a page', 'Tokens for a minute', 'Tokens for a report or a batch of titles'], buttons: () => ['Change a page', 'Change a minute', 'Change a report or batch'] },
];
const ruleOf = key => RULES.find(r => r.keys.includes(key));
const shown = (key, value) => (ruleOf(key)?.minus ? Math.abs(Number(value)) : value);
function ruleShort(key, label) { const r = ruleOf(key); return r ? r.short[r.keys.indexOf(key)] : label || key; }
const TIER_FIELDS = [['tier_name', 'Name'], ['min_base_credits', 'Credits, from'], ['max_base_credits', 'Credits, up to (empty = no limit)'], ['ok_delta', 'OK'], ['ok_but_delta', 'OK, but...'], ['fail_delta', 'Fail'], ['sort_order', 'Order in the list']];
const categoryLabel = code => labelOf(State.optionListsByName.task_category || [], code) || code;

// A proposal of a change. `fields`: [{ name, label, type: 'text'|'number', value, minus }] become field_changes (action 'upsert'),
// or null (action 'delete': only the reason). `owners`: the departments that may propose it; with more than one, the person
// chooses for which one they propose.
export function openPolicyProposalModal({ title, targetTable, targetKey, action, owners, fields, onSaved }) {
  const proposable = owners.filter(d => canProposePolicyChange(d));
  if (!proposable.length) { alert('Only the lead of the department of this rule can propose a change.'); return; }
  const { panel, close } = popupShell('rule-proposal', { label: title, section: 'mydepartment' });
  panel.innerHTML = `
    <h2 style="margin-top:0;">${esc(title)}</h2>
    <p class="hint">An Admin decides. Until then nothing changes.</p>
    ${proposable.length > 1 ? `<div class="field"><label>Propose for
      <select id="polprop-department">${proposable.map(d => `<option value="${esc(d)}" ${d === State.myDeptSelected ? 'selected' : ''}>${esc(deptLabel(d))}</option>`).join('')}</select></label>
    </div>` : `<input type="hidden" id="polprop-department" value="${esc(proposable[0])}">`}
    ${action === 'delete' ? '<p>This removes it.</p>'
      : (fields || []).map(f => `<div class="field"><label>${esc(f.label)}
          <input id="polprop-field-${esc(f.name)}" type="${f.type === 'number' ? 'number' : 'text'}" ${f.type === 'number' ? 'step="any"' : 'dir="auto"'} value="${f.value == null ? '' : esc(f.minus ? Math.abs(Number(f.value)) : f.value)}"></label></div>`).join('')}
    <div class="field"><label>Why? <span class="hint">(needed)</span>
      <textarea id="polprop-reason" rows="3" dir="auto"></textarea></label></div>
    <div id="polprop-error" class="hint dep-error" role="alert"></div>
    <div class="btn-row" style="justify-content:flex-end;">
      <button type="button" class="btn secondary" id="polprop-cancel">Cancel</button>
      <button type="button" class="btn" id="polprop-save">Propose</button>
    </div>`;
  const $ = id => panel.querySelector('#' + id);
  $('polprop-cancel').addEventListener('click', close);
  $('polprop-save').addEventListener('click', async () => {
    const reason = $('polprop-reason').value.trim(), errBox = $('polprop-error');
    errBox.textContent = '';
    const field_changes = {};
    if (action !== 'delete') {
      for (const f of (fields || [])) {
        const raw = $(`polprop-field-${f.name}`).value.trim();
        field_changes[f.name] = raw === '' ? null : f.type === 'number' ? (f.minus ? -Math.abs(Number(raw)) : Number(raw)) : raw;
      }
    }
    if ((fields || []).length === 1 && fields[0].type === 'number' && field_changes[fields[0].name] == null) { errBox.textContent = 'Please write a number.'; return; }
    if (!reason) { errBox.textContent = 'Please write why.'; return; }
    $('polprop-save').disabled = true;
    const { error } = await sb.rpc('propose_policy_change', {
      p_department: $('polprop-department').value, p_target_table: targetTable, p_target_key: targetKey,
      p_action: action, p_field_changes: field_changes, p_reason: reason,
    });
    $('polprop-save').disabled = false;
    if (error) { errBox.textContent = errorText(error); return; }
    close();
    if (onSaved) await onSaved();
  });
}

// ---------- What a proposal says, in words ----------

// now: the numbers in force { values, rates, tiers, texts }, to say "from"; past proposals do not have it.
function changeHtml(p, now) {
  const f = p.field_changes || {}, b = v => `<b>${esc(v == null ? 'nothing' : v)}</b>`;
  const fromTo = (from, to) => (now && from !== undefined ? `From ${b(from)} to ${b(to)}` : `To ${b(to)}`);
  if (p.target_table === 'policy_values') {
    const cur = now?.values[p.target_key];
    return `${fromTo(cur ? shown(p.target_key, cur.value) : undefined, shown(p.target_key, f.value))}: ${esc(ruleShort(p.target_key, cur?.label))}`;
  }
  if (p.target_table === 'task_category_rates') {
    if (p.action === 'delete') return `Remove the credits of ${esc(categoryLabel(p.target_key))}`;
    return `${fromTo(now?.rates[p.target_key]?.credits_per_page, f.credits_per_page)}: credits for a page of ${esc(categoryLabel(p.target_key))}`;
  }
  if (p.target_table === 'task_reputation_tiers') {
    if (p.action === 'delete') return `Remove the size &ldquo;${esc(p.target_key)}&rdquo;`;
    const cur = now?.tiers[p.target_key];
    const changed = TIER_FIELDS.filter(([k]) => k in f && (!cur || String(cur[k] ?? '') !== String(f[k] ?? '')));
    return `${esc(p.target_key)}: ${changed.map(([k, l]) => `${esc(l.replace(/ \(.*/, ''))} ${cur ? `from ${b(cur[k])} to ` : ''}${b(f[k])}`).join(', ') || 'no change'}`;
  }
  if (p.target_table === 'token_milestones') {
    if (p.action === 'delete') return `Remove the milestone of ${b(p.target_key)} tokens`;
    return `Milestone of ${b(f.tokens ?? p.target_key)} tokens${f.label ? `: &ldquo;${esc(f.label)}&rdquo;` : ''}`;
  }
  if (p.target_table === 'token_texts') return `${esc(now?.texts[p.target_key]?.label || 'A text of the certificate')}: <span dir="auto">&ldquo;${esc(f.text)}&rdquo;</span>`;
  return esc(`${p.target_key}: ${Object.entries(f).map(([k, v]) => `${k} ${v}`).join(', ')}`);
}

async function loadRules() {
  const [rates, tiers, values, texts, proposals] = await Promise.all([
    withStatus(sb.from('task_category_rates').select('*').order('category')),
    withStatus(sb.from('task_reputation_tiers').select('*').order('sort_order')),
    withStatus(sb.from('policy_values').select('*').order('key')),
    sb.from('token_texts').select('key,label').then(r => r.data || [], () => []),
    withStatus(sb.from('policy_proposals').select('*').order('proposed_at', { ascending: false })),
  ]);
  const by = (rows, key) => Object.fromEntries(rows.map(r => [r[key], r]));
  return { rates, tiers, values, proposals, now: { rates: by(rates, 'category'), tiers: by(tiers, 'tier_name'), values: by(values, 'key'), texts: by(texts, 'key') } };
}

async function refreshPolicyValues() {
  // The numbers the app read when it started (core.js): the new one counts at once.
  const { data } = await sb.from('policy_values').select('key,value');
  if (!data) return;
  State.policyValues = Object.fromEntries(data.map(p => [p.key, p.value]));
}

async function proposalItems(pending, now) {
  const { data: { user } } = await sb.auth.getUser();
  const name = await namesByIds(pending.map(p => p.proposed_by));
  return pending.map(p => ({
    tone: 'violet', title: 'A rule', text: changeHtml(p, now), quote: p.reason, can: canApprovePolicyChange(),
    by: `Proposed by ${name(p.proposed_by)}, ${agoText(p.proposed_at)}${canApprovePolicyChange() ? '' : '. An Admin decides.'}`,
    buttons: decideButtons({
      mine: p.proposed_by === user.id, can: canApprovePolicyChange(), question: 'Approve this change? It counts from now.',
      call: (outcome, note) => sb.rpc('decide_policy_change', { p_id: p.id, p_outcome: outcome, ...(note ? { p_note: note } : {}) }),
      approved: refreshPolicyValues,
    }),
  }));
}

// For "Today": the proposals of this department that wait. can: this person decides them.
export async function loadRuleItems(code) {
  const { proposals, now } = await loadRules();
  return proposalItems(proposals.filter(p => p.status === 'pending' && p.department_code === code).reverse(), now);
}

// ---------- The tab "Rules" ----------

export async function renderRules(box, code) {
  const { rates, tiers, values, proposals, now } = await loadRules();
  const again = () => renderRules(box, code);
  const mine = proposals.filter(p => p.department_code === code);
  const items = await proposalItems(mine.filter(p => p.status === 'pending').reverse(), now);
  const past = mine.filter(p => p.status !== 'pending');
  const name = await namesByIds(past.flatMap(p => [p.proposed_by, p.decided_by]));
  const owned = key => ownersFor('policy_values', key);
  const asked = new Set(proposals.filter(p => p.status === 'pending').map(p => p.target_table + ' ' + p.target_key));
  const other = owners => `<span class="hint">${esc(owners.map(deptLabel).join(' or '))} decides this</span>`;

  const known = RULES.filter(r => r.keys.every(k => now.values[k]) && r.keys.some(k => owned(k).includes(code)));
  const rest = values.filter(v => !known.some(r => r.keys.includes(v.key)) && owned(v.key).includes(code));
  const cards = [
    ...known.map(r => {
      const v = r.keys.map(k => shown(k, now.values[k].value));
      const labels = r.buttons ? r.buttons(v) : ['Change'];
      return { html: r.say(v), btns: r.keys.map((k, i) => ({ key: k, label: labels[i], can: owned(k).some(canProposePolicyChange) })), owners: owned(r.keys[0]) };
    }),
    ...rest.map(v => ({ html: `${esc(v.label)}: ${num(v.value)}.`, btns: [{ key: v.key, label: 'Change', can: owned(v.key).some(canProposePolicyChange) }], owners: owned(v.key) })),
  ];
  const canRf = canProposePolicyChange('RF');
  const ruleRow = (text, side) => `<div class="rule"><div class="rule-text">${text}</div><div class="rule-side">${side}</div></div>`;
  const waits = '<span class="hint">&#8987; A change is waiting</span>';

  box.innerHTML = `
    ${items.length ? `<section><h3 class="dep-h">Waiting for an Admin <span class="dep-n">${items.length}</span></h3>${items.map(itemHtml).join('')}</section>` : ''}
    ${cards.length ? `<section>${cards.map(c => ruleRow(c.html, c.btns.filter(b => b.can).map(b => (asked.has('policy_values ' + b.key) ? waits : `<button type="button" class="btn secondary" data-rule="${esc(b.key)}">${esc(b.label)}</button>`)).join('') || other(c.owners))).join('')}</section>` : ''}
    ${code === 'RF' && rates.length ? `<section><h3 class="dep-h">Credits for a page</h3>${rates.map(r => ruleRow(`A page of ${esc(categoryLabel(r.category))} gives ${num(r.credits_per_page)} ${Number(r.credits_per_page) === 1 ? 'credit' : 'credits'}.`,
      !canRf ? other(['RF']) : asked.has('task_category_rates ' + r.category) ? waits : `<button type="button" class="btn secondary" data-rate="${esc(r.category)}">Change</button>`)).join('')}</section>` : ''}
    ${SEES_TIERS.includes(code) && tiers.length ? `<section><h3 class="dep-h">How each result changes the reputation</h3>${tiers.map((t, i) => ruleRow(
      `<b>${esc(t.tier_name)}</b>, ${t.max_base_credits == null ? `from ${esc(t.min_base_credits)} credits` : `from ${esc(t.min_base_credits)} to ${esc(t.max_base_credits)} credits`}: <span class="rule-deltas"><span>OK ${num(signed(t.ok_delta))}</span> <span>OK, but... ${num(signed(t.ok_but_delta))}</span> <span>Fail ${num(signed(t.fail_delta))}</span></span>`,
      !canRf ? other(['RF']) : asked.has('task_reputation_tiers ' + t.tier_name) ? waits : `<button type="button" class="btn secondary" data-tier="${i}">Change</button>`)).join('')}</section>` : ''}
    ${!cards.length && !SEES_TIERS.includes(code) ? '<div class="panel empty-msg">This department has no rules with a number.</div>' : ''}
    <details class="subpanel dep-past"><summary>Past decisions <span class="count-badge">${past.length}</span></summary>
      <p class="hint">Each proposal, with its reason and its result. Kept forever.</p>
      ${past.map(p => `<div class="dep-past-row"><div>${outcomeHtml(p.status)} <span class="hint">${esc(dayText(p.decided_at))}</span></div>
        <div>${changeHtml(p, p.target_table === 'token_texts' ? { texts: now.texts, values: {}, rates: {}, tiers: {} } : null)}</div>
        <div class="hint" dir="auto">&ldquo;${esc(p.reason)}&rdquo;</div>
        <div class="hint">Proposed by ${esc(name(p.proposed_by))}${p.status === 'withdrawn' || !p.decided_by ? '' : `, decided by ${esc(name(p.decided_by))}`}</div>
        ${p.decision_note ? `<div class="hint" dir="auto">Note: ${esc(p.decision_note)}</div>` : ''}</div>`).join('') || '<div class="empty-msg">Nothing has been decided yet.</div>'}
    </details>`;

  wireItems(box, items, again);
  box.querySelectorAll('[data-rule]').forEach(b => b.addEventListener('click', () => {
    const key = b.dataset.rule, v = now.values[key];
    openPolicyProposalModal({
      title: ruleShort(key, v.label), targetTable: 'policy_values', targetKey: key, action: 'upsert', owners: owned(key),
      fields: [{ name: 'value', label: 'New number', type: 'number', value: v.value, minus: !!ruleOf(key)?.minus }], onSaved: again,
    });
  }));
  box.querySelectorAll('[data-rate]').forEach(b => b.addEventListener('click', () => openPolicyProposalModal({
    title: `Credits for a page of ${categoryLabel(b.dataset.rate)}`, targetTable: 'task_category_rates', targetKey: b.dataset.rate, action: 'upsert',
    owners: ownersFor('task_category_rates'),
    fields: [{ name: 'credits_per_page', label: 'Credits for a page', type: 'number', value: now.rates[b.dataset.rate].credits_per_page }], onSaved: again,
  })));
  box.querySelectorAll('[data-tier]').forEach(b => b.addEventListener('click', () => {
    const t = tiers[+b.dataset.tier];
    openPolicyProposalModal({
      title: `How each result changes the reputation: ${t.tier_name}`, targetTable: 'task_reputation_tiers', targetKey: t.tier_name, action: 'upsert',
      owners: ownersFor('task_reputation_tiers'),
      fields: TIER_FIELDS.map(([n, label]) => ({ name: n, label, type: n === 'tier_name' ? 'text' : 'number', value: t[n] })), onSaved: again,
    });
  }));
}
const signed = n => (Number(n) > 0 ? '+' + n : Number(n) < 0 ? '−' + Math.abs(n) : String(n ?? 0));
