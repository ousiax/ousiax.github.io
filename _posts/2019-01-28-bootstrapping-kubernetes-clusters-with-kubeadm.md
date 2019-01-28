---
layout: post
title: Bootstrapping Kubernetes Clusters with kubeadm
date: 2019-01-28 11:11:46 +0800
categories: ['Kubernetes'] 
tags: ['Kubernetes', 'kubeadm'] 
---

- TOC
{:toc}

- - -

### Install CRI (Docker)

#### Debian

```sh
# Install Docker CE on Debian 9+
# Install packages to allow apt to use a repository over HTTPS
apt-get update \
    && apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# Add docker apt repository.
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable"

## Install docker ce.
apt-get update && apt-get install docker-ce=18.06.0~ce~3-0~debian

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```

#### Centos/RHEL

```sh
# Install Docker CE on CentOS/RHEL 7.4+
## Set up the repository
### Install required packages.
yum install yum-utils device-mapper-persistent-data lvm2

### Add docker repository.
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

## Install docker ce.
yum update && yum install docker-ce-18.06.1.ce

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
```

### Installing kubeadm, kubelet, kubectl and kubernetes-cni

#### Ubuntu/Debian

```sh
# Install kubeadm, kubelet, kubectl and kuberntes-cni on Ubuntu, Debian or HypriotOS
apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update && apt-get install -y kubelet kubeadm kubectl kubernetes-cni

apt-mark hold kubelet kubeadm kubectl kubernetes-cni

# The kubelet is now restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.
```

#### CentOS/RHEL

```sh
# Install kubeadm, kubelet, kubectl and kuberntes-cni on CentOS, RHEL or Fedora
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

# The kubelet is now restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.
```

Note:

- Setting SELinux in permissive mode by running `setenforce 0` and `sed ...` effectively disables it. This is required to allow containers to access the host filesystem, which is needed by pod networks for example. You have to do this until SELinux support is improved in the kubelet.

- Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure `net.bridge.bridge-nf-call-iptables` is set to `1` in your sysctl config, e.g.

    ```
    cat <<EOF >  /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sysctl --system
    ```

#### Install kubeadm, kubectl bash completion

```sh
# Install bash completion
kubeadm completion bash > /etc/bash_completion.d/kubeadm.sh
kubectl completion bash > /etc/bash_completion.d/kubectl.sh

# Load the completion code for bash into the current shell
source /etc/bash_completion.d/kube{adm,ctl}.sh
```

### Creating a single master cluster with kubeadm

#### Initializing your master

For **flannel** to work correctly, you must pass `--pod-network-cidr=10.244.0.0/16` to `kubeadm init`.

The master is the machine where the control plane components run, including etcd (the cluster database) and the API server (which the kubectl CLI communicates with).

- Choose a pod network add-on, and verify whether it requires any arguments to be passed to kubeadm initialization. Depending on which third-party provider you choose, you might need to set the `--pod-network-cidr` to a provider-specific value. See [Installing a pod network add-on](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network).

- (Optional) Unless otherwise specified, kubeadm uses the network interface associated with the default gateway to advertise the master’s IP. To use a different network interface, specify the `--apiserver-advertise-address=<ip-address>` argument to `kubeadm init`. To deploy an IPv6 Kubernetes cluster using IPv6 addressing, you must specify an IPv6 address, for example `--apiserver-advertise-address=fd00::101`

- (Optional) Choose a specific Kubernetes version for the control plane with `--kubernetes-version`. (default "stable-1")

- (Optional) Run `kubeadm config images pull` prior to `kubeadm init` to verify connectivity to gcr.io registries.

- Run `swapoff -a` and edit `/etc/fstab` to commant all swap fs to disable swap.

Now run:

```sh
kubeadm init <args> 
```

`kubeadm init` first runs a series of prechecks to ensure that the machine is ready to run Kubernetes. These prechecks expose warnings and exit on errors. `kubeadm init` then downloads and installs the cluster control plane components. This may take several minutes. The output should look like:

```
[init] Using Kubernetes version: vX.Y.Z
[preflight] Running pre-flight checks

... (log output of join workflow) ...

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
```

Make a record of the `kubeadm join` command that `kubeadm init` outputs. You need this command to join nodes to your cluster.

