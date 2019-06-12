---
layout: post
title: 七周七并发-笔记
date: 2019-06-12 10:56:08 +0800
categories: ['programming']
tags: ['programming']
---

```none
并发与并行
  "Concurrency is about dealing with lots of things at once. Parallelism is about doing lots of things at once." — Rob Pike 
  并发是同一时间应对多件事情的能力, 并行是同一时间做多件事情的能力.

  并发程序的执行通常是不确定的，它会随着事件时序的改变给出不同的结果。

  并发并不仅仅是利用多核能力，同时有及时响应、高效、容错、简单的优势。

并行架构
  位级(bit)并行
    处理器数据位宽: 8位, 16位, 32位, 64位
  指令级(instruction)并行
    CPU 并行: 流水线, 乱序执行, 猜测执行
  数据级(data)并行
    单指令多数据架构(SIMD)
    GPU(图形处理器)
  任务级(task)并行
    多处理器/多核/超线程
    共享内存模型(SMP)
    分布式内存模型(NUMA)

线程与锁模型
  线程 / 共享内存模型 / 互斥
  内存可见性 / 顺序一致性 / happen-before
  读-改-写(read-modify-write)模式
  线程同步: 互斥锁(mutex), 信号量(semaphore)
    哲学家进餐问题 / 死锁
      全局固定顺序获取多把锁
      条件变量
    外星方法 / 保护性复制(defensive copy) / 对副本进行操作
    交替锁(hand-over-hand locking) / 链表插入操作
    原子变量 / 无锁(lock-free) / 非阻塞(non-blocking)
  线程与锁模型没有为并行提供直接的支持，仅支持共享内存模型，并不支持分布式内存模型
  原子操作
    原子操作是指从另外一个线程的角度看上去，该操作的状态只能是“已发生”或者“未发生”，而不会是发生了一半

函数式编程
  函数式编程(functional programming)与命令式编程(imperative programming)
    命令式编程的代码由一系列改变全局状态的语句构成
    函数式编程则是将计算过程抽象成表达式求值
    函数式编程并不是基于可变状态的数据，因此多余不可变数据，多线程不使用锁就可以安全地访问
  函数式并发
    引用透明性
      在纯粹的函数语言中，函数都具有引用透明性——在任何调用函数的地方，都可以用函数运行的结果来体会函数的调用，
        而不会对程序产生副作用，如(+ (+ 1 2) (+ 2 3)) 等价于 (+ 3 (+ 2 3)) 等价于(+ (+ 1 2) 5)
    数据流式编程(dataflow programming)
      future 模型 / promise 模型
      Future 模型
        future 函数可以接受一段代码，并在一个单独的线程中执行这段代码，并返回一个 feature 对象
        对future对象进行解引用将阻塞当前线程，直到其代表的值变得可用，即完成异步求值
      Promise 模型
        promise 对象也是异步求值，但不会立即执行
  Clojure: 分离标识与状态
    原子变量
    持久数据结构: 指数据结构被修改时总是保留之前的副本（共享结构）
    标识(identity)和状态(State)
    可变数据类型：原子变量(atomic),代理(agent)和引用(ref)
    软件事物内存STM(Software Transaction Memeory): 原子性(A)/一致性(C)/隔离性(I)
Actor 模型
  Erlang / 尾递归消除(优化)
  消息 / 队列式信箱 / 元组
  进程 / 父进程 / 管理进程 / Actor
  终止 / 错误检测 / 容错 / 错误处理(Kernal)
  分布式 / OTP / 重启策略 / 节点
  进程：独立，并发执行的实体
    进程间通过发送消息进行通信
    进程与信箱是紧耦合的

  Alan Kayak： 创建一个规模宏大的且可生长的系统的关键在于模块之间应该如何交流，
    而不是在于其内部的属性和行为应如何一致。
CSP 模型
  CSP 通信顺序进程(Communicating Sequential Process)
  Golang / Clojure/core.async
  channel / go
  同步(synchroning) / 缓冲(buffering) / 阻塞(blocking) / 弃用(dropping) / 移除(sliding)
  阻塞 / 线程池 / 事件驱动 / 状态机 / 控制反转

  actor 模型侧重于容错和分布式 / csp 模型侧重于效率和代码表达的流畅性

数据并行 GPU
  GPGPU: General-purpose computing on the CPU
  OpenCL / OpenGL
  流水线 / 多 ALU
  数值计算

Lambda 架构
  批处理层(batch layer) / MapReduce
  加速层(speed layer) / Streaming
  Spark / Storm
```
