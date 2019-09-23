---
layout: post
title: Get Started with AWS
date: 2019-09-18 15:55:54 +0800
categories: ['aws']
tags: ['aws']
---

### VPC (Virtual Private Cloud)

1. [What Is Amazon VPC?](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/what-is-amazon-vpc.html)
2. [Getting Started with IPv4 for Amazon VPC](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/getting-started-ipv4.html)

3. [Scenario 2: VPC with Public and Private Subnets (NAT)](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/VPC_Scenario2.html)

4. [Recommended Network ACL Rules for Your VPC](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/vpc-recommended-nacl-rules.html#nacl-rules-scenario-2)

5. [Security Groups for Your VPC](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/VPC_SecurityGroups.html)

6. [Network ACLs](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/vpc-network-acls.html)

- VPCs
  - Subnets
    - public subnet
    - private subnet
  - Accessing the Internet
    - private IP & public IP & EIP & route table
    - IGW (Internet Gateway)
    - NAT (network address translation)
  - Security
    - Security Groups & EC2 Instances
      - **If you specify a single IPv4 address, specify the address using the /32 prefix length. If you specify a single IPv6 address, specify it using the /128 prefix length. **
      - **Some systems for setting up firewalls let you filter on source ports. Security groups let you filter only on destination ports.**
    - Network ACLs & Subnets

### ELB (Elastic Load Balancing)

1. [How Elastic Load Balancing Works](https://docs.amazonaws.cn/en_us/elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html)
  - **With Application Load Balancers, cross-zone load balancing is always enabled.**
  - **With Network Load Balancers, cross-zone load balancing is disabled by default. After you create a Network Load Balancer, you can enable or disable cross-zone load balancing at any time. **

- ELBs
  - NLB (Network Load Balancer)
    - **https://www.awsfeed.com/2019/08/09/using-a-network-load-balancer-with-the-nginx-ingress-controller-on-eks/**

### EC2 (Elastic Compute Cloud)

- Install Docker

  ```
  $ sudo amazon-linux-extras install docker -y
  ```
  
  ```
  $ cat /etc/docker/daemon.json 
  {
    "data-root": "/data/docker",
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2"
  }
  ```
  
  ```
  $ sudo systemctl enable docker.service
  ```
  
  ```
  $ sudo systemctl start docker.service
  ```
  
  ```
  $ sudo docker info
  ```

  ```
  $ sudo yum install amazon-ecr-credential-helper -y
  ```

  ```
  $ sudo cat /root/.docker/config.json
  {
    "credHelpers": {
      "[aws_account_id].dkr.ecr.[region].amazonaws.com.cn": "ecr-login"
    }
  }
  ```

### Install Kubernetes

- Set bash completion

  ```
  $ sudo sh -c "kubeadm completion bash > /etc/profile.d/kubeadm.sh"
  $ source /etc/profile.d/kubeadm.sh
  ```
  
  ```
  $ sudo sh -c "kubectl completion bash > /etc/profile.d/kubectl.sh"
  $ source /etc/profile.d/kubectl.sh
  ```

- Set kubelet root-dir

  The file that can contain user-specified flag overrides with `KUBELET_EXTRA_ARGS` is sourced from /etc/default/kubelet (for DEBs), or /etc/sysconfig/kubelet (for RPMs). `KUBELET_EXTRA_ARGS` is last in the flag chain and has the highest priority in the event of conflicting settings
  
  ```
  #KUBELET_EXTRA_ARGS=--root-dir=/opt/lib/kubelet
  ```

- Enable kubelet service

  ```
  $ sudo systemctl enable kubelet.service
  ```

- kube init

  ```
  $ sudo kubeadm init --pod-network-cidr=[10.244.0.0/16] --image-repository=[aws_account_id].dkr.ecr.[region].amazonaws.com.cn/k8s --kubernetes-version=[v1.15.0] [--ignore-preflight-errors=NumCPU]
  ```

- Check required ports

  https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports

- Nginx Ingress Controller & ALB & NLB

  ```
  [23/Sep/2019:09:03:56 +0000] remote_addr=10.244.0.4 https= host=alb-449876832.cn-north-1.elb.amazonaws.com.cn request="GET /remote_addr?lb=alb HTTP/1.1" content_length=- request_id=11995321529ae2f4ba05f626d1b2bdce request_time=0.000 referer=- user_agent="curl/7.64.0" x_forwarded_for="10.0.2.71" status=404 bytes_sent=190 body_bytes_sent=21 upstream_addr=- upstream_status=- upstream_response_time=- upstream_connect_time=- upstream_header_time=-
  [23/Sep/2019:09:05:06 +0000] remote_addr=10.244.0.4 https= host=nlb-49353abebcd88735.elb.cn-north-1.amazonaws.com.cn request="GET /remote_addr?lb=nlb HTTP/1.1" content_length=- request_id=6c3ea368830abef17296502d98e797f8 request_time=0.000 referer=- user_agent="curl/7.64.0" x_forwarded_for="140.206.187.194" status=404 bytes_sent=190 body_bytes_sent=21 upstream_addr=- upstream_status=- upstream_response_time=- upstream_connect_time=- upstream_header_time=-
  ```
