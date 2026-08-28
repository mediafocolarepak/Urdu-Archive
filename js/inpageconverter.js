// InPage (.inp) -> Unicode Urdu converter, plus Word/PDF generation.
// Standalone utility: works on any .inp file the user picks locally, independent of a
// document already existing in the archive (Document ID / English reference are just
// optional header text the user can fill in for a specific archive document).
//
// The core byte-decoding table below is ported from the GPLv2-licensed inPageToUnicode
// project (https://github.com/ltrc/inPageToUnicode, inPage2Unicode.js) - it parses the
// raw .inp binary directly (locates the content block via fixed byte markers, then maps
// each InPage glyph code to its Unicode Arabic/Urdu codepoint), so no InPage clipboard
// step is needed. Rewritten here as a pure function instead of relying on globals.
import { canWrite, esc, getDriveAccessToken, driveUploadOrReplace } from './core.js?v=20260827230000';

const DEFAULT_OPTIONS = {
  urdu: true,          // Urdu glyph variants (ک ی ہ ھ ں...) vs. plain Arabic ones
  hehHamza: true,       // correct heh+hamza combinations (ؤ, ۂ)
  removeKashida: false,
  reverseQuotes: false,
  reverseDigits: true,
  reverseSolidus: true,
  reverseThousands: true,
  correctBariYe: true,
  removeDoubleSpace: true,
  removeErabs: false,
  correctYearSign: true,
};

function findStartPosition(b) {
  for (let i = 0; i <= b.length - 1; i++) {
    if (b[i] === 1 && b[i + 4] === 13) {
      let marker = '';
      for (let t = 0; t <= 9; t++) marker += b[i + t];
      if (marker === '10001300000') return i + 14;
    }
  }
  return -1;
}
function findEndPosition(b, startP) {
  for (let i = startP; i <= b.length - 1; i++) {
    if (b[i + 6] === 255) {
      let marker = '';
      for (let t = 0; t <= 9; t++) marker += b[i + t];
      if (marker === '1300000255255255255') return i;
    }
  }
  return b.length;
}
function toHexPairs(bytes, start, length) {
  const hex = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
  let res = '';
  for (let i = start; i < start + length; i++) {
    const b = bytes[i];
    res += '-' + hex[(b >> 4) & 0x0f] + hex[b & 0x0f];
  }
  return res;
}

