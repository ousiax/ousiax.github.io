---
layout: post
title: "C Programming Language (1) - Overview"
date: 2016-04-15 01-32-42 +0800
categories: ['C',]
tags: ['C', 'Programming Language']
disqus_identifier: 4904530486998316446927979528588566262
---
### 1\.1 Getting Started

The only way to learn a new programming language is by writing programs in it.

The first program to write is the same for all languages: *Print the words* of **hello, world**.

    #include<stdio.h>       // include informaiton about standard library
    main()                  // define a function called main
                            // that received no argument values
    {                       // statements of main are enclosed in braces
        printf("hello, world\n"); // main calls library function printf
                                  // to print this sequence of characters \n represents the newline character.
    }


A C program, whatever its size, consists of ***functions*** and ***variables***.

A function contains ***statements*** that specify the computing operations to be done, and variables store values used during the computaiton.

**main** is special and your program begins executing at the beginning of main.

**main** will usually call other functions to help perform its job, some that you wrote, and othes from libraries that are provied for you.

One method to communicating data between function is for the calling function to provide a list of values, called ***arguments***, to the funciton it calls. The parentheses after the function name surround the argument list.

A sequence of characters in double quotes, like "**hello, world\n**", is called a ***character string*** or ***string constant***.

**printf** never supplies a newline character automatically, so several calls may be used to build up an output line in stages.

An ***escape sequence*** like **\n** provides a general and extensible mechanism for representing hard-to-type or invisible characters.

* Compiling

        cc hello.c

* Run 

        ./a.out

#### 1.2 Variables and Arithmetic Expressions

    #include <stdio.h>
    
    /* print Fahrenheit-Celsius table
        for fahr = 0, 20, ..., 300 */
    main()
    {
        int fahr, celsius;
        int lower, upper, step;
        
        lower = 0;      /* lower limit of temperature scale */
        upper = 300;    /* upper limit */
        step = 20;      /* step size */
        
        fahr = lower;
        while (fahr <= upper) {
            celsius = 5 * (fahr-32) / 9;
            printf("%d\t%d\n", fahr,celsius);
            fahr = fahr + step;
        }
    }

Any characters between **/\*** and **\*/** are ignored by the compiler; they *may be* used freely to make a program easier to understand.

In C, all variables must be declared before they are used, usually at the beginning of the function before any executable statements.

A ***declaration*** annouces the properties of variables; it consists of a name and a list of variables, such as

    int fahr, celsius;
    int lower, upper, step;

The type **int** means that the variables listed are integers; by contrast with **float**, which means floating point, i.e., numbers that may have a fractional part.

The range of both **int** and **float** depends on the machine you are using; 16-bits, which lie between -32768 and +32767, are common, as are 32-bit ints. A **float** number is typically a 32-bit quantity, with at least six significant digits and magnitude generally between about 10<sup>-38</sup> and 10<sup>38</sup>.

Computation in the temperature conversion program begins with the ***assignment statements***

    lower = 0;
    upper = 300;
    step = 20;

which set the variables to their initial values.

Each line of the table is computed the same way, so we use a loop that repeats once per output line; this is the purpose of the **while** loop

    while (fahr <= upper) {
        ...
    }

The body of a **while** can be one or more statements enclosed in braces, as in the temperature converter, or a single statement without braces, as in

    while (i < j)
        i = 2 * i

In either case, we will always indent the statements controlled by the **while** by one tab stop (which we have shown as four spaces) so you can see at a glance which statements are inside the loop. The rndentation emphasizes the **logical structure** of the program. Although C compilers do not care about how a program looks, proper indentation and spacing are critical in making programs easy for people to read. We recommend writing only **one statement per line**, and **using blanks around operators to clarify grouping**. The position of braces is less important, although people hold passionate beliefs. We have chosen one of several popular styles. **Pick a style that suits you, then use it consistently**.

The Celsius temperature is computed and assigned to the variable **celsius** by the statement

    celsius = 5 * (fahr-32) / 9;

The reason for multiplying by 5 and dividing by 9 instead of just multiplying by 5/9 is that in C, as in many other languages, integer division ***truncates***: any fractional part is discarded.

By the way, **printf** is not part of the C language; *there is no input or output defined in C itself*. **printf** is just a useful function from the standard library of functions that are normally accessible to C programs. *The behaviour of **printf** is defined in the ANSI standard*, however, so its properties should be the same with any compiler and library that conforms to the standard.

#### 1.3 The **for** statement

    #include <stdio.h>
    
    /* print Fahrenheit-Celsius table */
    main()
    {
        int fahr;
        
        for (fahr = 0; fahr <= 300; fahr = fahr + 20)
            printf("%3d %6.1f\n", fahr, (5.0/9.0)*(fahr-32));
    }

