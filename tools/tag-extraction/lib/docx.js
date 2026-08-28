'use strict';
/**
 * lib/docx.js — estrae il testo da un .docx senza librerie di conversione.
 * Un .docx e' uno zip: il testo sta in word/document.xml, gia' in Unicode.
 * Si sostituiscono i fine-paragrafo con a capo e si tolgono i tag.
 */
const AdmZip = require('adm-zip');

function leggiDocx(percorso) {
  const zip = new AdmZip(percorso);
  const voce = zip.getEntry('word/document.xml');
  if (!voce) throw new Error('non e\' un .docx valido: ' + percorso);
  let xml = zip.readAsText(voce);
  xml = xml.replace(/<\/w:p>/g, '</w:p>\n');
  xml = xml.replace(/<w:tab[^>]*\/>/g, '\t');
  return xml.replace(/<[^>]+>/g, '').replace(/&amp;/g, '&').replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&apos;/g, "'")
            .replace(/[ \t]+\n/g, '\n').trim();
}

module.exports = { leggiDocx };
