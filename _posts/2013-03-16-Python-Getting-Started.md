---
disqus_identifier: 102799273928567868197245214345597966628
layout: post
title: "02 Python Getting Started"
date: 2013-03-16 10-06-56 +0800
categories: ['Core.Python.Programming',]
tags: ['Core.Python.Programming', 'Python']
---
* 􀁺 介绍
* 􀁺 输入/输出
* 􀁺 注释
* 􀁺 操作符
* 􀁺 变量与赋值
* 􀁺 Python 类型
* 􀁺 缩进
* 􀁺 循环与条件
* 􀁺 文件
* 􀁺 错误
* 􀁺 函数
* 􀁺 类
* 􀁺 模块

#### 2.3 注释 

* 普通注释

    和大部分脚本及Unix-shell 语言一样，Python 也使用 # 符号标示注释，从 # 开始，直到一行结束的内容都是注释。 

        >>> # one comment 
        ... print 'Hello World!' # another comment 
        Hello World! 

* 文档字符串 

    有一种叫做文档字符串的特别注释。

    你可以在模块、类或者函数的起始添加一个字符串，起到在线文档的功能，这是Java 程序员非常熟悉的一个特性。 

        def foo(): 
            "This is a doc string." 
            return True 
    
    与普通注释不同，文档字符串可以在运行时访问，也可以用来自动生成文档。

* 编码声明注释(The -*- symbols)

         # -*- coding: latin-1 -*-

     Python looks for coding: name or coding=name in the comment.

    If you don’t include such a comment, the default encoding used will be ASCII.

