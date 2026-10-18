-- 102_import_italian_originals_part10.sql (10/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1738-1757 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1738, 'ITA', $doc1738$Rocca di Papa, 22 dicembre 1994
1995
Noi e la televisione
Carissimi,

         se con la spiritualità collettiva siamo tutti impegnati a costruire il "castello
esteriore", non è meno vero che, proprio per realizzare questo scopo, è nostro dovere
mantenere vivo ed alimentare continuamente anche il "castello interiore".

         Se è volontà di Dio, infatti, per noi perseguire una spiritualità collettiva, non è detto
che non dobbiamo conseguire anche la perfezione dell'individuo.

         Il "di più" che la spiritualità collettiva esige e cioè, la reciprocità e la consumazione
nell'unità, può essere attuato proprio perché è assicurato un "di meno".

         Così è nostro dovere fra il resto praticare la mortificazione personale.
         La mortificazione. Noi dobbiamo viverla. La mortificazione degli occhi, ad esempio,
sempre quando occorre: per strada, di fronte a qualche rivista, alla televisione, ecc.
         Soffermiamoci oggi ad approfondire in particolare la mortificazione necessaria di
fronte alla televisione.
         Ho già parlato di questo argomento e di quello che deve essere il nostro
comportamento di fronte ad esso.
         Ma occorre e occorrerà ripeterlo.
         Con la televisione il mondo è spesso lì pronto per catturarci con le sue immagini
immorali, con i suoi bassi pensieri, con le sue violenze, con le sue trame indegne della
persona umana e ancor più del cristiano.

         C'è anche chi si sforza a fare del bene attraverso la televisione ed offre programmi
puliti e pensieri sani. Ma il male è sempre più del bene e sproporzionato al bene.

         Noi siamo membri del Movimento dei focolari e quindi tutti protesi nella tensione
alla santità, alla perfezione.

         E santità significa "separazione", separazione dal mondo in cui Dio ci ha voluti e
messi. Dobbiamo essere, sì, "nel mondo", ma non possiamo essere "del mondo".
         E la televisione è spesso il mondo in casa e in grande stile; che penetra persino nel
santuario delle nostre famiglie; che entra anche fra le immagini della pubblicità e si attesta
in ore in cui persino i bambini lo possono vedere.

         Ora, per essere quelli che dobbiamo essere, occorre fuggire da "questo" mondo,
dobbiamo separarcene. E lo possiamo fare con la mortificazione.

         Ci fu un buddista un giorno che visitò una nostra cittadella, e rimase scandalizzato
che lì, dove si stava perseguendo la perfezione, si potesse guardare la televisione.

         E spesso in Oriente presso le grandi Religioni si pensa così.

         E' un dovere per noi tener spenta quasi sempre la televisione ed usarla solo nella
sicurezza che nulla d'impuro o di cattivo o di violento possa, per essa, penetrare nella nostra
anima.

         E' un dovere fra il resto non solo perché siamo cristiani e focolarini, ma anche
perché uno dei nostri grandi scopi è avvicinare proprio i fedeli di altre Religioni e mostrare
loro il cristianesimo nella sua purezza.

         Sono, infatti, Teresa di Gesù e Giovanni della Croce che, con la loro tensione al
"nada", alla totale mortificazione, impressionano di più, positivamente, quei popoli.

         E allora come comportarci per essere certi che la televisione sia solo uno strumento
di bene e non di male?

         Parlando ai focolarini qualche anno fa - data la loro consacrazione a Dio - ho chiesto
in pratica di "perdere" la televisione, di rinunciarvi generosamente. E l'hanno fatto. Ora li
riinvito ad attenersi a quanto allora si era detto.

         E' logico che i telegiornali si possono vedere, anzi, vivendo noi in mezzo alla società,
si devono vedere.

         E' logico che i programmi religiosi sono utili, oltre che permessi; che tutto quanto
riguarda la cultura, o la scienza, o lo sport, o la natura può aiutare anche come distensione.

         E' vero che esistono pure, rari in verità, programmi possibili, buoni, per le famiglie e
per bambini ...

         Ma a tutto il resto, quasi sempre inquinato dal male, occorre saper rinunciare.

         I nostri occhi non possono vedere certe cose; devono mortificarsi. Pena un arresto
nella via della perfezione, del Santo Viaggio.

         Dice Giovanni della Croce che ad un uccellino non occorre tanto per essere legato
alla terra: basta un tenue filo per impedirgli di volare.
         Così succederà anche a noi, anche se mettiamo in pratica tutti i nostri doveri, anche
se usiamo con diligenza tutti gli strumenti della nostra spiritualità collettiva, ma non
sappiamo tagliare il filo che ci lega al mondo, attraverso la televisione.

         Vedremo ora, ciascuno, come comportarci nelle singole situazioni.

         Vedremo anche di comunicarci l'un l'altro le nostre esperienze, chiedendoci aiuto a
vicenda, imparando così gli uni dagli altri.

         E coraggio! Perché occorre coraggio oggi per operare questo taglio. Coraggio! E Dio
ci illuminerà sul come fare senza portare troppo turbamento in famiglia o fra gli amici della
nostra comunità.

         Ma, se occorre, bisogna sopportare pure questo.

         Non ha anche detto Gesù che non è venuto a portare la pace, ma la spada?

         La sua sequela esige pure questo.$doc1738$, 'drive_import', '01738-WEB-1994-12-22-noi-e-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1738)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1739, 'ITA', $doc1739$Rocca di Papa, 26 gennaio 1995
La nostra penitenza
Carissime,

         abbiamo parlato la volta scorsa di quell'aspetto della penitenza che abbiamo in
comune con le spiritualità individuali: la mortificazione. E ci siamo soffermati in particolare
su quella degli occhi che dobbiamo praticare anche di fronte alla televisione.

         I molteplici fax, che mi sono arrivati in seguito, mi hanno dato sicurezza che quel
pensiero era stato recepito in profondità e con una tale serietà che non immaginavo: segno
che moltissimi fra voi hanno avvertito un pericolo, forse prima sottovalutato, che può
compromettere anche gravemente il nostro cammino sulla via della spiritualità collettiva. Di
qui gli innumerevoli propositi presi spesse volte insieme, per liberarci con intelligenza e
decisione da questo subdolo strumento.

         Oggi parliamo della nostra tipica penitenza.

         Quando Gesù spiega che cosa deve fare l'uomo per poterlo seguire, dice: "Rinneghi
se stesso" perché in ognuno spesso vive l'uomo vecchio. Occorre perciò rinnegarsi e lasciar
vivere l'uomo nuovo.

         Ma poi aggiunge: "Prenda la sua croce".
         Bisogna, dunque, prendere la croce, anzi la "propria" croce.
         Sì, perché ogni uomo ha la "sua" croce misurata dall'amore di Dio sulle spalle di
ciascuno.

         Come sappiamo, all'inizio del cristianesimo si pensava che il Signore chiedesse di
portare una croce simile a quella di Gesù. Ed ecco l'idea e la gioia del martirio.

         Più tardi, alla fine delle persecuzioni, era ritenuto un martirio anche il consacrarsi
alla verginità.

         Lungo i secoli poi, mano mano che si penetrava la vita e la passione di Gesù, con la
sua agonia nell'orto, con il suo sudore di sangue, la sua flagellazione, la crocifissione con le
sue piaghe, ecco un fiorire incredibile delle più varie penitenze per "prendere" la propria
croce.
         Finché si arriva ad oggi. E, per noi, alla contemplazione della piaga più nascosta, più
misteriosa, più terribile: quella manifesta nel grido d'abbandono di Gesù che rivela l'infinita
sua desolazione nel sentirsi abbandonato dal Padre, oltre che dalle creature.

         Gesù soffre così perché ha preso su di sé la separazione degli uomini da Dio e degli
uomini fra loro, e tutte le divisioni del mondo.

         Ora è proprio questa la croce che il carisma dell'unità ci ha indicato, sin dall'inizio
del nostro cammino, come propriamente nostra.

         A questa croce dobbiamo guardare, questa dobbiamo abbracciare anzitutto in ogni
circostanza dolorosa della vita.

         Ma quest'atteggiamento lo abbiamo un po' in comune con chiunque vive una
qualsiasi spiritualità individuale.

         Dove, allora, trovare la nostra tipica croce, croce particolare?

         Negli uomini, nei nostri fratelli e sorelle disuniti da Dio e tra loro.

         Sono, infatti, gli uomini, con tutto il loro bagaglio di abbandono, la particolare croce
che il Signore ci chiede di portare.

         Ponendo quella in spalla, giorno per giorno, abbiamo accesso alla sequela di Gesù.
Altrimenti per noi quest'avventura è chiusa.

         E i primi fratelli che noi dobbiamo amare in tal modo, nei quali dobbiamo ravvisare
il volto di Gesù Abbandonato, sono quelli che ci stanno più vicini, che vivono con noi.

         Dio, dunque, non ci chiede un martirio cruento, non dobbiamo tanto flagellarci,
portare il cilizio, fare lunghe veglie e digiuni, dormire per terra..., ma accogliere sempre nel
nostro cuore il fratello o i fratelli, con tutte le loro pene, le loro aridità, le loro prove, i loro
limiti, i loro difetti, e far di tutto per ridonare pace, fiducia, amore, ardore.

         Perché, lo sappiamo, se il fratello, quando c'è l'unità, è causa di una gioia divina per
tutti, quando soffre e non sa più amare, è un peso per tutti.

         Ma è la cosa più preziosa in cui possiamo imbatterci. E' l'incontro con Gesù
crocifisso e abbandonato, Colui per cui viviamo, e cui abbiamo donato la vita, che abbiamo
scelto con predilezione e a volte in maniera esclusiva.

         Accoglierlo, porci in spalla la sua croce, è il nostro modo di amare il nostro Amore, è
l'espressione più genuina della nostra penitenza.
         Ma - come sappiamo - nel nostro Movimento non troviamo Gesù Abbandonato
soltanto in chi vive con noi o vicino a noi. L'Opera è fatta in maniera tale che siamo chiamati
a caricarci dei pesi di molti altri fratelli e sorelle. Sono a volte quelli che soffrono per i disagi
in cui si dibatte oggi il mondo dei giovani, o quello degli adolescenti, o della famiglia, o della
società in ogni suo campo; il mondo ecclesiastico e religioso nelle sue varie espressioni...;
sono cristiani con i quali condividiamo molte verità, ma non tutto. E ciò è motivo spesso di
sofferenza. O persone di altre fedi e non credenti in cui il volto di Gesù Abbandonato è, in
modo seppur diverso, più evidente.

         Ora poi che, in seguito agli avvenimenti di Trento, tutta l'Opera si è sentita chiamare
a fare uno scatto in avanti e a disporsi, ad aprirsi al servizio della Chiesa nella sua globalità,
al Centro e nelle diverse diocesi, o della società civile in tutte le sue espressioni, Gesù
Abbandonato sta lì ad aspettarci nelle molteplici necessità, ma soprattutto in quella carenza
spesso di armonia, di concordia, di unità a cui può portare rimedio proprio il nostro
carisma.

         Non dobbiamo spaventarci venendo a conoscenza, magari attraverso sondaggi, dello
stato di salute della Chiesa di cui facciamo parte o della situazione civile del mondo in cui
viviamo. Crediamo che Dio è con noi e che, se ci indica una méta, ha già in serbo le armi di
cui possiamo servirci.

         Così vivendo bene ogni giorno, nell'Opera in ogni suo angolo, dove siamo posti, noi
abbiamo la possibilità non solo di servirla ma di fare penitenza, quella penitenza che Dio
vuole da noi. Ed assolvere così un nostro importantissimo dovere cristiano.

         Carissime, l'Ideale è grande. Di per sé è Dio stesso.

         Ma anche nella sua applicazione pratica sembra ci superi di gran lunga. Ma con noi -
se siamo fedeli - è Colui che ha detto: "Ho vinto il mondo" (Gv 16,33).

         A Lui dirigere i nostri passi come ha fatto finora, svelarci il suo programma, aiutarci
a compierlo.

         Viviamo allora in questo mese, con immenso amore, la penitenza che Dio ha pensato
per noi, espressione anch'essa o strumento della nostra spiritualità collettiva.$doc1739$, 'drive_import', '01739-WEB-1995-01-26-la-nostra-penitenza-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1739)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1740, 'ITA', $doc1740$Rocca di Papa, 16 febbraio 1995

"Saluto di Chiara dopo il pensiero del Collegamento"

Carissime,

         le nostre focolarine dei mass-media vogliono che io dica qualche cosa per chiudere
questo Collegamento.

         Be', voi sapete tutte, perché vi è stato detto, dove sono proprio in questo momento,
mentre voi siete lì radunate ad ascoltare il Collegamento.

         Quello che vi chiedo perciò è pregare un po', fare un piccolo "consenserint" perché
tutto vada avanti, e anche questo sia un passo innanzi nell'amore di Dio, nel costruire la
nostra Opera.

         Io sono lì, con i nostri Vescovi amici del Movimento dei Focolari, per salutare, per
ossequiare, per parlare col Santo Padre e sentire la sua parola nei confronti dei nostri
Vescovi e anche, forse, del Movimento.

         Sapete, poi, che in questi giorni e precisamente martedì prossimo partirò per
Istanbul. Quello che vi chiedo anche qui è la vostra preghiera. So che ne vengono tante,
anche offerte di tante sofferenze da diverse parti del mondo. E io vorrei in questo momento
ringraziare veramente tutti. Non mi aspettavo neanche questo concorso, in questo viaggio,
da parte di tante persone.

         Quando tornerò vi aggiornerò nel prossimo Collegamento di come sono andate le
cose. Intanto voi vivete perfettamente il nostro Ideale e soprattutto questa nostra penitenza
di cui abbiamo parlato oggi.

         Ciao, pope, arrivederci a tutti; salutatemi tutti i popi e tutti gli interni del nostro
