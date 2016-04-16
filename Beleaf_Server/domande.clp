;(clear)
;(watch all)

;********************************
;* FUNZIONI                     *
;********************************

;effettua una domanda e controlla che la risposta sia valida
(deffunction Domanda (?testo $?valori_ammessi)
    ;il simbolo > indica la fine del messaggio
    ;la lettera Q identifica una domanda
    (bind ?risposta un_valore_non_ammesso)
    (while (not (member$ ?risposta ?valori_ammessi)) do
        (Print Q (str-cat ?testo " (" (implode$ ?valori_ammessi) ")" ))
        (bind ?risposta (read))
        ( if (lexemep ?risposta)
            then (bind ?risposta (lowcase ?risposta)) )
        )
    ?risposta ;Valore restituito dalla funzione Domanda
)

;stampa con la giusta formattazione i messaggi (domande escluse)
(deffunction Print (?tipo_messaggio ?testo)
    ;il simbolo > indica la fine del messaggio
	;la lettera Q identifica una domanda
    ;la lettera A identifica che un albero e' stato trovato
    ;la lettera U identifica che non e' stato trovato nessun albero
	;la lettera R identifica che si sta stampando la lista delle risposte effettuate
	(if (eq Q ?tipo_messaggio) then
		(format t "Q %s >" ?testo)
		)
    (if (eq A ?tipo_messaggio) then
        (format t "A %s >" ?testo)
        )
    (if (eq U ?tipo_messaggio) then
        (format t "U %s >" ?testo)
        )
	(if (eq R ?tipo_messaggio) then
	    (format t "R %s >" ?testo)
		)
)

;********************************
;* STRUTTURE                    *
;********************************

;surrogato di attributo utilizzato per la ritrattazione
(deftemplate risposta
    (slot nome
        (type SYMBOL))
    (slot valore)
)

;attributo memorizzato nella wm per mantenere lo storico delle scelte effettuate
(deftemplate attributo
    (slot nome
        (type SYMBOL))
    (slot valore)
    (slot obbligatorio
        (type SYMBOL)
        (allowed-values si no)
        (default si))
)

;copia di attributo utilizzato per la gestione della confidenza
(deftemplate nuovo_attributo
    (slot nome
        (type SYMBOL))
    (slot valore)
    (slot obbligatorio
        (type SYMBOL)
        (allowed-values si no)
        (default si))
)

;template utilizzato per descrivere gli alberi nella wm
(deftemplate albero
    (slot nome (type SYMBOL))
    (slot grado_di_confidenza (type INTEGER) (default 0))
    (slot consistente (type SYMBOL) (allowed-values si no)(default si))
    
    (slot tipo_pianta  (type SYMBOL) (default any))
    (multislot chioma (type SYMBOL) (default any))
	(slot sempre_verde (type SYMBOL) (default any))
    (slot altezza_max (type INTEGER))
    (slot descrizione_foglia (type STRING) (default ""))
    (slot tipo_foglia (type SYMBOL) (default any))
    (slot margine_fogliare (type SYMBOL) (default any))
    (multislot periodo_fioritura (type SYMBOL) (default any))
    (slot tipo_fiore (type SYMBOL) (default any))
    (multislot colore_fiore (type SYMBOL) (default any))
    (multislot periodo_fruttificazione (type SYMBOL) (default any))
    (slot tipo_frutto (type SYMBOL) (default any))
    (multislot colore_frutto (type SYMBOL) (default any))
    (slot descrizione_corteccia (type STRING))
    (multislot colore_corteccia (type STRING))
    (slot fusto (type STRING))
    (multislot luogo (type Symbol)(default any))
    (multislot altitudine  (type SYMBOL))
    (slot informazioni (type STRING))
)

;********************************
;* GESTIONE CONFIDENZA          *
;********************************

