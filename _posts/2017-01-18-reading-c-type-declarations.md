---
layout: post
title: "Reading C type declarations"
date: 2017-01-18 11-31-28 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 65307364381866740415511172598175329721
---

Even relatively new C programmers have no trouble reading simple C declarations such as

```c
int foo[5];     // foo is an array of 5 ints
char *foo;      // foo is a pointer to char
double foo();   // foo is a function returing a double
```

but as the declartions get bit more involved, it's more difficult to know exactly what's you're looking at.

```c
char *(*(**foo[][8])())[];  // huh ?????
```
It turns out that the rules for reading an arbitrarily-complex C variable declaration are easily learned by even beginning programmers (though how to actually *use* the variable so declared may be well out of reach).

This Tech Tip show how to do it.

**Basic and Derived Types**

In addition to one variable name, a declaration is composed of one "basic type" and zero or more "derived types", and it's crucial to understand the distinction between them.

The complete list of basic type is :

```txt
• char             • signed char          • unsigned char     
• short            • unsigned short        
• int              • unsigned int      
• long             • unsigned long         
• float            • double               • void  
• struct tag       • union tag            • enum tag      
• long long        • unsigned long long   • long double      ANSI/ISO C only
```

A declaration can have exactly **one** basic type, and it's always on the far left of the expression.

The "basic types" are augmented with "derived types", and C has three of them:

- **\* pointer to...**

    This is denoted by the familiar **\*** character, and it should be self evident that a pointer always has to point ***to*** something.

- **[] array of...**

    "Array of" can be undimensioned **[]** or dimensioned **[10]** but the sizes don't really play significantly into reading into reading a declaration. We typically include the size in the description. It should be clear that arrays have to be "arrays ***of***" something.

