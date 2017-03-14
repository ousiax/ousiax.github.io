---
layout: post
title: "Enumerations in C Language"
date: 2017-02-28 18-52-27 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 303038926370320173773895282387259497157
---
* TOC
{:toc}

* * *

An enumeration is a custom data type used for storing constant integer values and referring to them by names. By default, these values are of type `signed int`; however, you can use the `-fshort-enums` GCC compiler option to cause the samllest possible integer type to be used instead.

Both of these behaviors conform to the C89 standard, but mixing the use of these options within the same program can produce incompatibilities.

### 1. Defining Enumerations

You define an enumeration using the `enum` keyword, followed by the name of the enumeraiton (this is optional), followed by a list of constant names (separated by commas and enclosed in braces), and ending with a semicolon.

```c
enum fruit {grape, cherry, lemon, kiwi};
```

That example defines an enumeration, `fruit`, which contains four constant integer values, `grape`, `cherry`, `lemon` and `kiwi`, whose values are, by default, 0, 1, 2, and 3, repectively. You can also specify one or more of the values explicitly:

```c
enum more_fruit {banana = -17, apple, bluberry, mango};
```

That example defines `banana` to be -17, and the remaining values are incremented by 1: `apple` is -16, `blueberry` is -15, and `mango` is -14. Unless specified otherwise, an enumeration value is equal to one more than the previous value (and the first value defult to 0).

You can also refer to an enumeration value defined earlier in the same enumeration:

```c
enum yet_more_fruit {kumquat, raspberry, peach,
                     plum = peach + 2};
```

In that example, `kumquat` is 0, `raspberry` is 1, `peach` is 2, and `plum` is 4.

You cann't use the same name for an `enum` as a `struct` or `union` in the same scope.

### 2. Declaring Enumerations

You can declare variables of an enumeration type both when the enumeration is defined and afterward. This example declares one variable, named `my_fruit` of type `enum fruit`, all in a single statement:

```c
enum fruit {banana, apple, blueberry, mango} my_fruit;
```

while this example declares the type and variable separately:

```c
enum fruit {banana, apple, blueberry, mango};
enum fruit my_fruit;
```

(Of course, you couldn't declare it that way if you don't named the enumeration.)

Although such variables are considered to be of an enumeration type, you can assign them any value that you could assign to an `int` variable, including values from other enumerations. Furthmore, any variable that can be assigned an `int` value can be assigned a value from an enumeration.

However, you cannot change the values in an enumeration once it has been defined; they are constant values. For example, this won't work:

```c
enum fruit {banana, apple, blueberry, mango};
banana = 15;    /* You cann't do this! */
```

Enumerations are useful in conjunction with the `switch` statement, because the compiler can warn you if you have failed to handle one of the enumeration values. Using the example above, if your code handes `banana`, `apple` and `mango` only but not `blueberry`, GCC can generate a warning.

- - -

### 3. References

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Enumerations)
