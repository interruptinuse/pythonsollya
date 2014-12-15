# -*- coding: utf-8 -*-

import string
import sys

class Callable:
    def __init__(self, anycallable):
        self.__call__ = anycallable

function_template = lambda func, sollya_func: """PyObject* python_PSI_%s(PyObject* self, PyObject* args) {
    PyObject* argument;
    PyArg_ParseTuple(args, "O", &argument);

    sollya_obj_t function_arg = buildOperandFromPyObject(argument);

    /** if argument could not be converted, NULL must be returned */
    if (function_arg == NULL) return NULL;

    python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_type.tp_new(&python_sollyaObject_type, NULL, NULL);
    //pso->sollya_object = POURCENTs(function_arg);
    attachSollyaObject(pso,  %s(function_arg));

    return (PyObject*) pso;
}""" % (func, sollya_func)
header_template = lambda func: "PyObject* python_PSI_%s(PyObject* self, PyObject* args);\n" % func

class Args:      pass
class Function:  pass
class Integer:   pass
class Constant:  pass
class Name:      pass
class Doc:       pass
class Mandatory: pass
class Optionnal: pass
class List:      pass
class Object:    pass
class Range:     pass
class Integer:   pass
class String:    pass

class Return: pass
class IntToBool: pass
class Void: pass

arg_dict = {
    Function: "function", 
    Integer: "int", 
    Constant: "constant",
    List: "list", 
    Range: "range",
    String: "string",
    Object: "object",
}


general_function = {
    "taylor" : {Args: [{Mandatory: [Function, Integer, Constant], Optionnal : []}], Name: "sollya_lib_taylor"},
    "fpminimax" : {
        Args: [
        {Mandatory: [Function, [Integer, List], List, [Range]], Optionnal : [Object, Object, Object, Function]}],
        Name: "sollya_lib_fpminimax"
    },
    "autodiff" : {
        Args: [
            {Mandatory: [Function, Integer, [Constant, Range]], Optionnal: []}
        ],
        Name: "sollya_lib_autodiff",
    },
    "checkinfnorm" : {
        Args: [
            {Mandatory: [Function, Range, Constant], Optionnal: []}
        ],
        Name: "sollya_lib_checkinfnorm",
    },
    "coeff" : {
        Args: [
            {Mandatory: [Function, Integer], Optionnal: []},
        ],
        Name: "sollya_lib_coeff",
    },
    "composepolynomials" : {
        Args: [
            {Mandatory: [Function, Function], Optionnal: []},
        ],
        Name: "sollya_lib_composepolynomials",
    },
    "denominator": {
        Args: [
            {Mandatory: [Function], Optionnal: []},
        ],
        Name: "sollya_lib_denominator",
    },
    "degree": {
        Args: [
            {Mandatory: [Function], Optionnal: []},
        ],
        Name: "sollya_lib_degree",
    },
    "diff": {
        Args: [
            {Mandatory: [Function], Optionnal: []},
        ],
        Name: "sollya_lib_diff",
    },
    "dirtyfindzeros": {
        Args: [ 
            {Mandatory: [Function, Range], Optionnal: []},
        ],
        Name: "sollya_lib_dirtyfindzeros",
    },
    "dirtyinfnorm": {
        Args: [
            {Mandatory: [Function, Range], Optionnal: []},
        ],
        Name: "sollya_lib_dirtyinfnorm",
    },
    "dirtyintegral": {
        Args: [
            {Mandatory: [Function, Range], Optionnal: []},
        ],
        Name: "sollya_lib_dirtyintegral",
    },
    "evaluate": {   Args: [{Mandatory: [Function, [Range, Constant, Function]], Optionnal: []},],
        Name: "sollya_lib_evaluate",
    },
    "execute": {
        Args: [{Mandatory: [String], Optionnal: []},],
        Name: "sollya_lib_execute",
        Return: Void,
    },
    "expand": { Args: [{Mandatory: [Function], Optionnal: []},],
        Name: "sollya_lib_expand",
    },
    "exponent": {   Args: [{Mandatory: [Object], Optionnal: []},],
        Name: "sollya_lib_exponent",
    },
    "findzeros": {  Args: [{Mandatory: [Function, Range], Optionnal: []},],
        Name: "sollya_lib_findzeros",
    },
    "guessdegree": {    Args: [{Mandatory: [Function, Range, Constant], Optionnal: [Function, Constant]},],
        Name: "sollya_lib_guessdegree",
        Doc: "guessdegree(function, interval, maximal acceptable error, [weight function, bound])",
    },
    "horner": { Args: [{Mandatory: [Function], Optionnal: []},],
        Name: "sollya_lib_horner",
    },
    "infnorm": {    Args: [{Mandatory: [Function, Range], Optionnal: [Object, Object]},],
        Name: "sollya_lib_infnorm",
    },
    "integral": {   Args: [{Mandatory: [Function, Range], Optionnal: []},],
        Name: "sollya_lib_integral",
    },
    "round": {
        Args: [{Mandatory: [Constant, Integer, Object], Optionnal: []},],
        Name: "sollya_lib_round",
    },
    "roundcoefficients": {
        Args: [
            {Mandatory: [Function, List], Optionnal: []},
        ],
        Name: "sollya_lib_roundcoefficients",
    },
    "supnorm": {    Args: [{Mandatory: [Function, Function, Range, Object, Object], Optionnal: []},],
        Name: "sollya_lib_supnorm",
        Doc: "supnorm(polynomial, function, interval, error: absolute | relative, interval tightness)"
    },
    "inf": {    Args: [{Mandatory: [[Range, Object]], Optionnal: []},],
        Name: "sollya_lib_inf",
    },
    "mid": {    Args: [{Mandatory: [[Range, Object]], Optionnal: []},],
        Name: "sollya_lib_mid",
    },
    "sup": {    Args: [{Mandatory: [[Range, Object]], Optionnal: []},],
        Name: "sollya_lib_sup",
    },
    "PSI_is_range": { Args: [{Mandatory: [[Object]], Optionnal: []},], 
        Name: "sollya_lib_obj_is_range",
        Return: IntToBool,
    },
}

