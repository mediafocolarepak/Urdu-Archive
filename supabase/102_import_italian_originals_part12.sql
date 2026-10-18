-- 102_import_italian_originals_part12.sql (12/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1778-1797 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1778, 'ITA', $doc1778$Castel Gandolfo, 18 febbraio 1999

Colui che deve precedere

         Stiamo vivendo l'anno in cui vogliamo approfondire il rapporto con Dio, la
preghiera, secondo quanto abbiamo sentito nel tema di quest'anno: "L'amore eleva".

         E' il nostro dovere quotidiano, aiutato anche dai brani che ci sono stati spediti dal
Centro.

         Ed anch'io, naturalmente, sono in questa linea.

         E' per ciò che ritengo utile, oggi, con voi fare un po' di comunione d'anima, come noi
diciamo, e dirvi una mia piccola esperienza.

         Un giorno mi ero proposta, come altri spero, come dice e vuole Gesù, di "pregare
sempre" offrendo a Lui ogni azione preceduta da un "Per Te". Ero stata, con la grazia di Dio,
particolarmente fedele a questo impegno. Cosicché, a conclusione della giornata, in un
colloquio con Dio, Gli chiesi se era contento di me o, se non lo fosse, che mi correggesse.

         Mi sembrò di avvertire in fondo al cuore la sua risposta, che può esser espressa così:
"Il tuo modo di vivere oggi, offrendo a Dio ogni tua azione con un 'Per te', mi è stato
certamente gradito, ma potrebbe benissimo essere anche di chiunque segue una spiritualità
individuale. Tu sei chiamata ad altro. Da te io esigo qualcosa di diverso. La tua vocazione
richiede che tu, prima di tutto, metta a base di ogni tua azione, anche offerta con un 'Per Te',
l'amore vicendevole con le tue sorelle e i tuoi fratelli. Il tuo primo impegno perciò deve
essere quello di essere sempre disposta a dare la vita per loro, affinché trionfi l'unità".

         Ho capito la lezione.

         Certamente, dopo tanti anni di vita spirituale, avevo cercato, anche in quel giorno, di
vivere il comandamento nuovo, ma non come mio primo dovere.

Ho cercato subito allora chi mi stava vicino, disposta ad esser pronta a morire anche per lui,
per lei e quindi ad assumere tutti quei comportamenti conseguenti e, solo su questa base, ad
offrire a Gesù ogni azione con un "Per Te".

         Sono più di cinquant'anni che mi dico e vi dico che la "norma delle norme", quindi
anche la regola base per poter pregare, è l'unità.

         Eppure occorre sempre ravvivare in cuore tale nostro obbligo, occorre sempre
ricominciare.

         Quanto vi ho confidato consoli ora soprattutto chi, in questo momento, trovasse
difficoltà in questo particolare così essenziale della nostra vita spirituale. E ricordi che Gesù
fra noi può sempre rinascere in un perenne Natale.
         Carissimi, facciamo ogni sforzo per non dimenticare ciò, o meglio per non
dimenticare Colui che deve precedere ogni cosa. E' Egli la grande novità che siamo chiamati
ad offrire al mondo.

         Quale onore poter vivere questa vocazione! Quale pienezza di gioia!

         La nostra è Opera di Maria, di Maria nel senso che è sua.

         Ma, se l'Opera è sua, anche noi, ciascuno di noi, singolarmente, siamo suoi.
Dobbiamo, infatti, essere altrettante piccole Maria.

         E la funzione della nostra spiritualità è proprio questa: darci la possibilità di
ripetere, in certo modo, Lei qui sulla terra, di imitare Lei.

         A Maria - come sappiamo – possiamo attribuire tanti privilegi: è immacolata, è stata
assunta in Cielo, è Regina del mondo.

         Ma ciò che la fa grande più d'ogni altra cosa, è la sua maternità divina, per cui Lei
può dire figlio al Verbo incarnato nel suo seno, come il Padre Celeste lo dice al Verbo in seno
alla Trinità: prerogativa che non si comprenderà mai abbastanza.

         Eppure è proprio nella sua maternità che noi possiamo, a nostro modo, imitarLa,
vivendo in maniera che Gesù sia sempre "generato" in mezzo a noi dal nostro reciproco
amore.

E imitare Maria nella sua maternità divina è certamente più possibile a chi segue una
spiritualità comunitaria, come la nostra.

         Preoccupiamoci, allora, d'essere sempre viva espressione della nostra tipica
vocazione, perché se ci fosse chiesto: "Chi sono i focolarini?" Oppure: "Chi sono i membri del
Movimento dei Focolari?", possiamo rispondere: coloro che offrono sempre, realmente Gesù
al mondo, affinché Egli, come una volta, lo possa ancora illuminare, educare, guidare per
giusti sentieri, e farvi nascere e crescere così un popolo tutto suo, che orienta l'umanità alla
fraternità universale.

         Noi focolarini non possiamo prescindere da questa sua presenza. Saremmo un non
senso. Sarebbe tradire la chiamata di Dio.

         E allora - ripetiamolo - il nostro impegno sarà questo: protesi a stabilire e
mantenere Gesù in mezzo a noi, offriamo a Lui ogni nostra azione con un "Per Te".$doc1778$, 'drive_import', '01778-WEB-1999-02-18-colui-che-deve-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1778)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1779, 'ITA', $doc1779$Castel Gandolfo, 27 maggio 1999
L'ascolto

Carissime,

         penso oggi di narrarvi un episodio della storia del nostro Movimento, poco o nulla
conosciuto, che può darvi gioia. Ne sono venuta a conoscenza anch'io solo recentemente.

         Era il 1957, anno nel quale avevamo un contatto profondo con una personalità
ecclesiastica di valore, allora molto nota: il gesuita padre Riccardo Lombardi, che, ad un
certo punto, è stato molto interessato al carisma del nostro Movimento dal quale era
fortemente attratto.

         In quel tempo egli, che la gente chiamava "l'altoparlante di Dio", annunciava sulle
piazze d'Italia, gremite di folle attentissime, come nocciolo del suo messaggio, un "ritorno di
Gesù"; non certo il ritorno di Gesù alla fine dei tempi, ma un suo ritorno che non precisava.

         Era estate e i membri del Movimento, presenti in montagna a Fiera di Primiero nel
Trentino, stavano dando vita all'ottava Mariapoli estiva.

         Padre Lombardi era salito lassù, pure lui, per approfondire la nostra vita.

         Un giorno è stato invitato da qualcuno di quei luoghi a tenere un discorso nella
piazza del paese a quanta gente sarebbe arrivata.

         Poiché, però, in quella valle i principi spirituali del nostro Movimento erano
abbastanza noti e si pensava che la gente attendesse dal padre, nostro ospite, qualcosa su di
essi, noi, pur contenti di quella circostanza, abbiamo preferito che qualcuno, che conosceva
bene il Movimento, aggiungesse a quel discorso qualche parola. Ed era stata incaricata per
questo una delle mie prime compagne, la Graziella.

         Come potrete capire non fu certo facile per lei salire sul palco dopo una così celebre
personalità. Ma lo ha fatto per amore.

         Narrò la piccola-grande storia, perché storia sacra, di un minuscolo popolo, il nostro,
visitato pochi anni prima da un carisma dello Spirito Santo.

         Parlò e non dimenticò certamente uno dei valori spirituali sublimi più tipicamente
nostri che il Movimento porta nel suo seno: la presenza di Gesù dove due o più sono uniti
nel suo nome, nel suo amore.

         Mentre stava concludendo il suo intervento, s'accorse che, dietro di lei, qualcuno
sembrava piangesse.
         Si volse: era proprio padre Lombardi, il quale, colpito evidentemente da quelle
parole, prese il microfono e disse che era proprio quello il ritorno di Gesù che lui
annunciava, del quale si sentiva come un Giovanni Battista.

         Forse non si fece troppo caso, allora, a quelle parole. Ma io ora, a conoscenza di esse,
e per aver sperimentato allora in quell'anima grande la presenza di un dono speciale, ne
sono rimasta, con altri, toccata e soprattutto grata.

         Grata in modo speciale a Dio d'averci ri-rivelato - se così si può dire - una sua
presenza, allora poco conosciuta nella Chiesa, almeno nella pratica dei cristiani comuni.

         Grata per averci suggerito di mettere Gesù fra noi come norma delle norme del
nostro agire, in pratica come regola nostra. E' Lui, fra il resto, che dà particolare valore a
tutto quanto noi facciamo.

         Ultimamente, raccontando qualcosa del nostro Movimento nelle nazioni che ho
visitato, ho sempre spiegato come, sin dall'inizio, chi ci incontrava, non s'imbatteva tanto in
un Movimento o in una comunità o in una corrente spirituale..., incontrava Gesù. E ciò
perché le nostre esperienze evangeliche ci avevano convinto e convincevano molti che
anche oggi Gesù manteneva le sue promesse, per cui si esclamava: "Gesù è vivo".

Oggi voglio aggiungere: perché Egli realmente era in mezzo a noi.

         Gesù in mezzo a noi! E' da qualche mese che parliamo di Lui, che ci impegniamo a
vivere in maniera tale da non perderlo mai, ma sempre generarlo e rigenerarlo fra noi, come
dice Paolo VI.

         Ho sottolineato ultimamente la grandezza di Maria come Madre di Dio. Ho detto
quant'è divinamente meraviglioso che come il Padre nella Trinità chiama Figlio il Verbo,
così Maria chiami Figlio il Verbo incarnato.

         Ora penso che non sia sbagliato dire che Gesù in mezzo a noi è figlio del nostro
amore reciproco, quindi di noi, perché così è.

         Non aveva detto un giorno Gesù che chi fa la volontà di Dio è suo fratello, sorella e
madre? (cf Mt 12,47).

         Possiamo, dunque, anche noi essere, in qualche modo, sua madre.

         Ma ad un patto però: che ci amiamo come si deve.

         L'ultima volta ci siamo impegnati ad un "farci uno" reciproco più profondo.

         L'effetto?

         L'ho riscontrato più di una volta durante questo mese.
         Di fronte al nostro amore che non vuol limitarsi ad "essere pronto a dare la vita" per
il fratello, ma a "morire" sul serio, a "non essere" per essere, per essere amore, qualcuno ha
affermato d'aver ammirato nelle persone del Movimento un grande "ascolto".

         "Sanno ascoltare". "C'è ascolto".

         E' un nuovo commento a questo modo di amare, un modo che piace assai, specie
oggi in questi tempi.

         La gente, in questo mondo tumultuoso, disturbato da tanti rumori, da tanti suoni, da
tante chiacchiere, ha bisogno di essere ascoltata, che significa amata sul serio.

         Perfezioniamo allora, nei prossimi mesi, quest'atteggiamento di sapore così
mariano.

         Promettiamoci: oggi ascolterò meglio ogni mio prossimo.

         Avremo sicuramente la presenza di Gesù in mezzo a noi.$doc1779$, 'drive_import', '01779-WEB-1999-05-27-lascolto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1779)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1780, 'ITA', $doc1780$Rocca di Papa, 17 giugno 1999

Come vivere il Sinodo dei Vescovi 1999

         Come alcuni di voi già sanno, il Santo Padre Giovanni Paolo II, nella sua bontà, ha
voluto annoverare anche me fra gli uditori italiani da lui designati per il prossimo Sinodo, il
secondo sull'Europa, che si terrà a Roma in ottobre.

         Per questo ho cominciato, sin d'ora, a prepararmi leggendo il cosiddetto
Instrumentum laboris che viene preparato sempre prima di quest'evento, col concorso di
Vescovi di tutto il mondo, quale, appunto, strumento di lavoro.

         Questa lettura mi ha interessato ed attratto sin dal titolo della prossima Assise. Esso
recita: "Gesù Cristo vivente nella sua Chiesa sorgente di speranza per l'Europa", come a dire
che, se l'Europa può avere una speranza, questa deve poggiare su Gesù presente nella sua
Sposa.

         E voi capite subito come, di fronte a tali parole, non mi è stato difficile pensare a
quella particolare presenza di Gesù nella comunità che egli ci ha donato quando ha detto:
"Dove due o più sono riuniti nel mio nome, io sono in mezzo a loro" (Mt 18,20). Presenza di
Gesù che non esclude certo le altre che conosciamo, anzi! Gesù nell'Eucaristia, nella Parola,
nell'autorità ecclesiastica, nel povero, ecc. Presenze che si possono vedere anche in funzione
della presenza di Gesù nella Chiesa.

         Leggendo poi il testo ho appreso la necessità di questo secondo Sinodo perché -
nonostante la caduta del muro nel 1989, che sembrava promettere libertà e unità - nel
decennio seguente si sono visti ergere altri muri invisibili, ma non meno pericolosi e
dannosi, "quello - dice l'lnstrumentum laboris - fatto di paura e di aggressività, di mancanza
di comprensione per gli uomini di diversa origine, di diverso colore, di diverse convinzioni
religiose; il muro dell'egoismo politico ed economico, dell'affievolimento della sensibilità
riguardo al valore della vita umana", per cui "il traguardo di un'autentica unità del
continente europeo appare ancora lontano".

L'Instrumentum laboris però, se riporta i grandi problemi che tormentano ora l'Europa,
elenca anche le nuove speranze; travagli e speranze, del resto, che si possono riscontrare,
per la globalizzazione in atto, in altri continenti.

         E da tutto questo la necessità che l'Europa faccia riemergere le sue radici cristiane.

         Di qui la fiducia in Gesù, nel Risorto presente nella sua Chiesa, presenza ora
estremamente necessaria ed opportuna.
         Il Sinodo è un avvenimento della Chiesa che tutti i cristiani devono sentire proprio,
seguire, parteciparvi, contribuirvi almeno con la preghiera.

         Si dice poi che si sa come un Sinodo incomincia, ma non come finisce: è un
avvenimento di Chiesa, dove lo Spirito Santo agisce e conduce dove lui vuole.

         Per noi poi quest'avvenimento ha - come potete capire - un interesse particolare.
Per cui viene da chiederci: quale il nostro atteggiamento?

         Anzitutto gratitudine a Dio perché cardini per noi così fondamentali appaiono ora
sul piano Chiesa: "Gesù in mezzo ai cristiani" in questo caso.

Grande e trepida attesa perché noi, conoscendone gli effetti, possiamo prevedere cosa
potranno apportare alla Sposa di Cristo.

         E poi impegno a vivere con maggiore intensità questi principi stessi.

         E' da tempo che ci soffermiamo sulla presenza di Gesù fra noi.

         L'ultima volta abbiamo voluto incrementarla con un più attento ascolto. Ricordate?

         Su cosa allora impegnarci durante il mese di settembre per prepararci al Sinodo
d'ottobre? Come fare per esso la nostra parte?

         Lo possiamo rinnovando spesso in cuore il serio proposito di volere sempre, notte e
giorno, la presenza di Gesù fra noi ed agire di conseguenza.

         Per questo occorrerà, quando saremo in contatto con un fratello o una sorella
d'Ideale o più, dichiararcelo apertamente e di frequente.

So che non è facile sempre nel lavoro ad esempio, nella vita di famiglia, di comunità, nello
studio, nella routine d'ogni giorno. E' un atto, infatti, non privo di sacrificio. Domanda, ad
esempio, di vincere il rispetto umano, di superare l'indolenza, di praticare l'umiltà per far
tacere l'amor proprio, di pagare insomma il prezzo di una spiritualità comunitaria.

Dobbiamo dunque reagire. Non diciamo forse: "Sei Tu, Signore, l'unico mio bene"? E lui non
è sacrificio, virtù, vittoria su noi stessi?

Il ricordarsi reciprocamente il dovere di avere Gesù fra noi può contribuire molto a vivere
su un piano soprannaturale, e questo anche nei momenti più semplici, che appaiono i meno
spirituali, come prima di mettersi a tavola o durante una ricreazione o lungo il telegiornale,
prima di una passeggiata, ecc.
         E' questo modo di fare, questo tenere alta la temperatura della nostra vita spirituale,
il nostro tipico contributo al Santo Sinodo, oltre che al Santo Viaggio che questi
Collegamenti aiutano a percorrere.

         Nel mio focolare si è sentito la necessità di vivere così da qualche tempo. E lo
cerchiamo di fare. Vi assicuro che è molto utile; il dichiararcelo è il termometro che ci
assicura di fissare in Dio tutti i momenti della nostra giornata, e - sono certa - è assai, assai
gradito a lui.$doc1780$, 'drive_import', '01780-WEB-1999-06-17-come-vivere-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1780)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1781, 'ITA', $doc1781$Castel Gandolfo, 29 aprile 1999
Con radicalità: non basta essere pronti a morire per il fratello,

occorre morire veramente

Carissimi,
         ho saputo dai vostri fax che la mia piccola esperienza della volta scorsa è piaciuta.

Ciò mi convince ed incoraggia a comunicarvene un'altra, piccola anch'essa.

         E' passato poco tempo da quando la Chiesa, nella persona del Santo Padre Giovanni
Paolo II, ha elevato agli onori degli altari padre Pio da Pietrelcina, ora beato.

         Quel giorno nel mio focolare si doveva vivere il ritiro mensile. Niente di meglio,
quindi, che seguire, per televisione, almeno qualche momento, la cerimonia in piazza San
Pietro popolata dallo straordinario afflusso di centinaia di migliaia di pellegrini. Era quella
una fortunata opportunità per conoscere e amare maggiormente un santo della nostra
epoca.

         E più partecipavamo alla santa Messa, al momento della beatificazione soprattutto,
più seguivamo le parole del Santo Padre e di quanti altri parlavano di lui, più era evidente
che la vita di questo padre era stata straordinaria. Straordinaria per i molteplici doni di Dio,
come le stigmate, ad esempio, per il suo modo di celebrare la santa Messa, così prolungata e
partecipata, per le lunghe preghiere quotidiane, come i 30 - 40 rosari al giorno, per le ore e
ore trascorse in confessionale, per l'irradiazione della sua santità su persone senza numero,
per le opere di carità così consistenti, ma anche straordinaria per le durissime prove subite.

Una vita totalmente ascetica, incentrata su Gesù crocifisso che riviveva in sé.

         E quale l'effetto nella mia anima di fronte a tanto prodigio? Più passava il tempo, più
l'ammiravo come santo, più cresceva nel mio cuore la venerazione verso di lui, più ne avevo
un forte sprone alla santità.

Ma - non posso negarlo - anche un leggerissimo turbamento.

         Perché? Perché mi veniva spontaneo confrontare la mia e la nostra vita con la sua
nei particolari esterni, ad esempio, e, nonostante potessi dire che anche per me, per noi, è
valido, e speriamo vissuto, il suo stesso atteggiamento interiore ("Sei Tu, Signore, Gesù
crocifisso e abbandonato, l'unico mio bene"), considerando la "nudità" spirituale e fisica in
cui egli era vissuto (in convento, solo, nel silenzio, penitenze, 2-3 poveri vestiti, sonno
spesso assente, poco o niente cibo, ecc.), avvertivo una grande differenza fra lui e noi.
         Noi stiamo tra la gente non in convento, noi avviciniamo ogni sorta di persone; noi
parliamo in privato e in pubblico; abbiamo tanti fratelli non siamo soli; tante case,
esteticamente curate anche se semplici; vestiamo, in genere, il meglio che possiamo per
essere come gli altri; non facciamo grandi digiuni, perché Gesù è in mezzo a noi e se lo Sposo
è con voi...; non disdegniamo di usare anche con prudenza i moderni mezzi di
comunicazione...

         Sì, c'era una grande differenza.

         E allora? Non ci ho pensato e sono andata, per una visita, alla Madonna del Divino
Amore, nella nuova, bella e spaziosa chiesa, edificata per assolvere un voto di tanti anni fa.

         E là, di fronte al Santissimo, nella cappella ampia e luminosa a lui riservata, ho
avvertito dentro di me la spiegazione al problema postomi dalla santità di padre Pio: "Non
ricordi - mi parve di sentire in cuore - con quale forza, i primi tempi, t'ho messo in animo
che tu non devi imitare nessun santo se non nel fare come lui la volontà di Dio, perché Io
avevo una via tutta particolare per te e per voi?"

         E capii, colpita dalla forza, dalla decisione, dalla chiarezza colte in queste parole, che
nemmeno i santi di oggi avrei dovuto imitare (pensavo finora, infatti, solo a quelli del
passato).

E qui ho rivisto in tutto il suo splendore la via che egli ha riservato per noi, punteggiata da
quelle parole evangeliche che siamo chiamati ad incarnare, parole che, sembra, vengano
vissute per la prima volta nella Chiesa, almeno nel nostro modo, e parlano di attenderci il
centuplo, di imitare i gigli del campo, del gridare dai tetti, dell'amore reciproco fino all'unità,
di Gesù "generato" in mezzo a noi, di rivivere Maria, laica come quasi tutti noi, ma
santissima, nel mondo in una famiglia, come la più parte di noi; del fratello nostra perla,
possibile nostro paradiso o purgatorio, e quindi anche penitenza per noi; del digiuno non
troppo osservato, appunto, perché lo Sposo è o dev'essere sempre con noi; della vita come
missione, evangelizzazione, dialogo; del grande mistero di Gesù abbandonato, che pare sia
stato a noi riservato, per molti naturalmente.

E ho apprezzato nuovamente quelle concise norme dei nostri statuti che lo Spirito Santo ci
ha suggerito e che la Chiesa ha approvato, dove è descritto il nostro cammino, la particolare
volontà di Dio su di noi. E, ringraziando Dio, ho avvertito in cuore piena la pace.

         Naturalmente non è che aver vissuto qualche ora con un santo non abbia lasciato,
anche in me, una profonda traccia. Ma essa ha avuto questo significato: sottolinearmi la
radicalità con cui dobbiamo vivere la nostra vocazione, perché così padre Pio ha vissuto la
sua. Ed è ciò a cui dobbiamo puntare in questo prossimo mese di giugno: aver sempre di
fronte "Colui che deve precedere", Gesù in mezzo, e vivere in modo che sia fra noi, ma con
radicalità: con un "farsi uno" reciproco più profondo. Non basta, infatti, essere pronti a
morire per il fratello, occorre morire veramente, esser niente lì di fronte a lui.
         Qualcuno mi ha scritto che offrire ogni azione con un "Per Te" è facile, ma è più
difficile stabilire prima e sempre la presenza di Gesù in mezzo a noi. Eppure dobbiamo farlo.
La porta che il Vangelo indica non è mai larga, è sempre stretta, ma conduce alla felicità
piena e alla più grande libertà.$doc1781$, 'drive_import', '01781-WEB-1999-04-29-con-radicalit-non-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1781)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1782, 'ITA', $doc1782$Mollens, 26 agosto 1999

Anima-sposa

Carissime e carissimi,

la seconda assemblea per l'Europa del Sinodo dei Vescovi, si è conclusa da un po' di tempo,
in un clima di grande speranza per questo nostro continente, che è apparso, agli occhi di chi
vi ha partecipato, in grado di offrire ancora a se stesso e, per vari motivi, agli altri continenti,
una nuova vita. Se leggete il "Messaggio", indirizzato a tutti a conclusione dei lavori, ne
avrete una conferma.

         Grazie, dunque, a tutti quelli che hanno pregato ed offerto sofferenze, anche gravi,
per quest'assise così importante per la Chiesa e per il mondo. Il Signore vi ricompenserà.

So che vorreste essere aggiornati. Vedremo il da farsi.

         Intanto vi sia di grande gioia il fatto che, a quanto so, si è parlato, per la prima volta
in un'assemblea del Sinodo dei Vescovi, dei Movimenti ecclesiali e Nuove Comunità, con
tanta ampiezza.

         Non solo, ma questo è meraviglioso: fra le speranze per il futuro che l'Europa può
nutrire, anzi fra le primissime speranze, ci sono proprio i Movimenti. Così, infatti, hanno
scritto i Padri sinodali non senza l'aiuto dello Spirito Santo: " 'Segni di speranza' sono pure:
(…) la presenza e la diffusione di nuovi movimenti e comunità, attraverso cui lo Spirito
suscita una vita cristiana più segnata da radicalismo evangelico e da slancio missionario".
(n. 3)

         Dobbiamo, dunque, essere felici.

         E quale la mia esperienza di quei 23 giorni d'ottobre, fra sessioni plenarie ed altre in
piccoli circoli, impegnati essi stessi a fondo nel lavoro?

         L'impressione di un "momento di Dio" prolungato, soprattutto quando eravamo
tutti insieme col Santo Padre presente in silenzio e in ascolto. Ma anche nei circoli minori
quando ognuno ascoltava l'altro con rispetto profondo in una vera armonia.

Non tutti certamente conoscevano "Gesù in mezzo", come lo pensiamo e viviamo noi,
eppure si è venuta creando una certa unità. E perciò, ecco cosa ne ho tratto: la Chiesa, gli
uomini di Chiesa fanno sul serio: niente di improvvisato; ogni cosa è fatta sino in fondo
anche se costa fatica e stanchezza. E ho dedotto: se la Chiesa istituzionale fa sul serio,
dobbiamo fare altrettanto anche noi, noi come una delle espressioni dell'aspetto
carismatico della Chiesa.

         Ma come?

         In questi giorni, più volte durante la meditazione, mi è venuto da chiedermi:
come devo vivere il tempo che mi rimane per trarre vantaggio da quell'esempio?

         E come vorrei essere ricordata da chi mi ha conosciuto?

         E' una domanda - penso - che può interessare anche voi, e, forse, vi sentite disposti e
attratti a porgerla a voi stessi. La mia risposta, che mi pare uscita dal profondo dell'anima, è
stata: "Vorrei essere ricordata unicamente come la sposa di Gesù abbandonato, come (e in
questo modo possiamo esprimerci tutti) un'anima sposa di Gesù abbandonato.

         Questa possibile (Dio mi aiuti!) definizione della mia vita, mi è sembrata
meravigliosa, anche se altissima, anche se ancora mio "dover essere". Eppure l'ho avvertita
come la mia vocazione.

         Lo sappiamo - come abbiamo ripetuto quest'estate a santa Chiara - che, per farsi
santi, occorre puntare su un'unica idea sintesi, che per noi non può essere che Unità; ma
l'unità si raggiunge solamente se l'anima nostra è sposa di Gesù abbandonato. Foco direbbe:
"avvinta ad un Dio abbandonato". E mi si sono presentate davanti le infinite possibilità di
amarlo: nei dolori personali, grandi o piccoli; nello sforzo che costano le virtù; nelle piccole
o grandi disunità da ricomporre; nella non perfetta unità della Chiesa; nella frammentarietà
delle religioni; nella non credenza; nei sofferenti di ogni genere; nei peccatori; nelle
circostanze avverse; negli imprevisti… dovunque.

         C'è da fare; c'è da amare.

         Grazie, Signore, del tempo che ancora ci lasci per dimostrarti il nostro amore, per
poter dire con sincerità: "Ho un solo Sposo sulla terra".

         Ricordando l'inizio del nostro Movimento avevamo detto, tempo fa, che volevamo
terminare la nostra vita così come l'abbiamo cominciata, come spose di Dio, del Dio Infinito
ed Eterno e Immenso. Ma da tempo questo Dio si è precisato per noi; ha un nome: Gesù
abbandonato.

         Iniziamo allora subito, senza attendere un attimo, a cercarlo, come è scritto nel
Cantico dei Cantici. "Alzati - Egli dice alla sposa in quel divino poema - amica mia, mia bella e
vieni" (Cant. 2,10) (II poema). "Mi alzerò - risponde la Sposa - e farò il giro della città; per le
strade e per le piazze; voglio cercare l'amato del mio cuore" (Cant. 3,2) (II poema).
         Questo ci resta da fare fino alla fine, quando comincerà la Vita senza
tramonto; questo resta da compiere con quella serietà e perfezione che abbiamo
ammirato all'assemblea del Sinodo.

E per prendere in rilievo solo una cosa - giacché da poco è incominciato il nuovo
anno (1999-2000) per tutta la nostra Opera - amiamoLo intanto nei nostri fratelli
d'ideale. E' sempre possibile alzare il termometro dell'amore in chi ci sta vicino,
perché la presenza di Gesù fra noi sia potente ed atta ad affrontare le sfide dell'Anno
Giubilare: la nostra doverosa e gioiosa e piena partecipazione alle sue
manifestazioni.

         E ripeto il titolo. Cosa dobbiamo essere? Anima-sposa di un Dio abbandonato.$doc1782$, 'drive_import', '01782-WEB-1999-08-26-anima-sposa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1782)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1783, 'ITA', $doc1783$Castel Gandolfo, 11 novembre 199

Esperti e testimoni

Carissimi,

         come sapete dai "diarietti", che spero avrete gradito, sono tornata da Amman, la
bella città della Giordania, pulita, ordinata e ricca di valori, il giorno dell'Immacolata, mentre
altri ed altre hanno proseguito per Gerusalemme onde dar compimento al viaggio previsto.
E da lì, da Amman, dove ho sempre risieduto per due settimane, che cosa mi sono portata
via?

         Esperienze senz'altro magnifiche e forse uniche, come quella alla Conferenza
Mondiale delle Religioni per la Pace, ad esempio, dove mi sono resa conto, nello stupore,
come il nostro Movimento sia conosciuto, apprezzato e stimato in tutto il mondo, e quale
venerazione generale susciti il carisma dello Spirito Santo che ne ha dato le origini e lo
sviluppo.

Ho portato qui nel mio cuore anche la conoscenza, il contatto con esponenti di primo piano
di varie religioni, con personalità ecclesiastiche e con capi di più Stati. E, non ultimo, lo
capirete, il calorosissimo, impossibile da descriversi, incontro con tutti i nostri di lì della
zona dei tre Continenti: vero anticipo di Paradiso.

         Eppure non si tratta solo di questo, ma anche di qualcosa in più.

Ad Amman, infatti, in una certa occasione, mi è stato chiesto come la presenza di Gesù in
mezzo a noi, uniti, è stata da noi compresa la prima volta.

Per poter rispondere in piena fedeltà allo Spirito Santo a tale domanda, ho iniziato
descrivendo i momenti della nostra storia che hanno preceduto quel momento, quando, ad
esempio, per la possibile morte vicina sotto le bombe, noi, prime focolarine, ci siamo
domandate se ci fosse stata una volontà di Dio particolarmente gradita a Lui, per viverla
almeno gli ultimi giorni. E ho detto come il comandamento nuovo di Gesù - quell'amore
reciproco sulla misura dell'amore di Gesù, che ha dato la vita per noi - era stato la risposta.

Ho ricordato poi il patto seguente: "Io sono pronta a morire per te"; "Io per te"; ecc., ma,
naturalmente, mi sono soffermata più a lungo su ciò che è successo in seguito. Ricordate? La
constatazione di un balzo di qualità della nostra anima, come se una rete l'avesse portata
più in alto, e l'esperienza, per la prima volta, di una pace unica, mai sperimentata (così si
disse e si continua a dire), di una luce che dava senso a tutto quanto ci riguardava, di una
nuova volontà perseverante al posto della nostra incostante spesso nel mettere in pratica i
propositi; di una gioia fresca, rara, zampillante, di un ardore e zelo nuovi, vivissimi…
Ho spiegato come ci eravamo chieste, in quei momenti, quale poteva essere la causa di tutto
ciò. E l'avevamo capita così: Gesù in quel momento si era reso spiritualmente presente fra
noi perché unite nel suo nome e cioè nel suo amore. Quella pace, quella luce, quell'ardore,
quella gioia, ecc. manifestavano proprio questo. Se Egli c'è, infatti, ci sono tutti questi effetti;
altrimenti è inutile illudersi: Egli non c'è.

