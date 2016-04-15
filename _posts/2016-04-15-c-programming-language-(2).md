---
layout: post
title: "C Programming Language (2) - Types Operators and Expressions"
date: 2016-04-15 07-00-24 +0800
categories: ['C',]
tags: ['C', 'Programming Language']
disqus_identifier: 209523309766816828360886996768894892080
---
**Variable**s and **constant**s are the basic data objects manipulated in a program. **Declaration**s list the varables to be used, and state what type they have and perhaps what their initial values are. **Operator**s specify what is to be done to them. **Expression**s combine variables and constants to produce new values. The **type** of an object determines the set of values it can have and what operations can be performed on it.

#### 2.1 Variable Names

Names are made up of letters and digits; the first character must be a letter. The underscore "_" counts as a letter; it is sometimes useful for improving the readability of long variable names. Don't begin varible names with underscore, however, since library routines often use such names. Upper and lower case letters are distinct. Tracditional C practice is to use lower case for varible names, and all upper case for symbolic constants.

At least the first 31 characters of an internal name are significant. For funciton names and external vraibles, the number may be less than 31, because external names may be used by assemblers and loaders over which the language has no control. For externel names, the standard guarantees uniqueness only for 6 characters and a single case. Keywords like **if**, **else**, **int**, **float**, etc., are reserved.

We tend to use short names for local varibles, especially loop indices, and longer names for external variables.

#### 2.2 Data Types and Sizes

They are only a few basic data types in C:

&nbsp;&nbsp;&nbsp;&nbsp;**char** a single byte, capable of holding on character in the local character set

&nbsp;&nbsp;&nbsp;&nbsp;**int** an integer, typicall reflecting the natural size of integers on the host machine

&nbsp;&nbsp;&nbsp;&nbsp;**float** single-precision floating point

&nbsp;&nbsp;&nbsp;&nbsp;**double** double-precision floating point

In addition, there are a number of *qualifiers* that can be applied to these basic type. **short** and **long** apply to inegers:

&nbsp;&nbsp;&nbsp;&nbsp;**short int** sh;

&nbsp;&nbsp;&nbsp;&nbsp;**long int** counter;

The word **int** can be ommited in such declarations, and typically it is.

The intent is that **short** and **long** should provide different lengths of integers where practical; **int** will normally be the natural size for a particular machine. **short** is often 16 bits long, and **int** either 16 or 32 bits. Each compiler is free to choose appropriate sizes for its own hardware, subject only to the restriction that **short**s and **int**s are at least 16 bits, **long**s are at least 32 bits, and **short** is no longer than **int**, which is no longer than **long**.

