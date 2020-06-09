In this section I talk about some of my past projects that I've done, professional and personal. The projects listed are the ones that I believe are the most influential to what kind of programmer I am now, and the descriptions are about why that's true. For practical reasons each section is listed most recent first, so the "story" might be a little hard to follow. Last updated June 2020.

# Professional projects

img(nodestar1-small.jpg)[]

In early 2019 I started work at link(https://www.metsci.com/)[Metron], a US government contractor. I work on a team that uses monte carlo techniques to track moving objects. The actual project is a descendant of link(https://www.metsci.com/ama/nodestar/)[this one], which has the only publicly available description and image that I could find of the project.

Before that I got my first programming job by worming my way from a graphic design intern to a scripting/automation person to a programmer. My first project was to create a piece of billing software required for a multi-million dollar contract. It was a massive failure, a lot of it my fault. A couple days before all hell broke loose I whipped up a quick app that had to be manually run once a month, but did 90% of the job. It worked, and I even got a bonus for it! I'm sure there's a lesson to be learned in all of that, but I'm not sure what it is.

# Personal projects: physics/math simulations and research

imgcmp(sponza.png)[Global illumination: simulating the way light bounces off of real-world materials](origami.png)[Folding a crane in software]

One of the longest running (off and on) projects that I've had is a piece of software that tries to remove photosensitively epileptic flashes from video. I started it in college and revisit it every couple months or so. The two issues that that project has been facing from the beginning is speed and accuracy. From empirical tests I know that the depth of research on triggers of epileptic events is lacking, so I've been having to do my own. As for efficiency, this project was how I started learning about software efficiency. I remember being skeptical after reading about how accessing memory in cache-efficient ways gave large speed wins, and I remember how shocked I was to get a 2-3x speedup from something so simple. I've learned a lot more since then about modern CPUs and efficiency, and the project shows it. I ended up ditched OpenCV a couple years ago for handwritten AVX2 everywhere, completing a cycle that I talk about later. This project has also followed the changes in my personal coding style over the years, from pretty C++-heavy beginnings to my now almost-entirely-C style.

For a while in college I was on a computational origami binge. I read up on the work of link(https://langorigami.com/)[Robert Lang] and did a bunch of personal research into detecting invalid designs and trying to follow Lang's work in link(https://langorigami.com/article/treemaker/)[TreeMaker]. It was in this project that a surprising number of problems can be solved by putting in the hours. Initial sparks of ideas certainly seem magical, but the real magic is making the ideas seem like things anyone could have come up with them in an afternoon. It's been a while since I touched this stuff, but every year when the new SIGGRAPH submissions come out the physical material bending and folding papers are my favorite.

When I was taking my multivariable calculus course I decided to try my hand at fluid simulations. I normally learn easily from lectures or from reading math books, but I think this kind of side-by-side theory and practice learning is my favorite kind. That, and fluid sims are really fun.

A couple years before that in high school I learned how to create path tracers (example shown above), which I played with off and on for several years. This was my first exposure to seriously reading research papers (Eric Veach's thesis, BVH and material papers, etc) and was also my first experience with GPGPU programming. Porting things to the GPU was a thing that I did for a while as well. This and other graphics projects were also my first introduction to more higher-level math like measure theory and geometric algebra.

Around the same time I wanted to try to do eye tracking. The techniques that I used were pretty rudimentary: feature detection using Haar wavelets, using edge detection kernels and ellipse regression to detect iris angles, and an overly complicated setup for calibrating. This was probably one of my first steps in learning about software efficiency the hard way. I spent a couple weeks doing various things to generate my own eye detecting Haar wavelet library and trying to get the convolutions/detectors to run faster. In the end I accepted that I wasn't going to get better than OpenCV in either of these cases and ended up using theirs. This lesson is an interesting one, because it's directly contradicted by my experience a couple projects above.

# Other small miscellaneous projects

imgcmp(crystal_advert_header.png)[Gravity mechanics](contorted.jpg)[Stretchy space platformer]

Throughout high school, college, and even now when I have a real job, I've kept a steady stream of projects going. The ones listed above are the major-learning ones, but here are some others that I think might say something about me. Again, sorted in reverse chronology.

- This site! I wrote the static site generator in an afternoon. Markdown parsing, rss feed generating, etc. Hugo and mmark had been a pain in my ass every time I tried to do stuff with this site, and I recently read through a good bit of the CSS spec so I was ready to take on website layout for real this time.
- Recently I've been playing with ideas about how to do multithreaded debugging well. This is a major shortcoming of all traditional debuggers, and since I've also been playing with Java JVM's JVMTI interface I think this is a fun thing to look into.
- I was into link(https://www.shadertoy.com/user/culdevu/)[shadertoy] for a while, making shaders every week. I think the demoscene and the shader artists out there are incredible. And it's fun to try too!
- Before I go home to visit my family I run simulations and print out tables of probabilities for whatever board/card games they're into at the time.
- In high school and a bit in college I would write little video game prototypes (examples above). Mostly platformers and top-down Zelda-likes, but sometimes other things like 3D space flight Rogue Squadron inspired gamelets
- In around 2010 I was still on Windows XP for a lot of my devices, but I liked the Windows 7 snap feature. So I made an autosnapping program. I'm honestly just surprised that I was able to do that back then.