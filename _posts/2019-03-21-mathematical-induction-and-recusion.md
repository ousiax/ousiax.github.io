---
layout: post
title: '数学归纳法之递归求值'
date: 2019-03-21 15:39:17 +0800
categories: ['Programming']
tags: ['Programming', 'mathematical induction', 'tail call', 'tail recusive']
---

### 数学归纳法 

数学归纳法是证明当 n 等于任意一个自然数时某命题成立。证明分为起始步骤（basics）和递推步骤（induction step）两步：

1. 证明当 n = 1 时，命题成立。
2. 证明如果 n = m 时命题成立，那么可以推导出在 n = m + 1 时命题成立。

### 阶乘

阶乘的定义公式：

```
n! = 1 × 2 × ... × (n-2) × (n - 1) × n
```

阶乘的递推公式：

```
n! = n × (n-1)!
```

我们可以用数学归纳法证明阶乘的递推公式如下：

1. 根据阶乘的定义，当 n = 0 或 n = 1 时，0! = 1 或 1! = 1，命题成立。
2. 假设 n = m 时，m! = m × (m - 1)!， 当 n = m + 1 时，则 (m + 1)! = (m + 1) × [(m + 1) - 1]! = (m + 1) × m!，命题成立。

### 函数和递归

如果我们把 *n* 的阶乘**函数**（function）定义为 *f(n) = n! ，当 n = 0 或 1时，n! = 1* ，则根据阶乘的递推公式，我们有 *f(n) = n × (n - 1)! = n × f(n - 1)* 。也就是说，我们要求值 *f(n)* ，就要求值 *f(n - 1)* ，再求值 *f(n - 2)* ... *f(2)* , 最后求值 *f(1)* ，而这个函数 *f* 调用自己 *f* 的情况，我称之为**递归**（recursion）。

### 递归求解

递归的用途是用于将一个大的问题，重复**分解**为相同或相似的子问题，直到子问题小到可以直接解决。

当子问题需要继续分解时，我们称这种情况为**递归情况**（recursive case）。

当子问题可以直接解决时，递归**终止**并回升，我称这种情况为**递归情况**（base case）。

以阶乘函数为例，*f(0) = 1* 和 *f(1) = 1* 为基本情况，*f(n) = n × f(n - 1)，n > 1* 属于递归情况。

```go
// Go 语言，递归求解阶乘
package main

import (
    "fmt"
)

func main() {
    n := 5
    f := factorial(n)
    fmt.Printf("%d! = %d\n", n, f)
    // Output:
    // n = 5: 5 * factorial(4)
    // n = 4: 4 * factorial(3)
    // n = 3: 3 * factorial(2)
    // n = 2: 2 * factorial(1)
    // n = 1: 1
    // 5! = 120
}

func factorial(n int) int {
    if n == 0 || n == 1 { // base case
        fmt.Printf("n = %d: %d\n", n, 1)
        return 1
    }

    fmt.Printf("n = %d: %d * factorial(%d)\n", n, n, n-1)
    return n * factorial(n-1) // recursive case
}
```

### 尾调用和尾递归

在计算机科学中，**尾调用**（tail call）是指一个函数的最后一个动作是返回一个函数的调用结果的情形，即最后一步新调用的函数返回值被当成当前函数的返回结果。如果**递归函数**（recursion）满足**尾调用**的定义，则称这种递归为**尾递归**（tail recursion）。

```go
// Go 语言，尾递归求解阶乘
package main

import (
    "fmt"
)

func main() {
    n := 5
    f := tail_recursive_factorial(n, 1)
    fmt.Printf("%d! = %d\n", n, f)
    // Output:
    // n = 5: tail_recursive_factorial(4, 5*1)
    // n = 4: tail_recursive_factorial(3, 4*5)
    // n = 3: tail_recursive_factorial(2, 3*20)
    // n = 2: tail_recursive_factorial(1, 2*60)
    // n = 1: 120
    // 5! = 120
}

func tail_recursive_factorial(n, f int) int {
    if n == 0 || n == 1 { // base case
        fmt.Printf("n = %d: %d\n", n, f)
        return f
    }

    fmt.Printf("n = %d: tail_recursive_factorial(%d, %d*%d)\n", n, n-1, n, f)

    return tail_recursive_factorial(n-1, n*f) // recursive case
}
```

### 分治法

在计算机科学中，**分治法**（divide and conquer）是基于多分支递归的一个算法设计模式。分治算法是将问题递归的分解成两个或多个相同或相关类型的子问题，直到这些子问题简单到可以直接求解。最后将子问题的解进行合并得到原始问题的解。分治法是许多高效算法的技术基础，如排序中的归并排序（merge sort）和快速排序（quick sort）等等。

分治法的求解步骤如下：

1. **分解**:原问题为若干子问题，这些子问题是原有问题的规模较小的实例
2. **解决**:这些子问题，递归地求解各子问题。若子问题的规模足够小，则直接求解
3. **合并**:这些子问题的解成原问题的解

快速排序算法：

1. **分解**: 选择主元 **P**(viot), 将待排序序列分割成两个区域（partitions），左边的分区的元素都小于或等于 P，右边的元素大于 P
1. **解决**: 对左右两个分区进行递归的快速排序
1. **合并**: 由于序列是原址排序，分区的操作即为排序的操作，无需合并

