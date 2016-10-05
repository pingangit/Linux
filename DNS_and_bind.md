
DNS and BIND
============
[TOC]
# 1. 基本概念
- DNS: Domain Name Service，（C/S, 53/udp, 53/tcp），应用层协议；
- BIND：Bekerley Internat Name Domain, ISC （www.isc.org）
- TCP: 面向连接的协议；
- UDP: User Datagram Protocol，无连接协议

## 1.1 本地名称解析配置文件

    Linux: /etc/hosts
    Windows: %WINDOWS%/system32/drivers/etc/hosts
    1.1.1.1 www.magedu.com
    1.2.2.2 www.apple.com

## 1.2 TLD
    Top Level Domain: tld
    com, edu, mil, gov, net, org, int
    三类：组织域、国家域(.cn, .iq, .hk, .tw)、反向域

## 1.3 DNS查询类型
    递归查询：客户端请求一次，服务器返回结果
    迭代查询：客户端请求多次

## 1.4 名称服务器
    域内负责解析本域内的名称的主机；
    根服务器：13组服务器

## 1.5 解析类型
    正向解析：Name --> IP
    反向解析：IP --> Name
    注意：正反向解析是两个不同的名称空间，是两棵不同的解析树；

## 1.6 DNS服务器的类型
    主DNS服务器
    辅助DNS服务器
    缓存DNS服务器
    转发器

    主DNS服务器：维护所负责解析的域内解析库服务器；解析库由管理维护；
    从DNS服务器：从主DNS服务器或其它的从DNS服务器那里“复制”（区域传递）一份解析库；
        序列号：解析库的版本号；前提：主服务器解析库内容发生变化，其序列递增；
        刷新时间间隔：从服务器从主服务器请求同步解析库的时间间隔；
        重试时间间隔：从服务器从主服务器请求同步解析库失败时，再次尝试的时间间隔；
        过期时长：从服务器始终联系不到主服务器时，多久多后放弃从服务器角度，停止提供服务；
        "通知"机制：

## 1.7 区域传送
    全量传送：传送整个解析库
    增量传送：传递解析库变化的那部分内容

# 2. DNS
## 2.1 Domain
        正向：FQDN --> IP
        反向: IP --> FQDN

        各需要一个解析库来分别负责本地域名的正向和反向解析
            正向区域
            反向区域

## 2.2 FQDN
    Full Qualified Domain Name
    例如：www.magedu.com.

## 2.3 一次完整的查询请求经过的流程
    Client --> hosts文件 --> DNS Service
        Local Cache --> DNS Server (recursion) --> Server Cache --> iteration(迭代) --> 

    解析答案：
        肯定答案：请求的条目存在
        否定答案：请求的条目不存在等原因导致无法返回结果；

    权威答案：该域DNS服务器返回的结果
    非权威答案：非该域 DNS服务器返回结果，例如缓存

# 3. 区域解析库
## 3.1 组成
    资源记录：Resource Record, RR
    记录类型：A, AAAA, PTR, SOA, NS, CNAME, MX

	SOA：Start Of Authority，起始授权记录；一个区域解析库有且仅能有一个SOA记录，而必须为解析库的第一条记录；
	A：internet Address，作用，FQDN --> IP
	AAAA: FQDN --> IPv6
	PTR: PoinTeR，IP --> FQDN
	NS: Name Server，专用于标明当前区域的DNS服务器
	CNAME：Canonical Name，别名记录
	MX:　Mail eXchanger，邮件交换器

## 3.2 资源记录
### 3.2.1 资源记录格式
    语法：name	[TTL]	IN 	rr_type 	value

    注意：
    	(1) TTL可从全局继承；
    	(2) @可用于引用当前区域的名字；
    	(3) 同一个名字可以通过多条记录定义多个不同的值；此时DNS服务器会以轮询方式响应；
    	(4) 同一个值也可能有多个不同的定义名字；通过多个不同的名字指向同一个值进行定义；此仅表示通过多个不同的名字可以找到同一个主机而已；
