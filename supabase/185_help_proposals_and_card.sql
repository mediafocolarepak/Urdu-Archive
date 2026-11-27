-- 185: the guides follow phase 5: a proposal in four steps, the review beside the document, the groups of a document's card
-- and Copy the link. In Urdu only the names of the buttons change. Run after the new screens are live. Safe to run again.

do $m$
declare c record;
begin
  for c in
    select * from (values
      ('find-read_en', $g$<h2>What you can do with a document</h2>$g$,
        $g$<h2>What you can do with a document</h2>
<p>The card shows the number of the document and its title in English, Urdu and Italian.</p>$g$),
      ('find-read_en', $g$<li><b>Something to say about this text?</b> (for those at work on it, <b>Report a problem</b>): opens <b>Share with us</b>, with the document number already filled in.</li>$g$,
        $g$<li><b>Something to say about this text?</b> (for those at work on it, <b>Report a problem</b>, under <b>More</b>): opens <b>Share with us</b>, with the document number already filled in.</li>
<li><b>Copy the link</b>: the address of this document, to send to someone. They see it only if they may read it.</li>
<li>Those at work on a text find <b>Translate</b>, <b>Open editable text</b> and <b>+ Add a related version</b> under <b>Work on this text</b>.</li>$g$),
      ('find-read_it', $g$<h2>Che cosa puoi fare con un documento</h2>$g$,
        $g$<h2>Che cosa puoi fare con un documento</h2>
<p>La scheda mostra il numero del documento e il suo titolo in inglese, urdu e italiano.</p>$g$),
      ('find-read_it', $g$<li><b>Something to say about this text?</b> (per chi ci sta lavorando, <b>Report a problem</b>): apre <b>Share with us</b>, con il numero del documento già compilato.</li>$g$,
        $g$<li><b>Something to say about this text?</b> (per chi ci sta lavorando, <b>Report a problem</b>, sotto <b>More</b>): apre <b>Share with us</b>, con il numero del documento già compilato.</li>
<li><b>Copy the link</b>: l'indirizzo di questo documento, da mandare a qualcuno. Lo vede solo se può leggerlo.</li>
<li>Chi lavora su un testo trova <b>Translate</b>, <b>Open editable text</b> e <b>+ Add a related version</b> sotto <b>Work on this text</b>.</li>$g$),
      ('propose_en', $g$<li><b>Check whether the text already exists.</b> In part 1, search by title or by a phrase of the text. If you find the same text in another language, press <b>Link to this</b>: empty fields fill in by themselves. If it isn't there, go on: it will be a new text.</li>$g$,
        $g$<li><b>Check whether the text already exists.</b> In the first step, <b>Is it already here?</b>, search by title or by a phrase of the text. If you find the same text in another language, press <b>Link to this</b>: empty fields fill in by themselves. If it isn't there, go on: it will be a new text.</li>$g$),
      ('propose_en', $g$<li><b>Fill in what the versions share.</b> Part 2 needs the <b>English title, category, author</b> and <b>date or period</b>. For a Word of Life, use its own month, such as <code>2026-12</code>, not the magazine's. The rest is optional.</li>$g$,
        $g$<li><b>Fill in what the versions share.</b> The second step, <b>About the text</b>, needs the <b>English title, category, author</b> and <b>date or period</b>. For a Word of Life, use its own month, such as <code>2026-12</code>, not the magazine's. The rest is under <b>More details</b>, and is optional.</li>$g$),
      ('propose_en', $g$<li><b>Fill in the version.</b> In part 3, choose the <b>language</b> and the <b>title in that language</b>, then the access level and format.</li>$g$,
        $g$<li><b>Fill in the version.</b> In the third step, <b>The text or the file</b>, choose the <b>language</b> and the <b>title in that language</b>, then the access level and format.</li>$g$),
      ('propose_en', $g$<li><b>Add the text.</b> Paste it, or use <b>Or load the text from Word</b>, and <b>always check it</b>. The text is what makes the document findable: a PDF alone can be found only by its title and tags.</li>$g$,
        $g$<li><b>Add the text.</b> Paste it, or use <b>Load the text from Word</b> or drop the Word file on the box, and <b>always check it</b>. The text is what makes the document findable: a PDF alone can be found only by its title and tags.</li>$g$),
      ('propose_en', $g$<li><b>Add the PDF, if there is one.</b> Either the text or the PDF is enough, but both are better.</li>$g$,
        $g$<li><b>Add the PDF, if there is one.</b> Press <b>Choose a PDF</b>, or drop it on the box. On a computer it shows beside the text, so you can compare them. Either the text or the PDF is enough, but both are better.</li>$g$),
      ('propose_en', $g$<li><b>Send.</b> Press <b>Send for review</b>. If you haven't finished, press <b>Save draft</b> and come back from <b>My proposals</b>.</li>$g$,
        $g$<li><b>Send.</b> The last step, <b>Check and send</b>, lists what is still missing, and <b>Go there</b> takes you to it. Then press <b>Send for review</b>. If you haven't finished, press <b>Save draft</b> and come back from <b>My proposals</b>. While you write, the app also keeps a copy on this device, and offers it again if the page closes.</li>$g$),
      ('propose_en', $g$<li><b>A text already there, starting from the form:</b> in part 1, search and press <b>Link to this</b>. Here <b>Remove the link</b> undoes it.</li>$g$,
        $g$<li><b>A text already there, starting from the form:</b> in the first step, search and press <b>Link to this</b>. Here <b>Remove the link</b> undoes it.</li>$g$),
      ('propose_en', $g$<li>The simplest way: copy the text and paste it into <b>Text</b> in the form. Or press <b>Download Word (.docx)</b> and load it with <b>Or load the text from Word</b>, or <b>Generate PDF (print)</b> and choose <b>Save as PDF</b>.</li>$g$,
        $g$<li>The simplest way: copy the text and paste it into <b>Text</b> in the form. Or press <b>Download Word (.docx)</b> and load it with <b>Load the text from Word</b>, or <b>Generate PDF (print)</b> and choose <b>Save as PDF</b>.</li>$g$),
      ('propose_it', $g$<li><b>Controlla se il testo esiste già.</b> Nella parte 1, cerca per titolo o per una frase del testo. Se trovi lo stesso testo in un'altra lingua, premi <b>Link to this</b>: i campi vuoti si compilano da soli. Se non c'è, prosegui: sarà un testo nuovo.</li>$g$,
        $g$<li><b>Controlla se il testo esiste già.</b> Nel primo passo, <b>Is it already here?</b>, cerca per titolo o per una frase del testo. Se trovi lo stesso testo in un'altra lingua, premi <b>Link to this</b>: i campi vuoti si compilano da soli. Se non c'è, prosegui: sarà un testo nuovo.</li>$g$),
      ('propose_it', $g$<li><b>Compila ciò che le versioni hanno in comune.</b> La parte 2 chiede <b>titolo inglese, categoria, autore</b> e <b>data o periodo</b>. Per una Parola di Vita usa il suo mese, per esempio <code>2026-12</code>, non quello della rivista. Il resto è facoltativo.</li>$g$,
        $g$<li><b>Compila ciò che le versioni hanno in comune.</b> Il secondo passo, <b>About the text</b>, chiede <b>titolo inglese, categoria, autore</b> e <b>data o periodo</b>. Per una Parola di Vita usa il suo mese, per esempio <code>2026-12</code>, non quello della rivista. Il resto è sotto <b>More details</b>, ed è facoltativo.</li>$g$),
      ('propose_it', $g$<li><b>Compila la versione.</b> Nella parte 3, scegli la <b>lingua</b> e il <b>titolo in quella lingua</b>, poi il livello di accesso e il formato.</li>$g$,
        $g$<li><b>Compila la versione.</b> Nel terzo passo, <b>The text or the file</b>, scegli la <b>lingua</b> e il <b>titolo in quella lingua</b>, poi il livello di accesso e il formato.</li>$g$),
      ('propose_it', $g$<li><b>Aggiungi il testo.</b> Incollalo, oppure usa <b>Or load the text from Word</b>, e <b>controllalo sempre</b>. È il testo a far trovare il documento: un PDF da solo si trova solo per titolo e tag.</li>$g$,
        $g$<li><b>Aggiungi il testo.</b> Incollalo, oppure usa <b>Load the text from Word</b> o trascina il file Word sul riquadro, e <b>controllalo sempre</b>. È il testo a far trovare il documento: un PDF da solo si trova solo per titolo e tag.</li>$g$),
      ('propose_it', $g$<li><b>Aggiungi il PDF, se c'è.</b> Basta il testo o il PDF, ma entrambi sono meglio.</li>$g$,
        $g$<li><b>Aggiungi il PDF, se c'è.</b> Premi <b>Choose a PDF</b>, o trascinalo sul riquadro. Sul computer compare accanto al testo, così puoi confrontarli. Basta il testo o il PDF, ma entrambi sono meglio.</li>$g$),
      ('propose_it', $g$<li><b>Invia.</b> Premi <b>Send for review</b>. Se non hai finito, premi <b>Save draft</b> e torna da <b>My proposals</b>.</li>$g$,
        $g$<li><b>Invia.</b> L'ultimo passo, <b>Check and send</b>, elenca ciò che manca ancora, e <b>Go there</b> ti porta lì. Poi premi <b>Send for review</b>. Se non hai finito, premi <b>Save draft</b> e torna da <b>My proposals</b>. Mentre scrivi, l'app tiene anche una copia su questo dispositivo, e te la ripropone se la pagina si chiude.</li>$g$),
      ('propose_it', $g$<li><b>Un testo già presente, partendo dalla scheda:</b> nella parte 1, cerca e premi <b>Link to this</b>. Qui <b>Remove the link</b> lo annulla.</li>$g$,
        $g$<li><b>Un testo già presente, partendo dalla scheda:</b> nel primo passo, cerca e premi <b>Link to this</b>. Qui <b>Remove the link</b> lo annulla.</li>$g$),
      ('propose_it', $g$<li>Il modo più semplice: copia il testo e incollalo in <b>Text</b> nella scheda. Oppure premi <b>Download Word (.docx)</b> e caricalo con <b>Or load the text from Word</b>, o <b>Generate PDF (print)</b> e scegli <b>Salva come PDF</b>.</li>$g$,
        $g$<li>Il modo più semplice: copia il testo e incollalo in <b>Text</b> nella scheda. Oppure premi <b>Download Word (.docx)</b> e caricalo con <b>Load the text from Word</b>, o <b>Generate PDF (print)</b> e scegli <b>Salva come PDF</b>.</li>$g$),
      ('propose_ur', $g$<li><b>متن شامل کریں۔</b> اسے چسپاں کریں، یا <b>Or load the text from Word</b> استعمال کریں، اور <b>ہمیشہ اسے جانچیں</b>۔ متن ہی سے دستاویز تلاش میں ملتی ہے: اکیلی PDF صرف عنوان اور ٹیگز سے ملتی ہے۔</li>$g$,
        $g$<li><b>متن شامل کریں۔</b> اسے چسپاں کریں، یا <b>Load the text from Word</b> استعمال کریں، اور <b>ہمیشہ اسے جانچیں</b>۔ متن ہی سے دستاویز تلاش میں ملتی ہے: اکیلی PDF صرف عنوان اور ٹیگز سے ملتی ہے۔</li>$g$),
      ('propose_ur', $g$<li>سب سے آسان طریقہ: متن کاپی کر کے فارم کے <b>Text</b> میں چسپاں کریں۔ یا <b>Download Word (.docx)</b> دبا کر <b>Or load the text from Word</b> سے لوڈ کریں، یا <b>Generate PDF (print)</b> دبا کر <b>Save as PDF</b> چنیں۔</li>$g$,
        $g$<li>سب سے آسان طریقہ: متن کاپی کر کے فارم کے <b>Text</b> میں چسپاں کریں۔ یا <b>Download Word (.docx)</b> دبا کر <b>Load the text from Word</b> سے لوڈ کریں، یا <b>Generate PDF (print)</b> دبا کر <b>Save as PDF</b> چنیں۔</li>$g$),
      ('review-proposals_en', $g$<li><b>Open a proposal.</b> You see the data all versions share, then each version with its text, PDF, audio or video.</li>$g$,
        $g$<li><b>Open a proposal.</b> On a computer the document is on the left and your decision on the right; on a phone press <b>Look at the document</b>. Each version has <b>Open the PDF</b> or <b>Read the text</b>, and its recording or video.</li>$g$),
      ('review-proposals_en', $g$<li><b>Read the text</b> against its source, if you can, and tick that you have. Only then does that text count as reread. Otherwise it stays unverified, which is allowed.</li>$g$,
        $g$<li><b>Read the text</b> against its source, if you can, and tick that you have. Only then does that text count as reread. Otherwise it stays unverified, which is allowed. <b>Approve and publish</b> opens when you have looked at every version: its PDF or text opened, its recording played, its video opened.</li>$g$),
      ('review-proposals_en', $g$<li><b>Decide.</b></li>$g$,
        $g$<li><b>Decide.</b> Choose one of the three, write a note, and press <b>Send</b>. The note is needed with <b>Send back to correct</b> and <b>Reject</b>.</li>$g$),
      ('review-proposals_en', $g$<table><tr><th>Button</th><th>When</th><th>What happens</th></tr>$g$,
        $g$<table><tr><th>Choice</th><th>When</th><th>What happens</th></tr>$g$),
      ('review-proposals_it', $g$<li><b>Apri una proposta.</b> Vedi i dati comuni, poi ogni versione con il suo testo, PDF, audio o video.</li>$g$,
        $g$<li><b>Apri una proposta.</b> Sul computer il documento è a sinistra e la tua decisione a destra; sul telefono premi <b>Look at the document</b>. Ogni versione ha <b>Open the PDF</b> o <b>Read the text</b>, e la sua registrazione o il suo video.</li>$g$),
      ('review-proposals_it', $g$<li><b>Leggi il testo</b> a fronte della fonte, se puoi, e spunta di averlo fatto. Solo allora quel testo risulta riletto. Altrimenti resta non verificato, ed è ammesso.</li>$g$,
        $g$<li><b>Leggi il testo</b> a fronte della fonte, se puoi, e spunta di averlo fatto. Solo allora quel testo risulta riletto. Altrimenti resta non verificato, ed è ammesso. <b>Approve and publish</b> si apre quando hai guardato ogni versione: aperto il PDF o il testo, ascoltata la registrazione, aperto il video.</li>$g$),
      ('review-proposals_it', $g$<li><b>Decidi.</b></li>$g$,
        $g$<li><b>Decidi.</b> Scegli una delle tre, scrivi una nota e premi <b>Send</b>. La nota serve con <b>Send back to correct</b> e <b>Reject</b>.</li>$g$),
      ('review-proposals_it', $g$<table><tr><th>Pulsante</th><th>Quando</th><th>Che cosa succede</th></tr>$g$,
        $g$<table><tr><th>Scelta</th><th>Quando</th><th>Che cosa succede</th></tr>$g$)
    ) as t(slug, was, now_is)
  loop
    update public.help_pages h
       set html_content = replace(h.html_content, c.was, c.now_is), updated_at = now(), updated_by_email = 'migration 185'
     where h.slug = c.slug and strpos(h.html_content, c.was) > 0 and strpos(h.html_content, c.now_is) = 0;
  end loop;
end $m$;

-- Every row should say true. A false row means the sentence had been edited in the app: change that guide by hand.
select 'find-read_en' as item, (select count(*) = 1 from public.help_pages where slug = 'find-read_en'
  and strpos(html_content, $g$<h2>What you can do with a document</h2>
<p>The card shows the number of the document and its title in English, Urdu and Italian.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Something to say about this text?</b> (for those at work on it, <b>Report a problem</b>, under <b>More</b>): opens <b>Share with us</b>, with the document number already filled in.</li>
<li><b>Copy the link</b>: the address of this document, to send to someone. They see it only if they may read it.</li>
<li>Those at work on a text find <b>Translate</b>, <b>Open editable text</b> and <b>+ Add a related version</b> under <b>Work on this text</b>.</li>$g$) > 0) as ok
union all
select 'find-read_it' as item, (select count(*) = 1 from public.help_pages where slug = 'find-read_it'
  and strpos(html_content, $g$<h2>Che cosa puoi fare con un documento</h2>
<p>La scheda mostra il numero del documento e il suo titolo in inglese, urdu e italiano.</p>$g$) > 0
  and strpos(html_content, $g$<li><b>Something to say about this text?</b> (per chi ci sta lavorando, <b>Report a problem</b>, sotto <b>More</b>): apre <b>Share with us</b>, con il numero del documento già compilato.</li>
<li><b>Copy the link</b>: l'indirizzo di questo documento, da mandare a qualcuno. Lo vede solo se può leggerlo.</li>
<li>Chi lavora su un testo trova <b>Translate</b>, <b>Open editable text</b> e <b>+ Add a related version</b> sotto <b>Work on this text</b>.</li>$g$) > 0) as ok
union all
select 'propose_en' as item, (select count(*) = 1 from public.help_pages where slug = 'propose_en'
  and strpos(html_content, $g$<li><b>Check whether the text already exists.</b> In the first step, <b>Is it already here?</b>, search by title or by a phrase of the text. If you find the same text in another language, press <b>Link to this</b>: empty fields fill in by themselves. If it isn't there, go on: it will be a new text.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Fill in what the versions share.</b> The second step, <b>About the text</b>, needs the <b>English title, category, author</b> and <b>date or period</b>. For a Word of Life, use its own month, such as <code>2026-12</code>, not the magazine's. The rest is under <b>More details</b>, and is optional.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Fill in the version.</b> In the third step, <b>The text or the file</b>, choose the <b>language</b> and the <b>title in that language</b>, then the access level and format.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Add the text.</b> Paste it, or use <b>Load the text from Word</b> or drop the Word file on the box, and <b>always check it</b>. The text is what makes the document findable: a PDF alone can be found only by its title and tags.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Add the PDF, if there is one.</b> Press <b>Choose a PDF</b>, or drop it on the box. On a computer it shows beside the text, so you can compare them. Either the text or the PDF is enough, but both are better.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Send.</b> The last step, <b>Check and send</b>, lists what is still missing, and <b>Go there</b> takes you to it. Then press <b>Send for review</b>. If you haven't finished, press <b>Save draft</b> and come back from <b>My proposals</b>. While you write, the app also keeps a copy on this device, and offers it again if the page closes.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>A text already there, starting from the form:</b> in the first step, search and press <b>Link to this</b>. Here <b>Remove the link</b> undoes it.</li>$g$) > 0
  and strpos(html_content, $g$<li>The simplest way: copy the text and paste it into <b>Text</b> in the form. Or press <b>Download Word (.docx)</b> and load it with <b>Load the text from Word</b>, or <b>Generate PDF (print)</b> and choose <b>Save as PDF</b>.</li>$g$) > 0) as ok
union all
select 'propose_it' as item, (select count(*) = 1 from public.help_pages where slug = 'propose_it'
  and strpos(html_content, $g$<li><b>Controlla se il testo esiste già.</b> Nel primo passo, <b>Is it already here?</b>, cerca per titolo o per una frase del testo. Se trovi lo stesso testo in un'altra lingua, premi <b>Link to this</b>: i campi vuoti si compilano da soli. Se non c'è, prosegui: sarà un testo nuovo.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Compila ciò che le versioni hanno in comune.</b> Il secondo passo, <b>About the text</b>, chiede <b>titolo inglese, categoria, autore</b> e <b>data o periodo</b>. Per una Parola di Vita usa il suo mese, per esempio <code>2026-12</code>, non quello della rivista. Il resto è sotto <b>More details</b>, ed è facoltativo.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Compila la versione.</b> Nel terzo passo, <b>The text or the file</b>, scegli la <b>lingua</b> e il <b>titolo in quella lingua</b>, poi il livello di accesso e il formato.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Aggiungi il testo.</b> Incollalo, oppure usa <b>Load the text from Word</b> o trascina il file Word sul riquadro, e <b>controllalo sempre</b>. È il testo a far trovare il documento: un PDF da solo si trova solo per titolo e tag.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Aggiungi il PDF, se c'è.</b> Premi <b>Choose a PDF</b>, o trascinalo sul riquadro. Sul computer compare accanto al testo, così puoi confrontarli. Basta il testo o il PDF, ma entrambi sono meglio.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Invia.</b> L'ultimo passo, <b>Check and send</b>, elenca ciò che manca ancora, e <b>Go there</b> ti porta lì. Poi premi <b>Send for review</b>. Se non hai finito, premi <b>Save draft</b> e torna da <b>My proposals</b>. Mentre scrivi, l'app tiene anche una copia su questo dispositivo, e te la ripropone se la pagina si chiude.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Un testo già presente, partendo dalla scheda:</b> nel primo passo, cerca e premi <b>Link to this</b>. Qui <b>Remove the link</b> lo annulla.</li>$g$) > 0
  and strpos(html_content, $g$<li>Il modo più semplice: copia il testo e incollalo in <b>Text</b> nella scheda. Oppure premi <b>Download Word (.docx)</b> e caricalo con <b>Load the text from Word</b>, o <b>Generate PDF (print)</b> e scegli <b>Salva come PDF</b>.</li>$g$) > 0) as ok
union all
select 'propose_ur' as item, (select count(*) = 1 from public.help_pages where slug = 'propose_ur'
  and strpos(html_content, $g$<li><b>متن شامل کریں۔</b> اسے چسپاں کریں، یا <b>Load the text from Word</b> استعمال کریں، اور <b>ہمیشہ اسے جانچیں</b>۔ متن ہی سے دستاویز تلاش میں ملتی ہے: اکیلی PDF صرف عنوان اور ٹیگز سے ملتی ہے۔</li>$g$) > 0
  and strpos(html_content, $g$<li>سب سے آسان طریقہ: متن کاپی کر کے فارم کے <b>Text</b> میں چسپاں کریں۔ یا <b>Download Word (.docx)</b> دبا کر <b>Load the text from Word</b> سے لوڈ کریں، یا <b>Generate PDF (print)</b> دبا کر <b>Save as PDF</b> چنیں۔</li>$g$) > 0) as ok
union all
select 'review-proposals_en' as item, (select count(*) = 1 from public.help_pages where slug = 'review-proposals_en'
  and strpos(html_content, $g$<li><b>Open a proposal.</b> On a computer the document is on the left and your decision on the right; on a phone press <b>Look at the document</b>. Each version has <b>Open the PDF</b> or <b>Read the text</b>, and its recording or video.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Read the text</b> against its source, if you can, and tick that you have. Only then does that text count as reread. Otherwise it stays unverified, which is allowed. <b>Approve and publish</b> opens when you have looked at every version: its PDF or text opened, its recording played, its video opened.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Decide.</b> Choose one of the three, write a note, and press <b>Send</b>. The note is needed with <b>Send back to correct</b> and <b>Reject</b>.</li>$g$) > 0
  and strpos(html_content, $g$<table><tr><th>Choice</th><th>When</th><th>What happens</th></tr>$g$) > 0) as ok
union all
select 'review-proposals_it' as item, (select count(*) = 1 from public.help_pages where slug = 'review-proposals_it'
  and strpos(html_content, $g$<li><b>Apri una proposta.</b> Sul computer il documento è a sinistra e la tua decisione a destra; sul telefono premi <b>Look at the document</b>. Ogni versione ha <b>Open the PDF</b> o <b>Read the text</b>, e la sua registrazione o il suo video.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Leggi il testo</b> a fronte della fonte, se puoi, e spunta di averlo fatto. Solo allora quel testo risulta riletto. Altrimenti resta non verificato, ed è ammesso. <b>Approve and publish</b> si apre quando hai guardato ogni versione: aperto il PDF o il testo, ascoltata la registrazione, aperto il video.</li>$g$) > 0
  and strpos(html_content, $g$<li><b>Decidi.</b> Scegli una delle tre, scrivi una nota e premi <b>Send</b>. La nota serve con <b>Send back to correct</b> e <b>Reject</b>.</li>$g$) > 0
  and strpos(html_content, $g$<table><tr><th>Scelta</th><th>Quando</th><th>Che cosa succede</th></tr>$g$) > 0) as ok
union all
select 'no old name is left', not exists (select 1 from public.help_pages where html_content ~ '<b>Or load the text from Word</b>')
union all
select 'still 27 guides in each language', (select count(*) = 81 from public.help_pages);
