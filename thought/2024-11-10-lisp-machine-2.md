== Lisp machine interlude
=== If this was a prusa printer build, I'd have eaten my weight in gummy bears already

Work on the lisp machine has been progressing excruciatingly slowly. Also, water is wet.

Since last time:

# Software

I had gotten the simulator to the point where I wanted to test larger programs in the simulator. I want to be able to run a simple REPL on the finished machine at the very least, so I started with that. But along the way I ended up doing a partial rewrite of the simulation.

The old design had a dedicated cons cell type called `node-type-call`. The idea is that you would tell the lisp machine explicitly to execute a list, as opposed to just passing it as a value. Not some amazing feature of the ISA or anything, it just made the microcode easier to write.

The problem is that, in the old design, you couldn't write a compiler that returns a `node-type-call`. If you tried, the `node-type-call` would be in the `instr` register at the start of the next macrocycle and it would be immediately executed. You'd have to return a raw list containing the instructions. And there'd be no possible way to construct a `node-type-call` that points to it either. You'd have to make a whole new instruction, called `eval`, whose job is to execute lists. Which was supposed to be the job of `node-type-call`. So I ended up getting rid of `node-type-call` and just implemented the normal lisp calling convention: lists encountered while running instructions are executed, lists encountered while returning from calls are not.

I also made a simple little microcode compiler. Instead of listing out the literal microcode signal lines for each macrocycle like this:

```
(from-instr-cdr to-mem-addr swizzle-cdr->car)
(from-mem-mark from-mem-type from-mem-car from-mem-cdr to-instr-mark to-instr-type to-instr-car to-instr-cdr)
```

I now write something like this:

```
(instr (mem (cdr instr)))
```

This made the rewrite much easier. It's a little too simplistic for the gc phases, so I do those manually still. Which is unfortunate, because those are the most complicated, and it's where it would help a lot. The microcode compiler is a bit greedy with its use of temporaries, and the gc phase is short on extra register space. Hopefully I can go back sometime and make this better.

One of my longer-term goals is to make a microcode compiler that works from first principles: you feed it in the metacircular evaluator and it outputs the entire microcode for the computer. Outside of being dorky and cool, it would actually be nice to have a parameterizable machine. Currently, a bunch of cycles are wasted because the machine only looks one at one instruction at a time. It'd be nice if I could specify to the microcode compiler "take the metacircular evaluator, inline it n times, and tell me how many cpu states and registers you will need, and how many microcode instructions it will turn out to be."

But in any event, the compiler is now working. Meaning, I have a test case where the simulator is running a small lisp compiler, that compiles into its own native ISA, and then runs it. It's quite slow, but it does work.

In addition, there's now output targets for building and dumping the microcode ROM and instruction ROMs. Every step is a step closer to running real programs on a real physical machine!

# First board

Making the boards has been an exercise in patience, and a wrestling match with my own stubbornness.

I really wanted to do make the board without having to use a PCB manufacturer. I've tried JLCPCB for a previous keyboard project before and it was a nightmare:

- They said it would take 2 weeks to ship, it took *2 months*
- There was this whole debacle with my bank. My account was banned because of it, and I had to make a new one. Because JLCPCB is headquartered in Hong Kong, every time I want to order from them I have to call my bank ahead of time and ask permission. I've had this problem anytime I want to pay any company outside the US. It's not even a China issue, I even had problems paying for Sublime Text, whose company is headquartered in Australia. It's all I can do not to just rant about this for a couple paragraphs. I hate my bank.
- I'm a software guy. I like my edit-debug cycles to be measured in seconds, not weeks.

So I ended up spending a couple months waffling around with etching PCBs.

My first experiment was to make this thing:

img(usbc_tester_top.jpeg)[USBC to USBA tester]

Just to get my feet wet, I made a little device that tests if a USBA-to-USBC cord has data lines, or just power lines. This is a practical tool on its own. All my devices have USBC charging ports, so I have a bunch of these cords. You plug both ends into their respective slots, and if all 4 leds light up, then all 4 lines are present. If only the outer two light up, then it's a power-only cord. If some other combination, your cord is broken.

I got some single-sided copper cladded PCB boards, and drew the design out freehand with a sharpie. I etched it in some ferric chloride, and it came out great on the first try!

imgcmp(usbc_tester_markings.jpeg)[The board after etching, but before removing the sharpie etch mask](usbc_tester_bottom.jpeg)[After drilling holes, tinning, and soldering everything together]

Not the greatest craftsmanship, but it works.

Here's a test for part of one of the lisp machine's register boards. Uses 2 components, a 3-state bus transciever (74HC245) and an 8-bit latch (74HC573), with room for pins in the middle for testing.

I carefully marked out the spacing needed for the component pins, and freehanded the rest.

The etch on this one was really good! There were some spots where the sharpie was a bit thin and got etched away, but other than that it was very clean.

imgcmp(reg_test_markings.jpeg)[The register test board, before etching.](reg_test_zoom.jpeg)[After etching. This zoom-in was the result of a pen-slip that got *very* close to shorting two adjacent lines. It was etched perfectly, no under or overetching. I estimate the gap to be ~5 thou]

img(reg_test_done.jpeg)[With everything soldered on. No tinning because I'm lazy.]

Again, worked perfectly first try. The trick to clean etches I think is to use fresh ferric chloride, and do it outside in a warm summer day. I definitely noticed the etches getting worse the more I used the current batch of ferric chloride.

A full register (reduced a bit from last time because the amount of parts and effort required for this fucking project is spiraling out of control) is 40 bits: 16bits for the car field, 16bits for the cdr field, and 8bits for the type/gc mark. I've been focusing on making some 16bit boards, since they'll all have the same layout.

I've tried a couple ways of making them:

imgcmp(reg_perfboard.jpeg)[About half of a 16bit register board, laid out on a perfboard. Wayyy too much of a pain to make.](reg_etch.jpeg)[A 16bit version of the 8bit board from above. I never could get the ink transfer method to work, so still just freehanding it. Honestly not that hard or time-consuming. Didn't end up using this one because I couldn't figure out an easy way to give it a second layer.]

In the end, I cracked and got a pcb manufactured. The process didn't go as horribly this time. Here's a 16bit board, fully assembled:

imgcmp(manu.jpeg)[First finished 16bit register board. 1 in-bus port, 1 out-bus port, and one intermediate port that goes to the microcode controller, the adder, stuff like that.](manu_zoom.jpeg)[Oh god my eyes! My solder paste is pretty old, and it didn't go very well. And then I tried reviving it with more flux, and a little bit of isroprop, and that went even worse. I'm also terrible at heat gun soldering.]

Of course, there was a dumb mistake on the boards. In the link(SOT23.pdf)[documentation I was reffering to], the footprint of the transistors, SOT23, it says that the distance from the centerline to the *outer edge* of the bottom pad is 1.35mm . I accidentally used that number as the distance to the *center* of the bottom pad, and so the transistors don't sit quite right on the board. I have to really double or triple up on the solder to get them to stick.

I tested the board, and the chips work fine, though two leds don't come on (because of the above problem).

# Future

The plan now is to:

- Make yet another simulator, this time running on an arduino. The idea is to get the lisp machine simulator up running on an arduino, and then gradually start replacing functionality with real boards. I have an arduino mega, which has enough pins to be able to do this and also drive a lcd screen. This is currently in-progress.
- Put together more boards. This means correcting the issues, ordering more, getting solder paste that isn't trash, etc.
- Finish writing a little repl that can run in the simulator. The sim is very bare-bones, so I've just been dragging my feet a little bit.