### 3.2.2 资源记录类型
	SOA:
		name: 当前区域的名字，例如“magedu.com.”；
		value: 有多部分组成
			(1) 当前区域的主DNS服务器的FQDN，也可以使用当前区域的名字；
			(2) 录前区域管理员的邮箱地址；但地址中不能使用@符号，一般用.替换，例如linuxedu.magedu.com；
			(3) (主从服务协调属性的定义以及否定的答案的统一的TTL)

	例如：
	magedu.com. 	86400 	IN 	SOA 	ns.magedu.com. 	nsadmin.magedu.com. 	(
					2015042201  ;序列号
					2H          ;刷新时间
					10M			;重试时间
					1W			;过期时间
					1D			;否定答案的TTL值
	)

	NS: 
		name: 当前区域的名字
		value: 当前区域的某DNS服务器的名字，例如ns.magedu.com.；
			注意：一个区域可以有多个NS记录；

		例如：
		magedu.com.		IN 		NS  	ns1.magedu.com.
		magedu.com.		IN 		NS  	ns2.magedu.com.

		注意：
			(1) 相邻的两个资源记录的name相同时，后续的可省略；
			(2) 对NS记录而言，任何一个ns记录后面的服务器名字，都应该在后续有一个A记录；

	MX: 
		name: 当前区域的名字
		value: 当前区域的某邮件服务器(smtp服务器)的主机名；
			一个区域内，MX记录可有多个；但每个记录的value之前应该有一个数字(0-99)，表示此服务器的优先级；数字越小优先级越高；

		例如：
		magedu.com.		IN  	MX  10  mx1.magedu.com.
						IN 		MX  20  mx2.magedu.com.

		注意：
			(1) 对MX记录而言，任何一个MX记录后面的服务器名字，都应该在后续有一个A记录；

	A:
		name: 某主机的FQDN，例如www.magedu.com.
		value: 主机名对应主机的IP地址；

		例如：
			www.magedu.com.		IN  	A 	1.1.1.1
			www.magedu.com.		IN  	A  	1.1.1.2

			mx1.magedu.com. 	IN    	A   1.1.1.3
			mx2.magedu.com.  	IN   	A   1.1.1.3

		注意：
			*.magedu.com. 		IN  	A  	1.1.1.4
			magedu.com.			IN   	A   1.1.1.4

			避免用户写错名称时给错误答案，可通过泛域名解析进行解析至某特定地址；

	AAAA:
		name: FQDN
		value: IPv6

	PTR:
		name: IP，有特定格式，把IP地址反过来写，1.2.3.4，要写作4.3.2.1；而有特定后缀：in-addr.arpa.，所以完整写法为：4.3.2.1.in-addra.arpa.
		value: FQDN

		例如：
			4.3.2.1.in-addr.arpa. 	IN 	PTR 	www.magedu.com
			简写成：
				4  	IN  PTR 	www.magedu.com.

				注意：网络地址及后缀可省略；主机地址依然需要反着写；

	CNAME：
		name: 别名的FQDN
		value: 正工名字的FQDN；

		例如：
			web.magedu.com. 	IN  	CNAME  	www.magedu.com.

# 4. 子域授权
    每个域的名称服务器，都是通过其上级名称服务器在解析库进行授权；
## 4.1 示例
	类似根域授权tld:
		.com.	IN 		NS  	ns1.com.
		.com.   IN   	NS 		ns2.com.
		ns1.com. 	IN 		A 	2.2.2.1
		ns2.com.  	IN 		A 	2.2.2.2

	magedu.com. 在.com的名称服务器上，解析库中添加资源记录：
		magedu.com. 	IN 	NS 		ns1.magedu.com.
		magedu.com. 	IN 	NS 		ns2.magedu.com.
		magedu.com. 	IN 	NS 		ns3.magedu.com.
		ns1.magedu.com. 	IN 	A  	3.3.3.1
		ns2.magedu.com. 	IN 	A  	3.3.3.2
		ns3.magedu.com. 	IN 	A  	3.3.3.3

		glue record：粘合记录

## 4.2 域名注册
	代理商：万网, 新网；godaddy

	注册完成以后，想自己用专用服务来解析？

	(1) 管理后台：把NS记录指向的服务器名称，和A记录指向的服务器地址；

# 5. BIND的安装配置：
## 5.1 程序包  
	dns服务，程序包名bind，程序名named
		bind
		bind-libs
		bind-utils
	bind-chroot: /var/named/chroot/
## 5.2 配置文件路径
	bind：
	服务脚本：/etc/rc.d/init.d/named
	主配置文件：/etc/named.conf, /etc/named.rfc1912.zones, /etc/rndc.key
	解析库文件：/var/named/ZONE_NAME.ZONE

	注意：
		(1) 一台物理服务器可同时为多个区域提供解析；
		(2) 必须要有根区域文件；named.ca
		(3) 应该有两个（如果包括ipv6的，应该更多）实现localhost和本地回环地址的解析库；
