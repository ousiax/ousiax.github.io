---
layout: post
title: "Packages and the Go Tool in Go Language"
date: 2017-06-24 16:32:30 +0800
categories: ['go']
tags: ['go']
---

- TOC
{:toc}

The purpose of any package system is to make the design and maintenance of large programs pratical by grouping related features together into units that can be easily understood and changed, independent of the other packages of the program. This *modularity* allows packages to be shared and reused by different project, distributed within an organization, or make available to the wider world.

Each package defines a distinct name space that encloses its identifiers. Each name is associated with a particular package, letting us choose short, clear names for the types, functions, and so on that we use most often, without creating conflicts with other parts of the program.

Packages also provide encapsulation by controlling which names are visible or exported outside the package.

Go compilation is notably faster than most other compiled languages, even when building from scratch. There are three main reasons for the compiler's speed. First, all imports must be explicitly listed at the beginning of each source file, so the compiler does not have to read and process an entire file to determine its dependencies. Second, the dependencies of a package form a directed acyclic graph, and because there are no cycles, packages can be compiled separately and perhaps in parallel. Finally, the object file for compiled Go package records export information not just for the package itself, but for its dependencies too. When compiling a package, the compiler must read one object file for each import but need not look beyond these files.

### Import Paths

Each package is identified by a unique string called its ***import path***. Import paths are the strings that appear n **import** declarations.

```go
import (
	"encoding/json"
	"fmt"
	"math/rand"

	"golang.org/x/net/html"

	"github.com/go-sql-driver/mysql"
)
```

The Go language specification doesn't define the meaning of these strings or how to determine a package's import path, but leaves these issues to the tools.

For package you intend to share or publish, import paths should be globally unqiue. To avoid conflicts, the import paths of all packages other than those from the standard library should start with the Internaet domain name of the organization that owns or hosts the packages; this make it possible to find packages.

### The Package Declaration

A **package** declaration is required at the start of every Go source file. Its main purpose is to determine the default identifier for that package (called the ***package name***) when it is imported by another package.

Conventionally, the package name is the last segment of the import path, and as a result, two packages may have the same name even though their import paths necessarily differ.

There are three major exceptions to the "last segment" convention. The fist is that a package defining a command (an executable Go program) always has the name **main**, regardless of the package's import path. This is a signal to **go build** that it must invoke the linker to make an executalbe file.

The second exception is that some files in the directory may have the suffix **\_test** on their package name if the file name ends with **\_test.go**. The **\_test** suffix signals to **go test** that it must build both package, and it indicates which files belong to each package.

The third exception is that some tools for dependency management append version number suffixes to package import paths, such as **"gopkg.in/yaml.v2"**. The package name excludes the suffix, so in this case it would be just **yaml**.

### Import Declarations

A Go source file may contain zero or more **import** declarations immediately after the **pacakge** declaration and before the first non-import declaration.

Each import declaration may specify the import path of a single package, or multiple packages in a parenthesized list.

```go
import "fmt"
import "os"

import (
	"fmt"
	"os"
)
```

Imported packages may be grouped by introducing blank lines; such groupings usually indicate different domains.

```go
import (
	"fmt"
	"html/template"
	"os"

	"golang.org/x/net/html"
	"golang.org/x/net/ipv4"
)
```

If we need to import two packages whose names are the same, like **math/rand** and **crypto/rand**, into a third package, the import declaration must specify an alternative name for the least one of them to avoid a confilict. This is called a ***renaming import***.

```go
import (
	"crypto/rand"
	mrand "math/rand" // alternative name mrand avoids conflict
)
```

Choosing an alternative name can help avoid conflicts with common local variable names.

```go
import pathpkg "path" // import the standard "path" package as pathpkg
```

To suppress the "unused import" error we would otherwise encounter, we must use a renaming import in which the altertive name is **\_**, the blank identifier. As usual, the blank identifier can never be referenced. These is known as a ***blank import***.

```go
import _ "image/png" // register PNG decoder
```

The **database/sql** package uses a similar mechanism to let users install just the database drivers they need.

