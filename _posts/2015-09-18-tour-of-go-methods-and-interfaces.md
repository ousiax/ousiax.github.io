---
layout: post
title: "Tour of Go - Methods and interfaces"
date: 2015-09-18 19-41-03 +0800
categories: ['Go',]
tags: ['Go', 'Tour of Go']
disqus_identifier: 308371642106453527511949979648299400705
---
## Methods and interfaces

### Methods

Go does not have classes. However, you can define methods on struct types.

The method receiver appears in its own argument list between the `func` keyword and the method name.

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := &Vertex{3, 4}
	fmt.Println(v.Abs())
}
{% endhighlight %}

### Methods continued

You can declare a method on any type that is declared in your package, not just struct types.

However, you cannot define a method on a type from another package (including built in types).

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

func main() {
	f := MyFloat(-math.Sqrt2)
	fmt.Println(f.Abs())
	fmt.Printf("%T,%v", f, f)
}
{% endhighlight %}

### Methods with pointer receivers

Methods can be associated with a named type or a pointer to a named type.

We just saw two Abs methods. One on the `*Vertex` pointer type and the other on the `MyFloat` value type.

There are two reasons to use a pointer receiver. First, to avoid copying the value on each method call (more efficient if the value type is a large struct). Second, so that the method can modify the value that its receiver points to.

Try changing the declarations of the `Abs` and `Scale` methods to use `Vertex` as the receiver, instead of `*Vertex`.

The `Scale` method has no effect when `v` is a `Vertex`. `Scale` mutates `v`. When `v` is a value (non-pointer) type, the method sees a copy of the `Vertex` and cannot mutate the original value.

`Abs` works either way. It only reads `v`. It doesn't matter whether it is reading the original value (through a pointer) or a copy of that value.

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := &Vertex{3, 4}
	fmt.Printf("Before scaling: %+v, Abs: %v\n", v, v.Abs())
	v.Scale(5)
	fmt.Printf("After scaling: %+v, Abs: %v\n", v, v.Abs())
}
{% endhighlight %}

### Interfaces

An interface type is defined by a set of methods.

A value of interface type can hold any value that implements those methods.

**Note**: There is an error in the example code on line 22. `Vertex` (the value type) doesn't satisfy `Abser` because the `Abs` method is defined only on `*Vertex` (the pointer type).

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

type Abser interface {
	Abs() float64
}

func main() {
	var a Abser
	f := MyFloat(-math.Sqrt2)
	v := Vertex{3, 4}

	a = f  // a MyFloat implements Abser
	a = &v // a *Vertex implements Abser

	// In the following line, v is a Vertex (not *Vertex)
	// and does NOT implement Abser.
	// a = v

	fmt.Println(a.Abs())
}

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
{% endhighlight %}

### Interfaces are satisfied implicitly

A type implements an interface by implementing the methods. There is no explicit declaration of intent; no "implements" keyword.

Implicit interfaces decouple implementation packages from the packages that define the interfaces: neither depends on the other.

It also encourages the definition of precise interfaces, because you don't have to find every implementation and tag it with the new interface name.

