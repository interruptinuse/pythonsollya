# vim: sw=2
from libc.stdint cimport int64_t, uint64_t

from csollya_ops cimport *

cdef extern from "sollya.h":
  ctypedef struct __sollya_internal_type_object_base:
    pass

  ctypedef __sollya_internal_type_object_base * sollya_obj_t

  void sollya_lib_init()


  sollya_obj_t sollya_lib_constant_from_double(double v)
  sollya_obj_t sollya_lib_constant_from_int64(int64_t v)

  bint sollya_lib_get_constant_as_double(double *, sollya_obj_t)
  bint sollya_lib_get_constant_as_int(int *, sollya_obj_t)
  bint sollya_lib_get_constant_as_int64(int64_t *, sollya_obj_t)
  bint sollya_lib_get_constant_as_uint64(uint64_t *, sollya_obj_t)

  void sollya_lib_autoprint(sollya_obj_t, ...)

  void sollya_lib_clear_obj(sollya_obj_t obj)

  bint sollya_lib_cmp_objs_structurally(sollya_obj_t, sollya_obj_t)

  int sollya_lib_printf(const char *, ...)
  int sollya_lib_sprintf(char *, const char *, ...)
  int sollya_lib_snprintf(char *, size_t, const char *, ...)

  sollya_obj_t sollya_lib_list(sollya_obj_t[], int)
  bint sollya_lib_get_element_in_list(sollya_obj_t *, sollya_obj_t, int)
  sollya_obj_t sollya_lib_string(char *)

  sollya_obj_t sollya_lib_length(sollya_obj_t)

  sollya_obj_t sollya_lib_cmp_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_in(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_less(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_greater(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_less_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_greater_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_not_equal(sollya_obj_t, sollya_obj_t)

  bint sollya_lib_is_true(sollya_obj_t)
  bint sollya_lib_is_false(sollya_obj_t)

  sollya_obj_t sollya_lib_dirtyfindzeros(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_head(sollya_obj_t)
  sollya_obj_t sollya_lib_roundcorrectly(sollya_obj_t)
  sollya_obj_t sollya_lib_degree(sollya_obj_t)
  sollya_obj_t sollya_lib_numerator(sollya_obj_t)
  sollya_obj_t sollya_lib_denominator(sollya_obj_t)
  sollya_obj_t sollya_lib_substitute(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_composepolynomials(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_coeff(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_subpoly(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_roundcoefficients(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_rationalapprox(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_evaluate(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_round(sollya_obj_t, sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_revert(sollya_obj_t)
  sollya_obj_t sollya_lib_sort(sollya_obj_t)
  sollya_obj_t sollya_lib_mantissa(sollya_obj_t)
  sollya_obj_t sollya_lib_exponent(sollya_obj_t)
  sollya_obj_t sollya_lib_precision(sollya_obj_t)
  sollya_obj_t sollya_lib_tail(sollya_obj_t)
  sollya_obj_t sollya_lib_range(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_sqrt(sollya_obj_t)
  sollya_obj_t sollya_lib_exp(sollya_obj_t)
  sollya_obj_t sollya_lib_log(sollya_obj_t)
  sollya_obj_t sollya_lib_log2(sollya_obj_t)
  sollya_obj_t sollya_lib_log10(sollya_obj_t)
  sollya_obj_t sollya_lib_sin(sollya_obj_t)
  sollya_obj_t sollya_lib_cos(sollya_obj_t)
  sollya_obj_t sollya_lib_tan(sollya_obj_t)
  sollya_obj_t sollya_lib_asin(sollya_obj_t)
  sollya_obj_t sollya_lib_acos(sollya_obj_t)
  sollya_obj_t sollya_lib_atan(sollya_obj_t)
  sollya_obj_t sollya_lib_sinh(sollya_obj_t)
  sollya_obj_t sollya_lib_cosh(sollya_obj_t)
  sollya_obj_t sollya_lib_tanh(sollya_obj_t)
  sollya_obj_t sollya_lib_asinh(sollya_obj_t)
  sollya_obj_t sollya_lib_acosh(sollya_obj_t)
  sollya_obj_t sollya_lib_atanh(sollya_obj_t)
  sollya_obj_t sollya_lib_abs(sollya_obj_t)
  sollya_obj_t sollya_lib_erf(sollya_obj_t)
  sollya_obj_t sollya_lib_erfc(sollya_obj_t)
  sollya_obj_t sollya_lib_log1p(sollya_obj_t)
  sollya_obj_t sollya_lib_expm1(sollya_obj_t)
  sollya_obj_t sollya_lib_double(sollya_obj_t)
  sollya_obj_t sollya_lib_single(sollya_obj_t)
  sollya_obj_t sollya_lib_quad(sollya_obj_t)
  sollya_obj_t sollya_lib_halfprecision(sollya_obj_t)
  sollya_obj_t sollya_lib_double_double(sollya_obj_t)
  sollya_obj_t sollya_lib_triple_double(sollya_obj_t)
  sollya_obj_t sollya_lib_doubleextended(sollya_obj_t)
  sollya_obj_t sollya_lib_ceil(sollya_obj_t)
  sollya_obj_t sollya_lib_floor(sollya_obj_t)
  sollya_obj_t sollya_lib_nearestint(sollya_obj_t)
  sollya_obj_t sollya_lib_length(sollya_obj_t)

  sollya_obj_t sollya_lib_and(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_or(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_negate(sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_in(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_less(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_greater(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_less_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_greater_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_cmp_not_equal(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_add(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_sub(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_concat(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_append(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_prepend(sollya_obj_t, sollya_obj_t)

  sollya_obj_t sollya_lib_approx(sollya_obj_t)
  sollya_obj_t sollya_lib_mul(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_div(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_pow(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_neg(sollya_obj_t)
  sollya_obj_t sollya_lib_sup(sollya_obj_t)
  sollya_obj_t sollya_lib_mid(sollya_obj_t)
  sollya_obj_t sollya_lib_inf(sollya_obj_t)
  sollya_obj_t sollya_lib_diff(sollya_obj_t)



  sollya_obj_t sollya_lib_absolute()
  sollya_obj_t sollya_lib_relative()
  sollya_obj_t sollya_lib_fixed()
  sollya_obj_t sollya_lib_floating()
  sollya_obj_t sollya_lib_error()
  sollya_obj_t sollya_lib_double_obj()
  sollya_obj_t sollya_lib_single_obj()
  sollya_obj_t sollya_lib_quad_obj()
  sollya_obj_t sollya_lib_halfprecision_obj()
  sollya_obj_t sollya_lib_doubleextended_obj()
  sollya_obj_t sollya_lib_double_double_obj()
  sollya_obj_t sollya_lib_triple_double_obj()

  sollya_obj_t sollya_lib_round_down()
  sollya_obj_t sollya_lib_round_up()
  sollya_obj_t sollya_lib_round_towards_zero()
  sollya_obj_t sollya_lib_round_to_nearest()


  sollya_obj_t sollya_lib_pi()

  sollya_obj_t sollya_lib_on()
  sollya_obj_t sollya_lib_off()

  sollya_obj_t sollya_lib_true()
  sollya_obj_t sollya_lib_false()

  sollya_obj_t sollya_lib_dyadic()
  sollya_obj_t sollya_lib_powers()
  sollya_obj_t sollya_lib_binary()
  sollya_obj_t sollya_lib_hexadecimal()
  sollya_obj_t sollya_lib_decimal()

  bint sollya_lib_obj_is_function(sollya_obj_t)
  bint sollya_lib_obj_is_list(sollya_obj_t)
  bint sollya_lib_obj_is_end_elliptic_list(sollya_obj_t)
  bint sollya_lib_obj_is_range(sollya_obj_t)
  bint sollya_lib_obj_is_string(sollya_obj_t)
  bint sollya_lib_obj_is_error(sollya_obj_t)
  bint sollya_lib_obj_is_structure(sollya_obj_t)
  bint sollya_lib_obj_is_procedure(sollya_obj_t)

  bint sollya_lib_get_function_arity(int *, sollya_obj_t)
  bint sollya_lib_get_head_function(sollya_base_function_t *, sollya_obj_t)
  bint sollya_lib_get_subfunctions(sollya_obj_t, int *, ...);

  bint sollya_lib_get_structure_elements(char ***, sollya_obj_t **, int *, sollya_obj_t);
  bint sollya_lib_get_element_in_structure(sollya_obj_t *, char *, sollya_obj_t);
  bint sollya_lib_create_structure(sollya_obj_t *, sollya_obj_t, char *, sollya_obj_t);

  void sollya_lib_set_prec(sollya_obj_t)
  void sollya_lib_set_points(sollya_obj_t)
  void sollya_lib_set_diam(sollya_obj_t)
  void sollya_lib_set_display(sollya_obj_t)
  void sollya_lib_set_verbosity(sollya_obj_t)
  void sollya_lib_set_canonical(sollya_obj_t)
  void sollya_lib_set_autosimplify(sollya_obj_t)
  void sollya_lib_set_fullparentheses(sollya_obj_t)
  void sollya_lib_set_showmessagenumbers(sollya_obj_t)
  void sollya_lib_set_taylorrecursions(sollya_obj_t)
  void sollya_lib_set_timing(sollya_obj_t)
  void sollya_lib_set_midpointmode(sollya_obj_t)
  void sollya_lib_set_dieonerrormode(sollya_obj_t)
  void sollya_lib_set_rationalmode(sollya_obj_t)
  void sollya_lib_set_roundingwarnings(sollya_obj_t)
  void sollya_lib_set_hopitalrecursions(sollya_obj_t)

  sollya_obj_t sollya_lib_get_prec()
  sollya_obj_t sollya_lib_get_points()
  sollya_obj_t sollya_lib_get_diam()
  sollya_obj_t sollya_lib_get_display()
  sollya_obj_t sollya_lib_get_verbosity()
  sollya_obj_t sollya_lib_get_canonical()
  sollya_obj_t sollya_lib_get_autosimplify()
  sollya_obj_t sollya_lib_get_fullparentheses()
  sollya_obj_t sollya_lib_get_showmessagenumbers()
  sollya_obj_t sollya_lib_get_taylorrecursions()
  sollya_obj_t sollya_lib_get_timing()
  sollya_obj_t sollya_lib_get_midpointmode()
  sollya_obj_t sollya_lib_get_dieonerrormode()
  sollya_obj_t sollya_lib_get_rationalmode()
  sollya_obj_t sollya_lib_get_roundingwarnings()
  sollya_obj_t sollya_lib_get_hopitalrecursions()

  sollya_obj_t sollya_lib_parse_string(const char *)
  sollya_obj_t sollya_lib_parse(sollya_obj_t)

  sollya_obj_t sollya_lib_copy_obj(sollya_obj_t)

  sollya_obj_t sollya_lib_approx(sollya_obj_t)
  sollya_obj_t sollya_lib_horner(sollya_obj_t)
  sollya_obj_t sollya_lib_canonical(sollya_obj_t)
  sollya_obj_t sollya_lib_expand(sollya_obj_t)
  sollya_obj_t sollya_lib_dirtysimplify(sollya_obj_t)
  sollya_obj_t sollya_lib_simplify(sollya_obj_t)
  sollya_obj_t sollya_lib_simplifysafe(sollya_obj_t)

  sollya_obj_t sollya_lib_guessdegree(sollya_obj_t, sollya_obj_t, sollya_obj_t, ...)
  sollya_obj_t sollya_lib_fpminimax(sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t, ...)
  sollya_obj_t sollya_lib_remez(sollya_obj_t, sollya_obj_t, sollya_obj_t, ...)
  sollya_obj_t sollya_lib_infnorm(sollya_obj_t, sollya_obj_t, ...)
  sollya_obj_t sollya_lib_supnorm(sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t, sollya_obj_t)

  sollya_obj_t sollya_lib_findzeros(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_dirtyinfnorm(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_numberroots(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_integral(sollya_obj_t, sollya_obj_t)
  sollya_obj_t sollya_lib_dirtyintegral(sollya_obj_t, sollya_obj_t)
  
  sollya_obj_t sollya_lib_free_variable()
  sollya_obj_t sollya_lib_error()

  uint64_t sollya_lib_hash(sollya_obj_t)

# vim: sw=2
