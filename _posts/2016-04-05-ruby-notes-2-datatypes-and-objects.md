---
layout: post
title: "Ruby Notes 2 Datatypes and Objects"
date: 2016-04-05 01-44-27 +0800
categories: ['Ruby',]
tags: ['Ruby',]
disqus_identifier: 93736917096573817128848063245533052220
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
            t= s            # Copy the reference to t. s and t both refer to the same object. 
            t[-1] = ""      # Modify the object through the reference in t.
            print s         # Access the modified object through s. Prints "Rub".
            t = "Java"      # t now refers to a different object.
            print s,t       # Prints "RubJava".

    * **Object Lifetime**

        The `new` and `initialze` methods provide the default technique for creating new classes, but classes may aslo define other methods, known as "factory methods".

        Ruby uses a technique called garbage collection to automatically destroy objects that are no longer needed.

        An object becomes a candidate for garbage collection when it is unreachable—when there are no remaining references to the object except from other unreachable objects.

        But garbage collection does *not* mean that *memory leaks* are impossible: any code that creates long-lived references to objects that would otherwise be short-lived can be a source of memory leaks.

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

    * **Marshaling Objects**

        `Mrshal.dump`,`Marshal.load`

* * *

#### References

* [The Ruby Programming LanguageFeb by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
