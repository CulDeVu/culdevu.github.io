---
layout: page
title: Portfolio
permalink: /portfolio/
---

I have tinkered with a lot of different things in a lot of different areas, from computer graphics, to game programming, to CUDA programming blah blah blah

<br />
<hr>
<br />

Computational Origami and Paper Folding
===

![Origami Designer window]( {{ site.url }}/assets/portfolio/origami.png)

For those that don't know about mathematic paper folding, it's the study of turning origami and other paper foldings into rules that can be followed, and reaching conclusions from the crease patterns that these folds make. This has (or had, at one point) many uses, including optimal folding of solar sails in space shuttles, or how to rigid-fold sheet metal.

I worked on an origami editor that was supposed to be vastly superior to [ORIPA](http://mitani.cs.tsukuba.ac.jp/oripa/), currently the most widely used origami crease pattern editor for academic purposes. My editor was able to show, in real-time wire-frame 3D rendering, every change made to the crease pattern. Also supported was crease suggestions, for being able to auto-complete folds in the paper. At the editor's base was a small, fast, and lightweight  API, with just a handful of classes, that delivered the full functionality of the editor including auto-completion. It is no longer in development anymore, however. You can find the source for the project [here](https://github.com/CulDeVu/OrigamiConverter), (for Windows only).l

Of the hurdles that were overcome making this, the most significant: 

- Developing a novel and fast folding algorithm that takes advantage of the way that transformation matrices across crease patterns create identities as they circle around certain features
- Developing a working auto-complete functionality, again taking advantage of these identity matrices and the matrix forms used to construct them
- Creating a file format that's superior to ORIPA's XML-based file type
- Extending all calculations (including auto-complete) into non-flat creases

<br />
<hr>
<br />

Fluid Mechanics
===

list stuff

<br />
<hr>
<br />

Global Illumination
===

list stuff

<br />
<hr>
<br />


Video Game prototypes
===

I've made quite a few little video game tech demos showing a video game mechanic I had been toying with. Each one of them are themed completely around a mechanic that I thought would be "fun" to play an actual video game with. All of the art is hand-done by me, which is why there's not much of it. Each of these were made over the course of 2 or 3 months, and are, at the moment, at varying levels of polish and stability.

Contorted
---

![Crystal game prototype]( {{ site.url }}/assets/portfolio/contorted.jpg)

Contorted is a game where you bend space in order to move around and solve puzzles in the game world. The movement was based around a grappling hook that pulls ledges and objects toward you, instead of the other way around. A video of it in action here:

<iframe width="640" height="360" src="https://www.youtube.com/embed/h2K6sl1c4fY" frameborder="0" allowfullscreen></iframe>

The main feature of this game, and the part that took the most time, was creating the physics engine. Box2D, Chipmunk2S, and really all other mainstream physics engines, require that you submit static fixtures around even dynamic objects. Even with soft-bodies, these physics engines take huge performance hits when modifying fixture shapes, so a special engine had to be made to support a constantly bending world at a decent framerate. The final engine was modeled off of, with many modifications and improvements, Paul Firth's speculative physics write-up [here](http://www.wildbunny.co.uk/blog/2011/03/25/speculative-contacts-an-continuous-collision-engine-approach-part-1/).

Apart from the physics engine, other barriers that I had to overcome included:

- Mesh optimization, so that world bending could be done at mesh vertexes and have minimal holes show up
- Creating an art style that would synergize with the new movement capabilities of the player character

Crystal
---

![Crystal game prototype]( {{ site.url }}/assets/portfolio/crystal_advert_header.png)

Crystal is a game where you attach gravity wells to various objects in the world. In this game, you manipulate gravity to solve puzzles and to navigate the world.

You can then use the gravity wells to scale walls, to reach otherwise impossible places, to walk on the undersides of platforms, and loads of other cool tricks. You can use your powers creating and canceling gravity to fling yourself (and enemies, and other objects) around level, to manipulate swinging platforms, to solve puzzles, the whole nine platforming yards!

This game demo was (largely) made for and shown at a tech expo that is hosted annually at high-school during my senior year there. This game demo is, at the time of writing, the largest and most elaborate project that any student has ever submitted and displayed.

Things I learned and barriers that I had to overcome:

- Learned how to interface with LWJGL and OpenAL, and Box2D
- Learned practical methods to overcome Java's garbage collector to maintain a relatively constant framerate
- Built a graphics module designed for rapid prototyping but that was also clean and fast