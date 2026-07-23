
class D(object):
  def __init__(self):
    self.w = 0
    self.h = 0
    self.text = ''
    self.anim_text = ''
    self.anim_w = 0
    self.anim_bits_0 = []
    self.anim_bits_1 = []
    self.anim_bits_t = []
    self.anim_bits_p = []
    self.anim_lut = []
    
  def isone(self, ind):
    return self.anim_bits_0[ind]['y'] < self.anim_bits_1[ind]['y']
  def flip(self, ind):
    self.anim_bits_0[ind], self.anim_bits_1[ind] = self.anim_bits_1[ind], self.anim_bits_0[ind]

  def input(self, vals):
    for i,v in enumerate(vals):
      self.text += f'<text x="15" y="{10+10*i}" font-size="8" text-anchor="end" dominant-baseline="middle">{v}</text>'
    self.h = 10 + len(vals)*10
    self.w += 20
    self.n = len(vals)
    for i in range(self.n):
      self.text += f'<path d="M{self.w},{10+10*i} l-3,0" stroke="black"/>'
    
    self.anim_bits_0 = [{"x": 0, "y": i*20} for i in range(len(vals) + 2)]
    self.anim_bits_1 = [{"x": 0, "y": i*20+10} for i in range(len(vals) + 2)]
    self.anim_bits_t = [[0] for _ in range(len(vals) + 2)]
    self.anim_lut = [i for i in range(len(vals))]
    self.cnot_lu = len(vals)
    self.crst_lu = len(vals) + 1
    
  def output(self, vals):
    for i,v in enumerate(vals):
      self.text += f'<text x="{self.w + 5}" y="{10+10*i}" font-size="8" text-anchor="start" dominant-baseline="middle">{v}</text>'
      self.text += f'<path d="M{self.w},{10+10*i} l3,0" stroke="black"/>'
    self.w += 10 + max([len(v) for v in vals])*10
  
  def input_vals(self, vals):
    self.vals = vals
  
  def write_common(self, ind, cF, cT):
    for i in range(self.n):
      self.text += f'<path d="M{self.w},{10+10*i} l10,0" stroke="black"/>'
    
    self.w += 5
    
    m = min(cF + cT + [ind])
    M = max(cF + cT + [ind])
    self.text += f'<path d="M{self.w},{10+10*m} L{self.w},{10+10*M}" stroke="black" fill="none" />'
    
    for i in cF:
      self.text += f'<circle cx="{self.w}" cy="{10+10*i}" r="2" stroke="black" fill="black" />'
    for i in cT:
      self.text += f'<circle cx="{self.w}" cy="{10+10*i}" r="2" stroke="black" fill="white" />'
    
    b = True
    for i in cF:
      if self.isone(self.anim_lut[i]):
        b = False
    for i in cT:
      if not self.isone(self.anim_lut[i]):
        b = False
    return b
  
  def nt(self, ind, cF, cT):
    self.write_common(ind, cF, cT)
    self.text += f'<path d="M{self.w},{10+10*ind} m-3,-3 l6,6 m0,-6 l-6,6" stroke="black" fill="none" />'
    self.w += 5
    
    self.flip(self.anim_lut[ind])
    
  def set(self, ind, cF, cT):
    b = self.write_common(ind, cF, cT)
    self.text += f'<path d="M{self.w},{10+10*ind} m4,0 l-6,-3 l0,6 l6,-3" stroke="black" fill="white"/>'
    self.w += 5
    
    self.anim_lut[ind], self.crst_lu = self.crst_lu, self.anim_lut[ind]
    if b and not self.isone(self.anim_lut[ind]):
      self.flip(self.anim_lut[ind])
    
  def rst(self, ind, cF, cT):
    b = self.write_common(ind, cF, cT)
    self.text += f'<path d="M{self.w},{10+10*ind} m4,0 l-6,-3 l0,6 l6,-3" stroke="black" fill="black"/>'
    self.w += 5
    
    self.anim_lut[ind], self.crst_lu = self.crst_lu, self.anim_lut[ind]
    if b and self.isone(self.anim_lut[ind]):
      self.anim_bits_0[self.anim_lut[ind]], self.anim_bits_1[self.anim_lut[ind]] = self.anim_bits_1[self.anim_lut[ind]], self.anim_bits_0[self.anim_lut[ind]]
  
  def fwrite(self, f):
    f.write(f'<svg version="1.1" width="{d.w*10}" height="{d.h*10}" xmlns="http://www.w3.org/2000/svg">')
    f.write('<g transform="scale(10 10)">')

    f.write(self.text)

    f.write('</g>')
    f.write('</svg>')

  def fwrite_anim(self, fn):
    with open(fn, 'w') as f:
      h = (len(self.anim_bits_0) + len(self.anim_bits_1))*10
      f.write(f'<svg version="1.1" width="{d.w*10}" height="{h}" xmlns="http://www.w3.org/2000/svg">')
      f.write('<g transform="scale(10 10)">')
      
      for box in self.anim_bits_0:
        f.write(f'<rect x="{box["x"]}" y="{box["y"]}" width="10" height="10" fill="lightblue" stroke="black" />')
      for box in self.anim_bits_1:
        f.write(f'<rect x="{box["x"]}" y="{box["y"]}" width="10" height="10" fill="lightpink" stroke="black" />')
      
      f.write('</g>')
      f.write('</svg>')

