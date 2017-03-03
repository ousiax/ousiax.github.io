---
layout: post
title: "Pointers in C Language"
date: 2017-03-02 17-19-51 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 186579721564951921087832385494630209132
---

Pointers hold memory address of stored constants or variables. For any data type, including both primitive types and custom types, you can create a pointer that holds the memory address of an instance of that type.

### 1. Declaring Pointers

You declare a pointer by specifying a name for it and a data type. The data type indicates of what type of variable the pointer will hold memory addresses.

To declare a pointer, include the indirection operator before the identifier. Here is the general form of a pointer declaration:

```c
data-type * name;
```

White space is not significant around the indirection operator:

```c
data-type *name;
data-type* name;
```

Here is an example of declaring a pointer to hold the address of an `int` variable:

```c
int *ip;
```

Be careful, though: when declaring multiple pointers in the same statement, you must explicitly declare each as a pointer, using the indirection operator:

```c
int *foo, *bar;     /* Two pointers. */
int *baz, quux;     /* A pointer and an integer variable. */
```

### 2. Intializing Pointers

You can initialize a pointer when you first declare it by specifying a variable address to store in it. For example, the following code declares an `int` variable `i`, and a pointer which is initialized with the address of `i`:

```c
int i;
int *p = &i;
```

Note the use of the address operator, used to get the memory address of a variable. After you declare a pointer, you do *not* use the indirection operator with the pointer's name when assigning it a new address to point to. On the countrary, that would change the value of the variable that the points to, not the value of the ponter itself. For example:

```c
int i, j;
int *ip = &i;  /* ‘ip’ now holds the address of ‘i’. */
ip = &j;       /* ‘ip’ now holds the address of ‘j’. */
*ip = &i;      /* ‘j’ now holds the address of ‘i’. */
```

The value stored in a pointer is an integral number: a location within the computer's memory space. If you are so inclined, you can assign pointer values explicitly using literal integers, casting them to the appropriate pointer type. However, we do not recommend this practice unless you need to have extremely fine-tuned control over what is stored in memory, and you known exactly what are doing. It would be all too easy to accidentally overwrite something that you did not intend to. Most uses of this technique are also non-portable.

It is important to note thant if you do not initialize a pointer with the address of some other existing object, it points nowhere in particular and will likely make your program crash if you use it (formmally, this kind of thing is called *undefined behavior*).

### 3. Pointers to Unions

You can create a pointer to a union type just as you can a pointer to a primitive data type.

```c
union numbers {
    int i;
    float f;
};
union numbers foo = { 4 };
union numbers *number_ptr = &foo;
```

That example creates a new union type, `union numbers`, and declares ( and initializes the first member of) a variable of that type named `foo`. Finally, it declares a pointer to the type `union numbers`, and gives it th address of `foo`.

You can access the members of a union variable through a pointer, but you can't use the regular member access operator anymore. Instead, you have to use the indirect member access operator. Continuing with the previous example, the following example will change the value of the first member of `foo`:

```c
number_ptr -> i = 450;
```

Now the `i` member in `foo` is 450.

### 4. Pointers to Structures

You can create a pointer to a structure type just as you can a pointer to a primitive data type.

```c
struct fish {
    float length, weight;
};
struct fish salmon = { 4.3, 5.8 };
struct fish *fish_prt = &salmon;
```

That example creates a new structure type, `struct fish`, and declares (and initializes) a variable of that type named `salmon`.

You can access the members of a structure variable through a pointer, but you can't use the regular memeber access operator anymore. Instead, you have to use the indirect member access operator. Continuing with the previous example, the following example will change the values of the members of `salmon`:

```c
fish_ptr -> length = 5.1;
fish_ptr -> weight = 6.2;
```

Now the `length` and `width` members in `salmon` are 5.1 and 6.2, respectively.

### 5. Dangling, Void , Null and Wild Pointers <sup>[[1]](http://www.geeksforgeeks.org/dangling-void-null-wild-pointers/)</sup>


* * *

#### References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Pointers)

1. [http://www.geeksforgeeks.org/dangling-void-null-wild-pointers/](http://www.geeksforgeeks.org/dangling-void-null-wild-pointers/)