(defrule aggiorna_grado_di_confidenza
    (declare (salience 9000) (no-loop TRUE))
	(or (fase predizione)(fase ristrutturazione))
    
    (nuovo_attributo (nome ?nomeAttributo)(valore ?valoreAsserito&~non_so))
    (or
        (and (test (eq ?nomeAttributo tipo_pianta)) ?albero <- (albero (tipo_pianta ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo chioma)) ?albero <- (albero (chioma $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo sempre_verde)) ?albero <- (albero (sempre_verde ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo altezza)) ?albero <- (albero (altezza_max ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_foglia)) ?albero <- (albero (tipo_foglia ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo margine_fogliare)) ?albero <- (albero (margine_fogliare ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo periodo_fioritura)) ?albero <- (albero (periodo_fioritura $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_fiore)) ?albero <- (albero (tipo_fiore ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo colore_fiore)) ?albero <- (albero (colore_fiore $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo periodo_fruttificazione)) ?albero <- (albero (periodo_fruttificazione $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_frutto)) ?albero <- (albero (tipo_frutto ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo colore_frutto)) ?albero <- (albero (colore_frutto $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo luogo)) ?albero <- (albero (luogo $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo altitudine)) ?albero <- (albero (altitudine $? ?valoreAsserito $?)(consistente si)) )
        )
    =>
    (modify ?albero (grado_di_confidenza (+ ?albero.grado_di_confidenza 1)) )
    )

(defrule elimina_alberi_inconsistenti
    (declare (salience 9001) (no-loop TRUE))
	(or (fase predizione)(fase ristrutturazione))
    
    (nuovo_attributo (nome ?nomeAttributo)(valore ?valoreAsserito&~non_so)(obbligatorio si))
    (or
        (and (test (eq ?nomeAttributo chioma)) ?albero <- (albero (chioma $?valori&~any&:(not(member$ ?valoreAsserito ?valori)))(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_pianta)) ?albero <- (albero (tipo_pianta ~?valoreAsserito&~any)(consistente si)) )
		(and (test (eq ?nomeAttributo sempre_verde)) ?albero <- (albero (sempre_verde ~?valoreAsserito&~any)(consistente si)) )
        (and (test (eq ?nomeAttributo altezza))(test (eq ?valoreAsserito alto)) ?albero <- (albero (altezza_max basso|medio)(consistente si)) )
		(and (test (eq ?nomeAttributo altezza))(test (eq ?valoreAsserito medio)) ?albero <- (albero (altezza_max basso)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_foglia)) ?albero <- (albero (tipo_foglia ~?valoreAsserito&~any)(consistente si)) )
        (and (test (eq ?nomeAttributo margine_fogliare)) ?albero <- (albero (margine_fogliare ~?valoreAsserito&~any)(consistente si)) )
        (and (test (eq ?nomeAttributo periodo_fioritura)) ?albero <- (albero (tipo_fiore ~strobilo)(periodo_fioritura $?valori&~any&:(not(member$ ?valoreAsserito ?valori)))(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_fiore)) ?albero <- (albero (tipo_fiore ~?valoreAsserito&~any)(consistente si)) )
        (and (test (eq ?nomeAttributo colore_fiore)) ?albero <- (albero (colore_fiore $?valori&~any&:(not(member$ ?valoreAsserito ?valori)))(consistente si)) )
        (and (test (eq ?nomeAttributo periodo_fruttificazione)) ?albero <- (albero (tipo_frutto ~strobilo)(periodo_fruttificazione $?valori&~any&:(not(member$ ?valoreAsserito ?valori)))(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_frutto)) ?albero <- (albero (tipo_frutto ~?valoreAsserito&~any)(consistente si)) )
        (and (test (eq ?nomeAttributo colore_frutto)) ?albero <- (albero (colore_frutto $?valori&~any&:(not(member$ ?valoreAsserito ?valori)))(consistente si)) )
        (and (test (eq ?nomeAttributo luogo)) ?albero <- (albero (luogo $?valori&~any&:(not(member$ ?valoreAsserito ?valori)))(consistente si)) )
        )
    =>
    (modify ?albero (consistente no))
    )

