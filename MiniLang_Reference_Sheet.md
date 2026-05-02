# MiniLang Language Reference Sheet

## 1. Token Set
- **Identifiers**: `[a-zA-Z_][a-zA-Z0-9_]*` (e.g., `x`, `sum_val`, `count1`)
- **Keywords**: `int`, `float`, `if`, `else`, `while`, `return`, `print`
- **Integer Literals**: `[0-9]+` (e.g., `42`, `0`)
- **Float Literals**: `[0-9]+\.[0-9]+` (e.g., `3.14`, `0.5`)
- **Operators**: `+`, `-`, `*`, `/`, `=`, `==`, `!=`, `<`, `>`
- **Delimiters**: `;`, `,`, `(`, `)`, `{`, `}`
- **Comments**: `//` for single-line comments

## 2. Reserved Keywords
| Keyword | Description |
|---------|-------------|
| `int`   | Integer data type |
| `float` | Floating-point data type |
| `if`    | Conditional branch |
| `else`  | Alternative conditional branch |
| `while` | Loop construct |
| `return`| Function return statement |
| `print` | Output statement |

## 3. Operator Precedence & Associativity
| Rank | Operator | Description | Associativity |
|------|----------|-------------|---------------|
| 1    | `( )`    | Parentheses | N/A |
| 2    | `*`, `/` | Multiplicative | Left-to-Right |
| 3    | `+`, `-` | Additive | Left-to-Right |
| 4    | `<`, `>`, `==`, `!=` | Relational | Left-to-Right |
| 5    | `=`      | Assignment | Right-to-Left |

## 4. Formal Grammar (EBNF)
```ebnf
program        = { function_def | global_declaration } ;

global_declaration = declaration ";" ;

function_def   = type identifier "(" [ parameter_list ] ")" block ;

parameter_list = parameter { "," parameter } ;
parameter      = type identifier ;

block          = "{" { statement } "}" ;

statement      = declaration ";"
               | assignment ";"
               | if_statement
               | while_statement
               | return_statement ";"
               | print_statement ";"
               | expression ";" ;

declaration    = type identifier [ "=" expression ] ;
type           = "int" | "float" ;

assignment     = identifier "=" expression ;

if_statement   = "if" "(" expression ")" block [ "else" block ] ;

while_statement = "while" "(" expression ")" block ;

return_statement = "return" expression ;

print_statement = "print" "(" expression ")" ;

expression     = relational_expr ;

relational_expr = additive_expr [ rel_op additive_expr ] ;
rel_op         = "<" | ">" | "==" | "!=" ;

additive_expr  = multiplicative_expr { ( "+" | "-" ) multiplicative_expr } ;

multiplicative_expr = primary { ( "*" | "/" ) primary } ;

primary        = identifier
               | integer_literal
               | float_literal
               | "(" expression ")"
               | function_call ;

function_call  = identifier "(" [ argument_list ] ")" ;
argument_list  = expression { "," expression } ;
```

## 5. Sample MiniLang Code
```c
// Function to calculate factorial
int factorial(int n) {
    int result = 1;
    while (n > 1) {
        result = result * n;
        n = n - 1;
    }
    return result;
}

int main() {
    int x = 5;
    float threshold = 100.0;
    
    int fact = factorial(x);
    
    if (fact > threshold) {
        print(fact);
    } else {
        print(0);
    }
    
    return 0;
}
```
