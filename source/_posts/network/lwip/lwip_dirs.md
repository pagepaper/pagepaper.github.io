---
title: LwIP源代码文件目录解析
date:  2011-01-25 13:09:50
updated:  2011-01-25 13:09:50
categories : 
  - [LwIP]
tags:
urlname: fd041d79f7e98f1ea7e291ec02a5af7f
---
## LwIP源代码文件目录
```
root@motadou:/home/motadou/lwip/lwip-1.4.1# tree .
├── CHANGELOG
├── COPYING
├── doc
│   ├── contrib.txt
│   ├── FILES
│   ├── rawapi.txt
│   ├── savannah.txt
│   ├── snmp_agent.txt
│   └── sys_arch.txt
├── FILES
├── README
├── src
│   ├── api
│   │   ├── api_lib.c
│   │   ├── api_msg.c
│   │   ├── err.c
│   │   ├── netbuf.c
│   │   ├── netdb.c
│   │   ├── netifapi.c
│   │   ├── sockets.c
│   │   └── tcpip.c
│   ├── core
│   │   ├── def.c
│   │   ├── dhcp.c
│   │   ├── dns.c
│   │   ├── init.c
│   │   ├── ipv4
│   │   │   ├── autoip.c
│   │   │   ├── icmp.c
│   │   │   ├── igmp.c
│   │   │   ├── inet.c
│   │   │   ├── inet_chksum.c
│   │   │   ├── ip_addr.c
│   │   │   ├── ip.c
│   │   │   └── ip_frag.c
│   │   ├── ipv6
│   │   │   ├── icmp6.c
│   │   │   ├── inet6.c
│   │   │   ├── ip6_addr.c
│   │   │   ├── ip6.c
│   │   │   └── README
│   │   ├── mem.c
│   │   ├── memp.c
│   │   ├── netif.c
│   │   ├── pbuf.c
│   │   ├── raw.c
│   │   ├── snmp
│   │   │   ├── asn1_dec.c
│   │   │   ├── asn1_enc.c
│   │   │   ├── mib2.c
│   │   │   ├── mib_structs.c
│   │   │   ├── msg_in.c
│   │   │   └── msg_out.c
│   │   ├── stats.c
│   │   ├── sys.c
│   │   ├── tcp.c
│   │   ├── tcp_in.c
│   │   ├── tcp_out.c
│   │   ├── timers.c
│   │   └── udp.c
│   ├── FILES
│   ├── include
│   │   ├── ipv4
│   │   │   └── lwip
│   │   │       ├── autoip.h
│   │   │       ├── icmp.h
│   │   │       ├── igmp.h
│   │   │       ├── inet_chksum.h
│   │   │       ├── inet.h
│   │   │       ├── ip_addr.h
│   │   │       ├── ip_frag.h
│   │   │       └── ip.h
│   │   ├── ipv6
│   │   │   └── lwip
│   │   │       ├── icmp.h
│   │   │       ├── inet.h
│   │   │       ├── ip_addr.h
│   │   │       └── ip.h
│   │   ├── lwip
│   │   │   ├── api.h
│   │   │   ├── api_msg.h
│   │   │   ├── arch.h
│   │   │   ├── debug.h
│   │   │   ├── def.h
│   │   │   ├── dhcp.h
│   │   │   ├── dns.h
│   │   │   ├── err.h
│   │   │   ├── init.h
│   │   │   ├── mem.h
│   │   │   ├── memp.h
│   │   │   ├── memp_std.h
│   │   │   ├── netbuf.h
│   │   │   ├── netdb.h
│   │   │   ├── netifapi.h
│   │   │   ├── netif.h
│   │   │   ├── opt.h
│   │   │   ├── pbuf.h
│   │   │   ├── raw.h
│   │   │   ├── sio.h
│   │   │   ├── snmp_asn1.h
│   │   │   ├── snmp.h
│   │   │   ├── snmp_msg.h
│   │   │   ├── snmp_structs.h
│   │   │   ├── sockets.h
│   │   │   ├── stats.h
│   │   │   ├── sys.h
│   │   │   ├── tcp.h
│   │   │   ├── tcp_impl.h
│   │   │   ├── tcpip.h
│   │   │   ├── timers.h
│   │   │   └── udp.h
│   │   ├── netif
│   │   │   ├── etharp.h
│   │   │   ├── ppp_oe.h
│   │   │   └── slipif.h
│   │   └── posix
│   │       ├── netdb.h
│   │       └── sys
│   │           └── socket.h
│   └── netif
│       ├── etharp.c
│       ├── ethernetif.c
│       ├── FILES
│       ├── ppp
│       │   ├── auth.c
│       │   ├── auth.h
│       │   ├── chap.c
│       │   ├── chap.h
│       │   ├── chpms.c
│       │   ├── chpms.h
│       │   ├── fsm.c
│       │   ├── fsm.h
│       │   ├── ipcp.c
│       │   ├── ipcp.h
│       │   ├── lcp.c
│       │   ├── lcp.h
│       │   ├── magic.c
│       │   ├── magic.h
│       │   ├── md5.c
│       │   ├── md5.h
│       │   ├── pap.c
│       │   ├── pap.h
│       │   ├── ppp.c
│       │   ├── pppdebug.h
│       │   ├── ppp.h
│       │   ├── ppp_impl.h
│       │   ├── ppp_oe.c
│       │   ├── randm.c
│       │   ├── randm.h
│       │   ├── vj.c
│       │   └── vj.h
│       └── slipif.c
├── test
│   └── unit
│       ├── core
│       │   ├── test_mem.c
│       │   └── test_mem.h
│       ├── etharp
│       │   ├── test_etharp.c
│       │   └── test_etharp.h
│       ├── lwip_check.h
│       ├── lwipopts.h
│       ├── lwip_unittests.c
│       ├── tcp
│       │   ├── tcp_helper.c
│       │   ├── tcp_helper.h
│       │   ├── test_tcp.c
│       │   ├── test_tcp.h
│       │   ├── test_tcp_oos.c
│       │   └── test_tcp_oos.h
│       └── udp
│           ├── test_udp.c
│           └── test_udp.h
├── tt.xtx
└── UPGRADING

24 directories, 151 files
```

