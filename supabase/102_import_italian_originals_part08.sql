-- 102_import_italian_originals_part08.sql (8/14)
-- Import dei testi originali italiani dei Collegamenti, estratti dai PDF della cartella Google
-- Drive "Linkup Ita PDF" (owner: alessanpk@gmail.com), secondo HANDOFF_Operazione_Italiano_2026-09-20.md.
-- Spezzato in 14 file da 20 insert l'uno: l'SQL editor di Supabase rifiuta
-- una singola query troppo grande. Eseguire i file in ordine (part01, part02, ...), poi
-- 102_import_italian_originals_verify.sql per il riepilogo finale.
-- Questo file: document_id 1698-1717 (20 documenti).
--
-- Ogni insert e' condizionato a "where exists (...)": un document_id che non esiste ancora
-- nell'archivio urdu viene scartato silenziosamente invece di far fallire il batch per una
-- violazione di foreign key. source = 'drive_import', reviewed = false (non ancora confrontato
-- con l'originale da un umano).


insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1698, 'ITA', $doc1698$Rocca di Papa, 11.5.89

NIENT’ALTRO CHE L’AMORE SCAMBIEVOLE

Carissimi,

È passato questo mese nel quale – come ho saputo dalle vostre lettere, dai numerosissimi
messaggi, ecc. – avete rinnovato il patto dell’amore reciproco che è assolutamente
fondamentale per la nostra vita.

Noi, del Centro, lo abbiamo fatto a Loreto, in un clima particolare, anche a nome di tutti voi.

In seguito abbiamo sentito un grande desiderio di puntare ancora su di esso mettendolo in
pratica così come lo Spirito ce lo ha insegnato, quando ci ha svelato la chiave per attuarlo
con radicalità e cioè con la misura di Gesù Abbandonato.

Occorre, infatti, essere assolutamente poveri di mente, di cuore, di volontà, occorre essere
"nulla" come Gesù Abbandonato per poter farci uno con gli altri, per poter "vivere gli altri",
sì da non essere noi a vivere, ma essere amore.

E lo faremo. Ci fermeremo perciò anche questa volta a quella tappa del nostro itinerario
mariano, la quale contempla Maria che segue, a suo modo, Gesù nell’evangelizzazione. Noi
dobbiamo evangelizzare prima di tutto col nostro amore reciproco: "Da questo
conosceranno..." (cf. Gv 13, 35).

Mi ha dato gioia, giorni fa, sentire spesso leggere dal sacerdote alla messa un prefazio che
diceva così: "e hai donato il tuo Spirito per fare di tutte le nazioni un solo popolo nuovo, che
ha [...] come statuto il precetto dell’amore".

Anche se lo sapevo, mi ha colpito nuovamente il fatto che lo statuto, la regola del popolo di
Dio, sia il comando dell’amore. La regola del popolo di Dio. Dunque di tutta la Chiesa: dai
laici ai sacerdoti, ai religiosi, ai vescovi...

E ho collegato questo statuto col nostro, quello dell’Opera (che comprende anch’essa tutte le
vocazioni), nel quale è scritto che la regola base, la norma per la quale tutte le altre norme
hanno valore e senza la quale nulla ha senso (né la preghiera, né l’apostolato, né il donare i
beni, né il dare la vita...) è Gesù in mezzo, effetto dell’amore reciproco. E non ho potuto non
compiacermi nel costatare come lo Spirito Santo ha agito con noi: essendo un piccolo
popolo di Dio, non poteva non darci per statuto quello del grande popolo di Dio: l’amore
reciproco.

È questa, infatti, la nostra specifica vita, il nostro tipico modo di essere.

Esso vale per tutti i membri del nostro Movimento.
Anche quelli che noi chiamiamo "interni", e sono più a diretto servizio dell’Opera, non
devono avere perplessità o dubbi nell’attuarlo, qualsiasi compito debbano espletare.

Devono amarsi così i membri di ogni nostra comunità fra loro e col responsabile. E deve
amare tutti così il responsabile. Ché se egli ha anche il dovere di correggere, lo faccia, ma
come espressione di questo amore. Meglio ancora se può rimandare la cosa – a meno che
non sia d’un certo peso – a quella che noi chiamiamo l’"ora della verità", che si potrà
stabilire una volta al mese, ad esempio, come si fa al Centro. Lì si sarà in grado di aiutarci
meglio, con tutto l’amore, segnalando i difetti che si sono visti per toglierli, e i pregi per
incoraggiarci a vicenda. Si aiutavano così anche i primi cristiani.

In tal modo, durante il mese anche il responsabile potrà essere libero di amare mettendosi
all’ultimo posto, servendo tutti, sopportando, appianando difficoltà, e non rompendo mai
l’unità.

Viviamo, dunque, in profondità l’amore reciproco, perfezionandolo ogni giorno, sì da creare
un tale clima da poterci dichiarare sempre, in ogni attimo, il patto.

Ma io vorrei che vivessimo quest’amore, durante i prossimi quindici giorni, in una maniera
particolare: come se non avessimo nient’altro da fare. Perché il resto viene da sé: l’amore
illumina e illumina bene su ogni altro nostro dovere.

Dunque, non pensare ad altro. Pensare solo ad amarci fra di noi. Proviamo a far così tutto il
giorno. È un’esperienza che va fatta. Vi assicuro che a sera ci troveremo cambiati; magari
stanchi, ma con un nuovo entusiasmo per la meravigliosa divina vita che Dio ci ha dato; e un
fuoco in cuore che brucerà, letteralmente.

Sia la parola d’ordine per noi: nient’altro che lo statuto dell’amore.$doc1698$, 'drive_import', '01698-WEB-1989-05-11-nient-altro-che-l-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1698)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1699, 'ITA', $doc1699$Rocca di Papa, 8.6.89

PERDERE TUTTO PER AMARCI MEGLIO

Carissimi,

In queste ultime settimane abbiamo parlato dell’amore scambievole, che si vede, sicché dà
testimonianza, dello sforzo di viverlo come più importante impegno, di esso come statuto
del popolo di Dio e del nostro piccolo "popolo".

Vorrei continuare anche questa volta su questa linea, perché è di un’importanza capitale.

È il comandamento nuovo, infatti, che dona lo splendore, che dà l’ultimo tocco, che dà lo
smalto (come si dice) alla vita cristiana, alla comunità dei seguaci di Gesù.

Mi fa sempre grande impressione costatare la così poca differenza che c’è fra una città
prevalentemente cristiana e una che non lo è. A parte qualche celebrazione liturgica,
qualche manifestazione religiosa, la gente per le strade è uguale di qua e di là. Manca il
segno, manca il distintivo, perché l’amore reciproco non è in evidenza.

Mi danno, invece, sempre consolazione le nostre cittadelle. Ci si sforza di amarci come Gesù
vuole ed ecco che le persone accorrono a decine di migliaia per vedere questo fenomeno che
dovrebbe essere la norma per tutti i cristiani. Ma perché non è così?

Certamente, la frequente mancata attuazione del comandamento nuovo di Gesù, in coloro
che dovrebbero viverlo, dipende da molti ostacoli che insorgono. Uno di questi è che si ama
se stessi, si guarda a se stessi, non si pensa al prossimo, non ci si preoccupa di amare. Si
coltivano pensieri di vanità, di superbia. Si tiene alle proprie idee, alla bella figura, alla fama,
all’onore. Si cercano soddisfazioni umane e spirituali... O si è attaccati a persone o a cose: al
proprio lavoro, anche a quello apostolico: alla zona, al proprio settore, alla propria branca. E
di tutte queste miserie è piena la nostra giornata.

Che fare, allora, per lasciar libero corso all’amore reciproco?

Ci può aiutare oggi la nuova tappa della "Via Mariae". Essa ci ricorda Maria, la nostra Madre
Desolata ai piedi della croce.

Noi abbiamo sempre ammirato in Maria colei che ha rinnegato completamente se stessa e,
ad imitazione di Gesù nell’abbandono, ha saputo perdere tutto, persino suo Figlio Dio, e per
questo è stata un monumento di virtù.

Ella è maestra della mortificazione necessaria al cristiano, modello del saper perdere, che è
saper tagliare.
Noi sappiamo che la nostra è certamente una via eminentemente positiva. È soprattutto
perché amiamo che acquistiamo tutte le virtù. Non è quindi tanto nostro compito "togliere",
quanto "aggiungere", aggiungere amore: è facendo così, infatti, che compiremo un vero
Santo Viaggio, è così che ci santificheremo.

Ma ciò non toglie che per facilitare, per perfezionare l’amore, non si debba dare qualche
colpo, anche solenne, al nostro "uomo vecchio" sempre risorgente.

Gesù parla d’amore, ma anche di "rinnegare e stessi" (cf. Mt 16, 24), di "tagliare la mano" (cf.
Mt 5, 30), se scandalizza, e così via. E i santi sono modelli in ciò. Dice Giovanni della Croce
che come è necessario che la terra, perché produca, venga lavorata, altrimenti non darebbe
che erbacce, così occorre, perché l’anima progredisca, che gli attaccamenti (gli "appetiti",
egli li chiama) siano mortificati.

Perciò in questi prossimi giorni ci impegneremo a mantenere perfetto, integro, costante il
nostro reciproco amore, mortificando, perdendo tutto ciò che va perduto; dobbiamo
attenerci a questo "perdere".

Arriva un pensiero di orgoglio? Dire dentro di sé: "Lo perdo", e buttarci fuori ad amare, ad
amarci, e, fra il resto, avremo acquistato un po’ di umiltà.

Abbiamo voglia di comprarci un libro, un vestito, un oggetto, superflui? Si taglia il desiderio,
si perde e avremo acquistato in povertà.

Siamo portati a guardare certi cartelloni pubblicitari, a seguire certi programmi televisivi?
No, e fuori ad amare, e avremo acquistato in purezza.

Così tutto il giorno. E il nostro amore reciproco prenderà sempre più posto nella nostra vita,
diverrà più robusto, sarà sempre più il nostro abito. Allora sì che il mondo attorno a noi pian
piano cambierà.

Dobbiamo essere così, vivere così, amare così. Dio da noi lo vuole: è solo in questo modo che
noi possiamo gridare il Vangelo con la nostra vita.

Ricordiamo: perdere tutto per amarci meglio.$doc1699$, 'drive_import', '01699-WEB-1989-06-08-perdere-tutto-per-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1699)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1700, 'ITA', $doc1700$Rocca di Papa, 22.6.89

BRUCIARE LA PROPRIA VOLONTà

Carissimi,

Eccoci – dopo un periodo di vacanza – nuovamente collegati per camminare speditamente
insieme, per santificarci nella nostra via collettiva.

Siamo in agosto, e una Parola di Vita meravigliosa, tanto consona con la nostra spiritualità,
ci illumina come una fiaccola: "Fuoco son venuto a portare sulla terra e vorrei davvero che
fosse già acceso!" (Lc 12, 49) ha detto Gesù.

È una parola che gli interpreti spiegano in diverse maniere, ma che si può intendere anche
così: la missione di Gesù è quella di gettare fuoco sulla terra, cioè "di portare lo Spirito Santo
con la sua forza purificatrice e rinnovatrice".

Il fuoco, quindi, che Gesù dona, sarebbe lo Spirito Santo. Ma "nel dono dello Spirito è la
carità divina che viene versata nel cuore dei fedeli".

Con questa parola Gesù ci invita a prendere in grande considerazione l’amore e a
farlo fruttare: l’amore deve divampare! Dobbiamo, dunque, mettere in moto l’amore,
dargli la massima accelerazione.
Amore verticale verso Dio, amore orizzontale verso il prossimo.

Amore che è vero e autentico se non è solo sentimento, ma un "farsi uno": farsi uno col
prossimo e anche farsi uno con Dio. Proprio così: farsi uno con Dio, per amare Dio; farsi uno
con quanto gli suggerisce il suo personale amore per ciascuno di noi; farsi uno col suo
pensiero su di noi, con l’itinerario che Egli desidera percorriamo. In una parola: farsi uno
con la sua volontà su ciascuno di noi, con la sua volontà che è lui stesso. Come, infatti, la mia
volontà è parte del mio io, così la volontà di Dio è Dio stesso.

Perciò, farsi uno con la sua volontà è farsi uno con lui. Accogliere la sua volontà è accogliere
lui, abbracciare lui, nutrirsi di lui.

Noi, che vogliamo fare della vita un Santo Viaggio, abbiamo bisogno di assicurarci, almeno di
tanto in tanto, se agiamo così, di verificare se camminiamo nella via retta o se è necessaria
una correzione di rotta.

Iniziato il nostro cammino in Dio, ponendoci nella sua volontà, sul raggio della sua volontà,
dobbiamo essere certi di continuare sempre in esso senza fuoruscite, anche minime.
È così che si aggiungono giorno dopo giorno nuove pennellate al disegno che Dio ha su di
noi, nuovi tasselli al mosaico della nostra nuova vita; è così che la nostra piccola storia
diventa, ora dopo ora, quasi storia sacra; è così, solo così, che amiamo Dio.

Ma per vivere la volontà di Dio, per uniformarsi ad essa sempre, bella o triste, desiderata o
indesiderata, occorre bruciare: bruciare la nostra volontà, soppiantarla, ammazzarla,
eliminarla. E lasciar vivere la sua che è vita, luce, risurrezione.

Gesù ci vuole di fuoco, e questo è il modo. Non c’è fuoco senza combustibile. Il combustibile
è la nostra volontà. Alimentiamo allora, minuto per minuto, l’amore in noi, sacrificandola.

Forse in questi ultimi tempi abbiamo allentato un po’ questo impegno, ma esso è
fondamentale per noi.

Maria ha iniziato la sua divina avventura con un sì alla volontà di Dio e così ha dato Gesù al
mondo. Anche l’Opera di Maria, nella sua storia, dopo aver conosciuto l’amore di Dio, Dio
che è Amore, è stata chiamata a rispondere con un sì alla sua volontà. È, infatti, la volontà di
Dio il secondo punto della nostra spiritualità. Ed è per essa che anche il Movimento può
svolgere la sua funzione: ridonare Cristo al mondo.

Avanti, allora! Ripetiamo anche noi con Gesù, come fosse parola nostra: "Fuoco sono venuto
a portare sulla terra e vorrei davvero che fosse già acceso".

Questa la missione di noi focolarini o comunque di noi, membri del Movimento dei Focolari.

Tutto parla di fuoco in noi!

Cerchiamo allora di essere in vocazione: alle fiamme la nostra volontà, perché viva e regni in
noi la sua, il suo Amore!$doc1700$, 'drive_import', '01700-WEB-1989-06-22-bruciare-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1700)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1701, 'ITA', $doc1701$Mollens, 10.8.89

AZIONI "PULITE", TUTTE UGUALMENTE

IMPORTANTI, SULLA BASE DELL’AMORE

Carissimi,

Ci siamo lasciati, l’ultima volta, col proposito di vivere la volontà di Dio e di "bruciare" la
nostra.

È bello sapere che, per amare Dio, basta fare la sua volontà. Ma è più bello ancora e dà le ali
al cuore costatare, mentre si fa la volontà di Dio, che lo si sta amando veramente; è
consolante poter essere certi, almeno in quei momenti, di amarlo: sapere che il nostro
amore va diritto a lui, che egli lo riceve e ne è contento. E ciò dà gioia a chiunque tende
anche solo un po’ alle cose del Cielo.

Parliamo allora ancora di questo fare la volontà di Dio, espressione del nostro amore a Dio.

Noi sappiamo come le tre divine Persone si amano e come è lì che si trova il modello
dell’amore. È la dinamica del loro rapporto che noi dobbiamo imitare qui sulla terra.

Nel prologo del suo Vangelo, Giovanni dice della seconda Divina Persona: "In principio era il
Verbo e il Verbo era rivolto verso Dio" (Gv 1, 1-2); e più sotto, parlando del Verbo incarnato,
Gesù dirà: "Il Figlio Unigenito che è rivolto verso il seno del Padre [...]" (Gv 1, 18).

"Rivolto verso Dio", "[...] rivolto verso il seno del Padre", che vuol dire?

Significa che il Verbo ama il Padre, che Gesù faceva sempre la volontà del Padre, diceva solo
quello che aveva udito dal Padre, parlava sempre del Padre, era sempre nel Padre, compiva
solo l’opera che il Padre gli aveva detto di fare.

È questo l’atteggiamento che anche noi dobbiamo avere verso Dio per poter dire di amarlo
veramente: essere sempre rivolti a Dio, essere in ascolto, in obbedienza, fare ciò che lui
vuole, fare la sua opera.

Fare la volontà di Dio, solo quella e non altro. E ciò significa fare bene, per intero, ogni
momento, quell’azione che Dio ci chiede. Essere tutti lì in quell’opera, eliminando ogni altra
cosa, perdendo pensieri, desideri, ricordi, azioni... che riguardano altro. Parlare, telefonare,
ascoltare, aiutare, studiare, pregare, mangiare, dormire, senza curarci di nient’altro; fare
azioni intere, pulite, con tutto il cuore, la mente e le forze. È questo il modo di amare Dio.
Così facendo, si può sperimentare che la giornata risulta piena. In questo modo si
correggono tanti sbagli in cui possiamo incorrere: l’attivismo, ad esempio, se si pensa
all’apostolato anche fuori del tempo stabilito; l’angelismo, se si ama solo l’aspetto spirituale
della vita; l’improvvisazione, se non si dà il giusto tempo allo studio... Si sciupa la salute, se
non se ne fa calcolo; non si testimonia Dio: ordine ed armonia, se non si cura l’ambiente; si
sprecano tante possibilità di bene se non stiamo al passo con le nuove tecniche; si è
disonesti, se si lavora male.

E si esce dal piano di Dio se non si accolgono a cuore aperto tutte quelle varie "volontà di
Dio" che sopraggiungono nella nostra giornata da noi non programmate, ma volute da lui.

Se invece si dà spazio ad ogni volontà di Dio, la cura di un aspetto della vita aiuta l’altro.

E si capisce come la Chiesa approvi le regole delle famiglie religiose: in esse ogni cosa ha il
suo posto e tutto è importante: dai pasti alle lodi, dalla passeggiata alla lettura spirituale, al
lavoro.

Naturalmente, perché la nostra giornata risulti un piccolo capolavoro soprannaturale, è
necessario mettere a base di ogni cosa quella che è la prima volontà di Dio: il mutuo amore.

Appena aperti gli occhi al mattino, dobbiamo guardarci attorno e incominciare con l’amare
per primi, onde mantenere sempre viva la presenza di Gesù fra noi, se si vive con chi
condivide il nostro Ideale o, comunque, per partire con il piede giusto.

Tutto allora scorrerà meglio e ogni azione sarà una nuova piastrella di vita, aggiunta al
mosaico della nostra giornata, che potremo, alla sera, offrire a lui come nostra concreta
risposta d’amore al suo amore.

In pratica: azioni "pulite", tutte ugualmente importanti, sulla base dell’amore.$doc1701$, 'drive_import', '01701-WEB-1989-08-10-azioni-pulite-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1701)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1702, 'ITA', $doc1702$Mollens, 14.9.89

LA VOLONTà DI DIO È "CIBO" CHE NUTRE L’ANIMA

Carissimi,

Grazie dei molti messaggi che mi avete spedito in seguito all’ultimo Collegamento.

Da essi ho tratto convinzione che, vivere la formula: praticare la volontà di Dio con azioni
"pulite", tutte ugualmente importanti sulla base dell’amore, è stato di grande gioia per tanti
e di profitto spirituale. Forse la volontà di Dio è diventata un po’ di più, per noi, quel "cibo"
di cui parla Gesù che, nutrendo l’anima, – come fa appunto il cibo materiale per il corpo – dà
sollievo, sazietà, forza e rende felicemente atti al nuovo cammino che ci attende.

L’esperienza poi, che se ne è fatta, è tale da far cogliere nelle vostre espressioni il desiderio
di continuare ancora a vivere così, anzi qualcuno arriva a dirmi che quel pensiero del
Collegamento potrebbe valere per tutta la vita.

E allora, che facciamo?

Vi confesso, anzitutto, che anch’io avrei il desiderio di andare avanti così, almeno per un
poco.

Abbiamo appena imparato bene a fare azioni tutte potate da un continuo perdere; abbiamo
appena capito quanto sia giusto dare importanza ad ogni aspetto della vita; ci siamo sforzati
con decisione di costruire tutto su quell’amore che dà valore divino ad ogni nostro respiro
che non so perché si debba ora cambiare.

Ma c’è un fatto in più che convince a mantenerci ancora sulla stessa linea.

Vivendo così, si può fare un’esperienza un po’ speciale, che reca stupore, sorpresa,
meraviglia, gioia, e che suscita la gratitudine a Dio: ci si accorge che, concentrati sulla
volontà di Dio tutto il giorno, si vive tutta la nostra spiritualità.

Se, infatti, alla sera, passiamo in rassegna, a mo’ di esame di coscienza, i vari punti di essa,
notiamo che sono stati tutti attuati.

Vivendo la volontà di Dio in tal modo, si crede senz’altro all’amore di Dio (primo punto della
nostra spiritualità), perché si gettano nel Padre tutte le preoccupazioni che sopravvengono.

Si fa la volontà di Dio prevista e non prevista (secondo punto della nostra spiritualità),
perché proprio a questo tendiamo.

Ci si ricorda di amare i fratelli.
Si mantiene l’amore reciproco, anche perché fa parte della formula.

Per esso è così viva, sempre, la presenza di Gesù fra noi.

Si ama Gesù Abbandonato, perché, quando il suo volto appare, si vede chiaro che questa è la
volontà di Dio da abbracciare.

Si è tutti protesi verso l’unità e si vive la Chiesa, perché, adempiendo la volontà di Dio, si
realizza la comunione con Dio, con coloro che la rappresentano e con gli uomini.

Si vivono le Parole di Gesù, perché sono esse che esprimono la volontà di Dio.

Si ama Maria, e proprio nella sua espressione più alta, come Desolata, perché si continua a
"perdere".

Si ama lo Spirito Santo, perché, per adempiere la volontà di Dio, si è sempre in ascolto della
sua voce...

Sì, tutto va a posto. Ma non sono le mie spiegazioni a convincere. Occorre fare l’esperienza,
che io auguro a tutti.

Continuiamo allora con azioni tutte intere, sapendo perdere il resto.

E diamo la stessa importanza ad ognuna. E il tutto sulla base dell’amore.

All’inizio del Movimento, con quell’idea chiarissima sulla necessità di raggiungere uno scopo
vasto come l’"ut omnes", avremmo potuto pensare che non si dovesse spendere il tempo che
per lavorare e trascinare persone a questo ideale. E chissà dove ci saremmo arenati...
Sarebbe mancato il supporto della preghiera, della salute, del lavoro come parziale mezzo di
sostentamento, di un po’ di studio a corredo della sapienza, ecc.

Invece lo Spirito, attraverso Maria, Capo, Madre e Maestra dell’Opera, ci ha aperto il cuore
su tutti gli aspetti della vita.

E in questa maniera, dando tempo a tutto, il Movimento è arrivato in tutto il mondo.

E allora, avanti! Rimaniamo fedeli alla formula attuale. Per essa porteremo mattoni su
mattoni all’edificio della nostra vita spirituale e dell’Opera.

Con la prossima volta inizia un nuovo anno ideale.

L’88 era stato l’anno di fuoco. L’89 quello fruttuosissimo. Penso che il ’90 sarà l’anno dello
Spirito Santo.

Approfondiremo, infatti, il rapporto fra la terza Divina Persona e il nostro Movimento. E
sarà un anno meraviglioso.

Ma, se in questi giorni continuiamo a vivere la volontà di Dio, ci troveremo meglio disposti
ad accogliere ciò che lo Spirito Santo ci dirà e ci darà.$doc1702$, 'drive_import', '01702-WEB-1989-09-14-la-volont-di-dio-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1702)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1703, 'ITA', $doc1703$Rocca di Papa, 28.9.89
CHIEDERSI AD OGNI AZIONE CHE COMPIAMO:
STO EVANGELIZZANDO?

Carissimi,

È stato lanciato da qualche anno nella nostra Chiesa cattolica, e anche fuori di essa, nelle
altre Chiese, un imperativo insistente che esprime un’esigenza imprescindibile: urge
evangelizzare o, meglio, rievangelizzare.
Nasce dall’amara costatazione che l’Europa, ma non solo essa, è stata invasa dalla
secolarizzazione, dal materialismo. I principi evangelici sono sempre meno considerati,
seguiti; la vita cristiana è spesso ignorata, abbandonata, e anche Cristo oggi – come ha detto
un religioso-poeta 29 – "non è più comprato (da molti cuori) nemmeno per trenta denari".
Sembra proprio che tutto debba ricominciare da capo.
Come ci sentiamo noi, membri del Movimento dei Focolari, di fronte a questo vastissimo
problema? Come essere autentici figli della Chiesa oggi, quand’essa implora di incamminarci
tutti nella linea di una nuova evangelizzazione? Dobbiamo cambiare qualche cosa?
Dobbiamo aggiungere qualche cosa? Dobbiamo assumere nuove responsabilità?
Per rispondere bene a tale quesito, bisogna riandare alla nostra storia e vedere cosa Dio ha
chiesto da noi proprio in questo secolo così scristianizzato.
Ricordate i primi tempi.
Egli non ha permesso che avessimo altro in mano se non il piccolo libro del Vangelo.
Per una grazia speciale dello Spirito Santo, abbiamo compreso parole fondamentali di quel
libro in maniera completamente nuova.
E siamo stati così attratti da ciò che vi era scritto, da pensare che la regola del Movimento,
che stava per nascere, non doveva essere altro che il Vangelo.
Nel Vangelo, del resto, trovavamo tutto.
In esso confluiva l’Antico Testamento; in esso era contenuta la legge della vita, la stessa
legge della vita della Trinità partecipata da Gesù agli uomini; nel Vangelo si rivedeva
scaturire dal cuore di Cristo la Chiesa, la sua gerarchia e, illuminato dalla promessa dello
Spirito da lui fatta agli apostoli, il pieno senso del suo magistero; di esso erano applicazioni
e quindi spiegazioni ed ampliamenti, gli altri libri del Nuovo Testamento.

Dunque il Movimento aveva trovato! Vivere il Vangelo, diffondere il Vangelo era la sua
vocazione.

Ma, pensiamo un po’: non è questa autentica evangelizzazione, anzi nuova evangelizzazione
e in più di un senso?

In seguito, si sa, sono emersi dal Vangelo alcuni punti che hanno dato origine alla nostra
spiritualità evangelica.

Ma essi vanno capiti, interpretati nel contesto dell’intero Vangelo e di tutto ciò che è
connesso col Vangelo. Sarebbe miseramente riduttivo, sarebbe grave errore, vederli
diversamente.

Sì, perché il Vangelo è come una grande rete. Noi la solleviamo con le mani inserendoci in
dodici suoi anelli (i punti della nostra spiritualità), ma così è l’intera rete che solleviamo.

Perciò si può dire che la nostra spiritualità poggia senz’altro sui dodici punti sottolineatici
dallo Spirito nel Vangelo, ma anche che la nostra spiritualità è il Vangelo.

E tutto ciò è accaduto – io penso – affinché, quando la Chiesa avrebbe sentito l’urgenza di
una rievangelizzazione e l’avrebbe poi intrapresa in molti modi, lo Spirito Santo avrebbe
suscitato delle forze (e fra queste la nostra) in grado di attuarla.

Carissimi, come rispondiamo allora alla domanda: Che cosa fare? Come inserirci in questa
nuova evangelizzazione?

Dobbiamo rispondere essendo maggiormente coscienti di ciò che Dio ci ha donato e
vivendolo con maggiore pienezza.

Dio non ha chiesto a noi per prima cosa di costruire lebbrosari, orfanotrofi, scuole ed altre
opere di bene. (Queste le abbiamo anche noi, ma vengono dopo).

Dio ci ha messo in mano il Vangelo, ci ha dato una nuova luce sul Vangelo, un modo di
vedere e di capire il Vangelo adatto proprio a questi tempi. Nostro primo compito è donare
questo Vangelo agli altri, annunziarlo, diffonderlo.

"Guai a me se non evangelizzassi" (cf. 1 Cor 9, 16), diceva san Paolo perché apostolo.

"Guai a noi se non evangelizzassimo", dobbiamo ripetere noi, piccoli apostoli.

E come? Con la vita e con la parola.

Certo, non è che noi evangelizziamo solo quando distribuiamo la Parola di Vita. Lo facciamo
sempre quando viviamo il nostro Ideale.
Superiamo i dolori, andando – come noi diciamo – "al di là della piaga"? Evangelizziamo: i
fratelli non sono insensibili al Risorto che vive in noi.

Stabiliamo la presenza di Gesù fra noi cosicché si realizza l’unità? Evangelizziamo: infatti il
mondo crede.

Parliamo, scriviamo, dialoghiamo, partecipiamo attivamente a Mariapoli, Congressi,
Giornate, Scuole, Convegni, gruppi? Coltiviamo il nostro grappolo? Evangelizziamo.

Lavoriamo col nostro spirito nelle strutture della Chiesa? Evangelizziamo.

E allora non c’è che da andare avanti con la nostra vita Ideale.

Forse dobbiamo sottolineare il parlare, dopo che si è vissuto, s’intende, ma parlare. Si
parlava di più i primi tempi. La fede arriva alle persone perché hanno udito la Parola di Dio.
Parlare. E, se è difficile parlare perché c’è chi è – per così dire – allergico ai Movimenti, ad
esempio, parliamo dei suoi principi soltanto: come si fa ad amare, ad affrontare il dolore,
come va vista la Chiesa, il Papa, come si deve essere onesti, puri, distaccati.

Oggi, del resto, tutti parlano: c’è più libertà d’un tempo; c’è rispetto delle idee altrui, perché
c’è tolleranza. Approfittiamone e parliamo anche noi.

Adesso poi che assistiamo in Europa, ad esempio, ad avvenimenti eccezionali come il crollo
di barriere, e molti dell’Est, spesso privi di nozioni religiose, vengono nell’Ovest, urge
doppiamente evangelizzare. Non dobbiamo permettere che trovino qui solo il consumismo
e gli altri mali. Devono incontrare la Chiesa viva, cristiani autentici.

C’è dunque molto, moltissimo da fare.

Per concludere, nei prossimi quindici giorni cerchiamo di chiederci ad ogni azione che
compiamo: Sto evangelizzando? E parlare un po’ di più.$doc1703$, 'drive_import', '01703-WEB-1989-09-28-chiedersi-ad-ogni-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1703)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1704, 'ITA', $doc1704$Rocca di Papa, 23.11.89
MIO DIO E MIO TUTTO

Carissimi,

Stiamo vivendo in un’epoca meravigliosa, anche se non priva di interrogativi. Si dice e si
ripete che questo (il 1989) è stato un anno straordinario. E si prevede che avrà nuovi
sviluppi, nuovi sbocchi. Si gode per qualcosa che se ne va precipitosamente e, anche se con
qualche sospensione, per ciò che può sopravvenire.
I fatti sono sotto gli occhi di tutti. Ne abbiamo fatto un veloce accenno l’ultima volta: nei
paesi dell’Est europeo qualcosa si sta sfaldando, dissolvendo: un macigno si sta sgretolando,
come un pallone che inesorabilmente si sgonfia. Un’ideologia, anche affascinante, che ha
infuocato e illuso un terzo di mondo, si va spegnendo.
Si danno, naturalmente, le spiegazioni più diverse a questo fenomeno.
Se ne individua, ad esempio, la causa nell’imprescindibile esigenza di valori (come quello
della libertà, della dignità, del diritto alla vita, della legalità, della coscienza) che viene a
galla in popoli interi che, reclamando una nuova vita, si versano come fiumi nelle piazze
delle loro città...
Si vede, e non solo nel mondo cattolico, nell’elezione di un papa slavo, con tutte le
conseguenze che ne sono venute, il fattore dirompente di una rivoluzione pacifica, grazie a
Dio, che dilaga.
Si constata che altri personaggi, oggi di primo piano, hanno avuto e hanno il loro influsso in
tutto quanto succede.
Argomenti convincenti tutti questi che noi non possiamo non condividere.
Ma, vien fatto di chiedersi: È solo tutto qui?
La nostra risposta è che si dovrebbe aggiungere ancora qualcosa, anzi, scavare più a fondo.
Occorre andare alla radice di tutte queste cause.
Ci sembra, infatti, che il più profondo perché di quello a cui stiamo assistendo stia nelle
profetiche parole di Gesù, che non possono non risuonare oggi in tutto il nostro continente e
anche fuori: "Chiunque ascolta queste mie parole e non le mette in pratica [le parole di Dio:
chiunque cioè non conforma il proprio vivere ed operare al pensiero di Dio, alla sua volontà]
è simile ad un uomo stolto che ha costruito la sua casa sulla sabbia. Cadde la pioggia,
strariparono i fiumi, soffiarono i venti e si abbatterono su quella casa, ed essa cadde, e la sua
rovina fu grande" (Mt 7, 26-27).

