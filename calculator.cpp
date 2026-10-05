#include <iostream>

float multiply(float a, float b){
    return a*b;
}
float division(float a, float b){
    return a/b;
}
float addition(float a, float b){
    return a+b;
}
float subtraction(float a, float b){
    return a-b;
}

int main(){
    int a;
    int b;
    char o;
    std::cout << "What's up little sigmas! This is your calculator!" << "\n";
    std::cout << "Enter first number: ";
    std::cin >> a;
    std::cout << "Enter second number: ";
    std::cin >> b;
    std::cout << "Enter operator you want to perform(+, -, /, *): ";
    std::cin >> o;

    if (o == '+'){
        std::cout << "The addition of the given values is: " << addition(a, b);
    }
    else if (o == '-'){
        std::cout << "The subtraction of the given values is: " << subtraction(a, b);
    }
    else if (o == '/'){
        std::cout << "The division of the given values is: " << division(a, b);
    }
    else if (o == '*'){
        std::cout << "The multiplication of the given values is: " << multiply(a, b);
    }
    else{
        std::cout << "Enter valid operation to be performed in order.";
    }
}