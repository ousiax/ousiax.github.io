---
layout: post
title: "How to install Read The Docs on CentOS"
date: 2016-05-12 01:36:16 +0800
categories: ['Python']
tags: ['ReadTheDocs', 'Python', 'CentOS', 'Git', 'Nginx']
disqus_identifier: 320150661822729104925016946000399763251
---
## Installation Read The Docs

First, obtain [Python 2.7](http://www.python.org/) and [virtualenv](http://pypi.python.org/pypi/virtualenv) if you do not already have them. Using a virtualenv environment will make the installation easier, and will help to avoid clutter in your system-wide libraries.

### Python 2.7

To install Python 2.7 from source, please see [How to install Python 2.7 from source on CentOS](/2016/05/11/how-to-install-python-2.7-from-source-on-centos/).

Linux users may find they need to install a few additional packages in order to sucessfully execute `pip install -r requirements.txt`. For example, a clean install of CentOS 5.11 (Final) will require the following packages:

    yum -y groupinstall "Development Tools"
    yum -y install python-devel python-setuptools
    yum -y install libxml2-devel libxslt-devel zlib-devel
    cd /tmp
    wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
    python get-pip.py

### Git 2.8

You will also need [Git](http://git-scm.com/) in order to clone the repository.

    yum -y install curl-devel
    yum -y install perl-devel
    wget https://www.kernel.org/pub/software/scm/git/git-2.8.2.tar.gz
    tar xf git-2.8.2.tar.gz
    cd git-2.8.2
    ./configure --prefix=/usr/local
    make install

### Read The Docs

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

*  Could not find a version that satisfies the requirement backports.ssl\_match\_hostname (from tornado&gt;=4.1\-&gt;mkdocs==0.14.0\-&gt;\-r requirements/pip.txt (line 7)) (from versions: )

    No matching distribution found for backports.ssl_match_hostname (from tornado&gt;=4.1\-&gt;mkdocs==0.14.0\-&gt;\-r requirements/pip.txt (line 7))

        source rtd/bin/active
        cd /tmp 
        wget https://pypi.python.org/packages/76/21/2dc61178a2038a5cb35d14b61467c6ac632791ed05131dda72c20e7b9e23/backports.ssl_match_hostname-3.5.0.1.tar.gz
        tar xf backports.ssl_match_hostname-3.5.0.1.tar.gz
        cd backports.ssl_match_hostname-3.5.0.1
        python setup.py install

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
    PUBLIC_API_URL = 'http://192.168.241.130:8000'
    MEDIA_URL = 'http://192.168.241.130:80/media/'

    TIME_ZONE = 'Asia/Chongqing'
    
    ALLOW_ADMIN = False
    DEBUG = False

## Configuration of the production servers

### uWSGI

To install uWSGI with Python support, please refer to [Python & WSGI applications](/2016/05/13/python-and-wsgi-applications/)

    cd rtd
    source bin/active
    pip install uwsgi

Configuration file `readthedocs_wsgi.ini`

    [uwsgi]
    ini = :pro
    
    [pro]
    env = DJANGO_SETTINGS_MODULE=readthedocs.settings.pro
    ini = :readthedocs
    
    [dev]
    env = DJANGO_SETTINGS_MODULE=readthedocs.settings.dev
    ini = :readthedocs
    
    [readthedocs]
    virtualenv = /home/x/rtd/
    chdir = /home/x/rtd/checkouts/readthedocs.org/
    wsgi-file = readthedocs/wsgi.py
    # module = django.core.handlers.wsgi:WSGIHandler()
    # module = readthedocs.wsgi:applicaiton
    
    # http = 0.0.0.0:8000
    socket = 127.0.0.1:3031
    # socket = /tmp/%n.sock
    # chmod-socket = 777
    
    uid = x
    gid = x
    
    stats = 127.0.0.1:9191
    pidfile = logs/%n.pid
    # daemonize = logs/%n.log
    
    master = true
    workers = 4
    enable-threads = true
    
    vaccum = true

### Nginx

Building nginx from Sources, refer to [Building nginx from Sources](http://nginx.org/en/docs/configure.html)


    wget http://nginx.org/download/nginx-1.10.0.tar.gz
    tar xf nginx-1.10.0.tar.gz
    wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz
    tar xf pcre-8.38.tar.gz
    wget http://zlib.net/zlib-1.2.8.tar.gz
    tar xf zlib-1.2.8.tar.gz
    cd nginx-1.10.0
    ./configure
    --prefix=/usr/local
    --conf-path=/etc/nginx/nginx.conf
    --pid-path=/var/run/nginx.pid
    --error-log-path=/var/log/nginx/error.log
    --http-log-path=/var/log/nginx/access.log
    --with-http_ssl_module
    --with-pcre=../pcre-8.38
    --with-zlib=../zlib-1.2.8
    make && make install

Configuration File's Structure

`nginx.conf`

    location / {
            include uwsgi_params;
            uwsgi_pass 127.0.0.1:3031;
            uwsgi_read_timeout 60;
    }

    location /static/ {
            alias /home/x/rtd/checkouts/readthedocs.org/media/static/;
    }

    location /media/ {
            alias /home/x/rtd/checkouts/readthedocs.org/media/;
    }

    location /docs/ {
            alias /home/x/rtd/checkouts/readthedocs.org/public_web_root/;
            index  index.html index.htm;
    }

XSendfile: Nginx & Django

`nginx.conf`
    
    location /protected/docs/ {
            alias /home/x/rtd/checkouts/readthedocs.org/public_web_root/;
            index  index.html index.htm;
    }

`middleware.py`

```python
from django.http import HttpResponse


class AuthenticationMiddleware(object):
    def __init__(self):
        self.mime_map = {
            '.css': 'text/css',
            '.htm': 'text/html',
            '.html': 'text/html',
            '.jpeg': 'image/jpeg',
            '.jpg': 'image/jpeg',
            '.js': 'application/javascript',
            '.json': 'application/json',
            '.zip': 'application/x-zip-compressed',
        }
        self.protected_url = '/protected'

    def is_authenticated(self, request):
        return True

    def x_accel_redirect(self, request_path):
        resp = HttpResponse()
        ext = path.splitext(request_path)[1]
        if ext:
            resp['Content-Type'] = self.mime_map[ext]
        resp['X-Accel-Redirect'] = self. protected_url + request_path
        return resp

    def process_request(self, request):
        if request.path.startswith('/docs') and self.is_authenticated(request):
            return self.x_accel_redirect(request.path)
```

* * *

### References

* [Installation — Read The Docs 1.0 documentation](http://docs.readthedocs.io/en/latest/install.html)

* [Customizing your install — Read The Docs 1.0 documentation](http://docs.readthedocs.io/en/latest/custom_installs/customization.html)

* [linux - git clone: fatal: Unable to find remote helper for 'https' - Stack Overflow](http://stackoverflow.com/questions/8329485/git-clone-fatal-unable-to-find-remote-helper-for-https)

* [Python & WSGI applications](/2016/05/13/python-and-wsgi-applications/)

* [Building nginx from Sources](http://nginx.org/en/docs/configure.html)

* [Module ngx_http_core_module](http://nginx.org/en/docs/http/ngx_http_core_module.html)

* [XSendfile \| NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)
