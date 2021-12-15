---
layout: post
title: "Ruby Notes 2 Datatypes and Objects"
date: 2016-04-05 01:44:27 +0800
categories: ['ruby',]
tags: ['ruby', 'the ruby programming language']
---
1. Numbers

    Ruby includes five built-in classes for representing numbers, and standard library includes three more numeric classes.

    * `Numeric`

        * `Integer`

            * `Fixnum`

            * `Bignum`

        * `Float`

        * `Complex` (standard library)
        * `BigDecimal` (standard library)
        * `Rational` (standard library)

1. Text

    Text is represented in Ruby by objects of the `String` class.

    * **Single-quoted string literals**

        In single-quoted strings, a backslash is not special if the character that follows it is anything other than a quote or a backslash.

            > 'a\b' == 'a\\b'
            => true

    * **Double-quoted string literals**

        Double-quoted literals support quite a few backslash escape sequences, such as `\n` for newline, `\t` for tab, and `\"` for a quotation mark.

        * **String Interpolation**

            Double-quoted literals may also inlcude arbitrary Ruby expression that begin with the `#` character and are enclosed within curly braces:

                "360 degrees=#{2*Math::PI} radians" # "360 degrees=6.28318530717959 radians"

            When the expression to be interpolated into the string literal is simply a reference to a global, instance, or class variable, then the curly braces may be omitted:

                $salutation = 'hello' # Define a global variable 
                "#$salutation world" # Use it in a double-quoted string

            Use a backslash to escape the # character if you do not want it to be treated specially. Note that this only needs to be done if the character after # is {, $, or @:

                "My phone #: 555-1234" # No escape needed
                "Use \#{ to interpolate expressions" # Escape #{ with backslash

    * **Unicode escapes**

        In Ruby 1.9, double-quoted strings can include arbitrary Unicode characters with `\u` escapes.

        Strings that use the `\u` escape are encoded uisng the Unicode ***UTF-8*** encoding.

        1. `\u`

            In its simplest form, `\u` is followed by exactly four hexadecimal digits (letters can be upper- or lowercase), which represent a Unicode codepoint between 0000 and FFFF.

                "\u00D7" # => "×": leading zeros cannot be droppe
                 "\u20ac" # => "€": lowercase letters are okay

        2. `u{}`

            A second form of the `\u` escape is followed by an open curly brace, one to six hexadecimal digits, and a close curly brace.

            The digits between the braces can represent any Unicode codepoint between 0 and 10FFFF. 

                "\u{A5}" # => "¥": same as "\u00A5"
                "\u{3C0}" # Greek lowercase pi: same as "\u03C0" 
                "\u{10ffff}" # The largest Unicode codepoint

            The `\u{}` form of this escape allow multiple codepoints to be embedded within a single escape.

                money = "\u{20AC 20 A3 20 A5}" # => "€ £ ¥"

    * **String Opertors**

        `+`, `<<`, `*`,`==`,`!=`,`<`,`<=`,`>`,`>=`,`[]`

        `casecmp`,`downcase`,`upcase`,`each_byte`,`each_char`,`each_line`

1. Arrays

    An **array** is a sequence of values that allows values to be accessed by their position, or index, in the sequence.

    In Ruby, the first value in an array has index 0.

    The `size` and `length` methods return the number of elements in an array.

    The last element of the array is at index size-1.

    Negative index values count from the end of the array, so the last element of an array can also be accessed with an index of –1 The second-to-last has an index of –2, and so on

     If you attempt to read an element beyond the end of an array (with an index >= size) or before the beginning of an array (with an index < -size), Ruby simply returns `nil` and does *not* throw an exception.

    `+`,`-`,`<<`,`|`,'&`

    `clear`,`each_index`,`empty?`,`sort`,`sort!`,`include?`

1. Hashes

    A **hash** (a.k.a **maps**, **associative arrays**) is a data struture that maintains a set of objects known as *keys*, and associates a value with each key.

    * **Hash Literals**

            numbers = { "one" => 1, "two" => 2, "three" => 3 }
            numbers = { :one => 1, :two => 2, :three => 3 }
            numbers = { :one, 1, :two, 2, :three, 3 } # (Deprecated!) Same, but harder to read
            numbers = { :one => 1, :two => 2, } # Extra comma ignored
            numbers = { one: 1, two: 2, three: 3 } # Ruby 1.9+

1. Ranges

    A **Range** object represents the values between a start value and an end value.

    Range literals are written by placing two or three dots between the start and end value.

        1..10       # The integers 1 through 10, including 10
        1.0...10.0  # The numbers between 1.0 and 10.0, excluding 10.0 itself.

    `member?`,`include?`,`to_a`,`===`

1. Symbols

    Symbols are immutable interned strings, written as colon-prefixed identifiers.

