---
layout: post
title: "Blocks in C Language"
date: 2017-03-03 12-01-57 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 269113690989633562647698810160673447942
---

A *block* is a set of zeor or more statements enclosed in braces. Blocks are also known as *compound statements*. Often, a block is used as the body of an `if` statement or a loop statement, to group statements together.

```c
for(x = 1; x <= 10; x++) {
    printf("x is %d\n", x);

    if((x % 2) == 0)
        printf("%d is even\n", x);
    else
        printf("%d is odd\n", x);
}
```

You can also put blocks inside other blocks:

```c
for(x = 1; x <= 10; x++) {
    if((x % 2) == 0) {
        printf("x is %d\n", x);
        printf("%d is even\n", x);
    } else {
        printf("x is %d\n", x);
        printf("%d is odd\n", x);
    }
}
```

You can declare variables inside a block; such variables are local to that block. **In C89, declarations must occur before other statements**, and so sometimes it is useful to introduce a block simply for this purpose:

```c
    {
        int x = 5;
        printf("%d\n", x);
    }
    printf("%d\n", x);   /* Compilation error! x exists only in the preceding block. */
```

* * *

##### References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Blocks)