type_check = {
    Integer : None, # lambda var: "PyInt_Check(%s) || " % var,
    Constant : None,
    Function : None,
    Object : None,
    String: None,
    List : lambda var: "PSI_checkSollyaListCompatibility(%s)" % var,
    Range : lambda var: "PSI_checkSollyaIntervalCompatibility(%s)" % var,
}

operand_formation = {
    Integer : lambda var: "buildOperandFromPyObject(%s)" % var,
    Constant : lambda var: "buildOperandFromPyObject(%s)" % var,
    Function : lambda var: "buildOperandFromPyObject(%s)" % var,
    Object : lambda var: "buildOperandFromPyObject(%s)" % var,
    Range : lambda var: "buildIntervalFromPyObject(%s)" % var,
    List : lambda var: "buildSollyaListFromPyObject(%s)" % var,
    String : lambda var: "buildSollyaStringFromPyObject(%s)" % var,
}

tab = "    "


def generateTypeCode(var, exp_type, output, mandatory = True, function_name = ""):
    #code = "sollya_obj_t %s;\n" % output
    pre_sorted_type = [type_check[st] for st in exp_type]
    sorted_type = []
    hasNone = False
    for t in pre_sorted_type:
        if t != None:
            sorted_type.append(t)
        else:
            hasNone = True
    
    if hasNone:
        sorted_type.append(None)

    test_code = []
    test_tail = []
        
    for sub_type in exp_type:
        type_check_macro = type_check[sub_type]
        if type_check_macro == None:
            test_tail = [(None, operand_formation[sub_type](var), var)]
            # TODO : case with multiple None and distinct operand_formation
        else:
            test_code.append((type_check_macro(var), operand_formation[sub_type](var), var))
    test_code = test_code + test_tail
    code = "" 
    # optionnal argument case
    test_number = len(test_code)
    firstTest = True
    if not mandatory: 
        code += tab + "if (%s == NULL) {\n" % var
        code += tab * 2 + "%s = NULL;\n" % output
        code += tab + "}"
        firstTest = False
    else:
        # mandatory argument
        code += tab + "if (%s == NULL) {\n" % var
        code += tab * 2 + " cerr << \"ERROR: missing argument %s from %s.\" << endl;\n" % (var, function_name)
        #code += tab * 2 + " PyObject* PSI_missingArg = PyErr_NewException(\"PythonSollyaInterface.MissingArg\", NULL, NULL);\n"
        code += tab * 2 + " PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_MissingArg_str, NULL, NULL);\n"
        code += tab * 2 + " PyErr_SetString(PSI_missingArg, \"missing argument %s in call to %s\");\n" % (var, function_name)
        code += tab * 2 + " return NULL;\n"
        code += tab + "}"
        firstTest = False
    onlyNoneTest = True
    oneNoneTest = False
    while test_code != []:
        local_test, local_operand, var = test_code.pop(0)
        if local_test == None:
            if len(test_code) > 0: raise Exception("more than one non-checking type")
            code += tab + "{\n" if firstTest else " else {\n"
            oneNoneTest = True
        else:
            code += tab + "if (" if firstTest else " else if("
            code += local_test + ") {\n"
            onlyNoneTest = False
        code += tab * 2 + output + " = " + local_operand + ";\n"
        code += tab * 2 + "if (%s != NULL && %s == NULL) return NULL;\n" % (var, output)
        code += tab + "}"
        firstTest = False
    if not onlyNoneTest and not oneNoneTest:
        code += " else {\n"
        code += tab * 2 + "cerr << \"unknown type for arg %s of %s\" << endl;\n" % (var, function_name)
        code += tab * 2 + " PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_TypeErrorArg_str, NULL, NULL);\n"
        code += tab * 2 + " PyErr_SetString(PSI_missingArg, \"wrong argument type for %s in call to %s\");\n" % (var, function_name)
        code += tab * 2 + " return NULL;\n"
        code += tab + "}"
    code += ";\n"
    return code

