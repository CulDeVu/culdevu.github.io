== Death clock
=== wip

img(final.jpg)[]

We have here a death clock.

I've mounted in on the wall above my desk. It's simple looking, mounted on wood and perfboard, simple electronics with lightly artful wiring. The brains, located in the center, is an Attiny 85.

The bottom LEDs display today's date. The top LEDs display a death date.

Every day at midnight it rolls a new death date. The clock knows my birthdate. It also has inside it a table of mortality statistics by age, provided by the 2025 Social Security Trustees Report. With these, along with the current date, it can sample my probability distribution of dying on a specific date, given that I've already lived to the current date.

I started working on this about 2 months ago. A couple hours here, a couple hours there. This picture was taken a couple weeks ago. And yes, I know the year in the photo is wrong.

# Prior work

Writing on the subject of one's own mortality goes back thousands of years.

One of Gilgamesh's adventures involves link(https://web.archive.org/web/20060206220555/http://alexm.here.ru/mirrors/www.enteract.com/jwalz/Eliade/159.html)[becoming afraid of death and seeking immortality]. 

A popular sub-genre is of heroes attempting to avert prophesied deaths. Oedipus is a classic, but the story of Achilles in The Illiad is probably just as old. I'm interested to know what the oldest example of this genre is. There's link(https://origin.web.fordham.edu/halsall/ancient/1100egyptmagic.asp)[this 20th dynasty story] about prince Naneferkaptah getting cursed for stealing a god's book. I'm not sure this one counts though, because although his sister-wife and son die seemingly by fate, this happens because of the actively angry Throth and Ra.

Since the scientific revolution, these questions have been dealt with dealt with quantitatively.

I suspect that visualizations of life expectancy are likewise very old, though I don't know of any examples. There's link(https://en.wikipedia.org/wiki/File:Nightingale-mortality.jpg)[this famous diagram] of army fatalities by month between 1854 and 1856 (published in 1858), which doesn't quite fit but is interesting nonetheless.

Visualizations of life and death are pretty common on the internet, especially on social media. I remember sharing this link(https://lifeboxes.neocities.org)["your life where one box equals one month"] link on facebook back in 2012. There are tons of these sorts of things, where your life gets "shaded in" as it happens.

In the realm of electronic clocks, there are products out there that help visualize your lifespan. By coincidence link(https://inqfactory.com/pages/death-clock)[this clock] was released as part of a viral video just a couple weeks ago.

Even in the realm of bespoke hobby electronics art pieces there are examples. link(https://learn.adafruit.com/mindfulness-clock-of-doom/)[Here's one by Adafruit], and link(https://github.com/adamtait/ArduinoDeathClock)[here's one of the many, many examples on github].

In these last 3 examples, your supposed death date is fixed. They give you a sense of averages, but not of the whole probability distribution. In reality the mortality standard devation is huge: 18 years for males according to the data I'm using.

This last one doesn't really fit, but I can't leave it out. I listened to link(https://sphinx.acast.com/themagnusarchives/mag70-bookofthedead/media.mp3)[this episode] of the horror podcast The Magnus Archives years ago. I just liked it, and it fits with this project thematically.

# The build

img(first_board.jpg)[The first board about to be tested.]

An attiny85 as the brains on the breadboard.

The ICs are all 74HC595 daisy chained together, for that old school look and feel.

Programmed by the arduino to the right.

img(upper_board.jpg)[The second board being assembled.]

I wanted some nice wiring, with a bit of an old-school bent. I like browsing hackaday.io and such looking at all the new homebrew cpus that people make on breadboards. I like the wiring aesthetic in those projects.

Personally I find soldering to be a chore. I have to pull out all the stuff and set up the fans and put on the gloves and clean up afterwards. Pretty much the moment I put everything away is when I notice a problem that needs correcting. And out it all comes again.

For SMD it's not so bad. Reflow is less messy, quicker, and easier to correct mistakes.

For THT I've been finding myself wirewrapping more lately. It's nice: I don't have to pull out the soldering supplies if I find an issue on the board. I can unwrap, correct, and then rewrap, all dry.

It doesn't work for everything, and the boards still needed a good bit of soldering. But if I can wirewrap half the connections, then any problem on the board has a 50% chance of being able to be fixed without the soldering equipment.

Idk, it's just nicer.

imgcmp(both_boards.jpg)[Testing both boards.](both_boards_closeup.jpg)[A close up.]

The two display boards are daisy chained together, which ended up causing signal problems. At least, I think that's what's causing the signal issues. I'm honestly at my whits end trying to figure it out. Luckily, when mounted on a wall far away from moving people and other electronics it operates fine.

In this picture the two boards are in the same orientation. I ended up flipping the orientation of the bottom board later.

Also notice that I was powering the whole thing via the power pins on the arduino. After a while I started wondering how that worked. I've been slowly working through a link(https://www.youtube.com/playlist?list=PLUl4u3cNGP62UTc77mJoubhDELSC8lfR0)[lecture series on power electronics], and I wanted to see some of that magic in action.

It turns out that the magic was actually one single linear regular on the verge of melting. So I stopped that.

img(jumpers.jpg)[The two sections, and a middle control section, mounted on a backboard.]

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

# Discussion

These visualizations and clocks and stuff that people make, they aren't being made just for shits. It's not "just art," there's some intention behind it. People have some anxiety about spending their time "right," and they make tools to help put things into perspective. These clocks are tools.

I feel that way too. Part of the idea for the clock is that it might be helpful for making decisions.

There are things that you can spend your time doing. Some of them you do or don't *have* to do, some of them you do or don't *want* to do.

Things come in four kinds:

- things you *have* to do and *want* to do
- things you *have* to do but *don't want* to do
- things you *don't have* to do but *want* to do
- things you *don't have* to do and *don't want* to do.

Hopefully you're already doing the first, and not doing the fourth. Which leaves the middle two.

We're going to look at a simple toy model. Every day you choose between option 2, called work, or option 3, called fun. A day of work increases your money by 1. A day of fun decreases your money by 8 but increases your happiness by 1. You get a 4% interest rate on your money, accrued daily. The goal is to maximize happiness.

As it is said, all models are wrong. But some models are specifically chosen, with carefully tuned parameters, to back up my shitty point.

In this toy model there are three important strategies.

## The analog nomad

Back in the day, people would travel around Europe by train and bus, from city to city. They would take on odd jobs in each city to pay for experience. Apparently these people didn't even work remote programming jobs at Stripe.

In our model, the analog nomad will work for the requisite 8 days, and then have fun for 1 day. Rinse and repeat.

The analog nomad will never save up. They'll never reap the benefits of that sweet 4% interest.

To say that they spend money as fast as they make it isn't untrue, but it's not the goal. The goal is to try to, at any given moment, rack up as much happiness as possible as soon as possible. Tomorrow may never come, life is not guaranteed.

According to our model, this strategy has an expected happiness of 2202, and a variance of 672^2.

If the interest rule were taken away, this strategy would be optimal: if $X$ is a random variable representing age at death, then any other strategy $H(x)$ would obey $H(x) \leq \frac{x}{9}$. This of course mean that $E[F(X)] \leq \frac{E[X]}{8} = E[\text{happiness of analog nomad}]$.

With interest, this strategy is the least optimal strategy in terms of expected happiness, at least among the strategies that are even trying. 1 fun day per 8 work days is the minimum.

On the other hand, this strategy minimizes variance.

## The public school guidance counselor

The public school guidance counselor will advise all children to stay in school, go to college, get a job in a stable job sector, put your head down and work hard, save as much money as possible, and retire no earlier than 60.

It's safe, and it's what they themselves are planning on doing. "Just another couple years of these gen a's saying I sound like a wagie, and I'll be able to take that vacation I've been planning!"

In this model, people take no fun days until the "retirement" cutoff, and then only take fun days (until the money runs out).

They reap the full, maximum benefit from the 4% interest. Empirically, the optimal retirement age is 62.8 years according to this model. This cutoff results in an expected happiness of 4534 and variance 3120^2.

This strategy is optimal in expectation. (That's not actually true, the actual optimal smooths the hard cutoff out by a couple years. The higher the interest rate the sharper the optimal cutoff is. By 4%, it's practically indistinguishable from the public school guidance counselor strategy).

This strategy also unfortunately has one of the least optimal variances among all strategies. It deliberately pushes happiness as far into the future as possible. Over 20% of men die before age 62, so they would all get a score of 0. The graph is bimodal, driving up the variance.

## The desk jockey

The desk jockey is the everyman. The normal person. They hold down a steady job like a normal person, and maybe take a vacation of every year or two. Yeah it's not optimal, but so what? The desk jockey deserves it.

So the strategy is: take N number of days of fun each year until "retirement", which is going to be different for every value of N.

img(everyman_plot.svg)[plot]

Here's a graph different values of N. The bottom left corner is equivalent to the analog nomad and the top right is equivalent to the guidance counselor.

The graph is amazingly linear! Each additional day off the desk jockey takes per year subtracts 50-60 expected happiness, subtracts 60-80 stddev, and adds 0.01-0.1 years to your retirement age (not shown).

None of these feel strategies feel compelling. The extremes are too extreme. The middle ground offers a tradeoff between the extremes, but doesn't feel like it improves the situation.

## The death clock

I can't match the analog nomad for consistency, and I can't match the guidance counselor for expected results. I'm okay with taking a hit to my expected score for a bit of consistancy, but I don't want to trade them 1-to-1. I want a completely different strategy.

My intuition says that you should work at the same rate that you live to see the results.

So every day you would pick a random death date proportional to your probability distribution of death dates, given that you've already lived this long ($P(X=x | X \geq \text{today's date})$). Assuming that sample death day, calculate whether you could spend all your moneyon fun before you die. If yes, work today. If no, take a fun day. Repeat tomorrow.

The formula used for "if you can spend it all before you die" is what you'd expect. If $\Delta d$ is the current sampled hypothetical death date - today's date, it is:

$$
\text{money} \cdot \text{interest}^{\Delta d} - 8 \frac{\text{interest}^{\Delta d + 1} - 1}{\text{interest} - 1} \ge 0
$$

This will weight fun days more towards your elder years, but some will still happen when you're young. You still reap a lot of the benefit of the interest rate, but those who die young don't go out with a happiness of 0.

The expected happiness for this strategy is 3850, and the variance is 2648^2.

Let's see where this falls on the plot. Remember, we want to be to the right and below the purple line.

img(death_clock_plot.svg)[]

... well damn. So much for that intuition.

Luckily we can fix this. If we plan on bottoming out our cash stack a bit before the end date, we can jump to the other side of the line.

$$
1.3 \cdot \text{money} \cdot \text{interest}^{\Delta d} - 8 \frac{\text{interest}^{\Delta d + 1} - 1}{\text{interest} - 1} \ge 0
$$

img(overspend_plot.svg)[]

Of course all of this is silly. Life doesn't work anything like the model described here. The point is that a real life death clock is a potentially useful tool. Asking the death clock to roll a new hypothetical death date, and then taking that date seriously, is NOT an obviously stupid thing to do.

Also, "money" and "work" here is a stand-in for all sorts of things that give returns over time, but that don't make you happy.

This may be extrapolating too much, but I see this strategy as being helpful even beyond that. Say you hate your job but the pay is decent. When do you quit? Well, you ask your death clock every day.

For me, most days it will give me a date 40 years from now, and I'll say "if that's my real death date, I can stomach my job for one more day."

Every once in a while it will give me a date within the next few years, to which I'll say "yikes, I better make plans to go visit with those friends I haven't seen in a while, but ultimately one more day at this job won't kill me."

Any date much sooner and I'd probably give notice that I'm leaving, or at least take the opportunity to start looking around.

But there will be a couple times in my life that it will give me a date within the week, and that's when I text my boss and tell him I'm not showing back up.

# Conclusion

I see 20-somethings online opine about death all the time. It's always so melodramatic. Hopefully this wasn't that. Hopefully this was cool and fun.

I have a strange relationship with emotions, like many of my brethren on the internet.

I also have a strange relationship with stuff. I don't like having tons of possessions. I pack light and I like to live light. My bed frame is an upgrade from the mattress that laid on the floor for so many years, but god damn is it a pain to move.

This clock is different though. It's something I think I want to keep for a long time.

There are many future directions from here.

Power outages are annoying. Setting the right date involves pressing those two buttons in the middle a bunch. Setting the default date involves reprogramming the Attiny. It'd be nice if I integrated a backup battery.

In the event of my death, it'd be cool if the death date on the bottom froze. It would turn into a decoration saying "this art piece was made by me, in memoriam me, passed away on xxx". How I'd accomplish that I don't know. I'm not totally sold on this idea. I also like the idea that it would keep ticking, predicting my life span were I still alive.

It didn't include a real time clock. I could have, just didn't want to deal with the hassle. From my tests, the Attiny keeps time relatively well. And if it drifts a bit, it's not that big of a deal. Despite calling it a clock, it's more of a calendar.

It's very sensitive to electrical noise in the air. I'm still not sure why. It's up on the wall away from people and clothes, but sometimes when I get close one of the latches will trigger and turn the display all garbled. I wake the chip up every hour to refresh the display for this reason. I would like to fix it though.

