---
layout: post
title: "C Programming Language 3 - Control Flow"
date: 2016-04-17 20-37-50 +0800
categories: ['C',]
tags: ['C', 'C Programming Language']
disqus_identifier: 317036797006502053128435958298810762776
---
The control-flow of a language specify the order in which computations are performed.

### 3.1 Statements and Blocks

An expression such as x = 0 or i++ or printf(...) becomes a **statement** when it is followed by a semicolon, as in

    x = 0;
    i++;
    printf(...);

Braces **{** and **}** are used to group declarations and statements together into a **compound statement**, or **block**, so that they are syntactically equivalent to a single statement. 

### 3.2 Decisions

#### 3.2.1 If

    if (expression)
        statement
    else if (expression)
        statement
    else if (expression)
        statement
    else if (expression)
        statement
    else
        statement

#### 3.2.2 Switch

The **switch** statement is a multi-way decision that tests wheter an **expression** matches one of a number of **constant integer** values, and branches accordingly.

    switch (expression) {
        case const-expr:
            statements
        case const-expr:
            statements
        default:
            statements
    }

Each case is labeled by one or more integer-valued constants or constant expressions. 

### 3.3 Loops

    while (expression)
        statement

The *expression* is evaluated. If it is non-zero, *statement* is executed and *expression* is re-evaluated. This cycle continues until *expression* becomes zero, at which point execution resumes after *statement*.

The **for** statement

    for (expr1; expr2; expr3)
        statement

is equivalent to

    expr1;
    while (expr2) {
        statement
        expr3;
    }

The syntax of the **do** is

    do
        statement
    while (expression);

The *statement* is executed, then *expression* is evaluated. If it is true, *statement* is evaluated again, and so on. When the *expression* becomes false, the loop terminates.

### 3.4 Break and Continue

The **break** statement provides an early exit from **for**, **while**, and **do**, just as from **switch**. A **break** causes the *innermost* enclosing loop or switch to be exited immediately.

The **continue** statement is related to **break**, but less often used; it causes the next iteration of the enclosing **for**, **while**, or **do** loop to begin. In the **while** and **do**, this means that the test part is executed immediately; in the **for**, control passes to the increment step. The **continue** statement applies only to loops, not to **switch**. A **continue** inside a **switch** inside a loop causes the next loop iteration.

### 3.5 Goto and labels

C provides the infinitely-abusable **goto** statement, and **label**s to branch to.

    for ( ... )
        for ( ... ) {
        }
        ...
        ...
        if (disaster)
            goto error;
    error:
       /* clean up the mess */

* * *

#### References

* [The C Programming Language 2nd Edition by Brian W. Kernighan (Author), Dennis M. Ritchie (Author)](http://www.amazon.com/Programming-Language-Brian-W-Kernighan/dp/0131103628/ref=sr_1_1?ie=UTF8&qid=1460658948&sr=8-1&keywords=c+programming+language)
 
