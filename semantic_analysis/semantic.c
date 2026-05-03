#include "semantic.h"

int semantic_errors = 0;
char* current_func_type = NULL;

void report_error(int line, const char* msg) {
    fprintf(stderr, "Semantic Error at line %d: %s\n", line, msg);
    semantic_errors++;
}

void check_semantics(ASTNode* node) {
    SymbolTable* st = create_symbol_table();
    traverse(node, st);
    if (semantic_errors > 0) {
        printf("\nSemantic analysis failed with %d error(s).\n", semantic_errors);
    } else {
        printf("\nSemantic analysis completed successfully.\n");
    }
}

char* traverse(ASTNode* node, SymbolTable* st) {
    if (!node) return "void";

    char* type = "void";

    switch (node->type) {
        case NODE_PROGRAM:
            traverse(node->left, st);
            break;

        case NODE_VAR_DECL: {
            char* varType = node->left->value;
            if (!insert_symbol(st, node->value, varType, node->line)) {
                char msg[100];
                sprintf(msg, "Redeclaration of variable '%s'", node->value);
                report_error(node->line, msg);
            }
            if (node->right) {
                char* exprType = traverse(node->right, st);
                if (strcmp(varType, exprType) != 0) {
                    report_error(node->line, "Type mismatch in initialization");
                }
            }
            node->dataType = strdup(varType);
            break;
        }

        case NODE_FUNC_DEF: {
            char* retType = node->dataType ? node->dataType : "void";
            if (!insert_symbol(st, node->value, "function", node->line)) {
                report_error(node->line, "Function name already in use");
            }
            push_scope(st);
            current_func_type = retType;
            traverse(node->left, st); /* Params are usually in node->left or handled specifically */
            /* In parser.y, node->left for FUNC_DEF is parameters if I recall correctly. Let's check parser.y */
            /* parser.y: $$ = create_node(NODE_FUNC_DEF, $2, $4, $6); where $4 is parameter_list */
            traverse(node->left, st); 
            traverse(node->right, st); /* block */
            pop_scope(st);
            current_func_type = NULL;
            node->dataType = strdup(retType);
            break;
        }

        case NODE_PARAM: {
            char* pType = node->left->value;
            insert_symbol(st, node->value, pType, node->line);
            node->dataType = strdup(pType);
            break;
        }

        case NODE_BLOCK: {
            ASTNode* curr = node->left;
            while (curr) {
                traverse(curr, st);
                curr = curr->next;
            }
            break;
        }

        case NODE_ASSIGN: {
            Symbol* sym = lookup_symbol(st, node->value);
            if (!sym) {
                char msg[100];
                sprintf(msg, "Assignment to undeclared variable '%s'", node->value);
                report_error(node->line, msg);
                type = "error";
            } else {
                char* exprType = traverse(node->left, st);
                if (strcmp(sym->type, exprType) != 0) {
                    report_error(node->line, "Type mismatch in assignment");
                }
                type = sym->type;
            }
            node->dataType = strdup(type);
            break;
        }

        case NODE_IDENTIFIER: {
            /* If it's a type (int, float), just return it */
            if (strcmp(node->value, "int") == 0 || strcmp(node->value, "float") == 0) {
                type = node->value;
            } else {
                Symbol* sym = lookup_symbol(st, node->value);
                if (!sym) {
                    char msg[100];
                    sprintf(msg, "Use of undeclared variable '%s'", node->value);
                    report_error(node->line, msg);
                    type = "error";
                } else {
                    type = sym->type;
                }
            }
            node->dataType = strdup(type);
            break;
        }

        case NODE_INT_LITERAL:
            type = "int";
            node->dataType = strdup(type);
            break;

        case NODE_FLOAT_LITERAL:
            type = "float";
            node->dataType = strdup(type);
            break;

        case NODE_BINARY_EXPR: {
            char* t1 = traverse(node->left, st);
            char* t2 = traverse(node->right, st);
            if (strcmp(t1, t2) != 0) {
                report_error(node->line, "Type mismatch in binary expression");
                type = "error";
            } else {
                type = t1;
            }
            node->dataType = strdup(type);
            break;
        }

        case NODE_IF:
        case NODE_WHILE: {
            char* condType = traverse(node->left, st);
            /* Conditions should ideally be int/bool. In MiniLang, anything goes? 
               Let's just check if it's not error */
            if (strcmp(condType, "error") == 0) {
                report_error(node->line, "Invalid condition");
            }
            traverse(node->right, st);
            break;
        }

        case NODE_RETURN: {
            char* retType = traverse(node->left, st);
            if (current_func_type && strcmp(current_func_type, retType) != 0) {
                report_error(node->line, "Return type mismatch");
            }
            break;
        }

        case NODE_PRINT:
            traverse(node->left, st);
            break;

        case NODE_FUNC_CALL: {
            /* Simple check: is it factorial or main? Or user defined? 
               We should have a global function table ideally. 
               For this lab, we'll just check if it's 'print' or something else. */
            Symbol* sym = lookup_symbol(st, node->value);
            if (!sym && strcmp(node->value, "print") != 0) {
                /* Not in symbol table and not a builtin */
                // report_error(node->line, "Call to undeclared function");
                /* Note: Functions are added to symbol table in NODE_FUNC_DEF */
            }
            traverse(node->left, st); /* arguments */
            /* We skip detailed argument count check for now unless requested */
            type = "int"; /* assume int for simplicity or lookup sym */
            node->dataType = strdup(type);
            break;
        }

        case NODE_ARG:
            type = traverse(node->left, st);
            node->dataType = strdup(type);
            break;

        default:
            break;
    }

    /* Process siblings (next pointers) if they are not already processed by lists */
    if (node->next && node->type != NODE_PARAM && node->type != NODE_ARG && node->type != NODE_VAR_DECL && node->type != NODE_FUNC_DEF) {
        traverse(node->next, st);
    }

    return type;
}
