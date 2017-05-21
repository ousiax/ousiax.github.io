---
layout: post
title: "Object-oriented Programming in Go Language"
date: 2017-05-21 17-27-56 +0800
categories: ['Go']
tags: ['Go']
disqus_identifier: 203179644519977345273349616101311842042
---

* toc
{:toc}

* * *

Since the early 1990s, object-oriented programming (OOP) has been the dominant programming paradigm in industry and education, and nearly all widely used languages developed since then have inlcuded support for it. Go is no exception.

Although there is no universally accepted definition of object-oriented programming, for our purposes, an ***object*** is simply a value or variables that has methods, and a ***method*** is a function associated with a particular type. An object-oriented program is one that uses methods to express the properties and operations of each data structure so that clients need not access the object's representation directly.

### Method Declarations

A method is declared with variant of the ordinary function declaration in which an extra parameter appears before the function name. The parameter attachs the function to the type of that parameter.

```go
package geometry

import "path"

type Point struct{ X, Y float64 }

// traditional funcitoni
func Distance(p, q Point) float64 {
	return maht.Hypot(p.X-q.X, p.Y-q.Y)
}

// same thing, but as a method of the Point type
func (p Point) Distance(q Point) float64 {
	return maht.Hypot(p.X-q.X, p.Y-q.Y)
}
```

The extra parameter `p` is called the method's ***receiver***, a legacy from early object-oriented languages that described calling a method as "sending a message to an object".

In Go, we don't use a special name like **this** or **self** for the receiver; we choose receiver names just as we would for any other parameter. **Since the receiver name will be frequently used, it's a good idea to choose something short and to be consistent across methods. A common choice is the first letter of the type name, like `p` for `Point`.**

In a method call, the receiver argument appears before the method name. This parallels the declaration, in which the receiver parameter appears before the method name.

```go
p := Point{1, 2}
q := Point{4, 6}
fmt.Println(Distance(p, q)) // "5", function call
fmt.Println(p.Distance(q))  // "5", method call
```

There's no conflict between the two declarations of functions called `Distance` above. The first declares a package-level function called `geometry.Distance`. The second declares a method of the type `Point`, so its name is `Point.Distance`.

The expression `p.Distance` is called a ***selector***, because it select the appropriate `Distance` method for the receiver `p` of type `Point`. Selectors are also used to select fields of struct types, as in `p.X`. **Since mehtods and fields inhabit the same name space, declaring a method `X` on the struct `Point` would be ambiguous and the compiler will reject it.**

### Methods with a Pointer Receiver

Because calling a function makes a copy of each argument value, if a function needs to update a variable, of if an argument is so large that we wish to avoid copying it, we must pass the address of the variable using a pointer. The same goes for methods that need to update receiver variable: we attach them to the pointer type, such as `*Point`.

```go
func (p *Point) ScaleBy(factor flaot64) {
	p.X *= factor
	p.Y *= factor
}
```

The name of this method is `(*Point).ScaleBy`. The parentheses are neccessary; without them, the expression would be parsed as `*(Point.ScaleBy)`.


**In a realistic program, convention dictates that if any method of `Point` has a pointer receiver, the *all* methods of `Point` should have a pointer receiver, even ones that don't strictly need it.**

Named types (`Point`) and pointers to them (`*Point`) are the only types that may appear in a receiver declaration. Furthermore, to avoid ambiguities, method declarations are not permitted on named types that are themselves pointer types:

```go
type P *int
func (P) f() { /* ... */ } // compile error: invalid receiver type
```

If the receiver `p` is a *variable* of type `Point` but the method requires a `*Point` receiver, we can use this shorthand:

```go
p.ScaleBy(2)
```

and the compiler will perform an implicity `&p` on the variable. This works only for variables, including struct field like `p.X` and array or slice elements like `perim[0]`. We cannot call a `*Point` method on a non-addressable `Point` receiver, because there's no way to obtain the address of a temporary value.

```go
// compile error: cannot call pointer method on Point literal
// compile error: cannot take the address of Point literal
Point{1, 2}.ScaleBy(2)
```

