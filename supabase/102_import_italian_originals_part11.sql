-- 102_import_italian_originals_part11.sql (11/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1758-1777 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1758, 'ITA', $doc1758$Rocca di Papa, 25 aprile 1996

"Solo con Lui solo".

Come primo passo: l'amore a Gesù nel fratello.

Carissimi,

         l'ultimo Collegamento intitolato: "Solo con Lui solo", che ci invitava ad amare Gesù
dentro di noi, come pure Gesù fuori di noi, in ogni fratello, ed aver così la possibilità di
trattare nella vita solamente con Gesù, è piaciuto assai nel Movimento ed ha portato
abbondanti frutti.

         Si osserva, per esempio, che così facendo si fa tutto bene e senza fretta; che alla sera
si trova una certa unione con Dio; che quando ci si accinge ad intraprendere un lavoro più
impegnativo, che potrebbe magari preoccupare, come incontrare tante, tante persone, si
pensa: "Non cambia niente: è sempre Gesù che amerò"; che la nostra è una vita attiva e
contemplativa insieme; che ogni opera, fatta in questo spirito, porta frutto.

         Per queste esperienze si desidererebbe continuare a vivere il Collegamento
precedente anche nel prossimo futuro.

         Ho pensato allora che, nel mese di giugno, si potrebbe sempre tener presente il "Solo
con Dio Solo", vedendo però di approfondirlo, di capirlo meglio e di attuarlo con maggiore
proprietà.

         Allo scopo mi sembra utile uno scritterello che ho letto in questi giorni, steso in
tempi particolarmente felici per il nostro carisma, in cui, mi sembra, la sapienza
abbondasse.

         Esso dice:

         "Noi abbiamo una vita intima e una vita esterna. L'una dell'altra una fioritura; l'una
dell'altra radice; l'una dell'altra chioma dell'albero della nostra vita.

         La vita intima è alimentata dalla vita esterna. Di quanto penetro nell'anima del
fratello, di tanto penetro in Dio dentro di me; di quanto penetro in Dio dentro di me, di tanto
penetro nel fratello.

         Dio-io-il fratello: è tutto un mondo, tutto un regno..."

         Ma andiamo per ordine, cercando di capire bene.

         "Noi - dice - abbiamo una vita intima (Gesù dentro di noi) e una esterna (Gesù nel
fratello). L'una dell'altra una fioritura, l'una dell'altra radice."
         La vita intima, si afferma, produce una fioritura nella vita esterna.

         La vita esterna (con Gesù nel fratello) provoca una fioritura nella vita intima.

         Ma in che modo si può pensare la vita intima con Gesù come una fioritura, come una
chioma?

         Non è la vita interiore unione con Dio, punto e basta?

         Lo è, ma c'è unione e unione. E questo tutti noi lo sappiamo, perché ognuno ha e
sperimenta, poco o tanto, la sua particolare unione con Dio.

         Ma quando poter definire questa vita intima come fioritura o chioma, quindi come
alcunché di ricco e compatto?

         Quand'essa è nel suo completo sviluppo, nel suo massimo splendore.

         Facciamo qualche esempio.

         Se si osservano le persone del Movimento, specie alcune già presenti in Cielo, o altre
tuttora militanti in terra, ma che, a nostro avviso, hanno corrisposto bene alla grazia del
nostro Ideale, si può costatare come esse definiscano spesso la loro vita intima come una
grande pace, una pace sostanziosa, una pace così concreta, così densa, che si potrebbe -
permettete la parola - tagliare.

         Una pace stabile e tale da dominare su tutto, da emergere sopra ogni dolore, per
quanto acuto e diffuso esso sia.

         Era così, ad esempio, la pace di Corim che, nonostante sofferenze lancinanti in tutto
il corpo, affermava: "Sì, soffro dovunque, ma ho la pace".

         Una pace, poi, diffusiva e contagiosa. Corim distribuiva continuamente pace alle
persone, che, specie negli ultimi tempi, dopo averlo visitato, affermavano: "Sono uscito dalla
sua camera con la pace nel cuore".

         Ma, non solo pace. La fioritura completa, la chioma dell'albero della nostra vita
interiore ha altri particolari. Per esempio: l'unione con Dio è tale da poterla avvertire in ogni
istante della nostra vita. Quando si va in fondo al cuore, in cerca di Dio (nella preghiera o
durante la giornata) Egli, Gesù, è sempre lì e Lo si avverte coi sensi dell'anima. E' lì, che ci
attende, per ascoltare quanto Gli diciamo e per dirci (se sappiamo afferrare il suo linguaggio
silenzioso) quanto Egli vuole comunicarci. E' un fenomeno questa perenne presenza di Gesù
dentro di noi, ma può essere una realtà; come è reale ormai, anche se diversa, la nostra
unione con il Padre, con lo Spirito Santo e, non più velata, quella con Maria, i Santi, e i
fratelli.

         Pace, dunque, e continua piena unione con Dio, due modi di essere della fioritura,
della chioma della nostra vita interiore. Anche se non i soli frutti.
         E come si possono raggiungere?

         Dice lo scritto: la vita intima in noi fiorisce, si fa chioma su una radice: l'amore al
fratello, a Gesù nei fratelli.

         "La vita intima è alimentata dalla vita esterna. Di quanto penetro nel fratello, di
tanto penetro in Dio".

         Si può arrivare, dunque, a tanta pace, a tanta unione con Dio, amando i fratelli, Gesù
nei fratelli.

         Per quante volte? Molte, molte volte. Forse occorre tutta la vita.

         Ma anche il tutto viceversa: l'unione con Dio è radice per la fioritura, la chioma della
nostra vita esterna. Del nostro amore ai fratelli.

         E come e perché lo vedremo la prossima volta.

         Nel mese entrante pensiamo di aumentare, di perfezionare il nostro amore a Gesù
nel fratello, per vedere o subito o col tempo, fiorire la pace densa dentro di noi e avvertire
l'unione con Dio, sempre più frequentemente, nel nostro cuore.$doc1758$, 'drive_import', '01758-WEB-1996-04-25-solo-con-lui-solo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1758)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1759, 'ITA', $doc1759$Rocca di Papa, 23 maggio 1996
Secondo passo: lo sviluppo della chioma esterna

Carissime,

         abbiamo cercato l'altra volta di rendere più piena la nostra unione con Dio,
sforzandoci di amare Gesù nel fratello, nei fratelli.

         Abbiamo visto, infatti, che l'amore ai fratelli (la nostra vita esterna) è causa della
fioritura della nostra unione con Dio, che si manifesta in modo particolare in una speciale
pace e in una presenza di Dio nel nostro cuore anche costante, oltre che con doni particolari
conosciuti da chi cammina avanti nella via di Dio.

         Oggi vediamo come mai l'amore a Dio, a Gesù dentro di noi, è radice per una
fioritura esterna.

         Vediamo come, se noi viviamo intensamente la nostra vita interiore, accumulando
pace con l'amore a Gesù Abbandonato e a Maria Desolata e rendiamo sempre più viva e
costante la nostra unione con Dio, fiorirà il mondo attorno a noi.

         E' ovvio che, più si ha l'unione con Lui, più Egli ci comunica la sua vita, che è carità, e
meglio possiamo compiere quell'operazione del farsi uno con gli altri, dell'entrare negli
altri, che è sinonimo di amare gli altri.

         E si sa come, dal nostro "farci uno" con gli altri, dipende la conquista di quei cuori a
Gesù o la loro adesione sempre più profonda a Lui.

         Ma c'è "farsi uno" e "farsi uno".
         Nel farsi uno, occorre essere totalmente e per tutto il tempo staccati da sé.
         C'è infatti - noi lo sappiamo - chi, per attaccamento a sé o a qualcos'altro, non ascolta
fino in fondo il fratello, non muore tutto nel fratello e vuol dare risposte raccolte via via
nella propria testa, che non sono quelle suggerite dallo Spirito Santo che può dare la vita o
incrementarla nel fratello.
         Vi è invece chi, amante appassionato di Gesù Abbandonato, ascolta il fratello fino in
fondo, non preoccupandosi della risposta, che gli darà alla fine e sintetizzerà in brevi parole,
o in una, tutto quanto serve a quell'anima.

         A chi si fa uno perfettamente, Gesù dà al suo dire un'autenticità straordinaria, un
parlare essenziale, senza cose superflue, senza fronzoli, che entra nel cuore del fratello
come una spada, che "brucia (veramente) ciò che ha da cadere e lascia in piedi solo la
verità." E il fratello può crescere in quella, nella verità, che è sinonimo di crescere in Gesù.

         Ma si può avere non solo contatto con singole persone, ma anche con gruppi o
grandi assemblee.

         Come poter influire positivamente su questi per vederli rifiorire?

         Mediante una sempre più perfezionata unione con Dio, con un ascolto sempre più
attento dello Spirito in noi.

         Occorrerà anzitutto prepararsi bene, implorando il dono dello Spirito assieme ai
fratelli con un "consenserint" al Padre in nome di Gesù, in cui concorrano non solo Maria,
ma i nostri mariapoliti celesti e i nostri santi protettori.

         Poi bisognerà stendere - sempre in ascolto dello Spirito, che ci ricorderà anche
molte idee, verità già acquisite ma utili allo scopo - la scaletta del piccolo o lungo discorso
che dobbiamo fare.

         Infine dovremo offrirlo ai fratelli come dono d'amore, non senza esserci prima
assicurati che l'assemblea è già lievitata dalla presenza di Gesù in mezzo, perché "a chi ha
sarà dato": a chi ha Gesù sarà data una maggior presenza e conoscenza di Lui.

         Gli effetti allora saranno vari.

         Ci sarà chi toccherà solo superficialmente le persone, producendo però almeno un
certo interesse.

         Chi, invece, con le sue parole toccherà più profondamente i presenti, illuminandoli,
sì da portarli a sentimenti, e a propositi di bene.

         Chi saprà offrire, infine, un discorso così pieno di Spirito da trasformare le persone
con profonde conversioni verso Dio, con desideri anche di svuotare la piena del proprio
cuore in chi rappresenta Gesù, per poter cominciare una vita nuova.

         Così si fa chioma (più o meno sviluppata) l'albero della nostra vita esterna, perché è
posta sulla radice della nostra unione con Dio, con il suo Spirito.
         Che fare allora in questo prossimo mese?
         Migliorare ogni giorno di più la nostra vita interiore, vivendo con Gesù dentro di noi,
perfezionando le nostre preghiere e attuando con radicalità il nostro: "Sei tu, Gesù
Abbandonato, con Maria Desolata, l'unico mio bene".
         Poi curare il nostro approccio con i singoli e con i gruppi come ho detto sopra.

         Il Regno di Dio così avanzerà, l'unità progredirà, e ciò a seconda della nostra
corrispondenza. Ma il Signore ci conceda che essa sia piena.

         Si tratta della gloria di Dio e della nostra partecipazione ad essa, qui - come è
possibile - e certamente nell'altra Vita.$doc1759$, 'drive_import', '01759-WEB-1996-05-23-secondo-passo-lo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1759)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1760, 'ITA', $doc1760$Rocca di Papa, 27 giugno 1996
La luna che cresce

Carissimi,

         ed eccoci al Collegamento di agosto, semplice ma impegnativo, che varrà soprattutto
per settembre, quando a Rocca saranno radunati tutti i responsabili di zona del mondo.

         Penso che tutti voi, che ascoltate questo pensiero, vivete più o meno il "Sei Tu,
Signore, l'unico mio bene" rivolto a Gesù crocefisso e abbandonato, e concludete con: "con
Maria Desolata".

         E' questa la base della nostra vita spirituale per poter compiere con frutto il nostro
santo viaggio quotidiano. Ci rende in qualche modo, infatti, degni di seguire Gesù. Egli vuole
che si ami la croce ("prenda la sua croce") e che ci si distacchi da tutto ("rinneghi se stesso").
"Chi vuol venire dietro a Me..." conosciamo le Sue esigenze.

         Pur tuttavia con ciò non è tutto fatto. L'abbiamo sottolineato altre volte.
         Non basta seguire Gesù. Occorre vedere dove Egli ci vuol portare.
         Il Suo intento è porci nella Sua via, che è la via dell'amore.
         Amare, dunque, amare soprannaturalmente: amar Dio nella Sua volontà ed amar il
prossimo con i quattro modi che conosciamo: vedere Gesù in tutti, amare tutti, amare per
primi e farsi uno.
         Amare, che deve essere sempre migliorato per essere autentico e gradito a Dio: "Chi
