# -*- coding: utf-8 -*- vim: sw=2

from csollya cimport *
cimport libc.stdint
from cpython.int cimport PyInt_AsLong
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from cpython.string cimport PyString_AsString
from libc.stdlib cimport malloc, free

## initialization of Sollya library
sollya_lib_init()

cdef int SOW_NULL  = 0
cdef int SOW_ALIAS = 1
cdef int SOW_CLEAN = 2

ctypedef struct sollya_obj_wrapper_t:
  sollya_obj_t value
  # 0 = CLEAN COPY
  # 1 = COPIED FROM ELSEWHERE
  int status

cdef class SollyaObject:

  def __cinit__(self):
    self.value = NULL

  def __init__(self, op):
    self.value = convertPythonTo_sollya_obj_t(op)

  def __dealloc__(self):
    if self.value is not NULL:
      sollya_lib_clear_obj(self.value)

  def myprint(self):
    sollya_lib_autoprint(self.value)

  ## converting sollya object to python Integer
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

  ## converting sollya object to python Float
  def __float__(SollyaObject self):
    cdef int i 
    cdef double result[1]
    i = sollya_lib_get_constant_as_double(result, self.value)
    return result[0]

  ## Negate operator (-self) for sollya object
  def __neg__(self):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self)
    result.value = sollya_lib_neg(sollya_op0.value)
    clear_clean_sollya_wrapper(sollya_op0)
    return result

  ## Not operator (!self) for sollya object
  def __not__(self):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self)
    result.value = sollya_lib_negate(sollya_op0.value)
    clear_clean_sollya_wrapper(sollya_op0)
    return result

  ## addition operator for sollya objects
  def __add__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 # = convertPythonTo_sollya_obj_t(self)
    cdef sollya_obj_wrapper_t sollya_op1 # = convertPythonTo_sollya_obj_t(op)
    cdef int list_length

    if isinstance(self, list) and isinstance(op, SollyaObject):
      return self + convertSollyaObject_to_PythonList(op)
    elif isinstance(self, SollyaObject) and isinstance(op, list):
      return convertSollyaObject_to_PythonList(self) + op
    else:
      sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self)
      sollya_op1 = convertPythonTo_sollya_obj_wrapper_t(op)
      result.value = sollya_lib_add(sollya_op0.value, sollya_op1.value)
      clear_clean_sollya_wrapper(sollya_op0)
      clear_clean_sollya_wrapper(sollya_op1)
      return result

  def __getitem__(self, index):
    if not sollya_lib_obj_is_list(self.value):
      raise ValueError("not a Sollya list")
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    if sollya_lib_get_element_in_list(&result.value, self.value, PyInt_AsLong(int(index))):
      return result
    else:
      raise IndexError("index out of range")

  ## Subtraction operator for sollya objects
  def __sub__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self)
    cdef sollya_obj_wrapper_t sollya_op1 = convertPythonTo_sollya_obj_wrapper_t(op)
    result.value = sollya_lib_sub(sollya_op0.value, sollya_op1.value)
    clear_clean_sollya_wrapper(sollya_op0)
    clear_clean_sollya_wrapper(sollya_op1)
    return result

  ## Multiplication operator for sollya objects
  def __mul__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 
    cdef sollya_obj_wrapper_t sollya_op1 
    cdef bint sollya_obj_is_list
    if isinstance(self, list):
      return self * int(op)
    elif isinstance(op, list):
      return int(self) * op
    elif isinstance(self, SollyaObject):
      sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self)
      sollya_obj_is_list = sollya_lib_obj_is_list(sollya_op0.value)
      if sollya_obj_is_list:
        clear_clean_sollya_wrapper(sollya_op0)
        return convertSollyaObject_to_PythonList(self) * int(op)
    elif isinstance(op, SollyaObject):
      sollya_op1 = convertPythonTo_sollya_obj_wrapper_t(op) 
      sollya_obj_is_list = sollya_lib_obj_is_list(sollya_op1.value)
      if sollya_obj_is_list:
        clear_clean_sollya_wrapper(sollya_op1)
        return int(self) * convertSollyaObject_to_PythonList(op) 
    # default case
    sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self) 
    sollya_op1 = convertPythonTo_sollya_obj_wrapper_t(op) 
    result.value = sollya_lib_mul(sollya_op0.value, sollya_op1.value)
    clear_clean_sollya_wrapper(sollya_op0)
    clear_clean_sollya_wrapper(sollya_op1)
    return result

  ## Division operator for sollya objects
  def __div__(self, op):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 
    cdef sollya_obj_wrapper_t sollya_op1 
    sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self) 
    sollya_op1 = convertPythonTo_sollya_obj_wrapper_t(op) 
    result.value = sollya_lib_div(sollya_op0.value, sollya_op1.value)

    clear_clean_sollya_wrapper(sollya_op0)
    clear_clean_sollya_wrapper(sollya_op1)
    return result

  ## Power operator for sollya objects
  def __pow__(self, op, modulo):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef sollya_obj_wrapper_t sollya_op0 
    cdef sollya_obj_wrapper_t sollya_op1 
    sollya_op0 = convertPythonTo_sollya_obj_wrapper_t(self) 
    sollya_op1 = convertPythonTo_sollya_obj_wrapper_t(op) 
    result.value = sollya_lib_pow(sollya_op0.value, sollya_op1.value)

    clear_clean_sollya_wrapper(sollya_op0)
    clear_clean_sollya_wrapper(sollya_op1)
    return result

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


  # Comparison operators
  def __richcmp__(self, other, int cmp_op):
    cdef sollya_obj_wrapper_t sollya_op0_wrapper = convertPythonTo_sollya_obj_wrapper_t(self)
    cdef sollya_obj_wrapper_t sollya_op1_wrapper = convertPythonTo_sollya_obj_wrapper_t(other)
    cdef sollya_obj_t sollya_op0 = sollya_op0_wrapper.value
    cdef sollya_obj_t sollya_op1 = sollya_op1_wrapper.value
    cdef sollya_obj_t result = NULL
    if cmp_op == Py_LT:
      result = sollya_lib_cmp_less(sollya_op0, sollya_op1)
    elif cmp_op == Py_EQ:
      result = sollya_lib_cmp_equal(sollya_op0, sollya_op1)
    elif cmp_op == Py_GT:
      result = sollya_lib_cmp_greater(sollya_op0, sollya_op1)
    elif cmp_op == Py_LE:
      result = sollya_lib_cmp_less_equal(sollya_op0, sollya_op1)
    elif cmp_op == Py_NE:
      result = sollya_lib_cmp_not_equal(sollya_op0, sollya_op1)
    elif cmp_op == Py_GE:
      result = sollya_lib_cmp_greater_equal(sollya_op0, sollya_op1)
    cdef bint bool_result = sollya_lib_is_true(result)

    clear_clean_sollya_wrapper(sollya_op0_wrapper)
    clear_clean_sollya_wrapper(sollya_op1_wrapper)
    sollya_lib_clear_obj(result)

    return bool_result

