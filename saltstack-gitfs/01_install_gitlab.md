
gitlab 安装配置
=============

# 备注
        gitlab-ce-8.9.9-ce.0.el7.x86_64.rpm 这个版本从backups文件restore后，在页面看不到Repository菜单。
        升级到 gitlab-ce-8.9.11-ce.0.el7.x86_64.rpm 正常，升级步骤如下。
```shell
# 主备都需要升级
gitlab-ctl status
gitlab-ctl uninstall
rpm -e gitlab-ce
rpm -i gitlab-ce-8.9.11-ce.0.el7.x86_64.rpm 
```


# 1. gitlab 下载
[RHEL家族 Linux 6.x](https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el6/)

[RHEL家族 Linux 7.x](https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/)


# 2. 安装并启动
## 2.1 安装命令
```shell
rpm -i gitlab-ce-8.9.9-ce.0.el6.x86_64.rpm

vim /etc/gitlab/gitlab.rb
external_url  'http://10.20.19.105'

gitlab-ctl reconfigure
gitlab-ctl status
```

## 2.2 实验过程
```shell
[root@SZB-L0008177 software]# ls -l
total 267292
-rw-r--r-- 1 root root 271539205 Oct 28 16:03 gitlab-ce-8.9.9-ce.0.el6.x86_64.rpm
drwxr-xr-x 9 1001 1001      4096 Jun 24 11:08 nginx-1.10.1
-rw-r--r-- 1 root root    909077 Jun 23 16:51 nginx-1.10.1.tar.gz
drwxr-xr-x 6 1169 1169      4096 Feb  4  2012 pcre-8.30
-rw-r--r-- 1 root root   1248556 Jun 24 11:13 pcre-8.30.tar.bz2
[root@SZB-L0008177 software]# rpm -i gitlab-ce-8.9.9-ce.0.el6.x86_64.rpm 
gitlab: Thank you for installing GitLab!
gitlab: To configure and start GitLab, RUN THE FOLLOWING COMMAND:

sudo gitlab-ctl reconfigure

gitlab: GitLab should be reachable at http://SZB-L0008177
gitlab: Otherwise configure GitLab for your system by editing /etc/gitlab/gitlab.rb file
gitlab: And running reconfigure again.
gitlab: 
gitlab: For a comprehensive list of configuration options please see the Omnibus GitLab readme
gitlab: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md
gitlab: 
It looks like GitLab has not been configured yet; skipping the upgrade script.
[root@SZB-L0008177 software]# rpm -qa|grep -i gitlab
gitlab-ce-8.9.9-ce.0.el6.x86_64
[root@SZB-L0008177 software]# 
[root@SZB-L0008177 software]# gitlab-ctl status
[root@SZB-L0008177 software]#

# 下面这一步会初始化配置并启动 gitlab
# 默认 nginx 会监听 80 端口，确保端口可用
[root@SZB-L0008177 software]# gitlab-ctl reconfigure
...
# 省略过程
...
[root@SZB-L0008177 software]#
[root@SZB-L0008177 software]# gitlab-ctl status
run: gitlab-workhorse: (pid 17611) 14s; run: log: (pid 17396) 70s
run: logrotate: (pid 17416) 62s; run: log: (pid 17415) 62s
run: nginx: (pid 17640) 0s; run: log: (pid 17403) 68s
run: postgresql: (pid 17253) 108s; run: log: (pid 17252) 108s
run: redis: (pid 17170) 124s; run: log: (pid 17169) 124s
run: sidekiq: (pid 17386) 71s; run: log: (pid 17385) 71s
run: unicorn: (pid 17353) 77s; run: log: (pid 17352) 77s
[root@SZB-L0008177 software]#
```

# 3. 登录
        地址：http://10.20.19.105/
        默认用户名和密码：root/5iveL!fe

# 4. 维护
## 4.1 维护命令

* 启动
```shell
gitlab-ctl start
```
* 查看状态
```shell
gitlab-ctl status
```
* 停止
```shell
gitlab-ctl stop
```
* 查看错误
```shell
gitlab-ctl tail
```
* 保存配置
```shell
gitlab-ctl reconfigure
```

