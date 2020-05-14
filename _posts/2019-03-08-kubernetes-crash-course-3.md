---
layout: post
title: 3 - Kubernetes Services and Ingress
date: 2019-03-04 17:55:05 +0800
categories: ['kubernetes']
tags: ['kubernetes']
---

- TOC
{:toc}

- - -

### Contents

- Services Discover
    - Environment Variables
    - **DNS** (recommended)
- Services <small>with/without Label Selector</small>
- Headless Services <small>with/without Label Selector</small>
- Service Types **ClusterIP/ExternalName/NodePort**
- Ingress

### Services Discover <small>& Environment variables (00)</small>

```sh
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   32h
$ kubectl create deployment nginx --image=nginx:1.15
deployment.apps/nginx created
$ kubectl exec nginx-5f47c69c5b-8ppph env
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
```

### Services Discover <small>& Environment variables (01)</small>

```sh
$ kubectl expose deployment nginx --port=80
service/nginx exposed
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   33h
nginx        ClusterIP   10.101.123.96   <none>        80/TCP    9m50s
$ kubectl exec -it nginx-5f47c69c5b-8ppph env
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
```

### Services Discover <small>& Environment variables (10)</small>

```sh
$ kubectl delete po nginx-5f47c69c5b-8ppph 
pod "nginx-5f47c69c5b-8ppph" deleted
$ kubectl exec nginx-5f47c69c5b-v7kkm env
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.96.0.1
NGINX_SERVICE_HOST=10.101.123.96
NGINX_SERVICE_PORT=80
```

### Services Discover <small>& DNS (00)</small>

```sh
$ kubectl get svc --all-namespaces 
NAMESPACE     NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
default       kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP         33h
kube-system   default-http-backend   NodePort    10.108.162.115   <none>        80:30001/TCP    3d4h
kube-system   kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP   10d
kube-system   kubernetes-dashboard   NodePort    10.108.191.216   <none>        443:31115/TCP   33h
```

### Services Discover <small>& DNS (01)</small>

```yaml
# network-utils-pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: network-utils
  namespace: default
  labels:
    app: network-utils
spec:
  containers:
    - name: network-utils 
      image: amouat/network-utils
      command: ['sleep', '10h']
```

### Services Discover <small>& DNS (10)</small>

```sh
$ kubectl create -f network-utils-pod.yaml 
pod/network-utils created
$ kubectl exec -it network-utils bash
root@network-utils:/# nslookup kubernetes
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1

root@network-utils:/# nslookup kubernetes.default
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

### Services Discover <small>& DNS (11)</small>

```sh
root@network-utils:/# nslookup kube-dns          
;; connection timed out; no servers could be reached

root@network-utils:/# nslookup kube-dns.kube-system
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   kube-dns.kube-system.svc.cluster.local
Address: 10.96.0.10
```

### Services <small>with Label Selectors (00)</small>

```sh
$ kubectl create deployment nginx --image=nginx:1.15
deployment.apps/nginx created
$ kubectl expose deployment nginx --port=80
service/nginx exposed
$ kubectl get svc,ep -l app=nginx
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/nginx   ClusterIP   10.111.193.91   <none>        80/TCP    59s

NAME              ENDPOINTS         AGE
endpoints/nginx   10.244.0.124:80   59s
$ kubectl exec network-utils nslookup nginx
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   nginx.default.svc.cluster.local
Address: 10.111.193.91
```

### Services <small>with Label Selectors (01)</small>

```sh
$ kubectl get ep nginx -oyaml --export 
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    app: nginx
  name: nginx
subsets:
- addresses:
  - ip: 10.244.0.124
    targetRef:
      kind: Pod
      name: nginx-5f47c69c5b-vlt69
  ports:
  - port: 80
    protocol: TCP
```

### Services <small>with Label Selectors (10)</small>

```sh
$ kubectl get svc nginx -oyaml --export 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP
```

### Services <small>with Label Selectors (11)</small>

```sh
$ kubectl scale deployment nginx --replicas=3
deployment.extensions/nginx scaled
$ kubectl get po -l app=nginx -owide
NAME                     READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
nginx-5f47c69c5b-bw7wm   1/1     Running   0          15s     10.244.0.127   far-seer-01   <none>           <none>
nginx-5f47c69c5b-shcch   1/1     Running   0          15s     10.244.0.128   far-seer-01   <none>           <none>
nginx-5f47c69c5b-vlt69   1/1     Running   0          6m10s   10.244.0.124   far-seer-01   <none>           <none>
$ kubectl get ep -l app=nginx
NAME    ENDPOINTS                                         AGE
nginx   10.244.0.124:80,10.244.0.127:80,10.244.0.128:80   6m13s
$ kubectl exec network-utils nslookup nginx
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   nginx.default.svc.cluster.local
Address: 10.102.44.128
```

### Services <small>without Label Selectors (00)</small>

```yaml
# mongo-svc.yaml (1)
apiVersion: v1
kind: Service
metadata:
  name: mongo
  labels:
    app: mongo