Dunque, ho concluso, abbiamo compreso che Egli era presente quando Lo abbiamo potuto
sperimentare.

Non si tratta, infatti, di credere a Lui presente solo per fede, perché Lui l'ha detto.

No: Gesù fra noi, se c'è, si fa sentire, se ne può avere l'esperienza.

Sta qui il bello e il grande di questa sua particolare presenza a cui noi siamo chiamati. Del
resto, anche l'esperienza della sua assenza sta a dimostrare quanto dico: allorché non ci
amiamo in quel modo, la via stessa da noi intrapresa perde senso, le finalità proposteci,
tutto ciò che facciamo, le preghiere, le opere, lo studio… sono senza perché. Camminiamo in
quei momenti come zoppi, come ciechi, a tentoni, pesiamo su di noi e sugli altri, siamo
aperti ad ogni tentazione. Non c'è luce, non c'è fiamma, non c'è protezione, perché Egli non
c'è.

Ma mi potreste obiettare: tutto questo un po' lo sapevamo. Che cosa c'è proprio di nuovo?
Cos'è che è apparso nuovo a te?

Quella necessità assoluta, per noi, che consideriamo la presenza di Gesù fra noi come
"norma delle norme", di sperimentarne gli effetti. Gesù vuole da noi - ripeto - non solo
gente religiosa, che crede e Lo ama con una qualche bella devozione, ma persone che Lo
conoscono, che avvertono la sua presenza fra loro; vuole da noi degli esperti di Chi è Gesù in
mezzo a noi. E, solo se siamo degli esperti di Lui, possiamo essere per molti anche suoi
testimoni: "Noi - possiamo dire a tutti in verità - l'abbiamo visto con i sensi dell'anima;
l'abbiamo scoperto nella luce con cui ci ha illuminato; l'abbiamo toccato nella pace che ci ha
infuso; l'abbiamo sentito nella sua voce in fondo al cuore; abbiamo gustato la sua gioia
inconfondibile, abbiamo conosciuto il profumo celeste d'una nuova volontà adamantina che
ci ha donato".

