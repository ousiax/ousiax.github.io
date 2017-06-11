---
layout: post
title: "Goroutines and Channels in Go Lanugage"
date: 2017-06-11 11-33-43 +0800
categories: ['Go']
tags: ['Go', 'Goroutine', 'Channel']
disqus_identifier: 173717911066083403588181774442153793683
---

* toc
{:toc}

* * *

Go enables two styles of concurrent programming, ***communicating sequential processes*** and ***shared memory multithreading***. Goroutines and channels, which support *communicating sequential processes* or CSP, a model of concurrency in which values are passed between independent activities (goroutines) but variables are for the most part confined to a single activity.

### Goroutines

In Go, each concurrently executing activity is called a *goroutine*. When a program starts, is only goroutine is the one that calls the **main** function, so we call it the ***main goroutin***. New goroutines are created by the **go** statement. Syntacticaly, a **go** statement is an ordinary function or method call prefixed by the keyword **go**. A **go** statement causes the function to be called in a newly created goroutine. The **go** statement itself completes immediately:

```go
	f()    // call f(); wait for it to return
	go f() // create a new goroutine that calls f(); don't wait
```

Other than by returning from **main** or exiting the program, there is no programmatic way for one goroutine to stop another, but there are ways to communicate with a goroutine to request that it stop itself.

### Channels

If goroutines are the activities of a concurrent Go program, ***channels*** are the connections between them. A channel is a communication mechanism that lets one goroutine send values to another goroutine. Each chanel is conduit for values of a particular type, called the channel's ***element type***.

To create a channel, we use the built-in **make** function:

```go
	ch := make(chan int) // ch has type 'chan int'
```

As with maps, a channel is a *reference* to the data structure created bye **make**. As with other reference types, the zero value of a channel is **nil**.

Two channels of the same type may be compared using **==**. The comparision is true if both are references to the same channel data structure. A channel may also be compared to **nil**.

A channel has two principal operations, ***send*** and ***receive***, collectively known as ***communications***.  A *send statement* transmits a value from one goroutine, through the channel, to another goroutine executing a corresponding *receive expression*. Both operations are written using the **<-** operator. In a send statement, the **<-** separates the channel and value operands. In a receive expression, **<-** preceds the channel operand. A receive expression whose result is not used is a valid statement.

```go
	ch <- x  // a send statement
	x = <-ch // a receive expression in an assignment statement
	<-ch     // a receive expression; the result is discarded
```

Channels support a third operation, ***close***, which sets a flag indicating that no more values will ever be sent on this channel, subsequent attempts to send will panic. Receive operations on a closed channel yield the values that has been sent until no more value are left, any receive operations thereafter complete immediately and yield the zero value of the channel's element type.

To close a channel, we call the buit-in **close** function:

```go
	close(ch)
```

There is no way to test directly whether a chanel has been closed, but there is a variant of the receive operation that produces two results: the received channel element, plus a boolean value, conventionnaly called **ok**, which is **true** for a successful receive and **false** for a receive on a closed and drained channel.

```go
	x, ok := <-ch
	if !ok {
		// channel was closed and drained
	}
```

Because the syntax above is clumsy and this pattern is common, there is a more convenient syntax for receving all the values sent on a channel with a **range** loop to interate over the channel and terminating the loop after the last one.

You don't close every channel when you've finished with it. It's only necessary to close a channel when it is important to tell the receiving goroutines that all data have been sendt. A channel that the garbage collector determines to be unreachable will have its resources reclaimed whether or not it is closed. (Don't confuse this with the close operation for open files. It *is* important to call the **Close** method on every file when you've finished with it.)

Attempting to close an already-closed channel causes a panic, as does closing a nil channel.

A channel create with a simple call to **make** is called an *unbuffered* channel, but **make** accepts an optional second argument, an integer called the channel's *capacity*. If the capacity is non-zero, **make** create a *buffered* channel.

```go
	ch = make(chan int)    // unbuffered channel
	ch = make(chan int, 0) // unbuffered channel
	ch = make(chan int, 3) // buffered channel
```

#### Unbuffered Channels

A send operation on an unbuffered channel blocks the sending goroutine until another goroutine executes a corresponding receive on the same channel, at which point the value is transmitted and both goroutines may continue. Conversely, if the receive operation was attempted first, the receiving goroutine is blocked until another goroutine performs a send on the same chanel.

Communication over an unbuffered channel causes the sending and receving goroutines to ***synchornize***. Because of this, unbuffered channels are sometimes called ***synchornous channels***. When a value is sent on an unbuffered channel, the receipt of the value *happens before* the reawakening of the sending goroutine.

Channels can be used to connect goroutines together so that the output of one is the input to another. This is called a ***pipeline***.

#### Unidirectional Channel Types

When a channel is supplied as a function parameter, it is nearly always with the intent that is be used exclusively for sending or exclusively for receiving.

