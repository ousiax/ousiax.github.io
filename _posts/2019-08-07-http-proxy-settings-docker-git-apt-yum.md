---
layout: post
title: HTTP Proxy Settings for Docker, git, apt, yum
date: 2019-08-07 15:20:11 +0800
categories: ['http']
tags: ['http', 'proxy']
---

### 1. Setup HTTP Proxy Environment Variables

Linux and Unix-like systems has environment variable called `http_proxy`, `https_proxy` and `no_proxy`. It allows you to connect text based session and/or applications via the proxy server. All you need is proxy server IP address (URL) and port values. The variable is almost used by all utilities such as elinks, lynx, wget, curl, git and others commands.

Type the following command to set proxy server environment variables:

```
$ export http_proxy=http://[USERNAME:PASSWORD@]PROXY_HOST:PORT/
$ export https_proxy=http://[USERNAME:PASSWORD@]PROXY_HOST:PORT/
$ export no_proxy=localhost,127.0.0.1,::1,codefarm.me
```

To setup the proxy environment variable as a global variable for all users, append the above settings into */etc/profile* file or */etc/profile.d/http-proxy.sh*. for example:

```
$ cat /etc/profile.d/http_proxy.sh
export {HTTP,HTTPS}_PROXY=http://PROXY_HOST:PORT/
export {http,https}_proxy=http://PROXY_HOST:PORT/
export {NO_PROXY,no_proxy}=localhost,127.0.0.1,::1,192.168.99.100
```

```
$ env | grep -i proxy
HTTP_PROXY=http://PROXY_HOST:PORT/
https_proxy=http://PROXY_HOST:PORT/
http_proxy=http://10.38.32.189:10808/
no_proxy=localhost,127.0.0.1,::1,192.168.99.100
NO_PROXY=localhost,127.0.0.1,::1,192.168.99.100
HTTPS_PROXY=http://PROXY_HOST:PORT/
```

### 2. Docker

The Docker daemon uses the `HTTP_PROXY`, `HTTPS_PROXY`, and `NO_PROXY` environmental variables in its start-up environment to configure HTTP or HTTPS proxy behavior. You cannot configure these environment variables using the `daemon.json` file.

This example overrides the default `docker.service` file.

If you are behind an HTTP or HTTPS proxy server, for example in corporate settings, you need to add this configuration in the Docker systemd service file.

1.  Create a systemd drop-in directory for the docker service:

    ```bash
    $ sudo mkdir -p /etc/systemd/system/docker.service.d
    ```

2.  Create a file called `/etc/systemd/system/docker.service.d/http-proxy.conf`
    that adds the `HTTP_PROXY` environment variable:

    ```conf
    [Service]
    Environment="HTTP_PROXY=http://proxy.example.com:80/"
    ```

    Or, if you are behind an HTTPS proxy server, create a file called
    `/etc/systemd/system/docker.service.d/https-proxy.conf`
    that adds the `HTTPS_PROXY` environment variable:

    ```conf
    [Service]
    Environment="HTTPS_PROXY=https://proxy.example.com:443/"
    ```

3.  If you have internal Docker registries that you need to contact without
    proxying you can specify them via the `NO_PROXY` environment variable:

    ```conf
    [Service]    
    Environment="HTTP_PROXY=http://proxy.example.com:80/" "NO_PROXY=localhost,127.0.0.1,docker-registry.somecorporation.com"
    ```

    Or, if you are behind an HTTPS proxy server:

    ```conf
    [Service]    
    Environment="HTTPS_PROXY=https://proxy.example.com:443/" "NO_PROXY=localhost,127.0.0.1,docker-registry.somecorporation.com"
    ```

4.  Flush changes:

    ```bash
    $ sudo systemctl daemon-reload
    ```

5.  Restart Docker:

    ```bash
    $ sudo systemctl restart docker
    ```

6.  Verify that the configuration has been loaded:

    ```bash
    $ systemctl show --property=Environment docker
    Environment=HTTP_PROXY=http://proxy.example.com:80/
    ```

    Or, if you are behind an HTTPS proxy server:

    ```bash
    $ systemctl show --property=Environment docker
    Environment=HTTPS_PROXY=https://proxy.example.com:443/
    ```

### 3. apt

```sh
cat <<EOF > /etc/apt/apt.conf.d/10httproxy 
> Acquire::http::Proxy "http://PROXY_HOST:PORT";
> Acquire::http::Proxy {
>   #security.debian.org DIRECT;
>   #security-cdn.debian.org DIRECT;
>   ftp2.cn.debian.org DIRECT;
>   ftp.cn.debian.org DIRECT;
>   mirror.lzu.edu.cn DIRECT;
>   mirrors.163.com DIRECT;
>   mirrors.huaweicloud.com DIRECT;
>   mirrors.tuna.tsinghua.edu.cn DIRECT;
>   mirrors.ustc.edu.cn DIRECT;
> 
>   download.docker.com DIRECT;
>   packages.microsoft.com DIRECT;
> };
> EOF
```

### 4. yum

```sh
echo 'proxy=http://PROXY_HOST:PORT' >> /etc/yum.conf
```

### 5. git

```sh
git config --global http.proxy "http://PROXY_HOST:PORT"
```
