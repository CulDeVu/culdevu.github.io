---
layout: post
title:  "Fluid dynamics update"
date:   2015-09-29
categories: fluid-dynamics math
---

I'm not really going to talk about much math-y stuff this time. I've covered too much ground since my last entry to be able to remember all the pitfalls I ran into. So this time I'm only really going to be talking about the general algorithm, how I deal with the pitfalls of the marker particle method, and the ongoing translation to CUDA. And probably share some of my Mario Maker levels. I'm addicted to stars :(

So! Let's do this!

<iframe width="640" height="390" src="https://www.youtube.com/embed/0xBAqjxHUkA" frameborder="0" allowfullscreen></iframe>

Sorry for the video being kinda shaky. OBS is having a hard time capturing details and YouTube thinks everything ever is a camcorder, so it looks a little strange. It gets across the idea, though. Note that there is still no surface tension, which would account for just about everything else strange looking with the simulation.

The General Algorithm
===

So the algorithm for simulating a Eulerian fluid goes as follows:

    init particles
    init velocity field, type field, etc
    
    for each frame:
        apply external forces to velocity field
        
        clear type field
        update particle positions and apply to type field
        extrapolate the velocity field
        
        find particles to re-position
        re-position those particles
        
        build pressure matrices
        solve the pressure equation
        apply the pressure to the velocity field
        
        enforce boundary conditions
        
        advect the velocity field

The velocity field is the standard MAC staggered grid, cause why not, and because it's useful for pressure computation and velocity extrapolation. The extrapolation and pressure step are straight out of academic papers so it's standard stuff.

The marker particles are the part I don't really know about. I just advect the marker particles through the velocity field just like anything else, and wherever the marker particles end up defines where the fluid exists or doesn't. This is pretty much the simplest method of defining the interior vs exterior of a fluid, so it has a lot of pitfalls, but I'll get to those in a minute. The issue is, though, that most everyone doesn't talk about this method (because of the many many issues it has) and so they use something called level sets. I've tried implementing level sets several times, and marker particles are just so much simpler in every way.

Marker Particles
===

So the biggest pitfall about marker particles is that, due to numerical inaccuracy and a bunch of other issues, they tend to bunch up a lot in certain places. Namely, places where the divergence of the velocity field is still positive even after the incompressibility pressure solver. You'd think that, since the pressure is positive in some places, it'd be negative in the same area, canceling each other out, but it's not. The fact that gravity is always pulling down on the fluid makes it not always true, so what ends up happening is a net loss of volume from full to nearly 0 in a couple minutes.

So what I tried to do, instead of using level sets like a sane person, I decided to force the fluid to conserve volume. The way I did this is pretty straightforward, and is the "find/re-position particles" part of the above algorithm. Basically,

1. iterate over every particle over a grid and see if there are already more than a certain number of particles (max density, if you will) in that grid cell. If there are, I mark it to be re-positioned
2. iterate over every grid cell where and see if there are less than some other number of particles (min density), and if there are, start pulling from the re-position pool and fill in those spots

This is rather finicky in practice. For example, if I set minDensity to maxDensity, you see a lot of artifacts from there not being enough particles in the re-position pool to accommodate (because of the overall positive divergence I mentioned). A happy median, I found, was setting maxDensity to anywhere between 2 or 3 times the minDensity. Sure, this DOES lead to volume loss by a factor of whatever multiple you choose, but it's much better than having visually disgusting and simulations.

![Marker particles]({{ site.url }}/assets/2015-09-29-fluid-dyanamic-update/marker.jpg)

To be fair, the simulation without re-position looks a lot more fluid and water-like. However, conserving volume it too important to be avoided. Oh well.

CUDA
===

I've been translating small pieces of the simulation to use the GPGPU via CUDA. I've gotten the "update particle" portion completely ported to the GPU, which is just a simple advection and setting type fields. The really neat one is the pressure solver.

In order to find the pressure in each cell, long story short, you need to construct a matrix equation something like this:

$$
    \Bigg[
        \text{pain and suffering}
    \Bigg]
    \Bigg[
        \text{pressure}
    \Bigg] = 
    \Bigg[
        \text{divergence}
    \Bigg]
$$

, and then solve for pressure. On the CPU I used Gauss-Seidel to solve it, but I have no idea how to do it on the GPU. Luckily, there's a library called cusp that implemented everything for me!

    struct cuspTriple
    {
    	int row, col;
    	float amount;
    };
    cusp::array1d<float, cusp::host_memory> pressure(mapW * mapH);
    void project()
    {
    	cusp::array1d<float, cusp::host_memory> b(mapW * mapH);
    	{
    		float scale = rho / dt;
    		for (int y = 0; y < mapH; ++y)
    		{
    			for (int x = 0; x < mapW; ++x)
    			{
    				int index = y * mapW + x;
    				b[index] = scale * (u->at(x + 1, y) - u->at(x, y) +
    					v->at(x, y + 1) - v->at(x, y));
    			}
    		}
    	}
    
    	vector<cuspTriple> data;
    	{
    		for (int y = 0; y < mapH; ++y)
    		{
    			for (int x = 0; x < mapW; ++x)
    			{
    				float scale = 1;
    				int n = 0;
    
    				if (x > 0) 
    				{
    					if (type[y * mapW + x - 1] != SOLID)
    					{
    						if (type[y * mapW + x - 1] == WATER)
    						{
    							cuspTriple t;
    							t.row = y * mapW + x;
    							t.col = y * mapW + x - 1;
    							t.amount = 1;
    							data.push_back(t);
    						}
    						++n;
    					}
    				}
    				if (y > 0) {
    					if (type[(y - 1) * mapW + x] != SOLID)
    					{
    						if (type[(y - 1) * mapW + x] == WATER)
    						{
    							cuspTriple t;
    							t.row = y * mapW + x;
    							t.col = (y - 1) * mapW + x;
    							t.amount = 1;
    							data.push_back(t);
    						}
    						++n;
    					}
    				}
    				if (x < mapW - 1) {
    					if (type[y * mapW + x + 1] != SOLID)
    					{
    						if (type[y * mapW + x + 1] == WATER)
    						{
    							cuspTriple t;
    							t.row = y * mapW + x;
    							t.col = y * mapW + x + 1;
    							t.amount = 1;
    							data.push_back(t);
    						}
    						++n;
    					}
    				}
    				if (y < mapH - 1) {
    					if (type[(y + 1) * mapW + x] != SOLID)
    					{
    						if (type[(y + 1) * mapW + x] == WATER)
    						{
    							cuspTriple t;
    							t.row = y * mapW + x;
    							t.col = (y + 1) * mapW + x;
    							t.amount = 1;
    							data.push_back(t);
    						}
    						++n;
    					}
    				}
    
    				cuspTriple t;
    				t.row = y * mapW + x;
    				t.col = y * mapW + x;
    				t.amount = -n;
    				data.push_back(t);
    			}
    		}
    
    	}
    	cusp::coo_matrix<int, float, cusp::host_memory> A(mapW * mapH, mapW * mapH, data.size());
    	{
    		for (int i = 0; i < data.size(); ++i)
    		{
    			A.row_indices[i] = data[i].row;
    			A.column_indices[i] = data[i].col;
    			A.values[i] = data[i].amount;
    		}
    	}
    
    	cusp::default_monitor<float> monitor(b, 600, 0.01, 0);
    	cusp::precond::diagonal<float, cusp::host_memory> M(A);
    
    	cusp::krylov::cg(A, pressure, b, monitor, M);
    }
    void applyPressure()
    {
    	float scale = dt / (rho);
    
    	for (int y = 0; y < mapH; y++)
    	{
    		for (int x = 0; x < mapW; x++)
    		{
    			if (type[y * mapW + x] != WATER)
    				continue;
    
    			float p = pressure[y * mapW + x];
    
    			u->at(x, y) -= scale * p;
    			u->at(x + 1, y) += scale * p;
    			v->at(x, y) -= scale * p;
    			v->at(x, y + 1) += scale * p;
    		}
    	}
    }

This is the version of the GPU solver I have right now. It has a ton of theoretical std::vector overhead (idk how well the CUDA compiler does to try to optimize things out), so the next thing I'm going to be testing is whether or not over-approximating the number of non-zero elements in the sparse matrix will still be efficient.

Also, the GPU version is around 3-4 times faster than the CPU version! Now, on the other hand, it's only 3 or 4 times faster than the CPU version. That's with copying data back and forth from the GPU, so I give it a little bit of a break, but not much. I'm extremely confident that I could easily squeeze much more efficiency out of it, so that will have to be something I'll deal with at a later date, after I port a bit more to the GPU.

In short, kill me now.

Conclusion
===

Could someone please give me stars in Super Mario Maker? I'm addicted and I need all you have. One of my levels' ID is 04B7-0000-0069-DB69 and from there you should be able to access the 3 levels I've uploaded. They have < 20% clear rate on each of them for some strange reason, even though I think they're pretty easy (and fun).

Anyway, thanks for reading!