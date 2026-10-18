-- 102_import_italian_originals_part07.sql (7/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1678-1697 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1678, 'ITA', $doc1678$Rocca di Papa, 11.2.88

GUARDARE AI FRUTTI

Carissimi,

Noi parliamo di Santo Viaggio, ci incoraggiamo a percorrere la vita come un Santo Viaggio,
ma forse è bene che chiariamo una volta ancora che cos’è, come ci sembra che Dio pensi il
nostro Santo Viaggio.

Noi spesso lo immaginiamo così: una serie di giornate che ci proponiamo una più perfetta
dell’altra, col nostro lavoro compiuto bene, con lo studio, col riposo, con le ore trascorse in
famiglia, con gli incontri, i convegni, lo sport, con i tempi di ricreazione... svolti nell’ordine e
nella pace. Lo pensiamo così, siamo umanamente e istintivamente portati ad attendercelo
così, perché la vita è una continua tensione all’ordine, all’armonia, alla salute, alla pace.
Forse lo immaginiamo così, perché così sarebbe stata la vita dell’uomo se non avesse
peccato, e così sarà certamente dopo, se lo meritiamo, nell’altra Vita.

Noi, infatti, non introduciamo null’altro nei nostri programmi se non ciò che è espressione
di vita, di pienezza di vita: studio, preghiera, lavoro ecc.

E facciamo in questa maniera perché il resto è senz’altro imprevedibile, ma anche perché c’è
sempre nel cuore umano la speranza che le cose vadano così e solo così.

In realtà, il nostro Santo Viaggio poi si dimostra diverso, perché Dio lo vuole diverso. E
pensa lui stesso a introdurre nel nostro programma altri elementi da lui voluti, o permessi,
perché la nostra esistenza acquisti il vero senso e raggiunga il fine per cui è stata creata.
Ecco i dolori fisici e spirituali, ecco le malattie, ecco mille e mille sofferenze che parlano più
di morte che di vita.

Perché? Forse perché Dio vuole la morte? No, ché anzi, Dio ama la vita, ma una vita così
piena, così feconda che noi – con tutta la nostra tensione al bene, al positivo, alla pace – non
avremmo mai saputo immaginare. Ce lo chiarisce la Parola di Vita del prossimo mese di
marzo: "[...] se il chicco di grano caduto in terra non muore, rimane solo: se invece muore,
produce molto frutto" (Gv 12, 24).

Se non muore, il chicco rimane bello, sano, ma solo; se muore si moltiplica.

Dio vuole che durante la vita noi sperimentiamo una certa morte – o, a volte, molti tipi di
morte – ma perché questo è il Santo Viaggio per lui: portare frutto, fare opere degne di lui e
non di noi semplici uomini. Questo è per lui il senso della nostra vita: una vita ricca, piena,
sovrabbondante, una vita che sia un riflesso della sua.
E allora occorre prevedere queste morti e disporsi ad esse per accettarle nel miglior modo.

È saggia, quindi, indispensabile – e non è che genuino cristianesimo – quella scelta che ogni
giorno noi rinnoviamo di Gesù Abbandonato, quell’amore a lui che vogliamo preferenziale.
Esso ci predispone a far della vita un Santo Viaggio secondo il pensiero di Dio: ad accettare
le piccole o grandi morti, ma anche a vedere superato di gran lunga, potenziato e fecondato,
quanto noi avevamo programmato.

Ho letto in questi giorni un breve trattato sulle prove che Dio manda o permette in modo
particolare a chi lo segue più da vicino, a chi, come noi, vuol fare della vita un Santo Viaggio.

Sono purificazioni passive che vengono da Dio: malattie, la morte di cari, la perdita di beni,
della fama, difficoltà di ogni genere... Sono notti dei sensi e notti dello spirito dove corpo ed
anima sono purificati in mille modi con tentazioni, aridità spirituali, dubbi, senso di
abbandono da parte di Dio; con le virtù della fede, speranza e carità che vacillano; sono veri
purgatori anticipati se non quasi inferni.

Che fare? Abbandonare il Santo Viaggio pensando che con una vita più comune, secondo
l’andazzo del mondo, molte forse, o alcune, di queste prove si possono evitare? No: non
possiamo tornare indietro.

E poi qui ho elencato solo le purificazioni, ma occorre vedere quali sono le consolazioni, le
"beatitudini" (cf. Mt 5, 3-11) che una vita vissuta come Santo Viaggio porta già su questa
terra. La morte di Gesù infatti chiama la risurrezione; la morte del chicco di grano il "molto
frutto". E "risurrezione" e "molto frutto" significano, in certo modo, paradiso anticipato,
pienezza di gioia, quella gioia che il mondo non conosce.

E allora, avanti! Guardiamo al di là di ogni dolore. Non fermiamoci solo a quella
sospensione, a quell’angoscia, a quella malattia, a quella prova... Guardiamo alla mèsse che
ne verrà, se sapremo soffrire bene come il nostro ideale insegna.

È quello che ci impegneremo a fare nel mese di marzo: abbracciare ogni sofferenza per
amore di Gesù Abbandonato, prevedendo e pregustando il frutto abbondante che è alle
porte.$doc1678$, 'drive_import', '01678-WEB-1988-02-11-guardare-ai-frutti-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1678)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1679, 'ITA', $doc1679$Rocca di Papa, 25.2.88
COME CERCARE LE COSE DI LASSÙ

Carissimi,

Riprendiamo, dopo la pausa di marzo, il nostro Collegamento che ha – come si sa – lo scopo
di sostenerci tutti nel Santo Viaggio.
Luce per il cammino è sempre la Parola di Vita.
E quella che ci illumina in questo mese è precisa e affascinante: "Se siete risorti con Cristo,
cercate le cose di lassù [...]" (Col 3, 1).
Paolo sa che nonostante la condizione di battezzati e quindi di risorti con Gesù, la nostra
attuale presenza nel mondo ci espone a mille pericoli, tentazioni e difficoltà che ci possono
far deviare o soccombere. Ci esorta perciò a cercare le "cose di lassù".
E che cosa sono "le cose di lassù"? Quei valori che Gesù ha portato sulla terra e per i quali si
distinguono i suoi seguaci. Sono l’amore, la concordia, la pace, il perdono, la correttezza, la
purezza, l’onestà, la giustizia ecc.
Sono tutte quelle virtù e ricchezze che offre il Vangelo. Con esse e per esse i cristiani si
mantengono nella loro realtà di risorti con Cristo. Per esse sono immunizzati dall’influenza
del mondo, dalla concupiscenza della carne, dal demonio.
Per noi il modo di "cercare le cose di lassù" è vivere il Vangelo secondo la nostra spiritualità.
Come? Un modo pratico, che ho sperimentato anch’io con successo, è quello di motivare
tutte le varie azioni della nostra giornata con un cardine della nostra spiritualità, un suo
aspetto.
Nel trattare con i fratelli, ad esempio, o lavorando a qualche opera in loro favore, penseremo
al dovere di "farci uno" con tutti, oppure ci impegneremo ad amarli come noi stessi, o
ancora a vedere Gesù in loro.
Nella vita di comunità, con persone che vivono il nostro stesso Ideale, cercheremo di
ricordare quella che deve essere la misura del nostro amore reciproco: essere pronti a
morire l’uno per l’altro; oppure rammenteremo quel nostro dovere, che deve precedere
tutti gli altri: stabilire la presenza di Gesù in mezzo a noi.
Se sopravvenissero fatiche e dolori, difficoltà e contrarietà, il nostro pensiero andrà a Gesù
Abbandonato per abbracciarlo...
In altre situazioni, ci potrà essere di luce la Parola del mese, o il proposito di fare nel
presente la volontà di Dio, o di essere altra Maria, oppure di ascoltare la voce dello Spirito e
così via.

Sì, tutto quello che facciamo, la nostra intera vita va illuminata col nostro Ideale. In questo
modo, anche vivendo in mezzo al mondo teniamo il cuore ancorato al Cielo, "cerchiamo le
cose di lassù".

E così avremo modo di evitare i cosiddetti "attaccamenti" nei quali necessariamente si cade
se non si ha il cuore in Dio e nei suoi insegnamenti. Essi possono riguardare le cose, le
creature, se stessi: le proprie idee, la salute, il proprio tempo, il riposo, lo studio, il lavoro, i
parenti, le proprie consolazioni o soddisfazioni... Tutte cose che non sono Dio e non possono
quindi prendere il primo posto nei cuori che tendono alla perfezione.

Se si leggono vite o pensieri di santi, si vede come essi abbiano combattuto contro tutti gli
attaccamenti perché hanno attuato il "rinnega te stesso" (cf. Lc 9, 23) di Gesù, condizione
per ogni progresso spirituale. Dice san Giovanni della Croce: "Chi cerca gusto in qualche
cosa, non si mantiene vuoto affinché Dio lo riempia del suo ineffabile diletto, e perciò come
va a Dio, così se ne ritorna, perché avendo le mani ingombre, non può ricevere ciò che Dio
gli dà".

Anche noi dobbiamo combattere gli attaccamenti, anzitutto prevenendoli col tipico
atteggiamento positivo della nostra spiritualità. Se, infatti, la si vive, se si dà un motivo
ideale ad ogni nostra azione, Dio è messo al suo posto. E se qualche momento ci trovassimo
in cuore qualcosa o qualcuno al posto di Dio, dobbiamo distaccarcene subito.

Noi, ad esempio, conoscendo i molti frutti che porta il Movimento, siamo assetati di sapere
quali effetti può aver avuto una giornata, o una Mariapoli, o un’altra manifestazione
dell’Opera. Se ciò però è brama di conoscere qualcosa non per la gloria di Dio, ma per la
nostra soddisfazione, va eliminato.

E gli esempi che potremmo portare in questo campo sono senza numero.

Allora, specialmente nei prossimi quindici giorni, impegniamoci ad avere il cuore libero
perché Dio lo possa riempire delle cose di lassù. Facciamolo illuminando ogni nostra azione
con l’Ideale e distaccandoci da tutto ciò che non è Dio.

È tutto lavoro utile alla nostra santificazione. Quella santificazione che dobbiamo
raggiungere a tutti i costi in questa vita: qui c’è la possibilità, poi non l’avremo più.$doc1679$, 'drive_import', '01679-WEB-1988-02-25-come-cercare-le-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1679)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1680, 'ITA', $doc1680$Rocca di Papa, 14.4.88

AMARE NELLA VERITÀ

Carissimi,

Siamo vissuti in questi ultimi quindici giorni immersi nel nostro Ideale, animati dalla nostra
spiritualità che, applicata nei suoi vari aspetti, ha dato una motivazione ideale ad ogni
nostro atto. E ciò ha portato nuovo sprint alla vita spirituale di noi singoli e delle nostre
comunità, come ho potuto rendermi conto dai molteplici messaggi giunti dalle più svariate
parti del mondo. La gioia è aumentata nei cuori, la presenza di Gesù in mezzo è cresciuta, gli
atti di amore a Gesù Abbandonato si sono moltiplicati. In pratica, si è potuto costatare in
tutto il Movimento una nuova carica d’amore. Ringraziamo Dio e andiamo avanti senza
perdere tempo.

Se il "guardare alle cose di lassù", come invitava a fare la Parola di Vita di aprile, ci ha
portato a prendere in considerazione tutta la nostra spiritualità e a viverla come potevamo,
la Parola di maggio ci sottolinea decisamente un suo aspetto. Dice come deve essere il
nostro amore: dobbiamo amare non a parole, ma con le opere e nella verità. È una parola,
dunque, che ci aiuterà, nei giorni che verranno, a cesellare, a perfezionare ogni nostro
rapporto con i prossimi.

Amare con le opere. Si capisce: l’amore cristiano non è chiacchiera o sentimentalismo;
arriva ai fatti, si concretizza nelle opere. Gesù, che ha saziato affamati, guarito malati,
risuscitato morti..., ce ne dà il più luminoso esempio. Se pensiamo a lui, è tutto chiaro.

Ma occorre amare anche nella verità, che significa come la verità vuole. Amare, dunque,
secondo i suoi insegnamenti. Noi ne conosciamo soprattutto tre: bisogna amare sapendo
che Gesù ritiene fatto a sé quanto si fa al prossimo (cf. Mt 25, 40); occorre amare i fratelli
come noi stessi (cf. Mc 12, 31); è necessario amarci con quella misura che ci fa pronti a
morire l’uno per l’altro (cf. Gv 15, 13).

Io consiglierei in queste due settimane di impegnarci ad amare nella verità, e in particolare
a vedere Gesù in tutti. Soprannaturalizzare sempre, dunque, il nostro modo di vedere.

Alzarsi al mattino, coscienti e convinti che si può e si deve sempre vivere così. Possiamo
amare Gesù anche nei familiari ai quali diamo il buon giorno, con i quali recitiamo magari le
preghiere del mattino e consumiamo la prima colazione.

Possiamo amare Gesù nei prossimi durante il giorno, anche dietro la cattedra di una scuola,
dove insegniamo, o il banco del negozio, o lo sportello della banca dove lavoriamo...
Possiamo amare il prossimo vedendo in lui Gesù anche in casa quando usiamo lo
strofinaccio o la scopa, quando laviamo i piatti o usciamo per fare la spesa.

Possiamo amare Gesù quando ci dedichiamo ad attività in favore della nostra Opera, quando
scriviamo una lettera, o facciamo una telefonata, o teniamo un raduno, o partecipiamo ad un
convegno, o scriviamo un articolo o contribuiamo a edificare un nostro centro, una nostra
cittadella. Possiamo amare Gesù nel prossimo quando preghiamo. Sempre abbiamo questa
favolosa possibilità, e possiamo essere certi che egli ad ogni momento ci dice: L’hai fatto a
me (cf. Mt 25, 40).

Impegniamoci a vivere così dalla mattina alla sera. Senza dire che sappiamo già queste cose,
perché non le mettiamo ancora in pratica come dovremmo. E così, molto spesso, non
amiamo nella verità. Mentre, se amiamo in quel modo, lavoreremo alla nostra perfezione,
faremo nuovi passi verso la santità, perché santità significa virtù, virtù eroiche. E il nostro
Ideale ci addita come via, per adornare l’anima di virtù, proprio l’amore, la carità. Tutto
infatti può avere origine dalla carità.

Il 25 di questo mese è stato beatificato un carmelitano spagnolo dell’Ottocento, P. Francisco
Palau y Quer. È un testimone dell’unica divina verità che si presenta nuova in ogni epoca per
i vari carismi che lo Spirito Santo dona alla sua Chiesa. Questo padre ha scritto: "La carità è il
seme di tutte le virtù solide, vere, eroiche, sublimi, perfette allo stesso modo che nell’ordine
visibile il seme è principio da cui procedono le radici, i rami, le foglie e i frutti dell’albero"
(Doc. 248).

È, quindi, anche lui dell’idea che la carità è un po’ tutto nel cristianesimo.

Avanti, dunque! Teniamo come parola d’ordine: Amare nella verità, che significa: amare,
vedendo Gesù in tutti. Sarà un modo di lavorare seriamente alla nostra perfezione, di
accumulare virtù.

E perché non facciamo una gara a chi fa al giorno più atti di amore?$doc1680$, 'drive_import', '01680-WEB-1988-04-14-amare-nella-verit-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1680)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1681, 'ITA', $doc1681$Rocca di Papa, 28.4.88

AMARE CON I FATTI

Carissimi,

Abbiamo cercato in questi ultimi giorni di amare nella verità, vedendo Gesù in ogni
prossimo, e sono certa che per la gara in cui ci siamo ingaggiati, sono arrivati a Gesù tanti
atti di amore che forse non avremmo fatto, almeno in quel numero, senza l’aiuto della
Parola di Vita di questo mese: "Non amiamo a parole né con la lingua, ma con i fatti e nella
verità" (1 Gv 3, 18).

Questa volta punteremo sull’amare il fratello con i fatti.

Senz’altro, amando nella verità, vedendo cioè Gesù nel fratello, non lo abbiamo fatto col solo
sentimento o con la sola compassione, ma concretamente. Comunque, questa volta facciamo
nostro il detto: "Amare con i fatti". Gesù vuole quelli, vuole una carità verso il prossimo che
sia servizio concreto. Lui stesso ci è stato modello con la lavanda dei piedi, ad esempio.

Amare con le opere. Noi sappiamo che possiamo fare ciò – come ho detto l’altra volta – tutto
il giorno: un atto concreto in favore di un fratello, poi di un altro o di un altro ancora, e così
via. Come membri interni del Movimento poi, ingaggiati in tutte le sue attività, possiamo
moltiplicare tali atti concreti.

Perché tutto il nostro meraviglioso Movimento è una grande opera di carità: esso riunisce
famiglie, porta pace, infonde gioia, converte peccatori, salva vite, diffonde il fuoco nei cuori
spenti e aridi, promuove dialoghi dove persone di tutte le religioni o di buona volontà si
avvicinano alla verità...

E allora, alla fine della vita, per queste azioni concrete, Gesù ci darà un premio
proporzionato. Se anche un solo bicchiere d’acqua offerto a lui nel prossimo non rimarrà
senza ricompensa (cf. Mt 10, 42), che sarà di molti bicchieri d’acqua?

Tuttavia, perché possiamo vivere con maggiore impegno e con più largo respiro la Parola
del mese, suggerirei ancora un’altra cosa. Che nei prossimi quindici giorni osservassimo un
particolare della nostra Opera: che non la guardassimo solo come un grande Movimento
spirituale impegnato a concorrere a realizzare l’unità, o come costituita da diramazioni con
vocazioni diverse, ma che la vedessimo come suscitatrice o sostenitrice di opere più o meno
grandi, concretizzazioni dell’amore verso il prossimo.

Mi ha fatto impressione sapere dalle statistiche dell’Opera che erano fiorite
spontaneamente dai nostri, nel mondo, oltre 200 opere o attività in favore dei fratelli che si
trovano nelle necessità più varie. Opere caritative per ammalati, per anziani, disoccupati,
portatori di handicap; centri di accoglienza alla vita, di accoglienza di persone abbandonate,
sole, di studenti stranieri; opere in favore di bambini in difficoltà, dei senza casa, dei
carcerati, dei tossicodipendenti, di alcoolizzati; corsi di promozione umana e di catechismo;
iniziative nel campo dell’economia, del lavoro, dell’educazione; azioni in favore di tutte le
necessità dei Paesi in via di sviluppo, o per calamità naturali...

E ho lodato Dio perché sin dai primi anni del Movimento le cosiddette opere di misericordia
sono state per noi, come ci suggeriva il Vangelo, condizione imprescindibile per un buon
esame finale, e dunque per una buona conclusione del Santo Viaggio della vita.

Con questo nostro Collegamento vorrei suggerirvi di prendere in considerazione una di
queste opere, di averla a cuore in modo particolare, di interessarvi ad essa, di aiutarla a
svilupparsi, di incrementarla con qualche mezzo a voi possibile, di sentirvi corresponsabili
di essa.

Sarebbe bello che, nel grande albero dell’Opera di Maria, queste attività e opere concrete
prendessero nuovo vigore.

Guardiamoci intorno. Ci saranno attività e opere concrete suscitate nel Movimento Umanità
Nuova o Gioventù Nuova o Ragazzi per l’unità o Famiglie Nuove o nel Movimento
Parrocchiale. Sono nella vostra zona o in altre. Vedete come mettervi in contatto, magari
consultando i vostri responsabili. Avvicinatevi ad esse con delicatezza, senza scompaginarle,
ma solo col desiderio di servirle se non altro con la vostra preghiera.

So, come esempio, che qualcuno si è preso a cuore di dare un po’ del suo tempo perché
possano essere stese e pubblicate con maggiore frequenza, biografie di membri della nostra
Opera andati in Cielo. Così, i fratelli che hanno compiuto il Santo Viaggio continuano ad
illuminare molti col loro esempio, e il bene si diffonde.

Allora, intesi: amare con le opere e dare una mano ad una di esse.

Che per il nostro amore concreto, ed anche per questa particolare opera, il Signore possa
ripetere, alludendo a ciascuno di noi: "Ecco io verrò presto e porterò con me il mio salario,
per rendere a ciascuno secondo le sue opere" (Ap 22, 12).$doc1681$, 'drive_import', '01681-WEB-1988-04-28-amare-con-i-fatti-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1681)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1682, 'ITA', $doc1682$Rocca di Papa, 12.5.88

RAVVIVARE I RAPPORTI

Carissimi,

Percorriamo assieme da 7, 8 anni il Santo Viaggio della vita perché vogliamo farci santi a
gloria di Dio.

E facciamo ciò perché siamo convinti – come diceva anche santa Teresa d’Avila – che
tutti sono chiamati alla santità, nessuno escluso, nemmeno noi, dunque.
La santità: sì, questa è la mèta su cui puntiamo.

La santità. Ma che cos’è la santità? La Chiesa la sanziona nei cristiani quando può dichiarare
d’aver riscontrato in essi le virtù eroiche.

Anche noi certamente non mettiamo un limite alle virtù che desideriamo praticare, ma
quando sentiamo parlare di virtù eroiche e facciamo un breve esame retrospettivo della
nostra vita, non possiamo non ammettere che ne siamo lontani.

Chi di noi, volgendosi indietro, può dire davanti a Dio d’aver vissuto con una pazienza
eroica, un’umiltà, una fortezza, un’obbedienza, una povertà, una carità, eroiche? Ci sono
sempre, permangono, nonostante la nostra buona volontà, difetti, imperfezioni, peccatucci
che è difficile eliminare.

Con dolore ci viene quindi da concludere che non raggiungeremo mai la santità. E questa
situazione ci potrebbe scoraggiare... Cosa pensare?

A parte che dobbiamo essere convinti che anche in fatto di santità il più dipende da Dio e
non da noi, per cui non dobbiamo smettere mai di chiederla come un suo dono, se solo ci
sfiorasse questo dubbio di riuscita o, più ancora, se ci colpisse come uno dei più grandi, e
forse il più grande, dolore della vita (diceva Léon Bloy: "Non c’è che una tristezza [nella
vita]: quella di non esser santi"), se ci succedesse così, dovremmo vedere anche in questo
grande vuoto Gesù Abbandonato, abbracciarlo ed aspettarci con fede la sorpresa di
trovarcelo tutto riempito.

Poi ricordare l’operaio dell’ultima ora, che ha la medesima mercede di quello della prima, e
ricominciare ancora una volta davvero (cf. Mt 20, 12).

Ma come? E su cosa puntare?
Fatti nuovamente coscienti che ciò che vale è Dio e che occorre amarlo come va amato, e
non sapendo quanta vita ancora abbiamo, proporci di vivere lo squarcio di tempo, che ci sta
dinanzi, essendo l’Ideale vivo.

C’è una pagina del Vangelo che ha un’eco particolare in noi e ci indica come fare. Gesù dice:
"Se osserverete i miei comandamenti, rimarrete nel mio amore [...]". "Questo è il mio
comandamento: che vi amiate gli uni gli altri [...]" (Gv 15, 10 e 12).

Tutto sta dunque nell’amore reciproco.

Vivendo così, si trova il mezzo di essere Ideale vivo.

In queste ultime settimane ci siamo impegnati ad amare con le opere.

Ma c’è modo e modo di fare opere.

La grande e al tempo stesso semplice rivoluzione che ha portato e porta il nostro
Movimento nel mondo è proprio questo: vivere, riguardo alle opere, secondo il pensiero di
Cristo, e non altrimenti. Erano e sono molti coloro che operano ed operano, in un attivismo
non del tutto cristiano. È per essi il monito di Paolo: "E se anche distribuissi tutte le mie
sostanze [...], ma non avessi la carità, niente mi giova" (1 Cor 13, 3).

Il Signore ci ha fatto dono di spingerci sempre a mettere a base di ogni altra cosa l’amore
reciproco: "Ma prima di tutto abbiate un amore costante tra di voi [...]" (1 Pt 4, 8).

"Prima di tutto". Così l’operare acquista valore.

Ed è ciò a cui invito tutti in questi prossimi quindici giorni. Come in un caminetto acceso
occorre ogni tanto scuotere col ferro la brace perché la cenere non la copra, così nel gran
braciere del nostro Movimento è necessario di tempo in tempo ravvivare di proposito
l’amore reciproco fra noi, ravvivare i rapporti, perché non siano ricoperti dalla cenere
dell’indifferenza, dell’apatia, dell’egoismo.

In questo modo ameremo veramente Dio, saremo l’Ideale vivo; potremo sperare che la
carità così vissuta generi in noi virtù solide che, quasi senza accorgerci, raggiungeranno, con
la grazia di Dio, la misura dell’eroismo. In tal modo ci faremo santi.

Attenzione allora al nuovo proposito: ravvivare i rapporti: cogliere tutte le occasioni della
giornata per far uscire dai nostri cuori e da quelli dei fratelli fiamme di amore
incandescente.

Vedremo in questo modo tutte le espressioni del nostro Movimento rivitalizzarsi, ravvivarsi,
ringiovanirsi, e tutti noi diventare più ardenti, più belli, più noi, così come Dio ci vuole.$doc1682$, 'drive_import', '01682-WEB-1988-05-12-ravvivare-i-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1682)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1683, 'ITA', $doc1683$Rocca di Papa, 26.5.88

TUTTO TUO

Carissimi,

Un punto della nostra spiritualità, anzi il punto fondamentale, sul quale tutto poggia, è
credere all’Amore.

Credere a Dio-Amore, credere all’amore del Padre, del Figlio e dello Spirito Santo per noi.

Credere anche all’amore di Maria per noi, amore che è espressione, manifestazione
dell’amore di Dio.

È finito il mese di maggio, nel quale la natura si è vestita a festa per la primavera
dirompente con lo splendore dei suoi fiori, e inizia l’estate.

Fra un paio di mesi si concluderà l’Anno Mariano, che, poco o tanto, ha ravvivato in noi
l’attenzione, la venerazione, l’amore per Maria. Anche perché Maria è stata il tema che ha
interessato e interessa, in questo tempo, il nostro Movimento: i cattolici che ad esso
aderiscono, come quelli di altre Chiese, mentre non ha sfiorato invano neppure il cuore di
fedeli di altre religioni e di persone che non professano una fede.

Il ricordo, dunque, di Maria è nell’aria per noi. Essa ci è venuta più vicina. A lei da tanti
nostri cuori sta salendo, con molta più convinzione ora, quell’espressione che è nota al
mondo intero, perché motto del nostro Papa: "Tutto tuo", o "tutta tua", a significare: "Tutto
il mio essere ti appartiene, affinché tu lo doni a Gesù".

"Tutto tuo". È un’espressione d’amore, è l’espressione d’amore per eccellenza.

Anche chi ama, col semplice amore umano, non può dire di meglio alla persona amata che:
"Sono tuo".

Noi l’abbiamo detto e ripetuto a Maria. E lei non ha mancato di aiutarci, di confortarci, di
addolcire nei dolori la nostra vita, di godere con noi nelle nostre ore serene. In una parola:
di mostrarsi madre.

Ma c’è modo e modo per Maria di dirsi tale all’anima nostra.

E c’è modo e modo per noi di comprendere la maternità di Maria.

Lo sappiamo che Maria è madre, che è madre di tutti noi, ma, appunto perché è madre
dell’intero genere umano (degli uomini passati all’Altra Vita, di quelli che vivono oggi sul
nostro pianeta e di coloro che verranno), si può a volte non cogliere nella sua interezza e
verità quella che è la parte d’amore che riserva a ciascuno di noi e, immersi in
quest’immensa famiglia di figli suoi, si può pensare che a noi non possa toccare che una
briciola del suo amore, quasi un granellino dell’arena del mare.

Ed ecco, allora, che Maria si prende cura di chiarire questa situazione e, come per un tocco
divino, immette nell’anima una convinzione che incanta, che riempie di forza e che nessuno
mai più riuscirà a toglierci.

Ella dice al nostro cuore: "Anch’io sono tutta tua. Io, l’onnipotente per grazia, sono qui, tutta
per te", come non appartenesse ad altri, come non amasse che noi. Ci fa dimenticare
completamente che è madre di tutti gli altri, per mettersi di fronte a noi come madre solo
nostra.

E ci sembra che soltanto in questo momento Maria entri veramente nella casa della nostra
anima, che abbraccia lei e noi. E fiorisce nel cuore un atteggiamento assolutamente nuovo
verso di lei, totalmente diverso da quello che avevamo prima.

Nasce infatti un rapporto profondo, diretto, a tu per tu; sgorga una confidenza sconfinata in
lei; si sperimenta una fede così forte nel suo amore che ci sembra, vicino a lei, di poter fare
ogni cosa, di ottenere ogni grazia.

Forse perché noi le abbiamo detto e ripetuto: "Tutto tuo, sono tutto tuo", lei ora risponde:
"Anch’io sono tutta tua".

Approfittiamo dei prossimi quindici giorni, per ravvivare la fede nell’amore personale che
Maria ha per ciascuno di noi, e per spalancare la porta della nostra anima a lei.

E giacché ci ama tanto, cerchiamo di contraccambiare il suo amore.

Come? Fra i mille modi che esistono per farlo, noi ne prediligiamo uno: quello di imitarla.

Cerchiamo allora di dire anche noi, sempre, con la nostra vita, a colui che amiamo (a Dio,
direttamente: nella preghiera, o nel lavoro, nel riposo, nell’adempimento, insomma, della
sua volontà): "Sono tutto tuo, a tua totale disposizione, senza alcuna riserva"; e cerchiamo di
dire altrettanto a Gesù in ogni prossimo con cui trattiamo nella giornata.

Saremo tutti proiettati fuori di noi, nell’amore; l’"uomo vecchio" non avrà respiro; saremo
Maria, ciascuno, altra lei. Bruceremo, insomma, come fuoco in quest’anno di fuoco.$doc1683$, 'drive_import', '01683-WEB-1988-05-26-tutto-tuo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1683)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1684, 'ITA', $doc1684$Rocca di Papa, 9.6.88
QUANDO SONO FORTE?

Carissimi,

È indubbio che un punto della spiritualità dell’unità da cui non si può prescindere, perché
fondamentale per la nostra vita spirituale e quindi anche per un sicuro Santo Viaggio, è Gesù
crocifisso e abbandonato.
Gesù Abbandonato! Quante cose dicono a noi queste semplici parole!
Gesù Abbandonato è la soluzione di ogni problema. Egli è la chiave della nostra unione con
Dio in ogni momento della nostra esistenza. Egli ci apre l’unità con i prossimi. È, infatti, il
segreto dell’unità.
Ma oggi con voi vorrei considerare un altro aspetto di Gesù crocifisso e abbandonato.
Siamo sollecitati a questo dalla Parola di Vita di luglio che afferma: "Quando sono debole, è
allora che sono forte" (2 Cor 12, 10).
Che cosa vuol dire? Non abbiamo qui una lampante contraddizione? No. È una legge
cristiana, tipicamente cristiana. Gesù ce la spiega con la sua vita e soprattutto con la sua
morte.
Quando ha compiuto l’Opera che il Padre gli ha affidato? Quando ha redento l’umanità?
Quando ha vinto sul peccato? Quando è morto in croce, annientato, dopo aver gridato: "Dio
mio, Dio mio, perché mi hai abbandonato?".
Gesù è stato più forte proprio quando è stato più debole.
E la Chiesa è fiorita su quel sacrificio. I primi cristiani hanno offerto il loro martirio per
consolidarla e dilatarla.
Gesù avrebbe potuto dare origine al nuovo popolo di Dio con la sua sola predicazione, o con
qualche miracolo in più, o qualche gesto straordinario.
E invece no. No, perché la Chiesa è opera di Dio ed è nel dolore e solo nel dolore che
fioriscono le opere di Dio.
Più volte nella nostra storia ci è stato detto autorevolmente che anche la nostra piccola
Opera, figlia della Chiesa, è opera di Dio. E noi ci crediamo perché, se non altro, sappiamo
che non l’abbiamo fatta noi e perché, ci si dice, agisce in essa lo Spirito Santo.
Ora, su cosa può fondarsi e vivere la nostra se è un’opera di Dio?

Se guardiamo a Gesù, ci appare evidente che essa non può trovare il suo vero supporto se
non nel sacrificio, nel dolore.

Perché questa è la legge: è quando siamo deboli che siamo forti.

Diceva la nostra Pina de Vettori, ora nella Mariapoli Celeste, a proposito del suo male che
progrediva: "È il regno di Dio che avanza".

Così pensano tutti i nostri che sono visitati da Dio con il dolore. E accettano e offrono: per
l’Opera, per la Chiesa.

Ma non è certo il caso di aspettare di essere gravemente ammalati per pensare in questo
modo.

Abbiamo tutti spesso da sopportare dolori di ogni genere: avversità, situazioni dolorose,
malattie, morti, prove interiori, incomprensioni, tentazioni, fallimenti... Cosa fare? Per
essere coerenti col cristianesimo, che ci siamo impegnati a vivere con radicalità, dobbiamo
credere che quelli sono momenti preziosissimi per l’Opera a cui abbiamo dato la vita;
dobbiamo essere certi che è soprattutto per essi che l’Opera va avanti.

Occorre, insomma, valorizzare il dolore, piccolo o grande, prenderlo in rilievo, unirlo a
quello di Gesù. Dar valore in particolare alla fatica, al sacrificio che comporta l’amare il
prossimo, perché è il nostro tipico dovere, è qui che troviamo la nostra caratteristica
penitenza.

E quando non ci fosse il dolore, scegliamo noi, di tanto in tanto, qualche mortificazione di
nostra iniziativa, per assicurarci meglio il buon esito del nostro operare.

Di qui il proposito per le prossime settimane: al sopraggiungere del dolore, ripetere con
forza in cuore: "È quando sono debole che sono forte".$doc1684$, 'drive_import', '01684-WEB-1988-06-09-quando-sono-forte-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1684)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1685, 'ITA', $doc1685$Rocca di Papa, 23.6.88

LA PENITENZA CHE IL CIELO CI DOMANDA

Carissimi,

Riprendiamo il nostro Collegamento, dopo un periodo di sosta. Lo riprendiamo per aiutarci
ad essere anche noi, alla nostra ora, così ben preparati per il definitivo incontro con Gesù,
come lo sono stati alcuni fra i nostri, carissimi, che, presenti all’ultimo Collegamento di
giugno, oggi non ci sono, almeno qui sulla terra, perché hanno terminato il loro Santo
Viaggio: Dio li ha chiamati a sé. Ve ne parliamo brevemente in questo Collegamento, per
dilungarci doverosamente e maggiormente in altra occasione.

L’estate – ho saputo – è stata per molti di noi motivo di riposo fisico, ed anche di nuove
impennate nella via dello spirito.

Ci siamo per questo aiutati tutti senz’altro con diversi mezzi a nostra disposizione. È quanto
ho cercato di fare anch’io.

Assieme ad un approfondimento della nostra spiritualità, infatti, ho avuto la possibilità di
leggere qualcosa riguardante grandi santi, che la Chiesa onora, e di vedere anche qualche
filmato su questo argomento.

Una delle impressioni più forti che ne ho riportato è stata l’aspra, asprissima vita di
penitenza che qualcuno di loro ha condotto, indossando spesso dolorosi cilizi, praticando
continui digiuni, penose veglie, interminabili silenzi, dormendo sulla terra nuda o su legni.
Questi santi sono diventati tali anche in forza di queste penitenze...

Naturalmente, mi sono chiesta: E noi? Cosa facciamo noi? Non vogliamo farci santi pure noi?

E subito, nella mia anima, è stata chiara la risposta: "Tu, voi, dovete guardare a Maria. È lei il
vostro modello. Di lei, che è vissuta in mezzo al mondo come la maggior parte di voi, non si
conoscono tanto le penitenze, che può aver praticato, quanto le sofferenze che Dio le ha
chiesto, attraverso le circostanze della sua meravigliosa, straordinaria, ma anche
dolorosissima vita. E osservate il modo in cui lei le ha vissute, tanto da essere chiamata
regina dei martiri".

Sì, dobbiamo guardare a Maria.

Non c’è dubbio che anche per noi la sofferenza ha un grande posto nella vita: basta pensare
a tutto quanto significa nella nostra esistenza Gesù Abbandonato.
Impossibile, dunque, temere che ci manchi qualcosa. Il dolore, i dolori, e quindi le penitenze,
ci sono. L’importante è viverli come ha fatto Maria.

Non è certo escluso che anche noi facciamo qualche penitenza corporale o spirituale, specie
quelle che in certi periodi la Chiesa consiglia. Ma, sotto questo aspetto, dobbiamo
soprattutto imitare Maria.

Ho ripensato a lei che, manifestandosi come Desolata, è stata riconosciuta da noi proprio
come un monumento di santità, come la santa per eccellenza, come la personificazione di
tutte le virtù.

E mi è fiorito nuovo in cuore il desiderio di riviverla così.

Riviverla nella completa rinuncia a se stessa (giacché qui sta la virtù), imitarla nel suo saper
perdere tutto, tutto, persino il suo Figlio Dio.

In che modo? Comportandoci come anni fa, quando l’abbiamo compresa un po’ in
profondità. Erano tempi in cui lo Spirito ci sottolineava in varie maniere come fosse
necessario fare non la nostra, ma la volontà di Dio; e come occorresse vivere bene questa e
viverla pienamente nel momento presente della vita. Ma si capiva che ciò non era possibile
se nel presente non si perdeva sempre tutto ciò che non era volontà di Dio, se non si
abdicava con decisione alla propria volontà.

Ho riprovato a vivere così, e ho visto quanto ciò fa bene all’anima, come la ringiovanisce, la
rinnova; come non c’è nulla di vecchio in ciò che Dio ci ha dato, ci ha insegnato; come –
essendo la nostra spiritualità evangelica – essa può offrire sempre, come il Vangelo, spunti
di vita nuova in ogni sua espressione e in ogni tempo.

Allora, con questo Collegamento, invito anche voi a vivere in tal modo.

Fermiamoci un momento. Osserviamo come il tempo cammina. Mettiamoci bene nel
presente e compiamo la volontà di Dio, perdendo decisamente la nostra, sacrificando tutto
ciò che abbiamo in cuore o nella mente, ma che non riguarda il presente. Può essere un
ricordo anche vivissimo, un’idea, un desiderio, un sentimento anche profondo, una cosa, una
persona... Applichiamo cuore, mente e forze solo alla volontà di Dio. Così amiamo veramente
Dio, con tutto il cuore, la mente, le forze: Dio, il nostro Ideale.

È una ginnastica meravigliosa: è un morire ogni volta per sempre rinascere. È la principale
penitenza che il Cielo domanda ai membri dell’Opera di Maria.$doc1685$, 'drive_import', '01685-WEB-1988-06-23-la-penitenza-che-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1685)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1686, 'ITA', $doc1686$Mollens, 25.8.88

RIMANIAMO NELLA VOLONTÀ DI DIO DEL PRESENTE

Carissimi,

Eccoci ad un nuovo Collegamento, con il quale darci una mano per santificarci insieme,
secondo la nostra vocazione.

Come sempre dovrei, anche questa volta, indicare e approfondire qualche punto della
nostra spiritualità, atto a nutrire la nostra anima e a farla camminare verso la perfezione.

Se non che è avvenuto che il pensiero del Collegamento precedente ha suscitato in molti e
molti una tale gioia, un tale impegno e anche un tale entusiasmo – come ho potuto costatare
dagli innumerevoli echi giuntimi da molte parti del mondo – che mi sono chiesta se fosse
proprio opportuno e giusto proporne un altro subito, o se non fosse meglio continuare a
vivere, per altri quindici giorni almeno, quello precedente, e cioè: attuare la volontà di Dio
nel presente tagliando, mortificando la nostra.

D’altra parte io stessa, che mi sforzo di vivere come voi, avvertivo in cuore un desiderio così
forte di rimanere in questa linea, apportatrice di tanta gioia interiore e di tanti frutti
spirituali, che non avevo nessuna voglia di cambiare.

E allora mi sono chiesta: ma perché questa formula ha avuto tanto successo? Forse perché
suggeritaci da Maria che, specie nella sua desolazione, è nostro tipico modello di santità?

Certamente sì.

Ma anche perché – ed è la scoperta che ho fatto nei giorni scorsi – questo pensiero sulla
volontà di Dio contiene tutto il nostro Ideale. Del resto è proprio di una madre, Maria, madre
soprannaturale, ma sempre madre, concentrare in una pillola tutto il nutrimento che è
necessario ai suoi figli.

Ho visto, infatti, che facendo nostra la volontà di Dio nel presente e annientando la propria,
dobbiamo credere all’amore di Dio, siamo in certo modo costretti a credere all’amore di Dio
(che è il primo punto della nostra spiritualità).

In chi gettare, infatti, le preoccupazioni del futuro, ad esempio, o di altre cose a cui in questo
attimo noi non possiamo dedicarci, se non nel Padre?

In quanto al punto sulla volontà di Dio, è ovvio che è proprio in questo modo che
l’adempiamo veramente.
E così mi sono accorta che, vivendo in questa maniera, anche il prossimo è amato come si
deve; che l’amore reciproco è mantenuto vivo; che la luce del Risorto in mezzo a noi
splende. Ho visto che Gesù Abbandonato (dovendo fare subito nostri i dolori del presente) è
continuamente abbracciato; che si sfruttano le grazie che porta nel nostro cuore l’Eucaristia;
che si vive Maria (come ho spiegato l’ultima volta). Mi sono resa conto che siamo Parola
viva, perché Gesù, Verbo di Dio, vive in noi; che lo Spirito Santo è meglio ascoltato in fondo
al cuore...

Non solo, ma anche ogni aspetto della nostra vita d’amore si perfeziona: si lavora meglio; si
irradia più intensamente la luce dell’Ideale dalla nostra persona e dalla nostra comunità; si
prega sempre, perché uniti a Dio, e migliorano le pratiche di pietà; si curano di più la salute
e il riposo, l’armonia dell’ambiente in cui viviamo; prende il suo posto decisamente lo studio
e si coltiva, con accresciuto amore, la comunione con tutti.

Tutto il nostro Ideale è dentro questa formula; per questo è un vero tesoro.

E allora, perché cambiare? Piuttosto, cerchiamo di viverla con più decisione di prima e più
costantemente.

Io penso che siate tutti d’accordo.

Quindi avanti: rimettiamoci, con tutto l’amore, nella divina volontà, in questo raggio di sole,
diverso per ciascuno, ma sempre di sole, e cioè di Dio. Rimettiamoci in esso nel presente e
allontaniamo tutto ciò che non è sua volontà. Credo che si progredisca di più in questo modo
che non in molte altre maniere.

Così ci andiamo preparando al nuovo anno ideale che ha inizio in ottobre, anno che mi
sembra di prevedere ricchissimo su tutti i fronti, per i luminosi prodromi che si stanno
manifestando, e di cui informerò i responsabili di tutte le zone del mondo.

L’Opera, infatti, cammina, ma tanto più avanzerà, quanto più lasceremo vivere Gesù in
ciascuno di noi. E ciò sarà possibile essendo sempre la sua volontà viva.$doc1686$, 'drive_import', '01686-WEB-1988-08-25-rimaniamo-nella-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1686)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1687, 'ITA', $doc1687$Mollens, 8.9.88

L’ANNUNCIO DELL’IDEALE

Carissimi,

Cominciamo, con ottobre, il nuovo anno ideale ’88-’89 che – come abbiamo già detto –
prevediamo "ricchissimo" di frutti, a gloria di Dio.

Per tale periodo, è in programma per tutto il Movimento un argomento che riguarda tutti
noi, ma si rifà sempre a Maria: la "Via Mariae". È il nostro itinerario spirituale che, scoperto
circa venticinque anni fa e già spiegato, verrà presentato arricchito di parecchi elementi per
l’esperienza che abbiamo potuto fare in questi ultimi due decenni: tanti, su quarant’anni di
vita!

Parlare ancora di Maria non è fuori luogo, né fuori tempo. Come ebbe ad esprimersi il Santo
Padre Giovanni Paolo II, infatti, se è finito l’Anno Mariano, non si è conclusa l’epoca di Maria,
che si può pensare arrivi almeno fino alla fine del secolo, quando si festeggeranno i duemila
anni dalla nascita di Gesù.

Perciò, avendo presente che tutto il Movimento approfondirà questa via dell’amore, mi son
detta: Non sarebbe bello, attraverso i collegamenti di quest’anno, puntualizzare una tappa
dopo l’altra per riprendere coscienza dei passi che abbiamo già fatto o faremo nel nostro
Santo Viaggio? Per trarre qualche insegnamento pratico, per rendere il dovuto
ringraziamento a Dio dei doni ricevuti e pregustare i futuri, per prepararci alle prove
indispensabili che verranno?

Per questo vorrei sottoporre oggi alla vostra e mia attenzione la prima tappa della "Via
Mariae": l’Annunciazione.

Essa significa per noi l’annuncio dell’Ideale, quel momento della nostra vita in cui Dio si è
manifestato a noi, in modo particolare, con una luce superiore; ci ha chiamati, ci ha scelti per
un suo fine preciso e noi gli abbiamo risposto, facendo di lui il perché della nostra vita.

In tal modo ci siamo trovati lanciati in una vita nuova, in un’avventura divina, dove abbiamo
cercato di amarlo, vivendo la spiritualità che ci ha donato.

Oggi, ripensando a quel momento, vorrei ci fermassimo un attimo e ci raccogliessimo nel
profondo del nostro cuore e, ancora nello stupore, ci chiedessimo: Dio mi ha scelto! Ma chi è
colui che mi ha scelto?

E, sollevando il capo da tutto ciò che ci occupa in questo mondo (i nostri affari, la nostra
casa, la nostra famiglia, le notizie del giorno...), riandassimo col pensiero a quest’estate,
quando abbiamo potuto contemplare magari una distesa di mare senza fine, una catena di
monti altissimi, un ghiacciaio imponente o una volta del cielo punteggiata di stelle... Che
maestosità! Che immensità!

E, attraverso lo splendore abbagliante della natura, risalissimo a colui che ne è l’autore: Dio,
il Re dell’universo, il Signore delle galassie, l’Infinito.

E ci ripetessimo: Egli è colui che un giorno mi ha guardato, mi ha chiamato.

Allora, se la percezione della sua maestosità ci annientasse, la certezza che egli ci ha scelti
potrebbe aprirci il cuore e suscitare in noi la brama di scoprire, di trovare – dietro tanta
gloriosa bellezza del creato – il suo volto, la sua presenza.

E c’è. Perché egli è presente dovunque: è sotto lo scintillio d’un ruscello, nello schiudersi
d’un fiore, in un’alba chiara, in un rosso tramonto, su una vetta nevosa... Noi poi sappiamo
che, essendosi fatto uomo, è presente in certi luoghi in modo particolare: è nei tabernacoli,
nel centro della nostra anima, in ogni fratello e soprattutto in chi più soffre; è in mezzo a noi
se ci amiamo; è nella Chiesa e nei suoi pastori; nella sua Parola, nella sua volontà, dove ci
siamo sempre sforzati di amarlo e continueremo così anche nei prossimi giorni.

Tuttavia sarebbe mio desiderio e consiglio che, in queste due settimane che ci stanno di
fronte, lo cercassimo in modo particolare là dove la natura ce lo svela.

È vero, dopo il periodo estivo, siamo tornati al lavoro nelle nostre metropoli di cemento,
costruite dalla mano dell’uomo tra il frastuono del mondo, dove raramente la natura si è
salvata. Eppure, se vogliamo, basta uno squarcio di cielo azzurro scorto fra le cime dei
grattacieli, per ricordarci Dio; basta un raggio di sole, che non manca di penetrare nemmeno
fra le sbarre d’una prigione; basta un fiore, un prato, il volto di un bambino...

E vorrei rispondessimo al suo amore per noi, così particolare, dichiarandogli il nostro
amore totale; adorandolo, prostrati, almeno spiritualmente, fino a terra; lodandolo con le
più belle note che salgono dal nostro cuore; glorificandolo con tutta la nostra vita.

Questo dobbiamo fare: amare Dio per se stesso nella sua immensità, nella sua infinitezza,
nella sua bellezza, nel suo splendore, nella sua onnipotenza...

Ciò ci aiuterà a tornare in mezzo agli uomini, dove è il nostro posto, ritemprati come
senz’altro lo era Gesù quando, dopo aver pregato il Padre tutta la notte sui monti, sotto il
cielo stellato, tornava fra gli uomini a fare del bene.

Riviviamo allora nei prossimi giorni la nostra annunciazione accogliendo come Maria, nel
nostro cuore, Dio, che vorremmo riscoprire presente dovunque nella natura. Che egli entri
in noi maggiormente con le sue grazie, con quel carisma che ci ha destinato, perché si
compia su di noi, come già in Maria, il suo disegno.

In conclusione: viviamo il presente perdendo tutto, ma soffermandoci di tanto in tanto ad
adorare il Dio che ci ha chiamati.$doc1687$, 'drive_import', '01687-WEB-1988-09-08-l-annuncio-dell-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1687)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1688, 'ITA', $doc1688$Mollens, 22.9.88

PORTARE GESÙ

Carissimi,

Volendo ripercorrere le tappe della "Via Mariae", almeno in un qualche suo aspetto,
la volta scorsa, pensando all’Annunciazione, ci siamo voluti render conto di chi è
colui che ci ha chiamati, che ci ha scelti, per camminare in questa sua via dell’unità.
E, nuovamente sorpresi e profondamente grati, abbiamo ricostatato con stupore che
è Dio, il Signore del creato.
Questa volta passiamo alla seconda tappa della "Via Mariae", che ricorda un altro episodio
della vita della Madonna.

Ella, subito dopo l’Annunciazione – "in quei giorni" (cf. Lc 1, 39) dice san Luca –, si è messa
in viaggio per andare da Elisabetta ad aiutarla, giacché anch’essa aspettava un bambino pur
nella sua tarda età. Maria vi andò "in fretta" (ibid.), dice il Vangelo, portando Gesù in sé. E,
appena ebbe salutato Elisabetta, il bambino di lei sussultò di gioia nel suo grembo.

L’analogia tra questo, pur straordinario, episodio di Maria, e quanto siamo spinti a fare
anche noi, dopo la nostra annunciazione, è chiara.

Conosciuto, in maniera tutta nuova, l’amore di Dio, la prima cosa che fa il membro del
Movimento è quella di mettersi ad amare. E lo fa subito, lo fa "in fretta", senza frapporre
indugi. È di tutti così. Così fa agire il nostro carisma. Non ci si pone tanto in adorazione di
Dio o in contemplazione (anche se il nostro cuore ne è pieno) ma... si va. Si va perché lo
Spirito Santo ci spinge in quella direzione. Si va in fretta perché – come è stato scritto – "lo
Spirito Santo non ammette lentezze". Si va ad amare, a "farsi uno" con il prossimo, a
prestare il nostro servizio.

E anche noi portiamo, in altro modo, Gesù in noi, nel nostro cuore, perché, dato che amiamo,
vive "l’uomo nuovo" in noi, vive Gesù. Ed è Gesù in noi che incide per primo sulle persone
che incontriamo, un po’ come lui, che Maria portava nel suo grembo, fece sussultare il bimbo
di Elisabetta.

Questo andare ad amare è una delle novità che ha portato il nostro Movimento. Ricordo che
i primi tempi, almeno nei nostri ambienti, si concepiva la carità quasi solo come elemosina,
elargizione, sovvenzione, e per questo aveva perduto il suo fascino.

L’Ideale ha concorso a riaccendere il fuoco dell’amore.
Poi, dopo aver portato Gesù in noi amando, si deve passare al servizio concreto. Maria aiutò
per tre mesi la cugina in tutte le faccende di casa. E così dobbiamo fare anche noi: l’amore
non è completo se non è concreto.

Maria dunque, anche nel suo secondo episodio, si manifesta come modello nostro, come
nostra via. Nello stesso tempo comprendiamo che lo Spirito Santo ha iniziato a plasmare in
noi, sin dal principio della nostra nuova vita, la figura di Maria.

Cosa mettere in pratica, allora, i prossimi quindici giorni?

Da veri "piccole Maria" ricordiamo quali sono i nostri prossimi verso i quali abbiamo il
debito dell’amore: sono tutti quelli con cui viviamo, quelli che incontriamo durante il giorno,
le persone del nostro "grappolo", i partecipanti ai nostri convegni, i diversi fratelli che
conosciamo soprattutto attraverso le nostre opere e in cui scopriamo Gesù Abbandonato.

Andiamo in fretta verso quanti possiamo, amandoli, e porgendo loro ciò di cui abbisognano
o che desiderano: aiuto, consiglio, comprensione, compassione, il nostro interesse, soldi,
indumenti. La Provvidenza ci aiuterà come aiutava le prime focolarine e come aiuta sempre.

Prima dunque portare Gesù nel nostro cuore con l’amore e poi offrire quanto possiamo.

Gesù ci dirà: "L’hai fatto a me" (cf. Mt 25, 40). E, in tal modo, confermerà che la maniera di
amarlo è proprio quella di amare i nostri fratelli.$doc1688$, 'drive_import', '01688-WEB-1988-09-22-portare-ges-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1688)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1689, 'ITA', $doc1689$Rocca di Papa, 13.10.88
TUTTO ALLA MAGGIOR GLORIA DI DIO

Carissimi,

Come è noto a tutti, abbiamo pensato di intrattenerci in questi mesi – durante il
Collegamento – sulle tappe della "Via Mariae", e non tanto su ciò che esse hanno di centrale
(che sarà trattato nel tema dell’anno), quanto su qualche loro particolare.
In questi giorni, meditando un po’ la terza tappa della "Via Mariae" (la nascita di Gesù), mi
sono soffermata sulle prime parole che gli angeli hanno cantato in quella straordinaria
occasione: "Gloria a Dio nel più alto dei cieli" (Lc 2, 14).
Gloria a Dio. Gli angeli cantano la gloria di Dio.
Noi, specie in questi ultimi tempi, ci siamo impegnati a glorificare Dio soprattutto attraverso
gli splendori della natura.
Oggi, meditando questo terzo mistero della vita di Maria, impariamo dagli angeli a
glorificare Dio per la presenza di Gesù sulla terra.
È una gloria che possiamo elevare a Dio in parecchie circostanze: davanti ad ogni
tabernacolo, ad esempio, e ad ogni altra sua presenza sulla terra.
Ma in questo momento mi sembra di dover considerare in particolare una presenza.
È quella di Gesù nell’Opera di Maria, nel Movimento dei Focolari, che è opera di Dio.
Voi sapete come Natale, la nascita di Gesù, ci porta sempre a pensare a Gesù in mezzo a noi,
alla sua nascita e rinascita in mezzo a noi in tutto il mondo per il nostro vicendevole amore.
Ebbene, questo Gesù così vero, così vivo, anche se presente solo spiritualmente, lo
dobbiamo glorificare.
Ma noi lo facciamo? E lo glorifichiamo a sufficienza?
Certamente la nostra appartenenza al Movimento ci dà continue possibilità di farlo, ma non
sempre ce ne rendiamo conto.
E ciò non è bene perché il nostro cuore, così come ha bisogno di amare Dio, ha bisogno di
dargli gloria. Mentre può accadere, a volte, persino che non si sappia come fare.
Ebbene, dobbiamo sapere che il modo stesso di vivere del Movimento è tutto una gloria a
Dio, o meglio può essere tutto una gloria a Dio.
Quando, per esempio, narriamo la straordinaria espansione del nostro Movimento e la
vediamo come logico effetto di un’opera di Dio (anche perché non potrebbe essere semplice
prodotto di sforzi umani), non è una grande gloria che eleviamo a Dio?

E non è bene farlo? Se fatto al momento giusto, è ottimo, è evangelico. Dice Gesù: "Che gli
uomini vedano le vostre buone opere e glorifichino il Padre" (cf. Mt 5, 16).

Quando raccontiamo le nostre esperienze personali o collettive, in cui scopriamo un divino
filo conduttore, l’azione di Dio in ciascuno di noi e in noi come gruppo, non abbiamo forse
un’altra possibilità concreta di dar gloria a Dio?

E quando scriviamo o ci raccontiamo col cuore esultante le nostre impressioni, i frutti, gli
effetti su di noi o su altre persone, di un discorso, di una giornata, di un avvenimento
dell’Opera, non è questo forse ancora un modo per dar gloria a Dio?

L’importante, e anzi indispensabile, è che si glorifichi sempre Dio nella sua opera e non se
stessi o le persone o altre cose. Anche se le opere appaiono di qualcuno, sono in realtà di
Dio. Il nostro contributo c’è, ma è sempre quello di un servo inutile e infedele.

Ci sono però nell’Opera anche altre grandi possibilità di glorificare Dio. Dobbiamo farlo.

Condividiamo in pieno quanto pensa in proposito Madre Teresa di Calcutta, la quale dice
che, se è Dio che ha fatto un’Opera, questa verità va annunciata, perché Cristo è la verità e
Cristo va annunciato.

Siamo dunque felici, strafelici: il Signore, con la terza tappa della "Via Mariae", ci dà un
nuovo impulso nel nostro Santo Viaggio.

Dove c’è Gesù (ed egli è anche in mezzo a noi nella sua Opera), dobbiamo cantare la sua
gloria. E dobbiamo farlo con i fatti, con le parole, con gli scritti, con i mimi, con i canti, con i
mezzi di comunicazione, ecc.

È l’intenzione che daremo ad ogni nostra attività nel Movimento in questi prossimi
quindici giorni: tutto alla sua gloria, tutto alla maggior gloria di Dio.$doc1689$, 'drive_import', '01689-WEB-1988-10-13-tutto-alla-maggior-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1689)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1690, 'ITA', $doc1690$Rocca di Papa, 27.10.88

IL PIÙ GRANDE DOLORE

Carissimi,

Oggi, dopo la pausa nella quale siete stati aggiornati sul mese di ottobre trascorso a Roma
dai capizona e sul programma del nuovo anno ideale ’88-’89, eccoci di nuovo a comunicarci
qualche pensiero che aiuti il nostro Santo Viaggio.

Abbiamo approfondito le volte scorse, almeno sotto qualche aspetto, le prime tre tappe
della "Via Mariae". E siamo ora alla quarta. La conosciamo: Maria, con Giuseppe, presenta
Gesù bambino al tempio e il vecchio Simeone le preannuncia che una spada trapasserà la
sua anima.

È un episodio, questo, che fa pensare: come mai Dio ha voluto che a Maria fosse annunciata
in anticipo la croce? Come mai una profezia che poteva amareggiarle l’intera vita?

Perché Maria doveva vivere – prima fra tutti – la vocazione cristiana che è: chiamata
all’amore. E su questa terra non si può vivere una vita di amore, la vita del vero amore,
senza conoscere il dolore.

Per il cristiano, infatti, amare, significa vivere non la propria, ma la volontà di Dio, e ciò
costa; vivere non se stessi, ma i fratelli, e ciò vuol dire rinnegarsi, sacrificarsi, morire, far
perire l’uomo vecchio, lasciar vivere l’uomo nuovo, anche se l’amore poi è foriero di nuova
luce, di pace vera, di gioia piena.

È per questo che anche per tutti noi, piccoli o grandi, si è presentata un giorno la quarta
tappa della "Via Mariae", quando ci è stato annunciato Gesù Abbandonato. È solo lui, infatti,
la condizione per camminare in quella via dell’amore che ci ha folgorati e attratti.

Abbiamo conosciuto la quarta tappa della "Via Mariae", che di tanto in tanto però ritorna
nella vita, quando, attraverso un approfondimento della nostra spiritualità, o una
circostanza dolorosa, o la voce dello Spirito Santo in noi, o altro, siamo invitati a riscegliere
lui, Gesù Abbandonato, nelle sofferenze personali, nella pratica delle virtù, nei fratelli che
più gli assomigliano, negli scopi della nostra Opera...

Quarta tappa che vogliamo rivivere anche oggi e proprio in quella luce ed in quel modo in
cui l’abbiamo appresa dal nostro Movimento.

Non vogliamo noi, infatti, abbracciare semplicemente la croce, ogni croce della vita. Sospinti
dall’amore a Gesù, abbiamo deciso di seguirlo nel suo più grande dolore.
Costatando di avere una sola vita, abbiamo preso questa decisione.

Ma quali conseguenze ha per la nostra esistenza tale scelta?

Quella di essere sempre pronti ad accogliere, a soffrire, per lui e con lui, anche i dolori più
grandi. Sì: i dolori più grandi. Questo significa per noi aver scelto Gesù Abbandonato.

Forse, nella vita non abbiamo pensato a sufficienza a questo impegno che abbiamo preso;
forse l’abbiamo minimizzato, scolorito. Forse abbiamo addirittura strumentalizzato Gesù
Abbandonato per avere pace e gioia. E così egli non ha potuto portare in noi quegli
straordinari frutti che da lui si possono sperare.

E allora: che fare?

Il ripensare alla quarta tappa della "Via Mariae" sia per tutti noi – nei prossimi quindici
giorni – l’occasione per metterci nelle giuste disposizioni di fronte a Dio.

Ogni giorno ha la sua croce. Così sarà anche per noi.

Impegniamoci ad accogliere in essa Gesù Abbandonato a cuore aperto; a dirgli non solo: "Ti
amo, Te voglio", ma anche: "Quello che mi dai è ancora poco, perché ad altro sono stata
chiamata con la tua grazia".

In tal modo lo ameremo veramente, secondo la nostra vocazione.

Abbiamo detto che questo nuovo anno potrà avere un titolo: anno fruttuosissimo.

Ciò sarà soprattutto se ognuno di noi farà una nuova conversione: conversione a lui
abbandonato nel suo più grande dolore. Decisione, questa, che può sgomentare, ma che ci
farà conoscere già da quaggiù le più profonde ineffabili gioie dell’unione con Dio e le
meraviglie dell’unità fra gli uomini.$doc1690$, 'drive_import', '01690-WEB-1988-10-27-il-pi-grande-dolore-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1690)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1691, 'ITA', $doc1691$Rocca di Papa, 25.12.1986

1987

AMARE TUTTI, AMARE PER PRIMI

Carissimi,

         Quest’anno in tutta l’Opera si approfondirà il tema sulla Parola di Vita vissuta e i
frutti che essa porta.

         Per questo sarà bene che prendiamo nella massima considerazione tale pratica
tradizionale del nostro Movimento e la sottolineiamo ancora di più attraverso il
Collegamento.

         La Parola di Vita di questo mese ci è molto cara perché esprime il nostro modo di
vivere secondo l’Ideale, modo che ha rinnovato la nostra esistenza.

         Essa dice: "Se uno è in Cristo, è una creatura nuova; le cose vecchie sono passate,
ecco ne sono nate di nuove" (2 Cor 5, 17).

         Parla, come subito avrete intuito, dell’"uomo nuovo" (cf. Ef 4,24) che, mediante il
battesimo e l’adesione alla fede, si è stabilito in noi togliendo di mezzo l’"uomo vecchio" (cf.
Ef 4,22). "Uomo nuovo", con un modo nuovo di vedere le cose, di agire, di amare, che ha
preso il posto del modo vecchio di pensare, di fare.

         "Uomo nuovo", che in noi ha però sempre bisogno di essere mantenuto vivo col
lasciarci invadere dall’amore soprannaturale.

         Ma, perché in noi possa liberamente vivere quest’"uomo nuovo", è utile chiedersi:
Com’è fatto questo amore? Che differenza c’è con l’amore che può concepire anche un
"uomo vecchio"? Quali le sue principali caratteristiche?

         L’amore soprannaturale, essendo una partecipazione all’amore stesso che è in Dio,
che è Dio, si differenzia da quello umano in infinite maniere, ma per due aspetti soprattutto
è diverso: l’amore umano fa delle distinzioni, è parziale, ama certi fratelli, come ad esempio
quelli del proprio sangue, o quelli colti o ricchi o belli o onorati o sani o giovani...; quelli di
una certa razza o categoria, e non ama, o almeno non così, gli altri.
         L’amore divino, invece, ama tutti, è universale.

         E di questo ogni uomo sulla terra, se credente, è talmente convinto che non
penserebbe mai di essere escluso dall’amore di Dio.

         La seconda differenza sta nel fatto che nell’amore umano, in genere, si ama perché si
è amati; e anche quando l’amore è bello, si ama nell’altro qualcosa di sé. C’è sempre
qualcosa di egoistico nell’amore umano, oppure si attende ad amare quando l’interesse ci
porta ad amare. L’amore divino soprannaturale, invece, è gratuito, ama per primo.

         Se vogliamo quindi lasciar vivere l’"uomo nuovo" in noi, se vogliamo lasciar accesa
in noi la fiamma dell’amore soprannaturale, dobbiamo anche noi amare tutti ed amare per
primi.

         Dobbiamo insomma essere come Gesù, altri Gesù. Gesù è morto in croce per tutti: il
suo amore è stato universale. E con quella morte ha amato per primo.

         Quale allora il nostro proposito nei prossimi quindici giorni?

         Cogliere tutte le occasioni che si presentano per mettere in moto questo amore
nuovo che ama tutti ed ama per primo.

         Saremo creature nuove (cf. 2 Cor 5, 17), metteremo il nostro mattone per la
costruzione di un mondo nuovo.

         Il mondo vecchio se ne accorgerà e, trovando Gesù in noi, ne sarà attratto e crederà
in lui.$doc1691$, 'drive_import', '01691-WEB-1986-12-25-amare-tutti-amare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1691)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1692, 'ITA', $doc1692$Rocca di Papa, 8.12.88
NON FAR MORIRE GESÙ

Carissimi,

Mancano pochi giorni ormai a Natale ed è questa l’occasione per rivestirci a festa, per
rinascere nuovamente al nostro Ideale.
Ci spingerà a questa rinascita l’approfondimento della nuova tappa della "Via Mariae": la
fuga in Egitto.
L’altra volta abbiamo parlato di Gesù Abbandonato, del dolore più grande. La croce è, infatti,
condizione per camminare sicuri nella nostra via: la via dell’amore.
Questa volta prendiamo in considerazione il primo episodio, che il Vangelo descrive, in cui
Maria con Giuseppe ha dovuto affrontare e superare una vera croce: Erode vuole togliere di
mezzo Gesù bambino, facendolo morire; ma un angelo avverte Giuseppe in sogno ed egli
fugge in Egitto con la famiglia.
C’è dunque, per Maria, il pericolo di perdere Gesù. Così piccolo, è già minacciato di morte.
Per evitare questo tremendo pericolo, Maria affronta con Gesù e Giuseppe i disagi di un
lungo viaggio.
Perdere Gesù. Far morire Gesù.
Il nostro Ideale ha fatto vivere con pienezza Gesù nel nostro cuore. Ha operato ciò
accendendovi l’amore. Ed ecco che sulla morte del nostro uomo vecchio è apparso il Risorto,
con tutto un corteo di doni a gioia della nostra anima e a edificazione del Regno di Dio nel
mondo.
Ma occorre mantenere acceso questo amore, questo vero amore, e allontanare tutto ciò che
lo può spegnere, che può, in certo modo, far morire Gesù dentro di noi.
Tener acceso l’amore, quell’amore che lo Spirito Santo ha diffuso nei nostri cuori, e che –
come abbiamo visto tempo fa – deve esprimersi in fatti concreti.
Nei prossimi quindici giorni dobbiamo esaminarci proprio su questo particolare dell’amore,
sulla sua concretezza, e lavorare a renderlo autentico.
Come?
Un’occasione ce la dà un tema dell’anno in corso. Esso tratta della povertà, di quella povertà
che, per noi, ha significato soprattutto come effetto della carità vissuta.

Un’altra occasione ce la dà la Parola di Vita del mese: "Chi ha due tuniche ne dia una a chi
non ne ha [...]" (Lc 3, 11).

Noi sappiamo come, vivendo nel mondo, è facile impolverarsi, raccogliere via via cose più o
meno utili, o superflue, e tenerle nelle proprie case.

Si tratta magari di una matita in più, di un libro, di un indumento, uno strumento, un
quadro, un tappeto; di biancheria, di mobili; di cose voluminose, di piccole, di una somma di
denaro...

Perché non raccogliere tutti questi oggetti e metterli a disposizione di chi non ne ha nella
nostra comunità, o dei poveri, o del "Gesù Abbandonato quotidiano", come noi definiamo le
calamità che gettano nel dolore, nelle angosce, nel freddo e nei pericoli tanta gente?

Ogni mattina, appena alzati, ci si lava il volto.

Non sarà forse necessario ogni anno, all’inizio dell’anno, fare una verifica del nostro
superfluo e donarlo per obbligo di carità?

Ho già detto questo ai focolarini. Nel focolare si fa di tanto in tanto quello che noi chiamiamo
"il fagotto": si ammucchia cioè tutto ciò che è in sovrappiù e lo si distribuisce.

Ma non può essere attuato da tutti noi, membri interni del Movimento, questo?

Raccogliendo il superfluo e donandolo, la nostra carità verso i prossimi sarà vera e
salveremo perciò, per essa, la presenza viva del Risorto in noi.

Io ho sperimentato che per attuare ciò occorre un po’ di tempo. Bisogna considerare bene
cosa per cosa. Disporre naturalmente solo di ciò che possiamo dire nostro, e definire: questo
è superfluo, questo no. Ed essere generosi, pensando che è meglio rimanere senza qualcosa
di utile piuttosto che averne in sovrappiù.

La fuga in Egitto. Maria è fuggita perché a Gesù non venisse tolta la vita. Fuggiamo anche noi
da quegli attaccamenti, da quel poco o tanto di consumismo che è penetrato, magari
involontariamente, nella nostra vita.

Ci sentiremo più liberi e più leggeri, più atti a lavorare per l’Opera di Dio e a fare del
presente un anno fruttuosissimo.$doc1692$, 'drive_import', '01692-WEB-1988-12-08-non-far-morire-ges-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1692)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1693, 'ITA', $doc1693$Rocca di Papa, 22.12.88
1989
SERE FUOCO

Carissimi,

Continuiamo il nostro cammino lungo la "Via Mariae" e vediamo, anche oggi, se le tappe di
questo straordinario itinerario della mamma di Gesù e nostra possono insegnarci qualcosa.
Siamo all’episodio in cui Maria e Giuseppe perdono Gesù a Gerusalemme (cf. Lc 2, 41-45).
Noi sappiamo come tale circostanza della vita di Maria illumini soprattutto un periodo della
nostra vita spirituale in cui si fanno presenti specifiche difficoltà, sofferenze, prove.
Vogliamo però, oggi, come le volte scorse, considerare tale mistero in un suo particolare,
nella sua conclusione: il ritrovamento di Gesù nel tempio.
La vita spirituale ha svariati aspetti: gioiosi, amari, indifferenti, e io penso che nessuno di
noi può negare di avere sperimentato un giorno in qualche maniera, per una circostanza,
per un incontro, per un convegno, per una grazia particolare, magari in seguito ad una
prova, ciò che ha provato Maria quando, dopo lunga ricerca, ha ritrovato Gesù. È l’Ideale,
che ci aveva affascinato un giorno, che si ripresenta nel suo splendore, è il volto luminoso di
Gesù che si riaffaccia alla nostra anima.
Sono momenti che ricaricano lo spirito, che tonificano l’anima, che fanno grandemente
sperare, che aiutano a riprendere con lena il Santo Viaggio della vita.
Ritrovare Gesù, riscoprire Gesù, lasciarsi riavvolgere dalla sua luce, lasciarsi riaccendere dal
suo fuoco.
Io desidererei che questo Collegamento potesse esserne un’occasione.
Ne abbiamo parlato più volte qui a Roma nei nostri ultimi convegni. Ma lo voglio ripetere a
tutti voi.
Abbiamo un sogno: era solo mio prima, ma ora è di tanti. Poggia su fatti reali, anche se ha
tutta l’apparenza di un’utopia.
Santa Caterina ha detto un giorno ai suoi: "Se voi sarete quelli che dovete essere, metterete
fuoco in tutta Italia"; "Non contentatevi delle piccole cose perché egli, Dio, le vuole grandi".
I "suoi", non di Caterina questa volta, ma di Maria, della sua Opera, sono diffusi non solo in
Italia ma, si può dire, in tutte le nazioni del mondo. Perché ella non potrebbe dirci: "Se voi
sarete quelli che dovete essere, metterete fuoco in tutto il mondo"? Non è forse esperienza
particolarissima di Maria il vedere Dio operare cose grandi?

È questo il sogno: mettere fuoco in tutto il mondo. Vivere e operare, collaborando con
quante altre forze buone agiscono oggi sul nostro pianeta, per un’invasione d’amore nel
mondo.

Aver questo dinanzi come programma. Programma che è quello stesso impresso da Dio sul
nostro Movimento nascente.

Foco, così l’ha visto nei suoi primi membri e così l’ha definito: "Arrivare a Dio attraverso un
incendio di anime".

È, dunque, questa la nostra vocazione. Farla propria, oggi, è ritrovare Gesù, quel Gesù,
quell’Ideale che un giorno ha aperto una via nuovissima alla nostra vita.

Tendere lì è la spiegazione di quella realtà che Dio, non senza la nostra povera
collaborazione, ha fino ad oggi costruito nel mondo.

Noi la conosciamo: l’Opera è una rete d’amore che ormai lo abbraccia tutto.

Essa non può non essere destinata a divenire sempre più fitta e, accendendo molti e molti
con l’amore, a far sì che molti e molti incontrino o riincontrino Gesù.

Tendere lì è dare anche noi il contributo alla realizzazione di quella "civiltà dell’amore"
invocata, pensiamo non senza una visione profetica, da Paolo VI e da Giovanni Paolo II.

Per lavorare però al nostro programma è necessario tener presenti due cose: anzitutto
essere sempre più coscienti che in questa sua Opera si segue Dio e non creature umane; ed
essere noi fuoco per incendiare gli altri.

Essere fuoco; essere anche un piccolo fuoco, ma sempre acceso.

Un incendio nasce in genere da una scintilla.

Essere un fuoco acceso. E perché ciò sia, bruciare qualche cosa.

Anzitutto il nostro io, essendo sempre tutti protesi verso l’Altro e gli altri: Dio nella sua
volontà e i fratelli.

E poi mantenere acceso il fuoco e accrescerlo accendendo i fratelli stessi.

Un fuoco acceso anche piccolo, se alimentato, vince su tutto. Un fuoco su un tavolo presto o
tardi brucia il tavolo, il pavimento, la casa. E tutto diventa fuoco, diventa incendio.

Ecco: dobbiamo essere anche noi così: fuoco in tutte le occasioni, per poter essere certi di
aver ritrovato Gesù, il suo e nostro Ideale.
E allora? Non perdere occasione per alimentare il fuoco.
Vivere nell’amore, dell’amore.
Questa è la parola d’ordine per i prossimi quindici giorni.$doc1693$, 'drive_import', '01693-WEB-1988-12-22-sere-fuoco-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1693)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1694, 'ITA', $doc1694$Rocca di Papa, 12.1.89

I QUATTRO MODI DI PREGARE

Carissimi,

Passando in rassegna – come abbiamo fatto in quest’ultimo tempo – le tappe della "Via
Mariae", per cogliere in qualche loro particolare nuova luce per il nostro Santo Viaggio, ci
siamo soffermati nell’ultimo Collegamento su Gesù ritrovato nel tempio.

Questa volta dobbiamo esaminare la tappa successiva: il lungo periodo in cui Maria visse
accanto a Gesù in un’intimità profonda, in un colloquio così eccezionale da essere secondo
soltanto a quello che dall’eternità si snoda fra le Persone della SS. Trinità.

Maria, in quei lunghi anni, ha certamente parlato spesso con Gesù, e Gesù le ha risposto.
Gesù ha parlato con Maria e Maria gli ha risposto.

Ma che cosa si saranno detti fra loro? Senz’altro molte cose: della vita di famiglia, del lavoro,
dell’ambiente, delle usanze, della Bibbia... e chissà quante altre cose ancora a noi ignote.

Certamente quella madre era una madre speciale e quel Figlio un figlio specialissimo. Il
rapporto fra Maria e Gesù era comunque sempre quello tra una creatura, seppur altissima, e
il suo Creatore.

Esso ci fa ricordare, in qualche modo, anche il nostro rapporto con Gesù, la nostra unione
con lui, con tutte le espressioni di amore, di confidenza, di richiesta, di lode che lo
caratterizzano e che noi definiamo – prendendo la cosa nel senso più vasto – "preghiera".

Oggi, ricordando i trent’anni di vita di unità fra Maria e Gesù, diremo – come ho già fatto
anche in passato – qualcosa sulla preghiera.

Ho notato, soprattutto in questi ultimi giorni, che i fondatori, ogni fondatore e le varie
correnti spirituali che da essi nascono, sotto l’impulso dello Spirito Santo, insegnano a
pregare in modo assai diverso l’uno dall’altro, anche se per tutti la preghiera occupa il
primo posto. Essa, infatti, è diretta espressione e risposta a quel comando che è il primo di
tutti: "Amerai il Signore Dio tuo".

Approfondendo queste varie preghiere, tutte belle, tutte affascinanti, come quelle insegnate
da santa Teresa d’Avila, da santa Caterina da Siena, da san Francesco d’Assisi, da san
Francesco di Sales, ecc., ho cercato di confrontarle con la nostra, di vedere cioè come lo
Spirito Santo ha insegnato a noi a pregare.

E ho visto che, fondamentalmente (quando si tratta sempre di preghiera personale), noi
preghiamo in quattro modi.
Anzitutto con la preghiera "vocale". Recitiamo cioè ogni giorno le preghiere che ci sono
consigliate dalla Chiesa e prescritte dai nostri regolamenti. Lo vogliamo fare non
meccanicamente, ma, possibilmente, con tutta la mente e con tutto il cuore.

Inoltre, poiché viviamo l’amore al prossimo ed abbracciamo Gesù Abbandonato in tutti i
suoi volti, noi abbiamo sperimentato nel nostro cuore, poco o tanto, l’unione con Dio. Essa ci
porta a parlare spontaneamente con Gesù, col Padre, con lo Spirito Santo o con Maria:
confidiamo loro i nostri problemi, chiediamo aiuto in tutte le necessità, li teniamo aggiornati
del nostro lavoro, offriamo loro le nostre gioie, ecc. Si tratta di quella preghiera fatta anche
solo di sguardi, di silenzi, d’intese, che tutti chiamano – con una parola che non ne esprime
bene il significato –: preghiera "mentale".

E ancora, noi siamo soliti offrire a Gesù – in genere con un "per Te" – tutto quanto facciamo,
decisi a compiere poi ogni nostra azione meglio che possiamo, perché consci di fare di essa
un prolungamento dell’azione creatrice di Dio e redentrice di Gesù per l’esecuzione dei
piani di Dio sul mondo. Trasformiamo così tutto il nostro agire umano in un’azione sacra. Ed
è questa la preghiera più sentita ai giorni nostri. Per essa, attuiamo il comando di Gesù sulla
necessità di pregare sempre, senza stancarsi (cf. Lc 18, 1).

Infine, il nostro quarto modo di pregare è quello di offrire a Gesù i nostri dolori, piccoli o
grandi, per lavorare con lui alla redenzione del mondo.

Quale l’impegno, dunque, per i prossimi quindici giorni?

Abbiamo parlato l’altra volta di "invasione d’amore". Ma ogni operazione che si fa, in favore
del Regno di Dio, si sostiene solo se le nostre braccia sono alzate, come ricorda Mosè (cf. Es
17, 11).

È la preghiera che potrà rendere veramente fecondo il nostro operare.

E allora sotto: a puntellare il nostro "sogno" con la preghiera ben fatta. Non dandoci pace se
essa non è migliorata sotto tutti gli aspetti.

Che il nostro motto sia: "Pregare bene per invadere il mondo di amore".$doc1694$, 'drive_import', '01694-WEB-1989-01-12-i-quattro-modi-di-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1694)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1695, 'ITA', $doc1695$Rocca di Papa, 23.2.89

"ABBà, PADRE!"

Carissimi,

Nell’ultimo Collegamento, soffermandoci un po’ sulla tappa della "Via Mariae", che riguarda
i lunghi anni di vita privata e intima fra Maria e Gesù, il loro profondo e insondabile
rapporto, abbiamo parlato un po’ della preghiera e in particolare della preghiera personale,
privata. Abbiamo puntualizzato quei tipici modi di pregare a cui lo Spirito ha condotto tutti
noi in questi quarant’anni di vita, anche se, come si sa, esistono membri del nostro
Movimento, come i religiosi ad esempio, che devono tenere in assoluta considerazione altre
preghiere e altri modi di pregare, suggeriti dai loro fondatori e dalle loro regole.

Questa volta parleremo ancora di preghiera: è il respiro della nostra anima, l’ossigeno di
tutta la nostra vita spirituale, l’espressione del nostro amore a Dio, il carburante di ogni
nostra attività.

Ma di quale preghiera tratteremo?

Di quella che – con le infinite e divine ricchezze che contiene – è tutta racchiusa in una
parola, in una sola parola, che Gesù ci ha insegnato e lo Spirito ha messo sulle nostre labbra.

Ma veniamo alla sua genesi.

Gesù pregava, pregava il Padre suo. Per lui il Padre era "Abbà" e cioè il babbo, il papà, cui
egli si rivolgeva con accenti di infinita confidenza e di sterminato amore. Lo pregava
essendo nel seno della Trinità, dove egli è la seconda divina Persona.

È stato proprio anche per questa sua particolarissima preghiera che ha rivelato al mondo
chi egli realmente era: il Figlio di Dio.

Ma, giacché era venuto in terra per noi, non gli è bastato essere lui in questa condizione
privilegiata di preghiera. Morendo per noi, redimendoci, ci ha fatti figli di Dio, fratelli suoi, e
ha dato anche a noi, tramite lo Spirito Santo, la possibilità d’essere introdotti nel seno della
Trinità, in lui, assieme a lui, per mezzo di lui. Cosicché anche a noi è stata resa possibile
quella sua divina invocazione: "Abbà, Padre!" – (Mc 14, 36 e Rm 8, 15): "Papà, babbo mio!",
nostro – con tutto ciò che essa comporta: certezza della sua protezione, sicurezza, cieco
abbandono al suo amore, consolazioni divine, forza, ardore; ardore che nasce in cuore a chi
è certo di essere amato...
È questa la preghiera cristiana, una preghiera straordinaria. Non si riscontra in altri luoghi,
né in altre religioni. Al più, se si crede in una divinità, la si venera, la si adora, la si supplica
stando, per così dire, all’esterno di essa. Qui no, qui si entra nel Cuore di Dio.

E allora?

Allora ricordiamoci anzitutto della vertiginosa altezza a cui siamo chiamati come figli di Dio
e, di conseguenza, dell’eccezionale nostra possibilità di pregare.

Naturalmente, si può dire "Abbà, Padre!", con tutto il significato che questa parola
comporta, solo se lo Spirito Santo la pronuncia in noi.

E, perché ciò sia, occorre essere Gesù, null’altro che Gesù.

Il modo? Lo sappiamo: egli già vive in noi per la grazia. Ma occorre fare la parte nostra. Essa
consiste nell’amare, nell’essere nell’amore verso Dio e verso il prossimo.

Con più pienezza poi lo Spirito la porrà sulle nostre labbra se saremo in perfetta unità coi
nostri fratelli, dove Gesù è fra noi.

"Abbà, Padre!", sia la nostra preghiera, specie nei prossimi quindici giorni. Per essa
corrisponderemo in pieno alla nostra chiamata a credere all’amore, alla fede nell’amore che
sta alla radice del nostro carisma.

Sì, l’Amore, il Padre ci ama. È il nostro papà: di che possiamo temere?

E come non vedere nel disegno d’amore che egli ha su ciascuno di noi, e che ci si rivela
giorno dopo giorno, la più straordinaria avventura a cui potevamo essere chiamati?

"Abbà" è la tipica preghiera del cristiano. E in modo speciale di noi focolarini.

Se siamo dunque sicuri che stiamo vivendo il nostro Ideale, se siamo cioè nell’amore,
rivolgiamoci al Padre così, come faceva Gesù.

Le conseguenze? Le sentiremo nel nostro cuore.$doc1695$, 'drive_import', '01695-WEB-1989-02-23-abb-padre-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1695)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1696, 'ITA', $doc1696$Rocca di Papa, 9.3.89

"VIENI, SIGNORE GESÙ!"

Carissimi,

Oggi è giovedì santo, un giorno specialissimo per noi. Esso ci ricorda diverse realtà divine
che stanno al cuore della nostra spiritualità, sicché ogni anno, alla sua ricorrenza,
avvertiamo tutto il fascino di questo giorno e non è raro che qualcosa di paradiso investa la
nostra anima.

Come infatti non sentire il nostro cuore dilatarsi se il giovedì santo sottolinea in tale modo il
comandamento nuovo di Gesù, l’unità, suo testamento, l’Eucaristia, suo straordinario dono,
e il sacerdozio che la rende possibile?

Soffermiamoci allora oggi con immensa gratitudine su questi straordinarissimi misteri
fondamentali per ogni cristiano e per noi in particolare.

E domani sarà venerdì santo. Anch’esso ci porta nel cuore del cristianesimo e della nostra
spiritualità: Gesù muore, muore abbandonato.

Non vi sembra questo il momento di affrontare, in qualche modo, un tema che oggi, in un
mondo così com’è, preso dal consumismo e da altri mali, nessuno o ben pochi sono disposti
a trattare, e cioè l’argomento della morte?

Noi lo dobbiamo fare per coerenza col nostro Ideale che insegna come affrontare ogni
momento della vita e, quindi, anche il passaggio all’altra, quella eterna.

E lo trattiamo rimanendo nell’ambito della preghiera, nostro argomento preferito in queste
ultime settimane.

Esiste una preghiera brevissima anch’essa, stupenda.

Lo Spirito l’ha posta sulle labbra della Sposa, la Chiesa, ed è diretta allo Sposo, Gesù.

Si conclude con essa l’Apocalisse, l’ultimo dei nostri libri sacri. Dice così: "Vieni, Signore
Gesù!" (Ap 22, 20).

"Vieni, Signore Gesù!".

Questa preghiera potrebbe essere la nostra pensando, attendendo, preparandoci alla morte.

Sì, perché noi abbiamo o dobbiamo avere un concetto nostro ed esatto della morte: essa non
è la fine, ma l’inizio; l’incontro con Gesù. E ancora: essa non è facoltativa: è nel programma
di tutti; un giorno arriverà per tutti, è volontà di Dio per tutti.
Sì, è volontà di Dio per me, per noi, per ognuno.

Bisogna saperla accogliere allora come tale, come volontà di Dio.

Ma come accettiamo noi in genere la volontà di Dio?

Abbiamo capito che la volontà di Dio, qualunque essa sia, è l’espressione dell’amore di Dio
per noi.

Non è logico né giusto allora accettarla unicamente con rassegnazione, ma occorre vedervi
ciò che di meglio può capitarci. Per cui, noi ci sforziamo di vivere in modo che la volontà di
Dio sia la nostra.

E ci impegniamo a viverla non solo con tutto l’amore, ma con entusiasmo, perché sappiamo
che, per essa, siamo incamminati in un’avventura divina, in parte nota, in parte da scoprire,
e compiamo così il disegno di Dio su di noi.

È da questo modo di affrontare la volontà di Dio, infatti, che si distingue un focolarino,
perché è su questo punto che è avvenuta la nostra conversione, che ha cambiato rotta la
nostra vita.

Ma, se vediamo così ogni volontà di Dio, dobbiamo vedere così anche la morte.

Al di là delle malattie, dei dolori spirituali e fisici che la potranno accompagnare, essa è un
dono, un nuovo dono da accettare con riconoscenza, l’ultimo prima del Paradiso.

Per questo non è il caso di vivere come se essa non esistesse, ma piuttosto di metterla in
programma e di disporsi sempre meglio ad accoglierla con gioia, ad attenderla con desiderio
ardente – come hanno fatto i santi –, aiutandoci con la preghiera: "Vieni, Signore Gesù!"

"Vieni, Signore Gesù!"

Se pensiamo alla morte: "Vieni, Signore Gesù!" Per questo invito del nostro cuore molte
paure spariranno, tutto si schiarirà. E Gesù verrà, alla sua ora. Verrà proprio lui.

Ma questa preghiera va bene anche per altre occasioni.

Si può dire: "Vieni, Signore Gesù!" attendendo la santa Comunione.

La possiamo dire prima di un incontro con qualche persona o gruppo in cui vogliamo
assolutamente amare lui. E prima di adempiere ogni altra sua volontà.

"Vieni, Signore Gesù!". Guardando a te, l’amore, nostra vocazione, sarà senza timore.

Nell’attesa della tua venuta, costruiremo bene questa vita e, appena si aprirà l’altra, ci
tufferemo nell’avventura senza fine.

Tu hai vinto la morte. E per questa preghiera avvertiamo che tu, sin d’ora, l’hai vinta anche
in noi, nel nostro cuore.
"Vieni – allora – Signore Gesù!", sempre, in tutti noi.

E la morte non sarà; tu sarai. Il Risorto sarà. E questo è già Pasqua.

Auguri a tutti per una Pasqua gloriosa e senza interruzione, feconda, fecondissima per noi,
per la Chiesa e per il mondo.$doc1696$, 'drive_import', '01696-WEB-1989-03-09-vieni-signore-ges-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1696)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1697, 'ITA', $doc1697$Rocca di Papa, 23.3.89

AMORE CHE SI VEDE

Carissimi,

Vivendo il pensiero dei Collegamenti scorsi, abbiamo cercato di ispirarci alla tappa
della "Via Mariae" che ricorda il lungo periodo di vita familiare e intima fra Maria e il
suo Figlio, prima dell’uscita di Gesù a vita pubblica.
Per questo abbiamo approfondito qualche aspetto della nostra unione con Gesù e col Padre,
e cioè della preghiera.

Questa volta la "Via Mariae" ci presenta un altro quadro: Gesù incomincia la sua
missione e Maria, a suo modo, lo segue.
Questa tappa corrisponde a quel periodo della vita spirituale in cui la persona, dopo aver a
lungo cercato di distinguere dentro di sé, fra le tante, la voce interiore, la voce di Dio, per
conoscere e attuare la sua volontà, è così familiarizzata con essa che le è usuale seguirla.

Non so chi fra tutti noi può affermare di essere arrivato a questo punto della vita spirituale
così alto, così eminente.

So però che tutti possiamo e dobbiamo sforzarci di ascoltare la sua voce, la sua parola in
fondo al cuore.

E una parola certamente Dio ripete costantemente a tutti noi. Non saremmo del nostro
Movimento se fosse altrimenti. È la parola che ha pronunciato quando esso è nato; che ha
indirizzato a tutti noi quando ci ha chiamati singolarmente a questa nuova vita e che non
smette mai di ricordarci perché è in essa che troviamo la nostra identità; è per essa, attuata,
che il Movimento trova e ritrova sempre la sua vera natura.

Questa parola è "Amatevi a vicenda".

È la vocazione di ogni cristiano, ma, potremmo aggiungere, di noi in particolare.

Mi hanno fatto pensare in questi giorni le parole che si dicevano dei primi cristiani: "Guarda
come si amano e l’un per l’altro sono pronti a morire" 24.

Dunque si vedeva che ognuno era pronto a morire per l’altro. Forse ciò dipendeva dal fatto
che, in tempi di persecuzione, non era raro il caso che qualcuno si offrisse a morire per
l’altro. Resta tuttavia il fatto che, questa misura d’amarsi fra i cristiani, si vedeva.

A noi, in genere, non è chiesto proprio di morire. Tuttavia dobbiamo essere pronti. Ogni
nostro atto d’amore reciproco va fatto su questa base.
E allora? Che fare in questi giorni?

Alziamo il termometro della nostra reciproca carità. Che anche un semplice nostro sorriso, o
un gesto, o un atto di amore, o una parola, o un consiglio, o un apprezzamento, o una
correzione a suo tempo, rivolti ai fratelli, rivelino la nostra prontezza a morire per loro. Che
si veda il nostro amore, non certo per vanità, ma per garantirci l’arma potente della
testimonianza.

Siamo spesso anche noi, come i primi cristiani, in un mondo senza Dio, scristianizzato.
Dobbiamo, dunque, testimoniare Gesù.

Ed è così che tutti noi potremo seguirlo anche nella sua vita pubblica, quando ha svolto il
suo apostolato.

Per noi, per tutti noi, il tipico modo di irradiare il messaggio di Cristo nel mondo è, lo
sappiamo, comporci e vivere in perfetta unità. Sta qui il 90% dell’efficacia della nostra
azione per annunciare la Buona Novella.

Dunque, come prima cosa, "che si veda".

Poi rinnoviamo (nei focolari, nei nuclei, nelle unità gen, prima degli incontri per "interni",
ecc.) il nostro patto di unità: "Io sono pronto a morire per te, ecc.". Facciamolo un po’
solennemente davanti a qualche immagine di Gesù, in qualche chiesa. Quanti lo desiderano
lo stipulino, in questo mese di maggio, in qualche santuario mariano o di fronte ad una sua
immagine, di Maria, intendendo mettere la nostra decisione nelle sue mani perché la porti a
suo Figlio.

Anch’io mi porterò, assieme a tutto il Consiglio di Coordinamento, a Loreto. Vogliamo
commemorare in quel santuario il cinquantesimo della nostra vita, considerando come
prima tappa quel mio lontano viaggio in cui compresi che si apriva per noi una nuova via
nella Chiesa. E lì, offrendo a Maria tutta l’Opera che ne è nata (Mariapoli terrestre e
Mariapoli celeste), rinnoveremo fra noi, con tutti voi e con quanti condividono l’Ideale, il
nostro patto.

Voi, sono certa, sarete spiritualmente con noi, come noi saremo con voi.

Allora, in questi quindici giorni il nostro motto è questo: "Un amore che si vede e il patto".$doc1697$, 'drive_import', '01697-WEB-1989-03-23-amore-che-si-vede-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1697)
on conflict (document_id, language) do nothing;