## 5.3 rndc 管理工具
	rndc: remote name domain controller，默认与bind安装在同一主机，且只能通过127.0.0.1来连接named进程；提供辅助性的管理功能；
		953/tcp
## 5.4 配置文件详解
### 5.4.1 主配置文件
    	全局配置：options {}
    	日志子系统配置：logging {}
    	区域定义：本机能够为哪些zone进行解析，就要定义哪些zone；
    	zone "ZONE_NAME" IN {}

		注意：任何服务程序如果期望其能够通过网络被其它主机访问，至少应该监听在一个能与外部主机通信的IP地址上；

### 5.4.2 缓存名称服务器的配置
		监听外部地址即可；

### 5.4.3 dnssec 
	建议测试时关闭dnssec；

### 5.4.3 主DNS名称服务器
	(1) 在主配置文件中定义区域
	zone "ZONE_NAME" IN {
		type {master|slave|hint|forward};
		file "ZONE_NAME.zone";
	};

	(2) 定义区域解析库文件

	出现的内容：
		宏定义；
		资源记录；

	示例：
	$TTL 86400
	$ORIGIN magedu.com.
	@	IN	SOA	ns1.magedu.com.	admin.magedu.com (
				2015042201
				1H
				5M
				7D
				1D )
		IN	NS	ns1
		IN	NS	ns2
		IN	MX 10	mx1
		IN	MX 20	mx2
	ns1	IN	A	172.16.100.11
	ns2	IN	A	172.16.100.12
	mx1	IN	A	172.16.100.13
	mx2	IN	A	172.16.100.14
	www	IN	A	172.16.100.11
	www	IN	A	172.16.100.12
	ftp	IN	CNAME	www


## 5.5 测试命令
### 5.5.1 dig命令
	dig [-t type] name [@SERVER] [query options]

	dig用于测试dns系统，因此，不会查询hosts文件进行解析；

	查询选项：
		+[no]trace：跟踪解析过程
		+[no]recurse：进行递归解析

	测试反向解析：
		dig -x IP @SERVER

	模拟区域传送：
		dig -t axfr ZONE_NAME @SERVER

		例如：dig -t axfr magedu.com @172.16.100.11

### 5.5.2 host命令
		host [-t type] name [SERVER]

### 5.5.3 nslookup命令
	 nslookup [-option] [name | -] [server]

	 交互式模式：
	 	nslookup>
	 		server IP: 指明使用哪个DNS server进行查询；
	 		set q=RR_TYPE: 指明查询的资源记录类型；
	 		NAME: 要查询的名称；

# 6. 反向区域

	区域名称：网络地址反写.in-addr.arpa.
		172.16.100. --> 100.16.172.in-addr.arpa.

	(1) 定义区域
	zone "ZONE_NAME" IN {
		type {master|slave|forward}；
		file "网络地址.zone"
	};

	(2) 区域解析库文件
		注意：不需要MX和A，以及AAAA记录；以PTR记录为主；

	示例：
	$TTL 86400
	$ORIGIN 100.16.172.in-addr.arpa.
	@	IN	SOA	ns1.magedu.com. admin.magedu.com. (
				2015042201
				1H
				5M
				7D
				1D )
		IN	NS	ns1.magedu.com.
		IN	NS	ns2.magedu.com.
	11	IN	PTR	ns1.magedu.com.
	11	IN	PTR	www.magedu.com.
	12	IN	PTR	mx1.magedu.com.
	12	IN	PTR	www.magedu.com.
	13	IN	PTR	mx2.magedu.com.	

# 7. 主从复制：
	1、应该为一台独立的名称服务器；
	2、主服务器的区域解析库文件中必须有一条NS记录是指向从服务器；
	3、从服务器只需要定义区域，而无须提供解析库文件；解析库文件应该放置于/var/named/slaves/目录中;
	4、主服务器得允许从服务器作区域传送；
	5、主从服务器时间应该同步，可通过ntp进行；
	6、bind程序的版本应该保持一致；否则，应该从高，主低；

