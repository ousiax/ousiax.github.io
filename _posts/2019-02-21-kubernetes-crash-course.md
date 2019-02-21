---
layout: post
title: Kubernetes 从入门到放弃
date: 2019-02-21 17:55:05 +0800
categories: ['Kubernetes']
tags: ['Kubernetes']
---

- TOC
{:toc}

<style>
img {
 width: 55%;
}
</style>

- - -

### What is Kubernetes?

- Kubernetes is a production-grade, open-source platform that orchestrates the placement (scheduling) and execution of application containers within and across computer clusters.

- Kubernetes provides a container-centric management environment. It orchestrates computing, networking, and storage infrastructure on behalf of user workloads.

- [https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)

### Kubernetes vs Docker Swarm vs Apache Mesos

![Kubernetes vs Docker Swarm vs Apache Mesos](/assets/kubernetes/k8s-swarm-mesos.png)

- [https://codefresh.io/kubernetes-tutorial/kubernetes-vs-docker-swarm-vs-apache-mesos/](https://codefresh.io/kubernetes-tutorial/kubernetes-vs-docker-swarm-vs-apache-mesos/
)

### CLOUD NATIVE <small><small>COMPUTING FOUNDATION</small></small>

![CLOUD NATIVE COMPUTING FOUNDATION](/assets/kubernetes/cncf.png)

- CNCF is an open source software foundation dedicated to making cloud native computing universal and sustainable. 
- Cloud native computing uses an open source software stack to deploy applications as microservices, packaging each part into its own container, and dynamically orchestrating those containers to optimize resource utilization. 
- Cloud native technologies enable software developers to build great products faster.
- https://www.cncf.io/


### Setup Kubernetes Cluster

![GFW](/assets/kubernetes/gfw.png)

- Minikube & Kubeadm
- AKS & EKS & ACK & TKE 