non va avanti, va indietro".

         In queste ultime settimane ho avuto fra le mani un libretto, che mi è stato fatto
gentilmente pervenire. E' assai bello. Può servire anche per meditazione.

         Esso riporta tanti detti sull'amore vero, trovati nella Sacra Scrittura, nei Santi, ma
anche in pensatori cristiani o meno, persino in lontani.

         Parlando dell'amore esso conferma, se ce ne fosse bisogno, l'importanza assoluta di
questo atteggiamento e raccomanda anch'esso di migliorare.
         Essendomi questi detti assai piaciuti, vorrei farvi partecipi almeno di qualcuno.

         E' di san Gregorio Magno questo: "Possiamo progredire maggiormente nell'amore di
Dio, se prima, nel grembo del suo amore, veniamo allattati con l'amore del prossimo."

         Afferma Fritz Usinger, lirico e saggista tedesco (1895 1982): "Chi dona amore si
arricchisce di ciò che dà. Quanto più dona, tanto più si arricchisce."

         Aggiunge Ricarda Huch, scrittrice tedesca a cavallo tra il XIX e XX secolo (1864-
1947): "L'amore è l'unica cosa che cresce quando lo distribuiamo a piene mani."

         Michail J. Lermontov, scrittore russo del 1800 (1814-1841), dice: "L'amore è come il
fuoco: senz'alimento si spegne."

         E sant'Agostino: "Nella misura in cui l'amore cresce in te, cresce anche la tua
bellezza, poiché l'amore è la bellezza dell'anima."

         Per quanto riguarda la necessità di migliorare sempre, ecco cosa afferma Fulton J.
Sheen, il famoso vescovo e scrittore americano (1895-1979): "Nel regno dell'amore non ci
sono pianure: o si sale o si scende."

         E il Visconte de Ségur, scrittore francese del XIX secolo: "L'amore è come la luna: se
non cresce, cala."

         E crescere sempre si può perché san Tommaso afferma: "La carità non conosce
limite di crescita, essendo essa una partecipazione dell'infinita carità, che è lo Spirito Santo."

         Che dobbiamo amare lo sappiamo. Insistiamo questo mese prossimo, perciò, sul
crescere. M'è piaciuta la conclusione d'una letterina indirizzatami da una focolarina: "nella
luna crescente, tua..."

         Anche noi tutti, allora: "nella luna crescente" e "nel Regno dell'amore senza pianure
ove o si sale o si scende."

         Chiediamoci ogni tanto durante la giornata: Ho migliorato nell'amore verso Dio e
verso i fratelli?

         Lo si potrà fare verso Dio nelle pratiche di pietà quotidiane o nell'adempimento dei
nostri doveri compiuti sempre meglio, sempre meglio. Verso i fratelli ogni qualvolta li
incontriamo.

         Per parte mia ho provato: occorre maggior attenzione alla nostra vita spirituale. Ma
occorre averla, pena il calare e il discendere. Il migliorare deve diventare per noi
un'abitudine. E' necessario.
Coraggio, allora.
Che la fine di settembre ci trovi molto migliorati.$doc1760$, 'drive_import', '01760-WEB-1996-06-27-la-luna-che-cresce-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1760)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1761, 'ITA', $doc1761$Sierre, 22 agosto 1996
Unità

Carissime,

         si sono conclusi gli Esercizi Spirituali e l'Assemblea che doveva seguirli. Sono iniziati
gli incontri con le singole zone del mondo. E tutto nella pienezza della gioia e in una
gratitudine immensa verso Dio, verso lo Spirito Santo che ci ha avvolti.

         E' iniziato, dunque, il nuovo Anno ideale 1996-97 e, come tutti gli anni, è stato
offerto, ai 380 presenti all'Assemblea, il nuovo tema dell'anno. Questa volta esso esamina gli
ultimi sei cardini della nostra spiritualità, evidenziandovi il "di più", che pure essi
contengono.

         Questo tema sarà oggetto di meditazione durante tutti i corsi cui parteciperete, ma
anche quest'anno, come in quello passato, si approfondirà un punto per ogni Collegamento.

         Il primo del nuovo tema è, appunto, l'unità.
         Come tutti potete capire qui, in questo cardine, tipico nostro, è implicito il "di più" di
ciò che è richiesto, in genere, nelle spiritualità individuali, almeno lungo il loro decorso. Quel
"di più" che è, come sappiamo, reciprocità e unità.

         L'unità. Ma che cos'è l'unità? Si può attuare l'unità?
         L'unità è ciò che Dio vuole da noi.
         L'unità è realizzare la preghiera di Gesù: "Padre che siano uno come io e te. Io in essi
e tu in me affinché siano uno" (cf Gv 17,21).

         Ma l'unità non si può attuare con le sole nostre forze. Può realizzarla solo una grazia
particolare, che scende dal Padre, se trova una particolare disposizione in noi, un requisito
preciso e necessario.

         Esso è l'amore reciproco, comandato da Gesù, messo in atto.
         Il suo amore reciproco, quello che Lui vuole, che non è - lo sappiamo - semplice
amicizia spirituale o accordo o buona intesa.
         E' l'amarsi l'un l'altro come Lui ci ha amato. E cioè fino all'abbandono: fino al
distacco completo dalle cose e creature, materiali e spirituali per poterci far uno l'un l'altro
vicendevolmente e perfettamente.

         In tale maniera si fa la parte nostra e si è nelle condizioni per ricevere la grazia
dell'unità, che non mancherà, che non può mancare.

         Quale riconoscenza deve nascere a tale pensiero in noi, chiamati a ciò; quale spinta a
vivere in modo da ottenere questo dono che là, dove così non si vive, non c'è.

         Occorre ricordarsi che, nella nostra spiritualità comunitaria, c'è una grazia in più;
che il Cielo può aprirsi ogni momento per noi; e noi, se facciamo quanto Esso chiede, invasi
da questa grazia, possiamo operare molto, molto per il Regno di Dio.

         E' questa grazia certamente che spiega la grande espansione del nostro Movimento
e tante belle conquiste ad esso collegate.

         Conscie di questo straordinario privilegio, ecco perché così ci si esprimeva i primi
tempi:

         "Fissatevi in testa una sola idea. Fu sempre una sola idea a far i grandi santi.
         "E la nostra idea è questa: Unità."

         "Tutto cada. L'unità mai! Portate fra voi sempre questo fuoco acceso. E non temete
di morire. Già l'avete sperimentato che l'unità esige la morte di tutti per dar vita all'Uno.
Fate questo come sacrosanto dovere, anche se vi porterà immensa gioia! L'ha promessa
Gesù la pienezza del gaudio a chi vive l'unità."

         E durante il prossimo mese sforziamoci per procurarci sempre questo dono!
         E non attendiamolo solo per la nostra felicità, ma per essere abilitati alla nostra
tipica evangelizzazione. La conoscete: "Siano uno affinché il mondo creda" (cf Gv 17,21).
         C'è tanto bisogno nel mondo di fede, di credere! E tutti siamo chiamati a
evangelizzare.
         Un giorno Francesco disse ai suoi discepoli: "Facciamo la predica." E infilate le mani
nelle maniche e abbassati gli occhi, camminarono per la città, predicando, con il loro essere,
la mortificazione e la povertà del tutto.

         Lanciamo anche noi nel mondo la nostra predica. Che chiunque osservi due o più di
noi uniti (in focolare, nei nuclei, nelle unità, nei nostri incontri, o perché casualmente
insieme), sia colpito da un raggio della nostra fede e creda: creda all'amore, perché l'ha
visto.

         Mettiamoci sotto. Questo vuole il Signore da noi. Lo vuole attraverso il nostro
carisma inciso nei nostri statuti: l'unità è la premessa di ogni altra volontà di Dio.

         Poi possiamo anche parlare per irradiare il Vangelo. Ma dopo.$doc1761$, 'drive_import', '01761-WEB-1996-08-22-unit-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1761)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1762, 'ITA', $doc1762$Rocca di Papa, 26 settembre 1996
La Festa

Carissimi,

         la maggior parte di noi, che ascoltiamo questo Collegamento, pur non volendo
"essere del mondo", è immersa però nel mondo.

         E sappiamo quello che vi possiamo trovare. Fra aspirazioni a valori autentici, che
non si possono negare, vediamo che si aspira, in genere, unicamente a qualcosa che soddisfi,
che dia gioia.

         Si vuole non di rado la felicità anche a tutti i costi, anche a tutti i prezzi.
         Nessuno certamente desidera il dolore. Se viene, lo si accetta ma per forza e, chi ha
fede, vi vede forse la volontà di Dio cui rassegnarsi.
         E' la gioia che si cerca. Per cui certuni, spesso senza scrupoli, conoscendo questa
insopprimibile esigenza dell'uomo, forniscono e imbandiscono mense le più varie per
appagarla.
         Purtroppo però, mescolati a cose indifferenti e anche buone, vi sono ingredienti
cattivi, malefici, a volte persino scandalosi e sozzi. La televisione, i rotocalchi, la moda non
ne sono immuni.
         E gli uomini spesso bevono tutto quanto vien loro offerto e si accorgono poi che,
cercando la felicità, alla fine, delusi, non la trovano.
         Tuttavia questa esigenza di gioia non va vista male, perché l'ha messa Dio nel cuore
umano, Dio che è somma beatitudine.

         Anche noi, nel Movimento, con lo spirito che abbiamo, affermiamo di voler dare la
felicità ai cuori umani e di voler far "sorridere il mondo".

         E spesso ci riusciamo: è testimonianza generale; ma quale il nostro tipico modo?
         Amando il fratello, facendo in modo che si senta amato, lo solleviamo dai pesi che lo
opprimono, apriamo di fronte a lui orizzonti più ampi e luminosi.

         Ma non basta amare, attuando le opere di misericordia.
         Occorre di più.

         La volta scorsa, nel Collegamento, abbiamo parlato dell'unità e abbiamo affermato
che possiamo viverla solo se ci disponiamo a riceverne la grazia praticando l'amore
reciproco. Allora: ciack, l'unità è fatta.

         Questa volta vorrei che guardassimo dentro questa grazia, che la analizzassimo un
po'.

         Che cos'è, chi è?

         Lo sappiamo. Non è certamente un semplice punto della nostra spiritualità. Essa
porta fra noi addirittura una persona, una persona che è Dio stesso. L'unità è Gesù fra noi.

         L'unità - dice un Padre della Chiesa - è quell'"accordo" di pensieri e di sentimenti, fra
più persone, così da giungere alla concordia che "unisce e contiene il Figlio di Dio".

         E questa presenza - noi lo possiamo testimoniare - è sorgente di una profonda
felicità: Gesù fra noi è pienezza di gioia, fa della nostra vita e di tutti coloro che vivono
l'unità una continua festa.

         Perché questo?

         Lo spiega un altro Padre parlando della Pentecoste, dopo la quale gli apostoli erano
talmente pieni, traboccanti di grazia, di luce, di gioia da apparire ebbri.

         Dice questo Padre:

         "Sebbene la Pentecoste sia trascorsa, la festa tuttavia non è passata; ogni riunione
infatti è una festa. Da dove risulta ciò? Dalle stesse parole di Cristo che dice: 'Dovunque sono
due o tre riuniti nel mio nome, io sono in mezzo a loro'. Dunque, - continua il Padre - ogni
volta che Cristo è presente in mezzo a una riunione, quale prova maggiore vuoi che allora è
festa?"

         Ed è questa la festa vera che il cuore dell'uomo cerca.

         Noi siamo chiamati a suscitare la festa in mezzo al mondo, a farlo palpitare della
gioia che dà pienezza.

         E lo possiamo fare nelle nostre piccole o meno piccole comunità, nei nostri convegni,
nei nostri centri e nelle nostre città.

         E lo dobbiamo fare e insegnare, perché, agire in modo che Gesù e la sua gioia siano
fra noi, non è che vivere la Chiesa.
         Vivere con Gesù in mezzo non è infatti una pratichetta che soltanto i membri del
Movimento devono attuare. Vivendo con Gesù in mezzo ci si inserisce più vitalmente nella
presenza di Gesù nella sua Chiesa.

         I Padri infatti, per spiegare la presenza di Dio nella Chiesa, si basano su due frasi:
