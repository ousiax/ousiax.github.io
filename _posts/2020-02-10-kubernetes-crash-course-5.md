---
layout: post
title: 5 - Kubernetes StatefulSet
date: 2020-02-10 10:46:33 +0800
categories: ['kubernetes']
tags: ['kubernetes']
---

- TOC 
{:toc}

- - -

### StatefulSet

- StatefulSet is the workload API object used to manage stateful applications.
- Like a Deployment , a StatefulSet manages Pods that are based on an identical container spec.
- Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: **each has a persistent identifier that it maintains across any rescheduling**.
- A StatefulSet operates under the same pattern as any other Controller. You define your desired state in a StatefulSet object, and the StatefulSet controller makes any necessary updates to get there from the current state.
- StatefulSets are valuable for applications that require one or more of the following.
    - Stable, **unique network identifiers**.
    - Stable, **persistent storage**.
    - Ordered, graceful deployment and scaling.
    - Ordered, automated rolling updates.

### Limitations

- The storage for a given Pod must either be provisioned by a PersistentVolume Provisioner based on the requested storage class, or pre-provisioned by an admin.
- **Deleting and/or scaling a StatefulSet down will not delete the volumes associated with the StatefulSet**. This is done to ensure data safety, which is generally more valuable than an automatic purge of all related StatefulSet resources.
- StatefulSets currently **require a Headless Service** to be responsible for the network identity of the Pods. You are responsible for creating this Service.
- StatefulSets do not provide any guarantees on the termination of pods when a StatefulSet is deleted. To achieve ordered and graceful termination of the pods in the StatefulSet, it is possible to scale the StatefulSet down to 0 prior to deletion.

### Pod Identity

- StatefulSet Pods have a unique identity that is comprised of an **ordinal**, a **stable network identity**, and **stable storage**. The identity sticks to the Pod, regardless of which node it’s (re)scheduled on.
- For a StatefulSet with N replicas, each Pod in the StatefulSet will be assigned an integer ordinal, **from 0 up through N-1**, that is unique over the Set.
- Each Pod in a StatefulSet derives its hostname from the name of the StatefulSet and the ordinal of the Pod. The pattern for the constructed hostname is **$(statefulset name)-$(ordinal)**.
- A StatefulSet can use a Headless Service to control the domain of its Pods. The domain managed by this Service takes the form: **$(service name).$(namespace).svc.cluster.local**, where "cluster.local" is the cluster domain. As each Pod is created, it gets a matching DNS subdomain, taking the form: **$(podname).$(governing service domain)**, where the governing service is defined by the serviceName field on the StatefulSet.

### pvs/mongodb-data-0-pv.yaml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-data-0
spec:
  storageClassName: local
  capacity:
    storage: 64Mi
  accessModes:
    - ReadWriteOnce
  local:
    path: /tmp/data/db/0
 nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: node.kubernetes.io/mongodb-data-0-ready
            operator: In
            values:
              - "true"
```

### pvs/mongodb-data-1-pv.yaml

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-data-1
spec:
  storageClassName: local
  capacity:
    storage: 64Mi
  accessModes:
    - ReadWriteOnce
  local:
    path: /tmp/data/db/1
 nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: node.kubernetes.io/mongodb-data-1-ready
            operator: In
            values:
              - "true"
```

### pvs/mongodb-data-2-pv.yaml

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-data-2
spec:
  storageClassName: local
  capacity:
    storage: 64Mi
  accessModes:
    - ReadWriteOnce
  local:
    path: /tmp/data/db/2
 nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: node.kubernetes.io/mongodb-data-2-ready
            operator: In
            values:
              - "true"
```

### mongodb-svc.yaml

```yml
apiVersion: v1
kind: Service
metadata:
  name: mongodb
spec:
  clusterIP: None
  selector:
    app: mongodb
  ports:
    - port: 27017
```

### mongodb-sts.yaml (1)

```yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  replicas: 3
  serviceName: mongodb
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        storageClassName: local
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 16Mi
 template:
    metadata:
      labels:
        app: mongodb
    spec:
      volumes:
        - name: etc-mongod-keyfile
          secret:
            defaultMode: 0400
            secretName: mongod-keyfile
      containers:
        - name: mongo
          image: mongo:3.6
          command: ["mongod", "--bind_ip_all", "--auth", "--replSet", "rs0", "--keyFile", "/etc/mongod.keyfile"]
          volumeMounts:
            - mountPath: /data/db
              name: data
            - mountPath: /etc/mongod.keyfile
              name: etc-mongod-keyfile
              subPath: mongod.keyfile
```

### mongod-keyfile-secret.yaml

```yml
apiVersion: v1
kind: Secret
metadata:
  name: mongod-keyfile
