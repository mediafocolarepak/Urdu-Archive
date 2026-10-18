-- 102_import_italian_originals_part13.sql (13/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1798-1817 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1798, 'ITA', $doc1798$Castel Gandolfo, 9 marzo 2000

Le 4 parole"

Carissime,

         buon Giovedì Santo!

In questo mese di aprile il nostro Collegamento coincide proprio con questo giorno tanto
speciale per tutti i cristiani.

E noi che, a motivo della nostra spiritualità fiorita dal carisma donatoci dallo Spirito Santo,
lo avvertiamo specialissimo, non possiamo oggi non fermarci un po' a meditare, a
contemplare, a cercare di rivivere i misteri che svela, assieme a quelli di venerdì e sabato
santo e di domenica di Pasqua.

         Ognuno di questi giorni, lo possiamo intanto intitolare con una parola che dice –
anzi, vorrei dire –, grida da più di 50 anni nel Movimento il nostro dover essere: Amore il
Giovedì Santo; Gesù abbandonato domani, il Venerdì Santo; Maria il Sabato Santo; il Risorto
la Domenica di Pasqua.

         Oggi, dunque, Amore. Il Giovedì Santo, giorno nel quale, durante gli anni, abbiamo
sperimentato spesso la dolcezza d'una particolare intimità con Dio, ci ricorda quella
profusione di amore che il Cielo ha riversato sulla Terra.

         Amore innanzitutto l'Eucaristia, donataci in questo giorno.

         Amore il sacerdozio che è servizio d'amore e ci dà, fra il resto, la possibilità
dell'Eucaristia.

         Amore l'unità, effetto dell'amore, che Gesù, come oggi, ha implorato dal Padre: "Che
tutti siano uno come io e te"(cf Gv 17,21).

         Amore il comandamento nuovo che Egli ha rivelato in questo giorno prima di
morire: "Come io vi ho amato, così amatevi anche voi gli uni gli altri. Da questo tutti
sapranno che siete miei discepoli, se avrete amore gli uni per gli altri" (Gv 13,34-35).
Comando che ci permette qui in terra una vita sul modello della Santissima Trinità.

Domani: Venerdì Santo. Un solo nome: Gesù abbandonato.

         Ho scritto un libro su di Lui in questi giorni intitolato: "Il grido". L'ho dedicato a Lui
con l'intenzione di scriverlo anche a nome vostro, a nome di tutta l'Opera di Maria "Come -
questa è la dedica - una lettera d'amore a Gesù abbandonato".
         In esso si parla di Lui che, nell'unica vita data a noi da Dio, un giorno, un preciso
giorno, diverso per ciascuno di noi, ci ha chiamati a seguirlo, a donarci a Lui.

         E si capisce - lo dichiaro lì - come tutto ciò che voglio dire in quelle pagine, non può
essere un tema, pur familiare, caldo, intimo, sentito; ma vuol essere un canto, un inno di
gioia e soprattutto di gratitudine verso di Lui.

Aveva dato tutto: una vita accanto a Maria nei disagi e nell'obbedienza. Tre anni di
predicazione, tre ore di croce, dalla quale dà il perdono ai carnefici, apre il Paradiso al
ladrone, dona a noi la Madre. Gli rimaneva la divinità.

La sua unione col Padre, la dolcissima e ineffabile unione con Lui, che l'aveva fatto tanto
potente in terra, quale figlio di Dio, e tanto regale in croce, questo sentimento della presenza
di Dio doveva scendere nel fondo della sua anima, non farsi più sentire, disunirlo in qualche
modo da Colui col quale Egli aveva detto di essere uno, e grida: "Dio mio, Dio mio, perché mi
hai abbandonato?" (Mt 27,46).

Dopo domani: Sabato Santo. Maria è sola. Sola col suo figlio-Dio morto. Un abisso
incolmabile di angoscia, uno strazio infinito? Sì, ma Ella sta ritta in piedi, divenendo un
esempio eccelso, un monumento di tutte le virtù. Lei spera, lei crede: le parole di Gesù che,
durante la vita annunziavano la sua morte, ma anche la sua risurrezione, se altri le hanno
scordate, Lei non le ha mai dimenticate: conservava queste, con altre, nel suo cuore e le
meditava (cf Lc 2,51).

         Perciò non soccombe al dolore: attende.

E, finalmente: Domenica di Pasqua.

         E' il trionfo di Gesù risorto che conosciamo e riviviamo, anche in noi nel nostro
piccolo personalmente, dopo aver abbracciato l'abbandono, o quando uniti veramente nel
suo nome, sperimentiamo gli effetti della sua vita, i frutti del suo Spirito.

         Il Risorto deve essere sempre presente e vivo in noi in questo anno 2000, in cui il
mondo attende non solo persone che credono e lo amano in qualche maniera, ma testimoni
autentici che possano dire in tutta verità, come già la Maddalena agli apostoli dopo averlo
incontrato nei pressi della tomba, quelle parole che conosciamo, ma che sono sempre
nuove: "L'abbiamo visto!" Sì, noi l'abbiamo scoperto nella luce con cui ci ha illuminato;
l'abbiamo toccato nella pace che ci ha infuso; l'abbiamo sentito nella sua voce in fondo al
cuore; abbiamo gustato la sua gioia senza confronto.
Carissime, ricordiamoci allora in questi giorni 4 parole: amore, Gesù abbandonato, Maria, il
Risorto. E perché diventino vita, niente di meglio che continuare a vivere: "Ciò che mi fa
male è mio": nei confronti dei fratelli sofferenti, amandoli; a proposito delle nostre personali
sofferenze con l'abbraccio di Gesù abbandonato; nelle prove dell'Opera, presenza mistica di
Maria nella Chiesa e nel mondo, prove che dobbiamo superare; nello sforzo di non privarci
mai di Lui in noi e in mezzo a noi: il Risorto.

         "Ciò che mi fa male è mio!" Fatto questo è tutto fatto.$doc1798$, 'drive_import', '01798-WEB-2000-03-09-le-4-parole-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1798)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1799, 'ITA', $doc1799$Castel Gandolfo, 20 aprile 2000

Quel sorriso

Carissimi,

         una settimana fa tornavo a Rocca da Fontem, in Africa, dove mi sono trattenuta per
13 giorni. Nel mio cuore un'immensa gratitudine a Dio ed al popolo Bangwa per quanto ho
vissuto e sperimentato.

         E' difficile descrivere la gentilezza, la sovrabbondante generosità, l'aspetto sano e
robusto, la fierezza (specie dei giovani), la virilità, d'un popolo che qualche decennio fa
sembrava destinato all'estinzione.

         E poi quel sorriso che, già belli, rendeva tutti più belli e amabili.

         Sarete ancor oggi, e molto più in seguito, aggiornati su tutto quanto è successo
laggiù.

         E, intanto, un'esperienza particolare. Di che cosa ho parlato loro? Di vari argomenti
a seconda degli uditori, ma con una costante: invitarli tutti ad amare, ad amarsi, all'unità.

         Lo dicevo ai cattolici presenti, che stanno crescendo per i molti battesimi specie di
adulti, ai cristiani di un'altra Chiesa, pochi ma vivi, ai molti che seguono tuttora la religione
tradizionale.

         Lo dicevo e lo ripetevo. Veniva detto e ripetuto da altri, come dal generosissimo Fon
di Fontem, il loro re, Lucas Njifua.

         E vedevo sotto quell'unico annuncio tutti rifiorire, tutti più uno fra loro e con noi.
Perché?

         Me ne sono resa pienamente conto l'ultimo giorno: perché in quell'invito ad amare,
nella carità verso Dio e il prossimo sono riassunti l'Antico ed il Nuovo Testamento, ciò che
principalmente Dio richiede nell'uno e nell'altro. Perché lì anche l'Antico Testamento viene
in rilievo: per il sistema patriarcale della famiglia legata ancora a tradizioni ancestrali, per
quelle forme di vita che ti ricordano il tempo di Abramo, di Davide, di Salomone…

E lì noi, grati e stupiti (perché non ci avevamo mai pensato), abbiamo passato in rassegna i
dieci comandamenti, donatici da Dio nell'Antico Testamento, ed abbiamo costatato che chi
ama, coloro che amano veramente Dio e il prossimo, li osservano tutti e alla perfezione.

Non è forse vero che chi ama Dio, non può ammettere altri dèi nel suo cuore?

Che chi ama Dio dice il Suo nome con sacralità e non invano?
Che chi ama è felice di poter dedicare un giorno almeno alla settimana a Colui che più ama?

Non è forse vero che chi ama ogni prossimo non può non amare i propri genitori?

Non è evidente che chi ama gli altri non si mette nelle condizioni di derubarli, né di
ucciderli, né di approfittarsi di loro per i propri piaceri egoistici, né di testimoniare il falso
contro di loro?

Non è forse vero ancora che il suo cuore è già pieno e soddisfatto e non sente certo il
desiderio dei beni degli altri, delle creature altrui?

         E' così: chi ama non commette peccato, osserva i dieci comandamenti.

         Sappiamo molto bene poi, d'altra parte, come Gesù, nel Nuovo Testamento, ci dà la
sintesi della Legge e dei profeti (cf Mt 22,40), rivelando nella sua pienezza l'amore.

         Molti certamente, laggiù a Fontem, non conoscono ancora i due Testamenti, ma
cercando di vivere l'amore, sembravano esprimerli dai loro volti, dalle loro attenzioni, dalle
loro mosse, nelle ritmiche e coloratissime danze.

         Amavano, e illuminavano, come tanti piccoli soli, quelle vallate rigogliose del verde
d'una foresta ancora allo stato puro, l'ambiente donato loro dal Creatore.

         E allora, noi, pur fra il cemento degli agglomerati urbani che tanto spesso ci
soffocano e non lasciano spazio alla poesia dello spirito, che dobbiamo fare?

         Non dimenticheremo certo tutto ciò che ci è richiesto dalla nostra fede, ma
lasceremo vivere in pienezza l'amore, onde rendere feconde ed autentiche le nostre azioni.
Perché questa è la volontà di Dio su di noi, come ci ha detto un giorno il Santo Padre:
“L'amore è (…) la scintilla ispiratrice di tutto quello che si fa con il nome Focolari, di tutto
quello che voi siete, di tutto quello che voi fate nel mondo”.

         Fermiamoci qui durante questo mese. Fermiamoci qui. Fermarsi qui significa
camminare, volare perché è ciò che di meglio possiamo fare. Dice un pensatore: "Nel mondo
è sepolto un Dio che vuole risorgere nell'amore".

         Questo è il nostro dovere nei confronti dell'umanità intera.

         Perché, se l'amore domina nel cuore degli uomini, di tutti gli uomini del nostro
pianeta, Iddio non può non far sentire la Sua voce, la verità nel profondo del loro spirito.

         E allora non lasciamoci superare da nessuno nell'amare.$doc1799$, 'drive_import', '01799-WEB-2000-04-20-quel-sorriso-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1799)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1800, 'ITA', $doc1800$Castel Gandolfo, 29 novembre 2001

l nostro rapporto con le tre divine Persone

Carissimi e carissime,

         da poco è trascorso il Natale 2001 che ha ricordato il primo, quando, per la venuta
del Figlio di Dio incarnato sulla terra, noi abbiamo potuto divenire figli di Dio; figli, come
Lui, Figlio del Padre; figli nel Figlio.

E' presente, infatti, un infinito tesoro dentro di noi. L'abbiamo ancora descritto come una
voragine, come un abisso, come l'immenso dentro di noi, come un sole divino dentro di noi:
è la Trinità Santissima. Si ha, quindi, la possibilità di convivere con Essa, si può sentire il
richiamo a perdersi in Essa, per ritrovarsi cristificati. E, chiudendo le imposte dell'anima al
di fuori per aprirle al di dentro, si può colloquiare con Essa.

         E' un invito a intrattenerci nel Cielo dentro di noi, dove l'Eterno vive ed è l'Essere
vero.

         Ma non è solo preghiera ciò che domanda la Santissima Trinità dentro di noi. Le tre
divine Persone, che sono l'unico Amore, desiderano avere un rapporto di Cielo con ognuno
di noi; e l'una diverso dall'altra.

         Senz'altro, nel cammino ultra ventennale del nostro Santo Viaggio, parecchi di noi
possono aver sperimentato un proprio personale rapporto e col Padre e col Figlio e con lo
Spirito Santo.

         E' questo un argomento venuto in rilievo in quest'ultimo tempo, di cui mi sono
trovata a parlarne in varie occasioni, in posti e zone diverse, ma, in genere, ad una sola
categoria di persone. Per questo sarà utile oggi dirne ancora qualcosa, specificando
possibilmente i diversi modi che noi possiamo avere di rapportarci con le tre divine
Persone.

         Sarà un'occasione questa per renderci conto di quale ricchezza essi - questi modi -
rappresentino; di approfondirli, di perfezionarli, di dar loro il rilievo che meritano per la
nostra vita spirituale personale.

         Il Padre. Abbiamo il Padre. E' presente nel nostro intimo un Padre. Quel Padre
Celeste, che ha dato origine e sostiene l'immensa creazione, il cosmo, in cui siamo immersi
come goccia in un oceano, è pure qui nel nostro piccolo cuore.
         E questo Padre è padre davvero. Vari i nostri contatti con Lui: ad esempio è il
destinatario della più divina preghiera che possiamo pronunciare: il Padre nostro. Lo
invochiamo in nome di Gesù per ottenere le grazie desiderate.

