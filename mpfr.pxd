cimport cmpfr

cdef class Mpfr_t:
    """
    definition of Mpfr_t, original declaration is in mpfr.pyx
    """
    cdef cmpfr.__mpfr_struct _value
