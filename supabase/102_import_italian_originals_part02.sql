-- 102_import_italian_originals_part02.sql (2/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1578-1597 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1578, 'ITA', $doc1578$Sierre, 19.8.1982

TAGLIARE PER MEGLIO AMARE

Carissimi,

Siamo all’ultimo mese di quest’anno ideale nel quale in tutto il Movimento nel mondo s’è
cercato di approfondire e vivere la realtà del Risorto in mezzo a noi. In ottobre, infatti,
incomincia il nuovo. Il settembre ci invita a vivere una nuova Parola di Vita fortissima,
radicale, senza mezzi termini: “Se il tuo piede ti scandalizza, taglialo: è meglio per te entrare
nella vita zoppo, che esser gettato con due piedi nella Geenna” (Mc 9, 45).

Con queste parole Gesù non ci chiede certamente di mutilare le nostre membra, ma, usando
espressioni di questo genere, ci fa capire quanto sia esigente il suo insegnamento morale: di
fronte a circostanze che potrebbero farci cadere nel male, occorre tagliare e tagliare
decisamente.

Come vivere allora in questo mese?

Se fino ad oggi abbiamo cercato di cacciare le tentazioni cattive da qualunque parte
provenissero (dal mondo, dalla carne, dal demonio), in questo mese la nostra reazione deve
essere ancora più celere e più decisa. Tagliare subito senza pietà.

Ma per noi, che vogliamo percorrere sino alla fine della vita il Santo Viaggio, questo non
basta. Non è sufficiente evitare il male. Occorre anche fare il bene.

Quale? Quello che la volontà di Dio ci domanda nel presente.

E giacché siamo ancora nell’anno del Risorto in mezzo a noi, occorre, in modo particolare,
vivere bene l’unità, realizzando perfettamente il "farsi uno" con ogni prossimo tagliando
tutto ciò che lo può impedire.

Molti fattori possono compromettere questo nostro atteggiamento d’amore.

A volte sono le distrazioni, altre volte il cattivo desiderio di dire precipitosamente la nostra
idea, di dare inopportunamente il nostro consiglio. In altre occasioni siamo poco disposti a
farci uno col prossimo perché riteniamo che non comprenda il nostro amore, o siamo
frenati da altri giudizi al suo riguardo. In certi casi siamo impediti da un recondito interesse
di conquistarlo alla nostra causa.

Ancora: siamo incapaci di farci uno perché il nostro cuore è già occupato dalle nostre
preoccupazioni, dai nostri dolori, dalle nostre cose, dai nostri programmi. Come possiamo
allora farci uno, e come le preoccupazioni, i dolori, le ansie del fratello possono entrare in
noi?
È proprio necessario tagliare o posporre tutto quanto riempie la nostra mente e il nostro
cuore per farci uno con gli altri.

E allora, per concludere bene quest’anno, almeno come l’operaio dell’ultima ora,
ricordiamoci queste poche parole: tagliare per essere più liberi, più totalitari
nell’amore. Tagliare per meglio amare.

E se durante la nostra giornata saremo impegnati in ciò, non faremo solo con maggior
perfezione il bene, ma eviteremo anche il male, perché chi si fa uno ama, e chi ama non
pecca.

Avanti allora: tagliare per meglio amare.$doc1578$, 'drive_import', '01578-WEB-1982-08-19-tagliare-per-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1578)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1579, 'ITA', $doc1579$Sierre, 2.9.1982

SÌ A GESÙ, NO AL NOSTRO IO

Carissimi,

Abbiamo trascorso i primi quindici giorni di settembre cercando di "tagliare per meglio
amare" per metter in pratica la Parola: “Se il tuo piede ti scandalizza, taglialo” (Mt 18, 8). Ci
restano, ora, altre due settimane per approfondirla insieme, allo scopo di realizzare meglio
l’unità, nostra specifica vocazione, di far vivere, cioè, il Risorto in mezzo a noi.

Nei giorni scorsi, leggendo una pagina meravigliosa delle sue lettere, mi è parso di capire
come Paolo, l’Apostolo, vivesse personalmente i tagli di cui parla Gesù.

Dopo aver invitato i cristiani ad imitare gli atleti, che fanno tanti sacrifici per conquistare
una corona, parlando di sé, afferma: “Tratto duramente il mio corpo e lo trascino in
schiavitù perché non succeda che, dopo aver predicato agli altri, venga io stesso
squalificato” (1 Cor 9, 27).

Paolo doveva, infatti, coltivare il suo "grappolo", anzi le sue viti ricolme di grappoli, sparse
qua e là in tutte le regioni da lui evangelizzate. Ed ecco che cosa passa nella sua anima al
pensiero di tutte queste persone a lui affidate.

Avverte il desiderio, sente la spinta, l’esigenza di essere di esempio per tutti e per questo –
come dice – tratta duramente il suo corpo e lo trascina in schiavitù. È ciò che dobbiamo fare
noi col nostro io.

Si sta ribellando alla volontà di Dio? Non vuole lavorare come si deve, studiare a modo,
pregare con attenzione, accettare con amore qualche situazione un po’ pesante, forse
dolorosa?

Vorrebbe svincolarsi da quell’amore che si deve al prossimo? Parlar male di
qualcuno, non aver più pazienza con un altro, giudicarlo, vendicarsi almeno un po’?
È il momento di trattare duramente noi stessi, di dir di no senza compassione al
nostro io. Dir di no, di no, di no; dieci, venti volte al giorno Ma noi sappiamo che c’è
un modo tipicamente nostro per dirgli di no non soltanto dieci, venti volte al giorno,
ma tutto il giorno.
E quello di dir di sì a Gesù, alla sua volontà, di dir di sì ai prossimi, in tutto tranne nel
peccato, dir di sì sempre, sempre con tutto il cuore.

Questi sì a Gesù sono un solenne no al nostro io. Con questi sì a Gesù non lasciamo spazio al
nostro io, lo rendiamo schiavo. Questi sì a Gesù sono la tomba del nostro io.
E allora, in questi quindici giorni diciamo sempre si a Gesù nell’attimo presente e, se
qualcuno in noi si ribella, rendiamolo schiavo con un bel no.

Sì a Gesù, no al nostro io.$doc1579$, 'drive_import', '01579-WEB-1982-09-02-s-a-ges-no-al-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1579)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1580, 'ITA', $doc1580$Sierre, 16.9.1982

SERVIZIO CONCRETO

Carissimi,

Come sappiamo, l’unità fra noi, il Risorto vivo in mezzo a noi è lo stupendo, il divino, il
formidabile tema di quest’anno, il motivo per cui viviamo, la meta a cui tendiamo
costantemente.

Volendo però analizzare gli scopi del nostro Movimento, vediamo che il Risorto tra i suoi
membri non è solo l’impegno di un anno, ma il suo fine in ogni tempo, in ogni luogo.

Se, infatti, lo scopo specifico del nostro Movimento è di concorrere a realizzare sulla terra, in
tutti i modi, il Testamento di Gesù: “Che tutti siano una cosa sola” (Gv 17, 21), lo scopo
generale è la perfezione dell’amore, essere "perfetti nell’amore".

E siamo perfetti nell’amore quando abbiamo il Risorto in mezzo a noi.

Fa sempre profonda impressione la frase di san Giovanni evangelista, che dice: “Se ci
amiamo gli uni gli altri, Dio rimane in noi e il suo amore è perfetto in noi” (1 Gv 4, 12).
L’amore di Dio in noi è perfetto, se ci amiamo. Ma, se ci amiamo, il Risorto è fra noi.

Nell’unità col Risorto in mezzo a noi siamo perfetti e quindi santi, sicuri cioè di compiere
nella nostra vita un Santo Viaggio. Viviamo, dunque, sempre in maniera che il Risorto
splenda fra gli uomini.

Anche la nuova Parola di Vita, quella d’ottobre, può aiutarci in ciò. Essa dice: “Chi vuol
essere grande tra voi si farà vostro servitore” (Mc 10, 43).

Dobbiamo servire, servire il prossimo, ogni prossimo. Come? Come vuole Gesù, che pensava
ad un vero servizio concreto, quale lavare i piedi ai discepoli.

Certamente tutta la nostra vita può essere vista come un servizio concreto, sia che
esplichiamo un lavoro per il bene della società terrena, sia che operiamo per quello della
Chiesa.

La nuova Parola ci sollecita comunque a riempire la nostra giornata di servizi concreti, umili
e intelligenti, tutti quelli richiesti dal "farsi uno" con ogni nostro fratello, che durante essa
avviciniamo, come preparare la tavola, riassettare, fare qualche spesa, medicare, istruire,
consolare, donare qualcosa di nostro, ammonire con amore...

E, lo sappiamo: se ci facciamo uno con gli altri, presto o tardi si realizza l’amore reciproco e
il Risorto è in mezzo a noi. La Parola del mese ci aiuta perciò veramente a realizzare l’unità,
il nostro scopo, quello dell’anno in corso e di sempre, perché noi dell’Opera di Maria siamo
chiamati a generare, come la Madre nostra, Cristo fra gli uomini. E perché ciò sia, puntiamo
in questo mese sul servizio concreto. Ricordiamo: "servizio concreto" è la parola d’ordine.$doc1580$, 'drive_import', '01580-WEB-1982-09-16-servizio-concreto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1580)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1581, 'ITA', $doc1581$Rocca di Papa, 7.10.1982

COME P. KOLBE, PRONTI A MORIRE PER IL FRATELLO

Carissimi,

Siamo ancora nell’atmosfera di festa che ha caratterizzato la santificazione di P.
Massimiliano Kolbe.

I giornali ne hanno parlato, la televisione ha mandato in onda filmati, circolano sue biografie
vecchie e nuove. E anche noi ne siamo stati presi.

Ma quello che più ci ha impressionato, scorrendo una di queste biografie, è stato il
fatto che il nuovo santo (così vicino a noi per il suo appassionato amore alla
Madonna e per aver amato con la misura di Gesù, fino a dar la vita), di fronte ad un
prigioniero, destinato a morire di fame nel bunker della morte, sconosciuto a lui, ma
divenuto, in un momento presente della sua vita, suo prossimo, ha dimenticato ad
un tratto tutta la grande opera (che stava svolgendo non per suo interesse, ma in
favore del Regno di Dio), tutta la vasta attività editoriale, le sue cittadelle
dell’Immacolata, i suoi figli, le sue carte (l’ho visto, in una foto, davanti ad una
scrivania strapiena), per prendere il posto di un altro.

Non poteva P. Massimiliano Kolbe pensare che, con quell’Opera, che aveva fatto nascere
nella Chiesa, avrebbe potuto glorificare Dio più da vivo che da morto? Egli, invece, non ha
avuto esitazione ed ha offerto la sua vita per salvare quella di un padre di famiglia.

Carissimi, anche noi spesso durante il giorno svolgiamo compiti che sono importanti,
almeno ai nostri occhi. E a volte, mentre vi siamo applicati, veniamo "disturbati" – così
pensiamo noi – da qualche prossimo, che s’introduce nella nostra vita, imprevisto, a
chiederci qualcosa; o di persona, o attraverso il telefono o una lettera, o in altra maniera.

Allora, "gonfi" dell’importanza (così appare a noi) del lavoro che stiamo svolgendo, non lo
degniamo di uno sguardo, non poniamo attenzione ad una sua richiesta, lo rimandiamo,
quando non lo trattiamo poco bene.

Ed ecco P. Kolbe darci a questo proposito una solenne lezione. Non è così che si ama il
prossimo, non è così che si serve: di fronte ad ognuno dobbiamo saper dimenticare (anche
per pochi attimi, se il dovere ci chiama ad altro) tutto quanto facciamo di bello e di grande e
di utile ed esser pronti a farci uno con lui del tutto, a farci uno con la misura del saper
morire per l’altro. Questa è vita cristiana.

Come viviamo allora in questo mese la Parola di Vita che parla del servizio? Mettendoci in
animo d’esser pronti a morire verso tutti quelli per i quali svolgiamo il nostro lavoro
quotidiano ed in particolare verso quei prossimi che arrivano improvvisi.
Ripetiamo in cuor nostro:
“Come P. Kolbe, pronti a morire”.$doc1581$, 'drive_import', '01581-WEB-1982-10-07-come-p-kolbe-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1581)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1582, 'ITA', $doc1582$Rocca di Papa, 21.10.1982

FARCI UNO CON DIO SEMPRE DI PIÙ

Carissimi,

In questi ultimi mesi di Santo Viaggio abbiamo cercato di curare l'amore verso il
prossimo, il farci uno con tutti, in modo che, se l'amore diventava reciproco, il
Risorto potesse vivere in mezzo a noi. E ciò ha approfondito senz'altro anche il
nostro rapporto con Dio: sappiamo, infatti, come amore del prossimo e amore di Dio
s'accrescono reciprocamente.

In questo mese di novembre ci viene proposta, invece, una parola che sottolinea la fede, la
fede in Dio l'Onnipotente, la fede che ottiene grazie: “Va', la tua fede ti ha salvato” (Mc 10,
52).

Come metterla in pratica nel migliore dei modi?

Se abbiamo letto il commento, abbiamo visto come la fede, che fiorisce nel cuore
(condizione indispensabile perché Dio operi), non è che il primo passo verso ciò che
Dio vuole dall'uomo: è una fiducia che è già rapporto con Lui, ma che deve
approfondirsi e diventare comunione.

Se le cose stanno così, niente allora di meglio, per ben interpretare la volontà espressa da
Gesù in questa Parola, che coltivare durante il mese l'unione con Dio, andar a fondo in essa.
Così facendo del resto, si cerca senz'altro il Regno di Dio, e tutto viene di conseguenza:
cercando d'essere profondamente uniti con Lui, si cerca per davvero il suo Regno e i nostri
problemi troveranno soluzione, le grazie desiderate e chieste con amore, si otterranno.
Dunque: unione con Dio. “Andare in profondità”, dicono i Gen. Andare in profondità tutta la
giornata, facendo la sua volontà. Ma in questo mese puntare su quei momenti particolari nei
quali la nostra unione con Dio si esprime: far sgorgare veramente dal cuore le meravigliose
preghiere che ripetiamo al mattino, alla sera o quando andiamo a visitarlo nel tabernacolo;
che sia nostro quel dire e ridire a Maria per tante volte, col rosario, il nostro amore. Tuffarci
nell'unione con Lui durante la meditazione, per risentire quel vigore sempre nuovo che si
sprigiona nel nostro spirito quando leggiamo la Scrittura o approfondiamo la nostra
spiritualità o penetriamo i pensieri dei santi...

Tuffarci nell'unione con Lui per lo meno con quello slancio con cui in questi mesi passati ci
siamo fatti uno col prossimo: uno con Lui, facendo tutto tacere in noi per essere in grado di
cogliere la sua voce... Poi assistere alla Messa, ricevere la Comunione con tutto l'amore del
nostro cuore, coscienti e felici che lì abbiamo un dono proporzionato da offrire al Padre per
dirgli che lo amiamo, lo adoriamo, lo lodiamo; convinti che in Gesù, che viene sacrificato
sull'altare, abbiamo chi chiede perdono al Padre per noi, chi gli può dire un grazie accetto,
chi gli può domandare grazie con successo.

Così: essere fedeli a quei momenti che sono riservati direttamente a Dio.

Viverli perfettamente, intimamente ed esteriormente. Sì, anche il segno di croce bello, degno
di colui che si nomina. Anche la genuflessione ben fatta, quando occorre. Ché se tanto precisi
in tutto questo sono coloro che non conoscono ancora Gesù, ma cercano Dio dove possono,
che deve essere di noi?

Così, proprio così: tutto perfetto, con quella compostezza e dignità e convinzione che
irradiano, da se sole, la nostra fede.

E allora, se la comunione con Dio si perfezionerà, tutto il resto della nostra giornata non
tarderà a risentirne beneficamente. Col "treno" del nostro viaggio saliremo in alto più vicini
a Lui, e con l'amore che cresce, aumenterà la fede, faremo tutto d'accordo con Lui, gli
confideremo le angustie della vita e ci sentiremo ripetere: “Va', la tua fede ti ha salvato”.$doc1582$, 'drive_import', '01582-WEB-1982-10-21-farci-uno-con-dio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1582)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1583, 'ITA', $doc1583$Rocca di Papa, 4.11.1982

