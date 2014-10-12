/*****************************************************************************
 * This file is part of the metalibm proof of concept project
 *
 * copyrights : Nicolas Brunie, Florent de Dinechin (2012) 
 * All rights reserved
 *****************************************************************************
 * This particular file should be included in 
 * the PythonSollyaInterface.cpp file 
 *****************************************************************************/

//#include "PythonSollyaObject.hpp"
#include "python_sollyaObject_struct.h"
#include "utils.hpp"
#include "stdint.h"
#include "inttypes.h"
#include "signal.h"
#include "limits.h"
#include <iostream>

using namespace std;


#define INVALID_OP(TEST) if (TEST) {\
        PyObject* py_result = Py_None;\
        Py_INCREF(py_result);\
        return py_result;\
    }

void metalibm_catch_signal(int signalNumber)
{
	cout << "handling signal SIGSEGV" << endl;
    signal(SIGSEGV, metalibm_catch_signal);
	throw(signalNumber);
}

/*****************************************************************************/

 PyObject* python_sollyaObject_degree_get(python_sollyaObject* self, PyObject* args) {
	int result;

	sollya_obj_t sollya_degree = sollya_lib_degree(self->sollya_object);

	// transforming sollya int to python int
	sollya_lib_get_constant_as_int(&result, sollya_degree);

	return PyInt_FromLong(result);
}

 PyGetSetDef python_sollyaObject_getsets[] = {
	{PSI_StringConstants::PSI_degree, (getter) python_sollyaObject_degree_get, (setter) NULL, PyDoc_STR(PSI_StringConstants::PSI_degree_doc)},
	{0}
};

void attachSollyaObject(python_sollyaObject* self_object, sollya_obj_t object) {
	self_object->sollya_object = object;

	/* cout << "attaching O(" << self_object->id << ") " << endl;
	{

		sollya_lib_printf("%b \n", self_object->sollya_object);
	};*/

	return;
}

void attachSollyaPyObject(PyObject* self, sollya_obj_t object) {
	python_sollyaObject* self_object = (python_sollyaObject*) self;
	attachSollyaObject(self_object, object);
}


PyObject* python_sollyaObject_new(PyTypeObject *type, PyObject *args, PyObject *kwds)
{
    python_sollyaObject* self;
    self = (python_sollyaObject*) type->tp_alloc(type, 0);

	static int object_counter = -1;
	object_counter++;
	self->id = object_counter;

	Py_INCREF((PyObject*) self);
  
    return (PyObject*) self;
}

PyObject* python_sollyaObject_coeff(python_sollyaObject* self, PyObject* args) {
	int coeff_index;

	// parsing arg to extract coefficient index
	PyArg_ParseTuple(args, "i", &coeff_index);
	sollya_obj_t coeff_obj, coeff_index_obj;
	coeff_index_obj = sollya_lib_constant_from_int(coeff_index);
	
	coeff_obj = sollya_lib_coeff(self->sollya_object, coeff_index_obj);

	// clearing temporary object
	sollya_lib_clear_obj(coeff_index_obj);

	python_sollyaObject* pso = (python_sollyaObject*) python_sollyaObject_new(self->ob_type, NULL, NULL);
	attachSollyaObject(pso, coeff_obj);

	return (PyObject*) pso;
}

 PyObject* python_sollyaObject_getConstantAsDouble(python_sollyaObject* self, PyObject* args) {
	double result;
	int status = sollya_lib_get_constant_as_double(&result, self->sollya_object);
	return PyFloat_FromDouble(result);
}

 PyObject* python_sollyaObject_getConstantAsInt(python_sollyaObject* self, PyObject* args) {
	int64_t result;
	int status = sollya_lib_get_constant_as_int64(&result, self->sollya_object);
	return PyInt_FromLong(result);
}


PyObject* python_sollyaObject_div(python_sollyaObject* self, PyObject* args) {
	PyObject* argument;
	PyArg_ParseTuple(args, "O", &argument);
	sollya_obj_t div_arg;

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(self->ob_type, NULL, NULL);

	if (PyObject_TypeCheck(argument, self->ob_type)) {
		div_arg = ((python_sollyaObject*) argument)->sollya_object;
	} else {
		double value = PyFloat_AsDouble(argument);
		div_arg = sollya_lib_constant_from_double(value);
	}

	//attachSollyaObject(pso, sollya_lib_build_function_div(self->sollya_object, div_arg));
	attachSollyaObject(pso, sollya_lib_build_function_div(self->sollya_object, div_arg));

	return (PyObject*) pso;
}

