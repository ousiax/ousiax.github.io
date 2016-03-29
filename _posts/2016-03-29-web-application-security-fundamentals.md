---
layout: post
title: "Web应用程序安全基础"
date: 2016-03-28 16-45-46 +0800
categories: ['Web',]
tags: ['Web', 'Security']
disqus_identifier: 95224089416555028000460144967225061458
---
关于Web应用的安全性，我们会想到的有网站污损，盗取信用卡号码，拒绝服务攻击（DoS），病毒，特洛伊木马，蠕虫……，而这些问题中最大的问是对安全的无知。

**我们是安全的？我们有防火墙**

这是一个普遍的误解，因为防火墙的安全性要取决于威胁的类型。例如，防火墙无法检测发送到Web应用的恶意输入。

防火墙在于封锁端口，是安全的一个组成部分，并不是一个完整的解决方案。

这同样适用于安全套接字层（SSL），SSL在于网络流量的加密，但它不会验证应用程序的输入或保护配置不当的服务器。

**什么是我们所指的安全？**

安全的根本在于保护资产。资产可以是有形的，如网页或者客户的数据，也可以是无形的，比如公司的声誉。

安全是没有终点的征程。通过分析基础设施与应用程序，可以找出潜在的威胁以及了解威胁的风险程度。安全是关于风险的管理与有效对策的实施。

***安全基础***

* 认证（Authentication）

    认证要解决的问题是：你是谁？（贫僧乃东土大唐差往西天取经者。路过此间，……）。它是应用程序对户端（包括终端用户，其他的服务，进程或计算机)的唯一性标识。对客户端的认证是安全方面的基础。

* 授权（Authorization）

    授权解决的问题是：你能做什么？它是对认证的客户端在资源的支配和操作的访问过程中的许可认证。资源包括文件，数据库，表，行等，以及系统级资源，如注册表，配置数据。资源的操作包括交易的执行，如产品的购买，账户资金的转移，客户信用评级的增加等。

* 审计（Auditing）

    有效的审计和日志是不可抵赖性的关键。不可抵赖性保证用户无法对执行的操作进行否认。例如，在电子商务系统中，需要不可抵赖机制，以确保消费者不能否认100份特定书籍的订购。

* 保密（Confidentiality）

    保密性，也被称为私密性（privacy），用于确保数据的隐私与保密，以及确保数据在网络传输的过程中不会被非授权用户偷听或查看。加密常用于保密性的增强，而访问控制列表（ACL）是另一种手段。

* 完整性（Integrity）

    完整性保护数据不被意外或者有意的篡改。就像保密性（privacy），完整性也是一个关键的问题点，特别是数据在网络传输的过程中。通常使用散列（hashing）和消息码认证（message authentication codes）提供数据的完整性。

* 可用性（Availability）

    从安全的角度看，可用性是指应用程序对用户的可用性保证。拒绝服务攻击（DoS）的目的是整垮应用程序或者耗尽系统资源，使应用程序无法被其他的用户访问。 

**威胁，漏洞和攻击的定义**

威胁是对资产潜在的，恶意的或其他对资产有害的任何事情。

漏洞是可能产生威胁的一种缺陷。这可能是不良的设计，错误的配置或不适当和不安全的编码技术。

攻击是一种探测漏洞或发现威胁的行为。攻击的例子包括向应用程序发送恶意的输入或用于拒绝服务的网络洪水攻击。

**如何建立安全的Web应用程序？**

设计和构建安全的Web应用程序之前，你需要知道你所面对的威胁。一个重要的准则就是在应用程序的设计阶段进行威胁建模（threat modeling）。威胁建模的目的是分析应用程序的架构和设计，并识别破坏系统安全的潜在漏洞，如用户的误操作，恶意目的攻击。

在系统设计的时候，可以应用安全原则进行系统安全性设计的考量。作为开发人员，你需要遵循安全的编码技术，开发安全，稳定的解决方案。应用层的软件设计与开发须由软件部署的服务器的安全的网络，主机和配置的支持。

**网络，主机和应用程序的安全**

*"A vulnerability in a network will allow a malicious user to exploit a host or an application. A vulnerability in a host will allow a malicious user to exploit a network or an application. A vulnerability in an application will allow a malicious user to exploit a network or a host."*

*Carlos Lyons, Corporate Security, Microsoft*

要构建安全的Web应用程序，需要对应用程序安全做到统筹兼顾，并且安全必须应用到所有的三层（网络，主机和应用程序）。

