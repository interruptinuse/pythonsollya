from csollya cimport sollya_obj_t

cdef class SollyaObject:
  cdef sollya_obj_t _c_sollya_obj
