#!/usr/bin/env node
'use strict';
/**
 * bin/estrai-tag.js — estrazione dei tag da una cartella o da un singolo file.
 *
 *   node bin/estrai-tag.js <percorso> [opzioni]
 *
 * <percorso>  un file .inp / .docx / .txt oppure una cartella (ricorsiva)
 *
 *   --max <n>          numero massimo di tag per documento (default 6)
 *   --out <file.csv>   tabella di revisione (default tag-estratti.csv)
 *   --tassonomia <f>   file YAML del vocabolario (default tassonomia_focolare.yaml)
 *   --supabase         scrive anche su Supabase (richiede le variabili d'ambiente)
 *   --dry-run          non scrive nulla, stampa soltanto
 *
 * Variabili d'ambiente per --supabase:
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 */
const fs = require('fs');
const path = require('path');
const { caricaTassonomia } = require('../lib/tassonomia');
const { trovaTag, selezionaMigliori } = require('../lib/estrai');
const { leggiInp, leggiTxtLegacy } = require('../lib/inpage');
const { leggiDocx } = require('../lib/docx');

const ESTENSIONI = new Set(['.inp', '.docx', '.txt']);

// Default risolto rispetto alla cartella dello script (non alla cwd di chi lo lancia):
// cosi' `node tools/tag-extraction/bin/estrai-tag.js ...` funziona da qualunque punto
// del repo, invece di richiedere di essere dentro tools/tag-extraction/.
const TASSONOMIA_DEFAULT = path.join(__dirname, '..', 'tassonomia_focolare.yaml');

function argomenti(argv) {
  const a = { max: 6, out: 'tag-estratti.csv', tassonomia: TASSONOMIA_DEFAULT };
  const resto = [];
  for (let i = 0; i < argv.length; i++) {
    const v = argv[i];
    if (v === '--max') a.max = parseInt(argv[++i], 10);
    else if (v === '--out') a.out = argv[++i];
    else if (v === '--tassonomia') a.tassonomia = argv[++i];
    else if (v === '--supabase') a.supabase = true;
    else if (v === '--dry-run') a.dryRun = true;
    else resto.push(v);
  }
  a.percorso = resto[0];
  return a;
}

function elencaFile(percorso) {
  const st = fs.statSync(percorso);
  if (st.isFile()) return [percorso];
  const out = [];
  (function cammina(dir) {
    for (const v of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, v.name);
      if (v.isDirectory()) cammina(p);
      else if (ESTENSIONI.has(path.extname(v.name).toLowerCase()) && !v.name.startsWith('~$')) out.push(p);
    }
  })(percorso);
  return out.sort();
}

/** Estrae il testo secondo il formato. Ritorna '' se il file non e' leggibile. */
function testoDi(percorso) {
  const ext = path.extname(percorso).toLowerCase();
  if (ext === '.inp') return leggiInp(percorso);
  if (ext === '.docx') return leggiDocx(percorso);
  if (ext === '.txt') {
    const dati = fs.readFileSync(percorso);
    // un export legacy di InPage contiene la marca 0x04 ad alta frequenza
    const marche = dati.filter ? [...dati].filter((b) => b === 4).length : 0;
    return marche > dati.length / 10 ? leggiTxtLegacy(percorso) : dati.toString('utf8');
  }
  return '';
}

function csvCampo(v) {
  const s = String(v == null ? '' : v);
  return /[",\n;]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
}

async function main() {
  const a = argomenti(process.argv.slice(2));
  if (!a.percorso) {
    console.error('uso: node bin/estrai-tag.js <file-o-cartella> [--max 6] [--out tag.csv] [--supabase]');
    process.exit(1);
  }
  const tx = caricaTassonomia(a.tassonomia);
  const file = elencaFile(a.percorso);
  console.error(`Tassonomia: ${tx.tags.size} tag, ${tx.pattern.length} pattern.`);
  console.error(`File da elaborare: ${file.length}`);

  const righe = [];
  const perSupabase = [];
  let vuoti = 0;

  for (const f of file) {
    let testo = '';
    try {
      testo = testoDi(f);
    } catch (e) {
      console.error(`  ! ${path.basename(f)}: ${e.message}`);
      continue;
    }
    if (testo.trim().length < 40) { vuoti++; continue; }

    const scelti = selezionaMigliori(trovaTag(testo, tx), a.max);
    righe.push({
      file: path.relative(process.cwd(), f),
      nome: path.basename(f),
      caratteri: testo.length,
      n_tag: scelti.length,
      tag_id: scelti.map((t) => t.tagId).join('; '),
      tag_it: scelti.map((t) => t.it).join('; '),
      tag_en: scelti.map((t) => t.en).join('; '),
      tag_ur: scelti.map((t) => t.ur).join('; '),
      faccette: scelti.map((t) => t.faccetta).join('; '),
      punteggi: scelti.map((t) => t.punteggio).join('; '),
    });
    for (const t of scelti) {
      perSupabase.push({
        file_name: path.basename(f),
        tag_id: t.tagId,
        faccetta: t.faccetta,
        punteggio: t.punteggio,
        confidenza: t.confidenza,
        origine: 'auto',
      });
    }
  }

  const intestazione = ['file', 'nome', 'caratteri', 'n_tag', 'tag_id', 'tag_it', 'tag_en', 'tag_ur', 'faccette', 'punteggi'];
  const csv = '﻿' + [intestazione.join(','),
    ...righe.map((r) => intestazione.map((c) => csvCampo(r[c])).join(','))].join('\n');

  if (a.dryRun) {
    console.log(csv);
  } else {
    fs.writeFileSync(a.out, csv, 'utf8');
    console.error(`  -> ${a.out} (${righe.length} righe)`);
  }
  console.error(`Documenti elaborati: ${righe.length}   senza testo utile: ${vuoti}`);
  const senza = righe.filter((r) => r.n_tag === 0).length;
  console.error(`Documenti senza alcun tag: ${senza}`);

  if (a.supabase && !a.dryRun) {
    const { scriviSuSupabase } = require('../lib/supabase');
    await scriviSuSupabase(perSupabase, tx);
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