Movimento.
Il Papa per una spiritualità comunitaria
Carissimi,

         come forse già sapete, o come verrete a conoscere tra poco nelle notizie che vi
comunicheremo, un gruppo di settanta Vescovi, amici del nostro Movimento, è stato
recentemente ricevuto in udienza dal S.Padre, che ha rivolto loro un breve ma
interessantissimo discorso1.

         Interessantissimo per noi soprattutto, perché il Papa parla della spiritualità
comunitaria o collettiva così come la vede lui, che, in fatto di dottrina, è quello che è.

         Sono certa di far cosa gradita a tutti voi nell'analizzare insieme questo brano del
S.Padre.

         Dopo aver espresso la gioia d'incontrare questo gruppo di Vescovi, dopo aver
accennato all'indimenticabile nostro mons. Klaus Hemmerle e ringraziato il card. Miloslav
Vlk per le parole rivoltegli, e dopo aver fatto cenno alla "spiritualità focolarina" - così la
chiama - che rafforza la collegialità affettiva ed effettiva dei Vescovi col Papa e dei Vescovi
fra loro, il Santo Padre afferma che una spiritualità comunitaria o collettiva è "un aspetto
costitutivo della vocazione cristiana" (è cioè della natura stessa della vocazione cristiana),
perché - egli dice - "Il Signore Gesù non ha chiamato i discepoli ad una sequela individuale,
ma inscindibilmente personale e comunitaria".

         E basterebbe questa prima affermazione per giustificare in pieno la nostra
nuovissima spiritualità e magnificare Dio che, dandocela, ci ha chiamati, ognuno, a seguirla.
Ma poi il Papa continua: "E, se ciò è vero per tutti i battezzati (quindi - commento io - la
spiritualità comunitaria è buona per tutti, è universale), vale in modo particolare per ... gli
apostoli ed i loro successori, i Vescovi".

         Più avanti egli dà alla Chiesa la definizione che usò il Concilio nella Lumen
Gentium,1: "icona della Santissima Trinità", "mistero di comunione e sacramento di unità"
per cui "la comunione tra i membri della Chiesa è il primario (e cioè il primo: 'ante omnia'-
diremmo noi) ed il principale segno (vale quindi più del predicare) che essa offre perché il
mondo possa credere in Cristo".

         E qui il Papa approva in pieno il modo da noi da sempre usato per l'irradiazione o
l'apostolato: essere anzitutto uno fra noi.

         Perché - afferma lui - "essere uno in Cristo è la prima e permanente forma di
evangelizzazione attuata dalla comunità cristiana". "Prima" - dice - e noi l'abbiamo sempre
detto; e "permanente forma". Come capiamo bene noi focolarini quest'espressione: essere
cioè uniti 24 ore su 24!

         Giovanni Paolo II continua poi passando a dire che "il nostro tempo esige una nuova
evangelizzazione" che per lui è sinonimo di "rispondere a questa originaria vocazione
personale ed ecclesiale (cioè comunitaria): formare in Cristo, 'un cuor solo e un'anima
sola'(At 4,32)". Dunque per il Papa evangelizzare è: essere un cuor solo e un'anima sola.

         Per cui - continua - "un rinnovato annuncio del Vangelo - sono parole sue - non può
essere coerente ed efficace, se non è accompagnato da una robusta spiritualità di
comunione...".

         L'annuncio, la parola è per il Papa "coerente" solo se prima si vive l'unità; ed è
"efficace" solo se prima si vive l'unità.

         E noi di tutto ciò ne sappiamo qualcosa.

         Dunque, senza vantarci vanamente di essere così in sintonia con il pensiero del
Vicario di Cristo, sentiamoci estremamente grati della spiritualità comunitaria che il Cielo ci
ha dato e che è, come il Papa la definisce, "robusta", robusta perché poggia sul più grande
dolore di Gesù, l'abbandono.

         Che dobbiamo fare allora davanti a tanto amore di Dio, a tanta predilezione?

         Impegniamoci nuovamente a vivere questa spiritualità con tutto l'ardore, ad
approfondirla - come invita il Papa a fare alla conclusione - usando tutti gli strumenti che
conosciamo, senza trascurarne nessuno.

         Così - come ha augurato il S. Padre ai Vescovi - con "la spiritualità dell'unità", "nella
prospettiva del Giubileo del 2.000", ci prepareremo "a meglio cooperare con lo Spirito
Santo, divino lievito dell'unità del Popolo di Dio e dell'intera umanità", noi diremmo:
coopereremo al mondo unito.

         In questo prossimo mese, per rispondere al dono di queste parole dette ai Vescovi (e
indirettamente anche a noi) dal S. Padre, rivediamo uno per uno gli strumenti della nostra
spiritualità collettiva e mettiamoli in pratica, sicché diventino presto un'abitudine. Serve
moltissimo (e forse è indispensabile) stabilire nel nostro programma i giorni in cui vengono
praticati.

         Mi arrivano notizie dei frutti meravigliosi che porta la nostra spiritualità collettiva.
Essa ha cambiato spesso il volto di brani della nostra Opera.

         Abbiamo una vita sola. Tendiamo al massimo suo rendimento per la gloria di Dio e
per il Paradiso di molti.$doc1740$, 'drive_import', '01740-WEB-1995-02-16-saluto-di-chiara-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1740)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1741, 'ITA', $doc1741$Rocca di Papa, 23 marzo 1995
La preghiera individuale e le condizioni per la sua efficacia

Carissime,

         andiamo, dunque, avanti con tutto l'amore del cuore nella via della nostra
spiritualità collettiva che tanti frutti d'ogni genere sta portando ovunque.

         E, perché ciò sia, approfondiamo oggi un aspetto importantissimo, che abbiamo in
comune anche con ogni altra spiritualità individuale. Si tratta della preghiera personale. Ne
abbiamo parlato altre volte, ma non se ne parla mai abbastanza.

         Perché voglio fare della preghiera il tema del nostro odierno Collegamento?
         Perché in questi ultimi tempi ho desiderato conoscerla più a fondo ed ho costatato
quale utilità questo studio può portare alla nostra anima.
         Ho attinto, come al solito, alla Scrittura, ai Padri ed ai santi ed ora vorrei - a mo' di
comunione d'anima - parlarne con tutti voi.
         Fra il resto, mi ha fatto bella e profonda impressione il noto libretto di sant'Alfonso
M. de Liguori, intitolato: "Il gran mezzo della preghiera"1. Questo santo, Vescovo e dottore
della Chiesa, ne aveva lui stesso tale stima che avrebbe desiderato che tutti lo conoscessero.

         E' di lui il famoso detto: "Chi prega sicuramente si salva; chi non prega sicuramente
si danna".

         E non intendeva dire genericamente: chi recita, ad esempio, il Rosario od altro, si
salva, ma specificatamente: chi prega per la propria salvezza sicuramente si salva. Per
sperare di salvarsi, che è la condizione prima per potersi poi santificare, occorre pregare.
Infatti affermano santi e teologi: "La grazia della fede ci viene data gratis, ma quella della
perseveranza in essa occorre chiederla".

         Gesù ha detto: "Chiedete e otterrete" (cf Mt 21,22).
         Si possono ottenere, e si ottengono in realtà, anche grazie materiali. Gesù, infatti, è
così magnanimo che dice "Qualunque cosa chiederete.." (Gv 14,13), quindi anche queste, ma
se servono e non ostacolano la salvezza dell'anima.
         Quando Dio non ci ascolta vuol dire che, proprio non ascoltandoci, ci fa una grazia
superiore.

         Gesù dice: "Chiunque chiede riceve..." (Mt 7,8). Dunque sia il giusto, sia il peccatore.
"Supplichi anche il peccatore - dice san Gregorio - e il suo gemito salirà a Dio".

         Piuttosto non tutte le preghiere ottengono perché non vi sono le dovute condizioni,
che sono soprattutto tre.

         La prima sarebbe l'umiltà. Occorre essere umili per ottenere. "Dio resiste ai superbi,
ma dà la grazia agli umili" (Gc 4,6).

         La preghiera di un'anima umile penetra i Cieli, e presentandosi al trono divino, non
parte di là senza che Dio la esaudisca. E, per quanto peccatrice sia quest'anima, Dio non la sa
disprezzare (cf Salmo 50,19), perché è umile.

         La seconda condizione è la confidenza, l'aver fede di ottenere, il credere, l'essere
certi.

         Scrive san Basilio: "Non hai ottenuta la grazia perché l'hai domandata senza
confidenza", senza fede.

         Per Davide la nostra confidenza in Dio deve essere ferma come un monte, che non si
smuove ad ogni soffio di vento (Salmo 124,1).

         Ed è ciò che disse Gesù: "Tutto quello che domanderete al Padre, abbiate fede
d'averlo ottenuto e vi sarà accordato" (Mc 11,24).

         L'ultima condizione è la perseveranza. Ne è una conferma la parabola di quell'uomo
insistente che fu esaudito perché continuò a chiedere.

         Per san Girolamo le nostre preghiere, tanto più sono accette a Dio quanto più sono
"perseveranti e importune".

         "Dio vuole, dunque - dice Cornelio a Lapide - che noi siamo perseveranti nella
preghiera fino ad essere importuni". Gli uomini in genere non possono sopportare gli
importuni, ma Dio non solo li sopporta, ma, nel domandargli le grazie, li desidera tali. E san
Gregorio: "Dio vuol essere invocato, vuol essere costretto, vuol essere vinto da una certa
importunità dalla quale non è offeso, ma addirittura placato".
         "Né basta, dice il Bellarmino, chiedere la grazia della perseveranza una volta, o
poche volte; dobbiamo cercarla sempre, in ogni giorno sino alla morte, se vogliamo
ottenerla".

         Ottima cosa e quasi indispensabile è chiedere poi per intercessione di Maria
Santissima. Diceva sant'Antonino: "Chi chiede senza il suo aiuto, presume di volare senza le
ali".

         Compreso tutto questo, cosa dobbiamo fare? Aggiungere, per ottenere la nostra
salvezza, altre preghiere a quelle che già facciamo? No.

         Cerchiamo anzitutto di sentire profondamente e di sottolineare nel nostro cuore
certe parole che diciamo perché, senza forse renderci conto, lo facciamo già, già chiediamo
queste cose.

         Ad esempio, in ogni "Ave Maria" che recitiamo, diamo importanza a quel "prega per
noi peccatori ora e nell'ora della nostra morte".

         Il "Pater noster", specie in tutta la prima parte (ma anche nella seconda), è una
richiesta di grazie proprio per la nostra e l'altrui salvezza: "Venga il tuo Regno; sia fatta la
tua volontà..."

         La "Salve Regina" - provate a recitarla - è tutta incentrata solo sulla richiesta di
salvezza: "e dopo questo esilio mostraci Gesù". Prima si fanno tanti complimenti alla
Madonna e poi si dice: "E dopo questo esilio mostraci Gesù".

         E così via.

         Carissime, siamo in un tempo in cui la mentalità moderna vorrebbe cancellare
persino l'idea del peccato e quindi della necessità di essere salvati, proprio oggi mentre
l'uomo compie anche peccati mai visti sulla faccia della terra, come il drogarsi, il ledere la
natura, i genocidi, ecc.

         Il fatto è che non si vuol pensare all'esistenza dell'Altra vita, la più importante,
quella che non finirà.

         Invece c'è. Noi lo sappiamo. Noi che col nostro Ideale, con Gesù in mezzo a noi, ne
viviamo sin d'ora veri e propri anticipi.

         Il salvarsi o il dannarsi sono cose serie che non tramontano. E, se Dio era giusto ieri,
quando si parlava di queste cose, è giusto anche oggi.
         Perfezioniamo, allora, cominciando dal prossimo mese, la nostra preghiera secondo
le tre condizioni. Sono facili a ricordare: l'umiltà (pregare sentendoci zero), la fiducia
(credere a tutti i costi: è così e basta!), la perseveranza (essere importuni), e facciamo
nostro il detto del santo che abbiamo menzionato: "Chi prega (chi chiede queste cose),
certamente si salva; ma chi non prega certamente si danna".$doc1741$, 'drive_import', '01741-WEB-1995-03-23-la-preghiera-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1741)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1742, 'ITA', $doc1742$Rocca di Papa, 27 aprile 1995
Maria e la spiritualità collettiva
Carissimi,

         spero che abbiamo messo in pratica i suggerimenti offertici dall'ultimo
Collegamento sulla preghiera e che ne abbiamo tratto i frutti, soprattutto per quanto
riguarda la nostra salvezza e santità.

         E mi auguro pure che abbiate ricevuto - altrimenti la riceverete presto - la mia
lettera agli "interni" sull'"Azione straordinaria" in favore dei 5.000 e che abbiate già pensato
come attuarla.

         Questa volta vorrei rispondere ad una domanda che di tanto in tanto mi viene posta
e suona così: "Come Maria viveva la spiritualità collettiva?"

         Si suppone, infatti, che la nostra Opera animata da tale spiritualità possa trovare in
Maria sua Capo, sua Regina, sua Condottiera, un modello.

         Ed è certamente così.
         In quanto poi a poterlo dimostrare non è del tutto facile. Si sa troppo poco di Maria.
Ma, se la si ama almeno un po', si può forse intuire qualcosa.
         Cerchiamo di farlo.

         Maria può aver vissuto la spiritualità collettiva con Giuseppe, con Gesù, con gli
Apostoli e con l'apostolo Giovanni.

         Con Giuseppe.
         Nel rapporto col suo sposo terreno Maria ha avuto un privilegio unico che
permetteva e garantiva una spiritualità collettiva: c'è sempre stata fra i due la presenza di
Gesù. Ed è tutto detto. Quella presenza illuminava, dava senso, consolidava, rendeva
profondissimo, manteneva assolutamente soprannaturale il loro rapporto.
         Maria parlava poco - penso. E' scritto, infatti, che "conservava tutte queste cose
