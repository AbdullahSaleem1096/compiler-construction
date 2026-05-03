#include "symbol_table.h"

SymbolTable* create_symbol_table() {
    SymbolTable* st = (SymbolTable*)malloc(sizeof(SymbolTable));
    st->currentScope = NULL;
    push_scope(st); /* Global scope */
    return st;
}

void push_scope(SymbolTable* st) {
    Scope* newScope = (Scope*)malloc(sizeof(Scope));
    newScope->symbols = NULL;
    newScope->parent = st->currentScope;
    newScope->level = st->currentScope ? st->currentScope->level + 1 : 0;
    st->currentScope = newScope;
}

void pop_scope(SymbolTable* st) {
    if (!st->currentScope) return;
    Scope* oldScope = st->currentScope;
    st->currentScope = oldScope->parent;
    
    /* Free symbols in the scope */
    Symbol* s = oldScope->symbols;
    while (s) {
        Symbol* next = s->next;
        free(s->name);
        free(s->type);
        free(s);
        s = next;
    }
    free(oldScope);
}

int insert_symbol(SymbolTable* st, char* name, char* type, int line) {
    if (lookup_symbol_local(st, name)) {
        return 0; /* Already declared in this scope */
    }
    
    Symbol* s = (Symbol*)malloc(sizeof(Symbol));
    s->name = strdup(name);
    s->type = strdup(type);
    s->scopeLevel = st->currentScope->level;
    s->line = line;
    s->next = st->currentScope->symbols;
    st->currentScope->symbols = s;
    return 1;
}

Symbol* lookup_symbol(SymbolTable* st, char* name) {
    Scope* s = st->currentScope;
    while (s) {
        Symbol* sym = s->symbols;
        while (sym) {
            if (strcmp(sym->name, name) == 0) return sym;
            sym = sym->next;
        }
        s = s->parent;
    }
    return NULL;
}

Symbol* lookup_symbol_local(SymbolTable* st, char* name) {
    if (!st->currentScope) return NULL;
    Symbol* sym = st->currentScope->symbols;
    while (sym) {
        if (strcmp(sym->name, name) == 0) return sym;
        sym = sym->next;
    }
    return NULL;
}
