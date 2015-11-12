# -*- coding: utf-8 -*- vim:sw=2

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
    """.format(name=name)
print "settings = __Settings()"