Ma caratteristico per noi poi è quello che ci sottolinea il nostro carisma, ed è quanto san
Pietro suggerisce: gettare ogni sollecitudine in lui (cf 1 Pt 5,7).

         E, dobbiamo dirlo: quante volte (un'infinità di volte), buttando le nostre
preoccupazioni nel suo cuore, con fede, siamo stati da esse liberati in tutta fretta, svanite nel
nulla, risolte dal suo amore!

         Perché così si fa con un padre: ci si affida, in tutto e per tutto, a lui sicuri. E questo è
un padre: il sostegno, la certezza del figlio che, come un bambino, si butta spensierato fra le
sue braccia.

         Il Verbo. C'è anche il Figlio dentro di noi: il Verbo che, incarnato, è Gesù.

         C'è Gesù dentro di noi.

E quale il nostro rapporto soprattutto da quando viviamo il nostro grande Ideale? Vario,
molteplice. Ad esempio: lo abbiamo imparato ad amare profondamente nelle sue diverse
presenze: nell'Eucaristia, nella Parola, nell'unità tra i fratelli, nel povero, nell'autorità che lo
rappresenta..., nel profondo del nostro cuore.

         Ma c'è Gesù in un suo aspetto particolare, che noi riconosciamo e amiamo come
Sposo delle nostre anime: Gesù nel suo abbandono. E noi sappiamo quale Sposo sia stato
per noi e come lo sarà fino alla fine della nostra vita. E' stato Lui a sostenerci in tutte le
prove della vita, in tutte, suggerendoci come superarle, per ridare alla nostra vita luce e
pace e forza.

Gesù abbandonato, il nostro Sposo!

         E terzo lo Spirito Santo. Quello Spirito di cui conosciamo i divini effetti: nelle
persone, nelle comunità rinnovate dalla sua presenza, dalla sua atmosfera. Quello Spirito in
cui, come ad altri noi stessi, ci confidiamo sicuri; che sempre risponde quando lo
invochiamo e ci suggerisce parole di sapienza; che ci dà conforto, che ci sostiene, e ci ama
d'un amore particolare come un amico vero. E' nostro amico lo Spirito Santo.

         Padre, Sposo, amico. Che vogliamo di più? E, i tre, uno, un solo Amore che ha preso
stanza nel nostro cuore.

         Pensiamoci nel prossimo mese assieme a Maria, sulla quale lo Spirito Santo è sceso;
la potenza dell'Altissimo, il Padre, ha steso la sua ombra; nella quale il Verbo si è incarnato.
Manteniamo, rafforziamo con lei questi rapporti, mentre, continuando a vivere il momento
presente, ci inseriamo nel presente eterno in cui è Dio, in cui i Tre vivono, come sono vivi
nel nostro piccolo cuore.$doc1800$, 'drive_import', '01800-WEB-2001-11-29-l-nostro-rapporto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1800)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1801, 'ITA', $doc1801$Castel Gandolfo, 27 dicembre 2001
2002
Come Enzo

         Un mese fa Enzo partiva.

Carissime,

         seguendo un giorno la santa Messa col Messale, sono stata nuovamente colpita dalle
parole di Gesù: "Occorre sempre pregare".

         Non è la prima volta, come sapete, che affrontiamo questo nostro dovere di cristiani.
Lo stesso tema "L'amore eleva" ne parla. Anzi spiega la maniera di attuarlo. Ricordate? Con
l'amore, poiché in tal modo Gesù è vivo in noi, è vivo l'uomo nuovo, e Gesù, l'uomo nuovo,
prega sempre.
Oppure offrendo tutte le nostre azioni con un "Per Te" a Lui.

         Ma non esistono solo questi due modi.
         Leggendo un recente scritto di Enzo (si rafforza, giorno dopo giorno, in noi la
convinzione della profondità della sua anima e - diciamo pure - della sua santità), leggendo
un recente scritto suo, mi sono resa conto come lui, almeno nei suoi ultimi anni, era
costantemente alla presenza di Dio, sempre unito a Lui. Sempre.
Certamente questo suo straordinario atteggiamento era stato frutto della grazia di Dio a cui
si era allenato a corrispondere e, forse, di grazie particolari. Pensiamo solo al fatto che,
incaricato della vita spirituale dell'intero Movimento, poteva e doveva mantenersi sempre a
contatto col patrimonio prezioso che l'Opera custodisce sotto quest'aspetto.
         E com'era questa sua vita se essa obbediva al dovere di pregare in continuazione?
Sembra così: lavorando, studiando, scrivendo, servendo, mangiando, passeggiando,
parlando, ecc., viveva in un armonioso alternarsi fra il fare una cosa per Dio ed il colloquiare
con Lui. Un colloquio vivo, ogniqualvolta il lavorare, l'amare, il seguire qualche programma
anche televisivo glielo permetteva. Un modo di essere che è solo miracolo dell'amore:
miracolo di un'anima innamorata.
         Enzo aveva trascorso gli ultimi anni sulla croce. Una grave malattia l'aveva messo
più volte di fronte alla morte. Ma aveva accolto quel volto di Gesù abbandonato in modo – a
quanto a noi sembra – perfetto. Non un momento di impazienza, non il pur minimo lamento
con i fratelli; il suo dramma era solo affare suo, fra lui e Gesù.

A me confidava, anche se raramente, le sue condizioni fisiche, ma sorridendo, anzi ridendo.

E così, in quest'ultimo tempo, la sua vita, in una salita senza sosta, si è impreziosita di virtù e
Dio gli ha fatto la grazia dell'unione con sé.

         Noi tutti non siamo certo nelle condizioni di Enzo. Ma sono convinta che l'unione
con Dio, più o meno intensa, tutti la possiamo avere. Non invano abbiamo speso la vita ad
amare i fratelli. Ed è questa la garanzia di possedere tale tesoro. Più amiamo i fratelli, più
viene l'unione con Dio.

Forse non ci rendiamo conto di tale ricchezza che portiamo in noi, ma lo dobbiamo fare. Solo
chi è conscio d'essere ricco sa di poter disporre, come crede, dei suoi beni.

E noi tutti possiamo e dobbiamo cominciare a lasciare parlare il cuore con Colui che,
nell'ultimo Collegamento, abbiamo contemplato ospite della nostra anima.

         Proviamo anche noi a fare come Enzo: a rivolgerGli negli intervalli, fra azione ed
azione, la parola.

         Domani, quando pure noi seguiremo la sorte di Enzo, di Guglia, di Antonio, di Ginetta
e quanti altri sono con loro, chi incontreremo per primo, con chi parleremo? La fede ci dice
che sarà con Gesù che ci giudicherà.

         Che non succeda che, in quel momento, ci troviamo disorientati per non esserci
abituati ad incontrarLo. Ma che possiamo guardarLo sicuri negli occhi, ed in un sussulto
d'amore, abbracciare Colui che abbiamo cercato di amare sempre, con il quale abbiamo
cercato di parlare, di pregare sempre.

         In conclusione: approfittare, nella nostra quotidiana attività, di tutti gli attimi liberi
per dichiarare a Lui, presente in noi, il nostro amore sincero, come Enzo, come i nostri ora
Lassù.$doc1801$, 'drive_import', '01801-WEB-2001-12-27-come-enzo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1801)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1802, 'ITA', $doc1802$Castel Gandolfo, 31 gennaio 2002

Solenne sterzata

Carissimi,

         siamo, dunque, al Collegamento di febbraio.

         Grazie, innanzitutto, dei moltissimi fax che arrivano da tutte le parti del mondo dopo
il nostro incontro mensile planetario. Sono una gioia per me e per noi.

         Mi sorprende, infatti, ogni volta, come voi sottolineate e prendete tanto a cuore
parole, inviti, frasi che vi scoprite, come se foste presenti qui al Centro e forse di più: non
possono che essere luci dello Spirito Santo.

         E grazie anche perché cercate tutti i modi affinché le persone delle zone a voi
affidate possano avere lo stesso nutrimento spirituale e uguale aggiornamento il più
direttamente possibile, moltiplicando i punti d'ascolto che oggi sono arrivati ad essere 317.

         Grazie, grazie: nel Collegamento si sperimenta veramente l'amore che va e l'amore
che torna, con la vostra sempre espressa gratitudine e la vostra corrispondenza.

         Nel pensiero dedicato ad Enzo, del gennaio scorso, con il quale abbiamo cercato di
dare un incremento all'aspetto personale del nostro cammino spirituale, che è comunitario
e personale insieme, ci siamo convinti che è una grande perfezione alternare nella vita
spirituale azioni fatte per Iddio e parole d'amore rivolte a Lui.

         Ricordate?

         Ma qualcuno di noi può chiedersi: "Quali parole appropriate possiamo rivolgere a
Dio, cos'è bene dire a Lui in quei momenti, quale atteggiamento assumere?"

I santi, esperti in vita di perfezione, ci dicono - lo sapete - che basta una dichiarazione
d'amore sentita ("Mio Dio e mio Tutto"; "Mio Signore ti amo", ecc.) o anche un solo sguardo
rivolto a Lui, ad esempio, nel tabernacolo, perché tutto ciò è già vera preghiera. Lo stesso
"Per Te, Gesù" che abbiamo imparato a dire, prima di una nuova azione, è preghiera.

         Ma non sono tutti qui i modi di colloquiare con Lui.

         Dire in particolari circostanze, con rinnovato slancio e totale adesione della mente e
del cuore: "Sei Tu, Signore, l'unico mio bene", è anche un'ottima preghiera.

Tutti, infatti, ci accorgiamo che, non di rado, nel lavorare, nello scrivere, nel parlare, durante
il riposo o in quant'altro facciamo, può infilarsi qualche attaccamento anche lieve a noi
stessi, a cose, a persone... E accettare ciò è un grosso guaio per la vita spirituale. Dice san
Giovanni della Croce: "Che importa che l'uccello sia legato a un filo o a una corda! Per
quanto sottile sia il filo, l'uccello resterà legato come alla corda, finché non riuscirà a
strapparlo per volare. Lo stesso vale - continua - per l'anima legata a qualche cosa:
nonostante tutte le sue virtù non perverrà mai alla libertà dell'unione con Dio".

         E' necessario, perciò, in quelle circostanze, intervenire immediatamente, e niente
aiuta di più - è una mia esperienza anche recente - che ridichiarare a Gesù abbandonato:
"Sei Tu, Signore, l'unico mio bene. L'unico. Non ne ho altri".

         E' una preghiera, penso, importantissima e assai gradita a Dio. Ci aiuta a non
impolverarci con le cose terrene. E vivendola si resta impressionati - io lo sono stata e lo
sono sempre - di come quell'aggettivo: "unico" ("Sei Tu, Signore, l'unico mio bene") dia una
solenne sterzata alla nostra vita spirituale, come ci raddrizzi immediatamente, quasi fosse
sicuro ago della bussola del nostro cammino verso Dio.

         Questo modo d'agire, poi, è molto conforme alla nostra spiritualità, in cui prevale
l'aspetto positivo: si vive il bene e così se ne va il male. Non siamo tanto chiamati, infatti, a
staccarci da qualcosa (noi stessi, le cose, le persone), ma a riempirci di qualcosa (l'amore a
Lui nostro tutto). A noi non piacciono tanto i no, ma i sì.

         E questa preghiera, "Sei Tu, Signore, l'unico mio bene", è un modo meraviglioso per
vivere da veri cristiani che amano Dio con tutto il cuore, con tutta l'anima e non a metà.

E' una maniera sublime ancora per prepararci ad ogni incontro con Lui nelle sue ispirazioni
quotidiane; così come al grande incontro con Lui quando, all'alba dell'eterno giorno, nel
nostro cuore non varrà che l'amore a Dio e, per Lui, ai fratelli.

         "Sei Tu, Signore, l'unico mio bene": quanta sapienza, quanta saggezza, quanta luce,
quanta forza, quanto amore, quanta perfezione in queste brevi parole!

         Il Signore ci dia di sperimentarne tutta la loro potenza.$doc1802$, 'drive_import', '01802-WEB-2002-01-31-solenne-sterzata-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1802)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1803, 'ITA', $doc1803$Castel Gandolfo, 21 febbraio 2002
Vivere la Parola per amare Gesù abbandonato
nell'attimo presente della nostra vita

Carissime,

in questi ultimi anni, l'amore a Gesù abbandonato, nostro Ideale, Sposo delle anime nostre,
scopo della nostra vita, via maestra - come lo definisce il Papa - per realizzare la "spiritualità
di comunione" e, con essa, l'unità, ci ha portato - questo amore - a dichiarargli: "Sei Tu,
Signore, l'unico mio bene", ogni qual volta qualche cosa o qualcuno avrebbe voluto prendere
il suo posto nel nostro cuore o nella nostra mente.

         Ed è ormai consuetudine per molti e molti fra noi, grazie a Dio, pregare così, dire
così: "Sei tu, Signore, l'unico mio bene."

         Ora, nel desiderio di proseguire, progredire anzi progredire sempre meglio nel
Santo Viaggio, possiamo chiederci: "E' questo il modo più perfetto di amare Gesù
abbandonato, o possiamo trovarne un altro migliore?"

         Certamente il nostro amore per Lui sarebbe più grande ancora se non lo amassimo
soltanto quando il nostro comportamento "ideale" lo esige, come nei distacchi ad esempio, o
nelle più varie prove; o ancora nei prossimi che ce lo ricordano.
Ma sempre.

         Più perfetto sarebbe il nostro comportamento se vivessimo unicamente per Lui,
amandolo sempre.

         Ma Lui è sempre presente nella nostra vita?
         Certamente sì.
Sappiamo, infatti, che due sono gli atteggiamenti richiesti a noi cristiani e sottolineati dalla
nostra spiritualità: amare Dio, facendo la sua volontà, anche quando si è soli; e amare il
prossimo, quando siamo in contatto con fratelli e sorelle. E nell'uno e nell'altro caso è
richiesta la morte del nostro io.
Nel primo con lo spegnere la nostra volontà sempre riluttante a morire, per fare
perfettamente quella di Dio.

         Nell'altro, morendo a noi stessi per vivere la vita degli altri: quel prossimo a noi
tanto spesso vicino, come la persona a cui scrivo, o l'altra che servo nel negozio, o il bimbo
che accudisco a casa, o gli scolari ai quali insegno, o gli amici radunati in convegno cui parlo,
o altri che aggiorno. O vicino ancora nello squillo del telefono che mi chiama…

         Ma, proprio perché il fare la sua volontà e l'amare gli altri, chiede l'annientamento di
noi stessi, ecco che, così vivendo, amo Gesù abbandonato, annientatosi per amore nostro.

Come possiamo osservare perciò, è sempre, sempre possibile amare Gesù abbandonato;
sempre.

Lui c'è sempre.

         E' da settimane che, con grande gioia di tanti, ci siamo impegnati a vivere, giorno
dopo giorno, l'attimo presente. Ne siamo stati spinti dalla considerazione che questo modo
di fare era il più idoneo, non solo per chi s'appressa all'Altra Vita (tutti gli spirituali lo
consigliano), ma per tutti.

         Ed ecco, allora, un lungo elenco di - quelli che noi chiamiamo - "passa-parola",
comunicati via e-email a più persone del Movimento possibile, che aiutano a vivere così e
mettono in cuore il desiderio di continuare in tal modo, visti i tanti risultati positivi.

         "E' - dicono - la stampella sempre pronta per poter ben camminare". "E' - sempre
questo 'passa-parola' - la vitamina dello Spirito". "E' la prima cosa che vogliamo sapere
appena ci svegliamo al mattino." Dicono ancora: "Ci mantiene sempre in quota", ecc.

         Ora però abbiamo parlato di Gesù abbandonato, nostro tutto, e di volerlo amare
sempre. E questo ci sta molto a cuore se, dalla settimana di Pasqua, ci sentiamo spronati ad
amarlo come non è mai stato amato.

Come conciliare allora le due cose: amare Gesù abbandonato e vivere l'attimo presente?

E' facile: basta vivere il "passa-parola" nell'attimo presente come prima, sapendo che questo
è anche il modo migliore di amare Gesù abbandonato perché - l'abbiamo sperimentato - è
proprio vivendo il presente che amiamo la sua volontà e non la nostra, che amiamo il
prossimo e non noi stessi.

Anzi, sapendo che in questa maniera amiamo Gesù abbandonato, saremo portati a
migliorare ogni giorno il vivere la Parola. E ciò è ottimo e ciò è necessario perché - lo
sappiamo - "chi non va avanti, va indietro".
Conclusione: vivere sempre meglio la Parola nel presente, coscienti e contenti che con essa
amiamo veramente Gesù abbandonato.

E do un esempio.

Noi, per esempio, oggi dobbiamo "seriamente mettere in rilievo la Parola di Dio",
seriamente: noi mettiamola e con ciò mettiamo in rilievo il nostro amore a Gesù
abbandonato.

Insomma: vivere quello che vi mando, giorno per giorno, il "passa-parola", e con ciò state
certi, e siamo contenti, che amiamo veramente Gesù abbandonato.

Ecco, vi ho detto tutto.$doc1803$, 'drive_import', '01803-WEB-2002-02-21-vivere-la-parola-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1803)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1804, 'ITA', $doc1804$Castel Gandolfo, 25 aprile 2002

I fioretti

Carissimi,

         con la collaborazione di molte e molte persone del Movimento, alcuni di noi, qui al
Centro, stiamo concludendo un periodo un po' particolare, uno dei belli, vorrei dire, della
nostra vita.

         Siamo stati impegnati a comporre un libretto commissionatoci dalla casa editrice
San Paolo, che ha ampia diffusione, e doveva contenere quelli che chiamano: "I fioretti".
Si tratta di piccoli, o meno piccoli fatti della nostra vita evangelica che, perché vissuti in
rapporto con Dio, portano nel centro della storia una preziosissima perla: l'intervento
proprio di Dio, del suo amore.

         E' stato un lavoro intenso, perché doveva essere pronto dopo pochi giorni.
         Noi leggevamo e rileggevamo tutti gli episodi, o semplici fatterelli, arrivatici: una
miniera, uno spettacolo, un firmamento di stelle piovute dal cielo, che ci hanno fatto più
volte affermare con convinzione: "Quant'è bello il nostro Movimento! Quant'è meraviglioso
il nostro popolo! Annuncia veramente al mondo la Buona Nuova... e, con la vita!
         Voi, che li avete mandati, avete dimostrato con evidenza lampante che Dio c'è,
perché, al vostro dare, Lui ha dato; al vostro chiedere ha risposto; ha consolato il vostro e
l'altrui pianto; vi ha rivestiti come i gigli del campo; vi mancava tutto e vi ha riempito di
beni; avete chiesto l'impossibile ed è arrivato; avete gettato in Lui le vostre preoccupazioni
e ve le ha risolte ad una ad una; Egli ha pensato a voi ben più che ai piccoli passeri; l'avete
invocato ed eccolo al vostro fianco; avete avuto fede in Lui più che in ogni altra cosa al
mondo, ed Egli è stato presente in ogni circostanza della vostra vita.
         Egli c'era, c'è sempre, immancabilmente. Interviene magari subito o dopo qualche
tempo. Ma lo fa. I vostri "fioretti" che sono piovuti a Rocca, invadendo le nostre scrivanie, lo
hanno gridato. A riprova, fra il resto, che le nuove realtà ecclesiali, i Movimenti come il
nostro, sono un ritorno alla radicalità del Vangelo.
E dal cuore è sgorgato un grazie a Dio senza fine per questa nostra Opera, dove chi è più
semplice e povero è più suo, più inzuppato di Vangelo.
         Una cosa grande, dunque, questa rievangelizzazione, come Gesù la desidera, anche
se, fra le molte considerazioni che stiamo facendo, appare chiaro che, se il Vangelo vissuto
dona il cielo in terra (quel centuplo quanto è vero!), chiede anche del nostro.

         Non si può, infatti, vivere sul serio la Parola di Dio senza fatica. Quando la si vuole
seguire, quando la si vuole abbracciare, all'inizio costa, per poi lasciare la gioia piena
nell'anima. Ma costa.

         E qui ricordo Madre Teresa di Calcutta, la quale affermava che, se l'amore al
prossimo non fa male, non è amore.

         Io vorrei estendere quest'affermazione anche all'amore verso Dio, che è fare la sua
volontà.

         Sì, se questi due amori - che sono uno - non costano, non fanno male, non sono
amore.

         Per questo nel praticarli è di grandissimo aiuto, oggi, il nostro modo di vivere il
presente, perché nel presente si ha una grazia in più, quella attuale, che addolcisce ogni
sforzo.

         Non per niente continuano ad arrivare da più parti definizioni entusiaste al nostro
passa-parola: "E' il vademecum alla santità; è alimento per l'anima; è rugiada divina;
metodo giornaliero tonificante, ci fa trovare risposta ad ogni domanda, ci dà quella serenità
che, per la troppa attività, rischieremmo di perdere; è la soluzione in ogni situazione; è
pace".

         E allora, durante il prossimo mese, continuiamo a vivere il presente con tutto
l'amore.

         Se, col farlo - come abbiamo visto nel precedente Collegamento -, amiamo sempre
Gesù abbandonato, ora stiamo certi che, poiché amando Gesù abbandonato è presente lo
Spirito Santo, Egli stesso ci farà ricordare, nelle varie circostanze della nostra vita, parole,
promesse, comandi, parabole di Gesù che potranno illuminarle, queste circostanze, e
trasformarle in fatterelli evangelici.

         Succederà, allora, che il nostro Santo Viaggio si arricchirà di un susseguirsi di
incantevoli "fioretti", manifestazioni di Dio al mondo.$doc1804$, 'drive_import', '01804-WEB-2002-04-25-i-fioretti-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1804)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1805, 'ITA', $doc1805$Castel Gandolfo, 16 maggio 2002
Una piccola - grande idea

Carissime,

         eccoci reduci da Rimini, da pochi giorni, col cuore colmo di gratitudine per quanto è
successo, per il legame spirituale rinsaldato fra tutti noi sparsi nel mondo, eppure presenti
per tre ore in quel palazzo dei congressi che ha visto la gloria di Dio.

         Da più parti, in quest'ultimo tempo, il nostro Movimento ed in particolare la sua
diramazione politica era stata invitata autorevolmente ad aver maggior "visibilità" perché
gli uomini, vedendo le nostre opere, rendessero gloria a Dio. Ed anche perché la luce andava
messa sul moggio e la città sul monte. E così è stato. E i frutti sono stati abbondantissimi.

         La santa Messa della domenica scorsa ha avuto un'unica intenzione: il
ringraziamento...
Ma tutto ciò era di ieri.

         Oggi vediamo - è questo il perché del nostro Collegamento - come proseguire nel
Santo Viaggio.

Siamo alla fine di giugno, sempre concentrati da mesi ormai sull'attimo presente, illuminato
dal quotidiano "passa-parola", definito "geniale" da una personalità ecclesiastica che lo vive
con noi. Perché sempre nuovo, vi ha visto, forse, un invito originale ad adempiere, con
sempre rinnovato slancio, la volontà di Dio. E ancora c'è chi mi scrive magnificando questa
pratica, che trova utile alla sua vita spirituale.

         Eppure, perché siamo su questa terra, si fa l'abitudine a tutto, tutto poco a poco
perde attrattiva, non gli si dà l'importanza dei primi giorni, e non si vive con la gioia e la
pienezza di allora.

         Nel caso nostro non sempre si vive con radicalità nell'attimo presente la volontà di
Dio. Fanno capolino, di tanto in tanto, e poi sempre più, desideri, preferenze della nostra
volontà, con danno - ne siamo convinti - della nostra perfezione. Danno riconosciuto non
solo da noi cristiani, ma anche da altri come, ad esempio, dai buddisti che, per raggiungere
la felicità, imparano a spegnere tutti i desideri umani. Il loro simbolo, infatti, è la candela
spenta.
         Non è la prima volta che ne parliamo ed anche oggi ripetiamo che - a differenza di
quei fedeli orientali - il nostro simbolo sarebbe la candela accesa. Infatti lo Spirito Santo ha
infuso nei nostri cuori il fuoco dell'amore soprannaturale che, mantenuto vivo, fa fiorire in
noi desideri celesti, annientando, spegnendo, di conseguenza, quelli terreni, troppo umani.

         Ma che fare, se questi ora cominciano a rispuntare? E, se s'affievolisse in noi l'amore
alla volontà di Dio dell'attimo presente, come rimetterci in riga? Una sterzatina al nostro io
non starebbe male. Siamo sempre poveri peccatori bisognosi di correzione, di qualche aiuto
un po' forte, magari piccolo, forse banale, ma che ci serva.

         Lo dicono, del resto, i santi.

         Un giorno m'è stato regalato un libro illustrato con immagini antiche, belle e
coloratissime, sulla vita di Chiara d'Assisi. Riportavano momenti, episodi importanti della
santa, dipinta con aria ingenua, ma dolcissima e attraente. Non li ricordo tutti. Vi era
senz'altro il suo incontro con san Francesco e la sua donazione a Dio alla Porziuncola; la vita
carica di carità con le sorelle; l'altolà, con l'ostensorio in mano, ai saraceni invasori; la visita
del Papa a San Damiano col miracolo della croce sui pani; l'edificantissima morte di Chiara
fra il pianto angosciato delle sue sorelle: avvenimenti in genere celebri, riprodotti da un
artista di valore.

E lì, fra questi, uno che mi ha sorpreso: la santa che conta i suoi atti d'amore del giorno con
pietruzze raccolte in un vaso.

"Come? mi sono detta. Non è Chiara d'Assisi l'anima dagli immensi orizzonti, faro di luce di
Sapienza per il mondo di allora? Non è quella creatura 'praeclara', chiarissima, che nessuna
parola con tutti gli aggettivi di luce pensabili, riuscivano a descrivere?" Eppure eccola lì ad
aiutarsi con sassolini per verificare se quel giorno ha amato più del giorno precedente; se è
cresciuta così nell'amore di Dio e del prossimo.

         Una sorpresa per me, ma anche un incoraggiamento: quel dipinto ha dato
spiegazione e valore all'esigenza che, di tanto in tanto, nel mio focolare avvertiamo: contare
con qualche mezzo, in qualche modo, i nostri atti d'amore a Dio, alla sua volontà, al
prossimo, né più né meno come fanno i gen 4.

         Carissime, il titolo del presente pensiero è: "Una piccola - grande idea". Ora lo capite.

         Perché durante il mese di luglio - e almeno in quel mese - non facciamo anche noi
come santa Chiara d'Assisi? Perché non trovare il modo di contare le volte al giorno in cui
vivere il presente è stata una conquista per noi, una morte al nostro io? E quindi un atto
d'amore a Gesù abbandonato?

         Non potrebbe essere questo un aiuto per mantenere la nostra candela sempre
accesa? Una maniera per poi, i mesi seguenti, tornare a vivere con semplicità i nostri attimi
alla luce del solo passa-parola?

         Io ne sono convinta. Per questo comincio e spero di non essere la sola.$doc1805$, 'drive_import', '01805-WEB-2002-05-16-una-piccola-grande-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1805)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1806, 'ITA', $doc1806$Castel Gandolfo, 27 giugno 2002
Come progredire?
Carissimi,

         anzitutto auguri a tutti voi, tutti noi dell'Opera di Maria sparsi nel mondo, per la
festa che oggi ricorre in onore di Maria Regina, Madre, Capo, Presidente, Regina del nostro
Movimento e dei suoi singoli cuori. Onoriamola oggi in modo tutto speciale, in questa felice
giornata, e preghiamola uniti per ottenere, come abbiamo promesso al Santo Padre il giorno
di santa Chiara, la pace in Terra Santa.

         Ed ora il pensiero che sarebbe intitolato così: "Come progredire?"
         Spero che l'estate trascorsa fin qui, pur burrascosa in varie parti del mondo, vi abbia
permesso di riposare e riprendere quelle forze necessarie alla nostra vita dedita alle cose
terrene, pur soprannaturalizzate dall'amore divino: alla famiglia, al lavoro, allo studio, allo
sport, ecc., e a quelle celesti: come la rievangelizzazione in noi e attorno a noi, a cui siamo
tutti chiamati.

         Intanto, da molti plichi di fax pervenutimi in quest'ultimo tempo, ho potuto
costatare l'entusiasmo di molti e molte nel ripetere, giorno dopo giorno, il gesto di santa
Chiara d'Assisi, che conta gli atti d'amore ed ho gioito della fervida fantasia nello scegliere i
metodi più vari. Il Cielo avrà certamente gioito nel vederci tornare bambini.

         E adesso, e in seguito finché vivremo, dovremo continuare ad amare, impegnati
come siamo su questa terra nella prova della vita, che deciderà dell'Altra definitiva.
Come?
Vivendo nel presente che non vogliamo abbandonare più.

E' impressionante quanto dice san Giovanni della Croce di quelle persone che hanno la
volontà più conforme a quella del loro Creatore, e perciò vivono con maggior perfezione il
presente. Afferma che Dio si dà pienamente a loro, tanto da trasformarle
soprannaturalmente in Sé.

         Sarà così di qualcuno di noi? Volesse il Cielo!

         Comunque, se in molti dobbiamo costatare ancora vuoti, mancanze, attaccamenti
alla propria volontà, nonostante i mezzi usati, non è il caso di avvilirci e di temere. Vale
anche in questi casi la Parola di vita del mese: "Coraggio, sono io, non abbiate paura" (Mt
14,24). Il volto di Gesù abbandonato è anche dietro le nostre imperfezioni. Basta saperlo
riconoscere ed abbracciarlo e Lui risorto risplenderà in noi e continuerà ad aiutarci.

         In che maniera? Ad esempio, attraverso i sempre vari carismi che arrivano nella
Chiesa, i quali, se da una parte sono stati e sono sempre atti a suscitare cristiani autentici,
evangelici, ognuno è anche un correttivo, per così dire, della vita cristiana in qualche sua
debolezza, in qualche suo cedimento, in qualche sua necessità.

Il nostro, ad esempio, oltre che generare unità, è utile a rimediare alle disunità d'ogni
genere. Così il carisma francescano della povertà, se era stato chiamato a riedificare la
Chiesa, lo ha fatto anche fungendo da correttivo all'avidità di ricchezze dilagante nel suo
tempo, e lo può fare ai nostri tempi come rimedio al consumismo, ad esempio.

Così è. E allora possiamo chiederci: in questo momento, se sentiamo il bisogno di alcunché
che ci distacchi da tutto: da cose, persone e da noi stessi, per compiere bene nel presente la
sola volontà di Dio, a chi ricorrere?

         Senz'altro alla nostra stessa spiritualità, che ci propone l'amore a Gesù abbandonato,
ridottosi a niente.

         Ma anche – e perché no? – al carisma proprio di san Giovanni della Croce, il santo del
distacco da tutto, del "nada".

         Egli dice: "Come è necessario che la terra, perché produca, venga lavorata, altrimenti
non sarebbe che erbacce, così conviene che gli attaccamenti siano mortificati perché l'anima
progredisca".

         Ne abbiamo parlato altre volte ed è sempre venuto in grande evidenza qual è per noi
il miglior modo di annientarci, di staccarci da ogni cosa: non pensare a noi stessi, nemmeno
ai nostri attaccamenti, nemmeno alla nostra perfezione, ma pensare agli altri, al prossimo.

         E' questa la nostra tipica strada per arrivare a Dio. Non possiamo prescinderne. Non
lo possiamo perché così è scritto nei primi (notate: "i primi!") appunti che conserviamo,
riguardanti la nostra chiamata. Dicono: "L'anima (nostra) compirà il suo Ideale ut omnes
unum sint quando vivrà il presente al servizio del prossimo."

         E allora cerchiamo, d'ora in poi, e lungo il mese di settembre, di vivere nel
presente soprattutto l'amore al prossimo attraverso tutto quanto facciamo,
servendolo in tutte le maniere, direttamente e indirettamente.

         Sarà l'occasione per progredire veramente, per fare grandi passi in avanti, a gloria di
Dio.$doc1806$, 'drive_import', '01806-WEB-2002-06-27-come-progredire-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1806)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1807, 'ITA', $doc1807$Mollens, 22 agosto 2002

Il messaggio del Papa

Carissimi e carissime, sparsi in tutto il mondo e presenti a questo Collegamento, vi annuncio
una grande gioia!

         E' quella che ieri, mercoledì 16 c.m., ha invaso la nostra Assemblea a Castel
Gandolfo, alzando l'atmosfera spirituale al massimo grado, quando abbiamo tirato le fila
d'una giornata resa straordinaria da una straordinaria udienza col Santo Padre Giovanni
Paolo II.

         Egli ha, dapprima, salutato, fra gli altri, il nostro gruppo, ed ha mandato la sua
benedizione a tutti noi, tutti noi (s'avvertiva nella sua voce l'universalità del suo amore),
benedizione che ho ora la gioia di trasmettervi perché - così è l'intento del Papa - la possiate
comunicare a chiunque vive in qualche modo il nostro Ideale attorno a voi.

         Poi ha ripetuto questa benedizione attraverso un messaggio che mi ha consegnato
quando ho potuto salutarlo personalmente con don Foresi ed Eli.

         E' un messaggio assai particolare dove il cuore del Papa si apre a noi, suoi figli, con
una fiducia eccezionale, affidandoci ciò che in questi momenti gli sta più a cuore.

         Si tratta di quello strumento di preghiera che ha sempre privilegiato perché, come
una divina fionda nelle sue mani, gli ha permesso persino di concorrere a sradicare nella sua
vita, durante la sua vita, senza alcuna altra arma umana, giganteschi pericoli della Chiesa e
del mondo: il rosario.

         Ma andiamo per ordine.

         Il messaggio si suddivide in quattro parti. Ognuna importantissima, ricca, fra il resto,
di direttive che non possiamo non fare subito nostre.

         Nella prima, rivolgendosi "con gioia ed affetto" - dice - il suo "cordiale saluto" alla
nostra Assemblea, ringrazia degli auguri fattigli per l'inizio del suo XXV anno di pontificato.
Afferma di sentire sempre la nostra vicinanza e di aver ammirato quanto facciamo per la
Chiesa e per il mondo. Dice di apprezzare il "valido contributo" dei nostri quattro dialoghi,
che enumera come possibilità di perseguire il fine propostoci: ut omnes unum sint.

         Nella seconda parte, ripetendo la sua stima e la sua riconoscenza per quanto
facciamo, lo si sente soddisfatto per un nostro evangelico modo d'agire quando dice: "Voi
siete ben consapevoli (...) di come le azioni concrete debbano essere precedute ed animate
da una robusta spiritualità di comunione".

Poi continua menzionando ad una ad una le nostre diramazioni come luoghi in cui questo si
fa. E ancora non smette di ringraziare e chiede di continuare dappertutto a testimoniare,
con la nostra vita, Dio Amore.

         Nella terza parte, ed è la più singolare ed impegnativa per noi, ci incoraggia
dapprima ad approfondire il nostro particolare legame spirituale con Maria, "la Madre
dell'unità nell'amore", a cui la nostra Opera è intitolata.

         Poi, manifestando tutta la sua fiducia nel nostro Movimento, ci affida un compito
particolare, un po' come ha fatto nella vigilia delle Pentecoste 1998, quando ci ha chiesto di
lavorare per la comunione fra i Movimenti.

         Nel contesto della promulgazione d'una sua nuova Lettera apostolica - di cui, penso,
siate tutti al corrente, speriamo -, sulla contemplazione e l'assimilazione del mistero di Gesù
attraverso la recita del rosario, da lui completato e splendidamente integrato con "misteri di
luce", ci dice testualmente: "In questa singolare ricorrenza, vorrei consegnare idealmente ai
Focolarini la preghiera del santo rosario che ho voluto riproporre a tutta la Chiesa. Sono
certo che la vostra devozione alla Vergine Santa vi aiuterà a dare il necessario rilievo
all'iniziativa di un anno dedicato appunto al rosario", il prossimo.

         Nella quarta parte non può non accennare a ciò che è per noi il punto di forza e di
garanzia di positivi risultati in ogni nostra impresa, e parla di Gesù abbandonato,
collegandolo - come non ha mai fatto così - con l'unità, Gesù abbandonato, nostro unico
bene, chiave, porta aperta all'unità.

         E conclude, dicendosi certo del costante ricordo che abbiamo per lui, assicurando la
sua preghiera per noi, auspicando ogni successo e ancora benedicendo ben volentieri - così
dice - "ciascuno di voi e l'intero Movimento".

         Carissimi, sono subito nate in cuor nostro - come potete immaginare - diverse
entusiasmanti iniziative per adempiere questa precisa volontà di Dio espressaci dal Papa. E
perciò, aiutati anche dai nostri fratelli delle varie Chiese che, seppure non praticano il
rosario, amano però la Madre di Gesù, e sostenuti - perché no! - dall'amore sempre vivo di
quegli altri nostri fratelli e sorelle a cui ci lega la "Regola d'oro", partiamo subito.
Interesseremo, ad esempio, la nostra stampa in tutte le sue edizioni; organizzeremo nel
nuovo anno, con i diversi Movimenti e con quant'altri lo vogliano nella Chiesa, un Convegno
internazionale da ripetersi poi nelle zone, con la presenza di persone particolarmente
capaci di temi spirituali, nostre e non, con studiosi della Scuola Abbà ed esperti in
Mariologia e tutto quanto vi è connesso, con esperienze nostre vive.
         Per questo posporremo i vari nostri convegni, che stavamo programmando, nel
2004, sicuri che dare un anno a Maria sarà per la nostra Opera porre per i successivi anni
basi sicure a qualsiasi altra attività della sua Opera.

         Maria, dove è apparsa nel mondo, lo ha fatto spesso col rosario in mano.
         Siamo ben lieti di offrire un anno della sua Opera per svelare al mondo le ricchezze
della meravigliosa sintesi del Vangelo che esso propone alla nostra meditazione e, quale
specchio di Gesù, alla nostra imitazione.

         So di trovare in voi fedelissimi figli di una così grande Madre.
Che anche tutti noi possiamo ripetere durante il prossimo anno il motto del Santo Padre:
Totus tuus, tota tua. Sono tutto tuo, tutta tua, siamo tutti tuoi.

                                                                                                   Chiara

E adesso le ultimissime!
Stamattina ci sono state le elezioni: com'era naturale, con l'esultanza di tutti, Chiara è
sempre la nostra presidente!$doc1807$, 'drive_import', '01807-WEB-2002-08-22-il-messaggio-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1807)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1808, 'ITA', $doc1808$Castel Gandolfo, 17 ottobre 2002

Il Risorto

Carissimi e carissime,

         eccoci al nuovo Collegamento del mese di novembre. Il pensiero attuale verte su un
preciso particolare della vita cristiana. Ma, poiché fanno parte del nostro Movimento fedeli
di altre religioni del mondo o persone di culture diverse, desidero premettere un
suggerimento e un consiglio proprio per loro.

         Come sapete, noi siamo tutti un'unica Opera, dove deve trionfare tra noi la "regola
d'oro" presente nelle nostre Scritture ("Fai agli altri ciò che vorresti fosse fatto a te" oppure
"Non fare agli altri ciò che non vorresti fosse fatto a te"), regola che richiede di amarci, e,
perciò, di conoscerci sempre meglio. Per questo approfittate tutti di quanto dirò adesso. Si
tratta di quella necessaria inculturazione senza la quale non è possibile costruire brani di
fratellanza universale, come, in altre occasioni, i cristiani, fra noi, faranno con voi.

         E passiamo, dunque, al pensiero. Si intitola: IL RISORTO.

         L'ho già comunicato a due gruppi di persone e, recentemente, all'Assemblea, ma
