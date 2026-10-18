-- 102_import_italian_originals_part03.sql (3/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1598-1617 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1598, 'ITA', $doc1598$Rocca di Papa, 16.6.1983

UN AMORE EROICO: NIENTE DI MENO

Carissimi,

Ci siamo lasciati l'ultima volta col desiderio di vivere con deciso impegno l'amore del
prossimo. E, come ho saputo, è stata questa la spinta per molti a costruire con grande amore
le straordinarie Mariapoli di cui mi sono arrivati da tutto il mondo echi su echi. Oggi
desidero parlarvi ancora d'amore e proprio d'amore al prossimo.

Come deve essere questo amore perché sia conforme a quanto Gesù esige da noi?

Lo sappiamo: un amore che ha come misura la morte: esser pronti a morire per gli altri, per
ogni prossimo.

Un amore eroico dunque: niente di meno. Questa è la carità: “... come io ho amato voi”. Ed è
proprio in un simile amore, concepito e vissuto in questa maniera, che noi del Movimento
dei Focolari troviamo la via per santificarci nella vita: dunque il nostro tipico modo per far
di essa un Santo Viaggio.

Il fatto è che, amando il prossimo così, tutta la nostra vita spirituale secondo la spiritualità
dell'unità ne guadagna. Ed è questa la scoperta che ho fatto in questi giorni in cui mi sono
sforzata di vivere anch'io così, scoperta che vorrei comunicarvi.

Voi sapete come una spiritualità è un modo di vivere il cristianesimo, è una vita. E una vita
ha mille aspetti.

Tuttavia nella nostra spiritualità noi ne consideriamo in genere una diecina e questi – ci
sembra – li riassumono tutti.

Sono: Dio Amore, la volontà di Dio, l'amore al prossimo, l'amore reciproco, Gesù in mezzo e
l'unità, Gesù Abbandonato, la Parola di Dio, Maria, la Chiesa, lo Spirito Santo.

Ebbene, in questi giorni ho compreso che amando il prossimo realizzo meglio tutti gli altri
aspetti della nostra spiritualità.

Amando il prossimo così, faccio infatti veramente mio l'Ideale Dio-Amore, perché sono
anch'io in questo modo un po': "amore".

Amando il prossimo così, compio la sua volontà che per me è proprio concentrata anzitutto
qui. La sola base, infatti, su cui posso costruire ogni altra cosa è la carità verso i fratelli,
senza la quale nulla ha valore.

Facendo così, centro proprio il terzo punto della mia spiritualità che è amare il prossimo.
Amando così, compio tutta la mia parte per realizzare l'amore reciproco.

Amando così, faccio tutto quanto sta in me per mettere Gesù in mezzo e attuare l'unità

Amando il prossimo in questo modo, amo veramente Gesù abbandonato, perché la sola
misura del mio amore è Lui

Se amo il prossimo così, presto o tardi mi vien spontaneo tener presente e valorizzare la
Parola di Vita, perché ognuna serve all'amore, è amore, e mi spiega le molte sfaccettature
dell'amore.

Amando così, vivo veramente come altra Maria, perché la via dell'amore è la sua vita, la “Via
Mariae”, come noi l'abbiamo chiamata. E, come Lei, non pensando che ad amare, pratico le
virtù implicite alla carità: la pazienza, la misericordia, l'obbedienza, la povertà, perché dono
e mi dono, la mortificazione, perché penso ad altro e non a me stessa, ecc.

Amando così, vivo la Chiesa e per la Chiesa, perché concorro ad edificarla con l'unità e
perché, per la Comunione dei Santi, aiuto gli altri a sollevarsi.

Amando così, onoro veramente lo Spirito Santo perché gli obbedisco nel tipico carisma che
mi ha dato. Carissimi, amiamo, dunque. Il fratello, i fratelli sono la nostra grande occasione.
Non perdiamone una, durante tutto il giorno.

Amiamo quelli che siamo soliti prendere in considerazione, perché li vediamo fisicamente
accanto a noi. Amiamo quelli che magari sfuggono alla nostra osservazione: coloro ad
esempio di cui parliamo o si parla, che ricordiamo, o per i quali preghiamo; coloro di cui
veniamo a conoscere qualche notizia sul giornale, o alla TV; quelli che ci scrivono o ai quali
scriviamo; coloro ai quali è destinato il lavoro che ci occupa giorno per giorno...

Amiamo i vivi e quelli che non sono più qui sulla terra.

Amiamo i fratelli singolarmente e collettivamente: amiamo, quindi, e rispettiamo
sommamente ogni popolo.

Tutti amiamo con amore eroico: non di meno.

Ne vedremo gli effetti eccezionali: di luce e di gioia! E con l amore il suo Regno sarà in noi,
sarà fra noi come vuole la Parola di Vita di questo mese.$doc1598$, 'drive_import', '01598-WEB-1983-06-16-un-amore-eroico-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1598)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1599, 'ITA', $doc1599$Sierre, 4.8.1983

L’AMORE DEL PROSSIMO E LE DODICI STELLE

Carissimi,

Eccoci di nuovo collegati. In questi quindici giorni trascorsi ho avuto modo di
costatare come l’amore al fratello sia profondamente sentito da tutto il nostro
Movimento e quanto sia efficace la sua attuazione. Leggendo, infatti, i moltissimi
telegrammi giuntimi per la festa di santa Chiara, ho potuto notare, con grande gioia
e consolazione, sotto tutte quelle parole augurali, un così intenso entusiasmo
soprannaturale e un tale fuoco d’amore da avere una ulteriore riprova che siamo
veramente sulla strada più indicata.
E giacché le cose stanno così, continueremo anche oggi sullo stesso argomento.

Vi ho già detto come, praticando eroicamente la carità verso il prossimo, tutta la nostra vita
spirituale ci guadagna.

Oggi, invece, vedremo come non solo la tipica vita spirituale dei membri del Movimento
avanza con l’amore al prossimo, ma anche come chi è chiamato per altra strada può trovare
proprio lì la molla per progredire nella perfezione.

Ricordate le 12 stelle di san Giovanni della Croce? In chi è perfetto, secondo lui, in chi è
santo, e cioè in coloro che hanno compiuto nella vita il Santo Viaggio, brillano nell’anima
dodici stelle. Esse sono: l’amor di Dio, l’amor del prossimo, la castità, la povertà,
l’obbedienza, l’orazione, il coro (cioè la preghiera in comune), l’umiltà, la mortificazione, la
penitenza, il silenzio e la pace.

Ebbene in questi giorni ho potuto costatare come, amando il prossimo, queste dodici stelle
splendano meglio nell’anima nostra. E per convincerci meglio passiamole in rassegna ad
una ad una.

L’amore di Dio. Diviene più vivo questo amore nel nostro cuore, amando il prossimo?
Certamente sì. Vi è noto l’esempio della pianticella che, più affonda le radici nel terreno, più
si lancia verso il sole. Così, più amiamo il prossimo, più brilla in noi la stella dell’amor di Dio.

Seconda stella: l’amor del prossimo: è proprio ciò che vogliamo praticare bene.

Terza: la castità. Lo stesso Statuto del Movimento dice che la migliore salvaguardia della
castità è l’amore del prossimo. E lo si capisce: se si ama, si pensa agli altri e non si
accontentano le proprie passioni. Quarta stella: la povertà. Noi – come tutti sappiamo – non
amiamo la povertà per se stessa. La tipica povertà dei membri del Movimento è proprio
quella che nasce dal dare al prossimo. Siamo poveri, rimaniamo col solo necessario, perché
doniamo agli altri, perché mettiamo in comune in vari modi con gli altri quanto possediamo.

Quinta stella: l’obbedienza. La prima obbedienza va fatta a Dio, al carisma che lo Spirito
Santo ci ha donato. Esso ci dice che la nostra via è proprio amare il prossimo. Praticando la
carità, dunque, si perfeziona l’obbedienza.

Sesta stella: l’orazione. Questo atteggiamento dell’anima – si sa – cresce in perfezione e si
sublima con lo sviluppo dell’unione con Dio. Ma questa, a sua volta, è incrementata – come
abbiamo visto – dall’amore al prossimo. Anche la stella dell’orazione brilla meglio
praticando l’amore verso il fratello.

Settima stella: il coro. L’amore al prossimo è uno stimolo alla preghiera in comune. Non
sperimentiamo forse, quando amiamo il fratello veramente come noi stessi, quando siamo
uno con lui, il desiderio e quasi l’esigenza di averlo unito con noi anche nella preghiera?

Ottava stella: l’umiltà. La vera umiltà è annientamento di sé, cancellarsi completamente, e
ciò si realizza perfettamente amando, vivendo gli altri.

Nona stella: la mortificazione. Nell’amare il prossimo come Gesù vuole si è non solo
mortificati, ma morti. Decima stella: la penitenza. La prima penitenza che Dio ama e vuole
da noi è quella implicita nell’amore al prossimo.

Undecima stella: il silenzio. Coll’amore al prossimo si pratica il silenzio e si evitano le parole
inutili: 1) perché, per "farsi uno" occorre far tacere tutto in noi. E questo è il silenzio più
sublime. 2) Perché con l’amore è presente nei nostri cuori lo Spirito Santo, che lo diffonde, il
Quale, più amiamo, più forte parla in noi e ci dice fra il resto: “Taci qui, taci lì”.

Dodicesima stella: la pace. Amando il prossimo la si acquista davvero. Essa è un frutto dello
Spirito Santo, che è appunto là dove è l’amore.

Carissimi: amiamo, dunque. Amiamo sempre. Amiamo ancora. Che fra quindici giorni
possiamo ammirare nel firmamento della nostra anima più luminose queste dodici stelle. Se
faremo un esame dello stato della nostra anima, vedremo che è così. Questo ci dirà allora
che avremo compiuto un bel tratto di Santo Viaggio. Ed è ciò che auguro a tutti di cuore.$doc1599$, 'drive_import', '01599-WEB-1983-08-04-l-amore-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1599)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1600, 'ITA', $doc1600$Rocca di Papa, 6.10.1983

IO SONO NULLA, TU SEI TUTTO

Carissimi,

Ravviviamo anche oggi la nostra decisione di tendere alla santità, che significa vivere, senza
tentennamenti e sempre ricominciando, il nostro Ideale.

Ottobre ci offre come Parola di Vita per illuminarci il cammino: “Quando avrete fatto
tutto quello che vi è stato ordinato, dite: siamo servi inutili. Abbiamo fatto quanto
dovevamo fare”.
Con essa – come vi ho già detto –, e ciò si capisce dal contesto, Gesù non intendeva affermare
che le nostre azioni sono inutili, ma che è necessario tener sempre presente l’infinita
distanza fra Dio e l’uomo, come fra il Tutto e il nulla.

I giganti della religione, che sono i santi, sono sempre stati coscienti di ciò e spesso la loro
preghiera a Dio è fiorita così dal loro cuore: “Io sono nulla e Tu sei tutto”. E il risultato che
hanno ricavato da questa loro consapevolezza è stato di poter costatare un giorno che il loro
nulla era riempito dal Tutto, che Dio era entrato pienamente nel loro cuore. Essendosi
annientati, partecipavano persino della sua gloria.

Come si sono comportati questi cristiani veramente realizzati, così dobbiamo fare anche noi.

Ricordo che all’inizio del Movimento, volendo appunto imitare i santi, dichiaravamo
ripetutamente a Gesù nel tabernacolo che Egli è tutto e noi nulla. E lo facevamo soprattutto
prima di parlare in pubblico, perché non fossimo tanto noi a dare agli altri parole umane e
vuote, ma fosse Lui in noi a parlare ai cuori. E non posso dimenticare quanto spesso Egli ci
abbia aiutato, tanto da poter dire: se sin dall’inizio il Movimento ha avuto l’espansione che
sappiamo, lo dobbiamo pure a questo fatto.

E allora, anche adesso dobbiamo metterci in questa disposizione davanti a Dio: dirgli
sempre che noi siamo nulla e Lui tutto, ma soprattutto vivere questo nulla: essere quello che
realmente siamo per noi stessi: nulla.

Nelle varie spiritualità che hanno abbellito la Chiesa attraverso i secoli, molti sono stati i
modi suggeriti dallo Spirito Santo per insegnare ai cristiani ad annullarsi: vi sono coloro che
s’impegnano costantemente a rinnegare se stessi, a mortificazioni anche grandi, altri che
tendono al cosiddetto "nada" (niente), niente di tutti gli appetiti (cioè i desideri), ecc.

