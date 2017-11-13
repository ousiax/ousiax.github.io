---
layout: post
title: "Understanding The Linux Kernel 01"
date: 2017-11-12 14-20-08 +0800
categories: ['Linux']
tags: ['Linux', 'Kernel']
disqus_identifier: 214637421380564030329447675521549613702
---
- TOC
{:toc}

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

Linux tries to maintain a neat distinction between hardware-dependent and hardware-independent source code. To that end, both the *arch* and the *include* directories include subdirectories correspoding to the hardware platforms supported.

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

### 1.5 An Overview of the Unix Filesystem

#### 1.5.1 Files

A Unix file is an inforamtion container strutured as a sequence of bytes; the kernel does not intepret the contents of a file.

Many programming libraries implement higher-level abstractions, such as records structured into fields and record addressing based on keys. However, the programs in these libraries must rely on system calls offered by the kernel.

From the user's point of view, files are organized in a tree-structured name space.

![An example of a directory tree]({{ site.baseurl }}/assets/images/understanding-the-linux-kernel/an example of a directory tree.png)

- All the nodes of the tree, except the leaves, donote directory names.
- A directory node contians information about the files and directories just beneath it.
- A file or directory name consists of a sequence of arbitrary ASCII characters, with the exception of `/` and of the null character `\0`.
- Most filessytems place a limit on the length of a filename, typically no more than 255 characters.
- The directory corresponding to the root of the tree is called the *root directory*. By convention, its name is a slash (`/`).
- Names must be different within the same directory, but the same name may be used in different directories.

Unix associates a *current working directory* with each process; it belongs to the process execution context, and it identifies the directory currently used by the process.

In order to identify a specific file, the process uses a *pathname*, which consists of slashes alternating with a sequence of directory names that lead to the file.

- If the first item in the pathname is a slash, the pathname is said to be *absolute*, since its starting point is the root direcotry.
- Otherwise, if the first item is a directory name or filename, the pathname is said to be *relative*, since its starting point is the process's current directory.

While specifying filenames, the notations "." and ".." are also used. They denote the current working directory and its parent directory, respectively. If the current working directory is the root directory, "." and ".." coincide.

#### 1.5.2 Hard and Soft Links

A filename included in a directory is called a *file hard link*, or more simply a *link*.

The same file may have several links included in the same directory or in different ones, thus several filenames.

The Unix command:

```sh
$ ln f1 f2
```
 is used to create a new hard lin that has the pathname `f2` for a file identified by the pathname `f1`.

Hard links have two limitations:

- Users are not allowed to create hard links for directories. This might transform the directory tree into graph with cycles, thus making it impossible to locate a file according to its name.

- Links can be created only among files included in the same filesystem. This is a serious limitation since modern Unix systems may include several filesystems located on different disk and/or partions, and users my be unaware of the physical divisions between them.

In order to overcome these limitations, *soft links* (also called *symbolic links*) have been introduced. Symbolic links are short files that contains an arbitrary pathname of another file. The pathname may refer to any file located in any filesystem; it may even refer to a nonexistent file.

The Unix command:

```sh
$ ln -s f1 f2
```

create a new soft link with pathname `f2` that refers to pathname `f1`. When this command is executed, the filesystem creates a soft link and writes into it the `f1` pathname. It then inserts—in the proper directory—a new entry containing the last name of the `f2` pathname. In this way, any reference to `f2` can be translated automatically into a reference to `f1`.

#### 1.5.3 File Types

Unix files may have one of the following types:

- `-` Regular file
- `d` Directory
- `l` Symbolic link
- `b` Block-oriented device file
- `c` Character-oriented device file
- `p` Pipe and named pipe (also called FIFO)
- `s` Socket

#### 1.5.4 File Descriptor and Inode

Unix makes a clear distinction between a file and a file descriptor. With the exception of device and special files, each file consists of a sequence of characters. The file does not include any control information such as its length, or and End-Of-File (EOF) delimiter.

All information needed by the filesystem to handle a file is included in a data structure called an *inode*. Each file has its own inode, which the filesystem uses to indentify the file.

While filesystems and the kernel functions handling them can vary widely from on Unix system to antoher, they must always provide at least the following attributes, which are specified in the POSIX standard:

- File type
- Number of hard links associated with the file
- File length in bytes
- Device ID (i.e., an identifier of the device containing the file)
- Inode number that indentifies the file within the filesystem
- User ID of the file owner
- Group ID of the file
- Several timestamps that specify the inode status change time, the last access time, and the last modify time
- Access rights and file mode

#### 1.5.5 Access Rights and File Mode

The potential users of a file fall into three classes:
- The user who is the onwer of the file
- The users who belong to the same group as the file, not including the owner
- All remaining users (others)

There are three types of access rights, *Read*, *Write*, and *Execute*, for each of these three classes. Thus, the set of access rights associated with a file consists of nine different binary flags. Three additional flags, called *suid* (Set User ID), *sgid* (Set Group ID), and *sticky* define the file mode. These flags have the following meaning when applied to executable files:

