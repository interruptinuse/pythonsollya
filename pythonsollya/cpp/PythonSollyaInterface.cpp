/*****************************************************************************
 *	This file is part of the metalibm proof of concept project
 *
 * copyrights : Nicolas Brunie, Florent de Dinechin (2012) 
 * All rights reserved
*****************************************************************************/

#include "PythonSollyaInterface.hpp"
#include <Python.h>
#include "structmember.h"
#include <iostream>
#include <sollya.h>

#include "utils.hpp"
#include "PythonSollyaInterface_functions.hpp"
#include "PythonSollyaInterface_gen_functions.hpp"
#include "PythonSollyaObject.hpp"

using namespace std;

PyDoc_STRVAR(PythonSollyaInterface__doc__, "PythonSollyaInterface is a dummy python wrapper from sollya library\n");

#define DEFERRED_ADDRESS(ADDR) 0

/*****************************************************************************
 * externally defined type inclusion
 *****************************************************************************/
//#include "PythonDouble.hpp"

/*****************************************************************************/
/** Static methods for PythonSollyaInterface module */

PyObject* python_PSI_askSollya(PyObject* self, PyObject* args) {
	PyObject* cmd_string;
	PyArg_ParseTuple(args, "O", &cmd_string);
	// convert parsed string to C string
	char* sollya_cmd = PyString_AsString(cmd_string);

	// asking sollya
	sollya_obj_t result = sollya_lib_parse_string(sollya_cmd);

	// embedding response into PythonSollyaObject
	python_sollyaObject* pso = (python_sollyaObject*)python_sollyaObject_type.tp_new(&python_sollyaObject_type, NULL, NULL);
	pso->sollya_object = result;

	return (PyObject*) pso;
}

static PyObject* python_PSI_display(PyObject* self, PyObject* args) {
	PyObject* display_mode;
	PyArg_ParseTuple(args, "O", &display_mode);

	sollya_obj_t sollya_display_mode = buildOperandFromPyObject(display_mode);
	sollya_lib_set_display(sollya_display_mode);

	Py_INCREF(Py_None);
	return Py_None;
}


static PyObject* python_PSI_set_prec(PyObject* self, PyObject* args) {
	PyObject* display_mode;
	PyArg_ParseTuple(args, "O", &display_mode);

	sollya_obj_t sollya_new_precision = buildOperandFromPyObject(display_mode);
	sollya_lib_set_prec(sollya_new_precision);

	Py_INCREF(Py_None);
	return Py_None;
}

static PyObject* python_PSI_verbosity(PyObject* self, PyObject* args) {
	PyObject* verbosity_level;
	PyArg_ParseTuple(args, "O", &verbosity_level);

	sollya_obj_t sollya_verbosity_level = buildOperandFromPyObject(verbosity_level);
	sollya_lib_set_verbosity(sollya_verbosity_level);

	Py_INCREF(Py_None);
	return Py_None;
}

static PyObject* python_PSI_roundingwarnings(PyObject* self, PyObject* args) {
	PyObject* roundingwarnings;
	PyArg_ParseTuple(args, "O", &roundingwarnings);

	sollya_obj_t sollya_roundingwarnings= buildOperandFromPyObject(roundingwarnings);
	sollya_lib_set_roundingwarnings(sollya_roundingwarnings);

	Py_INCREF(Py_None);
	return Py_None;
}







/** table of PSI module function */
static PyMethodDef PSI_functions [] = {
	{"askSollya", python_PSI_askSollya, METH_VARARGS, "send a character string to sollya for evaluation"},

	// inclusion of generated wrapper functions
#include "PythonSollyaInterface_functions.method_def"
#include "PythonSollyaInterface_gen_functions.method_def"


	{"display", python_PSI_display, METH_VARARGS, "display(<display_mode>)"},
    {"prec", python_PSI_set_prec, METH_VARARGS, "prec(<new_precision>)"},
	{"verbosity", python_PSI_verbosity, METH_VARARGS, "verbosity(<integer>)"},
	{"roundingwarnings", python_PSI_roundingwarnings, METH_VARARGS, "roundingwarnings(<on|off>)"},
	{NULL, NULL},
};

void addStaticObjectToModule(PyObject* module, string static_name, sollya_obj_t sollya_obj) {
	python_sollyaObject* python_object = (python_sollyaObject*)python_sollyaObject_type.tp_new(&python_sollyaObject_type, NULL, NULL);
	python_object->sollya_object = sollya_obj;
	PyModule_AddObject(module, static_name.c_str(), (PyObject*) python_object);

}


