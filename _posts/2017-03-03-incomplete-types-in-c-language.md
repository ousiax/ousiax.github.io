---
layout: post
title: "Incomplete Types in C Language"
date: 2017-03-03 11-10-30 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 251921865815762789706878812159064652731
---

You can define structures, unions, and enumerations without listing their members (or values, in the case of enumerations). Doing so results in an incomplete type. **You can't declare variables of incomplete types, but you can work with pointer to those types.**

```c
struct point;
```

At some time later in your program you will want to complete the type. You do this by defining it as you usually would:

```c
struct point {
    int x, y;
}
```

This technique is commonly used to for linked list:

```c
struct singly_linked_list {
    struct singly_linked_list *next;
    int x;
    /* other members here perhaps */
};
struct singly_linked_list *list_head;
```

* * *

##### References:

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Incomplete-Types)