[Package io](http://golang.org/pkg/io/) defines `Reader` and `Writer`; you don't have to.

{% highlight go %}
package main

import (
	"fmt"
	"os"
)

type Reader interface {
	Read(b []byte) (n int, err error)
}

type Writer interface {
	Write(b []byte) (n int, err error)
}

type ReadWriter interface {
	Reader
	Writer
}

func main() {
	var w Writer

	// os.Stdout implements Writer
	w = os.Stdout

	fmt.Fprintf(w, "hello, writer\n")
}
{% endhighlight %}

### Stringers

One of the most ubiquitous interfaces is `Stringer` defined by the `fmt` package.

    type Stringer interface {
        String() string
    }

A `Stringer` is a type that can describe itself as a string. The `fmt` package (and many others) look for this interface to print values.

{% highlight go %}
package main

import "fmt"

type Person struct {
	Name string
	Age  int
}

func (p Person) String() string {
	return fmt.Sprintf("%v (%v years)", p.Name, p.Age)
}

func main() {
	a := Person{"Arthur Dent", 42}
	z := Person{"Zaphod Beeblebrox", 9001}
	fmt.Println(a, z)
}
{% endhighlight %}

### Errors

Go programs express error state with error values.

The error type is a built-in interface similar to `fmt.Stringer`:

    type error interface {
        Error() string
    }

(As with `fmt.Stringer`, the `fmt` package looks for the `error` interface when printing values.)

Functions often return an `error` value, and calling code should handle errors by testing whether the error equals `nil`.

    i, err := strconv.Atoi("42")
    if err != nil {
        fmt.Printf("couldn't convert number: %v\n", err)
    }
    fmt.Println("Converted integer:", i)

A nil `error` denotes success; a non-nil error denotes failure.

{% highlight go %}
package main

import (
	"fmt"
	"time"
)

type MyError struct {
	When time.Time
	What string
}

func (e *MyError) Error() string {
	return fmt.Sprintf("at %v, %s",
		e.When, e.What)
}

func run() error {
	return &MyError{
		time.Now(),
		"it didn't work",
	}
}

func main() {
	if err := run(); err != nil {
		fmt.Println(err)
	}
}
{% endhighlight %}

### Readers

The `io` package specifies the `io.Reader` interface, which represents the read end of a stream of data.

The Go standard library contains [many implementations](http://golang.org/search?q=Read#Global) of these interfaces, including files, network connections, compressors, ciphers, and others.

The `io.Reader` interface has a `Read` method:

    func (T) Read(b []byte) (n int, err error)

`Read` populates the given byte slice with data and returns the number of bytes populated and an error value. It returns an `io.EOF` error when the stream ends.

The example code creates a `strings.Reader`. and consumes its output 8 bytes at a time.

{% highlight go %}
package main

import (
	"fmt"
	"io"
	"strings"
)

func main() {
	r := strings.NewReader("Hello, Reader!")

	b := make([]byte, 8)

	for {
		n, err := r.Read(b)
		fmt.Printf("n = %v err = %v b = %v\n", n, err, b)
		fmt.Printf("b[:n] = %q\n", b[:n])
		if err == io.EOF {
			break
		}
	}
}
{% endhighlight %}

#Web servers#

[Package http](http://golang.org/pkg/net/http/) serves HTTP requests using any value that implements `http.Handler`:

    package http

    type Handler interface {
        ServeHTTP(w ResponseWriter, r *Request)
    }

In this example, the type `Hello` implements `http.Handler`.

Visit [http://localhost:4000/](http://localhost:4000/) to see the greeting.

**Note**: This example won't run through the web-based tour user interface. To try writing web servers you may want to [Install Go](http://golang.org/doc/install/).

{% highlight go %}
package main

import (
	"fmt"
	"log"
	"net/http"
)

type Hello struct{}

func (h Hello) ServeHTTP(
	w http.ResponseWriter,
	r *http.Request) {
	fmt.Fprint(w, "Hello")
}

func main() {
	var h Hello
	err := http.ListenAndServe("localhost:4000", h)
	if err != nil {
		log.Fatal(err)
	}
}
{% endhighlight %}

#Exercise: HTTP Handlers#

Implement the following types and define `ServeHTTP` methods on them. Register them to handle specific paths in your web server.

    type String string
    
    type Struct struct {
        Greeting string
        Punct    string
        Who      string
    }

For example, you should be able to register handlers using:

    http.Handle("/string", String("I'm a frayed knot."))
    http.Handle("/struct", &Struct{"Hello", ":", "Gophers!"})

**Note**: This example won't run through the web-based tour user interface. To try writing web servers you may want to [Install Go](http://golang.org/doc/install/).

{% highlight go %}
package main

import (
	"log"
	"net/http"
)

func main() {
	// your http.Handle calls here
	log.Fatal(http.ListenAndServe("localhost:4000", nil))
}
{% endhighlight %}

### Images

[Package image](http://golang.org/pkg/image/#Image) defines the `Image` interface:

    package image
    
    type Image interface {
        ColorModel() color.Model
        Bounds() Rectangle
        At(x, y int) color.Color
    }

**Note**: the `Rectangle` return value of the `Bounds` method is actually an `image.Rectangle`, as the declaration is inside package `image`.

(See [the documentation](http://golang.org/pkg/image/#Image) for all the details.)

The `color.Color` and `color.Model` types are also interfaces, but we'll ignore that by using the predefined implementations `color.RGBA` and `color.RGBAModel`. These interfaces and types are specified by the [image/color package](http://golang.org/pkg/image/color/)
{% highlight go %}
package main

import (
	"fmt"
	"image"
)

func main() {
	m := image.NewRGBA(image.Rect(0, 0, 100, 100))
	fmt.Println(m.Bounds())
	fmt.Println(m.At(0, 0).RGBA())
}
{% endhighlight %}

* * *

### References

* Tour of Go,[http://tour.golang.org/](http://tour.golang.org/)
