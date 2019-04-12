---
layout: post
title: 数字签名和数字证书
date: 2019-04-12 13:55:20 +0800
categories: ['Cryptography']
tags: ['Cryptography']
---

### 密码系统

在密码学（cryptography）中，密码系统（cryptosystem）是用于特定安全服务（通常是实现保密性，即加密）所需的一套算法。

密码系统通常由三种算法组成：一种用于密钥的生成（key generation），一种用于加密（encryption），一种用于解密（decryption）。单词 cipher 或 cypher 通常指一对加密和解密的算法，所以单词  cryptosystem 通常用于强调密钥生成算法的重要性，表示公钥加密（public key）。但是，cipher 和 cryptosystem 都可以指对称加密（symmetric key）。

在密码学中，明文（plaintext  or cleartext）是指未加密的消息，密文（cipher text）指通过加密算法（encryption algorithm），将明文进行扰乱并转换为不可读的消息，密文可以通过解密算法（decryption algorithm）转换为明文。而密钥（key）是指用于限定密码算法（cryptographic alogrithm）输出的一段信息，在加密算法中，密钥用于将明文转换为密文，而在解密算法中，密钥用于将密文转换为明文。

### 对称加密算法

对称加密算法（symmetric key algorithm）是指在明文加密和密文解密中使用同一个的密钥的密码算法。实际上，对称加密的密钥由两个或多个参与方共享，并用于在参与方之间维护一条私有的信息链路。对称加密算法的通信的双方都有密码的访问权，相对于公钥加密，对称加密的密钥的共享成为对称加密算法的一个主要缺点。

对称加密算法有 AES, RC4, DES, RC5, and RC6 等，常用的算法是 AES-128 AES-192 AES-256。

### 公钥加密

公钥加密（public key cryptography）或非对称加密（asymmetric cryptography）是一种使用一对公钥（public key）和私钥（private key）的密码系统，其中，公钥可以广泛的公开传播，但私钥只有所有者持有。公钥加密系统的安全的有效性只需要对私钥保密，而公钥的公开和发布不会影响安全性。

在公钥加密系统中，任何人都可以用接收者的公钥加密明文，而只有接收者使用其持有的私钥才能将密文解密。

非对称加密的常见算法有 RSA，DSA，PKCS 等。

RSA 是最早的公钥加密算法之一，并广泛用于数据的安全传输。RSA 由在1978年公开发表该算法的三个发明人（Ron Rivest，Adi Shamir，和 Leonard Adleman）的姓氏的首字母组成。

RSA 是相对比较慢的算法，因此很少直接用于数据的加密，更多是用于对称加密算法中共享密钥的传递，然后由对称加密算法进行大量的更加快速高效的加解密操作。

### 数字签名

数字签名（digital signature）用于检验数字消息或文档的可靠性的一种数学方案（mathematical scheme）。有效的数字签名可以让接收者有非常强的理由相信其接收到的消息是由已知或者认证的发送者创建，并且消息在传输的过程并没有被篡改。

数字签名利用公钥加密系统，很多情况中，用于在非安全的信息通道中提供一层对消息的校验和安全层，并用于鉴定（authentication）消息的可靠来源，提供消息的完整性（integrity）以及消息的不可抵赖性（non-repudiation）保证。

### 数字证书

在密码学中，公钥证书（public key certificate）或数字证书（digital certificate）或者身份证书（identity certificate）是用于证明公钥所有权的一种电子文档。证书中包含公钥的信息，所有者或者主体（subject）的信息，以及验证证书内容的实体即证书的签发者（issuer）的数字签名。如果签名有效，并核验了证书的信签发者，则可以使用证书的公钥进行安全的信息通信。数字证书保证了公钥进行安全可靠的发布和传播。

在电子邮件加密、代码签名和电子签名系统中，证书的主体通常是个人或组织。但是，但安全传输协议层 TLS（Transport Layer Security）中，证书的主体通常是指计算机或者其他设备，当然，TSL 证书除了标识设备的核心角色外，还可以标识个人或组织。TLS 有时也用其旧称，即安全套接字层 SSL（Secure Sockets Layer），并因作为 Web 浏览器安全访问的 HTTPS 协议的一部分而闻名。

在一个典型的公钥基础设施 PKI（public key infrastructure）中，证书的签发者是一个证书签发机构 CA（certificate authority），通常是一个向客户收取费用并为其签发证书的公司。