with open('not_sch.svg', 'w') as f:
  d = D()
  d.input(['A'])
  d.nt(0, [], [])
  d.output(['1-A'])
  
  d.fwrite(f)

with open('rst_sch.svg', 'w') as f:
  d = D()
  d.input(['A'])
  d.rst(0, [], [])
  d.output(['0'])
  d.fwrite(f)

with open('set_sch.svg', 'w') as f:
  d = D()
  d.input(['A'])
  d.set(0, [], [])
  d.output(['1'])
  d.fwrite(f)
with open('set_alt_sch.svg', 'w') as f:
  d = D()
  d.input(['A'])
  d.rst(0, [], [])
  d.nt(0, [], [])
  d.output(['1'])
  d.fwrite(f)

with open('cnot_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.nt(1, [], [0])
  d.output(['A', 'A+B'])
  d.fwrite(f)

with open('cset_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.set(1, [], [0])
  d.output(['A', 'A|B'])
  d.fwrite(f)

with open('crst_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.input_vals([1, 0])
  d.rst(1, [], [0])
  d.output(['A', 'A⇍B'])
  d.fwrite(f)
with open('cset_alt_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.nt(1, [], [])
  d.rst(1, [], [0])
  d.nt(1, [], [])
  d.output(['A', 'A|B'])
  d.fwrite(f)

with open('gate_0_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.rst(1, [], [])
  d.output(['A', '0'])
  d.fwrite(f)
with open('gate_fst_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.rst(1, [], [])
  d.nt(1, [], [0])
  d.output(['A', 'A'])
  d.fwrite(f)
with open('gate_snd_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.output(['A', 'B'])
  d.fwrite(f)
with open('gate_and_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.rst(1, [0], [])
  d.output(['A', 'AB'])
  d.fwrite(f)
with open('gate_implies_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.set(1, [0], [])
  d.output(['A', 'A⇒B'])
  d.fwrite(f)
with open('gate_converse_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B'])
  d.rst(1, [], [0])
  d.nt(1, [], [])
  d.output(['A', 'A⇐B'])
  d.fwrite(f)

with open('fanout.svg', 'w') as f:
  d = D()
  d.input(['A', '0'])
  d.nt(1, [], [0])
  d.output(['A', 'A'])
  d.fwrite(f)

with open('3_way.svg', 'w') as f:
  d = D()
  d.input(['A', 'B', 'C'])
  d.nt(2, [], [0, 1])
  d.set(1, [2], [0])
  d.rst(0, [2], [])
  d.output(['D', 'E', 'F'])
  d.fwrite(f)

with open('not_anim.svg', 'w') as f:
  f.write('''
<svg version="1.1" width="400" height="300" xmlns="http://www.w3.org/2000/svg">
<g transform="scale(10 10)">

<rect x="10" y="10" width="10" height="10" stroke="black" fill="lightpink">
<animate attributeName="x" values="10;10;8;8;22;22;20;20" dur="5s" repeatCount="indefinite" />
<animate attributeName="y" values="10;10;10;3;3;10;10;10" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="20" y="10" width="10" height="10" stroke="black" fill="lightblue">
<animate attributeName="x" values="20;20;22;22;8;8;10;10" dur="5s" repeatCount="indefinite" />
<animate attributeName="y" values="10;10;10;17;17;10;10;10" dur="5s" repeatCount="indefinite" />
</rect>

</g>
</svg>''')

with open('rst_anim.svg', 'w') as f:
  f.write('''
<svg version="1.1" width="400" height="300" xmlns="http://www.w3.org/2000/svg">
<g transform="scale(10 10)">

<rect x="10" y="10" width="10" height="10">
<animate attributeName="fill" values="lightblue;lightblue;plum;lightpink;lightpink" keyTimes="0; 0.16; 0.161; 0.48; 1" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="20" y="10" width="10" height="10" fill="lightpink">
<animate attributeName="fill" values="lightpink;lightpink;plum;lightpink;lightblue;lightblue" keyTimes="0;0.16;0.161;0.48;0.64;1" dur="5s" repeatCount="indefinite" />
<animate attributeName="width" values="10;10;0;0;10;10" keyTimes="0;0.32;0.48;0.64;0.8;1" dur="5s" repeatCount="indefinite" />
</rect>

<path d="M30,10 L10,10 L10,20 L30,20" stroke="black" fill="none" stroke-linecap="square" />
<path d="M20,10 l0,10" stroke="black" stroke-linecap="square">
<animate attributeName="d" values="M20,10 l0,10; M20,10 l0,10; M20,-2 l0,10; M20,-2 l0,10; M20,10 l0,10; M20,10 l0,10" dur="5s" keyTimes="0;0.16;0.32;0.48;0.64;1" repeatCount="indefinite" />
</path>

<path d="M30,10 l0,10 m0,-5 l5,0" stroke="black" fill="none" stroke-linecap="square">
<animateTransform attributeName="transform" type="translate" values="0;0;-10;-10;0;0" keyTimes="0;.32;.48;.64;.8;1" dur="5s" repeatCount="indefinite" />
</path>

</g>
</svg>''')

with open('rst_anim_2.svg', 'w') as f:
  f.write('''
<svg version="1.1" width="400" height="600" xmlns="http://www.w3.org/2000/svg">
<g transform="scale(10 10)">

<rect x="10" width="10">
  <animate attributeName="y" values="10;10;20;20" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="height" values="10;10;0;0" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="fill" values="lightblue;lightblue;plum;lightpink;lightpink" keyTimes="0;.3;.301;.6;1" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="20" width="10">
  <animate attributeName="y" values="10;10;20;20" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="height" values="10;10;0;0" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="fill" values="lightpink;lightpink;plum;lightpink;lightpink" keyTimes="0;.3;.301;.6;1" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="10" y="40" width="10">
  <animate attributeName="height" values="0;0;10;10" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="fill" values="plum;plum;lightpink;lightpink" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="20" y="40" width="10" height="10" fill="lightblue" />

<!-- wires -->
<path d="M15,20 c0,5 4,5 4,10" stroke="black" fill="none" />
<path d="M25,20 c0,5 -4,5 -4,10" stroke="black" fill="none" />
<path d="M12.5,40 c0,-5 6.5,-5 6.5,-10" stroke="black" fill="none" />
<path d="M17.5,40 c0,-5 3.5,-5 3.5,-10" stroke="black" fill="none" />

<path d="M10,50 l0,-10 l20,0 l0,10 l-10,0 l0,-10" stroke="black" fill="none" stroke-linecap="square" />
<path d="M10,10 l0,10 l20,0 l0,-10 m-10,0 l0,10" stroke="black" fill="none" stroke-linecap="square" />

<path d="M10,10 l20,0 m-15,0 l0,-5 m10,5 l0,-5 M10,40 l10,0 m-5,0 l0,5" stroke="black" fill="none" stroke-linecap="square">
  <animateTransform attributeName="transform" type="translate" values="0,0;0,0;0,10;0,10;" keyTimes="0;.3;.6;1" dur="5s" repeatCount="indefinite" />
</path>

</g>
</svg>''')

with open('crst_anim.svg', 'w') as f:
  f.write('''
<svg version="1.1" width="400" height="700" xmlns="http://www.w3.org/2000/svg">
<g transform="scale(10 10)">

<rect x="10" width="10">
  <animate attributeName="y" values="10;10;20;20" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="height" values="10;10;0;0" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="fill" values="lightblue;lightblue;plum;lightpink;lightpink" keyTimes="0;.5;.501;.75;1" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="20" width="10">
  <animate attributeName="y" values="10;10;20;20" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="height" values="10;10;0;0" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="fill" values="lightpink;lightpink;plum;lightpink;lightpink" keyTimes="0;.5;.501;.75;1" dur="5s" repeatCount="indefinite" />
</rect>

<!-- wires -->
<path d="M15,20 c0,5 4,5 4,10" stroke="black" fill="none" />
<path d="M25,20 c0,5 -4,5 -4,10" stroke="black" fill="none" />

<path d="M10,10 l0,10 l20,0 l0,-10 m-10,0 l0,10" stroke="black" fill="none" stroke-linecap="square" />

<path d="M10,10 l20,0 m-15,0 l0,-5 m10,5 l0,-5" stroke="black" fill="none" stroke-linecap="square">
  <animateTransform attributeName="transform" type="translate" values="0,0;0,0;0,10;0,10;" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
</path>

<!-- middle -->
<g>
  <rect x="3" y="30" width="10" height="10" stroke="black" fill="lightpink" />
  <rect x="23" y="30" width="10" height="10" stroke="black" fill="lightblue" />
  <path d="M19,30 l0,10 m2,-10 c0,5 -2,5 -2,10" stroke="black" fill="none" />
  <path d="M15,30 l0,10 m2,-10 l0,10" stroke="black" fill="none" />
  <path d="M3,30 l0,10 m0,-5 l-5,0" stroke="black" fill="none" />
  <animateTransform attributeName="transform" type="translate" values="0;0;4;4;" keyTimes="0;.25;.5;1" dur="5s" repeatCount="indefinite" />
</g>

<!-- last box -->
<path d="M15,50 c0,-5 4,-5 4,-10" stroke="black" fill="none" />
<path d="M25,50 c0,-5 -4,-5 -4,-10" stroke="black" fill="none" />

<rect x="10" y="50" width="10">
  <animate attributeName="height" values="0;0;10;10" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
  <animate attributeName="fill" values="plum;plum;lightpink;lightpink" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
</rect>
<rect x="20" y="50" width="10" fill="lightblue">
  <animate attributeName="height" values="0;0;10;10" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
</rect>

<path d="M10,50 l20,0 m-5,0 l0,5 m-10,-5 l0,5" stroke="black" fill="none" stroke-linecap="square">
  <animateTransform attributeName="transform" type="translate" values="0,0;0,0;0,10;0,10;" keyTimes="0;.5;.75;1" dur="5s" repeatCount="indefinite" />
</path>

<path d="M10,60 l0,-10 l20,0 l0,10 m-10,-10 l0,10" stroke="black" fill="none" stroke-linecap="square" />

</g>
</svg>''')

with open('full_adder_2_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B', 'C', '0'])
  d.nt(3, [], [0, 1])
  d.nt(3, [], [0, 2])
  d.nt(3, [], [1, 2])
  d.nt(1, [], [0])
  d.nt(1, [], [2])
  d.rst(2, [], [])
  d.output(['A', 'S', '0', 'D'])
  d.fwrite(f)

with open('adder_sch.svg', 'w') as f:
  d = D()
  d.input(['A', 'B', 'C'])
  d.nt(1, [], [0])
  d.nt(1, [], [2])
  d.rst(2, [0], [1])
  d.set(2, [1], [0])
  d.output(['A', 'S', 'D'])
  d.fwrite(f)
  d.fwrite_anim('adder_anim.svg')

with open('ripple_adder_sch.svg', 'w') as f:
  d = D()
  d.input(['A3', 'A2', 'A1', 'A0', 'B3', 'B2', 'B1', 'B0', '0'])
  
  d.nt(7, [], [3])
  d.set(8, [7], [3])
  
  d.nt(6, [], [2])
  d.nt(6, [], [8])
  d.rst(8, [2], [6])
  d.set(8, [6], [2])
  
  d.nt(5, [], [1])
  d.nt(5, [], [8])
  d.rst(8, [1], [5])
  d.set(8, [5], [1])
  
  d.nt(4, [], [0])
  d.nt(4, [], [8])
  d.rst(8, [0], [4])
  d.set(8, [4], [0])
  
  d.output(['A3', 'A2', 'A1', 'A0', 'S3', 'S2', 'S1', 'S0', 'D'])
  d.fwrite(f)

with open('adder_2x2_sch.svg', 'w') as f:
  d = D()
  d.input(['A1', 'A0', 'B1', 'B0', 'C'])
  d.nt(3, [1], [4])
  d.nt(3, [4], [1])
  
  d.nt(2, [0, 1, 3], [4])
  d.nt(2, [0, 3], [1, 4])
  d.nt(2, [0, 3, 4], [1])
  d.nt(2, [0], [1, 3, 4])

  d.nt(2, [4], [0, 1, 3])
  d.nt(2, [1, 4], [0, 3])
  d.nt(2, [1], [0, 3, 4])
  d.nt(2, [1, 3, 4], [0])

  d.rst(4, [0, 1, 2], [3])
  d.rst(4, [0, 1, 3], [2])
  d.rst(4, [0, 1], [2, 3])
  d.rst(4, [0, 3], [1, 2])
  d.rst(4, [0], [1, 2, 3])
  d.set(4, [0, 2, 3], [1])

  d.set(4, [3], [0, 1, 2])
  d.set(4, [2], [0, 1, 3])
  d.set(4, [2, 3], [0, 1])
  d.set(4, [1, 2], [0, 3])
  d.set(4, [1, 2, 3], [0])
  d.rst(4, [1], [0, 2, 3])

  d.output(['A1', 'A0', 'S1', 'S0', 'D'])
  d.fwrite(f)








