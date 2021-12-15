---
layout: post
title: Tcpdump Examples
date: 2018-12-29 10:22:30 +0800
categories: ['networking']
tags: ['tcpdump','tcp/ip']
---

- TOC
{:toc}

- - -

## Basics

#### 1.1 BASIC COMMUNICATION

Just see what's going on, by looking at all interfaces.

```sh
tcpdump -i any
```

#### 1.2 SPECIFIC INTERFACE

Basic view of what's happening on a particular interface.

```sh
tcpdump -i eth0
```

#### 1.3 RAW OUTPUT VIEW

Verbose output (`-vv`), with no resolution of hostnames or port numbers (`-nn`), absolute sequence numbers (`-S`), and human-readable timestamps (`-tttt`).

```sh
tcpdump -ttttnnvvS
```

#### 1.4 FIND TRAFFIC BY IP

One of the most common queries, this will show you traffic from 1.2.3.4, whether it's the source or the destination.

```sh
tcpdump host 1.2.3.4
```

#### 1.5 SEEING MORE OF THE PACKET WITH HEX OUTPUT

Hex output is useful when you want to see the content of the packets in question, and it's often best used when you're isolating a few candiates for closer scrutiny.

```sh
tcpdump -nnvXSs0 icmp
```

#### 1.6 FILTERING BY SOURCE AND DESTINATION

It's quite easy to isolate traffic based on either source or destination using `src` and `dst`.

```sh
tcpdump src 2.3.4.5
tcpdump dst 3.4.5.6
```

#### 1.7 FINDING PACKETS BY NETWORK

To find packets going to or from a particular network, use the `net` option. You can combine this with the `src` or `dst` options as well.

```sh
tcpdump net 1.2.3.0/24
```

#### 1.8 SHOW TRAFFIC RELATED TO A SPECIFIC PORT

You can find specific port traffic by using the `port` option followed by the port number.

```sh
tcpdump port 3389
tcpdump src port 3389
```

#### 1.9 SHOW TRAFFIC OF ONE PROTOCOL

If you're looking one particular kind of traffic, you can use tcp (or proto 6), udp (or proto 17) and many others as well.

```sh
tcpdump tcp # same as tcpdump proto 6
```

#### 1.10 SHOW ONLY IP6 TRAFFIC

You can also find all IPv6 traffic using the protocol option.

```sh
tcpdump ip6
```

#### 1.11 FIND TRAFFIC USING PORT RANGES

You can also use a range of ports to find traffic.

```sh
tcpdump portrange 21-23
```

#### 1.12 FIND TRAFFIC BASED ON PACKET SIZE

If you're looking for packets of a particular size you can use these options. You can use less, greater, or their associated symbols that you would expect from mathmatics.

```sh
tcpdump less 32
tcpdump greater 64
tcpdump <=128
```

#### 1.13 READING / WRITING CAPTURES TO A FILE

It's often useful to save packet captures into a file for analysis in the future. These files are known as PACAP (PEE-cap) files, and they can be processed by hundreds of different applications (e.g. Wireshark), including network analyzers, intrusion detection systems, and of course by `tcpdump` itself.

```sh
tcpdump port 80 -w capture_file.pcap
```

You can read PACAP files by using the `-r` switch. Note that you can use all the regular commands within tcpdump while reading in a file; you're only limited by the fact that you can't capture and process what doesn't exist in the file already.

```sh
tcpdump -r capture_file.pcap
```

## Advanced

#### 2.1 FROM SPECIFIC IP AND DESTINED FOR A SPECIFIC PORT

Let's find all traffic form 10.5.2.3 going to any host on port 3389.

```sh
tcpdump -nnvvS src 10.5.2.3 and dst port 3389
```

#### 2.2 FIND ONE NETWORK TO ANOTHER

Let's look for all traffic comming from 192.168.x.x and goning to the 10.x or 172.16.x.x networks, and we're showing hex output with no hostname resolution and one level of extra verbosity.