## api文件夹源代码结构
为方便用户编程，LwIP为用户提供两种简单的高级API接口：协议栈sequentialAPI和socket API。这两种API实现的原理都是通过引进邮箱和信号量等通信与同步机制，来实现对内核中raw/callback API函数的封装和调用。也就是说，要使用这两种API，必须基于底层操作系统提供的邮箱和信号量机制，必须要在开发板上移植好操作系统。

| 文件 |	说明 |
| ---- | ---- |
| api_lib.c	| 包含sequential API函数的实现，主要包含预留给用户的编程接口 |
| api_msg.c	| 包含sequential API函数的实现，主要包含API消息的封装和处理函数 |
| netbuf.c	| 包含上层数据包管理函数的实现 |
| netdb.c	| 包含与主机名字转换相关的函数，主要在socket中被使用到 |
| netifapi.c	| 包含上层网络接口管理函数的实现 |
| sockets.c	| 包含socket API函数的实现 |
| tcpip.c	| 提供了上层API与协议栈内核交互的函数，它是整个上层API功能得以实现的一个枢纽，其实现的功能可以理解为：从API函数处接收消息，然后将消息递交给内核函数，内核函数根据消息做出相应的处理。 |


## netif文件夹源代码结构
netif文件夹主要包含了与底层网络接口相关的文件。
| 文件	| 说明 |
| ---- | ---- |
| etharp.c	| 包含ARP协议的实现代码。主要用来实现主机以太网物理地址到IP地址的映射。|
| ethernetif.c	| 包含了与以太网网卡密切相关的初始化、发送、接收等函数的实现。这个文件夹中的函数并不能使用，它们都是一个框架性的结构，移植者需要根据自己使用的网卡特性来完成这些函数。 |
| loopif.c	| 为协议栈提供回环网络接口功能。使用这个接口可以实现本地两个进程之间的数据传递。|
| slipif.c	| SLIP（串行链路IP），提供一种在串行链路上传送IP数据包的函数定义，移植者需要根据自己使用的串行线路特性来实现这些函数。 |

