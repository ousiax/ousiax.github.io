---
layout: post
title: 数字签名和数字证书
date: 2019-04-12 13:55:20 +0800
categories: ['Cryptography']
tags: ['Cryptography']
---

- TOC
{:toc}

- - -

### 密码系统

在密码学（cryptography）中，密码系统（cryptosystem）是用于特定安全服务（通常是实现保密性，即加密）所需的一套算法。

密码系统通常由三种算法组成：一种用于密钥的生成（key generation），一种用于加密（encryption），一种用于解密（decryption）。单词 cipher 或 cypher 通常指一对加密和解密的算法，所以单词 cryptosystem 通常用于强调密钥生成算法的重要性，表示公钥加密（public key）。但 cipher 和 cryptosystem 都可以指对称加密（symmetric key）。

在密码学中，明文（plaintext  or cleartext）是指未加密的消息，密文（cipher text）指通过加密算法（encryption algorithm），将明文进行扰乱并转换为不可读的消息，密文可以通过解密算法（decryption algorithm）转换为明文。密钥（key）是指用于限定密码算法（cryptographic alogrithm）输出的一段信息，在加密算法中，密钥用于将明文转换为密文，而在解密算法中，密钥用于将密文转换为明文。

### 对称加密算法

对称加密算法（symmetric key algorithm）是指在明文加密和密文解密中使用同一个的密钥的密码算法。实际上，对称加密的密钥由两个或多个参与方共享，并用于在参与方之间维护一条私有的信息链路。对称加密算法的通信双方都有密钥的访问权，相对于公钥加密，对称加密的密钥的共享成为对称加密算法的一个主要缺点。

对称加密算法有 AES, RC4, DES, RC5 和 RC6 等，常用的算法是 AES-128，AES-192 和 AES-256。

### 公钥加密

公钥加密（public key cryptography）或非对称加密（asymmetric cryptography）是一种使用一对公钥（public key）和私钥（private key）的密码系统，其中，公钥可以广泛的公开传播，但私钥只有所有者持有。公钥加密系统的安全的有效性只需要对私钥保密，而公钥的公开和发布不会影响安全性。

在公钥加密系统中，任何人都可以用接收者的公钥加密明文，而只有接收者使用其持有的私钥才能将密文解密。

非对称加密的常见算法有 RSA，DSA，PKCS 等。

RSA 是最早的公钥加密算法之一，并广泛用于数据的安全传输。RSA 由在1978年公开发表该算法的三个发明人（Ron Rivest，Adi Shamir，和 Leonard Adleman）的姓氏的首字母组成。

RSA 是相对比较慢的算法，因此很少直接用于数据的加密，更多是用于对称加密算法中共享密钥的传递，然后由对称加密算法进行大量的更加快速高效的加解密操作。

### 数字签名

数字签名（digital signature）用于检验数字消息或电子文档的可靠性的一种数学方案（mathematical scheme）。有效的数字签名可以让接收者有非常强的理由相信其接收到的消息是由已知或者认证的发送者创建，并且消息在传输的过程并没有被篡改。

数字签名利用公钥加密系统，很多情况中，用于在非安全的信息通道中提供一层对消息的校验和安全层，并用于鉴定（authentication）消息的可靠来源，提供消息的完整性（integrity）以及消息的不可抵赖性（non-repudiation）保证。

### 数字证书

在密码学中，公钥证书（public key certificate）或数字证书（digital certificate）或者身份证书（identity certificate）是用于证明公钥所有权的一种电子文档。证书中包含公钥的信息，所有者或者主体（subject）的信息，以及验证证书内容的实体即证书的签发者（issuer）的数字签名。如果签名有效，并核验了证书的信任签发者，则可以使用证书的公钥进行安全的信息通信。数字证书保证了公钥发布和传播的安全性和可靠性。

在电子邮件加密、代码签名和电子签名系统中，证书的主体通常是个人或组织。但是，在安全传输协议层 TLS（Transport Layer Security）中，证书的主体通常是指计算机或者其他设备。当然，TSL 证书除了标识设备的核心角色外，还可以标识个人或组织。TLS 有时也用其旧称，即安全套接字层 SSL（Secure Sockets Layer），并因作为 Web 浏览器安全访问的HTTPS协议的一部分而闻名。

在一个典型的公钥基础设施 PKI（public key infrastructure）中，证书的签发者是一个证书签发机构 CA（certificate authority），通常是一个向客户收取费用并为其签发证书的公司。