// Decodes the raw bytes of an .inp file into Unicode Urdu/Arabic text.
export function inPageBytesToUnicode(bytes, opts) {
  const o = { ...DEFAULT_OPTIONS, ...opts };
  const startP = findStartPosition(bytes);
  if (startP === -1) throw new Error('This does not look like a valid InPage (.inp) file — content marker not found.');
  const endP = findEndPosition(bytes, startP);
  let out = toHexPairs(bytes, startP, endP - startP);

  const CR = String.fromCharCode(13) + String.fromCharCode(10);
  out = out.replace(/-0D-[^-]+-[^-]+-[^-]+-[^-]+[^-]/g, CR);
  out = out.replace(/-09/g, '\t');
  out = out.replace(/-04-AA/g, 'ِ');
  out = out.replace(/-04-20/g, ' ');
  out = out.replace(/-04-81-04-B3/g, 'آ');
  out = out.replace(/-04-81-04-BF/g, 'أ');
  out = out.replace(/-04-81/g, 'ا');
  out = out.replace(/-04-82/g, 'ب');
  out = out.replace(/-04-83/g, 'پ');
  out = out.replace(/-04-84/g, 'ت');
  out = out.replace(/-04-85/g, 'ٹ');
  out = out.replace(/-04-86/g, 'ث');
  out = out.replace(/-04-87/g, 'ج');
  out = out.replace(/-04-88/g, 'چ');
  out = out.replace(/-04-89/g, 'ح');
  out = out.replace(/-04-8A/g, 'خ');
  out = out.replace(/-04-8B/g, 'د');
  out = out.replace(/-04-8C/g, 'ڈ');
  out = out.replace(/-04-8D/g, 'ذ');
  out = out.replace(/-04-8E/g, 'ر');
  out = out.replace(/-04-8F/g, 'ڑ');
  out = out.replace(/-04-90/g, 'ز');
  out = out.replace(/-04-91/g, 'ژ');
  out = out.replace(/-04-92/g, 'س');
  out = out.replace(/-04-93/g, 'ش');
  out = out.replace(/-04-94/g, 'ص');
  out = out.replace(/-04-95/g, 'ض');
  out = out.replace(/-04-96/g, 'ط');
  out = out.replace(/-04-97/g, 'ظ');
  out = out.replace(/-04-98/g, 'ع');
  out = out.replace(/-04-99/g, 'غ');
  out = out.replace(/-04-9A/g, 'ف');
  out = out.replace(/-04-9B/g, 'ق');
  out = out.replace(/-04-9C/g, o.urdu ? 'ک' : 'ك');
  out = out.replace(/-04-9D/g, 'گ');
  out = out.replace(/-04-9E/g, 'ل');
  out = out.replace(/-04-9F/g, 'م');
  out = out.replace(/-04-A0/g, 'ن');
  out = out.replace(/-04-A1/g, 'ں');
  if (o.hehHamza) {
    out = out.replace(/-04-A3-04-A2/g, 'ؤ');
    out = out.replace(/-04-BF-04-A2/g, 'ؤ');
  } else {
    out = out.replace(/-04-A3-04-A2/g, 'ئو');
  }
  out = out.replace(/-04-A2-04-BF/g, 'ؤ');
  if (o.urdu) {
    if (o.hehHamza) {
      out = out.replace(/-04-BF-04-A6/g, 'ۂ');
      out = out.replace(/-04-A3-04-A6/g, 'ۂ');
    }
    out = out.replace(/-04-A6-04-BF/g, 'ۂ');
  } else {
    out = out.replace(/-04-A6-04-BF/g, 'ۀ');
  }
  out = out.replace(/-04-A3-04-A6/g, 'ئہ');
  out = out.replace(/-04-A2/g, 'و');
  out = out.replace(/-04-A3/g, 'ء');
  out = out.replace(/-04-A4-04-BF/g, 'ئ');
  out = out.replace(/-04-A4/g, o.urdu ? 'ی' : 'ي');
  out = out.replace(/-04-A5/g, 'ے');
  out = out.replace(/-04-A6/g, o.urdu ? 'ہ' : 'ه');
  out = out.replace(/-04-A7/g, o.urdu ? 'ھ' : 'ه');
  out = out.replace(/-04-A8/g, 'ٍ');
  out = out.replace(/-04-A9/g, o.removeKashida ? '' : 'ـ');
  out = out.replace(/-04-AA/g, 'ِ');
  out = out.replace(/-04-AB/g, 'َ');
  out = out.replace(/-04-AC/g, 'ُ');
  out = out.replace(/-04-AD/g, 'ّ');
  out = out.replace(/-04-AE/g, 'ؑ');
  out = out.replace(/-04-B0/g, 'ٖ');
  out = out.replace(/-04-B1-04-B1/g, 'ْ');
  out = out.replace(/-04-B1/g, 'ْ');
  out = out.replace(/-04-B3/g, 'ٓ');
  out = out.replace(/-04-B4/g, 'ْ');
  out = out.replace(/-04-B5/g, 'ٌ');
  out = out.replace(/-04-B6/g, 'ؤ');
  out = out.replace(/-04-B7/g, 'ئ');
  out = out.replace(/-04-B8/g, 'ي');
  out = out.replace(/-04-B9/g, o.urdu ? 'ۃ' : 'ة');
  out = out.replace(/-04-BD/g, 'ٰ');
  out = out.replace(/-04-BE/g, 'ٗ');
  out = out.replace(/-04-BF/g, 'ٔ');
  out = out.replace(/-04-C7/g, 'ً');
  out = out.replace(/-04-C8/g, 'آ');
  out = out.replace(/-04-C9/g, 'أ');
  out = out.replace(/-04-CA/g, 'إ');
  out = out.replace(/-04-CB/g, 'ﷲ');
  out = out.replace(/-04-CF/g, 'ؔ');
  const digits = o.urdu ? ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'] : ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (let d = 0; d <= 9; d++) out = out.replace(new RegExp(`-04-${(0xD0 + d).toString(16).toUpperCase()}`, 'g'), digits[d]);
  out = out.replace(/-04-DA/g, '!');
  out = out.replace(/-04-DB/g, '﴾');
  out = out.replace(/-04-DC/g, '﴿');
  out = out.replace(/-04-DE/g, '%');
  out = out.replace(/-04-DF/g, '/');
  out = out.replace(/-04-E0/g, '……');
  out = out.replace(/-04-E1/g, ')');
  out = out.replace(/-04-E2/g, '(');
  out = out.replace(/-04-E4/g, '+');
  out = out.replace(/-04-E6/g, 'ؓ');
  out = out.replace(/-04-E7/g, 'ؒ');
  out = out.replace(/-04-E8/g, '٭');
  out = out.replace(/-04-E9/g, ':');
  out = out.replace(/-04-EA/g, '؛');
  out = out.replace(/-04-EB/g, '×');
  out = out.replace(/-04-EC/g, '=');
  out = out.replace(/-04-ED/g, '،');
  out = out.replace(/-04-EE/g, '؟');
  out = out.replace(/-04-EF/g, '÷');
  out = out.replace(/-04-F1/g, '؍');
  out = out.replace(/-04-F2/g, '؂');
  out = out.replace(/-04-F3/g, o.urdu ? '۔' : '.');
  out = out.replace(/-04-F5/g, '-');
  out = out.replace(/-04-F6/g, 'ﷺ');
  out = out.replace(/-04-F7/g, '؁');
  out = out.replace(/-04-F8/g, 'ؐ');
  out = out.replace(/-04-F9/g, ',');
  out = out.replace(/-04-FA/g, ']');
  out = out.replace(/-04-FB/g, '[');
  out = out.replace(/-04-FC/g, '.');
  if (o.reverseQuotes) {
    out = out.replace(/-04-FE/g, '’');
    out = out.replace(/-04-FD/g, '‘');
  } else {
    out = out.replace(/-04-FD/g, '’');
    out = out.replace(/-04-FE/g, '‘');
  }
  out = out.replace(/-04-3A/g, '');
  out = out.replace(/-04-3B/g, '');
  out = out.replace(/-09/g, '\t');

  // Remaining single-byte ASCII range (punctuation, digits, Latin letters).
  const ascii = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
  for (let c = 0x20; c <= 0x7E; c++) {
    const ch = ascii[c - 0x20];
    if (ch !== undefined) out = out.replace(new RegExp(`-${c.toString(16).toUpperCase().padStart(2, '0')}`, 'g'), ch);
  }

  const regUrduAlfabat = '([ابپتٹثجچحخدڈذرڑزژسشصضطظعغفقکكگلمنوئیےؤهۀةأـآيھإہۃں])';
  const regAhrab = '([ًٌٍَُِّٰٖٗ])';
  if (o.reverseDigits) {
    const digitClass = o.urdu ? '[۰۱۲۳۴۵۶۷۸۹]' : '[٠١٢٣٤٥٦٧٨٩]';
    const fullRe = new RegExp(digitClass + (o.reverseThousands ? `[${o.urdu ? '۰۱۲۳۴۵۶۷۸۹' : '٠١٢٣٤٥٦٧٨٩'}/+×÷%,]+` : `${digitClass}+`), 'g');
    out = out.replace(fullRe, (m) => {
      if (o.reverseThousands && o.reverseSolidus && m.endsWith('/')) return m.slice(0, -1).split('').reverse().join('') + '/';
      return m.split('').reverse().join('');
    });
  }
  out = out.replace(/(\/)(=)/g, '$2$1');
  out = out.replace(new RegExp('(ں)' + regUrduAlfabat, 'g'), '$1 $2');
  out = out.replace(/(ﺀ)(ﺀ)/g, 'ئ$2');
  out = out.replace(new RegExp('(ء)' + regUrduAlfabat, 'g'), 'ئ$2');
  out = out.replace(new RegExp('(ء)' + regAhrab + regUrduAlfabat, 'g'), 'ئ$2$3');
  if (o.correctBariYe) out = out.replace(new RegExp('(ے)' + regUrduAlfabat, 'g'), 'ی$2');
  if (o.urdu) out = out.replace(new RegExp('(ي)' + regUrduAlfabat, 'g'), '$1 $2');
  if (o.removeDoubleSpace) out = out.replace(/[ ]+[ ]/g, ' ');
  if (o.removeErabs) out = out.replace(new RegExp('[ ' + regAhrab.slice(1, -1) + ']', 'g'), '');
  if (o.correctYearSign) {
    out = out.replace(/(ھ)(؁)/g, '$2$1');
    out = out.replace(/(ء)(؁)/g, '$2$1');
  }
  return out;
}