spec:
  ports:
    - port: 27017
      targetPort: 27017
  type: ClusterIP
```

```yaml
# mongo-svc.yaml (2)
apiVersion: v1
kind: Endpoints
metadata:
  name: mongo
  labels:
    app: mongo
subsets:
  - addresses:
      - ip: 10.200.200.157
    ports:
      - port: 27017
```

### Services <small>without Label Selectors (01)</small>

```sh
$ kubectl create -f mongo-svc.yaml 
service/mongo created
endpoints/mongo created
$ kubectl get svc,ep -l app=mongo
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/mongo   ClusterIP   10.103.114.91   <none>        27017/TCP   12s

NAME              ENDPOINTS              AGE
endpoints/mongo   10.200.200.157:27017   11s
$ kubectl exec network-utils nslookup mongo
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   mongo.default.svc.cluster.local
Address: 10.103.114.91
```

### Headless Services <small>with Label Selectors (00)</small>

```yaml
# hmac-svc.yaml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: hmacsvc
  name: hmacsvc
spec:
  externalName: hmac.internal.example.com
  type: ExternalName
```

### Headless Services <small>with Label Selectors (01)</small>

```yaml
$ kubectl create -f hmac-svc.yaml 
service/hmacsvc created
$ kubectl get svc hamcsvc 
NAME      TYPE           CLUSTER-IP   EXTERNAL-IP                          PORT(S)   AGE
hmacsvc   ExternalName   <none>       hmac.internal.example.com   <none>    7s
$ kubectl exec network-utils nslookup hmacsvc
Server:     10.96.0.10
Address:    10.96.0.10#53

hmacsvc.default.svc.cluster.local   canonical name = hmac.internal.example.com.
```

### Headless Services <small>without Label Selectors (00)</small>

```yaml
# prod-mongo-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: prod-mongo
  labels:
    app: prod-mongo
spec:
  ports:
    - port: 27017
      targetPort: 27017
  type: ClusterIP
```

```yaml
# prod-mongo-svc.yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: prod-mongo
  labels:
    app: prod-mongo
subsets:
  - addresses:
      - ip: 10.10.43.10
    ports:
      - port: 27017
  - addresses:
      - ip: 10.10.43.11
    ports:
      - port: 27017
  - addresses:
      - ip: 10.10.43.12
    ports:
      - port: 27017
```

### Headless Services <small>without Label Selectors (01)</small>

```sh
$ kubectl create -f prod-mongo-svc.yaml 
service/prod-mongo created
endpoints/prod-mongo created
$ kubectl get svc,ep -l app=prod-mongo
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
service/prod-mongo   ClusterIP   None         <none>        27017/TCP   7s

NAME                   ENDPOINTS                                                     AGE
endpoints/prod-mongo   10.10.43.10:27017,10.10.43.11:27017,10.10.43.12:27017   7s
$ kubectl exec network-utils nslookup prod-mongo
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   prod-mongo.default.svc.cluster.local
Address: 10.10.43.11
Name:   prod-mongo.default.svc.cluster.local
Address: 10.10.43.10
Name:   prod-mongo.default.svc.cluster.local
Address: 10.10.43.12
```

### NodePort Services (00)

```sh
$ kubectl create deployment nginx --image=nginx:1.15
deployment.apps/nginx created
$ kubectl expose deployment nginx --type=NodePort --port=80
service/nginx exposed
$ kubectl get svc -l app
NAME    TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.106.42.214   <none>        80:31868/TCP   32s
$ curl -iI localhost:31868
HTTP/1.1 200 OK
Server: nginx/1.15.8
Date: Mon, 11 Mar 2019 02:42:28 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 25 Dec 2018 09:56:47 GMT
Connection: keep-alive
ETag: "5c21fedf-264"
Accept-Ranges: bytes
```

### NodePort Services (01)

```yaml
# kubectl get svc nginx -oyaml --export 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
  type: NodePort