GRANDE FEDE PER MEGLIO AMARE

Carissimi,

“Va’, la tua fede ti ha salvato” (Mc 10, 52).

È questa la Parola di Vita che stiamo approfondendo in questo mese, e cerchiamo di vivere.

“Va’ la tua fede ti ha salvato”! Che importanza Gesù dà alla fede!
Noi, nella nostra spiritualità, siamo soliti sottolineare piuttosto l’amore, la carità. Ed
è giusto: la perfezione dell’amore è il primo scopo, infatti, della nostra vita. Ma se
questa è la nostra vocazione, pensiamo noi sufficientemente al contributo
insostituibile che può donarci la fede proprio per perseguire il fine per cui Dio ha
suscitato il nostro Movimento?
Per essere perfetti nell’amore noi cerchiamo di tendere alla sua perfezione giorno per
giorno, ora dopo ora, e siamo quasi al 700° giorno del nostro Santo Viaggio. E tutti, più o
meno, a seconda della nostra generosità, facciamo sforzi quotidiani per proseguire e,
quando abbiamo allentato la corsa, per riprenderci. Ma forse, pur sapendo che senza la
grazia di Dio non si combina niente in questo senso, viviamo la nostra tensione alla santità
facendo troppo calcolo sulle nostre forze, come fosse affare tutto nostro, proporzionato alla
nostra volontà. E, nonostante l’impegno quotidiano, ci vediamo comunque ancora carichi di
difetti: osserviamo, quando ci esaminiamo, che il risultato non è proporzionato allo sforzo e
soprattutto al lungo periodo d’impegno: più di 120 settimane di viaggio!

