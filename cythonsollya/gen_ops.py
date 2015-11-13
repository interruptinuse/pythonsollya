import sys

ops = []
for op in sys.stdin:
  op = op.strip(" ,\n")
  if not op.startswith("SOLLYA_BASE_FUNC_"):
    raise ValueError
  ops.append(op)

header = open(sys.argv[1], 'w')
header.write(
r"""cdef extern from "sollya.h":
  ctypedef enum sollya_base_function_t:
""")
for op in ops:
  header.write("    " + op + "\n")
header.close()

impl = open(sys.argv[2], 'w')
impl.write("cdef __operator_names = {\n")
for op in ops:
  name = op.replace("SOLLYA_BASE_FUNC_", "", 1)
  impl.write('  {}: "{}",\n'.format(op, name))
impl.write("}\n")
impl.close()