在密码学中，X.509 是一种最常见的标准的公钥证书的定义格式。X.509 证书在许多互联网协议中都有使用，例如用于 Web 浏览器安全访问的 HTTPS 协议中的 TLS 或 SSL，以及一些如电子签名的离线应用。X.509 证书中包含公钥和主体身份（主机名，组织或个人），并由可信的签发机构（CA）签名或自签名（self-signed）。当证书由可信任的签发机构签名或者其他方式核验后，证书的持有者可以根据证书中的公钥和证书的主体建立安全的通信，或者验证由证书中公钥对应的私钥所签名的电子文档。

X.509 证书有几种常见的文件扩展名：

- .pem（Privacy-enhanced Electronic Mail）基于 Base64 编码的 DER （Distinguished Encoding Rules）格式的证书，以 `-----BEGIN CERTIFICATE-----` 开始，并以 `-----END CERTIFICATE-----` 结束。
- .cer, .crt, .der 扩展名通常是指二进制形式的 DER 格式的证书

在公钥基础设施 PKI 系统中，证书签名请求 CSR（certificate signing request），或证书请求（certificate request）是由证书申请人发送给证书的签发机构（CA)以便申请数字证书的身份消息。CSR 通常包含被签发者证书的公钥，标识信息（如域名）以及完整性保护（integrity protection，如数字签名）。CSR 最常见的格式是 PKCS #10 规范，以及另一种由某些 Web 浏览器生成的签名公钥和质询 SPKAC（Signed Public Key and Challenge）格式。

### ## OpenSSL

OpenSSL 是一个应用程序软件库，用于保护计算机网络的安全通信，防止窃听或者识别通信另一端的参与方。 OpenSSL 广泛用于互联网服务器，并为大多数网站提供服务。OpenSSL 包含了一个 TLS/SSL 协议的开源实现。大多数 Unix 和 Unix-like 的操作系统(包括 Solaris, Linux, macOS, QNX 和各种开源 BSD 操作系统)，OpenVMS 和 Microsoft Windows 都有可用的版本。

- 使用 OpenSSL 创建自签名根证书
  
  ```sh
  # Generate a self signed root certificate
  openssl req \
      -x509 -nodes \
      -newkey rsa:2048 -keyout 996.icu.key -out 996.icu.pem \
      -subj "/C=CN/ST=Shanghai/L=Shanghai/O=996/CN=996.icu"
  ```
  
- 使用 996.icu 根证书签发 955.wlb 证书
  
  ```sh
  # Generate a certificate signing request
  openssl req \
      -nodes \
      -newkey rsa:2048 -keyout 955.wlb.key -out 955.wlb.csr \
      -subj "/C=CN/ST=Shanghai/L=Shanghai/O=955/CN=955.wlb"
  
  # Sign a certificate request using the CA certificate above
  openssl x509 \
      -req -in 955.wlb.csr \
      -CA 996.icu.pem -CAkey 996.icu.key -CAcreateserial \
      -out 955.wlb.pem -days 10000
  ```
  