Noi, pur tenendo presente il dovere della rinuncia, dobbiamo seguire una via particolare:
trovare il nulla di noi pensando a Dio e alla sua volontà, e al prossimo vivendo in noi le sue
ansie, le sue pene, i suoi problemi, le sue gioie.
Sì, amando.

Se siamo "amore" sempre, nel presente, noi, senza che ce ne accorgiamo, siamo per noi
stessi nulla.

E perché viviamo il nostro nulla affermiamo con la vita la superiorità di Dio, il suo essere
Tutto.

Nello stesso tempo però, perché siamo nulla nel presente essendo amore, Dio ci fa subito
partecipi di Lui, e allora siamo "niente" per noi stessi e "tutto" a causa di Lui.

E quindi, per venire ad un proposito, in questi quindici giorni facciamo sempre nostra la
volontà di Dio: quella che conosciamo ed abbiamo programmata, e quella imprevista, che si
manifesta giorno per giorno, ora per ora.

Così facendo non sarà solo la nostra preghiera a dirGli: “Tu sei tutto, io sono nulla”, ma lo
griderà la nostra stessa vita.$doc1600$, 'drive_import', '01600-WEB-1983-10-06-io-sono-nulla-tu-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1600)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1601, 'ITA', $doc1601$Sierre, 18.8.1983

OGNI IDEA, UNA RESPONSABILITÀ

Carissimi,

In questi ultimi Collegamenti abbiamo parlato dell’amore verso il prossimo. Oggi vogliamo
salire dall’amore all’Autore di questa carità: Colui che la diffonde nei nostri cuori: lo Spirito
Santo.

Perché ne parliamo? Perché la Parola di Vita di settembre ci invita a non servire a due
padroni, ma ad uno solo: a Dio (cf. Lc 16, 13). E Dio parla a noi in vari modi: tra questi vi
sono le ispirazioni dello Spirito Santo. Dobbiamo, dunque, in questo mese servire Dio
seguendo anche le indicazioni della voce sottile dello Spirito che parla in noi.

Lo Spirito Santo! La Terza Divina Persona che è Dio, come il Padre è Dio e come lo è il Verbo!

Carissimi! Colgo l’occasione di questo Collegamento per manifestarvi un grandissimo
desiderio che conservo nel più profondo del cuore: che tutti noi, membri del Movimento dei
Focolari, abbiamo uno straordinario amore verso questo Dio che a molti – come spesso si
dice – è sconosciuto.

Dobbiamo avere questa ardentissima devozione, che deve distinguerci, perché non
possiamo, tutti noi insieme, e ciascuno in particolare, non sentirci grandi debitori verso di
Lui.

Noi diciamo: ho conosciuto l’Ideale, vivo l’ideale, da dieci anni seguo l’Ideale, da venti, da
trent’anni... E non possiamo negare che in tutto questo tempo l’Ideale ha dato non un
perché, ma il perché alla nostra vita e a quella di tanti, di tanti.

Ci ha inondato di luce, ci ha fatto conoscere la gioia più pura, facendo fiorire il sorriso sul
nostro e su molti volti; ci ha risolti e fatto risorgere, ci ha fatto sempre risperare, ci ha
lanciati in un’avventura divina unica e stupenda.

Ora, ci siamo mai chiesti: che saremmo noi senza l’Ideale?

Proviamo a domandarcelo, e vedremo quanto più triste, forse spenta, noiosa, insulsa, con
poco frutto, sarebbe la nostra vita.

Ebbene: Chi ha versato quest’Ideale nel nostro cuore, Chi lo mantiene sempre vivo, Chi lo
alimenta ogni giorno di nuove ispirazioni?

Colui che Gesù ha promesso ai suoi Apostoli partendo da questa terra: lo Spirito Santo.

Egli è nel cuore dei cristiani; è dunque qui nel mio cuore; Egli è nel cuore dei nostri fratelli.
Quanto ingrati siamo se non l’amiamo! È grave scortesia ricevere sempre e non dare mai!
Ma consoliamoci: abbiamo ancora la vita. E, prima che il nostro Santo Viaggio abbia il suo
compimento e possiamo andare di là a contemplare la Santissima Trinità senza troppo
rossore, possiamo fare qualcosa.
Il mese di settembre – come ho detto – ce ne dà l’occasione.
Lo Spirito Santo è dentro di noi? Egli parla al nostro cuore?
Diveniamo attenti ed assidui allievi di questo grande Maestro. Facciamo attenzione ai suoi
tocchi misteriosi e delicatissimi. Non lasciamo cadere nessuna di quelle che possono essere
sue ispirazioni.
Se i primi tempi abbiamo fatto tanto cammino mettendo in pratica il motto: “Ogni idea, una
responsabilità”, ricordiamo che le idee che fioriscono nella mente di una persona che s’è
proposta d’amare sono spesso ispirazioni dello Spirito Santo.
E perché ce le dà? Per beneficare noi e il mondo attraverso di noi, perché portiamo avanti la
nostra rivoluzione d’amore.
Attenzione allora: ogni idea, specie se pensiamo possa essere un’ispirazione, sentiamola
come una responsabilità da cogliere e mettere in pratica.
Così facendo, avremo trovato un ottimo modo per amare, onorare, ringraziare lo Spirito
Santo ed obbedire ad un solo padrone.

1.9.1983
ONORIAMO LO SPIRITO SANTO

Carissimi,
Nel Collegamento precedente abbiamo parlato dello Spirito Santo. Ed è questo argomento
che vorrei riprendere oggi, perché, conoscendo sempre di più questo “Dio sconosciuto”, lo
amiamo, lo onoriamo, gli obbediamo.
È incredibile quello che opera lo Spirito Santo. Guardate gli Apostoli: la Chiesa era stata
fondata da Gesù in croce, ma essi praticamente erano ammutoliti, timidi, impauriti, chiusi in
casa.
Scende lo Spirito Santo ed eccoli, con enorme coraggio, per le strade e le piazze, a parlare
con tale fuoco da sembrare ubriachi. Affrontano intrepidi ogni persecuzione e
s’incamminano per il mondo.

Questo un esempio, anche se di primaria importanza, di ciò che opera questo divino Spirito,
per non dire poi di tutto quanto è avvenuto sotto il suo impulso nei venti secoli di vita della
Chiesa: miracoli di luce di grazia, di capovolgimenti, di rinnovamento. Pensiamo ai Concili,
pensiamo anche ai vari Movimenti spirituali che sempre così tempestivamente ha suscitato.

E, guardando anche al nostro, dite un po’: pur con le dovute proporzioni, non è successo
qualcosa di questo genere anche per la nostra Opera, anche a noi, quando questo divino
Spirito ci ha investito col dono di un suo carisma?

Che orizzonte aveva la nostra vita, prima che ciò avvenisse, se non quello di persone che
non vedono al di là del proprio quartiere, con pensieri ed affetti limitati quasi
esclusivamente alla cerchia della propria famiglia, tesi unicamente, com’eravamo, a
raggiungere il traguardo d’una professione, o a possedere – che so? – una macchina, una
casa... con il desiderio di rallegrare i propri giorni migliori, di festa, al più con qualche film o
con l’assistere a qualche gara sportiva?

E che cosa è successo in noi quando lo Spirito Santo si è manifestato con questo splendido
Ideale?

Non ci ha forse spinti ad uscire dal chiuso di noi stessi per pensare al prossimo, agli altri,
dandoci la speranza e donandoci spesso l’evidenza che col suo aiuto molti problemi, che
travagliano il mondo, possono risolversi?

Non ha immesso, forse, anche in noi, il coraggio di parlare alle folle, come non
avremmo mai potuto supporre? Non ha forse dato anche a noi la forza di lasciare
spiritualmente, e spesso concretamente, non dico il proprio quartiere, ma la propria
patria, il proprio continente, per portar il fuoco del suo amore nelle più lontane
regioni del mondo? Non ha forse dato anche a noi la forza di affrontare giorno dopo
giorno disagi, difficoltà, contrarietà e spesso con la gioia nel cuore?

È perché Egli ci ha spinto ad agire così che abbiamo potuto costatare tanto spesso la
straordinaria Provvidenza del Padre, che abbiamo potuto raccogliere i frutti delle nostre
fatiche, e vedere il comporsi di una immensa famiglia che copre il mondo!

Se qualcosa o molto si è rinnovato attorno a noi, non è forse per opera dello Spirito Santo,
che sa rinnovare la faccia della terra? Sì, è stato Lui. È suo compito dar moto e impulso alle
cose, far lavorare la grazia, la vita divina che Gesù ci ha procurato. È di Lui immettere forza e
coraggio. E allora, se così è, se tanto gli dobbiamo, è nostro dovere far più spazio, nella
nostra vita spirituale, allo Spirito Santo.
Abbiamo visto che Egli è presente nella nostra anima. Noi siamo suoi templi, siamo templi
dello Spirito Santo. Abbiamo visto perciò come ciascuno di noi deve ascoltare la sua voce
che parla in noi.

Oggi vogliamo concentrare l’attenzione sul fatto che Egli è presente anche nell’anima di ogni
nostro fratello: anch’esso è tempio dello Spirito Santo o è destinato ad esserlo.

Se è così, non vi pare questo un nuovo motivo per amare ancor meglio ogni prossimo?

Se davanti ad un tabernacolo con Gesù Eucaristia si ha il rispetto dovuto, davanti a tutti i
nostri fratelli, altrettanti tabernacoli dello Spirito Santo, non si può non comportarsi di
conseguenza.

Sia questo allora il pensiero che illumina il nostro prossimo cammino: onoriamo lo Spirito
Santo, amando, rispettando, servendo ogni nostro prossimo.

15.9.1983

L’AZIONE POTENTE DELLO SPIRITO SANTO

Carissimi,

Mi è stato espresso da più parti il desiderio di sentir parlare ancora dello Spirito Santo, il
Dio purtroppo tanto spesso dimenticato. Ed è quello che voglio fare con grande gioia. Non è
forse Egli il nostro Protettore?

Abbiamo visto dove possiamo trovare lo Spirito Santo per poterlo onorare, obbedirgli,
manifestargli il nostro amore.

Egli è nel nostro cuore e per questo è cosa assai saggia e utile, per un buon Santo
Viaggio, ascoltare sempre la sua voce.
Egli è nei nostri prossimi come in un tempio e perciò ci siamo sforzati di raddoppiare
l’amore per chi ci sta vicino.

Ed Egli dov’è ancora?

È bene localizzare, in certo modo, la sua presenza perché noi tutti, uomini, siamo pur
sempre piuttosto "materialisti" e portati quindi molto più facilmente ad esternare la nostra
devozione a Dio là dove, per il suo grande amore, si fa vedere e toccare, come, ad esempio,
nell’Eucaristia, nella quale Gesù è presente sotto le specie del pane e del vino, che là dove
rimane quello che è: puro Spirito, non soggetto quindi in alcun modo ai nostri sensi, come è
per lo Spirito Santo.
Lo Spirito Santo, infatti, viene paragonato ad un vento a volte impetuoso, a volte dolce, e
raffigurato da una colomba, una creatura che ricorda leggerezza e soavità e vola con
dolcezza qua e là. È detto infatti dello Spirito Santo: “Lo Spirito soffia dove vuole e non si sa
donde venga e dove vada” (Gv 3, 8).

Ma l’azione di questo Dio, soave e tutto amore, è potente. Guardate quelle persone alle quali,
per disposizione di Gesù, è destinata una particolare infusione dello Spirito Santo: guardate
i sacerdoti, ad esempio. Essi, per Lui, possono addirittura con poche parole rendere
presente sull’altare Dio stesso o togliere i peccati dal cuore degli uomini. Guardate ancora i
Pastori della Chiesa, i Vescovi: non è forse nostra esperienza continua quella di scoprire, in
questi servi eletti del popolo di Dio, qualcosa che non abbiamo notato in nessun altro? Non
sentiamo forse sulle loro bocche un linguaggio che tocca il nostro cuore, perché
particolarmente illuminato, di fronte al quale nessuna disquisizione di teologo ben
preparato può star a paragone? Non cogliamo forse in loro una parola così confortante e
calda, da aver l’impressione d’essere, in loro, avvolti dall’amore materno della Chiesa? E i
nostri convegni, quando questi Pastori sono presenti, non toccano forse il culmine?