## 4.2 实验过程
```shell
[root@SZB-L0008177 software]# gitlab-ctl status
run: gitlab-workhorse: (pid 17611) 215s; run: log: (pid 17396) 271s
run: logrotate: (pid 17416) 263s; run: log: (pid 17415) 263s
run: nginx: (pid 18006) 7s; run: log: (pid 17403) 269s
run: postgresql: (pid 17253) 309s; run: log: (pid 17252) 309s
run: redis: (pid 17170) 325s; run: log: (pid 17169) 325s
run: sidekiq: (pid 17386) 272s; run: log: (pid 17385) 272s
run: unicorn: (pid 17670) 193s; run: log: (pid 17352) 278s
[root@SZB-L0008177 software]# gitlab-ctl stop
ok: down: gitlab-workhorse: 0s, normally up
ok: down: logrotate: 0s, normally up
ok: down: nginx: 1s, normally up
ok: down: postgresql: 0s, normally up
ok: down: redis: 0s, normally up
ok: down: sidekiq: 0s, normally up
ok: down: unicorn: 1s, normally up
[root@SZB-L0008177 software]# 
[root@SZB-L0008177 software]# 
[root@SZB-L0008177 software]# gitlab-ctl start
ok: run: gitlab-workhorse: (pid 18090) 0s
ok: run: logrotate: (pid 18095) 1s
ok: run: nginx: (pid 18101) 0s
ok: run: postgresql: (pid 18107) 1s
ok: run: redis: (pid 18115) 0s
ok: run: sidekiq: (pid 18119) 1s
ok: run: unicorn: (pid 18123) 0s
[root@SZB-L0008177 software]# gitlab-ctl status
run: gitlab-workhorse: (pid 18090) 6s; run: log: (pid 17396) 293s
run: logrotate: (pid 18095) 6s; run: log: (pid 17415) 285s
run: nginx: (pid 18101) 5s; run: log: (pid 17403) 291s
run: postgresql: (pid 18107) 5s; run: log: (pid 17252) 331s
run: redis: (pid 18115) 4s; run: log: (pid 17169) 347s
run: sidekiq: (pid 18119) 4s; run: log: (pid 17385) 294s
run: unicorn: (pid 18123) 3s; run: log: (pid 17352) 300s
[root@SZB-L0008177 software]# 
[root@SZB-L0008177 software]# netstat -anp|grep 80
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN      18101/nginx         
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      1580/sshd           
tcp        0      0 10.20.19.105:55476          10.20.23.180:4505           ESTABLISHED 15867/python2.6     
tcp        0      0 :::22                       :::*                        LISTEN      1580/sshd           
udp        0      0 fe80::489:beff:fe00:189f:123 :::*                                    1588/ntpd           
unix  2      [ ACC ]     STREAM     LISTENING     9056961 18090/gitlab-workho /var/opt/gitlab/gitlab-workhorse/socket
unix  2      [ ACC ]     STREAM     LISTENING     9880   1475/acpid          /var/run/acpid.socket
[root@SZB-L0008177 software]#
```

# 5. 备份
## 5.1 配置步骤

### 5.1.1 创建备份目录
```
mkdir /backups
```

### 5.1.2 设置备份配置
```
vim /etc/gitlab/gitlab.rb
gitlab_rails['backup_path'] = "/backups"
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_keep_time'] = 604800
```

### 5.1.3 使配置生效
```
gitlab-ctl reconfigure
```

### 5.1.4 添加定时任务
```
# backup gitlab
15,20,25,30 11 31 10 * /opt/gitlab/bin/gitlab-rake gitlab:backup:create
```

### 5.1.5 验证
```
cd /backups;date;ls -lh
```

