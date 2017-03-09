---
layout: post
title: "POSIX Threads Programming in C Language"
date: 2017-03-09 16-29-29 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 21493735310366146726844093771521945239
---

### What is Parallel Computing ?

#### 1. Serial Computing

Traditionally, software has been written for ***serial*** computing:

- A problem is broken into a discrete series of instructions
- Instructions are executed sequentially one after another
- Executed on a single processor
- Only one instruction may execute at any moment in time

![Serial Computing](https://computing.llnl.gov/tutorials/parallel_comp/images/serialProblem.gif)

#### 2. Parallel Computing

In the simplest sense, ***parallel computing*** is the simultaneous use of multiple compute resources to solve a computational problem:

- A problem is broken into discrete parts that can be solved concurrently
- Each part is further broken down to a series of instructions
- Instructions from each part execute simultaneously on different processors
- An overall control/coordination mechanism is employed

![Parallel Computing](https://computing.llnl.gov/tutorials/parallel_comp/images/parallelProblem.gif)

- The computional problem should be able to:

    - Be broken apart into discrete pieces of work that can be solved simultaneously
    - Execute multiple program instructions at any moment in time
    - Be solved in less time with multiple compute resources than with a single compute resource

- The compute resources are typically:

    - A single computer with multiple processors/cores
    - An arbitrary number of such computers connected by a network

#### 3. Parallel Computers

Virtually all stand-alone computers today are parallel from a hardware perspective:

- Multiple functional units (L1 cache, L2 cache, branch, prefetch, decode, floating-point, graphics processing (GPU), integer, etc.)
- Multiple execution units/cores
- Multiple hardware threads

![IBM BG/Q Compute Chip with 18 cores (PU) and 16 L2 Cache units (L2) ](https://computing.llnl.gov/tutorials/parallel_comp/images/bgqComputeChip.jpg)

Networks connect multiple stand-alone computers (nodes) to make larger parallel computer clusters.

![Parallel Computer Clusters](https://computing.llnl.gov/tutorials/parallel_comp/images/nodesNetwork.gif)

- For example, the schematic below shows a typical LLNL parallel computer cluster:

    - Each compute node is a multi-processor parallel computer in itself
    - Multiple compute nodes are networked together with an Infiniband network
    - Special purpos node, also multi-processors, are used for other purposes

![](https://computing.llnl.gov/tutorials/parallel_comp/images/parallelComputer1.gif)

#### 4. von Neumann Architecture

Named after the Hungarian mathematician/genius John von Neumann who first authored the general requirements for an electronic computer in his 1945 papers.

Also know as "stored-program computer" - both program instructions and data are kept in electronic memory. Differs from earlier computers which were programmed through "hard writing".

Since then, virtually all computers have followed the basic design:

- Comprised of four main components:
    - Memory
    - Control Unit
    - Arithmetic Logic Unit
    - Input/Output

- Read/write, random access memory is used to store both program instructions and data.

    - Program instructions are coded data which tell the computer to do something
    - Data is simply informaiton to be used by the program

- Control unit fetches instructions/data from memory, decodes the instructions and then ***sequentially*** coordinates operations to accomplish the programmed task.
- Arithmetic Unit performs basic arithmetic operations.
- Input/Output is the interface to the human operator

- So what? Who cares?

    - Well, parallel computers still follow this basic design, just multiplied in units. the basic, fundamental architecture remains the same.

#### 6. Synchronization

- Managing the sequence of work and the tasks performing it is a critical design consideration for most parallel programs.

- Can be a significant factor in program performance (or lack of it)

- Often requires "serialization" of segments of the program.

**Types of Synchronization**

- **Barrier**

    - Usually implies that all taks are involved
    - Each task performs its work until it reaches the barriers. It then stops, or "blocks".
    - When the last task reaches the barrier, all tasks are synchronized.
    - What happens from here varies. Often, a serial section of work must be done. In other cases, the tasks are automatically released to continue their work.

- **Lock / semaphore**

    - Can involve any number of tasks
    - Typically used to serialize (protect) access to global data or a section of code. Only one task at a time may use (own) the lock / semaphore / flag.
    - The first task to acquire the lock "sets" it. This task can then safely (serially) access the protected data or code.
    - Other tasks can attempt to acquire the lock but must wait until the task that owns the lock releases it.
    - Can be blocking or non-blocking

- **Synchronous communication operations**

    - Involves only those tasks executing a communication operation
    - When a task performs a communication operation, some form of coordination is required with the other task(s) participating in the communication. For example, before a task can perform a send operation, it must first receive an acknowledgment from the receiving task that it is OK to send.

* * *

##### References

1. [https://computing.llnl.gov/tutorials/parallel_comp/](https://computing.llnl.gov/tutorials/parallel_comp/)
1. [https://computing.llnl.gov/tutorials/pthreads/](https://computing.llnl.gov/tutorials/pthreads/)
