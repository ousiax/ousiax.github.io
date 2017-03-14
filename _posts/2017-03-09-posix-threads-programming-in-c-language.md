---
layout: post
title: "POSIX Threads Programming in C Language"
date: 2017-03-09 16-29-29 +0800
categories: ['C']
tags: ['C']
disqus_identifier: 21493735310366146726844093771521945239
---
* TOC
{:toc}

- - -

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

#### 5. Synchronization

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

### POSIX Threads Programming

#### 1. What is a Thread?

- Technically, a thread is defined as an independent stream ofinstructions that can be scheduled to run as such by the operating system.

- To the software developer, the concept of a "procedure" that runs independently from its main program may best desribe a thread.

- To go one step further, imagine a main program (a.out) that contains a number of procedures. Then imagine all of these procedures being able to be scheduled to run simultaneously and/or independently by the operating system. That would describe a "multi-threaded" program.

- Before understanding a thread, one first needs to understand a UNIX process. A process is created by the operating system, and requires a fair amout of "overhead". Processes contain information about program resources and program execution state, including:

    - Process ID, process group ID, and group ID
    - Environment
    - Working directory
    - Program instructions
    - Registers
    - Stack
    - Heap
    - File descriptors
    - Signal actions
    - Shared libraries
    - Inter-process communication tools (such as message queues, pipes, semaphores, or shared memeory).

    <img style="max-width: 50%; float: left;" src="https://computing.llnl.gov/tutorials/pthreads/images/process.gif" alt="UNIX PROCESS" title="UNIX PROCESS" />
    <img style="max-width: 50%; float: left; clear: right;" src="https://computing.llnl.gov/tutorials/pthreads/images/thread.gif" alt="THREADS WITHIN A UNIX PROCESS" title="THREADS WITHIN A UNIX PROCESS" />

- Threads use and exist within these process reources, yet are able to be scheduled by the operating system and run as independent entities largely because they duplicate only the bare essential resources that enable them to exist as executable code.

- This independent flow of control is accomplished because a thread maintains its own:

    - Stack Pointer
    - Registers
    - Scheduling properties (such as policy or priority)
    - Set of pending and blocked signals
    - Thread specific data

- So, in summary, in the UNIX environment a thread:

    - Exists within a process and uses the process resources
    - Has its own independent flow of control as long as its parent process exists and the OS supports it
    - Duplicates only the essential resources it needs to be independently schedulable
    - May share the process resources with other threads that act equally independently (and dependently)
    - Dies if the parent process dies - or something similar
    - Is "lightweight" because most of the overhead has already been accomplished through the creation of it process

- Because threads within the same process share resources:

    - Changes made by one thread to shared system resources (such as closing a file) will be seen by all other threads
    - Two pointers having the same value point to the same data
    - Reading and writing to the same memory location is possible, and therefore requires explicit synchronization by the programmer

#### 2. What are Pthreads

Pthreads are defined as a set of C language programming types and procedure calls, implemented with a **pthread.h** header/include file and a thread library - through this library may be part of another library, such as **libc**, in some implementations.

#### 3. The Pthread API

The original Pthreads API was defined in the ANSI/IEEE POSIX 1003.1 - 1995 standard. The POSIX standard has continued to evolve and undergo revisions, including the Pthreads specification.

The subroutines which comprise the Pthreads API can be informally grouped into four major gorups:

1. **Thread management**: Routines that work directory on threads - creating, detaching, joining, etc. They also include functions to set/query thread attributes (joinable, sheduling etc.)

1. **Mutexes**: Routines that deal with synchronization, called a "mutext", which is an abbreviation for "mutual exclusion". Mutex functions provide for creating, destroying, locking and unlocking mutexes. These are supplemented by mutex attribute functions that set or modify attributes associated with mutexes.

1. **Condition variables**: Routines that address communications between threads that share a mutex. Based upon programmer specified conditions. This group includes functions to create, destory, wait and signal based upon specified variable values. Functions to set/query condition variable attributes are also included.

1. **Synchronization**: Routines that manage read/write locks and barries.

All identifiers in the threads library begin with **pthread_**.

