---
layout: post
title: "Ruby Notes 3 Expression and Operators"
date: 2016-04-05 04:35:28 +0800
categories: ['ruby',]
tags: ['ruby', 'the ruby programming language']
---
An *expression* is a chunk of Ruby code that the Ruby interpreter can evaluate to produce a value.

In Ruby, they is no clear distinction between statements and expressions; everything in Ruby, including class and method definitions, can be evaluated as expression and will return a value.

### Literals and Keyword Literals

*Primary Expressions*, *Compound Expression*

**Literals** are values such as `1.0`, `'hello world'`, and `[]` that are embedded directly into your program text. 

Certain Ruby keywords are primary expression can can be considered **Keyword literals** or specialized forms of variable reference:

* `nil`

    Evaluates to the nil value, of class NilClass.

* `true`

Evaluates to the singleton instance of class TrueClass, an object that represents the Boolean value true.

* `false`

    Evaluates to the singleton instance of class FalseClass, an object that represents the Boolean value false.

* `self`

    Evaluates to the current object.

* `__FILE__`

    Evaluates to a string that names the file that the Ruby interpreter is executing. This can be useful in error messages.

* `__LINE__`

    Evaluates to an integer that specifies the line number within __FILE__ of the current line of code.

* `__ENCODING__`

    Evaluates to an Encoding object that specifies the encoding of the current file. (Ruby 1.9 only.)

### Variable References

A *variable* is simply a name for a value.

When the name of a variable appears in a program anywhere other than lefthand side of an assignment, it is a variable refernece expression and evaluates to the value of the variable:

    one = 1.0   # This is an assignment expression
    one         # This varible reference expression evaluates to 1.0

* There are four kinds of variables in Ruby.

    * global variables

        Variables that begin with `$` are global variables, visible throughout a Ruby program.

    * instance variables and class variables

        Variables that begin with `@` and `@@` are instance variables and class varibles, used in object-oriented programming.

    * local varibles

        Varibles whose names begin with an *underscore* or a *lowercase* letter are locale varibles, defined only within the current method or block.

#### Uninitialized Variables

In general, you should always assign a value to, or *initialize*, your variables before using them in expressions.

In some cirumstances, however, Ruby will allow you to use variables that have not yet been intialized.

* Class varibles

    Class variables must always have a value assign to them before they are used.

    Ruby raises a `NameError` if you refer to a class variable to which no value has been assigned.

* Instance variables

    If you refer to an unitialized instance variable, Ruby returns `nil`.

    It is considered bad programming to reply on this behavior, however.

    Ruby will issue a warning about the unitialized variable if you run it with the `-w` option.

* Global varialbes

    Unitialized global variables are like unitialzied instance variables: they evaluate to `nil`, but cause a warning when Ruby is run with the `-w` flag.

* Local variables

    If the Ruby interpreter has seen an assignment to a local variable, it knows it is a variable and not a method, and it can return the value of the varialbe.

    If there has been no assignment, then Ruby treats the expression as a method invocation.

    If no method by that name exists, Ruby raises a `NameError`.

    A variable that exists but has not been assigned a value is given the default value `nil`.

        a = 0.0 if false    # This assignment is never executed
        print a             # Prints nil: the variable exits but is not assigned
        print b             # NameError: no variable or method named b exists

### Constant References

The Ruby interpreter does not actually enforce the constancy of constants, but it does issue a warning if a program changes the value of a constant.

Lexically, the names of constants look like the name of local variables, execpt that they begin with a *capital letter*.

By convention, most constants are written in all upcase with underscores to separate words, `LIKE_THIS`.

Ruby class and module names are also constants, but they are conventionally written using initial capital letters and camel case, `LikeThis`.

A constant reference is an expression that evaluates to the value of the named constant.

* `::`

    `::` is used to separate the name of the constant from the class or module in which it is defined.

    The lefthand side of the `::` may be an arbitrary expression that evaluates to a class or module object. The righthand side of the `::` is the name of a constant defined by the class or module.

The lefthand side of the :: may be omitted, in which case the constant is looked up in the global scope.

    CM_PER_INCH = 2.54          # Define a constant.
    CM_PER_INCH                 # Refer to the constant. Evaluates to 2.54.

    Conversions::CM_PER_INCH    # Constant defined in the Conversions module
    modules[0]::NAME            # Constant defined by an element of an array

    Conversions::Area::HECTARES_PER_ACRE    # Modules may be nested.

    ::ARGV      # The left side of the :: may be omitted.

