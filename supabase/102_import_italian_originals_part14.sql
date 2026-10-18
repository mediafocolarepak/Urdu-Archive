-- 102_import_italian_originals_part14.sql (14/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1818-1830 (13 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1818, 'ITA', $doc1818$Castel Gandolfo, 11 dicembre 2003
2004
Apostoli del dialogo

Carissime,

         siamo ancora nel 60° anno del nostro Movimento, celebrato dal 7 dicembre 2003
fino all'Epifania, a Castel Gandolfo, con doni e doni: la visita di S.E. mons. Rylko, con parole
ricche d'unzione causate dal genius loci – come ebbe a dire – e cioè da un particolare
ambiente, il nostro. Prima cosa.
La seconda cosa: la lettera bellissima del santo Padre, seguita da una sua telefonata nel mio
focolare; e poi il dono dei sei meravigliosi "tuffi" - li chiamiamo - nella nostra storia, curati
dai focolarini, che arricchiranno e rallegreranno i nostri diversi convegni durante tutto
l'anno.
E poi, se non bastasse, un'ultima letterina del santo Padre in ringraziamento degli auguri e
per il dono del nostro consueto cesto natalizio.
E così il Cielo ci ha proprio coccolati, forse perché il Movimento è un perenne Natale con la
presenza sempre rinnovata di Gesù fra noi, ed è una continua Pasqua per lo sforzo di tutti di
far trionfare, con la grazia di Dio, il Risorto in noi.

         Ed eccoci ad un nuovo Collegamento, questo, quello di gennaio.
         Già vi ho promesso che esso verterà su qualche particolare della graditissima lettera
del santo Padre.
         Oggi, in modo speciale, sulla definizione che egli fa del nostro compito nella Chiesa e
nel mondo, della nostra missione.
         Il Papa chiama tutti noi: "Apostoli del dialogo". "In sintonia col Magistero della
Chiesa, le focolarine ed i focolarini si sono fatti apostoli del dialogo…" scrive. Un titolo nuovo
che non abbiamo mai avuto, anche se il contenuto di tutto il nostro agire è lì, nel dialogo.
         Occorre perciò chiederci: come ci vede il santo Padre? Come ci pensa Dio in quanto
"apostoli del dialogo"?
         Vedono essi un'attività da svolgere di tanto in tanto nelle ore d'incontro con altri
cattolici, singoli o di gruppo, con fedeli d'altre Chiese cristiane, con seguaci d'altre religioni e
con uomini di buona volontà?

         Senz'altro è così. Ma si può adempiere bene questo nostro prezioso dovere se per
noi focolarini, chiamati ad una spiritualità collettiva, il dialogo è permanente.

         E il motivo è questo: siamo tutti chiamati a rispecchiare in noi la Santissima Trinità,
dove le tre divine Persone sono in eterno dialogo, eternamente uno ed eternamente distinte.

         In pratica, per tutti noi significa che ogni qual volta abbiamo da fare con uno o più
fratelli o sorelle, direttamente o indirettamente: per telefono o per scritto, o in quanto ad
esso e a loro è finalizzato il lavoro che facciamo, le preghiere che eleviamo, ci sentiamo tutti
in perpetuo dialogo, chiamati al dialogo.

         Come?

         Aprendoci ad esso - al fratello, alla sorella -, ascoltando con l'animo vuoto cosa il
fratello vuole, cosa dice, cosa lo preoccupa, cosa desidera. E, quando ciò è avvenuto,
subentrare noi col dare quanto è desiderato, e quanto è opportuno.

         E se ho momenti ed ore dove devo dedicarmi a me stessa (per mangiare, riposare,
vestirmi, ecc.), fare ogni cosa in funzione dei fratelli, delle sorelle, tenendo sempre presenti
coloro che mi attendono. In tal modo e solo in tal modo, con un continuo vivere la
"spiritualità dell'unità" o "di comunione", posso concorrere efficacemente a fare della mia
Chiesa "una casa ed una scuola di comunione"; a far progredire, con i fedeli delle altre
Chiese o Comunità ecclesiali, l'unità della Chiesa; col realizzare, con persone d'altre religioni
e culture, spazi sempre più vasti di fraternità universale.

         Nella bellissima lettera del santo Padre c'è anche un pensiero sull'Europa e dà
indicazioni utilissime a tutti noi nella preparazione della Giornata di Stoccarda il prossimo 8
maggio.

         Faremo esame di questo pezzo della lettera nel prossimo Collegamento.

         Durante il mese di febbraio sentiamoci allora tutti "apostoli del dialogo" e viviamo
da tali. Un dialogo a 360 gradi, certamente, ma partendo col piede giusto: amando ogni
fratello che incontriamo con la misura del dono della vita.$doc1818$, 'drive_import', '01818-WEB-2003-12-11-apostoli-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1818)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1819, 'ITA', $doc1819$Rocca di Papa, 15 aprile 2004
Quale messaggio da Stoccarda?

Carissimi,

         nella Giornata di Stoccarda "Insieme per l'Europa" "c'era - è stato detto
autorevolmente - una fortissima energia, gioia, decisione, vitalità, coraggio, arte, profezia,
un'incredibile comunione d'intenti. Tutto era ben preparato - dicono - , tutto era bello. Una
manifestazione che apre orizzonti nuovi, che dà tanta speranza".

         E' stato veramente un capolavoro che un'altra autorità ha definito: una "cosa
miracolosa".

         Ma, a che si deve questo miracolo? A diversi fattori come, ad esempio, al cammino di
comunione, di alcuni anni, fra Movimenti e Nuove Comunità nelle singole Chiese; e, ad un
dato punto, fra Movimenti e Comunità di Chiese diverse, espressioni del profilo mariano
della Chiesa. Realtà ecclesiali queste desiderose ora d'offrire i frutti dei loro carismi per
un'"Europa dello spirito".
E ancora: la cosa è dovuta alla presenza d'autorità ecclesiastiche di diverse Chiese, unite
spiritualmente fra loro, espressione del profilo petrino della Chiesa; autorità consce della
necessità dell'unità nella Chiesa, anche per riparare all'esempio di disunità dato dalle Chiese
nei secoli.
Ancor si può dire: è stato un miracolo dovuto pure all'articolazione d'un programma
variegato, ricco di contributi letti e di espressioni artistiche; così come alla presenza forte e
intelligente dei giovani che si sono manifestati la speranza di un'Europa nuova.
E ancora allo sguardo verso il futuro, all'apertura dell'Europa al mondo.
E infine all'assiduo lavoro di mesi svolto nelle zone per preparare i punti d'ascolto.
Tutto ha contribuito a fare della Giornata qualcosa d'indimenticabile e a vederla come
l'avvio di un processo che incarnerà ideali e sogni.

         Ma come spiegare tale prodigio in una sola parola?
         Chi più vi ha lavorato sa dove sta il primo segreto di tanta ricchezza e bellezza: in
Gesù, spiritualmente presente in mezzo a tutti, che tanti si sono impegnati a mantenere vivo
costantemente, col loro reciproco amore a tutta prova, e con l'amore totale verso chiunque.
Così è stato e, forse, come raramente.

         A "Giornata" conclusa io ho ricordato soprattutto un altro prodigio di questo tipo, il
prodigio per eccellenza: quello - all'inizio della nostra storia - dell'accendersi dell'amore
divino, del divampare di un fuoco in mezzo all'odio efferato di un conflitto bellico:
l'esplodere di un'Opera di Dio, del nostro Movimento.

         Se analizziamo la cosa superficialmente, si può credere che il mezzo, di cui lo Spirito
Santo si è servito allora, è stato un discorsetto che io tenevo nella sala Massaia, a Trento,
dopo aver ripetuto innumerevoli volte a Gesù, nel tabernacolo della sottostante chiesa di
san Marco: "Tu sei tutto, io sono nulla", implorando, in tal modo, il suo diretto intervento
nelle mie parole.

         Ma, se ricordiamo bene, vediamo invece che non uno, ma due sono stati i mezzi
parimenti necessari: il discorso certamente, ma pronunciato ad un gruppo di persone
lievitato soprannaturalmente dall'amore senza misura delle prime focolarine, che, amando
ciascuna persona "da morire" - si direbbe oggi -, garantivano immancabilmente la presenza
di Gesù in mezzo a noi.

         Per questo, da un apporto di luce nella parola detta, effetto del nuovo carisma
dell'unità, e da un apporto d'amore, effetto anch'esso del nostro carisma che ci guidava,
prese vita una realtà nella Chiesa destinata ad invadere il mondo.

         Carissimi, tali pensieri mi hanno fatto nascere in cuore il desiderio di vedere con voi,
con tutti voi se, nella nostra doverosa irradiazione dell'Ideale, nelle molteplici
manifestazioni (Giornate, Mariapoli, ecc.), noi agiamo sempre così. Perché, se sempre fosse
così, vedremmo il prodigio di Trento e di Stoccarda ripetersi dovunque, e l'ut omnes
avanzare rapidamente.

         Gesù è sempre disposto a venire in mezzo a noi.

         Lo vorremo accogliere sempre?

         Sono certa del vostro "sì".

         Mettiamoci sotto allora e facciamolo, anche in previsione della seconda Giornata di
Stoccarda o d'altra città europea, che si suppone fra due anni, richiesta dai più e voluta dai
nostri superiori.

         Nell'immensa riconoscenza a Gesù per quanto abbiamo visto e imparato l'8 maggio
scorso, rimaniamo in piena unità fra noi e con tutti.$doc1819$, 'drive_import', '01819-WEB-2004-04-15-quale-messaggio-da-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1819)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1820, 'ITA', $doc1820$Rocca di Papa, 27 maggio 2004

Il mistero d'amore

Carissime,

         gli avvenimenti del mese suggeriscono di volta in volta il pensiero del Collegamento.
La volta scorsa è stato l'evento di Stoccarda.

         Oggi, dopo l'intenso viaggio a Londra, gli spunti per il Collegamento odierno
sarebbero molti. Ma forse è bene, un attimo, soffermarci su un'idea suggeritaci da Foco, del
quale, in questo mese, è iniziato il processo per la sua possibile beatificazione. L'idea è
questa: ha pensato Foco nella sua vita a farsi santo? Che idea aveva della santità?

Ho consultato, allo scopo, alcune documentazioni ed ho scoperto un Foco nuovo in certo
modo anche per me. Egli non solo ha meditato qualche volta sulla santità, ma è stato
immerso nel tentativo quotidiano di farsi santo. Come? Iniziando con l'impersonare quel
tipo di santo che egli definisce così: "Un cristiano con la spina dorsale", frutto perciò di
un'ascesi personale quotidiana.

E' una storia meravigliosa la sua, ma la brevità del pensiero del Collegamento mi costringe a
segnalarvi solo poche sue espressioni.

Nel 1941, sette anni prima che incontrasse noi, nel Diario di fuoco, un suo libro che iniziava
a scrivere, troviamo scritto: "Infine, quel che conta è una cosa sola: farsi santi".

Nel 1946, chiamato a candidarsi alle elezioni politiche, perplesso alquanto, si poneva questo
interrogativo: "Può un uomo politico farsi santo?" Non conosceva una risposta precisa al
suo anelito preciso: farsi santo.

         Quando nel 1948 incontrò noi, rimase, come egli disse, folgorato, sconvolto,
trasformato. Perché? Per più motivi, ma anche perché la sua spiritualità fino allora era stata
prevalentemente individualistica. Da quel momento invece, specie dopo il famoso Patto del
'49, gli si era aperto un cammino di santità collettiva. Definiva il nostro come "un
Movimento che ci induce a fare la scalata a Dio in unione, in cordata… Il fratello vale come
ianua coeli, …", la porta del cielo. E scrive: "Dio scende in me per il tramite del pane
(eucaristico); io salgo a Lui per il tramite del fratello".

Immerso nella spiritualità comunitaria, in un colloquio intimo con Gesù lo ringrazia così: "Il
tuo amore mi ha scoperto i fratelli (…); me ne ha fatto il viatico per salire sempre di terra in
cielo".

E' poi suo quello che chiamerà il "mistero d'amore": (…) "Dio, il Fratello, Io".
Nel 1955, in mezzo alle prove che non mancano mai a nessuno, va acquistando una certa
familiarità con la Santissima Trinità, ed anche qui il bisogno di santificarsi si fa evidente.

"Questi passi - scrive -, affaticati (…) sono la marcia di ritorno alla casa tua, o Padre; (…)
tutte queste pene, si fanno gocce di sangue, del tuo Sangue, o Figlio; (…) e questo bisogno di
santificarsi è partecipazione dei tuoi doni, o Spirito Santo".

         Da particolari episodi della sua vita si capisce come lo Spirito Santo, in questa sua
tensione alla santità, lo abbia pian pianino introdotto nella vita mistica. Così era stato quel
giorno dell'ottobre '57 quando gli viene concessa quell'esperienza di straordinaria bellezza
con Maria, che conosciamo per averla letta nella cattedrale di Frascati. E dà questa
definizione del santo: "Il santo altri non è che un innamorato: innamorato di Dio, riflesso in
Maria (…) un innamorato della Madonna".

         Percorre poi un cammino di distacco progressivo da ogni cosa, ma lo vede come la
possibilità di santificarsi nell'unione con Dio: "Osservando - scrive - con pena questa caduta
di fronde (illusioni di fama, di potere, amicizie), dall'albero della mia vita, (…) mi sono
ancora meglio accorto (…) che ho un più intenso convegno amoroso con Dio: l'anima trova
tempo (…) per intrattenersi con lo Sposo (…), per convivere con gli angeli e con i beati (…).
Ora, via via l'unione si fa costante. Imparo e preparo la vita del Paradiso".

A proposito di vivere Gesù al posto del proprio io (è stato questo un suo desiderio costante),
scrive nel '63: "Parmi oggi d'aver (…) compiuto il trasloco; il trasloco del mio essere: dall'Io
a Dio".

E "sente" l'unione con Dio: "Ecco - dice - l'immensità di Lui (…), io la sento nell'intimo della
mia anima (…). Mi rivolgo all'interno e L'ascolto: Lo vivo: si stabilisce, nel fondo dell'essere,
un colloquio con l'Eterno: Dio in me".

         E l'anno dopo incalza: "Ora sento che si vola (…)".

Due anni prima della partenza per il Cielo, conferma: "Sento d'aver trovato l'accesso libero
per andare a Lui. Ora sono in terra e abito in cielo (…) Sono di Dio. Non mi serve altro".

         Queste le poche frasi di Foco che ho potuto riportare sul suo anelito alla santità.

         Che dire? E che cosa dice Foco a noi, ancora pellegrini su questa terra?

         Proprio nell'anno '80, in cui egli è passato all'Altra Vita, nasceva questo nostro
Collegamento. Esso - lo sappiamo - aveva per scopo di farci fare un "Santo viaggio": un
viaggio, dunque, verso la santità. E' come se egli, lasciandoci, ci avesse detto: "Ecco la vostra
possibilità. Ora tocca a voi".
         Percorriamo allora questo viaggio con amore. Facciamoci santi, imitando Foco
soprattutto nel suo "mistero d'amore": "Io, il fratello, Dio". Amiamo il fratello, ogni fratello
pronti a morire per lui. Sarà anche per noi la porta del Cielo.

Gesù, Maria e Foco ci aiutino.$doc1820$, 'drive_import', '01820-WEB-2004-05-27-il-mistero-damore-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1820)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1821, 'ITA', $doc1821$Rocca di Papa, 28 giugno 2004
Dar gioia a Dio in Cielo

Carissimi,
         abbiamo trascorso anche quest'anno, un magnifico giorno di santa Chiara, benedetto

dalla telefonata del santo Padre con i suoi auguri.
         E rieccoci al Collegamento di agosto.
         L'estate per noi a Mollens è stata un riposo, ma anche un lavoro per prepararci al

nuovo anno Ideale, ai suoi molteplici impegni, agli straordinari avvenimenti come "il ritorno
a casa" - a noi sembra proprio di poter dire così - di Foco e di Renata, ormai servi di Dio, le
cui salme saranno tumulate, la prima nella piccola chiesa del Centro dell'Opera a Rocca di
Papa, l'altra nella grande nuova chiesa, dedicata alla Theotókos, di Loppiano.

         Fra i vari compiti di quest'estate, oltre la solita lettura delle cosiddette "Paginette",
che danno relazione della vita di ogni zona, c'è stata un'ulteriore revisione degli Statuti,
dove vi abbiamo apportato quanto era stato suggerito ultimamente anche da voi.

         Fra le precisazioni, tutte necessarie, una mi ha particolarmente impegnato e m'ha
dato particolare gioia: un nuovo ordine nei vari cardini della nostra spiritualità.

         E' da molto tempo, infatti, che avverto in cuore una certezza: la nostra "spiritualità
dell'unità", vissuta, ha soprattutto un perché: renderci atti, abilitarci a saper mettere "Gesù
in mezzo a noi", a "generarlo" - direbbe Paolo VI - spiritualmente nel mondo, così come
Maria l'ha dato anche corporalmente.

         "Gesù in mezzo a noi" risulta così l'ultimo dei 12 punti della nostra spiritualità, a cui
tutti gli altri confluiscono.

         Di qui pure il perché del tema dell'anno Ideale. Se il 2003-2004 è stato incentrato
sull'"unione con Dio" (argomento che, a quanto so, ha operato nel mondo un grande bene),
quest'anno sarà proprio su "Gesù in mezzo a noi".

         Un tema nuovo, insolito, che non ripete quelli già conosciuti.
         Ci sarà, in una prima parte, il tentativo di spiegare "Gesù in mezzo a noi"
teologicamente e nei suoi riflessi ecclesiologici.
         In una seconda parte si cercherà di coglierlo, secondo il nostro metodo tradizionale,
negli scritti di quei giorni in cui s'è manifestato a noi la prima volta, per effetto del nuovo
carisma.

         Dall'insieme, tutti noi potremo acquisire una coscienza nuova su quale straordinario
apporto "Gesù in mezzo a noi" può portare oggi nella Chiesa e nel mondo. Una scoperta che
se da una parte ci entusiasmerà, dall'altra ci intimorirà per la coscienza della nostra
indegnità di fronte ad una vocazione così particolare.

         In questo mio Pensiero vi voglio suggerire, intanto, come prepararvi a ricevere tale
dono.

         "Gesù in mezzo a noi" non è certo una novità per noi. Ci sforziamo sempre di averlo
presente nella nostra vita comune, nelle nostre piccole e grandi comunità e riunioni.

         Conosciamo anche i suoi straordinari effetti come, ad esempio, ultimamente, alla
Giornata dell'8 maggio scorso a Stoccarda, il cui successo si deve soprattutto a Lui; o nei
nostri recenti simposi con persone d'altre fedi, dove Egli ha parlato ai cuori di quei nostri
fratelli, svelando loro verità importanti.

         E allora, in questo tempo di attesa, cerchiamo di vivere con Lui presente fra noi, con
la massima tensione. Solo così potrà essere fuoco su fuoco quello che vi sarà comunicato.

         Anzi, cerchiamo di vivere così, grati, perché "Gesù in mezzo a noi" sarà la nostra
gioia, ma più perché, per Esso, potremo dar ulteriore gioia a Dio in Cielo.

         Mi fanno sempre impressione le parole di Teofilatto, vescovo della Bulgaria, che
dice: "In verità, Dio gioisce non di una grande moltitudine, se mai 'dove sono due o tre
riuniti nel suo nome, lì è in mezzo a loro'".

         E se Dio gioisce - pensiamo noi - dove c'è unità, quale cosa più grande di fare della
propria vita una catena di giorni che aggiungano alla beatitudine, di cui Dio già gode, una
gioia accidentale?

         Andiamo avanti, allora, con questi propositi in cuore.
         Nel frattempo, state certi, io sarò con tutti voi a vivere "Gesù in mezzo a noi"
seppure da lontano.$doc1821$, 'drive_import', '01821-WEB-2004-06-28-dar-gioia-a-dio-in-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1821)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1822, 'ITA', $doc1822$Mollens, 26 agosto 2004
Una sola cosa

Carissime,

         eccoci al Collegamento di settembre che, come tutti quelli che abbiamo cercato di
vivere da più di vent'anni, ha lo scopo d'aiutarci a fare della vita un Santo Viaggio, di
portarci cioè alla santità.

         Che dirvi, oggi?
         So che ogni volta vi aspettate sempre un pensiero nuovo che ci aiuti a quest'impresa,
la più importante che si possa pensare per la vita. Ma questa volta ciò che vi dirò già lo
sapete, lo conoscete in teoria e, chi più chi meno, in pratica; è però di tale importanza che
merita assolutamente sottolinearlo. E' questo uno dei casi in cui hanno valore le parole:
"Repetita iuvant", le cose ripetute giovano.

         Ora in settembre, come nel mese di agosto, uno degli impegni che sto compiendo è
quello di leggere le brevi relazioni, che anche quest'anno mi sono arrivate da tutte le zone
del mondo, in preparazione agli incontri che avrò in ottobre con ciascuno e ciascuna
responsabile. Si tratta delle cosiddette "paginette", chiamate da noi in tal modo per la loro
forma sintetica.

         Quale quest'anno la mia reazione scorrendole?
         Una nuova grande gioia ed una più profonda riconoscenza a Dio, sempre principale
autore ed attore della sua-nostra Opera. Infatti, quasi tutte affermano, dichiarano - e lo si
può costatare leggendole -, che quest'anno il Movimento ha avuto dovunque un balzo in
avanti, una solidità interna e un'espansione all'esterno come forse non è mai stato.
         E vien da chiederci: a che si deve questo straordinario risultato? Voi stessi in zona lo
avete capito. Avendo, tutti i membri del Movimento approfondito quest'anno la loro unione
con Dio, si è avuto dovunque come effetto - e ciò può sembrare poco conseguente - una
presenza del Risorto in mezzo a voi più piena e più costante; presenza che spiegherebbe i
progressi interni ed esteriori ottenuti.
         Il fatto è che avendo scelto nel Movimento, come via privilegiata per arrivare
all'unione con Dio, il fratello, l'amore al fratello, vi siete trovati ad incrementare anche in
focolare e dovunque l'amore reciproco, e con esso la presenza di Gesù fra voi: una sua
presenza non ricercata in se stessa, ma come risultato del vostro agire.

         E ciò per noi ha una grande importanza. Sappiamo, infatti, che il Signore ci ha tutti
chiamati ad una spiritualità nuova, la "spiritualità dell'unità", quella stessa che il santo
Padre Giovanni Paolo II propone a tutta la Chiesa come "spiritualità di comunione". Essa ha
– lo si sa – una sua precisa caratteristica: è personale e comunitaria insieme. E come tale
sembra richiedere: e un impegno per farci progredire personalmente nell'unione con Dio ed
un altro per attuare la nostra comunione con i fratelli.

         Duplice tensione, duplice atteggiamento che può dare l'idea di un iter spirituale non
del tutto semplice, non lineare, un po' complesso insomma. E invece no. Ed è qui la grande
riscoperta fatta quest'anno in tutto il Movimento: unione con Dio e unione con i fratelli si
attuano in un solo momento, sono contemporanee, sono un'unica cosa.

         Vuoi raggiungere l'unione con Dio? Unisciti con ogni fratello, e… ti troverai in cuore
l'amore verso Dio, l'unione con Lui, la comunione con Lui.

         Ami tutti quelli che incontri nella tua giornata "da morire" - come noi diciamo -, da
essere pronto cioè a dare la vita per loro? E subito il Signore si farà sentire nel tuo cuore.

Lo sapevamo che i due amori sono legati, ma non proprio così. Sono una sola cosa. Ed è una
cosa meravigliosa, specie per noi laici che viviamo nel mondo dove sono meno possibili
atteggiamenti, pratiche spirituali complicate.

         Quest'anno, come ho già accennato anche l'altra volta, il tema su cui ci intratterremo
e dovremo poi vivere sotto una luce nuova, è Gesù in mezzo a noi. E poiché, come ho detto,
Gesù in mezzo a noi s'è consolidato nella nostra ricerca d'unione con Dio, penso che non si
poteva trovare un tema più indicato.

Carissime,

         come sappiamo, il Signore ci ha dato la gioia di vedere in vita il nostro Ideale
arrivare fino agli ultimi confini della terra. Perché? Come mai? Per diverse cause,
certamente; ma la più importante di tutte è senz'altro quella d'aver concorso a riportare, in
certo modo, Gesù nel mondo.
         Con l'approfondimento di quest'anno, chissà quale traguardo potremo raggiungere
se corrisponderemo. La rete già stesa sulla terra si intensificherà, il Regno di Dio
s'allargherà, il mondo unito apparirà più vicino. E noi lo perseguiremo seguendo le
indicazioni di Dio, Signore della storia.

         E allora?

         Non smettiamo un attimo, anche d'ora in poi, di cercare l'unione profonda con Lui
attraverso l'amore appassionato per ogni fratello.$doc1822$, 'drive_import', '01822-WEB-2004-08-26-una-sola-cosa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1822)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1823, 'ITA', $doc1823$Rocca di Papa, 23 settembre 2004
2005

Perfetti come il Padre

         Il comando di Gesù: "Siate perfetti come il Padre" (Mt 5,48) è comando che vale per
tutti in ogni attimo della loro vita: anche per il peccatore appena convertito. Vale quanto le
altre parole di Gesù.

         Come, ad esempio, tutti sempre debbono amare il prossimo come sé stessi, così tutti
sempre debbono essere perfetti come il Padre.

         Ma ciò è possibile solo se ci mettiamo a farci santi ponendoci nell'ordinaria
condizione indispensabile per divenirlo, cioè se a base della nostra santità (ante omnia,
anche prima della santità) poniamo la mutua carità: Gesù fra noi come premessa o principio,
come mezzo per santificarci e come fine.

                                                                     Chiara (1950)$doc1823$, 'drive_import', '01823-WEB-2004-09-23-perfetti-come-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1823)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1824, 'ITA', $doc1824$Aprile 2005
Divina Comunione

Carissime e carissimi,

         eccomi a voi con un pensiero sull'Eucaristia, vincolo di unità, nutrimento dell'unità,
inizio e culmine dell'unità.

         Lo faccio anche a ricordo di Giovanni Paolo II che aveva voluto dedicare quest'anno
all'Eucaristia. E' ripreso da un discorso del 1961, ma mi sembra forte, profondo e sempre
attuale.

         "Dio si è fatto uomo per salvarci. Ma, fattosi uomo, ha voluto addirittura farsi cibo
perché, nutrendoci di Lui, diventassimo altri Lui.

         Ora, una cosa è vedere Gesù (come se fossimo vissuti ai suoi giorni), un'altra cosa è
riessere Gesù: poter essere un altro Gesù sulla terra.

         L'Eucaristia ha proprio questo scopo: nutrirci di Gesù per farci essere altri Lui,
perché Gesù ci ha amati come se stesso".

         Benedetto XVI il giorno del Corpus Domini ha detto: "Mangiare questo pane è
comunione, è entrare nella comunione con la persona di Gesù vivo. (…) Scopo di questa
comunione è l'assimilazione della mia vita alla sua, la mia trasformazione e conformazione a
Colui che è Amore vivo."

         Che Gesù veda in noi il frutto della Sua totale donazione.

         Ecco un pensiero.
         E adesso un saluto a tutti i popi del mondo e a tutte le persone del nostro
Movimento.
         Ciao, a presto.$doc1824$, 'drive_import', '01824-WEB-2005-04-divina-comunione-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1824)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1825, 'ITA', $doc1825$Giugno 2005
Santa Chiara e l'Eucaristia

Carissime e carissimi,

         immagino che in ogni focolare, in ogni cittadella si faccia festa nel giorno di santa
Chiara.
Quest’anno siamo più che mai uniti per la viva, profonda, universale presenza di Gesù in
mezzo a noi, che riempie ogni vuoto e colma ogni separazione.

         Come sempre, nella festa di santa Chiara ricordiamo qualcosa della sua vita,
qualcosa che può illuminarci e aiutarci nel nostro santo viaggio verso la stessa mèta, anche
se per vie diverse.
Questo per la Chiesa è l’anno dell’Eucaristia.
Come santa Chiara ha amato l’Eucaristia?
Discepola di Francesco, santa Chiara è affascinata dall’abbassamento e dal nascondersi di
Dio nell’incarnazione, nella passione e nell’Eucaristia. E si sente chiamata a imitare Gesù nel
vivere questa “altissima povertà”.
Per noi l’altissima povertà è Gesù abbandonato che ci ha chiamato, che abbiamo seguito e
che dobbiamo amare con fedeltà.

         Santa Chiara non parla espressamente nella Regola dell’Eucaristia (anche se riesce a
chiedere e ottenere per le sue sorelle la Comunione sette volte all’anno, al posto delle 3
volte di altri Ordini), ma il Celano, l’autore della sua Vita, scrive: “Quanto intenso fu l’amore
devoto di santa Chiara verso il sacramento dell’altare lo dimostrano i fatti”.

         Nel Processo e nei Fioretti si racconta che essendo gravemente ammalata e
addolorata di non potersi recare alle funzioni liturgiche, “Gesù Cristo suo sposo, non
volendola lasciare così sconsolata, si la fece miracolosamente portare alla chiesa di santo
Francesco”, dove poté partecipare alla Messa e ricevere la santa Comunione.

         Altro episodio. Quando i saraceni entrarono nel monastero, santa Chiara si fece
“portare el santo sacramento del corpo del Signor Nostro Jesù Cristo. E gittandosi prostrata
in orazione, con lacrime pregò dicendo queste parole: 'Signore, custodisci Tu queste tue
serve, però che io non le posso custodire'.” E lei stessa testimonia di aver udito una voce “di
meravigliosa soavità”, che diceva: “Io le difenderò sempre!” Allora santa Chiara pregò anche
per Assisi. E quella medesima voce disse: “la città passerà molti pericoli, ma sarà difesa”. E i
saraceni se ne andarono senza fare alcun danno.

         Nei secoli seguenti, nella storia della Chiesa, si è evoluta la dottrina sull’Eucaristia.
Basti pensare alle cattedrali gotiche costruite in onore di Gesù Eucaristia, a san Pio X, che
l’ha concessa ai bambini, e a san Pier Giuliano Eymard che ha fondato due congregazioni del
SS. Sacramento.

Nei nostri Statuti si consiglia la Comunione quotidiana per trasformarci in Cristo, fino a
vedere il nostro corpo eucaristicizzato, come eucaristia della terra, pegno di risurrezione
del cosmo, dopo la morte.

         Nella terza lettera ad Agnese di Praga, Chiara sembra comunicare la sua esperienza
di contemplazione vissuta nell’Eucaristia: “Colloca il tuo cuore in Colui che è figura della
divina sostanza, e trasformati interamente, per mezzo della contemplazione, nella immagine
della divinità di Lui. Allora anche tu proverai ciò che è riservato per coloro che lo amano”.

         Nella nostra via collettiva la contemplazione si è aperta con il patto d’unità tra Gesù
Eucaristia in me e Gesù Eucaristia in Foco. E in questa divina unità abbiamo contemplato il
Paradiso, cielo dopo cielo.

         Chiediamo a Gesù Eucaristia di rinnovare Lui questo patto sul nulla d’amore dei
nostri cuori. Esso ci fonde in uno, ci fa essere il Suo corpo mistico sulla terra, ci fa vivere la
Chiesa.$doc1825$, 'drive_import', '01825-WEB-2005-06-santa-chiara-e-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1825)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1826, 'ITA', $doc1826$agosto 2005
Nell’approssimarsi del nuovo anno

Carissime e carissimi,

         siamo nel mese di ottobre in cui convengono al Centro i responsabili di tutte le zone
del nostro mondo ideale, come petali che si chiudono in un unico bocciolo.

         Ho letto le cosiddette "paginette" riassuntive della vita dell’anno che ogni
responsabile di zona mi ha inviato.
E’ stato l’anno di "Gesù in mezzo". E avete cercato che Egli fosse sempre presente non solo
nei focolari, nei nuclei e nelle unità gen, ma anche fra le varie branche dell’Opera, nel
consiglio di zona, così che sia Lui a illuminare, a guidare le mosse.

         E veramente mi sembra di poter dire che si sono visti i frutti, gli sviluppi dovuti alla
Sua presenza.

         Vi riporto alcuni commenti che mi sono venuti spontanei alla lettura dell’una o
dell’altra "paginetta".

"C’è vita!"
"In forte crescita."
"Zona grossa, fruttuosa."
"C’è futuro, vivacità e sviluppo."
"Bene, considerando l’ambiente e le molte difficoltà."
"Penetrano dovunque senza invadenza."
"Bravi!"
"Camminano puntualmente con la vita attuale dell’Opera."
"Tutto va avanti, il futuro è assicurato."
"Zona piccola, ma buona."
"Rafforzare il nostro Movimento in zona per essere all’altezza del dialogo interreligioso."
"C’è sviluppo, ci sono novità."
"Hanno gli anni alle spalle."
"Fanno il massimo."
"Tutto in fioritura."
"Zona che scoppia."
"Presenti su tutte le frontiere."
"Molto attivi."
"Buon inizio."
"Abbonda la vita."
"Bene: mi è cresciuta la stima per i due capozona."
"Tanto aperti! Bella cosa."
"Vanno a fondo e al largo."
"Molto oggettivo."
"Bello, purché le attività dello Statuto precedano le altre."
"Lavoro fecondo e promettente."
"Molto impegnati, anche con fantasia."
"C’è sviluppo, c’è equilibrio."
"Solidità e crescita."
"Abbondanza di frutti."

Alla fine della lettura delle "paginette" mi sono chiesta: come mai tanto sviluppo, più del
solito?
E ho capito che anche quest’anno abbiamo avuto la grazia dei consiglieri delle grandi zone.
Non poteva essere che così.

         Affidiamo all’amore e alla misericordia del Padre questo anno ideale che si chiude.

         Per il prossimo, il tema sarà Gesù crocifisso nel suo più grande dolore: l’abbandono
del Padre.

         Dall’inizio, ancora a Trento, il 24 gennaio 1944, lo Spirito Santo ci ha voluto
presentare il più grande dolore che Gesù abbia vissuto per noi. Dunque il suo più grande
Amore: perdendo Dio ci ha fatti figli di Dio. E questo ci ha penetrato l’anima a tal punto da
voler rispondere con tutte noi stesse al suo amore, da volerci consacrare a Lui, e lavorare
perché milioni di altri uomini e donne lo amino.

         Da lì è nato il Movimento dei Focolari.
         Ritorniamo a Lui: ci farà veri figli del Padre, fratelli gli uni degli altri, famiglia di
Maria.

         E adesso un saluto a tutti. Ciao.$doc1826$, 'drive_import', '01826-WEB-2005-08-nell-approssimarsi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1826)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1827, 'ITA', $doc1827$settembre 2005

Essere sempre famiglia

Quando Gis è venuta a trovarmi e mi ha chiesto una parola, ho scritto: "Essere sempre
famiglia".
E mi sembra che il mese d’ottobre sia stata l’occasione speciale per crearla tra i responsabili
del Movimento al cuore dell’Opera. Gesù in mezzo a noi vissuto, costruito e ricostruito,
ampliato dalle comunicazioni della vita delle varie zone, alimentato dal cointeresse tra
Centri e periferia, dalla comunione personale, dalla sapienza, è la realtà base della nostra
famiglia.
Se una volta ho detto che l’amore di una madre (senza limiti, disinteressato, che perdona
sempre, che tutto spera…) è il più simile all’amore divino, se l’amore di un padre è quello su
cui puoi appoggiarti, che ti dà sicurezza, se l’amore fraterno ti dà coraggio e ideali comuni
nell’affrontare la vita, il nostro "amore reciproco" deve contenere tutti questi sapori!

         Tornati nel mondo, non perdiamo mai la realtà di far parte di una meravigliosa
famiglia legata dallo Spirito Santo!
Custodiamola con la sua intimità, con la partecipazione alle gioie e ai dolori dei suoi
componenti, come è proprio di ogni famiglia. Manteniamo vivo lo scopo per cui Dio ha fatto
nascere la nostra Famiglia, l’Opera: testimoniare l’unità.
Un’unità come nella Santissima Trinità, ha chiesto Gesù (cf Gv 17,21). Che divino, eccelso
obiettivo!
O, trasferita in terra, un’unità come nella famiglia di Nazareth!

         Anni fa ricordo d’aver pregato Maria di formarsi in terra una "Famiglia di figli e figlie
tutti Lei".

         Con commozione e riconoscenza a Dio vediamo oggi l’Opera di Maria, riconosciuta
dalla Chiesa come "una presenza di Maria e una sua continuazione sulla terra" (cf Statuti
Generali art. 2).

         Dunque quella famiglia s’è fatta realtà: è la Famiglia di Maria.
              Chiara

Ottobre 2005$doc1827$, 'drive_import', '01827-WEB-2005-09-essere-sempre-famiglia-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1827)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1828, 'ITA', $doc1828$Rocca di Papa, 20 febbraio 1998
Migliorare per dirTi che Ti voglio bene

         Carissime e carissimi,

         avevo già pronto il nuovo pensiero, quando parecchie lettere di persone, che mi
ascoltano al Collegamento, mi hanno fatto cambiare idea.

         In esse, infatti, mi si domandava di continuare a vivere il "Per dirTi che Ti voglio
bene".

         I motivi? Vari. Praticamente perché quelle parole avevano dato uno slancio nuovo al
loro amore per Dio; perché soddisfacevano maggiormente i desideri del loro cuore ed erano
molto gratificanti. Sentivano, con esse, di poter dare a Dio non soltanto la propria mente, la
propria volontà e le proprie forze, ma anche i propri sentimenti.

         E si capisce: nella persona umana esistono anche i sentimenti.
         Se li prendiamo per se stessi, da soli, sono vanità e noi, impegnati come siamo in una
vita spirituale, non li consideriamo.
         Ma, se li accompagniamo alla volontà, all'intelligenza, essi completano la nostra
personalità, anzi le danno quel tocco, in più, di umanità che, altrimenti, mancherebbe.
         Di qui, nel poter dire a Gesù, di fronte ad ogni azione: "Per dirTi che Ti voglio bene",
quel senso di pienezza, di soddisfazione.

         Ma è stata fatta un'altra considerazione.
         Qualche mese fa abbiamo sottolineato il "migliorare" e ne abbiamo visto la grande
necessità, anzi l'urgenza - vorrei dire - di attuarlo con serietà, perché verrà un giorno in cui
non sarà più possibile.
         Quello slogan però, particolarmente apprezzato dai focolarini presenti qui, a Castel
Gandolfo, per l'incontro natalizio, si mise in pratica per troppo poco tempo.
         Mi è stato suggerito perciò di proporre di vivere l'uno e l'altro, così congiunti:
"Migliorare per dirTi che Ti voglio bene".
         Ho provato, allora, qualche giorno a metterlo in pratica e, nonostante fosse più
lunghetto dei soliti, ho visto che funziona. E come!

         Perché ci si concentra senz'altro sul migliorare, ma gli si dà la motivazione che
piace: "Migliorare, per dirTi che Ti voglio bene".

         Esso richiede la nostra intelligenza per vedere in cosa migliorare nell'attimo
presente. Domanda la volontà di farlo. E non manca il sentimento d'amore verso Colui, che
vuol esser amato anche con tutto il nostro cuore.

         Provate e mi saprete dire che va bene anche per voi: "Migliorare, per dirTi che Ti
voglio bene".

         Così continuiamo a camminare per quel Santo Viaggio, che non abbiamo
abbandonato da 18 anni. Intanto parecchi di noi sono partiti e, forse anche per esso, con le
valigie non vuote.

         Che il Signore trovi così anche noi quel momento, per il quale preghiamo ogni giorno
la Mamma del Cielo: "Prega per noi... ora e nell'ora della nostra morte".

         Carissimi, domani parto per l'Argentina ed il Brasile. Conto sulla vostra unità. Vi
porto tutti con me ed io sarò con voi attraverso i diarietti.

         Ricordate sempre che ognuno di noi è solo un tassello di quest'Opera e che tutto è di
tutti. Così Dio vede le cose: Egli ha pensato un Suo disegno su ciascuno di noi, tale, però, che
ha senso solo nell'insieme dell'Opera, proprio come un tassello lo ha soltanto nell'insieme
del mosaico.

         Allora, a presto! Io attendo i vostri fax per qualsiasi cosa vorrete comunicarmi.
         Che Gesù sia fra noi, anche da lontano.
         Vi saluterò tutti gli argentini e i brasiliani, con quelli delle nazioni confinanti che
converranno.

         Vi lascio nel cuore di Maria.$doc1828$, 'drive_import', '01828-WEB-1998-02-20-migliorare-per-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1828)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1829, 'ITA', $doc1829$Castel Gandolfo, 26 marzo 1998
Inesistenza

Ancora nel 1986 il teologo Hans Urs von Balthasar, a noi noto soprattutto per il suo
pensiero sul profilo mariano, incontrando gli allora responsabili del nostro Movimento in
Svizzera, dopo esser stato ragguagliato sulla nostra vita, ha detto: "Le esperienze che voi
fate sono molto belle. Ma vorrei sottolinearvi una cosa: rimanete alla prima intuizione (di
Chiara), all'abbandono di Gesù. Se si dimentica ciò, tutto si appiattisce. La centralità della
croce... questa è la cosa più bella...".
Ed è così per noi.

         Si sa, infatti, come chi vive il nostro Ideale fa una scelta: Dio Amore. Ma essa, poi, non
può non precisarsi che nella scelta di Gesù abbandonato, che è la viva dimostrazione
dell'amore di Dio qui in terra.

         E a Lui si consacrano perciò i focolarini vergini e coniugati, quando diventano tali a
tutti gli effetti. Ma a Lui guarda - come abbiamo detto in Piazza San Pietro al Santo Padre -
ed a Lui si consacra anche ogni altra vocazione dell'Opera.

         Questa scelta di Gesù abbandonato, che si vuol privilegiare e vivere anche in
maniera esclusiva, ha effetti straordinari; è la chiave per aprire ogni dialogo, per arrivare a
realizzare ogni unità, per far sì che il Risorto viva sempre in mezzo a noi e in noi.

         E inoltre Egli, essendo anche espressione di tutte le virtù in senso pieno ed eroico,
aiuta pure noi ad abbellire di esse la nostra anima.

         Egli infatti è la più estrema povertà, l'umiltà più abissale, la pazienza senza limiti, la
purezza celeste, la mansuetudine più dolce, costante, vittoriosa e così via.

         Oggi, giacché si dice che la base dell'ascesa alla santità è l'umiltà, contempliamoLo
proprio come modello d'umiltà, d'annientamento.
Egli però è umile in un modo tutto suo, che non ha nulla a che spartire, ad esempio, con
quelle espressioni con le quali si pensa in genere di vivere questa virtù.

         E' umile non perché afferma di aver imperfezioni, debolezze, ecc. La sua è un'umiltà,
per così dire, totale. Egli si è annullato totalmente. Ha vissuto un'inesistenza assoluta di se
stesso.
         Così dobbiamo essere noi se vogliamo essere umili. Dobbiamo imitare la sua
"inesistenza".

         Io, il mio io, non deve essere, non deve esistere. Va annullato. Se deve avere una sua
personalità, è questa: Gesù in me, sul mio nulla.

         E' un'umiltà, un'inesistenza che va vissuta sempre; è base del vero amore, nostra
tipica vocazione, ed effetto di esso.

         Per sant'Ignazio di Loyola l'obbedienza era un'espressione del suo carisma. Usava,
per spiegare il modo di viverla, un paragone un po' macabro, che oggi non si amerebbe
formulare, ma efficace: per obbedire bene - diceva - occorre essere come un cadavere. Lo si
può disporre in una maniera o in un'altra ed è sempre pronto ad adeguarsi.

         Un paragone non bello certamente, ma che non è lontano dal nostro modo, ad
esempio, di pensare l'amare, la pratica dell'amare. Anche noi, per amare bene, dobbiamo
essere "morti" a noi stessi, o meglio: non essere.

         Dobbiamo "non essere" per essere l'altro, Dio, nella sua volontà, o il fratello.
Dobbiamo vivere in pieno la nostra inesistenza.
Essa ci porta, poi, molti vantaggi.

         Non ci possono toccare, ad esempio, i biasimi, i rimproveri, i giudizi, le calunnie... Chi
colpiscono? Il nulla. E', quindi, come non esistessero.

         Così non ci esaltano le lodi, il parlar bene di noi. Chi esaltano? Nessuno. Noi non ci
siamo.

         Perciò, nella vita, non occorrerà difendersi, a meno che non ci siano obblighi di
giustizia o di carità. Né occorrerà aver parole per umiliarci di fronte alle lodi. Noi non ci
siamo.

         In questo mese guardiamo allora a Lui, abbandonato, alla sua inesistenza, per
imitarLo anche noi, seppure nella nostra vita, e, quindi, in altra maniera e con altro
spessore. Imitare quella nudità, quel "nada", quel "nulla" di cui parlano i santi, tanto
attraente perché premessa al pieno, al Regno di Dio in noi.

         E, giacché la nostra spiritualità è tutta positiva, facciamo, di questa nostra
inesistenza, il calice per essere volontà di Dio e vita dell'altro in noi.
         Per essere volontà di Dio... In questo mese puntiamo sull'essere totalmente "volontà
di Dio", nient'altro che volontà di Dio. La tua volontà è la mia, non ne ho altre.

         Viviamo, allora, la volontà di Dio come se la nostra quasi - senza quasi - non ci fosse.
         La volontà di Dio, in genere, è l'adempimento del disegno di Dio sull'umanità.
         La volontà di Dio vissuta da ciascuno di noi, momento per momento, è il ricamare il
disegno di salvezza sulla nostra piccola personale storia sacra.

         Siamo, dunque, d'accordo: volontà di Dio sempre, sull'inesistenza voluta della nostra
volontà.$doc1829$, 'drive_import', '01829-WEB-1998-03-26-inesistenza-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1829)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1830, 'ITA', $doc1830$Palermo, 22 gennaio 1998
Dichiarazione di amore

         Carissimi,

         al Collegamento che proveniva da Palermo ci siamo lasciati col proposito di
"costruirci in preghiera", come dice il teologo Evdokimov, e cioè non solo di possedere la
preghiera, ma di essere preghiera.

         E, da diversi echi, che ho avuto, ho capito quanta sete di unione con Dio c'è nelle
persone del nostro Movimento. E' santità che viene a galla.

         Ringraziamo Dio, veramente, e puntiamo lì ancora.

         Chi ci trasforma in preghiera, chi ci edifica preghiera è lo Spirito Santo. Infatti è Lui
che ricicla (permettete questa parola, che piace, perché è moderna e rende l'idea), è Lui che
ricicla l'amore, che abbiamo dato al prossimo, in amore di Dio.

         Dopo aver amato, come si deve e con perseveranza, il prossimo, ci si trova in cuore,
suscitata in noi da Lui, dallo Spirito Santo, l'unione con Dio, che è la vera preghiera.

         Preghiera, che non va solo costatata da noi, della quale ci rallegriamo e dobbiamo
esserGli immensamente grati, ma che è nostro dovere stimare grandemente, raccogliere,
goderne e alimentare con nuovo amore verso il prossimo, che sia però espressione del
nostro amore per Dio.

         E ciò nel modo che conosciamo: facendo precedere, ad esempio, ad ogni nostro
incontro diretto o indiretto col prossimo (anche, quindi, lavorando per lui singolo o per la
comunità), facendo precedere un "per te".

         "Per te" che può essere espresso anche in modo diverso, di cui ho fatto cenno a
Palermo, dopo di che un focolarino mi ha consigliato di farne oggetto di un Collegamento. Ed
è ciò che faccio.

         A Palermo, inoltre, per rispondere ad una giornalista sorpresa che nel Movimento si
trovi sempre il modo di concentrare comportamenti da tenere, in slogan appassionanti e
vivi, in brevi formule facili da mettere in pratica, ho spiegato l'ultimo con cui, alcuni di noi,
esprimevamo, da qualche tempo, il nostro "per te" e l'ho vista contenta.
         Anziché dire: "Per te", si può anche dire: faccio questo "per dirti che ti voglio bene".
E ciò per affermare: "Ora faccio quello che tu, nel prossimo, mi chiedi, per dichiararti il mio
amore".

         Certo, qualcuno potrebbe obiettare: basta dire: "Perché ti voglio bene". Ma quel "per
dirti che ti voglio bene" piace di più, perché è una dichiarazione di amore. E l'amore ha
bisogno anche di dichiarazioni.

         Le dichiarazioni sono espresse in parole, è vero. A volte con qualche dono o qualche
fiore. Cose che valgono poco, ma che hanno un profondo significato proprio perché
esprimono l'amore.

         Se poi ci rendiamo conto che la nostra dichiarazione è rivolta a Dio, come lo è,
scopriamo con gioia che essa è anche una preghiera. Preghiera pur in mezzo all'attività.
Sublime preghiera, che tanto si addice anche a quelli, fra noi, che debbono condurre una vita
immersa nel mondo e, a volte, tra la folla.

         E non solo. Ma, pregando così, aiutiamo lo Spirito Santo nel compito, che ha, di
accendere nel nostro cuore l'unione con Dio: mettiamo fuoco su fuoco, quel fuoco che è il
nostro amore verticale.

         Viviamo allora in questo prossimo periodo il nostro amore per Dio, facendo
precedere ad ogni incontro con il prossimo, o con i nostri prossimi, in casa, fuori, dovunque
e anche prima di ogni altra attività, che direttamente o indirettamente è rivolta al prossimo
o ai prossimi, la nostra dichiarazione d'amore: "Perché ti voglio bene; per dirti che ti voglio
bene".

         In Cielo Gesù è col suo corpo, glorificato certo, ma col suo corpo. E quel corpo ha un
Cuore. Immaginiamo il sussulto che quel santissimo Cuore avrà ogni qual volta noi diciamo:
"Per dirti che ti voglio bene".$doc1830$, 'drive_import', '01830-WEB-1998-01-22-dichiarazione-di-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1830)
on conflict (document_id, language) do nothing;