meditandole nel suo cuore" (Lc 2,51). Ma ciò non determinava certamente una mancanza di
comunione fra i due. Non diciamo forse anche noi che, nella nostra comunione d'anima,
l'amore ed il dolore vanno taciuti mentre la luce va data? Si suppone dunque che Lei, se non
ha manifestato a Giuseppe gli abissali misteri che avvenivano nel suo cuore, non abbia mai
privato Giuseppe della luce della sua straordinaria esperienza specialmente dopo che il
Cielo, attraverso qualche suo messaggero, svelava a lui ciò che doveva sapere.

         Maria e Gesù.

         Non ci fu mai sulla terra - noi pensiamo - rapporto più simile a quello che intercorre
fra le Persone della Santissima Trinità di questo.

         Che cosa si saranno detti nei trent'anni della vita privata di Gesù? Non si sa e non lo
si può sapere. Siamo troppo poco puri, poco trasparenti per potere anche solo intuire i loro
colloqui.

         Qualcosa piuttosto si sa del periodo della vita pubblica di Gesù. In essa Gesù ha
avuto non di rado un atteggiamento verso sua madre forse poco comprensibile da noi. Si
può supporre quanto l'amava, ma in quel tempo, con la sua predicazione, con i suoi miracoli,
con la fondazione della Chiesa, era tutto intento ad instaurare la grande famiglia di Dio, la
fratellanza universale per la quale ogni rapporto umano con madre naturale, fratelli, padre
ecc. andava posposto, quando non esigeva la "spada".

         Per cui Gesù era nella necessità di darne il primo esempio trattando a volte sua
madre in maniera un po' forte, come quando la chiamava "donna" o spiegava come sua
madre, suoi fratelli sono piuttosto coloro che fanno la volontà di Dio.

         Ma Maria non rimaneva sorpresa. Comprendeva e condivideva le preoccupazioni del
Figlio che la strappava continuamente alle altezze della volontà di Dio.

         Ed anche così il loro era un rapporto, una comunione: come - se si vuole - quella che
passa fra persone responsabili e gli altri; o quella che si attua nei cosiddetti "colloqui" o,
persino, perché no?, nell'ora della verità. Gesù era per lei anche una guida spirituale.

         Maria e gli Apostoli.

         Noi siamo abituati a vedere Maria nel Cenacolo nell'attesa della Pentecoste come
Madre di tutti, come colei che ha preso - in certo modo - il posto di Gesù. Ed è così. Gesù l'ha
fatta tale ai piedi della croce: "Donna, ecco il tuo figlio!" (Gv 19,26).

         Ma non è solo così. Maria, come tutti noi, anche se in maniera unica ed esemplare, è
stata fatta da Gesù in croce anche Sorella sua, come tutti gli uomini da quel momento sono o
possono essere suoi fratelli, figli, seppur adottivi, dell'unico Padre.
         Gesù non aveva mai chiamato i discepoli suoi fratelli. Lo ha fatto dopo la
risurrezione. "Va' - dice alla Maddalena - dai miei fratelli..." (Gv 20,17).

         E giacché, al par di tutti, Maria è stata redenta come tutti, anche se in precedenza,
pure Lei è Sorella di Gesù.

         Questo considerarla in veste di Sorella, oltre che di Madre, facilita in noi la
comprensione del suo rapporto con gli Apostoli.

         E' la fraternità, infatti, in cui uno solo è il Padre, che ci rende possibile capire un po'
il suo rapporto con gli Apostoli.

         Un rapporto in cui essi senz'altro conservavano una venerazione unica verso la
Madre di Gesù, ma avvertivano anche la possibilità di uno scambio d'anima, di una
comunione che nutriva e gli Apostoli e Maria. Rapporto che ha acquistato poi tutta una sua
intensità e profondità in particolare con Giovanni col quale ha vissuto.

         Maria e Giovanni.

         Chi mai saprà dire qualcosa della loro unità?

         Maria era divenuta ormai pienamente forma, tipo della Chiesa e Giovanni era
chiamato a descrivere proprio la Chiesa, soprattutto nel suo futuro, attraverso l'Apocalisse.

         Quanto avrà influito in ciò la comunione filiale e fraterna con Maria? Io penso
enormemente. Ma lo sapremo bene in Paradiso.

         Oggi ci basti sapere che in Maria possiamo senz'altro trovare il modello della
spiritualità collettiva, perché icona della Santissima Trinità.

         Con la preghiera, che abbiamo imparato ad amare di più ed a meglio mettere in
pratica, chiediamole che ci dia d'essere suoi seguaci, suoi figli, suoi fratelli minori, ma tutti
simili a Lei nella pratica perfetta della spiritualità collettiva. Che il Cielo dunque la veda in
terra in noi, singolarmente e globalmente nella sua Opera. E viva, oltre che in terra, in quanti
ci hanno preceduto in Cielo e sono rimasti legati a noi dalla carità, dal carisma dell'unità.$doc1742$, 'drive_import', '01742-WEB-1995-04-27-maria-e-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1742)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1743, 'ITA', $doc1743$Rocca di Papa, 25 maggio 1995

ivere per quell'ora

Carissime,

         desidero questa volta mettere in comunione con voi una forte e cruda esperienza
fatta in questi ultimi mesi.

         Come sapete, ho avuto la possibilità di seguire Angelella e Giosi nell'ultimo periodo
della loro vita terrena.

         Per ambedue le mie esperienze sono state molte. Ho avuto modo di costatare la
verità che afferma: si muore come si è vissuto.

         Ed, infatti, il tempo d'attesa dell'Eternità di queste due nostre focolarine ha rivelato
la loro vita: una dedizione totale a Gesù, lo Sposo delle loro anime, e, per Lui, ai fratelli, e
perciò agli scopi dell'Opera, alle sue molteplici attività in favore dell'umanità.

         Gioia, quindi, grande in fondo al cuore e gratitudine immensa verso Dio.

         Eppure questi sentimenti gaudiosi, che ho provato ripetutamente, non hanno potuto
coprire una realtà, una tragica realtà che appariva sotto i miei occhi.

         Osservando il loro stato fisico, mi ripetevo, in cuor mio, come l'avessi capito per la
prima volta: "Dio mio, come si è ridotti prima di morire! Non più grazia, non più bellezza...
Solo una tenace forza di volontà come amore allo Sposo e parole di sapienza eterna".

         Erano divenute, come Gesù in croce, creature a sé stanti, diverse, sembravano
d'un'altra categoria - per così dire. Veniva da ricordare con Isaia il Servo del Signore: "...
molti si stupiscono di lui tanto era sfigurato per essere d'uomo il suo aspetto e diversa la
sua forma da quella dei figli dell'uomo..." (Is 52,14) e anche: "Non ha apparenza, né bellezza
per attirare i nostri sguardi, non splendore per provare in lui diletto" (Is 53,2).

         Fuori di loro la salute in chi le assisteva. In loro il disfacimento.

         E mi sono resa conto che la morte (in chi muore non di morte improvvisa) con tutto
ciò che la precede, è un autentico martirio quotidiano, vissuto momento per momento... E
che anche se l'uomo non vuole offrirsi al martirio, gli arriva ugualmente.

         Non sarà un martirio a causa della fede, ma un autentico martirio che il cristiano
può e dovrebbe accettare per compiere la volontà di Dio.

         E ho capito, ancora una volta, che occorre prepararvisi prima che succeda.
         Fare come Gesù, che è vissuto per la sua "ora".

         Anche ciascuno di noi ha la sua "ora".

         Occorre porla in cima ai nostri pensieri, come è in cima alla nostra esistenza
quaggiù.

         E pregare per essa. Giosi aveva scoperto, solo poco prima di morire, che nell'Ave
Maria sempre si dice: "Prega per noi peccatori ora e nell'ora della nostra morte".

         Perciò, mentre siamo ancora sani, pur vivendo con pienezza la vita che ci è data
giorno dopo giorno, dobbiamo vivere in quell'attesa, scegliendo fin da adesso lo stato
d'animo più consono: "Sei tu, Signore, l'unico mio bene".

         Ed offrire quell'"ora" per gli scopi stessi per cui Gesù ha offerto la sua: la Chiesa, che
può essere per noi anche la chiesa che più ci riguarda: l'Opera, i nostri cari...

         Se così faremo, non ci sorprenderà più nulla.$doc1743$, 'drive_import', '01743-WEB-1995-05-25-ivere-per-quellora-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1743)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1744, 'ITA', $doc1744$Rocca di Papa, 22 giugno 1995
"Reagire"

Carissimi,

voglio farvi partecipi di una considerazione che ho fatto durante le vacanze ed ho
comunicato quassù ad un paio di corsi.
La ripeto perché mi è sembrata stimolante.

Per riposo, ed anche per preparare qualcosa per la ricreazione dei focolarini, ho guardato
alcuni film di un certo valore.
Fra questi ne ho rivisto uno di alcuni anni fa, che molti di voi certamente conosceranno. Il
suo titolo è "Gandhi".
A differenza della prima volta, che l'ho visto, esso non solo mi è piaciuto, ma mi ha fatto
riflettere su una cosa: Gandhi ha agito, per dar l'autonomia alla sua patria, non solo vivendo
e diffondendo la "non violenza" ma anche - come lui stesso afferma nel film - provocando.
Un esempio lo si può cogliere già da quando era nel Sud-Africa, allorché ha voluto bruciare,
ed ha invitato altri indù e musulmani a fare altrettanto, il proprio lascia-passare, simbolo
della discriminazione che subivano.
Fu percosso. Rispose con la non violenza, ma continuò a bruciare affermando così che era
arrivato un nuovo giorno: quello della rivolta pacifica.
In questo modo si comportò poi durante tutta la sua vita in India.
Usò e volle fosse usata la non violenza che gli costò bastonate, sangue, prigione ed
estenuanti digiuni. Ma continuò a far capire, a chi allora governava l'India, che
quell'immenso paese era loro: degli indiani, fino alla rivendicazione ed all'occupazione ad
esempio delle saline giacché - diceva -, se il mare, che circonda l'India, è indiano, pure il sale,
che vi si ricava, è indiano.

L'esempio di Gandhi mi ha portato a far un paragone fra la sua teoria o filosofia col suo
modo di concepire la lotta per la liberazione della sua Patria ed il messaggio di Gesù che,
dando la possibilità all'uomo di divenire figlio di Dio, è venuto sulla terra a condurre
un'altra guerra: quella contro il vecchio mondo, verso gli "uomini vecchi" per instaurare su
tutto il pianeta il regno della libertà e della pace vera.
E mi sono accorta che, se la non violenza di Gandhi e dei suoi era simile, almeno sotto un
aspetto, al comando dell'amore ("Non fare agli altri ciò che non vorresti fosse fatto a te"), la
sua idea e pratica della provocazione non era lontana dalla lotta che il cristiano deve
condurre per cambiare se stesso e il mondo che lo circonda.
Infatti il cristiano deve agire, deve sempre, anzi, reagire verso tutto ciò che non è conforme
al pensiero di Dio, alle Sue esigenze sull'uomo.
Così, passando in rassegna le beatitudini, almeno alcune - viste spesso come carta d'identità
dei cristiani -, ho potuto costatare come esse si interpretino bene se le vediamo non come
regole, che possono offrire alle persone una patina cristiana ma lasciano un po' le cose come
sono, ma come pungoli per un'autentica rivoluzione.

"Beati i pacifici..." ad esempio certamente non chiede che si stia lì in pace, senza scomporsi,
ma che si sia autentici e indefessi costruttori di pace, in noi nei confronti di Dio; fra noi, con
gli altri e fra gli altri. Dunque che si reagisca a tutto ciò che non è pace nel mondo.

Se pensiamo al "Beati i poveri di spirito..." costatiamo che questo non è un comando che
possa lasciar pensare che, quel che si poteva dare, lo si è dato. Ma spinge a vivere in
continuazione la "cultura del dare" (denaro, roba, tempo, attività, ecc.).

Il comando: "Beati i puri..." non dona beatitudine a chi crede d'esser a posto perché non
compie misfatti in questo campo, ma chiama con una lotta continua verso le tentazioni, un
atteggiamento preciso e deciso verso quei mezzi che potrebbero turbare la virtù della
purezza: il televisore, i rotocalchi, gli ambienti indecenti, i manifesti impudichi, ecc.

"Beati i miti..." non significa soltanto cercare di calmare le reazioni naturali a ciò che ci può
colpire, ma porgere l'altra guancia.

"Beati i misericordiosi..." vuole l'esplicito perdono a chi ci offende.

"Beati gli afflitti..." esige non solo l'attesa della consolazione di là, ma l'accettazione del
dolore come espressione della volontà o permissione di Dio.
E così via.

Il nostro Ideale poi e la sua specifica spiritualità ci interpellano sempre su questa necessaria
reazione.
Esso vuole che noi amiamo e amiamo tutti e ci amiamo a vicenda in un mondo in cui regna
l'indifferentismo reciproco, in cui puoi morire sotto i colpi di assassini in una strada
affollata senza che nessuno muova un dito per salvarti.
Perciò prendiamo anche noi la vita come lotta per la nostra e l'altrui liberazione da tutti i
vizi ed i mali che riempiono l'anima umana.
Gesù ha pagato questa lotta colla vita.
Noi chiediamoci ogni sera: oggi ho combattuto abbastanza?$doc1744$, 'drive_import', '01744-WEB-1995-06-22-reagire-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1744)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1745, 'ITA', $doc1745$Mollens, 24 agosto 1995
Fermi sulla navicella

Carissime,

         una volta, trovandomi dal Santo Padre gli rivolsi questa domanda: "Come vede lei il
nostro Movimento?"

         Lui mi rispose: "Come un Movimento ecumenico."
         Penso abbia detto questo col significato più ampio della parola comprendente cioè,
non solo l'unità dei cristiani, ma anche l'unità possibile con i fedeli di Altre Religioni e pure,
almeno sul piano umano, con chiunque sia di buona volontà.
         E' così: il nostro è un Movimento ecumenico. Il suo scopo, infatti, è l'attuazione del
