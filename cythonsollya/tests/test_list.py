# -*- coding: utf-8 -*-

from pythonsollya import *

test_expressions = [
  "[exp(2), exp(1)]",
  "[round(v, binary32, RN) for v in acc]",
  "acc * 3",
  "acc * SollyaObject(3)",
  "acc + acc",
  "fpminimax(exp(x), 3, [binary32] * 4, Interval(-0.5, 0.5))",
  "absolute",
  "absolute == relative",
  "absolute == absolute",
  "2 == SollyaObject(2)",
  "fpminimax(exp(x), 3, [binary32] * 4, Interval(-0.5, 0.5), absolute)",
]

for expr in test_expressions:
  print expr
  acc = eval(expr)
  print acc
