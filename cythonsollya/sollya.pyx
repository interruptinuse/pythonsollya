# -*- coding: utf-8 -*- vim: sw=2

from csollya cimport *
cimport libc.stdint
from cpython.int cimport PyInt_AsLong
from cpython.long cimport PyLong_AsLong
from cpython.object cimport Py_LT, Py_LE, Py_EQ, Py_NE, Py_GT, Py_GE
from cpython.ref cimport Py_INCREF, Py_DECREF
from cpython.string cimport PyString_AsString, PyString_FromString
from libc.stdlib cimport malloc, free

IF HAVE_SAGE:
  from sage.libs.mpfi cimport mpfi_set
  from sage.libs.mpfr cimport mpfr_rnd_t, mpfr_get_prec
  from sage.libs.mpfr cimport MPFR_RNDN, MPFR_RNDZ, MPFR_RNDU, MPFR_RNDD
  from sage.rings.integer cimport Integer
  from sage.rings.rational cimport Rational
  from sage.rings.real_mpfi cimport (
      RealIntervalField_class,
      RealIntervalFieldElement)
  from sage.rings.real_mpfr cimport RealNumber, RealField_class

import __builtin__, atexit, collections, inspect, itertools
import sys, traceback, types, warnings

IF HAVE_SAGE:
  from sage.rings.real_mpfi import RealIntervalField


# Initialization of Sollya library
sollya_lib_init_with_custom_memory_function_modifiers(NULL, NULL)
atexit.register(lambda: sollya_lib_close())
sollya_lib_install_msg_callback(__msg_callback, NULL)

def has_sage_support():
  return HAVE_SAGE

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

# WARNING: We rely pretty extensively on the lifetime of temporary
# SollyaObjects extending at least up to the next call to Python (e.g. in
# c_function(as_SollyaObject(foo).value)), and perhaps also on SollyaObjects
# stored in local variables not being deallocated before the function returns.
# I'm not sure how much of this really is guaranteed by [PC]ython.

