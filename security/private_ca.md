创建私有CA及签发证书
=================

        本文通过使用 openssl 创建私有 CA 和签发证书，加深对证书原理的理解。

# 术语
* csr - Certificate Signing Request
* pki - Public Key Infrastructure
* CA  - Certificate Authority

# 知识点
* 创建私有 CA
* 用户生成 CSR
* CA 签发证书
* CA 吊销证书

## 1. 创建私有 CA

### 1.1 创建目录/文件
        根据 openssl 的配置文件（/etc/pki/tls/openssl.cnf）创建相关目录/文件。
```        
[root@SZB-L0009803 CA]# pwd
/etc/pki/CA
[root@SZB-L0009803 CA]# ls
certs  crl  newcerts  private
[root@SZB-L0009803 CA]# 

# database index file.
[root@SZB-L0009803 CA]# touch index.txt
[root@SZB-L0009803 CA]# ll
total 16
drwxr-xr-x. 2 root root 4096 Oct 17  2014 certs
drwxr-xr-x. 2 root root 4096 Oct 17  2014 crl
-rw-r--r--  1 root root    0 Oct  6 17:29 index.txt
drwxr-xr-x. 2 root root 4096 Oct 17  2014 newcerts
drwx------. 2 root root 4096 Oct 17  2014 private
[root@SZB-L0009803 CA]#

 # The current serial number
[root@SZB-L0009803 CA]# echo 01 > serial
[root@SZB-L0009803 CA]# ll
total 20
drwxr-xr-x. 2 root root 4096 Oct 17  2014 certs
drwxr-xr-x. 2 root root 4096 Oct 17  2014 crl
-rw-r--r--  1 root root    0 Oct  6 17:29 index.txt
drwxr-xr-x. 2 root root 4096 Oct 17  2014 newcerts
drwx------. 2 root root 4096 Oct 17  2014 private
-rw-r--r--  1 root root    3 Oct  6 17:30 serial
[root@SZB-L0009803 CA]# 
```
### 1.2 生成 CA 私钥
        根据证书的原理，需要先生成私钥，然后从私钥中抽取公钥，再将公钥封装成证书。

```
[root@SZB-L0009803 CA]# ls -l private/
total 0
[root@SZB-L0009803 CA]# 
[root@SZB-L0009803 CA]# (umask 077; openssl genrsa -out private/cakey.pem 2048) 
Generating RSA private key, 2048 bit long modulus
..........................+++
.....................+++
e is 65537 (0x10001)
[root@SZB-L0009803 CA]# 
[root@SZB-L0009803 CA]# ls -l private/
total 4
-rw------- 1 root root 1679 Oct  6 17:32 cakey.pem
[root@SZB-L0009803 CA]# 
```
### 1.3 生成 CA 证书

    相关选项
        req: The req command primarily creates and processes certificate requests in PKCS#10 format. It can
             additionally create self signed certificates for use as root CAs for example.
        -new: 生成新证书签署请求；                  
        -x509: 专用于CA生成自签证书；               
        -key: 生成请求时用到的私钥文件；            
        -days n：证书的有效期限（天）；                   
        -out /PATH/TO/SOMECERTFILE: 证书的保存路径；

```
[root@SZB-L0009803 CA]# openssl req -new -x509 -key private/cakey.pem -days 7300 -out cacert.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:GuangDong
Locality Name (eg, city) [Default City]:Shenzhen
Organization Name (eg, company) [Default Company Ltd]:DBO
Organizational Unit Name (eg, section) []:Ops
Common Name (eg, your name or your server's hostname) []:ca.dbo.com 
Email Address []:caadmin@dbo.com
[root@SZB-L0009803 CA]# 
[root@SZB-L0009803 CA]# ll
total 24
-rw-r--r--  1 root root 1403 Oct  6 17:40 cacert.pem
drwxr-xr-x. 2 root root 4096 Oct 17  2014 certs
drwxr-xr-x. 2 root root 4096 Oct 17  2014 crl
-rw-r--r--  1 root root    0 Oct  6 17:29 index.txt
drwxr-xr-x. 2 root root 4096 Oct 17  2014 newcerts
drwx------. 2 root root 4096 Oct  6 17:32 private
-rw-r--r--  1 root root    3 Oct  6 17:30 serial
[root@SZB-L0009803 CA]# 
```
        至此，CA自签证书已经生成，私有 CA 已经创建完成，具备了签发证书的能力。将此证书导入到客户端受信任的根证书颁发机构，客户
    端就可以信任该 CA 颁发的证书。