The **for** statement is a loop, a generalization of the **while**. Within the parenthese, there are three parts, separated by semicolons. The first part, the *initialization*

    fahr = 0

is done once, before the loop proper is entered. The second part is the *test* or *condition* that contraols the loop:

    fahr <= 300

This conditoin is evaluated; if it is true, the body of the loop (here a single **printf**) is executed. The the *increment* step

    fahr = fahr + 20

is executed, and the conditon re-evaluated. The loop terminates if the condition has become false. The *initialization*, *condition*, and *increment* can be any expressions.

#### 1.4 Symbolic Constants

It's bad practice to bury **``magic number''** like 300 and 200 in a program; they convey little information to someone who might have to read the program later, and they are hard to change in a systematic way. One way to deal with magic numbers is to give them meaningful names. A **#define** line defines a ***symbolic name*** or ***symbolic constant*** to be a particular string of characters:

    #define name replacement list

Thereafter, any occurrence of ***name*** (not in quotes and not part of another name) will be replaced by the corresponding ***replacement text***. The ***name*** has the same form as a variable name: a sequence of letters and digits that begins with a letter. The ***replacement text*** can be any sequence of characters; it is not limited to numbers.

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

The quantities **LOWER**, **UPPER** and **STEP** are symbolic constants, not varialbes, to they do not appear in declarations. Symbolic constant names are conventionally written in upper case so they can ber readily distinguished from lower case variables names. *Notice that there is no semicolon at the end of a **#define** line.*

#### 1.5 Character Input and Output

The model of input and output supported by the **standard library** is very simple. Text input or output, regardless of where is originates or where it goes to, is dealt with as streams of characters. A ***text stream*** is a sequence of characters divided into lines; each line consists of zero or more characters followed by a newline character. It is the responsibility of the library to make each input or output stream confirm this model; the C programmer using the library need not worry about how lines are represented outside the program.

The standard library provides several functions for reading or writing one character at a time, of which **getchar** and **putchar** are the simplest. Each time it is called, **getchar** reads the *next input character* from a text stream and returns that as its value. That is, after

    c = getchar();

the variable **c** contains the next character of input.

The functioni **putchar** prints a character each time it is called:

    putchar(c)

prints the contents of the integer variable **c** as character.

**1.5.1 File Copying**

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

What appears to be a character on the keyboard or screen is of course, like everything else, stored internally just as a bit pattern.

The problemn is distinguishing the end of input from valid data. The solution is that **getchar** returns a distinctive value when there is no more input, a value that cannot be confused with any real character. This value is called **EOF**, for ``end of file''. We must declare **c** to be a type big enough to hold any value that **getchar** returns. We cann't use **char** since **c** must be big enough to hold **EOF** in addition to any possible **char**. Therefore we use **int**.

**EOF** is an integer defined in &lt;stdio.h&gt;.

In C, any assignment, such as 

    c = getchar();

is an expression and has a value, which is the value of the left hand side after the assignment. This means that a assignment can appear as part of a larger expression.

    #include <stdio.h>

    main()
    {
        int c;

        while((c = getchar()) != EOF)
            putchar(c);
    }

**1.5.2 Character Counting**

    #include <stdio.h>

    /* count characters in input */
    main()
    {
        long nc;

        nc = 0;
        while (getchar() != EOF)
            ++nc;
        printf("%ld\n", nc);
    }

The character counting program accumulates its count in a **long** variable insead of an **int**. **long** integers are at least 32 bits. Although on some machines, **int** and **long** are the same size, on others an **int** is 16 bits, with a maximum value of 32767, and it would take relatively little input to overflow an **int** counter. The conversion specification **%ld** tells **printf** that the corresponding arugment is a **long** integer.

**1.5.3 Line Counting**

    #include <stdio.h>
    
    /* count lines in input */
    main()
    {
        int c, nl;
        
        nl = 0;
        while ((c = getchar()) != EOF)
            if (c == '\n')
                ++nl;
        printf("%d\n", n1)
    }

The double equals sign **==** is the C notation for ``is equal to'' (like Pascal's single = or Fortran's .EQ.). *A word of caution: newcomers to C occasionally write = when they mean ==.*

*A character written between single quotes represents an integer value to the numerical value of the character in the machine's character set*. This is called a ***character constant***, although it is just another way to write a small integer. **'A'** is a character constant; in the ASCII character set its value is **65**, the internal representation of the character **A**. Of course, **'A'** is to be preferred over **65**: it meaning is obvious, and it is independent of a praticular character set.