def zipIndex(list_, offset = 0):
    return zip(list_, range(offset, offset + len(list_)))
    

def generateGenFunction(function_name):
    function_desc = general_function[function_name]
    sollya_name = function_desc[Name]
    code = "PyObject* python_PSI_%s(PyObject* self, PyObject* args) {\n" % function_name
    header_code = "PyObject* python_PSI_%s(PyObject* self, PyObject* args);\n" % function_name
    
    # arg count
    arg_count = 0
    min_mandatory_count = -1
    for arg_template in function_desc[Args]:
        mandatory_count = len(arg_template[Mandatory])
        min_mandatory_count = mandatory_count if min_mandatory_count < 0 or min_mandatory_count > mandatory_count else min_mandatory_count
        optionnal_count = len(arg_template[Optionnal])
        arg_count = max(mandatory_count + optionnal_count, arg_count)

    # arg definition code
    code += tab + "PyObject* py_arg0 = NULL"
    for i in range(1, arg_count):
        code += ", *py_arg%d = NULL" % i
    code += ";\n\n"

    # python argument parsing"
    code += tab + "PyArg_ParseTuple(args, \"" + "O" * min_mandatory_count + "|" + "O" * (arg_count - min_mandatory_count) + "\"" + string.join([" , &py_arg%d" % i for i in xrange(arg_count)]) + ");\n\n"  

    # arg definition code
    code += (tab + "sollya_obj_t sollya_arg0 = NULL") if arg_count > 0 else ""
    for i in range(1, arg_count):
        code += ", sollya_arg%d = NULL" % i
    code += ";\n\n"

    # mandatory arguments
    for pre_arg_types,i in zipIndex(function_desc[Args][0][Mandatory]):
        var = "py_arg%d" % i
        output_var = "sollya_arg%d" % i
        arg_types = pre_arg_types if type(pre_arg_types) is list else [pre_arg_types]
        code += generateTypeCode(var, arg_types, output_var, function_name = function_name)
    # optionnal arguments
    for pre_arg_types,i in zipIndex(function_desc[Args][0][Optionnal], offset = len(function_desc[Args][0][Mandatory])):
        var = "py_arg%d" % i
        output_var = "sollya_arg%d" % i
        arg_types = pre_arg_types if type(pre_arg_types) is list else [pre_arg_types]
        code += generateTypeCode(var, arg_types, output_var, mandatory = False, function_name = function_name)

    tab2 = tab + tab

    # sollya function_call
    # result object
    if not Return in function_desc:
        code += tab + "// sollya function call\n"
        code += tab + "sollya_obj_t result;\n"
        code += tab + "try {\n"
        code += tab2 + "result = %s(" % sollya_name
        code += "sollya_arg0" if arg_count > 0 else ""
        for i in range(1, arg_count):
            code += " ,sollya_arg%d" % i
        code += ");\n"
        code += tab2 + "python_sollyaObject* pso = (python_sollyaObject*) python_sollyaObject_type.tp_new(&python_sollyaObject_type, NULL, NULL);\n"
        code += tab2 + "//pso->sollya_object = result;\n\n"
        code += tab2 + "attachSollyaObject(pso,  result);\n\n"
        code += tab2 + "return (PyObject*) pso;\n" 
    elif function_desc[Return] == IntToBool:
        code += tab + "// sollya function call\n"
        code += tab + "int result;\n"
        code += tab + "try {\n"
        code += tab2 + "result = %s(" % sollya_name
        code += "sollya_arg0" if arg_count > 0 else ""
        for i in range(1, arg_count):
            code += " ,sollya_arg%d" % i
        code += ");\n"
        code += tab2 + "if (result) Py_RETURN_TRUE;\n"
        code += tab2 + "else Py_RETURN_FALSE;\n"
    elif function_desc[Return] == Void:
        code += tab + "// sollya function call\n"
        code += tab + "try {\n"
        code += tab2 + "%s(" % sollya_name
        code += "sollya_arg0" if arg_count > 0 else ""
        for i in range(1, arg_count):
            code += " ,sollya_arg%d" % i
        code += ");\n"
        code += tab2 + "Py_INCREF(Py_None);"
        code += tab2 + "return Py_None;"

    code += tab + "} catch (int &excp) {\n"
    code += tab2 + "cout << \"Signal exception raised: \" << excp << endl;\n" 
    # code += tab2 + "signal(SIGSEGV, metalibm_catch_signal);\n"
    code += tab2 + "return NULL;\n"
    code += tab + "};\n\n"

    # clearing temporary sollya object
    code += tab + "// clearing temporary sollya objects\n"
    for i in range(0, arg_count):
        code += tab + "if (sollya_arg%d) sollya_lib_clear_obj(sollya_arg%d);\n" % (i, i)
    code += "\n" 


    # function closure
    code += "}\n"
    return header_code, code

