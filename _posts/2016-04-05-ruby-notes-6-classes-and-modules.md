---
layout: post
title: "Ruby Notes 6 Classes and Modules"
date: 2016-04-05 13-04-35 +0800
categories: ['Ruby',]
tags: ['Ruby', 'The Ruby Programming Language']
disqus_identifier: 250443302884947471193195785856976787941
---
Classes can include—or inherit methods fom—modules.

Ruby's objects are strictly encapsulated: their state can be access only through the methods they define.

Any Ruby program can add methods to existing classes, and it is even possible to add "singleton methods" to individual objects.

### Classes

#### Defining a Simple Class
{% highlight rb %}
class Point
  @@n = 0        # How many points have created
  @@totalX = 0   # The sum of all X coordinates
  @@totlalY = 0  # The sum of all Y coordinates

  def intialize(x,y)
    @x, @y = x, y

    @@n += 1
    @@totalX += x
    @@totalY += y
  end

  ORIGIN = Point.new(0, 0)
  UNIT_X = Point.new(1, 0)
  UNIT_Y = Point.new(0, 1)

  def x
    @x
  end

  def x=(value)
    @x = value
  end

  def y
    @y
  end

  def y=(value)
    @y = value
  end

  def +(other)
    raise TypeError, "Point argument expected" unless other.is_a? Point
    Point.new(@x + other.x, @y + other.y)
  end

  def -(other)
    raise TypeError, "Point argument expected" unless other.is_a? Point
    Point.new(@x - other.x, @y - other.y)
  end

  def *(scalar)
    Point.new(@x*scalar, @y*scalar)
  end

  def [](index)
    case index
    when 0, -2: @x
    when 1, -1: @y
    when :x, "x": @x
    when :y, "y": @y
    else nil
    end
  end

  def each
    yield @x
    yield @y
  end

  def ==(o)
    @x == o.x && @y == o.y
  rescue
    false
  end

  # alias eql? == # Often, we want eql? to work just like == operator.

  def eql?(o)
    if o.instance_of? Point
      @x.eql?(o.x) && @y.eql?(o.y)
    elsif
      false
    end
  end

  def hash
    code = 17
    code = 37*code + @x.hash
    code = 37*code + @y.hash
    code
  end

  def <=>(other)
    return nil unless other.instance_of? Point
    @x**2 + @y**2 <=> other.x**2 + other.y**2
  end

  def self.sum(*points) # def Point.sum(*points)
    x = y = 0
    points.each { |p| x += p.x; y += p.y }
    Point.new(x, y)
  end

  def to_s
    "(#{@x},#{@y})"
  end
end

{% endhighlight %}

* Accessors and Attributes
{% highlight rb %}
class Point
  def intialize(x,y)
    @x, @y = x, y
  end

  def x   # The accessor (or getter) method for @x
    @x
  end

  def y   # The accessor (or getter) method for @y
    @y
  end
end

class MutablePoint
  def initialize(x,y); @x, @y = x, y; end

  def x; @x; end # The getter method for @x
  def y; @y; end # The getter method for @y

  def x=(value)  # The setter method for @x
    @x = value
  end
  def y=(value)  # The setter method for @y
    @y = value
  end
end

p = Point.new(1,1)
p.x = 0
p.y = 0
{% endhighlight %}
* *metaprogramming*

    * `attr`, `attr_reader`, and `attr_accessor`

        The `attr_reader` and `attr_accessor` methods are defined by `Module` class. Both methods take any number of symbols naming attributes.

        `attr_reader` creates trivial getter methods for the instance variables with the same name.

        `attr_accessor` creates getter and setter methods.

            class Point
              attr_accessor :x, :y  # Define accessor methods for our instance variables
            end

            class Point
              attr_reader :x, :y    # Define reader methods for our instance variable
              # attr_reader "x", "y" Equivalently.
            end

        `attr` is a similar method with a shorted name as a synonym for `attr_reader`.

            attr :x       # Define a trivial getter method x for @x
            attr :y, true # Define getter and setter methods for @y

        The `attr`, `attr_reader`, and `attr_accessor` methods create instance method for us (*metaprogramming*).

