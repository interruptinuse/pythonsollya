# coding: utf-8
r"""
>>> import sollya
>>> from sollya import *
>>> sollya.pi
pi

>>> round(sollya.pi, sollya.binary16, sollya.RN)
3.140625

>>> round(sollya.pi, sollya.binary32, sollya.RN)
3.1415927410125732421875
>>> round(sollya.pi, sollya.binary64, sollya.RN)
3.141592653589793115997963468544185161590576171875

>>> round(sollya.pi, sollya.binary80, sollya.RN)
3.1415926535897932385128089594061862044327426701784

>>> sollya.settings.display=sollya.hexadecimal

>>> round(sollya.pi, sollya.binary80, sollya.RN)
0x1.921fb54442d1846ap1

>>> round(sollya.pi, sollya.binary64, sollya.RN)
0x1.921fb54442d18p1
"""

if __name__ == "__main__":
    import doctest
    doctest.testmod()
