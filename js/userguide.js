// "Help" tab: a quick static English walkthrough (below), plus the fuller reference guides
// (Book of Roles, one operational guide per role, technical DB schema - in Italian and English),
// which now live in the `help_pages` table (51_help_pages.sql) instead of external Claude
// Artifacts. Admin can edit/save them in place (raw HTML source) from this same view.

import { sb, State, esc, isAdmin, withStatus } from './core.js?v=20260902002728';

let helpPagesCache = null;
const helpView = { slug: null, editing: false };

async function loadHelpPages() {
  if (helpPagesCache) return helpPagesCache;
  const { data, error } = await sb.from('help_pages').select('*').order('sort_order');
  helpPagesCache = error ? [] : (data || []);
  return helpPagesCache;
}

function guideListSection(pages, language, heading, intro, mineLabel) {
  const myRole = State.currentRole;
  const items = pages.filter(p => p.language === language).map(p => {
    const mine = p.role === myRole;
    return `<li style="margin-bottom:8px;${mine ? 'font-weight:600;' : ''}">
      <a href="#" data-help-slug="${esc(p.slug)}" class="help-link">${esc(p.title)}</a>${mine ? ` <span class="hint">(${mineLabel})</span>` : ''}
    </li>`;
  }).join('');
  return `
    <div class="panel report-view" style="max-width:820px;margin:0 auto 16px;">
      <h2>${heading}</h2>
      <p class="hint">${intro}</p>
      <ul style="padding-left:20px;">${items || '<li class="hint">(none yet)</li>'}</ul>
    </div>`;
}

export async function renderUserGuideView(main) {
  main.innerHTML = '<div class="empty-msg">Loading...</div>';
  const pages = await loadHelpPages();
  if (helpView.slug) renderHelpDetail(main, pages);
  else renderHelpList(main, pages);
}

function renderHelpList(main, pages) {
  main.innerHTML = `
    ${guideListSection(pages, 'it', 'Guide in italiano',
      'Documenti di riferimento più completi, in italiano - una guida per ogni ruolo, più la filosofia generale e lo schema tecnico del database. Clic per aprire.',
      'il tuo ruolo')}
    ${guideListSection(pages, 'en', 'Guides in English',
      'The same fuller reference documents, in English - one guide per role, plus the general philosophy and the technical database schema. Click to open.',
      'your role')}
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

  main.querySelectorAll('.help-link').forEach(a => {
    a.addEventListener('click', (e) => {
      e.preventDefault();
      helpView.slug = a.dataset.helpSlug;
      helpView.editing = false;
      renderUserGuideView(main);
    });
  });
}

function renderHelpDetail(main, pages) {
  const page = pages.find(p => p.slug === helpView.slug);
  if (!page) { helpView.slug = null; renderUserGuideView(main); return; }
  const editable = isAdmin();
  const updated = page.updated_at ? new Date(page.updated_at).toLocaleString() : '—';

  main.innerHTML = `
    <div class="panel report-view" style="max-width:1000px;margin:0 auto;">
      <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;margin-bottom:10px;">
        <button class="btn" id="help-back" type="button">&larr; Back to guides</button>
        ${editable ? `<div style="display:flex;gap:8px;">
          <button class="btn secondary" id="help-edit-toggle" type="button">${helpView.editing ? 'Cancel' : 'Edit'}</button>
          ${helpView.editing ? '<button class="btn" id="help-save" type="button">Save</button>' : ''}
        </div>` : ''}
      </div>
      ${helpView.editing
        ? `<textarea id="help-editor" spellcheck="false" style="width:100%;height:70vh;font-family:'IBM Plex Mono',monospace;font-size:12px;box-sizing:border-box;">${esc(page.html_content)}</textarea>`
        : `<iframe id="help-frame" title="${esc(page.title)}" style="width:100%;height:78vh;border:1px solid #ccc;border-radius:8px;background:#fff;" sandbox="allow-same-origin"></iframe>`
      }
      <p class="hint" style="margin-top:8px;">Last updated: ${esc(updated)}${page.updated_by_email ? ' by ' + esc(page.updated_by_email) : ''}</p>
    </div>`;

  if (!helpView.editing) {
    document.getElementById('help-frame').srcdoc = page.html_content;
  }

  document.getElementById('help-back').addEventListener('click', () => {
    helpView.slug = null; helpView.editing = false; renderUserGuideView(main);
  });

  if (editable) {
    document.getElementById('help-edit-toggle').addEventListener('click', () => {
      helpView.editing = !helpView.editing; renderUserGuideView(main);
    });
    const saveBtn = document.getElementById('help-save');
    if (saveBtn) saveBtn.addEventListener('click', async () => {
      const newHtml = document.getElementById('help-editor').value;
      const { data: { user } } = await sb.auth.getUser();
      const nowIso = new Date().toISOString();
      try {
        await withStatus(sb.from('help_pages').update({
          html_content: newHtml, updated_at: nowIso, updated_by_email: user.email,
        }).eq('slug', page.slug), 'Saving...');
      } catch (err) { alert('Save failed: ' + err.message); return; }
      page.html_content = newHtml; page.updated_at = nowIso; page.updated_by_email = user.email;
      helpView.editing = false;
      renderUserGuideView(main);
    });
  }
}

function example(title, bodyHtml) {
  return `<div class="field" style="background:var(--accent-soft);border-radius:8px;padding:10px 14px;margin:10px 0;">
    <div style="font-weight:600;margin-bottom:4px;">${title}</div>
    ${bodyHtml}
  </div>`;
}