- 查看 955.wlb 证书的内容
  
  ```sh
  openssl x509 -in 955.wlb.pem -noout -text
  ```
  
  ```none
  Certificate:
      Data:
          Version: 1 (0x0)
          Serial Number:
              e5:7a:55:ac:d4:b5:94:8f
      Signature Algorithm: sha256WithRSAEncryption
          Issuer: C = CN, ST = Shanghai, L = Shanghai, O = 996, CN = 996.icu
          Validity
              Not Before: Apr 12 09:02:59 2019 GMT
              Not After : Aug 28 09:02:59 2046 GMT
          Subject: C = CN, ST = Shanghai, L = Shanghai, O = 955, CN = 955.wlb
          Subject Public Key Info:
              Public Key Algorithm: rsaEncryption
                  Public-Key: (2048 bit)
                  Modulus:
                      00:c0:bd:6f:05:c1:cd:1b:a4:d5:3b:ed:69:a1:5b:
                      2e:d6:9a:c9:4d:88:9e:d1:fb:5d:40:f9:96:3c:b1:
                      2c:73:9b:68:6c:d1:83:6d:c1:5b:79:64:b5:29:af:
                      3b:30:e2:d7:ef:f4:d0:33:4a:9a:0d:8c:70:5c:21:
                      11:07:06:5f:41:b0:7f:82:68:27:06:c0:65:d7:48:
                      00:e4:5a:3a:ef:b2:7c:f9:af:82:c6:ca:75:a5:9e:
                      25:a1:d4:af:1a:e3:40:c0:ce:24:16:5b:ed:87:3f:
                      bf:19:92:05:fc:bd:7b:69:71:3a:c4:c9:19:c8:f8:
                      5d:9c:59:c5:f5:6a:a6:a8:c1:6f:06:2a:06:45:8c:
                      52:35:3f:4e:94:57:4d:82:af:2e:a7:05:d4:0d:5b:
                      b5:3d:cc:b7:0b:af:3d:79:7e:53:5b:be:a5:37:bb:
                      8f:05:a3:92:6f:e4:69:2a:22:7e:a9:4b:5f:0f:12:
                      e2:16:3e:b6:f3:54:42:4f:e2:01:0c:8b:30:ee:79:
                      de:30:62:dd:95:e4:8f:aa:06:3c:43:05:a3:0e:46:
                      e5:cd:24:59:9d:2f:7d:49:1e:0c:c7:74:a6:78:cc:
                      1b:9a:50:c6:61:ad:c7:37:a0:08:84:36:4c:a2:29:
                      b0:5b:f5:71:08:8e:f7:8c:9e:be:b3:f8:cb:5e:fc:
                      27:31
                  Exponent: 65537 (0x10001)
      Signature Algorithm: sha256WithRSAEncryption
           32:1f:35:96:7d:ef:ab:08:b1:52:dc:36:9c:c1:7d:73:e5:44:
           0a:c5:76:0f:58:e0:9b:d2:93:37:9a:3c:d7:94:20:37:a8:16:
           cc:2c:c3:73:49:ae:b2:27:9d:bb:fe:c4:8d:7e:4b:4e:75:5e:
           7f:e9:6c:e0:0e:13:79:ca:b4:cc:ed:80:61:ec:91:1d:de:51:
           f1:1f:5a:ae:0b:1b:81:31:7a:5d:79:8b:f4:86:a5:15:73:3f:
           31:f3:71:bb:dd:1c:78:2d:57:14:f6:f4:02:b0:17:63:fb:a5:
           aa:2b:68:f7:c2:37:2e:80:03:12:54:f3:d0:33:0e:3a:36:5a:
           ca:43:4e:95:f0:ed:67:4a:c8:57:2a:6a:08:4b:fb:57:fa:e2:
           3a:0e:42:8f:41:0f:92:33:73:00:da:0e:b3:77:b9:ff:2b:a8:
           cf:3d:bd:11:ad:7a:cd:b2:b4:3b:34:6b:6b:f3:c5:9d:9d:e0:
           97:cb:a7:e8:7a:8d:53:8f:d9:84:cf:ee:78:59:05:a8:85:2a:
           c6:ec:9a:d5:38:2c:bf:ff:d8:52:d2:fc:55:25:03:81:10:23:
           8c:56:38:2c:3a:a8:27:f7:a0:4b:16:f5:51:6f:1d:b3:84:ee:
           08:91:92:5d:93:55:29:14:a9:cd:10:ce:43:e0:2d:ac:1a:45:
           a2:83:d7:f2
  ```
  
- 验证证书 955.wlb.pem 的数字签名有效性
  
  证书签发机构 CA 在签名证书时，实际上是先用哈希算法计算证书内容的摘要信息（digest message），然后再利用公钥加密系统的私钥对摘要信息加密，并将摘要信息的密文嵌入到证书中。所以，要校验由 CA 签发的证书的签名信息，只需要 CA 的公钥，证书的签名信息以及摘要算法。



### References

- https://en.wikipedia.org/wiki/Cryptosystem
- https://en.wikipedia.org/wiki/Symmetric-key_algorithm
- https://en.wikipedia.org/wiki/Public-key_cryptography
- https://en.wikipedia.org/wiki/RSA_(cryptosystem)
- https://en.wikipedia.org/wiki/Certificate_signing_request
- https://en.wikipedia.org/wiki/X.509
- https://en.wikipedia.org/wiki/OpenSSL
- https://linuxctl.com/2017/02/x509-certificate-manual-signature-verification/