PyObject* python_sollyaObject_interval(PyObject* self, PyObject* args) {
	// extracting PyObject bound arguments
	PyObject *py_left_bound, *py_right_bound;
	PyArg_ParseTuple(args, "OO", &py_left_bound, &py_right_bound);

	// buillding sollya object from PyObject
	sollya_obj_t sol_left_bound = buildOperandFromPyObject(py_left_bound);
	sollya_obj_t sol_right_bound = buildOperandFromPyObject(py_right_bound);

    INVALID_OP(!sol_right_bound || !sol_left_bound)

	// building sollya interval from bounds
	sollya_obj_t sol_interval = sollya_lib_range(sol_left_bound, sol_right_bound);

	// creating new PythonSollyaObject and attaching interval to it
	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new((PyTypeObject*) self, NULL, NULL);
	attachSollyaObject(pso, sol_interval);

	return (PyObject*) pso;
}

PyObject* python_sollyaObject_test_nan(PyObject* a) {
    sollya_obj_t obj_a = buildOperandFromPyObject(a);

    INVALID_OP(!obj_a)

    PyObject* py_result = Py_None;

    if (sollya_lib_is_true(sollya_lib_cmp_equal(obj_a, obj_a))) {
        py_result = Py_False;
    } else {
        py_result = Py_True;
    };

    Py_INCREF(py_result);
    return py_result;
}

PyMethodDef python_sollyaObject_methods[] = {
   {"Interval", (PyCFunction) python_sollyaObject_interval, METH_CLASS, PyDoc_STR("PythonSollyaObject.Interval(a, b) : return sollya interval [a, b]")},
//	{"coeff", (PyCFunction) python_sollyaObject_coeff, METH_VARARGS, PyDoc_STR("self.coeff(index) : return the polynomial coefficient number index of the self polynomial ")},
	{"getConstantAsDouble", (PyCFunction) python_sollyaObject_getConstantAsDouble, METH_VARARGS, PyDoc_STR("self.getConstantAsDouble(): evaluate self as a constant expression and return its value as a double")},
	{"getConstantAsInt", (PyCFunction) python_sollyaObject_getConstantAsInt, METH_VARARGS, PyDoc_STR("self.getConstantAsInt() : evaluate self as a constant expression and return the result as an integer")},
	{"test_NaN", (PyCFunction) python_sollyaObject_test_nan, METH_VARARGS, PyDoc_STR("self.test_NaN() : test wether self is a NaN")},
	{"__div__", (PyCFunction) python_sollyaObject_div, METH_VARARGS, PyDoc_STR("self.__div__(x) <==> self / x")},
	{NULL, NULL},
};


int python_sollyaObject_init(PyObject* self, PyObject* args) { //, PyObject* kwds) {
	PyObject* sollya_object = NULL;
	PyArg_ParseTuple(args, "|O", &sollya_object);
	if (sollya_object != NULL) {
		((python_sollyaObject*) self)->sollya_object = buildOperandFromPyObject(sollya_object);
	} else {
		((python_sollyaObject*) self)->sollya_object = NULL;
	}
	/* cout << "initializing O(" << ((python_sollyaObject*) self)->id << ") " << endl;
	{
		python_sollyaObject* object = (python_sollyaObject*) self;

		sollya_lib_printf("%b \n", object->sollya_object);
	};*/
	return 0;
};


int python_sollyaObject_print(PyObject* self,FILE* fp, int flags){ 
	/** SollyaObject print function */
	python_sollyaObject* object = (python_sollyaObject*) self;

	sollya_lib_fprintf(fp, "%b", object->sollya_object);
	return 0;
}

int silent_callback(sollya_msg_t msg, void* _) {
    return 0;
}

