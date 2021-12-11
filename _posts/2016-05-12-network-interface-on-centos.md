---
layout: post
title: "Network Interface On CentOS"
date: 2016-05-12 15:11:10 +0800
categories: ['linux', ]
tags: ['linux', 'centos', 'network']
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

One of the most common interface file is **ifcfg-eth0**, which controls the first Ethernet *network interface card* or *NIC* in the system. In a system with mulitiple NICs, there are multiple **ifcfg-eth<*x*>** files (where **&lt;x&gt;** is a unique number conrresponding to a specific interface). Beacuse each device has its own configuration file, an administrator can control how each interface functions individually.

The **Network Administration Tool** (system-config-network) is an easy way to make changes to the various network interface configuration files.

However, it is also possible to manually edit the configuration files for a given network interface.

Below is a listing of configurable parameters in an Ethernet interface configuration file:

* **BONDING_OPTS**=`<parameters>`

    sets the configuration parameters for the bonding device, and is used in `/etc/sysconfig/network-scripts/ifcfg-bond<N>`. These parameters are identical to those used for bonding devices in `/sys/class/net/<bonding device>/bonding`.

    This configuration method is used so that multiple bonding devices can have different configurations. If you use BONDING_OPTS in `ifcfg-<name>`, do not use `/etc/modprobe.conf` to specify options for the bonding device.

* **BOOTPROTO**=`<protocol>`

    * where `<protocol>` is one of the following:

        none — No boot-time protocol should be used.

        bootp — The BOOTP protocol should be used.

        dhcp — The DHCP protocol should be used.

* **BROADCAST**=`<address>`

    where `<address>` is the broadcast address. This directive is deprecated, as the value is calculated automatically with ifcalc.

* **DEVICE**=`<name>`

    where `<name>` is the name of the physical device (except for dynamically-allocated PPP devices where it is the logical name).

* **DHCP_HOSTNAME**

    Use this option only if the DHCP server requires the client to specify a hostname before receiving an IP address.

* **DNS{1,2}**=`<address>`

    where `<address>` is a name server address to be placed in `/etc/resolv.conf` if the PEERDNS directive is set to yes.

* **ETHTOOL_OPTS**=`<options>`

    where `<options>` are any device-specific options supported by ethtool. For example, if you wanted to force 100Mb, full duplex:

    `ETHTOOL_OPTS="autoneg off speed 100 duplex full"`

    Instead of a custom initscript, use ETHTOOL_OPTS to set the interface speed and duplex settings. Custom initscripts run outside of the network init script lead to unpredictable results during a post-boot network service restart.

    *Changing speed or duplex settings almost always requires disabling autonegotiation with the autoneg off option. This needs to be stated first, as the option entries are order-dependent.*

* **GATEWAY**=`<address>`

    where `<address>` is the IP address of the network router or gateway device (if any).

* **HWADDR**=`<MAC-address>`

    where `<MAC-address>` is the hardware address of the Ethernet device in the form AA:BB:CC:DD:EE:FF. This directive is useful for machines with multiple NICs to ensure that the interfaces are assigned the correct device names regardless of the configured load order for each NIC's module. This directive should not be used in conjunction with MACADDR.

* **IPADDR**=`<address>`

    where `<address>` is the IP address.

* **MACADDR**=`<MAC-address>`

    where `<MAC-address>` is the hardware address of the Ethernet device in the form AA:BB:CC:DD:EE:FF. This directive is used to assign a MAC address to an interface, overriding the one assigned to the physical NIC. This directive should not be used in conjunction with HWADDR.

* **MASTER**=`<bond-interface>`

    where `<bond-interface>` is the channel bonding interface to which the Ethernet interface is linked.

    This directive is used in conjunction with the SLAVE directive.

* **NETMASK**=`<mask>`

    where `<mask>` is the netmask value.

* **NETWORK**=`<address>`

    where `<address>` is the network address. This directive is deprecated, as the value is calculated automatically with ifcalc.

* **ONBOOT**=`<answer>`

    * where `<answer>` is one of the following:

        yes — This device should be activated at boot-time.

        no — This device should not be activated at boot-time.

* **PEERDNS**=`<answer>`

    * where `<answer>` is one of the following:

        yes — Modif `/etc/resolv.conf` if the DNS directive is set. If using DHCP, then yes is the default.

        no — Do not modify`/etc/resolv.conf`.

* **SLAVE**=`<bond-interface>`

    * where `<bond-interface>` is one of the following:

        yes — This device is controlled by the channel bonding interface specified in the MASTER directive.

        no — This device is not controlled by the channel bonding interface specified in the MASTER directive.

    This directive is used in conjunction with the MASTER directive.

* **SRCADDR**=`<address>`

    where <address> is the specified source IP address for outgoing packets.

* **USERCTL**=`<answer>`

    * where `<answer>` is one of the following:

        yes — Non-root users are allowed to control this device.

        no — Non-root users are not allowed to control this device.

* * *

### References

* [Network Interfaces](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/ch-networkscripts.html)