## core文件夹源代码结构
core文件夹是LwIP内核源代码，包含IP、ICMP、IGMP、TCP、UDP等核心协议以及建立在它们基础上的DNS、DHCP、SNMP等上层应用协议。内核源代码可以单独运行，且不需要操作系统的支持。我们先看下core根目录下的文件作用说明，然后再分析子目录中过的文件。

| 文件 |	说明|
| ---- | ---- |
| dhcp.c	| 包含DHCP（动态主机配置协议）客户端的实现代码 |
| dns.c	| 包含DNS（域名系统）客户端的实现代码 |
| init.c |	包含了一个与LwIP协议栈初始化密切相关的函数，以及一些协议栈配置信息的检查与输出 |
| mem.c	| 协议栈内存堆管理函数的实现代码| 
| memp.c |	协议栈内存池管理函数的实现代码| 
| netif.c |	包含协议栈网络接口管理的相关函数，协议栈内部对每个接口（比如以太网接口、回环接口等）用一个对应的数据结构进行描述，并通过使用netif.c中的函数进行统一管理。| 
| pbuf.c | 包含协议栈内核使用的数据包管理函数，用于协议栈层次间的数据传递，避免数据拷贝| 
| raw.c	| 原始套接字的实现代码，可以通过该文件中的函数直接操纵IP层数据包| 
| stats.c |	包含协议栈内部数据统计与显示的函数，比如内存使用状况、邮箱、信号量等信息| 
| sys.c	| 实现对操作系统模拟层的封装，为协议栈提供统一的邮箱、信号量操作函数。如果开发者需要使用协议栈的sequential API和socket API，则必须使用底层操作系统提供的邮箱与信号量机制，这时内核要求移植者提供一个称为sys_arch.c的操作系统模拟层文件，这个文件主要完成对操作系统中邮箱与信号量函数的封装。而sys.c文件的功能是将sys_arch.c中的函数再次封装，以得到具有协议栈特色的邮箱、信号量操作函数。所谓特色，就是在这些函数中加入一种机制，以实现协议栈中各个定时事件的正确处理。不使用sequential API和socket API时，开发者不需要再实现sys_arch.c中的函数，sys.c对内核来说也没用了，因为此时系统不需要任何邮箱和信号量机制。| 
| tcp.c	| 包含对TCP控制块操作的函数，也包含了TCP定时处理函数| 
| tcp_in.c	| 包含TCP协议数据接收、处理相关的函数，以及最重要的TCP状态机函数| 
| tcp_out.c	| 包含TCP协议数据发送相关函数，例如数据包发送、超时重传函数等| 
| udp.c	| 包含实现UDP协议的相关函数，包括控制块管理、数据包发送函数、数据包接收函数等| 


core/ipv4文件夹包含了IPv4标准中与IP层数据包处理相关的所有代码
| 文件	| 说明 |
| ---- | ---- |
| autoip.c | 	包含IP地址自动配置相关函数，若主机从DHCP服务器处获取IP地址失败，则此时主机可以选择启动AUTOIP功能来配置自身的IP地址。AUTOIP将主机配置为169.254.0.0/16中的某个地址，并提供一套完整的机制来避免IP地址冲突 |
| icmp.c	| 包含ICMP（网际控制报文协议）协议的实现代码。ICMP协议为IP数据包传递过程中的差错报告、差错纠正以及目的地址可达性测试提供了支持，常见的Ping命令就属于ICMP应用中的一种。 |
| igmp.c	| 包含IGMP（网络组管理协议）协议的实现代码。IGMP为网络中的多播数据传输提供了支持，主机加入某个多播组后，可以接收到改组的UDP多播数据。 |
| inet.c	| 包含IP层使用到的一些功能函数的定义，如IP地址的转换、网络字节序与主机字节序转换等 |
| inet_chksum.c	| 包含对IP数据包校验相关的函数 |
| ip.c	| 包含IPv4协议实现的相关函数，如数据包的接收、递交、发送等 |
| ip_addr.c	| 包含一个判断IP地址是否为广播地址的函数 |
| ip_frag.c	| 提供了IP层数据包分片与重组相关的函数 |


