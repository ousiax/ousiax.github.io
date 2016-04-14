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

. Date & Time

* Select a **timezone**

        # tzselect    # select timezone e.g. Asia/Shanghai
        # echo 'Asia/Shanghai' > /etc/timezone    # set timezone
        # ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime

    OR

        # dpkg-reconfigure tzdata

* Set the time manually

        date --set 1998-11-02
        date --set 21:08:00

* Set the time automatically

    * Install **ntp**

            apt-get install ntp

    * Adjust */etc/ntp.conf*

        Change the

            server pool.ntp.org

        line to

            server XX.pool.ntp.org

        where XX is your continent or two letter country code.

* Force a clock update

        # service ntp stop
        # ntpd -gq
        # service ntp start

    OR

        # service ntp stop
        # ntpdate -s 3.cn.pool.ntp.org # synchronize date time.
        # service ntp start

* Asia — asia.pool.ntp.org

    To use this pool zone, add the following to your ntp.conf file:

           server 0.asia.pool.ntp.org
           server 1.asia.pool.ntp.org
           server 2.asia.pool.ntp.org
           server 3.asia.pool.ntp.org

* China — cn.pool.ntp.org

    There are not enough servers in this zone, so we recommend you use the Asia zone (asia.pool.ntp.org):

           server 0.asia.pool.ntp.org
           server 1.asia.pool.ntp.org
           server 2.asia.pool.ntp.org
           server 3.asia.pool.ntp.org
    
* * *

### References

* [How do I setup NTP to use the pool?](http://www.pool.ntp.org/en/use.html)
* [NTP Servers in Asia, asia.pool.ntp.org](http://www.pool.ntp.org/zone/asia)
* [DateTime](https://wiki.debian.org/DateTime)
* [TimeZoneChanges](https://wiki.debian.org/TimeZoneChanges)
* [How to force a clock update using ntp?](http://askubuntu.com/questions/254826/how-to-force-a-clock-update-using-ntp)