Routine Prefix      | Functional Group
:--------------     | :----------------
pthread\_           | Threads themselves and miscellaneous subroutines
pthread\_attr\_     | Thread attributes objects
pthread\_mutext\_   | Mutexes
pthread\_mutexattr_ | Mutex attributes objects
pthread\_cond\_     | Condition variables
pthread\_condattr\_ | Condition attributes objects
pthread\_key\_      | Thread-specific data keys
pthread\_rwlock\_   | Read/write locks
pthread\_barrier\_  | Synchronization barriers

#### 4. Creating and Terminating Threads

- **Routines**

```c
pthread_create (thread, attr, start_routine, arg)
pthread_exit (status)
pthread_cancel (thread)
pthread_attr_init (attr)
pthread_attr_destroy(attr);
```
- **Creating Threads**

    Initially, your `main()` program comprises a single, default thread. All other threads must be explicitly created by the programmer.

    `pthread_create` creates a new thread and makes it executalbe. This routine can be called any number of times anywhere within your code.

    The `pthread_create()` routine permits the programmer to pass one argument to the thread start routine. For cases where multiple arguments must be passed, this limitation is easily overcome by creating a structure which contains all of the arguments, and then passing a pointer to that structure in the `pthread_create()` routine. All arguments must be passed by reference and cast to `(void *)`.

    Once created, threads are peers, and may create other threads. There is no implied hierarchy or dependency between threads.

    ![](https://computing.llnl.gov/tutorials/pthreads/images/peerThreads.gif)

- **Terminating Threads** & `pthread_exit`

    There are several ways in which a thread may be terminated:
    - The thread returns normally from its starting routine. Its work is done.
    - The thread makes a call to the `pthread_exit` subroutine - whether its works is done or not.
    - The thread is canceled by another thread via the `pthread_cancel` routine
    - The entire process is terminated due to makeing a call to either the `exec()` or `exit()`
    - If `main()` finishes first, without calling `pthread_exit` explicitly itself.
    - Cleanup: the `pthread_exit()` routine does not close files; any files opened inside the thread will remain open after the thread is terminated.
    - **Discussion on calling** `pthread_exit()` from main()

        - There is definite problem if `main()` finishes before the threads it spawned if you don't call `pthread_exit` explicitly. All of the threads it created will terminate because `main()` is done and no longer exists to support the threads.

        - By having `main()` explicitly call **pthread_exit()** as the last thing it does, `main()` will block and be kept alive to support the threads it created until they are done.

    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <pthread.h>
    #include <unistd.h>
    
    #define NUM_THREADS     2
    
    static void *func(void *ch);
    
    int main(void)
    {
        char ch[NUM_THREADS] = { '*', '-' };
        pthread_t tids[NUM_THREADS];
        int i;
        int rc;
    
        for(i = 0; i < NUM_THREADS; ++i) {
            rc = pthread_create(&tids[i], NULL, func, (void *)&ch[i]);
    
            if(rc) {
                printf("ERROR; return code from pthread_create() is %d\n", rc);
                exit(EXIT_FAILURE);
            }
        }
    
        pthread_exit(NULL);
        exit(EXIT_SUCCESS);
    }
    
    static void *func(void *ch)
    {
        while(1) {
            usleep(100);
            printf("%c", *(char *)ch);
            fflush(stdout);
        }
    }
    ```

#### 5. Joing and Detaching Threads

- **Routines**

```c
pthread_join (threadid, status)
pthread_detach (threadid)
pthread_attr_setdetachstate (attr, detachstate)
pthread_attr_getdetachstate (attr, detachstate)
```

- **Joining**

    - "Joining" is one way to accomplish synchronization between threads.

        ![](https://computing.llnl.gov/tutorials/pthreads/images/joining.gif)

    - The **pthread_join()** subroutine blocks the calling thread until the specified **threadid** thread terminates.

    - The programmer is able to obtain the target thread's termination return **status** if it was specified in the target thread's call to **pthread_exit()**.

    - A joining thread can match one **pthread_join()** call. It is a logical error to attempt multiple joins on the same thread.

- **Joinable or Not?**

    - When a thread is created, one of its attributes defines whether it is joinable or detached. Only threads that are created as joinable can be joined. If a thread is created as detached, it can never be joined.

    - The final draft of the POSIX standard specifies that threads should be created as joinable.

    - To explicitly create a thread as joinable or detached, the **attr** argument in the **pthread_create()** routine is used. The typical 4 steps process is :

        1. Decalare a pthread attribute variable of the **pthread_attr_t** data type.
        1. Initialize the attribute variable with **pthread_attr_init()**
        1. Set the attribute detached status with **pthread_attr_setdetachstate()**
        1. When done, free library resources used by the attribute with **pthread_attr_destory()**

- **Detaching**

    - The **pthread_detach()** routine can be used to explicitly detach even though it was created as joinable.

    - There is no converse routine.

- **Recommendations**

    - If a thread requires joining, consider explicitly creating it as joinable. This provides portablility as not all implementations may create threads as joinable by default.

    - If you know in advance that a thread will never need to join with another thread, consider creating it in a detached state. Some system resources may be able to be freed.

    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <pthread.h>
    #include <unistd.h>
    
    #define NUM_THREADS     2
    
    static void *func(void *ch);
    
    int main(void)
    {
        char ch[NUM_THREADS] = { '*', '-' };
        pthread_t tids[NUM_THREADS];
        pthread_attr_t attr;
        int i;
        int rc;
        pthread_attr_init(&attr);
        pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    
        for(i = 0; i < NUM_THREADS; ++i) {
            rc = pthread_create(&tids[i], &attr, func, (void *)&ch[i]);
    
            if(rc) {
                printf("ERROR; return code from pthread_create() is %d\n", rc);
                exit(EXIT_FAILURE);
            }
        }
    
        pthread_attr_destroy(&attr);
    
        for(i = 0; i < NUM_THREADS; ++i) {
            rc = pthread_join(tids[i], NULL);
    
            if(rc) {
                printf("ERROR; return code from pthread_join() is %d\n", rc);
                exit(EXIT_FAILURE);
            }
        }
    
        // pthread_exit(NULL);
        exit(EXIT_SUCCESS);
    }
    
    static void *func(void *ch)
    {
        while(1) {
            usleep(100);
            printf("%c", *(char *)ch);
            fflush(stdout);
        }
    }
    ```

#### 6. Mutex Variables

- Mutex is an abbreviation for "mutual exclusion". Mutex variables are one of the primary means of implementing thread synchronization and for protecting shared data when multiple writes occur.

- A mutex variable act like a "lock" protecting access to a shared data resource. The basic concept of a mutex as used in Phtreads that only one thread can lock (or own) a mutex variable at any given time. Thus, even if several threads try to lock a mutex only one thread will be successful. On other thread can own that mutex until the owning thread unclocks that mutex. Threads must "take turns" accessing protected data.

- Mutexs can be used to prevent "race" conditions.

    A program that depends on threads working in a certain sequence to complete normally. Race Conditions happen when mutexes are used improperly, or not at all.

- Very often the action performed by a thread owning a mutex is the updating of global variables. This is a safe way to ensuere that when several threads update the same variable, the final value is the same as what it would be if only one thread performed the update. The vairables being updated belong to a "critical section".

- A typical sequence in the use of a mutex is as follows:

    - Create and initialize a mutex variable
    - Several threads attempt to lock the mutex
    - Only one succeeds and that thread owns the mutex
    - The owner unlocks the mutex
    - Another thread acquires the mutex and repeats the process
    - Finally the mutex is destroyed

- When several threads compete for a mutex, the loser block aht the call - an unblocking call is available with "trylock" instead of the "lock" call.

- When more than one thread is waiting for a locked mutex, unless thread priority scheduling is used, which thread will be granted the lock will be left to the native system scheduler and may appear to be more or less random.

- **Routines**

    ```c
    pthread_mutex_init (mutex,attr)
    
    pthread_mutex_destroy (mutex)
    
    pthread_mutexattr_init (attr)
    
    pthread_mutexattr_destroy (attr) 
    
    pthread_mutex_lock (mutex)
    
    pthread_mutex_trylock (mutex)
    
    pthread_mutex_unlock (mutex) 
    ```

    - Mutex variables must be decalre with type **pthread_mutex_t**, and must be initialized before they can be used.

        1. Statically, when it is declared.

            ```c
            pthread_mutex_t mymutex = PTHREAD_MUTEX_INITIALIZER;
            ```

        2. Dynamically, with the **pthread_mutex_init()** routine.

    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <pthread.h>
    #include <unistd.h>
    
    #define NUM_THREADS     1000
    
    static void *add(void *num);
    
    pthread_mutex_t mutex;
    
    int main(int argc, char *argv[])
    {
        pthread_t tids[NUM_THREADS];
        int t;
        int num = 0;
        pthread_mutex_init(&mutex, NULL);
        pthread_attr_t attr;
        pthread_attr_init(&attr);
        pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
    
        for(t = 0; t < NUM_THREADS; t++) {
            pthread_create(&tids[t], &attr, add, &num);
        }
    
        for(t = 0; t < NUM_THREADS; t++) {
            pthread_join(tids[t], NULL);
        }
    
        pthread_attr_destroy(&attr);
        pthread_mutex_destroy(&mutex);
        printf("\n");
        exit(EXIT_SUCCESS);
    }
    
    static void *add(void *num)
    {
        int n;
        pthread_mutex_lock(&mutex);
        n = *(int *)num;
        usleep(100);
        *(int *)num = n + 1;
        printf("%d ", *(int *)num);
        pthread_mutex_unlock(&mutex);
        pthread_exit(NULL);
    }
    ``` 

#### 7. Condition Variables

- Condition variables provide yet another way for threads to synchronize. While mutexes implement synchronization by controlling thread access data, condition variables allow threads to synchronize based upon the actual value of data.

- Without condition variables, the programmer would need to have threads continually polling (possibly in a critical section), to check if the condition is met. This can be very resource consuming since the thread would be continuously busy in this activity. A condition variable is a way to achieve the same goal without polling.

- A condition variable is always used in conjunction with a mutex lock.

- A representative sequence for using condition variable is shown below.

    <table width="90%" cellspacing="0" cellpadding="5" border="1">
        <tbody>
            <tr valign="top">
                <td colspan="2" bgcolor="#FOF5FE"><span class="heading3">Main Thread</span>
                    <ul>
                        <li>Declare and initialize global data/variables which require synchronization (such as "count")
                        </li>
                        <li>Declare and initialize a condition variable object
                        </li>
                        <li>Declare and initialize an associated mutex
                        </li>
                        <li>Create threads A and B to do work
                        </li>
                    </ul>
                </td>
            </tr>
            <tr valign="top">
                <td width="50%">
                    <strong>Thread A</strong>
                    <ul>
                        <li>Do work up to the point where a certain condition must occur (such as "count" must reach a specified value)
                        </li>
                        <li>Lock associated mutex and check value of a global variable
                        </li>
                        <li>Call
                            <tt>pthread_cond_wait()</tt> to perform a blocking wait for signal from Thread-B. Note that a call to
                            <tt>pthread_cond_wait()</tt> automatically and atomically unlocks the associated mutex variable so that it can be used by Thread-B.
                        </li>
                        <li>When signalled, wake up. Mutex is automatically and atomically locked.
                        </li>
                        <li>Explicitly unlock mutex
                        </li>
                        <li>Continue
                        </li>
                    </ul>
                </td>
                <td width="50%">
                    <strong>Thread B</strong>
                    <ul>
                        <li>Do work
                        </li>
                        <li>Lock associated mutex
                        </li>
                        <li>Change the value of the global variable that Thread-A is waiting upon.
                        </li>
                        <li>Check value of the global Thread-A wait variable. If it fulfills the desired condition, signal Thread-A.
                        </li>
                        <li>Unlock mutex.
                        </li>
                        <li>Continue
                        </li>
                    </ul>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2" bgcolor="#FOF5FE">
                    <span class="heading3">Main Thread</span>
                    <ul>
                        Join / Continue
                    </ul>
                </td>
            </tr>
        </tbody>
    </table>

- **Routines**

    ```c
    pthread_cond_init (condition,attr)
    
    pthread_cond_destroy (condition)
    
    pthread_condattr_init (attr)
    
    pthread_condattr_destroy (attr) 
    
    pthread_cond_wait (condition,mutex)
    
    pthread_cond_signal (condition)
    
    pthread_cond_broadcast (condition) 
    
    ```

    - Condition variables must be decalred with type **pthread_cond_t**, and must be intialized before they can be used. There are two ways to initialize a condition variable:

        1. Statically, when it is declared.

            ```c
            pthread_cond_t myconvar = PTHREAD_COND_INITIALIZER;
            ```

        1. Dynamically, with the **pthread_cond_init()** routine. The ID of the created condition variable is returned to the calling thread through the *condition* parameter. This method permits setting condition variable object attributes, *attr*.

    - **pthread_cond_wait()** blocks the calling thread until the specified *condition* is signalled. This routine should be called while *mutex* is locked, and it will automatically release the mutex while it waits. After signal is received and thread is awakened, *mutex* will be automatically locked for use by the thread. The programmer is the responsible for unlocking *mutex* when the thread is finished it.

        **Recommendation**: Using a WHILE loop instead of an IF statement to check the waited for condition can help deal with several potential problems, such as:
        - If several threads are wating for the same wake up signal, they will take turns acquiring the mutex, and any one of them can then modify the condition they all waited for.
        - If the thread received the signal in error due to a program bug.
        - The Pthreads library is permitted to issue spurious wake ups to a waiting thread without violating the standard.

    - The **pthread_cond_signal()** routine is used to signal (or wake up) another thread which is waiting on the condition variable. It should be called after *mutex* is locked, and must unlock *mutex* in order for *pthread_cond_wait()** routine to complete.

    - The **pthread_cond_broadcast()** routine should be used instead of **phtread_cond_signal** if more than one thread is in a blocking wait state.

    - It is a logical error to call **pthread_cond_wait()** before calling **pthread_cond_wait()**.

        Proper locking and unlocking of the associate mutex variable is essential when using these routines. For example:
        - Failing to lock the mutex before calling **pthread_cond_wait()** may cause it NOT to block.
        - Failing to unclok the mutex after calling **phtread_cond_signal()** may not allow a matching **pthread_cond_wait()** routine to complete (it will remain blocked).

    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <pthread.h>
    #include <unistd.h>
    
    #define INCR_TIMES      10
    #define LIMIT           8
    
    typedef struct {
        pthread_mutex_t mut;
        pthread_cond_t  cv;
        int count;
    } data;
    
    static void *incr(void *d);
    static void *watch(void *d);
    
    int main(int argc, char *argv[])
    {
        pthread_t in;
        pthread_t wt;
        pthread_attr_t attr;
        data d;
        d.count = 0;
        pthread_mutex_init(&d.mut, NULL);
        pthread_cond_init(&d.cv, NULL);
        pthread_attr_init(&attr);
        pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
        pthread_create(&in, & attr, incr, &d);
        pthread_create(&wt, & attr, watch, &d);
        pthread_join(in, NULL);
        pthread_join(wt, NULL);
        pthread_attr_destroy(&attr);
        exit(EXIT_SUCCESS);
    }
    
    static void *incr(void *d)
    {
        data *p = (data *)d;
        int i;
    
        for(i = 0; i < INCR_TIMES; i++) {
            usleep(500000);
            pthread_mutex_lock(&p->mut);
            p->count = p->count + 1;
    
            if(p->count == LIMIT) {
                pthread_cond_signal(&p->cv);
                printf("INCR.SIGNAL: %d\n", p->count);
            } else {
                printf("INCR: %d\n", p->count);
            }
    
            pthread_mutex_unlock(&p->mut);
        }
    
        pthread_exit(NULL);
    }
    
    static void *watch(void *d)
    {
        data *p = (data *)d;
        pthread_mutex_lock(&p->mut);
    
        while(p->count < LIMIT) {
            pthread_cond_wait(&p->cv, &p->mut);
            printf("WATCH: %d\n", p->count);
        }
    
        pthread_mutex_unlock(&p->mut);
        pthread_exit(NULL);
    }
    ```

* * *

### References

1. [Introduction to Parallel Computing](https://computing.llnl.gov/tutorials/parallel_comp/)
1. [POSIX Threads Programming](https://computing.llnl.gov/tutorials/pthreads/)
1. [Multithreading in C, POSIX style](http://softpixel.com/~cwright/programming/threads/threads.c.php)
