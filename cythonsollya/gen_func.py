# coding: utf-8 vim:sw=2

class sollya_obj_t: 
  python_class     = "SollyaObject"
  c_format         = "sollya_obj_t"
  convert_function = "to_sollya_obj_t" 
  result_decl_tplt= "cdef SollyaObject %s = SollyaObject.__new__(SollyaObject)\n"
  result_asgn_tplt = "%s.value = %s"
  @staticmethod
  def result_decl_gen(result_var, tab = 2):
    indent = " " * tab 
    result = indent + sollya_obj_t.result_decl_tplt % (result_var)
    return result
  @staticmethod
  def clear_gen(name, tab=2):
    return "{}sollya_lib_clear_obj({})\n".format(" "*tab, name)

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
  def clear_gen(name, tab=2):
    return ""

  @staticmethod
  def result_gen(result_var, result_call, tab = 2):
    return void.result_decl_gen(result_var, tab) + void.result_asgn_gen(result_var, result_call, tab)

  @staticmethod
  def return_gen(result_var):
    return ""

class LIST: pass

class SOT:
  """ Sollya Object template """
  def __init__(self, return_format, name, input_formats,
      optional_inputs=[], binding_name=None, interactive_name=None, variadic=None):
    self.return_format = return_format
    self.name = name
    self.input_formats = input_formats
    self.optional_inputs = []
    if optional_inputs == LIST:
      self.pass_remaining_args = True
    else:
      self.optional_inputs = optional_inputs
      self.pass_remaining_args = False
    self.variadic = variadic if variadic is not None else (optional_inputs != [])
    if binding_name is None:
      self.binding_name = self.name.replace("sollya_lib_", "")
    else:
      self.binding_name = binding_name
    if interactive_name is None:
      self.interactive_name = self.name.replace("sollya_lib_", "")
    else:
      self.interactive_name = interactive_name

  def docstring(self):
    from subprocess import Popen, PIPE
    interpreter = Popen(['sollya'], stdin=PIPE, stdout=PIPE)
    command = "help {};".format(self.interactive_name)
    help_text = interpreter.communicate(command)[0]
    help_lines = help_text.split('\n')
    intro = "Wrapper for Sollya's '{name}'. The Sollya help for '{name}' follows.".format(name=self.interactive_name)
    if len(help_lines) > 2:
      lines = ['r"""', intro, ""] + help_lines + ['"""\n']
      return '\n'.join('  ' + line for line in lines)
    else:
      return ""

  def generate_binding(self):
    # building binding name
    # building binding inputs
    binding_inputs = []
    call_op_list = []
    code_op_decl = code_clear = ""
    num_opt_inputs = len(self.optional_inputs)
    # building declaration and assignation of required arguments
    for i, op_format in enumerate(self.input_formats):
      binding_inputs.append("op%d" % i)
      call_op_list.append("sollya_op%d" % i)
      # XXX: won't this leak memory?
      code_op_decl += "  cdef %s sollya_op%d = %s(op%d)\n" % (op_format.c_format, i, op_format.convert_function, i)
      code_clear = op_format.clear_gen("sollya_op%d"%i) + code_clear
    if self.pass_remaining_args:
      binding_inputs.append("*args")
      call_op_list.append("sollya_args")
      code_op_decl +=  "  cdef sollya_obj_t sollya_args = %s(args)\n" % (sollya_obj_t.convert_function)
      code_clear = sollya_obj_t.clear_gen("sollya_args") + code_clear
    # building declaration of optional arguments
    for i, op_format in enumerate(self.optional_inputs):
      code_op_decl += "  cdef %s sollya_opt_op%d = NULL\n" % (op_format.c_format, i)
      code_clear = op_format.clear_gen("sollya_opt_op%d"%i) + code_clear
    # building assignation of optional arguments
    if num_opt_inputs > 0:
      binding_inputs.append("*opt_args")
      # FIXME: raise a TypeError instead
      code_op_decl += "  if len(opt_args) > %d:\n" % (num_opt_inputs)
      code_op_decl += "    raise TypeError('%s takes at most %d arguments (' + len(opt_args) + 'given)')\n" % (self.binding_name, num_opt_inputs)

    # generating declaration
    declaration = "def %s(%s):\n" % (self.binding_name, ", ".join(binding_inputs))
    if num_opt_inputs == 0:
      # no optional arguments
      if self.variadic:
        call_op_list.append("NULL")
      call_code = "%s(%s)" % (self.name, ", ".join(call_op_list))
      result = self.return_format.result_gen("result", call_code, tab = 2)
      code_op_decl += result + "\n"
    else:
      # optional arguments
      code_op_decl += self.return_format.result_decl_gen("result", tab = 2)
      for i in xrange(num_opt_inputs+1):
        call_opt_list = call_op_list + ["sollya_opt_op%d" % j for j in xrange(i)]
        if self.variadic:
          call_opt_list.append("NULL")
        call_code = "%s(%s)" % (self.name, ", ".join(call_opt_list))
        result = self.return_format.result_asgn_gen("result", call_code, tab = 4)
        code_op_decl += "  if len(opt_args) == %d:\n" % i
        for j in xrange(i):
          op_format = self.optional_inputs[j]
          code_op_decl += "    sollya_opt_op%d = %s(opt_args[%d])\n" % (j,op_format.convert_function,j)
        code_op_decl += result + "\n"
    code_ret = "  " + self.return_format.return_gen("result")
    return declaration + self.docstring() + code_op_decl + code_clear + code_ret