#### Method Visibility: Public, Protected, Private

Methods are normally public unless they are explicitly declared to be private or protected.

The `initialize` method is always implicitly private.

Global funcitons are defined as private instance methods of `Object`.

A private method is internal to the implementation of a class, and it can only be called by other instance method of the class.

Private methods are implicityly invoked on `self`, and may not be explicitly invoked on an object.

A protected method is like a private method in that it can only be invoked from within the implementation of a calss or its subclasses.

Protected methods may be explicitly invoked on any instance of the class, and it is not restricted to implicit invocation on `self`.

Protected methods are the least commonly defined and also the most difficult to understand.

Method visibility is declared with three methods named `public`, `private`, and `protected`. These are instance method of the `Module` class.

All classes are modules, and inside a class definition (both outside method definitions), `self` refers to class being defined.

{% highlight rb %}
class Point
  # public methods go here

  # The following methods are protected
  protected

  # protected methods go here

  # The following methods are private
  private

  # private methods go here
end

class Widget
  def x                   # Accessor method for @x
    @x
  end
  protected :x            # Make it protected

  def utility_method      # Define a method
    nil
  end
  private :utility_method # And make it private
end

{% endhighlight %}

*Instance and class variables are encapsulated and effectively private, and constants are effectively public.*

*There is no way to make an instance variable accessible from outside a class. And there is no way to define a constant that is inaccessible to outside use.*

* `private_class_method` and `public_class_method`

    You can make a private class method private with `private_class_method`.

        private_class_method :new

    You can make a private class method public again with `public_class_method`.

#### Subclassing and inheritance

*In Ruby 1.9, `Object` is no longer the root of the class hierarchy. A new class named `BasicObject` serves that purpose, and `Object` is a subclass of `BasicObject`. `BasicObject` is a very simple class, with almost no methods of its own, and is useful as the superclass of delegating wrapper classes.*

When you create a class in Ruby 1.9, you still extend `Object` unless you explicity specify the superclass, and most programmer will need to use or extend `BasicObject`.

The syntax for extending a class is to add **<** character and the name of the superclass to your `class` statement.

    class Point3D < Point   # Define class Point3D as a subclass of Point
    end

*Subclassing a Struct*

    class Point3D < Struct.new("Point3D", :x, :y, :z)
        # Superclass struct gives us acess method, ==, to_s, etc
        # Add point-specific methods here
    end

* Overriding Methods

        # Greet the World
        class WorldGreeter
            def greet           # Display a greeting
                puts "#{greeting} #{who}"
            end
            
            def greeting        # What greeting to use
                "Hello"
            end
            
            def who             # Who to greet
                "World"
            end
        end
        
        # Greet the world in Spanish
        class SpanishWorldGreeter < WorldGreeter
            def greeting        # Override the greeting
                "Hola"
            end
        end
        
        # We call a mehtod defined in WorldGreeter, which calls the overriden
        # version of greeting in SpanishWorldGreeter, and prints "Hola World"
        SpanishWorldGreeter.new.greet

    * abstract vs concrete

            # This class is abstract; it doesn't define greeting or who
            # No special syntax is required: any class that invokes methods that are
            # intended for a subclass to implement is abstract.
            class AbstractGreeter
              def greet
                puts "#{greeting} #{who}"
              end
            end
            
            # A concrete subclass
            class WorldGreeter < AbstractGreeter
              def greeting; "Hello"; end
              def who; "World"; end
            end
            
            WorldGreeter.new.greet # Displays "Hello World"

    * Overriding private methods

        Privates methods are inherited by subclass.

        Subclasses can invoke and override private methods.

        You should only subclass when you are familiar with the implementation of the superclass.

        *Compositition > Inheritance*

    * `super`
    
        `super` works like a special method invocation: it invokes a method with the same name as the current one, in the superclass of the current class.
    
        If you use `super` as a bare keyword—with no arguments and no parentheses—then all of the arguments that were passed to the current method are passed to the superclass method.
    
            class Point3D < Point
              def initialize(x,y,z)
                # Pass our first two arguments along to the superclass initialize method
                super(x , y)
                # And deal with the third argument ourself
                @z = z;
              end
            end

