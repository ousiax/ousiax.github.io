---
layout: post
title: "Concurrency with Shared Variables in Go Language"
date: 2017-06-17 16-25-34 +0800
categories: ['Go',]
tags: ['Go',]
disqus_identifier: 54531108245291027721254300040613364965
---

- TOC
{:toc}

### Race Conditions

In a sequential program, that is, a program with only one groutine, the steps of the program happen in the familiar execution order determined by the program logic. For instance, in a sequence of statements, the first one happens before the second one, and so on. In a program with two or more goroutines, the steps within each goroutine happen in the familiar order, bute in general we don't know whether an event ***x*** in one goroutine happens before an eventy ***y*** in another goroutine, or happens after it, or is simulaaneous with it. We we cannot confidently say that one event ***happens before*** the other, then the event ***x*** and ***y*** are ***concurrent***.

Consider a function that works correctly in a sequential program. That function is ***concurrency-safe*** if it continues to work correctly even when called concurrently, that is, from two or more goroutines with no additional syncrhonization. We can generalize this notion to a set of collaborating functions, such as the methods and operations of a particular type. A type is concurrency-safe if all its accessible methods and operations are concurrency-safe.

*We avoid concurrent access to most variables either by **confining** them to a single goroutine or by maintaining a higher-level invariant of **mutual exclusion***.

A **race condition** is a situation in which the program does not give the correct result for some interleaving of the operations of multiple goroutines.

A **data race**, that is, a particular kind of race condition, occurs whenever two goroutines access the same variable concurrently and at least one of the accesses is a write. A good rule of thumb is that *there is no such thing as a benign data race*. It follows from this definition that there are three ways to avoid a data race.

*The first way is not to write the variable.*

```go
var icons = make(map[string]image.Image)

func loadIcon(name string) image.Image

// NOTE: not concurrency-safe!
func Icon(name string) image.Image {
	icon, ok := icons[name]
	if !ok {
		icon = loadIcon(name)
		icons[name] = icon
	}
	return icon
}
```

```go
var icons = map[string]image.Image{
	"spades.png":   loadIcon("spades.png"),
	"hearts.png":   loadIcon("hearts.png"),
	"diamonds.png": loadIcon("diamonds.png"),
	"clubs.png":    loadIcon("clubs.png"),
}

// Concurrency-safe.
func Icon(name string) image.Image { return icons[name] }
```

*The second way to avoid a data race is to avoid accessing the variable from multiple goroutines.* These variables are ***confined*** to a single goroutine. Since other goroutines cannot access the varible directly, they must use a channel to send the confining goroutine a request to query or update the variable. This is what is meant by the Go mantra "**Do not communicate by sharing memory; instead, share memory by communication.**" A goroutine that brokers access to a confined variable using channel requests is called a ***monitor goroutine*** for that variable.

```go
// Package bank implements a bank with only one account.
package bank

var balance int

func Deposit(amount int) { balance = balance + amount }

func Balance() int { return balance }
```

```go
// Package bank provides a concurrency-safe bank with one account.
package bank

var deposits = make(chan int) // send amount to deposit
var balances = make(chan int) // receive balance

func Deposit(amount int) { deposits <- amount }
func Balance() int       { return <-balances }

func teller() {
	var balance int // balance is confined to teller goroutine
	for {
		select {
		case amount := <-deposits:
			balance += amount
		case balances <- balance:
		}
	}
}

func init() {
	go teller() // start the monitor goroutine
}
```

Even when a variable cannot be confined to a single goroutine for its entire lifetime, confinement may still be a solution to the problem of concurrent access. If each stage of the pipeline refrains from accessing the variable after sending it to the next stage, then all accesses to the variable are sequential. This discipline is sometimes called ***serial confinment***.

```go
type Cake struct{ state string }

func baker(cooked chan<- *Cake) {
	for {
		cake := new(Cake)
		cake.state = "cooked"
		cooked <- cake // baker never touches this cake again
	}
}

func icer(iced chan<- *Cake, cooked <-chan *Cake) {
	for cake := range cooked {
		cake.state = "iced"
		iced <- cake // icer never touches this cake again
	}
}
```

The third way to avoid a data race is to allow many gorotines to access the variable, but only one at a time. This approach is known as *mutual exclusion*.

A semaphore that counts only to 1 is called a *binary semaphore*.

```go
// Package bank implements a bank with only one account.
package bank

var (
	sema    = make(chan struct{}, 1) // a binary semaphore guarding balance
	balance int
)

func Deposit(amount int) {
	sema <- struct{}{} // acquire token
	balance = balance + amount
	<-sema // release token
}

func Balance() int {
	sema <- struct{}{} // acquire token
	b := balance
	<-sema // release token
	return b
}
```