PyObject* python_sollyaObject_str(PyObject* self) {
	// arg: sollya_obj_t foo
	sollya_obj_t foo = ((python_sollyaObject*) self)->sollya_object;
    sollya_obj_t a,b,c;
    int n;
    char *s;
    //int (*)(sollya_msg_t, void*) current_callback;

    //current_callback = sollya_lib_get_msg_callback();
    sollya_lib_install_msg_callback(silent_callback, NULL);
    a = sollya_lib_string(PSI_StringConstants::PSI_empty_string);
    b = sollya_lib_concat(a, foo); // possible arrondi et warning
    //c = sollya_length(b);
    //sollya_lib_get_constant_as_int(&n, c);
    //s = calloc(n+1, sizeof(char));
    sollya_lib_get_string(&s, b);
    sollya_lib_clear_obj(a);
    sollya_lib_clear_obj(b);
    //sollya_lib_clear_obj(c);
    sollya_lib_uninstall_msg_callback();
	//    if (current_callback)
	//        sollya_lib_install_msg_callback(current_callback, NULL);
    return PyString_FromString(s);
}

PyObject* python_sollyaObject_call(PyObject* self, PyObject* args, PyObject* kwargs) {
	python_sollyaObject* object = (python_sollyaObject*) self;
	sollya_obj_t sollya_object = object->sollya_object;

	PyObject* py_arg;
	PyArg_ParseTuple(args, "O", &py_arg);
	sollya_obj_t sollya_arg = buildOperandFromPyObject(py_arg);

    INVALID_OP(!sollya_arg)

	sollya_obj_t result = NULL;

	if (sollya_lib_obj_is_function(sollya_object)) {
		result = sollya_lib_apply(sollya_object, sollya_arg, NULL);
	} else {
		cerr << "only sollya function can be applied ! " << endl;
	}
	if (result) {
		python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(self->ob_type, NULL, NULL);
		//attachSollyaObject(pso, result);
		attachSollyaObject(pso, result);
		return (PyObject*) pso;
	} 

	return NULL;
}

void python_sollyaObject_dealloc(python_sollyaObject* self) {
	if ((PyObject*) self == Py_None) {
		cout << "trying to deallocate None." << endl;
	}
	cout << "deallocating O(" << self->id << ")" << endl;
	// if sollya object exists, clear it
	if (self->sollya_object != NULL) sollya_lib_clear_obj(self->sollya_object);

	
	// python object deallocation
	self->ob_type->tp_free((PyObject*) self);

	cout << "deallocating done" << endl;
}

int python_sollyaObject_compare(PyObject* a, PyObject* b) {
	/* -1 if a < b
	 * 0 if a == b
	 * 1 if a > b
	 */
	 sollya_obj_t obj_a = buildOperandFromPyObject(a);
	 sollya_obj_t obj_b = buildOperandFromPyObject(b);

     if (!obj_a || !obj_b) {
        return -1;
    }

	 int result;

	 if (sollya_lib_is_true(sollya_lib_cmp_less(obj_a, obj_b))) {
	 	result = -1;
	} else if (sollya_lib_is_true(sollya_lib_cmp_equal(obj_a, obj_b))) {
		result = 0;
	} else if (sollya_lib_is_true(sollya_lib_cmp_greater(obj_a, obj_b))) {
		result = 1;
	} else cerr << "ERROR: could not compare two objects;" << endl;

	return result;
}

long python_sollyaObject_hash(PyObject* o) {
	python_sollyaObject* pso = (python_sollyaObject*) o;

	return pso->id;
}



