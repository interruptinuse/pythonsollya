import sollya

sollya.execute("lib.sollya")

hello, incr, eval_at_one = [
        sollya.parse(name)
        for name in ["hello", "incr", "eval_at_one"]
]

print hello()
print incr(1)

def f(x):
    return incr(x)

# call a Sollya procedure that calls a Python function that calls another
# Sollya procedure
print eval_at_one(f)

# mutual recursion between a Sollya procedure and a Python function

def g(x):
    print "g(): called with x = {}".format(x)
    if x == 1:
        return 0
    else:
        return eval_at_one(g)

print g(2)
