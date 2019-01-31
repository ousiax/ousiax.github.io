---
layout: post
title: Public-key cryptography and X509
date: 2019-01-31 14:31:20 +0800
categories: ['Cryptography']
tags: ['cryptography', 'x509', 'openssl']
---

- TOC
{:toc}

- - -

## 1. Cryptosystem

In cryptography, a **cryptosystem** is a suite of cryptographic algorithms needed to implement a particular security service, most commonly for achieving confidentiality (encryption).

Typically, a cryptosystem consists of three algorithms: one for [key generation](https://en.wikipedia.org/wiki/Key_generation), one for encryption, and one for decryption. The term *cipher* (sometimes *cypher*) is often used to refer to a pair of algorithms, one for encryption and one for decryption. Therefore, the term *cryptosystem* is most often used when the key generation algorithm is important. For this reason, the term *cryptosystem* is commonly used to refer to [public key](https://en.wikipedia.org/wiki/Public_key_cryptography) techniques; however both "cipher" and "cryptosystem" are used for [symmetric key](https://en.wikipedia.org/wiki/Symmetric-key_algorithm) techniques. 

### 1.1. Public-key cryptography 

**Public-key cryptography**, or **asymmetric cryptography**, is a cryptographic system that uses pairs of [keys](https://en.wikipedia.org/wiki/Cryptographic_key): *public keys* which may be disseminated widely, and *private keys* which are known only to the owner. The generation of such keys depends on cryptographic algorithms based on mathematical problems to produce one-way functions. Effective security only requires keeping the private key private; the public key can be openly distributed without compromising security.

In such a system, any person can encrypt a message using the receiver's *public key*, but that encrypted message can only be decrypted with the receiver's *private key*. 

### 1.2. RSA

**RSA (Rivest–Shamir–Adleman)** is one of the first [public-key cryptosystems](https://en.wikipedia.org/wiki/Public-key_cryptography) and is widely used for secure data transmission. In such a [cryptosystem](https://en.wikipedia.org/wiki/Cryptosystem), the [encryption key](https://en.wikipedia.org/wiki/Encryption_key) is public and it is different from the [decryption key](https://en.wikipedia.org/wiki/Decryption_key) which is kept secret (private). The acronym RSA is made of the initial letters of the surnames of Ron Rivest, Adi Shamir, and Leonard Adleman, who first publicly described the algorithm in 1978. 

RSA is a relatively slow algorithm, and because of this, it is less commonly used to directly encrypt user data. More often, RSA passes encrypted shared keys for [symmetric key](https://en.wikipedia.org/wiki/Symmetric-key_algorithm) cryptography which in turn can perform bulk encryption-decryption operations at much higher speed. 

### 1.3. Symmetric-key algorithm

**Symmetric-key algorithms** are algorithms for cryptography that use the same [cryptographic keys](https://en.wikipedia.org/wiki/Key_(cryptography)) for both encryption of [plaintext](https://en.wikipedia.org/wiki/Plaintext) and decryption of [ciphertext](https://en.wikipedia.org/wiki/Ciphertext). The keys may be identical or there may be a simple transformation to go between the two keys. The keys, in practice, represent a [shared secret](https://en.wikipedia.org/wiki/Shared_secret) between two or more parties that can be used to maintain a private information link. This requirement that both parties have access to the secret key is one of the main drawbacks of symmetric key encryption, in comparison to [public-key encryption](https://en.wikipedia.org/wiki/Public_key_encryption) (also known as asymmetric key encryption).

### 1.4. Public key certificate

In [cryptography](https://en.wikipedia.org/wiki/Cryptography), a **public key certificate**, also known as a **digital certificate** or **identity certificate**, is an electronic document used to prove the ownership of a [public key](https://en.wikipedia.org/wiki/Key_authentication). The certificate includes information about the key, information about the identity of its owner (called the subject), and the [digital signature](https://en.wikipedia.org/wiki/Digital_signature) of an entity that has verified the certificate's contents (called the issuer). If the signature is valid, and the software examining the certificate trusts the issuer, then it can use that key to communicate securely with the certificate's subject. In email encryption, code signing, and e-signature systems, a certificate's subject is typically a person or organization. However, in [Transport Layer Security (TLS)](https://en.wikipedia.org/wiki/Transport_Layer_Security) a certificate's subject is typically a computer or other device, though TLS certificates may identify organizations or individuals in addition to their core role in identifying devices. TLS, sometimes called by its older name Secure Sockets Layer (SSL), is notable for being a part of [HTTPS](https://en.wikipedia.org/wiki/HTTPS), a protocol for securely browsing the web.

In a typical [public-key infrastructure](https://en.wikipedia.org/wiki/Public-key_infrastructure) (PKI) scheme, the certificate issuer is a [certificate authority](https://en.wikipedia.org/wiki/Certificate_authority) (CA), usually a company that charges customers to issue certificates for them. By contrast, in a web of trust scheme, individuals sign each other's keys directly, in a format that performs a similar function to a public key certificate.

The most common format for public key certificates is defined by X.509. Because X.509 is very general, the format is further constrained by profiles defined for certain use cases, such as [Public Key Infrastructure (X.509)](https://en.wikipedia.org/wiki/PKIX) as defined in RFC 5280. 

### 1.5. X.509

In [cryptography](https://en.wikipedia.org/wiki/Cryptography), **X.509** is a standard defining the format of [public key certificates](https://en.wikipedia.org/wiki/Public_key_certificate). X.509 certificates are used in many Internet protocols, including [TLS/SSL](https://en.wikipedia.org/wiki/Transport_Layer_Security), which is the basis for HTTPS, the secure protocol for browsing the web. They are also used in offline applications, like [electronic signatures](https://en.wikipedia.org/wiki/Electronic_signature). An X.509 certificate contains a public key and an identity (a hostname, or an organization, or an individual), and is either signed by a [certificate authority](https://en.wikipedia.org/wiki/Certificate_authority) or self-signed. When a certificate is signed by a trusted certificate authority, or validated by other means, someone holding that certificate can rely on the public key it contains to establish secure communications with another party, or validate documents [digitally signed](https://en.wikipedia.org/wiki/Digital_signature) by the corresponding private key. 

#### 1.5.1. Certificate filename extensions

There are several commonly used filename extensions for X.509 certificates. Unfortunately, some of these extensions are also used for other data such as private keys.

 - `.pem` – ([Privacy-enhanced Electronic Mail](https://en.wikipedia.org/wiki/Privacy-enhanced_Electronic_Mail)) [Base64](https://en.wikipedia.org/wiki/Base64) encoded [DER](https://en.wikipedia.org/wiki/Distinguished_Encoding_Rules) certificate, enclosed between "`-----BEGIN CERTIFICATE-----`" and "`-----END CERTIFICATE-----`"
- `.cer`, `.crt`, `.der` – usually in binary [DER](https://en.wikipedia.org/wiki/Distinguished_Encoding_Rules) form, but Base64-encoded certificates are common too (see `.pem` above)

### 1.6. Certificate signing request

In public key infrastructure (PKI) systems, a **certificate signing request** (also **CSR** or **certification request**) is a message sent from an applicant to a [certificate authority](https://en.wikipedia.org/wiki/Certificate_authority) in order to apply for a [digital identity certificate](https://en.wikipedia.org/wiki/Public_key_certificate). It usually contains the public key for which the certificate should be issued, identifying information (such as a domain name) and integrity protection (e.g., a digital signature). The most common format for CSRs is the [PKCS](https://en.wikipedia.org/wiki/PKCS) #10 specification and another is the Signed Public Key and Challenge SPKAC format generated by some web browsers. 

## 2. OpenSSL

**OpenSSL** is a software library for applications that secure communications over computer networks against eavesdropping or need to identify the party at the other end. It is widely used in Internet web servers, serving a majority of all web sites.

OpenSSL contains an open-source implementation of the SSL and TLS protocols. The core library, written in the C programming language, implements basic cryptographic functions and provides various utility functions. Wrappers allowing the use of the OpenSSL library in a variety of computer languages are available.

The OpenSSL Software Foundation (OSF) represents the OpenSSL project in most legal capacities including contributor license agreements, managing donations, and so on. OpenSSL Software Services (OSS) also represents the OpenSSL project, for Support Contracts.

Versions are available for most Unix and Unix-like operating systems (including Solaris, Linux, macOS, QNX, and the various open-source BSD operating systems), OpenVMS and Microsoft Windows. 

### 2.1. Create a self-signed-certificate with OpenSSL

#### 2.1.1. Generate a self signed root certificate

```sh
openssl req -x509 -nodes -newkey rsa:2048 -keyout key.pem -out req.pem -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Global Security/OU=IT Department/CN=example.com"
```

#### 2.1.2. Generate a self signed root certificate from a private key

```sh
# Generate a 2048 bit RSA key (openssl genrsa -out key.pem 2048)
openssl genpkey -algorithm RSA -out key.pem -pkeyopt rsa_keygen_bits:2048
# Generate a certificate request from a private key
openssl req -x509 -new -key key.pem -out req.pem -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Global Security/OU=IT Department/CN=example.com"
```

#### 2.1.3 Display the contents of a certificate:

```sh
openssl x509 -in cert.pem -noout -text
```

*output:*

```none
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            b6:bd:90:ab:2b:f2:ac:55
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = CN, ST = Shanghai, L = Shanghai, O = Global Security, OU = IT Department, CN = example.com
        Validity
            Not Before: Jan 31 08:53:20 2019 GMT
            Not After : Mar  2 08:53:20 2019 GMT
        Subject: C = CN, ST = Shanghai, L = Shanghai, O = Global Security, OU = IT Department, CN = example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:aa:1e:d0:44:1f:50:3f:15:87:90:85:f0:64:e8:
                    5a:5b:41:8a:6a:60:29:a8:ad:13:6b:37:a9:fe:28:
                    5b:fb:a5:33:3e:50:ff:aa:af:2f:77:2b:80:18:a7:
                    f1:0e:b5:b8:c8:43:33:ab:e7:fe:c0:22:ef:c1:e0:
                    15:7d:55:5d:90:65:55:29:23:ef:7c:5c:b7:76:dd:
                    08:6a:9d:11:4a:dd:8b:25:b8:64:e2:20:8e:9b:de:
                    d4:0a:53:8e:00:b8:f5:7a:40:35:82:80:fa:3e:23:
                    1d:5b:d0:6d:b2:d4:2d:26:23:4e:52:cf:cd:d8:26:
                    44:bd:60:8b:3c:b6:a7:b0:21:07:08:f0:cc:1e:62:
                    3a:23:6a:96:d8:43:82:65:7a:f2:d6:93:25:bb:af:
                    03:db:30:26:0d:88:b0:1c:80:fe:c4:7e:48:60:4a:
                    77:99:02:18:14:8c:43:b5:f2:5b:12:d3:50:b8:32:
                    04:7f:e8:3b:e0:40:4c:29:a3:57:66:97:0d:ae:d8:
                    b8:d6:77:3f:84:e5:94:0a:ed:5e:2a:4d:c0:77:d0:
                    2d:70:5b:3d:ee:88:17:11:a3:3b:c4:af:5b:78:df:
                    64:c0:1f:76:11:29:2b:66:f4:e2:e0:54:58:6d:72:
                    43:74:51:56:1d:96:b5:ab:fe:12:af:2b:86:a7:eb:
                    97:a3
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                7D:64:0D:68:8D:5A:EA:8D:E3:7D:D1:04:06:8F:63:D0:3E:EB:2C:9F
            X509v3 Authority Key Identifier: 
                keyid:7D:64:0D:68:8D:5A:EA:8D:E3:7D:D1:04:06:8F:63:D0:3E:EB:2C:9F

            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
         7a:f3:91:f2:01:cc:59:f0:62:7d:76:e4:48:05:0e:f2:9d:9e:
         86:2a:27:fa:b6:00:7b:9c:d7:e1:f4:7f:9e:b3:48:5f:d4:32:
         cf:1e:a5:64:ff:95:0a:47:88:e5:1a:5c:32:46:ac:a2:a4:fc:
         a6:ed:fc:15:d0:07:f6:0e:fb:86:35:39:2d:f3:56:c1:a2:4a:
         c5:e5:aa:0d:17:fa:76:d6:42:89:09:a6:b7:9f:7a:da:d3:6f:
         b3:9a:a9:28:7e:2a:15:71:6c:27:82:b9:79:7a:74:3d:40:b9:
         56:5d:b3:61:32:2a:79:e3:d9:15:09:09:72:9e:ad:1d:3f:ab:
         33:dc:99:a3:c9:94:0b:0b:98:f9:d6:d1:29:33:fb:dd:39:ed:
         9a:16:81:85:33:60:40:d1:f8:18:1d:d4:c6:a1:31:9c:f4:aa:
         04:9a:7a:71:e4:8d:78:7d:64:ef:f8:6a:a8:f8:5b:bd:5a:c2:
         3f:39:a5:de:06:ea:55:47:18:fe:b3:67:e7:2e:92:6f:e3:1a:
         18:a0:bb:a9:20:e3:4d:1a:77:26:a9:ca:49:5b:f1:b5:55:aa:
         c3:26:74:f7:09:fb:10:23:16:38:f5:ba:7c:f3:95:92:4b:fd:
         a7:6d:90:d3:6b:4f:26:d7:d4:a8:87:9e:d1:3c:9f:87:e6:3f:
         35:9c:d9:1e
```

### 2.1. Sign a certificate request using a CA certificate

```sh
# Generate a self signed root certificate
openssl req -x509 -nodes -newkey rsa:2048 -keyout ca.key -out ca.crt -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Global Security/OU=IT Department/CN=example.com"
# Generate a certificate request
openssl req -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr  -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Global Security/OU=IT Department/CN=localhost"
# Display the contents of the certificate request
openssl req -in localhost.csr -noout -text
# Sign a certificate request using the CA certificate above
openssl x509 -req -in localhost.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out localhost.crt -days 10000
# Display the contents of the certificate
openssl x509 -in localhost.crt -noout -text
```

```none
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number:
            f6:08:96:a5:05:1c:88:c7
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = CN, ST = Shanghai, L = Shanghai, O = Global Security, OU = IT Department, CN = example.com
        Validity
            Not Before: Jan 31 09:41:49 2019 GMT
            Not After : Jun 18 09:41:49 2046 GMT
        Subject: C = CN, ST = Shanghai, L = Shanghai, O = Global Security, OU = IT Department, CN = localhost
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:d6:6a:f8:4f:b3:c5:2f:6a:f4:50:bf:50:5b:e8:
                    4a:d3:20:02:0d:82:b5:e1:ee:94:50:5d:64:4b:1a:
                    67:4e:19:0a:a8:21:24:94:e9:0d:38:e7:ae:54:f1:
                    1e:4f:85:b0:02:2a:d4:0f:76:1b:f6:92:ba:0d:ea:
                    40:2e:96:d5:e2:db:1b:8f:79:07:61:91:df:af:ce:
                    68:4d:11:56:53:bd:9b:6d:3a:72:34:dc:1c:84:9f:
                    dc:83:9c:7c:b8:76:9c:f9:15:99:8b:f5:e8:23:30:
                    d5:45:a0:d1:55:50:67:09:7e:f0:c5:59:1b:0e:8e:
                    55:3c:97:41:42:3e:12:c5:91:ce:7b:3e:c8:fe:33:
                    c5:4a:a9:55:57:a8:af:ed:06:10:d2:7c:f4:c2:55:
                    c9:23:57:23:d7:1f:cc:da:66:9f:29:8e:c1:f7:a8:
                    73:01:63:21:07:ee:69:6b:f4:de:0c:86:fc:e9:a5:
                    32:33:b4:28:e5:a5:0b:79:8b:7a:fe:0c:aa:5d:4e:
                    57:bb:e9:4c:f9:99:1b:e2:83:ba:1a:68:6e:9e:63:
                    a1:2d:e2:11:62:71:10:63:ab:88:29:ee:c4:73:97:
                    0a:ae:11:78:99:b8:a7:b3:14:e6:b4:1c:d6:02:a6:
                    bb:3a:12:15:05:b0:c7:b8:eb:d5:65:be:28:f2:fe:
                    89:45
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         d6:b9:8c:a1:35:3c:db:b8:24:bd:be:57:f2:a5:de:5f:90:27:
         d5:d4:5f:ba:44:dd:b3:40:36:1a:b3:8f:3b:b4:81:18:96:16:
         16:fe:7b:bf:9a:4f:1b:46:fb:38:a8:89:64:4c:e4:64:50:5f:
         b9:12:bc:cf:81:7e:ec:2d:4f:56:5c:9b:56:7a:39:08:c8:a8:
         b8:8c:f5:52:52:a7:ba:d0:e6:06:15:d9:bf:c1:25:57:0f:cc:
         c2:43:b6:ed:6a:67:e8:35:a8:1c:16:13:29:74:f6:5d:89:ce:
         f3:b8:22:18:bc:51:9b:94:4f:4c:4a:e1:3b:fe:67:f7:2c:89:
         44:a9:81:12:28:46:1e:d0:80:76:7e:c2:c8:e5:07:0a:0d:2a:
         eb:22:5a:59:dc:83:f5:80:56:04:b8:7f:53:1c:17:57:97:98:
         52:c6:42:d3:44:e7:a9:cd:26:b1:14:d9:89:c6:af:75:e5:0d:
         4b:7a:b3:76:2c:9a:3a:9c:c1:dc:17:17:f1:27:c8:68:b3:b0:
         2c:a9:c7:bf:17:29:db:50:5f:25:7c:a2:06:b2:42:41:58:8f:
         7c:ee:87:94:5b:35:79:44:85:bc:5b:74:ca:6d:5d:69:8e:b3:
         e6:e0:02:7c:a6:c1:67:90:52:db:d8:9d:e5:fa:f0:fe:a8:db:
         2c:3d:bc:fd
```

### References

1. Cryptosystem, [https://en.wikipedia.org/wiki/Cryptosystem](https://en.wikipedia.org/wiki/Cryptosystem)
1. Public-key cryptography, [https://en.wikipedia.org/wiki/Public-key\_cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography)
1. RSA (cryptosystem), [https://en.wikipedia.org/wiki/RSA\_(cryptosystem)](https://en.wikipedia.org/wiki/RSA_(cryptosystem))
1. Symmetric-key algorithm, [https://en.wikipedia.org/wiki/Symmetric-key\_algorithm](https://en.wikipedia.org/wiki/Symmetric-key_algorithm)
1. X.509, [https://en.wikipedia.org/wiki/X.509](https://en.wikipedia.org/wiki/X.509)
1. Certificate signing request, [https://en.wikipedia.org/wiki/Certificate\_signing\_request](https://en.wikipedia.org/wiki/Certificate_signing_request)
1. OpenSSL, [https://en.wikipedia.org/wiki/OpenSSL](https://en.wikipedia.org/wiki/OpenSSL)
1. [https://crypto.stackexchange.com/questions/43697/what-is-the-difference-between-pem-csr-key-and-crt](https://crypto.stackexchange.com/questions/43697/what-is-the-difference-between-pem-csr-key-and-crt)
1. [https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file](https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file)
1. [https://www.shellhacks.com/create-csr-openssl-without-prompt-non-interactive/](https://www.shellhacks.com/create-csr-openssl-without-prompt-non-interactive/)
