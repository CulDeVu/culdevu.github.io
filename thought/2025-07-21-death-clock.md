== Death clock
=== wip

img(final.jpg)[]

We have here a death clock.

I've mounted in on the wall above my desk. It's simple looking, mounted on wood and perfboard, simple electronics with lightly artful wiring. The brains, located in the center, is an Attiny 85.

The top LEDs display today's date. The bottom LEDs display a death date.

Every day at midnight it rolls a new death date. The clock knows my birthdate. It also has inside it a table of mortality statistics by age, provided by the 2025 Social Security Trustees Report. With these, along with the current date, it can sample my probability distribution of dying on a specific date, given that I've already lived to the current date.

I started working on this about 2 months ago. A couple hours here, a couple hours there.

# Prior work

Prior work on the subject of mortality goes back thousands of years. [maybe include stuff about gilgamesh? research on the first example of a hero trying to avoid a profecised death?]

In the modern day these questions are dealt with quantitatively. It's hard to make any big life decision without someone talking about average life expectancy.

I suspect that visualizations of life expectancy is likewise very old, though I don't know of any examples. There's link(https://en.wikipedia.org/wiki/File:Nightingale-mortality.jpg)[this famous diagram] of army fatalities by month between 1854 and 1856 (published in 1858), which doesn't quite fit but is interesting nonetheless.

Visualizations of life and death are pretty common on the internet, especially on social media. I remember sharing this link(https://lifeboxes.neocities.org)["your life where one box equals one month"] link on facebook back in 2012. There are tons of these sorts of visualizations, where your life gets "shaded in" as it happens.

In the realm of electronic clocks, there are products out there that predict or help visualize your death. By coincidence link(https://inqfactory.com/pages/death-clock)[this clock] was released as part of a viral video just a couple days ago.

Even in the realm of bespoke hobby electronics art pieces there are examples. link(https://learn.adafruit.com/mindfulness-clock-of-doom/)[Here's one by Adafruit], and link(https://github.com/adamtait/ArduinoDeathClock)[here's one of the many, many examples on github].

In these last 3 examples, your supposed death date is fixed. They give you a sense of averages, but not of the whole probability distribution. In reality the mortality standard variation is huge: 18 years for males according to the data I'm using.

This last one doesn't really fit, but I can't leave it out. I listened to link(https://sphinx.acast.com/themagnusarchives/mag70-bookofthedead/media.mp3)[this episode] of the horror podcast The Magnus Archives years ago. There's probably some amount of inspiration taken from this story.

# The build

img(first_board.jpg)[The first board about to be tested.]

An attiny85 as the brains on the breadboard.

The ICs are all 74HC595 daisy chained together, for that old school look and feel.

Programmed by the arduino to the right.

img(upper_board.jpg)[The second board being assembled.]

I wanted some nice wiring, with a bit of an old-school bent. I like browsing hackaday.io and such looking at all the new homebrew cpus that people make on breadboards. I like the wiring aesthetic in those projects.

Personally I find soldering to be a chore. I have to pull out all the stuff and set up the fans and put on the gloves and clean up afterwards. Pretty much the moment I put everything away is when I notice a problem that needs correcting. And out it all comes again.

So I've been finding myself wire-wrapping more lately. It's nice: I don't have to pull out the soldering supplies if I find an issue on the board. I can unwrap, correct, and then rewrap, all dry.

It doesn't work for everything, and the boards still needed a good bit of soldering. But if I can wirewrap half the connections, then any problem on the board has a 50% chance of being able to be fixed without the soldering equiptment.

Idk, it's just nicer.

imgcmp(both_boards.jpg)[Testing both boards.](both_boards_closeup.jpg)[A close up.]

The two display boards are daisy chained together, which ended up causing signal problems. At least, I think that's what's causing the signal issues. I'm honestly at my whits end trying to figure it out. Luckily, when mounted on a wall far away from moving people and other electronics it operates fine.

In this picture the two boards are in the same orientation. I ended up flipping the orientation of the bottom board later.

Also notice that I'm powering the whole thing via the power pins on the arduino. After a while I started wondering how that worked. I've been slowly working through a link(https://www.youtube.com/playlist?list=PLUl4u3cNGP62UTc77mJoubhDELSC8lfR0)[lecture series on power electronics], and I wanted to see some of that magic in action.

It turns out that the magic was actually one single linear regular on the verge of melting. So I stopped that.

img(jumpers.jpg)[The two sections, and a middle controll section, mounted on a backboard.]

The middle section has some buttons for setting the date after a power outage, and some ICSP pins for programming. I just use an arduino as the programmer, and `avrdude` to flash.

```
# To compile
avr-gcc -c -Os -nostdlib -nodefaultlibs -mmcu=attiny85 main.c
avr-gcc -c -Os -mmcu=attiny85 start.S
avr-gcc -nostdlib start.o main.o -o output.out -T link.ld
avr-objcopy -O ihex -j.text -j.data output.out output.hex

# To flash
avrdude -p t85 -c stk500v1 -P /dev/ttyACM0 -v -v -b 19200 -U flash:w:output.hex:i
```

The circuit boards are mounted on the backboard by some 1cm brass standoffs.

I was originally wanting to mount it on some dark walnut. But the hardwood store is a ways away, and some family had some spare poplar boards that were the right size. So I went with poplar. I might change it at some point.

imgcmp(dremel.jpg)[Cutting the plexiglass.](plexiglass.jpg)[The plexiglass cut and it all put together.]

Julie 3d printed this cool dremel table saw thing. We have a quick-connect head that we use with the cutting wheel bits that I thought would be an issue, but it wasn't.

The study only *sort of* smelled like melted plastic afterwards!

img(final_tilt.jpg)[Obligatory three quarters shot.]

The ports on the boards are JST-XH. Why not JST-RE? Shrug, I don't know why we have these and not those. I've noticed that XHs are more common and cheaper online for some reason.

I ordered some 22 AWG jumper terminals without realizing they weren't the right size for the JST female ports. But after just plugging the wires in directly, I think they look cool without them.

# Justification

I have a strange relationship with emotions, like many of my bretheren on the internet. [todo]

I have a strange relationship with stuff. [todo]

These visualizations and clocks and stuff that people make, they aren't being made just for shits. It's not "just art," there's some intention behind it. People have some anxiety about spending their time "right," and they make tools to help put things into perpective. These clocks are tools.

I feel it too. Part of the idea for the clock is that it might help me make decisions. The idea is that 

There are things that you can spend your time doing. Some of them you do or don't have to do, some of them you do or don't want to do.

Things come in four kinds:

- things you have to do and want to do
- things you have to do but don't want to do
- things you don't have to do but want to do
- things you don't have to do and don't want to do.

Hopefully you're already doing the first, and not doing the fourth. Which leaves the middle two.

[todo]

In this toy model there are two important strategies.

## The smelly teen spirit

The teen spirit will work for the requisite 8 days, and then have fun for 1 day. Rinse and repeat.

The teen spirit will never save up. They'll never reap the benefits of that sweet 4% interest.

To say that they spend money as fast as they make it isn't untrue, but it's not the goal. The goal is to try to, at any given moment, rack up as much happiness as possible as soon as possible. Tomorrow may never come, life is not guarenteed.

This strategy is least optimal strategy in terms of expected happiness, at least among the strategies that are even trying.

[todo: proof?]

However, this strategy also minimizes variance.

## The high school guidance councelor

The high school guidance councelor will advise you to stay in school, go to college, get a job, put your head down and work hard, save as much money as possible, and retire no earlier than 65.

It's safe, and it's what they themselves are planning on doing. "Just another couple years of these zoomers calling me a wagie, and I'll be able to take that vacation I've been planning!"

In the model, these people take no fun days until the "retirement" cutoff, and then only take fun days (until the money runs out).

They reap the full, maximum benefit from the 4% interest. Empirically, the optimal retirement age is [todo]. This cutoff results in an expected happiness of [todo].

This strategy is optimal, in that no other strategy results in a higher happiness. (That's not actually true, the actual optimal smooths the hard cutoff out by a couple years. The higher the interest rate the sharper the optimal cutoff is. By 4%, it's practically indistinguishable from the high school guidence councelor strategy).

This strategy also unfortunately has one of the least optimal variances among all strategies. It deliberately pushes happiness as far into the future as possible. Roughly 25% of men die before age 65, so they would all get a score of 0. It lets the unfortunate who die young take a score of 0 happiness to boost the expected happiness of the whole.

## The wojak

The wojak is the everyman. The normal person. They hold down a steady job like a normal person, and maybe take a vacation of every year or two. Yeah it's not optimal, but so what? Wojak deserves it.

It's hard to come up with a definite score for this strategy. [todo]

None of these feel compelling. The extremes are too extreme, and the middle ground is too lame.

## The death clock

I can't match the smelly teen spirit for variance, and I can't match the guidance councelor for expected value. But maybe I can take a small hit to expected value while keeping variance low.

My intuition says that you should do work days at the same rate that you live to see the results.

So every day you would pick a random death date proportional to [todo]. Assuming that sample death day, calculate whether you could spend it all on fun before you die. If yes, work today. If no, take a fun day. Repeat tomorrow.

This will weight fun days more towards your elder years, but some will still happen when you're young. You still reap a lot of the benefit of the interest rate, but those who die young don't go out with a happiness of 0.

The expected happiness for this strategy is [todo], and the variance is [todo].

# Conclusion

I see 20-somethings online opine about death all the time. It's always so melodramatic. Hopefully this wasn't that. Hopefully this was cool and fun.

There are many future directions from here.

Power outages are annoying. Setting the right date involves pressing those two buttons in the middle a bunch. Setting the default date involves reprogramming the Attiny. It'd be nice if I integrated a backup battery.

In the event of my death, it'd be cool if the death date on the bottom froze. It would turn into a decoration saying "this art piece was made by me, in memoriam me, passed away on <date>". How I'd accomplish that I don't know. I'm not totally sold on this idea. I also like the idea that it would keep ticking, predicting my life span were I still alive.

It didn't include a real time clock. I could have, just didn't want to deal with the hassle. From my tests, the Attiny keeps time relatively well. And if it drifts a bit, it's not that big of a deal. Despite calling it a clock, it's more of a calendar.

It's very sensitive to electrical noise in the air. I'm still not sure why. It's up on the wall away from people and clothes, but sometimes when I get close one of the latches will trigger and turn the display all garbled. I wake the chip up every hour to refresh the display for this reason. I would like to fix it though.

