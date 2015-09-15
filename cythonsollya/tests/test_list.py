# -*- coding: utf-8 -*-

from pythonsollya import *

test_expressions = [
  "[exp(2), exp(1)]",
  "[round(v, binary32, RN) for v in acc]",
  "acc * 3",
  "acc * SollyaObject(3)",
  "acc + acc"
]

for expr in test_expressions:
  print expr
  acc = eval(expr)
  print acc
