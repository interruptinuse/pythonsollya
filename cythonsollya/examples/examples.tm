<TeXmacs|1.99.4>

<style|<tuple|generic|american>>

<\body>
  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      import sollya
    </input>
  </session>

  Perhaps the simplest way to perform computations with Sollya is
  <code*|sollya.parse()>, which takes a string containing an expression in
  Sollya syntax.

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.parse("diff(sin(x));")
    <|unfolded-io>
      cos(x)
    </unfolded-io>
  </session>

  Its return value is a Python object of type <code*|sollya.SollyaObject>.
  These objects are Pyton wrappers for Sollya objects, and can also be
  manipulated directly.

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.x
    <|unfolded-io>
      x
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      type(sollya.x)
    <|unfolded-io>
      \<less\>type 'sollya.SollyaObject'\<gtr\>
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.Interval(1, 2)
    <|unfolded-io>
      [1;2]
    </unfolded-io>
  </session>

  Various simple Python objects can be converted to Sollya objects, and
  simple Sollya objects can be converted back to Python:

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.SollyaObject(42)
    <|unfolded-io>
      42
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.SollyaObject([True, "hello", sollya.SollyaObject([]), None,
      Ellipsis])
    <|unfolded-io>
      [\|true, "hello", [\| \|], void...\|]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      float(sollya.SollyaObject(42))
    <|unfolded-io>
      42.0
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      bool(sollya.parse("1 + 1 == 2;"))
    <|unfolded-io>
      True
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      list(sollya.parse("[\| pi, pi^2 \|]"))
    <|unfolded-io>
      [pi, (pi)^2]
    </unfolded-io>
  </session>

  Arithmetic operations with Sollya objects or between Sollya objects and
  Python objects convertible to Sollya mostly work as expected, as do
  comparisons and various other standard Python functions. Essentially all
  commands and built-in procedures available interactively in Sollya are
  bound to Python functions with the same name that automatically convert
  their input to Sollya objects (and return Sollya objects).

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.SollyaObject(1) + sollya.Interval(1, 2)
    <|unfolded-io>
      [2;3]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      1 + sollya.Interval(1, 2)
    <|unfolded-io>
      [2;3]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      (sollya.SollyaObject(2)/3)**2
    <|unfolded-io>
      (2 / 3)^2
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      sollya_list = sollya.SollyaObject(["a", "b"])
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      len(sollya_list)
    <|unfolded-io>
      2
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya_list[0]
    <|unfolded-io>
      a
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.pi \<less\> 3
    <|unfolded-io>
      False
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.exp(1)
    <|unfolded-io>
      exp(1)
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.diff(sollya.sin(sollya.x))
    <|unfolded-io>
      cos(x)
    </unfolded-io>
  </session>

  Importing <code*|*> from the <code*|sollya> module allows one to call
  Sollya in a natural way, with a syntax reasonably close to that of
  interactive Sollya. Note however that this may shadow other useful
  definitions of names such as <code*|x>, <code*|abs> and <code*|pi>. Also
  note that definitions of multiple-precision constants typically still need
  to be wrapped in calls to <code*|parse()> or similar.

  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      from sollya import *
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      abs(x) + sqrt(pi)
    <|unfolded-io>
      abs(x) + sqrt(pi)
    </unfolded-io>
  </session>

  More features of Sollya objects:

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject("").is_string()
    <|unfolded-io>
      True
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      exp(1), exp(1).approx()
    <|unfolded-io>
      (exp(1), 2.7182818284590452353602874713526624977572470937)
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      expr = exp(1) + 2*x
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      expr(0.5)
    <|unfolded-io>
      1 + exp(1)
    </unfolded-io>
  </session>

  Destructuring of Sollya \Pfunctions\Q (symbolic expressions):

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      expr.arity()
    <|unfolded-io>
      2
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      expr.operator()
    <|unfolded-io>
      ADD
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      type(expr.operator())
    <|unfolded-io>
      \<less\>type 'sollya.SollyaOperator'\<gtr\>
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaOperator("sub")(*expr.operands())
    <|unfolded-io>
      exp(1) - 2 * x
    </unfolded-io>
  </session>

  Sollya structures are supported, and can be converted from/to Python
  dictionaries:

  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      s = SollyaObject({"field": "value", "other_field": 17})
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      s
    <|unfolded-io>
      { .field = "value", .other_field = 17 }
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      s.is_structure()
    <|unfolded-io>
      True
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      len(s)
    <|unfolded-io>
      2
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      s.struct.field
    <|unfolded-io>
      value
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      s.struct.field = None
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      s
    <|unfolded-io>
      { .other_field = 17, .field = void }
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      dict(s)
    <|unfolded-io>
      {'other_field': 17, 'field': void}
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      list(s)
    <|unfolded-io>
      [('other_field', 17), ('field', void)]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject({"יי": 1})
    <|unfolded-io>
      Traceback (most recent call last):

      RuntimeError: creation of Sollya structure failed
    </unfolded-io>
  </session>

  Sollya global settings are accessed as follows:

  <\session|python|default>
    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      sollya.settings.display
    <|unfolded-io>
      decimal
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      sollya.settings.display = binary
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(17)
    <|unfolded-io>
      1.0001_2 * 2^(4)
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      sollya.settings.display = default
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(17)
    <|unfolded-io>
      17
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      sollya.settings.fullparentheses = on
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      expand((1 + x)**3)
    <|unfolded-io>
      ((((x * x) * x) + (3 * (x * x))) + (3 * x)) + 1
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      del sollya.settings.fullparentheses
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      expand((1 + x)**3)
    <|unfolded-io>
      x * x * x + 3 * x * x + 3 * x + 1
    </unfolded-io>
  </session>

  Calling Python functions from Sollya:

  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      def myproc(x, y): return x + y
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      foo = SollyaObject(myproc)
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      foo(x, x)
    <|unfolded-io>
      2 * x
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      parse("proc(fun) { return fun(1, 2); };")(foo)
    <|unfolded-io>
      3
    </unfolded-io>
  </session>

  Implementing new mathematical functions in Python:

  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      def myfunction(x, diff_order, prec): return exp(x)
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      f = function(myfunction)
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      f(1)
    <|unfolded-io>
      myfunction(1)
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      f(1).approx()
    <|unfolded-io>
      2.7182818284590452353602874713526624977572470936999
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      diff(f)(1)
    <|unfolded-io>
      (diff(myfunction))(1)
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      diff(f)(1).approx()
    <|unfolded-io>
      2.7182818284590452353602874713526624977572470936999
    </unfolded-io>
  </session>

  Same thing for constants:

  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      def myconstant(prec): return 17
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      c = libraryconstant(myconstant)
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      (c/2).approx()
    <|unfolded-io>
      8.5
    </unfolded-io>
  </session>

  \;

  \;

  \;

  \;
</body>