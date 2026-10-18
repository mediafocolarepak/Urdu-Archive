-- 102_import_italian_originals_part09.sql (9/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1718-1737 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1718, 'ITA', $doc1718$Rocca di Papa, 25 ottobre 1990$doc1718$, 'drive_import', '01718-WEB-1990-10-25-collegamento-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1718)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1719, 'ITA', $doc1719$Rocca di Papa, 27 dicembre 1990

1991

Parola al primo posto

carissime,

         e allora, ciò che non doveva accadere, è successo: da 8 giorni è iniziata una guerra
terrificante e in tutto il mondo si è col fiato sospeso nel dubbio che essa dilaghi e coinvolga
altri popoli.

         Anche molti del nostro Movimento stanno già soffrendo in nazioni più o meno
compromesse con l'attuale flagello: in Iraq, in Israele, in Giordania, negli Stati Uniti, nella
Turchia ecc.

         Nonostante le molte preghiere, anche nostre, Dio ha permesso la guerra. Perché?
Perché la volontà di qualcuno responsabile non ha coinciso con la sua, espressa dalla voce
corale dì coloro che avevano più ragione, e che il Santo Padre, la più grande autorità
spirituale e morale del mondo, ha riassunto e concentrato nei suoi appelli costanti alla pace,
all'inutilità della guerra per risolvere ogni problema, ed evitare le sue inevitabili
conseguenze catastrofiche.

         Speriamo soltanto che nei misteriosi piani di Dio Egli, col suo infinito amore, sappia
e voglia trarre qualcosa di bene anche da questo immenso male, come ha fatto con l'ultima
guerra mondiale almeno per quanto riguarda il nostro Movimento. Non lo si meriterebbe,
ma conosciamo l'immensità della sua misericordia. Per questo e anzitutto perché la pace
ritorni, non smetteremo di pregare. Anzi! Ora il nostro "time-out" dovrà essere più intenso
ancora.

         In questo momento poi dobbiamo tutti sentirci chiamati a seguire con decisione una
linea di vita che corregga, almeno dentro di noi (ma per la comunione dei santi in molti), lo
sbaglio che è stato commesso.

         Gli uomini non hanno fatto la volontà di Dio, del Dio della pace, hanno fatto la loro.

         Noi dobbiamo imporci, come non l'abbiamo mai fatto, di compiere perfettamente la
sua volontà, che è espressa nelle sue Parole.

         Le sue Parole per noi oggi devono assumere un'importanza tutta particolare.
         Se abbiamo scelto Dio come Ideale - e questa è la nostra identità -, se l'abbiamo
messo al primo posto, ciò richiede praticamente che mettiamo al primo posto nel nostro
cuore la sua Parola, la sua volontà. Essa deve venire a galla su tutto il resto. Di fronte ad essa
ogni altra cosa deve diventare in certo modo indifferente, di quella santa indifferenza di cui
parlano alcuni Santi. Non deve avere tanta importanza nella nostra vita ad esempio, essere
sani o ammalati, studiare o servire, dormire o pregare, vivere o morire. Importante è vivere
la Parola, essere Parola viva.

         Così si viveva nei primi tempi del nostro movimento quando, sullo sfondo appunto
di un'altra guerra, lo Spirito ci aveva appena illuminato sul valore delle cose.

         Voglio ricordare ancora qui, per essere il più chiara possibile, un episodio di quei
tempi, emblematico e da qualcuno già conosciuto, che dà anche oggi l'idea di come occorra
comportarsi.

         Il Movimento aveva incominciato ad estendersi anche a Roma e a noi necessitava
una casa. Era difficilissimo trovarla, ma provvidenzialmente ce n'era stata offerta una, e
avevamo avuto anche la somma che bisognava versare anticipatamente. Siamo andate,
dunque, dal nostro Arcivescovo di Trento per informarlo.

         Nel frattempo egli stava pensando come rendersi ulteriormente conto che la nostra
era Opera di Dio, e s'era ricordato del "segno dei segni" indicato dal suo fondatore Gaspare
Bertoni: l'obbedienza, e aveva pensato di metterci alla prova.

         Arrivate da lui, abbiamo esposto la nostra intenzione, ma egli ci oppose un netto
"no", motivando la cosa con i tempi che correvano.

         La nostra reazione - mentre il Vescovo si rassicurava per il segno avuto - fu
immediata: gioia ed esultanza: avevamo conosciuto la volontà di Dio. E noi non volevamo
che quella: avevamo capito troppo bene cosa significasse. Essa era in ciò che ci aveva detto il
Vescovo. Non ci importava assolutamente avere o non avere una casa, ma poter fare la
volontà di Dio. Quello era l'ideale.

         In questo modo dobbiamo comportarci anche ora.

         Abbiamo avuto un brusco e doloroso cambiamento di vita di qualcuno di noi?

         Dobbiamo correre ai rifugi tanto spesso, esattamente come in quei tempi lontani, ma
pur tanto cari al nostro cuore? Abbiamo momenti di paura, di angoscia, di dubbio persino
che la vita ci sia tolta? o conduciamo la vita di sempre, coi nostri impegni quotidiani, lontani
ancora dal pericolo?

         Per tutti valga ciò che più vale: non questo o quello, ma la volontà dì Dio.

         La Parola di Vita del prossimo mese dice: "Questi è il mio Figlio prediletto:
ascoltatelo" (cf Mc 9,7).
         Sì: occorre ascoltarlo, mettere al primo posto nel nostro cuore, nella memoria, nella
mente, la sua Parola; porre, prima di ogni altra cosa, tutte le nostre forze al suo servizio.

         E, per venire al concreto, ascoltiamo in questo mese quella che dice: "Non la mia, ma
la tua volontà sia fatta" (cf Mc 14,36).

         Per essa, mettendola tutti in pratica, rettificheremo, almeno in noi lo sbaglio che è
stato fatto. Per essa Cristo rimarrà nel nostro cuore e saremo così tutti più compatti, più
uniti, più uno, condividendo ogni cosa, pregando con efficacia gli uni per gli altri e perché
torni la pace.

         Carissime tutte, a presto, a presto: a notizie - speriamo - migliori!$doc1719$, 'drive_import', '01719-WEB-1990-12-27-parola-al-primo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1719)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1720, 'ITA', $doc1720$Rocca di Papa, 25 ottobre 1990

Saluti di Chiara

-  Saluti in Francia: al Centro Mariapoli di St. Pierre, dove si svolgeranno, durante il

prossimo week-end, tre congressi nazionali: per i Gen 2, per i Gen 3 e per i Gen's.

-  Poi vorrei mandare un saluto del tutto speciale alle focolarine, ai focolarini e a tutta

la comunità del Libano. Se non mi sentono adesso, mi sentiranno fra poco.

         So quanto avete sofferto anche in queste ultime settimane: un nostro giovane di
Gioventù Nuova è stato ucciso, e una gen 3 è stata ferita...

         Siete stati privati di ogni sorta di beni materiali, avete sofferto per non aver potuto
incontrarvi, e vedete attorno a voi ora tutto compromesso.

         Il mio consiglio? Gettate ogni preoccupazione nel cuore del Padre. A Trento,
all'inizio dell'Ideale, tutto crollava, eppure il nostro cuore era così abbagliato dalla luce
dell'Ideale, che quanto succedeva attorno a noi impallidiva. E così il Movimento è cresciuto e
il Regno di Dio si è dilatato fino a raggiungere tanti popoli; ed ora i suoi ideali di unità, che
garantiscono la più piena libertà, stanno penetrando anche gli aspetti umani delle cose.

         Per chi cerca il suo regno il resto viene senz'altro in soprappiù. Perciò la speranza
non deve mai affievolirsi e la pace rimanere salda nel vostro cuore.

         Del resto anche Gesù, ai suoi tempi, è vissuto in una Palestina occupata dai romani.
Ma non era tanto quella la liberazione su cui puntava. E ha amato tutti: gli uni e gli altri. Così
fate anche voi.

         Carissimi tutti, sono con voi in modo - come vi ho detto - tutto speciale. E qui sono
con me il Centro dell'Opera e i capizona di tutto il mondo, tutti uniti con voi ogni giorno nel
"time-out".

   Ciao dunque a tutti. Attendiamo sempre notizie. Ciao.

EARE E RICREARE LA COMUNITA'
Carissimi,

         il nostro Collegamento odierno cade ancora nel periodo di Natale, un tempo
in cui si medita sulla nascita di Gesù e, di conseguenza, su altre nascite. Natale,
infatti, nel campo umano, è la festa dei bambini, gli ultimi nati, e, nel campo
soprannaturale, ci ricorda la nascita o rinascita di Gesù in noi e di Gesù in mezzo a
noi cui sempre dobbiamo tendere.

         Quest'anno, qui a Rocca, ci siamo soffermati un attimo per ricordare anche
un'altra nascita, quella del nostro Movimento: una vera, reale nascita, avvenuta 47
anni fa.

         Il Movimento prima, infatti, non c'era, poi c'è stato. E l'ha fatto nascere, lo
sappiamo, lo Spirito Santo, che ha agito in una certa maniera.

         Ha messo le prime focolarine in condizione di prendere in grande, vorrei dire
in unico rilievo, il Vangelo; ha loro illuminato le sue parole e ha dato loro la spinta
per viverle.

         L'effetto? Lo sappiamo, impensato e meraviglioso: per la Parola vissuta
radicalmente, per la Parola presa sul serio, è nata una comunità ben presto
numerosa, ben presto diffusa in più di cento paesetti del Trentino: era il Movimento
dei Focolari. Gente, che prima si ignorava, è diventata famiglia; cristiani, prima
indifferenti l'uno dell'altro, si sono compaginati in uno.

         Dunque la Parola di Dio fa questo miracolo, può fare questo miracolo: dar
origine ad una comunità visibile.
         E ci siamo detti: la Parola si vive tuttora, ma fa pure adesso gli stessi effetti?
Noi distribuiamo ai nostri, ed agli altri, Parole di Vita in tutto il mondo, in tutte le
lingue e sproniamo a viverle. Ma, siamo certi che nasce dovunque, di conseguenza,
così come allora, una comunità viva di persone?

         Viviamo la Parola di Dio con tale radicalità sicché essa spezzi il nostro io,
annienti il nostro egoismo, ci inchiodi con Cristo in croce in maniera tale che non più
noi viviamo in noi, ma la Parola, che è Lui, viva in noi? Ed essa, che sola lo può,
edifichi attorno a noi la comunità? O la Parola serve, in genere e quasi
esclusivamente, come un qualche balsamo per le nostre anime, per consolarle,
incoraggiarle, per giustificare le nostre coscienze, ripiegandoci così in una ben
povera e languida spiritualità individuale, che poi non è tale? Sappiamo, infatti,
come le spiritualità individuali sono complesse, ricche: oltre l'attenzione alla Parola
di Dio, conoscono le penitenze, le lunghe preghiere, i digiuni, le veglie, ecc. E noi ci
accontentiamo magari di quel po' di patina spirituale, che può dare la meditazione o
il ricordo della Parola, e credere così di essere a posto?

         E ci è nato il desiderio di tornare lì a quei tempi...

         Erano tempi in cui, si può obiettare, oltre la Parola di Vita vissuta, si
aggiungevano, senza dubbio, altri utili elementi al formarsi di una comunità: il
comunicarci continuo delle esperienze della Parola che dobbiamo mettere in pratica
tuttora.

         Vi era la possibilità di attingere continuamente alla luce del nuovo carisma,
che non illuminava solo la Parola di Dio, ma ci faceva intravedere spiragli sul nostro
futuro, facendoci cogliere, ad esempio, con sicurezza, lo scopo per cui stavamo
nascendo: l'"ut omnes unum sint" e suggerendoci la chiave per attuarlo: Gesù
abbandonato. Poi si assisteva alle chiamate di giovanette e giovani, da parte di Dio, a
consacrarsi totalmente a Lui, con la possibilità per essi di vivere insieme e costituire
così l'esempio di minuscole comunità in cui il vivere la Parola era tutto; l'ambiente
stesso circostante sottolineava, con i terrori della guerra, l'ideale abbracciato; i
numerosissimi bisognosi (mutilati, orfani, malati, affamati, senza tetto e vestiti),
stimolavano il vivere le Parole, specie quelle riguardanti l'amore.

         Tutte cose tuttavia che anche oggi non mancano: anzi! Abbiamo un'Opera
meravigliosa da cui attingere negli scrigni dei suoi archivi luce e luce; abbiamo
meravigliosi statuti e regolamenti, approvati dalla Chiesa, come bussola sempre
pronta ad indicarci come dobbiamo vivere e per quale fine; abbiamo, grazie a Dio,
un continuo fluire di vocazioni totalitarie nell'Opera; abbiamo il mondo spalancato
davanti ai nostri occhi e più al nostro cuore (entrato ormai, per i mass media, nelle
nostre case), che ci grida i dolori delle guerre, delle catastrofi naturali, delle calamità
di ogni genere, a cui possiamo dedicarci con lo slancio con cui i primi tempi
amavamo i più provati...

         Tutto abbiamo. Nulla manca. Ed è con la Parola vissuta e tutti questi altri
doni, che possiamo, anche oggi, far nascere continuamente, dovunque, nel mondo
nuove comunità, per il bene della Chiesa e dell'umanità, per la gioia di Maria, per la
gloria di Dio, come frutto.

         Dio vuole i frutti, gli effetti: per questo il chicco di grano muore, per portar
frutto. Per questo la Parola deve farci morire al nostro io, al nostro modo di pensare,
di amare, di volere, per assumere quelli di Cristo che sa come creare una comunità.

         C'è, naturalmente, chi, nel nostro Movimento vive più all'interno di esso, ed
allora ha meno contatti con il mondo fuori.

         Per questi creare la comunità con la Parola significa soprattutto "ricreare"
continuamente quella porzione di Movimento in cui vive, alzando il termometro
della carità, assicurandosi che Gesù è sempre presente dovunque, mettendosi sotto
tutti, al servizio di tutti, per tutti sollevare di più verso Dio.
         Ma i più sono al contatto con la gente di ogni genere.

         Per loro creare la comunità è sfruttare ogni occasione (telefono, incontri,
corrispondenza, atti concreti d'amore, convegni, ecc.), per allacciare rapporti,
stringere amicizie, coltivare i cuori...

         Solo in questo modo noi siamo noi, il Movimento è quello che deve essere.
Solo così la nostra è una spiritualità come lo Spirito la vuole: vissuta insieme,
comunitaria, collettiva.

         La Parola del prossimo mese è: "Lodate, nazioni tutte, il Signore: i popoli tutti
lo esaltino." (Rm 15,11)

         Si può lodare Dio con le preghiere, con le lodi, coi canti, con la musica, con
l'arte... Ed è bene e doveroso farlo.

         Ma quale inno di lode più alto a Dio, Trinità Santissima, di quello di una
comunità che rispecchia in se stessa la vita stessa del suo Signore?

         Allora il nostro proposito per il prossimo mese sarà questo: creare e ricreare
attorno a noi, in tutti i modi e sfruttando tutte le grazie che ci porge lo Spirito
attraverso il Movimento, comunità di fratelli a lode ed esaltazione del nostro Dio
uno e trino.$doc1720$, 'drive_import', '01720-WEB-1990-10-25-saluti-di-chiara-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1720)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1721, 'ITA', $doc1721$Rocca di Papa, 24 gennaio 1991

Non tiepidi, ma ardenti

Carissimi,

         nell'ultimo Collegamento che abbiamo trasmesso - un mese fa circa sullo sfondo
della guerra da poco esplosa nel golfo, ci siamo lasciati nella speranza di ritrovarci questa
volta in un panorama diverso, con notizie migliori.

         E oggi, proprio oggi, la notizia tanto attesa è arrivata: la guerra è finita. Non ci resta
che ringraziare Dio con un "time-out" di almeno una settimana per poi continuarlo per le
altre guerre del mondo.

         Certamente abbiamo trascorso un mese e più particolarissimo anche per il continuo
alternarsi di speranze di pace e di delusioni. Un mese e più che ci ha messo e rimesso a
confronto col nostro ideale di un mondo unito.

         Avevamo risentito con sorpresa, dopo quarant'anni di pace, parole che pensavamo
sepolte: come "il nemico", i "nemici", "cominciano le ostilità" i bollettini di guerra, i
prigionieri, le sconfitte, nomi i più vari e i più nuovi di complicatissimi strumenti di morte ...

         Affliggeva il nostro cuore l'impressione d'essere tornati molto indietro nel tempo;
sembrava che gli uomini ignorassero quasi ciò che avevano costruito come sacro ed era
stato attinto o confortato dalla cultura cristiana: le leggi internazionali, gli organismi sorti
per l'intesa fra i popoli, i patti, l'idea così diffusa ormai dei diritti umani..., e se ne vedevano
gli effetti disastrosi.

         Abituati poi, noi, in modo speciale, per decenni a fare l'esperienza dell'amore
cristiano, a portarlo dovunque, dove s'è sviluppato il Movimento e, incoraggiati anche dagli
avvenimenti dell'89, che ci facevano sentire il mondo unito più vicino, ci siamo resi conto,
con sgomento, che veniva ferito nel cuore il principio fondamentale del cristianesimo, il
comando per eccellenza di Gesù, quello nuovo. "Gesù infatti - dice la Redemptoris missio -
riprende tutta la Legge, incentrandola sul comandamento nuovo." (Cf N. 15)

         Invece di amarsi a vicenda, invece di essere pronti a morire l'uno per l'altro, si era
caduti nel baratro dell'odio: ci si disprezzava, ci si torturava, ci si uccideva.

         Grande dolore quindi, grande momento di riflessione, grande desiderio di
ripuntualizzare la nostra vita. Così credo un po' per tutti. Ho sentito il pensiero di giovani e
di anziani mentre parecchi fra i nostri subivano le conseguenze della guerra.
         Quale la loro reazione? la nostra reazione?

         Rimettere senz'altro a fuoco con maggior convinzione il nostro ideale, che si può
vedere tutto li, nell'amore vicendevole, rinsaldare la nostra unità, spingerci a portarla più al
largo possibile.

         Ed è ciò che vorremmo fare in questo giorno senz'altro storico per l'umanità:
riprometterci quest'amore con tutto il cuore. Del resto non si è fatto mai abbastanza in
questo senso, se ne ha sempre bisogno.

         Perché il fuoco - e di fuoco si tratta - non si mantiene se non è continuamente
alimentato da legna, da paglia, ecc. Così il nostro amore ha bisogno d'essere continuamente
ravvivato da atti d'amore sempre più perfetti, sempre più sentiti.

         E non ne hanno bisogno solo quelli che sono al principio della vita spirituale o a
metà. Anche chi ha tentato di praticare a lungo, per anni, la carità, può cadere in una certa
routine della carità, che non ha più lo splendore e il calore della fiamma, ma lentamente si
ritira e va nascondendosi sempre più sotto la cenere. E' quando, ad esempio, nella nostra
vita quotidiana non viene più spontaneo dichiararci fra fratelli l'unità. E' quando costatiamo
che la nostra carità non fa più effetto, decresce sempre più la sua irradiazione, siamo poco
utili al Regno, i frutti diminuiscono - diveniamo tiepidi.

         Per questo allora occorre ricordarsi di ravvivare continuamente il fuoco, di tornare e
ritornare vivi all'amore.

         Sì, perché a Dio i tiepidi non piacciono per nulla. Dice la Scrittura: "... non, sei né
freddo, né caldo ; oh se tu fossi freddo o caldo! ... poiché sei tiepido, cioè né caldo, né freddo,
io sono pronto a vomitarti dalla mia bocca" (Ap 3,15-16).

         E ciò è terribile. Ciò dice l'urgenza di tornare sempre ad essere caldi, ad una carità
veramente fervente.

         Se faremo così, avremo la possibilità d'influire su molti.

         Noi, infatti, dobbiamo pensare che la nostra influenza sul mondo, sarà sempre più
efficace, sempre meno sproporzionata. Anzi è forse proprio questo il disegno di Dio sul
nostro Movimento. Ricordiamoci che pochi decenni fa non c'era nulla ed oggi siamo sparsi,
almeno come piccolo seme, su tutto il pianeta.

         E poi non siamo certamente soli. E' il nostro stesso ideale che esige una grande unità
con tutti i nostri fratelli cattolici, con tutti i cristiani e con tutti quelli che, avendo una fede o
no, vogliono il bene nel mondo!

         Certamente anche noi dobbiamo crescere e molto, ma non si può crescere se non
crescendo ogni attimo di più.
         E allora avanti: esaminiamoci spesso: abbiamo gettato legna sul fuoco? E' piatto il
nostro amore o ardente? Abbiamo colto tutte le occasioni per dimostrare a Dio e al
prossimo il nostro fervore?

         Se è così, anche per il nostro sforzo, Dio porterà avanti il Suo nostro progetto. E, pur
nel dolore per ciò che di grave la guerra ha procurato, diremo: le guerre passano (come è
passata la seconda guerra mondiale quando siamo nati) ma l'ideale, Dio, resta, Dio non
passa e, di conseguenza, se accolto nel nostro cuore, non passerà, ma avanzerà il progetto
per un mondo unito con un'invasione d'amore, con la civiltà dell'amore.

         Attenti allora in questo mese. Ricordiamoci solo queste parole: non tiepidi, ma
ardenti.$doc1721$, 'drive_import', '01721-WEB-1991-01-24-non-tiepidi-ma-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1721)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1722, 'ITA', $doc1722$Rocca di Papa, 28 febbraio 1991

Anzitutto un augurio di tutto cuore per questo giorno così particolare per la Chiesa e
particolarissimo per noi.

         Il Giovedì Santo ricorda tali e tante cose che occorrerebbe almeno un mese per
meditarle. E' un concentrato del nostro ideale se si ha presente anche la morte e
l'abbandono di Gesù, che ricorderemo domani, Venerdì Santo, e Gesù risorto, che
festeggeremo il giorno di Pasqua.

         Oggi diciamo tutto il nostro ringraziamento a Dio per averci dato il suo
comandamento nuovo, la preghiera per l'unità, l'Eucaristia ed il sacerdozio che la rende
possibile.

         E promettiamo di sfruttare questi doni immensi per tutta la vita per la sua gloria.

Meglio di ieri

Carissime,

         come parecchie di voi già sanno, durante questo mese abbiamo ricevuto un preciso
invito dal S.Padre Giovanni Paolo II. In uno scambio di lettere fra noi e lui, nella persona del
Sostituto della Segreteria di Stato - in seguito al suo meraviglioso discorso dove annunciava
il desiderio di portarsi a Gerusalemme per trovarsi insieme con musulmani ed ebrei a
pregare in quei luoghi così sacri alle tre religioni -, era emersa per noi (perché avvertita nel
cuore e confermata da Sua Santità) una precisa volontà di Dio.

         Dovevamo tessere in questi prossimi mesi, dove è possibile - come una delle
operazioni che il Movimento nelle sue diramazioni giovanili ed adulte è solito fare - rapporti
nuovi o un approfondimento di quelli già esistenti, fra noi cristiani ed i fedeli delle religioni
monoteiste: i musulmani e gli ebrei.

         E ciò per collaborare con la Chiesa, e con quanti altri vi sono impegnati, allo sforzo
che si fa per mettere pace fra tutti e permettere così il miglior riassetto del Medio Oriente.

         Infatti, nell'entusiasmo e nella gioia delle sue grandi aperture, così in sintonia con
quanto il nostro carisma ci suggerisce, avevo promesso al S.Padre di "dissodare il terreno
fra i membri delle religioni monoteiste a noi vicini perché l'azione presente e futura del
Papa abbia il massimo successo...".
         Ed egli, grato per la partecipazione alla sua azione, incoraggiava ogni nostro
impegno diretto allo stesso scopo e ogni collaborazione perché fiorisca nella famiglia umana
un'era di solidarietà e giustizia.

         Ed è quello che faremo. Sono certa che chi è nella possibilità (ma lo si può ormai in
molte nazioni per le emigrazioni, ad esempio, che ci sono state e ci sono), si impegnerà in
modo speciale in questa azione particolare. Vi farò avere a proposito, dal Centro
suggerimenti utili.

         Ma il fine del nostro Movimento - lo sappiamo - non è solo quello di - mettere pace in
medio oriente, dove vi sono cristiani, musulmani ed ebrei. Noi tendiamo - perché così vuole
il nostro ideale - all'unità del mondo intero. E per questo (perché ci sia pace dovunque)
preghiamo ogni giorno nel "time-out". Ora uno dei mezzi che abbiamo per arrivare a ciò è
convogliare allo scopo (all'unità e quindi alla pace) più persone possibili, proprio in quanto
fedeli di una religione: è il nostro terzo dialogo. Per cui in questo mese inviterei tutti a
ravvivare i rapporti con loro. E fedeli delle più varie religioni sono un po' dovunque.

         Certamente è sempre una rivoluzione quella che ci domanda la volontà di Dio.
Sappiamo che in questo campo ci sono secoli di immobilismo dietro alle nostre spalle, e,
spesso, di ostilità. E' una lotta per la pace, quindi, quella che dobbiamo condurre, ed occorre
premunirsi, allenarsi, prepararsi.

         Ecco perché vorrei consigliare, prima di tutto a me e poi a tutti voi, qualcosa che ci
aiuti nelle prossime settimane ad avere un aiuto in più, ad aggiungere qualcosa a ciò che già
facevamo, ad essere più vigilanti di prima, a crescere e crescere di continuo, per non venir
meno. Lo sappiamo che, se non si va avanti, si va indietro. Qualcosa che ci faccia migliorare
ogni giorno di più nel vivere il nostro ideale.

         Questo qualcosa potrebbe consistere nel dire a noi stessi prima di ogni azione che
facciamo: "Oggi meglio di ieri".

         Tante azioni nella nostra vita hanno alcunché di ripetitivo: si prega tutti i giorni, si
mangia tutti i giorni, si esce, si studia, si lavora, si incontrano persone, si dorme, si
passeggia, si fanno lavori di casa, si riposa, ecc.

         Ebbene, compiamo ogni azione facendola precedere da un: "Meglio di ieri". E
impegniamoci di conseguenza.

         Saremo così come Dio ci vuole: siamo un Movimento e non ci è permesso fermarci.
Ed avremo più grazie e più facilità nell'attuare il compito specifico di questo mese: prendere
in grande considerazione i fedeli di altre religioni e collaborare con loro alla pace e all'unità
del mondo.$doc1722$, 'drive_import', '01722-WEB-1991-02-28-collegamento-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1722)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1723, 'ITA', $doc1723$Loppiano, 14.5.87
COME MARIA MADRE

Carissimi,

Siamo ormai alle porte dell’Anno Mariano: un anno nel quale, anche assieme ai nostri fratelli
d’Ideale ortodossi, anglicani, luterani, riformati ecc. vogliamo approfondire la conoscenza di
Maria, la madre di Gesù, per poterla amare meglio e onorarla adeguatamente.
Da più parti del Movimento mi è stato richiesto come è risuonato in me l’annuncio dell’Anno
Mariano e quali propositi mi sono fatta per viverlo bene.
Ho risposto che il sapere di aver davanti a noi un intero anno nel quale si starà
spiritualmente più vicini a Maria (perché la si pregherà di più, si andranno a visitare i suoi
santuari e le sue basiliche, si leggeranno le encicliche a lei dedicate, si seguiranno i
programmi di conferenze che la riguardano, gli studi, le trasmissioni televisive che la Chiesa
sta approntando ecc.), ha portato nel mio animo un’atmosfera di gioia, di festa.
E questo perché c’è ormai qualcosa di molto forte che ci lega a Maria ed anche, più
semplicemente, perché le vogliamo bene.
In quanto poi ai propositi che mi sarei fatta, ne ho annunciato uno che comunico anche a voi
come ho già fatto con i "cittadini" di Loppiano e con i partecipanti a due corsi del Centro
Mariapoli di Castel Gandolfo.
È un proposito che vorrei formulassero tutti gli interni dell’Opera di Maria ai quali arriva
questo Collegamento.
In un anno tutto dedicato a Maria noi dovremmo trovare il modo di onorare la madre di Dio.
E quello migliore.
Ma c’è maniera e maniera di onorarla.
Lo si può fare parlandone, lodandola, pregandola, visitandola nelle chiese a lei dedicate;
dipingendola, scolpendola, innalzandole inni, adornando le sue effigi di fiori...
Ci sono tanti modi di onorare Maria.
Ma ce n’è uno che supera tutti: è quello di imitarla, di comportarsi come altra lei sulla terra.
Credo che sia quello a lei più gradito, perché le dà la possibilità di ritornare in certo modo
sulla terra.
Noi, senza escludere tutte le altre possibilità che abbiamo di onorare Maria, dobbiamo
puntare su questa.

Imitarla.

Ma come imitarla? Cosa imitare di lei?

Imitarla in ciò che è essenziale. Ella è Madre, madre di Gesù e spiritualmente madre nostra.
Gesù ce l’ha data come tale sulla croce nella persona di Giovanni.

Dobbiamo essere un’altra lei come madre.

Dobbiamo in pratica formulare questo proposito: durante l’Anno Mariano mi comporterò
verso tutti i prossimi che avvicinerò, o per i quali lavorerò, come fossi madre loro.

Così facendo costateremo in noi una conversione, una rivoluzione. E non solo perché a volte
ci troveremo a fare da madre magari a nostra madre o a nostro padre, ma perché
assumeremo un atteggiamento particolare, specifico.

Una madre accoglie sempre, aiuta sempre, spera sempre, copre tutto. Una madre perdona
ogni cosa al suo figlio, fosse anche un delinquente, un terrorista.

L’amore di una madre infatti è molto simile alla carità di Cristo di cui parla Paolo.

Se noi avremo il cuore di una madre o, più precisamente, se ci proporremo di avere il cuore
della Madre per eccellenza: Maria, saremo sempre pronti ad amare gli altri in tutte le
circostanze e a tener vivo perciò il Risorto in noi. Ma faremo anche tutta quella parte che è
richiesta a noi per mantenere presente Gesù, il Risorto, in mezzo a noi.

Se avremo il cuore di questa Madre, ameremo tutti e non solo i membri della nostra Chiesa,
ma anche quelli delle altre. Non solo i cristiani, ma anche i musulmani, i buddisti, gli induisti
ecc. Anche gli uomini di buona volontà. Anche ogni uomo che abita sulla terra: perché la
maternità di Maria è universale (cf. LG 79), come è stata universale la Redenzione.

Anche se lei non è a volte riamata, ama sempre, ama tutti.

Ecco, dunque, il nostro proposito iniziando l’Anno Mariano: vivere come Maria, come
fossimo madri di tutti gli uomini.$doc1723$, 'drive_import', '01723-WEB-1987-05-14-come-maria-madre-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1723)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1724, 'ITA', $doc1724$Rocca di Papa, 28 marzo 1991

"Il tuo volto, Signore, io cerco"

(Salmo 26,8)

Carissimi,

         mentre i giornali e i telegiornali non ci sanno consegnare in genere se non figure di
persone uccise nelle strade, nei bar, nelle case, evocando l'odio che intercorre fra tanti
uomini, la delinquenza, la malavita, e suscitando continua tristezza nel nostro animo, stanno
concludendo il loro santo viaggio anche persone degne, a noi note, che andrebbero messe
come luce sul moggio. Ma nessuno, all'infuori di chi è loro accanto, o nel loro ambito, se ne
accorge. Il bene, infatti, sembra destinato al silenzio ed il male al chiasso e i mass-media non
ne parlano. E' quello che succede fra noi. Per il carisma del Movimento, in questi 48 anni
della sua presenza sulla terra, abbiamo visto - lo sappiamo - partire tanti come santi: la
nostra Mariapoli Celeste, infatti, trabocca.

         Anche in queste ultime settimane ne sono partiti alcuni, come pensando solo
all'Italia - don Matteo, un focolarino sacerdote del quale mai abbastanza bene si dirà, e
Santa, una gen della zona di Napoli, trucidata come s.Maria Goretti per essere andata
controcorrente. E' di pochi giorni poi la notizia che anche Anna, una meravigliosa focolarina
di Londra, se n'è andata.

         Sono partiti e viene da chiedere a noi, che siamo ancora su questa terra: che
esperienza avranno fatto nel momento del passaggio? cosa ci direbbero se potessero
parlare?

         Lo sappiamo: hanno visto il Signore. Hanno incontrato Gesù. Hanno conosciuto il
suo volto.

         E' una verità di fede questa: una verità che dà una consolazione immensa. Non se ne
può dubitare. San Paolo esprime (sono parole sue) il suo "desiderio di essere sciolto dal
corpo per essere con Cristo" (Fil. 1,23). Parla quindi di un'esistenza con Cristo che succede
direttamente alla morte senza attendere la risurrezione finale (cf. 2 Cor. 5,8).

         L'hanno visto. Dunque è vero che - in certo modo - la morte non è: essa è l'incontro
col Signore.

         I nostri avranno visto risorto e radioso il loro salvatore, il loro fratello, lo sposo delle
loro anime; rivestito senz'altro dell'aspetto di giudice - come sappiamo - ma sempre colui al
quale hanno dato la vita. Per questo anch'essi prima di quell'incontro avrebbero potuto dire
con s. Teresa: "Sarà cosa bella al momento della morte pensare che stiamo per essere
giudicati da Colui che abbiamo amato sopra ogni cosa" (s. Teresa, Cammino 40,8).
         Questa, dunque, l'esperienza dei nostri arrivati alla mèta cui conduce il Santo
Viaggio: l'incontro con Colui che non potrà non amarci, se l'abbiamo amato.

         Questa - speriamo - sarà anche la nostra esperienza.

         Ma, per essere certi, occorre prepararvici fin d'ora, occorre, in certo modo,
abituarvici.

         Incontreremo il signore? Vedremo il suo volto?

         Certamente lo contempleremo splendente se qui l'avremo guardato e amato e
accolto abbandonato. Paolo non conosceva nulla sulla terra se non Cristo, ma questi
crocifisso.

         E' quello che vogliamo impratichirci a fare anche noi nel prossimo mese: cercare il
suo volto. Cercarlo abbandonato.

         Lo troveremo senz'altro nei piccoli e grandi dolori personali che non mancano mai;
nel volto dei fratelli che incontreremo, specie i più bisognosi d'aiuto, di consiglio, di
conforto, d'una spinta perché camminino meglio nella vita spirituale. Lo cercheremo negli
aspetti più duri, più faticosi, che comporta il fare le varie attività, che ci suggerisce la volontà
di Dio; in tutte le disunità vicine e lontane, piccole e grandi, e perciò nel lavoro per l'Opera
specialmente a favore dell'unità delle Chiese, dei fratelli d'altre Religioni, di quelli lontani,
ma di buona volontà.

         Cercheremo il suo volto anche nell'Eucaristia, in fondo al nostro cuore, nelle sue
immagini sacre.

         Va poi contemplato e amato concretamente anche in tutti i grandi dolori del mondo.
Sì, anche se per quelli noi ci sentiamo sovente impotenti. Ma forse non è così.

         Quanto spesso, attraverso il telegiornale o meglio la Radio Vaticana, che è più
internazionale, veniamo a conoscere certe calamità già in atto o incombenti su interi popoli
o nazioni (come ad es. è stato ed è per il popolo curdo, come per il flagello del colera che
minaccia ora più nazioni del Sud America, come per i previsti milioni di morti di fame in
Africa, come per lo stato più che precario del nostro pianeta che getta allarme per quello che
potrà accadere in futuro anche ai nostri Gen 4)! Sono calamità che - se la carità di Dio
alberga nel nostro cuore - ci cadono addosso come macigni, senza lasciarci respiro. E ciò
perché sentiamo - nonostante la nostra buona volontà e le nostre operazioni - di non poter
fare nulla d'adeguato che migliori le situazioni. Eppure dobbiamo convincerci che qualcosa
si può fare. Anche qui, scoperto il Suo Volto, in queste immani catastrofi, possiamo, con la
forza dei figli di Dio, che tutto s'attendono dal loro Padre onnipotente, gettare le
preoccupazioni, che schiacciano noi e porzioni così vaste di umanità, in Lui, perché pensi a
smuovere i cuori dei responsabili dei popoli che ancora possono fare qualcosa. E dobbiamo
essere certi che lo farà. Ed è stato così molte volte.
         Questo mese perciò, facciamo in modo che riecheggi il più spesso possibile nel
nostro cuore il versetto del Salmo 26 che dice: "Il tuo volto, Signore, io cerco". Il tuo volto
addolorato per asciugarti, come ci è possibile, lacrime e sangue e poterlo vedere splendente
alla nostra ora, quando faremo l'esperienza dei nostri già arrivati nella Mariapoli Celeste.

         E che Maria, la Desolata, la nostra Madre, la nostra Regina, che trasalì di fronte al
volto del suo Figlio sfigurato, sia sempre con noi in questo pietoso compito, così come
chiediamo che domani sia con noi nel nostro radioso incontro con Lui.$doc1724$, 'drive_import', '01724-WEB-1991-03-28-il-tuo-volto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1724)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1725, 'ITA', $doc1725$Rocca di Papa, 25 aprile 1991

"Santi per amore"

Carissimi,

         come sapete, vi parlo oggi dalla Mariapoli Araceli in Brasile, vicino a San Paolo.

         Avevo in animo di descrivervi questa cittadella, ma lascio, per ora, ad Eli questa
parte. Per ora, perché in futuro se ne parlerà a lungo.

         Vengo perciò immediatamente a comunicarvi il pensiero spirituale che ogni
collegamento esige.

         Siamo ancora nell'atmosfera della Pentecoste che ha dato a noi tutti e, penso, anche
a voi, l'occasione per rendere più presente all'anima il nostro Protettore: lo Spirito Santo.

         Abbiamo dedicato a Lui questi due ultimi anni di vita ideale e penso che Egli, in
questa Pentecoste del '91, abbia trovato in noi cuori più vigili d'una volta, più amanti, più
riconoscenti.

         Qui nella Mariapoli Araceli abbiamo meditato con i focolarini i suoi effetti sulle
persone del Movimento che ora hanno, in genere, trovato un nuovissimo rapporto con la
terza Divina Persona.

         E, poiché Egli è il santificatore, abbiamo cercato di evidenziare quale è stato nella
storia dell'Opera, il nostro atteggiamento verso la santità, la necessità della santità, il dovere
della santità.

         Come possono testimoniare quelli fra noi, che hanno avuto la grazia di vivere i primi
tempi del Movimento, in un primo momento - ricorderanno - avevamo persino rinunciato
alla santità, almeno così come era allora concepita da alcuni. Essa cozzava fortemente
contro l'esigenza di radicalità del nostro ideale.

         Noi ci sentivamo chiamati a vivere per Dio e per gli altri, in un totale oblio di noi
stessi e tutto ciò che poteva farci cadere nel ripiegamento su di sé, o isolarci dagli altri, non
ci convinceva. Di qui il nostro rifiuto. Dio, da amare attraverso i fratelli, era il solo ideale, e,
se in Cielo si fosse pensata per noi la santità, essa sarebbe dovuta venire come una
conseguenza di ciò.

         Senonché, anni e anni dopo, quando Maria S.S. ci manifestò tanta della sua bellezza a
noi nascosta e ci indicò, nelle tappe della sua vita, la via del nostro cammino proprio verso la
santità, si riparla di questo dovere del cristiano e di noi, in particolare.
         Ma qui non c'era più pericolo di guardare a sé: Maria, tutta proiettata su Dio e su
tutti i suoi figli, così com'è, non lo permetteva. E la via spirituale collettiva, non solo
individuale, che ci mostrava, ci soddisfaceva appieno. Infatti di via collettiva si trattava:
basti ricordare la seconda e la terza tappa, caratterizzate la seconda, dalla narrazione ad
altri delle proprie esperienze, sull'esempio di Maria che canta il "Magnificat"; e la terza,
dalla capacità, con l'aiuto di Dio, di dar vita, assieme ad altri, a Gesù presente fra noi, che
ricorda la sua nascita.

         Così abbiamo teso con forza anche alla santità ed in questa tensione, illuminati dallo
Spirito Santo, molti, fra i nostri "partiti" si sono - a noi sembra - santificati.

         Ora, in questa nuova sentitissima Pentecoste (come in un terzo momento della
nostra storia sui rapporti con lo Spirito Santo) ci è parso che Egli ci desse una nuova luce
sulla santità.

         Si è capito che noi siamo chiamati ad amare i fratelli, ma che essi si possono amare
poco o molto. Ama poco colui che si limita a farlo durante la sua vita terrena; ama molto,
invece, chi trova il modo d'amarli anche dopo, negli anni e nei secoli perché, vivendo in lui
Cristo, rimane qui in terra come modello che molti possono imitare.

         Così hanno fatto i santi. Si medita sulla loro vita, sui loro scritti e sulle loro opere,
anche dopo secoli e secoli dalla loro "partenza".

         Sul loro esempio, anche noi possiamo far questo: farci santi per amore dei nostri
contemporanei e di quelli che verranno per dar loro luce e sprone nella via della vita per
lungo tempo e infondere nei loro cuori la fiamma dell'amore.

         Farci santi non quindi e non certo per la nostra soddisfazione, ma oltre che per la
gloria di Dio - per i nostri fratelli.

         In questi giorni, ad Araceli, meditando su queste cose, è nato perciò uno slogan che
piace molto: "santi per amore".

         E ci siamo promessi, ed ora rinnoviamo la promessa con tutti voi, di raggiungere
questa santità così congeniale con la nostra via, che è via dell'amore.

         Farci santi, ma in che modo? Gesù, prima di morire, ha pregato il Padre così:
"santificali per la verità; la tua parola è verità." (Gv 17,17)

         Ci santificheremo, e ci santificheremo per gli altri, vivendo la Parola.

         Domini allora in questo mese l'idea del perdere: "Chi perde la propria vita...";
perdere ogni desiderio che non coincida con la volontà di Dio nel presente. Lo sappiamo che
si cammina più in un mese, praticando la rinuncia evangelica, che in molto tempo con altri
metodi: è pensiero di san Giovanni della Croce.
         In conclusione, quindi: santi per amore, santi, perdendo.

         Ci avvicineremo, così facendo, a quei due sublimissimi modelli di santità
irraggiungibile che sono Gesù abbandonato e Maria desolata, al "nulla" che essi hanno
raggiunto per dare a noi il Tutto. Essi sì che sono stati "santi per amore"; per amore di noi.$doc1725$, 'drive_import', '01725-WEB-1991-04-25-santi-per-amore-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1725)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1726, 'ITA', $doc1726$Mariapoli Araceli, 30 maggio 1991
Preferire i minimi

Carissimi,
         ed eccoci a questo nuovo Collegamento che, date le vacanze di luglio, speriamo

possa servire di stimolo alla nostra vita spirituale e pratica fino ad agosto quando ci
risentiremo.

         Che cosa desidero dirvi questa volta?
         Sottolineare un'indicazione che lo Spirito, mi sembra, ci ha dato in quest'ultimo
tempo.
         Tutti sapete ormai qualcosa del nostro viaggio in Brasile.
         Ebbene lì in quella nazione, in mezzo a quel popolo, per molti versi, meraviglioso, il
Signore ci ha ripetuto quale debba essere il nostro concetto ed il nostro atteggiamento nei
confronti dei poveri, dei diseredati, dei peccatori, dei lontani, dei minimi.
         Già lo sapevamo perché il nostro Statuto ci richiama in modo chiaro a vedere Gesù
Abbandonato in queste creature. Ma in queste ultime settimane, con sue grazie particolari,
ci ha risottolineato questo nostro dovere indicandocene l'ampiezza, le dimensioni,
suggerendoci modi, metodi e mezzi per espletarlo.

         Gesù ha una predilezione per i poveri, per i minimi.
         Quando, dopo il triplice rinnegamento di Pietro, fa a lui la triplice domanda: "Mi ami
più di costoro?" alla prima risposta affermativa di Pietro, Egli conclude: "Pasci i miei
agnelli". Dopo le altre due invece afferma: "Pasci le mie pecorelle". E per "agnelli"
s'intenderebbero - secondo gli esegeti - i piccoli, i poveri, i bisognosi. Per "pecorelle" tutti.
(Cf Gv 21,15 e ss)
         Così Gesù dimostra d'aver fatto l'opzione dei poveri, prima che molti Vescovi, ad
esempio, specie in paesi in via di sviluppo, la formulassero e la proponessero.
         Del resto lo si sa: egli è venuto per evangelizzare i poveri (cf Mt 11,5) ed ha detto
chiaramente: "Ogni volta che avete fatto queste cose a uno solo di questi miei fratelli più
piccoli, l'avete fatto a me" (Mt 25,40).

         Ma se Gesù ha dimostrato questa preferenza in parole ed opere già quand'era in vita,
il suo Spirito l'ha inculcata frequentissimamente durante i secoli in coloro che dovevano
diventare suoi strumenti per molti: come ad esempio, san Francesco, san Filippo Neri,
sant'Ignazio di Loyola, san Camillo de Lellis, ecc.

         E così è stato anche di noi. Il nostro carisma, all'inizio del Movimento, ci ha fatto
porre l'attenzione, ancora quando eravamo in casa con le nostre famiglie, anzitutto su quelli
che erano minimi intorno a noi: i poveri, gli ammalati, i feriti, i carcerati, i senza-tetto, gli
anziani, i bambini... E più tardi, in Piazza Cappuccini, nel primo focolare, su quelli che erano
minimi fra noi. Ed abbiamo cercato di risolvere il primo problema con azioni di carità, semi
delle azioni sociali e delle molte opere che sarebbero nate in seguito; ed il secondo con la
comunione dei beni fra tutti noi.

         Più tardi, siamo stati spinti generalmente a guardare a tutti, ad amare ogni prossimo
come noi stessi, minimo e non minimo, e ad amarci fra noi.

         E questo nostro modo di vivere è così inculcato in tutti che è divenuto il tessuto base
di tutto il Movimento.

         Ma in quest'ultimo periodo - come ho detto - ecco un nuovo richiamo a porre i
minimi nel primo posto del nostro cuore.

         Come allora potremo attuare ciò?

         Anzitutto guardando con predilezione a coloro fra noi che possono dirsi minimi e
sollevando ogni necessità con una comunione dei beni libera ma intensa, estesa a tutto il
Movimento nel mondo.

         E di ciò vi sarà parlato a fondo prossimamente negli incontri per interni, nelle
mariapoli e durante il prossimo anno.

         Poi guardandoci attorno. Abbiamo già delle specole ben poste: sono i membri di
Umanità Nuova e di Gioventù Nuova. Ma alle volte lasciamo solo a quei Movimenti, così
come sono istituzionalizzati, pensarci attraverso le loro azioni ed opere.

         E non pensiamo che tutti in certo modo siamo, se adulti, Umanità Nuova e, se
giovani, Gioventù Nuova.

         Dunque migliore attenzione a ciò che si fa nell'Opera in questo campo e solidarietà
concreta fra tutti e cooperazione per tutto quanto è possibile.
         Ancora è indispensabile una particolare predilezione per i minimi là dove inizia il
Movimento. Perché questo modo abbiamo seguito quand'esso è cominciato a Trento e così
deve essere dovunque.

         Leggete un po' sul libro "Meditazioni": 'una città non basta' e verranno molte
ispirazioni a quei nostri "piccoli greggi" sparsi qua e là nel mondo che danno inizio
all'avventura dell'unità.

         Se il Movimento nasce coi poveri, coi minimi, incomincia la sua vita nel proprio
humus caratteristico che non può non promettere sviluppo, frutti e vocazioni.

         Per le persone, infatti, che cominciano a conoscere il nostro Ideale, è più facile
amare dapprima i poveri, i diseredati, i bisognosi, le persone, in genere, fuori casa, che non
ti rinfacciano il cambiamento, la conversione che il carisma ha operato in te, che non ti
criticano, che non ti stanno a guardare con sospetto; poi si acquista la forza per amare tutti:
i familiari e gli altri. Così è stato con le prime e i primi focolarini.

         Ed ora, anche se ci sarebbero altre indicazioni da dare, per questa volta rimaniamo
così, lasciando che lo Spirito suggerisca a ciascuno come rimettere nel proprio cuore al
primo posto i minimi. A Lui non manca la fantasia.

         E allora avanti sempre al passo con ogni suggerimento che pensiamo venga dall'Alto.
E' così che si fa e si rifà sempre nuova e bella l'Opera di Dio.

         Un motto?

         Una domanda al nostro cuore: "Ho oggi preferito, fra tutti i miei prossimi, quelli più
in necessità?"$doc1726$, 'drive_import', '01726-WEB-1991-05-30-preferire-i-minimi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1726)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1727, 'ITA', $doc1727$Rocca di Papa, 27 giugno 1991

"Oggi ho parlato più di ieri?"

Carissime,

                   siamo tornati dalla Polonia col cuore gonfio di gratitudine per Dio che - come
ho preannunciato a Cracovia in una letterina al S.Padre - ha fatto veramente miracoli.

         E non solo nei giovani della chiesa universale, nei quali è esplosa la fede come poche
volte è successo, ma anche fra i nostri giovani che abbiamo accompagnato in più di 10.000.

         Stupendo e fruttuosissimo l'incontro a Czestochowa per tutti questi. E travolgente
quello a Katowice per i nostri interni dell'Est (che erano in numero maggiore) e dell'ovest.

         Il timbro ricevuto nel cuore lì dallo Spirito Santo è stato cosi forte che gli ultimi
drammatici avvenimenti successi immediatamente dopo in URSS, non li hanno toccati, come
era per noi focolarine e focolarini i primi tempi nei confronti della guerra.

         Ringraziamo, dunque, il Signore e Maria che in Polonia domina Regina e la si trova
dovunque.

         Quello che i nostri si sono portati via in cuore (e di cui si parlerà durante tutto l'anno
prossimo) sono i due cardini della nostra nuova evangelizzazione, che stiamo già lanciando;
cardini da cui non si può prescindere.

         La nostra nuova evangelizzazione, che, in pratica, coincide con una più intensa
diffusione dell'Ideale, consiste nel vivere prima, nel testimoniare nella nostra vita quanto
andremo poi annunciando. Con l'essere, insomma, prima di parlare.

         Con l'essere, come?

         Essere ciascuno uno con Dio, mediante l'unione con Lui che si esprime con la
preghiera vissuta tutta la giornata, come spesso abbiamo spiegato, e nella preghiere
stabilite dai nostri statuti.

         Con l'essere uno con Dio nella sua volontà, e uno con i fratelli che lo rappresentano,
specie i minimi.

         E con l'essere poi uno fra noi che è già parola, grido, annuncio al mondo: "Che siano
uno affinché il mondo creda." (Gv 17,21)

         Essere cioè in atto il Testamento di Gesù che riassume il Vangelo. Essere.

         E a questo riguardo abbiamo avuto una conferma generale che il mondo oggi vuole
tale evangelizzazione almeno come base.
         I giovani in Polonia non ci dicevano che si erano convertiti tanto per i discorsi che
hanno sentito, (certamente anche per quelli), ma perché si sono sentiti amati fino alla piena
condivisione di ogni bene. Vi sono loro espressioni meravigliose che vi faremo conoscere.
Per aver visto l'amore concreto, giovani non credenti hanno affermato: "Il cristianesimo è
vero." "Per la vostra vita siete credibili e imitabili."

         Ma, se il "vivere" è molto, moltissimo, esso non è sufficiente per una completa nuova
evangelizzazione.

         Occorre, anche parlare. E parlare molto. Donare tutto senza riservare nulla, e questo
certamente secondo le norme del Vangelo, il quale non vuole che si diano le cose sante ai
cani.

         Parlare, parlare di tutti i nostri principi: che nel fratello va visto Gesù, che occorre
"farsi uno" con ognuno; che nulla è meglio del fare la volontà di Dio; parlare dell'amore
reciproco, dell'unità, di Gesù crocifisso e abbandonato, di Gesù in mezzo..., insomma, della
spiritualità, senza trascurare occasione.

         E parlare delle nostre esperienze e di quello che abbiamo visto realizzarsi nel
Movimento.

         E' l'ora della parola.

         Anche nell'Est, già Chiesa del silenzio, occorre riimparare a parlare. Parlando, si
rinforza la fede in chi parla e in chi ascolta.

         Con questo binomio in cuore: "vivere e gridare sui tetti", sono ripartiti i nostri dallo
straordinario soggiorno in Polonia.

         E hanno sentito una nuova grazia d'impegnarvisi a fondo, come hanno dichiarato
quelli rientrati in Russia e come, spero, farete tutti quanti, appena riceverete questo
collegamento.

         In questo mese chiediamoci ogni sera: oggi ho parlato più di ieri? (E "parlare"
significa anche scrivere, trasmettere per radio, per TV, attraverso documentari; significa
parlare dell'Ideale fra noi per tener alta la temperatura nei nostri ambienti e nelle nostre
manifestazioni ecc.; parlare agli altri, inventandole tutte...)

         Maria, Regina degli Apostoli, ci guidi in questo meraviglioso e immane compito,
perché l'Opera si dilati e, con essa, la Chiesa.

         E il mondo sia lievitato dalla coscienza sempre più profonda dell'unità a cui non può
non tendere.

         Allora facciamo attenzione al titolo di questo collegamento che dice: "Oggi ho
parlato più di ieri?"$doc1727$, 'drive_import', '01727-WEB-1991-06-27-oggi-ho-parlato-pi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1727)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1728, 'ITA', $doc1728$Mollens, 29 agosto 1991

"Che occasione!"

Carissimi,

         nell'ultimo Collegamento vi ho preannunciato il tema dell'anno ideale, che sta
iniziando, e cioè: "Come concorre il nostro Movimento alla nuova evangelizzazione".

         E abbiamo preso nuova coscienza che evangelizzare per noi significa anzitutto
vivere, essere, testimoniare, ma poi anche parlare, annunciare.

         Anzi abbiamo visto tale necessità della parola nell'evangelizzazione che ci siamo
proposti, durante il mese scorso, di migliorarci, ogni giorno, proprio in questo senso.

         Ed è stato così.

         Si è costatato con ciò di conseguenza nel Movimento tutto un fiorire di esperienze, di
episodi, di fatti sorprendenti che hanno evidenziato la validità del nostro impegno.

         Non solo, ma il porre l'attenzione sul "parlare" nella nostra vita ideale, ha suscitato
in molti una specie di aperto esame di coscienza.

         Si è visto ad esempio che il poco "parlare" era stato a volte coperto da false
giustificazioni.

         Qualcuno ha affermato di non aver parlato per rispetto umano o per troppa
riservatezza; altri non aveva parlato per esagerata prudenza, per timore di suscitare critiche
verso il Movimento; qualcuno, avendo puntato su un malinteso farsi uno, aveva taciuto; c'è
stato chi, avendo lasciato che il ragionamento umano si annidasse nelle pieghe dell'anima,
non aveva parlato lì dove occorreva.

         Insomma si è vissuta qua e là un po' la Chiesa del silenzio, per così dire, anche se non
occorreva e dove non era volontà di Dio.

         Dobbiamo perciò rimediare.

         Esistono senz'altro nel mondo nazioni e situazioni particolarmente difficili, dove ad
esempio la cultura, fortemente chiusa, insegna a non parlare mai delle cose profonde della
propria anima, a non svelare mai il motivo delle proprie azioni; o dove l'ambiente è così
avverso al cristianesimo, che per il solo fatto di dirsi cristiani, si è considerati angelici,
retrogradi, alienati, la persona più bassa della società...

         In questi Paesi lo Spirito Santo suggerirà come comportarsi e non è detto che il
nostro Ideale ci dispensi proprio del tutto da incontrare, per Gesù, la persecuzione e magari
il martirio.
         Certamente occorre vedere come rimediare decisamente là dove le scuse che
abbiamo addotto non sono valide.

         Parlare dunque. Vivere e parlare.

         Vivere e parlare che, così espressi, appaiono due atteggiamenti ben distinti, ma che
per noi non sono poi tali.

         Dobbiamo essere convinti piuttosto che il parlare è una espressione del nostro
stesso vivere.

         Non si può infatti prescindere dal parlare se si vuole vivere integralmente la nostra
spiritualità.

         Ed è proprio ed in modo speciale per questo fatto che sento la necessità d'insistere
sull'uso della parola a favore del Regno di Dio.

         Voi sapete come, con la nascita del Movimento, il Signore ha donato alla sua Chiesa
un nuovo carisma. Nuovo, veramente nuovo perché, anche se radicato nel Vangelo, nella
Tradizione e nel magistero della Chiesa, porta una reale novità.

         Quale?

         Introduce nei vari modi di vivere del cristianesimo una spiritualità tipica,
particolare, che non si trova altrove e che manifesta la sua originalità nell'essere spiritualità
comunitaria, collettiva.

         Per essa non si va e non si può andare a Dio da soli, ma con i fratelli; non ci si può
santificare singolarmente, ma insieme; si trova l'unione con Dio non tanto ritirandosi in
solitudine, ma stando in mezzo al mondo in contatto con i fratelli in cui si ravvisa Gesù; non
vi è prescritto il silenzio, come norma di vita, ma piuttosto la parola come mezzo di
comunicazione.

         Per questa spiritualità perciò la parola è parte della vita stessa. Senza la parola noi
mutiliamo il nostro "vivere" fino a renderlo - si può affermare - inesistente.

         E allora, ripeto ancora una volta, occorre parlare: comunicare di più fra noi in casa,
in focolare, nei nuclei, nei centri, in ogni nostra comunità, quanto Dio ci mette in cuore di
cose belle, di propositi seri, di considerazioni utili ad una sempre più fervente vita ideale.

         Comunicare con quanti ci sono affidati senza lasciar intiepidire o, peggio, spegnere i
rapporti.

         Comunicare con quanti più si può, sapendo che, quando lo Spirito manda un
carisma, esso è destinato a tutti. Tenerlo perciò solo per sé stessi vuol dire derubare gli altri
di qualcosa che possono attendersi e non aver capito la magnanimità di Dio.

         Parlare, dunque, in tutti quei modi che sono già stati suggeriti l'altra volta.
         Lo so che tutti voi volete amare Dio. Anzi so che fra voi c'è chi vorrebbe amarlo -
senza presunzione, ma solo per amore - come mai nessuno lo ha amato dopo Maria. Ebbene,
perché ciò si realizzi, viviamo la nostra spiritualità con completezza e quindi anche con la
parola.

         E, per aiutarci in questo, ogni volta che il telefono squilla, che qualcuno bussa alla
porta, che ci viene richiesto di parlare di Dio e di ciò che lo riguarda; quando dobbiamo
scrivere una lettera o rispondere; quando siamo invitati a stendere un articolo o
un'intervista scritta, radiofonica o televisiva; quando si mette il piede in una scuola o come
studenti o come insegnanti, o in un'opera, ecc., ripetiamo con gioia a noi stessi: "Che
occasione". "Che occasione ho qui mai di amare Dio, amando questi fratelli anche con la
parola" E sarà una forte spinta per parlare.

         E "che occasione" sia allora il motto per vivere questo collegamento.

         E, sono certa, funzionerà. Io l'ho provato ed ha funzionato. Mi sono detta durante il
giorno, ogni volta che si presentava un'occasione: "Che occasione" e ha funzionato. A noi
tutti, dunque, ripetere questi atti d'amore durante il prossimo mese. E capirete come il titolo
di questo Collegamento è: "Che occasione".$doc1728$, 'drive_import', '01728-WEB-1991-08-29-che-occasione-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1728)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1729, 'ITA', $doc1729$Rocca di Papa, 26 settembre 1991

"Sei tu, Signore, l'unico mio bene"

(Cf Sl 15,2)

Carissimi,

         siamo nell'anno in cui il nostro Movimento approfondisce e si impegna nella nuova
evangelizzazione e vogliamo approfittare anche di questi collegamenti per allenarci sempre
più e sempre meglio a svolgere tale compito.

         In questi ultimi mesi è entrata in tutti, penso, la convinzione che ciò che caratterizza
e rende così feconda la nostra evangelizzazione è il fatto che facciamo precedere alla parola
la testimonianza; che per noi il "parlare" deve seguire il nostro "essere". Nello stesso tempo
abbiamo capito come - per la via comunitaria che seguiamo - lo stesso parlare è parte
dell'"essere": noi siamo veramente quelli che dobbiamo essere anche se comunichiamo. Ed
è questa coscienza che ci ha proiettati da sempre verso il prossimo, verso i prossimi e ci ha
fatto sfruttare innumerevoli occasioni per dare Dio alle persone.

         Questa volta vorremmo evidenziare quel cardine, quella pietra, su cui tutto deve
poggiare perché il nostro evangelizzare, che è anche comunicare, sia autentico.

         Vorremmo parlare di quell'impegno prioritario e imprescindibile perché tutto
l'edificio della nostra evangelizzazione poggi su basi sicure.

         Santa Teresa di Lisieux diceva che è meglio parlare con Dio che parlare di Dio,
perché nelle conversazioni con gli altri si può sempre introdurre l'amor proprio.

         Ha ragione, ma questo non è per noi un motivo sufficientemente valido perché, a
differenza della sua spiritualità piuttosto individuale, la nostra è, ripeto, una spiritualità
comunitaria: noi dobbiamo anche parlare di Dio.

         Tuttavia, certamente, dobbiamo parlare con Dio, dobbiamo amare anzitutto Dio con
quell'amore che è la base della nostra vita ideale e quindi anche della nostra
evangelizzazione e si estrinseca nella preghiera o nell'attuazione della sua volontà.

         Parlare, dunque, coi prossimi sì, cogliere ogni occasione per evangelizzare sì, ma
parlare anzitutto con Dio.

         Parlare, come?

         Eseguendo sempre meglio le pratiche di pietà che sono nostre proprie, secondo i
vari regolamenti; ma anche verificando, durante il giorno, attraverso qualche brevissima
preghiera, se il nostro cuore è veramente puntato in Lui, se è Lui l'ideale della nostra vita; se
regna su di noi, su tutto il nostro essere, da vero re; se Lo mettiamo veramente al primo
posto nel nostro cuore; se Lo amiamo sinceramente con tutti noi stessi.

         Intendo accennare a quelle preghiere-lampo che la Chiesa consiglia specialmente a
chi sta in mezzo al mondo e non ha tempo di pregare a lungo. Sono come frecce d'amore che
partono dal nostro cuore verso Dio, come dardi di fuoco: le cosiddette giaculatorie che
etimologicamente significano appunto dardi, frecce. Esse servono magnificamente a
raddrizzare il cuore verso Dio.

         Tempo fa nella liturgia della Messa si trovava un versetto che può essere
considerato una giaculatoria, bellissimo, che fa al caso nostro. Esso dice: "Sei tu, Signore,
l'unico mio bene".

"Sei tu, Signore, l'unico mio bene".

         Proviamo a ripeterlo durante il giorno, specie quando i vari attaccamenti
vorrebbero trascinare il nostro cuore su cose, su persone o su noi stessi: "Sei tu, Signore,
l'unico mio bene - diciamo -, non quella cosa, non quella persona, non me stesso; tu sei
l'unico mio bene, non altro. Questo mi ha insegnato l'Ideale, questo voglio e riscelgo tuttora:
te, unico mio bene".

         Proviamo a ripeterlo quando l'agitazione, o la fretta, ci vorrebbe far compiere male
la volontà di Dio del presente: "Sei. tu, Signore, l'unico mio bene e, quindi, è mio bene la tua
volontà, non quello che io voglio".

         Quando la curiosità, o la voglia di consolazione, ci spingerebbe ad anticipare
conoscenze di cose o di persone: "Sei tu, Signore, l'unico mio bene, non ciò di cui la mia
avidità, il mio orgoglio vorrebbero saziarsi".

         Proviamo a ripeterlo spesso e troveremo veramente il modo di raggiungere quel
"nulla", sull'immagine di Gesù abbandonato e Maria desolata, di cui abbiamo spesso parlato
e che tanto ci attrae. Ci risentiremo così, uniti a Dio e pieni di Lui e porremo e riporremo la
base del nostro essere vero, della nostra testimonianza necessaria, primo atto di
evangelizzazione.

         In tal modo tutto fluirà bene nella vita, in senso giusto.

         Allora sì che, quando apriremo la bocca, le nostre non saranno parole o, peggio,
chiacchiere, ma dardi anch'esse sulle anime, perché si aprano all'amore, perché accolgano
Gesù.

         Provate. Io ho anticipato anche per voi la prova. Sono certa che mi direte che quelle
poche parole: "Sei tu, Signore, l'unico mio bene" sono state una medicina per la vostra
anima, un tonico; hanno - direbbe santa Caterina da Siena - fatto in modo che il nostro cuore
sia lampada diritta.

         "Sei tu, Signore, l'unico mio bene".$doc1729$, 'drive_import', '01729-WEB-1991-09-26-sei-tu-signore-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1729)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1730, 'ITA', $doc1730$Rocca di Papa, 28 novembre 1991
Anche la vita!

         Anche oggi continuiamo a parlare della nostra nuova evangelizzazione.
         Come sappiamo, la base di essa è "essere": essere prima di parlare, essere prima di
annunciare.
         La volta scorsa abbiamo cercato di sottolineare ciò, aiutandoci a mettere e rimettere
con gioia e con frutto - come ho saputo - a re del nostro cuore Dio, Dio-Amore.
         E lo abbiamo fatto con la preghiera e in modo speciale con quella brevissima che
dice: "Sei tu, Signore, l'unico mio bene" (cf Sl 16,2).

         Ma il nostro Ideale insegna un altro modo per "essere". Esso consiste nell'unione con
Dio, nello stare uniti a Lui.

         Tutti noi - credo - abbiamo conosciuto più o meno l'unione con Dio e ciò sin dai
primi giorni del Movimento. E abbiamo sempre detto che essa è effetto dell'amore a Gesù
abbandonato. Gesù abbandonato, abbracciato, è un varco che apre la nostra anima
all'unione con Dio. Nulla come l'amore a Gesù abbandonato ci fa sperimentare questo
particolarissimo stato d'animo per il quale si ha la sensazione d'essere vicini a Dio - ed è una
realtà. Esso ci dona una gioia tipica, intima e profonda; ci dà sicurezza, ardore; ci rende
impavidi di fronte alle difficoltà; e rende remoto al nostro animo tutto ciò che di attraente,
ma semplicemente terreno, o meno che terreno, può esservi nel mondo e nelle sue creature.

         Sì, l'amore a Gesù abbandonato ci fa trovare l'unione con Dio.

         E sempre, lungo tutta la nostra storia, lo Spirito ci ha spinto a ravvivare nel cuore
questo amore nelle maniere più varie.

         Abbiamo imparato ad amarLo con predilezione, più d'ogni altra cosa; a fargli festa
ogni qual volta appare; ad accettarlo sempre, subito, con gioia; ad essere pronti a morire
piuttosto che non amarLo così, abbandonato; a vivere fra Lui e Maria desolata; a imitarLo
nel suo annientamento, nel suo essere "nulla".

         E, per grazia di Dio, l'unità con Dio ha continuato a fluire nelle anime del Movimento
e le ha portate così a vivere non più loro, ma a lasciar vivere Cristo in loro.
         Ed ecco: l'essere.

         Anche oggi dobbiamo vivere così.
         Del resto, questa e solo questa è l'autentica vita dei cristiani.
         Così pensavano i primi, i primi cristiani, subito dopo la morte, risurrezione e
ascensione di Gesù. Prendevano alla lettera le sue parole: "Chi vuol venire dietro a me ...
prenda la sua croce" (cf Mt 16,24). E ritenevano vero suo discepolo e, perciò, perfetto
cristiano, il martire che muore, come Gesù, di morte cruenta.
         Poi, quando è finito il periodo delle persecuzioni e il martirio non era più possibile,
pensarono ad un surrogato del martirio e lo trovarono nell'impegno anche eroico di
acquisire le virtù; lo vedevano come un martirio di desiderio e in seguito lo considerarono
equivalente al martirio cruento.
         Ed è questo modo di vedere la croce, di giudicare la sua assoluta necessità, per
essere seguaci di Gesù, che spiega l'ascetica cristiana di tutti i tempi, le penitenze di ogni
genere, i digiuni, le veglie, il desiderio, insomma, sempre presente nei cristiani di soffrire in
unione con Gesù, con Lui.

         Ed anche ora non può essere diversamente. Pure noi siamo chiamati ad un certo
qual martirio. Ho saputo, anzi, che non è inconsueto fra i membri del Movimento aver
avvertito, specie in giovane età, una chiamata al martirio. Ma a quale martirio?

         Se osserviamo ciò che lo Spirito ci ha sempre insegnato, vediamo che c'è un martirio
tipicamente nostro: è quello che comporta l'amore reciproco così come Gesù lo chiede.

         Esso domanda di amarci fra noi fino ad essere pronti a morire l'uno per l'altro. E
questo è martirio, un martirio bianco, se vogliamo, ma vero, perché domanda la vita.

         Un martirio quotidiano, anzi, di momento per momento.

         Forse, nonostante tutta la nostra buona volontà, noi non l'abbiamo ancora vissuto
proprio così. Ma solo in tal modo siamo veri cristiani, raggiungiamo la perfezione, appunto
come i martiri; e, con essa, l'unione con Dio, la presenza piena di Cristo in noi.

         Ed ecco: l'essere, premessa per la nostra evangelizzazione.

         E allora mettiamoci sotto. Rinnoviamo, perfezioniamo, ceselliamo l'amore reciproco.
E diamogli la misura della vita.
         E, per viverlo il più perfettamente possibile, di fronte ad ogni fratello che
incontriamo, per il quale lavoriamo, con cui parliamo per telefono ad es., aiutiamoci in
questo modo: diciamo nel nostro cuore queste parole: "Anche la vita", a significare: sono
pronto ad amarti così. Nessuno, del resto, ha maggior carità di chi dà la vita ... (cf Gv 15,13).

         Proviamo. "Anche la vita" è la parola per il prossimo mese. Per essa faremo grandi
progressi. Ne sono certa. E "Anche la vita" è il titolo - come vi ho detto - di questo
Collegamento.$doc1730$, 'drive_import', '01730-WEB-1991-11-28-anche-la-vita-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1730)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1731, 'ITA', $doc1731$Mollens, 24 febbraio 1994

Per essere un popolo di Pasqua

Carissime,

         s'avvicina Pasqua, la più grande festa dell'anno, e con essa la settimana santa
stracolma dei misteri più preziosi della vita di Gesù.

         Essi ci sono ricordati soprattutto il giovedì, il venerdì, il sabato santo e la domenica
della risurrezione e rappresentano per noi altrettanti aspetti centrali della nostra
spiritualità. Sono: la consegna del comandamento nuovo, l'istituzione del sacerdozio e
dell'Eucaristia, la preghiera dell'unità, la morte di Gesù Abbandonato in croce, la Desolata, il
Risorto.

         Noi li celebreremo con la Chiesa attraverso la santa liturgia, ma giacché la nostra è
una "via della vita" ci apprestiamo ad onorarli anche con la nostra vita.

         Ma come potremo rivivere almeno un po' misteri così numerosi e profondi? Ne
basta uno solo per accendere nella nostra anima la meditazione, per spingerla alla
contemplazione. Ne basta uno solo per santificarci - noi lo sappiamo.

         Abbiamo poi nel patrimonio della nostra spiritualità vari temi sull'uno e sull'altro
aspetto; abbiamo scritto a nostra edificazione alcuni libretti che vanno ad arricchire la già
straricca letteratura su ciascun argomento: "La carità come ideale", che approfondisce il
comandamento nuovo, "Uomini al servizio di tutti", che ci rivela che cos'è il sacerdozio per
Gesù e per la Chiesa, "L'Eucaristia", "L'unità e Gesù Abbandonato" e vari altri
approfondimenti su Maria nella sua desolazione, su Gesù Risorto...

         Che cosa vivere allora nell'appressarsi della settimana santa e durante quei giorni
benedetti?

         Io penso che, se viviamo la Pasqua, se lasciamo vivere cioè il Risorto in noi, abbiamo
il miglior modo per viverli tutti.

         Affinché il Risorto infatti splenda in noi, dobbiamo amare Gesù Abbandonato ed
essere sempre - come noi diciamo - "al di là della sua piaga" dove la carità è regina. E' lei poi
che ci spinge ad essere il comandamento nuovo in atto; che ci spinge ad accostarci
all'Eucaristia la quale alimenta questa carità divina nel nostro cuore e ci fa proprio essere
ciò di cui noi ci cibiamo che è appunto Gesù Risorto; è la carità che ci porta a vivere l'unità
con Dio e con i fratelli. E' per la carità che possiamo essere, in certo modo, altre Maria.
         Sì, non si possono vivere meglio i vari aspetti della vita di Gesù ricordati nella
settimana santa che proponendoci di far vivere ogni attimo il Risorto in noi.

         Carissime, questo vogliamo proporvi e questo cerchiamo di vivere.

         Saremo tutti assieme, con ciò, realmente quel Popolo di Pasqua che è parso a
qualcuno di intravedere nel nostro Movimento.

         In tal modo potremo capire meglio la passione, la morte e la risurrezione di Gesù
che vengono ripresentate dalla liturgia.

         E' questo un rinnovamento di tutto il nostro essere di membri dell'Opera di Maria,
che ci fa meno indegni di portare nel mondo il nostro Ideale.

         Tutto qui. E ancora auguri, auguri vivissimi a voi ed a quanti voi rappresentate.$doc1731$, 'drive_import', '01731-WEB-1994-02-24-per-essere-un-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1731)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1732, 'ITA', $doc1732$Sierre, 28 aprile 1994
Realizzare il nostro sogno:
nessun bisognoso

Carissime,

una delle più belle pagine scritte dal nostro Movimento nei primi tempi è quella riguardante
l'amore verso i poveri che il nuovo carisma andava infondendo nel nostro cuore. Dopo
averli incontrati e visitati nei loro tuguri, si invitavano a pranzo nelle nostre case. Per loro
erano la più bella tovaglia, le posate migliori, il cibo più scelto. Quando si aprì il primo
focolare sedevano a mensa una focolarina ed un povero, una focolarina ed un povero ...

         Oggi le centinaia di focolari nel mondo non possono ripetere quell'esperienza.
         Ma dove è andato allora l'amore per i poveri? Ora, come allora, siamo ben coscienti
dell'esame finale che ci farà Gesù: "Ho avuto fame e mi avete dato da mangiare. Ho avuto
sete e mi avete dato da bere;... ero nudo e mi avete vestito ..." (Mt 25,35-36).

Lo sappiamo. L'amore per i poveri non manca nella nostra vita. Opere e opere di carità e
opere sociali sono sorte in tutto il mondo proprio a tale scopo.

         Ma ciò che ci ha dato una certa speranza di riuscire a sovvenire regolarmente i
poveri, cominciando da coloro che appartengono all'Opera, è stata l'idea dell'Economia di
Comunione. Se noi attuiamo quella, col tempo, potremo vedere realizzata l'altra
meravigliosa pagina - questa volta della Chiesa nascente -: "La moltitudine aveva un cuor
solo ed un'anima sola... ogni cosa era fra loro comune... nessuno fra loro era bisognoso". (At
4,32-34)
Questo è l'ideale cui dobbiamo tendere con tutte le nostre forze, questo l'Ideale che deve fra
noi diventare realtà.

Quando si annunciò l'Economia di Comunione nel 1991 il Movimento intero ebbe un fremito
di gioia e tutti ne eravamo rimasti convinti e conquistati. Era evidente per noi che nella
stessa casa (l'Opera) non vi poteva essere chi ha fame e chi è sazio. E mille, mille iniziative
sorsero per aiutare i poveri.
         Si misero a disposizione terreni e case; ci si spogliò di ciò che si aveva di più caro: i
gioielli di famiglia, ad esempio; si pensò ai molti sistemi per orientare aziende ai fini
dell'Economia di Comunione. Fu uno spettacolo non solo in Italia, ma nel mondo.

         Poi anche questa "impresa" si incanalò accanto a tante altre cui tende il Movimento.

         Ma ora dobbiamo esaminare il cammino fatto e ciò che ci resta da fare per compiere
quella che ci sembra una volontà di Dio per noi. I nostri poveri, quelli che vivono in seno al
Movimento come interni, sono circa 5.000. E ben poco sollievo abbiamo potuto dare loro
finora. E' vero che le aziende piccole o grandi che vivono secondo l'Economia di Comunione,
a tutt'oggi, sono più di trecento, ma la realizzazione del nostro sogno resta ancora lontana.

         Che fare? Scoraggiarci di fronte a tanto impegno? No di certo. La Parola di vita ci
dice: "Non temere, continua solo ad aver fede" (Mc 5,36). Ed è ciò che io chiedo a me stessa
e a voi tutti: non temiamo, continuiamo a credere. Come il Signore ha dato il coraggio a
coloro che si sono impegnati finora, continuerà a darlo a tanti, tanti altri che aspettano
magari solo una spinta per buttarsi in questa meravigliosa avventura.

Naturalmente dobbiamo fare tutti la nostra parte. Tutti - nessuno escluso - devono
interessarsi, presso chi è responsabile, della situazione dell'Economia di Comunione nella
propria zona per incoraggiare, sostenere, suggerire, almeno pregare per quelli che si sono
cimentati, perché il Signore benedica gli sforzi, moltiplichi le braccia.

Avverto che con tutta la nostra buona volontà questa attività ha bisogno di una spinta per
camminare bella, piena di speranza come quando è nata, e questa preoccupazione voglio
condividerla con voi tutti.

Nel fare la vostra parte potrete avere qualche idea servendovi del nuovo Notiziario che sarà
presto in zona intitolato appunto: Economia di Comunione. Ha lo scopo di tenerci tutti
informati sulla situazione attuale.

         Allora in questo mese: Economia di Comunione e, per essa, come per tutti i problemi
e le necessità della nostra vita spirituale e fisica, far trionfare in noi la Parola: "Non temere,
continua solo ad aver fede".

Per il mese di luglio ci sarà poi l'altra, anche tanto consona al nostro problema: "... la mia
potenza si manifesta pienamente nella debolezza" (2 Cor 12,9), come a dire che, anche se ci
sentiamo inadeguati, la fede in Dio farà sì che Egli manifesti la sua potenza dando impensati
sviluppi all'Economia di Comunione.$doc1732$, 'drive_import', '01732-WEB-1994-04-28-realizzare-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1732)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1733, 'ITA', $doc1733$Rocca di Papa, 23 giugno 1994

Il patto

Carissimi,

         riprendiamo il nostro Collegamento dopo le vacanze estive.
         E già si pensa al nuovo anno ideale che si apre con settembre e ottobre.
         Esso sarà caratterizzato da uno studio profondo che tutto il Movimento farà sulla
nostra spiritualità dell'unità e praticamente sul suo essere collettiva, comunitaria.
         Studio che si tramuterà via via in pratica intensa di quei capisaldi che la distinguono,
di quegli strumenti che la caratterizzano.
         Il primo caposaldo su cui poggia è senz'altro il comandamento nuovo di Gesù:
"Amatevi a vicenda come io ho amato voi" (Gv 15,12).
         E' questa Parola di Gesù, assieme a quella dell'unità, la base della spiritualità
collettiva perché per attuarla non basta una sola persona. Ne occorrono due o tante, una
collettività, una piccola o grande comunità.
         Nell'attesa allora di conoscere la conversazione sul tema della spiritualità collettiva
che ho steso per tutti, ma in particolare per gli interni, non sarà male - penso - esercitarci un
po' in profondità su questo primo caposaldo, base di tutta la costruzione.
         E come facciamo in particolare?
         Io direi di ravvivare fra noi questo amore e perché il nostro agire abbia serietà, e si
segni quasi una nuova tappa nel cammino del nostro Santo Viaggio, consiglierei a voi ed a
me di ridichiararcelo questo amore fra noi, nei nostri focolari, nei nostri nuclei, nelle unità
gen, con tutti quelli con i quali normalmente conviviamo, anche se in maniere diverse. Fare
come fecero le prime focolarine quando si dissero: "Io sono pronta a morire per te; io per te,
tutte per ognuna", gettando così le fondamenta della nostra Opera. E poi vedere di vivere
conseguentemente con tutta l'intensità.
         Sapete che l'unità, mediante l'amore reciproco, non è che si operi una volta per
sempre. Essa va rinnovata ogni giorno mediante propositi e fatti.
         Così facendo, la lettura e l'approfondimento del mio tema durante l'anno avrà i suoi
profondi effetti, produrrà molti frutti, come vedo sta già operando in coloro che ne sono
venuti casualmente a conoscenza.
         E' sacra questa dichiarazione d'amore reciproco, questo patto che vi domando; è
solenne, anche se fatto nella semplicità; e non è privo di difficoltà. Con alcuni, infatti, sarà
facile pronunciarlo; con altri occorrerà preparare il terreno. E' un atto non privo di sacrificio
perché occorrerà alle volte vincere il rispetto umano, altre superare l'indolenza o il tran
tran spirituale in cui siamo magari caduti. Bisognerà praticare l'umiltà per far tacere l'amor
proprio, pagare, insomma, il primo costo del passaggio da un modo di vivere individuale ad
una spiritualità collettiva.

         Ma il Signore benedirà ogni sforzo e, se poi saremo fedeli a quanto abbiamo detto, ci
darà la gioia di scorgere la sua presenza, effetto dell'unità, dovunque ci giriamo.

         Ho saputo con quale zelo ed entusiasmo generale è stata accolta la mia lettera
sull'azione straordinaria a favore dei nostri cinquemila in difficoltà.

         Ed ecco che, dopo avervi chiesto, la volta scorsa l'amore a quelli che sono poveri fra
noi, oggi vi chiedo l'amore reciproco fra tutti come Gesù ci ha insegnato.

         Che il Signore ci dia di compiere con lo stesso entusiasmo e con lo stesso zelo anche
quest'altra caratteristica dei primi cristiani dei quali si diceva: "Guarda come si amano e l'un
per altro sono pronti a morire" 1; e di scrivere perciò nel nostro Movimento quest'altra
splendida pagina.

         Coraggio, allora, e avanti! Nulla ci freni.

         Se saremo fedeli, la spiritualità collettiva ci farà santi, farà i nuovi santi, ci
trasformerà in un popolo di santi. E' questo ciò che Dio vuole da noi, per la sua gloria.$doc1733$, 'drive_import', '01733-WEB-1994-06-23-il-patto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1733)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1734, 'ITA', $doc1734$Sierre, 25 agosto 1994

“Comunione d'anima"

Carissime,

         La volta scorsa ho consigliato di dichiararci reciprocamente l'amore soprannaturale
vicendevole, di rifare cioè il "patto", come noi diciamo, per muovere nuovamente il primo
passo nella nostra spiritualità collettiva. Abbiamo posto con ciò, abbiamo fissato nel nostro
cuore, quello che è il primo caposaldo di essa.

         E le reazioni sono state veramente meravigliose! Da tutto il mondo mi sono arrivati
echi e notizie che confermano la "rivoluzione" provocata da questo nostro rinnovato
atteggiamento, come mi è stata comunicata anche la gioia conseguente per aver attuato
qualcosa che realmente piace al Cuore di Gesù.

         Questa volta passiamo ad un secondo caposaldo. Esso è la cosiddetta "comunione
d'anima".

         Ne abbiamo tante volte sentito parlare. E più o meno è stata già attuata, almeno in
qualche maniera, in tutto il Movimento.

         Oggi cerchiamo di puntualizzarla meglio.

         Se è una pratica cristiana, se serve alla nostra santificazione, anche in essa ci dovrà
essere il lato cruciale; anch'essa, come il "patto", potrà forse costare. Ma è evidente che, se si
è pronti a dare la vita per i fratelli, come con la grazia di Dio vogliamo, si deve essere
disposti almeno ad aprir loro il proprio cuore.

         La "comunione d'anima" va fatta fra noi per rendere comuni i beni spirituali che
possediamo, e concorrere così alla santità altrui come alla nostra. Noi - lo sappiamo -
"siamo" tanto in quanto "siamo per gli altri".

         Si mette in comune tutto quello che è bello ed utile ai fini della santità e non per
ultimi i frutti della nostra meditazione.

         Noi tutti "interni", infatti, siamo chiamati dai nostri regolamenti a dedicare un
tempo (mezz'ora? venti minuti? dieci minuti?) alla meditazione o - come dicono i gen -
all'"andare in profondità".

         In questo modo ci si confronta ogni giorno attraverso la lettura della Sacra Scrittura,
di brani della nostra spiritualità, di scritti dei santi o di documenti della Chiesa atti allo
scopo, col nostro Ideale. Ci si mette alla presenza di Dio; si considera lo stato della nostra
vita spirituale; ci si lascia illuminare da un argomento o da un altro che abbiamo sott'occhio;
si parla con la Santissima Trinità, con Gesù o il Padre o lo Spirito Santo, oppure con Maria di
tutto ciò che interessa la nostra anima; si fanno propositi da attuare conseguentemente.

         E' bene tutto questo? E' ottimo e va fatto sempre meglio, possibilmente ogni volta
con maggiore diligenza.

         Ma il semplice far meditazione, anche perfettamente, non è ancora un caposaldo
della nostra spiritualità collettiva. Fanno così e forse meglio di noi, coloro che seguono
spiritualità individuali. E fanno meditazione anche fedeli di altre Religioni.

         Noi siamo chiamati a portare a beneficio anche degli altri quello che il Signore ci ha
fatto comprendere nella meditazione e quello che è stato il frutto di essa. E si fa questo nella
"comunione d'anima".

         E' necessario, allora, stabilire con i nostri fratelli o le nostre sorelle un tempo per
fare ciò. Vedete voi con che ritmo: due volte in settimana? Una volta? Una volta ogni quindici
giorni? o quando è possibile incontrarsi? Dobbiamo ricordare, a nostro incoraggiamento,
che quello che non si comunica si perde; mentre ciò che si dona torna rafforzato nell'anima
del donatore oltre che risultare di utilità per gli altri.

         Un esempio della "comunione d'anima" ce lo dà Maria di fronte alla cugina
Elisabetta. Nel "Magnificat" la Madre di Gesù, la tutta umile, parla di sé, di ciò che Dio ha
operato in Lei e lo fa a gloria di Dio. E' evidente che tra lei e la cugina vi era già l'amore
reciproco, ma il "Magnificat" lo ha rinsaldato.

         Così dobbiamo fare anche noi, stando attenti che tutto serva unicamente al bene dei
fratelli e che nulla abbia a che fare con la nostra vanagloria.

         Cominciamo allora a mettere in pratica con regolarità questo secondo caposaldo
della nostra spiritualità. Questa comunione spirituale darà sempre nuovo sprint alla nostra
vita ideale. Essa ci aiuterà ad amare meglio Dio nella sua volontà, che per noi è appunto
vivere una spiritualità collettiva ed a tradurre in vita con ciò anche la Parola del mese di
ottobre che domanda di amare Dio "con tutto il tuo cuore, con tutta la tua mente, con tutta la
tua forza".$doc1734$, 'drive_import', '01734-WEB-1994-08-25-comunione-danima-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1734)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1735, 'ITA', $doc1735$Rocca di Papa, 27 ottobre 1994
L’
"ora della verità"

Carissime,

         questa volta vi presento un altro strumento tipico e utile alla spiritualità collettiva e
senz'altro il più impegnativo e il più difficile per il nostro uomo vecchio. Ma, data la misura
con la quale vogliamo amare il prossimo: fino a dare la vita, penso attuabile.

         Si tratta dell'"ora della verità".
         Essa, anche se abbastanza diversa, ricorda una pratica che si riscontrava fra i primi
cristiani i quali, desiderosi di perfezione per mantenersi alla sequela di Gesù, ed amanti dei
fratelli nei quali avevano piena fiducia, arrivavano persino a volte a confessare l'uno all'altro
i propri peccati.
         Qui si tratta di tutt'altra cosa. I peccati noi li diciamo ai confessori, ma, per la carità,
che pure noi nutriamo per i nostri simili e per il desiderio di contribuire a santificare con
noi anche loro, ci impegniamo ad offrire ad essi, con amore, quanto possiamo osservare in
loro di negativo e positivo.
         E' una pratica esigente, ma serve molto al Santo Viaggio.
         Nel Movimento si era soliti attuarla sin dai primi tempi ed abbiamo di essa
un'impressione assai bella.
         Il fatto è che un fratello può essere veramente utile all'altro così come una mano sa
lavare l'altra. Ricordo al proposito un proverbio africano il quale dice che il fratello è come
un occhio che abbiamo dietro. E sta a significare che il fratello vede dove noi non vediamo.

         Occorrerà radunarsi in un gruppo non troppo numeroso. Per esempio in un focolare
o in un nucleo o in una unità gen, in una unità gens o in una piccola comunità, ecc.

         Perché porti i suoi frutti, occorrerà avere un po' di tempo a disposizione ed agire
con calma.

         Dovrà essere presente un responsabile come moderatore per confermare o
correggere quanto viene detto.
         Sarà bene prima di ogni altra cosa rinnovare il Patto fra tutti, perché tutto si svolga
solo nell'amore pieno.

         E con che animo occorrerà si disponga chi viene sottomesso al fraterno giudizio
degli altri? Col pensiero di essere sempre un servo inutile e infedele, di essere nulla, perché
tale è ognuno dinanzi a Dio. Così né si turberà, né si esalterà per tutto quanto viene detto.

         Si tirerà poi a sorte uno del gruppo. E, sotto la guida del moderatore, ogni fratello
dirà di quello scelto qualche difetto, qualche imperfezione, qualche neo che gli sembrerà
d'aver riscontrato in lui. Rifacendo poi il giro, ognuno dirà pure qualche virtù, qualche
pregio che avrà potuto osservare.

         Alla fine - questa la nostra continua costatazione - tutti sono invasi da una grande
gioia e non si sa perché. E', forse, l'esperienza della libertà cristiana; l'attuazione della
Parola: "La verità vi farà liberi" (Gv 8,32).

         Ma quando e come si fa "l'ora della verità"?
         Sarà bene farla una volta ogni tanto. Ad esempio due volte all'anno o, per chi è più
impegnato nel Movimento, una volta al mese.
         Può essere durante un ritiro o un convegno.

         E', "l'ora della verità", una specie di cosmesi spirituale. E, come quando si pratica il
cosmetico su un volto, toglie le impurità e rende morbida ed elastica la pelle e dà un senso
di benessere, in modo simile succede per le nostre anime.

         L'"ora della verità" è una vera benedizione nella nostra corsa verso la santità.
Vediamo, al momento opportuno, di praticarla con gioia. Dio ama chi dà con gioia.

         Contemporaneamente in questo mese viviamo la Parola di vita di dicembre. Essa
dice: "Prego che la vostra carità si arricchisca sempre più in conoscenza e in ogni forma di
discernimento, perché possiate distinguere sempre il meglio" (Fil 1,9-10). E' un invito alla
carità, cioè all'amore di Dio, al fare la volontà di Dio - comprendente anche l'amore del
prossimo -, volontà di Dio che dovremo cercare di conoscere sempre più in profondità per
compierla meglio.

         Avanti, allora: "Santi insieme" a tutti i costi, senza la minima paura.$doc1735$, 'drive_import', '01735-WEB-1994-10-27-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1735)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1736, 'ITA', $doc1736$Rocca di Papa, 22 settembre 1994

"Comunione delle esperienze

della Parola di vita"

Carissimi,

         siamo ben oltre la metà del tempo che abbiamo dedicato ai capizona per conoscere il
lavoro svolto in quest'ultimo anno da tutto il Movimento e suggerire le linee da seguire in
futuro.

         E vi assicuro che la gioia nel mio cuore ed in tutti i responsabili è veramente grande.

         Il fatto è che, da quanto posso costatare, tutto progredisce e molto più degli altri
anni: l'alberello dell'Opera è decisamente verde.

         Questo vuol dire che voi tutti nel mondo, assieme ai capizona, avete lavorato assai e
bene. Avete compiuto l'Opera fin dove doveva arrivare nel '93-'94 e avete con ciò dato gloria
a Dio. Gesù, infatti, dice: "Ho glorificato il Padre compiendo l'Opera che mi ha dato da fare"
(Gv 17,4).

         Grazie, dunque, grazie veramente a tutti voi, che ascoltate, a nome di Maria, la Madre
nostra, la vera Presidente, che io rappresento, del nostro Movimento.

         E veniamo al pensiero dell'attuale Collegamento.

         Le volte scorse abbiamo approfondito e vissuto, con maggior impegno, i due primi
"strumenti" della nostra spiritualità collettiva: "il patto" e "la comunione d'anima". E l'uno e
l'altra hanno portato i loro benefici effetti. Me l'avete detto voi nei vostri fax e, qui a Rocca,
l'ho costatato durante gli esercizi spirituali di tutto il Centro, compresi i capizona, quando,
in più ore stabilite, ognuno è stato invitato a praticare la "comunione d'anima". Tutti ne
sono rimasti soddisfatti e desiderosi di impostare sempre i nostri convegni più spirituali
nella medesima maniera.

         Questa volta parliamo della "comunione delle esperienze della Parola di vita" (o sul
motto del Collegamento che in genere la riassume). Essa non va confusa con la "comunione
d'anima", così come l'ho descritta la volta scorsa, ma è una pratica a sé stante risalente,
come sapete, ai primi giorni della vita del Movimento.

         La Parola di vita, infatti, ha per noi un'importanza fondamentale. La nostra Opera è
nata come un'incarnazione di essa.

         Per la Parola vissuta con radicalità Cristo si forma in noi.
         E' importantissima poi la Parola perché, per suo mezzo, facciamo nostra tutta quella
grande regola (così abbiamo visto il Vangelo sin dai primi tempi) da cui è stata tratta la
nostra spiritualità. Da esso, dal Vangelo, infatti, apprendiamo certamente le parole
riguardanti la carità, ma anche quelle che toccano le altre virtù che noi siamo chiamati a
vivere perché richieste dai nostri statuti: la fede, la speranza, la temperanza, la giustizia, la
fortezza, la prudenza, la pazienza, la purezza, l'umiltà, la mitezza, la pietà, l'obbedienza, la
povertà, la misericordia, ecc.

         E' importantissimo quindi vivere la Parola. Ma ciò non basta.

         Noi siamo chiamati a mettere in comune le nostre esperienze su di essa. Perché?
Perché il Signore vuole così in una spiritualità collettiva ed il non praticare questa
comunione è una grave omissione.

         I santi non dubitano tanto ad attribuire al nemico degli uomini (al diavolo) questa
trasgressione.

         Sant'Ignazio di Loyola parla in una sua lettera della "falsa umiltà", che sarebbe
un'arma che il diavolo usa per danneggiare le persone. Dice: "Vedendo il servo di Dio tanto
buono e umile che... pensa di essere del tutto inutile... gli fa pensare che, se parla di qualche
grazia (come sarebbe la luce che viene dal vivere la Parola, aggiungiamo noi), se parla di
qualche grazia concessagli da Dio Nostro Signore, grazia di opere, propositi e desideri, pecca
con (una) specie di vanagloria perché parla a suo onore. Procura quindi che non parli dei
benefici ricevuti dal suo Signore, impedendo così di produrre frutto in altri e in se stesso,
dato che il ricordo dei benefici aiuta sempre a cose più grandi"1.

         Io aggiungerei che qualche volta non si pratica la comunione sulle esperienze della
Parola di vita per pigrizia o perché trascinati da un falso attivismo e più portati quindi a
guardare fuori piuttosto che dentro.

         No! Noi dobbiamo essere fedeli ai nostri doveri, dobbiamo impugnare ogniqualvolta
è volontà di Dio (e questo lo stiamo stabilendo per tutte le varie vocazioni dell'Opera)
questo ulteriore strumento della nostra spiritualità collettiva.

         Intanto in questi ultimi giorni del mese di ottobre nutriamoci della Parola che dice:
"... amerai il Signore Dio tuo con tutto il tuo cuore, con tutta la tua mente e con tutta la tua
forza" (Mc 12,30).

         E' bellissima! Ci ricorda chi abbiamo scelto all'inizio della nostra conversione e ci
invita ad amarlo con tutti noi stessi e per se stesso. Noi, infatti, siamo spesso precipitosi e
per amare Dio ci impegniamo subito ad amare la sua volontà che sono i nostri compiti, ad
amare i prossimi, ecc. Ma ciò può portarci ad una dimensione unicamente orizzontale della
nostra carità.
         Se il fare la volontà di Dio è garanzia del nostro amore a Dio, questo non ci dispensa
dall'amarlo, adorarlo, glorificarlo per se stesso anche in momenti non dediti strettamente
alla preghiera.

         E a ciò in questo squarcio di mese dobbiamo puntare.

         E allora per concludere: vivere bene l'attuale Parola di vita e così in novembre la
prossima; e continuare o ripristinare la nostra comunione delle esperienze sulla Parola
stessa.

         Un sentitissimo saluto a tutti voi da parte di tutti noi e l'assicurazione che ognuno è
pronto a dare la vita per voi.$doc1736$, 'drive_import', '01736-WEB-1994-09-22-comunione-delle-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1736)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1737, 'ITA', $doc1737$Rocca di Papa, 24 novembre 1994
Il colloquio

Carissime,

         ed eccoci al quinto strumento della nostra spiritualità collettiva, quello che noi
chiamiamo 'il colloquio'.

         Anch'esso serve molto al progresso della nostra vita spirituale.

         Durante l'ora della verità, che vi ho fatto conoscere nell'ultimo Collegamento, sono i
fratelli e le sorelle a dire qualcosa di negativo o di positivo sul nostro conto.

         Ma anche se, per certi particolari, il fratello vede di noi quello che noi non sappiamo
vedere, senza dubbio nessuno conosce meglio noi di noi stessi.

         Noi siamo a conoscenza dei nostri desideri di perfezione, delle luci che ci consolano,
dei propositi che di tanto in tanto formuliamo, dei risultati, ma anche delle ombre che ci
turbano, delle paure e delle lotte che sosteniamo per andar avanti.

         Noi sappiamo - se lo Spirito ci illumina - a che punto può essere la pianticella della
nostra unione con Dio...

         E di cose del genere, come ci è stato suggerito un'altra volta, mettiamo al corrente i
nostri fratelli nella comunione d'anima.

         Tuttavia come, per mantenere la salute del corpo, non sono sempre sufficienti le
nostre cure ma ci affidiamo a persone esperte come magari per un check-up completo; come
non basta lavare e curare con amore la nostra automobile, per viaggiare sicuri, ma occorre
di tanto in tanto l'occhio esperto di un meccanico, così è bene controllare di tempo in tempo
l'andamento della nostra anima con chi conosce più di noi la vita dello spirito.

         E' per questo che si consiglia il colloquio con un fratello o con una sorella più avanti
di noi per esperienza o più adatta, per quella grazia particolare che ha nei nostri riguardi.

         Ed è per questo che pure noi saremo alle volte chiamati a fare dei colloqui con
qualcuno che conosce meno di noi la strada della perfezione.

         Anche Gesù faceva colloqui con singole persone. Il Vangelo ne riporta alcuni. E sono
stati importanti come i suoi discorsi alle folle.
         Egli parlò, ad esempio, da solo con la samaritana (cf Gv 4,1-26), come parlò di notte
con Nicodemo (cf Gv 3,1-21).

         Visto che si trovava ad un pozzo ed aveva sete, chiese alla samaritana da bere e,
nella stessa circostanza, le rivelò la sua situazione: aveva vissuto con cinque uomini nessuno
dei quali era suo marito, come non lo era quello che aveva in quel momento.

         Pur tuttavia, continuando il colloquio, Gesù parla a quella donna addirittura del
dono di Dio, la grazia, che ci fa figli di Dio e le rivela persino se stesso come Messia: "Sono io,
io che ti parlo" (Gv 4,26).

         Rivelazioni grandiose, divine... ad una povera samaritana, con la quale, secondo le
usanze, Gesù non avrebbe dovuto parlare.

         E a Nicodemo, di cui conosceva la fede e la pietà, Gesù dice che chi non è generato
dall'Alto non può vedere il Regno di Dio; che dunque occorre rinascere dall'acqua e dallo
Spirito per mezzo del battesimo.

         Altra rivelazione altissima riguardante il Regno. Tanto Gesù amava le persone!

         Ed è proprio da Lui che occorre imparare a fare i colloqui.

         Egli non chiude gli occhi sulla realtà delle persone che ha davanti: la samaritana
peccatrice, Nicodemo, uomo di pietà, anche se pauroso. E in tutti i casi Egli trova il modo di
rivelare loro le grandi realtà che è venuto a donare al mondo.

         Così dobbiamo comportarci noi nei colloqui che facciamo ai nostri fratelli: dobbiamo
partire dalla loro situazione presente, che verremo a conoscere se ci metteremo
nell'atteggiamento giusto (quello di amarli con tutto il cuore e la mente) e se saremo
totalmente vuoti (come ci insegna il mistero di Gesù Abbandonato), perché il fratello possa
aprirsi completamente, svuotando la piena che a volte ha nel suo spirito, nel nostro cuore, e
si dia il via così alla realizzazione fra noi di quel rapporto trinitario che dobbiamo stabilire
con lui.

         Poi, ascoltando lo Spirito che certamente parla in noi se abbiamo amato, parlare,
pronti non solo a ridonare la pace e la serenità al fratello, ma a rivelargli nuovamente, nelle
mille sfumature, l'Ideale che un giorno lo ha illuminato e trascinato per la via della
spiritualità collettiva.

         E come dobbiamo comportarci se siamo noi in posizione di ricevere?

         E' già chiaro. Dobbiamo disporci anche noi a stabilire con il fratello o la sorella, che è
presente per aiutarci, un rapporto trinitario. Ed anche in questo caso è maestro Gesù
Abbandonato, il vuoto.
         Ma qui occorre creare il vuoto in noi donando la nostra situazione spirituale con le
sue lotte e le sue vittorie, i suoi regressi e i suoi progressi.

         E poi, mettendoci in atteggiamento di ascolto, sicuri che lo Spirito Santo darà la sua
luce a chi ci deve illuminare, e che è soprattutto a Lui, allo Spirito Santo, che dobbiamo la
nostra gratitudine se siamo stati aiutati, sollevati e incoraggiati.

         Se tutto procederà come vi ho detto, anche qui, come nell'ora della verità, il risultato
sarà una profonda gioia: gioia per la pace ritrovata o aumentata, gioia per vedere ancora e
sempre meglio il nostro cammino dietro a Gesù, causa di ogni nostra felicità.

         Questi colloqui sarà bene farli due o tre volte all'anno, o più spesso in casi
particolari, quando ce ne fosse bisogno.

         Nel prossimo mese di gennaio viviamo intanto con amore la Parola di vita che dice:
"Io sono la vite, voi i tralci. Chi rimane in me ed io in lui, fa molto frutto, perché senza di me
non potete far nulla" (Gv 15,5).

         Leggete il commento: penso che vi piacerà, ma soprattutto attuiamola in ogni
momento della nostra giornata.

                                                                                         Chiara$doc1737$, 'drive_import', '01737-WEB-1994-11-24-il-colloquio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1737)
on conflict (document_id, language) do nothing;