PyObject* python_sollyaObject_richcompare(PyObject* a, PyObject* b, int op) {
	/* -1 if a < b
	 * 0 if a == b
	 * 1 if a > b
	 */
	 sollya_obj_t obj_a = NULL, obj_b = NULL;
     if (PSI_checkSollyaObjectCompatibility(a)) {
        obj_a = buildOperandFromPyObject(a);
    }
    
    if (PSI_checkSollyaObjectCompatibility(b)) {
	    obj_b = buildOperandFromPyObject(b);
    }

	int result;

	PyObject* py_result = Py_None;
    bool invalid_arg = (obj_a == NULL) || (obj_b == NULL);

    if (invalid_arg) {
        result = 3;
    } else if (sollya_lib_is_true(sollya_lib_cmp_less(obj_a, obj_b))) {
	 	result = -1;
	} else if (sollya_lib_is_true(sollya_lib_cmp_equal(obj_a, obj_b))) {
		result = 0;
	} else if (sollya_lib_is_true(sollya_lib_cmp_greater(obj_a, obj_b))) {
		result = 1;
	} else result = 2; // UNORDERED //cerr << "ERROR: could not compare two objects;" << endl;

	if (op == Py_EQ) {
		py_result = result == 0 ? Py_True : Py_False;
	} else if (op == Py_NE) {
		py_result = result != 0 ? Py_True : Py_False;
	} else if (op == Py_LT && !invalid_arg) {
		py_result = result == -1 ? Py_True : Py_False;
	} else if (op == Py_GT && !invalid_arg) {
		py_result = result == 1 ? Py_True : Py_False;
	} else if (op == Py_GE && !invalid_arg) {
		py_result = result != -1 ? Py_True : Py_False;
	} else if (op == Py_LE && !invalid_arg) {
		py_result = result != 1 ? Py_True : Py_False;
	}
	// if (py_result != Py_None) Py_INCREF(py_result);
	Py_INCREF(py_result);
	return py_result;;
}

 PyObject* python_sollyaObject_add(PyObject* a, PyObject* b);

 PyObject* python_sollyaObject_sub(PyObject* a, PyObject* b);

 PyObject* python_sollyaObject_mul(PyObject* a, PyObject* b);

 PyObject* python_sollyaObject_pow(PyObject* a, PyObject* b, PyObject* c);

 PyObject* python_sollyaObject_mod(PyObject* a, PyObject* b);

 PyObject* python_sollyaObject_classic_div(PyObject* a, PyObject* b);

 PyObject* python_sollyaObject_pos(PyObject* a);

 PyObject* python_sollyaObject_neg(PyObject* a);

 PyObject* python_sollyaObject_int(PyObject *a);

 PyObject* python_sollyaObject_float(PyObject *a);

/*
 PyObject* python_sollyaObject_classic_div(python_sollyaObject* a, python_sollyaObject* b) {
	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(a->ob_type, NULL, NULL);
	attachSollyaObject(pso, SOLLYA_DIV(sollya_lib_copy_obj(a->sollya_object), sollya_lib_copy_obj(b->sollya_object)));


	return (PyObject*) pso;
}*/

PyNumberMethods sollyaObject_as_number = {
    (binaryfunc)python_sollyaObject_add,        /*nb_add*/
    (binaryfunc)python_sollyaObject_sub,        /*nb_subtract*/
    (binaryfunc)python_sollyaObject_mul,        /*nb_multiply*/
    (binaryfunc)python_sollyaObject_classic_div, /*nb_divide*/
    (binaryfunc) python_sollyaObject_mod,//    (binaryfunc)int_mod,        /*nb_remainder*/
    0,//    (binaryfunc)int_divmod,     /*nb_divmod*/
    (ternaryfunc) python_sollyaObject_pow,//    (ternaryfunc)int_pow,       /*nb_power*/
    (unaryfunc) python_sollyaObject_neg,//    (unaryfunc)int_neg,         /*nb_negative*/
    (unaryfunc) python_sollyaObject_pos,//    (unaryfunc)int_int,         /*nb_positive*/
    0,//    (unaryfunc)int_abs,         /*nb_absolute*/
    0,//    (inquiry)int_nonzero,       /*nb_nonzero*/
    0,//    (unaryfunc)int_invert,      /*nb_invert*/
    0,//    (binaryfunc)int_lshift,     /*nb_lshift*/
    0,//    (binaryfunc)int_rshift,     /*nb_rshift*/
    0,//    (binaryfunc)int_and,        /*nb_and*/
    0,//    (binaryfunc)int_xor,        /*nb_xor*/
    0,//    (binaryfunc)int_or,         /*nb_or*/
    0,//    int_coerce,                 /*nb_coerce*/
    (unaryfunc) python_sollyaObject_int,//    (unaryfunc)int_int,         /*nb_int*/
    0,//    (unaryfunc)int_long,        /*nb_long*/
    (unaryfunc) python_sollyaObject_float,//    (unaryfunc)int_int,         /*nb_float*/
    0,//    (unaryfunc)int_oct,         /*nb_oct*/
    0,//    (unaryfunc)int_hex,         /*nb_hex*/
    0,                          /*nb_inplace_add*/
    0,                          /*nb_inplace_subtract*/
    0,                          /*nb_inplace_multiply*/
    0,                          /*nb_inplace_divide*/
    0,                          /*nb_inplace_remainder*/
    0,                          /*nb_inplace_power*/
    0,                          /*nb_inplace_lshift*/
    0,                          /*nb_inplace_rshift*/
    0,                          /*nb_inplace_and*/
    0,                          /*nb_inplace_xor*/
    0,                          /*nb_inplace_or*/
    0,//    (biPyTypeObject naryfunc)int_div,        /* nb_floor_divide */
    0,//    (binaryfunc)int_true_divide, /* nb_true_divide */
    0,                          /* nb_inplace_floor_divide */
    0,                          /* nb_inplace_true_divide */
    0,//    (unaryfunc)int_int,         /* nb_index */
};

