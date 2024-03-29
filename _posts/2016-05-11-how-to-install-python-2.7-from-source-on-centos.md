---
layout: post
title: "How to install Python 2.7 from source on CentOS"
date: 2016-05-11 23:38:01 +0800
categories: ['python']
tags: ['python']
---
#### Show CentOS version

    $  uname -ri
    2.6.18-398.el5 i386
    $ cat /etc/*release
    CentOS release 5.11 (Final)

#### Install "Develement Tools"

    # yum -y groupinstall "Development Tools"

#### Download [Gzipped source tarball](https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz)

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

* bz2

        # yum -y install bzip2-devel

* zlib

        # yum -y install zlib-devel

* readline

        # yum -y install readline-devel

* \_sqlite3

        # yum -y install sqlite-devel

* \_tkinter

        # yum -y install tk-devel

* \_curses \_curses\_panel

        # yum -y install ncurses-devel

* \_bsddb

        # yum -y install db4-devel

* gdbm

        # yum -y install gdbm-devel

* \_ssl

    With dist packages

        # yum -y install openssl-devel

    Make with source

        # wget https://www.openssl.org/source/openssl-1.0.2h.tar.gz
        # tar xf openssl-1.0.2h.tar.gz
        # cd openssl-1.0.2h
        # ./config --prefix=/usr shared
        # make install

#### Configure & Make install Python-2.7.11

You can also use `--enable-shared` option to build shared versions of libraries.

    # cd $HOME/tmp/Python-2.7.11
    # ./configure --prefix=/usr/local/python2.7
    # make
    ...
    Python build finished, but the necessary bits to build these modules were not found:
    bsddb185           sunaudiodev                        
    To find the necessary bits, look in setup.py in detect_modules() for the module's name.

    running build_scripts
    # make install

#### Add `/usr/local/python2.7/lib/` to `ld.so.conf`,

If you use `--enable-shared` option, you should append python DSO to `ld.so.conf`.

    # echo "/usr/local/python27/lib/" > /etc/ld.so.conf.d/python2.7-x86_64.conf

#### Install pip with [get-pip.py](https://bootstrap.pypa.io/get-pip.py)

    # cd $HOME/tmp
    # wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    # /usr/local/python2.7/bin/python get-pip.py

#### Install virtualenv

    # /usr/local/python2.7/bin/pip install virtualenv

#### Create a virtualenv

    $ export LC_ALL=C
    $ /usr/local/python2.7/bin/virtualenv venv
    $ source venv/bin/activate
    $ python --version
    Python 2.7.11

* * *

* [Python Source Releases \| Python.org](https://www.python.org/downloads/source/)
* [Installation — pip 8.1.2 documentation](https://pip.pypa.io/en/stable/installing/#installing-with-get-pip-py)
* [Installing Python 2.6, virtualenv, and virtualenvwrapper on Dreamhost](http://andrew.io/weblog/2010/02/installing-python-2-6-virtualenv-and-virtualenvwrapper-on-dreamhost/)
* [pip install - locale.Error: unsupported locale setting](http://stackoverflow.com/questions/36394101/pip-install-locale-error-unsupported-locale-setting/36394262#36394262)