* Unix Executable Scripts(#!)

    If you are goning to use Python on a Unix,  Linux,or Unix-like system, you can also turn files of Python code into executable programs, much as you would for programs coded in a sheel language such as csh or ksh. Such files are usually called executable scripts. In simple terms, Unix-style executable scripts are just normal text files containing Python statements, but with two special properties:

    * Their first line is special. 

        Script usually start with a line that begins with the characters *#!* (often called "hash bang"), followed by the path(the operating system uses it to find an interpreter for running the program code in the rest of the file) to the Python interpreter on your machine.

    * They usually have executable privileges. 

        Script files are usually marked as executable to tell the opration system that they may be run as top-level programs. On Unix systems, a comamnd such as *chmod +x file.py* usually does thi trick.

#### 2.4 运算符

* 标准运算符：    +     -     *     /     //     %     **

    加、减、乘、除和取余都是标准运算符。

    Python 有两种除法运算符，单斜杠用作传统除法，双斜杠用作浮点除法（舍弃小数点的数）。

    传统除法是指如果两个操作数都是整数的话，它将执行是地板除(取比商小的最大整数)，而浮点除法是真正的除法，不管操作数是什么类型，浮点除法总是执行真正的除法。还有一个乘方运算符， 双星号(**)。

        >>> 1/3
        0
        >>> 1//3
        0
        >>> 1.0/3
        0.3333333333333333
        >>> 1.0//3
        0.0
        >>> 1.9//1
        1.0

* 比较运算符：<     <=     >     >=     ==     !=     <>

* 逻辑运算符：and     or     not

* 索引运算符：[ ]

* 切片运算符：[ : ]

*核心风格：合理使用括号增强代码的可读性，在很多场合使用括号都是一个好主意，而没用括号的话，会使程序得到错误结果，或使代码可读性降低，引起阅读者困惑。括号在Python语言中不是必须存在的， 不过为了可读性，使用括号总是值得的。任何维护你代码的人会感谢你，在你再次阅读自己的代码时，你也会感谢你自己。*

#### 2.5 变量和赋值

Python 中变量名规则与C语言一样。

Python 是动态类型语言，也就是说不需要预先声明变量的类型。

变量的类型和值在赋值那一刻被初始化。

变量赋值通过等号来执行。

*Python 不支持C 语言中的自增1 和自减1 运算符，这是因为 + 和 － 也是单目运算符，Python 会将 --n 解释为-(-n) 从而得到 n , 同样 ++n 的结果也是 n.*

#### 2.6 数字

Python 支持五种基本数字类型，其中有三种是整数类型。

* 􀁺 int (有符号整数)
* 􀁺 long (长整数)
* 􀁺 bool (布尔值) (True(1), False(0))
* 􀁺 float (浮点值)
* 􀁺 complex (复数)

*布尔值是特殊的整数。尽管布尔值由常量 True 和 False 来表示，如果将布尔值放到一个数值上下文环境中（比方将 True 与一个数字相加），True 会被当成整数值 1，而False则会被当成整数值 0。*

#### 2.7 字符串

Python 中字符串被定义为引号之间的字符集合。

Python 支持使用成对的单引号或双引号，三引号（三个连续的单引号或者双引号）可以用来包含特殊字符。

使用索引运算符( [ ] )和切片运算符( [ : ] )可以得到子字符串。

字符串有其特有的索引规则：第一个字符的索引是 0，最后一个字符的索引是 －1。

加号( + )用于字符串连接运算，星号( * )则用于字符串重复。

#### 2.8 列表和元组

可以将列表和元组当成普通的“数组”，它能保存任意数量任意类型的Python 对象

和数组一样，通过从0 开始的数字索引访问元素，但是列表和元组可以存储不同类型的对象。

* 列表和元组有几处重要的区别。

    * 列表元素用中括号( [ ])包裹，元素的个数及元素的值可以改变。
    * 元组元素用小括号(( ))包裹，不可以更改（尽管他们的内容可以）。*元组可以看成是只读的列表。*

通过切片运算( [ ] 和 [ : ] )可以得到子集，这一点与字符串的使用方法一样。

#### 2.9 字典

字典是Python 中的映射数据类型，工作原理类似Perl 中的关联数组或者哈希表，由键-值(key-value)对构成。

几乎所有类型的Python 对象都可以用作键，不过一般还是以数字或者字符串最为常用。

值可以是任意类型的Python 对象，字典元素用大括号({ })包裹。

    >>> aDict = {'host': 'earth'} # create dict 
    >>> aDict['port'] = 80 # add to dict 
    >>> aDict 
    {'host': 'earth', 'port': 80}
    >>> aDict.keys() 
    ['host', 'port']
    >>> aDict['host'] 
    'earth'
    >>> for key in aDict: 
    ... print key, aDict[key]
    ...
    host earth

#### 2.10 代码块及缩进对齐

代码块通过缩进对齐表达代码逻辑而不是使用大括号，因为没有了额外的字符，程序的可读性更高。而且缩进完全能够清楚地表达一个语句属于哪个代码块。当然，代码块也可以只有一个语句组成。

***也许你会发现生活中没有大括号并不会象你想像的那么糟糕。***

#### 2.11 if 语句

标准if 条件语句的语法如下：

    if expression:
        if_suite

如果表达式的值非0 或者为布尔值True, 则代码组 if_suite 被执行; 否则就去执行下一条语句。 

*代码组是一个Python 术语， 它由一条或多条语句组成，表示一个子代码块。Python与其它语言不同， 条件条达式并不需要用括号括起来。*

Python 当然也支持 else 语句， 语法如下：

    if expression:
        if_suite
    else:
        else_suite

Python 还支持 elif （意指 “else-if ”）语句，语法如下:

    if expression1:
        if_suite
    elif expression2:
        elif_suite
    else:
        else_suite

#### 2.12 while 循环

标准while 条件循环语句的语法类似if. 再说一次，要使用缩进来分隔每个子代码块。

    while expression:
        while_suite

语句 while_suite 会被连续不断的循环执行， 直到表达式的值变成 0 或 False; 接着Python 会执行下一句代码。 

类似if 语句，Python 的while 语句中的条件表达式也不需要用括号括起来。

#### 2.13 for 循环和range()内建函数

Python 中的for 循环与传统的for 循环（计数器循环）不太一样， 它更象shell 脚本里的foreach 迭代。

Python 中的for 接受可迭代对象（例如序列或迭代器）作为其参数，每次迭代其中一个元素。

#### 2.14 列表解析

这是一个让人欣喜的术语，表示你可以在一行中使用一个for 循环将所有值放到一个列表当中：

    >>> squared = [x ** 2 for x in range(4)]
    >>> for i in squared:
            print i

    0
    1
    4
    9

列表解析甚至能做更复杂的事情，比如挑选出符合要求的值放入列表：

    >>> sqdEvens = [x ** 2 for x in range(8) if not x % 2]
    >>>
    >>> for i in sqdEvens:
            print i

    0
    4
    16
    36

#### 2.15 文件和内建函数open() 、file()

在你已经习惯一门语言的语法之后， 文件访问是相当重要的一环。在一些工作做完之后，将它保存到持久存储是很重要的。

* 如何打开文件

        handle = open(file_name, access_mode = 'r')

    file_name 变量包含我们希望打开的文件的字符串名字， access_mode 中 'r' 表示读取，'w' 表示写入， 'a' 表示添加。其它可能用到的标声还有 '+' 表示读写， 'b'表示二进制访问. 如果未提供 access_mode ， 默认值为 'r'。如果 open() 成功， 一个文件对象句柄会被返回。所有后续的文件操作都必须通过此文件句柄进行。当一个文件对象返回之后， 我们就可以访问它的一些方法， 比如 readlines() 和close()。文件对象的方法属性也必须通过句点属性标识法访问

* *核心笔记：什么是属性？*

    属性是与数据有关的项目，属性可以是简单的数据值，也可以是可执行对象，比如函数和方法。哪些对象拥有属性呢？ 很多。 类，模块，文件还有复数等等对象都拥有属性。

    我如何访问对象属性？使用句点属性标识法。也就是说在对象名和属性名之间加一个句点：object.attribute.

#### 2.16 错误和异常

编译时会检查语法错误，不过 Python 也允许在程序运行时检测错误。

当检测到一个错误，Python 解释器就引发一个异常，并显示异常的详细信息。程序员可以根据这些信息迅速定位问题并进行调试，并找出处理错误的办法。

要给你的代码添加错误检测及异常处理，只要将它们封装在 try-except 语句当中。try之后的代码组，就是你打算管理的代码。except 之后的代码组，则是你处理错误的代码。

    try:
        filename = raw_input('Enter file name: ')
        fobj = open(filename, 'r')
        for eachLine in fobj:
            print eachLine, fobj.close()
    except IOError, e:
        print 'file open error:', e

程序员也可以通过使用 raise 语句故意引发一个异常。

#### 2.17 函数

类似其它的语言，Python 中的函数使用小括号( () )调用。

函数在调用之前必须先定义。

如果函数中没有return 语句，就会自动返回 None 对象。

Python 是通过引用调用的。这意味着函数内对参数的改变会影响到原始对象。不过事实上只有可变对象会受此影响，对不可变对象来说，它的行为类似按值调用。

* 如何定义函数

        def function_name([arguments]):
            "optional documentation string"
            function_suite

    定义一个函数的语法由 def 关键字及紧随其后的函数名再加上该函数需要的几个参数组成。

    函数参数（比较上面例子中的arguments)是可选的， 这也是为什么把它们放到中括号中的原因。（在你的代码里千万别写上中括号！）这个语句由一个冒号(:)结束（与if 和while语句的结束方式一样）， 之后是代表函数体的代码组， 下面是一个简短的例子：

        def addMe2Me(x):
            'apply + operation to argument'
            return (x + x)

    这个函数， 干的是“在我的值上加我”的活。它接受一个对象将它的值加到自身，然后返回和。对于数值类型参数，它的结果是显而易见的，不过我要在这里指出，加号运算符几乎与所有数据类型工作。换句话说，几乎所有的标准数据类型都支持 + 运算符，不管是数值相加还是序列合并。