La Parola di Dio, che è Dio stesso, Dio, che è alla radice delle più profonde esigenze
dell’uomo e agente nella storia, non ha avuto posto in quella costruzione. Anzi. Tutti
conosciamo le vicende del nostro secolo.

Ora è bastato qualche venticello contrario come l’assaggio di nuove idee, di nuove vedute, di
nuove prospettive, filtrate da un Occidente più libero, anche se non privo di aspetti negativi;
è bastata soprattutto la verifica di colossali fallimenti..., perché tutto non regga.

E questa è per noi la riprova, al negativo, di quanto abbiamo affermato due collegamenti fa:
la necessità di costruire sulla roccia: sulla Parola di Dio, su Dio.

Costruire su Dio.

I cristiani poggiano la loro vita su Dio.

Noi, poi, aderendo al nostro Movimento, abbiamo messo Dio più coscientemente a
fondamento di tutta la nostra esistenza. È la scelta di lui il primo passo che lo Spirito Santo
ha fatto fare al Movimento nascente e ha fatto fare ad ognuno di noi quando lo abbiamo
incontrato.

Lo Spirito, infatti, quando agisce, opera spesso come nel battesimo: fa morire e risorgere:
morire ai nostri ideali precedenti e risorgere all’unico ideale immortale: Dio.

