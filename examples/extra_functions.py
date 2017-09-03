# coding: utf-8
r"""
>>> from sollya_extra_functions import cbrt

>>> cbrt(1)
1

>>> cbrt(27.0) + 2.0
5

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
