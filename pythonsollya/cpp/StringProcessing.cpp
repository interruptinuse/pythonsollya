#include <iostream>
#include <string>
#include <vector>
#include <boost/regex.hpp>
#include "StringProcessing.hpp"
#include "ParserContext.h"
#include <sstream>
#include <fstream>

using namespace std;

#define STRING_EXPRESSION_0  "\"\"\".*?(?<!\\\\)\"\"\""
#define STRING_EXPRESSION  "\".*?(?<!\\\\)\""
#define STRING_EXPRESSION_2 "'.*?(?<!\\\\)'"

#define NUMBER_PATTERN "(?<![a-zA-Z0-9_])(-?[1-9][\\d]*\\.?[\\d]*|-?[\\d]*\\.[1-9][\\d]*)s"

#define DYADIC_PATTERN "(?<![a-zA-Z0-9_])-?([1-9][\\d]*)b(-?[1-9][\\d]*)(?![a-f])"

#define HEXA_PATTERN "(?<![a-zA-Z0-9_])(-?0x(\\.?[[:xdigit:]]+|[[:xdigit:]]+\\.[[:xdigit:]]*)p-?[\\d]+)"

string extractString(vector<string> &string_vector_g, vector<string> & string_vector_a, vector<string> & string_vector_c, const std::string& file, sproc_status_t &status) 
{
	int index = 0, start_index = -1, stop_index = -1;
	sproc_status_t current_status = status;

	const int size = file.size();
	string new_string = "";

	while (index < size) {
		if (status == status_in) {
			string py_string = "";
			do {
				py_string += file[index];
				for (index++;file.substr(index, 3)  != "\"\"\"" && index+2 < size;  index++) {
					py_string += file[index];
				}; 
			} while (file[index-1] == '\\' && index < size);

			if (index+2 >= size) {
				status = status_in;
				while (index < size) py_string += file[index++];

				new_string += "##PYSTRING_C##"; 
	
				string_vector_c.push_back(py_string);

				return new_string;
			} else {
				py_string += "\"\"\"";
				status = status_out;
				new_string += "##PYSTRING_C##"; 
				index += 2;
	
				string_vector_c.push_back(py_string);
			}

		} else if (file[index] == '\"') {
			if (index+2 < size && file[index+1] == '\"' && file[index+2] == '\"') {
				// detecting long python string, surrounded by """ """
				string py_string = "";
				py_string += file[index++];
				py_string += file[index++];
				do {
					py_string += file[index];
					for (index++;file.substr(index, 3)  != "\"\"\"" && index+2 < size;  index++) {
						py_string += file[index];
					}; 
				} while (file[index-1] == '\\' && index < size);

				if (index+2 >= size) {
					status = status_in;
					while (index < size) py_string += file[index++];

					new_string += "##PYSTRING_C##"; 
	
					string_vector_c.push_back(py_string);

					return new_string;
				} else {
					py_string += "\"\"\"";
					new_string += "##PYSTRING_C##"; 
					index += 2;
	
					string_vector_c.push_back(py_string);
				}

			} else {
				// detecting  python string, surrounded by " "
				string py_string = "";
				do {
					py_string += file[index];
					for (index++;file[index] != '\"' && index < size;  index++) {
						py_string += file[index];
					}; 
				} while(file[index-1] == '\\' && index < size);
				py_string += "\"";
				new_string += "##PYSTRING_G##"; 

				string_vector_g.push_back(py_string);
			}
		} else if (file[index] == '\'') {
				// detecting  python string, surrounded by ' '
			string py_string = "";
			start_index = index;
			do {
				py_string += file[index];
				for (index++;file[index] != '\'' && index < size;  index++) {
					py_string += file[index];
				}; 
			} while(file[index-1] == '\\' && index < size);
			py_string += "\'";
			new_string += "##PYSTRING_A##"; 

			string_vector_a.push_back(py_string);
		} else {
			new_string += file[index];
		}
		index++;
	}
	return new_string;
}

void extractImport(const std::string &file, std::vector<std::string> module_vector) {
	boost::regex expression("from[[:space:]]+([[:alpha:]_][[:alnum:]_]*)[[:space:]]+import|^[[:space:]]*import[[:space:]]+([[:alpha:]_][[:alnum:]_]*[[:space:]]*, )[[:space:]]+");
	std::string::const_iterator start, end;

	start = file.begin();
	end = file.end();

	boost::match_results<std::string::const_iterator> what;
	boost::match_flag_type flags = boost::match_default;

	while (regex_search(start, end, what, expression, flags)) {
		cout << "what[1]: " << what[1] << " | what[2]: " << what[2] << endl;
		if (what[1] != "") module_vector.push_back(what[1]);
		if (what[2] != "") module_vector.push_back(what[2]);

	   // update search position: 
	   start = what[0].second; 
	   // update flags: 
	   flags |= boost::match_prev_avail; 
	   flags |= boost::match_not_bob; 
	}
}

std::string extendImport(std::string &file) {
	boost::regex e("from[[:space:]]+([[:alpha:]_][[:alnum:]_]*)[[:space:]]+import");
	string new_string = boost::regex_replace(file, e, "from $1_ext import", boost::match_default |boost::format_all);

	boost::regex e2("^[[:space:]]*import[[:space:]]*([[:alpha:]_][[:alnum:]_]*)[[:space:]]*");
	new_string = boost::regex_replace(new_string, e2, "import  $1_ext ", boost::match_default |boost::format_all);

	return new_string;
}