```go
// Go 语言，快速排序
package main

import (
    "fmt"
)

func main() {
    s := []int{8, 5, 2, 6, 9, 3, 1, 4, 0, 7}
    fmt.Println("Before:", s)
    quick_sort(s, 0, len(s))
    fmt.Println("After:", s)
    // Output:
    // Before: [8 5 2 6 9 3 1 4 0 7]
    // low: 0, high: 10, pivot: 7, s: [5 2 6 3 1 4 0 7 9 8]
    // low: 0, high: 07, pivot: 0, s: [0 2 6 3 1 4 5 7 9 8]
    // low: 0, high: 07, pivot: 5, s: [0 2 3 1 4 5 6 7 9 8]
    // low: 0, high: 05, pivot: 4, s: [0 2 3 1 4 5 6 7 9 8]
    // low: 0, high: 04, pivot: 1, s: [0 1 3 2 4 5 6 7 9 8]
    // low: 1, high: 04, pivot: 2, s: [0 1 2 3 4 5 6 7 9 8]
    // low: 2, high: 04, pivot: 3, s: [0 1 2 3 4 5 6 7 9 8]
    // low: 5, high: 07, pivot: 6, s: [0 1 2 3 4 5 6 7 9 8]
    // low: 7, high: 10, pivot: 8, s: [0 1 2 3 4 5 6 7 8 9]
    // low: 8, high: 10, pivot: 9, s: [0 1 2 3 4 5 6 7 8 9]
    // After: [0 1 2 3 4 5 6 7 8 9]
}

func quick_sort(s []int, low, high int) {
    if high-low > 1 { // recursive case
        mid := partition(s, low, high)
        quick_sort(s, low, mid)
        quick_sort(s, mid, high)
    }
    // base case
}

func partition(s []int, low, high int) int {
    pivot := s[high-1]

    i := low - 1
    for j := low; j < high-1; j++ {
        if s[j] <= pivot { // compare
            i++
            s[j], s[i] = s[i], s[j] // swap
        }
    }
    s[i+1], s[high-1] = s[high-1], s[i+1]

    fmt.Printf("low: %d, high: %02d, pivot: %d, s: %v\n", low, high, pivot, s)

    return i + 1
}
```

### 调用栈和调用帧

在计算机科学中，**调用栈**（call stack）是一种存储函数调用上下文的数据结构，比如局部变量，函数返回控制点等等。

调用栈是由一系列的**调用帧**（stack frame）的栈结构形式组成。每次发起一个函数调用，都会对新的调用创建新的调用帧。

我们以当 *n = 3* 的阶乘为例，调用栈（bottom to up）如下所示：

```
n = 1, f = 1
------------------
n = 2, f = 2 * f(1)
------------------
n = 3, f = 3 * f(2)
------------------
```

调用栈的大小通常是有限的，如果持续创建调用帧，则会导致调用**栈溢出**（stack overflow）。

比如对于递归调用，如果一直没有触发基本情况进行终止调用，进行递归回升，则会导致栈溢出。

```go
// Go 语言，栈溢出
package main

func main() {
    f()
    // Output:
    // runtime: goroutine stack exceeds 1000000000-byte limit
    // fatal error: stack overflow
}

func f() {
    f()
}
```

### 尾调用优化

我们知道尾递归是一种特性的尾调用，下面看下当 *n = 3* 的阶乘的尾递归调用栈：

```
n = 1, f = 6
------------------
n = 2, f = f(1, 2 * 3)
------------------
n = 3, f = f(2, 3 * 1)
------------------
```

和上述的非尾递归的调用栈比较，我们会发现，尾递归的每次新的调用并不依赖下一个调用帧的返回结果，所以我们可以把这些调用帧减少至一个并重复使用，这种情况就叫做**尾递归优化**或者**尾调用优化**（tail call optimaization）。

### 参考

- [https://en.wikipedia.org/wiki/Mathematical\_induction](https://en.wikipedia.org/wiki/Mathematical_induction)
- [https://en.wikipedia.org/wiki/Factorial](https://en.wikipedia.org/wiki/Factorial)
- [https://en.wikipedia.org/wiki/Recursion\_(computer\_science)](https://en.wikipedia.org/wiki/Recursion_(computer_science))
- [https://www.programmerinterview.com/index.php/recursion/explanation-of-recursion/](https://www.programmerinterview.com/index.php/recursion/explanation-of-recursion/)
- [https://en.wikipedia.org/wiki/Divide-and-conquer\_algorithm](https://en.wikipedia.org/wiki/Divide-and-conquer_algorithm)
- [https://en.wikipedia.org/wiki/Tail\_call](https://en.wikipedia.org/wiki/Tail_call)
- [https://www.programmerinterview.com/index.php/recursion/tail-recursion/](https://www.programmerinterview.com/index.php/recursion/tail-recursion/)
- [https://www.programmerinterview.com/index.php/recursion/tail-call-optimization/](https://www.programmerinterview.com/index.php/recursion/tail-call-optimization/)
- [https://en.wikipedia.org/wiki/Quicksort](https://en.wikipedia.org/wiki/Quicksort)
