// Static, self-contained user guide shown in the "Help" tab. Plain content, no data fetching -
// written for the plain User role's read-only workflow (search, browse, download); Operators/
// Admins have extra tabs (Match Review, Bulk Import, Edit Records, etc.) not covered here.
// The Italian guides (below, "Guide in italiano") are separate, editable-in-place documents
// (published Claude Artifacts, one per role + one philosophy overview + one technical
// reference) - this in-app tab stays the quick English reference, those are the fuller read.

import { State } from './core.js?v=20260831172011';

const IT_GUIDES = [
  { role: null, title: 'Il Libro dei Ruoli', desc: 'filosofia, ruoli, ciclo dei task, crediti e reputazione', url: 'https://claude.ai/code/artifact/91ff6ec9-60ef-4e45-baa1-d5ab2dc8a308' },
  { role: 'user', title: 'Guida Operativa — User', desc: 'consultare l\'archivio, segnalazioni, candidarsi al team', url: 'https://claude.ai/code/artifact/0d8b970a-3dd8-4012-913b-8194db7ab993' },
  { role: 'operator', title: 'Guida Operativa — Operator', desc: 'prendere un task, correggere un documento, qualifiche, punteggio', url: 'https://claude.ai/code/artifact/401867d1-4482-4e46-8f74-2a2550ab02de' },
  { role: 'coordinator', title: 'Guida Operativa — Coordinator', desc: 'creare task, gestire la squadra, messaggi, candidature', url: 'https://claude.ai/code/artifact/4fcb12ae-79fd-4e48-ab34-f6c6c54e0b5e' },
  { role: 'admin', title: 'Guida Operativa — Admin', desc: 'utenti, opzioni, decisione finale sui task, pubblicazione documenti', url: 'https://claude.ai/code/artifact/74c43b41-c3d6-49aa-90ff-fe2fa98295da' },
  { role: null, title: 'Schema e Meccanismi del Database', desc: 'riferimento tecnico: tabelle, RLS, funzioni RPC (per chi sviluppa/mantiene l\'app)', url: 'https://claude.ai/code/artifact/e5b1a9a8-35ee-42ee-bb5e-4e3161c4bb7c' },
];

function italianGuidesSection() {
  const myRole = State.currentRole;
  const items = IT_GUIDES.map(g => {
    const mine = g.role === myRole;
    return `<li style="margin-bottom:8px;${mine ? 'font-weight:600;' : ''}">
      <a href="${g.url}" target="_blank" rel="noopener">${g.title}</a>${mine ? ' <span class="hint">(il tuo ruolo)</span>' : ''}
      <div class="hint" style="margin-top:2px;">${g.desc}</div>
    </li>`;
  }).join('');
  return `
    <div class="panel report-view" style="max-width:820px;margin:0 auto 16px;">
      <h2>Guide in italiano</h2>
      <p class="hint">Documenti di riferimento più completi, in italiano - una guida per ogni ruolo, più la filosofia generale e lo schema tecnico del database. Si aprono in una nuova scheda.</p>
      <ul style="padding-left:20px;">${items}</ul>
    </div>`;
}

