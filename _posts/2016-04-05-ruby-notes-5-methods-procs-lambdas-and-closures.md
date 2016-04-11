---
layout: post
title: "Ruby Notes 5 Methods, Procs, Lambdas, and Closures"
date: 2016-04-05 12-51-11 +0800
categories: ['Ruby',]
tags: ['Ruby', 'The Ruby Programming Language', 'Closure', 'Lambda']
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

* Methods and Parentheses

    Ruby allows parentheses to be omitted from most method invocation.

        puts "Hello World"
        puts("Hello World")

        greeting = "Hello"
        size = greeting.length
        size = greeting.length()

        x = 3
        x.between? 1,5
        x.between?(1,5)

        f g x, y        # f((g(x),y) not f(g(x,y)) !!!
        square(2+2)*2   # square(4)*2 = 16*2 = 32
        square (2+2)*2  # square(4*2) = square(8) = 64

* Method Arguments

    * Parameter Defaults

        Specify a default value by following the parameter name with an equals sign and a value:

            def prefix(s,len=1)
                s[0,len]
            end

        Argument defaults need not be constants: they may be arbitrary expressions, and can be referred to instance variable and previous parameter in the parameter list.

            # Return the last character of s or the substring from index to the end
            def suffix(s, index=s.size-1)
                s[index, s.size-index)
            end

        Parameter defaults are evaluated when a method is invoked rather than when it is parsed.

    * Variable-Length Argument Lists and Arrays


            # Return the largest of the one or more arugments passed
            def max(first, *rest)
                # Assume that the required first argument is the largest
                max = first
                # Now loop through each of the optional arguments looking for bigger ones
                rest.each {|x| max = x if x > max }
                # Return the largest one we found
                max
            end

        No more than one parameter may be prefixed with an * and it should be the last parameter of the method, unless the method also has a parameter with an & prefix.

            max(1)      # first=1, rest=[]
            max(1,2)    # first=1, rest=[2]
            max(1,2,3)  # first=1, rest=[2,3]

    * Passing arrays to methods

        \* can also be used in a method invocation to scatter, expand, or explode the elements of an array (or range or emuerator) so that each element becomes a separate method argument.

            data = [3,2,1]
            m = max(*data)  # first=3, rest=[2,1] => 3

    * Mapping Arguments to Parameters

        *A little bit triky*
        *To be continued...*

    * Hashes for Named Arguments

        When a method requires more than two or three arguments, it can be difficult for the programmer invoking the method to remember the proper order for those argments.

        Ruby does not support to write method invocations that explicitly specify a parameter name for each arugment that is passed, but it can approximated if you write a method that expects a hash as its argument or as one of its arguments.

            # This method returns an array a of n numbers. For any index i, 0 <= i < n,
            # the value of element a[i] is m*i+c. Arguments n, m, and c are passed
            # as keys in a hash, so that it is not necessary to remember their order.
            def sequence(args)
              # Extract the arguments from the hash.
              # Note the use of the || operator to specify defaults used
              # if the hash does not define a key that we are interested in. n = args[:n] || 0
              m = args[:m] || 1
              c = args[:c] || 0
              a = []                    # Start with an empty array
              n.times {|i| a << m*i+c } # Calculate the value of each array element
              a                         # Return the array
            end

        You might invoke this method with a hash literal argument like this:

            sequence({:n=>3, :m=>5})    # => [0, 5, 10]

        In order to better support this style of programming, Ruby allows you to omit the curly braces around the hash literal if it is the last argument to the method (or if the only arugment that follows it is a block argument, prefixed with &).

        A hash without braces is sometinmes called a **bare hash**.

            sequence(:m=>3, :n=>5)      # => [0, 3, 6, 9, 12]

        As with other ruby methods, we can omit the parentheses.

            sequence c:1, m:3, n:5      # => [1, 4, 7, 10, 13]

        If you omit the paretheses, then you *must* omit the curly braces.

            # Ruby thinks you're passing a block to the method.
            seqence {:m=>3, :n=>5 }     # Syntax error!

    * Block Arguments

        Any mehtod invocation may be followed by a block, and any method that has a block associated with it may invoke the code in that block with the `yield` statement.

            # Generate a sequence of n numbers m*i + c and pass them to the block
            def sequence2(n, m, c)
                i = 0
                while(i < n)        # loop n times
                    yield i*m + c   # pass next element of the sequence to the block
                    i += 1
                end
            end

            # Here is how you might use this verison of the method
            sequence2(5, 2, 2) { |x| puts x } # Print numbers 2, 4, 6, 8, 10

        One of the features of blocks is their anonymity.

        If you prefer more explicit control over a block, add a final argument to your method, and prefix the argument name with an ampersand. The value of the argument will be a `Proc` object, and instead of using `yield`, you invoke the `call` method of the `Proc`.

            def sequence3(n, m, c, &p) # Explicit argument to get block as a Proc
                i = 0
                while(i < n)
                    b.call(i*m + c)    # Invoke the Proc with its call method
                    i += 1
                end
            end

            # Note that the block is still passed outside of the parentheses
            sequence3(5, 2, 2) { |x| puts x }

        Notice that using the ampersand in this way changes only the method definition.

        * Passing Proc Objects Explicityly

                # This version expects an explicitly-created Proc object, not a block
                def sequence4(n, m, c, b)   # No ampersand used for arguemnt b
                    i = 0
                    while(i < n)
                        b.call(i*m + c)     # Proc is called explicitly
                        i += 1
                    end
                end

                p = Proc.new { |x| puts x } # Explicity create a Proc object
                sequence4(5, 2, 2, p)       # And pass it as an ordinary argument

        Block arguments prefixed with ampersands must *really* the last one in the parameter list.

            def sequence5(args, &b) # Pass arguments as a hash and follow with a block
                n, m, c = argus[:n], args[:m], args[:c]
                i = 0
                while(i < n)
                    b.call(i*m + c)
                    i += 1
                end
            end

            # Expects one or more arguments, followed by a block
            def max(first, *rest, &block)
                max = first
                rest.each { |x| max = x if x > max }
                block.call(max)
                max
            end

    The `yield` satement still works in a method defined with an & parameter. Even if the block has been converted to a `Proc` object and passed as an argument, it can still be invoked as an anonymous block, as if the block argument was not there.

   * Using & in method invocation

        `*` in a method definition to specify that multiple arguments should be packed into an array

        `*` in a method invocaiton to specify that an array should be upcaked so that its elements become separate arguments

        `&` in a method definition allows an ordinary block associated with a method invocation to be used as a named `Proc` object inside the method.

        `&` in a method invocation that before a `Proc` object to treat the `Proc` as if it was an ordinary block following the invocation.

        In a mehtod invocation an & typically appears before a `Proc` object. But it is accually allowed before any object with a `to_proc` method (e.g `Method` and `Symbol` classes). 

            a, b = [1,2,3], [4,5]                       # Start with some data.
            summation = Proc.new { |total,x| total+x }  # A Proc object for summations
            sum = a.inject(0, &summation)               # => 6
            sum = b.inject(0, &summation)               # => 15