/*
void extractString(vector<string> &string_vector, const std::string& file) 
{ 
	boost::regex expression(STRING_EXPRESSION);
	std::string::const_iterator start, end; 
	start = file.begin(); 
	end = file.end(); 
	boost::match_results<std::string::const_iterator> what; 
	boost::match_flag_type flags = boost::match_default; 

	while(regex_search(start, end, what, expression, flags)) 
	{ 
	   // what[0] contains the whole string 
	   string_vector.push_back(what[0]);
	   // update search position: 
	   start = what[0].second; 
	   // update flags: 
	   flags |= boost::match_prev_avail; 
	   flags |= boost::match_not_bob; 
	} 
}*/

string hideString(const std::string& file) {
	boost::regex e(STRING_EXPRESSION);
	string new_string = boost::regex_replace(file, e, "##PYSTRING##", boost::match_default |boost::format_all);

	return new_string;
}


string expandSollyaObject(const std::string& file) {
	boost::regex number_pattern(NUMBER_PATTERN);

	string new_string = boost::regex_replace(file, number_pattern, "PSI.SollyaObject\\($1\\)", boost::match_default |boost::format_all);

	return new_string;
}


string expandDyadicNumbers(const std::string &file) {
	boost::regex number_pattern(DYADIC_PATTERN);

	string new_string = boost::regex_replace(file, number_pattern, "PSI.SollyaObject\\($1\\)*2**PSI.SollyaObject\\($2\\)", boost::match_default |boost::format_all);

	return new_string;
}


string expandHexaNumbers(const std::string &file) {
	boost::regex number_pattern(HEXA_PATTERN);

	string new_string = boost::regex_replace(file, number_pattern, "convert_hexa\\(\"$1\"\\)", boost::match_default |boost::format_all);

	return new_string;
}

     
void reinjectString(std::string& file, vector<string> string_vector_g, vector<string> string_vector_a, vector<string> string_vector_c) {
	int index = 0;
	int str_index = 0;
	while (1) {
		str_index = file.find("##PYSTRING_G##", str_index);
		if (str_index == string::npos) break;
		file.replace(str_index, 14, string_vector_g[index++]);
	}
	index = 0;
	str_index = 0;
	while (1) {
		str_index = file.find("##PYSTRING_A##", str_index);
		if (str_index == string::npos) break;
		file.replace(str_index, 14, string_vector_a[index++]);
	}
	index = 0;
	str_index = 0;
	while (1) {
		str_index = file.find("##PYSTRING_C##", str_index);
		if (str_index == string::npos) break;
		file.replace(str_index, 14, string_vector_c[index++]);
	}
}


string newProcessString(string file) {
	return "";
	/*boost::regex import_from("^[ \t]*import.*|^[ \t]*from.*");
	boost::match_results<std::string::const_iterator> what; 

	std::string::const_iterator start, end; 
	start = file.begin(); 
	end = file.end(); 
	boost::match_results<std::string::const_iterator> what; 
	boost::match_flag_type flags = boost::match_default; 

	std::vector<std::string> string_vector;

	while(regex_search(start, end, what, import_from, flags)) 
	{ 
	   // what[0] contains the whole string 
	   string_vector.push_back(what[0]);
	   // update search position: 
	   start = what[0].second; 
	   // update flags: 
	   flags |= boost::match_prev_avail; 
	   flags |= boost::match_not_bob; 
	} 
	// processing string_vector
	for (int i = 0; i < string_vector.size(); i++) {
		
	}*/

/*	if (regex_match(file, what, import_from)) {
		cout << "label: new string processing" << endl;
		// allocating input stream
		stringstream stream(file);
		istream* p_stream = &stream;
			
		ParserContext context(p_stream);
		
		if (!ParserContext_parse(&context)) context.result;

		std::list<std::string>::iterator it;
		for (it = context.module_list.begin(); it != context.module_list.end(); it++) {
			cout << "module: " << (*it) << endl;
			//processFile("./script/" + *it + ".py");
		}

		return string(context.result_str);
	} else return file;*/
}

string processString(std::string &file, sproc_status_t &status, std::vector<std::string> &module_vector) {
	vector<string> string_vector, string_vector_g, string_vector_a, string_vector_c;
	// vector<string> module_vector;

	/* look for and hide python strings */
	string new_string = extractString(string_vector_g, string_vector_a, string_vector_c, file, status);

	/* expand import module */
	// new_string = newProcessString(new_string);

	/* expand sollya and dyadic numbers */
	new_string = expandSollyaObject(new_string);
	new_string = expandHexaNumbers(new_string);
	new_string = expandDyadicNumbers(new_string);

	/* reinject hidden string */
	reinjectString(new_string, string_vector_g, string_vector_a, string_vector_c);

	/* return result */
	return new_string;
}


string processFile(string filename) {
	string modFileName = boost::regex_replace(filename, boost::regex("\\.py"), "_ext.py", boost::match_default | boost::format_all);
	cout << "new file " << modFileName << endl;

	ifstream input_file(filename.c_str());
	ofstream output_file(modFileName.c_str());

	vector<string> module_vector;

	string line;
	if (input_file.is_open()) {
		sproc_status_t status = status_out;
		while (input_file.good()) {
			getline(input_file, line);
			string line_trans = processString(line, status, module_vector);
			output_file << line_trans << endl;
		}
		input_file.close();
		output_file.close();
	};

	return modFileName;
}
