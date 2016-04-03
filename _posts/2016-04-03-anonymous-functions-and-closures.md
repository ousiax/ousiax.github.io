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

*Wiki*: In programming languages, closures (also lexical closures or function closures) are a technique for implementing lexically scoped name binding in languages with first-class functions. Operationally, a closure is a record storing **a function together with an environment**: a mapping associating each free variable of the function (variables that are used locally, but defined in an enclosing scope) with the value or storage location to which the name was **bound when the closure was created**. A closure-***unlike a plain function***-allows the function to access those ***captured variables*** through the closure's reference to them, even when the function is invoked outside their scope.

*MDN*: Closures are functions that refer to independent (free) variables. In other words, the function defined in the closure 'remembers' the environment in which it was created.

*Keypoints*

* *a function together with an environment*
* *unlike a plain function*
* *variables that are used locally, but defined in an enclosing scope which name was bound when the closure was created*

#### Lexical scoping

{% highlight js %}
function init() {
    var name = "Mozilla"; // name is a local variable created by init
    function displayName() { // displayName() is the inner function, a closure
        alert (name); // displayName() uses variable declared in the parent function    
    }
    displayName();    
}
init();
{% endhighlight %}

`init()` creates a local variable `name` and then a function called `displayName()`. `displayName()` is an inner function that is defined inside `init()` and is only available within the body of that function. `displayName()` has no local variables of its own, however it has access to the variables of outer functions and so can use the variable `name` declared in the parent function.

#### Closure
{% highlight js %}
function makeFunc() {
  var name = "Mozilla";
  function displayName() {
    alert(name);
  }
  return displayName;
}

var myFunc = makeFunc();
myFunc();
{% endhighlight %}

This code still works may seem unintuitive. Normally, the local variables within a function only exits for the duration of that function's execution. Once `makeFunc()` has finished executing, it is reasonable to expect that the `name` variable will no longer be accessible. Since the code still works as expected, this is obviously not the case.


The solution to this puzzle is that `myFunc` has become a *closure*. A closure is a special kind of object that combines two things: a function, and the environment in which that function was created. The environment consists of any local variables that were in-scope at the time that the closure was created. In this case, `myFunc` is a closure that incorporates both the `displayName` function and the "Mozilla" string that existed when the closure was created.

A closure lets you associate some data (the environment) with a function that operates on that data. This has obvious parallels to the object oriented programming, where objects allow us to associate some data (the object's properties) with on or more methods.

Consequently, you can use a closure anywhere that you might normally use an object with only a single method.

#### Enulating private methods with closures

{% highlight js %}
var makeCounter = function() {
  var privateCounter = 0;
  function changeBy(val) {
    privateCounter += val;
  }
  return {
    increment: function() {
      changeBy(1);
    },
    decrement: function() {
      changeBy(-1);
    },
    value: function() {
      return privateCounter;
    }
  }  
};

var counter1 = makeCounter();
var counter2 = makeCounter();
alert(counter1.value()); /* Alerts 0 */
counter1.increment();
counter1.increment();
alert(counter1.value()); /* Alerts 2 */
counter1.decrement();
alert(counter1.value()); /* Alerts 1 */
alert(counter2.value()); /* Alerts 0 */
{% endhighlight %}

#### Creating closures in loops: A common mistake

* *JavaScript*
{% highlight js %}
<!DOCTYPE html>
<html>
<head>
    <title>Closures</title>
    <meta charset="utf-8">
    <script type="text/javascript">
        window.onload = function() {
            var lists = document.getElementsByTagName("li");
            
            for(var i = 0; i < lists.length; i++) {
                // Three closures have been created, but each one shares the same single environment.
                // By the time the onclick callbacks are executed, the loop has run its course
                // and the i variable (shared by all the closures) has been left pointing to the last with a value 2.
                lists[i].onclick = function(){
                    alert(i); // not work as expected.
                };
            }
            
            // solution 1
            // for(var i = 0; i < lists.length; i++) {
            //     var f = function(j) {
            //         lists[j].onclick = function(){
            //             alert(j);
            //         };
            //     }(i);
            // }
            
            // solution 2
            // for(var i = 0; i < lists.length; i++) {
            //     var f = function() {
            //         var j = i;
            //         lists[j].onclick = function(){
            //             alert(j);
            //         };
            //     }();
            // }
        };
    </script>
</head>
<body>
<ul>
    <li>0</li>
    <li>1</li>
    <li>2</li>
</ul>
</body>
</html>
{% endhighlight %}

* *golang*

{%highlight go %}
func Serve(queue chan *Request) {
    for req := range queue {
        sem <- 1
        go func() {
            process(req) // Buggy; see explanation below.
            <-sem
        }()
    }
}
{% endhighlight %}

The bug is that in a Go *for loop*, *the loop variable is reused for each iteration*, so the `req` variable is shared across all goroutines.

Here's one way to do that, passing the value of `req` as an argument to the *closure* in the goroutine:

{% highlight go %}
func Serve(queue chan *Request) {
    for req := range queue {
        sem <- 1
        go func(req *Request) {
            process(req)
            <-sem
        }(req)
    }
}
{% endhighlight %}

Another solution is just to create a new variable with the same name, as the belows:
{% highlight go %}
Serve(queue chan *Request) {
    for req := range queue {
        req := req // Create new instance of req for the goroutine.
        sem <- 1
        go func() {
            process(req)
            <-sem
        }()
    }
}
{% endhighlight %}

#### Performance considerations

It is unwise to unnecessarily create functions within other function if closures are not needed for a particular task, as it will negatively affect script performance both in terms of processing speed and memory consumption.

#### Implementation and theory

Closures are typically implemented with a special data structure that contains a pointer to the function code, plus a representation of the function's lexical environment (i.e., the set of available variables) at the time when the closure was created. The referencing environment binds the non-local names to the corresponding variables in the lexical environment at the time the closure is created, additionally extending their lifetime to at least as long as the lifetime of the closure itself. When the closure is entered at a later time, possibly with a different lexical environment, the function is executed with its non-local variables referring to the ones captured by the closure, not the current environment.

* * *

#### References

* [Closures](https://developer.mozilla.org/en/docs/Web/JavaScript/Closures)
* [Closure (computer programming)](https://en.wikipedia.org/wiki/Closure_%28computer_programming%29)
* [Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus)
* [Anonymous function](https://en.wikipedia.org/wiki/Anonymous_function)
* [Functional programming](https://en.wikipedia.org/wiki/Functional_programming)
* [Subroutine](https://en.wikipedia.org/wiki/Subroutine)
* [What is the difference between a 'closure' and a 'lambda'?](http://stackoverflow.com/questions/220658/what-is-the-difference-between-a-closure-and-a-lambda)
* [Effective Go](https://golang.org/doc/effective_go.html)
* [JavaScript closure inside loops – simple practical example](http://stackoverflow.com/questions/750486/javascript-closure-inside-loops-simple-practical-example)