E – parlando ora a tutti quelli fra noi che sono cattolici – da quando è nato il nostro
Movimento, non raccogliamo forse come cosa preziosa ogni parola pronunciata dai diversi
Papi che si sono succeduti, perché la troviamo unica e vera?

Ebbene: è lo Spirito Santo che opera tutto questo. È Lui che, attualizzando le parole e le
promesse di Gesù, fa la Chiesa viva anche in questi suoi ministri in ogni secolo, in ogni luogo.

Dobbiamo esser coscienti di queste particolari presenze dello Spirito Santo in uomini
destinati in modo particolare ad aprire il Cielo all’umanità. E, superando l’atmosfera a volte
fredda e agghiacciante che il laicismo e il materialismo hanno dovunque diffuso, sì da
emarginarli spesso dalla vita sociale come esseri inesistenti o inutili al progresso della vita
moderna, esser sempre pronti invece a dare ad essi – senza cadere in atteggiamenti superati
– il posto d’onore che loro spetta.

La Parola di Vita di questo mese dice: “Quando avrete fatto tutto quello che vi è stato
ordinato, dite: siamo servi inutili. Abbiamo fatto quanto dovevamo fare” (Lc 17,10).

Avete visto nel commento come, letta nel contesto, essa esprima non tanto l’inutilità di
quanto fa l’uomo, quanto la preoccupazione di Gesù che sia sempre presente in lui l’infinita
distanza fra Dio e l’uomo come fra il Tutto e il nulla.

Nei prossimi quindici giorni, per sentirci tali e per onorare lo Spirito Santo, coltiveremo in
noi un amore particolare per i ministri di Dio, cercando di ricordare pensieri, ammonimenti,
indirizzi da loro rivoltici per metterli in pratica; preghiamo in modo particolare per essi;
mettiamo in luce presso altri il loro operato; sappiamo difenderli se fossero attaccati.

Questo atteggiamento, che san Francesco conosceva tanto bene e riservava persino ai preti
concubini, tanto da baciare la terra dove essi passavano, attirerà molte benedizioni su di noi
e lo Spirito Santo ci elargirà nuovi doni.$doc1601$, 'drive_import', '01601-WEB-1983-08-18-ogni-idea-una-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1601)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1602, 'ITA', $doc1602$Rocca di Papa, 20.10.1983

L’ESPERIENZA DEL RISORTO IN CIASCUNO DI NOI

Carissimi,

Il punto della spiritualità, che cerchiamo di vivere quest’anno, è Gesù crocifisso e
abbandonato, che consideriamo “chiave dell’unità della nostra anima con Dio”, perché è
proprio in Lui che noi troviamo la via per realizzare la nostra unità col Signore..

Studiando infatti i punti della spiritualità, come erano compresi e vissuti i primi
tempi, non si può non fare la sbalorditiva scoperta che l’esperienza del Risorto, con
l’irradiazione dei doni del suo Spirito (luce, pace, amore, consolazione, ardore, vita,
ecc.), è possibile non solo dove si realizza l’unità di due o più persone unite nel nome
di Gesù, ma è una esperienza che possono fare anche singole persone da sole. Il
modo? il prezzo? Abbracciare nell’attimo presente Gesù Abbandonato.
Approfondendo, alla luce di questa straordinaria esperienza, la Sacra Scrittura e
l’insegnamento della Chiesa, abbiamo visto che essa corrisponde a verità. Ma quale Gesù
Abbandonato – come noi diciamo – occorre abbracciare nell’attimo presente?

Quello richiesto dalla vita cristiana che, per poter seguire Gesù, domanda la rinuncia a se
stessi e il prendere la propria croce.

Occorre dunque dir di sì ed abbracciare con slancio ogni dolore che si presenta (la propria
croce), ma anche ogni sforzo che costa il rinnegare se stessi, la lotta al proprio egoismo, ai
desideri della carne – come si dice – (eccessi nel mangiare, impurità, litigi, gelosie e così via),
per lasciar trionfare nel cuore l’amore.

Ecco: quando questi sforzi sono amati per amore di Gesù crocifisso nel momento presente e
subito dopo si vive ciò che Dio vuole da noi nel momento seguente, si può sperimentare la
pienezza della vita del Risorto in noi, anche da soli. In ciascuno di noi si fa strada la sua luce,
ci invade la sua pace, s’accende l’amore con la consolazione, la serenità, il paradiso. Tutto
cambia, insomma; la nostra anima si veste a nuovo. Proprio come raccomanda la Parola di
Vita del mese di novembre, presa da san Paolo, che dice: “Rivestitevi del Signore nostro
Gesù Cristo e non seguite la carne nei suoi desideri” (Rm 13, 14).

È quello che vogliamo fare in questi quindici giorni: amare Gesù Abbandonato sempre,
subito, con gioia, non solo nei dolori quotidiani, ma anche nello sforzo per vincere il nostro
io.

Quando il nostro Foco, poco tempo dopo aver abbracciato il nostro Ideale, scriveva in una
poesia: “Mi son messo a morire e quel che accade non mi importa più, mi sono messo a
gioire nel cuore desolato di Gesù”, intendeva proprio questo: morire a se stessi per gioire
con Gesù: morire con Lui Abbandonato per vivere con Lui Risorto.

E allora anche noi ricordiamo questo verso: “Mi son messo a morire” e accettiamo la morte
del nostro io dieci, cento volte al giorno, per donare a chi ci incontra la gioia d’imbattersi nel
Risorto.$doc1602$, 'drive_import', '01602-WEB-1983-10-20-l-esperienza-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1602)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1603, 'ITA', $doc1603$Rocca di Papa, 3.11.1983

“ECCOMI!”

Carissimi,

L’incontro annuale dei focolarini europei (presenti alcune focolarine) svoltosi al
Centro Mariapoli dalla vigilia dell’Immacolata al 10 dicembre, festa della Madonna
di Loreto, caratterizzato dalla gioia di Gesù, dono dello Spirito Santo, esplosa
incontenibile da quei settecento cuori, ha avuto come singolare epilogo un patto
reciproco: ci siamo ripromessi di trovarci tutti spiritualmente uniti, ogni mattina, di
fronte all’immagine di Gesù Abbandonato per formulare, come un solo coro, una
preghiera.

Oggi, al pensiero di parlare a tutti voi focolarini, sacerdoti, volontari, religiosi, Gen, famiglie,
impegnati parrocchiali, ecc., schierati in prima fila nella divina avventura di far conoscere
più pienamente l’Amore nel mondo, mi è nato il desiderio in cuore di farvi partecipi di
questa piccola, ma importante iniziativa. Come sapete, ricorre in questi giorni il 40°
anniversario della nascita del Movimento dei Focolari e il nostro pensiero non può non
portarsi là, ai primi giorni della nostra nuova vita. Quest’anno poi, in cui in tutto il
Movimento si approfondisce Gesù Abbandonato come chiave dell’unità dell’anima con Dio,
non si può non ricordare una volta ancora quell’episodio notissimo, quando le prime
focolarine, liberandosi di tutto quanto avevano e rimanendo con i soli materassi per
dormire, hanno mantenuto, fissato alla parete, un unico oggetto: un quadro raffigurante
Gesù Abbandonato per dirgli, con questo atto, il proprio amore preferenziale, anzi esclusivo.
Di fronte a Lui, al mattino pregavano così: “Perché sei abbandonato...”.

Ma cosa significavano quelle tre parole? Proprio: io vivo perché Tu sei stato abbandonato e
voglio perciò avere come motivo della mia vita soltanto Te; dedicarmi con ciò ad amarti nei
dolori, nei fratelli le cui sofferenze ci fanno ricordare di Te, in quei germi di scopi dell’Opera
nascente che allora si potevano intravedere.

Il primo significato non era questo. Con quell’espressione si voleva dire a Gesù: “Perché sei
stato abbandonato (essendo stati noi con ciò salvati, essendo anch’io morta e risorta con
Te), eccomi Gesù tutta rinnovata, come Tu mi vuoi, anche in questo giorno; anche in ogni
suo attimo io sarò la risposta al tuo perché, un frutto del tuo abbandono. E non un frutto
qualunque, ma un frutto degno: bello, pieno, saporoso, dorato. Non mi basta quindi aver
ricevuto la fede, la vita, col battesimo che Tu con la croce e l’abbandono mi hai procurato,
ma voglio corrispondere in pieno a questi doni. Eccomi, Gesù!”. Si voleva dire, insomma, si
voleva dichiarare: “Perché sei stato abbandonato, eccomi!”.
Carissimi, proprio in questo mese la Parola di Vita dice: “Fate, dunque, frutti degni di
conversione” (Mt 3, 8). Frutti "degni" sono tutti gli atti di amore che si possono fare.

Ma con la preghiera suddetta invito anche tutti voi a fare possibilmente per Lui qualcosa di
più: ad essere voi stessi un frutto degno, a ripetergli ogni mattina, a ridirlo con la vita tutto il
giorno: “Perché sei stato abbandonato, eccomi!”.

Dietro a quel quadro – come molti sanno – allora stava scritto: “La mia vigna è sempre
dinanzi a me”, come queste parole fossero dette da Gesù.

In questi quindici giorni quella frase deve perfettamente realizzarsi: io, i 700 focolarini, noi
tutti, i 50.000 e più di tutto il mondo con cui siamo collegati, faremo di tutto per stare di
fronte a Lui come un frutto degno. E sono certa che nessuno mancherà all’appello.

Egli ci ha amato. Noi dobbiamo rispondere.$doc1603$, 'drive_import', '01603-WEB-1983-11-03-eccomi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1603)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1604, 'ITA', $doc1604$Rocca di Papa, 15.12.1983

1984

FISSARE LA BUSSOLA

Carissimi,

Anche il raduno di Natale, con le più di ottocento focolarine europee, si è concluso con un
piccolo patto che desidero oggi comunicare a tutte ed a tutti gli interni.

Abbiamo osservato come la chiamata a seguire Gesù Abbandonato in modo radicale non è
stata di una sola volta, e cioè all’inizio del Movimento.

Di tanto in tanto infatti, durante questi anni, il Signore ce l’ha risottolineata con episodi, o
particolari considerazioni.

Così è successo a me nel 1954. È un episodio noto, ma che è utile ricordare. Era il
’54, un anno importante per noi: diventava per la prima volta sacerdote un
focolarino. Io dovevo portarmi da Roma a Trento, per l’ordinazione di don Foresi da
parte dell’Arcivescovo di Trento. Non stando però bene in salute, si era pensato di
farmi fare il grosso del viaggio in aereo. Appena salita sul velivolo, una hostess molto
gentile, per facilitarmi il viaggio, ha pensato di farmi entrare nella cabina di
pilotaggio. In quel posto sono stata subito impressionata dal magnifico panorama
che vi si poteva osservare: ampio, completamente aperto, per la carlinga tutta di
vetro.
Ma non è stato il panorama che ha colpito maggiormente il mio spirito. È stata piuttosto una
sommaria spiegazione del pilota su ciò che è importante per guidare un aereo. Mi ha detto
che, per un viaggio diretto e sicuro, occorreva anzitutto fissare la bussola sul punto di
arrivo. Poi, lungo il cammino, si sarebbe dovuto vigilare perché l’aereo non deviasse mai
dalla rotta stabilita.

Seguendo questa spiegazione, feci immediatamente nel mio animo un parallelo fra quello
che è un viaggio in aereo in questo mondo, e quello che è il viaggio della vita: oggi direi il
"Santo Viaggio". Mi parve di capire che occorreva anche qui fissare in partenza, con
precisione, la rotta, la strada della nostra anima, che è Gesù Abbandonato. Poi, lungo tutto il
tragitto, far solo una cosa: rimanergli fedele. Sì, la via a cui Dio chiama tutti noi è solo
questa: amare Gesù Abbandonato sempre.

Ciò significa abbracciare tutti i dolori della propria esistenza. Significa praticare l’amore,
adeguando sempre la nostra volontà alla sua, "ammazzando" la nostra per lasciar vivere la
sua. Amare Gesù Abbandonato vuol dire conoscere la carità; sapere come si fa ad amare i
propri prossimi (come Lui, fino all’abbandono). Amare Gesù Abbandonato sempre significa
mettere in pratica tutte le virtù, che Egli in quel momento ha vissuto manifestamente in
modo eroico.

