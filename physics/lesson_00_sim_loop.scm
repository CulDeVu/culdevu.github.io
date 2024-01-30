(include "generator.scm")

(define lesson-number 0)

(define sim01
    (sim (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0))
(define sim02
    (sim (list (list (make-sim-object 2 1 -2) (make-sim-object 1 0 1))) 0))
(define sim03
    (sim (list (list (make-sim-object 1 1 -2) (make-sim-object 2 0 1))) 0))

(define page
    (lesson lesson-number

        (para "Lets just get into it.")

        (para "So first a warning. I'm going to be making some claims about the nature of the universe that are, strictly speaking, not true. I'm about to describe the simulation that we're going to be working with and claiming that this is *exactly* how the universe works. It is not, but it is a good enough approximation for us at the moment. I'm also going to be leaving some things out. This is for simplicity's sake; we'll be adding missing things in as they come up.")

        (para "So with all that out of the way, let's start.")

        (sim-vis sim01)

        (heading "The loop")

        (para "The universe operates on rules. These rules are unbreakable, the rules are known, and they can be written down as a fairly simple loop of instructions. Here it is, and here's how it works:")

        sim-loop-code-sm

        (para "There is a thing called time. This is a quantity that, every time the loop reaches the bottom and loops back around to the top, it increments by a constant value.")

        (para "Now in the real universe, this timestep is absurdly small, many many billionths of billionths of a second. But that's not very useful for a simulation that a computer runs; it'd be calculating forever. So for the purposes of approximation, I'm going to be setting the timestamp for our simulations to be a small but manageable number, like 1/100th, 1/1000th of a second, something like that. The smaller the timestep, the more accurate the simulation is to reality. More on that later.")

        (para "There are also *things* in the universe. Now what that means is a bit of a touchy subject for us at the moment, but generally a *thing* is something physical in the world, like a ball or a cup. Of course, a ball is made up of lots of little *things* all connected together. So *thing* in this context can also mean collections of things. We'll come back to this later probably, but for the moment *things* for us are going to be stuff like bouncy balls, heavy boxes, things like that. I'll call these things by various other names, like objects or entities.")

        (para "Now every *thing* in the universe has three properties associated with them.")

        (ulist "First is position, which is a measurement of *where* the things is. For the first couple talks, we're only going to be looking at objects that move from left to right, so their position can be described using a single number, where on the number line it is."
            "The second is velocity, which is a measurement of where the thing is *going*."
            "The third is mass, which is a measure of how much effort it takes to change an object's velocity.")

        (para "Now if that was all there was, the universe would be a pretty boring place. But luckily, things in the universe can influence each other. Objects can collide, they can push and pull other objects using gravity of magnetism, that kind of thing. The way that objects interact is called a force. I'll talk about specific forces later, but for right now there is one important rule about forces: whenever two objects interact, they always exert forces on each other, and those forces are always equal and opposite. In other words, if one object is feeling a force of +5, the other one will feel a force of -5.")

        (para "Those concepts all come together in this loop.")

        (heading "Surely you're joking!")

        (para "So you're probably wondering, why is it like this? What's the deal with dividing the force number by the mass number?")

        (para "The answer is, perhaps unsatisfying as it is, that that's just how the universe works. Those are just the rules. They've been experimentally verified by millions over the last several centuries, and this is just how it works. To quote a famous physicist: \"I can only tell you what it looks like!\"")

        (heading "Forces")        

        (para "Now, in the simulation loop above, it doesn't say how we get the force for each object.")

        (para "This is a big subject. Essentially, each type of interaction between objects have their own formula. A good bit of this series will be spent talking about these.")

        (para "But there are a few common properties that all forces have:")

        (ulist
            "Forces always happen between pairs of objects,"
            "If an object is interacting with multiple other objects, their forces add, and"
            "Forces are applied symmetrically.")

        (para "Specifically what I mean are these changes to the simulation loop:")

        sim-loop-code-lg

        (para "There's one more vitally important rule. I've already mentioned it, but I'll say it again:")

        (ulist
            "Forces are antisymmetric. In other words, forces are always equal and opposite.")

        (para "What I mean by this is that force_function(object 1, object 2) = -force_function(object 2, object 1). So in the loop above, whatever gets added to the force for object 1 gets subtracted from the force for object 2, and vice versa.")

        (heading "Examples")

        (para "To get a little more comfortable, let's look at some concrete examples.")

        (sim-vis sim01)

        (para "This is a simulation of two colliding bouncy balls. We'll be going over collisions in detail in the next several lessons. For now, I want to talk general. The important thing to know about collisions for right now is that the balls will only feel a force while they're touching.")

        (para "There are 3 parts to this simulation: before the collision starts, during the collision, and after the collision ends.")

        (para "Before the collision starts, neither ball feel any force at all. And so")
        (ulist
            "Line 1 in the loop, force = 0."
            "Therefore line 2, dvel = 0."
            "Therefore line 3, velocity += 0, in other words velocity isn't changing from timestamp to timestamp."
            "Since velocity is staying constant, line 4 dpos = velocity * dt is staying constant as well."
            "Line 5, position += dpos is increasing at a constant rate.")
        (para "So before the collision starts, both balls are moving at a constant unchanging speed. Same thing after the collision ends, too.")

        (para "During the collision:")
        (ulist
            "Line 1, force is non-zero, and changing every timestamp. The force on the left object is negative, and the force on the right object is positive"
            "Line 2, the left object's dvel is negative, and the right object's dvel is positive, but both keep changing"
            "Line 3, that means the left object's velocity is decreasing, and the right object's velocity is increasing"
            "Line 4, that means dpos is going up and down"
            "Line 5, which means that position is increasing and decreasing at changing rates")

        (para "The big thing to note here is that the right ball didn't just \"bounce off\" the left one immediately. It made contact, and then sped up.")

        (para "Nothing does an instant acceleration like that. They have to take some non-zero amount of time to accelerate.")

        (para "Let's look at another one:")

        (sim-vis sim02)

        (para "In the simulations here and in the next couple lessons, objects with larger mass will be physically larger. That's not very physically accurate. It's just a visual thing.")

        (para "In this simulation, the left ball has twice the mass as the right one.")

        (para "In the simulation loop above, mass comes into play only in one spot, on line 2, dvel = force / mass * dt. The effect of mass on the simulation is to lessen the effect of force on an object.")

        (para "For example, in this simulation the larger mass object is able to \"barrel through\" the smaller one, because its dvel is half as large as the right object's. So it's velocity reacts to the same force at a slower rate.")

        (para "Here's another example, but where the ball with the larger mass is on the right:")

        (sim-vis sim03)

        (para "Here a similar thing happens. The two balls are feeling equal and opposite forces, but the right ball, due to its larger mass, reacts slower. So the left ball ends up slowing, stopping, and actually reversing direction before the right ball speeds up enough to move out of the way.")

        ))

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string page file)
        (put-string file page)
        (close-port file)))
