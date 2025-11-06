# == Recursive monte carlo greens functions
# === wip

# What follows is some experiments with using greens functions for solving some differential equations, particularly laplace equations.

# First I need to set things up.

import random
from math import sin, exp, sqrt, pi
from statistics import mean, stdev
import matplotlib.pyplot as plt

def xrange():
  for xi in range(100):
    yield xi / 100
x01 = [x/100 for x in range(100)]
x13 = [x/100 for x in range(100, 300)]
x19 = [x/100 for x in range(100, 900)]
x03 = [x/100 for x in range(300)]
x02 = [x/20 for x in range(2*20)]
x26 = [x/20 for x in range(2*20, 6*20)]

def plot(filename, xs, *data):
  plt.clf()
  axis = plt.gca()
  
  plt.plot(xs, data[0])
  
  y_limits = axis.get_ylim()
  
  for dat in data[1:]:
    plt.plot(xs, dat)
  
  axis.set_ylim(y_limits)
  
  plt.savefig(filename, format='svg')

def Hv(x):
  if 0 <= x:
    return 1
  else:
    return 0

# $$
# \begin{aligned}
# \int_0^1 f(s) G(x, s) ds & = A
# \end{aligned}
# $$

# Using this to solve $\frac{d^2}{dx^2}u(x) = 2$, $u(0)=0, u(1)=1$:

def sample_quadratic(x):
  def G(x, s):
    return (x - s)*Hv(x - s) + (s - 1)*x
  
  s = random.random()
  return x + G(x, s) * 2

# Results:

plot('quadratic.svg',
  x01,
  [x*x for x in x01],
  [mean([sample_quadratic(x) for _ in range(100)]) for x in x01])

# img(quadratic.svg)[]

# $\frac{d^2}{dx^2}u(x) = 48x - 24, u(0)=0, u(1)=1$:

def sample_cubic(x):
  def G(x, s):
    return (x - s)*Hv(x - s) + (s - 1)*x
  
  s = random.random()
  return x + G(x, s) * (48*s - 24)

plot('cubic.svg',
  x01,
  [x*(8*x*x - 12*x + 5) for x in x01],
  [mean([sample_cubic(x) for _ in range(100)]) for x in x01])

# img(cubic.svg)[]

# $\frac{d^2}{dx^2}u(x) = -4 u(x), u(0)=0, u(1)=1$:

def sample_laplace1_v1(p, x):
  if x < 0.01:
    return 0
  if 0.99 < x:
    return 1
  
  def G(x, s):
    return (x - s)*Hv(x - s) + (s - 1)*x
  
  s = random.random()
  return x + G(x, s) * p * sample_laplace1_v1(p, s)

plot('wave_small.svg',
  x01,
  [sin(2 * x) / sin(2) for x in x01],
  [mean([sample_laplace1_v1(-4, x) for _ in range(100)]) for x in x01])

# img(wave_small.svg)[]

# ## Homogeneous boundary conditions

# One of the problems to look into is how to deal with 0's for the boundary conditions. I want to be able to do solve something like $\frac{d^2 u}{dx^2}(x) = -\pi^2 x$ with $x(0) = x(1) = 0$ and get out a function of the form $u(x) = C \sin (2 \pi x)$.

# Finding non-trivial solutions to equations like this is required to make the electron orbital simulator. All of the wavefunction boundary conditions are 0.

# Simply rewriting the above `sample_laplace1_v1`, replacing boundary conditions:

def sample_laplace1_homogeneous(p, x):
  if x < 0.01:
    return 0
  if 0.99 < x:
    return 0
  
  def G(x, s):
    return (x - s)*Hv(x - s) + (s - 1)*x
  
  s = random.random()
  return G(x, s) * p * sample_laplace1_homogeneous(p, s)

# This only produces the trivial solution $u(x) = 0$. This makes sense, since the algorithm is multiplicative, and all recursions terminate in 0.

# Splitting the domain:

def sample_laplace1_otherside(p, x):
  if x < 1.02:
    return 1
  if 2.98 < x:
    return 0
  
  def G(x, s):
    return (x - s)*Hv(x - s) + ((s-3)/2)*x -(s-3)/2
  
  s = 1 + random.random()*2
  return 1.5 - 0.5*x + G(x, s) * p * sample_laplace1_otherside(p, s)*2

plot('homogeneous.svg',
  x01+x13,
  [2*sin(pi*x/3)/sqrt(3) for x in x01+x13],
  [mean([sample_laplace1_v1(-pi*pi/9, x) for _ in range(100)]) for x in x01] +
  [mean([sample_laplace1_otherside(-pi*pi/9, x) for _ in range(100)]) for x in x13])

# img(homogeneous.svg)[]

# Another thing I'm interested in is the resilience of this technique to the parameter $p$. The equation $\frac{d^2 u}{dx^2}(x) = p x$ with $x(0) = x(3) = 0$ has nontrivial solutions for ONLY $p = -k \pi^2 / 9$. For my intended uses I'm probably only going to be able to compute $p$ approximately. I want this technique to sort of work even if $p$ is a little off.

