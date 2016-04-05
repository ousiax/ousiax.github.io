---
layout: post
title: "Ruby Notes 4 Statements and Control Structures"
date: 2016-04-05 04-37-29 +0800
categories: ['Ruby',]
tags: ['Ruby',]
disqus_identifier: 306601145746773585543222304277535818207
---
A sequential program that are executed one line of code after the other without branching or repetition.

    x = ARGV[0].to_f # Convert first argument to a number
    y = ARGV[1].to_f # Convert second argument to a number
    sum = x + y      # Add the arguments
    puts sum         # Print the sum

Alter the sequential execution, or *flow-of-control*, of a program with Ruby's **control structures**.

* Conditionals
* Loops
* Iterators and blocks
* Flow-altering satements like **return** and **break**
* Exceptions
* The special-case BEGIN and END statements
* The esoteric control structures known as **fibers** and **continuations**

### Conditionals

1. if

        if expression
            code
        end

    The `code` between `if` and `end` is executed if (and only if) the `expression` evaluates to something other than `false` or `nil`.

    The `code` must be separated from the `expression` with a newline or semicolon or the keyword `then`.

           # If x is less than 10, increment it

           if x < 10 # newline separator
           x += 1
           end
           
           if x < 10 then x += 1 end # then separator
           
           if x < 10 then
               x += 1
           end

    * **else**

            if expression
                code
            else
                code
            end

    * **elsif**

            if expression1
                code1
            elsif expression2
                code2
                .
                .
                .
            elsif expressionN
                codeN
            else
                code
            end

    * **Return value**

        The return value of an `if` “statement” (i.e., the value that results from evaluating an if expression) is *the value of the last expression* in the code that was executed, or `nil` if no block of code was executed.

1. if As a Modifer

        Instead of writing:

            if expression then code end

        we can simply write:

            code if expression

1. unless

    `unless`, as a statement or a modifier, is the opposite of `if`: it executes code only if an associated expression evaluates to `false` or `nil`. Its syntax is just like `if`, except that `elsif` clauses are *not* allowed:

        # single-way unless statement
        unless condition
            code
        end
        
        # two-way unless statement
        unless condition
            code
        else
            code
        end
        
        # unless modifier
        code unless condition

1. case

    The `case` statement is a multiway conditional. There are two forms of this statement.

    * *if/elsif/else*

            name = case                             name =
            when x == 1 then "one"                  if x == 1 then "one" 
            when x == 2 then "two"                  elsif x == 2 then "two"
            when x == 3 then "three"                elsif x == 3 then "three"
            when x == 4 then "four"                 elsif x == 4 then "four"
            else "many"                             else "many"
            end                                     end

        *the `then` keyword replaced with a newline or semicolon*

            case
            when x == 1
                "one"
            when x == 2
                "two"
            when x == 3
                "three"
            end

    * *case equality* 

            name = 
            case x
            when 1              # Just the value to compare to x
                "one"
            when 2 then "two"   # Then keyword instead of newline
            when 3; "three"     # Semicolon instead of newline
            else "many"         # Optional else clause at end
            end

        *same as*
            
            name = case
            when 1 === x then "one"
            when 2 === x then "two" 
            when 3 === x then "three" 
            else "many"
            end

        *eg.1*
            
            # Take different actions depending on the class of x 
            puts case x
            when String then "string"
            when Numeric then "number"
            when TrueClass, FalseClass then "boolean"
            else "other"
            end

        *eg.2*

            # Compute 2006 U.S. income tax using case and Range objects
            tax = case income
                  when 0..7550
                      income * 0.1
                  when 7550..30650
                      755 + (income-7550)*0.15
                  when 30650..74200
                      4220 + (income-30655)*0.25
                  when 74200..154800
                      15107.5 + (income-74201)*0.28
                  when 154800..336550
                      37675.5 + (income-154800)*0.33
                  else
                      97653 + (income-336550)*0.35
                  end

        *eg.3*
            
            # Get user's input and process it, ignoring comments and exiting
            # when the user enters the word "quit"
            while line=gets.chomp do    # Loop, asking the user for input each time
                case line
                when /^\s*#/            # If input looks like a comment...
                    next                # skip to the next line.
                when /^quit$/i          # If input is "quit" (case insensitive)...
                    break               # exit the loop.
                else                    # Otherwise...
                    puts line.reverse   # reverse the user's input and print it.
                end
            end
            