E possiamo assicurare a tutti che Egli è la felicità, la più piena felicità.

Solo chi può parlare così può dirsi focolarino o membro del nostro Movimento. E così - lo
vogliamo sperare - è già di molti fra noi, se tanto spesso si sente menzionare e magnificare il
sorriso dei loro volti. Ma occorre crescere in estensione e in profondità. Occorre che la
felicità sia patrimonio di più persone possibili, anche di chi, in un primo tempo, può
mancare di qualcosa o di molto ma non è privo del più necessario: di Lui, di Lui in mezzo a
noi.
Allora sì che il nostro desiderio di far sorridere il mondo sarà una realtà sempre più vasta. E
che vogliamo di più? Non è questa la nostra religione? "Affinché abbiano la pienezza della
gioia" (cf Gv 17,13) ha pregato Gesù.

Egli deve essere sempre fra noi e starci bene e noi bene con Lui.
Ecco, quindi, la perla che mi sono portata dall'Oriente, perla conosciuta ma che ora brilla
ancora di più: amarci sempre in tal modo da poter testimoniare: "L'ho visto, l'ho sentito…"
Quale contributo alla nuova evangelizzazione!
"Andate", ci ha detto il Papa in Piazza San Pietro la vigilia della Pentecoste '98.
Andiamo e cominciamo subito ad annunziarLo e a donarLo al mondo.$doc1783$, 'drive_import', '01783-WEB-1999-11-11-esperti-e-testimoni-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1783)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1784, 'ITA', $doc1784$Rocca di Papa, 25 maggio 2000

Una nuova unità

Carissime,

         un punto cardine della nostra spiritualità - ma che dico? -, una meravigliosa realtà,
anzi la celeste creatura che è venuta in particolare rilievo, almeno due volte, in queste
ultime settimane è stata Maria, la Madre di Gesù, la Madre nostra.

         Non era certo rimasta nell'ombra. Era sempre nel cuore della nostra preghiera
assieme a Gesù, al Padre ed allo Spirito Santo, al centro della nostra vita personale e
comunitaria. Ma, in queste ultime settimane, è come apparsa alle nostre anime, alla nostra
Opera in tutta la sua bellezza e forza.

         Quale profonda e intensa felicità anzitutto ha provocato nel nostro cuore quel primo
sentitissimo applauso al mio discorso, dei molti politici convenuti al Centro Mariapoli per il
loro Congresso, tributato a Lei, quando ho ricordato il suo Magnificat!

         Come si sono impresse nel loro cuore, distinte e forti, quelle parole che presentano
Dio come Colui che, se versa su tutti la sua misericordia, distrugge anche i progetti dei
superbi, abbatte i potenti dal trono e innalza gli umili, ristabilisce la giustizia e distribuisce
le ricchezze!…

         Hanno persino visto in Maria la figura del politico per eccellenza, per cui, in un
ambiente alieno a riferimenti troppo religiosi, sono stati condivisi con noi, con convinzione,
i titoli che, sin dai primi tempi, le abbiamo dato: "Regina dei popoli", "nostra Condottiera".

         Un altro momento particolare, nel quale l'abbiamo contemplata assoluta
protagonista, è stato quando, parlando ai responsabili dell'Opera in Roma, ci siamo convinti
che ad un solo patto saremmo stati in grado di attuare il progetto "Roma-Amor": col fare in
modo che l'Opera nostra sia ciò che deve essere e cioè una presenza mistica di Maria sulla
terra, quasi una sua continuazione, come esige il nostro Statuto. E ci si è chiarito che ciò
sarebbe stato possibile unicamente se la nostra Opera avesse conosciuto un'unità più
perfetta. Unità che alcuni di noi, portatisi a Santa Maria Maggiore, hanno implorato da
Maria, Salus populi romani.

         Si tratta di un'unità nuova, che presenta al mondo l'Opera Una, un'Opera una non
solo nel senso che normalmente diamo a queste parole, ma - ricordate il paragone che fa san
Paolo? - un'Opera una come è uno il corpo umano, anche se fatto di diverse membra, anche
se possiede, al suo interno, vari organi. Perché l'Opera, pur essendo costituita di tante zone
(come il corpo umano di tante parti: le braccia, le gambe, la testa, il tronco, ecc.) e, pur
essendovi al suo interno tante realtà (diramazioni, Centri, segreterie per i vari dialoghi,
Cittadelle, Scuole, ecc.), non è se stessa, secondo il disegno di Dio, se non è una, fatta tale
dall'amore diffuso dallo Spirito Santo dovunque, come è presente il sangue in tutto il corpo
umano. Fatta una da Gesù posto in mezzo a noi dovunque.

Questa nuova unità chiesta all'Opera è possibile se si vive in maniera conforme al modello
trinitario in tutti i nostri rapporti dal Centro alla periferia. Vita conforme a quella della
Santissima Trinità nella quale, se esiste un principio, il Padre, e se il Figlio è tutto rivolto a
Lui, le Tre divine Persone sono comunque tutte uguali.

         In questa nuova unità nessuno si troverà ad essere "oggetto" - per così dire -
dell'attenzione degli altri, quasi stesse in piedi unicamente perché sostenuto, ma "soggetto"
cosciente, atto a sostenere quanti gli verranno affidati. In questa nuova unità perciò ognuno
non potrà farsi trascinare nella vita ideale come - direbbero i gen 4 - un "vagone" di un
treno, ma dovrà trascinare gli altri come una "locomotiva".

         In quest'unità, ancora, non ci si porrà tanto di fronte ai responsabili in attesa di
qualcosa, ma ci si dovrà mettere alle loro spalle per comporre con essi, nell'Opera, Maria e
scatenare insieme, come vera "acies schierata", la nostra rivoluzione d'amore nel mondo.

         E, affinché questa nuova unità diventi realtà, cosa dobbiamo fare sin d'ora?

         Una sola cosa: generare costantemente fra noi dovunque nell'Opera la presenza di
Gesù. Ma non però come fine a se stessa, ma come pedana di lancio per poter amare tutti e
incendiare il mondo d'amore, per seminarvi i veri valori e far sfumare i falsi; per costruirvi il
Regno; per permettere a Maria di cantare nuovamente, attraverso l'Opera, il suo Magnificat.

         Coraggio, allora, non aspettiamo un attimo a dar vita a Gesù fra noi, come Maria lo
ha fatto in sé. Vedremo miracoli!

         Da Roma, dove l'Opera ha iniziato a vivere questa nuova unità ed è partita il 10 c.m.
l'Operazione "Roma-Amor" (O.R.A.), i responsabili di zona, nel darne relazione, mi scrivono:
"Dopo il lancio dell'Operazione, l'O.R.A. va dilagando a macchia d'olio, di bocca in bocca: ci
sembra che mai l'Opera sia stata così viva, vigile e attenta alle indicazioni dello Spirito
Santo.
         "Sperimentiamo di essere portati da una grazia straordinaria che fa dell'Opera un
cuore pulsante: più l'unità è alimentata fra tutti noi, più si aprono le possibilità di andare
fuori e portare a tanti la rivoluzione d'amore".

         Voglio sperare, carissime e carissimi tutti nel mondo, che pian piano tutti i
responsabili di zona e le responsabili di zona del mondo possano scrivermi così.$doc1784$, 'drive_import', '01784-WEB-2000-05-25-una-nuova-unit-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1784)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1785, 'ITA', $doc1785$Mollens, 29 giugno 2000
Evangelizzare

         Carissimi,
         vi parlo dalla Svizzera reduce, come sapete, dai due impegni a Roma: il Genfest al
Flaminio, e la Giornata Mondiale della Gioventù a Tor Vergata.
         Avvenimenti, l'uno e l'altro, non certo limitati a quei luoghi, ma aperti a più parti del
nostro pianeta fin dove i mezzi moderni possono arrivare, mezzi moderni tanto volentieri
usati da noi per quell'istinto unico all'"Ut omnes" che ci distingue.

         E che cosa hanno lasciato nel mio cuore questi due momenti?
         La riscoperta consolantissima che il nostro Movimento, là dove è vissuto con tutto
l'impegno, è la "nuova evangelizzazione" in atto; è, misticamente, Maria, Regina degli
Apostoli, presente in questa sua Opera, che continua a dar al mondo Gesù.

