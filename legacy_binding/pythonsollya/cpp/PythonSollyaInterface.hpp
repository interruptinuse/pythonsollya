#include <Python.h>
#include <string>
#include <list>

#ifndef __PYTHON_SOLLYA_INTERFACE_HPP__
#define __PYTHON_SOLLYA_INTERFACE_HPP__

using namespace std;

class PythonSollyaInterface {
	public:
		static std::list<std::string> cmd_history;

		static void init();
		static void setArgv(int argc, char** argv);
		static void runString(string script_line, bool no_exec_f = false, bool enable_process = true);
		static void runFile(const char* filename, bool no_exec_f = false, bool preprocess = false);
		static void initConstantObjects(PyObject* module);
		static void destroy();

		static void dumpHistory(string filename);
};

#endif
