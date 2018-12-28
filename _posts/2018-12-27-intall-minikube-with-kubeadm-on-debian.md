---
layout: post
title: Intall Minikube (v0.32.0) on Debian 9
date: 2018-12-27 13:49:17 +0800
categories: ['Docker']
tags: ['Docker', 'K8S', 'Kubernetes', 'Minikube', 'Kubeadm']
disqus_identifier: 25609677555699789769540068998527786259
---
- TOC
{:toc}
---

## 1. Install minikube binary with curl

```sh
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/v0.32.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
```

Use the following command to enable bash completion for kubernetes with kubectl:

```sh
sudo apt-get install bash-completion && sudo sh -c 'minikube completion bash > /etc/bash_completion.d/minikube.bash' && source /etc/bash_completion.d/minikube.bash
```



## 2. Install kubectl binary with curl

```sh
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
```

>> You must use a kubectl version that is within one minor version difference of your cluster. For example, a v1.2 client should work with v1.1, v1.2, and v1.3 master. Using the latest version of kubectl helps avoid unforeseen issues.

>> To download `kubectl` behind HTTP proxy (e.g. through GFW to access Google, FB etc..), please set up environment as below:
> 
> ```sh
> YOURPROXY=127.0.0.1 # please update with your HTTP proxy host
> PORT=1080 # please update with your HTTP proxy port
> export {HTTP,HTTPS}_PROXY=http://$YOURPROXY:$PORT/
> export {http,https}_proxy=http://$YOURPROXY:$PORT/
> export {NO_PROXY,no_proxy}=localhost,127.0.0.1,::1,192.168.99.100
> ```

Use the following command to enable bash completion for kubernetes with kubectl:

```sh
sudo apt-get install bash-completion && sudo sh -c 'kubectl completion bash > /etc/bash_completion.d/kubectl.bash' && source /etc/bash_completion.d/kubectl.bash
```

## 3. Install VirtualBox with APT

Add Oracle public key for apt-secure:

```sh
curl -LO https://www.virtualbox.org/download/oracle_vbox_2016.asc
sudo apt-key add oracle_vbox_2016.asc
```

Add the following line to your `/etc/apt/sources.list.d/vmbox.list`.

```sh
echo 'deb http://download.virtualbox.org/virtualbox/debian stretch contrib' | sudo tee /etc/apt/sources.list.d/vmbox.list
```

 To install VirtualBox, do

```sh
sudo apt-get update && sudo apt-get install virtualbox-5.2 -y
```

> This system is currently not set up to build kernel modules.
> Please install the Linux kernel "header" files matching the current kernel
> for adding new hardware support to the system.
> The distribution packages containing the headers are probably:
>     linux-headers-amd64 linux-headers-4.9.0-4-amd64
> This system is currently not set up to build kernel modules.
> Please install the Linux kernel "header" files matching the current kernel
> for adding new hardware support to the system.
> The distribution packages containing the headers are probably:
>     linux-headers-amd64 linux-headers-4.9.0-4-amd64
> 
> There were problems setting up VirtualBox.  To re-start the set-up process, run
>   /sbin/vboxconfig
> as root.

> To solve the problem, please execute the command as below:
> 
> ```sh
> sudo apt-get install linux-headers-amd64 linux-headers-4.9.0-4-amd64 && sudo /sbin/vboxconfig
> ```

## 4. Start minikube

Before start the minikube, you can setup some optional environment variables as below:

```sh
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false

export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir -p $HOME/.kube
mkdir -p $HOME/.minikube
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config
```

Use the `minikube start` to start the minikube cluster.

> You can also use the `minikube start -v 9` to enable debug logging during startup.

> At the first time, Minikube will download needed `kubeadm`, `kubelet` and ISO image (e.g. `minikube-v0.32.0.iso`) and start the Minikube virtual machine. To check the status of Minikube `minikube status` can be executed. If Minikube works fine the output of the command will be like below.