A Tor Vergata, mi era stato detto di ricordare la parola di Gesù, che il Papa nel 1995 aveva
voluto riferita ai giovani: "Come il Padre ha mandato me, così io mando voi". In pratica
dovevo sottolineare l'evangelizzazione. Per cui io, per commentarla e insegnare a viverla, ho
invitato i presenti (in quell'ora circa un milione, non tutti hanno ascoltato naturalmente) a
passi successivi secondo quest'ordine: anzitutto stabilire fra loro l'amore reciproco così
perfettamente che si possa ripetere pure di essi: "Guarda come si amano, e l'un per l'altro è
pronto a morire."
Poi amore a tutti i prossimi che incontrano, senza distinzione; e mostrare questo amore
concretamente, a fatti.
E infine, ma proprio e solo infine, parlare, annunciare il Vangelo.

         E mentre proponevo questo, chiamiamolo questo metodo, mi sono resa conto con un
certo stupore, che non facevo che esporre ai giovani lo stile di vita che lo Spirito Santo ha
suggerito al nostro Movimento. Nei focolari, nei nuclei, nelle unità gen, nelle nostre
comunità stabili (come le cittadelle) o temporanee (come le Mariapoli estive), sempre
occorre innanzitutto infatti amarsi, assicurandosi la presenza di Gesù in mezzo, amare poi
tutti i prossimi concretamente, ed infine, solo infine, parlare.
         Nel discorso al Genfest, due giorni prima, d'altra parte, narrando il miracolo di
Fontem, s'era potuto costatare, con tutta evidenza, la validità di questo modo di procedere.
Infatti lì, perché ci si è comportati così, si è arrivati alla parola, che viene data con grande
abbondanza.

         La nostra vita dunque si identifica con la "nuova evangelizzazione". E le "Paginette"
delle vostre zone, che sto leggendo con un grande interesse, mi confermano che lo sforzo
generale dell'Opera è mantenersi in questa linea.

         Tuttavia mi sembra di dover commentare un po' l'ultimo dei passi: "e poi, alla fine,
parlare". Parlare che è essenziale per un'evangelizzazione.

         Noi parliamo spesso: nei nostri vari incontri ed i frutti - lo sappiamo - sono
abbondanti.

Ma basta ciò?

No, no, dopo esserci assicurata la presenza di Gesù in mezzo a noi con l'amore reciproco,
dopo aver rivolto il nostro amore a tutti, anche concreto, è d'obbligo sempre far qualcosa in
più. Bisogna annunciare, occorre sempre annunciare, anche perché tutto l'amore che
facciamo precedere ci autorizza a farlo.

Occorre annunciare! che per noi non significa tanto cominciare col catechizzare i prossimi,
ma, partendo, ad esempio, dalla nostra esperienza con Gesù, parlare di Lui.

Ed è proprio quest'annuncio che mi sembra un po' debole, mancante fra noi.

         Conosciamo certamente e condividiamo in parte l'obiezione che si fa di tanto in
tanto: "Non c'è tempo a disposizione per i contatti personali - si dice - per il lavoro che ci
occupa ore e ore, per i già molti impegni nell'Opera...".

         Tuttavia io penso che qualcosa ancora si può fare e non solo per quei singoli fratelli
che ci sono affidati nei grappoli, ad esempio, ma per tutti quanti incontriamo.

Era il cuore strapieno d'amore per Dio delle prime e dei primi focolarini che faceva
traboccare il Vangelo riscoperto su tanti! Come del resto avviene tuttora in certe zone
difficili, che stupiscono, e ci fanno render gloria a Dio per la miracolosa - così appare -
espansione della nostra rivoluzione in quelle parti.

         E allora come far in modo che anche oggi sia così dovunque?

A quali prossimi aprire il nostro cuore e come, dopo averli amati?
         A tutti, a tutti: anche se non sempre si può parlare con la bocca, lo si può sempre col
cuore, col chiamarli per nome, ad esempio, col salutarli in una data maniera, in modo che
avvertano che sono importanti per noi, che non ci sono certo indifferenti, che c'è già un
legame con loro fatto magari solo di silenzio rispettoso. Queste parole senza rumore, come
può essere un sorriso, se indovinate, non possono non aprire un varco nei cuori.

         E appena il varco si apre in chiunque, non bisogna attendere, occorre parlare, dire
anche poche parole..., ma parlare. Domani il discorso sarà forse più lungo. Ma intanto così.

Proviamo a riempire la nostra giornata di queste parole, di gesti nuovi che non abbiamo mai
fatto, totalitari, completi.

E' questo l'impegno che ci dobbiamo prendere d'ora in poi per tutto il mese di settembre:
parole, parole, parole, sonore o silenziose, ma comunque parole.$doc1785$, 'drive_import', '01785-WEB-2000-06-29-evangelizzare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1785)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1786, 'ITA', $doc1786$Mollens, 24 agosto 2000

La fortezza

Carissimi,

         quando mi sono recata, per la prima volta, negli Stati Uniti nel 1964, ammirando
questa grande nazione, avevo scritto nel diario: "A me quest'America ha fatto una bellissima
impressione. Conosco altre nazioni in Europa, nel Sud America…, anche in Asia; ma questa
mi sembra particolarmente adatta allo spirito del Movimento: non c'è boria di popolo, c'è
l'internazionalità più spiccata, c'è semplicità".

         Questa volta la medesima impressione, con un particolare aggiunto: il numero di
nazioni rappresentate da singoli, da gruppi (si parla in pratica di tutte o quasi tutte quelle
esistenti nel mondo), di razze è senza numero, ma sono spesso chiuse in loro stesse, divise
fra loro. E perciò nuovamente la certezza: è l'Ideale, il nostro ideale che può fare di questa
quantità di etnie un solo popolo.

Ciò è apparso chiaro anche a S.Ecc. mons. O'Brien, ordinario militare, che abbiamo
incontrato nella nostra visita alla Nunziatura di Washington i primi giorni: "Il carisma,
l'unità - disse -, è la potenza che potrà mettere insieme questo popolo così diverso; è ciò che
gli USA potranno offrire al mondo". Ed è nata in noi la passione di contribuire a far sì che
questa nazione (in cui il Movimento è presente da anni ed è diffuso un po' dovunque) possa
realizzare col tempo questo suo altissimo fine: dare al mondo un formidabile esempio
d'unità.

         Intanto durante il nostro soggiorno ciò è avvenuto almeno fra tre popoli: il nostro
"popolo focolarino" (già uno anche se vario), i Bangwa nordamericani e gli afroamericani
dell'Imam Mohammed.

Penso avrete già avuto qualche informazione, che fra poco Eli ed Enzo completeranno.

         Considerando però questo grande progetto si è capito subito che non sarebbe
bastato il piccolo davide dell'unità per affrontare l'enorme golia d'una tale frammentarietà.
Le immani difficoltà ci avrebbero chiesto una forza particolare e non solo umana: quella
speciale virtù che è un'altra delle quattro virtù cardinali: la fortezza.

         Importantissima. Pur tuttavia una di tutte quelle virtù di cui la carità (nostro ideale)
è madre. Ci sarebbe, dunque, bastato amare, amare, amare, amare sempre ed avremmo
sviluppato in noi anche la fortezza che occorre al Movimento negli Stati Uniti, e non solo.

         Ma - come tutti sappiamo - noi siamo chiamati non solo attraverso la carità, quindi
indirettamente, a superare le divisioni, gli ostacoli, le frammentazioni, le dispersioni, le
chiusure, ma anche direttamente: Gesù abbandonato, amato, sposo della nostra anima,
chiave, soluzione di tutte le difficoltà, è di certo per noi la fortezza stessa.
         Con Lui, infatti, è possibile, vorrei dire quasi logico, normale, affrontare le difficoltà e
superarle. E' Lui che ci fa forti. Infatti, perché lo amiamo, vale anche per noi quanto dice
santa Caterina: "Per l'uomo forte felicità e infelicità sono come la sua mano destra e sinistra;
l'uomo forte si serve di entrambe".

         I mesi scorsi abbiamo puntato su un'altra virtù cardinale: la temperanza. E spero
che sia stata ricordata; spero che, almeno qualche volta, all'atto d'amore, che ci ha fatto
superare il dolore abbracciando Gesù abbandonato, abbiamo dato il suo nome: temperanza.
Lo spero e voglio crederlo.

         Nel prossimo mese a questi atti daremo il nome: fortezza. E per meglio possederla,
perché sia sempre presente in noi, non solo negli USA, ma ovunque nel mondo (dappertutto
siamo chiamati a realizzare, pur con compiti diversi, l'unità), per raggiungere la fortezza
sarà bene pregare.

C'è un'espressione particolare, che forse qualcuno non capisce di colpo, ma che rende l'idea
della necessità dell'aiuto di Dio per possedere questa meravigliosa virtù. Essa dice: "La
fortezza è la paura che ha detto le sue preghiere". (Dorothy Bernard)

         La fortezza poi ci sarà utile per altri motivi. Ce lo dice una definizione di
sant'Agostino: "La fortezza è la capacità di sopportazione dei mali e delle avversità della vita
in vista del godimento dei beni supremi".

Essa, poi, ci porta alla perfezione. Afferma santa Teresa d'Avila: "Tra le prime condizioni
della perfezione sta, innanzi tutto, la fortezza".

         Una delle espressioni della fortezza, poi, è una qualità tanto necessaria ai nostri
tempi: l'ottimismo. Diceva un celebre scrittore francese che l'ottimismo è una delle forme
estreme della fortezza.

         E infine essa ci fa autentici cristiani. Dice Paolo VI: "Come è concepibile un fedele
fiacco, indolente, amante del proprio vivere comodo, senza rischio, senza energia morale,
senza spirito di sacrificio? Un cristiano dev'essere, per definizione, un uomo forte!".

         Ridichiariamo allora a Gesù abbandonato il nostro totale amore e viviamo di
conseguenza. E la fortezza brillerà in noi. Per essa costruiremo l'unità dovunque, come s'è
detto. Saremo autentici cristiani e diverremo perfetti.

         Tanto può una sola virtù!$doc1786$, 'drive_import', '01786-WEB-2000-08-24-la-fortezza-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1786)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1787, 'ITA', $doc1787$Castel Gandolfo, 23 novembre 2000

La prudenza

Carissime,
         alle volte, intervistando una persona, le si chiede: "Qual è stato il momento più bello

della tua vita?" Ed è difficile per tutti rispondere perché, se in genere molti sono i dolori di
ogni esistenza, non mancano mai, o quasi, giorni più sereni e gioiosi.

         E così è toccato anche a me e più di una volta: non ho saputo rispondere forse
perché nella nostra vita ideale sono molte, bisogna dirlo forte, veramente molte le gioie che
Dio ci dà, e quale scegliere?

         Ma, se oggi la cosa si ripetesse, potrei almeno sapere quale è stata una delle giornate
di così grande gioia, da arrivare alla commozione. E non esiterei a segnalare la festa
dell'Immacolata 2000 quando, di buon mattino, ho ricevuto una lettera. Era di mons. Pietro
Garlato, vescovo di Tivoli, nella quale mi faceva sapere la sua decisione di avviare il
processo di beatificazione di Igino Giordani, il nostro Foco, confondatore dell'Opera. Non
solo: egli è stato anche primo fra i focolarini sposati, e, già esperto in umanità, l'ha, per così
dire, rappresentata in mezzo a noi sin dall'inizio; l'ha aperta poi lungo gli anni all'influenza
del nostro carisma, sicché oggi comincia ad essere invasa, l'umanità, nei suoi diversi mondi
da quello Spirito che fa nuove tutte le cose: la politica, l'arte, la cultura, la teologia, la
filosofia, l'economia, la pedagogia e così via.

         Foco, personalità cristiana di alto livello spirituale e culturale, ma soprattutto
focolarino come tutti noi, domani sarà - a Dio piacendo - beato.

         Ma - viene da chiederci - come ha fatto a raggiungere tale mèta?

         La Chiesa s'occuperà di rispondere a questa domanda verificando, fra il resto, le sue
virtù. Noi, pur attendendo il suo giudizio, siamo già testimoni di quanto l'amore, con tutte le
virtù che ne derivano, era presente nel suo cuore: Foco, fuoco non era solo il suo nome
ideale. Era la sua vita.

         In lui, tra le altre, si notavano, ad esempio, quelle quattro virtù che andiamo
analizzando in questi mesi e cercando di vivere. E tra esse - ecco quella che proponiamo
oggi - la prudenza. Virtù veramente speciale se il libro dei Proverbi la definisce "fine" e
"preziosa". Essa vale più dell'argento e il suo possesso più dell'oro, più delle perle e tutte le
gemme che non possono pareggiarla. (Cf Pr 3,13-15) E tutto perché questa sublime virtù è
tale da metterti in condizione di raggiungere il tuo ideale.

         Noi sappiamo che l'ideale di Foco era Dio. E pensiamo che l'abbia raggiunto, se ora la
Chiesa pensa che può essere dichiarato "beato".

         La prudenza, infatti, fa "eliminare", "perdere" e "mortificare" le tendenze e gli
attaccamenti puramente umani per lasciar vivere e imperare solo il divino. Essa insegna il
discernimento fra ciò che ostacola e ciò che favorisce il raggiungimento della mèta: aiuta a
distinguere. Sa scegliere fra ciò che è utile e ciò che è dannoso.

         L'Imitazione di Cristo arriva a dire: "Prudente è colui che considera spazzatura ogni
cosa terrena, al fine di guadagnarsi Cristo".

         Foco ha cominciato presto a praticare la prudenza. E lo ha fatto con energia nella
linea della nostra spiritualità: amando Gesù abbandonato e persino godendo
dell'annientamento che il suo amore esigeva e lo liberava, com'era la sua vocazione di
focolarino.

         Ricordiamo ancora quei suoi versi: "Mi son messo a morire/ e quel che accade non
m'importa più: ora voglio sparire/ nel cuore abbandonato di Gesù.

         Tutto questo penare/ per l'avarizia e per la vanità/ nell'amore scompare: ho
riacquistato la mia libertà.

Mi son messo a morire/ a questa morte che non muore più;/ ora voglio gioire/ con Dio della
sua eterna gioventù."

E Foco, pur in una vita non scevra di prove, anche acute, specie alla fine della sua vita, ha
potuto conoscere e farci conoscere quei frutti della prudenza che ha descritto il card. Carlo
Maria Martini: "La prudenza - dice - genera saggezza di vita, genera armonia, tranquillità
d'animo, serenità, ordine, chiarezza, pace interiore e ci rende capaci di guardare a ciò che è
essenziale".

         E allora: quello che dobbiamo dedurre è evidente. Mettiamo in pratica questa virtù
dando a tutti gli atti che compiamo per amore di Gesù abbandonato, scelto come "unico
tutto", il nome di "prudenza". Saremo in grado così anche noi di "morire" ("mi sono messo a
morire" ha confidato Foco) distinguendo bene nella vita ciò che possiamo possedere e ciò
che dobbiamo perdere.

         E non dimentichiamo una preghiera di gratitudine a Dio per averci dato una via
spirituale che può offrire a chi l'abbraccia la santità. Ce lo dicono Chiara Luce, Santa, Maria
Orsola, il focolarino sposato polacco (Jerzy Ciesielski), tutti e quattro ormai Servi di Dio,
mons. Valdés, ed ora Foco: tutti e sei avviati alla gloria per la Gloria di Dio.

         E allora coraggio e avanti con loro dinanzi a noi. Siamo ancora vivi; possiamo ancora
farcela.

         E Buon Natale e Buon Capodanno 2001 ad ognuna e a tutte.$doc1787$, 'drive_import', '01787-WEB-2000-11-23-la-prudenza-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1787)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1788, 'ITA', $doc1788$Rocca di Papa, 21 dicembre 2000

2001

La giustizia

Carissimi,

         negli ultimi Collegamenti abbiamo cercato di sottolineare, approfondire e vivere tre
virtù cardinali: la temperanza, la fortezza, la prudenza.

         Rimane da affrontare, questa volta, la giustizia.

         Ma come si può definire la giustizia? "La giustizia consiste nella costante e ferma
volontà di dare a Dio e al prossimo ciò che è loro dovuto."

         E già qui noi non possiamo non intuire che anche la giustizia, come le altre virtù
cardinali, ha a che fare con l'amore. Infatti la carità sta proprio nell'amare Dio con tutto il
cuore, la mente e le forze, e il prossimo come se stessi.

         Sant’Agostino stesso vede un legame, quasi un sinonimo, fra l'amore e la giustizia.
Dice, fra il resto: "La carità iniziale è germoglio di giustizia; una carità progredita è giustizia
che va maturando; una carità perfetta è perfetta giustizia."

         E Giovanni Paolo II ha sottolineato l'indiscusso rapporto fra amore e giustizia
quando ha affermato: "Cristo ci ha lasciato il comandamento dell'amore del prossimo. In
questo comandamento - l'amore del prossimo - è racchiuso anche tutto ciò che concerne la
giustizia."

         Da poco più di una settimana, come tutti sapete, siamo tornati dall'India con nel
cuore e nella mente un arricchimento vario e molteplice. Conoscete parecchio di questo
viaggio per via dei diari, dei "diarietti" li chiamiamo. Ma avremmo molte e molte altre cose
da raccontarvi. L'India misteriosa è, infatti, un pozzo senza fine.

         E un elemento che emerge da essa è il fattore spirituale. Perché anche questo è
l'India: terra di spiritualità, di interiorità, di fede. E chi è soltanto un po' sensibile a queste
cose, le coglie nell'aria. Esistono laggiù pratiche e usanze diverse e lontane da quelle che si
vivono, ad esempio, nella nostra Religione cristiana; eppure, vi è sempre, in questo popolo,
una tensione verso l'alto.

Per loro, per gli indiani, Dio è dovunque (anche se in maniera diversa da come noi lo
pensiamo), e forse è proprio questa convinzione che non permette loro d'essere insensibili
a Lui.
         Così, mentre si costata questo, nel tuo cuore di cristiano, lo Spirito Santo lavora,
approfondisce in te la tua fede, i vari aspetti della tua religione, il tuo modo di amare Dio.

         Così è stato per noi, per me. Mi è sembrato infatti, fra il resto, di essere spinta a
vivere più in profondità tutte le nostre pratiche religiose.

E, fra queste, la santa Messa. L'ho vista ancor meglio sotto un suo aspetto: quello del dono.
Non solo, ma anche come la straordinaria consolantissima possibilità di dare a Dio qualcosa
di proporzionato alla sua Regale Maestà.

         Il Concilio Vaticano II dice che nella preghiera eucaristica della santa Messa uno
degli elementi principali, appunto, è quello del dono, dell'offerta: la Chiesa offre al Padre
nello Spirito Santo (Gesù) la vittima immacolata. (E) la Chiesa - così il Concilio ancora -
desidera che i fedeli non solo offrano la vittima immacolata, ma anche imparino ad offrire se
stessi.

         Finora, in genere, noi abbiamo attuato e attueremo sempre il comando di amare Dio
con l'impegnarci a far sempre meglio la sua volontà. Ci sono piaciute e ci piacciono assai
quelle parole riferite a Gesù nella lettera agli Ebrei: "Tu non hai voluto né sacrificio né
offerta, un corpo invece mi hai preparato. (...) Allora ho detto: Ecco, io vengo (...) per fare, o
Dio, la tua volontà."

         Ora vedo meglio anche la possibilità di amare Dio Padre in quest'altro modo:
donandoGli, appunto, attraverso la santa Messa, l'offerta del suo Figlio, Agnello di Dio, al
quale aggiungo l'offerta della mia vita al suo servizio.

         E il cuore è sazio.

         E, per ricordarmelo, tengo a volte presente una scritta trovata sulla porta di una
chiesa: "Di qui si entra per amare Dio (per donargli un’offerta a Lui gradita); di qui - da
questa porta - si esce per amare il prossimo." E in quanto all'amare il prossimo, oggi non
voglio aggiungere nulla. Lo conosciamo bene.

         Che la nostra esperienza in Asia possa servire anche a tutti voi, che mi ascoltate,
impegnandoci insieme, nel prossimo mese, a dare a Dio con tutto il cuore, oltre
l'adempimento della sua volontà, anche il dono più grande che possiamo fare: il suo Figlio
immolato. E, se nell'amare è un po' tutta la nostra spiritualità (ha detto il Santo Padre che
l'amore è la "scintilla ispiratrice di tutto quanto si fa con il nome di Focolari"), essendo
l'amore un po' tutta la nostra spiritualità, che la santa Messa diventi veramente il centro
della nostra giornata. Lo è già, ma lo deve essere sempre di più e meglio, perché è per essa
che possiamo vivere la giustizia per quanto riguarda Dio: dando a Lui quanto gli è dovuto,
per poi dare ai fratelli il loro: amandoli come noi stessi.$doc1788$, 'drive_import', '01788-WEB-2000-12-21-la-giustizia-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1788)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1789, 'ITA', $doc1789$Castel Gandolfo, 25 gennaio 2001

Ciò che si può fare sempre

Carissime,
         conosciute e messe in pratica le quattro virtù cardinali, nei mesi scorsi: prudenza,

giustizia, fortezza, temperanza, affrontiamo, con oggi, altre virtù cominciando
dall’obbedienza.

         Ma cos'è l'obbedienza? Che peso ha l'obbedienza?

         L’obbedienza è uno dei tre consigli evangelici che aiutano a raggiungere la
perfezione.

         Per capirne il valore basta pensare che la povertà, primo consiglio, domanda di
essere distaccati dai beni terreni, la castità, secondo consiglio, dalle creature, mentre con
l'obbedienza si dona a Dio la nostra volontà e cioè: tutti noi stessi.

         Questa volta, però, non vorrei dilungarmi troppo nel dare definizioni e spiegazioni
sull'attuale virtù. Preferisco offrire un luminosissimo esempio d'obbedienza alla volontà di
Dio che abbiamo ammirato tanto vicino a noi, poco tempo fa. Si tratta di Fiore. Tutti, penso,
sappiate chi è stata Fiore. E come recentemente questo "fiore" è stato trapiantato da Dio nei
suoi giardini, Lassù.

Fiore era stata, sin dal '51, una delle prime focolarine di Roma. Aveva svolto, durante
cinquant'anni di focolare, vari importanti servizi all'Opera, al Centro e in più parti del
mondo, diffondendo, più recentemente, il nostro Ideale in Centro America: Salvador,
Guatemala, Nicaragua. Ma soprattutto in Messico, dove aveva contribuito, con sapienza ed
energia, al nascere della Cittadella "El Diamante".

         Di lei vorrei raccontarvi soltanto qualche particolare del suo ultimo giorno qui in
terra.

I giorni precedenti avevo avuto la gioia anch'io di aiutarla a vivere bene quella che era ormai
la sua "ora", come Gesù aveva definito l’appressarsi ed il compiersi della sua Passione e
morte. E mi ero preoccupata di darle diversi consigli. Quello però che più aveva inciso nel
suo animo era stato l'invito a vivere bene la volontà di Dio, perché - spiegavo a lei, sempre
così attiva - se ora non poteva più né lavorare, né dedicarsi agli altri, né viaggiare, nutrirsi,
dormire, ecc., poteva sempre vivere la volontà di Dio, obbedendo a Dio in ogni attimo.

L'ultima mattina, verso le 7.00, alle focolarine, che l'avevano trovata seduta sul bordo del
suo lettino, aveva detto: "Sono qui che faccio festa a Gesù (cioè: accetto con gioia questa sua
volontà) dopo una notte atroce. Sono ormai molto grave, molto grave. Cosa sarà successo?"
Messa al corrente delle complicazioni che erano subentrate, si è disposta, con un abbandono
totale in Dio, a prepararsi per l'"incontro". (Per noi, come si sa, la morte ha soprattutto
questo significato: l'incontro con Gesù che, secondo la nostra fede, avviene subito dopo
arrivati di là.) Poi ha ripetuto ad ogni respiro per più di due ore: "Eccomi, eccomi, eccomi..."
che alternava con un: "Sì, sì, sì...". Ed ogni tanto ripeteva: "Dio lo ha voluto, Dio lo ha voluto!"
E aveva una pace profonda. Non riuscendo poi quasi più a parlare, ha soggiunto: "Ho già
detto il mio sì per sempre, l’ho detto milioni di volte...".

A mezza mattina ha cominciato a salutare le focolarine. Ad una: "Ciao, sei stata sempre al
servizio. Grazie!" Alla medico che la curava: "Sono felice. Sì, sono felice. Non ti preoccupare
di nulla; hai fatto tutto quello che hai potuto. Devi essere felice".

Verso le 11.00, arrivato da lei don Foresi per un ultimo aiuto da parte della Chiesa, gli
risponde: "Grazie, sono felice". E appena lui sussurra: "Stai compiendo, Fiore, una grande
missione con la tua sofferenza", risponde: "Sono felice se può servire all'Opera. Salutami
Chiara e dille che sono felice!".

Intanto a mezzogiorno, rivolta ad una focolarina arrivata due giorni prima: "Ti ho aspettata!
Di' alle focolarine del Messico che le ringrazio perché hanno avuto tanta pazienza con me;
voglio che siate felici tutti. Siate felici tutti. Salutami tutti. Vi ho amato molto (...), vi ho
sempre voluto tanto bene. Anche i focolarini ho amato come le focolarine; non ho avuto
preferenze (...)".

La focolarina la informava su quanto Atti, il responsabile del Movimento in Messico, aveva
scritto a me: "Fiore porta a Dio una bella fetta di mondo fra le braccia", ricordando l'ardita
frase del teologo belga Jacques Leclercq: "Il tuo giorno, mio Dio, verrò verso di Te... Verrò
verso di Te, mio Dio... e con il mio sogno più folle: portarti il mondo fra le braccia",

Al che Fiore aggiunge: "Ha fatto tutto la Madonna, ha fatto tutto Lei, ha fatto cose grandi...". E
la focolarina: "Hai fatto la piena unità in zona..." E Fiore: "La Madonna ci ha dato il tempo. La
Madonna è qui, Lei è grande. Vorrei morire tranquilla sapendo che portate avanti l'Opera". E
la focolarina: "Prendiamo la staffetta, Fiore". E Fiore: "Sono contenta. Voi sapete come fare e
cosa fare". E ancora: "Sto andando" e fa un cenno di saluto con la mano. La focolarina: "La
Madonna è qui". E Fiore: "Oh, sì, è qui. C'è la Madonna, c'è la Madonna. E c'è Gesù in mezzo a
noi, grande!". E anche se i dolori perduravano, faceva alle focolarine sorrisi di cielo. E ripete:
"Sì, per sempre".

Alle ore 14.00 la focolarina le canta alcune canzoni, come quella intitolata: "Sono grazie" che
dice: "Quando sarò alla tua porta non dirò il mio nome. Dirò: sono grazie per tutto e per
sempre".

E Fiore si assopisce sempre di più. Ma a Natalia, lì vicina, con voce decisa, dice: "Di' tutta la
mia unità a Chiara!"
Alle ore 16.00, mentre la respirazione veniva meno, raddrizza la testa con forza, come se
cercasse qualcuno che la chiama, ed apre gli occhi grandi; poi, con sorpresa, fissa lo sguardo
su un punto e, chinata la testa dolcemente, chiude gli occhi e parte.

         Questa è l'obbedienza: fare la volontà di Dio sempre e possibilmente come Fiore,
nella felicità. Ma fare la volontà di Dio è proprio l'espressione tipica, noi lo sappiamo,
dell'amare Dio. Anche l'obbedienza, quindi, è fondamentalmente amore.$doc1789$, 'drive_import', '01789-WEB-2001-01-25-ci-che-si-pu-fare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1789)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1790, 'ITA', $doc1790$Castel Gandolfo, 22 febbraio 2001
La più genuina unità

Carissimi,

         ed eccoci al nuovo Collegamento.
         Cosa vuol dirci questa volta?

         Sembra proprio che Gesù non si risparmi nel dare modelli, per la nostra vita
cristiana e focolarina, a tutti noi ed in particolare ai giovani, che domani porteranno la
responsabilità dell'intero Movimento. E li dà proprio in quest'epoca così avara di essi - di
modelli -, quando i modelli vengono ricercati, tutt'al più, per vie sbagliate.

         Ci aveva appena offerto, in Fiore, una testimone dell'obbedienza, insegnandoci a
ripetere, di fronte ad ogni piccola o grande avversità (e non solo nell'ultima nostra
giornata): "Sono felice". Ora ci ha donato in Ginetta, un gigante dello spirito, della cui vita, in
questi ultimi giorni, abbiamo conosciuto molti particolari, alcuni dei quali possono forse
dirsi straordinari. Ci vorrà un volume, però, per sapere solo qualcosa.

         Ma, nella sua ricchissima vita spirituale si può individuare una sua dote o virtù che
più l'ha caratterizzata?

         Sì: l'unità - io penso -, la più genuina unità, quella giusta, autentica, perfetta, forte,
inflessibile, vissuta e realizzata con l'amore esclusivo e perseverante a Gesù abbandonato.
Quell'unità che la nostra spiritualità comunitaria ci insegna a vivere sul modello della
Santissima Trinità, quell'unità per la quale si tenta di ripetere - per quanto è possibile a noi
creature umane - il rapporto fra il Padre celeste ed il suo Figlio, nello Spirito Santo.

         Ginetta aveva compreso, sin dall'inizio della sua nuova vita, che il Signore ci aveva
donato un carisma, e l'aveva offerto a tutti attraverso un suo strumento. Di qui la sua unità
totale e incondizionata con chi ne era stata fatta - in certo modo - la fonte.
Non si è fidata, non ha tanto fatto calcolo, della luce di questo dono, al quale pure lei
partecipava; non ha guardato in se stessa, nemmeno a ciò che di più prezioso aveva. Ha
vissuto come Gesù che, pur potendo attirare l'attenzione su di sé - era anch'Egli, come il
Padre, Dio -, non l'ha fatto; ha, per così dire, "spento" se stesso, orientando tutti al Padre.

Ginetta ha annullato completamente se stessa e, come Gesù abbandonato, ridottosi a nulla, è
stato Mediatore tra noi e il Padre, così lei è diventata autentica mediatrice del carisma
dell'unità per molti altri.

Ha fatto posto al carisma genuino; non ha voluto dargli una sua interpretazione personale;
lo ha accolto così come sgorgava dalla fonte. E si è poi messa al suo servizio, a viverlo e a
farlo vivere. Ed ecco, di qui, l'autenticità della sua vita, il segreto, il miracolo, la concretezza
e la completezza delle sue opere. Di qui l'essere riconosciuta unanimemente confondatrice
in quel pezzo d'Opera, che è una parte del mondo: il Brasile.

Che ora dal Cielo ci aiuti ad essere come lei.

Ginetta ha vissuto unicamente per la gloria di Dio ed ora è, in certo modo, glorificata a voce
di popolo. E' stata puro servizio, ancella, come Maria, e la vediamo venerata ed amata come
regina, si può dire. Se i piccoli continuano a considerarla sorella amatissima, loro forma,
loro immagine, i grandi della società e della Chiesa la riconoscono guida e le sono
profondamente riconoscenti.

         Non abbiamo di meglio per sapere come vivere in questo prossimo mese: attuare il
nostro Ideale, così come lo Spirito Santo, attraverso lo strumento da Lui scelto, ce lo dona.
Perché questo è stata Ginetta.$doc1790$, 'drive_import', '01790-WEB-2001-02-22-la-pi-genuina-unit-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1790)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1791, 'ITA', $doc1791$Rocca di Papa, 19 aprile 2001

"Sono Io"

Carissime,

         a Praga e a Bratislava ho avuto modo, in due occasioni, di comunicare ai e alle
focolarine una piccola, ma per me grande esperienza, perché - se la sentivano utile - anche
loro la facessero propria.

         E' dello scorso anno, ma il suo effetto perdura nella mia vita spirituale e spero
continui, sempre. Avevo terminato di scrivere Il grido, che avevo voluto fosse un canto a
Gesù abbandonato, per quello che Egli è stato, è e sarà nella mia e nella nostra vita.

         Un canto, perché - lo possiamo dire con certezza - il quotidiano aiuto per la
soluzione di tutti i nostri e gli altrui problemi, era stato, è e sarà sempre Lui, soprattutto Lui.
Sicché non era improprio vederlo ed amarlo non solo come amico, ma come lo Sposo
dell'anima.

         Avevo concluso quel lavoro in pochi giorni, forse quindici, anche se possedevo
qualche pagina preparata in precedenza. Pochi giorni perché - lo si sa - quando è il cuore che
detta, si conclude in fretta.

Desiderosa di ringraziare Gesù per tale lavoro, ero entrata nella mia cappellina, quando,
trovandomi di fronte a Gesù Eucaristia, prima di pronunciar parola, ho avuto la netta
sensazione che Lui - come per una ricompensa - mi dicesse: "Sono Io quel Gesù
abbandonato di cui tu hai scritto".

         E in quel momento, Colui che avevamo scoperto dovunque, in tutti i dolori personali
e in tutte le afflizioni per le disunità, i traumi, le separazioni che affliggono l'umanità; quel
Gesù abbandonato che avevo, con voi, cercato di amare durante tutta la vita, me lo sono
trovato lì di fronte, come fosse entrato in casa mia, in quel momento, per stare con me, in
ogni momento della giornata.

         Certamente avevo sempre cercato d'amare Gesù Eucaristia. Come avrei potuto fare
diversamente se so che Egli, nella santa Comunione, mi trasforma in Sé? Se so che Egli,
vincolo d'unità, perfeziona, anzi suggella l'unità che, con l'amore vicendevole, costruiamo
con i fratelli? Se ho sempre visto la sua presenza eucaristica come la possibilità per Gesù di
rimanere presente su tutti i punti della terra per amore nostro? Se… se.

         Ho scritto pure un piccolo libro su Gesù Eucaristia.

         Nel mio animo avevo sempre tenute distinte però le due sue presenze (che, fra il
resto, costituiscono due pilastri importantissimi della nostra spiritualità): Lui abbandonato
e Lui Eucaristia.
Ora le sue due presenze, di fronte alla mia anima, erano divenute uno ed io potevo scaricare
la piena del mio cuore su Gesù abbandonato-Eucaristia, di cui mi si era rivelato non tanto
uno dei tanti "volti" che abbiamo amato per decenni nel mondo, ma Lui in persona, mio,
nostro Sposo.

         Ora potevo avere verso di Lui non solo gli atteggiamenti che tutti abbiamo avuto, di
tempo in tempo: cercarlo, preferirlo, fargli festa, non sopportarlo ma amarlo, anzi amarlo in
modo esclusivo, coabitare con Lui..., ma adorarlo, sciogliermi in adorazione con
quell'annientamento totale di me-nulla di fronte a Lui-Tutto, che spesso si brama e strugge
ardentemente qualche volta il cuore.

         Era lì Gesù abbandonato, era lì in persona come sarà davanti a me il giorno del mio
giudizio, come sarà, se andrò, in Paradiso. Potevo parlargli, confidarmi, vedere con Lui i miei
programmi, venire, quando voglio, a visitarlo. Era mio. Non avrei dovuto andare lontano per
trovarlo. Egli stesso, poi, avrebbe alimentato il mio amore per Lui dovunque nel mondo
L'avessi cercato. E… e… ve l'assicuro, ho avvertito che questo fatto, questa sua così tangibile,
visibile, toccabile presenza accanto a me, cambiava la mia vita.

         Ed è stato così. E' quello che vado dicendo, quando narro questa piccola cosa: "Ha
cambiato la mia vita". E come!

Carissime, ho detto questo senz'altro perché è nostro dovere comunicarci le piccole o meno
piccole esperienze spirituali, onde aiutarci a proseguire nel Santo Viaggio, ma anche - lo
capite - perché - se già non lo aveste fatto - possiate far vostra la mia scoperta. Un fatto, una
cosa ovvia, se volete, ma che a me ha dato tanto.

         E, sapendo che ora s'apre la possibilità d'aver la presenza di Gesù Eucaristia non
solo nei nostri centrizona, punto di convergenza di tutti i membri del Movimento, ma anche
- salve le condizioni richieste - nei focolari, ho in cuore la speranza che salgano a Lui ancor
più atti d'amore di quanto è stato fatto finora. Senza trascurare il fatto - per chi non lo
avesse in casa - che Egli, Gesù abbandonato-Eucaristia è anche presente in tutte le nostre
chiese, dove a volte - per il poco amore dei cristiani - è più abbandonato ancora...

         Che l'amore, che l'adorazione a Lui, nostro tutto, ci divori! Questo il mio augurio.
Questo il nostro impegno per il prossimo mese.$doc1791$, 'drive_import', '01791-WEB-2001-04-19-sono-io-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1791)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1792, 'ITA', $doc1792$Castel Gandolfo, 17 maggio 2001

Autenticità e radicalità evangeliche

Carissimi,
         come sapete, da più d'una settimana sono tornata a Rocca di Papa al Centro, dopo

dodici giorni di soggiorno a Trento, con impegni quotidiani anche importanti e contatti
molteplici, nella gioia di molti e mia.

         E ora mi domando: su quale circostanza, su quale mia esperienza è utile vi informi in
questo nostro appuntamento mensile per trarre un qualche insegnamento spirituale per
tutti noi?

         Fra le tante e tante, posso sceglierne, penso, una, minuscola, passata forse
inosservata: la risposta ad una domanda che mi è stata fatta nel convegno dedicato ai
membri del Movimento delle Tre Venezie, svoltosi il 4 giugno. E' un interrogativo che si può
capire meglio nell'ambiente in cui è stato posto: a Trento appunto.

         Infatti, poiché è quella la città che ha visto i passi iniziali di noi, prime focolarine, è
facile che essa ci ricordi lo speciale stile di vita suggeritoci dal nuovo carisma.

         Vivevamo la spiritualità dell'unità, così come si fa ora in tutto il mondo, ma il nostro
vivere era caratterizzato da un'autenticità e da una radicalità evangelica, forse uniche.

         La scoperta, come per la prima volta, della Parola di Dio così speciale, diversa dalle
parole umane, luminosa, universale, così unica, da potersi tradurre in vita, immetteva nei
nostri cuori tale divino fervore ed entusiasmo, tale brama d'esserne subito l'incarnazione,
da non voler vivere se non come ancelle di essa, fedelissime seguaci della Parola, suoi calici
accoglienti. E, in questo modo, ci si impregnava di Vangelo, di quel Vangelo che, se è tale,
non può non infrangere il modo di vivere unicamente umano, rompere col mondo, ma anche
trascinare molti ad un'altra vita che dava origine alla comunità cristiana ed ingaggiava la
rivoluzione di Cristo.

Uno spettacolo questo, complesso e semplice, che dovunque, nel Movimento, potrebbe e
dovrebbe sempre ripetersi, spettacolo il cui primo attore non è che la Parola che si vive, la
Parola che ci vive.

         Certamente - come ebbi a dire altre volte - la vita che si conduceva, in quei primi
mesi, era facilitata dal fatto che si poteva concentrare tutto il nostro impegno lì,
nell'ascoltare e servire la Parola di Dio, poiché l'Opera, con le sue diramazioni, le sue
manifestazioni, le attività da seguire, non era ancora nata. Vita di cui Trento è stata
testimone, ma della quale non si vorrebbe e non si vuole assolutamente sia solo uno
splendido e affascinante ricordo.

         E, infatti, la domanda a Trento, di cui ho detto, era stata posta in questo modo:
"Come tornare ad essere così?"
         Ora, poiché questa è cosa di grandissima importanza per tutti noi, vorrei tentare di
dare attraverso questo Collegamento una risposta un po' esauriente, ricavandola da una mia
esperienza.

         Prima di partire da Roma mi aveva fortemente toccato una frase di Giovanni: "Egli
(Gesù) ha dato la sua vita per noi; quindi anche noi dobbiamo dare la vita per i nostri
fratelli" (1 Gv 3,16).

         Mi hanno impressionato queste parole e non solo perché ci si aspetterebbe una
conclusione diversa e cioè: "Se Egli è morto per noi, dunque anche noi dobbiamo morire per
Lui" (e non "per i fratelli" - come è scritto), ma anche perché quest'invito ad amare ogni
prossimo, che si incontra, con la misura della vita, m'era risultato assai forte.

         Cosicché se, arrivando in Cechia - ricordate? - avevo fatto il proposito di amare,
amare, amare, a Trento m'ero proposta, in cuor mio, di avvicinare ogni singola persona, ogni
gruppo, ogni piccola o meno piccola folla, pronta a morire per ciascuno.

         Ho cercato, quindi, che questo impegno, vissuto da me, naturalmente, con più o
meno pienezza, accompagnasse i miei giorni e che il mio amore per i prossimi imitasse
quello che ha avuto Gesù per noi.

Ebbene, così facendo, ho sperimentato giorno dopo giorno, che la Parola in noi può, anche
oggi, prendere il primo posto come allora: ergersi sopra tutte le cose, rimanere a galla su
tutto. Può tornare ad avere l'importanza di una volta e darci così il necessario distacco da
ogni cosa, e l'equilibrio, pur in mezzo a riconoscimenti ed ovazioni, che andrebbero
comunque tutti diretti a Dio.

Non solo: ma può permettere al Signore di farsi sentire in fondo al cuore, anche nei
momenti più chiassosi e disturbanti della giornata. Così come può dare al nostro fisico la
possibilità di non rimanere stressato da molteplici incalzanti attività.

Sì, mi sentirei di affermare che è possibile tornare a quei primi tempi.

Questa, pur cosciente che tutto potrebbe esser stato più perfetto, questa la testimonianza
della mia coscienza.

Carissimi, vi ho narrato questo. Perché ve l'ho narrato? Voi lo intuite: perché possiamo tutti
insieme fare ogni sforzo perché il Vangelo di Gesù possa tornare a brillare, attraverso le
nostre piccole e povere persone, nelle nostre case, nelle nostre città, nei nostri Paesi.

Se ciò avverrà, se Gesù stesso in noi sarà a mostrarsi al mondo, potrà fare cose degne di Lui.

         A luglio dovremo lasciarci vivere dalla Parola: "Sei tu, Signore, l'unico mio bene" (cf
Salmo 15). Viviamola di fronte ai dolori personali, ai fratelli bisognosi d'aiuto, nelle varie
difficoltà.  E che questa Parola stia sopra tutto; ci interessi prima di ogni altra cosa. E

che essa possa viverci in pieno.

Ascoltiamo ora le notizie del presente Collegamento che riguarderanno questo avvenimento
di Trento, dove il principale attore è, logicamente, lo Spirito Santo, mentre noi ne siamo solo
gli strumenti.$doc1792$, 'drive_import', '01792-WEB-2001-05-17-autenticit-e-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1792)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1793, 'ITA', $doc1793$Castel Gandolfo, 21 giugno 2001

Una grazia in più

Carissime,

         stanno terminando (almeno in alcune parti del mondo) le nostre vacanze in
montagna o al mare dove, fra le meraviglie del Creatore, abbiamo cercato di recuperare
forze fisiche per poterci rimettere presto al servizio dell'Opera che Dio ci ha affidato.

         Nello stesso tempo abbiamo voluto riprendere quelle forze spirituali che, durante lo
scorso anno, si erano un po' affievolite ed avevano bisogno d'un recupero per tanto
impegno profuso e non sempre centrato.

         Siamo, infatti, figli e figlie del nostro tempo di cui, se, da una parte, ne ammiriamo,
stupefatti, le conquiste tecniche e scientifiche, ne avvertiamo anche certe esagerate
esigenze, che, se non ben misurate, minacciano di consumarci inutilmente.

         E allora, preparandoci all'inizio del nuovo "Anno ideale" - così chiamiamo nel
Movimento il periodo che va da un ottobre all'altro -, non sarà inutile un piccolo esame per
vedere cosa in noi va bene e cosa non va.

         Siamo figli del nostro tempo che ama, e quasi adora, l'attivismo folle, che apprezza
quasi esclusivamente nelle persone l'efficienza, che valorizza alcune professioni e
sottovaluta se non disprezza, altre; che copre di silenzio certi momenti della vita per paura,
nell'illusione di cancellarli…

         E questo modo di pensare può arrivare ad influenzare qualcuno di noi che,
abbagliato da simili tendenze, spreca inutilmente energie, generando così nella sua vita un
pericoloso squilibrio.

         Non è certo da generalizzare, ma si deve pure ammettere che anche fra noi ci può
essere il pericolo di considerare, ad esempio, l'attività dell'Opera così importante, così
unica, da credere di dover spendere quasi tutto il tempo che si ha, a preparare programmi,
lettere, giornate, articoli, interviste, a pronunciare discorsi, e così via.

         E tale pensiero può essere così dominante da vedere inutili i giorni pur dovuti al
riposo, o da considerare le malattie, che Dio permette per un suo preciso fine d'amore,
intralci alla propria vita.

         Così succede che, nell'ora dedicata direttamente a Dio, si preghi in fretta, o
distrattamente, per continui pensieri che tornano e ritornano sempre sull'attività.

         Così accade che quando occorre dedicarsi allo studio, all'aggiornamento, ad
esempio, importanti impegni pure questi, non lo si faccia; se si fa, non lo si fa
diligentemente.
         E ancora può essere che, se accanto ai doveri diretti al servizio dell'Opera, ci si deve
impegnare in una professione esterna ad essa, la si sopporti come una penitenza; e, che non
ci si sappia fermare per comunicare le proprie esperienze spirituali ai fratelli o alle sorelle, e
si preferisca rimandare, per dopo poi, in pratica, trascurare questo dovere.

         Questi e molti altri, purtroppo, sono sbagli in cui possiamo incorrere.

         Ma, quando le cose stanno così, si è ben lontani dal tendere a quella perfezione a cui
siamo chiamati, e dal raggiungere la mèta che ci siamo proposti in momenti illuminanti
della nostra vita!

         Sì, perché tutti siamo chiamati veramente a farci santi ed a divenirlo secondo il
Cuore di Dio.

         Quel Dio che ci ama uno per uno di amore immenso ed ha sognato e disegnato per
noi un doveroso cammino da seguire, ed un traguardo preciso da raggiungere.

         Antonio, quando l'ho visitato l'ultima volta, non aveva che questa preoccupazione:
"Avrò compiuto il disegno che Dio ha su di me?" Ed io, pensando a quanto aveva patito
ultimamente, l'avevo tranquillizzato.

E allora occorre rimettersi per benino nella vita ideale perché il rimedio a questi mali c'è e
noi lo conosciamo: è chiamato sanatotum (guarisce tutto), ed è così essenziale che – come
abbiamo detto altre volte – al solo nominarlo, manda i santi in estasi. Esso è: fare ciò che Dio
vuole, la sua volontà, cioè obbedire a Dio, che è poi il modo d'amarlo; quell'obbedire così
importante che fa dire a santa Maria Maddalena de' Pazzi: "Una goccia di semplice
obbedienza vale un milione di volte di più che un vaso intero della più fine contemplazione".
E fa dire a Nicola de Flüe che l'obbedienza è la più alta virtù.

         E allora, per ben obbedire, già prima che cominci il nuovo anno, meditiamo, per
esempio, sui nostri Statuti e Regolamenti (io ho già cominciato a farlo con grande beneficio);
meditiamo la parte che riguarda ogni punto della nostra spiritualità ed ogni aspetto della
volontà di Dio che ci riguarda in ogni momento presente della vita, consapevoli che - e
questo è un grande dono - per ogni azione che compiamo in questa maniera c'è una grazia
speciale, aggiunta alla "grazia santificante": la cosiddetta "grazia attuale", un aiuto del
momento che - come sta scritto nei libri - "consiste concretamente in illuminazioni
dell'intelligenza e inclinazioni al bene, sia nella volontà che nella sensibilità". Una grande
cosa a cui poco, forse, pensiamo.
         Cerchiamo questo mese di sfruttarla al massimo. Quindi, attimo presente quella
volontà di Dio. Ci ritroveremo il prossimo mese con molti doni di luce e di forza nell'anima
in più.$doc1793$, 'drive_import', '01793-WEB-2001-06-21-una-grazia-in-pi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1793)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1794, 'ITA', $doc1794$Montet, 16 agosto 2001
La cosa più bella

Carissimi,

         sono passate più di due settimane, ma non riusciamo a dimenticare quanto i nostri
occhi hanno visto attraverso la televisione: l'immane sciagura piombata sugli USA, a New
York ed a Washington: tremendi avvenimenti che ci hanno convinto che assieme a tanto
bene innegabile, presente sul nostro pianeta, è vivo più che mai lo spirito del male che, con
luce luciferina, può compiere distruzioni tali da mettere in angoscia l'intera umanità.

         Come fronteggiare una simile potenza, come non arrendersi?
         Tutti gli spiriti liberi del mondo si ribellano; i governi stanno lavorando per
arginarla, questa potenza, militarmente e politicamente.
         E noi? Noi singoli, noi espressione delle nuove realtà ecclesiali, suscitate dallo
Spirito Santo proprio per affrontare con successo i problemi di oggi, che facciamo? Se alcuni
hanno dato una potente accelerazione per far trionfare la loro rivoluzione, si sono ad essa
preparati, anche personalmente, con lunga e puntigliosa disciplina, hanno dimostrato
d'essere pronti a morire per le loro idee, noi non sentiamo forse arrivata l'ora di giocare il
tutto per il tutto per il trionfo del bene?
         Certamente sì. E mi arrivano conferme dal nostro popolo focolarino.
         Ma come?
         E' inutile pensare ad altro: di fronte alle molteplici difficoltà di rapporti fra mentalità
così opposte, fra popoli così diversi, culture così lontane fra loro, religioni con la presenza di
estremisti che le distorcono, uno solo è il rimedio: la fraternità universale, fare dell'umanità
una sola famiglia con Dio Padre e tutti gli uomini fratelli.
         E questo come? Chi è meglio abilitato a ciò?
         Non c'è dubbio: un altro che ha saputo morire per il proprio ideale, ma poi risorgere
e dare a tutti questa possibilità, è Gesù. Dobbiamo puntare a riportarlo sulla terra attraverso
di noi, essere noi altro Cristo, altro Amore incarnato, Santità, Perfezione, com'è Lui.
         E' ora l'ora di tendere decisamente alla perfezione.
         Ma in che consiste la perfezione?
         Ho riletto recentemente, in un lavoro sulla vita spirituale, parole meravigliose di
Padri e santi della Chiesa, di grosso calibro. Le conosciamo, forse, ma non sarà inutile in
questo momento ricordarle.

         Per tutte queste persone eminenti della Chiesa la perfezione consiste nel non
fermarsi mai nella propria crescita, perché chi non va avanti, va indietro. E, giacché il nostro
è un cammino dell'amore, la perfezione sta nel crescere sempre nella carità.

         Amare, dunque, amare sempre meglio. Sempre meglio. Come? Fissando lo sguardo al
nostro perfetto modello: la Santissima Trinità, Dio Amore.

         Nella vita della Santissima Trinità ciascuna Persona è non essendo perché l'Altro sia.
Se il Padre – e ugualmente il Figlio e lo Spirito –, se il Padre non è (non è chiuso in sé, ma
apertura all'Altro; non è possesso di sé, ma dono senza riserve all'Altro), allora è: è amore.

         Così deve essere di noi: ognuno sarà se stesso se vivrà l'altro, il prossimo, o l'Altro -
con la A maiuscola -, Dio, la sua volontà.

         San Francesco di Sales dice: "Chi non guadagna, perde; per questa scala chi non
ascende, discende; chi non vince, rimane sconfitto".

         E' impressionante questa radicalità che l'amore esige. Ma tutto in Dio è radicale.

         Radicalità che si può contemplare anche nella seconda divina Persona fatta uomo in
Gesù.

         Egli nell'abbandono si svuota completamente di sé, dell'umano e del divino. E si può
vedere anche in Maria Desolata che avverte, in certo modo, il vanificarsi della sua maternità
divina, quando Gesù le mostra un altro figlio e perde così ciò che ha di più umano e divino.

         Dio domanda tutto. Non possiamo risparmiare nulla di noi stessi. Se così facciamo
non siamo, non siamo proprio noi stessi. Noi siamo, ripeto, se siamo l'altro, se siamo l'Altro.

         Richiede un vendere tutto quello che si ha e si è e non i soli beni. Ma proprio tutto. In
certo modo darsi, vendersi alla volontà di un altro, trasferirsi in altro. E ciò in ogni attimo
senza nulla risparmiare.

         Difficile? Facile?

         Provare e vedere. Ogni attimo darsi alla volontà di Dio, all'altro, al fratello che
dobbiamo amare, al lavoro, allo studio, alla preghiera, al relax, all'attività che dobbiamo
compiere. E ciò sempre meglio: ché altrimenti si va indietro.

Un aiuto per comportarsi così è ripetere ad ogni azione, anche la più semplice e banale:
"Questa è la più bella cosa che posso fare in questo momento". Allora si è; siamo noi perché
siamo Lui, Gesù che è Amore.
         Era impegno di Giovanni XXIII fare bene ciò che doveva fare nel presente come se
egli fosse nato solo per quello.

         In questo modo ci alleniamo anche noi per l'impresa che ci attende tipicamente
nostra: la fratellanza universale.$doc1794$, 'drive_import', '01794-WEB-2001-08-16-la-cosa-pi-bella-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1794)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1795, 'ITA', $doc1795$Castel Gandolfo, 16 dicembre 1999
2000
L’ora

Carissime,

         da un mese è trascorso Natale, l'ultimo del secondo millennio, anche se quest'Anno
Giubilare sarà tutto un Natale. Per questo vorrei oggi parlarvi del nostro Natale, quello che
in genere non si usa più chiamare così, ma che così era definito dai primi cristiani. Essi
vedevano il passaggio di ognuno di loro all'Altra Vita come il proprio Natale. Coincide,
quindi, con la fine della nostra vita quaggiù e l'inizio dell'Altra eterna e splendida, se
facciamo fruttare il dono di Dio.

         Siamo anche nell'anno in cui nel nostro Movimento si approfondisce il
comportamento che dobbiamo assumere di fronte a tutti gli aspetti della vita fisica. Ed un
aspetto di essa è, appunto, la morte e cioè, la nostra nascita.

         Questa volta vorrei parlarvi di essa. Me ne dà occasione una domanda rivoltami da
un gen 2, da un giovane, all'ultimo Congresso.

         Visto che anche i giovani, non di rado, la devono affrontare pur nella loro età tenera,
ha chiesto che se ne parli. E non era fuori luogo quella domanda se si pensa che il 28% di
quelli fra noi, che finora l'hanno sperimentata, erano o bambini o ragazzi o giovani. Dunque
quasi un terzo di quelli che noi chiamiamo i "Mariapoliti celesti".

         E' così. Il Signore può chiamare, e lo fa, a qualsiasi ora.

         Ma qual è il significato di questa nascita originale? E come va impostata la nostra
vita per poterla affrontare idealmente? Chi dà il vero senso alla morte?

         Noi siamo cristiani. E ciò dice tutto. Essere cristiani significa avere un preciso
modello da seguire: Gesù. In vita e in morte. Solo lui può dare una risposta convincente a
questo interrogativo.

         Come, dunque, Gesù ha visto e ha considerato la morte, la sua morte?
         Il Vangelo lo dice. La morte, la sua morte era vista da lui come la "sua ora", l'ora per
eccellenza della sua vita. Ad essa ha guardato, essa ha atteso durante tutta la sua esistenza.

         Egli aveva fatto grandi cose in quei tre anni di vita pubblica: aveva irradiato la
Parola, la Buona Novella, suggellandola con i miracoli; aveva formato discepoli che la
propagassero nel mondo; aveva fondato la Chiesa perché Lo continuasse nei secoli.

         Eppure tutti questi atti, il tempo speso per essi non erano importanti per lui come la
"sua ora", l'ora della sua morte che avrebbe coinciso con la sua risurrezione, quindi con la
sua nascita in Cielo. Gesù era venuto fra noi proprio per quell'"ora"; il compito affidatogli dal
Padre consisteva nel salvarci, e si afferma che senza "effusione di sangue", così dice la
Scrittura, cioè senza la morte, non c'è salvezza (cf Ebr. 9,22).

         Ora, guardando un po' la nostra vita, soprattutto di noi cristiani impegnati in una
realtà carismatica della Chiesa, possiamo vedere che essa, proporzioni fatte, è simile alla sua
e si è snodata e si sta snodando sul suo esempio.

Pure noi irradiamo una Parola, una luce di un carisma dello Spirito Santo. Pure noi, con la
grazia di Dio, abbiamo infiammato cuori e conosciuto discepoli. Pure noi abbiamo dato
origine ad una porzione di Chiesa: l'Opera nel suo insieme e nelle sue parti. Pure noi
camminiamo verso un'ora particolare, quella che il nostro amore per Cristo può trasformare
nella "nostra ora".

         L'"ora" nella quale tutto quanto facciamo avrà compimento ("Tutto è compiuto" ha
detto Gesù in croce); l'"ora" del suggello di tutto quanto abbiamo fatto, perché anche per
noi, senza la nostra "effusione di sangue" non avrà pieno valore quanto abbiamo attuato.

         Lo sappiamo che dobbiamo - come dice l'Apostolo Paolo - completare in noi (anche
se non ne avrebbe bisogno) la passione di Cristo ed è lì soprattutto con quell'"ora" che ciò
sarà possibile.

         Tutto questo, lasciatemelo dire, è veramente consolante. Almeno così lo sento io e
