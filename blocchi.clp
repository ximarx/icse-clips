


(deftemplate sopra-a "sposta un blocco sopra un altro"
	(slot sopra)
	(slot sotto)
) 

(deftemplate obiettivo "rappresenta una volonta'"
	(slot sposta)
	(slot sopra-a)
)

;=======================================================
; volonta: spostare un blocco 1 sopra un blocco 2
; blocco 1 libero
; blocco 2 libero
; blocco 1 sopra blocco 3
; =>
; sposta blocco 1 su blocco 2

(defrule sposta "sposta un blocco libero su un altro blocco libero"
	?obiettivo <- (obiettivo (sposta ?blocco1) (sopra-a ?blocco2))
	(blocco ?blocco1)
	(blocco ?blocco2)
	(sopra-a (sopra niente) (sotto ?blocco1))
	?pila1 <- (sopra-a (sopra ?blocco1) (sotto ?blocco3))
	?pila2 <- (sopra-a (sopra niente) (sotto ?blocco2))
=>
	(retract ?obiettivo)
	(retract ?pila1)
	(retract ?pila2)
	(assert (sopra-a (sopra ?blocco1) (sotto ?blocco2)))
	(assert (sopra-a (sopra niente) (sotto ?blocco3)))
	(printout t "Sposto " ?blocco1 " sopra " ?blocco2 "." crlf)
)

;=======================================================
;volonta: spostare un blocco libero sul piano
; blocco 1 libero
; blocco 1 sopra blocco 2
; =>
; sposta blocco 1 su piano
; sopra niente sotto blocco 2

(defrule sposta-sul-piano "sposta un blocco libero (sopra un altro blocco) sul piano"
	?obiettivo <- (obiettivo (sposta ?blocco1) (sopra-a piano))
	(blocco ?blocco1)
	(blocco ?blocco2)
	(sopra-a (sopra niente) (sotto ?blocco1)) ; e' libero
	?pila <- (sopra-a (sopra ?blocco1) (sotto ?blocco2))
=>
	(retract ?obiettivo)
	(retract ?pila)
	(assert (sopra-a (sopra ?blocco1) (sotto piano)))
	(assert (sopra-a (sopra niente) (sotto ?blocco2)))
	(printout t "Sposto " ?blocco1 " sopra il piano" crlf)
)


;=======================================================
; volonta: stabilire l'obiettivo di liberare il blocco di partenza
;  obiettivo spostare blocco 1 su blocco x
;  blocco 2 sopra blocco 1
; =>
; spostare blocco 2 su piano
(defrule libera-blocco-partenza "comunica l'intenzione di liberare il blocco di partenza"
	?obiettivo <- (obiettivo (sposta ?blocco1) (sopra-a ?))
	(blocco ?blocco1)
	(blocco ?blocco2)
	(sopra-a (sopra ?blocco2) (sotto ?blocco1)) ; blocco 2 sopra blocco1
=>
	(assert (obiettivo (sposta ?blocco2) (sopra-a piano)))
)


;=======================================================
; volonta: stabilire l'obiettivo di liberare il blocco di arrivo
;  obiettivo spostare blocco 1 su blocco 2
;  blocco 3 sopra blocco 2
; =>
;  stabilire intenzione di spostare blocco 3 sopra il piano
(defrule libera-blocco-arrivo "comunica l'intenzione di liberare il blocco di arrivo"
	?obiettivo <- (obiettivo (sposta ?) (sopra-a ?blocco2))
	(blocco ?blocco2)
	(blocco ?blocco3)
	(sopra-a (sopra ?blocco3) (sotto ?blocco2)) ; blocco 3 sopra blocco 2
=>
	(assert (obiettivo (sposta ?blocco3) (sopra-a piano)))
)


;=======================================================
; FATTI

(deffacts stato-iniziale "A/B/C D/E/F, voglia mettere C su F"
	(blocco A)
	(blocco B)
	(blocco C)
	(blocco D)
	(blocco E)
	(blocco F)
	(sopra-a (sopra niente) (sotto A))
	(sopra-a (sopra A) (sotto B))
	(sopra-a (sopra B) (sotto C))
	(sopra-a (sopra C) (sotto piano))
	(sopra-a (sopra niente) (sotto D))
	(sopra-a (sopra D) (sotto E))
	(sopra-a (sopra E) (sotto F))
	(sopra-a (sopra F) (sotto piano))
	(obiettivo (sposta C) (sopra-a F))
)