cdef class SollyaObject:

  def __cinit__(self):
    self.value = NULL

  def __init__(self, op):
    self.value = to_sollya_obj_t(op)

  def __dealloc__(self):
    if self.value is not NULL:
      sollya_lib_clear_obj(self.value)

  def __hash__(self):
    return sollya_lib_hash(self.value)

  def __repr__(SollyaObject self):
    r"""
    Return the string representation of this Sollya object.

    NOTES:
    - The resulting string s is valid Sollya input; use sollya.parse(s + ';')
      to evaluate it.
    - Sollya expressions ("functions") such as sin(1) are not evaluated: e.g.,
      repr(sin(1)) returns "sin(1)", not "0.8414...". In interactive usage, set
      Python's sys.displayhook to sollya.autoprint in order for Sollya objects
      returned by the evaluation of a command line to be displayed in evaluated
      form, similar to what interactive Sollya does.
    """
    cdef int n = sollya_lib_snprintf(NULL, 0, <char*>"%b", <sollya_obj_t>self.value)
    cdef sollya_obj_t sollya_op = self.value
    cdef char* result_str
    if n > 0:
      result_str = <char*>malloc(n+1)
      sollya_lib_snprintf(result_str, n+1, <char*>"%b", <sollya_obj_t>self.value)
      return result_str
    else:
      return ""

  def __call__(self, *args):
    cdef sollya_obj_t res
    if (sollya_lib_obj_is_procedure(self.value) or
        sollya_lib_obj_is_externalprocedure(self.value)):
      res = sollya_lib_concat(self.value, as_SollyaObject(args).value)
      return wrap(res)
    elif len(args) == 1:
      res = sollya_lib_apply(self.value, as_SollyaObject(args[0]).value, NULL)
      foo = wrap(res)
      return foo
    else:
      raise TypeError("expected exactly one argument")

  # Typechecking

  def is_function(self):
    return sollya_lib_obj_is_function(self.value)

  def is_list(self):
    return sollya_lib_obj_is_list(self.value)

  def is_end_elliptic_list(self):
    return sollya_lib_obj_is_end_elliptic_list(self.value)

  def is_range(self):
    return sollya_lib_obj_is_range(self.value)

  def is_string(self):
    return sollya_lib_obj_is_string(self.value)

  def is_error(self):
    return sollya_lib_obj_is_error(self.value)

  def is_structure(self):
    return sollya_lib_obj_is_structure(self.value)

  def is_procedure(self):
    return sollya_lib_obj_is_procedure(self.value)

  def is_externalprocedure(self):
    return sollya_lib_obj_is_externalprocedure(self.value)

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
    r"""
    Interpret this Sollya object as a Python integer.

    Warning: quadratic complexity.
    """
    cdef uint64_t *value
    cdef int sign
    cdef size_t len
    if sollya_lib_get_constant_as_uint64_array(&sign, &value, &len, self.value):
      res = 0
      for i in range(len):
        res = (res << 64) + value[len-1-i]
      sollya_lib_free(value)
      res *= cmp(sign, 0)
      # Attempt to return a Python int (instead of a long) when possible
      try:
        return PyLong_AsLong(res)
      except OverflowError:
        return res
    else:
      raise ValueError("no conversion of this Sollya object to int")

  def getConstantAsInt(SollyaObject self):
    return int(self)

  def getConstantAsIntLegacy(SollyaObject self):
    cdef int64_t result
    if sollya_lib_get_constant_as_int64(&result, self.value):
      return result
    else:
      raise ValueError("no conversion of this Sollya object to int")

  def getConstantAsUInt(SollyaObject self):
    cdef int i 
    cdef uint64_t result[1]
    i = sollya_lib_get_constant_as_uint64(result, self.value)
    return result[0]

  def __float__(SollyaObject self):
    cdef int i
    cdef double result[1]
    i = sollya_lib_get_constant_as_double(result, self.value)
    # XXX: handle errors
    return result[0]

  IF HAVE_SAGE:

    def _integer_(self, parent=None):
      cdef Integer result = <Integer> Integer.__new__(Integer)
      if sollya_lib_get_constant_as_mpz(result.value, self.value):
        return result
      else:
        raise ValueError("unable to convert this Sollya object "
            "to a Sage integer")

    def _rational_(self, parent=None):
      cdef Rational result = <Rational> Rational.__new__(Rational)
      if sollya_lib_get_constant_as_mpq(result.value, self.value):
        return result
      else:
        raise ValueError("unable to convert this Sollya object "
            "to a Sage rational")

    def _real_mpfi_(self, RealIntervalField_class parent):
      cdef double dummy[1]
      cdef RealIntervalFieldElement result = parent._new()
      if sollya_lib_get_interval_from_range(result.value, self.value):
        return result
      elif sollya_lib_get_constant_as_double(dummy, self.value):
        # self looks like a constant expression
        if sollya_lib_evaluate_function_over_interval(result.value, self.value,
            result.value):
          return result
      else:
        raise ValueError("unable to convert this Sollya object "
            "to a Sage real interval")

    def _mpfr_(self, RealField_class parent):
      cdef sollya_obj_t prec, rounded
      cdef RealNumber result = parent._new()
      cdef sollya_obj_t rnd = __rounding_mode(parent.rnd) # global, do not free
      try:
        prec = sollya_lib_constant_from_int64(mpfr_get_prec(result.value))
        rounded = sollya_lib_round(self.value, prec, rnd)
        if sollya_lib_get_constant(result.value, rounded):
          return result
        else:
          raise ValueError("unable to convert this Sollya object "
              "to a Sage floating-point number")
      finally:
        sollya_lib_clear_obj(rounded)
        sollya_lib_clear_obj(prec)

  # Destructuring

  def arity(self):
    r"""
    Return the arity of a Sollya function (expression).

    WARNING: In some cases (e.g., library functions), self.operand() accepts
    arguments >= self.arity(), and the corresponding "operand" is necessary to
    reconstruct the function from its operator() and operands(). See the Sollya
    manual for details.
    """
    cdef int res
    if sollya_lib_get_function_arity(&res, self.value):
      return res
    else:
      raise ValueError("this Sollya object doesn't have operands")

  def operator(self):
    cdef SollyaOperator res = SollyaOperator.__new__(SollyaOperator)
    if sollya_lib_get_head_function(&res.value, self.value):
      return res
    else:
      raise ValueError("this Sollya object doesn't have operands")

  def operand(self, n):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    if not sollya_lib_get_nth_subfunction(&result.value, self.value, n + 1):
      raise IndexError("operand index out of range or object without operands")
    return result

  def operands(self, extended=True):
    arity = self.arity()
    ops = [self.operand(n) for n in range(arity)]
    if extended: # include the additional pseudo-operand that some objs provide
      try:
        ops.append(self.operand(arity))
      except IndexError:
        pass
    return ops

  # Access to fields

  property struct:
    def __get__(self):
      return SollyaStructureWrapper(self)

  # Container methods

  def __len__(self):
    cdef sollya_obj_t sollya_len
    cdef int64_t int_len = -1
    cdef char **names = NULL
    cdef sollya_obj_t *objs = NULL
    cdef int struct_len = -1
    if sollya_lib_obj_is_structure(self.value):
      sollya_lib_get_structure_elements(&names, &objs, &struct_len, self.value)
      for i in range(struct_len):
        sollya_lib_clear_obj(objs[i])
        sollya_lib_free(names[i])
      sollya_lib_free(objs)
      sollya_lib_free(names)
      return struct_len
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
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    if (sollya_lib_obj_is_list(self.value)
        or sollya_lib_obj_is_end_elliptic_list(self.value)):
      result = SollyaObject.__new__(SollyaObject)
      if sollya_lib_get_element_in_list(&result.value, self.value,
                                        PyInt_AsLong(int(index))):
        return result
      else:
        raise IndexError("index out of range")
    else:
      raise ValueError("not a Sollya list")

  def __contains__(self, elt):
    res = sollya_lib_cmp_in(as_SollyaObject(elt).value, self.value)
    return sollya_lib_is_true(res)

  def list(self):
    cdef char **names = NULL
    cdef sollya_obj_t *objs = NULL
    cdef int length = 0
    cdef int is_end_elliptic
    cdef SollyaObject val
    if (sollya_lib_obj_is_list(self.value)
        or sollya_lib_obj_is_end_elliptic_list(self.value)):
      if not sollya_lib_get_list_elements(&objs, &length, &is_end_elliptic,
                                          self.value):
        raise RuntimeError("conversion of Sollya list failed")
      py_objs = [wrap(objs[i]) for i in range(length)]
      sollya_lib_free(objs)
      if is_end_elliptic:
        py_objs.append(Ellipsis)
      return py_objs
    elif sollya_lib_obj_is_structure(self.value):
      # Should we return the list of keys rather than the list of pairs (as
      # Python mappings are supposed to do) even though we don't support access
      # by struct["key"]?
      if not sollya_lib_get_structure_elements(&names, &objs, &length,
                                               self.value):
        raise RuntimeError("conversion of Sollya structure failed")
      pairs = [(PyString_FromString(names[i]), wrap(objs[i]))
               for i in range(length)]
      for i in range(length):
        sollya_lib_free(names[i])
      sollya_lib_free(objs)
      sollya_lib_free(names)
      return pairs
    else:
      raise ValueError("not iterable")

  def __iter__(self):
    cdef bint is_end_elliptic = sollya_lib_obj_is_end_elliptic_list(self.value)
    # wrap all elements first to avoid leaking memory if interrupted
    items = self.list()
    if is_end_elliptic:
      last = items.pop(-1)
      assert last is Ellipsis
    for item in items:
      yield item
    if is_end_elliptic: # may be slow if the initial part is long
      for i in itertools.count(len(items)):
        yield self[i]

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
      if (sollya_lib_obj_is_list(op0.value)
        and (sollya_lib_obj_is_list(op1.value)
          or sollya_lib_obj_is_end_elliptic_list(op1.value))):
        result.value = sollya_lib_concat(op0.value, op1.value)
      else:
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

  def __abs__(self):
    cdef SollyaObject result = SollyaObject.__new__(SollyaObject)
    cdef SollyaObject op0 = as_SollyaObject(self)
    result.value = sollya_lib_abs(op0.value)
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

