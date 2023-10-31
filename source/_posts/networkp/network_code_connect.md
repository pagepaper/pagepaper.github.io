---
title: 同步以及异步connect
date: 2018-09-13 10:50:50
updated: 2018-09-13 10:50:50
categories : 
  - [网络编程]
tags:
urlname: 82fbc5d807d8cc41ab7379376be73ba4
---
## 背景
``` c
#include <sys/types.h>
#include <sys/socket.h>
 
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```
connect是socket套接口编程中非常重要的一个函数，它用于客户机连接使用TCP协议打开的服务机。

connect有同步连接和异步连接两种模式。
 > * 同步连接指的是，我们设置socket套接字为阻塞模式，调用connect之后，程序一直等待，直到该函数返回成功或者失败。如果连接过程中，发生了超时重传，接口的耗时时间有可能达127秒之久。假如我们的服务器程序只有一个网络线程，同步connect会阻塞该网络线程较长时间，在这段时间内将不能给其他连接提供服务。
 > * 异步连接指的是，我们设置socket套接字为非阻塞模式，调用connect之后，该函数会马上返回，如果连接立即成功，那么皆大欢喜，就不用进行下步操作了。如果连接没有立即成功，我们就用select或者epoll等待操作系统给我们通知，接到通知后，我们再判断连接成功与否。在高性能服务器程序中，我们优先使用异步连接这种模式。

## connect的错误场景
<strong>第一种场景：连接因特网中一个没有响应的主机。</strong>
此种场景下，发起方执行三次握手中的第一步向因特网上发出SYNC包，经过网络上的各种中间路由器转发之后，仍然找不到主机或者主机不回包或者该SYNC包直接被路由器丢弃。发起方得不到SYNC响应，然后它会根据系统定义的超时重试机制，多次发送SYNC包。如果在执行完超时重传机制之后，发起方仍然得不到响应，那么它就放弃重试，并返回一个错误码为ETIMEDOUT(110)的超时错误给客户端程序。Linux系统默认发送7次connect请求，共计经历127秒等待。

下图是我在内网抓包连接114.144.144.144的情况，这个IP好像是日本的一个IP地址，但在我的网络里没有响应。
![](/images/82fbc5d807d8cc41ab7379376be73ba4/1.png)

<strong>第二种场景：连接网络中一个不可达的主机。</strong>
此种场景下，分两种情况，其一是有路由规则，但该主机压根不存在，比如我在本地子网(192.168.9.X)中连接192.168.9.200这个不存在的主机，其二是没有路由规则进行数据转发。这两种情况下，无论是同步还是异步connect，都会跟ETIMEDOUT错误一样，在等待规定的一段时间后，返回给客户端程序一个ENETUNREACH(113)的错误。

客户端连接192.168.9.200，客户主机发出ARP请求，要求那个不存在的主机响应以其硬件地址，客户端得不到ARP响应，向上报ENETUNREACH错误。
![](/images/82fbc5d807d8cc41ab7379376be73ba4/2.png)

<br/>

客户端连接14.215.187.40，这个是IP是因特网中不可到达的IP地址。如果我们用tcpdump观察分组的情况，就会发现6跳以远的路由器返回了主机不可达的ICMP错误。这种情况下connect也会很快失败，然后返回一个ENETUNREACH(113)的错误给客户端程序。
![](/images/82fbc5d807d8cc41ab7379376be73ba4/3.png)

<br/>

第三种场景：连接网络中一个可达的主机，但该主机端口未打开。
此种场景下，客户端连接192.168.9.46上的7788，但在7788这个端口上没有进程在等待与之连接。服务机接到SYNC包之后，返回客户机RST包，客户机收到RST之后，马上向客户端程序返回一个ECONNREFUSED(111)的错误。
![](/images/82fbc5d807d8cc41ab7379376be73ba4/4.png)


