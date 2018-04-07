---
layout: post
title: "Unix Internals: The New Frontiers"
date: 2018-02-03 15:14:37 +0800
categories: ['Unix',]
tags: ['Unix']
disqus_identifier: 83792099409831129219031460862419980974
---

- TOC
{:toc}

### 进程与内核

- - -

#### 2.1 简介

- 操作系统的主要功能是为用户程序（应用程序）提供可以运行的执行环境。这包括程序的执行定义的一个基本框架，并提供一整套服务（例如文件管理和I/O）和这些服务的接口（interface）。

- UNIX 应用程序环境包含一个基本抽象——进程（process）。

    `进程 (process)` `地址空间 (address space)` `指令系列` `进程控制点 (control point)` `程序计数器 (program counter, PC)` `硬件寄存器` `多个控制点 [线程 (thread)]`

- UNIX 系统是一个多道编程环境（multiprogramming environment），即几个进程可以并发地在系统中活动。

    `多道编程环境 (multiprogramming environment)` `虚拟机 (virtual machine)` `寄存器` `内存` `I/O`

- 进程的地址空间是虚拟的，并且通常只有部分地址空间与物理内存的位置对应。

    `进程(虚拟)地址空间` `物理内存` `磁盘` `交换区 (swap area)` `存页 (page, 固定大小的块)`

- 每个进程都有一组寄存器，对应于实际的硬件寄存器。

    系统中会有很多活动进程，但只有一组硬件寄存器。

    内核将当前正在运行的进程的寄存器内容保存到硬件寄存器中，而将其他进程的寄存器内容保存在每个进程的数据结构中。

- 进程之间会争用系统的各类资源，如处理器（又称中央处理器或 CPU），内存和外围设备。

    `阻塞 (block) (暂停执行)` `配额 (quantum) 10ms` `时间片 (time-slicing)`

- 内核是一个特殊的程序，可以直接运行在设备上。它实现了进程模型和其他系统服务。

    - 内核驻留在磁盘的一个文件中，通常是 */vmunix* 或 */unix* （取决于具体的 UNIX 厂商）。
    - 当系统启动时，使用称为`引导 (bootstrapping)` 的特殊过程 (procedure) 从磁盘上加载内核。
    - 接着，内核初始化系统，为进程运行设置环境。
    - 然后，创建几个初始进程，这些进程随后依次创建其他进程。
    - 一旦加载完成，内核会一直驻留在内存中，直到系统关闭。
    - 它管理着所有的进程，为进程提供各种服务。

- UNIX 操作系统从四个方面来提供功能：
    - 用户进程显示地通过系统调用接口向内核请求服务，`系统调用接口 (system call interface)` 是 UNIX API 的核心组成部分。
        - 内核代表调用进程 (calling process) 来执行这些请求。

    - 进程的一些不寻常动作，例如试图除以零，或者用户栈 (user stack) 溢出，会引起`硬件异常 (hardware exception)`。
        - 异常需要内核的干预，由内核代表进程来处理它们。
    - 内核处理来自外围设备的硬件`中断 (interrupt)`。
        - 设备使用中断机制来通知内核 I/O 的完成和状态变化。
        - 内核将中断视为全局事件，与任何指定的进程都没有关联。
    - 一组特殊的系统进程，像 swapper 和 pagedaemon 会执行系统级别的任务，如控制活动进程的数目和维持一个空闲的内存池。

- - -

#### 2.2 模式、空间和上下文

`执行模式 (execution mode)` `内核态 (kernel mode)` `用户态 (user mode)` `执行等级 (ring of execution)`

`虚拟内存 (virtual memory)` `虚拟地址空间 (virtual address space)` `地址转换映射表 (address translation table)` `页表 (page table)` `页 (page, 一种固定大小的内存分配和保护单元)` `内存管理单元 (memory management unit, MMU)` `当前进程` `上下文切换 (context switch)` 

`系统空间 (system space)` `内核空间 (kernel space)` `全局数据结构` `每进程 (per-process) 对象`