E allora? E allora ecco la Parola di Vita di questo mese, con la quale Gesù ci indica un
rimedio favoloso per “salvarci” – come dice Lui – non solo dai mali fisici, ma da quelli
morali: le nostre cattive abitudini, i difetti, gli attaccamenti, le debolezze, i vizi, che tuttora
sussistono in noi. Questo rimedio è la fede. “Va’, la tua fede ti ha salvato”.

È l’ora, è il momento per noi, di non lasciar cadere questo promettente invito di Gesù,
quest’occasione per far seri passi avanti.

È l’ora di ravvivare la fede.

In questi ultimi giorni di novembre sarà bene dare soprattutto questo scopo alla nostra
preghiera, cominciando dalla Messa e dalla Comunione: offrirle per ottenere da Dio d’esser
perfetti, perfetti nell’amore.

Chiediamo questa grazia con fede, con fede ardente, ravvivata dalla convinzione che, del
resto, non chiediamo se non ciò che Lui vuole da noi, e che Egli ci darà senz’altro se sarà
certo che le nostre sicurezze poggiano su di Lui, non su di noi.
Così. Allora, d’accordo!
Grande fede per meglio amare. Questo è il motto.$doc1583$, 'drive_import', '01583-WEB-1982-11-04-grande-fede-per-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1583)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1584, 'ITA', $doc1584$Rocca di Papa, 18.11.1982

A DIO PER IL FRATELLO

Carissimi,

Siamo nel mese di dicembre e la Parola di Vita, che deve illuminare il nostro Santo Viaggio in
questo mese, è: “Preparate la via del Signore, raddrizzate i suoi sentieri” (Mc 1, 3).

Il fatto è che il Signore sta per venire: s’avvicina infatti Natale, e la liturgia ci invita a
preparargli la strada.

Egli, entrato nella storia 2000 anni fa, vuol entrare nella nostra vita, ma la strada in noi è
irta di ostacoli. Occorre spianare le montagnole, rimuovere i massi. Quali sono gli ostacoli
che possono ostruire la strada a Gesù?

Sono tutti i desideri che sorgono nella nostra anima non conformi alla volontà di
Dio; sono gli attaccamenti che l’attanagliano.
Desideri minimi di parlare o di tacere, quando si deve fare diversamente; desideri di
affermarsi, di stima, di affetto. Desideri di cose, di salute, di vita... quando Dio non lo vuole.

Desideri più cattivi, di ribellione, di giudizio, di vendetta...

Essi sorgono nella nostra anima e l’invadono tutta. Occorre con decisione spegnere questi
desideri, togliere questi ostacoli, e rimetterci nella volontà di Dio e così preparare la via del
Signore.

Occorre – dice la Parola – raddrizzare i suoi sentieri.

Raddrizzare: così, proprio così. I desideri deviano il nostro cammino. Spegnendoli, ci
rimettiamo nel raggio del volere di Dio e ritroviamo la strada.

Ma c’è un sistema tipicamente nostro per essere sicuri di camminare su una via diritta, che
porta certamente alla meta: a Dio.

Essa ha un passaggio obbligato: si chiama il fratello. Ributtiamoci, in questo mese, ad amare
ogni fratello che incontriamo durante la giornata.

Accendiamo nel nostro cuore quell’ardentissimo e lodevolissimo desiderio che Dio
sicuramente vuole: il desiderio di amare ogni prossimo, facendoci uno con lui in tutto, con
amore disinteressato e senza limiti.

Disponiamoci, durante il mese, in questo atteggiamento soprattutto verso quelle persone
che, nella grande vigna di Gesù Abbandonato, l’Opera di Maria, formano il nostro "grappolo"
L’amore ravviverà rapporti e persone e non permetterà a desideri egoistici di sorgere, anzi
ne sarà il miglior antidoto.
Per Natale potremo preparare così, quale dono per Gesù che viene, il nostro frutto ricco,
succoso e il nostro cuore bruciato, consumato d’amore.

Il motto che saprà ricordarci questo proposito potrà essere, allora: a Dio per il fratello!$doc1584$, 'drive_import', '01584-WEB-1982-11-18-a-dio-per-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1584)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1585, 'ITA', $doc1585$Rocca di Papa, 2.12.1982

PER ESSERE CIÒ CHE SIAMO, ESSERE L’AMORE

Carissimi,

Siamo ancora nel mese di dicembre, mese di Avvento col Natale ormai alle porte. E
la Parola ci ripete. “Preparate la via del Signore, raddrizzate i suoi sentieri”.
Quindici giorni fa abbiamo parlato, infatti, di rialzi da abbassare, di montagnole, nella via
della nostra vita, da livellare... Ed è proprio a proposito di montagnole che vorrei oggi
comunicarvi l’impressione meravigliosa che m’ha fatto una frase di san Paolo.

Dice: “Togliete via il lievito vecchio per essere pasta nuova, poiché siete azzimi” (1 Cor 5, 7).

Cosa fa il lievito?

Il lievito gonfia. Avete presente quella sorta di biscotti, i crackers, con tutte le bollicine?
Sono del lievito, che per san Paolo, qui, è simbolo del male. Il male infatti sembra spiare i
nostri desideri, "appetiti", come direbbe Giovanni della Croce. Sembra riempire l’animo, ma
è solo un’apparenza. E Paolo invita a togliere questo gonfiore “perché – dice – siete azzimi” e
cioè... senza lievito.

Vien da domandarsi: come mai l’Apostolo chiede di togliere il lievito e afferma
contemporaneamente che siamo già senza lievito?

È qui, vedete, tutta la morale di Paolo: noi siamo già cristiani per la grazia, noi siamo già
l’amore (la grazia è l’amore di Dio in noi), noi siamo già puri (la grazia ci ha purificati, anzi ci
ha "divinizzati"), ma dobbiamo essere quello che siamo. Dobbiamo corrispondere a questa
grazia. Il cristianesimo, infatti, è azione misteriosa di Dio e insieme tensione continua
dell’uomo.

E potrete ancora chiedermi: come mai questa frase di Paolo t’ha fatto tanta impressione?
M’ha colpita perché vedo riassunto qui tutto il nostro Ideale, tutta la nostra spiritualità. Noi
non vogliamo nient’altro che essere ciò che già siamo: essere veri, autentici cristiani
singolarmente e corpo di Cristo collettivamente. Questo vogliamo. Proprio a ciò lo Spirito
Santo ci ha spinto, anche con l’Ideale: ad essere quello che siamo.

E allora, in attesa di Natale, cerchiamo di essere veramente ciò che siamo: essere l’amore
verso Dio prima di tutto, incarnando ogni attimo la sua volontà; ed essere l’amore verso
tutti, in modo tale da generare Gesù costantemente in mezzo a noi, come omaggio, il più
bell’omaggio, a Gesù Bambino nella sua festa e a Maria, sua Madre, che, così facendo, in certo
modo riviviamo.

Nell’amore è tutto: l’amore vince il lievito del male in noi, prepara una degna via a Colui che
viene. Perciò in questi giorni non dimentichiamo: essere ciò che siamo.
E questo potrebbe essere il motto: Per essere ciò che siamo, essere l’amore.$doc1585$, 'drive_import', '01585-WEB-1982-12-02-per-essere-ci-che-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1585)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1586, 'ITA', $doc1586$Rocca di Papa, 16.12.1982

1983

COGLIERE L’OCCASIONE

Carissimi,

Abbiamo trascorso il fine ’82 ed abbiamo iniziato l’83. Siamo, dunque, nei giorni dei bilanci e
dei propositi. Bilancio di due anni di tensione alla santità. Proposito di arrivare fino in
fondo: fino al giorno, cioè, nel quale potremo offrire a Maria il dono della nostra santità 22.

