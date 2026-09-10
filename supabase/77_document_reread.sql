-- Coda di rilettura (v14 §6.4 punto 5 / v17 §4 punto 3): distribuisce la rilettura dei 1.124
-- testi document_texts.reviewed = false. Decisioni chiuse in chat l'11/09/2026: un solo
-- passaggio (chi rilegge corregge e marca riletto direttamente, nessun secondo Revisor), una
-- coda dedicata senza righe Task (1.124 task manuali non sono praticabili - la creazione di un
-- Task oggi e' manuale, vedi 34_task_store.sql), correzione diretta del testo.
--
-- NESSUNA riga Task, NESSUNA nuova tabella per il registro: il credito passa da
-- task_outcome_events con task_id = null (gia' permesso dallo schema, 38_task_review_pipeline.sql)
-- cosi' il trigger che aggiorna credits/reputation scatta esattamente come per un task vero.
-- La tariffa (crediti per pagina) vive in task_category_rates con un codice dedicato
-- 'TEXT_REREAD' - stessa tabella gia' admin-editabile usata per le tariffe dei Task, ma questo
-- codice non viene aggiunto alla lista 'task_category' di option_lists: non deve comparire tra
-- le categorie selezionabili quando un Coordinator crea un Task vero, per non confondere i due
-- flussi (questo bypassa deliberatamente il sistema Task).
--
-- Chi puo' rileggere: qualifica Proof Reader (operator_qualification 'PROOF_READER', gia'
-- esistente dal 08/2026, mai usata finora) o Coordinator/Admin - stesso schema di
-- DATA_ASSISTANT per gli strumenti di catalogazione.

-- 1. Tariffa di partenza - l'Admin la puo' cambiare dalla coda stessa (vedi UI), che fa un
-- upsert su questa riga. 0.5 crediti/pagina, meta' di quanto tipicamente vale una traduzione -
-- "va pagato meno", come gia' annotato in 68_document_texts.sql.
insert into task_category_rates (category, credits_per_page)
values ('TEXT_REREAD', 0.5)
on conflict (category) do nothing;

-- 2. "Dammi il prossimo testo da rileggere" - sceglie deterministicamente il document_id piu'
-- basso ancora non riletto (nessuna prenotazione/lock: se due persone lo aprono nello stesso
-- momento, la seconda scrittura vince e basta, il rischio e' basso e non vale la complessita'
-- di un claim). Si autoverifica il permesso, stesso schema di board_post_readers/
-- formation_enrollees: chi non e' qualificato riceve zero righe invece di un errore.
create or replace function public.get_next_reread_document()
returns table (
  document_id integer, title text, en_title text, category text,
  pages integer, body text
)
language sql
security definer
stable
set search_path = public
as $$
  select d.document_id, d.title, d.en_title, d.category, d.pages, dt.body
  from public.document_texts dt
  join public.documents d on d.document_id = dt.document_id
  where dt.reviewed = false
    and (
      public.current_role_is('coordinator')
      or exists (select 1 from public.user_qualifications uq
                  where uq.user_id = auth.uid() and uq.qualification_code = 'PROOF_READER')
    )
  order by dt.document_id
  limit 1;
$$;

-- 3. Invio della rilettura - unico punto che assegna il credito, cosi' non si puo' guadagnare
-- rileggendo lo stesso documento due volte (se reviewed e' gia' true quando arriva questa
-- chiamata - riletto nel frattempo da qualcun altro - il testo si salva comunque ma senza
-- credito aggiuntivo). reviewed_at viene sempre toccato in questa stessa update, quindi il
-- guard trigger di 69_protect_reviewed_texts.sql non scatta mai qui.
create or replace function public.submit_document_reread(doc_id integer, corrected_body text)
returns table (credited numeric)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
  v_was_reviewed boolean;
  v_pages integer;
  v_rate numeric;
  v_credit numeric := 0;
begin
  if not (
    public.current_role_is('coordinator')
    or exists (select 1 from public.user_qualifications uq
                where uq.user_id = auth.uid() and uq.qualification_code = 'PROOF_READER')
  ) then
    raise exception 'You are not qualified to reread texts.';
  end if;

  select email into v_email from public.user_roles where user_id = auth.uid();

  select dt.reviewed, d.pages into v_was_reviewed, v_pages
  from public.document_texts dt join public.documents d on d.document_id = dt.document_id
  where dt.document_id = doc_id;
  if not found then
    raise exception 'Document not found.';
  end if;

  update public.document_texts
  set body = corrected_body, reviewed = true, reviewed_by_email = v_email, reviewed_at = now()
  where document_id = doc_id;

  if not v_was_reviewed then
    select credits_per_page into v_rate from task_category_rates where category = 'TEXT_REREAD';
    v_credit := coalesce(v_rate, 0) * greatest(coalesce(v_pages, 1), 1);
    insert into public.task_outcome_events (task_id, user_id, event_type, credit_delta, reputation_delta, created_by_email, note)
    values (null, auth.uid(), 'document_reread', round(v_credit)::integer, 2, v_email, 'Reread document #' || doc_id);
  end if;

  return query select v_credit;
end;
$$;

select 'funzione get_next_reread_document', to_regproc('public.get_next_reread_document') is not null as ok
union all select 'funzione submit_document_reread', to_regproc('public.submit_document_reread') is not null
union all select 'tariffa TEXT_REREAD seminata', (select count(*) = 1 from task_category_rates where category = 'TEXT_REREAD');