## connect超时时间和重试次数
Linux系统默认重试6次，总时间为127秒。我们看下它的超时重试行为：
（1）第 1 次发送SYN后等待   1s，如果超时，则重试
（2）第 2 次发送SYN后等待   2s（前次等待时间的2倍），如果超时，则重试
（3）第 3 次发送SYN后等待   4s（前次等待时间的2倍），如果超时，则重试
（4）第 4 次发送SYN后等待   8s（前次等待时间的2倍），如果超时，则重试
（5）第 5 次发送SYN后等待 16s（前次等待时间的2倍），如果超时，则重试
（6）第 6 次发送SYN后等待 32s（前次等待时间的2倍），如果超时，则重试
（7）第 7 次发送SYN后等待 64s（前次等待时间的2倍），如果超时，则超时失败
所以默认情况下，发送7次SYN报文其中重试6次，总等待时间为：1s+2s+4s+8s+16s+32s+64s=127s。

对于有些客户端程序来说，127秒的时间太长了。怎么修改这个时间呢？Linux内核中，net.ipv4.tcp_syn_retries表示建立TCP连接时SYN报文重试的次数，默认为6次。我们使用下面的命令可以查看机器的相应设置：

``` bash
motadou@dev-0-0:~$ sudo sysctl net.ipv4 | grep tcp
......
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_sack = 1
net.ipv4.tcp_slow_start_after_idle = 1
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_syn_retries = 6
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_thin_dupack = 0
net.ipv4.tcp_thin_linear_timeouts = 0
net.ipv4.tcp_timestamps = 1
......
```
<br />

使用如下命令修改重试次数：
![](/images/82fbc5d807d8cc41ab7379376be73ba4/5.png)

值得我们注意的是，sysctl修改的内核参数在系统重启之后失效，如果需要持久化，将其添加到系统配置文件中。方法是，编辑/etc/sysctl.conf，添加： net.ipv4.tcp_syn_retries = 3即可。


## 同步连接（阻塞连接）
阻塞连接比较简单，创建网络套接字之后，就可以使用connect进行连接。默认创建的套接口为阻塞式。
``` c
// 保存当前文件为：connect.cpp
// 编译：g++ -o connect connect.cpp
// 运行：./connect
#include <iostream>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <arpa/inet.h>
 
int main(int argc, char ** argv)
{
    // 创建socket套接口
    int iSocketFd = ::socket(AF_INET, SOCK_STREAM, 0);
 
    // 转换IP地址
    struct sockaddr_in xAddr;
    xAddr.sin_family = AF_INET;
    xAddr.sin_port   = htons(7788);
    if (::inet_pton(AF_INET, "192.168.9.46", &(xAddr.sin_addr)) != 1)
    {
        return -1;
    }
 
    // 阻塞式连接192.168.9.46的7788端口
    int iRet = ::connect(iSocketFd, (struct sockaddr *)&xAddr, sizeof(xAddr));
 
    if (iRet == 0) 
    {
        // 连接成功
        std::cout << "connect success" << std::endl;
    }
    else
    {
        // 连接失败，查看errno，获取错误原因
        std::cout << "connect error:" << iRet << ", errno:" << errno << std::endl;
    }
 
    return 0;
}
```

## 异步连接（非阻塞连接）
异步连接流程：
* 第一步：使用socket创建套接口；
* 第二步：设置套接口为非阻塞模式（默认为阻塞模式）;
* 第三步：调用connect进行连接；
* 第四步：判断第三步connect的返回值，如果返回值为0，表示连接立即成功，至此连接全部完成，不用再进行下面的步骤；
* 第五步：判断第三步connect的返回值，如果返回值不为0，此时有两种情况：第一种情况errno为EINPROGRESS，表示连接没有立即成功，需进行二次判断，进入第六步；第二种情况errno不为EINPROGRESS，表示连接失败，调用close关闭套接口之后，再次connect；
* 第六步：将该套接口加入epoll中，调用epoll_wait等待套接口的通知；
* 第七步：如果连接成功，正常情况下epoll触发EPOLLOUT事件，不会触发EPOLLIN事件。但有一种情况，如果connect成功之后，服务端马上发送数据，此时客户端也会立刻得到EPOLLIN事件。如果连接失败，我们会得到EPOLLIN、EPOLLOUT、EPOLLERR和EPOLLHUP事件。