`系统调用 (system call)` `模式切换 (mode switch)`

`u 区 (u area, 也称为用户区，user area)` `内核栈 (kernel stack)` `可重入 (re-entrant)`

`执行上下文 (execution context)` `进程上下文 (process context)` `系统上下文 (system context)` `中断上下文 (interrupt context)`

- 用户代码在用户态和进程上下文中运行，但只能访问进程空间。
- 系统调用和异常在内核态中，但在进程上下文中被处理，可以访问进程空间和系统空间。
- 中断在内核态和系统上下文中处理，只能访问系统空间。

- - -

#### 2.3 进程抽象

- 进程就是一个实体，运行一个程序并为它提供一个可以执行的环境。

    `fork` `vfork` `exit` `exec`

    `父进程 (parent)` `子进程 (child)` `系统进程/守护程序` `孤儿进程 (orphan)`

- 不论什么时候，UNIX 进程总是会处于某一明确定义的`状态 (state)`。进程会在对各种事件的响应中，从一个状态转移到另外一个状态。

    `fork()` `初始 (initial) (也称为空闲 (idle)) 状态` `就绪 (ready to run) 状态` `上下文切换: swtch()`

    `用户运行态` `系统运行态` `sleep()` `睡眠 (alseep) 状态` `进程队列` `内核运行 (kernel running)`

    `exit()` `信号 (signal, 信号是由内核所发出的通知)` `退出状态 (exit status)` `资源使用情况 (resource usage)` `僵死 (zombie) 状态` `wait()`

    `SIGSTOP` `SIGTSTP` `SIGTIN` `SIGTTOUT` `停止 (stop) 或 挂起 (suspend) 状态` `停止 (stopped)` `SIGCONT` `停止态 + 睡眠态`

- 每个进程有一个明确定义的上下文，包含那些描述进程时所需的所有信息。

    - **用户地址空间** (user address space)

        `程序代码 (可执行代码)` `数据` `用户栈` `共享内存区`

    - **控制信息** (control information)

        `u 区` `proc 结构` `内核栈` `地址转换映射表`

    - **凭据** (credential)

        `UID` `GID`

    - **环境变量** (environemnt variables)

        当调用一个新进程时，调用者可以请求 `exec` 保留原始环境变量（从父进程继承而来的）或者提供一组新的变量来代替。
    - **硬件上下文** (hardware context)  `进程控制块 (process control block), PCB`
        - 程序计数寄存器 (program counter, PC)
        - 堆栈指针寄存器 (stack pointer, SP)
        - 状态标志寄存器 (processor status word, PSW)
        - 内存管理寄存器 (memory management registers)
        - 浮点运算单元 (floating point unit, FPU) 寄存器

-  在系统中的每个用户都有一个唯一的编号，称为“用户 ID" 或 UID 以及所属的一个或多个用户组，每组拥有一个唯一的用户组 ID 或 GID。

    `凭据 (credential)` `超级用户 (superuser), root`

    `setuid()` `setgid()`

    `保存的 (saved) UID` `保存的 GID` `附加组 (supplemental group)` `setgroups()` `主组 (primary group)`

    - 每个进程有两对 ID：实际的（real）ID 和有效的（effective）ID。
    - 有效的 UID 和有效的 GID 影响力文件的创建和访问。
        - 在文件创建期间，内核将文件的拥有者设置为正常创建文件的进程的有效 UID 和 GID。
        - 在文件访问期间，内核使用进程的有效 UID 和 GID 来决定它是否可以访问该文件。
    - 实际的 UID 和实际的 GID 标识了进程的实际拥有者，影响发送信号的权限。
        - 非超级用户权限的进程发送信号给另外一个进程时，只能在发送者的实际或有效 UID 与接收者的 UID 匹配时才可以发送。
    - 如果一个进程调用 `exec` 来运行处于 `suid` 模式的程序，内核会将进程的有效 UID 改为文件所有者的有效 UID。同样，如果程序是 `sgid` 模式，内核会改变调用进程的有效 GID。

