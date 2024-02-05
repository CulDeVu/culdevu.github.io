(include "generator.scm")

(define lesson-number 2)

(define sim01
    (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1))))
(define sim02
    (sim (make-sim-spawn (make-sim-object 2 1 -2) (make-sim-object 1 0 1))))
(define sim03
    (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 2 0 1))))

(define page
    (lesson lesson-number 
        (para "I'd like to start analyzing some simple simulations. I'm a visual person, so I say we start graphing things. But what should we graph?")

        sim-loop-code-sm

        (para "Well there's only a handful of piece of information in this loop.")

        (para "Each object has a mass, but those don't change over the course of the simulation. Clearly, because the simulation loop from a couple slides ago doesn't have a line saying \"mass += something\".")

        (para "The quantities that do change are time, the force being felt by each object, each object's position, and each object's velocity. So to start, I suggest that we just graph each of the major variables by every other major variable. There's only 4:")

        (ulist
            "time"
            "force"
            "velocity"
            "position")

        (para "So after removing duplicates, that's just 6 graphs:")

        (ulist
            "force / time"
            "position / time"
            "velocity / time"
            "force / position"
            "force / velocity"
            "position / velocity")

        (heading "force / time")

        (option
            (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-time-history get-force-history))
            (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-time-history get-force-history))
            (sxs (sim-vis sim03) (sim-graphs-2 sim03 get-time-history get-force-history))
            )

        (para "First up is force/time. Notice how, in all 3, the graphs for the left and right ball have perfect vertical symmetry. Hopefully that should make sense: at every timestep forces are always equal and opposite. At any given timestamp, whatever force the right object feels, the left feels but negative.")

        (para "Another interesting difference between the graphs is that some are shifted to the left. The reason is because we represent mass with the radius of the balls in these simulations. So in the simulations where there is a larger ball, it has a larger radius, and so they end up colliding sooner. So this is kind of a silly difference.")

        (para "A more interesting difference is that in some of the simulations the \"base\", the amount of the x-axis where the graph lifts off, is wider. We might talk about that later on.")

        (heading "position / time")

        (option
            (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-time-history get-pos-history))
            (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-time-history get-pos-history))
            (sxs (sim-vis sim03) (sim-graphs-2 sim03 get-time-history get-pos-history))
            )

        (para "Not much to say here, except notice the weird kind of diagonal almost-symmetry these graphs have.")

        ; TODO: add something about "I would like to point out, in the moments where the objects feel no force these graphs look like straight lines. That's what happens when an object has a constant velocity. And those straight lines are connected by smooth curves."
        ; Also, maybe bring up how the bend has different levels of "sharpness"

        (heading "velocity / time")

        (option
            (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-time-history get-vel-history))
            (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-time-history get-vel-history))
            (sxs (sim-vis sim03) (sim-graphs-2 sim03 get-time-history get-vel-history))
            )

        (para "We're going to be talking about this one extensively very soon, so I'll hold off on this one.")

        (heading "force / position")

        (option
            (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-pos-history get-force-history))
            (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-pos-history get-force-history))
            (sxs (sim-vis sim03) (sim-graphs-2 sim03 get-pos-history get-force-history))
            )

        (para "Again, we're going to be talking about this one very soon, so I'll hold off.")

        (para "The only thing I wanted to say is to notice that in that last one, the graph doubles back on itself! The x-axis cooresponds to the balls' positions, and the balls can turn around and move backwards.")

        (heading "force / velocity")

        (option
            (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-vel-history get-force-history))
            (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-vel-history get-force-history))
            (sxs (sim-vis sim03) (sim-graphs-2 sim03 get-vel-history get-force-history))
            )

        (para "Again, not much to say, except cool symmetry.")

        (heading "velocity / position")

        (option
            (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-pos-history get-vel-history))
            (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-pos-history get-vel-history))
            (sxs (sim-vis sim03) (sim-graphs-2 sim03 get-pos-history get-vel-history))
            )

        (para "Not much to say, except cool almost-symmetry.")

        (para "Changelog:")
        (ulist
            "2024 Jan 30: Initial publish")
        
        ))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string page file)
        (put-string file page)
        (close-port file)))
