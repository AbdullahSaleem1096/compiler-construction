#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Node Types */
typedef enum {
    NODE_PROGRAM,
    NODE_VAR_DECL,
    NODE_FUNC_DEF,
    NODE_BLOCK,
    NODE_IF,
    NODE_WHILE,
    NODE_RETURN,
    NODE_PRINT,
    NODE_ASSIGN,
    NODE_BINARY_EXPR,
    NODE_IDENTIFIER,
    NODE_INT_LITERAL,
    NODE_FLOAT_LITERAL,
    NODE_FUNC_CALL,
    NODE_PARAM,
    NODE_ARG
} NodeType;

/* AST Node Structure */
typedef struct ASTNode {
    NodeType type;
    char* value;            /* Lexeme or operator */
    char* dataType;         /* Evaluated data type (int, float, etc.) */
    struct ASTNode* left;
    struct ASTNode* right;
    struct ASTNode* next;   /* For lists (statements, parameters, etc.) */
    int line;
} ASTNode;

/* Function to create a new AST node */
static inline ASTNode* create_node(NodeType type, char* value, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type;
    node->value = value ? strdup(value) : NULL;
    node->dataType = NULL;
    node->left = left;
    node->right = right;
    node->next = NULL;
    node->line = 0; 
    return node;
}

/* Function to append to a list of nodes */
static inline ASTNode* append_node(ASTNode* list, ASTNode* node) {
    if (!list) return node;
    ASTNode* current = list;
    while (current->next) current = current->next;
    current->next = node;
    return list;
}

/* Function to print the AST */
static inline void print_ast(ASTNode* node, int indent) {
    if (!node) return;

    for (int i = 0; i < indent; i++) printf("  ");

    if (node->dataType) {
        printf("[%s] ", node->dataType);
    }

    switch (node->type) {
        case NODE_PROGRAM: printf("Program\n"); break;
        case NODE_VAR_DECL: printf("VarDecl: %s\n", node->value); break;
        case NODE_FUNC_DEF: printf("FuncDef: %s\n", node->value); break;
        case NODE_BLOCK: printf("Block\n"); break;
        case NODE_IF: printf("IfStmt\n"); break;
        case NODE_WHILE: printf("WhileStmt\n"); break;
        case NODE_RETURN: printf("ReturnStmt\n"); break;
        case NODE_PRINT: printf("PrintStmt\n"); break;
        case NODE_ASSIGN: printf("Assignment: %s\n", node->value); break;
        case NODE_BINARY_EXPR: printf("BinaryExpr: %s\n", node->value); break;
        case NODE_IDENTIFIER: printf("Identifier: %s\n", node->value); break;
        case NODE_INT_LITERAL: printf("IntLiteral: %s\n", node->value); break;
        case NODE_FLOAT_LITERAL: printf("FloatLiteral: %s\n", node->value); break;
        case NODE_FUNC_CALL: printf("FuncCall: %s\n", node->value); break;
        case NODE_PARAM: printf("Param: %s\n", node->value); break;
        case NODE_ARG: printf("Arg\n"); break;
    }

    print_ast(node->left, indent + 1);
    print_ast(node->right, indent + 1);
    print_ast(node->next, indent); /* Next in list stays at same indent */
}

#endif
