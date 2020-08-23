


procedure callPythonFunction(f, f0, b)
{
    var i, acc;
    i = 0;
    acc = 0;
    while (i < 10) do {
        acc = acc + f(f0(i));
        i = i + 1;
    };
    return acc;
};
