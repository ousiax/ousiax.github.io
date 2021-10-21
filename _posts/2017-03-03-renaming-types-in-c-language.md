---
layout: post
title: "Renaming Types in C Language"
date: 2017-03-03 11:20:37 +0800
categories: ['C']
tags: ['C']
---

Sometimes it is convenient to give a new name to a type. You can do this using the `typedef` statement. Here is the general form of the `typedef` statement:

```c
typedef old-type-name new-type-name
```

`old-type-name` is the existing name for the type, and may consist of more than one token (e.g., `unsigned long int`). `new-type-name` is the resulting new name for the type, and must be a single identifier. Creating this new name for the type does not cause the old name to cease to exist. Here are some examples:

```c
typedef unsigned char byte_type;
typedef double real_number_type;
```

In the case of custom data types, you can use `typedef` to make a new name for the type while defining the type:

```c
typedef struct fish {
    float weight;
    float length;
    float probability_of_being_caught;
} fish_type;
```

To make a type defintion of an array, you first provide the type of the element, and then establish the number of elements at the end of the type definition:

```c
typedef char array_of_bytes [5];
array_of_bytes five_bytes = {0, 1, 2, 3, 4};
```

When selecting names for types, you should avoid ending your type names with a **_t** suffix. The compiler will allow you to do this, but the POSIX standard reserves use of the **_t** suffix for standard library types names.

* * *

##### References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#The-typedef-Statement)