### Procs and Lambdas

Blocks are syntactic structures in Ruby; they are not objects, and cannot be manipulated as objects.

Procs have block-like behavior and lambdas have method-like behavior, however, both are instances of class `Proc`.

#### Creating Procs

* Proc factory method

        # This method creates a proc from a block
        def make_proc(&p)   # Convert associated block to a Proc and store in p
            p               # Return the Proc object
        end

        adder = make_proc { |x,y| x+y }

        sum = adder.call(2,2) # => 4

* Proc.new

        p = Proc.new { |x,y| x+y }

* Kernel.lambda

        is_positive = lambda { |x| x > 0 }

* Kernel.proc

    `proc` is a synonym for `Proc.new`.

* Lambda Literals

    In Ruby 1.8

        succ = lambda { |x| x+1 }

    In Ruby 1.9, we can convert this to a literal as follows:

    * Replace the method name `lambda` with the punctuation `->`.
    * Move the list of arguments outside of and just before the curly braces.
    * Change the argument list delimiters from `||` to `()`.

            succ = ->(x){ x+1 }

    A lambda literal uses an arrow made with a hypen, whereas a hash literal uses an arrow made with an equals sign.

        # This lambada takes 2 args and declares 3 local vars
        f = ->(x,y; i,j,k) { ... }

    Lambdas can be to declared with argument defaults.

        zoom = ->(x,y,factor=2) { [x*factor, y*factor] }

    As with method declarations, the parentheses in lambda literals are optional, because the parameter list and localvariable lists are completely delimited by the `->`,`;`, and `{`.

        succ = -> { x + 1 }
        f = -> x,y; i,j,k { ... }
        zoom = -> x,y,factor=2 { x*factor, y*factor }

    Lambda parameters and local variables are optional.

        -> {}

    If you want to pass a lambda literal to a method that expects a block, prefix the literal with `&`.

        data.sort { |a,b| b-a }     # The block version
        data.sort &->a,b{ b-a }     # The lambda literal version

#### Invoking Procs and Lambdas

Procs and lambdas are objects, not methods, and they cannot be invoked in the same way that method are.

    f = Proc.new { |x,y| 1.0/(1.0/x + 1.0/y) }
    z = f.call(x,y)

