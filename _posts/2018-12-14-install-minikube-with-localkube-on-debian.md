---
layout: post
title: Install Minikube with localkube on Debian 9
date: 2018-12-14 06:47:24 +0800
categories: ['Docker']
tags: ['Docker', 'K8S', 'Kubernetes', 'Minikube']
disqus_identifier: 236578891763823879063645218115848355420
---

- TOC
{:toc}

- - -

### 1. Install minikube binary with curl.

```sh
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.25.2/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
```

### 2. Install the kubectl binary with curl.

```sh
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
```

>> You must use a kubectl version that is within one minor version difference of your cluster. For example, a v1.2 client should work with v1.1, v1.2, and v1.3 master. Using the latest version of kubectl helps avoid unforeseen issues.

### 3. Install VirtualBox with apt.

Add Oracle public key for apt-secure:

```sh
curl -LO https://www.virtualbox.org/download/oracle_vbox_2016.asc
sudo apt-key add oracle_vbox_2016.asc
```

Add the following line to your `/etc/apt/sources.list.d/vmbox.list`.

```sh
deb http://download.virtualbox.org/virtualbox/debian stretch contrib
```

 To install VirtualBox, do

```sh
sudo apt-get update
sudo apt-get install virtualbox-5.2
```

### 4. Setup minikube and troubleshooting

#### 4.1 Failed to download Minikube ISO 

**Problem**

```none
$ minikube start -v 999
. . .
Starting local Kubernetes v1.9.4 cluster...
Starting VM...
Downloading Minikube ISO
E1214 07:38:27.480534   10992 start.go:159] Error starting host: Error attempting to cache minikube ISO from URL: Error downloading Minikube ISO: failed to download: failed to download to temp file: download failed: 5 error(s) occurred:

* Temporary download error: Get https://storage.googleapis.com/minikube/iso/minikube-v0.25.1.iso: dial tcp: lookup storage.googleapis.com on 192.168.66.2:53: read udp 192.168.66.128:38600->192.168.66.2:53: i/o timeout
```

**Solution**

Manually download the ISO image and copy it to `.minikube/cache/iso/minikube-v0.25.1.iso`.

```sh
curl -LO https://storage.googleapis.com/minikube/iso/minikube-v0.25.1.iso && mv minikube-v0.25.1.iso .minikube/cache/iso/minikube-v0.25.1.iso && rm .minikube/cache/iso/.tmp-minikube-v0.25.1.iso*
```

#### 4.2 Error updating cluster:  Error updating localkube from uri: Error creating localkube asset from url: Error opening file asset: ...

**Problem**

```none
$ minikube start -v 999
. . .
Starting local Kubernetes v1.9.4 cluster...
Starting VM...
. . .
Moving files into cluster...
E1214 08:07:50.144101   11616 start.go:234] Error updating cluster:  Error updating localkube from uri: Error creating localkube asset from url: Error opening file asset: /home/x/.minikube/cache/localkube/localkube-v1.9.4: open /home/x/.minikube/cache/localkube/localkube-v1.9.4: no such file or directory
```

**Solution**

Manually download localkube and copy it to `.minikube/cache/localkube/localkube-v1.9.4`.

```none
curl -LO https://github.com/kubernetes/minikube/releases/download/v0.25.2/localkube && mv localkube .minikube/cache/localkube/localkube-v1.9.4
```

#### 4.3 Print the client and server version information.

```none
$ minikube start
Starting local Kubernetes v1.9.4 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"11", GitVersion:"v1.11.0", GitCommit:"91e7b4fd31fcd3d5f436da26c980becec37ceefe", GitTreeState:"clean", BuildDate:"2018-06-27T20:17:28Z", GoVersion:"go1.10.2", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"", Minor:"", GitVersion:"v1.9.4", GitCommit:"bee2d1505c4fe820744d26d41ecd3fdd4a3d6546", GitTreeState:"clean", BuildDate:"2018-03-21T21:48:36Z", GoVersion:"go1.9.1", Compiler:"gc", Platform:"linux/amd64"}
```

#### 4.4 Error response from daemon: Get https://gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers) ...

**Problem**

