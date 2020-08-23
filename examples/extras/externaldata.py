# coding: utf-8
r"""
>>> import sollya
>>> from sollya import *
>>> foo = externaldata("bar", None)
>>> foo
bar
>>> foo is None
False
>>> foo.is_externaldata()
True
>>> foo.python() is None
True
"""

if __name__ == "__main__":
    import doctest
    doctest.testmod()
