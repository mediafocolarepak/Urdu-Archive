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
import { sb, canWrite, isAdmin, esc, withStatus, getDriveAccessToken, driveUploadOrReplace } from './core.js?v=20260910235125';

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

// Returns the raw offset of the marker itself (not +14) so it can also be used to look
// for a SECOND occurrence later in the file — see findEndPosition below.
function findStartMarker(b, from) {
  for (let i = from; i <= b.length - 1; i++) {
    if (b[i] === 1 && b[i + 4] === 13) {
      let marker = '';
      for (let t = 0; t <= 9; t++) marker += b[i + t];
      if (marker === '10001300000') return i;
    }
  }
  return -1;
}
function findStartPosition(b) {
  const i = findStartMarker(b, 0);
  return i === -1 ? -1 : i + 14;
}
// A content block shorter than this can't be a real document - see findEndPosition below.
// 2000 is comfortably above the largest genuine short block seen in the local archive
// (a few hundred bytes of heading) and far below the smallest real document.
const MIN_CONTENT_BLOCK_BYTES = 2000;

function findEndPosition(b, startP) {
  let normalEnd = -1;
  for (let i = startP; i <= b.length - 1; i++) {
    if (b[i + 6] === 255) {
      let marker = '';
      for (let t = 0; t <= 9; t++) marker += b[i + t];
      if (marker === '1300000255255255255') { normalEnd = i; break; }
    }
  }
  // Some older .inp files (seen on a 1992-era document) store the document's content
  // TWICE between a single pair of start/end markers, with a chunk of un-decodable
  // binary padding in between. Concretely: a second start-of-content marker turns up
  // *before* the real end marker. When that happens, stop there instead - otherwise the
  // decoded output ends up with a garbage tail (unmapped binary rendered as literal
  // "-XX" hex) followed by the entire document a second time.
  //
  // But that only holds when the first block is a whole document. Plenty of files put
  // several start markers a few dozen bytes apart - those are consecutive text frames of
  // one layout, not a repeat - and stopping at the first of them threw the document away:
  // 290-God is Love-Chiara-Gen 2-74.inp (69 KB) has its second marker 32 bytes after the
  // first and decoded to 10 characters instead of 17,853. Requiring the first block to be
  // at least MIN_CONTENT_BLOCK_BYTES long tells the two cases apart. Measured over all
  // 1365 .inp files in the local archive (2026-09-09): 54 files gain text, 40 of them
  // recovering from near-empty to a full document at 97-99% Urdu characters, and no file
  // loses a single line - so the 1992-era duplicate case stays protected.
  const secondStart = findStartMarker(b, startP + 1);
  if (secondStart !== -1 && secondStart - startP >= MIN_CONTENT_BLOCK_BYTES
      && (normalEnd === -1 || secondStart < normalEnd)) return secondStart;
  return normalEnd !== -1 ? normalEnd : b.length;
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
  // Safety net #1: every .inp file carries a per-"story" preamble of English metadata
  // (InPage's fixed 10-entry colour table - None/White/Black/Gray/Red/Yellow/Green/
  // Cyan/Blue/Magenta - followed by font names like "Noori Nastaliq"/"ZoharSindhi"/
  // "Simplified Arabic" and the literal signature "InPage Arabic Document"). Normally
  // findStartPosition/findEndPosition skip straight past all of this. On some older
  // multi-story files, though, the content markers land at a *second* story whose own
  // preamble ends up included - real Urdu body text will never contain these literal
  // English strings. Cut at whichever piece of leaked metadata turns up earliest (the
  // colour table and the font names don't always both survive far enough into the
  // decoded output to appear together, so each is checked independently).
  const junkMarkers = ['InPage Arabic Document', 'Simplified Arabic', 'ZoharSindhi', 'Noori Nastaliq', 'oori Character'];
  let junkAt = -1;
  const colourTable = out.match(/None[\s\S]{0,80}White[\s\S]{0,80}Black/);
  if (colourTable) junkAt = colourTable.index;
  for (const marker of junkMarkers) {
    const idx = out.indexOf(marker);
    if (idx !== -1 && (junkAt === -1 || idx < junkAt)) junkAt = idx;
  }
  if (junkAt !== -1) out = out.slice(0, junkAt);
  // Safety net #2: by this point every valid InPage byte has been replaced by a real
  // character. A run of 3+ still-literal "-XX" hex pairs can only be un-decodable binary
  // that slipped past the marker search (e.g. leftover layout records) - strip it rather
  // than let it leak into the Word/PDF output. A lone "-XX" is left alone since a genuine
  // "-" (from -04-F5) followed by ordinary characters that happen to look like hex digits
  // is possible; three in a row from real text is not.
  out = out.replace(/(-[0-9A-F]{2}){3,}/g, '');
  // Safety net #3: per-line plausibility filter, ported from the companion desktop
  // converter's TextCleaner.cs (validated on ~1200 real archive files). Binary noise that
  // survives nets #1/#2 by coincidentally mapping through the same character table as
  // real content (odd punctuation/control-character fragments, a few bytes wide) still
  // won't look like a real sentence: a genuine Urdu/Arabic line is overwhelmingly Arabic-
  // block characters, plain Latin letters/digits, or ordinary punctuation. Blank lines are
  // kept as-is (they're intentional spacing, not garbage - see splitIntoLines below).
  const EXTRA_PUNCT = new Set([0x2C, 0x3B, 0x3A, 0x21, 0x3F, 0x28, 0x29, 0x2D, 0x27, 0x22, 0x060C, 0x061F, 0x06D4, 0x40, 0x2F, 0x5F, 0x25, 0x2E]);
  function isPlausibleLine(line) {
    const trimmed = line.trim();
    if (trimmed.length === 0) return true;
    let plausible = 0;
    for (const ch of trimmed) {
      const c = ch.codePointAt(0);
      if ((c >= 0x0600 && c <= 0x06FF) || (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A) ||
          (c >= 0x30 && c <= 0x39) || c === 0x20 || EXTRA_PUNCT.has(c)) plausible++;
    }
    return (plausible / trimmed.length) >= 0.85;
  }
  out = out.split('\r\n').filter(isPlausibleLine).join('\r\n');
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
      // .iife.js, not .umd.cjs: jsDelivr serves .cjs as MIME type application/node, which
      // browsers with strict MIME checking refuse to execute as a <script> (found by testing
      // in a real browser - Node's `require()` doesn't care about MIME types, so this only
      // shows up once the library actually has to load in a page).
      s.src = 'https://cdn.jsdelivr.net/npm/docx@9.7.1/dist/index.iife.js';
      s.onload = () => resolve(window.docx);
      s.onerror = () => reject(new Error('Could not load the Word-generation library.'));
      document.head.appendChild(s);
    });
  }
  return docxLibPromise;
}