```none
Warning FailedCreatePodSandBox kubelet, minikube Failed create pod sandbox.
```

```none
$ minikube logs
-- Logs begin at Fri 2018-12-14 00:27:57 UTC, end at Fri 2018-12-14 00:35:41 UTC. --
. . .
Dec 14 00:35:20 minikube localkube[3608]: E1214 00:35:20.811495    3608 remote_runtime.go:92] RunPodSandbox from runtime service failed: rpc error: code = Unknown desc = failed pulling image "gcr.io/google_containers/pause-amd64:3.0": Error response from daemon: Get https://gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
Dec 14 00:35:20 minikube localkube[3608]: E1214 00:35:20.811548    3608 kuberuntime_sandbox.go:54] CreatePodSandbox for pod "kube-addon-manager-minikube_kube-system(c4c3188325a93a2d7fb1714e1abf1259)" failed: rpc error: code = Unknown desc = failed pulling image "gcr.io/google_containers/pause-amd64:3.0": Error response from daemon: Get https://gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
Dec 14 00:35:20 minikube localkube[3608]: E1214 00:35:20.811572    3608 kuberuntime_manager.go:647] createPodSandbox for pod "kube-addon-manager-minikube_kube-system(c4c3188325a93a2d7fb1714e1abf1259)" failed: rpc error: code = Unknown desc = failed pulling image "gcr.io/google_containers/pause-amd64:3.0": Error response from daemon: Get https://gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
Dec 14 00:35:20 minikube localkube[3608]: E1214 00:35:20.811666    3608 pod_workers.go:186] Error syncing pod c4c3188325a93a2d7fb1714e1abf1259 ("kube-addon-manager-minikube_kube-system(c4c3188325a93a2d7fb1714e1abf1259)"), skipping: failed to "CreatePodSandbox" for "kube-addon-manager-minikube_kube-system(c4c3188325a93a2d7fb1714e1abf1259)" with CreatePodSandboxError: "CreatePodSandbox for pod \"kube-addon-manager-minikube_kube-system(c4c3188325a93a2d7fb1714e1abf1259)\" failed: rpc error: code = Unknown desc = failed pulling image \"gcr.io/google_containers/pause-amd64:3.0\": Error response from daemon: Get https://gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)"
Dec 14 00:35:23 minikube localkube[3608]: E1214 00:35:23.244071    3608 healthcheck.go:317] Failed to start node healthz on 0: listen tcp: address 0: missing port in address
```

**Solution**

Manully download the folloing Docker images and load to minikube VM with `minikube ssh`. 

```
k8s.gcr.io/kubernetes-dashboard-amd64         v1.8.1              e94d2f21bc0c        12 months ago       121MB
gcr.io/google-containers/kube-addon-manager   v6.5                d166ffa9201a        13 months ago       79.5MB
gcr.io/k8s-minikube/storage-provisioner       v1.8.1              4689081edb10        13 months ago       80.8MB
k8s.gcr.io/k8s-dns-sidecar-amd64              1.14.5              fed89e8b4248        14 months ago       41.8MB
k8s.gcr.io/k8s-dns-kube-dns-amd64             1.14.5              512cd7425a73        14 months ago       49.4MB
k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64        1.14.5              459944ce8cc4        14 months ago       41.4MB
gcr.io/google_containers/pause-amd64          3.0                 99e59f495ffa        2 years ago         747kB
```

### 5. Quickstart with Nginx

