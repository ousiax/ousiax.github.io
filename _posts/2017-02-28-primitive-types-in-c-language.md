---
layout: post
title: "Primitive Types in C Language"
date: 2017-02-28 16-24-43 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 144634406855718786306315904227731548500
---

`Integer Types` `Real Number Types` `Complex Number Types`

- - -

`char` `unsigned char` `signed char` `short` `unsiged short` `int` `unsiged int` `long` `unsigned long` `long long` `unsigned long long` `float` `double` `long double` `_Complex`

### 1. Integer Types

The integer data types range in size from at least 8 bits to at least 32 bits. The C99 extends this range to include integer sizes of at least 64 bits. You should use integer types for storing whole number value (and the `char` data type for storing characters). The size and ranges listed for these types are minimums; depending on your computer platform, there sizes and ranges may be larger.

While there ranges provide a natural ordering, the standard does not require that any two types have a different range. For example, it is common for `int` and `long` to have the same range. The standard event allows `signed char` and `long` to have the same range, though such platforms are very unusual.

- `signed char`

    The 8-bit `signed char` data type can hold integer values in the range of -128 to 127.

- `unsigned char`

    The 8-bit `unsigned char` data type can hold integer values in the range of 0 to 255.

- `char`

    Depending on your system, the `char` data type is defined as having the same range as either the `signed char` or the `unsigned char` data type (they are three distinct types, however). By convention, you should use the `char` data type specifically for storing ASCII characters (such as `m`), including escape sequences (such as `\n`).

- `short int`

    The 16-bits `short int` data type can hold integer values in the range of -32,768 to 32,767. You may also refer to this data type as `short`, `signed short int`, or `signed short`.

- `unsigned short int`

    The 16-bits `unsigned short int` data type can hold integer values in the range of 0 to 65535. You may also refer to this data type as `unsigned short`.
- `int`

    The 32-bits `int` data type can hold integer values in the range of -2,147,483,648 to 2,147,483,647. You may also refer to this data type as `signed int` or `signed`.

- `unsigned int`

    The 32-bit `unsigned int` data type can hold integer values in the range of 0 to 4,294,967,295. You may also refer to this data type simply as `unsigned`.

- `long int`

    The 32-bit `long int` data type can hold integer values int the range of at least -2,147,483,648 to 2,147,483,647. (Depending on your system, this data type might be 64-bit, in which case its range is identical to that of the `long long int` data.) You may also refer to this data as `long`, `signed long int`, or `signed long`.

- `unsiged long int`

    The 32-bit `unsigned long int` data type can hold integer values in the range of at least 0 to 4,294,967,295. (Depending on your system, this data type might be 64-bit, in which case its range is identical to that of the `unsigned long long int` data type.) You may aslo refer to this data type as `unsigned long`.

- `long long int`

    The 64-bit `long long int` data type can hold integer values in the range of -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807. You may also refer to this data type as `long long`, `signed long long int` or `signed long long`. This type is not part of C89, but is both part of C99 and a GNU C extension.

- `unsigned long long int`

    The 64-bit `unsigned long long int` data type can hold integer values in the range of at least 0 to 18,446,744,073,709,551,615. You may also refer to this data type as `unsigned long long`. This type is not part of C89, but is both part of C99 and a GNU C extension.

### 2. Real Number Types

There are three data types that represent fractional numbers. While the sizes and ranges of these types are consistent across most computer systems in use today, historically the sizes of there types varied from system to system. As such, the minimum and maximum values are stored in macro definitions in the library file `float.h`. In this section, we include the names of the macro definitions in place of their possible values; check you system's `float.h` for specific numbers.

- `float`

    The `float` data type is the smallest of the three floating point types, if they differ in size at all.

    Its minimum value is stored in the `FLT_MIN`, and should be no greater than `1e-37`. Its maximum value is stored in the `FLT_MAX`, and should be no less than `1e37`.

- `double`

    The `double` data type is at least as large as the `float` type, and ti may be larger. Its minimum value is stored in `DBL_MIN`, and its maximum value is stored in `DBL_MAX`.

- `long double`

    The `long double` data type is at least as large as the `float` type, and it may be larger. Its minimum value is stored in `LDBL_MIN`, and its maximum value is stored in `LDBL_MAX`.

All floating point data type are signed; trying to use `unsigned float`, for example, will cause a compile-time error.

The real number types provided in C are of finite precision, and accordingly, not all real numbers can be represented exactly. Most computer systems that GCC compiles for use a binary representation for real numbers, which is unable to precisely represent numbers such as, for example, 4.2. For this reason, we recommend that you consider not comparing real numbers for exactly equality with the == operator, but rather check that real numbers are within an acceptable tolerance.

### 3. Complex Number Types

GCC introduced some complex number types as an extension to C89. Similar features were introduced in C99, but there were a number of differences.

#### 3.1 Standard Complex Number Types

Complex types were introduces in C99. There are three complex types:

```c
float _Complex
double _Complex
long double _Complex
```

The names here begin with an unserscore and an uppercase letter in order to avoid conflicts with existing program's identifiers. However, the C99 standard header file `<complex.h>` introduces some macros which make using complex type easier.

The `<complex.h>` header files also declares a number of functions for performing computations on complex number, for example the `creal` and `cimag` functions which respectively return the real and imaginary parts of a `double complex` number.

#### 3.2 GNU Extensions for Complex Numbrer Types

GCC also introduced complex types as a GNU extension to C89, but the spelling is different. The floating-point complex types in GCC's C89 extension are:

```c
__complex__ float
__complex__ double
__complex__ long double 
```
- - -

#### References:

1. [https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html](https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Primitive-Types)