#### Loops

1. while and until
    * `while`

            x = 10          # Initialize a loop counter variable
            while x >= 0 do # Loop while x is greater than or equal to 0
                puts x      # Print out the value of x
                x = x - 1    # Subtract 1 from x
            end             # The loop ends here
            
    * `until`
            
            # Count back up to 10 using an until loop
            x = 0           # Start at 0 (instead of -1)
            until x > 10 do # Loop until x is greater than 10
                puts x
                x = x + 1 
            end             # Loop ends here
            
1. while and until As Modifiers            

    * `while`

            x = 0                       # Initialize loop variable
            puts x = x + 1 while x < 10 # Output and increment in a single expression

    * `until`        

            a = [1,2,3]                 # Initialize an array
            puts a.pop until a.empty?   # Pop elements from array until empty

1. The for/in Loop

    for var in collection do
        body
    end

### Altering Control Flow

* `return`

    Causes a method to exit and return a value to its caller.

* `break`

    Causes a loop (or iterator) to exit.

* `next`

    Causes a loop (or iterator) to skip the rest of the current iteration and move on to the next iteration.

* `redo`

    Restarts a loop or iterator from the begining.

* `retry`

    Restarts an iterator, reevaluating the entire expression. The `retry` keyword can aslo be used in exception handling.

* `throw/catch`

    A very general control struture that is named like and works like an exception progagation and handling mechanism. `throw` and `catch` are not Ruby's primary exception mechanism (that would be `raise` and `rescue`). Instead, they are used as a kind of multilevel or labeled `break`.

### Exceptions and Exception Handling

1. Exception Classes and Exception Objects

        Object
            +--Exception
                +--NoMemoryError
                +--ScriptError
                | +--LoadError
                | +--NotImplementedError
                | +--SyntaxError
            +--SecurityError        # Was a StandardError in 1.8
            +--SignalException
            | +--Interrupt
            +--SystemExit
            +--SystemStackError     # Was a StandardError in 1.8
            +--StandardError
                +--ArgumentError
                +--FiberError       # New in 1.9
                +--IOError
                | +--EOFError
                +--IndexError
                | +--KeyError       # New in 1.9
                | +--StopIteration  # New in 1.9
                +--LocalJumpError
                +--NameError
                | +--NoMethodError
                +--RangeError
                | +--FloatDomainError
                +--RegexpError
                +--RuntimeError
                +--SystemCallError
                +--ThreadError
                +--TypeError
                +--ZeroDivisionError

    *The Ruby Exception Class Hierarchy*

    * **The methods of exception objects**

        * `message`

            The `message` method returns a string that my provide human-readable details about what went wrong.

        * `backtrace`

            The `backtrace` method returns an array of strings that represents the call stack at the point that exception was raised.

            Each element of the array is a string of the form:

                filename:linenumber:in `methodname'

2. Raising Exceptions with `raise`

    The *Kernel* method `raise` raises an exception. `fail` is a synonym that is sometimes used when the exceptation is that the exception will cause the program to exit.

    * `raise` with on arguments

        If `raise` is called with no arguments, it creates a new `RuntimeError` object (with no message) and raises it. Or, if `raise` is used with no arguments inside a `rescue` clause, it simply re-raises the exception that was being handled.

    * `raise` with a single `Exception` object

        If `raise` is called with a single `Exception` object as its argument, it raises that exception. Despite its simplicity, this is *not actually a common way* to use `raise`.

    * 'raise` with a single string argument

        If `raise` is called with a single string argument, it creates a new `RuntimeError` exception object, with the specified string as its message, and raises that exception. This is a *very common way* to use `raise`.

    * `raise` with an object that has an `exception` method

        If the first argument to `raise` is an object that has an `exception` method, then `raise` invokes that method and raises the `Exception` object that its returns. The `Exception` class defines an `exception` method, so you can specify the class object for any kind of exception as the first argument to `raise`.

        `raise` accepts a string as its optional second argument to use as the exception message.

        `raise` also accepts an optional third argument. An array of strings may be specified here, and they will be used as the backtrace for the exception object. If this third argument is not specified, `raise` sets the backtrace of the exception itself (using the *Kernel* method `caller`).

