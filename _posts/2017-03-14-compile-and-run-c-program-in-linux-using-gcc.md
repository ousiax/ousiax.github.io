---
layout: post
title: "Compile and Run C Program in Linux Using GCC"
date: 2017-03-14 15:41:52 +0800
categories: ['C']
tags: ['C']
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

While compiling `hello.c` the *GCC* compiler reads the source file `hello.c` and translates it into an executable `hello`. The compilation is performed in four sequential phases by the compilation system (a collection of four programs - *preprocessor*, *compiler*, *assembler*, and *linker*).

#### 1. Preprocessing

During compilation of a C program the compilation is started off with preprocessing the directives (e.g. `#include` and `#define`). The preprocessor (**cpp** - c preprocessor) is a separate program in reality, but it is invoked automatically by the compiler. The result is another file typically with the `.i` suffix. In pratice, the preprocessed file is not saved to disk unless the `-save-temps` option is used.

This is the first stage of compilation process where preprocessor directives (macros and header files are most common) are expanded. To perform this step GCC executes the following command internally.

```sh
$ cpp hello.c > hello.i # gcc -E hello.c > hello.i
```

By default, the preprocessor looks for *header files* included by the quote form of the directive `#include "file"` first relative to the directory of the current file, and then in a preconfigured list of standard system directories. For example, if */usr/include/sys/stat.h* contains `#include "types.h"`, GCC looks for *types.h* first in */usr/include/sys*, then in its usual search path.

For the angle-bracket form `#include <file>`, the preprocessor’s default behavior is to look only in the standard system directories. The exact search directory list depends on the target system, how GCC is configured, and where it is installed. You can find the default search directory list for your version of CPP by invoking it with the *-v* option. For example,

```sh
cpp -v /dev/null -o /dev/null
```

```console
#include "..." search starts here:
#include <...> search starts here:
 /usr/lib/gcc/x86_64-linux-gnu/8/include
 /usr/local/include
 /usr/lib/gcc/x86_64-linux-gnu/8/include-fixed
 /usr/include/x86_64-linux-gnu
 /usr/include
```

There are a number of command-line options you can use to add additional directories to the search path. The most commonly-used option is `-Idir`, which causes dir to be searched after the current directory (for the quote form of the directive) and ahead of the standard system directories. You can specify multiple `-I` options on the command line, in which case the directories are searched in left-to-right order. 

#### 2. Compilation

In this phase compilation proper takes place. The compiler (**cc1**) translates `hello.i` into `hello.s`. File `hello.s` contains assembly code. You can explicitly tell *GCC* to translate `hello.i` to `hello.s` by executing the following command.

```sh
$ /usr/lib/gcc/x86_64-linux-gnu/8/cc1 -quiet hello.i # gcc -S hello.i
```

The command line option `-S` tells the compiler to convert the preprocessed code to assembly language without creating an object file. You may note the assembly code conatins a call to the external function `printf` (or `puts` on *gcc version 8.3.0*).

#### 3. Assembly

Here, the assembler (**as**) translates `hello.s` into machine language instructions, and generates an object file `hello.o`. You can invoke the assembler at your own by executing the following command.

```sh
$ as hello.s -o hello.o # gcc -c hello.s
```

The above command will generate `hello.o` as it is specified with `-o` option. And, the resulting file contains the machine instructions for classic "Hello World!" program, with an undefined reference to `printf`.

#### 4. Linking

This is the final stage in compilation of "Hello World!" program. This phase links objects files to produce final executable file. An executable file requires many external resources (system functions, C run-time libraries etc.). Regardings our "Hello World!" program you have noticed that it calls the `printf` funtion to print the 'Hello World!' message on console. This function is conatined in a separate pre compiled object `printf.o`, which must somehow be merged with out `hello.o` file. The linker (**ld**) performs this task for you. Eventually, the resulting file `hello` is produced, which is an executable. This is now ready to be loaded into memory and execute by the system.

There is no need to type the complex `ld` command directly - the entire linking process is handled transparently by *GCC* when invoked, as follows.

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

#### 1. What is Linker ?

Linker is system software which plays curcial role in software development because it enables separate compilation. Instead of organizing a large application as one monolithic source file, you can decompose it into smaller, more manageable chunks that can be modified and compiled separately. When you change one of the modules, you simply recompile it and re-link the application, without recompiling the other source files.

Linker as a system program takes relocatable object files and command line arguments in order to generate an executable object file. To produce an executable file the Linker has to perform the symbol resolution, and Relocation.

Note: Object files come in three flavors viz Relocatable, Executable, and Shared.

- **Relocatable object files** contain code and data in a form which can be combined with other objects files of its kind at compile time to create an executable object file. They consist of various code and data sections. Instructions are in one section, initialized global variables in another section, and unitialized variables are yet in another section.
- **Executable object files** contain binary code and data in a form which can directly be copied into memory and executed.
- **Shared object files** are files those can be loaded into memory and linked dynamically, at either load or run time by a linker.

While linking, the linker complains about missing function definitions, if there is any. During compilation, if compiler does not find a function definition for a particular module, it just assumes that the function is defined in another file, and treats it as an **external reference**. The compiler does not look at more than one file at a time. Whereas, linker may look at multiple files and seeks references for the modules that were not mentioned. The separate compilation and linking processes reduce the complexity of program and gives the ease to break code into smaller pieces which are better manageable.

#### 2. What is Static Linking?