quelli che mi hanno sentito parlarne. Perché ora so che senso dare alla morte che verrà. So
come prenderla, come affrontarla. Non sarà certo il caso di subirla semplicemente, perché
non è l'annientamento del tutto; non è la fine; non è l'andare verso il nulla.

         Bisognerà viverla attivamente, sarà un continuare a "fare" qualche cosa per l'Opera,
qualcosa che è il coronamento di tutta la nostra vita. E noi in genere vogliamo sempre "fare",
sempre saper cosa "fare", perché siamo veramente figli di un Padre che, come dice la
Scrittura, "lavora sempre".

         Prepariamoci perciò a quell'ora, predisponiamoci, guardiamola come quel momento
in cui il nostro "fare" avrà il più grande effetto, il più alto significato; il momento per cui
siamo nati e vissuti. Il nostro "fare" in quei momenti naturalmente avrà il sapore di Gesù
abbandonato (anche se non solo, ci saranno anche le consolazioni); consisterà soprattutto
nell'offrire a lui momenti simili ai suoi.

Prepariamoci allora donandogli anche nel prossimo mese tutto quanto operiamo con un
"Per Te", ma offriamogli con predilezione soprattutto ciò che più ci costa, come sarà in
quell'ora. E, ricordandoci della nostra ora, ci verrà in rilievo e pronunceremo perciò ogni
giorno con maggior convinzione e ardore quella preghiera alla Madre nostra che ogni Ave
Maria ci propone: "Prega per noi (…) nell'ora della nostra morte".

         Così, avvolti dal suo sorriso, "faremo" a suo tempo anche questo. Sì, "faremo", per
