# file: sollya.pyx

from csollya cimport *
cimport libc.stdint
from cpython.int cimport PyInt_AsLong
from cpython.string cimport PyString_AsString
from libc.stdlib cimport malloc, free

## initialization of Sollya library
sollya_lib_init()

cdef class SollyaObject:
  cdef sollya_obj_t _c_sollya_obj

  def __cinit__(self):
    self._c_sollya_obj = NULL

  def __init__(self, op):
    self._c_sollya_obj = convertPythonTo_sollya_obj_t(op)

  def __dealloc__(self):
    if self._c_sollya_obj is not NULL:
      sollya_lib_clear_obj(self._c_sollya_obj)

  def myprint(self):
    sollya_lib_autoprint(self._c_sollya_obj)

  ## converting sollya object to python Integer
  def __int__(SollyaObject self):
    cdef int i 
    cdef int result[1]
    i = sollya_lib_get_constant_as_int(result, self._c_sollya_obj)
    return result[0]

  ## converting sollya object to python Float
  def __float__(SollyaObject self):
    cdef int i 
    cdef double result[1]
    i = sollya_lib_get_constant_as_double(result, self._c_sollya_obj)
    return result[0]

  ## Negate operator (-self) for sollya object
  def __neg__(self):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    result._c_sollya_obj = sollya_lib_neg(sollya_op0)
    return result

  ## Not operator (!self) for sollya object
  def __not__(self):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    result._c_sollya_obj = sollya_lib_negate(sollya_op0)
    return result

  ## addition operator for sollya objects
  def __add__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_t sollya_op1 = convertPythonTo_sollya_obj_t(op)
    cdef int list_length
    #if isinstance(self, list) and sollya_lib_obj_is_list(sollya_op1):
    #  list_length = sollya_lib_length(sollya_op2)
    #  result_list = self
    #  for i in range(list_length):
    #    result_list.append(op[i])
    #  return result_list
    #elif isinstance(op,   list) and sollya_lib_obj_is_list(sollya_op0):
    #else:
    result._c_sollya_obj = sollya_lib_add(sollya_op0, sollya_op1)
    return result

  def __getitem__(self, index):
    cdef sollya_obj_t sollya_result
    cdef sollya_obj_t sollya_op = convertPythonTo_sollya_obj_t(self)
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef int flag
    if isinstance(self, list):
      return self[int(index)]
    else:
      flag = sollya_lib_get_element_in_list(&sollya_result, sollya_op, PyInt_AsLong(int(index)))
      result._c_sollya_obj = sollya_result
      return result

  ## Subtraction operator for sollya objects
  def __sub__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_t sollya_op1 = convertPythonTo_sollya_obj_t(op)
    result._c_sollya_obj = sollya_lib_sub(sollya_op0, sollya_op1)
    return result

  ## Multiplication operator for sollya objects
  def __mul__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_t sollya_op1 = convertPythonTo_sollya_obj_t(op)
    result._c_sollya_obj = sollya_lib_mul(sollya_op0, sollya_op1)
    return result

  ## Division operator for sollya objects
  def __div__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_t sollya_op1 = convertPythonTo_sollya_obj_t(op)
    result._c_sollya_obj = sollya_lib_div(sollya_op0, sollya_op1)
    return result

  ## Power operator for sollya objects
  def __pow__(self, op, modulo):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_t sollya_op1 = convertPythonTo_sollya_obj_t(op)
    result._c_sollya_obj = sollya_lib_pow(sollya_op0, sollya_op1)
    return result

  def __repr__(SollyaObject self):
    cdef int n = sollya_lib_snprintf(NULL, 0, <char*>"%b", <sollya_obj_t>self._c_sollya_obj)
    cdef char* result_str
    if n > 0:
      result_str = <char*>malloc(n)
      sollya_lib_sprintf(result_str, <char*>"%b", <sollya_obj_t>self._c_sollya_obj)
    return result_str

  cdef sollya_obj_t extract_c_sollya_obj(self):
    cdef sollya_obj_t sollya_op_result
    sollya_op_result = self._c_sollya_obj
    return sollya_op_result

    

