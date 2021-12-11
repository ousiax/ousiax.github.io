---
disqus_identifier: 137767400007191038414297736775556603941
layout: post
title: "Linux Dev (Debian)"
date: 2015-08-31 09:10:45 +0800
categories: ['linux',]
tags: ['linux', 'debian',]
---
### . show linux version

    $ uname -a
    $ cat /proc/version
    $ cat /proc/sys/kernel/{ostype,osrelease,version}
    $ lsb_release -a
    $ cat /etc/*release

### . setterm (Disable PC speaker beep)

    $ setterm -blength 0

### . apt

    # cd /etc/apt/
    # wget http://mirrors.163.com/.help/sources.list.jessie -O sources.list
    # apt-get update

### . vim

    # apt-get install vim

*basic configuration*

```vim
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
```

### . sudo

*install*

    # apt-get install sudo

*configuration*

    # usermod -aG sudo x # x is my login user name

### . home directory for user [x]

    # mkdir -p /home/x
    # chown x:x /home/x
    # usermod -d /home/x -m x

### . OpenSSH

*install*

        # apt-get install openssh-server

*start*

        # /etc/init.d/ssh start

### . gcc
    
    # apt-get install gcc
    # apt-get install make

### . git

    # apt-get install git

*base_completion*

    # apt-get install git-core bash-completion

*configuration*

    $ git config --global user.name "John Doe"
    $ git config --global user.email johndoe@example.com

    $ git config --global core.editor emacs

*configuring a remote for a fork*

    $ git remote -v
    
    $ git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git

*syncing a fork*

    $ git fetch upstream
    $ git checkout master
    $ git merge upstream/master

### . pip

*install*

    # cp /tmp
    # wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
    # python get-pip.py

*configuration*

**Per-user**:

* On Unix the default configuration file is: `$HOME/.config/pip/pip.conf` which respects the `XDG_CONFIG_HOME` environment variable.

* On Mac OS X the configuration file is `$HOME/Library/Application Support/pip/pip.conf`.

* On Windows the configuration file is `%APPDATA%\pip\pip.ini`.

There are also a legacy per-user configuration file which is also respected, these are located at:

* On Unix and Mac OS X the configuration file is: `$HOME/.pip/pip.conf`

* On Windows the configuration file is: `%HOME%\pip\pip.ini`

You can set a custom path location for this config file using the environment variable `PIP_CONFIG_FILE`.

    # mkdir /etc/pip
    # vi /etc/pip/pip.ini

    [global]
    timeout=60
    index-url=https://pypi.mirrors.ustc.edu.cn/simple

    # echo 'PIP_CONFIG_FILE="/etc/pip/pip.ini"' >> /etc/bash.bashrc

**Inside a virtualenv**:

* On Unix and Mac OS X the file is `$VIRTUAL_ENV/pip.conf`

* On Windows the file is: `%VIRTUAL_ENV%\pip.ini`

**Site-wide**:

* On Unix the file may be located in `/etc/pip.conf`. Alternatively it may be in a "pip" subdirectory of any of the paths set in the environment variable `XDG_CONFIG_DIRS` (if it exists), for example `/etc/xdg/pip/pip.conf`.

* On Mac OS X the file is: `/Library/Application Support/pip/pip.conf`

* On Windows XP the file is: `C:\Documents and Settings\All Users\Application Data\pip\pip.ini`

* On Windows 7 and later the file is hidden, but writeable at `C:\ProgramData\pip\pip.ini`

* Site-wide configuration is not supported on Windows Vista

If multiple configuration files are found by pip then they are combined in the following order:

* Firstly the site-wide file is read, then

* The per-user file is read, and finally

* The virtualenv-specific file is read.

### . virtualenv

    $ pip install virtualenv

### . django

    # pip install django

### . uwsgi

    # apt-get install python-dev
    # pip install uwsgi

### . nginx

    # apt-get install nginx

### . java

*download*

    # wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"
    \ http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.tar.gz
    # tar xzf jdk-8u66-linux-x64.tar.gz
    # mv jdk-8u66-linux-x64 /opt/java

*configuration (/etc/profile or /etc/bash.bashrc)*

```bash
JAVA_HOME=/opt/java # jdk1.8.0_66
JRE_HOME=$JAVA_HOME/jre
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME
export JRE_HOME
export PATH
```

### . Date & Time

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

### . Uninstall softeware / package

* Uninstall / Delete / Remove Package
    
    * Remove package called mplaer,
     
            $ sudo apt-get remove mplayer
     
    * Remove package called lighttpd along with all configuration files,
     
            $ sudo apt-get --purge remove lighttpd
     
    * To list all installed package,
    
            $ dpkg --list
    
* Uninstall files installed from a source code tar ball
    
    * Method # 1: make command
    
            # make uninstall
    
        This method sounds very easy but not supported by all tar balls make file.
    
    * Method # 2: find command
    
        First, make a list of all files on system before installing software i.e. pre-installation list of all files on your system,
    
            find /* > packagelist.b4
    
        Next compile and install the software (use configure & make to compile it),
    
            ./configure --option=1 --foo=bar etc
            make
            make install
    
        Now, make a list of all files on the system after installing software i.e. postinstall list,
    
            find /* > packagelist.after
    
        Finally compare both lists using the diff utility to find out what files are placed where.
    
            diff packagelist.b4 packagelist.after > package.uninstall.list
    
        Use the following small for loop at shell prompt to remove all files,
    
            for i in $(grep ">" package.uninstall.list | awk '{ print $2 }')
            do
             /bin/rm -fi "$i"
            done

### . net-tools (CentOS)

* ifconfig command not found

        # yum install net-tools

### . Network Configuration (Debian)

The majority of network setup can be done via *interfaces* configuration file at */etc/network/interfaces*.

* Using DHCP to automatically configure the interface

        auto eth0
        allow-hotplug eth0
        iface eth0 inet dhcp

* Configuring the interface manually

        auto eth0
        iface eth0 inet static
            address 192.0.2.7
            netmask 255.255.255.0
            gateway 192.0.2.254

* Defining the (DNS) Nameservers

    The configuration file *resolv.conf* at */etc/resolv.conf* contains information that allows a computer connected to a network to resolve names into addresses.

        nameserver 12.34.56.78
        nameserver 12.34.56.79

### . redirecting to and from the standard file handles

    Handle  Name    Description
    0       stdin   Standard input
    1       stdout  Standard output
    2       stderr  Standard error

* redirect `stderr` to `stdout`

    $ command-name 2>&1

OR

    $ command-name &>

* examples

    Write all output data to file `list`.    

        $ find / -name .bashrc > list 2>&1
        $ find / -name .bashrc &> list

* * *

### References

* [How do I setup NTP to use the pool?](http://www.pool.ntp.org/en/use.html)
* [NTP Servers in Asia, asia.pool.ntp.org](http://www.pool.ntp.org/zone/asia)
* [DateTime](https://wiki.debian.org/DateTime)
* [TimeZoneChanges](https://wiki.debian.org/TimeZoneChanges)
* [How to force a clock update using ntp?](http://askubuntu.com/questions/254826/how-to-force-a-clock-update-using-ntp)
* [Customizing Git - Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
* [Configuring a remote for a fork](https://help.github.com/articles/configuring-a-remote-for-a-fork/)
* [Syncing a fork](https://help.github.com/articles/syncing-a-fork/)
* [NetworkConfiguration](https://wiki.debian.org/NetworkConfiguration#Setting_up_an_Ethernet_Interface)