- 有关进程的控制信息保存在两个每进程的数据结构中：u 区和 proc 结构。

    `进程表 (process table)` `用户空间` `系统空间`

    - 在很多实现上，内核有一个固定大小的 proc 结构数组，称为`进程表 (process table)`。
        - 数组的大小严格限制了可以存在的进程最大数目。
        - 由于 proc 结构是在系统空间里，所以任何时候 proc 结构对内核都是可见，即便在进程没有运行时。
    - 而 u 区或者用户区是进程空间的一部分，也就是说，只有进程运行时它才会被映射，才是可见的。
        - 很多实现中，u 区总是被映射到每个进程里相同的固定虚拟地址上，内核可以简单的通过变量 u 进行引用。
        - 上下文切换的其中一个任务就是重置该映射，以便内核在引用变量 u 时能够转换到新的 u qu的物理位置上。
    - u 区只包含进程运行时所需的数据
        - 进程控制块：存放进程来运行时已经保存的硬件上下文内容
        - 指向该进程 proc 结构的指针
        - 实际和有效的 UID 和 GID
        - 传给当前系统调用的参数和从当前系统调用的返回值或者错误状态
        - 信号处理函数（signal handler）和相关信息
        - 来自程序头部的信息，如代码（text）、数据（data）、栈大小，以及其他内存管理信息
        - 打开的文件描述符表
        - 指向当前路径（current directory）和控制终端（controlling terminal）的 vnode 指针
        - CPU 的使用统计，profiling 信息，磁盘配额和资源限制
    - proc 结构包含了那些即使进程没有运行但也可能需要的信息
        - 标识（identification）：每个进程有一个唯一的进程 ID （PID），属于特定的某进程组
        - 与该进程 u 区映射的内核地址转换表（kernel address map）的位置
        - 当前进程状态
        - 前向指针和后向指针，将进程链接到调度队列，或将阻塞的进程链接到睡眠队列
        - 阻塞进程的睡眠通道
        - 调度优先级和相关信息
        - 信号处理信息：将要被忽略、阻塞、发送（post）和处理的信号的屏蔽字（mask）
        - 内存管理信息
        - 将该结构链接到活动、空闲或者僵死进程链表的指针
        - 一些杂项标志
        - 让该结构继续处于下一个以 PID 为 key 的散列队列（hash queue）中的指针
        - 层次体系结构，描述了该进程与其他进程之间的关系 

#### 2.4 执行在内核态中

- 设备中断、异常、陷入或软件中断 `分发表 (dispatch table)`
    - 中断是由像磁盘、终端或硬件时钟等外围设备引发的异步事件
        - 中断不是由当前进程引发的，他们必须在系统上下文中处理，不能访问进程的地址空间和 u 区
        - 硬件中断的主要功能是允许外围设备与 CPU 交互，来通告 CPU 任务的完成、错误状况，或者其他需要紧急关注的事件

            `中断处理函数 (interrupt handler)` `中断服务例程 (interrupt server routine)`

            `时间片 (time slice)` `时钟中断处理函数 (clock interrupt handler)` `时钟 tick` `proc 结构`

            `软中断或陷入`

            `中断优先级 (interrupt priority level, ipl)` `状态标志寄存器`

            `中断栈 (interrupt stack)` `内核栈 (kernel stack)` `上下文层 (context layer)`

    - 异常对进程而言是同步的，是进程自己的相关事件引发的，比如试图除以零或者访问非法地址
        - 异常的处理例程运行在进程上下文中，可以访问进程的地址空间和进程的 u 区，必要时还会被阻塞
    - 软件中断，或者陷入，在进程执行特殊的指令时发生，如系统调用，而且也是在进程上下文中同步处理的

        `标准 C 库` `封装例程 (wrapper routine)` `陷入 (trap) 指令: syscall/chmk/trap` `内核态` `syscall()`

        `用户栈` `u 区` `硬件上下文` `内核栈` `调用编号` `分发向量` `sysent()` `内核函数` `用户态`