"Dove sono due o tre riuniti nel mio nome, io sono in mezzo a loro" (Mt 18,20) e poi "Io sono
con tutti voi tutti i giorni, fino alla fine del mondo" (Mt 28,20).

         "Cristofori" sia il nostro secondo nome in questo prossimo mese di novembre,
portatori di Cristo in mezzo al mondo, per farlo non solo sorridere, ma per accendervi una
perenne festa.

         E per sapere da dove cominciare, eccovi un consiglio, frutto di un'esperienza che ho
fatto: amiamo tutti per primi cominciando da adesso e insegniamo a tutti a far così. Il
ritorno è facilitato e qualche volta - almeno fra noi - automatico. E Gesù è in mezzo e, con
Lui, la festa.$doc1762$, 'drive_import', '01762-WEB-1996-09-26-la-festa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1762)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1763, 'ITA', $doc1763$Rocca di Papa, 24 ottobre 1996
Rivolti verso il Padre

Carissime,

         eccoci nuovamente a Rocca di Papa dopo il fruttuoso viaggio per le zone della Gran
Bretagna e dell'Irlanda, di cui avrete certamente avuto qualche aggiornamento o almeno
qualche eco. Grazie, grazie di cuore per la preghiera di molti e le offerte di sofferenze e,
persino di morti, di qualcuno. Gesù e Maria penseranno a ricompensare.

         Oggi vorrei fare con voi, nel seguente pensiero, una considerazione.

         Noi, come ci viene confermato anche dalla nostra spiritualità, nel secondo suo punto,
dobbiamo fare la volontà di Dio per poter dire che amiamo Dio, che contraccambiamo il suo
essere Amore nei nostri confronti con il nostro.

         Ora - qualcuno potrà domandarsi - il fare, nella vita, unicamente la volontà di un
altro, sia pure Dio; il compiere, durante la nostra esistenza, il disegno che un altro, sia pure
Dio, ha su di noi, non ci porta forse ad adombrare, a non sviluppare la nostra personalità, a
privarci della nostra libertà?

         Ci si convince che non è assolutamente così, ma che è proprio l'esatto contrario, se
pensiamo almeno un po' a chi siamo noi, a quale è la nostra realtà.

         Noi siamo e siamo stati presenti nella mente di Dio, nel Suo Verbo, da sempre.
         Noi siamo in Dio una parola che Egli ha pensato fin dall'eternità. Questa parola è il
nostro vero io. A un dato momento, il Padre ci ha creati e siamo apparsi su questa terra.
         Ora, come il destino della Parola per eccellenza di Dio, del Verbo del Padre, è quello
di essere sempre rivolto verso il Padre [dice il Prologo del Vangelo di san Giovanni: il Figlio
unico è rivolto verso il seno del Padre (Gv 1, 18)], così dobbiamo essere anche noi.
         L'essere di Gesù, il suo essere, ha senso solo in quanto generato dal Padre e tutto il
suo è quanto il Padre gli ha dato. Per questo compie ciò che il Padre vuole perché è la sua
realtà: è con ciò Verbo del Padre e, allo stesso tempo, è se stesso. Gesù non fa che la volontà
del Padre anche se, essendo uomo può a volte costargli, come ad esempio nella sua agonia
nell'orto degli ulivi, ma la fa.

         Così anche noi dobbiamo fare la volontà del Padre. Ed è proprio nel vivere ciò che
Egli ha pensato e pensa di noi che sta lo sviluppo della nostra personalità. Ecco perché -
come esige il nostro Ideale - dobbiamo compiere nella vita il disegno che Dio ha su di noi,
disegno che è la nostra stessa vita ed è anche la nostra libertà perché ci rende liberi di
essere veramente noi stessi.

         E allora rimaniamo sempre rivolti verso il Padre, verso la Sua volontà.

         "Attieniti con pazienza alla volontà divina - dice Taulero -. E' cento volte meglio degli
slanci di una virtù brillante".

         Sì, perché aggiunge Caterina da Genova, ed è pensiero anche di Teresa d'Avila, "Più
l'uomo si conforma alla volontà di Dio, più si avvicina alla perfezione".

         Per noi - lo sappiamo - la volontà di Dio è uno splendido raggio a sette colori od un
diamante a sette facce luminose. Lo si deve vivere poggiandolo su una imprescindibile
premessa: l'amore reciproco prima di tutto, l'unità fra noi.

         Poi esso ci chiama ad adempiere con perfezione il nostro lavoro quotidiano, a
lanciarci con zelo e ardore nell'irradiazione del nostro Ideale, ad approfondire con le
pratiche di pietà la nostra unione con Dio; a curare con amore anche la nostra vita fisica, a
mettere la dovuta attenzione alla casa; a dedicarci con passione al nostro studio e a quelle
attività che permettono di rimanere in contatto specie con chi ci è particolarmente affidato.

         E' bello, a proposito di tutto quanto si deve fare, ciò che dice Suor Magdeleine,
fondatrice delle Piccole Sorelle di Foucauld:

         "Ogni mattina Dio ci offre una giornata, che ha preparato per noi: non c'è niente di
troppo e niente che 'non sia abbastanza', niente di indifferente e niente di inutile".

         Tutto, allora, è sommamente importante.

         E allora il prossimo mese ricordiamo: rivolti verso il Padre sempre, ogni momento;
rivolti verso la sua volontà.$doc1763$, 'drive_import', '01763-WEB-1996-10-24-rivolti-verso-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1763)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1764, 'ITA', $doc1764$Rocca di Papa, 28 novembre 1996
Quando essere rivolti al Padre?

Carissimi,

         nell'ultimo Collegamento abbiamo compreso come ognuno di noi è una Parola di Dio
fin dall'eternità. Dice, infatti, san Paolo: "In Cristo, il Padre ci ha scelti prima della creazione
del mondo...". Ed in altro luogo parlando sempre di noi, aggiunge: "Quelli che Egli (Dio) da
sempre ha conosciuto...".

         Ed abbiamo capito come noi, essendo Parola di Dio, dobbiamo tenere un unico
atteggiamento, il più intelligente: essere sempre, come la Parola per eccellenza, il Verbo,
"rivolti" verso il Padre, che significa verso la Sua volontà.

         E' così che, fra il resto, possiamo realizzare la nostra personalità; ed è così che
acquistiamo la nostra piena libertà. Lasciamo vivere in tal modo, infatti, il nostro vero io.

         Ora, volendo attuare bene tutto ciò, possiamo domandarci: quando occorre
prendere questo atteggiamento?

         La risposta la conoscete: ora, adesso, nel momento presente. E' nel presente che va
vissuta la volontà di Dio.

         E' nel presente che dobbiamo vivere rivolti verso il Padre. In quel presente, che è un
aspetto essenziale della nostra spiritualità, della nostra "ascetica". Non si può infatti
prescindere da esso.

         Questo modo di vivere è prettamente evangelico.
         L'evangelista Matteo riporta queste parole di Gesù: "Non affannatevi, dunque, per il
domani, perché il domani avrà le sue inquietudini. A ciascun giorno basta la sua pena".
         Ma vivere il presente è sottolineato non solo da santi, ma anche da pensatori.

         Ho trovato questo pensiero di Pascal: "Non ci atteniamo mai al presente.
Anticipiamo l'avvenire come troppo lento a giungere, quasi per affrettare il suo corso;
oppure ricordiamo il passato per fermarlo come troppo fugace; siamo così imprudenti che
vaghiamo nei tempi che non sono nostri e non pensiamo al solo che realmente ci
appartiene".

         Rimettiamoci, allora, nell'impegno di vivere il presente, la volontà di Dio, in più
attimi possibile.

         Con questo atteggiamento esplicheremo anche un dovere che il nostro Collegamento
richiama di tempo in tempo: quello di migliorarci decisamente ogni giorno. Lo sappiamo che
chi non avanza va indietro. "Nella vita spirituale - ammonisce san Giovanni della Croce - non
progredire significa arretrare...".

         E persone come noi, che vogliono tendere alla perfezione, facendo della vita un
santo viaggio, devono assolutamente impegnarsi nello sforzo di far ogni giorno meglio.

         E' anche mia esperienza personale che si migliora veramente quando ci si impegna a
vivere il presente. Per questo lo consiglio caldamente anche a tutti voi.

         E' più facile per esso rimetterci in linea (perché è subito attuato) e ci sono più
occasioni durante la giornata.

         Ricordiamoci poi che, per noi membri del Movimento dei Focolari, la volontà di Dio
che va attuata prima di ogni altra ed in ogni attimo della nostra giornata, è quella dell'amore
reciproco, così come Gesù ci ha amati.

         E' con essa che è assicurato il nostro costante rinnovamento.

         Buon Natale a tutti! Sia il migliore della nostra vita! Gesù nasca e rinasca fra noi e fra
molti, perché il mondo sia più uno e in pace.

         Vi porto con me, con noi che partiamo per l'Asia. Sarete informati in tutti i modi
possibili, mentre resto con voi in ogni punto della terra.

         Ciao a tutti.$doc1764$, 'drive_import', '01764-WEB-1996-11-28-quando-essere-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1764)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1765, 'ITA', $doc1765$Rocca di Papa, 21 dicembre 1996
1997
Noi e l'Eucaristia

Carissime,

         nel III° tema sulla spiritualità collettiva abbiamo approfondito alcuni cardini, gli
ultimi sei, che dovevamo meglio assimilare quest'anno.

         Uno di essi, anzi il primo, è l'unità.
         Abbiamo evidenziato il "di più" nei primi sei punti; qui, nell'unità, è evidente: per far
l'unità, infatti, occorre essere almeno in due.
         Ma non è solo questa la considerazione che abbiamo fatto, rimeditando questo
punto particolare.
         Abbiamo sottolineato anche che l'unità può essere attuata sul comandamento nuovo
vissuto integralmente, e mediante una grazia particolare che viene dal Cielo. Grazia
implorata per tutti noi da Gesù nella sua preghiera: "Padre, che tutti siano uno...".
         Grazia che non è possibile a noi ottenere con i soli nostri sforzi.

         Ma, se è così, come essere certi di vivere l'unità? Questa grazia scenderà sempre
certamente?

         Intanto possiamo affermare che l'unità tutti noi l'abbiamo sperimentata e più volte.
         E' quel qualcosa di divino, di impalpabile, di sublime che conosciamo ed ha infuso
pace, gioia, luce, sicurezza, ardore alla nostra anima; che ci ha convinto che, con l'aiuto di
Dio, molto possiamo, nonostante noi; che ci ha spalancato orizzonti immensi.
         Ma come ci è stato possibile vivere quest'unità, goderne? Quando è arrivata la grazia
che sanziona l'unità? e come è arrivata? Quale ne è stata la causa? Quale il segreto?
         Abbiamo potuto sperimentare questa grazia e lo possiamo ancora fare perché Gesù
viene ogni giorno, o spesso, nel nostro cuore nel sacramento dell'Eucaristia.
         E' l'Eucaristia che arriva a noi carica del dono dell'unità. E, se noi ci predisponiamo
ad accoglierla con il reciproco, autentico amore insegnatoci da Gesù, essa non manca di
offrire a tutti noi il suo dono. Esso è appunto l'unità.
         L'Eucaristia, infatti, produce diversi effetti come, ad esempio, nutrire la nostra
anima come un cibo.

         Dice san Tommaso:
         "... questo sacramento viene dato... sotto forma di cibo e di bevanda. Perciò ogni
effetto che viene prodotto dal cibo e dalla bevanda materiale per quanto (riguarda) la vita
corporale, e cioè sostentare, far crescere, rigenerare e dilettare, tutto ciò viene operato da
questo sacramento nella vita spirituale".

         Ma non è solo cibo l'Eucaristia; essa trasforma il cristiano. Dice la Lumen Gentium:
         "La partecipazione al corpo e al sangue di Cristo altro non fa, se non che ci mutiamo
in ciò che prendiamo" e cioè in Gesù. Diventiamo Gesù.
         Perciò affermano i Padri:
         "... in figura di pane ti è dato il corpo e in figura di vino ti è dato il sangue, per
diventare, avendo partecipato del corpo e del sangue di Cristo, concorporeo e consanguineo
di lui".
         E si può parlare di concorporei e consanguinei non perché avvenga un'unione fisica,
ma per l'unione delle nostre persone col corpo glorificato di Cristo - presente nell'Eucaristia
-, vivificato dallo Spirito Santo. Siamo dunque concorporei, realmente, ma in un senso
nuovo, mistico.
         Ma i Padri specificano ulteriormente:
         "(L'Eucaristia) è detta comunione e lo è veramente, perché per essa noi