Ultimamente, guardando i] piccolo calendario, che ricorda ogni giorno gli amatissimi
“mariapoliti celesti” (così chiamiamo i nostri fratelli che non sono più su questa terra), ho
osservato che non c’è grande differenza fra il numero dei piccoli o dei giovani già arrivati (i
Gen 3 e i Gen 2) ed i più maturi (i volontari, i focolarini, i sacerdoti).

Anche quest’anno, con tutta probabilità, qualcuno di noi partirà e non è male se, per un
attimo almeno, pensiamo che potrebbe toccare a noi. Certamente presto o tardi, l’ora arriva
per tutti. E in questa prospettiva la vita che ci rimane (mesi, anni...) non può non apparirci
come una grande occasione, un’occasione unica, un’occasione da non perdere, nella quale
realizzare qualcosa di veramente bello, grande, santo. Ma come?

La Parola di Vita del mese di gennaio ci invita a riflettere su ciò che Gesù ha detto di se: “Io
sono... la Vita” (Gv 14, 6).

Gesù, così dicendo, intendeva parlare di quella Vita soprannaturale che è venuto in terra per
comunicare anche a noi: una vita straordinaria, che non muore, che dura sempre.

È con quella Vita che noi possiamo trasformare la nostra terrena in qualcosa di
meraviglioso, di divino, di grande; che possiamo concorrere al disegno che Dio ha
sull’umanità e produrre frutti straordinari, imperituri.

Per cogliere bene allora l’occasione della vita che abbiamo, dobbiamo far in modo di
innestare su di essa questa Vita superiore, che è Gesù stesso.

Il commento alla Parola di Vita ci indica tre fonti a cui attingere per attuare ciò.

Questa Vita arriva a noi attraverso la fede, che vuol dire adesione del nostro cuore a Cristo.
Arriva ancora attraverso l’Eucaristia. E, infine, ci è data mettendo in pratica le parole di
Gesù.
Io penso che noi, che seguiamo questo Collegamento, abbiamo la fede, così come penso che
tutti, più o meno spesso, ci nutriamo dell’Eucaristia. A queste fonti, dunque, già in qualche
modo attingiamo.

Dobbiamo piuttosto porre tutta la nostra attenzione, tutto il nostro sforzo, nel vivere le sue
Parole. Quali? Quelle che ogni mese ci vengono offerte.

In questi prossimi quindici giorni, sforziamoci di attuare quella che sta alla base del
cammino di tutto il nostro Movimento ed è il concentrato del cristianesimo: Amiamoci come
Lui ci ha amato. Gesù ci ha amato fino all’abbandono. Amiamo così anche noi ogni fratello
che incontriamo.

Per non perdere dunque la grande occasione della vita che ci resta, cogliamo ogni occasione
per amarci, con la sua misura, col vuoto cioè totale di noi, col farci uno fino in fondo con
tutti, in modo che il Risorto sia in mezzo a noi.

Offrire il Risorto al mondo, dar vita a Gesù, come Maria: questa è la straordinaria occasione
da cogliere.$doc1586$, 'drive_import', '01586-WEB-1982-12-16-cogliere-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1586)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1587, 'ITA', $doc1587$Sierre, 4.1.1983

CURARE LA SUA VIGNA

Carissimi,

“Io sono... la Vita” è la parola che Gesù ci ripete ancora in questa seconda metà del mese di
gennaio. E “Io sono... la tua vita!” sussurra anche a ciascuno di noi: “Io sono... la tua vita,
Gen”; “Io sono... la tua vita, focolarino!”, o sacerdote, o volontario, o religioso, o altro
membro del Movimento dei Focolari.

Sì, perché, per la grazia di Dio e la nostra corrispondenza, nei nostri cuori fiorisce la sua
Vita.

Noi, infatti, amando Dio e amando il prossimo, e lasciando, così, sviluppare l’amore
in noi, abbiamo dato la possibilità alla nostra personalità soprannaturale di
affermarsi, abbiamo permesso a Gesù di vivere in noi.
E questa sua vita è in noi. Essa è la cosa più preziosa che possediamo, che possiede ogni
cristiano coerente. Noi la possiamo percepire, in qualche modo, coi sensi dell’anima, quando
ad esempio, dopo aver amato il prossimo durante il giorno con perseveranza, rientriamo in
noi per pregare: Gesù è lì presente – lo avvertiamo – per accoglierci, per ascoltarci.

L’Opera di Maria è, lo sappiamo, la vigna di Gesù Abbandonato. E, singolarmente, ognuno di
noi è una vite. Vite, che ha la vita in sé: la vita che è Gesù: “Io sono... la Vita”.

Mi ha fatto grande impressione in questi giorni d’inverno vedere qui, nel Vallese, in
Svizzera, come sono coltivate le viti; a quante cure e a quali... discipline sono sottoposte.

Danno ottimo vino, è vero, ma che lavoro assiduo esse reclamano!

Le vedi lì in filari rettilinei, perfettamente equidistanti, perché ognuna sia ben esposta al
sole.

Le osservi ben potate di tutti i tralci superflui, perché uno solo, alle volte, porti il suo frutto
abbondante, i suoi grappoli succosi.

Sono legate solidamente ad un paletto, perché stiano dritte e non s’adagino sul suolo.

Hanno il terreno attorno ben ripulito dalle molte foglie cadute dopo la vendemmia. E, se
piccolissime, le puoi vedere addirittura protette e rivestite da una rete cilindrica. E altri
accorgimenti ancora!

Ho pensato a noi, alla pianticella di vite, alla vita di Gesù cresciuta in noi ed alle cure che le si
devono. Dobbiamo anzitutto tenerla al sole, ben esposta alla presenza di Dio nella preghiera,
quando dialoghiamo cioè con Gesù nel nostro cuore. Dobbiamo mantenerla ben potata di
tutti i tralci superflui, di tutte le attività cioè che vorremmo svolgere, ma non sono volontà
di Dio per noi.

Dobbiamo mantenerla solidamente legata a Gesù Abbandonato, che ci fa amare il dolore che
sopraggiunge o quello che ci impone la rinuncia.

Dobbiamo mantenerle attorno il terreno ben pulito, allontanando da noi quelle cose o
creature che sono state oggetto di tentazione nella nostra vita precedente: amicizie non
buone, piccoli vizi, programmi televisivi sconvenienti, oggetti inutili, vanità...

E, soprattutto, se la pianticella di vite è ancora minuscola in noi, dobbiamo proteggerla con
l’unità degli amici che condividono lo stesso Ideale, nella vita di focolare, di nucleo, d’unità,
di comunità.

Ecco, tutto questo dobbiamo fare in questi giorni che ci restano: coltivare bene la vita di
Gesù in noi, perché la grande vigna di Gesù Abbandonato nel mondo cresca e si sviluppi
sempre più verso l’"ut omnes".

Ma, giacché durante la giornata arriva da sé il momento della preghiera, del dolore, delle
rinunce da abbracciare; possono ritornare le tentazioni, i vecchi amori da vincere; viene
l’ora di andare in focolare o in comunità... per far tutto quanto ho detto e coltivare così la
nostra amatissima vite, basta buttarci tutti lì, in quanto Dio vuole da noi in ogni attimo
presente e ripetere in cuor nostro il pensiero di Papa Giovanni XXIII: “Devo far ciascuna
cosa... come se non avessi altro da fare, come se fossi nato solo per far bene questo...”.

Allora così: totalmente presenti in ciò che Dio vuole da noi nel presente, come non avessimo
altro da fare, come fossimo nati solo per quello.$doc1587$, 'drive_import', '01587-WEB-1983-01-04-curare-la-sua-vigna-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1587)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1588, 'ITA', $doc1588$Sierre, 20.1.1983

CON TE

Carissimi,

“Chi non va avanti, va indietro”: è questo il pensiero di san Bernardo e di diversi Padri per
quanto riguarda la vita interiore, il cammino verso la santità, o, con parole nostre, l’avanzare
nel Santo Viaggio.

“Chi non va avanti”, cioè non migliora, non sta fermo: ma va indietro.

Ecco perché abbiamo veramente bisogno di tenerci tutti legati, in cordata, per
aiutarci e stimolarci a camminare, a far sempre qualche passetto, e non minacciare
così di retrocedere.
Ci dà una mano poi in questo senso la Parola di Vita che – come sappiamo – è
“lampada per i nostri passi”.
Questo mese essa dice: “Sulla tua parola, getterò le reti” (Lc 5, 5). È la risposta di Pietro a
Gesù, che lo invitava a pescare.

