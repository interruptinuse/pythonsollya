

import sollya

for f in [sollya.sqrt, sollya.exp, sollya.log, sollya.log2, sollya.log10, sollya.sin, sollya.cos, sollya.tan, sollya.asin, sollya.acos, sollya.sinh, sollya.cosh, sollya.tanh, sollya.asinh, sollya.acosh, sollya.erf, sollya.erfc, sollya.log1p, sollya.expm1]:
  print sollya.evaluate(f(2), 50)