const URDU_FONT = 'Jameel Noori Nastaleeq';

// Converted InPage text uses \r\n (or, once round-tripped through an HTML <textarea>, plain
// \n) as the separator between what were distinct lines/paragraphs in the original document
// (title, verse reference, each body paragraph, blank spacer lines...) - there's no reliable
// double-line-break to split on, so every line becomes its own paragraph instead. A
// whitespace-only line still becomes an (empty) paragraph, to preserve the original spacing.
function splitIntoLines(text) {
  return text.replace(/\r\n/g, '\n').split('\n').map(l => l.trim());
}

// header: { documentId, englishRef } - both optional, shown as plain left-aligned lines
// before the Urdu body, each rendered right-aligned/RTL to match the layout already used
// for Word of Life bulletins.
export async function buildDocxBlob(urduText, header) {
  const docx = await loadDocxLib();
  const { Document, Packer, Paragraph, TextRun, AlignmentType } = docx;
  const headerParas = [];
  if (header?.documentId) headerParas.push(new Paragraph({ children: [new TextRun({ text: `Document ID: ${header.documentId}`, bold: true })] }));
  if (header?.englishRef) headerParas.push(new Paragraph({ children: [new TextRun({ text: header.englishRef, bold: true })] }));
  headerParas.push(new Paragraph({ text: '' }));

  const bodyParas = splitIntoLines(urduText).map(line => new Paragraph({
    alignment: AlignmentType.RIGHT,
    bidirectional: true,
    children: line ? [new TextRun({ text: line, font: URDU_FONT, rightToLeft: true })] : [],
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
  const paras = splitIntoLines(urduText).map(l => `<p>${esc(l) || '&nbsp;'}</p>`).join('\n');
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
    </div>
    ${isAdmin() ? bulkTextImportPanel() : ''}`;

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

  if (isAdmin()) wireBulkTextImport();
}

// ---------- Bulk Urdu text import (Admin only) ----------
// Fills document_texts (migration 68) from a folder of .inp files, converting them with the
// same inPageBytesToUnicode above - so what lands in the database is exactly what the single-
// file converter in this tab produces, not a separate offline pipeline that could drift.
//
// It runs in two halves on purpose. "Analyse" reads and converts everything and shows what it
// WOULD do, without touching the database; only then does Import write. A bulk load that
// starts writing on the first click is a load you cannot review, and this one touches the
// whole archive at once.
//
// Deliberately NOT a one-off script: new .inp files keep arriving from the typists, so the
// tool that loads them belongs in the app rather than on someone's disk.

function bulkTextImportPanel() {
  return `
    <div class="panel">
      <h2>Bulk Urdu text import <span class="hint">— Admin only, fills the searchable text of the archive</span></h2>
      <p class="hint">Converts a whole folder of .inp files and stores the Urdu text against the matching
        documents, which is what makes in-app reading and full-text search possible. Files are matched to
        documents by their original InPage filename, exactly as recorded in the archive
        (<i>original_inp_file_name</i> / <i>renamed_inp_file_name</i>). Nothing is written until you press
        Import, and text that somebody has already reviewed is never overwritten.</p>
      <div class="field">
        <label>InPage folder — subfolders are included</label>
        <input type="file" id="bti-files" multiple webkitdirectory directory>
        <div class="hint">Pick the top folder of the InPage archive; anything that isn't a .inp file is ignored.</div>
      </div>
      <div class="field" style="display:flex;flex-wrap:wrap;gap:6px 24px;">
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="bti-overwrite"> Replace text that is already stored (never touches reviewed text)
        </label>
        <label style="display:flex;align-items:center;gap:6px;text-transform:none;font-size:12.5px;">
          <input type="checkbox" id="bti-include-suspect"> Include suspect conversions (very short, or little Urdu)
        </label>
      </div>
      <div class="btn-row">
        <button class="btn" id="bti-analyse">Analyse</button>
        <button class="btn" id="bti-import" disabled>Import</button>
        <button class="btn secondary" id="bti-stop" style="display:none;">Stop</button>
      </div>
      <p id="bti-progress" class="hint"></p>
      <div id="bti-summary"></div>
      <div id="bti-log" style="max-height:260px;overflow:auto;font-size:12px;"></div>
    </div>`;
}

// Same tolerant key on both sides of the match: case, accents, punctuation and the leading
// zeros of the catalogue number all differ between the filenames on disk and the names recorded
// in the archive ("02-Giving..." in the database vs "002-Giving....inp" on disk).
function textKey(name) {
  return String(name).toLowerCase().replace(/\.inp$/, '')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')   // accenti, scritti come escape: sono invisibili
    .replace(/[^a-z0-9]/g, '')
    .replace(/^0+/, '');
}
// renamed_inp_file_name carries a "<id>-ALE-" / "<id>-STE-" prefix added during the 2026-08-31
// file work; the part after it is the historical name that matches what is on disk.
function stripIdPrefix(name) {
  const m = String(name).match(/^\d+-(?:ALE|STE)-(.*)$/);
  return m ? m[1] : String(name);
}
// Leading catalogue number, used only as a fallback and only together with the date below.
// NB: never run this through a path helper - the recorded names contain dates with slashes
// ("347-Linkup-10/1/1997"), which a basename() would chop.
function catalogueNumber(name) {
  const m = String(name).match(/^(\d{1,4})[^\d]/);
  return m ? m[1] : null;
}
// Every date in the string, normalised to ddmmyy so that 10.01.97 and 10/1/1997 compare equal.
function dateStamps(name) {
  return (String(name).match(/(\d{1,4})[.\-/ =]+(\d{1,2})[.\-/ =]+(\d{2,4})/g) || [])
    .map(x => x.split(/[.\-/ =]+/).map(n => n.length === 4 ? n.slice(2) : n.padStart(2, '0')).join(''));
}
function urduShare(text) {
  const t = text.replace(/\s/g, '');
  if (!t.length) return 0;
  let n = 0;
  for (const ch of t) { const c = ch.codePointAt(0); if (c >= 0x0600 && c <= 0x06FF) n++; }
  return n / t.length;
}

// Legge una tabella intera a pagine di 1000, che e' il tetto che PostgREST applica in silenzio
// a una select senza range.
async function fetchAllRows(table, columns) {
  const PAGE = 1000;
  const all = [];
  for (let from = 0; ; from += PAGE) {
    const page = await withStatus(sb.from(table).select(columns).order('document_id').range(from, from + PAGE - 1),
      `Reading ${table} (${all.length})...`);
    all.push(...page);
    if (page.length < PAGE) return all;
  }
}

let btiRows = [];
let btiStopRequested = false;

function wireBulkTextImport() {
  document.getElementById('bti-analyse').addEventListener('click', analyseBulkTextImport);
  document.getElementById('bti-import').addEventListener('click', runBulkTextImport);
  document.getElementById('bti-stop').addEventListener('click', () => { btiStopRequested = true; });
  // Le due caselle cambiano quante righe verranno scritte: il riepilogo e il pulsante devono
  // seguirle subito, altrimenti mostrerebbero il conteggio di prima della spunta.
  for (const id of ['bti-overwrite', 'bti-include-suspect']) {
    document.getElementById(id).addEventListener('change', () => {
      if (!btiRows.length) return;
      renderBulkAnalysis();
      document.getElementById('bti-import').disabled = plannedBulkRows().length === 0;
    });
  }
}

async function analyseBulkTextImport() {
  const files = [...document.getElementById('bti-files').files].filter(f => f.name.toLowerCase().endsWith('.inp'));
  const progress = document.getElementById('bti-progress');
  const summary = document.getElementById('bti-summary');
  const log = document.getElementById('bti-log');
  const importBtn = document.getElementById('bti-import');
  importBtn.disabled = true;
  summary.innerHTML = '';
  log.innerHTML = '';
  btiRows = [];
  if (!files.length) { alert('Choose a folder containing .inp files first.'); return; }

  // The whole archive's naming, in one go: short rows, cheaper and far less fragile than asking
  // the database once per file. Paged on purpose - PostgREST caps a plain select at 1000 rows
  // and says nothing about it, and documents is well past that: without paging, every document
  // beyond the first thousand would silently come back as "no matching document".
  progress.textContent = 'Reading the archive index...';
  const docs = await fetchAllRows('documents', 'document_id,original_inp_file_name,renamed_inp_file_name,en_title,title');
  const existing = await fetchAllRows('document_texts', 'document_id,reviewed');
  const reviewedIds = new Set(existing.filter(r => r.reviewed).map(r => r.document_id));
  const storedIds = new Set(existing.map(r => r.document_id));

  const byKey = new Map();       // nome normalizzato -> [documenti]
  const byNumber = new Map();    // numero di catalogo -> [documenti]
  for (const d of docs) {
    for (const raw of [d.original_inp_file_name, d.renamed_inp_file_name && stripIdPrefix(d.renamed_inp_file_name)]) {
      if (!raw) continue;
      const k = textKey(raw);
      if (k) { if (!byKey.has(k)) byKey.set(k, []); if (!byKey.get(k).includes(d)) byKey.get(k).push(d); }
      const n = catalogueNumber(raw);
      if (n) { if (!byNumber.has(n)) byNumber.set(n, []); if (!byNumber.get(n).includes(d)) byNumber.get(n).push({ doc: d, raw }); }
    }
  }

  const claimed = new Map();     // document_id -> nome del file che se l'e' gia' preso
  for (let i = 0; i < files.length; i++) {
    const f = files[i];
    if (i % 25 === 0) { progress.textContent = `Converting ${i} / ${files.length}...`; await new Promise(r => setTimeout(r)); }
    // name = solo il nome, ed e' quello su cui si aggancia; path = il percorso dentro la
    // cartella scelta, che si registra come provenienza e si mostra nei problemi (le stesse
    // trascrizioni compaiono in piu' sottocartelle: senza percorso non si capisce quale sia).
    const row = { name: f.name, path: f.webkitRelativePath || f.name, file: f };
    try {
      row.text = inPageBytesToUnicode(new Uint8Array(await f.arrayBuffer()), {});
    } catch (e) {
      row.status = 'failed'; row.note = e.message; btiRows.push(row); continue;
    }
    row.chars = row.text.length;
    row.urdu = urduShare(row.text);
    row.suspect = row.chars < 200 || row.urdu < 0.55;

    // 1) match sul nome; 2) ripiego sul numero di catalogo, ma solo se anche la data coincide -
    // il numero da solo aggancerebbe documenti diversi che iniziano per le stesse cifre.
    let hit = byKey.get(textKey(f.name)) || [];
    if (!hit.length) {
      const cands = (byNumber.get(catalogueNumber(f.name)) || []).filter(c => {
        const a = dateStamps(f.name), b = dateStamps(c.raw);
        return a.length && b.length && a.some(x => b.includes(x));
      });
      hit = cands.map(c => c.doc);
      if (hit.length) row.viaNumber = true;
    }
    if (!hit.length) { row.status = 'nomatch'; btiRows.push(row); continue; }
    if (hit.length > 1) { row.status = 'ambiguous'; row.docs = hit; btiRows.push(row); continue; }

    const doc = hit[0];
    row.doc = doc;
    if (claimed.has(doc.document_id)) { row.status = 'duplicate'; row.note = claimed.get(doc.document_id); btiRows.push(row); continue; }
    if (reviewedIds.has(doc.document_id)) { row.status = 'reviewed'; btiRows.push(row); continue; }
    row.status = storedIds.has(doc.document_id) ? 'stored' : 'new';
    claimed.set(doc.document_id, f.name);
    btiRows.push(row);
  }

  renderBulkAnalysis();
  progress.textContent = `Analysed ${files.length} file(s). Nothing has been written yet.`;
  importBtn.disabled = plannedBulkRows().length === 0;
}

// Quali righe verranno scritte, date le due caselle. Unico punto che decide: la tabella di
// riepilogo, il pulsante e il ciclo di scrittura leggono tutti da qui, cosi' non possono
// raccontare tre cose diverse.
function plannedBulkRows() {
  const overwrite = document.getElementById('bti-overwrite')?.checked;
  const includeSuspect = document.getElementById('bti-include-suspect')?.checked;
  return btiRows.filter(r =>
    (r.status === 'new' || (r.status === 'stored' && overwrite))
    && (!r.suspect || includeSuspect));
}

function renderBulkAnalysis() {
  const count = s => btiRows.filter(r => r.status === s).length;
  const planned = plannedBulkRows();
  const suspectPlanned = planned.filter(r => r.suspect).length;
  document.getElementById('bti-summary').innerHTML = `
    <div class="grid-wrap"><table class="grid">
      <thead><tr><th>Outcome</th><th>Files</th><th></th></tr></thead>
      <tbody>
        <tr><td>New text to store</td><td>${count('new')}</td><td class="hint">no text held for that document yet</td></tr>
        <tr><td>Already stored</td><td>${count('stored')}</td><td class="hint">${document.getElementById('bti-overwrite').checked ? 'will be replaced' : 'skipped unless you tick Replace'}</td></tr>
        <tr><td>Reviewed — never touched</td><td>${count('reviewed')}</td><td class="hint">somebody has checked this text by hand</td></tr>
        <tr><td>No matching document</td><td>${count('nomatch')}</td><td class="hint">filename not recorded in the archive</td></tr>
        <tr><td>Ambiguous</td><td>${count('ambiguous')}</td><td class="hint">the name matches more than one document</td></tr>
        <tr><td>Duplicate of another file</td><td>${count('duplicate')}</td><td class="hint">same document already taken by an earlier file</td></tr>
        <tr><td>Conversion failed</td><td>${count('failed')}</td><td class="hint">not a readable .inp</td></tr>
      </tbody>
    </table></div>
    <p class="hint" style="margin-top:8px;"><b>${planned.length}</b> file(s) will be written${suspectPlanned ? `, of which <b>${suspectPlanned}</b> flagged as suspect` : ''}.
      Everything imported here is stored as an unverified automatic transcription until somebody reviews it.</p>`;

  const problems = btiRows.filter(r => ['nomatch', 'ambiguous', 'duplicate', 'failed'].includes(r.status) || r.suspect);
  document.getElementById('bti-log').innerHTML = problems.length
    ? `<div class="hint" style="margin-top:6px;">Needs a human eye (${problems.length}):</div>` + problems.map(r => {
      const why = r.status === 'nomatch' ? 'no matching document'
        : r.status === 'ambiguous' ? 'matches #' + r.docs.map(d => d.document_id).join(', #')
          : r.status === 'duplicate' ? 'that document was already taken by ' + r.note
            : r.status === 'failed' ? r.note
              : `suspect: ${r.chars} chars, ${(r.urdu * 100).toFixed(0)}% Urdu`;
      return `<div>${esc(r.path)} — ${esc(why)}</div>`;
    }).join('')
    : '';
}

async function runBulkTextImport() {
  const planned = plannedBulkRows();
  if (!planned.length) return;
  if (!confirm(`Store the Urdu text of ${planned.length} document(s)?\n\nText already reviewed by hand is never touched.`)) return;

  btiStopRequested = false;
  const importBtn = document.getElementById('bti-import');
  const analyseBtn = document.getElementById('bti-analyse');
  const stopBtn = document.getElementById('bti-stop');
  const progress = document.getElementById('bti-progress');
  const log = document.getElementById('bti-log');
  importBtn.disabled = true; analyseBtn.disabled = true; stopBtn.style.display = 'inline-block';

  const { data: { user } } = await sb.auth.getUser();
  // Written in batches: one request per document would be ~1000 round trips, one single request
  // would be a ~19 MB body. body_norm and char_count are generated columns - sending them would
  // be rejected - and `reviewed` is left out on purpose so that replacing a stored text cannot
  // silently reset somebody's review flag.
  const BATCH = 20;
  let done = 0, saved = 0, failed = 0;
  for (let i = 0; i < planned.length && !btiStopRequested; i += BATCH) {
    const chunk = planned.slice(i, i + BATCH);
    const payload = chunk.map(r => ({
      document_id: r.doc.document_id,
      body: r.text,
      source: 'inpage',
      source_file: r.path,
      updated_by_email: user?.email || null,
    }));
    try {
      const { error } = await sb.from('document_texts').upsert(payload, { onConflict: 'document_id' });
      if (error) throw error;
      saved += chunk.length;
    } catch (err) {
      failed += chunk.length;
      log.insertAdjacentHTML('beforeend', `<div>Batch starting at ${esc(chunk[0].path)} failed — ${esc(err.message)}</div>`);
    }
    done += chunk.length;
    progress.textContent = `${done} / ${planned.length} (${saved} stored, ${failed} failed)${btiStopRequested ? ' — stopped, safe to run again.' : ''}`;
    await new Promise(r => setTimeout(r, 60));
  }

  stopBtn.style.display = 'none';
  analyseBtn.disabled = false;
  progress.textContent = `Finished: ${saved} stored, ${failed} failed${btiStopRequested ? ' (stopped early)' : ''}. Re-run Analyse to see the new state.`;
}