(defrule elimina_alberi_inconsistenti_alta_montagna
	(declare (salience 9001) (no-loop TRUE))
	(or (fase predizione)(fase ristrutturazione))
	(nuovo_attributo (nome ?nomeAttributo)(valore alta_montagna))
	?albero <- (albero (nome ~betulla&~betulla_verrucosa)(tipo_pianta ~conifera)(consistente si) )
	=>
    (modify ?albero (consistente no))
)

(defrule eliminare_attributo_da_controllare
    (declare(salience 8500))
    (or (fase predizione)(fase ristrutturazione))
    
    ?nuovo_attributo <- (nuovo_attributo)
    =>
    (retract ?nuovo_attributo)
    )

;*******************************************************
;* GESTIONE TERMINAZIONE - determinazione vincitore    *
;*******************************************************

(defglobal ?*delta* = 2
    ?*confidenza_min* = 2)
	
(defrule determina_vincitore
    (declare(salience 8000))
    ?fase <- (fase predizione)
    
    ?candidato <- (albero (nome ?nomeCandidato)(grado_di_confidenza ?confCandidato&:(>= ?confCandidato ?*confidenza_min*))(consistente si))
    (forall (albero (nome ?n&~?nomeCandidato)(consistente si)) ;per ogni albero consistente il cui nome � diverso da ?nomeCandidato
        (albero (nome ?n)(grado_di_confidenza ?c&:(>= (- ?confCandidato ?c) ?*delta*)))) ;la differenza tra ?conf e il grado di confidenza di tale albero dev'essere maggiore di delta
    =>
    (retract ?fase)
    (assert (fase conclusione))
	(assert (Vincitore ?nomeCandidato))
)

(defrule estrai_vincitore
    (declare (salience -4000))
	?fase <- (fase predizione)
    ?candidato <- (albero (nome ?nomeCandidato)(grado_di_confidenza ?confCandidato&:(>= ?confCandidato ?*confidenza_min*))(consistente si))
    (forall (albero (nome ?n&~?nomeCandidato)(consistente si))
        (albero (nome ?n)(grado_di_confidenza ?c&:(>= ?confCandidato ?c))))
    =>
    (retract ?fase)
    (assert (fase conclusione))
	(assert (Vincitore ?nomeCandidato))
)

(defrule albero_non_riconosciuto
    (declare (salience 7000))
    ?fase <- (fase predizione)
    
    (forall (albero (nome ?nome))
        (albero (nome ?nome)(consistente no)))
    =>
    (retract ?fase)
    (assert (fase conclusione))
    (Print U "Albero non riconosciuto")
)

(defrule albero_non_riconosciuto_amen
	(declare (salience -5000))
	?fase <- (fase predizione)

	=>
	(retract ?fase)
	(assert (fase conclusione))
	(Print U "Albero non riconosciuto")
)

;*********************************************
;* GESTIONE TERMINAZIONE - WHY               *
;*********************************************

(defrule inizializza_why
	(declare (salience 7000))
	(fase conclusione)
	(Vincitore ?nomeVincitore)
	(not (exists (why $?)))
	=>
	(assert (why))
)	
(defrule riempi_why
	(declare (salience 6500))
	(fase conclusione)
	(Vincitore ?nomeVincitore)
	?vincitore <- (albero (nome ?nomeVincitore))
    (attributo (nome ?nomeAttributo)(valore ?valoreAsserito&~non_so))
    (or
        (and (test (eq ?nomeAttributo tipo_pianta)) (albero (nome ?nomeVincitore)(tipo_pianta ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo chioma)) (albero (nome ?nomeVincitore) (chioma $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo sempre_verde)) (albero (nome ?nomeVincitore) (sempre_verde ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo altezza)) (albero (nome ?nomeVincitore) (altezza_max ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_foglia)) (albero (nome ?nomeVincitore) (tipo_foglia ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo margine_fogliare)) (albero (nome ?nomeVincitore) (margine_fogliare ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo periodo_fioritura)) (albero (nome ?nomeVincitore) (periodo_fioritura $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_fiore)) (albero (nome ?nomeVincitore) (tipo_fiore ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo colore_fiore)) (albero (nome ?nomeVincitore) (colore_fiore $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo periodo_fruttificazione)) (albero (nome ?nomeVincitore) (periodo_fruttificazione $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo tipo_frutto)) (albero (nome ?nomeVincitore) (tipo_frutto ?valoreAsserito)(consistente si)) )
        (and (test (eq ?nomeAttributo colore_frutto)) (albero (nome ?nomeVincitore) (colore_frutto $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo luogo)) (albero (nome ?nomeVincitore) (luogo $? ?valoreAsserito $?)(consistente si)) )
        (and (test (eq ?nomeAttributo altitudine)) (albero (nome ?nomeVincitore) (altitudine $? ?valoreAsserito $?)(consistente si)) )
    )
	?why <- (why $?risposte&:(not(member$ ?nomeAttributo ?risposte)))
	=>
	(assert (why $?risposte ?nomeAttributo ?valoreAsserito crlf))
	(retract ?why)
)

