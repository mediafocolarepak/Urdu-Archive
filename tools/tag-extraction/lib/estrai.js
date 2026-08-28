'use strict';
/**
 * lib/estrai.js — assegna i tag a un testo e ne seleziona al massimo N.
 *
 * Due passaggi:
 *  1. ricerca di tutti gli alias, con risoluzione delle sovrapposizioni a
 *     favore del match piu' lungo (cosi' "Word of Life" non fa scattare anche
 *     il tag generico "the Word");
 *  2. selezione dei migliori N con QUOTE PER FACCETTA, perche' sei tag tutti
 *     dello stesso tipo descrivono male un documento.
 */
const { normalizza } = require('./normalizza');

const FACCETTE_TEMATICHE = new Set(['SPI', 'TEM', 'COL', 'ADA', 'STR']);
const FACCETTE_CONTESTO = new Set(['GEN', 'DES', 'BRA']);

/** Trova tutti i tag presenti nel testo, con punteggio e confidenza. */
function trovaTag(testo, tassonomia) {
  const norm = normalizza(testo);
  const colpi = [];
  for (const p of tassonomia.pattern) {
    p.rx.lastIndex = 0;
    let m;
    while ((m = p.rx.exec(norm)) !== null) {
      colpi.push({ da: m.index, a: m.index + m[0].length, ...p });
      if (m.index === p.rx.lastIndex) p.rx.lastIndex++;
    }
  }
  // match piu' lungo vince; span identici convivono (un termine puo' servire
  // due tag legati da gerarchia, es. Maria persona e Maria punto cardine)
  colpi.sort((a, b) => (b.a - b.da) - (a.a - a.da) || a.da - b.da);
  const tenuti = [];
  for (const c of colpi) {
    const scontro = tenuti.some((k) =>
      !(c.da === k.da && c.a === k.a) && c.da < k.a && k.da < c.a);
    if (!scontro) tenuti.push(c);
  }

  const per = new Map();
  const visti = new Set();
  for (const c of tenuti) {
    const chiave = c.da + ':' + c.a + ':' + c.tagId;
    if (!per.has(c.tagId)) per.set(c.tagId, { tagId: c.tagId, forti: 0, deboli: 0, termini: new Map(), lingue: new Set() });
    const r = per.get(c.tagId);
    r.lingue.add(c.lingua);
    if (visti.has(chiave)) continue;   // lo stesso termine puo' stare in piu' lingue
    visti.add(chiave);
    if (c.forza === 'forte') r.forti++; else r.deboli++;
    r.termini.set(c.termine, (r.termini.get(c.termine) || 0) + 1);
  }

  const esito = [];
  for (const r of per.values()) {
    if (r.forti === 0) continue;                    // solo match deboli: si scarta
    const tag = tassonomia.tags.get(r.tagId);
    const piuLungo = Math.max(...[...r.termini.keys()].map((t) => t.split(/\s+/).length));
    esito.push({
      tagId: r.tagId,
      faccetta: tag.facet,
      punteggio: 3 * r.forti + r.deboli,
      confidenza: (r.forti >= 2 || piuLungo >= 2) ? 'alta' : 'media',
      termini: [...r.termini.keys()].slice(0, 5),
      it: (tag.pref && tag.pref.it) || '',
      en: (tag.pref && tag.pref.en) || '',
      ur: (tag.pref && tag.pref.ur) || '',
    });
  }
  return esito.sort((a, b) => b.punteggio - a.punteggio);
}

/**
 * Seleziona al massimo `max` tag garantendo un minimo di varieta':
 * almeno 3 tematici e almeno 1 di contesto (genere/destinatario/branca),
 * il resto per punteggio. Se il testo non offre abbastanza di una categoria,
 * i posti liberi vanno agli altri: non si inventa nulla.
 */
function selezionaMigliori(tag, max = 6, quote = { tematici: 3, contesto: 1 }) {
  const scelti = [];
  const prendi = (filtro, quanti) => {
    for (const t of tag) {
      if (scelti.length >= max || quanti <= 0) break;
      if (scelti.includes(t) || !filtro(t)) continue;
      scelti.push(t); quanti--;
    }
  };
  prendi((t) => FACCETTE_TEMATICHE.has(t.faccetta), quote.tematici);
  prendi((t) => FACCETTE_CONTESTO.has(t.faccetta), quote.contesto);
  prendi(() => true, max);            // riempi i posti rimasti per punteggio
  return scelti.slice(0, max).sort((a, b) => b.punteggio - a.punteggio);
}

module.exports = { trovaTag, selezionaMigliori, FACCETTE_TEMATICHE, FACCETTE_CONTESTO };
