/*****************************************************************************
 * This file is part of the metalibm proof of concept project
 *
 * copyrights : Nicolas Brunie, Florent de Dinechin (2012) 
 * All rights reserved
 *****************************************************************************
 * This particular file should be included in 
 * the PythonSollyaInterface.cpp file 
 *****************************************************************************/


/*****************************************************************************/
/** Python Wrapper for double type */

#include <Python.h>
#include <sollya.h>
#include "python_sollyaObject_struct.h"


#ifndef __PYTHON_SOLLYA_OBJECT_T__
#define __PYTHON_SOLLYA_OBJECT_T__

void metalibm_catch_signal(int signalNumber);


void attachSollyaPyObject(PyObject* self, sollya_obj_t object);

void attachSollyaObject(python_sollyaObject* self, sollya_obj_t object);

PyObject* python_sollyaObject_degree_get(python_sollyaObject* self, PyObject* args);

PyObject* python_sollyaObject_new(PyTypeObject *type, PyObject *args, PyObject *kwds);

PyObject* python_sollyaObject_coeff(python_sollyaObject* self, PyObject* args);

PyObject* python_sollyaObject_getConstantAsDouble(python_sollyaObject* self, PyObject* args);

PyObject* python_sollyaObject_getConstantAsInt(python_sollyaObject* self, PyObject* args);

PyObject* python_sollyaObject_div(python_sollyaObject* self, PyObject* args);

int python_sollyaObject_init(PyObject* self, PyObject* args);

PyObject* python_sollyaObject_str(PyObject* self);

int python_sollyaObject_print(PyObject* self,FILE* fp, int flags); 

void python_sollyaObject_dealloc(python_sollyaObject* self); 

PyObject* python_sollyaObject_add(PyObject* a, PyObject* b);

PyObject* python_sollyaObject_sub(PyObject* a, PyObject* b);

PyObject* python_sollyaObject_mul(PyObject* a, PyObject* b);

PyObject* python_sollyaObject_pow(PyObject* a, PyObject* b, PyObject* c);

PyObject* python_sollyaObject_classic_div(PyObject* a, PyObject* b);

PyObject* python_sollyaObject_pos(PyObject* a);

PyObject* python_sollyaObject_neg(PyObject* a);

extern PyTypeObject python_sollyaObject_type;

void initPythonSollyaObjectType();


#endif
