#ifndef SEMANTIC_H
#define SEMANTIC_H

#include "../syntax_analysis/ast.h"
#include "symbol_table.h"

void check_semantics(ASTNode* node);
char* traverse(ASTNode* node, SymbolTable* st);

#endif