cdef sollya_obj_t to_sollya_obj_t(op) except NULL:
  cdef sollya_obj_t sollya_obj, old_sollya_obj
  cdef sollya_obj_t* sollya_list
  cdef int n
  # order matters!
  if isinstance(op, SollyaObject):
    return sollya_lib_copy_obj((<SollyaObject>op).value)
  elif hasattr(op, '_sollya_'):
    return sollya_lib_copy_obj((<SollyaObject>(op._sollya_())).value)
  elif isinstance(op, float):
    return sollya_lib_constant_from_double(<double>op)
  elif isinstance(op, bool):
    return sollya_lib_true() if op else sollya_lib_false()
  elif isinstance(op, int):
    return sollya_lib_constant_from_int64(PyInt_AsLong(op))
  elif isinstance(op, long):
    return pylong_to_sollya_obj_t(op)
  elif op is None:
    return sollya_lib_void()
  elif isinstance(op, basestring):
    # Sollya strings are byte arrays, with no associated encoding. Can/should
    # we do better than the following for some types of Python strings?
    return sollya_lib_string(PyString_AsString(op))
  elif isinstance(op, collections.Sequence):
    n = len(op)
    if n > 0 and op[-1] is Ellipsis:
      n -= 1
      end_elliptic = True
    else:
      end_elliptic = False
    sollya_list = <sollya_obj_t*>malloc(sizeof(sollya_obj_t) * n)
    for i in range(n):
      sollya_list[i] = to_sollya_obj_t(op[i])
    if end_elliptic:
      sollya_obj = sollya_lib_end_elliptic_list(sollya_list, n)
    else:
      sollya_obj = sollya_lib_list(sollya_list, n)
    for i in range(n):
      sollya_lib_clear_obj(sollya_list[i])
    free(sollya_list)
    return sollya_obj
  elif isinstance(op, collections.Mapping):
    if not op:
      raise ValueError("empty structures are not supported by Sollya")
    sollya_obj = NULL
    for name in op.keys():
      old_sollya_obj = sollya_obj
      if not sollya_lib_create_structure(&sollya_obj, sollya_obj,
          PyString_AsString(name), as_SollyaObject(op[name]).value):
        raise RuntimeError("creation of Sollya structure failed")
      sollya_lib_clear_obj(old_sollya_obj)
    return sollya_obj
  elif isinstance(op, types.FunctionType):
    return function_to_sollya_obj_t(op)
  IF HAVE_SAGE:
    if isinstance(op, Integer):
      return sollya_lib_constant_from_mpz((<Integer> op).value)
    elif isinstance(op, Rational):
      return sollya_lib_constant_from_mpq((<Rational> op).value)
    elif isinstance(op, RealIntervalFieldElement):
      return sollya_lib_range_from_interval(
          (<RealIntervalFieldElement> op).value)
    elif isinstance(op, RealNumber):
      return sollya_lib_constant((<RealNumber> op).value)
  raise TypeError("unsupported conversion to sollya object", op, op.__class__)

