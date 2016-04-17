---
layout: post
title: "C Programming Language 1 - Overview"
date: 2016-04-17 15-55-07 +0800
categories: ['C'] 
tags: ['C', 'C Programming Language'] 
disqus_identifier: 143312454441662558015581744019953861071
---
### 1.1 Getting Started

    #include <stdio.h>

    main()
    {
        printf("Hello, 世界！\n");
    }

A C program, whatever its size, consists of **function**s and **variable**s.

A function contains **statement**s that specify the computing operations to be done, and variables store values used during the computation.

**main** is special and your program begins executing at the beginning of main. main will usually call other functions, some that you wrote, and others from libraries.

One method to communicating data between function is for the calling function to provide a list of values, called **argument**s, to the function it calls.

A sequence of characters in double quotes, like **"Hello, 世界！\n"**, is called a **character string** or **string constant**.

An **escape sequence** like **'\n'** provides a general and extensible mechanism for representing hard-to-type or invisible characters.

### 1.2 Variables and Symbolic Constants

##### <sup>o</sup>C=(5/9)(<sup>o</sup>F-32)

    #include <stdio.h>
    
    #define LOWER 0     /* lower limit of table */
    #define UPPER 300   /* upper limit */
    #define STEP  20    /* step size */
    
    /* print Fahrenheit-Celsius table */
    main()
    {
        int fahr;
        
        for (fahr = LOWER; fahr <= UPPER; fahr = fahr + STEP)
            printf("%3d %6.1f\n", fahr, (5.0/9.0)*(fahr-32));
    }

Any character between **/\*** and **\*/** are ignored by the **compiler**; they may be used freely to make a program easier to understand.

A variable **declaration** announces the properties of variables; it consists of a name and a list of variables, such as `int fahr;`.

The type **int** means that the variables listed are integers.

It's bad practice to bury "**magic number**" like *300* and *200* in a program; they convey little information to someone who might have to read the program later, and they are hard to change in a systematic way. A **#define** line defines a **symbolic name** or **symbolic constant** to be a particular string of characters:

    #define name replacement text

Thereafter, any occurence of **name** (not in quotes and not part of anohter name) will be replaced by the corresponding **replacement text**.

### 1.3 Character Input and Output

There is no input and output defined in C itself. The model of input and output are supported by the **standard library**.

    #include <stdio.h>
    
    /* copy input to output; 1st version  */
    main()
    {
        int c;
        
        c = getchar();
        while (c != EOF) {
            putchar(c);
            c = getchar();
        }
    }

The problemn is distinguishing the end of input from valid data. The solution is that **getchar** returns a distinctive value when there is no more input, a value that cannot be confused with any real character. This value is called **EOF**, for "end of file". We must declare **c** to be a type big enough to hold any value that **getchar** returns. We cann’t us **char** since **c** must be big enough to hold **EOF** in addition to any possible char. Therefore we use **int**.

**EOF** is an integer defined in **&lt;stdio.h&gt;**.

### 1.4 Functions

In C, a function is equivalent to a subroutine or function in Fortran, or procedure or function in Pascal. A function provides a convenient way to **encapsulate** some computation to ignore **how** a job is done and know **what** is done is sufficient.

    #include <stdio.h>
    
    int power(int m, int n);
    
    /* test power function */
    main()
    {
        int i;
        
        for (i = 0; i < 10; ++i)
            printf("%d %d %d\n", i, power(2, i), power(-3, i));
        return 0;
    }
    
    /* power: raise base to n-th power; n >= 0 */
    int power(int base, int n)
    {
        int i, p;
        
        p = 1;
        for (i = 1; i <= n; ++i)
            p = p * base;
        return p;
    }

A funciton definition has this form:
    
    return-type funciton-name(parameter declarations, if any)
    {
        declarations
        statements
    }

The declaration `int power(int base, int n);` just before **main** says that **power** is a function that expect two **int** arguments and return an **int**. This declaration, which is called a **funciton prototype**, has to agree with the definition and uses of **power**. Indeed, parameter names are optional in a funciton prototype.

#### 1.4.1 Arguments - Call by Value

In C, all funciton arguments are passed "**by value**". This means that the called function is given the values of it arguments in temporary variables rahter than the originals. This leads to some different properties than are see with "**call by reference**" languages like Fortran or with var pratrameters in Pascal, in which the called routine has access to the original argument, not a local copy.

When the name of an array is used as an argument, the value passed to the function is the **location** or **address** of the **beginning of the array**-there is no copying of array elements. By subscripting this value, the function can access and alter any argument of the array.

### 1.5 Character Arrays

    /* getline: read a line into s, return length */
    int getline(char s[], int lim)
    {
        int c, i;
        
        for (i=0; i < lim-1 && (c=getchar()) != EOF && c!='\n'; ++i)
            s[i] = c;
        if (c == '\n') {
            s[i] = c;
            ++i;
        }
        s[i] = '\0';
        return i;
    }

**getline** puts the character **'\0'** (the **null character**, whose value is zero) at the end of the array **char line[]**, to mark the end of the string of characters. This conversion is also used by the C language: when a string constant like `"hello\n"` appears in a C program, it stored as an array of characters containing the characters in the string and terminated with **'\0'** to mark the end.

<img src="/assets/images/character_array.png" style="display: block; margin: 0 auto; width:300px">

The **%s** format specification in **printf** expects the corresponding argument to be a string represented in this form.

### 1.6 External Variable and Scope

    #include <stdio.h>
    
    #define MAXLINE 1000    /* maxmum input line length */
    
    int max;                /* maximum length seen so far */
    char line[MAXLINE];     /* current input line */
    char longest[MAXLINE];  /* longest line saved here */
    
    int getline(void);
    void copy(void);
    
    /* print the longest input line */
    main()
    {
        int len;
        extern int max;
        extern char longest[];
        
        max = 0;
        while((len = getline()) > 0)
            if (len > max) {
                max = len;
                copy();
            }
        if (max > 0)    /* there was a line */
            printf("%s", longest);
        return 0;
    }
    
    int getline(void)
    {
        int c, i;
        extern char line[];
        
        for (i = 0; i < MAXLINE - 1
            && (c = getchar()) != EOF && c != '\n'; i++)
            line[i] = c;
        if (c == '\n') {
            line[i] = c;
            ++i;
        }
        line[i] = '\0';
    }
    
    void copy(void)
    {
        int i;
        extern char line[], longest[];
        
        while((longest[i]=line[i]) != '\0')
            ++i;
    }

The variables that are declared within function are private or local to the function. Each local variable in a funcitoni comes into existence only when then function is called, and disappears when the function is exited. This is why such variables are usually known as **automatic variable**s, following terminology in other languages.

As an alternative to automatic variables, is is possiable to define variables that are **external** to all funcitons, that is, variables that can be accessed by name by any function. **External variable**s remain in existence permanently, rather than appearing and disappearing as funcitons are called and exited, they retain their value even after the functions that set them value have returned.

An **externel variable** must be defined, exactly once, outside of any function; this sets aside storage for it. The variable must also be declared in each funciton that wants to access it; this states the type of the variable.

* * *

#### References

* [The C Programming Language 2nd Edition by Brian W. Kernighan (Author), Dennis M. Ritchie (Author)](http://www.amazon.com/Programming-Language-Brian-W-Kernighan/dp/0131103628/ref=sr_1_1?ie=UTF8&qid=1460658948&sr=8-1&keywords=c+programming+language)
