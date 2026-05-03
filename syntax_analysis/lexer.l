%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ast.h"
#include "parser.tab.h"

int line_num = 1;

void lexer_error(const char* msg) {
    fprintf(stderr, "Lexer Error at line %d: %s\n", line_num, msg);
}

%}

/* Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INT         {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+
WS          [ \t]+

%x MULTI_COMMENT

%%

"int"           { return INT_TYPE; }
"float"         { return FLOAT_TYPE; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"return"        { return RETURN; }
"print"         { return PRINT; }

{ID}            { yylval.sval = strdup(yytext); return IDENTIFIER; }
{INT}           { yylval.sval = strdup(yytext); return INTEGER_LITERAL; }
{FLOAT}         { yylval.sval = strdup(yytext); return FLOAT_LITERAL; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"=="            { return EQ; }
"!="            { return NE; }
"<"             { return LT; }
">"             { return GT; }
"="             { return ASSIGN; }

";"             { return SEMICOLON; }
","             { return COMMA; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }

"//".*          { /* Skip single-line comment */ }

"/*"            { BEGIN(MULTI_COMMENT); }
<MULTI_COMMENT>"*/"    { BEGIN(INITIAL); }
<MULTI_COMMENT>\n      { line_num++; }
<MULTI_COMMENT>.       { /* Skip */ }

{WS}            { /* Skip whitespace */ }
\n              { line_num++; }

.               { 
                    char msg[100];
                    sprintf(msg, "Unrecognized character '%s'", yytext);
                    lexer_error(msg);
                }

%%

int yywrap() {
    return 1;
}