But we ***can*** call a `Point` method like `Point.Distance` with a `*Point` reciver, because there is a way to obtain the value from the address: just load the value pointed to by the receiver. The compiler inserts an implicit `*` operation for us. The two function call are equivalent:


Either the receiver argument has the same type as the receiver parameter, for example both have type `T` or both have type `*T`:

```go
	Point{1, 2}.Distance(q) // Point
	pptr.Distance(q)        // Point
```

If all the methods of a named type `T` have a receiver type of `T` itself (not `*T`), it is safe to copy instances of that type; calling any of its methods necessarily makes a copy. But if any method has a pointer receiver, you should avoid copying instances of `T` because doing so may violate internal invariants.

#### Nil Is a Valid Receiver Value

Just as some functions allow nil pointers as arguments, so do some methods for their receiver, especially if **nil** is a meaningful zero value of the type, as with maps and slices.

When you define a type whose methods allow **nil** as a receiver value, it's worth pointing this out explicitly in its documentation comment.

### Composing Types by Struct Embedding

```go
import "image/color"

type Point struct{ X, Y float64 }

type ColoredPoint struct {
	Point
	Color clor.RGBA
}
```

We could have defined `ColoredPoint` as a struct of three fields, but instead we ***embedded*** a `Point` to provide the `X` and `Y` fields. A similar mechanism applies to the *methods* of `Point`. We can call methods of the embedded `Point` field using a receiver of type `ColoredPoint`, even though `ColoredPoint` has no declared methods:

```go
	red := color.RGBA{255, 0, 0, 255}
	blue := color.RGBA{0, 0, 255, 255}
	var p = ColoredPoint{Point{1, 1}, red}
	var q = ColoredPoint{Point{5, 4}, blue}
	fmt.Println(p.Distance(q.Point)) // "5"
	p.ScaleBy(2)
	q.ScaleBy(2)
	fmt.Println(p.Distance(q.Point)) // "10"
```

The methods of `Point` have been ***prometed*** to `ColoredPoint`.

Notice the calls to `Distance` above. `Distance` has a parameter of type `Point`, and `q` is not a `Point`, so although `q` does have an embedded field of that type, we must explicitly select it. Attempting to pass `q` would be an error:

```go
p.Distance(q) // compile error: cannot use q (type ColoredPoint) as type Point in argument to p.Point.Distance
```

A `ColoredPoint` is not a `Point`, but it "has a" `Point`, and it has two additional methods `Distance` and `ScaleBy` promoted from `Point`. If you prefer to think in terms of implementation, the embedded field instructs the compiler to generate additional wrapper that delegate to the declared method, equivalent to these:

```go
func (p ColoredPoint) Distance(q Point) float64 {
	return p.Point.Distance(q)
}

func (p *ColoredPont) ScaleBy(factor float64) {
	return p.Point.ScaleBy(factor)
}
```

When `Point.Distance` is called by the first of these wrapper methods, its receiver value is `p.Point`, not `p`, and there is no way for the method to access the `ColoredPoint` in which the `Point` is embedded.

A struct type may have more than one anonymous field. **When the compiler resolves a selector such as `p.ScaleBy` to a method, it first looks for directly method named `ScaleBy`, then for methods promoted once from `ColoredPoint`'s embedded fields, then for methods promoted twich from embedded fileds within `Point` and `RGBA`, and so on.** **The compiler reports an error if the selector was ambiguous because two methods were promoted from the same rank.**

With embedding, it's possible and sometimes useful for ***unmamed*** struct types to have methods too. The following example shows part of a simple cache implemented using two package-level variable, a mutex and the map that it guards:

```go
var (
	mu      sync.Mutex // guards mapping
	mapping = make(map[string]string)
)

func Lookup(key string) string {
	mu.Lock()
	defer mu.Unlock()
	return mapping[key]
}
```

The version below is funcitonally equivalent but groups together the two related variables in a single package-level variable, `cache`:

