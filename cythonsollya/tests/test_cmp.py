# -*- coding: utf-8 -*-

from pythonsollya import *

test_expressions = [
  "exp(2) == exp(2)",
  "exp(0) > 1",
  "exp(0) == 1.0",
  "exp(x) == exp(x)",
  "exp(3) > log(1)",
  "parse(\"0x2p-24\") > parse(\"0x1.8p-24\")",
  "parse(\"0x2p-24\") < parse(\"0x1.8p-24\")",
]

for expr in test_expressions:
  print expr
  acc = eval(expr)
  print acc
