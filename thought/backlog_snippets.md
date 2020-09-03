# The abyss stares back

I've noticed a pattern in myself over the last few years. My opinion on all of this tends to wildly flip-flop back and forth at predictable intervals. Not on whether or not CSS is shit; that's always been true. It's whether or not I think that pushing through anyways is worth it. The way it goes is this:

**Me, during the up-swing**: "Yes, CSS is garbage and nearly unusable in all but the simplest of scenarios. But so much of the world runs on this language, so as a programmer (or even anyone making a living off of computers) I need to learn it and be comfortable around it. I'm not in a position where I can reasonably live a webtech-hermit existence, and even if I was there's still the problem of employers. The difference between my effectiveness/efficiency when I feel comfortable with my environment, feel in control, and free to make constant progress vs when I don't is *dramatic*. But even if I were to show an employer that difference it wouldn't matter, since developing on software with a team of near-strangers means that everyone is going to be uncomfortable, nobody can feel in control and aware, and rate of progress depends on others. The thing they have to care about is conformity, so just learn the dumb tech that everyone is using, and maybe one day you'll get to the point where you can work in an environment that feels like your personal projects and will make you *want* to come to work every day."

**Me, during the down-swing**: "No... *NO*. No. If these people wanted me to make websites using their language, they wouldn't have made it so completely fucked. Why did I spend 2 hours fiddling with CSS knobs, re-reading specs, and *eventually failing* to get 2 pieces of text to draw at the same baseline? That should take 1 line of code! Those things that make me more effective/efficient also affects how I feel, and I feel bad after I know I did a shitty job. So why would I spend a day of stop-and-go progress, manipulating hierarchies that I know going in won't be able to express the things I want to see output at the end of the day? I've used hierarchies enough times to know they make a very poor stand-in for logic, so why put up with them? Yes all that stuff about employers are true, but there's another road that I can take: when I have to use these things I shouldn't try super hard to do a good job (because I know I won't be able to anyways), and use my remaining energy to focus on the side projects that *do* make me happy. If I can show my ability to make things on my own, maybe someone will hire me and let me do things my way. Or if one of these projects turns out to be sellable, that's another way out. Either way, the road is out and not further in."

It's probably a good thing that those down-swings don't last very long. They seem detrimental to my livelihood. For the past 3 years that I've noticed it, it seems to be a yearly cycle with the down-swing happening around early/mid-summer till around early/mid-fall.

If it's not obvious, this applies to everything. Replace "CSS" with anything you want (anything web, anything corporate, etc) and you should be able to fill in the rest of the nouns fairly easily. That's not to say that these things have no value or are purely bad. But I am saying that if 3 months out of the year I feel like something is pushing me back to my "happy place," there's something wrong.

I'm left wondering whether it was even a good idea to go into programming. Don't get me wrong, I love programming: I love creating things and computers are by far the greatest creation tools humans have ever made. But when I look at people in our sister profession, IT, I feel a little jealous. All the IT people that I've known all seem very chill and relaxed. They all seem to know that everything is broken but they still try to get everything working in the simplest possible way with the least amount of moving parts. Their decisions seem to come from actual experience with actual peoples' problems. This is contrasted against our profession, where it seems to me like solving actual peoples' problems is only an excuse, a backdrop to do what programmers *actually* want, which is to satisfy their aspyness and OCD cravings for everything to exist in hierarchies, for all things to be categorized and organized *just right*. I used to not like the idea of IT, and I told myself that it was because I don't like playing plumber, I don't like it when things fail silently or cryptically, and I don't like feeling like I have no control over a system of things that all act on their own. But looking back at the last couple days redoing this site, and my last year of professional programming I'm reminded of a pot that called a kettle black.

--------------------------------
# ??

One big question that I have as an engineer is what linear-time costs I choose to accept and which ones I don't. 

--------------------------------
== Image codec ideas
=== descr

I have some ideas for how this should go.

For a pixel block $A$, the traditional way of doing this is by using the $B = DCT$ matrix and transforming the rows and columns into frequency space, one after the other:

$$
B A B^T.
$$

In this post, we're going to be looking at different choices of B with `u8`s as its primary number system instead of floats.

# What can we do from here?

Traditionally, the point of the frequency change of basis is 3-fold:

- To set the later entropy encoder up for success
- Lossy compression by quantizing (rounding) some or all of the coefficients decays reasonably
- Lossy compression by zeroing some or all of the coefficients decays reasonably

As a simple, consider the matrix 4x4 matrix

$$
B = 
\begin{pmatrix}
	-3 &  2 & 1 & 1 \\
	-4 &  2 & 1 & 1 \\
	-2 &  1 & 0 & 1 \\
	1  & -1 & 0 & 0
\end{pmatrix}, B^{-1} =
\begin{pmatrix}
	1 & -1 &  0 & 0 \\
	1 & -1 &  0 & -1 \\
	1 &  0 & -1 & 1 \\
	1 & -1 &  1 & 1
\end{pmatrix}
$$

# Non-power-of-2 block sizes

A more ideal change of basis would probably look something like

$$
B = 
\begin{pmatrix}
	\begin{matrix}
		1 & 1 & \dots & 1 \\
	\end{matrix} \\
	\dots
\end{pmatrix}, \, B^{-1} =
\begin{pmatrix}
	\begin{matrix}
		1 \\ 1 \\ \vdots \\ 1
	\end{matrix} & \>
	\dots
\end{pmatrix}.
$$

The reasoning her is that $B$ should mix all of the elements of $A$ together equally for the first element, and $\alpha B^{-1}$ should behave reasonably when the zeroing compression strategy is used (so when all but the first coefficient is zero'd out, the output should look something like an average of the pixels in $A$).

and this is of course can't even be fixed with a scalar on the $B^{-1}$ if $n$ if even, since $(B B^{-1})_{11}$ will be even. But if $n$ is odd, this works. 

[go into detail about why this doesn't work when averages are not multiples of 3]

[go into detail about matrix generation and how that works]

--------------------------------
== O(1) becomes O(n) in a loop
=== descr

Once a week, every week, for the past 3 years I've gotten an email from Dropbox telling me that one of my accounts is almost full and that I should upgrade. 

At work, every time I write a new class I type `private final Object lock = new Object();`, and most methods begin with `synchronized (lock) {`. How many times have I typed `private` without it doing anything?

At work, the thing I just wrote does a `.put` into a hashmap, followed immediately by a `.get` on the same key every time a particular message gets processed. I was told I did "good work."

--------------------------------
==
=== descr

There's a general engineering practice that I think is kinda important, but I see people everywhere violating. Including me. To make it easier to talk about, here are 3 concrete and very common manifestations:

- A program dealing with physical quantities, whose values are "unit agnostic." Not in the $\pi$-theorem way, but where the values supposed to be in some unknown/unimportant units, and when dealing with real units you need to do conversions. So calls like `meters_2_length()` and `time_2_seconds()`. However, upon closer inspection these imaginary units are just the standard SI units (meters, seconds, watts, etc), and the conversions from SI units to the imaginary ones and back are just the identity function.
- A program has a concept of `memory` in buffer+length form, and pointer-length strings are defined something like `typedef memory string`. Another example, a codebase wants to talk about time quantities but needs it to be easy to work with (adding, subtracting, scaling, passing to libraries, etc), so there's a `time_dif` type that ultimately comes down to a `typedef double time_dif` or `typedef int64_t time_dif` or similar.
- 