```sh
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

> After the VM started, minikube will pull docker images to start cluster components. The minikube might be fail to pull images via your network behind GFW. If the minikube starts failed, please check the needed docker images whether have downloaded as expected.

 ```sh
 $ minikube status
 E1227 18:46:05.523830   16511 status.go:88] Error kubelet status: getting status: Process exited with status 3
 $ minikube ssh 'docker images|grep -v REPOSITORY|wc -l'  # print docker images count in the minikube VM
 0
 ```

> The version 0.32.0 minikube will use `kubeadm` to bootstrap clusters. You can use `kubeadm config images list` to print a list of images kubeadm will use.

```sh
$ chmod +x ./.minikube/cache/v1.12.4/kubeadm && ./.minikube/cache/v1.12.4/kubeadm config images list
 I1227 18:42:36.348876   16494 version.go:93] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://dl.k8s.io/release/stable-1.txt: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
 I1227 18:42:36.348953   16494 version.go:94] falling back to the local client version: v1.12.4
 k8s.gcr.io/kube-apiserver:v1.12.4
 k8s.gcr.io/kube-controller-manager:v1.12.4
 k8s.gcr.io/kube-scheduler:v1.12.4
 k8s.gcr.io/kube-proxy:v1.12.4
 k8s.gcr.io/pause:3.1
 k8s.gcr.io/etcd:3.2.24
 k8s.gcr.io/coredns:1.2.2
 ```

> To solve the above problem, you can mannully pull these images with [Docker behind HTTP proxy](/2018/08/09/http-proxy-docker-minikube/#2-custom-docker-daemon-options-with-http-proxy) and use `docker save` and `docker load` with `minikube ssh` to minikube VM. For example:

 ```none
 $ minikube ssh # enter the minikube VM
                          _             _            
             _         _ ( )           ( )           
   ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __  
 /' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
 | ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
 (_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)
 
 $ scp x@192.168.66.140:/home/x/minikube-v0.32.0/images.tar . # use scp to copy images
 x@192.168.66.140's password: 
 images.tar                                                                                                                              100% 1008MB  11.8MB/s   01:25    
 $ docker load -i images.tar 
 0c1604b64aed: Loading layer [==================================================>]   44.6MB/44.6MB
 dc6f419d40a2: Loading layer [==================================================>]  3.407MB/3.407MB
 2a6024944fd1: Loading layer [==================================================>]  50.36MB/50.36MB
 Loaded image: k8s.gcr.io/kube-proxy:v1.12.4
 8a788232037e: Loading layer [==================================================>]   1.37MB/1.37MB
 fef21df29df0: Loading layer [==================================================>]    163MB/163MB
 Loaded image: k8s.gcr.io/kube-controller-manager:v1.12.4
 63c53f48f45b: Loading layer [==================================================>]  57.22MB/57.22MB
 Loaded image: k8s.gcr.io/kube-scheduler:v1.12.4
 469d6bfe88bc: Loading layer [==================================================>]  192.8MB/192.8MB
 Loaded image: k8s.gcr.io/kube-apiserver:v1.12.4
 9198eadacc0a: Loading layer [==================================================>]  542.2kB/542.2kB
 9949e50e3468: Loading layer [==================================================>]  38.94MB/38.94MB
 Loaded image: k8s.gcr.io/coredns:1.2.2
 cd7100a72410: Loading layer [==================================================>]  4.403MB/4.403MB
 86e1bc08db56: Loading layer [==================================================>]  2.732MB/2.732MB
 ffb9278c02c6: Loading layer [==================================================>]  6.082MB/6.082MB
 49c864efad6a: Loading layer [==================================================>]  3.584kB/3.584kB
 . . .
 $ minikube stop && minikube start # restart minikube to restart cluster components
 ```

> You can also use [minikube with an HTTP proxy](/2018/08/09/http-proxy-docker-minikube/#3-start-minikube-behind-a-http-proxy) to supply Docker in the minikube VM with the proxy settings. For example:
 
```sh
$ minikube start --docker-env http_proxy=http://$YOURPROXY:PORT \
               --docker-env https_proxy=https://$YOURPROXY:PORT
```

## 5 Tips and Tricks 

### 5.1 Error starting cluster:  kubeadm init error 

```sh
$ minikube start -v 9
. . .
E1227 20:41:40.056575   21198 start.go:343] Error starting cluster:  kubeadm init error 
sudo /usr/bin/kubeadm init --config /var/lib/kubeadm.yaml --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests --ignore-preflight-errors=DirAvailable--data-minikube --ignore-preflight-errors=Port-10250 --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-etcd.yaml --ignore-preflight-errors=Swap --ignore-preflight-errors=CRI 
 running command: : Process exited with status 2
