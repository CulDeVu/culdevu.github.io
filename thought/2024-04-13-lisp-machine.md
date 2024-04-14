== Lisp machine simulator
=== wip

# history

# The plan

I want to build one. An actual factual lisp machine. Is that not the coolest idea ever?

I was, of course, hugely inspired by all the people on Youtube and hackaday.io and the homebrew computer webring, as well as all the other people I've been able to find who make homebrew computers. I know this was a big thing back in the 80s, and it seems like there's been an explosion in recent years. Though it's hard to know without more research. The websites and blogs of the people who would have been doing this sort of thing back in the late 90s and mid 2000s would be mostly gone. The internet really is the largest force for information destruction ever created :(

Anyways, 

...

It's a large undertaking, but it goes something like this:

- Phase 1: some simulators. I've written a couple so far to get my bearings. The most recent one (listed in full at the bottom of the post) simulates just the computer portion. In other words, just the part that executes instructions, no external hardware. It simulates the computer on the scale of clock signals and control lines, bus lines, and latches. So not quite logic gates, but close enough that I'm pretty confident that this design works.
- Phase 2a: some software. Notably a compiler and some software for interacting with hardware. I'm still a bit split on where I want to go with this.
- Phase 2b: the build. Self-explanatory.
- Phase 3: ???

...

It's going to get tedious calling it "my computer" over and over, so let's give it a temporary name. Let's call it "SM-1" for "scheme machine 1".

# Design

The broad design borrows from LISP-81 in that the whole computer is set up like a state machine. On the large scale, the computer walks the instruction graph one cons cell at a time and permute the machine's state. For example, an `if` node will change the `state` register to `doing-if`. If the computer encounters a `0` when the state register is set to `doing-if`, the state register will then change to `doing-if-skip`. And so on.

That's about where the similarities end. Mine uses a much less compact instruction encoding, much much less instructions, a single-layered microcode design, and a simplified bus model. 

## Instruction Encoding

## Architecture Overview

The SM-1 of:

- An address bus that can be written to. Has width ADDR-WIDTH.
- A data bus of that can be read from and written to. Has width CONS-WIDTH.
- RAM, ROM, external devices behind a simple memory map.
- A microcode ROM, with [todo]
- 8 registers: instr, stack, accumulator, state, temp, envt, mem-addr, head

## Registers and Bus Design

- instr: holds the currently executing instruction. CONS-WIDTH.
- stack: holds the head of the call stack. Is CONS-WIDTH. Could be ADDR width, since I never have much need of the value during normal execution, but I use it during the GC for the extra space.
- accumulator: holds intermediate data for whatever stack frame we're in. This could be like the running sum of a `+` instruction, or storing the address of the instructions of a closure while collecting arguments, etc. CONS-WIDTH
- state: holds the machine's state. Used for answering questions like "I have a instr register holding the integer 5. What am I doing with it?". CONS-WIDTH
- temp: for intermediate calculations. The original idea was that, while the other registers have important meanings that persist through multiple instructions, the temp register would be some extra space that could be used *during* the execution of an instruction. But then it turned out I only ever really used it during the GC.
- envt: holds the calling environment. So you might access the calling function's argument by `(car envt)`. By far the worst and weakest part of the design, but definately not too hard to change. CONS-WIDTH
- mem-addr: whatever is in this register is getting emitted onto the memory bus. ADDR-WIDTH
- head: the top of the heap. Very poorly named. ADDR-WIDTH

- micro-index
- micro-state
- micro-mem-overflow
- micro-index

## Microcode

## Garbage Collection

## Chips

# source