* 如何调用函数

        >>> addMe2Me(4.25)
        8.5
        >>>
        >>> addMe2Me(10)
        20
        >>>
        >>> addMe2Me('Python')
        'PythonPython'
        >>>
        >>> addMe2Me([-1, 'abc'])
        [-1, 'abc', -1, 'abc']

    Python 语言中调用函数与在其它高级语言中一样，函数名加上函数运算符，一对小括号。

    括号之间是所有可选的参数。

    即使一个参数也没有，小括号也不能省略。注意一下， + 运算符在非数值类型中如何工作。
默认参数

函数的参数可以有一个默认值，如果提供有默认值，在函数定义中，参数以赋值语句的形式提供。事实上这仅仅是提供默认参数的语法，它表示函数调用时如果没有提供这个参数，它就取这个值做为默认值。

        >>> def foo(debug=True):
        ... 'determine if in debug mode with default argument'
        ... if debug:
        ... print 'in debug mode'
        ... print 'done'
        ...
        >>> foo()
        in debug mode
        done
        >>> foo(False)
        done

#### 2.18 类

类是面向对象编程的核心，它扮演相关数据及逻辑的容器角色。

类提供了创建“真实”对象(也就是实例)的蓝图。因为Python 并不强求你以面向对象的方式编程（与Java 不同） 此刻你也可以不学习类。

