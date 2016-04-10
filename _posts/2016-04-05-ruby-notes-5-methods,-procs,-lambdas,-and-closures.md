---
layout: post
title: "Ruby Notes 5 Methods, Procs, Lambdas, and Closures"
date: 2016-04-05 12-51-11 +0800
categories: ['Ruby',]
tags: ['Ruby', 'The Ruby Programming Language']
disqus_identifier: 220874196843994406098196263241972315788
---
### Defining Simple Methods

    # Define a method named 'factorial' with a single parameter 'n'
    def factorial(n)
      if n < 1  # Test the argument value for validity
        raise "argument must be > 0"
      elsif n == 1    # If the argument is 1
        1             # then the value of the method invocation is 1
      else            # Otherwise, the factorial of n is n times
        n * factorial(n-1)  # the factorial of n-1
      end
    end

* Method Return Value

    If a method terminates normally, then the value of the method invocation expression is the value of the last expression evaluated within the method.

    * `return`

        The keyword `return` is used to force a return prior to the end of the method.

        If an expression follows the `return` keyword, then the value of that expression is returned.

        If no expression follows, then the return value is `nil`.

* Invoking a Method on an Object

    Methods are always invoked on an object.

    Within the body of a method, the keyword `self` refers to the object on which the method was invoked.

    If we don't specify an object when invoking a method, then the method is implicitly invoked on `self`.

* Defining Singleton Methods

    *global functions*, *instance methods*, *module methods*, *class methods*

    It is also possible to use `def` statement to define a ***singleton method*** that is avaiable only on a single object. 

    The expression to define a singleton method should be followed by a period and the name of the method to be defined.

        o = "message" # A string is an object
        def o.printme # Define a singleton method for this object
          puts self
        end
        o.printme # Invoke the singleton
*Ruby implementations typically treat Fixnum and Symbol values as immediate values rather than as true object references. For this reason, singleton methods may not be defined on Fixnum and Symbol objects. For consistency, singletons are also prohibited on other Numeric objects.*

* Undefing Method

    Methods are defined with the `def` statement and may be undefined with the `undef` statement.

        def sum(x,y); x+y; end # Define a method puts sum(1,2)          # Use it
        undef sum              # And undefine it

    Interestingly, `undef` can be used to undefine inherited methods, without affecting the definition of the method in the class from which it is inherited.

    `undef` cannot be used to undefine a singleton method.

    Within a class or module, you can also use `undef_method` (a private method of `Module`) to undefine methods.

* Method Names

    By convention, method names begin with a lowercase letter.

    When a method name is longer than one word, the usual convention is to separate the words with underscores `like_this` rather than using mixed case `likeThis`.

    * `=`,`?`,`!`

        Method names may (but are not required to) end with an equals sign, a question mark, or an exclamation point.

        * setter

            An equals sign suffix signifies that the method is a **setter** that can be invoked using assignment syntax.

        * predicates

            Any method whose name ends with a question mark are called **predicates** returns one the Boolean value `true` or `false`, but not required, as any value other than `false` or `nil` works like `true` when a Boolean value is required that answers the question posed by the method invocation.

        * mutators

            Any method whose name ends with an exclamation mark should be used with caution.

            Often, methods that end with an exclamation mark are **mutators**, which alter the internal state of an object.

    * Operator Methods

        Many of Ruby's operators, sucn as +,*, and even the array operator [], are implemented with methods that you can define in your own classes.

    * Method Aliases

        The keyword `alias` serves to define a new name for an existing method.

            alias aka also_known_as     # alias new_name existing_name

        Aliasing is not overloading.

            def hello                       # A nice simple method
              puts "Hello World"            # Suppose we want to augment it...
            end                             
                                            
            alias original_hello hello      # Give the method a backup name
                                            
            def hello                       # Now we define a new method with the old name
              puts "Your attention please"  # That does some stuff
              original_hello                # Then calls the original method
              puts "This has been a test"   # Then does some more stuff
            end

* * *

### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
