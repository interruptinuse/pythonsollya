# -*- coding: utf-8 -*- vim: sw=2

from csollya cimport *
cimport libc.stdint
from cpython.int cimport PyInt_AsLong
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from cpython.string cimport PyString_AsString
from libc.stdlib cimport malloc, free

## initialization of Sollya library
sollya_lib_init()

# Create a new SollyaObject wrapping sollya_val, taking ownership of sollya_val
# (which will thus be cleared when the SollyaObject gets garbage-collected)
cdef SollyaObject wrap(sollya_obj_t sollya_val):
  cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
  result.value = sollya_val
  return result

cdef SollyaObject as_SollyaObject(op):
  if isinstance(op, SollyaObject):
    return op
  else:
    return SollyaObject(op)

cdef class SollyaObject:

  def __cinit__(self):
    self.value = NULL

  def __init__(self, op):
    self.value = convertPythonTo_sollya_obj_t(op)

  def __dealloc__(self):
    if self.value is not NULL:
      sollya_lib_clear_obj(self.value)

  def __hash__(self):
    return sollya_lib_hash(self.value)

  def __repr__(SollyaObject self):
    cdef int n = sollya_lib_snprintf(NULL, 0, <char*>"%b", <sollya_obj_t>self.value)
    cdef sollya_obj_t sollya_op = self.value
    cdef char* result_str
    if n > 0:
      result_str = <char*>malloc(n+1)
      sollya_lib_snprintf(result_str, n+1, <char*>"%b", <sollya_obj_t>self.value)
      return result_str
    else:
      return ""

  def myprint(self):
    sollya_lib_autoprint(self.value)

  # Conversions

  def __nonzero__(self):
    if sollya_lib_is_true(self.value):
      return True
    elif sollya_lib_is_false(self.value):
      return False
    else:
      # XXX: is this what we want?
      raise ValueError("not a boolean")

  def __int__(SollyaObject self):
    cdef int i
    cdef int64_t result[1]
    i = sollya_lib_get_constant_as_int64(result, self.value)
    return result[0]

  def getConstantAsInt(SollyaObject self):
    cdef sollya_obj_t tmp, c64, divr, divr_, prod, rem, c0
    cdef int64_t result[1]
    cdef int status
    tmp = sollya_lib_copy_obj(self.value) #sollya_lib_nearestint(self.value)
    c64 = sollya_lib_constant_from_int64(1 << 32)
    c0  = sollya_lib_constant_from_int64(0)
    weight = 0
    value = 0
    wd = 0
    while sollya_lib_cmp_not_equal(tmp, c0):
      divr_ = sollya_lib_div(tmp, c64)
      divr = sollya_lib_nearestint(divr_)
      prod = sollya_lib_mul(divr, c64)
      rem = sollya_lib_sub(tmp, prod)
      status = sollya_lib_get_constant_as_int64(result, rem)
      value += result[0] * 2**weight
      weight += 32
      tmp = sollya_lib_copy_obj(divr)
      sollya_lib_clear_obj(divr)
      sollya_lib_clear_obj(rem)
      sollya_lib_clear_obj(prod)
      wd += 1
      if wd > 10: break
    sollya_lib_clear_obj(tmp)
    sollya_lib_clear_obj(c64)
    sollya_lib_clear_obj(c0)
    return value

  ## wrapper for constant as int
  def getConstantAsIntLegacy(SollyaObject self):
    return int(self)

  def getConstantAsUInt(SollyaObject self):
    cdef int i 
    cdef uint64_t result[1]
    i = sollya_lib_get_constant_as_uint64(result, self.value)
    return result[0]

  def __float__(SollyaObject self):
    cdef int i
    cdef double result[1]
    i = sollya_lib_get_constant_as_double(result, self.value)
    return result[0]

  # Container methods

  def __len__(self):
    cdef sollya_obj_t sollya_len
    cdef int64_t int_len = -1
    try:
      sollya_len = sollya_lib_length(self.value)
      if sollya_lib_obj_is_error(sollya_len):
        raise ValueError("this Sollya object has no length")
      if not sollya_lib_get_constant_as_int64(&int_len, sollya_len):
        raise ValueError("unable to convert the length to an integer")
      return int_len
    finally:
      sollya_lib_clear_obj(sollya_len)

  def __getitem__(self, index):
    if not sollya_lib_obj_is_list(self.value):
      raise ValueError("not a Sollya list")
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    if sollya_lib_get_element_in_list(&result.value, self.value, PyInt_AsLong(int(index))):
      return result
    else:
      raise IndexError("index out of range")

  def __contains__(self, elt):
    res = sollya_lib_cmp_in(as_SollyaObject(elt).value, self.value)
    return sollya_lib_is_true(res)

  # Arithmetic operators

  def __neg__(self):  # -self
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0 = as_SollyaObject(self)
    result.value = sollya_lib_neg(op0.value)
    return result

  def __add__(left, right):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0, op1
    cdef int list_length
    if isinstance(left, list) and isinstance(right, SollyaObject):
      return left + list(right)
    elif isinstance(left, SollyaObject) and isinstance(right, list):
      return list(left) + right
    else:
      op0 = as_SollyaObject(left)
      op1 = as_SollyaObject(right)
      result.value = sollya_lib_add(op0.value, op1.value)
      return result

  def __sub__(left, right):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0 = as_SollyaObject(left)
    cdef SollyaObject op1 = as_SollyaObject(right)
    result.value = sollya_lib_sub(op0.value, op1.value)
    return result

  def __mul__(left, right):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0, op1
    cdef bint sollya_obj_is_list
    if isinstance(left, list):
      return left * int(right)
    elif isinstance(right, list):
      return int(left) * right
    elif (isinstance(left, SollyaObject)
        and sollya_lib_obj_is_list((<SollyaObject>left).value)):
      return list(left) * int(right)
    elif (isinstance(right, SollyaObject)
        and sollya_lib_obj_is_list((<SollyaObject>right).value)):
      return int(left) * list(right)
    else:
      op0 = as_SollyaObject(left)
      op1 = as_SollyaObject(right)
      result.value = sollya_lib_mul(op0.value, op1.value)
      return result

  def __div__(left, right):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0 = as_SollyaObject(left)
    cdef SollyaObject op1 = as_SollyaObject(right)
    result.value = sollya_lib_div(op0.value, op1.value)
    return result

  def __pow__(self, op, modulo):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0 = as_SollyaObject(self)
    cdef SollyaObject op1 = as_SollyaObject(op)
    result.value = sollya_lib_pow(op0.value, op1.value)
    return result

  # Comparison operators

  def __richcmp__(SollyaObject self, py_other, int cmp_op):
    cdef SollyaObject other = as_SollyaObject(py_other)
    cdef sollya_obj_t result = NULL
    if cmp_op == Py_LT:
      result = sollya_lib_cmp_less(self.value, other.value)
    elif cmp_op == Py_EQ:
      result = sollya_lib_cmp_equal(self.value, other.value)
    elif cmp_op == Py_GT:
      result = sollya_lib_cmp_greater(self.value, other.value)
    elif cmp_op == Py_LE:
      result = sollya_lib_cmp_less_equal(self.value, other.value)
    elif cmp_op == Py_NE:
      result = sollya_lib_cmp_not_equal(self.value, other.value)
    elif cmp_op == Py_GE:
      result = sollya_lib_cmp_greater_equal(self.value, other.value)
    cdef bint bool_result = sollya_lib_is_true(result)
    sollya_lib_clear_obj(result)
    return bool_result

  def identical(self, SollyaObject other):
    return sollya_lib_cmp_objs_structurally(self.value, other.value)

  def approx(self):
    return wrap(sollya_lib_approx(self.value))

