# coding: utf-8
r"""
>>> import sollya

Perhaps the simplest way to perform computations with Sollya is
sollya.parse(), which takes a string containing an expression in Sollya
syntax.

>>> sollya.parse("diff(sin(x));")
cos(x)

Its return value is a Python object of type sollya.SollyaObject. These
objects are Pyton wrappers for Sollya objects, and can also be
manipulated directly.

>>> sollya.x
x

>>> type(sollya.x)
<type 'sollya.SollyaObject'>

>>> sollya.Interval(1, 2)
[1;2]

Various simple Python objects can be converted to Sollya objects, and
simple Sollya objects can be converted back to Python:

>>> sollya.SollyaObject(42)
42

>>> sollya.SollyaObject([True, "hello", sollya.SollyaObject([]),
...                     None, Ellipsis])
[|true, "hello", [| |], void...|]

>>> float(sollya.SollyaObject(42))
42.0

>>> bool(sollya.parse("1 + 1 == 2;"))
True

>>> list(sollya.parse("[| pi, pi^2 |]"))
[pi, (pi)^2]

Arithmetic operations with Sollya objects or between Sollya objects and
Python objects convertible to Sollya mostly works as expected, as do
comparisons and various other standard Python functions. Essentially all
commands and built-in procedures available interactively in Sollya are
bound to Python functions with the same name that automatically convert
their input to Sollya objects (and return Sollya objects).

>>> sollya.SollyaObject(1) + sollya.Interval(1, 2)
[2;3]

>>> 1 + sollya.Interval(1, 2)
[2;3]

>>> (sollya.SollyaObject(2)/3)**2
(2 / 3)^2

>>> sollya_list = sollya.SollyaObject(["a", "b"])
>>> len(sollya_list)
2

>>> sollya_list[0]
a

>>> sollya.pi < 3
False

>>> sollya.exp(1)
exp(1)

>>> sollya.diff(sollya.sin(sollya.x))
cos(x)

Importing * from the sollya module allows one to call Sollya in a
natural way, with a syntax reasonably close to that of interactive
Sollya. Note however that this may shadow other useful definitions of
names such as x, abs and pi. Also note that definitions of
multiple-precision constants typically still need to be wrapped in calls
to parse() or similar.

>>> from sollya import *

>>> abs(x) + sqrt(pi)
abs(x) + sqrt(pi)

More features of Sollya objects:

>>> SollyaObject("").is_string()
True

>>> exp(1), exp(1).approx()
(exp(1), 2.7182818284590452353602874713526624977572470937)

>>> expr = exp(1) + 2*x
>>> expr(0.5)
1 + exp(1)

Destructuring of Sollya “functions” (symbolic expressions):

>>> expr.arity()
2

>>> expr.operator()
ADD

>>> type(expr.operator())
<type 'sollya.SollyaOperator'>

>>> SollyaOperator("sub")(*expr.operands())
exp(1) - 2 * x

Sollya structures are supported, and can be converted from/to Python
dictionaries:

>>> s = SollyaObject({"field": "value", "other_field": 17})
>>> s
{ .field = "value", .other_field = 17 }

>>> s.is_structure()
True

>>> len(s)
2

>>> s.struct.field
value

>>> s.struct.field = None

>>> s
{ .other_field = 17, .field = void }

>>> dict(s)
{'other_field': 17, 'field': void}

>>> list(s)
[('other_field', 17), ('field', void)]

>>> SollyaObject({"éé": 1}) # doctest: +ELLIPSIS
Traceback (most recent call last):
...
RuntimeError: creation of Sollya structure failed

Sollya global settings are accessed as follows:

>>> sollya.settings.display
decimal

>>> sollya.settings.display = binary

>>> SollyaObject(17)
1.0001_2 * 2^(4)

>>> sollya.settings.display = default

>>> SollyaObject(17)
17

>>> sollya.settings.fullparentheses = on

>>> expand((1 + x)**3)
((((x * x) * x) + (3 * (x * x))) + (3 * x)) + 1

>>> del sollya.settings.fullparentheses

>>> expand((1 + x)**3)
x * x * x + 3 * x * x + 3 * x + 1

Or using a context manager:

>>> with sollya.settings(display=sollya.hexadecimal):
...     print(sollya.SollyaObject(17))
0x1.1p4

>>> print(sollya.SollyaObject(17))
17

Calling Python functions from Sollya:

>>> def myproc(x, y): return x + y
>>> foo = SollyaObject(myproc)
>>> foo(x, x)
2 * x

>>> parse("proc(fun) { return fun(1, 2); };")(foo)
3

Implementing new mathematical functions in Python:

>>> def myfunction(x, diff_order, prec): return exp(x)

>>> f = function(myfunction)

>>> f(1)
py_myfunction(1)

>>> f(1).approx()
2.7182818284590452353602874713526624977572470936999

>>> diff(f)(1)
(diff(py_myfunction))(1)

>>> diff(f)(1).approx()
2.7182818284590452353602874713526624977572470936999

Same thing for constants:

>>> def myconstant(prec): return 17

>>> c = libraryconstant(myconstant)

>>> (c/2).approx()
8.5
"""

if __name__ == "__main__":
    import doctest
    doctest.testmod()
