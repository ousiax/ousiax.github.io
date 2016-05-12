---
layout: post
title: "Linux Shared Library Management & Debugging Problem"
date: 2016-05-12 18-26-42 +0800
categories: ['Linux']
tags: ['Linux']
disqus_identifier: 243398258692857642813586467616780302218
---
If you are a developer, you will re-use code provided by others.

Usually **/lib, /lib64, /usr/local/lib**, and other directories stores various shared libraries. You can write your own program using these shared libraries. As a sys admin you need to manage and install these shared libraries. Use the following commands for shared libraries management, security, and debugging problems.

## What is a Library In Linux or UNIX ?

In Linux or UNIX like operating system, a library is nothing but a collection of resources such as subroutines / functions, classes, values or type specifications. There are two types of libraries:

1. **Static libraries**

    All lib\*.a files are included into executables that use their functions.

2. **Dynamic libraries or linking** \[also known as DSO (dynamic shared object)\]

    All lib\*.so\* files are not copied into executables. The executable will automatically load the libraries using `ld.so` or `ld-linux.so`.

## Linux Library Management Commands

1. **ldconfig**: Updates the necessary links for the run time link bindings.

2. **ldd**: Tells what libraries a given program needs to run.

3. **ltrace**: A library call tracer.

4. **ld.so/ld-linux.so**: Dynamic linker/loader.

## Important Files

As a sys admin you should be aware of important files related to shared libraries:

1. **/lib/ld-linux.so.\***: Execution time linker/loader.

2. **/etc/ld.so.conf**: File containing a list of colon, space, tab, newline, or comma separated directories in which to search for libraries.

3. **/etc/ld.so.cache**: File containing an ordered list of libraries found in the diretories specified in `/etc/ld.so.conf`. This file is not in human readable format, and is not intended to be edited. This file is created by `ldconfig` command.

4. **lib\*.so.version**: Shared libraries stores in **/lib, /lib64, /usr/lib, /usr/lib64, /usr/local/lib** directories.

### \#1: **ldconfig** command

You need to use the **ldconfig command** to create, update, and remove the necessary links and cache (for use by the run-time linker, *ld.so*) to the most recent shared libraries foudn in the directories specified on the command line, in the file */etc/ld.so.conf*, and in the trused directories (*/usr/lib*, */lib64* and */lib*). The ldconfig command checks the header and file names of the libraries it encounters when determining which versions should have their links updated. This command also creates a file called ***/etc/ld.so.cache which is used to speed up linking.***

**Examples**
In this exmaple, you've installed a new set of shared libraries at **/usr/local/lib/**:

    $ ls -l /usr/local/lib/

    -rw-r--r-- 1 root root 878738 Jun 16  2010 libGeoIP.a
    -rwxr-xr-x 1 root root    799 Jun 16  2010 libGeoIP.la
    lrwxrwxrwx 1 root root     17 Jun 16  2010 libGeoIP.so -> libGeoIP.so.1.4.6
    lrwxrwxrwx 1 root root     17 Jun 16  2010 libGeoIP.so.1 -> libGeoIP.so.1.4.6
    -rwxr-xr-x 1 root root 322776 Jun 16  2010 libGeoIP.so.1.4.6
    -rw-r--r-- 1 root root  72172 Jun 16  2010 libGeoIPUpdate.a
    -rwxr-xr-x 1 root root    872 Jun 16  2010 libGeoIPUpdate.la
    lrwxrwxrwx 1 root root     23 Jun 16  2010 libGeoIPUpdate.so -> libGeoIPUpdate.so.0.0.0
    lrwxrwxrwx 1 root root     23 Jun 16  2010 libGeoIPUpdate.so.0 -> libGeoIPUpdate.so.0.0.0
    -rwxr-xr-x 1 root root  55003 Jun 16  2010 libGeoIPUpdate.so.0.0.0

You need to run ldconfig command mannully to link libraries by passing them as command line arguments with the **-l** switch:

    # ldconfig -l /path/to/lib/our.new.lib.so

