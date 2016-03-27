---
disqus_identifier: 164786765557704604696316809304499526528
layout: post
title: "Virtualenv for python runtime"
date: 2015-08-06 22-36-37 +0800
categories: ['Python',]
tags: ['Python', 'virtualenv']
---
**virtualenv** is a tool to create isolated Python environments.

The basic problem being addressed is one of dependencies and versions, and indirectly permissions. Imagine you have an application that needs version 1 of *LibFoo*, but another application requires version 2. How can you use both these applications? If you install everything into */usr/lib/python2.7/site-packages* (or whatever your platform’s standard location is), it’s easy to end up in a situation where you unintentionally upgrade an application that shouldn’t be upgraded.

Or more generally, what if you want to install an application and leave it be? If an application works, any change in its libraries or the versions of those libraries can break the application.

Also, what if you can’t install packages into the globa *site-packages* directory? For instance, on a shared host.

In all these cases, *virtualenv* can help you. It creates an environment that has its own installation directories, that doesn’t share libraries with other virtualenv environments (and optionally doesn’t access the globally installed libraries either).

* installation

    $ sudo pip install virtualenv

* create isolated env

    $ mkdir diango184

    $ virtualenv django184

* active virtual env 

    $ source django184/bin/active

* deactive

    $ deactive

* example
{% highlight shell %}
$ python -c "import django; print django.__version__"
Traceback (most recent call last):
  File "<string>", line 1, in <module>
ImportError: No module named django
$ cd /tmp
$ mkdir django184
$ virtualenv django184/
New python executable in /tmp/django184/bin/python
Installing setuptools, pip, wheel...done.
$ source django184/bin/activate
(django184) $ pip install django==1.8.4
Collecting django==1.8.4
  Using cached https://pypi.mirrors.ustc.edu.cn/packages/py2.py3/D/Django/Django-1.8.4-py2.py3-none-any.whl
Installing collected packages: django
Successfully installed django-1.8.4
You are using pip version 8.0.2, however version 8.1.1 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.
(django184) $ python -c "import django; print django.__version__"
1.8.4
(django184) $ deactivate 
$ python -c "import django; print django.__version__"
Traceback (most recent call last):
  File "<string>", line 1, in <module>
ImportError: No module named django
$ rm -rf django184
{% endhighlight %}

* * *

#### References

* [https://virtualenv.pypa.io/](https://virtualenv.pypa.io/)
* [https://pypi.python.org/](https://pypi.python.org/pypi?%3Aaction=search&term=django&submit=search)
