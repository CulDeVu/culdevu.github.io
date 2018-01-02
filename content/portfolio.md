---
title: Portfolio
menu: main
---

I have tried my best to tinker with a lot of different things in a lot of different areas, from CUDA programming, to game programming; from computer graphics to computational physics. I really like to spend a couple months really digging down into a particular topic, trying to delve as deep as I can into any given topic as I can before something else steals my curiosity. Because of this, they end up being kinda complex, and detailed enough for me to be able to spend multiple months working on. 

Here is a sampling of the projects that have taken the longest, or are the most complex, or I'm just plain really proud of.

<br />
<hr>
<br />

Computational Origami and Paper Folding
===

![Origami Designer window](/portfolio/origami.png)

Years: 2015-2016

For those that don't know, mathematic paper folding is the study of turning origami and other paper folding crafts into rules that can be followed, and reaching conclusions from the crease patterns that result. This has (or had at one point) many uses, including optimal folding of solar sails in space shuttles, or how to rigid-fold sheet metal.

I worked on an origami editor that was supposed to be vastly superior to [ORIPA](http://mitani.cs.tsukuba.ac.jp/oripa/), currently the most widely used origami crease pattern editor for academic purposes. My editor was able to show, in real-time wire-frame 3D rendering, every change made to the crease pattern. Also supported was crease suggestions, for being able to auto-complete folds in the paper. At the editor's base was a small, fast, and lightweight  API, with just a handful of classes, that delivered the full functionality of the editor including auto-completion. It is no longer in development anymore, however. You can find the source for the project [here](https://github.com/CulDeVu/OrigamiConverter), (for Windows only).

Of the hurdles that were overcome making this, the most significant: 

- Developing a novel and fast folding algorithm that takes advantage of the way that transformation matrices across crease patterns create identities as they circle around certain features
- Developing a working auto-complete functionality, again taking advantage of these identity matrices and the matrix forms used to construct them
- Creating a file format that's simpler than ORIPA's XML-based file type
- Extending all calculations (including auto-complete) into non-flat creases

<br />
<hr>
<br />

Global Illumination
===

![Sponza atrium with bust of Lenin](/portfolio/sponza.png)

Years: Off and on for 2013-2016

Global Illumination algorithms are a class of algorithms that simulate the way that light bounces and interacts with real-world materials. It models, mathematically, light exiting from a source, bouncing off of objects, and hitting a camera lens. Light paths, direction, and power are all generated from the properties of the materials they interact with, and accumulate to create a finished image. This is the same method that is used to generate almost all CGI in movies like Disney Pixar films.

This particular project I've been working on a little bit for a couple years now. This is the sort of project I love working on: the type that I can pour hundreds of hours into, and still have barely scratched the surface of what I know that I'm capable of making. There's a low barrier to understanding, but a much higher barrier to implementing everything properly.

Features of the current version:

- Embree raytracing kernel recently replaced my own BVH implementation
- Imports 3D models and textures
- Microfacet BRDF, with importance sampling of the Beckmann Distribution of microfacets
- Layered materials, inspired by [Arnold](https://www.solidangle.com/arnold/) renderer
- OpenGL window rendering the current image as it's being created

<br />
<hr>
<br />


Video Game prototypes
===

I've made quite a few little video game tech demos showing a video game mechanic I had been toying with. Each one of them are themed completely around a mechanic that I thought would be "fun" to play an actual video game with. All of the art is hand-done by me, which is why there's not much of it. Each of these were made over the course of 2 or 3 months, and are, at the moment, at varying levels of polish and stability.

Contorted
---

![Contorted game prototype](/portfolio/contorted.jpg)

Year: 2015

Contorted is a game where you bend space in order to move around and solve puzzles in the game world. The movement was based around a grappling hook that pulls ledges and objects toward you, instead of the other way around. A video (and a sampling of some of my best vector artwork abilities) can be seen of it in action here:

<iframe width="640" height="360" src="https://www.youtube.com/embed/h2K6sl1c4fY" frameborder="0" allowfullscreen></iframe>

The main feature of this game, and the part that took the most time, was creating the physics engine. Box2D, Chipmunk2D, and really all other mainstream physics engines, require that you submit static fixtures around even dynamic objects. Even with soft-bodies, these physics engines take huge performance hits when modifying fixture shapes, so a special engine had to be made to support a constantly bending world at a decent framerate. The final engine was modeled off of, with many modifications and improvements, Paul Firth's speculative physics write-up [here](http://www.wildbunny.co.uk/blog/2011/03/25/speculative-contacts-an-continuous-collision-engine-approach-part-1/).

Including the physics engine, barriers that I had to overcome included:

- Extending Little Big Planet's speculative physics system with friction (not seen in above video)
- Created a class of distortion functions that prevented discontinuities, even with the existence of 5 or 6 conflicting distortions, but also provided variable "weight" to the distortions
- Mesh optimization, so that world bending could be done at mesh vertexes and have minimal holes show up
- Creating an art style that would synergize with the new movement capabilities of the player character

Crystal
---

![Crystal game prototype](/portfolio/crystal_advert_header.png)

Year: 2014

Crystal is a game where you attach gravity wells to various objects in the world. In this game, you manipulate gravity to solve puzzles and to navigate the world.

You can then use the gravity wells to scale walls, to reach otherwise impossible places, to walk on the undersides of platforms, and loads of other cool tricks. You can use your powers creating and canceling gravity to fling yourself (and enemies, and other objects) around level, to manipulate swinging platforms, to solve puzzles, the whole nine platforming yards!

This game demo was (largely) made for and shown at a tech expo that is hosted annually at high-school during my senior year there. This game demo is, at the time of writing, the largest and most elaborate project that any student has ever submitted and displayed.

Things I learned and barriers that I had to overcome:

- Learned how to interface with LWJGL and OpenAL, and Box2D
- Learned practical methods to overcome Java's garbage collector to maintain a relatively constant framerate
- Built a graphics module designed for rapid prototyping but that was also clean and fast