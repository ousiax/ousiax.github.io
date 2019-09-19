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
