---
title: shell文件重定向
urlname: 5d1e3638f76ab779f19b753cc83ed58c
categories : 
  - [编程开发]
  - [Shell]
tags: [Shell]
date: 2007-04-18 15:01:01
updated: 2007-04-18 15:01:01
---
Shell编程中常用的文件描述符有3个：
0：stdin，标准输入，默认指的是键盘输入
1：stdout，标准输出，默认指的是屏幕输出
2：stderr，标准错误输出，默认值得是屏幕输出

重定向简单例子
命令举例    含义
cmd > file    把 stdout 重定向到 file 文件中
cmd >> file    把 stdout 重定向到 file 文件中(追加)
cmd 1> fiel    把 stdout 重定向到 file 文件中
cmd > file 2>&1    把 stdout 和 stderr 一起重定向到 file 文件中
cmd 2> file    把 stderr 重定向到 file 文件中
cmd 2>> file    把 stderr 重定向到 file 文件中(追加)
cmd >> file 2>&1    把 stderr 和 stderr 一起重定向到 file 文件中(追加)
cmd < file >file2    cmd 命令以 file 文件作为 stdin，以 file2 文件作为 stdout
cat <>file    以读写的方式打开 file
cmd < file cmd    命令以 file 文件作为 stdin
cmd << delimiter Here document 从 stdin 中读入，直至遇到 delimiter 分界符