---
layout: post
title: "Testing in Go Language"
date: 2017-07-01 13-42-56 +0800
categories: ['Go']
tags: ['Go']
disqus_identifier: 88285347216346570168573710594433451269
---

* TOC
{:toc}

Go's approach to testing relies on one command, **go test**, and a set of conventions for writing test functions that **go test** can run. It is effective for pure testing, and it extends naturally to benchmarks and systematic examples for documentation.

### The go test Tool

The **go test** subcommand is a test driver for Go packages that are orgnized according to certain conventions. In a package directory, files whose names end with **\_test.go** are not part of the package ordinarily built by **go build** but are a part of it when built by **go test**.

Within **\*\_test.go** files, three kinds of functions are treated specially: tests, benchmarks, and examples. A ***test function***, which is a function whose name begins with **Test**, exercises some program logic for correct behavior; **go test** calls the test function and report the result, which is either **PASS** or **FAIL**. A ***benchmark function*** has a name beginning with **Benchmark** and measures the performance of some operation; **go test** reports the mean execution time of the operation. And an ***example function***, whose name starts with **Example**, provides machine-checked documentation.

### Test Functions

Each test file must import the **testing** package. Test functions have the following signature:

```go
func TestName(t *testing.T) {
}
```

Test function names must begin with **Test**; the optional suffix **Name** must begin with a capital letter:

```go
func TestSin(t *testing.T) { /* ... */ }
func TestCos(t *testing.T) { /* ... */ }
func TestLog(t *testing.T) { /* ... */ }
```

The **t** parameter provides methods for reporting test failures and logging additional information.

```go
func TestPalindrome(t *testing.T) {
	if !IsPalindrome("detartrated") {
		t.Error(`IsPalindrome("detartrated") = false`)
	}
	if !IsPalindrome("kayak") {
		t.Error(`IsPalindrome("kayak") = false`)
	}
}

func TestNonPalindrome(t *testing.T) {
	if IsPalindrome("palindrome") {
		t.Error(`IsPalindrome("palindrome") = true`)
	}
}

// a table-driven test
func TestIsPalindrome(t *testing.T) {
	var tests = []struct {
		input string
		want  bool
	}{
		{"", true},
		{"a", true},
		{"aa", true},
		{"ab", false},
		{"kayak", true},
	}
	for _, test := range tests {
		if got := IsPalindrome(test.input); got != test.want {
			t.Errorf("IsPalindrome(%q) = %v", test.input, got)
		}
	}
}
```

Test failure messages are usually of the form **"f(x) = y, want z"**, where **f(x)** explains the attempted operation and its input, **y** is the actual result, and **z** is the expected result.

### Randomized Testing

Table-driven tests are convenient for checking that a function works on inputs carefully selected to exercise interesting cases in the logic. Another approach, ***randomized testing***, explores a broader range of inputs by constructing inputs at random.

```go
import "math/rand"

// randomPalindrome returns a palindrome whose length and contents
// are derived from the pseudo-random number generator rng.
func randomPalindrome(rng *rand.Rand) string {
	n := rng.Intn(25) // random length up to 24
	runes := make([]rune, n)
	for i := 0; i < (n+1)/2; i++ {
		r := rune(rng.Intn(0x1000)) // random rune up to '\u0999'
		runes[i] = r
		runes[n-1-i] = r
	}
	return string(runes)
}

func TestRandomPalindromes(t *testing.T) {
	// Initialize a pseudo-random number generator.
	seed := time.Now().UTC().UnixNano()
	t.Logf("Random seed: %d", seed)
	rng := rand.New(rand.NewSource(seed))
	for i := 0; i < 1000; i++ {
		p := randomPalindrome(rng)
		if !IsPalindrome(p) {
			t.Errorf("IsPalindrome(%q) = false", p)
		}
	}
}
```

### Testing a Command

A package named **main** ordinarily produces an executable program, but it can be imported as a library too.

```go
// Echo prints its command-line arguments.
package main

import (
	"flag"
	"fmt"
	"io"
	"os"
	"strings"
)

var (
	n = flag.Bool("n", false, "omit trailing newline")
	s = flag.String("s", " ", "separator")
)

var out io.Writer = os.Stdout // modified during testing

func main() {
	flag.Parse()
	if err := echo(!*n, *s, flag.Args()); err != nil {
		fmt.Fprintf(os.Stderr, "echo: %v\n", err)
		os.Exit(1)
	}
}
func echo(newline bool, sep string, args []string) error {
	fmt.Fprint(out, strings.Join(args, sep))
	if newline {
		fmt.Fprintln(out)
	}
	return nil
}
```

By having **echo** write through the global variable, **out**, not directly to **os.Stdout**, the tests can substitute a different **Writer** implementation that records what was written for later inspection. Here's the test, in file **echo_test.go**:

```go
package main

import (
	"bytes"
	"fmt"
	"testing"
)

func TestEcho(t *testing.T) {
	var tests = []struct {
		newline bool
		sep     string
		args    []string
		want    string
	}{
		{true, "", []string{}, "\n"},
		{false, "", []string{}, ""},
		{true, "\t", []string{"one", "two", "three"}, "one\ttwo\tthree\n"},
		{true, ",", []string{"a", "b", "c"}, "a,b,c\n"},
		{false, ":", []string{"1", "2", "3"}, "1:2:3"},
	}
	for _, test := range tests {
		descr := fmt.Sprintf("echo(%v, %q, %q)",
			test.newline, test.sep, test.args)
		out = new(bytes.Buffer) // captured output
		if err := echo(test.newline, test.sep, test.args); err != nil {
			t.Errorf("%s failed: %v", descr, err)
			continue
		}
		got := out.(*bytes.Buffer).String()
		if got != test.want {
			t.Errorf("%s = %q, want %q", descr, got, test.want)
		}
	}
}
```

