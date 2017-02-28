---
layout: post
title: "Structure and Sope in C Language"
date: 2017-02-26 12-00-08 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 212712969519156400470368935825558304067
---

### Program Structure

A C program may exist entirely within a single source file, but more commonly, any non-trivial program will consist of serval custom header files and source files, and will also include and link with files from existing libraries.

By convention, header files (with a ".h" extension) contain variable and function declarations, source files (with a ".c" extension) contain the corresponding definitions. Source file may also store declarations, if these declarations are not for objects which need to be seen by other files. However, header files almost certainly should not contain any definition.

For example, if you write a function that computes square roots, and you wanted this function to be accessible to files other than where you define the function, then you would put the function into a header file (with a ".h" extension):

```c
/* sqrt.h */
double computeSqrt(double x);
```

This header file could be included by other source files which need to use your function, but do not need known how it was implemented.

The implemented of the function would then go into a corresponding source file (with a ".c" file extension):

```
/* sqrt.c */
#include "sqrt.h"

double computeSqrt(double x)
{
    double result;
    ...
    return result;
}
```

### Scope

Scope refers to what parts of the program can "see" a declared object. A declared object can be visible only within a particular function, or within a particular file, or may be visible to an entire set of files by way of including header files and using `extern` declarations.

Unless explicitly stated otherwise, declaration made at the top-level of a file (i.e., not within a function) are visible to the entire file, including from within functions, but are not visible outside of the file.

Delcarations made within functions are visible only within those functions.

A declaration is not visible to declarations that came before it; for example:

```c
int x = 5;
int y = x + 10;
```

will work, but:

```c
int x = y + 10;
int y = 5;
```

will not.

- - -

#### References:

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Keyword)