È ricorso il 31 dicembre ’83 il terzo anniversario del Santo Viaggio. E noi ci siamo chiesti: a
che punto siamo? E dentro un desiderio struggente di non perdere altro tempo.

Ebbene, io penso di poter affermare che puntare l’ago della nostra anima su Gesù
Abbandonato è quanto di meglio possiamo fare per continuare e finire il viaggio santo e per
percorrerlo anche con una certa facilità.

Se il pilota, che ho osservato tutto libero nei movimenti, non usa redini come per guidare un
carro, né volante come per un’automobile, anche noi se sistemiamo l’ago della nostra
bussola spirituale su Gesù Abbandonato, non avremo necessità di altro espediente per
arrivare sicuri alla meta.

E come nel viaggio in aereo non si conoscono le sorprese delle curve perché si corre in linea
d’aria, né si conoscono montagne perché ci si pone immediatamente su grandi altezze,
anche nel nostro viaggio, con l’amore a Gesù Abbandonato ci si mette subito in alto, non ci
spaventano gli imprevisti, né si sentono tanto le fatiche delle salite, perché, per Lui, sorprese
e fatiche e sofferenze sono già tutte previste e attese.

Fissiamo dunque la bussola su Gesù Abbandonato e rimaniamogli fedeli.

Come? Al mattino, al primo risveglio, puntiamo l’ago su Gesù Abbandonato col nostro
"Eccomi", di cui vi ho parlato. Poi, durante il giorno, di tanto in tanto, diamogli un’occhiata:
vediamo se siamo sempre in linea con Gesù Abbandonato. Se così non sarà, con un nuovo
"Eccomi" riassestiamoci nuovamente ed il viaggio non sarà compromesso.

Carissimi, questo è il patto fatto con le focolarine. Questo l’invito che porgo oggi a tutti noi.

Se faremo il viaggio della vita in compagnia di Gesù Abbandonato, potremo anche noi alla
fine ripetere con Pina 34 la famosa frase di santa Chiara: “Va’ sicuramente [sicura] anima
mia, imperocché buono compagno hai tu nel tuo cammino. Va’ che Colui che t’ha creata, t’ha
sempre guardata e t’ha santificata”.

Così facendo vivremo anche perfettamente la Parola di Vita di gennaio: “Io, quando sarò
elevato da terra, attirerò tutti a me” (Gv 12, 32).

E raccoglieremo frutti, frutti, frutti per l’"ut omnes".$doc1604$, 'drive_import', '01604-WEB-1983-12-15-fissare-la-bussola-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1604)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1605, 'ITA', $doc1605$Rocca di Papa, 5.1.1984

“ECCOMI”, DAVANTI A CHIUNQUE

Carissimi,

Ci siamo lasciati due volte fa pronti a pronunciare, come prima preghiera del mattino,
quell’"Eccomi" di fronte a Gesù Abbandonato, a significare che avevamo deciso d’essere
subito un frutto degno, bello, maturo, pieno, del suo abbandono, della sua redenzione.

Abbiamo puntato l’ultima volta la lancetta della nostra bussola spirituale su Gesù
Abbandonato, perché durante il giorno non avessimo mai modo di deviare dal
nostro deciso proposito.
Oggi quale la direttiva di marcia per il Santo Viaggio?

Voi sapete che il Signore ci ha dato uno straordinario carisma, che centra veramente il
cristianesimo. Per esso noi abbiamo compreso, sin dall’inizio, che eravamo chiamati a vivere
l’amore, la carità, il Comandamento Nuovo: a partecipare cioè a quell’agape che è Dio stesso:
“Dio è Agape”, “Dio è amore” (1 Gv 4, 8).

E lì dobbiamo rimanere e ritornare sempre.

È quella la grande rivoluzione che siamo chiamati ad offrire oggi al mondo moderno, in
estrema tensione, ed anche al mondo cristiano traumatizzato ancora da divisioni, come i
primi cristiani la presentavano al mondo pagano di allora.

Il Comandamento Nuovo è la nostra vocazione. Quel Comandamento, che non solo Gesù
chiamava “suo” e “nuovo” a sottolinearne l’importanza che vi dava (anche se “suoi” e
“nuovi” erano quanti altri aveva annunciato), ma che anche i primi cristiani, in san Giovanni,
consideravano come il messaggio per eccellenza.

Il Comandamento Nuovo è la nostra chiamata: vocazione ad amare, amare sempre, a
suscitare un incendio d’amore nel mondo, ad essere sempre pronti a pagare ogni giorno i
nostri debiti, debiti d’amore (cf. Rm 13, 8). Noi, infatti, fatti liberi dallo Spirito, che è in
ciascuno di noi, siamo condotti dallo stesso Spirito (che diffonde nei nostri cuori l’amore) ad
amare gli altri, a servire, a farci schiavi degli altri, di tutti.

Ma chi ci insegna questo modo di amare che ha in sé tanta rinuncia, tutta la rinuncia di noi
stessi?

Chi ci insegna questo amore che, mentre ci fa assolvere, momento per momento, il nostro
dovere di cristiani, ci porta più d’ogni altro mezzo, più della penitenza, dei voti stessi, alla
perfezione, alla santità?
Lo sappiamo: è Gesù nella sua croce, nel suo abbandono. È Lui il nostro modo d’amare. Così
Lui ha amato gli uomini. Così dobbiamo amarli noi.

Ed ecco allora una buona indicazione per i prossimi quindici giorni: pronunciare
quell’"Eccomi" a Lui soprattutto di fronte ad ogni fratello che incontriamo: per il quale
lavoriamo nelle scuole, negli uffici, nei negozi, a casa, in ogni luogo, con cui parliamo al
telefono, del quale parliamo con gli amici. Pronunciare quell’"Eccomi" essendo pronti a
rinunciare a tutto per farci uno con Lui.

“Eccomi, Gesù Abbandonato, di fronte a te in tutti”. Questo il nostro impegno. Questa la via
diritta. Questa la tensione che dobbiamo mantenere viva tutto il giorno per attuare anche la
Parola di Vita del mese: “Io, quando sarò elevato da terra, attirerò tutti a me”.

E saranno quindici giorni di progresso spirituale impensato e di conquiste impreviste.$doc1605$, 'drive_import', '01605-WEB-1984-01-05-eccomi-davanti-a-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1605)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1606, 'ITA', $doc1606$Rocca di Papa, 19.1.1984

RISTABILIRE SEMPRE L’UNITÀ

Carissimi,

Se c’è un problema, che oggi preoccupa tutti, è il problema della pace. Ed è talmente
importante che nessuno può disinteressarsene.
Mentre governanti e Santa Sede tessono rapporti utili al suo mantenimento (almeno là dove
non è ancora compromessa), mentre Movimenti laici e religiosi fanno quanto possono con
manifestazioni, stampa, ecc. per tener vivo il problema, anche ogni singolo cristiano deve
sapere d’avere in mano delle possibilità uniche per contribuire a questo scopo.

È giusto, infatti, quanto il Papa ha detto nel suo “Messaggio per la pace”: occorre cambiare il
cuore, avere un cuore nuovo.

E questo lo possiamo fare soprattutto noi cristiani ed è un dovere tutto particolare poi per i
membri del nostro Movimento, tanto sensibilizzati al Vangelo.

Nella Parola di questo mese di febbraio esso ci dice: “Se dunque presenti la tua offerta
all’altare e lì ti ricordi che tuo fratello ha qualche cosa contro di te, lascia lì il tuo dono
davanti all’altare e va’ prima a riconciliarti con il tuo fratello e poi torna ad offrire il tuo
dono” (Mt 5, 23s.).

È questa una Parola che ha costituito uno dei motivi fondamentali della rivoluzione vera e
propria che si è scatenata, i primi tempi, nella città di Trento, ed ha sorpreso e convertito
molti.

Perché? Forse perché con essa si affermava che Dio preferisce l’amore al prossimo piuttosto
che le offerte fatte a Lui? E che Egli non gradisce i doni di persone che opprimono i poveri?

Per questo, ma certamente non solo per questo.

Essa ha avuto degli effetti sorprendenti perché, cercando di viverla alla lettera, così come si
presenta, s’era colta la novità che conteneva. Già l’Antico Testamento, infatti, affermava che
Dio respinge come abominevoli i sacrifici di persone che opprimono i loro simili.

Questa Parola ha suscitato un potente capovolgimento di situazioni perché s’era capito che
Gesù domandava, in caso di tensione, di disaccordo, di disunità, di rimediare al male
prodotto, non solo al colpevole, ma anche all’altro che aveva subito il danno.
Gesù, infatti, dice: “Se... tuo fratello ha qualcosa contro di te”, non “se tu hai qualcosa contro
tuo fratello”. Per cui bastava prender coscienza che la concordia, l’unita non funzionava più,
non portava più i suoi effetti straordinari, per intervenire.

Ed è stato del resto questo modo di fare che ha mantenuto, anche per i quarant’anni
seguenti, il Movimento come un blocco monolitico.

È, dunque, una Parola utilissima all’unità, che è garanzia della pace, della vera pace dei
cuori.

Per attuarla occorre avere veramente un cuore nuovo, che non bada a ragioni o a torti, ma
sente soltanto il dovere, perché si è cristiani, che l’unione perfetta sia sempre salva.

E allora, che faremo in questi quindici giorni per viverla con pienezza?

Consideriamo subito le nostre situazioni personali: ognuno di noi ha parenti cui è legato, ha
compagni di studio o di lavoro, superiori, persone affidate a noi nei nostri "grappoli",
prossimi con cui ci imbattiamo giorno dopo giorno.

Qualche parente se l’è presa con noi perché, perché... Qualche amico ci ha mosso critiche per
il nostro essere cristiani, o membri del Movimento?

Qualche altro ci ha chiesto qualcosa e comincia a pensare male di noi perché non l’abbiamo
ancora soddisfatto?

È addirittura rotta la piena armonia nelle nostre unità Gen, nei nostri nuclei, persino nei
focolari? O languisce questa concordia, quest’unità per il misero contributo che qualcuno gli
dà?

Sia colpa nostra o di altri tutto ciò, non diamoci pace finché non abbiamo perfettamente
rimediato.

È necessario. È obbligatorio: siamo cristiani, siamo membri del Movimento dei Focolari
dell’unità. L’unità prima di tutto. Le offerte a Dio: preghiere, Messe, ecc. dopo. Dopo aver
ristabilito l’unità, o, se non è proprio possibile: pregare, andare a Messa anche prima,
accordandoci però con Gesù, assicurandolo che quel nostro dovere sarà al più presto
espletato. Immaginate se tutti facessero così?

E non solo sul piano individuale, ma fra Stato e Stato? O se almeno i cristiani, che sono circa
un miliardo nel mondo, si comportassero in questo modo?

Certamente la pace non sarebbe più un problema. Così, allora, i prossimi quindici giorni.

“Eccomi!”, di fronte ad ogni situazione che chiama una soluzione. “Eccomi”, per amore di
Gesù Abbandonato che s’è rivestito di "disunità" per tutti riunire.$doc1606$, 'drive_import', '01606-WEB-1984-01-19-ristabilire-sempre-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1606)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1607, 'ITA', $doc1607$Rocca di Papa, 16.2.1984

SIATE FUOCO PERCHÉ SIETE FOCOLARINI

Carissimi,

La Parola che illumina il cammino del Santo Viaggio in questo mese incomincia così:
“Togliete via il vecchio lievito per essere pasta nuova, poiché siete azzimi...” (1 Cor. 5,7). E
una frase che abbiamo avuto modo di commentare ancora, per la sorpresa che ha suscitato
in noi.

Essa si potrebbe, infatti, leggere anche così: “Togliete via il vecchio lievito [il lievito del
male], perché siete senza lievito [per la grazia di essere cristiani]”, che è come dire: “Siate
cristiani perché siete cristiani”.

È una parola che va proprio bene per molti seguaci di Cristo. Spesse volte, infatti, si lamenta
una realtà. i cristiani ci sono, ma non si vedono, perché non vivono da autentici cristiani,
mentre si dovrebbero distinguere per l’amore, per il fuoco.

È una parola che per noi, membri del Movimento dei Focolari, si potrebbe leggere anche
così: “Siate fuoco perché siete focolarini”.

