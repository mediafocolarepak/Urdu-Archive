// The document beside the work (Owner's decision, 2026-11-25): the PDF, the text and the file of a task are seen inside the
// app, on a computer next to the steps, on a phone on the whole screen. Used by the task desk and by the review (tasks.js).
// PDFs are drawn with pdf.js, Word files are read with mammoth and InPage files with the converter: nothing leaves the app.

import { sb, esc, BUCKET, withStatus, loadLibrary, loadPdfJs, fetchDriveFile, textDir, errorText } from './core.js?v=20261127123527';
import { inPageBytesToUnicode } from './inpageconverter.js?v=20261127123527';

const ending = name => ((String(name || '').match(/\.([a-z0-9]+)$/i) || [])[1] || '').toLowerCase();

async function storageBlob(path) {
  const { data } = await sb.storage.from(BUCKET).createSignedUrl(path, 120);
  if (!data?.signedUrl) return null;
  const res = await fetch(data.signedUrl);
  return res.ok ? res.blob() : null;
}

// What a file shows here: { pdf: Blob }, { text } or { none: why }.
async function contentOf(blob, name) {
  if (!blob) return { none: 'This file could not be opened.' };
  const kind = ending(name);
  if (kind === 'pdf') return { pdf: blob };
  if (kind === 'docx') {
    const reader = await loadLibrary('mammoth', 'Could not load the Word reader. Please check the connection and try again.');
    const { value } = await reader.extractRawText({ arrayBuffer: await blob.arrayBuffer() });
    return value.trim() ? { text: value.replace(/\n{3,}/g, '\n\n').trim() } : { none: 'There is no text in this file.' };
  }
  if (kind === 'inp') return { text: inPageBytesToUnicode(new Uint8Array(await blob.arrayBuffer())).replace(/\r\n/g, '\n').trim() };
  return { none: 'This kind of file cannot be shown here. You can download it.' };
}

// A document of the archive: its PDF (the app's own copy, or Drive's) and its text.
export async function documentSources(documentId) {
  if (!documentId) return [];
  const [docs, texts, originals] = await Promise.all([
    withStatus(sb.from('documents').select('document_id,language,media_type,file_name,storage_path').eq('document_id', documentId)),
    withStatus(sb.from('document_texts').select('body').eq('document_id', documentId)),
    sb.from('document_original_texts').select('body,language').eq('document_id', documentId).then(r => r.data || [], () => []),
  ]);
  const doc = docs[0];
  if (!doc) return [];
  const out = [];
  const pdfName = doc.storage_path || doc.file_name;
  if (pdfName) out.push({ key: 'pdf', label: 'PDF', load: async () => contentOf((doc.storage_path && await storageBlob(doc.storage_path)) || (doc.file_name && await fetchDriveFile(doc.file_name)) || null, ending(pdfName) ? pdfName : pdfName + '.pdf') });
  if (texts[0]?.body) out.push({ key: 'text', label: 'Text', load: async () => ({ text: texts[0].body, language: doc.language }) });
  if (originals[0]?.body) out.push({ key: 'original', label: 'First language', load: async () => ({ text: originals[0].body, language: originals[0].language }) });
  return out;
}

// A file of a task (archive-files). path may be a function, asked each time, because the file can be replaced.
export function fileSource(key, label, path) {
  return { key, label, fresh: true, load: async () => { const p = typeof path === 'function' ? await path() : path; return p ? contentOf(await storageBlob(p), p) : { none: 'There is no file yet.' }; } };
}

const ZOOMS = [0.6, 0.8, 1, 1.25, 1.5, 2, 2.6];

