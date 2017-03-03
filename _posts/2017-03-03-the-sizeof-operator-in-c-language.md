---
layout: post
title: "The sizeof Operator in C Language"
date: 2017-03-03 11-47-55 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 110768578835743024300567903040946918802
---

You can use the `sizeof` operator to obtain the size (in bytes) of the data type of its operand. The operand may be an actual type specifier (such as `int` or `float`), as well as any valid expression. When the operand is a type name, it must be enclosed in parentheses. Here are some examples:

```c
size_t a = sizeof(int);
size_t b = sizeof(float);
size_t c = sizeof(5);
size_t d = sizeof(5.143);
size_t e = sizeof a;
```

The result of the `sizeof` operator is of a type called `size_t`, which is defined in the header file `<stddef.h>`. `size_t` is an unsigned integer type, perhaps identical to `unsigned int` or `unsigned long int`; it varies from system to system.

The `size_t` type if often a conventient type for a look index, since it is guaranteed to be able to hold the number of elements in any array; this is not the case with `int`, for example.

The `sizeof` operator can be used to automatically compute the number of elements in an array:

```c
#include <stddef.h>
#include <stdio.h>

static const int values[] = {1, 2, 48, 681 };
#define ARRAYSIZE(x) (sizeof x / sizeof x[0])

int main(int argc, char *argv[])
{
    size_t i;

    for(i = 0; i < ARRAYSIZE(values); i++) {
        printf("%d\n", values[i]);
    }

    return 0;
}
```

There are two cases where this technique does not work. The first is where the array element has zero size (GCC supports zero-sized structures as a GNU extension). The second is where the array is in fact a function parameter.

* * *

##### References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#The-sizeof-Operator)