cdef sollya_obj_t convertPythonTo_sollya_obj_t(op) except NULL:
  cdef sollya_obj_t sollya_op
  cdef sollya_obj_t* sollya_list
  cdef int n
  if isinstance(op, SollyaObject):
    return sollya_lib_copy_obj((<SollyaObject>op).value)
  elif isinstance(op, float):
    return sollya_lib_constant_from_double(<double>op)
  elif isinstance(op, bool): # must come before int
    return sollya_lib_true() if op else sollya_lib_false()
  elif isinstance(op, int):
    return sollya_lib_constant_from_int64(PyInt_AsLong(op))
  elif isinstance(op, list):
    n = len(op)
    sollya_list = <sollya_obj_t*>malloc(sizeof(sollya_obj_t) * n)
    for i in range(n):
      sollya_list[i] = convertPythonTo_sollya_obj_t(op[i])
    sollya_op = sollya_lib_list(sollya_list, n)
    for i in range(n):
      sollya_lib_clear_obj(sollya_list[i])
    free(sollya_list)
    return sollya_op
  elif isinstance(op, str):
    return sollya_lib_string(PyString_AsString(op))
  else:
    raise TypeError("unsupported conversion to sollya object", op, op.__class__)

include "sollya_settings.pxi"
include "sollya_func.pxi"

# Global constants

binary16 = wrap(sollya_lib_halfprecision_obj())
binary32 = wrap(sollya_lib_single_obj())
binary64 = wrap(sollya_lib_double_obj())
binary80 = wrap(sollya_lib_doubleextended_obj())
binary128 = wrap(sollya_lib_quad_obj())
doubledouble = wrap(sollya_lib_double_double_obj())
tripledouble = wrap(sollya_lib_triple_double_obj())

RD       = wrap(sollya_lib_round_down())
RU       = wrap(sollya_lib_round_up())
RZ       = wrap(sollya_lib_round_towards_zero())
RN       = wrap(sollya_lib_round_to_nearest())

absolute = wrap(sollya_lib_absolute())
relative = wrap(sollya_lib_relative())
fixed    = wrap(sollya_lib_fixed())
floating = wrap(sollya_lib_floating())

on = wrap(sollya_lib_on())
off = wrap(sollya_lib_off())

binary      = wrap(sollya_lib_binary())
powers      = wrap(sollya_lib_powers())
hexadecimal = wrap(sollya_lib_hexadecimal())
dyadic      = wrap(sollya_lib_dyadic())
decimal     = wrap(sollya_lib_decimal())

pi          = wrap(sollya_lib_pi())
x           = wrap(sollya_lib_free_variable())
error       = wrap(sollya_lib_error())


def Interval(inf, sup = None):
  if sup is None:
    return sollya_range(inf, inf)
  else:
    return sollya_range(inf, sup)

def PSI_is_range(SollyaObject op):
  return sollya_lib_obj_is_range(op.value)

S2 = SollyaObject(2)