在密码学中，X.509 是一种最常见的标准的公钥证书的定义格式。X.509 证书在许多互联网协议中都有使用，例如用于 Web 浏览器安全访问的 HTTPS 协议中的 TLS 或 SSL，以及一些如电子签名的离线应用。X.509 证书中包含公钥和主体身份（主机名，组织或个人），并由可信的签发机构（CA）签名或自签名（self-signed）。当证书由可信任的签发机构签名或者其他方式核验后，证书的持有者可以根据证书中的公钥和证书的主体建立安全的通信，或者验证由证书中公钥对应的私钥所签名的电子文档。

X.509 证书有几种常见的文件扩展名：

- .pem（Privacy-enhanced Electronic Mail）基于 Base64 编码的 DER （Distinguished Encoding Rules）格式的证书，以 `-----BEGIN CERTIFICATE-----` 开始，并以 `-----END CERTIFICATE-----` 结束。
- .cer, .crt, .der 扩展名通常是指二进制的 DER 格式的证书

在公钥基础设施 PKI 系统中，证书签名请求 CSR（certificate signing request），或证书请求（certificate request）是由证书申请人发送给证书的签发机构（CA)以便申请数字证书的身份消息。CSR 通常包含被签发者证书的公钥，标识信息（如域名）以及完整性保护（integrity protection，如数字签名）。CSR 最常见的格式是 PKCS #10 规范，以及另一种由某些 Web 浏览器生成的签名公钥和质询 SPKAC（Signed Public Key and Challenge）格式。

### OpenSSL

OpenSSL 是一个应用程序软件库，用于保护计算机网络的安全通信，防止窃听或者识别通信另一端的参与方。 OpenSSL 广泛用于互联网服务器，并为大多数网站提供服务。OpenSSL 包含了一个 TLS/SSL 协议的开源实现。大多数 Unix 和 Unix-like 的操作系统(包括 Solaris, Linux, macOS, QNX 和各种开源 BSD 操作系统)，OpenVMS 和 Microsoft Windows 都有可用的版本。

- 使用 OpenSSL 创建自签名根证书
  
  ```sh
  # Generate a self signed root certificate
  openssl req \
      -x509 \
      -nodes \
      -newkey rsa:2048 \
      -keyout 996.icu.key \
      -out 996.icu.pem \
      -subj "/C=CN/ST=Shanghai/L=Shanghai/O=996/CN=996.icu"
  ```
  
