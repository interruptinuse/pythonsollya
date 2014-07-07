%option reentrant
%option prefix="ParserContext_"
%option bison-bridge
%option bison-locations
%option noyywrap 
%option yylineno

%{
	#include "ParserContext.h"
	#include "parserRule.hpp"

	// #include "Dataflow.hpp"

	#define YY_EXTRA_TYPE ParserContext*
	#define YY_USER_ACTION yylloc->first_line = yylineno;


	#define YY_INPUT(buf,result,max_size) \
	{ \
		char c; \
		(*yyextra->is).get(c); \
		if(yyextra->is->eof()) { \
			result = YY_NULL; \
		} else { \
			buf[0] = c; \
			result = 1; \
		} \
	}


	long long int hexToInt(char* str) {
		char* pointer = str;
		long long int tmp = 0;
		while(1) {
			switch(*pointer) {
				case '0': tmp = tmp * 16; break;
				case '1': tmp = tmp * 16 + 1; break;
				case '2': tmp = tmp * 16 + 2; break;
				case '3': tmp = tmp * 16 + 3; break;
				case '4': tmp = tmp * 16 + 4; break;
				case '5': tmp = tmp * 16 + 5; break;
				case '6': tmp = tmp * 16 + 6; break;
				case '7': tmp = tmp * 16 + 7; break;
				case '8': tmp = tmp * 16 + 8; break;
				case '9': tmp = tmp * 16 + 9; break;
				case 'a': tmp = tmp * 16 + 10; break;
				case 'b': tmp = tmp * 16 + 11; break;
				case 'c': tmp = tmp * 16 + 12; break;
				case 'd': tmp = tmp * 16 + 13; break;
				case 'e': tmp = tmp * 16 + 14; break;
				case 'f': tmp = tmp * 16 + 15; break;
				default:
					return tmp;
			}
			pointer += 1;
		};
		// execution should not reach this line
		return tmp;
	}
%}


%%
"#".*		{ cout << "comment" << endl;} // commentary : do nothing  
"from"		{ return FROM; }
"import"	{ return IMPORT;}
"as"		{ return AS;}
";"			{ return SC;}
","    		{ return C;}
"*" 		{ return WC; }
^[ \t]*	    { yylval->str = new string(strdup(yytext)); return SPACE; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval->str = new string(strdup(yytext)); return STRING;}
.|\n  

%%


void ParserContext::init_scanner() {
	yylex_init(&scanner);
	yyset_extra(this, scanner);
}

void ParserContext::destroy_scanner() {
	yylex_destroy(scanner);
}
