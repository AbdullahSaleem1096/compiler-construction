// Test program for MiniLang Lexer
int factorial(int n) {
    int result = 1;
    while (n > 1) {
        result = result * n;
        n = n - 1;
    }
    return result;
}

/* 
   Main function to test
   Multi-line comments
*/
int main() {
    int x = 5;
    float threshold = 100.5;
    
    int fact = factorial(x);
    
    if (fact > threshold) {
        print(fact);
    } else {
        print(0);
    }
    
    // Testing invalid character
    // int invalid = @; 

    return 0;
}
