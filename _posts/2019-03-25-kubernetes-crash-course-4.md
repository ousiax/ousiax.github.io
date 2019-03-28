---
layout: post
title: 4 - Kubernetes Storage
date: 2019-03-25 17:55:05 +0800
categories: ['Kubernetes']
tags: ['Kubernetes']
---

- TOC
{:toc}

- - -

### Contents

- Docker & container & storage
    - images & layers
    - container & layers
    - volumes & bind mounts & tmpfs mounts (linux only)
- Pod & Volumes
    - Kubernetes Volumes
    - PVs and PVCs
    - Storage Classes
    - A Scratch Example of MongoDB

### Docker & container & storage

#### Images and layers

```dockerfile
# Dockerfile
FROM ubuntu:15.04
COPY . /app
RUN make /app
CMD python /app/app.py
```

![Image layers based on ubuntu:15.04](https://docs.docker.com/storage/storagedriver/images/container-layers.jpg)

#### Container and layers

- **UnionFS**
- **Stackable image layers**
- **Copy-on-write (CoW) strategy**

```sh
docker build
docker history
docker ps -s
```

![Container layers](https://docs.docker.com/storage/storagedriver/images/sharing-layers.jpg)


#### volumes & bind mounts & tmpfs mounts

![volumes & bind mounts & tmpfs mounts](https://docs.docker.com/storage/images/types-of-mounts.png)


### Pod & Volumes

#### Kubernetes Volumes

- A volume has an explicit lifetime - the same as the Pod that encloses it.
- A volume outlives any Containers that run within the Pod, and data is preserved across Container restarts.
- When a Pod ceases to exist, the volume will cease to exist, too.
- A volume is just a directory, possibly with some data in it, which is accessible to the Containers in a Pod. How that directory comes to be, the medium that backs it, and the contents of it are determined by the particular volume type used.
- To use a volume, a Pod specifies what volumes to provide for the Pod (the **.spec.volumes** field) and where to mount those into Containers (the **.spec.containers.volumeMounts** field).

#### Pod & Volumes

![Pod and volumes](https://d33wubrfki0l68.cloudfront.net/fe03f68d8ede9815184852ca2a4fd30325e5d15a/98064/docs/tutorials/kubernetes-basics/public/images/module_03_pods.svg)

##### Types of Volumes

- configMap
- secret
- emptyDir
- hostPath
- persistentVolumeClaim

##### EmptyDir

```yaml
spec:
  volumes:
    - name: nginx-html
      emptyDir: {} 
  containers:
    - name: network-utils
      image: amouat/network-utils
      command: ['sleep', '10h']
      volumeMounts:
        - name: nginx-html 
          mountPath: /tmp/html
    - name: nginx
      image: nginx:1.15
      volumeMounts:
        - name: nginx-html 
          mountPath: /usr/share/nginx/html
```

```sh
$ kubectl exec -it [POD_NAME] -c network-utils sh
# curl -iI localhost
HTTP/1.1 403 Forbidden
Server: nginx/1.15.8

# cd /tmp/html
# echo 'Hi Kubernetes!' > index.html
# curl -i localhost
HTTP/1.1 200 OK
Server: nginx/1.15.8

Hi Kubernetes!
```

##### HostPath

```yaml
spec:
  volumes:
    - name: nginx-html
      hostPath:
        path: /tmp/html
        type: DirectoryOrCreate
  containers:
    - name: nginx
      image: nginx:1.15
      volumeMounts:
        - name: nginx-html
          mountPath: /usr/share/nginx/html
```

```sh
$ kubectl port-forward [POD_NAME] 8080:80
$ curl -iI localhost:8080
HTTP/1.1 403 Forbidden
Server: nginx/1.15.8

$ cd /tmp/html/
$ sudo touch index.html
$ curl -iI localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.15.8
```

##### PVs and PVCs

- A **PersistentVolume** (PV) is a piece of storage in the cluster that has been provisioned by an administrator.
- PVs are volume plugins like Volumes, but have a lifecycle independent of any individual pod that uses the PV.
- A **PersistentVolumeClaim** (PVC) is a request for storage by a user and consumes PV resources.
- Claims can request specific size and access modes (e.g., can be mounted once read/write or many times read-only).
- PVs are resources in the cluster. PVCs are requests for those resources and also act as claim checks to the resource.
- There are two ways PVs may be provisioned: **static**ally or **dynamic**ally.
- A PVC to PV **binding** is a one-to-one mapping. Claims will remain unbound indefinitely if a matching volume does not exist. 
- When a user is done with their volume, they can delete the PVC objects from the API which allows reclamation of the resource. The **reclaim policy** for a PersistentVolume tells the cluster what to do with the volume after it has been released of its claim. Currently, volumes can either be **Retained**, Recycled or **Deleted**.
- **Pods use claims as volumes**. The cluster inspects the claim to find the bound volume and mounts that volume for a pod.

#### Storage Classes

- A StorageClass provides a way for administrators to describe the "classes" of storage they offer. Kubernetes itself is unopinionated about what classes represent. 
- Persistent Volumes that are dynamically created by a storage class will have the reclaim policy specified in the **reclaimPolicy** field of the class, which can be either Delete or Retain. If no reclaimPolicy is specified when a StorageClass object is created, it will default to Delete.
- Persistent Volumes that are created manually and managed via a storage class will have whatever reclaim policy they were assigned at creation.
- By default, the **Immediate** mode indicates that volume binding and dynamic provisioning occurs once the PersistentVolumeClaim is created. For storage backends that are topology-constrained and not globally accessible from all Nodes in the cluster, PersistentVolumes will be bound or provisioned without knowledge of the Pod’s scheduling requirements. This may result in unschedulable Pods.
- A cluster administrator can address this issue by specifying the **WaitForFirstConsumer** mode which will delay the binding and provisioning of a PersistentVolume until a Pod using the PersistentVolumeClaim is created. 

##### Local Storage Class

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  namespace: kube-system
  name: local
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

##### Azure File Storage Class

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile
provisioner: kubernetes.io/azure-file
parameters:
  skuName: Standard_LRS
  location: eastus
  storageAccount: azure_storage_account_name
```

#### A Scratch Example of MongoDB

##### mongo-data-db-pv.yaml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongo-data-db
  labels:
    app: mongo
spec:
  storageClassName: local
  capacity:
    storage: 64Mi
  accessModes:
    - ReadWriteOnce
  local:
    path: /tmp/data/db
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: node.kubernetes.io/mongodb
            operator: In
            values: ['data']
```

##### mongo-data-db-pvc.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-data-db
spec:
  storageClassName: local
  resources:
    requests:
      storage: 16Mi
  accessModes:
    - ReadWriteOnce
  selector:
    matchLabels:
      app: mongo
```

##### mongo-pod.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mongo
spec:
  volumes:
    - name: data-db
      persistentVolumeClaim:
        claimName: mongo-data-db
  containers:
    - name: mongo
      image: mongo:3.6
      volumeMounts:
        - name: data-db
          mountPath: /data/db
```

##### Create Pod

```sh
$ kubectl create -f mongo-pod.yaml 
pod/mongo created
$ kubectl get po
NAME    READY   STATUS    RESTARTS   AGE
mongo   0/1     Pending   0          3s
$ kubectl describe po mongo 

. . .

Events:
  Type     Reason            Age              From               Message
  ----     ------            ----             ----               -------
  Warning  FailedScheduling  9s (x2 over 9s)  default-scheduler  persistentvolumeclaim "mongo-data-db" not found
```

##### Create PVC (1)

```sh
$ kubectl create -f mongo-data-db-pvc.yaml 
persistentvolumeclaim/mongo-data-db created
$ kubectl get po
NAME    READY   STATUS    RESTARTS   AGE
mongo   0/1     Pending   0          2m42s
$ kubectl get pvc
NAME            STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mongo-data-db   Pending                                      local          7s
```

##### Create PVC (2)

```sh
$ kubectl describe po mongo 
Events:
  Type     Reason            Age                    From               Message
  ----     ------            ----                   ----               -------
  Warning  FailedScheduling  2m55s (x2 over 2m55s)  default-scheduler  persistentvolumeclaim "mongo-data-db" not found
  Warning  FailedScheduling  16s (x3 over 16s)      default-scheduler  0/1 nodes are available: 1 node(s) didn't find available persistent volumes to bind.
$ kubectl describe pvc mongo-data-db 
Events:
  Type       Reason                Age               From                         Message
  ----       ------                ----              ----                         -------
  Normal     WaitForFirstConsumer  4s (x5 over 37s)  persistentvolume-controller  waiting for first consumer to be created before binding
Mounted By:  mongo
```

##### Create PV (1)

```sh
$ kubectl create -f mongo-data-db-pv.yaml 
persistentvolume/mongo-data-db created
$ kubectl get pv,pvc
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
persistentvolume/mongo-data-db   64Mi       RWO            Retain           Available           local                   3s

NAME                                  STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/mongo-data-db   Pending                                      local          57s
```

##### Create PV (2)

```sh
$ kubectl label no [NODE_NAME] node.kubernetes.io/mongodb=data
node/far-seer-01 labeled
$ kubectl get pv,pvc
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
persistentvolume/mongo-data-db   64Mi       RWO            Retain           Bound    default/mongo-data-db   local                   34s

NAME                                  STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/mongo-data-db   Bound    mongo-data-db   64Mi       RWO            local          88s
```

##### Create PV (3)

```sh
$ kubectl get po
NAME    READY   STATUS              RESTARTS   AGE
mongo   0/1     ContainerCreating   0          6m34s
$ kubectl describe po mongo 
Events:
  Type     Reason            Age                    From                  Message
  ----     ------            ----                   ----                  -------
  Warning  FailedScheduling  5m48s (x6 over 6m42s)  default-scheduler     0/1 nodes are available: 1 node(s) didn't find available persistent volumes to bind.
  Normal   Scheduled         5m21s                  default-scheduler     Successfully assigned default/mongo to far-seer-01
  Warning  FailedMount       71s (x10 over 5m21s)   kubelet, far-seer-01  MountVolume.NewMounter initialization failed for volume "mongo-data-db" : path "/tmp/data/db" does not exist
```

##### Create PV (4)

```sh
$ mkdir /tmp/data/db –p
$ kubectl get po mongo -w
NAME    READY   STATUS              RESTARTS   AGE
mongo   0/1     ContainerCreating   0          9m37s
mongo   1/1   Running   0     9m37s
$ ls /tmp/data/db/
collection-0-8521021064489198322.wt  index-1-8521021064489198322.wt  journal          storage.bson      WiredTiger.turtle
collection-2-8521021064489198322.wt  index-3-8521021064489198322.wt  _mdb_catalog.wt  WiredTiger        WiredTiger.wt
collection-4-8521021064489198322.wt  index-5-8521021064489198322.wt  mongod.lock      WiredTigerLAS.wt
diagnostic.data                      index-6-8521021064489198322.wt  sizeStorer.wt    WiredTiger.lock
```

##### Use MongoDB

```sh
$ kubectl port-forward mongo 27017:27017
Forwarding from 127.0.0.1:27017 -> 27017
Forwarding from [::1]:27017 -> 27017
Handling connection for 27017
```

```sh
$ mongo --quiet
test@mongo:$ show databases;
admin   0.000GB
config  0.000GB
local   0.000GB
```

### References

- https://docs.docker.com/storage/storagedriver/
- https://docs.docker.com/storage/
- https://docs.docker.com/v17.09/engine/userguide/eng-image/dockerfile\_best-practices/#minimize-the-number-of-layers
- https://docs.docker.com/v17.09/engine/userguide/eng-image/dockerfile\_best-practices/#use-multi-stage-builds
- https://kubernetes.io/docs/concepts/storage/volumes/#configmap
- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
- https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
- https://kubernetes.io/docs/concepts/storage/volumes/#local
- https://kubernetes.io/docs/concepts/storage/persistent-volumes
- https://kubernetes.io/docs/concepts/storage/storage-classes/

### Quit or not quit ?

[https://kubernetes.io/](https://kubernetes.io/)