Testamento di Gesù: "Che tutti siano uno." (Gv 17,21)
         Il carisma che l'ha fatto sorgere e lo anima è quello dell'unità.
         Un Movimento, dunque, nato non per volontà di uomo o di donna, ma per volere
dello Spirito Santo, dispensatore di carismi.
         In questi ultimi tempi mi viene da pensare ad un fatto.
         Dio ha mandato sulla terra un suo dono. Perché? Per un'Opera che Egli ha escogitato
e che noi - a cinquant'anni dalla sua nascita - possiamo dire di non conoscere ancora del
tutto.
         Nel grande fenomeno dell'ecumenismo, sviluppatosi in questi ultimi tempi nella
Cristianità, ci siamo certamente anche noi.
         Ma per far che cosa?
         Per darvi un contributo.
         Quale? Grande, piccolo, determinante, basilare, di contorno...?
         Non lo sappiamo.
         Però una cosa è certa: Dio lo sa.
         Quand'Egli ha suscitato quest'Opera sulla terra, conosceva molto bene a che cosa
serviva e quale doveva essere il suo compito.
         A noi è stato manifestato finora, via via col tempo, solo un parziale disegno su di
essa.

         E ringraziamo Dio che ci ha sempre suggerito di non fare noi programmi, ma di
seguire solamente i suoi.

         E' noto un fatto. Nel '50 un Padre, conosciuta l'idea fondamentale del Movimento:
l'unità, mi chiese: "Ma il vostro allora è un Movimento ecumenico?" Al che, sapendo come
esso avesse operato, fino allora, soltanto nel mondo cattolico, risposi: "No."

         Non immaginavo certo che poi avremmo conosciuto i primi pastori evangelici...

         Prova, questa mia ignoranza, che il disegno sull'Opera era solo in Cielo.

         Spesse volte fra le domande, che mi rivolgono, ci sono quelle sull'ecumenismo. Mi si
chiede come stanno le cose in questo campo nel mondo, come stanno fra noi; cosa si
prevede; quanto si dovrà attendere; cosa si deve fare per accelerare l'ora...

         Che cosa si deve fare - questo vogliono sapere.

         Dio ci ha posti in quest'Opera come su una navicella, che naviga sulle acque del
tempo verso un porto a noi sconosciuto.

         Chi la sospinge non siamo noi. E' lo Spirito Santo che col suo soffio divino ci indica le
diverse tappe del viaggio da raggiungere.

         Dapprima ci ha manifestato lo spirito che dobbiamo avere (la nostra spiritualità
collettiva); poi i vari aspetti della nostra vita, fino all'economia di comunione, fino alla
dottrina nostra...; poi l'ordinamento che necessitava a questa sua e nostra Opera (il Centro,
le branche, ecc.) e gli orizzonti cui dovevamo guardare, per i quali lavorare: l'unità più
serrata nella Chiesa Cattolica, quella con gli altri Cristiani, e così via.

         Per ora conoscenze più in là non le abbiamo. Il Signore non ci ha dato nuove
indicazioni.

         Che fare? Pensare noi - dopo tante lezioni che Lui ci ha impartito - di aggiungere
qualcosa al suo pensiero, alla sua volontà?

         No, di certo.

         Il nostro dovere è star lì sulla navicella, nel luogo designatoci dalla Provvidenza, ben
assicurati ai nostri posti, perché i flutti del mare del mondo non abbiano a risucchiarci.

         Star lì fermi e totalmente attivi alla volontà che Dio ha pensato da sempre per noi,
perché la navicella non abbia scosse, ma cammini sicura verso quello che noi non
conosciamo ma a cui crediamo, infinitamente bello, enormemente utile alla diffusione del
Regno dell'unità sulla terra.
         Star lì anche se noi non dovessimo vedere quell'ora (come i nostri Mariapoliti
Celesti non l'hanno vista con gli occhi del corpo), perché - dopo di noi - altri prenderanno il
nostro posto e noi con loro possiamo ringraziare un giorno Dio d'averci fatti partecipi della
costruzione di un'Opera sua sulla terra, estremamente vantaggiosa (perché sua)
all'ecumenismo universale.

         E allora?

         Non voler precedere Dio, non permettersi di suggerirGli qualcosa, non voler -
presuntuosamente - accelerare le sue ore e i suoi tempi.

         Ma seguire Dio: in fretta: la navicella va. E ben fermi e aggrappati all'attimo
presente.

         Riapprezzare quindi maggiormente, con grande amore, il posto che Dio ci ha
assegnato e corrispondervi in pieno.

         Ché se non vedremo la mèta di qua, la vedremo di Là.

         Di essa intanto ci consoli il suo nome: "Tutti uno".

         Per esser certi di navigare bene, intanto, lasciamoci illuminare dalla Parola. Essa è
per ottobre: "Chi si esalta sarà umiliato. Chi si umilia sarà esaltato" (Cf Lc 14,11).$doc1745$, 'drive_import', '01745-WEB-1995-08-24-fermi-sulla-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1745)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1746, 'ITA', $doc1746$Rocca di Papa, 28 settembre 1995
La comunione dell'amore

         Carissimi,

         a confermare ancor una volta la nostra spiritualità collettiva, m'è venuto incontro in
questi ultimi giorni un libretto segnalatomi recentemente.

         E' del beato Baldovino, vissuto nel XII secolo e morto in fama di santità. Abate
cistercense, era divenuto Vescovo, quindi Primate d'Inghilterra e in seguito legato pontificio.

         Nei suoi scritti1 parla della necessità per i monaci di vivere bene non solo la
solitudine ("O beata solitudo o sola beatitudo"), ma di attuare anche la "comunione" con i
fratelli.

         Si rifà al: "Guai a chi è solo" e dice: "L'amore odia esser solitario".
         Aveva compreso la necessità della comunione meditando sull'infanzia della Chiesa,
quando gli apostoli erano stati invasi dallo Spirito Santo, che li aveva fusi in uno. E aveva
approfondito ciò anche pensando che la vita di comunione è caratteristica degli Angeli, vita
che saremo chiamati a condividere anche noi, se meritevoli, un giorno.
         Egli, in splendidi trattati poco conosciuti, afferma fra il resto, che la carità, diffusa nel
nostro cuore dallo Spirito Santo, ha un'esigenza: chiama, in chi la vive, la reciprocità, dice:
"Opera sempre in modo che colui che è amato ami a sua volta."
         Chi ama vuole, insomma, condividere con l'amato non solo tutto ciò che possiede
(beni materiali e spirituali) ma anche l'amore stesso.
         Esiste, dunque, per il beato Baldovino, l'amore di colui che ama e cerca la
comunione, che egli chiama - questo amore - "l'amore della comunione", e il ritorno
dell'amore da parte dell'amato, che fa nascere fra i due la "comunione dell'amore".
         Quindi c'è un amore della comunione e la comunione dell'amore.
         Realizzare fin d'ora questa comunione è predisporsi alla vita futura, in Cielo, dove
l'amore reciproco sarà legge.
         La "comunione dell'amore", secondo lui, porta alla beatitudine come si può
sperimentare sulla terra.
         E' la nostra esperienza: si tratta della gioia dell'unità, effetto del reciproco amore,
che è volontà di Dio per tutti noi.

         Gesù infatti non ha detto solo: amate, ma amatevi; ha chiesto quindi un amore che va
e viene.

         L'amore portato in terra da Gesù esige la reciprocità, vuole che si viva la "comunione
dell'amore".

         Tutto questo noi lo sappiamo e cerchiamo di viverlo.

         Ma una cosa mi ha fatto riflettere di quanto scrive il beato Baldovino.
         Egli afferma che impliciti all'amore reciproco sono anche la reciproca lode e la
reciproca gloria.

         E ha dedotto ciò considerando la vita delle Persone della S.S. Trinità. Esse si lodano e
si glorificano a vicenda. Non dice, forse, Gesù al Padre: "... glorifica il tuo Figlio perché il
Figlio glorifichi te"?

         Ma - aggiungo io - afferma ancora Gesù: "E la gloria, che tu hai dato a me, io ho dato
