---
layout: post
title: "Tour of Go - Basics"
date: 2015-09-17 19:08:50 +0800
categories: ['go']
tags: ['go']
---
## Packages, variables, and function

### Packages

Every Go program is made up of packages.

Programs start running in package `main`.

This program is using the packages with import paths `"fmt"` and `"math/rand"`.

By convention, the package name is the same as the last element of the import path. For instance, the `"math/rand"` package comprises files that begin with the statement package `rand`.

***Note***: the environment in which these programs are executed is deterministic, so `rand.Intn` will always return the same number. (To see a different number, seed the number generator; see `rand.Seed`.)

{% highlight go %}
package main

import (
    "fmt"
    "math/rand"
)

func main() {
    fmt.Println("My favorite number is ", rand.Intn(10))
    //fmt.Println(rand.Seed(1))
}
{% endhighlight %}

### Imports

This code groups the imports into a parenthesized, "factored" import statement.

You can also write multiple import statements, like:

    import "fmt"
    import "math"

But it is good style to use the factored import statement.

{% highlight go %}
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Printf("Now you have %g problems.", math.Nextafter(2, 3))
}
{% endhighlight %}

### Exported names

After importing a package, you can refer to the names it exports.

In Go, a name is exported if it begins with *a capital letter*.

`Foo` is an exported name, as is `FOO`. The name foo is not exported.

Run the code. Then rename `math.pi` to `math.Pi` and try it again.

{% highlight go %}
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Println(math.Pi)
}
{% endhighlight %}

### Functions

A function can take zero or more arguments.

In this example, add takes two parameters of type int.

Notice that the type comes after the variable name.

{% highlight go %}
package main

import "fmt"

func add(x int, y int) int {
    return x + y
}

func main() {
    fmt.Println(add(42, 13))
}
{% endhighlight %}

### Functions continued

When two or more consecutive named function parameters share a type, you can omit the type from all but the last.

In this example, we shortened

    x int, y int

to

    x, y int


{% highlight go %}
package main

import "fmt"

func add(x, y int) int {
    return x + y
}

func main() {
    fmt.Println(add(42, 13))
}
{% endhighlight %}

### Multiple results

A function can return any number of results.

The `swap` function returns two strings.

{% highlight go %}
package main

import "fmt"

func swap(x, y string) (string, string) {
	return y, x
}

func main() {
	a, b := swap("hello", "world")
    fmt.Println(a, b)
}
{% endhighlight %}

### Named return values

Go's `return` values may be named and act just like variables.

These names should be used to document the meaning of the return values.

A return statement without arguments returns the current values of the results. This is known as a "naked" return.

Naked return statements should be used only in short functions, as with the example shown here. They can harm readability in longer functions

{% highlight go %}
package main

import "fmt"

func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}

func foo() (x, y, z int) {
	x = 1
	y = 2
	z = 3
	return
}

func main() {
	fmt.Println(split(17))
	fmt.Println(foo())
}
{% endhighlight %}

### Variables

The `var` statement declares a list of variables; as in function argument lists, the type is last.

A `var` statement can be at package or function level. We see both in this example.

{% highlight go %}
package main

import "fmt"

var c, python, java bool

func main() {
    var i int
    fmt.Println(i, c, python, java)
}
{% endhighlight %}

### Variables with initializers

A `var` declaration can include initializers, one per variable.

If an initializer is present, the type can be omitted; the variable will take the type of the initializer.

{% highlight go %}
package main

import "fmt"

var i, j = 1, 2
var x, y = "hello", 100

func main() {
	var c, python, java = true, false, "no!"
	fmt.Println(i, j, c, python, java)
	fmt.Println(x, y)
}
{% endhighlight %}

### Short variable declarations#

Inside a function, the *:=* short assignment statement can be used in place of a `var` declaration with implicit type.

Outside a function, every statement begins with a keyword (`var`, `func`, and so on) and so the *:=* construct is not available.

{% highlight go %}
package main

import "fmt"

func main() {
	var i, j int = 1, 2
	k := 3
	c, python, java := true, false, "no!"

	fmt.Println(i, j, k, c, python, java)
}
{% endhighlight %}

### Basic types

Go's basic types are

    bool

    string

    int  int8  int16  int32  int64
    uint uint8 uint16 uint32 uint64 uintptr

    byte // alias for uint8

    rune // alias for int32
         // represents a Unicode code point

    float32 float64

    complex64 complex128

The example shows variables of several types, and also that variable declarations may be "factored" into blocks, as with import statements.

