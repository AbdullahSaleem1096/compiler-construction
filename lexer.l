%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Global variables */
int line_num = 1;

/* Polynomial Rolling Hash Function */
unsigned int calculate_hash(const char *str) {
    unsigned int hash = 0;
    unsigned int p = 31;
    while (*str) {
        hash = (hash * p) + (unsigned char)(*str);
        str++;
    }
    return hash;
}

/* Helper function to print token details */
void print_token(const char* type, const char* lexeme) {
    if (strcmp(type, "IDENTIFIER") == 0) {
        unsigned int h = calculate_hash(lexeme);
        printf("[Line: %d] Type: %s, Lexeme: \"%s\", Hash: %u\n", line_num, type, lexeme, h);
    } else {
        printf("[Line: %d] Type: %s, Lexeme: \"%s\"\n", line_num, type, lexeme);
    }
}
%}

/* Definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INT         {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+
WS          [ \t]+

/* Exclusive state for multi-line comments */
%x MULTI_COMMENT

%%

"int"           { print_token("KEYWORD", yytext); }
"float"         { print_token("KEYWORD", yytext); }
"if"            { print_token("KEYWORD", yytext); }
"else"          { print_token("KEYWORD", yytext); }
"while"         { print_token("KEYWORD", yytext); }
"return"        { print_token("KEYWORD", yytext); }
"print"         { print_token("KEYWORD", yytext); }

{ID}            { print_token("IDENTIFIER", yytext); }
{INT}           { print_token("INTEGER_LITERAL", yytext); }
{FLOAT}         { print_token("FLOAT_LITERAL", yytext); }

"+"             { print_token("OPERATOR", yytext); }
"-"             { print_token("OPERATOR", yytext); }
"*"             { print_token("OPERATOR", yytext); }
"/"             { print_token("OPERATOR", yytext); }
"=="            { print_token("OPERATOR", yytext); }
"!="            { print_token("OPERATOR", yytext); }
"<"             { print_token("OPERATOR", yytext); }
">"             { print_token("OPERATOR", yytext); }
"="             { print_token("OPERATOR", yytext); }

";"             { print_token("DELIMITER", yytext); }
","             { print_token("DELIMITER", yytext); }
"("             { print_token("DELIMITER", yytext); }
")"             { print_token("DELIMITER", yytext); }
"{"             { print_token("DELIMITER", yytext); }
"}"             { print_token("DELIMITER", yytext); }

"//".*          { /* Skip single-line comment */ }

"/*"            { BEGIN(MULTI_COMMENT); }
<MULTI_COMMENT>"*/"    { BEGIN(INITIAL); }
<MULTI_COMMENT>\n      { line_num++; }
<MULTI_COMMENT>.       { /* Skip */ }

{WS}            { /* Skip whitespace */ }
\n              { line_num++; }

.               { fprintf(stderr, "Error at line %d: Unrecognized character '%s'\n", line_num, yytext); }

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        yyin = file;
    } else {
        printf("Usage: ./lexer <filename>\n");
        return 1;
    }

    printf("--- Token Stream Start ---\n");
    yylex();
    printf("--- Token Stream End ---\n");
    
    return 0;
}

int yywrap() {
    return 1;
}
