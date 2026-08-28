'use strict';
/**
 * lib/inpage.js — legge i documenti InPage (formato legacy, font Noori Nastaliq)
 * e li converte in urdu Unicode.
 *
 * PERCHE' SERVE
 * InPage non esporta in Unicode: il suo "salva come testo" produce il flusso
 * nella codifica interna, che in un editor sembra illeggibile. In realta' e'
 * regolare: ogni carattere urdu e' la coppia di byte 04 XX, dove XX e' il
 * codice della lettera; il testo latino resta ASCII. Il flusso e' in ordine
 * LOGICO, quindi non serve alcuna ricostruzione geometrica.
 *
 * Un file .inp e' un contenitore OLE (Compound File) con due flussi interni:
 * il testo sta in "InPage100", nella stessa identica codifica. Quindi si legge
 * il .inp direttamente, senza passare da InPage.
 *
 * I codici 0x81-0xA7 seguono esattamente l'ordine dell'alfabeto urdu: e' la
 * verifica che la tabella e' corretta.
 */

const CFB = require('cfb');
const fs = require('fs');

const MARCA = 0x04;

const TABELLA = {
  0x20: ' ',
  0x81: 'ا', 0x82: 'ب', 0x83: 'پ', 0x84: 'ت', 0x85: 'ٹ', 0x86: 'ث',
  0x87: 'ج', 0x88: 'چ', 0x89: 'ح', 0x8a: 'خ', 0x8b: 'د', 0x8c: 'ڈ',
  0x8d: 'ذ', 0x8e: 'ر', 0x8f: 'ڑ', 0x90: 'ز', 0x91: 'ژ', 0x92: 'س',
  0x93: 'ش', 0x94: 'ص', 0x95: 'ض', 0x96: 'ط', 0x97: 'ظ', 0x98: 'ع',
  0x99: 'غ', 0x9a: 'ف', 0x9b: 'ق', 0x9c: 'ک', 0x9d: 'گ', 0x9e: 'ل',
  0x9f: 'م', 0xa0: 'ن', 0xa1: 'ں', 0xa2: 'و', 0xa3: 'ئ', 0xa4: 'ی',
  // 0xa5 = ye automatica, gestita a parte
  0xa6: 'ہ', 0xa7: 'ھ',
  0xb3: 'ٓ', 0xc7: 'ً',
  0xed: '،', 0xee: '؟', 0xf3: '۔',
  0xfd: '‘', 0xfe: '’',
};

const YE_AUTO = 0xa5;
const YE_FINALE = 'ے';
const YE_MEDIANA = 'ی';
// dopo questi codici la ye e' comunque finale (chiudono la parola)
const CHIUDE_PAROLA = new Set([0x20, 0xed, 0xee, 0xf3, 0xfd, 0xfe]);

/**
 * Converte il flusso legacy in Unicode.
 * @param {Buffer} dati
 * @param {{segnalaIgnoti?: boolean}} opzioni
 * @returns {string}
 */
function converti(dati, opzioni = {}) {
  const segnala = opzioni.segnalaIgnoti !== false;
  // 1. tokenizza in unita' ('U' = urdu, 'A' = ascii)
  const unita = [];
  for (let i = 0; i < dati.length; ) {
    if (dati[i] === MARCA && i + 1 < dati.length) {
      unita.push([85, dati[i + 1]]); i += 2;          // 85 = 'U'
    } else {
      unita.push([65, dati[i]]); i += 1;              // 65 = 'A'
    }
  }
  // 2. decodifica
  const out = [];
  for (let n = 0; n < unita.length; n++) {
    const [tipo, c] = unita[n];
    if (tipo === 65) {
      out.push(c === 9 || c === 10 || c === 13 || (c >= 32 && c < 127) ? String.fromCharCode(c) : '');
      continue;
    }
    if (c === YE_AUTO) {
      const succ = unita[n + 1];
      const finale = !succ || succ[0] === 65 || CHIUDE_PAROLA.has(succ[1]);
      out.push(finale ? YE_FINALE : YE_MEDIANA);
      continue;
    }
    const ch = TABELLA[c];
    if (ch === undefined) out.push(segnala ? '<' + c.toString(16).toUpperCase().padStart(2, '0') + '>' : '');
    else out.push(ch);
  }
  return out.join('');
}

// tiene le porzioni con almeno 8 caratteri urdu di fila: scarta le strutture
// binarie del documento senza perdere testo
const FRAMMENTO = /[؀-ۿ‘’ ]{8,}/g;

/**
 * Legge un file .inp e ne restituisce il testo urdu in Unicode.
 * @param {string} percorso
 * @returns {string}
 */
function leggiInp(percorso) {
  const cfb = CFB.read(fs.readFileSync(percorso), { type: 'buffer' });
  const flusso = CFB.find(cfb, 'InPage100') || cfb.FileIndex.find((f) => f.content && f.content.length > 512);
  if (!flusso || !flusso.content) throw new Error('flusso InPage100 non trovato: ' + percorso);
  const grezzo = converti(Buffer.from(flusso.content), { segnalaIgnoti: false });
  const pezzi = (grezzo.match(FRAMMENTO) || []).map((s) => s.trim()).filter(Boolean);
  return pezzi.join('\n');
}

/** Legge un export testuale di InPage (.TXT con la codifica legacy). */
function leggiTxtLegacy(percorso) {
  return converti(fs.readFileSync(percorso));
}

module.exports = { converti, leggiInp, leggiTxtLegacy, TABELLA };