## 5.2 实验过程
```shell
[root@SZB-L0008177 ~]# mkdir /backups
[root@SZB-L0008177 ~]# 
[root@SZB-L0008177 ~]# cd /backups/
[root@SZB-L0008177 backups]# grep "gitlab_rails\['backup_path'\]" /etc/gitlab/gitlab.rb 
gitlab_rails['backup_path'] = "/backups"
[root@SZB-L0008177 backups]#
[root@SZB-L0008177 backups]# pwd
/backups
[root@SZB-L0008177 backups]# ls -l
total 0
[root@SZB-L0008177 backups]# crontab -l

# add sec_agent monitor by sec team at 2016-06-20 16:32:33
*/1 * * * * /usr/local/sec_agent/script/check_secagent.sh > /usr/local/sec_agent/script/monitor.log 2>&1
# 添加定时备份任务
[root@SZB-L0008177 backups]# crontab -e

# kangxiaoning

# add sec_agent monitor by sec team at 2016-06-20 16:32:33
*/1 * * * * /usr/local/sec_agent/script/check_secagent.sh > /usr/local/sec_agent/script/monitor.log 2>&1

# backup gitlab
15,20,25,30 11 31 10 * /opt/gitlab/bin/gitlab-rake gitlab:backup:create

~
"/tmp/crontab.usJStw" 7L, 255C written
crontab: installing new crontab
[root@SZB-L0008177 backups]# crontab -l

# add sec_agent monitor by sec team at 2016-06-20 16:32:33
*/1 * * * * /usr/local/sec_agent/script/check_secagent.sh > /usr/local/sec_agent/script/monitor.log 2>&1

# backup gitlab
15,20,25,30 11 31 10 * /opt/gitlab/bin/gitlab-rake gitlab:backup:create

[root@SZB-L0008177 backups]# ls -l /opt/gitlab/bin/gitlab-rake
-rwxr-xr-x 1 root root 1225 Sep 15 00:10 /opt/gitlab/bin/gitlab-rake
[root@SZB-L0008177 backups]# 
[root@SZB-L0008177 backups]# date; ls -l
Mon Oct 31 11:14:36 CST 2016
total 0
[root@SZB-L0008177 backups]# date; ls -l
Mon Oct 31 11:15:52 CST 2016
total 0
[root@SZB-L0008177 backups]#
# 默认会备份到 /var/opt/gitlab/backups/目录下
[root@SZB-L0008177 backups]# date; ls -l /var/opt/gitlab/backups/
Mon Oct 31 11:16:53 CST 2016
total 432
-rw------- 1 git git 440320 Oct 31 11:15 1477883719_gitlab_backup.tar
[root@SZB-L0008177 backups]#
# 执行 gitlab-ctl reconfigure 让配置生效
[root@SZB-L0008177 backups]# gitlab-ctl reconfigure
...
...
# 可以看到新备份文件已经在指定目录下
[root@SZB-L0008177 backups]# date; ls -l
Mon Oct 31 11:22:24 CST 2016
total 432
-rw------- 1 git git 440320 Oct 31 11:20 1477884017_gitlab_backup.tar
[root@SZB-L0008177 backups]#
[root@SZB-L0008177 backups]# date; ls -lh
Mon Oct 31 11:36:17 CST 2016
total 1.3M
-rw------- 1 git git 430K Oct 31 11:20 1477884017_gitlab_backup.tar
-rw------- 1 git git 430K Oct 31 11:25 1477884316_gitlab_backup.tar
-rw------- 1 git git 430K Oct 31 11:30 1477884616_gitlab_backup.tar
[root@SZB-L0008177 backups]#
```
# 6. rsync 配置

        如下以 CENTOS 6.5 为例。

## 6.1 rsync 配置
```shell
[root@SZB-L0008177 ~]# cat /etc/rsyncd.conf 
# /etc/rsyncd: configuration file for rsync daemon mode

# See rsyncd.conf man page for more options.

# configuration example:

uid = root
gid = root
use chroot = no
max connections = 2
strict modes = yes
port = 873
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log

[gitlab]
# 数据存放位置
path = /backups/ 
comment = gitlab backup
read only = yes
list = no
# gitlab 用户与系统用户无关
auth users = gitlab
secrets file = /etc/rsyncd.passwd
# 允许访问的客户端，可指定网段，多个客户端以空格隔开
hosts allow = 10.20.19.102
# 不允许访问的客户端
#hosts deny = *

[root@SZB-L0008177 ~]#
```