;*********************************************
;* GESTIONE TERMINAZIONE - altri candidati   *
;*********************************************

(defrule inizializza_lista_altri_alberi
	(declare (salience 6000))
	(fase conclusione)
	(Vincitore ?nomeVincitore)
	(not (exists (altri_candidati $?)))
	=>
	(assert (altri_candidati))
)	
(defrule riempi_altri_candidati
	(declare (salience 5500))
	(fase conclusione)
	(Vincitore ?nomeVincitore)
	(albero (nome ?nomeVincitore)(grado_di_confidenza ?confidenzaVincitore))
    (albero (nome ?nome_altro_candidato&~?nomeVincitore)(grado_di_confidenza ?confidenza_altro_candidato&:(<= (- ?confidenzaVincitore ?confidenza_altro_candidato) ?*delta* ))(consistente si))
    ?altri_candidati <- (altri_candidati $?lista_altri_candidati&:(not(member$ ?nome_altro_candidato ?lista_altri_candidati)))
    =>
    (assert (altri_candidati $?lista_altri_candidati ?nome_altro_candidato crlf ))
    (retract ?altri_candidati)
)

;*********************************************
;* GESTIONE TERMINAZIONE - Stampa vincitore  *
;*********************************************

(defrule stampa_vincitore
	(declare (salience 6000))
	(fase conclusione)
	?vincitore <-(Vincitore ?nomeVincitore)
	(albero (nome ?nomeVincitore)(descrizione_foglia ?descrizioneFoglia)(descrizione_corteccia ?descrizione_corteccia)(fusto ?fusto)(informazioni ?informazioniVincitore))
	?why <- (why $?lista_why)
    ?altri_candidati <- (altri_candidati $?lista_altri_candidati)
	=>
	(Print A (str-cat "Albero: " ?nomeVincitore " @ Info: " ?descrizioneFoglia " " crlf " " ?descrizione_corteccia " " crlf " " ?fusto " " crlf " " ?informazioniVincitore " @ Why: " (implode$ $?lista_why) " @ Altri: " (implode$ $?lista_altri_candidati)))
	(retract ?vincitore)
	(retract ?why)
    (retract ?altri_candidati)
)

;*************************************************
;* RITRATTAZIONE RISPOSTA - LISTA RISPOSTE       *
;*************************************************

(defrule inizializza_lista_risposte
	(declare (salience 5000))
	(fase conclusione)
	(richiesta lista_risposte)
	(not (exists (risposte $?)))
	=>
	(assert (risposte))
)	
(defrule riempi_lista_risposte
	(declare (salience 4500))
	(fase conclusione)
	(richiesta lista_risposte)
	(risposta (nome ?nome_risposta)(valore ?valore_risposta))
	?lista_risposte <- (risposte $?risposte&:(not(member$ ?nome_risposta ?risposte)))
	=>
	(assert (risposte $?risposte ?nome_risposta ?valore_risposta))
	(retract ?lista_risposte)
)
(defrule stampa_lista_risposte
	(declare (salience 4000))
	(fase conclusione)
	?richiesta <- (richiesta lista_risposte)
	?lista_risposte <- (risposte $?risposte)
	=>
	(Print R (implode$ $?risposte))
	(retract ?richiesta)
	(retract ?lista_risposte)
)