type: Opaque
data:
  mongod.keyfile: QkpTUGEveElKNU9UTXRXcGZiSjl0M253SDMzZHJCSG9idEczYmtvN3RmMCtkVENKR1o4R0pRNS9oekFQdksxYgpLMHNqZExKNi9ZY3l1TFI4NDlsUEl6aUtIVFpiZWI4a0ZYR1Fnb0s3QkE4VlBqaHFySnhTVUxHb1YyQkNvZElsCmtqeE5nc29JOW1PTmxsMmh2WTJxYWlrOFMzVnBOc1orNlVjV0lXYk90ekE0ZFJXb3ZISTZZS0xrU3RTMlRoakwKM3lMQUlPM1ZUVlJ5bEptcFVwNFJiMzd5QUVPYlR6VHg2dStURjg2L1p3OEFGM2NGZ1JLdHgxQ0pKMTlOVjZ2NAowZ051ZEhUSXNkZXJSNWViSkhKMTZsY2I2ZGdPOUxxaWlBaXBxQmNPdzB2TXlsalVtZHpQRVN2VXhzbmtaRy9KCmRNbkJGYitOV2owelQ0aGpyLzJCTUZwTTYvcjlMYnpocnVGem5XOTBXb0JEZGRFdnNvVWwrU1lLMWJiUE1yTVIKekovc0pTa2t3eDZ2NUlZc2NmdnFrRllqSS9TaFNHQ0FWMXlXcS9pZ3ptSGg3b2ZLUXVHSHBoWVNVNzlwVTNqagpBRVN4VHhaMDJSTmZNOExRdU42eGl5dWRLbWF0TDBuWlp6VlAySnFSeTNiRGtpTVFhcmJLbzVRZ2JsNk0xSmlwClhVSElPUWFSQytlRU1weGxycWM5cGtaYVVqZEZEUmlEWDBUcHZISWNVaWNuVGxOeTFRMVpHYmczY09SVmo0R2sKZGZmRXdjRHNubWwyZS9oUFJpejZxQTJURGpBb3B6di9MakhZUWZ1U0JVREVwTkpIMytPQUlKcWJFeWpHWFdlQgp5L0dVL0w5OHpPN21mYWlrbG52SW5jR0M2czVtalVNS1JWVW8yaytMdXU2VVV3NkRYa1hjVXhvYzVkemQzNy94CitiNDZJN1YzUXJ5cnI0UWtDb3ZnbHBHVmtBa3lKamVZQnVUckY2MnV4bDlCaTM2MkwrMWdnWjVJZE1IYTErV0wKWGZOZXR6c1FqanFlWlNzdWxsaHRJaWFDMjZ5azQ5NXFHMks0T1N5bDBhbjZQQkdldmtpOE5xTm11UlY3N2M5YwpQM2wvdElJNUlhMllHdFFyNGZHU3BuQ1U5bHIxelRmUzYrZUFPNGxjNk85SXljQnEwU1VNd3IvUDhCTFVOYk96CndrR09NQTB1Vy8zMVR3RllNUE9vY0R6WHF5ejE2NTFUc0dHY0xEWnR5bUx1eEdqTitDbGNMVlN2K0lrMVBRa3gKV2FML2pCVzJCL2g4OXNaY21Zak9PTVQrUVdvTWo2WEtXSWsvNUpEOERpa28rNzA3Cg==
```

### network-utils-pod.yaml

```yml
apiVersion: v1
kind: Pod
metadata:
  name: network-utils
spec:
  containers:
    - name: network-utils
      image: amouat/network-utils
      command: ['sleep', '10h']
```

### rs-init.js

```js
// 1. init replication set
rs.initiate( {
  _id : "rs0",
  members: [ { _id : 0, host : "mongodb-0.mongodb" } ]
});
// 2. create cluster admin
use admin;
db.createUser({
  user:"admin",
  pwd:"admin",
  roles: [
      {role: "userAdmin", db:"admin"},
      {role: "clusterAdmin", db: "admin"}
  ]
});

// 3. login with cluster admin user
db.auth("admin", "admin");
// 3. add slave nodes
rs.add("mongodb-1.mongodb");
rs.add("mongodb-2.mongodb");
db.runCommand('isMaster');

