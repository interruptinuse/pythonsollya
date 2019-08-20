import sollya

class BinaryFloatingPointFormat(object):
    r"""
    An object with a custom conversion to Sollya.

    >>> import sollya
    >>> sollya.SollyaObject(BinaryFloatingPointFormat(16))
    halfprecision

    >>> sollya.settings.display = sollya.binary

    >>> for sz in [16, 32, 64, 65]:
    ...     fmt = BinaryFloatingPointFormat(sz)
    ...     try:
    ...         print(sollya.round(sollya.pi, fmt, sollya.RN))
    ...     except ValueError:
    ...         print("unsupported")
    1.1001001_2 * 2^(1)
    1.10010010000111111011011_2 * 2^(1)
    1.1001001000011111101101010100010001000010110100011_2 * 2^(1)
    unsupported
    """

    def __init__(self, size):
        self.size = size

    def _sollya_(self):
        if self.size == 16:
            return sollya.binary16
        elif self.size == 32:
            return sollya.binary32
        elif self.size == 64:
            return sollya.binary64
        elif self.size == 80:
            return sollya.binary80
        elif self.size == 128:
            return sollya.binary128
        else:
            raise ValueError