1. True, False, and Nil

    **true** and **false** are the two Boolean values, and they represent truth and falsehood, yes and no, on and off.

    **nil** is a special value reseved to indicate the absence of value.

    TrueClass->true, FalseClass->flase, NilClass->nil.

    Note that **true**, **false**, and **nil** refer to objects, not numbers.

    **false** and **nil** are not the same thing as 0, and **true** is not the same thing as 1.

    When Ruby requires a Boolean value, **nil** behaves like **false**, and any value other than **nil** or **false** behaves like **true**.

1. Objects

    Ruby is a very pure object-oriented language: all values are objects, and there is no distinction between primitive types and object types as there are in many other languages.

    In Ruby, all objects inherit from a class named **Object** (BasicObject?) and share the methods defined by that class.

    * **Object References**

        When we work with objects in Ruby, we are really working with object ***references***.

        When we assign a vlaue to a variable, we are not copying an object "into" that variable; we are merely storing a reference to an object into that variable.

        In Ruby, method arguments are passed by value rather than by reference, but that the values passed are object references.

            s = "Ruby"      # Create a String object. Store a reference to it in s.
            t = s           # Copy the reference to t. s and t both refer to the same object. 
            t[-1] = ""      # Modify the object through the reference in t.
            print s         # Access the modified object through s. Prints "Rub".
            t = "Java"      # t now refers to a different object.
            print s,t       # Prints "RubJava".

    * **Object Lifetime**

        The `new` and `initialze` methods provide the default technique for creating new classes, but classes may aslo define other methods, known as "factory methods".

        Ruby uses a technique called garbage collection to automatically destroy objects that are no longer needed.

        An object becomes a candidate for garbage collection when it is unreachable—when there are no remaining references to the object except from other unreachable objects.

        But garbage collection does *not* mean that *memory leaks* are impossible: any code that creates long-lived references to objects that would otherwise be short-lived can be a source of memory leaks.

    * **Object Identify**

        Every object has an object identifier, a **Fixnum**, that you can obtain with the `object_id` method.

        The value returned by this method is constant and unique for the life of the object.

        The method `id` is a *deprecated* synonym for `object_id`.

        `__id__` is a valid synonym for `object_id`. It exists as a fallback, so you can access an object's ID even if the `object_id` method has been undefined or overridden.

        The `Object` class implements the `hash` method to simply return an object's ID.

    * **Object Class and Object Type**

        1. Determine the class of an object

                o = "test"                      # This is a value
                o.class                       # String: o is a String object
                o.class.superclass            # Object: superclass of String is Object
                o.class.superclass.superclass # nil: Object has no superclass
    
            In Ruby 1.9, `Object` is no longer the true root of the class hierachy.
    
                # Ruby 1.9 only
                Object.superclass
                BasicObject.superclass

        2. Check the class of an object

            * `==`

                    o.class == String       # true if o is a String

            * `instance_of?` method

                *The `instance_of?` method does the same thing and is a litte more elegant than `==`.

                    o.instance_of? String   # true if o is a String

            * `is_a?` and `kind_of?`

                *Use the `is_a?` method, or its synonym `kind_of?` to test if an object is an instance of any subclass of that class.*

                    x = 1                  # This is the value we're working with
                    x.instance_of? Fixnum  # true: is an instance of Fixnum
                    x.instance_of? Numeric # false: instance_of? doesn't check inheritance
                    x.is_a? Fixnum         # true: x is a Fixnum
                    x.is_a? Integer        # true: x is an Integer
                    x.is_a? Numeric        # true: x is a Numeric
                    x.is_a? Comparable     # true: works with mixin modules, too
                    x.is_a? Object         # true for any value of x

                *The `Class` class defines the `===` operator in such a way that it can used in place of `is_a?` but is probaly less readable.*

                    Numeric === x          # true: x is_a Numeric

        3. Ducking Type

            Every object has a well-defined class in Ruby, and that class never changes during the lifetime of the object.

            The type of an object is related to its class, but the class is only part of an object's type.

            The type of an object is the set of methods it can it can respond to.

            In Ruby, we often don't care about the class of an object, we just want to know whether we can invoke some method on it.

            Focusing on types rather than classes leads to a programming style known in Ruby as "ducking typing".

                o.respond_to? :"<<"    # true if o has an << operator

    * **Object Equality**

        1. The `equal?` method

            The `equal?` method is defined by `Object` to test whether two values refer to exactly the same object.

                a.object_id == b.object_id # Works like a.equal?(b)

        2. The `==` operator

            The `==` operator is the most common way to test for equality. In `Object` class, it simply a synonym for `equal?`, and it tests whether two objet references are identical.

            Most classes *redefine* this operator to allow distinct instances to be tested for equality:

            a = "Ruby"  # One String object
            b = "Ruby"  # A different String object with the same content
            a.equal?(b) # false: a and b do not refer to the same object
            a == b      # true: but these two distinct objects have equal values

            ***Equality for Java Programmers: Ruby’s convention is just about the opposite of Java’s.***

        3. The `===` operator

            The `===` operator is commonly called the “case equality” operator and is used to test whether the target value of a `case` statement matches any of the when clauses of that statement.

            `Range` defines `===` to test whether a value falls within the range.

            `Regexp` defines `===` to test whether a string matches the regular expression.

            `Class` defines `===` to test whether an object is an instance of that class.

            In Ruby 1.9, `Symbol` defines `===` to return true if the righthand operand is the same symbol as the left or if it is a string holding the same text. 

                (1..10) === 5       # true: 5 is in the range 1..10
                /\d+/ === "123"     # true: the string matches the regular expression
                String === "s"      # true: "s" is an instance of the class String 
                :s === "s"          # true in Ruby 1.9

    * **Object Order**

        * `<=>`

            In Ruby, classes define an ordering by implementing the `<=>` operator.

            `-1: less than`, `0: equal`, `1: greater than`, `nil: cannot be meaningfully compared`

                1 <=> 5     # -1
                5 <=> 5     # 0
                9 <=> 5     # 1
                "1" <=> 5   # nil: integers and strings are not comparable

        * `Comparable` module as a mixin

            The `<=>` operator is all that is needed to compare values. But it isn’t particularly intuitive.

                < Less than
                <= Less than or equal
                == Equal
                >= Greater than or equal
                > Greater than

            `Comparable` also defines a useful comparison method named `between?`:

                1.between?(0,10)    # true: 0 <= 1 <= 10

            If the `<=>` operator return `nil`, all the comparision operators dervided from it return `false`.

                nan = 0.0/0.0;              # zero divided by zero is not-a-number
                nan < 0                     # false: it is not less than zero
                nan > 0                     # false: it is not greater than zero
                nan == 0                    # false: it is not equal to zero
                nan == nan                  # false: it is not even equal to itself!
                nan.equal?(nan)             # this is true, of course

            *Note that defining `<=>` and including the `Comparable` module defines a `==` operator for your class.*

    * **Object Conversion**

        * Explicit conversions

            Classes define explicit conversion methods for use by application code that needs to convert a value to another representation.

            `to_s`, `to_i`, `to_f`, and `to_a` to convert to `String`, `Integer`, `Float`,  and `Array`.

            Built-in methods do not typically invoke these methods for you.

            * `to_s` and `inspect`

                `to_s` is generally intended to return a human-readable representation of the object, suitalbe for end users.

                `inspect` is tended for debugging use, and should return a representation that is helpful to Ruby developers.

                The default `inspect` method, inherited from `Object`, simply call `to_s`.

        * Implicit conversions

            Sometimes a class has strong characteristics of some other class.

            `to_str`, `to_int`, `to_ary`, `to_hash`, `try_convert`

        * Conversion functions

            The `Kernel` module defines four conversion methods that behave as global conversion functions.

            `Array`, `Float`, `Integer`, `String`

        * Arithmetic operator type coercions

            `Numeric` types define a conversoin method named `coerce` to convert the argument to the same type as the numeric object on which the method is invoked, or to convert both objects to some more general compatible type.

            The `coecre` method always returns an array that holds two numeric values of the same type.

        * Boolean type convrsion

            `to_b`

            There are no implicit conversions that convert other values to `true` or `false`.

            Ruby’s Boolean operators and its conditional and looping constructs that use `Boolean expressions` can work with values other than `true` and `false`.

             In `Boolean expressions`, any value other than `false` or `nil` behaves like (but is not converted to) `true`. `nil`, on the other hand behaves like `false`.

    * **Copying Objects**

        * `clone`, `dup`

            The `Object` class defines two closely related methods `clone` and `dup` for copying objects.

            If copied object includes one internal state that refers to other objects, only the object references are copied, not the referenced objects themselves.

            * `clone` copies both the frozen and tainted state of an object, whereas `dup` only copies the tainted state; calling `dup` on a frozen object returns an unfrozen copy.

            * `clone` copies any singleton methods of the object, whereas `dup` does not.

        * `initialize_copy`

            `initialize_copy` method could recursively copy the internal data of an object so the resulting object is not a simple shallow copy of the original.

    * **Marshaling Objects**

        `Mrshal.dump`,`Marshal.load`

    * **Freezing Objects**

        Any object may be *frozen* by calling its `freeze` method.

        A frozen object becomes immutable.

        Freezing a class object prevents the addition of any methods to the class.

        Once frozen, there is no way to "thaw" an object.

        If you copy a frozen object with `clone`, the copy will also be frozen.

        If you copy a frozen object with `dup`, however, the copy will not frozen.

            s = "ice"     # Strings are mutable objects
            s.freeze      # Make this string immutable
            s.frozen ?    # true: it has been frozen
            s.upcase!     # TypeError: can't modify frozen string 
            s[0] = "ni"   # TypeError: can't modify frozen string

    * **Tainting Objects**

       `taint`, `untaint`, `$$SAFE` 

* * *

#### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
