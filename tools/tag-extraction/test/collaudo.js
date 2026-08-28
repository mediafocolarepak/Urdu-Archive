'use strict';
/** Collaudo minimo: `npm test`. Va eseguito dopo ogni modifica alla
 *  normalizzazione o alla tabella InPage: sono i due punti in cui un errore
 *  degrada la ricerca in silenzio, senza far fallire nulla. */
const assert = require('assert');
const { normalizza, CASI } = require('../lib/normalizza');
const { converti } = require('../lib/inpage');
const { costruisciPattern } = require('../lib/tassonomia');

let errori = 0;
function prova(nome, fn) {
  try { fn(); console.log('  ok   ' + nome); }
  catch (e) { errori++; console.log('  ERR  ' + nome + ' — ' + e.message); }
}

console.log('normalizzazione');
for (const [grezzo, atteso] of CASI) {
  prova(JSON.stringify(grezzo), () => assert.strictEqual(normalizza(grezzo), atteso));
}

console.log('decodifica InPage');
prova('ye mediana e finale', () => {
  // م + ye-auto + ں  ->  میں   |   ک + ye-auto  ->  کے
  const meN = Buffer.from([0x04, 0x9f, 0x04, 0xa5, 0x04, 0xa1]);
  const ke  = Buffer.from([0x04, 0x9c, 0x04, 0xa5]);
  assert.strictEqual(converti(meN), 'میں');
  assert.strictEqual(converti(ke), 'کے');
});
prova('alfabeto in ordine', () => {
  const buf = Buffer.from([0x04, 0x81, 0x04, 0x82, 0x04, 0x83, 0x04, 0x84]);
  assert.strictEqual(converti(buf), 'ابپت');
});

console.log('pattern');
prova("l'accento dattilografico trova entrambe le grafie", () => {
  const rx = costruisciPattern('Gesu Abbandonato', 'it');
  assert.ok(rx.test(normalizza("GESU'ABBANDONATO")));
  rx.lastIndex = 0;
  assert.ok(rx.test(normalizza('Gesù Abbandonato')));
});
prova('la ye urdu e\' tollerante', () => {
  const rx = costruisciPattern('یسوع متروک', 'ur');
  assert.ok(rx.test(normalizza('ےسوع متروک')));
});

console.log(errori ? `\n${errori} ERRORI` : '\ntutto ok');
process.exit(errori ? 1 : 0);
