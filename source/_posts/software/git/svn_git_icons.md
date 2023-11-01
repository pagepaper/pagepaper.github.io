---
title: 找回Svn和Git不见的文件图标
date: 2012-03-09 13:07:58
updated: 2012-03-09 13:07:58
categories : 
  - [工具使用]
tags:
urlname: 3aa7c02a866b00f888e1523895b6634e
---
安装云盘软件之后，导致原来Svn和Git的文件图标都不显示了。按照如下的方法找回图标。
![](/images/3aa7c02a866b00f888e1523895b6634e/1.png)

<!--more-->

第一步：使用组合键“Win+R”，打开“运行”窗口。在其中输入“regedit”打开注册表编辑器。
![](/images/3aa7c02a866b00f888e1523895b6634e/2.png)

第二步：使用组合键”Ctrl+F“，搜索”ShellIconOverlayIdentifiers“。
![](/images/3aa7c02a866b00f888e1523895b6634e/3.png)
我们可以看到"eDriveAppExt1"这些图标排在了Tortoise的图标之前，优先级被降低，导致Svn和Git的图标没有显示出来。解决方法就是重新提升Tortoise的优先级，我们在Tortoise的图标前多加几个空格，只要比“eDriveAppExt1"多一个空格就行。

第三步：关闭窗口退出，重新电脑。重启之后我们就可以看到熟悉的Svn和Git的图标了。
我们再打开注册表编辑器，看看Tortoise的图标权限，确实是排到了前面。
![](/images/3aa7c02a866b00f888e1523895b6634e/4.png)