3. Handling Exceptions with `rescue`

    `raise` is a *Kernel* method.

    A `rescue` clause, by contrast, is a fundamental part of the Ruby language.

    `rescue` is not a statement in its own right, but rather a clause that can be attached to other Ruby statements.

    Most commonly, a `rescue` clause is attached to a `begin` statement.

    The `begin` statement exists simply to delimit the block of code within which exceptions are to be handled.

        begin
            # Any number of Ruby statements go here.
            # Usually, they are executed without exceptions and # execution continues after the end statement.
        rescue
            # This is the rescue clause; exception-handling code goes here.
            # If an exception is raised by the code above, or propagates up
            # from one of the methods called above, then execution jumps here.
        end
        
    * **Naming the exception object**

        In a `rescue` clause, the global variable `$!` refers to the `Exception` object that is being handled.

        If your program includes the line:

            require 'English'

        then you can use the global variable `$ERROR_INFO` instead.

        A better alternative to `$!` or `$ERROR_INFO` is to specify a variable name for the exception object in the `rescue` itself:

            rescue => ex

        The statements of this `rescue` clause can now use the varible `ex` to refer to the `Exception` object that describes the exception.

            begin                                 # Handle exceptions in this block
                x = factorial(-1)                 # Note illegal argument
            rescue => ex                          # Store exception in variable ex
                puts "#{ex.class}: #{ex.message}" # Handle exception by printing message
            end                                   # End the begin/rescue block


    * **Handling exceptions by type**

        The `rescue` clause show here handle any exception that is a `StandardError` (or subclass) and ignore any `Exception` object that is not `StandardError`.

        If you want to handle nonstandard exceptions outside the `StandardError` hierarchy, or if you want to handle only specific types of exceptions, you must include one or more exception classes in the `rescue` clause.

            rescue Exception

            rescue ArgumentError => e

            rescue ArgumentError, TypeError => error

4. The `else` Clause

    The `else` clause is an alternative to the `rescue` clauses; it is used if none of the `rescue` clauses are needed.

    The code in an `else` clause is executed if the code in the body of the begin statement runs to completion *without exceptions*.

5. The `ensure` Clause

    The `ensure` clause contains code that always runs, no matter what happens with the code following `begin`:

    * If the code *runs to completion*, then control jumps to the `else` clause—if there is one—and then to the `ensure` clause.

    * If the code executes a `return` statement, then the execution skip the `else` clause and jump directly to the `ensure` clause before returing.

    * If the code following `begin` raises an exception, then control jumps to the appropriate `rescue` clause, then to the `ensure` clause.

    * If there no `rescue` clause, or if no `rescue` clause can handle the exception, then control jumps directly to the `ensure` clause. The code in the `ensure` clause is executed before the exception propagates out to containing blocks or up the call stack.

    The purpose of the `ensure` clause is to ensure that housekeeping details such as closing files, disconnecting database connections, and committing or aborting transactions get taken care of.

7. `rescue` As a Statement Modifier

        # Compute factorial of x, or use 0 if the method raises an exception 
        y = factorial(x) rescue 0

### Threads, Fibers, and Continuations