comunichiamo al Cristo... e poi perché per essa comunichiamo e ci uniamo gli uni con gli
altri...".
         "Per il fatto stesso che (Cristo) unisce tutti a sé, li unisce vicendevolmente; perché,
se più cose sono unite ad una terza, sono unite anche fra di loro".

         L'Eucaristia, dunque, è vincolo d'unità. L'Eucaristia è fonte dell'unità.
         L'Eucaristia è la divina possibilità di essere uno con Cristo e fra di noi.
         Ci è presente ciò sufficientemente?
         Credo che, se non lo abbiamo pensato con la testa, lo abbiamo capito col cuore.
         Non per nulla non vogliamo perdere mai l'Eucaristia.
         Anche se circostanze serie ci hanno impedito, forse una o due volte, di assistere alla
Messa, almeno la S. Comunione abbiamo sempre cercato di farla. Perché così siamo fatti.
Così ci ha fatti lo Spirito Santo, l'istinto divino che ci guida nel cuore.

         Egli lo sa che siamo chiamati all'unità e per questo ci spinge dove possiamo
attingerla.

         E allora, che dire?

         Viviamo in questo prossimo mese, con maggior coscienza, l'unità.

         Non diamola per scontata giacché - diciamo - siamo membri del Movimento dei
Focolari e viviamo magari immersi in esso. No, no: dobbiamo costruirla momento per
momento, cominciando da adesso, con i nostri fratelli d'Ideale, col dar vita a rapporti
trinitari fra noi mediante un radicale amore reciproco, consci che l'Eucaristia ci darà la
grazia che serve.

         E poi, sempre in questo mese, portiamoci più spesso possibile in qualche Chiesa o
cappella a ringraziare Gesù Eucaristia di tutte le volte che Egli è intervenuto nella nostra
vita d'unità. La gratitudine è un dovere e chiama nuove grazie.

         Dunque non dimentichiamo: amore reciproco, ma di quello proprio... e incontri con
Gesù Eucaristia, qualche visita a Gesù Eucaristia.$doc1765$, 'drive_import', '01765-WEB-1996-12-21-noi-e-leucaristia-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1765)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1766, 'ITA', $doc1766$Rocca di Papa, 27 febbraio 1997
Una ginnastica utile

Carissimi,

         in questi nostri Collegamenti cerchiamo di approfondire quei cardini della nostra
spiritualità che sono contenuti nel tema preparato ogni anno e steso per la nostra
formazione spirituale.

         La volta scorsa, infatti, abbiamo parlato dell'"unità".
         Oggi ripensiamo un po' quel punto che, abbreviato, definiamo: "Gesù in mezzo".
         Sì, Gesù in mezzo a noi, effetto dell'unità.
         Non un comando, non un'esortazione, o un concetto, o una regola, ma Lui, proprio
Lui, una Persona, che vive spiritualmente fra coloro che sono uniti dall'amore nel suo Nome.

         Oggi ci tocca spesso d'accostare, nel mondo in cui viviamo, persone anche rette e
buone che non sentono però il bisogno di credere. C'è chi, fra loro, ne avrebbe anche il
desiderio, ma, immerso in un mondo, che dovrebbe essere cristiano, e spesso non lo è, non
trova la forza di fare il passo e attende, ponendosi fra coloro che si dicono in ricerca.

         Attende chi?
         Attende, magari inconsciamente, di incontrarsi un giorno con Gesù.
         Ed è qui, è di fronte a persone di questo genere, soprattutto, che si costata di
estrema attualità, opportunità e urgenza la nostra spiritualità ed il punto in questione: Gesù
in mezzo a noi, il Risorto.
         Egli attesta, dimostra di non essere una realtà soltanto di un tempo passato, ma è
Colui che, mantenendo la sua promessa: "Io sarò con voi tutti i giorni fino alla fine del
mondo" (Mt 28,20), è presente, vivo, luminoso, amante anche oggi tra i fratelli.
         Portare Lui in mezzo a noi è il nostro grande dovere.
         E lo possiamo, attuando i suoi comandi, che si riassumono nel comandamento nuovo
vissuto sul modello di Gesù abbandonato.
         Vivere però i suoi comandi - ha detto Lui - è portare un giogo leggero e soave (cf Mt
11,30).

         Un giogo certo, che tien bassa la testa al nostro uomo vecchio, ma non pesante, anzi
dolce.

         E' così.

         Ma, può essere sempre così?
         In genere sì. Si esigono però due o più persone unite nel suo Nome.

         E quando fossimo soli? O non fossimo da altri compresi nell'amore?
         Noi sappiamo che con l'abbraccio di Gesù abbandonato in momenti del genere,
possiamo mantenerci in piedi, in pace e anche nella gioia, e possiamo lavorare, pregare,
studiare, vivere con la pienezza nel cuore.

         Vi possono essere però momenti in cui sembra difficile poter definire leggero e
soave il giogo del Signore.

         Vi sono periodi, ad esempio, in cui la salute non regge e influisce anche sull'anima, e
ci chiude in noi stessi, rendendoci incapaci quasi di rapportarci con i fratelli.

         Oppure vi sono momenti in cui si è vincolati a certi segreti che pesano e ci sarebbe di
sollievo comunicare, ma non possiamo. Riguardano noi - come prove della nostra anima - o
altri, come fatti tristi e delicati che ci sono stati confidati in segreto.

         Riguardano anche periodi in cui si è sommersi da tentazioni che si possono dire solo
al confessore.

         O morti improvvise, o incidenti imprevisti che ci tolgono il respiro e ci sembra
difficile altri capiscano.

         O il manifestarsi di una malattia, che si può pensare mortale...
         O..., o...
         Sono tutte circostanze dolorose, che Dio permette per lavorarci con quel mezzo da
cui, nel cristianesimo, non si può prescindere e che Gesù stesso ha provato: la croce.

         Come comportarsi in questi frangenti?
         Cercare di gioire, almeno con la volontà, per essere un po' come Lui, abbandonato,
gettando ogni preoccupazione nel cuore del Padre (cf 1Pt 5,7).

         Rimanere in una continua offerta, aiutati dalla grazia del momento, che non
mancherà, finché Dio farà tornare in pieno il sereno sulla nostra anima provata.

         Tener presente però che dobbiamo sempre amare i fratelli, naturalmente come
possiamo e per quanto possiamo, confidandoci con loro, almeno in linea generale. Dire ad
esempio: "Sto passando una prova...". Dirlo per amore, per non venir meno alla comunione.
Il comunicare, fra il resto, è sempre il tonico migliore in ogni situazione.

         Così, Gesù fra noi, se non smettiamo di "generarlo" - come diceva Paolo VI - ci
porterà a galla anche in questi momenti e ci dimostrerà che, sempre e comunque, il suo
giogo può esser leggero e soave.

         In questo mese, dedicato appunto all'approfondimento della realtà di Gesù fra noi,
impegniamoci a far ogni sforzo perché Egli sia sempre presente.

         Sarà una ginnastica utile per dimostrarci che potremo averLo fra noi per tutta la
vita.$doc1766$, 'drive_import', '01766-WEB-1997-02-27-una-ginnastica-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1766)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1767, 'ITA', $doc1767$Rocca di Papa, 24 aprile 1997
Con i due remi

Carissime, carissime tutte,

         si è concluso il nostro viaggio nell'America del Nord ed in quella Centrale, durante il
quale siete state informate sui vari avvenimenti successi, con un aggiornamento quasi
quotidiano. E si riparte oggi con il solito Collegamento mensile, che riporta il pensiero
spirituale e la relazione di fatti recentemente avvenuti nel mondo-ideale.

         Che dirvi oggi?
         Voglio comunicarvi una mia considerazione.
         So che molti, io compresa, teniamo come linea di vita una Parola, che tanto bene ha
fatto e fa alla nostra anima. E' una Parola che - ci sembra - riassuma tutto ciò che ci è
richiesto dal nostro Ideale e suona così: "Sei tu, Signore, l'unico mio bene."
         Attuata dà effetti favolosi e fa pensare che, vivendo essa, tutto sia fatto.

         Come si sa, questa Parola riassume in sé quanto è richiesto per seguire Gesù: la
rinuncia a se stessi ("Chi vuol venire dietro a me rinneghi se stesso..." e cioè le virtù) e
l'invito ad accogliere il ["porti la sua croce", (cf Mt 16,24)].

         Contiene certamente tutto. Ne era convinto anche Paolo che affermava: "Non
conosco che Cristo e questi crocifisso" (cf 1 Cor 2,2). Come a dire: non ho bisogno d'altro.

         Può essere, però, che noi finora abbiamo vissuto questa Parola limitandoci ad
abbracciare Gesù abbandonato nei dolori che sopravvenivano e nel praticare, ogniqualvolta
era necessario, le varie virtù: la pazienza quando eravamo tentati dell'opposto, la povertà
quando il nostro cuore si attaccava a qualche cosa, l'umiltà quando la superbia ci esaltava, la
misericordia quando il giudizio ci attanagliava, la purezza quando qualche cosa ci turbava, e
così via.

         Comportandoci in tale maniera, però, non era di tutti i momenti poter affermare:
"Sei tu, Signore, l'unico mio bene", in quanto i dolori non sono sempre presenti nella vita e
nemmeno è richiesto in ogni istante il "perdere" qualcosa col rinnegamento.
         Vi è, invece, un modo, che è tutto nostro, per vivere in ogni istante questa Parola. E'
quello di amare, amare Dio nella sua volontà e amare il prossimo.

         E', infatti, proprio nell'amare che noi troviamo la nostra tipica maniera di soffrire e
di praticare le virtù.

         Amare, nostra vocazione, che non sostituisce certamente il vivere la Parola "Sei Tu,
Signore, l'unico mio bene", come abbiamo fatto finora, e che deve continuare. Ma lo rende
possibile tutta la giornata.

         Così si comportava il nostro Donato, che pochi giorni fa è partito per la Mariapoli
celeste, soprattutto negli ultimi mesi della sua vita e di più ancora nelle sue ultime
settimane.

         Egli ha usato due remi per condurre la navicella della sua vita fino al Porto, a Dio: il
"Sei Tu, Signore l'unico mio bene" detto e ripetuto con una fedeltà estrema, con perfezione,
con costanza mirabile ogni volta occorreva, e l'amare.

         Amava tutti.

         Ed ha realizzato un capolavoro di grazia e di santità.

         Quando lo si visitava ci si rendeva conto come egli vivesse su un gradino, per così
dire, più alto di tutti quelli occupati da quanti - ed erano dei meravigliosi focolarini - lo
circondavano.

         Egli navigava sicuro come un nocchiero in alto mare superando con una maestria
soprannaturale tutti i marosi che si accavallano quando ci si avvicina a quell'ora.

         Ricordo che uno di questi ultimi giorni mi ha confidato: "Sai, al pensiero di dover
partire, ho avuto un momento di malinconia, ma poi: 'Sei Tu, Signore, l'unico mio bene' e
tutto è passato."

         Per cui, anche quella volta, s'era sentito pronto a lanciarsi ad amare. Ed amò sempre.

         Chissà ora dove questa corsa nel suo Santo Viaggio ha portato Donato!

         Chissà come ora prega Gesù, che ha incontrato, per quegli scopi per cui ha dato la
vita: i focolarini, il nostro soggiorno qui a Graz, l'Opera!

         Egli rimarrà sempre nel nostro cuore come un modello di chi appunto sa far uso
dell'uno e dell'altro remo della navicella per superare vittoriosamente i flutti della vita e
seminare ovunque l'amore.
         Addio, Donato! Abbiamo cercato di esserti vicino quaggiù per condividere con te lo
sforzo delle tue lotte e la gioia delle tue vittorie.

         Sii vicino ora a noi tu, che tanto puoi lì dove sei, perché sappiamo ripetere come te a
Gesù: "Sei Tu, Signore, l'unico mio bene" e sappiamo far uscire dal nostro cuore tutto
l'amore possibile.$doc1767$, 'drive_import', '01767-WEB-1997-04-24-con-i-due-remi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1767)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1768, 'ITA', $doc1768$Graz, 26 giugno 1997

E' sempre amore

Carissimi,

         dopo la sospensione del Collegamento nel mese di luglio, lo continuiamo ora.

         In questi due mesi intanto abbiamo avuto modo di constatare personalmente la
