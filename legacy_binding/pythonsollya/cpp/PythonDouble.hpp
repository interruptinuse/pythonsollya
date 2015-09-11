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
typedef struct {
	/* Python linked object, SHOULD ALWAYS BE FIRST STRUCT MEMBER */
	PyObject object;

	double double_value;
} python_double;

static PyMethodDef python_double_methods[] = {
	{NULL, NULL},
};

static PyGetSetDef python_double_getsets[] = {
	{0},
};


static int python_double_init(PyObject* self, PyObject* args, PyObject* kwds) {
	static char *kwlist[] = {"double", "sollya_object"};
	double double_value = -1.0;
	PyObject* sollya_object;

	/* initialize double_value */
	PyArg_ParseTupleAndKeywords(args, kwds, "|dO", kwlist, &double_value, sollya_object);
	((python_double*) self)->double_value = double_value;

	return 0;
};

static PyObject* python_double_str(PyObject* self) {
	stringstream double_str;
	cout << "call to python_double_str" << endl;

	double_str << "D" << ((python_double*) self)->double_value;
	return PyString_FromString(double_str.str().c_str());
};

static PyTypeObject python_double_type = {
	PyVarObject_HEAD_INIT(DEFERRED_ADDRESS(&PyType_Type), 0)
	"PythonSollyaInterface.Double",
	sizeof(python_double),
	0,
	0,					/* tp_dealloc */
	0,			/* tp_print */
	0,					/* tp_getattr */
	0,					/* tp_setattr */
	0,					/* tp_compare */
	0,					/* tp_repr */
	0,					/* tp_as_number */
	0,					/* tp_as_sequence */
	0,					/* tp_as_mapping */
	0,					/* tp_hash */
	0,					/* tp_call */
	python_double_str,	/* tp_str */
	0,					/* tp_getattro */
	0,					/* tp_setattro */
	0,					/* tp_as_buffer */
	Py_TPFLAGS_DEFAULT , /* tp_flags */
	0,					/* tp_doc */
	0,					/* tp_traverse */
	0,					/* tp_clear */
	0,					/* tp_richcompare */
	0,					/* tp_weaklistoffset */
	0,					/* tp_iter */
	0,					/* tp_iternext */
	python_double_methods,			/* tp_methods */
	0,					/* tp_members */
	python_double_getsets,			/* tp_getset */
	0,		/* tp_base */
	0,					/* tp_dict */
	0,					/* tp_descr_get */
	0,					/* tp_descr_set */
	0,					/* tp_dictoffset */
	python_double_init,		/* tp_init */
	PyType_GenericAlloc,					/* tp_alloc */
	PyType_GenericNew,					/* tp_new */
};

/*****************************************************************************/
