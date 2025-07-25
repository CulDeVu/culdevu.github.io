== Rack, REPL, and registers
=== More lisp machine work

Since last time:

# CAD

I need a rack for these register boards. They're designed to stack vertically, but not with stacking headers. They need a frame.

I haven't done much CAD before. I'll use blender once a year, and I've done some stuff in OpenSCAD, but neither are very good for what I'm trying to do.

img(openscad.png)[From a previous unfinished split keyboard project.]

Both are painful for doing CAD work. OpenSCAD is slightly better since the calculations are programatic and can be tweaked. But still painful.

OpenSCAD likes to lean into the "constructive" part of CSG. You end up trying to build things from rectangles, circles, ngons, extrusions, and convex hulls. If you want to use general polygons you have to specify all of the vertices, and you may as well be back in blender. If you want parallel edges, you're going to be doing a bunch of scratch trig in a notebook, which then become read-only pieces of code.

Since you rely on extrusions and convex hulls, you end up decomposing complex designs into tiny pieces. And then you have a ton of tiny pieces to give names, and all of their measurements to give names, and anytime you need pieces A B D and not C, that has to be given a name too. Add to that with how 2D shapes seem like second-class citizens, like how you can't convex hull two off-plane 2D shapes.

Making anything with rounded corners is painful. A minkowski sum is just not a good primitive for that.

"Measuring" a model isn't a thing you can do, so if you want to make a face of one object touch the face of another, pull out your trig notebook again!

Doing anything with round shapes, like cylinders and spheres always involves fiddling with global variables, and makes your render times asymptotic.

So I tried SolveSpace.

img(solvespace.png)[One of the PCB mounting ideas.]

Constraint solvers like SolveSpace are so much nicer. Being able to say "these two lines are parallel" is nicer than sins and cosines. The downside is that, at least for Solvespace, it can sometimes be a puzzle to state your intentions with the constraint primitives given to you. Here's a fun puzzle: find a set of constraints that finds the center of mass of an arbitrary quadrilateral.

Solvespace can be painful too.

If you want two shapes to touch each other, SolveSpace reaaaally likes to make your whole window turn red over some imagined infraction until you tell it to force to a triangle mesh. It also really likes to tell you that your design is over-constrained (you have to have EXACTLY 1 constraint per DOF).

I don't think there's a setting to increase the amount of polygons in a rounded edge, so I guess you just have to be fine with the default. That's fine though, because you don't want rounded edges anyways: if you have, for example, 2 cylinders stacked on top of one another, you have to be very careful or else you'll have dangling vertices in the resulting STL.

There's definitely a "clunky" feel. Like if you try to specify the distance between 2 parallel lines, which is a reasonable thing for someone to specify, it says "no" in a big window that you have to click "ok" on before trying a work-around. Or like how you can't specify a new workplace by clicking on a face. Or like the really weird mouse controls.

As much as I want to rep free software, and as much as I want to say "fuck Autodesk", I ended up trying Fusion360. Which is painful mostly because there's no linux version.