- **() fuction returning...**

    This is usually denoted by a pair of parentheses together **()** though it's also possible to find a prototype parameter list inside.

    Parameters lists (if present) don't really play into reading a declaration, and we typically ignore them. We'll note that parens used to represent "function returning" are different than those used for grouping: grouping parents *surround* the variable name, while "function returning" parens are always on the right.

    Functions are meaningless unless they *return* something (and we accommodate the **void** type by waving the hand and pretend that it's "returning" void).

A derived type *always* modifies something that follows, whether it be the basic type or another derived type, and to make a declaration read properly one must always include the preposition ("to", "of", "returning"). Saying "pointer" instead of "pointer to" will make your declarations fall apart.

It's possible that a type expression may have no derived type (e.g., **"int i"** describes "i is an int"), or it can have many. Interpreting the derived types is usually the sticking point when reading a complex declartion, but this is resolved with operator precedence in the next section.

**Operator Precedence**

Almost every C programmer is familiar with the operator precedence tables, which give rules that say (for instance) multiply and divide have higher precedence than ("are performed before") addition or subtraction, and parentheses can be used to alter the groupoing. This seems natural for "normal" expressions, but the same rules do indeed apply to declarations - the are *type* expressions rather than *computational* ones.

The "array of" **[]** and "function returning" **()** type operators have higher precedence than "pointer to" **\***, and this leads to some fairly straightforward rules for decoding.

*Always* start with the variable name:

>   **foo is ...**

and *always* end with the basic type:

>    foo is ... **int**

The "filling in the middle" part is usually the tricker part, but it can be summarize with this rule:

> "go right when you can, go left when you must"

Working your way out from the variable name, honor the precedence rules and consume derived-type tokens to the right as far as possible without bumping into a grouping parenthesis. Then go left to the matching paren.

**cdecl**

Cdecl  (and  c++decl) is a program for encoding and decoding C (or C++) type declarations.

```shell
$ cdecl -i
Type `help' or `?' for help
cdecl> explain int foo[5];
declare foo as array 5 of int
cdecl> explain char *foo;
declare foo as pointer to char
cdecl> explain double foo();
declare foo as function returning double
cdecl> explain char *(*(**foo[][8])())[]
declare foo as array of array 8 of pointer to pointer to function returning pointer to array of pointer to char
```

**A simple example**

We'll start with a simple example:

```c
long **foo[7];
```

```shell
$ cdecl explain long **foo[7];
declare foo as array 7 of pointer to pointer to long
```

```shell
$ # Start with the variable name and end with the basic type: foo is ... long
$ cdecl explain long foo;
declare foo as long
$ # At this point, the variable name is touching two derived types: "array of 7" and "pointer to", and the rule is to go right when you can, so in this case we consume the "array of 7"
$ cdecl explain long foo[7];
declare foo as array 7 of long
$ # Now we've gong as far right as possible, so the intermost part is only touching the "pointer to" - consume it.
$ cdecl explain long *foo[7];
declare foo as array 7 of pointer to long
$ # The innermost part is now only touching a "pointer to", so consume it also.
$ cdecl explain long **foo[7];
declare foo as array 7 of pointer to pointer to long
```

**A hairy example**

To really test our skills, we'll try a very complex declaration that very well may never appear in real life (indead: we're hard-pressed to think of how this could actually be used). But it shows that the rules scale to very complex declarations.

```c
char *(*(**foo [][8])())[];
```

```shell
$ cdecl explain char *(*(**foo [][8])())[];
declare foo as array of array 8 of pointer to pointer to function returning pointer to array of pointer to char
```

```sh
$ cdecl -i
Type `help' or `?' for help
cdecl> explain char foo;
declare foo as char
cdecl> explain char foo[];
declare foo as array of char
cdecl> explain char foo[][8];
declare foo as array of array 8 of char
cdecl> explain char *foo [][8];
declare foo as array of array 8 of pointer to char
cdecl> explain char **foo [][8];
declare foo as array of array 8 of pointer to pointer to char
cdecl> explain char (**foo [][8])()
declare foo as array of array 8 of pointer to pointer to function returning char
cdecl> explain char *(**foo [][8])()
declare foo as array of array 8 of pointer to pointer to function returning pointer to char
cdecl> explain char (*(**foo [][8])())[]
declare foo as array of array 8 of pointer to pointer to function returning pointer to array of char
cdecl> explain char *(*(**foo [][8])())[]
declare foo as array of array 8 of pointer to pointer to function returning pointer to array of pointer to char
```

**Abstract Declarations**

The C standard describes an "abstract declarator", which is used when a type needs to be described but not associated with a variable name.

These occur in two places -- casts, and as arguments to **sizeof** -- and the can look intimidating:

```c
int (*(*)())()
```

To the obvious question of "where does one start?", the answer if "find where the variable name would go, then treat it like a normal declaration". There is only one place where a variable name could possibly go, and locating it is actually straithforward. Using the syntax rules, we know that:

- to the right of all the "pointer to" derived type tokens
- to the left of all "array of" derived type tokens
- to the left of all "function returning" derived type tokens
- inside all the grouping parentheses

Looking at the example, we see that the rightmost "pointer to" sets one boundary, and the leftmost "function returning" set another one:

> <del>int (*(*</del> • ) • <del>())()</del>

The • indicators show the only two places that could possibly hold the variable name, but the leftmost one is the only one that fits the "inside the grouping parens" rule. This gives us our declaration as:

> int (*(*foo)())()

which our "normal" rules describe as:

```shell
$ cdecl explain 'int (*(*foo)())()'
declare foo as pointer to function returning pointer to function returning int
```

**Semantic restrictions/notes**

Not all combinations of derived types are allowed, and it's possible to create a declaration that perfectly follows the syntax rules but is nevetheless not legal in C (e.g., *syntatically* valid but *sematically* invalid). We'll touch on them here.

- **Can't have arrays of functions**

    Use "array of pointer to function returning..." instead.

- **Functions can't return functions**

    Use "function returning pointer of function returning..." instead.

- **Functions can't return arrays**

    Use "function returning pointer to array of..." instead.

- **In arrays, only the leftmost [] can be undimensioned**

    C support multi-dimensional arrays (e.g., **char foo[1][2][3][4][5]**), though in pratice this often suggests poor data structing.

    Nevertheless, when there is more than one array dimension, only the leftmost one is allowed to be empty. **char foo[]** and **char foo[][5]** are legal, but **char foo[5][]** is not.

- **"void" type is restricted**

    Since **void** is a special pseudo-type, a varialbe with this basic type is only legal with a final derived type of "pointer to" or "function returning". It's not legal to have "array of void" or to declare a variable of just type "void" without any derived types.

```c
void *foo;            // legal
void foo();           // legal
void foo;             // not legal
void foo[];           // not legal
```

- - -
- - -

**References:**

1. [Steve Friedl's Unixwiz.net Tech Tips - Reading C type declarations](http://unixwiz.net/techtips/reading-cdecl.html)