;************************************************
;* RITRATTAZIONE RISPOSTE - REINIZIALIZZAZIONE  *
;************************************************

(defrule avvia_fase_reinizializzazione
	?fase <- (fase conclusione)
	(richiesta ritratta_risposta ?nome)
	=>
	(retract ?fase)
	(assert (fase reinizializzazione))
)
(defrule ritratta_risposta
	(declare (salience 2500))
	(fase reinizializzazione)
	(richiesta ritratta_risposta ?nome)
	?risposta <- (risposta (nome ?nome))
	?attributo <-(attributo (nome ?nome))
	=>
	(retract ?risposta)
	(retract ?attributo)
)
(defrule ritratta_risposta_senza_attributo
	(declare (salience 2000))
	(fase reinizializzazione)
	(richiesta ritratta_risposta ?nome)
	?risposta <- (risposta (nome ?nome))
	=>
	(retract ?risposta)
)
(defrule azzera_tutto	
	(declare (salience 1000) (no-loop TRUE))
	(fase reinizializzazione)
	?albero <- (albero)
	=> 
	(modify ?albero (grado_di_confidenza 0)(consistente si))
)

;*****************************************
;* RITRATTA RISPOSTE - RISTRUTTURAZIONE  *
;*****************************************

(defrule avvia_fase_ristrutturazione
	(declare (salience 500))
    ?fase <- (fase reinizializzazione)
	=> 
	(retract ?fase)
	(assert (fase ristrutturazione))
)
(defrule inizializza_lista_attributi
	(declare (salience 5000))
	(fase ristrutturazione)
	(not (exists(attributi_considerati $?)))
	=>
	(assert (attributi_considerati))
)
(defrule simula_domanda
	(declare (salience 4000))
	(fase ristrutturazione)
	(not (exists(nuovo_attributo)))
	(attributo (nome ?nome_attributo)(valore ?valore_attributo)(obbligatorio ?obbligatorieta))
	?attributi_considerati <- (attributi_considerati $?attributi&:(not(member$ ?nome_attributo ?attributi)))
	=>
	(assert (attributi_considerati $?attributi ?nome_attributo))
	(retract ?attributi_considerati)
	(assert (nuovo_attributo(nome ?nome_attributo) (valore ?valore_attributo) (obbligatorio ?obbligatorieta)))
)
(defrule elimina_richiesta_ritratta_risposta
	(declare (salience 3000))
	(fase ristrutturazione)
	?ritratta_risposta <- (richiesta ritratta_risposta $?)
	=>
	(retract ?ritratta_risposta)
)
(defrule concludi_fase_ristrutturazione
	(declare (salience 2000))
	?fase <-(fase ristrutturazione)
	?attributi_considerati <- (attributi_considerati $?)
	=>
	(retract ?fase)
	(retract ?attributi_considerati)
	(assert (fase predizione))
)

;********************************
;* INIZIALIZZAZIONE             *
;********************************

(deffacts fase
    (fase inizializzazione)
)

(defrule init_mese
	(fase inizializzazione)
    =>
    (bind ?x (Domanda "in che mese siamo?" gennaio febbraio marzo aprile maggio giugno luglio agosto settembre ottobre novembre dicembre))
	(assert (attributo (nome mese_attuale)(valore ?x)))
)
(defrule avvia_fase_predizione
	?fase <- (fase inizializzazione)
    (attributo (nome mese_attuale))
	=> 
    (retract ?fase)
	(assert (fase predizione))
)

;******************
;* DOMANDE        *
;******************

