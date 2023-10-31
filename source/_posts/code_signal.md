---
title: Linux编程的信号机制
date: 2019-06-25 10:52:34
updated: 2019-06-25 10:52:34
categories : 
  - [编程开发]
tags:
urlname: 8ab057b83c644a0771f3a1b81597a11b
---
信号是一种软件中断。常驻程序尤其需要注意处理这些信号，如果没有处理，同时也没有了解信号的默认动作，进程可能会莫名其妙的退出或者core。信号早已有之，但在老的操作系统中，可能会出现信号丢失。4.3BSD和SVR3之后增加了可靠信号机制，我们可以放心使用信号机制。本文根据阅读Nginx代码，参考其信号处理机制，总结了信号使用方法和注意事项。

``` c
#define SIGHUP		 1
#define SIGINT		 2
#define SIGQUIT		 3
#define SIGILL		 4
#define SIGTRAP		 5
#define SIGABRT		 6
#define SIGIOT		 6
#define SIGBUS		 7
#define SIGFPE		 8
#define SIGKILL		 9
#define SIGUSR1		10
#define SIGSEGV		11
#define SIGUSR2		12
#define SIGPIPE		13
#define SIGALRM		14
#define SIGTERM		15
#define SIGSTKFLT	16
#define SIGCHLD		17
#define SIGCONT		18
#define SIGSTOP		19
#define SIGTSTP		20
#define SIGTTIN		21
#define SIGTTOU		22
#define SIGURG		23
#define SIGXCPU		24
#define SIGXFSZ		25
#define SIGVTALRM	26
#define SIGPROF		27
#define SIGWINCH	28
#define SIGIO		29
#define SIGPOLL		SIGIO
#define SIGPWR		30
#define SIGSYS		31

struct sigaction 
{
    union 
    {
        __sighandler_t _sa_handler;
        
        void (*_sa_sigaction)(int, struct siginfo *, void *);
    } _u;

    sigset_t sa_mask;
    
    unsigned long sa_flags;
    
    void (*sa_restorer)(void);
};
```
下表列出了各信号在Linux（2.4.22）环境中代表的意思，以及信号默认动作：
 | 名字 | 说明 | ISO C | SUS | 默认动作 |
 | ---------- | ---------- | ---------- | ---------- | ---------- |
 | SIGABRT | 异常终止(abort)	 | &#x2714; | &#x2714; | 终止+core |
 | SIGALRM | 超时(abort) | | &#x2714; | 终止 |
 | SIGBUS |	硬件故障 | | &#x2714; | 终止+core |
 | SIGCHLD | 子进程状态改变	| | &#x2714; | 忽略 |
 | SIGCONT | 使暂停进程继续	| | &#x2714; | 继续/忽略 |
 | SIGEMT | 硬件故障 | | | 终止+core |
 | SIGFPE |	算术异常 | &#x2714; | &#x2714; | 终止+core |
 | SIGHUP | 连接断开 | | &#x2714; | 终止 |
 | SIGILL | 非法硬件指令 | &#x2714; | &#x2714; | 终止+core |
 | SIGINT | 终端中断符 | &#x2714; | &#x2714; | 终止 |
 | SIGIO | 异步I/O | | | 终止/忽略 |
 | SIGIOT | 硬件故障 | | | 终止+core |
 | SIGKILL | 终止 | | &#x2714; | 终止 |
 | SIGPIPE | 写至无读进程的管道	| | &#x2714; | 终止 |
 | SIGPOLL | 可轮询事件(POLL) | | XSI|终止 |
 | SIGPROF | 梗概事件超时(setitimer) |	| XSI| 终止 |
 | SIGPWR | 电源失效/重启动	| | | 		终止/忽略 |
 | SIGQUIT | 终端退出符	 	| | &#x2714; | 终止+core |
 | SIGSEGV	| 无效内存引用 | &#x2714; | &#x2714; | 终止+core |
 | SIGSTKFLT |	协处理器故障	| | |		终止|
 | SIGSTOP |	停止 | | &#x2714; | 暂停进程 |
 | SIGSYS	| 无效系统调用| |		XSI	|终止+core |
 | SIGTERM	| 终止	| &#x2714; | &#x2714; | 终止+core |
 | SIGTRAP	| 硬件故障|		| XSI	|终止+core |
 | SIGTSTP	| 终端停止符 | | &#x2714; |		暂停进程 |
 | SIGTTIN	| 后台读控制tty| | &#x2714; |		暂停进程 |
 | SIGTTOU	| 后台写至控制tty| | &#x2714; |		暂停进程 |
 | SIGURG	| 紧急情况(套接字，带外数据)| | &#x2714; |		忽略 |
 | SIGUSR1	| 用户自定义的信号| | &#x2714; |		终止 |
 | SIGUSR2	| 用户自定义的信号| | &#x2714; |		终止 |
 | SIGVTALRM |	虚拟时间闹钟(setitimer)| | 		XSI	| 终止 |
 | SIGWINCH	| 终端窗口大小改变| | |			忽略 |
 | SIGXCPU	| 超过CPU限制(setrlimit)|	 |	XSI	| 终止+core/忽略 |
 | SIGXFSZ	| 超过CPU限制(setrlimit)|		| XSI |	终止+core/忽略 |


## 备注
> * POSIX.1包含了ISO C标准函数库，同时结构分类两部分：必须部分和可选部分（X/Open系统接口(X/Open System Interface,XSI)）。
> * XSI是POSIX.1中的接口，描述了POSIX中的可选部分。
> * 单一UNIX规范（Single UNIX Specification，缩写为SUS），它是一套UNIX系统的统一规格书。SUS是POSIX的扩展，扩充了POSIX标准，定义了标准UNIX操作系统。只有遵循XSI的实现才能称为UNIX系统。
> * SUS、POSIX、ISO C的关系,可以总结为 SUS > POSIX > ISO C。

## 参考
1)https://blog.csdn.net/Ada_baby/article/details/44487451