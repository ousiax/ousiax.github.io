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

## Basic Concepts

iptables is used to inspect, modify, redirect, and/or drop IPv4 packets. The code for filtering IPv4 packets is already built into the kernel and is organized into a collection of **tables**, each with a specific purpose. The tables are made up of a set of predefined **chains**, and the chains **rules** which are traversed in order. Each rule consists of a predicate of potential matches and a corresponding action (called a **target**) which is executed if the predicate is true; i.e. the conditions are matched. iptables is the user utility which allows you to work with these chains/rules.

![tables traverse](/assets/firewall-netfilter-iptables/tables_traverse.gif)
<style>
img {
  width: 60%;
}
</style>

The key to understanding how iptables works is the chart above. The lowercase word on top is the table and the uppercase word below is the chain. Every IP packet that comes in *on any network interface* passes through this flow chart from top to bottom.

### Tables

iptables contains five tables:

1. `raw` is used only for configuring packets so that they are exempt from connection tracking.
1. `filter` is the default table, and is where all the action typically associated with a firwall take place.
1. `nat` is used for [network address translation](https://en.wikipedia.org/wiki/Network_address_translation) (e.g. port forwarding).
1. `mangle` is used for specialized packet alterations.
1. `security` is used for [Mandatory Access Control](https://wiki.archlinux.org/index.php/Security#Mandatory_access_control) networking rules. (e.g. SELinux -- see [this article](http://lwn.net/Articles/267140/) for more details).

In most common use cases you will only use two of these: **filter** and **nat**.

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

### Chains

Tables consist of *chains*, which are lists of rules which are followed in order.

The default table, `filter`, contains three bultin-chain: `INPUT`, `OUTPUT` and `FORWARD` which are actived at different points of the packet filtering process, as illustrated in the flow chart.

- `INPUT` - This chain is used to control the behavior for incoming connections. For example, if a user attempts to SSH into your PC/Server, iptables will attempt to match the IP address and port to a rule in the input chain.

- `FORWARD` - This chain is used for incoming connections that aren't actually being delivered locally. Think of a router - data is always being sent to it but rarely actually destined for the router itself; the data is just forwarded to its target. Unless you're doing some kind of routing, NATing, or something else your system that rquires forwarding, you won't even use this chain.

- `OUTPUT` - This chain is used for outgoing connections. For example, if you try to ping codefarm.me, iptables will check output chain to see what the rules are regarding ping and codefarm.me before making a decision to allow or deny the connection attempt.

The nat table incudes `PREROUTING`, `POSTROUTING`, and `OUTPUT` chains.

- `PREROUTING` - Alters packets before routing. i.e Packet translation happens immediately after the packet comes to the system (and before routing). This helps to translate the destination ip address of the packets to something that matches the routing on the local server. This is used for DNAT (destination NAT).

- `POSTROUTING` - Alters packets after routing. i.e Packet translation happens when the packets are leaving the system. This helps to translate the source ip address of the packets to something that might match the routing on the desintation server. This is used for SNAT (source NAT).

- `OUTPUT` - NAT for locally generated packets on the firewall.

### Rules

Packet fitlering is based on *rules*, which are specified by multiple *matches* (condition the packet must satisfy so that the rule can be applied), and on *target* (action taken when the packet matches all conditions). The typical things a rule might match on are what interface the packet came in on (e.g eth0 or eth1), what type of packet it is (ICMP, TCP, or UDP), or the desitination port of the packet.

Targets are specified using the `-j` or `--jump` option. **Targets can be either user-defined chains (i.e. if these conditions are matched, jump to the following user-defined chain and continue processing there), one of the special built-in targets, or a target extension.**

Built-in targets are `ACCEPT`, `DROP`, `QUEUE` and `RETURN`, target extensions are, for example, `REJECT` and `LOG`. If the target is a built-in target, the fate of the packet is decided immediately and processing of the packet in current table is stopped. If the target is a user-defined chain and the fate of the packet is not decided by this second chain, it will be filtered against the remaining rules of the original chain. Target extensions can be either terminating (as built-in targets) or non-terminating (as user-defined chains).

- `ACCEPT` - iptables will accept the packet.
- `DROP` - iptables will drop the packet.
- `QUEUE` - iptables will pass the packet to the userspace.
- `RETURN` - iptables will stop executing the next set of rules in the current chain for this packet. The control will be returned to the calling chain.

### Policy Chain Default Behavior

Before going in and configuring specific rules on the default table `fitler`, you'll want to decide what you want the default behavior of the three chains to be. In other words, what do you want iptables to do if the connection/packet doesn't match any existing rules?

To see what your policy chains are currently configured to do with unmatched traffic, run the `iptables -L` command.

```sh
$ sudo iptables -L | grep policy
Chain INPUT (policy ACCEPT)
Chain FORWARD (policy ACCEPT)
Chain OUTPUT (policy ACCEPT)
```

As you can see, we also used the `grep` command to give use cleaner output. In that screenshot, our chains are currently figured to accpet traffic.

More times than not, you'll
want your system to accept connections by default. Unless you've changed the policy chain rules previously, this setting should already be configured. Either way, here's the command to accept connections by default:

```sh
$ sudo iptables -P INPUT ACCEPT
$ sudo iptables -P OUTPUT ACCEPT
$ sudo iptables -P FORWARD ACCEPT
```

By defaulting to the accept rule, you can then use iptables to deny specific IP addresses or port numbers, while continuing to accept all other connections.

If you would rather deny all connections manually specify which ones you want to allow to connect, you should change the default policy of yur chains to drop. Doing this probably only be useful for servers that contain sensitive information and only ever have the same IP addresses connect to them.

```sh
$ sudo iptables --policy INPUT DROP
$ sudo iptables --policy OUTPUT DROP
$ sudo iptables --policy FORWARD DROP
```

## Configuration and Usage

### Showing the Current Rules

```sh
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
DOCKER-USER  all  --  anywhere             anywhere
DOCKER-ISOLATION  all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
DOCKER     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain DOCKER (1 references)
target     prot opt source               destination

Chain DOCKER-ISOLATION (1 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere

Chain DOCKER-USER (1 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere
```

```sh
$ sudo iptables -S
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-N DOCKER
-N DOCKER-ISOLATION
-N DOCKER-USER
-A FORWARD -j DOCKER-USER
-A FORWARD -j DOCKER-ISOLATION
-A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -o docker0 -j DOCKER
-A FORWARD -i docker0 ! -o docker0 -j ACCEPT
-A FORWARD -i docker0 -o docker0 -j ACCEPT
-A DOCKER-ISOLATION -j RETURN
-A DOCKER-USER -j RETURN
```

### Resetting Rules

```sh
$ sudo iptables -F  # Flush your iptables all chains rules
```

```sh
$ sudo iptables -F INPUT    # Flush the INPUT chain only
$ sudo iptables -F OUTPUT   # Flush the OUTPUT chain only
$ sudo iptables -F FORWARD  # Flush the FORWARD chain only
```

### Editing Rules

Rules can be edited by appending `-A` a rule to a chain, inserting `-I` it at a specific position on the chain, replacing `-R` an existing rule, or delete `-D` it.

#### Allowing Incomming Traffic on Specific Ports

You could start by blocking traffic, but you might be working over SSH, where you would need to allow SSH before blocking everything else.

To allow incomming traffic on the default SSH port (22), you could tell iptables to allow all TCP traffic on that port to come in.

```sh
$ sudo iptables -A INPUT -p tcp --dport ssh -j ACCEPT
```

or

```sh
$ sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

Referring back to the list above, you can see that this tells iptables:

1. append this rule to the input chain (`-A INPUT`) so we look at incomming traffic.
1. check to see if it is TCP (`-p tcp`).
1. if so, check to see if the input goes to the SSH port (`--dport ssh`).
1. if so, accept the input (`-j ACCEPT`.

Lets check the rules: (only the firt few lines shown, you will see more)

```
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh

```

Now, let's allow all incomming web traffic

```sh
$ sudo iptables -A INPUT -p tcp --dport http -j ACCEPT
$ sudo iptables -A INPUT -p tcp --dport https -j ACCEPT
```
or

```sh
$ sudo iptables -A INPUT -p tcp -m multiport --dports http,https -j ACCEPT
```

Checking our rules, we have

```sh
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:https
```

We have specifically allowed tcp traffic to the ssh and web ports, but as we have not blocked anything, all traffic can still come in.

#### Block Incomming Traffic

Once a decision is made to accept a packet, no more rules affect it. As our rules allowing ssh and web traffic come first, as long as our rule to block all traffic comes after them, we can still accept the traffic we want. All we need to do is put the rule to block all traffic at the end.

```sh
$ sudo iptables -A INPUT -j DROP
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:https
DROP       all  --  anywhere             anywhere
```

#### Allow Incomming Traffic on Specific IP Addresses

- Here `-s 0/0` stand for any incomming source with any IP addresses.

    ```sh
    $ sudo iptables -A INPUT -p tcp -s 0/0 --dport 22 -j ACCEPT
    $ sudo iptables -L
    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination
    ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
    ```

- `-s 192.168.66.128/24` using CIDR values, it stands for IP starting from 192.168.66.1 to 192.168.66.255.

    ```sh
    $ sudo iptables -A INPUT -p tcp -s 192.168.66.128/24 --dport 22 -j ACCEPT
    $ sudo iptables -L
    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination
    ACCEPT     tcp  --  192.168.66.0/24      anywhere             tcp dpt:ssh
    ```

    ```sh
    $ sudo iptables -A INPUT -p tcp -s 192.168.66.128/32 --dport 22 -j ACCEPT
    $ sudo iptables -L
    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination
    ACCEPT     tcp  --  192.168.66.128       anywhere             tcp dpt:ssh
    ```
    
    ```sh
    $ sudo iptables -A INPUT -p tcp -s 192.168.66.128 --dport 22 -j ACCEPT
    $ sudo iptables -L
    Chain INPUT (policy ACCEPT)
    target     prot opt source               destination
    ACCEPT     tcp  --  192.168.66.128       anywhere             tcp dpt:ssh
    ```

#### Blocking ICMP

```sh
$ sudo iptables -A OUTPUT -p icmp --icmp-type 8 -j DROP
$ sudo iptables -L
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DROP       icmp --  anywhere             anywhere             icmp echo-request
$ ping www.codefarm.me
PING www.codefarm.me (104.27.162.235) 56(84) bytes of data.
ping: sendmsg: Operation not permitted
```

#### Blocking MongoDB from outside attach

```sh
$ sudo iptables -A INPUT -p tcp -s 192.168.66.0/24 --dport 27017 -j ACCEPT
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  192.168.66.0/24      anywhere             tcp dpt:27017
```
    
#### Blocking DDOS
    
```sh
$ sudo iptables -A INPUT -p tcp --dport 80 -m limit --limit 20/minute --limit-burst 100 -j ACCEPT
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http limit: avg 20/min burst 100
```

#### Insert a New Rule / Replace an Old Rule

```sh
$ sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http

$ sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:ssh
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http

$ sudo iptables -R INPUT 1 -p tcp --dport 443 -j ACCEPT
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:https
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
```

#### Create User Defined Chain / Target

```sh
$ sudo iptables -N CODE_FARM
$ sudo iptables -L | grep 'Chain'
Chain INPUT (policy ACCEPT)
Chain FORWARD (policy ACCEPT)
Chain OUTPUT (policy ACCEPT)
Chain CODE_FARM (0 references)

$ sudo iptables -A INPUT -p tcp --dport 22 -j CODE_FARM
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
CODE_FARM  tcp  --  anywhere             anywhere             tcp dpt:ssh

Chain CODE_FARM (1 references)
target     prot opt source               destination

$ sudo iptables -A CODE_FARM -p tcp -j ACCEPT
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
CODE_FARM  tcp  --  anywhere             anywhere             tcp dpt:ssh

Chain CODE_FARM (1 references)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere

$ sudo iptables -P INPUT DROP
$ sudo iptables -L
Chain INPUT (policy DROP)
target     prot opt source               destination
CODE_FARM  tcp  --  anywhere             anywhere             tcp dpt:ssh

Chain CODE_FARM (1 references)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere
```

### Saving and Restoring IPTables Rules

Changes to **iptables** are transitory; if the system is rebooted or if the **iptables** service is restarted, the rules are automatically flushed and reset. To save the rules so that they are loaded when the **iptables** service is started, use the following command: 

```sh
$ sudo service iptables save
```

The rules are stored in the file **/etc/sysconfig/iptables** and are applied whenever the service is started or the machine is rebooted.

You can also save the current iptables into a file and restore it.

```sh
$ sudo iptables -L
Chain INPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     tcp  --  192.168.66.0/24      anywhere             tcp dpt:ssh
ACCEPT     tcp  --  anywhere             anywhere             multiport dports http,https
DROP       all  --  anywhere             anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
$ sudo iptables-save | tee iptables.rules # save current iptables into iptables.rules and print to standard output
$ sudo Generated by iptables-save v1.6.0 on Fri Jan 18 16:43:19 2019
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [278:30254]
-A INPUT -s 192.168.66.0/24 -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
-A INPUT -j DROP
COMMIT
$ sudo Completed on Fri Jan 18 16:43:19 2019
$ sudo iptables -P INPUT ACCEPT # allow any incomming traffic before delete all rules
$ sudo iptables -F # delete all rules
$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
$ sudo iptables-restore iptables.rules # restore iptables from iptables.rules
$ sudo iptables -L
Chain INPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     tcp  --  192.168.66.0/24      anywhere             tcp dpt:ssh
ACCEPT     tcp  --  anywhere             anywhere             multiport dports http,https
DROP       all  --  anywhere             anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
```

## References

1. The netfilter.org project, [https://netfilter.org/index.html](https://netfilter.org/index.html)
1. iptables - ArchWiki, [https://wiki.archlinux.org/index.php/iptables](https://wiki.archlinux.org/index.php/iptables)
1. IPTABLES VS FIREWALLD \| Unixmen, [https://www.unixmen.com/iptables-vs-firewalld/](https://www.unixmen.com/iptables-vs-firewalld/)
1. The Beginner's Guide to iptables, the Linux Firewall, [(https://www.howtogeek.com/177621/the-beginners-guide-to-iptables-the-linux-firewall/](https://www.howtogeek.com/177621/the-beginners-guide-to-iptables-the-linux-firewall/)
1. IptablesHowTo - Community Help Wiki, [https://help.ubuntu.com/community/IptablesHowTo](https://help.ubuntu.com/community/IptablesHowTo)
1. HowTos/Network/IPTables - CentOS Wiki, [https://wiki.centos.org/HowTos/Network/IPTables](https://wiki.centos.org/HowTos/Network/IPTables)
1. RETURN target, [https://www.frozentux.net/iptables-tutorial/chunkyhtml/x4625.html](https://www.frozentux.net/iptables-tutorial/chunkyhtml/x4625.html)
1. Linux Firewall Tutorial: IPTables Tables, Chains, Rules Fundamentals, [https://www.thegeekstuff.com/2011/01/iptables-fundamentals/](https://www.thegeekstuff.com/2011/01/iptables-fundamentals/)