desidero ripeterlo per quanti altri, collegati, non lo conoscono, sperando che sia di
vantaggio spirituale per molti. Riporta un'idea, un'intuizione, forse una luce che ho ricevuto
qualche tempo fa, una delle tante relativa, penso, al nostro carisma. E', forse, una delle più
belle; senz'altro una di quelle che personalmente mi ha toccato di più. Si può intitolare:
"Conferma della fede."

         Una circostanza provvidenziale mi ha portato ad approfondire la realtà di Gesù che,
dopo l'abbandono e la morte in croce, è risorto.

Non solo: ho avuto l'occasione di meditare intensamente con la mente e con il cuore molti
particolari della risurrezione di Gesù e della sua vita dopo la risurrezione. E sono rimasta
sbalordita (è la parola esatta) dalla maestosità, dalla grandiosità che da questo avvenimento
divino emanava: dall'unicità del Risorto, da questo fatto soprannaturale che, per quanto so,
è unico al mondo.

Per cui non posso non soffermarmi questa volta a metterlo ancora in rilievo.

         La risurrezione di Gesù è ciò che maggiormente caratterizza il cristianesimo, ciò che
distingue il suo Fondatore, Gesù. Il fatto che è risorto. Risorto da morte! Ma non nella
maniera di altri risorti, come Lazzaro ad esempio, che poi, a suo tempo, è morto. Gesù è
risorto per non morire mai più, per continuare a vivere, anche come uomo, in Paradiso, nel
cuore della Trinità. E l'hanno visto in 500 persone! E non era certo un fantasma. Era lui,
proprio lui: "Metti qua il tuo dito e guarda le mie mani; stendi la tua mano, e mettila nel mio
costato" (Gv 20,27), ha detto a Tommaso.

