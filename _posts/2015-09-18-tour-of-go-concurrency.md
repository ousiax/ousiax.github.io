---
layout: post
title: "Tour of Go - Concurrency"
date: 2015-09-18 21:12:40 +0800
categories: ['go',]
tags: ['go', ]
---
## Concurrency

### Goroutines

A *goroutine* is a lightweight *thread* managed by the Go runtime.

    go f(x, y, z)

starts a new goroutine running

    f(x, y, z)

The evaluation of `f`, `x`, `y`, and `z` happens in the current goroutine and the execution of `f` happens in the new goroutine.

Goroutines run in the same address space, so access to shared memory must be synchronized. The `sync` package provides useful primitives, although you won't need them much in Go as there are other primitives. (See the next slide.)

{% highlight go %}
package main

import (
	"fmt"
	"time"
)

func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}
{% endhighlight %}

### Channels

Channels are a typed conduit through which you can send and receive values with the channel operator, `<-`.

    ch <- v    // Send v to channel ch.
    v := <-ch  // Receive from ch, and
               // assign value to v.

(The data flows in the direction of the arrow.)

Like maps and slices, channels must be created before use:

    ch := make(chan int)

By default, sends and receives block until the other side is ready. This allows goroutines to synchronize without explicit locks or condition variables.

{% highlight go %}
package main

import "fmt"

func sum(a []int, c chan int) {
	sum := 0
	for _, v := range a {
		sum += v
	}
	c <- sum // send sum to c
}

func main() {
	a := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(a[:len(a)/2], c)
	go sum(a[len(a)/2:], c)
	x, y := <-c, <-c // receive from c

	fmt.Println(x, y, x+y)
}
{% endhighlight %}

### Buffered Channels

Channels can be *buffered*. Provide the buffer length as the second argument to `make` to initialize a buffered channel:

    ch := make(chan int, 100)

Sends to a buffered channel block only when the buffer is full. Receives block when the buffer is empty.

Modify the example to overfill the buffer and see what happens.

{% highlight go %}
package main

import "fmt"

func main() {
	ch := make(chan int, 2)
	ch <- 1
	ch <- 2
	fmt.Println(<-ch)
	fmt.Println(<-ch)
}
{% endhighlight %}

### Range and Close

A sender can `close` a channel to indicate that no more values will be sent. Receivers can test whether a channel has been closed by assigning a second parameter to the receive expression: after

    v, ok := <-ch

`ok` is `false` if there are no more values to receive and the channel is closed.

The loop `for i := range c` receives values from the channel repeatedly until it is closed.

**Note**: Only the sender should close a channel, never the receiver. Sending on a closed channel will cause a panic.

**Another note**: Channels aren't like files; you don't usually need to close them. Closing is only necessary when the receiver must be told there are no more values coming, such as to terminate a `range` loop.

{% highlight go %}
package main

import (
	"fmt"
)

func fibonacci(n int, c chan int) {
	x, y := 0, 1
	for i := 0; i < n; i++ {
		c <- x
		x, y = y, x+y
	}
	close(c)
}

func main() {
	c := make(chan int, 10)
	go fibonacci(cap(c), c)
	for i := range c {
		fmt.Println(i)
	}
}
{% endhighlight %}

### Select

The `select` statement lets a goroutine wait on multiple communication operations.

A `select` blocks until one of its cases can run, then it executes that case. It chooses one at random if multiple are ready.
{% highlight go %}
package main

import "fmt"

func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}
{% endhighlight %}

### Default Selection

The `default` case in a `select` is run if no other case is ready.

Use a `default` case to try a send or receive without blocking:

    select {
    case i := <-c:
        // use i
    default:
        // receiving from c would block
    }
{% highlight go %}
package main

import (
	"fmt"
	"time"
)

func main() {
	tick := time.Tick(100 * time.Millisecond)
	boom := time.After(500 * time.Millisecond)
	for {
		select {
		case <-tick:
			fmt.Println("tick.")
		case <-boom:
			fmt.Println("BOOM!")
			return
		default:
			fmt.Println("    .")
			time.Sleep(50 * time.Millisecond)
		}
	}
}
{% endhighlight %}

* * *

### References

* Tour of Go,[http://tour.golang.org/](http://tour.golang.org/)
