(include "generator.scm")

(define lesson-number 5)

(define sim01
    (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)))) 
(define sim02
    (sim (make-sim-spawn (make-sim-object 2 1 -2) (make-sim-object 1 0 1))))
(define sim03
    (sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 2 0 1))))

(define sim2x2_vel_1
	(sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1))))
(define sim2x2_vel_2
	(sim (make-sim-spawn (make-sim-object 1 2 -2) (make-sim-object 1 0 1))))
(define sim2x2_vel_3
	(sim (make-sim-spawn (make-sim-object 1 3 -2) (make-sim-object 1 0 1))))
(define sim2x2_vel_4
	(sim (make-sim-spawn (make-sim-object 1 4 -2) (make-sim-object 1 0 1))))
(display "Finished with 2x2 vel\n")

(define sim2x2_mass_1
	(sim (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1))))
(define sim2x2_mass_2
	(sim (make-sim-spawn (make-sim-object 2 1 -2) (make-sim-object 1 0 1))))
(define sim2x2_mass_3
	(sim (make-sim-spawn (make-sim-object 3 1 -2) (make-sim-object 1 0 1))))
(define sim2x2_mass_4
	(sim (make-sim-spawn (make-sim-object 4 1 -2) (make-sim-object 1 0 1))))
(display "Finished with 2x2 mass\n")

(define sim2x2_mass_alt_1
	(sim (make-sim-spawn (make-sim-object 1 1 -3) (make-sim-object 1 0 2))))
(define sim2x2_mass_alt_2
	(sim (make-sim-spawn (make-sim-object 2 1 -3) (make-sim-object 2 0 2))))
(define sim2x2_mass_alt_3
	(sim (make-sim-spawn (make-sim-object 3 1 -3) (make-sim-object 3 0 2))))
(define sim2x2_mass_alt_4
	(sim (make-sim-spawn (make-sim-object 4 1 -3) (make-sim-object 4 0 2))))
(display "Finished with 2x2 mass\n")

(define sim-multi
	(sim (make-sim-spawn (make-sim-object 1 0.75 -3) (make-sim-object 2 0 0) (make-sim-object 2 -1 4))))

(define sim-dt-1
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) 1))
(define sim-dt-4
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) (/ 1 4)))
(define sim-dt-16
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) (/ 1 16)))
(define sim-dt-32
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) (/ 1 32)))
(define sim-dt-128
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) (/ 1 128)))
(define sim-dt-512
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) (/ 1 512)))
(define sim-dt-2048
    (sim-with-dt (make-sim-spawn (make-sim-object 1 1 -2) (make-sim-object 1 0 1)) (/ 1 2048)))
(display (get-vel-history sim-dt-4 0))
(display "\n")
; (display (get-force-history sim-dt-4 0))
(display (- (get-ke-at-time sim2x2_mass_alt_2 0 8.0) (get-ke-at-time sim2x2_mass_alt_2 0 0.0)))
(display "\n")