def generateFunctionDoc(function_name):
    function_desc = general_function[function_name]

    function_line = tab + "{\"%s\", python_PSI_%s" % (function_name, function_name)
    function_line += ", METH_VARARGS, \" call to sollya function %s(" % general_function[function_name][Name]

    def addArgs(arg):
        local_code = ""
        if type(arg) is list:   
            local_code += "{" + arg_dict[arg[0]]
            for sub_arg in arg[1:]:
                local_code += "|" + arg_dict[sub_arg]
            local_code += "}"
        else:
            local_code += arg_dict[arg]
        return local_code

    if len(function_desc[Args][0][Mandatory]) > 0:
        function_line += addArgs(function_desc[Args][0][Mandatory][0])
        for arg in function_desc[Args][0][Mandatory][1:]:
            function_line += ","
            function_line += addArgs(arg)

    if len(function_desc[Args][0][Mandatory]) > 1:
        function_line += ","

    if len(function_desc[Args][0][Optionnal]) > 0:
        function_line += "["
        function_line += addArgs(function_desc[Args][0][Optionnal][0])

        for arg in function_desc[Args][0][Optionnal][1:]:
            function_line += ","
            function_line += addArgs(arg)

        function_line += "]"

    function_line += ")"
    if Doc in general_function[function_name]:
        function_line += "\\n"
        function_line += general_function[function_name][Doc]
    function_line += "\"},\n"
    return function_line

