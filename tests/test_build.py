# -*- coding: utf-8 -*- vim: sw=2
# minimal test script for new python binding for sollya library
# (a.k.a cythonsollya)

import sys
from pythonsollya import *

print "initializing sollya library"
print "a = sollya.SO(1.0)"
a = SollyaObject(1.0)
a.myprint()
print "r = exp(a)"
r = exp(a)
r.myprint()
print "c = exp(2)"
c = exp(2)
c.myprint()
print "exp(SollyaObject())"
try:
  exp(SollyaObject())
except TypeError:
  print "TypeError encountered when creating SollyaObject without parameters"

print "t = c + a"
t = c + a
t.myprint()

print "i = int(t)"
i = int(t)
print i

print "str(c)"
print str(c)

print "SollyaObject([1, 2, 3, 4])"
print SollyaObject([1, 2, 3, 4])

print "SollyaObject(\"hello world\")"
print SollyaObject("hello world")
print "End"


a = parse("0xb.17217f7d2p0")
print a
display(hexadecimal)
print str(a)


sys.exit(0)
