== Lambert conformal projection derivation
=== Why would I write something like this? It'd be so much more useful and discoverable as an edit to the wikipedia page.

Below is a simple derivation of the lambert conical conformal transform for a sphere.

Most resources online are like link(https://mathworld.wolfram.com/LambertConformalConicProjection.html)[this wolfram mathworld page], which sites a link(https://archive.org/details/USGSMapProjectionsAWorkingManual1987/page/n115/mode/2up)[a book from 1987] contains just formulas, no derivation. That book in turn cites the original 1772 paper by Lambert. To nobody's surprise, I couldn't find this book, nor its 1972 translation online.

link(https://geodesy.noaa.gov/library/pdfs/Special_Publication_No_47.pdf)[This 1918 (?) paper] gives a good overview of the derivation. The first section gives a derivation of a (fairly poor) approximation, but then later gives the full thing. But it's over an ellipsoid, and it's maybe a bit overcomplicated.

Here's mine. I tried to keep it as simple as I could. It's only valid for a sphere, which is what the NDFD and HRRR datasets are in.

imgcmp(sphere.png)[](projected.png)[]

We have here a sphere with radius $R$, a  reference point $G$ with parallel $\phi_0$ and meridian $0$, and another point on the sphere with parallel $\phi$ and meridian $\lambda$.

The transform has a couple properties:

- "Wedges" of the sphere, like in the left image above, get transformed into sectors of a circle, like in the right image above.
- Meridians get mapped to straight lines radiating out from a center "origin" point (the point where the north pole gets mapped). Parallels get mapped to concentric circles (or rather portions of circles).
- The length of the reference parallel is the same as the length of the circle that the reference parallel gets mapped to.
- A wedge with angle $\lambda$ get transformed into a wedge with internal angle $\lambda \sin{\phi_0}$. You could conceivably choose something different, but this choice minimizes the distortion around the reference parallel.
- From these two, the distance from $G'$ to the origin is $R \cot{\phi_0}$.

To derive the transformation, we're going to be looking at what happens to $N$ and $E$ in the above diagram.

Say you're standing on the sphere at $(\phi, \lambda)$. Taking a small step of $\Delta$ meters northward corresponds to a change in parallel $d \phi = \frac{\Delta}{R}$. Taking the same small step $\Delta$ eastward cooresponds to a change in meridian of $d \lambda = \frac{\Delta}{R \cos{\phi}}$.

The goal here is to express the cooreponding change to $N$ and $E$ in the projected map, $dN$ and $dE$. Conformal maps preserve scale in all directions at every point, so $dN = dE$ in a lambert conformal map.

Going off of the diagram above, a step eastward on the globe would correspond to a change in the projected map $dE = (R \cot{\phi_0} - N) d \lambda \sin{\phi_0} = (R \cot{\phi_0} - N) \frac{\Delta}{R \cos{\phi}} \sin{\phi_0}$.

We don't know what $N$ is as a function of $\Delta$. However, we can say that whatever $N$ is, $dN = \frac{dN}{d \phi} d \phi = \frac{dN}{d \phi} \frac{\Delta}{R}$.

Putting it all together:

$$
\begin{align}
dN & = dE \\
\frac{dN}{d \phi} \frac{\Delta}{R} & = (R \cot{\phi_0} - N) \frac{\Delta}{R \cos{\phi}} \sin{\phi_0} \\
\frac{dN}{d \phi} & = (R \cot{\phi_0} - N) \sec{\phi} \sin{\phi_0}.
\end{align}
$$

This is where we need to bring in calculus. This is a fairly simple seperable differential equaion:

$$
\frac{dN}{R \cot{\phi_0} - N} = \sec{\phi} \sin{\phi_0} d \phi,
$$

which solves to

$$
\begin{align}
-\ln \left| R \cot{\phi_0} - N \right| & = \sin{\phi_0} \sinh^{-1}(\tan{\phi}) + C \\
\text{OR} & = \sin{\phi_0} \ln \left| \sec{\phi} + \tan{\phi} \right| + C \\
\text{OR} & = \sin{\phi_0} \ln \left| \tan \left( \frac{\phi}{2} + \frac{\pi}{4} \right) \right| + C \\
\text{OR} & = ...
\end{align}
$$

There are famously several equivalent integrals of secant. Sticking with the top one:

$$
\begin{align}
-\ln \left| R \cot{\phi_0} - N \right| & = \sin{\phi_0} \sinh^{-1}(\tan{\phi}) + C \\
\left| R \cot{\phi_0} - N \right| & = C e^{-\sin{\phi_0} \sinh^{-1}(\tan{\phi})} \\
N & = R \cot{\phi_0} + C e^{-\sin{\phi_0} \sinh^{-1}(\tan{\phi})}.
\end{align}
$$

Combining this with $N(\phi_0) = 0$ gives:

$$
N = R \cot{\phi_0} \left( 1 - e^{\sin{\phi_0}(\sinh^{-1}(\tan \phi_0) - \sinh^{-1}(\tan \phi))} \right).
$$

Completing it with E:

$$
E = (R \cot{\phi_0} - N) \lambda \sin{\phi_0}
$$