The escape sequences used in string constants are also legal in character constant, so **'\n'** stand for the value of the newline character, which is 10 in ASCII.

#### 1.6 Arrays

    #include <stdio.h>
    
    /* count digits, white space, others */
    main()
    {
        int c, i, nwhite, nother;
        int ndigit[10];
        
        nwhite = nother = 0;
        for (i = 0; i < 10; ++i)
            ndigit[i] = 0;
        
        while ((c = getchar()) != EOF)
            if (c >= '0' && c <= '9')
                ++ndigit[c-'0'];
            else if (c == ' ' || c == '\n' || c == '\t')
                ++nwhite;
            else
                ++nother;
            
            printf("digits =");
            for (i = 0; i < 10; ++i)
                printf(" %d", ndigit[i]);
            printf(", white space = %d, other = %d\n",
                nwhite, nother);
    }

The declaration

    int ndigit[10];

declares **ndigit** to be an array of 10 integers. *Array subscripts always start at zero in C, so the elements are ndigit[0], ndigit[1], ..., ndigit[9]*.

A subscript can be any integer expression, which includes integer variables like **i**, and integer constants.

This particular program relies on the properties of the character representation of the digits. For example, the test

    if (c >= '0' && c <= '9')

determines whether the character in **C** is a digit.

By definition, **char**s are just small integers, so **char** variables and constants are identical to **int**s in arithmetic expressions.

#### 1.7 Functions

In C, a function is equivalent to a subroutine or function in Fortran, or procedure or function in Pascal. A function provides a convenient way to encapsulate some computation, which can then be used without worring about its implementation. With properly desigined functions, it is possiable to ignore *how* a job is done; knowing *what* is done is sufficient.

Since C has no exponentiation operator like **\*\*** of Fortran, let us illustrate the mechanics of function definition by writing a function **power(m,n)** to raise an integer **m** to a positive integer power **n**.

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

A function definition has this form:

    return-type funciton-name(parameter declarations, if any)
    {
        declarations
        statements
    }

Function definitions can appear in any order, and in one source file or several, although no function can be split between files.

The first line of **power** itself,

    int power(int base, int n)

declares the parameter types and names, and the type of the reusult that the function returns.

We will generally use *parameter* for a variable named in the parenthesized list in a function. The terms *formal arugment* and *actual argument* are sometimes used for the same distinction.

The value that **power** computes is returned to **main** by the **return**: statement. Any expression may follow **return**:

    return expression;

A function need not return a value; a return statement with no expression causes control, but no useful value, to be returned to the caller, as does ``falling off the end'' of a function by reaching the terminating right brace. And the calling function can ignore a value returned by a function.

The declaration

    int power(int base, int n);

just before **main** says that **power** is a function that expect two **int** arguments and return an **int**. This declaration, which is called a ***function prototype***, has to agree with the definition and uses of **power**. It is an error if the definitioni of a function or any uses of it do not agree with its prototype.

parameter names need not agree. Indeed, parameter names are optional in a function prototype, so for the prototype we could have written

    int power(int, int);

Well-chosen names are good documentation however, so we will often use them.

#### 1.8 Arguments - Call by Value

In C, all function arguments are passed ''**by value**.'' This means that the called function is given the values of it arguments in temporary variables rather than the originals. This leads to some different properties than are see with ''**call by reference**'' languages like Fortran or with var parameters in Pascal, in which the called routine has access to the original argument, not a local copy.

When necessary, it is possible to arrange for a function to modify a varible in a calling routine. The caller must provide the ***address*** of the variable to be set (technically a ***pointer*** to the variable), and the called function must declare the parameter to be a pointer and access the variable indirectly through it.

When the name of an array is used as an argument, the value passed to the function is *the location or address of the beginning of the array*—there is no copying of array elements. By subscripting this value, the funciton can access and alter any argument of the array.

#### 1.9 Character Arrays

