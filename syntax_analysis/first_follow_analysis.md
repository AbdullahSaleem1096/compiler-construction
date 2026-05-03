# First and Follow Set Analysis (Phase 2)

This document provides the theoretical analysis of the MiniLang grammar used in the Bison parser.

## 1. Grammar Classification
The grammar implemented in `parser.y` is **LR(1)** (specifically LALR(1) as handled by Bison).

**Why LR(1)?**
- **Bottom-Up Parsing**: The grammar contains left-recursive rules (e.g., `global_list: global_list global_item`), which are naturally handled by LR parsers but would cause infinite recursion in LL(1) parsers.
- **Lookahead**: Bison uses one token of lookahead to decide between shift and reduce actions.
- **Conflict Resolution**: The grammar uses precedence and associativity declarations (`%left`, `%right`) to resolve ambiguities in arithmetic expressions and assignment, which is a feature of LR parsers.

The grammar is **NOT LL(1)** because:
- It contains left-recursion.
- Many rules share common prefixes (e.g., `declaration` and `type` both start with `int` or `float`), requiring left-factoring which was not performed to keep the grammar intuitive for LR parsing.

---

## 2. First and Follow Sets

Below are the computed sets for the primary non-terminals in the grammar.

| Non-Terminal | First Set | Follow Set |
|--------------|-----------|------------|
| `program` | `{int, float, ε}` | `{$}` |
| `global_list` | `{int, float}` | `{int, float, $}` |
| `global_item` | `{int, float}` | `{int, float, $}` |
| `function_def` | `{int, float}` | `{int, float, $}` |
| `type` | `{int, float}` | `{IDENTIFIER}` |
| `block` | `{ '{' }` | `{int, float, else, return, print, if, while, IDENTIFIER, '}', $}` |
| `statement` | `{int, float, if, while, return, print, IDENTIFIER, '(', INTEGER_LITERAL, FLOAT_LITERAL}` | `{int, float, if, while, return, print, IDENTIFIER, '}', '('}` |
| `declaration` | `{int, float}` | `{';'}` |
| `expression` | `{IDENTIFIER, INTEGER_LITERAL, FLOAT_LITERAL, '('}` | `{';', ')', ','}` |
| `primary` | `{IDENTIFIER, INTEGER_LITERAL, FLOAT_LITERAL, '('}` | `{*, /, +, -, <, >, ==, !=, ;, ), ,}` |

### Detailed Derivation (Selected Examples)
- **First(type)**: Derived from rules `type: INT_TYPE | FLOAT_TYPE`. Thus, `{int, float}`.
- **First(expression)**: Since `expression -> relational_expr -> additive_expr -> multiplicative_expr -> primary`, `First(expression)` is `First(primary)`, which includes `IDENTIFIER`, `INTEGER_LITERAL`, `FLOAT_LITERAL`, and `'('`.
- **Follow(type)**: Used in `declaration: type IDENTIFIER`. So `IDENTIFIER` is in `Follow(type)`. Also used in `parameter: type IDENTIFIER`.

---

## 3. Parsing Strategy
The parser uses the **LALR(1)** algorithm. This is sufficient for MiniLang because the grammar is deterministic and conflicts (like the dangling-else) are resolved by Bison's default shift preference or explicit precedence.

### Error Handling
Descriptive error messages are implemented by:
1. Using a custom `yyerror` that prints the current token (`yytext`).
2. Providing context (line number) from the lexer's `line_num` variable.