The qualifiers **signed** or **unsigned** may be applied to **char** or any **int**eger. **unsigned** numbers are always positive or zero, and obey the laws of arithmetic modulo 2<sup>n</sup>, where ***n*** is the number of bits in the type. So, for instance, if **char**s are 8 bits, **unsigned char** variables have values between 0 and 255, while **signed char**s have values between -128 and 127 (in a two's complement machine.) Whether plain **char**s are signed or unsigned is machine-dependent, but parintable characters are always positive.

The type **long double** specifies extended-precision floating point. As with integers, the sizes of floating-point objects are implementation-defined; **float**, **double** and **long double** could represent one, two or three distinct sizes.

#### 2.3 Constants

An integer constant like *12334* is an *int*. A *long* constant is written with a terminal **l** (ell) or **L**, as in *123456789L*; an integer constant too big to fit into an *int* will also be taken as a *long*. Unsigned constants are written with a terminal **u** or **U**, and the suffix **ul** or **UL** indicates *unsigned long*.

Floating-point consants contain a decimal point (*123.4*) or an exponent (*1e-2*) or both; their type is *double*, unless suffixed. The suffixes **f** or **F** indicate a *float* constant; **l** or **L** indicate a *long double*.

A leading **0** (zero) on an integer constant means *octal*; a leading **0x** or **0X** meanns hexadecimal. For example, decimal *31* can be write as *037* in octal and *0x1f* or *0x1F* in hex. Octal and hexadecimal contants may also be followed by **L** to make them *long* and **U** to make them *unsigned: 0XFUL* is an *unsigned long* constant with value 15 decimal.

A **character constant** is an integer, written as one character with single quotes, such as *'x'*. The value of a character constant is the numberic value of the character in the machine's character set.

Certain characters can be represented in character and string constants by escape sequences like *\n* (newline); these sequences looks like two characters, but represent only one. In addition, an arbitrary bytesized bit pattern can be specified by 

    '\000'

where *000* in one to three octal digits (0...7) or by

    '\xhh'

where *hh* is one or more hexadecimal digits (0...9, a...f, A...F).

    #define VTAB '\013'     /* ASCII vertical tab */
    #define BELL '\007'     /* ASCII bell character */

or, in hexadecimal,

    #define VTAB '\xb'      /* ASCII vertical tab */
    #define BELL '\x7'      /* ASCII bell character */

The complete set of escape sequences is

    \a      alert(bell) character       \\      backslash
    \b      backspace                   \?      question mark
    \f      formfeed                    \'      single quote
    \n      newline                     \"      double quote
    \r      carriage return             \000    octal number
    \t      horizontal tab              \xhh    hexadecimal number
    \v      vertical tab 

The character constant '\0' represents the character with value zero, the null character.

A ***constant expression*** is an expression that involves only consants. Such expression may be evaluated at during compilation rather run-time.

A ***string constant***, or ***string literal***, is a sequence of zero or more characters surrounded by double quotes.

There is one other kind of constant, the ***enumeration constant***. An enumeratioin is a list of constant integer values, as in

    enum boolean { NO, YES }

The first name in an **enum** has value 0, the next 1, and so on, unless explicit values are specified. If not all values are specified, unspecified values continue the progression from the last specified value.

Names in different enumerations must be distinct. Values need not be distinct in the same enumeration.

#### 2.4 Declarations

All variables must be declared before use, although certain declarations can be made implicitly by content.

    int  lower, upper, step; 
    char c, line[1000];

A variable may also be initialized in its declaration.

    char  esc = '\\';
    int   i = 0;
    int   limit = MAXLINE + 1;
    float eps = 1.0e-5;

If the variable in question is not automatic, the initialization is done once only, conceptionally before the program starts executing, and the initializer must be a constant expressoin.

The qualifier **const** can be applied to the declaration of any variable to specify that its value will not be changed. For an array, the **const** qualifier says that the elements will not be altered.

    const double e = 2.71828182845905;
    const char msg[] = "warning: ";

    int strlen(const char[]);

#### 2.5 Arithmetic Operators

*binary arithmetic operators*

**+**&nbsp;&nbsp;&nbsp;&nbsp;**\-**&nbsp;&nbsp;&nbsp;&nbsp;**\***&nbsp;&nbsp;&nbsp;&nbsp;**/**&nbsp;&nbsp;&nbsp;&nbsp;**%**

Integer division truncates any fractional part.

The **%** operator cannot be applied to a **float** or **double**.

The direction of trucation for **/** and the sign of the result for **%** are machine-dependent for negative operands, as is the action token on overflow or underflow.

*unary arithmetic operators*

**+**&nbsp;&nbsp;&nbsp;&nbsp;**\-**

#### 2.6 Relational and Logical Operators

*relational operators*

**>**&nbsp;&nbsp;&nbsp;&nbsp;**>=**&nbsp;&nbsp;&nbsp;&nbsp;**<**&nbsp;&nbsp;&nbsp;&nbsp;**<=**&nbsp;&nbsp;&nbsp;&nbsp;**==**&nbsp;&nbsp;&nbsp;&nbsp;**!=**

*logical operators*

**&&**&nbsp;&nbsp;&nbsp;&nbsp;**\|\|**&nbsp;&nbsp;&nbsp;&nbsp;**!**

#### 2.7 Type Conversions


#### 2.8 Increment and Decrement Operators

#### 2.9 Bitwise Operators

#### 2.10 Assignment Operators and Expressions

#### 2.11 Conditional Expressions

#### 2.12 Precedence and Order of Evaluation

    Operators                           Associativity
    () [] -> .                          left to right
    ! ~ ++ -- + - * (type) sizeof       right to left
    * / %                                left to right
    + -                                  left to right
    << >>                               left to right
    < <= > >=                           left to right
    == !=                               left to right
    &                                   left to right
    ^                                   left to right
    |                                   left to right
    &&                                  left to right
    ||                                  left to right
    ?:                                  right to left
    = += -= *= /= %= &= ^= |= <<= >>=   right to left
    ,                                   left to right