#### 2.5 同步

- UNIX 内核是可重入的。`不可抢占的（nonpreemptive）` `阻塞操作` `中断` `多处理器`
- 当进程进入睡眠状态等待资源可用或事件发生时，进程`阻塞(block)` 在资源或事件上
- 内核会临时进展中断或者信号的传送来`屏蔽 (block)` 它们
- I/O 子系统已固定大小的`块 (block)` 来将数据传入或传出存储设备

    `阻塞操作 (blocking operation)` `睡眠状态` `标志位` `锁` `等待完成 (wanted) 标志`

    `sleep()` `阻塞队列` `swtch()`

    `wakeup()` `可运行的 (runable)` `调度队列`

    `中断处理函数` `临界区 (critical region)`

    `全局数据结构` `多处理器安全 (multiprocessor-safe)`

#### 2.6 进程调度

`CPU` `调度器 (scheduler)` `抢占式轮转调度策略 (preemptive round-robin scheduling)`

`nice 值` `usage 因子` `进程饿死 (starvation)`

`调度优先级` `内核优先级` `用户优先级` `睡眠优先级 (sleep priority)`

#### 2.7 信号

- UNIX 使用`信号(singal)` 来通知进程异步事件的发生及异常处理
- 进程可以使用 `kill` 系统调用显式地向一个或多个进程发送信号
- 终端驱动程序响应某些按键和事件时，会向与终端关联的进程发送信号
- 内核生成信号来通知进程发生了硬件异常，或满足某种条件（如达到了配额）
- 进程并不会立即响应一个信号

`信号 (signal)` `SIGUSR1` `SIGUSR2`

`终止进程` `挂起进程` `忽略信号` `信号处理函数` ` 阻塞信号` `信号屏蔽字`

`signal (System V)` `sigvec (BSD)` `sigaction (POSIX.1)`

`中断睡眠` `siginterrupt`

#### 2.8 新的进程和程序

`fork` `vfork` `exec` `exit`

`数据段` `栈区` `交换空间 (swap space)`

`PID` `proc 结构` `UID` `GID` `进程组` `信号屏蔽字` `驻留时间` `CPU 使用情况` `睡眠通道` `PPID`

`地址转换映射表` `u 区` `共享资源` `硬件上下文` `调度器队列`

`写时复制 (copy-on-write)` `只读页` `写时复制标志` `缺页异常 (page fault)`

`vfork`

- 进程的地址空间有几个基于功能划分的不同的组成部分
    - 代码 (text) : 包含可执行代码，对应程序的代码区 (text section)
    - 初始化数据 (initialized data): 历史上称为块静态存储 (block static storage, bss) 区，由已经声明但没有初始化的变量组成。在这个区的对象首次访问时，可以确保初始值为 0.因为在可执行文件保存多个 0 值的页是比较浪费的，程序头部简单地记录了该区域的总体大小，并依赖于操作系统为这些地址生成 0 值的页。
    - 共享内存 (shared memory): 很多 UNIX 系统允许进程共享内存
    - 共享库 (shared library): 如果系统支持动态链接库，进程可以包含几个独立的内存区，里面包含了可以被其他进程共享的库代码和数据
    - 堆 (heap): 动态内存分配的源。进程通过 `brk` 或 `sbrk` 系统调用，或者使用标准 C 库里面的 `malloc` 从堆上分配内存。内核为每个进程提供了一个堆，并可以按需扩展
    - 用户栈 (user stack): 内核为每个进程分配一个栈。在很多传统的 UNIX 实现里，内核可以透明地捕获栈溢出的异常，并将用户栈扩展到一个事先设定的最大值

`SZOME (僵死)` `SIGCHLD 信号` `wait` `wait3` `waitpid` `waitid` `init 进程` `SA_NOCLDWAIT 标志`