;informazioni generali
(defrule sq_altitudine
	(fase predizione)
	(not (exists (risposta (nome altitudine))))
	=>
	(bind ?x (Domanda "A che altitudine ti trovi?" pianura_[meno_di_300_mt] collina_[tra_300_e_600_mt] bassa_montagna_[tra_600_e_1400_mt] alta_montagna_[piu_di_1400_mt] non_so))
	(if (eq ?x pianura_[meno_di_300_mt]) then
		(bind ?x pianura)
	)
	(if (eq ?x collina_[tra_300_e_600_mt]) then
		(bind ?x collina)
	)
	(if (eq ?x bassa_montagna_[tra_600_e_1400_mt]) then
		(bind ?x bassa_montagna)
	)
    (if (eq ?x alta_montagna_[piu_di_1400_mt]) then
        (bind ?x alta_montagna)
    )
	(assert (risposta (nome altitudine)(valore ?x)))
	(assert (attributo (nome altitudine)(valore ?x)(obbligatorio no)))
    (assert (nuovo_attributo (nome altitudine)(valore ?x)(obbligatorio no)))
)

(defrule sq_luogo 
    (fase predizione)
    (not (exists (risposta (nome luogo))))
    =>
    (bind ?x (Domanda "In che luogo ti trovi?" parco strada proprieta_privata zona_industriale campagna foresta non_so))
	(assert (risposta (nome luogo)(valore ?x)))
	(assert (attributo (nome luogo)(valore ?x)(obbligatorio no)))
    (assert (nuovo_attributo (nome luogo)(valore ?x)(obbligatorio no)))
)

;informazioni generali albero

(defrule sq_Chioma
    (fase predizione)
	(not (exists (risposta (nome chioma))))
    =>
    (bind ?x (Domanda "Come e' la forma della chioma dell'albero?" globoso espanso piramidale ovoidale piangente))
	(assert (risposta (nome chioma)(valore ?x)))
	(assert (attributo (nome chioma)(valore ?x)))
    (assert (nuovo_attributo (nome chioma)(valore ?x)))
)

(defrule sq_altezza
	(fase predizione)
	(not (exists (risposta (nome altezza))))
	=>
	(bind ?x (Domanda "Quanto e' alto l'albero?" basso_[da_0_a_15_mt] medio_[da_16_a_30_mt] alto_[maggiore_di_30_mt]))
	(if (eq ?x basso_[da_0_a_15_mt]) then
		(bind ?x basso)
	)
	(if (eq ?x medio_[da_16_a_30_mt]) then
		(bind ?x medio)
	)
	(if (eq ?x alto_[maggiore_di_30_mt]) then
		(bind ?x alto)
	)
	(assert (risposta (nome altezza)(valore ?x)))
	(assert (attributo (nome altezza)(valore ?x)))
    (assert (nuovo_attributo (nome altezza)(valore ?x)))
)

;informazioni sulle foglie dell'albero

(defrule sq_Tipo_foglia ;immagine
    (fase predizione)
	(not (exists (risposta (nome tipo_foglia))))
    =>
    (bind ?x (Domanda "Di che forma e' la foglia?" aghiforme lanceolata ovale tonda pennata triangolare cordata lobata palmata))
    (assert (risposta (nome tipo_foglia)(valore ?x)))
	(assert (attributo (nome tipo_foglia)(valore ?x)))
    (assert (nuovo_attributo (nome tipo_foglia)(valore ?x)))
    )

(defrule q_Margine_fogliare_aghiforme
    (declare (salience 1000))
    (logical (attributo (nome tipo_foglia) (valore aghiforme)))
	(fase predizione)
    (not (exists (risposta (nome margine_fogliare))))
	=>
    (bind ?x (Domanda "Come sono gli aghi?" singoli ciuffi_di_due ciuffi_di_cinque))
	(assert (risposta (nome margine_fogliare)(valore ?x)))
    (assert (attributo (nome margine_fogliare)(valore ?x)))
    (assert (nuovo_attributo (nome margine_fogliare)(valore ?x)))
    )

