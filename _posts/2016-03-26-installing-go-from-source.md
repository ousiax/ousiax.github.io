---
disqus_identifier: 117786748938706904285550144624705447095
layout: post
title: "Installing-Go-from-source"
date: 2016-03-26 00-11-25 +0800
categories: [Go,]
tags: [Go, ]
---
###### Except as noted, the content of this page is licensed under the Creative Commons Attribution 3.0 License, and code is licensed under a BSD license.

[Reference: Installing Go from source](https://golang.org/doc/install/source "Installing Go from source")

## Installing Go from source

* Introduction
* Install Go compiler binaries
* Install Git, if needed
* Fetch the repository
* (Optional) Switch to the master branch
* Install Go
* Testing your installation
* Set up your work environment
* Install additional tools
* Community resources
* Keeping up with releases
* Optional environment variables

### Introduction

Go is an open source project, distributed under a [BSD-style license](https://golang.org/LICENSE). This document explains how to check out the sources, build them on your own machine, and run them. 

Most users don't need to do this, and will instead install from precompiled binary packages as described in [Getting Started](https://golang.org/doc/install), a much simpler process. If you want to help develop what goes into those precompiled packages, though, read on. 

There is two official Go compiler tools chains. This document focused on the *gc* Go compiler and tools. For information on how to work on *gccgo*, a more traditional compiler using the GCC back end, see [Setting up and using gccgo](https://golang.org/doc/install/gccgo). 

The Go compiler support five instrution sets. There are important differences in the quality of the compilers for the different architectures. 

##### amd64 (also known as x86-64)

* amd64 (also known as x86-64)
    A mature implementation. The compiler has an effective optimizer (registerizer) and generates good code (although gccgo can do noticeably better sometimes). 
* 386 (x86 or x86-32)
    Comparable to the amd64 port. 
* arm (ARM)
    Supports Linux, FreeBSD, NetBSD and Darwin binaries. Less widely used than the other ports. 
* arm64 (AArch64)
    Supports Linux and Darwin binaries. New in 1.5 and not as well excercised as other ports. 
* ppc64, ppc64le (64-bit PowerPC big- and little-endian)
    Supports Linux binaries. New in 1.5 and not as well excercised as other ports.

Except for things like low-level operating system interface code, the run-time support is the same in all ports and includes a mark-and-sweep garbage collector, efficient array and string slicing, and support for efficient goroutings, such as stacks that grow and shrink on demand. 

The compilers can target the DragonFly BSD, FreeBSD, Linux, NetBSD, OpenBSD, OS X (Darwin), Plan 9, Solaris and Windows operating systems. The full set of supported combinations is listed in the discussion of [environment variables](https://golang.org/doc/install/source#environment) below.

### Install Go compiler binaries

The Go tool chain is written in Go. To build it, you need a Go compiler installed. The scripts that do the initial build of the tools look for an existing Go tool chain in *$HOME/go1.4*. (This path may be overridden by setting the *GOROOT_BOOTSTRAP* environment variable.) 

Build the tools with Go version 1.4 or a point release (1.4.1, 1.4.2 etc.). Go 1.4 binaries can be found at [the downloads page](https://golang.org/dl/). 

Download the zip or tarball of Go 1.4 for your platform and extract it to *$HOME/go1.4* (or your nominated *GOROOT_BOOTSTRAP* location). 

If you want to install Go 1.5 on a system that not supported by Go 1.4 (such as *linux/pcc64*) you can either use [bootstrap.bash](https://golang.org/src/bootstrap.bash) on a system that can bootstrap GO 1.5 normally, or bootstrap with gccgo 5. 

When run as (for example)
    $ GOOS=linux GOARCH=pcc64 ./bootstrap.bash

*bootstrap.bash* cross-compiles a toolchain for that *GOOS/GOARCH* combination, leaving the resulting tree in *../../go-${GOOS}-${GOARCH}-bootstrap*. That tree can be copied to a machine fo the given target type and used as *GOROOT_BOOTSTRAP* to bootstrap a local build. 

To use gccgo, you need to arrange for *$GOROOT_BOOTSTRAP/bin/go* to be the go tool that comes as part of gccgo 5. 

For example on Ubuntu Vivid: 

    $ sudo apt-get install gccgo-5
    $ sudo update-alternatives --set go /usr/bin/go-5
    $ GOROOT_BOOTSTRAP=/usr ./make.bash

### Install Git, if needed

To perform the next step you must have Git installed. (Check that you have a *git* command before proceeding.) 

If you do not have a working Git installation, follow the instructions on the [Git downloads](http://git-scm.com/downloads) page. 

### Fetch the repository

Go will install to a directory named *go*. Change to the directory that will be its parent and make sure the *go* directory does not exist. Then clone the repository and check out the latest release tag:

    $ git clone https://go.googlesource.com/go
    $ cd go
    $ git checkout go1.5.1

### (Optional) Switch to the master branch

If you intend to modify the go source code, and [contribute your changes](https://golang.org/doc/contribute.html) to the project, then move your repository off the release branch, and onto the master (development) branch. Otherwise, skip this step. 

    $ git checkout master

### Install Go

To build Go distribution, run 

    $ cd src
    $ ./all.bash

(To build under Windows use *all.bat*.) 


If all goes well, it will finish by printing output like: 
> ALL TESTS PASSED
> 
> ---
> Installed Go for linux/amd64 in /home/you/go.
> Installed commands in /home/you/go/bin.
> *** You need to add /home/you/go/bin to your $PATH. ***

where the details on the last few lines reflect the operating system, architecture, and root directory used during the install. 

For more informaiton about ways to control the build, see the discussion of [environment variables](https://golang.org/doc/install/source#environment) below. 

*all.bash* (or *all.bat*) run important tests for Go, which can take more time than simply building Go. If you do not want to run the test suite use *make.bash* (or *make.bat*) instead. 

### Testing your installation

Check that Go is installed correctly by building a simple program. 

Create a file named *hello.go* and put the following program in it: 

    package main
    
    import "fmt"
    
    func main() {
        fmt.Printf("hello, world\n")
    }

Then run it with the *go* tool:
    $go run hello.go
    hello, world

If you see the "hello, world" message then Go is installed correctly. 

### Set up your work enviroment

You're almost done. You just need to do a litte more setup. 

The [How to Write Go Code](https://golang.org/doc/code.html) document provides **essential setup instructions** for using the Go tools. 

### Install additional tools

The source code for several Go tools (including [godoc](https://golang.org/cmd/godoc/)) is kept in [the go.tools repository](https://golang.org/x/tools). To install all of them, run the *go get* command: 

    $ go get golang.org/x/tools/cmd/...

Or if you want to install a specific command (*godoc* in this case): 

    $ go get golang.org/x/tools/cmd/godoc

To install these tools, the *go get* command requires that [Git](https://golang.org/doc/install/source#git) be installed locally. 

You must also have a workspace (*GOPATH*) set up; see [How to Write Go Code](https://golang.org/doc/code.html) for the details. 

**Note**: The *go* command will install the *godoc* binary to *$GOROOT/bin* (or *$GOBIN*) and the *cover* and *vet* binaries to *$GOROOT/pkg/tool/$GOOS_$GOARCH*. You can access the latter commands with "*go tool cover*" and "*go tool vet*". 

### Community resources

The usual community resources such as *#go-nuts* on the [Freenode](http://freenode.net/) IRC server and the [Go Nuts](https://groups.google.com/group/golang-nuts) mailing list have active developers that can help you with problems with your installation or your development work. For those who wish to keep up to date, there is another mailing list, [golang-chekins](https://groups.google.com/group/golang-checkins), that receives a message summarizing each checkin to the Go repository. 

Bugs can be reported using the [Go issue tracker](https://golang.org/issue/new). 

### Keeping up with releases

New release are announced on the [golang-announce](https://groups.google.com/group/golang-announce) mailing list. Each announcement mentions the latest release tag, for instance, *go1.5.1*. 

To update an existing tree to the latest release, you can run: 
    $ cd go/src
    $ git fetch
    $ git checkout <tag>
    $ ./all.bash

What *<tag>* is the version string of the release. 

### Optional enviroment variables

The Go compilation environment can be customized by environment variables. *None is required by the build*, but you may wish to set some to override the defaults. 

* *$GOROOT* 

> The root of the Go tree, often *$HOME/go*. Its values is built into the tree when it is compiled, and defaults to the parent of the directory when *all.bash* was run. There is no need to set this unless you want to switch between multiple local copies of the repository. 

* *$GOROOT_FINAL*
 
> The value assumed by installed binaries and scripts when *$GOROOT* is not set explicitly. It defaults to the value of *$GOROOT*. If you want to build the Go tree in one location but move it elsewhere after the build, set *$GOROOT_FINAL* to the eventual location. 

* *$GOOS* and *$GOARCH*
 
> The name fo the target operating system and compilation architecture. These default to the values of *$GOHOSTOS* and *$GOHOSTARCH* respectively (described below). 
> 
> Choice for *$GOOS* are *darwin* (Mac OS X 10.7 and above and iOS), *dragonfly, freebsd, linux, netbsd, openbsd, plan9, solaris* and *windows*. Choices for *$GOARCH* are *amd64 (640bit x86, the most mature port), *386* (32-bit x86), *arm* (32-bit ARM), *arm64* (64-bit ARM), *ppc64le* (PowerPC 64-bit, little-endian), and *ppc64* (PowerPC 64-bit, big-endian). The valid combinations of *$GOOS* and *$GOARCH* are:
> <table cellpadding="0" border="0">
> <tbody><tr>
> <th width="50"></th><th align="left" width="100"><code>$GOOS</code></th> <th align="left" width="100"><code>$GOARCH</code></th>
> </tr>
> <tr>
> <td></td><td><code>darwin</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>darwin</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>darwin</code></td> <td><code>arm</code></td>
> </tr>
> <tr>
> <td></td><td><code>darwin</code></td> <td><code>arm64</code></td>
> </tr>
> <tr>
> <td></td><td><code>dragonfly</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>freebsd</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>freebsd</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>freebsd</code></td> <td><code>arm</code></td>
> </tr>
> <tr>
> <td></td><td><code>linux</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>linux</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>linux</code></td> <td><code>arm</code></td>
> </tr>
> <tr>
> <td></td><td><code>linux</code></td> <td><code>arm64</code></td>
> </tr>
> <tr>
> <td></td><td><code>linux</code></td> <td><code>ppc64</code></td>
> </tr>
> <tr>
> <td></td><td><code>linux</code></td> <td><code>ppc64le</code></td>
> </tr>
> <tr>
> <td></td><td><code>netbsd</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>netbsd</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>netbsd</code></td> <td><code>arm</code></td>
> </tr>
> <tr>
> <td></td><td><code>openbsd</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>openbsd</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>openbsd</code></td> <td><code>arm</code></td>
> </tr>
> <tr>
> <td></td><td><code>plan9</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>plan9</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>solaris</code></td> <td><code>amd64</code></td>
> </tr>
> <tr>
> <td></td><td><code>windows</code></td> <td><code>386</code></td>
> </tr>
> <tr>
> <td></td><td><code>windows</code></td> <td><code>amd64</code></td>
> </tr>
> </tbody></table>

* *$GOBIN*
 
> The location where Go binaries will be installed. The default is *$GOROOT/bin*. After installing, you will want to arrange to add this directory to your *$PATH*, so you can use the tools. If *$GOBIN* is set, the [go command](https://golang.org/cmd/go) installs all commands there. 

* *$GO386* (for *386* only, default is auto-detected if built on either *386* or *amd64*, *387* otherwise)
 
> This controls the code generated by gc to use either the 387 floating-point unit (set to *387*) or SSE2 instructions (set to *sse2*) for floating point computations.
> * *GO386=387*: use x87 for floating point operations; should support aull x86 chips (Pentium MMX or later).
> * *GO386=sse2*: use SSE2 for floating operations; has better performance than 387, but only avaliable on Pentium 4/Opteron/Athlon 64 or later.

* *$GOARM* (for *arm* only; default is auto-detected if building on the target processor, 6 if not)
 
> This sets the ARM floating point co-processor architecture version the run-time should target. If you are compiling on the target system, its values will be auto-detected.
> * *GOARM=5*: use software floating point; when CPU doesn't have VFP co-processor
> * *GOARM=6*: use VFPv1 only; default if cross compiling; usually ARM11 or better cores (VFPv2 or better is also supported)
> * *GOArM=7*: use VFPv3; usually Cortex-A cores
> If in doubt, leave this variable unset, and adjust it if required when you first run the Go executable. The [GoARM](https://golang.org/wiki/GoArm) page on the [Go community wiki](https://golang.org/wiki) contains further details regarding Go's ARM support. 

Note that *$GOARCH* and *$GOOS* identify the *target* environment, not the environment you are running on. In effect, you are always cross-compiling. By architecture, we mean the kind of binaries that the target environment can run: an x86-64 system running a 32-bit-only operating system must set *GOARCH* to *386*, not *amd64*. 

If you choose to override the defaults, set these variables in your shell profile (*$HOME/.bashrc, $HOME/.profile*, or equivalent). The settings might look something like this: 
 
    export GOROOT=$HOME/go
    export GOARCH=amd64
    export GOOS=linux

although, to reiterate, none of these variables needs to be set to build, install, and develop the Go tree. 