loro", e fa con ciò anche noi partecipi di questa gloria, di questa lode.

         Sì, se viviamo la nostra vita cristiana pienamente, come il nostro Ideale insegna (ed è
nell'amore reciproco), noi partecipiamo - come è possibile sulla terra - alla gloria ed alla
lode che è nella S.S. Trinità; ne partecipiamo nel nostro rapporto con Dio (riusciamo a
glorificarlo a nostra volta e a lodarlo degnamente) e ne partecipiamo nel nostro rapporto
reciproco.

         Dice il beato: "Ogni bene (ogni amore) per il fatto solo che è bene (che è amore), è
bisognoso di lode." "Ogni bene", ogni amore, quindi anche quello fra di noi.

         E sono questa gloria e lode reciproche, ìnsite nell'amore vicendevole, che ci fanno
godere con semplicità di quanto di gioioso esiste nella nostra vita di comunione.

         Non turberanno allora la nostra umiltà, né ci faranno cadere nella vanagloria le
espressioni di apprezzamento e di lode che a volte riceviamo, ad esempio, per la nostra
Opera o per ciò che la riguarda. Esse (queste espressioni) sono effetto dell'amore,
dell'amore che va e torna: dobbiamo saperle accogliere e possiamo goderne.
         Per la presenza di Dio, che è là dove è la carità e l'amore, sapremo subito a chi
riferirle (questa gloria e questa lode): a Lui. Tutto è merito Suo, magari merito Suo in noi.
Noi, per noi stessi, siamo sempre "servi inutili e infedeli".

         Così quelle da noi dette "impressioni" positive e lusinghiere, che spesso vengono
rilasciate dai partecipanti ai nostri convegni, non ci devono turbare, anzi le dobbiamo
accettare con gratitudine a Dio e con gioia, perché sono sempre espressioni di quella lode e
di quella gloria che sono ìnsite nell'amore reciproco.

         Noi abbiamo cercato di amare servendo i fratelli in quel corso, in quel convegno, in
quel congresso, in quel raduno, oppure alzandone l'atmosfera spirituale, facendoci lievito
nella massa. Ora dalle persone che abbiamo amato torna la lode e la gloria.

         Quelle "impressioni", spesso così belle, testimoniano che è nata fra noi e chi ci ha
ascoltato la "comunione dell'amore", che andrà coltivata e approfondita in seguito.

         Puntiamo allora sempre lì, all'amore reciproco, alla comunione dell'amore e
lasciamoci illuminare e riscaldare dall'irradiazione del suo splendore di lode e di gloria, a
sola gloria di Dio, per essere sempre più degni, sempre più pronti a portare questo amore là
dove si gela nella reciproca indifferenza e dove si muore dal freddo.$doc1746$, 'drive_import', '01746-WEB-1995-09-28-la-comunione-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1746)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1747, 'ITA', $doc1747$Rocca di Papa, 26 ottobre 1995

Il mosaico

Carissime,

         come certamente saprete, anche quest'anno vogliamo approfondire la nostra
spiritualità collettiva.

         E lo facciamo ripensando per ora i primi sei punti, per renderci conto che anch'essi,
come pilastri di questa via nuova nella Chiesa, vanno vissuti in quel "di più" che la
caratterizzano: la reciprocità e l'unità.

         Ogni mese poi dell'anno prenderemo in rilievo in particolare uno di questi capisaldi,
per viverli con rinnovata coscienza e maggior responsabilità.

         Abbiamo - almeno qui al Centro - dedicato il mese di novembre all'approfondimento
di "Dio-Amore", primo punto. Dedicheremo l'ormai prossimo dicembre alla "volontà di Dio",
secondo punto.

         Qualche volta, e non proprio di rado, mi si pone una domanda di questo genere:

         "Ho dato la mia vita per Dio e vorrei amarLo con tutto il cuore, la mente e le forze.
Mi succede però che mi sembra piccolo e poco importante quello che faccio e desidererei
dare un contributo più grande.

         Come posso vedere nelle piccole cose quotidiane che faccio, tutta la volontà di Dio su
di me?"

         Non è certo disprezzabile questo zelo, che di tanto in tanto sentiamo in cuore, di
voler arrivare in fretta a manifestare a Dio il nostro amore con fatti più rilevanti; anzi è
bello.

         Ma, giacché è un desiderio più che altro terreno e umano, occorre riconsiderarlo.

         Mi sembra utile a questo scopo raffigurarci la nostra Opera come un mosaico, un
magnifico mosaico.

         Avete presente qualche mosaico?

         Se ne possono vedere di assai belli nelle basiliche romane. Sono famosi quelli di
Ravenna, ad esempio. Sono numerosi soprattutto nel vicino Oriente. Ne ricordo alcuni
bellissimi e noti nella basilica del Salvatore a Istanbul.
         Quale splendore, quale lucentezza i loro ori secolari! Quali sfondi azzurri, magnifici!
Quali paesaggi... e quei troni su cui siede regale Gesù: che finezza, che bellezza, che maestà!

         Anche la nostra Opera può esser vista come un magnifico mosaico.

         I mosaici, lo sapete, sono fatti d'una moltitudine di piastrelle e di tasselli. Ed ognuno
di noi può esser considerato come un tassello di questo nostro mosaico.

         Ma i tasselli dell'Opera non sono come quelli di un normale mosaico, senza vita,
inanimati. Nel mosaico dell'Opera ognuno di noi è una piastrella viva, che comprende,
capisce il proprio posto, conosce quello degli altri, ed è cosciente anche del significato di se
stessa nell'insieme. Anzi, vede evidente che essa ha valore soltanto nell'insieme. Nello
stesso tempo però le è chiaro che, se mancasse, il mosaico risulterebbe incompleto.

         Naturalmente non tutti i tasselli del nostro mosaico sono uguali. Uno di noi può
essere una piastrella verde, per così dire, un altro un tassello azzurro, un'altra ancora d'oro
o bianca e così via. Ognuno è investito di un proprio compito e ha il dovere di stare al
proprio posto.

         Se uno, infatti, ha la funzione, ad esempio, di cucinare e di tenere la casa e non lo fa,
come l'altro può svolgere il proprio lavoro, o studiare, o tenere l'amministrazione, o
dedicarsi ad irradiare l'Ideale, o usare i mezzi di comunicazione al suo servizio?

         Ognuno ha la propria missione e deve mantenersi fedele ad essa. Ognuno, come
tassello del mosaico della nostra Opera, non deve scostarsi dal proprio luogo perché, solo se
fa in questo modo è in comunione concreta con tutti, con il dono della propria vita in quel
dato dovere espletato.

         Ognuno ama tutti gli altri soltanto se fa così e così ognuno ne è riamato, perché pure
gli altri vivono per lui.

         Ecco la reciprocità e l'unità dell'immenso, bellissimo mosaico dell'Opera, come di un
corpo vivo.

         E questa è la natura dell'Opera di Maria. E guai se non ci si comporta in questa
maniera.

         Immaginate un mosaico con la figura di un giovane e qualche piastrella che dica:
"Guarda, la cosa più bella di questo mosaico sono gli occhi di questo ragazzo. Sono
veramente vivi. Io voglio diventare l'occhio!"

         E immaginate se altri dicessero frasi simili: che mosaico avremmo? Non avremmo
certo un mosaico! Avremmo un qualcosa di mostruoso e d'incomprensibile.
         Dobbiamo dunque - ripeto - tener presente che noi siamo tasselli vivi della nostra
Opera e che siamo tutti collegati tra noi e che ognuno partecipa del tutto. E che, se non c'è
quella particolare piastrella, viene a mancare qualcosa a tutto il resto e ognuno ne soffre.

         Per cui occorre star ben aggrappati al proprio compito.
         Se dobbiamo scopare dalla mattina alla sera ed è volontà di Dio per noi, dobbiamo
sapere che, scopando, facciamo l'Opera di Dio.
         Star fermi al nostro posto significa compier bene, momento per momento, la volontà
che Dio ha su di noi.
         Considerare l'Opera come un mosaico, e tirarne le conseguenze, non è infatti che un
altro modo di quello di star ben saldi nella navicella, come abbiamo detto tempo fa.

         Viviamo, allora, così il prossimo mese, ma possiamo cominciare sin d'ora.
         Gusteremo la libertà dello Spirito tipica dei figli di Dio e lo Spirito stesso ci dirà
l'importanza di quanto facciamo e quant'è gradito al Cielo.$doc1747$, 'drive_import', '01747-WEB-1995-10-26-il-mosaico-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1747)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1748, 'ITA', $doc1748$Rocca di Papa, 23 novembre 1995
a sorpresa

Carissimi,

         ed eccoci al nuovo Collegamento, che avviene in questo periodo ancora natalizio.
         Spero abbiate passato un Natale Santo, festoso e ricco.
         E allora: Buon Anno. Che sia il migliore della nostra vita! Che nel '96 amiamo il
Signore più che in ogni altro anno trascorso.

         Ed ora il pensiero.
         La volta scorsa abbiamo parlato della nostra Opera nella Chiesa come di un mosaico
formato da tanti tasselli quanti siamo noi, ognuno in relazione con gli altri e ognuno in
relazione con l'insieme.
         Abbiamo ulteriormente approfondito, quindi, la nostra spiritualità in quanto
comunitaria, collettiva, che mette in piena evidenza il rapporto, i rapporti.

         Ma - ci si può chiedere -, una spiritualità collettiva, tutta impegnata a sottolineare la
comunione, la comunità, quanto esige di impegno personale? Di nostro sforzo individuale?

         Dobbiamo rispondere: lo esige almeno tanto quanto le altre spiritualità.
         Come possiamo, infatti, amare gli altri se abbiamo nulla o poco di personale da
offrire?
         E poi non ha detto Gesù che per gli altri occorre proprio santificare sé stessi: "Pro eis
sanctifico me ipsum"?
         L'impegno personale, anche per noi, deve perciò essere costante e radicale.
         Ed è quello che sempre, ma specie in questi ultimi anni, noi cerchiamo di attuare
mettendo in pratica le parole: "Sei tu, Signore, l'unico mio bene."
         Sì, abbiamo avuto la grazia di capire sin dall'inizio della nostra nuova vita, e di
approfondire più recentemente, la nota espressione di Paolo: "Non conosco che Cristo e
questi crocifisso", che esprimiamo così: "Non conosco che Cristo e questi crocifisso e
abbandonato."
         Lo Spirito Santo, infatti, ci ha spinto a mettere Lui al primo posto della nostra vita,
ad amarLo con predilezione e persino in modo esclusivo.

         Ci ha insegnato ad accogliere ogni sofferenza personale, ogni angoscia dei fratelli,
ogni situazione dolorosa fra noi, nella Chiesa, fra le Chiese, nel mondo come fosse Lui da
abbracciare, Lui da prediligere.

         Non è che non siamo protesi ad amare ciò che di bello e buono e positivo ci presenta
la volontà di Dio. Tutto accettiamo e ne siamo grati, ma Uno ed Uno solo abbiamo scelto in
questa vita, proprio come ogni sposa che, pur grata a tutti e tutti accogliendo, si sente legata
con amore di predilezione a uno solo: al suo Sposo.

         E così ci siamo sforzati di vivere.

         Ma, come è andata?
         Rivediamo il nostro percorso spirituale di questi ultimi tempi per corrispondere più
pienamente alla grazia di Dio ed essere anche, se Dio vuole, di aiuto per altri.

         Ricordo, e voi lo ricorderete con me, che ad un certo punto, ripensando quelle parole
di Gesù che precisano le condizioni per poterLo seguire, abbiamo capito di doverci
concentrare nella nostra vita non solo sul dolore, sulla croce: "Chi vuol venire dietro a me
(...) prenda la sua croce...", ma anche sulla rinuncia a noi stessi: "Rinneghi se stesso."

         E in quel momento questo dovere di rinnegarci ci ha ricordato Maria Santissima, la
Desolata, colei che ha realizzato ciò il più perfettamente possibile dopo Gesù.

         E fiorì così una nuova formula per la nostra vita spirituale: "Sei tu, Gesù
Abbandonato, con Maria Desolata, l'unico mio bene."

         Croce, dunque, e rinuncia, programma che volemmo vivere con generosità e
perseveranza, e lo si fece, Dio sa come, con la coscienza che la pace, la felicità, la beatitudine
sarebbero stati retaggi dell'Altra Vita, della vita futura: "Tanto è il bene che mi aspetto - dice
san Francesco - che ogni pena mi è diletto."

         Giorni fa, però, ripensando ancora, come per un esame di coscienza, a quest'ultimo
tempo, abbiamo avuto una sorpresa, una lieta meravigliosa sorpresa.

         Ci siamo accorti che questo ultimo periodo, in cui non avevamo scelto che ciò che
faceva male, è stato forse il tempo più pieno, più gioioso, più festoso della nostra vita.
         Come mai?

         Il fatto è che la crocifissione di Gesù non va mai disgiunta dalla sua risurrezione:
croce e gloria sono un unico fatto, un unico mistero.

         E, se ciò è di Cristo, è di tutti i cristiani.

         Abbiamo rifatto, insomma, l'esperienza di quanto scrivevamo anni fa in un periodo
di luce:

         "Non è vero che quando si abbraccia la croce si incontra il dolore. Quando la si
abbraccia con amore totalitario, si incontra l'Amore, si incontra Dio."

         E così è stato, senza magari rendercene pienamente conto.

         Ma ora lo sappiamo, l'abbiamo nuovamente sperimentato.

         E perciò vogliamo, non per interesse ma per amore, rinnovare il nostro proposito e
la nostra amorosa dichiarazione a Gesù e a Maria: "Sei tu, Signore Abbandonato, con Maria
Desolata, l'unico mio bene."

         Sarà così e solo così che, pieni di Dio, potremo aprire mente, cuore, spirito ad ogni
fratello, che incontreremo nella vita, per attuare con lui la nostra spiritualità collettiva.$doc1748$, 'drive_import', '01748-WEB-1995-11-23-a-sorpresa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1748)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1749, 'ITA', $doc1749$Rocca di Papa, 23 novembre 1995
l mosaico

Carissime,

         come certamente saprete, anche quest'anno vogliamo approfondire la nostra
spiritualità collettiva.

         E lo facciamo ripensando per ora i primi sei punti, per renderci conto che anch'essi,
come pilastri di questa via nuova nella Chiesa, vanno vissuti in quel "di più" che la
caratterizzano: la reciprocità e l'unità.

         Ogni mese poi dell'anno prenderemo in rilievo in particolare uno di questi capisaldi,
per viverli con rinnovata coscienza e maggior responsabilità.

         Abbiamo - almeno qui al Centro - dedicato il mese di novembre all'approfondimento
di "Dio-Amore", primo punto. Dedicheremo l'ormai prossimo dicembre alla "volontà di Dio",
secondo punto.

         Qualche volta, e non proprio di rado, mi si pone una domanda di questo genere:
         "Ho dato la mia vita per Dio e vorrei amarLo con tutto il cuore, la mente e le forze.
Mi succede però che mi sembra piccolo e poco importante quello che faccio e desidererei
dare un contributo più grande.
         Come posso vedere nelle piccole cose quotidiane che faccio, tutta la volontà di Dio su
di me?"
         Non è certo disprezzabile questo zelo, che di tanto in tanto sentiamo in cuore, di
voler arrivare in fretta a manifestare a Dio il nostro amore con fatti più rilevanti; anzi è
bello.
         Ma, giacché è un desiderio più che altro terreno e umano, occorre riconsiderarlo.

         Mi sembra utile a questo scopo raffigurarci la nostra Opera come un mosaico, un
magnifico mosaico.

         Avete presente qualche mosaico?
         Se ne possono vedere di assai belli nelle basiliche romane. Sono famosi quelli di
Ravenna, ad esempio. Sono numerosi soprattutto nel vicino Oriente. Ne ricordo alcuni
bellissimi e noti nella basilica del Salvatore a Istanbul.

         Quale splendore, quale lucentezza i loro ori secolari! Quali sfondi azzurri, magnifici!
Quali paesaggi... e quei troni su cui siede regale Gesù: che finezza, che bellezza, che maestà!

         Anche la nostra Opera può esser vista come un magnifico mosaico.

         I mosaici, lo sapete, sono fatti d'una moltitudine di piastrelle e di tasselli. Ed ognuno
di noi può esser considerato come un tassello di questo nostro mosaico.

         Ma i tasselli dell'Opera non sono come quelli di un normale mosaico, senza vita,
inanimati. Nel mosaico dell'Opera ognuno di noi è una piastrella viva, che comprende,
capisce il proprio posto, conosce quello degli altri, ed è cosciente anche del significato di se
stessa nell'insieme. Anzi, vede evidente che essa ha valore soltanto nell'insieme. Nello
stesso tempo però le è chiaro che, se mancasse, il mosaico risulterebbe incompleto.

         Naturalmente non tutti i tasselli del nostro mosaico sono uguali. Uno di noi può
essere una piastrella verde, per così dire, un altro un tassello azzurro, un'altra ancora d'oro
o bianca e così via. Ognuno è investito di un proprio compito e ha il dovere di stare al
proprio posto.

         Se uno, infatti, ha la funzione, ad esempio, di cucinare e di tenere la casa e non lo fa,
come l'altro può svolgere il proprio lavoro, o studiare, o tenere l'amministrazione, o
dedicarsi ad irradiare l'Ideale, o usare i mezzi di comunicazione al suo servizio?

         Ognuno ha la propria missione e deve mantenersi fedele ad essa. Ognuno, come
tassello del mosaico della nostra Opera, non deve scostarsi dal proprio luogo perché, solo se
fa in questo modo è in comunione concreta con tutti, con il dono della propria vita in quel
dato dovere espletato.

         Ognuno ama tutti gli altri soltanto se fa così e così ognuno ne è riamato, perché pure
gli altri vivono per lui.

         Ecco la reciprocità e l'unità dell'immenso, bellissimo mosaico dell'Opera, come di un
corpo vivo.

         E questa è la natura dell'Opera di Maria. E guai se non ci si comporta in questa
maniera.
         Immaginate un mosaico con la figura di un giovane e qualche piastrella che dica:
"Guarda, la cosa più bella di questo mosaico sono gli occhi di questo ragazzo. Sono
veramente vivi. Io voglio diventare l'occhio!"

         E immaginate se altri dicessero frasi simili: che mosaico avremmo? Non avremmo
certo un mosaico! Avremmo un qualcosa di mostruoso e d'incomprensibile.

         Dobbiamo dunque - ripeto - tener presente che noi siamo tasselli vivi della nostra
Opera e che siamo tutti collegati tra noi e che ognuno partecipa del tutto. E che, se non c'è
quella particolare piastrella, viene a mancare qualcosa a tutto il resto e ognuno ne soffre.

         Per cui occorre star ben aggrappati al proprio compito.

         Se dobbiamo scopare dalla mattina alla sera ed è volontà di Dio per noi, dobbiamo
sapere che, scopando, facciamo l'Opera di Dio.

         Star fermi al nostro posto significa compier bene, momento per momento, la volontà
che Dio ha su di noi.

         Considerare l'Opera come un mosaico, e tirarne le conseguenze, non è infatti che un
altro modo di quello di star ben saldi nella navicella, come abbiamo detto tempo fa.

         Viviamo, allora, così il prossimo mese, ma possiamo cominciare sin d'ora.

         Gusteremo la libertà dello Spirito tipica dei figli di Dio e lo Spirito stesso ci dirà
l'importanza di quanto facciamo e quant'è gradito al Cielo.$doc1749$, 'drive_import', '01749-WEB-1995-11-23-l-mosaico-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1749)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1750, 'ITA', $doc1750$Rocca di Papa, 28 dicembre 1995
1996
Farsi uno senza fretta

Carissime,

         come ricorderete all'inizio dell'anno "ideale" '95-'96 ci siamo proposti di vivere ogni
mese uno dei primi 6 punti della nostra spiritualità, così come l'avevamo riscoperto nel
nuovo tema, il secondo, sulla spiritualità collettiva.

         Occorreva, quindi, vivere più in profondità in novembre "Dio Amore",
annunciandolo a quante più persone possibile.

         In dicembre dovevamo perfezionare il fare la "volontà di Dio", indicandola a tanti
come via di santità per tutti, per le folle.

         Poi è venuto gennaio ed ora si apre febbraio, nel quale dobbiamo perfezionare il
vivere la "Parola".

         Come ricorderete ancora: abbiamo chiarito con l'ultimo Collegamento che vivendo:
"Sei tu, Signore, con Maria Desolata, l'unico mio bene", ci si prepara veramente a rivestirci di
quella divisa che è Cristo in noi. Infatti, imitando la Desolata, mettiamo a tacere l'"uomo
vecchio" con tutti i suoi attaccamenti e con anche tutte le tentazioni. Vivendo
l'Abbandonato, invece, ci si riempie di Dio, per quella famosa "sorpresa" di cui abbiamo
parlato.

         Forgiata così, la nostra persona può sentirsi degna di essere alla sequela di Gesù.

         Come abbiamo già sottolineato però non basta seguire Gesù, bisogna anche vedere
dove Lui ci vuol portare e che cosa desidera noi facciamo.

         Sappiamo che la sua intenzione è quella di farci vivere i suoi comandi, le sue parole.
         Ora, la parola di Gesù - lo sappiamo - che concentra un po' tutto il suo volere - è
l'amore, l'amare.
         Per approfondire quindi nel prossimo mese di febbraio la "Parola" dovremo vivere
meglio l'amore.

         Occorre però intendere nel senso più vero, nel modo più giusto, l'amore.

         L'uomo si sente veramente amato da un altro, se questo riesce a farlo contento. Si
capisce allora come a volte il nostro non è vero amore quando, ad esempio, portiamo
argomenti, teniamo atteggiamenti, prestiamo attenzioni che non interessano l'altro.

         Il vero comportamento che interpreta la parola "amore", "amare", è il "farsi uno",
l'andare incontro al fratello, ai suoi bisogni, il farsi carico completo dei suoi pesi,
l'addossarsi le sue necessità, come le sue sofferenze. Allora avrà significato il dar da
mangiare, da bere, l'offrire un consiglio, un aiuto.

         Ma cosa succede se ci comportiamo così?

         Avviene come quando, constatando i grandi problemi di tanti ambienti del terzo e
quarto mondo, attanagliati dalla morsa della miseria, dalla mancanza di casa, di vestiti, di
lavoro ecc., si comprende che non si può pretendere che queste persone pensino a crearsi
una cultura ad esempio o si elevino nello spirito con la preghiera; prima occorre fare in
modo che siano sollevate dal peso della miseria che le schiaccia. Poi si potrà pensare anche
a tutto ciò che riguarda la vita della persona umana: la sua istruzione, il suo sviluppo, ecc.

         La stessa cosa succede con le singole persone quando noi le amiamo col "farci uno".
Noi, in tal modo, togliamo a loro completamente ciò che occupa il loro cuore e può essere un
peso. Esse sentono che noi ci carichiamo di ciò che le opprime, e si sentono libere.

         Ma, sentendosi sollevate, libere, vuote di preoccupazioni, sono atte ad accogliere
anche il messaggio che noi vorremmo portar loro.

         E saranno attratte da questa vita nuova che scoprono in noi, cui anelano tutti in
fondo al cuore, perché pensata da Dio per tutti i suoi figli.

         Succederà così che non dovremo preoccuparci tanto di mettere in pratica l'amore
vicendevole (punto che approfondiremo il prossimo mese), che è la quintessenza del
cristianesimo, perché la persona così amata amerà a sua volta e l'amore tornerà.

         Il nostro impegno allora per questo prossimo mese sarà quello di curare in
profondità il "farsi uno"; non attuandolo in qualche modo e malamente, non trascurando
qualche particolare, soprattutto non facendolo in fretta, ma perfettamente. E ciò sia con le
persone che avviciniamo direttamente o per telefono, sia con quelle con cui trattiamo
attraverso la corrispondenza, o in altro modo.

         Con questa ginnastica, perfezionata ogni giorno, arriveremo poi, il mese di marzo, a
vivere meglio il comandamento nuovo di Gesù.

         Coraggio, allora, cominciamo subito!

         Troverete presto la vostra vita spirituale molto migliorata. Ne ho fatto l'esperienza
ed è così.

         Concludendo: puntare questo mese sul "farsi uno senza fretta".$doc1750$, 'drive_import', '01750-WEB-1995-12-28-farsi-uno-senza-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1750)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1751, 'ITA', $doc1751$Rocca di Papa, 25 gennaio 1996
"Farsi uno" fra noi
fino all'unità di pensiero

         Carissimi,

         ed eccoci al nuovo pensiero che dovremo vivere d'ora in poi fino al Collegamento di
marzo.

         Vi dico la verità che mi rincresce un po' abbandonare quello del mese scorso.
         Quel "farsi uno senza fretta", infatti, ha portato nel Movimento tali e tanti frutti -
come ho saputo da voi e sperimentato io stessa - che verrebbe il desiderio di soffermarsi su
di esso.
         D'altra parte dobbiamo ricordare il proposito (che abbiamo fatto all'inizio dell'Anno
ideale, in ottobre) di mettere in pratica, mese dopo mese, ad uno ad uno, i primi sei cardini
della nostra spiritualità. Per cui ora dovremmo abbordare il quinto e cioè l'amore reciproco.
         Come fare allora?
         Faremo così: con tutti i prossimi che incontreremo, o con cui in tanti modi veniamo
