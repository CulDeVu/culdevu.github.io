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

In these last 3 examples, your supposed death date is fixed. They give you a sense of averages, but not of the whole probability distribution. In reality the mortality variance is huge: 

This last one doesn't really fit, but I can't leave it out. I listened to link(https://sphinx.acast.com/themagnusarchives/mag70-bookofthedead/media.mp3)[this episode] of the horror podcast The Magnus Archives years ago. There's probably some amount of inspiration taken from this story.

# The build

img(first_board.jpg)[caption]

img(upper_board.jpg)[caption]

imgcmp(both_boards.jpg)[caption](both_boards_closeup.jpg)[caption]

img(jumpers.jpg)[caption]

imgcmp(dremel.jpg)[caption](plexiglass.jpg)[caption]

img(final_tilt.jpg)[caption]

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

# Conclusion

I see 20-somethings online opine about death all the time. It's always so melodramatic. Hopefully this wasn't that. Hopefully this was cool and fun.

# Future work

Power outages are annoying. Setting the right date involves pressing those two buttons in the middle a bunch. Setting the default date involves reprogramming the Attiny. It'd be nice if I integrated a backup battery.

In the event of my death, it'd be cool if the death date on the bottom froze. It would turn into a decoration saying "this art piece was made by me, in memoriam me, passed away on <date>". How I'd accomplish that I don't know. I'm not totally sold on this idea. I also like the idea that it would keep ticking, predicting my life span were I still alive.

It didn't include a real time clock. I could have, just didn't want to deal with the hassle. From my tests, the Attiny keeps time relatively well. And if it drifts a bit, it's not that big of a deal. Despite calling it a clock, it's more of a calendar.

It's very sensitive to electrical noise in the air. I'm still not sure why. It's up on the wall away from people and clothes, but sometimes when I get close one of the latches will trigger and turn the display all garbled. I wake the chip up every hour to refresh the display for this reason. I would like to fix it though.