Ed ha mangiato con i suoi ed ha parlato ai suoi ed è rimasto con loro ben 40 giorni... Aveva
rinunciato alla sua infinita grandezza per amore nostro e s'era fatto piccolo, uomo fra gli
uomini, come uno di noi, così piccoli che da un aereo non ci possono neppure vedere.

Ma, poiché è risorto, ha rotto, ha superato ogni legge della natura, del cosmo intero, e s'è
mostrato, con questo, più grande di tutto ciò che è, di tutto ciò che ha creato, di tutto ciò che
si può pensare. Sicché anche noi, al solo intuire questa verità, non possiamo non vederlo
Dio, non possiamo non fare come Tommaso e, inginocchiati di fronte a Lui, adoranti,
confessare e dirgli col cuore in mano: "Mio Signore e mio Dio". Anche se non la saprò mai
descrivere bene, è questo l'effetto che ha fatto in me la luce del Risorto.

Certamente, lo sapevo; sicuramente lo credevo, e come! Ma qui l'ho come visto. Qui la mia
fede è diventata chiarezza, certezza, ragionevole, vorrei dire.

E ho visto con altri occhi quello che ha fatto in quei nuovi favolosi giorni terreni.

         Dopo la discesa dal Cielo di un angelo che ha ribaltato la pietra del suo sepolcro e lo
