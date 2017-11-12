---
layout: post
title: "Understanding The Linux Kernel 01"
date: 2017-11-12 14-20-08 +0800
categories: ['Linux']
tags: ['Linux', 'Kernel']
disqus_identifier: 214637421380564030329447675521549613702
---

Linux is a member of the large family of Unix-like operating system.

Linux was initially deveoped by Linus Torvalds in 1991 as an operating system for IBM-compatible personal computers based on the Intel 80386 microprocessor.

Technically speaking, Linux is a true Unix kernel, although it is not a full Unix operating system, because it does not include all the applications such as filesystem utilities, windowing systems and graphical desktops, system administrator commands, text editors, compilers, and so on. However, since most of thes programs are freely available under the GNU General Public License, they can be installed into one of the filesytems supported by Linux.

### 1.1 Linux Versus Other Unix-Like Kernels

The various Unix-like systems on the market, some of which have a long history and may show signs of archaic practices, differ in many important respects. All commercial variants were derived from either SVR4 or 4.4BSD; all of them tend to agree on some common standards like IEEE's POSIX (Portable Operating Systems based on Unix) and X/Open's CAE (Common Applications Environment).

- The Linux kernel and most commercial Unix kernels are monolithic. A notable exception is Carnegie-Mellon's Mach 3.0, which follows a microkernel approach.
- Traditional Unix kernels are compiled and linked statically. Most modern kernels can dynammically load and unload some portions of the kernel code (typically, device derivers), which are usually called *modules*. Linux's support for modules is very good, since it able to automatically load and unload modules on demand.
- Kernel threading.

    A kernel thread is an execution context that can be independently scheduled; it may be associated with a user program, or it may run only some kernel functions. Context switches between kernel threads are usually much less expensive than context swithes between ordinary processes, since the former usually operate on a common address space.

    Linux uses kernel threads in a very limited way to execute a few kernel functions perodically; since Linux kernel threads cannot execute user programs, they do not represent the basic execution context abstraction.

- Multithreaded application support.

    Most modern operating systems have some kind of support for multithreaded applications, that is, user programs that are well designed in terms of many relatively independent execution flows sharing a large portion of the application data structures.

    A multithreaded user application could be composed of many *lightweight processes* (LWP), or processes that can operate on a common address space, common physical memory pages, common opened files, and so on.

    While all the commercial Unix variants of LWP are on kernel threads, Linux regards lightweight processes as the basic execution context and handles them via the nonstandard `clone()` system call.

- Linux is a nonpreemptive kernel.

    This means that Linux cannot arbitrarily interleave execution flows while they are in privileged mode.

- Multiprocessor support.

    Linux 2.2 offers an evolving kind of support for symmetric multiprocessing (SMP), which means not only that the system can use multiple processors but also that any processor can handle any task; there is no discrimination among them.

- Filesystem.

    Linux' standard filesystem lacks some advanced features, such as journaling. 

- STREAMS. 

    Linux has no analog to the STREAMS I/O subsystem introduced in SVR4, although it is included nowadays in most Unix kernels and it has become the preferred interface for writing device drivers, terminal drivers, and network protocals.

### 1.2 Hardware Dependency

Linux tries to maintain a neat distinction between hardware-dependent and hardware-independent source code. To that end, both the *arch* and the *include* directories include nine subdirectories correspoding to the nine hardware platforms supported. The standard names of the platforms are:

- *arm*

    Acorn personal computers

- *alpha*

    Compaq Alpha workstations

- *i386*

    IBM-compatible personal computers based on Intel 80x86 or Intel 80x86-compatible microprocessors

- *m68k*

    Personal computers based on Motorola MC680x0 microprocessors

- *mips*

    Workstations based on Silicon Graphics MIPS microprocessors

- *ppc*

    Workstations based on Motorola-IBM PowerPC microprocessors

- *sparc*

    Workstations based on Sum Microsystems SPARC microprocessors

- *sparc64*

    Workstations based on Sum Microsystems 64-bit Ultra SPARC microprocessors

- *s390*

    IBM System/390 mainframes

### 1.3 Linux Versions

Linux distinguishes stable kernels from development kernels through a simple numbering scheme. Each version is characterized by three numbers, separated by periods. The first two numbers are used to indentify the version; the third number indentifies the release.

