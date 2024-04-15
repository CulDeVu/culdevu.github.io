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

The timing is broken up into macrocycles, microcycles, and nanocycles. Typically one instruction from the instruction graph is consumed every macrocycle. Each macrocycle will consist of many microcycles, one for each microinstruction stored in the microcode ROM for a given state. Each microcycle is 4 nanocycles.

I may have gone a bit overboard with the clock. I got really anal about signal integrety. What happens when, for a brief moment, two parts of the CPU see different clock states (spooky circuits)? What happens when a latch triggers but the data isn't there yet?

The nanocycle timing I came up with works under the principles that, during a single nanocycle, signals should become stable (no rising edge detectors), and if two adjacent nanocycles overlap a bit it's okay. So we have this:
[todo: a diagram]

The write nanocycle lets registers and external memory write to the bus(ses). The read cycle lets them read. The two microinstruction cycles are for controlling the microcode ROM.

- Each read/write nanocycle is separated a bit, so the data bus can't thrash.
- The two microcode nanocycles are a bit silly. It's so that there can be a 2-layer latch for the microcode state. That's needed because, if either the read or write nanocycle overlaps with the latching of the microcode lookup address (described later), the CPU can end up executing a mixture of two different microinstructions.
- This timing is very easy to do, just a single clock downsample by 2 and a few gates.

Which components are doing the reading and writing this microcycle is governed by the microcode ROM. The CPU state is packed into an address and fed into the microcode ROM. One bit of output per control line.

My count so far of the control lines:
- 6 for each full CONS-WIDTH register: a read and write signal for each type, val, and cdr parts of the register.
- 2 for each ADDR-WIDTH register.
- 7 for bus swizzling.
- 1 for each bit of concrete work circuitry (add circuit, nand circuit, etc).
- 2 for read/write from memory.
- a couple for the microcode circuitry?

So some number in the 50s probably. Large, but manageable. It's also very wasteful (e.g. you can't write the type and val portions of a register and also activate the type->val swizzle, as that would thrash the bus) but I'm not concerned about that right now.

All of the registers are connected to the data bus, but the mem-addr is also connected to the memory bus.

## Registers and Bus Design

- instr: holds the currently executing instruction. CONS-WIDTH.
- stack: holds the head of the call stack. Is CONS-WIDTH. Could be ADDR width, since I never have much need of the value during normal execution, but I use it during the GC for the extra space.
- accumulator: holds intermediate data for whatever stack frame we're in. This could be like the running sum of a `+` instruction, or storing the address of the instructions of a closure while collecting arguments, etc. CONS-WIDTH
- state: holds the machine's state. Used for answering questions like "I have a instr register holding the integer 5. What am I doing with it?". CONS-WIDTH
- temp: for intermediate calculations. The original idea was that, while the other registers have important meanings that persist through multiple instructions, the temp register would be some extra space that could be used *during* the execution of an instruction. But then it turned out I only ever really used it during the GC.
- envt: holds the calling environment. So you might access the calling function's argument by `(car envt)`. By far the worst and weakest part of the design, but definately not too hard to change. CONS-WIDTH
- mem-addr: whatever is in this register is getting emitted onto the memory bus. ADDR-WIDTH
- head: the top of the heap. Very poorly named. ADDR-WIDTH

These descriptions of the register uses change during garbage collection.

- micro-index
- micro-state
- micro-mem-overflow
- micro-index

The data bus is organized like a cons cell, with some lines being thought of as the "type" portion, the "val" portion, and the "cdr" portion.

There are actually two data busses: the write bus and read bus. They're connected by some swizzling circuitry:
- type->type, type->val
- val->type, val->val, val->cdr
- cdr->val, cdr->cdr

This swizzling isn't accessible from userspace, it's controlled by the microinstructions.

The original idea for this is that you can read entire cons cells from memory in a single microinstruction, and that during normal computation many crossing writes and reads could be done at the same time on the one bus. But one big power that this design has, the ability for multiple registers to read from the same bus line, I think only ever gets used once in the whole microcode.

## Microcode

The contents of instr-type, instr-val, state-val, and a few other things are packed into an address and looked up in the microcode-address ROM once every macrocycle. Then, every microcycle that address is incremented and looked up in the microcode ROM. One output bit per control line.

## Garbage Collection

One of the worst parts of the design.

If you look at the list of instructions, you'll see there's no "set!" or equivalent instruction; all computation is pure. If memory is allocated linearly upwards, that means that any addresses stored in a cons cell in the heap must be a smaller address than itself. This makes garbage collection pretty simple.

It's done in two phases: a downward phase and marks and deletes garbage memory, and an upward phase that compacts.

## Chips

# source
