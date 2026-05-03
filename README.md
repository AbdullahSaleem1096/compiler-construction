# MiniLang Compiler

This project implements a compiler for **MiniLang**, a small typed language designed for compiler construction labs.

## Project Structure
- `lexical_analysis/`: Phase 1 - Lexical Analysis (Flex).
- `syntax_analysis/`: Phase 2 - Syntax Analysis (Bison) and AST construction.
- `test_program.ml`: Sample MiniLang source code for testing.

---

## How to Run Phase 1 (Lexical Analysis)

The lexical analyzer converts the source code into a stream of tokens.

### Step 1: Navigate to the Lexical Analysis Directory
```bash
cd lexical_analysis
```

### Step 2: Generate and Compile the Lexer
```bash
flex lexer.l
gcc lex.yy.c -o lexer
```

### Step 3: Run the Lexer
```bash
./lexer ../test_program.ml
```

---

## How to Run Phase 2 (Syntax Analysis)

The syntax analyzer consumes tokens from the lexer and produces an Abstract Syntax Tree (AST).

### Step 1: Navigate to the Syntax Analysis Directory
```bash
cd syntax_analysis
```

### Step 2: Generate the Parser and Lexer
```bash
bison -d parser.y
flex lexer.l
```

## How to Run Phase 3 (Semantic Analysis)

The semantic analyzer traverses the AST, performs type checking, and manages scopes using a symbol table.

### Step 1: Navigate to the Syntax Analysis Directory
(Note: The main entry point remains the parser, but it now links with the semantic analysis modules).
```bash
cd syntax_analysis
```

### Step 2: Generate the Parser and Lexer
```bash
bison -d parser.y
flex lexer.l
```

### Step 3: Compile with Semantic Analysis Modules
```bash
gcc parser.tab.c lex.yy.c ../semantic_analysis/semantic.c ../semantic_analysis/symbol_table.c -o compiler
```

### Step 4: Run the Compiler
**On a valid program:**
```bash
./compiler ../test_program.ml
```

**On an invalid program (to see error reporting):**
```bash
./compiler ../invalid_program.ml
```

---

## Sample Output
Upon successful parsing, the compiler will print an indented **Abstract Syntax Tree (AST)**:
```text
--- Abstract Syntax Tree ---
Program
  FuncDef: factorial
    Param: n
      Identifier: int
    Block
      VarDecl: result
        Identifier: int
        IntLiteral: 1
      WhileStmt
...
--- End of AST ---
```

## Error Reporting
If the code contains syntax errors, the parser will provide a descriptive message:
```text
Syntax Error at line 10: syntax error (near '}')
Parsing failed due to syntax errors.
```
