
class sollya_obj_t: 
  python_class     = "SollyaObject"
  c_format         = "sollya_obj_t"
  convert_function = "convertPythonTo_sollya_obj_t" 
  result_template  = "cdef SollyaObject %s = SollyaObject.__new__(SollyaObject)\n  %s._c_sollya_obj = %s"
  @staticmethod
  def result_gen(result_var, result_call):
    return sollya_obj_t.result_template % (result_var, result_var, result_call)

  @staticmethod
  def return_gen(result_var):
    return "return %s\n" % result_var

class void: 
  @staticmethod
  def result_gen(result_var, result_call):
    return "%s" % (result_call)

  @staticmethod
  def return_gen(result_var):
    return ""

class SSO:
  """ Sollya Static Object """
  def __init__(self, binding_name_list, sollya_lib_func):
    self.binding_name_list = binding_name_list
    self.sollya_lib_func = sollya_lib_func

  def generate_binding(self):
    pass
    

class SOT:
  """ Sollya Object template """
  def __init__(self, return_format, name, input_formats, binding_name = None):
    self.return_format = return_format
    self.name = name
    self.input_formats = input_formats
    if binding_name is None:
      self.binding_name = self.name.replace("sollya_lib_", "")
    else:
      self.binding_name = binding_name

  def generate_binding(self):
    # building binding name
    # building binding inputs
    binding_inputs = []
    call_op_list = []
    code_op_decl = ""
    for i in xrange(len(self.input_formats)):
      op_format = self.input_formats[i]
      binding_inputs.append("op%d" % i)
      call_op_list.append("sollya_op%d" % i)
      code_op_decl += "  cdef %s sollya_op%d = %s(op%d)\n" % (op_format.c_format, i, op_format.convert_function, i) 

    # generating declaration
    declaration = "def %s(%s):" % (self.binding_name, ", ".join(binding_inputs))

    call_code = "%s(%s)" % (self.name, ", ".join(call_op_list))
    result = self.return_format.result_gen("result", call_code)
    return declaration + "\n" + code_op_decl + "  " + result + "\n  " + self.return_format.return_gen("result")


sollya_h_list = [
  SOT(sollya_obj_t, "sollya_lib_dirtyfindzeros",(sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_head",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_roundcorrectly",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_round",(sollya_obj_t,sollya_obj_t,sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_revert",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sort",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_mantissa",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_exponent",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_precision",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_tail",(sollya_obj_t,)),
  # bound to sollya_range to avoid polluting python's range
  SOT(sollya_obj_t, "sollya_lib_range",(sollya_obj_t, sollya_obj_t,), binding_name = "sollya_range"),
  SOT(sollya_obj_t, "sollya_lib_sqrt",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_exp",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_log",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_log2",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_log10",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sin",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_cos",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_tan",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_asin",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_acos",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_atan",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sinh",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_cosh",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_tanh",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_asinh",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_acosh",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_atanh",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_abs",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_erf",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_erfc",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_log1p",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_expm1",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_double",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_single",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_quad",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_halfprecision",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_double_double",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_triple_double",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_doubleextended",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_ceil",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_floor",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_nearestint",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_length",(sollya_obj_t,)),

  SOT(sollya_obj_t, "sollya_lib_parse",(sollya_obj_t,)),

  SOT(sollya_obj_t, "sollya_lib_inf",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sup",(sollya_obj_t,)),

  SOT(void, "sollya_lib_set_display",(sollya_obj_t,), binding_name = "display"),
  SOT(void, "sollya_lib_set_prec",(sollya_obj_t,), binding_name = "prec"),
  SOT(void, "sollya_lib_set_verbosity",(sollya_obj_t,), binding_name = "verbosity"),
  SOT(void, "sollya_lib_set_roundingwarnings",(sollya_obj_t,), binding_name = "roundingwarnings"),
]

sollya_static_obj = [
  SSO(["binary32"], "sollya_lib_single_obj"),
]

if __name__ == "__main__":
  for func in sollya_h_list:
    print func.generate_binding()
