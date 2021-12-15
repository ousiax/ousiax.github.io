---
layout: post
title:  Docker and Minikube behind HTTP Proxy
date: 2018-08-09 17:15:35 +0800
categories: ['kubernetes']
tags: ['docker', 'proxy', 'minikube', 'kubernetes']
---

- TOC
{:toc}

- - -

### 1. Setup HTTP Proxy Environment Variables 

Linux and Unix-like systems has environment variable called `http_proxy`, `https_proxy` and `no_proxy`. It allows you to connect text based session and/or applications via the proxy server. All you need is proxy server IP address (URL) and port values. The variable is almost used by all utilities such as elinks, lynx, wget, curl, git and others commands.

Type the following command to set proxy server environment variables:

```bash
$ export http_proxy=http://[USERNAME:PASSWORD@]server-ip:port/
$ export https_proxy=http://[USERNAME:PASSWORD@]server-ip:port/
$ export no_proxy=localhost,127.0.0.1,::1,codefarm.me
```

To setup the proxy environment variable as a global variable for all users, append the above settings into */etc/profile* file or */etc/profile.d/http-proxy.sh*. for example:

```bash
$ cat /etc/profile.d/http_proxy.sh
export {HTTP,HTTPS}_PROXY=http://10.38.32.9:10808/
export {http,https}_proxy=http://10.38.32.9:10808/
export {NO_PROXY,no_proxy}=localhost,127.0.0.1,::1,192.168.99.100
```
```bash
$ env | grep -i proxy
HTTP_PROXY=http://10.38.32.9:10808/
https_proxy=http://10.38.32.9:10808/
http_proxy=http://10.38.32.189:10808/
no_proxy=localhost,127.0.0.1,::1,192.168.99.100
NO_PROXY=localhost,127.0.0.1,::1,192.168.99.100
HTTPS_PROXY=http://10.38.32.9:10808/
```

### 2. Custom Docker Daemon Options with HTTP Proxy

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

### 3. Start minikube behind a HTTP Proxy

1. Print the version of minikube.

    ```sh
    $ minikube version
    minikube version: v0.25.2
    ```

    > The latest minikube version is 0.28.2 at this time, but it doesn't work well cause it hangs up at *Starting cluster components...*.

2. Use `--docker-env` flag to pass environment variables to the Docker daemon.

    ```bash
    minikube start \
        --docker-env HTTP_PROXY=http://10.38.32.9:10808/ \
        --docker-env HTTPS_PROXY=http://10.38.32.9:10808/ \
        --docker-env NO_PROXY=index.docker.io,\
    registry.hub.docker.com,\
    registry-1.docker.io,\
    registry.docker-cn.com,\
    registry-mirror-cache-cn.oss-cn-shanghai.aliyuncs.com,\
    192.168.99.100\
        --registry-mirror https://registry.docker-cn.com
    ```
    
    > Not required: Pass the `--registry-mirror` option when starting `dockerd` to pull-through China mirror cache.

    Use `kubectl version` to print the client and server version information.

    ```bash
    $ kubectl version
    Client Version: version.Info{Major:"1", Minor:"11", GitVersion:"v1.11.0", GitCommit:"91e7b4fd31fcd3d5f436da26c980becec37ceefe", GitTreeState:"clean", BuildDate:"2018-06-27T20:17:28Z", GoVersion:"go1.10.2", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"", Minor:"", GitVersion:"v1.9.4", GitCommit:"bee2d1505c4fe820744d26d41ecd3fdd4a3d6546", GitTreeState:"clean", BuildDate:"2018-03-21T21:48:36Z", GoVersion:"go1.9.1", Compiler:"gc", Platform:"linux/amd64"}
    ```

    After starting the minikube, the `--docker-env` and `--registry-mirror` options were wrote into `config.json` file at *$HOME/.minikube/machines/minikube/config.json*. And when starting minikube with `minikube start`, it will reload the config from the file `config.json` again.

    ```none
        33      "HostOptions": {
        37          "EngineOptions": {
        .
        41              "Env": [
        42                  "HTTP_PROXY=http://10.38.32.9:10808/",
        43                  "HTTPS_PROXY=http://10.38.32.9:10808/",
        44                  "NO_PROXY=index.docker.io,registry.hub.docker.com,registry-1.docker.io,registry.docker-cn.com,registry-mirror-cache-cn.oss-cn-shanghai.aliyuncs.com,192.168.99.100"
        45              ],
        .
        55              "RegistryMirror": [
        56                  "https://registry.docker-cn.com"
        57              ],
    ```

    > The `minikube start --docker-env` doesn't work on my Windows 10 laptop. But you can edit the `config.json` directly, then start the minikube and execute the following command to reload docker daemon.

    > ```bash
    > $ uname.exe  -a
    > MINGW64_NT-10.0 minikube 2.10.0(0.325/5/3) 2018-06-13 23:34 x86_64 Msys
    > $ minikube.exe  start
    > There is a newer version of minikube available (v0.28.2).  Download it here:
    > https://github.com/kubernetes/minikube/releases/tag/v0.28.2
    > 
    > To disable this notification, run the following:
    > minikube config set WantUpdateNotification false
    > Starting local Kubernetes v1.9.4 cluster...
    > Starting VM...
    > Getting VM IP address...
    > Moving files into cluster...
    > Setting up certs...
    > Connecting to cluster...
    > Setting up kubeconfig...
    > Starting cluster components...
    > Kubectl is now configured to use the cluster.
    > Loading cached images from config file.
    > Unable to load cached images from config file.
    > $ kubectl.exe version
    > Client Version: version.Info{Major:"1", Minor:"7", GitVersion:"v1.7.4", GitCommit:"793658f2d7ca7f064d2bdf606519f9fe1229c381", GitTreeState:"clean", BuildDate:"2017-08-17T08:48:23Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"windows/amd64"}
    > Server Version: version.Info{Major:"", Minor:"", GitVersion:"v1.9.4", GitCommit:"bee2d1505c4fe820744d26d41ecd3fdd4a3d6546", GitTreeState:"clean", BuildDate:"2018-03-21T21:48:36Z", GoVersion:"go1.9.1", Compiler:"gc", Platform:"linux/amd64"}
    > $ minikube.exe ssh
    >                          _             _
    >             _         _ ( )           ( )
    >   ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __
    > /' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
    > | ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
    > (_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)
    > 
    > $ sudo systemctl daemon-reload
    > $ sudo systemctl restart docker
    > ```