validità e la funzionalità per il nostro Santo viaggio dell'ultimo pensiero: "navigare con due
remi".

         Così mi è stato riferito da parecchi di voi ed è questa anche la mia convinzione, tanto
da desiderare di non cambiare ma continuare ancora in questo modo. Ma cosa avremmo
trovato di meglio?

         Potremo forse avere un più grande guadagno da esso, da questo pensiero, per la
nostra vita spirituale se, aiutati da una sua migliore comprensione, ci impegneremo a
viverlo con maggiore autenticità e perfezione.

         Impegniamoci allora anche il prossimo mese a vivere così, ma in maniera nuova:
remiamo verso la santità con uno dei remi, attuando cioè ogni rinuncia a tutto ciò che non è
Dio e abbracciando ogni dolore che ci capita con le liberanti parole: "Sei Tu, Signore, l'unico
mio bene".

         Nelle circostanze normali, invece, remiamo con l'altro remo, amando Dio intanto
nella sua volontà (diceva Caterina da Genova: “Più l'uomo si conforma alla volontà di Dio,
più si avvicina alla perfezione”) e poi amandolo nei fratelli. Scrive Rahner: “Chi si espone
all'avventura dell'amore incondizionato per il prossimo, trova Dio”.

         E in che cosa sta il nuovo, il modo nuovo di vivere in questo modo?

         Pensiamo un po'.

         Cosa succede quando noi, turbati per il subentrare nel nostro spirito d'un qualche
attaccamento dal quale dobbiamo distaccarci, pronunciamo con tutto il cuore: "Sei Tu,
Signore, l'unico mio bene"?

         E' proprio un atto di rinuncia quello che facciamo? Se bene osserviamo, non è
proprio così.

         Noi, dichiarando la nostra predilezione per Gesù abbandonato, facciamo invece un
atto di amore a Lui. E solo di conseguenza lasciamo cadere contemporaneamente ogni
attaccamento che abbiamo a noi stessi, alle creature o alle cose. Si ama Dio, Lo si sceglie e
con ciò si perde il resto.

         Ogni autentica virtù, che si contrappone al rispettivo vizio, è effetto dell'amore, ha la
sua radice nell'amore. Cosa questa per noi molto importante.

         Tale modo di fare, infatti, è un'espressione genuina della nostra spiritualità che è
differente da altre che pure hanno dato ottimi frutti di santità nella storia della Chiesa.

         Per noi non si tratta tanto, come si può fare altrove, di spogliarci di un difetto e poi
d'un altro, ma di porre la nostra tensione nell'amare.

         E perciò anche in questi momenti, come in quelli normali in cui l'anima, in pace, ama
la Volontà di Dio ed il fratello, il remo che dobbiamo attivare per poter navigare è quello
dell'amore.

         Identica cosa succede quando ci visita un qualsiasi dolore. Non lo lasciamo tanto
dominare su di noi, non è tanto della nostra spiritualità sopportarlo, schiacciati da esso, ma,
con l'atto di predilezione a Gesù crocefisso e abbandonato, possiamo trovare la maniera di
andare in certo modo al di là di esso e liberare così del suo peso almeno l'anima nostra.

         Testimoniano continuamente questa reale possibilità i nostri fratelli passati, non
senza sofferenze anche atroci e agonie mortali, nella Mariapoli Celeste.

         Dunque, anche quando ci visita il dolore, si ama; si ama Dio in Gesù.

         Per cui possiamo dire che la nostra vita, sia che infuri il vento della tentazione o la
tempesta della sofferenza, è sempre amore, come è amore negli altri momenti.

         E ciò perché - lo sappiamo - la nostra spiritualità ha appunto questo solo nome:
amore, quell'amore che può rendere la nostra anima sana pur nella malattia, viva pur vicina
alla morte, libera e gioiosa in ogni attimo.

         E' quell'amore che rende sempre possibile la vita di Gesù in noi, che ci fa altri Gesù
che camminano su questa terra; ed, essendo Gesù, in grado di dedicarci agli altri, di
stringere unità con molti. Sappiamo di quale amore sono capaci, ad esempio, i nostri fratelli
da un letto d'ospedale.

         Essere Gesù personalmente è, infatti, la premessa necessaria all'unità con i prossimi.

         Essere Gesù perciò è la condizione di ciascuno di noi di poter vivere la nostra
spiritualità collettiva.

         In questo mese di settembre, allora, puntiamo lì: ad essere sempre "altri Gesù" per
realizzare il Suo testamento.

         Già siamo "altri Gesù" per il battesimo, ma occorre la nostra cooperazione perché
cresca in noi.
         Per cui - concludiamo - in questo mese cerchiamo di navigare nella nostra vita con i
due remi, ma, attenzione!, che ognuno dei due non sia altro che amore.$doc1768$, 'drive_import', '01768-WEB-1997-06-26-e-sempre-amore-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1768)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1769, 'ITA', $doc1769$Mollens, 28 agosto 1997
L'arte di amare
in Madre Teresa di Calcutta

         Il secondo dei remi, che ci aiutano a navigare bene nella vita, dice di amare Dio nella
sua volontà e di amare ogni prossimo con “l'arte di amare”. Quest'oggi ci soffermeremo
ancora su quest'arte d'amare. E non finiremmo mai.

         E' nostra convinzione che noi non dobbiamo imitare i santi pedestremente, ma
possiamo contemplare in loro e vivere con loro qualche aspetto della nostra stessa
spiritualità, che, perché persegue l'unità, è universale e abbraccia un po' tutti gli aspetti
della vita cristiana. Infatti, Paolo VI disse che l'unità è il “riassunto del Vangelo”. E', infatti, la
sua sintesi più alta.

         E possiamo fare ciò specie se nei santi è presente un carisma che sottolinea quel
dato aspetto.

         Abbiamo tutti noi, più o meno, seguito per televisione l'evento a Calcutta della
grandiosa cerimonia per i funerali di Madre Teresa. Siamo rimasti profondamente colpiti,
ammirati, commossi. Abbiamo lodato Dio per aver dato alla Chiesa e all'umanità intera tale
miracolo di carità.

         E cosa possiamo averne ricavato?
         Sappiamo che l'Opera di Madre Teresa e la nostra sono due fra le Opere più estese
nel mondo. Si possono anche fare, fra le due, dei paralleli: ambedue mondiali, ambedue con
un numero pressoché uguale di consacrati, ambedue col numero di case (per noi i focolari)
molto, molto alto.
         Ma tuttavia con una grande differenza.
         Noi non siamo chiamati tanto a spendere tutte le nostre energie in favore dei più
poveri fra i poveri - almeno nel senso di Madre Teresa, perché i più poveri di tutti sarebbero
quelli senza Dio. “L'hai fatto a me”, parola sintesi della sua spiritualità, aspetto
importantissimo del Vangelo, ma particolare di esso, non dice infatti tutta la nostra
spiritualità.
         Noi siamo chiamati a vivere, in certo modo, tutto intero il Vangelo, sì da suscitare un
popolo, quello che già c'è in potenza, per il battesimo, nel mondo cristiano, ma che deve
estendersi nel mondo, attraverso i dialoghi, con fedeli di altre religioni e di altre culture.

         Per cui, modello per noi non possono essere tanto i santi, quanto Maria SS., che ha
dato la vita a Gesù (e noi dobbiamo darla a Cristo in noi) ed è madre anche del suo Corpo
mistico, la Chiesa, al quale pure noi ci dedichiamo ravvivandolo quale popolo nuovo, quale
famiglia di Dio.

         Ma se abbiamo evidenziato la differenza fra la nostra e l'Opera di Madre Teresa, non
possiamo non vedere una profonda somiglianza sul piano proprio dell'amore. Amore che lei
ha vissuto tanto bene, eroicamente, da poter essere per tutti un modello.

         Madre Teresa è, infatti, una maestra eccelsa dell'arte di amare.

         Amava veramente tutti. Non chiedeva al suo prossimo se era cattolico o indù o
musulmano, ecc. A lei bastava che fosse uomo o donna, in cui riscopriva tutta la sua dignità.

         Madre Teresa amava senz'altro per prima. Era lei che andava a cercare coloro per i
quali era stata inviata da Dio.

         Madre Teresa vedeva, come forse nessun altro, Gesù in ognuno: “l'hai fatto a me”
appunto il suo motto.

         Madre Teresa si faceva uno con tutti. S'è fatta povera con i poveri, ma soprattutto
come i poveri. E' qui che si differenzia dalla semplice assistente sociale o dalla dama di
carità o da chi è dedito al volontariato.

         Non accettava nulla che non potessero avere anche i poveri.

         E' nota, ad esempio, la sua rinuncia e quella delle sue suorette ad una semplice
lavatrice, rinuncia che molti non comprendono - dicono: in questi tempi! -, ma lei faceva così
perché i poveri non ce l'hanno e quindi nemmeno lei.

         S'è addossata, ha fatto propria la miseria dei poveri, le loro pene, le loro malattie, le
loro morti.

         Madre Teresa ha amato tutti come se stessa, sino ad offrire loro il proprio ideale.
Invitava, ad esempio, i volontari, che prestavano per un certo tempo un servizio alla sua
Opera, a cercare la propria Calcutta là dove ognuno tornava. Perché i poveri - diceva - sono
un po' dovunque.

         Madre Teresa ha senz'altro amato i nemici. Non s'è mai fermata a contestare le
accuse assurde che le si rivolgevano, ma pregava per i nemici.

         Sì, in lei si può vedere “l'arte di amare” incarnata alla perfezione.
         Era una regina - come ha detto il nostro Presidente Scalfaro -, una regina della carità.
         Ed è in questo che lei ci può essere d'esempio.

         Noi possiamo pensare a Madre Teresa soprattutto quando avviciniamo o lavoriamo
per i nostri 5.000; quando operiamo per e nelle nostre opere o attività sociali, che in gran
numero, più di 700, abbiamo sparse per il mondo; quando ci dedichiamo all'Economia di
Comunione, che ha anch'essa per fine i poveri.

         Giacché, con tutti poi, pure noi pensiamo che sarà proclamata fra i santi, vogliamo
anche annoverare Madre Teresa (intanto che faccia un noviziato come protettrice) fra i
santi nostri protettori. Io la prego già e mi sembra di vederla vicinissima a Dio, quasi
confusa con Dio.

         In questo prossimo mese, nel mettere in pratica l'amore verso i prossimi, teniamo,
dunque, presente Madre Teresa di Calcutta.

         E così ella continuerà ad amare anche noi con predilezione, perché così ci amava
quando era in vita.

         Il calorosissimo abbraccio finale, che ci siamo date a New York l'ultima volta prima
di lasciarci ne era - penso - un segno, ne era una promessa.$doc1769$, 'drive_import', '01769-WEB-1997-08-28-larte-di-amare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1769)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1770, 'ITA', $doc1770$Bologna, 25 settembre 1997

S. Teresa del Bambino Gesù

dottore della Chiesa

         Abbiamo assistito, in questo mese, alla solenne proclamazione, avvenuta per opera
del S. Padre Giovanni Paolo II, di santa Teresa di Lisieux a dottore della Chiesa.

         Il fatto era nell'aria da tempo. Alcuni dubitavano su questa possibilità per l'assoluta
mancanza di studi universitari di questa santa, per l'assenza nei suoi scritti di una
"presentazione scientificamente elaborata delle cose di Dio" e per la disarmante semplicità
del suo modo di pensare.

         Ultimamente è stato detto anche che sarebbe stata definita "giovane dottore".

         Ma la Sapienza, che non manca mai alla Chiesa, ha invece deciso: santa Teresa del
Bambino Gesù sarà il 33° dottore della Chiesa.

         Grande onore, onore inestimabile! Ora, se la sua vita è stata stampata in più di 500
edizioni, ed ha invaso il mondo (anche più dell'opera, si dice, di santa Teresa d'Avila), essa
avrà un'ulteriore diffusione. Si vorrà sapere ancor più cos'ha avuto di straordinario questa
giovane carmelitana.

         Lo straordinario di quest'anima, mi sembra, l'ha rilevato il Sommo Pontefice nel suo
discorso.

         E la grandezza di Teresa l'ha vista anche in quella sua scoperta: "Nella Chiesa, mia
madre, io sarò l'amore".

         Bramava avere tante vocazioni nella Chiesa: sacerdote, missionario, ecc. Ma non era
quella la volontà di Dio su di lei. Cosicché lo Spirito le rese chiaro al cuore il suo specifico
compito nella Sposa di Cristo: essere l'amore.

         E essere l'amore non è stato solo una scoperta per lei; è stata la sua vita. Le