1. Threads for Concurrency

    A *thread of execution* is a sequence of Ruby statements that run (or apear to run) in parallel with the main sequence of statements that the interpreter is running.

    Threads are represented by `Thread` objects, but they can also be thought of as control structures for concurrency.

    Call `Thread.new` and associate a block with it to create new threads that will start running the code in the block.

        # This method expects an array of filenames.
        # It returns an array of strings holding the content of the named files.
        # The method creates one thread for each named file.
        def readfiles(filenames)
            # Create an array of threads from the array of filenames.
            # Each thread starts reading a file.
            threads = filenames.map do |f|
                Thread.new { File.read(f) }
            end
        
            # Now create an array of file contents by calling the value 
            # method of each thread. This method blocks, if necessary, 
            # until the thread exits with a value.
            threads.map {|t| t.value }
        end

1. Fibers for Coroutines

    The name "fiber" has been used elsewhere for a kind of lightweight thread, but Ruby's fibers are better described as *coroutines` or, more accurately, *semi-coroutines*.

    The most common use for coroutines is to implement *generators*: objects that can compute a partial result, *yield* the result back to the caller, and save the state of the computaiton so that the caller can *resume* that compuation to obtain the next result.

    In Ruby, the `Fiber` class is used to enable the automatic conversion of internal iterators, such as the `each` method, into enumerators or external iterators.

    Create a fiber with `Fiber.new`, and associate a block with it to specify the code that the fiber to run.

    Unlike a thread, the body of a fiber does not start executing right away.

    To run a fiber, call the `resume` method of the `Fiber` object that represent it.

    The first time `resume` is called on a fiber, control is transferred to the begining of the fiber body.

    That fiber then runs unitl it reachs the end of the body, or unitl it executes the class method `Fiber.yield`.

    The `Fiber.yield` method transfer control back to the caller and makes the call to `resume` return. It also saves the state of the fiber, so that the next call to `resume` makes the fiber pick up where it left off.

            f = Fiber.new {                 # Line 1: Create a new fiber
                puts "Fiber says Hello"     # Line 2:
                Fiber.yield                 # Line 3:
                puts "Fiber says Goodbye"   # Line 4: goto line 11
            }                               # Line 5:
                                            # Line 6:
            puts "Caller says Hello"        # Line 7:
            f.resume                        # Line 8: goto line 2
            puts "Caller says Goodbye"      # Line 9:
            f.resume                        # Line 10: goto line 4
                                            # Line 11:

    * **Fiber arguments and return values**

        Fibers and their callers can exchange data through the arguments and return values of `resume` and `yield`.

        The arguments to the first call to `resume` are passed to the block associated with the fiber: they become the values of the block parameters.

        On subsequent calls, the arguments to `resume` become the return value of `Fiber.yield`.

        Conversely, any arguments to `Fiber.yield` become the return value of `resume`.

        And when the block exits, the value of the *last expression* evaluated also becomes the return value of *resume*.

            f = Fiber.new do |message|
                puts "Caller said: #{message}" 
                message2 = Fiber.yield("Hello") # "Hello" returned by first resume
                puts "Caller said: #{message2}"
                "Fine"                          # "Fine" returned by second resume
            end
            
            response = f.resume("Hello")         # "Hello" passed to block
            puts "Fiber said: #{response}"
            response2 = f.resume("How are you?") # "How are you?" returned by Fiber.yield 
            puts "Fiber said: #{response2}"

    * **Implementing generators with fibers**

            class FibonacciGenerator
                def initialize
                    @x,@y = 0,1
                    @fiber = Fiber.new do
                        loop do
                            @x,@y = @y, @x+@y
                            Fiber.yield @x
                        end
                    end
                end
            
                def next    # Return the next Fibonacci number
                    @fiber.resume
                end
            
                def rewind  # Restart the sequence
                    @x,@y = 0,1
                end
            end
            
            g = FibonacciGenerator.new     # Create a generator
            10.times { print g.next, " " } # Print first 10 numbers
            g.rewind; puts                 # Start over, on a new line
            10.times { print g.next, " " } # Print first 10 again

1. Continuations


* * *

#### References

* [The Ruby Programming LanguageFeb by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
