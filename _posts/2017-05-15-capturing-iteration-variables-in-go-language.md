---
layout: post
title: "Capturing Iteration Variables in Go Language"
date: 2017-05-15 19:33:03 +0800
categories: ['Go']
tags: ['Go', 'Closure', "Anonymous Functions"]
disqus_identifier: 141757748613418085833278844065856773717
---

Named functions can be declared only at the package level, but we can use a *function literal* to denote a function value within any expression. A function literal is written like a function declaration, but without a name following the `func` keyword. It is an expression, and its value is called an ***anonymous function***.

Function literals let us define a function at its point of use. As an example, the call to `strings.Map` can be rewritten as

```go
strings.Map(func(r rune) rune { return r + 1}, "HAL-9000")
```

More importantly, functions defined in this way have access to the entire lexical environment, so the inner function can refer to variables from the enclosing funciton, as this example shows:

```go
package main

import "fmt"

// squares returns a function that returns
// the next square number each time it is called.
func squares() func() int {
	var x int
	return func() int {
		x++
		return x * x
	}
}

func main() {
	f := squares()
	fmt.Println(f()) // "1"
	fmt.Println(f()) // "4"
	fmt.Println(f()) // "9"
	fmt.Println(f()) // "16"
}
```

The function `squares` returns another function, of type `func() int`. A call to `squares` creates a local variable `x` and returns an anonymous function that, each time it is called, increments `x` and return its square. A second call to `squares` would create a second variable `x` and return a new anonymous function with increments that variable.

The `squares` example demonstrates that **function values are not just code but can have state.** The anonymous inner function can access and update the local variables of the enclosing function `squares`. These hidden variable references are why we classify functions as reference types and why function values are not comparable. Function values like these are implemented using a technique called ***closures***, and Go programmerrs often use this term for function values.

Here again we see an example where the lifetime of a variable is not determined by its scope: the variable `x` exists after `squares` has returned within `main`, even though `x` is hidden inside `f`.

- - -

```go
package main

import "fmt"

func main() {
	var fb func(int) int
	fb = func(n int) int {
		if n == 0 || n == 1 {
			return 1
		}
		return fb(n-1) + fb(n-2)
	}
	// 0:1 1:1 2:2 3:3 4:5 5:8 6:13 7:21 8:34 9:55
	for n := 0; n < 10; n++ {
		fmt.Printf("%d:%d ", n, fb(n))
	}
}
```

When an anonymous function requires recursion, as in this example, we must first declare a variable, and then assign the anonymous function to that variable. Had these two steps been combined in the declaration, the function literal would not be within the scope of the variable `fb` so it would have no way to call itself recursively:

```go
	// var fb func(int) int
	fb := func(n int) int {
		if n == 0 || n == 1 {
			return 1
		}
		return fb(n-1) + fb(n-2) // compile error: undefined: fb
	}
```

- - -

In this section, we'll look at a pitfall of Go's lexical scope rules that can cause surprising results. We urge you to understand the problem before proceeding, because the trap can ensnare even experienced programmers.

Consider a program that must create a set of directories and later remove them. We can use a slice of function values to hold the clean-up operations. (For brevity, we have ommited all error handling in this example.)

```go
	var rmdirs []func()
	for _, d := range tempDirs() {
		dir := d               // NOTE: necessary!
		os.MkdirAll(dir, 0755) // creates parent directories too
		rmdirs = append(rmdirs, func() {
			os.RemoveAll(dir)
		})
	}
	// ...do some work...
	for _, rmdir := range rmdirs {
		rmdir() // clean up
	}
```

You may wondering why we assigned the loop variable `d` to a new local variable `dir` within the loop body, instead of just naming the loop variable `dir` as in this subtly incorrect variant:

```go
	var rmdirs []func()
	for _, dir := range tempDirs() {
		os.MkdirAll(dir, 0755)
		rmdirs = append(rmdirs, func() {
			os.RemoveAll(dir) // NOTE: incorrect!
		})
	}
```

The reason is a consequence of the scope rules for loop variables. In this program immediately above, the `for` loop introduces a new lexical block in which the variable `dir` is declared. All function values created by this loop "capture" and share the same variable—an addressable storage location, not its value at that particular moment. The value of `dir` is updated in successive iterations, so by the time the cleanup functions are called, the `dir` variable has been updated serval times by the now-completed `for` loop. Thus `dir` holds the value from the final iteration, and consequently all calls to `os.RemoveAll` will attempt to remove the same directory.

Frequently, the inner variable introduced to work around this problem—`dir` in out example—is given the exact same name as the outer variable of which it is a copy, leading to odd-looking but crucial variable declarations like this:

```go
	for _, dir := range tempDirs() {
		dir := dir // declares inner dir, intialized to outer dir
        // ...
	}
```

The rist is not uique to `range`-based `for` loops. The loop in the example below suffers from the same problem due to unitended capture of the index variable `i`.

```go
	var rmdirs []func()
	dirs := tempDirs()
	for i := 0; i < len(dirs); i++ {
		os.MkdirAll(dirs[i], 0755) // OK
		rmdirs = append(rmdirs, func() {
			os.RemoveAll(dirs[i]) // NOTE: incorrect!
		})
	}
```

The problem of iteration variable capture is most often encountered when using the `go` statement or with `defer` since both may delay the execution of a function value until after the loop has finished. But the problem is not inherent to `go` or `defer`.

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
1. [Blocks, declarations and scope](https://golang.org/ref/spec#Blocks), The Go Programming Language Specification.
1. [Anonymous functions and closures](/2016/04/03/anonymous-functions-and-closures/)