Non era quello, certo, il momento propizio, anzi! Non esisteva, dunque, motivo umano per
accogliere l’invito di Gesù. Ma, giacché il discepolo aderisce per fede alla proposta del
Maestro, ecco la pesca miracolosa.

Anche noi siamo chiamati ad una pesca straordinaria, e ad essere pescatori, non tanto di
pesci, quanto di uomini, di tanti uomini: siamo chiamati all’"ut omnes".

E quale il modo per realizzare questa pesca? Dice Pietro: “Sulla tua parola”. Il mezzo, la
causa, il segreto della pesca miracolosa è credere a quanto dice Gesù, alla sua Parola, e
aderirvi.

La Parola dunque, che è “luce per il nostro cammino”, la Parola, che ci garantisce di non
indietreggiare, ma di avanzare, è quella che causerà anche la pesca miracolosa. Occorre
poggiare sulla Parola, star ben saldi in essa, rimanere in sua compagnia.

Ma su quale Parola di Gesù dobbiamo poggiare, a quale aderire? Senz’altro ad ogni Parola di
Gesù, e mese per mese cercheremo di farlo. In questo, in cui ci è offerta la possibilità di
scegliere, punteremo su Gesù stesso come Parola di Dio, anzi su Gesù crocifisso e
abbandonato, in cui abbiamo sempre ammirato la Parola pienamente dispiegata.

Aderiamo a Lui, dunque, in questi quindici giorni, restiamo con Lui durante tutto il giorno;
anzi nel momento presente, diciamogli: con Te.
Così facendo, Egli ci suggerirà gli atti di virtù da compiere, i tagli da operare, le
mortificazioni da praticare per morire a noi stessi ogni attimo e risorgere alla sua volontà.
Egli ci sarà di luce, specialmente (giacché il fratello è la nostra strada per arrivare a Dio), sul
come essere niente di fronte ai nostri prossimi per farci uno con loro e dar modo a Gesù così
di conquistarli al suo cuore.

Sarà Lui ad insegnarci perfettamente quella che noi chiamiamo la "tecnica dell’unità" che è
la nostra maniera di contribuire all’"ut omnes" e vedremo ripetersi, in qualche modo,
attorno a noi la pesca miracolosa.

Con Lui, dunque, è il motto che riassume il nostro impegno nell’attimo presente in questi
giorni. Con Te, Gesù crocifisso e abbandonato, per camminare in avanti perché: “Chi non va
avanti, va indietro”. "Con Te".$doc1588$, 'drive_import', '01588-WEB-1983-01-20-con-te-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1588)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1589, 'ITA', $doc1589$Rocca di Papa, 3.2.1983

RISCHIARE SULLA SUA PAROLA

Carissimi,

Siamo, dunque, sempre "in viaggio". Il tempo non si ferma, la meta si avvicina e noi non
possiamo star fermi.

È da più di due anni, infatti, che ci sforziamo di "camminare".

Ma quali gli effetti, i progressi?

Può essere che in qualche momento non per tutti siano completamente positivi: forse, dopo
una partenza entusiasmante, è calato un po’ l’ardore, è subentrata la stanchezza; o forse si
sente la necessità che succeda qualcosa che possa aiutarci a riprender con lena la corsa... E
in questo stato di sospensione, un po’ incerto, ecco che le cose, la famiglia, gli affari, il lavoro,
anche al servizio dell’Opera, ci hanno riassorbito. Così, di conseguenza, l’unione con Dio,
quella splendida, inconfondibile unione con Lui, che abbiamo a volte sperimentata come
una dolcezza ineguagliabile, come una forza sovrumana, non l’avvertiamo più.

Che fare?

Anche in questi casi, anche per questi casi, chi ci può aiutare è la Parola. In questo mese essa
ci dice ancora: “Sulla tua parola getterò le reti”.

Gesù, perché potesse sperimentare la potenza di Dio, ha chiesto a Pietro la fede: credere a
Lui e credere addirittura a qualcosa, umanamente parlando, di impossibile, anzi di assurdo:
pescare di giorno quando la notte era stata così avara.

Anche noi, se vogliamo che torni la vita, se desideriamo una pesca miracolosa di felicità,
dobbiamo credere e affrontare, se occorre, il rischio dell’assurdo che, alle volte, la sua
Parola comporta.

Lo sappiamo: la Parola di Dio è vita; ma si ottiene passando per la morte; è guadagno, ma si
ha perdendo; è crescita, ma si raggiunge diminuendo.

E allora? Come risolvere lo stato di stanchezza spirituale in cui possiamo trovarci?

Affrontando il rischio della sua Parola.

Spesso influenzati dalla mentalità di questo mondo, in cui viviamo, crediamo un po’ anche
noi che la felicità stia nel possedere o nel farsi valere; nel darsi al divertimento o nel
dominare sugli altri, nell’apparire, nell’accontentare i sensi: nel mangiare, nel bere... Ma non
è così.
Proviamo ad affrontare il rischio del taglio a tutte queste cose; lasciamo che il nostro io
corra il rischio della morte completa. Rischiamo, rischiamo! Una, due, dieci volte al giorno.

Che succederà? Alla sera sentiremo rifiorire, dolce, nel cuore l’amore; ritroveremo l’unione
ormai insperata con Lui; risplenderà la luce delle sue inconfondibili ispirazioni; ci invaderà
la sua consolazione, la sua pace e ci risentiremo sotto il suo sguardo di Padre. E, avvolti così
dalla sua protezione, rinascerà in noi la forza, la speranza, la confidenza, la certezza che il
Santo Viaggio è possibile; che la nostra non è stata che una sosta; sentiremo la sicurezza che
il mondo può esser suo.

Ma occorre rischiare la morte, il nulla, il distacco. È questo il prezzo!

Coraggio allora: il motto di questi quindici giorni sia: rischiare sulla sua Parola per una
pesca miracolosa di felicità e di cuori che lo amino.$doc1589$, 'drive_import', '01589-WEB-1983-02-03-rischiare-sulla-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1589)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1590, 'ITA', $doc1590$Rocca di Papa, 17.2.1983

COME FOSSI SUA MADRE

Carissimi,

Spero proprio che siamo tutti in cammino. E, se per qualcuno c’è stata una tregua, è da
augurarsi che si sia ripreso bene, che abbia capito che su questa terra l’atteggiamento di
fondo, che dobbiamo tenere, è quello d’esser sempre pronti a ricominciare, ringraziando Dio
che ce ne dà ancora il tempo.

Dunque: avanti nel Santo Viaggio! È troppo importante! Importante per noi e per
molti. Per la Comunione dei santi, che ci lega tutti, infatti, chi sta "su" – come si dice –
chi sta nella tensione dell’amore, tien "su" tanti altri, che, magari, senza quell’aiuto,
si sarebbero lasciati sommergere dai flutti del mare di questo mondo. Sì, perché di
mondo si tratta; è mondo spesso, purtroppo, quanto ci circonda: quel mondo per il
quale Gesù non ha pregato; nel quale siamo, ma del quale noi cristiani non
dobbiamo essere.
Ora ciò che ci aiuta, la cengia che ci permette di camminare in alto, verso la cima del monte
della perfezione senza precipitare, è la Parola.

In questo mese di marzo essa ci dice: “Chi di voi è senza peccato, scagli per primo la pietra”
(Gv 8,7). L’ha detta Gesù a coloro che volevano lapidare l’adultera.

Il punto centrale dei comandi di Gesù è proprio sempre l’amore. Per questo Egli non vuole
che noi cristiani condanniamo: “Non giudicate”, ha ammonito infatti, e ha proclamato: “Beati
i misericordiosi”. Gesù vuole misericordia.

Tuttavia dalla sua Parola sembrerebbe di poter dedurre che qualcuno può scagliare la
pietra: chi è senza peccato.

Non si tratta certamente di noi, di ciascuno di noi, che siamo peccatori.

Ma c’è una creatura senza peccato. Lo sappiamo: è la Madre di Dio.

Potrebbe, dunque, Maria scagliare la pietra verso qualcuno che ha errato? E l’ha forse fatto
nella sua vita? Noi conosciamo la Mamma nostra. Sappiamo ciò che afferma la Scrittura, ciò
che tramanda la Tradizione, quello che è il pensiero del Popolo di Dio nei suoi confronti:
Maria è amore verso tutti gli uomini, è misericordia, è avvocata dei più miserabili.

È a Lei che cristiani senza numero ricorrono, e son sempre ricorsi, quando hanno avuto
l’impressione che la giustizia di Dio li sovrastasse.
Maria non scaglia pietre. Anzi: nessuno come Lei, dopo Gesù, diffonde amore.