Anche ora deve rimanere viva in noi questa scelta radicale.

I nostri volontari nel ’56, quando si spegneva il sogno di libertà in Ungheria, sono nati al
grido lanciato da Pio XII: "Dio, Dio, Dio" e si sono detti "volontari di Dio". Ma tutti siamo di
Dio, noi, membri del nostro Movimento.

E se lo siamo, se Dio è tutto per noi, esprimiamo questa realtà, diamo sfogo al nostro amore
per lui: adoriamolo infinito al di là del creato, glorifichiamolo presente dovunque
nell’universo intero, lodiamolo nel fondo del nostro cuore e vivo nei tabernacoli.

Abbiamo detto, nei 18 punti programmatici del nuovo anno, che in esso, per onorare lo
Spirito Santo, cercheremo di migliorare le preghiere che a lui offriamo.

Ce ne viene offerta l’occasione in questi prossimi quindici giorni: pregare, cantare,
inneggiare in tutte le maniere al Padre, a Gesù, allo Spirito, come facevano i primi cristiani.
Con la preghiera, che è nostro dovere ogni giorno offrire al Cielo, scopriremo immense
possibilità di esprimere questo nostro sentimento. Ma bisogna anche ripetere col cuore
tutto il giorno, ogni qualvolta si può: "Dio, Dio, Dio,"; "mio Dio, mio tutto", "mio Dio, mio
tutto".

In tutto il pianeta dove siamo disseminati, rimanere, poi, il più possibile uniti a lui in questo
Natale e mentre col dissolversi delle ideologie si stempera e perde la sua morsa l’ateismo,
cantare, gridare con la nostra vita e le nostre parole assieme agli angeli: "Gloria a Dio nel più
alto dei cieli" (Lc 2, 14)

Che il prossimo sia così il più bel Natale della nostra vita, il più spirituale, il più divino,
quello che fa risuonare il nome di Dio sul mondo intero.$doc1704$, 'drive_import', '01704-WEB-1989-11-23-mio-dio-e-mio-tutto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1704)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1705, 'ITA', $doc1705$Rocca di Papa, 14.12.89

AMARE GLI UNI E GLI ALTRI

Carissimi,

Essendosi il nostro Movimento, perché Opera di Dio, diffuso su tutto il pianeta
(anche se in parecchie nazioni siamo ancora in pochi e da poco arrivati), seguiamo
dal Centro tutto quanto avviene nel mondo con uno speciale interesse, con una
particolare partecipazione, che vuol essere condivisione delle sofferenze provocate
ad esempio da disordini o da guerre, e condivisione delle gioie, come quando il
Santo Padre, nei suoi numerosi viaggi, solleva nei popoli corali manifestazioni di
fede e di amore, o come quando un Paese, che ha sofferto a lungo la tirannia,
riacquista la libertà.
Ci stanno profondamente a cuore tutte le varie vicende che vengono alla ribalta della
cronaca dall’est all’ovest, dal nord al sud, e ci teniamo collegati, telefonicamente e con fax
con i nostri delle varie nazioni, per sapere come vanno le cose, come stanno loro stessi, quali
pericoli corrono, o quali grazie li investono. E il Libano con il suo dramma e il Salvador e la
Palestina e le varie vicende delle nazioni africane, e il Nicaragua e il Cile, e la Corea col
problema della sua unità, e Malta col suo storico incontro e le Filippine con le sue ricorrenti
difficoltà e la Cina e la Cambogia e la Colombia e Panama con gli attuali avvenimenti e altri,
altri Paesi, sono nel cuore di tutti con le loro prove, le loro speranze, le loro sconfitte e le
loro conquiste.

Arde in noi un desiderio sempre più forte: poter venir incontro, almeno un po’, alle
situazioni più dolorose; fare qualche cosa, perché – lo ricordiamo sempre – dovunque siamo
arrivati col nostro grande Ideale, la gente ci ha sempre detto: "È fatto proprio per noi"; fatto,
quindi, anche per i loro problemi.

E si rafforza il proposito di crescere, crescere, con l’aiuto di Dio, di moltiplicarci per dare
anche noi un contributo positivo all’umanità.

In questi giorni poi sono ancora di bruciante attualità gli avvenimenti dell’Est europeo,
avvenimenti che – se è vero quanto abbiamo affermato sulla casa costruita sulla sabbia –
non potranno non verificarsi presto o tardi, magari in altro modo, anche in altre nazioni del
mondo: l’ideologia marxista è presente, lo si sa, un po’ dovunque.

E dovunque, e ora specie nell’Est europeo, il Movimento ha un suo preciso compito.

Noi vediamo come in quelle nazioni la gente si è venuta a trovare, grosso modo, su due
posizioni. C’è chi plaude alla libertà, è estremamente felice di averla finalmente raggiunta.
C’è chi avverte di dover cambiare col passato, ma è alla ricerca di una nuova via che non
significhi rinuncia totale a ciò in cui ha finora creduto.

Come comportarci noi con gli uni e con gli altri?

Il nostro Ideale ci chiama ad amare tutti. Esso ci spinge a far comprendere a chi ha ritrovato
la libertà – e ciò vale anche in Occidente e dovunque la si possiede – in che cosa essa
consista realmente: non solo, non tanto nello scegliere fra bene e male, ma nell’andare
sempre più verso il bene. È così che si diventa sempre più liberi. Il nostro Ideale ci insegna
ancora che la libertà non consiste nell’accumulare, come si fa dove domina il consumismo, o
nel cercare la felicità a tutti i costi, come nell’edonismo e nella droga, ma che si è veramente
liberi e si ha la vera gioia nell’amare, nel dare.

Il nostro Ideale, poi, ci spinge ad amare coi fatti, a rimboccarci le maniche e ad aiutare, ad
esempio, chi nell’Est europeo ha il compito e la vocazione a dare un nuovo assetto alla
società: sociale, politico, economico; a dare una mano alla Chiesa, ad aiutare i responsabili a
riorganizzarla meglio, a potenziarla. Questo il nostro compito con quelle persone.

E per gli altri? A che cosa ci spinge l’Ideale?

Occorre innanzitutto ricordare che l’ideologia marxista non avrebbe potuto affascinare e
trascinare tanta gente e così numerosi popoli, se non avesse riguardato – anche se sulla base
di una dottrina errata – temi che toccano le esigenze profonde dell’uomo, come l’attenzione
alle classi disagiate, il bisogno di una visione globale del mondo, l’esigenza di unità, la pace,
la socialità dell’uomo. Ideali che poi venivano contraddetti vistosamente nei fatti.

Ma di per sé, questi ideali costituivano e costituiscono ancora in molti di coloro che ne sono
attratti, la loro identità, la loro caratteristica. Quegli ideali, per quanto hanno di buono, non
dovrebbero morire, non devono morire.

Ma perché ciò sia, occorre radicarli là donde hanno avuto la prima origine: in Dio, in Gesù
Cristo. In lui, che ha prediletto, più di ogni altro, gli ultimi, i poveri, facendosi oltretutto
povero come loro, più di loro, quando è morto in croce spogliato completamente di ogni
bene materiale e spirituale; in lui, che ha predicato una vita sociale di fraternità fra gli
uomini tale da potersi modellare addirittura sulla vita della SS.ma Trinità; in lui, che ha
impersonato la pace più vera e sicura ed ha vissuto perché sulla terra vi fosse l’unità, l’unità
di tutti i popoli in uno, nel popolo di Dio che è la sua Chiesa, a segno ed emblema di ciò che
dovrebbe essere il mondo.

Questo occorre ricordare.

E non vi sembra che qui, proprio qui, anche qui, specie nel Movimento dei Focolari, abbiamo
una parola da dire?

Non vi sembra questo un campo particolarmente adatto alla nostra evangelizzazione?
Sappiamo come nei paesi dell’Est, molti, nel turbine degli attuali avvenimenti, sono smarriti,
disorientati, profondamente delusi e depressi, perché, spesso in buona fede, hanno creduto
in questi ideali che ora vedono infrangersi.

E allora mentre condividiamo la gioia e l’impegno di coloro che, nella ritrovata libertà,
s’avviano verso un futuro diverso, non potremmo noi essere di aiuto anche a questi altri,
assicurandoli che tutto non è perduto, che Dio sa trarre il bene da ogni cosa, che egli segue
la storia ed ha seguito anche la loro; che si tratta di vedere in un altro modo quello cui
hanno creduto finora; che sì, l’unità è possibile, ma così e così...; che quanto hanno sognato
può divenire meravigliosa realtà non nella lotta, ma con l’amore e con Dio?

Questo dobbiamo dire.

Con la parola e con la vita: essendo soprattutto noi stessi, sempre più radicalmente noi
stessi. Quando Dio, in questa precisa epoca, ci ha donato il carisma dell’unità, sapeva che
poteva essere di utilità anche per tutti gli attuali problemi.

Essere dunque noi stessi, così come Dio ci vuole, amando il bello e il buono: come gli aneliti
e la conquista della libertà; ma amando anche Gesù Abbandonato in quell’umanità che è
stata illusa e ora delusa, ed è in ricerca.