## 
# @brief convert a Python object to a sollya_obj_t
# @params op is Python object
# @return 
cdef sollya_obj_t convertPythonTo_sollya_obj_t(op):
  cdef sollya_obj_t sollya_op
  cdef sollya_obj_t* sollya_list
  cdef int n
  if isinstance(op, SollyaObject):
    sollya_op = (<SollyaObject>op)._c_sollya_obj
    return sollya_op
  elif isinstance(op, float):
    sollya_op = sollya_lib_constant_from_double(<double>op)
    return sollya_op
  elif isinstance(op, int):
    sollya_op = sollya_lib_constant_from_int64(PyInt_AsLong(op))
    return sollya_op
  elif isinstance(op, list):
    n = len(op) 
    sollya_list = <sollya_obj_t*>malloc(sizeof(sollya_obj_t) * n)
    for i in range(n):
      sollya_list[i] = convertPythonTo_sollya_obj_t(op[i])
    sollya_op = sollya_lib_list(sollya_list, n)
    return sollya_op
  elif isinstance(op, str):
    sollya_op = sollya_lib_string(PyString_AsString(op))
    return sollya_op
  else:
    print "conversion not supported to sollya object ", op, op.__class__
    return sollya_lib_error()

cdef SollyaObject convert_sollya_obj_t_to_PythonObject(sollya_obj_t sollya_op):
  cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
  result._c_sollya_obj = sollya_op
  return result

def Interval(inf, sup = None):
  if sup is None:
    return sollya_range(inf, inf)
  else:
    return sollya_range(inf, sup)

def lib_init():
  sollya_lib_init()

include "sollya_func.pxi"

lib_init()

binary32 = convert_sollya_obj_t_to_PythonObject(sollya_lib_single_obj())
binary64 = convert_sollya_obj_t_to_PythonObject(sollya_lib_double_obj())
binary80 = convert_sollya_obj_t_to_PythonObject(sollya_lib_doubleextended_obj())

absolute = convert_sollya_obj_t_to_PythonObject(sollya_lib_absolute())
relative = convert_sollya_obj_t_to_PythonObject(sollya_lib_relative())
fixed    = convert_sollya_obj_t_to_PythonObject(sollya_lib_fixed())
floating = convert_sollya_obj_t_to_PythonObject(sollya_lib_floating())
error    = convert_sollya_obj_t_to_PythonObject(sollya_lib_error())

RD       = convert_sollya_obj_t_to_PythonObject(sollya_lib_round_down())
RU       = convert_sollya_obj_t_to_PythonObject(sollya_lib_round_up())
RZ       = convert_sollya_obj_t_to_PythonObject(sollya_lib_round_towards_zero())
RN       = convert_sollya_obj_t_to_PythonObject(sollya_lib_round_to_nearest())

doubledouble = convert_sollya_obj_t_to_PythonObject(sollya_lib_double_double_obj())
tripledouble = convert_sollya_obj_t_to_PythonObject(sollya_lib_triple_double_obj())

pi = convert_sollya_obj_t_to_PythonObject(sollya_lib_pi())

on = convert_sollya_obj_t_to_PythonObject(sollya_lib_off())
off = convert_sollya_obj_t_to_PythonObject(sollya_lib_on())

binary      = convert_sollya_obj_t_to_PythonObject(sollya_lib_binary())
powers      = convert_sollya_obj_t_to_PythonObject(sollya_lib_powers())
hexadecimal = convert_sollya_obj_t_to_PythonObject(sollya_lib_hexadecimal())
dyadic      = convert_sollya_obj_t_to_PythonObject(sollya_lib_dyadic())
decimal     = convert_sollya_obj_t_to_PythonObject(sollya_lib_decimal())

x           = convert_sollya_obj_t_to_PythonObject(sollya_lib_free_variable())
error       = convert_sollya_obj_t_to_PythonObject(sollya_lib_error())



def PSI_is_range(SollyaObject op):
  return sollya_lib_obj_is_range(op._c_sollya_obj)

S2 = SollyaObject(2)

