---
layout: post
title: "Goroutines and Threads in Go Language"
date: 2017-06-18 11-57-35 +0800
categories: ['Go',]
tags: ['Go', 'Goroutine', ]
disqus_identifier: 131456394492759551109904219199863894860
---

- TOC
{:toc}

- - -

### Growable Stacks

Each OS thread has a fixed-size block of memory (often as large as **2MB**) for its *stack*, the work area where it saves the local variables of function calls that are in progress or temporarily suspended while another function is called. This fixed-size stack is simultaneously too much and too little. A 2MB stack would be a huge waste of memory for a litte goroutine, such as one that merely waits for a **WaitGroup** then closes a channel. It's uncommon for a Go program to create hundreds of thousands of goroutines at one time, which would be impossible with stacks this large. Yet despite their size, fixed-size stacks are not always big enough for the most complex and deeply recursive of functions. Channing the fixed size can improve space efficiency and allow more threads to be created, or it can enable more deeply recursive functions, but it cannot do both.

In contrast, a goroutine starts life with a small stack, typically **2KB**. A goroutine's staack, like the stack of an OS thread, holds the local variables of active and suspended function calls, but unlike an OS thread, a goroutine's stack is not fixed; it grows and shrinks as needed. The size limit for a goroutine stack may be as much as **1GB**, orders of magnitude larger than a typical fixed-size thread stack, though of course few goroutines use that much.


### Goroutine Scheduling

OS threads are scheduled by the OS kernel. Every few milliseconds, a hardware timer interupts the processor, which causes a kernel function called the *scheduler* to be invoked. This function suspends the currently executing thread and saves it registers in memory, looks over the list of thread and decides which one should run next, restores the thread's registers from memory, then resumes the execution of that thread. Because OS threads are scheduled by the kernel, passing control from one thread to another requires a full ***context switch***, that is, saveing the state of one user thread to memory, restoring the state of another, and updating the scheduler's data structures. This operation is slow, due to its poor locality and the number of memory accesses required, and has historically only gotten worse as the number of CPU cycles required to access memory has increased.

The Go runtime contains its own scheduler that uses a technique known as ***m:n scheduling***, because it multiplexes (or schedules) ***m*** goroutines on ***n*** OS threads. The job of the Go scheduler is analogous to that of the kernel scheduler, but it concerned only with the goroutines of a single Go program.

Unlike the operating system's thread scheduler, the Go scheduler is not invoked periodically by a hardware timer, but implicitly by certain Go language constructs. For example, when a goroutine calls **time.Sleep** or blocks in a channel or mutex operation, the scheduler puts it to sleep and runs another goroutine until it is time to wake the first one up. Because it doesn't need a swith to kernel context, rescheduling a goroutine is much cheeper than rescheduling a thread.

### GOMAXPROCS

The Go scheduler uses a parameter called **GOMAXPROCS** to determine how many OS threads may be actively executing Go code simultaneously. Its default value is the number of CPUs on the machine, so on a machine with 8 CPUs, the scheduler will schedule Go code on up to 8 OS threads at once. (**GOMAXPROCS** is the ***n** in ***m:n*** scheduling.) Goroutines that are sleeping or blocked in a communication do not need a thread at all. Goroutines that are blocked in I/O or other system calls or are calling non-Go functions, do need an OS thread, but **GOMAXPROCS** need not account for them.

You can explicitly control this parameter using the **GOMAXPROCS** environment variable or the **runtime.GOMAXPROCS** function.

### Goroutines Have No Identity

In most operating systems and programming languages that support multithreading, the curent thread has a distinct identity that can be easily obtained as an ordinary value, typically an integer or pointer. This make it easy to build an abstraction called ***thread-local storage***, which is essentially a global map keyed by thread identity, so that each thread thread can store and rewrite values independent of other threads.

Gorutines thas no notion of identity that is accessible to the programmer. This is by design, since thread-local storeage tends to be abused.
