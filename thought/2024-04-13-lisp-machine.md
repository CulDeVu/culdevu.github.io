== Lisp machine simulator
=== wip

# history

LISP Machine progress report:
Alan Bawden: went on to get his PhD at MIT, with Gerald Sussman as his advisor. His last publication was in 2008, but he seems to still be kicking around, at least as of 2019.
Richard Greenblatt: went on to found Lisp Machines Inc to sell the CADR machines.
Jack Holloway: co-founded Symbolics, of which much ink has been spilt. After that died, he started a company doing phone line stuff. He last year of Parkinsons.
Thomas Knight: went on to work on a number of very impressive things in the fields of supercomputing and biology. I had never heard of the term "adiabatic computing" before, very cool. He co-founded Ginkgo Bioworks, and seems to be doing very well.
David Moon: became a big contributor to Common Lisp. Is still around, still doing some programming  language work.
Daniel Weinreb: co-founded Symbolics. After that, he bounced around for a while writing LISP at a couple different companies. He died in 2012 at age 55 from cancer.

Storage Management in LISP-based microprocessor
Guy Lewis Steele Jr: what can't be said about him? emacs, common lisp, hacker culture, java, etc. He's still doing computer research do this day.
Gerald Jay Sussman: 

LAMBDA: The ultimate opcode
Guy Lewis Steele Jr
Gerald Jay Sussman

scheme-79 authors:
Jack Holloway
Guy Lewis Steele Jr
Gerald Jay Sussman
Alan Bell: I haven't been able to find anything about him in the intervening years. On a forum about a year ago someone popped up who seems to match, his mind seems to be going: https://www.quora.com/profile/Dr-Alan-Bell-PhD

CADR authors:
Thomas F Knight Jr
David A Moon
Jack Holloway
Guy L Steele Jr

Scheme-86 authors:
Andrew A Berlin: has worked on a very wide range of subfields over the years, started lots of companies. Seems like a cool dude.
Henry M Wu: did some hardware design, and then left the industry and now owns some hotels and restaurants


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

Memory is organized, of course, as cons cells. Instructions and data are organized in big trees, and the instructions are walked in depth-first order. Some registers, and the data bus both are able to hold a full cons cell.

It's funny, I'm still fuzzy on some of the details. But this is the current plan:

[picture]
[picture of lisp-79?]

Each cell has a type, value, and cdr pointing to the next cell.

The type is self explanatory. There needs to be enough types to represent all of the fundemental operations that the computer is capable of, and hopefully enough room for lot of use-defined types as well. The current list of fundemental types looks like:

3 constant-like types:
- nil: the terminating item of a list. Eventually, all lists end in one of these. See later discussion of pure functional memory.
- int
- builtin-function: its value is one of a list of builtin operations the computer can do. So like `add`, `car`, `nand`, `zero?`, etc.

3 list-like types:
- list
- call: an address to another list somewhere. Will push the CPU stack and put the CPU in a state where its expecting the next node to be a builtin-function or a closure
- closure: prodecure and environment

2 types needed for gc:
- reloc: a marker left in memory saying "the item that was here has been moved to this other location"
- empty: an empty cell, as opposed to a cell that has some other type of item in it.

The first slot in memory, at memory location zero, sits a nil element. This is so that lists can terminate with a cdr of `0`, instead of a whole new nil cell for each.

Which comes out to 8, or 3 bits. Not great, since it's already a little bloated and I don't even have a symbol type yet!

The most obvious possible changes to look into are: removing nil (nil is just a list whose value points to 0), and removing empty (empty could just be a nil with a cdr of 0? Because anything that's pointing to a nil with a cdr of 0 could just as easily have been pointing to location 0. The problem is that the GC would have to detect that, and I don't have any more free registers to stick that kind of info into. I may have to add a new control line...). That would give an extra 2 slots to work with and still be 3 bits, which would be nice.

Due to the constraints of the microcode ROM, I'm thinking I may have to restrict types to be... just 5 bits. Much much lower than I was hoping. If I could relax that constraint, I could concievably go up to like 10 bits (or higher??). I'm not sure, so I'll be calling this size TYPE-WIDTH.

The values are bigger. They need to be able to hold addresses as well as regular old integers and characters and the like. Of those, I suspect address sizes are going to be larger. Depending on the decision on TYPE-WIDTH, the ADDR-WIDTH could be 20 to 24 bits.

The cdr term is simple enough: it's an address of size ADDR-WIDTH. It points to the next cell in the linked list.

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

The data bus is organized like a cons cell, with some lines being thought of as the "type" portion, the "val" portion, and the "cdr" portion.

There are actually two data busses: the write bus and read bus. They're connected by some swizzling circuitry:
- type->type, type->val
- val->type, val->val, val->cdr
- cdr->val, cdr->cdr

This swizzling isn't accessible from userspace, it's controlled by the microinstructions.

The original idea for this is that you can read entire cons cells from memory in a single microinstruction, and that during normal computation many crossing writes and reads could be done at the same time on the one bus. But one big power that this design has, the ability for multiple registers to read from the same bus line, I think only ever gets used once in the whole microcode.

