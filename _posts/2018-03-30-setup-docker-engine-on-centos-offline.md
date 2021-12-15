---
layout: post
title: "Setup Docker Engine on Centos Offline"
date: 2018-03-30 13:50:26 +0800
categories: ['docker']
tags: ['centos', 'docker']
---


- TOC
{:toc}

- - -

Let's run a container with the command `docker run --rm -it centos:7 bash` as our operating environment.

```txt
$ docker run --rm -it centos:7 bash
[root@89b94344d402 /]#
```

1. Use the following command to setup the docker stable repository.

    ```txt
    [root@5879a18a8be4 ~]# curl -sSL https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/
    ```

1. Use the `yum list docker-ce --showduplicates | sort -r` to list all available *docker-ce* packages.

    ```txt
    [root@5879a18a8be4 ~]# yum list docker-ce --showduplicates | sort -r
    docker-ce.x86_64            18.03.0.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.12.1.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.12.0.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.09.1.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.09.0.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.06.2.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.06.1.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.06.0.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.03.2.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.03.1.ce-1.el7.centos             docker-ce-stable
    docker-ce.x86_64            17.03.0.ce-1.el7.centos             docker-ce-stable
    ```

1. Use `repoquery -R docker-ce-17.12.0.ce-1.el7.centos` to list all dependency packages.

    *You can also use `yum deplist docker-ce-17.12.0.ce-1.el7.centos` to list dependency packages.*

    ```txt
    [root@5879a18a8be4 ~]# repoquery -R docker-ce-17.12.0.ce-1.el7.centos
    /bin/sh
    container-selinux >= 2.9
    device-mapper-libs >= 1.02.90-1
    iptables
    libc.so.6(GLIBC_2.17)(64bit)
    libcgroup
    libdevmapper.so.1.02()(64bit)
    libdevmapper.so.1.02(Base)(64bit)
    libdevmapper.so.1.02(DM_1_02_97)(64bit)
    libdl.so.2()(64bit)
    libdl.so.2(GLIBC_2.2.5)(64bit)
    libltdl.so.7()(64bit)
    libpthread.so.0()(64bit)
    libpthread.so.0(GLIBC_2.2.5)(64bit)
    libpthread.so.0(GLIBC_2.3.2)(64bit)
    libseccomp.so.2()(64bit)
    libsystemd.so.0()(64bit)
    libsystemd.so.0(LIBSYSTEMD_209)(64bit)
    rtld(GNU_HASH)
    systemd-units
    tar
    xz
    ```

    Use the `yum provides [libxxx]` to find what package provides the given value *libxxx*. For example:

    ```none
    # yum provides libdevmapper.so.1.02
    Loaded plugins: fastestmirror, ovl
    Loading mirror speeds from cached hostfile
     * base: mirrors.tuna.tsinghua.edu.cn
     * extras: mirrors.tuna.tsinghua.edu.cn
     * updates: mirrors.tuna.tsinghua.edu.cn
    7:device-mapper-libs-1.02.146-4.el7.i686 : Device-mapper shared library
    Repo        : base
    Matched from:
    Provides    : libdevmapper.so.1.02
    ```

1. Let's make a directory named `docker-ce` and use `yumdownloader --resolve docker-ce-17.12.0.ce-1.el7.centos` to download docker-ce and all its dependency packages.

    ```txt
    [root@5879a18a8be4 ~]# mkdir docker-ce
    [root@5879a18a8be4 ~]# cd docker-ce
    [root@5879a18a8be4 docker-ce]# yumdownloader --resolve docker-ce device-mapper-libs systemd libseccomp -q
    warning: /root/docker-ce/audit-libs-python-2.7.6-3.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    Public key for audit-libs-python-2.7.6-3.el7.x86_64.rpm is not installed
    Public key for iptables-1.4.21-18.3.el7_4.x86_64.rpm is not installed
    Public key for container-selinux-2.42-1.gitad8f0f7.el7.noarch.rpm is not installed
    ...
    [root@5879a18a8be4 docker-ce]# ls
    audit-libs-2.8.1-3.el7_5.1.i686.rpm              libseccomp-2.3.1-3.el7.i686.rpm
    audit-libs-2.8.1-3.el7_5.1.x86_64.rpm            libseccomp-2.3.1-3.el7.x86_64.rpm
    audit-libs-python-2.8.1-3.el7_5.1.x86_64.rpm     libselinux-2.5-12.el7.i686.rpm
    bzip2-libs-1.0.6-13.el7.i686.rpm                 libselinux-2.5-12.el7.x86_64.rpm
    checkpolicy-2.5-6.el7.x86_64.rpm                 libselinux-python-2.5-12.el7.x86_64.rpm
    container-selinux-2.68-1.el7.noarch.rpm          libselinux-utils-2.5-12.el7.x86_64.rpm
    ...
    ```
    
