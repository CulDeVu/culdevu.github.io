

LINE_TYPE_NONE = 0
LINE_TYPE_CODE = 1
LINE_TYPE_TEXT = 2
LINE_TYPE_SELF_RUNNING = 3
LINE_TYPE_CODE_OR_TEXT = 4

with open('writeup.py', 'r') as f:
  full_file = f.read()
  exec(full_file)
  
  lines = full_file.split('\n')
  with open('../2025-11-01-laplace.md', 'w') as out:
    while lines:
      def line_type(line):
        if line == '':
          return LINE_TYPE_CODE_OR_TEXT
        if line.startswith('# '):
          return LINE_TYPE_TEXT
        if line.startswith('#> '):
          return LINE_TYPE_SELF_RUNNING
        return LINE_TYPE_CODE
      
      def nextish_line_type(ls):
        if not ls:
          return LINE_TYPE_NONE
        if line_type(ls[0]) == LINE_TYPE_CODE_OR_TEXT:
          return nextish_line_type(ls[1:])
        return line_type(ls[0])
      
      def nextish_code(ls):
        if not ls:
          return False
        if ls[0] == '':
          return nextish_code(ls[1:])
        elif ls[0].startswith('# '):
          return False
        else:
          return True
      
      if lines[0] == '':
        out.write('\n')
        lines = lines[1:]
      elif line_type(lines[0]) == LINE_TYPE_SELF_RUNNING:
        out.write('```\n' + lines[0][3:] + '\n```\n')
        exec(f'def proc_writer_magic():\n  return {lines[0][3:]}')
        
        out.write(f'\n> {str(proc_writer_magic())}\n\n')
        
        lines = lines[1:]
      elif lines[0].startswith('# '):
        out.write(lines[0][2:] + '\n')
        
        lines = lines[1:]
        
        if nextish_line_type(lines) == LINE_TYPE_CODE:
          while lines and lines[0] == '':
            lines = lines[1:]
          out.write('\n```\n')
      else:
        out.write(lines[0] + '\n')
        lines = lines[1:]
        
        if not nextish_code(lines):
          out.write('```\n\n')
          while lines and lines[0] == '':
            lines = lines[1:]

