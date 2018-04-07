---
layout: post
title: "Python & WSGI Applications"
date: 2016-05-13 14:51:33 +0800
categories: ['Python']
tags: ['Python', 'WSGI']
disqus_identifier: 86045526457165983718688743244436200313
---

## Installing uWSGI with Python support

*When you start learning uWSGI, try to build from offical sources: using distribution-supplied packages may brings you plenty of headaches. When things are clear, you can use modular builds (like the ones available in your distribution).*

uWSGI is a (big) C application, so you need a C compiler (like gcc or clang) and the Python development headers.

On a Debian-based distro an

    apt-get install build-essential python-dev

will be enough.

You have various ways to install uWSGI for Python:

* via pip

        pip install uwsgi

* using the network installer

        curl http://uwsgi.it/install | bash -s default /tmp/uwsgi

    (this will install the uWSGI binary into `/tmp/uwsgi`, feel free to change it).

* via downloading a source tarball and "making" it

        wget http://projects.unbit.it/downloads/uwsgi-latest.tar.gz
        tar zxvf uwsgi-latest.tar.gz
        cd <dir>
        make

    (after the build you will have a uwsgi binary in the current directory).

One thing you may want to take into account with distro-supplied packages, is that very probably your distribution has built uWSGI in modular way (every feature is a different plugin that must be loaded). To complete it, you have to prepend `--plugin python,http` to the first series of examples, and `--plugin python` when the HTTP router is removed.

## The first WSGI application

Let's start with a simple "Hello World" example:

    def application(env, start_response):
        start_response('200 OK', [('Content-Type','text/html')])
        return [b"Hello World"]

(save it as `foobar.py`)

As you can see, it composed of a single Python function. It is called "application" as this is default function that the uWSGI Python loader will search for (but you can obviously customize it).

### Deploy it on HTTP port 9090

Now start uWSGI to run an HTTP server/router passing requests to your WSGI application:

    uwsgi --http :9090 --wsgi-file foobar.py

That's all.

*Do not use `--http` when you have a frontend webserver or you are doning some form of benchmark, use `--http-socket`.*

### Add concurrency and monitoring

The first tuning you would like to make is adding concurrency (by deafult uWSGI starts with a single process and a single thread).

You can add more processes with the `--processes` option or more threads with the `--threads` option (or you can have both).

    uwsgi --http :9090 --wsgi-file foobar.py --master --processes 4 --threads 2

This will spawn 4 processes (each with 2 threads), a master process (will respawn your processes when they die) and the HTTP router.

One important task is monitoring. Understanding what is goning on is vital in production deployment.

The status subsystem allows you to export uWSGI's internal statistics as JSON:

    uwsgi --http :9090 --wsgi-file foobar.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191

Make some request to your app and then telnet to the port 9191, you'll get lots of fun information.

You may want to use "uwsgitop" (just `pip install` it), which is a top-like tool for monitoring instances.

### Putting behind a full webserver

Even though uWSGI HTTP router is solid and high-perfomance, you may want to put your applicaiton behind a fully-capable webserver.

uWSGI natively speaks HTTP, FastCGI, SCGI and its specific protocol named "uwsgi" (yes, wrong naming choice). The best performing protocol is obviously uwsgi, alread supported by nginx and Cherokee (while various Apache modules are available).

A common nginx config is the following:

    location / {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:3031;
    }

This means "pass every request to the server bound to port 3031 speaking the uwsgi protocol".

Now we can spawn uWSGI to natively speak the uwsgi protocol:

    uwsgi --socket 127.0.0.1:3031 --wsgi-file foobar.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191

If you'll run `ps aux`, you will see one process less. The HTTP router has been removed as our "workers" (the processes assigned to uWSGI) natively speak the uwsgi protocol.

If your proxy/webserver/router speaks HTTP, you have to tell uWSGI to natively speak the http protocol (this is different from `-–http` that will spawn a proxy by itself):

    uwsgi --http-socket 127.0.0.1:3031 --wsgi-file foobar.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191

### Automatically starting uWSGI on boot

If you are thinking about firing up vi and writing an init.d script for spawning uWSGI, just sit (and calm) down and make sure your system doesn't offer a better (more modern) approach first.