The `int`, `uint`, and `uintptr` types are usually 32 bits wide on 32-bit systems and 64 bits wide on 64-bit systems. When you need an integer value you should use `int` unless you have a specific reason to use a sized or unsigned integer type.

{% highlight go %}
package main

import (
	"fmt"
	"math/cmplx"
)

var (
	ToBe   bool       = false
	MaxInt uint64     = 1<<64 - 1
	z      complex128 = cmplx.Sqrt(-5 + 12i)
)

func main() {
	const f = "%T(%v)\n"
	fmt.Printf(f, ToBe, ToBe)
	fmt.Printf(f, MaxInt, MaxInt)
	fmt.Printf(f, z, z)
	fmt.Printf(f, f)
}
{% endhighlight %}

### Zero values

Variables declared without an explicit initial value are given their zero value.

The zero value is:

> 0 for numeric types,
> false the boolean type, and
> "" (the empty string) for strings.

{% highlight go %}
package main

import "fmt"

func main() {
    var i int
    var f float64
    var b bool
    var s string
    fmt.Printf("%v %v %v %v\n", i, f, b, s)
}
{% endhighlight %}

### Type conversions

The expression `T(v)` converts the value `v` to the type `T`.

Some numeric conversions:

    var i int = 42
    var f float64 = float64(i)
    var u uint = uint(f)

Or, put more simply:

    i := 42
    f := float64(i)
    u := uint(f)

Unlike in C, in Go assignment between items of different type requires an explicit conversion. Try removing the `float64` or `int` conversions in the example and see what happens.

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

func main() {
	var x, y int = 3, 4
	var f float64 = math.Sqrt(float64(x*x + y*y))
	var z int = int(f)
	fmt.Println(z, y, z)
}
{% endhighlight %}

### Type inference

When declaring a variable without specifying an explicit type (either by using the `:=` syntax or `var =` expression syntax), the variable's type is inferred from the value on the right hand side.

When the right hand side of the declaration is typed, the new variable is of that same type:

    var i int
    j := i // j is an int

But when the right hand side contains an untyped numeric constant, the new variable may be an `int`, `float64`, or `complex128` depending on the precision of the constant:

    i := 42           // int
    f := 3.142        // float64
    g := 0.867 + 0.5i // complex128

Try changing the initial value of `v` in the example code and observe how its type is affected.

{% highlight go %}
package main

import "fmt"

func main() {
	v := "pgg" // change me!
	fmt.Printf("v is of type %T\n", v)
}
{% endhighlight %}

### Constants
 
Constants are declared like variables, but with the `const` keyword.

Constants can be character, string, boolean, or numeric values.

Constants cannot be declared using the := syntax.

{% highlight go %}
package main

import "fmt"

const Pi = 3.14

func main() {
	const World = "世界"
	fmt.Println("Hello", World)
	fmt.Println("Happy", Pi, "Day")

	const Truth = true
	fmt.Println("Go rules?", Truth)
}
{% endhighlight %}

### Numeric Constants

Numeric constants are high-precision values.

An untyped constant takes the type needed by its context.

Try printing `needInt(Big)` too.

{% highlight go %}
package main

import "fmt"

const (
	Big   = 1 << 100
	Small = Big >> 99
)

func needInt(x int) int { return x*10 + 1 }
func needFloat(x float64) float64 {
	return x * 0.1
}

func main() {
	fmt.Println(needInt(Small))
	fmt.Println(needFloat(Small))
	fmt.Println(needFloat(Big))
	fmt.Println(needInt(int(Big)))
}
{% endhighlight %}


## Flow control statements: for, if, else, switch and defe

### For

Go has only one looping construct, the `for` loop.

The basic for loop looks as it does in C or Java, except that the *( )* are gone (they are not even optional) and the `{ }` are required.

{% highlight go %}
package main

import "fmt"

func main() {
	sum := 0
	for i := 0; i < 10; i++ {
		sum += 1
	}
	fmt.Println(sum)
}
{% endhighlight %}

### For continued

As in C or Java, you can leave the pre and post statements empty.

{% highlight go %}
package main

import "fmt"

func main() {
	sum := 1
	for ; sum < 1000 ; {
		sum += sum
	}
	fmt.Println(sum)
}
{% endhighlight %}

### For is Go's "while"

At that point you can drop the semicolons: C's while is spelled for in Go.

{% highlight go %}
package main

import "fmt"

func main() {
	sum := 1
	for sum < 1000 {
		sum += sum
	}
	fmt.Println(sum)
}
{% endhighlight %}

### Forever

If you omit the loop condition it loops forever, so an infinite loop is compactly expressed.