## 6.2 密码设置

        以 rsyncd.conf 指定的配置设置同步用户名和密码。
```shell
[root@SZB-L0008177 ~]# cat /etc/rsyncd.passwd
gitlab:gitlab
[root@SZB-L0008177 ~]# 
[root@SZB-L0008177 ~]# chmod 600 /etc/rsyncd.passwd
[root@SZB-L0008177 ~]#
```

## 6.3 xinetd 配置
        Linux 6.x 中 rsync 由 xinetd 管理，所以需要安装 xinetd。
        Linux 7.x 中由 systemd 管理，直接用 systemctl 命令设置即可。
```shell
# 将 disable = yes 设置为 disable = no
[root@SZB-L0008177 ~]# cat /etc/xinetd.d/rsync 
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#       allows crc checksumming etc.
service rsync
{
        disable = no
        flags           = IPv6
        socket_type     = stream
        wait            = no
        user            = root
        server          = /usr/bin/rsync
        server_args     = --daemon
        log_on_failure  += USERID
}
[root@SZB-L0008177 ~]# 
```

## 6.4 设置文件权限
        设置待同步文件权限可读。
```shell
[root@SZB-L0008177 ~]# ls -l /backups/
total 1296
-rw------- 1 git git 440320 Oct 31 11:20 1477884017_gitlab_backup.tar
-rw------- 1 git git 440320 Oct 31 11:25 1477884316_gitlab_backup.tar
-rw------- 1 git git 440320 Oct 31 11:30 1477884616_gitlab_backup.tar
[root@SZB-L0008177 ~]# cd /backups/
[root@SZB-L0008177 backups]# chmod 644 *.tar
[root@SZB-L0008177 backups]# ls -l /backups/
total 1296
-rw-r--r-- 1 git git 440320 Oct 31 11:20 1477884017_gitlab_backup.tar
-rw-r--r-- 1 git git 440320 Oct 31 11:25 1477884316_gitlab_backup.tar
-rw-r--r-- 1 git git 440320 Oct 31 11:30 1477884616_gitlab_backup.tar
[root@SZB-L0008177 backups]#
```
## 6.5 启动 rsync 服务
```shell
# 启动 xinetd 后 rsync 处于监听状态
[root@SZB-L0008177 ~]# netstat -anp|grep 873
[root@SZB-L0008177 ~]# service xinetd restart
Stopping xinetd: [FAILED]
Starting xinetd: [  OK  ]
[root@SZB-L0008177 ~]# netstat -anp|grep 873
tcp        0      0 :::873                      :::*                        LISTEN      11654/xinetd        
[root@SZB-L0008177 ~]#
```

## 6.6 客户端验证
```shell
[root@SZB-L0008181 ~]# rsync -azP --delete gitlab@10.20.19.105::gitlab /backups
Password: 
receiving incremental file list
./
1477884017_gitlab_backup.tar
      440320 100%   16.80MB/s    0:00:00 (xfer#1, to-check=2/4)
1477884316_gitlab_backup.tar
      440320 100%    8.57MB/s    0:00:00 (xfer#2, to-check=1/4)
1477884616_gitlab_backup.tar
      440320 100%    5.75MB/s    0:00:00 (xfer#3, to-check=0/4)

sent 118 bytes  received 1137642 bytes  325074.29 bytes/sec
total size is 1320960  speedup is 1.16
[root@SZB-L0008181 ~]# 
```

## 6.7 非交互同步
        配置密码文件，达到无需输入密码就可以同步的效果，实现后台自动同步。
```shell
[root@SZB-L0008181 ~]# cat /etc/rsyncd.passwd 
gitlab
[root@SZB-L0008181 ~]#

# 同步命令
rsync -azP --delete --password-file=/etc/rsyncd.passwd gitlab@10.20.19.105::gitlab /backups

```

