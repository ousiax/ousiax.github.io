---
layout: post
title: "Ruby Notes 1 Overview"
date: 2016-04-04 20-27-17 +0800
categories: ['Ruby']
tags: ['Ruby']
disqus_identifier: 304705226039501129190960351359847979001
---

1. Ruby Is Object-Oriented

    Every value is an object, even simple numeric literals and the values **true**, **false**, and **nil** (nil is Ruby's null).

1. Blocks and Iterators

    There are a special kind of method known as *iterator*, and they like loops. The code within curly braces—known as *blok*—is associated with the method invocation and serves as the body of the loop.

        3.times { print "Ruby! " }   # Prints "Ruby! Ruby! Ruby!"
        1.upto(9) {|x| print x }     # Prints "123456789"

1. Expressions and Operators in Ruby

    Ruby's syntax is expression—oriented.Control strutures such as **if** that would be called statements in other languages are actually expressions in Ruby.

        minimum = if x < y then x else y end

    Although all "statements" in Ruby are actually expression, they do not all return meaningful values.

    Many of Ruby's operators are implemented as methods, and classes can define (or redefine) these methods however they want.

1. Methods

    Methods are defined with the **def** keyword. The return value of a method is the value of the last expression evaluated in its body:

        def square(x)   # Define a method named square with one parameter x
            x*x         # Return x squared
        end             # End of method

    In Ruby, parentheses of function and method invocations are usually optional and commonly omitted, especially when the method being invoked takes no arguments.

        > square 2
        => 4
        > square(2)
        => 4

1. Assignment

    The (**nonoverridable**) = operator in Ruby assigns a value to a variable:

        x = 1
        x += 1  # Increment x: note Ruby does not have ++.
        x -= 1  # Decrement x: no -- operator, either.
        a, b = b, a # Swap the value of two varibles

1. Punctuation Suffixes and Prefixes

    * `=`

    Methods that end with an equals sign (=) are special because Ruby allows them to be invoked using assignment syntax.

    * `?`
        A question mark (?) is used to mark predicates—methods that return a Boolean value.

    * `!`

        An exclamation mark at the end of a method name is used to indicate that caution is required with the use of the method.

        Usually, the method without the exclamation mark returns a modified copy of the object it is invoked on, and the one with exclamation mark returns a mutator method that alerts the object in place.

    * `$`, `@`, `@@`

        *global variable* are prefixed with $, instance variables are prefixed with @, and class varibles are prefixed with @@.

1. Regexp and Range

    A **Regexp** (regular expression) object describes a textual pattern.

    A **Range** represents the values (usually integers) between two endpoints.

        /[Rr]buy/       # Matches "Ruby" or "ruby"
        /\d{5}          # Matches 5 consecutive digits
        1..3            # All x where 1 <= x <= 3
        1...3           # All x where 1 <= x < 3

    Regexp and Range objects define the normal `==` operator for testing equality. In addition they also define the `===` operator for testing matching and membership. Ruby's case statement matches its expression agains each of the possible cases using `===`, so this operator is often called the ***case equality operator***.

        > (0..2) === 1
        => true
        > 1 === (0..2)
        => false

1. Classes and Modules

    * `.`, `::`, `#`

        Normally, you can separate a class or module name from a method name with a period `.`. If a class defines a class method and an instance method by the same name, you must instead use `::` to refer to the class method or `#` to refer to the instance method.

            ri Array
            ri Array.sort
            ri Hash#each
            ri Math::sqrt


    * ***Class***
            
            class Sequence
                include Enumerable
                
                def initialize(from, to, by)
                    @from, @to, @by = from, to , by
                end
                
                def each
                    x = @from
                    while x <= @to
                        yield x # Pass x to the block associated with the iterator
                        x += @by
                    end
                end
            end
                
   * ***Modules***
            
            module Sequences                        # Begin a new module
                def self.fromtoby(from, to, by)     # A singleton method of the module
                    x = from
                    while x <= to
                        yield x
                        x += by
                    end
                end
            end

1. Ruby Surprises

    * Ruby's strings are mutable.

    * Conditional expression often evaluate to **true** or **false**, but not required. The value of `nil` is treated the same as `false`, and **any other value is the same as true**.

1. The Ruby Interpreter

    ***MRI***, ***JRuby***, ***IronRuby***, ***Rubinius***, ***Cardinal***

1. The Ruby Toolset

    * Interactive Ruby with **irb**

    * Viewing Ruby Documentation with **ri**

    * Ruby Package Management with **gem**

    * **Bundler** provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed. 

    * **RVM** is a command-line tool which allows you to easily install, manage, and work with multiple ruby environments from interpreters to sets of gems. 

1. Specifying Program Encoding

    By default, the Ruby interpreter assumes that program are encoded in ASCII.

    * **Encoding comments**
    
        1. `# coding: utf-8`
    
        1. `# -*- coding: utf-8 -*-`
    
        1. `# vi: set fileencoding=utf-8 :`
    
    * **Source Encoding and Default External Encoding**
    
        1. Source encoding are typically set with coding comments to tell the Ruby interpeter how to read characters in a script.
    
        1. The default external encoding is something that Ruby use by default when reading from files and streams. The default external encoding is global to the Ruby process and does not change from file to file.

1. File Structure

        #!/usr/bin/ruby -w          shebang comment
        # -*- coding: utf-8 -*-     coding comment
        require 'socket'            load networking library
        
        ...                         program code goes here
        
        __END__                     mark end of code program data goes here
        ...

1. Comments

    Comments in Ruby begin with a `#` character and continue to the end of the line.

    Ruby has *no* quivalent of the C-style `/*...*/` comment.

    * **Embedded documents**

        Ruby supports another style of multiline comment known as ***embedded doucment*** that an text that apears between `=begin` and `=end`.

            =begin Someone needs to fix the broken code below!
                Any code here is commented out
            =end

    * **Documentation comments**

        Ruby programs can include embedded API documentation as specially formatted (e.g. Markdown) comments that precede method, class, and module definitions.

* * *

### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)

* [Ruby Version Manager (RVM)](https://rvm.io/)

* [Bundler: The best way to manage a Ruby application's gems](http://bundler.io/)

* [bundler vs RVM vs gems vs RubyGems vs gemsets vs system ruby](http://stackoverflow.com/questions/15586216/bundler-vs-rvm-vs-gems-vs-rubygems-vs-gemsets-vs-system-ruby)