Sono stata in questi ultimi tempi in Via dei Cestari, vicino alla Minerva 1, dove è sepolto il
corpo di santa Caterina da Siena, che ho visitato. Ho ricordato altre visite fatte a lei, i primi
tempi della diffusione del Movimento a Roma, quando ci infiammava una sua frase: “Se voi
sarete quelli che dovete essere, metterete fuoco in tutta Italia” 2. E mi sono trovata a
costatare, con infinita e commossa riconoscenza, che il fuoco è stato almeno acceso in tutto
il mondo. Almeno acceso... Non è stato certamente appiccato al mondo intero, in questi
quarant’anni, ma acceso un po’ dovunque, sì. E m’è nato in cuore un desiderio immenso: che
divampi!

Ma come fare?

Sembrava che Caterina mi ripetesse: “Se voi sarete quelli che dovete essere...”. E ho collegato
questo suo monito con la Parola di questo mese.

Siamo cristiani? Dobbiamo essere cristiani.

Siamo focolarini? Dobbiamo essere fuoco.
Essere fuoco. Il fuoco non è, non vive, se non si alimenta con legna, paglia, carta o altro. Così
noi non possiamo essere amore, se non amiamo. Il fratello, i fratelli sono la nostra “chance”,
con loro da amare (e i fratelli li possiamo avere dovunque) siamo fuoco.

Dobbiamo ricordarci che la nostra via per arrivare a Dio è il fratello. Quanto amiamo i
fratelli, tanto amiamo Dio: coi fatti, ma anche come potenziamento dell’amore verso di Lui
nel nostro cuore.

Carissimi, siamo sparsi in tutto il mondo. Esaminate dunque, su una carta geografica, qual è
la diffusione del Movimento nel luogo in cui vivete, nel territorio in cui operate. Prendete
conoscenza del fuoco che già c’è: divampante, o appena acceso, o sotto la cenere. Osservate
dove il fuoco ancora non c’è. E datevi da fare.

Essendo voi prima quelli che dovete essere, metterete il fuoco in coloro che contattate, e
questi, a loro volta, in altri. E così via.

Gesù vuole da noi un incendio, e lo vuole in tutto il mondo.

Sì, bisogna che il terzo millennio cristiano, che ormai s’avvicina, veda realizzata
questa promessa: Se voi sarete quelli che dovete essere, metterete fuoco in tutta la
Corea, in tutto il Paraguay, in tutto il Portogallo, in tutta la Costa d’Avorio... in tutte le
nazioni. E poi: in ogni regione di ogni nazione, in ogni città, località, paese...

Se il Movimento è arrivato, al giorno d’oggi, fin qui, perché non può raggiungere altre mete?

Lo può, perché se noi lo vogliamo è Gesù stesso, il Risorto, che appicca il fuoco ed estende
l’incendio. E Lui può essere fra noi, Lui può essere in ciascuno di noi sempre. Sappiamo cosa
domanda da noi per questo. Basta dunque che lo vogliamo.

E allora in questi quindici giorni ricordiamo: “Devo esser fuoco per tutti quanti
incontrerò e per quanti mi sono stati affidati”.$doc1607$, 'drive_import', '01607-WEB-1984-02-16-siate-fuoco-perch-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1607)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1608, 'ITA', $doc1608$Rocca di Papa, 2.2.1984

È AMORE ANCHE DOMANDARE

Carissimi,

Siamo ancora nel mese di febbraio illuminato dalla Parola: “Se presenti la tua offerta
all’altare e lì ti ricordi che tuo fratello ha qualche cosa contro di te, lascia lì il tuo dono
davanti all’altare e va’ prima a riconciliarti con il tuo fratello e poi torna ad offrire il tuo
dono” (Mt 5, 23s.).

È una Parola che ci ha chiarito, ancora una volta, il posto ed il peso che Gesù dà all’amore
fraterno. Ho saputo con gioia di qualche zona in cui tutti i membri "interni" si sono
mobilitati per sistemare situazioni sospese, piccole disunità, vecchie incrinature. Sia
ringraziato Dio e continuiamo a fare così!

Gesù con questa Parola ci ha detto chiaramente che non c’è comunione con Dio, culto vero,
preghiera autentica, senza la riconciliazione con i fratelli. Speriamo, dunque, che tale
discorso sia entrato profondamente in tutti i nostri cuori.

Ed è per questa speranza che vorrei ora parlarvi proprio della preghiera che, su queste basi,
è senz’altro accetta a Dio. Vorrei parlarvi in particolare della preghiera di domanda, di
richiesta d’aiuto e di grazie. Ho l’impressione, infatti, che qualcuno possa non sottolinearla
abbastanza. Perché? Anche per un motivo assai nobile: essendoci accostati in maniera più
profonda alla nostra fede, essendo diventati, in pratica, più religiosi, si è capito che la
religione non consiste solamente nell’andare in chiesa a chiedere e chiedere, ma nell’amare
Dio e quindi nel donare. E si impegna la propria vita ad attuare tutti quei principi che anche
la nostra spiritualità evangelica suggerisce, per fare – come si dice – la nostra parte.

È certamente questo un ragionamento più che valido. Tuttavia c’è da fare una
considerazione: amare Dio implica osservare tutti i suoi comandamenti.

Ebbene, un comandamento che Gesù ripete con insistenza è proprio quello di domandare:
“Chiedete e vi sarà dato; cercate e troverete; bussate e vi sarà aperto” (Mt 7, 7).

Che dobbiamo fare allora? Chiedere di più e meglio perché Egli vuole così. E anche in questa
maniera manifesteremo il nostro amore a Lui.

Vedete: in questo Santo Viaggio che portiamo avanti da più di tre anni, è bene che facciamo
di tanto in tanto qualche breve pausa di riflessione per costatare come va, se abbiamo fatto
progressi, se ci sembra d’esser sempre allo stesso punto, o addirittura se abbiamo perso lo
slancio iniziale.
E un pensiero che può venirci è questo: come mai con tanti lumi soprannaturali che ho
avuto, a confronto di tante altre persone, con tante spinte da parte di fratelli, con tante
promesse e dichiarazioni che ho formulato, sono così lento e così poco generoso nell’amare,
nell’esercizio delle virtù, persino nel vincere le tentazioni?

Non è forse sproporzionato ciò che ricevo e ciò che io stesso mi propongo di fare, con quello
che in concreto realizzo?

A questa nostra possibile domanda la miglior risposta la dà Gesù: “Senza di me non potete
far nulla” (Gv 15, 5). Che è come dire: nonostante tutti i vostri sforzi, le belle meditazioni, gli
incoraggiamenti, le decisioni, non fate grandi passi in avanti perché non pregate a
sufficienza, perché non domandate l’aiuto corrispondente.

Carissimi, se i santi sono arrivati a dire che: “Chi prega si salva e chi non prega si danna”, è
ovvio anche che chi prega avanza spiritualmente e chi non prega, al massimo sta fermo, ma
in genere retrocede. Io so che voi tutti pregate. I focolarini hanno – tutto compreso – più di
due ore al giorno di preghiera; gli altri vi impiegano un tempo conforme alla loro vocazione.
So che piccoli e grandi fanno “consenserint” – come noi diciamo – in ogni occasione
particolare: quando uno muore o nasce; quando si sposa o si consacra a Dio; quando ci sono
da affrontare situazioni non ordinarie.

Certamente si prega e ciò vuol dire che non si poggia unicamente sulle proprie forze.

Tuttavia possiamo migliorare in due direzioni. In primo luogo, non moltiplicando le
preghiere, ma nel renderci meglio conto di ciò che già chiediamo.

Riflettiamo un po’ e vedremo quante grazie si chiedono nelle preghiere del Mattino, della
sera, durante la Messa, nel nostro ringraziamento dopo la Comunione, nella recita del
rosario, durante la meditazione, e alla visita al Santissimo Sacramento, per chi la può fare.

In secondo luogo, potremo migliorare pregando, come dicono i santi, in modo da ottenere.

Si ottiene, se si chiede con la coscienza che nulla possiamo fare da noi e quindi con l’umiltà,
con la convinzione che tutto invece possiamo fare con Dio e quindi con la confidenza in Lui;
e se si prega con perseveranza: chiedendo sempre con amorosa insistenza come Gesù
desidera.

Insomma è necessario mettere a fuoco sempre più queste domande, che già facciamo, ed
esporle sempre meglio e in modo proporzionato allo sforzo che mettiamo nel vivere il
nostro Ideale. Così tutto risulterà più fecondo.

E preghiamo finché siamo in tempo. Ricordo sempre quello che ha raccomandato la mamma
d’una delle prime focolarine prima di morire: pregate durante la vita perché alla fine non c’è
più possibilità.

Così, allora, per questi quindici giorni: mettiamo a fuoco la preghiera.$doc1608$, 'drive_import', '01608-WEB-1984-02-02-amore-anche-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1608)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1609, 'ITA', $doc1609$Rocca di Papa, 5.4.1984

LA RISPOSTA IMMEDIATA:

SCELTA PREFERENZIALE DI GESÙ ABBANDONATO

Carissimi,

È stato accolto con grande entusiasmo quello che possiamo chiamare “il progetto di
Caterina da Siena aggiornato al 2000”, che vi ho trasmesso nell’ultimo pensiero: “Se voi
sarete quelli che dovete essere, metterete fuoco in tutto il mondo”. L’ho capito dai vostri
molti telegrammi e messaggi, nei quali era evidente come esso abbia toccato il tasto più
sensibile del vostro cuore, come abbia mirato al centro della nostra vocazione di cristiani, di
focolarini che ci chiama, per la misericordia di Dio e la sua gloria, a cose non comuni: “Non
accontentatevi delle piccole cose – scrive pure Caterina – perché egli, Dio, le vuole grandi”.

Ed ho cercato di vivere anch’io con tutti voi, secondo il suo insegnamento, mettendo in
pratica la Parola, che ci invita ad essere quelli che siamo.

Ebbene, uno di questi giorni mi sono trovata a chiedermi: ma chi sei tu, chi siete voi, per
poter aspirare ad essere veramente quelli che dovete essere nel senso più profondo?
Passavo in quel momento accanto ad una grande immagine di Gesù Abbandonato e la
risposta mi è venuta immediata: Noi siamo quelli che hanno fatto di Te l’Ideale della loro
vita: “Ho un solo Sposo sulla terra, non ho altro Dio fuori di Lui”. E lì, come fossero concetti
tutti nuovi, ho ricordato l’amore preferenziale per Lui, la scelta esclusiva di Lui, che tante
volte gli ho dichiarato, mentre s’accendeva nel mio cuore una grande voglia di amarlo come
mai.

Ma dove? Come? Amarlo in tutti certamente, ma soprattutto in coloro che più gli
assomigliano, che soffrono in qualsiasi modo, che noi chiamiamo lontani; anche nei piccoli,
nei giovani esposti oggi all’atmosfera micidiale dell’indifferentismo, dell’ateismo pratico,
dell’immoralità, se non a peggio.

Sì, se la nostra rivoluzione ha avuto un rilancio particolare, come mi sembra, in questi
giorni, se esaminiamo la nostra piccola carta geografica della diffusione del Movimento là
dove siamo, se abbiamo fra le mani o stiamo ordinando gli indirizzi delle persone di cui
dobbiamo prenderci particolare cura, dobbiamo evidenziare in modo tutto particolare
quelle che più ci ricordano Gesù Abbandonato. È ad esse che va data la nostra prima
attenzione, ad esse va destinato il nostro primo tempo a disposizione. Se così faremo, sono
certa che il resto verrà da sé. Se così faremo, saremo nel miglior modo quelli che dobbiamo
essere, perché il nostro dover essere non è che Gesù venuto per gli ammalati e non per i
sani, per i peccatori e non per i giusti. I sani e i giusti ci seguiranno spontaneamente.
Carissimi, domani, Venerdì Santo, è la nostra grande festa: festa di dolore e di amore. Che il
bacio alla croce abbia quest’anno il significato del suggello d’una promessa: amarlo nelle
persone che più lo ricordano, che più gli assomigliano.

Intanto oggi, Giovedì Santo, non dimentichiamo il Comandamento nuovo di cui egli è la
misura; la preghiera dell’unità di cui egli è la chiave; l’Eucaristia in cui egli si dona a noi in
corpo, anima e divinità proprio nel mistero della sua passione, e ricordiamo il sacerdozio
che in Gesù trova la sua piena realizzazione sulla croce, nell’abbandono.