// The pane: what can be seen on top, the content below. Returns { show(key), keys, refresh() }.
export function documentPane(box, sources, { onClose = null } = {}) {
  let zoom = Number(localStorage.getItem('deskZoom')) || 1, current = null, turn = 0, stopDrawing = () => {};
  const cache = {};
  box.classList.add('desk-pane');
  box.innerHTML = `
    <div class="desk-tabs" role="tablist" aria-label="What to look at">
      ${onClose ? '<button type="button" class="btn secondary desk-close">&lsaquo; Back</button>' : ''}
      ${sources.map(s => `<button type="button" class="desk-tab" role="tab" data-key="${esc(s.key)}" aria-selected="false">${esc(s.label)}</button>`).join('')}
      <span class="desk-space"></span>
      <button type="button" class="desk-tool" data-zoom="-1" aria-label="Smaller">&minus;</button>
      <button type="button" class="desk-tool" data-zoom="1" aria-label="Larger">+</button>
      ${onClose ? '' : '<button type="button" class="desk-tool desk-full" aria-label="Full screen" aria-pressed="false">&#10530;</button>'}
    </div>
    <div class="desk-page" tabindex="0" role="tabpanel" aria-live="polite"></div>`;
  const page = box.querySelector('.desk-page');
  const message = text => { page.innerHTML = `<div class="desk-message">${text}</div>`; };

  async function drawPdf(blob, mine) {
    const pdfjs = await loadPdfJs();
    const pdf = await pdfjs.getDocument({ data: await blob.arrayBuffer(), isEvalSupported: false }).promise;
    if (mine !== turn) return;
    const first = await pdf.getPage(1);
    const width = Math.max(240, Math.min(page.clientWidth - 24, 980)) * zoom;
    page.innerHTML = '';
    const sheets = [];
    for (let n = 1; n <= pdf.numPages; n++) {
      const sheet = document.createElement('div');
      const v = first.getViewport({ scale: 1 });
      sheet.className = 'desk-sheet';
      sheet.dataset.n = n;
      sheet.style.width = width + 'px';
      sheet.style.height = Math.round(width * v.height / v.width) + 'px';
      sheet.setAttribute('aria-label', `Page ${n} of ${pdf.numPages}`);
      page.appendChild(sheet);
      sheets.push(sheet);
    }
    // Only the pages in sight are drawn, so a long PDF does not fill the memory of a phone.
    const watch = new IntersectionObserver(entries => entries.forEach(async e => {
      const sheet = e.target;
      if (!e.isIntersecting) { if (sheet.dataset.drawn) { sheet.innerHTML = ''; delete sheet.dataset.drawn; } return; }
      if (sheet.dataset.drawn) return;
      sheet.dataset.drawn = '1';
      const p = await pdf.getPage(Number(sheet.dataset.n));
      const base = p.getViewport({ scale: 1 }), ratio = Math.min(window.devicePixelRatio || 1, 2);
      const view = p.getViewport({ scale: (width / base.width) * ratio });
      sheet.style.height = Math.round(width * base.height / base.width) + 'px';
      const canvas = document.createElement('canvas');
      canvas.width = view.width; canvas.height = view.height;
      await p.render({ canvasContext: canvas.getContext('2d'), viewport: view }).promise.catch(() => {});
      if (sheet.dataset.drawn && sheet.isConnected) { sheet.innerHTML = ''; sheet.appendChild(canvas); }
    }), { root: page, rootMargin: '600px 0px' });
    sheets.forEach(s => watch.observe(s));
    stopDrawing = () => { watch.disconnect(); pdf.destroy(); };
  }

  async function show(key) {
    const source = sources.find(s => s.key === key) || sources[0];
    if (!source) { message('There is nothing to look at for this task.'); return; }
    const mine = ++turn, again = current === source.key, top = page.scrollTop / (page.scrollHeight || 1);
    current = source.key;
    stopDrawing(); stopDrawing = () => {};
    box.querySelectorAll('.desk-tab').forEach(b => b.setAttribute('aria-selected', String(b.dataset.key === current)));
    if (!cache[current]) message('Opening...');
    try {
      const found = cache[current] || await source.load();
      if (mine !== turn) return;
      if (!found.none) cache[current] = found;
      if (found.none) { message(esc(found.none)); return; }
      if (found.pdf) await drawPdf(found.pdf, mine);
      else {
        const dir = textDir(found.text, found.language);
        page.innerHTML = `<div class="desk-text${dir === 'rtl' ? ' desk-ur' : ''}" dir="${dir}" ${dir === 'rtl' ? 'lang="ur"' : ''} style="--desk-zoom:${zoom};"></div>`;
        page.firstElementChild.textContent = found.text;
      }
      page.scrollTop = again ? top * page.scrollHeight : 0;
    } catch (e) {
      if (mine !== turn) return;
      console.warn('Document beside the work:', e);
      message(`<p>${esc(errorText(e))}</p><button type="button" class="btn secondary desk-again">Try again</button>`);
      page.querySelector('.desk-again').addEventListener('click', () => show(key));
    }
  }

  box.querySelectorAll('.desk-tab').forEach(b => b.addEventListener('click', () => show(b.dataset.key)));
  box.querySelectorAll('[data-zoom]').forEach(b => b.addEventListener('click', () => {
    const i = ZOOMS.reduce((best, z, n) => (Math.abs(z - zoom) < Math.abs(ZOOMS[best] - zoom) ? n : best), 0);
    zoom = ZOOMS[Math.max(0, Math.min(ZOOMS.length - 1, i + Number(b.dataset.zoom)))];
    try { localStorage.setItem('deskZoom', String(zoom)); } catch { /* this time only */ }
    if (current) show(current);
  }));
  box.querySelector('.desk-close')?.addEventListener('click', () => onClose());
  const full = box.querySelector('.desk-full');
  const setFull = on => { box.classList.toggle('desk-is-full', on); full.setAttribute('aria-pressed', String(on)); full.setAttribute('aria-label', on ? 'Close the full screen' : 'Full screen'); if (current) show(current); };
  full?.addEventListener('click', () => setFull(!box.classList.contains('desk-is-full')));
  box.addEventListener('keydown', e => { if (e.key === 'Escape' && box.classList.contains('desk-is-full')) { e.stopPropagation(); setFull(false); } });
  let lastWidth = 0, timer = null;
  new ResizeObserver(([entry]) => {
    const w = Math.round(entry.contentRect.width);
    if (!page.isConnected || !w || Math.abs(w - lastWidth) < 24) return;
    const first = !lastWidth;
    lastWidth = w;
    if (first || !current || !cache[current]?.pdf) return;
    clearTimeout(timer);
    timer = setTimeout(() => show(current), 250);
  }).observe(page);

  return { show, keys: sources.map(s => s.key), refresh: key => { delete cache[key]; if (current === key) show(key); } };
}