- 使用 996.icu 根证书签发 955.wlb 证书
  
  ```sh
  # Generate a certificate signing request
  openssl req \
      -nodes \
      -newkey rsa:2048 \
      -keyout 955.wlb.key \
      -out 955.wlb.csr \
      -subj "/C=CN/ST=Shanghai/L=Shanghai/O=955/CN=955.wlb"
  
  # Sign a certificate request using the CA certificate above
  openssl x509 \
      -req \
      -CA 996.icu.pem \
      -CAkey 996.icu.key \
      -CAcreateserial \
      -days 10000 \
      -in 955.wlb.csr \
      -out 955.wlb.pem
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
              80:58:87:4a:4c:41:0f:25
      Signature Algorithm: sha256WithRSAEncryption
          Issuer: C = CN, ST = Shanghai, L = Shanghai, O = 996, CN = 996.icu
          Validity
              Not Before: Apr 12 10:04:39 2019 GMT
              Not After : Aug 28 10:04:39 2046 GMT
          Subject: C = CN, ST = Shanghai, L = Shanghai, O = 955, CN = 955.wlb
          Subject Public Key Info:
              Public Key Algorithm: rsaEncryption
                  Public-Key: (2048 bit)
                  Modulus:
                      00:b2:20:29:35:5f:fe:42:35:22:74:03:8b:fd:75:
                      04:66:3d:fd:5f:63:b3:4b:1f:70:29:4f:16:92:0e:
                      7b:a0:16:31:2e:8c:8f:35:ee:ff:ce:b9:0b:db:15:
                      65:77:b7:56:01:15:12:86:6e:75:4b:95:bb:9a:31:
                      be:ef:63:a1:85:54:b6:91:73:a1:5a:bc:07:3d:ac:
                      9d:f3:50:f5:a3:62:a7:fb:04:da:7d:49:3b:2d:b2:
                      0f:57:53:d3:a0:ac:5c:01:70:f7:14:4e:a9:9c:1a:
                      29:6c:1d:ce:10:e2:bd:4b:88:af:ed:38:ce:a4:e0:
                      4f:b1:cf:61:ba:c9:28:5c:0a:71:2e:99:a4:52:97:
                      d9:d4:ae:ba:44:0f:78:ac:3e:d5:f9:87:f8:24:0d:
                      b2:45:46:c4:d1:99:77:a5:6b:cd:60:01:94:fb:e2:
                      f5:3c:f1:46:31:b6:18:93:c1:d3:45:4b:ce:d4:4d:
                      ad:98:3a:e7:c3:be:16:90:dc:8e:f4:2c:1e:4b:71:
                      be:73:c3:97:28:3b:f0:28:63:2a:90:60:d9:b6:c0:
                      eb:dc:3e:76:fc:62:3b:8c:2a:78:2b:d9:be:41:00:
                      59:40:43:91:a0:a6:ca:ee:cd:c0:b9:ae:51:c7:07:
                      4f:c2:a4:00:e9:41:be:1b:b0:e3:56:8d:24:a7:42:
                      3b:4f
                  Exponent: 65537 (0x10001)
      Signature Algorithm: sha256WithRSAEncryption
           4c:20:59:24:c0:49:cc:8a:36:bc:fa:88:7e:74:7e:19:29:ec:
           67:20:b1:cd:32:31:5d:bc:ec:97:d6:a5:e7:f3:c3:b0:c5:93:
           f9:61:4c:62:83:63:de:67:3a:1d:07:f1:d4:3e:80:e1:36:66:
           ec:73:51:cc:19:b2:d5:81:64:ea:4f:9d:6f:c5:ad:e8:f2:3f:
           53:5c:ce:31:58:21:a3:b1:e7:15:8d:21:ba:61:e3:fc:ce:df:
           45:96:81:5c:0d:4a:75:cb:5c:4a:66:d0:6e:26:e4:ec:0f:7a:
           72:47:64:3d:92:01:36:10:5f:b4:59:5d:d8:77:1c:1c:6f:21:
           1d:95:e2:a2:f8:cb:4d:08:06:be:c2:ee:3e:c8:42:ba:ff:47:
           85:e7:41:da:a2:ec:8a:80:83:3a:85:d5:4d:e4:93:fe:cf:2d:
           18:c0:dc:60:1a:6f:ba:56:c4:e3:8b:42:37:61:6d:3c:c5:28:
           b7:bf:e1:4b:65:e0:73:5e:f9:e6:07:f6:14:60:57:61:cc:06:
           0f:13:62:1a:17:02:02:9b:5c:aa:6a:12:d3:11:36:eb:0e:a1:
           04:5e:6e:67:d6:a3:05:0c:29:3b:da:a9:15:91:6b:14:83:31:
           a0:2f:27:7b:02:8a:ba:55:eb:42:9b:44:21:6d:8f:c3:f8:53:
           b3:3f:40:db
  ```
  