E rimaniamo immersi in questi immensi misteri che sono la nostra vita e la nostra gioia.$doc1609$, 'drive_import', '01609-WEB-1984-04-05-la-risposta-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1609)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1610, 'ITA', $doc1610$Rocca di Papa, 19.4.1984

PER FARE OPERE PIÙ GRANDI

Carissimi,

La Parola di Vita del mese di maggio invita a credere in Gesù per compiere le opere che egli
ha fatto e farne di più grandi (cf. Gv. 14,12). Come mai delle semplici creature come noi,
possono arrivare a tanto?

Le opere, a cui accenna Gesù, sono quelle riguardanti la redenzione dell’uomo, la sua
salvezza.

Ma giacché Gesù ha operato pienamente la salvezza del mondo quando è morto e risorto ed
è salito al Cielo, ecco che ha potuto agire con pienezza a favore degli uomini solo attraverso
altri uomini, e non direttamente.

Così, ha diffuso la fede nel mondo per mezzo dei suoi discepoli. E le opere che egli ha fatto e
fa tuttora attraverso uomini, essendo effetto della redenzione pienamente compiuta,
possono essere anche superiori a quelle che faceva quando era in terra. Non sono gli uomini,
però, che fanno opere come le sue o più grandi delle sue, anche se occorre certamente la
loro corrispondenza. È Gesù in loro.

Chi, infatti, credesse d’esser capace da solo di fare cose grandi come quelle che ha fatto
Gesù, sarebbe come un bambino che, perché in braccio al padre, pensa di essere alto come
lui. E chi credesse di saper fare cose addirittura più grandi di quelle compiute da Gesù
assomiglia a quel bambino che, seduto sulle spalle del padre, crede di essere più grande di
lui perché magari può toccare persino il soffitto di casa. Il bambino può arrivare senz’altro
all’altezza del padre e anche più su di lui, ma perché egli lo porta.

Così è del cristiano. Il Risorto è in lui. Se egli lo lascia vivere può fare opere degne del
Risorto; come quelle di Gesù, dunque, prima della sua morte ed anche più.

E come fare perché il Risorto viva in noi?

Lo sappiamo. Occorre svegliarsi al mattino e drizzare subito la bussola sull’Abbandonato;
pronunciare l’“Eccomi” ed essergli fedeli tutto il giorno. In pratica: amare il dolore.

San Giovanni della Croce, arrivato ai vertici della santità, avendo quindi compiuto col
massimo successo il Santo Viaggio, si chiede come mai pochi arrivino ai più alti gradi
dell’unione con Dio. E risponde che dipende dal fatto che non amano il dolore e cercano la
consolazione. Mentre chi ama il dolore sa cos’è la vita del Risorto in se: è Paradiso
anticipato.
E allora, se le cose stanno così, in questi quindici giorni cercheremo di dare il massimo
valore, durante la giornata, al dolore che potremo incontrare. Non tanto a quello inventato
dalla nostra fantasia, ma a quello offertoci dalla volontà di Dio: dalle circostanze avverse, dai
prossimi da amare fino in fondo, dalle mortificazioni di cui possiamo rivestirci tanto spesso
in questo mondo in cui viviamo, ma del quale non dobbiamo essere assolutamente.

Noi, del resto, abbiamo un estremo bisogno di lasciar vivere il Risorto in noi. Il nostro scopo,
infatti, è un’opera grandissima: incendiare il mondo, cominciando dal nostro angolo. E
dobbiamo puntare non su obiettivi facili, ma difficili: amare i lontani, come ha fatto Gesù.

Il Risorto, dunque, deve semplicemente splendere in noi e fra noi.

E perché ciò sia dobbiamo vivere, come noi diciamo, “oltre la piaga” di Gesù Abbandonato .
Allora saremo sempre di fiamma e le nostre convivenze (siano esse un focolare, o una
famiglia-focolare, o un nucleo, o un’unità Gen, o una comunità religiosa, o un grappolo),
saranno un fuoco, un incendio d’amore con tutte le conseguenze che si possono pensare
nella linea dell’“ut omnes”. Tuttavia non ci meraviglieremo se la nostra azione è nel mondo
intero, mentre quella di Gesù è rimasta nei limiti della Palestina. Avremo ben chiaro che è
sempre Lui che fa. Né ci stupiremo se le conversioni operate tramite noi superano di
numero le sue. È sempre Lui che converte.

Ricordiamo che non c’è fiamma, né fuoco, né incendio senza qualcosa che si consuma: è il
nostro io che deve bruciare, anche se vorrebbe sempre prevalere; ma noi, abbracciando i
momenti duri lo faremo morire, perché sulla sua morte risorga di continuo Gesù.

Riempiamo allora questi quindici giorni di atti di amore a Gesù Abbandonato.$doc1610$, 'drive_import', '01610-WEB-1984-04-19-per-fare-opere-pi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1610)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1611, 'ITA', $doc1611$Rocca di Papa, 3.5.1984

MARIA, IL NOSTRO DOVER ESSERE

Carissimi,

Siamo agli ultimi giorni di maggio, questo mese che, anche per la primavera ormai presente,
almeno da queste parti, ma soprattutto perché dedicato a Maria, non può non portare nei
nostri cuori un’onda di tenerezza, di dolcezza ed un particolare amore verso la nostra
amabilissima Madre. Ed io vorrei che tutti noi, membri della sua Opera, dopo l’atto di
affidamento del mondo gridato dal Papa al suo Cuore Immacolato, non lasciassimo
tramontare questo mese senza una personale consacrazione di ciascuno a lei, un “Totus
tuus” ripetuto con tutto il cuore, perché ci affidi meglio che può a Gesù.

Noi infatti, proprio perché membri del Movimento, dobbiamo avere una particolarissima
unità con la Madonna. E di ciò siamo consapevoli non solo noi, ma lo è anche chi ci segue con
amore dall’esterno. Ne abbiamo avuto una conferma pure in questi giorni.

Come immaginerete, nel suo recente viaggio in Estremo Oriente, il Santo Padre ha
incontrato spesso i focolarini, i gen, i volontari, i sacerdoti, ecc. Erano così universalmente
presenti che una personalità al suo seguito ha chiesto loro: “Ma come fate?”. Ed un’altra ha
risposto per noi: “È opera di Maria! È Maria!”. Chi parlava alludeva probabilmente alla
fecondità di Maria e delle sue Opere, ma a noi quella risposta ha dato una grande gioia per
un altro motivo.

Come tutti sappiamo Maria, la nostra amabilissima Madre, è il nostro Ideale, il nostro
Modello, è la nostra “forma”. Maria è – come noi diciamo – il nostro “dover essere”, mentre
noi siamo di lei il “poter essere”.

E, quando noi realizziamo noi stessi (e ciò avviene nei momenti in cui il Risorto splende in
noi sulla morte del nostro io), se ci potessimo vedere con quegli occhi con cui si vedono le
cose soprannaturali, scopriremmo di essere, in certo modo, altre piccole Maria. È lei infatti
la nostra realizzazione.

Ricordate la preghiera che abbiamo fatto tanti, tanti anni fa, quando abbiamo chiesto a Gesù
come mai egli, che ha voluto rimanere su tutti i punti della terra nell’Eucaristia, non ha
trovato un modo per lasciarvi anche sua Madre per aiutarci così nel viaggio della vita?

E ricordate la risposta che mi è sembrato di cogliere nel mio cuore: “È perché la voglio
rivedere in te; anche se non siete immacolati il mio amore vi verginizzerà”?

Ebbene la mia speranza è che oggi, dopo tanti anni, Gesù dal Cielo possa vedere, in qualche
modo, in molti di noi, su vari punti della terra, almeno in certi momenti, un’immagine della
sua Madre. E sia confortato dal fatto che, se così è, ella, attraverso di noi, apra nuovamente il
cuore e le braccia all’umanità che soffre, soprattutto all’umanità lontana.

Con questa speranza una grande gratitudine invade il mio cuore e deve invadere il vostro,
col proposito più serrato a Gesù: “Piuttosto morire che non amarti abbandonato”. Perché –
come dice anche una nostra antica canzone – è incontrando Gesù Abbandonato che si
diventa un’altra-Maria. Nei prossimi quindici giorni allora, di fronte ad ogni difficoltà, che
subentra o che affrontiamo per vivere le virtù, soprattutto la carità, dobbiamo ripetere
continuamente: “Morire, piuttosto che non amarti abbandonato”. E faremo con ciò felice
anche Maria. Vedendo in qualche modo sulla terra dei figli e delle figlie tanto simili a lei,
immaginate quali grazie donerà, come farà del nostro soggiorno terreno una continua
primavera.$doc1611$, 'drive_import', '01611-WEB-1984-05-03-maria-il-nostro-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1611)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1612, 'ITA', $doc1612$Rocca di Papa, 17.5.1984

SALVARE E RITORNARE

Carissimi,

Abbiamo da pochi giorni lasciato dietro le nostre spalle, con una certa nostalgia, il mese di
maggio che tanto fascino esercita; ed ecco, il mese di giugno appena schiuso, esercitare in
noi, attraverso le sue feste, una serie di profondissimi sentimenti che toccano nel più intimo:
l’Ascensione, che abbiamo celebrato il 3 con la straordinaria giornata di Umanità Nuova e
Gioventù Nuova, ed ora fra tre giorni la Pentecoste. Poi la festa della SS. Trinità, quella del
Sacratissimo Corpo e Sangue di Gesù e infine quella del Cuore Immacolato di Maria. Feste,
realtà così celesti e così nostre che ci sembrano fin troppo numerose per poterle meditare e
godere profondamente in un solo mese.

E fermiamoci a quella che celebreremo fra tre giorni, in tempo giusto, proprio per
prepararci un po’: la Pentecoste, la straordinaria discesa dello Spirito Santo – frutto della
morte di Gesù – su Maria, gli Apostoli e la primitiva comunità cristiana. Una festa che
abbiamo sempre sentito nostra, nostrissima, forse inconsapevolmente, forse per
associazione di idee tra le fiamme che il focolare richiama e quelle scese sul Cenacolo.

Sì, forse per questo secondo motivo. Ha collegato del resto così le due cose anche il Santo
Padre Giovanni Paolo II, che al nostro Genfest dell’ ’80 ha detto, ricordate?: “...“il focolare”,
un termine che per voi ha un grande significato. Il pensiero va spontaneo a quel primo
“focolare” costituito dai discepoli raccolti nel Cenacolo...”.

La Pentecoste, dunque, lo Spirito Santo, il Focolare.

Dobbiamo festeggiare anche quest’anno la ricorrenza della Pentecoste nel modo migliore,
per la gratitudine che non possiamo non sentire verso la Terza Divina Persona della SS.
Trinità, che è stata con noi così prodiga di grazie, sì da cambiare la nostra vita.

E come festeggiarla?

Io non vedo altro modo che quello di ravvivare la fiamma toccata a ciascuno di noi: io la mia,
voi la vostra, ognuno la sua: la fiamma dell’amore.

E un potente aiuto può essere la Parola di Vita del presente mese. In essa Gesù dice: “Dio
non ha mandato il Figlio nel mondo per giudicare il mondo, ma perché il mondo si salvi per
mezzo di lui” (Gv 3,17). È la rivelazione del perché della vita di Cristo: egli è venuto in
questo mondo per salvare, per vivere il suo nome: Salvatore.
Carissimi, questa Parola sviluppa in noi due atteggiamenti: anzitutto ci fa guardare ad ogni
prossimo che incontriamo come a qualcuno che, in qualsiasi situazione si trovi, non va
condannato, ma salvato.

Poi ci fa guardare anche a noi stessi come a qualcuno che, in qualsiasi situazione si trovi, è
oggetto dell’amore di Dio e può tornare sempre alla sua misericordia infinita.

È una Parola che ci insegna a vivere come si vive in Cielo, dove si fa più festa per un
peccatore che torna, che per novantanove giusti; che ci aiuta a non giudicare, a non
condannare, ma ad amare sempre, ad essere sempre pronti a salvare; che ci spinge verso i
lontani per dare al Cielo la gioia di una possibile festa.

E una Parola che spinge a tornare sempre anche noi a Dio, che significa ricominciare ogni
volta; che ci sprona ad alimentare la fiamma nel nostro cuore alla sua misericordia.

