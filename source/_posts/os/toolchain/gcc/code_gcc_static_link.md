---
title: gcc全静态链接
date: 2008-05-01 20:15:58
updated: 2008-05-01 20:15:58
categories : 
  - [编程开发]
tags: [GCC,工具链]
urlname: 998488cc6ef362e4e5d93fc11969a197
---
昨天看一篇关于libco的博文，里面提到了一个由于全静态链接导致的bug。全静态链接？以前没有接触过这个概念，特意到网上搜了下，原来是一个程序将其依赖的所有动态库都替换成对应静态库，即使是libc.so,libm.so,libstdc++.so这种系统级别的动态库。全静态链接出来的可执行程序，不依赖任何动态库，拷贝到任何一台机器，只需要操作系统，这个程序就可以run起来。

这种全静态链接的方式，肯定有好有坏。
* 第一，缺点：浪费了磁盘空间。全静态链接出来的可执行程序要比动态链接的大。但目前磁盘普遍够大，这个缺点基本可以忽略。
* 第二，缺点：浪费了内存空间。我们知道相同的动态库在内存中只存在一份，被多个程序共享。而静态库，是需要全部加载到内存的。所以多多少少要浪费一些内存空间。目前来看，内存仍然是服务器中宝贵的资源，能省一些肯定划算。
* 第三，优点：屏蔽了动态库的版本差异。由于静态链接把所有依赖的函数，全部打包进可执行程序，不依赖于特定机器的动态库函数版本。所有分布式部署的程序，其行为一致。

那全静态链接如何优雅的实现呢？gcc为我们提供了(-static)、(-Wl,-Bstatic)、(-Wl,-Bdynamic)，这么几个选项。

<!--more-->

<strong>第一种用法：使用-static选项，将全部动态库都用静态库替换。</strong>
这里有个基于boost库的程序，我们使用普通动态链接的方式编译出来，看看可执行程序的依赖关系。
![](/images/998488cc6ef362e4e5d93fc11969a197/1.png)由上图可见，可执行程序依赖于libboost_thread.so.1.72.0、libpthread.so.0、libstdc++.so.6、libc.so.6等等动态库。我们再用-static编译这个程序，再看看可执行程序的依赖关系。

<p>

![](/images/998488cc6ef362e4e5d93fc11969a197/2.png)由上图可见，加入-static选项以后，链接器将动态库全部换成了静态库。


<strong>第二种用法：使用-Wl,-Bstatic，-Wl,-Bdynamic选项，将部分动态库设置为静态链接。</strong>
gcc使用-Wl将参数传递给连接器。链接器使用-Bdynamic强制连接动态库，-Bstatic强制连接静态库。所以部分静态，部分动态连接这么写：
``` bash
gcc -Wl,-Bstatic -l<static-lib> -Wl,-Bdynamic -l<dynamic-lib>
```
我们还是使用上面的boost.cpp作为例子，本次编译我们将libboost_thread.so.1.72.0用作静态编译，其他系统动态库，任然以动态库的方式进行连接。
![](/images/998488cc6ef362e4e5d93fc11969a197/3.png)由上图可见，libboost_thread.so.1.72.0已经是静态链接，而其他系统库，任然是动态链接。

参考1：https://www.zhihu.com/question/22940048/answer/222625910
参考2：https://www.jianshu.com/p/3f1ec6748655