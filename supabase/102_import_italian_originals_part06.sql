-- 102_import_italian_originals_part06.sql (6/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1658-1677 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1658, 'ITA', $doc1658$Rocca di Papa, 13.11.1986

QUALITÀ IMPEGNATIVE PER CHI VUOL FARE UN SANTO VIAGGIO

Carissimi,

Siamo, dunque, sempre in viaggio per giungere alla meta che speriamo sarà, se Dio ci aiuta,
coronata dalla santità. Già parecchi fra quelli che hanno intrapreso questo cammino sono
arrivata e, a quanto possiamo sapere, con successo. Giungono notizie quasi tutte le
settimane e molto spesso c’è veramente da lodare Dio.

I più, e siamo noi, sono ancora qui su questa terra ad incitarsi vicendevolmente: il nostro
Collegamento ha appunto questo scopo.

Perché si possa far della vita un Santo Viaggio, ed essa abbia la conclusione che si desidera
L’Imitazione di Cristo, il libro di pietà e di meditazione così ricco di spiritualità che tanti di
noi conoscono, dice che occorre avere alcune qualità molto impegnative: il completo
disprezzo del mondo, l’ardente desiderio di progredire nella virtù, l’amore al sacrificio, il
fervore della penitenza, la rinuncia a se stessi e il saper sopportare ogni avversità...

Sono qualità che è necessario possediamo anche tutti noi. Dobbiamo però chiederci:
secondo la nostra spiritualità, in che maniera possiamo acquistarle?

La risposta è chiara e sicura: noi non siamo chiamati da Dio a realizzare tutto questo
attraverso una vita monastica e separata dal mondo. Siamo chiamati a rimanere in mezzo al
mondo e ad arrivare a Dio attraverso il fratello, attraverso perciò l’amore al prossimo e
l’amore reciproco.

È impegnandoci a camminare per questa originale ed evangelica via che troveremo come
per incanto arricchita la nostra anima di tutte quelle virtù.

Occorre il disprezzo del mondo.

Non c’è miglior disprezzo per una cosa che l’oblio di essa, la dimenticanza, la noncuranza.

Se noi siamo tutti tesi a pensare agli altri, ad amare gli altri, non ci curiamo del mondo, lo
dimentichiamo, quindi lo disprezziamo, anche se ciò non ci dispensa dal fare la nostra parte
per allontanare le sue suggestioni quando ci assalissero.

Occorre progredire nella virtù. Ma è con l’amore che si raggiunge ciò. Non sta forse scritto:
“Corro per la via dei tuoi comandamenti, perché hai dilatato [con l’amore] il mio cuore ” (Sal
119, 32) ?
Se amando il prossimo si corre nell’adempiere i comandi di Dio, vuol dire che si progredisce.

Occorre l’amore al sacrificio.

Amare gli altri significa proprio sacrificare se stessi per dedicarsi al fratello. L’amore
cristiano è sinonimo di sacrificio, anche se comporta grande gioia.

Occorre il fervore della penitenza. È in una vita d’amore che troveremo la migliore e
principale penitenza.

Occorre la rinuncia a se stesso.

Nell’amore verso gli altri c’è sempre implicita una rinuncia a se stessi.

Occorre infine saper sopportare tutte le avversità

Molti dolori non sono forse causati nel mondo dalla convivenza con gli altri?

Dobbiamo saper sopportare tutti e amarli per amore di Gesù Abbandonato. E supereremo
con ciò molti ostacoli della vita.

Sì, nell’amare il prossimo troviamo un modo eccellente per fare della vita un “santo viaggio”
.

Impegniamoci allora a vivere questo nostro amore in maniera così totalitaria, così radicale,
così sofferta, spendendo per esso tutte le nostre forze; proponiamo di renderlo così
concreto, come vero servizio, che esaminandoci possiamo riconoscere: sì, per l’amore ho
dimenticato il mondo, ho progredito nelle altre virtù, ho sacrificato me stesso, ho fatto
penitenza, ho rinunciato al mio io.

E allora, avanti.

Continuiamo in questi prossimi quindici giorni a mettere a centro della nostra vita l’amore
al fratello e l’amore reciproco.

Sarà il miglior modo per prepararci all’Avvento, il periodo dell’anno in cui attendiamo la
venuta del Signore.

Per questo amore Gesù rinascerà in noi, e fra noi, e quale miglior modo per prepararci al
Natale?$doc1658$, 'drive_import', '01658-WEB-1986-11-13-qualit-impegnative-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1658)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1659, 'ITA', $doc1659$Rocca di Papa, 27.11.1986

CHI È IL LAICO PER LA CHIESA

Carissimi,

Il 1986-’87 è un anno importante per il mondo cattolico. In esso, infatti, ci si sta preparando
alla celebrazione del Sinodo dei Vescovi, che si terrà in autunno, su “Vocazione e missione
dei laici nella Chiesa e nel mondo a vent’anni dal Concilio Vaticano II”.

Anno importante per i laici cattolici, ma anche – penso – per gli altri cristiani, nelle cui
Chiese spesso s’è dato tanto rilievo ai laici.

E anche noi, che desideriamo essere dei cattolici impegnati, Ci stiamo preparando a questo
Sinodo con la preghiera, che non deve mai mancare, e con il lavoro che ci viene richiesto.

Ma “chi è il laico”? È la domanda oggi ricorrente nella Chiesa. Quale il modo di identificarlo,
di definirlo? Molti Si sforzano di dare una risposta. Non si vorrebbe, infatti, definire il laico
soltanto per ciò che egli non è: colui che non è né sacerdote, né religioso. Si vorrebbe invece
stabilire chi è.

Ed è per questo che noi pure vogliamo portare un contributo allo studio di questo
argomento, affermando qualcosa che può sembrare l’uovo di Colombo: il laico è il cristiano
Come tale, è seguace di Cristo e del suo Vangelo. Per questo deve vivere in pieno quanto
Gesù vuole da lui, e lavorare anzitutto ad estendere il Regno di Dio, a costruire la Chiesa.
Dato poi che egli ha la possibilità di trovarsi in mezzo al mondo, porterà lì la luce del
Vangelo, informando ogni cosa. di essa.

Questo è il laico per noi. Un seguace di Cristo ben stagliato, che ha il doppio compito di
costruire la Chiesa e di cristianizzare il mondo.

Ed è in questo tipo di laico che ci troviamo specchiati tanto bene anche tutti noi, laici del
Movimento dei Focolari.

Il nostro Movimento, infatti, ha un aspetto più spirituale, se così si può dire, dove si opera
perché cresca Cristo in noi, fra noi e fra molti, e ciò significa edificare la Chiesa; e un aspetto
più umano, più concreto, dove si lavora per informare dello spirito di Cristo le varie
espressioni del mondo.

Ci troviamo bene in questo tipo di laico, e ci sentiamo per esso in tanta sintonia con quanto
ha definito al riguardo il Concilio Vaticano II.
Ci troviamo bene e vorremmo quest’anno vivere sempre meglio la nostra specifica
vocazione di laici, per dare anche così il nostro contributo al Sinodo.

Cosa fare allora, in questi prossimi quindici giorni?

Cerchiamo di essere veri laici della Chiesa, e cioè autentici seguaci di Cristo.

Questi vivono le sue parole e quant’altre la Sacra Scrittura propone.

Noi in questo mese ne abbiamo una splendida, che sottolinea quanto s’è vissuto il mese
scorso sull’amore reciproco. Essa dice: “Accoglietevi gli uni gli altri come Cristo accolse voi,
per la gloria di Dio” (Rm. 15, 7). Attuando questa Parola fra noi manterremo saldo il
fondamento su cui è edificata la nostra Opera, che è Chiesa.

Mettendo in pratica questa Parola con altri cristiani, là dove possiamo trovarci ad operare
inseriti nelle strutture ecclesiali, daremo ancora il nostro specifico contributo allo sviluppo
della Chiesa.

Realizzando poi queste parole nel mondo della famiglia e nei vari mondi della società,
metteremo la base più importante per poter conseguire il rinnovamento cristiano di leggi e
strutture.

Questo Collegamento – come avete sentito – è fatto in modo speciale per i laici.

Ma la Parola di Vita è per tutti: laici, sacerdoti e religiosi. Attuiamola, ognuno nei rispettivi
campi d’azione.

Accogliamo ogni fratello come Cristo ci ha accolti.

Egli ci ha accolti e ci accoglie tutti i giorni e ad ogni ora quando ricorriamo a Lui. Chiunque
noi siamo, peccatori o santi, giovani o anziani, belli o brutti, sani o malati, egli ci accoglie
sempre tutti. E siamo così certi del suo ascolto, del suo perdono e della sua accoglienza, che
non ci passa nemmeno un attimo per la mente che possa essere diverso.

Facciamo così anche noi coi nostri fratelli. Che essi trovino in noi il cuore sempre aperto,
sempre disposto, sempre accogliente.

Viviamo così. E sia per la gloria di Dio.$doc1659$, 'drive_import', '01659-WEB-1986-11-27-chi-il-laico-per-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1659)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1660, 'ITA', $doc1660$Rocca di Papa, 11.12.1986
NATALE CON CHI SOFFRE

Carissimi,
Oggi è Natale e il nostro Collegamento non poteva cadere in data migliore.
Siamo, infatti, nella possibilità di farci reciprocamente gli auguri in diretta.
Auguri di che?
È logico: auguri d’un Santo Viaggio percorso insieme in questo ’86-’87, che vogliamo diventi
l’anno più santo della nostra vita.
Auguri a tutti, ma specialissimi ad una categoria di persone. Oggi il calore del Natale porta a
sentirà tutti più famiglia, più uno fra noi, più fratelli: a condividere quindi ogni cosa: gioie e
dolori.
Dolori soprattutto con quelli che, per le più varie circostanze, trascorrono questo Natale a tu
per tu con la sofferenza.
È questa la categoria di persone a cui desideriamo oggi indirizzare in modo particolare il
Collegamento.
La sofferenza!
Quella che investe totalmente a volte le nostre persone o quella che ci sfiora e mescola
l’amaro con il dolce nelle nostre giornate.
La sofferenza: una malattia, una disgrazia, una prova, una circostanza dolorosa...
La sofferenza!
Come vedere questo fatto, che interessa anche in questi giorni molto da vicino parecchie
persone del nostro Movimento, o che è sempre pronto ad apparire in ogni esistenza?
Come definirlo, come identificarlo? Che nome dargli? Di chi è la voce?
Se guardiamo con occhio umano la sofferenza, siamo tentati di cercarne la causa o in noi, o
fuori di noi, nella cattiveria umana ad esempio, o nella natura, o in altro... Quell’incidente è
colpa di Tizio; quella malattia è colpa mia; quella prova dolorosa risale a Caio...
E tutto ciò può essere anche vero, ma, se pensiamo solo in tal modo, dimentichiamo il più. Ci
scordiamo che dietro la trama della nostra vita sta Dio con il suo amore, che tutto vuole o
permette per un motivo superiore, che è il nostro bene.

Per questo i santi prendono ogni avvenimento doloroso, che li colpisce, direttamente dalla
mano di Dio. È impressionante come non si sbaglino mai in ciò.

Per loro il dolore è voce di Dio e null’altro.

Essi, immersi come sono nella Scrittura, comprendono cos’è e cosa deve essere per il
cristiano la sofferenza; colgono la trasformazione che Gesù vi ha operato, vedono come egli
l’ha tramutata da elemento negativo in elemento positivo.

Gesù stesso è la spiegazione del loro patire: Gesù crocifisso.

Per questo è persino amabile, è addirittura cosa buona.

Per questo non lo maledicono, ma lo sopportano, lo accettano, lo abbracciano

Apriamo del resto anche noi il Nuovo Testamento e ne avremo la conferma.

Non dice san Giacomo nella sua lettera: “Considerate perfetta letizia, miei fratelli, quando
subite ogni sorta di prove”(Gc 1, 2)?

Il patire dunque è addirittura motivo di gioia.

Gesù, dopo averci invitati a prendere la nostra croce per seguirlo, non afferma forse: Perché
“chi avrà perduto la sua vita” (e questo è il colmo del patire) “la troverà” (Mt 10, 39)?

Il dolore è quindi speranza di salvezza.

Per Paolo poi il patire è addirittura un vanto, anzi l’unico vanto: “Quanto a me invece non ci
sia apro vanto che nella croce del Signore nostro Gesù Cristo” (Gal 6, 14).

Sì, il patire, per chi lo considera nell’ottica cristiana, è una grande cosa; è addirittura la
possibilità di completare in noi la passione di Cristo per la nostra purificazione e per la
redenzione di molti.

Che dire, allora, oggi, ai nostri che si dibattono nella sofferenza? Che augurio far loro? Come
comportarci nei loro riguardi?

Avviciniamoli anzitutto con sommo rispetto: anche se ancora forse non lo pensano, essi
sono in questo momento visitati da Dio.

Poi condividiamo, in tutto quanto è possibile, le loro croci e cioè teniamo Gesù in mezzo con
loro effettivamente. Assicuriamoli anche del nostro continuo ricordo e della nostra
preghiera, perché sappiano prendere direttamente dalle mani di Dio quanto li angustia e li
fa soffrire e lo possano unire alla passione di Gesù, onde sia potenziato al massimo.
Aiutiamoli poi ad avere sempre presente il valore della sofferenza.

E ricordiamo loro quel meraviglioso principio cristiano della nostra spiritualità, per il quale
un dolore amato come volto di Gesù crocifisso e abbandonato si può tramutare in gioia.

Ora aggiungiamo una parola per tutti quelli che trascorrono il Natale con serenità e nella
gioia.

Essendo a conoscenza che chi si mette a camminare nella via di Dio non può sottrarsi al
patire, auguriamo a tutti di saper cogliere ogni piccolo o grande dolore che incontreranno
con amore, con grande amore, per donarlo a Gesù Bambino che oggi è nato, come i Magi
hanno offerto i loro doni. Sarà il migliore incenso, il migliore oro, la migliore mirra che
potremo deporre nel presepio.

Sia dunque questo il nostro Natale e l’impegno per i prossimi quindici giorni: condividere
ogni sofferenza con i nostri fratelli più provati ed offrire le nostre a Gesù Bambino.$doc1660$, 'drive_import', '01660-WEB-1986-12-11-natale-con-chi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1660)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1661, 'ITA', $doc1661$Rocca di Papa, 8.1.1987

L’IMMENSITà DI DIO

Carissimi,

Voglio offrirvi questa volta una piccola esperienza che ho fatto nei giorni scorsi.
In un momento di riposo ho visto un documentario sulla natura.
Ebbene: a differenza di altre trasmissioni della TV, che portano il "mondo" nell’anima e
lasciano il vuoto nel cuore (perciò occorre tantissima prudenza nell’uso di questo che è il
più diffuso tra i mass-media), quel lungometraggio ha avuto un grande effetto sulla mia
anima.
Contemplando l’immensità dell’universo, la straordinaria bellezza della natura, la sua
potenza, sono risalita spontaneamente al Creatore del tutto e ho avuto come una nuova
comprensione dell’immensità di Dio. L’impressione è stata così forte e così nuova che mi
sarei gettata subito in ginocchio ad adorare, a lodare, a glorificare Dio. Ho sentito un
bisogno di far ciò, come se questa fosse la mia attuale vocazione.
E, quasi mi si aprissero ora gli occhi, ho compreso come non mai prima, chi è colui che
abbiamo scelto come ideale, o meglio colui che ha scelto noi. L’ho visto così grande, così
grande, così grande che mi sembrava impossibile avesse pensato a noi. E questa
impressione della sua immensità mi è rimasta in cuore per alcuni giorni. Ora il pregare così:
"Sia santificato il tuo nome" o "Gloria al Padre, al Figlio, allo Spirito Santo" è un’altra cosa
per me: è una necessità del cuore.
Carissimi, Ottorino ci ha lasciato meno di tre mesi dopo la partenza di Lionello. Ambedue
hanno concluso il loro Santo Viaggio. Così Marilen, Aldo, Margrit 4 e diverse altre persone
carissime del nostro Movimento. Quale il loro compito ora in Cielo dove, spero, già si
troveranno anche per gli aiuti che tutti insieme abbiamo potuto dar loro?
Il loro principale impegno è (come per tutti gli abitanti del Cielo) quello di lodare Dio, di
glorificarlo, di adorarlo. Ora lo vedono e non possono non lasciar sprigionare da loro stessi
tutta la lode di cui sono capaci.
Noi siamo in cammino. E, quando uno viaggia, già pensa all’ambiente che l’accoglierà
all’arrivo, al paesaggio, alla città, già si prepara. Così dobbiamo fare anche noi.

Lassù si loderà Dio? Lodiamolo allora fin da questo momento. Lasciamo che il nostro cuore
gli gridi tutto il nostro amore, lo proclami, insieme con gli angeli, con i santi, con i
Mariapoliti celesti: "Santo, Santo, Santo".

Esprimiamogli la nostra lode con la bocca e con il cuore.

Approfittiamone per ravvivare certe nostre quotidiane preghiere che hanno questa finalità.
E diamogli gloria anche con tutto il nostro essere.

Sappiamo che più annientiamo noi stessi (sul modello di Gesù Abbandonato che s’è ridotto a
nulla), più gridiamo con la nostra vita che Dio è tutto e quindi lo si loda, lo si glorifica, lo si
adora.

Ma, così facendo, muore anche l’"uomo vecchio" in noi e sulla sua morte vive l’"uomo
nuovo", la nuova creatura. Ecco allora un altro modo per mettere in pratica la Parola di Vita
del mese, quella che parla appunto della nuova creatura, del Cristo in noi.

Abbiamo anche oggi, come di solito, altri quindici giorni davanti a noi da vivere, se Dio ce li
darà.

Cerchiamo tanti momenti durante la giornata per adorare Dio, per lodarlo. Facciamolo
durante la meditazione, o in qualche visita in chiesa, o alla S. Messa. Lodiamolo al di là della
natura o nel profondo del nostro cuore. Soprattutto, viviamo morti a noi stessi e vivi alla
volontà di Dio, all’amore verso i fratelli.

Siamo anche noi, come diceva Elisabetta della Trinità, una "lode della sua gloria".
Anticiperemo così un po’ di Paradiso, e Dio sarà ripagato dell’indifferenza di innumerevoli
cuori che oggi vivono nel mondo.$doc1661$, 'drive_import', '01661-WEB-1987-01-08-l-immensit-di-dio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1661)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1662, 'ITA', $doc1662$Rocca di Papa, 22.1.1987

COMINCIARE CON L’AMARE I PIÙ LONTANI

Carissimi,

La Parola di Vita di questo mese mostra quanto stia a cuore a Gesù l’amore verso il
prossimo. Essa minaccia, infatti, di giudizio non solo chi si rende gravemente colpevole
verso il proprio fratello, ma anche chi nutre sentimenti negativi come l’ira.
"Chiunque s’adira contro il proprio fratello è sottoposto a giudizio" (Mt 5, 22a).
L’amore al fratello.
Si ritorna all’amore al fratello. Ed è utile, è necessario, è bello per noi riconsiderarlo. Il fine
generale infatti per il quale siamo Opera di Maria è la perfezione della carità. Amore al
fratello. Amore sempre più sentito, profondo, perfezionato, cesellato.
A volte sentiamo che è difficile piegare il nostro cuore ad un amore più raffinato di quello
che già nutriamo verso i nostri fratelli: il nostro cuore è ancora un po’ di pietra; il nostro
amore è rozzo, superficiale, troppo sbrigativo.
Perché? Perché abbiamo ancora il cuore occupato da noi stessi, da una certa considerazione
di noi. Siamo, anche se non ce ne rendiamo conto, egoisti e superbi.
E ciò è dimostrato dal fatto che quando subiamo una qualche dura prova spirituale (che,
come terremoto, sembra sradicare tutto alla radice, avendo così l’effetto di staccarci da noi
stessi, dalle nostre cose e di umiliarci, di abbassare il nostro orgoglio), avvertiamo un amore
più comprensivo, più profondo, più facile, più spontaneo verso i nostri fratelli. È così. Viene
quindi da dedurre che la povertà e l’umiltà sono alla base della carità.
La povertà e l’umiltà.
Come procurarsele, come guadagnarsele senza aspettare i temporali spirituali? Lo si può
attuando il nostro Ideale.
Con esso si possono raggiungere, almeno nel presente, la povertà e l’umiltà perfette.
Esso insegna che per amare occorre "vivere l’altro" a mo’ della SS. Trinità. E ciò ha implicita
la non considerazione di sé, la povertà totale e l’umiltà totale.
Viviamo allora questi principi della nostra spiritualità e vivremo bene anche l’attuale Parola
di Vita.

Poniamoci di fronte ai nostri prossimi nell’atteggiamento di accogliere la loro vita in noi
perfettamente.

Così di fronte a tutti i prossimi.

E giacché parliamo di prossimi chiediamoci: Chi amare per primo? Chi amare di più? Per chi
aver preferenza?

Noi abbiamo scelto nella vita Gesù Abbandonato. Dobbiamo preferire quelli che per le
situazioni in cui si trovano ricordano un po’ il suo volto: quanti, pur cattolici vivono separati
dalla Chiesa; e poi tutti coloro che in vario modo sono più o meno lontani dalla verità che è
Cristo, fino ai non credenti.

Su questi dobbiamo soprattutto puntare.

Dobbiamo curare i nostri grappoli con lettere, con visite, con telefonate? Cominciamo dalle
persone, in certo modo, più lontane da noi.

Vivremo, allora, non solo secondo il fine generale dell’Opera che è la carità, ma anche
secondo il fine specifico del nostro Movimento che è l’ut omnes, al cui raggiungimento
sentiamo di contribuire anche attraverso i quattro dialoghi.

Mi sembra di avvertire che in questi tempi Dio spinga tutti noi verso tale traguardo.

Ed è per questo che lo ripeto nelle mie conversazioni.

E allora? Come vivere i prossimi quindici giorni?

Ravviviamo l’amore ai fratelli, facendoci così uno con essi da vivere – per così dire – la loro
vita. E incominciamo da coloro che ci appaiono più lontani dal nostro modo evangelico di
pensare e di vivere, dalle persone che non hanno fede. Cominciamo da loro. E dove è
possibile schieriamoci su tutti e quattro i fronti. Gesù Abbandonato ci attende lì. È lì il nostro
posto. È per quest’azione che è sceso in terra il nostro carisma.$doc1662$, 'drive_import', '01662-WEB-1987-01-22-cominciare-con-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1662)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1663, 'ITA', $doc1663$Rocca di Papa, 12.2.1987

CHE COSA RICHIEDE L’AMORE AL FRATELLO

Carissimi,

Sollecitati dalla Parola di Vita di questo mese abbiamo parlato nell’altro Collegamento
ancora di amore del prossimo e abbiamo visto come dovevamo incrementare i quattro
dialoghi.
L’amore del prossimo è importantissimo per noi, è di primaria importanza. Non lo
ripeteremo mai abbastanza: noi andiamo a Dio attraverso questo amore: noi incontriamo
Dio, alimentiamo l’unione con Dio impegnandoci nell’amore verso il prossimo. E quindi non
possiamo fare con frutto nemmeno il Santo Viaggio della vita se non puntiamo sempre
sull’amore del prossimo.
Ma qual è il modo di amare il prossimo?
Lo sappiamo e l’abbiamo visto anche l’altra volta.
Si ama il prossimo facendosi uno con lui, vivendo in noi la sua vita e provvedendo quindi a
ciò di cui abbisogna. Occorre farsi affamati con lui affamato e dargli da mangiare, farsi
dubbiosi con lui e offrirgli un consiglio, farsi deboli e infondergli coraggio, e così via.
Sì, amare il prossimo vuol dire tutto questo.
Ma non solo questo.
Se guardiamo a Gesù, possiamo osservare che egli ha amato il prossimo sfamandolo,
guarendolo, perdonandolo ecc. Senza, tuttavia, fermarsi a questo. Per amarlo perfettamente
e compiutamente ha sofferto e ha offerto la sua vita per lui.
Il comportamento di Gesù ci deve essere di luce. Dobbiamo dedurre da esso che anche per
noi l’amore al prossimo non può limitarsi al "farsi uno" con lui. Dobbiamo aggiungere
qualcosa d’altro. E questo qualcosa ha un nome: soffrire.
Carissimi, la vita che conduciamo su questa terra è senz’altro segnata dalle gioie, da quelle
soddisfazioni profonde che dà, per esempio, il portare il Regno di Dio, l’irradiare l’Ideale. Ma
non possiamo negare che essa è segnata anche dal dolore: malattie, tentazioni, angustie,
tormenti, miserie, incomprensioni, imprevisti dolorosi...

Che significato hanno tutte queste manifestazioni di dolore? Per quale motivo Dio-Amore le
permette? Noi sappiamo che sono un volto di Gesù Abbandonato e l’abbracciamo, ma spesso
non ci chiediamo il perché di tali sofferenze. Invece per Dio, che tutto fa concorrere al bene,
hanno sempre un preciso motivo, ogni volta che ci affliggono. Esse sono predisposte dalla
sua volontà o dalla sua permissione per la nostra purificazione o per il bene degli altri, come
per la loro conversione o per la loro rinascita spirituale o anche per il progresso del loro
cammino verso Dio.

Sì, tutto ha sempre un perché.

Osservava il Curato d’Ars che, quando s’avvicinava qualche grosso peccatore bisognoso di
conversione, il giorno prima egli doveva sostenere gravi lotte contro Satana. Ed era un
grande patire.

Anche noi nel nostro piccolo dobbiamo ricordarci che non si può esser padri e madri di
anime se non inchiodati in croce.

E allora, come dobbiamo comportarci?

Ai nostri, che si preparano per entrare nella Mariapoli Celeste, nelle lunghe ore di sofferenza
viene spontaneo, in genere, offrire tutto per l’Opera, il che significa per le persone che ne
fanno parte. S’affaccia evidente in loro l’idea che il dolore vale e va sfruttato.

È quanto dobbiamo fare anche noi: tutti protesi nel portare avanti coloro che ci sono in
qualche modo affidati, o che avviciniamo nelle giornate e nelle Mariapoli, non possiamo
limitarci ad amarli ad uno ad uno. Dobbiamo offrire a Gesù, per essi, quanto di doloroso
cogliamo nella vita. Solo così sarà feconda la nostra azione.

E facendo in questo modo avremo amato come Gesù ha amato. E avremo fatto, veramente
con frutto, un altro tratto del Santo Viaggio.

Rocca di Papa 26.2.1987

FARE LA VOLONTà DI DIO

ANCHE IN MODO EROICO
Carissimi,

Uno dei doveri che abbiamo verso Dio, è quello di ringraziarlo. Sempre dobbiamo farlo, e,
alle volte, occorre farlo in modo particolare.

È quanto avverto in questo momento: mi sento spinta, infatti, ad invitare tutti voi, legati in
cordata per il Santo Viaggio, a ringraziare Dio in modo speciale.

Quale il motivo?

È questo: al Centro ci stiamo rendendo conto una volta di più dell’enorme grazia che
abbiamo avuto con l’Ideale.

Stiamo leggendo in questi giorni le risposte delle varie zone dell’Opera al questionario
inviato in preparazione del Sinodo sui laici.

Ebbene, alla domanda: "Perché l’appello alla santità non è percepito da tutti i laici?" si
risponde che la grande maggioranza dei laici nella Chiesa non sente il richiamo alla santità
sia perché possiede una mentalità che non fa comprendere e aspirare alla santità, sia perché
non sa come raggiungere questo traguardo.

Non si comprende la santità perché la società in cui si vive, sommersa dal materialismo e dal
secolarismo, è priva di veri valori; perché l’enorme sviluppo tecnologico ha creato in molti
l’illusione che l’uomo è padrone di ogni cosa e non ha bisogno del trascendente; perché non
si trovano modelli da imitare in quanto i santi che i laici in genere conoscono sono persone
lontane dal mondo, che lo hanno abbandonato, persone consacrate.

Si ha perciò l’idea che la santità sia monopolio di un’élite. E alcuni arrivano persino a
concepirla come una cosa fuori moda, che al più poteva avere forse un suo fascino nel
passato.

Non si sa poi come raggiungere la santità, perché si vede assolutamente inconciliabile il
trattare le cose umane, in cui si è immersi stando nel mondo, con la vita dello spirito.

Carissimi, leggendo tutte queste osservazioni di moltissimi laici, ho sentito nel mio cuore
una grande riconoscenza verso Dio per quanto ci ha donato col nostro carisma e sono certa
che anche dal vostro cuore, di voi tutti incamminati nel Santo Viaggio, non può non
esplodere un inno di ringraziamento a Dio per averci illuminati sul valore della santità e
soprattutto per averci fatto conoscere il modo di raggiungerla.

Ricordate?

Erano i primi giorni del nostro Movimento. E dopo aver avuto la sensazione che un alto
muro insormontabile mi impedisse l’accesso alla santità, ecco balenare nella mia mente
un’idea semplice come tutte le cose di Dio: c’è una via alla santità buona per tutti, aperta a
tutti, adatta alle folle, all’intero popolo di Dio: è fare la volontà di Dio lì dove si è, dove Dio ci
ha posti: in famiglia, in ufficio, a scuola, in parlamento...

Ed ecco fatto il ciak fra la vita spirituale e la vita nel mondo.

Oggi molti, moltissimi non conoscono ancora questa via. Ringraziamo Dio di averci dato
l’Ideale. Per esso più di 60.000 persone sono seriamente impegnate a raggiungere la santità.
Per esso molti forse (fra i nostri Mariapoliti Celesti, per esempio) l’hanno già raggiunta.

Ringraziamo Dio e facciamoci un dovere nei prossimi quindici giorni di camminare con più
ardore per questa strada, di vivere cioè alla perfezione la volontà di Dio.

Si sa, non sempre è facile: ci sono circostanze nella vita che rendono difficilissimo questo
impegno. E allora puntiamo sul fare la volontà di Dio nel presente anche in modo eroico.

La santità, del resto, esige questo.

Se ci comporteremo così, avverrà che molti fratelli troveranno in noi quei modelli che
cercano, sentiranno in cuor loro l’attrattiva di una tale vita e si incammineranno essi pure
verso la santità.

Coraggio: viviamo la volontà di Dio nel momento presente anche in maniera eroica.$doc1663$, 'drive_import', '01663-WEB-1987-02-12-che-cosa-richiede-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1663)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1664, 'ITA', $doc1664$Mollens, 12.3.1987

GETTARE SUL PADRE
OGNI NOSTRA PREOCCUPAZIONE

Carissimi,

Spero che in questi ultimi quindici giorni ci siamo tutti sforzati di attuare la volontà di Dio
anche nelle situazioni più difficili. Spero quindi che ci sia stato qualche atto generoso e
magnanimo da offrire a Dio.
Come sapete, infatti, per riuscire a raggiungere la santità non bastano virtù vissute in
qualche modo, ma si richiede che esse siano praticate in modo sublime, eroico.
Ora, una maniera per attuare la volontà di Dio nei momenti difficili è quella di cui vi parlerò
oggi.
Voi sapete come la nostra spiritualità (che è poi la nostra via di santità) poggi su un punto
da cui è tutta scaturita: la fede nell’amore di Dio, l’essere coscienti che non siamo soli, non
siamo orfani perché c’è un Padre sopra di noi che ci ama.
Una delle applicazioni di questa fede si ha quando qualche pensiero ci preoccupa, ci mette in
agitazione. Sono, alle volte, paure del futuro, preoccupazioni per la salute, allarmi per
supposti pericoli, trepidazioni per i propri parenti, apprensione per un certo lavoro,
incertezze sul come comportarsi, spaventi per notizie negative, timori di vario genere...
Ebbene, in questi momenti, proprio in questi momenti di sospensione, Dio vuole che noi
crediamo al suo amore e ci domanda un atto di fiducia: se siamo veramente cristiani, se
siamo membri del nostro Movimento, vuole che approfittiamo di queste circostanze penose
per dimostrargli che crediamo al suo amore. E ciò significa: aver fede che lui ci è Padre e
pensa a noi. Gettare in lui ogni nostra preoccupazione. Caricarla su di lui.
Dice la Scrittura: "E ogni vostra 'ansietà gettate' su di lui perché egli ha cura di voi" (1 Pt 5,
7). In pratica – così afferma un commento – come si scarica un peso su una bestia da soma,
così i cristiani devono gettare le loro preoccupazioni sul Padre celeste.
Il fatto è che Dio è Padre e vuole la felicità dei suoi figli. Per questo si fa carico lui di tutti i
loro pesi.
Inoltre, Dio è Amore e vuole che i suoi figli siano amore.
Ora tutte queste preoccupazioni, ansietà, paure, bloccano la nostra anima, la fanno chiudere
su se stessa e impediscono che si apra a Dio col fare la sua volontà e al prossimo col farci
uno con lui per amarlo come si deve.

I primi tempi del Movimento, quando la pedagogia dello Spirito Santo cominciava a farci
muovere i primi passi nella via dell’amore, il "gettare ogni preoccupazione nel Padre" era
affare di tutti i giorni, e di spesse volte al giorno.

Si usciva, infatti, da un modo di vivere puramente umano, benché fossimo cristiani, per
entrare in un modo di vivere soprannaturale, divino. Si incominciava, cioè, ad amare.

E le preoccupazioni sono inciampi all’amore. Lo Spirito Santo, dunque, doveva insegnarci il
modo di eliminarle.

E l’ha fatto. Ricordo che si diceva che come non si può tenere su una mano una brace, ma la
si scuote subito, perché altrimenti brucia, così, con la stessa sollecitudine, dovevamo gettare
nel Padre ogni preoccupazione. E non ricordo preoccupazione messa nel cuore del Padre
della quale egli non si sia preso cura.

Carissimi, non sempre è facile credere e credere all’amore di Dio.

Ma noi dobbiamo sforzarci di farlo in tutti i casi, anche nei più ingarbugliati. Assisteremo
anche ora all’intervento di Dio volta per volta. Egli non ci abbandonerà, ma avrà cura di noi.

So di molti fra noi che si trovano in situazioni difficili. È per loro soprattutto questo pensiero
del Collegamento. Ma è anche per tutti: quante circostanze ognuno deve affrontare nella
vita!

Quanto bisogno che un Altro ci pensi!

In questi quindici giorni, allora, gettiamo ogni preoccupazione in lui. Saremo liberi di amare.
Correremo meglio nella via dell’amore che – come si sa – porta alla santità.$doc1664$, 'drive_import', '01664-WEB-1987-03-12-gettare-sul-padre-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1664)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1665, 'ITA', $doc1665$Mollens, 26.3.87

RINUNCIARE E AMARE

Carissimi,

         Ciò che caratterizza il nostro gruppo, che segue il Collegamento, è il desiderio e il
proposito di raggiungere la santità. Così, infatti, è nato questo contatto telefonico
quindicinale nell’ormai lontano 1980, e da questi intenti è sempre stato illuminato e così
deve sempre proseguire.

         I frutti? I frutti ci sono stati: lo testimoniano decine di nostri fratelli che hanno
raggiunto il Cielo – a nostro avviso – da veri piccoli santi.

         Ora tocca a noi! E la Parola di Vita del mese è un aiuto non piccolo per raggiungere la
mèta. Lo abbiamo costatato sempre e così è ancora oggi.

         Quella del mese di aprile ammonisce: "Voi infatti siete morti e la vostra vita è ormai
nascosta con Cristo in Dio!" (Col 3, 3).

         È una parola – come vedete – che parla della nostra morte spirituale e della nostra
nuova vita in Cristo.

         Una parola che ricorda la realtà in cui ci ha posti il battesimo: per esso, Cristo è nato
in noi sulla nostra morte.

         Noi stessi, per bocca dei nostri padrini, abbiamo accettato e decretato questa morte
quando per tre volte abbiamo affermato di rinunciare al demonio e alle sue seduzioni.

         Oggi non si ama parlare del demonio, si vuole dimenticarlo, si preferisce dire che
non esiste. Invece c’è, e se a lui abbiamo rinunciato al battesimo, non per questo siamo
esentati dal fare tutta la nostra parte per rinunciarvi anche durante la nostra vita. Dobbiamo
ripetere il nostro "rinuncio" sempre, perché Gesù in noi viva, cresca e si sviluppi. E ripeterlo
anche ora.

         Siamo alla fine della Quaresima e vivremo, nei prossimi giorni, la Settimana Santa. In
questo tempo liturgico la parola "rinuncio" trova proprio il suo clima adatto.
"Rinuncio". Ma come attuare il nostro "rinuncio" noi, incamminati per la via della
perfezione? Speriamo di non essere ancora nelle condizioni di dover rinunciare a grosse
offerte che il demonio ci fa, accettate le quali compiamo gravi peccati.

         Tuttavia, se fosse ancora così, o qualche volta così, dobbiamo, senza avvilirci,
mettercela tutta per vincere le tentazioni e ricominciare sempre daccapo.

         Ma le rinunce che noi – penso – dobbiamo operare sono in genere più lievi, e
comunque necessarie, perché legate al mondo, regno spesso del demonio, a cui occorre
saper dire di no. Solo così Gesù crescerà in noi senza troppi ostacoli e con lui progrediremo
nella via della santità.

         In un mondo saturo di materialismo, di consumismo, di edonismo, di vanità, di
violenza, dobbiamo saper rinunciare, ad esempio, a qualche programma della televisione
anche se non proprio cattivo, ma tuttavia ambiguo, inutile; ad una spesa superflua, a un
dolce non necessario, alla curiosità, alla bramosia del guardare indiscriminato. Dobbiamo
saper rinunciare ad uno sfogo, a vantarci, a inorgoglirci, o a parlare di noi stessi.

         Sarà necessario rinunciare alla schiavitù della moda, a cose voluttuarie, a letture
vane. Oppure ad accumulare troppi denari, a comodità eccessive, ad attaccamenti a cose o a
persone...

         Rinunciare...

         Sì, rinunciare a tutto questo e a quant’altro ci viene in mente che può o deve essere
sacrificato.

         Rinunciare con tutta generosità.

         E non dimentichiamo che il carisma del Movimento sottolinea il modo ideale di
rinunciare (anche se ammette tutto quanto abbiamo sopra detto): esso è amare il prossimo,
amarci a vicenda.

         Chi ama rinuncia anzitutto a Satana, perché il suo regno è l’odio; rinuncia a beni, a
tante cose superflue e alle vanità, perché dona quanto può in favore degli altri.

         Viviamo allora con intensità, nei prossimi quindici giorni, queste due parole:
rinunciare e amare.

         Amare e rinunciare: ecco il modo migliore per prepararci alla Pasqua di
risurrezione, perché con questo binomio faremo sì che Gesù rinasca a nuova vita in noi e vi
splenda Risorto.

         E quale modo migliore per festeggiare la più grande ricorrenza religiosa dell’anno?
RESISTI ALL’INIZIO

Carissimi,

La volta scorsa abbiamo parlato del rinunciare e dell’amare, necessari a noi cristiani perché
non l’"uomo vecchio" viva in noi, ma Gesù.

Oggi vorrei parlarvi di un altro argomento, attinente a questo, e molto importante per tutti
coloro che tendono seriamente alla santità.

C’è una parola della Scrittura che sorprende. Essa dice: "Perché eri accetto a Dio fu
necessario che tu fossi tentato" (Tb 12, 13, trad. Volgata).

Parla della tentazione. E dice chiaramente che essa può assalire non solo i cattivi, coloro che
si sono messi dalla parte del male, ma i buoni, le persone accette a Dio, amate da lui. Anzi,
dice che per tali persone la tentazione è "necessaria".

Ora, pensando che tutti noi possiamo essere fra quelli che sono amati in modo particolare
da Dio, perché arricchiti di un carisma del suo Spirito ed avviati sulla via della santità,
dobbiamo dedurre che anche per noi la tentazione è una prova necessaria.

Certamente, c’è fra noi chi ha già subito tentazioni anche grandi e chi non le ha provate.

Per chi ha già passato queste prove (anche se le tentazioni possono assalirci molte volte
nella vita) può essere di consolazione intanto sapere che esse erano motivate proprio
dall’amore di Dio per lui. Chi invece non le ha subite ancora, deve sapere (ma ciò è bene per
tutti) come comportarsi.

Anzitutto: cos’è una tentazione? È qualcosa che vuole indurci al male. Tradizionalmente si
dice che essa viene a noi dal mondo ingannatore, che adora gli idoli come l’orgoglio, la
potenza, la ricchezza; o viene dalla "carne", secondo il linguaggio biblico, che suscita cattivi
pensieri, tentazioni impure, ma anche sentimenti d’ira, di risentimento. Infine, la tentazione
può venire a noi dal demonio.

Ci sono anche tentazioni lievi come quelle di gola, di distrazione nella preghiera, di
immortificazione, di un po’ di vanità, ecc.

Le tentazioni sono permesse da Dio perché noi abbiamo modo, vincendole, di dimostrargli il
nostro amore, la nostra fedeltà.

I santi hanno sempre conosciuto prove grandi e piccole e hanno approfittato di esse per
progredire (anziché fermarsi o regredire) nella via della perfezione.
E noi? Quale l’atteggiamento caratteristico dei membri del Movimento nei confronti della
tentazione?

Noi ci sforziamo sempre di amare: di amare Dio, facendo la sua volontà, e di amare il
prossimo.

E, finché amiamo, certamente la tentazione fa breccia con difficoltà nel nostro animo perché
l’amore, la carità, genera le virtù e non i vizi. Ma può essere, e ciò è umano, che non sempre
siamo nell’atteggiamento di amare, per cui ecco allora affiorare più facilmente una
tentazione grande o piccola.

Noi abbiamo imparato che il dolore, il disagio che essa comporta in chi ha pratica di vita
cristiana, è una delle tante sofferenze che possiamo provare, uno dei tanti volti di Gesù
Abbandonato. E sentiamo il dovere di abbracciare quel dolore e di superarlo, buttandoci poi
a vivere bene il momento seguente.

Così dobbiamo fare sempre.

Tuttavia, non è bene porre la fiducia unicamente nei nostri sforzi per vincere queste prove.
Esse possono ripetersi, prolungarsi, farci anche cadere. Ecco, allora, che dobbiamo armarci
di pazienza e ripetere i nostri atti vittoriosi ogni qual volta occorra. Ma soprattutto,
dobbiamo fidarci di Dio e chiedergli nella preghiera il suo aiuto indispensabile.

Ottimo poi e necessario per vincere le tentazioni è vigilare bene fin dall’inizio, quando esse
sopravvengono, per non lasciare che varchino la soglia della nostra mente. Altrimenti il
combattimento diventa più difficile. Dice un motto: "Resisti all’inizio", che per noi significa:
abbraccia subito Gesù Abbandonato.

E infine, anche se le tentazioni fossero terribili e persistenti, cerchiamo di non soffrirne
troppo e soprattutto di non disperare.

La tentazione – lo dicono i maestri di spirito – è una cosa utile, in fondo. Essa serve a
umiliarci e a mettere quindi una buona base all’edificio della nostra santificazione. Serve
anche a purificarci e a vivere quaggiù un po’ il purgatorio che, altrimenti, dovremmo subire
tutto di là.

Nei prossimi quindici giorni, stiamo attenti a vincere ogni piccola o grande tentazione e a
vincerla subito.

Sia nostro il motto: "Resisti all’inizio".$doc1665$, 'drive_import', '01665-WEB-1987-03-26-rinunciare-e-amare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1665)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1666, 'ITA', $doc1666$Rocca di Papa, 23.4.87
I DUE PILASTRI

Carissimi,

Siamo sempre in cammino per realizzare la nostra santificazione.
Senza questo obiettivo, del resto, la vita avrebbe poco senso perché Dio, che ci ha creati, ci
ha pure chiamati alla santità. Tutti gli uomini devono perseguire questa mèta.
È universale, infatti, la chiamata alla santità. Lo si afferma tanto spesso quest’anno, in cui si
prepara per ottobre il Sinodo sui laici.
Tutti dovrebbero raggiungere la propria perfezione. E chi vi si impegna raggiunge tale
traguardo camminando per vie diverse.
Anche noi abbiamo la nostra strada. E se domandassimo ai membri interni del nostro
Movimento qual è, ognuno avrebbe una risposta da dare: ci si fa santi facendo la volontà di
Dio; ci si fa santi amando Gesù Abbandonato; ci si fa santi con la perfezione della carità.
Ed è tutto vero, se ben compreso.
Ma qual è la volontà di Dio su di noi? In che modo dobbiamo amare Gesù Abbandonato?
Quali dimensioni deve avere la carità in noi?
Per noi è volontà di Dio camminare per una via di santità collettiva.
E per fare ciò occorre avere presenti due elementi della nostra spiritualità dai quali non si
può prescindere. Noi non possiamo farci santi se non mantenendo vivo il Risorto in noi e il
Risorto fra noi.
Siamo in mezzo al mondo e, da qualsiasi parte ci giriamo, troviamo qualcosa che è in antitesi
con Cristo e con la sua mentalità. Nel mondo si respira aria di consumismo, di edonismo, di
materialismo, di secolarismo dappertutto.
Come portare efficacemente e costantemente e sempre più al largo la presenza di Dio nella
società odierna?
Come difendersi dalle insidie del mondo, sempre pronte a colpirci e a scoraggiarci? Come
mantenere i propositi che facciamo nei momenti di grazia?
La Madonna con la sua Opera ci ha offerto una possibilità favolosa: ha costruito dappertutto,
in vario modo, delle piccole o meno piccole comunità che hanno per vocazione di tenere
Gesù presente in mezzo a loro.

Chiede, quindi, non solo di superare le personali difficoltà con l’abbraccio di Gesù
Abbandonato perché il Risorto sia in noi, ma anche di costruire l’unità con i fratelli perché il
Risorto sia in mezzo a noi.

Lei sa che da soli, in un mondo come il nostro, sarebbe difficile farcela. E per questo ha
"inventato" questa spiritualità che si dice collettiva appunto perché vissuta da più persone
insieme.

Noi tutti, del resto, siamo testimoni di questa necessità.

Ricordo ancora i primi tempi quando, dopo aver scoperto la realtà di Gesù in mezzo, si
vedeva con evidenza il grandissimo nuovo contributo che egli portava alla nostra vita
spirituale.

Prima, infatti, da soli, si avvertiva tutta la propria fragilità, la debolezza della nostra volontà
inconcludente, il dubbio sulle scelte fatte per Dio; non si capiva come poter vivere il
Vangelo.

E così è anche oggi. Dove si è nuovamente attratti dal mondo e dalle sue proposte? Dove ci si
arrende più facilmente nella lotta che quotidianamente occorre sostenere per essere
cristiani e membri del nostro Movimento? Dove sorgono più facilmente dubbi sulla propria
vocazione?

È là dove vien meno la presenza di Gesù in mezzo, là dove si è soli.

Ed è logico: "Guai a chi è solo..." (Qo 4, 10b), è scritto nella Scrittura, mentre: "Il fratello
aiutato dal fratello è come una città forte".

Il fatto è – come magnificamente spiega Giovanni Crisostomo – che "grande è la forza
proveniente dall’esser riuniti... perché, stando riuniti insieme, cresce la carità; e, se cresce la
carità, necessariamente cresce [fra noi] la realtà di Dio".

È Dio dunque quella forza che emana dall’unità. È Gesù in mezzo a noi.

Perché possiamo raggiungere la mèta della santità con successo per noi, che percorriamo la
via dell’unità, Gesù in mezzo è essenziale.

Pena il nostro fallimento, noi dobbiamo sempre ravvivare la sua presenza nei nostri
focolari, nei nostri nuclei, nelle nostre unità, nei nostri convegni, nei centri, nelle nostre
famiglie. E se la volontà di Dio ci vuole dispersi e soli nel mondo, dobbiamo cercare ogni
occasione per stabilire la sua presenza con qualche altro fratello di Ideale. Solo così avremo
quella luce, quella forza, quella pace e quell’ardore che sono indispensabili alla nostra piena
realizzazione.
Dobbiamo quindi raggiungere la santità mantenendo vivo il Risorto in noi con l’amore a
Gesù Abbandonato e fra noi con lo stesso amore.
Questo è ciò che Dio e Maria hanno pensato per noi.
È solo in questo modo che ci faremo santi.
Prendiamo coraggio allora e sistemiamo qualche rapporto, se c’è qualcosa da sistemare.
Ne guadagnerà il nostro Movimento e quindi la Chiesa, perché – lo sappiamo tutti – è l’unità
soprattutto che lo fa avanzare.
Nei prossimi quindici giorni lavoriamo a che il Risorto risplenda in noi e fra di noi.$doc1666$, 'drive_import', '01666-WEB-1987-04-23-i-due-pilastri-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1666)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1667, 'ITA', $doc1667$Rocca di Papa, 26.5.87

NON RISPARMIARSI NEL COMUNICARE L’IDEALE

Carissimi,

L’Anno Mariano è iniziato e noi l’abbiamo accolto con il proposito di vivere, sull’esempio di
Maria, quali madri o padri di chiunque incontriamo durante la giornata.

Tale proposito, suggerito nell’ultimo Collegamento, è entrato così profondamente
nell’animo dei membri interni del nostro Movimento ed ha portato così buoni frutti – come
ho potuto costatare dalle vostre reazioni – che non viene nemmeno in mente di sostituirlo
ora con un altro, quanto piuttosto nasce il desiderio di mantenerlo ancora perché diventi
vita della nostra vita.

Questa volta vorrei perciò semplicemente approfondirlo con voi, illuminandolo con la nuova
Parola di Vita. Essa dice: "A ciascuno è data una manifestazione particolare dello Spirito per
l’utilità comune" (1 Cor 12, 7).

Ognuno di noi ha senz’altro dei doni personali, dei talenti particolari di grazia o per lo meno
di natura. Essi ci sono stati dati da Dio per un fine: l’utilità comune, l’edificazione della
comunità cristiana. Noi li traffichiamo come si deve se non li custodiamo gelosamente per
noi, ma li mettiamo al servizio degli altri.

Accanto ad essi, però, c’è – come sapete – un dono specialissimo nel nostro cuore. È il
grande, il divino carisma di questa Opera di Dio. Voi tutti ne partecipate. Esso ha dato e dà
vita al nostro Movimento, l’ha sviluppato, lo sviluppa e lo sostiene. Esso non è un carisma
qualunque dello Spirito Santo. È, penso, un dono straordinario come quelli che vengono
elargiti a chi ha un compito speciale nella Chiesa o ai fondatori di nuove famiglie religiose o
di Movimenti.

Voi tutti lo possedete nel cuore come un meraviglioso regalo di Dio e come una
responsabilità.

Quale perciò il vostro atteggiamento nei suoi confronti? Conoscete la parabola dei talenti.
Essi vanno fatti fruttare secondo la loro finalità, perché non ci vengano tolti e dati ad altri.

Ora, il fine per cui ci è stato dato questo carisma non è solo quello del nostro bene spirituale,
ma anche il bene degli altri. Lo Spirito dona un carisma per la comunità, per la cristianità.
Noi non possiamo tenerlo solamente per noi, per la nostra santificazione, ma dobbiamo
comunicarlo ai prossimi.
Non possiamo esimerci da questo compito. Così facevamo i primi tempi, così dobbiamo fare
anche ora.

E qui ritorna la figura, l’esempio della madre.

Se una madre, come abbiamo visto, ha tra le sue qualità specifiche quella di tutto coprire del
suo figlio, di tutto sperare, di tutto credere, ha anche come sua caratteristica quella di vivere
per gli altri, senza risparmiarsi mai.

È quel che dobbiamo fare anche noi. Non risparmiarci nel donare a larghe mani il nostro
Ideale a tanti e dappertutto. Cogliere, a questo fine, ogni occasione. Ed anche suscitarle.

Il nostro grappolo è un po’ poco curato? Nei prossimi quindici giorni facciamo qualcosa di
specialissimo per esso.

Ci sono Giornate, Mariapoli, Genfest in vista? Approfittiamone per metterci a disposizione
per ogni servizio. Soprattutto per il servizio della parola. Il dono dell’Ideale è un dono di
profezia. Per comunicarlo, occorre anche parlare.

Noi diciamo sempre che per amare bisogna prima farsi uno con i prossimi in tutto, tranne
che nel peccato. E questo va bene. Ma non vorrei che ciò divenisse per noi un pretesto per
non affrontare il rischio della parola. Dobbiamo star attenti a non confondere la vera con la
falsa prudenza, sì da arenarci in un deprecato silenzio.

Gesù si faceva uno senz’altro con tutti, cambiando l’acqua in vino, moltiplicando i pani,
sedando la tempesta, guarendo gli ammalati, risuscitando i morti. Contemporaneamente,
però, parlava. E come parlava! E la parola gli attirava l’amore e anche l’odio.

Così sarà anche di noi, ma non per questo dobbiamo tacere.

Ascoltiamo bene la voce interiore che ci guida, e quanto desiderano anche i nostri
responsabili: ci saranno date possibilità sempre nuove per comunicare il nostro dono
opportunamente e anche, come esorta san Paolo, inopportunamente.

Proseguiamo dunque nei prossimi quindici giorni il Santo Viaggio con questo motto:
Non risparmiarsi nel comunicare a tanti l’Ideale.
Fiorirà una nuova vita anche per noi; il Risorto risplenderà meglio; la gioia crescerà nei
nostri cuori.

Rocca di Papa,3 11.6.1987

COME INCREMENTARE L’UNIONE CON DIO

Carissimi,
La volta scorsa, ricordandoci di quale dono o carisma (come lo chiama il Santo Padre) il
Signore abbia arricchito la nostra anima, abbiamo deciso di farlo fruttare al massimo, non
risparmiandoci nel comunicarlo agli altri.

E così, spero, abbiamo tentato di fare e sempre faremo. È un grande talento, che non va
certo sotterrato.

Ma se analizziamo bene questo dono, quest’Ideale dell’unità, vediamo che esso ha una
doppia faccia e persegue un doppio fine.

Non ci è stato dato soltanto perché, comunicandolo, realizziamo l’unità con i nostri fratelli,
ma anzitutto perché, vivendolo, raggiungiamo l’unione con Dio.

L’unione con Dio.

A che punto è per tutti noi, che ascoltiamo questo Collegamento, l’unione con Dio?

Anzitutto: è essa una realtà viva dentro il nostro cuore? A quale intensità, a quale profondità
è pervenuta? Come si esprime, come si manifesta?

Noi sappiamo che Dio fa nascere, incrementa, sviluppa l’unione con lui in vari modi.

La stessa carità verso i nostri fratelli è causa dell’unione con Dio.

Egli, poi, fa crescere questa unione con tutte le prove della vita ben portate.

Inoltre, l’unione con Dio si sviluppa per mezzo di tante molteplici grazie che egli dona alla
nostra anima. San Paolo, enumerando le sue, parla addirittura di rivelazioni. Per noi
possono essere state ed essere illuminazioni particolari, impulsi divini alla nostra volontà
per sempre rinnovate conversioni, come può avvenire in occasione dei nostri convegni, per
la forte presenza di Gesù in mezzo.

Ora, certamente tutti noi ci siamo sforzati di amare il prossimo; tutti noi abbiamo superato
delle prove e tutti noi abbiamo ricevuto delle grazie.

La pianticella della nostra unione con Dio, dunque, dovrebbe aver fatto la sua apparizione
ed essersi sviluppata nella nostra anima e potrebbe raccontarci una sua storia.

Ecco – può dire chiunque di noi – che già dai primi giorni in cui ho incominciato a vivere
questa nuova vita ho avvertito Qualcuno in fondo al mio cuore che mi ha attirato in un
raccoglimento inconsueto, prima non conosciuto.

Ecco, potrebbe aggiungere un altro, che un giorno con mia sorpresa mi sono sentito spinto
interiormente ad entrare in chiesa e ad immergermi in un colloquio spontaneo con Gesù che
mi ha rifatto l’anima.
Ecco che, dopo aver superato certi dolori, ho costatato che il mio rapporto con Gesù si è
approfondito.

Ecco, è forse l’esperienza di un altro, che per me la preghiera ora è diversa da quella d’un
tempo: nonostante le mie distrazioni, che permangono, sento Gesù presente quando prego e
ho l’impressione che le mie parole vadano diritte al suo cuore.

Ecco che, mentre prima pregavo solo Gesù, ora, dopo tanti anni di vita ideale, avverto dentro
di me un rapporto anche con il Padre e con lo Spirito Santo.

Ecco che a volte, pur passando in mezzo al mondo, che distrae e che tenta, sento molto più
attraente la vita interiore, lo stare almeno un po’ con la Santissima Trinità, che vive dentro
di me.

Ecco che, mentre prima non riuscivo a trovare l’unità della mia anima con Maria, ora l’ho
trovata...

Sì, tutti, tutti noi potremmo dire qualcosa della nostra unione con Dio. Potremmo – così
come si fa per l’unità con i fratelli – elencarne i frutti.

È questo un patrimonio spirituale importantissimo e delicatissimo, che non percepiamo se
non con i sensi dell’anima; che per chi vive in mezzo al mondo è qualcosa di fuori
dell’ordinario, che ha del miracoloso. È regno di Dio dentro di noi.

Ciò che dobbiamo fare è non disperderlo, ma anzi custodirlo, raccoglierlo, ricordandoci che
fa parte di quella vita che vivremo nell’Aldilà.

E come si disperde? Lo sappiamo: con il peccato, anche veniale, e con le imperfezioni.
Dobbiamo perciò stare attenti ad evitare tutto ciò che non è perfetto: passare per questo
mondo sapendo che non apparteniamo ad esso e quindi mortificarci in tutto ciò che lo
richiede.

E come si custodisce e si raccoglie e si accresce questo patrimonio spirituale? Agendo su
quattro fronti: essendo sempre nella tensione di amare i nostri fratelli; superando ogni
piccola e grande prova, con l’amore a Gesù Abbandonato abbracciato sempre, subito, con
gioia, ricordandoci con gratitudine delle grazie che Dio ci ha elargito nella vita; e infine –
dato che si tratta di vita interiore, di rapporto con Dio – mettendo fuoco sul fuoco e cioè
curando in modo speciale la preghiera.

Nei prossimi giorni, teniamo presenti tutti questi nostri doveri e, se vogliamo
concentrarci in modo particolare su di uno, ricordiamo l’ultimo: prestiamo
un’attenzione particolare alla preghiera. Facciamo anzi una revisione della nostra
vita dal punto di vista della preghiera, da quella spontanea a quella a cui la nostra
particolare vocazione ci chiama. Cerchiamo di pregare bene, con raccoglimento,
senza rubar tempo alla preghiera; anzi, aumentiamola un po’. L’abbiamo tante volte
trascurata o fatta male! Vediamo di riparare.
Gesù, se la sua presenza si fosse affievolita dentro di noi, sarà invitato a rimanifestarsi e
l’unione con lui ne beneficerà. Avremo nuove gioie, nuove consolazioni, che ci prepareranno
ad affrontare meglio il santo viaggio della vita.

E allora ricordiamo: pregare di più e pregare meglio.$doc1667$, 'drive_import', '01667-WEB-1987-05-26-non-risparmiarsi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1667)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1668, 'ITA', $doc1668$Rocca di Papa, 25.6.87

L’UNICA STELLA

Carissimi,

Abbiamo deciso l’altra volta, illuminati soprattutto dall’esempio di Giovanna, di fare
attenzione a non sbagliare binario, ma di mantenere sempre viva nel nostro cuore la
scelta di Gesù Abbandonato.
Nel frattempo, stanno arrivando ancora da alcune parti del mondo splendide relazioni sulle
Mariapoli brevi e sulle Mariapoli-vacanze dalle quali emerge come molti, trascinati dalla
grazia di Dio e dall’entusiasmo, eleggano Gesù Abbandonato come luce della loro vita.

Ora viene da chiederci: È importante questa decisione? Ed è facile mantenervisi fedeli?
Quella di Gesù Abbandonato è una scelta indispensabile per noi.

Noi infatti, toccati dal carisma del nostro Movimento, ci sentiamo chiamati a due mète: a
farci santi e a conquistare tante persone a Dio.

Ma per farci santi occorre seguire il Santo, Gesù, ed egli ha detto a chiare note: "Chi vuol
venire dietro a me... prenda la sua croce" (Mt 16, 24). Non c’è altro modo, dunque, per farsi
santi.

Ed anche per conquistare le persone a Dio occorre fare come ha fatto lui, che ha patito ed è
morto in croce per esse: "Se il chicco di grano, gettato in terra non muore..." (cf. Gv 12, 24). È
quindi anche il nostro patire che può produrre quei frutti.

È indispensabile, dunque, per noi la scelta di Gesù Abbandonato. E ringraziamo Dio che egli
si rivela ogni volta a noi ed ai nostri, nelle varie manifestazioni dell’Opera, e ci chiama a
seguirlo. Non avremmo possibilità, altrimenti, di raggiungere i nostri fini.

Ma è facile mantenerglisi fedeli? Sì, se le prove sono piccole; no, se sono più consistenti. A
volte, infatti, proprio non è facile. Anzi è piuttosto difficile, e può sembrare pressoché
impossibile.

Anche qui al Centro veniamo a conoscenza, spessissimo, di sofferenze gravi di membri del
nostro Movimento, di dolori al limite della sopportazione, di situazioni dolorose
umanamente assurde...
Esistono prove penose che si prolungano nel tempo per mesi ed anni, senza quasi dar
tregua, e che tolgono il respiro. E si capisce come ci si lamenti e che venga la tentazione di
ribellarsi.

Il fatto è che il dolore ripugna alla natura umana.

E allora che fare? Consigliare di attenuare il proprio amore per Gesù Abbandonato, o
addirittura di rinunciare alla predilezione per lui per rimettere in cuore altri ideali come –
se pur fosse possibile – una felicità procurata illecitamente e a poco prezzo? No: occorre
incoraggiare a rimanere fedeli a Gesù Abbandonato a tutti i costi; a rimanervi fedeli anche
perché sarà lui, alla fine, la fonte della vera felicità.

Gesù non ci vuole solo nella sofferenza. Egli parla anche di pienezza di gioia. E quella si
ottiene proprio con l’abbraccio di Gesù Abbandonato. Ricordate la nostra scoperta di tanti e
tanti anni fa, dopo le prime esperienze al riguardo? Si diceva: "Non è vero che chi si butta in
braccio alla croce trovi il dolore: trova invece l’amore, trova Dio".

E, se ciò è sempre valido per le piccole prove, non lo è meno per quelle grandi. Ne abbiamo
quotidiane dimostrazioni ad esempio in chi, soffrendo di quei dolori che spesso precedono
l’avvicinarsi all’Altra Vita, irradia paradiso attorno a sé.

Bisogna allora riprendere sempre coraggio per rifare la scelta di lui abbandonato e ripetere
ogni mattina: "Perché sei abbandonato" a significare che è lui il motivo della nostra vita.

Non di meno, del resto, ci chiede il nostro Ideale. In questo modo avremo anche una
conclusione positiva del nostro Santo Viaggio e l’Opera si estenderà.

Andiamo avanti così, perché la croce di ogni giorno è sempre una novità e richiede nuovo
impegno nell’abbracciarla.

Andiamo avanti così.

Supereremo le prove tipiche di quella tappa della "Via Mariae" in cui ci troviamo e ci
prepareremo ad affrontare le nuove.

Sì, perché tutta la vita si può vedere come una lunga prova, e così un po’ appare quando si è
sotto la sferza del dolore. Ma Dio, che è Amore, alterna sempre il dolore alla gioia,
l’Abbandonato al Risorto.

E allora, se così è, camminiamo con coraggio, ma anche con speranza. Scegliamo pure Gesù
Abbandonato e amiamolo con predilezione, sapendo che è il passaggio al Risorto.

In questo modo rimettiamo a fuoco nel nostro cuore le due realtà più importanti della
nostra spiritualità, che è cristianesimo: la croce e la risurrezione.

Fatto questo, è fatto tutto.

Ricordiamo: in qualsiasi situazione ci troviamo, unica stella sia Gesù Abbandonato.$doc1668$, 'drive_import', '01668-WEB-1987-06-25-l-unica-stella-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1668)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1669, 'ITA', $doc1669$Mollens, 27.8.87

UN’UNICA PAROLA: AMARE

Carissimi,

         Continuiamo il nostro Santo Viaggio o riprendiamolo con amore, coraggio e
speranza se l’avessimo interrotto.

         Questa volta vi parlo di una cosa particolare.

         La Chiesa cattolica sta per celebrare un avvenimento a cui certamente le altre
Chiese cristiane saranno interessate per la specificità dell’argomento che vi si
affronterà. Si tratta del Sinodo sui laici, che si terrà in Vaticano nel mese di ottobre.
Vi parteciperanno cardinali, vescovi, qualche sacerdote e una sessantina di laici di
tutto il mondo, fra i quali il Santo Padre ha scelto anche me.

         Vi andrò quindi cercando di dare tutta la mia attenzione ed il mio contributo, anche
se, forse, solo indiretto, alla trattazione di un simile tema.

         La realtà dei laici, infatti, nella Chiesa, come sapete, va approfondita. Voi tutti avete
lavorato per preparare questo Sinodo e noi tutti insieme – giacché la nostra è un’Opera
prevalentemente laica – ci aspettiamo molto da esso.

         Ma sono solo i Padri sinodali e quei laici invitati che devono accollarsi le soluzioni
della vasta problematica del mondo laicale? Io penso che, essendo questo un avvenimento
di Chiesa, tutta la Chiesa dovrebbe in qualche modo parteciparvi. Almeno con la preghiera,
come faranno le suore di clausura, perché lo Spirito Santo mandi i suoi lumi.

         Per noi però non basta la preghiera. Siamo talmente cointeressati a questi problemi
che dobbiamo fare qualcosa di più. Anche perché, come ho visto negli incontri preparatori,
l’influenza delle idee di un Movimento laico, suscitato nel presente secolo dallo Spirito
Santo, potrebbe essere notevole.

         E allora, cosa fare? Non potendo partecipare tutti materialmente al Sinodo, vi
parteciperemo spiritualmente vivendo, in questi prossimi giorni di vigilia e poi per tutto
ottobre, da laici perfetti.

         Gesù vedrà il nostro sforzo e manderà buone ispirazioni ai membri del Sinodo.

         Laici perfetti. Cosa distingue un laico perfetto? Lo distingue il tradurre in vita
quell’inserimento nel Corpo Mistico di Cristo che gli viene dato dal battesimo e che lo rende
partecipe delle funzioni di Cristo: sacerdotale, profetica e regale; funzioni che il laico ha in
comune con gli ecclesiastici e i religiosi (cf. LG 10-12).
         Ora i laici possono partecipare a queste funzioni di Cristo in vari modi. Ma non è qui
il posto per approfondirli tutti.

         Prendiamone in rilievo allora qualche aspetto e puntualizziamolo per viverlo bene
in questi quindici giorni.

         I laici partecipano alla funzione sacerdotale di Cristo immolando se stessi, il proprio
"uomo vecchio", e lasciando vivere l’"uomo nuovo". In altre parole, facendo di tutto perché il
Risorto viva in loro e fra loro.

         Partecipano alla funzione profetica di Cristo con la testimonianza data come singoli,
e con quella collettiva; e poi anche con la parola.

         Partecipano alla funzione regale di Cristo animando cristianamente il mondo. E un
modo di far ciò è – secondo il Concilio – quello di mettere in atto una più equa distribuzione
dei beni.

         Come pensare allora, nei prossimi quindici giorni, questi tre modi di partecipare alle
funzioni di Cristo perché siano facili da vivere? Io direi di concentrarsi su un’unica parola:
amare, amare il prossimo. Se noi ameremo, infatti, il Risorto sarà in noi e fra noi.

         Se noi ameremo, daremo testimonianza con la vita e verrà spontaneo darla anche
con la parola. Se noi ameremo, incrementeremo spontaneamente la comunione dei beni fra
noi e con gli altri.

         Andiamo avanti così. Viviamo nell’amore e dell’amore. Se così sarà vi sentirò tutti
presenti con me in quest’assise della Chiesa e le ispirazioni dello Spirito Santo verranno
colte in pienezza anche per il nostro generale contributo.$doc1669$, 'drive_import', '01669-WEB-1987-08-27-un-unica-parola-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1669)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1670, 'ITA', $doc1670$Mollens, 10.9.87

PER IL SINODO

Carissimi,

Come potete immaginare, in questi giorni mi sto preparando con l’anima a partecipare al
Sinodo.

E, come sapete, il Santo Padre mi vi ha chiamata perché, se nel nostro Movimento sono
presenti tutte le categorie di persone esistenti nella Chiesa, e anche fuori di essa, esso è
costituito in prevalenza da laici.

La nostra spiritualità, infatti, è adattissima ai laici, a persone cioè che non vivono, ad
esempio, in conventi o lontane in qualche modo dal mondo, perché è essa stessa una
protezione dallo spirito del mondo in quanto immerge nel Regno di Dio.

Voi questo lo sapete, ma passiamo una volta in rassegna i principali punti di essa per averne
una più profonda convinzione e trarne una conclusione.

Noi crediamo in Dio-Amore. È questo il punto di partenza della nostra spiritualità. Per la
fede in lui Amore siamo convinti che egli è dietro ad ogni circostanza della nostra vita:
gioiosa, indifferente e dolorosa, e lo sentiamo, così, presentissimo, pur nel trambusto della
società in cui viviamo.

E non è questa fede che ci custodisce e ci fa sentire Dio vicino pur nel clima materialista e
secolarizzato che ci circonda?

Noi ci impegniamo, per corrispondere al suo amore, a compiere con perfezione la volontà di
Dio proprio lì dove siamo: in famiglia, a scuola, al lavoro, in strada...

Ma con ciò non ci poniamo proprio in quella tipica via tracciata oggi dallo Spirito Santo per i
laici, perché possano farsi santi? Ad essi non sono consone, per raggiungere tale traguardo,
troppe preghiere o penitenze. Essi devono santificarsi trattando le cose umane, santificarsi
in quel mondo che sono chiamati ad animare dello Spirito di Cristo.

Noi non sfuggiamo la gente, come si vedeva necessario un tempo per poter vivere con
autenticità la vita cristiana, ma anzi amiamo ogni prossimo vedendo in lui Gesù. Ed ecco che
esso, anziché risultare di ostacolo alla nostra perfezione, l’aiuta: più cresce, infatti, il nostro
amore per il fratello, più s’approfondisce la nostra unione con Dio. La nostra spiritualità è
adattissima per persone che vivono in mezzo al mondo, dunque per i laici. Ma andiamo
avanti.
Noi viviamo con radicalità la Parola. Ma, se la Parola richiede il nostro impegno, essa è tanto
spesso messaggera di promesse da parte di Dio. E per esse (come il resto che arriva in
soprappiù, come il centuplo), i laici non toccano forse quasi con mano l’esistenza di un
regno che non è quello di questa terra, a tutto vantaggio della loro fede?

Noi ci amiamo a vicenda, attuiamo l’unità e abbiamo così il Risorto fra noi.

Egli è il fuoco per chi vive nel freddo del mondo; egli trasforma in oasi le nostre piccole e
grandi comunità nel deserto del mondo; egli fa Chiesa viva pochi laici uniti nel suo nome. E
si ha necessità di sentirsi così, perché si è spesso come in diaspora anche in terre da secoli
evangelizzate, ma ora scristianizzate.

Noi seguiamo Gesù Abbandonato. Ed egli è presente soprattutto nel mondo, dove i laici
possono incontrarlo sotto i più svariati volti.

Noi, noi... Tutti i punti della spiritualità, se ben pensiamo, sono adattissimi ai laici. Sembrano
fatti soprattutto per loro.

Così Maria, la prima laica, fidanzata, sposa, madre, vedova, anche se vergine.

Così lo Spirito Santo. Il laico è nella condizione di dover necessariamente ascoltare la sua
voce: non ha infatti un superiore che gli esprima il volere di Dio.

Così gli altri punti.

I laici possono attingere con enormi vantaggi alla nostra spiritualità. Anzi, verrebbe da dire
che essa è una spiritualità tipicamente laicale.

E allora, che conclusione trarne? Essere convinti della sua straordinaria utilità ed offrirla
più al largo possibile.

Il mese di ottobre non potrò trasmettere il Collegamento: l’impegno nel Sinodo me lo
impedisce. Passeranno quindi addirittura sette settimane prima che ci risentiamo.
Approfittiamone per approfondire alcuni punti della nostra spiritualità e irradiarli, attorno
a noi.

Nella prima settimana vediamo come rafforzare in noi e negli altri la fede in Dio-Amore.
Nella seconda, la volontà di Dio. Nella terza l’amore a Gesù nei fratelli.

Poi sottolineiamo in noi e nei nostri prossimi, specialmente quelli che ci sono affidati, la
necessità di migliorare nell’amore reciproco.

La settimana dopo, aiutiamoci ad abbracciare tutte le croci con amore.

Viviamo e facciamo vivere in seguito qualche parola di Gesù, soprattutto quelle che
annunciano promesse evangeliche.

Infine, ascoltiamo ed aiutiamo ad ascoltare la voce dello Spirito.
Come vedete, ne abbiamo da fare.

Ma è vivendo così che contribuiremo alla buona riuscita del Sinodo. Io vi sentirò con me e
sarò con ciascuno di voi a tenere Gesù in mezzo.$doc1670$, 'drive_import', '01670-WEB-1987-09-10-per-il-sinodo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1670)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1671, 'ITA', $doc1671$Rocca di Papa, 24.9.87

VIVERE LA VOLONTà DI DIO

CON TOTALE IMPEGNO

Carissimi,

Sono reduce, come sapete, dal Sinodo, al quale ho partecipato assieme a 230 vescovi e
cardinali della Chiesa e a 60 laici qualificati. Ho già aggiornato su questo avvenimento i
responsabili delle zone radunati a Rocca di Papa per il mese di novembre, e anche tutti voi
sarete informati, o qui al Centro nei vostri consueti incontri, o nelle zone.

Intanto, come riassumervi il tutto con poche parole? Come dirvi la straordinaria esperienza
che ho fatto, sostenuta dalle vostre preghiere?

Si potrebbe dire così: Ho visto irrompere nella Chiesa lo Spirito Santo.

Il Sinodo è un cammino di Chiesa dove ogni partecipante (e questa volta anche i laici) porta
il proprio contributo, offre il proprio tassello al mosaico, ma dove, ad un dato punto, agisce
Qualcuno che supera i singoli e l’insieme, e tutto orienta potentemente verso un fine da
nessuno previsto, verso una nuova tappa che la Chiesa è chiamata a vivere e ad attraversare
nella sua storia. Questo Qualcuno è appunto lo Spirito Santo.

Diversi sono stati gli argomenti trattati dal Sinodo, e per ognuno è stata presa una certa
posizione. Uno di questi argomenti è stato quello riguardante i nuovi movimenti ecclesiali,
quindi anche noi.

È stato ciò che in me – come potete immaginare – pur interessandomi tutto quanto riguarda
la Chiesa (laici in genere, problema della donna, ministeri, parrocchia, impegno civile e
politico dei cristiani, famiglia, gioventù ecc.) – ha suscitato maggiore partecipazione.

Gli interventi sui Movimenti sono stati vari e molto si potrebbe dire delle valutazioni che i
diversi Padri hanno dato a proposito di queste nuove realtà della Chiesa.

Ma quale il giudizio finale, quale la conclusione?

A me sembra che l’abbia espressa bene l’Arcivescovo coadiutore di Bordeaux, Segretario
speciale del Sinodo, quando ha detto, nella conferenza stampa finale, che i pastori tutti sono
stati “felici di salutare in tutti i paesi, a Est come ad Ovest, a Nord come a Sud, lo sviluppo
multiforme di movimenti di spiritualità, che fanno somigliare il tempo in cui viviamo ad
altre epoche della Chiesa, quando cominciarono a svilupparsi gli ordini mendicanti
nell’Europa del XIII secolo”.

Un momento importante, dunque, il Sinodo per i Movimenti.

Così importante che io pure sono tornata a casa a lavorare per il nostro con un accresciuto
zelo ed un grande desiderio di far tutta la mia parte – finché Dio mi dà forza e vita – perché
la nostra Opera corrisponda sempre più al disegno di Dio e alle attese della Chiesa.

Per questo anche oggi con tutti voi riprendo il cammino nel Santo Viaggio secondo le linee
che il nostro tipico carisma ci offre.

Dice la Parola di Vita del mese: “A chiunque ha sarà dato e sarà nell’abbondanza; a chi non
ha sarà tolto anche quello che ha” (Mt 25, 29).

Ma chi è colui che ha? È colui che fa fruttare i talenti che possiede, che fa il bene. Noi
diremmo: colui che ama, perché chi ama è in continua donazione.

E a chi fa il bene, a chi ama, sarà dato.

Chi ama è destinato a passare, dunque, di abbondanza in abbondanza. Lo possiamo
costatare, del resto, nel nostro Movimento: perché i suoi membri si sono impegnati ad
amare sin dai primi momenti, hanno visto fiorire attorno a loro un’opera che stende i suoi
rami fino agli ultimi confini della terra: hanno conosciuto il centuplo in tutti i sensi.

Non c’è dunque che da continuare ad amare.

È con l’amare Dio nella sua volontà e il prossimo come noi stessi che saremo colmi dei beni
di Dio, e anche dei beni spirituali.

È così facendo, perciò, che ci faremo santi.

Teniamoci allora come parola d’ordine per i prossimi quindici giorni questa: Vivere la
volontà di Dio con totale impegno.

Vivere la volontà di Dio con totale impegno sempre, nei nostri quotidiani doveri. Viverla così
quando arriva a noi con il volto di Gesù Abbandonato: di prove da abbracciare, di tentazioni
da superare, di cattive occasioni da sfuggire. Vivere con totale impegno la volontà di Dio
quando si presenta come messaggera di gioia, di consolazione e di pace. Metterci insomma
in cuore una sola idea: Vivere la volontà di Dio con totale impegno. È questo il sistema di
“avere” per poter ricevere ancor di più per noi e per molti. Questa la maniera di essere
sempre “vivi” nella nostra vita spirituale, di essere certi di camminare in una via di santità.

Facciamo così allora. Cominciamo subito.$doc1671$, 'drive_import', '01671-WEB-1987-09-24-vivere-la-volont-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1671)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1672, 'ITA', $doc1672$Rocca di Papa, 12.11.87

"...E SARà NELL’ABBONDANZA"

Carissimi,

"A chi ha sarà dato e sarà nell’abbondanza [...]" (Mt 25, 29).

È ciò che sperimentiamo in questo splendido mese di novembre, in cui abbiamo qui
presenti a Rocca tutti i capizona del mondo. Mese splendido perché in esso vengono
raccolti i frutti di un anno di lavoro, un anno che per moltissimi è stato – come ci si
era proposti e come si vuole sperare – l’anno più santo della nostra vita. Anno,
quindi, in cui l’amore a Gesù Abbandonato con il trionfo del Risorto in noi e fra noi
ha avuto la meglio. Anno in cui l’amore ha vinto. Ha vinto Gesù in molti cuori. E a chi
ha Gesù è stato dato Gesù. Solo così si spiegano le innumerevoli conversioni, le
nuove vocazioni a tutte le diramazioni dell’Opera, l’espandersi del Movimento, il
concretizzarsi di opere ed opere.
Tutto è cresciuto, e si gode di ogni cosa. Ringraziamo insieme Gesù. Anche se abbiamo
presenti i molti di noi che in questi ultimi mesi sono stati colpiti da malattie o sono rimasti
vittime di incidenti, e vogliamo portare con loro la croce, non si può negare che al Centro
dell’Opera, traboccante di persone in un intenso alternarsi d’incontri, c’è aria di festa forse
come non mai. Perché l’Opera cammina su tutti i fronti, la Chiesa ne guadagna e tutto va a
gloria di Dio.

Ora stiamo tirando le fila e stendendo i punti programmatici per il nuovo anno. Si dirà in
questi giorni su cosa maggiormente puntare, come migliorare, quali aspetti sviluppare.

Senz’altro vorrò assicurarmi anzitutto – perché il Santo Viaggio sia la realtà base della
nostra vita – che tutti, cominciando dagli interni, siano nella realtà della Parola di Vita del
mese: abbiano cioè – perché a chi ha sarà dato –, abbiano amore.

L’ultima volta ci siamo impegnati ad avere più amore verso Dio compiendo la sua volontà
con totale impegno.

Questa volta – per avere di più e perché con questo ci sia dato – ripunteremo su quella
volontà di Dio che è specifica per noi e che è il modo più autentico di amare Dio: amare il
prossimo.
Vi ho spronati spesso a fare ciò. Ma non può essere diversamente. "L’amore del prossimo –
dice santa Teresa di Lisieux – è tutto sulla terra: si ama Dio nella misura in cui lo si mette in
pratica".

Sì, vogliamo puntare lì anche nei prossimi quindici giorni: vedere il volto di Gesù nel volto di
ogni fratello ed amarlo. Sapere che quando incontriamo un fratello è come accostarsi ad una
miniera da cui possiamo trarre qualche pepita d’oro. Perché amando quel fratello
arricchiamo la nostra anima. "A chiunque ha [amore] sarà dato [...]". È convinto di ciò anche
sant’Agostino che afferma: "Nell’amore del prossimo il povero è ricco; senza l’amore del
prossimo il ricco è povero".

Svegliamoci allora al mattino con questo proposito. Oggi voglio arricchirmi, arricchirmi
l’anima. E, se l’anima è ricca, anche ciò che serve al corpo arriva.

Buttiamoci dunque ad amare uno dopo l’altro i fratelli che incontriamo. Facciamo un
programma d’incontri. Siamo "interni" dell’Opera e le persone affidateci non mancano.
Amiamole con una telefonata, una cartolina, un dono. Col condividere, con l’aggiornare, con
l’infiammare.

Quando arriveremo al prossimo Collegamento, il Movimento avrà una nuova vitalità perché,
avendo amato, ci sarà dato dal Cielo altro amore e saremo nell’abbondanza. Così potremo
arricchire molti e il Regno di Dio avanzerà. Cosa vogliamo di più?

Noi qui partiamo in questa direzione e spero che tutti veniate con noi.

Se l’anno passato doveva essere l’anno più santo della nostra vita, che questo sia l’anno più
di fuoco.

I nostri fratelli e le nostre sorelle che soffrono offriranno il miglior carburante all’incendio.
Perché d’incendio si tratta, e l’incendio vogliamo. È affare di coerenza: vogliamo seguire
Gesù. E non ha detto lui che il fuoco è venuto a portare sulla terra, e che è sua volontà che
esso divampi?$doc1672$, 'drive_import', '01672-WEB-1987-11-12-e-sar-nell-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1672)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1673, 'ITA', $doc1673$Rocca di Papa, 26.11.87

AMORE E GIOIA

Carissimi,

Molti responsabili del Movimento nelle zone saranno tornati fra voi ed avranno
cominciato un serrato aggiornamento. Altri stanno per arrivare, essendosi fermati
qui per il raduno dei focolarini. Così conoscerete molte cose della nostra splendida
Opera e lavorerete ad essa con accresciuta gioia. Anche noi, qui al Centro, vediamo il
succedersi d’incontri. Essi pure motivo di gioia. Come il raduno dei focolarini,
appunto. Aveste visto che spettacolo nella grande sala di Castelgandolfo! Erano
1.200, tutti consacrati a Dio. Come non sperare che sia salita un po’ di gioia a Dio?
Come non pensare che, in questa recente festa dell’Immacolata, la Madonna sia stata
particolarmente contenta?
E gioia abbiamo provato anche per l’incontro costruttivo fra il Santo Padre ed il
Patriarca di Costantinopoli Demetrio I nella sua recente visita a Roma. Gioia, perché
alla radice di questi avvenimenti c’è un po’ anche la nostra Opera, il nostro carisma,
che ha operato sin dai tempi del Patriarca Athenagoras I.
Gioia. Sì: gioia che ci viene da tante circostanze; gioia che è anche però un dovere per noi in
questo mese. Dice la Parola: "Siate sempre lieti" (1 Ts 5, 16).

Pensando al Collegamento mi ero un po’ preoccupata in questi giorni: non abbiamo ancora
approfondito e messo bene in pratica il precedente, quello sull’amore al fratello che
arricchisce l’anima, che già è ora di passare ad un altro. Ma ecco che il pensiero della gioia
da vivere mi si è subito collegato con questo amore. Il nostro Ideale, infatti, ci ha sempre
insegnato che la carità verso il prossimo è fonte di gioia. Ne ho trovato anche una piccola
conferma in due frasi di due scrittori che mi sono particolarmente piaciute. Una dice:
"Semina la gioia nel giardino di tuo fratello e la vedrai fiorire nel tuo" (J. Journer). E l’altra:
"Nella vita non v’è che un modo di esser felici: vivere per gli altri" (Tolstoi). Ed ho pensato
allora che per vivere bene la Parola attuale era opportuno continuare ad amare. Così mi è
stato chiaro che non occorreva cambiare programma. Fra i tesori che avrebbero abbondato
nel nostro cuore per aver amato, avremmo trovato anche la gioia.

"Siate sempre lieti". Dobbiamo essere sempre contenti. Dobbiamo, in pratica, essere noi.
Giorni fa una persona ci ha chiesto se il sorriso e la gioia sono un punto della nostra regola.
Non è così. Ma è sempre stato osservato che la gioia è un distintivo dei membri del nostro
Movimento. Appunto perché la loro vita è amore.
Continuiamo allora ad amare.
E continuiamo a farlo come conviene in quest’anno che vogliamo sia di fuoco.
Più ardente sarà l’amore, più aumenterà la gioia e ne avremo molta da distribuire al mondo.
Sarà poi con questo binomio: amore e gioia, che ci prepareremo nel migliore dei modi a
Natale.
Gesù è venuto al mondo per amore e per comunicarci la sua gioia. È venuto in terra per noi,
per liberarci da ogni schiavitù e dalla morte. E con ciò ci ha introdotti nella sua vita trinitaria
che è beatitudine, che è gioia.
Ricordiamo: "Siate sempre lieti"! Sempre.
Non lasciamo passare un attimo senza amare e non saremo un solo attimo senza gioia.
Che "gioia" sia, in questo mese, il nostro secondo nome.$doc1673$, 'drive_import', '01673-WEB-1987-11-26-amore-e-gioia-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1673)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1674, 'ITA', $doc1674$Rocca di Papa, 10.12.87

LA GIOIA CHE FIORISCE DALL’OBBEDIENZA

Carissimi,

Abbiamo sottolineato nell’altro Collegamento di dicembre la necessità di essere nella gioia
per adeguarci alla Parola di Vita di questo mese che dice: "Siate sempre lieti!". E abbiamo
visto come fonte della gioia sia l’amore al fratello, che abbiamo voluto mettere in pratica con
particolare impegno anche per prepararci a Natale, facendo nostro il binomio: "Amore e
gioia".

Domani è Natale, la più sentita festa cristiana, e alla S. Messa, che ricorda il grande evento,
ma anche con il presepio, l’albero, i tipici canti, i doni, saremo avvolti da un’atmosfera
caratteristica che infonde pace, gioia; che suscita meraviglia, stupore, gratitudine; che dice
novità: la novità sempre nuova di Dio che s’è fatto uomo per noi. E nuovo vorremmo che
tutto fosse: nuova l’anima, magari con una bella confessione, nuovo l’ambiente che ci
circonda per gli immancabili addobbi natalizi, nuovo il vestito che forse indosseremo.

E per noi, incamminati nel Santo Viaggio, in quest’anno di fuoco, nuovo anche "il modo" per
essere lieti ed avere gioia da offrire come incenso a Gesù Bambino.

Nuovo il modo. Sì, c’è un modo nuovo per essere felici, che finora non abbiamo sottolineato.
L’ho sperimentato tante volte nella vita. È quello di obbedire, di saper obbedire.

Ma che posto ha l’obbedienza nella nostra spiritualità? mi domanderete. E che rapporto ha
con la gioia?

L’obbedienza ha un posto importante nella nostra spiritualità, anzitutto perché, essendo
essa una spiritualità cristiana, non può non contemplare tutte le virtù.

Poi perché la carità, che indiscutibilmente ci distingue, genera l’obbedienza.

Sapete come la carità è madre di tutte le virtù. Ebbene, dell’obbedienza lo è in particolare.

Dice santa Caterina da Siena che l’obbedienza e la pazienza "sono partorite dalla carità [...]. E
la principale di esse è la vera e perfetta obbedienza".

E lo si capisce: quando si ama, anche senza accorgersi, si obbedisce alla persona amata. Lo si
fa con Dio, perché proprio per volerlo amare ci si impegna ad obbedirlo nella sua volontà.
Lo si fa con il fratello, perché amare significa proprio immedesimarsi con i pensieri, con i
gusti, con i desideri degli altri.
Quest’anno sentirete parlare molto dell’obbedienza; la vogliamo approfondire come
puntello all’unità. La sentirete descrivere in modo tradizionale e in quella luce particolare
che le dona il nuovo carisma che Dio ci ha dato e la fa apprezzare proprio dall’umanità di
oggi.

E noi impareremo meglio ad obbedire, ad obbedire a tutto ciò e a tutti coloro che ci
manifestano la volontà di Dio e in particolare a vivere con perfezione l’obbedienza anche in
seno al nostro Movimento. Esso è un’opera della Chiesa, approvata dalla Chiesa, con dei
responsabili che ci dicono come dobbiamo camminare secondo i nostri statuti.

Effetto di questa obbedienza riscoperta, ricompresa, praticata?

La gioia. La gioia, e non può essere che così.

La gioia, perché con l’obbedienza si elimina la nostra volontà che genera nell’anima il
peccato e l’imperfezione e con essi il tormento. Mentre nella volontà di Dio – lo dicono tanti
santi – è gioia e felicità.

Domani doniamo a Gesù, che ha iniziato la sua vita ed è vissuto sulla terra sempre e solo per
amore ed obbedienza al Padre, il proposito di perfezionare in noi l’obbedienza. In
particolare tutti noi, interni, aiutiamo i nostri responsabili ad attuare i 18 punti che il Centro
ha segnalato come binario per il cammino del Movimento nell’87-88. E, senza pensarci, così
obbedendo, ci impegneremo ad attingere ad una perenne gioia.

In tal modo si cammina e si abbellisce l’anima di virtù, modellandoci sempre di più su Gesù
Abbandonato in cui abbiamo sempre ammirato tutte le virtù al massimo grado, e su Maria
Desolata che abbiamo definito: monumento di virtù.

E allora: Auguri, auguri, auguri! Auguri di ogni bene, soprattutto di santità, di quella santità
tipica del nostro Movimento, che si è sempre distinto per l’obbedienza alla Chiesa e quindi a
Dio.$doc1674$, 'drive_import', '01674-WEB-1987-12-10-la-gioia-che-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1674)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1675, 'ITA', $doc1675$Rocca di Papa, 24.12.87

1988

LUMINOSI ESEMPI

Carissimi,

Siamo nel primo mese dell’anno nuovo e la Parola di Vita ci invita all’amore perfetto, cioè
all’amore vero, quello che caccia il timore (cf. 1 Gv 4, 18).

Una buona spinta quindi per proseguire nell’anno di fuoco, quale vogliamo sia quello in
corso.

Una buona occasione per eliminare dalla nostra vita ogni paura!

Quanti timori nell’esistenza di ogni uomo: timore delle circostanze, del passato,
dell’avvenire, delle malattie, della morte... Paure di ogni genere.

Timori che proviamo tutti, specie quando non siamo nell’amore, e che nell’amore e per
l’amore spariscono.

L’ho costatato con evidenza un paio di volte in questi giorni. Anzitutto quando mi sono
recata a Roma per rendere omaggio a Giovanni Zaglio, focolarino più che novantenne, dei
primi tempi, che ha offerto per decenni, con la moglie Linda, anche lei focolarina più che
novantenne, uno spettacolo di unità soprannaturale eccezionale, effetto dell’amore vero.

La salma di lui era sul letto in quella loro stanza che pareva consacrata tempio dalla
presenza di Gesù in mezzo tenuta sempre accesa. Lei stava accanto, serena, senza spargere
una lacrima, convinta che quanto era successo altro non era che il compimento del disegno
d’amore di Dio su Giovanni e per lei una delle manifestazioni del disegno di Dio sulla sua
persona e perciò la cosa migliore che le potesse accadere.

Senza timore dunque, anzi contenta pur di fronte alla morte di colui che aveva amato, per
Gesù, in un continuo logorante servizio, notte e giorno, fino a incurvarsi nella schiena, sì da
aver bisogno ora di essere sostenuta. Un esempio che è nostro dovere porre come luce sul
moggio, come città sul monte, perché molti vedano e imparino.

Un amore che tiene eternamente giovani, sicché mentre Giovanni è andato in Paradiso a
raggiungere il Dio della giovinezza, a lei è stato aperto, come di diritto, ventiquattro ore su
ventiquattro, il focolare.
L’altra occasione che ho avuto ed ho per costatare l’amore vero che caccia il timore è quella
della situazione attuale in cui si trova un nostro religioso del Centro, anche lui dei primi
tempi, prossimo al compimento del suo Santo Viaggio.

In lui la verità contenuta nell’attuale Parola di Vita è evidente e, mi sembra, in modo
straordinario.

Si chiama don Giuseppe Savastano, ma noi da sempre l’abbiamo chiamato Micor, cioè
"misericordia", per aver impersonato questa virtù in modo eccezionale. Ha sempre misurato
gli altri con amore senza limiti ed ora nel medesimo modo è misurato da Dio.

Nelle condizioni estreme in cui si trova afferma, infatti, di aver in cuore non solo la pace ma
una gioia, una gioia grande, intensa, che permane e aumenta, una gioia che non sa donde gli
venga.

Sentendolo parlare si ha l’impressione che si tratti di una grazia tutta particolare. Grazia
legata, come lui afferma, a Maria, all’Opera di Maria, al carisma, dunque, che ha vissuto con
piena fedeltà.

Gioia piena nel cuore del Padre mentre attende la morte. Gioia. E dove è finito il timore?
Gioia che la Parola di Vita spiega: La carità perfetta caccia il timore.

E allora, cosa fare noi che siamo ancora in cammino?

È chiaro: amare senza limiti, senza misura, come hanno fatto e fanno questi nostri fratelli.

Amare, e il timore se ne andrà. Non è mai troppo ripeterci che dobbiamo amare. Amare è la
vita di Dio. Deve essere anche la nostra.$doc1675$, 'drive_import', '01675-WEB-1987-12-24-luminosi-esempi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1675)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1676, 'ITA', $doc1676$Rocca di Papa, 14.1.88
MIGLIORARE LA PREGHIERA

Carissimi,

Siamo agli ultimi giorni del mese di gennaio e, prima che arrivi a tutti i nostri interni questo
Collegamento, saremo già in febbraio, mese illuminato dalla Parola: "Quando preghi, entra
nella tua camera e, chiusa la porta, prega il Padre tuo che è nel segreto" (Mt 6, 6).
Un’occasione buona per dare uno sguardo alla nostra preghiera, al nostro modo di pregare e
possibilmente per proporci di migliorarlo.
Ma vediamo un po’ qual è, in genere, per molti cristiani, il significato della preghiera.
Si prega spesso quasi esclusivamente per chiedere grazie. In momenti di preoccupazione,
d’angoscia, di bisogno ci si rivolge a Dio con orazioni e suppliche o, per arrivare a lui, si
ricorre alla Madonna e ai santi.
È una buona preghiera questa?
Certamente, essa non esaurisce il dovere di pregare che i cristiani hanno. Per questo, se è
l’unica che si pratica, è giudicata troppo interessata.
La vita cristiana infatti non è solo chiedere, è anche e principalmente dare.
Con l’aiuto della preghiera bisogna dare pure a Dio: dobbiamo, infatti, amare Dio.
Chi conosce solo la preghiera di domanda non è perciò autentico seguace di Cristo, né figlio
genuino della Chiesa.
Se invece tale preghiera è fatta nel contesto di una vita cristiana coerente, corrisponde ad
una precisa volontà di Gesù che dice: "Chiedete e otterrete, picchiate e vi sarà aperto,
cercate e troverete" (cf. Mt 7, 7).
È una preghiera dunque che siamo autorizzati a fare e che spessissimo, infatti, pratichiamo.
Con essa, tra il resto, dichiariamo la nostra impotenza ed affermiamo la fiducia
nell’onnipotenza di Dio.
Poi ci sono le preghiere che recitiamo ogni giorno: ad esempio al mattino, alla sera, o prima
dei pasti; o durante la S. Messa, la visita al SS. Sacramento, il rosario. Sono preghiere di lode,
di adorazione, di ringraziamento, che esprimono il nostro amore, fatte per dar gloria a Dio.
Sono le preghiere indicate nei nostri statuti o regolamenti.
Sono dette preghiere vocali. La Chiesa le consiglia. A volte non sono valorizzate quanto
meriterebbero perché possono diventare meccaniche e perdere così parte del loro
significato. Ma sta a noi riempirle con la mente e col cuore, pensando a quanto si dice e
amando colui al quale si parla. Esse, ripetute ogni giorno, tengono vivi e presenti i misteri
divini in cui come cristiani siamo immersi: l’incarnazione, la redenzione, la SS. Trinità, le
meraviglie operate da Dio in Maria, ecc. Molto spesso, poi, la loro recita apre spiragli di
unione con Dio.

E c’è infine la preghiera mentale. È detta così quella nella quale Dio attira l’anima alla
comunione con lui. La si sperimenta soprattutto nella meditazione, ma anche durante la
giornata. I maestri e le maestre di spirito consigliano – quando questa preghiera si fa
presente – di interrompere la preghiera vocale (se non è obbligatoria) e di immergersi in
questa cosiddetta mentale.

Credo che tutti abbiamo una certa esperienza di tale tipo di preghiera, che è tanto gradita a
Dio. E conosciamo anche i modi per esserne arricchiti: è amando il fratello in modo radicale
che avvertiamo poi nel nostro cuore l’unione con Dio; è abbracciando le croci con generosità
che approfondiamo questa comunione.

Nel mese di febbraio vediamo di migliorare tutti questi modi di pregare. Nutriremo così il
nostro spirito. Dice santa Caterina che la preghiera è come una madre che nutre l’anima,
perché è nella preghiera che si avverte maggiormente il dolore dei propri peccati e nasce
così la contrizione; è nella preghiera che si fanno buoni propositi, i quali impostano poi in
modo cristiano e ideale la nostra vita; è lì che ci si decide ad abbracciare la croce...

Dobbiamo migliorare la preghiera come cristiani ed in particolare come membri del nostro
Movimento.

La preghiera infatti ha un grande significato nella nostra spiritualità. Essa, che è definita
"elevazione dell’anima a Dio", è diretta a stabilire un rapporto con lui, una comunione. È
quindi in funzione dell’unità. E la nostra è la spiritualità dell’unità.

Amiamo allora la preghiera e pratichiamola. Assieme all’amore al fratello e all’amore alla
croce, si manifesterà come un’altra possibilità di più profonda unione con Dio. E che cosa
desiderare di più? Nulla di più dolce, di più consolante che avvertire nel nostro cuore la
presenza amorosa di Dio. Niente ci fa più forti che sentirci amati da lui. Ed è quanto ci
occorre per fare di quest’anno un anno di fuoco.$doc1676$, 'drive_import', '01676-WEB-1988-01-14-migliorare-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1676)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1677, 'ITA', $doc1677$Rocca di Papa, 28.1.88

CIÒ CHE È ESSENZIALE NELLE NOSTRE PREGHIERE

Carissimi,

Anche se può essere ovvio, anche se può sembrare superfluo, voglio con questo
Collegamento incoraggiare voi tutti e me stessa a riprendere oggi con nuova lena il nostro
Santo Viaggio.

È la cosa più intelligente che possiamo fare, la più centrata, la più giusta.

Siamo infatti diretti verso una mèta che noi non chiamiamo "morte", perché è l’inizio di una
nuova vita, ma "incontro", incontro con Gesù. Tutti vi siamo destinati, nessuno può
scamparvi.

I diversi fratelli appena partiti per la "Mariapoli Celeste" ce lo ricordano; i circa
centocinquanta interni (su sessantasettemila che siamo) malati gravemente, tengono
presente in noi questo pensiero.

Dobbiamo perciò impostare la nostra esistenza in relazione al traguardo che ci attende;
dobbiamo fare dell’unica vita che abbiamo, un viaggio, e un viaggio santo perché, tra il resto,
santo è colui che ci attende, Gesù, e domanderà a noi la santità.

Conosciamo i vari modi per raggiungere questa mèta. Oggi vorrei risottolineare quello di cui
abbiamo parlato la volta scorsa.

Ci si fa santi, infatti, stando a contatto con il Santo: dimmi con chi vai e ti dirò chi sei.

Ma stare in contatto con Gesù, con la SS. Trinità, è quel tipico atteggiamento che si chiama
preghiera, pregare.

Diamo anche oggi allora uno sguardo alla nostra preghiera. L’abbiamo già considerata in
modo generale. Ora lo vogliamo fare in modo particolare, dettagliato.

Si sa che occorre pregare sempre (cf. Lc 18, 1) e sappiamo anche come attuare ciò. Ma ci
sono delle preghiere particolari che sono un dovere per noi in precisi momenti della
giornata.

Non potremo qui esaminare preghiera per preghiera, commentare ogni pratica di pietà.
Sarebbe lavoro troppo lungo.

Ci soffermeremo piuttosto su ciò che sembra essenziale nelle nostre preghiere, su ciò che
deve esserne l’anima perché possiamo dirci autentici membri del nostro Movimento.
Noi, al mattino, appena svegli, diciamo a Gesù: "Perché sei abbandonato". Esprimiamo con
ciò il proposito di sceglierlo come tale e di preferirlo lungo tutto il giorno. E ciò è essenziale
per noi. Non si può vivere la nostra spiritualità senza questo impegno.

Poi recitiamo altre preghiere. Ma la cosa più importante, al mattino, è fare a Gesù l’offerta
della nostra giornata, dando così ad ogni attività, ad ogni incontro un motivo, un’intenzione
soprannaturale.

Alla fine della giornata, abbiamo poi le preghiere della sera. Con esse, così come al mattino,
si prega il Padre, Gesù, Maria, l’angelo custode. Ma la cosa più importante è l’esame di
coscienza: rivedere cioè la nostra giornata, ora dopo ora, e promettere sinceramente di far
meglio il giorno dopo, perché chi non avanza regredisce.

Ogni giorno, inoltre, o molto spesso, assistiamo alla S. Messa. Essa costituisce il vertice di
ogni altra preghiera, l’atto più alto della nostra giornata, il centro cui tutto deve convergere.
La vita di una creatura infatti ha significato vero se riconosce il suo Creatore, se sta verso di
lui in atteggiamento giusto, quindi se lo adora, lo ama, lo ringrazia, se a lui chiede perdono
dei propri peccati, se lo invoca. Ma tutto ciò è pressoché impossibile farlo da soli, con mezzi
nostri, scelti da noi. Siamo incapaci di offrire a Dio qualcosa di adeguato, che arrivi a toccare
il suo cuore. Dio è vicino, ma è anche immensamente grande. Occorre quindi qualcosa che
sia a lui proporzionato: non si dà ad un adulto un giocattolo, né ad un neonato un libro.

Ed ecco la S. Messa che ci dona questa insperata possibilità. Sull’altare è offerto dal
sacerdote al Padre (e noi possiamo unirci a lui nell’offerta) Gesù stesso: egli è il nostro dono,
quello che il Padre gradisce. Con lui e per lui possiamo degnamente e convenientemente
amare il Padre, adorarlo, lodarlo; chiedergli qualcosa, ringraziarlo, implorare da lui il
perdono dei nostri peccati. Con lui, con Gesù, il Padre ci ascolta.

Di qui l’importanza della S. Messa. Dobbiamo assistervi con questa coscienza. E dobbiamo
non dimenticare di mettere sull’altare anche la nostra vita assieme alla sua con tutto quanto
la riguarda: soprattutto le fatiche, le pene, le sofferenze, i tormenti, perché uniti a quelli di
Gesù acquistino il massimo valore.

Poi durante il giorno si prega prima dei pasti, e questa preghiera ha il significato di offrire a
Dio anche l’atto di sovvenire alle nostre necessità corporali.

Inoltre, si va a visitare Gesù presente nel tabernacolo di una chiesa. È, mi sembra, un atto
indispensabile. Se le grandi personalità, anche non cattoliche, sentono il dovere, quando
vengono a Roma, di chiedere un’udienza con il Santo Padre, riconoscendo in lui una
personalità di livello mondiale, che cosa dobbiamo fare con Gesù, Uomo-Dio presente in
terra nelle nostre chiese? Il minimo è fargli quotidianamente una visita. La visita quindi al
SS. Sacramento ha proprio il significato di una visita per dire a Gesù che comprendiamo ciò
che lui ha fatto per noi e per tutti, e che non ci sfugge la portata della sua presenza sulla
terra.
E ancora recitiamo anche il rosario. È la preghiera che ci incatena a Maria, tutta dedicata a
lei. Dobbiamo vivere bene questo momento come il nostro quotidiano appuntamento con la
Madre, con la Regina della nostra Opera. Con la prima parte dell’"Ave Maria" entriamo
anche noi in quella lode planetaria che lei stessa ha profetizzato quando ha detto: "Tutte le
genti mi chiameranno beata" (cf. Lc 1, 48).

Per la seconda parte, con quel "prega per noi peccatori adesso", avremo assicurata ogni
giorno la sua protezione. Mentre per quel "nell’ora della nostra morte" Maria si ricorderà di
noi alla conclusione della nostra esistenza.

Facciamo poi ogni giorno un po’ di meditazione dove – se abbiamo vissuto secondo il nostro
Ideale – possiamo sperimentare la preghiera mentale. La meditazione ha lo scopo di
mettere la nostra anima in contatto con Dio, di sperimentare già da quaggiù la vita del
Paradiso. La meditazione ha come fine di rituffarci nel divino e ritemprarci.

Preghiere del mattino, della sera, prima dei pasti, S. Messa, rosario, visita, meditazione: ecco
i momenti sacri della nostra giornata. Lavoriamo con tutto l’impegno i prossimi quindici
giorni per migliorarli, per cesellarli. Ne guadagnerà tutta la nostra vita spirituale, daremo un
importante contributo al raggiungimento della nostra perfezione, correremo più spediti nel
nostro Santo Viaggio.$doc1677$, 'drive_import', '01677-WEB-1988-01-28-ci-che-essenziale-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1677)
on conflict (document_id, language) do nothing;