# Warning: quadratic complexity! (Alt options: use the undocumented format of
# Python longs, go through a base 16 or 32 string representation.)
cdef sollya_obj_t pylong_to_sollya_obj_t(op):
  if ((-(1 << 30)) < op) and (op < (1 << 30)):
    return sollya_lib_constant_from_int64(PyInt_AsLong(op))
  sollya_obj = sollya_lib_constant_from_int64(PyInt_AsLong(0))
  if op >= 0:
    r = op
    s = 1
  else:
    r = -op
    s = -1
  w = 0
  while r != 0:
    t = r >> 30
    c = r - (t << 30)
    sollya_obj = sollya_lib_build_function_add(sollya_obj,
                    sollya_lib_build_function_mul(
                      sollya_lib_build_function_pow(
                        sollya_lib_constant_from_int64(PyInt_AsLong(2)),
                        sollya_lib_build_function_mul(
                          sollya_lib_constant_from_int64(PyInt_AsLong(30)),
                          sollya_lib_constant_from_int64(PyInt_AsLong(w)))),
                      sollya_lib_constant_from_int64(PyInt_AsLong(c))))
    w = w + 1
    r = t
  if s < 0:
    sollya_obj = sollya_lib_build_function_neg(sollya_obj)
  return sollya_lib_simplify(sollya_obj)