Diffonde amore. Perché?

Perché è Madre. Una madre non sa che amare

E l’amore della madre è tipico: ama i propri figli come sé, perché c’è qualcosa di sé,
veramente, nei suoi figli.

Penso che in nessun modo potremo vivere meglio questa nuova Parola che imitando Maria.

Anche noi possiamo trovare qualcosa di noi stessi negli altri. Dobbiamo, infatti, vedere Gesù
sia in noi che nei nostri fratelli.

E allora, come ci comporteremo?

Ecco: di fronte ad ogni prossimo: in casa, al lavoro, per strada, con quello del quale stiamo
parlando, con le persone con cui ci intratteniamo al telefono, con quelli a vantaggio dei quali
esplichiamo il nostro lavoro, di fronte ad ognuno, in questi quindici giorni, dobbiamo
pensare semplicemente: devo comportarmi come fossi sua madre. E agire di conseguenza.

Una madre serve, serve sempre. Una madre scusa, scusa sempre. Una madre spera, spera
sempre.

"Come fossi sua madre": questo il pensiero che deve dominare nei prossimi quindici giorni.

Questo il nostro impegno per esser certi di non scagliare pietre e per poter essere per tutti
la presenza di Maria sulla terra.$doc1590$, 'drive_import', '01590-WEB-1983-02-17-come-fossi-sua-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1590)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1591, 'ITA', $doc1591$Rocca di Papa, 3.3.1983

COME MISURIAMO SAREMO MISURATI

Carissimi,

Stiamo vivendo ancora la Parola: “Chi di voi è senza peccato, scagli per primo la pietra” (Gv
8, 7) e, per viverla bene, i giorni passati abbiamo guardato a Maria che, essendo madre
nostra, non giudica, ma scusa sempre i suoi figli e spera sempre, spera fino alla fine.

Questa Parola dice, infatti, ciò che è centrale nel messaggio evangelico: l’amore di Dio per
l’uomo. Dio lo vuole salvo. Per questo ha offerto lo stesso suo Figlio.

Ma se Dio ama così gli uomini, anche noi dobbiamo fare altrettanto gli uni verso gli altri.
Così saremo, oltretutto, in piena vocazione, perché l’amore verso il prossimo costituisce il
cuore della nostra spiritualità.

Continuiamo, allora, anche i prossimi quindici giorni su questa linea. Faremo certamente
passi avanti nella via della santità.

E, per meglio praticare questo amore che tutto scusa, tutto spera, tutto crede, ricordiamoci
che un giorno esso avrà un peso determinante sul giudizio che Dio pronuncerà su di noi.

Spesse volte il pensiero della morte ci è amaro perché temiamo il giudizio di Dio. Esso ci
appare una vera incognita e noi ne abbiamo paura al ricordo dei nostri peccati.

Se però credessimo alle parole di Gesù, noi potremmo, in certo modo, condizionarlo
decisamente e sapere, già fin d’ora, quello che ci succederà. Egli ha detto: “Con la misura con
la quale misurate sarete misurati” (Mt 7, 2) e “Beati i misericordiosi perché troveranno
misericordia” (Mt 5, 7).

Il nostro comportamento verso il prossimo è come un bumerang che va e torna,
ripercuotendosi su di noi. Va un giudizio severo? Torna un giudizio severo. Va la
misericordia? Torna la misericordia. Misuriamo il prossimo attenuando le sue
responsabilità? Saranno attenuate le nostre. Misuriamo, cercando di cogliere l’aspetto
buono della questione, scusando, non ergendoci comunque noi a giudici, nemmeno dei casi
più palesi, ma lasciando ogni verdetto a Dio? Così farà Dio con noi.

In questi quindici giorni comportiamoci in questo modo con ogni prossimo di cui stiamo
parlando, anche con quelli che ci passano sott’occhio leggendo i giornali e guardando la
televisione; con le persone semplici, o con le persone pubbliche; con tutti. Come misuriamo
saremo misurati.$doc1591$, 'drive_import', '01591-WEB-1983-03-03-come-misuriamo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1591)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1592, 'ITA', $doc1592$Rocca di Papa, 17.3.1983

SPALANCARE IL CUORE ALLA CROCE, PER SPALANCARLO A GESÙ

Carissimi,

Come saprete dall’"Aggiornamento", il Lunedì Santo sono stata invitata a pranzo dal Santo
Padre Giovanni Paolo II. Con me era Eli.

Alla fine, prima di congedarci, ci ha voluto far dono d’un bellissimo libro riguardante
quattordici dei suoi viaggi, dal titolo Spalancate le porte a Cristo.

In riferimento a questa frase, il Santo Padre, manifestando tutta la grande fiducia,
che pone nel nostro Movimento, ha detto: “Il Papa lo grida e i focolarini lo attuano”.
Carissimi, noi certo non meritiamo questo elogio. Dobbiamo però comportarci in
maniera da esserne degni.
“Spalancare le porte a Cristo”. Che significa? E come si fa?

Io credo che nessuno apra meglio il cuore a Gesù di colui che lo spalanca di fronte alla croce,
a Lui crocifisso.

È con l’abbraccio alla croce, infatti, che il Risorto può vivere pienamente in noi, in ciascuno
di noi. È questo un argomento che analizzeremo a fondo un altro anno. Ma ciò non ci
impedisce di assaporarlo fin d’ora e di metterlo in pratica.

Il Risorto nel nostro cuore! Certamente, colui nel quale Egli vive ha spalancato il suo cuore
alla croce, al Suo grido. Non si può parlare, infatti, di risurrezione se non supponendo la
morte.

Ecco allora come dobbiamo comportarci in questi quindici giorni: individuare dove si trova
la nostra croce del momento presente, spalancarle il cuore ed abbracciarla.

A volte sarà un dolore personale imprevisto e improvviso. A volte qualche sofferenza di chi
ci sta accanto. Altre volte le croci della specifica nostra vocazione: le barriere fra caratteri
diversi, le disunità fra i cristiani, il senso di lontananza con chi non ha la nostra fede, il
freddo del mondo individualista e materialista che ci circonda. In altre occasioni sarà il
dolore che comportano le virtù ben praticate come la purezza, la pazienza, la mansuetudine,
la misericordia e così via.

Spalanchiamo dunque il cuore a tutte queste croci e sarà questo il miglior modo per
spalancarlo a Gesù. In questi giorni ho avuto una profonda gioia per aver conosciuto
l’esperienza del Santo Viaggio di una persona che cammina con noi. Essa mi ha confidato
che circa due anni fa – prima che iniziasse il Collegamento – le era nato in animo il desiderio
che Gesù fosse al primo posto nel suo cuore. Avvertiva infatti che così non era.

Ora, dopo questi anni di tensione alla santità, le sembrava di percepire che quell’aspirazione
stava diventando realtà. Poteva, infatti, costatare, almeno in alcuni momenti o tratti della
sua giornata, che ciò che più le interessava era Lui, proprio Lui. E attribuiva questo risultato
all’aver cercato di amare sul serio Gesù Abbandonato.

In questi prossimi giorni, allora, dobbiamo tutti sforzarci di fare altrettanto: spalancare il
cuore alla croce per spalancarlo a Gesù.$doc1592$, 'drive_import', '01592-WEB-1983-03-17-spalancare-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1592)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1593, 'ITA', $doc1593$Rocca di Papa, 7.4.1983

RICOMINCIARE DA CAPO

Carissimi,

Tempo fa il Priore di Taizé, Roger Schutz, mi ha confidato in un colloquio che, frequentando
le persone del nostro tempo e specie i giovani, s’era reso conto di quanto il mondo fosse
completamente scristianizzato, al punto da non sapere da quale parte cominciare per
riportarvi Gesù.

È questa in realtà, sovente, anche la mia triste impressione: mentre 30-40 anni fa la
nostra società (e qui mi riferisco soprattutto all’Europa) era fondamentalmente
cristiana, e poggiava quindi su principi solidi, ora non è più così. È subentrata una
mentalità secolarizzata, materialistica, e, dato che la maggior parte degli uomini la
pensa in modo praticamente pagano, si crede che sia giusto così.
Prevalgono, ad esempio, l’idea e la pratica del divorzio, dell’aborto, di certi comportamenti
prematrimoniali, delle convivenze libere? Si giudica tutto ciò come il normale modo di
vivere e per questo si pensa lecito. Si trascura il lavoro, si approfitta del prossimo, si ruba
allo Stato? Dunque si può fare... E qui potremmo enumerare tutte le espressioni dell’"uomo
vecchio" di questi tempi, che fanno del nostro un mondo vecchio. E sarebbe per noi
interessante elencare soprattutto le manifestazioni più sottili che possono essere penetrate
anche nel nostro comportamento, come il dar valore al possedere, al prestigio... come gli
attaccamenti a mille cose materiali o, più ancora, spirituali, come la fuga dal sacrificio, dal
dominio di sé, ecc.

