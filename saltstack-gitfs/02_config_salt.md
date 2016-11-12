配置 gitfs
=========

        如下操作在master/syndic节点执行。

## 1. 安装依赖
```
unzip GitPython.zip 
cd GitPython;yum -y install *.rpm
```

## 2. 配置 saltstack
        修改 /etc/salt/master 添加如下配置。
```
fileserver_backend:
  - git
  - roots

gitfs_remotes:
  - git@30.16.226.110:salt/salt-formula.git
  - git@30.4.226.57:salt/salt-formula.git

```

## 3. 添加 public key
        在主 gitlab 页面添加 master/syndic 的 public key。
        如果不存在 public key ，按照如下步骤生成 public key。
```
[root@CNLF041518 ~]# ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
78:f5:3c:1d:82:18:59:a3:4a:99:21:e0:e5:64:6b:6c root@CNLF041518
The key's randomart image is:
+--[ RSA 2048]----+
|  ..= . .oo      |
| . * o +.+ o     |
|  . E + o o . .  |
|   o . o . o o . |
|      o S   + .  |
|       .     .   |
|                 |
|                 |
|                 |
+-----------------+
[root@CNLF041518 ~]# cat .ssh/id_rsa.pub 
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAnRuiz0OUa25nGry4DQu2vx9z2O8adb32Gu0l9WbW9TMWyejo9lpto12ijPnEF+gMq1bWJs6mKumRO57sprbdnAifnrto95rk5C2n/LMmbn7xSyFRxt57lUeI+CAiMKyKKUg7IR0mYaEmm/QJb8KnQ9a7DIASXyTE3qVHvyLy2g4heqQ3S9rOVntaN5GiuziOd4pUqYd7URdWngOgduyfisq562BUEGboPPiph13EwVx/yvBZ16YZ2rdNLleiTHGHzGYSla2WFdo4yarYtgOsvLyeCIMfx6R1vFb1XPzpOtxXbshsFqSTkVeyRb3MHEbQEps9lmNJNGLjvmp9nT6bFw== root@CNLF041518
[root@CNLF041518 ~]#
```

## 4. 重启 salt-master
```
service salt-master restart
```

## 5. 验证
        在 master/syndic 节点执行如下命令，如果结果显示远程仓库的文件则 gitfs 配置成功。
```
salt-run fileserver.file_list
```

## 6. 异常处理
### 6.1 Host key verification failed

#### 【现象】

        /var/log/salt/master 日志中出现如下信息
```
2016-11-04 17:01:30,857 [salt.utils.gitfs                                     ][ERROR   ][113884] Exception 'len([]) != len(['Host key verification failed.', ''])' caught while fetching gitfs remote 'git@30.16.226.110:salt/salt-formula.git'
2016-11-04 17:01:31,186 [salt.utils.gitfs                                     ][ERROR   ][113884] Exception 'len([]) != len(['Host key verification failed.', ''])' caught while fetching gitfs remote 'git@30.4.226.57:salt/salt-formula.git'
```
#### 【解决方法】
        把日志出现的异常 repository 都手动 clone 一次，使 git 访问正常就可以了。 
```
cd /tmp/

# 输入 yes
git clone git@30.16.226.110:salt/salt-formula.git
rm -rf salt-formula/

git clone git@30.4.226.57:salt/salt-formula.git 
rm -rf salt-formula/
```