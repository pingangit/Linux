httpd
=====

# 知识点

## 1. 基础

### 1.1 Socket

        IPC的一种实现，允许位于不同主机（甚至同一主机）上不同进程之间进行通信；
        数据交换；Socket API, 1983年，4.2 BSD
            SOCK_STREAM：tcp套接字
            SOCK_DGRAM：udp套接字
            SOCK_RAW: 裸套接字

### 1.2 TCP协议的特性

        建立连接：三次握手
        将数据打包成段：校验和（CRC-32）
        确认、重传以及超时：
        排序：逻辑序号
        流量控制：滑动窗口算法
        拥塞控制：慢启动和拥塞避免算法

### 1.3 MPM

        prefork：多进程模型，一个进程响应一个请求；
        worker：多线程模型(多进程生成，一个进程生成多个线程)，一个线程响应一个请求；
        event：事件驱动模型，一个线程响应多个请求；

### 1.4 并发服务器响应请求

        单进程I/O模型；
        多进程I/O模型；
        复用的I/O模型；
            多线程模型
            事件驱动
        利用的多进程I/O模型；

## 2. CentOS 6上的httpd

### 2.1 程序环境
    【配置文件】
        /etc/httpd/conf/httpd.conf
        /etc/httpd/conf.d/*.conf
    【服务脚本】
        /etc/rc.d/init.d/httpd
        配置文件：/etc/sysconfig/httpd
    【主程序文件】
        /usr/sbin/httpd
        /usr/sbin/httpd.event
        /usr/sbin/httpd.worker
    【日志文件目录】
        /var/log/httpd
            access_log: 访问日志
            error_log：错误日志
    【站点文档目录】
        /var/www/html
    【模块文件路径】
        /usr/lib64/httpd/modules
    【配置文件的组成】
         ~]# grep "Section" /etc/httpd/conf/httpd.conf 
        ### Section 1: Global Environment
        ### Section 2: 'Main' server configuration
        ### Section 3: Virtual Hosts
    【配置文件格式】
        directive value
        directive: 不区分字符大小写；
        value: 为路径时，取决于文件系统；

### 2.2 常用配置
#### 2.2.1 监听IP和Port
        Listen [IP:]PORT
        省略ip表示监听本机所有IP; Listen可重复出现多次；

#### 2.2.2 持久连接

    【Persistent Connection】
        连接建立，每个资源获取完成后不会断开连接，而是继续等待其它的请求完成。
        
        断开机制
            数量限制：100
            时间限制：可配置
        副作用：对并发访问量较大的服务器，持久连接功能会使用有些请求得不到响应。
        
        折衷：使用较短的持久连接时间；
            httpd-2.4 支持毫秒级持久时间；
    
        HTTP 1.0 默认是非持久连接
        HTTP 1.1 默认是持久连接
        
        KeepAlive On|Off
        MaxKeepAliveRequests #
        KeepAliveTimeout #（默认是秒）

    【测试】
        telnet HOST PORT
        GET /URL HTTP/1.1
        Host: HOSTNAME or IP
    
    【结论】
        KeepAlive Off
            GET一次会话就断开
        KeepAlive On
            GET一次会话不会断开，可以GET多次，直到超时

#### 2.2.3 MPM
    Multipath Process Module：多道处理模块
        prefork, worker, event

    httpd-2.2不支持同时编译多个模块，所以只能编译时选定一个。
    rpm安装的包提供三个二进制程序文件，分别用于实现对不同MPM机制的支持。
    
    确认方法：
        # ps aux  | grep httpd
        如果是worker或者event会显示httpd.worker或者httpd.event
    
    默认为/usr/sbin/httpd, 其使用prefork
        查看模块列表：
            查看静态编译的模块
                [root@SZB-L0009803 conf]# httpd -l
                Compiled in modules:
                  core.c
                  prefork.c
                  http_core.c
                  mod_so.c
                [root@SZB-L0009803 conf]# 
            查看静态编译及动态装载的模块
                # httpd -M
                [root@SZB-L0009803 conf]# httpd -M
                httpd: Could not reliably determine the server's fully qualified domain name, using 172.30.17.65 for ServerName
                Loaded Modules:
                 core_module (static)
                 mpm_prefork_module (static)
                 http_module (static)
                 so_module (static)
                 auth_basic_module (shared)
                    ...
                    ...
                 cgi_module (shared)
                 version_module (shared)
                 dnssd_module (shared)
                Syntax OK
                [root@SZB-L0009803 conf]#                 

    更换使用的httpd程序：
        /etc/sysconfig/httpd
            HTTPD=

        重启服务生效；

```
[root@SZB-L0009803 conf]# more /etc/sysconfig/httpd | grep HTTPD=    
HTTPD=/usr/sbin/httpd.worker
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# ps -ef|grep -v | grep httpd
Usage: grep [OPTION]... PATTERN [FILE]...
Try `grep --help' for more information.
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# ps -ef|grep httpd | grep -v grep
root      2554     1  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2557  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2558  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2559  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2560  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2561  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2562  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2563  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
apache    2564  2554  0 21:46 ?        00:00:00 /usr/sbin/httpd
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd: httpd.worker: Could not reliably determine the server's fully qualified domain name, using 172.30.17.65 for ServerName
                                                           [  OK  ]
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# ps -ef|grep httpd | grep -v grep
root      2902     1  0 22:02 ?        00:00:00 /usr/sbin/httpd.worker
apache    2905  2902  0 22:02 ?        00:00:00 /usr/sbin/httpd.worker
apache    2908  2902  0 22:02 ?        00:00:00 /usr/sbin/httpd.worker
apache    2911  2902  0 22:02 ?        00:00:00 /usr/sbin/httpd.worker
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# vim /etc/sysconfig/httpd 
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# more /etc/sysconfig/httpd | grep HTTPD=
HTTPD=/usr/sbin/httpd.event
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# service httpd restart                  
Stopping httpd:                                            [  OK  ]
Starting httpd: httpd.event: Could not reliably determine the server's fully qualified domain name, using 172.30.17.65 for ServerName
                                                           [  OK  ]
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# ps -ef|grep httpd | grep -v grep       
root      3052     1  0 22:02 ?        00:00:00 /usr/sbin/httpd.event
apache    3055  3052  0 22:02 ?        00:00:00 /usr/sbin/httpd.event
apache    3056  3052  0 22:02 ?        00:00:00 /usr/sbin/httpd.event
apache    3058  3052  0 22:02 ?        00:00:00 /usr/sbin/httpd.event
[root@SZB-L0009803 conf]# 
[root@SZB-L0009803 conf]# httpd.event -l
Compiled in modules:
  core.c
  event.c
  http_core.c
  mod_so.c
[root@SZB-L0009803 conf]# 
```        

    prefork的配置：
        <IfModule prefork.c>
        StartServers       8
        MinSpareServers    5
        MaxSpareServers   20
        ServerLimit      256
        MaxClients       256
        MaxRequestsPerChild  4000
        </IfModule>				

    worker的配置：
        <IfModule worker.c>
        StartServers         4
        MaxClients         300
        MinSpareThreads     25
        MaxSpareThreads     75
        ThreadsPerChild     25
        MaxRequestsPerChild  0
        </IfModule>

    PV, UV
        PV: Page View
        UV: User View
            独立IP量；

        300*86400=40W+

#### 2.2.4 DSO
    配置指令实现模块加载
        LoadModule <mod_name> <mod_path>

        模块路径可使用相对地址
            相对于ServerRoot(/etc/httpd)指向的路径而言；
                /etc/httpd/modules/
```
# /etc/httpd/modules 是个软链接
[root@SZB-L0009803 conf]# ls -l /etc/httpd/
total 12
drwxr-xr-x. 2 root root 4096 Oct  7 21:45 conf
drwxr-xr-x. 2 root root 4096 Mar  9  2015 conf.d
lrwxrwxrwx. 1 root root   19 Mar  9  2015 logs -> ../../var/log/httpd
lrwxrwxrwx. 1 root root   29 Mar  9  2015 modules -> ../../usr/lib64/httpd/modules
lrwxrwxrwx. 1 root root   19 Mar  9  2015 run -> ../../var/run/httpd
drwxr-xr-x  2 root root 4096 Oct  6 18:01 ssl
[root@SZB-L0009803 conf]#
```                

#### 2.2.5 定义'Main' server的文档页面路径
    DocumentRoot

    文档路径映射：
        DocumentRoot指向的路径为URL路径的起始位置；
            DocumentRoot "/var/www/html"
                test/index.html --> http://HOST:PORT/test/index.html

#### 2.2.6 站点访问控制
    可基于两种类型的路径指明对哪些资源进行访问控制
        文件系统路径：
            <Directory ""> </Direcotry>
            <File ""> </File>
            <FileMatch ""> </FileMatch>
        URL路径：
            <Location ""> </Location>
            ...

    访问控制机制：
        基于来源地址；
        基于账号；

#### 2.2.7 Directory中“基于来源地址”实现访问控制

    (1) Options
        所有可用特性：Indexes Includes FollowSymLinks SymLinksifOwnerMatch ExecCGI MultiViews
                      None, All
            Indexes: 索引；如果没有提供主页的话允许以目录显示网站根下的所有文件
            FollowSymlinks：允许跟踪符号链接文件；

    (2) 基于来源地址的访问控制机制
        Order：检查次序
            Order allow,deny 默认deny，显式allow的才允许
            Order deny,allow 默认allow，显式deny的才禁止
        Allow from 来源地址
        Deny from
        
        注：Allow from 和 Deny from 可同时存在
        
        来源地址：
            IP
            NetAddr:（支持如下多种方式）
                172.16
                172.16.0.0
                172.16.0.0/16
                172.16.0.0/255.255.0.0
            还可以使用FQDN，支持通配符，例如：Allow: 172.16 *.dbo.com

#### 2.2.8 定义默认主页面
    DirecotryIndex index.html index.html.var

#### 2.2.9 日志设定

    错误日志：
        ErrorLog logs/error_log
        LogLevel warn

            debug, info, notice, warn, error, crit, alert, emerg

    访问日志：
        CustomLog logs/access_log combined
        LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

            %h：客户端IP地址；
            %l: Remote logname (from identd, if supplied). -表示为空；
            %u: Remote user,  (from auth; may be bogus if return status (%s) is 401);
            %t：Time the request was received (standard english format)，服务器收到请求的时间；
            %r：First line of request，请求报文的道行信息(method url version)；
            %>s: 响应状态码；
            %b: 响应报文的大小，单位是字节，不包括响应报文首部；
            %{Referer}i：请求报文当中"referer"首部的值；当前资源的访问入口，即从哪个页面中的超链接跳转而来；
            %{User-Agent}i：请求报文当中"User-Agent"首部的值；即发出请求用到的应用程序；

        详情：http://httpd.apache.org/docs/2.2/mod/mod_log_config.html#formats

#### 2.2.10 路径别名

    DocumentRoot "/www/htocs"
        http://www.magedu.com/download/bash-4.4.2-3.el6.x86_64.rpm
            --> /www/htdocs/download/bash-4.4.2-3.el6.x86_64.rpm

    Alias /URL/ "/PATH/TO/SOMEDIR/"	
    
        Alias /bbs/ "/forum/htdocs"
            http://www.magedu.com/bbs/index.html 	
                --> /forum/htdocs/bbs/

#### 2.2.11 设定默认字符集
    AddDefaultCharset UTF-8

    GBK, GB2312, GB18030

#### 2.2.12 基于用户的访问控制

    认证质询：
        WWW-Authenticate：响应码为401，拒绝客户端请求，并说明要求客户提供账号和密码；

    认证：
        Authorization：客户端用户填入账号和密码后再次发送请求报文；认证通过，则服务器发送响应的资源；

        认证类型：
            basic：明文
            digest：消息摘要

    安全域：需要用户认证后方能访问的路径；
        应该通过名称对其进行标识，并用于告知用户认证的原因；

    用户的账号和密码存储于何处？
        虚拟账号：仅用于访问某服务时用到的认证标识；

        存储：
            文本文件
            SQL数据库
            ldap
            nis

    basic认证：
        (1) 定义安全域
            <Directory "">
                Options None
                AllowOverride None
                AuthType Basic
                AuthName "STRING"
                AuthUserFile "/PATH/TO/HTTPD_USER_PASSWD_FILE"
                Require user username1 username2 ...
            </Directory>

                允许账号文件中的所有用户登录访问：
                    Require valid-user

        (2) 提供账号和密码存储(文本文件)
            使用htpasswd命令进行管理
                htpasswd [options] passwordfile username
                    -c: 自动创建passwordfile，因此，仅应该在添加第一个用户时使用；
                    -m: md5加密用户密码；
                    -s: sha1加密用户密码；
                    -D: 删除指定用户

        (3) 实现基于组进行认证
            <Directory "">					
                Options None
                AllowOverride None
                AuthType Basic
                AuthName "STRING"
                AuthUserFile "/PATH/TO/HTTPD_USER_PASSWD_FILE"
                AuthGroupFile "/PATH/TO/HTTPD_GROUP_FILE"
                Require group GROUP1 GROUP2 ...
            </Directory>	

            要提供：用户账号文件和组文件；

                组文件：每一行定义一个组
                    GRP_NAME：user1 user2 user3 ...


            示例：
                <Directory "/www/htdocs/admin">
                    Options None
                    AllowOverride None
                    AuthType Basic
                    AuthName "Administator private"
                    AuthUserFile "/etc/httpd/conf.d/.htpasswd"
                    AuthGroupFile "/etc/httpd/conf.d/.htgroup"
                    Require group webadmin
                </Directory>

#### 2.2.13 虚拟主机

    有三种实现方案：
        基于ip：
            为每个虚拟主机准备至少一个ip地址；
        基于port：
            为每个虚拟主机准备至少一个专用port；实践中很少使用；
        基于hostname：
            为每个虚拟主机准备至少一个专用hostname；

        可混合使用上述三种方式中任意方式；

    注意：一般虚拟主机莫与中心主机混用，所以，要使用虚拟主机，先禁用中心主机；
        禁用中心主机：注释DocumentRoot

    每个虚拟主机都有专用配置：
        <VirtualHost "IP:PORT">
            SeverName
            DocumentRoot ""
        </VirtualHost>

            ServerAlias: 虚拟主机的别名；
            ErrorLog
            CustomLog
            <Directory "">
            </Directory>

    示例1：基于ip
        <VirtualHost 172.16.100.6:80>
            ServerName web1.magedu.com
            DocumentRoot "/vhosts/web1/htdocs"
        </VirtualHost>

        <VirtualHost 172.16.100.7:80>
            ServerName web2.magedu.com
            DocumentRoot "/vhosts/web2/htdocs"
        </VirtualHost>

    示例2：基于port
        <VirtualHost 172.16.100.7:80>
            ServerName web2.magedu.com
            DocumentRoot "/vhosts/web2/htdocs"
        </VirtualHost>

        <VirtualHost 172.16.100.7:8080>
            ServerName web3.magedu.com
            DocumentRoot "/vhosts/web3/htdocs"
        </VirtualHost>

    示例3：基于hostname
        <VirtualHost 172.16.100.6:80>
            ServerName web1.magedu.com
            DocumentRoot "/vhosts/web1/htdocs"
        </VirtualHost>

        <VirtualHost 172.16.100.6:80>
            ServerName web2.magedu.com
            DocumentRoot "/vhosts/web2/htdocs"
        </VirtualHost>

        <VirtualHost 172.16.100.6:80>
            ServerName web3.magedu.com
            DocumentRoot "/vhosts/web3/htdocs"
        </VirtualHost>

#### 2.2.14 内置的status页面
    <Location /server-status>
        SetHandler server-status
        Order deny,allow
        Deny from all
        Allow from 172.16
    </Location>	
    
    实现：基于账号实现访问控制
