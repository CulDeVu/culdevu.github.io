import math
from math import pi, sqrt, sin, tan, atan
from statistics import mean, stdev
from random import gauss, random

def r(s):
    return gauss(0, s)

sensitivity_illum = 1
sensitivity_length = 0 #1/32
sensitivity_ang = 2*pi/360 / 100

# R = 100000
# R = 65000000/pi
# R = 2000000
R = 8000000

# a = 10000
# b = 100
# A = atan(tan(a/R) / sin(b/R))

# a_ = [(b + r(sensitivity_length)) * tan(A + r(sensitivity_ang)) for _ in range(1000)]
# print(mean(a_), stdev(a_))



def measure(L):
    a = L
    # b = 1000
    b = L/1000
    A = atan(tan(a/R) / sin(b/R))
    measured_L = (b + r(sensitivity_length)) * tan(A + r(sensitivity_ang))
    B = atan(tan(b/R) / sin(a/R))
    measured_B = B + r(sensitivity_ang)
    return (L, b / measured_B)



import numpy as np
outs = np.zeros((4, 8000))
for iter in range(8000):
    vals = []
    for L in range(16000, 800000, 16000):
        # m = measure(L)
        m = (L, R*sin(L/R))
        vals.append(m)
        if iter == 0:
            print(m[0], m[1] - m[0])

    mat = np.zeros((len(vals), 4))
    y = np.zeros((len(vals), 1))
    for i, v in enumerate(vals):
        L,d = v
        # mat[i,0] = L**2
        mat[i,0] = L**3
        # mat[i,2] = L**4
        mat[i,1] = L**5
        # mat[i,4] = L**6
        mat[i,2] = L**7
        # mat[i,6] = L**8
        mat[i,3] = L**9
        y[i] = d - L
    x = (np.linalg.inv(mat.T @ mat) @ mat.T @ y)
    # x = x * np.array([[1*2, 1*2*3, 1*2*3*4, 1*2*3*4*5, 1*2*3*4*5*6, 1*2*3*4*5*6*7, 1*2*3*4*5*6*7*8, 1*2*3*4*5*6*7*8*9]]).T
    x = x * np.array([[1*2*3, 1*2*3*4*5, 1*2*3*4*5*6*7, 1*2*3*4*5*6*7*8*9]]).T
    outs[:, iter] = (x.T)[0]
    # print(mat)
    # print(x)
    # print(x * np.array([[1*2, 1*2*3, 1*2*3*4, 1*2*3*4*5, 1*2*3*4*5*6, 1*2*3*4*5*6*7, 1*2*3*4*5*6*7*8, 1*2*3*4*5*6*7*8*9]]).T)

# print(outs)
print(np.mean(outs, axis=1))
print(np.std(outs, axis=1) / sqrt(8000))

print('--')
print(outs[:, 0])
print(np.std(outs, axis=1))



