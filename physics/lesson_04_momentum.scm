
(include "generator.scm")

(define lesson-number 4)

(define sim01
    (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1))))
(define sim02
    (sim (make-sim-spawn (make-sim-object 2 1 -2) (make-sim-object 1 0 1))))
(define sim03
    (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 2 0 1))))

(define sim-multi
    (sim (make-sim-spawn (make-sim-object 1 0.75 -3) (make-sim-object 2 0 0) (make-sim-object 2 -1 4))))

(define lesson2
    (lesson lesson-number
        (para "I want to analyze the velocity/time graphs of our simulations.")

        (sxs (sim-vis sim01) (sim-graphs-2 sim01 get-time-history get-vel-history))

        (para "There is another VERY clear line of symmetry here. But it's maybe not super obvious *why* this one is symmetric.")

        (para "Before moving on from these three graphs, I want to run another simulation, same situation, but now the left ball has twice as much mass. Remember from before, the role of mass in an interaction with forces is that they respond less to the same force than objects with less mass.")

        (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-time-history get-vel-history))

        (para "The symmetry is still *kinda* there. It's reminiscent of the reflectional symmetry we had. But not quite. I want to talk about this.")

        sim-loop-code-sm

        (para "To explain this, let's go back to the simulation loop.")

        (para "What I want to draw your attention to is line 2, \"dvel = force / mass * dt\". Rearranging this line gives \"dvel * mass = force * dt\". We know that dt is the same for each timestep and for each object, and we know that at each timestep the force between the objects are equal and opposite in sign. So that means, at each timestep the quantities \"dvel * mass\" are going to be equal and opposite in sign.")

        (sim-graphs-2 sim02 get-time-history get-p-history)

        (para "And, sure enough, if I scale the velocity/time graph by each object's mass, the symmetry comes back.")

        (heading "Conservation of momentum")

        (para "Just to write it out, for every timestamp k:")

        (bmath
            '(= (mt (ball1 force) k) (- (mt (ball2 force) k)))
            '(= (* (mt (ball1 force) k) dt) (- (* (mt (ball2 force) k) dt)))
            '(= (* (mt (ball1 dvel) k) (ball1 mass)) (- (* (mt (ball2 dvel) k) (ball2 mass))))
            )

        (para "This is true at every timestamp, but you don't see us graphing mass * dvel above. That's because the \"d\" terms are pretty uninteresting to graph: they converge to zero as dt gets small. So whenever we notice something like this we almost always want to translate it into macro-terms.")

        (para "To do that, we'll use the fact that the macro-term velocity is just the sum of lots of dvels:")

        (bmath
            '(= (mt velocity T2) (+ (mt velocity T1) (sum k (+ T1 dt) T2 (mt dvel k))))
            )

        (para ", to conclude:")

        (bmath
            '(= (sum k (+ T1 dt) T2 (* (ball1 mass) (mt (ball1 dvel) k))) (sum k (+ T1 dt) T2 (* (ball2 mass) (mt (ball2 dvel) k))))
            '(= (* (ball1 mass) (- (mt (ball1 velocity) T2) (mt (ball1 velocity) T1))) (* (ball2 mass) (- (mt (ball2 velocity) T2) (mt (ball2 velocity) T1))))
            )

        (para "If on one timestep, mass * dvel increases for the red ball by 8, it must decrease for the blue ball by 8. And if on the next timestep it increases for the red ball by 2, it must decrease for the blue ball by 2. And so therefore, over the course of two consecutive timesteps, mass * dvel increases for the red ball by 10, and decreases for the blue ball by 10. So these quantities are equal and opposite not just for single timesteps, but for larger spans of time as well!")

        (para "So that's where the mass * velocity graph's symmetry comes from.")

        (sxs (sim-vis sim02) (sim-graphs-2 sim02 get-time-history get-p-history))

        ; (bmath 
        ;     '(+ (sum k T1 T2 (* (ball1 mass) (mt (ball1 dvel) k))) (sum k T1 T2 (* (ball2 mass) (mt (ball2 dvel) k))))
        ;     '(+ (sum k T1 T2 (* (ball1 mass) (/ (mt (ball1 force) k) (ball1 mass)) dt)) (sum k T1 T2 (* (ball2 mass) (/ (mt (ball2 force) k) (ball2 mass)) dt)))
        ;     '(+ (sum k T1 T2 (* (mt (ball1 force) k) dt)) (sum k T1 T2 (* (mt (ball2 force) k) dt)))
        ;     '(sum k T1 T2 (* (+ (mt (ball1 force) k) (mt (ball2 force) k)) dt))
        ;     0
        ;     )

        (para "The labels on these graphs probably gave it away, but this quantity, mass * velocity, is important enough to have a name: momentum.")

        (bmath '(= momentum (* mass velocity)))

        (para "And this symmetry that you're seeing here also has a name: conservation of momentum.")

        (bmath
            '(= (- (mt (ball1 momentum) T2) (mt (ball1 momentum) T1)) (- (mt (ball2 momentum) T2) (mt (ball2 momentum) T1)))
            )

        (para "This name reflects a different way of looking at all this. Instead of the two mass * dvel's being equal and opposite, the traditional way of writing it is that they add to 0:")

        (bmath
            '(= (* (ball1 mass) (ball1 dvel)) (- (* (ball2 mass) (ball2 dvel))))
            '(= (+ (* (ball1 mass) (ball1 dvel)) (* (ball2 mass) (ball2 dvel))) 0)
            )

        (para "And the traditional way of looking at the momentum equations it is that between two time points, whatever momentum is lost by one object is gained by the other. So the total momentum felt by all of the objects, the sum of all of their momentums, is constant.")

        (bmath
            '(= (- (mt (ball1 momentum) T2) (mt (ball1 momentum) T1)) (- (mt (ball2 momentum) T2) (mt (ball2 momentum) T1)))
            '(= (+ (mt (ball1 momentum) T1) (mt (ball2 momentum) T1)) (+ (mt (ball1 momentum) T2) (mt (ball2 momentum) T2)))
            )

        ; (para "[flip back a slide]I want to dwell on this for a bit more. Let's ignore all of these \"mass *\" bits for now. The velocity of an object at, say, timestep 100, is going to be equal to that object's initial velocity plus its first dvel, plus its second dvel, and so on. Right? So if you multiply both sides of this equation by that object's mass, they should still be equal. But we also know that, whatever the \"mass * dvel 0\" of the blue object is, the \"mass * dvel 0\" of the red object is going to be equal and opposite. Same for \"mass * dvel 1\", and so on. So since each of these \"mass * dvel\"s are equal and opposite for the two objects, all of their sums are equal and opposite.")

        ; (para "So if you were to, say, add the blue ball's momentum at timestep 100 and the red ball's momentum at timestep 100, it would be equal to: the blue ball's momentum at time 0, plus the red ball's momentum at time 0, plus a whole bunch of terms that end up cancelling out! So that's what conservation of momentum is: the sum of the momentums of the red and blue ball are going to be the same at every timestep.")

        (heading "3 objects")

        (para "So that's pretty cool and all, but so far in these last couple lessons we've only talked about pairs of objects. What happens if we throw in another one? Here we have 3 balls in play, with varying masses, colliding with each other:")

        (sim-vis sim-multi)

        ; (para "We'll start out simple. Here the 3 balls undergo 3 distinct collisions: first from " (car svg-colors) "/" (cadr svg-colors) ", then from " (cadr svg-colors) "/" (caddr svg-colors) ". So let's look at our graphs.")

        ; (para "[3 balls same mass graphs]So here are the 3 graphs again, force/time, position/time and velocity/time. In the first graph, you can very clearly see the 3 collisions. Notice how they're different sizes. The middle one is much taller than the other two. This is because during this collision both balls are moving towards each other, whereas in first and last collision one of the balls was stationary. This means that for the second collision the objects were able to squeeze much closer together, and feel a larger force.")

        ; (para "For the position/time graph, you can again see 3 collisions clearly. The collisions are nice curves while the time inbetween are straight lines.")

        ; (para "For the velocity/time graph, you can see how during each collision they swap velocities, just like they did in the first simulation we looked at.")

        ; (para "[3 balls different masses]Okay, well what about the case when the collisions aren't distinct? What happens when they're all happening at once? Remember what I said earlier about forces adding. The red object is feeling the force of collision from *both* the blue and green objects, whereas the blue and green objects are just feeling the forces from the red one.")

        (sxs (sim-graphs-2 sim-multi get-time-history get-vel-history) (sim-graphs-2 sim-multi get-time-history get-p-history))

        ; (para "And the graphs again. The force/time graph is now all muddied, there's no clear dilineation between the collisions. But, if you look closely, it's still sort of balanced. And that's correct! At every timestamp, every pair of objects share and equal and opposite force. But that also means that the sums of their forces is 0, and that the sums of the forces of all pairs of objects together is also 0! So this force graph should always be balanced around 0.")

        ; (para "Instead of the position/time graph, which is kinda boring, I have the velocity/time and momentum/time. In the velocity/time graph, you can see the graphs start a bit lopsided in the positive direction, and then they finish lobsided in the negative direction. So the sums of their velocities (or their averages with you want), is not conserved.")

        ; (para "But moving to the momentum/time graph, that's not the case! Look at the beginning and ends [ad lib]")

        (para "It's a bit hard to see, but the velocity/time graph is slightly lopsided: the sum of velocities at the beginning of the sim is a bit larger than it is at the end. But the momentum graph is perfectly balanced.")

        (para "So why is this?")

        (para "Well, it all comes down to our simulation rules. It's still (and always) the case that \"dvel * mass = force * dt\". And forces are still (and always) equal and opposite. But now that we have more than 2 objects, we get to see forces adding. The force that the middle ball experiences is a positive force from its interaction with the left object, and a negative one from its interaction with right.")

        (bmath-eqs
            '(sum k T1 T2 (+ (* (ball1 mass) (mt (ball1 dvel) k)) (* (ball2 mass) (mt (ball2 dvel) k)) (* (ball3 mass) (mt (ball3 dvel) k))))
            '(sum k T1 T2 (+ (* (mt (ball1 force) k) dt) (* (mt (ball2 force) k) dt) (* (mt (ball3 force) k) dt)))
            '(sum k T1 T2 (+ (* (mt (ball1 force) k) dt) (* (+ (- (mt (ball1 force) k)) (- (mt (ball3 force) k))) dt) (* (mt (ball3 force) k) dt)))
            0
            )

        (para "If we were to add up all of the mass * dvel of all of the objects, it would *still* add up to 0! And so therefore, for every two timestamps T1 and T2:")

        (bmath 
            '(= (+ (mt (ball1 momentum) T1) (mt (ball2 momentum) T1) (mt (ball3 momentum) T1)) (+ (mt (ball1 momentum) T2) (mt (ball2 momentum) T2) (mt (ball3 momentum) T2)))
            )

        ; (para "If we were to add up all of the mass * dvel of all of the objects, it would equal this expression. The blue one would equal -blue-force*dt, and the green would be +green-force*dt like we talked about a couple slides ago. But the red one would be the sum of these two forces time dt, from [this] line. The blue forces cancel out after multiplying by dt, as do the greens.")

        (para "This is conservation of momentum. The sum of all of the object's masses * their dvels at every timestep is always 0. We define an object's momentum to be equal to its mass times its velocity. The sum of all of the object's momentums never change from timestep to timestep.")

        ; (para "Before we end I want to mention one last thing. I don't what you to get the impression that the stuff we talked about just applies to our collision force. After introducing it, I never really brought it up again, and the derivation of conservation of momentum doesn't rely on any of its properties. As long as your forces are always equal and opposite, which they should be, conservation of momentum always works. So to demonstrate, I cooked up a very strange looking collision force, something really wacky that has no basis in reality. And you can see how the velocity graph has a strange shape. But still, the momentum symmetry is still there. If you were to scale the [color] graph by 2, cooresponding to the ratio of their masses, they'd be symmetric. So conservation of momentum is working here, too.")

        (para "So yeah. That's momentum. We'll come back to this eventually, a couple times. Momentum is a really important concept, one of those things that, throughout physics you never really get away from.")

        (para "Changelog:")
        (ulist
            "2024 Feb 4: Initial publish")

        ))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string lesson1 file)
        (put-string file lesson2)
        (close-port file)))