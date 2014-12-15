#ifndef __UTILS_HPP__
#define __UTILS_HPP__

#include <Python.h>
#include <sollya.h>

sollya_obj_t buildOperandFromPyObject(PyObject* obj);
sollya_obj_t buildSollyaListFromPyObject(PyObject* obj);
sollya_obj_t buildIntervalFromPyObject(PyObject* obj);
sollya_obj_t buildSollyaStringFromPyObject(PyObject* obj);

bool PSI_checkSollyaIntervalCompatibility(PyObject* obj);
bool PSI_checkSollyaListCompatibility(PyObject* obj);
bool PSI_checkSollyaObjectCompatibility(PyObject* obj);

class PSI_StringConstants {
	public:
		static char* PSI_Exception_MissingArg_str;
        static char* PSI_Exception_TypeErrorArg_str;
        static char* PSI_Exception_UnsupportedArg_str;

		static char* PSI_degree_doc;
		static char* PSI_empty_string;
		static char* PSI_degree;

		// static void loadStrings();
};

#endif // __UTILS_HPP__
