---
layout: post
title: "Functions in C Language"
date: 2017-02-27 14:43:39 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 110626711474074828223206922383299503229
---
* TOC
{:toc}

* * *

You can write functions to separate parts of your program into distinct subprocedures. To write a function, you must at least create a function definition. It is a good idea also have an explicit function declaration; you don't have to, but if you leave it out, then the default implicit declaration might not match the function itself, and you will get some compile-time warnings.

### 1. Function Declarations

You write a function declaration to specify the name of a function, a list of parameters, and the function's return type. A function declaration ends with a semicolon. Here is the general form:

> return-type function-name (parameter-list);

*return-type* indicates the data type of the value returned by the function. You can declare a function that doesn't return anything by using the return type `void`.

*function-name* can be any valid identifier.

*parameter-list* consists of zero or more parameters, separated by commas. A typical parameter consists of a data type and an optional name for the parameter. You can also declare a function that has a variable number of parameters, or no parameters using `void`. **Leaving out *prameter-list* entirely aslo indicates no parameters, but it is better to specify it explicitly with `void`**.

You should write the function declaration above the first use of the function. You can put it in a header file and use the `#include` directive to include that function declaration in any source code files that use the function.

### 2. Function Definitions

You write a function definition to specify what a function actually does. A function definition consists of informaiton regarding the function's name, return type, and types and names of parameters, along with the body of the function. The function body is a series of statements enclosed in braces; in fact it is simply a block.

Here is the general form of a function definition:

```
return-type function-name (parameter-list)
{
    function-body
}
```

*return-type* and *function-name* are the same as what you use in the function declaration.

*parameter-list* is the same as the parameter list used in the function declaration, except you *must* include names for the parameters in a function definition.

### 3. Calling Functions

You can call a function by using its name and supplying any needed parameters. Here is the general form of a function call:

> function-name (parameters)

A function call can make up an entire statement, or it can be used as a subexpression.

### 4. Function Parameters

Function parameters can be any expression—a literal value, a value stored in variable, a address in memory, or a more complex expression built by combining these.

***Within the function body, the parameter is a local copy of the value passed into the function; you cannot change the value passed in by changing the local copy.***

If the value that you pass to a function is a memory address (that is, a pointer), then you can access(and change) the data stored at the memory address. This achieves an effect similar to pass-by-reference in other languages, but is not the same: the memory address is simply a value, just like any other value, and cannot itself be changed. The difference between passing a pointer and passing an integer lies in what you can do using the value within the function.

Here is an example of calling a function with a pointer parameter:

```c
void foo(int *x)
{
    *x = *x + 42;
}

// ...
int a = 15;
foo(&a);
```

The formal parameter for the function is of type `pointer-to-int`, and we call the function by passing it the address of a variable of type `int`. By dereferencing the pointer within the function body, we can both see and change the value stored in the address. The above changes the value of `a` to '57'.

Even if you don't want to change the value stored in the address, passing the address of a variable rather than the variable itself can be useful if the variable type is large and you need to conserve memory space or limit the performance impact of parameter copying. For example:

```c
struct foo
{
    int x;
    float y;
    double z;
};

void bar (const struct foo *a);
```

In this case, unless you are working on a computer with very large memory address, it will take less memory to pass a pointer to the structure than to pass an instance of the structure.

One type of parameter that is always passed as a pointer is any sort of array:

```c
void foo (int a[]);
// ...
int x[100];
foo (x);
```

In this example, calling the function `foo` with the parameter `a` does not copy the entire array into a new local parameter with `foo`, it passes `x` as a pointer to the first element in `x`. Be careful, though: within the function, you cannot use `sizeof` to determine the size of the array `x`—`sizeof` instead tells you the size of the pointer `x`. Indeed, the above code is equivalent to:

```c
void foo (int *a);
// ...
int x[100];
foo (x);
```

Explicitly specifying the length of the array in the parameter declaration will not help. If you really need to pass an array by value, you can wrap it in a `struct`, though doing this will rarely be useful(passing a `const`-qualified pointer is normally sufficient to indicate that the caller should not modify the array).

### 5. Variable Length Parameter Lists

You can write a function that takes a variable number of arguments; these are called *variadic functions*. To to this, the function needs to have at least one parameter of a known data type, but the remaining paramters pare optional, and can vary in both quantity and data type.

You list the initial parameters as normal, but then after that, use an ellipsis:'...'. Here is an exmaple function prototype:
> int add_multiple_values (int number, ...);

To work with the optional parameters in the function definition, you need to use macros that are defined in the library header file ***<stdarg\.h>***, so you must `#include` that file. For a detailed description of there macros, see *The GNU C Library* manual's section on variadic functions.

Here is an example:

