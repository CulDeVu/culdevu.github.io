
(include "test_gen.sch")

(define lesson-number 4)

(define sim01
    (sim (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0))
(define sim02
    (sim (list (list (make-sim-object 2 1 -2) (make-sim-object 1 0 1))) 0))

(define lesson2
    (lesson lesson-number
        (para "I want to analyze this with you. Put some numbers to things, and start making graphs. Last video we talked very qualitatively, \"this velocity is larger or smaller, this force is smaller\", that kind of thing. But I like graphs. I'm a visual person. But what should we graph?")

        (code
            "dt = ..."
            "loop for every instance in time:"
            "    loop for every object:"
            "        sum up all of the forces for this object"
            ""
            "    loop for every object:"
            "        1. force = ..."
            "        2. velocity += force / mass * dt"
            "        3. position += velocity * dt"
            "    time += dt")

        (para "Well there's only a handful of piece of information in this loop. Each object has a mass, but those don't change over the course of the simuation. Clearly, the simulation loop from a couple slides ago doesn't have a line saying \"mass += something\". The quantities that do change are time, the force being felt by each object, each object's position, and each object's velocity. So to start, I suggest that we just graph each of the major variables by every other major variable. There's only 4: time, force, velocity, position. So after removing duplicates, that's just 6 graphs.")

        (para "And here are the first three! We have our original simulation, just so we have something interesting to look at. And we have force/time, position/time, and velocity/time.")

        (sim-graphs-2 sim01 get-time-2-history get-force-history)

        (para "Notice how the force graph has perfect reflectional symmetry. Hopefully that makes sense: at every point in time, the red object and blue object feel the exact same force, just one is negative and one is positive. So that's good.")

        (sim-graphs-2 sim01 get-time-2-history get-pos-history)

        (para "Then there's the position/time graph. There's not much to say here I think. I would like to point out, in the moments where the objects feel no force these graphs look like straight lines. That's what happens when an object has a constant velocity. And those straight lines are connected by smooth curves. Also, notice how there's a sort of diagonal symmetry here. That's kinda interesting, but we're going to talk about this. I'll save this for a future video.")

        (sim-graphs-2 sim01 get-time-2-history get-vel-history)

        (para "Now let's look at the velocity/time graph. There is another VERY clear line of symmetry here. But it's maybe not super obvious *why* this one is symmetric.")

        (para "Before moving on from these three graphs, I want to run another simulation, same situation, but now the [color] ball has twice as much mass. Remember from last time, the role of mass in an interaction with forces is that they respond less to the same force than objects with less mass. The functional result is that, with a repulsive force like collisions, heavy objects tend to \"barrel through\" smaller objects when moving, and when at rest smaller objects tend to \"bounce off\" of them. And we can see that happening here.")

        (sim-vis sim02)

        (para "So back to those graphs.")

        (sim-graphs-2 sim02 get-time-2-history get-force-history)

        (para "For the force graph in particular, they're being shown on the same scale as before. I can switch back and forth between the graphs like this.")

        (para "Starting at the force/time graph, notice how this time the force graphs are wider. This is because the left object is now wider, and so it's initiating the collision earlier. So that's maybe a silly difference. Also, notice that the red and blue graphs are still symmetric. Remember, whenever two objects interact via a force, the forces are always equal and opposite! Even when the masses are different. In that collision force I showed earlier, I didn't take mass into account, just the distance between object centers.")

        (sim-graphs-2 sim02 get-time-2-history get-pos-history)

        (para "For the position/time graph, I don't have much more to say, other than to notice how much \"less sharp\" the bend in the position graph is now, and that symmetry went away. Well, maybe not \"went away\", but it's not as obvious anymore.")

        (sim-graphs-2 sim02 get-time-2-history get-vel-history)

        (para "And now the velocity/time graph. So the symmetry that we were going for is still *kinda* there. It's reminiscent of the reflectional symmetry we had. But not quite. I want to talk about this.")

        (code
            "dt = ..."
            "loop for every instance in time:"
            "    loop for every object:"
            "        sum up all of the forces for this object"
            ""
            "    loop for every object:"
            "        1. force = ..."
            "        2. dvel = force / mass * dt"
            "        3. velocity += dvel"
            "        4. dpos = velocity * dt"
            "        5. position += dpos"
            "    time += dt")

        (para "So to explain this, let's go back to the simulation loop. So I've made one last modification to the loop. I haven't changed what it does, I've just re-arranged it a bit. Instead of doing these calculations and accumulating them in one step, I separated out the calculations and accumulations, and gave the intermediate calculations new names. \"dvel\" here means \"the amount that we're changing velocity this timestep\". \"dpos\" means \"the amount that we're changing position this timestep\".")

        (para "[momentum derivation]What I want to draw your attention to is this line, \"dvel = Force / mass * dt\". Rearranging this line gives \"dvel * mass = Force * dt\". We know that dt is the same for each timestep and for each object, and we know that at each timestep the force between the objects are equal and opposite in sign. So that means, at each timestep the quantities \"dvel * mass\" are going to be equal and opposite in sign.")

        (sim-graphs-2 sim02 get-time-2-history get-p-history)

        (para "[sim2 2 graphs]And, sure enough, if I scale the velocity/time graph by each object's mass, the symmetry comes back. If on one timestep, this quantity increases for the red ball by 8, it must decrease for the blue ball by 8. And if on the next timestep it increases for the red ball by 2, it must decrease for the blue ball by two. And so therefore, over the course of two consecutive timesteps, this quantity increases for the red ball by 10, and decreases for the blue ball by 10. So these quantities are equal and opposite not just for single timesteps, but for larger spans of time as well!")

        (para "[sim1 3 graphs, but this time velocity/time is replaced with momentum/time]By the way, this quantity, mass * velocity, is fairly important and it has a name: momentum. And this symmetry that you're seeing here also has a name: conservation of momentum.")

        (para "This name reflects a different way of looking at the relationship: instead of the differences in momentum between to point in time being equal and opposite, the traditional way of looking at it is that between two time points, whatever momentum is lost by one object is gained by the other. So the total momentum felt by all of the objects, the sum of all of their momentums, is constant.")

        (para "[flip back a slide]I want to dwell on this for a bit more. Let's ignore all of these \"mass *\" bits for now. The velocity of an object at, say, timestep 100, is going to be equal to that object's initial velocity plus its first dvel, plus its second dvel, and so on. Right? So if you multiply both sides of this equation by that object's mass, they should still be equal. But we also know that, whatever the \"mass * dvel 0\" of the blue object is, the \"mass * dvel 0\" of the red object is going to be equal and opposite. Same for \"mass * dvel 1\", and so on. So since each of these \"mass * dvel\"s are equal and opposite for the two objects, all of their sums are equal and opposite.")

        (para "So if you were to, say, add the blue ball's momentum at timestep 100 and the red ball's momentum at timestep 100, it would be equal to: the blue ball's momentum at time 0, plus the red ball's momentum at time 0, plus a whole bunch of terms that end up cancelling out! So that's what conservation of momentum is: the sum of the momentums of the red and blue ball are going to be the same at every timestep.")

        (para "[graphs 3-6]So that's pretty cool. But before we continue I wanted to mention that I haven't forgotten about the other three graphs. We won't be going into them in this video. We're saving these for next video. It'll turn out that this graph in the upper corner, the \"force/position\" graph will be important. Probably the most important of all 6 of the graphs presented here. But that's for next time! Back to momentum.")

        (para "[talk about the case with 3 balls]So that's pretty cool and all, but so far in these last 2 videos we've only talked about pairs of objects. What happens if we throw in another one? Here we have 3 balls in play, all the same mass, colliding with each other.")

        (para "We'll start out simple. Here the 3 balls undergo 3 distinct collisions: first from blue/red, then from red/green, then blue/red again. So let's look at our graphs.")

        (para "[3 balls same mass graphs]So here are the 3 graphs again, force/time, position/time and velocity/time. In the first graph, you can very clearly see the 3 collisions. Notice how they're different sizes. The middle one is much taller than the other two. This is because during this collision both balls are moving towards each other, whereas in first and last collision one of the balls was stationary. This means that for the second collision the objects were able to squeeze much closer together, and feel a larger force.")

        (para "For the position/time graph, you can again see 3 collisions clearly. The collisions are nice curves while the time inbetween are straight lines.")

        (para "For the velocity/time graph, you can see how during each collision they swap velocities, just like they did in the first simulation we looked at.")

        (para "[3 balls different masses]Okay, well what about the case when the collisions aren't distinct? What happens when they're all happening at once? Remember what I said earlier about forces adding. The red object is feeling the force of collision from *both* the blue and green objects, whereas the blue and green objects are just feeling the forces from the red one.")

        (para "[3 balls different mass graphs]And the graphs again. The force/time graph is now all muddied, there's no clear dilineation between the collisions. But, if you look closely, it's still sort of balanced. And that's correct! At every timestamp, every pair of objects share and equal and opposite force. But that also means that the sums of their forces is 0, and that the sums of the forces of all pairs of objects together is also 0! So this force graph should always be balanced around 0.")

        (para "Instead of the position/time graph, which is kinda boring, I have the velocity/time and momentum/time. In the velocity/time graph, you can see the graphs start a bit lopsided in the positive direction, and then they finish lobsided in the negative direction. So the sums of their velocities (or their averages with you want), is not conserved.")

        (para "But moving to the momentum/time graph, that's not the case! Look at the beginning and ends [ad lib]")

        (para "So why is this?")

        (para "[next slide]Well, it all comes down to our simulation rules. The red object's dvel is equal to the force its experiencing at that instant, divided by mass times dt. But forces add, so the force that its experiencing is a positive force from its interaction with the blue object, and a negative one from its interaction with green.")

        (para "If we were to add up all of the mass * dvel of all of the objects, it would equal this expression. The blue one would equal -blue-force*dt, and the green would be +green-force*dt like we talked about a couple slides ago. But the red one would be the sum of these two forces time dt, from [this] line. The blue forces cancel out after multiplying by dt, as do the greens.")

        (para "[conservation of momentum]This is conservation of momentum. The sum of all of the object's masses * their dvels at every timestep is always 0. We define an object's momentum to be equal to its mass times its velocity. The sum of all of the object's momentums are never changes from timestep to timestep.")

        (para "[talk about alternate force graphs]Before we end I want to mention one last thing. I don't what you to get the impression that the stuff we talked about just applies to our collision force. After introducing it, I never really brought it up again, and the derivation of conservation of momentum doesn't rely on any of its properties. As long as your forces are always equal and opposite, which they should be, conservation of momentum always works. So to demonstrate, I cooked up a very strange looking collision force, something really wacky that has no basis in reality. And you can see how the velocity graph has a strange shape. But still, the momentum symmetry is still there. If you were to scale the [color] graph by 2, cooresponding to the ratio of their masses, they'd be symmetric. So conservation of momentum is working here, too.")

        (para "So yeah. That's momentum. We'll come back to this eventually, a couple times. Momentum is a really important concept, one of those things that, throughout physics you never really get away from.")
        ))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append "lessons/" (lesson-html lesson-number)))))
    (begin
        ; (write-string lesson1 file)
        (put-string file lesson2)
        (close-port file)))