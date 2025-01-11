== Lisp machine interlude
=== wip

Since last time:

# Software

I wrote another simulator. This will be the 4th one, by my count. Unlike the others, this one is designed to run on an Arduino.

The idea is this: I would write a simulator of the lisp machine on my Arduino, at the level of busses and logical components. I would expose the major busses on the IO pins, and gradually replace parts of the simulation with real circuit boards on those busses. Output (at least at the beginning) is done through an LCD screen.

Some changes had to happen:

I added a `port` instruction for outputting to the LCD screen. Previously, the machine would output a result by storing it in the `instr` register and transitioning to an illegal state, stopping the simulation. Seeing the number on a screen is much nicer.

Very simple programs were taking forever. I would write a simple program to multiply two numbers together, and the sim would show that dozens of garbage collections happening. There are a ton of reasons, but I made a big dent in the problem by changing how local variables work. Previously, you would call `(envt)` to get the contents of the environment register, a list type. Then, to get the n'th item in the environment you'd do `(car (cdr ... n-1 of these ... (cdr (envt))))`. This results in a *ton* of function calls, which then generate a ton of garbage on the heap, filling up memory. So I added a feature whre you can do `(envt 10)` instead to get the 10th item in the environment. Honestly, I'd be happier with a system that could handle call stack garbage in a more general way. But that's a problem for another day.

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

This old issue may very well be the first person to complain about this problem, almost exactly 15 years ago: link(https://code.google.com/archive/p/arduino/issues/188)[adfa].

Honestly, I find this crazy. Like, why? Someone in their programming journey will learn about function prototypes vs definitions in like the 2nd or 3rd week [citation needed]. In an effort to make programming slightly less confusing for the first 3 weeks, the Arduino devs decided to make programming slightly harder and less predictable for weeks 4 through infinity.

Luckily, you can step around this nonsense: make a `main.h` file that contains everything you would normally put in your `.ino` file, and make your `.ino` file look like this:

```
#include "main.h"
```

The arduino compiler only does it's stupid preprocessing on `.ino` files, not on `.c` or `.h` files. So those are safe. *For now*.

Also, damn arduinos have a tiny amount of RAM. Luckily, the MEGA has quite a bit of flash. If you have lots of data to stuff into flash memory, the normal `PROGMEM` macro doesn't work. You have to explicitly place the data on the *far* side of the address space, and let the code in the `.text` section have the lower addresses. You have to add `__attribute__((__section__(".fini1")))`, or one of the other `fini`'s defined in the compiler's linker script. Reading can be done with a custom `memcpy` function using `pgm_read_byte_far`.

# The build, first steps

I was gifted a hot plate for christmas, so no more heat gun for me! As a result, my boards look much better now:

[image]

Part of that is probably to do with the fresh solder paste I ordered too, lol.