in contatto, continuiamo a vivere il "farsi uno senza fretta".
         Fra noi, nel Movimento, dove già si attua, o dobbiamo attuare, l'amore che va e
l'amore che torna, applichiamoci a vivere l'amore reciproco, però in modo nuovo.
         Ci sono stati dati, infatti, al riguardo, alcuni suggerimenti attraverso il secondo tema
sulla spiritualità collettiva: dobbiamo viverlo, questo comandamento, con il "di più" che
esige la nostra spiritualità comunitaria.
         "Di più" di come è richiesto da altre bellissime spiritualità più individuali. Per esse
l'amore reciproco significa volersi bene in Cristo, non giudicarsi, servire l'altro, prevenirsi
nel rendersi onore, mostrare l'amore con le opere, ecc.
         "Di più" perché quel "come" del Comandamento Nuovo va da noi interpretato e
vissuto in un modo particolare e cioè secondo il modello di Gesù Abbandonato. Quel "come"
che, se così vissuto, genera l'unità.
         In Gesù Abbandonato quel "come" significa non solo la prontezza - se ci fosse
richiesta - a dar la vita l'uno per l'altro, ma il totale quotidiano morire di fronte ai fratelli, in
uno spogliamento esteriore ed interiore dalle cose materiali a quelle spirituali.

         Esso comprende, fra quelle spirituali, anche il distacco dal nostro pensare.
L'"altissima povertà di mente" - direbbe san Francesco.

         Distacco che permette di capire fino in fondo il pensiero del fratello e che esige il
donare con generosità e garbo il nostro pensiero al fratello.

         Distacco che genera l'unità di pensiero.
         A noi, come ai primi cristiani, quest'unità di pensiero è richiesta. Diceva san Paolo:
"Vi esorto pertanto, fratelli, (...) ad essere tutti unanimi nel parlare, perché non vi siano
divisioni tra voi, ma siate in perfetta unione di pensiero..." (1Cor 1,10).

         Ha una misura, quindi, il nostro reciproco amore, un "come" che genera non solo
amicizia pur soprannaturale, o concordia, ma unità, sull'esempio di Gesù che nel e per il suo
grido d'abbandono, vertice della sua Passione, ricompose l'unità degli uomini con Dio e fra
loro.

         E allora?
         Allora - ripetiamo - viviamo con tutti il "farsi uno senza fretta" e fra noi il
Comandamento Nuovo, puntando sul realizzare sempre l'unità di pensiero.
         Esso esigerà certamente, ed in modo speciale, anche qui il "farsi uno senza fretta",
ma dovrà portarci ad essere tutti di un solo pensiero.
         Se io comprenderò bene l'altro (e ciò lo otterrò mettendomi vuoto di fronte ad esso)
ed egli capirà bene me, la sintesi sarà presto fatta e sarà il pensiero di Gesù
fra noi.

         E allora: avanti! Non è poi così difficile!
         Questa è comunione vera ed utilissima, che fa progredire noi spiritualmente e fa
avanzare l'Opera, che ci è affidata, verso i meravigliosi orizzonti cui è destinata. Essa sarà
guidata in tal modo non da "noi", dal nostro misero "noi", ma da Gesù fra noi.
         Concludendo: "Farsi uno con tutti senza fretta", e fra noi aver sempre l'"unità di
pensiero".$doc1751$, 'drive_import', '01751-WEB-1996-01-25-farsi-uno-fra-noi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1751)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1752, 'ITA', $doc1752$Rocca di Papa, 22 febbraio 1996
Soli con Lui solo?

Carissime,

         s'avvicina maggio, il mese dei fiori, del profumo, dei colori e, specie per noi, il mese
dedicato a Maria, che è, fra il resto, regina, madre, capo, condottiera del nostro Movimento.

         Non solo: Ella è anche modello di ciascuno di noi e della nostra Opera.
         A Lei dobbiamo guardare se vogliamo esserne autentici membri.
         Lo sappiamo: Ella è il nostro "dover essere". Noi siamo il suo "poter essere".
         E come modello può essere amata e imitata non solo dai cattolici, ma anche da tutti
gli altri cristiani.
         Ed è ammirata pure da fedeli di altre Religioni.
         Motivi sufficienti, questi, per parlare questa volta di Lei a tutti noi.

         Maria.
         Ma come si può immaginare Maria, come ci viene descritta dalla Scrittura?
         Come viene dipinta, cantata, scolpita dagli artisti di tutti i tempi?
         Non certo come una persona tutta estroversa, agitata, precipitosa, sempre di corsa,
attenta unicamente a ciò che avviene al di fuori.
         Ma come una creatura, soffusa di mistica bellezza, che rivela un immenso tesoro
nascosto nel suo cuore: Dio.
         Guardandola, contemplandola, ammirandola, immette, specie in chi è più sensibile,
una sete fortissima di raccoglimento e di segretezza.

         Quest'intimità di Maria con Dio ha affascinato persone senza numero nella storia,
che hanno seguito spiritualità prevalentemente individuali, sino a far loro esprimere un
ardente desiderio: quello d'essere soli con Dio solo, fino a far loro il noto detto, espressione
di un certo ideale, mèta di perfezione: "Sola cum solo."
         E quest'atteggiamento, che è anche un fortissimo impegno, ha forgiato dei santi, dei
grandi santi.

         Ora a noi, che spesso non siamo soli, ma in compagnia con fratelli e sorelle, noi, che
seguiamo una via comunitaria, collettiva vien da chiedere: come in questo nostro stato ci si
può lasciare attrarre dal fascino di Maria nella sua solitudine con Dio, come raggiungere
anche noi - sul suo esempio - la piena unione personale con Lui?

         Se ben osserviamo, Maria non è sempre sola; non è unicamente attratta dalla sua
solitudine con Dio nel suo cuore. La vediamo cantare il Magnificat di fronte ad Elisabetta,
sua cugina; la sappiamo ospite a Cana di un convito; l'ammiriamo sofferente assieme a Gesù
in croce con accanto discepoli e donne; la pensiamo presente nel Cenacolo, ove prega con gli
apostoli e riceve con loro lo Spirito Santo.

         E' una vita normale la sua e modello non solo di chi, per amore, si ritira in solitudine,
ma anche di coloro che sono chiamati ad essere e ad agire in mezzo al mondo.

         Noi dobbiamo certamente amare Dio, Gesù nel nostro cuore, dove Egli è, e nella
Santissima Eucaristia, che sempre ci attende; ma dobbiamo amarlo anche in ogni altra sua
presenza che noi conosciamo, e quindi pure in tutti i fratelli che incontriamo. In essi
dobbiamo infatti ravvisare Gesù, quello stesso Gesù, che è presente nel nostro cuore.

         In tal modo ogni nostro rapporto nella vita non è che con Uno solo, soltanto, con Lui,
con Gesù.

         E' questo il mio, il nostro modo specifico di vivere il: "Sola con Lui solo", perché tra
me e Lui non c'è più nessuno che faccia diaframma, anzi sono sin d'ora già come mi troverò
in punto di morte e subito dopo: io e Lui.

         Ecco, quindi, come attuare il nostro Ideale della perfetta comunione con i fratelli, che
coincide però col perfetto raccoglimento.

         Carissime,
         anche Maria amava Dio dentro di sé e Dio fuori di sé: Lo amava in Gesù suo Figlio.
         Affidiamoci a Lei allora, modello anche di vita comunitaria, in questo prossimo mese
di maggio, come più volte, nella nostra vita ideale, abbiamo fatto, consacrandoci a Lei,
perché ci insegni ad essere come Lei: sole con Dio, sole con Gesù.
         E che il suo fascino, attraverso le nostre persone e la nostra Opera, dia il bando ad
ogni superficialità nella nostra vita d'unione con Dio, ad ogni atteggiamento puramente
umano verso i nostri fratelli, ad ogni attivismo sregolato, ma attragga, convinca, trascini
molti.

         Ella ci converta se occorre, ci aiuti, ci insegni a comportarci come Lei affinché non