// On a phone, and before taking a task: the document on the whole screen. Back, or the phone's own Back, closes it.
export function openDocument(sources, key) {
  const back = document.createElement('div');
  back.className = 'desk-overlay';
  back.innerHTML = '<div class="desk-overlay-in" role="dialog" aria-modal="true" aria-label="Document" tabindex="-1"></div>';
  document.body.appendChild(back);
  const before = document.activeElement;
  const onPop = () => close(false);
  const close = byButton => {
    window.removeEventListener('popstate', onPop);
    back.remove();
    if (before && before.isConnected) before.focus();
    if (byButton && history.state && history.state.desk) history.back();
  };
  history.pushState({ desk: true }, '');
  window.addEventListener('popstate', onPop);
  back.addEventListener('keydown', e => { if (e.key === 'Escape') { e.stopPropagation(); close(true); } });
  const pane = documentPane(back.firstElementChild, sources, { onClose: () => close(true) });
  back.firstElementChild.focus();
  pane.show(key || (sources[0] && sources[0].key));
}

// The line between the document and the work: dragged with the mouse, or moved with the arrows. Remembered on this device.
export function wireSplit(desk) {
  const bar = desk.querySelector('.desk-split');
  if (!bar) return;
  const set = (pct, keep) => {
    const p = Math.max(25, Math.min(72, pct));
    desk.style.setProperty('--desk-left', p + '%');
    bar.setAttribute('aria-valuenow', String(Math.round(p)));
    if (keep) { try { localStorage.setItem('deskLeft', String(Math.round(p))); } catch { /* this time only */ } }
  };
  set(Number(localStorage.getItem('deskLeft')) || 56);
  bar.addEventListener('pointerdown', e => {
    bar.setPointerCapture(e.pointerId);
    const box = desk.getBoundingClientRect();
    const move = ev => set((ev.clientX - box.left) / box.width * 100);
    const up = ev => { move(ev); set((ev.clientX - box.left) / box.width * 100, true); bar.removeEventListener('pointermove', move); bar.removeEventListener('pointerup', up); };
    bar.addEventListener('pointermove', move);
    bar.addEventListener('pointerup', up);
  });
  bar.addEventListener('keydown', e => {
    const d = { ArrowLeft: -4, ArrowRight: 4 }[e.key];
    if (!d) return;
    e.preventDefault();
    set(Number(bar.getAttribute('aria-valuenow')) + d, true);
  });
}