ha annunciato, ecco il Risorto apparire per primo alla Maddalena, già peccatrice, perché egli
aveva preso carne per i peccatori. Eccolo sulla via di Emmaus, grande e immenso com'era,
farsi il primo esegeta a spiegare ai due discepoli la Scrittura. Eccolo come fondatore della
sua Chiesa, imporre le mani ai suoi discepoli, per dar loro lo Spirito Santo; eccolo dire
straordinarie parole a Pietro, che ha posto a capo della sua Chiesa. Eccolo mandare i
discepoli nel mondo ad annunziare il Vangelo, il nuovo Regno da lui fondato, in nome della
Santissima Trinità da cui era disceso quaggiù e che nell'ascensione seguente avrebbe
raggiunto in anima e corpo e divinità. Tutte cose conosciute da me, ma ora nuove perché
vere in assoluto per la fede e per la ragione.

         E perché Risorto, ecco anche le sue parole detteci in precedenza, prima della sua
morte, acquistare una luminosità unica, esprimere verità incontrastabili. E prime fra tutte
quelle in cui annuncia anche la nostra risurrezione.

Lo sapevo e lo credevo perché sono cristiana. Ma ora sono doppiamente certa: risorgerò,
risorgeremo.

         Potrò dire allora ai miei molti, ai nostri molti amici partiti per l'Aldilà e, forse,
pensati da noi inconsciamente perduti, non tanto: addio, ma ARRIVEDERCI, ARRIVEDERCI
per non lasciarci mai più. Perché fin qui arriva l'amore di Dio per noi.

         Non so se ho espresso, almeno un po', la grazia, la luce che ho ricevuto: una
conferma della fede.

         Che il Signore faccia in modo che l'abbia potuta comunicare a tutti voi che mi avete
ascoltato, come conferma della vostra fede.
         Intanto in questo prossimo mese continuiamo a nutrirci del passaparola. Oggi dice:
"Consegnarsi alla volontà di Dio dell'attimo presente" per essere avvolti dalla grazia attuale
che dà maggior luce sempre alla nostra fede.$doc1808$, 'drive_import', '01808-WEB-2002-10-17-il-risorto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1808)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1809, 'ITA', $doc1809$Castel Gandolfo, 14 novembre 2002

Miniera d'oro

Carissime e carissimi,

         è da qualche tempo che sono tornata dalla Spagna, ma avverto di non aver esaurito
quanto dovevo comunicarvi sulla mia esperienza spirituale in quella terra di santi. Ne ho
parlato a qualche incontro, ma non a tutti voi.

         Per questo desidero offrirvi, attraverso il presente Collegamento, quel qualcosa di
essenziale che io ho portato con me, tornando al Centro.

         Incontrando a Manresa Ignazio, ad Avila Teresa, a Segovia Giovanni della Croce, ho
trovato dei “giganti” della santità, che hanno raggiunto gloriosamente la mèta, camminando
per vie spirituali, individuali, personali.

         Gli episodi straordinari della loro vita, le parole sante da loro dette, quelle divine
udite, i vari ambienti che li ricordano in uno o in un altro atteggiamento del loro essere, e
profumano ancora dell'ardentissimo amore per Dio di queste anime elette, hanno avuto su
di me un notevole, forte impatto; vi hanno scavato un insaziabile desiderio: quello di
approfondire, di sviluppare al massimo l'aspetto individuale, che prevede anche la nostra
“spiritualità dell'unità”, che è comunitaria e personale insieme.

         Ho avvertito dentro di me l'urgenza, la necessità e la bellezza di rivedere i momenti
sacri che la volontà di Dio su di noi ha riservato a questo scopo, e di adempiere, con
moltiplicato impegno, quegli obblighi che concretizzano il nostro rapporto con Dio. Obblighi
diversi secondo le nostre vocazioni, ma che per noi focolarini sono, ad esempio, le preghiere
in diverse ore della giornata, la meditazione quotidiana, la recita del rosario, l'assistere alla
santa Messa con la partecipazione all'Eucaristia, la visita a Gesù nel Santissimo Sacramento,
l'esame di coscienza e gli “strumenti” della nostra santità. Doveri questi, in genere, di ogni
giorno. E poi la confessione ogni 15 giorni, il ritiro mensile e gli esercizi spirituali una volta
all'anno.

         Si tratta di quelle pratiche che noi definiamo il “vestito” che indossiamo, premessa
per poter poi uscire ad amare i fratelli. Sì: il vestito! Ma di quale vestito si tratta? E’ il vestito
d’oro dell’unione con Dio. E' e deve essere oro, oro, oro. E può diventare miniera d'oro se si
accresce amando fuori, per Dio, i fratelli.
         Ho cominciato a vivere così, a cercare di perfezionare, quasi cesellare quei momenti.
E quale il primo risultato?

Forse perché: “A chi ha sarà dato”, la spinta, il giorno dopo, a farlo ancora meglio, sempre
meglio, quasi non fosse mai fatto abbastanza bene. Ma l'effetto più forte, straordinario, direi,
di tutto questo impegno è stato, paradossalmente, il vedere con maggiore chiarezza e
precisione e il sentirmi attratta verso quelle parole della Scrittura, nel Nuovo Testamento
che meglio si addicono all'aspetto tipico, soprattutto comunitario, della nostra spiritualità e
ne permettono l'attuazione. Come il “Che tutti siano una cosa sola” (cf Gv 17,21), e qui
occorrono i fratelli; come l’“Amatevi a vicenda come io vi ho amato” (cf Gv 15,12), e qui
occorre il fratello; come “Prima di tutto abbiate tra voi la mutua carità” (cf 1 Pt 4,8). Parole
che riguardano, con me, anche i miei fratelli. Parole che, se vanno adempiute dopo aver
indossato il “vestito” suddetto, lo devono pure - in certo modo, ma senz'altro - per un
intreccio divino, precedere perché la nostra vita sia pienamente, cristianamente realizzata.

         Non occorre forse lasciare l’offerta all’altare - una delle nostre pratiche - per
riconciliarsi col fratello quando ce ne fosse bisogno?

         Ma non è solo così. Ho avvertito ancora l’attrattiva, l’importanza per noi di altre
parole della Scrittura che raggiungono senz’altro il necessario cristiano rinnegamento,
l’annientamento di sé, così ammirato, ad esempio, nei santi spagnoli, annientamento però,
per noi, non tanto perseguito direttamente, ma attraverso quella che noi chiamiamo, per
esempio, la visibilità del nostro operare a gloria di Dio. Parole come: “Voi siete la luce del
mondo; (…) risplenda la vostra luce davanti agli uomini, perché vedano le vostre opere
buone e rendano gloria al Padre vostro che è nei cieli” (cf Mt 5,14-16). “Gloria al Padre
vostro che è nei cieli” e non a noi; ed ecco ancora il rinnegamento di sé, di noi.

Ho sentito l'attrattiva ancora di altre Parole che chiedono di mostrare al mondo, non tanto
le rinunce, che il Vangelo chiede a tutti i cristiani, quanto la ricchezza e la bellezza dei doni
di Dio che, perché Padre, ci dà. Come la Parola riguardante il “centuplo”, di cui parla il
Vangelo a chi tutto lascia (ecco la povertà a base, ecco il distacco); o quella che dice:
“Osservate come crescono i gigli del campo: non lavorano e non filano. Eppure io vi dico che
neanche Salomone, con tutta la sua gloria, vestiva come uno di loro. Ora se Dio veste così
l’erba del campo, che oggi c’è e domani verrà gettata nel forno, non farà assai di più per
voi?” (Mt 6,28-30). Sempre se abbiamo fede in lui, rinunciando - ecco l'annientamento - a
pensarci troppo noi.

         Avremo da approfondire in seguito questi aspetti della vita cristiana così come Dio li
vuole vissuti da noi oggi, aspetti che sembra possano mostrare un volto nuovo della Chiesa:
quello del Risorto.

         Noi, nel prossimo mese, accontentiamoci intanto di attuare meglio le nostre
pratiche, le nostre preghiere; di sistemare per benino il nostro “vestito” e che sia d'oro,
d'oro.$doc1809$, 'drive_import', '01809-WEB-2002-11-14-miniera-doro-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1809)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1810, 'ITA', $doc1810$Castel Gandolfo, 26 dicembre 2002

2003

Per essere una piccola Maria

Carissimi,

         questa volta, come ho fatto ancora del resto, desidero comunicarvi una mia
esperienza piccola, personale, che ha, però, inciso nella mia anima e spero utile anche a voi.

         Il Signore ci ha dato di vivere, in questi ultimi mesi, momenti meravigliosi. Ginevra,
Barcellona-Madrid, Mumbai sono città che sollevano ancora nelle nostre anime stupore e
riconoscenza ed hanno lasciato un segno in noi e in tutto il Movimento.

         Eppure ciò che deve dominare nel nostro cuore, sempre, è una realtà che vale più di
qualsiasi altra cosa e che dobbiamo mantenere a base di ogni pur straordinaria esperienza.

         Ho preso in mano, questi giorni, un libro, che m'è stato regalato, forse anche da voi
conosciuto. E' intitolato: Il segreto di Madre Teresa di Calcutta, ovviamente. Lo apro a
metà, là dove parla di "mistica della carità". Leggo questo capitolo ed altri. Mi immergo con
grande interesse in quelle pagine: tutto ciò che riguarda questa prossima santa, mi interessa
personalmente: è stata, per anni, una mia preziosissima amica.

         Mi viene in luce, lampante, la radicalità estrema della sua vita, della sua vocazione
totalitaria, che impressiona, e quasi spaventa, ma, soprattutto, mi spinge ad imitarla in quel
tipico impegno, radicale e totalitario, che Dio chiede a me. Ogni carisma, infatti, è un
meraviglioso fiore, unico, irripetibile, diverso dagli altri come, del resto, pensava Madre
Teresa. Quando avevamo modo d'incontrarci mi ripeteva: "Quello che io faccio, tu non lo
puoi fare. Quello che tu fai, io non lo posso fare".

         Mossa da questa convinzione, prendo in mano il nostro Statuto convinta che avrei
trovato lì la misura ed il tipo di radicalità di vita che il Signore domanda a me. Apro e subito,
alla prima pagina, ho un piccolo choc spirituale, come per una scoperta del momento. (E son
quasi 60 anni che lo conosco!) Si tratta della "norma delle norme, la premessa d'ogni altra
regola" della mia e della nostra vita: generare – così si esprimeva Papa Paolo – e mantenere,
prima e innanzitutto, anche nelle grandi imprese, anche negli impegni straordinari, anche
nei successi per il Regno, Gesù fra noi col vicendevole amore.

         Perché, capisco subito, è questo il mio e il nostro più importante compito, specie
oggi: essere nella Chiesa una piccola Maria, "una sua presenza sulla terra, quasi una sua
continuazione" da sola e con tutta l'Opera; essere un’altra Maria che offre Gesù al mondo.
         Propongo subito di vivere la norma intanto nel mio focolare e con chi mi sta più
vicino. Ma, lo sappiamo: "Chi è senza peccato scagli la prima pietra" (Gv 8,7). Ed anche a
casa nostra non è sempre tutto perfetto: qualche parola in più, di me o di altre, qualche
silenzio di troppo, qualche giudizio avventato, qualche piccolo attaccamento, qualche
sofferenza mal sopportata, che rendono senz'altro scomodo Gesù fra noi, se non ne
impediscono la presenza.

         Comprendo che devo essere io, per prima, a farGli posto, tutto appianando, tutto
colmando, tutto condendo con la massima carità; tutto, nelle altre e in me, sopportando,
parola da noi, in genere, non usata, ma molto consigliata dall’Apostolo Paolo.

         Sopportare è una carità non certo qualunque. E’ una carità speciale, la quintessenza
della carità.

         Comincio. E non va male, anzi cammina!

         Altre volte avevo invitato subito le mie compagne a fare altrettanto. Ora no. Sento il
dovere di fare prima tutta la mia parte ed ha effetto. E inoltre mi riempie il cuore di felicità,
forse perché, in questo modo, Lui riappare presente e rimane. Più tardi lo dirò, ma
continuando a sentire il dovere di proseguire, come fossi sola, a comportarmi così.

         Ed è al colmo la mia gioia quando mi sovvengono le parole di Gesù: "Misericordia io
voglio e non sacrificio" (Mt 9,13). Misericordia! Ecco la carità sopraffina che ci è domandata
e vale di più del sacrificio, perché il più bel sacrificio è quest’amore che sa anche sopportare,
che sa, all’occorrenza, perdonare e dimenticare.

         Per essere delle piccole Maria, per assicurare Gesù al mondo, occorre vivere la
