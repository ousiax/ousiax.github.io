---
layout: post
title: "How to install Read The Docs on CentOS"
date: 2016-05-12 01-36-16 +0800
categories: ['ReadTheDocs']
tags: ['ReadTheDocs', 'Python', 'CentOS']
disqus_identifier: 320150661822729104925016946000399763251
---
First, obtain [Python 2.7](http://www.python.org/) and [virtualenv](http://pypi.python.org/pypi/virtualenv) if you do not already have them. Using a virtualenv environment will make the installation easier, and will help to avoid clutter in your system-wide libraries. You will also need [Git](http://git-scm.com/) in order to clone the repository. If you plan to import Python 3 project to your RTD then you'll need to install Python 3 with virtualenv in your system as well.

To install Python 2.7 from source, please see [How to install Python 2.7 from source on CentOS](/python/2016/05/11/how-to-install-python-2.7-from-source-on-centos.html).

Linux users may find they need to install a few additional packages in order to sucessfully execute `pip install -r requirements.txt`. For example, a clean install of Ubuntun 14.04 LTS will require the following packages:

    sudo apt-get install build-essential
    sudo apt-get install python-dev python-pip python-setuptools
    sudo apt-get install libxml2-dev libxslt1-dev zlib1g-dev

For CentOS,

    sudo yum -y groupinstall "Development Tools"
    sudo yum -y install python-devel python-setuptools
    sudo yum -y install libxml2-devel libxslt-devel zlib-devel
    cd /tmp
    wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    sudo python get-pip.py

Once you have these, create a virtual environment somewhere on your disk, then active it:

    virtualenv rtd
    cd rtd
    source bin/active

Create a folder in here, and clone the repository:

    mkdir checkouts
    cd checkouts
    git clone https://github.com/rtfd/readthedocs.org.git