- 验证证书 955.wlb.pem 的数字签名有效性
  
  证书签发机构 CA 在签名证书时，实际上是先用哈希算法计算证书内容的摘要信息（digest message），然后再利用公钥加密系统的私钥对摘要信息加密，并将摘要信息的密文嵌入到证书中。所以，要校验由 CA 签发的证书的签名信息，只需要 CA 的公钥，证书的签名信息以及摘要算法。

  - 提取签发机构 CA (995.icu)的公钥

    ```sh
    # extract the Issuer's Public Key
    openssl x509 \
        -in 996.icu.pem\
        -noout \
        -pubkey \
        > 996.icu.pubkey
    ```

  - 查看证书（955.wlb）的数字签名和哈希算法

    ```sh
    # show the signature and cryptographic hash algorithm (SHA-256)
    # and the encryption algorithm (RSA)
    openssl x509 \
        -in 955.wlb.pem \
        -text \
        -noout \
        -certopt ca_default \
        -certopt no_validity \
        -certopt no_serial \
        -certopt no_subject \
        -certopt no_extensions \
        -certopt no_signame
    ```

    ```none
    Signature Algorithm: sha256WithRSAEncryption
         4c:20:59:24:c0:49:cc:8a:36:bc:fa:88:7e:74:7e:19:29:ec:
         67:20:b1:cd:32:31:5d:bc:ec:97:d6:a5:e7:f3:c3:b0:c5:93:
         f9:61:4c:62:83:63:de:67:3a:1d:07:f1:d4:3e:80:e1:36:66:
         ec:73:51:cc:19:b2:d5:81:64:ea:4f:9d:6f:c5:ad:e8:f2:3f:
         53:5c:ce:31:58:21:a3:b1:e7:15:8d:21:ba:61:e3:fc:ce:df:
         45:96:81:5c:0d:4a:75:cb:5c:4a:66:d0:6e:26:e4:ec:0f:7a:
         72:47:64:3d:92:01:36:10:5f:b4:59:5d:d8:77:1c:1c:6f:21:
         1d:95:e2:a2:f8:cb:4d:08:06:be:c2:ee:3e:c8:42:ba:ff:47:
         85:e7:41:da:a2:ec:8a:80:83:3a:85:d5:4d:e4:93:fe:cf:2d:
         18:c0:dc:60:1a:6f:ba:56:c4:e3:8b:42:37:61:6d:3c:c5:28:
         b7:bf:e1:4b:65:e0:73:5e:f9:e6:07:f6:14:60:57:61:cc:06:
         0f:13:62:1a:17:02:02:9b:5c:aa:6a:12:d3:11:36:eb:0e:a1:
         04:5e:6e:67:d6:a3:05:0c:29:3b:da:a9:15:91:6b:14:83:31:
         a0:2f:27:7b:02:8a:ba:55:eb:42:9b:44:21:6d:8f:c3:f8:53:
         b3:3f:40:db
    ```

  - 提取证书（ 955.wlb）的 16 进制编码的签名并转换为二进制编码格式

    ```sh
    openssl x509 \
        -in 955.wlb.pem \
        -text \
        -noout \
        -certopt ca_default \
        -certopt no_validity \
        -certopt no_serial \
        -certopt no_subject \
        -certopt no_extensions \
        -certopt no_signame | \
        grep -v 'Signature Algorithm' | \
        tr -d '[:space:]:' | \
        xxd -r -p > 955.wlb.cert-sig.bin
    ```

  - 解密（RSA）证书（955.wlb）的数字签名

    ```sh
    # decrypty the Signature (RSA)
    openssl rsautl \
        -verify \
        -inkey 996.icu.pubkey \
        -in 955.wlb.cert-sig.bin \
        -pubin > 955.wlb.cert-sig-decrypted.bin
    ```

  -  查看解密后签名摘要信息

    ```sh
    # view the decrypted signature hash (digest)
    openssl asn1parse \
        -inform der \
        -in 955.wlb.cert-sig-decrypted.bin
    ```
    
    ```none
        0:d=0  hl=2 l=  49 cons: SEQUENCE          
        2:d=1  hl=2 l=  13 cons: SEQUENCE          
        4:d=2  hl=2 l=   9 prim: OBJECT            :sha256
       15:d=2  hl=2 l=   0 prim: NULL              
       17:d=1  hl=2 l=  32 prim: OCTET STRING      [HEX DUMP]:2536D931BEDD00FA1F586352FF0C6282EA1BF710561A2DE1EA64B64ABA6B0F91
    ```

    ```sh
    # print only the digest
    openssl asn1parse \
        -inform der \
        -in 955.wlb.cert-sig-decrypted.bin | \
        grep 'DUMP' | \
        cut -d ':' -f4 | \
        tr A-Z a-z
    ```

    ```none
    2536d931bedd00fa1f586352ff0c6282ea1bf710561a2de1ea64b64aba6b0f91
    ```

  - 计算原始的证书的摘要信息（和上面的摘要匹配）

    ```sh
    # extract the certifcate body and compute the hash (digest)
    openssl asn1parse \
        -in 955.wlb.pem \
        -strparse 4 \
        -noout \
        -out - | \
        openssl dgst \
        -sha256 -
    ```

    ```none
    (stdin)= 2536d931bedd00fa1f586352ff0c6282ea1bf710561a2de1ea64b64aba6b0f91
    ```

### References

- https://en.wikipedia.org/wiki/Cryptosystem
- https://en.wikipedia.org/wiki/Symmetric-key\_algorithm
- https://en.wikipedia.org/wiki/Public-key\_cryptography
- https://en.wikipedia.org/wiki/RSA_(cryptosystem)
- https://en.wikipedia.org/wiki/Certificate_signing_request
- https://en.wikipedia.org/wiki/X.509
- https://en.wikipedia.org/wiki/OpenSSL
- https://linuxctl.com/2017/02/x509-certificate-manual-signature-verification/