{% highlight go %}
package main

import "fmt"

func main() {
	var i int = 10
	for {
		fmt.Println("Hello TOM!")
		i = i - 1
		if i < 0 {
			break
		}
	}
}
{% endhighlight %}

### If

The `if` statement looks as it does in C or Java, except that the *( )* are gone and the *{ }* are required.

(Sound familiar?)

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

func sqrt(x float64) string {
	if x < 0 {
		return sqrt(-x) + "i"
	}
	return fmt.Sprint(math.Sqrt(x))
}

func main() {
	fmt.Println(sqrt(2), sqrt(-4))
}
{% endhighlight %}

### If with a short statement

Like for, the `if` statement can start with a short statement to execute before the condition.

Variables declared by the statement are only in scope until the end of the `if`.

(Try using `v` in the last `return` statement.)

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

func pow(x, n, lim float64) float64 {
	v := 1
	if v := math.Pow(x, n); v < lim {
		fmt.Println(v)
		return v
	}
	fmt.Println(v)
	return lim
}

func main() {
	fmt.Println(
		pow(3, 2, 10),
		pow(3, 3, 20))
}
{% endhighlight %}

### If and else

Variables declared inside an `if` short statement are also available inside any of the `else` blocks.

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	} else {
		x := 100


		fmt.Println(x)
		fmt.Printf("%g >= %g\n", v, lim)
	}
	// can't use v here, though
	return lim
}

func main() {
	fmt.Println(
		pow(3, 2, 10),
		pow(3, 3, 20),
	)
}
{% endhighlight %}


### Switch

You probably knew what `switch` was going to look like.

A case body breaks automatically, unless it ends with a `fallthrough` statement.

{% highlight go %}
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Print("Go runs on ")
	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Print("%s.", os)
	}
}
{% endhighlight %}

### Switch evaluation order

Switch cases evaluate cases from top to bottom, stopping when a case succeeds.

(For example,

    switch i {
    case 0:
    case f():
    }

does not call `f` if `i==0`.)

**Note**: Time in the Go playground always appears to start at 2009-11-10 23:00:00 UTC, a value whose significance is left as an exercise for the reader.

{% highlight go %}
package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("When's Saturday?")
	today := time.Now().Weekday()
	switch time.Saturday {
	case today + 0:
		fmt.Println("Today.")
	case today + 1:
		fmt.Println("Tomorrow.")
	case today + 2:
		fmt.Println("In two days.")
	default:
		fmt.Println("Too far away.")
	}
}
{% endhighlight %}

Switch with no condition

Switch without a condition is the same as `switch true`.

This construct can be a clean way to write long if-then-else chains.

{% highlight go %}
package main

import (
	"fmt"
	"time"
)

func main() {
	t := time.Now()
	switch {
	case t.Hour() < 12:
		fmt.Println("Good morning!")
	case t.Hour() < 17:
		fmt.Println("Good afternoon!")
	default:
		fmt.Println("Good evening.")
	}
}
{% endhighlight %}

### Defer

A `defer` statement defers the execution of a function until the surrounding function returns.

The deferred call's arguments are evaluated immediately, but the function call is not executed until the surrounding function returns.

{% highlight go %}
package main

import "fmt"

func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}
{% endhighlight %}

### Stacking defers

Deferred function calls are pushed onto a stack. When a function returns, its deferred calls are executed in last-in-first-out order.

