import math
from math import pi, sin, cos, tan, sqrt, asin, acos, atan2

R = 20

def to_3d(x, space):
    phi = x[0] / R
    v = [R*cos(x[1])*sin(phi), R*sin(x[1])*sin(phi), R*cos(phi)]
    v = [
        space[0][0]*v[0] + space[1][0]*v[1] + space[2][0]*v[2],
        space[0][1]*v[0] + space[1][1]*v[1] + space[2][1]*v[2],
        space[0][2]*v[0] + space[1][2]*v[1] + space[2][2]*v[2]]
    return v

def to_chart(v, space):
    v = [
        space[0][0]*v[0] + space[0][1]*v[1] + space[0][2]*v[2],
        space[1][0]*v[0] + space[1][1]*v[1] + space[1][2]*v[2],
        space[2][0]*v[0] + space[2][1]*v[1] + space[2][2]*v[2]]

    LC = acos(v[2]/R) * R
    tC = atan2(v[1], v[0])
    return [LC, tC]

def path(a, b, stroke='black'):
    return f'<path d="M {a[0]*cos(a[1])} {a[0]*sin(a[1])} L {b[0]*cos(b[1])} {b[0]*sin(b[1])}" stroke="{stroke}" fill="none" />'
def path2(c, stroke='black'):
  strs = [f'{v[0]*cos(v[1])} {v[0]*sin(v[1])} ' for v in c]
  return f'<path d="M {"".join(strs)}" stroke="{stroke}" fill="none" />'

def cross(a, b):
    return [
        a[1]*b[2]-a[2]*b[1],
        a[2]*b[0]-a[0]*b[2],
        a[0]*b[1]-a[1]*b[0]]

def norm(v):
    L = sqrt(v[0]**2 + v[1]**2 + v[2]**2)
    return [x/L for x in v]

A = (35, 0.2)
# A = (10, 1.9999)
B = (48, 2)

survey_space = [[1,0,0], [0,1,0], [0,0,1]]
A_space = [
    cross(norm(to_3d(A, survey_space)), [1,0,0]),
    cross(norm(to_3d(A, survey_space)), cross(norm(to_3d(A, survey_space)), [1,0,0])),
    norm(to_3d(A, survey_space))]

# print(to_chart(to_3d(to_chart(to_3d(A, survey_space), A_space), A_space), survey_space))
# print(A_space)
# print(to_chart(to_3d(A, survey_space), A_space))

def gen_geodesic(A, B):
  c = [[to_3d(A, survey_space)[i]*(1-l/100) + to_3d(B, survey_space)[i]*l/100 for i in range(3)]for l in range(101)]
  c = [norm(v) for v in c]
  c = [[R * x for x in v] for v in c]
  c = [to_chart(v, survey_space) for v in c]
  return c
AB_geodesic = gen_geodesic(A, B)

AB_flatline = [(
  A[0]*cos(A[1])*(1-i/100) + B[0]*cos(B[1])*i/100, 
  A[0]*sin(A[1])*(1-i/100) + B[0]*sin(B[1])*i/100) for i in range(101)]
AB_flatline = [[sqrt(x*x+y*y), atan2(y,x)] for x,y in AB_flatline]

with open('a.svg', 'w') as f:
    f.write('<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">\n')
    f.write('<g transform="translate(50 50)">')

    for a_ind in range(20):
        a = 2 * math.pi * a_ind / 20
        f.write(f'<path d="M 0 0 L {50*cos(a)} {50*sin(a)}" stroke="grey" />')
    for a_ind in range(1, 6):
        f.write(f'<circle cx="0" cy="0" r="{10*a_ind}" stroke="grey" fill="none"/>')

    # f.write(f'<path d="M {A[0]*cos(A[1])} {A[0]*sin(A[1])} L {B[0]*cos(B[1])} {B[0]*sin(B[1])}" stroke="black" />')
    
    c = [v for v in AB_flatline]
    # for i in range(len(c)-1):
      # f.write(path(c[i], c[i+1]))
    f.write(path2(c))

    # geodesic = []
    # for a_ind in range(10):
        # phiA = A[0] / R
        # phiB = B[0] / R
        # vA = [cos(A[1])*sin(phiA), sin(A[1])*sin(phiA), cos(phiA)]
        # vB = [cos(B[1])*sin(phiB), sin(B[1])*sin(phiB), cos(phiB)]
        # l = a_ind / 10
        # v = [vA[i]*(1-l) + vB[i]*l for i in range(3)]
        # L = sqrt(v[0]**2 + v[1]**2 + v[2]**2)
        # v = [R*x/L for x in v]
        # LC = acos(v[2]/R) * R
        # tC = atan2(v[1], v[0])
        # geodesic.append((LC, tC))
    # geodesic.append(B)
    # print(geodesic)
    # for i in range(len(AB_geodesic)-1):
        # a = AB_geodesic[i]
        # b = AB_geodesic[i+1]
        # f.write(f'<path d="M {a[0]*cos(a[1])} {a[0]*sin(a[1])} L {b[0]*cos(b[1])} {b[0]*sin(b[1])}" stroke="black" fill="none" />')
    f.write(path2(AB_geodesic))

    f.write('</g>')
    f.write('</svg>')

