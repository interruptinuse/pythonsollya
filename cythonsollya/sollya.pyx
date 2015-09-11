# file: sollya.pyx

from csollya cimport *
cimport libc.stdint
from cpython.int cimport PyInt_AsLong

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

  ## addition operator for sollya objects
  def __add__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_t sollya_op0 = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_t sollya_op1 = convertPythonTo_sollya_obj_t(op)
    result._c_sollya_obj = sollya_lib_add(sollya_op0, sollya_op1)
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

  def __str__(self):
    cdef char* result_str = NULL
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
  if isinstance(op, SollyaObject):
    sollya_op = (<SollyaObject>op)._c_sollya_obj
    return sollya_op
  elif isinstance(op, float):
    sollya_op = sollya_lib_constant_from_double(<double>op)
    return sollya_op
  elif isinstance(op, int):
    sollya_op = sollya_lib_constant_from_int64(PyInt_AsLong(op))
    return sollya_op
  else:
    print "conversion not supported to sollya object ", op, op.__class__
    raise Exception()


def exp(op):
  cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
  result._c_sollya_obj = sollya_lib_exp(convertPythonTo_sollya_obj_t(op))
  return result

def lib_init():
  sollya_lib_init()

