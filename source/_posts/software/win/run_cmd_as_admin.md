---
title: Windows11以管理员身份运行cmd
date: 2022-03-04 17:02:58
updated: 2022-03-04 17:02:58
categories : 
  - [软件使用]
tags:
urlname: 6f873326a47848b2b3cc51063fdb5489
---
超级管理员系统内置的一个用户组，所有管理员用户都在这个组下，默认我们打开的cmd是普通用户组而非超级管理员，在Windows上编程开发，有些命令必须以管理员身份运行cmd，下面是两种操作方法。

<!--more-->

## 第一种，从开始菜单进入

+ 1.首先点击任务栏中的“开始菜单”
![](/images/6f873326a47848b2b3cc51063fdb5489/1.png)

+ 2.点击上方“搜索应用、设置和文档”
+ 3.输入cmd，然后我们看到如下界面
![](/images/6f873326a47848b2b3cc51063fdb5489/2.png)
点击“以管理员身份运行”，即可打开管理员身份的cmd对话框，此处输入的命令既以管理员身份运行。
![](/images/6f873326a47848b2b3cc51063fdb5489/3.png)

## 第二种，从右键菜单进入
上述方法倒是简单直接，但这种方法启动之后是进入的"C:\Windows\System32"目录，有的时候我们期望类似如下的操作。
在特定的文件夹，点击右键，右键菜单有个"在终端中打开"，点击该菜单项之后，进入cmd，并进入特定的目录。

![](/images/6f873326a47848b2b3cc51063fdb5489/4.png)

但以这种方法打开的cmd并非管理员身份，所以我们要在右键菜单中增加一个菜单项，点击特定的菜单项进入管理员模式。

``` bash
Windows Registry Editor Version 5.00
[HKEY_CLASSES_ROOT\Directory\Background\shell\runas]
@="以管理员身份运行命令提示符"
"NoWorkingDirectory"=""
"Extended"=""
[HKEY_CLASSES_ROOT\Directory\Background\shell\runas\command]
@="cmd.exe /s /k pushd \"%V\""
```

将如上内容保存为文件"admin.reg"，然后双击运行该文件。我们再在特定的目录，按住键盘上的”Shift“键，同时点击右键，此时的右键菜单将有一个”以管理员身份运行命令提示符“菜单项，点击该菜单项打开管理员身份的cmd窗口。

![](/images/6f873326a47848b2b3cc51063fdb5489/5.png)

点击“以管理员身份运行命令提示符”菜单项后：
![](/images/6f873326a47848b2b3cc51063fdb5489/6.png)

## 参考文档：
1.https://wp.xanderye.cn/archives/31
2.https://www.xtzjcz.com/pc/245221.html
