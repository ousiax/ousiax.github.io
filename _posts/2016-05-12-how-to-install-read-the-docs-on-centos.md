---
layout: post
title: "How to install Read The Docs on CentOS"
date: 2016-05-12 01-36-16 +0800
categories: ['ReadTheDocs']
tags: ['ReadTheDocs', 'Python', 'CentOS', 'Git']
disqus_identifier: 320150661822729104925016946000399763251
---
First, obtain [Python 2.7](http://www.python.org/) and [virtualenv](http://pypi.python.org/pypi/virtualenv) if you do not already have them. Using a virtualenv environment will make the installation easier, and will help to avoid clutter in your system-wide libraries.

To install Python 2.7 from source, please see [How to install Python 2.7 from source on CentOS](/python/2016/05/11/how-to-install-python-2.7-from-source-on-centos.html).

Linux users may find they need to install a few additional packages in order to sucessfully execute `pip install -r requirements.txt`. For example, a clean install of CentOS 5.11 (Final) will require the following packages:

    yum -y groupinstall "Development Tools"
    yum -y install python-devel python-setuptools
    yum -y install libxml2-devel libxslt-devel zlib-devel
    cd /tmp
    wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    python get-pip.py

You will also need [Git](http://git-scm.com/) in order to clone the repository.

* ***fatal: Unable to find remote helper for 'https'***

It looks like not having (lib)curl-devel installed when you compile git can cause this.

If you install (lib)curl-devel, then rebuild/install git, this should solve the problem.

    yum -y install curl-devel
    wget https://www.kernel.org/pub/software/scm/git/git-2.8.2.tar.gz
    tar xf git-2.8.2.tar.gz
    cd git-2.8.2
    ./configure --prefix=/usr/local
    make install

Once you have these, create a virtual environment somewhere on your disk, then active it:

    virtualenv rtd
    cd rtd
    source bin/active

Create a folder in here, and clone the repository:

    mkdir checkouts
    cd checkouts
    git clone https://github.com/rtfd/readthedocs.org.git

Next, install the depedencies using `pip` (included inside of [virtualenv](http://pypi.python.org/pypi/virtualenv)):

    cd readthedocs.org
    pip install -r requirements.txt

This may take a while, so go grab a beverage. When it's done, build your database:

    ./manage.py migrate

Then please create a super account for Django

    ./manage.py createsuperuser

Next, create an account for API use and set `SLUMBER_USERNAME` and `SLUMBER_PASSWORD` in order for everything to work properly.

    ./manage.py shell
    >>> from django.contrib.auth.models import User
    >>> user = User.objects.create_user('test','','test')
    >>> user.is_staff = True
    >>> user.save()

Now let's properly generate the static assets:

    ./manage.py collectstatic

Finally, your're ready to start the webserver:

    ./manage.py runserver

For builds to properly kick off as expected, it is necessary the port you're serving on (i.e. `runserver 0.0.0.0:8000`) match the port defined in `PRODUCTION_DOMAIN`. You can utilize `local_settings.py` to modify this. (By default, it's `localhost:8000`)

If you put a file named `local_settings.py` in the `readthedocs/settings` directory, it will override settings available in the base install.

Example `local_settings.py`:

    PRODUCTION_DOMAIN = '192.168.241.130:8000'

    SLUMBER_API_HOST = 'http://192.168.241.130:8000'

    TIME_ZONE = 'Asia/Chongqing'

    #ALLOW_ADMIN = False
    DEBUG = False

* * *

### References

* [Installation — Read The Docs 1.0 documentation](http://docs.readthedocs.io/en/latest/install.html)

* [Customizing your install — Read The Docs 1.0 documentation](http://docs.readthedocs.io/en/latest/custom_installs/customization.html)

* [linux - git clone: fatal: Unable to find remote helper for 'https' - Stack Overflow](http://stackoverflow.com/questions/8329485/git-clone-fatal-unable-to-find-remote-helper-for-https)

