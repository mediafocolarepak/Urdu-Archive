-- 69_protect_reviewed_texts.sql
-- Rende una garanzia del database quella che finora era solo una buona intenzione del client:
-- un testo che un essere umano ha riletto non viene sovrascritto da un caricamento automatico.
--
-- Il caricatore di massa (Bulk Urdu text import, js/inpageconverter.js) esclude gia' le righe
-- con reviewed = true prima di scrivere. Ma quel filtro protegge solo da QUEL programma: non
-- protegge da uno strumento futuro, da un upsert scritto di fretta, o da una update lanciata a
-- mano nel SQL Editor. E cio' che si perde e' esattamente il lavoro piu' costoso dell'archivio,
-- cioe' le ore di rilettura umana, sostituite in silenzio da una trascrizione automatica.
-- Do dopo 68_document_texts.sql.
--
-- IL CONTRATTO
-- ------------
-- Riscrivere il testo di un documento gia' riletto e' consentito, ma e' a sua volta un atto di
-- rilettura: chi lo fa deve dichiararlo toccando reviewed_at nella stessa update (e, per
-- educazione, reviewed_by_email). Un caricamento automatico non lo fa - manda solo body,
-- source e source_file - e quindi viene respinto.
--   * per correggere un testo riletto:  ... set body = ..., reviewed_at = now(), reviewed_by_email = ...
--   * per togliere la rilettura:        ... set reviewed = false, reviewed_at = null
-- In entrambi i casi reviewed_at cambia, che e' il segnale che qualcuno se ne sta assumendo
-- la responsabilita'.
--
-- Questo definisce il contratto per l'editor del testo che ancora non esiste: quando lo si
-- scrivera', il salvataggio di un testo gia' riletto dovra' stampigliare reviewed_at = now().
-- Non e' un vincolo scomodo, e' la registrazione di chi risponde di quella versione.
--
-- Perche' un'eccezione e non uno scarto silenzioso: il caricatore filtra gia' a monte, quindi
-- se questo trigger scatta vuol dire che qualcosa non funziona come si crede. In quel caso e'
-- molto meglio un errore rumoroso che una riga saltata di nascosto - il caricatore registra il
-- lotto fallito nel suo log e si puo' andare a vedere.

create or replace function public.guard_reviewed_document_text()
returns trigger
language plpgsql
as $fn$
begin
  if old.reviewed
     and new.body is distinct from old.body
     and new.reviewed_at is not distinct from old.reviewed_at then
    raise exception
      $msg$Il documento #% ha un testo gia' riletto e verificato: non puo' essere sostituito da una scrittura automatica. Per correggerlo davvero, aggiorna anche reviewed_at (e reviewed_by_email) nella stessa update.$msg$,
      old.document_id
      using errcode = 'check_violation';
  end if;
  return new;
end;
$fn$;

drop trigger if exists trg_guard_reviewed_document_text on public.document_texts;
create trigger trg_guard_reviewed_document_text
  before update on public.document_texts
  for each row execute function public.guard_reviewed_document_text();

-- Verifica: si fabbrica una riga finta, la si marca come riletta, si prova a sovrascriverla
-- esattamente come farebbe il caricatore, e ci si aspetta che il database rifiuti. Si controlla
-- anche che una correzione fatta come si deve passi, altrimenti avremmo costruito un muro
-- invece di un filtro. Alla fine ripulisce: non lascia niente dietro di se'.
do $test$
declare
  v_id       integer;
  v_bloccato boolean := false;
  v_passata  boolean := false;
begin
  select document_id into v_id from public.documents
   where document_id not in (select document_id from public.document_texts)
   limit 1;
  if v_id is null then
    raise notice 'Nessun documento libero per la prova: saltata (il trigger e'' comunque installato).';
    return;
  end if;

  insert into public.document_texts (document_id, body, reviewed, reviewed_at, reviewed_by_email)
    values (v_id, 'testo riletto a mano', true, now(), 'prova@example.org');

  -- 1. cio' che manda il caricatore: body/source/source_file, senza toccare reviewed_at -> respinta
  begin
    update public.document_texts
       set body = 'trascrizione automatica', source = 'inpage', source_file = 'prova.inp'
     where document_id = v_id;
  exception when check_violation then
    v_bloccato := true;
  end;

  -- 2. una correzione umana dichiarata: stessa riga, ma con reviewed_at aggiornato -> deve passare
  begin
    update public.document_texts
       set body = 'correzione umana', reviewed_at = now() + interval '1 second',
           reviewed_by_email = 'prova@example.org'
     where document_id = v_id;
    v_passata := true;
  exception when others then
    v_passata := false;
  end;

  delete from public.document_texts where document_id = v_id;

  if not v_bloccato then
    raise exception 'PROVA FALLITA: il testo riletto e'' stato sovrascritto da una scrittura automatica. Il trigger non protegge.';
  end if;
  if not v_passata then
    raise exception 'PROVA FALLITA: una correzione umana dichiarata (con reviewed_at) e'' stata respinta. Il trigger e'' troppo severo.';
  end if;
  raise notice 'PROVA SUPERATA: sovrascrittura automatica respinta, correzione umana dichiarata consentita.';
end $test$;

select 'trigger installato su document_texts (leggi il messaggio PROVA qui sopra)' as result;