Così saremo veramente cristiani che sanno amare, che sanno perdonare. Così saremo
focolarini che non vogliono vedere il mondo diviso fra vinti e vincitori, ma vogliono che tutti
siano vinti dall’amore di Dio per essere con lui vincitori.

E allora, nei prossimi quindici giorni, prendiamo in rilievo nei nostri gruppi, nei nostri
grappoli, nei nostri convegni, fra i nostri conoscenti o parenti (usando ogni mezzo: parola,
lettere, telefono, ecc.), quei prossimi più o meno lontani, tentati di appoggiarsi sui falsi idoli
dell’Occidente, e non dimentichiamo coloro che più assomigliano a Gesù Abbandonato.
Chiediamo allo Spirito Santo di suggerirci le parole giuste per illuminare, raddrizzare e
anche sollevare.

Seminiamo. Un giorno noi (o altri) raccoglieremo.

Questo è evangelizzare. Questo è mettere in azione lo Spirito Santo che ci ha donato l’Ideale
perché lo doniamo come medicina per gli uomini del nostro tempo: quello Spirito Santo che
rinnova la faccia della terra e sa rinnovare ogni angolo di essa a noi affidato.$doc1705$, 'drive_import', '01705-WEB-1989-12-14-amare-gli-uni-e-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1705)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1706, 'ITA', $doc1706$Rocca di Papa, 28.12.89

1990

sere il nostro ideale vivo

e pregare meglio

Carissimi,

         in ottobre ci siamo lasciati coi responsabili delle zone col fermo proposito di
migliorare quest'anno le nostre preghiere. Lo abbiamo fatto per onorare lo Spirito Santo che
vogliamo conoscere più in profondità, Spirito Santo che, quando preghiamo, aiuta tutti e
prega anche con noi.

         Ed abbiamo anche pensato di prendere in rilievo una preghiera alla volta durante i
mesi che ci stanno dinanzi.

         Questa volta parliamo del rosario.

         Lo so che sto parlando non solo a cattolici, ai quali il rosario è familiare, ma anche ad
altri cristiani di Chiese e comunità cristiane che lo conoscono poco e non lo praticano. Ma,
per l'amore reciproco che esiste fra tutti noi, sono certa che anch'essi sono contenti di
sapere cos'è il rosario per noi. D'altra parte esso contempla non solo preghiere rivolte a
Maria, ma altre comuni a tutti.

         Ma perché il rosario?

         Per un fatto al quale, oggi, quasi nessuno accenna e che pure è presentissimo nel
mondo ed abbraccia il brano di storia che stiamo vivendo.

         Siamo convinti, infatti, che negli avvenimenti dell'est europeo, che hanno segnato la
fine del 1989 e continuano a svolgersi, giorno dopo giorno, nel '90, fra nuove conquiste ed
inevitabili difficoltà, c'è di mezzo la Madonna. E' questo anche il pensiero del S.Padre.

         C'è di mezzo in maniera discreta come è suo stile, perché vuole che tutta la gloria sia
data a Dio, ma c'è. L'aveva promesso a Fatima. (E Fatima, con tutto ciò che significa, è una
cosa seria, se due Papi l'hanno visitata e con ciò approvata). Aveva promesso che
"finalmente" il suo Cuore Immacolato avrebbe trionfato. Su cosa? Sull'ideologia materialista,
sull'ateismo, liberando popoli annientati. E lo ha fatto e lo sta facendo e tutti lo vedono.

         Ma di Lei - come ho detto - non si parla.

         Noi però, che siamo Opera di Maria, non possiamo sottacerlo. Dobbiamo dirlo
almeno fra di noi.
         E dobbiamo soprattutto ringraziarla, lodandola, e pregarla di intercedere ancora
presso Dio, perché porti a termine quest'opera che interessa tutti, perché dà un nuovo
assetto all'Europa e ha conseguenze sul mondo intero.

         Possiamo fare ciò non moltiplicando le preghiere, ma perfezionando quelle che già
pratichiamo.

         Nell'Ave Maria, ad esempio, che recitiamo cinquanta volte nel rosario (perché chi
ama non smetterebbe mai di ripetere il proprio amore) abbiamo modo di lodarla: "piena di
grazia" - diciamo - "il Signore è con te", "tu sei benedetta fra le donne..."

         Dobbiamo ripetere queste parole col cuore gonfio d'amore, come a dire: se tale sei,
capiamo perché hai potuto tanto.

         E poi nella Salve Regina: "Madre di misericordia, vita, dolcezza, speranza nostra",
"avvocata nostra, clemente, pia, dolce vergine Maria."

         E nell'Ave Maria abbiamo modo anche di pregarla, chiedendole di intercedere
ancora: "prega per: noi peccatori adesso...", in questo tempo così eccezionale.

         E nella Salve Regina: "A Te ricorriamo..., a Te sospiriamo..., i tuoi occhi
misericordiosi rivolgi a noi..."

         Ma - come ho detto - nel rosario non si prega solo Maria: c'è il Gloria che tutti
possiamo innalzare al Cielo, nel quale si dà sfogo al proprio cuore che vuole gridare la gloria
della S.S. Trinità; c'è il Padre Nostro con cui tutti possiamo implorare: che sia santificato il
suo nome anche là dove è stato messo sotto silenzio; che venga il suo Regno, con la
dilatazione della Chiesa, dovunque; e anche là dove è stata perseguitata; che sia fatta la sua
volontà e non quella degli uomini; che sia dato il pane che tanto manca (è il primo problema
da risolvere in quei paesi); che vinca il perdono reciproco, che ogni tentazione di reciproca
sopraffazione stia lontana.

         E nel rosario si passano in rassegna i misteri della nostra fede, la storia della nostra
salvezza comune a tutti i cristiani.

         Sì, dobbiamo migliorare - ognuno come può - questa preghiera, il rosario, per
riconoscere la dolcissima protagonista di quanto è successo e succede di grande, perché non
dimentichi che ora, crollati i muri, occorre con quelle pietre - come ha detto il Papa -
costruire la casa comune europea, un pezzo di quella unità del mondo in cui, come bambini,
speriamo.

         Dobbiamo anche pregarla perché, come è intervenuta nel nostro continente, così
intervenga in quelle nazioni dell'Asia, dell'Africa, dell'America Centrale, dove non bastano
gli sforzi umani per liberare i popoli, ma occorrono interventi soprannaturali come quelli
cui abbiamo assistito.
         E poi dobbiamo pregarla per tutta l'umanità, per tutti i problemi. Lei è madre di tutti
e di ognuno, abbraccia il mondo ed ogni singola persona, appunto perché madre.

         Gesù non predicava soltanto, non faceva solo miracoli, non chiamava solo discepoli a
seguirlo: s'immergeva nella preghiera al Padre. Maria poi era tutta devozione, tutta
inabissata in Dio.

         La preghiera non può non aver un posto di privilegio anche nella nostra vita. E' uno
dei segreti della fecondità del nostro agire.

         Nei prossimi quindici giorni, perciò, attenzione alla preghiera e, in particolare, al
rosario.

         Perché si può intuire come ha fatto Maria a intervenire nella storia che viviamo. Ha
soprattutto pregato. Ha pregato così bene, così a lungo, da ottenere.

         Certamente Lei ha ottenuto perché era la tutta santa, la tutta bella, l'onnipotente per
grazia.

         Per quanto possiamo, dobbiamo anche noi essere santi, almeno nel presente; essere
cioè il nostro Ideale vivo, sempre in cammino nel Santo Viaggio, sempre nell'amore, sempre
- come diciamo - "al di là della piaga."

         Se la nostra preghiera al Padre, alla S.S. Trinità, a Gesù, a Lei, poggerà su questa
realtà, sarà gradita a Dio.

         E allora proponiamo oggi d'essere Ideale vivo e di pregare meglio.$doc1706$, 'drive_import', '01706-WEB-1989-12-28-sere-il-nostro-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1706)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1707, 'ITA', $doc1707$Rocca di Papa, 25 gennaio 1990

"Fra Gesù e Maria"

Carissime,

         siamo in cammino nel Santo Viaggio della vita e vediamo - da quanto succede
attorno a noi anche solo nell'ambito del Movimento - come c'è sempre qualcuno che arriva
alla méta, che conclude spesso improvvisamente il suo itinerario terreno. Questo spinge
tutti noi ad accelerare il passo, a metterci in giusta posizione perché il nostro cammino, la
nostra corsa sia la più perfetta possibile.

         Spesse volte però - tocca anche a me e, penso, anche a voi - viene in cuore un
desiderio: sapere su cosa concentrare l'attenzione della nostra mente, su cosa impegnare la
nostra volontà e le nostre forze per essere certi di fare tutto quello che è possibile, per non
trascurare nulla di ciò che ci propone il nostro Ideale onde poter dire: "Anche se sempre
indegno, mi sono sforzato di fare tutta la mia parte. Ora posso attendere umilmente che il
Signore compia la sua."

         Ebbene una risposta c'è a questo desiderio.

         Si tratta di porsi nella disposizione migliore per poter seguire Gesù, perché è Lui la
perfezione, è Lui la via.

         Ed Egli ci ha detto esplicitamente cosa occorre per poterlo seguire: "Se qualcuno
vuol venire dietro a me, rinneghi se stesso, prenda la sua croce e mi segua" (Mt 16,25).

         Due cose dunque: rinnegarsi e abbracciare la croce.

         Lo dobbiamo fare.

         Ed appare utile, per attuare queste due imprescindibili richieste di Gesù,
immaginare il nostro Santo Viaggio in questo modo: ciascuno di noi deve camminare nella
vita in compagnia di Gesù e Maria, fra Gesù e Maria, pensando - se vogliamo aiutarci anche
con l'immaginazione - Gesù alla nostra destra e Maria alla nostra sinistra. O, meglio ancora,
camminare in compagnia di Gesù nella massima espressione di sé e cioè nel suo abbandono,
e di Maria, nella più alta rivelazione del suo essere, nella sua desolazione.
         Sì, perché Gesù abbandonato è il prototipo di chi sa abbracciare bene la croce. E la
Desolata è il modello di chi sa rinnegare se stesso, di chi sa perdere (ha perso persino Gesù,
suo Figlio-Dio).

         Cosicché, camminando fra loro due, impareremo a seguire Gesù, che significa
imparare a diventare santi, che è l'obiettivo del nostro Santo Viaggio.

         Gesù abbandonato ci insegna il modo di abbracciare le croci, ogni croce. Non c'è
prova più grande di quella di un Dio che si sente abbandonato da Dio. Ed Egli l'ha provata e
l'ha superata: "Nelle tue mani, Padre, raccomando il mio spirito" (cf Lc 23,46). E' andato,
dunque - come noi diciamo - "al di là della piaga". Così dobbiamo fare noi di fronte ad ogni
dolore.

         Maria desolata ci insegna a rinnegarci, a perdere.

         Come? Non pensando a noi stessi, pensando agli altri: amando. Maria ha vissuto la
sua desolazione per amore di tutti noi.

         Nell'amare gli altri noi troviamo come Lei la via maestra del rinnegamento di noi
stessi.

         Se poi, nonostante il nostro sforzo d'amare, rimanesse qualche attaccamento nel
nostro animo (a noi stessi, alle creature, alle cose), sull'esempio di Maria desolata
dovremmo saperlo perdere sempre. Dire: "Questo lo perdo", "questo va perso" e continuare
a vivere la volontà di Dio dell'attimo dopo.

         Ma, se faremo così, se compiremo il nostro Santo Viaggio in compagnia di Gesù
abbandonato e di Maria desolata, non rimarrà in noi l'impronta dell'Abbandonato, ma del
Risorto, né quella della Desolata, ma di Maria gloriosa.

         Ed è con lo splendore dei due in noi che possiamo camminare sicuri verso la méta,
come anche compiere qualcosa di bello, di utile, di grande qui sulla terra per l'Opera, la
Chiesa, l'umanità.

         E contribuire così pure noi sempre meglio a quel positivo processo che si sta
sviluppando nel mondo da qualche mese e ad altri che stanno in gestazione, ma, pensiamo,
verranno anch'essi alla ribalta onde rendere più vicino l'obiettivo di un mondo più unito.

         Allora per i prossimi giorni, camminare fra Gesù abbandonato e Maria desolata.

         Aiutati anche dalla Parola di vita di questo mese, tutta intonata a quanto abbiamo
detto. "Io ritenni - dice in essa Paolo - di non saper altro in mezzo a voi se non Gesù Cristo e
questi crocifisso." (1Cor 2,2).
         Così anche noi: camminare conoscendo solo Gesù crocifisso alla nostra destra e
Maria desolata, altro crocifisso, alla nostra sinistra.

         Ci accorgeremo ben presto che fiumi di pace entreranno nella nostra anima e
sorgenti di gioia saremo per molti e molti.$doc1707$, 'drive_import', '01707-WEB-1990-01-25-fra-ges-e-maria-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1707)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1708, 'ITA', $doc1708$Rocca di Papa, 8 febbraio 1990

insegnamento di Renata

Carissime,

         in questi ultimi giorni abbiamo accompagnato Renata, la nostra responsabile della
cittadella di Loppiano, nel suo ultimo viaggio.

         Abbiamo accompagnato le sue spoglie nel cimiterino locale, ma anche l'abbiamo
seguita giorno per giorno nel breve tratto del suo santo viaggio da quando le è stata
annunciata la malattia mortale.

         Ma parlare di "spoglie" e parlare di alcunché di "mortale" sembra un controsenso
con ciò che è successo a Renata.

         Lei è ed è restata il simbolo della Vita, di quella Vita vera per la quale Gesù ha detto:
"Chi vive e crede in me, non morrà in eterno" (cf Gv 11,26).

         La Vita (con la V grande) in Renata si è colta, si è vista fino all'ultimo istante: e che
vita!

         Accettata, infatti, con tutto il cuore la nuova volontà di Dio, aveva avuto la grazia di
sperimentare (così diceva) che la morte è vita, che la morte è risurrezione e s'era proposta,
con l'aiuto di Dio, di dare questa dimostrazione fino alla fine. E c'è riuscita, trasformando
così un evento di morte in un tempo di Pasqua: una meraviglia, uno splendore, un qualcosa
di inesprimibile!

         Sempre su, sempre nel soprannaturale, sempre in Dio, ha pregustato - così è parso -
già prima di partire, prima di lasciarci, il Paradiso.

         Questo diceva estasiata con il suo atteggiamento e le sue espressioni.

         In realtà non abbiamo avvertito in lei un partire, un lasciarci. E' passata veramente