- [https://kubernetes.io/docs/setup/](https://kubernetes.io/docs/setup/)

- [https://kubernetes.io/docs/setup/minikube/](https://kubernetes.io/docs/setup/minikube/)

- [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

- [https://codefarm.me/2018/12/27/intall-minikube-with-kubeadm-on-debian/](https://codefarm.me/2018/12/27/intall-minikube-with-kubeadm-on-debian/)

- [https://codefarm.me/2019/01/28/bootstrapping-kubernetes-clusters-with-kubeadm/](https://codefarm.me/2019/01/28/bootstrapping-kubernetes-clusters-with-kubeadm/)

#### Set docker.service behind HTTP proxy

```sh
# 1. Edit the docker.service configuration with systemctl
$ sudo systemctl edit docker.service
# 2. Add the following text in the editor (Please update the PROXY_HOST and PROXY_PORT !!!)
#   [Service]
#   Environment="HTTP_PROXY=http://PROXY_HOST:PROXY_PORT/" "NO_PROXY=registry.docker-cn.com,registry-mirror-cache-cn.oss-cn-shanghai.aliyuncs.com,repository.gridsum.com,index.docker.io,registry.hub.docker.com,registry-1.docker.io,auth.docker.io,production.cloudflare.docker.com" "HTTPS_PROXY=http://PROXY_HOST:PROXY_PORT/"
# 3. Exit the editor. You can also run the following command to print the docker.service.d/override.conf
$ cat /etc/systemd/system/docker.service.d/override.conf 
[Service]
Environment="HTTP_PROXY=http://PROXY_HOST:PROXY_PORT/" "NO_PROXY=registry.docker-cn.com,registry-mirror-cache-cn.oss-cn-shanghai.aliyuncs.com,repository.gridsum.com,index.docker.io,registry.hub.docker.com,registry-1.docker.io,auth.docker.io,production.cloudflare.docker.com" "HTTPS_PROXY=http://PROXY_HOST:PROXY_PORT/"
# 4. Reload systemd manager configuration
$ sudo systemctl daemon-reload
# 5. Restart the docker.service
$ sudo systemctl restart docker.service
```

#### Set HTTP Proxy for APT/YUM

```sh
# Set HTTP proxy for APT:
$ cat <<EOF > /etc/apt/apt.conf.d/httproxy 
> Acquire::http::Proxy "http://PROXY_HOST:PORT";
> EOF

# Set HTTP proxy for YUM:
$ echo 'proxy=http://PROXY_HOST:PORT' >> /etc/yum.conf
```

#### Start minikube behind a HTTP Proxy

```sh
 $ minikube start \
     --docker-env HTTP_PROXY=http://PROXY_HOST:PORT/ \
     --docker-env HTTPS_PROXY=http://PROXY_HOST:PORT/ \
     --docker-env NO_PROXY=index.docker.io,\
 registry.hub.docker.com,\
 registry-1.docker.io,\
 registry.docker-cn.com,\
 registry-mirror-cache-cn.oss-cn-shanghai.aliyuncs.com,\
 192.168.99.100\
     --registry-mirror https://registry.docker-cn.com
```

- [https://codefarm.me/2018/08/09/http-proxy-docker-minikube/](https://codefarm.me/2018/08/09/http-proxy-docker-minikube/)


### Learn Kubernetes Basics

- Deploy an App
- Explore Your App
- Expose Your App Publicly
- Scale Your App
- Update Your App
 
- [https://kubernetes.io/docs/tutorials/kubernetes-basics/](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

#### Kubectl

Kubectl is a command line interface for running commands against Kubernetes clusters. 

```sh
# kubectl controls the Kubernetes cluster manager.
$ kubectl --help
# Output shell completion code for the specified shell (bash or zsh).
$ kubectl completion --help
# Print the supported API resources on the server
$ kubectl api-resources --help
# List the fields for supported resources
$ kubectl explain --help
# Modify kubeconfig files using subcommands like "kubectl config set current-context my-context"
$ kubectl config --help
# Print the logs for a container in a pod or specified resource.
$ kubectl logs --help
# Execute a command in a container.
$ kubectl exec --help
```

#### Using kubectl to Create a Deployment

![Kubernetes Cluster](https://d33wubrfki0l68.cloudfront.net/152c845f25df8e69dd24dd7b0836a289747e258a/4a1d2/docs/tutorials/kubernetes-basics/public/images/module_02_first_app.svg)

```sh
$ kubectl run nginx --image=nginx:1.15 --port 80

$ kubectl proxy

$ curl -iI http://localhost:8001/api/v1/namespaces/default/pods/$(kubectl get po –o jsonpath='{.items[0].metadata.name}')/proxy
```

- **kubectl get** - list resources
- **kubectl describe** - show detailed information about a resource
- **kubectl logs** - print the logs from a container in a pod
- **kubectl exec** - execute a command on a container in a pod

#### Viewing Pods and Nodes

![Node overview](https://d33wubrfki0l68.cloudfront.net/5cb72d407cbe2755e581b6de757e0d81760d5b86/a9df9/docs/tutorials/kubernetes-basics/public/images/module_03_nodes.svg)

- Pod is a Kubernetes abstraction that represents a group of one or more application containers (such as Docker or rkt), and some shared resources for those containers. Those resources include:
- Shared storage, as Volumes
- Networking, as a unique cluster IP address
- Information about how to run each container, such as the container image version or specific ports to use
 
- A Pod models an application-specific "logical host" and can contain different application containers which are relatively tightly coupled.
 
- Pods are the atomic unit on the Kubernetes platform.

#### Pods overview

![Pods overview](https://d33wubrfki0l68.cloudfront.net/fe03f68d8ede9815184852ca2a4fd30325e5d15a/98064/docs/tutorials/kubernetes-basics/public/images/module_03_pods.svg)

#### Node overview

![Node overview](https://d33wubrfki0l68.cloudfront.net/5cb72d407cbe2755e581b6de757e0d81760d5b86/a9df9/docs/tutorials/kubernetes-basics/public/images/module_03_nodes.svg)

- A Pod always runs on a Node.
- A Node is a worker machine in Kubernetes and may be either a virtual or a physical machine, depending on the cluster.
- Each Node is managed by the Master.
- A Node can have multiple pods, and the Kubernetes master automatically handles scheduling the pods across the Nodes in the cluster.
 
- Every Kubernetes Node runs at least:
    - **Kubelet**, a process responsible for communication between the Kubernetes Master and the Node; it manages the Pods and the containers running on a machine.
    - A **container runtime** (like Docker, rkt) responsible for pulling the container image from a registry, unpacking the container, and running the application.

#### Using a Service to Expose Your App

![Services and Labels](https://d33wubrfki0l68.cloudfront.net/cc38b0f3c0fd94e66495e3a4198f2096cdecd3d5/ace10/docs/tutorials/kubernetes-basics/public/images/module_04_services.svg)

- Kubernetes Pods are mortal.
- A Kubernetes Service is an abstraction layer which defines a logical set of Pods and enables external traffic exposure, load balancing and service discovery for those Pods.
- Services can be exposed in different ways by specifying a type in the ServiceSpec:
    - **ClusterIP** (default) - Exposes the Service on an internal IP in the cluster. This type makes the Service only reachable from within the cluster.
    - **NodePort** - Exposes the Service on the same port of each selected Node in the cluster using NAT. Makes a Service accessible from outside the cluster using <NodeIP>:<NodePort>. Superset of ClusterIP.
    - **LoadBalancer** - Creates an external load balancer in the current cloud (if supported) and assigns a fixed, external IP to the Service. Superset of NodePort.
    - **ExternalName** - Exposes the Service using an arbitrary name (specified by externalName in the spec) by returning a CNAME record with the name. No proxy is used.

##### Services and Labels

![Services and Labels](https://d33wubrfki0l68.cloudfront.net/b964c59cdc1979dd4e1904c25f43745564ef6bee/f3351/docs/tutorials/kubernetes-basics/public/images/module_04_labels.svg)

- **Labels** are key/value pairs that are attached to objects, such as pods. 
- Labels are intended to be used to specify identifying attributes of objects that are meaningful and relevant to users, but do not directly imply semantics to the core system.
- Labels can be used to organize and to select subsets of objects. 
- Services match a set of Pods using labels and selectors, a grouping primitive that allows logical operation on objects in Kubernetes. 
- [https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

##### Expose Your App Publicly

```sh
$ kubectl run nginx --image=nginx:1.15 --port=80
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/nginx created
$ kubectl get po nginx-6f7d58d4cc-7vnxv --show-labels 
NAME                     READY   STATUS    RESTARTS   AGE   LABELS
nginx-6f7d58d4cc-7vnxv   1/1     Running   0          13s   pod-template-hash=6f7d58d4cc,run=nginx
$ kubectl expose deployment nginx --type=NodePort --port=80 
service/nginx exposed
$ kubectl get svc nginx 
NAME    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.98.138.39   <none>        80:31462/TCP   26s
```

```sh
$ kubectl get svc nginx -ojsonpath='{.spec.ports[0].nodePort}'
31462$ kubectl get no -o wide
NAME          STATUS   ROLES    AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
far-seer-01   Ready    master   24d   v1.13.2   192.168.66.128   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-8-amd64    docker://18.6.0
$ curl -iI 192.168.66.128:31462
HTTP/1.1 200 OK
Server: nginx/1.15.8
Date: Thu, 21 Feb 2019 07:24:48 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 25 Dec 2018 09:56:47 GMT
Connection: keep-alive
ETag: "5c21fedf-264"
Accept-Ranges: bytes

```

### Running Multiple Instances of Your App

![Current State](https://d33wubrfki0l68.cloudfront.net/043eb67914e9474e30a303553d5a4c6c7301f378/0d8f6/docs/tutorials/kubernetes-basics/public/images/module_05_scaling1.svg)

![New State](https://d33wubrfki0l68.cloudfront.net/30f75140a581110443397192d70a4cdb37df7bfc/b5f56/docs/tutorials/kubernetes-basics/public/images/module_05_scaling2.svg)


#### Scale Your App

```sh
$ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6f7d58d4cc-7vnxv   1/1     Running   0          20m
$ kubectl scale deployment nginx --replicas=4    # scale out
deployment.extensions/nginx scaled
$ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6f7d58d4cc-7vnxv   1/1     Running   0          20m
nginx-6f7d58d4cc-ddhgk   1/1     Running   0          5s
nginx-6f7d58d4cc-l7grh   1/1     Running   0          5s
nginx-6f7d58d4cc-m8nr2   1/1     Running   0          5s
```

```sh

$ kubectl scale deployment nginx --replicas=2    # scale in
deployment.extensions/nginx scaled
$ kubectl get po -w
NAME                     READY   STATUS        RESTARTS   AGE
nginx-6f7d58d4cc-7vnxv   1/1     Running       0          21m
nginx-6f7d58d4cc-ddhgk   1/1     Running       0          62s
nginx-6f7d58d4cc-l7grh   0/1     Terminating   0          62s
nginx-6f7d58d4cc-m8nr2   0/1     Terminating   0          62s
nginx-6f7d58d4cc-m8nr2   0/1   Terminating   0     64s
nginx-6f7d58d4cc-m8nr2   0/1   Terminating   0     64s
nginx-6f7d58d4cc-l7grh   0/1   Terminating   0     64s
nginx-6f7d58d4cc-l7grh   0/1   Terminating   0     64s
^C$ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6f7d58d4cc-7vnxv   1/1     Running   0          21m
nginx-6f7d58d4cc-ddhgk   1/1     Running   0          79s
$ 
```

### Performing a Rolling Update

![Current State](https://d33wubrfki0l68.cloudfront.net/30f75140a581110443397192d70a4cdb37df7bfc/fa906/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates1.svg)

![Updating State](https://d33wubrfki0l68.cloudfront.net/678bcc3281bfcc588e87c73ffdc73c7a8380aca9/703a2/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates2.svg)

![New State](https://d33wubrfki0l68.cloudfront.net/6d8bc1ebb4dc67051242bc828d3ae849dbeedb93/fbfa8/docs/tutorials/kubernetes-basics/public/images/module_06_rollingupdates4.svg)

#### Update Your App

```sh
$ kubectl get deployment
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     2            2           53m
$ kubectl get svc nginx 
NAME    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.98.138.39   <none>        80:31462/TCP   52m
$ curl -iIs 192.168.66.128:31462 | grep Server
Server: nginx/1.15.8
$ kubectl set image deploy nginx nginx=nginx:1.13 && kubectl get deploy nginx -w
deployment.extensions/nginx image updated
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     1            2           54m
nginx   3/2   1     3     54m
nginx   2/2   1     2     54m
nginx   2/2   2     2     54m
^Ccurl -iIs 192.168.66.128:31462 | grep Server
Server: nginx/1.13.12
```

```sh
$ kubectl rollout undo deployment nginx 
deployment.extensions/nginx rolled back
$ kubectl get deployments -w
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     2            2           58m
^Ccurl -iIs 192.168.66.128:31462 | grep Server
Server: nginx/1.15.8
$ kubectl rollout undo deployment nginx 
deployment.extensions/nginx rolled back
$ curl -iIs 192.168.66.128:31462 | grep Server
Server: nginx/1.13.12
$ kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-5df8d97c98   0         0         0       21m
nginx-6b46d56475   2         2         2       17m
nginx-6f7d58d4cc   0         0         0       63m
$ kubectl rollout history deployment nginx 
deployment.extensions/nginx 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

### Quit or not quit ?

[https://kubernetes.io/](https://kubernetes.io/)