Each distribution has chose a startup system ([Upstart](http://uwsgi.readthedocs.io/en/latest/Upstart.html), [Systemd](http://uwsgi.readthedocs.io/en/latest/Systemd.html)...) and there are tons of process manangers available (supervisord, god, monit, circus...).

uWSGI will integrate very well with all of them (we hope), but if you plan to deploy a big number of apps check the uWSGI [Emperor](http://uwsgi.readthedocs.io/en/latest/Emperor.html) - it it more or less the dream of every devops engineer.

### Deploying Django

Django is very probably the most used Python web framework around. Deploying it is pretty easy.

We suppose the Django project is in `/home/foobar/myproject`:

    uwsgi --socket 127.0.0.1:3031 --chdir /home/foobar/myproject/ --wsgi-file myproject/wsgi.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191

(with `--chdir` we move to a specific directory). In Django this is required to correctly load modules.

Argh! What the hell is this?! Yes, you're right, you're right...dealing with such long command lines is unpractical, foolish and error-prone. Never fear! uWSGI supports various configuration styles. Here we will use .ini files.

    [uwsgi]
    socket = 127.0.0.1:3031
    chdir = /home/foobar/myproject/
    wsgi-file = myproject/wsgi.py
    processes = 4
    threads = 2
    stats = 127.0.0.1:9191 

A lot better!

Just run it:

    uwsgi yourfile.ini

If the file `/home/foobar/myproject/myproject/wsgi.py` (or whatever you have called your project) does not exist, you are very probably using an old (<1.4) version of Django. In such a case you need a little bit more configuration:

    uwsgi --socket 127.0.0.1:3031 --chdir /home/foobar/myproject/ --pythonpath .. --env DJANGO_SETTINGS_MODULE=myproject.settings --module "django.core.handlers.wsgi:WSGIHandler()" --processes 4 --threads 2 --stats 127.0.0.1:9191

Or, using the .ini file:

    [uwsgi]
    socket = 127.0.0.1:3031
    chdir = /home/foobar/myproject/
    pythonpath = ..
    env = DJANGO_SETTINGS_MODULE=myproject.settings
    module = django.core.handlers.wsgi:WSGIHandler()
    processes = 4
    threads = 2
    stats = 127.0.0.1:9191

Older (<1.4) Django releases need to set `env`, `module` and the `pythonpath` (`...` allow us to reach the `myproject.settings` module).

### A note on Python threads

If you start uWSGI without threads, the Python GIL will not be eanbled, so threads generated by your application will never run. You may not like that choice, but remember that uWSGI is a language-independent server, so most of its choices are for maintaining it "agnostic".

But do not worry, there are basically no choices made by the uWSGI developers that cannot be changed with an option.

If you want to maintain Python threads support without starting multiple threads for your application, just add the `--enable-threads` option (or `enable-threads = true in init style).

### Virtualenvs

uWSGI can be configured to search for Python modules in a specific virtuaenv.

Just add `virtualenv = <path>` to your options.

### Python Auto-reloading (DEVELOPMENT ONLY!)

In production you can monitor file/directory changes for triggering reloads (touch-reload, fs-reload...).

During development having a monitor for all of the loaded/used python modules can be handy. But please use it only during development.

This check is done by a thread that scans the modules list with the specified frequency:

    [uwsgi]
    ...
    py-autoreload = 2

will check for ptyhon modules changes every 2 seconds and eventually restart the instance.

And again:

*Use this only in development.*

### Security and availability

**Always** avoid running your uWSGI instances as root. You can drop privileges using `uid` and `gid` options:

    [uwsgi]
    https = :9090,foobar.crt,foobar.key
    uid = foo
    gid = bar
    chdir = path_to_web2py
    module = wsgihandler
    master = true
    processes = 8

If you need to bind to privileged ports (like 443 for HTTPS), use shared sockets. They are created before dropping privileges and can be referenced with the `=N` syntax, where `N` is the socket number (starting from 0):

    [uwsgi]
    shared-socket = :443
    https = =0,foobar.crt,foobar.key
    uid = foo
    gid = bar
    chdir = path_to_web2py
    module = wsgihandler
    master = true
    processes = 8

A common problem with webapp deployment is "stuck request". All of your threads/workers are stuck (blocked on request) and your app cannot accept more requests. To avoid that problem you can set a `karakiri` timer. It is a monitor (managed by the master process) that destroy processes stuck for more than the specified number of seconds (choose `karakiri` value carefully). For example, you may want to destroy workers blocked for more than 30 seconds:

    [uwsgi]
    shared-socket = :443
    https = =0,foobar.crt,foobar.key
    uid = foo
    gid = bar
    chdir = path_to_web2py
    module = wsgihandler
    master = true
    processes = 8
    harakiri = 30

In addition to this, since uWSGI 1.9, the stats server exports the whole set of request variables, so you can see (in realtime) what your instance is doing (for each worker, thread or async core).

## Managing the uWSGI server

### INI files

.INI files are a standard de-facto cofiguration format used by many applications. It consists of `[section]`s and `key=value` pairs.

An example uWSGI INI configuration:

    [uwsgi]
    socket = /tmp/uwsgi.sock
    socket = 127.0.0.1:3031
    master = true
    workers = 3

By default, uWSGI uses the `[uwsgi]` section, but you can specify another section name while loading the INI file with the syntax `filename:section`, that is:

    uwsgi --ini myconf.ini:app1

Alternatively, you can load another section from the same file by ommitting the filename and specifying just the section name. Note that technically, this loads the named section from the last.ini file loaded instead of the current one, so be careful when including other files.

    [uwsgi]
    # This will load the app1 section below
    ini = :app1
    # This will load the defaults.ini file
    ini = defaults.ini
    # This will load the app2 section from the defaults.ini file!
    ini = :app2
    
    [app1]
    plugin = rack
    
    [app2]
    plugin = php

* Whitespace is insignificant within lines.
* Lines starting with a semicolon (`;`) or a hash/octothorpe (`#`) are ignored as comments.
* Boolean values may be set without the value part. Simply `master` is thus equivalent to `master=true`. This may not be compatible with other INI parsers such as `paste.deploy`.
* For convenience, uWSGI recognizes bare `.ini` arguments specially, so the invocation `uwsgi myconf.ini` is equal to `uwsgi --ini myconf.ini`.

### Reloading the server

When running with the `master` process mode, the uWSGI server can be gracefully restarted without closing the main sockets.

This funcitonality allows you patch/upgrade the uWSGI server without closing the connection with the web server and losing a single request.

When you send the *SIGHUP* to the master process it will try to gracefully stop all the workers, waiting for the completion of any currently running requests.

Then it closes all the eventually opened file descriptors not related to uWSGI.

Lastly, it binary patches (using `execve()`) the uWSGI process image with a new one, inheriting all of the previous file descriptors.

The server will known that it is a reloaded instance and will skip all the sockets initialization, reusing the previous ones.

*Sending the SIGTERM signal will obtain the same result reload-wise but will not wait for the completion of running requests.*

There are several ways to make uWSGI gracefully restart.

There are several ways to make uWSGI gracefully restart.

    # using kill to send the signal
    kill -HUP `cat /tmp/project-master.pid`
    # or the convenience option --reload
    uwsgi --reload /tmp/project-master.pid
    # or if uwsgi was started with touch-reload=/tmp/somefile
    touch /tmp/somefile

Or from your application, in Python:

    uwsgi.reload()

Or in Ruby,

    UWSGI.reload

### Stoping the server

If you have the uWSGI process running in the foreground for some reason, you can just hit CTRL+C to kill it off.

When dealing with background processes, you'll need to use the master pidfile again. The SIGINT singal will kill uWSGI.

    kill -INT `cat /tmp/project-master.pid`
    # or for convenience...
    uwsgi --stop /tmp/project-master.pid

* * *

### References

* [Quickstart for Python/WSGI applications — uWSGI 2.0 documentation](http://uwsgi.readthedocs.io/en/latest/WSGIquickstart.html)

* [Managing the uWSGI server — uWSGI 2.0 documentation](http://uwsgi.readthedocs.io/en/latest/Management.html)

* [Configuring uWSGI — uWSGI 2.0 documentatio](http://uwsgi.readthedocs.io/en/latest/Configuration.html)

* [uWSGI Options — uWSGI 2.0 documentatio](http://uwsgi.readthedocs.io/en/latest/Options.html)
