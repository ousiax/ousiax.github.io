---
disqus_identifier: 206300561507362048657572104178660119172
layout: post
title: "C track: compiling C programs"
date: 2015-08-22 13:53:11 +0800
categories: ['C', ]
tags: ['C', 'Compiling']
---

* TOC
{:toc}

* * *
*Orinial：[C track: compiling C programs.](http://courses.cms.caltech.edu/cs11/material/c/mike/misc/compiling_c.html)*

尽管有些计算机语言（如 Schema 或者 Basic）通常使用交互式的解释器（当你输入命令后，就可立即执行），但 C 语言不是。C 的源文件总是要通过一个叫做编译器（compiler）的程序编译成二进制代码然后运行。这就是我们接下来要详细说明的几个步骤。

* * *

## 几种不同类型的文件

你需要4种文件进行编译C 程序：

1.  常规的源代码文件（**source code**）。这些文件包含了函数定义，并约定以 "*.c*" 作为结尾进行命名。

2.  头文件（**Header**）. 这些文件包含了函数声明（也叫做函数原型）以及各种预处理语句。源文件可以通过头文件访问外部定义的函数。头文件的文件名约定以 "*.h*" 作为结尾.

3.  目标文件（**Object**）. 这些文件由编译器的输出而产生。目标文件包含了二进制形式的函数定义，本身是不可执行文件。目标文件的文件名约定以"*.o*" 结尾，尽管在一些操作系统，如（Windows, MS-DOS），经常以"*.obj*" 结尾。

4.  二进制可执行文件（**Binary executables**）。这些文件由一个叫做链接器（*linker*）的程序的输出而产生。链接器链接一些目标文件并产生可以直接执行的二进制文件。二进制可执行文件在 Unix 操作系统上没有后缀名，但在 Windows 上，通常以"*.exe*" 作为后缀名。 

还有其他的各种文件，尤其是静态库文件（"*.a*" files or "*.lib*" on Windows）以及共享库文件（"*.so*" files or "*.dll*" on Windows）。但通常，你不需要直接与他们打交道。

## 预处理

在编译器开始编译源文件之前，源文件由预处理器（_preprocessor_）进行处理。预处理器是一个真实的单独的程序（通常叫做"*cpp*", for "C preprocessor"），而由编译器在编译前自动调用。预处理器的工作就是将源文件转换成另外一个源文件（你也可以认为是对源文件的修改或者扩展）。修改后的文件可能作为一个真实的文件存在文件系统中，也可能仅仅是在发送给编译器之前在内存中作短暂的保留。另外，你不需要特别关注预处理，但是你需要知道预处理是干什么滴。

预处理指令以符号（"`#`"）开始. 在多种预处理指令中，有两种最为重要：

1.  **`#define`**. 主要用于定义常量。如，

        #define BIGNUM 1000000

    指定在剩下的程序中任何位置处理的字符串 BIGNUM 应该被替换为 1000000。例如，这个语句：

        int a = BIGNUM;

    变成了

        int a = 1000000;

    `#define` 语句用于避免一个常量值在源文件中多处重复出现。这在你随后需要对这常量值进行修改时是相当的重要，并且可以减少bug 的滋生，你只需要对 ＃define 的定义修改，而不是对常量值在整个源代码中多处的出现位置进行修改。

2.  **`#include`**. 用于访问位于源文件之外的函数定义。例如：

        #include <stdio.h>

    在源代码编译之前，预处理器将*&lt;stdio.h&gt;* 的内容替换 `#include` 语句所在的位置。 `#include` 总是用于主要包含函数声明和`#define` 语句的头文件。 这时，我们可以通过 `#include` 语句而使用一些函数，如 `printf` 和 `scanf`, 这两个函数的声明就位于文件 *stdio.h* 中. 在源文件中，在函数声明或者定义之前，C compilers 是不允许我们使用函数的；`#include` 语句就是用于这种情况，从而使我们可以复用之前用C 编写的代码。

还有其他的各种预处理指令，我们将会根据需要进行有所处理。

## 生成目标文件: 编译器

在 C 预处理器包含了所有的头文件并且展开所有的 `#define` 和 `#include` 语句（也有其他一些在源文件中出现的预处理指令）后，编译器就可以编译程序了。编译器将 C 源文件编译成目标文件（**object code），**包含二进制版本源代码并以 ".o" 结尾的文件。 然而，目标文件并不能直接运行。为了能够生成可执行文件，你还需要加入被 #include 包含的库函数代码（这个通过 #include 包含函数声明是不一样的）。这就是下一节要讲到的链接器 linker 的工作。

通常，编译由以下方式被调用：

    % gcc -c foo.c

符号 `%` 是 unix 提示符. 它告诉编译器对文件 *foo.c* 运行预处理程序并编译成目标文件 *foo.o*。 `-c` 选项意思是由编译器将源文件编译成目标文件而不会调用链接器。如果你的整个程序就一个源文件，你也可以这么做：

    % gcc foo.c -o foo

它告诉编译器在文件 *foo.c* 运行预处理器，编译并链接产生一个可执行文件 *foo*。`-o` 表示二进制可执行文件（程序）将以其随后的单词作为文件名。 如果你不制定 `-o` 选项，或者仅仅是输入 `gcc foo.c`，由于某种历史原因，可执行文件将以 *a.out* 命名。

请注意编译器的名字，我们使用的是 *gcc*，代表 "GNU C compiler" 或者 "GNU compiler collection" 。也有其他的编译器；他们中大多数都以 *cc*（"C compiler"）命名。在 Linux 操作系统中 *cc* 是 *gcc* 的别名。

## 揉成一团: 链接器

链接器的工作就是将一组目标文件（.o 文件）一起链接到一个二进制可执行文件。这包括从你的源代码文件编译的目标文件，以及预编译的库文件（**library files）。** 这些文件 *.a* 或者 *.so* 作为结尾命名，通常你不需要知道他们，因为他们中大多数可以由链接器（*linker*）定位并根据需要自动链接。

像预处理器一样，链接器也是一个叫做 ld 独立的程序。也如预处理器一样，链接器在你使用编译器时自动被调用。链接器通常使用的方式如下：

    % gcc foo.o bar.o baz.o -o myprog

这一行是告诉编译器一起将三个目标文件（`foo.o`, `bar.o`, and `baz.o`） 链接成一个名为 *myprog* 的二进制可执行文件. 

这就是你需要知道如何编译你的 C 程序的事情。通常，我们也推荐 `-Wall` 选项：

    % gcc -Wall -c foo.cc

`-Wall` 选项让编译器对合法但是可以的代码结构发出警告，并且帮助你轻松捕获一些 bugs。如果你想要更多的编译检查项:

    % gcc -Wall -Wstrict-prototypes -ansi -pedantic -c foo.cc

 `-Wstrict-prototypes` 选项是让编译器对代码中没有正确原型的函数发出警告。`-ansi` 和 `-pedantic` 是让编译器对代码中不可移植的结构（_e.g._ 一些在 gcc 中合法而不满足标准 C compilers 的代码结构；这些结构通常是需要避免的）发出警告。

* * *

## References

* Kernighan and Ritchie, [The C Programming Language, 2nd Ed](http://www.amazon.cn/C-Programming-Language-Kernighan-Brian-W/dp/0131103628/ref=sr_1_fkmr0_3?ie=UTF8&qid=1458935417&sr=8-3-fkmr0&keywords=The+C+Programming+Language%2C+2nd+Ed).

* The man page for *gcc*. Type: `man gcc` at the unix prompt.

* The GNU Info documentation on *gcc*.  ***Warning!*** This is far more information than most people could possibly absorb in the average millenium.

    Info documentation on *gcc* can be accessed through the GNU emacs editor by typing "M-x info" (where "M-x" means to hit the meta-key and "x" simultaneously), or "C-h i" (where "C-h" means to hit the control key and "i" simultaneously), followed by "mgcc&lt;return&gt;". Type "minfo&lt;return&gt;" instead for a quick tour of how to use info. You can also access the info documentation from the unix command line by typing `info gcc`.

* * *
