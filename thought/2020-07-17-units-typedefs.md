== Units and typedefs
=== wip

In an earlier post I mentioned in passing that I don't like "semantic web" for the same reason I don't really like typedefs. Here I expand on the two examples I gave there and go more in depth into it.

There's a general engineering practice that I think is kinda important, but I see people everywhere violating. Including me. To make it easier to talk about, here are 3 concrete and very common manifestations:

- A program dealing with physical quantities, whose values are "unit agnostic." Not in the $\pi$-theorem way, but where the values are supposed to be in some imaginary units, and when dealing with real units you need to do conversions. So calls like `meters_to_length()` and `time_to_seconds()`. However, upon closer inspection these imaginary units are just the standard SI units (meters, seconds, watts, etc), and the conversions from SI units to the imaginary ones and back are just the identity function.
- A program has a concept of `memory` in pointer+length form, and pointer+length strings are defined something like `typedef memory string`. Another example, a codebase wants to talk about time quantities but needs it to be easy to work with (adding, subtracting, scaling, passing to libraries, etc), so there's a `time_diff_t` type that ultimately comes down to a `typedef double time_diff_t` or `typedef int64_t time_diff_t` or similar.
- [something]

The common theme here is implying a difference between two things that are really exactly the same. There are 2 reasons for disliking this:

- Mental overhead/distress from trying (in vain) to keep the two things separate 
- The more an abstraction gets used, the more that underlying workings become to be relied upon, intentionally or not. `typedef`-ing a fundamental abstraction in your codebase (which is how it usually happens) reads like a claim that the underlying type doesn't really matter, which is far from the truth.

I actually think that strong typedefs would make things worse. When I program on my personal side projects (which are the ones where I use C), I try to program at the limit of how fast I can program. At that speed, the cognitive load of the choice of which type to use is noticeable enough to be very annoying over time. In C, there's already so much mental overhead associated with type differences: `u64` and `uintptr_t` and `size_t`, `s64` and `ptrdiff_t`, casting results of `sizeof` everywhere because it should have been defined as a signed value, etc.

As much as I've tried to train myself to not listen to the aspy part of my mind when programming, it's there. Constantly knowing that there are all of these places where I should have wrapped a value in `meters_to_length(val)` *will* eventually result in a moment of weakness where I troll around "correcting" them. The issue here is that, as the adage goes, untested code is buggy code. The claim that `float val2 = meters_to_length(val1)` is more correct than `float val2 = val1` depends on the assumption that                   would have to be tested. I'm not talking about the kind of `typedef`s that people change and test all the time on different platforms. The `typedef`s I'm talking about here have more in common with dead code than anything else.

There are 2 main reasons that I use types. The first is to correct for typos ("oops, these two parameters for this function are switched!"), and the second is to automatically propagate changes to data that is scattered all over a program (if I deal with a block of data in multiple places, I want those reads and writes to automatically stay in sync).

In the first case, [todo]

What people *want* is to have an automatic system that will detect when one change somewhere breaks another piece of code somewhere else. I think for these people, the holy grail is code that is almost completely local and all bugs that a change would create are somehow detected by the compiler. All while also being easy to edit. For me, that'd be nice I guess

**"All abstractions are equivalent to the collection of their underlying pieces. Are you saying there should be no abstractions?"**

Um... uh... shut... shut up! Stop using logic against me on my own blog!

In all seriousness though, I think there's a very big difference between abstraction-as-information-hiding and abstraction-as-simplification. I think the abstractions that have value are the ones that, when not leaking, simplify the *process* of doing something complex. But that's just a thought that hasn't had time to ferment yet, so idk.