testimonianze, che hanno permesso di arrivare alla definizione della sua santità, lo stanno a
dimostrare.

         Sono rimasta anch'io sorpresa nel costatare quella sua breve vita incredibilmente
costellata di atti d'amore. E non solo verso Dio (è nota ed ammirevole la sua confidenza
sterminata in Lui), ma verso i suoi prossimi.
         Teresa aveva trovato, dunque, il suo posto nella Chiesa. Ma, a quanto sembra,
quando Teresa comprese, in un tripudio di gioia, questa sua vocazione, non era del tutto
chiaro per lei ciò che lo Spirito Santo le aveva rivelato.

         Si può pensare, infatti, che essere l'amore nella Chiesa non è solo la vocazione di
Teresa. E' la vocazione che, in questi tempi, viene in maggior rilievo per ogni donna
cristiana.

         Oggi, in cui la Chiesa, per circostanze riguardanti soprattutto altre porzioni di
cristianità, si trova nella necessità di precisare la sua posizione, che è quella di Cristo, nei
confronti del sacerdozio femminile; le donne avvertono, come Teresa, nel loro cuore con
accresciuta convinzione, che ciò che dà senso alla loro vita è proprio l'amore.

         Ed è da questa vocazione tipica della donna d'oggi che segue Cristo che ha origine il
suo genio, quello che il S. Padre Giovanni Paolo II chiama appunto "genio femminile".

         E forse è anche per questa scoperta di Teresa che oggi abbiamo in lei un dottore
della Chiesa.

         Non ha, infatti, colto dallo Spirito solo una chiamata personale ma generale, estesa a
tutte le donne, evidenziando così un aspetto della dottrina e della vita cristiana.

         E, giacché questa scoperta di Teresa non è che la rivelazione del profilo mariano
della Chiesa, il cui modello è Maria, profilo che uomini e donne sono chiamati a vivere
particolarmente oggi, essa non è che vocazione universale.

         L'amore, questo eccelso elemento diffuso nei nostri cuori dallo Spirito Santo, che ci
fa partecipi della vita divina!

         Di fronte alla vocazione di Teresa, alla sua considerazione sull'amore ai suoi pensieri
sull'amore, come vita di ogni altra vocazione cristiana, mi viene da ricordare un brano
squisitamente orientale che Atenagora mi ripeteva e riguardava proprio lo Spirito Santo:

         Diceva: "Senza lo Spirito Santo Dio è lontano, Cristo rimane nel passato, il Vangelo è
lettera morta, la Chiesa una semplice organizzazione, l'autorità una dominazione, la
missione propaganda, il culto evocazione e l'agire dell'uomo una morale da schiavo. Ma con
lui, (con lo Spirito Santo) Cristo è lì (è qui), il Vangelo è la missione trinitaria, l'autorità è un
servizio liberatore, la missione una Pentecoste, la liturgia memoriale e anticipazione,
l'azione dell'uomo diventa divina".

         Così, senza l'amore che Egli effonde, tutto perde senso.

         Questo sapeva, questo ci insegna Teresa del Bambino Gesù, dottore della Chiesa.
         L'amore, si va dicendo in questi giorni al raduno qui del Centro, l'amore reciproco è
la nostra "divisa".

         Indossiamola allora ogni mattina, appena ci svegliamo, per non togliercela più.$doc1770$, 'drive_import', '01770-WEB-1997-09-25-s-teresa-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1770)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1771, 'ITA', $doc1771$Rocca di Papa, 27 novembre 1997
Un grappolo sui generis

         Carissimi,

         questo Collegamento precede di poco Natale.
         Deve, quindi, in qualche modo concorrere a preparare questa che è, soprattutto per i
cristiani, ma non solo, la più sentita festa dell'anno.

         Il Verbo si è fatto uomo, s'è fatto bambino. Perché?
         Certamente per portarci il Cielo sulla terra, per farci partecipare della sua Vita
celeste.
         E tutta questa Vita è concentrata in un dono: l'amore. Non certo l'amore così come si
pensa quaggiù, nemmeno quello pur buono, che si concretizza in elemosina, ma quell'amore
che è lassù: l'amore soprannaturale, l'amore-carità, l'amore che è in Dio, l'amore che è Dio,
l'amore che anche noi dobbiamo essere.
         E' un amore - lo si può capire - speciale, specialissimo, ed è tipicamente cristiano,
non è conosciuto da altre fedi.
         Gesù ci ha portato quest'amore perché con esso possiamo amare adeguatamente Dio
con tutto il cuore, l'anima e le forze, e amare il nostro prossimo. E, senz'altro, ogni nostro
prossimo. L'arte di amare insegna, infatti, ad amare tutti.
         Ma Natale svela (e c'è come una percezione che si fa viva, in questi giorni, nei cuori,
anche dei più lontani da Dio) che Gesù nell'amare tutti i prossimi ha avuto comunque una
predilezione: preferiva i poveri, i derelitti, chi soffriva in qualsiasi modo, i malati quindi, i
disperati, i peccatori...

         Nei nostri statuti che, come sapete, fotografano la nostra Opera e la presentano
profeticamente tutta intenta e finalizzata alla realizzazione del Testamento di Gesù: "Padre,
che tutti siano uno" (cf Gv 17,21), troviamo (e forse non vi abbiamo posto tutta l'attenzione
dovuta) un articolo che ricorda anche a noi il dovere d'aver in cuore la preferenza che ebbe
Gesù verso chi soffre.
         E' parte dell'art. 8, dove si parla di Gesù abbandonato. Dice così: "(L'amore a Lui)
spinge (noi) queste persone a prodigarsi in favore di chiunque ricorda, nella propria
situazione personale, il suo doloroso abbandono, come le persone deluse, tradite,
nell'errore, peccatrici, lontane da Dio, orfane, separate", sofferenti insomma.

         E' un articolo che trova senz'altro la risposta nel nostro Movimento e nelle sue varie
diramazioni, in quel migliaio e più d'opere di carità e sociali, grandi e piccole, permanenti o
temporanee, alle quali in molti ci dedichiamo, cominciando da quelle solide, articolate e
ricche d'iniziative come il "Magnificat", S. Teresinha, Bukas Palad ed altre fino alla
cosiddetta "azione per i 5000", o a quelle di Gioventù Nuova dette "il Gesù abbandonato
quotidiano", ecc.

         Sì, lo facciamo e siamo contenti perché, fra l'altro, speriamo di farci dire da Gesù un
giorno il fatidico: "L'hai fatto a me" (cf Mt 25,40).

         Ora, avvicinandosi Natale, quelli che vi operano si impegnino ad adempiere ogni
cosa con più amore, più dedizione, più tempo.

         Ma, siccome non tutti, nel nostro Movimento, vi sono dedicati, cerchi ognuno
d'attuare meglio quell'art. 8, offrendo il proprio amore almeno a qualche persona sofferente,
per far un presente a Gesù bambino, avendo in cuore il proposito di curarla anche in
seguito, come un proprio "grappolo" sui generis, certi che la Provvidenza di Dio verrà in
aiuto come avveniva i primi tempi.

         Gregorio Nazianzeno ci ricorda quei primi tempi: "Prima che sia troppo tardi - dice -
(e la fine della vita viene presto) assistete Cristo, soccorrete Cristo, nutrite Cristo, rivestite
Cristo, onorate Cristo invitandolo alla vostra tavola."

         Apriamo, dunque, gli occhi e cerchiamoLo. Non ci sono città sulla terra senza un
carcere, o case per anziani, o ospedali per ammalati e per drogati, o famiglie in miseria e
magari senza tetto come i terremotati, o bambini abbandonati...

         Continuando a vivere, come parola guida, il "voglio" anche questo mese, che tanti
frutti spirituali ha portato, cerchiamo, con l'impegno che il "voglio" richiede, Gesù in chi
soffre e interveniamo almeno per Natale, senza dimenticare in sottofondo la Parola che era
di luce per il nostro cammino in quegli anni: "E avendoli amati, li amò fino alla fine" (Gv
13,1).

         Quest'azione, oltre che di gioia a qualche cuore in più, sarà anche un tonico
spirituale per noi, onde compiere meglio ogni altro nostro dovere nell'Opera a vantaggio
della Chiesa e della società.
E allora carissimi tutti: Buon Natale! Buon Natale! Buon Natale!
Che Gesù, tornando, sia contento di noi!$doc1771$, 'drive_import', '01771-WEB-1997-11-27-un-grappolo-sui-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1771)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1772, 'ITA', $doc1772$Rocca di Papa, 23 ottobre 1997
Voglio

Carissime,

         ed eccoci al Collegamento di novembre. Fra un mese sarà Natale.
         La figura che maggiormente viene in rilievo in questo periodo d'attesa è Maria, la
dolcissima madre di Gesù.

         Questa volta diremo qualcosa di Lei.

         Durante l'incontro dei responsabili delle zone di tutto il mondo qui, al Centro
dell'Opera a Rocca di Papa, in ottobre, si è parlato anche di Maria, in mezzo a tanti altri temi
e argomenti.

         Ma ciò che riguardava Lei è stato assolutamente speciale.
         Ho avuto la grazia, infatti, di parlarne a tutti, quattro volte, nelle quali abbiamo
approfondito il cosiddetto "profilo mariano". Di certo ne avete sentito accennare negli
aggiornamenti.

         Ma cos'è questo "profilo mariano"?
         Ne ha scritto, a fondo, von Balthasar, il noto e illustre teologo svizzero.
         E, accennando proprio a lui, me ne ha parlato, qualche anno fa, il S. Padre Giovanni
Paolo II.

         C'è una nuova presa di coscienza nella Chiesa in questi ultimi tempi: sta nel rendersi
conto che, in essa, attraverso i secoli, quindi anche nel nostro, accanto al "principio petrino"
riguardante - lo si capisce dal termine - la sua struttura gerarchica, non sia stato assente un
"principio mariano" e cioè una certa presenza di Maria.

         Questo "principio mariano", che fa ricordare come la Chiesa è edificata non solo
sugli apostoli ma anche sui profeti, si manifesterebbe nell'aspetto carismatico della Sposa di
Cristo, nell'aspetto profetico, spirituale, di santità, che si è sempre riscontrato in essa, così
come anche ora.

         Di questo profilo, anche il nostro Movimento, che la Chiesa stessa, nei suoi
rappresentanti, qualifica "carismatico", ne è - a quanto sembra - un'espressione. Von
Balthasar, che lo conobbe, ne era convinto e lo scrisse.

         Allora, se così è, la conclusione da trarre è quella d'esserne sempre più degni e
d'adeguare la nostra vita quotidiana a ciò che esso esige.

         E che cosa esige da noi? In pratica: come dobbiamo essere? Su chi modellarci?
         E' ovvio. Se il profilo è mariano, dobbiamo modellarci su Maria.

         Essere come Lei, imitarla, anzi, in certo modo, "riviverla" per quanto è possibile. E',
del resto, sempre stata questa la tensione del Movimento fin dai suoi primi tempi.

         Ricordate quando si cominciava a capire che Maria era il nostro "dover essere" e noi,
di Lei, il "poter essere"?

         Vocazione questa non solo per i singoli membri del Movimento, ma per la nostra
Opera nel suo insieme, che non a caso si chiama: Opera di Maria.

         Dice, infatti, il nostro statuto all'art. 2: "L'Opera di Maria... desidera essere - per
quanto è possibile - una presenza (di Maria) sulla terra e quasi una sua continuazione".

         E, lo sappiamo, "Maria" è anche un punto della nostra spiritualità e quindi un
cardine da vivere.

         Da vivere.
         Ma come viverla, come imitarla, da dove cominciare?
         Maria è semplice, ma è anche ricchissima! Come adeguarvisi in qualche modo?
         Forse c'è una sua parola nella quale possiamo intravedere un costante
atteggiamento della sua vita. E' il suo "sì", il "fiat" che ha pronunciato all'Angelo,
all'incarnazione e ha ripetuto tutta la vita.

         "Sì" a che? a chi?

         Sì a Dio, a tutto ciò che le chiedeva, a tutto ciò che le avrebbe chiesto; sì al Suo
volere.

         Sì.

         Ho ricordato questo (suo) "sì" in questi giorni ammirandolo ripetuto, in altra
maniera, in una persona, che ben può dirsi ispirata dal "principio mariano": Madre Teresa di
Calcutta.

         Ella dice che per poter essere il nostro dover essere, per raggiungere cioè la
