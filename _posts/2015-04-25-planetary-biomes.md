---
layout: post
title:  "Planetary Biomes"
date:   2015-04-25
categories: procedural-generation math graphics
---
Not many images or videos this time around, unfortunately. It's mostly about updates about what I'm up to and what I'm working on.

So, first off, the non-euclidean stretchy game thingy. Turns out that some people in my art class had taken an interest in it when I was working on it in class, and they offered to help offload some of the content generation, like making art, animations, level design, etc. This is actually exactly what I need in order to continue working on it, so you'll be seeing some gosh-darn pretty images in the future, after finals are over! Look forward to it!

In the meantime though, as I always need something to procrastinate on homework with, I've been playing around with a space flying simulation, one where you can get really close to the ground!

<img src="{{ site.url }}/assets/2015-04-25-planetary-biomes/head1.jpg" style="width: 49%;" />
<img src="{{ site.url }}/assets/2015-04-25-planetary-biomes/head2.jpg" style="width: 49%;" />

It looks a little rough right now, I know. Atmospheric scattering and physically correct lighting have taken a back seat to getting the game mechanics up and working. As you can see, though, there are biomes on the planet that try to correspond to how an actual planet's biomes work. With the exception of icecaps and rivers and stuff that have to have a little more processing thrown at them, the biomes are roughly there. I need to work on smoothing them out and getting them to be believable colors, but I'll work on that when I start doing close-up stuff.

So, down to the nitty gritty technical details of everything.

## Biomes 'n Stuff

The game world is represented in a sort of fixed-point-esque system using doubles in hopes to make it expand to more than just a single solar system. However, everything drawn on the GPU is done using floats, particularly because I don't want to have to require GLSL version 400. So for the planet and sun that you see right now, everything is done using raytraced impostors.

So how do the biomes work? Well, back in Freshman year of high school I took biology, and I remember learning about a chart that determines all of the different biomes we see on earth by plotting them on a graph of average rainfall vs average temperature. Here's a picture of it:

<img src="{{ site.url }}/assets/2015-04-25-planetary-biomes/biome_graph.jpg" style="width: 60%;" />

So, that's pretty easy. For the average temperature, I took inspiration from the earth: 

<img src="{{ site.url }}/assets/2015-04-25-planetary-biomes/temp.jpg" style="width: 60%;" />

I approximate it by a dot product plus offset by some value noise.

	// takes normalized position rel sphere
	// returns a value on [0, 1] representing the range [-15, 30] celcius
	float getTemperature(vec3 p)
	{
		vec3 randTempSeed = p + vec3(12, 11, 10);

		vec3 upVec = vec3(0, 1, 0);
		float temp = dot(upVec, p);
		if (temp < 0)
			temp = -temp;
		temp = 1.0 - temp + valueNoise3D(randTempSeed.x, randTempSeed.y, randTempSeed.z, 6) * 0.2;
		temp = clamp(temp, float(0), float(1));
		return temp;
	}

The average rainfall on the earth doesn't look like it has any discernible pattern, so I just thew some value noise on it and called it a day. All together, here's the snippet that determines biomes:

	// takes normalized position rel sphere
	// returns a value on [0, 1] representing the range [-15, 30]
	float getTemperature(vec3 p)
	{
		vec3 randTempSeed = p + vec3(12, 11, 10);

		vec3 upVec = vec3(0, 1, 0);
		float temp = dot(upVec, p);
		if (temp < 0)
			temp = -temp;
		temp = 1.0 - temp + valueNoise3D(randTempSeed.x, randTempSeed.y, randTempSeed.z, 6) * 0.2;
		temp = clamp(temp, float(0), float(1));
		return temp;
	}

	// takes normalized position rel sphere
	// returns a value on [0, 1] representing the range [0, max amount of precipitation]
	float getPrecipitation(vec3 p)
	{
		p = p + vec3(8, 12, 19);
		float precip = (valueNoise3D(p.x, p.y, p.z, 8) + 1.0) / 2.0;
		return precip;
	}

	int getBiome(vec3 p)
	{
		float temp = getTemperature(p);
		float precip = getPrecipitation(p);

		if (temp < 0.25)
			return BIOME_TUNDRA;
		if (precip / temp < 0.15)
			return BIOME_SUBTROPIC;
		if (temp < 0.75 && precip / temp < 0.5)
			return BIOME_GRASSLAND;
		if (temp < 0.3)
			return BIOME_TIAGA;
		if (temp < 0.75 && precip < 0.5)
			return BIOME_DECIDUOUS;
		if (temp < 0.75)
			return BIOME_TEMERATE_RAINFOREST;
		if (precip < 0.25)
			return BIOME_SAVANNA;
		if (precip < 0.5)
			return BIOME_TROPICAL_FOREST;
		return BIOME_TROPICAL_RAINFOREST;
		return 0;
	}

And that's that!

​Translating it to C++
---------------------

So, now with a basic rudimentary system in place for generating biomes for GLSL impostors, I need to translate it over to C++ so that I can build a mesh for when you get up close.

The issue is that I'll probably end up changing things, like finding ways to make the biomes more natural (like having more rainfall around ocean edges, etc), and I'll have to translate every single change I make to C++ as well.

The solution I came up with is to use the power of GLM plus the power of simple parsing, to get the C++ compiler to compile GLSL.

Here's how it works:

My shaders get run through a very simple parser that looks for #include statements, and then starts revursively copying and pasting those files into the body of the shader (I call these files .glh). This serves a double purpose. Firstly, it makes a large GLSL codebase much cleaner and more plug-and-play, which helps with prototyping. The separate header files can also, if GLM is willing, be parsed by the C++ compiler if there's just functions and their definitions.

This way, I can import all of my biome creation code into C++ by saying something like:

	using glm::max;
	using glm::min;
	using glm::clamp;
	using glm::normalize;

	typedef uint32_t uint;

	#include "planetImpostor.glh"

and BOOM! I've got the biome determination code transfered.

Here are some more boring screens:

![asdfas]( {{ site.url }}/assets/2015-04-25-planetary-biomes/foot1.jpg)

![asdfas]( {{ site.url }}/assets/2015-04-25-planetary-biomes/foot2.jpg)

Welp, I hope that interested you guys and everything! I'll get back to you guys in a week and catch you up with everything if finals don't get too rough.

Thanks for reading!