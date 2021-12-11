---
layout: post
title: "认识与学习 BASH"
date: 2016-11-16 09:30:39 +0800
categories: ['linux']
tags: ['linux', 'shell', 'bash']
---
## 硬件、核心与 Shell

**Shell, KDE, application** -> **核心( Kernel)** -> **硬件( Hardware)**

## Bash shell 功能

bash 是 GNU 计划中重要的工具软件之一，目前也是 Linux distributions 的标准 shell。bash 主要兼容于 sh，并且依据一些使用者的需求，而加强的 shell 版本。

- 命令编修能力(history)
- 命令与档案补全功能: ([tab] 按键的好处)

    - [Tab] 接在一串指令的第一个字的后面，则为命令补全；
    - [Tab] 接在一串指令的第二个字以后时，则为『档案补全』
- 命令别名设定功能: (alias)
- 工作控制、前景背景控制: (job control, foreground, background)
- 程序化脚本: (shell scripts)
- 通配符: (Wildcard)

    除了完整的字符串之外，base 还支持许多的通配符来帮助用户查询与指令下达。

## Bash shell 的内建命令: type

```
# type [-tpa] name
选项不参数：
：不加任何选项不参数时，type 会显示出 name 是外部指令还是 bash 内建指令
-t ：当加入 -t 参数时，type 会将 name 以底下这些字眼显示出他的意义：
    file ：表示为外部指令；
    alias ：表示该指令为命令删名所讴定的名称；
    builtin ：表示该指令为 bash 内建的指令功能；
-p ：如果后面接的 name 为外部指令时，才会显示完整文件名；
-a ：会由 PATH 发量定义的路径中，将所有吨 name 的指令都列出来，包含 alias
```

## 变量的取用与设定: echo, unset
- 变量的取用: echo

        # echo $PATH
        /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/local/go/bin:/opt/local/java/bin:/opt/local/scala/bin 

    变量的读取只需要在变量名前面加上 `$`,或者以 `${变量}` 的方式来取用都可以。

