# -*- coding: utf-8 -*-

import sollya
from sollya import SollyaObject

def get_list(b):
    return [b * 2 for i in range(3)]

class A:
    def __init__(self, value):
        self.value = value

    def method0(self, b):
        print("method0({}), {}".format(b, b.__class__))
        return sollya.externaldata(A(b))

    def method(self, b):
        print("method({})".format(b))
        l = [b.value, b.value+1, b.value +2]
        print(l)
        l = filter(lambda v: v >= b.value+1, l)
        print(list(l))
        print(l)
        print(list(l))
        #return self.value + sum(list(l) + get_list(b.value - 3))
        return self.value + sum(list(l)) # + get_list(b.value - 3))

def no_method0(b):
    print("no_method0({}), {}".format(b, b.__class__))
    return sollya.externaldata(A(b))

def no_method(b):
    print("no_method({})".format(b))
    l = [b.value, b.value+1, b.value +2]
    print(l)
    l = filter(lambda v: v >= b.value+1, l)
    print(list(l))
    print(l)
    print(list(l))
    #return self.value + sum(list(l) + get_list(b.value - 3))
    return 3 + sum(list(l)) # + get_list(b.value - 3))

def my_func(b):
    return b + 42

sollya.execute("roundtrip.sol")

callPythonFunction = sollya.parse("callPythonFunction")

print(callPythonFunction(SollyaObject(A(3).method), SollyaObject(A(2).method0), SollyaObject(-2)))

print(callPythonFunction(SollyaObject(no_method), SollyaObject(no_method0), SollyaObject(-2)))
