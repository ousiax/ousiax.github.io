---
layout: post
title: Kubernetes Recovery from Master Failure
date: 2019-05-22 11:21:04 +0800
categories: ['kubernetes']
tags: ['kubernetes']
---

#### # Backup Kubernetes PKI

```sh
#!/bin/sh

KUBE_CERT_DIR="/etc/kubernetes/pki"
BACKUP_CERT_DIR="/backup"

if [ ! -d $BACKUP_CERT_DIR ]
then
    mkdir -p $BACKUP_CERT_DIR 
fi

cp -a $KUBE_CERT_DIR $BACKUP_CERT_DIR
```

#### # Backup Kubernetes Etcd database with a CronJob object

***The CronJob must be scheduled to Kubernetes Master node.***

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: etcd-snapshot
  namespace: kube-system
spec:
  schedule: "59 23 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              # Same image as in /etc/kubernetes/manifests/etcd.yaml
              image: k8s.gcr.io/etcd:3.3.10
              env:
                - name: ETCDCTL_API
                  value: "3"
              command: ["/bin/sh"]
              args: ["-c", "etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /backup/etcd/snapshot-$(date +%Y-%m-%d_%H-%M-%S_%Z).db"]
              volumeMounts:
                - mountPath: /etc/kubernetes/pki/etcd
                  name: etcd-certs
                  readOnly: true
                - mountPath: /backup/etcd
                  name: backup
          hostNetwork: true
          restartPolicy: OnFailure
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                  - matchExpressions:
                    - key: node-role.kubernetes.io/master
                      operator: Exists
          tolerations:
            - effect: NoSchedule
              operator: Exists
          volumes:
            - name: etcd-certs
              hostPath:
                path: /etc/kubernetes/pki/etcd
                type: Directory
            - name: backup
              hostPath:
                path: /backup/etcd
                type: DirectoryOrCreate
```

#### # Recovery from Master Failure with Kubeadm

```sh
#/bin/sh

#####################################
# Recovery from Master Failure      #
#####################################

if kubectl cluster-info > /dev/null 2>&1; then
    kubectl cluster-info
    exit 0
fi

# Restore Kubernetes certificates
KUBE_CERT_DIR="/etc/kubernetes"
BACKUP_CERT_DIR="/backup/pki"
mkdir -p $KUBE_CERT_DIR 
cp -a $BACKUP_CERT_DIR $KUBE_CERT_DIR

# Restore etcd data
ETCD_IMAGE="k8s.gcr.io/etcd:3.3.10"
# ETCD_SNAPSHOT="snapshot-2019-05-21_06-48-06_UTC.db"
ETCD_SNAPSHOT="snapshot-2019-05-21_09-05-11_UTC.db"
mkdir -p /var/lib/etcd
docker run --rm \
    -v '/backup:/backup' \
    -v '/var/lib/etcd:/var/lib/etcd' \
    --env ETCDCTL_API=3 \
    "$ETCD_IMAGE" \
    /bin/sh -c "etcdctl snapshot restore '/backup/etcd/$ETCD_SNAPSHOT' ; mv /default.etcd/member/ /var/lib/etcd/"

# Init Kubernetes with Kubeadm
kubeadm init \
    --ignore-preflight-errors=DirAvailable--var-lib-etcd
```
