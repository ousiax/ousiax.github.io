---
layout: post
title: "认识与学习 BASH"
date: 2016-11-16 09-30-39 +0800
categories: Linux
tags: ['Linux', 'Shell', 'Bash']
disqus_identifier: 180988753761717130939285996517108463885
---
## 硬件、核心与 Shell

**Shell, KDE, application** -> **核心( Kernel)** -> **硬件( Hardware)**

## 变量的取用与设定: echo, unset
- 变量的取用: echo

    ```
    # echo $PATH
    /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/local/go/bin:/opt/local/java/bin:/opt/local/scala/bin 
    ```

    变量的读取只需要在变量名前面加上 `$`,或者以 `${变量}` 的方式来取用都可以。

- 变量设定规则
    1. 变量与变量内容以一个等号『=』来连结，如下所示：

        ```
        myname=myvalue
        ```

    2. 等号两边不能直接接空格符，如下所示错误：

        ```
        myname = myvalue
        myname=my value
        ```

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