plot('homogeneous_almost.svg',
  x01+x13,
  [2*sin(pi*x/3)/sqrt(3) for x in x01+x13],
  [mean([sample_laplace1_v1(-pi*pi/9 + 0.4, x) for _ in range(100)]) for x in x01] +
  [mean([sample_laplace1_otherside(-pi*pi/9 + 0.4, x) for _ in range(100)]) for x in x13])

# img(homogeneous_almost.svg)[$p = -\pi^2/9 + 0.4$]

# Nice! This means that approximate choices of $p$ give approximately correct answers. Also, I can dial in $p$ by looking at the derivatives near the split point.

# TODO: does sphere walking like in the paper work?

# TODO: in 2D?

# ## Large p

# Another problem is that this function doesn't actually work for all $p$. Take a look at $p = -16$:

plot('wave_large.svg',
  x01,
  [sin(4 * x) / sin(4) for x in x01],
  [mean([sample_laplace1_v1(-16, x) for _ in range(100)]) for x in x01])

# img(wave_large.svg)[]

# In fact, no value of $p < -\pi^2$ works!

# Why not?

# After the above discussion this isn't too surprising. At more negative values of $p$ the frequency of $u$ increases. For $p \in (-\pi^2, 0)$ the solution $u$ only contained a half period of a wave at max. For $p \in (-4\pi^2, -\pi^2)$ and beyond it's a full period. So beyond $-\pi^2$ you're always going to have negative numbers in the $[0, 1]$ subdomain.

# Much like above, `sample_laplace1_v1` can't produce negative numbers when $p$ is negative. $G$ is non-positive, $x$ is non-negative, and the terminal cases are both non-negative.

# ... but this feels a little unsatisfying.

# complexity

# derivation

# ## polynomial

# Actually, the fact that it diverges outside of $(-\pi^2, \pi^2)$ makes me think of the convergence of Taylor series. With a Taylor series you have a convergence region of a ball centered on your root position, with a radius of the distance to the nearest complex pole.

# Fixing $x$ and looking at `sample_laplace1_v1` as a function of $p$, there is a pole at $p = -\pi^2$, so if this were the correct intuition then this behavior would make sense.

# I don't know why I didn't think of this before. 

plot('exp_small.svg',
  x01,
  [exp(2-2*x) * (exp(4*x) - 1) / (exp(4) - 1) for x in x01],
  [mean([sample_laplace1_v1(4, x) for _ in range(100)]) for x in x01])

# img(exp_small.svg)[]

plot('exp_large.svg',
  x01,
  [exp(4-4*x) * (exp(8*x) - 1) / (exp(8) - 1) for x in x01],
  [mean([sample_laplace1_v1(16, x) for _ in range(100)]) for x in x01])

# img(exp_large.svg)[]

def prange_lo():
  return[i/5 for i in range(-100, 0)]
def prange_hi():
  return [i/5 for i in range(1, 100)]

plot('p.svg',
  prange_lo() + [0] + prange_hi(),
  [sin(sqrt(-p)*0.3) / sin(sqrt(-p)) for p in prange_lo()] +
  [0.3] +
  [exp(sqrt(p)*(1-0.3)) * (exp(2*sqrt(p)*0.3) - 1) / (exp(2*sqrt(p)) - 1) for p in prange_hi()],
  [mean([sample_laplace1_v1(p, 0.2) for _ in range(100)]) for p in prange_lo() + [0] + prange_hi()])

# img(p.svg)[]

# Here's the theoretical derivative table

# - 0th: 0.3
# - 1st: -0.0455
# - 2nd: 0.0102072
# - 3rd: approx -0.00318547
# - 4th: (only verified right sided) 0.00129975

def mul_poly(a, b):
  out = [0 for _ in range(len(a) + len(b))]
  for i,ai in enumerate(a):
    for j,bj in enumerate(b):
      out[i+j] += ai * bj
  return out

def sample_laplace1_v1_poly(p, x):
  if x < 0.01:
    return [0]
  if 0.99 < x:
    return [1]
  
  def G(x, s):
    return (x - s)*Hv(x - s) + (s - 1)*x
  
  s = random.random()
  out = mul_poly([0, G(x, s)], sample_laplace1_v1_poly(p, s))
  out[0] += x
  return out

from functools import reduce
from math import factorial
def add_poly(a, b):
  out = []
  for i in range(max(len(a), len(b))):
    if i < len(a) and i < len(b):
      out.append(a[i] + b[i])
    elif i < len(a):
      out.append(a[i])
    elif i < len(b):
      out.append(b[i])
  return out
polys = [sample_laplace1_v1_poly(1, 0.3) for _ in range(10)]
poly = reduce(add_poly, polys, [0])
poly = mul_poly([1/10], poly)

# Now mine. Left are my computed values, right are the Taylor series coefficients.

#> (poly[0] * factorial(0), 0.3)
#> (poly[1] * factorial(1), -0.0455)
#> (poly[2] * factorial(2), 0.0102072)
#> (poly[3] * factorial(3), -0.00318547)
#> (poly[4] * factorial(4), 0.00129975)

# That looks right. So apparently `sample_laplace1_v1` is computing the Taylor series of the solution of the differential equation somehow.

