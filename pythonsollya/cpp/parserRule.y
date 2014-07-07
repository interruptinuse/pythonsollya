%pure-parser
%name-prefix="ParserContext_"
%locations
%defines
%error-verbose
%parse-param { ParserContext* context }
%lex-param   { void* scanner }

%code requires {
	#include <list>
	#include <string>

}



%union {
	std::string* str;
	std::list<std::string>* string_list_t;
}

%token FROM   "from"
%token IMPORT "import"
%token AS     "as"
%token C      ","
%token SC     ";"
%token WC	  "*"

%token <str> STRING
%token <str> SPACE


%type <str> import_dec
%type <str> from_dec
%type <str> module_as
%type <str> module_as_follow
%type <str> module_as_list
%type <str> dec
%type <str> line_follow
%type <str> import_list

%start line
%{
	#include <map>
	#include <list>
	#include <string>
	#include <cmath>
	#include "ParserContext.h"

	using namespace std;

	
	int intlog2(int n) { return log(n) / log(2.0f);};

	int ParserContext_lex(YYSTYPE* lvalp, YYLTYPE* llocp, void* scanner);

	void ParserContext_error(YYLTYPE* locp, ParserContext* context, const char* err)
	{
		cout << locp->first_line << "," << locp->first_column <<  ":" << err << endl;
	}

	#define scanner context->scanner
%}

%%
line:
	SPACE dec line_follow {  context->result_str = *$1 + *$2 + *$3;}
	| dec line_follow {  context->result_str = *$1 + *$2;}
;
line_follow:
	SC dec line_follow { $$ = $2; *$$ = "; " + *$$ + *$3; }
	| SC { $$ = new string(";"); }
	|    { $$ = new string("");  }
;
dec:
	import_dec 
	| from_dec {  context->result_str = *$1; }
;
import_dec:
	IMPORT module_as_list { $$ = $2; *$$ = "import " + *$$; } 
;
from_dec:
	FROM STRING IMPORT import_list{ context->module_list.push_back(*$2); $$ = $2; *$$ = "from " + context->extendModule(*$$) + " import " + *$4; }
;
import_list:
	STRING AS STRING { $$ = $1; *$$ += " as " + *$3; } 
	| STRING AS STRING C import_list { $$ = $1; *$$ += " as " + *$3 + ", " + *$5; } 
	| STRING C import_list { $$ = $1; *$$ += ", " + *$3; }
	| STRING { $$ = $1; }
	| WC { $$ = new string("*");}
;
module_as_list:
	module_as module_as_follow { $$ = $1; *$$ += *$2; }
;
module_as:
	STRING AS STRING { context->module_list.push_back(*$1); $$ = $1; *$$ = context->extendModule(*$$) + " as " + *$3; }
	| STRING { context->module_list.push_back(*$1); $$ = $1; *$$ = context->extendModule(*$1); }
;
module_as_follow:
	 C module_as module_as_follow { $$ = $2; *$$ = ", " + *$$ + *$3; }
	| { $$ = new std::string("");}
;

%%