include "sollya_settings.pxi"
include "sollya_func.pxi"

# Commands and built-in procedures requiring special handling

def printxml(expr, file=None, append=None):
  if file is None:
    if append is None:
      sollya_lib_printxml(as_SollyaObject(expr).value)
    else:
      sollya_lib_printxml_appendfile(
          as_SollyaObject(expr).value,
          as_SollyaObject(append).value)
  else:
    if append is None:
      sollya_lib_printxml_appendfile(
          as_SollyaObject(expr).value,
          as_SollyaObject(file).value)
    else:
      raise TypeError("incompatible keyword arguments: 'file' and 'append'")

def plot(*args):
  if len(args) < 2:
    raise TypeError("plot() expects at least two arguments")
  if args[-2] in [file, postscript, postscriptfile]:
    funs = args[:-3]
    range, output, filename = args[-3:]
    sollya_lib_plot(
        as_SollyaObject(funs).value, as_SollyaObject(range).value,
        as_SollyaObject(output).value, as_SollyaObject(filename).value, NULL)
  else:
    funs, range = args[:-1], args[-1]
    sollya_lib_plot(
        as_SollyaObject(funs).value, as_SollyaObject(range).value, NULL)

__displayhook = sys.displayhook
def autoprint(obj):
  r"""
  Evaluate and print Sollya objects like the interactive Sollya interpreter
  does, print other Python objects as usual. This is intended to be usable as a
  Python display hook (see sys.displayhook).
  """
  if isinstance(obj, SollyaObject):
    sollya_lib_autoprint((<SollyaObject> obj).value, NULL)
    __builtin__._ = obj
  else:
    __displayhook(obj)

def libraryconstant(arg):
  if isinstance(arg, types.FunctionType):
    Py_INCREF(arg)
    return wrap(
        sollya_lib_libraryconstant_with_data(
          arg.__name__,
          __libraryconstant_callback,
          <void *> arg,
          __dealloc_callback))
  else:
    raise NotImplementedError

def function(arg):
  cdef sollya_obj_t sobj
  if isinstance(arg, types.FunctionType):
    Py_INCREF(arg)
    sobj = sollya_lib_libraryfunction_with_data(
          (<SollyaObject> _x_).value,
          arg.__name__,
          __libraryfunction_callback,
          <void *> arg,
          __dealloc_callback)
  else:
    sobj = sollya_lib_procedurefunction(
        (<SollyaObject> _x_).value,
        as_SollyaObject(arg).value)
  return wrap(sobj)

IF HAVE_SAGE:
  def sagefunction(arg):
    r"""
    Similar to Sollya's function(), but the user-defined function receives a
    real interval and must return something convertible to a real interval (of
    the given precision).
    """
    cdef sollya_obj_t sobj
    Py_INCREF(arg)
    sobj = sollya_lib_libraryfunction_with_data(
          (<SollyaObject> _x_).value,
          str(arg),
          __sage_libraryfunction_callback,
          <void *> arg,
          __dealloc_callback)
    return wrap(sobj)

# Sollya operators (aka base functions)

include "sollya_ops.pxi"

cdef class SollyaOperator:

  def __init__(self, name):
    # make it possible to convert things like operator.add someday?
    name = name.upper()
    vals = [k for (k, v) in __operator_names.iteritems() if v == name]
    try:
      self.value = vals[0]
    except IndexError:
      raise ValueError("unknown Sollya operator")

  def __repr__(self):
    return __operator_names[self.value]

  def __richcmp__(SollyaOperator self, SollyaOperator other, cmp_op):
    if cmp_op == Py_EQ:
      return self.value == other.value
    elif cmp_op == Py_NE:
      return self.value != other.value
    else:
      raise TypeError("Sollya operators are not ordered")

  def __call__(self, *args):
    cdef sollya_obj_t[4] padded
    cdef SollyaObject tmp
    n = len(args)
    if n > 4:
      raise NotImplementedError
    my_args = tuple(as_SollyaObject(arg) for arg in args)
    for i in range(n):
      Py_INCREF(my_args[i]) # probably not necessary
      padded[i] = (<SollyaObject> my_args[i]).value
    for i in range(n, 4):
      padded[i] = NULL
    cdef SollyaObject res = SollyaObject.__new__(SollyaObject)
    try:
      # variadic, but all operators actually have arity <= 2
      if not sollya_lib_construct_function(&res.value, self.value,
          padded[0], padded[1], padded[2], padded[3], NULL):
        raise ValueError("invalid number of operands for " + str(self))
    finally:
      for i in range(n):
        Py_DECREF(my_args[i])
    return res

