# coding: utf-8
r"""
>>> import sollya

>>> class MyObject:
...    def __init__(self, value):
...        self.value = value
...    def my_method(self, arg0, arg1):
...        #  example of method with multiple arguments 
...        return sollya.SollyaObject(self.value * arg0 + arg1)
...
...    def my_noarg_method(self):
...        # example of method with multiple arguments
...        return sollya.SollyaObject(42)
...    def my_vararg_method(self, *args):
...        # example of method with multiple arguments
...        return sollya.SollyaObject(42)
...    def my_varkw_method(self, **kw):
...        # example of method with multiple arguments
...        return sollya.SollyaObject(42)


>>> a = MyObject(17.0)

exporting a's method as Sollya's function (external procedure)

>>> f = sollya.SollyaObject(a.my_method)
>>> f(2.0, -18.0)
16

exporting a's method without any argument (except self) as Sollya's function
 (external procedure)
>>> g = sollya.SollyaObject(a.my_noarg_method)
>>> g()
42

exporting an unbounded method (only works for python3)

# >>> h = sollya.SollyaObject(MyObject.my_noarg_method)
# >>> ext_data = sollya.externaldata(MyObject(13.0))
# >>> h(ext_data)
# 42

# >>> i = sollya.SollyaObject(MyObject.my_method)
# >>> result = i(sollya.externaldata(MyObject(13.0)), 2.0, -16.0)
# >>> print(result)
# 10


>>> j = sollya.SollyaObject(a.my_vararg_method)
Traceback (most recent call last):
    ...
ValueError: function conversion does not support varargs nor varkeywords

>>> k = sollya.SollyaObject(a.my_varkw_method)
Traceback (most recent call last):
    ...
ValueError: function conversion does not support varargs nor varkeywords

"""
