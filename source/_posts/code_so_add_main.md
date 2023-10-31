---
title: 实现可执行的so动态链接库
date: 2018-09-14 09:12:58
updated: 2018-09-14 09:12:58
categories : 
  - [编程开发]
tags:
urlname: d35b2923c9174ea2f2275ceef6feb78f
---
## 背景
相比于静态链接库，Linux上的动态链接库和可执行程序都是ELF格式。原理上动态库也能和可执行程序一样直接运行。

比如，可以直接运行“/lib64/ld-linux-x86-64.so.2”，还有“/lib/x86_64-linux-gnu/libpthread.so.0”， 还有“/lib/x86_64-linux-gnu/libc.so.6”等等。举个例子，libc.so.6是C/C++运行时库的GNU实现，我们直接运行该动态库，打印如下信息：
![](/images/d35b2923c9174ea2f2275ceef6feb78f/1.png)

可见，动态库直接运行后，提示了该动态库的编译信息、版本信息等等。在实际项目中，我们也可以为动态库增加类似功能，用户直接运行我们提供的动态库之后，我们就打印该库的编译环境、运行方法、编译版本等等信息，或者完成其他功能。

## 让动态库可以直接运行的方法和原理
要让一个动态链接库可以直接运行，那么需要在其编译期间指定一个入口函数。当我们直接运行该动态库时，系统直接调用该入口函数。
C语言的实现示例如下：
``` c
// 保存：将本文件保存，比如名称叫做：sotest.c
// 编译：gcc -shared sotest.c -o libtest.so -Wl,-e,__lib_main -fPIC
// 运行：./libtest.so
 
#include <stdio.h>
#include <unistd.h> // needed for the _exit() function
 
// Must define the interpretor to be the dynamic linker
#ifdef __LP64__
const char service_interp[] __attribute__((section(".interp"))) = "/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2";
#else
const char service_interp[] __attribute__((section(".interp"))) = "/lib/ld-linux.so.2";
#endif
 
void __lib_main(void)
{
    printf("Entry point of libtest.so \n");
 
    _exit(0);
}
```
编译运行：
![](/images/d35b2923c9174ea2f2275ceef6feb78f/2.png)

其中：
 > * 1）service_interp指明了动态链接器ld的位置，系统不同，该位置可能不同；
 > * 2）入口函数__lib_main必须以_exit(0)或者exit(0)结束，否则可能会coredump；
 > * 3）-Wl表示传递给动态链接器ld的参数，后续的逗号会被替换为空格；
 > * 4）-e,__lib_main指定了入口函数，__lib_main名称仅示例，名称可自取;

C++的实现方法和C版本没有大的区别，需要在其入口函数加上extern "C"，来表明按照C语言的编译和链接规约来编译和链接，而不是C++的编译的链接规约。

C++语言的实现示例如下：

``` c
// 保存：将本文件保存，比如名称叫做：sotest.cpp
// 编译：g++ -shared sotest.cpp -o libtest.so -Wl,-e,__lib_main -fPIC
// 运行：./libtest.so
 
#include <stdio.h>
#include <unistd.h> // needed for the _exit() function
 
// Must define the interpretor to be the dynamic linker
#ifdef __LP64__
const char service_interp[] __attribute__((section(".interp"))) = "/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2";
#else
const char service_interp[] __attribute__((section(".interp"))) = "/lib/ld-linux.so.2";
#endif
 
extern "C" {
     
void __lib_main(void)
{
    printf("Entry point of libtest.so \n");
 
    _exit(0);
}
 
}
```

## 入口函数的参数问题
动态链接库的入口函数不能像可执行程序int main(int argc, char \*\* argv)那样直接传入和获取参数。如果我们要向动态库的入口函数传递参数，动态库必须自己分析/proc/self/cmdline文件中的内容，自行分割参数。

示例如下：
``` c++
// 保存：将本文件保存，比如名称叫做：sotest.c
// 编译：gcc -shared sotest.c -o libtest.so -Wl,-e,__lib_main -fPIC
// 运行：./libtest.so 111 222 333 444 555 666 777
 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
 
struct CmdLine
{
    int     argc;
    char ** argv;
};
 
void ReadCmdLine(struct CmdLine * pLine)
{
    pLine->argc = 0;
    pLine->argv = NULL;
 
    /////////////////////////////////////////////////////////////////////////////////////
    /// 读取文件
    int32_t iFileId = open("/proc/self/cmdline", O_RDONLY, 0644);
    if (iFileId < 0)
    {
        return ;
    }
 
    char szBuff[8192];
    int iFileSize = read(iFileId, szBuff, sizeof(szBuff));
    int iBegin    = 0;
    int iTemp     = 0;
 
    close(iFileId);
 
    /////////////////////////////////////////////////////////////////////////////////////
    /// 分析cmdLine
    for (iTemp = 0; iTemp < iFileSize; iTemp++)
    {
        if (szBuff[iTemp] == '\0')
        {
            pLine->argc++;
        }
    }
 
    pLine->argv = (char **)malloc(pLine->argc * sizeof(char *));
 
    for (iTemp = 0, pLine->argc = 0; iTemp < iFileSize; iTemp++)
    {
        if (szBuff[iTemp] == '\0')
        {
            char * p = (char *)malloc(iTemp - iBegin + 1);
 
            memcpy(p, szBuff + iBegin, iTemp - iBegin);
 
            p[iTemp - iBegin] = '\0';
 
            pLine->argv[pLine->argc++] = p;
 
            iBegin = iTemp + 1;
        }
    }
}
 
// Must define the interpretor to be the dynamic linker
#ifdef __LP64__
const char service_interp[] __attribute__((section(".interp"))) = "/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2";
#else
const char service_interp[] __attribute__((section(".interp"))) = "/lib/ld-linux.so.2";
#endif
 
void __lib_main(void)
{
    printf("Entry point of libtest.so \n");
 
    struct CmdLine cmdLine;
 
    ReadCmdLine(&cmdLine);
 
    printf("argc:%d\n", cmdLine.argc);
 
    int iTemp = 0;
    for ( ; iTemp < cmdLine.argc; iTemp++)
    {
        printf("arg:%s\n", cmdLine.argv[iTemp]);
    }
 
    _exit(0);
}
```
运行上述示例代码：

![](/images/d35b2923c9174ea2f2275ceef6feb78f/3.png)


参考
1.[《Advanced C and C++ Compiling》](http://product.dangdang.com/1033555531.html)
2.http://rachid.koucha.free.fr/tech_corner/executable_lib.html

