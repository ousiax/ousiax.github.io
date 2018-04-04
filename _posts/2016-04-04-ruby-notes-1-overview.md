---
layout: post
title: "Ruby Notes 1 Overview"
date: 2016-04-04 20-27-17 +0800
categories: ['Ruby']
tags: ['Ruby', 'The Ruby Programming Language']
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

            $ irb 
            irb(main):001:0> puts 'Hello, Ruby'
            Hello, Ruby
            => nil

    * Viewing Ruby Documentation with **ri**

            ri Array
            ri Array.sort
            ri Hash#each
            ri Math::sqrt

    * Ruby Package Management with **gem**

            gem list             # List installed gems
            gem enviroment       # Display RubyGems configuration information
            gem update rails     # Update a named gem
            gem update           # Update all installed gems
            gem update --system  # Update RubyGems itself
            gem uninstall rails  # Remove an installed gem

    * **RVM** is a command-line tool which allows you to easily install, manage, and work with multiple ruby environments from interpreters to sets of gems. 

    *install*

        $ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
        $ \curl -sSL https://get.rvm.io | bash -s stable

    *修改 RVM 的 Ruby 安装源到 Ruby China 的 [Ruby 镜像服务器](https://cache.ruby-china.org/)，这样能提高安装速度*

    ```
    $ echo "ruby_url=https://cache.ruby-china.org/pub/ruby" > ~/.rvm/user/db
    ```

    *commands*

        rvm -v          # RVM version rvm list known  # List Ruby interpreters available for installation rvm list        # List Ruby interpreters you've already installed

        rvm info     # Ruby information for the current shell

        rvm gemdir   # Switch to gems directory for current ruby
        rvm system   # Use the system ruby (as if no rvm)

        rvm install 2.1.1    # Install a version of Ruby (eg 2.1.1)
        rvm uninstall 2.0.0  # Unisntall RVM installed 2.0.0 version

        rvm gemset create rails4  # Greate a named gemset rails4
        rvm gemset use rails4     # Use the rails4 gemset

        rvm 2.1.1          # Use Ruby 2.1.1. Equivalently: rvm use 2.1.1
        rvm 2.1.1@rails4   # Use Ruby 2.1.1 and gemset rails4

    * **Bundler** provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed. 

            $ gem install bundler
            $ bundle install

        * Gemfile

                # A sample Gemfile
                source "https://rubygems.org"

                # gem "rails"

        * RubyGems

            * https://rubygems.org
            * https://gems.ruby-china.org

                    $ gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
                    $ gem sources -l

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

* RVM 实用指南 Ruby China, [https://ruby-china.org/wiki/rvm-guide](https://ruby-china.org/wiki/rvm-guide)
* [RubyGems 镜像 - 淘宝网](https://ruby.taobao.org/)