```sh
tcpdump -nvX src net 192.168.0.0/16 and dst net 10.0.0.0/8 or 172.16.0.0/16
```

#### 2.3 NON ICMP TRAFFIC GOING TO A SPECIFIC IP

This will show us all traffic goning to 192.168.0.2 that is *not* ICMP.

```sh
tcpdump dst 192.168.0.2 and not icmp
```

#### 2.4 TRAFFIC FROM A HOST THAT ISN'T ON A SPECIFIC PORT

This will show us all traffic from a host and isn't SSH traffic (assuming default port usage).

```sh
tcpdump -vv src mars and not dst port 22
```

Keep in mind that when you're building complex queries you minght have to group your options using single quotes. Single quotes are used in order to tell `tcpdump` to ignore certain special characters—in this case below the "()" brackets. The same technique can be used to group using other expressions such as `host`, `port`, `net`, etc.

```sh
tcpdump 'src 10.0.2.4 and (dst port 3389 or 22)'
```

#### 2.5 ISOLATE TCP FLAGS

You can also use filters to isolate packets with specific TCP flags set.

##### 2.5.1 Isolate TCP RST flags.

```sh
tcpdump 'tcp[13] & 4 != 0'
tcpdump 'tcp[tcpflags] == tcp-rst'
```

##### 2.5.2 Isolate TCP SYNC flags.

```sh
tcpdump 'tcp[13] & 2 != 0'
tcpdump 'tcp[tcpflags] == tcp-syn'
```

##### 2.5.3 Isolate packets that have both SYN and ACK flags set.

```sh
tcpdump 'tcp[13] = 18'
```

##### 2.5.4 Isolate TCP URG flags.

```sh
tcpdump 'tcp[13] & 32 != 0'
tcpdump 'tcp[tcpflags] == tcp-urg'
```

##### 2.5.5 Isolate TCP ACK flags.

```sh
tcpdump 'tcp[13] & 16!=0'
tcpdump 'tcp[tcpflags] == tcp-ack'
```

##### 2.5.6 Isolate TCP PSH flags.

```sh
tcpdump 'tcp[13] & 8!=0'
tcpdump 'tcp[tcpflags] == tcp-psh'
```

##### 2.5.7 Isolate TCP FIN flags.

```sh
tcpdump 'tcp[13] & 1!=0'
tcpdump 'tcp[tcpflags] == tcp-fin'
```

##### 2.5.8 Isolate packets that have both SYN and RST flags set.

```sh
tcpdump 'tcp[13] = 6'
```

#### 2.6 FIND HTTP USER AGENTS

```sh
tcpdump -vvAls0 | grep 'User-Agent:'
```

#### 2.7 CLEARTEXT GET REQUESTS

```sh
tcpdump -vvAls0 | grep 'GET'
```

#### 2.8 FIND HTTP HOST HEADERS

```sh
tcpdump -vvAls0 | grep 'Host:'
```

#### 2.9 FIND HTTP COOKIES

```sh
tcpdump -vvAls0 | egrep 'Set-Cookie:|Cookie:'
```

#### 2.10 FIND DNS TRAFFIC

```sh
tcpdump -vvAs0 port 53
```

#### 2.11 FIND FTP TRAFFIC

```sh
tcpdump -vvAs0 port ftp or ftp-data
```

#### 2.12 FIND NTP TRAFFIC

```sh
tcpdump -vvAs0 port 123
```

#### 2.13 FIND CLEARTEXT PASSWORDS

```sh
tcpdump port http or port ftp or port smtp or port imap or port pop3 or port telnet -lA | egrep -i -B5 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:|pass |user ' 
```

## 3. References

- [https://hackertarget.com/tcpdump-examples/](https://hackertarget.com/tcpdump-examples/)
- [https://danielmiessler.com/study/tcpdump/](https://danielmiessler.com/study/tcpdump/)