- 定义从区域的方法

	zone "ZONE_NAME" IN {
		type slave;
		masters { MASTER_IP; };
		file "slaves/ZONE_NAME.zone";
	};

	rndc：
		rndc --> rndc (953/tcp)

		rndc COMMAND

		COMMAND:
			reload: 重载主配置文件和区域解析库文件
			reload zone: 重载区域解析库文件
			retransfer zone: 手动启动区域传送过程，而不管序列号是否增加；
			notify zone: 重新对区域传送发通知；
			reconfig: 重载主配置文件
			querylog: 开启或关闭查询日志；
			trace: 递增debug级别；
			trace LEVEL: 指定使用的级别；

# 8. 子域授权：分布式数据库

## 8.1 正向解析区域子域方法

### 1. 定义一个子区域
	ops.magedu.com. 	IN 	NS 	ns1.ops.magedu.com.
	ops.magedu.com. 	IN 	NS 	ns2.ops.magedu.com.
	ns1.ops.magedu.com. 	IN 	A 	1.1.1.1
	ns2.ops.magedu.com. 	IN 	A 	1.1.1.2

	fin.magedu.com. 	IN 	NS 	ns1.fin.magedu.com.
	fin.magedu.com. 	IN 	NS 	ns2.fin.magedu.com.
	ns1.fin.magedu.com. 	IN 	A 	3.1.1.1
	ns2.fin.magedu.com. 	IN 	A 	3.1.1.2

### 2. 定义转发服务器
	注意：被转发的服务器需要能够为请求者做递归，否则，转发请求不予进行；

	(1) 全部转发: 凡是对非本机所有负责解析的区域的请求，统统转发给指定的服务器；
	Options {
		forward {first|only}
		fowwarders
	}

	(2) 区域转发：仅转发对特定的区域的请求至某服务器；
	zone "ZONE_NAME" IN {
		type forward;
		forward {first|only}
		forwarders
	}

	注意：关闭dnssec功能：
	dnssec-enable no;
	dnssec-validation no;

# 9. bind中基础的安全相关的配置
	acl: 把一个或多个地址归并为一个集合，并通过一个统一的名称调用；
	acl acl_name {
		ip;
		ip;
		net/prelen;
	};

	示例：
	acl mynet {
		172.16.0.0/16;
	}

	bind有四个内置的acl:
	none: 没有一个主机；
	any: 任意主机；
	local: 本机；
	localnet: 本机的IP同掩码运算后得到的网络地址；

	注意：只能先定义，后使用；因此，其一般定义在配置文件中options的前面；

	访问控制的指令：
		allow-query {}： 允许查询的主机；白名单；
		allow-transfer {}：允许区域传送的主机；白名单；
		allow-recursion {}: 允许递归的主机；
		allow-update {}: 允许更新区域数据库中的内容；

# 10. bind view
	视图：
	一个bind服务器可定义多个view，每个view中可定义一个或多个zone；
	每个view用一来匹配一组客户端；
	多个view内可能需要对同一个区域进行解析，但使用不同的区域解析库文件；

	view VIEW_NAME {
		match-clients {  };
	}

	注意：
		(1) 一旦启用了view，所有的zone都只能定义在view中；
		(2) 仅有必要在匹配到允许递归请求的客户所在view中定义根区域；
		(3) 客户端请求到达时，是自上而下检查每个view所服务的客户端列表；

		CDN: Content Delivery Network

		智能DNS:
			dnspod
			dns.la

# 11. 编译安装bind
## 11.1 下载
	isc.org:
		bind-9.8
		bind-9.9
		bind-10
## 11.2 编译安装
	bind-9.10
		# tar
		# cd
		# groupadd -r -g 53 named
		# useradd -r -u 53 -g 53 named
		# ./configure --prefix=/usr/local/bind9 --sysconfdir=/etc/named/ --disable-ipv6 --disable-chroot --enable-threads
		# make
		# make install

	前次博客作业附加：子域授权和view；

## 11.3 后续配置

1. 添加PATH
```
vim /etc/profile.d/named.sh
export PATH=/usr/local/bind9/bin:/usr/local/bind9/sbin:$PATH
. /etc/profile.d/named.sh
```
2. 添加lib
```
vim /etc/ld.so.conf.d/named.conf
/usr/local/bind9/lib
#通知系统重读此配置文件，生成库文件搜索路径
ldconfig -v
``` 
3. 头文件header
```
ln -sv /usr/local/bind9/include /usr/include/named
```
4. man手册配置
```
vim /etc/man.config
MANPATH /usr/local/bind9/share/man
```
5. 性能测试工具

    queryperf工具，在源码包中


