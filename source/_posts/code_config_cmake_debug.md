---
title: 让configure和cmake编译时支持调试选项
date: 2018-03-04 17:02:58
updated: 2018-03-04 17:02:58
categories : 
  - [编程开发]
tags:
urlname: de0674deb69068bdaa99dbf80d9eb63d
---

在Linux先编译软件基本都是采用configure文件生成makefile，或者，cmake生成makefile文件两种方式。它们生成的makefile文件，一般默认不支持-g调试选项。
但我们使用这种方式编译出来的静态库时，如果程序运行中core在静态库中，我们看不到有用的相关信息。所以有必要编译出debug版本。

## 针对configure文件而言：
第一种方法:./configure -h， 我们会看到这样的信息。
![](/images/de0674deb69068bdaa99dbf80d9eb63d/1.png)

我们可以在环境变量中，设置CFLAGS或者CXXFLAGS，这样的话，系统编译时会追加调试选项。

<br />

第二种方法：还是运行./configure -h，我们看到这样的信息。
![](/images/de0674deb69068bdaa99dbf80d9eb63d/2.png)

也就是说，我们在运行configure脚本的时候，加上选项--enable-debug，也同样会在生成的makefile中有调试选项了。

## 针对cmake而言：
一般，我是直接修改CMakeLists.txt文件，直接在其中添加-g选项。
![](/images/de0674deb69068bdaa99dbf80d9eb63d/3.png)
