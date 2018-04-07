---
layout: post
title: "Deffered Function Calls in Go Language"
date: 2017-05-21 10:30:37 +0800
categories: ['Go']
tags: ['Go']
disqus_identifier: 43398230421857166741638950775453953109
---

The program below fetchs an HTML document and prints it to the `os.Stdout`. The `title` function inspects the `Content-Type` header of the server's response and returns an error if the document is not HTML.

```go
func title(url string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}

	// Check Content-Type is HTML (e.g., "text/html; charset=utf-8").
	ct := resp.Header.Get("Content-Type")
	if ct != "text/html" && !strings.HasPrefix(ct, "text/html;") {
		resp.Body.Close()
		return fmt.Errorf("%s has type %s, not text/html", url, ct)
	}
	_, err = io.Copy(os.Stdout, resp.Body)
	resp.Body.Close()
	if err != nil {
		return err
	}
	return nil
}
```

Observe the duplicated `resp.Body.Close()` call, which ensures that `title` closes the network connection on all execution paths, including failures. As functions grow more complex and have to handle more errors, such duplication of clean-up logic become a maintenance problem. Let's see how Go's novel `defer` mechanism makes things simpler.

Syntactically, a `defer` statement is an ordinary function or method call prefixed by the keyword `defer`. **The function and argument expressions are evaluated when the statement is executed, but the actual call is *deferred* until the function that contains the `defer` statement has finished**, whether normally, by execution a return statement or falling off the end, or abnormally, by panicking. **Any number of calls may be deferred; they are executed in the reverse of the order in which they were deferred.**

A `defer` statement is often used with paried operations like open and close, connect and disconnect, or lock and unlock to ensure the resources are released in all cases, no matter how complex the control flow. The right place for a `defer` statement that releases a resource is immediately after the resource has been successfully acquired. In the `title` function below, a single deferred call replaces both previous calls to `resp.Body.Close()`:

```go
func title(url string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Check Content-Type is HTML (e.g., "text/html; charset=utf-8").
	ct := resp.Header.Get("Content-Type")
	if ct != "text/html" && !strings.HasPrefix(ct, "text/html;") {
		return fmt.Errorf("%s has type %s, not text/html", url, ct)
	}
	_, err = io.Copy(os.Stdout, resp.Body)
	if err != nil {
		return err
	}
	return nil
}
```

The same pattern can be used for other resources beside network connections, for instance to close an open file:

```go
package ioutil

func ReadFile(filename string) ([]byte, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	return ReadAll(f)
}
```

or to unlock a mutext:

```go
var mu sync.Mutex
var m = make(map[string]int)

func lookup(key string) int {
	mu.Lock()
	defer mu.Unlock()
	return m[key]
}
```

The `defer` statement can also be used to pair "on entry" and "on exit" actions when debugging a complex function. The `bigSlowOperation` function below calls `trace` immediately, which does the "on entry" action then returns a function value that, when called, does the corresponding "on exit" action. By deferring a call to the returned function in this way, we can instrument the entry point and all exit points of a function in a single statement and even pass values, like the `start` time, between the two actions. But don't forget the final parentheses in the `defer` statement, or the "on entry" action will happen on exit and the on-exit action won't happen at all!

```go
func bigSlowOperation() {
	defer trace("bigSlowOperation")() // don't forget the extra parentheses
	// ...lots of work...
	time.Sleep(10 * time.Second) // simulate slow operation by sleeping
}
func trace(msg string) func() {
	start := time.Now()
	log.Printf("enter %s", msg)
	return func() { log.Printf("exit %s (%s)", msg, time.Since(start)) }
}
```

Because an anonymous function can access its enclosing funciton's variables, including named results, a deferred anoymous function can observe the function's result.

```go
func double(x int) (result int) {
	defer func() { fmt.Printf("double(%d) = %d\n", x, result) }()
	return x + x
}

func main() {
	_ = double(4)
	// Output:
	// "double(4) = 8"
}
```

Go's `defer` statement schedules a function call (the deferred function) to be run immediately before the function executing the `defer` returns. A deffered anonymous function can even change the values that the enclosing function returns to its caller:

```go
func triple(x int) (result int) {
	defer func() { result += x }()
	return double(x)
}

func main() {
	fmt.Println(triple(4)) // "12"
}
```

Because deffered functions aren't executed until the very end of a function's execution, a `defer` function statement in a loop deserves extra scrutiny. The code below could run out of file descriptors since on file will closed until all files have been processed:

```go
for _, filename := range filenames {
	f, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer f.Close() // NOTE: risky; could run out of file descriptors
	// ...process f...
}
```

One solution is to move the loop body, including the `defer` statement, into another function that is called on each iteration.

```go
for _, filename := range filenames {
	if err := doFile(filename); err != nil {
		return err
	}
}

func doFile(filename string) error {
	f, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer f.Close()
	// ...process f...
}
```

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
1. [Defer](https://golang.org/doc/effective_go.html#defer), Effective Go - The Go Programming Language
1. [Anonymous functions and closures](/2016/04/03/anonymous-functions-and-closures/)
