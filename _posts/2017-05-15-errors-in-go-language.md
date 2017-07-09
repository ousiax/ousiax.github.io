---
layout: post
title: "Errors in Go language"
date: 2017-05-15 13-52-44 +0800
categories: ['Go',]
tags: ['Go',]
disqus_identifier: 152253863621932544857164999968478049190
---

**Some functions always succeed at their task.** For example, `strings.Contains` and `strconv.FromatBool` have well-defined results for all possible argument values and cannot fail—barring catastrophic and unpredictable scenarios like running out of memory, where the sympthom is far from the cause and from which there's little hope of recovery.

**Other functions always succeed so long as their preconditions are met.** For example, the `time.Date` function always constructs a `time.Time` from its components— year, month, and so on— unless the last argument (the time zone) is `nil`, in which case it panics. This panic is a sure sign of a bug in the calling code and should never happen in a well-writen program.

**For many other functions, even in a well-writen program, success is not assured because it depends on factors beyond the programmer's control.** Any function that does I/O, for example, must confront the possibility of error, and only a naive programmer believes a simple read or write cannot fail. Indeed, it's when the most reliable operations fail unexpectedly that we most need to know why.

Errors are thus an important part of a package's API or an application's user interface, and failure is just one of several expected behaviors. This is the approach Go takes to error handling.

A function for which failure is an expected behavior returns an additional result, conventionally the last one. **If the failure has only one possible cause, the result is a boolean, usually call `ok`**, as in this example of a cache lookup that always succeeds unless there was no entry for that key:

```go
value, ok := cache.Lookup(key)
if !ok {
    // ...cache[key] does not exist.
}
```

**More often, and especially for I/O, the failure may have a variety of causes for which the caller will need an explanation. In such cases, the type of the additional result is `error`.**

The built-in type `error` is an interface type, that an `error` may be nil or non-nil, that nil implies success and non-nil implies failure, and that a non-nil `error` has an error message string which we can obtain by calling its `Error` method or print by calling `fmt.Println(err)` or `fmt.Printf("%v", err)`.

Usually when a function returns a non-nil error, its other results are undefined and should be ignored. However, a few functions may return partial results in error cases. For example, if an error occurs while reading from a file, a call to `Read` returns the number of bytes it was able to read *and* an `error` value describing the problem. For correct behavior, some callers may need to process the incomplete data before handling the error, so it is important that such functions clearly document their results.

Go's approach sets it apart from many other languages in which failures are reported using `exceptions`, not ordinary values. Although Go does have an exception mechanism of sorts, the `panic`, it is used only for reporting truly unexpected errors that indicate a bug, not the routine errors that a robust program should be built to expect.

The reason for this design is that exceptions tend to entangle the description of an error with the control flow required to handle it, often leading to an undesirable outcome: routine errors are reported to end user in the form of an incomprehensible stack trace, full of information about the structure of the program but lacking intelligible context about what went wrong.

By contrast, **Go programs use ordinary contro-flow mechanisms like `if` and `return` to respond to errors.** This style undenably demands that more attention be paid to error-handling logic, but that is precisely the point.

- - -

```go
func main() {
	for _, url := range os.Args[1:] {
		links, err := findLinks(url)
		if err != nil {
			fmt.Fprintf(os.Stderr, "findlinks2: %v\n", err)
			continue
		}
		for _, link := range links {
			fmt.Println(link)
		}
	}
}

// findLinks performs an HTTP GET request for url, parses the
// response as HTML, and extracts and returns the links.
func findLinks(url string) ([]string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("getting %s: %s", url, resp.Status)
	}
	doc, err := html.Parse(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("parsing %s as HTML: %v", url, err)
	}
	return visit(nil, doc), nil
}
```

When a function call returns an error, it's the caller's resposibility to check it and take appropriate action. Depending on the situation, there may be a number of possibilities. Let's take a look at five of them.

**First, and most common, is to *propagate* the error, so that a failure in a subroutine becomes a failure of the calling routine.** We saw the above example in the `findLinks` function. If the call to `http.Get` fails, `findLinks` returns the HTTP error to the caller without further ado: 

```go
resp, err := http.Get(url)
if err != nil {
    return nil, err
}
```

In contrast, if the call to `htmp.Parse` fails, `findLinks` does not return the HTML parser's error directly because it lack two crucial pieces of information: that the error occured in the parser, and the URL of the document that was being parsed. In this case, `findLinks` constructs a new error message that includes both pieces of information as well as the underlying parse error:

```go
doc, err := html.Parse(resp.Body)
defer resp.Body.Close()
if err != nil {
    return nil, fmt.Errorf("parsing %s as HTML: %v", url, err)
}
```

The `fmt.Errorf` function formats an error message using `fmt.Sprintf` and returns a new `error` value. We use it to build descriptive errors by successively prefixing additional context information to the orignal error message. When the error is ultimately handled by the program's `main` function, it should provide a clear **causal chain** from the root problem to the overall failure, reminiscent of a NASA accident investigation:

```
genesis: crashed: no parachute: G-switch failed: bad relay orientation
```

Because error message are frequently chained together, message strings should not be capitalized and newlines should be avoided. The resulting errors may be long, but they will be selfcontained when found by tools like `grep`.

When designing error messages, be deliberate, so that each one is meaningful description of the problem with sufficient and relevant detail, and be consistent, so that errors returned b y the same function or by a group of functions in the same package are similar in form and can be dealt with in the same way.

For example, the `os` package guarantees that every error returned by a file operation, such as `os.Open` or the `Read`, `Write`, or `Close` of an open file, describes not just the nature of the failure (permission denied, no such directory, and so on) but also the name of the file, so the caller needn't include this information in the error message it constructs.

In general, the call `f(x)` is responsible for reporting the attempted operation `f` and the argument value `x` as they relate to the context of the error. The caller is responsible for adding further information that it has but the call `f(x)` does not, such as the URL in the call to `html.Parse` above.

Let's move on to the second strategy for handling errors. For errors that represent transient or unpredictable problems, it may make sense to *retry* the failed operation, possibly with a delay between tries, and perhaps with a limit on the number of attempts or the time spent trying before giving up entirely.

```go
// WaitForServer attemts to contact the server of a URL.
// It tries for one minute using exponential back-off.
// It reports an error if all attempts fail.
func WaitForServer(url string) error {
	const timeout = 1 * time.Minute
	deadline := time.Now().Add(timeout)
	for tries := 0; time.Now().Before(deadline); tries++ {
		_, err := http.Head(url)
		if err == nil {
			return nil // success
		}
		log.Printf("server not responding (%s); retrying...", err)
		time.Sleep(time.Second << uint(tries)) // exponential back-off
	}
	return fmt.Errorf("server %s failed to respond after %s", url, timeout)
}
```

Third, if progress is impossible, the caller can print the error and stop the program gracefully, but this course of action should generally be reserved for the main package of a program. Libraries funtions should usually propagate errors to the caller, unless the error is a sign of an internal inconsistency—that is, a bug.

```go
// (In function main.)
if err := WaitForServer(url); err != nil {
    fmt.Fprintf(os.Stderr, "Site is donw: %v\n", err)
    os.Exit(1)
}
```

A more convenient way to achieve the same effect is to call `log.Fatalf`. As with all the `log` functions, by default it prefixes the time and date to the error message.

```go
if err := WaitForServer(url); err != nil {
    log.Fatalf(os.Stderr, "Site is donw: %v\n", err)
}
```

Fourth, in some cases, it's sufficient just to log the error and then continue, perhaps with reduced functionality. Again there's a choice between using the `log` package, which adds the usual prefix:

```go
if err := Ping(); err != nil {
    log.Printf("ping failed: %v; networking disabled", err)
}
```

and printing directly to the standard error stream:

```go
if err := Ping(); err != nil {
fmt.Fprintf(os.Stderr, "ping failed: %v; networking disabled\n", err)
}
```

And fifth and finally, in rare cases we can safely ignore an error entirely:

```go
dir, err := ioutil.TempDir("", "scrath")
if err != nil {
    return fmt.Errorf("failed to create temp dir: %v", err)
}

// ...use temp dir...

os.RemoveAll(dir)   // ignore errors; $TMPDIR is cleaned periodically
```

The call to `os.RemoveAll` may fail, but the program ignores it because the operating system periodically cleans out the temproray directory. In this case, discarding the error was intentional, but the program logic would be the same had we forgotten to deal with it. Get into the habit of considering errors after every function call, and when you deliberately ignore one, document your intention clearly.

Error handling in Go has a particular rhythm. After checking an error, failure is usually dealt with before success. If failure causes the function to return, the logic for success is not indented with an `else` block but follows at the outer level. Function tend to exhibit a common structure, with a series of initial checks to reject errors, followed by the substance of the function at the end, minimally indented.

### The error Interface

The type of **error** is an interface type with a single method that returns an error message:

```go
type error interface {
	Error() string
}
```

The simplest way to create an **error** is by calling **errors.New**, which return a new **error** for a given error message. The entire **errors** package is only four lines long:

```go
package errors

func New(text string) error { return &errorString{text} }

type errorString struct{ text string }

func (e *errorString) Error() string { return e.text }
```

The underlying type of **errorString** is a struct, not a string, to protect its representation from inadvertent (or premeditated) update.

Calls to **errors.New** are relatively infrequent because there's a conveninent wrapper function, **fmt.Errorf**, that does string formatting too.

```go
package fmt

import "errors"

func Errorf(format string, args ...interface{}) error {
	return errors.New(Sprintf(format, args...))
}
```

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
