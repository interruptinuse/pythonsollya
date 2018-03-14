r"""
>>> import sollya

>>> sollya.execute("examples/lib.sollya")
>>> hello, incr, eval_at_one = [
...         sollya.parse(name)
...         for name in ["hello", "incr", "eval_at_one"]
... ]

>>> hello()
hello from a Sollya procedure!

>>> incr(1)
2

>>> def f(x):
...     return incr(x)

We call a Sollya procedure that calls a Python function that calls another
Sollya procedure:

>>> eval_at_one(f)
2

Mutual recursion between a Sollya procedure and a Python function:

>>> def g(x):
...     print "g(): called with x = {}".format(x)
...     if x == 1:
...         return 0
...     else:
...         return eval_at_one(g)
>>> g(2)
g(): called with x = 2
g(): called with x = 1
0
"""