da una stanza all'altra, da una Mariapoli (Loppiano che ora porta il suo nome) ad un'altra. E
non ci ha lasciati. E' rimasta. E' quanto sentiamo in cuore.

         Come spiegare questo prodigio? Come descrivere questa straordinaria "lezione di
vita" che Renata ha voluto donare alle focolarine a lei affidate, a Loppiano e a tutti noi? Si
muore come si vive.

         E a volere affrontare qui anche una minima descrizione della bellezza della sua
anima si minaccia di guastare ogni cosa. E' stato letto un suo ricordo un po' esterno durante
la santa Messa d'addio e lo potrete trovare su Mariapoli. Abbiamo raccolto altro di ben più
profondo e lo faremo conoscere in una sua vita.

         Renata era una delle prime focolarine di Roma entrata in focolare già nel 1950.

         Ha servito l'Opera per quarant'anni avendo modo di sviluppare, maturare in sé tutte
le virtù, tutte.

         E sono questi lunghi anni di corrispondenza alla grazia che spiegano anzitutto il suo
ultimo periodo, che l'hanno resa - come è stato detto - una stella di prima grandezza, che
l'hanno trasformata in un angelo.

         Corrispondenza sotto mille aspetti, corrispondenza al nostro carisma che plasma dei
piccoli o meno piccoli santi: è la nostra ormai consolidata esperienza.

         Ed è su un particolare fondamentale di questo carisma, così come Renata l'ha
vissuto, che vorrei soffermarmi oggi: l'amore per gli altri, il donarsi agli altri.

         Renata ha amato i fratelli per anni. E non li ha amati soltanto con un servizio
materiale (che non è mai mancato), ma soprattutto con uno spirituale. Era nelle condizioni
di farlo: doveva trasmettere la nuova vita che Dio ci ha dato.

         Lo ha fatto con un numero incredibile di persone giorno dopo giorno nei primi
diciassette anni della sua vita di focolare a Roma, a Trento, a Sassari, a Parma, a Trapani, a
Grenoble, alla scuola di formazione di Grottaferrata, a Milano, ma soprattutto negli ultimi
ventitré anni a Loppiano, dove ha formato più di mille focolarine alla nostra spiritualità.

         E si sa: "Date e vi sarà dato" (Lc 6,38). Ha dato vita in abbondanza e ha ricevuto vita
in abbondanza.

         Ma c'è vita e vita; c'è vita cristiana e vita cristiana. In lei, un po' come nei santi, era
presente una dimensione particolare della vita cristiana, oserei dire una dimensione
mistica; una dimensione tale che era la sua persona, il suo essere, il suo silenzio, il suo
sorriso che operavano prima delle sue parole.

         Renata ha amato. Alla fine della sua vita poteva dire: "Ho sempre amato."

         Vogliamo lasciare anche noi nel mondo un ricordo imperituro come il suo? Un
esempio luminosissimo per molti, una scia di luce come ha lasciato quest'angelo? Vogliamo
farlo, perché chiamati a ciò secondo lo stile del nostro Movimento?

         Amiamo i fratelli, diamoci da fare per formar Cristo in loro, in molti; comunichiamo
il nostro Ideale (è questo un compito primario in chi beneficia di un carisma) e lo Spirito
Santo formerà Cristo in noi.

         Più o meno, senz'altro. Ma... abbiamo una vita sola. E allora viviamo in modo che sia
il più possibile.
         Renata ci interpella sul nostro modo di irradiare il dono di Dio. Ci fa riesaminare a
fondo il nostro apostolato, la nostra evangelizzazione; ci avverte che dovremo rendere
conto del talento ricevuto. Non sotterrarlo, certo, non risparmiarlo; farlo fruttare al
massimo.

         Il mondo, specie il mondo d'oggi, aspetta questo dono. Si ha fame di spirito, di
amore, di comunione, di autenticità, di Vangelo. E noi dobbiamo saziarlo. E lo facciamo? Lo
facciamo a sufficienza?

         Abbiamo affidati centri, focolari, nuclei, unità, grappoli, comunità, cittadelle,
convegni...

         Ci doniamo come Renata senza risparmio fin là dove ce lo permette la volontà di
Dio? Allarghiamo il cuore anche a molti, molti altri, specie se lontani, come era consuetudine
di Renata?

         Forse perdiamo ancora tempo a guardarci, o a porre attenzione a cose futili in
questa società dai mille surrogati che riempiono la giornata di vanità?

         E allora ricordiamoci: siamo in Quaresima. E' tempo di conversione anche per noi.
La Parola di vita del mese ci ammonisce: "Non di solo pane vivrà l'uomo, ma di ogni parola
che esce dalla bocca di Dio" (Mt 4,4).

         E' questa parola che dobbiamo comunicare, la Parola di Dio che lo Spirito ci ha
illuminato non solo per noi, ma per molti.$doc1708$, 'drive_import', '01708-WEB-1990-02-08-insegnamento-di-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1708)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1709, 'ITA', $doc1709$Rocca di Papa, 8 marzo 1990

Coltivare la purezza per amare meglio

Carissimi,

         continuiamo il santo viaggio. Esso - come sappiamo deve portarci alla santità.

         Ma in che consiste la santità per un cristiano?

         Sta nella perfezione dell'amore.

         Ringraziamo lo Spirito Santo d'averci indicato, sin dall'inizio, come nostra via
proprio la via dell'amore.

         Abbiamo teso, dunque, all'amore da quando abbiamo conosciuto il nostro Ideale.
Speriamo allora che la nostra vita spirituale abbia fatto qualche passo verso la perfezione.
Dobbiamo perciò continuare sulla stessa strada per crescere ancora. Perché si impara ad
amare, che significa tendere alla perfezione, soprattutto amando.

         Ci sono tuttavia altri modi che incrementano l'amore, che sono mezzi a quel fine,
puntelli all'amore. Si tratta dei cosiddetti consigli evangelici che ben conosciamo: castità,
povertà, obbedienza.

         Alcune diramazioni della nostra Opera vi ci sono impegnate formalmente, anche se
in maniere diverse, come i focolarini, le focolarine, i focolarini e le focolarine sposati, i
sacerdoti, i religiosi e le religiose. Però tutti i cristiani sono chiamati a vivere queste tre
virtù, così importanti per amare bene e di più.

         Per questo vorremmo soffermarci oggi almeno sulla prima: la purezza, la castità. E'
una virtù questa che deve splendere in modo tutto speciale nella nostra che è Opera di
Maria: siamo tutti chiamati infatti a rivivere, in certo modo, Maria; e non si concepisce la
Madre di Dio se non come vergine purissima e immacolata.

         Già brilla questa virtù: è la testimonianza che raccogliamo. Brilla appunto perché
l'amore che ci sforziamo di vivere è madre delle altre virtù, fra le quali la castità. Ma c'è
sempre modo e bisogno di farla splendere ancora di più in noi e di aiutare gli altri a viverla,
specie se a noi affidati.

         E' uscito in questi giorni un documento della S. Sede sul modo di formare i religiosi.
E' ricco della saggezza della Chiesa e vale anche per tutti noi. Fa ricordare tanti
suggerimenti che, pensiamo, lo Spirito Santo ci ha dato in ordine alla purezza.

         Si mantiene la purezza rimanendo anzitutto ben inseriti nelle nostre piccole o
grandi comunità. E' noto come i primi cristiani quando si sentivano tentati dal male impuro,
tornando in seno alla comunità, avvertivano una liberazione, tornava il sereno nel loro
cuore. Effetto - noi diremmo - di Gesù in mezzo o dell'amore soprannaturale che non
s'accorda con il falso amore.

         Sappiamo poi che, per far parte del Movimento, un giorno abbiamo scelto Dio, ma è
più vero che Dio ha scelto noi. Se cerchiamo di tanto in tanto di rimanere nella gioia e
nell'incanto di essere stati personalmente guardati e amati a Dio, se lo ringraziamo di ciò
con tutto il cuore, avremo trovato un altro mezzo per tenerci legati a lui e non,
disordinatamente, alle creature.

         Se abbiamo affidati ragazzi o giovani, sarà bene mantenere con loro un clima di
piena confidenza: esso faciliterà l'apertura e la possibilità di dare dei consigli in proposito, li
aiuterà al controllo di sé sul piano affettivo e li renderà attenti a quelle relazioni personali
che potrebbero essere di ostacolo alla pratica della castità.

         Occorrerà anche sottolineare l'immenso valore della fecondità della castità: cioè la
maternità e la paternità spirituale che è così presente nel nostro Movimento sin dai gen 4 e
dalle gen 4.

         Infine (e sta qui oggi uno dei più grandi pericoli per la purezza) comportarsi con
tutta la prudenza dovuta coi mezzi di comunicazione sociale. Forse sapete che i focolarini
l'ottobre scorso hanno fatto una scelta coraggiosa, radicale che, forse, non tutti
comprendono: hanno rinunciato alla televisione. Guardano solo il telegiornale e le
trasmissioni religiose.

         L'hanno fatto non perché sia male tutto ciò che la televisione trasmette, ma perché
hanno ravvisato in essa come una palla al piede che impedisce, specie con certi programmi,
il potersi mantenere o il progredire nella vita soprannaturale, a cui sono chiamati a tendere
con tutte le loro forze.

         Le loro esperienze in seguito sono state molto positive e, vorrei dire, entusiastiche.
Anche se vedevano la Tv molto poco, dicono che la "rinuncia" ad essa ha accresciuto il clima
soprannaturale e l'unità in focolare; che hanno trovato una nuova libertà, una nuova gioia;
che tutti sono felici di non perdere il tempo, ma di poterlo sfruttare perché l'Ideale avanzi;
sentono di poter perfezionare ora la preghiera: con la Tv si aprivano - dicono - all'ascolto
della voce del mondo, e non a quella dello Spirito Santo.

         Ora noi nell'Opera siamo in situazioni anche diverse, ma a tutti è richiesta la
prudenza nella scelta dei programmi, per non condurre una vita mediocre ed essere
nell'illusione di tendere a Dio mentre ci si immerge nelle cose del mondo.

         Nei prossimi quindici giorni facciamo attenzione alla purezza nostra, ed aiutiamo
soprattutto quelli per i quali dobbiamo essere maestri della nostra spiritualità.

         Teniamo presenti i suggerimenti che vi ho indicato per trarre delle conclusioni nella
vita pratica. Ne guadagnerà il nostro amore a Dio e al prossimo. E Maria ci guarderà con un
più grande amore.$doc1709$, 'drive_import', '01709-WEB-1990-03-08-coltivare-la-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1709)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1710, 'ITA', $doc1710$Rocca di Papa, 22 marzo 1990

Rinnovare il patto

Carissime,

         siamo ancora profondamente toccati da quello che Gesù ha operato nel nostro
Genfest '90.

         E' stata forse la manifestazione più vasta, più alta, più ricca di frutti, a cui abbiamo
assistito in tutti i nostri anni di vita ideale.

         Gli echi che arrivano da tutto il mondo, le fortissime impressioni, i capovolgimenti di
situazioni, la fede sicurissima nei nostri ideali, le radicali decisioni delle persone presenti, o
collegate coi mezzi di comunicazione, hanno superato tutte le aspettative.

         Non ci resta che prostrarci in ringraziamento a Dio per ciò che ha fatto e perché ora
ci aiuti a portare avanti ciò che ha operato.

         Per me tutto è stato "super", ma ciò che mi ha dato più gioia è stata la conferma
esplicita, meravigliosa, decisa, ripetuta del S. Padre del fine per cui non solo i giovani per un
mondo unito, ma tutto il nostro Movimento, nella sua veste di Umanità Nuova e Gioventù
Nuova, vive: arrivare ad un mondo unito.

         Lo credevamo, lo vedevamo come possibile cammino della storia dell'umanità di
oggi. Il testamento di Gesù che noi concorriamo ad attuare con tutta la Chiesa, ne era la
garanzia; il nostro specifico carisma un pegno; ma, ora che ce l'ha confermato il Vicario di
Cristo in terra, è un'altra cosa.

         "Voi guardate avanti - ha detto il Papa - "(...) Volete scrutare il cammino che bisogna
percorrere per raggiungere un 'mondo unito' nella consapevolezza che tale 'Ideale' va
facendosi 'storia'. Davvero questa sembra la prospettiva che emerge dai molteplici segni del
nostro tempo: la prospettiva di un mondo unito. E' la grande attesa degli uomini di oggi, la
speranza e, al tempo stesso, la grande sfida del futuro. Ci accorgiamo che verso l'unità si sta
procedendo sotto la spinta di una eccezionale accelerazione". Così il Papa. Siamo, dunque,
felici: amiamo, lavoriamo, preghiamo, soffriamo per un mondo unito. Esso è la proiezione
umana del nostro ideale "ut omnes unum sint".

         Ma oggi è anche Giovedì Santo, un giorno speciale in cui noi spesso, negli anni
passati, ci siamo sentiti avvolti e intimamente impregnati in un'atmosfera speciale,
dolcissima: particolare presenza certo dello Spirito Santo.

         E non può essere che così perché oggi ricordiamo e riviviamo, condensati, parecchi
misteri della nostra fede e del nostro ideale.
         E' questo, infatti, il giorno dell'amore perché tutto amore è ciò di cui questo giorno
fa memoria.

         Amore il sacerdozio ministeriale, istituito nel lontano Giovedì Santo, di cui il S.
Padre, nella sua ultima lettera ai sacerdoti per questo Giovedì Santo, ha detto che non è
un'istituzione che esiste "accanto" al laicato, oppure "sopra" di esso, ma è "per" i laici e
proprio per questo possiede un carattere "ministeriale" e cioè "di servizio" e quindi d'amore
concreto.

         Amore l'Eucaristia nella quale Gesù, ci ha dato tutto se stesso.

         Amore l'unità, effetto dell'amore, che Egli ha invocato come oggi dal Padre.

         Amore il suo Comandamento Nuovo che ci ha lasciato.

         Ed è sul Comandamento Nuovo di Gesù che vorrei soffermarmi.

         Noi l'abbiamo proposto al Genfest come grande chance per arrivare ad un mondo
unito.

         E tutti, tanto o poco, si sforzeranno ora di attuarlo.

         E noi, che siamo nel cuore dell'Opera, i più interni ad essa, che facciamo?

         La mia proposta è questa.

         Inizia oggi il triduo pasquale. Sono tre giorni solenni. Ebbene, in uno di questi