“premessa di ogni altra regola”, in quella mutua continua carità che fiorisce in misericordia.

         E’ questa la radicalità, è questa la totalitarietà chiesta alla nostra vita.$doc1810$, 'drive_import', '01810-WEB-2002-12-26-per-essere-una-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1810)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1811, 'ITA', $doc1811$Castel Gandolfo, 20 febbraio 2003

Presunzione o precisa volontà di Dio?

Carissime,

         non si spegne ancora in noi il ricordo del meraviglioso Congresso mariano, che
abbiamo celebrato al Centro Mariapoli di Castel Gandolfo, dal 28 al 30 aprile scorso. Anzi
più circostanze lo mantengono vivo nel nostro cuore: il mese di maggio che è da tempo
dedicato a Maria; le trasmissioni televisive come "Frontiere dello Spirito", che ne riportano
il calore e l’entusiasmo; ed il ripetersi ora e più in avanti - come abbiamo sentito - di
Congressi mariani in tante parti del mondo.

         In uno degli ultimi momenti di quell’avvenimento al Centro – se ricordate – è stato
recitato un brano, noto a molti, dove si chiede a Gesù come mai egli, che è Dio, rimasto con
noi nell’Eucaristia, non ha trovato una maniera per farvi rimanere anche sua madre per tutti
noi, viatori deboli e bisognosi. Al che egli sembrava rispondesse: "Perché la voglio rivedere
in voi" e ci invitava ad essere madri, come lo è Maria, per tanti e ad imitarla rispecchiandoci
nelle litanie.

         Rivederla in noi!

Dunque noi potremmo vivere in maniera tale che Maria, la Madre dolcissima di Gesù e
nostra, possa trasparire in qualche modo nella nostra vita? Ed avere con ciò l’ardire ed il
coraggio, parafrasando le parole della piccola Teresa di Gesù, che dicevano: "Io, nella Chiesa
mia madre, sarò l’Amore", col dire da parte nostra: "Io, nella Chiesa mia madre, sarò una
piccola Maria"?

         Presunzione, grossa presunzione?

Sembra proprio di no, se si pensa come oggi lo Spirito Santo, con nuova luce, ci presenta la
Chiesa, attraverso Giovanni Paolo II. Egli ha affermato che, nella Sposa di Cristo, vi sono due
distinti profili o principi, in comunione tra loro: il profilo petrino, espresso dai Papi, che
continuano Pietro, e dalla Gerarchia; e il profilo mariano, che è la presenza, attraverso i
secoli, di Maria, nei molteplici antichi e nuovi carismi, che arricchiscono ed abbelliscono la
Chiesa con famiglie religiose, con Movimenti ecclesiali e Nuove Comunità.

Profili, quello petrino e quello mariano, coessenziali e cioè ambedue essenziali nella Chiesa.
L’uno e l’altro, quindi, importantissimi.
Ma, se il profilo mariano ha a che fare con i Movimenti ecclesiali, non è difficile dedurre che
anche l’Opera di Maria, una delle realtà carismatiche moderne, faccia parte di esso, con la
possibilità, per tutti noi che vi partecipiamo: uomini, donne, giovani e adulti, sacerdoti,
religiosi e vescovi, di rendere Maria presente nella Chiesa; capire perciò come sia doveroso
per tutti noi tendere a diventare un’altra Maria, una piccola Maria. E comporre in tal modo
quel rosario vivo che siamo chiamati a recitare, con la vita, prima di innalzarlo al Cielo con
una preghiera.

         Nulla di strano, dunque, né di impossibile in quel brano letto al termine del
Congresso. Non v’è nessuna presunzione in chi lo vuole tradurre in vita. Anzi con esso si
compie la volontà di Dio su tutti noi.

         Piuttosto, sarà bene sapere e ricordare come si attua questa volontà di Dio, il volere
di Dio. L’abbiamo capito: vivendo la "spiritualità dell’unità" o "di comunione", come la
chiama il Papa. Vivendone i cardini ad uno ad uno, come un bimbo che beve ogni giorno il
latte da sua madre. Perché, come abbiamo scoperto, la nostra spiritualità, che sfocia nella
possibilità di generare Cristo in mezzo a noi, è ciò che Maria e lo Spirito Santo ci offrono per
essere quelli che dobbiamo essere.

         Ultimamente però ci siamo concentrati su un solo cardine: la "volontà di Dio", che
viviamo nel presente aiutati dal passaparola.

         E’ necessario quindi chiederci: vivendo in tal modo facciamo tutto quello che
dobbiamo fare?

         Penso proprio di sì perché, osservando bene, vediamo come vivendo la volontà di
Dio in ogni presente, mettiamo in pratica, uno alla volta, anche gli altri cardini, bellissimi,
utilissimi, necessari.

         Vivendo la sua volontà, infatti, dimostriamo di credere che Dio è Amore, perché
preferiamo la sua alla nostra volontà; crediamo al disegno che egli ha su di noi piuttosto che
ai nostri progetti.

Per vivere la volontà di Dio, amiamo ogni prossimo che incontriamo; ci amiamo a vicenda
quando siamo insieme; ricomponiamo la nostra unità, se si fosse spezzata.

         Ci nutriamo dell’Eucaristia, altro cardine della nostra spiritualità, proprio per fare la
sua volontà; ascoltiamo la voce dello Spirito Santo quando parla nel cuore; attuiamo la
Chiesa-comunione e realizziamo l’unità.

         E, con essa, generiamo Gesù fra noi ed ecco raggiunto il nostro sogno d’essere
un’altra piccola Maria.
         Dobbiamo concludere che pure il prossimo mese, ed anche sempre, se lo vogliamo,
lavoreremo ogni attimo alla nostra specifica vocazione, facendo la volontà di Dio nel
presente, aiutati dal passaparola.

         E’ il fiat, il "sì" che contraddistingue la vita di Maria: "Sia fatto di me secondo la tua
parola" (cf Lc 1,38). Fiat che deve contraddistinguere anche la nostra vita.

         Insomma, vorrei spiegare per tutti: se noi viviamo l'attimo presente col passaparola,
la volontà di Dio nell'attimo presente col passaparola, viviamo tutti i punti della spiritualità.
Quindi non ci manca niente, possiamo andare avanti come siamo andati finora.$doc1811$, 'drive_import', '01811-WEB-2003-02-20-presunzione-o-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1811)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1812, 'ITA', $doc1812$Castel Gandolfo, 22 maggio 2003
Il "di più"

Carissimi,

alla presentazione del nostro libro Una via nuova, in una nazione europea, una personalità
religiosa ha fatto un apprezzamento di quest'opera che avrebbe potuto turbare la nostra
umiltà se l'avessimo pensato riferito a noi e non tanto al carisma che ci è stato dato: in
ultima analisi allo Spirito Santo. Ha detto che questo libro, in cui si analizza la nostra
"spiritualità dell'unità", poteva essere paragonato ad altri, classici, apparsi lungo la storia
della Chiesa che hanno fatto tanto e tanto bene.
Un'affermazione forte, che mi ha sorpreso, per cui ho cercato di capire cosa avrà potuto
impressionare quella persona.
E, scorse le prime pagine, mi è stato subito evidente che la nostra spiritualità può essere
così stimata per quel "di più" che richiede. Un "di più" capace di suscitare una via a Dio
veramente nuova, non solo personale, individuale, ma collettiva e comunitaria.

         Sì, perché noi dobbiamo andare a Dio non da soli ma con i fratelli. E' questo un
nostro "di più". Dobbiamo tendere alla santità assieme ai fratelli. In pratica, dobbiamo
aiutare i nostri fratelli a raggiungere la santità così come facciamo per noi.

         Un impegno di peso, che tanto facilmente dimentichiamo, ma che è per noi la
conditio sine qua non per perseguire la nostra stessa santità. Anzi: è solo amando il fratello
fino a questo punto che possiamo sperare la presenza di Gesù fra noi.

         E quale il modo migliore di vivere questo esigente amore verso i fratelli?
         Vi sono vari modi, ma uno è da considerare con attenzione, confermato anche dalla
mia lunga esperienza. Di esso ho già parlato, ma è così importante che merita ripeterlo.

         La vita di comunità che noi facciamo, sempre o temporaneamente, domanda di
amare costantemente i nostri fratelli, e cioè di farsi sempre uno con loro. Ed è quello che
cerchiamo di fare. Ma, anche se impegnassimo in ciò tutte le forze, non sempre riusciremmo,
perché siamo ancora in questo mondo e quindi inclini ai difetti e alle mancanze. E prima o
poi qualcuno di noi sbaglia.

         Che fare?

Se siamo noi a venir meno all'amore fraterno, rimettiamoci subito, rimettiamolo subito in
moto.

         E se fossero i nostri fratelli a comportarsi così, che cosa dobbiamo fare?

         Credetelo: è sapienza ascoltare san Paolo quando ci sottolinea il sopportare, perché
il sopportare non è una sottospecie dell'amore; il sopportare è insito nella carità, è un suo
aspetto, è costitutivo della carità. La carità, infatti, secondo l'apostolo Paolo, non solo "tutto
copre, tutto spera, tutto crede", ma anche tutto "sopporta", dice lui. Il sopportare è amore, è
carità. Senza di esso non si dà carità.

         Verrà il momento anche di avvertire il fratello dei suoi sbagli; il Vangelo esige pure
questo. Potrà essere, ad esempio, durante la periodica "ora della verità" – così noi la
chiamiamo – che nello Statuto rinnovato sarà consigliata a tutti i membri del Movimento,
perché i primi cristiani in genere, e non solo persone particolari, usavano metodi analoghi.

E' l'ora nella quale, per aiutarci ed edificarci, cerchiamo di evidenziare i lati buoni e quelli
meno buoni dei fratelli; e ciò a vicenda, l'un l'altro.

E facciamo questo solo per amore, non certo, ad esempio, per sfogarci magari di torti subiti
dai fratelli, ma con tutto quell'amore che possiamo avere, nella coscienza che - in pratica - se
il fratello migliora ne avrò vantaggio anch'io, perché qui sta la novità del nostro iter
spirituale: devo lavorare alla perfezione del mio fratello se voglio raggiungere la mia.

Siamo legati, non c'è scampo.

         Mettiamo d'ora in poi allora tutta la nostra volontà nel comportarci così: sopportarci
ogniqualvolta occorre e una volta tanto l'"ora della verità".

         Proviamo. E' un metodo cristiano. L'esperienza ci dice che porta frutto.$doc1812$, 'drive_import', '01812-WEB-2003-05-22-il-di-pi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1812)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1813, 'ITA', $doc1813$Castel Gandolfo, 19 giugno 2003

Lo stampo

Carissime,

         eccoci al Collegamento d'agosto, mese in cui, dalla nascita del nostro Movimento, si
festeggia - come abbiamo sentito - su tutto il pianeta santa Chiara d'Assisi, raffrontando in
genere il carisma donato a lei dallo Spirito Santo, col nostro.

         Anche quest'anno ci siamo comportati in questo modo e, poiché siamo tuttora
nell'anno dedicato dal santo Padre a Maria, abbiamo fatto un raffronto fra il rapporto che
ebbe santa Chiara con la Madre di Dio e quello richiesto a noi.

         Ora, in questo Collegamento, per non - come si dice - "moltiplicare le cose senza
necessità", vorrei trarre qualche pensiero per qualche proposito ancora da quel paragone.

         Fra quanto si è detto in quel giorno, propagato con i mezzi di comunicazione in tutto
il nostro mondo, una considerazione è stata quella sulla Desolata. Non La si è ricordata solo
come "monumento di virtù", di tutte le virtù cristiane, di tutte le virtù figlie della carità; né si
sono solamente letti alcuni versi che la riguardano. Maria Desolata, che è il "perdere
assoluto", "perdere universale" di tutto, per non possedere che Dio, amato in Sé e nei fratelli,
l'abbiamo ricordata pure come lo "stampo" in cui poterci gettare per uscire altro Gesù, altra
Maria.

         "Vi è una grande differenza - dice Montfort - tra lo scolpire un'immagine in rilievo a
colpi di martello e di scalpello, e il farne una gettandola nello stampo. Scultori e statuari
lavorano molto per produrre figure nella prima maniera, ed è loro necessario molto tempo;
invece, per modellare nella seconda maniera lavorano poco e la realizzano in pochissimo
tempo. Sant'Agostino chiama la Vergine - continua Montfort -, la Vergine santa, 'forma Dei',
'stampo di Dio': stampo adatto a formare e modellare degli dèi." Naturalmente figli di Dio
adottivi.

         "Chi è gettato in questo stampo divino, vien presto formato e modellato in Gesù
Cristo. Con poca spesa, e in breve tempo, diviene dio, perché è gettato nello stesso stampo
nel quale è stato formato un Dio."

         Che dobbiamo fare allora per divenire "altro Gesù","altra Maria"?
         Da qualche tempo noi conosciamo il cosiddetto "passaparola", cioè un modo di
vivere, diverso ogni giorno, che ci illumina, ci chiarisce, ci incoraggia, ci sprona, ci guida a
cogliere, in modo sempre nuovo la volontà di Dio nell'attimo presente: "Stabilirsi" nella
volontà di Dio dell'attimo presente, "perfezionarci", "adeguarci alla volontà di Dio
dell'attimo presente, "abbandonarci", "centellinare", "stazionare", "innamorarsi della
volontà di Dio nell'attimo presente".

         Usiamo fare così da quando abbiamo capito cosa significhi per la vita spirituale
vivere il momento presente con interezza: metodo che dà tanti vantaggi e, soprattutto, fa
camminare avanti. Infatti, comportandoci così, noi perdiamo tutto: il passato - perché
viviamo il presente -, il futuro, ogni cosa o persona, ogni desiderio, ogni attaccamento per
essere tutti lì, nel presente, a fare la volontà di Dio che significa amarlo con tutto il cuore, la
mente, le forze.

         E questo è proprio vivere la Desolata, è perdersi ogni attimo nel suo "stampo", nella
