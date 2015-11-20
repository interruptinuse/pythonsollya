<TeXmacs|1.99.2>

<style|<tuple|generic|american>>

<\body>
  <\session|python|default>
    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      import sys
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      sys.path.append("/home/marc/docs/recherche/projets/metalibm/pythonsollya/cythonsollya/build/lib.linux-x86_64-2.7<next-line>")
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      from sollya import *
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(1.5) + SollyaObject(2) + 3
    <|unfolded-io>
      6.5
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(True), SollyaObject(False)
    <|unfolded-io>
      (true, false)
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(None)
    <|unfolded-io>
      void
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject("hello"), SollyaObject(u"world!")
    <|unfolded-io>
      (hello, world!)
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject([])
    <|unfolded-io>
      [\| \|]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject([1, Ellipsis])
    <|unfolded-io>
      [\|1...\|]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject({"field": "value", "other_field": 42})
    <|unfolded-io>
      { .field = "value", .other_field = 42 }
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(lambda x: x+1)(16)
    <|unfolded-io>
      17
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(SollyaObject(1))
    <|unfolded-io>
      1
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(True) and False
    <|unfolded-io>
      False
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject([1, x]) + [sin(x)]
    <|unfolded-io>
      [1, _x_, sin(_x_)]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      exp(1)
    <|unfolded-io>
      exp(1)
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      exp(1).approx()
    <|unfolded-io>
      2.7182818284590452353602874713526624977572470937
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      l = autodiff(exp(cos(x))+sin(exp(x)), 5, 0)
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      settings.midpointmode = on
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      for f in l: print f
    <|unfolded-io>
      0.3559752813266941742012789792982961497379810154498~2/4~e1

      0.5403023058681397174009366074429766037323104206179~0/3~

      -0.3019450507398802024611853185539984893647499733880~6/2~e1

      -0.252441295442368951995750696489089699886768918239~6/4~e1

      0.31227898756481033145214529184139729746320579069~1/3~e1

      -0.16634307959006696033484053579339956883955954978~3/1~e2
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      del sollya.settings.midpointmode
    <|unfolded-io>
      Traceback (most recent call last):

      NameError: name 'sollya' is not defined
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      l = autodiff(sin(x)/x, 0, Interval(-1,1))
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      l[0]
    <|unfolded-io>
      [-infty;infty]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      evaluate(sin(x)/x, Interval(-1,1))
    <|unfolded-io>
      [0.5403023058681397174009366074429766037323104206179;1]
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      settings.autosimplify = off
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      x - x
    <|unfolded-io>
      _x_ - _x_
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      settings.autosimplify = default
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      x - x
    <|unfolded-io>
      0
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      bashevaluate("echo hello")
    <|unfolded-io>
      hello
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      ceil(SollyaObject(77)/10)
    <|unfolded-io>
      8
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      chebyshevform(exp(x), 10, Interval(-1,1))[2]
    <|unfolded-io>
      [-2.71406412827174505775085010461449926572460824320373e-11;2.71406412827174505775085010461449926572460824320373e-11]
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      degree((1+x)*(2+5*x**2))
    <|unfolded-io>
      3
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      degree(sin(x))
    <|unfolded-io>
      -1
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      1 in Interval(0, 3)
    <|unfolded-io>
      True
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(1) \<less\> 3
    <|unfolded-io>
      True
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      min(exp(17), sin(62))
    <|unfolded-io>
      sin(62)
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      if nearestint(exp(1)) == 3: print "ok"
    <|unfolded-io>
      ok
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      [1, 2, 3] + SollyaObject([4])
    <|unfolded-io>
      [1, 2, 3, 4]
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject([1, Ellipsis])[17]
    <|unfolded-io>
      18
    </unfolded-io>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      SollyaObject(["a", Ellipsis])[42]
    <|unfolded-io>
      a
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      type(exp(1))
    <|unfolded-io>
      \<less\>type 'sollya.SollyaObject'\<gtr\>
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>

    <\unfolded-io>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|unfolded-io>
      fpminimax(exp(x), 5, [binary64]*6, Interval(-1,1))
    <|unfolded-io>
      8.0405088923770264702772792020368797238916158676147e-3 * _x_^5 +
      4.3646259245321651631943637994481832720339298248291e-2 * _x_^4 +
      0.16727425716485810891498431374202482402324676513672 * _x_^3 +
      0.49934185445721385177009210565302055329084396362305 * _x_^2 +
      0.99983695994996946154742545331828296184539794921875 * _x_ +
      1.00002756836036632570596793812001124024391174316406
    </unfolded-io>

    <\input>
      \<gtr\>\<gtr\>\<gtr\>\ 
    <|input>
      \;
    </input>
  </session>
</body>