(defrule q_Margine_fogliare_nonaghiforme
    (declare (salience 1000))
	(logical (attributo (nome tipo_foglia) (valore ~aghiforme)))
    (fase predizione)
	(not (exists (risposta (nome margine_fogliare))))
    =>
    (bind ?x (Domanda "Come e' il margine delle foglie?" intero ciliato ondulato lobato crenato seghettato doppiamente_seghettato dentato))
    (assert (risposta (nome margine_fogliare)(valore ?x)))
	(assert (attributo (nome margine_fogliare)(valore ?x)))
    (assert (nuovo_attributo (nome margine_fogliare)(valore ?x)))
    )

(defrule sq_Caduta_foglie
    (fase predizione)
	(not (exists (risposta (nome caduta_foglie))))
    =>
    (assert (risposta (nome caduta_foglie) (valore (Domanda "L'albero perde le foglie nel corso dell'anno?" si no non_so))))
)

;informazioni su foglie fiori e frutti ---

(defrule sq_PresenzaFiori
    (fase predizione)
    (attributo (nome mese_attuale)(valore ?mese_attuale))
    (not (exists (risposta (nome presenza_fiori))))
	=>
    (bind ?x (Domanda "In questo momento ha i fiori [comprese le pigne]?" si no non_so))
    (assert (risposta (nome presenza_fiori) (valore ?x)))
)

(defrule q_Conosci_fiore
    (declare (salience 1000))
    (fase predizione)
    (risposta (nome presenza_fiori) (valore no|non_so))
	(not (exists (risposta (nome fiore_conosciuto))))
    =>
    (assert (risposta (nome fiore_conosciuto) (valore (Domanda "Conosci il fiore dell'albero?" si no))))
)

(defrule q_Periodo_fioritura
    (declare (salience 1000))
	(logical (risposta (nome fiore_conosciuto) (valore si)))
    (fase predizione)
	(not (exists (risposta (nome periodo_fioritura))))
    =>
    (bind ?x (Domanda "In che mese l'albero fiorisce?" gennaio febbraio marzo aprile maggio giugno luglio agosto settembre ottobre novembre dicembre non_so))
    (assert (risposta (nome periodo_fioritura)(valore ?x)))
	(assert (attributo (nome periodo_fioritura)(valore ?x)))
    (assert (nuovo_attributo (nome periodo_fioritura)(valore ?x)))
    )

(defrule q_Tipo_fiore
    (declare (salience 2000))
	(logical (or (risposta (nome fiore_conosciuto) (valore si)) (risposta (nome presenza_fiori) (valore si))))
    (fase predizione)
	(not (exists (attributo (nome tipo_fiore))))
    =>
    (bind ?x (Domanda "Di che tipo e' il fiore?" strobilo pannocchia grappolo amento ombrella glomerulo fiore_solitario pleiocasio capolino non_so))
    (assert (risposta (nome tipo_fiore)(valore ?x)))
	(assert (attributo (nome tipo_fiore)(valore ?x)))
    (assert (nuovo_attributo (nome tipo_fiore)(valore ?x)))
    )

(defrule q_Colore_fiore
    (declare (salience 1000))
	(logical (or (risposta (nome fiore_conosciuto) (valore si)) (risposta (nome presenza_fiori) (valore si))))
    (fase predizione)
	(not (exists (risposta (nome colore_fiore))))
    =>
    (bind ?x (Domanda "Di che colore sono i fiori?" verde rosso giallo bianco marrone viola non_so))
    (assert (risposta (nome colore_fiore)(valore ?x)))
	(assert (attributo (nome colore_fiore)(valore ?x)))
    (assert (nuovo_attributo (nome colore_fiore)(valore ?x)))
    )

(defrule sq_PresenzaFrutti
    (fase predizione)
    (attributo (nome mese_attuale)(valore ?mese_attuale))
    (not (exists (risposta (nome presenza_frutti))))
	=>
    (bind ?x (Domanda "In questo momento ha i frutti [comprese le pigne]?" si no non_so))
    (assert (risposta (nome presenza_frutti) (valore ?x)))
    )

