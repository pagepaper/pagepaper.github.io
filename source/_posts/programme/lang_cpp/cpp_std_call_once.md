---
title: C++11特性之std:call_once
urlname: 1a927e37caa6612edd2c10e9c4e2f8ce
categories : 
  - [C++]
tags: [C++,C++11]
date: 2018-03-26 22:18:00
updated: 2018-03-26 22:18:00
---
## 使用背景
在多线程编程环境中，我们有时希望某个操作只做一次，比如获取一些系统变量；或者某个函数只被调用一次。我们就可以采用系统提供的std::call_once来保证。

我们再看下call_once的定义：
``` c++
template< class Callable, class... Args >
void call_once( std::once_flag& flag, Callable&& f, Args&&... args );
```

<!--more-->

## 用法示例
``` c++
// 将文件保存为 call.cpp
// 编译：g++ -o test call.cpp -std=c++11 -pthread
// 运行：./test
#include <iostream>
#include <thread>
#include <mutex>
#include <sys/time.h>
#include <sys/resource.h>
 
int GetMaxOpenFileSys(struct rlimit *rlim)
{
    // 获取最大文件描述符数量
    ::getrlimit(RLIMIT_NOFILE, rlim);
     
    printf("GetMaxOpenFileSys Called\n");
}
 
int GetMaxOpenFile()
{
    static std::once_flag once_flag;
    static struct rlimit  rlimit;
 
    // 保证在多线程环境下，只调用GetMaxOpenFileSys一次
    // 也就是说保证只调用::getrlimit一次
    std::call_once(once_flag, GetMaxOpenFileSys, &rlimit);
 
    return rlimit.rlim_max;
}
 
void ThreadEntry()
{
    // 线程入口函数，我们先获取系统允许可打开的最多文件描述符数量
    printf("MaxOpenFile:%d\n", GetMaxOpenFile());
}
 
int main(int argc, char ** argv)
{
    std::thread xThreadA(ThreadEntry);
    std::thread xThreadB(ThreadEntry);
    std::thread xThreadC(ThreadEntry);
    std::thread xThreadD(ThreadEntry);
 
    xThreadA.join();
    xThreadB.join();
    xThreadC.join();
    xThreadD.join();
 
    return 0;
}
```

程序运行结果：
``` bash
motadou@dev-0-0:/home/motadou/objs/test$ ./test 
GetMaxOpenFileSys Called
MaxOpenFile:4096
MaxOpenFile:4096
MaxOpenFile:4096
MaxOpenFile:4096
```

从上面的运行结果，我们就可以看到程序在多线程环境中，只调用了GetMaxOpenFileSys（）一次。