void PythonSollyaInterface::initConstantObjects(PyObject* module) {
	// adding free variable
	addStaticObjectToModule(module, "x", sollya_lib_free_variable());
	addStaticObjectToModule(module, "pi", sollya_lib_build_function_pi());

	addStaticObjectToModule(module, "fixed", sollya_lib_fixed());
	addStaticObjectToModule(module, "floating", sollya_lib_floating());
	addStaticObjectToModule(module, "absolute", sollya_lib_absolute());
	addStaticObjectToModule(module, "relative", sollya_lib_relative());

    // specific value
    mpfr_t mp_nan, mp_infty;
    mpfr_inits(mp_nan, mp_infty, NULL);
    mpfr_set_nan(mp_nan);
    mpfr_set_inf(mp_infty, +1);
    addStaticObjectToModule(module, "infty", sollya_lib_constant(mp_infty));
    addStaticObjectToModule(module, "NaN", sollya_lib_constant(mp_nan));
    addStaticObjectToModule(module, "error", sollya_lib_error());
    mpfr_clears(mp_nan, mp_infty, NULL);

	// round mode
	addStaticObjectToModule(module, "RN", sollya_lib_round_to_nearest());
	addStaticObjectToModule(module, "RZ", sollya_lib_round_towards_zero());
	addStaticObjectToModule(module, "RU", sollya_lib_round_up());
	addStaticObjectToModule(module, "RD", sollya_lib_round_down());

	// display mode
	addStaticObjectToModule(module, "binary", sollya_lib_binary());
	addStaticObjectToModule(module, "dyadic", sollya_lib_dyadic());
	addStaticObjectToModule(module, "hexadecimal", sollya_lib_hexadecimal());
	addStaticObjectToModule(module, "powers", sollya_lib_powers());
	addStaticObjectToModule(module, "decimal", sollya_lib_decimal());

    // precision
    addStaticObjectToModule(module, "binary32", sollya_lib_single_obj());
    addStaticObjectToModule(module, "binary64", sollya_lib_double_obj());
    addStaticObjectToModule(module, "binary80", sollya_lib_doubleextended_obj());

    addStaticObjectToModule(module, "doubledouble_t", sollya_lib_double_double_obj());
    addStaticObjectToModule(module, "tripledouble_t", sollya_lib_triple_double_obj());

    // on|off flags
    addStaticObjectToModule(module, "on", sollya_lib_on());
    addStaticObjectToModule(module, "off", sollya_lib_off());

	// numeric constant
	addStaticObjectToModule(module, "S2", sollya_lib_constant_from_int(2));

	//addStaticObjectToModule(module, "display", sollya_lib_decimal());

}

int PSI_sollya_msg_callback(sollya_msg_t msg, void* _) {
	return 0;
};

std::list<std::string> PythonSollyaInterface::cmd_history;

extern "C" PyMODINIT_FUNC initPythonSollyaInterface(void) {
	PyObject* PSI_module;
	if (PyType_Ready(&python_sollyaObject_type) < 0) {
		cerr << "ERROR while finalizing python_sollyaObject_type initialization" << endl;
		return;
	}

	PSI_module = Py_InitModule3("PythonSollyaInterface", PSI_functions, PythonSollyaInterface__doc__);
	if (PSI_module == NULL) {
		cerr << "ERROR during python module init." << endl;
		return;
	}

	if (PyModule_AddObject(PSI_module, "SollyaObject", (PyObject*) &python_sollyaObject_type) < 0) {
		cerr << "ERROR during SollyaObject type import in PSI module." << endl;
		return;
	}

	// init sollya
	sollya_lib_init();

	//
	sollya_lib_install_msg_callback(PSI_sollya_msg_callback, NULL);

	// adding object into module
	PythonSollyaInterface::initConstantObjects(PSI_module);
}

void PythonSollyaInterface::init() {
	// pythonSollyaObject_type own init
	//initPythonSollyaObjectType();

	// python module initialization 
	Py_Initialize();
	PyObject* PSI_module;
	/*if (PyType_Ready(&python_double_type) < 0) {
		cerr << "ERROR while finalizing python_double_type initialization" << endl;
		return;
	}*/
	if (PyType_Ready(&python_sollyaObject_type) < 0) {
		cerr << "ERROR while finalizing python_sollyaObject_type initialization" << endl;
		return;
	}

	PSI_module = Py_InitModule3("PythonSollyaInterface", PSI_functions, PythonSollyaInterface__doc__);
	if (PSI_module == NULL) {
		cerr << "ERROR during python module init." << endl;
		return;
	}

	if (PyModule_AddObject(PSI_module, "SollyaObject", (PyObject*) &python_sollyaObject_type) < 0) {
		cerr << "ERROR during SollyaObject type import in PSI module." << endl;
		return;
	}

	// init sollya
	sollya_lib_init();

	//
	sollya_lib_install_msg_callback(PSI_sollya_msg_callback, NULL);

	// adding object into module
	PythonSollyaInterface::initConstantObjects(PSI_module);
}

void PythonSollyaInterface::setArgv(int argc, char** argv) {
	PySys_SetArgvEx(argc, argv, 0);
}

void PythonSollyaInterface::destroy() {
	// closing sollya
	sollya_lib_close();
}