The token is used for mutual authentication between the master and the joining nodes. The token included here is secret. Keep it safe, because anyone with this token can add authenticated nodes to your cluster. These tokens can be listed, created, and deleted with the `kubeadm token` command. See the [kubeadm reference guide](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/).

If the token is expired or you lost the record of the `kubeadm join` command that `kubeadm init` outputs, you can also use the `kubeadm token create --print-join-command` to create a new bootstrap token.

#### Installing a pod network add-on (Flannel)

For flannel to work correctly, you must pass `--pod-network-cidr=10.244.0.0/16` to `kubeadm init`.

Set `/proc/sys/net/bridge/bridge-nf-call-iptables` to `1` by running `sysctl net.bridge.bridge-nf-call-iptables=1` to pass bridged IPv4 traffic to iptables’ chains. This is a requirement for some CNI plugins to work, for more information please see [here](https://kubernetes.io/docs/concepts/cluster-administration/network-plugins/#network-plugin-requirements).

You can also run the following command to set the kernel paramets.

```
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

Note that flannel works on amd64, arm, arm64 and ppc64le.

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
```

#### Control plane node isolation

By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development, run:

```sh
kubectl taint nodes --all node-role.kubernetes.io/master-
```

This will remove the **node-role.kubernetes.io/master** taint from any nodes that have it, including the master node, meaning that the scheduler will then be able to schedule pods everywhere.

#### Joining your nodes

The nodes are where your workloads (containers and pods, etc) run. To add new nodes to your cluster do the following for each machine:

- SSH to the machine
- Become root (e.g. `sudo su -`)
- Run the command that was output by `kubeadm init`. For example:

```sh
kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
```

If you do not have the token, you can get it by running the following command on the master node:

```sh
kubeadm token list
```

The output is similar to this:

```none
TOKEN                     TTL       EXPIRES                     USAGES                   DESCRIPTION                                                EXTRA GROUPS
6b0kj6.goxmubaepv3hvcd5   23h       2019-01-29T15:01:49+08:00   authentication,signing   The default bootstrap token generated by 'kubeadm init'.   system:bootstrappers:kubeadm:default-node-token
```

By default, tokens expire after 24 hours. If you are joining a node to the cluster after the current token has expired, you can create a new token by running the following command on the master node:

```sh
kubeadm token create
```

The output is similar to this:

```none
5didvk.d09sbcov8ph2amjw
```

If you don’t have the value of `--discovery-token-ca-cert-hash`, you can get it by running the following command chain on the master node:

```sh
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

The output is similar to this:

```none
8cb2de97839780a412b93877f8507ad6c94f73add17d5d7058e91741c9d5ec78
```

The output should look something like:

```none
[preflight] Running pre-flight checks

... (log output of join workflow) ...

Node join complete:
* Certificate signing request sent to master and response
  received.
* Kubelet informed of new secure connection details.

Run 'kubectl get nodes' on the master to see this machine join.

A few seconds later, you should notice this node in the output from kubectl get nodes when run on the master.
```

### Tear down

To undo what kubeadm did, you should first drain the node and make sure that the node is empty before shutting it down.

Talking to the master with the appropriate credentials, run:

```sh
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>
```

Then, on the node being removed, reset all kubeadm installed state:

```sh
kubeadm reset
```

The reset process does not reset or clean up iptables rules or IPVS tables. If you wish to reset iptables, you must do so manually:

```sh
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

If you want to reset the IPVS tables, you must run the following command:

```sh
ipvsadm -C
```

If you wish to start over simply run `kubeadm init` or `kubeadm join` with the appropriate arguments.

### Set HTTP proxy for APT/YUM

Set HTTP proxy for APT:

```sh
cat <<EOF > /etc/apt/apt.conf.d/httproxy 
> Acquire::http::Proxy "http://PROXY_HOST:PORT";
> EOF
```

Set HTTP proxy for YUM:

```sh
echo 'proxy=http://PROXY_HOST:PORT' >> /etc/yum.conf
```

### References

1. Installing kubeadm - Kubernetes, [https://kubernetes.io/docs/setup/independent/install-kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm)
1. CRI installation - Kubernetes, [https://kubernetes.io/docs/setup/cri/](https://kubernetes.io/docs/setup/cri/)
1. Creating a single master cluster with kubeadm - Kubernetes, [https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
