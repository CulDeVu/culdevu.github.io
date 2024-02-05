(include "generator.scm")

(define lesson-number 6)

(define sim01
    (sim (make-sim-spawn (make-sim-object 1 (vec 1 1) (vec -2.5 -2)) (make-sim-object 1 (vec 0 0) (vec 0 0))))) 
; (define sim02
;     (sim (make-sim-spawn (make-sim-object 2 1 -2) (make-sim-object 1 0 1))))
; (define sim03
;     (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 2 0 1))))

(define lesson3
	(lesson lesson-number
		(para "Let's return to a familiar simulation.")

		(sim-vis sim01)

		(para "I want to talk about its force/position graph.")

		(sim-graph sim01 get-time-history get-vel-history)

		(heading "Conservation of momentum in 2D")

		(heading "Conservation of kinetic energy in 2D")

		(para "Changelog:")
        (ulist
            "2024 Feb 4: Initial publish")

		))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string lesson1 file)
        (put-string file lesson3)
        (close-port file)))