//void initPythonSollyaObjectType() {
PyTypeObject 	python_sollyaObject_type = (PyTypeObject) {
		//PyVarObject_HEAD_INIT(DEFERRED_ADDRESS(&PyType_Type), 0)
		PyObject_HEAD_INIT(NULL)
		0,
		"PythonSollyaInterface.SollyaObject",
		sizeof(python_sollyaObject),
		0,
		(destructor) python_sollyaObject_dealloc,					/* tp_dealloc */
		python_sollyaObject_print,			/* tp_print */
		0,					/* tp_getattr */
		0,					/* tp_setattr */
		python_sollyaObject_compare,					/* tp_compare */
		python_sollyaObject_str,	        /* tp_repr */
		&sollyaObject_as_number,					/* tp_as_number */
		0,					/* tp_as_sequence */
		0,					/* tp_as_mapping */
		python_sollyaObject_hash,	/* tp_hash */
		python_sollyaObject_call,	/* tp_call */
		0,	                                /* tp_str */
		0,					/* tp_getattro */
		0,					/* tp_setattro */
		0,					/* tp_as_buffer */
		Py_TPFLAGS_CHECKTYPES |	Py_TPFLAGS_DEFAULT , /* tp_flags */
		0,					/* tp_doc */
		0,					/* tp_traverse */
		0,					/* tp_clear */
		python_sollyaObject_richcompare,		/* tp_richcompare */
		0,					/* tp_weaklistoffset */
		0,					/* tp_iter */
		0,					/* tp_iternext */
		python_sollyaObject_methods,			/* tp_methods */
		0,					/* tp_members */
		python_sollyaObject_getsets,			/* tp_getset */
		0,		/* tp_base */
		0,					/* tp_dict */
		0,					/* tp_descr_get */
		0,					/* tp_descr_set */
		0,					/* tp_dictoffset */
		(initproc) python_sollyaObject_init,		/* tp_init */
		PyType_GenericAlloc,					/* tp_alloc */
		python_sollyaObject_new,					/* tp_new */
	};
//}


/*****************************************************************************/
 PyObject* python_sollyaObject_mod(PyObject* a, PyObject* b) {
	sollya_obj_t dividend, modulo;

	// building dividend
	dividend = buildOperandFromPyObject(a);

	// building divisor
	modulo = buildOperandFromPyObject(b);

    INVALID_OP(!dividend || !modulo) 

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	//attachSollyaObject(pso, sollya_lib_div(dividend, divisor));
    sollya_obj_t tmp = sollya_lib_mul(sollya_lib_floor(sollya_lib_div(dividend, modulo)), modulo);
	attachSollyaObject(pso,  sollya_lib_sub(dividend, tmp));

	return (PyObject*) pso;
}

