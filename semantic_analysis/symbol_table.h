#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Symbol {
    char* name;
    char* type;         /* int, float, function */
    int scopeLevel;
    int line;
    struct Symbol* next;
} Symbol;

typedef struct Scope {
    Symbol* symbols;
    struct Scope* parent;
    int level;
} Scope;

typedef struct SymbolTable {
    Scope* currentScope;
} SymbolTable;

SymbolTable* create_symbol_table();
void push_scope(SymbolTable* st);
void pop_scope(SymbolTable* st);
int insert_symbol(SymbolTable* st, char* name, char* type, int line);
Symbol* lookup_symbol(SymbolTable* st, char* name);
Symbol* lookup_symbol_local(SymbolTable* st, char* name);

#endif
