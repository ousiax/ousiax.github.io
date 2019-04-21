---
layout: post
title: 匿名函数
date: 2019-04-21 17:01:16 +0800
categories: ['programming']
tags: ['programming']
---

### 匿名函数

在计算机编程语言中，匿名函数（anonymous function），又称 lambda 表达式（lambda expression），lambda 抽象（lambda abstraction）或函数字面量（function literal），是在声明定义时没有绑定标识符的一种函数。简单点说，匿名函数就是没有名字的函数（不配拥有姓名？）。

匿名函数常见的 3 中使用场景：

- 头等函数（first-class function）
- 闭包（closures）
- 柯里化（currying）
- 高阶函数（higher-order function）

### 头等函数

头等函数是指在编程语言中，可以把一个函数作为参数传入其他的函数，并且可以把函数作为其他函数的返回值，以及可以把函数赋值给变量的函数。

以 Go 语言为例，说明如下：

```go
package main

import (
    "fmt"
)

func main() {
    sayHi()()

    // anonymous function: a function definition without name
    cmp := func(a, b int) int {
        return b - a
    }

    x := 4
    y := 21
    // pass function `cmp` as arguments to function `max`
    m := max(x, y, cmp)
    fmt.Printf("max(%d, %d) = %d\n", x, y, m)

    // output:
    // Hi!
    // max(4, 21) = 4
}

// return function as value from other function
func sayHi() func() {
    return func() {
        fmt.Println("Hi!")
    }
}

// pass function as argument to other function
func max(x, y int, cmp func(a, b int) int) int {
    if cmp(x, y) > 0 {
        return x
    }

    return y
}
```

### 闭包

闭包函数是一种具有状态或环境的函数，类似于面向对象语言中的函数。

以 Go 语言为例：

```go
package main

import (
    "fmt"
)

func main() {
    sq := squares()

    fmt.Println(sq())
    fmt.Println(sq())
    fmt.Println(sq())

    // Output:
    // 1
    // 4
    // 9
}

// Closures: function values are not just code but can have state
func squares() func() int {
    var x int
    return func() int {
        // the local variable `x` was captured
        x++
        return x * x
    }
}
```

```go
package main

import (
    "fmt"
    "time"
)

// A pitfall of Go's lexical scope rule
// that can cause surprising results.
//
// All goroutine function values created by `for` loop 
// `capture` and share the same variable that is an 
// addressable storage location, not its value at that 
// particular moment. 
func main() {
    list := []int{2019, 4, 21}

    for _, v := range list {
        go func() {
            fmt.Println(v)
        }()
    }

    time.Sleep(100 * time.Millisecond)

    for _, v := range list {
        // pass `v` as an argument
        go func(x int) {
            fmt.Println(x)
        }(v)
    }

    time.Sleep(100 * time.Millisecond)

    for _, v := range list {
        v := v // declares inner `v`, intialized to outer `v`
        go func() {
            fmt.Println(v)
        }()
    }

    time.Sleep(100 * time.Millisecond)

    // Output:
    // 21
    // 21
    // 21
    // 2019
    // 21
    // 4
    // 2019
    // 4
    // 21
}
```

### 柯里化

柯里化是一种将函数的多个输入参数转换为一系列具有单一输入参数的一种技术。

以 Go 语言为例：

```go
package main

import (
    "fmt"
)

func main() {
    add4 := func(x int) int {
        return add(x, 4)
    }

    fmt.Println(add4(1))
    fmt.Println(add4(2))
    fmt.Println(add4(3))

    // Output:
    // 5
    // 6
    // 7
}

func add(x, y int) int {
    return x + y
}
```

### 高阶函数

高阶函数是可以被传入一个或多个函数作为参数输入的函数。

以 Go 语言为例：

```go
package main

import (
    "fmt"
    "strings"
)

func main() {
    s := strings.Map(
        func(r rune) rune {
            return r + 1
        },
        "HAL-9000")
    fmt.Println(s)

    // Output:
    // IBM.:111
}
```

另一个 Python 的例子:

```py
#!/usr/bin/env python
# -*- coding: utf-8 -*-

def main():
  s = [0, 1, 2, 3]
  s1 = map(lambda x: x * x, s)
  print (s)
  print (s1)
  # Output:
  # [0, 1, 2, 3]
  # [0, 1, 4, 9]

if __name__ == '__main__':
  main()
```

### 参考

- https://en.wikipedia.org/wiki/Anonymous\_function
