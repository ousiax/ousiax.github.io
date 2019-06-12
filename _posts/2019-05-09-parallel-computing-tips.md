---
layout: post
title: 并行计算-笔记
date: 2019-05-09 17:27:03 +0800
categories: ['programming']
tags: ['programming']
---

```none
CPU Cache
  指令缓存 instruction cache
  数据缓存 data cache
    多级缓存 L1 L2 L3 L4
  旁路转换缓冲 TLB (translation lookside buffer, part of MMU)
缓存记录 cache entry
  缓存线 cache line : 固定大小，数据拷贝，内存地址(memory location, tag), 标志(flag, invalid bit, dirty bit)
缓存策略
  替换策略: 最近最少使用(LRU)
  写策略: 写通过(write-through), 回写(write-back), 缓存一致性协议, DMA, multi-core
缓存性能
  CPU 和 内存之前通过 Cache 架起桥梁，消除鸿沟(gap)
  CPU 在缓存未命中而访问内存并创建缓存线的等待状态称为闲置(Stall)
  为消除CPU的闲置(keep cpu busy),引入了乱序执行(out-of-order execution), 超线程(hyper-threading, HT)技术
缓存未命中 cache miss
  读 miss：取指令，取数据
  写 miss：队列 store buffer
内存管理单元 MMU
  虚拟内存 virtual memory
  virtual address To physical address
  TLB (translation lookside buffer)
  page table, segment table
缓存一致性协议
  MESI: Modified, Exclusive, Shared, Invalid
  Message:
    Read
    Read Response
    Invalidate
    Invlaidate Acknowledge
    Read Invalidate
    Writeback
  CPU 闲置 Stall
    Memory Barriers
    Happend-before
    Memory-misordering
    Store Buffer
      Store Forwarding
    Invalidate Queue

硬件同步原语 Hardware synchronization primitives
  Compare and swap (CAS)
    atomic test-and-set operation / atomic read-modify-write sequence
    On Intel processors, compare-and-swap is implemented by the cmpxchg family of instructions.
    A CAS operation includes three operands -- a memory location (V),
      the expected old value (A), and a new value (B).
    CAS effectively says "I think location V should have the value A; if it does, put B in it,
      otherwise, don't change it but tell me what value is there now.
  

无锁编程 lockless programming
  原子操作 atomic operation
    RMW(read-modify-write)
      _InterlockedIncrement on Win32
    CAS(compare-and-swap)
      _InterlockedCompareExchange on Win32
  Memory Ordering
    compiler reordering / processor reordering
    内存屏障/栏栅 memory fence/barrier

锁 lock
  自旋锁 spinlock

锁的粒度
  lock overhead: the extra resources for using locks, like the memory space allocated for locks, the CPU time to initialize and destroy locks, and the time for acquiring or releasing locks. The more locks a program uses, the more overhead associated with the usage;
  lock contention: this occurs whenever one process or thread attempts to acquire a lock held by another process or thread. The more fine-grained the available locks, the less likely one process/thread will request a lock held by the other. (For example, locking a row rather than the entire table, or locking a cell rather than the entire row.);
  deadlock: the situation when each of at least two tasks is waiting for a lock that the other task holds. Unless something is done, the two tasks will wait forever.




用户模式
内核模式

活锁
死锁

时间片

睡眠 0 1 -1

Yield

原子操作

Interlocked
Volatile

Memory fences / Memory barrier

自旋锁 SpinLock
  忙等 busy waiting

事件 Event
  AutoResetEvent
  ManualResetEvent 惊群
信号量 Semaphore

互斥锁 Mutex
  递归锁 Recursion
  线程所有权 Thread Ownership

读写锁 ReadWritLock

混合锁 Hybrid Lock
  用户模式 + 内核模式

异步 IO



A thread waiting on a construct might block forever if the thread currently holding the construct
never releases it. If the construct is a user-mode construct, the thread is running on a CPU forever, and
we call this a livelock. If the construct is a kernel-mode construct, the thread is blocked forever, and we
call this a deadlock. Both of these are bad, but of the two, a deadlock is always preferable to a livelock,
because a livelock wastes both CPU time and memory (the thread’s stack, etc.), while a deadlock wastes
only memory.

Context SWitch

Kernel Mode / User Mode

Volatile / Memory fences

Volatile’s Read method performs an atomic read operation, and its Write method performs an
atomic write operation. That is, each method performs either an atomic read operation or an atomic
write operation. 

Interlocked

atomic read and write operation

CPU
Thread / logic CPU

Single-CPU
Hyperthreaded CPU
  let only one thread run at a time
time-slice

SpinLock
SpinWait()
  executes a special CPU instructions; 
  A thread can force itself to pause, allowing a hyperthreaded CPU
    to switch to its other thread
Sleep(0) Sleep(-1) Sleep(1)
Yield()

User-Mode Constructs
  Volatile
  SpinLock
  InterLocked

Kernel-Mode Constructs
  events
  semaphores

  WaitHandle
    EventWaitHandle
      AutoResetWaitHandle
      ManualResetWaitHandle
    Semaphore
    Mutex

  Single-instance Application

  Events
    Events are simply Boolean variables maintained by the kernel.
    true / false
    unblock / block
    AutoSet: unblock a thread then set event to false
    ManualSet: unblock all thread, set event to false yourself

    SpinWait based autoresetwaithandle:
      forces the calling thread to transition from managed code to the kernel and back—which is bad. But when there is contention, the losing thread is blocked by the kernel and is not spinning and wasting CPU cycles—which is good.
  Semaphore
    Semaphores are simply Int32 variables maintained by the kernel. A thread waiting on a semaphore blocks when the semaphore is 0 and unblocks when the semaphore is greater than 0. When a thread waiting on a semaphore unblocks, the kernel automatically subtracts 1 from the semaphore’s count.
  Mutex
    A Mutex represents a mutual-exclusive lock. It works similar to an AutoResetEvent or a Semaphore with a count of 1 since all three constructs release only one waiting thread at a time.
    System.ApplicationException
    System.Threading.AbandonedMutexException
    recursion count
    Usually a recursive lock is needed when a method takes a lock and then calls another method that also requires the lock

  Hybrid Constructs
    Spinning / Thread OwnerShip / Recursion

    Monitor / lock
      Sync block index
      public / private lock object
    ReadWriterLockSlim
      Recusion / Thread Ownership / upgrade
    CountdownEvent
      This construct blocks a thread until its internal counter reaches 0.

Instead, you should use the thread pool to rent threads for short periods of time. So, a thread
pool thread starts out spell checking, then it changes to grammar checking, and then it changes again
to perform work on behalf of a client request, and so on.

In addition, avoid using recursive locks (especially recursive reader-writer locks) because they hurt
performance. However, Monitor is recursive and its performance is very good.77 Also, avoid releasing
a lock in a finally block because entering and leaving exception-handling blocks incurs a
performance hit, and if an exception is thrown while mutating state, then the state is corrupted, and
other threads that manipulate it will experience unpredictable behavior and security bugs.

In the CLR, calling any lock method is a full memory fence, and any variable writes you have before the fence must complete before the fence and any variable reads after the fence must start after it.


Double-Check Locking

Condition Variable Pattern
```

- https://www.ibm.com/developerworks/java/library/j-jtp11234/