```c
int add_multiple_values(int number, ...)
{
    int counter, total = 0;
    /* Declare a variable of type ‘va_list’. */
    va_list parameters;
    /* Call the ‘va_start’ function. */
    va_start(parameters, number);

    for(counter = 0; counter < number; counter++) {
        /* Get the values of the optional parameters. */
        total += va_arg(parameters, int);
    }

    /* End use of the ‘parameters’ variable. */
    va_end(parameters);
    return total;
}
```

To use optional parameters, you need to have a way to know how many there are. This can vary, so it can't be hard-coded, but if you don't know how many optional parameters you have, then you could have difficulty knowing when to stop using the `va_arg` function. In the above example, the first parameter to the `add_multiple_values` function, `number` , is the number of optional parameters actually passed. So, we minght call the function like this:

> sum = add_multiple_values (3, 12, 34, 190);

The first parameter indicates how many optional parameters follow it.

Also, note that you don't actually need to use `va_end` function. In fact, with GCC it doesn't do anything at all. However, you might want to include it to maximize compatibility with other compilers.

### 6. Calling Functions Through Function Pointers

You can also call a function identified by a pointer. The indirection operator `*` is optional when doing this.

```c
#include <stdio.h>

void foo(int i)
{
    printf("foo %d!\n", i);
}

void bar(int i)
{
    printf("%d bar!\n", i);
}

void message(void (*func)(int), int times)  /* func is a pointer to function returning void. */
{
    int j;

    for(j = 0; j < times; ++j)
        func(j);    /*  (*func) (j); would be equivalent. */
}

void example(int want_foo)
{
    void (*pf)(int) = &bar; /* The & is optional. */

    if(want_foo)
        pf = foo;

    message(pf, 5);
}
```

### 7. The `main` Function

Every program requires at least one function, called `main`. This is where the program begins executing. You do not need to write a declaration or prototype for `main`, but you do need to define it.

The return type for `main` is always `int`. You do not have to specify the return type for `main`, but you can. However, you *cannot* specify that it has a return type other than `int`.

In general, the return value from `main` indicates the program's *exit status*. A value of zero or `EXIT_SUCCESS` indicates success and `EXIT_FAILURE` indicates an error. Otherwise, the significance of the value returned is implementation-defined.

Reaching the `}` at the end of `main` without a return, or executing a `return` statement with no value (that is, `return;`) are both eauivalent. In C89, the effect of this is undefined, but in C99 the effect is equivalent to `return 0;`.

You can write your `main` function to have no parameters (that is, as `int main (void)`), or to accept parameters from the command line. Here is a very simple `main` function with no parameters:

```c
int main (void)
{
    puts ("Hi there!");
    return 0;
}
```

To accept command line parameters, you need to have two parameters in the `main` function, `int argc` followed by `char *argv[]`. You can change the names of those paramters, but they must have those data types—`int` and array of pointers to `char`. `argc` is the number of command line strings. `argv[0]`, the first element in the array, is the name of the program as typed at the command line; any following array elements are the parameters that followed the name of the program.

Here is an exmaple `main` function that accepts command line parameters, and prints out what those parameters are:

```c
int main(int argc, char *argv[])
{
    int counter;

    for(counter = 0; counter < argc; counter++)
        printf("%s\n", argv[counter]);

    return 0;
}
```

### 8. Recursive Functions

You can write a function that is recursive—a function that calls itself. Here is an example that computes the factorial of an integer.

```c
int factorial(int x)
{
    if(x < 1)
        return 1;
    else
        return (x * factorial(x - 1));
}
```

Be careful that you do not write a function that infinitely recursive. In the above example, once `x` is 1, the recursion stops. However, int the following example, the recursion does stop until the program is interrupted or runs out of memory:

```c
int watermelon(int x)
{
    return (watermelon(x));
}
```

Functions can also be indirectly recursive, of course.

### 9. Static Functions

You can define a function to be static if you want it to be callable only within the source file where it is defined:

```c
static int foo(int x)
{
    return x + 42;
}
```

This is useful if you are building a reusable library of functions and need to include some subroutines that should not be callable by the end user.

Functions which are defined in this way are said to have *static linkage*. Unfortuanately the `static` keyword has multiple meanings.

### 10. Nested Functions

As a GNU C extension, you can define functions within other function, a technique known as nesting functions.

Here is an example of a tail-recursive factorial function, defined using a nested function:

```c
int factorial(int x)
{
    int factorial_helper(int a, int b) {
        if(a < 1) {
            return b;
        } else {
            return factorial_helper((a - 1), (a * b));
        }
    }
    return factorial_helper(x, 1);
}
```

Note that nested functions must be defined along with variable declarations at the begings of a function, and all other statements follow.

* * *

### 11. References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Functions)
