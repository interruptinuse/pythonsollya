#include "utils.hpp"
#include "string.h"
#include <iostream>
#include "PythonSollyaObject.hpp"

using namespace std;

char* c_string(string c) {
	char* new_str = new char[c.size()+1];
	strcpy(new_str, c.c_str());
	return new_str;
}

char* PSI_StringConstants::PSI_Exception_MissingArg_str = c_string("PythonSollyaInterface.MissingArg");
char* PSI_StringConstants::PSI_Exception_TypeErrorArg_str = c_string("PythonSollyaInterface.TypeErrorArg");
char* PSI_StringConstants::PSI_Exception_UnsupportedArg_str = c_string("PythonSollyaInterface.UnsupportedArg");

char* PSI_StringConstants::PSI_degree_doc = c_string("degree: int, getter only");
char* PSI_StringConstants::PSI_empty_string = c_string("");
char* PSI_StringConstants::PSI_degree = c_string("degree");

/*void PSI_StringConstants::loadStrings() {
	string PSI_Missing_arg_cpp_str("PythonSollyaInterface.MissingArg");
	PSI_StringConstants::PSI_Exception_MissingArg_str = new char[PSI_Missing_arg_cpp_str.size()+1];
	strcpy(PSI_StringConstants::PSI_Exception_MissingArg_str, PSI_Missing_arg_cpp_str.c_str());

	string PSI_degree_doc_cpp_str("degree: int, getter only");
	PSI_StringConstants::PSI_degree_doc = new char[PSI_degree_doc_cpp_str.size()+1];
	strcpy(PSI_StringConstants::PSI_degree_doc, PSI_degree_doc_cpp_str.c_str());
}*/

sollya_obj_t buildOperandFromPyObject(PyObject* obj) {

	sollya_obj_t operand;
	if (PyObject_TypeCheck(obj, &python_sollyaObject_type)) {
		operand = sollya_lib_copy_obj(((python_sollyaObject*) obj)->sollya_object);
	} else if (PyLong_Check(obj)) {
		operand = sollya_lib_constant_from_int64(PyLong_AsLong(obj));
	} else if (PyInt_Check(obj)) {
		operand = sollya_lib_constant_from_int64(PyInt_AsLong(obj));
	} else if (PyFloat_Check(obj)) {
		double value = PyFloat_AsDouble(obj);
		operand = sollya_lib_constant_from_double(value);
    } else if (PyString_Check(obj)) {
        char* sollya_cmd = PyString_AsString(obj);
        operand = sollya_lib_parse_string(sollya_cmd);
	} else {
		cerr << "ERROR: unsupported type while converting PyObject to sollya object" << endl;
		PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_UnsupportedArg_str, NULL, NULL);
		PyErr_SetString(PSI_missingArg, "unsupported argument in conversion to interval");;
		return NULL;
	}

	return operand;
}

sollya_obj_t buildIntervalFromPyObject(PyObject* obj) {
	sollya_obj_t operand;
	if (PyObject_TypeCheck(obj, &python_sollyaObject_type)) {
		operand = sollya_lib_copy_obj(((python_sollyaObject*) obj)->sollya_object);
	} else if (PyList_Check(obj)) {
        if (PyList_Size(obj) != 2) {
            cerr << "ERROR: provided arg list does not have the required length of 2 while converting to interval " << endl;
            PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_UnsupportedArg_str, NULL, NULL);
            PyErr_SetString(PSI_missingArg, "unsupported argument in conversion to interval");
            return NULL;
        } else {
            sollya_obj_t left_bound = buildOperandFromPyObject(PyList_GetItem(obj, 0));
            sollya_obj_t right_bound = buildOperandFromPyObject(PyList_GetItem(obj, 1));
            operand = sollya_lib_range(left_bound, right_bound);
        }
	} else {
		cerr << "ERROR: unsupported type while converting PyObject to interval " << endl;
		PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_UnsupportedArg_str, NULL, NULL);
		PyErr_SetString(PSI_missingArg, "unsupported argument in conversion to interval");
		return NULL;
	}
	return operand;
}

sollya_obj_t buildSollyaListFromPyObject(PyObject* obj) {
	if (PyList_Check(obj)) {
		sollya_obj_t sollya_list;

		int list_size = PyList_Size(obj);
		sollya_obj_t* list_elts = new sollya_obj_t[list_size];

		for (int i = 0; i < list_size; i++) {
            sollya_obj_t new_elt = buildOperandFromPyObject(PyList_GetItem(obj, i));

            if (new_elt == NULL) {
                cerr << "ERROR : while converting an element for insertion in sollya list " << endl;
                PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_UnsupportedArg_str, NULL, NULL);
                PyErr_SetString(PSI_missingArg, "unsupported argument in conversion to list element");
                return NULL;
            }

            list_elts[i] = new_elt;
        }
		sollya_list = sollya_lib_list(list_elts, list_size);

		return sollya_list;
	} else {
		cerr << "ERROR : trying to build sollya list from a non list python object" << endl;
		PyObject* PSI_missingArg = PyErr_NewException(PSI_StringConstants::PSI_Exception_UnsupportedArg_str, NULL, NULL);
		PyErr_SetString(PSI_missingArg, "unsupported argument in conversion to interval");
		return NULL;
	};
}



bool PSI_checkSollyaIntervalCompatibility(PyObject* obj) {
	if (PyList_Check(obj) && PyList_Size(obj) == 2) return true;
	else if (PyObject_TypeCheck(obj, &python_sollyaObject_type)) {
		sollya_obj_t sollya_obj = ((python_sollyaObject*) obj)->sollya_object;
		if (sollya_lib_obj_is_range(sollya_obj)) return true;
	};
	return false;
}
bool PSI_checkSollyaListCompatibility(PyObject* obj) {
	if (PyList_Check(obj)) return true;
	else if (PyObject_TypeCheck(obj, &python_sollyaObject_type)) {
		sollya_obj_t sollya_obj = ((python_sollyaObject*) obj)->sollya_object;
		if (sollya_lib_obj_is_list(sollya_obj)) return true;
	};
	return false;
}


bool PSI_checkSollyaObjectCompatibility(PyObject* obj) {

	if (PyObject_TypeCheck(obj, &python_sollyaObject_type)) {
        return true;
	} else if (PyLong_Check(obj)) {
        return true;
	} else if (PyInt_Check(obj)) {
        return true;
	} else if (PyFloat_Check(obj)) {
        return true;
    } else if (PyString_Check(obj)) {
        return true;
	} else {
        return false;
	}
}
