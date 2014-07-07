#ifndef __PARSER_CONTEXT_H__
#define __PARSER_CONTEXT_H__

#include <iostream>
#include <list>
#include <string>

using namespace std;

class ParserContext {
	protected:
		void init_scanner();
		void destroy_scanner();

	public:
		void* scanner;
		int result;
		int a;
		int b;
		istream* is;
		int esc_depth;

		std::list<std::string> module_list;
		std::string result_str;
	public:
		ParserContext(istream* is_ = &cin) {
			init_scanner();
			is = is_;
			a = b = 1;
		}
		virtual ~ParserContext() {
			destroy_scanner();
		}

		string extendModule(string module) {
			return module;
			/*if (module == "PythonSollyaInterface" ||
				module == "PSI") return module;
			else return module + "_ext";*/
		}
};

int ParserContext_parse(ParserContext*);



#endif // __PARSER_CONTEXT_H__