img(fusion.png)[Please don't look at that timeline.]

It was alright. There was definitely a large learning curve, and tons of jank. But it did feel polished in a way that the other options didn't.

All in all, I don't know which one is least bad.

I made a couple different designs for the rack:

img(rack_attempts.jpeg)[]

I'm really very bad at CAD work. I don't have a good "will this work in practice" sense.

I've settled on the middle one, the rack tower, for the time being. This probably isn't final.

# Boards

I haven't done much in this department. I put together the other 3 boards that I have the parts for.

Oh btw if you're wondering why all the pictures this time look like shit, it's because I recently got a Fairphone 5. I took all the pictures with it. You know how on the iPhone there's this large No Touchy Zone™ on the back with like 5 cameras lenses sticking sticking out? Right where you naturally touch the phone when pulling it out of your pocket? Well the FP5 copied this. But rest assured, no award-winning movies are going to be shot on the FP5. My 5 year old Pixel 3A has one camera lens that's half the size of the smallest FP5 lense, and still takes less muddy pictures.

img(rack.jpeg)[All 5 boards accounted for.]

img(open_circuit.jpeg)[I learned that the hotplate isn't some magical device that makes mistakes go away.]

img(burnt.jpeg)[I turned the heat up on the hotplate a little too high lol. That's not a shadow.]

img(diagram.jpeg)[The register assignments of the boards at the moment.]

I've been using a link(https://pine64.com/product/pinecil-smart-mini-portable-soldering-iron/)[Pinecil] for soldering. Idk if anyone else has noticed this, but after a while I think it starts to lose track of the temperature and start getting cold, while still reporting 300C. I find that I have to turn it off, let it cool down, and then turn it back on again sometimes or else all my joints start acting like they're being cold-soldered.

My next batch of register boards are going to be a bit different. I want to make the boards a bit smaller. Now that I have an idea of what I'm doing, I might go for stacking headers instead of the ribbon cables. I think I might also try LED arrays? And maybe an LED driver chip. Idk, I know nothing about electronics but I feel like all those transistors is a bit silly.

Also, I found out that link(https://www.adafruit.com/product/5346)[Adafruit sells a pre-made IO expander], so I might get that. That should be enough pins for the immediate future.

# Software

Not much here either. I wrote a simple bare-bones lisp compiler. Actually, the idea is for it to mock a REPL. Full source below.

I still haven't gotten around to writing a `letrec*` for the outer compiler, so still doing that manually.

Since I don't have any keyboard input yet, I just hardcode the ASCII keycodes: `40 43 32 40 43 32 50 53 32 53 41 32 56 41` which corresponds to the program string `"(+ (+ 25 5) 8)"`. It then parses and compiles it. By "compiles" I mean building the lists in-memory, translating the `"+"` string to a literal `+` builtin function, etc.

It then passes the little compiled program `(+ (+ 25 5) 8)` into a print function to display it. This simulates typing the chars out on the screen, and then `read`.

Then it passes the compiled program into the `exec` instruction, and prints the result.

img(output.jpeg)[]

The Arduino MEGA has 256KB of flash, but only 8K of RAM. I can stick the microcode table into flash, since that won't be modified. But the running program lives in RAM. I could do all sorts of fancy things, like storing the lower part of the stack in flash. But I don't want to; I want to write programs that will "get consumed" by the GC as the instructions are executed and are no longer needed.

What I'm trying to say is that a program of this size is near the limit of what the Arduino simulator will be capable of. The repl program is currently 7569 byes (973 instruction cons cells + 256 cons cell extra heap room @ 6 bytes/cons cell + ~200-ish bytes for simulator program text). And some bytes are needed at runtime for the stack and junk.

Note that I plan on running programs in RAM in the final build. On reset, the first microinstructions will copy the program from ROM to RAM. Also in the finished build I have enough address lines for 16K cons cells. Meaning it will be able to run programs about 60x as large.

When it first ran on the hardware, it took around 5m 40s to execute. This is running the simulator at max speed on the Arduino, which empirically is about 3100 lisp machine cycles per second.

A good amount of the runtime is taken up by GCs. It does 10 GCs while executing this program. So I did some work trying to reduce memory pressure.

The ucode for executing closures was pretty wasteful, pushing one new cons cell onto the heap for every argument. That was fixed, and now it's one push for all the arguments. This didn't actually reduce the number of GCs at all, surprisingly.

Also, the `lambda` instruction, for creating closures, pushed one extra cell onto the heap that it didn't need to. This reduced the number of GCs to 7.

Now, it takes 4m 20s to run. This is still pretty awful, but better. Currently the GCs account for ~67% of all cycles. Most of the GCs happen during compiling, because lists are being constructed and passed around.

The actual runtime, while annoying, isn't that concerning. I'm hoping to hit at least 50kHz, and I'm going to have a much bigger heap to work with, so on the finished hardware the repl program should run in well under 10s.

Here's some blinkenlights:

<video style="max-width:100%" controls><source src="blinkenlights.mp4" type="video/mp4"></video>

# Conclusions

I have some comments about the linear timelines in Solvespace and Fusion360.

I get the selling point of non-destructive editing. I'm nowhere near good enough to really take advantage of that though. If I go back to an earlier spot on the timeline and make any nontrivial change, chances are a later stage will become broken.

I'm sure this is a skill issue. I probably sound like a programmer complaining that "when I change a function signature, the callers break!" Which is of course silly. But regardless I do feel that non-destructive editing works better in, say, a node-and-wire image editor than it does in a CAD program.

I also get how it's easier from a programming perspective that dependencies between parts only go one way. In a linear timeline, parts later in the timeline can depend on parts earlier, but not the other way around. But to that I say: but you're a constraint solver! Solving circular dependencies is your job!

I bring this up because I've already run into situations where I want two parts to depend on each other. Say you have a "backbone" piece that a lot of other little pieces are built off of. But you don't know how large the backbone has to be until all of the little pieces are laid out. You'd have to design all the little pieces first, which feels unnatural.

Again, I'm sure this is a skill issue. At the same time, I would hate having to program in this way. Imagine you're writing an indie game. You start by writing the outermost leaf functions, like the background particle effects when you open a treasure chest. You toil for a while writing functions progressively closer to the trunk until you finally write the game's main loop. From then on, all you can do is tweak, or else everything breaks. That sounds awful.

But enough of that.

Next steps I think involve the ALU pieces. `+`, `~&`, and `eq?` are the main ones. I might etch these by hand, since I have some extra blanks laying around, and since I know that JLCPCB will force me to order 5x what I need.

I also definitely need to order more register boards. I'm also partway done with designing the swizzle boards.

So yeah. Just business as usual.

Here's the full text of the mock-repl program.

```
(define repl-instr
  (compile-full
    `(let* (
        (and (lambda (x y) (if x y 0)))
        (not (lambda (x) (if x 0 1)))
        (cadr (lambda (x) (car (cdr x))))
        
        (list? (lambda (x) (eq? ,node-type-list (type x))))
        (int? (lambda (x) (eq? ,node-type-int (type x))))
        
        (for-each-cons-helper (lambda (this f xs)
            (if (nil? xs)
              0
              (begin
                (f xs)
                (this this f (cdr xs))))))
        (for-each-cons (lambda (f xs) (for-each-cons-helper for-each-cons-helper f xs)))
        (for-each (lambda (f xs)
            (for-each-cons
              (lambda (x) (f (car x)))
              xs)))
        
        (~ (lambda (x) (~& x x)))
        (& (lambda (a b) (~ (~& a b))))
        (- (lambda (a b) (+ 1 (+ a (~& b b)))))
        
        (<
          (lambda (a b)
            (if (& 32768 (- a b))
              1
              0)))
        
        (/%-helper
          (lambda (f accum a b)
            (if (< a b)
              (list accum a)
              (f f (+ accum 1) (- a b) b))))
        (/% (lambda (a b) (/%-helper /%-helper 0 a b)))
        
        (print-number-helper
          (lambda (f x)
            (if x
              (let ((val (/% x 10)))
                (begin
                  (f f (car val))
                  (port 0 (+ 48 (car (cdr val))))
                  ))
              0)))
        (print-number (lambda (x) (print-number-helper print-number-helper x)))
        
        (print-helper
          (lambda (this x)
            (cond
              ((list? x)
                (if (nil? x)
                  (begin
                    (port 0 40)
                    (port 0 41))
                  
                  (begin
                    (port 0 40)
                    (for-each-cons
                      (lambda (ls)
                        (if (nil? (cdr ls))
                          (this this (car ls))
                          (begin
                            (this this (car ls))
                            (port 0 32))))
                      x)
                    (port 0 41)
                    )))
              ((int? x) (print-number x))
              
              ((eq? x +) (port 0 43))
              
              (1 (port 0 63)))))
        (print (lambda (x) 
            (begin
              (print-helper print-helper x)
              (port 0 10))))
        
        ; (readline (lambda () '(43  32  53  32  56)))
        ; (readline (lambda () '(40 43 32 53 32 56 41)))
        (readline '(
              40 
                43 32 
                40 
                  43 32 
                  50 53 32 
                  53 41 32
                56 41))
        
        (str-starts-with? (lambda (str char)
            (if (nil? str)
              0
              (eq? (car str) char))))
        
        (str-starts-int? (lambda (str)
            (if (nil? str)
              0
              (and (< 47 (car str)) (< (car str) 58)))))
        
        (*-helper
          (lambda (f accum a b)
            (if a
              (f f (+ accum b) (+ a -1) b)
              accum)))
        (* (lambda (a b) (*-helper *-helper 0 a b)))
        
        (read-int-helper (lambda (this chars accum)
            (if (str-starts-int? chars)
              (this this (cdr chars) (+ (* 10 accum) (- (car chars) 48)))
              (list accum chars))))
        (read-int (lambda (instr)
            (read-int-helper read-int-helper instr 0)))
        
        (read-list-helper (lambda (this parse-one instr)
            (if (str-starts-with? instr 41)
              (list '() (cdr instr))
              (let* (
                  (one (parse-one parse-one instr))
                  (value (car one))
                  (remaining-instrs (cadr one))
                  
                  (rest-one (this this parse-one remaining-instrs))
                  )
                (list (cons value (car rest-one)) (cadr rest-one))))))
        
        (parse-one-helper (lambda (this instr)
            (cond
              ((str-starts-with? instr 43)
                (list + (cdr instr)))
              
              ((str-starts-int? instr)
                (read-int instr))
              
              ((str-starts-with? instr 40)
                (read-list-helper read-list-helper this (cdr instr)))
              
              ((str-starts-with? instr 32)
                (this this (cdr instr)))
              
              (1 (port 0 69)))))
        (compile (lambda (instr) (car (parse-one-helper parse-one-helper instr))))
        
        (repl-helper
          (lambda (f)
            (let* (
                (compiled (compile readline))
                (_ (print compiled))
                
                (output (exec compiled))
                (_ (print-number output)))
              1
              )))
        )
      (repl-helper repl-helper)
        )
    '())
  )
```






















