// Hand-rolled test harness for the app's pure utility functions - no dependency, no npm.
// Run before every publish (see publish.ps1). Only tests functions with no Supabase calls;
// mocking supabase-js well enough to unit-test the CRUD glue isn't worth it for this app.

import { slugify, computeFileName, yearOf } from './core.js?v=20260817101544';
import { extractDateFromFilename, titleOverlapScore, normalizeForCompare, slugifyTitle } from './bulkimport.js?v=20260817101544';
import { rankByDateProximity, rankByYearMonthProximity, pdvApproxDate } from './matchreview.js?v=20260817101544';

let passed = 0, failed = 0;
const results = [];

function assert(condition, label) {
  if (condition) { passed++; results.push({ ok: true, label }); }
  else { failed++; results.push({ ok: false, label }); }
}
function assertEqual(actual, expected, label) {
  const ok = JSON.stringify(actual) === JSON.stringify(expected);
  assert(ok, `${label} â€” got ${JSON.stringify(actual)}, expected ${JSON.stringify(expected)}`);
}

// ---- slugify / slugifyTitle ----
assertEqual(slugify('The Family Life! (draft)'), 'the-family-life-draft', 'slugify strips punctuation');
assertEqual(slugify(''), 'untitled', 'slugify falls back to untitled on empty input');
assertEqual(slugifyTitle('The Family Life! (draft)'), 'the-family-life-draft', 'slugifyTitle matches slugify on simple input');

// ---- yearOf ----
assertEqual(yearOf('1994-10-27', null), '1994', 'yearOf reads year from ref_date');
assertEqual(yearOf(null, 'Summer 2003 retreat'), '2003', 'yearOf falls back to a year found in ref_period');
assertEqual(yearOf(null, null), 'XXXX', 'yearOf falls back to XXXX with no date info at all');

// ---- computeFileName ----
assertEqual(
  computeFileName({ document_id: 1, category: 'DISC', author: 'CHIA', main_topic: '12PO', title: 'Unity', ref_date: '1982-06-09' }),
  '00001-DISC-CHIA-12PO-unity-1982.pdf',
  'computeFileName without provenance'
);
assertEqual(
  computeFileName({ document_id: 500, category: 'EXPE', author: 'OTHR', main_topic: 'GENR', title: 'A Test Title', provenance: 'STELLA', ref_date: '2020-01-01' }),
  '00500-EXPE-OTHR-GENR-STELLA-a-test-title-2020.pdf',
  'computeFileName includes provenance segment when set'
);

// ---- extractDateFromFilename ----
assertEqual(extractDateFromFilename('303.Linkup.27.10.94.pdf'), { ref_date: '1994-10-27', ref_period: null }, 'extractDateFromFilename: 2-digit year dd.mm.yy');
assertEqual(extractDateFromFilename('421-Linkup-9-10-86.pdf'), { ref_date: '1986-10-09', ref_period: null }, 'extractDateFromFilename: dashes, 2-digit year');
assertEqual(extractDateFromFilename('2003 Maria nel Movimento.pdf'), { ref_date: null, ref_period: '2003' }, 'extractDateFromFilename: bare year only');
assertEqual(extractDateFromFilename('no-date-here.pdf'), { ref_date: null, ref_period: null }, 'extractDateFromFilename: no date found at all');

// ---- titleOverlapScore / normalizeForCompare ----
assert(titleOverlapScore('Jesus Forsaken key of unity', 'jesus-forsaken-key-of-unity-1983') > 0.9, 'titleOverlapScore: near-identical titles score high');
assert(titleOverlapScore('Completely unrelated text', 'Something else entirely') < 0.3, 'titleOverlapScore: unrelated titles score low');
assertEqual(normalizeForCompare('Hello, World!.pdf'), 'hello world', 'normalizeForCompare strips punctuation and extension');

// ---- rankByDateProximity ----
{
  const refs = [{ id: 'a', data: '1990-01-01' }, { id: 'b', data: '1990-06-15' }, { id: 'c', data: null }, { id: 'd', data: '1990-06-10' }];
  const ranked = rankByDateProximity('1990-06-12', refs, 'data');
  assertEqual(ranked[0].id, 'd', 'rankByDateProximity: closest date ranked first');
  assertEqual(ranked[ranked.length - 1].id, 'c', 'rankByDateProximity: no-date candidate appended at the end, not dropped');
  assertEqual(rankByDateProximity(null, refs, 'data').length, 4, 'rankByDateProximity: with no target date, returns everything unranked');
}

// ---- pdvApproxDate / rankByYearMonthProximity ----
{
  const jan2005 = pdvApproxDate({ mese: 'Gennaio 2005', anno: '2005' });
  assert(jan2005 !== null && new Date(jan2005).getFullYear() === 2005 && new Date(jan2005).getMonth() === 0, 'pdvApproxDate: parses Italian month name + year');
  assertEqual(pdvApproxDate({ mese: '', anno: '' }), null, 'pdvApproxDate: blank input returns null, not a bogus date');
}

// ---- render results ----
const root = document.getElementById('results');
root.innerHTML = `
  <h1>${failed === 0 ? 'âœ…' : 'âŒ'} ${passed} passed, ${failed} failed</h1>
  <table border="1" cellpadding="6" style="border-collapse:collapse;font-family:monospace;font-size:13px;">
    ${results.map(r => `<tr style="background:${r.ok ? '#e6ffed' : '#ffecec'}"><td>${r.ok ? 'PASS' : 'FAIL'}</td><td>${r.label}</td></tr>`).join('')}
  </table>
`;
window.__testResults = { passed, failed };