``` c
// 保存当前文件为：connect.cpp
// 编译：g++ -o connect connect.cpp
// 运行：./connect
#include <iostream>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/epoll.h>
#include <unistd.h>
#include <fcntl.h>
 
static int SetNonBlock(int iFd) 
{
    int iFLValue = 0;
 
    if ((iFLValue = ::fcntl(iFd, F_GETFL, 0)) == -1)
    {
        return -1;
    }
 
    return ::fcntl(iFd, F_SETFL, iFLValue | O_NONBLOCK);
}
 
int AsyncConnect(int iSocketFd)
{
    int32_t iEpollFd = ::epoll_create(1);
 
    // 添加网络套接口文件描述符到epoll中
    struct epoll_event xEvent;
    xEvent.data.u64 = iSocketFd;
    xEvent.events   = EPOLLET | EPOLLOUT | EPOLLIN;
 
    ::epoll_ctl(iEpollFd, EPOLL_CTL_ADD, iSocketFd, &xEvent);
 
    // 等待epoll通知
    int iRet = ::epoll_wait(iEpollFd, &xEvent, 1, 10*1000);
 
    std::cout << "iRet:" << iRet << std::endl;
 
    if (iRet == -1)
    {
        std::cout << "epoll错误，具体错误查看errno" << std::endl;
 
        return -1;
    }
 
    if (iRet == 0)
    {
        std::cout << "连接失败, 等待超时" << std::endl;
 
        return -1;
    }
 
    // 如果是连接失败，必定触发EPOLLERR和EPOLLHUP
    if (xEvent.events & EPOLLERR || xEvent.events & EPOLLHUP)
    {
        std::cout << "连接失败" << std::endl;
 
        return -1;
    }
 
    std::cout << "连接成功" << std::endl;
 
    return 0;
}
 
int main(int argc, char ** argv)
{
    // 创建socket套接口
    int iSocketFd = ::socket(AF_INET, SOCK_STREAM, 0);
 
    // 设置为非阻塞套接口
    SetNonBlock(iSocketFd);
 
    // 转换IP地址
    struct sockaddr_in xAddr;
    xAddr.sin_family = AF_INET;
    xAddr.sin_port   = htons(7788);
    if (::inet_pton(AF_INET, "114.144.144.144", &(xAddr.sin_addr)) != 1)
    {
        return -1;
    }
 
    // 非阻塞式连接
    int iRet = ::connect(iSocketFd, (struct sockaddr *)&xAddr, sizeof(xAddr));
 
    if (iRet == 0)                  // 异步连接，立即成功的情况
    {
        std::cout << "连接立即成功" << std::endl;
    }
    else if (errno == EINPROGRESS)  // 异步连接，延迟成功的情况，开始进入异步连接模式
    {
        if (AsyncConnect(iSocketFd) == -1)
        {
            ::close(iSocketFd);     // 如果失败，记得关闭套接字
        }
    }
    else                            // 连接失败，查看errno，获取错误原因
    {
        std::cout << "连接失败, errno:" << errno << std::endl;
 
        ::close(iSocketFd);         // 如果失败，记得关闭套接字
    }
 
    return 0;
}
```
<br />

<strong>关于上述代码的说明：</strong>
我们是在响应事件EPOLLERR&EPOLLHUP的代码中来判断连接失败的情况，还有一种方法是在响应EPOLLIN或者EPOLLOUT的代码中，调用getsockopt来进行判断：如果描述符变为可读或者可写，我们就调用getsockopt取得套接字的待处理错误，如果连接成功建立，该值为0，否则该值就是对应连接错误的errno（比如ECONNRERUSED、ETIMEDOUT等）。

``` c
int iVal = 0;
socklen_t iLen = static_cast<socklen_t>(sizeof(int));
if ((::getsockopt(iSocketFd, SOL_SOCKET, SO_ERROR, reinterpret_cast<char *>(&iVal), &iLen) == -1) || (iVal != 0))
{
    std::cout << "连接错误，errno为：" << iVal << std::endl;
 
    return -1;
}
```
