# -*- coding: utf-8 -*- vim:sw=2

from pythonsollya import *

class A:
  pass

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
  "[binary32] * 4",
  "Interval(-0.5, 0.5)",
  "fpminimax(exp(x), 3, [binary32] * 4, Interval(-0.5, 0.5), absolute)",
  "[A()] * (SollyaObject(11))",
  "(SollyaObject(11)) * [A()]",
  "(SollyaObject(11)) * [binary32]",
  "[binary32] * (SollyaObject(11))",
]

for expr in test_expressions:
  print expr
  acc = eval(expr)
  print acc
