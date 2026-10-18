-- 102_import_italian_originals_part05.sql (5/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1638-1657 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1638, 'ITA', $doc1638$Rocca di Papa, 19.12.1985

1986
ESSERGLI TESTIMONI

Carissimi,
Iniziamo il nuovo anno (il VI del nostro Santo Viaggio) con un’altra splendida Parola di Vita:
“Mi sarete testimoni a Gerusalemme, in tutta la Giudea e la Samaria e fino agli estremi
confini della terra” (At, 1, 8).
“Mi sarete testimoni [...] fino agli estremi confini della terra”. Gesù ha concluso con queste
parole uno dei suoi ultimi incontri con gli apostoli dopo la risurrezione.
Aveva parlato loro probabilmente della prossima venuta dello Spirito Santo ed ora chiariva
loro che egli sarebbe venuto non per compiere un cambiamento spettacolare, come essi
s’aspettavano, ma per trasformare le loro persone, affinché potessero testimoniarlo,
portando in se stesse il Risorto, fino agli ultimi confini della terra.
Portare il Risorto. Sì, perché per testimoniare Dio occorre dimostrare che egli c’è, che egli
vive, che è il Vivente. Niente, allora, di più utile per una testimonianza di Dio, il Vivente, che
portarlo vivo in se, come Risorto.
Così fecero gli apostoli una volta ricevuto lo Spirito Santo. Ma, come sappiamo, anche a tutti
noi è stato dato lo Spirito Santo sin dal battesimo. Sono quindi anche per noi le parole: “Mi
sarete testimoni [...] fino agli estremi confini della terra”.
Testimoni. Sappiamo come si dice in greco “testimonianza” Marty´rion.
I martiri, infatti, sono considerati i primi testimoni.
Ma anche gli altri modi di dare testimonianza a Gesù, che noi conosciamo, esigono un
martirio. Occorre morire a se stessi con l’abbraccio di Gesù Abbandonato perché il Risorto
viva in ciascuno di noi.
Occorre ancora essere morti a se stessi perché il Risorto splenda fra di noi. E noi sappiamo
che quando è fra noi si dà testimonianza. Non ha forse detto Gesù che siano uno affinché il
mondo creda? (cf. Gv 17, 21). E cioè: che siano uno affinché il mondo riceva una
testimonianza di me e creda?
Lasciar vivere il Risorto in noi e in mezzo a noi sono i due modi principali con cui lo Spirito
Santo ha insegnato a noi a dar testimonianza.

In questi quindici giorni potremmo prendere di mira soprattutto il primo modo.

Come allora vivere bene perché ciò si verifichi?

E su che cosa porre in particolare la nostra attenzione?

Se osserviamo la nostra maniera di vivere secondo l’Ideale che Dio ci ha dato, vediamo che
ognuno di noi ogni giorno segue, più o meno diligentemente, il programma che ha previsto:
compie quei lavori, ha quell’incontro, scrive quelle lettere, stende quel discorso. Si prende
tempo per il momento dei pasti, del riposo e anche forse della distensione. E, se è fedele e
nella tensione alla santità, armato di buona volontà, esegue tutto alla perfezione, vedendo
Gesù nei fratelli che incontra, mantenendolo vivo in mezzo a tutti.

Ma ecco che ogni giorno succede qualche cosa di nuovo: piccole o grandi novità che variano
le nostre previsioni, e sono anch’esse per noi volontà di Dio.

Ogni giorno, nessuno escluso, uno o più imprevisti s’inseriscono nel nostro programma e
possono anche buttarlo all’aria in parte o del tutto.

Naturalmente, se siamo davvero attenti alla voce dello Spirito dentro di noi, sappiamo
accogliere con amore anche quella notizia, quella circostanza, quell’incontro,
quell’avvenimento.

Se, invece, non siamo troppo attenti alla voce dello Spirito, rimaniamo attaccati ai nostri
programmi e non sappiamo far morire la nostra volontà in quella di Dio. In quei momenti, la
luce del Risorto si spegne in noi.

Ecco: in questi prossimi quindici giorni, per poter testimoniare Gesù sempre, dobbiamo far
attenzione a tutto quanto ci arriva fuori programma. Un aiuto potente ci sarà dato dal
costante ricordo di essere tutti donati a Gesù Abbandonato. L’abbandono da parte del Padre
non era nel programma di Gesù, almeno da quanto noi sappiamo. Eppure era previsto dal
Padre per completare la passione del suo Figlio onde potesse liberare il genere umano dal
peccato.

Ma Gesù, dopo il grido di sorpresa: “Dio mio, Dio mio, perché mi hai abbandonato?” accetta
subito questa terribile circostanza fuori programma e dice con fiducia: “Padre, nelle tue
mani consegno il mio spirito”.

Così anche noi dobbiamo rimanere pronti a tutto ciò che nelle nostre giornate può
succedere di non previsto, e – sia esso cosa dolce o dolorosa o indifferente – dobbiamo farlo
subito nostro affinché il Risorto, il Vivente, splenda senza interruzione nel nostro cuore.

In questo modo Gli saremo veramente testimoni.$doc1638$, 'drive_import', '01638-WEB-1985-12-19-essergli-testimoni-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1638)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1639, 'ITA', $doc1639$Rocca di Papa, 2.1.1986

AL 100%

Carissimi,

Come tutti noi sappiamo, il nostro Ideale si può definire con una sola parola: amore.

L’amore è tutta la nostra vita. L’amore è l’anima della nostra preghiera, del nostro
apostolato, di tutte le espressioni della nostra esistenza.

L’amore è anche la salute della nostra vita spirituale individuale, così come l’amore
reciproco è la salute di noi come comunità, come Corpo mistico di Cristo. Quando amiamo,
infatti, siamo a posto, tutti interi, davanti a Dio, sia che godiamo dell’integrità fisica, sia che
siamo ammalati.

Ma amare quando si è sani è facile: è facile amare Dio e i fratelli. Amare quando si è
ammalati è più difficile

Ebbene, poche volte ho visto realizzato questo nostro dover essere dell’amore nella malattia
come in questi giorni. Poche volte ho visto qualcuno che è veramente malato eppure ti viene
da dire: quanto è sano!

Come immaginerete, vado di tanto in tanto a trovare Marilen che al Centro Mariapoli sta
trascorrendo questi giorni particolari della sua infermità, e l’impressione che ne ricavo è
che sia una persona veramente sana, completamente sana. Non è sana nel fisico, certamente,
ma è sana, tutta sana nell’anima.

Sì, perché quando ci si è consacrati a Gesù Abbandonato, si può aderire con il cuore e con la
volontà alle sue visite al 20%, al 50% o al 70%, al 100%.

Marilen vi aderisce al 100%. La sua vita è un continuo “per Te”, a significare che tutto offre a
Lui per noi, per l’Opera di Dio.

Vi ho comunicato questo bellissimo esempio che dà Marilen per porre a me ed a voi ora una
domanda: È giusto forse che chi si trova in momenti così difficili della sua vita terrena viva
con tanto impegno lo sposalizio della sua anima con Gesù Abbandonato, e noi che abbiamo
magari più salute fisica viviamo con mediocrità la nostra tensione alla santità? Dobbiamo
sempre lasciare che Dio permetta nei nostri confronti delle prove speciali, di quelle che
sembra tolgano il respiro, per farci decidere ad amarlo con totalitarietà?
No, è iniziato il VI anno del nostro Santo Viaggio e dobbiamo metterci a viverlo con tutto lo
slancio.

Qualcuno m’ha detto che lo considererà come fosse il primo. Io vorrei consigliasi di
considerarlo come fosse l’ultimo: come quell’anno cioè in cui si decide se davanti a Dio
saremo o non saremo santi.

Ma allora, se vogliamo pensarlo così (e chi può dire che non sarà così?), non si può perdere
tempo.

Abbiamo tutti lo Spirito Santo in cuore e conosciamo le sue richieste, le sue indicazioni. È
Lui che ci dice: Qui c’è da amare Gesù Abbandonato, in un dolore ad esempio o in una fatica;
qui c’è da preferirlo in una virtù, nell’amore fraterno ad esempio; qui ancora c’è da
sceglierlo in un aspetto dell’Opera o della Chiesa o dell’umanità...

Dobbiamo fare il proposito di amarlo giorno per giorno, sempre, come Marilen, al 100%. E
come lei dobbiamo ripetere prima di ogni nostra azione: “Per Te”.

Se ci spaventasse poi una vita così impegnata (il demonio è capace di ogni cosa pur di
scoraggiarci), come fa Marilen ricordiamo la raccomandazione di Gesù: “A ciascun giorno
basta la sua pena” (Mt 6, 34). Occupiamoci, dunque, del volto di Gesù Abbandonato di oggi,
di ogni momento. Per domani avremo altre grazie.

Così metteremo da parte giornate piene, tutte consacrate a Lui. È con esse che costruiremo
la nostra santità.

Se poi ci tocca di fallire, di tradire, di bloccarci, sappiamo che anche al di là di tutte queste
circostanze c’è il suo volto.

Che ogni sera possiamo rispondere a noi stessi, o meglio a Gesù che a interroga in fondo al
cuore sul come è andata la giornata: “Bene, al 100%”.

Così facendo viviamo anche la Parola di Vita del mese: “Mi sarete testimoni”.

Col nostro abbraccio di Gesù Abbandonato al 100% il Risorto splende in noi e fra noi e dà
testimonianza.

Allora, d’accordo? Mettiamoci in gara con Marilen. Che per 350 giorni (quanti ne mancano
per finire quest’anno) possiamo dire alla sera, sempre: al 100%.$doc1639$, 'drive_import', '01639-WEB-1986-01-02-al-100-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1639)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1640, 'ITA', $doc1640$Rocca di Papa, 6.2.1986

OPERE PERFETTE

PER AMORE DI GESÙ ABBANDONATO

Carissimi,

Il desiderio struggente di santità che a volte ci invade (e se non lo sentiamo in cuore
dobbiamo chiederlo allo Spirito Santo nella preghiera e non ce lo farà mancare), ci porta
spesso a chiederci a quale “cengia” , a quale appiglio cioè, a quale corda dobbiamo
aggrapparci per camminare sicuri accanto allo strapiombo del mondo ammalato e spesso
moribondo per il materialismo che lo invade, per il secolarismo, per l’edonismo o
l’indifferenza religiosa che lo domina.

E subito un nome tanto ben noto a noi riaffiora nell’anima: Gesù Abbandonato. Aggrapparci
dunque a Gesù Abbandonato. Amare Gesù Abbandonato.

È proprio a questo nome, che tocca così tanti aspetti della nostra vita di singoli e di
comunità, che vorrei anche oggi accennare.

Più precisamente, vorrei dirvi qualcosa su un modo particolare di amare Gesù
Abbandonato, porta, via alla nostra santità.

Vi ho detto un giorno che il grande atto d’amore che Gesù chiede a noi è quello di lavorare
per la sua Opera.

Oggi vorrei precisarvi che questo lavoro per l’Opera non è solo amore di Dio generico, ma è
proprio amore a Gesù Abbandonato.

Stiamo preparando in questi giorni il Convegno per il Movimento Parrocchiale che si terrà il
3-4 maggio nell’aula Paolo VI a Roma, in Vaticano.

E anch’io, come tanti altri, mi ci sono impegnata Ora, stendendo discorsi, ascoltandone altri,
correggendo esperienze, ho compreso meglio come la riuscita di quella giornata dipenderà
molto da come adesso prepariamo ogni cosa e da come allora la offriremo.

Abbiamo curato bene ogni intervento?

Abbiamo definito alla perfezione ogni dettaglio fino al punto in cui lo Spirito nel nostro
cuore non ha più nulla da suggerirci? E in questo modo ci comporteremo anche in quel
giorno? Se così è, siamo sicuri che tutto andrà bene, che con l’aiuto di Dio sarà un incendio.
Siamo sicuri che i riflessi di questa giornata si sentiranno per lungo tempo e si
espanderanno molto al largo. Siamo sicuri che la vita di quella struttura della Chiesa che è la
parrocchia, a volte trascurata, forse anche spenta per l’indifferenza di molti, tornerà a
pulsare.

Siamo sicuri che il volto di Gesù Abbandonato, che si può scorgere anche in questa
espressione di Chiesa, sarà alleviato, consolato, abbellito in molte parti del mondo.

Ed ecco così amato Gesù Abbandonato.

Ma non è solo lavorando per quel particolare, che è il Movimento Parrocchiale, che si ama
Gesù Abbandonato.

Siamo impegnati nel movimento Famiglie Nuove?

Non ricorda spesso oggi anche la famiglia il volto sfigurato di Gesù Abbandonato, il diviso, il
separato, il distrutto?

Lavoriamo al movimento Gioventù Nuova? Non è forse la nostra gioventù tanto di frequente
un’altra espressione del volto di Gesù Abbandonato per tutti i problemi che la investono: la
delusione, l’indifferenza, la sfiducia, la disoccupazione?

Lavoriamo nei vari mondi di Umanità Nuova? Non troviamo forse anche qui nel campo della
salute, della politica, della scuola, dei mass-media, dell’economia... tante situazioni che
ricordano colui che amiamo?

Ma..., mi avete capito.

Dovunque mettiamo le mani nell’Opera troviamo il suo volto, sentiamo il suo grido.

Dovunque abbiamo la possibilità meravigliosa di amarlo, di sollevarlo, di consolarlo, di
porre rimedio a mali concreti, espressioni di Lui. E ciò è una grande grazia. Per questo
lavoro siamo sempre in contatto con Lui, con Gesù Abbandonato, e amandolo possiamo
costruire la nostra santificazione.

Però c’è modo e modo di amarlo. Si può amarlo tanto, si può amarlo poco. E ciò significa: si
può con questo amore contribuire ad una nostra grande santità o ad una piccola. Si fanno
opere, ad esempio, nel nostro Movimento che, una volta espletate, non hanno più seguito.
Senz’altro anche con queste abbiamo un po’ amato Gesù Abbandonato. Ma ci sono opere che
sono sempre richieste, e sono quelle in genere che più servono, perché le più riuscite.

Occorre fare opere che restino, che abbiano sempre qualcosa da dire. Così si ama tanto Gesù
Abbandonato.

I santi hanno cercato e cercano, per la gloria di Dio, quell’amore che dà il massimo
rendimento.
Scriviamo la nostra storia per donare la nostra esperienza? Facciamolo bene, benissimo,
ascoltando con grande attenzione la sua voce dentro di noi che getta luce sul nostro passato
e presente, quella luce che piace a chi ascolta e che attira.

Prestiamo attenzione a quanto quella voce ci suggerisce e a quello che corregge.

Facciamo ogni cosa con impegno, con il massimo impegno. Smettiamo di ritoccare il nostro
lavoro solo quando quella voce non ha più nulla da dirci.

Non strapazziamo mai l’Opera di Dio. Non facciamo mai opere imperfette.

Facciamo dunque tutto bene, tutto benissimo.

Ed ecco allora il proposito per i prossimi quindici giorni: di fronte a qualsiasi opera che
intraprendiamo, cerchiamo di scoprire quale volto di Gesù Abbandonato possiamo amare
con essa, e lanciamoci a farla perfetta. Opere, dunque, perfette per amore di Gesù
Abbandonato e costruire così la nostra santità, la nostra grande santità.$doc1640$, 'drive_import', '01640-WEB-1986-02-06-opere-perfette-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1640)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1641, 'ITA', $doc1641$Rocca di Papa, 16.1.1986

VIGILARE

Carissimi,

Fra i tanti membri della nostra Opera che la volta scorsa hanno ascoltato il Collegamento,
c’era anche Sebastiano Biarese, di 39 anni, il carissimo caponucleo di volontari di Mondovì
(Cuneo), presente a Sassone per il suo incontro.

Era tornato poi a casa a fine corso ed era rimasto sveglio, quella domenica sera, fino all’una
di notte per parlare del raduno con Meri, la moglie, delegata delle volontarie, e accordarsi
con lei per amare Gesù Abbandonato, come s’era detto, al 100%.

Aveva deciso anche di non comperarsi la casa per essere più libero di spostarsi in altra zona,
qualora l’Opera avesse disposto così. Il mattino dopo, alla Messa, come fosse l’ultima volta,
avevano ambedue rinnovato la stessa promessa del 100%. In quello stesso giorno è partito
veramente per un altro luogo, specialissimo: fulminato da una scarica elettrica, Sebastiano
andava nella Mariapoli Celeste.

Carissimi, perché vi ho raccontato questo fatto? Non certo per contristarvi. Non per
spaventarvi, anche se il timor di Dio è salutare.

Vi ho detto quanto è successo a Sebastiano perché il nostro Collegamento ha per scopo di
farci essere sempre di più una sola famiglia, un solo focolare in tutto il mondo; e di farci
condividere fra tutti gioie, dolori, speranze, progetti in modo che nell’unità troviamo la forza
di raggiungere la santità Ve l’ho detto anche perché Meri e il suo bravo ragazzo sentano in
questo frangente la nostra unità più profonda, la nostra solidarietà più cristiana.

Poi, perché lodiamo Dio insieme e lo ringraziamo di aver preso con se uno dei nostri in un
momento così bello.

E infine, perché possiamo meglio comprendere come le cose che riguardano Dio sono
tremendamente serie, come con Lui non si può scherzare. Con Dio non si può giocare. Egli,
del resto, ci ha preavvertiti.

Non ha forse ammonito: “Vegliate perché non sapete né il giorno né l’ora” (Mt 25, 13)?

Se dunque toccasse ad ognuno di noi personalmente quanto è successo al nostro volontario,
non potremmo lamentarci. Perciò, dobbiamo proprio metterci nella linea indicataci da Gesù.
Come sapete, in questo mese di febbraio la Parola che dà luce al nostro cammino avverte:
“Non di solo pane vivrà l’uomo” (Lc 4, 4). Sì, perché l’uomo vive anche della Parola di Dio.

E quale Parola allora prendiamo in risalto in questi quindici giorni?

Io direi proprio: “Vegliate, perché non sapete né il giorno né l’ora”.

Dunque: vegliare. Ma che significa vegliare? Significa stare con gli occhi aperti, usare molta
attenzione, stare all’erta. Significa, dunque, essere ben presenti ogni minuto.

Ho costatato dalla mia esperienza che si vigila bene quando ci si decide a vivere la volontà di
Dio con pienezza, tutti protesi in quella dell’attimo presente.

Così facendo si coglie il momento, ogni momento di Dio. Non si rimanda a dopo o a domani o
a dopodomani questo importantissimo dovere di vigilare. Se Sebastiano non avesse denso di
amare subito Gesù, come fosse stata l’ultima occasione che aveva di amarlo, forse non
potremmo esser lieti oggi della sua morte.

No: dobbiamo stare sempre all’erta. Così egli ci troverà sempre con le lampade accese, le
lampade dell’olio dell’amore.

Facciamo allora questo proposito: porre attenzione a ciò che Dio vuole nell’attimo presente
ed abbracciarlo. Così vigileremo davvero. E in qualsiasi momento egli verrà, sotto forma di
sofferenza o di gaudio o addirittura di morte, ci troverà pronti. Vigilare dunque, vivendo
tutto intero l’attimo presente.$doc1641$, 'drive_import', '01641-WEB-1986-01-16-vigilare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1641)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1642, 'ITA', $doc1642$Loppiano, 20.2.1986

RINASCERE CON L’AMORE

Carissimi,

Eccoci ricollegati fra noi per camminare insieme verso la santità.

Siamo ancora in Quaresima, anche se la Pasqua è ormai alle porte. E la Quaresima, come
sappiamo, chiede a tutti i cristiani la conversione.

La domanda anche a noi.

E qual è la tipica conversione che noi, membri del Movimento dei Focolari, dobbiamo esser
sempre pronti a fare, soprattutto in questo tempo di Quaresima?

È il “convergere”, il rivolgersi verso Dio, cosa che noi operiamo in concreto, nella maniera
più indovinata, quando ci rivolgiamo al prossimo, lo prendiamo in considerazione come
nostra via specifica, che ci apre l’accesso a Dio.

Voi sapete come parliamo spesso del prossimo e dell’amore che dobbiamo a lui. Eppure ogni
volta che ci viene illuminata questa strada, è sempre una cosa nuova per noi.

E successo anche a me qualche giorno fa.

Facevo meditazione sul messaline. Ed ecco di fronte ai miei occhi la pagina stupenda del
giudizio finale: Gesù che verrà per giudicarci e ci dirà: “[...] ho avuto fame e mi avete dato da
mangiare, ho avuto sete e mi avete dato da bere [...] ” (Mt 25, 35).

Leggendo quelle parole sono rimasta colpita come fosse la prima volta che le leggevo.
Riscoprivo che Gesù, all’esame finale, non mi avrebbe chiesto questa o quell’altra cosa che
pure devo fare, ma avrebbe puntato proprio sull’amore al prossimo.

Ho cominciato, come una persona che inizia ora la sua salita a Dio, ad amare tutti, tutti quelli
con cui avevo a che fare durante la giornata. E, credetelo, mi sono sentita rinata. Ho
avvertito che la mia anima ha soprattutto fame di amore, fame di amare; e che qui,
nell’amore verso tutti, trova veramente il suo respiro, il suo alimento, la sua vita. Il fatto è
che anche prima cercavo di compiere tanti atti d’amore, mai – ora me ne rendevo conto –
alcuni erano più che altro espressione d’una spiritualità troppo individuale, che si alimenta
di piccole o meno piccole penitenze, che, nonostante la nostra buona volontà, possono
essere occasione per noi, chiamati all’amore, di un certo ripiegamento su noi stessi. Adesso,
in questa nuova tensione ad amare tutti, potevo cogliere ancora tanti atti d’amore, ma tutti
finalizzati ai fratelli, nei quali vedevo e amavo Gesù. E solo qui era per me la pienezza della
gioia.
Carissimi, siamo chiamati tutti ad operare continuamente in noi questa conversione;
dobbiamo tutti sperimentare questa specie di rinascita, questa pienezza di vita. Occorre
cercare perciò, il più possibile, di tradurre in carità verso il prossimo tutte le espressioni
della nostra esistenza.

E nostro dovere accudire alla casa? Non facciamolo solo per motivi umani, ma perché c’è
Gesù nei fratelli da amare, vestendoli, sfamandoli, servendoli. Dobbiamo svolgere qualsiasi
apro lavoro? C’è Gesù nei singoli e nelle comunità ai quali portare il nostro contributo.
Dobbiamo pregare? Preghiamo sempre per la nostra persona come per le altre, usando quel
“noi” che Gesù ci ha insegnato nel “Padre nostro”. Siamo chiamati a soffrire? Offriamo il
nostro dolore per i fratelli. È volontà di Dio trattare con qualcuno? Sempre ci sia l’intenzione
di ascoltare Lui, di consigliare Lui, di istruire Lui, di consolare Lui... in una parola: di amare
Lui. Dobbiamo riposare, mangiare, svagarci? Diamo a tutte queste azioni l’intenzione di
volere, con questi atti, riprendere le forze per servire meglio il fratello.

Facciamo ogni cosa, insomma, in vista del prossimo.

E anche se questo atteggiamento d’anima, che ci porta costantemente fuori di noi, sarà fonte
di grande gioia (parlavo prima di rinascita) stiamo certi che la fatica nell’uscire da noi per
“vivere – come si dice – gli altri” ci sarà.

In essa ci è offerta la possibilità di amare Gesù Abbandonato, nella pratica delle virtù della
pazienza, della benevolenza, dell’umiltà, della magnanimità, della povertà, della purezza che
sono implicite nella carità.

Sì, carissimi, dobbiamo farci santi, ma per la nostra via, che è quella dell’amore, anzi
dell’amore radicale, da praticare prima fra noi, dove diventa reciproco, e poi con tutti.

Per questo, anzi perché avvenga in noi tale riconversione, teniamo in mente nei prossimi
quindici giorni l’impegno: “Rinascere con l’amore”.

Ci prepareremo così alla Pasqua, per la cui festa vi auguro tutta la gioia della piena
risurrezione, assicurandovi di vivere in perfetta unità con tutti voi gli insegnamenti e i
misteri che la precedono nella Settimana santa: il Comandamento nuovo, il Testamento di
Gesù, l’istituzione del sacerdozio, l’Eucaristia, il grido di Gesù.$doc1642$, 'drive_import', '01642-WEB-1986-02-20-rinascere-con-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1642)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1643, 'ITA', $doc1643$Rocca di Papa, 20.3.1986

AMARLO SENZA TREGUA

Carissimi,

Pasqua è passata e per essa è stata viva in tutti – penso – la meditazione sul Risorto che
deve vivere in noi e fra noi.

Anche per il nostro Movimento, come per Gesù, questo evento straordinario è stato
preceduto da una meditazione profonda sulla morte. Ce ne ha data l’occasione Marilen,
partita da questa terra quattordici giorni fa.

Vi arriveranno notizie sulla sua vita ricchissima e sulla sua morte altrettanto ricca, ma sin da
oggi voglio comunicarvi almeno qualche pensiero.

Marilen ad un dato punto della sua esistenza aveva chiesto a Gesù la grazia di fare il
purgatorio in terra, e sembra proprio che sia stata esaudita.

Pareva infatti, in questi ultimi mesi, che Dio le domandasse, come a Giobbe, una cosa dietro
l’altra di quante le aveva donato con la vita. Aveva perso l’uso delle gambe (non si reggeva
più in piedi), l’uso delle mani (non poteva più afferrare), l’uso della parola (non poteva quasi
comunicare), respirava con estrema difficoltà, anche la memoria le veniva meno e alla fine
non poteva più inghiottire. Si stava dunque avvicinando l’ultimo giorno.

Quando si accorse di questo – era la sera prima che si assopisse profondamente – aveva
chiesto alla focolarina che l’assisteva di avvertirmi della situazione estrema in cui si trovava
e io le avevo risposto: “Marilen, Gesù ti chiede mode cose; dagliele tutte generosamente”. E
lei: “Sì”. E ancora: “Marilen, ama Gesù Abbandonato alla follia”.

E lei: “Sì”.

Era riuscita a dire sì anche in quel momento perché l’aveva fatto in tutte le richieste
precedenti.

Quello proprio che più impressionava in quest’ultimo periodo della vita di Marilen era il
fatto che Dio possa chiedere ad una persona una cosa dietro l’altra senza tregua, e che ella
possa aver la grazia di dire sempre di sì.

Tale costatazione faceva nascere nel cuore di chi la visitava dei desideri ardenti e delle
domande: anche se non siamo nelle condizioni di Marilen, perché aspettare che ci sia
annunziata la morte per metterci sul serio ad amarlo? Perché non incominciare subito a
farlo, dicendo sì senza tregua a tutte le richieste del suo amore? Perché attendere di amarlo
per timore della morte vicina e non amarlo subito per amore? Non dobbiamo un giorno tutti
noi, anziani o giovani, morire? Non è meglio tener presente subito questa realtà e lanciarci
in una salita senza soste?

Sì, carissimi, questo ci chiedevamo in cuor nostro mentre Marilen, inchiodata in croce, ci
trascinava dietro di sé.

E a queste domande volevamo e vogliamo tuttora rispondere anche assieme a voi, per farvi
partecipi del grande dono che abbiamo avuto di vivere un po’ assieme a Marilen la
conclusione della sua avventura terrena.

Sappiamo del resto per chi dobbiamo spenderci. Sappiamo dove possiamo trovare Gesù
Abbandonato da amare.

Egli è lì: in tutte le circostanze dolorose della vita, nei sacrifici che comporta la carità
fraterna, nelle mortificazioni implicite alla vita cristiana e ideale, nel lavoro per l’Opera, che
è tutta protesa ad alleviare il dolore di Gesù Abbandonato nell’umanità di oggi. Troviamo
Gesù Abbandonato dovunque ci è richiesta fatica, ci è domandata sofferenza.

Come Marilen, dobbiamo sempre accoglierlo con un grande sì. E accoglierlo senza porre
tregua al nostro amore.

Marilen, nella sua dolcezza e nella sua umiltà, diceva di non aver teso alla santità
precedentemente con sufficiente slancio. Ora quindi era impegnata a rifarsi, e i suoi atti
d’amore, che contava su una coroncina, salivano ogni giorno di numero, un numero
impressionante. Tutto il giorno era un continuo: “Per te”, un “sì” quasi continuato.

Anche noi, anche noi dobbiamo fare così. Promettiamolo a Gesù: ti amerò d’ora innanzi
senza mettere sosta al mio amore. Farò in un giorno quello che avrei fatto in tre, per
quantità di atti d’amore, per qualità di atti d’amore. E se un giorno la tensione calasse,
ricominceremo il giorno dopo. Allora, se così sarà, succederà anche a noi quanto è successo
a Marilen all’ultimo momento: il suo volto pallido, tirato, distrutto e dolorante s’è ad un
tratto illuminato, rasserenato, addolcito e pacificato. Che Gesù o Maria le si siano in qualche
modo manifestati? Che siano venuti a prenderla?

Succederà anche a noi che, dopo aver tanto amato, egli si manifesterà con il suo amore
grande, immenso. E tutto sarà compiuto, avremo raggiunto la santità.

Allora d’accordo: i prossimi quindici giorni amarlo senza tregua!$doc1643$, 'drive_import', '01643-WEB-1986-03-20-amarlo-senza-tregua-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1643)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1644, 'ITA', $doc1644$Rocca di Papa, 3.4.1986

SEGUIRE GESÙ

Carissimi,

Quest’anno in tutto il Movimento si approfondisce quel cardine della nostra spiritualità che
è la Parola di Dio. Non sarà inutile allora, almeno una volta, soffermarci un po’ per
esaminare l’incidenza che la Parola ha sulla nostra vita. Voi sapete come una nostra
preoccupazione costante sia quella che la Parola (o il pensiero del Collegamento che spesso
la riassume o la ricorda) perda, con l’andare del tempo, la forza rivoluzionaria che aveva i
primi tempi, forza che ha dato origine addirittura al Movimento stesso. Non diciamo noi,
forse, che esso è sorto dalla Parola vissuta, per la Parola applicata, con la Parola nel cuore e
nella vita?

Il Movimento, infatti, prima non c’era. Ma una volta messo in pratica il Vangelo, anzi attuata
una sua parola dietro l’altra, ecco comporsi una comunità di persone che venivano a
conoscersi per la prima volta, che cominciavano ad amarsi; ecco formarsi da gente prima
dispersa, un piccolo popolo: il Movimento nascente.

Ora – vogliamo chiederò – la Parola ha ancora questa forza su di noi?

Se guardiamo l’Opera nostra in genere, possiamo dare una risposta affermativa. Esistono,
infatti, alla periferia del Movimento o dove, per così dire, il Movimento è in prima linea,
innumerevoli gruppi della Parola che hanno il solo scopo di imparare a viverla. Sono gruppi
visitati poi da noi che comunichiamo loro altri aspetti della nostra spiritualità e
introduciamo così piano piano in tutta la vita dell’Opera. In questi gruppi si può dunque
notare come la vita della Parola sia veramente via al formarsi del Movimento. E questo non
può non infonderci gioia e riconoscenza verso Dio. Ma per noi, che già siamo nel Movimento,
la Parola ha questa forza dinamica, rivoluzionaria, che opera trasformazioni?

Potremo rispondere positivamente, se essa porta quegli effetti che conosciamo ed abbiamo
elencato nella nostra conversazione sulla Parola.

Per la Parola dovrebbero – lo sappiamo – cambiare tutti i nostri rapporti: quello con Dio e
quelli con il prossimo. Per la Parola inoltre si dovrebbe scoprire nella nostra convivenza la
presenza del Padre, il quale interviene con la sua Provvidenza, attua alla lettera le sue
promesse, le promesse evangeliche, perché noi viviamo alla lettera la sua Parola.

Ebbene, guardando il Movimento così come si presenta, possiamo pensare che almeno un
po’ questi effetti ci siano.
Non ci aiuta forse la Parola (o – ripeto – il pensiero del Collegamento che in genere
s’aggancia alla Parola) a risolvere i nostri problemi personali? Non ci spinge forse a far
vivere e rivivere il Risorto nelle nostre anime mediante l’abbraccio ripetuto di Gesù
Abbandonato?

E, dandoci così la forza di essere in piedi, non ci aiuta forse ad amare gli altri, ad essere fuori
di noi, protesi nel servizio del prossimo, nell’attuazione del Comandamento nuovo? E con
tutto ciò non continuano forse a rinnovarsi i rapporti anche con i prossimi? Non si mantiene
vivo perciò il Movimento in tutte le sue parti e non prosegue la sua espansione?

E per quanto riguarda l’esperienza della Provvidenza di Dio, non è anch’essa una realtà
quotidiana in molte parti del mondo “ideale” , come lo era nei primi tempi?

Sì – per quanto ci consta – la Parola svolge tuttora la sua funzione. Anzi mi sembra che
moltissimi fra noi vi sono aggrappati come all’ancora della salvezza. Essa è, in genere, il
fondamento del nostro vivere, di ogni nostra attività. Stiamo dunque contenti! Lo Spirito
non ci ha abbandonato, ci ha aiutato a rimanergli fedeli, a mettere il “porro unum” al suo
posto.

Certamente, se guardiamo caso per caso, vediamo che si potrebbe fare sempre di più e
meglio, ma non possiamo negare che Dio ci ha aiutato, che il Movimento è vivo, che la
rivoluzione, impressa in esso dalla Parola, continua.

E allora, verificato questo fatto, prendiamo coraggio per proseguire.

La Parola di questo mese dice: “Le mie pecore ascoltano la mia voce ed io le conosco ed esse
mi seguono” (Gv 10, 27). Con essa Gesù voleva dire che chi, con la grazia di Dio, è aperto alla
sua Parola e l’accoglie, è sempre più sintonizzato, come per istinto, sui suoi pensieri, sui suoi
sentimenti, sui suoi insegnamenti. Ed egli conosce queste persone, le ama e di conseguenza
esse lo seguono come suoi discepoli.

In questi prossimi quindici giorni, cerchiamo di seguire Gesù. Egli parla al nostro cuore
attraverso la sua voce. A volte ci dirà di ravvivare l’amore reciproco, oppure di abbracciare
la croce.

Ci suggerirà di essere perfetti, oppure di migliorare, o anche di ricominciare... Qualsiasi cosa
ci dica, seguiamolo.

Seguire Gesù è la parola d’ordine che ci ripromettiamo di vivere.$doc1644$, 'drive_import', '01644-WEB-1986-04-03-seguire-ges-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1644)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1645, 'ITA', $doc1645$Rocca di Papa, 17.4.1986

MARIA FORMATRICE DI SANTI

Carissimi,

Vorrei parlarvi questa volta di un argomento che mi sta particolarmente a cuore.

Si tratta di Maria, del nostro rapporto con lei, della nostra madre, dataci da Gesù nel
momento culminante della redenzione.

Ce ne dà lo spunto il mese di maggio che iniziamo ora, mese dei fiori, mese di Maria.

Ma ci spinge a farlo soprattutto il fatto che noi siamo “Opera di Maria”, che Maria è la regina
del nostro Movimento, la nostra vera presidente; che lei – l’abbiamo sempre detto – è il
nostro modello, la nostra forma, il nostro dover essere.

Sto leggendo in questi giorni dei brani su Maria di autori vari, in genere dei santi. Attraverso
di essi mi sto rendendo conto sempre di più dell’importanza di Maria nella vita spirituale di
un cristiano che tende alla santità.

Dicono infatti, questi autori, che la Madonna è formatrice di santi, che per tutte le persone
simili a Gesù, cioè per tutti i santi, la Madonna è al centro delle loro esperienze
soprannaturali; essi si sono formati tutti attraverso Maria. Per farci santi dunque – ed è ciò a
cui tendiamo anche attraverso questi collegamenti – dobbiamo mettere Maria sempre più al
suo giusto posto nella nostra vita spirituale. Qualche volta però, come si sa, il cammino non
è facile. Si incontrano prove, difficoltà, impedimenti che minacciano di bloccare i nostri
buoni propositi.

Si capisce quindi quanto sia importante una grande unione con Maria.

Per la via di Maria – dicono questi autori – si cammina più soavemente e più
tranquillamente. Certo, anche sul suo percorso non mancano aspre lotte da sostenere; ma
lei, Maria, come buona madre, si fa così vicina e presente ai suoi fedeli per rischiararli nelle
loro tenebre, per rassicurarli nei loro timori, per sostenerli nei loro combattimenti, che
davvero questa via (la via di Maria), paragonata ad ogni altra, è una via di rose e di miele.

Anche la nostra via spirituale è chiamata “Via di Maria”, “Via Mariae”.

Ravviviamo allora la fede che Maria ci è vicina, ma rinnoviamo soprattutto il proposito di
essere noi vicinissimi a lei. Se poi ci sembra di camminare con troppa lentezza per questa
via, ricordiamo quell’affermazione dei santi: si avanza di più in poco tempo di sottomissione
e di dipendenza da Maria (noi dobbiamo dipendere da lei perché è il nostro capo) che in
anni interi di propria volontà e appoggio su se stesso, perché un’anima obbediente e
sottomessa a Maria canterà vittoria su tutti i suoi nemici.

E se infine abbiamo già fatto qualche passo nella via di Maria, se ci sembra d’aver percorso
con la grazia di Dio qualcuna delle sue tappe, confidiamo di arrivare, perché uniti a lei, fino
alla meta.

È convinzione dei santi che lo Spirito Santo, Sposo di Maria, quando l’ha trovata in un’anima
la penetra tutta e le si comunica tanto più abbondantemente quanto maggior posto
quest’anima fa alla sua Sposa.

Dobbiamo dunque far di tutto per metterci in profonda unione con Maria incominciando
ora, in questo mese di maggio.

I santi, sempre totalitari, ci invitano a donarci tutti a lei, senza limitazioni, così da essere in
qualche modo, dicono (ripetendo un concetto a noi caro), “ella stessa vivente, parlante,
operante in questo mondo” per mezzo nostro.

Essere allora tutti suoi, donandole la nostra vita, ma anche le nostre singole azioni e gli
sforzi per raggiungere la santità.

Essere tutti suoi, offrendole delle Ave Maria e dei rosari recitati con tutto il cuore,
pregandola che si prenda cura particolare di noi e di tutta la nostra Opera.

Essere tutti suoi, andandola più spesso a trovare nei luoghi e nelle chiese dove più è
venerata.

È impressionante cosa inventano i santi per dichiararle il loro amore!

Ora tocca a noi!

Dobbiamo fare come loro e, se siamo Opera di Maria, dobbiamo puntare ad essere nella
Chiesa fra coloro che più la amano.

Un proposito conforme alla nostra vocazione sarebbe veramente quello di tendere ad
amarla come nessun altro la ama. Immaginiamo quanto l’ha amata Gesù. Ecco, noi dobbiamo
avere il suo cuore nell’amare la sua e nostra madre. Sì, nessuno deve superare noi
nell’amarla, nel venerarla, nel lodarla, nel cantarla. Sia questo il nostro proposito: Nessuno
ci superi nell’amare Maria.$doc1645$, 'drive_import', '01645-WEB-1986-04-17-maria-formatrice-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1645)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1646, 'ITA', $doc1646$Rocca di Papa, 1.5.1986

AMARE SENZA RISPARMIO

Carissimi,

Sono trascorsi già quindici giorni del mese di maggio e sono certa che, almeno un po’,
abbiamo cercato di aumentare nel nostro cuore l’amore per Maria.

Lo abbiamo fatto se non altro per i grandi vantaggi che porta il camminare per la sua via: chi
va a Gesù passando per Maria – lo abbiamo visto l’altra volta – trova la strada della santità
assai più dolce, cammina molto più in fretta e raggiunge la meta.

Così – penso – in questi giorni molti di noi certamente si saranno dichiarati suoi, tutti suoi,
per essere meglio di Gesù.

Sì, questo deve essere stato fatto. Lo direbbe un avvenimento piccolo, se si vuole, ma che a
noi piace interpretare in una data maniera, essendo convinti che la Madonna non si lascia
vincere in generosità.

Abbiamo detto noi di voler essere di Maria, tutti suoi?

Maria in qualche modo ci ha risposto e ha detto che é nostra. Lo ha fatto per bocca del Santo
Padre Giovanni Paolo II che ha coniato per noi (e nulla accade a caso) quasi una nuova
litania.

Era l’ultima ora del nostro Congresso parrocchiale e i partecipanti stavano tutti in piazza
San Pietro per assistere al Regina Coeli del Papa.

II Pontefice, dopo aver ricordato la celebrazione della Pasqua della Chiesa ortodossa e, dopo
aver rivolto bellissime parole anche a noi, ha soggiunto:

“Ancora una volta saluto tutti i presenti, ringraziando per questa comunione di preghiere
[...] in cui facciamo tutti gli auguri pasquali alla madre del Cristo risorto; [...] alla madre
nostra, madre nostra Maria; Maria dei focolarini, (Maria) dei focolari [...]”.

È stato un tripudio per il nostro cuore! E così sentito, che abbiamo pensato di intitolare il
bell’altorilievo su Maria, che un focolarino sposato sta preparando per il Centro Mariapoli di
Castelgandolfo, a “Santa Maria dei focolarini”.

“Maria dei focolarini”. Sì, è molto probabile che Maria abbia voluto dichiararsi “nostra”
tramite il Santo Padre. Non s’avvera sempre forse il “Date e vi sarà dato” (Lc 6, 38)? Ci siamo
dati a lei e lei s’è data a noi.

Siamo, dunque, grati a Maria per questa che ci piace pensare come una nuova sua grazia.
E allora in una gara d’amore continuiamo ad amare Maria con crescente intensità.

Lo possiamo fare camminando velocemente per la sua via, la via Mariae che è la nostra via.

Essa contempla tutte le tappe della sua vita e tutta la nostra spiritualità che ce le fa
percorrere.

Contempla, fra il resto, il vivere in modo radicale la Parola. Questo mese la Parola ci dice:
“Voi però non siete sotto il dominio della carne, ma dello Spirito, dal momento che lo Spirito
di Dio abita in voi” (Rom. 8, 9).

Sì, lo Spirito di Dio abita in noi.

E noi sappiamo cosa fa lo Spirito di Dio in noi. Egli diffonde nei nostri cuori l’amore.

Lasciamoci allora bruciare, incendiare da questo amore.

Che esso consumi tutto in noi! Che non risparmi nulla! Che nulla resti di noi che non sia
incenerito.

In pratica, amiamo Dio con tutto il nostro cuore. E, per far bene ciò, amiamo con tutto il
cuore, la mente, le forze, i nostri fratelli.

Gesù non ha risparmiato nulla nell’amarci: ha dato la sua vita per noi.

Maria non ha risparmiato nemmeno il suo Figlio per noi: l’ha dovuto perdere non solo
perché moriva, ma perché Gesù, in certo modo, affidandole Giovanni, la disimpegnava
dall’essere sua madre.

Tutto bisogna perdere per amore dei fratelli. Il nostro amore deve avere questa misura.

Analizziamo tutte le occasioni che abbiamo nelle nostre giornate di amare, cominciando dai
prossimi che ci stanno vicino, a quelli per i quali lavoriamo, a quelli inoltre a cui è diretto il
nostro apostolato in seno all’Opera e vediamo se siamo disposti a dare tutto di noi stessi:
forze, volontà, intelligenza.

La voce interiore ci sa dare la risposta. E, se essa è positiva, stiamo tranquilli. Altrimenti
correggiamo il nostro comportamento e amiamo senza risparmio.

Rimetteremo perciò in moto la nostra rivoluzione d’amore. È questa che Maria,
interpretando i disegni di Dio su di noi, vuole da noi.

Con decisione quindi: Per amare Maria, per vivere ai suoi ordini, amiamo i fratelli fino in
fondo, senza risparmio.$doc1646$, 'drive_import', '01646-WEB-1986-05-01-amare-senza-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1646)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1647, 'ITA', $doc1647$Rocca di Papa, 15.5.1986

PER ESSERE ATTI AL REGNO DI DIO

SCEGLIERE GESÙ ABBANDONATO

Carissimi,

È terminato lo splendido mese di maggio durante il quale, in tutto il Movimento, si è cercato
di incrementare l’amore per la nostra Mamma celeste.

Anch’io, come penso voi, ho voluto fare la mia parte per esternare a Maria, anche con passi
concreti, la mia devozione. Per questo sono andata a trovarla dove è più venerata: nei suoi
santuari. A Roma ho visitato quello della Mentorella e del Divino Amore. A Firenze quello di
Monte Senario dei Sette Santi Fondatori e a Trento quello di Baselga di Pine e della
Madonna delle Laste.

Ogni volta ho affidato a Maria tutti voi. E ogni volta è stata una consolazione, tanto da
sentire un desiderio strano: possedere anche noi un nostro santuario, erigere anche noi una
chiesa tutta in suo onore.

Trovandomi a Loppiano, immaginavo questo santuario proprio lì, nella nostra cittadella.

Quand’ecco una risposta interiore, e forse proprio da Maria: “Non voglio da voi un santuario
di pietra. Voglio voi. Voi siete le pietre vive d’un mio santuario. Non dite forse di camminare
per la “via Mariae” per divenire altre me? Non siete allora delle pietre che, durante il Santo
Viaggio, lo Spirito Santo leviga fino a renderle perfette ed atte ad una simile costruzione?”.

E ho capito: Loppiano – come del resto ogni altra nostra cittadella – non è soltanto – come
noi l’abbiamo definita – una città-scuola il cui maestro è Gesù in mezzo, né solo una città
posta sul monte, e neppure soltanto una città in cui si vive il Vangelo.

Loppiano può essere considerata una città-Maria, dove gli abitanti cercano di vivere come
Maria, sia nella loro vita singola che in quella collettiva, dove Maria rivive perciò, in certo
modo, misticamente in loro.

Loppiano può esser vista come una città in cui lo spirito di Maria aleggia, sicché quelli che
vengono a visitarla (e sono migliaia e migliaia) trovino la sua atmosfera come appunto nei
santuari mariani.

Ho riferito questi miei pensieri ai cittadini di Loppiano, suscitando gioia ed impegno.
Ma poi, pensandoci bene, ho capito come tutta la nostra Opera, così come è sparsa nel
mondo, può essere considerata un originale santuario mariano.

Non è il nostro Movimento una grande Mariapoli nel mondo? Non vogliamo forse tutti
divenire un’altra piccola Maria singolarmente e tutti insieme?

Sì, tutti noi siamo un edificio costruito in suo onore; siamo, o meglio dobbiamo essere, una
lode concreta a Maria che s’innalza da tutta la terra.

Allora ravviviamo in noi questa coscienza, viviamo con questo pensiero, con questo tesoro
in cuore, e non avremo così nostalgia perché il mese di maggio è passato, ma saremo in
grado di fare di tutto l’anno un mese di maggio. Rimarremo con Maria per tutti i dodici mesi
e lei resterà con noi ad insegnarci come amare Gesù, a confortarci nelle nostre pene, a
guidarci per la sua via, a portarci alla santità.

E perché ciò sia vissuto nella pratica, vediamo quale Parola è di luce nel nostro cammino
ora, in questi quindici giorni. Essa dice: “Nessuno che ha messo mano all’aratro e poi si
volge indietro è adatto per il regno di Dio” (Lc 9, 62).

“Si volge indietro”. Cosa vuoi dire questo guardare indietro? Significa tornare alle cose di
prima. Riprendere in considerazione e vivere con la nostra vita gli ideali di prima.

Gesù con questa parola ammonisce quelli che “hanno messo mano all’aratro”, e cioè hanno
fatto qualche buon proposito, di non tornare indietro, pena l’incapacità di portare il Regno
di Dio.

Noi, ad un dato punto della nostra vita, abbiamo scelto Gesù Abbandonato come il tutto
della nostra vita. L’abbiamo scelto con preferenza sulle altre cose.

Ciò ci impegna a rimanergli fedeli.

Scegliere Gesù Abbandonato con predilezione significa amare più il dolore e la fatica che la
virtù comporta, delle gioie, delle consolazioni, dei doni di Dio. Significa amare i fratelli, sul
cui volto scopriamo il suo volto, più di tutti gli altri.

Vuol dire amare le finalità dell’Opera: l’unità con i cattolici con i quali non siamo ancora in
perfetta unità d’amore, l’unità con i fratelli di altre Chiese, i fedeli di altre religioni, i lontani.

Ora, per essere atti a vivere per il suo Regno e cioè per la sua Opera, dobbiamo restare nella
radicalità di questo amore.

Ed è ciò che dobbiamo riconfermare in questi quindici giorni.

Dire a Gesù Abbandonato: “È te che voglio: non ho altro amore preferenziale. Vivo per te. Tu
sei il significato della mia vita”.
Così facendo cammineremo senza soste nella “via Mariae”, Maria si sovrapporrà alla nostra
figura; saremo nuove creature come lei perché il Risorto vivrà in noi, contribuiremo a fare
della nostra Opera un suo santuario.

Ricordiamo, allora: “Per essere atti al regno di Dio, scegliere Gesù Abbandonato”.$doc1647$, 'drive_import', '01647-WEB-1986-05-15-per-essere-atti-al-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1647)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1648, 'ITA', $doc1648$Rocca di Papa, 5.6.1986

GUARDATE A GESÙ ABBANDONATO

E TROVERETE LA RISPOSTA

Carissimi,

Eccoci ricollegati nuovamente per infervorarci a vicenda a camminare, anzi a correre nella
via della santità.

La Parola di Vita di questo mese, infatti, ci dice: “Corriamo con perseveranza nella corsa,
tenendo fisso lo sguardo su Gesù [...]” (Ebr 12,1-2).

È quella della vita spesso una corsa ad ostacoli. Ci sono le prove, ci sono le più varie
sofferenze. Ecco perché dobbiamo tenere lo sguardo fisso su Gesù, anzi su Gesù
Abbandonato.

E questa volta vorrei proprio dire una parola soprattutto a quelle persone – e ne ho presenti
alcune – che stanno subendo delle prove spirituali o fisiche e dir loro: “Guardate a Gesù
Abbandonato e troverete la risposta”.

Gesù Abbandonato è infatti modello di come si superano le prove.

Un aspetto di Gesù Abbandonato, e forse uno dei più dolorosi, è quello di chi, dopo aver
permeato tutta la sua vita spirituale della fede nell’amore di Dio, si trova per delle
circostanze a sentirsi abbandonato da Lui.

Ebbene anche qui, anche in questa situazione, egli deve guardare a Gesù Abbandonato. Non
aveva detto Gesù che tutti l’avrebbero abbandonato ma il Padre sarebbe sempre stato con
Lui?.

Eppure nell’abbandono si verifica il fatto contrario. Il Padre sembra abbandonarlo. È
tremendo, è tragico. E Lui cosa fa? Emette un forte grido, ma poi si riabbandona al Padre.
Così dobbiamo fare anche noi in queste circostanze. Sono momenti, penso, che valgono
molto davanti a Dio. Gesù con il suo abbandono ha dato compimento alla Redenzione. Noi,
con il nostro, unito al suo, opereremo la nostra purificazione ed aiuteremo chissà quante
anime. Gesù Abbandonato è veramente la soluzione di ogni problema. In Lui non troveremo
mai delusione, ma piuttosto la spiegazione di tutte le nostre prove. E allora, coraggio! Lo
sguardo fisso su di Lui per superare ogni ostacolo nella corsa della nostra vita.$doc1648$, 'drive_import', '01648-WEB-1986-06-05-guardate-a-ges-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1648)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1649, 'ITA', $doc1649$Mollens (CH), 14.8.1986

CHIAMARLO PER NOME

Carissimi,
Siamo ancora nel mese in cui la Parola (Ebr 12,1-2) ci invita a fare della nostra esistenza una
corsa, puntando lo sguardo su Gesù ed in particolare – abbiamo aggiunto noi – su Gesù
Abbandonato.
E l’ultima volta abbiamo visto come la vita si può considerare una corsa ad ostacoli.
Ma che cosa sono questi ostacoli? Come si possono definire?
È sempre una grande scoperta vedere come ad ogni dolore o prova della vita si può dare in
certo senso il nome di Gesù Abbandonato.
Siamo presi dalla paura? Gesù in croce nel suo abbandono non appare forse invaso dalla
paura che il Padre si sia dimenticato di Lui?
L’ostacolo che possiamo incontrare è in certe dure prove lo sconforto, lo scoraggiamento.
Gesù nell’abbandono sembra sommerso dall’impressione che nella sua divina passione gli
manchi il conforto del Padre e pare che stia perdendo il coraggio di concludere la sua
dolorosissima prova mentre, poi, soggiunge: “Padre, nelle tue mani consegno il mio spirito”
(Lc 23, 46).
Le circostanze ci portano ad essere disorientati? Gesù in quel tremendo dolore sembra non
comprendere più nulla di quanto gli sta succedendo dato che grida “Perché”? (cf. Mt 27, 46;
Mc 15, 34).
Veniamo contraddetti? Nell’abbandono non pare forse che il Padre non approvi l’operato
del Figlio?
Siamo rimproverati, o accusati?
Gesù in croce nel suo abbandono ha avuto forse l’impressione di ricevere un rimprovero,
un’accusa anche dal Cielo. E poi in certe prove che nella vita a volte possono susseguirsi
incalzanti, non si arriva anche a dire desolati: questo sembra troppo, questo è l’oltre
misura? Gesù nell’abbandono ha bevuto un calice amaro non solo colmo, ma traboccante. La
sua è stata la prova oltre misura.

E quando ci sorprende la delusione o siamo feriti da un trauma, o da una disgrazia
imprevista, o da una malattia o da una situazione assurda, possiamo sempre ricordare il
dolore di Gesù Abbandonato che tutte queste prove e mille altre ancora ha impersonato.

Sì, egli è presente in tutto ciò che ha sapore di dolore. Ogni dolore è un suo nome.

Si dice nel mondo che chi ama chiama per nome. Noi abbiamo deciso di amare Gesù
Abbandonato. E allora, per meglio riuscire in ciò, cerchiamo di abituarci a chiamarlo per
nome nelle prove della nostra vita.

Così gli diremo: Gesù Abbandonato-solitudine, Gesù Abbandonato-dubbio, Gesù
Abbandonato-ferita, Gesù Abbandonato-prova, Gesù Abbandonato-desolazione e così via.

E chiamandolo per nome, egli si vedrà scoperto e riconosciuto sotto ogni dolore e ci
risponderà con più amore; ed abbracciandolo diverrà per noi: la nostra pace, il nostro
conforto, il coraggio, l’equilibrio, la salute, la vittoria. Sarà la spiegazione di tutto e la
soluzione di tutto.

Cerchiamo allora in questi quindici giorni di chiamare per nome quel Gesù che incontriamo
negli ostacoli della vita. Li supereremo con più rapidità e la corsa nella nostra esistenza non
conoscerà soste.$doc1649$, 'drive_import', '01649-WEB-1986-08-14-chiamarlo-per-nome-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1649)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1650, 'ITA', $doc1650$Mollens (CH), 28.8.1986

DIAMO GIOIA AL CIELO!

Carissimi,

La Parola del mese di settembre parla di gioia. Essa dice: “C’è gioia davanti agli angeli di Dio
per un solo peccatore che Si converte” (Lc 15, 10).

Gioia nel Cielo! Gioia nuova che fiorisce sulla gioia di cui e gia pieno il Cielo. E perché? Per
un solo peccatore che si converte.

Quanto sono importanti per il Cielo le conversioni!

E qui a noi viene spontaneo pensare subito alla nostra Opera.

L’abbiamo detto tante volte: le attività del Movimento dei Focolari non sono tanto quelle
indirizzate a concretizzare le varie opere di misericordia. L’opera tipica dell’Opera di Maria
non sta tanto nell’erigere istituti per raccogliere orfani o anziani, o drogati, o mutilatini, o
ammalati, o moribondi... come tanto bene fanno innumerevoli famiglie religiose o
associazioni nella Chiesa e come anche noi non trascuriamo di fare, specie attraverso i
movimenti Gioventù Nuova e Umanità Nuova.

Le opere dell’Opera di Maria sono fondamentalmente le conversioni.

Gli innumerevoli ritorni a Dio che si riscontrano in tutto il mondo, dove è diffuso il nostro
Movimento, sono le caratteristiche nostre opere, i nostri frutti.

Li raccogliamo nelle più varie giornate, nelle Mariapoli, con la nostra stessa vita d’unità nei
focolari, nei nuclei, nelle unità-gen, nelle cittadelle... Fioriscono attraverso la nostra stampa
e i nostri mezzi di comunicazione.

Frutti, queste conversioni, che, se sempre ci hanno rallegrato, in questo mese, in cui la
Parola ci dice che una sola di esse fa tale effetto in Cielo, non possono non moltiplicare
anche nel nostro cuore la gioia.

Forse non avevamo mai posto su questo fatto in particolare la nostra attenzione, ma sono
questi i giorni in cui è bene lo ricordiamo sovente.

Sarà tale ricordo che ci spingerà a lavorare alla nostra Opera, in tutti i suoi settori, in tutte le
sue manifestazioni, con zelo rinnovato, con maggior impegno e perfezione.
Pensiamo: una sola conversione quaggiù è gioia lassù! Che sarà per le tante, tante
conversioni che così spesso opera Gesù in mezzo a noi?

La Parola di questo mese non può non metterci la convinzione in cuore che proprio per
questa finalità che ha il Movimento, per i frutti che porta, Gesù e Maria e tutto il Cielo sono
contenti di esso, di tutto quanto facciamo.

Certamente anche noi abbiamo sperimentato che quanto meglio lavoriamo nella nostra
Opera, quanto più preghiamo ed offriamo con amore le nostre sofferenze per essa, tanto più
abbondanti sono i frutti.

E allora sarà facile dare una conclusione a questo nostro pensiero: viviamo in maniera che il
Cielo conosca la più grande gioia aggiunta per tanti peccatori che tornano.

Raggiungeremo questo scopo dedicandoci in modo particolare in questi quindici giorni a
quanti conosciamo personalmente e dando generosamente il nostro contributo alla
particolare attività dell’Opera in cui siamo impegnati.

Il nostro motto allora sarà: “Per dar gioia al Cielo, lavoriamo perfettamente nell’Opera”.$doc1650$, 'drive_import', '01650-WEB-1986-08-28-diamo-gioia-al-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1650)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1651, 'ITA', $doc1651$Mollens (CH), 11.9.1986

LA GIORNATA CON MARIA

Carissimi,

Ci siamo ripromessi la volta scorsa di dedicarci alla nostra Opera con sommo impegno e
perfezione.

Essendo agli sgoccioli del mese di settembre, nel quale abbiamo ben due volte festeggiato
Maria, vogliamo vedere Oggi come rinnovare anzitutto il nostro personale rapporto con lei,
che è a capo del nostro Movimento. Vogliamo esaminarci sui nostri quotidiani contatti con
lei, sul nostro amore verso di lei: vedere in pratica qual è, o meglio, quale deve essere la
nostra giornata con Maria.

Come molti di noi già fanno, sarà bene, appena svegli al mattino, dopo aver puntualizzato lo
scopo per cui viviamo con quel “Perché sei abbandonato” 33, aggiungere: “Perché sei
desolata” come a dire: la mia vita deve svolgersi non solo per amore di Gesù Abbandonato,
ma anche in unione con Maria, la Desolata; la mia vita vuol essere tale che non vadano
perduti, ma anzi valorizzati al massimo, la passione e morte di Gesù ed anche il grande
dolore di Maria, sofferto ai piedi della croce per l’umanità.

Durante il giorno poi, come si sa, abbiamo vari modi di stare con Maria. A lei va un pensiero
particolare durante le preghiere del mattino e della sera. Maria è ricordata nella Messa,
anche alla visita e soprattutto durante la recita del rosario, quando per più di cinquanta
volte la salutiamo con l’Ave Maria.

È tutta bella l’Ave Maria in ogni sua espressione, ma oggi io vorrei suggerire di sottolineare
in questi prossimi giorni, con il cuore, in modo particolare la duplice richiesta: “Prega per
noi peccatori adesso” e “nell’ora della nostra morte”, affinché Maria ci assista con la sua
intercessione presso Dio in ogni nostro attimo presente e perché in quel momento
importante, che è la morte, sia presente presso di noi in modo speciale.

Ma se tutte queste preghiere hanno il loro peso nella nostra giornata, ciò che vorrei mettere
in luce oggi è soprattutto il rapporto che noi dobbiamo avere con Maria, rapporto che deve
essere vivo durante tutto il giorno e sarà sempre più profondo a seconda dell’unità che la
nostra persona avrà raggiunto con questa amatissima Madre e Capo.

Noi, membri dell’Opera di Maria, possiamo anzitutto pensare che, se siamo in questo
Movimento, è perché non solo Dio ci ha scelti, ma anche Maria con Lui. Noi, ciascuno di noi,
senz’altro un giorno è stato guardato con amore particolare da lei e portato qui.
Possiamo poi pensare che lei ci ha orientati alla sua Opera perché, avendoci amato, vuole
dimostrarsi con noi, in modo tutto particolare, Madre.
Ora cosa fa una madre per il suo figliolo? Lo sappiamo: fa tutto senza misurare.
Ebbene, se così è della madre terrena, che sarà della Madre celeste?
Noi dobbiamo essere convinti del suo specialissimo amore e trarne le conclusioni. Maria mi
ama? Anzi mi ama in modo particolare? Non posso non avere una fiducia sconfinata in lei
che tanto può. E allora le affiderò tutto quello che mi riguarda, non solo me stesso, ma i miei
pensieri, le mie preoccupazioni, ciò che mi pesa, ciò che mi fa male. Lei vuole per sé tutto
questo, ed è in grado di risolvere ogni mio problema.
Carissimi, vi dico queste cose perché ho sperimentato che la Mamma nostra, se noi
prendiamo sul serio il suo amore per noi, non manca di dimostrarcelo.
Provate anche voi. Forse l’avete già fatto.
Provate a non tener nessun peso sul cuore e ad affidare tutto a lei. Troverete risolto un
problema dietro l’altro.
Infine, io desidererei s’introducesse nella nostra vita d’unione con Maria una bella
abitudine.
Sapete come fra noi ravviviamo la presenza di Gesù in mezzo dichiarandoci: “Teniamo Gesù
in mezzo”. Ora perché non far questo anche con Maria? Ciò comporta essere pronti a morire
per lei come lei lo è stata per noi. E comporta essere pronti a morire per lei misticamente
presente nella sua Opera.
Chissà come sarà contenta Maria di aver la possibilità di dare con noi nuovamente vita a
Gesù, anche se solo spiritualmente.
Io ho provato quanto è bello poi e meraviglioso alla sera chiudere gli occhi dopo averle
detto: “Teniamo Gesù in mezzo”.
Ecco, carissimi, due parole sulla nostra giornata con Maria. Che lei ci faccia sentire tutto il
suo materno affetto e ci custodisca come le pupille dei suoi occhi.
Per i prossimi giorni dunque: Ravviviamo la nostra unità con Maria.

Mollens (CH), 25.9. 1986
LO STILE DELL’OPERA DI MARIA È L’AMORE
Carissimi,

Abbiamo visto ultimamente come il Cielo ami e goda per le conversioni. E ci siamo perciò
impegnati a lavorare con perfezione nella nostra Opera, che porta tali frutti. Abbiamo
cercato anzitutto in questi ultimi quindici giorni di perfezionare il nostro rapporto con colei
che è capo e prima fondatrice del nostro Movimento: Maria.

Vediamo oggi quale deve essere lo stile del nostro agire nell’Opera.

Incomincia un nuovo anno ideale, e per adempiere con diligenza ai nostri doveri avremmo
bisogno di un grande corredo di virtù. Anche san Paolo, con la Parola di Vita di questo mese,
ci invita a non essere timidi nel servire Dio, ma forti, pieni di amore e di saggezza. Ora su che
cosa puntare per acquistare e sviluppare queste e tutte le altre virtù che ci sono necessarie?

È semplice, e il nostro ideale ha la sua risposta: lasciar vivere Gesù in noi al posto del nostro
io.

Ma quale il modo perché Gesù viva in noi? Essere amore come Dio è Amore (cf. 1 Gv 4, 16).
Buttarci quindi fuori di noi ad amare gli altri.

Noi parliamo sempre d’amore e potrebbe sembrare superfluo sottolinearlo anche questa
volta. Ma non è così. L’“uomo vecchio” (cf. Ef 4, 22) – il non amore – è sempre pronto a
prendere il sopravvento in noi ammantato magari di mille scuse. Il nuovo anno che iniziamo
deve veder splendere decisamente nelle nostre persone l’“uomo nuovo” (cf. Ef 4, 24). Allora
agiremo bene là dove siamo; porteremo avanti e costruiremo l’Opera e, con essa, la Chiesa.

Torniamo, quindi, a ciò che è l’alfa della nostra spiritualità: l’amore. È questo del resto il
nostro carisma. Ed è questo l’elemento di cui il mondo anche oggi ha più bisogno.

Guardiamoci intorno. Dove troviamo l’amore che Gesù ha portato sulla terra? Per le strade,
nei negozi, nei bar, negli uffici, dappertutto gli uomini si passano accanto, ma indifferenti gli
uni verso gli altri. Leggiamo i giornali: le cronache vertono quasi sempre su episodi tristi, di
violenza. C’è sì l’amore umano che lega ancora molte famiglie e stringe le amicizie, ma è
difficile trovare l’amore cristiano. Lo possiamo scoprire in qualche oasi spirituale fra
persone consacrate o comunità di cristiani impegnati. Nel mondo, però, in genere non si
riscontra.

E noi siamo stati suscitati da Dio e scelti, assieme ad altri, proprio per portare questo amore.
È il dono, il grande dono che dobbiamo fare all’umanità.

È vero: siamo tanti, ma siamo anche tanto pochi in confronto alla popolazione del mondo. E
poi Dio ci ha diffuso dappertutto, ed è per questo che essendo così sparsi per il mondo,
raramente possiamo dare una testimonianza globale su larga scala di quella che è
veramente la natura del cristiano, del suo essere amore.
Ma non perdiamoci di coraggio!

Se Dio ha steso con noi una rete su tutta la terra, verrà il tempo in cui essa s’infittirà sempre
di più ed il mondo avrà più facilmente modo, anche per mezzo nostro, di costatare il fuoco
che Gesù ha portato sulla terra.

Esso sarà una realtà domani se oggi noi siamo quelli che dobbiamo essere. Dobbiamo essere
amore, proprio ciò che il mondo non è.

È l’amore lo stile dell’Opera di Maria. Buttiamoci fuori, allora, ad amare! E rimaniamo in
questa tensione. Partiamo decisi. Ingraniamo la marcia nell’Opera: riaccendiamo l’amore nel
nostro cuore. Perché il mondo conosca presto dovunque l’amore vero, buttiamoci ad amare!$doc1651$, 'drive_import', '01651-WEB-1986-09-11-la-giornata-con-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1651)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1652, 'ITA', $doc1652$Rocca di Papa, 9.10.1986

VIVERE IL PRESENTE ALLA PERFEZIONE

Carissimi,

Uno degli avvenimenti di maggior rilievo in questi ultimi quindici giorni è stata la partenza
improvvisa e inaspettata di Lionello per la Mariapoli Celeste. Lionello: uno dei focolarini più
maturi e più preparati dell’Opera di Maria; un focolarino a cui l’Opera deve tanto per
l’esempio della sua vita cristallina, così soprannaturale, distaccata dalle cose di questa terra,
tutta dedita al servizio di Dio e dei fratelli.

È stata la sua una partenza improvvisa ed inaspettata non solo per noi, ma anche per lui, che
ci fa ritornare con il pensiero ad altre partenze ben diverse perché a lungo preparate, come
quella di Luminosa, di Margrit, di Marilen. C’è, dunque, anche fra i nostri, chi compie il suo
Santo Viaggio dopo lunga attesa e chi lo compie in un baleno, quando meno se l’aspetta.

E allora vien da chiedersi: Come sarà per noi? E torna spontaneo concludere: è bene essere
sempre preparati. In che maniera? Rimanendo in grazia di Dio e vivendo con pienezza
l’attimo presente.

E stato per questo, per la partenza di Lionello avvenuta così, che ho desiderato in questi
ultimi giorni fissare ancora la mia attenzione proprio su quell’aspetto così tipico della
nostra spiritualità che consiste nel concentrarsi a vivere il momento presente. E con il
pensiero sono riandata a tante frasi colte ad esempio, dai santi, che ci spronano a metterlo
in pratica alla perfezione.

Ricordate?

Diceva Caterina da Siena: “La fatica che è passata noi non l’abbiamo, però ch’è fuggito il
tempo; quel ch’è a venire, non l’abbiamo, però che non siamo sicuri di avere il tempo”. E così
invitava a vivere il presente.

E Teresa di Lisieux: “Tu lo sai, mio Dio, che per amarti [...] non ho altro che l’oggi”.

E ho ricordato anche un motto che ci è stato utile nel passato e che ricordavamo facilmente
perché ogni sua parola, in italiano, comincia con la s: “Sarò santa se sono santa subito”.

Ma, sempre in questi giorni, ho notato che questo modo di vivere la vita è caro anche ad altri
santi, che lo consigliano con calore.
“Fortunata quell’anima – scriveva Paolo della Croce – che riposa “in sinu Dei”, senza pensare
al futuro, ma procura di vivere momento per momento in Dio, senz’altra sollecitudine che di
far bene la sua volontà in ogni evento...”. “Fortunata quell’anima...”.

Noi possiamo far nostra questa fortuna, perché è della nostra spiritualità vivere così.

È vivendo il presente che si possono adempiere bene tutti i nostri doveri.

È vivendo il presente che le croci diventano sopportabili: non per nulla si consiglia questa
pratica a coloro che s’avvicinano alla morte.

È vivendo il presente che si possono cogliere le ispirazioni di Dio, gli impulsi della sua grazia
che arrivano nel presente.

È vivendo il presente che possiamo costruire con frutto la nostra santità. Diceva Francesco
di Sales: “Ogni attimo viene carico di un ordine e va a sprofondarsi nell’eternità per fissarne
ciò che ne abbiamo fatto”. Viviamo, dunque, il presente! Era da un po’ di tempo che non
sottolineavamo questo nostro dovere. Ringraziamo Lionello di avercelo ricordato con la sua
partenza. Viviamo il presente alla perfezione! Ci troveremo alla sera di ogni giorno ed alla
sera della vita carichi di opere buone compiute e di atti d’amore offerti. Ricordiamo: vivere
il presente alla perfezione.$doc1652$, 'drive_import', '01652-WEB-1986-10-09-vivere-il-presente-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1652)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1653, 'ITA', $doc1653$Rocca di Papa, 23.10.1986

RINNOVARE L’AMORE RECIPROCO

Carissimi,

I responsabili delle zone hanno dunque concluso il loro incontro e sono tornati da voi nei
vari Paesi.

Ora il loro primo compito – e so che in alcune zone è già iniziato – sarà quello di mettervi al
corrente su tutto quanto si è visto al Centro: programmi, aggiornamenti, sviluppi, direttive...
Dovranno farvi partecipi anche degli avvenimenti vissuti qui, come il passaggio alla
Mariapoli celeste del nostro Lionello.

Quale dovrà essere il vostro atteggiamento perché queste informazioni portino frutto in
voi?

È evidente: occorre preparare il terreno nelle vostre anime e nelle varie comunità.

Come? Ributtandovi a vivere con pienezza l’Ideale, la nostra spiritualità.

E per questo ci aiuta assai bene la Parola di Vita di novembre. Essa dice: “Gettiamo via le
opere delle tenebre e indossiamo le armi della luce” (Rm 13, 12).

Le “opere delle tenebre” sono i frutti dei vizi e del peccato. Le “armi della luce” sono le virtù,
le applicazioni nella vita delle Parole di Dio.

Ora noi sappiamo che il Comandamento nuovo di Gesù è un po’ il riassunto di tutti i
comandi di Gesù, di tutte le sue Parole.

Indosseremo quindi le “armi della luce” rimettendo a fuoco nella nostra vita questo
comando.

Per esso – lo sappiamo – risplenderà il Risorto in mezzo alla nostra comunità, e non c’è
nessun miglior terreno per ricevere quanto vi verrà offerto, di quello in cui egli è presente:
con Lui fra voi tutto sarà accolto con cuore aperto. Senz’altro chi ha costruito di più, anche
con i vostri responsabili nel mese di ottobre a Rocca, è stato Gesù in mezzo a noi. Ed è la sua
fiamma, la sua luce che va ora portata in zona.

Ma se questa fiamma troverà un’altra fiamma, se questa luce troverà un’altra luce, l’Opera in
zona potrà sperare veramente quello sviluppo che Dio ha pensato per essa nell’anno ideale
che iniziamo.
“Armi di luce” dunque. Comandamento nuovo attuato con nuovissimo impegno. E il nuovo
anno, che ci accingiamo a vivere, sarà un anno autentico di Santo Viaggio.

Qui al Centro, prima di cominciare a lavorare, ci siamo proposti fra tutti noi di vivere l’ ’86-
’87 come l’anno più santo della nostra vita. Ed abbiamo deciso, perché ciò diventi una realtà,
d’essere sempre il pensiero del Collegamento vivo.

É questo un invito che allargo a tutti voi.

E, per cominciare subito, analizziamoci un po’ sul nostro amore vicendevole: consideriamo
la misura di questo nostro amore (ricordando che deve essere quella di Gesù per noi: quindi
essere pronti a dare la vita), evidenziamo la nostra poca generosità, i nostri limiti
nell’attuarlo, per superarli; osserviamo se l’amore reciproco non sia un po’ troppo umano e
quindi da riportare su un piano più soprannaturale...

Così facendo, migliorandolo in questo modo, Gesù, il Santo, sarà fra noi ed egli potrà fare
dell’attuale anno il più santo della nostra vita.

Amore reciproco, dunque, rinnovato in pieno per accogliere bene gli aggiornamenti, per
vivere la Parola di Vita, per essere santi.

Questo l’impegno dei prossimi quindici giorni.$doc1653$, 'drive_import', '01653-WEB-1986-10-23-rinnovare-l-amore-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1653)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1654, 'ITA', $doc1654$Rocca di Papa, 4.10.1984

UN COMANDAMENTO VECCHIO E NUOVO

Carissimi,

Un saluto con tutto il cuore anche oggi ed un ardente augurio di un ottimo Santo Viaggio.

Sì, perché la cosa più importante è questa: condurre santamente i nostri giorni e concluderli
ancor più santamente come certi nostri fratelli e sorelle che Dio ha chiamato all’Altra Vita
anche in questi giorni.

Così è stato per Beppe Borla, per Nick, un meraviglioso focolarino sposato delle Filippine
che dobbiamo tubi ricordare e imitare.

In questo mese d’ottobre seguiamo la Parola: “Date a Cesare quello che è di Cesare e a Dio
quello che è di Dio” (Mt 22, 21).

Se nei primi quindici giorni abbiamo cercato di dare con grande amore a Cesare quello che è
di Cesare, in questa seconda metà del mese ci sforzeremo di dare a Dio quel che è di Dio.
Dare a Dio quel che è di Dio.

Di fronte ai nostri mariapoliti celesti che ci avvertono che la vita non è poi tanto lunga e che
presto, anche per noi, può venire il passaggio, nasce il desiderio di conoscere quale sia il
modo migliore di dare a Dio quello che è di Dio. È la domanda del resto che ci facevamo noi
prime focolarine che, sempre di fronte alla morte per la guerra, volevamo conoscere il modo
migliore di amare Dio.

E la risposta la conosciamo tutti: far la volontà di Dio, che in modo tutto speciale ci domanda
di praticare il Comandamento nuovo di Gesù.

Questa risposta è sgorgata nuovamente con grande impeto dal mio cuore la settimana
scorsa, mentre stavo ad Istanbul.

Lì, trovandomi a contatto così diretto col cuore della Chiesa ortodossa, che qualcuno
definisce “giovannea”, perché la sua spiritualità attinge molto al pensiero di san Giovanni,
meditavo ogni giorno la prima lettera di questo evangelista. E, come già altre volte, ho
provato una grande impressione costatando quanto egli sottolinei il Comandamento nuovo
sì da parlarne come del comando di Gesù per eccellenza.

Giovanni definisce questo comando “vecchio” e nello stesso tempo lo dice “nuovo” (cf. 1 Gv
2, 7).
“Vecchio” perché lo abbiamo, come dice la lettera, “da principio”, da quando siamo cristiani
e cioè credenti e battezzati. Ma “vecchio” anche perché – così spiega un commentatore –
come Gesù stesso, Verbo incarnato, che l’ha dato, questo comando deriva dall’originaria vita
divina, è basato sulla natura stessa di Dio, sull’amore.

E “nuovo” perché Gesù, vivendolo in modo così sublime con la sua morte in croce, lo ha
come ravvivato, illuminato, ripresentato al mondo.

Meditando su tutto ciò ho costatato ancora una volta, con immensa gratitudine, come lo
Spirito Santo ci abbia guidato bene; come fra le mille e mille strade che potevamo
intraprendere ci abbia indicato la strada, il cuore del cristianesimo, quel comandamento alla
cui realizzazione tutti gli altri concorrono.

E un desiderio ardente, che vorrei comunicarvi, di viverlo sempre meglio, cercando di
perfezionarlo, puntando qui tutto lo sforzo ascetico della rinuncia cristiana di cui dobbiamo
rivestirci, perché amare così non è cosa semplicemente naturale, ma soprannaturale.

Come dare allora a Dio quel che è di Dio?

Riconvertendoci ogni momento al Comandamento nuovo, non con le parole, ma con i fatti.
Potremo rassicurare la nostra coscienza d’aver fatto abbastanza, d’aver fatto tutto.$doc1654$, 'drive_import', '01654-WEB-1984-10-04-un-comandamento-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1654)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1655, 'ITA', $doc1655$Rocca di Papa, 18.10.1984
LA CARITÀ È MORIRE
NON SOLO ESSER PRONTI A MORIRE

Carissimi,
Riprendiamo oggi il nostro Collegamento per aiutarci ad accelerare la corsa nel Santo
Viaggio.
La Parola di Vita del mese dice: “Al di sopra di tutto poi vi sia la carità, che è il vincolo della
perfezione” (Col 3, 14).
È una frase di Paolo.
Ma cosa intende egli con le parole: “al di sopra di tutto”? Per spiegare la condotta del
cristiano, l’apostolo ama spesso far l’esempio delle vesti che il seguace di Cristo deve
indossare. Ricordate? “...cinti i fianchi con la verità, rivestiti con la corazza della giustizia”
(Ef 6, 14).
E anche nella Parola attuale parla delle virtù, che devono prendere posto nel nostro cuore,
come di tanti capi di vestiario. Esse sono: la misericordia, la bontà, l’umiltà, la
mansuetudine, la pazienza, la sopportazione, il perdono.
Ma “al di sopra di tutto – dice, pensando ad una cintura che lega tutto insieme e dà
perfezione all’abbigliamento – vi sia la carità”.
Sì, la carità; perché non basta per un cristiano esser buono, misericordioso, umile,
mansueto, paziente... Egli deve avere per i fratelli la carità.
Ma la carità – può obiettare qualcuno – non è forse esser buoni, misericordiosi, pazienti,
saper perdonare?
No: la carità ce l’ha insegnata Gesù. Essa ci fa morire per gli altri. Notate: morire. Non: esser
pronti a morire. Ma proprio: morire. Morire spiritualmente, rinnegando noi stessi per
“vivere gli altri”. O anche morire fisicamente, se occorre.
La carità infami non è una prontezza a dar la vita. È dar la vita.
L’odio toglie la vita al fratello (“chi odia è omicida”, 1 Gv 3,15), l’amore dà la vita al fratello.
Ogni cristiano, solo se muore sempre a se stesso per gli altri ha la carità.
Ma se ha la carità – dice Paolo – sarà perfetto e ogni altra sua virtù acquisterà la perfezione:
“Al di sopra di tutto poi vi sia la carità, che è il vincolo della perfezione”.

Carissimi, certamente anche noi abbiamo una certa abitudine ad esser ben disposti verso i
nostri fratelli. Anche noi sopportiamo, perdoniamo. Ma, se ben osserviamo, quello che
spesso ci manca è proprio la carità. Pur con le più sante intenzioni, la natura ci porta sempre
a ripiegarci su noi stessi e, di conseguenza, nell’amare gli altri usiamo le mezze misure.

Ma non si è cristiani se si è solamente così.

Occorre mettere il nostro cuore nella massima tensione. Di fronte ad ogni prossimo che
incontriamo nella nostra giornata (in famiglia, al lavoro, dappertutto) dobbiamo dire a noi
stessi: “Su, coraggio, è il momento di morire”. E così si vive non pensando a noi, ma
pensando agli altri, vivendo gli altri.

Voi sapete come il nostro Movimento considera una pietra miliare nella propria storia
(dopo aver compreso in maniera nuova il Comandamento nuovo di Gesù) quel patto che
hanno formulato le prime focolarine: guardandosi in faccia tra loro hanno detto: “Io sono
pronta a morire per te [intendendo: io morirò per te]. Io per te. Ognuna per ciascuna”.

Quel patto è diventato, in seguito, come la natura della nostra Opera.

Ebbene, noi siamo chiamati tutti ad essere con la vita la sua realizzazione.

E allora, in questo mese in cui la Parola ci invita nuovamente a rivestirci della carità,
cerchiamo, soprattutto quando ci accostiamo alla Santa Comunione, di riformulare quel
patto: “Io, Gesù, col tuo aiuto, morirò a me stesso di fronte ad ogni fratello, cominciando da
chi condivide il mio ideale”.

Se così faremo con tutto il cuore e cercheremo di esservi fedeli con i fatti, vedremo fiorire
con rinnovato impulso attorno a noi, in ogni luogo, la rivoluzione cristiana, perché – lo
sappiamo – il Risorto risplenderà fra noi. E allora coglieremo frutti e frutti degni d’un Dio:
conversioni e conversioni, vocazioni e vocazioni. Concorreremo con ciò ad attuare il
mandato del Santo Padre: “Crescete e moltiplicatevi”.$doc1655$, 'drive_import', '01655-WEB-1984-10-18-la-carit-morire-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1655)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1656, 'ITA', $doc1656$Rocca di Papa, 6.12.1984

LA CARITÀ È CIÒ CHE CONTA

LA CARITÀ È CIÒ CHE RESTA

Carissimi,

Ho provato una nuova gioia in questi giorni leggendo gli Statuti del nostro Movimento. Ho
costatato, infatti, come Dio ci tiene in linea, perché lì è scritto che il fine generale della
nostra Opera è proprio la carità, anzi la perfezione della carità.

E voi sapete come noi parliamo spesso di carità spontaneamente, quasi avvertendo che nella
carità sta tutto ciò che Dio vuole da noi.

Ora mi rendevo nuovamente conto (forse per la millesima volta, ma era come fosse la
prima) che Dio esige da noi proprio la carità: lo dicono le norme che noi abbiamo scritto e la
Chiesa ha suggellato come nostra linea di vita. Esse ci avvertono che noi siamo chiamati
anzitutto a dare al mondo uno spettacolo di carità perfetta, di quella carità che è amore
verso Dio e trova la sua verifica nell’amore verso il prossimo.

Anche nel Collegamento precedente abbiamo parlato di carità ed essa ha colpito molti di
noi, quando abbiamo compreso che amare il prossimo non significa esser pronti a morire
per lui, ma morire realmente, non essere noi stessi cioè per essere l’altro, per vivere gli altri.

E l’impressione è stata cosi forte e così salutare che ho dubitato se fosse o no il caso di
proporre oggi un nuovo pensiero per il nostro cammino. Ho dubitato, ma poi mi sono
convinta che è bene fermarsi lì per assimilare ancor più quel concetto e provare e riprovare
a metterlo in pratica.

Allora, in questo Collegamento, perché la nostra decisione a morire completamente a noi
stessi di fronte ad ogni prossimo acquisti nuovo vigore, voglio vedere con voi, assieme a due
grandi santi che hanno concluso con successo il Santo Viaggio: Sant’Agostino e san
Girolamo, l’importanza della carità.

Sono idee, le loro, che hanno impressionato la mia anima e così, spero, sarà della vostra.

Agostino, maestro di carità, chiarisce: “Se tutti si segnassero con la croce, se rispondessero
amen e cantassero l’alleluja; se tutti ricevessero il battesimo ed entrassero nelle chiese, se
facessero costruire i muri delle basiliche, resta il fatto che soltanto la carità fa distinguere i
figli di Dio dai figli di Satana.

Quelli che hanno la carità sono nati da Dio, quelli che non l’hanno non sono nati da Dio. É
questo il grande criterio di discernimento. Se tu avessi tutto, ma ti mancasse quest’unica
cosa, a nulla ti gioverebbe ciò che hai; se non hai le altre cose, ma possiedi questa, tu hai
adempiuto la legge...”.

E Girolamo scrive: “Ti domando: tu hai la percezione del passaggio dall’infanzia alla
fanciullezza, alla giovinezza, alla maturità e alla vecchiaia? Ogni giorno si muore un po’, ogni
giorno subiamo trasformazioni e, malgrado ciò, viviamo con l’illusione di essere eterni.
Queste stesse cose che sto dettando, che vengono scritte e che poi rileggo e correggo, son
tutti momenti che mi restano in meno da vivere. Ogni punto che l’amanuense segna sulla
pagina, è un punto tolto alla curva della mia vita. [...] L’unico vero guadagno che resta è la
nostra unità nell’amore di Cristo”.

Carissimi, avete sentito?

La carità per noi cristiani è ciò che conta, come afferma Agostino; è ciò che resta, come dice
Girolamo.

Cosa dobbiamo dedurre?

Quando, durante il giorno, sentiamo che il nostro cuore dà peso ad un particolare o ad un
altro: a far bella figura, a salvare la faccia, ad un affetto, ad un attaccamento, a giudizi,
pensieri, sentimenti, persone, a noi stessi... abituiamoci a scartare, ad eliminare ogni cosa
dicendo in cuor nostro: “Questo non vale, quest’altro non vale” sì da non riempirci di vanità.

Quando, invece, troviamo l’occasione per mettere in pratica la carità, diciamo nel nostro
intimo: “Questo ha valore, questo conta, questo dura”.

Così vivremo la nostra vocazione di cristiani autentici e di membri dell’Opera di Maria. Così
ci rivestiremo di quel capo di vestiario menzionato da Paolo nella Parola del mese: “Sopra
ogni altra cosa abbiate la carità, che è il vincolo della perfezione” (Col. 3,14).$doc1656$, 'drive_import', '01656-WEB-1984-12-06-la-carit-ci-che-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1656)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1657, 'ITA', $doc1657$Rocca di Papa, 20.12.1984

1985

PRENDERE L’INIZIATIVA

Carissimi,

Il nuovo anno si apre con una splendida parola: “Ma Dio, ricco di misericordia, per il grande
amore con il quale ci ha amati, da morti che eravamo per i peccati, ci ha fatti rivivere con
Cristo” (Ef 2, 4-5).

Il commento a questa Parola, che forse avrete già letto, sottolinea due caratteristiche
dell’amore di Dio nei nostri confronti. La prima è che l’amore di Dio ha preso l’iniziativa e ci
ha amati quando noi eravamo tutt’altro che amabili (“morti per il peccato”). La seconda è
che Dio col suo amore non si è limitato a perdonare i nostri peccati ma, amandoci in modo
illimitato, s’è spinto fino a parteciparci la sua stessa vita (“ci ha fatti rivivere con Cristo”).

Carissimi, queste parole e queste considerazioni mi fanno ricordare l’inizio del Movimento,
quando Dio ha acceso nel nostro cuore la scintilla (direbbe il Papa) del nostro grande ideale.
Alla luce, infatti, di questa splendida Parola, mi rendo conto come quella scintilla o quel
fuoco non erano che partecipazione all’Amore stesso che è Dio.

Forse che noi, allora, nello squallore della guerra e nel deserto che ci circondava, trovavamo
qualcun altro che prendesse l’iniziativa di amarci?

Non eravamo noi che, per un dono particolare di Dio, accendevamo la fiamma dell’amore in
moltissimi cuori col desiderio di farla divampare in tutti? Guardavamo, forse, se i prossimi
erano amabili per poterli amare o ci attiravano piuttosto i più poveri nei quali meglio
ravvisavamo il volto di Cristo o i peccatori, che più avevano bisogno della sua misericordia?

Sì, per un miracolo divino (quei miracoli che succedono ogni volta che s’accende un carisma
dello Spirito su questa terra) anche il nostro piccolo cuore poteva affermare d’esser ricco di
misericordia.

E, come si sa, amare i prossimi non significava per noi semplicemente farsi uno con loro fino
a portarli a Dio. Significava coinvolgerli nella nostra rivoluzione d’amore, nel nostro stesso
ideale. Tutti candidati all’unità, potevano partecipare e partecipavano di fatto a quella
dinamica divina vita che Dio aveva scatenato in un punto della sua Chiesa. Così era allora.
Così deve essere anche ora. Certamente i tempi sono cambiati, ma non è difficile ammettere
che, se in quei lontani giorni il mondo appariva un deserto per le distruzioni della guerra,
non meno deserto è pure ora, anche se per altri motivi.
Molti fattori hanno determinato un livellamento della nostra società moderna, per cui si
vive in un pericoloso equivoco.

Una volta la società era fondamentalmente cristiana e si distingueva molto nettamente il
bene dal male.

Oggi è diverso: in nome d’una libertà, che non è vera libertà, bene e male, osservanza della
legge di Dio e non osservanza sono messi sullo stesso piano. È un nuovo deserto, dove ciò
che è stato bombardato non sono le case, le chiese, i palazzi, ma le leggi morali e di
conseguenza le coscienze.

E allora che fare? Siamo senz’armi a combattere la nostra battaglia per portare il perdono e
l’amore di Cristo agli uomini quand’essi fanno sì poco calcolo del peccato?

No, non siamo senz’armi.

Questo mondo sconsacrato ha per noi un volto: è quello di Gesù Abbandonato, in cui il sacro
e il divino s’è tutto celato.

Egli poi, Dio che si sente abbandonato da Dio, rispecchia ogni situazione negativa.

È in nome e per amore di Lui che troveremo la forza di amare ciò che oggi è tanto poco
amabile.

Con la fiamma accesa nel nostro cuore, prendendo anche noi sempre come il nostro Dio
l’iniziativa, avvicineremo quanti incontreremo. E Dio in noi risveglierà, illuminerà le
coscienze, susciterà compunzione, ridarà speranza, infiammerà d’entusiasmo sì da mettere
in molti il desiderio, da morti che erano, di rivivere con Cristo, di vivere Cristo.

Questi tre propositi, dunque, mette in cuore la Parola del mese di gennaio: tenere acceso il
fuoco nel nostro cuore, amare per primi, amare in modo non limitato ma sconfinato: in
modo cioè da portare tutti a vivere il nostro ideale, che è vivere Cristo.

Solo a questo livello siamo in linea con quanto la Scrittura ci chiede in questo mese.

Concludo facendo a tutti gli auguri più fervidi d’un santo anno nuovo, ricco di grazie. È il
quarto del nostro Santo Viaggio.$doc1657$, 'drive_import', '01657-WEB-1984-12-20-prendere-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1657)
on conflict (document_id, language) do nothing;
