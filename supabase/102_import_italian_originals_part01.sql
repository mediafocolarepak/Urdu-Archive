-- 102_import_italian_originals_part01.sql (1/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1558-1577 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1558, 'ITA', $doc1558$IL SANTO VIAGGIO

Rocca di Papa, 3.9.1981

Carissimi,

Il motivo che mi spinge a rivolgermi a voi è il desiderio di esaminare assieme la situazione
in ordine alla nostra santificazione. In questi giorni una focolarina mi ha segnalato una
bellissima frase dei Salmi, che annuncia una beatitudine che non conoscevo: “Beato l’uomo
che pone la sua fiducia in te e decide nel suo cuore il santo viaggio”.

"Il Santo Viaggio". Di che viaggio parla la Scrittura? Certamente dell’itinerario dell’uomo
verso Dio, verso il Cielo. Dunque il viaggio della propria santificazione, che ci apre il
Paradiso.

Questa decisione d’iniziare il Santo Viaggio noi tutti l’abbiamo presa quando
abbiamo aderito alla nostra vocazione: essere focolarini. Per noi infatti, in quanto
consacrati, tendere alla perfezione è un impegno più doveroso che per altri. E allora?
Siamo veramente incamminati, anche in questo momento, nel Santo Viaggio?
Oggi che vi parlo è il 246° giorno dall’inizio dell’anno ’81, da quando cioè abbiamo preso con
più coscienza questa decisione, sospinti dall’esempio di suor Maria Gabriella della Trappa.

Il 246° giorno! Fermiamoci un po’ e facciamo un breve consuntivo davanti a Dio solo, per la
sua sola gloria. Ci sono stati dei risultati? Abbiamo migliorato nel fare, ad esempio, la
volontà di Dio? nell’amore? nell’amore reciproco? nelle rinunce a noi stessi? nelle
mortificazioni? insomma, nell’amore a Gesù Abbandonato? Se si, ringraziamo Dio e avanti!
Se no, ringraziamolo d’aver ancora la vita per ricominciare. E avanti! Vogliamo
assolutamente gustare insieme la beatitudine del Santo Viaggio!$doc1558$, 'drive_import', '01558-WEB-1981-09-03-il-santo-viaggio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1558)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1559, 'ITA', $doc1559$DICHIARARE GUERRA ALLA NOSTRA VOLONTÀ

Ottmaring, 17.9.1981

Carissimi,
Siamo dunque incamminati nel Santo Viaggio. Forse volete sapere il leitmotiv di
questi giorni. Ecco, è questo: Dichiarare guerra alla nostra volontà, visto che per
camminare in questo Santo Viaggio occorre fare la volontà di Dio.
Così noi viviamo ora, tutti insieme, i nostri momenti presenti, cercando di ammazzare la
nostra volontà per piantarci bene in quella di Dio.
Adesso mancano, pensate, soltanto 105 giorni per finire questo anno di grazia della
tensione comune alla santità. Se Dio ce li lascia tutti – e altrimenti quelli che ci lascia
– che siano tutti tutti suoi!
Ecco, questo è il mio augurio: che riusciamo veramente a farci santi; che possiamo
presentare la nostra santità alla Madonna per le mani dell’Angelo Custode.
E intanto, con questa prospettiva e questi propositi, vi do l’appuntamento per il prossimo
Collegamento.$doc1559$, 'drive_import', '01559-WEB-1981-09-17-dichiarare-guerra-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1559)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1560, 'ITA', $doc1560$PAROLA D’ORDINE: TAGLIARE

Rocca di Papa, 1.10.1981

Carissimi,

Allora siamo di corsa. Ormai mancano solo tre mesi alla conclusione dell’anno. La Madonna
ci ha portato – per soddisfare il nostro desiderio di santità – sulla via dell’ascetica cristiana.

Lo sappiamo: chi ama il prossimo perfettamente (e questa e la nostra via) è già morto a se
stesso. Ma Gesù sapeva che nella vita non sempre, ad esempio, abbiamo prossimi da amare.
Per questo parla di rinuncia e in maniera a volte fortissima. In questi giorni mi hanno
impressionato le sue parole: “Se la tua mano ti scandalizza tagliala; se il tuo piede... Se il tuo
occhio... cavalo” (cf. Mt 18, 8). Che cosa vuol dire? Vuol affermare con grande forza la
necessità di togliere tutto ciò che ci è di ostacolo alla comunione con Lui. Per noi è un invito
ad evitare non solo il male grave, ma ad annientare ogni attaccamento che non sia Lui solo.

Ecco allora che torna l’idea del tagliare, bombardare, rinunciare, ammazzare, fare guerra a
tutto ciò che non è Lui, la sua volontà nel presente. Non c’è che da vivere così. Gesù
Abbandonato, che si nasconde dietro questi tagli, queste perdite, sia il nostro unico amore.

La parola d’ordine per questi quindici giorni? Tagliare. Se qualcosa ci è di impedimento ad
amar Dio, a fare la sua volontà, distruggerla.$doc1560$, 'drive_import', '01560-WEB-1981-10-01-parola-d-ordine-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1560)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1561, 'ITA', $doc1561$AMNISTIA COMPLETA. ACCENDERE FOCOLARI DAPPERTUTTO

Rocca di Papa, 15.10.1981

Carissimi,

È questo ciò che oggi voglio sottolineare a voi tutti: l’unità. L’unità deve trionfare: l’unità con
Dio, l’unità fra tutti gli uomini. E quale il modo? Amare tutti con quell’amore di misericordia
che era caratteristico nei primi tempi del Movimento, quando si era deciso di vedere ogni
mattina, durante tutta la giornata, il prossimo che incontravamo, in famiglia, a scuola, al
lavoro ecc., dappertutto, vederlo nuovo, nuovissimo, non ricordandoci affatto dei suoi nei,
dei suoi difetti, ma tutto tutto coprendo con l’amore. Amare proprio come ci suggerisce la
Parola di Vita di questo mese: perdonare settanta volte sette. Avvicinare tutti con
quest’amnistia completa nel nostro cuore, con questo perdono universale. E poi farci uno
con loro in tutto, tranne che nel peccato, tranne che nel male. Perché? Per ottenere quel
risultato meraviglioso, a cui Paolo, l’Apostolo, aspirava. Lui diceva: “Farsi tutto a tutti – farsi
uno con tutti – per guadagnare a Cristo il maggior numero” (cf. 1 Cor 9, 19). Ecco, se noi ci
facciamo uno col prossimo, facilitati anche da questo perdono, potremo passare il nostro
Ideale agli altri. E una volta ottenuto ciò, stabilire la presenza di Gesù fra noi e loro, di Gesù
il Risorto, di Gesù che ha promesso di essere sempre con noi nella sua Chiesa, e si fa in certo
modo vedere, sentire, quando è in mezzo a noi.

Questa deve essere la nostra opera principale: vivere in modo che Gesù viva fra noi, Egli che
è il conquistatore del mondo. Se saremo uno, infatti, molti saranno uno e il mondo potrà un
giorno vedere l’unità. E allora? Costituire dappertutto cellule di unità: nella propria famiglia,
nel caseggiato, con quelli coi quali si gioca, o si studia, o si lavora, con tutti, il più possibile,
accendere questi fuochi dovunque. È in questo che dobbiamo concentrare il massimo sforzo,
perché amare così, fino a questo risultato, costa sacrifici, mortificazioni, rinunce, perdite,
bombardamenti alla nostra volontà per fare quella del prossimo.

Il nuovo assetto che dobbiamo dare al nostro Movimento nel mondo è proprio questo:
accendere fuochi, fare in modo che "Gesù in mezzo" viva dappertutto.

Se c’è Lui, se con la sua grazia lavoriamo a dargli vita, Egli farà fiorire anche, nel nostro
cuore, le più belle virtù.

Oggi portate via solo questo pensiero, e per quindici giorni viviamo così: farci uno con gli
altri per accendere focolari di amore soprannaturale in tutto il mondo.$doc1561$, 'drive_import', '01561-WEB-1981-10-15-amnistia-completa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1561)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1562, 'ITA', $doc1562$ABBRACCIARE I DOLORI PERSONALI PER ESSERE PRONTI AD AMARE

Roma, 5.11.1981

Carissimi,

Mancano 56 giorni alla fine dell’anno, questo anno meraviglioso per noi, che ha visto la
partenza decisa di molti, anzi moltissimi, senza tentennamenti e perplessità, per il Santo
Viaggio. Alla fine dell’anno faremo il consuntivo e vedremo quanto abbiamo progredito con
l’aiuto di Dio e a sua gloria. Intanto però dobbiamo considerare assai preziosi i giorni che ci
rimangono, se Dio ce li darà. Essi ci offrono la possibilità di riguadagnare terreno qualora
l’avessimo perduto.

Dunque: vogliamo farci santi, ma tutti insieme.

Quale la meta da raggiungere fino al prossimo Collegamento? Lo sapete: il nostro Ideale, la
volontà di Dio su di noi, che viene particolarmente sottolineata in questo nuovo anno, è
l’unità. Nello stesso tempo ogni mese ci viene proposta una Parola di Vita, presa dalla
liturgia, da vivere in profondità. Per il mese di novembre, la Parola è: “Beati gli afflitti,
perché saranno consolati” (Mt 5, 4).

Come possiamo vivere l’unità e nel medesimo tempo la nuova Parola? Così: vivendo
benissimo, giorno dopo giorno, la Parola come aiuto per attuare l’unità. Vivere la Parola,
insomma, in funzione dell’unità.

Mi spiego.

“Beati gli afflitti, perché saranno consolati”. Noi dobbiamo rivestirci di questa beatitudine,
dobbiamo sperimentare questa consolazione. Il dolore vale. Dobbiamo abbracciare il dolore
quotidiano sempre subito, con gioia. Abbracciare anche sempre, subito, con gioia quelle
morti che noi stessi procuriamo al nostro io, quando recalcitra. Se così faremo, il dolore si
tramuterà in gioia, in pace, in consolazione. Ed essendo nella pace, potremo amare tutti
quelli che incontriamo, ci sentiremo liberi e atti a farci uno con loro e vivere quindi l’unità.

Semplificando: abbracciare bene i dolori personali per essere pronti ad amare i prossimi.
Ecco il cammino che ci proponiamo, tutti insieme, per i quindici giorni che ci stanno
dinnanzi.

Allora coraggio e avanti!$doc1562$, 'drive_import', '01562-WEB-1981-11-05-abbracciare-i-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1562)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1563, 'ITA', $doc1563$CAMPIONI D’UNITÀ

Rocca di Papa, 3.12.1981

Carissimi,

Eccoci nell’ultimo mese dell’anno. Dalle vostre lettere, dai messaggi, dai telegrammi ho
saputo che alcuni, che ancora non s’erano decisi per il Santo Viaggio, si sono messi
decisamente "in treno" – come dicono i nostri Gen – pronti a viaggiare con tutti gli altri a cui
arriva questo Collegamento.

Che dirvi oggi? Proprio in questi giorni ho visto alla televisione delle giovanissime atlete,
per la maggior parte dei paesi dell’Est, che si esibivano in meravigliosi esercizi di ginnastica
artistica. Erano magnifiche nei loro ripetuti salti mortali, negli avvitamenti, in ogni mossa.
Quale perfezione! Quanta armonia e quanta grazia! Possedevano perfettamente il loro fisico,
tanto che gli esercizi più difficili parevano naturali. Sono le prime del mondo.

Più volte, mentre le ammiravo, avvertivo dentro di me un pressante invito (forse dello
Spirito Santo). Era come se Qualcuno mi dicesse: Anche tu, anche voi, dovete diventare
campioni del mondo. Campioni in che cosa? Nell’amare Dio. Ma sai quanto allenamento è
occorso a queste ragazze? Lo sai che, giorno dopo giorno, per ore e ore, ripetono gli stessi
esercizi, senza arrendersi mai? Anche tu, anche voi, dovete fare altrettanto. Quando?
Nell’attimo presente. Sempre, senza fermarsi mai. E mi nasceva in cuore un grandissimo
desiderio di lavorare, momento per momento, per arrivare alla perfezione.

Carissimi, dice san Francesco di Sales che non c’è indole così buona che a forza di ripetuti
atti viziosi non possa acquistare il vizio. E allora, si può pensare che non vi è indole così
cattiva che a forza di atti virtuosi non possa acquistare la virtù. E quindi: coraggio! Se ci
alleniamo, diverremo campioni del mondo nell’amare Dio.

Questo mese la Parola di Vita dice: “Eccomi, sono la serva del Signore, si faccia di me
secondo la tua parola” (Lc 1, 38). Anche noi dobbiamo dire come Maria: “...Si faccia di me
secondo la tua parola”.

Quale la Parola detta da Dio al nostro Movimento? Lo sappiamo: Unità. E allora, dobbiamo
diventare campioni d’unità con Dio, con la sua volontà nell’attimo presente, e di unità col
prossimo, con ogni prossimo che incontriamo durante la giornata.

Su su, alleniamoci senza perdere minuti preziosi. Ci attende, non la medaglia d’oro, ma il
Paradiso e di riflesso, e per la Comunione dei Santi, tanto bene su tutti i nostri fratelli.$doc1563$, 'drive_import', '01563-WEB-1981-12-03-campioni-d-unit-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1563)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1564, 'ITA', $doc1564$DAR VITA A GESÙ FRA NOI

Tokio, 17.12.1981

Carissimi,

Tra pochi giorni arriva Natale. E prima che ci risentiamo un’altra volta, si concluderà
il primo anno del nostro comune deciso impegno per la santificazione. Come sapete,
il Natale ci ricorda un punto essenziale della nostra spiritualità e una norma
fondamentale del nostro caratteristico modo di vivere. Ma ciò che il Natale ci
rammenta è più che un punto, è più che una norma: è una realtà, è la grande realtà
che tutti siamo chiamati ad offrire al mondo. È Gesù che in certo modo nasce e vive
in mezzo a noi, se viviamo e rinnoviamo sempre il nostro reciproco amore. Dar vita
a Gesù fra noi è per noi il primo dovere. È il perché fondamentale del nostro
Movimento. E forse è per questo che mi passa per l’anima, in questi giorni, un
pensiero che è anche un ammonimento: “Non puoi prenderti il lusso di farti santa, se
il Santo non è fra voi. Non puoi illuderti di diventare perfetta, se il Perfetto non è fra
voi”.

E allora? Allora penso che la strada giusta per noi sia proprio questa: stabilire e
ristabilire la sua presenza fra di noi con quell’amore di servizio, di comprensione, di
partecipazione ai dolori, ai pesi, alle ansie e alle gioie dei nostri fratelli, con
quell’amore che tutto copre, che tutto perdona, tipico del cristianesimo. Assicurarsi
che per questo amore il Risorto, che ha promesso di essere con la sua Chiesa fino
alla fine del mondo, è anche tra di noi. E su questa base vivere attimo dopo attimo la
volontà di Dio bene, perfettamente, con la rinuncia più radicale alla nostra volontà.
Questo dobbiamo fare negli ultimi quindici giorni dell’anno, in cui la Parola di Vita ci sprona
ad attuare, come Maria, la volontà di Dio. Per noi, un po’ come per Lei, la prima volontà di
Dio è quella di dar vita a Gesù. Così ci perfezioneremo davvero come campioni d’unità coi
fratelli e con Dio.

E allora, a tutti tutti: Buon Natale! E ricordatevi che Gesù può essere fra di noi anche a
distanza.

Ancora auguri a tutti!
1982$doc1564$, 'drive_import', '01564-WEB-1981-12-17-dar-vita-a-ges-fra-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1564)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1565, 'ITA', $doc1565$LA CANDELA ACCESA

Hong Kong, 7.1.1982

Carissimi,

Un saluto, oggi, da Hong Kong.

Allora è iniziato l’82. Un anno di Santo Viaggio è concluso! Ringraziamo Dio. Speriamo che
con la tensione alla santità, che esso ha comportato, abbiamo potuto cantare il Te Deum per
meno peccati commessi e più atti d’amore offerti.

Ora nell’82 dobbiamo dare un colpo all’acceleratore. L’Estremo Oriente, in questi
giorni ci ha portati a più propositi. Ve ne dico due. Il primo è questo: diventare tutti
“locomotive”. Molti Gen, infatti, per raffigurare il Santo Viaggio, disegnano o
costruiscono un treno. E spesso mettono il mio nome sulla locomotiva. Dio sa chi è
che spinge di più. Certamente chi più ama.
Comunque da questo fatto dobbiamo trarre un proposito: quest’anno nessuno dei 43 mila,
che sono in cammino nel Santo Viaggio, può prendersi il lusso di essere un semplice vagone.
Tutti locomotive. Come? Trascinando con noi, in questa corsa verso Dio, almeno una
persona. Ecco il primo proposito.

Poi il secondo: a contatto coi nostri fratelli buddisti, abbiamo saputo che uno dei loro
simboli è la candela spenta. Essa significa totale mortificazione, assenza totale di desideri.
Ed essi sono ammirevoli per il modo con cui praticano questo.

Noi cristiani invece abbiamo la candela accesa. Gesù infatti ci ha portato la grazia, la vita
divina. Ha acceso il fuoco nel nostro cuore. Con esso possiamo e dobbiamo amare Dio e il
prossimo, facendo la volontà di Dio tutta intera nel presente e facendoci uno col prossimo.
In questa maniera muore anche in noi ciò che è terreno, si spengono i desideri e le passioni.
E allora ecco il secondo proposito: candele accese!

Locomotive e candele accese, dunque, in questi quindici giorni.$doc1565$, 'drive_import', '01565-WEB-1982-01-07-la-candela-accesa-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1565)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1566, 'ITA', $doc1566$RIPARARE PER MEGLIO AMARE

Rocca di Papa, 19.11.1981

Carissimi,

Siamo ancora per alcuni giorni nel mese di novembre e, come sapete, la Parola di
Vita che dobbiamo tradurre in pratica e della quale dobbiamo comunicarci le
esperienze, è: “Beati gli afflitti, perché saranno consolati”. Abbiamo dunque ancora
una diecina di giorni per viverla bene, fino in fondo, sfruttando per la gloria di Dio e
la nostra santificazione individuale e collettiva, tutto il suo ricchissimo, divino
contenuto. Come sapete, la Parola di Dio non è come le parole umane. In essa vi è
una presenza di Dio, del Verbo, il quale è la Parola pronunciata dall’eternità dal
Padre. Dunque, nutrendoci della Parola, ci nutriamo di Dio, di luce per illuminare
anche gli altri e di amore che riscalda il nostro cuore e può infiammare i fratelli.

Come vivremo in questi giorni la Parola? Penso che, se sono beati gli afflitti che subiscono il
dolore da loro non cercato, ma che arriva così, dal di fuori, sono senz’altro – e forse di più –
beati quelli che lo cercano per amore di Dio, per seguire Gesù, per camminare più spediti nel
Santo Viaggio. Ora, vi sono molte pratiche che fanno male e con le quali dobbiamo
"affliggere" il nostro io, per essere discepoli di Gesù: le rinunce, per esempio, le perdite di
ciò che non è volontà di Dio, i tagli, i distacchi ecc. Per questi dieci giorni ve ne proporrei
una particolare in questo viaggio verso la santità. Mi è stato detto che nessuno si è fatto
santo senza qualche penitenza anche corporale.

E allora?

Io direi di fare così. Per vivere bene la Parola di Vita, ogniqualvolta costatiamo d’aver
sbagliato in qualcosa, cerchiamo di fare qualche penitenza per riparare al bene non fatto.
Per esempio: siamo stati scontrosi col prossimo? Lo abbiamo urtato, l’abbiamo giudicato
male? Cerchiamo di rimediare raddoppiando la dolcezza, parlando bene di lui, difendendolo
se occorre, dimenticando completamente gli eventuali torti, come proprio non fosse
successo nulla.

Un altro esempio. Abbiamo mangiato senza pensare a frenare la gola? Al pasto seguente
offriamo a Gesù una mortificazione adeguata. Abbiamo pregato senza attenzione, come
proprio non parlassimo a nessuno? Raccogliamoci un momento in profonda preghiera. E
così via. Ci sono mille e mille modi di riparare.

Ho provato anch’io a fare così. Vi assicuro che subentra nell’anima una certa pace, una certa
gioia. Si ha l’impressione che, almeno in quel momento, siamo in unione con Dio. E, con
questa pace nel cuore, diventa più facile vivere l’unità. È facilitato l’amore al prossimo, il
vivere l’altro, come noi diciamo, il farci uno col fratello che dobbiamo servire, come Gesù
che, pur Signore e Maestro, ha lavato i piedi ai discepoli.

Concludendo e riassumendo: riparare per poter meglio amare.$doc1566$, 'drive_import', '01566-WEB-1981-11-19-riparare-per-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1566)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1567, 'ITA', $doc1567$ORDINAMENTO "A GRAPPOLO

Tagaytay (Filippine), 21.1.1982

Carissimi,

Nell’ultimo Collegamento abbiamo deciso per questo nuovo anno di non essere
come vagoni in questo Santo Viaggio, ma come locomotive, che trascinano altri. E, se
così facciamo, il nostro ordinamento sarà, per così dire, "a grappolo".
Una delle gioie che ho provato in questo rapido passaggio attraverso le zone asiatiche, è
costatare come qui fanno sul serio, e attuano immediatamente quanto si dice. A Hong Kong,
ad esempio, a conclusione di un incontro infuocato, un Gen rivolge la parola a una di noi e
dice: “Ti presento il mio grappolo”, e le fa conoscere alcuni giovani con cui condivide lo
stesso Ideale, che lui segue, ama, serve, per farsi santi insieme. Poi aggiunge: “E ora ti
presento il mio responsabile”, e le mostra chi si prende cura di lui.

Carissimi, vorrei che tutti potessimo dire al più presto come quel Gen, vorrei che tutti
potessimo presentarci gli uni gli altri in quel modo. E soprattutto, davanti a Dio, ora e alla
fine della vita.

Vorrei che tutti imitassimo anche quelle meravigliose volontarie di un nucleo a Manila. Qui,
il clima equatoriale fa in modo che non solo il frutto dell’uva venga a grappolo, ma molti
altri: il cocco, il mango, le banane, il mangustin, ecc. Ebbene, esse mi hanno salutato, al mio
arrivo qui, con un cartellone: al centro una foto di gruppo, coi loro volti, belli, luminosi,
sicuri, e intorno le loro firme; sotto ognuna, un grappolo diverso.

Ecco, così così anche tutti noi. Questa la consegna per i prossimi quindici giorni. Che Dio
Padre non debba chiederci: “E dove sono i tuoi fratelli?”.$doc1567$, 'drive_import', '01567-WEB-1982-01-21-ordinamento-a-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1567)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1568, 'ITA', $doc1568$SEMPRE AVANTI

Melbourne, 2.2.1982

Carissimi,

Oggi vi mando un saluto dall’Australia.

Siamo dunque ancora in cammino nel Santo Viaggio e non possiamo fermarci e tanto meno
retrocedere. Ha detto Gesù: “Chi mette mano all’aratro e guarda indietro non è atto al regno
di Dio” (Lc 9, 62).

Questo giovane continente, l’Australia, ce lo ricorda poi col suo stemma che porta due
animali locali, scelti appositamente perché non sanno camminare indietro: il canguro – il
famoso canguro! – e un uccellone di nome “emù”.

Anche noi dobbiamo camminare sempre avanti, con coraggio. E per camminare, lo
sappiamo, abbiamo la Parola di Vita, che è “lampada per i miei passi” – dice un salmo – e
“luce sul mio cammino” (Sal 118, 105). In questo mese la Parola è: “Mi sono fatto debole coi
deboli, mi sono fatto tutto a tutti... per guadagnarne il maggior numero” (1 Cor 9, 22.19). È
questa una Parola che noi dobbiamo amare in maniera del tutto particolare. Essa infatti ci
ricorda il metodo di chi segue la via dell’unità per arrivare all’“ut omnes”. Farsi uno con ogni
prossimo. Sì, questa è la strada, perché è quella stessa percorsa da Dio per manifestarci il
suo amore: si è fatto uomo come noi e crocifisso e abbandonato per mettersi al livello di
tutti; veramente debole con i deboli. E così ha dato il via all’“ut omnes”. Si è piegato verso di
noi, non si è spezzato. Esattamente come la canna di bambù, di cui nelle Filippine, ad
esempio, si fanno tanti usi, perché si piega ma non si spezza.

Noi siamo chiamati a concorrere all’“ut omnes” e allora, prima di tutto, ravviviamo la nostra
fede che ogni uomo è chiamato all’unità, perché Dio ama tutti. E non adduciamo scuse:
quello non capirà mai, quello è troppo piccolo per comprendere, quello è un mio parente e
lo conosco bene, è attaccato alle cose della terra, quello crede nello spiritismo, quello ha
un’altra fede, quello è troppo vecchio per cambiare... No: bando a tutti questi giudizi. Tutti
Dio ama, tutti aspetta. Per noi l’unico dovere è amare ciascuno, servirlo, facendoci uno fino
in fondo, tranne nel peccato. Penserà Gesù a conquistarlo, se non ora, fra dieci o venti o
trent’anni, ma verrà. È la mia esperienza.

E allora concludiamo: quale lo sforzo in questi quindici giorni? Rivedere il nostro rapporto
con tutti i nostri prossimi, farci uno con ciascuno per impostare bene la nostra battaglia per
l’“ut omnes”.$doc1568$, 'drive_import', '01568-WEB-1982-02-02-sempre-avanti-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1568)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1569, 'ITA', $doc1569$ALLARGARE IL CERCHIO

Rocca di Papa, 18.2.1982

Carissimi,

Ecco anche oggi qualche pensiero per incoraggiarci a vicenda nel Santo Viaggio che abbiamo
intrapreso tutti insieme, e cioè nel cammino verso la nostra santificazione collettiva con
l’aiuto della grazia di Dio e per la sola gloria di Dio!

Per viaggiare – come sappiamo – abbiamo la lampada della Parola di Dio.

La Parola di Dio! Ci rendiamo conto di che cosa sia la Parola di Dio? Fa sempre impressione
il confronto che la Scrittura stabilisce tra questa e l’uomo. “Ogni uomo è come l’erba e tutta
la sua gloria è come un fiore del campo. Secca l’erba, appassisce il fiore, ma la parola del
nostro Dio dura sempre” (Is 40, 6.8). Ecco cos’è la Parola.

Dobbiamo aver dunque un immenso rispetto per essa. Dobbiamo esaminarci sul come la
consideriamo. Spesso la limitiamo coi nostri piccoli ragionamenti, forse ci sembra cosa
risaputa, a volte non la riteniamo utile al nostro caso e la eliminiamo o, dopo averla vissuta
un po’, ci sembra esaurita. Sempre certamente non la comprendiamo come essa merita. Il
fatto è che noi passiamo ed essa rimane: le parole di Gesù non passeranno mai.

Che fare allora? Averne il più giusto concetto possibile, come di una presenza di Cristo quale
essa è, e sentire tutto l’onore di poterla vivere, di rivestirci di essa.

In questo mese la Parola ci ripete: “Mi sono fatto debole coi deboli, per guadagnare i deboli;
mi sono fatto tutto a tutti, per salvare ad ogni costo qualcuno” (1 Cor 9, 22).

Qualcuno ci ha chiesto: fin dove devo farmi uno con ogni prossimo per amarlo, per
servirlo, per arrivare presto o tardi all’unità? La risposta ce la dà Gesù stesso. Egli si
è fatto uno con noi, facendosi uomo; poi ha provato la nostra stanchezza, la nostra
sofferenza, ha sperimentato persino la morte. Tutto ha sperimentato del nostro
stato, tranne il peccato. Così anche noi: dobbiamo farci uno con chiunque
incontriamo nell’attimo presente della vita. Dobbiamo vivere le sue preoccupazioni,
i suoi dolori, le sue gioie: ogni cosa, tranne il peccato.
Allora e solo così, questo modo cristiano d’amare avrà benedizione e sarà fecondo. E molti
risponderanno. E il cerchio di chi vuol Dio come Ideale, s’allargherà attorno a ciascuno di
noi come quello di un sasso gettato nell’acqua. E questo era anche l’obiettivo di Paolo che ha
detto: “...mi sono fatto servo di tutti per guadagnarne il maggior numero” (1 Cor 9, 19).
Avanti allora: allarghiamo il cerchio del Regno di Dio.
Sono con voi sempre.$doc1569$, 'drive_import', '01569-WEB-1982-02-18-allargare-il-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1569)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1570, 'ITA', $doc1570$ESSERE LA SUA PAROLA

Sierre, 15.3.1982

Carissimi,

Eccoci ancora – e speriamo di esserlo per tutta la vita – nel Santo Viaggio, che ci siamo
proposti di fare tutti insieme: e non è certo per una mania di perfezionismo o per nutrire il
possibile nostro orgoglio che facciamo questo, e neanche per essere meglio degli altri, ma
per santificarci a gloria di Dio, perché Lui lo vuole: “È volontà di Dio la vostra
santificazione”, ha detto san Paolo (1Ts 4, 3).

Allora, anche in questi prossimi quindici giorni: avanti, avanti senza soste e, se ci siamo
fermati un po’, come può succedere, abbiamo un motivo in più per rimetterci con maggior
lena a camminare.

“Sii santa – mi scriveva un giorno Madre Teresa di Calcutta – ...perché Gesù è santo”. Proprio
così, dobbiamo divenir santi perché Gesù è santo. E noi diverremo santi, vivendo la Parola.
Anzi, lo sappiamo, chi vive la Parola, almeno nel momento in cui la vive, è già santo. “Chi
ascolta la Parola – ha detto Gesù – (e cioè l’accoglie nel proprio cuore e la pratica) è già
mondato”.

Allora, se le cose stanno così, è chiaro che ci si farà santi essendo il più possibile, ogni
momento, anche adesso, la Parola di Dio viva, essendo "Parola".

Carissimi, oggi vogliamo capire meglio come vivere bene la Parola.

La Parola va vissuta come la cosa più importante da fare nella vita. Quante volte il nostro
cuore è attirato verso tante cose del mondo che ci circonda o che sono dentro di noi! E
quanto spesso diamo il primo posto per esempio al lavoro, all’apostolato, o allo studio,
anche magari a un hobby, al divertimento; quante volte siamo dominati da una vanità, o
vincolati da un affetto. Quando non siamo schiavi di cose che non piacciono per niente a Dio.
Ecco: in genere viviamo la nostra vita distribuendo l’attenzione della nostra intelligenza,
l’affetto del nostro cuore, la tensione della nostra volontà solamente, in pratica, verso cose
di questa terra. E allora che posto occupa la Parola? La ricordiamo di tanto in tanto, e tutto
qui.

No, questa non è la vita che Gesù chiede a noi. La Parola deve essere, fra tutti, il
nostro primo amore, deve essere il pilastro su cui poggia la nostra esistenza, la
radice su cui la nostra vita fiorisce. È la Parola che deve illuminare, momento per
momento, ogni nostra attività, raddrizzare e correggere ogni espressione della
nostra vita.

Guardiamo Maria: la vita della Vergine è tutta conforme alle parole di Dio, a quelle parole
che conservava nel suo cuore, e meditava per tradurle in vita. Maria è tutta – si può dire –
Parola di Dio. E perché ha vissuto santamente, in modo perfetto, la sua vita è stata
veramente un Santo Viaggio.

Ma guardiamo soprattutto Gesù. Egli ha vissuto come noi, ha fatto il falegname, si è
affaticato, ha fatto apostolato, s’è anche riposato, s’è nutrito; ha amato Maria, Giuseppe, ha
istruito i discepoli, ha fatto miracoli, ha sfamato la gente.

Ma chi era Gesù? Non era Egli il Verbo, e cioè la Parola di Dio che si è incarnata? Ecco, se Egli
è la Parola, che ha assunto la natura umana, noi saremo veri cristiani, e santi, se saremo
uomini che informano tutta la loro vita della Parola di Dio. Quella che consideriamo in
questo tempo è: “Se uno mi vuol servire mi segua, e dove sono io, là sarà anche il mio servo.
Se uno mi serve, il Padre lo onorerà” (Gv l2, 26). E si segue Gesù, lo si sa, rinnegando noi
stessi e abbracciando la croce. Ogni traguardo che si vuoi raggiungere, anche in questo
mondo, ha bisogno di disciplina, di sacrificio, di sudore, di allenamento.

E' così la perfezione cristiana: rinuncia e croce. Sono parole dure, ma lo sappiamo che il
Santo Viaggio è impegnativo. E poi, questo è il cristianesimo: vivere la morte di Gesù perché
Lui risorga in noi, momento per momento. Quindi, potare l’uomo vecchio, perché l’albero
della nostra vita non rimanga un cespuglione inutile, ma dia frutti saporiti. Non vogliamo
attendere soltanto l’ultimo momento per offrire a Dio la nostra morte quando essa sarà
ormai inevitabile. L’amore per Lui ci dice di morire, col suo aiuto, giorno per giorno per
risorgere giorno per giorno, momento per momento.$doc1570$, 'drive_import', '01570-WEB-1982-03-15-essere-la-sua-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1570)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1571, 'ITA', $doc1571$TUTTO È A POSTO?

Roma, 1.4.1982

Carissimi,

La Parola di Vita di aprile che dice: “Se io, il Signore e Maestro, ho lavato i vostri piedi, anche
voi dovete lavarvi i piedi gli uni gli altri” (Gv 13, 14), mi ha fatto ricordare per la sua
radicalità un episodio successo qualche anno fa, che m’ha fortemente impressionata. Una
giovane mamma di dieci figli, colpita da tumore, aveva affidato uno ad uno i suoi bambini a
varie famiglie. Sentendosi prossima alla morte, s’era recata a visitare tutte le sue creature
per l’ultima volta, percorrendo un lungo viaggio faticosissimo. Compiuto quest’ultimo
dovere, coricandosi sul letto, aveva affermato: “Tutto è a posto”. Questa mamma ci insegna
veramente cos’è l’amore.

Anche a noi Dio ha affidato delle persone da amare, curare, aiutare, perché percorriamo
assieme il Santo Viaggio della vita, nel migliore dei modi, pagando il nostro debito d’amore.

L’ultima volta che ci siamo sentiti, abbiamo capito di dover essere la Parola di Dio viva.

Come fare ora per incarnare il più perfettamente possibile quella di questo mese, splendida,
che ci propone un esempio impareggiabile, donatoci da Cristo, sul modo cristiano d’amare?

Penso che un buon sistema sarebbe quello di esaminarci la sera di ogni giorno per vedere se
pure noi, nei confronti di coloro che ci sono affidati, possiamo sempre ripetere come quella
madre: “Tutto è a posto”.

Sarà stato ora un aiuto concreto, o un consiglio, o un dono, o un semplice sorriso... Un
condividere un peso, una disgrazia, una gioia... Metter in comune cibo, o vestiario, o denaro...
Comunicare qualche bella e utile idea per avanzare nel Santo Viaggio... Il cristianesimo è
amore. Dio ci domanda questo servizio d’amore.

Ma non lo chiede solo a singole persone. La Parola di questo mese ci dice chiaramente che
questo modo di agire deve essere reciproco: “...anche voi dovete lavarvi i piedi gli uni gli
altri”.

In un mio recente viaggio in Olanda, sono stata colpita, fra le molte cose, dal motto che ha
voluto darsi questa Nazione: “Con la concordia le piccole cose diventano grandi”.

È così, e l’Olanda, nella sua continua lotta per guadagnare terreno, togliendolo al mare, avrà
sperimentato spesso questa verità.

Anche Gesù vuole concordi i suoi seguaci, anzi domanda loro qualcosa di più: l’amore
scambievole a base di tutta la loro vita; quell’amore che dà valore a tutto quanto facciamo,
quell’amore che fa fiorire fra di noi la sua stessa presenza. È Lui che sa cavare miracoli
d’amore anche dalle nostre piccole esistenze, e sa farci gustare la beatitudine che ci ha
annunciata quando, dopo la lavanda dei piedi, ha detto: “Vi ho dato l’esempio perché, come
ho fatto io, facciate anche voi... Sapendo queste cose, sarete beati se le metterete in pratica”
(Gv 13, 15.17).$doc1571$, 'drive_import', '01571-WEB-1982-04-01-tutto-a-posto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1571)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1572, 'ITA', $doc1572$UN POPOLO DI PASQUA

Rocca di Papa, 15.4.1982

Carissimi,

Abbiamo appena vissuto gli importanti giorni della Settimana Santa ed ancora rimangono
nel nostro cuore i grandi temi che essa ci ha ricordato: il Comandamento Nuovo, con la
lavanda dei piedi, l’istituzione del sacerdozio che abbiamo commemorato il Giovedì Santo,
giorno in cui, per desiderio di Paolo VI, si festeggia il sacerdozio ministeriale e quello regale;
l’istituzione dell’Eucaristia; il Testamento di Gesù; la passione di Gesù del Venerdì Santo ed
il suo abbandono; Gesù risorto il giorno di Pasqua, che mai come quest’anno abbiamo
sentito festa particolarmente nostra.

Tutti fatti straordinari, realtà soprannaturali dalle quali è difficile per noi staccarci, quasi
desiderassimo che tutta la nostra vita fosse una lunga Settimana Santa. Tutti avvenimenti,
del resto, che il cristiano è chiamato a vivere ogni giorno della sua vita, anzi ogni momento.
Tutti i giorni, infatti, a tutte le ore, perché la nostra vita sia un Santo Viaggio, dobbiamo
morire a noi stessi e risorgere in Lui.

Come vivere allora la nostra esistenza in maniera che queste realtà siano sempre presenti,
così che questi immensi doni fruttino al massimo?

Io penso di suggerirvi tre direttive, che si concentrano poi in un solo punto.

Fissiamoci bene in cuore intanto, in questi quindici giorni, di avere un solo grande amore:
Gesù crocifisso e abbandonato.

Amiamolo innanzitutto nei dolori, abbracciandoli sempre, subito, con gioia, ripetendo di
fronte ad essi quello che diceva, con profonda convinzione, Danilo, il nostro volontario di
Stoccolma, poco prima di partire per la Mariapoli Celeste: “Tutto è amore, tutto è amore”.

Amiamolo poi nell’essere completamente proiettati nella volontà di Dio del presente, tutti
dimentichi della nostra, che non vogliamo considerare, che desideriamo dimenticare come
non degna di ricordo.

Amiamolo ancora nell’essere tutti uno con ogni prossimo che incontriamo, immedesimati
con lui totalmente in ogni cosa, tranne nel peccato. E ciò esige la morte di noi.

Vi assicuro che, se così faremo, nulla andrà perduto di quello che ci ha portato e ricordato la
Settimana Santa.
La lavanda dei piedi diverrà lo stile della nostra vita. Il Comandamento Nuovo sarà la
conseguenza di questo nostro agire. Il Testamento di Gesù verrà attuato. Il sacerdozio regale
vissuto pienamente anche a supporto fecondo e meraviglioso per chi lo ha ministeriale.

L’effetto tipico dell’Eucaristia in ciascuno di noi singolarmente (e cioè la nostra
trasformazione in Cristo) permarrà in noi perché ne è condizione il fare la sua volontà, in
cui sono tutte le virtù, tutti i desideri di Gesù. Così, la trasformazione di noi collettivamente
in Chiesa rimarrà pure per l’amore reciproco, sempre vivo, che ne è condizione; Gesù
Abbandonato sarà amato e vissuto da noi perché non vogliamo che Lui, e Gesù Risorto
trionferà sempre tra noi, trasformando la nostra vita in una perenne Pasqua.

Sì, come ci ha ricordato anche il Primate della Chiesa d’Inghilterra, Dr. R. Runcie, noi
dell’Opera di Maria vogliamo essere il Popolo della Pasqua. E se amiamo Gesù Abbandonato,
lo saremo. E allora, col nostro Santo Viaggio trascineremo a Dio un gran numero di cuori,
convinti che Cristo è risorto anche perché l’hanno scoperto tale in mezzo a noi.$doc1572$, 'drive_import', '01572-WEB-1982-04-15-un-popolo-di-pasqua-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1572)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1573, 'ITA', $doc1573$UN DIAMANTE A SETTE FACCE

Rocca di Papa, 6.5.1982

Carissimi,

È passato anche il momento solenne della Giornata Sacerdotale. Speriamo che per essa sia
andata a Dio tanta gloria, e così alla Chiesa.

Ma ciò che resterà di questo giorno sarà soprattutto quanto ciascuno di noi ha percorso di
Santo Viaggio in quelle ore. Fra il giorno d’oggi, in cui vi parlo, e il 30 aprile scorso, non v’è
tanta differenza.

Anche oggi dobbiamo camminare avanti verso la meta, ancorati alla Parola. Maggio ci dona
questa: “Voi siete già mondi, per la parola che vi ho annunziato” (Gv 15, 3).

Che cosa ha annunziato a noi Gesù?

Sappiamo che il nostro Movimento poggia su due pilastri: l’unità e l’abbandono di Gesù.
L’unità come frutto dell’amore a Gesù Abbandonato. Se amiamo Lui, infatti, abbiamo anche
l’unità.

In questo mese vogliamo offrire a Maria una profonda adesione a questa parola: a tutto ciò
che significa Gesù Abbandonato: vogliamo amarlo, viverlo.

Amarlo soprattutto nei fratelli d’Ideale, per essere con loro un solo “grappolo”.

In questi tempi, mi arrivano da varie parti non soltanto figurazioni del “grappolo” in tutti i
modi, disegni, sculture, soprattutto dai Gen, ma anche articoli, preghiere, favole che hanno a
che fare col “grappolo”

Di rilievo uno studio sui sette fondatori dei Servi di Maria, che un religioso di quell’Ordine, a
noi vicino, ha definito: “un grappolo di vite”.

Ho letto questo lavoro con grande interesse, costatando ancora una volta che le opere che si
ispirano alla Vergine hanno profonde analogie fra loro.

Questi sette fondatori laici, di cui alcuni sposati (per la cui canonizzazione Papa Leone XIII
stabiliva fossero sufficienti quattro miracoli collettivi, ottenuti cioè con la invocazione
collettiva dei sette), furono santi in uno, perché fecero dell’amore reciproco e della
testimonianza comunitaria la ragione della loro vita, nutriti da un particolare amore verso la
Madonna.
Erano, è stato scritto, “un diamante a sette facce”, e pur essendo tutti e sette santi non
fondarono sette famiglie religiose, ma una sola.
Carissimi, che desiderio di emularli! Non sentite bruciare il cuore per la voglia di ripetere
nel nostro secolo questo straordinario esempio? Non avvertite che abbiamo ancora la vita e
possediamo una meravigliosa spiritualità comunitaria ed apparteniamo a un Opera
concepita in modo tale che e l’una e l’altra ci possono mettere in grado di offrire a Dio e al
mondo, in questi tempi, non un grappolo solo di vite, ma una vite di grappoli anzi una vigna
distesa nel mondo per donare a tanti, a tutte le nazioni e razze, il vino inebriante dell’amore
di Dio e del prossimo?
Non siamo forse noi, Opera di Maria, la vigna di Gesù Abbandonato?
Niente di straordinario, dunque, se realizziamo tutto ciò.
La nostra Radi, partita per la Mariapoli Celeste, ci dà speranza col suo esempio: alcuni
hanno visto in lei la santità raggiunta in questo modo, per questo Santo Viaggio, che
percorriamo insieme, e hanno avuto coraggio e certezza.
Avanti, allora, senza fermarci, amandoci per amore di Gesù Abbandonato, soprattutto
quando questo amore ci ricorda il suo abbandono.
Avanti! E se accoglieremo in noi la sua parola, che è tutto ciò che intendiamo per Gesù
Abbandonato, saremo già mondi.
Mondi. Che significa già mondi? Significa appunto santi.
Santa Teresina pregava così: “Io non ho che quest’oggi mio fuggitivo per darTi in frutto
d’amore questo grappolo, di cui ogni acino è un’anima: dammi Tu il fuoco di un apostolo,
Gesù, e sia oggi!”.

UNA GARA DI FEDELTÀ
Carissimi,

Eccoci nuovamente al nostro appuntamento quindicinale, nato per darci tutti una
mano a far della vita un Santo Viaggio; per aiutarci cioè a spendere il tempo che ci
resta nel migliore dei modi, come Gesù ha insegnato.

Siamo ancora nel mese di maggio, che illumina il nostro cammino con la Parola: “Voi siete
già mondi, per la parola che vi ho annunziato”.

Quindici giorni fa abbiamo visto come la Parola che Dio ha annunciato a noi, al nostro
Movimento, è tutto ciò che noi intendiamo per "Gesù Abbandonato", "amare Gesù
Abbandonato".

Penso e spero che tutti avremo fatto quanto stava in noi per vivere così.

Ho cercato anch’io di mantenermi in questa linea durante gli scorsi giorni e, ancora una
volta, ho visto, ho costatato, come Gesù Abbandonato è la vita per noi. Ogni atto d’amore dà
come un nuovo sprint al nostro cammino, è un tonico per l’anima. E vien da dire: il Vangelo
ha proprio ragione: “Chi perde la propria vita la salverà”. E proprio morendo che viviamo.
Veramente: esperienza di tutti i giorni, di tutte le ore.

Quando poi non si fa così, quando non si pungola il nostro io con la rinuncia a noi stessi, coi
"salti di canguro" per strapparci alla nostra volontà ed essere la volontà di Dio; con la
mortificazione del nostro io per farci uno coi prossimi, abbiamo l’impressione non di vivere,
ma – che dire? – di vegetare.

E allora durante questi ultimi giorni di maggio ravviviamo ancor più questo amore a Gesù
Abbandonato.

Un fatto che impressiona sempre e che commuove è il costatare nella nostra vita la fedeltà
di Gesù Abbandonato. Egli si è fatto così uno con tutti (praticando per primo in maniera
sublime ed eroica quest’arte di amare), in ogni frangente della nostra esistenza, soprattutto
nei momenti dolorosi.

Ci sentiamo abbandonati, soli? Egli è lì. Traditi o umiliati? Egli è lì. Disorientati o estromessi
o falliti? Tiepidi o peccatori? Egli è lì. È lì, sempre fedele. E un fatto: Egli non manca mai.
Anzi, quando tutti spariscono, Egli compare.

Ebbene, ecco il proposito per questi prossimi giorni: gareggiare con la sua fedeltà. Essere
anche noi là dove Egli è. In piedi, pronti ad amarlo, ad abbracciarlo.
È in particolari dolori nostri, personali? Ci siamo anche noi.

È nella nostra famiglia che soffre? nella nostra comunità priva del sole dell’amore,
dell’unità? Eccoci lì. È nella divisione fra cristiani? Eccoci in prima fila! È in chi non conosce
la vera fede? Ci siamo anche noi. È in un ambiente freddo, ateo, secolarizzato? Anche noi ad
abbracciarlo in quel gelo.

Sì, a gara con Lui. Sarà contento e felice e dirà: “Voi siete già mondi, per la parola che vi ho
annunziato”.

E allora, se siamo già mondi (che – come sappiamo – significa santi) potremo essere sicuri di
star compiendo un vero Santo Viaggio.$doc1573$, 'drive_import', '01573-WEB-1982-05-06-un-diamante-a-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1573)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1574, 'ITA', $doc1574$Rocca di Papa, 20.5.1982

RENDIAMO FACILE LA VITA A GESÙ FRA NOI

Carissimi,

Avendo passato la settimana scorsa a Loppiano, non ho potuto non dedicare un paio
d’ore ad una visita al Santuario di Monte Senario, dove sono sepolti i sette santi
fondatori, che nel tredicesimo secolo sono riusciti a raggiungere il traguardo della
santità tutti insieme.
Lì, davanti alle loro preziose reliquie, dopo aver salutato Gesù e Maria che hanno tanto
amato, ho chiesto a loro sette di essere i protettori particolari di questo Collegamento
quindicinale, di cui ci serviamo per darci una mano nella nostra santificazione collettiva.

Terminata la breve preghiera, ho potuto ammirare poi su una parete della chiesetta un
affresco raffigurante un miracolo di quei santi: nel pieno inverno una vite ha cominciato a
coprirsi di pampini a fiorire e dar saporosi grappoli. Questo fatto straordinario ha
rappresentato per loro un segno della volontà di Dio di accogliere nella loro famiglia
religiosa tanti altri membri.

Naturalmente, come potrete capire, questa felice coincidenza fra i sette fondatori e la vite e i
grappoli (simbolo per noi dell’ordine che stiamo imprimendo alla nostra Opera), ci è stato
motivo di gioia, e più vivo e impellente si è fatto il desiderio di far fiorire nell’inverno di
questo mondo, raggelato dal materialismo, la mistica vigna di Gesù Abbandonato.

Siamo agli inizi di un nuovo mese, quello di giugno, con una Parola di Vita un po’ particolare
per noi, che abbiamo incentrato quest’anno la nostra attenzione sul Risorto: “Ecco, io sono
con voi tutti i giorni, sino alla fine del mondo” (Mt 28, 20).

Egli ha dunque promesso di essere con noi sempre, ed ha sottolineato “tutti i giorni”. Quindi,
anche in questi prossimi quindici giorni, Gesù sarà con noi; ha deciso di essere in nostra
compagnia.

Quale dovrà essere, allora, il nostro atteggiamento? Infinitamente grati di questa sua
decisione, dobbiamo disporci a saper stare con Lui nel migliore dei modi. Se fossimo a
conoscenza che un ospite di riguardo ha stabilito di venire ad abitare a casa nostra per un
po’ di tempo, ci preoccuperemmo senz’altro di non fargli trovare la porta chiusa, faremmo
preparativi per la sua visita, disporremmo ogni cosa in vista di lui.
Ora sappiamo che Gesù stesso è con noi tutti i giorni sino alla fine del mondo. Che dobbiamo
fare? Penso che sarà bene anzitutto individuare dove Egli possa essere. È presente – lo
sappiamo – qui sulla terra nell’Eucaristia, nei poveri, in chi agisce e parla in nome suo, nella
sua Parola, in ciascuno di noi per la grazia...

Ma quest’anno abbiamo capito che, dai membri del nostro Movimento, Egli vuol farsi
trovare in un posto: in mezzo ad essi. Vuole così, desidera così. Possiamo, infatti, pensare
che uno dei suoi scopi, quando ha suscitato la nostra Opera, fosse quello di potersi stabilire
in ogni luogo, anche fuori delle chiese, in mezzo alla gente, nei posti in cui essa vive,
ovunque si trova.

E allora in questi quindici giorni facciamogli posto in mezzo a noi, soprattutto fra le persone
del nostro "grappolo". Di là potrà irradiare amore e luce fra tante altre nel mondo.
Ravvivando il nostro dovere di servizio, facendoci uno reciprocamente fra noi, rendiamogli
possibile la vita, rendiamogliela facile.

Che Egli possa regnare fra noi. Che resti con noi e così noi potremo essere, almeno per
quindici giorni, con Lui: non potremmo desiderare migliore amico per il nostro viaggio. E
non possiamo misurare gli effetti di questa divina compagnia.

Ecco allora un motto utile per questi giorni: Rendiamo facile la vita a Gesù in mezzo a noi.$doc1574$, 'drive_import', '01574-WEB-1982-05-20-rendiamo-facile-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1574)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1575, 'ITA', $doc1575$Rocca di Papa, 3.6.1982

GESÙ ABBANDONATO E LE DODICI STELLE DELLA PERFEZIONE

Carissimi,

Eccoci di nuovo all’appuntamento quindicinale, che ha come scopo di rinsaldare
maggiormente la nostra unità ed incoraggiarci sempre più nella via della nostra
santificazione collettiva.

Questa volta penso vi faccia piacere conoscere una mia recentissima esperienza spirituale.

Come forse sapete, sto dedicando alcuni giorni del mese di giugno
all’approfondimento di quel cardine della nostra spiritualità che sarà argomento di
formazione dei membri del nostro Movimento nei prossimi anni. Si tratta di Gesù
Abbandonato, chiave dell’unità. Questo tema mi ha così profondamente toccato, m’è
parso talmente interessante e attraente, da sentirmi spinta a viverlo subito,
nell’attimo presente, dimenticando quasi l’impegno della tensione alla santità.
Mi sono messa, insomma, ad amare Gesù Abbandonato abbracciandolo sotto i suoi più vari
aspetti.

Ma proprio in questi giorni, durante la meditazione mattutina, ecco tornarmi sott’occhio
quelle che per san Giovanni della Croce sono "le dodici stelle’" della perfezione, Cioè: amor
di Dio, amor del prossimo, castità, povertà, obbedienza, pace, silenzio, umiltà,
mortificazione, penitenza, coro, orazione.

Le conoscevo bene, anzi, a forza di meditarle, le sapevo anche a memoria. Ma in questi
giorni non ci pensavo affatto, presa com’ero dall’amare solo Gesù Abbandonato.

Ed ecco la sorpresa, gioiosa sorpresa, come una luminosa riscoperta: rileggendole, durante
la meditazione, mi sono accorta che, amando Gesù Abbandonato, le avevo fatte splendere
tutte e dodici un pochino di più nella mia anima.

Avevo amato Dio un po’ di più, perché avevo amato Gesù Abbandonato che è Dio. Avevo
amato il prossimo di più, perché per amore di Lui m’ero sforzata di "farmi uno" con tutti.

Avevo migliorato la castità, perché l’amore a Gesù Abbandonato porta a mortificarsi. Così la
povertà, perché per Lui avevo cercato di spegnere ogni attaccamento. L’obbedienza, perché
per Lui mi sono sforzata di far tacere il mio io per ascoltare "quella voce". Amando nei
dolori Gesù Abbandonato avevo potuto mantenere la pace. Amandolo ho osservato meglio il
silenzio, mortificando inutili parole. L’umiltà ne ha guadagnato con la morte dell’io che
l’amore a Lui provoca. Così la mortificazione e la penitenza. Ho curato meglio il "coro", che
per noi significa la preghiera insieme al focolare, e così è stata più piena l’orazione
personale.

Tutto meglio, dunque, per il solo amore a Gesù Abbandonato.

Lo sapevo che Egli è – come diciamo – un monumento di santità. Ma non avevo ancora
sperimentato, con tanta evidenza, che viverlo significa veramente tendere con frutto alla
santità.

Carissimi, oggi non posso augurarvi di meglio che fare anche voi questa esperienza. Provate!
Amatelo nei dolori, nelle rinunce, nel morire per farvi uno con ogni prossimo: soprattutto in
quest’ultima maniera, per essere anche in armonia con la Parola di Vita di questo mese, che
parla della presenza del Risorto fra noi.

Che Gesù Abbandonato diventi tutto per noi! E la nostra santità collettiva sarà assicurata.$doc1575$, 'drive_import', '01575-WEB-1982-06-03-ges-abbandonato-e-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1575)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1576, 'ITA', $doc1576$Rocca di Papa, 16.6.1982

IL MOVENTE DI OGNI NOSTRA AZIONE: L’AMORE

Carissimi,

Eccoci nuovamente uniti anche attraverso il Collegamento.

Sono veramente grata a Dio perché ho potuto costatare come l’amore a Gesù
Abbandonato, durante il mese di luglio, ha fatto brillare in molti di noi, un po’ di più,
le dodici stelle della perfezione.
Ed ora siamo in agosto e la Parola di Vita (“Non ciò che entra nell’uomo contamina l’uomo,
ma ciò che esce dall’uomo contamina l’uomo” Mt 15, 11) ci pone – come abbiamo letto nel
commento – dinanzi alla necessità di metterci ogni attimo della nostra giornata nell’amore
verso Dio e verso il prossimo. È soltanto quest’atteggiamento, infatti, che ci garantisce che
ciò che esce dal nostro intimo (pensieri che fioriscono, desideri che formuliamo, speranze
che nutriamo, atti che compiamo) è buono, degno di persone che vedono la vita come un
Santo Viaggio. Carissimi, in questi giorni di agosto ho cercato anch’io con voi di mettere in
pratica questa nuova Parola, sia per fare la volontà di Dio, sia per comunicarvi un po’ la mia
esperienza ed incoraggiarci a vicenda a camminare.

E ho costatato che, alla sera, all’esame di coscienza, se ho da pentirmi di qualcosa, è sempre
di ciò che non è stato frutto, effetto dell’amore, di ciò che non ha avuto radici nell’amore. E
così sarà un po’ di tutti voi.

Non sono tanto – speriamo – i furti, gli omicidi, gli adulteri, le malvagità, gli inganni, ecc.
(mali che Gesù enumera) quelli che oscurano la nostra vita, che è cristiana e vuol esser
impegnata, ma spesso piccole vanità, attaccamenti, giudizi, risentimenti, egoismi, moti di
orgoglio, distrazioni nella preghiera, invidiuzze, fretta, poco impegno, peccati di gola... difetti
che compromettono comunque il Santo Viaggio.

E allora?

Allora ecco la parola d’ordine: amare! Amare Dio e il prossimo.

Come? Con tutto il cuore, senza riservarne nemmeno una briciola per altro. Poter dire di
ogni momento della giornata: sì, Gesù, in quest’attimo, in quest’azione t’ho amato con tutto
il cuore.

E fare ciò non solo e non tanto per essere perfetti, quanto perché gli vogliamo bene.
Allora, cominciamo! Attenzione al movente di ogni nostra azione! Che sia solo l’amore. Alla
sera non troveremo nulla di che rammaricarci, ma il nostro cuore sarà colmo solo di
gratitudine verso Dio.$doc1576$, 'drive_import', '01576-WEB-1982-06-16-il-movente-di-ogni-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1576)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1577, 'ITA', $doc1577$Sierre, 5.8.1982

UN AMORE COSÌ GRANDE DA METTERE IN GIOCO LA VITA

Carissimi,

Ci siamo lasciati, quindici giorni fa, col desiderio di dar buone radici alla nostra vita cristiana
vissuta momento per momento e di mettere perciò l’amore a movente di ogni nostra azione.
E ci è sembrato questo il miglior modo per vivere la Parola del mese: “Non ciò che entra
nell’uomo contamina l’uomo, ma ciò che esce dall’uomo contamina l’uomo” (Mt 15, 11).

Quale esperienza posso comunicarvi per darci una mano nel Santo Viaggio?
Cercando di amare Dio e i fratelli, ho compreso come noi cristiani siamo veramente
noi se amiamo, e cioè se non pensiamo a noi stessi ma a Dio, alla sua volontà, che è
soprattutto questa: che amiamo il prossimo.
Dio ci domanda questo: per essere, per essere veramente noi, per "realizzarci" come
cristiani, dobbiamo non essere, vivere fuori di noi, vivere, per così dire, "estatici". Vivere
non la nostra volontà ma quella di Dio. Vivere il fratello. Allora siamo veramente noi.
Carissimi, ho cercato dunque anch’io di vivere così, di amare. Ma mi sono resa conto che c’è
amore e amore.

Ho visto che l’aver una certa comprensione degli altri, interessarci un po’ ai loro dolori,
cercar di portare in qualche modo i loro pesi, amare, insomma, così così, non basta per
essere come Gesù ci vuole. Dio domanda a noi un amore, atti d’amore che abbiano (almeno
nell’intenzione e nella decisione) la misura del suo amore: “Amatevi – ha detto – come io vi
ho amato” (Gv 13,34).

Occorre perciò esser sempre pronti a morire per il fratello, e quanto facciamo, momento per
momento, per dimostrargli concretamente il nostro amore, deve essere animato, sostenuto
da questa volontà, da questa decisione.

Solo un amore così piace a Gesù: non un qualche amore, non una patina d’amore, ma un
amore così grande da mettere in gioco la vita.

E, amando così, si vive completamente "fuori di noi" si abdica interamente a noi stessi e, se
siamo in più d’uno ad agire così, si può sperare d’abdicare in favore del Risorto, che potrà
vivere fra noi. Egli, infatti, non si fa pienamente presente dove c’è un po’ d’amore, ma dove si
è uniti nel suo nome, e cioè in Lui, secondo la sua volontà che è amare come Lui ha amato.

E allora? In questi altri quindici giorni, ogni qualvolta incontriamo un prossimo, o lo
sentiamo per telefono, o lo avviciniamo con qualche lettera, o prepariamo per lui qualche
conversazione, o esplichiamo in suo servizio il nostro lavoro quotidiano, domandiamoci
sempre: Sono pronto a morire per lui?

Facendo così – sono certa – la nostra vita d’amore farà un salto di qualità, un grande salto di
qualità. Allora così. Dieci, venti volte al giorno (sempre quando si fa qualcosa per il
prossimo) chiederci: Sono pronto a dar la vita per lui?$doc1577$, 'drive_import', '01577-WEB-1982-08-05-un-amore-cos-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1577)
on conflict (document_id, language) do nothing;