If the second number is even, it denotes a stable kernel; otherwise, it denotes a development kernel.


![Numbering Linux versions]({{ site.baseurl }}/assets/images/understanding-the-linux-kernel/Numbering Linux Versions.png)

### 1.4 Basic Operating System Concepts

Any computer system includes a basic set of programs called the *operating system*.

The most important program in the set is called the *kernel*.

- It is loaded into RAM when the system boots and contains many critial procedures that are needed for the sytem to operate.
- The other programs are less crucial untilites; they can provide a wide variety of interactive experiences for the user—as well as doing all the jobs the user bought the computer for—but the essential shape and capabilities of the system are determined by the kernel.

The operating system must fulfill two main objectives:

- Interact with the hardware components servicing all low-level programmable elements included in the hardware platform.
- Provide an execution environment to the applications that run on the computer system (the so-called user programs).

Some operating systems allow all user programs to directly play with the hardware component (a typical example is MS-DOS). In contrast, a Unix-like operating system hides all low-level details concerning the physical orgnization of the computer from applications run by the user. When a program wants to make use of a hardware resource, it must issue a request to the operating system. The kernel evaluates the request and, if it chooses to grant the resource, interacts with the relative hardware components on behalf of the user program.

In order to enforce this mechnism, modern operating system rely on the availability of specific hardware features that forbid user programs to directly interact with low-level hardware components or to access arbitrary memory locations. In particular, the hardware introduces at least two different executions modes for the CPU: a nonprivileged mode for user programs and a privileged mode for the kernel. Unix call these *User Mode* and *Kernel Mode*, respectively.

#### 1.4.1 Multiuser Systems

A *mutliuser system* is a computer that is able to concurrently and independently execute several applications belonging to two or more users.

"Concurrently" means that applications can be active at the same time and contend for the various resources such as CPU, memory, hard disks, and so on.

"Independently" means that each application can perform its task with no concern for what the applications of the other users are doing.

Multiuser operating systems must include several features:

- An authentication mechanism for verifying the user identity.
- A protection mechanism against buggy user programs that could block other applications running in the system.
- A protection mechanism against malicious user programs that could interface with, or spy on, the activity of other users.
- An accounting mechanism that limits the ammount of resource units assigned to each user.

#### 1.4.2 Users and Groups

In a multiuser system, each user has a private space on the machine: typically, he owns some quota of the disk space to store files, receives private mail messages, and so on. The operating system must ensure that the private portion of a user space is visiable only its owner. In particular, it must ensure that no user can exploit a system application for the purpose of violating the private space of another user.

All users are identified by a unique number called the *User ID*, or UID. Usually only a restricted number of persons are allowed to make use of a computer system. When one of these users starts a working session, the operating system asks for a *login name* and a *password*. It the user does not input a valid pair, the system denies access. Since the password is assumed to be secret, the user's privacy is ensured.

In order to selectively share material with other users, each user is a member of one or more *groups*, which is identified by a unique number called a *Group ID*, or GID. Each file is also associated with exactly one group. For example, access could be set so that user owning the file has read and write privileges, the group has read-only privilidges, and others on the sytem are denied access to the file.

Any Unix-like operating system has a special user called *root*, *superuser*, or *supervisor*. The system administrator must log in as root in order to handle user accounts, perform maintenances like system backups and program upgrades, and so on.

#### 1.4.3 Processes

All operating systems make use of one fundamental abstraction: the *process*. A process can be defined either as "an instance of a program in execution," or as the "execution context" of a running programm. In traditional operating systems, a process executes a signle sequence of instructions in an *address space*; the address is the set of memory address that the process is allowed to reference. Modern operating systems allow processes with multiple execution flows, that is, multiple sequences of instructions executed in the same address space.

Multiuser systems must enforce an execution environment in which several processes can be active concurrently and contend for system resources, mainly the CPU. Systems that allow concurrent active processes are said to be *mutlprogramming* or *multiprocessing*. It is important to distiguish programs from processes: several processes can execute the same program concurrently, while the same process can execute several programs sequentially.

