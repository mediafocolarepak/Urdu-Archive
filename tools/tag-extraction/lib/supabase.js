'use strict';
/**
 * lib/supabase.js — scrittura dei tag su Supabase.
 *
 * Scrive SOLO nelle tabelle nuove (tag, documento_tag): i campi esistenti
 * dell'archivio — category, main_topic, secondary_tags — non vengono toccati.
 *
 * Il campo `origine` ('auto' / 'umano') e' quello che rende sostenibile la
 * manutenzione: permette di rilanciare l'estrazione su tutto il corpus
 * cancellando solo le righe 'auto' e lasciando intatte le correzioni fatte a
 * mano. Senza quel campo ogni ripassata distrugge il lavoro di revisione.
 */
const { createClient } = require('@supabase/supabase-js');

function client() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) throw new Error('mancano SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY');
  return createClient(url, key, { auth: { persistSession: false } });
}

/** Allinea la tabella `tag` alla tassonomia (upsert per id). */
async function sincronizzaTassonomia(tx) {
  const db = client();
  const righe = [...tx.tags.values()].map((t) => ({
    tag_id: t.id,
    faccetta: t.facet,
    etichetta_it: (t.pref && t.pref.it) || null,
    etichetta_en: (t.pref && t.pref.en) || null,
    etichetta_ur: (t.pref && t.pref.ur) || null,
    broader: t.broader || null,
  }));
  const { error } = await db.from('tag').upsert(righe, { onConflict: 'tag_id' });
  if (error) throw error;
  return righe.length;
}

/**
 * Scrive le assegnazioni. `voci` = [{file_name, tag_id, faccetta, punteggio,
 * confidenza, origine}]. Il document_id si risolve dal file_name, contro la
 * tabella `documents` gia' esistente nell'archivio (non una tabella nuova:
 * e' quella che l'app usa per tutto il resto - vedi js/core.js).
 */
async function scriviSuSupabase(voci, tx) {
  const db = client();
  const n = await sincronizzaTassonomia(tx);
  console.error(`  Supabase: tassonomia allineata (${n} tag)`);

  const nomi = [...new Set(voci.map((v) => v.file_name))];
  const mappa = new Map();
  for (let i = 0; i < nomi.length; i += 200) {
    const { data, error } = await db
      .from('documents')
      .select('document_id, file_name')
      .in('file_name', nomi.slice(i, i + 200));
    if (error) throw error;
    for (const r of data || []) mappa.set(r.file_name, r.document_id);
  }

  const righe = [];
  const orfani = [];
  for (const v of voci) {
    const id = mappa.get(v.file_name);
    if (!id) { orfani.push(v.file_name); continue; }
    righe.push({ document_id: id, tag_id: v.tag_id, punteggio: v.punteggio,
                 confidenza: v.confidenza, origine: v.origine });
  }

  for (let i = 0; i < righe.length; i += 500) {
    const { error } = await db.from('documento_tag')
      .upsert(righe.slice(i, i + 500), { onConflict: 'document_id,tag_id' });
    if (error) throw error;
  }
  console.error(`  Supabase: ${righe.length} assegnazioni scritte`);
  if (orfani.length) {
    console.error(`  ! ${new Set(orfani).size} file senza record corrispondente in documents (non scritti)`);
  }
  return { scritte: righe.length, orfani: [...new Set(orfani)] };
}

module.exports = { scriviSuSupabase, sincronizzaTassonomia };