# 7. 自动同步并恢复
* ### 记录
* 以“主gitlab”的/etc/gitlab/gitlab-secrets.json覆盖“备gitlab”
* “主gitlab”启动了 rsyncd 服务
* “主gitlab”和“备gitlab”的设置一致
* “主gitlab”启动了定期备份


        部署 restore_gitlab.sh 和 silent_restore.exp，通过 crontab 定期执行 restore_gitlab.sh 从
    主 gitlab 服务器同步最新备份并应用到备 gitlab 服务器，完成 restore 后，备 gitlab 可以给 saltstack 
    提供 gitfs 服务。

## 7.1 主 gitlab 配置
```
[root@CNSZ046058 ~]# crontab -l
#backup gitlab
55 * * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create
[root@CNSZ046058 ~]#
```

## 7.2 备 gitlab 配置
```
[root@CNSH046687 ~]# crontab -l
# gitlab rsync and restore
58 * * * * /root/scripts/restore_gitlab.sh > /root/scripts/restore_gitlab.log 2>&1
[root@CNSH046687 ~]# 
[root@CNSH046687 ~]# ls -l /root/scripts/restore_gitlab.sh 
-rwxr-xr-x 1 root root 1758 Nov  4 10:00 /root/scripts/restore_gitlab.sh
[root@CNSH046687 ~]# ls -l /root/scripts/silent_restore.exp 
-rwxr-xr-x 1 root root 355 Nov  2 11:16 /root/scripts/silent_restore.exp
[root@CNSH046687 ~]#
```

## 7.3 脚本
```shell
# script name: restore_gitlab.sh


#!/bin/bash - 
#===============================================================================
#
#          FILE: restore_gitlab.sh
# 
#         USAGE: ./restore_gitlab.sh 
# 
#   DESCRIPTION: restore gitlab from remote backups.
# 
#        AUTHOR: kangxiaoning495@pingan.com.cn
#  ORGANIZATION: 
#       CREATED: 2016Äê11ÔÂ01ÈÕ 16Ê±18·Ö07Ãë
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

BACKUPS_DIR=/data/backups
LOGFILE=/root/scripts/restore_error.log
gitlabctl=/usr/bin/gitlab-ctl
gitlabrake=/usr/bin/gitlab-rake
rsync=/usr/bin/rsync

# backup file on which host
RSYNC_SERVER=30.16.226.110


rsync_backups ()
{
    $rsync -azP --delete --password-file=/etc/rsyncd.passwd gitlab@${RSYNC_SERVER}::gitlab $BACKUPS_DIR
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi 
}

get_timestamp_of_backup ()
{
    cd $BACKUPS_DIR
    timestamp=$(ls -t *gitlab_backup.tar | head -1 | awk -F"_" '{print $1}')
    echo $timestamp
}

restore_gitlab ()
{
    $gitlabctl stop unicorn
    $gitlabctl stop sidekiq
    /root/scripts/silent_restore.exp $(get_timestamp_of_backup)
}

main ()
{
    rsync_backups

    if [ $? -eq 0 ];then
        echo "$(date '+%F %T') rsync backups successfully." 
        restore_gitlab

        if [ $? -eq 0 ];then
            echo "$(date '+%F %T') restore successfully."
            $gitlabctl start
        else
            echo "$(date '+%F %T') restore failed." >> $LOGFILE
        fi
    else
        echo "$(date '+%F %T') rsync backups failed." >> $LOGFILE
        exit 1
    fi
}

########################
#         main         #
########################

main

```

```shell
# script name: silent_restore.exp

#!/usr/bin/expect
# if not timeout,command will can not execute completelly
set timeout 600
set TIMESTAMP [lindex $argv 0]
spawn gitlab-rake gitlab:backup:restore BACKUP=$TIMESTAMP
expect "Do you want to continue (yes/no)?"
send "yes\r"
expect "Do you want to continue (yes/no)?"
send "yes\r"
# eof used for crontab,if not,crontab not execute.
expect eof
```