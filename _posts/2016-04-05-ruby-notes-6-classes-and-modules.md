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

#### Method Visibility: Public, Protected, Private

### Modules

    Like a class, a ***module*** is a named group of methods, constants, and class variables.

    Modules stand alone; there is no "module hierarchy" of ineritance.

    Modules are used as namespaces and as mixins.

* **Modules as Namespaces**

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

    If the two methods had some need to share noconstant data, they could use a class variable (with a @@ prefix), just as they could if they were defined in class.

* **Loading and Requiring Modules**

    Ruby programs may be broken up into multiple files, and the most natural way to partition a program is to place each nontrivial class or module into a separate file.

    These separate files can then be reassembled into a single program (and, if well-designed, can be reused by other programs) using `require` or `load` which are global functions defined in **Kernel**, but are used like language keywords.

    If the file to load is specified with an *absolute path*, or is relative to `~` (the user's home directory), then that specific file is loaded.

    Usually, however, the file is specified as a *relative path*, and `load` and `require` search for it relative to the directories of Ruby's load path.

    `require_relative` vs. `require` ?

* * *

#### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