nascere veramente a quella vita che non ha tramonto.$doc1795$, 'drive_import', '01795-WEB-1999-12-16-l-ora-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1795)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1796, 'ITA', $doc1796$Castel Gandolfo, 27 gennaio 2000

Come Chiara Luce

Carissimi popi che siete in giro, carissimi tutti,

nel nostro Movimento - pur tra le inevitabili prove a cui va incontro ogni Opera di Dio -
stiamo vivendo, in questi ultimi tempi, momenti di particolare gioia dovuta a vari fattori.
Uno di questi è senz'altro l'avanzare del processo di beatificazione di Chiara Luce Badano, la
nostra gen ligure, ora "Serva di Dio", che dalla diocesi, dove si è concluso un primo studio,
passa ora a Roma.
Chiara Luce! Quanta luce in questa nostra Chiara! La si legge sul suo volto nelle foto scattate,
specie nel suo ultimo periodo di vita.
Quanta luce nelle sue parole, nelle sue lettere, nella sua vita tutta protesa ad amare
concretamente tanti!
Città Nuova italiana e le sue 33 edizioni, sparse nel mondo, hanno iniziato a parlare di lei,
così la possiamo conoscere, possiamo bere alla sua vita, contemplarla come modello dei
nostri e di tutti i giovani, ma anche come testimone per giovani ed anziani di un ideale già
maturo in lei a 18 anni.
Non posso e non voglio anticipare qui granché della bellezza e grandezza e santità della sua
breve vita. Desidero che tutti noi cominciamo a conoscerla leggendo i nostri giornali o una
sua biografia che uscirà presto.

