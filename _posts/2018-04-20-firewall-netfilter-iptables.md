---
layout: post
title: Firewall, netfilter & iptables
date: 2018-04-20 19:35:48 +0800
categories: ['Linux']
tags: ['Linux', 'iptables']
disqus_identifier: 10561900883727734207137860490148236705
---

- TOC
{:toc}

- - -

*netfilter* is a set of hooks inside the Linux kernel that allows kernel modules to register callback functions with the network stack. A registered callback function is then called back for every packet that traverses the respective hook within the network stack.

*iptables* is a userspace command line utility for configuring Linux kernel **firewall** implemented within the [Netfilter](https://netfilter.org/projects/iptables/) project. The term *iptables* is also commonly used to refer to this kernel-level firewall. iptables is used for IPv4, and ip6tables is used for IPv6.

### Basic concepts

iptables is used to inspect, modify, redirect, and/or drop IPv4 packets. The code for filtering IPv4 packets is already built into the kernel and is organized into a collection of **tables**, each with a specific purpose. The tables are made up of a set of predefined **chains**, and the chains **rules** which are traversed in order. Each rule consists of a predicate of potential matches and a corresponding action (called a **target**) which is executed if the predicate is true; i.e. the conditions are matched. iptables is the user utility which allows you to work with these chains/rules.

The key to understanding how iptables works is [this chart](http://www.frozentux.net/iptables-tutorial/images/tables_traverse.jpg). The lowercase word on top is the table and the uppercase word below is the chain. Every IP packet that comes in *on any network interface* passes through this flow chart from top to bottom.

```
                               XXXXXXXXXXXXXXXXXX
                             XXX     Network    XXX
                               XXXXXXXXXXXXXXXXXX
                                       +
                                       |
                                       v
 +-------------+              +------------------+
 |table: filter| <---+        | table: nat       |
 |chain: INPUT |     |        | chain: PREROUTING|
 +-----+-------+     |        +--------+---------+
       |             |                 |
       v             |                 v
 [local process]     |           ****************          +--------------+
       |             +---------+ Routing decision +------> |table: filter |
       v                         ****************          |chain: FORWARD|
****************                                           +------+-------+
Routing decision                                                  |
****************                                                  |
       |                                                          |
       v                        ****************                  |
+-------------+       +------>  Routing decision  <---------------+
|table: nat   |       |         ****************
|chain: OUTPUT|       |               +
+-----+-------+       |               |
      |               |               v
      v               |      +-------------------+
+--------------+      |      | table: nat        |
|table: filter | +----+      | chain: POSTROUTING|
|chain: OUTPUT |             +--------+----------+
+--------------+                      |
                                      v
                               XXXXXXXXXXXXXXXXXX
                             XXX    Network     XXX
                               XXXXXXXXXXXXXXXXXX
```

#### Tables

iptables contains five tables:

1. `raw` is used only for configuring packets so that they are exempt from connection tracking.
1. `filter` is the default table, and is where all the action typically associated with a firwall take place.
1. `nat` is used for [network address translation](https://en.wikipedia.org/wiki/Network_address_translation) (e.g. port forwarding).
1. `mangle` is used for specialized packet alterations.
1. `security` is used for [mMandatory Access Control](https://wiki.archlinux.org/index.php/Security#Mandatory_access_control) networking rules. (e.g. SELinux -- see [this article](http://lwn.net/Articles/267140/) for more details).

In most common use cases you will only use two of these: **filter** and **nat**.

### Chains

Tables consist of *chains*, which are lists of rules which are followed in order. The default table, `filter`, contains three bultin-chain: `INPUT`, `OUTPUT` and `FORWARD` which are actived at different points of the packet filtering process, as illustrated in the flow chart.

`INPUT` - This chain is used to control the behavior for incoming connections. For example, if a user attempts to SSH into your PC/Server, iptables will attempt to match the IP address and port to a rule in the input chain.

`FORWARD` - This chain is used for incoming connections that aren't actually being delivered locally. Think os a router - data is always being sent to it but rarely actually destined for the router itself; the data is just forwarded to its target. Unless you're doing some kind of routing, NATing, or something else your system that rquires forwarding, you won't even use this  chain.

`OUTPUT` - This chain is used for outgoing connections. For example, if you try to ping codefarm.me, iptables will check output chain to see what the rules are regarding ping and codefarm.me before making a decision to allow or deny the connection attempt.

The nat table incudes `PREROUTING`, `POSTROUTING`, and `OUTPUT` chains.

`PREROUTING` - Alters packets before routing. i.e Packet translation happens immediately after the packet comes to the system (and before routing). This helps to translate the destination ip address of the packets to something that matches the routing on the local server. This is used for DNAT (destination NAT).

`POSTROUTING` - Alters packets after routing. i.e Packet translation happens when the packets are leaving the system. This helps to translate the source ip address of the packets to something that might match the routing on the desintation server. This is used for SNAT (source NAT).

`OUTPUT` - NAT for locally generated packets on the firewall.

### Rules

Packet fitlering is based on *rules*, which are specified by multiple *matches* (condition the packet must satisfy so that the rule can be applied), and on *target* (action taken when the packet matches all conditions). The typical things a rule might match on are what interface the packet came in on (e.g eth0 or eth1), what type of packet it is (ICMP, TCP, or UDP), or the desitination port of the packet.

Targets are specified using the `-j` or `--jump` option. Targets can be either user-defined chains (i.e. if these conditions are matched, jump to the following user-defined chain and continue processing there), one of the special built-in targets, or a target extension. Built-in targets are `ACCEPT`, `DROP`, `QUEUE` and `RETURN`, target extensions are, for example, `REJECT` and `LOG`. If the target is a built-in target, the fate of the packet is decided immediately and processing of the packet in current table is stopped. If the target is a user-defined chain and the fate of the packet is not decided by this second chain, it will be filtered against the remaining rules of the original chain. Target extensions can be either terminating (as built-in targets) or non-terminating (as user-defined chains).

### References

1. The netfilter.org project, [https://netfilter.org/index.html](https://netfilter.org/index.html)
1. iptables - ArchWiki, [https://wiki.archlinux.org/index.php/iptables](https://wiki.archlinux.org/index.php/iptables)
1. The Beginner’s Guide to iptables, the Linux Firewall, [(https://www.howtogeek.com/177621/the-beginners-guide-to-iptables-the-linux-firewall/](https://www.howtogeek.com/177621/the-beginners-guide-to-iptables-the-linux-firewall/)
1. RETURN target, [https://www.frozentux.net/iptables-tutorial/chunkyhtml/x4625.html](https://www.frozentux.net/iptables-tutorial/chunkyhtml/x4625.html)
1. IptablesHowTo - Community Help Wiki, [https://help.ubuntu.com/community/IptablesHowTo](https://help.ubuntu.com/community/IptablesHowTo)
1. HowTos/Network/IPTables - CentOS Wiki, [https://wiki.centos.org/HowTos/Network/IPTables](https://wiki.centos.org/HowTos/Network/IPTables)
1. Linux Firewall Tutorial: IPTables Tables, Chains, Rules Fundamentals, [https://www.thegeekstuff.com/2011/01/iptables-fundamentals/](https://www.thegeekstuff.com/2011/01/iptables-fundamentals/)