```go
var cache = struct {
	sync.Mutex
	mapping map[string]string
}{
	mapping: make(map[string]string),
}

func Lookup(key string) string {
	cache.Lock()
	defer cache.Unlock()
	return mapping[key]
}
```

The new variable gives more expressive names to the variables related to the cache, and because the `sync.Mutex` field is embeed witin it, its `Lock` and `Unlock` methods are promoted to the unnamed type, allowing us to lock the `cache` with a self-explanatory syntax.


### Method Values and Expressions

Usually we select and call a method in the same expression, as in `p.Distance`, but it's possible to separate these two operations. The selector `p.Distance` yields a ***method value***, a function that binds a method (`Point.Distance`) to a specific receiver value `p`. This function can then be invoked without a receiver value; it needs only the non-receiver arguments.

For example, the function `time.AfterFunc` calls a function value after a specified delay. This program uses it to launch the rocket `r` after 10 seconds:

```go
type Rocket struct { /* ... */
}

func (r *Rocket) Launch() { /*...*/ }

r := new(Rocket)
time.AfterFunc(10*time.Second, func() { r.Launch() })
```

The method values syntax is shorter:

```go
time.AfterFunc(10*time.Second, r.Launch)
```

Related to the method value is the ***method expression***. When calling a method, as opposed to an ordinary function, we must supply the receiver in a special way using the selector syntax. A method expression, written `T.f` or `(*T).f` where `T` is a type, yield a function value with a regular first parameter taking the place of the receiver, so it can be called in the usual way.

In the following example, the variable `op` represents either the addition or the subtraction method of type `Point`, and the `Path.TranslateBy` calls it for each point in the `Path`:

```go
type Point struct{ X, Y float64 }

func (p Point) Add(q Point) Point { return Point{p.X + q.X, p.Y + q.Y} }
func (p Point) Sub(q Point) Point { return Point{p.X - q.X, p.Y - q.Y} }

type Path []Point

func (path Path) TranslateBy(offset Point, add bool) {
	var op func(p, q Point) Point
	if add {
		op = Point.Add
	} else {
		op = Point.Sub
	}
	for i := range path {
		// Call either path[i].Add(offset) or path[i].Sub(offset).
		path[i] = op(path[i], offset)
	}
}
```

### Encapsulation

Go has only one mechnism to control the visibility of names: capitalized identifiers are exported from the package in which they are defined, and uncaptitalized names are not. The same mechanism that limits access to memebers of a package also limits access to the fields of a struct or the methods of a type. As a consequnce, to encapsulation an object, we must make it struct.

```go
type IntSet struct {
	words []uint64
}
```

We could instead define `IntSet` as a slice type as follows:

```go
type IntSet []uint64
```

Although this version of `IntSet` would be essentially equivalent, it would allow clients from other packages to read and modify the slice directly.

Another consequence of this name-based mechanism is that the unit of encapsulation is the package, not the type as in many other languages. The fields of a struct type are visible to all code within the same package. Whether the code appears in a function or a method makes no difference.

Function that merely access or modify interal values of a type, such as the method of the `Logger` type from `log` package, below, are called ***getters*** and ***setters***. However, when naming a getter method, we usually omit the **Get** prefix. This preference for brevity extends to all methods, not just field accessors, and to other redundant prefixes as well, such as `Fetch`, `Find`, and `Lookup`.

```go
package log

type Logger struct {
	flags  int
	prefix string
	// ...
}

func (l *Logger) Flags() int
func (l *Logger) SetFlags(flag int)
func (l *Logger) Prefix() string
func (l *Logger) SetPrefix(prefix string)
```

Encapsulation is not always desirable. By revealing its represention as an `int64` number of nanoseconds, `time.Duration` lets us use all the usual arithmetic and comparsion operations with durations, and even to define constants of this type:

```go
package main

import (
	"fmt"
	"time"
)

const day = 24 * time.Hour

func main() {
	fmt.Printf("%t\n", day) // %!t(time.Duration=86400000000000)
}
```

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
