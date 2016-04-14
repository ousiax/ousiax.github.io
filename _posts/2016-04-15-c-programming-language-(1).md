---
layout: post
title: "C Programming Language (1)"
date: 2016-04-15 01-32-42 +0800
categories: ['C',]
tags: ['C', 'Programming Language']
disqus_identifier: 4904530486998316446927979528588566262
---
## 1. Overview

### 1\.1 Getting Started

The only way to learn a new programming language is by writing programs in it.

The first program to write is the same for all languages: *Print the words* of **hello, world**.

A C program, whatever its size, consists of ***functions*** and ***variables***.

A function contains ***statements*** that specify the computing operations to be done, and variables store values used during the computaiton.

`main` is special and your program begins executing at the beginning of main.

**main** will usually call other functions to help perform its job, some that you wrote, and othes from libraries that are provied for you.

One method to communicating data between function is for the calling function to provide a list of values, called ***arguments***, to the funciton it calls. The parentheses after the function name surround the argument list.

    #include<stdio.h>       // include informaiton about standard library
    main()                  // define a function called main
                            // that received no argument values
    {                       // statements of main are enclosed in braces
        printf("hello, world\n"); // main calls library function printf \
                                  // to print this sequence of characters \n represents the newline character.
    }

A sequence of characters in double quotes, like "hello, world\n", is called a *character string* or *string constant*.

* Compiling

    cc hello.c

* Run 

        ./a.out