To learn more about defer statements read this [blog post](http://blog.golang.org/defer-panic-and-recover).

{% highlight go %}
package main

import "fmt"

func main() {
	fmt.Println("counting")

	for i := 0; i < 10; i++ {
		defer fmt.Println(i)
	}

	fmt.Println("done")
}
{% endhighlight %}


## More types: structs, slices, and map

### Pointers

Go has pointers. A pointer holds the memory address of a variable.

The type `*T` is a pointer to a T value. Its zero value is `nil`.

    var p *int

The *&* operator generates a pointer to its operand.

    i := 42
    p = &i

The _*_ operator denotes the pointer's underlying value.

    fmt.Println(*p) // read i through the pointer p
    *p = 21         // set i through the pointer p

This is known as "dereferencing" or "indirecting".

Unlike C, Go has no pointer arithmetic.

{% highlight go %}
package main

import "fmt"

func main() {
	var p *int
	i := 10
	p = &i
	*p += 10
	fmt.Println(p, *p, &p)
}
{% endhighlight %}

### Structs

A `struct` is a collection of fields.

(And a `type` declaration does what you'd expect.)

{% highlight go %}
package main

import "fmt"

type Vertex struct {
	X int
	Y int
}

type Foo struct {
	B    int
	A, R int
}

func main() {
	fmt.Println(Vertex{1, 2})
	var foo = Foo{1, 2, 3}
	fmt.Println(foo)
}
{% endhighlight %}

### Struct Fields

Struct fields are accessed using a *dot*.

{% highlight go %}
package main

import "fmt"

type Vertex struct {
	X int
	Y int
}

func main() {
	v := Vertex{1, 2}
	v.X = 4
	fmt.Println(v)
}
{% endhighlight %}

### Pointers to structs

Struct fields can be accessed through a struct pointer.

The indirection through the pointer is transparent.

{% highlight go %}
package main

import "fmt"

type Vertex struct {
	X int
	Y int
}

func main() {
	v := Vertex{1, 2}
	p := &v
	p.X = 1e9
	fmt.Println(v)
}
{% endhighlight %}

Struct Literals

A struct literal denotes a newly allocated struct value by listing the values of its fields.

You can list just a subset of fields by using the *Name:* syntax. (And the order of named fields is irrelevant.)

The special prefix *&* returns a pointer to the struct value.

{% highlight go %}
package main

import "fmt"

type Vertex struct {
	X, Y int
}

var (
	v1 = Vertex{1, 2}  // has type Vertex
	v2 = Vertex{X: 1}  // Y:0 is implicit
	v3 = Vertex{}      // X:0 and Y:0
	p  = &Vertex{1, 2} // has type *Vertex
)

func main() {
	fmt.Println(v1, p, v2, v3)
	var v4 = Vertex{Y: 10, X: 11}
	fmt.Println(v4, &v4, *(&v4))
}
{% endhighlight %}

### Arrays

The type *[n]T* is an array of n values of type *T*.

The expression

    var a [10]int

declares a variable *a* as an array of ten integers.

An array's length is part of its type, so arrays cannot be resized. This seems limiting, but don't worry; Go provides a convenient way of working with arrays.

{% highlight go %}
package main

import "fmt"

func main() {
	var a [2]string
	a[0] = "Hello"
	a[1] = "World"
	fmt.Println(a[0], a[1])
	fmt.Println(a)
	var b [2]int
	b[0] = 1
	b[1] = 2
	fmt.Printf("%T,%v", b, b)
}
{% endhighlight %}

### Slices

A *slice* points to an *array* of values and also includes a length.

*[]T* is a slice with elements of type *T*.

{% highlight go %}
package main

import "fmt"

func main() {
	var a = [...]int{1, 2, 3, 4, 5, 6, 7}
	var s1 = a[1:3]
	for i := 0; i < len(s1); i++ {
		fmt.Println(s1[i])
	}
	s1[0] = 10

	fmt.Println(a)
	fmt.Println(s1)
}
{% endhighlight %}

### Slicing slices

Slices can be re-sliced, creating a new *slice* value that points to the same array.

The expression

    s[lo:hi]

evaluates to a slice of the elements from `lo` through `hi-1`, inclusive. Thus

    s[lo:lo]

is empty and

    s[lo:lo+1]

has one element.

{% highlight go %}
package main

import "fmt"

func main() {
	s := []int{2, 3, 5, 7, 11, 13}
	fmt.Println("s ==", s)
	fmt.Println("s[1:4] ==", s[1:4])

	// missing low index implies 0
	fmt.Println("s[:3] ==", s[:3])

	// missing high index implies len(s)
	fmt.Println("s[4:] ==", s[4:])
}
{% endhighlight %}

### Making slices

Slices are created with the `make` function. It works by allocating a zeroed array and returning a slice that refers to that array:

    a := make([]int, 5)  // len(a)=5

To specify a capacity, pass a third argument to `make`:

    b := make([]int, 0, 5) // len(b)=0, cap(b)=5

    b = b[:cap(b)] // len(b)=5, cap(b)=5
    b = b[1:]      // len(b)=4, cap(b)=4


{% highlight go %}
package main

import "fmt"

func main() {
	a := make([]int, 5)
	b := make([]int, 0, 5)
	c := a[:3]
	fmt.Println(c)
	d := b[:2]
	fmt.Println(d)
}
{% endhighlight %}

### Nil slices

The zero value of a slice is `nil`.

A nil slice has a length and capacity of 0.

{% highlight go %}
package main

import "fmt"

func main() {
	var z [1]int
	fmt.Println(z, len(z), cap(z))
	//if z == nil {
    	fmt.Println("nil!")
	//}
}
{% endhighlight %}

### Adding elements to a slice

It is common to append new elements to a slice, and so Go provides a built-in `append` function. The [documentation](http://golang.org/pkg/builtin/#append) of the built-in package describes `append`.

    func append(s []T, vs ...T) []T

The first parameter `s` of `append` is a slice of type *T*, and the rest are T values to append to the slice.

The resulting value of `append` is a slice containing all the elements of the original slice plus the provided values.

If the backing array of `s` is too small to fit all the given values a bigger array will be allocated. The returned slice will point to the newly allocated array.

{% highlight go %}
package main

import "fmt"

func main() {
	var a []int
	printSlice("a", a)

	// append works on nil slices.
	a = append(a, 0)
	printSlice("a", a)

	// the slice grows as needed.
	a = append(a, 1)
	printSlice("a", a)

	// we can add more than one element at a time.
	a = append(a, 2, 3, 4)
	printSlice("a", a)
}

func printSlice(s string, x []int) {
	fmt.Printf("%s len=%d cap=%d %v\n",
		s, len(x), cap(x), x)
}
{% endhighlight %}

### Range

The `range` form of the `for` loop iterates over a `slice` or `map`.

{% highlight go %}
package main

import "fmt"

var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
	for i, v := range pow {
		fmt.Printf("2**%d = %d\n", i, v)
	}
}
{% endhighlight %}

### Range continued

You can skip the index or value by assigning to *_*.

If you only want the index, drop the ", value" entirely.

{% highlight go %}
package main

import "fmt"

func main() {
	pow := make([]float64, 10)
	for i := range pow {
		// invalid operation: 1 << uint(i) (shift of type float64)
		// pow[i] = float64(1<<uint(i)) + 0.1
		j := 1 << uint(i)
		pow[i] = float64(j) + 0.1
	}
	for i := range pow {
		fmt.Printf("%d\n", i)
	}
}
{% endhighlight %}

### Maps

A `map` maps keys to values.

Maps must be created with `make` (not new) before use; the `nil` map is empty and cannot be assigned to.

{% highlight go %}
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m map[string]Vertex

func main() {
	m = make(map[string]Vertex)
	m["Bell Labs"] = Vertex{
		40.68433, -74.39967,
	}
	fmt.Println(m["Bell Labs"])
}
{% endhighlight %}

### Map literals

Map literals are like `struct` literals, but the keys are required. 
{% highlight go %}
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}

func main() {
	fmt.Println(m)
	m2 := make(map[int]string)
	for i := 0; i < 10; i++ {
		m2[i] = "Hello"
	}
}
{% endhighlight %}

### Map literals continued

If the top-level type is just a type name, you can omit it from the elements of the literal.

{% highlight go %}
package main

import "fmt"

type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}