Il guaio è che tale mentalità si è progressivamente diffusa ed è così penetrata dappertutto, in
modo speciale attraverso i mass media, che vi ci troviamo immersi senza rendercene conto.

E abbiamo allora il doloroso fenomeno che i nostri stessi giovani, a volte, confessano
candidamente di non saper discernere il bene dal male e di perdere persino il concetto di
peccato.

“Per alcuni – ha detto infatti recentemente il Papa – la parola peccato è diventata
un’espressione vuota”, “Per altri il peccato si riduce all’ingiustizia”, “Per altri ancora il
peccato è una realtà inevitabile”; altri infine pur ammettendolo interpretano “in modo
arbitrario la legge morale” (Oss. Rom., 16 aprile 1983).

Sì, questa è la situazione, la grave situazione in cui viviamo. Come comportarci? Come
reagire?
All’angosciosa domanda del Priore di Taizé ho cercato di rispondere dicendo che l’unica
cosa da fare in questi casi è quella di ricominciare da capo. Sì, proprio così: cominciare,
come hanno fatto i primi cristiani, che tuttavia si sono diffusi nel mondo in poco tempo,
facendo conoscere il Vangelo a molti popoli.

Essi hanno vinto il mondo pagano d’allora perché avevano chiare due cose: che il
cristianesimo è soprattutto amore, amore reciproco, e che essi erano nel mondo, ma non
erano del mondo.

Carissimi, anche noi sappiamo che Gesù ha portato l’amore e cerchiamo invero di viverlo.

Forse però non abbiamo sempre chiaro che al mondo in cui siamo, al suo modo di pensare,
noi non possiamo e non dobbiamo appartenere. Noi non siamo del mondo, nemmeno di
questo nostro mondo del XX secolo. Noi siamo di un regno diverso.

E allora? Continuiamo a lanciare la nostra rivoluzione d’amore e guardiamo al
mondo e a tutto quanto lo riguarda con spirito critico.

La parola di questo mese, “È meglio obbedire a Dio, piuttosto che agli uomini” (At 5, 29),
letta in senso spirituale potrà esserci d’aiuto, potrà darci una mano.

Sì, nell’attimo presente, quando le molte pressioni del mondo vorrebbero piegarci al suo
modo di pensare e di agire, reagiamo con tutte le nostre forze; facciamo trionfare in noi
l’uomo nuovo che stima l’amore, le altre virtù e la croce.

Se in noi, che siamo tanti, l’uomo nuovo vincerà, anche un mondo nuovo non sarà
irrealizzabile.

Ma dobbiamo, con lo zelo dei primi cristiani, ripeterci ogni giorno, ogni momento: “È meglio
obbedire a Dio, piuttosto che agli uomini”.$doc1593$, 'drive_import', '01593-WEB-1983-04-07-ricominciare-da-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1593)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1594, 'ITA', $doc1594$Rocca di Papa, 21.4.1983
PER VIVERE LA PAROLA SCEGLIERE LA CROCE

Carissimi,
Quello che desidero fare oggi è incoraggiarvi una volta di più a perseverare nel Santo
Viaggio.
Non dobbiamo fermarci mai. Lo sapete: “Chi non va avanti, va indietro”. E dato che spesso ci
fermiamo, perché siamo peccatori, deve diventare nostra abitudine ripetere a Gesù, ogni
volta che occorre: “Perdono, ricomincio”.
Ricomincio a far che cosa? Ricomincio a vivere la Parola, perché la Parola è “luce ai nostri
passi”.
È la Parola che ci potrà portare a concludere felicemente un buon cammino: che ci farà
raggiungere la santità.
Dobbiamo, dunque, amare la Parola.
Essa è per i cristiani di una enorme importanza
In questi giorni m’ha fatto una certa impressione una frase di Gesù colla quale Egli, dopo
aver affermato di non essere venuto al mondo per giudicare gli uomini, ma per salvarli, dice
che c’è chi li giudicherà l’ultimo giorno: la Parola.
Ci troveremo in quel tremendo attimo conformi alla Parola? Saremo cioè, in pratica, Parola
vissuta? Tutto andrà bene per noi. Sarà il contrario? Dovremo sottostare al suo giudizio.
Anche se ora, dunque, non prendiamo in considerazione la Parola, verrà il momento che
dovremo confrontarci con essa.
E allora, se non è l’amore che ci spinge a viverla, deve essere almeno il timore.
Amare, dunque, la Parola o, almeno, temerla.
Il mese di maggio ci incoraggia a ciò. Esso ci annuncia: “Se uno mi ama, osserverà la mia
parola e il Padre mio lo amerà e noi verremo a lui e prenderemo dimora presso di lui” (Gv
14, 23).
“Se uno mi ama, osserverà la mia parola...”.
Gesù vuole, dunque, che amiamo la sua Parola, le sue Parole. E se così facciamo ci annuncia
promesse enormi: la Trinità prenderà dimora in noi.
E quale Parola prendere in rilievo in questi quindici giorni? Una che in qualche modo le
riassuma tutte. Leggendo in questi mesi san Giovanni della Croce, e meditando su tutte le
ascensioni dell’amore di questo impareggiabile mistico, fino a quella che si chiama l’unione
trasformante, che conclude il suo viaggio verso la santità, mi sono resa conto ancor una
volta che il segreto dei santi, e quindi della loro straordinaria esperienza, vero anticipo del
Paradiso, è la scelta della croce.

Credo che qui, in questa scelta, sia concentrato quanto Gesù vuole da noi. Rinnoviamo
perciò oggi incondizionatamente il nostro amore a Gesù Abbandonato nei dolori che
sopravvengono e nel vincere noi stessi.$doc1594$, 'drive_import', '01594-WEB-1983-04-21-per-vivere-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1594)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1595, 'ITA', $doc1595$Rocca di Papa, 3.5.1983

PORTAR MOLTO FRUTTO PER DAR GLORIA A DIO

Carissimi,

Il mese di maggio ci invita ancora a vivere la Parola affinché la Santissima Trinità prenda
dimora più stabile nella nostra anima.

Vi voglio perciò comunicare una considerazione, che ho fatto in questi giorni
riguardo ad un particolare insegnamento di Gesù.
Non so se succede anche a voi, ma di tanto in tanto io sento il desiderio che la mia vita sia
veramente una gloria a Dio, e perciò di conoscere la strada per realizzare meglio ciò.

Finora la risposta la trovavo soprattutto nei santi, che mi assicuravano che chi fa la volontà
di Dio dà gloria a Dio e gli dà gioia.

In questi giorni, seguendo la Messa col messalino mi ha colpito, invece, profondamente una
frase chiarificatrice di Gesù riportata da san Giovanni

“In questo è glorificato il Padre mio: che portiate molto frutto e diventiate miei discepoli”
(Gv 15, 8). Leggendo questa Parola, mi sono resa conto che, attraverso il Collegamento, ci
siamo incoraggiati spesso a viverne la seconda parte, che sottolinea la necessità di divenire
suoi discepoli: “...e diventiate miei discepoli”. Noi, infatti, parliamo e ci sforziamo di
rinnegare noi stessi e portare la croce come condizioni, che conosciamo indispensabili, per
poter seguire il Cristo.

La prima parte, invece, e cioè la necessità di portar frutto, non è stata da noi finora
egualmente messa in rilievo. Mentre è proprio coll’attuare l’una e l’altra cosa che si dà gloria
al Padre.

Oggi vorrei sottolineare la necessità di portar frutto. E qui viene subito in rilievo quanto sia
importante quel dono, che tutti i membri del nostro Movimento hanno, quel loro tipico
modo di portar frutto per il quale molti spendono gioiosamente le loro migliori energie: il
dono, la capacità di comunicare ad altri il proprio "Ideale", mettendo in atto "la tecnica
dell’unità", come si dice, fino a generare Gesù in mezzo agli uomini, quel Gesù che converte i
cuori, e la possibilità di diventar così padri e madri di anime.

