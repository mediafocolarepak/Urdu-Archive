-- 102_import_italian_originals_part04.sql (4/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1618-1637 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1618, 'ITA', $doc1618$Mollens (CH), 20.9.1984

LAVORARE CON PERFEZIONE E CON AMORE

Carissimi,

Nel mese di ottobre si vive la Parola: “Rendete a Cesare quello che è di Cesare e a Dio quello
che è di Dio” (Mt 22, 21). Occorre, dunque, dare allo Stato quello che è dello Stato.

Questa Parola non si vive soltanto pagando con regolarità le tasse che lo Stato richiede per
assicurare i servizi di cui la comunità ha necessità, o andando a votare nelle elezioni
politiche e amministrative, ma svolgendo il nostro lavoro in favore della collettività con
sempre maggior responsabilità e col massimo impegno.

Così, tutti protesi nell’attuare la direttiva del Santo Padre: “Crescete e moltiplicatevi”, se nel
mese scorso ci siamo impegnati a crescere nell’amor di Dio, che ha poi la sua verifica nella
vita di preghiera, in questo mese cercheremo di crescere, di migliorare nel modo di svolgere
i nostri lavori. È – come sappiamo – un altro aspetto della nostra vita non solo umana ma
“ideale”.

Migliorare il nostro lavoro perché con esso – di qualsiasi natura sia – si serve la comunità e
si dà anche in questa maniera a Cesare quello che è di Cesare.

E come migliorare il lavoro, i nostri quotidiani lavori? Ricordando che dietro quelle pratiche
che dobbiamo sbrigare su una scrivania, magari da soli; al di là di quel duro lavoro dei
campi a cui siamo obbligati; dietro la lezione che prepariamo o il compito che correggiamo;
al di là di quelle macchine che facciamo funzionare o di quei cibi che cuociamo; dietro quei
vestiti che dobbiamo confezionare o quei discorsi o programmi che dobbiamo stendere, ci
sono dei fratelli o meglio c’è Gesù, che ritiene fado a se tutto quanto facciamo per la
comunità o per le singole persone, e c’è ancora Lui che con la sua parola ci dice: “Rendete a
Cesare quello che è di Cesare”.

E allora, se è così, come svolgere il nostro lavoro? Non c’è dubbio: con perfezione e con
amore. Noi, del resto – lo sappiamo – dobbiamo avere un elevatissimo concetto del lavoro.
Perciò esso va fado con perfezione.

Ma anche – e questo oggi vorrei sottolineare – va fatto con amore.

Con amore. Con amore verso quel Gesù o quei Gesù per i quali lavoriamo.

Occorrerà allora tenerli presenti questi vari Gesù che vivono nei nostri fratelli, i quali
attendono magari ansiosi quelle pratiche che la burocrazia, spesso lenta, non fa arrivare;
che aspettano quel pane che nascerà dal campo che coltiviamo, l’istruzione che procurerà
loro il nostro insegnamento, il vestito che servirà, il cibo che li nutrirà, la parola infuocata
che li tiene vivi e accesi per lavorare al Regno di Dio...

E far ogni cosa in modo che tutto risulti loro utile e gradito.

Lavorare, in pratica, facendosi uno col singolo e con la collettività che dobbiamo servire.

Farsi uno: parola sempre illuminante. Farsi uno come Dio che per amore non solo s’è fatto
uno con noi, ma falegname per servire gli altri uomini da uomo e dare a Cesare quello che è
di Cesare.

Farsi uno: scendere – se si tratta di scendere – al livello dei nostri fratelli bisognosi, farsi
uno con le loro esigenze e coi loro gusti, essere loro.

Anche Charles de Foucauld, parlando dell’amore che si deve agli altri, dice: “...quando si ama
qualcuno, si è molto realmente in lui, si è in lui coll’amore, si vive in lui coll’amore, non si
vive più in se, perché non è più a se stessi che si è “attaccati”, si è “distaccati” da se, “fuori” di
se; non si vive più in se, si è in colui che si ama, si vive della sua vita ...Come il Padre vive nel
Figlio mediante l’amore e come il Figlio vive nel Padre mediante l’amore che ha per lui, così
noi dobbiamo vivere in tutti gli uomini, mediante l’amore che abbiamo per loro. E dobbiamo
amare fino a questo punto tutti gli uomini”.

Puntiamo qui allora, in questi quindici giorni: facciamo perfettamente ogni cosa. Dice
L’imitazione di Cristo: “Molto fa chi molto ama; molto fa chi fa bene una cosa”.

Che ogni opera che esce dalle nostre mani sia un capolavoro. Ma facciamola con amore: sia
essa allora cesellata dall’amore che esce dal nostro cuore controllato dalla voce della
coscienza, illuminata dallo Spirito Santo, che non manca mai di ammonirci là dove ancora
non abbiamo fatto bene le cose, o di approvarci consolandoci quando tutto è a posto.$doc1618$, 'drive_import', '01618-WEB-1984-09-20-lavorare-con-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1618)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1619, 'ITA', $doc1619$Rocca di Papa, 3.1.1985

CAMMINARE NELLA VIA DELL’AMORE

Carissimi,

Tante e tante volte, in questi Collegamenti, abbiamo parlato dell’amore, dell’amare i fratelli.

Il fatto è che noi siamo chiamati alla “via dell’amore”. Giovanni Paolo II, nella sua visita al
nostro Centro Mariapoli, ha detto che l’amore è il “nucleo centrale” della nostra spiritualità.

Il fatto è anche che l’amore ai fratelli occupa tale posto nel cristianesimo che, fatto quello, è
un po’ fatto tutto. Non adempiuto quel dovere, tutto quanto facciamo è nulla. I santi ce lo
hanno solennemente ribadito. E noi ne siamo talmente convinti che desideriamo impostare
tutta la nostra vita in quel senso.

Ora, per camminare nella “via dell’amore”, si possono intraprendere due strade. Quella di
proporsi d’amare ogni fratello che si incontra, per il quale si lavora, si prega, si vive... O
quella di amare l’Amore che per noi cristiani è tutto manifestato, tutto espresso in Gesù
crocifisso e abbandonato. Amare, dunque, Gesù Abbandonato. Ebbene, l’esperienza dice che
è meglio scegliere la seconda via. Se do a Gesù Abbandonato tutto il mio cuore, infatti, egli è
sempre lì a darmi i suoi suggerimenti per modellare il mio modo di vivere, a potare ogni mia
azione di tutto ciò che vi è di umano, a invitarmi ad abbracciare la fatica che ogni mio
dovere comporta, ad accogliere “sempre, subito, con gioia13 ogni piccolo o grande dolore,
sicché non più io viva in me stessa, ma il Risorto in me col suo Spirito sempre acceso.

Ed è questo Spirito acceso che, ogni qualvolta incontro un fratello, mi fa pronta a farmi uno
con lui, a servirlo alla perfezione, a non darmi pace finché non ho esaurito il mio dovere
verso di lui: a quell’amore cioè che – come abbiamo detto in questi ultimi Collegamenti – mi
fa “morire” per lui. È quello Spirito, Spirito d’amore, che mi fa tutto sperare dal mio fratello
per la sua crescita spirituale e la sua realizzazione cristiana; che mi dà la forza di amarlo se
in qualche modo m’è nemico, perché anche in lui mi suggerisce di vedere il Suo volto; che mi
arricchisce il cuore di misericordia per saperlo perdonare e poter capire i suoi guai; che mi
fa zelante nel comunicargli, quando è l’ora, le cose più belle del mio animo, di metterlo in
grado di camminare con più decisione nel Santo Viaggio.

Sì, ho visto, ho costatato che cammino meglio nella “via dell’amore” avendo per compagno
sempre presente l’Amore, Gesù Abbandonato. Il fatto è che la croce è il centro del
cristianesimo, anzi Gesù crocifisso e risorto è tutto il cristianesimo.
Torniamo allora a porre Gesù Abbandonato a cuore della nostra giornata, a guida dei nostri
attimi presentò Torniamo a ripetere: “Ho un solo Sposo sulla terra”. Costateremo che
cammineremo assai e vivremo in profondità la Parola che illumina tutto il mese di gennaio,
ed insegna ad esser, come Dio Padre, ricchi di misericordia per tutti.$doc1619$, 'drive_import', '01619-WEB-1985-01-03-camminare-nella-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1619)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1620, 'ITA', $doc1620$Rocca di Papa, 1.2.1985

SCENDERE PER FAR SALIRE

Carissimi,

La volta scorsa abbiamo capito con chiarezza che la nostra strada per arrivare alla santità ha
un nome: Gesù Abbandonato. Egli ci insegna ogni segreto di questo cammino ed è anche la
chiave per vivere alla perfezione la Parola di questo mese: “Sia che mangiate, sia che
beviate, sia che facciate qualsiasi altra cosa, fate tutto per la gloria di Dio” (1 Cor 10, 31).

Che significa far tutto per la gloria di Dio? Vuol dire comportarsi in modo da piacere a Lui. E
si piace a Dio osservando i suoi comandamenti, e soprattutto quello riguardante il prossimo.
Perciò questa parola potrebbe essere espressa anche così: “Sia che mangiate, sia che
beviate, sia che facciate qualsiasi altra cosa, fate tutto tenendo presente il prossimo,
facendovi uno col prossimo”.

Se si prescinde da chi ci sta vicino, non si fanno le cose per la gloria di Dio.

Farsi uno. Quel farsi uno di cui Gesù Abbandonato è il modello perfetto: Egli infatti si è fatto
in tutto simile a noi, fuorché nel peccato. Egli che era di condizione divina si è abbassato fino
a noi prendendo la condizione dello schiavo, dice Paolo (cf. Fil 2, 7-8).

Noi vogliamo farci santi. Ma spesso ci sfugge il vero senso della santità. La santità è solo
amore perché Dio, il Santo, è Amore.

Molti di noi, perché membri interni del Movimento dei Focolari, sono spesso alla direzione
di una o dell’altra branca, o d’una zona, o d’un focolare, o di uno o più nuclei, o di un’unità
gen, o anche di un’opera dell’Opera... E – come sappiamo – brucia in noi di frequente un tale
zelo perché tutto sia fatto alla perfezione, che, sembra, non ci sia che da lodare Dio.

Eppure questa posizione di responsabilità può esserci a volte d’ostacolo alla santità, come
quando pensiamo, ad esempio, che condividere coi prossimi di tutti i giorni interessi più
piccoli, ma che costituiscono la loro vita, o fatiche e soddisfazioni per mansioni umili e
nascoste, sia perdita di tempo.

Non è così di qualche padre verso il figlioletto che vuol giocare o il ragazzo che desidera fare
dello sport? Non può essere questo il nostro atteggiamento verso chi deve lavorare
manualmente, o svagarsi per riposare o trascorrere giornate nella semiattività per malattia
e vecchiaia? Gli esempi certo non mancano.
Senz’altro non dobbiamo venir meno ai nostri doveri verso l’Opera, ma dobbiamo saperli
armonizzare con quell’amore che ci fa uno fino all’estremo con chi ci sta vicino come Gesù
Abbandonato.
Non ci faremo santi perché abbiamo tanto operato, ma perché abbiamo tanto amato. E Gesù
nell’abbandono non sembra operare, non ha miracoli da compiere, né discorsi da fare. Ha il
suo corpo e la sua anima per soffrire con noi tutti lontani da Dio, e perciò per amare.
Egli lì non parlava d’amore; era l’Amore che nascondeva la sua divinità per essere come noi
miserabili. E proprio lì ha compiuto il suo più grande miracolo, la sua più grande opera: la
salvezza dell’umanità intera. Proprio lì ha fatto la sua più eloquente predica.
Dobbiamo ricordarci che anche noi non siamo chiamati tanto ad essere perfetti
organizzatori, o dirigenti... Dobbiamo essere perfetti nell’amore. Così tutte queste altre
perfezioni saranno assicurate.
E allora l’atteggiamento che dobbiamo ricordare, il verbo che non ci deve sfuggire nei
prossimi quindici giorni è questo: scendere non perché noi, in qualche maniera, siamo in
alto e gli altri in basso, ma perché il nostro io, come un pallone, è sempre pronto a salire, a
mettersi in posizione di superiorità nei confronti degli altri, a farci sentire in qualche modo
“qualcuno”.
Dobbiamo imparare ad esser niente come Gesù Abbandonato, che è disceso fino a noi, fino
ai più peccatori e poveri materialmente e spiritualmente.
È questa la forza che aiuterà gli altri a salire; è come la virtù d’una carrucola spirituale che
farà uscire i fratelli dalle angustie delle loro pene, delle loro preoccupazioni, dei loro dolori;
dai loro complessi, dai loro handicap o semplicemente uscire da se stessi per andare verso
Dio e verso i fratelli.
E questo importa: passare e far passare tutti dalla morte alla risurrezione.
Ricordiamoci: scendere, saper scendere. Essere carrucole spirituali per il mondo che ci
circonda.

Rocca di Papa, 21.2. 1985
CAMMINO A DUE

Carissimi,
Spero che abbiate saputo le ultime decisioni e cioè quelle di vedere solo in Gesù
Abbandonato la nostra strada, il nostro cammino a due. Sempre più mi rendo conto che è
quella la nostra strada. E anche, d’altra parte, studiando gli Statuti – il lavoro che devo fare
ora – vedo che già vi è sottolineata questa idea, perché lì sta scritto che noi dobbiamo
camminare per la via dell’amore, e che non si può fare unità prescindendo da Gesù
Abbandonato.

Perciò è quella veramente la strada.

L’unica cosa allora che raccomando – se posso raccomandare una cosa – è questa: tenete
sempre presente Gesù Abbandonato e cercate di tradurre ogni vostro proposito in Gesù
Abbandonato. Per esempio, oggi dite: “Io voglio vivere la volontà di Dio”, cercate di vedere il
volto di Gesù Abbandonato in questo vivere la volontà di Dio, perché senz’altro per fare la
volontà di Dio e non la nostra, bisogna rinnegarsi e nel rinnegamento di se è presente –
come noi diciamo – Gesù Abbandonato.

Un altro giorno dite: “Oggi dobbiamo riposare”. Per vivere bene il riposo bisogna
dimenticare l’apostolato, il lavoro, lo studio, dimenticare un po’ tutto. Per vivere questo
dimenticare, occorre tener presente Gesù Abbandonato.

Cerchiamo di scoprire ovunque il volto del nostro Sposo, perché ne abbiamo sposato uno
solo, e non due, e non tre. Così in tutti gli altri momenti della giornata e in tutte le decisioni
che prendiamo; in tutte le buone idee che ci vengono, giorno per giorno, per vivere la nostra
corsa alla santità, cerchiamo di scoprire Gesù Abbandonato.$doc1620$, 'drive_import', '01620-WEB-1985-02-01-scendere-per-far-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1620)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1621, 'ITA', $doc1621$Rocca di Papa, 17.1.1985

LA NOSTRA VIA

Carissimi,

Sono quattro anni ormai che abbiamo iniziato questo Santo Viaggio. Qualcuno l’ha già
compiuto ed ha portato in Cielo, come dono particolare a Maria, capo della nostra Opera, la
santità raggiunta.

Sono quattro anni e nasce in cuore il desiderio di fare un po’ di bilancio di questo tempo
vissuto, più o meno, in questa tensione.

Voltandoci un attimo indietro (col solo scopo di camminare meglio in avanti) vediamo che,
in un primo tempo, – sapendo che per farsi santi occorrono le virtù eroiche e incoraggiati da
suor Gabriella della Trappa che con tanta velocità ha raggiunto il traguardo della santità, – ci
siamo tutti impegnati nel rinnegare noi stessi, nel potare, nel tagliare, nel mortificarci,
nell’eliminare dalla nostra anima i difetti che riscontravamo.

È stato un periodo che – sono certa – ci ha procurato non poche gioie, perché da ogni taglio
fluisce la vita; il mortificare l’uomo vecchio pone continuamente su un piano
soprannaturale, dove la gioia e la pace giocano un ruolo tutto particolare.

E, perché i vizi sono stati combattuti, è stato quello un tempo in cui abbiamo costatato più in
profondità la bellezza delle varie virtù cristiane.

Poi è iniziato un altro periodo nel quale, forse perché condotti dallo Spirito, abbiamo
compreso come noi, pur essendo chiamati, come tutti i cristiani, alla rinuncia, potevamo,
anzi dovevamo raggiungere questo traguardo, non tanto puntando sulla morte del nostro io,
quanto sull’amore, sull’amare gli altri, sul “vivere gli altri”. Nell’amore avremmo trovato
implicitamente tutte le virtù.

Questa via ci è sembrata, allora, più semplice e più consona alla nostra vocazione, poiché la
maggior parte di noi vive in mezzo al mondo, a contatto continuo con i fratelli. E anche in
questo periodo abbiamo potuto notare molti frutti e godere di profonde consolazioni
spirituali.

Di tanto in tanto però ci sembra (e i pensieri del Collegamento lo stanno a testimoniare) che
il Signore ci concentri con forza su quel cardine della nostra spiritualità che è Gesù
Abbandonato.

Abbiamo l’impressione infatti che con una certa insistenza egli abbia ripetuto al nostro
animo parole di questo genere: e “Stai cercando la via, la tua via per farti santo?
Sono Io, l’Abbandonato.

Vuoi trovare il modello della rinuncia a te stesso, del taglio che chiama la vita, delle perdite
che chiamano il guadagno, delle virtù di cui puoi rivestire la tua anima e in particolare della
carità, madre e corona di tutte?

Vuoi trovare il modello di chi ha camminato per primo per la via d’una santità collettiva,
perché in croce e in particolare nell’abbandono ha trascinato con se, ha riunito gli uomini
con Dio e fra loro?

Guarda a me: a Gesù Abbandonato. È quella la tua via. La via completa in cui i tuoi sforzi
precedenti, le tue aspirazioni, trovano compimento”.

Sì, Gesù Abbandonato, che è la chiave dell’unione con Dio, è la via, la nostra via alla santità.

E allora imbocchiamo anche oggi questa strada, così come si faceva nei primi tempi, quando
per noi non c’era che Lui; quando vivere il nostro ideale significava soprattutto amare il
dolore, ogni dolore nostro e del fratello, quel dolore che comportano le virtù praticate e il
Vangelo diffuso. È perché abbiamo puntato lì che è nata una rivoluzione, che il Movimento è
esploso in quella maniera. Non c’erano difficoltà, infatti, se per l’amore di Gesù
Abbandonato ogni ostacolo diventava una pedana di lancio.

Torniamo anche oggi a Lui, unicamente. E viviamo le nostre giornate arricchendo il calice
che il sacerdote offre alla Messa coi nostri piccoli e grandi dolori. Riversiamone in esso tanti,
come continui atti d’amore a Gesù Abbandonato.

Colmiamolo a tal punto che il Signore possa dire: il mio calice trabocca.

Questo il proposito.

E vedremo progressi senza precedenti in ordine alla nostra santità personale e collettiva, e
frutti, frutti sull’intero fronte del nostro Movimento.$doc1621$, 'drive_import', '01621-WEB-1985-01-17-la-nostra-via-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1621)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1622, 'ITA', $doc1622$Mollens, 4.3.1985

CONTINUARE A GIOCARE

Carissimi,

È così recente il passaggio di Luminosa dalla Mariapoli terrestre a quella celeste, che non
posso questa volta non parlare di lei.

Ne parlo anche perché la sua vita ha tali e tante cose da dirci (e noi ne stiamo raccogliendo
molte) che non è difficile cogliere, dallo scrigno della sua meravigliosa anima, qualche
splendido gioiello.

Uno degli insegnamenti che questa focolarina d’eccezione ci lascia è quello d’un Santo
Viaggio condotto e concluso – vorrei dire – alla perfezione. Anche concluso, perché
Luminosa è ormai una maestra per tutti noi sul come un membro del nostro Movimento
deve affrontare la morte e viverla secondo il nostro grande ideale.

Quando nel settembre dell’ ’84, pensando, secondo il parere dei medici, che il male
precipitasse da un giorno all’apro, ho dovuto avvertirla della fine ormai prossima, le
raccontai di san Luigi, al quale, mentre stava giocando, fu chiesto: “Cosa faresti, se tu sapessi
ora di dover morire?”. Egli aveva risposto: “Continuerei a giocare”.

Ebbene, a queste mie parole Luminosa, abituata com’era a fare – come noi diciamo –
perfetta unità a chi le rappresentava la volontà di Dio, fissò nel suo cuore questa frase:
“continuare a giocare” che visse alla lettera, giorno dopo giorno, ora dopo ora, e non se la
tolse più dall’anima. Me la ripeteva ogni volta che la visitavo: “Io continuo a giocare, vero?”
come per avere da me un’ulteriore conferma. E quando nel mese di novembre sono andata
un po’ lontana dal Centro e non ho potuto andarla a trovare spesso, mi scriveva: “Io
continuo a giocare”.

“Continuare a giocare” significava per lei continuare a vivere le sue giornate come
focolarina, anzi con l’anima di chi sa di avere una particolare responsabilità nell’Opera,
senza attendere a prepararsi particolarmente alla morte, senza metodi speciali; significava
continuare a seguire l’Opera con tutte le sue forze. Aveva in stanza i video, le registrazioni, e
seguiva ogni corso come fosse perfettamente sana. Riceveva posta, scriveva, faceva doni,
mandava fiori, dava consigli se richiesta, anche sul piano d’Opera; godeva delle nostre gioie,
soffriva dei nostri dolori. Faceva le sue pratiche di pietà con regolarità. E, naturalmente, ma
in maniera che nessuno s’accorgeva, abbracciava i suoi guai fisici. Ma lo faceva in tale modo
da farci pensare che non soffrisse tanto, mentre si sa che altri, nelle sue condizioni, si
lamentano continuamente. Lei no: era tutta sana nell’anima e così, sembrava, nel corpo,
anche se il respiro si faceva sempre più difficile. Ma “questa è la mia vita” – affermava – e su
quel Gesù Abbandonato perfettamente amato, sicché il Risorto irradiava da lei, “continuava
a giocare”, ad interessarsi di tutto. E così fino alla fine. È morta viva, verrebbe da dire; è
morta perfettamente sana.

Sembrò modificare questo suo atteggiamento le ultime ore, quando – e qui si vede che in
pratica nulla modificò – sentendo che non poteva più ricominciare perché il respiro si
spegneva, chiese alle focolarine di far un patto, come a dire: “Io ho concluso (era il suo
“consummatum est”), ora andate avanti voi!”. E così continuava a “giocare” ed invitava tutti
a “giocare”.

Carissimi, questa è la lezione che oggi Luminosa ci fa. Questo lo slogan della meravigliosa
ascesa nell’ultimo tratto del suo Santo Viaggio.

Questa una sua eredità che ci lascia: il segreto del saper morire come Dio vuole, come Maria,
la Madre dolce, insegna a noi suoi figli: “continuare a giocare”, continuare a vivere la nostra
vita soprannaturale, senza preoccupazione alcuna del nostro futuro (anche se significa la
morte), tutti concentrati nel presente con le sue gioie, coi suoi dolori, con l’Opera da
costruire, che è Opera di Dio, che si fa di qua e si troverà di là, perché è il nostro grande atto
d’amore valevole per l’esame finale.

E allora? Cogliamo la proposta di Luminosa, aderiamo al suo patto. Lei ha concluso. Ora
tocca a noi! Nulla ci freni nel vivere pienamente, col Risorto splendente nel nostro cuore, la
nostra vita di membri di quest’Opera. Accumuleremo grazie su grazie, come si è costatato in
Luminosa, e fra queste anche la grazia di far un volo verso il Paradiso, verso il grande
incontro con Gesù e con Maria.

Ricordiamo: anche se ci avvertissero che la morte sta lì per venire, noi dobbiamo continuare
a “giocare”. E allora continuiamo a “giocare” anche in qualsiasi altra circostanza, che per
grave sia (dal punto di vista umano) è sempre meno della morte.

Continuiamo a “giocare”; sapendo che fa parte di questo gioco anche ricominciare sempre.
Siamo gli emblemi di questo ricominciare! È una parola che piace a Dio ed a Maria, che
sempre, quando si mostra su questa terra, chiede conversione. E ricominciare sempre è
costantemente convertirsi. Continuiamo allora a “giocare”, continuiamo a ricominciare.$doc1622$, 'drive_import', '01622-WEB-1985-03-04-continuare-a-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1622)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1623, 'ITA', $doc1623$Mollens, 21.3.1985

COMPIERE L’OPERA METTENDO LE BASI
CON LA COMUNIONE DEI BENI

Carissimi,
Ho detto nell’ultimo Collegamento che il nostro grande atto d’amore da portare di là è
costruire l’Opera. Per questo Luminosa ha chiuso la sua vita con una finale meravigliosa: ha
continuato a giocare e cioè ad amare, a edificare l’Opera.
Ed è ciò che dobbiamo fare tutti noi.
Non vedere nei lavori che svolgiamo, nelle preghiere che innalziamo a Dio, nell’apostolato a
cui siamo intenti, nella cura necessaria alla salute soltanto un dovere, ma scorgervi i tanti
tasselli di un mosaico; le innumerevoli manifestazioni dell’atto d’amore del quale Gesù ci
domanderà conto; vedervi parti della costruzione di quel pezzo d’Opera di cui siamo
responsabili.
Studiamo? Non facciamolo solamente per l’esame terreno, ma per edificare l’Opera.
Avviciniamo persone? Per edificare l’Opera. Assistiamo un ammalato, aiutiamo un
moribondo a concludere bene il suo Santo Viaggio? Facciamolo per edificare l’Opera.
Preghiamo a favore dei nostri passati di là? Sia per edificare l’Opera. Preghiamo anche i
nostri di là perché ci diano una mano? Sempre per edificare l’Opera. L’Opera nostra, infatti,
non ha l’ampiezza che le diamo spesso noi con le nostre vedute limitate. Essa, come la
Chiesa di cui è piccola immagine, è presente sulla terra, ma anche in purgatorio e nella
gloria.
Questo fare l’Opera era molto chiaro i primi tempi, quei primi tempi che restano per noi
come un punto fisso e luminoso.
Si era capito che anche di noi si poteva e si doveva dire, come di Gesù: “Mio cibo è fare la
volontà di colui che mi ha mandato e compiere la sua opera” (Gv 4, 34).
Questa Parola aveva una risonanza particolare nel nostro cuore. Anzitutto avevamo capito
che anche noi non dovevamo seguire la nostra volontà, non dovevamo aver progetti nostri,
ma quelli di un Altro. Ci sembrava di poter dire che anche noi eravamo, in certo modo,
mandati per fare la volontà di un Altro. Con essa, anche noi avremmo potuto compiere
un’opera. Ed è stata questa continua tensione a ricercare ogni giorno la sua volontà che ha
fatto sì che si componesse, passo dopo passo, l’Opera nostra, che nessuno fra noi prevedeva.

Sì, dobbiamo fare l’Opera. E se qualcuno fra noi non sa da dove cominciare, o se altri
desiderano rendersi più atti a questo compito, mettiamo per prima cosa le basi, tessiamo
l’intelaiatura di essa.

Lo sappiamo: ciò che sta sotto, ciò che deve essere la regola delle regole, è l’amore reciproco
con tutte le sue conseguenze, come quelle indicate dalla Parola di questo mese “La
moltitudine di coloro che eran venuti alla fede aveva un cuore solo ed un’anima sola e
nessuno diceva sua proprietà quello che gli apparteneva, ma ogni cosa era fra loro comune”
(At 4, 32).

Fermiamoci allora un po’ di tanto in tanto in questi quindici giorni, ed osserviamo tutto
quanto è nostro sia nel campo spirituale che in quello materiale, e pensiamolo come cosa
non nostra, ma della comunità, dell’Opera. È presso di noi perché lo amministriamo bene e
lo possiamo mettere a disposizione degli altri.

Cominciamo, dunque, con questo distacco totale, pronti a giocarci tutto per Gesù nei fratelli.
Questa è la base per costruire l’Opera, per continuare a giocare.

Abbiamo tante ricchezze da mettere in comune, anche se può non sembrare. Le abbiamo in
forze fisiche e intellettuali. Abbiamo affetto nel cuore da dare, cordialità da esternare, gioia
da comunicare. Abbiamo tempo da mettere a disposizione, preghiere, ricchezze interiori da
mettere in comune a voce o per iscritto; abbiamo a volte cose, borse, penne, libri, soldi, case
da mettere a disposizione, automezzi ecc.

Per chi avesse il necessario in vestiario, ad esempio, ma anche nel resto secondo il proprio
stato o l’apostolato a cui è dedito, può essere buona norma mettere in comune vestiti,
oggetti, quando ne entrassero altri dalla Provvidenza, o perché comperati, senza troppi
ragionamenti come: “Ma questa cosa mi può essere utile in tale o tal apra occasione”; perché
tutto può essere utile, ma intanto, assecondando questi suggerimenti, s’infiltrano nel nostro
cuore tanti attaccamenti, si creano esigenze continue. No, come ogni pianta creata da Dio
assorbe dal terreno solo l’acqua necessaria, anche noi cerchiamo di avere solo quello che
occorre. È meglio se ogni tanto vediamo che manca qualcosa. Meglio essere un po’ poveri
che un po’ ricchi.

Certamente Gesù non mancherà, se così faremo, di farci arrivare il centuplo, ed avremo così
la possibilità di continuare a dare.

E allora, per concludere: diamo a tutto il nostro operare il senso di compiere l’Opera di Dio,
che è il nostro grande atto d’amore.
Ma perché tutto quanto facciamo sia pienamente valido, rivediamo la nostra personale
comunione dei beni.$doc1623$, 'drive_import', '01623-WEB-1985-03-21-compiere-l-opera-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1623)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1624, 'ITA', $doc1624$Mollens (CH), 4.4.1985

MORIRE PIUTTOSTO CHE NON AMARTI ABBANDONATO

Carissimi,

Abbiamo appena vissuto il meraviglioso Genfest e stanno arrivando al Centro dell’Opera gli
echi di molti giovani da diverse parti del mondo.

Sono tutti assai positivi, come si può immaginare. Ma mi hanno impressionato di più quelli
di giovani al loro primo contatto col Movimento, credenti o più spesso indifferenti, agnostici,
non credenti...

E impressionante il gelo in cui vive la gioventù del nostro tempo. Sembrano vagare in un
deserto senza vita, senza speranza, senza calore, senza ideali, senza nulla. Scoraggiati e
rassegnati.

E la loro triste condizione mette nel cuore un ardente desiderio di fare qualcosa di più
perché la scintilla di un ideale li raggiunga, dia loro respiro, apra una strada, mostri un
avvenire. E; per questo che vorrei oggi, indirizzando queste parole a voi, a noi tutti interni
dell’Opera di Maria, spronarci a tener ancor più alta la fiamma nel nostro cuore, a sviluppare
l’incendio che tutti uniti insieme possiamo alimentare ed estendere

E perché questo avvenga, cosa dobbiamo fare?

Lo sappiamo che c’è una via segnata per noi dalla volontà di Dio. Via che dice santità e cioè
fuoco d’amore per Dio e per il prossimo; speranza, dunque, per molti nel mondo che ci
circonda: è Gesù Abbandonato scelto come unico tutto, preferito ad ogni altra creatura o
cosa, garanzia della presenza piena del Risorto in noi e fra noi.

Il Venerdì Santo scorso ci siamo senz’altro consacrati tutti a Lui. Ma oggi, viste le estreme
necessità, chiederei a voi, a noi, un altro passo.

Questa scelta deve essere radicale: Lui e nessun altro. Essere tutti suoi senza compromessi.
Esser pronti a morire piuttosto che non amarLo abbandonato. Decidere così ogni mattina ed
esservi fedeli tutto il giorno.

E dove Lo troviamo per poterLo amare?

È noto: in tutti i dolori piccoli o grandi della nostra giornata; nella fatica del fard uno coi
nostri prossimi; nel saper pazientare; nel sopprimere ogni attaccamento a tutto ciò che non
è volontà di Dio per noi nel presente; nel far tutto con perfezione e senza fretta, con
disciplina perfetta, con intenzioni soprannaturali e non semplicemente umane. Lo troviamo
nell’adempiere le nostre pratiche di pietà con raccoglimento; nel vincere i piccoli o grandi
vizi personali; nel preferirLo tra le persone che più Gli assomigliano; nel lanciarci a lavorare
per gli scopi che più Lo ricordano: l’unità fra i cristiani, con quelli di altre fedi, coi non
credenti. Lo incontriamo nello sforzo che comporta il tener vivo pure negli altri questo
amore perché il Risorto sia anche in mezzo a noi. In una parola, nel dar più valore a questa
vittoria su noi stessi che a tutto il resto della vita: nel far emergere, dunque, Lui come re
della nostra esistenza.

Carissimi, dovunque, nella nostra Opera è arrivato questo mio proposito e questa mia
preoccupazione, abbiamo cominciato a vivere così. Anzi, con un metodo che forse ci ha
suggerito la Madonna (sempre benigna e pratica), ci siamo premurati di contare ogni giorno
questi atti d’amore, sapendo che è ciò che più vale nella nostra vita, e di offrirli alla sera a
Gesù.

Ebbene, l’esperienza è stata un po’ straordinaria: abbiamo conosciuto come non mai nel
nostro animo la vera libertà: libertà da noi stessi, dalle cose, da tutto. Siamo stati inondati da
una nuova gioia: quella, credo, che è insita nel Regno di Dio, che invade i cuori poveri di
spirito.

Abbiamo avvertito che in questo modo si può dire veramente di amare Dio con tutto il
cuore, la mente e le forze, perché si elimina tutto ciò che non è sua volontà. Si può affermare
con sincerità, assieme a Paolo: “Non conosco che Cristo e questi crocifisso” (cf. 1 Cor 2, 2). Si
può ripetere senza menzogna: “Ho un solo Sposo sulla terra”. Si comprende la beatitudine di
quelli che – come Luminosa – così morti a se stessi, muoiono nel Signore: “Beati d’ora in poi
i morti che muoiono nel Signore” (Ap 14,13). Si capisce perché san Giovanni della Croce
inviti a riempire la giornata di questi atti d’amore.

Personalmente, ho compreso perché santa Teresa del Bambino Gesù dicesse che i giorni in
cui aveva più da offrire erano i suoi veri giorni di festa.

Sì, questa è la vita: “Chi vuoi venire dietro a me rinneghi se stesso, prenda la sua croce...” (Lc
9, 23).

Carissimi, proviamo ! Proviamo a vivere così, contando i nostri atti d’amore. Non certo per
inorgoglirci del numero, ma per incoraggiarci ad aumentarli. Vi sarà una vita nuova nella
nostra anima, nei nostri focolari, nei nuclei, nelle nostre unità.

Sforziamoci quindi di non barattare mai questa scelta di Gesù Abbandonato con apre, anche
se belle, buone o sante. Le gioie stesse, che Gesù ci dà, offriamole a Lui: ci vengono elargite,
del resto, perché abbiamo più coraggio nell’amarLo abbandonato.

In questo modo la Pasqua sarà continua in noi, il Risorto splendente. Saremo fontane che
irrigano il deserto del mondo, per lo Spirito che è in noi. Vedremo rinascere molti.

La via è Lui abbandonato. Non è stata la croce anche la via perché Gesù risorga?

Aggrappiamoci, dunque, allo Sposo dell’anima nostra.
Lo scopriremo presto come la perla preziosa per la quale merita vendere tutto quanto
possediamo.

In questi quindici giorni, allora, contare gli atti d’amore e offrirli a Lui.$doc1624$, 'drive_import', '01624-WEB-1985-04-04-morire-piuttosto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1624)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1625, 'ITA', $doc1625$Mollens (CH), 18.4.1985

COME ESSERE UN’ALTRA MARIA

Carissimi,

Come sapete, in quest’ultimo tempo mi sono dedicata ad una prima stesura degli Statuti
dell’Opera a cui tutti noi apparteniamo e, dovendo descrivere la sua natura, ho spiegato
quali sono le sue caratteristiche.

Essa per un verso rispecchia la Chiesa: ha affermato Giovanni Paolo II nella sua visita al
Centro Mariapoli che nella nostra Opera si scorgono i lineamenti della Chiesa postconciliare;
per un altro verso essa rispecchia Maria di cui desidera essere, nel suo insieme e nei suoi
singoli membri, una continuazione, una presenza sulla terra.

Ebbene: in questo mese di maggio appena iniziato, dedicato a Maria, mi viene
continuamente in mente questa sua seconda caratteristica e mi sembra che in nessun modo
noi potremmo onorare meglio la Madre di Dio che vivendo la nostra tipica vocazione.

Un tempo, quand’eravamo piccoli (parlo di noi persone adulte), maggio era un mese atteso,
che portava nel nostro cuore un’onda di gioia, di freschezza, di purezza, e durante tutti i suoi
trentun giorni si onorava Maria portandole fiori, abbellendo il suo altare, anzi erigendo pure
nelle nostre case piccoli altari a lei dedicati, anche se non si mancava di offrirle fiori
spirituali.

Ora, come spiega Foco in una pagina stupenda del suo diario, narrando la sua esperienza, è
soprattutto la nostra anima che deve essere il suo altare, l’altare di Maria.

E come possiamo far questo? In che maniera intronizzare Maria, far sì che Maria prenda
posto, in certo modo, nella nostra anima, come spiega anche Grignion de Montfort? Come, in
pratica, continuare con la nostra vita Maria?

Maria, lo si sa, è un monumento di carità e di tutte le altre virtù. Lo rivela nella sua
desolazione e lo cantano le sue litanie: ella è purissima, castissima, amabile, così attenta alla
voce dello Spirito Santo da esser “Madre del buon consiglio’; è prudentissima, potente,
clemente, fedele, “specchio di giustizia”, “sede della Sapienza”, “causa di letizia”, per tutti;
così mortificata in ciò che è meramente terreno da essere un “vaso spirituale”; così raccolta
da essere definita “vaso di insigne devozione”; è forte come una “torre d’avorio” e così via.

Ebbene, noi dovremmo vivere in modo tale che si possa dire qualcosa di simile anche delle
nostre persone.
Come si fa?

La risposta la conosciamo: amando Gesù Abbandonato, facendo sì che diventi realtà per noi
il “Non conosco che Cristo e questi crocifisso” (1 Cor 2, 2), per non dar valore che a Lui, a Lui
nei dolori, a Lui nei distacchi, nello sforzo che comportano le virtù, speme la carità verso
tutti i fratelli, specie i nemici, specie i più simili a Lui. Con Lui saremo come Maria, forti,
amanti, puri, amabili, prudenti, potenti, sapienti, clementi, fedeli, ecc. Ma anche come lei
saremo “rosa mistica”, perché dal nostro bocciolo usciranno tanti petali: l’amore a Gesù
Abbandonato, nostro Sposo, ci farà, infatti, madri e padri di molte anime. Saremo come lei
“casa d’oro”, “domus aurea” perché custodiremo la presenza, splendente come l’oro, del
Risorto in noi; saremo “arca dell’alleanza” perché non romperemo il patto fatto con Lui di
amarlo sopra ogni altra cosa; “porta del Cielo” per modi che per il nostro amore si
salveranno; “stella mattutina” perché come lei brilleremo nel mondo tenebroso; saremo
“salute degli infermi” perché faremo ogni cosa per sollevare chi soffre; “rifugio dei
peccatori” perché a noi s’orienteranno quando il loro cuore vorrà aprirsi; saremo
“consolatrice degli afflitti” perché porteremo gioia nei cuori ulcerati; e “aiuto dei cristiani”
per il dialogo che intavoleremo...

Molto di Maria potremo imitare con l’amore a Gesù Abbandonato. Anzi oso affermare che
quelli che si sono proposti di amare Gesù Abbandonato, assomigliano già un po’ a Maria,
almeno in alcune di queste sue caratteristiche. Non si può chiamare prudente una persona
che tace ciò che non deve dire? Forte chi amando Gesù Abbandonato vince le battaglie della
vita? Puro chi allontana per Gesù Abbandonato le tentazioni? Non si è consolatori degli
afflitti ogni volta che per amore di Gesù Abbandonato si fa sorridere chi piange, e rifugio dei
peccatori quando essi, per l’amore che portiamo a Gesù Abbandonato in loro, si sfogano con
noi?

Sì, la figura di Maria, per grazia di Dio, già sta apparendo nelle persone che amano Gesù
Abbandonato!

Ed allora non c’è che da andare avanti, in questo mese di maggio, e da continuare a contare
gli atti d’amore a Lui abbandonato, o meglio a cogliere fiori e a portarli a Maria perché li
offra a Gesù. Ci troveremo alla fine del mese, ancor più simili a lei, e avremo portato l’Opera
tutta a corrispondere meglio alla sua meravigliosa vocazione: ripetere, continuare Maria nel
mondo.

Il nostro motto sia allora: fiori a Gesù Abbandonato per essere un’altra Maria.$doc1625$, 'drive_import', '01625-WEB-1985-04-18-come-essere-un-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1625)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1626, 'ITA', $doc1626$Rocca di Papa, 2.5.1985

COSÌ MARIA DIVENTA NOSTRA MADRE

Carissimi,

Siamo ancora nel mese di maggio, e con questo Collegamento vorrei che in tutti i nostri
cuori fosse ravvivato ancor di più l’amore a Maria, madre e capo della nostra Opera.

Spesse volte, infatti, specie da membri del Movimento di altre Chiese (come quella luterana
o anglicana o riformata) mi si chiede di parlare di Maria. E sotto questa domanda si avverte
un desiderio di rapporto con lei.

Altre volte, e più spesso da parte di membri cattolici, mi si domanda che via intraprendere,
che cosa escogitare per accrescere nella propria anima l’unione con lei, per sentirsi in
pratica figli di Maria.

Proprio in questi giorni, leggendo degli scritti su Maria, mi sono resa conto della validità
dell’esperienza del Movimento in questo campo, e cioè come la nostra spiritualità possa
aprire a molti il tesoro di un’unità filiale con Maria.

n noto teologo Laurentin, in un capitolo del suo libro La vergine Maria, dice come sin dai
primi secoli venisse indicata, ad esempio, da Origene, nel III secolo, la strada per ricevere da
Gesù Maria come madre, così come l’ha avuta san Giovanni. Questa via è vivere il Vangelo.

“...Coloro, infatti – commenta Laurentin – che comprendono e vivono [il Vangelo] si
identificano a Cristo e questa identificazione permette di chiamarli, secondo san Giovanni
19, 26 “figli di Maria””.

“...I cristiani [che vivono il Vangelo] con l’aiuto della grazia agiscono in modo tale che essa
diventa la loro Madre”.

Dello stesso avviso è san Nilo nel V secolo, il quale afferma che Maria è “Madre di coloro che
vivono in modo evangelico”. Vivere il Vangelo è dunque il modo per aver Maria come madre.

Per noi è una gran gioia sapere questa cosa, che spiega l’esperienza fatta dal Movimento in
questo campo.

Chi vive, infatti, l’Ideale, il quale non è che Vangelo, avverte a un dato punto che Maria è sua
madre; affiora sul suo labbro nei confronti di lei la parola: mamma. E la forte impressione
che se ne può avere è tale da ricordare quel primo momento per tutta la vita.
Una seconda esperienza che si può fare è quella di costatare nel proprio animo quanta
differenza passi fra Maria, sentita ormai come nostra madre, e la nostra mamma terrena.
L’amore, sempre grande, perché raffinato e purificato dalla carità soprannaturale verso la
nostra mamma terrena è minimo nei confronti di quello che lo Spirito ha deposto nel nostro
cuore per Maria.

E così, con gli anni, vivendo l’Ideale con perseveranza, il rapporto con la Mamma celeste
cresce anche se fra pause e cali.

Cresce. Finché dopo anni ed anni, si avverte che è più costante; che quel qualcosa che prima
velava in certo modo il nostro rapporto con Maria (mentre magari quello con Gesù era più
deciso) scompare e Maria è tutta lì presente, di fronte alla nostra anima e possiamo
intrattenerci con lei senza più timori, come figli con la propria madre.

Se poi si continua a camminare nella via del Vangelo, Maria prende un gran posto nel nostro
cuore accanto a Gesù, come porta che s’apre su di Lui.

E quest’amore a Maria può divenire intenso, intensissimo.

Maria diventa anch’essa con Gesù e per Gesù l’amore del nostro cuore.

È l’aspirazione dell’anima, il meglio dopo Gesù a cui può attingere il cuore, il modello che ci
attrae e sempre irraggiungibile; è la dolcezza della nostra anima, la nostra (questo il
sostantivo che più le s’addice) “delizia” . Proprio così. E possono sgorgare dal cuore, anche a
Lei rivolse, quelle parole che l’amore soprannaturale fa dire a Gesù: Sono tutto tuo, sono
tutta tua, “Totus tuus” .

Poi, chissà quali apre esperienze si possono fare nei suoi confronti vivendo il Vangelo. Già si
avverte, però, che anche il passo più difficile, quello della morte, è raddolcito dalla sua
presenza là, sull’altra sponda. È Lei il porto sicuro.

E, allora, se è così, se già i primi secoli si vedeva nella vita evangelica il modo per aver Maria
come madre, non c’è che da camminare guidati dalla Parola di Vita.

Questi ultimi giorni di maggio continuiamo a raccogliere fiori: sono espressione del
rinnegamento di noi stessi e del nostro amore ed abbraccio della croce. E tutto questo è
Vangelo.

Rinneghiamo noi stessi soprattutto nell’amare i fratelli ed abbracciamo le croci che questo
amore comporta. Sono queste, del resto, le croci su cui noi siamo chiamati ad inchiodarci in
modo tutto particolare: le croci che sono insite nel Comandamento nuovo.

Poniamo allora la nostra attenzione soprattutto ad esse in questi giorni. Ci offriranno la
possibilità di un legame tutto particolare con Maria perché il Comandamento nuovo è
Vangelo, anzi il concentrato del Vangelo. E quando si possiede in cuore l’unità con Maria, la
vita è veramente un’altra cosa.
Fiori dunque per Maria, colti dall’amore reciproco vissuto.$doc1626$, 'drive_import', '01626-WEB-1985-05-02-cos-maria-diventa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1626)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1627, 'ITA', $doc1627$Rocca di Papa, 16.5.1985

RINNEGHIAMO NOI STESSI PER

LASCIAR LO SPIRITO SANTO PIÙ LIBERO D’AGIRE

Carissimi,

Per i contatti sempre vivi che abbiamo con i nostri fratelli buddhisti, sto approfondendo un
po’ in questi giorni la loro dottrina e mi sto rendendo conto di come, per aver sottolineato in
modo particolare un atteggiamento – che è anche alla base dell’autentica vita cristiana – e
cioè il rinnegamento di se, questa religione si sia diffusa così al largo nel mondo da
diventare la quarta per espansione, dopo la cristiana, la musulmana e l’induista.

II buddhismo, infatti, nel desiderio di liberare l’uomo dalla sofferenza, con il suo cosiddetto
“ottuplice sentiero” , domanda in pratica tre cose, e cioè: la moralità (con il rifiuto della
menzogna, delle chiacchiere inutili, del pettegolezzo; coll’abolizione in modo particolare
dell’adulterio, del furto e dell’assassinio); la disciplina spirituale coll’impedire i moti cattivi
e favorire i buoni, ad esempio; e infine la “retta conoscenza” delle cose e il “retto
atteggiamento” .

Domanda dunque fondamentalmente che si faccia – si potrebbe dire – morire l’“uomo
vecchio” che è in noi.

Ebbene, leggendo questo, penso cosa sarebbe il mondo cristiano e quale l’ulteriore sviluppo
della nostra religione, se ogni suo principio fosse vissuto in pienezza, ma intanto si
prendesse maggiormente in considerazione il rinnegamento di sé, quel tipico rinnegamento
cristiano che è implicito nell’amore verso Dio e verso il prossimo.

Certamente non si avrebbe soltanto una certa liberazione dalla sofferenza (e questa in modo
cristiano, naturalmente, e cioè per quell’alchimia che tramuta, per la croce amata, il dolore
in amore), ma assisteremmo ad una continua autentica Pentecoste nelle anime, ad
un’invasione dello Spirito Santo nelle menti e nei cuori

È a questo infatti che ci fa pensare la Parola di Vita di questo mese. Essa ci parla di chi è il
cristiano, di ciò che lo distingue dagli altri. Il cristiano è un figlio di Dio, perché guidato dallo
Spirito di Dio.

“Tutti quelli – dice la Parola – che sono guidati dallo Spirito di Dio, costoro sono figli di Dio”
(Rm 8,14).
Ma si sa che, perché lo Spirito Santo agisca, occorre la nostra corrispondenza, e san Paolo,
scrivendo questa Parola, pensava soprattutto a quel dovere dei seguaci di Cristo che è
proprio il rinnegamento di se, la lotta contro l’egoismo nelle sue forme più svariate, la morte
dell’“uomo vecchio”. È del resto ciò che conosciamo: l’amore a Gesù Abbandonato, che
significa sforzo per vivere le virtù anche in modo eroico, chiama una più libera espansione
dello Spirito Santo in noi. C è un legame fra la croce e lo Spirito, come fra causa ed effetto. E
noi lo sperimentiamo tutti i giorni: ogni taglio, ogni potatura, ogni no al nostro io è sorgente
di luce nuova, di pace, di gioia, di amore, di libertà interiore; e porta aperta allo Spirito.

E allora, ecco l’impegno per i prossimi quindici giorni.

Abbiamo finito di “contare” gli atti di amore, ma non di compierli.

Ora che s’è fatta un po’ l’abitudine, acceleriamo la corsa No, no, no al nostro io, per dire sì, sì,
sì a Dio.

Renderemo più libero lo Spirito Santo che è nei nostri cuori. Potrà elargirò con più
abbondanza i suoi doni; potrà guidarci, saremo riconosciuti per figli di Dio.

Rinneghiamo noi stessi questa volta, proprio per amore di Lui, di cui è da poco trascorsa la
festività.

Del resto, l’impresa che abbiamo iniziato con questo Santo Viaggio, e cioè costruire la nostra
santità, dipende da Lui. È lo Spirito Santo il Dio santificatore.

Dobbiamo divenire suoi amici.

Allora ripetiamo: rinnegarci meglio, per ospitarlo meglio nel nostro cuore.

Anzi per meglio onorarlo, amarlo, cerchiamo di meditare in questi giorni proprio su di Lui.
Ne parlano le Scritture (non dimentichiamo gli Atti degli Apostoli), ne parlano i libri di
meditazione che abbiamo.

Ma ci sono libri e libretti assai belli. Impariamo qualche preghiera rivolta allo Spirito Santo –
come il “Veni Creator Spiritus”, se non lo sappiamo –, per poterla ripetere. Insomma,
facciamo di tutto per conoscerlo meglio, amarlo meglio e pregarlo meglio.

Il Santo Viaggio di tutti noi (più di cinquantamila persone) farà un salto di qualità. E la
verità, che è nella nostra fede, sarà più conosciuta, il Regno di Dio si espanderà, e lo Spirito
Santo rinnoverà molte cose.$doc1627$, 'drive_import', '01627-WEB-1985-05-16-rinneghiamo-noi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1627)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1628, 'ITA', $doc1628$Rocca di Papa, 6.6.1985

LA CARICA

Carissimi,

Vorrei questa volta, come ho fatto spesso, parlarvi ancora della carità. Il fatto è che siamo
nel mese di giugno, e la Parola di Vita ci parla dello Spirito Santo: “Tutti quelli che sono
guidati dallo Spirito di Dio, costoro sono figli di Dio” (Rm 8,14).

Lo Spirito Santo, come sappiamo, diffonde nei nostri cuori la carità.

Se abbiamo amore quindi per lo Spirito Santo (ed è quello che ci siamo ripromessi di
intensificare con l’ultimo Collegamento), dobbiamo tener presente il dono che egli ci fa, se
non altro per non essergli irriconoscenti.

La carità è un argomento, è una realtà nella vita del cristiano che sempre mi stupisce. Forse
perché la misura con cui occorre viverla è tale che supera ogni nostra attuazione.

Così è stato in questi giorni, quando mi sono trovata sotto gli occhi le parole: Sarete così
veramente figli del Padre vostro celeste che fa sorgere il suo sole sui cattivi e sui buoni, e fa
piovere su quanti fanno e su quanti non fanno la volontà di Dio (cf. Mt 5, 45 e Lc 6, 35) – e mi
sono chiesta: Amo io veramente in modo uguale i buoni ed i cattivi? Ho lo stesso
comportamento con gli uni e con gli altri? Prego almeno con la stessa intensità e con lo
stesso amore per chi ama Dio e quindi ama anche me, e per chi è lontano da Dio e dai suoi
comandi?

E ho visto che c’è sempre da migliorare, da perfezionare.

Così, mi sono risultate nuove anche le parole: “Non abbiate alcun debito con nessuno se non
quello di un amore vicendevole; perché chi ama il suo simile ha adempiuto la legge. Infatti il
precetto: Non commettere adulterio, non uccidere [...] si riassume in queste parole: Amerai
il prossimo tuo come te stesso. L’amore non fa nessun male al prossimo: pieno compimento
della legge è l’amore” (Rm 13, 8-10). Ho compreso ancora una volta quanto è stata grande la
nostra piccola storia: la scelta di Dio-Amore; amarlo, e per questo far la sua volontà che è
amare, amarci fra noi... E m’è parsa un po’ come una ripuntualizzazione del cristianesimo,
come una sua riscoperta. Ed ho capito meglio perché quando, giovani ancora, andavamo
annunciando il nostro Ideale nelle città d’Italia, spesso il commento dei sacerdoti, dei
vescovi, di chi conosceva più a fondo di noi la nostra religione, era questo: “È cristianesimo!
È solo cristianesimo! ”.
Sì, dobbiamo esser grati allo Spirito Santo perché con il dono dell’Ideale non ci ha offerto
nulla di più, ma anche nulla di meno di una ricomprensione della nostra religione. Essa,
fondamentalmente, non è che Amore.

Vi ho incoraggiati l’altra volta a dire: No, no, no al nostro io, e: Sì, sì, sì a Dio. E come si fa a
dire sì a Dio? Inserendoci nel dinamismo della vita stessa di Dio che è Amore. La nostra fede
cristiana infatti è fede in Dio che è Amore, ma non è pura cognizione e adesione a questa
verità. Essa esige il coinvolgimento di noi stessi nell’amore di Dio. Il “noi abbiamo creduto
all’Amore” che ha caratterizzato la vita delle prime focolarine e deve caratterizzare tutta la
nostra vita anche ora, non è un fatto soltanto di fede, ma di carità. Se noi crediamo che Dio è
Amore dobbiamo amare, dobbiamo amarci l’un l’altro.

Non si concepisce, allora, un cristiano che non abbia questo dinamismo, questa carica
d’amore nel cuore.

Un orologio non funziona, non dà l’ora – e si può dire che non è neppure un orologio, ma un
ordigno di metallo – se non è carico.

Così, un cristiano che non è sempre nella tensione di amare non è una persona che merita il
nome di cristiano

E allora la conclusione: analizziamoci durante tutto il giorno: siamo nell’amore verso Dio e
cioè verso ogni sua volontà e verso il prossimo? Siamo per così dire “caricati” , abbiamo la
carica dell’amore cristiano?

Se è così, tutto andrà bene. Alla sera non avremo da costatare ed elencare errori. Chi ama
non fa il male. Ci accorgeremo di aver sempre amato Gesù Abbandonato perché con l’amore
saremo passati al di là di ogni dolore. Ci scopriremo in controcorrente con il mondo perché
avremo pensato solo a Dio e ai fratelli, mentre a quelli che amano il mondo interessa la
soddisfazione dell’io; costateremo che il cristianesimo è una religione assolutamente
positiva, affascinante, che non può non aver seguito; continueremo ad assistere a tutte le
straordinarie conseguenze che il Vangelo vissuto promette.

Sì, dobbiamo amare! Tornare lì, alla nostra piccola-grande storia. Vissuta quella, tutto è
completo, tutto è pieno.$doc1628$, 'drive_import', '01628-WEB-1985-06-06-la-carica-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1628)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1629, 'ITA', $doc1629$Rocca di Papa, 20.6.1985

PREGARE COME ANGELI

LAVORARE COME FACCHINI

Carissimi,

il mese di luglio è stato così ricco, in tanti e tanti luoghi, di attività apostoliche come
magnifiche Mariapoli e congressi.

Prima di partire da Roma, nell’ultimo Consiglio di coordinamento ci siamo ripromessi fra
tutti noi, responsabili dell’Opera al Centro, di approfondire in questi mesi la nostra vita di
preghiera.

E anch’io perciò ho ripreso contatto, durante la meditazione, con santi ed esperti in questo
campo allo scopo di vedere come possa esser giudicata la preghiera, che tutti noi già
pratichiamo, e per trovare sempre nuovi incentivi per migliorarla.

Come forse già sapete, a questo riguardo si fa una distinzione: il primo modo di pregare è
quello cosiddetto “vocale” , la “preghiera vocale” , che consiste nel parlare con Dio usando
delle formule prestabilite; un secondo e più perfetto modo di pregare è quello detto
impropriamente “mentale” , la “preghiera mentale” . Essa consiste in un colloquio
spontaneo, amoroso e frequente con Dio e perciò – come spiega Teresa d’Avila, dotata di un
particolare carisma in ordine all’orazione – “non nel molto pensare, ma nel molto amare”.

Ora, per chi cammina verso Dio in una via piuttosto individuale, la “preghiera mentale”
(questo colloquio amoroso e spontaneo) è una conquista, che può richiedere tempo, a volte
conquista sofferta ed anche non sempre raggiunta.

Per chi, invece, cammina per una via più collettiva, come la nostra (dove il Santo Viaggio
della vita si fa con i fratelli, anzi, dove si fa del fratello la strada per arrivare a Dio), mi
sembra Si possa affermare che la “preghiera mentale” (questo colloquio amoroso con Dio)
non è solo usuale, ma si conosce, almeno in certi momenti, fin dall’inizio.

E nostra esperienza, infatti, che dopo aver amato Gesù nei fratelli lungo il giorno, si trova
alla sera un rapporto più vivo con Dio; in pratica si scopre di essere da Lui amati e comincia
così a sbocciare nel nostro cuore il colloquio confidenziale con Lui, che può arrivare, col
tempo e con gli anni, a sottostare ad ogni nostra azione, ad esserne il sottofondo.

È un’esperienza – penso – di tutti noi questa, ed è una grazia veramente grande, che occorre
custodire affinché non venga meno.
Anche per noi, poi, come per coloro che camminano per vie diverse, vale il fatto che ciò che
mantiene vivo questo modo di pregare (la “preghiera mentale”, questo colloquio vivo con
Dio) è l’applicazione fedele a quei momenti di particolare preghiera che Dio domanda a
ciascuno di noi (le preghiere del mattino, della sera, la partecipazione alla Messa, la
meditazione, ecc.).

Queste preghiere vanno fatte veramente bene. E, perché ciò sia, esse – dicono gli esperti –
hanno bisogno di una preparazione remota e di una prossima.

È preparazione remota mantenersi con il cuore distaccato da tutto.

A questa preparazione – mi sembra – noi tutti siamo impegnati. Non è tutta la nostra vita
amare Gesù Abbandonato? Non parliamo forse sempre di distacchi, di potature, e
soprattutto di quel distacco che porta con se l’esser proiettati nell’amore verso i fratelli, il
vivere gli altri e non noi stessi?

Sì, questa preparazione c’è. Almeno è la nostra quotidiana tensione.

Ma occorre anche una preparazione prossima: scegliere anzitutto l’ambiente più adatto a
ciascuno di noi per pregare bene. Esso può essere la nostra stanza, una chiesa, un giardino,
in mezzo alla natura, ecc. Raccoglierci poi in silenzio e trovare anche per il corpo, che è così
legato all’anima, la posizione più indicata (in ginocchio o seduti, con le mani giunte o in altra
posizione riverente).

E una preparazione necessaria che noi, forse, dobbiamo migliorare. Essa ci consente: di far
meglio quella volontà di Dio che è la preghiera; di non sprecare la “preghiera vocale” con cui
si dicono a Gesù tante stupende cose; di mantenere vivo nel nostro cuore, anche nel resto
del giorno, il nostro colloquio con Dio.

In Cielo, dove speriamo di andare, la vita non sarà tanto apostolato, quanto lode,
ringraziamento, adorazione a Dio, Trinità Santissima. Dobbiamo imparare sin d’adesso
come si vivrà lassù.

Di questa necessità della preghiera si era consci fin dai primi tempi, quando girava fra le
prime focolarine un motto, e lo si viveva: “Pregare come angeli, lavorare come facchini”.
Anch’esso, come altri, ci è servito a portare avanti l’Ideale, a portare al largo la nostra
rivoluzione.

Essa infatti è un’opera terrena e celeste. È estendere maggiormente la Chiesa. E Gesù, che ha
fondato questa sua stupenda Sposa, si ritirava pure Lui ogni tanto per pregare, si appartava
al contatto con la natura sui monti, e lì parlava con il Padre.

Oggi – mi sembra – è fuori dubbio che noi viviamo la seconda parte del motto dei primi
tempi: “lavorare come facchini”. Sappiamo che nell’Opera gli impegni sono tanti che non è
raro il caso che alcuni siano fiaccati da un superlavoro.

Ma è compensato sempre dalla prima parte? Si prega come angeli?
Se non è così, vogliamo essere così ingrati verso Dio che ci ha aperto tanto facilmente la
comunione con Lui, che ci ha fatto dono della cosiddetta “preghiera mentale” , da non far
tutto quanto possiamo per mantenerla, approfondirla e renderla più frequente?

Durante questi quindici giorni, teniamo presenti i pensieri che vi ho comunicato. Alla fine
troveremo che spiritualmente avremo progredito. Ed è ciò che dobbiamo fare, perché chi
non avanza va indietro.$doc1629$, 'drive_import', '01629-WEB-1985-06-20-pregare-come-angeli-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1629)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1630, 'ITA', $doc1630$Montet (CH), 1.8.1985

“SONO FELICISSIMA”

Carissimi,

È appena trascorso il giorno di santa Chiara che, come è nostra tradizione, si festeggia un po’
in tutto il “mondo ideale”. Così è stato quassù, dove sono arrivati i vostri graditissimi
telegrammi, i vostri messaggi, le telefonate e i vari doni. Di tutto voglio ringraziarvi, perché
è per questa partecipazione, soprattutto, che si sente in quel giorno il Movimento intero
palpitante come un solo cuore.

Ora siamo qui, per il nostro quindicinale appuntamento.

Come sapete, il pensiero che vi trasmettiamo ha lo scopo di farci percorrere un tratto del
nostro Santo Viaggio della vita nel miglior modo possibile. Ma chi può istruirci meglio sulla
maniera di camminare lungo il corso della nostra esistenza se non chi l’ha conclusa
splendidamente?

Ecco perché questa volta vorrei parlarvi di Margrit, la nostra focolarina sposata per la quale
si sta già pregando in tutto il mondo.

Voi sapete come Luminosa resterà sempre per noi quella creatura che ci ha insegnato a
prepararci a morire o meglio a vivere per sempre “continuando a giocare”. Ebbene, Margrit
resterà, invece, nella nostra memoria come colei che ci ha “riconciliati con la morte” .

La morte, si sa, è un fatto sempre molto grave, temuto, misterioso.

Si può parlare spesso di questo oscuro passaggio, ci si può preparare ad esso per tutta la
vita, ma non mancano mai i momenti in cui lo si teme. La morte, infatti, non si armonizza
bene con la vita che viviamo, perché è una dura, ineluttabile conseguenza del peccato.

Ebbene, Margrit ci ha lasciato con la sua morte questo ineffabile dono: ha fatto sgorgare dal
nostro cuore una frase: se la morte è questa, ben venga!

È meraviglioso morire!

Ci ha, insomma, riconciliati pienamente con la morte.

Avevo seguito Margrit durante l’anno scorso, quando la sua anima era stata attraversata da
prove anche spirituali durissime, che non potevano non far pensare alle notti oscure dei
santi. Chi ne era al corrente, se non avesse conosciuto Gesù Abbandonato, avrebbe forse
commentato: ma questo è troppo!
Sono andata a trovarla, l’ultima volta, pochi giorni prima che spirasse. Era lì nel suo lettino,
ridotta ormai a pelle ed ossa coi suoi due occhioni vivi, bellissimi, che apriva e chiudeva per
l’inizio d’un sonno che preludeva alla morte. Dopo averle assicurato di tenere viva con lei, in
mezzo a noi, la presenza di Gesù, le ho chiesto: “Margrit, sei contenta?”; e lei: “Sono felice,
felice, felice!”. Poi, chiudendo e riaprendo gli occhi, ha soggiunto: “Io non ho problemi. Sono
felicissima, felicissima”.

Vistala con nel cuore tanta pienezza, le ho detto: “Tu andrai da Gesù e Maria. Mi vorrai
salutare Gesù e la Madonna anche a nome di tutta l’Opera di Maria?”. E lei: “Certo, certo”.
“Mi saluterai anche Foco e tutti gli altri mariapoliti celesti?”. E, conoscendo quanto era stata
purificata, ho aggiunto: “Pensa, Margrit, andrai in Paradiso e sarà un gran festa”. E lei: “È
incredibile!”; come a dire: “È superlativo, è troppo bello!”.

Guardandomi quindi con un sorriso splendido, che mi ricordava gli ultimi indimenticabili
sorrisi di Foco: “Sono come Gesù” – dice. “Come Gesù Abbandonato” dico io, vedendola,
come Lui, moribonda. “Sì, – risponde – ma felicissima”.

E ti mi sono resa conto di vedere coi miei occhi un fenomeno straordinario: il fenomeno del
Risorto che irradia piena vita in un corpo ridotto a nulla, il fenomeno della grazia di Dio che
sprigiona tutta la sua potenza. Mentre infatti la vita umana di Margrit, come la fiamma di
una candela si andava spegnendo, un’altra fortissima fiamma, un’altra Vita era accesa in lei
potente, luminosissima, amorevolissima: la Vita eterna. Sì, posso dire d’aver contemplato
l’esistenza della Vita eterna.

Era un fenomeno assolutamente inspiegabile dal punto di vista umano.

E mi ripetevo: così devono morire i santi! Magari toccasse anche a me, anche a noi, morire
così. La morte così è un fatto stupendo.

Quando poi, dopo aver parlato con i suoi familiari, tutti sereni per il contagio di tanta grazia,
sono tornata per darle un bacio, le ho detto: “Margrit, il Risorto è in te”. Ed era, penso, la più
bella assicurazione che potevo dare ad una focolarina.

Carissimi, Margrit ci ha dunque riconciliati pienamente con la morte.

Morire può diventare un avvenimento d’una felicità inenarrabile.

Viviamo in maniera da arrivare anche noi a quel momento con le stesse disposizioni di
Margrit, e da meritare le stesse grazie.

Ma ci riconcilieremo domani con la morte se oggi sappiamo riconciliarci con la vita, con i
suoi problemi, con i suoi dolori, con gli sforzi per vivere le virtù che ci domanda, con la
tensione ad abbracciare sempre ciò che è più difficile. In pratica, con il preferire Gesù
Abbandonato.

Margrit ci aiuti a far la sterzata, che occorre sempre rinnovare, verso la morte del nostro io
perché Cristo, il Risorto, Eva sin d ora in noi.
Se la nostra coscienza di oggi potrà assicurarci in ogni momento che il Risorto vive in noi,
domani in quel momento estremo qualcuno ce lo confermerà, e non ci sarà morte per noi: si
passerà dalla vita alla Vita.

Dunque, in questi quindici giorni abbracciamo tanto bene Gesù Abbandonato che il Risorto
splenda sempre in noi, sì da poter ripetere in ogni istante come Margrit: “Sono felicissima,
sono felicissima”.$doc1630$, 'drive_import', '01630-WEB-1985-08-01-sono-felicissima-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1630)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1631, 'ITA', $doc1631$Mollens (CH), 15.8.1985

ESSER DONO DI SÉ PER ESSERE

Carissimi,

La Parola di Vita che illumina questo mese di settembre è: “Se uno vuole essere il primo, sia
l’ultimo di tutti e il servo di tutti” (Mc 9, 35).

È una Parola che viene a proposito per noi. Chi fra noi, infatti, non ha desiderato qualche
volta in vita d’essere colui che oggi più ama Gesù, e dunque di essere il primo? Chi non ha
chiesto formalmente a Lui, spinto da un pressante invito dello Spirito Santo: “Dammi
d’amarti come nessuno ti ha mai amato”?

Ebbene, se vogliamo raggiungere questo traguardo, il modo è mettersi all’ultimo posto,
porsi al servizio di tutti. E tutto questo vuol dire semplicemente, come spiega il commento
alla Parola, mettersi sempre di fronte a ciascuno in atteggiamento di amore.

Amare, dunque, è il modo di raggiungere il primo posto. Così insegna il Vangelo ad ogni
cristiano.

Ma amare per noi significa più specificamente anche esser focolarini. La scelta iniziale infatti
dei focolarini è quella di Dio Amore.

Ho letto degli splendidi pensieri in questi giorni riguardanti Dio Amore. Hanno fatto bene
alla mia anima e vorrei perciò comunicarveli. Sono verità che conosciamo e straconosciamo,
ma è bello sentirle ripetere specie da chi non conosce il nostro Ideale.

“Dio è Amore e cioè egli comunica se stesso [...]. Egli è dono totale di se. Questa
comunicazione di se è la sua natura, dunque la sua legge vitale. Egli non esiste se non
donandosi e il dono è la sua vita. L’essere divino, dunque, è uno, non è però solo. La vita
divina è e dev’essere una società di persone”.

Dio, dunque, è uno, ma non è solo. Infatti è Trinità di persone.

Queste considerazioni mi hanno fatto pensare a come si vive nella nostra Opera, e vi ho
visto riflesso l’Ideale che abbiamo scelto: Dio Amore. Anche per noi l’amore è la nostra vita.
Anche nell’Opera, perché si ama, non si rimane soli perché l’amore genera.

E solo così siamo cristiani e siamo focolarini.
L’amore ci fa essere. Noi esistiamo non solo per amore, ma esistiamo perché amiamo. Se
non amassimo, e tutte quelle volte che non amiamo, non siamo, non esistiamo. Non siamo né
come cristiani e neppure come focolarini.

Dobbiamo dunque essere amore, vivere questa realtà in seno all’Opera, come Dio la vive in
se stesso ed è Amore. Nei focolari, nei nuclei, nelle unità, nei grappoli, in ogni forma
strutturata e in tutta l’Opera, fra tutte le branche e i Movimenti, Dio ci chiede solo questo:
esser dono di noi stessi agli altri. È l’unico debito che abbiamo, direbbe san Paolo (cf. Rm.
13, 8).

Ma come Dio è Amore oltre che in se stesso, pure fuori di se (ha infatti amato noi ed ha
mandato suo Figlio per noi), noi dobbiamo essere dono di noi stessi anche a coloro che
stanno fuori dell’Opera e anche della Chiesa, che non appartengono ad essa, che ne sono
separati dall’indifferenza, da traumi secolari, da differenze religiose, da altre culture.
Dobbiamo curarci di loro. E ci si cura bene di loro donandoci, mettendoci all’ultimo posto,
cioè amando. Anche qui allora non saremo soli. Il dono di se chiama dono ed è la conquista
dei cuori a Dio.

“Guai a chi è solo” dice la Scrittura (cf. Eccle 4, 10). Non dobbiamo intendere queste parole
unicamente nel senso che il solo è sempre in pericolo, ma che chi è solo è tale perché non
ama, non ha fatto dono di se. Guai allora a chi non ama.

In questi quindici giorni dobbiamo rivedere la nostra situazione nell’Opera, che è poi la
nostra situazione nella Chiesa.

Dobbiamo tener presente un solo proposito: esser dono di noi stessi in ogni istante.

Se saremo dono di noi ai fratelli d’Ideale incrementeremo l’unità nell’Opera, che non si deve
presupporre, ma sempre costruire.

Se saremo dono di noi a quanti in qualsiasi modo sono lontani (persone da ravvivare,
parenti, non credenti, persone che ignorano l’Ideale il quale, se è un carisma, è fatto per
tutti), l’“ut omnes” sarà più vicino.

Chiedersi allora continuamente: “Sono in questo momento dono di me stesso?”.$doc1631$, 'drive_import', '01631-WEB-1985-08-15-esser-dono-di-s-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1631)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1632, 'ITA', $doc1632$Mollens (CH), 5.9.1985

TUTTI LÌ

Carissimi,

Se ci sono due concetti, che ricorrono spesso in questi pensieri del Collegamento, essi sono:
la santità e l’amore.

Siamo, infatti, tutti uniti, in cordata, per far della vita un Santo Viaggio e crediamo che il
miglior modo di compierlo e quello di amare.

Ma è veramente amando che saremo santi?

Come si sa, il cristiano è santo già per il battesimo perché colui che è il Santo – Dio, la Trinità
SS. – abita nel suo cuore. San Paolo chiamava santi i cristiani di allora (cf. Col 3, 12; Ef 5, 3).

Ma noi, come i più del resto, per santità intendiamo un’altra cosa: la perfezione. Sono santi
coloro che hanno perfettamente corrisposto al dono del battesimo.

Ora, è proprio amando che raggiungeremo la perfezione? Nella storia della Chiesa è stato
sempre amando che i cristiani si sono fatti santi?

Se si cerca di approfondire le cose, si vede che la santità, anche se è stata sempre presentata
dalla Chiesa come la massima espressione dell’amore, non sempre è stata proposta in modo
chiaro attraverso i tempi .

Nei primi secoli, ad esempio, erano considerati santi per eccellenza i martiri. Poi, divenuti
rari i martiri (per il cessare delle persecuzioni), erano ritenuti santi i monaci, che i laici, per
essere bravi cristiani, cercavano d’imitare.

Sappiamo come un profondo conoscitore dell’epoca patristica, qual era Foco, ripetesse
spesso l’espressione del Crisostomo, per il quale un coniugato doveva vivere come un
monaco, con in meno il celibato. E allora monaci e laici vedevano la via della santità non
tanto nell’amore quanto nella fuga dal mondo e nell’attuazione dei consigli evangelici. Il
tono fondamentale perciò della loro spiritualità era prevalentemente negativo.

Nel Medioevo si continuò pure così. E, sebbene san Tommaso d’Aquino, secondo la dottrina
dei primi tempi della Chiesa – sottolineata particolarmente da Sant’Agostino –, avesse
riaffermato chiaramente che la santità cristiana sta nell’amore (e quindi può realizzarsi in
ogni stato e in ogni situazione, perché sta nei comandamenti e solo in seconda linea e
strumentalmente nei consigli), tuttavia il mondo cristiano non progredì tanto su questa
linea, preferendo un atteggiamento eccessivamente ascetico e conventuale.

Alla fine del Medioevo invece, per le nuove situazioni venutesi a creare con il Rinascimento,
si sottolinearono meno la fuga dal mondo e le penitenze fisiche, e si accentuò piuttosto la
rinuncia interiore.

É stato san Francesco di Sales a ripresentare il concetto dell’amore come principio della
pietà cristiana, e a rimettere in evidenza la possibilità della santità anche in mezzo al
mondo.

E così, piano piano, l’amore come via di santità si rifece strada.

Anche ora è così, anche se – come si sa – si sottolinea spesso esageratamente l’aspetto
orizzontale della carità. Comunque, è l’amore il principale agente della santità. Lo dice anche
il Concilio Vaticano II (cf. LG, cap. 5).

È l’amore.

E noi, che abbiamo avuto la ventura d’esser guidati sulla via della santità direttamente dallo
Spirito Santo mediante un suo particolare carisma, senza influenza da parte di nessuno,
vediamo quale strada adatta ai nostri tempi Dio ci abbia spalancato, quanto egli sia
moderno.

Questa costatazione deve darci dunque nuova lena per camminare per tale via con tutta la
speranza e con grande gioia.

Noi raggiungeremo senz’altro la santità amando

Abbiamo visto anche l’ultima volta come, per vivere la Parola di Vita, che ci invita ad
occupare l’ultimo posto per guadagnare il primo, dobbiamo amare, dobbiamo essere dono
di noi.

Che faremo allora in questi altri quindici giorni? Dobbiamo perfezionarci nell’amare,
nell’amare Dio e il prossimo. Ci sforzeremo perciò di essere dono ancor più perfetto di noi a
Dio, cioè alla sua volontà e particolarmente a quella sua volontà che ci è rappresentata
dall’amore del prossimo.

Quella carità che lo Spirito Santo ha diffuso in noi dobbiamo lasciarla penetrare in tutte le
fibre del nostro essere. Essa deve incarnarsi in noi, nel nostro cuore, nei nostri affetti. Tutto
di noi deve assumere: cuore, mente, memoria, volontà, forze. E noi dobbiamo essere
durante il giorno tUtti li, nella volontà di Dio del presente. “Tutti lì” non risparmiando nulla,
nulla, nulla per noi, perché ciò che si risparmia si perde e ciò che si perde per amore si
guadagna. “Tutti lì” allora è la parola d’ordine per le prossime due settimane: “tutti lì” nel
raccoglimento più pieno quando si prega. “Tutti lì” a condividere con i fratelli
preoccupazioni, interessi, pene, dubbi e anche gioie. “Tutti lì” nell’abbracciare Gesù
crocifisso e abbandonato nei dolori, nelle malattie e, se occorre, nella morte. “Tutti lì” nel
lavoro, nello studio. “Tutti lì” anche quando occorre curare ciò che sembra secondario, ma è
sempre un aspetto importante dell’amore come la distensione, il riposo, l’ordine. “Tutti lì”
nei doverosi distacchi che richiedono le virtù. “Tutti lì” per amare, per esser amore, per
occupare il posto degli ultimi, cioè dei primi a seguire Gesù.$doc1632$, 'drive_import', '01632-WEB-1985-09-05-tutti-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1632)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1633, 'ITA', $doc1633$Rocca di Papa, 19.9.1985

MIGLIORARE

Carissimi,

Come sapete, la grande notizia di cui vi informeremo oggi è la recente udienza con Giovanni
Paolo II. Sono stata infatti invitata a pranzo da lui perché desiderava festeggiare – così m’ha
detto – l’anniversario della sua visita al Centro Mariapoli avvenuta l’anno scorso, il 19
agosto. Durante quell’ora e mezzo benedetta in cui si è parlato di moltissime cose gli ho
rivolto, fra il resto, questa domanda: “È contento lei del Movimento?”. Egli ha risposto: “Sì,
sì. Sia ringraziato Dio perché esiste! Sia ringraziato Dio perché esiste! Quando vado in un
paese o in una città, se ci sono i focolarini, sono più... tranquillo, specie con i giovani”.

Affermava poi che nel Movimento c’è un carisma sicché, se san Paolo elencasse i carismi che
ci sono nella Chiesa oggi, direbbe: focolarini, ecc.

Il Santo Padre vede, dunque, che esiste un carisma di Dio nel Movimento.

È quindi una grazia farne parte.

È una grazia, è un talento particolare di cui dobbiamo soprattutto renderci conto noi, per
corrispondervi.

Ed è qui che vorrei fermare oggi la nostra attenzione: dobbiamo corrispondere.

Io so che noi viviamo il nostro Ideale. So che per molti di noi è tutto. Come esser sicuri,
allora, che facciamo pienamente la nostra parte per sfruttare tale grazia?

Un modo, un sistema per me tanto utile e che mi mantiene nella tensione verso la santità, è
il pensiero costante, rinnovato ogni giorno, che non posso accontentarmi di vivere come ho
vissuto ieri, ma devo migliorare.

È questa un’indicazione, del resto, che danno spesso i padri spirituali: proporsi di migliorare
sempre. Essi sanno, come anche noi sappiamo, che nella vita spirituale chi non va avanti va
indietro. Per cui è d’obbligo migliorare.

Migliorare in che cosa? Migliorare nell’amare Dio e il prossimo, nell’abbracciare Gesù
Abbandonato nei dolori e nelle fatiche che comportano le virtù, migliorare nel vivere la
Parola, ecc.

In questi quindici giorni proporrei di concentrarci nel migliorare in particolare quella
volontà di Dio che è la preghiera. Ce lo suggerisce la Parola di Vita di questo mese: "Tutto è
possibile a Dio" (Mc. 10,27). E allora, dato che molte cose sono possibili a Dio, occorre
pregare.

Nella vita spirituale bisogna fare gran calcolo dell'aiuto di Dio, molto più di quanto in genere
non si faccia. E' Dio che compie la parte più importante. Per non rischiare di fallire,
confidando solo nelle nostre forze, dobbiamo quindi pregarlo perché ci mandi la sua grazia.

E come migliorare nella preghiera? Alla preghiera del mattino e della sera, o alla recita del
rosario facciamo precedere qualche secondo di silenzio, per renderò conto davanti a chi
siamo e assumere così nello spirito e nel corpo l’atteggiamento e la posizione più giusta e
rispettosa.

Preghiamo possibilmente di fronte ad un’immagine che aiuti il nostro raccoglimento e la
nostra devozione. Pronunciamo le parole lentamente, senza fretta, in modo da poterle far
nostre e mettervi tutto il nostro cuore. Costateremo ben presto che una preghiera lenta e
ben fatta è leggera, non porta noia perché unisce l’anima con il suo Dio nel momento
presente; mentre una preghiera affrettata e sciatta appesantisce il cuore. Ogni volta poi che
ci distraiamo, dobbiamo rimetterci in unione con Dio, con Gesù, Maria e i santi.

Appena terminata la preghiera, attendiamo pure qualche secondo prima di congedarci dal
nostro divino Interlocutore. Non parliamo d’altro in chiesa o, se proprio lo si deve,
facciamolo sottovoce.

Ma molto spesso si tratta di preghiera spontanea come nella meditazione, o durante la
Messa, o nella visita al SS. Sacramento. Anche in questi casi prediligiamo i momenti di
silenzio, non solo per disporci nel migliore dei modi a tale colloquio, ma anche per poter
ascoltare interiormente quelle che possono essere le risposte della SS. Trinità che abita in
noi, di Gesù o di Maria.

Poi parliamo noi, confidiamo a Dio, a Gesù, a Maria le nostre cose più segrete, diciamo loro
quanto li amiamo, o li vorremmo amare; di quanto aiuto abbiamo bisogno; quali sono le
nostre difficoltà, le nostre speranze, i nostri progetti. Chiediamo sempre lo Spirito Santo.
Abituiamoci insomma ad un colloquio aperto con gli abitanti del Cielo.

Se tutto ciò è in qualche momento impossibile, perché ci troviamo attanagliati da spiegabili
o inspiegabili aridità, ci sarà sempre la possibilità di parlare a Gesù Abbandonato e di
abbracciarlo in questi dolori spirituali. L’importante è non venir mai meno alla preghiera.
Essere fedeli, quale che sia lo stato della nostra anima.

In questi quindici giorni migliorare dunque, nei modi che ho detto, e in quello che a noi tutti
sembra più utile.

Migliorarci nella preghiera!

I primi cristiani, che avevano colto fresco fresco il messaggio di Gesù e ne conoscevano le
esigenze, davano una grandissima importanza alla preghiera. Noi dobbiamo imitarli.
Così saremo degni del dono dell’ideale, il nostro cammino nel Santo Viaggio sarà spedito, ci
attireremo tante grazie, non deluderemo né Dio, né il Papa.

Migliorare. Che questo verbo, che questa tensione diventi per noi un’esigenza, un’abitudine,
un pungolo nella nostra vita spirituale senza cui non possiamo più vivere. Allora saremo
all’altezza di quello che dobbiamo essere e cioè membri dell’Opera di Maria, del nostro
Movimento, nel quale il Santo Padre ripone tanta speranza.$doc1633$, 'drive_import', '01633-WEB-1985-09-19-migliorare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1633)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1634, 'ITA', $doc1634$Rocca di Papa, 3.10.1985

SUPERARE

Carissimi,

Con ottobre è incominciato un nuovo “anno ideale”. E giacché di tanto in tanto dobbiamo
fermarci per vedere come procediamo nel Santo Viaggio, penso che anche questo sia un
momento indicato. Con il Santo Viaggio, come si sa, si tende alla santità. Ma si tende
veramente alla santità se questa è una meta sperata. Occorre infatti vederla possibile per
lanciarci alla sua conquista. E penso che questa speranza sia nel cuore di tutti noi.

Tuttavia vi può essere sempre fra noi qualcuno che non la vede proprio così. Forse perché
pensa troppo ai peccati della vita passata o alla lentezza con cui ha corrisposto fin qui. C’è
perciò pericolo che si stia rassegnando ad una vita mediocre...

È un grave errore.

In qualsiasi situazione noi ora ci troviamo dobbiamo esser certi che ce la faremo. Ci sono tre
motivi che incoraggiano: anzitutto la Parola di Vita del mese: “Tutto è possibile a Dio” (Mc
10, 27). Poi i santi. Quelli infatti che vediamo canonizzati non sono sempre stati così.
Ricordiamo san Girolamo che, curvo sotto il peso dei propri peccati, s’è sentito dire dal
Signore: “Dammi i tuoi peccati”. Pensiamo a un Sant’Agostino, a una beata Angela da
Foligno, a sant’Ignazio di Loyola, alla stessa Teresa d’Avila che, pur non essendosi macchiata
di peccati mortali, ha avvertito per tutta la vita il peso della sua iniziale incorrispondenza.

E poi c’è un terzo motivo che ci fa sperare: sono i nostri fratelli e sorelle che ultimamente
hanno concluso il Santo Viaggio. Molti di essi, infatti, ce l’hanno fatta, la conclusione della
loro vita è stata stupenda. E non parlo solo di Luminosa e di Margrit, ma di altri meno
conosciuti a noi ma non a Dio. Chi li ha seguiti da vicino mi ha assicurato che questi passaggi
meravigliosi alla Mariapoli Celeste non sono eccezioni nella nostra Opera.

Ce l’hanno fatta, perciò potremo farcela anche noi.

Dobbiamo aver fiducia, e non veder altro futuro per noi se non quello di diventare santi,
strumenti di Dio per la salvezza di molti. Questo è certamente ciò che Dio vuole da noi. Tutto
il resto è pensiero nostro, progetto umano, nostra impressione.

Ma come fare per raggiungere tale livello? Intanto, ogniqualvolta lo sconforto ci prende,
perché ci pare impossibile raggiungere la meta della santità, anziché fermarci, dobbiamo
dire a Gesù che lo ringraziamo, perché lavora a scavare le fondamenta dell’umiltà nelle
nostre anime, premessa necessaria alla santità; dobbiamo dirgli che siamo felici perché
nulla ci importa di più, in ogni momento della vita, che vederci simili a Lui abbandonato; che
non cambieremmo questi momenti con nessun altro perché è Lui che ci importa, Lui che
abbiamo scelto.

In questo modo il Risorto prende spazio dentro di noi e con Lui la certezza che, anche a
nostra insaputa, egli ci sta strappando dal tran tran di una vita cristiana sì, ma tiepida, per
portarci nelle sfere del suo fuoco. Riaffiorerà così in noi la speranza di poter diventare santi,
anzi grandi santi per il bene di molti; e con maggior fiducia tutto faremo confluire a questo
fine: gioie, dolori, conquiste.

Ho letto un libro in via di pubblicazione sul nostro viaggio in Asia nell’81, il primo anno del
nostro Santo Viaggio, e ho potuto costatare con quale slancio ci eravamo incamminati verso
la santità.

È nato così nel mio cuore il desiderio che l’anno che stiamo iniziando sia come quello – e
ancora migliore. Il fatto è che timoniere della nostra nave era Gesù Abbandonato. Non si
vedeva che Lui, non si possedeva che Lui.

Se dobbiamo attenderci molto da Dio, perché tutto è possibile a Lui, e qui è la nostra
speranza, dobbiamo però fare anche la nostra parte.

Il mio invito allora è che ci rimettiamo al seguito di Gesù Abbandonato. Egli mostra come il
cristianesimo non è stasi, ma dinamismo. Gesù Abbandonato non si sofferma nella
situazione in cui si trova, ma supera tutto: supera l’impressione e la tentazione di essere
abbandonato da Dio, supera la sensazione di nullità, di vuoto in cui è travolto; supera la
paura, l’angoscia, il dubbio che l’attanagliano, la debolezza che sente, la sfiducia che lo ha
invaso, la distanza dal Padre suo che avverte, e vive tutte le virtù nella maniera più eroica.

Così dobbiamo fare anche noi al suo seguito: superare ogni dolore accettandolo sempre,
subito, con gioia; vivere con il massimo slancio tutto ciò che ci chiede la voce dello Spirito
nel nostro cuore.

Superare, superare, superare. Andare al di là. Ricordarci che il cristianesimo è dinamismo
perché è amore.

“Superare” è la parola d’ordine per questi quindici giorni, per rimanere incamminati nella
via della santità.

Rocca di Papa, 17.10. 1985

TENIAMO GESÙ IN MEZZO
Carissimi,

“Amare Dio [...] e amare il prossimo [...] val più di tutti gli olocausti e i sacrifici” (Mc 12, 33).
Così ci ammonisce la Parola di questo mese. E noi sappiamo che il modo concreto di amare
Dio è amare il prossimo. Perciò l’amore del prossimo vale più di tutti gli olocausti e i
sacrifici.

Forse ora si capisce perché il nostro Movimento ha tante benedizioni dal Cielo e perché
conosce tanta provvidenza di Dio. Perché esso ha centrato ciò che più vale: l’amore e in
particolare l’amore del prossimo; e ha fatto dell’amore la sua via a Dio, il suo fine. La
perfezione della carità è infatti il nostro scopo.

Poi, abbiamo anche un fine specifico: concorrere a realizzare il Testamento di Gesù, e perciò
aprirci a tutti i dialoghi. Ma tutte queste attività hanno senso per noi sulla base dell’amore al
prossimo.

Amare il prossimo. Qualcuno può obiettare: questo è il fine generale di tutte le opere nella
Chiesa. Certamente. Ma anche se l’amore del prossimo è lo scopo generale di ogni famiglia
religiosa, noi – giacché lo Spirito Santo plasma le sue opere con infinita fantasia – abbiamo
un nostro tipico modo di amare il prossimo, un modo tutto nostro per piacere quindi a Dio,
più che se offrissimo olocausti e sacrifici.

Amiamo il prossimo fino a raggiungere con esso l’unità. Dobbiamo amare amandoci fra noi,
dobbiamo amare nell’unità, dobbiamo avere quindi Gesù in mezzo a noi.

Gesù in mezzo a noi, l’unità, è il nostro modo di vivere per essere veri membri del
Movimento dei Focolari. Quando i primi tempi ci chiedevano se non avevamo pensato di
portare un distintivo (allora era in uso nelle associazioni cattoliche), noi dicevamo che il
nostro distintivo era l’amore reciproco e che, se qualche volta ci fossimo trovate senza
questo amore, ipso facto non ci sentivamo più di appartenere al Movimento dei Focolari.

Sì, è così: è questo distintivo così squisitamente evangelico che deve distinguere noi
focolarini. E allora non sarà male fare qualche considerazione su questo nostro dovere.
Siamo ora, oggi, nella più perfetta unità con quanti nel Movimento conosciamo?

Se la nostra risposta è sì, ringraziamo Dio e stiamo certi che tutto quanto facciamo – anche
di piccolo, di piccolissimo – come lavare i piatti o dare una scopata alla stanza, come
sorvegliare i bambini o fare la spesa, come leggere un libro o fare un passeggiata, persino un
nostro sorriso, una mossa, un sentimento... tutto, tutto ha valore. A maggior ragione
lavorare per l’Opera, tendere a realizzare le molteplici sue attività. Non dice forse Paolo che
la carità dà valore a tutto?
Se la nostra risposta è no, il nostro primo dovere è quello di fare tutto per ricomporre
un’unità annebbiata, o peggio, incrinata o rotta.

Lo Statuto dell’Opera, dove è descritta la vita di tutti gli interni di essa, ha una premessa che
è la norma delle norme, senza la quale tutte le altre non hanno valore. Questa premessa dice
che occorre stabilire anzitutto la presenza di Gesù fra noi con il mutuo amore.

Carissimi, lo so che vi sto dicendo cose semplici, ma esse sono sommamente impegnative.
Guai a me se non le dicessi! Mancherei al primo dovere che Dio mi ha affidato.

E guai a voi se non fate di tutto per realizzarle! Sono richieste dal carisma che vi ha
investito.

C’è in quel nucleo, in quell’unità gen, in quel Centro del Movimento, in quella famiglia-
focolare una situazione di stasi? Manca la luce di Gesù in mezzo, l’ardore di cui Lui infiamma
i cuori, l’entusiasmo dei primi giorni? Diciamocelo con franchezza, incolpando anzitutto noi
che non siamo stati vigilanti nell’amare. Lasciamo ogni altra attività per stabilire dapprima
la presenza di Gesù in mezzo. Fatto questo è fatto tutto. Ed è urgente farlo, è doveroso. Fate
nascere Gesù fra voi ed egli vi farà rivedere lo splendore della sua Opera, vi prenderà per
mano e vi dirà come camminare, vi ridarà il fascino della divina avventura che avete
intrapreso in suo nome.

Costa questo lavoro? Ma non ci siamo forse consacrati più volte a Gesù Abbandonato, decisi
a prendere sulle nostre spalle soprattutto le croci delle unità non perfette per far trionfare il
Risorto fra noi? Non abbiamo visto e seguito Lui abbandonato proprio perché chiave di ogni
unità? Ora recalcitriamo perché questo dovere ci costa?

No. Sono certa che mi capite e che lo farete.

Dio lo esige, la Madonna lo vuole. Vivere con Gesù fra noi è dar corpo al Movimento. È
mantenerlo vivo.

E voi lo volete così il vostro Movimento

S’avvicina Natale. Non sarà forse opportuno preparare sin d’ora un bel regalone a
dimensioni mondiali (dato che il Movimento è in tutto il mondo) da donare a quel Bambino
che è venuto in terra proprio perché tutti siano uno?

Cominciamo sin d’ora a ridare nuova luce alle nostre esistenze, ravvivando la sua presenza
fra noi.

Lo scopo del Santo Viaggio che stiamo compiendo insieme è quello di farci santi. Ma non
arriveremo mai a questo obiettivo se non facciamo in modo che il Santo sia fra tutti noi.

È perché c’è stato Lui e per quel tanto che c’è stato Lui, che certi nostri mariapoliti celesti
sono passati di là come santi.
La parola d’ordine allora per i prossimi quindici giorni: stabilire Gesù in mezzo con quanti
vivono con noi l’ideale. Vivere in maniera che quando ci salutiamo venga spontaneo dirci:
“Teniamo Gesù in mezzo”.$doc1634$, 'drive_import', '01634-WEB-1985-10-03-superare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1634)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1635, 'ITA', $doc1635$Rocca di Papa, 6.11.1985

ASCOLTARE LA VOCE DELLO SPIRITO

Carissimi,

Vi penso tutti – anche perché me ne avete dato conferma in molti – nella tensione di
preparare il “regalone” per Gesù Bambino. Natale s’avvicina e vorremmo che in quel giorno
la presenza di Gesù in mezzo a noi, in ogni struttura o realtà del Movimento, fosse assai
cresciuta. Abbiamo capito, infatti, una volta di più, che noi non siamo nati come Movimento
primariamente per i grandi scopi dell’Opera, che del resto ci affascinano e per i quali
avverto anch’io giorno dopo giorno grazie tutte particolari, ma per essere perfetti
nell’amore, nella carità.

Vorrei, quindi, anche questa volta spendere una parola perché raggiungiamo meglio questo
scopo generale del nostro Movimento, con il quale possiamo veramente stabilire e
mantenere la presenza di Gesù in mezzo nei focolari, nei nuclei, nelle unità gen, in tutte le
nostre comunità.

Essere perfetti nell’amore. E per raggiungere questo scopo – lo si sa – essere ogni giorno più
perfetti, perché “chi non va avanti va indietro”. Avere verso il prossimo che ci passa accanto
una carità sempre più raffinata, sempre più squisita.

Ma quale il miglior mezzo per raggiungere tale obiettivo?

Io non ne vedo altri che quello di aver cuore, mente, forze puntati verso Gesù Abbandonato
in un desiderio sempre rinnovato di amarlo; di amarlo nei dolori inevitabili d’ogni giornata,
nella pratica delle virtù, nelle mortificazioni che, come cristiani e membri dell’Opera, siamo
chiamati a praticare. È con questo amore, è – come noi dinamo – con l’andare al di là della
piaga sempre in ogni momento, che il Risorto può vivere luminoso in noi, che il suo Spirito
può rompere ogni catena del nostro io. E se lo Spirito è libero in noi, egli può espandere
meglio la carità che è diffusa nel nostro cuore proprio da Lui.

Sto facendo l’esperienza in questi giorni che, cercando di vivere con il Risorto nel cuore, la
voce di Dio si ingigantisce dentro di me ed è quella voce che mi guida nei rapporti che devo
intavolare con chiunque, sia o no della Chiesa o del Movimento.

Quante volte direi forse una parola in più o una in meno, se non ascoltassi quella voce tanto
sonora, minacciando di compromettere il dialogo coi buddhisti, così ben nato e così
promettente.
Sì, la carità, che è una partecipazione alla vita divina, non possiamo improvvisarla noi,
dobbiamo attingerla da Dio e dal suo Spirito. Allora, nell’ascolto e nell’obbedienza alla sua
voce, il piano di Dio si snoda magnifico e maestoso. E mentre questo si realizza, l’unità fra
noi s’approfondisce, cresce, e il “regalone” diventa sempre più una realtà che s’avvicina.

Carissimi, abbiamo un ideale straordinario, divino. Leggendo i messaggi che mi arrivano da
tutto il mondo, il mio animo è preso da commozione: quanta grazia in tutte le nostre anime,
quale abbondanza Dio vi ha versato! Piccoli e grandi nel Movimento sono tutti ripieni del
carisma di Dio! Veramente non sappiamo quello che abbiamo. O meglio lo sappiamo:
abbiamo Gesù, il Figlio di Dio in noi e in mezzo a noi, che vive e domina dove la carità è
regina. E allora, affinché siamo sempre più così, affinché questo miracolo d’amore che è il
Movimento nostro sia sempre più una realtà, ributtiamoci ad amare Gesù Abbandonato
perché il Risorto splenda nel nostro cuore. La parola del suo Spirito si farà potente in tutti
noi e potremo essere sempre più perfetti nell’amore, piacendo sempre più a Dio, a Maria, ed
essendo sempre più atti a servire la Chiesa. Ricordiamo questo trinomio: Gesù
Abbandonato, il Risorto, ascoltare la voce dello Spirito. Così saremo per tutti l’espressione
della carità di Dio.$doc1635$, 'drive_import', '01635-WEB-1985-11-06-ascoltare-la-voce-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1635)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1636, 'ITA', $doc1636$Rocca di Papa, 21.11.1985

CRESCERE E SOVRABBONDARE

Carissimi,
C’è una Parola in questo mese, veramente favolosa, che aiuterà molti di noi.
Non si può infatti negare che, pur con tutta la buona volontà, il viaggio verso la santità non è
sempre facile.
Anzi, non sarebbe nemmeno nella normalità delle cose se di tanto in tanto esso non fosse
accidentato da qualche inconveniente, da qualche tentazione, da qualche impressione di non
farcela. Tocca a tutti, e non dobbiamo meravigliarci. La stessa vita dei santi è un susseguirsi
di prove.
Per noi poi che, per la maggior parte, viviamo in mezzo al mondo, è ancor più nella logica
delle cose.
Il mondo – lo sappiamo – pur nelle sue innegabili bellezze, che meritano tutta la nostra
attenzione e il nostro apprezzamento (per il suo progresso, per le sue culture, per le sue
scoperte e le ricchezze di natura e d’invenzioni umane), è un pericolo numero uno per il
cristiano. È l’ambiente in cui Satana domina con le sue lusinghe, le sue seduzioni, le sue
attrattive, le sue offerte perverse. E il cristiano che vi vive è chiamato giorno per giorno ad
andare controcorrente, a prender le distanze, a difendersi. Né sempre vi riesce Si scatenano
allora lotte interiori e, perché no?, persecuzioni esteriori provenienti da chi non la pensa
come noi. Per cui verrebbe da cedere, da lasciar andare, da istradarsi nella via della
mediocrità.
Ma non si può. Non si deve tradire Gesù che di tanta gioia ha colmato i nostri cuori per quel
poco che abbiamo corrisposto. Anche se a volte verrebbe da dire basta, si vorrebbe
abbandonare la lotta, sentiamo di non poterlo fare.
A cosa aggrapparsi per non naufragare? A quale medicina, a quale rimedio possiamo
ricorrere in questi momenti che tutti possiamo attraversare?
Il rimedio sta nella Parola di questo mese. Straordinaria, favolosa veramente. Io ho provato
a metterla in pratica e mi sembra – direbbero i santi – il “sanatotum”, ciò che risana tutto.
L’ha scritta san Paolo ai Tessalonicesi, giovane comunità che minacciava di venir meno sotto
la persecuzione. Egli non ha trovato rimedio migliore da suggerire ad essa che questo:
crescere e sovrabbondare nell’amore vicendevole e verso tutti.

L’amore reciproco quindi e l’amore verso tutti.

L’Apostolo sapeva che con l’amore reciproco Gesù sarebbe stato in mezzo a quei cristiani
tentati di cedere, e che, se fedeli nell’amare gli altri, il Signore sarebbe stato nel loro cuore.
Perciò afferma, e questa è la Parola: “a Signore vi faccia crescere e abbondare nell’amore
vicendevole e verso tutti” (1 Ts 3, 12).

“Crescere e abbondare” .

Carissimi, ecco il rimedio anche per quelli fra noi che stanno attraversando momenti
difficili.

Ecco una Parola per tutti noi che nei vari momenti della giornata siamo sempre nella
possibilità di calare di tono.

Provate. Provate a crescere e a sovrabbondare nell’amore. Anch’io, prima di scrivere questo
Collegamento, ho provato e mi sono trovata assai bene. Ho avuto l’impressione che questa è
una Parola che va nel più profondo del nostro cuore. È il nostro stesso carisma. E
incoraggiarci in essa è toccarci veramente sul vivo.

Provate intanto a crescere nell’amore reciproco coi fratelli d Ideale, e costaterete come è
dolce farlo. Si tratta a volte d una parola in più, d’un sorriso in più, di un’attenzione in più, di
un dono che non avremmo fatto.

Provate a concentrare la vostra vita unicamente su questo crescere e sovrabbondare e
risentirete scorrere nuova vita nella vostra anima, mentre le paure, i dubbi, i blocchi, i freni,
le tentazioni, semmai ci fossero, impallidiranno.

È una Parola questa che opera il miracolo della nostra continua rinascita: il Risorto brilla
sempre più in noi per una fede più viva, una speranza più sicura, una carità più ardente. In
essa è la vita.

Provate e vi sentirete in linea. Le mortificazioni, le penitenze che pur dobbiamo fare per
amare il nostro ideale, Gesù Abbandonato, sono implicite in questo crescere e
sovrabbondare, e sono quindi tipicamente le nostre.

Ma non limitiamoci ad amare solo quelli che condividono con noi l’Ideale. Amiamo tutti.
Questo esige il Vangelo.

Cresciamo e sovrabbondiamo nell’amore anche verso ogni fratello, e in pochi minuti – ve
l’assicuro – anche chi si sente sconfitto riacquisterà fiducia, si risentirà in viaggio verso la
meta con lo stesso entusiasmo dei primi giorni.

C’è il regalone poi da preparare per Natale. Quale migliore Parola poteva toccarci?
Vorrei augurarvi ed augurarmi con il cuore di Paolo che la nostra comunità sparsa in tutto il
mondo cresca in questo mese e sovrabbondi di carità, così da far felice veramente Gesù in
Cielo, e da fargli dire: Questo è il più bel Natale da quando sono nato sulla terra.

E allora, perché ciò si realizzi ricordiamo: crescere e sovrabbondare nell’amore.$doc1636$, 'drive_import', '01636-WEB-1985-11-21-crescere-e-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1636)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1637, 'ITA', $doc1637$Rocca di Papa, 5.12.1985

ESPERIENZA DI DIO

Carissimi,

Come sapete, ho fatto ultimamente quella forte esperienza di Chiesa che è stato il Sinodo.Su
come sia andato il Sinodo, sui suoi contenuti, sulle conseguenze che dovremmo trarne anche
noi, come Movimento, sarete informati nel corso dell'anno.

Questa volta vorrei accennare ad un’altra esperienza parallela che ho fatto in quel periodo.

Siamo stati in Vaticano due settimane e ogni giorno ho incontrato cardinali e vescovi che mi
hanno espresso il loro apprezzamento per il nostro Movimento. I due terzi infatti dei
presenti lo conoscevano. Ho avuto modo così, di vedere l’Opera nostra veramente come
Opera di Dio: estesa su tutta la terra, così maestosa, così bella (alcuni usavano parole
superlative nel descriverla), così radicata ormai nella Chiesa, che mi è parsa come una
gemma dell’albero della Chiesa in questo secolo. E ho avuto la netta sensazione che fosse
ben al di là di ogni nostra immaginazione, che superasse soprattutto noi, anche tutti noi
messi insieme. Mi è parso, infatti, di capire come le nostre persone fossero poveri e semplici
strumenti di quest’Opera, come pennelli o gocce di colore, e di contemplare ed ammirare in
essa il quadro stupendo che il vero Artista-Dio aveva composto

Ma perché, carissimi, la nostra Opera è tanto bella? Che cosa ha di specifico che la rende così
accetta ai Pastori della Chiesa, per cui essi la sentono come propria?

Credo che il motivo stia qui: quest’Opera di Dio è stata concepita dallo Spirito Santo in modo
tale che mette le persone in contatto con Dio, le pone in condizione di fare l’esperienza di
Dio.

Quando, abbracciata la croce, siamo invasi dai doni dello Spirito che sono pace, luce, amore,
gioia... non è forse Dio, Gesù, il Risorto che noi sperimentiamo e che gli altri vedono in noi?

Quando è in atto l’amore reciproco non è forse Gesù vivo, presente in mezzo a noi, che
sperimentiamo? E non è forse in Lui che si imbattono coloro che s’accostano a noi,
facendone a loro volta l’esperienza?

Ma è proprio perché si fa questa esperienza di Dio, diretta o indiretta, che anche persone
lontane accolgono, quasi senza ragionare, come cosa logica, tutto ciò che sta dietro questa
esperienza: la vita cristiana con tutte le sue esigenze, la Sacra Scrittura con i suoi comandi, i
Sacramenti, la Chiesa con la sua Gerarchia, ecc. Tutto accettano di ciò che in fondo ha
funzione strumentale per avvicinare gli uomini a Dio, per far fare loro l’esperienza di Lui e
del suo Regno.

E, giacché tutto di cuore è accettato e fatto proprio, i Pastori avvertono come i membri
dell’Opera sono “uno” con la Chiesa, mentre costatano la sua potenza apostolica anche sul
mondo ateo e secolarizzato, e ne sono contenti, sono soddisfatti e benedicono.

E noi, a nostra volta, per le loro benedizioni siamo sommamente consolati. Ci sembra, infatti,
ed è vero, che, se il Santo Padre e i vescovi sono contenti di noi, è Gesù stesso che è contento.
Mentre in caso contrario non lo sarebbe.

E allora, se la Chiesa approva benedicendo il nostro agire, che conclusione dobbiamo trarre?
Che indirizzo dare alla nostra vita? È ovvio: essere (come ci dicono molti suoi
rappresentanti) noi stessi, vivere la nostra vocazione con sempre maggiore totalitarietà.

E perciò in questi giorni di dicembre che ci restano dobbiamo incarnare ancora meglio la
Parola del mese, così nostra, così centrale nella nostra spiritualità, ma che non si esaurisce
mai: crescere e sovrabbondare nell’amore reciproco e nell’amore verso tutti.

Stare ancorati ad essa come alla nostra salvezza, come alla chiave che apre la nostra santità.

Certamente, durante i primi quindici giorni l’amore sarà cresciuto in noi. Ma la Parola ci
chiede di crescere ancora e sempre, anzi di sovrabbondare, e cioè di non misurare nella
carità fraterna e in quella verso tutti.

Facciamo così, e il regalone a Gesù Bambino sarà una realtà. Auguro a tutti: amore, amore,
amore, e che con l’amore possiate far sperimentare al mondo Dio che è Amore.$doc1637$, 'drive_import', '01637-WEB-1985-12-05-esperienza-di-dio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1637)
on conflict (document_id, language) do nothing;