To document this intent and prevent misuse, the Go type system provides *unidirectional* channel types that expose only one or the other of the send and receive operations. The type **chan<- int**, a ***send-only*** channel of **int**, allows sned but not receives. Conversely, the type **<-chan int**, a ***receive-only*** channel of **int**, allows receives but not sends. (The position of the **<-** arrow relative to the **chan** keyword is a mnemonic.) Violations of this discipline are detected at compile time.

Since the **close** operation asserts that no more sends will occur on a channel, only sending goroutine is in a position to call it, and for this reason it it complie-time error to attempt to close a receive-only channel.

Conversions from bidirectional to unidirectional channel types are permitted in any assignment. There is no going back, however: once you have a value of unidirectional type such as **chan<- int**, there is no way to obtain from it a value of type **chan int** that refers to the same channel data structure.

```go
package main

import "fmt"

func counter(out chan<- int) {
	for x := 0; x < 100; x++ {
		out <- x
	}
	close(out)
}
func squarer(out chan<- int, in <-chan int) {
	for v := range in {
		out <- v * v
	}
	close(out)
}
func printer(in <-chan int) {
	for v := range in {
		fmt.Println(v)
	}
}
func main() {
	naturals := make(chan int)
	squares := make(chan int)
	go counter(naturals)
	go squarer(squares, naturals)
	printer(squares)
}
```

#### Buffered Channels

A buffered channel has a queue of elements. The queue's maximum size is determined when it is create, by the capacity argument to **make**.

A send operation on a buffered channel inserts an element at the back of the queue, and a receive operation removes an element from the front. If the channel is full, the send opearation blocks its goroutine until space is make available by another goroutine's receive. Conversely, if the channel is empty, a receive operation blocks until a value is sent by another goroutine.

In the unlikely event that a program needs to know the channel's buffer capacity, it can be obtained by calling the built-in **cap** function.

When applied to a channel, the built-in **len** function returns the number of elements currently buffered. Since in a concurrent program this information is likely to be stale as soon as it is retrieved, its value is limited, but it could conceivably be useful during fault diagnosis or performance optimization.

Novices are sometimes tempted to use buffered channels within a single goroutine as a queue, lured by their pleasingly simple syntax, but this is a mistake. Channels are deeply connected to goroutine scheduling, and without another goroutine receiving from the channel, a sender—and perhaps the whole program—risks becomminng blocked forever. If all you need is simple queue, make one using a slice.

**The assembly line metaphor is useful one for channels and goroutines. For exmaple, if the second stage is more elaborate, a single cook may not be able to keep up with the supply from the first cook or meet the demand from the third. To sovle the problem, we could hire another cook to help the second, performing the same task but working independently. This is analogous to creating another goroutine communicating over the same channels.**

To know when the last goroutine has finished (which may not be the last one to start), we need to increment a counter before each goroutine starts and decrement it as each gorutine finishes. This demands a special kind of counter, one that can be safely manipulated from multiple gorutines and that provides a way to wait unitl it becomes zero. This counter type is known as **sync.WaitGroup**.

```go
// makeThumbnails makes thumbnails for each file received from the channel.
// It returns the number of bytes occupied by the files it creates.
func makeThumbnails(filenames <-chan string) int64 {
	size := make(chan int64)
	var wg sync.WaitGroup // number of working goroutines
	for f := range filenames {
		wg.Add(1)
		// worker
		go func(f string) {
			defer wg.Done()
			thumb, err := thumbnail.ImageFile(f)
			if err != nil {
				log.Println(err)
				return
			}
			info, _ := os.Stat(thumb) // OK to ignore error
			sizes <- info.Size()
		}(f)
	}

	// closer
	go func() {
		wg.Wait()
		close(sizes)
	}()

	var total int64
	for size := range sizes {
		total += size
	}
	return total
}
```

Note the asymmetry in the **Add** and **Done** methods. **Add**, which increments the counter, must be called before the worker goroutine starts, not within it; otherwise we would not be sure that the **Add** *happens before* the "closer" goroutine call **Wait**. Also, **Add** take a parameter, but **Done** does not; it equivalent to **Add(-1)**. We use **defer** to ensure that the counter is decremented even in the eror case. The structure of the code above is a common and idiomatic pattern for loopingg in parallel when we don't know the number of iterations.

**Unbounded parallelism is rarely a good idea since there is always a limiting factor in the system, such as the number of CPU cores for compute-bound workloads, the number of spindles and heads for local disk I/O operations, the bandwidth of the network for streaming downloads, or the serving capacity of a web services.** The solution is to limit the number of parallel uses of the resource to match the level of parallelism that is available.

We can limit parallelism using a buffered channel of capacity **n** to model a concurreny primitive called a ***couting semaphore***. Conceptually, each of the *n* vacant slots in the channel buffer represents a token entitling the holder to proceed. Sending a value into the channel **acquires a token**, and receving a value from the channel **releases a token**, creating a new vacant slot. This ensures that at most **n** sends can occur without an intervening receive. (Although it might be more intuitive to treat **filled** slots in the channel buffer as tokens, using vacant slots avoids the need to fill the channel buffer after creating it.) Since the channel element type is not imporatnt, we'll use **struct{}**, which has size zero.