sua "forma" ed uscire Gesù, uscire Maria, o piccola Maria, come il Signore ci vuole.

         Perciò, se dopo la festa di santa Chiara, divampa nel nostro animo il desiderio di
vivere come Lei, di rivivere la Desolata, non abbiamo in pratica nulla da cambiare. C'è solo
da migliorare. Certo, questo sì, perché chi non avanza, va indietro.

         Carissime, per Foco è iniziata una divina avventura: probabilmente sarà
riconosciuta la sua santità.

         E noi, in quest'unica vita che abbiamo, vorremmo realizzare di meno?
         Che Maria Desolata possa, col suo aiuto, vedere uscire dalla sua Opera una schiera di
altri Gesù, altri Maria: una schiera di santi!
         E' quanto il Cielo desidera da noi. Auguriamocelo a vicenda.

Saluto di Chiara dopo il Collegamento

         Chiara: Voglio ricordarvi una cosa sola: voglio ricordarvi "lo stampo", "lo stampo",
perché in questo stampo si entra così: Marco, Chiara, Giovanni, Eli, Angela, ecc., e si esce
piccola Maria.

         Come si fa ad andar dentro in questo stampo? Come?
         Vivendo il presente col passaparola, proprio quello che stiamo facendo adesso, non
aggiungendo niente, soltanto facendolo sempre meglio, sempre meglio perché altrimenti
andiamo indietro.

         Se noi faremo così il prossimo mese ci troveremo arricchitissimi.

         Quindi, ciao a tutti, in tutto il mondo.$doc1813$, 'drive_import', '01813-WEB-2003-06-19-lo-stampo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1813)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1814, 'ITA', $doc1814$Mollens, 28 agosto 2003

Il "porro unum" del focolarino

         Carissimi,

         eccoci al primo Collegamento del nuovo anno ideale, che inizia mentre è vivissima in
noi ancora la figura spirituale del nostro Ulisse, l'ultimo focolarino arrivato nella Mariapoli
celeste.

         Giorni fa, scorrendo il suo profilo, letto alla Messa il giorno della sua festa - una festa,
infatti, è apparso il funerale -, un'idea mi è rimasta in mente: l'intera vita di Ulisse rivela il
"porro unum", l'aspetto più necessario del focolarino: l'amore al fratello. Si può definire il
focolarino, infatti, come colui che mette decisamente a base della sua vita spirituale l'amore
al fratello.

         E' questo amore che ha fatto Ulisse così grande, vero, autentico.

         E questo suo modo di essere, questo suo essere amore, è stato anche il motivo degli
innumerevoli frutti che ha portato, frutti che si possono riassumere in uno, preziosissimo:
aver spalancato l'Opera ed aver irradiato il suo Ideale ad un brano di umanità musulmana.

         Lo dice Farouk che scrive ad Ulisse ormai in Cielo: "Tu ci hai donato la tua vita. Tu ci
hai donato la vita. (…) La cosa più bella, che hai 'costruito', è l'Ideale in 'terra' d'islam, nel
cuore dei musulmani. Oggi l'Ideale è nostro. Oggi esiste una comunità, un popolo (nuovo) in
mezzo ai musulmani. E' per questo che io ti ho sempre considerato come mio padre, come il
padre fondatore."

         E in una lettera dei nostri amici musulmani dell'Algeria troviamo: "(Oggi) è partito
per il cielo quello che ci ha amato tutti, grandi e piccoli senza distinzione. (…) E' stato il
ponte, il legame fra il cristianesimo e l'islam."

         A conferma poi del suo amore, dovunque passava in mezzo ai fratelli di quel mondo,
tutti lo salutavano, tutti avevano conosciuto il suo amore personale e concreto.

         Maria Teresa Sala, che ha condiviso per anni con Ulisse la responsabilità del
Movimento in Algeria, scrive: "Ulisse è stato un vero fratello, un gigante della carità;
nessuno lo superava in questo. Per il fratello lasciava cadere tutto; il rapporto era la cosa più
importante, ora direi sacra. E' ciò che mi ha colpito da sempre. (…)
         Ciò che conquistava - continua Maria Teresa - era proprio questo perdere tempo per
i fratelli. Ulisse ha 'perso tempo' e ha 'guadagnato tempo'. E in questo (…) mi ha aiutato a
penetrare il cuore, l'animo di questo popolo che Gesù ci affidava."

         Ma anche chi non era musulmano egli amava con lo stesso amore.

         Scrive un focolarino della Siria: "Ulisse è stato un grande fratello per me, mi ha
aiutato spesso nei momenti difficili, quando mi confessavo da lui. Nella confessione
incarnava l'amore di Dio e la sua misericordia. (…) La sua serenità, la sua pace, il suo volto
sempre radioso comunicavano solo il divino."

         Mentre Rosa e Zouhir, musulmani, dicono: "Ulisse resterà per noi una leggenda del
Movimento dei Focolari in Algeria. Bastava guardare come viveva per capire il senso dello
spirito del Movimento."

         E Lydia e Samy, altri due musulmani: "Ulisse ora se n'è volato verso un altro mondo.
Continueremo a portare nel nostro cuore la fiamma di amore e di unità che lui ha sempre
seminato. Continueremo il nostro cammino sulle sue orme perché un giorno il suo sogno di
un mondo in pace divenga realtà."

         Sono tutte espressioni belle e toccanti che concordano in un punto.

         Nelle nostre menti primeggia spesso la preoccupazione di attuare i programmi, che
pure dobbiamo svolgere. In lui avevano il primo posto i fratelli, e così i programmi si
attuavano nel migliore dei modi.

         Non è il fare, infatti, che è importante nella nostra vita, ma l'essere. E si è, se amiamo.

         Carissimi, questa è la lezione che Ulisse ha fatto a noi, lezione che ha raddrizzato
tutte le nostre intenzioni, anche se è da una vita che la conosciamo e cerchiamo di metterla
in pratica. E' per questo che mi sembra di dover soffermarmi su di essa e, affinché la
possiamo vivere con la radicalità di Ulisse, propongo a tutti noi una mia idea.

         Abbiamo visto nell'ultimo Collegamento che, vivendo l'attimo presente col
passaparola, ci si getta nello "stampo", in Maria desolata, e si esce, in breve tempo e con
poca fatica, un altro Gesù, un'altra piccola Maria.

         E va bene. Se continuassimo a vivere così per tutta la vita, avremmo fatto ciò che è
sufficiente per un Viaggio veramente Santo.

         Ma, in questo momento, sento la necessità di precisare meglio per me e per voi il
nostro atteggiamento.

         In questi prossimi giorni il passaparola ci dirà: "Tener d'occhio l'attimo presente",
"Restare saldi nell'attimo presente", "Sfruttare la grazia attuale dell'attimo presente",
"Donarsi alla volontà di Dio nell'attimo presente", e così via.
         Che ne dite se al passaparola aggiungessimo: "Soprattutto a contatto con i fratelli",
sicché risulti così: "Tener d'occhio l'attimo presente soprattutto a contatto con i fratelli",
"Restare saldi nell'attimo presente soprattutto a contatto con i fratelli", "Sfruttare la grazia
attuale dell'attimo presente soprattutto a contatto con i fratelli"?

         Per parte mia, alla luce della vita Ideale di Ulisse, ho cominciato a vivere così e…
funziona. Ho l'impressione che, in questo modo, si moltiplichino gli atti d'amore a Dio e che
la nostra vita possa essere più aderente allo "stampo", sicché diventi più precisa e più
perfetta.

         Proviamo a vivere in tal modo almeno il prossimo mese. Poi vedremo.

         Che Ulisse ci aiuti: avrà così l'occasione, anche dal Paradiso, di amare ancora i suoi
fratelli e le sue sorelle.$doc1814$, 'drive_import', '01814-WEB-2003-08-28-il-porro-unum-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1814)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1815, 'ITA', $doc1815$Rocca di Papa, 25 settembre 2003

Una bella raccolta di virtù

Carissime,

         ormai da un paio d'anni tutti noi viviamo l'attimo presente, variandone
l'applicazione col passaparola. In questo mese l'abbiamo vissuto tenendo presente, in modo
speciale, i nostri fratelli. L'abbiamo fatto ad imitazione dell'amore di Ulisse verso tutti i
prossimi e a suo ricordo.

         Ebbene, si può osservare che uno dei risultati di questo modo di vivere, se fedele ed
abbastanza intenso, è quello di prendere ottime abitudini che prima non avevamo.

Ecco alcuni esempi. E' molto frequente offrire a Gesù le azioni che compiamo con un "per
Te", che trasforma la nostra giornata in un'ininterrotta preghiera; perché vivendo l'attimo
presente noi abbiamo una grazia attuale che ci ricorda di dire davanti ad ogni azione: "Per
Te".

         Un'altra cosa: di fronte alle tentazioni - vivendo così - ci si sente atti a difenderci con
più rapidità di prima.

         Di fronte agli attaccamenti a cose o persone o a noi stessi, è pronta la nostra tipica
dichiarazione d'amore: "Sei tu, Signore, l'unico mio bene".

         Si dà poi il giusto posto alle azioni che dobbiamo compiere, senza anticiparle perché
piacevoli, e senza posticiparle perché gravose; perché succede spesso così.

         Ancora: sgorgano spontanee dal cuore parole d'incoraggiamento, di stima, di lode,
verso i fratelli con cui viviamo o, in qualsiasi modo, incontriamo, attraverso il telefono, ad
esempio, scrivendo loro, preparando per loro discorsi, insegnamenti e così via. E sempre più
spesso si vede in loro Gesù, sicché, crescendo la nostra carità, facendosi via via più raffinata,
anche la nostra unione con Dio s'approfondisce.

         Un'altra cosa: non si dimentica di salutare e adorare Gesù, vivo nel tabernacolo,
ogniqualvolta gli passiamo accanto o ce lo ricorda una croce o un'immagine.

         Allo stesso modo si fanno atti di venerazione a Maria, specie ora dopo
l'indimenticabile anno a Lei consacrato.

         Un'altra cosa che si può osservare: si rimane di più alla presenza di Dio durante le
nostre pratiche di pietà e si allontanano con più facilità le distrazioni.
         Ancora: ci si accorge che si riesce a mantenere con maggiore facilità, durante tutto il
giorno, l'amore reciproco che, per cristiani come noi, è importantissimo. Dice, infatti, la
Scrittura che la sua attuazione - quella del comandamento nuovo - ci fa perfetti: "Se ci
amiamo gli uni gli altri, - dice Giovanni - Dio rimane in noi e l'amore di lui in noi è perfetto"
(cf 1 Gv 4,12).

         Prima - dobbiamo convenire -, pur con tanta buona volontà, la carità reciproca aveva
delle oscillazioni, certamente con continue riprese, ma con interruzioni.

         Un'altra: divenuti più perfetti nelle piccole cose, sappiamo compiere meglio anche le
grandi, e l'anima tutto il giorno è invasa di serenità, di pace e di gioia.

         Queste alcune abitudini acquistate che alimentano diverse virtù nella nostra anima.
Ed è proprio una bella accolta di virtù che fa del viaggio della vita un Santo Viaggio: ciò che
desideravamo quando, anni fa, l'abbiamo iniziato tutti insieme. Un Viaggio Santo, un Santo
Viaggio: un viaggio verso la santità. Certamente.

         Alla Chiesa, per promuovere un cristiano a modello degli altri, per dichiararlo beato
e santo, non interessano tanto certi fenomeni pur mistici come le visioni, le locuzioni, i
rapimenti, le bilocazioni…, ma interessano le virtù.

         Ora, se tutto questo, e più, possiamo costatare in noi vivendo con costanza l'attimo
presente, dobbiamo concludere che siamo sulla buona strada. Ringraziamo perciò il Padre,
che guida, con la storia grande del mondo, la nostra piccola storia e diamo lode allo Spirito
Santo, che pensiamo non assente in questo suggerimento (attimo presente rafforzato col
passaparola) tanto semplice e tanto utile soprattutto per chi vive, come la maggior parte di
noi, in mezzo al mondo.

         Per il prossimo mese non ci resta che continuare a vivere il presente col
passaparola, aggiungendo: "Soprattutto verso il fratello".

         Alla Vergine Maria raccogliere e presentare alla Santissima Trinità i nostri atti
d'amore.$doc1815$, 'drive_import', '01815-WEB-2003-09-25-una-bella-raccolta-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1815)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1816, 'ITA', $doc1816$Castel Gandolfo, 23 ottobre 2003
7 dicembre 1943 – 7 dicembre 2003

Carissimi,

         abbiamo appena attraversato il traguardo del 60° anno di vita del nostro
Movimento.

         Un traguardo straricco di doni più che preziosi: durante il primo incontro delle
focolarine, la vigilia, il 6 dicembre, un incoraggiamento caldo e sentito da parte di S.E. mons.
Stanislaw Rylko, che ci rappresenta la Chiesa, con luminose parole sul nostro carisma. Poi,
portatoci da lui, un lungo paterno e affettuoso messaggio del santo Padre. E, ancora, il
giorno 7, la sorpresa delle sorprese: una inaspettata quanto gradita telefonata del Papa
stesso nel mio focolare, con gli auguri riconoscenti per il nostro 60° anno di vita al servizio
della Chiesa e dell'umanità.

         Che cosa ci dice tutto questo?
         Credo che abbiamo bisogno di tempo per capire il significato di quanto è successo il
6 e il 7 dicembre scorsi, per meditare soprattutto le parole del santo Padre nel suo
messaggio, onde viverle, come, ad esempio, la nuova moderna definizione che egli dà della
nostra vocazione: "Apostoli del dialogo", di cui a prima vista si intuiscono le molte
implicazioni.
         Ci vorrà tempo e noi ci proponiamo sin d'ora di dedicarvici nell'immediato futuro.

         Oggi sappiamo di trovarci di fronte ad un'Opera nuova che 60 anni fa non c'era.