## Microcode

The contents of instr-type, instr-val, state-val, and a few other things are packed into an address and looked up in the microcode-address ROM once every macrocycle. Then, every microcycle that address is incremented and looked up in the microcode ROM. One output bit per control line.

The address fed into the microcode-address ROM is formed from:

- instr-type, the first however-many-bits it takes to encode a fundemental type (3 currently)
- instr-val, but only enough bits to encode a full type (5 currently)
- state-val (5 currently, but likely to change)
- 1 bit for "are the rest of the bits in instr-val zero?"
- 1 bit for "is instr-cdr 0?"
- 1 bit for "is head overflowed?"

The total here comes out to 16 bits, to be stored in a 64kb ROM no room at all to spare. I'm not a big fan of having no room, but I guess it is what it is for right now.

I haven't tallied up the amount of space the microinstructions will take up. Lots and lots of bit patterns apply to the same set of microinstructions, but some microinstruction expansions are pretty big. I wouldn't be surprised if it came out to be over 1000 microinstructions total to store in the ROM. Very manageable number.

At the end of each macrocycle, the state of instr-type, instr-val, state-val, and the other 1-bit calculations are snapshotted and stored into a couple dedicated microcode registers. This is so that the set of instructions that we're following doesn't change out from under us as we're executing and permuting the CPU state. At the end of each microcycle the stored microcode address is incremented, until it recieves the "latch microcode registers", in which case it resets to 0.

## Garbage Collection

One of the worst parts of the design.

If you look at the list of instructions, you'll see there's no "set!" or equivalent instruction; all computation is pure. If memory is allocated linearly upwards, that means that any addresses stored in a cons cell in the heap must be a smaller address than itself. This makes garbage collection pretty simple.

The GC is automatic: when it reaches the top of memory it stops the world and does its thing, and then returns to the state it was in before it started. There's currently no way to trigger a GC in userspace, but that's not a design decision or anything. It'd be very easy to add a builtin function `gc`, just haven't done it.

GC is done in four phases: an init phase, a downward phase and marks and deletes garbage memory, an upward phase that compacts, and a cleanup phase.

The init phase pushes all of the registers onto the heap, and sets their gc `mark` bits.

The downward phase walks the heap downards. If a cell is marked, it marks the cells its pointing to, and then unmarks itself. If a cell is not marked, it's replaced with an `empty` cell. At the end of this phase, all memory is unmarked, there are no `reloc` cells left, and there is no unreachable memory left in the heap.

The upward phase walks the heap upwards. It maintains two pointers, a low and a high. The low pointer searches for an `empty` cell and the high pointer searches for a non-`empty` cell to move to the low location, with the constraint that low pointer < high pointer. When a pair is found, the contents of the high pointer gets copied into the low pointer, and a `reloc` cell is put in its place notifying all cells further up the heap that it has moved. Before doing the move though, the contents of the high pointer are checked to see if *it* is pointing to any `reloc` cells, and rewrites them. At the end of this phase, the low pointer points to what will become the new `head`, there are no `empty` cells below the low pointer, and no non-`reloc` cells are pointing to a `reloc` cell. There are, however, still some `reloc` cells scattered around the heap that take up space and will get deleted in the next GC.

The cleanup phase recovers the registers it wrote into heap, and then continues, the CPU now in the same logical state it was before the GC started.

There are no GC-specific registers, though there is a couple GC-specific circuits. One detects if the `head` register overflows the top water line (set about 15 addresses down from the actual top of memory), but then changes its behavior to detecting if `head` is at the top of memory in the upward phase. 

There is also a dedicated `gc-reloc` circuit that computes `(if (= temp-type node-type-reloc) temp-val temp-cdr)`, which is used in the upwards phase to rewrite addresses if they point to a reloc. Otherwise, the microcode became way to unwieldy for me to write. The inclusion of this circuit really makes me question the decision to lean so heavily into the state-machine design. Like, the whole point of the state-machine design is to make it easy to handle function-call-heavy instruction graphs and conditional logic. But I now have dedicated circuitry to doing conditional logic, so...

The upwards phase leaves a lot to be desired. Its purpose is to compact memory so that `head` can be in a lower than it was before GC started. But the upwards phase ends up inserting tons of `reloc` junk in the heap that have to be compacted around. Those `reloc` cells will be deleted on the next GC, and new cells will move into them, but that will itself leave more `reloc` cells behind. The actual effect of the upwards phase, as it's written here, is to create "bubbles" that rise to the top of the heap over the course of several GCs.

## Chips

The heap memory will be implemented as a bunch of parallel banks each holding part of a cons cell.

[picture]

For example, if we use 52-bit cons cells, we might be looking at 7 8-bit SRAM chips that each hold 8 bits of the cell. This makes things much nicer, since memory accesses can be a single read/write macrocycle.

The same thing will happen with the microinstruction ROM. This makes it more annoying to write ROMs, but I'll just have to deal with it.

The rest will be pretty straightforward. Lots of tristate buffers, lots of latches, lots of logic gates.

# source