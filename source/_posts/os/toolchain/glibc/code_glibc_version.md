---
title: 查看glibc版本号
date: 2008-05-03 14:18:58
updated: 2008-05-03 14:18:58
categories : 
  - [编程开发]
tags: [GLIBC,工具链]
urlname: 70c2eff34a271c6535445168b4e91867
---
glibc是标准C库的GNU实现。我们采用C/C++所写的程序，运行时基本都依赖与它。如果我们想看当前机器glibc的源代码，首先需要知道当前机器glibc的版本号，然后到glibc的官网下载对应版本的源代码。


## 查看当前机器glibc的版本号
第一种方法：使用命令ldd，查看可执行程序依赖libc的路径。
![](/images/70c2eff34a271c6535445168b4e91867/1.png)根据输出可知，系统采用的是libc-2.19.so的动态库，那么glibc的版本号是2.19。

第二种方法：执行libc.so查看输出的glibc编译信息，里面包含了版本号。
![](/images/70c2eff34a271c6535445168b4e91867/2.png)
<p>

第三种方法：使用命令 ldd --version（ldd是glibc提供的命令，由此可知glibc的版本号）。
![](/images/70c2eff34a271c6535445168b4e91867/3.png)
<p>

第四种方法：使用命令 getconf GNU_LIBC_VERSION。
![](/images/70c2eff34a271c6535445168b4e91867/4.png)
<p>

第五种方法：编程获取glibc的版本号。
``` c
#include <stdio.h>
#include <gnu/libc-version.h>
int main(void) 
{ 
    printf("glibc version:%s\n", gnu_get_libc_version());
 
    return 0; 
}
```
执行以上程序，输出如下：
![](/images/70c2eff34a271c6535445168b4e91867/5.png)
<p>

## 下载glibc源代码
glibc官网地址：https://www.gnu.org/software/libc/
glibc源代码包：https://ftp.gnu.org/gnu/glibc/
![](/images/70c2eff34a271c6535445168b4e91867/6.png)