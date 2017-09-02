r'''
Examples adapted from a talk by Christoph Lauter and Marc Mezzarobba
given at the Pequan seminar at LIP6 on 2016-01-18.

>>> import sollya

>>> dir(sollya) # doctest: +ELLIPSIS
['Interval', 'RD', 'RN', ...]

>>> sollya.SollyaObject(42) + 17
59

>>> type(_) # doctest: +ELLIPSIS
<... 'sollya.SollyaObject'>

>>> int(sollya.SollyaObject(42) + 17)
59

>>> sollya.sin(1)
sin(1)

>>> sys.displayhook = sollya.autoprint # doctest: +SKIP

>>> # because the doctest driver can't (afaik) catch what the message hook
>>> # outputs to stderr and pair it with the right input
>>> sollya.settings.verbosity = 0

>>> from sollya import *

>>> p = parse
>>> sin(Interval(p("0.1")))
[9.9833416646828152306814198410622026989915388017983e-2;9.9833416646828152306814198410622026989915388017986e-2]

>>> f = sin(1 + exp(sollya._x_))
>>> evaluate(f, 4)
-0.81371655140175448871553013334315708186522755964095

>>> f
sin(1 + exp(_x_))

>>> fp = diff(f)
>>> fp(0)
cos(2)

>>> g = sin(cos(x/3) - 1)
>>> g((2)**(parse("-3000"))).approx()
-3.6707390421142527733796653495536131777290030585503e-1808

>>> Interval(2, 3) + Interval(4, 5)
[6;8]

>>> sin(Interval(-3, 0.5))
[-1;0.4794255386042030002732879352155713880818033679406]

>>> f = x - sin(x)
>>> f(Interval(-2**(-5), 2**(-5)))
[-6.2494913985326078739581121257464464626078118798932e-2;6.2494913985326078739581121257464464626078118798932e-2]


>>> sollya.settings.prec
165

>>> f = sin(cos(x/3) - 1)
>>> f(1).approx()
-5.501526355908266391152772814019516251695908603806e-2

>>> with sollya.settings(prec=1000):
...     print(f(1).approx())
-5.501526355908266391152772814019516251695908603805905088725075252049985504528317579852395927511980192277611652640495829333507662997685389596204298153802812709307542580858728755496284042230877769757369477459165543247482676358999029132617139095509066958794105199781707261616997622409598671121861981853163e-2

>>> a = log2(17)/log2(13)
>>> b = log(17)/log(13)
>>> (a - b).approx()
0

>>> sollya.settings.display
decimal

>>> sollya.settings.display = binary
>>> SollyaObject(17.25)
1.000101_2 * 2^(4)

>>> del sollya.settings.display
>>> sollya.settings.display
decimal

>>> printdouble(17.25) # doctest: +SKIP
0x4031400000000000

>>> parse("0x3ff00000cafebabe")
1.00000075621544182169486703060101717710494995117187

>>> s = SollyaObject("Hello world")
>>> t = SollyaObject("Salut les copains")
>>> s
Hello world

>>> str(s) + " --- " + str(t)
'Hello world --- Salut les copains'

>>> str(s)[4]
'o'

>>> SollyaObject(True)
true

>>> if SollyaObject(True): print("a")
a

>>> if SollyaObject(False): print("b")

>>> exp(17) < 2**42
True

>>> 1 + x + x**2 == 1 + x + x**2
True

>>> SollyaObject("Salut") == "Salut", SollyaObject("Salut") == "Privet"
(True, False)

>>> l = SollyaObject([1, 2, 3, "Coucou", exp(x)])
>>> l
[|1, 2, 3, "Coucou", exp(_x_)|]

>>> [sin(x) + 1] + l
[sin(_x_) + 1, 1, 2, 3, Coucou, exp(_x_)]

>>> tail(l)
[|2, 3, "Coucou", exp(_x_)|]

>>> l[3]
Coucou

>>> #l[3] = "Fromage"

>>> SollyaObject(range(1, 18))
[|1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17|]

>>> l = SollyaObject(["Salut", exp(x), 17, True, nearestint(exp(5)), Ellipsis])
>>> l[1520]
1664

>>> a = SollyaObject({
...    "f": exp(x),
...    "I": Interval(-1, 1)
... })
>>> sorted(a)
[('I', [-1;1]), ('f', exp(_x_))]


>>> a.struct.f
exp(_x_)

>>> a.struct.I = Interval(-2, 2)
>>> a.struct.accuracy = 2**-45
>>> sorted(a)
[('I', [-2;2]), ('accuracy', 2.8421709430404007434844970703125e-14), ('f', exp(_x_))]

>>> sorted(dict(a).items())
[('I', [-2;2]), ('accuracy', 2.8421709430404007434844970703125e-14), ('f', exp(_x_))]

>>> succ = parse("proc(i) { return i+1; };")
>>> succ(1)
2

>>> succ
proc(i)
{
nop;
return (i) + (1);
}

>>> eval_at_one = parse("""
...   proc(fun) {
...       return fun(1);
...   };
... """)

>>> def myfun(x):    return 2*x

>>> eval_at_one(myfun)
2

>>> obj = exp(x)

>>> obj.is_list()
False

>>> obj.is_function()
True

>>> obj.operator()
EXP

>>> obj.arity()
1

>>> obj.operands()
[_x_]

>>> def mymatcher(expr):
...    op = expr.operator()
...    if op == SollyaOperator('EXP'):
...        return 1
...    elif op == SollyaOperator('SIN'):
...        return 2
...    else:
...        return 3

>>> mymatcher(exp(x)), mymatcher(sin(x))
(1, 2)

>>> def transform(expr):
...    op = expr.operator()
...    return op(*[sin(a) for a in expr.operands()])

>>> transform(x + exp(x))
sin(_x_) + sin(exp(_x_))

>>> f = sin(cos(x/3) - 1)
>>> I = Interval(-1/4, 1/4)
>>> plot(f, I) # doctest: +SKIP

>>> p = remez(f, 5, I)
>>> delta = p - f
>>> plot(p - f, I) # doctest: +SKIP

>>> remez? # doctest: +SKIP

>>> def mypi(prec): return 3
>>> foo = libraryconstant(mypi)
>>> foo
py_mypi

>>> foo.approx()
3
'''

if __name__ == "__main__":
    import doctest
    doctest.testmod(optionflags=doctest.NORMALIZE_WHITESPACE)