* Inheritance of Class Methods

    Class methods may be inherited and overriden just as instance methods can be.

    As a stylistic matter, it is preferable to invoke class methods through the class object on which they are defined.

    Class methods can use `super` just as instance methods can to invoke the same-named method in the superclass.

        class Point
          def self.sum(*args)
            s = 0
            args.each { |x| s += x }
            s
          end
        end
        
        class Point3D < Point
          def self.sum(*args)
            puts "Point3D"
            super(*args)
          end
        end

* Inheritance and Instance Variables

    Inheritance variables often appear to be inherited in Ruby.

        class Point3D < Point
          def initialize(x,y,z)
            super(x , y)
            @z = z;
          end
          def to_s
            "(#@x, #@y, #@z)" # Variables @x and @y inherited?
          end
        end

* Inheritance and Class Variables

    Class variables are shared by a class and all of its subclasses.

* Inheritance of Constants

    Constants are inherited can can be overriden, much like instance methods can.

        class Point
          ORGIN = Point.new 0, 0
          
          def initialize(x, y)
            @x, @y = x, y
          end
        end
        
        class Point3D
          ORGIN = Point3D.new 0, 0, 0
          
          def initialize(x, y, z)
            super x, y
            @z = z
          end
        end

#### Object Creation and Intialization

* `new`, `allocate`, and `intialize`

    Every class inerits the class method `new`.

    `new` method has two jobs: it must `allocate` a new object—actually bring the object into existence—and it must `intialize` the object.

    The `new` metho would look something like this:

        def new(*args)
          o = self.allocate     # Create a new object of this class
          o.intialize(*args)    # Call the object's intialize method with our args
          o                     # Return new object; ignore return value of intialize
        end

    * `allocate`

        `allocate` is an instance method of `Class`, and it is inherited by all class objects.

        Its purpose is to create a new instance of the class.

        You can call it yourself to create uninitialized instances of a class.

        But don't try to override it; Ruby always inovkes this mehtod directly, ignoring any overriding versions you may have defined.

    * `initalize`

        `initialze` is an instance method and usually to create instance variables for the obect and set them to their initial values.

        Ruby implicitly makes the `initialize` method private.

        * Class::new and Class#new

            The class method `Class::new` is the `Class` class' own version of the method, and it can be used to create new classes.

* Factory Methods

        class Point
          # Define an initialize method as usual...
          def initialize(x,y) # Expects Cartesian coordinates
            @x,@y = x,y
          end
        
          # But make the factory method new private
          private_class_method :new
        
          def Point.cartesian(x,y) # Factory method for Cartesian coordinates
            new(x,y)
            # We can still call new from other class methods
          end
        
          def Point.polar(r, theta) # Factory method for polar coordinates
            new(r*Math.cos(theta), r*Math.sin(theta))
          end
        end

* `dup`,`clone`, and `intialize_copy`

* marshal_dump and marshal_load

* The Singleton Pattern

        require 'singleton'         # Singleton module is not built-in
        
        class PointSats             # Define a class
          include Singleton         # Make it as singleton
        
          def intialize             # A normal initialization method
            @n, @totalX, @totalY = 0, 0.0, 0.0
          end
        
          def record(point)         # Record a new point
            @n += 1
            @totalX += point.x
            @totalY += point.y
          end
        
          def report                # Report point statistics
            puts "Number of points created: #@n"
            puts "Average X coordinate: #{@totalX/@n}"
            puts "Average Y coordinate: #{@totalY/@n}"
          end
        end
        
        class Point
            def initialize(x,y)
                @x, @y = x, y
                PointSats.instance.record(self)
            end
        end
        
   The `Singleton` module automatically creates the `instance` class method for us.
        
        PointSats.instance.report