export async function inPageFileToUnicode(file, opts) {
  const buf = await file.arrayBuffer();
  const bytes = new Uint8Array(buf);
  return inPageBytesToUnicode(bytes, opts);
}

// ---------- Word (.docx) generation ----------

let docxLibPromise = null;
function loadDocxLib() {
  if (window.docx) return Promise.resolve(window.docx);
  if (!docxLibPromise) {
    docxLibPromise = new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = 'https://cdn.jsdelivr.net/npm/docx@9.7.1/dist/index.umd.cjs';
      s.onload = () => resolve(window.docx);
      s.onerror = () => reject(new Error('Could not load the Word-generation library.'));
      document.head.appendChild(s);
    });
  }
  return docxLibPromise;
}

const URDU_FONT = 'Jameel Noori Nastaleeq';

// header: { documentId, englishRef } - both optional, shown as plain left-aligned lines
// before the Urdu body. urduText is split into paragraphs on blank lines, each rendered
// right-aligned/RTL, matching the layout already used for Word of Life bulletins.
export async function buildDocxBlob(urduText, header) {
  const docx = await loadDocxLib();
  const { Document, Packer, Paragraph, TextRun, AlignmentType } = docx;
  const headerParas = [];
  if (header?.documentId) headerParas.push(new Paragraph({ children: [new TextRun({ text: `Document ID: ${header.documentId}`, bold: true })] }));
  if (header?.englishRef) headerParas.push(new Paragraph({ children: [new TextRun({ text: header.englishRef, bold: true })] }));
  headerParas.push(new Paragraph({ text: '' }));

  const bodyParas = urduText.split(/\n{2,}/).map(para => new Paragraph({
    alignment: AlignmentType.RIGHT,
    bidirectional: true,
    children: [new TextRun({ text: para.trim(), font: URDU_FONT, rightToLeft: true })],
  }));

  const doc = new Document({ sections: [{ children: [...headerParas, ...bodyParas] }] });
  return Packer.toBlob(doc);
}

