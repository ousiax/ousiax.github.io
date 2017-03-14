---
layout: post
title: "Compile and Run C Program in Linux Using gcc"
date: 2017-03-14 15-41-52 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 218913577362729603218920453083406134879
---
* TOC
{:toc}

* * *

### Compile C Program in Linux - The Classic Hello World!

Kernighan and Ritchie (K & R) in their classic book on C programming language acquaint readers to C language by compiling and executing "Hello World!" C program as follows. 

```c
/* hello.c */

#include <stdio.h>

int main(void)
{
    printf("Hello World!\n");
    return 0;
}
```

The following command compiles C program `hello.c` and creates an executable file (which contains a sequence of instructions that a machine can unserstand).

```shell
$ gcc hello.c -o hello
```

While compiling `hello.c` the *gcc* compiler reads the source file `hello.c` and translates it into an executable `hello`. The compilation is performed in four sequential phases by the compilation system (a collection of four programs - *preprocessor*, *compiler*, *assembler*, and *linker*).

#### 1. Preprocessing

During compilation of a C program the compilation is started off with preprocessing the directives (e.g. #include and #define). The preprocessor (*cpp* - c preprocessor) is a separate program in reality, but it is invoked automatically by the compiler. The result is another file typically with the `.i` suffix. In pratice, the preprocessed file is not saved to disk unless the `-save-temps` option is used.

This is the first stage of compilation process where preprocessor directives (macros and header files are most common) are expanded. To perform this step gcc executes the following command internally.

```sh
$ cpp hello.c > hello.i
```

The result is a file `hello.i` that contains the source code with all macros expaned.

#### 2. Compilation

In this phase compilation proper takes place. The compiler (*cll*) translates `hello.i` into `hello.s`. File `hello.s` contains assembly code. You can explicitly tell *gcc* to translate `hello.i` to `hello.s` by executing the following command.

```sh
$ gcc -S hello.i
```

The command line option `-S` tells the compiler to convert the preprocessed code to assembly language without creating an object file. You may note the assembly code conatins a call to the external function `printf` (or `puts` on *gcc version 4.9.2 (Debian 4.9.2-10)*).

#### 3. Assembly

Here, the assembler (*as*) translates `hello.s` into machine language instructions, and generates an object file `hello.o`. You can invoke the assembler at your own by executing the following command.

```sh
$ as hello.s -o hello.o
```

The above command will generate `hello.o` as it is specified with `-o` option. And, the resulting file contains the machine instructions for classic "Hello World!" program, with an undefined reference to `printf` (or `puts`).

#### 4. Linking

This is the final stage in compilation of "Hello World!" program. This phase links objects files to produce final executable file. An executable file requires many external resources (system functions, C run-time libraries etc.). Regardings our "Hello World!" program you have noticed that it calls the `printf` funtion to print the 'Hello World!' message on console. This function is conatined in a separate pre compiled object `printf.o`, which must somehow be merged with out `hello.o` file. The linker (*ld*) performs this task for you. Eventually, the resulting file `hello` is produced, which is an executable. This is now ready to be loaded into memory and execute by the system.

There is no need to type the complex `ld` command directly - the entire linking process is handled transparently by *gcc* when invoked, as follows.

```sh
$ gcc hello.o -o hello
```

And, you can greet the universe as follows:

```sh
$ ./hello
```

Output:

```sh
Hello World!
```

* * *

### Static and Dynamic Link Libraries in C on Linux

Static and dynamic linking are two processes of collecting and combining multiple object files in order to create a single executable. Linking can be performed at both **compile time**, when the source code is translated into machine code and **load time**, when the program is loaded into memory and executed by the loader, and even at **run time**, by application programs. And, it is performed by programs called **linkers**. Linkers are also called link editors.

#### What is Linker ?

### References

1. [C track: compiling C programs.](http://courses.cms.caltech.edu/cs11/material/c/mike/misc/compiling_c.html)
1. [gcc Compilation Process and Steps of C Program in Linux](http://cs-fundamentals.com/c-programming/how-to-compile-c-program-using-gcc.php)
1. [Create Static and Dynamic Library in C using gcc on Linux](http://cs-fundamentals.com/c-programming/static-and-dynamic-linking-in-c.php)
