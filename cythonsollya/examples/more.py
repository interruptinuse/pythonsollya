# coding: utf-8
r"""
>>> import sollya
>>> from sollya import *

>>> SollyaObject(1.5) + SollyaObject(2) + 3
6.5

>>> SollyaObject(True), SollyaObject(False)
(true, false)

>>> SollyaObject(None)
void

>>> SollyaObject("hello"), SollyaObject(u"world!")
(hello, world!)

>>> SollyaObject([])
[| |]

>>> SollyaObject([1, Ellipsis])
[|1...|]

>>> SollyaObject({"field": "value", "other_field": 42})
{ .field = "value", .other_field = 42 }

>>> SollyaObject(lambda x: x+1)(16)
17

>>> SollyaObject(SollyaObject(1))
1

>>> SollyaObject(True) and False
False

>>> SollyaObject([1, x]) + [sin(x)]
[1, _x_, sin(_x_)]

>>> exp(1)
exp(1)

>>> exp(1).approx()
2.7182818284590452353602874713526624977572470937

>>> l = autodiff(exp(cos(x))+sin(exp(x)), 5, 0)

>>> settings.midpointmode = on

>>> for f in l: print f
0.3559752813266941742012789792982961497379810154498~2/4~e1
0.5403023058681397174009366074429766037323104206179~0/3~
-0.3019450507398802024611853185539984893647499733880~6/2~e1
-0.252441295442368951995750696489089699886768918239~6/4~e1
0.31227898756481033145214529184139729746320579069~1/3~e1
-0.16634307959006696033484053579339956883955954978~3/1~e2

>>> del sollya.settings.midpointmode

>>> l = autodiff(sin(x)/x, 0, Interval(-1,1))

>>> l[0]
[-infty;infty]

>>> evaluate(sin(x)/x, Interval(-1,1))
[0.5403023058681397174009366074429766037323104206179;1]

>>> settings.autosimplify = off

>>> x - x
_x_ - _x_

>>> settings.autosimplify = default

>>> x - x
0

>>> bashevaluate("echo hello")
hello

>>> ceil(SollyaObject(77)/10)
8

>>> chebyshevform(exp(x), 10, Interval(-1,1))[2]
[-2.71406412827174505775085010461449926572460824320373e-11;2.71406412827174505775085010461449926572460824320373e-11]

>>> degree((1+x)*(2+5*x**2))
3

>>> degree(sin(x))
-1

>>> 1 in Interval(0, 3)
True

>>> SollyaObject(1) < 3
True

>>> min(exp(17), sin(62))
sin(62)

>>> if nearestint(exp(1)) == 3: print "ok"
ok

>>> [1, 2, 3] + SollyaObject([4])
[1, 2, 3, 4]

>>> SollyaObject([1, Ellipsis])[17]
18

>>> SollyaObject(["a", Ellipsis])[42]
a

>>> type(exp(1))
<type 'sollya.SollyaObject'>

>>> fpminimax(exp(x), 5, [binary64]*6, Interval(-1,1))
8.0405088923770264702772792020368797238916158676147e-3 * _x_^5 + 4.3646259245321651631943637994481832720339298248291e-2 * _x_^4 + 0.16727425716485810891498431374202482402324676513672 * _x_^3 + 0.49934185445721385177009210565302055329084396362305 * _x_^2 + 0.99983695994996946154742545331828296184539794921875 * _x_ + 1.00002756836036632570596793812001124024391174316406
"""

if __name__ == "__main__":
    import doctest
    doctest.testmod()