### Mutual Exclusion: sync.Mutex

```go
// Package bank implements a bank with only one account.
package bank

import "sync"

var (
	mu      sync.Mutex
	balance int
)

func Deposit(amount int) {
	mu.Lock()
	defer mu.Unlock()
	balance = balance + amount
}

func Balance() int {
	mu.Lock()
	defer mu.Unlock()
	return balance
}
```

By convention, the variables guarded by a mutex are declared immediately after the declaration of the mutex itself. If you devviate from this, be sure to document it.

The region of code between **Lock** and **Unlock** in which a goroutine is free to read and modify the shared variables is called a ***critial section***. The lock holder's call to **Unlock** *happens before* any other goroutine can acquire the lock itself.

When you use a mutex, make sure that both it and the variables it guards are not exported, whether they are package-level variables or the fields of a struct.


### Read/Write Mutexes: sync.RWMutex

```go
// Package bank implements a bank with only one account.
package bank

import "sync"

var (
	mu      sync.RWMutex
	balance int
)

func Deposit(amount int) {
	mu.Lock()
	defer mu.Unlock()
	balance = balance + amount
}

func Balance() int {
	mu.RLock() // readers lock
	defer mu.RUnlock()
	return balance
}
```

**RLock** can be used only if there are no writes to shared variables in the critical section. If in doubt, use an exclusive **Lock**.

It's only profitable to use an **RWMutex** when most of the goroutines that acquire the lock are readers, and the lock is under *contention*, that is, goroutines routinely have to wait to acquire it.

### Memory Synchronization

```go
var (
	balance int
	mu      sync.Mutex
)

func Withdraw(amount int) bool {
	mu.Lock()
	defer mu.Unlock()
	balance = balance - amount
	if balance < 0 {
		balance = balance + amount
		return false // insufficient funds
	}
	return true
}

func Balance() int {
	mu.Lock()
	defer mu.Unlock()
	return balance
}
```

You may wonder why the **Balance** method needs mutual exclusion, either channel-based or mutex-based. After all, unlike **Withdraw**, it consists only a single operation, so there is no danger of another goroutine executing "in the middle" of it. There are two reason we need a mutex. The first is that it's equally important that **Balance** not execute in the middle of some other operation like **Withdraw**. The second (and more subtle) reason is that **synchronization is about more than just the order of execution of multiple goroutines; synchronization also affets memory.**

In a modern computer there may be dozens of processors, each with its own local cache of the main memory. For efficiency, writes to memory are buffered within each processor and flushed out to main memory only when necessary. They may even be commited to main memory in a different order than they were written by the writting goroutine. Synchoronization primitives like channel communications and mutex operations cause the processor to flush out and commit all its accumulated writes so that the effects of goroutine execution up to that point are guaranteed to be visible to goroutines running on other processors.

Consider the possible outputs of the following snippet of code:

```go
	var x, y int
	go func() {
		x = 1                   // A1
		fmt.Print("y:", y, " ") // A2
	}()

	go func() {
		y = 1                   // B1
		fmt.Print("x:", x, " ") // B2
	}()
```

Since these two goroutine are concurrent and access shared variables without mutual exclusion, there is a data race, so we should not be surprised that the program is not deterministic. We might expect it to print any one of these four results, which correspond to intuitive interleavings of the labled statements of the program:

```
y:0 x:1
x:0 y:1
x:1 y:1
y:1 x:1
```

The fourth line could be explained by the sequence **A1,B1,A2,B2** or by **B1,A1,A2,B2**, for example. However, these two outcomes might come as a surprise:

```
x:0 y:0
y:0 x:0
```

but depending on the compiler, CPU, and many other factors, they can happen too.

Within a single goroutine, the effects of each statement are guaranteed to occur in the order of execution; goroutines are ***sequentially consistent***. But in the absence of explicit synchronization using a channel or mutex, there is no guarantee that events are seen in the same order by all goroutines. Although goroutine *A* must observe the effect of the write **x = 1** before it reads the value of **y**, it does not necessarily observe the write to **y** done by goroutine *B*, so *A* may print a *stale* value of *y*.

It is tempting to try to understand concurrency as if it corresponds to *some* interleaving of the statements of each goroutine, but as the example above shows, this is not how a modern compiler or CPU works. Because the assignment and the **Print** refer to different variables, a compiler may conclude that the order of the two statements cannot affect the result, and swap them. If the two goroutines execute on different CPUs, each with its own cache, writes by one goroutine are not visible to the other goroutine's **Print** until the caches are synchorinzed with main memory.

All these concurrency problems can be avoided by the consistent use of simple, established patterns. Wehre possible, confine variables to a single goroutines; for all other variables, use mutual exclusion.

