---
layout: post
title: "Keywords in C Language"
date: 2017-02-26 09:32:02 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 202693019303021835597724434992607825735
---

Keywords are special identifiers reserved for use as part of the programming language itself. You cannot use them for any other purpose.

Here is a list of 32 keywords recognized by **ANSI C89**:

```c
auto      register  static    extern    const     volatile
int       short     long      float     double    char      unsigned  signed    void
if        else
switch    case      default
for       do        while
goto
break     continue
struct    union     enum      typedef
return
sizeof
```

**ISO C99** adds the followinig keywords:

```c
inline  _Bool   _Complex    _Imaginary
```

and **GNU extensions** add these keywords:

```c
__FUNCTION__    __PRETTY_FUNCTION__    __alignof    __alignof__
__asm    __asm__    __attribute    __attribute__
__builtin_offsetof    __builtin_va_arg    __complex    __complex__
__const    __extension__    __func__
__imag    __imag__        __inline    __inline__
__label__    __null    __real    __real__
__restrict    __restrict__    __signed    __signed__
__thread    __typeof    __volatile    __volatile__
```

In both ISO C99 and C89 with GNU extensions, the following is also recognized as a keyword:

```c
restrict
```

#### Storage Class Specifiers

There are four storage class specifiers that you can prepend to your variable declarations which change how the variables are stored in memory: `auto`, `extern`, `register`, and `static`.

You use `auto` for variables which are local to a function, and whose values should be discarded upon return from the function in which they are declared. This is the default behavior for variables declared within functions.

```c
void foo(int value)
{
    auto int x = value;
    ...
    return;
}
```

`register` is nearly identical in purpose to `auto`, except that it also suggests to the compiler that the variable will be heavily used, and, if possible, should be stored in a register. You cannot use the address-of operator to obtain the address of a variable declared with `register`. This means that you cannot refer to the elements of an array declared with storage class `register`. In fact the only thing you can do with such an array is measure its size with `sizeof`. GCC normally makes good choices about which values to hold in regiseters, and so `register` is not often used.

`static` is essentially the opposite of `auto`: when applied to variables within a function or block, these variables will retaiin their value even when the function or block is finised. This is know as `static storage duration`.

```c
int sum(int x)
{
    static int sumSoFar = 0;
    sumSoFar = sumSoFar + x;
    return sumSoFar;
}
```

You can alos declare variables (or functions) at the top level (that is, not inside a function) to be `static`; such variables are visible (global) to the current source file (but not other source file). This gives an unfortunate double meaning to `static`; this second meaning is known as *`static linkage`*. Two functions or variables having static linkage in separate files are entirely separate; neither is visiable outside the file in which it is declared.

Uninitialized variables are declared as `extern` are given default value of `0`, `0.0`, or `NULL`, depending on the type. Unintialized variables that are declared as `auto` or `register` (including the default usage of `auto`) are left uninitialized, and hence should be assumed to hold any particular value.

`extern` is useful for declaring variables that you want to be visible to all source files that are linked into your project. You cannot initialize a variable in an `extern` declaration,as no space is actually allocated during the declaration. You must make both an `extern` declaration (typically in a header file that is included by the other source files which need to access the variable) and a non-`extern` declartion which is where space is actually to store the variable. The `extern` declaration may be repeated multiple times.

```c
extern int numberOfClients;
. . .
int numberOfClients = 0;
```

- - -

### References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Keywords)