# test if a sollya_obj_wrapper_t contains a clean copied (not aliased 
# or referenced elsewhere), if it is the case, clears it
cdef void clear_clean_sollya_wrapper(sollya_obj_wrapper_t sollya_obj):
  if sollya_obj.status == SOW_CLEAN:
    sollya_lib_clear_obj(sollya_obj.value)
    sollya_obj.status = SOW_NULL

## 
# @brief convert a Python object to a sollya_obj_t
# @params op is Python object
# @return 
cdef sollya_obj_t convertPythonTo_sollya_obj_t(op):
  cdef sollya_obj_t sollya_op
  cdef sollya_obj_t* sollya_list
  cdef int n
  if isinstance(op, SollyaObject):
    sollya_op = sollya_lib_copy_obj((<SollyaObject>op).value)
    if sollya_op is NULL:
      print "sollya_op is NULL in convertPythonTo_sollya_obj_t"
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
    for i in range(n):
      sollya_lib_clear_obj(sollya_list[i])
    free(sollya_list)
    return sollya_op
  elif isinstance(op, str):
    sollya_op = sollya_lib_string(PyString_AsString(op))
    return sollya_op
  else:
    print "conversion not supported to sollya object ", op, op.__class__
    return sollya_lib_error()

cdef sollya_obj_wrapper_t convertPythonTo_sollya_obj_wrapper_t(op):
  cdef sollya_obj_wrapper_t sollya_wrapper, sollya_wrapper_tmp
  cdef sollya_obj_t* sollya_list
  cdef int* sollya_list_elt_status
  cdef int n
  if isinstance(op, SollyaObject):
    sollya_wrapper.value = (<SollyaObject>op).value
    sollya_wrapper.status = SOW_ALIAS 
    if sollya_wrapper.value is NULL:
      print "sollya_op is NULL in convertPythonTo_sollya_obj_wrapper_t"
    return sollya_wrapper
  elif isinstance(op, float):
    sollya_wrapper.value = sollya_lib_constant_from_double(<double>op)
    sollya_wrapper.status = SOW_CLEAN
    return sollya_wrapper
  elif isinstance(op, int):
    sollya_wrapper.value = sollya_lib_constant_from_int64(PyInt_AsLong(op))
    sollya_wrapper.status = SOW_CLEAN
    return sollya_wrapper
  elif isinstance(op, list):
    n = len(op) 
    sollya_list = <sollya_obj_t*>malloc(sizeof(sollya_obj_t) * n)
    sollya_list_elt_status = <int*>malloc(sizeof(int) * n)
    for i in range(n):
      sollya_wrapper_tmp = convertPythonTo_sollya_obj_wrapper_t(op[i])
      sollya_list[i] = sollya_wrapper_tmp.value
      sollya_list_elt_status[i] = sollya_wrapper_tmp.status
    sollya_wrapper.value = sollya_lib_list(sollya_list, n)
    sollya_wrapper.status = SOW_CLEAN
    for i in range(n):
      if sollya_list_elt_status[i] == SOW_CLEAN:
        sollya_lib_clear_obj(sollya_list[i])
    free(sollya_list)
    return sollya_wrapper
  elif isinstance(op, str):
    sollya_wrapper.value = sollya_lib_string(PyString_AsString(op))
    sollya_wrapper.status = SOW_CLEAN
    return sollya_wrapper
  else:
    print "conversion not supported to sollya object ", op, op.__class__
    sollya_wrapper.value = sollya_lib_error()
    sollya_wrapper.status = SOW_CLEAN
    return sollya_wrapper