## 2. CA 签发证书
        接下来我们模拟用户申请证书，CA 签发证书的过程。
### 2.1 用户生成 csr
        用户申请证书就像我们申请身份证一样，需要提交一份材料（csr），所以需要先生成 csr 文件，然后提交 csr 文件，CA 验证通过
    后，再签发证书给申请人。
        如下假设公司网站的 httpd 服务提供 HTTPS 服务，以 httpd 生成证书请求为例。
        注：实际中 CA 可签发用于各种服务器的证书，比如 nginx、tomcat、weblogic、硬件 F5 等。
#### 2.1.1 生成私钥
        生成证书私钥文件。
```
[root@SZB-L0009803 CA]# cd /etc/httpd/
[root@SZB-L0009803 httpd]# mkdir ssl
[root@SZB-L0009803 httpd]# cd ssl/
[root@SZB-L0009803 ssl]# 
[root@SZB-L0009803 ssl]# (umask 077; openssl genrsa -out httpd.key 2048)
Generating RSA private key, 2048 bit long modulus
...............+++
.+++
e is 65537 (0x10001)
[root@SZB-L0009803 ssl]# ll
total 4
-rw------- 1 root root 1679 Oct  6 17:52 httpd.key
[root@SZB-L0009803 ssl]# 
```

#### 2.1.2 生成证书请求
        根据私钥生成证书签署请求，即 csr 文件。
        由于这里是私有 CA ，因此申请证书的机构和 CA 机构是一个组织，即生成 crs 文件需要的组织信息和 CA 相同。
```
[root@SZB-L0009803 ssl]# openssl req -new -key httpd.key -days 365 -out httpd.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:GuangDong
Locality Name (eg, city) [Default City]:Shenzhen
Organization Name (eg, company) [Default Company Ltd]:DBO
Organizational Unit Name (eg, section) []:Ops
Common Name (eg, your name or your server's hostname) []:www.dbo.com
Email Address []:webadmin@dbo.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@SZB-L0009803 ssl]# 
[root@SZB-L0009803 ssl]# ll
total 8
-rw-r--r-- 1 root root 1050 Oct  6 17:55 httpd.csr
-rw------- 1 root root 1679 Oct  6 17:52 httpd.key
[root@SZB-L0009803 ssl]#
```
### 2.2 提交证书请求
        这里模拟给 CA 机构提交证书请求，直接将请求文件 cp 到 /tmp 目录。
```
[root@SZB-L0009803 ssl]# cp httpd.csr /tmp/
[root@SZB-L0009803 ssl]# 
[root@SZB-L0009803 ssl]# 
[root@SZB-L0009803 ssl]# ls -l /tmp
total 16
drwxr-xr-x  2 root root 4096 Sep 30  2015 hsperfdata_root
-rw-r--r--  1 root root 1050 Oct  6 17:55 httpd.csr
drwx------. 2 root root 4096 Mar  9  2015 pulse-Spog04rIKYWx
-rw-------  1 root root  235 Sep 27 19:55 sysstat
[root@SZB-L0009803 ssl]#
```
### 2.3 签发证书
        CA 收到证书请求后，会检查相关组织信息是否属实等，如果检查没有问题，就可以签发证书了。
```
[root@SZB-L0009803 ssl]# cd /etc/pki/CA
[root@SZB-L0009803 CA]# 
[root@SZB-L0009803 CA]# openssl ca -in /tmp/httpd.csr -out certs/httpd.crt
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Oct  6 09:57:20 2016 GMT
            Not After : Oct  6 09:57:20 2017 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = GuangDong
            organizationName          = DBO
            organizationalUnitName    = Ops
            commonName                = www.dbo.com
            emailAddress              = webadmin@dbo.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                69:15:0F:D4:12:38:08:A3:D3:E5:B0:C6:CF:E9:29:41:CD:C7:57:8C
            X509v3 Authority Key Identifier: 
                keyid:C1:6F:A6:22:40:33:FB:B6:97:9F:E9:16:FB:49:16:AF:52:CD:29:19

Certificate is to be certified until Oct  6 09:57:20 2017 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
[root@SZB-L0009803 CA]#

# 确认证书已经在指定目录生成
[root@SZB-L0009803 CA]# ls -l certs/
total 8
-rw-r--r-- 1 root root 4588 Oct  6 17:58 httpd.crt
[root@SZB-L0009803 CA]# 

# 查看数据文件，已经生成新记录
[root@SZB-L0009803 CA]# cat index.txt
V       171006095720Z           01      unknown /C=CN/ST=GuangDong/O=DBO/OU=Ops/CN=www.dbo.com/emailAddress=webadmin@dbo.com
[root@SZB-L0009803 CA]#

# 证书会先在 newcerts 目录生成
[root@SZB-L0009803 CA]# ls newcerts/
01.pem
[root@SZB-L0009803 CA]#
```
        接下来 CA 可以将证书发给申请证书的用户了。

