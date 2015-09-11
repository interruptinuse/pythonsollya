#ifndef __PYTHON_SOLLYA_OBJECT_STRUCT_H__
#define __PYTHON_SOLLYA_OBJECT_STRUCT_H__

#include <Python.h>
#include <sollya.h>

typedef struct {
	/* Python linked object, SHOULD ALWAYS BE FIRST STRUCT MEMBER */
	PyObject_HEAD; // object;

	sollya_obj_t sollya_object;
	int id;
} python_sollyaObject;

#endif