class ElementaryFunctions:

    # function_name: sollya lib function
    function_table = {
        "sqrt"  : "SLBF_%s",
        "abs"   : "SLBF_%s",

        "erf"   : "SLBF_%s",
        "erfc"  : "SLBF_%s",
        "exp"   : "SLBF_%s",
        "expm1" : "SLBF_%s",
        "log"   : "SLBF_%s",
        "log2"  : "SLBF_%s",
        "log10" : "SLBF_%s",
        "log1p" : "SLBF_%s",

        "sin"   : "SLBF_%s",
        "cos"   : "SLBF_%s",
        "tan"   : "SLBF_%s",
        "asin"  : "SLBF_%s",
        "acos"  : "SLBF_%s",
        "atan"  : "SLBF_%s",
        "sinh"  : "SLBF_%s",
        "cosh"  : "SLBF_%s",
        "tanh"  : "SLBF_%s",
        "asinh" : "SLBF_%s",
        "acosh" : "SLBF_%s",
        "atanh" : "SLBF_%s",

        "ceil" : "SL_%s",
        "floor" : "SL_%s",
        "nearestint" : "SL_%s",

        "double" : ["SL_%s", ["D"]],
        "single" : ["SL_%s", ["SG"]],
        "quad" : ["SL_%s", ["QD"]],
        "halfprecision" : ["SL_%s", ["HP"]],
        "doubledouble" : ["SL_double_double", ["DD"]],
        "tripledouble" : ["SL_triple_double", ["TD"]],
        "doubleextended" : ["SL_%s", ["DE"]],
    }

    def generateEltFuncWrapper(filename):
        f = open(filename, "w")
        f_header = open(filename.replace(".cpp", ".hpp"), "w")
        f_def = open(filename.replace(".cpp", ".method_def"), "w")

        f_header.write("#include <Python.h>\n")
        f_header.write("#include \"PythonSollyaObject.hpp\"\n")
        f.write("#include \"PythonSollyaInterface_functions.hpp\" \n\n\n")
        f.write("#include \"utils.hpp\" \n\n\n")
        f.write("#include <iostream> \n\n\n")
        f.write("#include <sollya.h> \n\n\n")
        f.write("using namespace std;\n\n")

        for function_name in ElementaryFunctions.function_table:
            pre_sollya_function = ElementaryFunctions.function_table[function_name]
            sollya_function = None
            if type(pre_sollya_function) is list:
                sollya_function = pre_sollya_function[0]
            else:
                sollya_function = pre_sollya_function
                
            f.write("// function %s generated by automatic wrapper\n" % function_name)
            if "SLBF" in sollya_function:
                sollya_function = sollya_function.replace("SLBF", "sollya_lib_build_function")
            if "SL" in sollya_function:
                sollya_function = sollya_function.replace("SL", "sollya_lib")
            if "%s" in sollya_function:
                sollya_function = sollya_function % function_name

            f.write(function_template(function_name, sollya_function)) 
            f_header.write(header_template(function_name))

            alias_list = [function_name]
            if type(pre_sollya_function) is list:
                alias_list += pre_sollya_function[1]
            for alias in alias_list:
                f_def.write("     {\"%s\", python_PSI_%s, METH_VARARGS, \"%s(x): call to sollya function %s on x\"},\n" % (alias, function_name, function_name, sollya_function))
            f.write("\n\n")

        f.close()
        f_header.close()
        f_def.close()

    generateEltFuncWrapper = Callable(generateEltFuncWrapper)

def main(file_to_generate):
    if "PythonSollyaInterface_gen_functions.cpp" in file_to_generate:

        function_file = open(file_to_generate, "w")
        header_file = open(file_to_generate.replace(".cpp", ".hpp"), "w")

        header_file.write("#include <Python.h>\n")
        header_file.write("#include \"PythonSollyaObject.hpp\"\n")
        function_file.write("#include \"PythonSollyaInterface_gen_functions.hpp\"\n")
        function_file.write("#include <iostream>\n")
        function_file.write("#include <sollya.h> \n\n\n")
        function_file.write("#include \"utils.hpp\" \n\n\n")
        function_file.write("using namespace std;\n\n")

        for function in general_function:
            header_code, function_code = generateGenFunction(function)
            function_file.write(function_code)          
            header_file.write(header_code)
        function_file.close()
        header_file.close()
        def_file = open(file_to_generate.replace(".cpp", ".method_def"), "w")
        for function in general_function:
            def_file.write(generateFunctionDoc(function))
        def_file.close()
    elif "PythonSollyaInterface_functions.cpp" in file_to_generate:
        ElementaryFunctions.generateEltFuncWrapper(file_to_generate)
    else:
        header_code, function_code = generateGenFunction(sys.argv[1])
        print function_code


if __name__ == "__main__":
    file_to_generate = sys.argv[1]
    main(file_to_generate)