*Note that there is not actually a "global scope" for constants. Like global funcitons, global constants are defined (and looked up) within the `Object` class. The expression `::ARGV`, therefore, is simply shorthand for `Object::ARGV`.*

When Ruby evaluates a constant reference expression, it returns the value of the constant, or it raises a `NameError` exception if no constant by that name could be found.

Note that constants do not exist unitl a value is acctually assigned to them.

### Method Invocations

A method invocation expression has four parts:

* An arbitrary expression whose value is the object on which the method is invoked. This expression is followed by `.` or `::` to separate it from the method name that follows. The expression and separator are optional; if omitted, the method invoked on `self`.

* The name of the method beging invoked.

* The argument values being passed to the method.

* An optional block of code delimited by curly braces or by a `do/end` pair.

The value of a method invocation expression is the value of the last evaluated epxression in th body of the mehtod.

Methods defined by `Kernel` are global functions, and global fuctions are defined as private methods of the `Object` class.

If a variable named *x* exists (that is, if the Ruby interpreter has seen an assignment to *x*), then this is a variable reference expression. If no such variable exits, then this is an invocation of the method *x*, with no arguments, on `self`.

### Assignments

An assignment expression specifies on or more values for one or more lvalues.

**lvalue** is the term for something that can appear on the lefthand side of an assignment operator. (Values on the righthand side of an assignment operator are sometimes called **rvalues** by contrast.)

Variables, constants, attributes, and array elements are lvalues in Ruby.

The value of an assignment expression is the value (or an array of the values) assigned.

The assignment operator is "right-associative"—if multiple assignments appear in a single expression, they are evaluated from right to left.

    x = 1           # Set the lvalue x to the value 1
    x += 1          # Set the lvalue x to the value x + 1
    x,y,z = 1,2,3   # Set x to 1, y to 2 and z to 3
    x = y = 0       # Set x and y to 0

* Assiging to Variables

A simple expression such as `x` could refer to a local variable named `x` or a method of `self` named `x`. To resolve this ambiguity, Ruby treats an identifier as a local variable if it has been seen any previous assignment to the variable. It does this even if that assignment was never executed.

    class Ambiguous
      def x; 1; end # A method named "x". Always returns 1

      def test
        puts x      # No variable has been seen; refers to method above: prints 1
    
        # The line below is never evaluated, because of the "if false" clause. But
        # the parser sees it and treats x as a variable for the rest of the method.
        x = 0 if false
    
        puts x    # x is a variable, but has never been assigned to: prints nil
    
        x = 2     # This assignment does get evaluated
        puts x    # So now this line prints 2
      end
    end

* Assigning to Constants

    * Assignment to a constant that already extists causes Ruby to issue a warning.

    * Assignment to constants is not allowed within the body of a method.

    * Unlike variables, constants do not come into extistence until the Ruby interpreter actually executes the assignment expression.

* Assigning to Arributes and Array Elements

Assignment to an attribute or array element is actually Ruby shorthand for mehtod invocation.

    o.m = v
    o.m=(v)

    o[x] = y
    o[](x,y)

    o[x,y] = z
    o[](x,y,z)

* Abbreviated Assigment

        x += y       x = x + y
        x -= y       x = x - y
        x *= y       x = x * y
        x /= y       x = x / y
        x %= y       x = x % y
        x **= y      x = x ** y
        x &&= y      x = x && y
        x ||= y      x = x || y
        x &= y       x = x & y
        x |= y       x = x | y
        x ^= y       x = x ^ y
        x <<= y      x = x << y
        x >>= y      x = x >> y