export function downloadBlob(blob, fileName) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = fileName;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 5000);
}

// ---------- PDF (via browser print) ----------
// Nastaliq shaping is hard to reproduce reliably from scratch client-side; the browser's own
// text engine already does it correctly if the font is installed locally (same font the
// operators already use in InPage/Word), so we render a print-ready page and let the user
// "Save as PDF" from the native print dialog rather than generating the PDF bytes ourselves.
export function openPrintPreview(urduText, header) {
  const w = window.open('', '_blank');
  if (!w) { alert('Please allow pop-ups to generate the PDF preview.'); return; }
  const paras = urduText.split(/\n{2,}/).map(p => `<p>${esc(p.trim()).replace(/\n/g, '<br>')}</p>`).join('\n');
  w.document.write(`<!doctype html><html><head><meta charset="utf-8"><title>${esc(header?.documentId ? `Document ${header.documentId}` : 'InPage Conversion')}</title>
  <style>
    @page { margin: 2cm; }
    body { font-family: "${URDU_FONT}", "Noto Nastaliq Urdu", "Segoe UI", serif; }
    .header { font-family: Arial, sans-serif; font-weight: bold; margin-bottom: 1em; }
    .body p { direction: rtl; text-align: right; unicode-bidi: plaintext; font-size: 18pt; line-height: 2; margin: 0 0 1em; }
  </style></head><body>
  <div class="header">${header?.documentId ? esc(`Document ID: ${header.documentId}`) + '<br>' : ''}${header?.englishRef ? esc(header.englishRef) : ''}</div>
  <div class="body">${paras}</div>
  <script>window.onload = () => window.print();</script>
  </body></html>`);
  w.document.close();
}

// ---------- Google Drive upload ----------

// Accepts either a bare folder ID or a full "https://drive.google.com/drive/folders/<id>..."
// link, since that's what people normally copy out of Drive's own address bar/share menu.
export function parseDriveFolderId(input) {
  const s = (input || '').trim();
  const m = s.match(/\/folders\/([a-zA-Z0-9_-]+)/);
  return m ? m[1] : s;
}

export async function uploadFilesToDrive(folderId, files) {
  const token = await getDriveAccessToken();
  const results = [];
  for (const f of files) {
    if (!f.blob) continue;
    await driveUploadOrReplace(folderId, f.name, f.blob, token);
    results.push(f.name);
  }
  return results;
}

// ---------- UI ----------

