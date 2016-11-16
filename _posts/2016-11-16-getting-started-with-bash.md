---
layout: post
title: "Getting Started with Bash"
date: 2016-11-16 09-30-39 +0800
categories: Linux
tags: ['Linux', 'Shell', 'Bash']
disqus_identifier: 180988753761717130939285996517108463885
---
## 变量的取用与设定: echo, unset
- 变量的取用: echo
    ```shell
    # echo $PATH
    /usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/local/go/bin:/opt/local/java/bin:/opt/local/scala/bin 
    ```
    变量的读取只需要在变量名前面加上 `$`,或者以 `${变量}` 的方式来取用都可以。

- 变量设定规则
    1. 变量与变量内容以一个等号『=』来连结，如下所示：
    ```sh
    myname=myvalue
    ```
    2. 等号两边不能直接接空格符，如下所示错误：
    ```sh
    myname = myvalue
    myname=my value
    ```
    3. 变量名称只能是英文字符与数字，但是开头字符不能是数字，如下为错误：
    ```sh
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