## convert a sollya_obj_t to a PythonList
#  @param op is a  sollya_obj_t pointing towards a sollya_list_t objt
#  @return a python list containing the same elt as <op> in the same order
cdef convert_sollya_obj_t_to_PythonList(sollya_obj_t sollya_op):
  cdef int sollya_list_length 
  cdef sollya_obj_t sollya_list_elt
  cdef bint extract_valid
  cdef sollya_obj_t SO_list_length


  # TODO add check on (op is list)
  SO_list_length = sollya_lib_length(sollya_op)
  extract_valid = sollya_lib_get_constant_as_int(&sollya_list_length, SO_list_length)
  sollya_lib_clear_obj(SO_list_length)

  result_list = []
  for i in range(sollya_list_length):
    extract_valid = sollya_lib_get_element_in_list(&sollya_list_elt, sollya_op, i)
    if not extract_valid:
      print "Error in list element extraction"
      raise Exception()
    result_list.append(convert_sollya_obj_t_to_PythonObject_no_copy(sollya_list_elt))
  return result_list


## convert a SollyaObject wrapping a sollya_list_t
#  to a Python list
#  @param op is a SollyaObject whose value field is a sollya list
#  @return a python list containing the same elt as <op> in the same order
def convertSollyaObject_to_PythonList(SollyaObject op):
  cdef sollya_obj_t sollya_op 
  cdef int sollya_list_length 
  cdef sollya_obj_t sollya_list_elt
  cdef bint extract_valid

  # TODO add check on (op is list)
  sollya_op = op.value
  extract_valid = sollya_lib_get_constant_as_int(&sollya_list_length, sollya_lib_length(sollya_op))

  return convert_sollya_obj_t_to_PythonList(sollya_op)


cdef SollyaObject convert_sollya_obj_t_to_PythonObject_no_copy(sollya_obj_t sollya_op):
  cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
  result.value = sollya_op
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

binary32 = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_single_obj())
binary64 = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_double_obj())
binary80 = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_doubleextended_obj())

absolute = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_absolute())
relative = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_relative())
fixed    = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_fixed())
floating = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_floating())
error    = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_error())

RD       = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_round_down())
RU       = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_round_up())
RZ       = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_round_towards_zero())
RN       = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_round_to_nearest())

doubledouble = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_double_double_obj())
tripledouble = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_triple_double_obj())

pi = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_pi())

on = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_off())
off = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_on())

binary      = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_binary())
powers      = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_powers())
hexadecimal = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_hexadecimal())
dyadic      = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_dyadic())
decimal     = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_decimal())

x           = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_free_variable())
error       = convert_sollya_obj_t_to_PythonObject_no_copy(sollya_lib_error())



def PSI_is_range(SollyaObject op):
  return sollya_lib_obj_is_range(op.value)

S2 = SollyaObject(2)

