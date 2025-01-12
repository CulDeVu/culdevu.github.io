== The first couple boards
=== Don't forget to hang your blinkenlights from the eaves this christmas!

Since last time:

# Software

I wrote another simulator. This will be the 4th one, by my count. Unlike the others, this one is designed to run on an Arduino.

The idea is this: I would write a simulator of the lisp machine on my Arduino, at the level of busses and logical components. I would expose the major busses on the IO pins, and gradually replace parts of the simulation with real circuit boards on those busses. Output (at least at the beginning) is done through an LCD screen.

Some changes had to happen:

I added a `port` instruction for outputting to the LCD screen. Previously, the machine would output a result by storing it in the `instr` register and transitioning to an illegal state, stopping the simulation. Seeing the number on a screen is much nicer.

Very simple programs were taking forever. I would write a simple program to multiply two numbers together, and the sim would show that dozens of garbage collections happening. There are a ton of reasons, but I made a big dent in the problem by changing how local variables work. Previously, you would call `(envt)` to get the contents of the environment register, a list type. Then, to get the n'th item in the environment you'd do `(car (cdr ... n-1 of these ... (cdr (envt))))`. This results in a *ton* of function calls, which then generate a ton of garbage on the heap, filling up memory. So I added a feature where you can do `(envt 10)` instead to get the 10th item in the environment. Honestly, I'd be happier with a system that could handle call stack garbage in a more general way. But that's a problem for another day.

Jesus christ, I didn't realize that how deep the arduino rabbit hole goes. There are huge, blatant bugs in the compiler that have been there for years. For example, this compiles:

```
typedef struct { int a; } A_t;
int bar(A_t a) { return a.a; }
void setup() {}
void loop() {}
```

But this doesn't:

```
void foo() {}
typedef struct { int a; } A_t;
int bar(A_t a) { return a.a; }
void setup() {}
void loop() {}
```

The latter claims that `A_t` on line 3 is not declared. This is because the arduino compiler (in the IDE as well as the `arduino --verify file.ino`) first runs a preprocessor over the file that rewrites shit, adds `#include` s to the top of files, moves shit around. But it doesn't create an AST or anything before it starts rewriting your file, so sometimes it rewrites your perfectly valid C into non-valid C before passing it off to `avr-gcc`.

In the above specifically, it's detecting functions `foo`, `bar`, `setup`, and `loop`, and inserting forward declarations at the top of the file. Presumably to "fix" the error that will show up when someone writes two mutually recursive functions.