On uniprocessor systems, just one process can hold the CPU, and hence just one execution flow can progress at a time. In general, the number of CPUs is always restricted, and therefore only a few processes can progress at the same time. The choice of the process that can progress is left to an operating system component called the *scheduler*. Some operating systems allow only *nonpreemptive* processes, which means the scheduler is invoked only when a process voluntarily relinquishes the CPU. But processes of a multiuser system must be *preemptive*; the operating system tracks how long each process holds the CPU and periodically activates the scheduler.

Unix is a multiprocessing operating system with preemptive processes. Indeed, the process abstraction is really fundamental in all Unix systems. Even when no user is logged in and no application is running, several system processes monitor the peripheral devices.

In particular, several procesess listen at the system terminals waiting for user logins.

- When a user inputs a login name, the listening process runs a program that validates the user password. If the user identity is acknowledged, the process creates another process that runs a shell into which commnds are entered.

- When a graphical display is activated, one process runs the window manager, and each window on the display is usually run by a separate process. When a user creates a graphics shell, one proces runs the graphics windows, and a second process runs the shell into which the user can enter the commands.

- For each user command, the shell process creates another process that executes the corresponding program.

Unix-like operating system adopt a *process/kernel* model. Each process has the illusion that it's the only process on the machine and it has exclusive access to the operating system servies.

- Whenever a process make a *system call* (i.e., a request to the kernel), the hardware changes the privilidge mode from User Mode to Kernel Mode, the the process starts the execution of a kernel procedure with a strictly limited purpose.
- In this way, the operating system acts within the execution context of the process in order to satisfy its request.
- Whenever the request is fully satisfied, the kernel procedure forces the hardware to return to User Mode and the process continues its execution form the instruction following the system call.

#### 1.4.4 Kernel Architecture

As stated before, most Unix kernels are monolithic: each kernel layer is integrated into the whole kernel program and runs in Kernel Mode on behalf of the current process. In contrast, *microkernel* operating systems demand a very small set of functions from the kernel, generally including a few synchronization primitives, a simple scheduler, and an interprocess communication mechanism. Several system processes that run on top of the microkernel implement other operting system-layer functions, like memory allocators, device drivers, system call handlers, and so on.

Although academic research on operating systems is oriented toward microkernel, such operating systems are generally slower than monolithic ones, since the explicit message passing between the different layers of the operating system has a cost. However, microkernel operating systems might have some theretical advantages over monolithic ones.

- Microkernels force the system programmers to adopt a modularized approach, since any operating system layer is relatively independent program that must interact with the other layers through well-defined and clean software interfaces.
- Moreover, an existing microkernel operating system can be fairly easily ported to other architectures, since all hardware-dependent components are generally encapsulated in the microkernel code.
- Finally, microkernel operating system tend to make better use of random access memeory (RAM) than monolithic onces, since system processes that aren't implementing needed functionalities might be swapped out or destroyed.

Modules are a kernel feature that effectively achieves many of the theoretical advantages of microkernels without introducting performance penalties. A *module* is an object file whose code can be linked to (and unlinked from) the kernel at runtime. The object code usually consists of a set of functions that implements a filesystem, a deveice driver, or other features athe kernel's upper layer. The module, unlike the external layers of microkernel operating systems, does not run as a specific process. Instead, it is executed in Kernel Mode on behalf othe the current process, like any other statically linked kernel function.

The main advantages of using modules include:

- *Modularized approach*

    Since any module can be linked and unlinked at runtime, system programmers must introduce well-defined software interfaces to access the data structures handled by modules. This makes it easy to deveop new modules.

- *Platform independence*

    Even if it may rely on some specific hardware featues, a module doesn't depend on a fixed hardware platform. For example, a disk driver module that relies on the SCSI standard works as well on an IBM-compatible PC as it does on Compaq's Alpha.

- *Frugal main memory usage*

    A module can be linked to the running kernel when its functionality is required and unlinked when it is no longer useful. This mechanism also can be made transparent to the user, since linking and unlinking can be performed automatically by the kernel.

- *No performance penalty*

    Once linked in, the object code of a modue is equivalent to the object code of the statically linked kernel. Therefore, no explicit message passing is required when the functions of the module are invoked.

- - -

### References

1. Daniel P. Bovet、 Marco Cesati (2005-11), "Chapter 1: Understanding the Linux Kernel"