1. Use the `tar cf docker-ce.offline.tar *.rpm` to pack the rpm packages.
    
    ```txt
    [root@5879a18a8be4 docker-ce]# tar cf docker-ce.offline.tar *.rpm
    ```
    
1. Copy the the *docker-ce.offline.tar* to the destination machine with *scp* or *ftp* etc..
    
    ```txt
    [root@5879a18a8be4 docker-ce]# scp docker-ce.offline.tar username@hostname:/dest_dir
    ```
    
1. Use the command `rpm -ivh --replacepkgs --replacefiles *.rpm` to install docker-ce.
    
    ```txt
    [root@9ddda0cd196d ~]# tar xf docker-ce.offline.tar
    [root@9ddda0cd196d ~]# ls
    audit-libs-2.8.1-3.el7_5.1.i686.rpm              libseccomp-2.3.1-3.el7.i686.rpm
    audit-libs-2.8.1-3.el7_5.1.x86_64.rpm            libseccomp-2.3.1-3.el7.x86_64.rpm
    audit-libs-python-2.8.1-3.el7_5.1.x86_64.rpm     libselinux-2.5-12.el7.i686.rpm
    bzip2-libs-1.0.6-13.el7.i686.rpm                 libselinux-2.5-12.el7.x86_64.rpm
    checkpolicy-2.5-6.el7.x86_64.rpm                 libselinux-python-2.5-12.el7.x86_64.rpm
    container-selinux-2.68-1.el7.noarch.rpm          libselinux-utils-2.5-12.el7.x86_64.rpm
    ...
    [root@9ddda0cd196d ~]# rpm -ivh --replacepkgs --replacefiles *.rpm
    warning: docker-ce-17.12.0.ce-1.el7.centos.x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID 621e9f35: NOKEY
    Preparing...                          ################################# [100%]
    Updating / installing...
       1:libselinux-utils-2.5-11.el7      ################################# [  5%]
       2:policycoreutils-2.5-17.1.el7     ################################# [ 10%]
       3:selinux-policy-3.13.1-166.el7_4.9################################# [ 15%]
       4:libnfnetlink-1.0.1-4.el7         ################################# [ 20%]
       5:libcgroup-0.41-13.el7            ################################# [ 25%]
       6:selinux-policy-targeted-3.13.1-16################################# [ 30%]
    ...
      18:policycoreutils-python-2.5-17.1.e################################# [ 90%]
      19:container-selinux-2:2.42-1.gitad8################################# [ 95%]
    setsebool:  SELinux is disabled.
      20:docker-ce-17.12.0.ce-1.el7.centos################################# [100%]
    ```
    
1. Configure Docker to start on boot
    
    ```sh
    [root@9ddda0cd196d ~]# systemctl enable docker
    ```
    
1. Set the registry-mirrors array in /etc/docker/daemon.json to pull from the China registry mirror by default.
    
    ```sh
    [root@9ddda0cd196d ~]# mkdir -p /etc/docker
    [root@9ddda0cd196d ~]# bash -c 'cat << EOF > /etc/docker/daemon.json
    {
      "registry-mirrors": ["https://registry.docker-cn.com"]
    }
    EOF'
    ```
    
1. Start Docker
    
    ```sh
    [root@9ddda0cd196d ~]# systemctl start docker
    ```
    
- - -
    
1. [https://www.centos.org/docs/5/html/Deployment\_Guide-en-US/s1-rpm-using.html](https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-rpm-using.html)
1. [https://codefarm.me/2017/07/20/get-docker-ce-for-centos/](/2017/07/20/get-docker-ce-for-centos/)