### Modules

Like a class, a ***module*** is a named group of methods, constants, and class variables.

Modules stand alone; there is no "module hierarchy" of ineritance.

Modules are used as namespaces and as mixins.

#### Modules as Namespaces

Modules are a good way to group related methods when object-oriented programming is not necessary.

    def base64_encode
    end

    def base64_decode
    end

To define the two methods within a `Base64` module to prevent namespace collisions.

    module Base64   # Note the module names must begin with a capital letter.
    def self.encode # def Base64.encode
    end

    def self.decode # def Base64.decode
    end

Modules may also contain constants.

    module Base64
        DIGITS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
                 'abcdefghijklmnopqrstuvwxyz' \
                 ' 0123456789+/ '
    end

Outside the `Base64` module, this constant can be referred to as `Base64::DIGITS`.

If the two methods had some need to share nonconstant data, they could use a class variable (with a **@@** prefix), just as they could if they were defined in class.

* Nested namespaces

    Modules, including classes, may be nested.

    This creates nested namespaces but has no other effect: a class or module nested within another has no special access to the class or module it is nested within.

        module Base64
          DIGITS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        
          class Encoder
            def encode
            end
          end
        
          class Decoder
            def decode
            end
          end
        
          # A utility function for use by both classes
          def Base64.helper
          end
        end

    By structuring our code this way, we've defined two new classes, `Base64::Encoder` and `Base64::Decoder`.

    Inside the `Base64` module, the two classes can refer to each other by their unqualified names, without the `Base64` prefix.

    And each of the classes can use the `DIGITS` constant without a prefix.

* Modules As Mixins

If a module defines instance methods instead of the class methods, those instance methods can be mixed in to other classes.

`Enumerable` and `Comparable` are well-known examples of mixin modules.

*Enumerable* defines useful iterators that are implemented in terms of an `each` iterator.

*Enumerable* doesn't define the `each` mehtod itself, but any class that defines it can mix in the *Enumerable* module to instantly add many useful iterators.

And class that defines `<=>` can be mixed in `Comparable` to get `<`,`<=`,`==`,`>=`, and `between?` for free.

To mix a module into a class, use `include`.

    class Point
      include Comparable
    end

In fact, it is a private instance method of `Module`, implicitly invoked on `self`—the class into which the module is being included.

The inclusion of a module affects the type-checking method `is_a?` and the switch-equality operator `===`.

    "text".is_a? Comparable     # => true
    Enumerable === "text"       # => true in Ruby 1.8, false in 1.9

Note the `instance_of?` only checks the class of its receiver, not superclasses or modules, so the following is false.

    "text".instance_of? Comparable  # => false

    The normal way to mix in a module is with the `Module.include` method. Another way is with `Object.extend`. This method makes the instance methods of the specified module or modules into singleton methods of the receiver object. (And if the receiver object is a Class instance, then the methods of the receiver become class methods of that class.)

        countdown = Object.new          # A plain old object
        def countdown.each              # The each iterator as a singleton mehtod
          yield 3
          yield 2
          yield 1
        end
        countdown.extend(Enumerable)    # Now the object has all Enumerable methods
        print countdown.sort            # Prints "[1, 2, 3]"

* Includable Namespace Modules

    It is possible to define modules that define a namespace but still allow their methods to be mixed in.

        Math.sin(0)     # => 0.0: Math is a namespace
        include 'Math'  # The Math namespace can be included
        sin(0)          # => 0.0: Now we have easy access to the functions

    The **Kernel** module also works like this: we can invoke its methods through the **Kernel** namespace, or as private method of **Object**, into which it is included.

    If you want to create a module like **Math** or **Kernel**, define your methods as instance methods of the module. Then use `module_function` to convert those methods to "module functions".

    **module_funciton** is a private instance method of **Module**, much like the **public**, **protected**, and **private** methods. It accepts any number of method names (as symbols or strings) as arguments.

    The primary effect of calling **module_function** is that it makes class method copies of the specified methods.

    A secondary effect is that it makes the instance methods private.

    Like the **public**, **protected**, and **private** methods, the **module_funciton** mehtod can also be invoked with no arguments. When invoked in this way, any instance methods subsequently defined in the module will be modue funciton: they will become public class methods and private instance methods.

