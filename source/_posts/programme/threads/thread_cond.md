---
title: pthread编程之条件变量
urlname: bd462c634547e829ad2d6c7004a56b6e
categories : 
  - [编程开发]
tags: [多线程,条件变量,PThraed]
date: 2008-01-18 21:01:01
updated: 2008-01-18 21:01:01
---
## 关于pthread条件变量
``` bash
$ man pthread_cond_init | col -b > pthread_cond.man
```
得到manual中的描述：

> A condition (short for ''condition variable'') is a synchronization device that allows threads to suspend execution and relinquish the processors until some predicate on shared data is satisfied. The basic operations on conditions are: signal the condition(when the predicate becomes true), and wait for the condition, suspending the thread execution until another thread signals the condition.


> 条件变量是同步线程的一种机制，它允许线程挂起，让出处理器等待其他线程向它发送信号，该线程收到该信号后被唤醒继续执行程序。对条件变量基本的操作就是：a）向条件变量发送信号，唤醒等待的线程；b）等待条件变量并挂起直至其他线程向该条件变量发送信号。为了防止竞争，条件变量总是和一个互斥锁同时使用。

## 条件变量相关函数
phtread条件变量主要有如下的这些函数：
``` c
#include <pthread.h>
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
int pthread_cond_init(pthread_cond_t *cond, pthread_condattr_t *cond_attr);
int pthread_cond_signal(pthread_cond_t *cond);
int pthread_cond_broadcast(pthread_cond_t *cond);
int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
int pthread_cond_timedwait(pthread_cond_t *cond, pthread_mutex_t *mutex, const struct timespec *abstime);
int pthread_cond_destroy(pthread_cond_t *cond);
```
返回0为成功，非0为失败。

> <font color="FF0000">注意：pthread_cond_init,pthread_cond_signal,pthread_cond_broadcast,pthread_cond_wait只返回0，不会返回其他错误码。也就是说这几个函数每次调用都会成功，编程时不用检查返回值。但pthread_cond_timedwait和pthread_cond_destroy会返回错误码，需要注意！</font>


## 条件变量创建
条件变量的初始化有两种方式：静态和动态方式。
1.静态方式
初始化方法：pthread_cond_t pcond = PTHREAD_COND_INITIALIZER;
对于静态分配的条件变量，如果使用默认的条件变量属性，可以直接使用PTHREAD_COND_INITIALIZER对条件变量进行赋值来初始化。pthread_cond_t是一个结构体，同样PTHREAD_COND_INITIALIZER是一个结构体常量。

2.动态方式
动态方式调用pthread_cond_init函数对条件变量初始化，该函数的第二个参数指向条件变量属性的结构体。尽管POSIX标准中为条件变量定义了属性，但在LinuxThreads中没有实现，因此cond_attr值通常设置为NULL。

## 条件变量等待
``` c
int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
```
pthread_cond_wait调用相当复杂，它是如下执行序列的一个组合：
(1)释放互斥锁 并且 线程挂起（这两个操作是一个原子操作）；
(2)线程获得信号，尝试获得互斥锁后被唤醒；

我们知道调用pthread_cond_signal给条件变量发送信号时，如果当时没有线程在等待这个条件变量，信号将被丢弃。如果"释放互斥锁"和"线程挂起"不是一个原子操作，那么pthread_cond_wait线程在"释放互斥锁"和"线程挂起"之间，如果有信号一旦发生，程序就会错失一次条件变量变化。
int pthread_cond_timedwait(pthread_cond_t *cond, pthread_mutex_t *mutex, const struct timespec *abstime)

返回错误码：ETIMEDOUT。如果在指定时刻前，没有信号发生。
返回错误码：EINTR。该函数被信号中断。
pthread_cond_timewait是等待条件变量的令一种形式，与前一种的区别是计时等待方式如果在给定时刻前条件没有满足，就返回ETIMEOUT结束等待。该函数在不同情况下会返回特定错误码，编程时请参照开发。

## 条件变量触发
``` c
int pthread_cond_signal(pthread_cond_t *cond);
```
pthread_cond_signal唤醒等待改条件变量所有线程中的一个。如果此时没有线程在等待该条件变量，那么就丢弃该信号，当做什么也没发生。如果有多个线程在等待，精确保证只有一个线程被唤醒。
int pthread_cond_broadcast(pthread_cond_t *cond);
pthread_cond_broadcast唤醒等待该条件变量所有线程。如果此时没有线程在等待该条件变量，那么就丢弃该信号，当做什么也没发生。

## 条件变量销毁
``` c
int pthread_cond_destroy(pthread_cond_t *cond);
```

返回错误码：EBUSY。当前还有线程在该条件变量上等待。
pthread_cond_destroy销毁一个条件变量，但只有在没有线程在该条件变量上等待的时候才能销毁，否则返回EBUSY。因为Linux实现的条件变量没有分配什么资源，所以注销动作只包括检查是否有等待线程。


## memcached应用条件变量实例
背景：memcached是一个多线程结构的程序，主线程负责接收和分发请求，工作者线程实际处理请求。工作者线程在主线程中创建。创建线程后，工作者线程需要完成一些初始化工作，才允许主线程继续执行，所以主线程需要等待这些工作者线程全部初始化完毕。
这里就使用到了条件变量，大体的流程是这样的：
(1)主线程初始化一个条件变量和一个互斥锁；
(2)主线程创建n个工作者线程；
(3)主线程调用pthread_mutex_lock锁定互斥锁，然后调用pthread_cond_wait在条件变量上wait，等待被唤醒；
(4)子线程执行初始化代码，完毕后获取互斥锁，累加已初始化线程数量，调用pthread_cond_signal给该条件变量发送信号，同时释放互斥锁；
(5)线程调度唤醒主线程，主线程检查现在已经初始化的线程数目，如果都初始化了就释放互斥锁，顺序执行其他代码；如果还没初始化完毕，调用pthread_cond_wait再次等待。

主线程执行如下代码：
``` c
/*主线程创建nthreads个线程，线程创建后进行初始化，初始化完毕后累加init_count*/
for (i = 0; i < nthreads; i++) 
{
	create_worker(worker_libevent, &threads[i]);
}

/*主线程等待线程全部初始化，条件是已初始化量init_count等于线程数nthreads*/
pthread_mutex_lock(&init_lock);
while (init_count < nthreads) 
{
       	pthread_cond_wait(&init_cond, &init_lock);
}
pthread_mutex_unlock(&init_lock);
```

工作者线程执行如下代码：
``` c
//TODO:初始化代码
pthread_mutex_lock(&init_lock);
init_count++;	//累加已初始化线程数量
pthread_cond_signal(&init_cond);
pthread_mutex_unlock(&init_lock);
```

看完这段代码之后，估计都会有一个疑问：流程(3)中互斥锁已被主线程获取了，在线程全部初始化完毕之前，主线程并没有显式释放互斥锁，为什么在流程(4)中工作者线程还能获取到互斥锁呢？在讲解pthread_cond_wait函数时说明过这个问题，也可以从下图看出其中奥妙。

![](/images/bd462c634547e829ad2d6c7004a56b6e/1.jpg)