Although the package name of the test code is **main** and it defines a **main** function, during testing this package acts as a library that exposes the function **TestEcho** to the test driver; its **main** function is ignored.

### White-Box Testing

One way of categorizing tests is by the level of knowledge they require of the internal workings of the package under test. A ***black-box*** test assumes nothing about the package other than what is exposed by its API and specified by its documentation; the package's internal are opaque. In contrast, a ***white-box*** test has privileged access to the internal functions and data structres of th package and can make observations and changes that an ordinary client can not.

The two approaches are complementary. Black-box tests are usually more robust, needing fewer updates as the software evolves. They also help the test author empathize with the client of the package and can reveal flaws in the API design. In contrast, white-box tests can provide more detailed coverage of the trickier parts of the implementation.

### External Test Packages

Consider the package **net/url**, which provides a URL parser, and **net/http**, which provides a web server and HTTP client library. As we might expect, the higher-level **net/http** depends on the lover-level **net/url**. However, one of the tests in **net/url** is an example demonstrating the interaction between URLs and the HTTP client library. In other words, a test of the lover-level package imports the higher-level packages.

![A test of net/url dep ends on net/http]({{ site.baseurl }}/assets/gopl/a-test-of-net-url-dep-ends-on-net-http.png)

Declaring this test function in the **net/url** package would create a cycle in the package import graph.

We resolve the problem by declaring the test function in an ***external test package***, that is, in a file the **net/url** directory whose package declaration reads **package url_test**. The extral suffix **\_test** is a signal to **go test** that it should build an additional package containing just these files and run its tests.

In terms of the design layers, the external test package is logically higher up than both of the package it depends upon.

![external-test-packages-bre-ak-dep-endency-cycles]({{ site.baseurl }}/assets/gopl/external-test-packages-bre-ak-dep-endency-cycles.png)

We can use the **go list** tool to summarize which Go source files in a package directory are production code, in-pcakges tests, and external tests.

**GoFiles** is the list of files that contain the production code; this are the files that **go build** will include in your application:

```sh
$ go list -f={{.GoFiles}} fmt
[doc.go format.go print.go scan.go]
```

**TestGoFiles** is the list of files that also belong to the **fmt** package, but these files, whose names all end in **\_test.go**, are included only when building tests:

```sh
$ go list -f={{.TestGoFiles}} fmt
[export_test.go]
```

**XTestGoFiles** is the list of files that constitute the external test package, **fmt_test**, so these files must import the **fmt** package in order to use it. Again, they are included only during testing:

```sh
$ go list -f={{.XTestGoFiles}} fmt
[fmt_test.go scan_test.go stringer_test.go]
```

Sometimes an external test package may need privileged access to the internals of the package under test, if for example a white-box test must live in a separate package to avoid an import cycle. In such cases, we use a trick: we add declaration to an in-package **\_test.go** file to expose the necessary internals to the external test. This file thus offers the test a "back door" to the package. If the source file exists only for this purpose and contains no tests itself, it is often called **export_test.go**.

### Writing Effective Tests

Other languages' frameworks provide mechanisms for identifying test functions (often using reflection or metadata), hooks for perforrming "setup" and "teardown" operations before and after the tests run, and libraries of utility functions for asserting common predicates, comparing values, formatting error messages, and aborting a failed test (often using exceptions). Although these mechanisms can make tests very concise, the resulting tests often seem like they are written in a foreign language. Furthermore, although they may report **PASSS** or **FALL** correctly, their manner may be unfriendly to the unfortunate maintainer, with cryptic failure message like "**assert: 0 == 1**" or page after page of stack traces.

A good test does not explode on failure but prints a clear and succinct description of the symptom of the problem, and perhaps other relevant facts about the context. Ideally, the maintainer should not need to read the source code to decipher a test failure. A good test should not give up after one failure but should try to report several errors in a single run, since the pattern of failures may itself be revealing.

The assertion function below compares two values, constructs a generic error message, and stops the program. It's easy to use and it's correct, but when it fails, the error message is almost useless.

```go
import (
	"fmt"
	"strings"
	"testing"
)

// A poor assertion function.
func assertEqual(x, y int) {
	if x != y {
		panic(fmt.Sprintf("%d != %d", x, y))
	}
}
func TestSplit(t *testing.T) {
	words := strings.Split("a:b:c", ":")
	assertEqual(len(words), 3)
	// ...
}
```

In this sense, assertion functions suffer from *premature abstraction*: by treating the failure of this particular test as a mere difference of two integers, we forfeit the opportunity to provide meaningful context. We can provide a better message by starting from the concrete details, as in the example below.

```go
import (
	"strings"
	"testing"
)

func TestSplit(t *testing.T) {
	var tests = []struct {
		s    string
		sep  string
		want int
	}{
		{"a:b:c", ":", 3},
	}
	for _, test := range tests {
		words := strings.Split(test.s, test.sep)
		if got := len(words); got != test.want {
			t.Errorf("Split(%q, %q) returned %d words, want %d",
				test.s, test.sep, got, test.want)
		}
	}
}
```

Now the test reports the function that was called, its inputs, and the significance of the results; it explicitly identifies the actual value and the expectation; and it continues to execute even if this assertion should fail.

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