link(https://code.google.com/archive/p/arduino/issues/188)[This old issue] may very well be the first person to complain about this problem. By coincidence, I'm posting this just 8 days short of its 15th birthday!

Honestly, I find this crazy. Like, why? Someone in their programming journey will learn about function prototypes vs definitions in like the 2nd or 3rd week [citation needed]. In an effort to make programming slightly less confusing for the first 3 weeks, the Arduino devs decided to make programming slightly harder and less predictable for weeks 4 through infinity.

Luckily, you can step around this nonsense: make a `main.h` file that contains everything you would normally put in your `.ino` file, and make your `.ino` file look like this:

```
#include "main.h"
```

The arduino compiler only does it's stupid preprocessing on `.ino` files, not on `.c` or `.h` files. So those are safe. *For now*. You could also attach `--verbose` to the `arduino` command, and then ditch the `arduino` command.

Also, damn arduinos have a tiny amount of RAM. Luckily, the MEGA has quite a bit of flash. If you have lots of data to stuff into flash memory, the normal `PROGMEM` macro doesn't work. You have to explicitly place the data on the *far* side of the address space, and let the code in the `.text` section have the lower addresses. You have to add `__attribute__((__section__(".fini1")))`, or one of the other `fini`'s defined in the compiler's linker script. Reading can be done with a custom `memcpy` function using `pgm_read_byte_far`.

After all was done, I had a simple hello-world program running in the simulator, on the arduino:

```
(define output-instr
  (compile
    '(begin
      (port 0 72) ; H
      (port 0 69) ; E
      (port 0 76) ; L
      (port 0 76) ; L
      (port 0 79) ; O
      
      (port 0 32) ; Space
      
      (port 0 87) ; W
      (port 0 79) ; O
      (port 0 82) ; R
      (port 0 76) ; L
      (port 0 68) ; D
      (port 0 33) ; !
      (port 0 10) ; \n
      )
    '()))
```

Here, `begin` is a macro that's just built-in to the compiler. Port `0`, output to the LCD, is the only one implemented. I also have some stub microcode for `(port 1)`-style 1-operand instructions, which would take input. The idea is that, instead of interrupts, which would make everything much more complex, each peripheral would just maintain its own ringbuffer, and respond like traditional memory-mapped hardware.

# The build, first steps

I was gifted a link(https://www.adafruit.com/product/5903)[hot plate] for christmas, so no more heat gun for me! As a result, my boards look much better now:

imgcmp(clean_latches.jpeg)[](clean_transistors.jpeg)[]

Last time I had trouble with a pcb defect (my fault) where the collector and emitter pads on the transistors were a bit too far apart. But with the hotplate, it didn't matter, all the joints are nice and solid.

Part of that is probably to do with the fresh solder paste I ordered too, lol.

Here's a pic and video of the the hello-world program with the first board:

img(close_up_hello.jpeg)[Sorry for the contrast, it's hard to take a picture of the screen. Also, the weird "hamburger" glyph is the \n character. I include it in the output, because the sim also runs on my computer for testing.]
<video style="max-width:100%" controls><source src="hello.mp4" type="video/mp4"></video>

Note, in the video, I've deliberately slowed the clock so that you can see it executing each `port` instruction. Also in the video, the blinky lights are wrong. There was a bug in the simulator, where the read-instr-car signal line wasn't getting reset, so it's latching other data on the bus. It's fixed in the later video.

I suppose now is a good time to talk about general structure.

The computer consists of 2 major busses: an output bus and an input bus. These busses are register-sized, so they actually consist of 4 smaller sub-busses: mark, type, car, and cdr. On the write cycle, components in the computer will write to the output bus. Then a dedicated bit of swizzle circuitry will latch, and maybe cause the values in the sub-busses to switch lanes. Like, maybe the value in the type sub-bus needs to be sent to the car sub-bus. Then, on the read cycle, those values get sent down the input bus, where they can be latched by all of the components. 

So it looks something like this:

img(bitmap2.png)[Data goes round and round in a loop.]

In the real machine, these busses are going to be long ribbon cables, with IDC ports punched in. The "components" above will be stacked circuit boards in a tower.

A real board looks like this:

img(board_diagram.jpg)[Note the extra port on the right. It's there to be able to bypass the buss structure if I need to, or to be able to debug.]

The stacking design was inspired by many homebrew cpus, like link(https://incoherency.co.uk/blog/tags/cpu.html)[this one]. Though I currently have yet to make any hardware for the stacking.

Currently, the machine looks like this:

imgcmp(arduino_tower.jpeg)[By the end of this, all the back row IO pins are taken, and it's still not enough](board_tower.jpeg)[2 boards in a stack. Currently being held up by the stiffness of the ribbon cables.]

The top board is the `instr` car register, the bottom one is the `state` car register.

I wrote another program to show off the blinkenlights. This one multiplies `(* 12 13)` and displays the result:

```
(define math-instr
  (compile-full
    '(begin
      (port 0 49) ; 1
      (port 0 50) ; 2
      (port 0 42) ; *
      (port 0 49) ; 1
      (port 0 51) ; 3
      (port 0 61) ; =
      
      (let* (
          (~ (lambda (x) (~& x x)))
          (& (lambda (a b) (~ (~& a b))))
          
          (- (lambda (a b) (+ 1 (+ a (~& b b)))))
          
          (<
            (lambda (a b)
              (if (& 32768 (- a b))
                1
                0)))
          
          (*-helper
            (lambda (f accum a b)
              (if a
                (f f (+ accum b) (+ a -1) b)
                accum)))
          (* (lambda (a b) (*-helper *-helper 0 a b)))
          
          (/%-helper
            (lambda (f accum a b)
              (if (< a b)
                (list accum a)
                (f f (+ accum 1) (- a b) b))))
          (/% (lambda (a b) (/%-helper /%-helper 0 a b)))
          
          (print-helper
            (lambda (f x)
              (if x
                (let ((val (/% x 10)))
                  (begin
                    (f f (car val))
                    (port 0 (+ 48 (car (cdr val))))
                    ))
                0)))
          (print (lambda (x) (print-helper print-helper x)))
          )
        (print (* 12 13)))
      
      (port 0 33) ; !
      (port 0 10)) ; \n
    '()))
```

I don't have a `letrec` macro implemented in the compiler yet, so I'm just doing that job manually, creating an auxiliary function and passing it itself. `print` is implemented by repeatedly dividing and modulo-ing by 10. I currently don't have any right-shift instructions in the computer, so that's why it's doing the O(n) multiply.

And here it is, in all its blinky glory:

<video style="max-width:100%" controls><source src="math.mp4" type="video/mp4"></video>

In this video, the computer is not being slowed. It's limited by what the arduino can do, but this is its current max rate.

You can see in the video that, periodically, the `state` changes to 0b00011001 and `instr` seems to be counting down, or `state` equals `0b00011010` and `instr` is counting up. Those are the two GC stages happening. The multiply generates a *ton* of garbage. Currently, the computer needs to GC 5 times (!!) to run this program, which is why the program takes like 40 seconds to finish. That's prety awful, but I plan on working on it.

I've gotten the boards *almost* fully self-hosting. With the two busses and the control lines, I don't have enough pins. I'm 4 bits short, so I supplement the data coming in or off the busses with the remaining bits that are *supposed* to be there according to the simulation.

## Future

I want to start building the frame, and getting more boards put together. Which means CAD work, and ordering more parts.

I'd like some more IO pins. I'd like to find some sort of IO expander kit, if anyone makes them. If not, there are link(https://ww1.microchip.com/downloads/en/devicedoc/20001952c.pdf)[plenty of I2C addressable chips].

I have to say, I'm really happy that things seem to be picking up. I've got some actual boards, and an actual microcontroller running actual cons cells, being controlled by microcode that actually works!

It's probably just me, but I have a weird "thing" with handling leaded solder. I don't mean that I'm squeamish about it. I mean I lay down newspaper on the table before I solder, and change my clothes afterwards. And in the weeks afterwards, I avoid setting things, like my phone, on the table where I solder, because of the contamination from of bits of solder -> table -> phone -> hand -> mouth. So, okay, maybe I *am* a little squeamish about it.

I've read online that ~3.5 ug/dL of lead in my blood is cause for concern, even for adults, so for me that comes out to ~150 ug of lead total in my bloodstream.

For reference, take this board, and let's zoom into the little speck of solder next to the 0805 resistor:

img(solder_blob.jpg)[A little bit of solder splatter]

This little spec is, I feel, pretty representative of the sorts of tiny little bits of solder that end up flying off sometimes while soldering.

My calipers measure it to be ~0.32mm, from the picture I measure it to be ~0.39mm. Taking the lower measurement, that comes out to a volume of ~0.137mm^3. If this little dot was 63/37 Sn/Pb, then it would contain ~426.2ug of lead, about 3x the 150ug limit!

Now I don't know the body's digestive efficiency of lead. Or distribution of sizes of little solderballs, or the propensity of lead solder joint's to shave off little pieces through friction, or how small a spec of lead dust has to be to get picked up and carried through contact, etc etc. This is all very un-scientific. But that's anxiety, right? It's not rational.

People online say that, hey man, don't worry, it's not a problem, just don't eat while soldering, wash your hands afterwards, I've been using 63/37 my whole life, and look at me, I'm fine, and also the rosin fumes are probably worse, and lead-free solder can be toxic too ya know. I don't know, man.

All this is to say, my roll of leaded solder is getting low, and I'm probably going full lead-free after it runs out.

Other than that, I think the plan is to keep chugging along, try to get to the point where I've made and mounted all of the register boards.