- *suid*

    A process executing a file normally keeps the User ID (UID) of the process owner. However, if the executable file has the *suid* flag set, the process gets the UID of the file owner.

- *sgid*

    A process executing a file keeps the Group ID (GID) of the proces group. However, if the executable file has the *sgid* flag set, the process gets the ID of the file group.

-  *sticky*

    An executable file with the *sticky* flag set corresponds to a request to the kernel to keep the program in memory after its execution terminates.

When a file is created by a process, its owner ID is the UID of the process. Its owner group ID can be either the GID of the creator process or the GID of the parent directory, depending on the value of the `sgid` flag of the parent directory.

#### 1.5.6 File-Handling System Calls

When a user accesses the contents of either a regular file or a directory, he actually accesses some data stored in a hardware block device. In this sense, a filesystem is a user-level view of the physical organization of a hard disk partition. Since a process in User Mode cannot directly interact with the low-level hardware components, each actual file operation must be performed in Kernel Mode.

Therefore, the Unix operating system defines several system calls related to file handing. Whenever a process wants to perform some operation on a specific file, it uses the proper system call and passes the file pathname as a parameter.

##### 1.5.6.1 Opening a file

Processes can access only "opened" files. In order to open a file, the process invokes the system call:

```c
fd = open(path, flag, mode)
```

This system call creates an "open file" object and returns an identifier called *file descriptor*.

An open file object contians:

- Some file-handling data structures, like a pointer to the kernel buffer memory area where file data will be copied; an *offset* field that denotes the current position in the file from which the next operation will take place (the so-called *file pointer*); and so on.
- Some pointers to kernel functions that the process is enabled to invoke. The set of permitted functions depends on the value of the *flag* parameter.

In order to create a new file, the process may also invoke the `create()` system call, which is handled by the kernel excactly like `open()`.

##### 1.5.6.2 Accessing an opened file

Regular Unix files can be addressed either sequentially or randomly, while device files and named pipes are usually accessed sequenctially. In both kinds of access, the kernel stores the file pointer in the open file object, that is, the current position at which the next read or write operation will take place.

Sequential access is implicitly assumed: the `read()` and `write()` system calls always refer to the position of the current file pointer. In order to modify the value, a program must explicitly invoke the `lseek()` system call. When a file is opened, the kernel sets the file pointer to the position of the first byte in the file (offset 0).

1.5.6.3 Closing a file

When a process does not need to access the contents of a file anymore, it can invoke the system call:

```c
res = close(fd);
```

which releases the open file object corresponding to the file descriptor `fd`. When a process terminates, the kernel closes all its stil opened files.

1.5.6.4 Renaming and deleting a file

In order to rename or delete a file, a process does not need to open it. Indeed, such operations do not act on the contents of the affected file, but rather on the contents of one or more directories. For example, the system call:

```c
res = rename(oldpath, newpath);
```

changes the name of a file link, while the system call:

```c
res = unlink(pathname);
```

decrements the file link count and removes the corresponding directory entry. The file deleted only when the link count assumes the value 0.

### 1.6 An Overview of Unix Kernels

Unix kernels provide an execution environment in which applications may run. Therefore, the kernel must implement a set of services and corresponding interfaces. Applications use those interfaces and do not usually interact directly with hardware resources.

#### 1.6.1 The Process/Kernel Model

As already mentioned, a CPU can run either in User Mode or in Kernel Mode. Actually, some CPUs can have more than two execution states. For instance, the Intel 80x86 microprocessors have four different execution states. But all standard Unix kernels make use of only Kernel Mode and User Mode.

- When a program is executed in User Mode, it cannot directly access the kernel data structures or the kernel programs.

- When an application executes in Kernel Mode, however, these restrictions no longer apply.

- Each CPU model provides special instructions to switch from User Mode to Kernel Mode and vice versa.

- A program executes most of the time in User Mode and switchs to Kernel Mode only when requesting a service provided by the kernel.

- When the kernel has satisfied the program's request, it puts the program back in User Mode.

Processes are dynamic entities that usually have a limited life span within the system. The task of creating, eliminating, and sysnchronizing the existing processes is delegated to a group of rountines in the kernel.

The kernel itself is not a process but a process manager.

- The process/kernel model assumes that proceese that require a kernel service make use of specific programming constructs called *system calls*.

- Each system call sets up the group of parameters that identifies the process request and then executes the hardware-dependent CPU instruction to switch from User Mode to Kernel Mode.

Besides user processes, Unix systems include a few privileged processes called *kernel threads* with the following characteristics:

- They run in Kernel Mode in the kernel address space.
- They do not interact with users, and thus do not require terminal devices.
- They are usually created during system startup and remain alive unitl the system is shut down.

Notice how the process/kernel model is somewhat orthogonal to the CPU state: on a uniprocessor system, only one process is running at any time and it may run either in User or in Kernel Mode. If it runs in Kernel Mode, the processor is executing some kernel routine.