// 4. create database user
db.createUser({
    user: "test",
    pwd: "test",
    roles: [
        { role: "readWriteAnyDatabase", db: "admin" }
    ]
});
```

### Let’s do IT (0)

```shell
$ sudo mkdir /tmp/data/db/{0,1,2} -p
$ kubectl label no [NODE-0-NAME] node.kubernetes.io/mongodb-data-0-ready=true
node/NODE-0-NAME labeled
$ kubectl label no [NODE-1-NAME] node.kubernetes.io/mongodb-data-1-ready=true
node/NODE-1-NAME labeled
$ kubectl label no [NODE-2-NAME] node.kubernetes.io/mongodb-data-2-ready=true
node/NODE-2-NAME labeled
$ kubectl create -f pvs/
persistentvolume/mongodb-data-0 created
persistentvolume/mongodb-data-1 created
persistentvolume/mongodb-data-2 created
```

### Let’s do IT (1)

```shell
$ kubectl create -f mongodb-svc.yaml 
service/mongodb created
$ kubectl create -f mongod-keyfile-secret.yaml 
secret/mongod-keyfile created
$ kubectl create -f mongodb-sts.yaml 
statefulset.apps/mongodb created
```

```shell
$ kubectl get po -w
NAME        READY   STATUS    RESTARTS   AGE
mongodb-0   1/1     Running   0          4s
mongodb-1   0/1     Pending   0          0s
mongodb-1   0/1     Pending   0          1s
mongodb-1   0/1     ContainerCreating   0          1s
mongodb-1   1/1     Running             0          3s
mongodb-2   0/1     Pending             0          0s
mongodb-2   0/1     Pending             0          1s
mongodb-2   0/1     ContainerCreating   0          1s
mongodb-2   1/1     Running             0          3s
```

### Let’s do IT (2)

```sh
$ kubectl get pv,pvc
NAME                              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
persistentvolume/mongodb-data-0   64Mi       RWO            Retain           Bound    default/data-mongodb-0   local                   70s
persistentvolume/mongodb-data-1   64Mi       RWO            Retain           Bound    default/data-mongodb-1   local                   70s
persistentvolume/mongodb-data-2   64Mi       RWO            Retain           Bound    default/data-mongodb-2   local                   70s

NAME                                   STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-mongodb-0   Bound    mongodb-data-0   64Mi       RWO            local          43s
persistentvolumeclaim/data-mongodb-1   Bound    mongodb-data-1   64Mi       RWO            local          40s
persistentvolumeclaim/data-mongodb-2   Bound    mongodb-data-2   64Mi       RWO            local          36s
```

### Let’s do IT (3)

```sh
$ kubectl create -f network-utils-pod.yaml 
pod/network-utils created
$ kubectl exec -it network-utils bash
root@network-utils:/# nslookup mongodb-0.mongodbclear
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   mongodb-0.mongodb.default.svc.cluster.local
Address: 10.244.0.136
root@network-utils:/# nslookup mongodb          
Server:     10.96.0.10
Address:    10.96.0.10#53

Name:   mongodb.default.svc.cluster.local
Address: 10.244.0.138
Name:   mongodb.default.svc.cluster.local
Address: 10.244.0.137
Name:   mongodb.default.svc.cluster.local
Address: 10.244.0.136
```

### Let’s do IT (4)

```sh
$ kubectl describe po mongodb-0
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  data-mongodb-0
    ReadOnly:   false
  etc-mongod-keyfile:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  mongod-keyfile
    Optional:    false
```

### Let’s do IT (5)

```sh
$ kubectl delete -f mongodb-sts.yaml 
statefulset.apps "mongodb" deleted
$ kubectl get po
NAME            READY   STATUS    RESTARTS   AGE
network-utils   1/1     Running   0          7m4s
$ kubectl get pv,pvc
NAME                              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE
persistentvolume/mongodb-data-0   64Mi       RWO            Retain           Bound    default/data-mongodb-0   local                   11m
persistentvolume/mongodb-data-1   64Mi       RWO            Retain           Bound    default/data-mongodb-1   local                   11m
persistentvolume/mongodb-data-2   64Mi       RWO            Retain           Bound    default/data-mongodb-2   local                   11m

NAME                                   STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/data-mongodb-0   Bound    mongodb-data-0   64Mi       RWO            local          11m
persistentvolumeclaim/data-mongodb-1   Bound    mongodb-data-1   64Mi       RWO            local          11m
persistentvolumeclaim/data-mongodb-2   Bound    mongodb-data-2   64Mi       RWO            local          11m
```

### Let’s do IT (6)

```sh
$ kubectl create -f mongodb-sts.yaml 
statefulset.apps/mongodb created
$ kubectl exec -it mongodb-0 bash
root@mongodb-0:/# mongo --quiet
> rs.initiate( {
...   _id : "rs0",
...   members: [ { _id : 0, host : "mongodb-0.mongodb" } ]
... });
{ "ok" : 1 }
```

### Quit or not quit ?

[https://kubernetes.io/](https://kubernetes.io/)