Static linking is the process of copying all library modules used in the program into the final executable image. The linker combines library routines with the program code in order to resolve external references, and to generate an executable image suitable for loading into memory. This of course takes more space on the disk and in memory than dynamic linking. But static linking is faster and more portable because it does not require the presence of the library on the system where it runs.

We will deveop an `add` module and place in a separate `add.c` file. Prototype of `add` module will be placed inn a separate file called `add.h`. Code file `hello.c` will be created to demonstrate the linking process.

```c
/* add.h */

int add(int , int);
```

```c
/* add.c */

int add(int a, int b)
{
    return a + b;
}
```

```c
/* hello.c */

#include <stdio.h>
#include <add.h>

int main(void)
{
    int a = 3, b = 4;
    printf("%d + %d = %d\n", a, b, add(a, b));
    return 0;
}
```

After having created above files, you can start building the executable as follows:

```shell
$ gcc -I . -c hello.c
```

The `-I` option tells *GCC* compiler to search for header files in the directory which is specified after it.

The `-c` option tells *GCC* compiler to compile into an object file. It will stop after that and won't perform the linking to create the executable.

As similar to the above command, compile `add.c` to create the object file.

```shell
$ gcc -c add.c
```

Now the final step is to generate the executable by linking `add.o`, and `hello.o` together. 

```shell
$ gcc -o hello add.o hello.o
```

#### 3. How to Create Static Libraries?

A library contains hundreds or thousands of object files to keep the orgnaization of object files simple and maintainable.

Static libraries are bundle of *relocatable* object files. Usually they have `.a` extension.

For more explanatory demonstration of use of libraries we would create a new header file `math.h` and will add singatures of two functions `add`, `sub` to that.

```c
/* math.h */

int add(int, int);
int sub(int, int);
```

```c

/* sub.c */

int sub(int a, int b)
{
    return a - b;
}
```

Now compile `add.c` and `sub.c` as follows in order to get the binary object files.

```shell
$ gcc -c add.c sub.c
```

Create the static library `libmath.a` to collecting both `add.o` and `sub.o` files together by executing the following command:

```shell
$ ar rs libmath.a add.o sub.o
```

To use the `sub` funciton in `hello` we need to replace the `#include <math.h>` by `#include <math.h>` and recompile it.

```c
/* hello.c */

#include <stdio.h>
#include <math.h>

int main(void)
{
    int a = 3, b = 4;
    printf("%d + %d = %2d\n", a, b, add(a, b));
    printf("%d - %d = %2d\n", a, b, sub(a, b));
    return 0;
}
```

```shell
$ gcc -c hello.c -I .
```

And link it with `libmath.a` to generate final executable object file.

```shell
$ gcc -o hello hello.o libmath.a
```

You can also use the following command as an alternative to link the `libmath.a` with `hello.o` in order to generate the final executable file.

```shell
$ gcc -o hello hello.o -L . -lmath
```

In above command `-lmath` should be read as `-l math` which tells the linker to link the object files contained in `lib<library>.a` with `hello.o` to generate the executable object file.

The `-L` option tells the linker to search for libraries in the following argument (similar to how we did for `-I`).

#### 4. What is Dynamic Linking?

Dynamic linking defers much of the linking process until a program starts running. During dynamic linking the name of the shared library is placed in the executable image, while the actual linking takes place at run time when both the executable and library are placed in memory. Dynamic linking serves the advantage of sharing a single shareable library among multiple programs.

#### 5. How to Create and Use Shared Libraries?

Let's continue with the previous example of `add`, and `sub` modules. Now we will have to recompile both `add.c` and `sub.c` again with `-fpic` or `-fPIC` option. The `-fpic` or `-fPIC` option enable "*position independent code*" generation, a requirement for shared libraries, and used to generate code that is target-dependent. The `-fPIC` choice always works, but may produce larger code than `-fpic`. Using `-fpic` option usually generates smaller and faster code, but will have platform-dependent limitations. So, while creating shared library you have to recompile both `add.c`, and `sub.c` with following options:

```sh
$ gcc -Wall -fPIC -c add.c sub.c
```

Now build the library `libmath.so` using the following command.

```sh
$ gcc -shared -o libmath.so add.o sub.o
```

But to use a shared library is not as straightfoward as static library was. And, the simplest approach of installation is to copy the library into one of the standard directories (e.g., /usr/lib) and run `ldconfig` command.

Now recompile `hello.c` and generate the executable object file as following:

```sh
$ gcc -c hello.c -I .
```

```sh
$ gcc -o hello hello.o libmath.so
```

or 

```sh
$ gcc -o hello hello.o -L . -lmath
```

You can list the shared library dependencies which your executable is depedent upon with `ldd <name-of-executable>` command.

```sh
$ ldd hello
        linux-vdso.so.1 (0x00007ffdfdda2000)
        libmath.so => not found
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f318cde8000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f318d193000)
```

For more information about shared library, please refer to [Linux Shared Library Management & Debugging Problem](/2016/05/12/linux-commands-for-shared-library-management-and-debugging-problem/).

- - -

### References

1. [C track: compiling C programs.](http://courses.cms.caltech.edu/cs11/material/c/mike/misc/compiling_c.html)
1. [GCC Compilation Process and Steps of C Program in Linux](http://cs-fundamentals.com/c-programming/how-to-compile-c-program-using-gcc.php)
1. [Create Static and Dynamic Library in C using GCC on Linux](http://cs-fundamentals.com/c-programming/static-and-dynamic-linking-in-c.php)
1. [Search Path (The C Preprocessor)](https://gcc.gnu.org/onlinedocs/cpp/Search-Path.html#Search-Path)