The `Proc` class also defines the array access operator to work the same as `call`.

    z = f[x,y]

An alternative to square brackets, you can use parentheses prefixed with a period.

    z = f.(x,y)

`.()` is a syntactic-sugar that invokes the `call` method, and can be used with any object that defines a `call` method and is not limited to `Proc` objects.

#### How Lambdas Differ from Procs

A proc is the object form of a block, and it behaves like a block.

A lambda has slightly modified behavior and behaves more like a method than a block.

Calling a proc is like yielding to a block, whereas calling a lambda is like invoking a mehtod.

In Ruby 1.9, you can determine whether a `Proc` object is a proc or a lambda with the instance method `lambda?`.

* Return in blocks, procs, and lambdas

    The `return` statement in a block does not just return from the block to the invoking iterator, it reutrns from the mehtod that invoked the iterator.

        def test
            puts "entering method"
            1.times { puts "entering block"; return } # Makes test method return
            puts "exiting method"   # This line is never executed
        end

    A proc is like a block, so if you call a proc that executes a `return` statement, it attempts to return from the method that encloses the block that was converted to the proc.

        def test
            puts "entering method"
            p = Proc.new { puts "entering proc"; return }
            p.call                  # Invoking the proc makes method return
            puts "exiting method"   # This line is never executed.
        end

    Using a `return` statement in a proc is triky. (*LocalJumpError*)

    A `return` statement in a lambda, therefore, returns from the lambda itself, not from the method that surrounds the creation site of the lambda.

        def test
            puts "entering method"
            p = lambda { puts "entering lambda"; return }
            p.call                  # Invoking the lambda does not make the method return
            puts "exiting method"   # This line *is* executed now
        end

### Closures

In Ruby, procs and lambdas are *closures*.

The term "closure" comes from the early days of computer science; it refers to an object that is both an invocable funciton and a varible binding for that funciton.

When you create a proc or a labmda, the resulting `Proc` object holds not just the executable block but also bindings for all the varialbes used by the block.

* Closures and Shared Variables

It is important to understand that a closure does not just retain the value of the variables it refers to—it retains the actual variables and extends their lifetime.

The bindings are dynamic, and the values of the variables are looked up when the lambda or proc is executed.

As an example, the following code defines a method that returns two lambdas. Because the lambdas are defined in the same scope, they share access to the variables in that scope. When on lamda alters the values of a shared varible, the new value is available to the other lambda.

    # Return a pair of lambdas that share access to a local variable.
    def accessor_pair(initial_value=nil)
        value = intiial_value   # A local variable shared by the returned lambdas
        getter = lambda { value }         # Return value of local variable
        setter = lambda { |x| value = x } # Change value of local variable
        return getter, setter
    end

    getX, setX = accessor_pair(0)   # Create accssor lambdas for initial value 0.
    puts getX[]     # Prints 0. Note square brackets instead of call.
    set[10]         # Change the value through one closure.
    puts getX[]     # Prints 10. The change is visible through the other.

* Closures and Bindings

    The `Proc` class define a method named `binding`. Calling this method on a proc or lambda returns a `Binding` object that represents the bindings in effect for that closure.
    
    A `Binding` object doesn't have interesting methods of it own, but it can be used as the second argument to the global `eval` fuction`, providing a context in which to evaluate a string of Ruby code.
    
    In Ruby 1.9, `Binding` has its own `eval` method.
    
    The use of a `Binding` object and the `eval` method gives us a back door through which we can manipulate the behavior of a closure.
    
        # Return a lambda that retains or "closes over" the argument n
        def mulitplier(n)
            lambda { |data| data.collect{ |x| x*n } }
        end
        doubler = multiplier(2)     # Get a lambda that knows how to double
        puts doubler.call([1,2,3])  # Prints 2,4,6
    
        eval("n=3", doubler.binding) # Or doubler.binding.eval("n=3") in Ruby 1.9
        puts doubler.call([1,2,3])   # Now this pritns 3,6,9!
    
    Bindings are not only a feature of closures. The `Kernel.binding` method returns a `Binding` object that represents the bindings in effect at whatever point you happen to call it.

### Method Object

Ruby's methods and blocks are executable language constructs, but they are not objects.

Procs and lambdas are object versions of blocks; they can be executed and also manipualted as data.

Ruby has powerful metaprogramming (or *refleciton*) capabilities, and methods can actually be represented as instance of the `Method` class.

### Functional Programming

Ruby is not a functional programming language in the way that languages like Lisp and Haskell are, but Ruby's blocks, procs, and lambdas lend themselves nicely to a funcitonal programming style.

* * *

### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