with open('b.svg', 'w') as f:
    f.write('<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">\n')
    f.write('<g transform="translate(50 50)">')

    for a_ind in range(20):
        a = 2 * math.pi * a_ind / 20
        c = [[r, a] for r in range(51)]
        c = [to_chart(to_3d(x, survey_space), A_space) for x in c]
        # for i in range(len(c)-1):
            # f.write(path(c[i], c[i+1], 'gray'))
        f.write(path2(c, 'gray'))
    for r in range(10, 60, 10):
        c = [[r, 2 * pi * i / 60] for i in range(61)]
        c = [to_chart(to_3d(x, survey_space), A_space) for x in c]
        for i in range(len(c)-1):
            f.write(path(c[i], c[i+1], 'gray'))
        f.write(path2(c, 'gray'))

    # c = [[to_3d(A, survey_space)[i]*(1-l/20) + to_3d(B, survey_space)[i]*l/20 for i in range(3)]for l in range(21)]
    # c = [norm(v) for v in c]
    # c = [[R * x for x in v] for v in c]
    # c = [to_chart(v, A_space) for v in c]
    c = [to_chart(to_3d(v, survey_space), A_space) for v in AB_geodesic]
    # for i in range(len(c)-1):
        # f.write(path(c[i], c[i+1]))
    f.write(path2(c))
    
    c = [to_chart(to_3d(v, survey_space), A_space) for v in AB_flatline]
    f.write(path2(c))

    f.write('</g>')
    f.write('</svg>')

print('BAD length from A to B:')
length = 0
for i in range(len(AB_flatline) - 1):
  dL = AB_flatline[i+1][0] - AB_flatline[i][0]
  dT = AB_flatline[i+1][1] - AB_flatline[i][1]
  length += sqrt(dL**2 + (R * dT)**2)
print(length)

print('TRUE length from A to B:')
length = 0
for i in range(len(AB_geodesic) - 1):
  dL = AB_geodesic[i+1][0] - AB_geodesic[i][0]
  dT = AB_geodesic[i+1][1] - AB_geodesic[i][1]
  length += sqrt(dL**2 + (R * sin(AB_geodesic[i][0] / R) * dT)**2)
print(length)

def cov_deriv_sphere(path):
  accum = 0
  for i in range(1, len(path)-1):
    L = path[i][0]
    T = path[i][1]
    
    dL = (path[i+1][0] - path[i][0])
    dT = (path[i+1][1] - path[i][1])
    da = sqrt(dL**2 + (R * sin(L / R) * dT)**2)
    
    dLda = dL / da
    dTda = dT / da
    
    L_ = path[i-1][0]
    dL_ = (path[i][0] - path[i-1][0])
    dT_ = (path[i][1] - path[i-1][1])
    da_ = sqrt(dL_**2 + (R * sin(L_ / R) * dT_)**2)
    ddLdaa = (dL/da - dL_/da_) / da_
    ddTdaa = (dT/da - dT_/da_) / da_
    
    # should be correct:
    # der_dL = (1/tan(L/R)/R) * dT
    # der_dT = (1/tan(L/R)/R) * dL + (-R * sin(L/R) * cos(L/R)) * dT
    
    accum = max(accum, abs(ddLdaa + (-R * sin(L/R) * cos(L/R))*dTda*dTda), abs(ddTdaa + 2*(1/tan(L/R)/R*dLda*dTda)))
    # accum = max(accum, abs(ddLdaa + (-R * sin(L/R) * cos(L/R))*dTda*dTda) + ddTdaa + 2*(1/tan(L/R)/R*dLda*dTda))
  return accum

print('NON geodesic from A to B:')
print(cov_deriv_sphere(AB_flatline))

print('TRUE geodesic from A to B')
print(cov_deriv_sphere(AB_geodesic))

