È logico che questi atteggiamenti costino. Non è semplice essere sempre pronti a scusare, a
salvare. Risulta più facile lasciarsi andare al giudizio. Ma dobbiamo fare atti così frequenti di
comprensione e di perdono verso tutti, da farne l’abitudine.

Così, non è sempre facile affidare noi stessi alla misericordia di Dio. Sentendo il peso dei
nostri errori è più facile avvilirci, ma occorre tornare ugualmente, ricordandoci che egli è
venuto per salvare anche noi. Lasciandoci bagnare dalla sua misericordia si riapre il
colloquio con Lui, si sperimenta nuovamente l’unione con Lui, quell’unione che non
avvertiamo così intensa quando facciamo calcolo sulle nostre sole forze e crediamo di
andare avanti abbastanza bene senza il suo aiuto.

E allora, quale il motto dei prossimi quindici giorni per festeggiare con la nostra vita la
Pentecoste? È un binomio: salvare e ritornare. Salvare gli altri e ritornare noi a Dio,
ricominciare. Vivremo certamente bene, così, anche la festa della SS. Trinità. Prima delle
seguenti feste ci risentiremo ancora. Che il Padre, il Figlio e lo Spirito Santo avvolgano tutti
noi nel loro infinito amore.$doc1612$, 'drive_import', '01612-WEB-1984-05-17-salvare-e-ritornare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1612)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1613, 'ITA', $doc1613$Rocca di Papa, 7.6.1984

CESELLARE LA FIGURA DI CRISTO IN NOI

Carissimi,

Siamo sempre in cammino nel Santo Viaggio della vita. E c’è chi l’ha già concluso e chi lo
incomincia con noi. Un viaggio in cui domina la tensione alla santità, che è dovere di ogni
cristiano. Ed anch’io con voi cerco ogni giorno di non rallentare la corsa, ma, con la grazia di
Dio e poggiata sulla preghiera per ottenerla, mi sforzo di camminare.

È per questo che nel mio viaggio a Istanbul ho preso con me un libretto, che può dare ottimi
suggerimenti al riguardo: L’Imitazione di Cristo appena edito da “Città Nuova”. Esso, pur
parlando a chi si impegna per Gesù in una via diversa dalla nostra, una via più individuale,
dove si va a Dio più da soli, dà suggerimenti utili anche a noi che percorriamo una via più
collettiva. E li dà con sapienza ed esperienza.

Sua caratteristica è ad esempio accentuare l’importanza delle virtù.

Ora voi sapete come nell’acquisto di esse e nella lotta ai vizi opposti, noi, chiamati da Dio a
far del fratello la nostra “fortuna”, troviamo proprio nell’amore a Lui la rinuncia a noi stessi.
E voi sapete come sia nella nostra prassi in genere, per migliorarci, non tanto prendere di
mira difetto per difetto, quanto aggirare gli ostacoli, “cambiare stanza”, come diciamo noi,
“vivendo gli altri” e ponendoci così nella carità, fonte di ogni virtù.

Tuttavia anche i nostri Statuti sottolineano in particolare le virtù, ed è nostro compito
prenderle in considerazione, e ciò quanto più progrediamo nella via spirituale.

Del resto Gesù Abbandonato, a cui abbiamo dato la vita, è per noi modello di tutte le virtù e
sempre ripetiamo di volerlo amare non solo nel dolore, ma anche nella pratica di esse.

La carità infatti staglia in noi la figura del Cristo, perché amando si è un altro Lui. Ma
amando Gesù Abbandonato nella pratica delle virtù, si ha l’impressione di cesellare questa
figura di Cristo in noi, di rifinirla.

Il fatto è che si può osservare come nonostante il nostro amore ai fratelli ci portiamo dietro
da anni dei piccoli o meno piccoli difetti, alle volte banali, ma che tolgono qualcosa alla
bellezza di Cristo in noi. E spesso di ciò ci lamentiamo con noi stessi, perché ci umilia
vederci così imperfetti nonostante tutti i nostri sforzi.

Quali sono questi difetti? Ognuno ha i suoi. A volte guastiamo quanto facciamo per la fretta,
o compiamo imperfettamente la volontà di Dio; siamo distratti nella preghiera; ci
soffermiamo su sciocchezze che piacciono al mondo; o non sappiamo moderare la gola.
Spesso siamo vinti dalla curiosità, o cadiamo nella vanagloria; parliamo a sproposito o senza
necessità. Siamo attaccati a piccoli oggetti, un po’ dipendenti dalla televisione; ci facciamo
servire dai fratelli, siamo incostanti e così via.

Che fare?

Gesù, quando si tratta di cose non buone invita ad agire con decisione, come quando ha
affermato: Se il tuo occhio ti scandalizza, cavalo (cf. Mt 5, 29).

Anche noi dunque, pur continuando nella via dell’amore, dobbiamo per amore di Gesù
Abbandonato non tentennare, rimanendo quelli che siamo, ma sradicare vizio per vizio.

L’Imitazione di Cristo dice che non è facile, anzi afferma che se ce ne liberassimo di uno
all’anno, in breve saremmo perfetti.

Io sono convinta che nella nostra via le cose sono più possibili. L’amore, infatti, aiuta,
l’amore è rinnegamento di sé e brucia anche queste cose.

Tuttavia non sarà male prendere di mira qualche difetto e far l’abitudine opposta.

Assicura L’Imitazione di Cristo che è con l’abitudine opposta che si vince un’abitudine
cattiva.

Coraggio allora e all’opera!

Continuiamo ad amare ed in questi giorni e fino al prossimo appuntamento prendiamo
l’abitudine opposta di almeno tre difetti nostri.

La Madonna ci aiuterà. Lo sa che vogliamo fare a Lei il dono della nostra santificazione. Che
non ci tocchi di vederci inferiori agli atleti, i quali si sottopongono a volte a fatiche
estenuanti per una conquista solamente umana.

L’amore a Gesù Abbandonato amato nella lotta per il guadagno delle virtù, abbia più grande
vittoria.$doc1613$, 'drive_import', '01613-WEB-1984-06-07-cesellare-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1613)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1614, 'ITA', $doc1614$Rocca di Papa, 21.6.1984

LA DIVINA AVVENTURA

Carissimi,

Può darsi che alcuni di noi si siano dimenticati di una realtà che era così presente i primi
tempi del Movimento e che la Parola di questo mese ci ripropone. Se amiamo Dio, la vita, la
nostra vita, con tutte le sue circostanze, è una divina avventura nella quale non c’è un attimo
in cui non ci si debba stupire per qualcosa di nuovo; una divina avventura piena di tesori da
scoprire, di cui arricchirci momento per momento, come di tante piastrelle da aggiungere in
continuazione al mosaico della nostra santità.

La Parola del mese dice infatti: “Noi sappiamo che tutto concorre al bene per coloro che
amano Dio” (Rm 8, 28). Tutto concorre... per quelli che amano Dio. Tutto. Perché nulla – lo
dobbiamo credere – avviene a caso. Nessun avvenimento gioioso, indifferente o doloroso,
nessun incontro, nessuna situazione di famiglia, di lavoro, di scuola, nessuna condizione di
salute fisica o morale è senza senso. Ma ogni cosa: avvenimenti, situazioni, persone, è
portatrice d’un messaggio da parte di Dio, che dobbiamo saper leggere e accogliere con
tutto il cuore.

Tutto concorre al bene per quelli che amano Dio. Il fatto è che egli ha un suo disegno
d’amore su ognuno di noi, ci ama di amore personale, e – se crediamo a questo amore e vi
corrispondiamo col nostro amore (ecco la condizione!), – porta ogni cosa al compimento del
suo disegno su di noi.

Basta guardare Gesù. Sappiamo come egli abbia amato il Padre. Ebbene, se si pensa anche
solo un attimo a Lui, possiamo osservare come egli abbia realizzato la Parola di questo
mese, durante tutta la sua vita. Nulla è successo a caso per Lui. Tutto ha avuto un significato.

Ma si vede questa Parola impersonata in Lui in modo specialissimo soprattutto nell’ultimo
tratto della sua esistenza: nulla è successo a caso nella sua passione e morte.

Per Lui anche l’abbandono da parte del Padre, estrema prova, ha cooperato al bene perché
con il suo superamento ha dato compimento alla sua Opera.

Le cause erano magari cieche: quelli che l’hanno sottoposto a patimenti e poi alla morte non
sapevano quello che facevano; e non solo nel senso che non conoscevano chi flagellavano e
crocifiggevano, ma anche perché non conoscevano di essere autori d’un sacrificio, del
sacrificio per eccellenza, che avrebbe fruttato la salvezza dell’umanità. I dolori arrivavano
quindi a Gesù senza questa intenzione, ma egli, perché amava il Padre, li ha tradotti tutti in
mezzi di redenzione, vedendo anzi in quei terribili momenti l’ora da sempre attesa, il
compimento della sua divina terrena avventura.
L’esempio di Gesù deve essere di luce per la nostra vita: tutto quanto arriva, quanto
succede, quello che ci circonda e anche tutto quanto ci fa soffrire noi dobbiamo saperlo
leggere come volontà di Dio che ci ama o una permissione di Lui che ancora ci ama.

Allora tutto risulterà più che interessante nella vita; tutto avrà senso; tutto sarà
estremamente utile.

Coraggio: siamo ancora vivi. Siamo ancora in viaggio. La vita può ancora tradursi in una
divina avventura. Il disegno di Dio su di noi può ancora compiersi. Basta amare e tener gli
occhi aperti alla sua sempre splendida volontà.$doc1614$, 'drive_import', '01614-WEB-1984-06-21-la-divina-avventura-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1614)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1615, 'ITA', $doc1615$Mollens (CH), 2.8.1984

AMARE LA PROPRIA CROCE

Carissimi,

Vorrei anche questa volta parlarvi della Parola di Vita, riagganciarmi così all’ultimo
Collegamento e rivedere di nuovo con voi la possibilità di fare della nostra vita una divina
avventura.

Perché ve ne parlo? Perché l’argomento mi sembra di grande importanza e perché
soprattutto con le prime focolarine ed i primi focolarini che si sono sforzati, con la grazia di
Dio, di vivere così fin dai primi anni del Movimento, posso testimoniare quale straordinario
risultato si può raggiungere abbandonandosi completamente al Signore e lasciando a Lui di
indicarci giorno per giorno i passi da compiere per adempiere il suo disegno d’amore su
ciascuno di noi.

Per noi l’avventura divina ha avuto questo risultato: vedere sorgere nel mondo un’Opera di
Dio nuova, originale, moderna, di grandissima attualità; vederla piantare le sue radici
profondamente nel terreno della Chiesa e ammirarla mentre dilatava, con gli anni, i suoi
rami fino agli ultimi confini della terra.

Immaginiamo perciò se, nella diversità dei vari progetti di Dio su ciascuna persona, ogni
uomo al mondo si sforzasse di lasciare a Lui di svolgere il suo programma nella propria vita!
Certamente cambierebbe presto la faccia della terra.

Intanto, questi pensieri spingano tutti noi a non venir meno al nostro personale impegno e,
perché ciò sia, vediamo ancora una volta quale deve essere la nostra parte perché la vita che
ci resta si trasformi in una divina avventura. Tutto concorre al bene... tutto, dunque,
possiamo vedere finalizzato al bene. “Tutto concorre al bene [ma] per quelli che amano
Dio”. Amare Dio! Noi lo vogliamo amare certamente. Ma quando si è sicuri di amarlo? Non
solamente se diamo a Lui il nostro cuore allorché tutto va per il meglio, perché ciò è facile, è
bello, ma può essere anche frutto di entusiasmo o essere mescolato all’interesse personale,
all’amore di noi e non di Lui. Siamo certi di amarlo se lo amiamo anche nelle avversità: anzi
se, per garantirci l’amore vero, abbiamo deciso di preferirlo proprio in tutto ciò che ci fa
male. Amare Dio nelle contrarietà, nei dolori, è sempre amore vero, sicuro. Noi esprimiamo
questo amore con le parole: amare Gesù crocifisso e abbandonato.

Far della vita una divina avventura, allora, essere sicuri che tutto nella nostra vita passata,
presente e futura è materia prima per veder realizzarsi il disegno di Dio su di noi, richiede
una riscelta di Gesù Abbandonato