Another recommended options for sys admin is to create a file called **/etc/ld.so.conf.d/geoip.conf** as follows:

    /usr/local/lib

Now just run ldconfig to update the cache:

    # ldconfig

To verify new libs or to look for a linked library, enter:

    # ldconfig -v
    # ldconfig -v | grep -i geoip

**Troubleshooting Chrooted Jails**

You can print the current cache with the `-p` option:

    # ldconfig -p

**Common error**

You may see the errors as follows:

> Dynamic linker error in foo

> Can’t map cache file cache-file

All of the above errors means the linker cache file `/etc/ld.so.cache` is corrupt or does not exits. To fix these errors simply run the `ldconfig` command as follows:

    # ldconfig

> Can't find library xyz Error

The executable required a dynamically linked library that `ld.so` or `ld-linux.so` cannot find. It means a library called *xyz* needed by the program called *foo* not installed or path is not set.

To fix this problem install *xyz* library and set path in `/etc/ld.so.conf` file or create a file in `/etc/ld.so.conf.d/` directory.

### \#2: **ldd** command

**ldd** (List Dynamic Dependencies) is a Unix and Linux program to display the shared libraries required by each program. This tools is required to build and run various server program in a chroot jail. A typical example is as follows to list the Apache server shared libraries, enter:

    # ldd /usr/sbin/httpd

    libm.so.6 => /lib64/libm.so.6 (0x00002aff52a0c000)
    libpcre.so.0 => /lib64/libpcre.so.0 (0x00002aff52c8f000)
    libselinux.so.1 => /lib64/libselinux.so.1 (0x00002aff52eab000)

Now, you can copy all those libs one by one to `/jail` directory.

**Report Missing Functions**

Type the following command:

    $ ldd -d /path/to/executable

**Report Missing Objects**

Type the following command:

    $ ldd -r /path/to/executable

**Determine If Particular Feature Supported Or Not**

    # ldd /usr/sbin/sshd | grep libwrap

**Other usage of ldd command**

You can use the ldd command when an executable is failing because of a missing dependency. Once you found a missing dependency, you can install it or update the cache with the ldconfig command as mentioned above.

### \#3: **ltrace** command

The **ltrace command** simply runs the specified command until it exits. It intercepts and records the dynamic library calls which are called by the executed process and the signals which are received by that process. It can also intercept and print the system calls executed by the program.

    # ltrace /usr/sbin/httpd
    # ltrace /sbin/chroot /usr/sbin/httpd
    # ltrace /bin/ls

### \#4: **ld.so/ld-linux.so** Command

The **ld.so / ld-linux.so** used as follows by Linux:

1. To load the shared libraries needed by a program.
2. To prepare the program to run, and then runs it.

**List All Dependencies and How They Are Resolved**

Type the following command:

    # cd /lib

For 64 bit systems:

    # cd /lib64

Pass the `--list` option, enter:

    # ./ld-2.5.so --list /path/to/executable

Other options

From the man page:

    --verify                   verify that given object really is a dynamically linked object we can handle
    --library-path PATH   use given PATH instead of content of the environment variable LD_LIBRARY_PATH
    --inhibit-rpath LIST    ignore RUNPATH and RPATH information in object names in LIST

**Environment Variables**

The **LD\_LIBRARY\_PATH** can be used to set a library path for finding dynamic libraries using LD\_LIBRARY\_PATH, in the standard colon seperated format:

    $ export LD_LIBRARY_PATH=/opt/simulator/lib:/usr/local/lib

The **LD\_PRELOAD** allow an *extra library* not specified in the executable to be loaded:

    $ export LD_PRELOAD=/home/vivek/dirhard/libdiehard.so

Please note that these variables are ignored when executing setuid/setgid programs.

* * *
## References

* [Linux Commands For Shared Library Management & Debugging Problem](http://www.cyberciti.biz/tips/linux-shared-library-management.html)
