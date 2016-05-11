---
layout: post
title: "How to Install Python 2.7 On CentOS 6"
date: 2016-05-11 23-38-01 +0800
categories: ['Python']
tags: ['Python', 'CentOS']
disqus_identifier: 94384535001828622001171135555741952473
---
Show CentOS version

    $  uname -ri
    2.6.18-398.el5 i386

Install "Develement Tools"

    # yum groupinstall "Development Tools"

Download [Gzipped source tarball](https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz)

    # mkdir $HOME/tmp
    # cd $HOME/tmp
    # wget https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz
    # tar xf Python-2.7.11.tgz
    # cd Python-2.7.11
    # ./configure --prefix=/usr/local/python2.7
    # make
    ...
    Python build finished, but the necessary bits to build these modules were not found:
    _bsddb             _curses            _curses_panel   
    _sqlite3           _ssl               _tkinter        
    bsddb185           bz2                dbm             
    gdbm               readline           sunaudiodev     
    zlib

To install these modules,

    # yum -y install bzip2-devel
    # yum -y install zlib-devel
    # yum -y install readline-devel
    # yum -y install sqlite-devel
    # yum -y install tk-devel
    # yum -y install ncurses-devel
    # yum -y install db4-devel
    # yum -y install gdbm-devel
    # yum -y install openssl-devel

Configure & Make install Python-2.7.11

    # cd $HOME/tmp/Python-2.7.11
    # ./configure --prefix=/usr/local/python2.7
    # make
    ...
    Python build finished, but the necessary bits to build these modules were not found:
    bsddb185           sunaudiodev                        
    To find the necessary bits, look in setup.py in detect_modules() for the module's name.

    running build_scripts
    # make install

Add Python2.7 to PATH,

    # echo "export PATH=/usr/local/python2.7/bin:/usr/local/python2.7/lib/python2.7/site-packages:$PATH" > $HOME/.bashrc
    # python --version
    Python 2.7.11

Install pip with [get-pip.py](https://bootstrap.pypa.io/get-pip.py)

    # cd $HOME/tmp
    # wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    # python get-pip.py

Install virtualenv

    # pip install virtualenv

Create a virtualenv

    $ export PATH=/usr/local/python2.7/bin:/usr/local/python2.7/lib/python2.7/site-packages:$PATH
    $ export LC_ALL=C
    $ virtualenv venv
    $ source venv/bin/activate
    $ python --version
    Python 2.7.11

* * *

* [Python Source Releases](https://www.python.org/downloads/source/)
* [Installing with get-pip.py](https://pip.pypa.io/en/stable/installing/#installing-with-get-pip-py)
* [pip install - locale.Error: unsupported locale setting](http://stackoverflow.com/questions/36394101/pip-install-locale-error-unsupported-locale-setting/36394262#36394262)