### 2.4 查看证书信息
        openssl 可以查看证书相关信息。
        命令：openssl x509 -in /PATH/FROM/CERT_FILE -noout -text|-subject|-serial
```
[root@SZB-L0009803 CA]# openssl x509 -in /etc/httpd/ssl/httpd.crt -noout -text  
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=CN, ST=GuangDong, L=Shenzhen, O=DBO, OU=Ops, CN=ca.dbo.com/emailAddress=caadmin@dbo.com
        Validity
            Not Before: Oct  6 09:57:20 2016 GMT
            Not After : Oct  6 09:57:20 2017 GMT
        Subject: C=CN, ST=GuangDong, O=DBO, OU=Ops, CN=www.dbo.com/emailAddress=webadmin@dbo.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:cb:d8:4d:13:83:f8:c6:0f:05:11:ec:a4:8e:90:
                    d7:ec:12:a8:4b:08:e4:53:af:65:10:4a:a8:12:ac:
                    b7:5a:99:b8:86:78:af:0d:b6:80:11:37:7b:7e:fb:
                    92:34:65:b8:e0:49:4b:ec:03:12:60:6b:ee:06:43:
                    21:cb:99:15:08:3a:89:27:f5:97:ff:82:a2:bf:cf:
                    7a:5e:04:14:5f:47:61:59:f0:8e:39:f2:95:8a:7d:
                    09:ef:e1:d7:00:8b:1d:50:cf:a6:bc:db:d4:ec:f4:
                    ec:d2:69:1a:8a:57:d3:5d:05:a4:a7:c1:36:34:7f:
                    90:7c:3e:4c:43:8d:69:99:87:9b:f8:0e:dc:c4:78:
                    59:3c:ba:f6:98:11:18:6e:38:0c:4d:f0:f2:73:86:
                    9f:ab:8d:f4:69:24:14:e0:9b:81:ed:ec:cf:ec:e6:
                    ef:00:fc:b9:a3:c3:bb:3b:6e:64:88:00:ea:51:bd:
                    d4:78:53:a3:8b:fc:92:97:4c:7b:5d:19:17:a4:db:
                    d5:41:42:30:6f:f9:96:a6:cf:24:92:06:14:75:ce:
                    05:00:8c:3b:23:bb:fe:b1:8a:28:ab:7d:53:45:fe:
                    0f:4e:93:58:1d:1f:90:32:7c:72:8f:50:b5:90:dc:
                    37:88:95:7d:30:40:7b:9b:87:fb:bb:6e:6a:fd:53:
                    69:ef
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                69:15:0F:D4:12:38:08:A3:D3:E5:B0:C6:CF:E9:29:41:CD:C7:57:8C
            X509v3 Authority Key Identifier: 
                keyid:C1:6F:A6:22:40:33:FB:B6:97:9F:E9:16:FB:49:16:AF:52:CD:29:19

    Signature Algorithm: sha1WithRSAEncryption
         4b:74:5b:48:e8:d5:9c:10:06:a3:a5:91:b4:75:b9:69:99:79:
         6e:5f:b8:8c:3c:83:56:d1:b1:53:a5:81:80:b3:9c:52:70:87:
         b2:61:e5:64:60:ac:6c:1d:d8:05:0b:94:4b:09:63:30:41:7f:
         f3:26:e4:c1:0a:49:2d:21:c8:a4:3e:cb:6f:6e:7b:b3:3f:39:
         16:1f:b9:b2:7f:99:34:ef:b9:8b:3c:e1:31:b6:19:40:99:6f:
         7d:10:2a:53:8f:ae:98:b3:d1:88:43:3f:cd:a8:4b:85:46:a0:
         fa:a4:2d:16:99:b2:24:09:3d:41:76:b8:d1:bd:b0:63:06:31:
         25:d2:aa:5c:24:e4:5c:b2:69:ff:cd:ca:60:43:a2:95:0f:56:
         ba:3a:9a:be:60:bc:56:2a:9e:14:9f:f9:84:bb:8d:77:b2:6c:
         ef:52:12:13:c5:5e:2d:bf:e6:cf:57:b4:17:e3:df:ed:b8:f3:
         d4:ce:31:6c:ab:e4:5e:e6:ab:97:f6:f7:fa:39:a8:37:a6:38:
         52:aa:47:3e:70:a9:25:8f:08:94:35:f8:7b:c0:a9:87:ef:58:
         31:b5:b2:b1:1e:cf:4f:6c:c9:a7:c8:30:42:db:0d:d7:68:0c:
         78:08:3d:eb:67:ca:76:10:92:12:66:74:21:10:50:71:68:22:
         e7:a0:94:0a
[root@SZB-L0009803 CA]# 
```
## 3. 吊销证书
        模拟吊销证书的步骤。