perfezione, la santità, occorre dire: "Voglio!", ossia "sì". Dir sempre "voglio" a quanto Dio
vuole.

         La vita, infatti, per lei si gioca fra un "voglio" ed un "non voglio"; o - se volete - fra un
sì e un no.

         Perché, per raggiungere la santità non basta aver fiducia nella grazia di Dio e
abbandonarvisi, ma occorre la nostra totale corrispondenza, la nostra volontà piena:
"Voglio".

         Nel prossimo mese, anche per onorare Maria che ci presenta in Gesù il frutto del suo
"sì", del suo "voglio", ripetiamolo anche noi con Lei ad ogni richiesta del nostro Ideale.

         Quando mi sveglio, al mattino, "voglio" indossare la divisa dell'amore reciproco;
durante il giorno: "voglio" l'amore pieno verso ogni prossimo che incontrerò; "voglio" il
raccoglimento che mi richiede la preghiera; "voglio" ogni manifestazione della volontà di
Dio compresa nei 7 aspetti della mia vita d'amore; "voglio" ogni dolore che incontrerò...

         Con questo "voglio" ci inseriremo in modo efficace e fruttuoso in quella vita
mariana, di cui oggi si ha più coscienza, e che concorrerà, senz'altro nel prossimo secolo, a
far la Chiesa più bella, più attraente, più affascinante, capace di trascinare le folle alla
sequela di Gesù, in quell'avventura mozzafiato (così von Balthasar vede l'effetto del
principio mariano vissuto) che anche noi siamo chiamati a vivere.
"Voglio" sia la parola che ci conduce.$doc1772$, 'drive_import', '01772-WEB-1997-10-23-voglio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1772)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1773, 'ITA', $doc1773$Rocca di Papa, 18 dicembre 1997
1998
Costruirsi in preghiera

         Carissime,

         il proposito che ha accompagnato i nostri focolarini al rientro in zona, dopo il loro
grande incontro a Rocca di Papa, è stato quello riassunto in una parola: migliorare.

         Ora, da quanto so, questa parola ha fatto il giro del mondo, del nostro mondo.
         Dobbiamo, dunque, migliorare. Quando?
         Sempre, in ogni momento della nostra vita ed in ogni sua espressione particolare.
         Per aiutarci in ciò, vediamo oggi come migliorare nel nostro rapporto con Dio.

         Come sappiamo, la nostra spiritualità, personale e comunitaria insieme, ci porta ad
estendere il nostro amore verticalmente, come si dice oggi, verso Dio e orizzontalmente
verso il prossimo; e la santità, che ne deriva, è data dalla equilibrata presenza di questi due
amori.

         Ma è facile per alcuni (e lo sta dimostrando la tendenza, alle volte, all'attivismo)
sviluppare in modo particolare la dimensione orizzontale dell'amore e, forse, non
altrettanto quella verticale.

         E' vero che noi tutto quanto facciamo lo rivolgiamo in genere a Lui: è per Lui che
amiamo, che operiamo, che soffriamo, che preghiamo...

         Ma, se col continuo "farci uno" con i prossimi siamo arrivati ad amarli spesso anche
col cuore, siamo certi di amare pure Dio non solo con la volontà, ma insieme col cuore?

         Alla fine della nostra vita non potremo presentarci a Dio assieme agli altri, alla
comunità, ma dovremo farlo da soli.

         E siamo sicuri che, in quel momento, tutto l'amore raccolto nel nostro cuore,
durante la nostra esistenza, si verserà spontaneamente, come dovrebbe essere, su Colui che
dovremmo aver sempre amato e che incontreremo e ci giudicherà?

         In altre parole, potremo anche noi, almeno un po', dire parole simili a quelle di santa
Teresa d'Avila, la quale, prossima alla morte, ha detto, come conseguenza logica della sua
vita d'amore: "Signore mio e Sposo mio, è giunta l'ora tanto desiderata. E' tempo che ci
vediamo, Amato mio e Signore mio (...). E' giunta l'ora in cui (...) l'anima mia può godere di
Voi come ho tanto desiderato"?

         Ci sarà nel nostro cuore qualcosa che assomigli a questo anelito, a questa brama?

         Arriverà senz'altro anche per noi quel momento e, tenendolo presente, dovremmo
sin da adesso cercare di approfondire meglio ed al massimo il nostro rapporto con Dio.

         Durante gli esercizi spirituali fatti con i responsabili di zona l'ottobre scorso, sono
rimasta sorpresa d'un fatto. Avendo stabilito un tempo di silenzio e solitudine per tutti, al
mattino, diversi di loro mi hanno confidato la propria gioia per essersi trovati subito in
piena unione con Dio dentro di loro.

         Era senz'altro effetto del costante amore che avevano avuto verso i vari prossimi in
cui hanno servito, per anni, Gesù; ma non avevano, forse, fatto ancora un'esperienza forte di
quanto fosse vero che, più cresce la pianticella della nostra unione con gli altri, più si
approfondisce la radichetta del nostro amore a Dio.

         E così, per l'amore orizzontale praticato, avevano trovato ora in cuore l'amore
verticale, l'unione con Dio.

         Si può, infatti, amare come servi e compiere tutto quanto il padrone vuole senza
rivolgergli parola; o si può amare come figli col cuore, riempito dallo Spirito Santo, di amore
e di confidenza nel proprio Padre: quella confidenza che porta a parlare spesso con Lui, a
dirgli tutte le nostre cose, i nostri propositi, i nostri progetti; quella confidenza, quel divino
desiderio che porta a non veder l'ora che arrivi il momento dedicato esclusivamente a Lui,
per mettersi in contatto profondo con Lui.

         E' la preghiera, la preghiera vera! E' ad essa che dobbiamo tendere, fino ad arrivare
ad essere preghiere viventi.

         C'è una bella frase del teologo Evdokimov, a proposito della preghiera: "Non basta -
dice - avere la preghiera, bisogna diventare, essere preghiera, costruirsi in forma di
preghiera..."

         Costruirsi in forma di preghiera, essere preghiera, come vuole Gesù, che ha detto:
"Conviene sempre pregare" (cf Lc 21,36).

         Io credo che nel cuore di molti di noi ci sia un vero patrimonio d'amore
soprannaturale che può trasformare la nostra vita in autentica preghiera, che può costruirci
in preghiera. Si tratta di raccoglierlo nei momenti opportuni.
         In questo prossimo tempo impegniamoci allora a parlare spesso con Dio, anche in
mezzo all'attività. Cerchiamo di migliorare proprio in questo.

         Già il dire un "per te" prima di ogni azione, trasforma questa in una preghiera.

         Ma non basta. Incominciamo, durante il prossimo mese, un colloquio serrato con Lui
ogni volta che è possibile. Solo così alla fine della vita potranno fiorire sulle nostre labbra
espressioni d'amore a Dio, simili a quelle dei santi.

         In pratica bisogna riciclare il grande amore che abbiamo per i prossimi in amore per
Iddio.$doc1773$, 'drive_import', '01773-WEB-1997-12-18-costruirsi-in-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1773)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1774, 'ITA', $doc1774$Rocca di Papa, 18 giugno 1998
Santità di popolo

Carissime e carissimi,

         vorrei fare oggi con tutti voi una comunione d'anima, e dirvi un mio pensiero di cui
ho messo a parte, quassù, i partecipanti a più corsi.

         Si tratta del nostro rapporto con la santità.

         Madre Teresa di Calcutta, più volte, scrivendomi, ha ripetuto la frase: "Fatti santa
perché Dio è santo."

         Non è stata certamente questa grande santa a determinare una mia preghiera, che
facevo da tempo. Ma, senz'altro, ella, con questa sua frase ha gettato fuoco su fuoco.

         Da anni, infatti, da molti anni, Qualcuno nel cuore mi ha spinto a rivolgere a Gesù
queste parole: "Fammi santa per fare un dono a Maria."

         Mi sembrava, infatti, che, se io non avessi raggiunto la méta della santità, sarebbe
mancato qualcosa al mio servizio all'Opera: la possibilità di offrirle non solo le cure che, con
la grazia di Dio, posso aver avuto per essa, ma un modello, una testimone compiuta della sua
spiritualità.

         Sin dall'inizio del Movimento, non si è mai capita, però, la ricerca della santità per se
stessa. Poteva esprimere ancora un ripiegamento su di sé.

         Ma cercarla per amore era un'altra cosa. Ecco perché: "per farne un dono a Maria".
E perché "a Maria"?
Perché è la nostra madre, la nostra forma, la nostra regina, Colei che ci guida.
E "a Maria", anche, semplicemente, perché le vogliamo bene.

         Più recentemente però, conscia che la nostra via è collettiva e richiede l'attuazione
perfetta dell'amare gli altri come sé, ho avuto chiaro che, per potermi far santa, avrei dovuto
desiderare quella méta per i miei prossimi come per me. Così la mia preghiera veniva
subendo un cambiamento: "Gesù, facci santi per fare un dono a Maria ed essere modello per
molti."

         Questa nuova preghiera quassù, comunicata, ha reso felici tanti, ed insieme, per fare
la nostra parte, ci siamo promessi di vivere la formula delle 6 "s" già nota a noi: "Sarò santa
se sono santa subito."

         Ma, a che punto è il nostro Movimento a proposito della santità?

         Ci sembra di poter dire che, con la grazia di Dio per aver vissuto il carisma dell'unità,
ci devono essere molti piccoli e meno piccoli santi in Paradiso fra i nostri. Non esiteremmo a
pensarne decine e decine e forse più. Abbiamo costatato, infatti, in quale maniera molti e
molti partono da questa terra e si sa che, in genere, la morte è specchio della vita.

         Tuttavia, nel nostro Movimento, di rado abbiamo pensato di presentare alla Chiesa
queste creature perché, se credeva, provvedesse ad una verifica. Qualcosa si sta ora
preparando per Igino Giordani, il nostro Foco, e per mons. Klaus Hemmerle. Ma... tutto qui.

         Piuttosto è la Chiesa stessa che comincia a interessarsi di ciò attraverso i suoi
Pastori, i quali stanno pensando d'introdurre attualmente un processo di canonizzazione di
tre nostre giovani: due gen ed un'aderente; due delle quali morte in giovanissima età per
salvare la loro purezza.

         Ma noi, abbiamo fatto bene, come Movimento, a non interessarcene?

         La giustificazione a questa nostra apparente omissione forse, oggi, è chiara: il
Signore non ci domanda una santità individuale, ma comunitaria, dove ognuno deve aiutare
il suo prossimo a farsi santo. E questi, a catena, il prossimo suo, e così via.

E' questo tipo di santità che andrebbe eventualmente verificata e messa in luce per
l'edificazione di tanti nella Chiesa: una santità collettiva, una santità di popolo.

Meraviglioso, vero?

         Che il Cielo la faccia realtà.

         Intanto, impegniamoci personalmente, con la massima decisione, sin d'ora, con le 6
"s", e aiutiamo gli altri a fare altrettanto.

Che lo Spirito Santo, che ci ha dimostrato tanta predilezione, compia la sua opera e faccia
nascere davvero un popolo di santi, anche per amore di Maria, la sua Sposa.$doc1774$, 'drive_import', '01774-WEB-1998-06-18-santit-di-popolo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1774)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1775, 'ITA', $doc1775$Mollens, 27 agosto 1998

Vi consiglierei di fare come faccio io. E' troppo lunga la formula "sarò santa se sono santa
subito". Basta dire: "santo subito", "santa subito", "santi subito".
I 40 giorni

         Nell'ultimo Collegamento abbiamo parlato di santità, anzi di "santità di popolo", e ci
siamo lasciati decisi di perseguirla, con l'aiuto di Dio, vivendo il motto "santi subito", come
sunto di "sarò santo se sono santo subito".

         E senz'altro ognuno di noi ne ha sperimentato i frutti.
         Questa volta parliamo ancora di santità.

I primi giorni di questo mese, nel far meditazione sui nostri libri, ho trovato un pensiero
sulla santità, attribuito a san Bonaventura, che molti di noi senz'altro conoscono, ma che,
forse, non è vivo ancora nella nostra vita.
Esso, questo pensiero, ha attirato la mia attenzione, ne ho parlato con i responsabili di zona
qui presenti, e so che è già stato comunicato a parecchi di voi, se non a tutti. Comunque qui è
proprio il caso di affermare: le cose ripetute giovano.
Il suddetto pensiero ha suscitato nel mio cuore il grande desiderio di metterlo in pratica con
tutti voi. Non dobbiamo, forse, farci santi insieme?

         E' l'affermazione di un santo che, di vie per andare a Dio, se ne intende.
Egli, con audacia, assicura che una persona va più avanti spiritualmente in quaranta giorni,
se non si ferma nelle valli delle imperfezioni e dei peccati veniali, di chi vi sosta, in
quarant'anni.

         Bello, no?

         Mi sono naturalmente chiesta: "In che consistono le imperfezioni ed i peccati
veniali?" Certo, si potrebbe farne un lungo elenco...

         Senz'altro sono l'opposto della perfezione.
         E in che cosa consiste la perfezione?

Nel vivere la carità: "la carità che è il vincolo di perfezione", dice Paolo (Col 3,14); "Siano
perfetti - perfetti, perfezione - nella carità", si trova in Giovanni (17,23). Quella carità che, se
si è in più, come siamo noi, diventa reciproca: "Vi do un comandamento nuovo - dice Gesù -:
che vi amiate gli uni gli altri; come io vi ho amato, così amatevi anche voi gli uni gli altri"
(13,34).

         Bisogna perciò, per non rimanere nelle valli delle imperfezioni e dei peccati veniali,
vivere così e, qualora ce lo dimenticassimo o venissimo meno, ricominciare.

         Mettiamoci allora sotto, tutti, iniziando da oggi, 22 ottobre '98. Viviamo l'amore
reciproco con tutti, possibilmente.

         E, da dove conviene cominciare?

         Da casa, se siamo in casa; dal focolare, se viviamo in focolare.

         Sì, da casa, iniziando dal mattino, perché così la giornata parte bene.

         Da casa perché, alle volte, ci si impegna a viverlo bene con gli altri, negli incontri, nei
convegni e poi, tornati a casa, magari stanchi, perdiamo con i fratelli la pazienza, il controllo
e... addio amore reciproco!

         L'esperienza, durante questo mese, di noi del Centro e dei responsabili di zona, ci
dice che è indovinato cominciare proprio così: da casa, dal focolare.

         Per cui ci siamo comunicati questo detto, che ora passo a voi: "Amore reciproco
nell'attimo presente, cominciando da casa".

         Ricordiamocelo. Se così faremo, fra quaranta giorni, il 30 novembre, avremo
senz'altro progredito spiritualmente e avremo dato un notevole contributo alla nostra
santità personale ed a quella di popolo.$doc1775$, 'drive_import', '01775-WEB-1998-08-27-collegamento-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1775)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1776, 'ITA', $doc1776$Castel Gandolfo, 17 dicembre 1998

1999
La perla

         Parlando a Natale ai focolarini, un migliaio circa, radunati a Castel Gandolfo, ho detto
che avrei annunziato loro una "perla".

         Di che perla si trattava?
         Tutto è una perla, o sono più perle preziosissime, i particolari del nostro Ideale,
della nostra spiritualità, perché vengono da Dio, dal suo Spirito.
         Ma fra tutte in quel giorno, ne vedevo splendere, in modo speciale, una: la
particolarissima strada che il Signore ha svelato a noi per poter arrivare a Lui, per giungere
all'unione con Dio.
         Sappiamo come, attraverso i secoli, nella Chiesa siano sorte persone eccezionali, i
santi, i quali sono tali proprio perché sono riusciti a conquistare l'unione con Dio.
         In che modo e a che prezzo?
         Spesso ritirandosi dal mondo e isolandosi nei deserti, o chiudendosi in conventi,
protetti da mura, per facilitare, lontani dalle tentazioni del mondo, il loro rapporto col
Signore presente nel loro cuore.

         Oggi però i tempi richiedono altri modi e lo Spirito Santo si adegua ai nuovi
cambiamenti.

         Oggi "la santità – diceva Foco – deve fuoruscire dai conventi, essere presente nelle
case, nelle scuole, nelle strade, negli uffici, nei Parlamenti…", perché oggi, più di una volta,
sono anche i laici ad essere chiamati alla santità.

         E allora, come potranno essi, non isolati, non riparati da mura, privi di tutti quegli
accorgimenti che la vita spirituale chiedeva un tempo, trovare l'unione con Dio stando in
mezzo al mondo?

         Essi che non solo non sono protetti da alcunché, ma vivono sempre circondati dagli
altri uomini e donne, che un tempo si preferiva tener lontani.
         Ma ecco qui incominciare a luccicare la perla.

         Lo Spirito Santo, illuminandoci con un suo carisma, ci ha detto: proprio il fratello, la
sorella, proprio loro, che un tempo potevano essere visti come ostacoli, possono diventare
addirittura la vostra via per arrivare a Dio, un'apertura, una porta, una strada, un varco su
di Lui.

         Ad una condizione naturalmente: che non loro influiscano su di noi, col loro
comportamento spesso solo umano, ma noi su loro col nostro, soprannaturale. E come? Si
sa: amandoli. Amandoli ad uno ad uno durante la giornata, tutta la giornata. Amandoli con
quell'arte d'amare, che è divina, perché possibile solo con l'amore infuso nel tuo cuore dallo
Spirito Santo.

E noi tutti ne conosciamo ormai le esigenze.

         Che avverrà se così faremo?

         Alla sera, ad esempio, alla preghiera, e poi anche durante il giorno, quando, per un
attimo, potremo raccoglierci da soli con Dio, avvertiremo la sua presenza.

         Egli è venuto a noi, perché noi siamo andati a Lui nei fratelli.

         Si realizza così quell'unione sperimentata, che molti di noi conoscono, ma non sanno
ancora definire, classificare, forse perché nuova, sensibile ai sensi dell'anima, che riempie il
cuore d'amore.

         E così, con Lui presente, possiamo rivedere ogni nostra faccenda.

         Ne consegue, fra il resto, che, se abbiamo ottenuto ciò, attraverso il fratello amato,
questi non è soltanto un nostro beneficato, ma un nostro benefattore: ci ha procurato ciò
che di meglio speravamo.

         Occorrerà allora che lo avviciniamo con riconoscenza e ciò ci metterà in umiltà, virtù
che poi serve molto all'amore.

         Proviamo tutti. Se è esperienza di molti - come ho detto - nell'intero Movimento da
più di 50 anni, non può mancare proprio ora.

         Così, con questa unione speciale con Dio, ci caricheremo di celeste carburante e
potremo uscire nuovamente a contatto con altri fratelli e sorelle con un amore sempre più
fine, più centrato, più eccelso.

         E procederemo veloci verso il fine che ci siamo prefissi: l'unione con Dio e l'unione
con i fratelli, "finché tutti saranno uno".
         Ma tutto sta nello stimare, nell'apprezzare la perla che Dio ci ha dato: la particolare
strada per arrivare a Lui: il fratello, la sorella.

         Strada nuova, moderna, se il Papa Giovanni Paolo II ha detto che la via della Chiesa
oggi è l'uomo.$doc1776$, 'drive_import', '01776-WEB-1998-12-17-la-perla-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1776)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1777, 'ITA', $doc1777$Rocca di Papa, 22 ottobre 1998

