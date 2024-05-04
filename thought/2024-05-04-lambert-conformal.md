== Lambert conformal projection derivation
=== wip

We're going to finding a function $f$ that takes a parallel to distance from the projection's origin: $N(\phi) = f(\phi)$.
This means that

$$
\frac{dN}{dn} = \frac{f'(\phi)}{R} .
$$

$E$ is pretty easy, $E(\lambda) = f(\phi) \lambda \sin{\phi_0}$, and so

$$
\frac{dE}{de} = f(\phi) \frac{\sin{\phi_0}}{R \cos{\phi}} .
$$

Putting it together, 

$$
\begin{align}
f'(\phi) & = f(\phi) \frac{\sin{\phi_0}}{R \cos{\phi}} \\
\ln(\left| f(\phi) \right|) & = \sin{\phi_0} \tanh^{-1}(\sin{\phi}) + C \\
f(\phi) & = C e^{\pm \sin{phi_0} \tanh^{-1}(\sin{\phi})} .
\end{align}
$$

Combining this with $f(\phi_0) = R \cot{\phi_0}$ and $f(\frac{\pi}{2}) = 0$ gives

$$
f(\phi) = R \cot{\phi_0} e^{\sin{\phi_0} (\tanh^{-1}(\sin{\phi}) - \tanh^{-1}(\sin{\phi})} .
$$