* 如何定义类

        class ClassName(base_class[es]):
        "optional documentation string"
        static_member_declarations
        method_declarations

   使用 class 关键字定义类。 

    可以提供一个可选的父类或者说基类; 如果没有合适的基类，那就使用 object 作为基类。

    class 行之后是可选的文档字符串，静态成员定义，及方法定义。

* __init__() 方法

    当一个类实例被创建时，__init__() 方法会自动执行，在类实例创建完毕后执行，类似构建函数。

    __init__() 可以被当成构建函数，不过不象其它语言中的构建函数，它并不创建实例--它仅仅是你的对象创建后执行的第一个方法。它的目的是执行一些该对象的必要的初始化工作。通过创建自己的 __init__() 方法，你可以覆盖默认的 __init__()方法（默认的方法什么也不做），从而能够修饰刚刚创建的对象。

* self.

    什么是 self ? 它是类实例自身的引用。其他语言通常使用一个名为 this 的标识符。

* 如何创建类实例

        >>> foo1 = FooClass()

    创建一个类实例就像调用一个函数，它们确实拥有一样的语法。它们都是可调用对象。类实例使用同样的函数运算符调用一个函数或方法。

#### 2.19 模块

模块是一种组织形式，它将彼此有关系的Python 代码组织到一个个独立文件当中。

模块可以包含可执行代码，函数和类或者这些东西的组合。

* 如何导入模块

    import  module_name

* 如何访问一个模块

    函数或访问一个模块变量一旦导入完成，一个模块的属性（函数和变量）可以通过熟悉的**.**句点属性标识法访问。

### 2.20 实用的函数

对新Python 程序员有用的内建函数

    函数                                  描述
    dir([obj])  显示对象的属性，如果没有提供参数， 则显示全局变量的名字
    help([obj]) 以一种整齐美观的形式 显示对象的文档字符串， 如果没有提供任何参数， 则会进入交互式帮助。
    int(obj)    将一个对象转换为整数
    len(obj)    返回对象的长度
    open(fn, mode)   以 mode('r' = 读， 'w'= 写)方式打开一个文件名为 fn 的文件
    range([[start,]stop[,step])   返回一个整数列表。起始值为 start, 结束值为 stop - 1; start默认值为 0， step默认值为1。
    raw_input(str)  等待用户输入一个字符串， 可以提供一个可选的参数 str 用作提示信息。
    str(obj)        将一个对象转换为字符串
    type(obj)       返回对象的类型（返回值本身是一个type 对象！）

- - -