#### Loading and Requiring Modules

Ruby programs may be broken up into multiple files, and the most natural way to partition a program is to place each nontrivial class or module into a separate file.

These separate files can then be reassembled into a single program (and, if well-designed, can be reused by other programs) using **require** or **load** which are global functions defined in **Kernel**, but are used like language keywords.

If the file to load is specified with an ***absolute path***, or is relative to ***~*** (the user's home directory), then that specific file is loaded.

Usually, however, the file is specified as a ***relative path***, and **load** and **require** search for it relative to the directories of Ruby's ***load path***.

* `load`, `require` and`require_relative`

    * In addition to loading source code, **require** can also load binary extensions to Ruby.

        Binary extensions are, of course, implementation-dependent, but in C-based implementations, they typically take the form of shared library files with extension like *.so* or *.dll*.

    * **load** expects a complete filename including an extension.

        **require** is usually passed a library name, with no extension, rather than a filename. In that case, it searchs for a file that has the library name as its base name and an approriate source or native library extension. If a direcotry contains both an *.rb* source file and a binary extension file, **require** will load the source file instead of the binary file.

    * **load** can load the same file multiple times.

        **require** tries to prevent multiple loads of the same file.

        **require** keeps track of the files that have been loaded by appending them to the global array `$"` (also known as $LOAD_FEATURES).

    * **load** loads the specified file at the current $SAFE level.

        **require** loads the specified library with $SAFE set to 0, even if the code that called **require** has a higher value for that variable.

    * **require_relative**, a special version of **require**, searchs and loads file from the current direcotry.

* The Load Path

    Ruby's load path is an array that you can access using either of the global variables `$LOAD_PATH` or `$:`.

    Each element of the array is the name of a direcotry that Ruby will search for files to load.

    Direcotories at the start of the array are searched before direcotories at the end of the array.

    The elements of **$LOAD_PATH** must be strings in Ruby 1.8, but in Ruby 1.9, they may be strings or any object that has a `to_path` method that returns a string.

* Executing Loaded Code

    **load** and **require** execute the code in the specified file immediately.

    Files loaded with **load** or **require** are executed in a new top-level scope that is different from the one in which **load** or **require** was invoked.

    The loaded file can see all global variables and constants that have been defined at the time it is loaded, but it does not have access to the local scope from which the load was initiated.

    * The local variables defined in the scope from which **load** or **require** is invoked are not visible to the loaded file.

    * Any local variables created by the loaded file are discarded once the load is complete; they are never visible outside the file in which they are defined.

    * At the start of the loaded file, the value of **self** is always the main object, just as it is when the Ruby interpreter starts running. 

    * The current module nesting is ignored within the loaded file. You cannot, for example, open a class and then load a file of method definitions. The file will be processed in a top-level socpe, not inside any class or module.

* Autoloading Modules

    The **autoload** methods of **Kernel** and **Module** allow lazy loading of files on an as-needed basis. The global **autoload** function allows you to register the name of an undefined constant (typically a class or module name) and a name of the library that defines it. When that constant is first referenced, the named library is loaded using **require**. For example:

        # Require 'socket' if and when the TCPSocket is first used
        autoload :TCPSocket, "socket"

    The **Module** class defines its own version of **autoload** to work with constants nested within another module.

#### Singleton Methods and the Eigenclass

To define a singleton method **sum** on an object **Point**, we'd write:

    def Point.sum
      # Method body goes here
    end

The singleton methods of an object are instance methods of the anonymous *eigenchass* associated with that object.

"Eigen" is a German word meaning (roughly) "self", "own", "particular to," or "characteristic of."

The eigenclass is also called the *singleton class* or the *metaclass*.

Ruby defines a syntax for opening the eigenclass of an object and adding methods to it thats provides an alternative to defining singleton methods one by one.

To open the eigenclass of the object **o**, use **class << o**. For example, we can define class methods of **Point** like this:

    class << Point
      def class_method1     # This is an instance method of the eigenclass.
      end

      def class_method2
      end
    end

#### Method Lookup

When Ruby evaluates a method invocation expression, it must first figure out which method is to be invoked. The process for doing this is called ***method lookup*** or ***method name resolution***.

For the method invocation expression `o.m`, Ruby performs name resolution with the following steps:

1. First, it checks the eigenclass of **o** for ***singleton methods*** named **m**.

2. If no method **m** is found in the eigenclass, Ruby searchs the class of **o** for an ***instance method*** named **m**.

3. If no method **m** is found in the class, Ruby searchs the ***instance methods of any modules*** included by the class of **o**. If that class includes more than one module, then the most recently included module is searched first.

4. If no instance method **m** is found in the class of **o** or in its modules, then the search moves up the ***inheritance hierarchy to the superclass***.

5. If no method named **m** is found after completing the search, then a method named **method_missing** is invoked instead. In order to find an appropriate definitions of this method, the name resolution algorith starts over at step 1.

The **Kernel** module provides a default implementation of **method_missing**. What it does is raise an exception of *NoMethodError*.

The name resolution algorithm for class methods is exactly the same as it is for instance method.

#### Constant Lookup

When a constant is referenced without any qualifying namespace, the Ruby interpreter must find the appropriate definition of the constant.

* Ruby first attempts to resolve a constant reference in the lexical scope of the reference.

    This means that it first checks the class or module that encloses the constant reference to see if that class or module defines the constant.
    If not, it checks the next enclosing class or module.

    This continues untils there are no more enclosing classes or modules.

    Note that top-level or "global" constants are not considered part of the lexical scope and are not considered during this part of constant lookup.

    The class method **Module.nesting** returns the list of clases and modules that are searched in this step, in the order they are searched.

* If no constant definition is foud in the lexically enclosing scope, Ruby next tries to resolve the constant in the inheritance hierarchy by checking the ancesstors of the class or module that referred to the constant.

    The **ancestors** method of the containing class or module returns the list of classes and modules searched in this step.

* If no constant definition is found in the inheritance hierarchy, then top-level constant definitions are checked.

* If no definition can be found for the desired constant, then the **const_missing** method—if there is one—of the containing class or module is called and given the opportunity to provide a value for the constant.

A few points about this constant lookup algorithm.

* Constants defined in enclosing modules are found in preference to constants defined in included modules.

* The modules included by a class are searched before the superclass of the class.

* The **Object** class is part of the inheritance hierarchy of all classes.

* The **Kernel** module is an ancestor of **Object**.

{% highlight rb %}
module Kernel
  # Constants defined in Kernel
  A = B = C = D = E = F = "defined in Kernel"
end

# Top-level or "global" constants defined in Object
A = B = C = D = E = "defined at Top-level"

class Super
  A = B = C = D = "defined in superclass"
end

module Included
  # Constants defined in an included module
  A = B = C = "defined in included module"
end

module Enclosing
  # Constants defined in an enclosing module
  A = B = "defined in enclosing module"

  class Local < Super
    include Included

    # Locally defined constant
    A = "defined locally"

    # The list of modules searched, in the order searched
    # [Enclosing::Local, Enclosing, Inclued, Super, Object, Kernel]

    search = (Module.nesting + self.ancestors + Object.ancestors).uniq
    puts A # Prints "defined locally"
    puts B # Prints "defined in enclosing module"
    puts C # Prints "defined in included module"
    puts D # Prints "defined in superclass"
    puts E # Prints "defined at toplevel"
    puts F # Prints "defined in kernel"
  end
end
{% endhighlight %}

* * *

#### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