The most common type of array in C is the array of characters. To illustrate the use of character arrays and funcitons to manipulate them, let's write a program that reads a set of text lines and prints the longest. The outline is simple enough:

    while (there's another line)
        if (it's longer than the previous longest)
            (save it)
            (save its length)
    print longest line

Here is the program result.

    #include <stdio.h>
    #define MAXLINE 1000    /* maximum input line length */
    
    int getline(char line[], int maxline);
    void copy(char to[], char from[]);
    
    /* print the longest input line */
    main()
    {
        int len;            /* current line lenght */
        int max;            /* maximum length seen so far */
        char line[MAXLINE];     /* current input line */
        char longest[MAXLINE];  /* longest line saved here */
        
        max = 0;
        while ((len = getline(line, MAXLINE)) > 0)
            if (len > max) {
                max = len;
                copy(longest, line);
            }
            
        if (max > 0)    /* there was a line */
            printf("%s", longest);
        return 0;
    }
    
    /* getline: read a line into s, return lenght */
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
    
    /* copy: copy 'from' into 'to'; assume to is big engouth */
    void copy(char to[], char from[])
    {
        int i;
        
        i = 0;
        while ((to[i] = from[i]) != '\0')
            ++i;
    }

**getline** puts the character **'\0'** (the ***null character***, whose value is zero) at the end of the array it is creating, to mark the end of the string of characters. This conversion is also used by the C language: when a string constant like

    "hello\n"

appears in a C program, it stored as an array of characters containing the characters in the string and terminated with **'\0'** to mark the end.

<img src="{{ site.baseurl }}/assets/images/character_array.png" style="display: block; margin: 0 auto; width:300px" />

The **%s** format specification in **printf** expects the corresponding argument to be a string represented in this form.

#### 1.10 External Variables and Scope

The variables that are declared within function are private or local the function. Each local variable in a function comes into existence only when the function is called, and disapears when the function is exited. This why such variables are usually known as ***automatic*** variables, following terminology in other langugages.

Because automatic variables come and go with function invocation, they do not retain their values from one call to the next, and must be explicitly set upon each entry. If they are not set, they will contain garbage.

As an alternative to automatic variables, it is possiable to define variables that are ***external*** to all funcitons, that is, variables that can be accessed by name by any function. (This mechanism is rather like Fortran COMMON or Pascal variables declared in the outermost block.) Because external variables are globally accessible, they can be used instead of argument lists to communicate data between functions. Furthermore, because external variables remain in existence permanently, rather than appearing and disappearing as functions are called and exited, they retain their value even after the functions that set them have returned.

An external variable must be ***defined***, exactly once, outside of any function; this sets aside storage for it. The variable must also be ***declared*** in each function that wants to access it; this states the type of the variable. The declaration may be an explicit **extern** statement or may be implicit from context.



    #include <stdio.h>
    
    #define MAXLINE 1000        /* maximum input line size */
    
    int max;                    /* maximum length seen so far */
    char line[MAXLINE];         /* current input line */
    char longest[MAXLINE];      /* longest line saved here */
    
    int getline(void);
    void copy(void);
    
    /* print longest input line; specialized version */
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
    
    /* getline: specialized version */
    int getline(void)
    {
        int c, i;
        extern char line[];
        
        for (i = 0; i < MAXLINE - 1
            && (c=getchar()) != EOF && c != '\n'; ++i)
            line[i] = c;
        if (c == '\n') {
            line[i] = c;
            ++i;
        }
        line[i] = '\0';
        return i;
    }
    
    /* copy: specialized version */
    void copy(void)
    {
        int i;
        extern char line[], longest[];
        
        int i = 0;
        while ((longest[i] = line[i]) != '\0')
            ++i;
    }

Syntactically, external definitions are just like definitions of local variables, but since they occur outside of functions, the variables are external. Before a function can use a external variable, the name of the varible must be made known to the function; the declaration is the same as before except for the added keyword **extern**.

In certain circumstances, the **extern** declaration can be ommited. If the definition of the external variable occurs in the source file before its use in a particular function, then there is no need for an **extern** declaration in the funciton.

If the program is in several source files, and a variable is defined in *file1* and used in *file2* and *file3*, then **extern** declarations are needed in *file2* and *file3* to connect the occurrences of the variable. The usual practice is to collect **extern** declarations of variables and funcitons in a separate file, historically called a **header**, that is included by **#include** at the front of each source file. The suffix **.h** is conventional for header names.

When refer to external variables, ''**definition**'' refers to the place where the varible is created or assigned storage; ''**declaration**'' refers to places where the nature of the variable is stated but no storage is allocated.

* * *

#### References

* [The C Programming Language 2nd Edition by Brian W. Kernighan (Author), Dennis M. Ritchie (Author)](http://www.amazon.com/Programming-Language-Brian-W-Kernighan/dp/0131103628/ref=sr_1_1?ie=UTF8&qid=1460658948&sr=8-1&keywords=c+programming+language)

* [C track: compiling C programs](/c/2015/08/22/C-track-compiling-C-programs.html)
