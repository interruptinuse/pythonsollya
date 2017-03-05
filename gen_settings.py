# -*- coding: utf-8 -*- vim:sw=2

CYTHONSOLLYA_VERSION = "\"0.1b\""

sollya_settings = [
  "prec",
  "points",
  "diam",
  "display",
  "verbosity",
  "canonical",
  "autosimplify",
  "fullparentheses",
  "showmessagenumbers",
  "taylorrecursions",
  "timing",
  "midpointmode",
  "dieonerrormode",
  "rationalmode",
  "roundingwarnings",
  "hopitalrecursions",
]

print "cdef class __Settings(object):"
for name in sollya_settings:
    print r"""
    property {name}:
        def __get__(self):
            return wrap(sollya_lib_get_{name}())
        def __set__(self, value):
            sollya_lib_set_{name}(as_SollyaObject(value).value)
        def __del__(self):
            cdef sollya_obj_t default = sollya_lib_default()
            sollya_lib_set_{name}(default)
            sollya_lib_clear_obj(default)
    """.format(name=name)

print r"""
    property version:
        def __get__(self):
            return {version}
""".format(version=CYTHONSOLLYA_VERSION)

print "settings = __Settings()"