export function renderUserGuideView(main) {
  main.innerHTML = `
    ${italianGuidesSection()}
    <div class="panel report-view" style="max-width:820px;margin:0 auto;">
      <h2>User Guide</h2>
      <p class="hint">A short guide to finding and downloading documents in the Focolare Urdu Archive.</p>

      <h3>1. The Dashboard</h3>
      <p>When you sign in, you land on the <b>Dashboard</b>. It has two parts: a list of documents on the left, and a detail panel on the right that shows whichever document you click.</p>
      <p>By default the list is already filtered to <b>Language = Urdu</b>, since that is what most Users need. You can change this in the Language filter if you want to see documents in another language.</p>

      ${example('Example: browsing everything in Urdu', `
        <ol>
          <li>Open the <b>Dashboard</b> tab.</li>
          <li>Leave all filters empty - Language is already set to Urdu.</li>
          <li>Scroll the list on the left and click any row to see it on the right.</li>
        </ol>`)}

      <h3>2. Searching</h3>
      <p>The search box at the top ("Search by title or tags...") looks for your text inside the <b>Title</b>, the <b>Original title</b>, and the <b>Tags</b> of every document, so you don't need to know which field it was catalogued under.</p>
      <p>Below the search box you also have a dedicated <b>ID #</b> box, if you already know the document number.</p>

      ${example('Example: find a document by keyword', `
        <ol>
          <li>Type <code>Mariapoli</code> in the search box.</li>
          <li>The list on the left updates automatically to every document whose title, original title or tags contain "Mariapoli".</li>
        </ol>`)}

      ${example('Example: jump straight to a known ID', `
        <ol>
          <li>Type <code>245</code> in the <b>ID #</b> box.</li>
          <li>Only document #245 appears in the list. Click it to open it.</li>
        </ol>`)}

      <h3>3. Filters</h3>
      <p>Above the list you can narrow things down further with: <b>Category</b>, <b>Author</b>, <b>Main topic</b>, <b>Recipient</b>, <b>Collection</b>, and <b>Language</b>. You can combine several filters at once - the list only shows documents that match all of them.</p>

      ${example('Example: everything for Gen 4 in Urdu', `
        <ol>
          <li>Set <b>Recipient</b> to "Gen 4".</li>
          <li>Leave Language on Urdu (the default).</li>
          <li>The list now shows only Urdu documents addressed to Gen 4.</li>
        </ol>`)}

      <p class="hint">To go back to the full list, set any filter you changed back to the blank option at the top of its dropdown, or clear the search box.</p>

      <h3>4. Reading a document's details</h3>
      <p>Clicking a row opens its details on the right: the title, category, author, main topic, place, reference date, tags, language, recipient(s) and any collections it belongs to. If a document has no English title yet, you will see <i>(no title)</i> instead - the original title is still shown in the summary below it.</p>
      <p>If the same document exists in other languages or as a video/audio version, they are listed under <b>Other versions of this document</b> - click any of them to switch to that version.</p>

      <h3>5. Downloading a document</h3>
      <p>At the top of the detail panel, next to the document number, there is a <b>Download Document</b> button. Click it to get the file.</p>
      <p>If the document has more than one version (for example, an Urdu translation and the original Italian), a row of buttons appears above the details - one download button per version - so you can grab the exact one you need without hunting for it.</p>

      ${example('Example: download the Urdu version of a document', `
        <ol>
          <li>Find the document using search or filters.</li>
          <li>Click it to open its details.</li>
          <li>If you see several "Download ..." buttons at the top, pick the one labelled Urdu.</li>
          <li>Otherwise, just click the single <b>Download Document</b> button next to the document number.</li>
        </ol>`)}

      <h3>6. Print Reports</h3>
      <p>The <b>Print Reports</b> tab lets you build a printable list of documents matching a set of filters (Category, Main topic, Author, Recipient, Workflow status, Collection, Source, and a date range). Set the filters you want, click <b>Generate</b>, then <b>Print / Export PDF</b>.</p>

      <h3>7. Hayat Index</h3>
      <p>The <b>Hayat Index</b> tab is a searchable list of everything published in the Hayat magazine, independent of whether it has already been catalogued as a document. Use the search box there to look up an author, title or topic.</p>

      <h3>Quick tips</h3>
      <ul>
        <li>Search and filters work together - use search for a keyword, filters to narrow by category, author, etc.</li>
        <li>Click any column header in the list (ID, Title, Author...) to sort by it; click again to reverse the order.</li>
        <li><i>(no title)</i> means an English title hasn't been added yet for that document - it can still be found by its original title.</li>
        <li>Everything in this app is read-only for your account - if something looks wrong (a wrong title, a missing file), let an Operator or Admin know.</li>
      </ul>
    </div>`;
}

function example(title, bodyHtml) {
  return `<div class="field" style="background:var(--accent-soft);border-radius:8px;padding:10px 14px;margin:10px 0;">
    <div style="font-weight:600;margin-bottom:4px;">${title}</div>
    ${bodyHtml}
  </div>`;
}