```go
// tokens is a counting semaphore used to
// enfore a limit of 20 concurrent request.
var tokens = make(chan struct{}, 20)

func crawl(url string) []string {
	fmt.Println(url)
	token <- struct{}{} // acquire a token
	defer func() {      // release the token
		<-tokens
	}()
	list, err := links.Extract(url)
	if err != nil {
		log.Print(err)
	}
	return list
}
```

### Multiplexing with select

```go
	select {
	case <-ch1:
		// ...
	case x := <-ch2:
		// ...use x...
	case ch3 <- y:
		// ...
	default:
		// ...
	}
```

The general form of a *select statement* is shown above. Like a switch statement, it has a number of cases and an optional **default**. Each case specifies a ***communication** (a send or receive operation on some channel) and an associated block of statements. A receive expression may appear on its own, as in the first case, or within a short variable declaration, as in the second case, the second form lets you refer to the received value.

A **select** waits until a communication for some case is ready to proceed. It then performs that communication and executes the case's associated statements; the other communications do not happen. A **select** with no cases, **select{}**, waits forever.

If multiple cases are ready, **select** picks one at random, which ensures that every channel has an equal chance of being selected.

A **select** may have a **default**, which specifies what to do when none of the other communications can proceed immediately (a *non-blocking* communication).

Becaulse send and receive operations on a nil channel block forever, a case in a select statment whose channel is nil is never selected.

### Cancellation

There is no way for one goroutine to terminate another directly, since that would leave all its shared variables in undefined states. We could send a single value on a channel named **abort**, which the goroutine interpreted as a request to stop itself. But what if we need to cancel two goroutines, or an arbitrary number?

One possibility might be to send as many events on the **abort** channel as there are goroutines to cancel. If some of the goroutines have already terminated themselves, however, our count will be too large, and our sends will get stuck. On the other hand, if those goroutines have spawned other goroutines, our count will be too small, and so goroutines will remian on out behalf at any give moment. Moreover, when a goroutine receives a value from the **abort** channel, it consumes that value so that other goroutines won't see it. **For cancellation, what we need is a relable mechanism to *broadcast* an event over a channel so that many goroutines can see it *as* it occurs and can later see that is *has* occurred.** 

**Recall that after a channel has been closed and drained of all sent values, subsequent receive operations proceed immediately, yielding zero values. We can exploit this to create a broadcast mechanism: don't send a value on the channel, *close* it.**

First, we create a cancellation channel on which no values are ever sent, but whose closure indicates that it is time for the program to stop what it is doing. We also define a utility function, **cancelled**, that check or ***polls*** the cancellation state at the instant it is called.

```go
var done = make(chan struct{})

func cancelled() bool {
	select {
	case <-done:
		return true
	default:
		return false
	}
}
```

Next, we create a goroutine that will read from the standard input, which is typically connected to the terminal. As soon as any input is read (for instance, the user presses the return key), this goroutine broadcasts the cancellation by closing the **done** channel.

```go
	// Cancel traversal when input is detected.
	go func() {
		os.Stdin.Read(make([]byte, 1)) // read a single byte
		close(done)
	}()
```

Now we need to make our goroutines respond to the cancellation. In the main goroutines, we add a third case to the select statement that tries to receive from the **done** channel.

```go
	for {
		select {
		case <-done:
			// Drain fileSizes to allow existing goroutines to finish.
			for range fileSizes {
				// Do nothing.
			}
		case size, ok := <-fileSizes:
			// ...
		}
	}
```

The **walkDir** goroutine polls the cancellation status when it begins, and returns without doing anything if the status is set. This turns all goroutines created after cancellation into no-ops:

```go
func walkDir(dir string, n *sync.WaitGroup, fileSizes chan<- int64) {
	defer n.Done()
	if cancelled() {
		return
	}
	for _, entry := range dirents(dir) {
		// ...
	}
}
```

It might be profitable to poll the cancellation status again with **walkDir**'s loop, to avoid creating goroutines after the cancellation event. Cancellation involves a trade-off; a quicker response often requires more intrusive changes to program logic. Ensuring that no expensive operations ever occur after the cancellation event may require updating may places in your code, but often most of the benefit can be obtained by checking for cancellation in a few important places.

Of course, when **main** returns, a program exits, so it can be hard to tell a main function that clean up after itself from one that does not. There's handy trick we can use during testing: if instead of returning from **main** in the event of cancellation, we execute a call to **panic**, then the runtime will dump the stack of every goroutine in the program.

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
1. [Concurrency](https://golang.org/doc/effective_go.html#concurrency), Effective Go - The Go Programming Language
1. [Channel types](https://golang.org/ref/spec#Channel_types), The Go Programming Language Specification.
1. [goroutine背后的系统知识](http://www.sizeofvoid.net/goroutine-under-the-hood/), http://www.sizeofvoid.net/goroutine-under-the-hood/
