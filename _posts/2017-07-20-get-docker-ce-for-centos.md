---
layout: post
title: "Get Docker CE for CentOS"
date: 2017-07-20 15:37:21 +0800
categories: ['Docker']
tags: ['Docker', 'CentOS']
disqus_identifier: 263672491001721063426242575325651420571
---

- TOC
{:toc}

### Get Docker CE for CentOS

```sh
# 1. Install required packages.
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 2. Use the following command to set up the stable repository.
$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
# 3. Update the yum package index.
$ sudo yum makecache fast
# 4. Install the latest version of Docker CE
$ sudo yum install docker-ce
# 5. Start Docker
$ sudo systemctl start docker
```

On production systems, you should install a specific version of Docker CE instead of always using the latest. 

```sh
$ yum list docker-ce.x86_64  --showduplicates | sort -r
$ sudo yum install docker-ce-<VERSION>
```

Installing Command Completion for Bash.

```sh
# 1. Make sure bash completion is installed. 
$ yum install -y bash-completion
# 2. Install docker completion.
$ sudo curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
# 3. Make docker completion to be available.
$ sudo . /etc/profile
```

RE: [Get Docker CE for CentOS](https://docs.docker.com/engine/installation/linux/docker-ce/centos/)

RE: [Command-line completion](https://docs.docker.com/machine/completion/)

### Install Docker Compose

Run this command to download Docker Compose, replacing `$dockerComposeVersion` with the specific version of Compose you want to use:

```sh
sudo curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

For example, to download Compose version 1.14.0, the command is:

```sh
sudo curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

> Use the latest Compose release number in the download command.

Apply executable permissions to the binary:

```sh
sudo chmod +x /usr/local/bin/docker-compose
```

Installing Command Completion for Bash:

```sh
sudo curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
```

RE: [Install Docker Compose](https://docs.docker.com/compose/install/)

RE: [Compose repository release page on GitHub](https://github.com/docker/compose/releases)

RE: [Command-line completion](https://docs.docker.com/compose/completion/)