```

This is beacuse there are no needed `kubeadm config images list` in the minikube VM. To solve it, please load the required docker images and reset kubeadm.

```sh
$ docker images
REPOSITORY                                TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kubernetes-dashboard-amd64     v1.10.1             f9aed6605b81        10 days ago         122MB
k8s.gcr.io/kube-proxy                     v1.12.4             6d393e89739f        13 days ago         96.5MB
k8s.gcr.io/kube-controller-manager        v1.12.4             51b2a8e5ff78        13 days ago         164MB
k8s.gcr.io/kube-scheduler                 v1.12.4             c1b5e63c0b56        13 days ago         58.4MB
k8s.gcr.io/kube-apiserver                 v1.12.4             c04b373449d3        13 days ago         194MB
k8s.gcr.io/etcd                           3.2.24              3cab8e1b9802        3 months ago        220MB
k8s.gcr.io/coredns                        1.2.2               367cdc8433a4        4 months ago        39.2MB
k8s.gcr.io/kube-addon-manager             v8.6                9c16409588eb        10 months ago       78.4MB
k8s.gcr.io/pause                          3.1                 da86e6ba6ca1        12 months ago       742kB
gcr.io/k8s-minikube/storage-provisioner   v1.8.1              4689081edb10        13 months ago       80.8MB
$ sudo kubeadm reset -f && \
    sudo /usr/bin/kubeadm init --config /var/lib/kubeadm.yaml --ignore-preflight-errors=DirAvailable--etc-kubernetes-manifests --ignore-preflight-errors=DirAvailable--data-minikube --ignore-preflight-errors=Port-10250 --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml --ignore-preflight-errors=FileAvailable--etc-kubernetes-manifests-etcd.yaml --ignore-preflight-errors=Swap --ignore-preflight-errors=CRI
```

> You can also solve it via use minikube behind HTTP proxy to pull images through GFW.

### 5.2 Minikube hangs up at Machine exists, restarting cluster components...

First of all, use the `minikube status` to get the local kubernetes cluster status.

```sh
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

If it looks fine, try the `kubectl get po --all-namespaces` as below.

```sh
$ kubectl get po --all-namespaces 
NAMESPACE     NAME                                    READY   STATUS             RESTARTS   AGE
kube-system   etcd-minikube                           1/1     Running            1          19m
kube-system   kube-addon-manager-minikube             1/1     Running            1          19m
kube-system   kube-apiserver-minikube                 1/1     Running            0          4s
kube-system   kube-controller-manager-minikube        1/1     Running            0          19m
kube-system   kube-scheduler-minikube                 1/1     Running            1          19m
kube-system   kubernetes-dashboard-5bff5f8fb8-c7dz7   0/1     ImagePullBackOff   0          19m
kube-system   storage-provisioner                     0/1     ImagePullBackOff   0          19m
```

Use the `kubectl -n kube-system describe po [POD_NAME]` to show details of the above failed pods.

```sh
$ kubectl -n kube-system describe po storage-provisioner
. . .
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  28m                  default-scheduler  Successfully assigned kube-system/storage-provisioner to minikube
  Normal   Pulling    26m (x4 over 28m)    kubelet, minikube  pulling image "gcr.io/k8s-minikube/storage-provisioner:v1.8.1"
  Warning  Failed     25m (x4 over 28m)    kubelet, minikube  Failed to pull image "gcr.io/k8s-minikube/storage-provisioner:v1.8.1": rpc error: code = Unknown desc = Error response from daemon: Get https://gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
. . .
  Normal   BackOff    7m20s (x7 over 10m)  kubelet, minikube  Back-off pulling image "gcr.io/k8s-minikube/storage-provisioner:v1.8.1"
  Warning  Failed     5m3s (x15 over 10m)  kubelet, minikube  Error: ImagePullBackOff
$ kubectl -n kube-system describe po kubernetes-dashboard-5bff5f8fb8-c7dz7
. . .
Events:
  Type     Reason       Age                   From               Message
  ----     ------       ----                  ----               -------
  Normal   Scheduled    31m                   default-scheduler  Successfully assigned kube-system/kubernetes-dashboard-5bff5f8fb8-c7dz7 to minikube
  Normal   Pulling      28m (x4 over 31m)     kubelet, minikube  pulling image "k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1"
  Warning  Failed       28m (x4 over 30m)     kubelet, minikube  Failed to pull image "k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1": rpc error: code = Unknown desc = Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
. . .
  Normal   BackOff      9m54s (x6 over 12m)   kubelet, minikube  Back-off pulling image "k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1"
  Warning  Failed       2m26s (x36 over 12m)  kubelet, minikube  Error: ImagePullBackOff

```

We find there are two pods `kubernetes-dashboard-5bff5f8fb8-c7dz7` and `storage-provisioner` with `ImagePullBackOff` status. This is beacuse the minikube enable the addons `dashboard` and `storage-provisioner` as default, and minikube could not pull image via your network ( e.g. through GFW).

```sh
$ minikube addons list
- addon-manager: enabled
- dashboard: enabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- heapster: disabled
- ingress: disabled
- metrics-server: disabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
```

To sovle it, your can pull the images `k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1` and `gcr.io/k8s-minikube/storage-provisioner:v1.8.1` behind HTTP proxy and use `docker save` and `docker load` to load these images into you minikub VM.