(defrule q_Conosci_frutto
    (declare (salience 1000))
    (fase predizione)
    (risposta (nome presenzaFrutti) (valore no|non_so))
	(not (exists (risposta (nome frutto_conosciuto))))
    =>
    (assert (risposta (nome frutto_conosciuto)(valore (Domanda "Conosci il frutto dell'albero?" si no))))
    )

(defrule q_Periodo_fruttificazione
    (declare (salience 1000))
	(logical (risposta (nome frutto_conosciuto) (valore si)))
    (fase predizione)
	(not (exists (attributo (nome periodo_fruttificazione))))
    =>
    (bind ?x (Domanda "In che mese l'albero ha i frutti?" gennaio febbraio marzo aprile maggio giugno luglio agosto settembre ottobre novembre dicembre non_so))
    (assert (risposta (nome periodo_fruttificazione)(valore ?x)))
	(assert (attributo (nome periodo_fruttificazione)(valore ?x)))
    (assert (nuovo_attributo (nome periodo_fruttificazione)(valore ?x)))
    )

(defrule q_Tipo_frutto
    (declare (salience 2000))
	(logical (or (risposta (nome frutto_conosciuto) (valore si)) (risposta (nome presenza_frutti) (valore si))))
    (fase predizione)
    (not (exists (attributo (nome tipo_frutto))))
	=>
    (bind ?x (Domanda "Di che tipo e' il frutto?" strobilo schizocarpio drupa samara-disamara capsula noce pomo bacca siconio non_so))
    (assert (risposta (nome tipo_frutto)(valore ?x)))
	(assert (attributo (nome tipo_frutto)(valore ?x)))
    (assert (nuovo_attributo (nome tipo_frutto)(valore ?x)))
    )

(defrule q_Colore_frutto
    (declare (salience 1000))
	(logical (or (risposta (nome frutto_conosciuto) (valore si)) (risposta (nome presenza_frutti) (valore si))))
    (fase predizione)
	(not (exists (risposta (nome colore_frutto))))
    =>
    (bind ?x (Domanda "Di che colore sono i frutti?" verde rosso giallo nero arancione bianco marrone viola non_so))
    (assert (risposta (nome colore_frutto)(valore ?x)))
	(assert (attributo (nome colore_frutto)(valore ?x)))
    (assert (nuovo_attributo (nome colore_frutto)(valore ?x)))
    )
	
;*****************************
;* ASSERZIONI AUTOMATICHE    *
;*****************************

(defrule a_SempreVerdeSi
    (declare (salience 10000))
    (logical (risposta (nome caduta_foglie)(valore no)))
	(not (exists (attributo (nome sempre_verde))))
    =>
    (assert (attributo (nome sempre_verde) (valore si)))
	(assert (nuovo_attributo (nome sempre_verde) (valore si)))
)
(defrule a_SempreVerdeNo
    (declare (salience 10000))
    (logical (risposta (nome caduta_foglie)(valore si)))
    (not (exists (attributo (nome sempre_verde))))
	=>
    (assert(attributo (nome sempre_verde) (valore no)))
	(assert(nuovo_attributo (nome sempre_verde) (valore no)))
)
(defrule a_PresenzaFiori_helper 
	(declare (salience 10000))
	(logical (risposta (nome presenza_fiori) (valore si)))
	(attributo (nome mese_attuale)(valore ?mese_attuale))
	=>
	(assert (attributo (nome periodo_fioritura)(valore ?mese_attuale)))
    (assert (nuovo_attributo (nome periodo_fioritura)(valore ?mese_attuale)))
)
(defrule a_PresenzaFrutti_helper 
	(declare (salience 10000))
	(logical (risposta (nome presenza_frutti) (valore si)))
	(attributo (nome mese_attuale)(valore ?mese_attuale))
	=>
	(assert (attributo (nome periodo_fruttificazione)(valore ?mese_attuale)))
    (assert (nuovo_attributo (nome periodo_fruttificazione)(valore ?mese_attuale)))
)
