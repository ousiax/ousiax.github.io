---
layout: post
title: "Get started with Django"
date: 2015-08-25 09:24:02 +0800
categories: ['python']
tags: ['django', 'python']
---
### 1. Project

    $ python -c "import django; print(django.get_version())" 

**1.1 Django project structure**

{% highlight shell %}
$ django-admin startproject mysite
$ tree
.
`-- mysite
    |-- manage.py
    `-- mysite
        |-- __init__.py
        |-- settings.py
        |-- urls.py
        `-- wsgi.py

2 directories, 5 files
{% endhighlight %}

* The outer mysite/ root direcotry is just a container for your project. Its name doesn't matter to Django; you can rename it anything you like.
* *manage.py*: A command-line utility that lets you interact with this Django project in various ways. You can read all the details about *manage.py* in *django-admin* and *manage.py*.
* The inner mysite/ directory is the actual Python package for your project. Its name is the Python package name you'll need to use to import anything inside it (e.g. mysite.urls).
* *mysite/\_\_init\_\_.py*: An empty file that tells Python that this directory should be considered a Python package.
* *mysite/settings.py*: Setting/configuration for this Django project. Django settings will tell you about how settings work.
* *mysite/urls.py*: The URL declarations for this Django project; a "table of contents" of your Django-powered site. You can read more about URLs in URL dispatcher.
* *mysite/wsgi.py*: An entry-point for WSGI-compatible web servers to serve your project. See How to deploy with WSGI for more details.

**1.2 Database setup**

*mysite/settings.py*, a normal Python module with module-level variables representing Django settings.

By default, the configuration uses SQLite. SQLite is included in Python, so you don't need to install anything else to support your database.

If you wish to use another database, install the appropriate database bindings, and change the following keys in the DATABASES 'default' item to match your database connection settings:

* ENGINE – Either 'django.db.backends.sqlite3', 'django.db.backends.postgresql_psycopg2', 'django.db.backends.mysql', or 'django.db.backends.oracle'. 
* NAME – The name of your database. If you’re using SQLite, the database will be a file on your computer; in that case, NAME should be the full absolute path, including filename, of that file. The default value, os.path.join(BASE_DIR, 'db.sqlite3'), will store the file in your project directory.If you are not using SQLite as your database, additional settings such as USER, PASSWORD, HOSTmust be added.

**1.3 INSTALLED_APPS (settings.py/INSTALLED_APPS)**

INSTALLED_APPS holds the names of all Django applications that are activated in this Django instance. Apps can be used in multiple projects, and you can package and distribute them for use by others in their projects.

By default, INSTALLED_APPS contains the following apps, all of which come with Django:

* django.contrib.admin – The admin site.
* django.contrib.auth – An authentication system.
* django.contrib.contenttypes – A framework for content types.
* django.contrib.sessions – A session framework.
* django.contrib.messages – A messaging framework.
* django.contrib.staticfiles – A framework for managing static files.

These applications are included by default as a convenience for the common case.

**1.4 migrate command**

    $python manage.py migrate

The migrate command looks at the INSTALLED_APPS settings and creates any necessary database tables according to the database settings in your mysite/settings.py file and the database migrations shipped with the app.

**1.5 The development server**

    $python manage.py runserver

    Performing system checks...

    0 errors found
    August 25, 2015 - 15:50:53
    Django version 1.8, using settings 'mysite.settings'
    Starting development server at http://127.0.0.1:8000/
    Quit the server with CONTROL-C.

You've started the Django development server, a lightweight Web Server written purely in Python.

*Changing the port*

By default, the runserver command starts the development server on the internal IP at port 8000.

If you want to change the server's port, pass it as a command-line argument. For instance, this command start the server on port 8080:

    $python manage.py runserver 8080

If you want to change the server's IP, pass it along with the port. So to listen on all public IPs (usefull if you want to show off your work on other computers on your network), use:

    $python manage.py runserver 0.0.0.0:8000

*Automatic reloading of runserver*

The development server automatically reloads Python code for each request as needed. You don't need to restart the server for code changes to take effect. However, some actions like adding files don't trigger a restart, so you'll have to restart the server in these cases.

### 2.model

**2.1 Creating models**

Each application you write in Django consists of a Python package that follows a certain convention. Django comes with a utility that automaticlly generates the basic directory structure of an app, so you can focus on writing code rather than creating directories.

*Projects vs. apps*

What's the diffrence between a project and an app? An app is a Web applicaiton that does something – e.g., a Weblog system, a database of public records or a simple poll app. A project is a colleciton of configuration and apps for a particular Web site. A project can certain multiple apps. An app can be in multiple projects.

Your app live anywhere on your Python path.

To create your app, make sure your're in the same directory as manage.py and type this command:

    $ python manage.py startapp polls
    
        polls/
            __init__.py
            admin.py
            migrations/
                __init__.py
            models.py
            tests.py
            views.py

        This directory structure will house the poll application.

    Philosophy
        A model is the single, definitive source of truth about your data. It contains the essential fields and behaviors of the data you're storing. Django follows the DRY principle. The goal is to define your data model in one place and automatically derive things from it.
        This inlcudes the migrations - unlike in Ruby On Rails, for example, migrations are entirely derived from your models file, and are essentially just a history that Django can roll through to update your database schema to match your current models.
    polls/models.py

        from django.db import models

        class Question(models.Model):
                question_text = models.CharField(max_length=200)
                pub_date = models.DateTimeField('date published')

        class Choice(models.Model):
            question = models.ForeignKey(Question)
            choice_text = models.CharField(max_lenght=200)
            votes = models.IntegerField(default=0)

        The code is straigthforward. Each model is represented by a class that subclasses django.db.models.Model. 
        Each model has a number of class variables, each of which represents a database field in the model.
        Each field is represented by an instance of a Field class – e.g.,CharField for character fields and DateTimeField for datetimes. This tells Django what type of data each field holds.
        # The name of each Field instance (e.g. question_text or pub_date) is the field's name, in machine-friendly format. You'll use this value in your Python code, and your database will use it as the column name.
        # Django supports all the common database relationships: many-to-one, many-to-many and one-to-one.
2.2 Activating models
    That small bit of model code gives Django a lot of information. With it, Django is able to:

        Create a database schema (CREATE TABLE statements) for this app.
        Create a Python database-access API for accessing Question and Choice objects.

    mysite/settings.py

        INSTALLED_APPS = (

            'django.contrib.admin',
            'django.contrib.auth',
            'django.contrib.contenttypes',
            'django.contrib.sessions',
            'django.contrib.messages',
            'django.contrib.staticfiles',
            'polls'

        )

2.3 Migrations
    Migrations are how Django stores changes to your models (and thus your database schema)-they're just files on disk. You can read the migration for your new model if you like; it's the file polls/migrations/0001_initial.py.
    Migrations are very powerfull and let you change your models over time, as you develop your project, without the need to delete your database or tables and make new ones - it specializes in upgrading your database live, without losing data.

        Change your models (in models.py).
        Run python manage.py makemigrations to create migrations for those changes.
        Run python manage.py migrate to apply those changes to the database.

    The reason that there are seperate commands to make and apply migrations is because you'll commit migrations to your version control system and ship them with your app; they not only make your development easier, they're also useable by other developers and in production.
    Make migrations
        $python manage.py makemigrations polls
    Preview migrations
        $python manage.py sqlmigrate polls 0001

        BEGIN;
        CREATE TABLE "polls_choice" (
            "id" serial NOT NULL PRIMARY KEY,
            "choice_text" varchar(200) NOT NULL,
            "votes" integer NOT NULL
        );
        CREATE TABLE "polls_question" (
            "id" serial NOT NULL PRIMARY KEY,
            "question_text" varchar(200) NOT NULL,
            "pub_date" timestamp with time zone NOT NULL
        );
        ALTER TABLE "polls_choice" ADD COLUMN "question_id" integer NOT NULL;
        ALTER TABLE "polls_choice" ALTER COLUMN "question_id" DROP DEFAULT;
        CREATE INDEX "polls_choice_7aa0f6ee" ON "polls_choice" ("question_id");
        ALTER TABLE "polls_choice"
          ADD CONSTRAINT "polls_choice_question_id_246c99a640fbbd72_fk_polls_question_id"
            FOREIGN KEY ("question_id")
            REFERENCES "polls_question" ("id")
            DEFERRABLE INITIALLY DEFERRED;
        COMMIT;

    Apply migrations
        $python manage.py migrate

        Operations to perform:
          Synchronize unmigrated apps: staticfiles, messages
          Apply all migrations: admin, contenttypes, polls, auth, sessions
        Synchronizing apps without migrations:
          Creating tables...
            Running deferred SQL...
          Installing custom SQL...
        Running migrations:
          Rendering model states... DONE
          Applying <migration name>... OK

            The migrate command takes alll the migrations that haven't been applied (Django tacks whick one are applied using a special table in your database called django_migrations) and run them against your database-essentially, synchronizing the changes you made to your models with the schema in the database.
2.4 Playing with API
    $python manage.py shell
    Hop into the interactive Python shell and play around with the free API django gives you.
    We're using this instead of simply typing "python", because manage.py sets the DJANGO_SETTINGS_MODULE environment variable, which gives Django the Python import path to your mysite/settings.py file.

    Bypassing manage.py

        If you’d rather not use manage.py, no problem. Just set the DJANGO_SETTINGS_MODULE environment variable to mysite.settings, start a plain Python shell, and set up Django:

    >>> importdjango
    >>> django.setup()

        If this raises an AttributeError, you’re probably using a version of Django that doesn’t match this version. You’ll want to switch to the newer Django version.

        You must run python from the same directory manage.py is in, or ensure that directory is on the Python path, so that importmysite works.

    >>> from polls.models import Question,Choice# Import the model classes we just wrote.
    # No questions are in the system yet.
    >>> Question.objects.all()
    []
    # Create a new Question.
    # Support for time zones is enabled in the default settings file, so
    # Django expects a datetime with tzinfo for pub_date. Use timezone.now()
    # instead of datetime.datetime.now() and it will do the right thing.
    >>> fromdjango.utilsimporttimezone
    >>> q=Question(question_text="What's new?",pub_date=timezone.now())
    # Save the object into the database. You have to call save() explicitly.
    >>> q.save()
    # Now it has an ID. Note that this might say "1L" instead of "1", depending
    # on which database you're using. That's no biggie; it just means your
    # database backend prefers to return integers as Python long integer
    # objects.
    >>> q.id
    1
    # Access model field values via Python attributes.
    >>> q.question_text
    "What's new?"
    >>> q.pub_date
    datetime.datetime(2012, 2, 26, 13, 0, 0, 775217, tzinfo=<UTC>)
    # Change values by changing the attributes, then calling save().
    >>> q.question_text="What's up?"
    >>> q.save()
    # objects.all() displays all the questions in the database.
    >>> Question.objects.all()
    [<Question: Question object>]


2.5 __str__ or __unicode__?


    On Python 3, it’s easy, just use __str__().

    On Python 2, you should define __unicode__() methods returning unicode values instead. Django models have a default __str__() method that calls __unicode__() and converts the result to a UTF-8 bytestring. This means that unicode(p) will return a Unicode string, and str(p) will return a bytestring, with characters encoded as UTF-8. Python does the opposite: object has a __unicode__ method that calls __str__ and interprets the result as an ASCII bytestring. This difference can create confusion.

    If all of this is gibberish to you, just use Python 3.

