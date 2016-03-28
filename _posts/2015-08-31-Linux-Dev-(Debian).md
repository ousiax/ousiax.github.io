---
disqus_identifier: 137767400007191038414297736775556603941
layout: post
title: "Linux Dev (Debian)"
date: 2015-08-31 09-10-45 +0800
categories: ['Linux',]
tags: ['Linux', 'Debian',]
---
. show linux version

    $ uname -a
    $ cat /proc/version
    $ cat /proc/sys/kernel/{ostype,osrelease,version}
    $ lsb_release -a
    $ cat /etc/*release

. setterm (Disable PC speaker beep)

    $ setterm -blength 0

. apt

    # cd /etc/apt/
    # wget http://mirrors.163.com/.help/sources.list.jessie -O sources.list
    # apt-get update

. vim

    # apt-get install vim

*basic configuration*
{% highlight vim %}
    " line enables syntax highlighting
    syntax on

    " display line number
    set number

    " disable vim swap and backup
    set nobackup
    set nowritebackup
    set noswapfile

    " expands tab as spaces
    set expandtab
    set tabstop=4
    set shiftwidth=4

    " UTF-8
    set encoding=utf-8
    set fileencoding=utf-8
    set fileencodings=ucs-bom,utf-8,chinese
    set ambiwidth=double
{% endhighlight %}

. sudo

*install*

        # apt-get install sudo

*configuration*

        # usermod -aG sudo x # x is my login user name

. home directory for user [x]

    # mkdir -p /home/x
    # chown x:x /home/x
    # usermod -d /home/x -m x

. OpenSSH

*install*

        # apt-get install openssh-server

*start*

        # /etc/init.d/ssh start

. gcc
    
    # apt-get install gcc
    # apt-get install make

. git

    # apt-get install git

. pip

*install*

        # cp /tmp
        # wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
        # python get-pip.py

*configuration*

        # mkdir /etc/pip
        # vi /etc/pip/pip.ini

        [global]
        timeout=60
        index-url=https://pypi.mirrors.ustc.edu.cn/simple

        # echo 'PIP_CONFIG_FILE="/etc/pip/pip.ini"' >> /etc/bash.bashrc

. virtualenv

    $ pip install virtualenv

. django

    # pip install django

. uwsgi

    # apt-get install python-dev
    # pip install uwsgi

. nginx

    # apt-get install nginx

. java

*download*

    # wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"
    \ http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz
    # tar xzf jdk-8u66-linux-x64.tar.gz
    # mv jdk-8u66-linux-x64 /opt/java

*configuration (/etc/profile or /etc/bash.bashrc)*

{% highlight shell %}
    JAVA_HOME=/opt/java # jdk1.8.0_66
    JRE_HOME=$JAVA_HOME/jre
    PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
    export JAVA_HOME
    export JRE_HOME
    export PATH
{% endhighlight %}

. tzselect

    # tzselect    # select timezone e.g. Asia/Shanghai
    # echo 'Asia/Shanghai' > /etc/timezone    # set timezone
    # ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime
    # apt-get install ntpdate
    # service ntp start

* * *

### References

* [How do I setup NTP to use the pool?](http://www.pool.ntp.org/en/use.html)
* [NTP Servers in Asia, asia.pool.ntp.org](http://www.pool.ntp.org/zone/asia)
