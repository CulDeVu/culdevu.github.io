(include "generator.scm")

(define lesson-number 3)

(define sim01
    (sim (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0))

(define sim-dt-1
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 1))
(define sim-dt-4
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 (/ 1 4)))
(define sim-dt-16
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 (/ 1 16)))
(define sim-dt-32
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 (/ 1 32)))
(define sim-dt-128
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 (/ 1 128)))
(define sim-dt-512
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 (/ 1 512)))
(define sim-dt-2048
    (sim-with-dt (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0 (/ 1 2048)))

(define lesson1
    (lesson lesson-number

        (para "Wow, this is a weird spot for this chapter, huh? Eh, whatever.")

        (para "Calculus is *extremely* important to the study of physics. It's foundational to the subject. Unfortunately it's a large and long subject to teach, so we won't really be covering it. If you're interested in learning calculus, there's like a billion sites on the internet that will teach you it, go find one.")

        (para "Instead, I'm going to be giving a break-neck overview of the important bits for us.")

        (para "Let's recall the simulation loop we'll be working with:")

        sim-loop-code-sm

        (para "There are 2 important constructs that are studied in calculus: the derivative and the integral. But we're only really going to be talking about integrals.")

        (heading "The integral")

        (para "For us, integrals look like this:")

        (bmath '(sum k T1 T2 (* (mt quantity k) (mt dother-quantity k))))

        (para "Meaning, summing up, for every timestamp between time T1 and T2, the product of some quantity and the \"d\" form of some other quantity. The values are subscripted, meaning that, for each timestamp, we're using the quanties as they were *at that timestamp*, and then moving on to the next timestamp.")

        (para "An example:")

        (bmath '(sum k T1 T2 (* (mt force k) (mt dpos k))))

        (para "Here's another one, this time using \"dforce\". That isn't present in the loop above but it means the same thing, the change in force between each successive timestamp:")

        (bmath '(sum k T1 T2 (* (+ (mt force k) (mt velocity k)) (mt dforce k))))

        (para "Another one, where I don't subscript dt because it's the same at every timestamp:")

        (bmath '(sum k T1 T2 (* (mt velocity k) dt)))

        (para "We've seen this last integral already, actually. This is just lines 4 and 5 of the simulation loop above! An object's position is just the sum of the velocity at each timestamp, times dt:")

        (bmath '(= (mt position T2) (+ (mt position (- T1 1)) (sum k T1 T2 (* (mt velocity k) dt)))))

        (para "There are a few things to know about integrals.")

        (heading "Convergence")

        (para "The two integrals that are present in the simulation loop, the one for velocity and the one for position, they both *converge*. Every time you make dt smaller, the values of velocity and position \"settle further into\" their final value.")

        ; TODO: a table showing convergence

        (sxs
            (sim-vis sim01)
            (table
                (table-row
                    "dt" "position of left ball at t=2")
                (table-row
                    "dt = 1" (number->string (get-sim-object-pos (car (index sim-dt-1 4)))))
                (table-row
                    "dt=1/4" (number->string (get-sim-object-pos (car (index sim-dt-4 16)))))
                (table-row
                    "dt=1/16" (number->string (get-sim-object-pos (car (index sim-dt-16 32)))))
                (table-row
                    "dt=1/32" (number->string (get-sim-object-pos (car (index sim-dt-32 128)))))
                (table-row
                    "dt=1/128" (number->string (get-sim-object-pos (car (index sim-dt-128 512)))))
                (table-row
                    "dt=1/512" (number->string (get-sim-object-pos (car (index sim-dt-512 2048)))))
                (table-row
                    "dt=1/2048" (number->string (get-sim-object-pos (car (index sim-dt-2048 8192)))))
                ))

        (para "The other two integrals that I listed above as examples also converge. The conditions for convergence are a bit touchy, but here's the general idea:")

        (ulist
            "Your typical math operations, like +, *, sqrt and such on convergent quantities are themselves convergent."
            "The \"integrand\", the non-d-term, itself needs to be convergent, and needs to stay finite for the duration of the integral (believe it or not this can be an issue). "
            "The \"differential\", the d-term, needs to get arbitrarily small as dt gets brought closer to 0. Given any threshold, there needs to be a value of dt that causes all of the differentials to fall under the threshold. A differential of a quantity that is itself the result of an integral automatically satisfies this condition.")

        (para "There's some more subtlety to it, but this should be good enough for us. If you're interested in learning more, the subject is usually called \"Real Analysis\" or some variant of \"Modern Calculus\" in textbooks and college courses.")

        (heading "Antiderivaties")

        (para "Another big thing to know about integrals is that they have something called \"antiderivatives\". Essentially, if an integral is convergent, the exists a function, that we'll call U here, that satisfies:")

        (bmath '(lim (sum k T1 T2 (* quantity dother-quantity)) (- (fun U T2) (fun U T1))))

        (para "U here is called an antiderivative. What form exactly U takes is difficult to determine. A large part of a calculus course involves learning tricks to let you figure out what U is given the integrand and differential.")

        (para "The weird arrow thing is trying to convey that the left-hand side will converge to the right-hand side as dt gets smaller.")

        (para "One important thing for us to know is that the form that U takes depends ONLY on the choice of integrand and differential, NOT the choice of upper and lower bounds T1 and T2.")

        (para "The other important property is best shown through an example. If, say, the differential is dvel, and the integrand is some expression involving ONLY velocity, then there exists a form of the antiderivative that can be expressed as the difference between a function evaluated at the velocity at the beginning and end timestamps. So as a concrete example:")

        (bmath '(lim (sum k T1 T2 (* (^ velocity 2) dvel)) (- (mparen (* (/ 1 3) (^ (mt velocity T2) 3))) (mparen (* (/ 1 3) (^ (mt velocity T1) 3))))))

        (para "I don't really want to get into why they're called antiderivatives.")

        ; TODO: the area formulation of integrals
        ; TODO: left and right endpoint formulations

        (heading "Areas under graphs")

        (para "An important interpretation of integrals is as describing the area under a graph:")

        (sim-graphs-integral-dt-right sim-dt-4 get-time-2-history-temp-4 get-force-history (/ 1 4))
        (sim-graphs-integral-dt-right sim-dt-16 get-time-2-history-temp-16 get-force-history (/ 1 16))

        (para "The idea is that you can approximate the area under a graph with a bunch of thin rectangles and adding up their area, and it can be made more accurate by making the rectangles thinner. Again, if you don't get this, there are other places online that will teach you calculus.")

        (para "The integral that we outlined above corresponds to the right-point formulation of the area under the graph. The integrand is the height of the graph at a particular timestamp, and the differential is the distance between that timestamp and the previous one.")

        (para "Another thing you learn in a calculus class is that other formulations, like the midpoint or trapezoidal formulations, will also converge to the same value. Here's the left-point formulation:")
        
        (sim-graphs-integral-dt-left sim-dt-16 get-time-2-history-temp-16 get-force-history (/ 1 16))

        (para "This corresponds to the integral:")

        (bmath '(sum k T1 T2 (* (mt quantity k) (mt dother-quantity (+ k 1)))))

        (para "Something that's rarely taught in school is that it's perfectly fine to offset in the other direction:")

        (sim-graphs-integral-dt-double-right sim-dt-16 get-time-2-history-temp-16 get-force-history (/ 1 16))

        (para "Which corresponds to the integral:")

        (bmath '(sum k T1 T2 (* (mt quantity (+ k 1)) (mt dother-quantity k))))

        (para "I'm not sure if this one has a name. But we'll be using it in a couple lessons, so I guess I'll call this one the double-right-point formulation. It's sort of offset from the actual graph by a little bit, but as dt get smaller the difference converges to 0.")
        ))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string lesson1 file)
        (put-string file lesson1)
        (close-port file)))