### Lazy Intialization: sync.Once

```go
var icons map[string]image.Image

func loadIcons() {
	icons = map[string]image.Image{
		"spades.png":   loadIcon("spades.png"),
		"hearts.png":   loadIcon("hearts.png"),
		"diamonds.png": loadIcon("diamonds.png"),
		"clubs.png":    loadIcon("clubs.png"),
	}
}

// NOTE: not concurrency-safe!
func Icon(name string) image.Image {
	if icons == nil {
		loadIcons() // one-time initialization
	}
	return icons[name]
}
```

**In the absence of explicit synchornization, the compiler and CPU are free to reorder accesses to memory in any number of ways, so long as the behavior of each goroutine is sequentially consistent.** One possible reordering of the statements of **loadIcons** is show below.

```go
func loadIcons() {
	icons = make(map[string]image.Image)
	icons["spades.png"] = loadIcon("spades.png")
	icons["hearts.png"] = loadIcon("hearts.png")
	icons["diamonds.png"] = loadIcon("diamonds.png")
	icons["clubs.png"] = loadIcon("clubs.png")
}
```

- - -

```go
var (
	icons         map[string]image.Image
	loadIconsOnce sync.Once
)

func loadIcons() {
	icons = map[string]image.Image{
		"spades.png":   loadIcon("spades.png"),
		"hearts.png":   loadIcon("hearts.png"),
		"diamonds.png": loadIcon("diamonds.png"),
		"clubs.png":    loadIcon("clubs.png"),
	}
}

// Concurrency-safe.
func Icon(name string) image.Image {
	loadIconsOnce.Do(loadIcons) // lazy, similar to double check with Mutex
	return icons[name]
}
```

### The Race Detector

Even with greatest of care, it's all too easy to make concurrency mistakes. Fortunately, the Go runtime and toolchain are  equipped with a sophisticated and easy-to-use dynamic analysis too, the ***race detector***.

Just Add the **-race** flag to your **go build**, **go run**, or **go test** command. This cause the compiler to build a modified version of your application or test with additional instrumentation that effectively records all accesses to shared variables that occured during execution, along with the identity of the goroutine that read or wrote the varible. In addition, the modified program records all synchornization events, such as **go** statements, channel operations, and calls to **(*sync.Mutex).Lock**, **(*sync.WaitGroup).Wait**, and so on.

The race detector studies this steam of events, looking for cases in which one goroutine reads or writes a shared variables that was most recently written by a different goroutine without an intervening synchornization operation. This indicates a concurrent access to the shared variable, and thus a data race. The tool prints a report that includes the identity of the variable, and the stacks of active function calls in the reading goroutine and the writing goroutine. This is is usually sufficient to pinpoint the problem.

The race detector reports all data races that wre actually executed. However, it can only detect race conditions that occur during a run; it cannot prove that none will ever occur. For best results, make sure that your test exercise your packages using concurrency.

```go
     1  package main
     2
     3  import (
     4          "fmt"
     5          "sync"
     6  )
     7
     8  func main() {
     9          var wg sync.WaitGroup
    10          var x, y int
    11          wg.Add(1)
    12          go func() {
    13                  x = 1
    14                  fmt.Printf("y = %d ", y)
    15                  wg.Done()
    16          }()
    17
    18          wg.Add(1)
    19          go func() {
    20                  y = 1
    21                  fmt.Printf("x = %d ", x)
    22                  wg.Done()
    23          }()
    24
    25          wg.Wait()
    26  }
```

```sh
$ go run -race datarace.go
y = 0 ==================
WARNING: DATA RACE
Write at 0x00c4200621a0 by goroutine 7:
  main.main.func2()
      /tmp/datarace.go:20 +0x3f

Previous read at 0x00c4200621a0 by goroutine 6:
  main.main.func1()
      /tmp/datarace.go:14 +0x5f

Goroutine 7 (running) created at:
  main.main()
      /tmp/datarace.go:23 +0x16f

Goroutine 6 (finished) created at:
  main.main()
      /tmp/datarace.go:16 +0x122
==================
==================
WARNING: DATA RACE
Read at 0x00c420062168 by goroutine 7:
  main.main.func2()
      /tmp/datarace.go:21 +0x5f

Previous write at 0x00c420062168 by goroutine 6:
  main.main.func1()
      /tmp/datarace.go:13 +0x3f

Goroutine 7 (running) created at:
  main.main()
      /tmp/datarace.go:23 +0x16f

Goroutine 6 (finished) created at:
  main.main()
      /tmp/datarace.go:16 +0x122
==================
x = 1 Found 2 data race(s)
exit status 66
```

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