sollya_h_list = [ # should match the order of declarations in sollya.h

  # Functions corresponding to Sollya commands

  SOT(void, "sollya_lib_printdouble", (sollya_obj_t,)),
  SOT(void, "sollya_lib_printsingle", (sollya_obj_t,)),
  SOT(void, "sollya_lib_printexpansion", (sollya_obj_t,)),
  SOT(void, "sollya_lib_bashexecute",(sollya_obj_t,)),
  SOT(void, "sollya_lib_externalplot", (sollya_obj_t,)*4, optional_inputs = [sollya_obj_t]*3),
  SOT(void, "sollya_lib_asciiplot",(sollya_obj_t,)*2),
  SOT(void, "sollya_lib_execute",(sollya_obj_t,)),
  # omitted: worstcase (deprecated)
  SOT(void, "sollya_lib_suppressmessage", (), optional_inputs=LIST),
  SOT(void, "sollya_lib_unsuppressmessage", (), optional_inputs=LIST),
  SOT(void, "sollya_lib_implementconstant", (sollya_obj_t,), optional_inputs = [sollya_obj_t]*2),

  # Functions corresponding to Sollya built-in procedures

  SOT(sollya_obj_t, "sollya_lib_append",(sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_prepend",(sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_approx",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sup",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_mid",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_inf",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_diff",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_bashevaluate", (sollya_obj_t,), optional_inputs = [sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_getsuppressedmessages", ()),
  SOT(sollya_obj_t, "sollya_lib_getbacktrace", ()),
  SOT(sollya_obj_t, "sollya_lib_remez", (sollya_obj_t, sollya_obj_t, sollya_obj_t,), optional_inputs = [sollya_obj_t, sollya_obj_t, sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_annotatefunction", (sollya_obj_t,)*4, optional_inputs = [sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_min", (), optional_inputs=LIST),
  SOT(sollya_obj_t, "sollya_lib_max", (), optional_inputs=LIST),
  SOT(sollya_obj_t, "sollya_lib_fpminimax", (sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t,), optional_inputs = [sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_horner",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_canonical",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_expand",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_dirtysimplify",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_simplify",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_simplifysafe",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_taylor",(sollya_obj_t,)*3),
  SOT(sollya_obj_t, "sollya_lib_taylorform",(sollya_obj_t,)*3, optional_inputs=[sollya_obj_t]*2),
  SOT(sollya_obj_t, "sollya_lib_chebyshevform",(sollya_obj_t,)*3),
  SOT(sollya_obj_t, "sollya_lib_autodiff",(sollya_obj_t,)*3),
  SOT(sollya_obj_t, "sollya_lib_degree", (sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_numerator", (sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_denominator", (sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_substitute", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_composepolynomials", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_coeff", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_subpoly", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_roundcoefficients", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_rationalapprox", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_round",(sollya_obj_t,sollya_obj_t,sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_evaluate", (sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_parse",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_readxml",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_infnorm", (sollya_obj_t, sollya_obj_t), optional_inputs = [sollya_obj_t, sollya_obj_t]),
  SOT(sollya_obj_t, "sollya_lib_supnorm", (sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_findzeros", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_dirtyinfnorm", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_numberroots", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_integral", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_dirtyintegral", (sollya_obj_t, sollya_obj_t)),
  SOT(sollya_obj_t, "sollya_lib_implementpoly", (sollya_obj_t,)*6, optional_inputs = [sollya_obj_t]*3),
  SOT(sollya_obj_t, "sollya_lib_checkinfnorm", (sollya_obj_t,)*3),
  SOT(sollya_obj_t, "sollya_lib_zerodenominators", (sollya_obj_t,)*2),
  SOT(sollya_obj_t, "sollya_lib_searchgal", (sollya_obj_t,)*6),
  SOT(sollya_obj_t, "sollya_lib_guessdegree", (sollya_obj_t,)*3, optional_inputs=[sollya_obj_t]*2),
  SOT(sollya_obj_t, "sollya_lib_dirtyfindzeros",(sollya_obj_t, sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_head",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_roundcorrectly",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_revert",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_sort",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_mantissa",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_exponent",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_precision",(sollya_obj_t,)),
  SOT(sollya_obj_t, "sollya_lib_tail",(sollya_obj_t,)),
  # omitted: range (→ Interval)
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
  SOT(sollya_obj_t, "sollya_lib_objectname",(sollya_obj_t,)),

]

if __name__ == "__main__":
  for func in sollya_h_list:
    print func.generate_binding()