Ma quale croce, quale Gesù Abbandonato dobbiamo desiderare di amare, dobbiamo amare?
Non certo una croce generica, come quando si dice: voglio far mie le croci dell’Opera o i
dolori dell’umanità. Non una croce frutto della nostra fantasia che sogna, per esempio, il
martirio che magari non ci sarà mai.

Gesù per essere seguito ha detto: “Chi vuole venire dietro a me, prenda la sua croce” (cf. Lc
9, 23). La sua! Dunque, ciascuno deve amare la propria croce, il proprio Gesù Abbandonato.
Se egli, infatti, in uno slancio d’amore a un dato momento della nostra storia si è presentato
alla nostra anima ed ha chiesto di seguirlo, di sceglierlo, di – come si dice – sposarlo, non
intendeva manifestarsi in modo vago a ciascuno di noi, ma preciso. Ci domandava di
abbracciarlo in quei dolori, in quei disturbi, in quelle malattie, in quelle tentazioni, in quelle
situazioni, in quelle persone, in quei doveri che toccano la nostra persona, sì da poter dire:
“Questa è la mia croce”, anzi: “Ecco il mio Sposo!”. Perché ognuno ha il proprio personale
Gesù Abbandonato, che non è quello del suo fratello, né di tutti gli altri fratelli, ma è proprio
il suo.

E ciò, se sappiamo leggere al di là della trama delle varie personali sofferenze, l’amore di Dio
per ognuno di noi, è stupendo e ci invoglia ad affezionare a questo nostro Gesù
Abbandonato, ad abbracciarlo, come facevano i santi, ad attendere di vederlo in noi
trasfigurato da una risurrezione tutta nostra, dato che il “Gesù” in me è anch’egli diverso dal
“Gesù” del mio fratello.

E allora?

Allora non perdiamo tempo. Un piccolo esame sulla nostra situazione personale e
decidiamo, con l’aiuto di Dio, di dire sì a tutto ciò a cui verrebbe da dire no, ma che
sappiamo essere volontà di Dio.

Se così faremo, tutto avrà profondo significato. A volte saremo come il chicco di grano che,
perché sa morire, vedrà fiorire la spiga; a volte come il ramo che, perché si lascia potare,
vedrà frutti di prima scelta.

In questi quindici giorni alziamoci al macino con questo proposito in cuore: “Oggi vivrò
soltanto per amare il mio Gesù Abbandonato”.

E tutto sarà fatto. Il Risorto vivrà in ciascuno di noi e tra di noi e dispiegherà verso nuovi
orizzonti la sua Opera, a sua gloria e a gloria di Maria, per quei fini che il Cielo sa e che, per
quanto possiamo noi intuire, sono già la nostra felicità sulla terra.$doc1615$, 'drive_import', '01615-WEB-1984-08-02-amare-la-propria-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1615)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1616, 'ITA', $doc1616$Mollens (CH),16.8.1984

LA DIRETTIVA DEL PAPA:

“CRESCETE E MOLTIPLICATEVI”

Carissimi,

È ancora nei nostri cuori la gioia particolarissima per la visita del Santo Padre al Centro del
Movimento e la gratitudine a Maria che, nel giorno dell’Assunta, gliel’ha – pensiamo –
suggerita.

È stato un fatto straordinario. Non solo per lui che così l’ha definito per il suo contenuto, ma
– come potete immaginare – è stato un avvenimento straordinario soprattutto per noi.

Ora tutto al Centro ci sembra benedetto e più che benedetto: il Consiglio di Coordinamento,
che egli ha conosciuto nelle sue varie persone, le sessanta fra case e appartamenti che
costituiscono la Mariapoli Romana, che egli vede un po’ in piccolo come un’immagine della
struttura centrale della Chiesa.

In quest’Opera, infatti, della Chiesa, per la presenza di laici variamente consacrati, di
giovani, di famiglie, di gente impegnata nel mondo, di sacerdoti, di religiosi e suore; per la
presenza dei vari aspetti e perché si vive per i principali scopi della Chiesa, in quest’Opera
egli vede non solo una componente della Chiesa, ma la stessa fisionomia della Chiesa. Anzi
vede la fisionomia della Chiesa così come essa s’è autodefinita nel Concilio Vaticano II.

Ma ora anche tutto il Movimento ci sembra più che benedetto. Il Papa s’è detto cosciente
dell’unità che ci lega tutti ed ha parlato per voi tutti nel mondo.

E adesso che l’Opera intera ha ricevuto quest’ampia benedizione del Cielo per mezzo del
Vicario di Gesù in terra, urge nel nostro cuore un profondo desiderio di far tutto bene, di
mantener accesi tutti i cuori, di pregare meglio, molto meglio, di conservare pulite e
ordinate le cose e le case, funzionanti gli uffici e così via.

Il Santo Padre ha costatato anche la solidità del Movimento, l’ha visto ben definito e non ha
ritenuto di dar nessun indirizzo particolare. Eppure, affascinato – ci sembra – dalla bellezza
di quest’Opera, una direttiva gli è uscita dal cuore: “Crescete e moltiplicatevi”.

Ed è questa la parola che cercheremo di mettere in pratica nel migliore dei modi
incominciando dai prossimi quindici giorni.

Crescere: e si può far questo vivendo il nostro splendido ideale che è – come ha devo il Papa
– amore, la radicalità dell’amore. Quell’amore che non lascia l’ultima parola alla disunità,
alle divisioni, all’odio, ma vince tutto. È più forte di tutto. E noi sappiamo che questa
radicalità la troviamo contemplando e amando Gesù Abbandonato vertice ed esempio
dell’amore più grande.

E moltiplicarsi. Come? Rivolgendo, intanto, un pensiero alle nostre responsabilità: ai nostri
“grappoli”, alle nostre comunità. Vedere quello che c’è da fare. Donarsi senza misura ma
secondo l’Ideale, con la fede in Dio che opera anche quando noi non possiamo. E dar
un’occhiata alle nostre carte geografiche, quelle carte che abbiamo mostrato anche al Santo
Padre. Osservare a che punto siamo, dove il Movimento non è ancora sviluppato, dove
mancano nodi alla rete dell’ut omnes”. E poi rendersi conto se è tutto vivo quello che
abbiamo segnato, se è in atto nelle nostre zone, e particolarmente nella parte che più ci
riguarda, la rivoluzione d’amore che tanta speranza ha dato al cuore del Papa.

“Crescete e moltiplicatevi”. Noi sappiamo come le due realtà sono connesse tra loro: più si
cresce dentro più ci si moltiplica fuori, perché più si ama. Ma anche: più riusciamo a
moltiplicare e più cresce l’amore di Dio dentro di noi.

Così allora, e avanti. Guardiamo sempre a Maria, la nostra condottiera.

La divina avventura continua. C’è da inginocchiarsi in adorazione di Dio che è stato così
amore per noi. E non dimentichiamo in quest’ora così dolce e solenne chi ci ha preceduto e
ha lavorato e ha sofferto ed è passato nell’Altra Vita tutto offrendo per il nostro Movimento.
Che lo Spirito Santo accomuni tutti noi della Mariapoli terrestre e celeste in un solo inno di
ringraziamento ed in un proposito solenne di far tutto sempre meglio.

Ricordate: “Crescete e moltiplicatevi”.$doc1616$, 'drive_import', '01616-WEB-1984-08-16-la-direttiva-del-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1616)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1617, 'ITA', $doc1617$Mollens (CH), 6.9.1984

IMPARIAMO AD ESSERE PERSONE DI PREGHIERA

Carissimi,

Sollecitati dalle incoraggianti parole del Santo Padre, abbiamo cercato in questi ultimi
quindici giorni di vivere il suo “Crescete e moltiplicatevi”. Oggi vogliamo vedere in che modo
la Parola del mese in corso può aiutarci in questo senso. Essa ci dice: “Qual vantaggio avrà
l’uomo se guadagnerà il mondo intero e poi perderà la propria anima?” (Mt 16, 26).

Conosciamo, attraverso il commento, quello che Gesù voleva dire con queste parole. Per noi,
membri cosiddetti “interni” dell’Opera di Maria, essa può avere anche questo significato:
Qual vantaggio potreste avere nel lasciarvi trascinare, a volte, ad una attività apostolica
frenetica, ad una quasi “eresia dell’azione” – come si dice –, che assorbe praticamente tutto
il vostro tempo, quando è per voi volontà di Dio crescere in tutti i sensi? Che importa darsi
tanto da fare per conquistare a Dio molte persone quando la vostra anima rimane piccola e
imperfetta, perché non trova ad esempio un’ora veramente tranquilla per quel suo tipico
nutrimento che è la preghiera? Quando quelle preghiere che sono per voi un sacrosanto
dovere sono fate in mezzo a tante distrazioni, sono dette superficialmente ed in fretta o
vengono abbreviate?

Certamente la Parola del mese è, per quelli fra noi che si comportano in questo modo, un
ottimo correttivo per metterli nella linea giusta del crescere interiormente, risveglia in noi
quella esigenza del porro unum (“una sola cosa è necessaria”, Lc. 10, 42), che è l’unione con
Dio.

Inoltre, la Parola del mese ci rimette anche nel binario esatto per svolgere il nostro
apostolato, il nostro “moltiplicatevi”. Esso infatti fondamentalmente non deve essere
nient’altro che irradiazione del nostro amore per Iddio.

Ma se questo amore viene meno, perché non c’è unione con Dio senza preghiera, che cosa
potremo irradiare?

La preghiera, dunque! Rivedere in questi quindici giorni la nostra vita di preghiera per farla
emergere nelle diverse pratiche della giornata e nei momenti in cui ci rivolgiamo a Dio
spontaneamente come il sottofondo luminoso, in tutto quanto facciamo, del nostro amore
per Dio.

E come ci comporteremo perché ciò sia?
Anzitutto, nel fare i nostri programmi mensili, settimanali, giornalieri diamo spazio alla
preghiera.

Cerchiamo perciò di non stancarci troppo prima del suo momento perché non arriviamo
davanti a Dio privi di forza, di capacità di concentrazione; perché non siamo costretti a dare
a Lui gli attimi meno felici della nostra giornata. Prima di pregare vediamo di premettere
sempre un momento di raccoglimento.

Poi preghiamo col cuore, accompagniamo con l’anima quanto dicono le parole.

Abbiamo già parlato una volta della necessità della preghiera per chiedere le grazie di Dio e
non appoggiarci così solo sulle nostre forze.

In questi quindici giorni rivediamo tutte le nostre preghiere: anche quelle con le quali
adoriamo Dio, lo lodiamo, gli chiediamo perdono per noi e per tutti, lo ringraziamo.

Guardiamo un po’ se la nostra meditazione o il nostro “andare in profondità” è fatto nel
migliore dei modi. Perfezioniamo le nostre preghiere del mattino e della sera; quelle che
diciamo durante la visita al SS. Sacramento. Vediamo com’è la recita del rosario. Soprattutto
diamo uno sguardo alla Messa quotidiana e al modo con cui riceviamo l’Eucaristia.

Ce ne sarebbe di nutrimento per l’anima se tutto fosse fatto bene! Non sperperiamolo quasi
fosse cosa secondaria, che non merita tutta la nostra attenzione. Preghiamo coi fratelli,
quand’è possibile, per dar forza alla nostra preghiera. E preghiamo nel segreto della nostra
stanza, come vuole il Vangelo.

Ma giacché non sono certo questi i tempi in cui chi prega in pubblico corre il rischio di
gonfiarsi di vanagloria perché viene lodato, manifestiamo anche in faccia al mondo, –
quando è il caso, – la nostra fede; ripristinando il segno di croce ad esempio davanti alle
chiese o ai luoghi sacri; facendolo prima di mangiare anche in un albergo o all’inizio d’un
viaggio in treno o in macchina o in aereo, per richiamare possibilmente, anche in questo
modo, i troppo distratti a ciò che più vale.

Insomma, impariamo ad essere vere persone di preghiera ed offriamo a Dio anche tutto
quanto facciamo durante il giorno, per trasformare ogni cosa in preghiera.

Così tutto andrà meglio. Il nostro Santo Viaggio avrà il carburante necessario.

Se è vero che “chi prega si salva e chi non prega si danna”, è ancor più vero che solo chi
prega può santificarsi. E non è alla santità che puntiamo tutti insieme? Non è quello il primo
scopo di questo nostro Collegamento?$doc1617$, 'drive_import', '01617-WEB-1984-09-06-impariamo-ad-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1617)
on conflict (document_id, language) do nothing;