![A holistic approach to security](https://msdn.microsoft.com/dynimg/IC97872.gif)

***Figure 1.1 A holistic approach to security***

**网络安全**

安全的Web应用依赖于一个安全的网络基础设施。网络基础设施由路由器，防火墙和交换机构成。网络安全的作用不仅是保护自己免受基于TCP/IP的攻击，也是如安全的管理接口和强密码等应对措施的实现。网络安全也负责其转发流量的完整性。

**网络组件的类别**

* 路由器（Router）

    路由器是网络的最外一环。路由器根据应用程序需要的协议和端口设定数据包的网络路径。常见的TCP/IP漏洞在这一环得到限制。

* 防火墙（Firewall）

    防火墙用于限制应用程序不使用的协议和端口。此外，防火墙可根据特定程序的过滤规则，限制恶意的网络通信，保护网络流量的安全。

* 交换机（Switch）

    交换机用于网段的划分。它们通常是被忽视的或被过于信任的。

**主机安全**

在主机安全中，无论是Web服务器，应用服务器或数据库服务器，通过将安全设置进行分类，你可以专注于特定类别的安全审查或针对特定的安全类别应用相关的安全设置
。


![](https://msdn.microsoft.com/dynimg/IC44962.gif)

***Figure 1.2 Host security categories***

* 补丁和更新

    漏洞的发布以及被众所周知，导致存在许多的安全风险。当新的漏洞被发现并首次用于攻击成功时，这些漏洞代码在数小时内就会被发布于互联网的公告板上。对服务器的软件的补丁修订或更新，是对服务器安全保护的第一步。如果不对服务器进行补丁修订或更新，这会为恶意代码和攻击者提供更多潜在的机会。

* 服务

    通过禁用不必要和不使用的服务，可以轻易的减少攻击面。

* 协议

    通过禁用不必要或不使用的网络协议，可以减少攻击者的攻击面和攻击途径。

* 账户

    访问服务器的各种账户应限制在必要的服务与用户的账户组内。另外，你应该执行适当的账户策略，如强制使用强密码。

* 文件和目录

    文件和目录应该使用文件系统（ext2/3/4，NTFS，FAT）的权限系统进行限制。

* 共享

    删除所有不必要的文件共享，包括不需要的默认共享。使用文件系统的权限系统保护文件的共享。

* 端口

    服务在运行的服务器侦听特定的端口处理传入的请求。服务器打开的端口须定期的审查，以确保不被不安全的服务用于侦听并用于网络通信。

* 审计和日志

    审计是确认入侵或攻击的一种重要辅助。日志记录入侵或攻击的行为和方式。

* 注册表（Windows）

    许多安全相关的设置被保存在注册表中。通过应用受限的Windows ACL并阻止远程注册表的管理保护注册表的安全。

**应用程序安全**

* 输入校验（Input Validation）

    输入校验是指应用程序对输入进行处理之前，进行有效性和安全性的检查，如过滤，打磨或拒绝输入。

* 认证

    "Who are you?" 认证是通常使用用户名和密码对实体进行身份证实的过程。

* 授权

    "What can you do?" 授权是应用程序对资源和操作的访问控制。

* 配置管理

    Who does your application run as? Which databases does it connect to? How is your application administered? How are these settings secured?

* 敏感数据

    敏感数据是指应用程序对内存中，网络中或持久化存储的数据的安全保护。

* 会话管理

    会话是指用户和Web应用之间一系列相关的交互。会话管理是指应用程序如何处理并保护这些交互。

* 加密

    如何保护密码，隐私？如何防止数据或资料库篡改（数据的完整性）？如何提供用于增强加密的随机数的种子？加密是指应用程序如何增强保密和隐私。

* 参数处理

    表单字段，查询字符串参数和Cookie值常常作为应用程序的参数。参数处理是指如何保护参数值不被篡改和应用程序如何对处理参数的输入。

* 错误（异常）管理

    When a method call in your application fails, what does your application do? How much do you reveal? Do you return friendly error information to end users? Do you pass valuable exception information back to the caller? Does your application fail gracefully?

* 审计和日志

    Who did what and when? Auditing and logging refer to how your application records security-related events.

**安全准则**

* 隔离（Compartmentalize）

* 最低权限（Use least privilege）

* 深度防御（Apply defense in depth）

* 不要相信用户的输入（Do not trust user input）

* 检查入口（Check at the gate）

* 安全的失败（Fail securely）

* 保护脆弱的结点（Secure the weakest link）

* 创建安全的缺省（Create secure defaults）


* 减小攻击面（Reduce your attack surface）

    If you don't use it, remove it or disable it.

* * *

### References

* [Chapter 1- Web Application Security Fundamentals](https://msdn.microsoft.com/en-us/library/ff648636.aspx#c01618429_004)