func main() {
	fmt.Println(m)
}
{% endhighlight %}

### Mutating Maps

Insert or update an element in map m:

    m[key] = elem

Retrieve an element:

    elem = m[key]

Delete an element:

    delete(m, key)

Test that a key is present with a two-value assignment:

    elem, ok = m[key]

If key is in `m, ok` is `true`. If not, `ok` is `false` and `elem` is the zero value for the map's element type.

Similarly, when reading from a map if the key is not present the result is the zero value for the map's element type.

*Note*: if `elem` or ok have not yet been declared you could use a short declaration form:

    elem, ok := m[key]


{% highlight go %}
package main

import "fmt"

func main() {
	m := make(map[string]int)

	m["Answer"] = 42
	fmt.Println("The value:", m["Answer"])

	m["Answer"] = 48
	fmt.Println("The value:", m["Answer"])

	delete(m, "Answer")
	fmt.Println("The value:", m["Answer"])

	v, ok := m["Answer"]
	fmt.Println("The value:", v, "Present?", ok)
	m["Question"] = 100
	v, ok := m["Question"]
	fmt.Println("The value:", v, "Present?", ok)
}
{% endhighlight %}

### Function values

Functions are values too.

{% highlight go %}
package main

import (
	"fmt"
	"math"
)

func main() {
	hypot := func(x, y float64) float64 {
		return math.Sqrt(x*x + y*y)
	}

	fmt.Println(hypot(3, 4))
}
{% endhighlight %}

### Function closures

Go functions may be closures. A closure is a function value that references variables from outside its body. The function may access and assign to the referenced variables; in this sense the function is "bound" to the variables.

For example, the `adder` function returns a *closure*. Each closure is bound to its own `sum` variable.

{% highlight go %}
package main

import "fmt"

func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}
{% endhighlight %}

* * *

### References

* Tour of Go,[http://tour.golang.org/](http://tour.golang.org/)
