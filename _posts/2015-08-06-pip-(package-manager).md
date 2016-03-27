---
layout: post
title: "pip (package manager)"
date: 2015-08-06 21-07-28 +0800
categories: ['Python',]
tags: ['pip','pypi',]
---
**pip** is a [package management system](https://en.wikipedia.org/wiki/Package_manager) used to install and manage [software packages](https://en.wikipedia.org/wiki/Package_(package_management_system)) written in [Python](https://en.wikipedia.org/wiki/Python_(programming_language)). Many packages can be found in the [Python Package Index](https://en.wikipedia.org/wiki/Python_Package_Index) (PyPI).

Python 2.7.9 and later (on the python2 series), and Python 3.4 and later include pip (pip3 for Python 3) by default.

**pip** is a recursive acronym that can stand for either "Pip Installs Packages" or "Pip installs Python".

* installation

for linux(debian):

    $ sudo apt-get install python-pip

or

    $ sudo curl -O https://bootstrap.pypa.io/get-pip.py | python

* basic commands

    * help

        $ pip --help

    * install

        $ pip install threadpool&nbsp;&nbsp;&nbsp;# latest version

        $ pip install threadpool=1.2.7&nbsp;&nbsp;# specific version

        $ pip install threadpool>=1.2.7&nbsp;# minimum version

    * uninstall

        $ pip uninstall threadpool

    * search

        $ pip search threadpool

* configuration mirrors

    On Unix and Mac OS X the configuration file is: *$HOME/.pip/pip.conf*

    On Windows, the configuration file is: *$HOME\pip\pip.ini*

    *pip.conf*
            
        [global]
        timeout=60
        index-url = https://pypi.mirrors.ustc.edu.cn/simple

    *Note*: you can set a custom path location for the config file using the environment variable *PIP_CONFIG_FILE*.

       export PIP_CONFIG_FILE="/etc/pip/pip.ini"

* * *

### References

* [pip documentation](https://pip.pypa.io/)
* [pip (package manager)](https://en.wikipedia.org/wiki/Pip_%28package_manager%29)
* [如何使用科大 mirrors 加速 pip？](https://lug.ustc.edu.cn/wiki/mirrors/help/pypi)

* * *