poniamo un velo sulla trasparenza di Dio nella nostra vita.

         Concludendo: cerchiamo di vivere sole con Lui nel nostro cuore, specie nelle ore
dedicate alla preghiera, e sole con Gesù, amandolo nel fratello o nei fratelli attraverso tutto
ciò che, durante il giorno, operiamo in loro favore.

         Non immaginiamo quanti frutti raccoglieremo alla sera!$doc1752$, 'drive_import', '01752-WEB-1996-02-22-soli-con-lui-solo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1752)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1753, 'ITA', $doc1753$Sierre, 24 marzo 1994
Rinneghiamo noi stessi

Carissimi,
         ed eccoci al Collegamento. Esso vuol aiutarci - lo sappiamo - a fare della vita un

santo viaggio per arrivare sicuri alla mèta.
         Questa volta vorrei considerare con voi un'affermazione che già conosciamo, ma

che, ogni qual volta si legge, mantiene il suo interesse e la sua attrattiva.
         E' di san Giovanni della Croce e parla del rinnegare se stessi. Dice, accennando a

coloro che usavano fare tante penitenze per arrivare all'unione con Dio, che se si spendesse
metà della fatica nel rinnegare invece se stessi, in un mese si farebbero progressi maggiori
di quelli che si ottengono in molti anni usando di tutti gli altri mezzi (cf Salita del Monte
Carmelo I, c.8, n.4).

         Rinnegare dunque se stessi, perdere, saper perdere, o tagliare, o mortificarsi. Sono
tutti, in certo modo, sinonimi. Ne abbiamo parlato tante volte.

         Pur tuttavia qualcuno potrà pensare: come facciamo a concentrarci sulla rinuncia,
sul perdere, se la nostra spiritualità ci impegna soprattutto nel positivo e cioè nell'amore di
Dio e del prossimo mediante i quali perseguiamo le virtù?

         Sì, è così: il nostro Ideale è amare. Ma non è solamente così. E' vero che se sotto un
aspetto esso si presenta come amore, come unità, sotto un altro è anche Gesù Abbandonato,
imitare Gesù Abbandonato nella vita, che è garanzia della vera unità.

         Perché Gesù Abbandonato è proprio rinuncia, totale rinuncia. Gesù Abbandonato
dona, là in croce, la sua vita fisica e quindi la perde e anche, in certo modo, la sua vita
interiore, divina.

         Non per nulla noi ci consacriamo a Gesù Abbandonato.
         Guardando quindi Lui, noi possiamo, anzi dobbiamo, rinunciare, tanto più che Gesù
non ha detto solo: "Amatevi", ma anche: "Rinnega te stesso, prendi la tua croce".
         Ecco allora che, così spiegata, vale anche per noi l'indicazione di san Giovanni della
Croce. Del resto occorre rinnegare se stessi anche per amare, per coltivare l'unità con Dio e
amare il prossimo. La rinuncia è la condizione necessaria all'amore.
         E poi non sempre c'è un fratello o più fratelli da amare. Ed allora in quei momenti
occorre sapere rinunciare non solo alle lusinghe del male, ma anche a tutto quanto non è
nella volontà di Dio del presente.

         Proviamo allora, in questo prossimo mese, a far di esso un tempo dedicato alla
rinuncia. Se così faremo, il mese di maggio, quando ci risentiremo, avremo progredito
spiritualmente davanti a Dio e il Signore potrà darci le altre grazie che ha in serbo per noi.

         Sia dunque parola d'ordine: "Rinneghiamo noi stessi" ed il nostro Ideale d'unità
brillerà maggiormente.$doc1753$, 'drive_import', '01753-WEB-1994-03-24-rinneghiamo-noi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1753)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1754, 'ITA', $doc1754$Rocca di Papa, 26 dicembre 1991

1992

Sia fatta

Carissimi,

         come sapete attraverso i collegamenti di quest'anno, vogliamo evidenziare i pilastri
su cui deve poggiare la nuova evangelizzazione, la nostra nuova evangelizzazione affinché
non manchi ad essa né l'essere né il parlare.

         E anche questa volta continuiamo a parlare del nostro "essere" affinché sia una
realtà.

         Abbiamo già voluto farlo nei mesi scorsi cercando anzitutto di mettere o rimettere
Dio nel più profondo del nostro cuore, scegliendolo come primo ed unico nostro amore e
annullando tutto il resto: "Sei tu, Signore, l'unico mio bene" (cf Sal 15,2).

         Ci siamo poi concentrati su quell'amore radicale verso i prossimi, espressione del
nostro amore a Dio, che arriva a donare tutto di noi per essi: anche la vita.

         Oggi meditiamo ancor una volta su quell'atteggiamento tipico del cristiano che porta
ad immedesimarsi con Gesù, ad essere uno con Lui, quindi ad "essere" per davvero: il fare la
volontà di Dio.

         La volontà di Dio - l'abbiamo capito in questi anni - è un concetto o meglio una realtà
abissale come Dio stesso; divina, sublime come il suo amore; affascinante ed estasiante
come il suo volto.

         Essa non è, certamente, quella che a volte si pensa: un obiettivo di fronte al quale
occorre rassegnarsi, specie quando ci si imbatte nel dolore; né un susseguirsi di atti
monotoni susseguentisi, disseminati nella nostra esistenza.

         La volontà di Dio è la voce di Dio che continuamente ci parla e ci invita; è un filo o,
meglio, una trama d'oro divina che tesse tutta la nostra vita terrena e oltre; è il modo di Dio
di esprimerci il suo amore, amore che chiede una risposta perché egli possa compiere nella
nostra vita le sue meraviglie. La volontà di Dio è il nostro dover essere, il nostro vero essere,
la nostra piena realizzazione.

         E c'è chi può darci un'idea di che cosa opera in chi ad essa, alla volontà di Dio,
s'abbandona completamente: è Maria, la Mamma di Gesù, la cui spiritualità qui in terra, da
Lei pienamente vissuta, è stata, si può dire, attuare la volontà di Dio: "Fiat mihi secundum
verbum tuum".
          L'adesione costante alla volontà di Dio, anche nei momenti più dolorosi e tragici, ha
portato Maria a immedesimarsi e compiere lo straordinario disegno che Dio "ab aeterno"
aveva su di Lei.

         Perché ha compiuto non la sua ma la volontà di Dio, Ella è stata quella donna di cui
già nella Genesi lo Spirito Santo aveva predetto: "Io porrò inimicizia tra te e la donna, tra la
tua stirpe e la sua stirpe: questa ti schiaccerà la testa" (Gn 3,15).

         Perché ha compiuto la volontà di Dio, Ella è divenuta Madre di Dio in Gesù, Madre di
ciascuno di noi e della Chiesa e ha storicamente realizzato e disegnato il grande affresco
dell'Apocalisse: "Nel Cielo apparve un segno grandioso: una donna vestita di sole, con la
luna sotto i piedi e sul suo capo una corona di dodici stelle."(Ap 12,1)

         Quale vita più strabiliante della sua dopo quella di Gesù?

         Ma pure per la nostra vita - anche se sempre nelle debite proporzioni - si può
pensare qualcosa di un po' simile. Noi non siamo stati presenti solo ad un dato punto della
storia, quando siamo nati nel '24, nel '49, nel '50, nel '68 ... Noi eravamo già nella mente di
Dio dall'eterno, da Lui da sempre pensati; da Lui da sempre amati; noi abbiamo avuto da
sempre un posto nel suo cuore.

         Quale, come? Non lo sappiamo ora o potremo saper poco, anche se avessimo il dono
della Sapienza, ma lo scopriremo pienamente un giorno se, facendo, come Maria, la volontà
di Dio, andremo ad occupare, il giorno della nostra partenza da questa terra, quel posto in
Paradiso.

         Per cui anche la nostra vita come quella di Maria copre - in certa maniera - un arco
che va dall'eternità all'eternità: nella mente di Dio dapprima, su questa terra dopo, ed infine
in Paradiso.

         Ma tutto ciò è possibile se seguiamo il progetto di Dio su di noi, se compiamo la sua
volontà, se ci lanciamo in quella che noi chiamiamo "la nostra divina avventura".

         E così il Signore ci vede come altre piccole Maria o altri piccoli Gesù, la cui vita non è
stata altro che compiere la volontà del Padre in modo tale da volerla come propria. Sta
scritto che Egli, anche il più difficile passo, quello della passione e morte, lo ha fatto
volendolo Lui stesso. "Si offerse perché lo volle" (cf Gv 10,18), tanto la Sua volontà umana
era immedesimata con quella del Padre.

         Anche noi, dunque: non rassegnarci alla volontà di Dio qualunque essa sia, non
semplicemente accettarla, non compierla col cuore diviso, ma volerla. Essere uno con essa.
E' il meglio che possiamo fare. E' la cosa più intelligente che possiamo compiere.

         Essa ci fa altri Gesù.

         E che cosa occorre di meglio, per poter evangelizzare? Chi meglio di Gesù sa
evangelizzare?
         Ripetiamo allora ogni attimo di fronte ad ogni volontà di Dio dolorosa, gioiosa,
indifferente: sia fatta. Sia fatta quella che anche sotto la guida dello Spirito abbiamo noi
stessi programmato per il nostro anno ideale; quella che i doveri della nostra particolare
vocazione reclamano; quella che i nostri responsabili ci annunciano. E soprattutto quella
imprevista, che giorno dopo giorno fa capolino nella nostra vita e magari capovolge ciò che
abbiamo pensato e creduto.

         Proviamo: diciamo prima di ogni nostra azione: sia fatta. Vi assicuro: scopriremo che
queste due semplici parole saranno una spinta potente, come una pedana di lancio, per fare
con amore, con perfezione, con totale dedizione ciò che dobbiamo fare. Saranno, queste due
parole, il modo per eliminare tante altre cose che il nostro io, i nostri attaccamenti vogliono
farci credere di dover fare; saranno un sistema per salvaguardare la pace dell'anima e la
stessa salute fisica. E per avere la gioia. Con queste due parole, infatti, noi viviamo tutto il
giorno in una continua potatura del nostro 'uomo vecchio' e lasciamo spazio al 'nuovo', che
è felicità.

         Sia fatta dunque non la mia, ma la Sua volontà.

         E comporremo attimo dopo attimo il meraviglioso, unico e irripetibile mosaico della
nostra vita che il Signore da sempre ha pensato per ciascuno di noi: Egli, Dio, a cui
s'addicono solamente cose belle, grandi, immense, nelle quali anche ogni più piccola parte,
come un atto d'amore, ha senso e splende, così come i minuscoli colorati fiori hanno il loro
perché nella sconfinata bellezza della natura.

         Dunque dai nostri cuori, presenti in tutto il pianeta, escano in questo mese le due
sole parole: sia fatta.$doc1754$, 'drive_import', '01754-WEB-1991-12-26-sia-fatta-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1754)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1755, 'ITA', $doc1755$Rocca di Papa, 27 febbraio 1992

"Dare"

         Continuiamo, anche con questo Collegamento, a parlare dell' evangelizzazione"
tipica del nostro Movimento.

         Sappiamo che essa si basa sull' "essere" e sul "parlare": sull' "essere" prima e poi sul
"parlare".

         E, affinché l' "essere" in noi sia una realtà, abbiamo spiegato i mesi scorsi vari modi
di attuarlo.

         Questa volta ne sottolineiamo un altro ancora: noi possiamo "essere", se viviamo la
Parola, se siamo la Parola viva.

         Le Parole di Gesù, infatti, non sono semplicemente esortazioni, suggerimenti,
indicazioni, direttive, ordini, comandi. Nella Parola di Gesù è presente Gesù stesso che parla,
che ci parla. Le sue Parole sono Egli stesso, Gesù stesso.

         E così noi, nella Parola lo incontriamo. E accogliendo la Parola nel nostro cuore,
come Egli vuole che sia accolta (e cioè essendo pronti a tradurla in vita), siamo uno con Lui
ed Egli nasce o cresce in noi e così "siamo". Ed ecco l' "Essere".

         Sappiamo quale importanza abbia sempre avuto nel nostro Movimento la Parola;
come essa venga tuttora letta, commentata e vissuta in tutto il mondo, da persone di tutti i
popoli, di tutte le razze, di tutte le età.

         Sappiamo anche come, per i membri più vicini, il Collegamento suggerisca pure una
Parola sintetizzata spesso in un detto facile da ricordarsi.

         Si vuole, infatti, vivere la Parola, farla nostra; annullare noi per essere lei; metterla
in cima ai nostri pensieri, ai nostri affetti. Essa è lampada per i nostri passi, la vera
compagna nel nostro Santo Viaggio, perché non si può avere nessun miglior compagno di
Gesù che in essa vive; per essa ci andiamo evangelizzando e irradiamo il Vangelo attorno a
noi.

         I quasi cinquant'anni di vita del Movimento - penso - ci abbiano insegnato
veramente lo straordinario valore della Parola.

         Tuttavia non lo si è mai compreso abbastanza. Per questo, per "essere", lo
sottolineiamo anche ora e lo facciamo mettendo in rilievo in particolare una parola.
         E' una parola che oggi si dovrebbe tener presente in modo particolare e vivere con
la massima intensità per concorrere alla soluzione di uno dei più gravi problemi del mondo.

         Conosciamo i gravissimi dislivelli che caratterizzano l'umanità. Ci sono nazioni che
puntano sull'avere anziché sull'essere e guazzano nel consumismo con tutte le sue
conseguenze, ed altre, invece, popolatissime, attanagliate da bisogni angoscianti.

         La parola che potrebbe offrire un rimedio, che potrebbe ridare un equilibrio al
nostro pianeta è quella che invita a dare. "Date e vi sarà dato; una misura buona, pigiata,
scossa, traboccante vi sarà versata nel seno (...)" (cf Lc 6,38).

         Dare, dare, attuare il "dare". Far sorgere, incrementare la cultura del dare.

         Dare quello che abbiamo in soprappiù o anche il necessario, se così ci suggerisce il