- 变量设定规则
    1. 变量与变量内容以一个等号『=』来连结，如下所示：

        ```
        myname=myvalue
        ```

    2. 等号两边不能直接接空格符，如下所示错误：

            myname = myvalue
            myname=my value

    3. 变量名称只能是英文字符与数字，但是开头字符不能是数字，如下为错误：

        ```
        2myname=myvalue
        ```

    4. 变量内容若有空格符可以使用双引号`"`或者单引号`'`将变量内容结合起来，但
        - 双引号的特殊字符如 `$` 等，可以保有原本的特性，如下所示：

            `var="lang is $LANG"` 则 `echo $var` 可得 `lang is en_US`

        - 单引号的特殊字符则仅为一般字符（纯文本），如下所示：

            `var=`lang is $LANG` 则 `echo $var` 可得 `lang is $LANG`

    5. 可用跳脱字符`\`将特殊字符（如[Enter], $, \, 空格符，'等）变成一般字符
    6. 在一串指令中，还需要藉由奇特的指令提供的信息，可以使用反单引号`指令`或`$(指令)`。例如想要去的核心版本的设定：

        `version=$(uname -r)` 在 `echo $version` 可得 `3.16.0-4-amd64`

    7. 若该变量为扩增变量内容时，则可以用`"$变量名称"` 或者 `${变量}`累加内容，如下所示：

        `PATH="$PATH":/home/bin`

    8. 若该变量需要在其他子程序执行，则需要以 **export** 来使变量变成环境变量:

        `export PATH`

    9. 通常大写字符为系统默认变量，自行设定变量可有使用小写字符，方便判断（纯粹依照使用者的兴趣与嗜好）
    10. 取消变量的方法是使用 **unset**: `unset 变量`,例如取消 `myname` 的设定：

        `unset myname`

## 环境变量的功能: (env 与 export)

- HOME

    代表用户的家目录

- SHELL

    目前环境使用的 SHELL 是那支程序。Linux 预设时候用 /bin/bash 。

- HISTSIZE

- MAIL

- PATH

    执行文件的搜索目录，目录与目录之间以冒号(:)分隔，档案的搜寻是依序由 PATH 的变量内的目录来查询

- LANG

- RANDOM

    随机数变量

## SHELL 的操作接口有关的变量

- PS1: (命令提示字符的设定)


        $ echo $PS1
        \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$

- $: (关于本 shell 的 PID)

        ~$ echo $$
        631

- ?: (关于上个执行指令的回传值)

        $ ehco $?
        -bash: ehco: command not found
        $ echo $?
        127

- OSTYPE, HOSTTYPE, MACHTYPE: (主机硬件与核心的等级)

        $ echo $OSTYPE
        linux-gnu
        $ echo $HOSTTYPE
        x86_64
        $ echo $MACHTYPE
        x86_64-pc-linux-gnu

    较高阶的硬件通常会向下兼容旧有的软件，但较高的软件可能无法在就机器上面安装！

- export: 自定义变量转成环境变量
- declare: 环境变量转成自定义变量

## 影响显示结果的语系变量 (locale)

```
$ locale
LANG=en_US.UTF-8
LANGUAGE=
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=
```

## 变量的有效范围

环境变量=全局变量 (global variable)
自定义变量=局部变量 (local variable)

为什么环境变量的数据可以被子程序所引用呢？

- 当启动一个 shell，操作系统会分配一记忆区块给 shell 使用，此内存之变量可以让子程序取用
- 若在父程序利用 export 功能，可以让自定义变量的内容写到上述的记忆区快当中 (环境变量)
- 当加载另一个 shell 时（亦即启动子程序，而离开原本的父程序了），子 shell 可以将父 shell 的环境变量所在的记忆区快导入自己的环境变量区快当中

『环境变量』与『bash 的操作环境』意思不太一样，举例来说，PS1 并不是环境变量，但是这个 PS1 会影响到 bash 的接口 (命令提示符).

## 变量键盘读取、数组与宣告：read, array, declare

- read

    读取来自键盘输入的变量

        read [-pt] variable
        选项不参数：
        -p ：后面可以接提示字符！
        -t ：后面可以接等待的『秒数！』这个比较有趣～不会一直等待使用者啦！

- declare / typeset

    declare 或 typeset 是一样的功能，就是在『宣告变量的类型』.

        declare [-aixr] variable
        选项不参数：
        -a ：将后面名为 variable 的变量定义成为数组 (array) 类型
        -i ：将后面名为 variable 的变量定义成为整数数字 (integer) 类型
        -x ：用法与 export 一样，就是将后面的 variable 发成环境发量
        -r ：将变量设定成为 readonly 类型，该变量不可被更改内容，也不能 unset

    - 变量类型默认为『字符串』，所以若不指定变量类型，则 1 + 2 为一个『字符串』而不是『计算式』
    - bash 环境中的数值运算，预设最多仅能达整数形态，所以 1 / 3 结果是 0

- 数组（array）变量类型

    在 bash 里头，数组的设定方式是：

        var[index]=content

## 命令别名设定：alias, unalias

    $ alias
    alias grep='grep --color=auto'
    alias jekyllp='/home/x/repos/jekyll-kit/jekyll-post.py'
    alias jekylls='bundle exec jekyll serve'
    alias ls='ls --color=auto'
    alias rvm-restart='rvm_reload_flag=1 source '\''/home/x/.rvm/scripts/rvm'\'''

## 历史命令: history

    history [-raw] histfiles
    选项不参数：
    n ：数字，意思是『要列出最近的 n 笔命令行表』的意思！
    -c ：将目前的 shell 中的所有 history 内容全部消除
    -a ：将目前新增的 history 指令新增入 histfiles 中，若没有加 histfiles ，则预设写入 ~/.bash_history
    -r ：将 histfiles 的内容读进目前这个 shell 癿 history 记忆中
    -w ：将目前的 history 记忆内容写入 histfiles 中！

## Bash Shell 的操作环境

- 路径与指令搜寻顺序

    基本上，指令运作的顺序可以这样看：

    1. 以相对/绝对路径执行指令，例如『/bin/ls』或『./ls』
    2. 由 alias 找到该指令来执行
    3. 由 bash 内建的（builtin）指令执行
    4. 透过 $PATH 这个变量的顺序搜寻到的第一个指令来执行

- bash 的进站与欢迎讯息：/etc/issue, /etc/motd

- bash 的环境配置文件

    - login 与 non-login shell

        - login shell: 取得 bash 时需要完整的登入流程的，就成为 login shell. 举例来说，你要 tty1 ~ tty6 登入，需要输入用户的账号与密码，此时取得的 bash 就成为『login shell』

            - 系统设定：/etc/profile (login shell)
                - /etc/inputrc
                - /etc/profile.d/*.sh
                - /etc/sysconfig/i18n
            - 个人设定：~/.bash_profile 或 ~/.bash_login 或 ~/.profile
            - source : 读入环境变量配置文件的指令
                - 利用 source 或者小数点(.) 都可以将配置文件的内容读进来目前的 shell 环境中
        - non-login shell: 取得 bash 接口的方法不需要重复登入的举动，举例来说，(1) 你以 X window 登入 Linux 后，再以 X 的图形化接口启动终端机，此时那个终端接口并没有需要再次输入账号与密码，那个 bash 的环境成为 non-login shell 了。(2) 你在原本的 bash 环境下再次下达 bash 这个指令，同样的也没有输入账号密码，那第二个 bash (子程序) 也是 non-login shell.
            - ~/.bashrc (non-login shell)

    - 其他相关配置文件
        - /etc/man.config
        - ~/.bash_history
        - ~/.bash_logout

- 通配符与特殊符号

    - 通配符

            符号            意义
            *           代表『 0 个或无穷多个』任意字符
            ?           代表『一定有一个』任意字符
            [ ]         同样代表『一定有一个在括号内』的字符(非任意字符)。例如 [abcd] 代表『一定有一个字符，可能是 a, b, c, d 这四个任何一个』
            [ - ]       若有减号在中括号内时，代表『在编码顺序内的所有字符』。例如 [0-9] 代表 0 或 9 之间的所有数字，因为数字的语系编码是连续的！
            [^ ]        若中括号内的第一个字符为指数符号 (^) ，那表示『反向选择』，例如 [^abc] 代表一定有一个字符，叧要是非 a, b, c 的其他字符就接受的意思。


    - 特殊字符

            符号            内容
            #           批注符号：这个最常被使用在 script 当中，规为说明！在后的数据均不执行
            \           跳脱符号：将『特殊字符或通配符』还原成一般字符
            |           管线 (pipe)：分隑两个管线命令的界定(后两节介绍)；
            ;           连续指令下达分隑符：连续性命令的界定 (注意！不管线命令幵不相同)
            ~           用户的家目录
            $           取用发数前导符：亦即是变量之前需要加的变量取代值
            &           工作控刢 (job control)：将指令发成背景下工作
            !           逻辑运算意义上的『非』 not 的意思！
            /           目录符号：路径分隑的符号
            >, >>       数据流重导向：输出导向，分删是『取代』不『累加』
            <, <<       数据流重导向：输入导向 (这两个留待下节介绍)
            ' '         单引号，不具有变量置换的功能
            " "         具有变量置换的功能！
            ` `         两个『 ` 』中间为可以先执行的指令，亦可使用 $( )
            ( )         在中间为子 shell 的起始不结束
            { }         在中间为命令区块的组合！

- - - 

### References

1. [鸟哥的 Linux 私房菜](http://cn.linux.vbird.org/linux_basic/linux_basic.php)