/*****************************************************************************/
 PyObject* python_sollyaObject_classic_div(PyObject* a, PyObject* b) {
	sollya_obj_t dividend, divisor;

	// building dividend
	dividend = buildOperandFromPyObject(a);

	// building divisor
	divisor = buildOperandFromPyObject(b);

    INVALID_OP(!dividend || !divisor)

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	//attachSollyaObject(pso, sollya_lib_div(dividend, divisor));
	attachSollyaObject(pso,  sollya_lib_div(dividend, divisor));

	return (PyObject*) pso;
}
/*****************************************************************************/
 PyObject* python_sollyaObject_add(PyObject* a, PyObject* b) {
	sollya_obj_t op0, op1;

	if (PyString_Check(a)) {
		PyObject* str_result = PyString_FromString("");
		PyString_Concat(&str_result, a);
		PyString_Concat(&str_result, python_sollyaObject_str(b));
		return str_result;
	} else if (PyString_Check(b)) {
		PyObject* str_result = PyString_FromString("");
		PyString_Concat(&str_result, python_sollyaObject_str(a));
		PyString_Concat(&str_result, b);
		return str_result;
	}

	// building first operand
	op0 = buildOperandFromPyObject(a);

	// building second operand
	op1 = buildOperandFromPyObject(b);

    INVALID_OP(!op0 || !op1)

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	//attachSollyaObject(pso, sollya_lib_add(op0, op1));
	attachSollyaObject(pso,  sollya_lib_add(op0, op1));

	return (PyObject*) pso;
}
/*****************************************************************************/
 PyObject* python_sollyaObject_sub(PyObject* a, PyObject* b) {
	sollya_obj_t op0, op1;

	// building first operand
	op0 = buildOperandFromPyObject(a);

	// building second operand
	op1 = buildOperandFromPyObject(b);

    INVALID_OP(!op0 || !op1)

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	//attachSollyaObject(pso, sollya_lib_sub(op0, op1));
	attachSollyaObject(pso,  sollya_lib_sub(op0, op1));

	return (PyObject*) pso;
}
/*****************************************************************************/
 PyObject* python_sollyaObject_mul(PyObject* a, PyObject* b) {
	sollya_obj_t op0, op1;

    // managing sequence repetition
    if (PyList_Check(a)) {
        int repeat_value = 0;
        sollya_lib_get_constant_as_int(& repeat_value, buildOperandFromPyObject(b));
        return PySequence_Repeat(a, repeat_value);
    } else if (PyList_Check(b)) {
        int repeat_value = 0;
        sollya_lib_get_constant_as_int(&repeat_value, buildOperandFromPyObject(a));
        return PySequence_Repeat(b, repeat_value);
    } else {
        // building first operand
        op0 = buildOperandFromPyObject(a);

        // building second operand
        op1 = buildOperandFromPyObject(b);

        INVALID_OP(!op0 || !op1)

        python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
        attachSollyaObject(pso, sollya_lib_mul(op0, op1));

        return (PyObject*) pso;
    };
}
/*****************************************************************************/
 PyObject* python_sollyaObject_pow(PyObject* a, PyObject* b, PyObject* c) {
	sollya_obj_t op0, op1;

	// building first operand
	op0 = buildOperandFromPyObject(a);

	// building second operand
	op1 = buildOperandFromPyObject(b);

    INVALID_OP(!op0 || !op1)

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	attachSollyaObject(pso, sollya_lib_pow(op0, op1));

	return (PyObject*) pso;
}
/*****************************************************************************/
 PyObject* python_sollyaObject_neg(PyObject* a) {
	sollya_obj_t op0;

	// building first operand
	op0 = buildOperandFromPyObject(a);

    INVALID_OP(!op0)


	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	attachSollyaObject(pso, sollya_lib_neg(op0));

	return (PyObject*) pso;
}
/*****************************************************************************/
 PyObject* python_sollyaObject_pos(PyObject* a) {
	sollya_obj_t op0;

	// building first operand
	op0 = buildOperandFromPyObject(a);

    INVALID_OP(!op0)

	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_new(&python_sollyaObject_type, NULL, NULL);
	attachSollyaObject(pso, sollya_lib_neg(op0));

	return (PyObject*) pso;
}
/*****************************************************************************/
PyObject* python_sollyaObject_int(PyObject *a) {
	sollya_obj_t op0;

	// building first operand
	op0 = buildOperandFromPyObject(a);

    INVALID_OP(!op0)

	int64_t int_value;
	sollya_lib_get_constant_as_int64(&int_value, op0);

    PyObject* py_int_value = PyInt_FromLong(0);

    int offset = 0;
    int64_t tmp = int_value;
    while (tmp > LONG_MAX || tmp < LONG_MIN) {
        // decomposing number
        int64_t sub_value = tmp % (int64_t) (1 << 31);
        py_int_value = PyNumber_Add(PyNumber_Lshift(PyInt_FromLong(sub_value), PyInt_FromLong(offset)), py_int_value);
        tmp = (int64_t) tmp >> 31;
        offset += 31;
    }
    py_int_value = PyNumber_Add(PyNumber_Lshift(PyInt_FromLong(tmp), PyInt_FromLong(offset)), py_int_value);

	return py_int_value;
};
/*****************************************************************************/
PyObject* python_sollyaObject_float(PyObject *a) {
	sollya_obj_t op0;

	// building first operand
	op0 = buildOperandFromPyObject(a);
    INVALID_OP(!op0)

	double float_value;
	sollya_lib_get_constant_as_double(&float_value, op0);

	return PyFloat_FromDouble(float_value);
};
