---
layout: post
title: "Get Docker CE for Debian"
date: 2017-09-09 11:54:43 +0800
categories: ['docker']
tags: ['docker','debian']
---
- TOC
{:toc}
---

### Install using the repository

Before you install Docker CE for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

#### Set up the repository

1. Update the apt package index:

    ```sh
    $ sudo apt-get update
    ```
    
2. Install packages to allow apt to use a repository over HTTPS:
    
    ```sh
    $ sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common
    ```
    
3. Add Docker’s official GPG key:
    
    ```sh
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    ```
    
    *Verify that the key ID is 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88.*
    
    ```sh
    $ sudo apt-key fingerprint 0EBFCD88
    pub   rsa4096 2017-02-22 [SCEA]
          9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
    uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
    sub   rsa4096 2017-02-22 [S]
    ```

4. Use the following command to set up the stable repository.

    ```sh
    $ sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable"
    ```

*Note: The `lsb_release -cs` sub-command below returns the name of your Debian distribution, such as `stretch`.*

#### Install Docker CE

1. Update the `apt` package index.

    ```sh
    $ sudo apt-get update
    ```
    
2. Install the latest version of Docker CE, or go to the next step to install a specific version. Any existing installation of Docker is replaced.
    
    ```sh
    $ sudo apt-get install docker-ce
    ```
    
    *If you have multiple Docker repositories enabled, installing or updating without specifying a version in the `apt-get install` or `apt-get update` command will always install the highest possible version, which may not be appropriate for your stability needs.*
    
3. On production systems, you should install a specific version of Docker CE instead of always using the latest. This output is truncated. List the available versions:
    
    ```sh
    $ apt-cache madison docker-ce
     docker-ce | 17.06.2~ce-0~debian | https://download.docker.com/linux/debian stretch/stable amd64 Packages
     docker-ce | 17.03.0~ce-0~debian-stretch | https://download.docker.com/linux/debian stretch/stable amd64 Packages
    ```
    
    The contents of the list depend upon which repositories are enabled. Choose a specific version to install. The second column is the version string. The third column is the repository name, which indicates which repository the package is from and by extension its stability level. To install a specific version, append the version string to the package name and separate them by an equals sign (=):
    
    ```sh
    $ sudo apt-get install docker-ce=<VERSION_STRING>
    ```
    
    The Docker daemon starts automatically.

#### Uninstall Docker CE

1. Uninstall the Docker CE package:

    ```sh
    sudo apt-get purge docker-ce
    ```
    
1. Images, containers, volumes, or customized configuration files on your host are not automatically removed. To delete all images, containers, and volumes:
    
    ```sh
    $ sudo rm -rf /var/lib/docker
    ```

    You must delete any edited configuration files manually.

### Post-installation steps for Linux

#### Manage Docker as a non-root user

The `docker` daemon binds to a Unix socket instead of a TCP port. By default that Unix socket is owned by the user `root` and other users can only access it using `sudo`. The `docker` daemon always runs as the `root` user.

If you don’t want to use `sudo` when you use the `docker` command, create a Unix group called `docker` and add users to it. When the `docker` daemon starts, it makes the ownership of the Unix socket read/writable by the `docker` group.

>    Warning: The `docker` group grants privileges equivalent to the `root` user. For details on how this impacts security in your system, see [Docker Daemon Attack Surface](https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface).

#### Configure Docker to start on boot

**systemd**

```sh
$ sudo systemctl enable docker
```

#### Installing Bash Command Completion for Core Docker Commands

```sh
# 1. Make sure bash completion is installed. 
$ yum install -y bash-completion
# 2. Install docker completion.
$ sudo curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
# 3. Make docker completion to be available.
$ sudo . /etc/profile
```

### Install Docker Compose
On Linux, you can download the Docker Compose binary from the [Compose repository release page on GitHub](https://github.com/docker/compose/releases). Follow the instructions from the link, which involve running the curl command in your terminal to download the binaries. These step by step instructions are also included below.

1. Run this command to download Docker Compose, replacing `$dockerComposeVersion` with the specific version of Compose you want to use:

    ```sh
    sudo curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    ```
    
    For example, to download Compose version 1.15.0, the command is:
    
    ```sh
    sudo curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    ```
    
    > Use the latest Compose release number in the download command.
    
2. Apply executable permissions to the binary:
    
    ```sh
    sudo chmod +x /usr/local/bin/docker-compose
    ```
    
3. Install command completion for the `bash` shell
    
    ```sh
    sudo curl -L https://raw.githubusercontent.com/docker/compose/1.15.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    ```
4. Uninstallation

    To uninstall Docker Compose if you installed using `curl`:

    ```sh
    sudo rm /usr/local/bin/docker-compose
    ```

### References

1. [Get Docker CE for Debian \| Docker Documentation](https://docs.docker.com/engine/installation/linux/docker-ce/debian/)
1. [Install Docker Compose \| Docker Documentation](https://docs.docker.com/compose/install/)
1. [Compose command-line completion \| Docker Documentation](https://docs.docker.com/compose/completion/)
