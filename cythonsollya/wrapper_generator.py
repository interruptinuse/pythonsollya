# vim:sw=2

class sollya_obj_t: 
  python_class     = "SollyaObject"
  c_format         = "sollya_obj_t"
  convert_function = "convertPythonTo_sollya_obj_t" 
  result_decl_tplt= "cdef SollyaObject %s = SollyaObject.__new__(SollyaObject)\n"
  result_asgn_tplt = "%s.value = %s"
  @staticmethod
  def result_decl_gen(result_var, tab = 2):
    indent = " " * tab 
    result = indent + sollya_obj_t.result_decl_tplt % (result_var)
    return result

  @staticmethod
  def result_asgn_gen(result_var, result_call, tab = 2):
    indent = " " * tab 
    result = indent + sollya_obj_t.result_asgn_tplt % (result_var, result_call)
    return result

  @staticmethod
  def result_gen(result_var, result_call, tab = 2):
    return sollya_obj_t.result_decl_gen(result_var, tab) + sollya_obj_t.result_asgn_gen(result_var, result_call, tab)

  @staticmethod
  def return_gen(result_var):
    return "return %s\n" % result_var

class void: 
  @staticmethod
  def result_decl_gen(result_var, tab = 2):
    return ""

  @staticmethod
  def result_asgn_gen(result_var, result_call, tab = 2):
    return "%s%s" % (" " * tab, result_call)

  @staticmethod
  def result_gen(result_var, result_call, tab = 2):
    return void.result_decl_gen(result_var, tab) + void.result_asgn_gen(result_var, result_call, tab)

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
  def __init__(self, return_format, name, input_formats, optional_inputs = [], binding_name = None):
    self.return_format = return_format
    self.name = name
    self.input_formats = input_formats
    self.optional_inputs = optional_inputs
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
    num_opt_inputs = len(self.optional_inputs)
    # building declaration and assignation of required arguments
    for i in xrange(len(self.input_formats)):
      op_format = self.input_formats[i]
      binding_inputs.append("op%d" % i)
      call_op_list.append("sollya_op%d" % i)
      code_op_decl += "  cdef %s sollya_op%d = %s(op%d)\n" % (op_format.c_format, i, op_format.convert_function, i) 
    # building declaration of optional arguments
    for i in xrange(len(self.optional_inputs)):
      op_format = self.optional_inputs[i]
      code_op_decl += "  cdef %s sollya_opt_op%d\n" % (op_format.c_format, i)
    # building assignation of optional arguments
    if len(self.optional_inputs) > 0:
      code_op_decl += "  if len(opt_args) > %d:\n" % (num_opt_inputs)
      code_op_decl += "    print \"Error in %s, too many positional argumens\"\n" % (self.binding_name)
      code_op_decl += "    print \"%d expected, got %%d\" %% (len(opt_args))\n" % (num_opt_inputs)
      code_op_decl += "    raise Exception()\n"


    # generating declaration
    if num_opt_inputs == 0:
      # no optinal arguments
      declaration = "def %s(%s):" % (self.binding_name, ", ".join(binding_inputs))
      call_code = "%s(%s)" % (self.name, ", ".join(call_op_list))
      result = self.return_format.result_gen("result", call_code, tab = 2)
      return declaration + "\n" + code_op_decl + result + "\n  " + self.return_format.return_gen("result")
    else:
      # optinal arguments
      declaration = "def %s(%s, *opt_args):" % (self.binding_name, ", ".join(binding_inputs))
      code_op_decl += self.return_format.result_decl_gen("result", tab = 2)
      for i in xrange(num_opt_inputs+1):
        call_opt_list = call_op_list + ["sollya_opt_op%d" % j for j in xrange(i)] + ["NULL"]
        call_code = "%s(%s)" % (self.name, ", ".join(call_opt_list))
        result = self.return_format.result_asgn_gen("result", call_code, tab = 4)
        code_op_decl += "  if len(opt_args) == %d:\n" % i
        for j in xrange(i):
          op_format = self.optional_inputs[j]
          code_op_decl += "    sollya_opt_op%d = %s(opt_args[%d])\n" % (j,op_format.convert_function,j)
        code_op_decl += result + "\n"
      return declaration + "\n" + code_op_decl + "  " + self.return_format.return_gen("result")



sollya_h_list = [
  SOT(sollya_obj_t, "sollya_lib_dirtyfindzeros",(sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_head",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_roundcorrectly",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_degree", (sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_numerator", (sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_denominator", (sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_substitute", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_composepolynomials", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_coeff", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_subpoly", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_roundcoefficients", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_rationalapprox", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_evaluate", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_round",(sollya_obj_t,sollya_obj_t,sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_revert",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sort",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_mantissa",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_exponent",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_precision",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_tail",(sollya_obj_t,)),
  # bound to sollya_range to avoid polluting python's range
  # XXX: why not just exclude it from __all__?
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
  SOT(sollya_obj_t, "sollya_lib_guessdegree", (sollya_obj_t,sollya_obj_t,sollya_obj_t), optional_inputs = [sollya_obj_t, sollya_obj_t]),

  SOT(sollya_obj_t, "sollya_lib_fpminimax", (sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t,), optional_inputs = [sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_remez", (sollya_obj_t, sollya_obj_t, sollya_obj_t,), optional_inputs = [sollya_obj_t, sollya_obj_t, sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_infnorm", (sollya_obj_t, sollya_obj_t), optional_inputs = [sollya_obj_t, sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_supnorm", (sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t)),

  SOT(sollya_obj_t, "sollya_lib_findzeros", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_dirtyinfnorm", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_numberroots", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_integral", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_dirtyintegral", (sollya_obj_t, sollya_obj_t)),
]

if __name__ == "__main__":
  for func in sollya_h_list:
    print func.generate_binding()
