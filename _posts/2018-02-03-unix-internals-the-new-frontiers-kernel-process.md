---
layout: post
title: "Unix Internals: The New Frontiers"
date: 2018-02-03 15-14-37 +0800
categories: ['Unix',]
tags: ['Unix', 'Kernel']
disqus_identifier: 83792099409831129219031460862419980974
---

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