export async function renderInPageConverterView(main) {
  if (!canWrite()) { main.innerHTML = '<div class="empty-msg">Not available for your role.</div>'; return; }
  main.innerHTML = `
    <div class="panel">
      <h2>InPage Converter</h2>
      <p class="hint">Converts any InPage (.inp) file to Unicode Urdu text, then to Word and/or a print-ready PDF. Works standalone — no document needs to exist in the archive yet.</p>
      <div class="field"><label>InPage file (.inp)</label><input type="file" id="ipc-file" accept=".inp"></div>
      <div class="field"><label>Document ID (optional)</label><input type="text" id="ipc-docid" placeholder="e.g. 1234"></div>
      <div class="field"><label>English reference (optional)</label><input type="text" id="ipc-englishref" placeholder="e.g. Word of Life September 2026 &quot;...&quot; (John 13:34)"></div>
      <div class="btn-row">
        <button class="btn" id="ipc-convert">Convert</button>
      </div>
      <div class="field" style="margin-top:14px;">
        <label>Converted text (editable — review before generating Word/PDF)</label>
        <textarea id="ipc-preview" rows="16" dir="rtl" style="font-size:16px;"></textarea>
      </div>
      <div class="btn-row">
        <button class="btn secondary" id="ipc-word" disabled>Download Word (.docx)</button>
        <button class="btn secondary" id="ipc-pdf" disabled>Generate PDF (print)</button>
      </div>
      <div class="field" style="margin-top:14px;">
        <label>Google Drive folder (link or ID) — optional, to upload/overwrite files there</label>
        <input type="text" id="ipc-drive-folder" placeholder="https://drive.google.com/drive/folders/...">
      </div>
      <div class="btn-row">
        <button class="btn secondary" id="ipc-drive-upload" disabled>Update files on Drive</button>
      </div>
      <p class="hint">Uploads the original .inp and the generated .docx, overwriting any existing file with the same name in that folder. The PDF is not uploaded automatically — save it from the print dialog (Generate PDF above) into the same folder yourself.</p>
      <div class="hint" id="ipc-drive-status"></div>
    </div>`;

  const fileInput = document.getElementById('ipc-file');
  const preview = document.getElementById('ipc-preview');
  const wordBtn = document.getElementById('ipc-word');
  const pdfBtn = document.getElementById('ipc-pdf');
  const driveBtn = document.getElementById('ipc-drive-upload');
  const driveStatus = document.getElementById('ipc-drive-status');
  let lastDocxBlob = null;

  function currentHeader() {
    return {
      documentId: document.getElementById('ipc-docid').value.trim(),
      englishRef: document.getElementById('ipc-englishref').value.trim(),
    };
  }

  document.getElementById('ipc-convert').addEventListener('click', async () => {
    const file = fileInput.files[0];
    if (!file) { alert('Choose an .inp file first.'); return; }
    try {
      const text = await inPageFileToUnicode(file);
      preview.value = text;
      wordBtn.disabled = false;
      pdfBtn.disabled = false;
      lastDocxBlob = null;
      driveBtn.disabled = !document.getElementById('ipc-drive-folder').value.trim();
      driveStatus.textContent = '';
    } catch (e) {
      alert('Conversion failed: ' + e.message);
    }
  });

  document.getElementById('ipc-drive-folder').addEventListener('input', e => {
    driveBtn.disabled = !e.target.value.trim() || !preview.value.trim();
  });

  wordBtn.addEventListener('click', async () => {
    if (!preview.value.trim()) return;
    wordBtn.disabled = true;
    try {
      lastDocxBlob = await buildDocxBlob(preview.value, currentHeader());
      const id = currentHeader().documentId;
      downloadBlob(lastDocxBlob, (id ? `${id}-` : '') + 'converted.docx');
    } catch (e) {
      alert('Could not generate the Word file: ' + e.message);
    } finally {
      wordBtn.disabled = false;
    }
  });

  pdfBtn.addEventListener('click', () => {
    if (!preview.value.trim()) return;
    openPrintPreview(preview.value, currentHeader());
  });

  driveBtn.addEventListener('click', async () => {
    const folderId = parseDriveFolderId(document.getElementById('ipc-drive-folder').value);
    if (!folderId) return;
    driveBtn.disabled = true;
    driveStatus.textContent = 'Connecting to Google Drive…';
    try {
      if (!lastDocxBlob) lastDocxBlob = await buildDocxBlob(preview.value, currentHeader());
      const file = fileInput.files[0];
      const uploaded = await uploadFilesToDrive(folderId, [
        file ? { name: file.name, blob: file } : null,
        { name: (currentHeader().documentId ? `${currentHeader().documentId}-` : '') + 'converted.docx', blob: lastDocxBlob },
      ].filter(Boolean));
      driveStatus.textContent = 'Updated on Drive: ' + uploaded.join(', ');
    } catch (e) {
      driveStatus.textContent = 'Drive upload failed: ' + e.message;
    } finally {
      driveBtn.disabled = false;
    }
  });
}
