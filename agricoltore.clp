(clear)

(deffacts stato-iniziale "Stato iniziale"
	(serve-acquisizione agricoltore)
	(serve-acquisizione lupo)
	(serve-acquisizione cavolo)
	(serve-acquisizione pecora)
)


(defrule mostra-goal "Mostra il goal"
	(declare (salience 1000))
	(su-riva agricoltore lontana)
	(su-riva pecora lontana)
	(su-riva lupo lontana)
	(su-riva cavolo lontana)
=>
	(printout t "Hai raggiunto il goal. Vuoi giocare di nuovo (S/N)" crlf)
	(bind ?risposta (read))
	(if (or (eq ?risposta S) (eq ?risposta s)) 
		then 
			(reset)
		else
			(printout t crlf crlf crlf "------------------" crlf)
			(exit)
	)
)

(defrule acquisizione "Acquisisce lo stato da tastiera"
	(declare (salience 1000))
	(not (su-riva ? ?))
=>
	(printout t "--- Gioco dell'agricoltore ---" crlf)
	(printout t "Immetti lo stato iniziale per cortesia" crlf)
	(assert (acquisizione))
)

(defrule aquisizione-elemento "Acquisisce l'agricoltore fino a quando il valore immesso non sara' corretto"
	(declare (salience 900))
	?serve <- (serve-acquisizione ?elemento)
	(not (su-riva ?elemento ?))
=>
	(printout t "Indica la posizione di " ?elemento ": ([v]icina/[l]ontana)" crlf)
	(bind ?risposta (read))
	(if (or (eq ?risposta v) (eq ?risposta vicina)) 
		then 
			(assert (su-riva ?elemento vicina))
			(retract ?serve)
		else 
			(if (or (eq ?risposta l) (eq ?risposta lontana))
				then
					(assert (su-riva ?elemento lontana))
					(retract ?serve)
				else
					(printout t "Il valore immesso non e' valido!" crlf)
					;(retract ?serve)
					;(assert (serve-acquisizione ?elemento))
					(refresh aquisizione-elemento)
			)
	)
)

(defrule rimozione-fase-acquisizione "Avvia il gioco"
	?acquisizione <- (acquisizione)
	(not (serve-acquisizione ?))
=>
	(retract ?acquisizione)
)

(defrule torna-agricoltore-solo
	?agricoltore <- (su-riva agricoltore lontana)
	(and
		(not
			(and
				(su-riva pecora lontana)
				(su-riva cavolo lontana)
				(su-riva lupo vicina)
			)
		)
		(not
			(and
				(su-riva lupo lontana)
				(su-riva pecora lontana)
				(su-riva cavolo vicina)
			)
		)
	)
=>
	(retract ?agricoltore)
	(assert (su-riva agricoltore vicina))
	(printout t "Sposto agricoltore vicino" crlf)
)

(defrule torna-agricoltore-con-pecora
	?agricoltore <- (su-riva agricoltore lontana)
	?pecora <- (su-riva pecora lontana)
	(or
		(and
			(su-riva lupo lontana)
			(su-riva ? vicina)
		)
		(and
			(su-riva cavolo lontana)
			(su-riva ? vicina)
		)
	)
=>	
	(retract ?agricoltore)
	(assert (su-riva agricoltore vicina))
	(retract ?pecora)
	(assert (su-riva pecora vicina))
	(printout t "Sposto agricoltore e pecora vicino" crlf)
)

		 
(defrule manda-pecora-iniziale
	?agricoltore <- (su-riva agricoltore vicina)
	?pecora <- (su-riva pecora vicina)
	(su-riva lupo vicina)
	(su-riva cavolo vicina)
=>
	(retract ?agricoltore)
	(assert (su-riva agricoltore lontana))
	(retract ?pecora)
	(assert (su-riva pecora lontana))
	(printout t "Sposto agricoltore e pecora lontano" crlf)
)


(defrule manda-lupo
	?agricoltore <- (su-riva agricoltore vicina)
	?lupo <- (su-riva lupo vicina)
	(su-riva pecora lontana)
	(su-riva cavolo vicina)
=>
	(retract ?agricoltore)
	(assert (su-riva agricoltore lontana))
	(retract ?lupo)
	(assert (su-riva lupo lontana))
	(printout t "Sposto agricoltore e lupo lontano" crlf)
)

(defrule manda-cavolo
	?agricoltore <- (su-riva agricoltore vicina)
	?cavolo <- (su-riva cavolo vicina)
	(su-riva lupo lontana)
=>
	(retract ?agricoltore)
	(assert (su-riva agricoltore lontana))
	(retract ?cavolo)
	(assert (su-riva cavolo lontana))
	(printout t "Sposto agricoltore e cavolo lontano" crlf)
)	


(defrule manda-pecora-finale
	?agricoltore <- (su-riva agricoltore vicina)
	?pecora <- (su-riva pecora vicina)
	(su-riva ?op1 lontana)
	(su-riva ~?op1 lontana)
=>
	(retract ?agricoltore)
	(assert (su-riva agricoltore lontana))
	(assert (su-riva pecora lontana))
	(printout t "Sposto agricoltore e pecora lontano" crlf)
)

(defrule manda-agricoltore-solo
	?agricoltore <- (su-riva agricoltore vicina)
	(not (su-riva ~agricoltore vicina))
=>
	(retract ?agricoltore)
	(assert (su-riva agricoltore lontana))
	(printout t "Sposto agricoltore lontano" crlf)
)

(defrule controllo-condizione-errata-pecora-cavolo "Controlla se una condizione e' errata e la corregge"
	(declare (salience 1100))
	(su-riva pecora ?riva)
	(su-riva cavolo ?riva)
	(su-riva agricoltore ~?riva)
	(su-riva lupo ~?riva)
=>
	(printout t "Complimenti: la pecora ha mangiato il cavolo......" crlf)
	(printout t "Ricominciamo..." crlf)
	(reset)
)

(defrule controllo-condizione-errata-pecora-lupo "Controlla se una condizione e' errata e la corregge"
	(declare (salience 1100))
	(su-riva pecora ?riva)
	(su-riva lupo ?riva)
	(su-riva agricoltore ~?riva)
	(su-riva cavolo ~?riva)
=>
	(printout t "Complimenti: il lupo ha mangiato la pecora......" crlf)
	(printout t "Ricominciamo..." crlf)
	(reset)
)

;(batch "/home/ximarx/git/icse-clips/agricoltore.clp")

(reset)

(printout t crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf crlf)

(run)
