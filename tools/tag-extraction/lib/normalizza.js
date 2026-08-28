'use strict';
/**
 * lib/normalizza.js — UNICA fonte di verita' per la normalizzazione.
 * Va usata sul testo, sugli alias della tassonomia E sulla stringa digitata
 * dall'utente nella ricerca: se i due lati non sono normalizzati allo stesso
 * modo la ricerca fallisce in silenzio.
 *
 * REGOLA DELL'ACCENTO DATTILOGRAFICO
 *   I testi Focolare scrivono la vocale accentata come vocale + apostrofo:
 *   UNITA'  SPIRITUALITA'  GESU'ABBANDONATO  CITTA'NUOVA  E'  PERCHE'
 *   In italiano l'apostrofo preceduto da vocale non e' mai elisione (le
 *   elisioni finiscono in consonante: l', un', dell'), quindi la sostituzione
 *   con uno spazio e' sicura.
 */

const APOSTROFI = /[’‘ʼ`´]/g;
const ACCENTO_DATTILO = /([aeiouAEIOU])'/g;
const UR_DIACRITICI = /[ً-ْٓ-ٰٕٖ-ٟۖ-ۭ]/g;
const UR_INVISIBILI = /[​-‏‪-‮⁦-⁩ـ]/g;
const UR_PUNTEGGIATURA = /[۔،؛؟٪-٭«»]/g;
const UR_MAPPA = { 'ي': 'ی', 'ى': 'ی', 'ك': 'ک', 'ة': 'ہ', 'ه': 'ہ', 'ۃ': 'ہ', 'أ': 'ا', 'إ': 'ا', 'آ': 'ا' };

function normalizza(testo) {
  if (!testo) return '';
  let t = testo.normalize('NFC').replace(APOSTROFI, "'");
  t = t.replace(ACCENTO_DATTILO, '$1 ');
  t = t.replace(UR_INVISIBILI, '').replace(UR_DIACRITICI, '');
  t = t.replace(/[ء-ۿ]/g, (c) => UR_MAPPA[c] || c);
  t = t.replace(/[۰-۹]/g, (c) => String(c.charCodeAt(0) - 0x06f0));
  t = t.replace(/[٠-٩]/g, (c) => String(c.charCodeAt(0) - 0x0660));
  t = t.normalize('NFD').replace(/[̀-ͯ]/g, '').normalize('NFC');
  t = t.toLowerCase();
  t = t.replace(UR_PUNTEGGIATURA, ' ');
  return t.replace(/\s+/g, ' ').trim();
}

/** Casi di collaudo: eseguire dopo ogni modifica (npm test). */
const CASI = [
  ["UNITA'", 'unita'], ['unità', 'unita'],
  ["GESU'ABBANDONATO", 'gesu abbandonato'], ['Gesù Abbandonato', 'gesu abbandonato'],
  ["SPIRITUALITA'COLLETTIVA", 'spiritualita collettiva'], ["CITTA'NUOVA", 'citta nuova'],
  ["E' NECESSARIO", 'e necessario'], ["PERCHE'", 'perche'],
  ["L'UNITA'", "l'unita"], ["un'ora", "un'ora"], ["dell'Opera", "dell'opera"],
  ['خُدا', 'خدا'], ['یسوع متروک۔', 'یسوع متروک'],
];

module.exports = { normalizza, CASI };
