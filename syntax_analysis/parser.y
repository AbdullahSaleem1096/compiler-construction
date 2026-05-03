%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "../semantic_analysis/semantic.h"

extern int yylex();
extern int line_num;
extern char* yytext;
void yyerror(const char* s);

ASTNode* root;

/* Helper to set line number */
ASTNode* set_line(ASTNode* node) {
    if (node) node->line = line_num;
    return node;
}

%}

%union {
    char* sval;
    struct ASTNode* node;
}

/* Tokens */
%token <sval> IDENTIFIER INTEGER_LITERAL FLOAT_LITERAL
%token INT_TYPE FLOAT_TYPE IF ELSE WHILE RETURN PRINT
%token PLUS MINUS MULT DIV EQ NE LT GT ASSIGN
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE

/* Precedence */
%right ASSIGN
%left EQ NE LT GT
%left PLUS MINUS
%left MULT DIV

/* Non-terminal types */
%type <node> program global_list global_item function_def parameter_list parameter block statement_list statement declaration assignment if_statement while_statement return_statement print_statement expression relational_expr additive_expr multiplicative_expr primary function_call argument_list type

%%

program:
    global_list { root = set_line(create_node(NODE_PROGRAM, NULL, $1, NULL)); }
    ;

global_list:
    global_item { $$ = $1; }
    | global_list global_item { $$ = append_node($1, $2); }
    ;

global_item:
    declaration SEMICOLON { $$ = $1; }
    | function_def { $$ = $1; }
    ;

function_def:
    type IDENTIFIER LPAREN parameter_list RPAREN block { 
        $$ = set_line(create_node(NODE_FUNC_DEF, $2, $4, $6)); 
        $$->dataType = strdup($1->value);
    }
    | type IDENTIFIER LPAREN RPAREN block { 
        $$ = set_line(create_node(NODE_FUNC_DEF, $2, NULL, $5)); 
        $$->dataType = strdup($1->value);
    }
    ;

parameter_list:
    parameter { $$ = $1; }
    | parameter_list COMMA parameter { $$ = append_node($1, $3); }
    ;

parameter:
    type IDENTIFIER { $$ = set_line(create_node(NODE_PARAM, $2, $1, NULL)); }
    ;

block:
    LBRACE statement_list RBRACE { $$ = set_line(create_node(NODE_BLOCK, NULL, $2, NULL)); }
    ;

statement_list:
    /* empty */ { $$ = NULL; }
    | statement_list statement { $$ = append_node($1, $2); }
    ;

statement:
    declaration SEMICOLON { $$ = $1; }
    | assignment SEMICOLON { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    | return_statement SEMICOLON { $$ = $1; }
    | print_statement SEMICOLON { $$ = $1; }
    | expression SEMICOLON { $$ = $1; }
    ;

declaration:
    type IDENTIFIER { $$ = set_line(create_node(NODE_VAR_DECL, $2, $1, NULL)); }
    | type IDENTIFIER ASSIGN expression { $$ = set_line(create_node(NODE_VAR_DECL, $2, $1, $4)); }
    ;

type:
    INT_TYPE { $$ = set_line(create_node(NODE_IDENTIFIER, "int", NULL, NULL)); }
    | FLOAT_TYPE { $$ = set_line(create_node(NODE_IDENTIFIER, "float", NULL, NULL)); }
    ;

assignment:
    IDENTIFIER ASSIGN expression { $$ = set_line(create_node(NODE_ASSIGN, $1, $3, NULL)); }
    ;

if_statement:
    IF LPAREN expression RPAREN block { $$ = set_line(create_node(NODE_IF, NULL, $3, $5)); }
    | IF LPAREN expression RPAREN block ELSE block { 
        ASTNode* else_node = set_line(create_node(NODE_BLOCK, "else", $7, NULL));
        $$ = set_line(create_node(NODE_IF, NULL, $3, set_line(create_node(NODE_BLOCK, "then_else", $5, else_node)))); 
    }
    ;

while_statement:
    WHILE LPAREN expression RPAREN block { $$ = set_line(create_node(NODE_WHILE, NULL, $3, $5)); }
    ;

return_statement:
    RETURN expression { $$ = set_line(create_node(NODE_RETURN, NULL, $2, NULL)); }
    ;

print_statement:
    PRINT LPAREN expression RPAREN { $$ = set_line(create_node(NODE_PRINT, NULL, $3, NULL)); }
    ;

expression:
    relational_expr { $$ = $1; }
    ;

relational_expr:
    additive_expr { $$ = $1; }
    | additive_expr LT additive_expr { $$ = set_line(create_node(NODE_BINARY_EXPR, "<", $1, $3)); }
    | additive_expr GT additive_expr { $$ = set_line(create_node(NODE_BINARY_EXPR, ">", $1, $3)); }
    | additive_expr EQ additive_expr { $$ = set_line(create_node(NODE_BINARY_EXPR, "==", $1, $3)); }
    | additive_expr NE additive_expr { $$ = set_line(create_node(NODE_BINARY_EXPR, "!=", $1, $3)); }
    ;

additive_expr:
    multiplicative_expr { $$ = $1; }
    | additive_expr PLUS multiplicative_expr { $$ = set_line(create_node(NODE_BINARY_EXPR, "+", $1, $3)); }
    | additive_expr MINUS multiplicative_expr { $$ = set_line(create_node(NODE_BINARY_EXPR, "-", $1, $3)); }
    ;

multiplicative_expr:
    primary { $$ = $1; }
    | multiplicative_expr MULT primary { $$ = set_line(create_node(NODE_BINARY_EXPR, "*", $1, $3)); }
    | multiplicative_expr DIV primary { $$ = set_line(create_node(NODE_BINARY_EXPR, "/", $1, $3)); }
    ;

primary:
    IDENTIFIER { $$ = set_line(create_node(NODE_IDENTIFIER, $1, NULL, NULL)); }
    | INTEGER_LITERAL { $$ = set_line(create_node(NODE_INT_LITERAL, $1, NULL, NULL)); }
    | FLOAT_LITERAL { $$ = set_line(create_node(NODE_FLOAT_LITERAL, $1, NULL, NULL)); }
    | LPAREN expression RPAREN { $$ = $2; }
    | function_call { $$ = $1; }
    ;

function_call:
    IDENTIFIER LPAREN argument_list RPAREN { $$ = set_line(create_node(NODE_FUNC_CALL, $1, $3, NULL)); }
    | IDENTIFIER LPAREN RPAREN { $$ = set_line(create_node(NODE_FUNC_CALL, $1, NULL, NULL)); }
    ;

argument_list:
    expression { $$ = set_line(create_node(NODE_ARG, NULL, $1, NULL)); }
    | argument_list COMMA expression { $$ = append_node($1, set_line(create_node(NODE_ARG, NULL, $3, NULL))); }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error at line %d: %s (near '%s')\n", line_num, s, yytext);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            perror("Error opening file");
            return 1;
        }
        extern FILE* yyin;
        yyin = file;
    }

    if (yyparse() == 0) {
        printf("\nSemantic Analysis:\n");
        check_semantics(root);

        printf("\n--- Annotated Abstract Syntax Tree ---\n");
        print_ast(root, 0);
        printf("--- End of AST ---\n");
    } else {
        printf("\nParsing failed due to syntax errors.\n");
    }

    return 0;
}
