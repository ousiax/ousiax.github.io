---
layout: post
title: "Network Interface On CentOS"
date: 2016-05-12 15-11-10 +0800
categories: ['Linux', ]
tags: ['Linux', 'CentOS', 'Network']
disqus_identifier: 232439217093332920585807267185644346866
---
Under Red Hat Enterprise Linux, all network communications occur between configured software *interfaces* and *physical networking devices* connected to the system.

The configuration files for network interfaces are located in the `/etc/sysconfig/network-scripts/` directory. The scripts used to active and deactive these network interfaces are also located here. Although the number and type of interface files can differ from system to system, there are three categories of files that exist in this directory:

1. *Interface configuration files*

2. *Interface control scripts*

3. *Network function files*

The files in each of these categories work together to enable various network devices. 

## 1. Network Configuration Files

The primary network configuration files are as follows:

* `/etc/hosts`

    The main purpose of this file is to resolve hostnames that cannot be resolved any other way. It can also be used to resolve hostnames on small networks with no DNS server. Regardless of the type of network the computer is on, this file should contain a line specifying the IP address of the loopback device (127.0.0.1) as localhost.localdomain. For more information, refer to the hosts man page.

* `/etc/resolv.conf`

    This file specifies the IP addresses of DNS servers and the search domain. Unless configured to do otherwise, the network initialization scripts populate this file. For more information about this file, refer to the resolv.conf man page.

* `/etc/sysconfig/network`

    This file specifies routing and host information for all network interfaces.

`/etc/sysconfig/network-scripts/ifcfg-<interface-name>`

    For each network interface, there is a corresponding interface configuration script. Each of these files provide information specific to a particular network interface.

## 2. Interface Configuration Files

Interface configuration files control the software interfaces for individual network devices. As the system boots, it uses these files to determine what interfaces to bring up and how to configure them. These files are usually named **ifcft-&lt;name&gt;**, where **&lt;name&gt;** refers to the name of the devices that the configuration file controls.

### 2.1 Ethernet Interfaces

* * *
## References

* [Network Interfaces](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/ch-networkscripts.html)