```go
import (
	"database/mysql"

	_ "github.com/go-sql-driver/mysql" // enable support for MySQL
	_ "github.com/lib/pq"              // enable support for Postgres
)

db, err = sql.Open("postgres", dbname) // OK
db, err = sql.Open("mysql", dbname)    // OK
db, err = sql.Open("sqlite3", dbname)  // returns error: unknown driver "sqlite3"
```

### Packages and Naming

When creating a package, keep its name short, but not so short as to be cryptic. The most frequently used packages in the standard library are named **bufio**, **bytes**, **flag**, **fmt**, **http**, **io**, **json**, **os**, **sort**, **sync**, and **time**.

Be descriptive and unambiguous where possible. For example, don't name a utility package **util** when a name such as **imageutil** or **ioutil** is specific yet still concise.

Avoid choosing packages names that are commonly used for related local variables, or you may compel the package's client to use renaming imports, as with the **path** package.

Packages names usually take the singular form. The standard packages **bytes**, **errors**, and **strings** use the plural to avoid hiding the corresponding predeclared types and, in the case of **go/types**, to avoid conflict with a keyword.

When desiging a package, consider how the two parts of a qualified identifier work together, not the member name alone. Here are some characteristic examples:

```go
    bytes.Equal     flag.Int        http.Get        json.Marshal
```

### The Go Tool

The **go** tool combines the features of a diverse set of tools into one command set. Its command-line interface uses the "Swiss army knife" style, with over a dozen subcomands, like **get**, **run**, **build** and **fmt**.

```sh
$ go help
Go is a tool for managing Go source code.

Usage:

        go command [arguments]

The commands are:

        build       compile packages and dependencies
        clean       remove object files
        doc         show documentation for package or symbol
        env         print Go environment information
        bug         start a bug report
        fix         run go tool fix on packages
        fmt         run gofmt on package sources
        generate    generate Go files by processing source
        get         download and install packages and dependencies
        install     compile and install packages and dependencies
        list        list packages
        run         compile and run Go program
        test        test packages
        tool        run specified go tool
        version     print Go version
        vet         run go tool vet on packages

Use "go help [command]" for more information about a command.
```

### Workspace Orgnization

The only configuration most users ever need is the **GOPATH** environment variable, which specifies the root of the workspace. The default **GOPATH** is **$HOME/go**.

A second environment variable, **GOROOT**, specifies the root directory of the Go distribiution, which provides all the packages of the standard library.

### Documenting Packages

The **go doc** tool prints the declaration and doc comment of the entity specified on the command line, which may be a package:

```sh
$ go doc time
package time // import "time"

Package time provides functionality for measuring and displaying time.

The calendrical calculations always assume a Gregorian calendar, with no
leap seconds.

const ANSIC = "Mon Jan _2 15:04:05 2006" ...
func After(d Duration) <-chan Time
func Sleep(d Duration)
func Tick(d Duration) <-chan Time
type Duration int64
    const Nanosecond Duration = 1 ...
...many more...
```

or a package member:

```sh
$ go doc time.Since
func Since(t Time) Duration
    Since returns the time elapsed since t. It is shorthand for
    time.Now().Sub(t).

```

or a method:

```sh
$ go doc time.Duration.Seconds
func (d Duration) Seconds() float64
    Seconds returns the duration as a floating point number of seconds.

```

The tool does not need complete import paths or crrect identifier case.

```sh
$ go doc json.decode
func (dec *Decoder) Decode(v interface{}) error
    Decode reads the next JSON-encoded value from its input and stores it in the
    value pointed to by v.

    See the documentation for Unmarshal for details about the conversion of JSON
    into a Go value.

```

The second tool, confusingly named **godoc**, serves cross-linked HTML pages that provide the same information as **go doc** and much more.

The **godoc** server at **https://golang.org/pkg** covers the standard library. The **godoc** server at **https://godoc.org** has a searchable index of thousands of open-source packages.

You can also run an instance of **godc** in your workspace if you want to browse your own packages.

```sh
$ godoc -http :8000
```

- - -

### References

1. Alan A. A. Donovan, Brian W. Kernighan. The Go Programming Language, 2015.11.
1. [How to Write Go Code](https://golang.org/doc/code.html) - The Go Programming Language
