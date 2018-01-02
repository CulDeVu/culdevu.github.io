---
layout: post
title:  "Factored BRDF Representation"
date:   2015-07-20
categories: global-illumination math
---
It's been quite a while.

So I've been working on life/jobs/family/etc the past couple months. A couple weeks ago, however, I decided to implement a type of arbitrary BRDF sampling based on factoring large matrices, found here: http://gfx.cs.princeton.edu/proj/brdf/brdf.pdf

The idea is to convert the BRDF into a series of matrix representations in such a way that

\\[ f_r(\omega_i, \omega_o)(w_i \cdot \textbf{n}) \approx
	\sum_{l=1}^{L}{ F_l(\omega_o) u_l(\theta_h) v_l(\phi_h) } \\]

, where \\( F_l \\), \\( u_l \\), and \\( vl \\) are massive matrices that depend on outgoing direction, half angle azimuth, and half angle zenith about surface normal, respectively. Now that the functions for half angle azimuth and zenith are separated out, it's trivial to construct a probability density function based on each. From then on, it's the whole uniform random number -> CDF -> random ray thing like we're used to. The PDF is defined by

\\[
	pdf(\theta_h, \phi_h \vert \omega_o) =
	\left( 
		\sum_{l=1}^{L}{\frac{ F_l(\omega_o) u_l(\theta_h) v_l(\phi_h)}{\sum_{j=1}^{L}{F_j(\omega_o)}}}
	\right)
	\frac{1}{4 (\omega_i \cdot \omega_h) }
\\]

, where that last term is the Jacobian between half angle representation and normal paths.

Pretty Pictures and Opinions
===

![3 bounce comparison]({{ site.url }}/assets/2015-07-20-factored-brdf/3bounce.jpg)
*[Left: factored BRDF representation, Right: Path traced reference, 200 samples each]*

On to my personal thoughts. (Just as a warning, I've checked and re-checked my math a hundred times, so I don't think anything is wrong. If it is, though, be sure to sufficiently embarrass me on the Internet)

So. The big issue is that, while the representation is extremely good at importance sampling shiny materials, it does so at the expense of accurately representing more Lambertian properties. The effect can be seen when only one bounce is traversed:

![1 bounce comparison]({{ site.url }}/assets/2015-07-20-factored-brdf/1bounce.jpg)
*[Left: 256 u terms, 128 v terms, Middle: path traced reference, Right: 512 u terms, 256 v terms, all images rendered with 200 samples]*
(btw, the blue ball is the only thing in the picture that new material is applied to here. In case you couldn't tell.)

This issue arises because of its discrete nature. In order to get a good enough representation of the BRDF to sample it in this manner, you have to throw more and more samples at the BRDF. In this type of representation, a pure mirror would work very well, and diffuse materials would work less well, because this representation prefers more jagged BRDFs that so that it can sample the correct lobe. Otherwise, it has to make approximations at to what the CDF is, in the same way that a Euler integrator has issues because of regular sampling that doesn't capture the essence of the function. If that makes sense. A graph of what this looks like might be something like

![]({{ site.url }}//assets/2015-07-20-factored-brdf/illu.jpg)

I could show some close-ups like in normal graphics papers, but there's no real point as the differences are so massive.

Welp. Hoped you liked it. The factored representation is still fantastic if you want to store measured BRDF data, but it doesn't suit my needs for an actual path tracer. Oh well. I'm bound to find some other fancy graphics paper to try to implement soon