> If you use the minikube with HTT proxy, you will not see this problem.

> You can also use `minikube addons disable [ADDONS_NAME]` to disable addons both `dashboard` and `storage-provisioner`, then reset the kubeadm.


### 5.3 Minikube Usefull CLI

```none
$ minikube -h
Minikube is a CLI tool that provisions and manages single-node Kubernetes clusters optimized for development workflows.

Usage:
  minikube [command]

Available Commands:
  addons         Modify minikube's kubernetes addons
  completion     Outputs minikube shell completion for the given shell (bash or zsh)
  ip             Retrieves the IP address of the running cluster
  logs           Gets the logs of the running instance, used for debugging minikube, not user code
  service        Gets the kubernetes URL(s) for the specified service in your local cluster
  ssh            Log into or run a command on a machine with SSH; similar to 'docker-machine ssh'
  start          Starts a local kubernetes cluster
  status         Gets the status of a local kubernetes cluster
  stop           Stops a running local kubernetes cluster
  version        Print the version of minikube
```

### 5.4 Run a Stateless Nginx Application

1. Start minikube

    ```sh
    $ minikube start 
    Starting local Kubernetes v1.12.4 cluster...
    Starting VM...
    Getting VM IP address...
    Moving files into cluster...
    Setting up certs...
    Connecting to cluster...
    Setting up kubeconfig...
    Stopping extra container runtimes...
    Machine exists, restarting cluster components...
    Verifying kubelet health ...
    Verifying apiserver health .....Kubectl is now configured to use the cluster.
    Loading cached images from config file.
    
    
    Everything looks great. Please enjoy minikube!
    ```
    
2. Create a YAML file named nignx.yaml as blow:
    
    ```yaml
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: nginx
    spec:
      selector:
        app: nginx
      type: NodePort
      ports:
        - port: 80
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
            - name: nginx
              image: nginx:1.15
              ports:
                - containerPort: 80
    ...
    ```
    
3. Create a Nginx service and deployment based on the above YAML file.
    
    ```sh
    $ $ kubectl create -f nginx.yaml 
    service/nginx created
    deployment.apps/nginx created
    ```
    
4. List the pods created by the deployment:
    
    ```sh
    $ kubectl get po -w
    NAME                     READY   STATUS              RESTARTS   AGE
    nginx-5d445489fb-gjbs6   0/1     ContainerCreating   0          3s
    nginx-5d445489fb-h7vjl   0/1     ContainerCreating   0          3s
    nginx-5d445489fb-knf9f   0/1     ContainerCreating   0          3s
    nginx-5d445489fb-knf9f   1/1   Running   0     48s
    nginx-5d445489fb-gjbs6   1/1   Running   0     51s
    nginx-5d445489fb-h7vjl   1/1   Running   0     60s
    ```
    
5. Lists the URLs for the services in your local cluster
    
    ```sh
    $ minikube service list 
    |-------------|------------|-----------------------------|
    |  NAMESPACE  |    NAME    |             URL             |
    |-------------|------------|-----------------------------|
    | default     | kubernetes | No node port                |
    | default     | nginx      | http://192.168.99.100:32151 |
    | kube-system | kube-dns   | No node port                |
    |-------------|------------|-----------------------------|
    ```
    
6. Access the Nginx service
    
    ```sh
    $ curl -iI $(minikube service nginx --url)
    HTTP/1.1 200 OK
    Server: nginx/1.15.8
    Date: Thu, 27 Dec 2018 13:33:25 GMT
    Content-Type: text/html
    Content-Length: 612
    Last-Modified: Tue, 25 Dec 2018 09:56:47 GMT
    Connection: keep-alive
    ETag: "5c21fedf-264"
    Accept-Ranges: bytes
    
    ```

## 6. References

- [https://github.com/kubernetes/minikube/releases/tag/v0.32.0](https://github.com/kubernetes/minikube/releases/tag/v0.32.0)
- [https://github.com/kubernetes/minikube](https://github.com/kubernetes/minikube)
- Running Kubernetes Locally via Minikube, [https://kubernetes.io/docs/setup/minikube/](https://kubernetes.io/docs/setup/minikube/)

- [https://kubernetes.io/docs/setup/minikube/#using-minikube-with-an-http-proxy](https://kubernetes.io/docs/setup/minikube/#using-minikube-with-an-http-proxy)
- Docker and Minikube behind HTTP Proxy, [https://codefarm.me/2018/08/09/http-proxy-docker-minikube/](/2018/08/09/http-proxy-docker-minikube/)
