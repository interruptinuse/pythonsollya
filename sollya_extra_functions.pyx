# -*- coding: utf-8 -*- vim: sw=2

""" Some useful functions are not provided by Sollya directly.
    This module wraps such function from mpfr library into SollyaObject """

from csollya cimport *
import sollya
cimport sollya

__version__ = "0.1.1"

cdef sollya.SollyaObject as_SollyaObject(op):
  if isinstance(op, sollya.SollyaObject):
    return op
  else:
    return sollya.SollyaObject(op)

def cbrt(x):
  """ Custom wrapper for MPFR Cubic Root function """
  cdef mpfr_t op, result
  cdef int prec
  cdef sollya.SollyaObject res = sollya.SollyaObject.__new__(sollya.SollyaObject)

  if not sollya_lib_get_constant_as_int(&prec, sollya_lib_get_prec()):
    raise ValueError("unable to get sollya's prec in cbrt")

  mpfr_init2(op, prec)
  mpfr_init2(result, prec)
  cdef sollya.SollyaObject sollya_object = as_SollyaObject(x)
  sollya_lib_get_constant(op, sollya_object.value)
  mpfr_cbrt(result, op, MPFR_RNDN)
  res.value = sollya_lib_constant(result)
  mpfr_clear(op)
  mpfr_clear(result)
  return res

def gamma(x):
  """ Custom wrapper for MPFR Gamma function """
  cdef mpfr_t op, result
  cdef int prec
  cdef sollya.SollyaObject res = sollya.SollyaObject.__new__(sollya.SollyaObject)

  if not sollya_lib_get_constant_as_int(&prec, sollya_lib_get_prec()):
    raise ValueError("unable to get sollya's prec in cbrt")

  mpfr_init2(op, prec)
  mpfr_init2(result, prec)
  cdef sollya.SollyaObject sollya_object = as_SollyaObject(x)
  sollya_lib_get_constant(op, sollya_object.value)
  mpfr_gamma(result, op, MPFR_RNDN)
  res.value = sollya_lib_constant(result)
  mpfr_clear(op)
  mpfr_clear(result)
  return res

S2 = sollya.SollyaObject(2)
