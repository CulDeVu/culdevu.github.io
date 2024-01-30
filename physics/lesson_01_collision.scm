
(include "generator.scm")

(define lesson-number 1)

(define sim01
    (sim (list (list (make-sim-object 1 1 -2) (make-sim-object 1 0 1))) 0))

(define lesson1
    (lesson lesson-number
        (sim-vis sim01)

        (sim-graphs-2 sim01 get-pos-history get-force-history) 

        (para "In this one I want to introduce a specific kind of force: collisions! This is not a \"fundamental force\", it's actually a combination of lots of complicated interactions, some of which we might talk about later in this series. But despite that, it's an important kind of interaction, and it's one that illustrates very nicely a couple of important ideas that I want to introduce early.") 

        (para "So what is the collision force? The goal here should be to come up with an expression that we can just plug into our simulation loop and press \"go.\" Now I want this expression I present to be physically motivated, but I don't care about perfect accuracy. This series is about concepts.") 

        (para "So what I did is I went on youtube and found a couple slow-motion videos of tennis balls bouncing and colliding with one another. I tracked their positions over a number of video frames, and then backsolved to get an idea of what shape the force should take. And this is what I arrived at. Plugging into the simulation loop gets us this. When the two balls far away and not touching, there's no force felt by either. When they're close together, they feel a repulsive force. As they get pressed closer together, the force they feel gets larger in magnitude.") 

        (code
            "collision_force(this, other) {"
            "    distance = (this position) - (other position)"
            "    cutoff_distance = (this radius) + (other radius)"
            "    norm_dist = distance / cutoff_distance"
            ""
            "    if (abs(distance) <= cutoff_distance) {"
            "        force = 0.125 * (abs(norm_dist)^-5 - 1) * (norm_dist / abs(norm_dist))"
            "    } else {"
            "        force = 0"
            "    }"
            "}")

        (para "The way this works is that each object, when at the stage when it's time to calculate its force, plugs its *own* position into \"this position\" and the other object's position into \"other position\". So for the right ball, it's the right position minus the left. For the left ball, it's left minus right. So what this means is that for the right ball, this quantity is going to be positive, and that positive number will cascade through the expression and result in a positive force. For the left ball, this quantity will be negative, and cascade into an overall negative force.")

        (para "It first computes a normalized distance, where 0 means \"occupying the exact same spot\", -1 and 1 mean \"just barely touching\", and numbers outside of the [-1, 1] range means not touching. It then computes " (math '(- (^ (abs norm_dist) -5) 1)) " to compute a force value between 0 and infinity for the appropriate distance, and then multiplies by +1 or -1 depending on if the force is coming from the left or right.")

        (para "For our purposes, the \"position\" of one of the balls that you see on the screen is denoted by the little crosshairs, which is supposed to represent the object's \"center\". During the collision you see the balls squash and stretch, but this is just a visual effect.")

        ; (para "There's one thing about this that I'd like to bring attention to, that's this \"this position - other position\" bit. The way this works is that each object, when at the stage when it's time to calculate its force, plugs its *own* position into \"this position\" and the other ball's position into the \"other\". So for the right ball, it's the right position minus the left. For the left ball, it's left minus right. So what this means is that for the right ball, this quantity is going to be positive, and that positive number will cascade through the expression and result in a positive force. For the left ball, this quantity will be negative, and cascade into an overall negative force.")

        ; (para "I admit, this is a little odd. Some of you may even see this as \"clever\", because it takes two different cases (the left and right case) and handles them both with the same expression. Some may see this as \"beutiful\" or \"elegant\", because this way of writing down the force doesn't have to differentiate the two different cases (left and right). It treats both exactly the same, which lines up with people's intuition that physics should act the same for both you and me. But some other people will probably see this as \"unclear\" and \"confusing\". For those last people, well I'm sorry. These lectures are just going to be like this. But also, \"confusing\" is often a function of familiarity. The more you see tricks like this, the more comfortable you may become.")

        ; (para "So! That's the collision force. And here it is in action. Ahh.")

        ))
; (display lesson1)

(use-modules (ice-9 textual-ports))
(let ((file (open-output-file (string-append (lesson-html lesson-number) "/index.html"))))
    (begin
        ; (write-string lesson1 file)
        (put-string file lesson1)
        (close-port file)))
