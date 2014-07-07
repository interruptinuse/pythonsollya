#include <iostream>
#include <string>
#include <vector>
#include <boost/regex.hpp>


typedef enum {
	status_in,
	status_out
} sproc_status_t;

/** extracts python string from a script line and store them into string_vector
	in order */
std::string extractString(std::vector<std::string> &string_vector_g, std::vector<std::string> & string_vector_a, std::vector<std::string> &string_vector_c, const std::string& file, sproc_status_t &status); 

/** extracts python string from a script line and store them into string_vector
	in order */
// void extractString(std::vector<std::string> &string_vector, const std::string& file); 


/** replaces every occurences of a python string by ##PYSTRING## */
std::string hideString(const std::string& file);


/* expand each sollya number (e.g: 2s) into a call to a PythonSollyaObject constructor */
std::string expandSollyaObject(const std::string& file);


/** reinject hiden strings into script line */
void reinjectString(std::string& file, std::vector<std::string> string_vector_g, std::vector<std::string> string_vector_a, std::vector<std::string> string_vector_c);


/** apply extract, hide, extract and reinject to the given string */
std::string processString(std::string& file, sproc_status_t &status, std::vector<std::string> &module_vector);


std::string processFile(std::string filename);
