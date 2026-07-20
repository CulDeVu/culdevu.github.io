import math

A = 65536
B = 4096

res = {}
for a in range(A):
  v = (a*a) // A
  res[v] = res.get(v, 0) + 1
'''for a in range(A):
  for b in range(B):
    v = (a*b) // A
    res[(a, v)] = res.get((a,v), 0) + 1'''
'''for a in range(A):
  for b in range(B):
    v = (a+b) % (2*A)
    res[(a, v)] = res.get((a,v), 0) + 1'''

#print(res)
print(sum([v*math.log2(v) for k,v in res.items()]) / sum([v for k,v in res.items()]))
print(max([v for k,v in res.items()]))

