# coding: utf-8
r"""
>>> from sollya_extra_functions import cbrt, S2

An extension module called sollya_extra_functions, provides a few objects and
functions which are not part of sollya library. Such as the constant 2:

>>> S2
2

and the cubic root function:

>>> cbrt(1)
1

>>> cbrt(27.0) + 2.0
5

This Function accepts any input compatible with a conversion to a SollyaObject
and returns a SolllyaObject. It can be mixed with sollya objects.

>>> from sollya import log2
>>> cbrt(log2(8.0)**3)
3

>>> cbrt(42.875)
3.5

>>> import sollya
>>> cbrt(27.0) + sollya.SollyaObject(2.0)
5

"""

if __name__ == "__main__":
    import doctest
    doctest.testmod()
