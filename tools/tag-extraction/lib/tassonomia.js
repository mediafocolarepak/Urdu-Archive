'use strict';
/**
 * lib/tassonomia.js — carica il vocabolario controllato e costruisce i matcher.
 *
 * Struttura di un tag nel file YAML:
 *   id      identificatore stabile (chiave nel database: non cambia MAI)
 *   facet   faccetta (PER persone, BRA branche, SPI punti cardine, TEM temi,
 *           COL colori, ADA arte di amare, STR strumenti, EVE eventi,
 *           LUO luoghi, PUB fonti, ORG strutture, GEN genere, DES destinatario)
 *   pref    etichetta preferita per lingua {it, en, ur}
 *   alt     alias FORTI: se compaiono, il tag si assegna
 *   weak    alias DEBOLI/ambigui: contano solo se nello stesso documento c'e'
 *           gia' un match forte dello stesso tag
 *   broader tag padre (ricerca allargata)
 */
const fs = require('fs');
const yaml = require('js-yaml');
const { normalizza } = require('./normalizza');

function escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function costruisciPattern(termine, lingua) {
  const n = normalizza(String(termine));
  if (n.length < 2) return null;
  let esc = escapeRegex(n).replace(/ /g, '\\s+');
  // dopo un punto di abbreviazione lo spazio e' facoltativo: "S. Santo" trova "S.SANTO"
  esc = esc.replace(/\\\.\\s\+/g, '\\.\\s*');
  if (lingua === 'ur') {
    // i testi in Nastaliq confondono choti ye e bari ye: si accettano entrambe
    esc = esc.replace(/[یے]/g, '[یے]');
    esc = esc.replace(/\\s\+/g, '\\s*');
  }
  return new RegExp('(?<![\\p{L}\\p{N}_])' + esc + '(?![\\p{L}\\p{N}_])', 'giu');
}

function caricaTassonomia(percorso) {
  const doc = yaml.load(fs.readFileSync(percorso, 'utf8'));
  const tags = new Map();
  const pattern = [];
  for (const t of doc.tags) {
    tags.set(t.id, t);
    for (const [forza, chiave] of [['forte', 'alt'], ['debole', 'weak']]) {
      const blocco = t[chiave] || {};
      for (const [lingua, termini] of Object.entries(blocco)) {
        for (const termine of termini || []) {
          const rx = costruisciPattern(termine, lingua);
          if (rx) pattern.push({ rx, tagId: t.id, lingua, forza, termine });
        }
      }
    }
  }
  return { doc, tags, pattern };
}

module.exports = { caricaTassonomia, costruisciPattern };