4. Hello Minikube

    {% raw %}
    ```bash
    $ kubectl run nginx --image=nginx --image-pull-policy=IfNotPresent --replicas=2
    deployment.apps/nginx created
    $ kubectl get pods
    NAME                     READY     STATUS    RESTARTS   AGE
    nginx-6d78847c9c-298qt   1/1       Running   0          <invalid>
    nginx-6d78847c9c-v88mt   1/1       Running   0          <invalid>
    $ kubectl expose deployments/nginx --type=NodePort --port 80
    service/nginx exposed
    $ export NODE_PORT=$(kubectl get service nginx -o go-template='{{(index .spec.ports 0).nodePort}}')
    $ echo $NODE_PORT
    32659
    $ curl -i -XOPTION $(minikube ip):$NODE_PORT
    HTTP/1.1 405 Not Allowed
    Server: nginx/1.15.2
    Date: Fri, 10 Aug 2018 09:36:08 GMT
    Content-Type: text/html
    Content-Length: 173
    Connection: keep-alive
    
    <html>
    <head><title>405 Not Allowed</title></head>
    <body bgcolor="white">
    <center><h1>405 Not Allowed</h1></center>
    <hr><center>nginx/1.15.2</center>
    </body>
    </html>
    ```
    {% endraw %}

### References

1. Proxy server \- Wikipedia, [https://en.wikipedia.org/wiki/Proxy\_server](https://en.wikipedia.org/wiki/Proxy_server)
1. How To Use Proxy Server To Access Internet at Shell Prompt With http\_proxy Variable - nixCraft, [https://www.cyberciti.biz/faq/linux-unix-set-proxy-environment-variable/](https://www.cyberciti.biz/faq/linux-unix-set-proxy-environment-variable/)
1. Control Docker with systemd \| Docker Documentation, [https://docs.docker.com/config/daemon/systemd/#httphttps-proxy](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)
1. Using Minikube with an HTTP Proxy, [https://kubernetes.io/docs/setup/minikube/#using-minikube-with-an-http-proxy](https://kubernetes.io/docs/setup/minikube/#using-minikube-with-an-http-proxy)
1. bash \- Set a network range in the no\_proxy environment variable \- Unix & Linux Stack Exchange, [https://unix.stackexchange.com/questions/23452/set-a-network-range-in-the-no-proxy-environment-variable](https://unix.stackexchange.com/questions/23452/set-a-network-range-in-the-no-proxy-environment-variable)