# Access to fields of Sollya structures

cdef class SollyaStructureWrapper:

  def __init__(self, SollyaObject obj):
    if not sollya_lib_obj_is_structure(obj.value):
      raise ValueError("expected a Sollya structure")
    self.obj = obj

  def __getattribute__(self, name):
    cdef SollyaObject res = SollyaObject.__new__(SollyaObject)
    if not sollya_lib_get_element_in_structure(&res.value, PyString_AsString(name),
        self.obj.value):
      raise AttributeError(name) # ?
    else:
      return res

  def __setattr__(self, name, val):
    cdef sollya_obj_t old_struct = self.obj.value
    if not sollya_lib_create_structure(&self.obj.value, self.obj.value,
        PyString_AsString(name), as_SollyaObject(val).value):
      raise RuntimeError("update of Sollya srstructure failed")
    sollya_lib_clear_obj(old_struct)

# Calling Python functions from Sollya

cdef sollya_obj_t function_to_sollya_obj_t(fun) except NULL:
  cdef void *callback = <void *> __externalproc_callback
  arity = fun.__code__.co_argcount
  if arity == 0:
    callback = <void *> __externalproc_callback_no_args
  cdef size_t size = arity*sizeof(sollya_externalprocedure_type_t)
  cdef sollya_externalprocedure_type_t *sollya_argspec = (
    <sollya_externalprocedure_type_t *>malloc(size))
  for i in range(arity):
    sollya_argspec[i] = SOLLYA_EXTERNALPROC_TYPE_OBJECT
  Py_INCREF(fun)
  cdef sollya_obj_t sollya_obj = sollya_lib_externalprocedure_with_data(
      SOLLYA_EXTERNALPROC_TYPE_OBJECT, sollya_argspec, arity,
      fun.__name__, callback, <void *>fun,
      __dealloc_callback)
  free(sollya_argspec)
  return sollya_obj

cdef bint __externalproc_callback(sollya_obj_t *c_res,
                                  void **c_args, void *c_fun):
  try:
    fun = <object> c_fun
    args = [wrap(sollya_lib_copy_obj(<sollya_obj_t>(c_args[i])))
            for i in range(fun.__code__.co_argcount)]
    res0 = fun(*args)
    res = as_SollyaObject(res0)
    c_res[0] = sollya_lib_copy_obj(res.value)
    return True
  except:
    traceback.print_exc() # TBI?
    return False

# sollya requires a different prototype to call external procedures that don't
# take any argument
cdef bint __externalproc_callback_no_args(sollya_obj_t *c_res, void *c_fun):
  return __externalproc_callback(c_res, NULL, c_fun)

cdef void __libraryconstant_callback(mpfr_t res, mp_prec_t c_prec,
                                     void *c_fun):
  cdef mp_prec_t res_prec = 0
  try:
    fun = <object> c_fun
    res0 = fun(c_prec)
    res1 = as_SollyaObject(res0)
    if not sollya_lib_get_prec_of_constant(&res_prec, res1.value):
      # XXX: a warning might be enough
      raise RuntimeError("the value {} returned by {} does not appear to be "
          "exactly representable in floating-point".format(res1, fun))
    mpfr_set_prec(res, res_prec)
    sollya_lib_get_constant(res, res1.value)
  except:
    traceback.print_exc() # TBI?

cdef int __libraryfunction_callback(mpfi_t c_res, mpfi_t c_arg,
                                     int diff_order, void *c_fun):
  try:
    fun = <object> c_fun
    arg = wrap(sollya_lib_range_from_interval(c_arg))
    prec = mpfi_get_prec(c_res)
    res0 = fun(arg, diff_order, prec)
    res1 = as_SollyaObject(res0)
    if not sollya_lib_get_interval_from_range(c_res, res1.value):
      return 0 # "currently has no meaning"
    return 1
  except Exception:
    traceback.print_exc() # TBI?
    return 0