(define ke-equation-inline (math '(* (/ 1 2) mass (mparen (- (^ final-velocity 2) (^ initial-velocity 2))))))

(define area-list-single
	(lambda (x)
		(string-append "(<span style=\"color:" (car svg-colors) "\">" (num3 x) "</span>,<span style=\"color:" (cadr svg-colors) "\">" (num3 x) "</span>)")))
(define area-list
	(lambda (. args)
		(foldr string-append (interleave (map area-list-single args) ", "))))

(define lesson3
	(lesson lesson-number
		(para "Let's return to a familiar simulation.")

		(sim-vis sim01)

		(para "I want to talk about its force/position graph.")

		(sim-graphs-2 sim01 get-pos-history get-force-history)

		(para "So. First thing to notice is that they look symmetric. And they are!")

		; (para "[flip back for a second] Actually, it's interesting that basically all of the graphs we've seen so far of this simulation are symmetric, right? I mean the one we're currently looking at, the one where the two objects are of equal mass. If you think about it this particular simulation is *itself* symmetric. Right? We saw last time that the velocity graphs are perfectly symmetric. We never actually explained that, but what it means that whatever velocity the left object starts with, the right object will end with. So if you were to flip the whole simulation around horizontally, and replay it in reverse, it would be exactly the same. Which is pretty cool.")

		(para "Okay, so It's symmetric, big deal. Most of the graphs we've looked at for this particular simulation are symmetric. Also, one is positive while the other is negative, of course. And they attain the same max force at the same time, just with opposite signs.")

		(para "Additionally, both graphs have the same \"width\" and the same \"height.\" Well obviously they do, they're symmetric. But if you think about it, the \"width\" of the graph, the amount of the x-axis that isn't 0, is showing the distance each object travels during the collision. And both objects will travel the same distance during the collision. At the moment when their collision starts, they'll be barely touching, so their centers will be (left ball's radius) + (right ball's radius) away from each other. But at the moment when their collision ends, they'll be barely touching as well. So therefore, they'll both have traveled the same distance.")

		(para "Let's make it more interesting. Here's another sim that we've seen before, the one where the left object has twice the mass.")

		(sim-vis sim02)

		; (sim-graphs
  ;           (list 
  ;               (downsamp-sm (get-pos-history sim02 0))
  ;               (downsamp-sm (get-force-history sim02 0)))
  ;           (list
  ;               (downsamp-sm (get-pos-history sim02 1))
  ;               (downsamp-sm (get-force-history sim02 1))))
  		(sim-graphs-2 sim02 get-pos-history get-force-history) 

		(para "Maybe you might have guessed it, but now the symmetry is broken. And because we want to have lots of tools for thinking about complex physics interactions, we're going to see if we can explain this, and maybe recover the symmetry like we did last time with velocity and momentum.")

		(para "So one of them is now slanted more \"away\" than the other. And so you might think that we can do a similar thing to what we did with velocity. Maybe we can stretch or shrink one of these in the horizontal direction, somehow, dependent on mass?")

		(para "This is made all the more complicated by the fact that the graphs can double back on themselves:")

		(sim-vis sim03)
		(sim-graphs-2 sim03 get-pos-history get-force-history)

		(para "Unfortunately, that technique doesn't work here. No simple stretching scheme is going to help us. So what to do?")

		(para "Well, okay, so I don't really know how to motivate this. I could dance around it for a while and try to connect a bunch of different ideas together to imply what we should try here. But I think that's probably just confusing, and that I should just give it to you straight.")

		(para "The trick here is to look at these graphs like they're triangles. So they have a \"width\", and a height. And remember, their bottom edges are the same length, and their peaks are the same height. Now, if you remember your geometry, there aren't a ton of things you can say concretely about these triangles. Like, they don't share angles, or perimeters. BUT they do have the same area.")

		(para "So here's an idea. What were to happen if we tried calculating the area of these graphs?")

		(option
			(sxs (sim-vis sim01) (sim-graphs-2-integral sim01 get-pos-history get-force-history))
			(sxs (sim-vis sim02) (sim-graphs-2-integral sim02 get-pos-history get-force-history))
			(sxs (sim-vis sim03) (sim-graphs-2-integral sim03 get-pos-history get-force-history))
			)

		(para "From top to bottom, the areas are " (area-list 0.5 1.0 0.5))

		; (para "How would that work? Well, if you've taken a calculus course, you know all about this. The simulation only provides values at a number of discrete points on this graph, and nothing inbetween. So to take the approximate area of this graph I'll take each data point and associate with it a rectangle with its height as the y-value and its width as the distance between adjacent data points. And so the area of the graph is the sum of all of these rectangles.")

		; (para "[calc refresher] If you need a refresher, there's like a hundred billion sites on the internet that will teach calculus, just go find one. But to cover the important point quickly,")

		; (para "- sum((some quantity measured every timestamp) * d(other quantity)), summed up for every timestamp between to times T1 and T2, that sum converges as d(other quantity) gets smaller. The set of quantities for which this is true is pretty large; we probably won't run up against any issues in this course.")

		; (para "- In a calculus course you learn some other sums that also converge to the same value. Like this one here, where you measure the d(other quantity) every frame, but measure (first quantity) against the *next* frame. In a real calculus course you learn a bunch of other ones as well, like using midpoints or more complex shapes like trapezoids, but we'll just stick with these two.")

		; (para "[vid3 state 2 with area] So anyways. We measure the areas of these graphs. And if we do that, sure enough, the graphs' areas are exactly equal. Well, you know, equal and opposite.")

		(para "And if we do that, sure enough, the graphs' areas are exactly equal. Well, you know, equal and opposite. We're on to something here. Also, notice how these areas are, like, they're simple numbers. Like 0.5, and 2 and stuff.")

		(para "... but what is that area? They're equal, sure, but what is that number? What I mean is, the area of these graphs are not going to be 1/2 * (distance traveled) * (max force). That was just a silly idea I threw out there to get us thinking in the right direction. But because the numbers we're seeing look pretty simple, maybe there's a simple expression for the area of the graphs that we can narrow in on.")

		(para "Well, now that we have numbers that we can drive against, we can do some simulations. It might be tempting to look at the effects of mass first, but actually let's look at the effects of the initial velocity first.")

		(option
			(sxs (sim-vis sim2x2_vel_1) (sim-graphs-2-integral sim2x2_vel_1 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_vel_2) (sim-graphs-2-integral sim2x2_vel_2 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_vel_3) (sim-graphs-2-integral sim2x2_vel_3 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_vel_4) (sim-graphs-2-integral sim2x2_vel_4 get-pos-history get-force-history))
			)

		(para "From top to bottom, the areas are " (area-list 0.5 2 4.5 8))

		(para "Here, we have 4 simulations. In each, the left and right objects have the same mass, and the right object starts with 0 velocity, but the left object starts with different velocity in each.")

		(para "And on the right are the graphs of their areas. Maybe it's hard to tell, but these numbers are scaling *quadratically*. 0.5 is half of 1^2, 2 is half of 2^2, 4.5 is half of 3^2, 8 is half of 4^2. So it looks like the graph areas scale quadratically with the initial velocity of the left ball. That's interesting.")

		(para "Okay now let's try varying the masses. The right object has a velocity of 0 and a mass of 1. The left object has a velocity of +1, but different masses.")

		(option
			(sxs (sim-vis sim2x2_mass_1) (sim-graphs-2-integral sim2x2_mass_1 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_mass_2) (sim-graphs-2-integral sim2x2_mass_2 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_mass_3) (sim-graphs-2-integral sim2x2_mass_3 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_mass_4) (sim-graphs-2-integral sim2x2_mass_4 get-pos-history get-force-history))
			)

		(para "From top to bottom, the areas are " (area-list 0.5 0.889 1.125 1.280))

		(para "And when we look at the areas... huh. Okay that one's maybe not as obvious. Now we could run a bunch more simulations and graph the relationship, but I want to try something else first real quick.")

		(para "In this one, the masses are matched for both objects:")

		(option
			(sxs (sim-vis sim2x2_mass_alt_1) (sim-graphs-2-integral sim2x2_mass_alt_1 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_mass_alt_2) (sim-graphs-2-integral sim2x2_mass_alt_2 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_mass_alt_3) (sim-graphs-2-integral sim2x2_mass_alt_3 get-pos-history get-force-history))
			(sxs (sim-vis sim2x2_mass_alt_4) (sim-graphs-2-integral sim2x2_mass_alt_4 get-pos-history get-force-history))
			)

		(para "From top to bottom, the areas are " (area-list 0.5 1 1.5 2))

		(para "Aaaaand... Okay, there we go, that's something. So it looks like the force/position graph areas scale linearly with mass, when both objects have the same mass.")

		(para "Okay, I won't lead you on anymore. The issue with the middle set of graphs, the reason that it didn't scale linearly, is because when varying the left masses, another important quantity ended up inadvertently changing as well: the end velocities!")

		(para "You can go do some simulations on your own if you want, to figure out the complete relationship between all of these variables, but I'll us all the trouble. The final relationship is:")

		(bmath '(* (/ 1 2) mass (mparen (- (^ final-velocity 2) (^ initial-velocity 2)))))

		(para "So two things about this. First is that this is pretty different from the momentum derivation from last time. In the first video, each object has the same " (math '(* mass (mparen (- final-velocity initial-velocity)))) " between any two points in time. Here, each object has the same differences in... well the quantity 1/2 * mass * ((final velocity)^2 - (initial velocity)^2). So linear in mass, and also in this other weird term. And we don't know this for sure as of yet, but these quantities are only equal when the final and initial velocities are taken after and before the collision.")

		(para "The other thing to note about this is... well, look at this form. If you remember your calculus, this should be screaming at you. But to be concrete, let's finally work it out from our simulation loop.") 

		(heading "Derivation")

		(para "I'm going to be showing you why why the area of one of these graphs is equal to " ke-equation-inline ". I'll be doing so in 2 two steps. First, I'm going to rewrite the sum in terms of velocities, and then I'm going to show how the sum works out.")

		(para "To calculate the graph's area, we're going to be taking its integral. We're going to be using the  double-right-point-integral formulation that I introduced in the calculus chapter for this:")

		(bmath '(sum k T1 T2 (* (mt force (+ k dt)) (mt dpos k))))

		(para "So. First off, force and dpos are both closely related to velocity. So maybe by re-writing each item of the sum in terms of velocities, we can simplify a bit.")

		(bmath-eqs
			'(* (mt force (+ k dt)) (mt dpos k))
			'(* (mparen (* (mt dvel (+ k dt)) mass (/ 1 dt))) (mparen (* (mt velocity k) dt)))
			'(* mass (mt velocity k) (mt dvel (+ k dt)))
			)

		(para "Here I've pulled out, say, the k'th item of the integral we're dealing with. First, we can replace the force with mass * dvel / dt. Then we can replace dpos with velocity * dt. So with those two replacements, we see the sum is equal to the sums of mass * velocity * dvel.")

		(para "Now we're going to do a little funny business to take advantage of the relationship between velocity and dvel:")

		(bmath
			'(* mass (mt velocity k) (mt dvel (+ k dt)))
			'(* (/ 1 2) 2 mass (mt velocity k) (mt dvel (+ k dt)))
			'(* (/ 1 2) mass (mparen (- (^ (mparen (+ (mt velocity k) (mt dvel (+ k dt)))) 2) (^ (mt velocity k) 2) (^ (mt dvel (+ k dt)) 2))))
			'(* (/ 1 2) mass (mparen (- (^ (mt velocity (+ k dt)) 2) (^ (mt velocity k) 2) (^ (mt dvel (+ k dt)) 2))))
			)

		(para "So we do a bit of algebraic manipulation here. First multiplying and dividing by 2, then completing the square. But then notice that each " (math '(= (+ (mt velocity k) (mt dvel (+ k dt))) (mt velocity (+ k dt)))) ".")

		(para "This is a good form to end on, because after replacement a bunch of terms cancel out:") 

		(bmath-eqs
			'(sum k T1 T2 (* (mt force (+ k dt)) (mt dpos k)))
			'(sum k T1 T2 (* (/ 1 2) mass (mparen (- (^ (mt velocity (+ k dt)) 2) (^ (mt velocity k) 2) (^ (mt dvel (+ k dt)) 2)))))
			
			'(* (/ 1 2) mass (- (- (mt velocity (+ T2 dt)) (mt velocity T1)) (sum k T1 T2 (^ (mt dvel (+ k dt)) 2))))


			; '(* (/ 1 2) mass (mparen (- (^ velocity@101 2) (^ velocity@1 2) ...))) ; todo: the 100 terms of dvel
			; '(* (/ 1 2) mass (mparen (- (+ ... (^ velocity@30 2) (^ velocity@31 2) (^ velocity@32 2)) (+ ... (^ velocity@29 2) (^ velocity@30 2) (^ velocity@31 2) ...) (mparen dvel))))
			; '(* (/ 1 2) mass (mparen (- (^ (mt velocity (+ T2 1)) 2) (^ (mt velocity T1) 2) (mparen dvel))))
			)

		(para "This is *almost* the form we saw earlier. But it has all of these " (math '(^ (mt dvel k) 2)) " terms as well.")

		(para "We're going to be using another classic calculus trick here: we're going to say that these " (math '(^ dvel 2)) " terms are \"negligible\", or that they \"go to zero\". Here's the intuition:")

		(para "Say I reduced our simulation's dt by a factor of 10. We've seen that velocities converge closer to their \"correct\" value, and that the dvels all reduce by about a factor of 10. This means that each " (math '(^ (mt dvel k) 2)) " term will reduce by about a factor of 100. But by reducing the dt like this, it also mean that between any two points in time, there will be 10 times as many samples.")

		(para "So for the sum of " (math '(+ (^ (mt dvel T1) 2) ... (^ (mt dvel T2) 2))) ", we have 10 times as many samples, but each sample is about 100 times smaller. So the sum of all of these " (math '(^ dvel 2)) " terms reduce by about a factor of 10.")

		(para "The point here is that as you make dt smaller (to make the simulation more accurate), the sum of these " (math '(^ dvel 2)) " terms rapidly become so close to zero that they aren't worth thinking about.")

		(table
            (table-row
                "dt" (math '(* (/ 1 2) mass (mparen (- (^ (mt velocity 8.0) 2) (^ (mt velocity 0.0) 2))))) (math '(sum k 0.0 (- 8.0 dt) (^ (mt dvel (+ k dt)) 2))))
            (table-row
                "dt = 1" (number->string (- (get-ke-at-time sim-dt-1 0 8.0) (get-ke-at-time sim-dt-1 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-1 0)))
            (table-row
                "dt = 1/4" (number->string (- (get-ke-at-time sim-dt-4 0 8.0) (get-ke-at-time sim-dt-4 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-4 0)))
            (table-row
                "dt = 1/16" (number->string (- (get-ke-at-time sim-dt-16 0 8.0) (get-ke-at-time sim-dt-16 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-16 0)))
            (table-row
                "dt = 1/32" (number->string (- (get-ke-at-time sim-dt-32 0 8.0) (get-ke-at-time sim-dt-32 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-32 0)))
            (table-row
                "dt = 1/128" (number->string (- (get-ke-at-time sim-dt-128 0 8.0) (get-ke-at-time sim-dt-128 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-128 0)))
            (table-row
                "dt = 1/512" (number->string (- (get-ke-at-time sim-dt-512 0 8.0) (get-ke-at-time sim-dt-512 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-512 0)))
            (table-row
                "dt = 1/2048" (number->string (- (get-ke-at-time sim-dt-2048 0 8.0) (get-ke-at-time sim-dt-2048 0 0.0))) (number->string (get-integral-dvel-2 sim-dt-2048 0)))
            )

		(para "This table is based on the equal mass simulation that we've seen so many times already, but ran with different dt's.")

		; (para "[ This part is dogshit. Just say that velocities don't change that much with dt, but dvel does. ] So this is *almost* the form we saw earlier. But it also has all of these dvel(i)^2 terms as well. We're going to be using another classic calculus trick here: we're going to say that these dvel(i)^2 terms are \"negligible\", or that they \"go to zero\". Here's the intuition: Say I were to reduce the dt that our simulation used. Say we reduced it by a factor of 10. Well, in that case all of our numbers would be different. But assuming that the forces and velocities and positions won't change that much, our dvel's will get reduced by a factor of 10, because \"dvel = force / mass * dt\". But, reducing the dt would also mean that between any two points in time, there will be 10 times as many samples. So for a sum like this, [these] v(i) * dvel(i+1) terms will add up to about the same. The *10 and /10 will cancel each other out. Also, for [these] dvel(i)^2 terms, there will be 10 times more of them as well. BUT each one will be reduced by a factor of 100. So [these] numbers will get smaller, the smaller our dt gets. And so the argument goes, driving dt lower makes these terms stay about the same, but makes [these] terms closer to zero, without bound. But also, like we discussed in the first video, a smaller dt is \"more correct\". So the argument is that, for small enough dt, the sum of all of [these] terms should be 1/2 * mass * ((final velocity)^2 - (initial velocity)^2), without the dvel^2 terms.")

		; (para "Okay. So that was a bit complicated, but it wasn't *that* much. That was the entire derivation.")

		(para "The last thing to mention is the \"T2+1\" bit. It's true that " (math '(* (/ 1 2) mass (mparen (- (^ (mt velocity (+ T2 1)) 2) (^ (mt velocity T1) 2))))) " doesn't quite match the expression " ke-equation-inline " that we had before. Here we're going to make one more little approximation: if you reduce dt by a factor of 10, dvel will also shrink by about a factor of 10, and so " (math '(mt velocity k)) " is about equal to " (math '(mt velocity (+ k dt))) ". This is an approximation that should be handled with care, but in this case it should be fine.")

		(para "So to conclude, the sum of " (math '(* force dx)) " over every timestamp between times T1 and T2 converges to " (math '(* (/ 1 2) mass (mparen (- (^ (mt velocity T2) 2) (^ (mt velocity T1) 2))))) " as we make our dt smaller.")

		; TODO: give it a name

		(option
			(sxs (sim-vis sim01) (sim-graphs-2 sim01 get-time-history get-ke-history))
			(sxs (sim-vis sim02) (sim-graphs-2 sim02 get-time-history get-ke-history))
			(sxs (sim-vis sim03) (sim-graphs-2 sim03 get-time-history get-ke-history))
			)

		; (para "[kinetic energy definition] Over the course of this series, we're going to come to understand this quantity, and the extensions we're going to make to it, as having something to do with, like, a fundemental limit to an object's ability to exert change on other objects. But! We're not there yet.")

		; (para "So we've seen that we can calculate exactly the area of each of the two force/position graphs. For this simulation on the left, the blue ball starts with a large positive velocity and ends with low, while the red object starts with 0 velocity and ends high. And you can see that relected in the kinetic energy graph.")

		(heading "Conservation of kinetic energy")

		(para "We can see from the graph here that this quantity is *not* symmetric, but by the end of the collision they do seem to end up balancing out.")

		(para "But I still have to explain why that would be true. Why the force/position graphs would have equal and opposite area. It's certainly not obvious, at least not obvious to me, why these two expressions *should* be equal.")

		(para "So we're going to try to show that the two force/position have equal and opposite areas. Last time, we saw that the sum of momentums are equal to 0 at every timestamp. But that won't work here.  The areas are only equal when taken over the *entire* collision.")

		(para "This time we're going to go with the left-point formulation of the kinetic energy sum. We're start by looking at each individual timestamp, and then see what happens.")

		(bmath '(+ (* (ball1 force) (ball1 dpos)) (* (ball2 force) (ball2 dpos))))

		(para "So we have here our two force * dpos. The forces are equal and opposite.")

		(bmath 
			'(+ (* (ball1 force) (ball1 dpos)) (* (ball2 force) (ball2 dpos)))
			'(* (ball1 force) (mparen (- (ball1 dpos) (ball2 dpos))))
			'(* (ball1 force) (fun d (- (ball1 pos) (ball2 pos))))
			)

		(para "This is interesting. " (math '(mt (fun d quantity) k)) " is the difference between " (math '(mt quantity (+ k dt))) " and " (math '(mt quantity k)) ". And due to commutitivity, the sum of differences is the difference of sums: ")

		(bmath '(= (- da db) (- (mparen (- a2 a1)) (mparen (- b2 b1))) (- (mparen (- a2 b2)) (mparen (- a1 b1))) (fun d (- a b))))

		; (para "Remember, d(anything) is what we add to the previous quantity to get the current one. We then re-arrange and group like timestamps. And now here's a little something.")

		; (para "In all of these expressions, we're saying thinks like \"velocity measured at timestamp k\" or \"force measured at timestamp k\". But you can track any quantity over time. So we're going to rewrite [this] part as \"pos - pos @ k\". So meaning, we track the difference between the red ball's position and the blue ball's position over all of the steps of the simulation, and then we measure that quantity at timestamp k. This is just another way to say \"red pos @ k - blue pos @ k\", but it sets us up for this next step.")

		; (para "So previously, we've had dpos and dvel. Those measure the difference between this timestamp and last. We can extend that idea to any quantity. Any quantity that changes over time, that is. And this quantity, the difference between the ball's positions, that changes over time. And, well, what do you know? That's what we've got here. So I'm going to write it like this.")

		; (para "So the final form we've got here is ((force @ k) * (d(pos - pos) @ k)).")

		; (para "Those last couple lines aren't some fancy algebraic manipulation or anything, it's just re-writing what we have in a very suggestive way.")

		(para "That's the key to it, but there's another observation that we need to make first. That is, about the particular force that we've been using. Remember, it was itself a function of the distance between the two objects. So if we were to go out on a limb and assume that our collision function has to be a function of the difference in positions, we could re-write it like this.")

		(bmath
			'(* (ball1 force) (fun d (- (ball1 pos) (ball2 pos))))
			'(* (fun collision_force (- (ball1 pos) (ball2 pos))) (fun d (- (ball1 pos) (ball2 pos))))
			)

		(para "So we have this nice, very suggestive form.")

		(para "Now that we have this:")

		(bmath
			'(sum k T1 T2 (* (ball1 (mt force k)) (fun d (- (ball1 (mt pos k)) (ball2 (mt pos k))))))
			'(sum k T1 T2 (* (fun collision_force (mt (mparen (- (ball1 pos) (ball2 pos))) k)) (mt (fun d (- (ball1 pos) (ball2 pos))) k)))
			)

		; (para "There's one last step. We have to bring in one more fact from calculus.")

		; (para "[potential energy 3] We've seen some patterns like this already.")

		; (para "When we've summed up mass * dvel, we get a difference of two identical expressions in terms of velocity, but with one in terms of vel @ T2 and the other at T1.")

		; (para "When we summed up mass * vel * dvel, we again get a difference of two identical expressions in terms of velocity, but with one in terms of vel @T2 and the other at T1.")

		; (para "This is actually a general pattern [flip forward for a sec] Any time you're summing up a bunch of items of the form (expression involving quantity @ k) * (dquantity @ k), you're going to get a difference of two identical expressions in terms of your quantity, but one at T2 and the other at T1. (These would be the \"U\" functions here). This is a very important result from calculus, called the Fundemental Theorem of Calculus. We don't necessarily know the expression (the \"U\" in this case), we don't know what it is. Like what what it's form is as a mathematical expression. But calculus deos tell us some important facts. Namely, it's not dependant on T1 and T2. It's dependant only on the form of \"expression\" in the line above. Though the relationship is complicated. When you take calculus in school, most of the classes will be dedicated to learning how to actually figure out the form of U here. But this isn't a calculus class, so we aren't going to worry about that here.")

		; (para "To be a bit pedantic, this isn't always the case, but it's going to be the case for basically everything we'll be talking about in this series. The big things to look out for are that the \"expression\" part is \"sufficiently continuous\", and bounded over the range that we're summing over. So like, the \"dq\" keeps getting smaller as \"dt\" gets smaller, and the \"expression\" doesn't have any singularities. The subject where you learn all of the gritty details is called \"Real Analysis.\" If you're interested in that sort of thing, there's tons of lectures out there on the internet. Go find one.")

		; (para "[flip back] So we're going to apply that to our force(pos - pos) * d(pos - pos). As \"dt\" gets small, this will converge to a difference of two expressions in terms of (pos - pos) at the two timestamps.")

		(para "Since each of the ball's positions converge as dt goes to zero, " (math '(fun d (- (ball1 pos) (ball2 pos)))) " goes to 0. We're also going to assume that the collision force is strong enough to stop objects from \"phasing through\" each other, so in other words " (math '(- (ball1 pos) (ball2 pos))) " never crosses 0. So this fulfills all of the requirements (listed in the calculus chapter) to call this an integral and apply tools from calculus.")

		(para "We know, since this sum is an integral, it will have an antiderivative. We don't know what it is, and it can be very complicated to figure out its exact form. Err... well, we *do* know its antiderivative, it's the sum of the kinetic energy equations from before, one for each object! But expressing its antiderivative as a mathematical expression in terms of position would be very complicated.")

		(para "But because we're able to write it this way, we do know that it does have an antiderivative that is a function *only of* " (math '(- (ball1 pos) (ball2 pos))) ". Just to give it a name, I'm going to call it graph_antiderivative().")

		(bmath
			'(sum k T1 T2 (* (fun collision_force (mt (mparen (- (ball1 pos) (ball2 pos))) k)) (mt (fun d (- (ball1 pos) (ball2 pos))) k)))
			'(- (fun graph_antiderivative (mt (mparen (- (ball1 pos) (ball2 pos))) T2)) (fun graph_antiderivative (mt (mparen (- (ball1 pos) (ball2 pos))) T1)))
			)

		(para "But here's the trick! Remember from a couple minutes ago, when I was explaining that the base of the force/position graphs were the same width? I told you that, at the moment when the balls first touch, they'll be (blue radius + red radius) apart, and at the moment they separate, they'll also be (blue radius + red radius) apart. So if T1 and T2 are taken to be the very start and very end of the collision, " (math '(mt (mparen (- (ball1 pos) (ball2 pos))) T1)) " and " (math '(mt (mparen (- (ball1 pos) (ball2 pos))) T2)) " are the same! And so therefore, " (math '(- (fun graph_antiderivative (mt (mparen (- (ball1 pos) (ball2 pos))) T2)) (fun graph_antiderivative (mt (mparen (- (ball1 pos) (ball2 pos))) T1)))) " is going to be 0!")

		(para "And if you extend T1 to be sometime before the start of the collision, well it's not feeling any forces, is it? So it adds 0 to the final result. Same with extending T2 to be sometime after the collision ends.")

		(para "And there you have it. The sum of " (math '(+ (* (ball1 force) (ball1 dpos)) (* (ball2 force) (ball2 dpos)))) ", taken between the moment the balls touch and the force/position graph rises above the x-axis, and the moment the separate and the force/position graph returns to the x-axis, is 0. The areas of the force/position graphs are equal and opposite.")

		(para "This also means the sum of the kinetic energy of the two balls is conserved. That's because ")

		(bmath
			'(= (fun graph_antiderivative (mt (mparen (- (ball1 pos) (ball2 pos))) k))
				(+ (mt (ball1 kinetic_energy) k) (mt (ball2 kinetic_energy) k))))

		(heading "3 objects")

		(para "Right. So. Now that we've got that out of the way, the last thing left to talk about is multiple objects. The know that the total kinetic energy of a simulation with two objects is the same before and after a collision. But what happens when three objects all interact at once?")

		(sim-vis sim-multi)

		(sim-graphs-2-integral sim-multi get-pos-history get-force-history) 

		(bmath
			'(+ (* (ball1 force) (ball1 dpos)) (* (ball2 force) (ball2 dpos)) (* (ball3 force) (ball3 dpos)))
			'(+ (* (ball1 force) (ball1 dpos)) (* (mparen (- 0 (ball3 force) (ball1 force))) (ball2 dpos)) (* (ball3 force) (ball3 dpos)))
			'(+ (* (ball1 force) (mparen (- (ball1 dpos) (ball2 dpos)))) (* (ball3 force) (mparen (- (ball3 dpos) (ball2 dpos)))))
			)

		(para "Well, it goes pretty much the same. Here, we have 3 \"force * dpos\" terms, but the middle one's force equal and opposite to the sum of the forces on the left and right. So we can split them up and now both the left and right have a copy the dpos from the middle. And from here we just do it all again, getting \"force * d(pos - pos)\", it's just that each side has two separate versions of \"pos - pos\". Each side doesn't depend on the other. When we write the result of the sum using their antiderivatives, it's the same function, just two different \"pos - pos\"'s.")

		(bmath 
			'(sum k T1 T2 (+ (* (ball1 force) (- (ball1 dpos) (ball2 dpos))) (* (ball3 force) (mparen (- (ball3 dpos) (ball2 dpos))))))
			'(+ (fun graph_antiderivative (mt (mparen (- (ball1 pos) (ball2 pos))) k)) (fun graph_antiderivative (mt (mparen (- (ball3 pos) (ball2 pos))) k)))
			)

		(para "And that's that. When T1 is taken to be before all collisions begin, and T2 is taken to be after all collisions are finished, the sum is 0.") 

		(heading "Conclusion")

		(para "That was quite a lot. Let's regroup.")

		(para "Similar to last time, the sum of " (math '(* force dpos)) " over lots of timesteps heavily suggested a quantity we called kinetic energy, " (math '(* (/ 1 2) mass (^ vel 2))) ".")

		(para "We saw there was a symmetry in the kinetic energy graphs. But instead of the symmetry occurring at every timestep like last time, the kinetic energy symmetry happens on the level of entire collisions. Or, in the case of 3 or more objects, groups of collisions.")

		(para "The derivation of these facts required a number of assumptions. Namely:")

		(ulist
			"some results from calculus;"
			"the force that both objects are experiencing depends *only* on the distances between those objects;"
			"collisions need to be allowed to progress to completion.")

		(para "The assumptions from calculus aren't up for debate, but we'll see in later lessons that if either of the other two assumptions are invalidated, kinetic energy isn't actually conserved.")

		(para "So yeah. That's kinetic energy.")

		(para "And hey, I think we've covered a lot of ground these last couple lessons. We started with the base rules of physics, the rules that describe the little micro-movements that happen to individual objects over micro-durations of time. We then derived from them some rules about the macro-movement of entire simulations over macro-durations of time. And I think that's kinda cool.")

		))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string lesson1 file)
        (put-string file lesson3)
        (close-port file)))