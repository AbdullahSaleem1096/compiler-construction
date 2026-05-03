// Program with deliberate semantic errors for Phase 3 testing

int main() {
    int x = 10;
    float y = 5.5;
    
    // 1. Undeclared variable use
    z = 20; 
    
    // 2. Type mismatch in assignment (float to int)
    x = y; 
    
    // 3. Redeclaration of variable in same scope
    int x = 100; 
    
    // 4. Type mismatch in binary expression
    int sum = x + y; 
    
    // 5. Use of undeclared variable in expression
    int result = x + unknown_var;

    if (x > y) {
        // Nested scope
        int local_val = 1;
    }
    
    // 6. Accessing variable outside its scope
    print(local_val); 

    return 5.5; // 7. Return type mismatch (int function returning float)
}

int another_func() {
    // 8. Assignment to undeclared variable
    count = 1;
    return 0;
}