Anche se un pensiero lo voglio dire.
Un insegnamento, uno sprone lo voglio trarre dalle sue convinzioni tutte ideali.
Il Collegamento serve proprio per questo: per aiutarci a camminare avanti, e lei è già per noi
una battistrada.
In una delle sue ultime lettere mi confida la sua decisione - non dettata da altro, se non
dall'amore e dallo Spirito Santo nel suo cuore - di voler amare Gesù abbandonato per Sé e
non strumentalizzarlo a proprio beneficio.
Quindi amare il dolore per Lui, per Gesù abbandonato e non tanto perché la divina alchimia,
che conosciamo, lo tramuta in amore.

E di dolori Chiara Luce ne ha conosciuti molti, specie nell'ultimo tratto della sua vita
terrena. Ma aveva capito che erano le perle preziose che andavano colte con predilezione
lungo le sue giornate. Era in particolare nella sofferenza richiesta dalla fortezza, dalla
pazienza, dalla perseveranza, dalla costanza, ecc. (tutte virtù necessarie per potersi dire
cristiani in quei frangenti) che sentiva di poter amare.
Era nelle "sorprese" (così chiamava i ripetuti allarmi del suo fisico) che poteva incontrarsi
con Lui, veder apparire il suo volto, sfigurato e amante, ed abbracciarlo, come autentica
giovanetta "sposa avvinta ad un Dio abbandonato".
Per cui con Lui ha vissuto, con Lui ha trasformato la sua passione in un canto nuziale, se ha
voluto, una volta passata di là con la sua anima santa, vestire da sposa il suo corpo di qua,
curando in anticipo ogni particolare, perché lei, in quel momento, sarebbe stata, così ha
detto, "felice con Gesù". Così affermava e così voleva dicessero i suoi genitori.