### 3.1 获取待吊销证书的序列号
        客户端查看证书序列号，发给 CA 机构申请吊销。
```
[root@SZB-L0009803 CA]# openssl x509 -in /etc/httpd/ssl/httpd.crt -noout -serial -subject
serial=01
subject= /C=CN/ST=GuangDong/O=DBO/OU=Ops/CN=www.dbo.com/emailAddress=webadmin@dbo.com
[root@SZB-L0009803 CA]#
```

### 3.2 吊销证书
        CA 根据客户提交的serial与subject信息，对比检验是否与index.txt文件中的信息一致，确认无误后吊销证书。
```
[root@SZB-L0009803 CA]# openssl ca -revoke /etc/pki/CA/newcerts/01.pem    
Using configuration from /etc/pki/tls/openssl.cnf
Revoking Certificate 01.
Data Base Updated
[root@SZB-L0009803 CA]#
```
### 3.3 更新证书吊销列表
```
# 生成吊销证书的编号(只有 CA 第一次吊销需要操作，后面会自增)
[root@SZB-L0009803 CA]# echo 01 > /etc/pki/CA/crlnumber
[root@SZB-L0009803 CA]# 

# 更新证书吊销列表
[root@SZB-L0009803 CA]# openssl ca -gencrl -out dboca.crl
Using configuration from /etc/pki/tls/openssl.cnf
[root@SZB-L0009803 CA]#
```
### 3.4 查看吊销列表
        可以用 openssl 命令查看证书吊销列表。

```
[root@SZB-L0009803 CA]# openssl crl -in dboca.crl -noout -text
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha1WithRSAEncryption
        Issuer: /C=CN/ST=GuangDong/L=Shenzhen/O=DBO/OU=Ops/CN=ca.dbo.com/emailAddress=caadmin@dbo.com
        Last Update: Oct  6 10:13:32 2016 GMT
        Next Update: Nov  5 10:13:32 2016 GMT
        CRL extensions:
            X509v3 CRL Number: 
                1
Revoked Certificates:
    Serial Number: 01
        Revocation Date: Oct  6 10:11:54 2016 GMT
    Signature Algorithm: sha1WithRSAEncryption
         3d:38:84:e9:b2:6e:94:48:8d:1a:7d:84:50:0d:74:0e:3e:65:
         91:e4:02:a5:19:8e:82:ae:49:91:09:b5:30:0a:b0:70:d1:66:
         49:14:02:85:0a:ba:e3:95:19:e1:7f:a9:98:65:b1:49:04:8c:
         65:1e:34:24:3f:dc:d9:cf:a4:cf:f5:ea:af:6c:74:e7:32:d6:
         fc:06:30:fb:16:29:d9:80:e1:67:2c:74:ad:df:f1:29:79:f5:
         99:97:34:c4:44:81:c6:a4:3d:44:ca:f2:b7:7d:66:b5:a4:7b:
         1e:5b:ff:56:bf:73:96:b6:0f:31:20:a8:0f:8e:3f:f3:33:a9:
         ef:1b:69:0e:ab:78:70:38:cd:fa:d5:b1:e3:19:b0:4e:f7:25:
         81:e1:31:ee:db:f4:7c:f1:c8:a5:48:39:5e:ef:e1:78:4a:4d:
         22:a3:7d:06:8e:98:e7:66:2c:db:c6:97:e0:8a:b2:74:77:30:
         8d:ef:6d:9f:d2:c5:4e:6c:d6:a6:af:e3:58:45:4f:84:a1:40:
         69:9d:db:18:2a:4e:0e:dc:56:82:7a:3c:a5:6f:66:5c:36:a7:
         4f:c5:24:72:a6:e4:a4:11:a6:7f:e8:fd:66:d7:b2:69:b8:5c:
         65:9c:40:03:0d:4d:e1:a0:0c:f8:32:ef:7b:8c:33:e4:16:3d:
         44:cb:a3:e2
[root@SZB-L0009803 CA]# 
```