Questa volta Gesù, col suo Vangelo, ci conferma che così facendo si glorifica
veramente il Padre: “In questo è glorificato il Padre mio: che portiate molto frutto e
diventiate miei discepoli”.
Carissimi, nei prossimi quindici giorni dobbiamo impegnarci in modo tutto particolare a
portare frutto con la gioia di sapere che così diamo gloria a Dio. E dobbiamo esaminare tutte
le possibilità che abbiamo perché esso sia come Gesù lo vuole: “molto”. Sarà forse
necessario allora rinnovare il nostro amore verso qualche prossimo: o dovremo riprendere
contatti perduti. Forse ci sarà da impegnarsi a curar meglio qualche persona del nostro
"grappolo" o a perfezionare l’operazione "uno per uno". Ci sarà chi sentirà la necessità di
lanciarsi con più lena ad annunciare l’"Ideale" in posti nuovi...

Esaminiamo tutto. Programmiamo generosamente secondo le possibilità di forze e di
tempo, e siamo fedeli.

Ogni sera, prima di addormentarci, chiediamoci: Ho portato frutto, oggi? E ne ho portato
molto? Se la risposta sarà sì, confortiamoci: abbiamo dato gloria a Dio.$doc1595$, 'drive_import', '01595-WEB-1983-05-03-portar-molto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1595)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1596, 'ITA', $doc1596$Rocca di Papa, 19.5.1983

ESSERE PARTNER, ESSERE SICURI

Carissimi,

Se si gira per molte strade svizzere, in questo tempo, ci si può imbattere in un grande
cartellone assai grazioso. Vi sono raffigurate due macchine, una azzurra e una rossa, che
procedono insieme, si sorridono e si salutano. L’azzurra fa cenno con una mano alla rossa di
passare. La rossa, alzando il cappello, ringrazia. Una scritta commenta: “essere partner,
essere sicuri”, che significa: aiutarsi, trattarsi da soci, da amici, è garanzia di un viaggio
senza pericoli.

Ho pensato che questo motto, preso in senso cristiano, non vale solo per correre sulle strade
di questa terra, ma può esser di aiuto per il Santo Viaggio che abbiamo intrapreso. Per chi
poi è chiamato, come noi, alla via dell’amore, è senz’altro il modo più sicuro, anzi la via
obbligata per arrivare alla meta. Nell’aiuto al fratello sono, infatti, riassunti tutti i nostri
doveri. Lo conferma la Parola del mese di giugno, una di quelle parole della Scrittura,
incentrate sull’amore, che risuonano in noi in modo particolare: “Tutta la legge trova la sua
pienezza in un solo precetto: amerai il prossimo tuo come te stesso” (Gal 5, 14).

Se le cose stanno così, tensione alla santità significa porre tutta la nostra attenzione, il
nostro sforzo, nell’amare il fratello. Il cercare la santità infatti, per noi, non consiste tanto
nel toglierci i difetti uno per uno, quanto nell’amare, nel pensare agli altri, dimentichi
completamente di noi stessi. Si diceva già i primi tempi: ci sono due modi per aver una
stanza pulita: o scopare quella in cui noi siamo, o cambiare stanza. E si avvertiva che questa
era la nostra linea: cambiare stanza e cioè non vivere più noi, ripiegati su di noi, ma vivere
gli altri, i prossimi, per amarli. Ma si sa: chi ama il fratello, chi vive nell’altro, s’accorge ben
presto che non è più lui in realtà che vive in se stesso, ma Cristo in lui. Gesù vive nel suo
cuore. E chi è Gesù? È la santità. Noi troviamo la santità in Gesù, che fiorisce in noi perché
amiamo. La santità viene come conseguenza dell’amare. E noi non possiamo raggiungerla
che in questa maniera. Se cercassimo la santità per se stessa non la raggiungeremmo mai.
Amare, dunque, e null’altro.

Perdere tutto, anche l’attaccamento alla santità, per tendere solo ad amare. Solo così
potremo un giorno far di essa un dono a Maria.

Come vivere allora questi quindici giorni?

Oggi ripartiamo come fosse il primo giorno della nostra rivoluzione d’amore e il primo
giorno del nostro Santo Viaggio. Ripartiamo senza pensare a null’altro, perché nell’amore è
tutto. Viviamo disponendoci ad amare ogni nostro prossimo come noi stessi e per questo
nell’atteggiamento costante di "calarci" in ogni singola situazione.
Ricordiamo: essere partner - essere sicuri. Sicuri che quanto facciamo è il meglio che
possiamo fare. Sicuri che, così agendo, viviamo secondo il nostro Ideale; sicuri di amare Dio
e di trovare nell’amore al fratello anche tutte le altre virtù; sicuri che ci facciamo santi.
Essere partner - essere sicuri.$doc1596$, 'drive_import', '01596-WEB-1983-05-19-essere-partner-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1596)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1597, 'ITA', $doc1597$Rocca di Papa, 2.6.1983

SERVIZIO PERFETTO

Carissimi,

Siamo ancora nel mese di giugno, che irradia in tutto il Movimento la luce della Parola:
“Tutta la legge trova la sua pienezza in un solo precetto: amerai il prossimo tuo come te
stesso” (Gal 5,14). La volta scorsa al Collegamento, colpiti da questa lapidaria affermazione
di Paolo, abbiamo detto che per noi amare il fratello è tutto.

Sì, è proprio tutto.

Ma perché è tutto? Come mai nell’amare il fratello sentiamo di poter realizzarci
pienamente?

Lo possiamo perché per noi amare il fratello è trovare Dio; percorrere la "via del fratello" è
raggiungere il Signore. E Dio, il Signore, è il nostro Ideale.

L’abbiamo sperimentato ormai da quasi quarant’anni: penetrare, attraverso la vita del
fratello, che a volte è un’oscura galleria piena di dolore, di dubbi, d’angoscia, è come
attraversare con l’anima il purgatorio per sfociare in una più chiara visione del Cielo, in
un’esperienza più sentita del divino. L’amore al fratello porta inevitabilmente all’amore di
Dio.

Questa è la strada che il nostro Ideale, il carisma del Movimento, ci ha sempre indicato.
Questa la via che la Chiesa, la quale riflette la volontà di Dio, ha suggellato quando, dopo
aver a lungo studiato lo scopo per cui ci ha suscitato, ha sentenziato che Egli ci chiamava ad
essere "perfetti nell’amore".

Ecco: perfetti nell’amore; perfetti, dunque, anche noi! Perfetti, che significa santi, ma santi
nell’amare.

C’è chi Dio chiama a farsi santo, a raggiungerlo, attraverso l’orazione; chi attraverso la
pratica delle singole virtù; chi con la predicazione e così via. Tutte cose che anche noi
certamente non dobbiamo trascurare. Ma la via, la via maestra per noi resta l’amore al
fratello.

Dobbiamo dunque santificarci, sì, far della vita un Santo Viaggio, ma nell’amore.

Del resto: come potremmo noi lavorare per il “che tutti siano uno”, senza scatenare la nostra
rivoluzione d’amore? Non è l’amore l’unico capace di legare in unità, di far vivere al Corpo
Mistico la sua realtà? Come potremmo noi porre quel fondamento essenziale ed
imprescindibile alla nostra vita spirituale ed apostolica, che è il Risorto presente fra noi,
senza l’amore?
Sì, noi stessi, il nostro Movimento, non siamo pensabili se non nell’amore, con l’amore,
perché questa nostra vita è fiorita da una rinnovata manifestazione di Dio che è Amore.

Carissimi, il nostro compito, dunque, è amare. È lì che dobbiamo cercare la nostra
perfezione. Anzi, occorre andare di perfezione in perfezione nell’amare il prossimo al quale
durante il giorno ci dedichiamo: curare bene il pranzo che dobbiamo preparare, la lezione
della classe in cui insegniamo, il discorso che bisogna stendere, le pratiche che dobbiamo
sbrigare...

E, se ci sembra che quanto facciamo è solo diretto al nostro personale vantaggio, come è lo
studio per i Gen 3, per i Gen 2, pensiamo subito che noi vogliamo apprendere bene quelle
materie o quell’arte per essere più utili domani a Gesù che vive nella nostra società.

Tutto dobbiamo fare con perfezione, e per questo ascoltare bene quella voce dentro di noi,
finché ha qualcosa da rimproverarci, da suggerirci.

Ascoltare bene e fare opere perfette. I santi, quando raggiungono l’ultimo gradino che si
chiama "unione trasformante", perché sono ormai un tutt’uno con Gesù, hanno diverse
qualità. Una di queste è la capacità di fare opere perfette.

Sforziamoci anche noi di amare sin da ora con perfezione, e ciò vuol dire: servizio perfetto al
fratello.

Far della nostra vita un servizio perfetto sia lo sforzo costante nei prossimi quindici giorni.$doc1597$, 'drive_import', '01597-WEB-1983-06-02-servizio-perfetto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1597)
on conflict (document_id, language) do nothing;
