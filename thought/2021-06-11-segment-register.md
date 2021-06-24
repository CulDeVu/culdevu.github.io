== Segment registers did nothing wrong
=== wip

They just had lousy parents, that's all.

I know a little bit about the history of segment registers in the x86 family of microarchitectures. I also know, through hearsay, that people universally hated them. And it's easy to see why, what with all the `near` and `far` pointer nonsense that was needed to use the minuscule amount of extra memory that it would have given you. But maybe there's another way.

# Title

I'm probably going to end up showing how much of a n00b I am, but whatevs.

Consider the lifecycle of a classic expanding array.

It starts out, as most things do, as a dead simple fixed-size array at global scope. I reference items in it with a pointer. These pointers are stable. Life is good.

Then, I need it to expand. So I go and make sure that all of the pointers referencing into the array are indices instead, so that the buffer can be relocated on resize. All of the little functions I have around making things work either have to be modified to take an index now, or have to be called with `func(&buf[index])`. Usually a lot more typing than that, though. And now a lot of care has to be taken if it also turns out that the buffer needs to be resizable in the middle of a "frame," since that means nothing on the stack can hold a pointer for any length of time either!

Welp, now I need more than one of those buffers. Time to start modifying all those functions again to take a pointer to the buffer now too!

That was tiring. There are some alternatives, though. The important ones, in my mind:

- Have the buffer broken into multiple parts, probably double-indirection style (as opposed to linked-list style). If the sizes of each chunk are fixed, then an index works well. Going from pointer to index, however, is going to be painful if you have to do it all the time. There are tricks here, like putting all of the metadata for a chunk at the beginning, and a guard page past the end to trigger expansion.
- Reserve a huge region of virtual memory, like 100GB or something crazy. Commit/decommit the chunks on the end one at a time. Your pointers and indices are super easy to use, and all of your pointers are stable, even in the middle of modification.

In practice, the virtual memory technique seems to work well for normal application code, and it's the way I do it for most of my personal projects. I'm not sure how much I'd appreciate a third-party library doing something like that though, so maybe library code should opt for the double indirection technique.

# A mysterious third option

I have an idea for a different type of memory architecture that might... I wouldn't say "solve" this problem, or make anything better really. The idea is based on segment registers.

(I have no idea if this is an idea that's been explored already by others; I don't know what keywords to use to start searching. If you know, email me!)

Imagine an architecture where there were, say, each process gets a billion "segments" that are numbered starting at 0. You can then do something like:

```
seg rax                      ; New instruction. Picks one of the currently unused segments, marks it as "used," and stores the index in rax
mov rax:qword ptr[16], 5     ; Writes 5 at 16 bytes off of the segment returned in the last instruction
```

In this snippet, the processor keeps some internal table of which segments are in use and how they're mapped, much like a virtual memory table today. The new instruction `seg` tells the processor "initialize this segments with no upper bound." From this point on, any time someone indexes off of that segment by *any amount*, it will work. At least until physical memory runs out.

When a load or store happens to, say, `5:qword ptr[0xdead]`, a page will get committed to 