* Parallel Assignment

    * Same number of lvalues and rvalues
    
        x, y, z = 1, 2, 3   # x=1; y=2; z=3
        x, y = y, x         # Parallel: swap the value of two variables
    
    * One lvalue, multiple rvalues
    
        x = 1, 2, 3         # x = [1, 2, 3]
        x, = 1, 2, 3        # x = 1; other values are discarded

    * Multiple lvalues, single array rvalue

            x, y, z = [1, 2, 3] # Same as x,y,z = 1,2,3

            x = [1,2]  # x becomes [1,2]: this is not parallel assignment
            x, = [1,2] # x becomes 1: the trailing comma makes it parallel

    * Different numbers of lvalues and rvalues

            x, y, z = 1, 2  # x=1, y=2; z=nil
            x, y  = 1, 2, 3 # x=1, y=2, 3 is not assigned anywhere

    * The splat operator

        lvalues and rvalues may be prefixed with *, which is sometimes called the *splat operator*, though it is not a true operator.

            x, y, z = 1, *[2,3] # Same as x,y,z = 1,2,3
            x, *y = 1, 2, 3 # x=1; y=[2,3]
            x, *y = 1, 2    # x=1; y=[2]
            x, *y = 1       # x=1; y=[]

            *x, y = 1, 2, 3 # x=[1,2]; y=3
            *x,y  = 1, 2    # x=[1]; y=2
            *x,y  = 1       # x=[]; y=1

            x, y , *z = 1, *[2,3,4] # x=1; y=2; z=[3,4]

    * Parentheses in parallel assigment

            x, (y,z) = a, b # x = a; y, z = b

            x, y, z = 1,[2,3]   # No parens: x=1;y=[2,3];z=nil
            x,(y,z) = 1,[2,3]   # Parens: x=1; y=2; z=3

            a,b,c,d = [1,[2,[3,[4]]]]  # No parens: a=1; b=[2,[3,4]]; c=d=nil
            a,(b,(c,(d))) = [1,[2,[3,[4]]]] # parens: a=1;b=2;c=3;d=4

    * The value of parallel assignment

        The return value of a parallel assignment expression is the array of rvalues.

        * Parallel Assignment and Method Invocation

                puts x,y=1,2    # puts (x,y=1,2)
    
                puts ((x,y=1,2))

### Operators

*Ruby operators, by precedence (high to low), with arity (N), associativity (A), and definability (M)*

    Operator(s)            N    A    M    Operation
    
    ! ~ +                  1    R    Y    Boolean NOT, bitwise complement, unary plusa
    **                     2    R    Y    Exponentiation
    -                      1    R    Y    Unary minus (define with -@)
    * / %                  2    L    Y    Multiplication, division, modulo (remainder)
    + -                    2    L    Y    Addition (or concatenation), subtraction
    << >>                  2    L    Y    Bitwise shift-left (or append), bitwise shift-right
    &                      2    L    Y    Bitwise AND
    | ^                    2    L    Y    Bitwise OR, bitwise XOR
    < <= >= >              2    L    Y    Ordering
    == === != =~ !~ <=>    2    N    Y    Equality, pattern matching, comparisonb
    &&                     2    L    N    Boolean AND
    ||                     2    L    N    Boolean OR
    .. ...                 2    N    N    Range creation and Boolean flip-flops
    ?:                     3    R    N    Conditional
    rescue                 2    L    N    Exception-handling modifier
    =                      2    R    N    Assignment
    **= *= /= %= += -=        
    <<= >>=
    &&= &= ||= |= ^=
    defined?               1    N    N    Test variable definition and type
    not                    1    R    N    Boolean NOT (low precedence)
    and or                 2    L    N    Boolean AND, Boolean OR (low precedence)
    if unless while until  2    N    N    Conditional and loop modifiers

* Nonoperators

    * `()`

        Parenthese are an optinal part of method definition and invocation syntax.

        Parentheses are also used for grouping to affect the order of evaluation of subexpressions.

    * `[]`

        Square brackets are used in array literals and for quering and setting array and hash values. In that context, they are syntactic sugar for method invocation and behave somewhat like redefinable operators with arbitrary arity.

    * `{}`

        Curly braces are alternative to `do/end` in blocks, and are also used in hash literals.

    * `.` and `::`

        `.` and `::` are used in qualified names.

    * `;`,`,` and `=>`

        The semicolon `;` is used to separate stateemnts on the same line;

        the comma `,` is used to separate method arguments and the elements of array and hash literals;

        and the arrow `=>` is used to separate hash keys from hash values in hash literals.

    * `:`

        A colon is used to prefix symbol literals and is also used in Ruby 1.9 hash syntax.

    * `*`,`&` and `<`

        Putting `*` before array in an assinment or method invocation expression expands or unpacks the array into its individual elements.

        `&` can be used in a method declaration before the name of the last method argument, and this cause any block passed to the method to be assigned to that argument.

        `<` is used in class definitions to specify the superclass of class.

* * *

### References

* [The Ruby Programming Language by David Flanagan and Yukihiro Matsumoto](http://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1459784613&sr=8-1&keywords=The+Ruby+Programming+Language)
