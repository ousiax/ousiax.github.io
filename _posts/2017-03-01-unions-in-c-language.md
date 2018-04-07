---
layout: post
title: "Unions in C Language"
date: 2017-03-01 10:19:28 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 267566994083730237143405316276747173260
---

* TOC
{:toc}

* * *

A union is a custom data type used for storing several variables in the same memory space. Although you can access any of those variables at any time, you should only read from one of them at a time—assigning a value to one of them overwrites the values in the others.

### 1. Defining Unions

You define a union using the `union` keyword followed by the declarations of the union's memebers, enclosed in braces. You declare each member of a union just as you would normally declare a variable—using the data type followed by one or more variable names separated by commas, and ending with a semicolon. Then end the union definition with a semicolon after the closing brace.

You should also include a name for the union between the `union` keyword and the opening brace. This is syntactically optional, but if you leave it out, you can't refer that union data type later on (without a `typedef`).

Here is an example of defining a simple union for holding an integer value and a floting point value:

```c
union numbers {
    int i;
    float f;
};
```

That defines a union named `numbers`, which contains two members, `i` and `f`, which are of type `int` and `float`, respectively.

### 2. Declaring Union Variables

You can declare variables of a union type when both you initially define the union and after the definition, provided you gave the union type a name.

#### 2.1. Declaring Union Variables at Definition

You can declare variables of a union type when you define the union type by putting the variable names after the closing brace of the union definition, but before the final semicolon. You can declare more than one such variable by separating the names with commas.

```c
union numbers {
    int i;
    float f;
} first_number, second_number;
```

That example declares two variables of type `union numbers`, `first_number` and `second_number`.

#### 2.2. Declaring Union Variables After Definition

You can declare variables of a union type after you define the union by using the `union` keyword and the name you gave the union type, followed by one or more variable names separated by commas.

```c
union numbers {
    int i;
    float f;
};
union numbers first_number, second_number;
```

That example declares two variables of type `union numbers`, `first_number` and `second_number`.

#### 2.3. Initializing Union Members

You can initialize the first member of a union variable when you declare it:

```c
union numbers {
    int i;
    float f;
};
union numbers first_number = { 5 };
```

In that example, the `i` member of `first_number` gets the value `5`. The `f` member is left alone.

Another way to initialize a union member is to specify the name of the member to initialize. This way, you can intialize whichever member you want to, not just the first one. There are two methods that you can use—either follow the member name with a colon, and the its value, like this:

```c
union numbers first_number = { f: 3.14159 };
```

or precede the member name with a period and assign a value with the assignment operator, like this:

```c
union numbers first_number = { .f = 3.14159 };
```

You can also intialize a union member when you declare the union variable during the definition:

```c
union numbers {
    int i;
    float f;
} first_number = { 5 };
```

### 3. Accessing Union Members

You can access the members of a union variable using the member access operator. You put the name of the union variable on the left side of the operator, and the name of the member on the right side:

```c
union numbers {
    int i;
    float f;
};
union numbers first_number;
first_number.i = 5;
first_number.f = 3.14159;
```

Notice in that example, that giving a value to the `f` member overrides the value stored in the `i` member.

### 4. Size of Unions

The size of a union is equal to the size of its largest member. Consider the first union example from this section:

```c
union numbers {
    int i;
    float f;
};
```

The size of the union data type is the same of `sizeof (float)`, because the `float` type is larger than the `int` type. Since all of the members of a union occupy the same memory space, the union data type size doesn't need to be large enough to hold the sum of all their sizes; it just need to be large enough to hold the largest members;

- - -

### 5. References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Enumerations)