dobbiamo trovare un momento solenne in cui ci ripeteremo fra noi nei nostri Centri, nei
nostri focolari, nei nuclei, nelle unità, nei grappoli, fra chi è possibile, dovunque, quel patto
che fecero le prime focolarine quando dissero: "Io sono pronto a morire per te, io per te, io
per te ...".

         Lo sappiamo. Anche questa piccola, grande cosa, non è sempre del tutto facile: pure
nelle strutture fondamentali della nostra Opera può essersi infiltrato il rispetto umano. E'
più facile per alcuni, forse, prendere queste decisioni direttamente con Dio. Ma la nostra è
una spiritualità collettiva e non possiamo tradirla. Il patto d'allora è stato la pietra miliare
del Movimento. Lì Gesù si è posto in mezzo a noi. Troviamo dunque il modo di rinnovarlo.

         E poi sforziamoci di vivere conformemente.

         S'alzerà il tono soprannaturale in tutta l'Opera e diverremo meglio - come dobbiamo
essere - i primi operai di un mondo unito.

         Il Risorto sarà più splendente fra noi, col suo Spirito, come richiede la festa di
Pasqua, che ci accingiamo a festeggiare.

         Senza dimenticare che domani, Venerdì Santo, ricorda Gesù abbandonato, la chiave
divina che rende veramente possibile essere pronti a morire l'uno per l'altro.
A tutte e a tutti, buona e ottima Pasqua!
Il Risorto sia con noi.$doc1710$, 'drive_import', '01710-WEB-1990-03-22-rinnovare-il-patto-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1710)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1711, 'ITA', $doc1711$Rocca di Papa, 12 aprile 1990

Per essere una "rata"

Carissimi,

         è ancora nell'aria l'eco del recente viaggio del S.Padre in Cecoslovacchia, che non è
stato solo un trionfo del Papa o della sola Chiesa cattolica, ma un trionfo della fede e, quindi,
di tutti coloro che hanno creduto e credono in Dio in un ambiente in cui, ancor ieri,
dominava l'ateismo più nero e un duro sistema totalitario.

         In quest'occasione, come era giusto, sono stati ricordati i possibili fautori del
miracoloso cambiamento: Dio, primo autore, Signore della storia, che non poteva vedere
calpestati in eterno il suo nome ed i suoi figli; la Chiesa imprigionata, mutilata, martoriata,
quasi annientata e messa sotto silenzio coi suoi martiri: vescovi, sacerdoti, religiosi,
religiose, laici... Ed è stata riconosciuta più d'una volta anche (e questo particolare ci ha dato
speciale gioia) l'azione dei movimenti e dei carismi che - come il Papa ha detto - sono spesso
arrivati là dove la Chiesa ufficiale non avrebbe potuto.

         Questo viaggio del S.Padre, questo grande successo mi ha fatto ricordare un episodio
della nostra vita, piccolo forse, proporzionato alla nostra Opera, ma che - mi sembra - faccia
partecipare intimamente anche tutti noi a questo momento storico e glorioso. Lo narro per
coloro che non lo sapessero.

         Era il 1960 e due di noi hanno avuto l'occasione di portarsi in uno dei Paesi dell'Est
più tribolati. Le ferite della violenta recente repressione erano ancora presenti sui muri dei
palazzi, degli edifici. Regnava un clima di sospetto che metteva paura.

         Soprattutto siamo stati schiacciati dall'impressione di assoluta impossibilità, da
parte di chiunque, di portare un qualche rimedio alla situazione. E si soffriva come se il
problema ci riguardasse personalmente.

         Tornando però a Roma, al Centro, e parlando ai nostri della terribile esperienza,
abbiamo ricevuto un lieve conforto e visto un filo di speranza in un'idea che si è affacciata
alla nostra mente. Abbiamo detto: noi vorremmo concorrere a risolvere un tale problema.
Ma, per ottenere una grazia del genere dal cielo occorrerebbe un prezzo altissimo. E noi non
l'abbiamo. Una cosa tuttavia potremmo fare: pagarlo un po' alla volta. Se qui in terra gli
uomini ti vendono una casa, un mobilio, una macchina, a rate, vuoi che Dio sia meno buono
degli uomini?

         E abbiamo pensato di offrire le nostre vite (quando Dio le avesse colte) per questo
scopo.

         E in seguito, quando qualcuno di noi "partiva", tutto offrendo, in genere, per la
Chiesa e per l'Opera, si diceva: "E' una rata".
         Poi, forse non abbiamo avuto così presente questa particolarissima intenzione, ma
Dio certamente non l'ha dimenticata.

         Così - lo speriamo -, ora il Cielo ha contato, forse, fra quelli che hanno un po'
"pagato" per il trionfo della fede e della libertà, in parecchi Paesi europei e non, anche il
migliaio circa dei nostri interni partiti dal '60 ad oggi. Ed è anche ciò che ci fa godere di
quanto è avvenuto in questi giorni.

         Ma il pensiero del nostro Collegamento non ha lo scopo solo di costatare o ricordare,
ma quello di proporre qualche idea, di dare qualche consiglio perché il cammino del santo
viaggio per tutti noi prosegua e si concluda bene un giorno.

         E tutti noi vogliamo certamente dare come significato a quel momento le intenzioni
dell'Opera, che è Opera di Dio e sono, quindi, intenzioni di Dio.

         Ma come prepararci?

         In quest'ultimo periodo al Centro ed in molte zone abbiamo seguito da vicino
persone nostre chiamate a quel passo.

         Se è stata spesso un'esperienza formidabile in cui abbiamo visto piovere dal Cielo
grazie speciali e la morte coincidere con la Vita, abbiamo anche costatato sofferenze, a volte
prolungate e dure. Per cui può essere sorto nel nostro cuore questo interrogativo: "Mio Dio,
e io ce la farò? So che tu mandi il tuo aiuto in ogni prova, ma riuscirò ad affrontare quella
che è la prova per eccellenza, da degno figlio tuo, da autentico membro della nostra
meravigliosa Opera?"

         Sì, perché la croce, il Gesù abbandonato che dobbiamo abbracciare in quei momenti,
è tutto un'altra cosa dagli altri. Il nostro santo viaggio subisce lì, infatti, una variazione. Se
prima era come si viaggiasse in treno, per così dire, poi occorre prendere una grimagliera
perché la salita si fa ripida ogni giorno, ogni ora di più, fino alla méta.

         Tuttavia, se può passare per il nostro animo il dubbio di non farcela, almeno
perfettamente, mi sembra che lo Spirito con la nostra spiritualità, ci dia pure la soluzione.

         Si osserva, ad esempio, che quando si ha un impegno futuro, si è perfettamente
tranquilli, solo se si è ben preparati. Ciò farebbe capire che anche il tremendo impegno della
partenza finale da questa vita, perderebbe la sua gravità se fossimo ad essa preparati.

         Come?

         Osservo che quando stiamo vicino a chi sta morendo, l'amore ci spinge sempre a
dare questo consiglio: vivi il momento presente.

         Così facendo ogni cosa sembra possibile e sopportabile, come diceva santa Teresa
del Bambin Gesù, e ci si prepara nel miglior modo alla nuova volontà di Dio.
         E allora, perché non facciamo così sin d'ora? Non sarà, forse, questa la miglior
preparazione che può annullare in noi ogni timore? Credo proprio di sì.

         Cominciamo, dunque, da adesso e non smettiamo mai di vivere il presente finché ci
si imbatterà in quel momento da cui dipende l'eternità.

         Con esso, col presente - a voi scoprirlo -, si vivono uno dopo l'altro tutti i punti della
nostra spiritualità e tutti gli aspetti della nostra vita.

         Così, abituandoci a vivere il presente, potremo, con la grazia di Dio, uguagliare i
nostri fratelli partiti ed essere d'una qualche utilità ai piani di Dio sull'umanità.$doc1711$, 'drive_import', '01711-WEB-1990-04-12-per-essere-una-rata-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1711)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1712, 'ITA', $doc1712$Rocca di Papa, 26 aprile 1990

Essere per tutti causa di letizia

Carissime,

         quella che noi chiamiamo: storia dell'Ideale (ed è l'inizio dell'avventura divina del
nostro Movimento), la nostra piccola-grande storia, è ambientata (è noto a tutti) in una
circostanza particolare: la guerra; la guerra con le sue bombe, le sue rovine e i suoi morti.

         Essa, piccolo capolavoro della mano di Dio, da cui non possiamo prescindere per far
comprendere bene il nostro Ideale, è come un medaglione luminoso, come un prezioso
cammeo puntato però su un drappo rosso, rosso di sangue.

         E, anche se tutta folgorante di luce, di quella luce soprannaturale che - abbiamo
capito - è da attribuirsi allo Spirito Santo, è legata a questa dolorosa, drammatica
circostanza.

         Perché? Perché così Dio l'ha pensata, l'ha voluta, affinché si comprendessero meglio
le verità che voleva inculcare a noi e a molti; perché ne sgorgasse la vita che doveva
dilagare.

         Penso che per noi non sarà possibile vivere con perfezione e intensità il nostro
Ideale, se non tenendo sempre presente quel clima, quell'ambiente, quelle circostanze.

         E il Signore ancora oggi, dopo più di quarant'anni, non ci fa mancare le occasioni: le
frequenti "partite" dei nostri (ultima quella del focolarino Miguel Angel) sono un continuo
richiamo al "tutto passa", al "tutto crolla", sfondo necessario per capire ciò che veramente
vale.

         Fa impressione quello che ci mandano a dire con insistenza questi nostri fratelli "in
partenza": di fronte alla prossima perdita di tutte le cose terrene, vogliono che sappiamo
che solo l'Ideale vale. Così Hermann, il volontario della Germania, così don Toni Weber.
Nelle situazioni in cui si sono trovati, hanno visto più lontano come, quand'è notte, si
possono vedere le stelle. Colgono, per una luce particolare, l'assoluto valore di Dio e lo
dichiarano amore.

         Anche noi, mentre stiamo quaggiù, se vogliamo fare della vita un vero santo viaggio,
dobbiamo avere, come hanno loro, le idee chiare: considerare ogni cosa che non sia Dio,
transitoria e passeggera.

         Tuttavia la nostra fede e il nostro Ideale non si fermano al traguardo della morte.
         Il grande annuncio del cristianesimo è: "Cristo è risorto". E il nostro stesso Ideale ci
chiama sempre ad andare "al di là della piaga" per vivere il Risorto.

         Noi siamo chiamati, dunque, a pensare soprattutto al "dopo".
         Ed è su questo "dopo", il misterioso, ma affascinante "dopo", che vorrei soffermarmi
questa volta.

         Tocca a me abbastanza spesso e, forse anche a voi, di chiedermi dove saranno i
nostri? Dove sarà Renata, che farà, che penserà...? Che faranno Piero, Vita, Marilen, Dolfi? Mi
passano questi pensieri perché, qui in terra, fino a poco fa, sapevo dove erano, quello che
facevano. Ora mi è tutto ignoto.

         Certamente la fede dà le risposte a questi nostri interrogativi e noi le conosciamo.
         Una parola di Gesù, però, m'ha dato, in questi ultimi giorni, luce e conforto, grande
conforto.
         L'ha detta Gesù al buon ladrone: "Oggi sarai con me in Paradiso."(cf Lc 23,43)
         Oggi: dunque subito, subito dopo la morte.
         E, pensando che tutti i "nostri", a nostro giudizio, potevano ritenersi almeno come il
buon ladrone, ho detto: la loro morte allora non è stata che un passaggio; anzi, per essi la
morte è stata una vera pasqua: sono andati dalla vita alla Vita. E si capisce Renata quando
continuamente ripeteva: "La morte è vita": perché, per l'anima almeno, la morte non è:
quell'"oggi" fa pensare così. Alle tre e mezza di notte Renata è partita, alle tre e mezza è
arrivata dove ha conosciuto il Padre e Gesù, dove l'amore è perenne, dove il gaudio è
costante, in attesa certo della risurrezione della carne, perché anche Gesù è risorto.
         E si comprendono le parole di Gesù: "Chiunque vive e crede in me, non morrà in
eterno" (Gv 11,26). E si capisce perché il clima dei nostri funerali è quello di una grande
festa, è come un giorno di nozze.

         Cosa dobbiamo ricavare allora da questi pensieri?
         Cerchiamo di vivere in maniera che anche a noi sia detto quell'"oggi": "Oggi sarai
con me in Paradiso".
         Ma lo sappiamo: sarà dato a chi ha; a chi ha sarà dato.
         Se qui in terra saremo, per amore di Dio, paradiso per i nostri fratelli; se saremo
gioia, conforto, consolazione, aiuto, per i singoli, per la nostra Opera, per la Chiesa, per il
mondo, il Signore ci darà il Paradiso.

         Ed ecco perciò, il motto per camminare solleciti nei prossimi quindici giorni di
maggio, mese di Maria: essere, come Lei, causa di letizia per tutti nell'attimo presente;
essere per tutti: Paradiso.$doc1712$, 'drive_import', '01712-WEB-1990-04-26-essere-per-tutti-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1712)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1713, 'ITA', $doc1713$Rocca di Papa, 10 maggio 1990

Vivere il "già"

Carissimi,

         per proseguire tutti insieme con sempre rinnovato slancio il Santo Viaggio, non
vorrei soffermarmi questa volta - come ho fatto in alcuni collegamenti passati - sul "dopo",
sull'"Al di là", su quello che avverrà in futuro nel Regno dei Cieli, ma sull'"adesso", sulla vita
divina che conduciamo qui in terra.

         Si può parlare, infatti, sin d'ora, per il mistero della grazia, di Regno di Dio già
realizzato, anche se non con quella pienezza che avverrà nell'altra Vita. E' noto il "già e non
ancora": il già attuato, ma non ancora attuato.

         Questo collegamento vuole, dunque, approfondire il "già".

         Il Regno, il Paradiso che già può esistere sulla terra, ogni cristiano, se fedele, è in
grado sperimentarlo.

         Noi, con la nostra spiritualità, con il particolare carisma, che lo Spirito ci ha donato,
abbiamo un motivo in più, una grazia in più, per farne ogni giorno, ogni momento
l'esperienza.

         Essa consiste in quei frutti dello Spirito che abbondano nei nostri cuori, anche
singolarmente, dopo esser andati "al di là di ogni piaga" - come noi diciamo - o dopo aver
amato; e sono - come dice Paolo - gioia, pace, mitezza, benevolenza, pazienza, dominio di sé,
fedeltà.

         Essa, quest'esperienza, consiste pure in quegli stessi frutti ed effetti che si
