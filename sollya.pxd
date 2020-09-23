# -*- coding: utf-8 -*- vim:sw=2
# cython: language_level=3

from csollya cimport sollya_obj_t
from csollya_ops cimport sollya_base_function_t

cdef class SollyaObject:
  cdef sollya_obj_t value

cdef class SollyaOperator:
  cdef sollya_base_function_t value

cdef class SollyaStructureWrapper:
  cdef SollyaObject obj