# I was floored when I saw this.

# TODO: why does this work?

# ## No endpoints

# What would happen if I just messed up the two base cases? Like if I put the wrong values in them.

def G_laplace_01(x, s):
  return (x - s)*Hv(x - s) + (s - 1)*x

def sample_laplace1_wrong_endpoints(p, x):
  if x < 0.01:
    return 2
  if 0.99 < x:
    return -1
  
  s = random.random()
  return x + G_laplace_01(x, s) * p * sample_laplace1_wrong_endpoints(p, s)

plot('wrong_endpoints.svg',
  x01,
  [sin(2 * x) / sin(2) for x in x01],
  [mean([sample_laplace1_wrong_endpoints(-4, x) for _ in range(100)]) for x in x01])

# img(wrong_endpoints.svg)[]

# With the exception of the endpoints, the curve looks good. Meaning that the endpoints aren't necessary for the algorithm.

# Here's a redesigned one:

def sample_laplace1_no_endpoints(p, x):
  def one_sample(x, accum):
    cutoff = min(1, abs(accum))
    if cutoff < random.random():
      return 0
    
    s = random.random()
    weight = p * G_laplace_01(x, s)
    return (x + weight * one_sample(s, accum * weight)) / cutoff
  
  return one_sample(x, 1)

plot('no_endpoints.svg',
  x01,
  [sin(2 * x) / sin(2) for x in x01],
  [mean([sample_laplace1_no_endpoints(-4, x) for _ in range(100)]) for x in x01])

# img(no_endpoints.svg)[]

# There's a bit more variance, but that's to be expected.

# TODO: re-anchor

# TODO: walk-on-stars

# ## s orbital

# $\frac{d^2}{dx^2}u(x) = -2 (\frac{1}{x} - \frac{1}{2}) u(x), u(0)=0, u(\inf)=1$:

def s_orbital_01(r):
  def one_sample(x):
    cutoff = 0.95
    if cutoff < random.random():
      return 0
    
    s = random.random()
    return (x + G_laplace_01(x, s) * -2 * (1/s - 0.5) * one_sample(s)) / cutoff
  
  return one_sample(r)

def G_laplace_19(x, s):
  return (x - s)*Hv(x - s) + (s - 9)/8*x - (s-9)/8
def s_orbital_19(r, m=8):
  def one_sample(x, accum):
    # cutoff = min(1, abs(accum))
    cutoff = 0.98
    if cutoff < random.random():
      return 0
    
    s = 1 + random.random() * 8
    weight = G_laplace_19(x, s) * -2 * (1/s - 0.5) * m
    return (9/8 - x/8 + weight * one_sample(s, accum * weight)) / cutoff
  
  return one_sample(r, 1)

plot('s_orbital_09.svg',
  x01 + x19,
  [exp(-x)*x*exp(1) for x in x01 + x19],
  [mean([s_orbital_01(r) for _ in range(100)]) for r in x01] +
  [mean([s_orbital_19(r) for _ in range(100)]) for r in x19])

# print([stdev([s_orbital_09(r) for _ in range(100)]) for r in x19])

# img(s_orbital_09.svg)[]

plot('param_19.svg',
  [m/10 for m in range(30)],
  [mean([s_orbital_19(2, m/10) for _ in range(100)]) for m in range(30)])

# img(param_19.svg)[]

def G_laplace_generator(a, b):
  def G(x, s):
    return (x - s)*Hv(x - s) + (s - b)/(b - a)*x - a * (s - b)/(b - a)
  return G

G_laplace_02 = G_laplace_generator(0, 2)
def s_orbital_02(r):
  def one_sample(x, accum):
    cutoff = min(1, abs(accum))
    # cutoff = 0.98
    if cutoff < random.random():
      return 0
    
    s = random.random() * 2
    weight = G_laplace_02(x, s) * -2 * (1/s - 0.5) * 2
    return (x/2 + weight * one_sample(s, accum * weight)) / cutoff
  
  return one_sample(r, 1)

G_laplace_26 = G_laplace_generator(2, 6)
def s_orbital_26(r):
  def one_sample(x, accum):
    cutoff = min(1, abs(accum))
    # cutoff = 0.98
    if cutoff < random.random():
      return 0
    
    s = 2 + random.random() * 4
    weight = G_laplace_26(x, s) * -2 * (1/s - 0.5) * 4
    return (-0.25*(x-2)+1 + weight * one_sample(s, accum * weight)) / cutoff
  
  return one_sample(r, 1)

plot('s_orbital_06.svg',
  x02 + x26,
  [exp(-x)*x*exp(2)/2 for x in x02 + x26],
  [mean([s_orbital_02(r) for _ in range(100)]) for r in x02] +
  [mean([s_orbital_26(r) for _ in range(100)]) for r in x26]
  )

# print([stdev([s_orbital_09(r) for _ in range(100)]) for r in x19])

# img(s_orbital_06.svg)[]

# plot('param_16.svg',
#  # [m/10 for m in range(60)],
#  # [mean([s_orbital_16(2, m/10) for _ in range(100)]) for m in range(60)])
# 
# # img(param_16.svg)[]