sperimentano collettivamente, quando Gesù è in mezzo a due o più, e che si avvertono con
maggior pienezza se siamo in molti uniti nel suo nome.

         E' questo il caso delle nostre grandi manifestazioni, come le Mariapoli, i Genfest, ecc.,
o delle nostre cittadelle come la Luminosa, vicina a New York, da dove vi parlo, che in questi
giorni si è popolata di circa 250 focolarini e focolarine vergini e coniugati.

         Qui a tutti, provenienti dal Nord e Centro America, ho portato due grossi doni:
l'approvazione dei nostri Statuti da parte della Santa Sede e una lettera autografa del Papa
che assicura, fra il resto, le sue preghiere per ciascuno di noi e dice la sua gioia di incontrarci
dappertutto nel mondo.

         Doni che, assieme agli altri spirituali, immancabili dove c'è Lui fra noi, hanno
accresciuto l'intensità dell'atmosfera soprannaturale, hanno fatto avvertire, quasi
sensibilmente, la presenza del Regno di Dio, che tutti ci ha avvolto e trasformato.
L'esperienza, appunto, del "già" così forte, che non sono mancate espressioni come queste:
"se il Paradiso è così, ci basta!", "questa è l'eternità."

         Sono state ore meravigliose anche perché trascorse in questa cittadella, che come un
piccolo paradiso terrestre con boschi luminosi, un laghetto con pesci e tartarughe, uccelletti
di più di 80 specie, scoiattoli, marmotte, e persino cervi, volpi e castori; e con le sue viuzze,
intitolate ai più bei nomi ispirati allo Spirito Santo, che fiancheggiano case e casette
incantevoli, ha fatto da degna cornice.

         E il "già", il "già" del Regno irradiava talmente da tutti, questi nostri focolarini e
focolarine, che si poteva ammirare in essi tale dignità, bellezza, libertà, armonia da
richiamare le parole: "La gloria di Dio è l'uomo vivente".

         In questo clima, poi, s'è costatato nuovamente come il Cielo è fatto di Cieli (Regno
dei Cieli); come in Dio, che è Amore, tutto è vita, nulla è statico e si passa di realtà in realtà.

         In 3 giorni, ma in poche ore d'incontri, abbiamo assistito al prodigioso sviluppo della
città col progetto e la posa della prima pietra (la medaglietta) per altre sette casette per i
nostri e le nostre gen, i volontari, i sacerdoti e religiosi e le religiose, le focolarine presenti e
future; al progetto per una Chiesa intitolata alla Madonna della Luce; alla nascita di due
Centri Mariapoli per il Canada e il Venezuela; alla fondazione della cittadella o Loppiano per
il Messico, che prenderà il nome di "Il diamante".

         Abbiamo analizzato e visto come portare, lì dove siamo, il nostro contributo
all'attenuarsi almeno del consumismo e di altri mali in queste terre nord americane così
splendide, ma minacciate; abbiamo saputo della spontanea offerta di molte "rate" per il
crollo di questi muri tipici dell'occidente; abbiamo colto i vari segni d'un mondo unito nelle
nazioni delle quattro zone presenti.

         Da parte mia poi ho costatato con ammirazione e gratitudine quanto amore sia stato
seminato dovunque soltanto dagli innumerevoli doni arrivati di cui ringrazio di cuore tutti i
nostri interni.

         Insomma abbiamo vissuto il "già" con pienezza in un tripudio di gioia, nella
contemplazione dei disegni di Dio sull'Opera che, se siamo uniti - lo abbiamo visto - si vanno
precipitosamente realizzando.

         E allora non resta che il desiderio di incoraggiarci a proseguire tutti con raddoppiata
lena, ripetendo a noi sparsi nel mondo: non perdiamo tempo, viviamo il nostro Ideale con
intensità. Se apriremo al mondo l'esperienza del Paradiso che già si può costruire quaggiù,
molti crederanno al Paradiso lassù. E il riflesso sull'umanità sarà incalcolabile.

         Come proposito per i prossimi quindici giorni: vivere sempre nel soprannaturale, o,
come diciamo noi "nella nuvoletta". E' da essa che potrà piovere sul mondo tanta acqua
benefica.$doc1713$, 'drive_import', '01713-WEB-1990-05-10-vivere-il-gi-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1713)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1714, 'ITA', $doc1714$Mariapoli Luminosa (USA), 24 maggio 1990

“Lo vuoi Tu, lo voglio anch'io"

Carissime,

         siamo dunque collegate in tutto il mondo. Merito senz'altro delle moderne
tecnologie, ma anche, io penso, suggerimento dello Spirito Santo che ce l'ha fatto scoprire
perché, a mio avviso, Egli, il cui compito è quello di unire, deve essere il protettore di ogni
mezzo di comunicazione.

         Come incominciamo questa volta?

         Sento il desiderio di dare il via a questo Collegamento con una breve preghiera di
lode alla S.S.Trinità che salga da tutto il pianeta. Mi sembrerebbe, altrimenti, di usurpare il
posto dell'Unico che può tenere lo sguardo sul mondo intero. Ricordate Gesù Bambino,
dipinto o scolpito spesso vicino a sua Madre, col mondo in mano?

         Perciò ripetete con me: Sia Gloria al Padre, al Figlio e allo Spirito Santo, come era in
principio ora e sempre nei secoli dei secoli.

         Abbiamo appena trascorso la festa della Pentecoste e, con grande gioia, non senza
graditissima sorpresa, ho saputo da molti di voi che è stata diversa dagli altri anni.

         Dopo l'anno dedicato allo Spirito Santo, la Terza Divina Persona si è fatta strada
nelle persone del nostro Movimento, che hanno trovato un nuovo, inaspettato, rapporto con
Lui, profondo, ineffabile ed inesprimibile, come dicono. Hanno riscoperto la sua presenza
nella loro vita ideale quotidiana; l'hanno individuata costante nella loro piccola storia;
l'hanno costatata travolgente nelle manifestazioni dell'Opera, e parlano di Lui con felicità,
con entusiasmo, come di un grande amico che, ormai, non cesserà di essere tale.

         Un dono enorme, dunque, impagabile, che Egli ha fatto al nostro Movimento, dono
che avrà larghe conseguenze: non si scherza col fuoco! Dono che dobbiamo coltivare ed
intensificare. Il Santo Viaggio, che percorriamo, è presieduto da Lui, perché è il Santificatore.
L'anno prossimo sarà dedicato ancora allo Spirito Santo.

         Ma, che fare per essere certi di accrescere ancora il nostro rapporto con Lui?

         Lo si sa: occorre amarlo. Ma amare Dio significa obbedirlo ("Non chi dice: Signore,
Signore..." - Mt 7,21) ed obbedirlo non genericamente, ma in ciò che Lui vuole proprio da
noi, in ciò che di specifico, di tipico ha chiesto a noi.

         E lo sappiamo: Egli vuole che noi camminiamo per una via collettiva.
         La via collettiva, che siamo chiamati a percorrere, ha delle particolarità che la
distingue dalle vie più specificatamente individuali. Anche se, nel cristianesimo, tutto sfocia
un po' nel comunitario, nel collettivo. Ma le differenze rimangono.

         Per noi, ad esempio, tutto ha significato e valore, nell'apostolato, nello studio, nel
lavoro, come anche nella preghiera e nella tensione alla santità, se abbiamo prima con i
fratelli Gesù in mezzo, che è la norma delle norme; se coltiviamo continuamente questa
presenza con la più completa comunione spirituale, oltre che materiale fra di noi; se ci
nutriamo dell'Eucaristia, ecc.; se camminiamo nel Santo Viaggio insieme. Ma ciò dà origine a
differenziazioni con le vie spirituali più individuali.

         In queste ultime, ad esempio, il cristiano per amare Dio occorre segua spesso una
certa graduatoria, salga vari gradini, o più scalette, si incammini verso la montagna della
perfezione.

         La via collettiva, invece, pone il cristiano subito in vetta, in alto. E' la presenza di
Gesù in mezzo - penso - che lo esiga e lo imponga: Egli è il perfetto.

         Se si deve crescere - e lo si deve - è in intensità e cioè nel fare atti d'amore così
perfetti sempre più ravvicinati, ricominciando sempre. Si tratta dunque di quantità più che
di qualità.

         Per quanto riguarda, ad esempio, la volontà di Dio, quando lo Spirito ce ne ha dato
una nuova comprensione perché la vivessimo, ci ha subito suggerito il modo perfetto di
attuarla: volere la volontà di Dio, dir propria la volontà di Dio.

         Quindi non ci ha fatto passare attraverso vari gradi: prima rassegnarci alla volontà
di Dio, poi accettare la volontà di Dio, anche arrendersi alla volontà di Dio, e finalmente
volere la volontà di Dio. Ma ci ha posto subito nell'ultimo gradino.

         Naturalmente sappiamo noi se abbiamo corrisposto, e quante volte abbiamo
ricominciato.

         Comunque, quello è stato il suggerimento dello Spirito Santo a noi.

         Noi non dobbiamo salire tanto la montagna della perfezione, quanto piuttosto,
stando già in alto, camminare lungo lo spartiacque delle montagne fino al sole che è Dio, il
Cielo. Questa è la nostra linea.

         Abbiamo vissuto gli ultimi venti giorni il "già", già paradiso, anche se non ancora.

         E per qualcuno fra noi questo "già" ha fatto ricordare anche G.A.= Gesù
abbandonato, per qualche situazione dolorosa, per prove varie, per qualche malattia
subentrata... Per cui, solo volendo con tutto il cuore questi volti di Gesù abbandonato,
abbiamo potuto rimanere nel "già".
         Ma prove piccole o grandi non sono certo mancate a nessuno.

         Per essere allora in linea con la nostra spiritualità, abituiamoci a ripetere
sinceramente: "Lo vuoi Tu, lo voglio anch'io. La mia volontà è la tua."

         Ci sentiremo particolarmente tonificati.

         Facciamo così nei prossimi quindici giorni.

         E' un modo di amare lo Spirito Santo perché, appunto, l'obbediamo camminando
secondo la via che ha disegnato per noi. E crescerà il nostro meraviglioso rapporto con Lui.
Senza dimenticare - lo ripeto ancora - che prima di tutto dobbiamo costruire e ricostruire il
nostro rapporto fra noi perché Gesù sia fra noi.

         Sono con voi tutti in tutto il mondo: cerchiamo di essere una rete, una catena di veri
cristiani che abbraccia questo mondo, perché vogliono aver scritto in fronte - come ha detto
san Francesco di Sales: "Io sono la volontà di Dio su di me".$doc1714$, 'drive_import', '01714-WEB-1990-05-24-lo-vuoi-tu-lo-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1714)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1715, 'ITA', $doc1715$Rocca di Papa, 14 giugno 1990
"L'arte del levare"

Carissimi,

         ed eccoci al secondo collegamento mondiale: ringraziamo Dio anche oggi di poterci
sentire uniti in tutto il mondo. Che Gesù sia fra noi!

         Fra due giorni è la festa di santa Chiara e, come è consuetudine ormai ogni anno, ci
raccoglieremo, dovunque, in convegni familiari, festosi e gioiosi. Così sarà anche per molti
qui in Svizzera.

         Quest'anno però desidereremmo dare a questa ricorrenza un significato più preciso.
Senza trascurare gli auguri, che sin d'ora vogliamo porgere a tutte le varie Chiare e Chiaretti
del nostro Movimento, vorremmo, d'ora in poi, che l'11 agosto fosse una festa dell'Opera,
nella quale ringraziare Dio per l'anno trascorso; una festa in cui - pur tra canti, danze, mimi,
spettacoli, dolci, ecc. - si ricordino le grandi grazie che il Signore ci ha elargito nei mesi
precedenti. E ciò anche per incoraggiarci a sempre migliorare. Naturalmente, tutto
all'ombra e sotto la protezione della grande Chiara d'Assisi che è stata, sin dai primi tempi,
tanto vicina a noi. Ogni anno, infatti, ricordiamo un aspetto della sua vita che ci aiuti a
comprendere meglio la nostra spiritualità.

         E così vogliamo fare quest'anno.

         Chiara si è fatta santa per molti motivi. E non certo ultimo, per le durissime
penitenze. Era figlia del suo tempo, quando si pensava di dover andare a Dio attraverso le
penitenze, anche se poi, con san Francesco, modificò il suo pensiero e il suo atteggiamento,
sforzandosi di andare a Dio attraverso l'imitazione di Cristo.

         Comunque di penitenze ne fece e moltissime, fino ad ammalarsi.

         Cosa dice a noi questo particolare dell'esistenza terrena di santa Chiara d'Assisi?
         Ci vogliono proprio le penitenze per raggiungere la santità?
         Che ne pensa Gesù, che ne pensa la Chiesa?
         "Cristo, che sempre nella sua vita fece ciò che insegnò, prima di iniziare il suo
ministero, passò quaranta giorni e quaranta notti nella preghiera e nel digiuno..." (). Dunque
non abolì il digiuno, ad es. Tuttavia egli ha insistito maggiormente e soprattutto sulla
rinuncia a sé stessi e sul portare la propria croce. ()

         La Chiesa, dal canto suo, invita tutti i cristiani indistintamente a fare anche qualche
atto volontario di penitenza. ()

         Noi - lo sappiamo - seguiamo la via dell'amore, dell'amore a Dio nell'esser tutti
protesi verso la sua volontà anche dolorosa, e verso i fratelli. In particolare: andiamo a Dio
attraverso il fratello. Ed è qui che troviamo la più ampia possibilità di rinnegare noi stessi e
portare la croce: pensando, curandoci degli altri, non pensiamo a noi stessi, rinunciamo a
noi, siamo staccati da noi stessi. E ciò, e in modo particolare, non solo quando il fratello è
sensibile e risponde al nostro amore, ma quando non lo è.

         Se il fratello, infatti, è molto spesso causa della nostra gioia, di quella gioia
soprannaturale che conosciamo, amando, egli è anche a volte la nostra croce, il nostro Gesù
abbandonato che dobbiamo abbracciare con tutto il cuore.

         E questa è vera penitenza.

         Tuttavia - l'ho detto ancora, ma lo ripeto qui data l'importanza della cosa - può
accadere che, per rinnegarci e renderci totalmente morti a noi stessi, non basti l'amare,
facendo nostra la volontà di Dio anche penosa di ogni giorno, e l'amare i fratelli, il patire per
i fratelli. Rimane qualcosa: qualche attaccamento: ad una propria idea, ad esempio, ad un
proprio gusto, ad una soddisfazione, a qualche parola o pensiero inutile o vano, ad un libro,
a soldi, ad un programma televisivo non necessario, a persone, ecc.

         E allora occorre perdere, tagliare. E anche questa è rinuncia; anche questa è croce.
Dice san Giovanni della Croce che colui che non spegne gli attaccamenti è come chi vuol
camminare verso Dio, e cioè fare il santo viaggio, tirando un carro su per una salita. () Se va,
cammina pianissimo, o non ce la fa.

         Sì, perché santificarsi è un po' come scolpire. Diceva Michelangelo che la scultura è
"l'arte del levare", del togliere scheggia per scheggia, pezzo per pezzo di marmo, di creta od
altro per far uscire un'opera d'arte. Una volta egli, vedendo un masso, disse: "In quel blocco
c'è racchiuso un angelo; voglio tirarlo fuori" (). E lo scolpì, togliendo.

         Anche in noi è nascosto Gesù che dobbiamo far nascere e rinascere. E allora occorre
certamente togliere dal rozzo masso del nostro io quanto va eliminato: con l'amare se ne va
il 99%, e col perdere, col togliere, col levare, se ne va il resto.

         Proviamo e riproviamo a vivere così in questo periodo.
         Carissime, non si può raggiungere la santità grosso modo. E' questione di finezze.

         Pratichiamo allora "l'arte del levare", con l'amare, certo e, in particolare in questo
periodo, col perdere.$doc1715$, 'drive_import', '01715-WEB-1990-06-14-larte-del-levare-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1715)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1716, 'ITA', $doc1716$Mollens, 9 agosto 1990

Patto e "time-out"

Carissimi,

         L'11 agosto a Montreux abbiamo contemplato un po', come penso ormai tutti
sappiate, il "bambino evangelico" che vive nei membri del nostro Movimento che hanno
compreso e mettono in pratica la nostra spiritualità. Ed abbiamo visto come la prima
caratteristica di questo nuovo tipo - per così dire - di cristiano del duemila, fiorito dal
carisma dell'unità, sia una fede adamantina nell'amore del Padre. Come ogni bambino di
questa terra ha fiducia nel proprio padre, crede in lui, a lui si abbandona totalmente, lascia a
lui ogni preoccupazione, con lui è sicuro in ogni circostanza anche difficile, anche dolorosa,
anche impossibile, così fa e deve fare il bambino del Vangelo nei confronti del Padre celeste.

         Un atteggiamento, il suo, importantissimo sempre, perché siamo spesso sovrastati
da circostanze, da avvenimenti, da prove che non possiamo superare con le sole nostre
forze e necessitano quindi di interventi superiori.

         Un bisogno poi tutto particolare di una grande fede nell'amore del Padre, nella sua
Provvidenza, lo avvertiamo in questi giorni.

         Sappiamo come tutto il mondo, nelle ultime settimane, si trova in una sospensione
angosciosa per la crisi del Golfo Persico, che può portare con sé conseguenze catastrofiche
per vasta parte dell'umanità.

         Ed anche noi tutti certamente non siamo meno sensibili e meno preoccupati di tutti
gli altri.

         Anzi, lo siamo - vorrei dire - per un doppio motivo: per quello che può accadere e
perché tale circostanza viene a compromettere gravemente il nostro programma: lavorare
per un mondo unito, ideale questo, confermato splendidamente, all'ultimo Genfest, dal
S.Padre.

         Siamo stati e siamo preoccupati e abbiamo pensato (sono arrivate al Centro anche
sollecitazioni al riguardo, specie da giovani) che cosa potevamo fare. La prima risposta, che
è fiorita in cuore, è stata: pregare, unirsi tutti a pregare per scongiurare il flagello. E chi più,
chi meno, ha senz'altro cominciato a fare così.
         Nel frattempo inoltre, pensando anche a tutti voi, sparsi nel mondo intero, l'attuale
grossa prova del Medio Oriente ci ha portati a considerare tutti gli altri punti caldi della
terra e, anziché offuscarli, li ha messi in rilievo come tante ferite al nostro meraviglioso
progetto.

         23 sono i luoghi dove oggi si combatte nel mondo: dal Libano all'Armenia,
dall'Afganistan alla Somalia, dallo Sri Lanka alla Cambogia, al Mozambico, all'Etiopia, alla
Colombia, al Perù, al Salvador e così via.

         Ed è nato nel cuore, anche per tutti questi grossissimi problemi, il desiderio
bruciante di portare anche noi un contributo alla loro soluzione.

         Come?

         Senz'altro, se siamo nelle condizioni e possibilità di farlo, agendo sul piano
internazionale e nazionale; poi incrementando tutte le iniziative possibili nate da "Umanità
Nuova" e "Gioventù Nuova".

         Ma, anche qui, data l'immane impresa, soprattutto pregando.

         Pregare perché il Padre celeste intervenga sul cuore degli uomini e si spengano le
guerre.

         Pregare.

         Ma occorre pregare in modo da ottenere.

         E come?

         E' chiaro che chi è più buono, più santo, più perfetto, è più gradito a Dio e perciò
ottiene di più.

         Ma chi è santo? Chi è perfetto?

         San Giovanni, nella sua prima lettera, ha questa bellissima e incoraggiante
espressione: "... Se ci amiamo gli uni gli altri, Dio rimane in noi e il suo amore in noi è
perfetto" (lGv 4,12). "Il suo amore in noi è perfetto". Ma, se il suo amore in noi è perfetto, e
finché il suo amore in noi è perfetto, siamo perfetti. La perfezione dell'amore si ha, dunque,
nell'attuare l'amore reciproco.

         In questi giorni, dovendo rivedere a fondo il regolamento dei focolarini, perché
l'Assemblea generale della nostra Opera d'ottobre lo possa approvare, abbiamo introdotto
una norma che è basilare ed essenziale per loro: il dovere, prima di entrare in focolare, di
formulare con gli altri focolarini un patto, poi ogni anno rinnovato, d'essere pronti a morire
gli uni per gli altri, come esige il comandamento di Gesù.

         Ma questa decisione, questo patto non è certamente monopolio dei soli focolarini,
che vivono in focolare. E' legge per tutti i membri della nostra Opera.

         Essa, attuata, fa sì che l'amore in noi sia perfetto e che noi siamo perfetti nell'amore,
e così graditi a Dio, e quindi nelle condizioni di ottenere le grazie che desideriamo, anche
quelle necessarie per spostare le montagne.

         Penso che sarà necessario in questi giorni, se vogliamo lavorare efficacemente al
mondo unito, rinnovare fra noi e con quanti più incontriamo, che conoscono il nostro
Movimento, questa disposizione della nostra anima. Dobbiamo naturalmente creare prima
le premesse necessarie, suscitare l'atmosfera adatta per poi, con coraggio, poter dire
all'altro: "Io - con la grazia di Dio - voglio essere pronto a morire per te" e potersi sentir
ripetere: "E io per te".

         Poi dobbiamo agire di conseguenza, attizzando il fuoco dell'amore nei confronti di
ogni prossimo. In questo modo viviamo anche la Parola di Vita del mese di settembre che
dice: "Non abbiate alcun debito con nessuno se non quello dell'amore vicendevole; perché
chi ama il suo simile ha adempiuto la legge" (Rm 13,8). Su questa base possiamo pregare
con fiducia di ottenere.

         Un modo, che suggerisco, per il prossimo mese, è quello che già attuano i nostri gen
2 e, da anni, i gen 3: a mezzogiorno italiano in punto, tutti nel mondo dobbiamo sospendere
ogni attività per concentrarci in un "consenserint" con tutti gli altri. In esso chiederemo, al
Padre, in nome di Gesù e per intercessione di Maria che si risolva la crisi del Golfo Persico e
cessino le guerre su tutta la terra.

         "Patto e time-out", dunque: questo l'impegno del prossimo mese.$doc1716$, 'drive_import', '01716-WEB-1990-08-09-patto-e-time-out-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1716)