Scelta radicale di Gesù abbandonato, la sua; scelta di ciò che fa male e che, se non si ama,
può trascinare lo spirito in una galleria oscura.
Sì, scelta di ciò che fa male.

In questi giorni, pensando a lei, che è balzata in primo piano sulla scena della nostra vita, ho
ricordato una frase contenuta in uno scritto noto del '49, intitolato: "Ho un solo Sposo sulla
terra". Dice: "Ciò che mi fa male è mio. Mio il dolore che mi sfiora nel presente. Mio il dolore
delle anime accanto...".

Forse è bene non attendere la vigilia del nostro passaggio all'Aldilà per ripeterla anche noi,
consci del suo valore, attratti da quella dinamica di vita a cui essa ci può portare.
In questo Collegamento invito me e tutti voi a fare di questa frase una "luce per i nostri
passi", per poter far corona alla nostra piccola santa (come speriamo di poter chiamare, fra
non molto, Chiara Luce), o "gen realizzata" come forse preferiscono i nostri giovani.
Queste parole: "Ciò che mi fa male è mio" non sono del resto che una nuova versione di
quello che già viviamo: "Sei Tu, Signore (= Gesù abbandonato), l'unico mio bene".
Sì, così: "Ciò che mi fa male è mio".

         E, perché queste non siano solo parole, cominciamo per abituarci, almeno per alcuni
giorni, a contare quante volte al giorno le mettiamo in pratica, le viviamo.
Funziona questo metodo e aiuta molto.
"Ciò che mi fa male è mio", in me, nei miei limiti fisici, morali e spirituali, e nei miei fratelli,
nelle loro sofferenze d'ogni genere. Sarà, indirettamente, un ulteriore ottimo contributo a
santificare non solo noi, ma Gesù in mezzo a noi.
"Ciò che mi fa male" è mio più di ogni altra cosa, come per Chiara Luce.
Coraggio allora! Non esitiamo a cominciare.$doc1796$, 'drive_import', '01796-WEB-2000-01-27-come-chiara-luce-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1796)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1797, 'ITA', $doc1797$Castel Gandolfo, 27 settembre 2001

Per la nostra ORA

Carissime,

         sono qui a Rocca, reduce dal recente viaggio che mi ha portato in Austria ed in
Svizzera di cui (almeno del primo) parecchi di voi hanno avuto qualche saggio attraverso i
benedetti (se usati bene) mezzi di comunicazione.

         Oggi vorrei comunicarvi un pensiero che da qualche settimana domina (è la parola
esatta) la mia mente ed ho già comunicato agli interni a Vienna, in Austria, ed a Baar nella
cittadella Pietra angolare, della Svizzera.

         Ultimamente ritornava nella mia mente un proposito, già apparso, ma ora più
insistente: "Se Gesù ha vissuto tutta la sua vita in vista della sua 'Ora' (quella finale della sua
esistenza terrena), anch'io devo fare altrettanto." Cercavo perciò di prepararmi nel modo
migliore a quella che sarà la mia ORA.

         Per aiutarmi avevo cominciato a fare meditazione su libri vari ed anche sul mio
libretto: La parabola del corpo, che riportano il pensiero della Chiesa su simile argomento.
Ma, confesso, senza risultato. Non ne avevo tratto grossi stimoli, non avevo provato nuovi
utili impulsi a vivere in conformità a quanto mi ero proposta.

         Finché mi sono ricordata di Luminosa, la nostra straordinaria focolarina argentina,
che, ammalata gravemente, e conscia della prossima fine della sua vita, aveva preso come
norma: "Continuare a giocare", ad imitazione di un santo che, interrogato, mentre giocava,
su cosa avrebbe fatto sapendo di dover morire, aveva risposto: "Continuerei a giocare". E
Luminosa ha continuato a giocare a suo modo, da focolarina, con le forze che aveva: a
scrivere, a telefonare, a pregare, ad accogliere persone sempre nella gioia più piena. A fare,
quando le forze erano diminuite, graziosi lavoretti a maglia da donare. E, dopo una corsa
verso Gesù, quando è arrivato il momento, ha detto a coloro che le stavano vicino - come per
passare il testimone -: "Adesso tocca a voi".

         Luminosa non aveva, dunque, pensato al dopo, meditato sul dopo per prepararsi alla
sua ORA: aveva vissuto il presente nella massima intensità.

         A rafforzare tale pensiero ed il mio conseguente proposito di fare altrettanto, ecco
che proprio in quei giorni mi è venuto in mano un nuovo libretto edito da Città Nuova,
curato da Enzo Fondi, incaricato, al Centro, del terzo aspetto dell'Opera, che ne ha fatto
anche una bella prefazione. Il titolo: Ogni momento un dono. Raccoglie miei pensieri scritti o
detti lungo gli anni sulla necessità di vivere bene il presente.
         Mi è apparso assai utile, e lo consiglio a tutti. Ho cominciato, quindi, a reimpegnarmi
a vivere il momento presente, ma, questa volta, con continue scoperte semplici, ma favolose
per noi che stiamo camminando nel Santo viaggio.

         Eccone alcune: una decina ve ne do, ma poi sono molte di più... Ecco le scoperte!

         Perché vivo il presente faccio meglio la volontà di Dio. E ne sappiamo l'importanza!

         Ma, perché faccio la volontà di Dio più perfettamente, amo, di conseguenza, con più
facilità, Dio con tutto il cuore, la mente, le forze, e il prossimo come Dio vuole.

         Facendo la volontà di Dio, cammino per la via che mi porta alla santità. (Ricordate la
scoperta dei primi tempi della volontà di Dio come possibilità di santità per le folle?)

         E ancora: se faccio la volontà di Dio, anniento la mia.

Ma, se anniento la mia, do gloria a Dio. E' come dirGli con la vita: "Tu sei tutto, io sono nulla".

         E nell'annientare la mia volontà trovo modo di amare Gesù abbandonato.

         Facendo la volontà di Dio, la mia vita, che potrei condurre umanamente, come in
genere si fa, continua invece l'"avventura divina", già sperimentata, durante questi anni, con
la costruzione di un'Opera di Dio. E si va compiendo così, attimo dopo attimo, il disegno che
Dio ha su di me.

         Vivendo bene l'attimo presente, m'accorgo di vivere in pratica tutte le virtù: la
pazienza, la povertà, la perseveranza, la costanza, l'umiltà (perché io sono niente), la
purezza, il distacco… e, naturalmente: la carità.

         E finalmente: vivendo così, sperimento con intima gioia la leggerezza e la soavità del
giogo del Signore.

         E non è finita…

Ed ora capite come mi sono innamorata a tale punto dell'attimo presente che, dopo un
mesetto dall'averlo riscoperto, sono ancora qui a fare, alla fine della meditazione (che può
spaziare sui più vari argomenti), il proposito di vivere il presente in un modo o in un altro.

Carissime, e allora cosa concludere?

         Vi auguro di "inabissarvi" ogni momento nella volontà di Dio o, come ha consigliato
il nostro Papa, di "arrendervi" alla volontà di Dio nell'attimo presente.

         La Madonna, che ne sa di volontà di Dio, ve la imprima nell'anima.

         Ve lo auguro con tutto il cuore.$doc1797$, 'drive_import', '01797-WEB-2001-09-27-per-la-nostra-ora-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1797)
on conflict (document_id, language) do nothing;
