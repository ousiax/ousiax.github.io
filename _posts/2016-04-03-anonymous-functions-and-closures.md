---
layout: post
title: "Anonymous functions and closures"
date: 2016-04-03 06-36-48 +0800
categories: ['Programming languages',]
tags: ['Programming Languages', 'Lambda', 'Closure']
disqus_identifier: 253207475315520978685533137076644128787
---
### Anonymous functions & lambda expression

An **anonymous funciton** (also **function literal** or **lambda abstraction**) is a *function* definition that is not *bound* to an *identifier*. In other world, an anonymous function is only a function without function name.

Anonymous functions are sometimes called lambda expressions.

When attempting to sort in a non-standard way it may be easier to contain the comparison logic as an anonymous function instead of creating a named function.

* Python

{% highlight python %}
a = ['house', 'car', 'bike']
>>> a.sort()
>>> print a
['bike', 'car', 'house']
>>> a.sort(lambda x,y: cmp(len(x), len(y)))
>>> print a
['car', 'bike', 'house']
{% endhighlight %}

* Go

{% highlight go %}
package main

import (
    "fmt"
)

func main() {

    f := func(name string) {
        fmt.Printf("Hello, %s\n", name)
    }

    f("World")
}
{% endhighlight %}

* ES6
{% highlight javascript %}
alert((x => x*x)(10));
{% endhighlight %}

### Closures

*Wiki*: In programming languages, closures (also lexical closures or function closures) are a technique for implementing lexically scoped name binding in languages with first-class functions. Operationally, a closure is a record storing a function together with an environment: a mapping associating each free variable of the function (variables that are used locally, but defined in an enclosing scope) with the value or storage location to which the name was bound when the closure was created. A closure-***unlike a plain function***-allows the function to access those ***captured variables*** through the closure's reference to them, even when the function is invoked outside their scope.

*MDN: Closures are functions that refer to independent (free) variables. In other words, the function defined in the closure 'remembers' the environment in which it was created.*

*Keypoint*

* *a function together with an environment*
* *unlike a plain function*
* *variables that are used locally, but defined in an enclosing scope which name was bound when the closure was created*

## To be continued ...


* * *

#### References

* [Closures](https://developer.mozilla.org/en/docs/Web/JavaScript/Closures)
* [Closure (computer programming)](https://en.wikipedia.org/wiki/Closure_%28computer_programming%29)
* [Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus)
* [Anonymous function](https://en.wikipedia.org/wiki/Anonymous_function)
* [Lambda Expressions (C# Programming Guide)](https://msdn.microsoft.com/en-us/library/bb397687.aspx)
* [The Java™ Tutorials Lambda Expressions](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html)
* [Functional programming](https://en.wikipedia.org/wiki/Functional_programming)
* [Subroutine](https://en.wikipedia.org/wiki/Subroutine)
* [What is the difference between a 'closure' and a 'lambda'?](http://stackoverflow.com/questions/220658/what-is-the-difference-between-a-closure-and-a-lambda)
