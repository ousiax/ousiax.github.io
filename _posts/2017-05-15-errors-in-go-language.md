---
layout: post
title: "Errors in Go language"
date: 2017-05-15 13-52-44 +0800
categories: ['Go',]
tags: ['Go',]
disqus_identifier: 152253863621932544857164999968478049190
---

Some functions always succeed at their task. For example, `strings.Contains` and `strconv.FromatBool` have well-defined results for all possible argument values and cannot fail—barring catastrophic and unpredicatable scenarios like running out of memory, where the sympthom is far from the cause and from which there's little hope of recovery.

Other functions always succeed so long as their preconditions are met. For example, the `time.Data` function always constructs a `time.Time` from its components— year, month, and so on— unless the last argument (the time zone) is `nil`, in which case it panics. This panic is a sure sign of a bug in the calling code and should never happen in a well-writen program.

For many other functions, even in a well-writen program, success is not assured because it depends on factors beyond the programmer's control. Any function that does I/O, for example, must confront the possibility of error, and only a naive programmer believes a simple read or write cannot fail. Indeed, it's when the most reliable operations fail unexpectedly that we most need to know why.

Errors are thus an important part of a package's API or an application's user interface, and failure is just one of several expected behaviors. This is the approach Go takes to error handling.

A function for which failure is an expected behavior returns an additional result, conventionally the last one. If the failure has only one possible cause, the result is a boolean, usually call `ok`, as in this example of a cache lookup that always succeeds unless there was no entry for that key:

```go
value, ok := cache.Lookup(key)
if !ok {
    // ...cache[key] does not exist.
}
```

More often, and especially for I/O, the failure may have a variety of causes for which the caller will need an explanation. In such cases, the type of the additional result is `error`.

The built-in type `error` is an interface type, that an `error` may be nil or non-nil, that nil implies success and non-nil implies failure, and that a non-nil `error` has an error message string which we can obtain by calling its `Error` method or print by calling `fmt.Println(err)` or `fmt.Printf("%v", err)`.

Usually when a function returns a non-nil error, its other results are undefined and should be ignored. However, a few functions may return partial results in error cases. For example, if an error occurs while reading from a file, a call to `Read` returns the number of bytes it was able to read *and* an `error` value describing the problem. For correct behavior, some callers may need to process the incomplete data before handling the error, so it is important that such functions clearly document their results.

Go's approach sets it apart from many other languages in which failures are reported using `exceptions`, not ordinary values. Although Go does have an exception mechanism of sorts, the `panic`, it is used only for reporting truly unexpected errors that indicate a bug, not the routine errors that a robust program should be built to expect.

The reason for this desigin is that exceptions tend to entangle the description of an error with the control flow required to handle it, often leading to an undesirable outcome: routine errors are reported to end user in the form of an incomprehensible stack trace, full of information about the structure of the program but lacking intelligible context about what went wrong.

By contrast, Go programs use ordinary contro-flow mechanisms like `if` and `return` to respond to errors. This style undenably demands that more attention be paid to error-handling logic, but that is precisely the point.