on conflict (document_id, language) do nothing;

insert into public.document_original_texts (document_id, language, body, source, source_file, reviewed)
select 1717, 'ITA', $doc1717$Mollens, 13 settembre 1990
L'unità fra noi a tutti i costi

Carissime,

         i giorni dell'Assemblea '90, svoltisi al Centro dell'Opera di Rocca di Papa alla fine di
settembre, sono stati, come avrete saputo, meravigliosi per una particolarissima presenza di
Gesù fra tutti i rappresentanti delle varie espressioni dell'Opera e di tutte le zone del
mondo.

         Nei giorni seguenti e tuttora si sta esaminando invece la situazione nel Movimento
sui vari punti della terra, ed anche questi sono momenti un po' particolari. Se foste tutte qui
- sono certa - godreste profondamente soprattutto per il generale sviluppo della nostra
Opera: è il diffondersi del regno di Dio per il moltiplicarsi delle persone che vengono ad
aderire a quest'Opera ecclesiale, a questo pezzo di Chiesa.

         L'alberello del nostro Movimento, nelle varie zone, cresce pressoché dovunque, anzi
in un paio di zone si è addirittura raddoppiato, e ciò - spiegano i vari responsabili - è da
attribuirsi all'unità maggiormente cementata dovunque fra tutti, e particolarmente col
Centro, anche sotto la spinta della lezione di vita lasciataci da Renata, e per
l'approfondimento del tema sullo Spirito Santo, la terza divina Persona, il Dio dell'unità.

         C'è da ammirare, lodare Dio, mettere tutto in mano di Maria perché custodisca ogni
cosa.

         Ora non resta che continuare nella stessa linea così feconda, così fruttuosa, così
centrata: crescere nell'unità su tutti i fronti.

         Unità: parola chiave per tutti noi, parola sintesi di tutta la nostra spiritualità,
"conditio sine qua non" per mantenere la vita che c'è ed incrementarla.

         Abbiamo parlato nell'altro Collegamento dello sforzo costante che dobbiamo fare
per amare come Gesù vuole, per essere pronti a morire l'uno per l'altro.

         E, lo sappiamo, è proprio quest'amore reciproco, così radicale, che genera l'unità fra
noi.
         L'unità, infatti, non si può concepire senza il dolore, senza il morire. Perché l'unità è
un dono, ma è anche frutto del nostro autentico agire cristiano e non c'è espressione vera di
vita cristiana senza la croce. Lo dobbiamo sempre aver presente.

         Ho letto in questi giorni una vita di san Giovanni della Croce. E' impressionante
come egli, grande santo, dottore della Chiesa, non veda che il patire, non si orienti che al
dolore nel percorrere la sua via verso Dio, pur tanto diversa dalla nostra. Ha sperimentato
certamente anche grazie straordinarie, mistiche, vere anticipazioni di paradiso, e molte. Ma
lui non punta che lì. E' veramente Giovanni della croce. Gli andrebbe benissimo il nostro
programma: "Ho un solo Sposo sulla terra..." Egli ha veramente una predilezione per Gesù
crocifisso. Ed è ciò che lo fa un perfetto seguace di Gesù.

         Anche a noi - lo sappiamo - lo Spirito Santo, già dai primi anni, ha sempre indicato la
croce come varco per arrivare all'unione con Dio, come importantissima realtà da
prediligere, come garanzia di essere sulla retta via, e come garanzia di fecondità: "Se il
chicco di grano gettato in terra non muore..." (cf Gv 12,24). Ed è per questo soprattutto che
il Movimento si è così sviluppato. I chicchi di grano morivano, le pianticelle erano potate. E
di qui, vita, vita, vita.

         Negli ultimi anni, pur in mezzo a dolori quotidiani, quali malattie o la partenza di
molti per il Paradiso, o prove di ogni genere, abbiamo avuto così tante consolazioni
dall'Opera stessa, come quelle derivanti dalle molte approvazioni della Chiesa o dalla
costatazione dei copiosi frutti che, a volte, la nostra predilezione per la croce non è stata,
forse, sempre così decisa.

         E qui occorre stare attentissimi: le consolazioni di Dio non possono prendere il
posto del Dio delle consolazioni.

         Dobbiamo ricordarci sempre che abbiamo dato la vita ad uno solo: a Gesù
abbandonato. Non dobbiamo e non possiamo, quindi, barattarlo né tradirlo mai.

         Egli ci insegna l'immenso valore del patire proprio in vista dell'unità: è proprio per
la sua croce, per il suo abbandono che ha riunito gli uomini a Dio e fra loro.

         Sta lì, quindi, a dirci che l'unità costa, anche se con Lui, facendo come Lui, si
raggiunge.

         E allora, se vogliamo essere fedeli al carisma dell'unità, che lo Spirito ci ha dato,
spalanchiamo ancora una volta le porte del cuore a Gesù abbandonato e diamogli il posto
migliore.

         Facciamolo con infinito amore, con riconoscenza, con decisione e coraggio. Ci è stato
così vicino nella vita. Deve poter essere ancora e sempre così. Proponiamo di morire
piuttosto che non amarlo abbandonato.
         In questo mese, per sottolineare un aspetto concreto di questo amore, amiamolo
nelle difficoltà che comporta proprio l'unità fra noi, fra noi persone dell'Opera.

         Lo sappiamo: l'unità nei Centri, nei focolari, nei nuclei, nelle unità, nelle nostre varie
comunità non è cosa fatta una volta per sempre: va ricostruita ogni giorno, e lo si fa amando
il dolore che la non perfetta unità, sempre pronta a verificarsi, comporta.

         E ciò significa essere sempre pronti a vederci nuovi; vuol dire avere pazienza;
sopportare; saper sorvolare; significa dare fiducia; sperare sempre; credere sempre.
Soprattutto non giudicare. Il giudizio semplicemente umano verso gli altri, specie verso i
responsabili, è terribile, è il varco attraverso il quale entra il demonio della disunità; con
esso ogni bene dell'anima lentamente si dissolve, la vocazione stessa può vacillare.

         Curiamo dunque quest'amore per gli altri pieno di sfumature dolorose: sono
l'aspetto concreto del nostro essere pronti a morire l'uno per l'altro; sono i piccoli o grandi
ostacoli da superare con l'amore a Gesù abbandonato perché l'unità sia sempre piena. Allora
il Risorto vivrà sempre splendente in tutta la nostra Opera, su tutto il pianeta, e la condurrà
ancor più avanti nel compimento dei disegni di Dio.

         Quale allora il nuovo motto per questo mese? L'unità fra noi a tutti i costi.$doc1717$, 'drive_import', '01717-WEB-1990-09-13-lunit-fra-noi-a-ITA.txt', false
where exists (select 1 from public.documents where document_id = 1717)
on conflict (document_id, language) do nothing;