IF HAVE_SAGE:
  cdef int __sage_libraryfunction_callback(mpfi_t c_res, mpfi_t c_arg,
                                           int diff_order, void *c_fun):
    cdef RealIntervalField_class IntervalField
    cdef RealIntervalFieldElement arg, res
    try:
      fun = <object> c_fun
      prec = mpfi_get_prec(c_res)
      IntervalField = RealIntervalField(prec)
      arg = IntervalField._new()
      mpfi_set(arg.value, c_arg)
      res0 = fun(arg, diff_order, prec)
      res = IntervalField(res0)
      mpfi_set(c_res, res.value)
      return 1
    except Exception:
      traceback.print_exc() # TBI?
      return 0

cdef void __dealloc_callback(void *c_fun):
  fun = <object> c_fun
  Py_DECREF(fun)

_print_backtraces = False

cdef int __msg_callback(sollya_msg_t msg, void *data):
    sys.stderr.write(sollya_lib_msg_to_text(msg) + "\n")
    # Quick hack to help debugging python codes that use cythonsollya
    if _print_backtraces:
      traceback.print_stack(None, None, sys.stderr)
    return 0

# Global constants

on = wrap(sollya_lib_on())
off = wrap(sollya_lib_off())

dyadic      = wrap(sollya_lib_dyadic())
powers      = wrap(sollya_lib_powers())
binary      = wrap(sollya_lib_binary())
hexadecimal = wrap(sollya_lib_hexadecimal())
decimal     = wrap(sollya_lib_decimal())

file = wrap(sollya_lib_file())
postscript = wrap(sollya_lib_postscript())
postscriptfile = wrap(sollya_lib_postscriptfile())

perturb = wrap(sollya_lib_perturb())

RD       = wrap(sollya_lib_round_down())
RU       = wrap(sollya_lib_round_up())
RZ       = wrap(sollya_lib_round_towards_zero())
RN       = wrap(sollya_lib_round_to_nearest())

# omitted: true, false (use, e.g., SollyaObject(True), bool(obj)), void (use
# SollyaObject(None))

default = wrap(sollya_lib_default())

# moved up: decimal
absolute = wrap(sollya_lib_absolute())
relative = wrap(sollya_lib_relative())
fixed    = wrap(sollya_lib_fixed())
floating = wrap(sollya_lib_floating())

error       = wrap(sollya_lib_error())

binary16 = wrap(sollya_lib_halfprecision_obj())
binary32 = wrap(sollya_lib_single_obj())
binary64 = wrap(sollya_lib_double_obj())
binary80 = wrap(sollya_lib_doubleextended_obj())
binary128 = wrap(sollya_lib_quad_obj())
doubledouble = wrap(sollya_lib_double_double_obj())
tripledouble = wrap(sollya_lib_triple_double_obj())

pi          = wrap(sollya_lib_pi())
x = _x_     = wrap(sollya_lib_free_variable())

# MPFR -> Sollya rounding modes

IF HAVE_SAGE:
  cdef sollya_obj_t __sollya_rndn = sollya_lib_round_to_nearest()
  cdef sollya_obj_t __sollya_rndz = sollya_lib_round_towards_zero()
  cdef sollya_obj_t __sollya_rndd = sollya_lib_round_down()
  cdef sollya_obj_t __sollya_rndu = sollya_lib_round_up()
  cdef sollya_obj_t __rounding_mode(mpfr_rnd_t rnd):
    if rnd == MPFR_RNDN:
      return __sollya_rndn
    elif rnd == MPFR_RNDZ:
      return __sollya_rndz
    elif rnd == MPFR_RNDD:
      return __sollya_rndd
    elif rnd == MPFR_RNDU:
      return __sollya_rndu
    else:
      raise ValueError("unsupported rounding mode")

# Additional utilities

def Interval(left, right=None):
  if right is None:
    right = left
  return wrap(sollya_lib_range(
    as_SollyaObject(left).value,
    as_SollyaObject(right).value))

S2 = SollyaObject(2)