```
$ kubectl run nginx-app --image=nginx --port 80 --image-pull-policy=IfNotPresent
deployment.apps/nginx-app created
$ kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
nginx-app-84bd9fdcc6-d9bsq   1/1       Running   0          2s
$ kubectl expose deployment nginx-app --type=NodePort
service/nginx-app exposed
$ curl -sI $(minikube service nginx-app --url)
HTTP/1.1 200 OK
Server: nginx/1.15.7
Date: Fri, 14 Dec 2018 01:29:36 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 27 Nov 2018 12:31:56 GMT
Connection: keep-alive
ETag: "5bfd393c-264"
Accept-Ranges: bytes

$ kubectl scale --replicas=4 deployment nginx-app
deployment.extensions/nginx-app scaled
$ kubectl get pods
NAME                         READY     STATUS    RESTARTS   AGE
nginx-app-84bd9fdcc6-4jhqh   1/1       Running   0          31s
nginx-app-84bd9fdcc6-d9bsq   1/1       Running   0          5m
nginx-app-84bd9fdcc6-vxntl   1/1       Running   0          31s
nginx-app-84bd9fdcc6-wcgbh   1/1       Running   0          31s
$ kubectl scale --replicas=2 deployment nginx-app
deployment.extensions/nginx-app scaled
$ kubectl get pods
NAME                         READY     STATUS        RESTARTS   AGE
nginx-app-84bd9fdcc6-4jhqh   1/1       Running       0          2m
nginx-app-84bd9fdcc6-d9bsq   1/1       Running       0          7m
nginx-app-84bd9fdcc6-vxntl   0/1       Terminating   0          2m
$ kubectl get rs
NAME                   DESIRED   CURRENT   READY     AGE
nginx-app-84bd9fdcc6   2         2         2         8m
$ kubectl describe rs nginx-app-84bd9fdcc6
Name:           nginx-app-84bd9fdcc6
Namespace:      default
Selector:       pod-template-hash=4068598772,run=nginx-app
Labels:         pod-template-hash=4068598772
                run=nginx-app
Annotations:    deployment.kubernetes.io/desired-replicas=2
                deployment.kubernetes.io/max-replicas=3
                deployment.kubernetes.io/revision=1
Controlled By:  Deployment/nginx-app
Replicas:       2 current / 2 desired
Pods Status:    2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  pod-template-hash=4068598772
           run=nginx-app
  Containers:
   nginx-app:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  8m    replicaset-controller  Created pod: nginx-app-84bd9fdcc6-d9bsq
  Normal  SuccessfulCreate  3m    replicaset-controller  Created pod: nginx-app-84bd9fdcc6-wcgbh
  Normal  SuccessfulCreate  3m    replicaset-controller  Created pod: nginx-app-84bd9fdcc6-4jhqh
  Normal  SuccessfulCreate  3m    replicaset-controller  Created pod: nginx-app-84bd9fdcc6-vxntl
  Normal  SuccessfulDelete  39s   replicaset-controller  Deleted pod: nginx-app-84bd9fdcc6-wcgbh
  Normal  SuccessfulDelete  39s   replicaset-controller  Deleted pod: nginx-app-84bd9fdcc6-vxntl
$ kubectl describe deployment nginx-app
Name:                   nginx-app
Namespace:              default
CreationTimestamp:      Fri, 14 Dec 2018 09:25:54 +0800
Labels:                 run=nginx-app
Annotations:            deployment.kubernetes.io/revision=1
Selector:               run=nginx-app
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  run=nginx-app
  Containers:
   nginx-app:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-app-84bd9fdcc6 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  8m    deployment-controller  Scaled up replica set nginx-app-84bd9fdcc6 to 1
  Normal  ScalingReplicaSet  3m    deployment-controller  Scaled up replica set nginx-app-84bd9fdcc6 to 4
  Normal  ScalingReplicaSet  58s   deployment-controller  Scaled down replica set nginx-app-84bd9fdcc6 to 2
$ kubectl describe service nginx-app
Name:                     nginx-app
Namespace:                default
Labels:                   run=nginx-app
Annotations:              <none>
Selector:                 run=nginx-app
Type:                     NodePort
IP:                       10.97.148.193
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30735/TCP
Endpoints:                172.17.0.4:80,172.17.0.5:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
$ kubectl delete deployment nginx-app
deployment.extensions "nginx-app" deleted
$ kubectl get pods
No resources found.
```

### References

- [https://codefarm.me/2018/08/09/http-proxy-docker-minikube/](/2018/08/09/http-proxy-docker-minikube/)
- [https://github.com/kubernetes/minikube/releases/tag/v0.25.2](https://github.com/kubernetes/minikube/releases/tag/v0.25.2)
- [https://github.com/kubernetes/minikube/blob/v0.25.2/README.md](https://github.com/kubernetes/minikube/blob/v0.25.2/README.md)
- [https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-curl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-curl)
- [https://www.virtualbox.org/wiki/Linux\_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads)