![Transitions between User and Kernel Mode]({{ site.baseurl }}/assets/images/understanding-the-linux-kernel/Transitions between User and Kernel Mode.png)

Unix kernels do much more than handle system calls; in fact, kernel routines can be activated in serveral ways:

- A process invokes a system call.

- The CPU executing the process signals an *exception*, which is some unusual condition such as an invalid instruction. The kernel handles the exception on behalf of the process that caused it.

- A peripheral device issues an *interrupt signal* to the CPU to notify it of an event such as a request for attention, a status change, or the completion of an I/O operation.

    Each interrupt signal is dealt by a kernel program called an *interrupt handler*. Since peripheral devices operate asynchronously with respect to the CPU, interrupts occur at unpredicatable times.

- A kernel thread is executed; since it runs in Kernel Mode, the corresponding program must be considered part of the kernel, albeit encapsualted in a process.

#### 1.6.2 Process Implementation

To let the kernel processes, each process is represented by a *process descriptor* that includes information about the current state of the process.

When the kernel stops the execution of a process, it saves the current contents of several processor registers in the process descriptor. These include:

- The program counter (PC) and stack pointer (SP) registers
- The general-purpose registers
- The floating point registers
- The processor control registers (Process Status Word) containing information about the CPU state.
- The memory management registers used to keep track of the RAM accessed by the process.

When the kernel decides to resume executing a process, it uses the proper process descriptor fields to load the CPU registers. Since the stored value of the program counter points to the instruction following the last instruction executed, the process resumes execution from where it was stopped.

When a process is not executing on the CPU, it is waiting for some event. Unix kernels distinguish many wait sates, which are usually implemented by queues of process descriptors; each (possible empty) queue corresponds to the set of processes waiting for a specific event.

#### 1.6.3 Reentrant Kernels

All Unix kernels are *reentrant*: this means that several processes may be executing in Kernel Mode at the same time. Of course, on uniprocessor systems only one process can progress, but many of them can be blocked in Kernel Mode waiting for the CPU or the completion of some I/O operation.

For instance, after issuing a read to a disk on behalf of some process, the kernel will let the disk controller handle it and will resume executing other processes. An interrupt notifies the kernel when the device has statified the read, so the former process can resume the execution.

- One way to provide reentrancy is to write functions so that they modify only local variables and do not alter global data structures. Such functions are called *reentrant functions*.
- But a reentrant kernel is not limited just to such reentrant functions (although that is how some real-time kernels are implemented). Instead, the kernel can include nonreentrant functions and use locking mechanisms to ensure that only one process can execute a nonreentrant function at a time.
- Every process in the Kernel Mode acts on its own set of memory locations and conannot interface with others.

If a hardware interrupt occurs, a reentrant kernel is able to suspend the current running process even if that process is in Kernel Mode. This capability is very important, since it imporves the throughput of the device controllers that issue interrupts. Once a device has issued an interrupt, it waits until the CPU acknowledges it. If the kernel is able to answer quickly, the device controller will be able to perform other tasks while the CPU handles the interrupt.

A *kernel control path* denotes the sequence of instructions executed by the kernel to handle a system call, an exception, or an interrupt.

In the simplest case , the CPU executes a kernel control path from the first instruction to the last. When one of the following events occurs, however, the CPU interleaves the kernel control paths:

- A process executing in User Mode invokes a system call and the corresponding kernel control path verifies that the request cannot be satisfied immediately; it then invokes the scheduler to select a new process tor un. As a result, a  process switch occurs. The first kernel control path is left unfinished and the CPU resumes the execution of some other kernel control path. In this case, the two control paths are executed on behalf of two different processes.

- The CPU detects an exception—for example, an access to a page not present in RAM—while running a kernel control path. The first control path is suspended, and the CPU starts the execution of a suitable procedure. In our example, this type of procedure could allocate a new page for the process and read its contents from disk. When the procedure terminates, the first control path can be resumed. In this case, the two control paths are executed on behalf of the same process.

- A hardware interrupt occurs while the CPU is running in kernel control path with the interrupts enabled. The first kernel control path is left unfinished and the CPU starts processing another kernel control path to hanle the interrupt. The first kernel path resumes when the interrupt handler terminates. In this case the two kernel control paths run in the execution context of the same process and the total elapsed system time is accounted to it. However, the interrupt handler doesn't necessarily operate on behalf of the process.

- - -

### References

1. Daniel P. Bovet、 Marco Cesati (2005-11), "Chapter 1: Understanding the Linux Kernel"
1. What's program counter, [http://whatis.techtarget.com/definition/program-counter](http://whatis.techtarget.com/definition/program-counter)
1. Protection ring, [https://en.wikipedia.org/wiki/Protection_ring](https://en.wikipedia.org/wiki/Protection_ring)
1. Call stack, [https://en.wikipedia.org/wiki/Call_stack#STACK-POINTER](https://en.wikipedia.org/wiki/Call_stack#STACK-POINTER)