cuore. Dare a chi non ha, sapendo che questo modo di impiegare le nostre cose rende un
interesse smisurato, perché il nostro dare apre le mani di Dio ed Egli, nella sua Provvidenza,
ci riempie sovrabbondantissimamente per poter dare ancora e molto e ricevere ancora e
così poter venire incontro alle smisurate necessità di molti.

         Dare anche - e questo lo diciamo in particolare ai membri del nostro Movimento -
per attuare ciò che ci sembra il Signore ci domandi in questo momento di grazia, a proposito
dell'economia di comunione. Dare, che è poi sinonimo di amare concretamente perché
l'"uomo nuovo" sia sempre vivo in noi. E questa è la prima condizione dell'economia di
comunione: formare uomini nuovi.

         Dare poi perché diventi realtà tutto quanto si è pensato in questi ultimi mesi.

         Voi sapete come l' idea dell'economia di comunione abbia risvegliato in molti e molti
fra noi (dai più piccoli ai più grandi) energie sopite, abbia suscitato propositi seri e
impegnativi, abbia suggerito soluzioni a sogni creduti irrealizzabili.

         Come abbia messo in moto in tutto il mondo "ideale" questo meccanismo del "dare"
per cui quasi tutti, si può dire, si sono impegnati ad offrire prestazioni, preghiere, forze,
denari, spostamenti, terre, case, gioielli.

         Come di già semi promettenti di nuove aziende finalizzate al versamento degli utili
per chi è nel bisogno, stiano fiorendo come una primavera un po' dovunque.

         Come altre strutture per formare uomini nuovi stiano sorgendo come per incanto.

         Come le cittadelle si stiano moltiplicando.

         Ora, affinché tutto cresca e tutto maturi, è necessario consolidare, rendere abitudine
in noi questa virtù del "dare". E' necessario che l'entusiasmo col quale è partita l'economia
di comunione ci accompagni sempre e aumenti e non deluda le moltissime aspettative dei
poveri e gli incoraggiamenti così espliciti e spesso illuminanti di personalità religiose, di
economisti, di imprenditori e di altri esperti.

         Dobbiamo mantener viva quest'economia di comunione in tutte le sue espressioni
fino al punto che non ci sarà più un indigente fra noi. Allora sì che sarà una realtà umano-
soprannaturale sorprendente, un grande "essere" che griderà Dio al mondo, che svelerà a
tanti la sua presenza nella storia, come qualcuno qualifica il nostro progetto.

         Così l'economia di comunione servirà all'evangelizzazione, come l'evangelizzazione
(in questo caso: il nostro vivere la Parola, il dare) avrà servito all'economia di comunione.

         E allora "Dare": ecco il motto del nostro Collegamento.

         Diamo sempre; diamo un sorriso, una comprensione, un perdono, un ascolto; diamo
la nostra intelligenza, la nostra volontà, la nostra disponibilità; diamo il nostro tempo, i
nostri talenti, le nostre idee (ogni idea è una responsabilità), la nostra attività; diamo le
nostre esperienze, le capacità, i nostri beni riesaminati periodicamente perché nulla si
ammucchi e tutto circoli.

         Dare: sia questa la parola che non ci dà tregua.

         La vogliamo vivere a gloria di Dio e perché torni a rivivere lo spirito e la prassi dei
primi cristiani: erano un cuor solo e un'anima sola e fra loro non v'era indigente (cf At 4,32-
34).$doc1755$, 'drive_import', '01755-WEB-1992-02-27-dare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1755)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1756, 'ITA', $doc1756$Rocca di Papa, 23 aprile 1992
Il più profondo "farsi uno"

Carissimi,

         una delle tante grazie che la Madonna in questo mese di maggio ci ha fatto, nel
nostro soggiorno in Africa, è stata quella di comprendere una nuova dimensione del "farsi
uno", atteggiamento a noi tanto noto e familiare, espressione del nostro carisma d'unità.
Abbiamo approfondito come "farsi uno" col fratello, con i fratelli per amarli ed esprimere
con ciò concretamente il nostro amore a Dio.

         E abbiamo visto anche in una luce nuova il fratello stesso.

         San Vincenzo de' Paoli definiva i poveri che beneficava: i suoi padroni. E perciò li
serviva.

         Noi abbiamo compreso che dobbiamo vedere non solo i poveri come nostri padroni,
ma anche tutti i nostri prossimi. Infatti, se Gesù ha detto che non è venuto per essere
servito, ma per servire (e dobbiamo poter dire di noi stessi altrettanto), il servo siamo noi e
i padroni gli altri.

         E come tale è lui, il fratello, che deve aver la prima parola, essere onorato, obbedito
perché è lui che comanda.

         Ma allora quale l'atteggiamento nostro nei suoi confronti?
         Metterlo in condizione di agire per primo, di avere l'iniziativa. Si potrebbe dire: di
amare per primo.
         E, perché così sia, dobbiamo metterci a sua disposizione, accostarlo vuoti
completamente di noi stessi e spostare per lui anche ciò che possediamo di più bello, di più
grande: il nostro stesso carisma, la nostra spiritualità, la nostra Opera, per essere di fronte a
lui "nulla" come Gesù Abbandonato, come Maria Desolata. Essere "nulla" che è poi,
paradossalmente, essere l'Ideale più autentico, essere l'Opera personificata.
         In tal modo il fratello può manifestarsi, perché trova chi lo accoglie: può donarsi.
         Ma, poiché il "nulla" in noi è un "nulla d'amore", e non certo un nulla sinonimo di
inesistenza, lo Spirito Santo, che vigila presente in noi, ci illumina e ci permette di guidare,
in certo modo, la conversazione perché il fratello possa completamente aprirsi. Non solo,
ma ci dà modo di cogliere quel qualcosa di "vivo" che è nel cuore del fratello, "vivo" nel
senso soprannaturale, fiammella della vita divina in lui; o "vivo" semplicemente nel senso
umano, espressione cioè di quei valori che il Signore, creandoci, ha disseminato in ogni
anima umana.

         E su quel qualche cosa di "vivo" noi possiamo - servendo - innestare con dolcezza,
con amore, con illimitata discrezione, quegli aspetti della verità, del messaggio evangelico
che portiamo e danno pienezza e completezza a ciò che quel prossimo già crede e sono da
lui spesso attesi, quasi agognati; aspetti che trascinano con sé, poi, tutta la verità.

         Anzi, se si pensa che lo possa desiderare, possiamo offrirgli, con garbo, senza mai
imporre, d'entrare per quella porta dell'Opera (le sue varie parti strutturate o non
strutturate) che Maria ha preparato per ogni uomo, affinché anche questa persona possa
aver accesso alla nostra comunione, alla comunità del nostro Movimento che è una delle
comunità della Chiesa.

         Così il fratello ha prima dato e noi, poi, abbiamo fatto altrettanto, e la fiamma del
nostro Ideale va a beneficio di tanti.

         E' un modo, questo, eccellente per i Continenti dove la Chiesa, e quindi anche noi, fa
leva sui semi del Verbo esistenti nelle varie culture per innestare la Vita (Gesù) su qualcosa
di già vivo, come è vivo ogni albero anche selvatico, non ancora innestato.

         Ma è modo sublime anche nelle terre cosiddette civilizzate, dove l'ateismo teorico o
pratico o l'indifferentismo o il secolarismo o il materialismo dominano. Lì, quando non
vivono solamente i sottovalori (come il potere, i soldi, gli onori, il benessere solamente
proprio, ecc.), non si può parlare forse tanto di semi del Verbo, ma, a volte e non di rado, di
idealità più o meno elevate e spesso di tanta buona volontà.

         Anche tutto ciò va valorizzato e colto come base su cui costruire la fraternità umana.

         E', quanto ho spiegato, il "farsi uno" più profondo, più intimo, che suppone
certamente il dar da mangiare a chi ha fame, il costruire ospedali per chi è ammalato e cioè
suppone le opere. Ma non si esaurisce in esse che sono un aspetto più esterno del "farsi
uno".

         La prima opera che dobbiamo edificare è Cristo in noi, è Maria in noi. E loro sono
proprio loro là dove sono "nulla" nell'abbandono e nella desolazione. E diventano per
questo "tutto", pienezza: Gesù nella risurrezione e Maria, per partecipazione alla vita divina,
nella sua glorificazione.
         E allora tentiamo in questo mese di giugno, dedicato al Cuore di Gesù e cioè
all'ardentissimo amore di Cristo, di vivere questo che è stato il suo modo d'amare, questo
"farsi uno" come Lui ha fatto, quando da Dio s'è fatto noi, s'è fatto uomo.

         Ricordiamo perciò il "farsi uno più profondo".$doc1756$, 'drive_import', '01756-WEB-1992-04-23-il-pi-profondo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1756)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1757, 'ITA', $doc1757$Rocca di Papa, 28 maggio 1992
1994

Stare nella gioia"

Carissime,
         eccoci ad un nuovo Collegamento. Come sempre il mio desiderio è quello di darvi

un'idea da mettere poi in pratica, di dirvi una parola, naturalmente presa dal Vangelo, dalla
Sacra Scrittura, che risponda alla nostra vocazione.

         L'idea, la parola, che oggi vorrei proporvi, è quella della gioia. Centinaia di volte
ripete questo invito il Signore nelle Sue Sacre Scritture. Se noi proviamo a stare nella gioia
tutto il giorno, perché amiamo Gesù Abbandonato, superiamo le prove con l'amore a Lui
ecc., allora potremo dire di essere intonate col Collegamento.

         Ma che cosa ha contribuito a scegliere questa volta proprio la gioia? La sottolineo
perché ho ricevuto in questi giorni una lettera del Santo Padre, in cui dice alcune cose - e
due in modo speciale - che sono, nonostante noi, degli autentici apprezzamenti per il nostro
lavoro. E questo non può che portare gioia, quella gioia che è una manifestazione dello
Spirito Santo, un Suo dono.

         Sapendo di farvi piacere vi comunico ora il testo della lettera. Dice così:
         "Gentile Signorina,

                                       grazie per il ricordo che ha avuto per me per il Santo Natale e
per i voti augurali che mi ha trasmesso anche a nome di tutto il benemerito Movimento dei
Focolari.

         Lei, gentile Signorina, ha un posto speciale nelle mie preghiere quotidiane, come
ebbi a ricordare anche ai Focolarini che sono venuti a farmi visita nel Palazzo Apostolico di
Castel Gandolfo la sera del 28 dicembre scorso; e con Lei rendo grazie al Signore per il
servizio che il Movimento offre alla Chiesa.

         Con il più fervido augurio per il nuovo anno e con la mia benedizione,
                                                           Joannes Paulus PP II"
         Parla dunque di "benemerito Movimento" e dice di "rendere grazie al Signore per il
servizio che il Movimento offre alla Chiesa". Due frasi che possono far riempire il cuore di
gioia.

         Bello, eh! Siete contente? Non voglio dire ciò e sottolineare questi punti perché
abbiamo da inorgoglirci - è logico -, ma per avere un altro, ulteriore motivo di gioia. E allora
non c'è che da augurarci che il Signore c'invada con la Sua gioia.

         Ciao a tutte e a tutti!

Mollens 27 gennaio 1994

Il dono di mons. Hemmerle"

Carissimi,

         eccoci riuniti tutti per il Collegamento di febbraio.

         "Un mese di dolore" ho detto, ma anche "di gioia e di gloria".

         "Di gloria" perché mons. Hemmerle con la sua partenza ci ha dato modo di
contemplare in lui una incarnazione dell'Ideale, a gloria di Dio e sua.

         Sì, questo ho avvertito appena ci ha lasciato: l'immenso dono a noi della sua persona
trasformata in Gesù per mezzo dell'Ideale.

         Ora non abbiamo solo l'Ideale da impersonare, ma abbiamo una creatura che ce lo
svela fatto vita.

         E' un dono ulteriore. Dio ha tenuto lo stesso metodo nel manifestare il Suo amore a
noi: nell'Antico Testamento è venuto con il Suo Spirito fino a noi parlandoci per mezzo dei
profeti; nel Nuovo ha fatto sì che la Sua Parola s'incarnasse e abbiamo avuto fra noi Gesù
che ha parlato, oltre che con la Sua bocca, con la Sua vita intera.

         Se si passano in rassegna i punti della nostra spiritualità ci si accorge che mons.
Hemmerle li ha vissuti tutti e chiunque vuol approfondirli basta guardi a lui.

         Dio era tutto per lui e il fare la Sua volontà l'impegno costante della sua vita.

         Era la Parola vissuta, cosicché qualcuno che lo ha conosciuto da vicino afferma di
poterlo definire così: "Un innamorato della Parola di Dio".

         Chiunque lo ha avvicinato ha conosciuto il suo amore personale. L'amore reciproco
poi lo istillava in tutti, anche fra i "Vescovi amici", di cui si occupava.

         Gesù Abbandonato non lo perdeva mai di vista e Maria era la sua dolce Madre.
         Fu definito un sacerdote "secondo il cuore di Dio" e per questo servì la Chiesa
veramente lasciando vivere in lui lo Spirito Santo.

         L'unità era tutta la sua vita, secondo la sua Parola di vita: "Io sono nel Padre e voi in
me e io in voi".

         E in tal modo si è così arricchito interiormente, che non è difficile vedere in lui un
santo secondo la nostra spiritualità.

         Perciò ora che è partito, è rimasto di fronte a ciascuno di noi come un prototipo del
nostro Ideale.

         Conoscendo la sua vita a fondo saremo interiormente illuminati e trascinati a
servire meglio il Signore.

         Rendervi coscienti di ciò era il mio desiderio.

         Così attingeremo a questo dono copiosamente.

         Ciao, popi: rimaniamo nella gioia.

         Ciao, popi, ciao!$doc1757$, 'drive_import', '01757-WEB-1992-05-28-stare-nella-gioia-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1757)
on conflict (document_id, language) do nothing;
