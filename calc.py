o = input("Enter operator(+ - * /): ")

n1 = float(input("Enter first number: "))
n2 = float(input("Enter second  number: "))

if o == "+":
    result = n1 + n2
    print(round(result, 3))         #If u write the 3 after the result then first 3 decimals will be printed of the result
elif o == "-":
    result = n1 - n2
    print(round(result, 3))
elif o == "*":
    result = n1 * n2
    print(round(result, 3))
elif o == "/":
    result = n1 / n2
    print(round(result, 3))
    print(f"{o} is not a valid operator\n")