```

### NodePort Services (10)

```yaml
# nginx-svc.yaml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx-01
spec:
  ports:
    - port: 80
      targetPort: 80
      nodePort: 31115
  selector:
    app: nginx
  type: NodePort
```

### NodePort Services (11)

```sh
$ kubectl create -f nginx-svc.yaml 
service/nginx-01 created
$ kubectl get svc -l app
NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx      NodePort   10.106.42.214   <none>        80:31868/TCP   12m
nginx-01   NodePort   10.104.36.29    <none>        80:31115/TCP   5s
$ curl -iI localhost:31115
HTTP/1.1 200 OK
Server: nginx/1.15.8
Date: Mon, 11 Mar 2019 02:54:30 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 25 Dec 2018 09:56:47 GMT
Connection: keep-alive
ETag: "5c21fedf-264"
Accept-Ranges: bytes
```

### Ingress

![Ingress Topo](/assets/kubernetes/ingress.png)

### Ingress Controller

```sh
$ kubectl get po -n kube-system 
NAME                                       READY   STATUS    RESTARTS   AGE
coredns-86c58d9df4-cnx48                   1/1     Running   11         13d
coredns-86c58d9df4-x46nn                   1/1     Running   15         13d
default-http-backend-676d78555d-54jvx      1/1     Running   23         6d1h
etcd-far-seer-01                           1/1     Running   9          13d
kube-apiserver-far-seer-01                 1/1     Running   1          3d1h
kube-controller-manager-far-seer-01        1/1     Running   71         13d
kube-flannel-ds-amd64-vrt27                1/1     Running   11         13d
kube-proxy-b4lqx                           1/1     Running   9          13d
kube-scheduler-far-seer-01                 1/1     Running   69         13d
kubernetes-dashboard-7bbbdc6696-rrzk4      1/1     Running   0          6h4m
nginx-ingress-controller-779d9d54f-k795k   1/1     Running   83         6d1h
```

### Ingress Controller

```sh
# kubectl -n kube-system get po nginx-ingress-controller-779d9d54f-k795k -oyaml 
spec:
  containers:
  - args:
    - /nginx-ingress-controller
    - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
    - --configmap=$(POD_NAMESPACE)/nginx-load-balancer-conf
    - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
    - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
    - --annotations-prefix=nginx.ingress.kubernetes.io
    - --report-node-internal-ip-address
    name: nginx-ingress-controller
    ports:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
```

### Ingress TLS & Rules (00)

```sh
$ openssl req -x509 -nodes -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=*.bar.com"
Generating a RSA private key
...........................................................................................................................+++++
........................................................................+++++
writing new private key to 'tls.key'
-----
$ kubectl create secret tls tls-crt --cert=tls.crt --key=tls.key
secret/tls-crt created
$ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-5gh7g   kubernetes.io/service-account-token   3      13d
tls-crt               kubernetes.io/tls                     2      31s
```

### Ingress TLS & Rules (01)

```sh
# foo-bar-ing.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: foo-bar
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
    - hosts:
        - '*.bar.com'
      secretName: tls-crt
  rules:
    - host: 'foo.bar.com'
      http:
        paths:
          - path: /
            backend:
              serviceName: foo-bar
              servicePort: 80
```

### Ingress TLS & Rules (10)

```sh
$ kubectl create -f ingress.yaml 
ingress.extensions/foo-bar created
$ kubectl get ing
NAME      HOSTS         ADDRESS          PORTS     AGE
foo-bar   foo.bar.com   192.168.66.128   80, 443   101s
$ curl -iILk http://foo.bar.com
HTTP/1.1 308 Permanent Redirect
Location: https://foo.bar.com/

HTTP/2 200 
server: nginx/1.15.8
```

### References

- https://kubernetes.io/docs/concepts/services-networking/service/
- https://kubernetes.io/docs/concepts/services-networking/service/#discovering-services
- https://kubernetes.io/docs/concepts/services-networking/service/#headless-services
- https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
- https://kubernetes.io/docs/concepts/services-networking/ingress/
- https://kubernetes.io/docs/concepts/services-networking/ingress/#name-based-virtual-hosting
- https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
- https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#custom-timeouts

### Quit or not quit ?

[https://kubernetes.io/](https://kubernetes.io/)