Opera strabenedetta dai rappresentanti di Dio in terra (dagli ultimi Papi soprattutto), Opera
che abbiamo visto nascere, crescere, svilupparsi su tutta la terra. Realtà ecclesiale di fronte
alla quale noi focolarini - ben consci che il suo primo e principale autore è stato ed è lo
Spirito Santo, di cui ci sentiamo collaboratori anche se indegni e imperfetti - noi,
parafrasando il Cantico dei Cantici, ardiamo ripetere con gioia e gratitudine: "La nostra
vigna, proprio la nostra, ci sta dinanzi. Possiamo contemplare i suoi tralci su tutta la terra e i
grappoli che continuano a nutrire un popolo nuovo" (cf Cant 8,12).
         Ed oggi guardando indietro possiamo capire cosa poteva dirci, diversi decenni fa,
quel 7 dicembre '43, anno della nascita del nostro Movimento; afferma che un carisma dello
Spirito Santo, una nuova luce è scesa in quei giorni sulla terra, luce che nella mente di Dio
doveva dissetare l'arsura di questo mondo con l'acqua della Sapienza, riscaldarlo con
l'amore divino e dar così vita ad un popolo nuovo, nutrito dal Vangelo. Questo anzitutto.

         E, poiché Dio è concreto nel suo agire, ecco che ha provveduto subito ad assicurarsi
il primo mattone per l'edificio - quest'Opera - che sarebbe stata utile al suo intento. E pensa
di chiamare me, una ragazza qualunque; e di qui la mia consacrazione a Lui, il mio "sì" a Dio
seguito ben presto da tanti altri "sì" di giovani donne e giovani uomini.

         Di luce, dunque, parla quel giorno e di donazioni di creature a Dio quali strumenti
nelle sue mani per i suoi fini.

         Luce e donazione di sé a Dio, due parole estremamente utili allora, in quel tempo di
smarrimento generale, di odio reciproco, di guerra. Tempo di tenebra, dove Dio pareva
assente nel mondo col suo amore, con la sua pace, con la sua gioia, con la sua guida, e
sembrava nessuno si interessasse di Lui.

         E luce e donazione di sé a Dio, due parole che anche oggi il Cielo vuole ripeterci,
quando sul nostro pianeta si protraggono tante guerre e soprattutto, più spaventoso di
tutte, è apparso il terrorismo.

         Luce che significa Verbo, Parola, Vangelo, ancora tanto poco conosciuto e
soprattutto troppo poco vissuto.

Donazioni a Dio oggi più che mai necessarie e opportune se, per le cause che animano il
terrorismo, s'arruolano uomini e donne pronti a dare la vita. Che deve essere allora di noi
cristiani, seguaci di un Dio che è stato crocifisso e abbandonato, perché nasca un mondo
nuovo, per la nostra salvezza e per quella Vita che non avrà tramonto?

         Carissimi, pensiamo un po' in questo mese a quanto ci ricorda il 60° anno del nostro
Movimento e ripartiamo verso il mondo, che ci attende come Vangeli vivi, per poterlo
immergere nella sua Luce.

         Lo possiamo fare continuando a vivere la volontà di Dio nel momento presente col
"passaparola". Senza dimenticare di far propria la Parola di vita colta dalla Scrittura che ci
viene proposta mese per mese. Più completa, com'è ora, e molto apprezzata, può essere
oggetto della nostra meditazione quotidiana. Dimenticarla sarebbe svestirsi pian piano di
quel Vangelo che ammanta il nostro popolo.
         E, quasi nascessimo un'altra volta, ridoniamoci completamente a Dio secondo il
modo da Lui scelto per ciascuno di noi. Così anche il presente e il futuro che Dio ci donerà
diverranno graditi a Lui, come i 60 anni del nostro Movimento nel passato.

         Avanti, dunque, e Buon Natale a tutti, con in cuore i tesori ricevuti il 7 dicembre.$doc1816$, 'drive_import', '01816-WEB-2003-10-23-7-dicembre-1943-7-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1816)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1817, 'ITA', $doc1817$Castel Gandolfo, 22 gennaio 2004

Più in profondità

Carissimi,

         il titolo di questo pensiero è: "Più in profondità".

Siamo al Collegamento di febbraio, che vi arriva dall'Irlanda, e sempre nel 60° anno del
nostro Movimento.

         Un anno di gioia generale per i molti doni che lo Spirito Santo per mezzo - pensiamo
- di Maria ha donato all'Opera di Maria.

         Fra questi, come già sappiamo, è la bellissima lettera che il santo Padre ha diretto a
me per tutti noi, il 4 dicembre scorso.

         Di essa abbiamo già commentato, la volta scorsa, il nuovo nome che egli ci ha dato:
"Apostoli del dialogo". Ed è stato evidente che siamo tali perché il carisma dell'unità ci ha
aperto ad un dialogo universale di 360 gradi; e particolare all'interno della Chiesa, fra fedeli
di Chiese diverse, fra seguaci di varie religioni, fra chi crede e chi ha un'altra cultura.

Abbiamo però sottolineato che per la nostra spiritualità - così l'altra volta -, personale e
comunitaria insieme, siamo tali, cioè in dialogo, anche perché in costante dialogo fra noi.
Anzi abbiamo compreso più profondamente come nella vita di Dio-Amore, uno e trino
eternamente in dialogo, è il nostro supremo modello.

         Oggi passiamo a commentare una seconda parte della lettera del Papa. Tutto, infatti,
quanto egli ci dice è norma per noi, è direttiva, è comando. E' - come dice santa Caterina da
Siena - la parola del dolce Cristo in terra. Gesù parla soprattutto di lui, cioè del Papa, quando
dice: "Chi ascolta voi ascolta me" (Lc 10,16).

         Nel secondo capoverso del punto 2 egli analizza la storia del mondo, in genere, di
questi ultimi sessant'anni e vede - parole sue - "mutamenti sociali rapidi e sconvolgenti
(…)". Secondo lui "l'umanità (…) perseguendo interessi passeggeri, ha talora smarrito i
propri valori di riferimento ideale. Ed ora rischia di ritrovarsi quasi 'senz'anima'".

Costata ciò in particolare in Europa, "che - come lui afferma - conta una bimillenaria
tradizione cristiana". Per questo "s'impone con urgenza (…) - dice - una nuova
evangelizzazione".
Perché si faccia, s'appella ai Movimenti ecclesiali, al loro ruolo importante e fra essi occupa -
secondo il santo Padre - "un posto di rilievo quello dei Focolari." Per lui "i nuovi Movimenti
ecclesiali costituiscono un dono prezioso per la Chiesa" e la Chiesa - sempre parole sue - "li
invita a svolgere la loro profetica azione".

         E nel numero 3, mentre s'associa a noi nel "comune rendimento di grazie a Dio per
le grandi cose da Lui compiute in questi sessant'anni" nell'Opera, affida tutti noi "e le
molteplici attività" che svolgiamo "alla materna protezione di Maria Santissima".

Ci incoraggia inoltre "ad abbracciare" con Gesù "il mistero della Croce per cooperare, (…)
alla salvezza del mondo".

E con questo, "di cuore" - scrive lui - invia a me, ai miei "collaboratori e all'intero Movimento
dei Focolari" la sua "affettuosa Benedizione".

         Carissimi, ecco cosa vuole il Papa da noi: mettere in atto la "nuova
evangelizzazione", di cui spesso abbiamo parlato, e, per questo, come primo atto,
abbracciare nella nostra vita personale e nel nostro compito "il mistero della croce" e cioè:
abbracciare sempre e dovunque Gesù abbandonato.

         Nei prossimi Collegamenti, per essere in perfetta sintonia con la volontà di Dio
espressaci dal Papa, approfondiremo i diversi aspetti della "nuova evangelizzazione".

         Oggi aggrappiamoci con tutto il cuore - come suggerisce il Papa - a Colui che è stato
causa della planetaria espansione del nostro Movimento e cioè della nostra universale
evangelizzazione: Gesù abbandonato.

         In che modo?

         Ripetiamogli tutto il giorno, con tutto il cuore, ad ogni piccolo o grande doveroso
distacco, ad ogni dolore che subentra, nostro o altrui: "Sei Tu, Signore, l'unico mio bene".
L'abbiamo fatto spesso in passato, da diventare per noi quasi una salutare abitudine. Ma
questa volta l'impegno deve essere moltiplicato: lo vuole il santo Padre, lo vuole Dio.

Mariapoli Lieta (Prosperous - Irlanda)

26 febbraio 2004
La parabola della Parola

Carissime e carissimi tutti,

come sapete, da alcuni mesi stiamo meditando e mettendo in pratica diverse
direttive che il santo Padre ci ha dato nella sua bellissima e ricca lettera del 4
dicembre scorso, in occasione del 60° della nascita del nostro Movimento.
Abbiamo cercato di capire come tradurre in pratica, ad esempio, il nuovo nome che
lui ci ha dato. Ci ha chiamati: "Apostoli del dialogo".
Abbiamo accolto con gioia l'invito che egli ci fa alla "nuova evangelizzazione" che le
circostanze oggi impongono. E, per cominciare, ci siamo impegnati la volta scorsa ad
attuare quel suo consiglio là dove dice: "Incoraggio tutti a seguire fedelmente Cristo
e ad abbracciare con Lui il mistero della croce…", che per noi è Gesù crocifisso e
abbandonato.

                                                      E oggi?
C'è una caratteristica della "nuova evangelizzazione", messa in evidenza dal Papa nel
suo Magistero, che dice: "La nuova evangelizzazione sarà efficace se saprà
proclamare dai tetti quanto ha prima vissuto nell'intimità col Signore".
"Proclamare dai tetti" che significa? Penso voglia dire semplicemente il nostro
dovere di non solo vivere, ma anche annunciare agli altri la Buona Novella. Del resto,
in un altro discorso Giovanni Paolo II sottolinea che "non si può evangelizzare se
prima non si evangelizza se stessi", "se non si è personalmente oggetto di
evangelizzazione".
Tuttavia quel "proclamare dai tetti" può indurci a pensare ai posti con maggior
irradiazione, come i luoghi più importanti e prestigiosi, e soprattutto evangelizzare
con i più potenti mezzi di comunicazione moderni.

Noi seminiamo la Parola da 60 anni a livelli normali, come negli incontri della
Parola di vita, e la annunciamo dovunque sul nostro pianeta.
Usiamo poi i mezzi moderni sia in seno al Movimento che fuori. E abbiamo portato
la Parola, sin dall'inizio, e la portiamo tuttora, in posti di rilievo: nei Parlamenti, ad
esempio, o in istituzioni mondiali, come è stato per l'ONU o l'UNESCO… Oppure in
Università statali o della Chiesa o in Curie generalizie, ecc.

E allora non ci resta che continuare ad evangelizzare in tutti i modi. Ad esempio,
riceviamo ogni mese una Parola di Dio commentata. Che fare? Viviamola noi intanto,
e poi creiamo dovunque occasioni d'incontro con le persone anche appena
conosciute, ma che pensiamo sensibili al nostro Ideale.
Succederà allora come ai primi tempi del Movimento, quando la gente al di fuori si
meravigliava di vedere sorta - quasi un miracolo -, al posto di una Parola letta e
magari meditata, una comunità cristiana vivente che continua a crescere per il bene
di tanti e a gloria di Dio.
Pensiamoci in questo momento ed operiamo in questo senso: è "nuova
evangelizzazione", quella che il santo Padre vuole anche da noi. Ci renderemo conto
di fare una cosa grande, gradita a Dio e attesa dall'umanità. Infatti, possiamo
affermare che la Parola di Dio, una volta seminata in buon terreno, non solo
attecchisce splendidamente, ma lo fa in modo sorprendente e duraturo. Ne ho avuto
ulteriore conferma in questi giorni.
Un nostro padre del PIME era stato per molti anni in Brasile, in un paese del Mato
Grosso, un posto sperduto dove aveva comunicato alle persone il nostro Ideale, e la
Parola naturalmente.
Trasferito da alcuni anni in un'altra città, dovendo tornare in quel paese del Mato
Grosso per qualche giorno, pensava che l'entusiasmo che aveva notato in quella
gente per la Parola si fosse col tempo smorzato.

                                        E invece che cosa ha trovato?
Una comunità di 70 persone, che lo hanno accolto con gioia, preparandogli un
week-end d'incontri in una sala sulla cui parete campeggiava la scritta: "Mariapoli
2004".
 Alcuni hanno raccontato varie esperienze - in quell'occasione - e tra esse quella di
una tribù indigena col loro capo-tribù di 80 anni, che è sempre stato presente
regolarmente per l'incontro della Parola di vita.
 E questo fatto non è certamente il solo. Anzi! So di un gruppo di persone di una
nazione europea, che, raccolto attorno alla Parola di Dio 20 anni fa, era poi rimasto
per certe circostanze un gruppo isolato. Ebbene, rivisitando la città dopo così tanto
tempo lo si trovò ancora vivissimo.

Tutto questo ci fa capire meglio Isaia quando dice: "Come la pioggia e la neve
scendono dal cielo e non vi ritornano senza avere irrigato la terra, senza averla
fecondata e fatta germogliare, (…) così sarà della parola uscita dalla mia bocca; non
ritornerà vuota a me (…) senza avere compiuto ciò per cui io l'ho mandata" (Is
55,10-11).

 Lavoriamo allora, lavoriamo ad annunciare la Parola sempre e dovunque.
Cominciamo in questo mese a creare nuove occasioni per diffondere la Parola o
ravviviamo metodi passati e poi, magari, trascurati, perché la Parola si diffonda più
al largo possibile. Avremo gioia in terra e, perché cooperiamo ai disegni di Dio sugli
uomini, gloria in Cielo.$doc1817$, 'drive_import', '01817-WEB-2004-01-22-pi-in-profondit-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1817)
on conflict (document_id, language) do nothing;
