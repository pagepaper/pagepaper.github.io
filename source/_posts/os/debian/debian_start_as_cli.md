---
title: Debian以命令行界面启动
date: 2023-10-29 17:43:34
updated: 2023-10-29 17:43:34
categories : 
  - [Debian]
tags: [Debian,操作系统]
urlname: 61d8c7193f1b88013604e2667a0ec9df
---

使用虚拟机安装Debian，图形界面太耗资源，也用得比较少，所以还是以命令行界面启动比较好。如下是Debian12.10的设置方式。

<!--more-->

## 第一步：打开grub配置文件
```
$ sudo vi /etc/default/grub
```
修改前文件：
![](/images/61d8c7193f1b88013604e2667a0ec9df/1.png#pic_left)

修改后文件：
![](/images/61d8c7193f1b88013604e2667a0ec9df/2.png#pic_left)

## 第二步：更新grub
```
$ sudo update-grub
```

![](/images/61d8c7193f1b88013604e2667a0ec9df/3.png#pic_left)


## 第三步：更新系统服务管理器配置
```
$ sudo systemctl set-default multi-user.target
```

![](/images/61d8c7193f1b88013604e2667a0ec9df/4.png#pic_left)

## 第四步：重启系统
```
$ sudo reboot
```
  
<font margin-top:150px>参考文档：</font>
https://zhuanlan.zhihu.com/p/36080220