“Perfetta letizia"

         Grazie mille di tutti questi auguri, tantissimi da tutto il mondo. Leghiamo tutto il
mondo con il nostro amore, con la presenza di Gesù in mezzo. Così ci prepariamo a un
bellissimo Natale.

Carissimi,

         fra pochi giorni sarà Natale. Un grandissimo augurio a tutti voi - ripeto. E per viverlo
bene, anzi per perfezionare la presenza sempre rinnovata di Gesù nel nostro cuore, la sua
sempre più piena nascita, ecco alcuni pensieri.

         Da quando il nostro Movimento è sorto ci è stato chiaro come il cammino spirituale,
che ci veniva indicato dall'Alto, era una via collettiva. In seguito, lungo gli anni, si è visto che
con esso si andava edificando il cosiddetto "Castello esteriore", a confronto col "Castello
interiore", frutto della via più personale di santa Teresa d'Avila.

         Ma per costruire autenticamente il "Castello esteriore" (e cioè la nostra unità con i
fratelli nella realtà del Corpo mistico di Cristo, in cui tutti siamo inseriti) siamo coscienti che
occorre il nostro sforzo per migliorare ogni giorno, con la grazia di Dio, anche la nostra vita
interiore, personale.

         In altre parole: se vogliamo perseguire, fino in fondo, una santità collettiva, di
popolo, dobbiamo sempre tendere anche alla perfezione della nostra singola persona. Che
avremmo da offrire, altrimenti, agli altri?

         Ed è su di essa che oggi vorrei soffermarmi. Sarà un semplice pensiero - come è
sempre nel nostro Collegamento -, ma forse un po' più forte, che domanda coraggio,
costanza, perseveranza.

         Per la nostra vita spirituale personale noi abbiamo già una formula che, da tempo,
pratichiamo: "Sei Tu, Signore, l'unico mio bene" (cf Sl 15,2). Essa ha effetti meravigliosi. Che
occorre di più?
         Occorre forse approfondirla un po'.

         Gesù crocifisso e abbandonato l'unico mio bene?
         "L'unico mio bene".
         E che significa?
         Vuol dire mettere in cima ai nostri pensieri, al centro del nostro cuore non tanto ciò
che ci piace, ma quello che può far male: il rinnegare noi stessi, ad esempio, con le virtù e il
prendere ogni giorno la propria croce. In pratica tutto ciò che serve per poter seguire Gesù.
         Tutto qua.
         E il resto che la vita pure ci dona?
         La volontà di Dio non esclude senz'altro che consideriamo "nostri beni" le varie gioie
che possiamo sperimentare nella vita: il calore d'una famiglia, un successo nella nostra
esistenza, qualche fortuna che càpita. E poi quei doni che sono suoi e ci manda perché li
apprezziamo: consolazioni, luce, amore nuovo nel cuore, frutti.

         Gioie di cui non è proibito godere, se stiamo attenti però a non attaccarci ai doni di
Dio, ma piuttosto al Dio dei doni - come si suol dire. E' a Lui che va tutto il nostro cuore.

         Ciò che noi affermiamo col "Sei Tu, Signore..." dice che, fra tutto quanto ci può
succedere nella vita, va preferito ciò che costa. Anzi, è proprio in esso che dobbiamo trovare
una gioia particolare.

         Chi è appassionato, ad esempio, di sport, e guarda a traguardi agognati, si sottomette
volentieri a duri allenamenti, anzi li vuole e persino li gusta.

         Chi è veramente innamorato di Dio e vuole raggiungere la perfezione, non teme di
amare ciò che facilita l'accesso a questa mèta.

         Un giorno san Francesco, veramente innamorato del suo Signore, in viaggio verso
Assisi, d'inverno, scalzo, mezzo assiderato dal freddo, spiegò a frate Leone dove era "la
perfetta gioia, la perfetta letizia".
Non stava tanto nel fare miracoli e risuscitare morti; non nel profetare e nel parlare tutte le
lingue; ma nell'essere pronti a ricevere le ingiurie dei fratelli del convento a cui erano
diretti, se avessero conservato la carità, "perché sopra tutte le grazie e i doni dello Spirito
Santo - diceva - vi è quello di vincere sé medesimi e volentieri; per lo amore di Cristo,
sostenere pene, ingiurie e disagi".

         Era lì, per lui, la "perfetta letizia".

         Proviamo anche noi. Quando ci accorgiamo che il dolore (d'una rinuncia, d'un
distacco, d'una prova, d'una malattia) si avvicina, ripetiamo con san Francesco: "Qui è
perfetta letizia", che è come dire, con pienezza di significato: "Sei Tu, Signore, l'unico mio
bene".

         Un pensiero forte, vero? e implacabile. Ma è con azioni come queste che nella vita si
può progredire, anzi volare; si può lasciare una scia luminosa e trascinare molti.

         Su, su, allora, carissime tutte e carissimi, senza paura! Dimostriamo a fatti se siamo o
no membri maturi del nostro Movimento ecclesiale, come ci vuole il Papa, cristiani autentici
della nostra Chiesa e delle Chiese. In tal modo quest'anno il Natale sarà più luminoso per
noi, più festoso. Perché è con questi atteggiamenti che la gioia in noi sarà piena e perfetta,
sarà "perfetta letizia".

         Ecco, carissimi, cosa vi auguro.$doc1777$, 'drive_import', '01777-WEB-1998-10-22-perfetta-letizia-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1777)
on conflict (document_id, language) do nothing;
